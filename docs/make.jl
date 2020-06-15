using Documenter, AES

makedocs(
    modules = [AES],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "bernhard",
    sitename = "AES.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/kafisatz/AES.jl.git",
    push_preview = true
)
