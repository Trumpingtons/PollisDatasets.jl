"""
    PollisDatasets

A curated set of small, well-known datasets for examples and teaching, each returned as a
Tables.jl column table (a `NamedTuple` of vectors). Sources, licences and column
descriptions are in `datasets.toml`.

```julia
using PollisDatasets
datasets()                  # list the catalogue
d = dataset("penguins");    # load one
datasetinfo("penguins")     # source, licence and columns
```
"""
module PollisDatasets

using CSV
using TOML
using Tables

export dataset, datasets, datasetinfo

const ROOT = dirname(@__DIR__)
const CATALOGUE = joinpath(ROOT, "datasets.toml")

"""Catalogue entry of one dataset, as listed in `datasets.toml`."""
struct DatasetInfo
	id::String
	title::String
	domain::String
	description::String
	rows::Int
	source::String
	url::String
	licence::String
	status::String
	columns::Vector{Pair{String, String}}
end

function DatasetInfo(entry::Dict{String, Any})
	columns = [column["name"] => column["description"] for column in entry["columns"]]
	return DatasetInfo(entry["id"], entry["title"], entry["domain"], entry["description"], entry["rows"],
		entry["source"], entry["url"], entry["licence"], entry["status"], columns)
end

const _catalogue = Ref{Vector{DatasetInfo}}()

function catalogue()
	if !isassigned(_catalogue)
		_catalogue[] = DatasetInfo.(TOML.parsefile(CATALOGUE)["datasets"])
	end
	return _catalogue[]
end

function lookup(id::AbstractString)
	index = findfirst(info -> info.id == id, catalogue())
	if index === nothing
		throw(ArgumentError("unknown dataset \"$id\"; available: $(join((info.id for info in catalogue()), ", "))"))
	end
	return catalogue()[index]
end

"""
    datasets()

List the catalogue: one row per dataset with its `id`, `title`, `domain` and number of `rows`.
The result is a Tables.jl row table (a vector of `NamedTuple`s).
"""
datasets() = [(id = info.id, title = info.title, domain = info.domain, rows = info.rows) for info in catalogue()]

"""
    dataset(id)

Load the dataset `id` (see `datasets()`) as a Tables.jl column table: a `NamedTuple` of
vectors, so `d.mpg` is a column. Missing values are `missing`.
"""
function dataset(id::AbstractString)
	info = lookup(id)
	return Tables.columntable(CSV.File(joinpath(ROOT, "data", info.id * ".csv"); pool = false, stringtype = String))
end

"""
    datasetinfo(id)

Description, source to cite, licence and column descriptions of the dataset `id`.
"""
datasetinfo(id::AbstractString) = lookup(id)

function Base.show(io::IO, ::MIME"text/plain", info::DatasetInfo)
	println(io, info.title, " (\"", info.id, "\", ", info.rows, " rows)")
	println(io, "  ", info.description)
	println(io, "  Source:  ", info.source)
	println(io, "  Licence: ", info.licence)
	println(io, "  Columns:")
	width = maximum(length(first(column)) for column in info.columns)
	for (name, description) in info.columns
		println(io, "    ", rpad(name, width), "  ", description)
	end
end

end
