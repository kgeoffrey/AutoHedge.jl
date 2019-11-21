### Testing optimization for some stuff

struct Darray <: AbstractArray
    f::Array
    g::Array
end

import Base: +,/,*,-,^, convert, promote_rule
+(x::Darray, y::Darray) = Darray(x.f .+ y.f, x.g .+ y.g)
-(x::Darray, y::Darray) = Darray(x.f .- y.f, x.g .- y.g)
*(x::Darray, y::Darray) = Darray(x.f*y.f, x.f*y.g + y.f*x.g)
