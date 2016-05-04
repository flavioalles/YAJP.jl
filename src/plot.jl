# integer used as step in xticks def.
STEPDENOM = 30

"""
    heatmap(tr::YAJP.Trace, timestep::Real)

Returns a [Gadfly] plot depicting `tr`s normalized load evolution (at every `timestep`) as a [Gadfly] `rectbin`.
"""
function heatmap(tr::YAJP.Trace, timestep::Real)
    # major labels font size
    MAJORLABEL = 18pt
    # minor labels font size
    MINORLABEL = 12pt
    # key title font size
    KEYTITLE = 14pt
    # key label font size
    KEYLABEL = 14pt
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
                            convert(Int, round(YAJP.span(tr)/STEPDENOM)):
                            convert(Int, ceil(YAJP.ended(tr))))),
               Guide.xlabel("Time (s)", orientation=:horizontal),
               Guide.ylabel("Resource", orientation=:vertical),
               Scale.color_continuous(minvalue=0.0, maxvalue=1.0),
               Guide.colorkey("Load"),
               Theme(guide_title_position=:center,
                    major_label_font_size=MAJORLABEL,
                    minor_label_font_size=MINORLABEL,
                    key_title_font_size=KEYTITLE,
                    key_label_font_size=KEYLABEL))
end

"""
    heatmap(tr::YAJP.Trace, f::Function, timestep::Real, drop::Int=0)

Returns a [Gadfly] plot depicting `tr`s evolution for load imbalance metric `f` (at every `timestep`) as a [Gadfly] `rectbin`.
"""
function heatmap(tr::YAJP.Trace, f::Function, timestep::Real, drop::Int=0)
    # major labels font size
    MAJORLABEL = 14pt
    # minor labels font size
    MINORLABEL = 12pt
    # key title font size
    KEYTITLE = 14pt
    # key label font size
    KEYLABEL = 12pt
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
                                convert(Int, round(YAJP.span(tr)/STEPDENOM)):
                                convert(Int, ceil(YAJP.ended(tr)-drop)))),
                Guide.xlabel("Time (s)", orientation=:horizontal),
                Scale.y_discrete(labels= x->""),
                Guide.ylabel(text, orientation=:vertical),
                Scale.color_continuous(minvalue=minimum(mtr[:value]),
                                       maxvalue=maximum(mtr[:value])),
                Guide.colorkey("Value"),
                Theme(guide_title_position=:center,
                     major_label_font_size=MAJORLABEL,
                     minor_label_font_size=MINORLABEL,
                     key_title_font_size=KEYTITLE,
                     key_label_font_size=KEYLABEL))
end
