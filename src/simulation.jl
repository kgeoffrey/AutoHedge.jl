"""
    hedge(portfolio, data)

Solve the linear hedge system for `portfolio` at market state `data = [S, T, v]`.
Returns the borrowing amount followed by hedge instrument positions.
"""
function hedge(portfolio::Portfolio, data::AbstractVector{<:Real})
    borrowing_vec = zeros(Float64, length(portfolio.greeks) + 1)
    borrowing_vec[1] = -1
    A = zeros(Float64, length(borrowing_vec), length(borrowing_vec))
    A[:, 1] = borrowing_vec
    greeks = vcat(:value, portfolio.greeks)
    for (j, asset) in enumerate(portfolio.hedging_instruments)
        param = zeros(Float64, length(borrowing_vec))
        for (i, greek) in enumerate(greeks)
            param[i] = getfield(@__MODULE__, greek)(asset, data...)
        end
        A[:, 1 + j] = param
    end
    b = [portfolio.N * getfield(@__MODULE__, greek)(portfolio.f, data...) for greek in greeks]
    return A\b
end

function _default_maturity(price_path::AbstractVector{<:Real}, portfolio::Portfolio)
    if :T in fieldnames(typeof(portfolio.f))
        return Float64(getfield(portfolio.f, :T))
    end
    return length(price_path) / 365
end

function _default_volatility(portfolio::Portfolio)
    if :v in fieldnames(typeof(portfolio.f))
        return Float64(getfield(portfolio.f, :v))
    end
    return 0.2
end

function _remaining_time(initial_time::Real, step::Integer, n_steps::Integer)
    if n_steps <= 1
        return max(Float64(initial_time), eps(Float64))
    end
    return max(Float64(initial_time) * (n_steps - step) / (n_steps - 1), eps(Float64))
end

function _instrument_values(portfolio::Portfolio, S::Real, T::Real, v::Real)
    return [value(asset, S, T, v) for asset in portfolio.hedging_instruments]
end

"""
    backtest(price, freq, portfolio; time_to_maturity=nothing, volatility=nothing,
             transaction_cost=0.0, max_position=1e3)

Run a hedging backtest for a single price path. Returns `(borrow, shares, values)`,
where `borrow` is the financing series, `shares` are hedge positions over time, and
`values` are the resulting tracking errors.
"""
function backtest(price::Union{AbstractVector{<:Real}, AbstractMatrix{<:Real}},
                  freq::Integer,
                  portfolio::Portfolio;
                  time_to_maturity::Union{Nothing, Real}=nothing,
                  volatility::Union{Nothing, Real}=nothing,
                  transaction_cost::Real=0.0,
                  max_position::Real=1e3)
    transaction_cost >= 0 || throw(ArgumentError("transaction_cost must be non-negative"))
    max_position > 0 || throw(ArgumentError("max_position must be positive"))

    price_path = _price_path(price)
    n_steps = length(price_path)
    maturity = time_to_maturity === nothing ? _default_maturity(price_path, portfolio) : Float64(time_to_maturity)
    sigma = volatility === nothing ? _default_volatility(portfolio) : Float64(volatility)
    rebalance_steps = _rebalance_mask(n_steps, freq)

    borrow = zeros(Float64, n_steps)
    shares = zeros(Float64, n_steps, length(portfolio.hedging_instruments))
    values = zeros(Float64, n_steps)

    current_borrow = 0.0
    current_shares = zeros(Float64, length(portfolio.hedging_instruments))

    for (i, S) in enumerate(price_path)
        T = _remaining_time(maturity, i, n_steps)
        if rebalance_steps[i]
            target = hedge(portfolio, [Float64(S), T, sigma])
            target_shares = Float64.(target[2:end])
            if !any(abs.(target_shares) .> max_position)
                trades = target_shares .- current_shares
                hedge_values = _instrument_values(portfolio, S, T, sigma)
                fees = transaction_cost * sum(abs.(trades) .* abs.(hedge_values))
                current_borrow = Float64(target[1]) + fees
                current_shares = target_shares
            end
        end

        hedge_values = _instrument_values(portfolio, S, T, sigma)
        borrow[i] = current_borrow
        shares[i, :] = current_shares
        values[i] = sum(current_shares .* hedge_values) - portfolio.N * value(portfolio.f, S, T, sigma) - current_borrow
    end
    return borrow, shares, values
end
