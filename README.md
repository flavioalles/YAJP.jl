## YAJP

`YAJP` is an acronym for **Y**et **A**nother **J**ulia **P**ackage.

It contains methods to parse `csv` dumps of [Pajé](http://paje.sourceforge.net/download/publication/lang-paje.pdf) trace files - obtained with [`pj_dump`](https://github.com/schnorr/pajeng/wiki/pj_dump) - and extract information regarding the execution registered in these traces.

### Requirements

`YAJP` has nothing but a few minor requirements to run. Those are:

* `Julia 0.4` ([Download on julialang.org)](http://julialang.org/downloads/))
* `DataFrames.jl` ([GitHub](https://github.com/JuliaStats/DataFrames.jl))
* `Distributions.jl` ([GitHub](https://github.com/JuliaStats/Distributions.jl))
* `YAML.jl` ([(GitHub)](https://github.com/dcjones/YAML.jl))

Details regarding the floor version expected for each required package can be found in [`REQUIRE`](REQUIRE).

### Installation

To install `YAJP` simply type the following in a Julia REPL:

    julia> Pkg.clone("https://github.com/flavioalles/YAJP.jl")

As noted previously, the minimum Julia version required is `v0.4`. The package requirements are resolved by Julia's package manager (thus, there is no need in installing them manually).

### Organization

`YAJP` consists in a collection of methods to parse and analyze - offline - traced parallel application executions. Currently, `YAJP` can only parse `csv` files obtained by running [`pj_dump`](https://github.com/schnorr/pajeng/wiki/pj_dump) on [Pajé](http://paje.sourceforge.net/download/publication/lang-paje.pdf) trace files. The following subsections provide a brief description of how the code is organized.

#### `conf.jl`

`conf.jl` - located in `src/conf.jl` - verifies if a [`YAML`](https://en.wikipedia.org/wiki/YAML) - used as configuration for the `csv` parser - located in `src/parse.jl` - contains the expected fields and, also, if those fields are properly defined.

The expected fields are:

* `containers`: list that defines what container types one is interested in.
* `states`: list, once again, that defines which types of states - found within the container types defined in `containers` - should be parsed.
* `events`: also a list; it determines the names of the `states` one is interested in keeping or discarding - depending on the value of `discard` (see next field).
* `discard`: should be set to `true` or `false`. If `true`, the `events` listed in the corresponding field will be the ones that are kept for the analysis. Otherwise, if `false`, those `events` will be discarded and every event of a type listed in `states` found in a container of a type listed in `containers` not present in the `events` list will be kept for the subsequent data analysis.

An example `YAML` configuration file can be found at `conf/dump.yaml`.

#### `data.jl`

`data.jl` - located in `src/data.jl` - defines types and methods that operate on those types. The types defined mirror some of the types defined in the [Pajé trace format](http://paje.sourceforge.net/download/publication/lang-paje.pdf).

* `Trace`: top level type that consists simply of an array of `Container`s.
* `Container`: type that represents a container. It is composed of a name, a beginning and an ending timestamp, as well as list of `Event`s.
* `Event`: type representing an individual event execution.

Further information about the types can be found in the source code (`src/data.jl`).

#### `dump.jl`

`dump.jl` - `src/parse.jl` - provides methods that gather information on a parsed trace and return that information as a `DataFrame`. There are three different methods:

* `events`: simply returns every event parsed from the trace.
* `loads`: this method contains two implementations; the first, which expects a single argument - of type `Trace` - returns the aggregated load in every resource - `Container`, as defined in `src/data.jl` - contained in the `Trace`; the second implementation, expects, in addition to the object of type `Trace`, expects an `Int` that will define the timestep - that is, the size of the intervals into which the `Trace` will be divided and loads will be gathered for.
* `metrics`: this method also contains two implementations; once again, the first, which expects a single argument - of type `Trace` - returns the values for different load balancing metrics for the aggregated load in every resource - `Container`, as defined in `src/data.jl` - contained in the `Trace`; the second implementation, expects, in addition to the object of type `Trace`, expects an `Int` that will define the timestep - that is, the size of the intervals into which the `Trace` will be divided and the metrics will be calculated for.

For the metrics that are returned in the `metrics` methods, refer to the `load.jl` section (below).

#### `load.jl`

`load.jl` - `src/load.jl` - contains methods to calculate six different load balancing metrics. Those are:

* Standard Deviation
* Skewness
* Kurtosis
* Percent Imbalance [[Pearce et al, 2012][Pearce et al, 2012]]
* Imbalance Percentage [[Pearce et al, 2012][DeRose et al, 2007]]
* Imbalance Time [[Pearce et al, 2012][DeRose et al, 2007]]

Each load balancing metric contains two implementations. One that expects a single argument - of type `Trace` - and returns the value for the load balancing metric considering the aggregated load in every resource - `Container`, as defined in `src/data.jl` - contained in the `Trace`; the second implementation, expects, in addition to the object of type `Trace`, expects an `Int` that will define the timestep - that is, the size of the intervals into which the `Trace` will be divided and the metric will be calculated for.

[Pearce et al, 2012]: http://dl.acm.org/citation.cfm?id=2304601
[DeRose et al, 2007]: http://link.springer.com/chapter/10.1007/978-3-540-74466-5_17

#### `parse.jl`

`parse.jl` - `src/parse.jl` - contains a single method - `trace` - that is responsible for parsing a `csv` trace - the first argument - according to a configuration file - the second, and last, argument (more about this in the section explaining `conf.jl`). The method returns a `Trace` object as a result - defined in `src/data.jl`.

