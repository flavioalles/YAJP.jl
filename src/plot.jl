"""
    heatmap(tr::YAJP.Trace, timestep::Real)

Returns a [Gadfly] plot depicting `tr`s normalized load evolution (at every `timestep`) as a [Gadfly] `rectbin`.
"""
function heatmap(tr::YAJP.Trace, timestep::Real)
    # get loads
    lds = loads(tr, timestep)
    # sort DataFrame by container name
    try
        # MPI
        lds = sort!(lds,
                    cols = order(:container,
                                by = x -> parse(Int, replace(x, "rank", ""))),
                    rev = true)
    catch e
        if isa(e, ArgumentError)
            # StarPU
            lds = sort!(lds,
                    cols = order(:container,
                                by = x -> parse(Int, replace(x, "CPU", ""))),
                    rev = true)
        else
            throw(e)
        end
    end
    # return heat map of load evolution per resource
    return plot(lds, x="midpoint", y="container", color="normalized", Geom.rectbin,
               Coord.cartesian(xmin=YAJP.began(tr), xmax=YAJP.ended(tr)),
               Guide.xticks(ticks=collect(
                            convert(Int, floor(YAJP.began(tr))):
                            convert(Int, round(YAJP.span(tr)/20)):
                            convert(Int, ceil(YAJP.ended(tr))))),
               Guide.xlabel("Time (s)", orientation=:horizontal),
               Guide.ylabel("Resource", orientation=:vertical),
               Scale.color_continuous(minvalue=0.0, maxvalue=1.0),
               Guide.title("Normalized Load per Resource at Every $(timestep) s"),
               Guide.colorkey("Load"),
               Theme(guide_title_position=:center))
end

"""
    heatmap(tr::YAJP.Trace, f::Function, timestep::Real, drop::Int=0)

Returns a [Gadfly] plot depicting `tr`s evolution for load imbalance metric `f` (at every `timestep`) as a [Gadfly] `rectbin`.
"""
function heatmap(tr::YAJP.Trace, f::Function, timestep::Real, drop::Int=0)
    # retrieve metric
    mtr = metrics(tr, f, timestep, drop)
    # select appropriate metric y-label and title start
    if f == std
        text = "Standard Deviation (s)"
    elseif f == skewness
        text = "Skewness"
    elseif f == kurtosis
        text = "Kurtosis"
    elseif f == pimbalance
        text = "Percent Imbalance"
    elseif f == imbalancep
        text = "Imbalance Percentage"
    else
        text = "Imbalance Time (s)"
    end
    # plot metric heat map
    return plot(mtr, x="midpoint", y="metric", color="value", Geom.rectbin,
                Coord.cartesian(xmin=YAJP.began(tr)+drop,
                                xmax=YAJP.ended(tr)-drop),
                Guide.xticks(ticks=collect(
                                convert(Int, floor(YAJP.began(tr)+drop)):
                                convert(Int, round(YAJP.span(tr)/20)):
                                convert(Int, ceil(YAJP.ended(tr)-drop)))),
                Guide.xlabel("Time (s)", orientation=:horizontal),
                Scale.y_discrete(labels= x->""),
                Guide.ylabel(nothing),
                Scale.color_continuous(minvalue=minimum(mtr[:value]),
                                       maxvalue=maximum(mtr[:value])),
                Guide.title("$(text) Evolution at Every $(timestep) s"),
                Guide.colorkey("Value"),
                Theme(guide_title_position=:left))
end
