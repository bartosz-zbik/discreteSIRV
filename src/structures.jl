# Enum for epidemic state
@enum State  Susceptible=1 Infectious=2 Recovered=3 Vaccinated=4

# structure for disease parameters.
struct Disease
    s2i::Float64
    i2r::Float64
    r2s::Float64
    v2s::Float64
end

# population assuming that the size is const in time
# the simulation will do operations on this object
struct Population{T<:Real} <: AbstractArray{T, 2}
    p::Matrix{T}  # contains the population structure (main part) leave one additional row for new_I
    disease::Disease  # disease parameters are stored here
    popsize::T  # number of individuals
end
# constructors
function Population(N::T, d::Disease) where T<:Real
    p = Population(zeros(T, 5, 1), d, N)
    p.p[1,1] = N
    return p
end
function Population(N::T, d::Disease, max_time::Integer) where T<:Real
    max_time > 0 || error("max_time for a Population should be > 0")
    p = Population(zeros(T, 5, max_time+1), d, N)
    p.p[1,1] = N
    return p
end

# Array interface, just for fun
Base.getindex(p::Population, i::Int) = Base.getindex(p.p, i)
Base.getindex(p::Population, i::Vararg{Int, 2}) = Base.getindex(p.p, i)
Base.getindex(p::Population, I...) = Base.getindex(p.p, I...)

Base.setindex!(p::Population, v, i::Int)	= Base.setindex!(p.p, v, i)
Base.setindex!(p::Population, v, i::Vararg{Int, 2}) = Base.setindex!(p.p, v, i)
Base.setindex!(p::Population, X, I...) = Base.setindex!(p.p, X, I...)

Base.size(p::Population) = Base.size(p.p)
Base.firstindex(p::Population) = Base.firstindex(p.p)
Base.lastindex(p::Population) = Base.lastindex(p.p)

# support for using epidemic_states as indexes, also some fun
Base.getindex(p::Population, s::State, i::Int) = p.p[Int(s), i]
Base.getindex(p::Population, s::State) = p.p[Int32(s), :]
