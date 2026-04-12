using ForwardDiff, Distributions

const _GREEK_NAMES = (
    :value,
    :delta,
    :vega,
    :theta,
    :gamma,
    :vanna,
    :charm,
    :vomma,
    :veta,
    :speed,
    :zomma,
    :color,
    :ultima,
)

const _HEDGEABLE_GREEKS = Tuple(name for name in _GREEK_NAMES if name != :value)

## Setting up the Black-Scholes formulas for value of call and put:
_d1(S::Real, K::Real, T::Real, r::Real, v::Real) = (log(S / K) + (r + v * v / 2) * T) / (v * sqrt(T))
_d2(S::Real, K::Real, T::Real, r::Real, v::Real) = _d1(S, K, T, r, v) - v * sqrt(T)

function calloptionprice(S::Real, K::Real, T::Real, r::Real, v::Real, q::Real)
    return S * exp(-q * T) * cdf(Normal(), _d1(S, K, T, r, v)) - K * exp(-r * T) * cdf(Normal(), _d2(S, K, T, r, v))
end

function putoptionprice(S::Real, K::Real, T::Real, r::Real, v::Real, q::Real)
    return K * exp(-r * T) * cdf(Normal(), -_d2(S, K, T, r, v)) - S * exp(-q * T) * cdf(Normal(), -_d1(S, K, T, r, v))
end

abstract type Asset end

"""
    CallOption(S, K, T, r, v, q)

European call option parameterized by spot `S`, strike `K`, time to maturity `T`,
risk-free rate `r`, volatility `v`, and continuous dividend yield `q`.
"""
struct CallOption <: Asset
    S::Float64
    K::Float64
    T::Float64
    r::Float64
    v::Float64
    q::Float64
end

CallOption(S::Real, K::Real, T::Real, r::Real, v::Real, q::Real) =
    CallOption(Float64(S), Float64(K), Float64(T), Float64(r), Float64(v), Float64(q))

"""
    PutOption(S, K, T, r, v, q)

European put option parameterized by spot `S`, strike `K`, time to maturity `T`,
risk-free rate `r`, volatility `v`, and continuous dividend yield `q`.
"""
struct PutOption <: Asset
    S::Float64
    K::Float64
    T::Float64
    r::Float64
    v::Float64
    q::Float64
end

PutOption(S::Real, K::Real, T::Real, r::Real, v::Real, q::Real) =
    PutOption(Float64(S), Float64(K), Float64(T), Float64(r), Float64(v), Float64(q))

"""
    UnderlyingStock()

Simple underlying asset used as a hedging instrument. Its value is the spot price,
with unit delta and zero higher-order Greeks.
"""
struct UnderlyingStock <: Asset
end

"""
    value(asset, S, T, v)

Return the model value of `asset` at spot `S`, time to maturity `T`, and volatility `v`.
"""
value(option::CallOption, S::Real, T::Real, v::Real) = calloptionprice(S, option.K, T, option.r, v, option.q)
value(option::PutOption, S::Real, T::Real, v::Real) = putoptionprice(S, option.K, T, option.r, v, option.q)
value(::UnderlyingStock, S::Real, T::Real, v::Real) = S

"""
    delta(asset, S, T, v)

Return the first derivative of asset value with respect to spot.
"""
delta(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> value(asset, x, T, v), S)

"""
    vega(asset, S, T, v)

Return the first derivative of asset value with respect to volatility.
"""
vega(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> value(asset, S, T, x), v)

"""
    theta(asset, S, T, v)

Return the first derivative of asset value with respect to time to maturity.
"""
theta(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> value(asset, S, x, v), T)

"""
    gamma(asset, S, T, v)

Return the second derivative of asset value with respect to spot.
"""
gamma(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> delta(asset, x, T, v), S)

"""
    vanna(asset, S, T, v)

Return the mixed derivative of delta with respect to volatility.
"""
vanna(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> delta(asset, S, T, x), v)

"""
    charm(asset, S, T, v)

Return the mixed derivative of delta with respect to time to maturity.
"""
charm(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> delta(asset, S, x, v), T)

"""
    vomma(asset, S, T, v)

Return the second derivative of value with respect to volatility.
"""
vomma(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> vega(asset, S, T, x), v)

"""
    veta(asset, S, T, v)

Return the mixed derivative of vega with respect to time to maturity.
"""
veta(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> vega(asset, S, x, v), T)

"""
    speed(asset, S, T, v)

Return the third derivative of value with respect to spot.
"""
speed(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> gamma(asset, x, T, v), S)

"""
    zomma(asset, S, T, v)

Return the mixed derivative of gamma with respect to volatility.
"""
zomma(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> gamma(asset, S, T, x), v)

"""
    color(asset, S, T, v)

Return the mixed derivative of gamma with respect to time to maturity.
"""
color(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> gamma(asset, S, x, v), T)

"""
    ultima(asset, S, T, v)

Return the third derivative of value with respect to volatility.
"""
ultima(asset::Asset, S::Real, T::Real, v::Real) = ForwardDiff.derivative(x -> vomma(asset, S, T, x), v)

delta(::UnderlyingStock, S::Real, T::Real, v::Real) = one(Float64)
vega(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
theta(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
gamma(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
vanna(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
charm(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
vomma(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
veta(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
speed(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
zomma(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
color(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)
ultima(::UnderlyingStock, S::Real, T::Real, v::Real) = zero(Float64)

function _greek_dispatch(asset::Asset, name::Symbol)
    name in _GREEK_NAMES || throw(ArgumentError("Unsupported greek: $(name)"))
    return getfield(@__MODULE__, name)
end

function Base.getproperty(asset::Asset, name::Symbol)
    if name in _GREEK_NAMES
        greek = _greek_dispatch(asset, name)
        return (S, T, v) -> greek(asset, S, T, v)
    end
    return getfield(asset, name)
end

_normalize_greek(greek::Symbol) = greek
_normalize_greek(greek::AbstractString) = Symbol(greek)

function _validate_portfolio(hedging_instruments::Vector{Asset}, greeks::Vector{Symbol})
    length(hedging_instruments) == length(greeks) || throw(ArgumentError("The number of hedging instruments needs to be the same as the number of greeks"))
    all(greek -> greek in _HEDGEABLE_GREEKS, greeks) || throw(ArgumentError("Unsupported greek in portfolio. Supported greeks are: $(_HEDGEABLE_GREEKS)"))
    length(unique(greeks)) == length(greeks) || throw(ArgumentError("Portfolio greeks must be unique"))
end

"""
    Portfolio(f, N, hedging_instruments, greeks)

Define the option position `N * f` to hedge, along with the hedging instruments and
the Greeks to neutralize. Each Greek must be unique and matched by one instrument.
"""
struct Portfolio
    f::Asset
    N::Int64
    hedging_instruments::Vector{Asset}
    greeks::Vector{Symbol}

    function Portfolio(f::Asset, N::Int64, hedging_instruments::Vector{Asset}, greeks::Vector{Symbol})
        _validate_portfolio(hedging_instruments, greeks)
        return new(f, N, hedging_instruments, greeks)
    end
end

function Portfolio(f::Asset, N::Integer, hedging_instruments::AbstractVector{<:Asset}, greeks::AbstractVector)
    normalized_greeks = Symbol[_normalize_greek(greek) for greek in greeks]
    normalized_instruments = Asset[hedging_instruments...]
    return Portfolio(f, Int64(N), normalized_instruments, normalized_greeks)
end
