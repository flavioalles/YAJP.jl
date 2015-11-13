module Dump

using Data

export dumpworkers, dumptasks

# TODO: document
function dumpworkers(tr::Trace, path::AbstractString, sep::AbstractString)
    dump = open(joinpath(path, "workers.csv"), "w")
    # generate header
    write(dump, "resource$(SEP)")
    for (index,tt) in enumerate(tr.tasqtypes)
        if index != length(tr.tasqtypes)
            write(dump, "$(tt.kind)-exec$(SEP)$(tt.kind)-span$(SEP)")
        else
            write(dump, "$(tt.kind)-exec$(SEP)$(tt.kind)-span\n")
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
    close(dump)
    return joinpath(path, "workers.csv")
end

# TODO: document
function dumptasks(tr::Trace, path::AbstractString)
    dump = open(joinpath(path, "tasks.csv"), "w")
    # generate header
    write(dump, "resource$(SEP)type$(SEP)id$(SEP)began$(SEP)ended$(SEP)span$(SEP)")
    write(dump, "tag$(SEP)params$(SEP)size\n")
    # iterate over workers
    for wk in tr.workers
        # iterate over tasqs
        for tq in wk.tasqs
            # gather tq info
            write(dump, "$(wk.name)$(SEP)$(tq.kind)$(SEP)$(tq.id)$(SEP)")
            write(dump, "$(tq.began)$(SEP)$(tq.ended)$(SEP)$(span(tq))$(SEP)")
            # iterate over tasqtypes
            for tt in tr.tasqtypes
                if tq.kind == tt.kind
                    write(dump, "$(tt.tag)$(SEP)$(tt.params)$(SEP)$(tt.size)\n")
                    break
                end
            end
        end
    end
    close(dump)
    return joinpath(path, "tasks.csv")
end

end
