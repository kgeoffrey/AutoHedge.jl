### Finding the implied volatility with Newton's Methed

using ForwardDiff, Distributions

## Seting up the Black-Scholes formulas for value of call and put:

d = Normal()
d1(S,K,T,r,v) = (log(S/K) + (r + v*v/2)*T)/(v*sqrt(T))
d2(S,K,T,r,v) = (log(S/K) + (r + v*v/2)*T)/(v*sqrt(T)) - v*sqrt(T)
call_price(S,K,T,r,v,q) = S*exp(-q*T)*cdf(d, d1(S,K,T,r,v)) - K*exp(-r*T)*cdf(d, d2(S,K,T,r,v))
put_price(S,K,T,r,v,q) = K*exp(-r*T)*cdf(d, -d2(S,K,T,r,v)) - S*exp(-q*T)*cdf(d, -d1(S,K,T,r,v))

## Newton–Raphson method for finding roots (here it is the difference between the call option's market value and our guess)

function iter_newton(sigma_0, tolerance, maxiter,market_price, S, K, T, r, q=0)
    #sigma_0: initial guess for sigma, 0.5 recommended
    #tolerance: precision of approximation
    #maxiter: set maximum iteration of algorithm
    #market_price: market price of the option 
    #S: spot price
    #K: strike price
    #T: time to maturity
    #r: interest rate
    #q: dividends paid, set to 0
    
    price_v = v -> call_price(S,K,T,r,v,q)
    vega(v) = ForwardDiff.derivative(price_v, v)
    iter = 0
    v = sigma_0
    delta = price_v(v) - market_price
    while abs(delta) > tolerance && iter < maxiter
        v = v + (market_price - price_v(v)) / vega(v)
        delta = price_v(v) - market_price
        iter = iter + 1
    end
    return v, iter        
end



## Example:
# S = 178
# K = 97
# T = 0.47
# r = 0.0112
# q = 0

# @time iter_newton(0.5, 0.000001, 1000, 0.01,85, 183, 1.4, 0.0379, 0)
