# HDB Resale Flat Prices

Created: 2026-07-03

Updated: 2026-07-12

Data sources:
  - [`Open source data from public agencies in Singapore (data.gov.sg)`](https://data.gov.sg/)
  
  - [`HDB Flat Portal`](https://homes.hdb.gov.sg/home/landing)

This project was initially part of the `singapore-data` repository, but I have since created a standalone repository for it because of the interest and attention on this topic.

## Summary of million-dollar transactions
Toa Payoh has the most number of million-dollar transactions.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flats-prices-summary-table.png)

## Million-dollar flats distribution by HDB towns
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-town-absolute.png)

## Per square-meter price trends across selected HDB towns
A 5-room flat will be more expensive than a 3-room flat. To accurately see if resale prices are skyrocketing everywhere, I use price per square-meter. Comparing price per square-meter gives a fairer comparison between flat types and locations. 
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-multivariate-sqm.png)

## Effect of lease decay on per square-meter prices
Resale prices in Mature Estates hold up better than in Non-mature Estates. As expected, as the lease runs down, the resale prices fall. However, between 60 and 50 years lease remaining, the prices rise back up a little, breaking the trend, before really collapsing in the last 3 decades of the lease.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-lease_decay.png)

## Geo-spatial heatmap of per square-meter prices
The gray gaps in the map occur because HDB uses general town names (Central Area, Kallang/Whampoa, Marine Parade etc), while the URA Master Plan divides the island into precise Planning Areas (Downtown Core, Rochor, Outram, Kallang etc). Some of these areas do not match exactly, resulting in the gray blank areas. No surprise that the Downtown Core and Central areas have the highest per square-meter prices. Among the towns that are furthest from the city center, Punggol has some of the most expensive per square meter prices.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-geospatial_map.png)

End