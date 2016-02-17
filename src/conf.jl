const FIELDS = ["containers", "states", "keep", "discard"]

"Checks if YAML config. file represented by `config` is consistent"
function checkconfig(path::AbstractString)
    config = YAML.load_file(path)
    for field in FIELDS
        if !haskey(config, field)
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
