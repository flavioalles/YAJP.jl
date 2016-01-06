#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Data, Parser

SEP = ","

"Dumps to `csv` trace perf. data. Dump is made in the same dir. as `path` - i.e. trace."
function dumpperf(tr::Trace, path::AbstractString, sep::AbstractString)
    location = joinpath(path, "perf.csv")
    output = open(location, "w")
    # generate header
    write(output, "span\n")
    # output span
    write(output, "$(span(tr))\n")
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

if length(ARGS) == 2 && isfile(ARGS[1]) && isfile(ARGS[2])
    print("Acquiring trace data...")
    tr = Parser.parsetrace(ARGS[1], ARGS[2])
    println("done.")
    print("Dumping performance data...")
    location = dumpperf(tr, dirname(ARGS[1]), SEP)
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
