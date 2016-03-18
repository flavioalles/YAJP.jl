"""
    trace(tracepath::AbstractString, configpath::AbstractString)

Acquires desired trace information - as described by `configpath` configuration file - from csv or wsv dump of Pajé trace.

The expected arguments are, respectively, a path to the csv (or wsv) trace that will be parsed (`tracepath`) and a path to the configuration file that will define what is to be kept (`configpath`) No checking is done to insure existence and/or readability of files - `SystemError` is thrown and propagated (i.e. not caught here) in case the file cannot be opened. Also, if the config. file is inconsistent (as determined by `Conf.get(::AbstractString)`), an `ErrorException` is thrown. If file is neither a csv nor a wsv (determined simply by checking its extension), an `ErrorException` is raised.

The function returns an object of type `Trace` (exported by the `Data` module).
"""
function trace(tracepath::AbstractString, configpath::AbstractString)
    # error checking
    @assert isfile(tracepath) "Inexistent trace file"
    @assert isfile(configpath) "Inexistent config. file"
    @assert checkconfig(configpath) "Inconsistent config. file"
    # get configuration
    config = getconfig(configpath)
    # get denominator for time stamps
    if haskey(config, "unit")
        if config["unit"] == "ms"
            denom = 1000
        elseif config["unit"] == "us"
            denom = 1000000
        elseif config["unit"] == "ns"
            denom = 1000000000
        else # config["unit"] == "s"
            denom = 1
        end
    else
        denom = 1
    end
    # build trace (FYI: trace is a reserved word (its a function))
    tr = Trace(Vector{Container}())
    # set field separator Char according to file extension (csv or wsv)
    if split(basename(tracepath), '.')[end] == "csv"
        sep = ','
    elseif split(basename(tracepath), '.')[end] == "wsv"
        sep = ' '
    else
        error("Unrecognized trace file extension.")
    end
    # open trace stream
    file = open(tracepath, "r")
    for line in eachline(file)
        # split line, remove whitespace and trailing newline
        splitline = map(strip, split(line, sep, keep=true))
        # check what line represents and react accordingly
        if splitline[3] in config["containers"]
            # build Container and push it to return array
            ct = Container(splitline[end], parse(Float64, splitline[4])/denom, parse(Float64, splitline[5])/denom, Vector{Event}(), Vector{Event}())
            push!(tr.containers, ct)
        elseif splitline[3] in config["states"]
            if haskey(config, "keep") && splitline[8] in config["keep"]
                # build event object and add to container
                # assumes that the current event always belongs to the most recently added Container
                # and that events are chronologically ordered
                ev = Event(splitline[8], parse(Float64, splitline[4])/denom, parse(Float64, splitline[5])/denom)
                push!(tr.containers[end].kept, ev)
            elseif haskey(config, "discard") && splitline[8] in config["discard"]
                # build event object and add to container
                # assumes that the current event always belongs to the most recently added Container
                # and that events are chronologically ordered
                ev = Event(splitline[8], parse(Float64, splitline[4])/denom, parse(Float64, splitline[5])/denom)
                push!(tr.containers[end].discarded, ev)
            end
        end
    end
    close(file)
    return tr
end
