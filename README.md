This repository contains some financial models I implemented in Julia. Especially the package ForwardDiff is really cool and useful for this purpose.

# 1. Finding the Implied Volatility

The Black-Scholes equation for the price of a call option has 5 parametes, usually 4 of them can be observed directly: the price of the option, the maturity, the spot price of the underlying stock and the strike price. The fifth parameter is the (implied) volatility, but we cannot observe it directly. There exists no analytic solution for the implied volatility, luckily the BS-Scholes formula is a monotonicly increasing function of volatility, which means we can use fast (and simple) root finding algorithm like Newton's Method. 
This is very easy to do with the Julia package 'ForwardDiff'([Forwarddiff Paper](https://arxiv.org/abs/1607.07892)), that I will also use to get the other 'Greeks' as shown in the examples below.

### Black-Scholes  

# 2. Volatility Surface
We can plot the Volatility Surface by finding the IV (as described above) from options with the same underlying, but different strike prices and maturities.
Example with simulated options:

![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/volatilitysurface.png "Logo Title Text 1")



You can find an online version here: [Interactive Volatility Surface](https://kgeoffrey.github.io/quantfinance/graph.html)


# 3. Delta Hedging Strategy

Example:

 - Simulating stock price with Gaussian walk (should be geometric Brown. motion) 
 - Rebalancing every 5th day 
 - Delta hedging portfolio consisting of N call options expiring at T = 200
 - Everything constant except for time and spotprice:
    - K = 120
    - r = 0.01
    - q = 0
    - N = 1000 (number of calls)
    
 Stock Price:
 
 ![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/stockprice.png "Logo Title Text 1")
 
 Cash borrowing to finance stock purchase 
 
 ![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/borrow.png "Logo Title Text 1")
 
 Portfolio Value over time
 
 ![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/value.png "Logo Title Text 1")


# 4. Delta-Gamma Hedging Strategy

An even better strategy is to try to hedge against changes in the delta of the derivative (second order derivative; also called Gamma).
For this we bring in a another derivative with the same under lying stock, but a different strike price. 

Example:
 - Same stock price as before
 - Rebalancing every 5th day
 - Delta-Gamma hedging portfolio consisting of N call options expiring at T = 200
 - Everything constant except for time and spotprice: 
   - K1 = 110
   - K2 = 120
   - r = 0.01
   - q = 0
   - N = 1000 (number of calls options with K1)

We can see that the borrowing significantly decreased with the Delta-Gamma hedge:
![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/borrowdeltagamma.png "Logo Title Text 1")

The tracking error is significantly smaller and in this case Delta-Gamma hedging is clearly the superior strategy - in theory. In practice, the leverage and liquidity for the derivatives required would be unrealistic 
![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/valuedeltagamma.png "Logo Title Text 1")

# 5. For fun: Delta-Gamma-Speed Hedging

If you know [Taylor's theorem](https://en.wikipedia.org/wiki/Taylor%27s_theorem) it should come to no surprise that adding more higher order greeks (we also need an additional derivative for each, to be able to solve the system of equations) yields an even better approximation. By adding another derivative we can make our portfolio 'speed' neutral (speed is the 3rd derivative of the call option with respect to price).

Example:
 - Same stock price as before
 - Rebalancing every 5th day
 - Delta-Gamma hedging portfolio consisting of N call options expiring at T = 200
 - Everything constant except for time and spotprice: 
   - K1 = 110
   - K2 = 120
   - r = 0.01
   - q = 0
   - N = 1000 (number of calls options with K1)
   
 The tracking error is super small, but the leverage and liquidity required for each derivative is otherwordly :alien:
