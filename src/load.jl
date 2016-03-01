"Returns the **Standard Deviation** among the loads in `tr`s containers"
function std(tr::Trace)
    return std(map(load, tr.containers))
end

# TODO: doc
function std{T<:Real}(tr::Trace, timestep::T, drop::Int=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive integer"
    stds = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            push!(stds, std(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
    # drop?
    if drop != 0
        if drop < ceil(length(stds)/2)
            deleteat!(stds, 1:drop)
            deleteat!(stds, (length(stds)-drop+1):length(stds))
        else
            error("Drop too high - would eliminate list completely")
        end
    end
    # norm?
    if norm
        stds = map(x -> (x - minimum(stds))/(maximum(stds) - minimum(stds)), stds)
    end
    return stds
end

"Returns the **Skewness** of the loads in `tr`s containers"
function skewness(tr::Trace)
    return skewness(map(load, tr.containers))
end

# TODO: doc
function skewness{T<:Real}(tr::Trace, timestep::T, drop::Int=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive integer"
    skews = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            push!(skews, skewness(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
    # drop?
    if drop != 0
        if drop < ceil(length(skews)/2)
            deleteat!(skews, 1:drop)
            deleteat!(skews, (length(skews)-drop+1):length(skews))
        else
            error("Drop too high - would eliminate list completely")
        end
    end
    # norm?
    if norm
        skews = map(x -> (x - minimum(skews))/(maximum(skews) - minimum(skews)), skews)
    end
    return skews
end

"Returns the **Kurtosis** of the loads in `tr`s containers"
function kurtosis(tr::Trace)
    return kurtosis(map(load, tr.containers))
end

# TODO: doc
function kurtosis{T<:Real}(tr::Trace, timestep::T, drop::Int=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive integer"
    kurts = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            push!(kurts, kurtosis(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
    # drop?
    if drop != 0
        if drop < ceil(length(kurts)/2)
            deleteat!(kurts, 1:drop)
            deleteat!(kurts, (length(kurts)-drop+1):length(kurts))
        else
            error("Drop too high - would eliminate list completely")
        end
    end
    # norm?
    if norm
        kurts = map(x -> (x - minimum(kurts))/(maximum(kurts) - minimum(kurts)), kurts)
    end
    return kurts
end

"Returns the **Percent Imbalance** of the loads of `tr`s containers"
function pimbalance(tr::Trace)
    loads = map(load, tr.containers)
    return ((maximum(loads)/mean(loads)) - 1)*100
end

# TODO: doc
function pimbalance{T<:Real}(tr::Trace, timestep::T, drop::Int=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive integer"
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, ((maximum(loads)/mean(loads)) - 1)*100)
        end
    end
    # drop?
    if drop != 0
        if drop < ceil(length(ps)/2)
            deleteat!(ps, 1:drop)
            deleteat!(ps, (length(ps)-drop+1):length(ps))
        else
            error("Drop too high - would eliminate list completely")
        end
    end
    # norm?
    if norm
        ps = map(x -> (x - minimum(ps))/(maximum(ps) - minimum(ps)), ps)
    end
    return ps
end

"Returns the **Imbalance Percentage** of the loads of `tr`s containers"
function imbalancep(tr::Trace)
    loads = map(load, tr.containers)
    return ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1))
end

# TODO: doc
function imbalancep{T<:Real}(tr::Trace, timestep::T, drop::Int=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive integer"
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1)))
        end
    end
    # drop?
    if drop != 0
        if drop < ceil(length(ps)/2)
            deleteat!(ps, 1:drop)
            deleteat!(ps, (length(ps)-drop+1):length(ps))
        else
            error("Drop too high - would eliminate list completely")
        end
    end
    # norm?
    if norm
        ps = map(x -> (x - minimum(ps))/(maximum(ps) - minimum(ps)), ps)
    end
    return ps
end

"Returns the **Imbalance Time** of the loads of `tr`s containers"
function imbalancet(tr::Trace)
    loads = map(load, tr.containers)
    return maximum(loads) - mean(loads)
end

# TODO: doc
function imbalancet{T<:Real}(tr::Trace, timestep::T, drop::Int=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive integer"
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, maximum(loads) - mean(loads))
        end
    end
    # drop?
    if drop != 0
        if drop < ceil(length(ps)/2)
            deleteat!(ps, 1:drop)
            deleteat!(ps, (length(ps)-drop+1):length(ps))
        else
            error("Drop too high - would eliminate list completely")
        end
    end
    # norm?
    if norm
        ps = map(x -> (x - minimum(ps))/(maximum(ps) - minimum(ps)), ps)
    end
    return ps
end
