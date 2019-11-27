### Testing optimization for some stuff

struct Darray
    f::Array
    g::Array
end

import Base: +,/,*,-,^, convert, promote_rule
+(x::Darray, y::Darray) = Darray(x.f .+ y.f, x.g .+ y.g)
-(x::Darray, y::Darray) = Darray(x.f .- y.f, x.g .- y.g)
*(x::Darray, y::Darray) = Darray(x.f*y.f, x.f*y.g + y.f*x.g)

convert(::Type{Darray}, x::AbstractArray) = Darray(x, ones(length(x)))

t = convert(Darray, rand(4))
