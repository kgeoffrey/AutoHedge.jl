

# AutoHedge.jl
This Julia package provides an implementation of automatic options hedging using automatic differentiation for obtaining the [Greeks](https://en.wikipedia.org/wiki/Greeks_(finance)). The package allows users to easily create and backtest complicated hedging strategies for a portfolio of European Options.

## Installation
To install the package, simply run the following command in the Julia REPL:

```julia
using Pkg
Pkg.add("AutoHedge")
```


## Usage
To use the automatic options hedging functionality provided by this package, you can import the package into your Julia session:

```julia
using AutoHedge
```

### Example #1: Delta Hedging
Say you have a portfolio of 10 call options and you want to make your portfolio [delta neutral](https://en.wikipedia.org/wiki/Delta_neutral). One way of achieving this is to buy or sell specific quantities of underlying stock - this is referred to as Delta Hedging. First create a portfolio, define the asset to be hedged (10 call options), and the array of hedging instruments (the underlying stock) and hedging strategies (delta in this case):

```julia
call_option = CallOption(100, 130., 5., 0.01, 0.2, 0.)
stock = UnderlyingStock()
portfolio = Portfolio(call_option, 10, [stock], ["delta"])
```

CallOption takes the arguments S, K, T, r, v, q - which stand for spot price, strike price, passage of time, risk free rate, volatility and continuously compounded dividend yield. The S, T and q can be random upon initiation, as they will be updated during the simulation. Furthermore it is important that the number of hedging strategies is the same as the number of hedging instruments, this will be explained [later below](#How-does-AutoHedge-work?). Next we simulate the price of the underlying stock:

```julia
using Plots

stock_price = randomwalk(100, 500, 1)
plot(stock_price, xlabel="Time", ylabel="Spot Price")
```
![Picture of Simulated Underlying Price](https://i.imgur.com/5UovmfY.png)

Now that we have the evolution of the stock price of the underlying we can run a backtest of the hedging strategy and obtain the borrowing to fund hedging purchases, holdings of hedging instruments and tracking error over time. For the backtest, we also need to define the rebalancing frequency:

```julia
rebalancing_frequency = 5  # we rebalance every 5 periods
borrowing, volumes, tracking_errors = backtest(stock_price, rebalancing_frequency, portfolio)
```
As simple as that! Next we plot the results:
```julia
plot(borrowing, xlabel="Time", ylabel = "Cash Borrowing")
plot(volumes', xlabel="Time", ylabel = "Volume", labels=permutedims(string.(typeof.(portfolio.hedging_instruments))))
plot(tracking_errors, xlabel="Time", ylabel = "Tracking Error (Value of Portfolio)")
```

![Borrowing](https://i.imgur.com/ShXL0H5.png)

![Volumes](https://i.imgur.com/ARyYimo.png)

![Tracking Error](https://i.imgur.com/eSiDshV.png)

For this example you could experiment with rebalancing frequencies to reduce the tracking error even further. In the next example you see how you can hedge other greeks

### Example #2: Delta-Theta-Vega Hedging

In this example we will construct a portfolio that has neutral Delta, Theta, Charm and Speed. We have 100 call options in our portfolio and need 3 additional hedging instruments for our strategy:

```julia
call_option = CallOption(100, 130., 5., 0.01, 0.2, 0.)

stock = UnderlyingStock()
f1 = CallOption(100., 130., 5., 0.01, 0.2, 0.)
f2 = PutOption(100., 120., 5., 0.01, 0.2, 0.)

portfolio = Portfolio(call_option, 10, [stock, f1, f2], ["delta", "theta", "vega"])
```
We use the same simulated stock price as before and create the backtest:
```julia
rebalancing_frequency = 5
borrowing, volumes, tracking_errors = backtest(stock_price, rebalancing_frequency, portfolio)
```

![Borrwing](https://i.imgur.com/SrvcTyE.png)

![Volumes](https://i.imgur.com/KljWlfz.png)

![Volumes](https://i.imgur.com/GT1s76M.png)

As you can see, depending on how many greeks you want to hedge, borrowing and asset volume can explode. Furthermore you should be wary of the [Moneyness](https://en.wikipedia.org/wiki/Moneyness) of your hedging instruments with regard to the simulated stock price, especially when you select many Greeks to hedge this can lead to numerical errors.


## How does AutoHedge work?

AutoHedge uses [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl) to get the Greeks of European Options. Next a system of linear equations is solved to obtain the cash borrowings, and hedging instrument volumes. The simple Delta-Hedge shown in Example #1 needs to fulfill 2 requirements, where B is the borrowing and $n_{1}$ the volume of stocks purchased:
It needs to be self-financing:
```math
-Nf + n_{1}S - B = 0
```
and it needs to be Delta Neutral as per definition:
```math
-N\Delta + n_{1} * 1 - 0 = 0
```

By rearranging, we can write the equations in matrix form, so they can be solved easily:

```math
Ax = b
```
```math
x = A^{-1} b
```
where,
```math
A = \begin{bmatrix} -1 & S \\ 0 & 1 \end{bmatrix}, b =  \begin{bmatrix} Nf \\ N \Delta \end{bmatrix}, x =  \begin{bmatrix} B  \\ n_{1} \end{bmatrix}  
```

Similarly, we can add other Greeks, but for the A to be invertible and square, we cannot have an overdetermined system (more equations to balance than variables). Thus for each new hedging strategy we need to add a unique hedging instrument to the portfolio. We take Example #2, where we hedge portfolio delta, theta and vega:

```math
A = \begin{bmatrix} -1 & S & f_2 & f_3 \\ 0 & 1  & \Delta_2 & \Delta_3 \\ 0 & 0  & \Theta_2 & \Theta_3 \\ 0 & 0  & \nu_2 & \nu_3
 \end{bmatrix}, b =  \begin{bmatrix} Nf \\ N \Delta_1 \\ N \Theta_1 \\ N \nu_1  \end{bmatrix}, x =  \begin{bmatrix} B  \\ n_{1}  \\ n_{2}  \\ n_{3} \end{bmatrix}  
```


## Contributing
Contributions to this package are welcome! If you find a bug or have a feature request, please create an issue on the GitHub repository. If you would like to contribute code, please fork the repository and create a pull request.

## License
This package is licensed under the [MIT License](https://opensource.org/license/mit/).
