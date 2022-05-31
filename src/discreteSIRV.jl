module discreteSIRV

export Population, Disease, get_population_stats,
    vaccinate!, simulate_step!, initial_infections!

include("structures.jl")
include("basic_functions.jl")
include("epidemic.jl")
include("vaccination.jl")

end # module
