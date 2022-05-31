# timeout argument is after how many iterations an individual may be vaccinated again
# timeout equal to 1 means that it may be vaccinated the next iteration

# in the implementation it is important to update vaccinated after reducing other states counts 

function vaccinate!(p::Population{T}, n_doses::Real, timeout::Integer = 0)::T where T<:AbstractFloat
    n_doses < 0 && error("vaccine doses should be positive")
    # check if timeout is correct
    (size(p.p)[2] > timeout >= 0) || error("vaccine timeout should be >= 0 and < than $( size(p.p)[2] )")
    timeout += 1  # set timeout to be the correct index
    total_for_vaccination = p.p[1, 1] + p.p[3, 1] + p.p[4, 1] # S+R+V at t=1
    # if there is whom to vaccinate
    if total_for_vaccination >= n_doses
        # update all states from which vaccinated ware taken
        p.p[1, 1] -= p.p[1, 1] * n_doses / total_for_vaccination
        p.p[3, 1] -= p.p[3, 1] * n_doses / total_for_vaccination
        p.p[4, 1] -= p.p[4, 1] * n_doses / total_for_vaccination
        # add newly vaccinated
        p.p[4, timeout] += n_doses
        return n_doses
    else
        # vaccinate all that can be vaccinated
        # update all states from which vaccinated ware taken
        p.p[1, 1] = zero(T)
        p.p[3, 1] = zero(T)
        p.p[4, 1] = zero(T)
        # add newly vaccinated
        p.p[4, timeout] += total_for_vaccination
        return total_for_vaccination
    end
end

function vaccinate!(p::Population{T}, n_doses::Integer, timeout::Integer = 0)::T where T<:Integer
    n_doses < 0 && error("vaccine doses should be positive")
    # check if timeout is correct
    (size(p.p)[2] > timeout >= 0) || error("vaccine timeout should be >= 0 and < than $( size(p.p)[2] )")
    timeout += 1  # set timeout to be the correct index
    total_for_vaccination = p.p[1, 1] + p.p[3, 1] + p.p[4, 1] # S+R+V at t=1
    # if there is whom to vaccinate
    if total_for_vaccination >= n_doses
        # update all states from which vaccinated ware taken
        v_distribution = round_vaccination_distribution(p.p[1, 1], p.p[3, 1], p.p[4, 1], n_doses, total_for_vaccination)
        p.p[1, 1] -= v_distribution[1]
        p.p[3, 1] -= v_distribution[2]
        p.p[4, 1] -= v_distribution[3]
        # add newly vaccinated
        p.p[4, timeout] += n_doses
        return n_doses
    else
        # vaccinate all that can be vaccinated
        # update all states from which vaccinated ware taken
        p.p[1, 1] = zero(T)
        p.p[3, 1] = zero(T)
        p.p[4, 1] = zero(T)
        # add newly vaccinated
        p.p[4, timeout] += total_for_vaccination
        return total_for_vaccination
    end
end

