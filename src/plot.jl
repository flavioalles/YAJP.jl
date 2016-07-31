# integer used as step in xticks def.
STEPDENOM = 30

"""
    loadplot(tr::YAJP.Trace, timestep::Real, labels::Bool=true)

Returns a [Gadfly](https://github.com/dcjones/Gadfly.jl) plot depicting `tr`s normalized load evolution (at every `timestep`) as a [`rectbin`](http://dcjones.github.io/Gadfly.jl/geom_rectbin.html). The optional argument `labels` determines if plot is labelled or not.
"""
function loadplot(tr::YAJP.Trace, timestep::Real, labels::Bool=true)
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
    # set labels and key position
    if labels
        horizontallabel = "Time (s)"
        verticallabel = "Resource"
        keyposition = :right
    else
        horizontallabel = nothing
        verticallabel = nothing
        keyposition = :none
    end
    # plot heat map of load evolution per resource
    pl = plot(lds, x="midpoint", y="container", color="normalized",
              Geom.rectbin,
              Coord.cartesian(xmin=YAJP.began(tr), xmax=YAJP.ended(tr)),
              Guide.xticks(ticks=collect(
                            convert(Int, floor(YAJP.began(tr))):
                            convert(Int, round(YAJP.span(tr)/STEPDENOM)):
                            convert(Int, ceil(YAJP.ended(tr)))),
                           label=labels,
                           orientation=:horizontal),
              Guide.yticks(label=labels),
              Guide.xlabel(horizontallabel, orientation=:horizontal),
              Guide.ylabel(verticallabel, orientation=:vertical),
              Scale.color_continuous(minvalue=0.0, maxvalue=1.0),
              Guide.colorkey("Load"),
              Theme(key_position=keyposition,
                    guide_title_position=:center,
                    major_label_font_size=MAJORLABEL,
                    minor_label_font_size=MINORLABEL,
                    key_title_font_size=KEYTITLE,
                    key_label_font_size=KEYLABEL))
    return pl
end

"""
    metricsplot(tr::YAJP.Trace, timestep::Real, norm::Bool=false, individual::Bool=false)

Returns a [Gadfly] plot depicting `tr`s evolution for load imbalance metric `f` (at every `timestep`) as a [Gadfly] `rectbin`. `norm` will determine if severity plots are normalized. `individual` will prepare plots to be presented separately (containing all labels).
"""
function metricsplot(tr::YAJP.Trace, timestep::Real, norm::Bool=false, individual::Bool=false)
    # line width
    LINEWIDTH = 3pt
    # point size
    POINTSIZE = 3pt
    # major labels font size
    MAJORLABEL = 14pt
    # minor labels font size
    MINORLABEL = 12pt
    # plots container
    plots = Plot[]
    for f in [pimbalance,
              imbalancep,
              imbalancet,
              std,
              skewness,
              kurtosis]
        # retrieve metric
        f in [skewness, kurtosis]?
            mtr = metrics(tr, f, timestep) :
            mtr = metrics(tr, f, timestep, norm)
        # select appropriate metric  y-label
        # and if x-label and ticks label should exist
        if f == pimbalance
            verticallabel = "Percent Imbalance"
            individual?
                horizontallabel = "Time (s)" :
                horizontallabel = nothing
            plotcolor = "blue"
        elseif f == imbalancep
            verticallabel = "Imbalance Percentage"
            individual?
                horizontallabel = "Time (s)" :
                horizontallabel = nothing
            plotcolor = "green"
        elseif f == imbalancet
            norm?
                verticallabel = "Imbalance Time" :
                verticallabel = "Imbalance Time (s)"
            individual?
                horizontallabel = "Time (s)" :
                horizontallabel = nothing
            plotcolor = "red"
        elseif f == std
            norm?
                verticallabel = "Standard Deviation" :
                verticallabel = "Standard Deviation (s)"
            individual?
                horizontallabel = "Time (s)" :
                horizontallabel = nothing
            plotcolor = "orange"
        elseif f == skewness
            verticallabel = "Skewness"
            individual?
                horizontallabel = "Time (s)" :
                horizontallabel = nothing
            plotcolor = "gray"
        else
            verticallabel = "Kurtosis"
            individual?
                horizontallabel = "Time (s)" :
                horizontallabel = nothing
            plotcolor = "purple"
        end
        # plot metric heat map
        push!(plots, plot(mtr[!isnan(mtr[:value]), :],
                     layer(x="midpoint", y="value",
                           Geom.line, order=1),
                     layer(x="midpoint", y="value",
                           Geom.point, order=2),
                     Coord.cartesian(xmin=YAJP.began(tr),
                                     xmax=YAJP.ended(tr)),
                     Guide.xticks(ticks=collect(
                                     convert(Int, floor(YAJP.began(tr))):
                                     convert(Int, round(YAJP.span(tr)/STEPDENOM)):
                                     convert(Int, ceil(YAJP.ended(tr)))),
                                  label=true,
                                  orientation=:horizontal),
                     Guide.xlabel(horizontallabel, orientation=:horizontal),
                     Guide.ylabel(verticallabel, orientation=:vertical),
                     Theme(default_color=parse(Gadfly.Colorant, plotcolor),
                           line_width=LINEWIDTH,
                           default_point_size=POINTSIZE,
                           key_position=:none,
                           major_label_font_size=MAJORLABEL,
                           minor_label_font_size=MINORLABEL)))
    end
    return plots
