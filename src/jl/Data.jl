module Data

export Trace, Worker, Tasq, TasqType

import Base: ==, isequal, show

"""
TODO
    * `kind`: string that identifies the task type. `type` would be a better name for this field but it is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/types/#composite-types) in Julia.
    * `tag`:
    * `params`:
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

"""
TODO
"""
type Trace
    name::ByteString # Is it necessary for a Trace to have a name?
    workers::Vector{Worker}
    tasqtypes::Vector{TasqType}
end

end
