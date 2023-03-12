
module AutoHedge

export CallOption, PutOption, UnderlyingStock, Portfolio, backtest, randomwalk, convertdata, hedge, Asset
using ForwardDiff, Distributions
include("options.jl")
include("simulation.jl")
include("utils.jl")

end
