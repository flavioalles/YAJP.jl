module Dump

using Data

export dumpworkers, dumptasks

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
        # get wk name
        write(dump, "$(wk.name)$(SEP)")
        # iterate over tasqtypes
        for (index,tt) in enumerate(tr.tasqtypes)
            if index != length(tr.tasqtypes)
                write(dump, "$(executed(wk, tt))$(SEP)$(span(wk, tt))$(SEP)")
            else
                write(dump, "$(executed(wk, tt))$(SEP)$(span(wk, tt))\n")
            end
        end
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
            # gather tq info
            write(output, "$(wk.name)$(SEP)$(tq.kind)$(SEP)$(tq.id)$(SEP)")
            write(output, "$(tq.began)$(SEP)$(tq.ended)$(SEP)$(span(tq))$(SEP)")
            # iterate over tasqtypes
            for tt in tr.tasqtypes
                if tq.kind == tt.kind
                    write(output, "$(tt.tag)$(SEP)$(tt.params)$(SEP)$(tt.size)\n")
                    break
                end
            end
        end
    end
    close(output)
    return joinpath(path, "tasks.csv")
end

end
