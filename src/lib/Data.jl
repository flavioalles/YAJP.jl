module Data

export Trace, Worker, Tasq, TasqType, span, count, dump, lb

import Base: ==, isequal, show, count, dump

"""
Type that represents an individual task execution. What follows below is a list describing what each field stands for.
    * `kind`: string that identifies the task type. `type` would be a better name for this field but it is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/types/#composite-types) in Julia.
    * `began`: marks at what point - relative to the beginning of the execution - the task began to execute.
    * `ended`: marks at what point - relative to the beginning of the execution - the task ended execution.

Obs: `Tasq` and not `Task` because `Task` is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/control-flow/#man-tasks) in Julia.
"""
type Tasq
    kind::ByteString # splitline[8]
    began::Float64 # splitline[4]
    ended::Float64 # splitline[5]
end

show(io::IO, x::Tasq) = print(io, "$(x.kind) $(x.began) $(x.ended)")

==(x::Tasq, y::Tasq) = x.kind == y.kind && x.began == y.began && x.ended == y.ended? true : false

isequal(x::Tasq, y::Tasq) = x.kind == y.kind && x.began == y.began && x.ended == y.ended? true : false

"Return task `tq` span"
span(tq::Tasq) = tq.ended - tq.began

# TODO: document
function dump(tq::Tasq, worker::AbstractString, node::AbstractString, sep::AbstractString)
    # gather tq info
    str = "$(tq.kind)$(sep)$(worker)$(sep)$(node)$(sep)"
    str *= "$(tq.began)$(sep)$(tq.ended)$(sep)$(span(tq))\n"
    return str
end

"""
Type that will represent information gathered from each worker (i.e. process). Below follows a description of what each field represents.
    * `name`: the name of the worker (i.e. the name of the Pajé Container that represented the worker).
    * `node`: NUMA node where the worker is located
    * `tasqs`: list of `Tasq`s associated with the Worker
"""
type Worker
    name::ByteString
    node::ByteString
    began::Float64
    ended::Float64
    tasqs::Vector{Tasq}
end

==(x::Worker, y::Worker) = (x.name == y.name)? true : false

isequal(x::Worker, y::Worker) = (x.name == y.name)? true : false

"Return how many times tasks of type `kind` were executed on worker `wk`"
function count(wk::Worker, kind::ByteString)
    exec = 0
    for tq in wk.tasqs
        (tq.kind == kind)? exec+= 1 : nothing
    end
    return exec
end

"Return `wk`s span"
span(wk::Worker) = wk.ended - wk.began

"Return the aggregated span of tasks of type `kind` on worker `wk`"
function span(wk::Worker, kind::ByteString)
    aggspan = 0
    for tq in wk.tasqs
        (tq.kind == kind)? aggspan += span(tq) : nothing
    end
    return aggspan
end

"""
Type representing a traced execution. The fields are described bellow.
    * `workers`: array that collect all `Worker`s (of interest) found in the trace.
"""
type Trace
    workers::Vector{Worker}
end

"Return the `tr`s span - measured by the `Worker` with largest span"
function span(tr::Trace)
    # iterate over workers
    sp = zero(Float64)
    for wk in tr.workers
        sp < span(wk)? sp = span(wk) : nothing
    end
    return sp
end

end
