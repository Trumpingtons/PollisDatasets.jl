# Rebuild data/*.csv from the original sources listed in datasets.toml.
# Run from the package root: Rscript scripts/build_data.R
# Needs the R packages AER, survival, lme4, did and haven; everything else is downloaded.
# Missing values are written as empty fields.

suppressPackageStartupMessages({
	library(AER)
	library(survival)
	library(lme4)
	library(did)
})

options(timeout = 600)
out <- "data"
dir.create(out, showWarnings = FALSE)
tmp <- tempfile("pollis-datasets")
dir.create(tmp)
rdatasets <- "https://vincentarelbundock.github.io/Rdatasets/csv"

fetch <- function(url, name = basename(url)) {
	path <- file.path(tmp, name)
	download.file(url, path, quiet = TRUE, mode = "wb")
	path
}

# Rdatasets stores Wooldridge's single-precision values as doubles (3.3540000915527344); restore them
tidy_floats <- function(d) {
	for (n in names(d)) {
		if (is.double(d[[n]])) {
			d[[n]] <- signif(d[[n]], 7)
		}
	}
	d
}

save <- function(id, d) {
	rownames(d) <- NULL
	# Julia-friendly names: ph.ecog -> ph_ecog, midparentHeight -> midparent_height, IQ -> iq
	names(d) <- tolower(gsub("([a-z])([A-Z])", "\\1_\\2", gsub(".", "_", names(d), fixed = TRUE)))
	write.csv(d, file.path(out, paste0(id, ".csv")), row.names = FALSE, na = "")
	cat(sprintf("%-14s %5d x %-3d\n", id, nrow(d), ncol(d)))
}

# ---------- Regression ----------

save("mtcars", cbind(model = rownames(mtcars), mtcars))
save("anscombe", anscombe)
# The Datasaurus Dozen as the datasauRus package ships it, pinned to its commit
datasaurus <- read.delim(fetch("https://raw.githubusercontent.com/jumpingrivers/datasauRus/269706b98d171fe52258e4a7288e26e1b37512f5/inst/extdata/DatasaurusDozen-Long.tsv"))
save("datasaurus", datasaurus)
galton <- read.csv(fetch(paste0(rdatasets, "/HistData/GaltonFamilies.csv")), colClasses = c(family = "character"))
save("galton", galton[, -1])

# ---------- Econometrics ----------

data("Grunfeld", package = "AER")
save("grunfeld", Grunfeld[, c("firm", "year", "invest", "value", "capital")])
produc <- read.csv(fetch(paste0(rdatasets, "/plm/Produc.csv")))[, -1]
produc$state <- tools::toTitleCase(tolower(produc$state))
save("produc", produc)
save("mroz", tidy_floats(read.csv(fetch(paste0(rdatasets, "/wooldridge/mroz.csv")))[, -1]))
save("card", tidy_floats(read.csv(fetch(paste0(rdatasets, "/wooldridge/card.csv")))[, -1]))

nsw <- c("treat", "age", "educ", "black", "hisp", "married", "nodegree", "re74", "re75", "re78")
treated <- read.table(fetch("https://users.nber.org/~rdehejia/data/nswre74_treated.txt"), col.names = nsw)
control <- read.table(fetch("https://users.nber.org/~rdehejia/data/nswre74_control.txt"), col.names = nsw)
save("lalonde", rbind(treated, control))
for (k in 1:3) {
	save(paste0("cps", k), read.table(fetch(sprintf("https://users.nber.org/~rdehejia/data/cps%s_controls.txt", if (k == 1) "" else k)), col.names = nsw))
}
save("petersen", read.table(fetch("https://www.kellogg.northwestern.edu/faculty/petersen/htm/papers/se/test_data.txt"), col.names = c("firmid", "year", "x", "y")))
data("mpdta", package = "did")
save("mpdta", mpdta)
# Goodman-Bacon's (2021) example as Thomas Goldring's ddtiming (MIT) ships it: Stevenson and Wolfers' female suicide rate
# in 49 states, 1964-1996, and the indicator of no-fault (unilateral) divorce. The rate is a Stata single-precision float:
# 7 significant digits
divorce <- haven::read_dta(fetch("https://raw.githubusercontent.com/tgoldring/ddtiming/0f97729c1af4503bf0683c7f25df29cc1f562d3a/nofault_divorce.dta"))
save("divorce", data.frame(state = as.character(haven::as_factor(divorce$state)), fips = as.integer(divorce$state),
	year = as.integer(divorce$year), asmrs = signif(divorce$asmrs, 7), treat = as.integer(divorce$treat)))

