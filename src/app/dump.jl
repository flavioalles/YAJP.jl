#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Data, Parser

SEP = ","

# TODO: document
function dumpworkers(tr::Trace, path::AbstractString, sep::AbstractString)
    output = open(joinpath(path, "workers.csv"), "w")
    # generate header
    write(output, "resource$(sep)node$(sep)event$(sep)count$(sep)span\n")
    # iterate over workers
    for wk in tr.workers
        # iterate over tasqtypes
        for tt in tr.tasqtypes
            str = "$(wk.name)$(sep)$(wk.node)$(sep)$(tt.kind)$(sep)$(count(wk, tt))$(sep)$(span(wk, tt))"
            write(output, "$(str)\n")
        end
    end
    close(output)
    return joinpath(path, "workers.csv")
end

# TODO: document
function dumptasks(tr::Trace, path::AbstractString, sep::AbstractString)
    output = open(joinpath(path, "tasks.csv"), "w")
    # generate header
    write(output, "type$(sep)resource$(sep)node$(sep)id$(sep)began$(sep)")
    write(output, "ended$(sep)span$(sep)tag$(sep)params$(sep)size\n")
    # iterate over workers
    for wk in tr.workers
        # iterate over tasqs
        for tq in wk.tasqs
            write(output, dump(tq, wk.name, wk.node, tr.tasqtypes, sep))
        end
    end
    close(output)
    return joinpath(path, "tasks.csv")
end

if length(ARGS) == 1 && isfile(ARGS[1])
    print("Acquiring trace data...")
    tr = Parser.parsecsv(ARGS[1])
    println("done.")
    println("Dumping workers...")
    location = dumpworkers(tr, dirname(ARGS[1]), SEP)
    println("Done. Worker data in $(location).")
    println("Dumping tasks...")
    location = dumptasks(tr, dirname(ARGS[1]), SEP)
    println("Done. Tasks data in $(location).")
    exit(0)
else
    println("Wrong usage.")
    println("dump.jl <csv-trace>")
    exit(1)
end
