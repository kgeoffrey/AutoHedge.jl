include("../src/AutoHedge.jl")
using .AutoHedge
#using AutoHedge


f1 = CallOption(100., 130., 5., 0.01, 0.2, 0.)
f2 = CallOption(100., 140., 5., 0.01, 0.2, 0.)
f3 = CallOption(100., 115., 5., 0.01, 0.2, 0.)
f4 = PutOption(100., 120., 5., 0.01, 0.2, 0.)
stock = UnderlyingStock() #(100., 0, 0)
p = Portfolio(f1, 10, [stock, f2, f4], ["delta", "theta", "vanna"])

stock_price = randomwalk(100, 500, 1)
rebalancing_frequency = 5
borrowing, volumes, tracking_errors = backtest(stock_price, rebalancing_frequency, p)


# plots
#s1 = plot(stock_price, xlabel="Time", ylabel = "Spot Price")
#s2 = plot(tracking_errors, xlabel="Time", ylabel = "Tracking Error (Value of Portfolio)")
#s3 = plot(volumes, labels=permutedims(string.(typeof.(p.hedging_instruments))), xlabel="Time", ylabel = "Volume")
#s4 = plot(borrowing, xlabel="Time", ylabel = "Cash Borrowing")
