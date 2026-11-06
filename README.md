# PollisDatasets.jl

A curated set of 69 small, well-known datasets for examples and teaching, across regression, econometrics, classification, time series, survival, multilevel models and more. Each dataset loads as a [Tables.jl](https://github.com/JuliaData/Tables.jl) column table: a `NamedTuple` of vectors.

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
| Econometrics | mroz, card |
| Panel econometrics | grunfeld, produc, gasoline, petersen |
| Causal inference | lalonde, cps1, cps2, cps3, mpdta, divorce |
| Count data | horsekicks, insectsprays, biochemists, ships, challenger, assortive_mating |
| Classification | penguins, iris, titanic, wine, breastwisconsin, glass, pima, sonar, vowel, ionosphere, vehicle, germancredit, image, ecoli, votes, liver, letters, satimage, soybean |
| Time series | airpassengers, nile, co2, bg96, dgs10, lynxmackenzie, airquality, sp500, gamestop, gnp82, gnpc96 |
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
| sample.pdf | Three pages in Latin, from Caesar's De Bello Gallico: text, a figure and a SAMPLE stamp, a regression table (Table 1) and notes, then notes in English on Caesar and a timeline of Rome in his lifetime (Table 2) on a page of their own; the cells of Table 1 are attached as table1.csv |
| sample.tex | The LaTeX source of sample.pdf, which reads Table 1 from table1.csv |
| table1.csv | The cells of Table 1, separated by semicolons |
| caesar.jpg | The figure on page 1, an engraving of Julius Caesar by Jan Caspar Philips (1745), from the Rijksmuseum (CC0) |

```julia
pdf = samplefile("sample.pdf")
```

## Vignette

[PollisDatasets.jl: the datasets of the examples](vignette/PollisDatasets.pdf)

## Licence

The package code is MIT licensed. Each dataset keeps the terms of its original provider, recorded in `datasets.toml`; please cite the listed source when you use a dataset.

The sample PDF, its LaTeX source and the cells of its Table 1 (`sample.pdf`, `sample.tex` and `table1.csv`) are © 2026 Pollis Team, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Caesar's Latin text and the engraving of Julius Caesar (`caesar.jpg`, CC0 from the Rijksmuseum) are in the public domain.
