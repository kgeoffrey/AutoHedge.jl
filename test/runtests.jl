using AutoHedge
using Test

@testset "AutoHedge.jl" begin
    @test size(AutoHedge.randomwalk(100, 500, 1)) == (500, 1)

    sampled = AutoHedge.convertdata([100.0, 101.0, 102.0, 103.0, 104.0], 2)
    @test sampled == [100.0, 100.0, 102.0, 102.0, 104.0]

    call_option = CallOption(100.0, 130.0, 5.0, 0.01, 0.2, 0.0)
    put_option = PutOption(100.0, 120.0, 5.0, 0.01, 0.2, 0.0)
    stock = UnderlyingStock()
    portfolio = Portfolio(call_option, 10, [stock], ["delta"])
    prices = reshape([100.0, 101.0, 102.0, 103.0, 104.0], :, 1)

    @test value(call_option, 100.0, 5.0, 0.2) ≈ call_option.value(100.0, 5.0, 0.2)
    @test delta(call_option, 100.0, 5.0, 0.2) ≈ call_option.delta(100.0, 5.0, 0.2)
    @test value(stock, 100.0, 5.0, 0.2) == 100.0
    @test delta(stock, 100.0, 5.0, 0.2) == 1.0
    @test vega(stock, 100.0, 5.0, 0.2) == 0.0
    @test value(put_option, 100.0, 5.0, 0.2) > 0.0
    @test Portfolio(call_option, 10, [stock], [:delta]).greeks == [:delta]
    @test_throws ArgumentError Portfolio(call_option, 10, [stock], [:delta, :vega])
    @test_throws ArgumentError Portfolio(call_option, 10, [stock, put_option], [:delta, :delta])

    borrowing, shares, tracking_errors = backtest(prices, 2, portfolio)
    @test length(borrowing) == 5
    @test size(shares) == (5, 1)
    @test length(tracking_errors) == 5

    borrowing_fee, shares_fee, tracking_errors_fee = backtest(prices, 2, portfolio; transaction_cost=0.01)
    @test length(borrowing_fee) == 5
    @test size(shares_fee) == (5, 1)
    @test length(tracking_errors_fee) == 5
    @test all(tracking_errors_fee .<= tracking_errors .+ 1e-8)
end
