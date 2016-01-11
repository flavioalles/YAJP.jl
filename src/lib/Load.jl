module Load

using Data, Distributions

export skewness, kurtosis, pimbalance, imbalancep, imbalancet

import Base: std
import Distributions: skewness, kurtosis

"Returns the **Standard Deviation** among the loads in `tr`s containers"
function std(tr::Trace)
    return std(map(load, tr.containers))
end

# TODO: doc
function std(tr::Trace, slices::Int)
    @assert slices > 0 "# of slices must be positive"
    timestep = (ended(tr) - began(tr))/slices
    stds = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts != ended(tr)
            push!(stds, std(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
    return stds
end

"Returns the **Skewness** of the loads in `tr`s containers"
function skewness(tr::Trace)
    return skewness(map(load, tr.containers))
end

# TODO: doc
function skewness(tr::Trace, slices::Int)
    @assert slices > 0 "# of slices must be positive"
    timestep = (ended(tr) - began(tr))/slices
    skews = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts != ended(tr)
            push!(skews, skewness(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
    return skews
end

"Returns the **Kurtosis** of the loads in `tr`s containers"
function kurtosis(tr::Trace)
    return kurtosis(map(load, tr.containers))
end

# TODO: doc
function kurtosis(tr::Trace, slices::Int)
    @assert slices > 0 "# of slices must be positive"
    timestep = (ended(tr) - began(tr))/slices
    kurts = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts != ended(tr)
            push!(kurts, kurtosis(map(x -> load(x, ts, ts+timestep), tr.containers)))
        end
    end
    return kurts
end

"Returns the **Percent Imbalance** of the loads of `tr`s containers"
function pimbalance(tr::Trace)
    loads = map(load, tr.containers)
    return ((maximum(loads)/mean(loads)) - 1)*100
end

# TODO: doc
function pimbalance(tr::Trace, slices::Int)
    @assert slices > 0 "# of slices must be positive"
    timestep = (ended(tr) - began(tr))/slices
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts != ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, ((maximum(loads)/mean(loads)) - 1)*100)
        end
    end
    return ps
end

"Returns the **Imbalance Percentage** of the loads of `tr`s containers"
function imbalancep(tr::Trace)
    loads = map(load, tr.containers)
    return ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1))
end

# TODO: doc
function imbalancep(tr::Trace, slices::Int)
    @assert slices > 0 "# of slices must be positive"
    timestep = (ended(tr) - began(tr))/slices
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts != ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1)))
        end
    end
    return ps
end

"Returns the **Imbalance Time** of the loads of `tr`s containers"
function imbalancet(tr::Trace)
    loads = map(load, tr.containers)
    return maximum(loads) - mean(loads)
end

# TODO: doc
function imbalancet(tr::Trace, slices::Int)
    @assert slices > 0 "# of slices must be positive"
    timestep = (ended(tr) - began(tr))/slices
    ps = Float64[]
    for ts in began(tr):timestep:ended(tr)
        if ts != ended(tr)
            loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            push!(ps, maximum(loads) - mean(loads))
        end
    end
    return ps
end

end
