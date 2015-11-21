#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Data, Parser

SEP = ","

# TODO: document
function dumptasks(tr::Trace, path::AbstractString, sep::AbstractString)
    output = open(joinpath(path, "dump.csv"), "w")
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
    return joinpath(path, "dump.csv")
end

if length(ARGS) == 1 && isfile(ARGS[1])
    print("Acquiring trace data...")
    tr = Parser.parsecsv(ARGS[1])
    println("done.")
    print("Dumping data...")
    location = dumptasks(tr, dirname(ARGS[1]), SEP)
    println("done.")
    println("Data in $(location).")
    exit(0)
else
    println("Wrong usage.")
    println("dump.jl <csv-trace>")
    exit(1)
end
