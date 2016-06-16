# integer used as step in xticks def.
STEPDENOM = 30

"""
    loadplot(tr::YAJP.Trace, timestep::Real...)

Returns a container of [Gadfly] plots depicting `tr`s normalized load evolution (at every `timestep`) as a [Gadfly] `rectbin`s.
"""
function loadplot(tr::YAJP.Trace, timestep::Real...)
    if length(timestep) == 1
        # major labels font size
        MAJORLABEL = 18pt
        # minor labels font size
        MINORLABEL = 12pt
        # key title font size
        KEYTITLE = 14pt
        # key label font size
        KEYLABEL = 14pt
    else
        # major labels font size
        MAJORLABEL = 12pt
        # minor labels font size
        MINORLABEL = 8pt
        # key title font size
        KEYTITLE = 12pt
        # key label font size
        KEYLABEL = 12pt
    end
    # plots container
    plots = Plot[]
    for (id,ts) in enumerate(timestep)
        # get loads
        lds = loads(tr, ts)
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
        if id != length(timestep)
            horizontallabel = nothing
        else
            horizontallabel = "Time (s)"
        end
        # plot heat map of load evolution per resource
        push!(plots,
                   plot(lds, x="midpoint", y="container", color="normalized",
                   Geom.rectbin,
                   Coord.cartesian(xmin=YAJP.began(tr), xmax=YAJP.ended(tr)),
                   Guide.xticks(ticks=collect(
                                    convert(Int, floor(YAJP.began(tr))):
                                    convert(Int, round(YAJP.span(tr)/STEPDENOM)):
                                    convert(Int, ceil(YAJP.ended(tr)))),
                                label=true,
                                orientation=:horizontal),
                   Guide.xlabel(horizontallabel, orientation=:horizontal),
                   Guide.ylabel("Resource", orientation=:vertical),
                   Scale.color_continuous(minvalue=0.0, maxvalue=1.0),
                   Guide.colorkey("Load"),
                   Theme(guide_title_position=:center,
                        major_label_font_size=MAJORLABEL,
                        minor_label_font_size=MINORLABEL,
                        key_title_font_size=KEYTITLE,
                        key_label_font_size=KEYLABEL)))
    end
    return plots
end

"""
    metricsplot(tr::YAJP.Trace, timestep::Real)

Returns a [Gadfly] plot depicting `tr`s evolution for load imbalance metric `f` (at every `timestep`) as a [Gadfly] `rectbin`.
"""
function metricsplot(tr::YAJP.Trace, timestep::Real)
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
        mtr = metrics(tr, f, timestep)
        # select appropriate metric  y-label
        # and if x-label and ticks label should exist
        if f == pimbalance
            verticallabel = "Percent Imbalance"
            horizontallabel = nothing
            plotcolor = "blue"
        elseif f == imbalancep
            verticallabel = "Imbalance Percentage"
            horizontallabel = nothing
            plotcolor = "green"
        elseif f == imbalancet
            verticallabel = "Imbalance Time (s)"
            horizontallabel = nothing
            plotcolor = "red"
        elseif f == std
            verticallabel = "Standard Deviation (s)"
            horizontallabel = nothing
            plotcolor = "orange"
        elseif f == skewness
            verticallabel = "Skewness"
            horizontallabel = nothing
            plotcolor = "yellow"
        else
            verticallabel = "Kurtosis"
            horizontallabel = "Time (s)"
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
    return vstack(plots)
end

"""
    metricsplot(tr::YAJP.Trace, f::Function, timestep::Real...)

Returns [Gadfly] plots - as many as there are `timestep`'s - depicting `tr`s evolution for load imbalance metric `f` (at every `timestep`).
"""
function metricsplot(tr::YAJP.Trace, f::Function, timestep::Real...)
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
    for (id,ts) in enumerate(timestep)
        # retrieve metric
        mtr = metrics(tr, f, ts)
        # select appropriate metric  y-label
        # and if x-label and ticks label should exist
        if f == pimbalance
            verticallabel = "Percent Imbalance"
            plotcolor = "blue"
        elseif f == imbalancep
            verticallabel = "Imbalance Percentage"
            plotcolor = "green"
        elseif f == imbalancet
            verticallabel = "Imbalance Time (s)"
            plotcolor = "red"
        elseif f == std
            verticallabel = "Standard Deviation (s)"
            plotcolor = "orange"
        elseif f == skewness
            verticallabel = "Skewness"
            plotcolor = "yellow"
        else
            verticallabel = "Kurtosis"
            plotcolor = "purple"
        end
        # horizontal label?
        if id != length(timestep)
            horizontallabel = nothing
        else
            horizontallabel = "Time (s)"
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
