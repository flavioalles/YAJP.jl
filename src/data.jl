"""
Type that represents an individual event execution. What follows below is a list describing what each field stands for.
    * `kind`: string that identifies the event type. `type` would be a better name for this field but it is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/types/#composite-types) in Julia.
    * `began`: marks at what point - relative to the beginning of the execution - the event began to execute.
    * `ended`: marks at what point - relative to the beginning of the execution - the event ended execution.
"""
type Event
    kind::ByteString # splitline[8]
    began::Float64 # splitline[4]
    ended::Float64 # splitline[5]
end

show(io::IO, x::Event) = print(io, "$(x.kind) $(x.began) $(x.ended)")

==(x::Event, y::Event) = x.kind == y.kind && x.began == y.began && x.ended == y.ended? true : false

isequal(x::Event, y::Event) = x.kind == y.kind && x.began == y.began && x.ended == y.ended? true : false

"Return event `ev` span"
span(ev::Event) = ev.ended - ev.began

# TODO: document
function dump(ev::Event, container::AbstractString, sep::AbstractString)
    # gather ev info
    str = "$(ev.kind)$(sep)$(container)$(sep)$(ev.began)$(sep)$(ev.ended)$(sep)$(span(ev))\n"
    return str
end

"""
Type that will represent information gathered from each container (i.e. process). Below follows a description of what each field represents.
    * `name`: the name of the container (i.e. the name of the Pajé Container that represented the container).
    * `events`: list of `Event`s associated with the Container
"""
type Container
    name::ByteString
    began::Float64
    ended::Float64
    events::Vector{Event}
end

==(x::Container, y::Container) = (x.name == y.name)? true : false

isequal(x::Container, y::Container) = (x.name == y.name)? true : false

"Return how many events `Container` `ct` holds"
count(ct::Container) = length(ct.events)

"Return how many times events of type `kind` were executed on container `ct`"
function count(ct::Container, kind::ByteString)
    exec = 0
    for ev in ct.events
        (ev.kind == kind)? exec+= 1 : nothing
    end
    return exec
end

"Return collection of `Container` (`ct`) events that executed - totally or partially - between `start` and `finish`"
function events(ct::Container, start::Float64, finish::Float64)
    evs = Vector{Event}()
    for ev in ct.events
        if ev.began < finish && ev.ended > start
            push!(evs, ev)
        end
    end
    return evs
end

"Return `ct`s span"
span(ct::Container) = ct.ended - ct.began

"Return the aggregated span of events of type `kind` on container `ct`"
function span(ct::Container, kind::ByteString)
    aggspan = 0
    for ev in ct.events
        (ev.kind == kind)? aggspan += span(ev) : nothing
    end
    return aggspan
end

"Return `ct`'s load"
function load(ct::Container, norm::Bool = false)
    if norm
        return mapreduce(span, +, zero(Float64), ct.events)/span(ct)
    else
        return mapreduce(span, +, zero(Float64), ct.events)
    end
end

"Return `ct`'s load - considering events starting between `start` and `finish`"
function load(ct::Container, start::Float64, finish::Float64, norm = false)
    sp = zero(Float64)
    for ev in events(ct, start, finish)
        sp += span(ev)
        ev.began < start? sp -= (start - ev.began) : nothing
        ev.ended > finish? sp -= (ev.ended - finish) : nothing
    end
    norm? sp = sp/(finish - start) : nothing
    return sp
end

"""
Type representing a traced execution. The fields are described bellow.
    * `containers`: array that collect all `Container`s (of interest) found in the trace.
"""
type Trace
    containers::Vector{Container}
end

show(io::IO, x::Trace) = print(io, "Trace holding $(length(x.containers)) Containers and $(mapreduce(count, +, zero(Int), x.containers)) Events.")

"Return `tr`s beginning timestamp - represented by the `Container` with smallest `began` timestamp"
function began(tr::Trace)
    bg = Inf
    for ct in tr.containers
        ct.began < bg? bg = ct.began : nothing
    end
    return bg
end

"Return `tr`s ending timestamp - represented by the `Container` with highest `ended` timestamp"
function ended(tr::Trace)
    ed = zero(Float64)
    for ct in tr.containers
        ct.ended > ed? ed = ct.ended : nothing
    end
    return ed
end

"Return the `Trace`'s (`tr`) span - measured by the `Container` with largest span"
function span(tr::Trace)
    return ended(tr) - began(tr)
end
