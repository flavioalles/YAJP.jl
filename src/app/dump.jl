#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Data, Load, Parser

SEP = ","

# TODO: doc
function checkargs{T<:AbstractString}(args::Vector{T})
    if length(args) < 2 || length(args) > 3
        return false
    elseif !isfile(args[1]) || !isfile(args[2])
        return false
    elseif length(args) == 3
        if !startswith(args[3], "--slices=")
            return false
        else
            try
                if parse(Int, replace(args[3], "--slices=","")) < 1
                    return false
                end
            catch
                return false
            end
        end
    end
    return true
end

"Dumps to `csv` load balancing metrics. Dump is made in the same dir. as `path` - i.e. trace location."
function dumpmetrics(tr::Trace, path::AbstractString, slices::Int, sep::AbstractString)
    location = joinpath(path, "metrics.csv")
    output = open(location, "w")
    # generate header
    write(output, "slice$(sep)std$(sep)skewness$(sep)kurtosis$(sep)pimbalance$(sep)imbalancep$(sep)imbalancet\n")
    # output slices
    for (index,metrics) in enumerate(zip(std(tr,slices), skewness(tr,slices), kurtosis(tr,slices), pimbalance(tr,slices), imbalancep(tr,slices), imbalancet(tr,slices)))
        write(output, "$(index)$(sep)$(metrics[1])$(sep)$(metrics[2])$(sep)$(metrics[3])$(sep)$(metrics[4])$(sep)$(metrics[5])$(sep)$(metrics[6])\n")
    end
    close(output)
    return location
end

"Dumps to `csv` trace perf. data. Dump is made in the same dir. as `path` - i.e. trace."
function dumpperf(tr::Trace, path::AbstractString, slices::Int, sep::AbstractString)
    location = joinpath(path, "perf.csv")
    output = open(location, "w")
    # generate header
    write(output, "span$(sep)began$(sep)ended\n")
    # output span
    write(output, "$(span(tr))$(sep)$(began(tr))$(sep)$(ended(tr))\n")
    close(output)
    return location
end

"Dumps to `csv` file info. on every `event` parsed. Dump is made in the same dir. as `path` - i.e. trace."
function dumpevents(tr::Trace, path::AbstractString, sep::AbstractString)
    location = joinpath(path, "events.csv")
    output = open(location, "w")
    # generate header
    write(output, "event$(sep)resource$(sep)began$(sep)ended$(sep)span\n")
    # iterate over containers
    for ct in tr.containers
        # iterate over events
        for ev in ct.events
            write(output, dump(ev, ct.name, sep))
        end
    end
    close(output)
    return location
end

if checkargs(ARGS)
    print("Acquiring trace data...")
    tr = Parser.parsetrace(ARGS[1], ARGS[2])
    println("done.")
    print("Dumping load balancing metrics...")
    if length(ARGS) == 2
        location = dumpmetrics(tr, dirname(ARGS[1]), 1, SEP)
    else
        location = dumpmetrics(tr, dirname(ARGS[1]), parse(Int, replace(ARGS[3], "--slices=","")), SEP)
    end
    println("done.")
    println("Metrics data in $(location).")
    print("Dumping performance data...")
    if length(ARGS) == 2
        location = dumpperf(tr, dirname(ARGS[1]), 1, SEP)
    else
        location = dumpperf(tr, dirname(ARGS[1]), parse(Int, replace(ARGS[3], "--slices=","")), SEP)
    end
    println("done.")
    println("Performance data in $(location).")
    print("Dumping events data...")
    location = dumpevents(tr, dirname(ARGS[1]), SEP)
    println("done.")
    println("Events data in $(location).")
    exit(0)
else
    println("Wrong usage.")
    println("dump.jl <csv-trace> <yaml-config>")
    exit(1)
end
