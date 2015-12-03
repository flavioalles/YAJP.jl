#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Data, Parser

SEP = ","

"Dumps to `csv` file macroscopic data (trace span and an lb metric)"
function dumpmacro(tr::Trace, path::AbstractString, sep::AbstractString)
    location = joinpath(path, "macro.csv")
    output = open(location, "w")
    # generate header
    write(output, "span$(sep)lb\n")
    # output span
    write(output, "$(span(tr))$(sep)$(lb(tr))\n")
    close(output)
    return location
end

"Dumps to `csv` file info. on every `tasq` parsed"
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
    tr = Parser.parsecsv(ARGS[1], states=true)
    println("done.")
    print("Dumping macro data...")
    location = dumpmacro(tr, dirname(ARGS[1]), SEP)
    println("done.")
    println("Macro data in $(location).")
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
