#!/usr/bin/env julia

MAX_SIZE = 100000000

function runyaros(indir, outdir)
    for elem in readdir(indir)
        if !isdir(elem) && splitext(elem)[end] == ".paje" && filesize(joinpath(indir, elem)) < MAX_SIZE
            i = joinpath(indir, elem)
            o = open(joinpath(outdir, replace(elem, ".paje", ".yaros")), "w")
            write(o, readall(`bin/yaros $i`))
            close(o)
        end
    end
end

# check args 
if length(ARGS) != 2 || !isdir(ARGS[1]) || !isdir(ARGS[2])
    println("Wrong usage.")
else
    # run yaros on every .paje file in the dir passed
    runyaros(ARGS[1], ARGS[2])
end
