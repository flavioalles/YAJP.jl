module Data

export Trace, Worker, Tasq, TasqType, span, executed, dump

import Base: ==, isequal, show, dump

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

span(tq::Tasq) = tq.ended - tq.began

# TODO: document
function dump(tq::Tasq, worker::AbstractString, tasqtypes::Vector{TasqType}, sep::AbstractString)
   # gather tq info
    str = "$(worker)$(sep)$(tq.kind)$(sep)$(tq.id)$(sep)"
    str *= "$(tq.began)$(sep)$(tq.ended)$(sep)$(span(tq))$(sep)"
    # iterate over tasqtypes
    for tt in tasqtypes
        if tq.kind == tt.kind
            str *= "$(tt.tag)$(sep)$(tt.params)$(sep)$(tt.size)\n"
            break
        end
    end
    return str
end

"""
Type that will represent information gathered from each worker (i.e. process). Below follows a description of what each field represents.
    * `name`: the name of the worker (i.e. the name of the Pajé Container that represented the worker).
    * `computed`: associative array that maps a tasks name to the amount of time (aggregated) that tasks executed in that worker.
    * `executed`: associative array that maps a tasks name to the amount of times that task was executed in that worker.
"""
type Worker
    name::ByteString
    tasqs::Vector{Tasq}
end

==(x::Worker, y::Worker) = (x.name == y.name)? true : false

isequal(x::Worker, y::Worker) = (x.name == y.name)? true : false


"Return how many times tasks of type `tt` was executed on worker `wk`"
function executed(wk::Worker, tt::TasqType)
    exec = 0
    for tq in wk.tasqs
        (tq.kind == tt.kind)? exec+= 1 : nothing
    end
    return exec
end

"Return the aggregated span of tasks of type `tt` on worker `wk`"
function span(wk::Worker, tt::TasqType)
    aggspan = 0
    for tq in wk.tasqs
        (tq.kind == tt.kind)? aggspan += span(tq) : nothing
    end
    return aggspan
end

# TODO: document
function dump(wk::Worker, tasqtypes::Vector{TasqType}, sep::AbstractString)
    # get wk name
    str = "$(wk.name)$(sep)"
    # iterate over tasqtypes
    for (index,tt) in enumerate(tasqtypes)
        if index != length(tasqtypes)
            str *= "$(executed(wk, tt))$(sep)$(span(wk, tt))$(sep)"
        else
            str *= "$(executed(wk, tt))$(sep)$(span(wk, tt))\n"
        end
    end
    return str
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

end