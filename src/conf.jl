const FIELDS = ["containers", "states", "events", "discard"]

"Checks if YAML config. file represented by `config` is consistent"
function check(path::AbstractString)
    config = YAML.load_file(path)
    for field in FIELDS
        if !haskey(config, field)
            return false
        elseif field == "discard" && typeof(config[field]) != Bool
            return false
        elseif field != "discard" && typeof(config[field]) != Array{Any,1}
            return false
        end
    end
    return true
end

"Returns config. contained in `path`"
function get(path::AbstractString)
    return YAML.load_file(path)
end