# ---------- Time series classification ----------

# UCR archive datasets from timeseriesclassification.com: one row per series, its split and class, then its values
ucr <- function(id, name) {
	zip <- fetch(sprintf("https://timeseriesclassification.com/aeon-toolkit/%s.zip", name))
	unzip(zip, exdir = file.path(tmp, name))
	parts <- lapply(c("TRAIN", "TEST"), function(split) {
		d <- read.table(file.path(tmp, name, sprintf("%s_%s.txt", name, split)))
		data.frame(split = tolower(split), label = as.integer(d[[1]]), signif(as.matrix(d[, -1]), 7))
	})
	d <- do.call(rbind, parts)
	names(d) <- c("split", "label", paste0("t", seq_len(ncol(d) - 2)))
	save(id, d)
}
ucr("ecg200", "ECG200")
ucr("earthquakes", "Earthquakes")
ucr("twoleadecg", "TwoLeadECG")

# ---------- Counts and GLM ----------

vonbort <- read.csv(fetch(paste0(rdatasets, "/vcd/VonBort.csv")))
save("horsekicks", vonbort[, c("year", "corps", "deaths")])
save("insectsprays", InsectSprays)
biochemists <- read.csv(fetch(paste0(rdatasets, "/pscl/bioChemists.csv")))[, -1]
save("biochemists", tidy_floats(biochemists))
data("ships", package = "MASS")
save("ships", ships)
shuttle <- read.csv(fetch(paste0(rdatasets, "/vcd/SpaceShuttle.csv")))[, -1]
shuttle <- shuttle[!is.na(shuttle$nFailures), ]  # flight 4: boosters lost at sea, O-rings never inspected
names(shuttle)[names(shuttle) == "FlightNumber"] <- "flight"
save("challenger", shuttle[, c("flight", "Temperature", "Pressure", "nFailures")])

# ---------- Classification ----------

save("penguins", read.csv(fetch("https://raw.githubusercontent.com/allisonhorst/palmerpenguins/main/inst/extdata/penguins.csv"), na.strings = "NA"))

iris_uci <- read.csv(fetch("https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"), header = FALSE,
	col.names = c("sepal_length", "sepal_width", "petal_length", "petal_width", "species"))
iris_uci <- iris_uci[iris_uci$species != "", ]
# The two errors documented in UCI's iris.names, corrected to Fisher's (1936) values
iris_uci[35, 1:4] <- c(4.9, 3.1, 1.5, 0.2)
iris_uci[38, 1:4] <- c(4.9, 3.6, 1.4, 0.1)
iris_uci$species <- sub("^Iris-", "", iris_uci$species)
save("iris", iris_uci)

titanic <- read.csv(fetch("https://hbiostat.org/data/repo/titanic3.csv"), na.strings = "")
names(titanic)[names(titanic) == "home.dest"] <- "home_dest"
save("titanic", titanic)

wine <- read.csv(unz(fetch("https://archive.ics.uci.edu/static/public/109/wine.zip"), "wine.data"), header = FALSE,
	col.names = c("cultivar", "alcohol", "malic_acid", "ash", "alcalinity_of_ash", "magnesium", "total_phenols", "flavanoids",
		"nonflavanoid_phenols", "proanthocyanins", "color_intensity", "hue", "od280_od315", "proline"))
