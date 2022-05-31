# rounds individuals so that they remain Integers
# uses a random number to decide what to do with fractions of individuals
function round_new_individuals(x::T, p::Real)::T where T<:Integer
    value = x * p
    new = floor(T, value)
    if value - new > rand()
        return new + 1
    end
    return new
end

function round_vaccination_distribution(s::T, r::T, v::T,
                                        n_doses::Integer, total_to_vaccinate::T)::Tuple{T, T, T} where T<:Integer
    vaccination_chance = n_doses / total_to_vaccinate
    new_s = floor(T, s * vaccination_chance)
    new_r = floor(T, r * vaccination_chance)
    new_v = floor(T, v * vaccination_chance)
    vaccines_left = n_doses - new_s - new_r - new_v
    # distribute doses equally
    while vaccines_left > 0
        if (s * vaccination_chance - new_s) > rand()
            new_s += 1
            vaccines_left -= 1
        elseif ((r+s) * vaccination_chance - (new_s + new_r)) > rand()
            new_r += 1
            vaccines_left -=1
        else
            new_v += 1
            vaccines_left -=1
        end
    end
    # prevent from giving more doses than there are available
    while vaccines_left < 0
        if new_s > 0
            new_s -= 1
        elseif new_r > 0
            new_r -= 1
        else
            new_v -= 1
        end
        vaccines_left -= 1
    end
    # prevent form vaccinating not existing individuals
    # just moves additional ones S -> R -> V -> S
    # the distribution isn't correct but this situation will probably never happen
    while true
        new_s > s && (new_s -= 1; new_r += 1; continue)
        new_r > r && (new_r -= 1; new_v += 1; continue)
        new_v > v && (new_v -= 1; new_s += 1; continue)
        break
    end
    return new_s, new_r, new_v
end
