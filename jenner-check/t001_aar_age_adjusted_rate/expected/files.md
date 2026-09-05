These URLs point to artifacts from a specific Jenner run and expire when that run is reaped from the server. Re-running the bundle (`./run_jenner.sh <bundle>`) regenerates them against a fresh run.

## Files

| name | content_type | size_bytes | url |
|------|--------------|-----------:|-----|
| Count_sum | application/octet-stream | 385 | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/files/Count_sum?token=0e9d681a618241d28b478e6700c9ef08 |
| population_sum | application/octet-stream | 424 | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/files/population_sum?token=0e9d681a618241d28b478e6700c9ef08 |

## Datasets

| name | rows | columns | preview_url |
|------|-----:|---------|-------------|
| aar | 4 | countyfips, statefips, year, AAR | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/aar?token=0e9d681a618241d28b478e6700c9ef08 |
| aar_nat | 20 | countyfips, statefips, age, year, n_count, n_pop, Yr2000STDWT, AgeBandId | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/aar_nat?token=0e9d681a618241d28b478e6700c9ef08 |
| count_data | 20 | countyfips, statefips, age, year, n_events | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/count_data?token=0e9d681a618241d28b478e6700c9ef08 |
| count_sum | 20 | countyfips, statefips, age, year, n_count | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/count_sum?token=0e9d681a618241d28b478e6700c9ef08 |
| full | 20 | countyfips, statefips, age, year, n_count, n_pop | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/full?token=0e9d681a618241d28b478e6700c9ef08 |
| population_data | 20 | countyfips, statefips, age, year, population_amt | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/population_data?token=0e9d681a618241d28b478e6700c9ef08 |
| population_sum | 20 | countyfips, statefips, age, year, n_pop | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/population_sum?token=0e9d681a618241d28b478e6700c9ef08 |
| rate | 20 | countyfips, statefips, age, year, n_count, n_pop, Yr2000STDWT, AgeBandId, rate, wrate | https://api.jenneranalytics.com/v1/run/r_019ed5a2502873539f0462985bf4b908/datasets/rate?token=0e9d681a618241d28b478e6700c9ef08 |

