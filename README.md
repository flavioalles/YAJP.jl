## YAJP

`YAJP` is an acronyim for **Y**et **A**nother **J**ulia **P**ackage.

### Requirements

`YAJP` has nothing but a few minor requirements to run. Those are:

* `Julia 0.4` [(Download on julialang.org)](http://julialang.org/downloads/)
* `Distributions.jl` [(Github)](https://github.com/JuliaStats/Distributions.jl)
* `YAML.jl` [(Github)](https://github.com/dcjones/YAML.jl)

### Usage

Currently, `YAJP` is collection of modules (located in `src/lib`) and an application (located in `src/app`). The application - `dump.jl` - is executed as follows:

    julia src/app/dump.jl <csv-trace> <yaml-configuration> [--timestep=#]

