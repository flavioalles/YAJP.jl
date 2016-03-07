const REQUIRED = ["containers", "states"]
const OPTIONAL = ["keep", "discard"]

"Checks if YAML config. file represented by `config` is consistent"
function checkconfig(path::AbstractString)
    config = YAML.load_file(path)
    # check if all REQUIRED fields are present
    for field in REQUIRED
        if !haskey(config, field)
            return false
        end
    end
    # check config fields
    for field in keys(config)
        if !(field in REQUIRED || field in OPTIONAL)
            return false
        elseif typeof(config[field]) != Array{Any,1}
            return false
        end
    end
    return true
end

"Returns config. contained in `path`"
function getconfig(path::AbstractString)
    return YAML.load_file(path)
end
