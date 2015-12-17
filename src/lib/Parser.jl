module Parser

using Constants, Data

"""
Acquires desired `StarPU` information from csv or wsv dump of Pajé trace.

The expected argument is a path to the csv (or wsv) trace that will be parsed. No checking is done to insure existence and/or readability of file - `SystemError` is thrown and propagated (i.e. not caught here) in case the file cannot be opened. If file is neither a csv nor a wsv, an `ErrorException` is raised.

An optional argument is (`discard`) tell the parser if the events present in the `STARPU_EVENTS` should be the ones to keep (`discard=false`) or to discard (`discard=true`).

The function returns an object of type `Trace` (exported by the `Data` module).
"""
function starpu(path::AbstractString, discard=false)
    # build trace (FYI: trace is a reserved word (its a function))
    tr = Trace(Vector{Worker}(), Vector{TasqType}())
    # set field separator Char according to file extension (csv or wsv)
    if split(basename(path), '.')[end] == "csv"
        sep = ','
    elseif split(basename(path), '.')[end] == "wsv"
        sep = ' '
    else
        error("Unrecognized extension in trace file.")
    end
    # open trace stream
    file = open(path, "r")
    for line in eachline(file)
        # split line, remove whitespace and trailing newline
        splitline = map(strip, split(line, sep, keep=true))
        # check what line represents and react accordingly
        if splitline[3] in STARPU_CONTAINERS
            # build Worker and push it to return array
            wk = Worker(splitline[end], node(string(splitline[end])), parse(Float64, splitline[4]), parse(Float64, splitline[5]), Vector{Tasq}())
            push!(tr.workers, wk)
        elseif splitline[3] in STARPU_STATES
            if (!discard && splitline[8] in STARPU_EVENTS) || (discard && !(splitline[8] in STARPU_EVENTS))
                # check if splitline is user-defined event
                if length(splitline) > 8
                    tt = TasqType(splitline[8], splitline[9], splitline[11], parse(Int, splitline[12]))
                else
                    tt = TasqType(splitline[8], "NA", "NA", zero(Int))
                end
                # check if TasqType has been added to Trace
                !(tt in tr.tasqtypes)? push!(tr.tasqtypes, tt): nothing
                # build task object and add to worker
                # assumes that the current task always belongs to the previously added Worker
                # check if splitline is user-defined event
                if length(splitline) > 8
                    tq = Tasq(splitline[8], parse(Int, splitline[10]), parse(Float64, splitline[4]), parse(Float64, splitline[5]))
                else
                    tq = Tasq(splitline[8], zero(Int), parse(Float64, splitline[4]), parse(Float64, splitline[5]))
                end
                push!(tr.workers[end].tasqs, tq)
            end
        end
    end
    close(file)
    return tr
end

end
