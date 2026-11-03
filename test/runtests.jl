using PollisDatasets
using Test

@testset "PollisDatasets" begin
	for row in datasets()
		@testset "$(row.id)" begin
			d = dataset(row.id)
			info = datasetinfo(row.id)
			@test (length(first(d)), collect(String.(keys(d)))) == (info.rows, first.(info.columns))
		end
	end
	@test_throws ArgumentError dataset("nope")
end

@testset "sample files" begin
	for name in ("sample.pdf", "sample.tex", "table1.csv", "figure.png")
		@test isfile(samplefile(name))
	end
	@test_throws ArgumentError samplefile("nope.pdf")
end
