"Returns the **Standard Deviation** among the loads in `tr`s containers"
function std(tr::Trace)
    return std(map(load, tr.containers))
end

# TODO: doc
function std(tr::Trace, timestep::Real, drop::Real=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive real number"
    @assert drop < span(tr)/2 "Drop is larger than possible"
    stds = Float64[]
    for ts in (began(tr)+drop):timestep:(ended(tr)-drop)
        if ts < ended(tr) - drop
            if ts + timestep <= ended(tr) - drop
                push!(stds, std(map(x -> load(x, ts, ts+timestep), tr.containers)))
            else
                push!(stds, std(map(x -> load(x, ts, ended(tr)-drop), tr.containers)))
            end
        end
    end
    # norm?
    if norm
        l = [rem(i,2) == 0? 0 : timestep for i=1:length(tr.containers)]
        maxstd = sqrt(mapreduce(x -> abs2(x - mean(l)), +, 0, l)/length(l))
        minstd = zero(Float64)
        stds = map(x -> (x - minstd)/(maxstd - minstd), stds)
    end
    return stds
end

"Returns the **Skewness** of the loads in `tr`s containers"
function skewness(tr::Trace)
    return skewness(map(load, tr.containers))
end

# TODO: doc
function skewness(tr::Trace, timestep::Real, drop::Real=0)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive real number"
    @assert drop < span(tr)/2 "Drop is larger than possible"
    skews = Float64[]
    for ts in (began(tr)+drop):timestep:(ended(tr)-drop)
        if ts < ended(tr) - drop
            if ts + timestep <= ended(tr) - drop
                push!(skews, skewness(map(x -> load(x, ts, ts+timestep), tr.containers)))
            else
                push!(skews, skewness(map(x -> load(x, ts, ended(tr)-drop), tr.containers)))
            end
        end
    end
    return skews
end

"Returns the **Kurtosis** of the loads in `tr`s containers"
function kurtosis(tr::Trace)
    return kurtosis(map(load, tr.containers))
end

# TODO: doc
function kurtosis(tr::Trace, timestep::Real, drop::Real=0)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive real number"
    @assert drop < span(tr)/2 "Drop is larger than possible"
    kurts = Float64[]
    for ts in (began(tr)+drop):timestep:(ended(tr)-drop)
        if ts < ended(tr) - drop
            if ts + timestep <= ended(tr) - drop
                push!(kurts, kurtosis(map(x -> load(x, ts, ts+timestep), tr.containers)))
            else
                push!(kurts, kurtosis(map(x -> load(x, ts, ended(tr)-drop), tr.containers)))
            end
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
function pimbalance(tr::Trace, timestep::Real, drop::Real=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive real number"
    @assert drop < span(tr)/2 "Drop is larger than possible"
    ps = Float64[]
    for ts in (began(tr)+drop):timestep:(ended(tr)-drop)
        if ts < ended(tr) - drop
            if ts + timestep <= ended(tr) - drop
                loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            else
                loads = map(x -> load(x, ts, ended(tr)-drop), tr.containers)
            end
            push!(ps, ((maximum(loads)/mean(loads)) - 1)*100)
        end
    end
    # norm?
    if norm
        l = [i == 1? timestep : 0 for i=1:length(tr.containers)]
        maxps = ((maximum(l)/mean(l)) - 1)*100
        minps = zero(Float64)
        ps = map(x -> (x - minps)/(maxps - minps), ps)
    end
    return ps
end

"Returns the **Imbalance Percentage** of the loads of `tr`s containers"
function imbalancep(tr::Trace)
    loads = map(load, tr.containers)
    return ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1))
end

# TODO: doc
function imbalancep(tr::Trace, timestep::Real, drop::Real=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive real number"
    @assert drop < span(tr)/2 "Drop is larger than possible"
    ps = Float64[]
    for ts in (began(tr)+drop):timestep:(ended(tr)-drop)
        if ts < ended(tr) - drop
            if ts + timestep <= ended(tr) - drop
                loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            else
                loads = map(x -> load(x, ts, ended(tr)-drop), tr.containers)
            end
            push!(ps, ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1)))
        end
    end
    # norm?
    if norm
        l = [i == 1? timestep : 0 for i=1:length(tr.containers)]
        maxps = ((maximum(l) - mean(l))/maximum(l))*(length(l)/(length(l) - 1))
        minps = zero(Float64)
        ps = map(x -> (x - minps)/(maxps - minps), ps)
    end
    return ps
end

"Returns the **Imbalance Time** of the loads of `tr`s containers"
function imbalancet(tr::Trace)
    loads = map(load, tr.containers)
    return maximum(loads) - mean(loads)
end

# TODO: doc
function imbalancet(tr::Trace, timestep::Real, drop::Real=0, norm::Bool=false)
    @assert timestep > zero(Int) "Time step must be positive"
    @assert drop >= zero(Int) "Drop must be positive real number"
    @assert drop < span(tr)/2 "Drop is larger than possible"
    ps = Float64[]
    for ts in (began(tr)+drop):timestep:(ended(tr)-drop)
        if ts < ended(tr) - drop
            if ts + timestep <= ended(tr) - drop
                loads = map(x -> load(x, ts, ts+timestep), tr.containers)
            else
                loads = map(x -> load(x, ts, ended(tr)-drop), tr.containers)
            end
            push!(ps, maximum(loads) - mean(loads))
        end
    end
    # norm?
    if norm
        l = [i == 1? timestep : 0 for i=1:length(tr.containers)]
        maxps = maximum(l) - mean(l)
        minps = zero(Float64)
        ps = map(x -> (x - minps)/(maxps - minps), ps)
    end
    return ps
end
