using Distributions
using Plots
using HigherOrderDerivatives
using LinearAlgebra

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


function simulate_deltahedge(price, freq)
    freqlist = convertdata(price, freq)
    borrow = Any[]
    shares = Any[]
    delta_old = 0
    B_old = 0

    price_s = S -> call_price(S,K,T,r,v,q)
    delta(S) = ForwardDiff.derivative(price_s, S)

    for (i,S) in enumerate(price)
        T = (length(price) - i)/365
        if price[i] == freqlist[i]

            B = N*(delta_(S,K,T,r,v,q)*S - call_price(S,K,T,r,v,q))
            append!(borrow,B)
            append!(shares, N*(delta_(S,K,T,r,v,q)- delta_old))
            delta_old = delta_(S,K,T,r,v,q)
            B_old = B
        else
            append!(borrow,B_old)
        end
    end
    return borrow, shares
end


function hedge_portfolio_(Ks::Vector{Int64}, T)
    mat = zeros(length(Ks), length(Ks))
    mat[1,1] = 1.0
    b = Vector{Float64}(undef,length(Ks))

    for i in 2:length(Ks)
        for j in 1:length(Ks)
            closure = x -> call_price(x,Ks[j],T,r,v,q)
            mat[j, i] = derivative(closure, Ks[i], j)
        end
    end
    for j in 1:length(Ks)
        closure = x -> call_price(x,Ks[1],T,r,v,q)
        b[j] = derivative(closure, Ks[1], j)
    end
    return mat\float.(b)
end

closure = x -> call_price(x,K,T,r,v,q)
t = [12, 13, 19]
hedge_portfolio_(t, closure)


function simulate_deltahedge_(price::Array{Float64, 2}, freq, Ks)
    freqlist = convertdata(price, freq)
    borrow = Any[]
    shares = Any[]
    delta_old = zeros(length(Ks))
    B_old = 0

    #Ks = [12, 13, 19]
    val = Vector{Float64}(undef,length(Ks))
    N=100

    for (i,S) in enumerate(price)
        T = (length(price) - i)/365
        if price[i] == freqlist[i]

            val[1] = S
            for i in 2:length(Ks)
                print(Ks[i])
                val[i] = call_price(S, Ks[i], T, r, v, q)
            end

            closure = x -> call_price(x,K,T,r,v,q)

            w = hedge_portfolio_(Ks, T)
            B = N*(dot(val, w) - call_price(S, Ks[1], T, r, v, q))
            append!(borrow,B)
            append!(shares, N*(dot(val, w) .- delta_old))
            delta_old = dot(val, w)
            B_old = B
        else
            append!(borrow, B_old)
        end
    end
    return borrow, shares
end



g = [1]

for x in 2:length(g)
    print(x)
end



#test= walk(100,200,1)
#plot(test, xlabel = "Time", ylabel = "Spot Price of Stock")

#T=100
K = 150 #test[1]
r = 0.01
q = 0
v = 0.20
N = 1000

Ks = [12]

test= walk(100,400,1)
plot(test, xlabel = "Time", ylabel = "Spot Price of Stock")
plot(simulate_deltahedge_(test, 3, [170, 150])[1], xlabel = "Time", ylabel = "Cash borrowed in each period")


plot(simulate_deltahedge_(test, 5, [10, 140])[2], xlabel = "Time", ylabel = "Cash borrowed in each period")
