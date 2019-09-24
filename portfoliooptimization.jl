## Binary Search method for Market Portfolio

# dependancies
using Plots
using Statistics
using PyPlot
using LinearAlgebra
using Convex
using Random
using ECOS

function market_portfolio(r, Sig, num, rf)
    # w is the weight for the portfolio
    w1 = Variable(length(r))
    R1 = Variable()
    problem1 = minimize(quadform(w1,(Sig)), r'*w1 >= R1, ones(length(r))'*w1 == 1, w1 >= 0)
    solve!(problem1, ECOSSolver(verbose=false))
    
    numrange = collect(range(sum(r'*w1.value), stop = maximum(r), length=num))
    
    returnsboi = []
    covarianceboi = []
    for i in numrange
        w = Variable(length(r))
        R = i
        problem = minimize(quadform(w,(Sig)), r'*w >= R, ones(length(r))'*w == 1, w >= 0)
        solve!(problem, ECOSSolver(verbose=false))
        rr = r'*w.value
        cc = sqrt.(problem.optval)
        append!(returnsboi, rr)
        append!(covarianceboi, cc)
    end
    
    function sharpe(rf)
        sharpe = []
        for (i,j) in enumerate(returnsboi)
            append!(sharpe, (j-rf)/covarianceboi[i])
        end
        return sharpe
    end
    
    function optimal(R)
        w = Variable(length(r))
        problem = minimize(quadform(w,(Sig)), r'*w >= R, ones(length(r))'*w == 1, w >= 0)
        solve!(problem, ECOSSolver(verbose=false))
        #solve!(problem, SCSSolver(verbose=false))
        return (sum(r'*w.value) - rf) / problem.optval, sum(r'*w.value) , sqrt.(problem.optval)
    end

    function binarysearch()
        wow = (sharpe(rf))
        maxval = maximum(wow)
        pos = sum([i for (i, x) in enumerate(wow) if x == maxval])
        value = numrange[pos]
        inc = abs(numrange[pos]-numrange[pos+1])*(1/2)

        while abs(inc) > 1e-6
            mark = optimal(value+inc)[1]
            geoff = optimal(value-inc)[1]
            if mark > maxval
                maxval = mark
                value += inc
                print("UP by ", inc,"\n") #, " value: ",maxval,", new value: ",maxval,"\n")
                inc *= (1/2)
            elseif geoff > maxval
                print("DOWN by ", inc, "\n") #, " value: ",maxval,", new value: ",geoff,"\n")
                maxval = geoff
                value -= inc
                inc *= (1/2)
            else
                inc *= (1/2)
                print("Decreasing radius with value: ",inc,"\n")
            end
        end
        return value
    end
    
    optresult = binarysearch()
    optreturn, optstd, optsharpe = optimal(optresult)
    return optreturn, optstd, optsharpe, returnsboi,(covarianceboi)
end

@time begin
    shrp, mreturn, mstd, returns, standarddev = market_portfolio(r, Sig, 12, 0.03)
end

## Plotting the market portfolio at the intersection of efficient frontier and capital market line

plot!(standarddev,returns)
gcf()
PyPlot.clf()
scatter!([mstd],[mreturn])
PyPlot.clf()
gcf()
xx = collect(range(0,stop=0.4,length=10))
slope = (sum(mreturn) - 0.03)/mstd
plot!(xx, 0.03 .+ slope*xx)
