module Load

using Data, Distributions

export pimbalance, imbalancep, imbalancet

import Base: std
import Distributions: skewness, kurtosis

"Returns the **Standard Deviation** among the loads in `tr`s containers"
function std(tr::Trace)
    return std(map(load, tr.containers))
end

"Returns the **Skewness** of the loads in `tr`s containers"
function skewness(tr::Trace)
    return skewness(map(load, tr.containers))
end

"Returns the **Kurtosis** of the loads in `tr`s containers"
function kurtosis(tr::Trace)
    return kurtosis(map(load, tr.containers))
end

"Returns the **Percent Imbalance** of the loads of `tr`s containers"
function pimbalance(tr::Trace)
    loads = map(load, tr.containers)
    return ((maximum(loads)/mean(loads)) - 1)*100
end

"Returns the **Imbalance Percentage** of the loads of `tr`s containers"
function imbalancep(tr::Trace)
    loads = map(load, tr.containers)
    return ((maximum(loads) - mean(loads))/maximum(loads))*(length(loads)/(length(loads) - 1))
end

"Returns the **Imbalance Time** of the loads of `tr`s containers"
function imbalancet(tr::Trace)
    loads = map(load, tr.containers)
    return maximum(loads) - mean(loads)
end

end
