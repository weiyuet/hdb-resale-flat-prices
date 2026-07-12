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
## 3.1 Define estate classifications ----
mature_towns <- c(
  "ANG MO KIO",
  "BEDOK",
  "BISHAN",
  "BUKIT MERAH",
  "BUKIT TIMAH",
  "CENTRAL AREA",
  "CLEMENTI",
  "GEYLANG",
  "KALLANG/WHAMPOA",
  "MARINE PARADE",
  "PASIR RIS",
  "QUEENSTOWN",
  "SERANGOON",
  "TOA PAYOH"
)

## 3.2 Clean up data types ----
resale_flat_prices_clean <- resale_flat_prices_raw %>%
  mutate(
    month = as.yearmon(month, format = "%Y-%m"),
    price_per_sqm = resale_price / floor_area_sqm,
    estate_type = if_else(
      town %in% mature_towns,
      "Mature Estate",
      "Non-mature Estate"
    ),
    lease_years = as.numeric(str_extract(
      remaining_lease,
      "\\d+(?=\\s*years?)"
    )),
    lease_years = if_else(is.na(lease_years), 0, as.numeric(lease_years)),
    lease_months = str_extract(remaining_lease, "\\d+(?=\\s*months?)"),
    lease_months = if_else(is.na(lease_months), 0, as.numeric(lease_months)),
    remaining_lease_numeric = lease_years + (lease_months / 12),
    floor_lower = as.numeric(str_extract(storey_range, "^\\d+")),
    floor_upper = as.numeric(str_extract(storey_range, "\\d+$")),
    floor_mid = (floor_lower + floor_upper) / 2
  ) %>%
  select(-lease_years, -lease_months, -floor_lower, -floor_upper)

## 3.3 Prep geospatial data join ----
hdb_to_ura_translation <- c(
  "KALLANG/WHAMPOA" = "KALLANG",
  "CENTRAL AREA" = "DOWNTOWN CORE"
)

town_price_summary <- resale_flat_prices_clean %>%
  mutate(town_mapped = recode(town, !!!hdb_to_ura_translation)) %>%
  group_by(town = town_mapped) %>%
  summarise(
    median_price_sqm = median(price_per_sqm, na.rm = TRUE),
    .groups = "drop"
  )

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
    strip.text = element_text(face = "bold"),
    legend.position = "top"
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
  " | Project: https://github.com/weiyuet/hdb-resale-flat-prices"
)

# 5.0 Plotting Data ----
## 5.1 Price distributions by town ----
plot_1 <- resale_flat_prices_clean %>%
  ggplot(aes(x = month, y = resale_price)) +
  geom_point(
    aes(color = resale_price >= 1e+06),
    size = 0.3,
    alpha = 0.4,
    show.legend = FALSE
  ) +
  scale_color_manual(values = c("TRUE" = "coral1", "FALSE" = "gray75")) +
  geom_smooth(
    color = "royalblue",
    se = FALSE,
    linewidth = 0.8,
    method = "gam",
    formula = y ~ s(x, k = 5)
  ) +
  geom_hline(yintercept = 1e+06, linetype = "dotted", color = "black") +
  date_scale +
  price_scale_m +
  facet_wrap(vars(town)) +
  base_theme +
  labs(
    title = "Million-dollar flat distributions by towns",
    x = NULL,
    y = NULL,
    caption = shared_caption
  )

## 5.2 Multivariate comparison (Sqm growth) ----
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
  geom_point(size = 0.3, alpha = 0.4, color = "gray75") +
  geom_smooth(
    se = FALSE,
    linewidth = 0.8,
    method = "gam",
    formula = y ~ s(x, k = 5)
  ) +
  date_scale +
  scale_y_continuous(labels = label_dollar()) +
  scale_color_viridis_d(option = "viridis", end = 0.8) +
  facet_wrap(vars(town), ncol = 3) +
  base_theme +
  labs(
    title = "Price per sqm growth across sample towns",
    x = NULL,
    y = "Price per Sqm ($)",
    color = "Flat Type",
    caption = shared_caption
  )

