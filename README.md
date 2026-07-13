# HDB Resale Flat Prices

Created: 2026-07-03

Updated: 2026-07-13

Data sources:
  - [`Open source data from public agencies in Singapore (data.gov.sg)`](https://data.gov.sg/)
  
  - [`HDB Flat Portal`](https://homes.hdb.gov.sg/home/landing)

This project was initially part of the `singapore-data` repository, but I have since created a standalone repository for it because of the interest and attention on this topic.

I started this project to answer some questions I had about the HDB Resale Flat market.
  - Are prices of resale flats skyrocketing everywhere? Or just in the highly sought after locations?
  - How much is the town premium between a Mature Estate compared to a Non-mature estate?
  - How much more are buyers willing to pay for a flat on a higher floor?
  - How much effect does lease decay have on the resale price?

For the questions, I had my own pre-conceived ideas on some of the answers, but I wanted to see what the data will reveal, and also learn some insights that I did not anticipate.

## Quick Navigation

- [Summary of Million-dollar Resale Flat Transactions](#summary-of-million-dollar-transactions)
- [Million-dollar Flats Distributed by HDB Towns](#million-dollar-flats-distribution-by-hdb-towns)
- [Per Square-meter Price Trends Across Selected HDB Towns](#per-square-meter-price-trends-across-selected-hdb-towns)
- [Effect of Lease Decay on Resale Flat Prices](#effect-of-lease-decay-on-per-square-meter-prices)
- [Town Premium (Downtown Core areas vs fringe areas)](#town-premium)
- [Floor Height Premium (Flats on higher floors vs flats on lower floors)](#floor-premium)
- [Geo-spatial Heatmap of Resale Flat Prices](#geo-spatial-heatmap-of-per-square-meter-prices)

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
People are willing to pay a substantial premium for a flat in the Downtown Core/Central Area. Highly coveted areas like the Central Area, Queenstown and Bukit Merah show a long tail, indicating an open-ended premium ceiling. Non-mature towns like Choa Chu Kang and Jurong West tend to have a more tightly clustered plot indicating less variance in prices.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-town-premium.png)

## Floor Premium
Buyers are usually willing to pay more for a flat at a higher floor. However, the data shows that the floor premium is highly dependent on location, rather than a fixed premium across Singapore. Buyers are much more willing to pay for a flat at a higher floor especially if it's in a Mature Estate.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-floor-premium.png)

## Geo-spatial Heatmap of per Square-meter Prices
The gray gaps in the map occur because HDB uses general town names (Bishan, Kallang/Whampoa, Marine Parade etc), while the URA Master Plan divides the island into precise Planning Areas (Downtown Core, Rochor, Outram, Kallang etc). Some of these areas do not match exactly, resulting in the gray blank areas. No surprise that the Downtown Core and Central areas have the highest per square-meter prices. Among the towns that are furthest from the city center, Punggol is an outlier, and has some of the most expensive per square meter prices.
![](https://github.com/weiyuet/hdb-resale-flat-prices/blob/main/figures/hdb-resale-flat-prices-geospatial-map.png)

End