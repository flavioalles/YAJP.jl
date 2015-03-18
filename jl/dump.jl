#!/usr/bin/env julia

MAX_SIZE = 100000000

# check args 
if length(ARGS) != 2 || !isdir(ARGS[1]) || !isdir(ARGS[2])
    println("Wrong usage.")
else
    # run yaros on every .paje file in the dir passed
    for elem in readdir(ARGS[1])
        if !isdir(elem) && splitext(elem)[end] == ".paje" && filesize(joinpath(ARGS[1], elem)) < MAX_SIZE
            i = joinpath(ARGS[1], elem)
            o = open(joinpath(ARGS[2], replace(elem, ".paje", ".yaros")), "w")
            write(o, readall(`bin/yaros $i`))
            close(o)
        end
    end
end
