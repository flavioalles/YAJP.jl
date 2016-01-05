module Constants

export STARPU_CONTAINERS, STARPU_STATES, STARPU_EVENTS

# arrays that contain the container, events, and task names used in each application tested.
const STARPU_CONTAINERS = ["Worker"]
const STARPU_STATES = ["Worker State"]
const STARPU_EVENTS = ["cl11", "cl21", "cl22", "cl22_p",
               "starpu_slu_lu_model_11", "starpu_slu_lu_model_12",
               "starpu_slu_lu_model_21", "starpu_slu_lu_model_22"]


end
