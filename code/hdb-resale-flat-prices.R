##########################
# HDB Resale Flat Prices #
##########################

# 1.0 Setup ----
## 1.1 Load libraries ----
library(tidyverse)
library(scales)
library(zoo)
library(flextable)
library(sf)

# 2.0 Load Data ----
## 2.1 Clean up files and rename new downloaded files ----
list.files(
  "data/",
  pattern = "^Resaleflatprices",
  full.names = TRUE
) %>%
  walk(~ file.rename(.x, "data/hdb-resale-flat-prices.csv"))

## 2.2 Read local file ----
resale_flat_prices_raw <- read_csv(
  "data/hdb-resale-flat-prices.csv"
)

## 2.3 Read spatial data (Masterplan subzones) ----
sg_map_raw <- st_read("data/map-data/masterplan-2019-planning-area.geojson")

# 3.0 Prep Data ----
## 3.1 Convert month to yearmon, calculate price per sqm and parse remaining lease into a decimal ----
resale_flat_prices_clean <- resale_flat_prices_raw %>%
  mutate(
    month = as.yearmon(month, format = "%Y-%m"),
    price_per_sqm = resale_price / floor_area_sqm,
    lease_years = as.numeric(str_extract(
      remaining_lease,
      "\\d+(?=\\s*years?)"
    )),
    lease_months = str_extract(remaining_lease, "\\d+(?=\\s*months?)"),
    lease_months = if_else(is.na(lease_months), 0, as.numeric(lease_months)),
    remaining_lease_numeric = lease_years + (lease_months / 12)
  ) %>%
  select(-lease_years, -lease_months)

## 3.2 Prep geospatial join data ----
town_price_summary <- resale_flat_prices_clean %>% 
  group_by(town) %>% 
  summarise(median_price_sqm = median(price_per_sqm, na.rm = TRUE)) %>% 
  mutate(town = str_replace(town, "KALLANG/WHAMPOA", "KALLANG"))

sg_map_clean <- sg_map_raw %>% 
  mutate(town = toupper(PLN_AREA_N)) %>% 
  left_join(town_price_summary, by = "town")
  
# 4.0 Shared Plot Configurations ----
## 4.1 Define a standardized base theme ----
base_theme <- list(
  theme_minimal(base_size = 11),
  theme(
    plot.caption = element_text(hjust = 0, color = "gray40"),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )
)

## 4.2 Date scale configuration for clean year-only label output ----
min_date <- min(resale_flat_prices_clean$month)
max_date <- max(resale_flat_prices_clean$month)

date_breaks <- as.yearmon(seq(
  from = floor(min_date),
  to = ceiling(max_date),
  by = 2
))

date_scale <- scale_x_yearmon(
  format = "%Y",
  breaks = date_breaks
)

## 4.3 Price scale configuration (Millions) ----
price_scale_m <- scale_y_continuous(
  labels = label_dollar(scale = 1 / 1e+06, suffix = "M")
)

## 4.4 Dynamic update time-stamp ----
update_time <- format(Sys.time(), "%Y-%m-%d %H:%M", tz = "Asia/Singapore")
shared_caption <- paste0(
  "Data: Housing & Development Board (HDB) | Updated: ",
  update_time,
  " | Graphic: weiyuet"
)

# 5.0 Plotting Data ----
## 5.1 By Town ----
plot_1 <- resale_flat_prices_clean %>%
  filter(town != "CENTRAL AREA") %>%
  ggplot(aes(x = month, y = resale_price)) +
  geom_point(aes(color = resale_price >= 1e+06), size = 0.3, alpha = 0.4, show.legend = FALSE) +
  scale_color_manual(values = c("TRUE" = "coral1", "FALSE" = "gray75")) +
  geom_smooth(
    color = "royalblue",
    se = FALSE,
    linewidth = 0.8,
    method = "gam"
  ) +
  geom_hline(yintercept = 1e+06, linetype = "dotted", color = "black") +
  date_scale +
  price_scale_m +
  facet_wrap(~town) +
  base_theme +
  labs(
    title = "Million-dollar flats are not evenly distributed across towns",
    x = NULL,
    y = NULL,
    caption = shared_caption
  )

