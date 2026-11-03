# PollisDatasets.jl

A curated set of 61 small, well-known datasets for examples and teaching, across regression, econometrics, classification, time series, survival, multilevel models and more. Each dataset loads as a [Tables.jl](https://github.com/JuliaData/Tables.jl) column table: a `NamedTuple` of vectors.

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
| Regression | mtcars, anscombe, datasaurus, galton, evals |
| Econometrics | grunfeld, produc, gasoline, mroz, card, lalonde, cps1, cps2, cps3, mpdta, divorce, petersen |
| Count data | horsekicks, insectsprays, biochemists, ships, challenger, assortive_mating |
| Classification | penguins, iris, titanic, wine, breastwisconsin, glass, pima, sonar, vowel, ionosphere, vehicle, germancredit, image, ecoli, votes, liver, letters, satimage, soybean |
| Time series | airpassengers, nile, co2, bg96, dgs10, lynxmackenzie, airquality, sp500, gamestop |
| Time series classification | ecg200, earthquakes, twoleadecg |
| Dynamical systems | lynxhare |
| Epidemiology | italycovid |
| Survival | lung, pbc, veteran |
| Bayesian / multilevel | eightschools, radon, sleepstudy |
| Density / mixtures | faithful |
| Market baskets | groceries |
| Text | pollis_guide |
| Simulated | sim_glmm, sim_clf |

## Sample files

`samplefile(name)` returns the path of a file that comes with the package, listed under `[[files]]` in `datasets.toml`:

| File | Contents |
|---|---|
| sample.pdf | Three pages: text and a figure, a regression table (Table 1), and notes; the cells of Table 1 are attached as table1.csv |
| sample.tex | The LaTeX source of sample.pdf, which reads Table 1 from table1.csv |
| table1.csv | The cells of Table 1, separated by semicolons |
| figure.png | The figure on page 1 |

```julia
pdf = samplefile("sample.pdf")
```

## Licence

The package code is MIT licensed. Each dataset keeps the terms of its original provider, recorded in `datasets.toml`; please cite the listed source when you use a dataset.