save("wine", wine)

features <- c("radius", "texture", "perimeter", "area", "smoothness", "compactness", "concavity", "concave_points", "symmetry", "fractal_dimension")
wdbc <- read.csv(unz(fetch("https://archive.ics.uci.edu/static/public/17/breast+cancer+wisconsin+diagnostic.zip", "wdbc.zip"), "wdbc.data"), header = FALSE,
	col.names = c("id", "diagnosis", paste0(features, "_mean"), paste0(features, "_se"), paste0(features, "_worst")))
save("breastcancer", wdbc)

# ---------- Time series ----------

save("airpassengers", data.frame(year = floor(time(AirPassengers)), month = cycle(AirPassengers), passengers = as.numeric(AirPassengers)))
save("nile", data.frame(year = as.integer(time(Nile)), flow = as.numeric(Nile)))

co2 <- read.table(fetch("https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_mm_mlo.txt"), comment.char = "#",
	col.names = c("year", "month", "decimal_date", "average", "deseasonalized", "ndays", "sdev", "unc"))
co2$ndays[co2$ndays < 0] <- NA
co2$sdev[co2$sdev < 0] <- NA
co2$unc[co2$unc < 0] <- NA
save("co2", co2)

# ---------- Dynamical systems ----------

lynxhare <- read.csv(fetch("https://raw.githubusercontent.com/stan-dev/example-models/master/knitr/lotka-volterra/hudson-bay-lynx-hare.csv"), comment.char = "#", strip.white = TRUE)
names(lynxhare) <- c("year", "lynx", "hare")
save("lynxhare", lynxhare)

# ---------- Epidemiology ----------

# Italy in JHU CSSE's global time series, from 27 February 2020 (the first day with 500 cases or more) to 31 May 2020
jhu <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series"
italy <- function(kind) {
	d <- read.csv(fetch(paste0(jhu, "/time_series_covid19_", kind, "_global.csv")), check.names = FALSE)
	row <- d[d[["Country/Region"]] == "Italy" & d[["Province/State"]] == "", ]
	setNames(as.integer(unlist(row[, -(1:4)])), as.character(as.Date(names(row)[-(1:4)], "%m/%d/%y")))
}
days <- as.character(seq(as.Date("2020-02-27"), as.Date("2020-05-31"), by = "day"))
save("italycovid", data.frame(date = days, cases = italy("confirmed")[days], recovered = italy("recovered")[days], dead = italy("deaths")[days]))

# ---------- Survival ----------

save("lung", survival::lung)
save("veteran", survival::veteran)

# ---------- Bayesian and multilevel ----------

save("eightschools", data.frame(school = LETTERS[1:8], effect = c(28, 8, -3, 7, -1, 1, 18, 12), se = c(15, 10, 16, 11, 9, 11, 10, 18)))

# Gelman's Minnesota subset, as built in ARM's radon_setup.R (columbia.edu blocks scripted downloads; the CMU copy is the same file)
arm <- "https://stat.cmu.edu/~brian/valerie/617-2022/617-2021/0%20-%20books/Gelman-Hill/ARM_Data/radon"
srrs2 <- read.csv(fetch(paste0(arm, "/srrs2.dat")), strip.white = TRUE)
cty <- read.csv(fetch(paste0(arm, "/cty.dat")))
mn <- srrs2[srrs2$state == "MN", ]
uppm <- cty$Uppm[match(mn$stfips * 1000 + mn$cntyfips, cty$stfips * 1000 + cty$ctfips)]
save("radon", data.frame(county = trimws(mn$county), floor = mn$floor, activity = mn$activity,
	log_radon = log(ifelse(mn$activity == 0, 0.1, mn$activity)), log_uranium = log(uppm)))
save("sleepstudy", lme4::sleepstudy[, c("Subject", "Days", "Reaction")])

# ---------- Density ----------

save("faithful", faithful)
