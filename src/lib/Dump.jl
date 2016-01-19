module Dump

using Data, DataFrames, Load, Parser

# TODO: doc
function loads(tr::Trace, timestep::Int)
    # create DataFrame
    df = DataFrame(slice = Int[],
                   began = Float64[],
                   midpoint = Float64[],
                   ended = Float64[])
    # add one column per container (of type Float64[])
    for ct in tr.containers
        df[Symbol(ct.name)] = Float64[]
    end
    # insert slice loads
    for (slice,ts) in enumerate(began(tr):timestep:ended(tr))
        if ts != ended(tr)
            ts + timestep < ended(tr)? ed = ts + timestep : ed = ended(tr)
            midpoint = ts + (ed - ts)/2
            loads = [slice, ts, midpoint, ed]
            for ct in tr.containers
                push!(loads, load(ct, ts, ts+timestep))
            end
            push!(df, loads)
        end
    end
    return df
end

# TODO: docs
function metrics(tr::Trace, timestep::Int)
    # create DataFrame
    df = DataFrame(slice = Int[],
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
        push!(df, [slice bg midpoint ed metrics[1] metrics[2] metrics[3] metrics[4] metrics[5] metrics[6]])
        #push!(df, [slice, bg, midpoint, ed, metrics[1], metrics[2], metrics[3], metrics[4], metrics[5], metrics[6]])
        #push!(df, [slice, bg, midpoint, ed, metrics])
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
            push!(df, [event.kind ct.name event.began event.ended Data.span(event)])
        end
    end
    return df
end

end