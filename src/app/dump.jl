#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Data, Parser

SEP = ","

# TODO: document
function dumpspan(tr::Trace, path::AbstractString, sep::AbstractString)
    location = joinpath(path, "span.csv")
    output = open(location, "w")
    # generate header
    write(output, "span\n")
    # output span
    write(output, "$(span(tr))\n")
    close(output)
    return location
end

# TODO: document
function dumptasks(tr::Trace, path::AbstractString, sep::AbstractString)
    location = joinpath(path, "tasks.csv")
    output = open(location, "w")
    # generate header
    write(output, "event$(sep)resource$(sep)node$(sep)id$(sep)began$(sep)")
    write(output, "ended$(sep)span$(sep)tag$(sep)params$(sep)size\n")
    # iterate over workers
    for wk in tr.workers
        # iterate over tasqs
        for tq in wk.tasqs
            write(output, dump(tq, wk.name, wk.node, tr.tasqtypes, sep))
        end
    end
    close(output)
    return location
end

if length(ARGS) == 1 && isfile(ARGS[1])
    print("Acquiring trace data...")
    tr = Parser.parsecsv(ARGS[1])
    println("done.")
    print("Dumping span...")
    location = dumpspan(tr, dirname(ARGS[1]), SEP)
    println("done.")
    println("Span in $(location).")
    print("Dumping tasks data...")
    location = dumptasks(tr, dirname(ARGS[1]), SEP)
    println("done.")
    println("Tasks data in $(location).")
    exit(0)
else
    println("Wrong usage.")
    println("dump.jl <csv-trace>")
    exit(1)
end
