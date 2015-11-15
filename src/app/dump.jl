#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Data, Parser

SEP = ","

# TODO: document
function dumpworkers(tr::Trace, path::AbstractString)
    output = open(joinpath(path, "workers.csv"), "w")
    # generate header
    write(output, "resource$(SEP)")
    for (index,tt) in enumerate(tr.tasqtypes)
        if index != length(tr.tasqtypes)
            write(output, "$(tt.kind)-exec$(SEP)$(tt.kind)-span$(SEP)")
        else
            write(output, "$(tt.kind)-exec$(SEP)$(tt.kind)-span\n")
        end
    end
    # iterate over workers
    for wk in tr.workers
        write(output, dump(wk, tr.tasqtypes, SEP))
    end
    close(output)
    return joinpath(path, "workers.csv")
end

# TODO: document
function dumptasks(tr::Trace, path::AbstractString)
    output = open(joinpath(path, "tasks.csv"), "w")
    # generate header
    write(output, "resource$(SEP)type$(SEP)id$(SEP)began$(SEP)ended$(SEP)span$(SEP)")
    write(output, "tag$(SEP)params$(SEP)size\n")
    # iterate over workers
    for wk in tr.workers
        # iterate over tasqs
        for tq in wk.tasqs
            write(output, dump(tq, wk.name, tr.tasqtypes, SEP))
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
    location = dumpworkers(tr, dirname(ARGS[1]))
    println("Done. Worker data in $(location).")
    println("Dumping tasks...")
    location = dumptasks(tr, dirname(ARGS[1]))
    println("Done. Tasks data in $(location).")
    exit(0)
else
    println("Wrong usage.")
    println("dump.jl <csv-trace>")
    exit(1)
end
