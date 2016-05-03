# TODO: doc
function loads(tr::Trace)
    # create DataFrame
    df = DataFrame(slice = Int[],
                   began = Float64[],
                   midpoint = Float64[],
                   ended = Float64[],
                   container = ByteString[],
                   kind = ByteString[],
                   load = Float64[],
                   normalized = Float64[])
    # insert slice loads
    for ct in tr.containers
        ld = load(ct)
        norm = ld/(ended(tr) - began(tr))
        push!(df, [1, began(tr), began(tr)+((ended(tr)-began(tr))/2), ended(tr), ct.name, ct.kind, ld, norm])
    end
    return df
end

# TODO: doc
function loads(tr::Trace, timestep::Real)
    @assert timestep > zero(Real) "Time step must be positive Real number."
    # create DataFrame
    df = DataFrame(slice = Int[],
                   timestep = Real[],
                   began = Float64[],
                   midpoint = Float64[],
                   ended = Float64[],
                   container = ByteString[],
                   kind = ByteString[],
                   load = Float64[],
                   normalized = Float64[])
    # insert slice loads
    for (slice,ts) in enumerate(began(tr):timestep:ended(tr))
        if ts != ended(tr)
            ts + timestep < ended(tr)? ed = ts + timestep : ed = ended(tr)
            midpoint = ts + timestep/2
            for ct in tr.containers
                ld = load(ct, ts, ed)
                norm = ld/(ed - ts)
                push!(df, [slice, timestep, ts, midpoint, ed, ct.name, ct.kind, ld, norm])
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
                     midpoint = @data([began(tr)+((ended(tr)-began(tr))/2)]),
                     ended = @data([ended(tr)]),
                     std = @data([std(tr)]),
                     skewness = @data([skewness(tr)]),
                     kurtosis = @data([kurtosis(tr)]),
                     pimbalance = @data([pimbalance(tr)]),
                     imbalancep = @data([imbalancep(tr)]),
                     imbalancet = @data([imbalancet(tr)]))
end

# TODO: doc
function metrics(tr::Trace, f::Function)
    # assert proper mtr
    fs = [std, skewness, kurtosis,
          pimbalance, imbalancep, imbalancet]
    @assert f in fs "Unrecognized metric function"
    return DataFrame(slice = @data([1]),
                     began = @data([began(tr)]),
                     midpoint = @data([began(tr)+((ended(tr)-began(tr))/2)]),
                     ended = @data([ended(tr)]),
                     metric = @data([string(f)]),
                     value = @data([f(tr)]))
end

# TODO: doc
function metrics(tr::Trace, timestep::Real, drop::Real=0, norm::Bool=false)
    # create DataFrame
    df = DataFrame(slice = Int[],
                   timestep = Real[],
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
    for (slice,values) in enumerate(zip(std(tr,timestep,drop,norm), skewness(tr,timestep,drop,norm),
                                 kurtosis(tr,timestep,drop,norm), pimbalance(tr,timestep,drop,norm),
                                 imbalancep(tr,timestep,drop,norm), imbalancet(tr,timestep,drop,norm)))
        bg = began(tr) + drop + timestep*(slice-1)
        bg + timestep <=  ended(tr) - drop? ed = bg + timestep : ed = ended(tr) - drop
        midpoint = bg +  timestep/2
        push!(df, [slice timestep bg midpoint ed values[1] values[2] values[3] values[4] values[5] values[6]])
    end
    return df
end

# TODO: doc
function metrics(tr::Trace, f::Function, timestep::Real, drop::Real=0, norm::Bool=false)
    # assert proper mtr
    fs = [std, skewness, kurtosis,
          pimbalance, imbalancep, imbalancet]
    @assert f in fs "Unrecognized metric function"
    # create DataFrame
    df = DataFrame(slice = Int[],
                   timestep = Real[],
                   began = Float64[],
                   midpoint = Float64[],
                   ended = Float64[],
                   metric = ByteString[],
                   value = Float64[])
    # insert slices
    for (slice,value) in enumerate(f(tr,timestep,drop,norm))
        bg = began(tr) + drop + timestep*(slice-1)
        bg + timestep <=  ended(tr) - drop? ed = bg + timestep : ed = ended(tr) - drop
        midpoint = bg +  timestep/2
        push!(df, [slice timestep bg midpoint ed string(f) value])
    end
    return df
end

# TODO: doc
function events(tr::Trace, discarded=false)
    # create DataFrame
    df = DataFrame(event = ByteString[],
                   kind = ByteString[],
                   resource = ByteString[],
                   began = Float64[],
                   ended = Float64[],
                   span = Float64[],
                   imbrication = Int[])
    # iterate over containers
    for ct in tr.containers
        # iterate over events
        discarded? evs = ct.discarded : evs = ct.kept
        for event in evs
            if isa(event, BareEvent)
                push!(df, [NA NA ct.name event.began event.ended span(event) NA])
            else
                push!(df, [event.name event.kind ct.name event.began event.ended span(event) event.imbrication])
            end
        end
    end
    return df
end
