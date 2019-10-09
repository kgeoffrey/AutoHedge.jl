# quantitativefinance
Some models

Example with simulated options:

![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/volatilitysurface.png "Logo Title Text 1")



You can find an online version here: [Interactive Volatility Surface](https://kgeoffrey.github.io/quantfinance/graph.html)


## Delta Hedding Strategy

Example:

 - Simulating stock price with Gaussian walk (should be geometric Brown. motion)
 - Rebalancing every 5th day 
 - Delta hedging portfolio consisting of call option 
 - Everything constant except for time and spotprice:
    - K = 120
    - r = 0.01
    - q = 0
    - N = 1000 (number of calls)
    
 Stock Price:
 
 ![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/stockprice.png "Logo Title Text 1")
 
 Cash borrowing to finance stock purchase 
 
 ![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/borrow.png "Logo Title Text 1")
 
 Portfolio Value over time
 
 ![alt text](https://github.com/kgeoffrey/quantitativefinance/blob/master/fig/value.png "Logo Title Text 1")


An even better strategy is to try to hedge against changes in the delta of the derivative (second order derivative; also called Gamma).
For this we bring in a another derivative with the same under lying stock, but a different strike price. 

