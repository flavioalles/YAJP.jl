module Parser

using Constants, Data

"""
Acquires desired `StarPU` information from csv dump of Pajé trace.

The expected argument is a path to the csv that will be parsed. No checking is done to insure existence and/or readability of file - `SystemError` is thrown and propagated (i.e. not caught here) in case the file cannot be opened.

The function returns an object of type `Trace` (exported by the `Data` module).
"""
function parsecsv(path::AbstractString; states=false)
    # build trace (FYI: trace is a reserved word (its a function))
    tr = Trace(Vector{Worker}(), Vector{TasqType}())
    file = open(path, "r")
    for line in eachline(file)
        # split line in comma-separated fields, remove whitespace and trailing newline
        splitline = map(strip, split(line, ",", keep=true))
        # check what line represents and react accordingly
        if splitline[3] in CONTAINERS
            # build Worker and push it to return array
            wk = Worker(splitline[end], node(string(splitline[end])), parse(Float64, splitline[4]), parse(Float64, splitline[5]), Vector{Tasq}())
            push!(tr.workers, wk)
        elseif splitline[3] in EVENTS && splitline[8] in TASKS
            # check if TasqType has been added to Trace
            tt = TasqType(splitline[8], splitline[9], splitline[11], parse(Int, splitline[12]))
            !(tt in tr.tasqtypes)? push!(tr.tasqtypes, tt): nothing
            # build task object and add to worker
            # assumes that the current task always belongs to the previously added Worker
            tq = Tasq(splitline[8], parse(Int, splitline[10]), parse(Float64, splitline[4]), parse(Float64, splitline[5]))
            push!(tr.workers[end].tasqs, tq)
        elseif states && splitline[3] in EVENTS && splitline[8] in STATES
            # build task object and add to worker
            # assumes that the current task always belongs to the previously added Worker
            tq = Tasq(splitline[8], zero(Int), parse(Float64, splitline[4]), parse(Float64, splitline[5]))
            push!(tr.workers[end].tasqs, tq)
        end
    end
    return tr
end

end
