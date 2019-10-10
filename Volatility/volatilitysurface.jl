## Example of computing and graphing volatility surface

using Pkg
using ForwardDiff, Distributions
using Plots
using Interpolations
using Random
Random.seed!(1234)

## BS functions 

d = Normal()
d1(S,K,T,r,v) = (log(S/K) + (r + v*v/2)*T)/(v*sqrt(T))
d2(S,K,T,r,v) = (log(S/K) + (r - v*v/2)*T)/(v*sqrt(T)) #- v*sqrt(T)
call_price(S,K,T,r,v,q) = S*exp(-q*T)*cdf(d, d1(S,K,T,r,v)) - K*exp(-r*T)*cdf(d, d2(S,K,T,r,v))
put_price(S,K,T,r,v,q) = K*exp(-r*T)*cdf(d, -d2(S,K,T,r,v)) - S*exp(-q*T)*cdf(d, -d1(S,K,T,r,v))

# varying the option price too to make it look more realistic as well
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
    
    market_price = round(rand(Normal(market_price,1)),digits=2)
    if K >= S
        price_v = v -> call_price(S,K,T,r,v,q)
    else
        r = -1*r
        price_v = v -> put_price(S,K,T,r,v,q)
    end
    # price_p = v ->  S*exp(-q*T) + put_price(S,K,T,r,v,q)- K*exp(-r*T)
    vega(v) = ForwardDiff.derivative(price_v, v)
    iter = 0
    v = sigma_0
    delta = price_v(v) - market_price
    while abs(delta) > tolerance && iter < maxiter
        v = v - 0.1*(price_v(v) - market_price) / vega(v)
        delta = price_v(v) - market_price
        iter = iter + 1
        # print("Volatility found was", v)
    end
    return v, iter        
end

# the market price for the option is not very realistic though we get a nice surface 
strike = rand(Normal(180,30),60)
tenor= collect(range(0.5, length=40, stop=8)) # [1:8;]
optionp = round(rand(Normal(75.8,2)),digits=2)
z(strike, tenor) = iter_newton(0.5, 0.000001, 100, 75.8, 178, strike, tenor, 0.0112, 0)[1]

# creating data for scatter plot

function scatterthis()
    points = zeros(60*40, 3)
    this = 1
    # error = []
    for x in strike, y in tenor
        optionp = round(rand(Normal(75.8,2)),digits=2)
        p = iter_newton(0.5, 0.000001, 100, optionp, 178, x, y, 0.0112, 0)[1]
        if p <= 0
            break
        # p[p.>0.0]
        else
            points[this,:] = [x,y,p]
            this += 1
        end
    end
    return points
end

# plotting scatter on top of surface

points = scatterthis()
surface(strike, tenor, z, alpha = 0.3, legend=true, fc=:viridis, grid=true, gridlinewidth=3,
    size = (1200, 700),
    title = "Volatility Surface",
    xlabel = "Strike Price",
    ylabel = "Time to Maturity",
    zlabel = "Volatility")
scatter!(points[:,1], points[:,2], points[:,3], markersize=0.4)


## interpolation method  using cubic splines
# don't use random number in iter_newton

xs = 160:1:230
ys = 0.5:0.1:8
matrix = [z(x, y) for x in xs, y in ys]
interp_cubic = CubicSplineInterpolation((xs, ys), matrix)
interp_cubic(200, 2)
