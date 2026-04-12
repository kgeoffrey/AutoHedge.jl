
module AutoHedge

export CallOption, PutOption, UnderlyingStock, Portfolio, backtest, randomwalk, convertdata, hedge, Asset, iter_newton
export value, delta, vega, theta, gamma, vanna, charm, vomma, veta, speed, zomma, color, ultima
using ForwardDiff, Distributions
include("options.jl")
include("utils.jl")
include("simulation.jl")
include("impliedvolatility.jl")

end
