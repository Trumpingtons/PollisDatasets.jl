# PollisDatasets.jl

A curated set of 30 small, well-known datasets for examples and teaching, across regression, econometrics, classification, time series, survival, multilevel models and more. Each dataset loads as a [Tables.jl](https://github.com/JuliaData/Tables.jl) column table: a `NamedTuple` of vectors.

```julia
using PollisDatasets
datasets()                  # list the catalogue
d = dataset("penguins");    # d.species, d.bill_length_mm, ...
datasetinfo("penguins")     # description, source to cite, licence and columns
```

Install with `import Pkg; Pkg.add(url = "https://github.com/Trumpingtons/PollisDatasets.jl")`.

## Datasets

`datasets.toml` is the catalogue: for every dataset, its description, source to cite, licence and a description of each column. Missing values load as `missing`.

| Domain | Datasets |
|---|---|
| Regression | mtcars, anscombe, galton |
| Econometrics | grunfeld, produc, mroz, card, lalonde |
| Count data | horsekicks, insectsprays, biochemists, ships, challenger |
| Classification | penguins, iris, titanic, wine, breastcancer |
| Time series | airpassengers, nile, co2, bg96, dgs10 |
| Dynamical systems | lynxhare |
| Survival | lung, veteran |
| Bayesian / multilevel | eightschools, radon, sleepstudy |
| Density / mixtures | faithful |

## Licence

The package code is MIT licensed. Each dataset keeps the terms of its original provider, recorded in `datasets.toml`; please cite the listed source when you use a dataset.
