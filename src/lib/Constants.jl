module Constants

export STARPU_CONTAINERS, STARPU_STATES, STARPU_EVENTS, TURING, node

# arrays that contain the container, events, and task names used in each application tested.
const STARPU_CONTAINERS = ["Worker"]
const STARPU_STATES = ["Worker State"]
const STARPU_EVENTS = ["cl11", "cl21", "cl22", "cl22_p",
               "starpu_slu_lu_model_11", "starpu_slu_lu_model_12",
               "starpu_slu_lu_model_21", "starpu_slu_lu_model_22"]

# array describing Worker associativity with NUMA nodes on tested machines
const TURING = Dict{ByteString, Vector{ByteString}}("NUMA1" => ["CPU0", "CPU4", "CPU8", "CPU12", "CPU16", "CPU20", "CPU24", "CPU28"],
                                                    "NUMA2" => ["CPU1", "CPU5", "CPU9", "CPU13", "CPU17", "CPU21", "CPU25", "CPU29"],
                                                    "NUMA3" => ["CPU2", "CPU6", "CPU10", "CPU14", "CPU18", "CPU22", "CPU26", "CPU30"],
                                                    "NUMA4" => ["CPU3", "CPU7", "CPU11", "CPU15", "CPU19", "CPU23", "CPU27", "CPU31"])


# TODO: document
function node(name::AbstractString)
    # search for key to which name is associated
    for key in keys(TURING)
        if name in TURING[key]
            return key
        end
    end
    # return NA if name not found
    return "NA"
end

end
