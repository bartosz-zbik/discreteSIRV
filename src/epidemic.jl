
function advance_timeouts!(p::Population)
    n = size(p.p)[2] # check population time
    n == 1 && (return nothing) # return it population time is one
    # add second column to first
    p.p[1:4, 1] .+= p.p[1:4, 2]
    # copy all other columns
    for i in 2:n-1
        p.p[1:4, i] .= p.p[1:4, i+1]
    end
    # reset the last one
    p.p[1:4, n] .= 0
    return nothing
end

function simulate_step!(p::Population{T})::T where T<:Integer
    # infection_chance = (1 - (1-p)^I) 
    infection_chance = (1 - (1 - p.disease.s2i)^sum(p.p[2, :]))
    p.p[5, :] .= round_new_individuals.(p.p[1, :], infection_chance) # calculate new infections

    # Recovered --> Susceptible
    for i in 1:size(p.p)[2]
        difference = round_new_individuals(p.p[3, i], p.disease.r2s)
        p.p[3, i] -= difference # remove those who lost immunity
        p.p[1, i] += difference # add them to Susceptible state
    end
    # Vaccinated --> Susceptible
    for i in 1:size(p.p)[2]
        difference = round_new_individuals(p.p[4, i], p.disease.v2s)
        p.p[4, i] -= difference # remove those who lost immunity
        p.p[1, i] += difference # add them to Susceptible state
    end
    # Infectious --> Recovered
    for i in 1:size(p.p)[2]
        difference = round_new_individuals(p.p[2, i], p.disease.i2r)
        p.p[2, i] -= difference # remove those who lost immunity
        p.p[3, i] += difference # add them to Susceptible state
    end
    # Susceptible -> Infectious
    p.p[1, :] .-= p.p[5, :]
    p.p[2, :] .+= p.p[5, :]
    # move timer
    advance_timeouts!(p)
    return sum(p.p[5, :])
end

function simulate_step!(p::Population{T})::T where T<:AbstractFloat
    # infection_chance = (1 - (1-p)^I) 
    infection_chance = (1 - (1 - p.disease.s2i)^sum(p.p[2, :]))
    p.p[5, :] .= p.p[1, :] * infection_chance # calculate new infections

    # Recovered --> Susceptible
    for i in 1:size(p.p)[2]
        difference = p.p[3, i] * p.disease.r2s
        p.p[3, i] -= difference # remove those who lost immunity
        p.p[1, i] += difference # add them to Susceptible state
    end
    # Vaccinated --> Susceptible
    for i in 1:size(p.p)[2]
        difference = p.p[4, i] * p.disease.v2s
        p.p[4, i] -= difference # remove those who lost immunity
        p.p[1, i] += difference # add them to Susceptible state
    end
    # Infectious --> Recovered
    for i in 1:size(p.p)[2]
        difference = p.p[2, i] * p.disease.i2r
        p.p[2, i] -= difference # remove those who lost immunity
        p.p[3, i] += difference # add them to Susceptible state
    end
    # Susceptible -> Infectious
    p.p[1, :] .-= p.p[5, :]
    p.p[2, :] .+= p.p[5, :]
    # move timer
    advance_timeouts!(p)
    return sum(p.p[5, :])
end

function initial_infections!(p::Population, infections::Real)
    p.p[1, 1] - infections < 0 && error("Number of initial infections exceeds number of Susceptible")
    p.p[1, 1] -= infections
    p.p[2, 1] += infections
end

function get_population_stats(p::Population)
    return sum(p.p[1, :]), sum(p.p[2, :]), sum(p.p[3, :]), sum(p.p[4, :])
end
