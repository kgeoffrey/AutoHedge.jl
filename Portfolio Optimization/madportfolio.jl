## Mean Absolute Deviation Model

# depencancies 

using LinearAlgebra
using Convex
using Pkg
using Random
# I used the ECOS solver, any other cone solver works as well
using ECOS

# create input matrix
function absmatrix(X)
    returns = X
    r = mapslices(mean, returns,dims=1)
    
    #matrix = []
    matrix = Array{Float64}(undef, length(returns[:,1])) #Array(Float64, length(r) ,length(returns[:,1]))
    for (i,j) in enumerate(r)
        column = []
        for t in returns[:,i]
            dev = t - j
            append!(column, dev)
        end
        matrix = hcat(matrix, column)
    end
    
    matrix = convert(Array{Float64,2}, (matrix[:,2:end]'))
    
    return matrix, r'
end 

# calculating minimum MAD-portfolio
tmatrix, r = absmatrix(X)

function MAD(R, tmatrix, r)
    tmatrix, r = tmatrix, r
    T = size(tmatrix)[2] #length(absmatrix(X)[:,1])
    N = size(tmatrix)[1] #length(absmatrix(X)[1,:])
    y = Variable(T) # T 
    w = Variable(N) # N

    R = R #Variable()

    problem = minimize(sum(y)/T)
    problem.constraints += r'*w >= R
    problem.constraints += sum(w) == 1
    problem.constraints += w >= 0


    for i in 1:T
        array = convert(Array{Float64,2}, (tmatrix))
        problem.constraints += y[i] + array[:,i]'*w >= 0
        problem.constraints += y[i] - array[:,i]'*w >= 0
    end
    solve!(problem, ECOSSolver(verbose=false))
    return w.value
end

@time begin
    solve!(problem, ECOSSolver(verbose=false))
    print("minimum is ", problem.optval)
end
