module Data

export Trace, Worker, Tasq, TasqType, span, count, dump

import Base: ==, isequal, show, count, dump

"""
Type that contains information information about `Tasq`s that are not particular for each instance of `Tasq`. Created to reduce storage footprint. Bellow is a list explaining the fields that compose the type.
    * `kind`: string that identifies the task type. `type` would be a better name for this field but it is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/types/#composite-types) in Julia.
    * `tag`: `ByteString` identifier.
    * `params`: `ByteString` describing the parameters the task expects.
    * `size`: `Int` that determines the size of the task.
"""
type TasqType
    kind::ByteString # splitline[8]
    tag::ByteString # splitline[9]
    params::ByteString # splitline[11]
    size::Int # splitline[12]
end

show(io::IO, x::TasqType) = print(io, "$(x.kind) $(x.tag) $(x.params) $(x.size)")

function ==(x::TasqType, y::TasqType)
    if x.kind == y.kind && x.tag == y.tag && x.params == y.params && x.size == y.size
        return true
    else
        return false
    end
end

function isequal(x::TasqType, y::TasqType)
    if x.kind == y.kind && x.tag == y.tag && x.params == y.params && x.size == y.size
        return true
    else
        return false
    end
end

"""
Type that represents an individual task execution. What follows below is a list describing what each field stands for.
    * `kind`: string that identifies the task type. `type` would be a better name for this field but it is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/types/#composite-types) in Julia.
    * `id`: identifier that uniquely identifies the task.
    * `began`: marks at what point - relative to the beginning of the execution - the task began to execute.
    * `ended`: marks at what point - relative to the beginning of the execution - the task ended execution.

Obs: `Tasq` and not `Task` because `Task` is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/control-flow/#man-tasks) in Julia.
"""
type Tasq
    kind::ByteString # splitline[8]
    id::Int # splitline[10]
    began::Float64 # splitline[4]
    ended::Float64 # splitline[5]
end

show(io::IO, x::Tasq) = print(io, "$(x.kind) $(x.id) $(x.began) $(x.ended)")

function ==(x::Tasq, y::Tasq)
    if x.kind == y.kind && x.id == y.id && x.began == y.began && x.ended == y.ended
        return true
    else
        return false
    end
end

function isequal(x::Tasq, y::Tasq)
    if x.kind == y.kind && x.id == y.id && x.began == y.began && x.ended == y.ended
        return true
    else
        return false
    end
end

"Return task `tq` span"
span(tq::Tasq) = tq.ended - tq.began

# TODO: document
function dump(tq::Tasq, worker::AbstractString, node::AbstractString, tasqtypes::Vector{TasqType}, sep::AbstractString)
   # gather tq info
    str = "$(tq.kind)$(sep)$(worker)$(sep)$(node)$(sep)$(tq.id)$(sep)"
    str *= "$(tq.began)$(sep)$(tq.ended)$(sep)$(span(tq))$(sep)"
    # iterate over tasqtypes
    found = false
    for tt in tasqtypes
        if tq.kind == tt.kind
            str *= "$(tt.tag)$(sep)$(tt.params)$(sep)$(tt.size)\n"
            found = true
            break
        end
    end
    # if tq not in tasqtypes, fill string with NA values
    found? nothing : str *= "NA$(sep)NA$(sep)NA\n"
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

"Return how many times tasks of type `tt` was executed on worker `wk`"
function count(wk::Worker, tt::TasqType)
    exec = 0
    for tq in wk.tasqs
        (tq.kind == tt.kind)? exec+= 1 : nothing
    end
    return exec
end

"Return the `wk`s span"
span(wk::Worker) = wk.ended - wk.began

"Return the aggregated span of tasks of type `tt` on worker `wk`"
function span(wk::Worker, tt::TasqType)
    aggspan = 0
    for tq in wk.tasqs
        (tq.kind == tt.kind)? aggspan += span(tq) : nothing
    end
    return aggspan
end

"""
Type representing a traced execution. The fields are described bellow.
    * `name`: name of the trace/application.
    * `workers`: array that collect all `Worker`s (of interest) found in the trace.
    * `tasqtypes`: array that contains (unique) `TasqType`s found within the trace.
"""
type Trace
    name::ByteString # Is it necessary for a Trace to have a name?
    workers::Vector{Worker}
    tasqtypes::Vector{TasqType}
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