end

"""
    mergedmetricsplot(tr::YAJP.Trace, timestep::Real)

Returns an array of [Gadfly](https://github.com/dcjones/Gadfly.jl) plots depicting `tr`s evolution for each load imbalance metric (at every `timestep`). Plots are merged: severity and shape metrics are plotted together. Severity metrics are normalized.
"""
function mergedmetricsplot(tr::YAJP.Trace, timestep::Real)
    # line width
    LINEWIDTH = 3pt
    # point size
    POINTSIZE = 3pt
    # key title font size
    KEYTITLE = 12pt
    # key label font size
    KEYLABEL = 10pt
    # major labels font size
    MAJORLABEL = 14pt
    # minor labels font size
    MINORLABEL = 12pt
    # plots container
    plots = Plot[]
    # retrieve metrics
    mtr = stack(metrics(tr, timestep, true),
                [:pimbalance, :imbalancep, :imbalancet,
                :std, :skewness, :kurtosis])
    # severity measures
    push!(plots, plot(mtr[(mtr[:variable] .== :pimbalance) | 
                          (mtr[:variable] .== :imbalancep) | 
                          (mtr[:variable] .== :imbalancet) | 
                          (mtr[:variable] .== :std) & 
                          (!isnan(mtr[:value])), :],
                     layer(x="midpoint", y="value", color="variable",
                           Geom.line, order=1),
                     layer(x="midpoint", y="value", color="variable",
                           Geom.point, order=2),
                     Coord.cartesian(xmin=YAJP.began(tr),
                                     xmax=YAJP.ended(tr),
                                     ymin=0.0,
                                     ymax=1.0),
                     Guide.xticks(ticks=collect(
                                     convert(Int, floor(YAJP.began(tr))):
                                     convert(Int, round(YAJP.span(tr)/STEPDENOM)):
                                     convert(Int, ceil(YAJP.ended(tr)))),
                                  label=true,
                                  orientation=:horizontal),
                     Guide.xlabel("Time (s)", orientation=:horizontal),
                     Guide.ylabel(nothing, orientation=:vertical),
                     Guide.colorkey("Metric"),
                     Theme(line_width=LINEWIDTH,
                           default_point_size=POINTSIZE,
                           key_position=:right,
                           guide_title_position=:center,
                           key_title_font_size=KEYTITLE,
                           key_label_font_size=KEYLABEL,
                           colorkey_swatch_shape=:circle,
                           major_label_font_size=MAJORLABEL,
                           minor_label_font_size=MINORLABEL)))
    # shape measures
    push!(plots, plot(mtr[(mtr[:variable] .== :skewness) | 
                          (mtr[:variable] .== :kurtosis) & 
                          (!isnan(mtr[:value])), :],
                     layer(x="midpoint", y="value", color="variable",
                           Geom.line, order=1),
                     layer(x="midpoint", y="value", color="variable",
                           Geom.point, order=2),
                     Coord.cartesian(xmin=YAJP.began(tr),
                                     xmax=YAJP.ended(tr)),
                     Guide.xticks(ticks=collect(
                                     convert(Int, floor(YAJP.began(tr))):
                                     convert(Int, round(YAJP.span(tr)/STEPDENOM)):
                                     convert(Int, ceil(YAJP.ended(tr)))),
                                  label=true,
                                  orientation=:horizontal),
                     Guide.xlabel("Time (s)", orientation=:horizontal),
                     Guide.ylabel(nothing, orientation=:vertical),
                     Guide.colorkey("Metric"),
                     Theme(line_width=LINEWIDTH,
                           default_point_size=POINTSIZE,
                           key_position=:right,
                           guide_title_position=:center,
                           key_title_font_size=KEYTITLE,
                           key_label_font_size=KEYLABEL,
                           colorkey_swatch_shape=:circle,
                           major_label_font_size=MAJORLABEL,
                           minor_label_font_size=MINORLABEL)))
    return plots
end