## 5.3 Lease depreciation impact ----
plot_3 <- resale_flat_prices_clean %>%
  ggplot(aes(x = remaining_lease_numeric, y = price_per_sqm)) +
  geom_point(color = "gray75", size = 0.3, alpha = 0.4) +
  geom_smooth(
    color = "royalblue",
    se = FALSE,
    linewidth = 1.0,
    method = "gam",
    formula = y ~ s(x, k = 5)
  ) +
  facet_wrap(vars(estate_type)) +
  scale_x_reverse(limits = c(99, 35), breaks = seq(100, 40, -10)) +
  scale_y_continuous(labels = label_dollar()) +
  base_theme +
  labs(
    title = "How does an aging HDB lease affect its value?",
    subtitle = "Price per sqm vs. Remaining lease (years), stratified by Estate Type",
    x = "Remaining Lease (Years left)",
    y = "Price per Sqm ($)",
    caption = shared_caption
  )

## 5.4 Town premium ----
plot_4 <- resale_flat_prices_clean %>%
  mutate(town = fct_reorder(town, price_per_sqm, .fun = median)) %>%
  ggplot(aes(x = town, y = price_per_sqm, fill = estate_type)) +
  geom_violin(trim = TRUE, alpha = 0.6, color = "gray40", linewidth = 0.3) +
  geom_boxplot(
    width = 0.15,
    outlier.shape = NA,
    alpha = 0.7,
    color = "black",
    lwd = 0.4
  ) +
  stat_summary(
    fun = median,
    geom = "point",
    shape = 21,
    size = 1.2,
    fill = "white",
    color = "black"
  ) +
  coord_flip() +
  scale_y_continuous(labels = label_dollar()) +
  scale_fill_manual(
    values = c("Mature Estate" = "#2c3e50", "Non-mature Estate" = "#18bc9c")
  ) +
  base_theme +
  labs(
    title = "HDB Town Premium Distribution Profile",
    subtitle = "Price density by ascending median unit value",
    x = NULL,
    y = "Price per Sqm ($)",
    fill = NULL,
    caption = shared_caption
  )

## 5.5 Floor height premium ----
plot_5 <- resale_flat_prices_clean %>%
  filter(flat_type %in% c("3 ROOM", "4 ROOM", "5 ROOM")) %>%
  group_by(estate_type, flat_type, floor_mid) %>%
  summarise(
    median_price_sqm = median(price_per_sqm, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = floor_mid, y = median_price_sqm, color = flat_type)) +
  geom_point(alpha = 0.6, size = 1.5) +
  geom_line(linewidth = 0.8) +
  facet_wrap(vars(estate_type)) +
  scale_y_continuous(labels = label_dollar()) +
  scale_color_viridis_d(option = "viridis", end = 0.8) +
  base_theme +
  labs(
    title = "The Floor Height Premium Profile",
    subtitle = "Median unit pricing evaluated across vertical storey ranges",
    x = "Storey Level (Range Midpoint)",
    y = "Median Price per Sqm ($)",
    color = "Flat Type",
    caption = shared_caption
  )

## 5.6 Geospatial Map ----
plot_6 <- ggplot(sg_map_clean) +
  geom_sf(aes(fill = median_price_sqm), color = "white", linewidth = 0.2) +
  scale_fill_viridis_c(
    option = "magma",
    direction = -1,
    labels = label_dollar(),
    na.value = "gray95"
  ) +
  theme_void(base_size = 11) +
  theme(
    plot.title = element_text(hjust = 0.1),
    plot.subtitle = element_text(hjust = 0.1),
    plot.caption = element_text(hjust = 0, color = "gray40"),
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm"),
    plot.background = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = "Geospatial Heatmap of HDB Resale Value",
    subtitle = "Median price per sqm by planning area (Blank areas because HDB Town names do not match URA Planning Area names)",
    fill = "Median Price/Sqm",
    caption = shared_caption
  )

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
  "lease-decay" = plot_3,
  "town-premium" = plot_4,
  "floor-premium" = plot_5,
  "geospatial-map" = plot_6
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
