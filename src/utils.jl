"""
    randomwalk(start, len, num_walks)

Generate `num_walks` Gaussian random walks of length `len`, starting near `start`.
Returns a `len × num_walks` matrix.
"""
function randomwalk(start::Real, len::Integer, num_walks::Integer)
    A = zeros(Float64, len, num_walks)
    for i in 1:num_walks
        gaussian_walk = zeros(Float64, len)
        step_scale = max(rand(Normal(2, 1)), eps(Float64))
        gaussian_walk[1] = rand(Normal(start, step_scale))
        for n in 2:length(gaussian_walk)
            gaussian_walk[n] = gaussian_walk[n - 1] + rand(Normal())
        end
        A[:, i] = gaussian_walk
    end
    return A
end


function _price_path(price::AbstractVector{<:Real})
    path = Float64.(collect(price))
    isempty(path) && throw(ArgumentError("price path must not be empty"))
    return path
end

function _price_path(price::AbstractMatrix{<:Real})
    size(price, 2) == 1 || throw(ArgumentError("backtest currently supports a single simulated price path"))
    path = vec(Float64.(price))
    isempty(path) && throw(ArgumentError("price path must not be empty"))
    return path
end

function _rebalance_mask(n_steps::Integer, freq::Integer)
    freq > 0 || throw(ArgumentError("rebalancing frequency must be positive"))
    mask = falses(n_steps)
    mask[1:freq:n_steps] .= true
    return mask
end

"""
    convertdata(price, freq)

Convert a price path into a piecewise-constant rebalance reference series, where the
value updates every `freq` observations and is held between rebalance points.
"""
function convertdata(price::Union{AbstractVector{<:Real}, AbstractMatrix{<:Real}}, freq::Integer)
    path = _price_path(price)
    rebalance_mask = _rebalance_mask(length(path), freq)
    sampled = similar(path)
    last_rebalance_price = path[1]
    for i in eachindex(path)
        if rebalance_mask[i]
            last_rebalance_price = path[i]
        end
        sampled[i] = last_rebalance_price
    end
    return sampled
end
