## Simulating Delta-Gamma Hedging strategy

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
test= walk(100,200,1)

## Helper function
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

function DGhedge(price, freq)
    freqlist = convertdata(price, freq)
    borrow = Any[]
    B_old = 0
    for (i,S) in enumerate(price)
        T = (length(price) - i)/365
        if price[i] == freqlist[i]
            price_s1 = S -> call_price(S,K1,T,r,v,q)
            price_s2 = S -> call_price(S,K2,T,r,v,q)
            delta1(S) = ForwardDiff.derivative(price_s1, S)
            gamma1(S) = ForwardDiff.derivative(delta1, S)
            delta2(S) = ForwardDiff.derivative(price_s2, S)
            gamma2(S) = ForwardDiff.derivative(delta2, S)
            n2 = N*(gamma1(S)/gamma2(S))
            n1 = N*delta1(S) - n2*(delta2(S))
            B = n1*S + n2*call_price(S,K2,T,r,v,q) - N*call_price(S,K1,T,r,v,q)
            append!(borrow,B)
            B_old = B
        else
            append!(borrow,B_old)
        end
    end
    return borrow
end

## Tracking error / Value of Delta-Gamma hedged portfolio 
function DGvalue(price, B, freq)
    freqlist = convertdata(price, freq)
    values = []
    n1_old = 0
    n2_old = 0
    for (i,S) in enumerate(price)
        T = (length(price) - i)/365
        if price[i] == freqlist[i]
            price_s1 = S -> call_price(S,K1,T,r,v,q)
            price_s2 = S -> call_price(S,K2,T,r,v,q)
            delta1(S) = ForwardDiff.derivative(price_s1, S)
            gamma1(S) = ForwardDiff.derivative(delta1, S)
            delta2(S) = ForwardDiff.derivative(price_s2, S)
            gamma2(S) = ForwardDiff.derivative(delta2, S)
            n2 = N*(gamma1(S)/gamma2(S))
            n1 = N*delta1(S) - n2*(delta2(S))
            value = n1*S + n2*call_price(S,K2,T,r,v,q) - N*call_price(S,K1,T,r,v,q) - B[i]*exp(r/365)
            append!(values,value)
            n1_old = n1
            n2_old = n2
        else
            value = n1_old*S + n2_old*call_price(S,K2,T,r,v,q) - N*call_price(S,K1,T,r,v,q) - B[i]*exp(r/365)
            append!(values,value)
        end
    end
    return values
end

# Example
K1 = 120
K2 = 140
r = 0.01
q = 0
v = 0.20
N = 1000

plot(DGhedge(test, 5), xlabel = "Time", ylabel = "Cash borrowed in each period")
frequ = 5
borrow= DGhedge(test, frequ)
plot(DGvalue(test, borrow, frequ), xlabel = "Time", ylabel = "Tracking Error (Value of Portfolio)")
