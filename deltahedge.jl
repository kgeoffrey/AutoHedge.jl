## simulating a delta hedge strategy

using ForwardDiff, Distributions
using Plots

## Seting up the Black-Scholes formulas for value of call and put:
d = Normal()
d1(S,K,T,r,v) = (log(S/K) + (r + v*v/2)*T)/(v*sqrt(T))
d2(S,K,T,r,v) = (log(S/K) + (r + v*v/2)*T)/(v*sqrt(T)) - v*sqrt(T)
call_price(S,K,T,r,v,q) = S*exp(-q*T)*cdf(d, d1(S,K,T,r,v)) - K*exp(-r*T)*cdf(d, d2(S,K,T,r,v))
put_price(S,K,T,r,v,q) = K*exp(-r*T)*cdf(d, -d2(S,K,T,r,v)) - S*exp(-q*T)*cdf(d, -d1(S,K,T,r,v))

## Random walk 
function walk(start, len, num_walks)
    A = zeros(len, num_walks)
    for i in 1:num_walks
        gaussian_walk = zeros(len)
        gaussian_walk[1] = rand(Normal(start, rand(Normal(2,1))))
        for n=2:length(gaussian_walk)
            gaussian_walk[n] = gaussian_walk[n-1] + rand(Normal())
        end
        G = gaussian_walk
        A[:,i] = G
    end
    return A
end

## records the amount borrowed and the shares bought
function deltahedge(price, freq)
    freqlist = convertdata(price, freq)
    borrow = Any[]
    shares = Any[]
    delta_old = 0
    B_old = 0
    for (i,S) in enumerate(price)
        T = (length(price) - i)/365
        if price[i] == freqlist[i]
            price_s = S -> call_price(S,K,T,r,v,q)
            delta(S) = ForwardDiff.derivative(price_s, S)
            B = N*(delta(S)*S - call_price(S,K,T,r,v,q))
            append!(borrow,B)
            append!(shares, N*(delta(S)- delta_old))
            delta_old = delta(S)
            B_old = B
        else
            append!(borrow,B_old)
        end
    end
    return borrow, shares
end

## computes the portfolio value
function trackingerror(price, B, freq)
    freqlist = convertdata(price, freq)
    values = []
    lag_delta = 0
    for (i,S) in enumerate(price)
        T = (length(price) - i)/365
        price_s = S -> call_price(S,K,T,r,v,q)
        delta(S) = ForwardDiff.derivative(price_s, S)
        if price[i] == freqlist[i]
            price_s = S -> call_price(S,K,T,r,v,q)
            delta(S) = ForwardDiff.derivative(price_s, S)
            value = N*(delta(S)*S - call_price(S,K,T,r,v,q)) - B[i]*exp(r/365)
            append!(values,value)
            lag_delta = delta(S)
        else
            value = N*(lag_delta*S - call_price(S,K,T,r,v,q)) - B[i]*exp(r/365)
            append!(values,value)
        end
    end
    return values
end

## Helper for rebalancing 
function convertdata(test, freq)
    function remove!(a, item)
        deleteat!(a, findall(x->x==item, a))
    end
    newlist = []
    new = test[1:freq:end]
    rebalance = 0
    for (i,v) in enumerate(test)
        if test[i] in new
            append!(newlist, v)
            rebalance = v
            remove!(new,[test[i]])
        else
            append!(newlist, rebalance)
        end
    end
    return newlist
end


## parameter values for plotting
K = 120
r = 0.01
q = 0
v = 0.20
N = 1000

# Stock price
test= walk(100,200,1)
plot(test, xlabel = "Time", ylabel = "Spot Price of Stock")

# Borrowing
plot(deltahedge(test, 5)[1], xlabel = "Time", ylabel = "Cash borrowed in each period")

# Tracking error
plot(trackingerror(test, borrow, frequ), xlabel = "Time", ylabel = "Tracking Error (Value of Portfolio)")
