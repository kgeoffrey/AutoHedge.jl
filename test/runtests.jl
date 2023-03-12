using AutoHedge
using Test

@testset "AutoHedge.jl" begin
    @test length(AutoHedge.randomwalk(100, 500, 1)) == 500
end
