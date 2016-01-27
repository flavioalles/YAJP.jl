# TODO: doc
function loads(tr::Trace)
    # create DataFrame
    df = DataFrame(slice = Int[],
                   began = Float64[],
                   midpoint = Float64[],
                   ended = Float64[],
                   container = ByteString[],
                   load = Float64[],
                   normalized = Float64[])
    # insert slice loads
    for ct in tr.containers
        ld = load(ct)
        norm = ld/(ended(tr) - began(tr))
        push!(df, [1, began(tr), (ended(tr)-began(tr))/2, ended(tr), ct.name, ld, norm])
    end
    return df
end

# TODO: doc
function loads(tr::Trace, timestep::Int)
    # create DataFrame
    df = DataFrame(slice = Int[],
                   timestep = Int[],
                   began = Float64[],
                   midpoint = Float64[],
                   ended = Float64[],
                   container = ByteString[],
                   load = Float64[],
                   normalized = Float64[])
    # insert slice loads
    for (slice,ts) in enumerate(began(tr):timestep:ended(tr))
        if ts != ended(tr)
            ts + timestep < ended(tr)? ed = ts + timestep : ed = ended(tr)
            midpoint = ts + (ed - ts)/2
            for ct in tr.containers
                ld = load(ct, ts, ed)
                norm = ld/(ed - ts)
                push!(df, [slice, timestep, ts, midpoint, ed, ct.name, ld, norm])
            end
        end
    end
    return df
end

# TODO: doc
function metrics(tr::Trace)
    # create DataFrame
    return DataFrame(slice = @data([1]),
                     began = @data([began(tr)]),
                     midpoint = @data([(ended(tr)-began(tr))/2]),
                     ended = @data([ended(tr)]),
                     std = @data([std(tr)]),
                     skewness = @data([skewness(tr)]),
                     kurtosis = @data([kurtosis(tr)]),
                     pimbalance = @data([pimbalance(tr)]),
                     imbalancep = @data([imbalancep(tr)]),
                     imbalancet = @data([imbalancet(tr)]))
end

# TODO: doc
function metrics(tr::Trace, timestep::Int)
    # create DataFrame
    df = DataFrame(slice = Int[],
                   timestep = Int[],
                   began = Float64[],
                   midpoint = Float64[],
                   ended = Float64[],
                   std = Float64[],
                   skewness = Float64[],
                   kurtosis = Float64[],
                   pimbalance = Float64[],
                   imbalancep = Float64[],
                   imbalancet = Float64[])
    # insert slices
    for (slice,metrics) in enumerate(zip(std(tr,timestep), skewness(tr,timestep),
                                 kurtosis(tr,timestep), pimbalance(tr,timestep),
                                 imbalancep(tr,timestep), imbalancet(tr,timestep)))
        bg = began(tr) + timestep*(slice-1)
        bg + timestep <=  ended(tr)? ed = bg + timestep : ed = ended(tr)
        midpoint = bg +  (ed - bg)/2
        push!(df, [slice timestep bg midpoint ed metrics[1] metrics[2] metrics[3] metrics[4] metrics[5] metrics[6]])
    end
    return df
end

# TODO: doc
function events(tr::Trace)
    # create DataFrame
    df = DataFrame(event = ByteString[],
                   resource = ByteString[],
                   began = Float64[],
                   ended = Float64[],
                   span = Float64[])
    # iterate over containers
    for ct in tr.containers
        # iterate over events
        for event in ct.events
            push!(df, [event.kind ct.name event.began event.ended span(event)])
        end
    end
    return df
end
