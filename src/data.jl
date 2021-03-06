"""Abstract type from which `BareEvent` and `FullEvent` are subtypes"""
abstract AbstractEvent

"Return event `ev` span"
span(ev::AbstractEvent) = ev.ended - ev.began

"""
Type that represents an individual event execution. What follows below is a list describing what each field stands for.
    * `began`: marks at what point - relative to the beginning of the execution - the event began to execute.
    * `ended`: marks at what point - relative to the beginning of the execution - the event ended execution.
"""
type BareEvent <: AbstractEvent
    began::Float32 # splitline[4]
    ended::Float32 # splitline[5]
end

show(io::IO, x::BareEvent) = print(io, "BareEvent: $(x.began) $(x.ended)")

==(x::BareEvent, y::BareEvent) = (x.began == y.began &&
                                  x.ended == y.ended)

isequal(x::BareEvent, y::BareEvent) = (x.began == y.began &&
                                       x.ended == y.ended)

"""
Type that represents an individual event execution. What follows below is a list describing what each field stands for.
    * `name`: string that identifies the event type. `type` would be a better name for this field but it is a [reserved word](http://docs.julialang.org/en/release-0.4/manual/types/#composite-types) in Julia.
    * `began`: marks at what point - relative to the beginning of the execution - the event began to execute.
    * `ended`: marks at what point - relative to the beginning of the execution - the event ended execution.
    * `imbrication`: `Int` that determines level of event in the call stack.
"""
type FullEvent <: AbstractEvent
    name::ByteString # splitline[8]
    kind::ByteString # splitline[3]
    began::Float64 # splitline[4]
    ended::Float64 # splitline[5]
    imbrication::Int # splitline[7]
end

show(io::IO, x::FullEvent) = print(io, "$(x.name) $(x.began) $(x.ended) $(x.imbrication)")

==(x::FullEvent, y::FullEvent) = (x.name == y.name &&
                          x.kind == y.kind &&
                          x.began == y.began &&
                          x.ended == y.ended &&
                          x.imbrication == y.imbrication)

isequal(x::FullEvent, y::FullEvent) = (x.name == y.name &&
                               x.kind == y.kind &&
                               x.began == y.began &&
                               x.ended == y.ended &&
                               x.imbrication == y.imbrication)

"""
Type that will represent information gathered from each container (i.e. process). Below follows a description of what each field represents.
    * `name`: the name of the container (i.e. the name of the Pajé Container that represented the container).
    * `kind`: `Container` type.
    * `began`: marks at what point - relative to the beginning of the execution - the `Container` was created.
    * `ended`: marks at what point - relative to the beginning of the execution - the `Container` was destructed.
    * `kept`: list of `AbstractEvent`s associated with the Container whose `span`s should be considered load.
    * `discarded`: list of `AbstractEvent`s associated with the Container whose `span`s should not be considered load.
"""
type Container
    name::ByteString
    kind::ByteString
    began::Float64
    ended::Float64
    kept::Vector{AbstractEvent}
    discarded::Vector{AbstractEvent}
end

==(x::Container, y::Container) = (x.name == y.name) && (x.kind == y.kind)

isequal(x::Container, y::Container) = (x.name == y.name) && (x.kind == y.kind)

show(io::IO, x::Container) = print(io, "Container \"$(x.name)\" of type \"$(x.kind)\" holding $(length(x.kept)) kept Events and $(length(x.discarded)) discarded Events.")

"Return how many events `Container` `ct` holds"
function count(ct::Container, discarded::Bool=false)
    discarded? length(ct.discarded) : length(ct.kept)
end

"Return collection of `Container` (`ct`) events that executed - totally or partially - between `start` and `finish`"
function events(ct::Container, start::Real, finish::Real, discarded::Bool=false)
    evs = Vector{AbstractEvent}()
    discarded? eventslist = ct.discarded : eventslist = ct.kept
    for ev in eventslist
        if ev.began < finish && ev.ended > start
            push!(evs, ev)
        end
    end
    return evs
end

"Return `ct`s span"
span(ct::Container) = ct.ended - ct.began

"Return the aggregated span of events named `name` on container `ct`"
function span(ct::Container, name::ByteString)
    aggspan = 0
    for ev in ct.kept
        if isa(ev, BareEvent)
            error("BareEvent does not have name field.")
        else
            (ev.name == name)? aggspan += span(ev) : nothing
        end
    end
    return aggspan
end

"Return `ct`'s load"
function load(ct::Container, norm::Bool=false)
    if length(ct.kept) == 0
        ld = span(ct) - mapreduce(span, +, zero(Float64), ct.discarded)
    else
        ld = mapreduce(span, +, zero(Float64), ct.kept) - mapreduce(span, +, zero(Float64), ct.discarded)
    end
    # norm?
    norm? ld = ld/span(ct) : nothing
    return ld
end

"Return `ct`'s load - considering events starting between `start` and `finish`"
function load(ct::Container, start::Real, finish::Real, norm::Bool=false)
    @assert start >= zero(Real) && finish > zero(Real) "Time stamps must be positive."
    @assert start < finish "Start time stamp must be smaller than finish time stamp."
    ld = zero(Float64)
    # get kept events
    if length(ct.kept) == 0
        ld += finish - start
    else
        for ev in events(ct, start, finish)
            ld += span(ev)
            ev.began < start? ld -= (start - ev.began) : nothing
            ev.ended > finish? ld -= (ev.ended - finish) : nothing
        end
    end
    # get discarded events
    for ev in events(ct, start, finish, true)
        ld -= span(ev)
        ev.began < start? ld += (start - ev.began) : nothing
        ev.ended > finish? ld += (ev.ended - finish) : nothing
    end
    # normalized load?
    norm? ld = ld/(finish - start) : nothing
    return ld
end

"""
Type representing a traced execution. The fields are described bellow.
    * `containers`: array that collect all `Container`s (of interest) found in the trace.
"""
type Trace
    containers::Vector{Container}
end

show(io::IO, x::Trace) = print(io, "Trace holding $(length(x.containers)) Containers, $(mapreduce(count, +, zero(Int), x.containers)) kept Events, and $(mapreduce(y -> count(y, true), +, zero(Int), x.containers)) discarded Events.")

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
