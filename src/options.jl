using ForwardDiff, Distributions

## Seting up the Black-Scholes formulas for value of call and put:
d1(S::Any,K::Float64,T::Any,r::Float64,v::Any) = (log(S / K) + (r + v * v / 2) * T) / (v * sqrt(T))
d2(S::Any,K::Float64,T::Any,r::Float64,v::Any) = (log(S / K) + (r + v * v / 2) * T) / (v * sqrt(T)) - v * sqrt(T)

function calloptionprice(S::Any, K::Float64, T::Any, r::Float64, v::Any, q::Float64)
    return S * exp(-q * T) * cdf(Normal(), d1(S, K, T, r, v)) - K * exp(-r * T) * cdf(Normal(), d2(S ,K ,T , r, v))
end

function putoptionprice(S::Any, K::Float64, T::Any, r::Float64, v::Any, q::Float64)
    return K * exp(-r * T) * cdf(Normal(), -d2(S, K, T, r, v)) - S * exp(-q * T) * cdf(Normal(), -d1(S, K, T, r, v))
end

abstract type Asset end

mutable struct CallOption <: Asset
    S::Float64
    K::Float64
    T::Float64
    r::Float64
    v::Float64
    q::Float64

    value::Function

    delta::Function
    vega::Function
    theta::Function

    gamma::Function
    vanna::Function
    charm::Function

    vomma::Function
    veta::Function

    ## 3rd order greeks
    speed::Function
    zomma::Function
    color::Function

    ultima::Function

    function CallOption(S::Any, K::Float64, T::Any, r::Float64, v::Any, q::Float64)
        #closure_ = S -> calloptionprice(S, K, T, r, v, q)
        #value based
        value(S, T, v) = calloptionprice(S, K, T, r, v, q)

        delta(x, T, v) = ForwardDiff.derivative(S -> value(S, T, v), x)
        vega(S, T, x) = ForwardDiff.derivative(v -> value(S, T, v), x)
        theta(S, x, v) = ForwardDiff.derivative(T -> value(S, T, v), x)

        #delta based
        gamma(x, T, v) = ForwardDiff.derivative(x -> delta(x, T, v), x)
        vanna(S, T, x) = ForwardDiff.derivative(x -> delta(S, T, x), x)
        charm(S, x, v) = ForwardDiff.derivative(x -> delta(S, x, v), x)

        #vega based
        vomma(S, T, x) = ForwardDiff.derivative(x -> vega(S, T, x), x)
        veta(S, x, v) = ForwardDiff.derivative(x -> vega(S, x, v), x)

        #gamma based
        speed(x, T, v) = ForwardDiff.derivative(x -> gamma(x, T, v), x)
        zomma(S, T, x) = ForwardDiff.derivative(x -> gamma(S, T, x), x)
        color(S, x, v) = ForwardDiff.derivative(x -> gamma(S, x, v), x)

        #vomma based
        ultima(S, T, x) = ForwardDiff.derivative(x -> vomma(S, T, x), x)

        new(S, K, T, r, v, q, value, delta, vega, theta, gamma, vanna, charm, vomma, veta, speed, zomma, color, ultima)
    end
end

mutable struct PutOption <: Asset
    S::Float64
    K::Float64
    T::Float64
    r::Float64
    v::Float64
    q::Float64

    value::Function

    delta::Function
    vega::Function
    theta::Function

    gamma::Function
    vanna::Function
    charm::Function

    vomma::Function
    veta::Function

    ## 3rd order greeks
    speed::Function
    zomma::Function
    color::Function

    ultima::Function

    function PutOption(S::Any, K::Float64, T::Any, r::Float64, v::Any, q::Float64)
        #closure_ = S -> calloptionprice(S, K, T, r, v, q)
        #value based
        value(S, T, v) = putoptionprice(S, K, T, r, v, q)

        delta(x, T, v) = ForwardDiff.derivative(S -> value(S, T, v), x)
        vega(S, T, x) = ForwardDiff.derivative(v -> value(S, T, v), x)
        theta(S, x, v) = ForwardDiff.derivative(T -> value(S, T, v), x)

        #delta based
        gamma(x, T, v) = ForwardDiff.derivative(x -> delta(x, T, v), x)
        vanna(S, T, x) = ForwardDiff.derivative(x -> delta(S, T, x), x)
        charm(S, x, v) = ForwardDiff.derivative(x -> delta(S, x, v), x)

        #vega based
        vomma(S, T, x) = ForwardDiff.derivative(x -> vega(S, T, x), x)
        veta(S, x, v) = ForwardDiff.derivative(x -> vega(S, x, v), x)

        #gamma based
        speed(x, T, v) = ForwardDiff.derivative(x -> gamma(x, T, v), x)
        zomma(S, T, x) = ForwardDiff.derivative(x -> gamma(S, T, x), x)
        color(S, x, v) = ForwardDiff.derivative(x -> gamma(S, x, v), x)

        #vomma based
        ultima(S, T, x) = ForwardDiff.derivative(x -> vomma(S, T, x), x)

        new(S, K, T, r, v, q, value, delta, vega, theta, gamma, vanna, charm, vomma, veta, speed, zomma, color, ultima)
    end
end

mutable struct UnderlyingStock <: Asset
    #S::Float64
    #T::Float64
    #q::Float64

    value::Function

    delta::Function
    vega::Function
    theta::Function

    gamma::Function
    vanna::Function
    charm::Function

    vomma::Function
    veta::Function

    ## 3rd order greeks
    speed::Function
    zomma::Function
    color::Function

    ultima::Function

    function UnderlyingStock()
        #closure_ = S -> calloptionprice(S, K, T, r, v, q)
        #value based
        value(S, T, v) = S

        delta(S, T, v) = 1
        vega(S, T, v) = 0
        theta(S, T, v) = 0

        #delta based
        gamma(S, T, v) = 0
        vanna(S, T, v) = 0
        charm(S, T, v) = 0

        #vega based
        vomma(S, T, v) = 0
        veta(S, T, v) = 0

        #gamma based
        speed(S, T, v) = 0
        zomma(S, T, v) = 0
        color(S, T, v) = 0

        #vomma based
        ultima(S, T, v) = 0

        new(value, delta, vega, theta, gamma, vanna, charm, vomma, veta, speed, zomma, color, ultima)
    end
end

mutable struct Portfolio
    f::Asset
    N::Int64
    hedging_instruments::Array{<:Asset}
    greeks::Array{String}
    function Portfolio(f::Asset, N::Int64, hedging_instruments::Array{<:Asset}, greeks::Array{String})
        @assert length(hedging_instruments) == length(greeks) "The number of hedging instruments needs to be the same as the number of greeks"
        new(f, N, hedging_instruments, greeks)
    end
end
