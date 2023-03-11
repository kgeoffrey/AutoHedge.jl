

function randomwalk(start, len, num_walks)
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
