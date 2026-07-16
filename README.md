# HDB Resale Flat Prices

Created: 2026-07-03

Updated: 2026-07-17

Data sources:
  - [`HDB resale flat price data from (data.gov.sg)`](https://data.gov.sg/datasets?topics=housing&resultId=d_8b84c4ee58e3cfc0ece0d773c8ca6abc)
  
  - [`HDB Flat Portal`](https://homes.hdb.gov.sg/home/landing)

This project was initially part of the `singapore-data` repository, but I have since created a standalone repository for it because of the interest and attention on this topic.

## Quick Navigation

- [Background & Project Motivation](#background--project-motivation)
- [Data Preview](#data-preview)
  - [Raw Data](#raw-data)
  - [Prepped & Clean Data](#prepped--clean-data)
- [Summary of Million-dollar Resale Flat Transactions](#summary-of-million-dollar-transactions)
- [Million-dollar Flats Distributed by HDB Towns](#million-dollar-flats-distribution-by-hdb-towns)
- [Per Square-meter Price Trends Across Selected HDB Towns](#per-square-meter-price-trends-across-selected-hdb-towns)
- [Effect of Lease Decay on Resale Flat Prices](#effect-of-lease-decay-on-per-square-meter-prices)
- [Town Premium (Downtown Core areas vs fringe areas)](#town-premium)
- [Floor Height Premium (Flats on higher floors vs flats on lower floors)](#floor-premium)
- [Geo-spatial Heatmap of Resale Flat Prices](#geo-spatial-heatmap-of-per-square-meter-prices)

## Background & Project Motivation
The HDB resale flat market has been running hot with ever increasing numbers of resale flats changing hands at a cost of over SDG1 Million.

I started this project to answer some questions I had about the HDB Resale Flat market.
  - Are prices of resale flats skyrocketing everywhere? Or just in the highly sought after locations?
  - How much is the town premium between a Mature Estate compared to a Non-mature estate?
  - How much more are buyers willing to pay for a flat on a higher floor?
  - How much effect does lease decay have on the resale price?

For the questions, because of my own lived experience, I have my own pre-conceived ideas on some of the answers, but I wanted to see what the data will reveal, and also learn some insights that I did not anticipate.

## Data Preview
### Raw Data
This is how the data format looks like as provided by the HDB. The raw dataset does not meet "tidy" data principles (Wickham, 2014), and is at most, semi-structured.

`resale_flat_prices_raw %>% tail(10) %>% knitr::kable(format = "markdown")`

|month   |town   |flat_type        |block |street_name  |storey_range | floor_area_sqm|flat_model       | lease_commence_date|remaining_lease    | resale_price|
|:-------|:------|:----------------|:-----|:------------|:------------|--------------:|:----------------|-------------------:|:------------------|------------:|
|2026-04 |YISHUN |EXECUTIVE        |614   |YISHUN ST 61 |04 TO 06     |            142|Apartment        |                1987|60 years 01 month  |       820000|
|2026-04 |YISHUN |EXECUTIVE        |606   |YISHUN ST 61 |07 TO 09     |            142|Apartment        |                1987|60 years 08 months |       830000|
|2026-06 |YISHUN |EXECUTIVE        |746   |YISHUN ST 72 |04 TO 06     |            162|Adjoined flat    |                1984|57 years 07 months |      1128000|
|2026-03 |YISHUN |EXECUTIVE        |877   |YISHUN ST 81 |10 TO 12     |            142|Apartment        |                1987|60 years 10 months |       980000|
|2026-03 |YISHUN |EXECUTIVE        |836   |YISHUN ST 81 |10 TO 12     |            146|Maisonette       |                1988|61 years           |       995000|
|2026-03 |YISHUN |EXECUTIVE        |877   |YISHUN ST 81 |07 TO 09     |            142|Apartment        |                1987|60 years 10 months |       980000|
|2026-04 |YISHUN |EXECUTIVE        |827   |YISHUN ST 81 |01 TO 03     |            145|Maisonette       |                1987|60 years 06 months |       960000|
|2026-05 |YISHUN |EXECUTIVE        |828   |YISHUN ST 81 |07 TO 09     |            145|Apartment        |                1988|60 years 09 months |      1068888|
|2026-05 |YISHUN |MULTI-GENERATION |666   |YISHUN AVE 4 |04 TO 06     |            164|Multi Generation |                1987|60 years 08 months |      1120000|
|2026-07 |YISHUN |MULTI-GENERATION |605   |YISHUN ST 61 |07 TO 09     |            163|Multi Generation |                1988|60 years 07 months |      1190000|

### Prepped & Clean Data
This is how it looks after some tidying up and prepping. Dates, lease values and storey numbers are given their correct data type, and other needed data like price-per-square-meter are calculated.

`resale_flat_prices_clean %>% tail(10) %>% knitr::kable(format = "markdown")`

|month    |town   |flat_type        |block |street_name  |storey_range | floor_area_sqm|flat_model       | lease_commence_date|remaining_lease    | resale_price| price_per_sqm|estate_type       | remaining_lease_numeric| flat_age|age_cohort                 | floor_mid|
|:--------|:------|:----------------|:-----|:------------|:------------|--------------:|:----------------|-------------------:|:------------------|------------:|-------------:|:-----------------|-----------------------:|--------:|:--------------------------|---------:|
|Apr 2026 |YISHUN |EXECUTIVE        |614   |YISHUN ST 61 |04 TO 06     |            142|Apartment        |                1987|60 years 01 month  |       820000|      5774.648|Non-mature Estate |                60.08333| 38.91667|Mid-Life (15-50 Years Old) |         5|
|Apr 2026 |YISHUN |EXECUTIVE        |606   |YISHUN ST 61 |07 TO 09     |            142|Apartment        |                1987|60 years 08 months |       830000|      5845.070|Non-mature Estate |                60.66667| 38.33333|Mid-Life (15-50 Years Old) |         8|
|Jun 2026 |YISHUN |EXECUTIVE        |746   |YISHUN ST 72 |04 TO 06     |            162|Adjoined flat    |                1984|57 years 07 months |      1128000|      6962.963|Non-mature Estate |                57.58333| 41.41667|Mid-Life (15-50 Years Old) |         5|
|Mar 2026 |YISHUN |EXECUTIVE        |877   |YISHUN ST 81 |10 TO 12     |            142|Apartment        |                1987|60 years 10 months |       980000|      6901.408|Non-mature Estate |                60.83333| 38.16667|Mid-Life (15-50 Years Old) |        11|
|Mar 2026 |YISHUN |EXECUTIVE        |836   |YISHUN ST 81 |10 TO 12     |            146|Maisonette       |                1988|61 years           |       995000|      6815.068|Non-mature Estate |                61.00000| 38.00000|Mid-Life (15-50 Years Old) |        11|
|Mar 2026 |YISHUN |EXECUTIVE        |877   |YISHUN ST 81 |07 TO 09     |            142|Apartment        |                1987|60 years 10 months |       980000|      6901.408|Non-mature Estate |                60.83333| 38.16667|Mid-Life (15-50 Years Old) |         8|
|Apr 2026 |YISHUN |EXECUTIVE        |827   |YISHUN ST 81 |01 TO 03     |            145|Maisonette       |                1987|60 years 06 months |       960000|      6620.690|Non-mature Estate |                60.50000| 38.50000|Mid-Life (15-50 Years Old) |         2|
|May 2026 |YISHUN |EXECUTIVE        |828   |YISHUN ST 81 |07 TO 09     |            145|Apartment        |                1988|60 years 09 months |      1068888|      7371.641|Non-mature Estate |                60.75000| 38.25000|Mid-Life (15-50 Years Old) |         8|
|May 2026 |YISHUN |MULTI-GENERATION |666   |YISHUN AVE 4 |04 TO 06     |            164|Multi Generation |                1987|60 years 08 months |      1120000|      6829.268|Non-mature Estate |                60.66667| 38.33333|Mid-Life (15-50 Years Old) |         5|
|Jul 2026 |YISHUN |MULTI-GENERATION |605   |YISHUN ST 61 |07 TO 09     |            163|Multi Generation |                1988|60 years 07 months |      1190000|      7300.613|Non-mature Estate |                60.58333| 38.41667|Mid-Life (15-50 Years Old) |         8|

## Summary of Million-dollar Transactions
Resale flat sellers in Toa Payoh have done well as it has the most number of million-dollar transactions.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flats-prices-summary-table.png)

## Million-dollar Flat Distribution Across HDB Towns
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-town-absolute.png)

## Per Square-meter Price Trends Across Selected Sample HDB Towns
A 5-room flat will be more expensive than a 3-room flat. To accurately see if resale prices are skyrocketing everywhere, I use price per square-meter. Comparing price per square-meter gives a fairer comparison between flat types and locations. A surprising find is the price per square-meter does not differ too much between 3, 4, and 5 room flats in Tampines and Jurong West.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-multivariate-sqm.png)

## Effect of Lease Decay on Resale Flat Prices
Generally, as the lease runs down, the resale prices fall, however resale prices in Mature Estates hold up far better than in Non-mature Estates over the whole lease of the HDB flat. Between 60 and 50 years lease remaining, the prices rise back up slightly, breaking the trend, before collapsing in the last 30 years of the lease. The collapse is much more dramatic in Non-mature Estates.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-lease-decay.png)

## Town Premium 
The location of a flat is important. People are willing to pay a substantial premium for a flat in the Downtown Core/Central Area. Highly coveted areas like the Central Area, Queenstown and Bukit Merah show a long tail, indicating an open-ended premium ceiling. Non-mature towns like Choa Chu Kang and Jurong West tend to have a more tightly clustered plot indicating less variance in prices.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-town-premium.png)

## Floor Premium
Buyers are usually willing to pay more for a flat at a higher floor. However, the data shows that the floor premium is highly dependent on location, rather than a fixed premium across Singapore. Buyers are much more willing to pay for a flat at a higher floor especially if it's in a Mature Estate.

The confounding factor for the floor premium is that older HDBs were mostly capped at 12 storeys, while the modern HDBs are routinely 25 storeys or higher. Currently the tallest HDB development is Pinnacle@Duxton at 50 storeys. It will soon be eclipsed by a [`60-storey BTO project at Pearl's Hill, Chinatown`.](https://www.straitstimes.com/singapore/politics/60-storey-bto-project-to-be-built-in-pearls-hill-hdb-to-construct-taller-flats-where-possible)
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-floor-premium.png)

## Geo-spatial Heatmap of per Square-meter Prices
The gray gaps in the map occur because HDB uses general town names (Bishan, Kallang/Whampoa, Marine Parade etc), while the URA Master Plan divides the island into precise Planning Areas (Downtown Core, Rochor, Outram, Kallang etc). Some of these areas do not match exactly, resulting in the gray blank areas. No surprise that the Downtown Core and Central areas have the highest per square-meter prices. Among the towns that are furthest from the city center, Punggol is an outlier, and has some of the most expensive per square meter prices.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-geospatial-map.png)

End