## 5.2 Multivariate Comparison (Time vs Price/Sqm vs Size vs Town) ----
plot_2 <- resale_flat_prices_clean %>%
  filter(
    town %in%
      c(
        "BISHAN",
        "BUKIT MERAH",
        "JURONG WEST",
        "MARINE PARADE",
        "TAMPINES",
        "TOA PAYOH"
      )
  ) %>%
  filter(flat_type %in% c("3 ROOM", "4 ROOM", "5 ROOM")) %>%
  ggplot(aes(x = month, y = price_per_sqm, color = flat_type)) +
  geom_smooth(se = FALSE, linewidth = 0.8, method = "gam") +
  date_scale +
  scale_y_continuous(labels = label_dollar()) +
  scale_color_viridis_d(option = "plasma", end = 0.8) +
  facet_wrap(~town, ncol = 3) +
  base_theme +
  labs(
    title = "Trends by Flat Size and Region",
    subtitle = "Price per sq meter growth across sample towns",
    x = NULL,
    y = "Price per Sqm ($)",
    color = "Flat Type",
    caption = shared_caption
  )

## 5.3 Lease Depreciation Impact ----
plot_3 <- resale_flat_prices_clean %>%
  ggplot(aes(x = remaining_lease_numeric, y = price_per_sqm)) +
  geom_point(color = "gray75", size = 0.3, alpha = 0.4) +
  geom_smooth(
    color = "royalblue",
    se = FALSE,
    linewidth = 1.0,
    method = "gam"
  ) +
  scale_x_reverse(limits = c(99, 35), breaks = seq(100, 40, -10)) +
  scale_y_continuous(labels = label_dollar()) +
  base_theme +
  labs(
    title = "How does an aging HDB lease affect its value?",
    subtitle = "Price per square meter vs. Remaining lease (years)",
    x = "Remaining Lease (Years left)",
    y = "Price per Sqm ($)",
    caption = shared_caption
  )

## 5.4 Geospatial Map ----
plot_4 <- ggplot(sg_map_clean) +
  geom_sf(aes(fill = median_price_sqm), color = "white", linewidth = 0.2) +
  scale_fill_viridis_c(option = "magma",
                       direction = -1,
                       labels = label_dollar(),
                       na.value = "gray90") +
  theme_void(base_size = 11) +
  theme(plot.caption = element_text(hjust = 0, color = "gray40"),
        legend.position = "bottom",
        legend.key.width = unit(1.5, "cm"),
        plot.background = element_rect(fill = "white")) +
  labs(title = "Geospatial Heatmap of HDB Resale Value",
       subtitle = "Median price per square meter by planning area",
       fill = "Median Price/Sqm",
       caption = shared_caption)

# 6.0 Summary Table ----
# Compute total and highest transacted price for million-dollar transactions
million_dollar_flat_summary <- resale_flat_prices_clean %>%
  filter(resale_price >= 1e+06) %>%
  group_by(Town = town) %>%
  summarise(
    `Total Million-Dollar Flats` = n(),
    `Highest Record Price` = max(resale_price)
  ) %>%
  arrange(desc(`Total Million-Dollar Flats`))

# Format summary table
table_image <- million_dollar_flat_summary %>%
  flextable() %>%
  theme_vanilla() %>%
  colformat_double(
    j = "Highest Record Price",
    big.mark = ",",
    digits = 0,
    prefix = "$"
  ) %>%
  colformat_int(j = "Total Million-Dollar Flats", big.mark = ",") %>% 
  add_footer_lines(shared_caption) %>%
  bg(bg = "white", part = "all") %>%
  autofit()

# 7.0 Export and Save Images ----
# Save plots
all_plots <- list(
  "town-absolute" = plot_1,
  "multivariate-sqm" = plot_2,
  "lease_decay" = plot_3,
  "geospatial_map" = plot_4
)

iwalk(
  all_plots,
  ~ ggsave(
    filename = paste0("figures/hdb-resale-flat-prices-", .y, ".png"),
    plot = .x,
    width = 10,
    height = 8
  )
)

# Save summary table
save_as_image(
  table_image,
  path = "figures/hdb-resale-flats-prices-summary-table.png"
)

cat("\nAnaylsis complete. Plots saved to `figures` directory.\n")

# End ----
