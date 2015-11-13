#!/usr/bin/env julia

# TODO: come up with a better solution to import my lib code
push!(LOAD_PATH, "src/lib")

using Dump, Parser

SEP = ","

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
