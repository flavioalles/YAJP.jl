"Returns the **Standard Deviation** among the loads in `tr`s containers"
function std(tr::Trace)
    return std(map(load, tr.containers))
end

# TODO: doc
function std{T<:Real}(tr::Trace, timestep::T, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    stds = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            push!(stds, std(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
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
function skewness{T<:Real}(tr::Trace, timestep::T, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    skews = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            push!(skews, skewness(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
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
function kurtosis{T<:Real}(tr::Trace, timestep::T, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    kurts = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            push!(kurts, kurtosis(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
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
function pimbalance{T<:Real}(tr::Trace, timestep::T, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, ((maximum(loads)/mean(loads)) - 1)*100)
        end
    end
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
function imbalancep{T<:Real}(tr::Trace, timestep::T, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1)))
        end
    end
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
function imbalancet{T<:Real}(tr::Trace, timestep::T, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts < ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, maximum(loads) - mean(loads))
        end
    end
    if norm
        ps = map(x -> (x - minimum(ps))/(maximum(ps) - minimum(ps)), ps)
    end
    return ps
end
