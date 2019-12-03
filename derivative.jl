### simple Automatic Differentiation with Dual Numbers
using Distributions, LinearAlgebra
using StaticArrays


struct Dual <: Number
    f::Union{Real, Dual}
    g::Array
end


### Differentiation rules via overloading ###

import Base: +,/,*,-,^,adjoint, convert, promote_rule
import Base: +,/,*,-,^, convert, promote_rule

+(x::Dual, y::Dual) = Dual(x.f + y.f, x.g + y.g)
+(x::Dual, y::Real) = Dual(x.f + y, x.g)
+(y::Real, x::Dual) = Dual(x.f + y, x.g)
-(x::Dual, y::Dual) = Dual(x.f - y.f, x.g - y.g)
-(x::Dual) = Dual(-x.f, -x.g)
-(x::Dual, y::Real) = Dual(x.f -y, x.g)
-(y::Real, x::Dual) = Dual(y-x.f, -x.g)
*(x::Dual, y::Dual) = Dual(x.f*y.f, x.f*y.g + y.f*x.g)
*(x::Dual, y::Real) = Dual(x.f*y, x.g*y)
*(y::Real, x::Dual) = Dual(x.f*y, x.g*y)
/(x::Dual, y::Dual) = Dual(x.f/y.f, (y.f*x.g - x.f*y.g)/y.f^2)
/(y::Real, x::Dual) = Dual(y/x.f, (-y*x.g) / x.f^2)
/(x::Dual, y::Real) = Dual(x.f/y, x.g/y)
^(x::Dual, k::Real) = Dual(x.f^k, (x.g * k) * x.f ^ (k-1))
^(x::Dual, k::Int) = Dual(x.f^k, (k * x.f ^ (k-1)) * x.g)
Base.exp(x::Dual) = Dual(exp(x.f), x.g * exp(x.f))
Base.sqrt(x::Dual) = Dual(sqrt(x.f), x.g / (2 * sqrt(x.f)))
Base.log(x::Dual) = Dual(log(x.f), x.g/x.f)

Distributions.cdf(d, x::Dual) = Dual(cdf(d, x.f), pdf(d, x.f) * x.g)
Base.adjoint(x::Dual) = Dual(adjoint(x.f), adjoint(x.g))
LinearAlgebra.dot(x::Dual, y::Dual) = Dual(dot(x.f,y.f), x.f * y.g + y.f * x.g)
Base.zero(x::Dual) = Dual(zero(x.f), zero(x.g))

### conversion, promotion rules ###
convert(::Type{Dual}, x::Real) = Dual(x, one(x))
convert(::Type{Dual}, x::AbstractArray) = DualArray(x)
convert(::Type{Array}, x::Real) = [x]
Dual(x) = convert(Dual, x)
promote_rule(::Type{Dual}, ::Type{<:Number}) = Dual


### derivative ###
function gradient(f, x)
    x = convert(Dual, x)
    return getfield.(f(x), :g)
end

new = rand(100)

sigmoid(x) = (x .*  x)'*x
derivative(sigmoid, new)


Dual(1,1)
getfield(Dual(1,1), :g)

function DualArray(x)
    l = length(x)
    eye = I(l)
    collect = []
    for i in 1:l
        push!(collect, Dual(x[i], view(eye,i,:,)))
    end
    return collect
end




@time t = DualArray(new)
@time p = DualArray2(new)


@time gradient(sigmoid, new)






view(t,1,:,)

rr = rand(4)

I(3)

Matrix(I, 3, 3 ,3)

using StaticArrays

struct Foo{N,T, L}
    x::SMatrix{N,N,T, L}
    y::SVector{N,T}
end


f(x) = x^3

f(Dual(3,1))



d(x) = f(Dual(x, 1))

d(Dual(2,1))

f(Dual(Dual(5,1),1))

f(x) = x'*x
me = rand(10)

function higherorder(f, x, n)
    return dechain(f(chain(x,n)))
end

@time higherorder(f, 2, 3)


function chain(x, n)
    if n == 1
        return Dual(x, 1)
    else
        return chain(Dual(x, 1), n-1)
    end
end


function dechain(x)
    if x.g[1] isa Real
        return x.g[1]
    else
        dechain(x.g[1])
    end
end

pp = f(u)

dechain(pp)
