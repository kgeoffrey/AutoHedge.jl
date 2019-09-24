## dependancy
import numpy as np
import pandas as pd
import random
import scipy.stats as si

## Black Scholes formula for value of a call option
def call_option(S, K, T, r, v):
    #S: spot price
    #K: strike price
    #T: time to maturity
    #r: interest rate
    #v: volatility of underlying asset
    d1 = (np.log(S / K) + (r + 0.5 * v ** 2) * T) / (v * np.sqrt(T))
    d2 = (np.log(S / K) + (r - 0.5 * v ** 2) * T) / (v * np.sqrt(T))
    call = (S * si.norm.cdf(d1, 0.0, 1.0) - K * np.exp(-r * T) * si.norm.cdf(d2, 0.0, 1.0))
    return call

## Simulating many random call options 
def syntehtic_data(size):
    df = pd.DataFrame()
    df['spot_price'] = np.random.randint(50, 200, size=(size))
    df['strike_price'] = np.random.randint(50, 200, size=(size))
    # df['maturity'] = np.round(np.random.chisquare(2,size=(size)),2)
    df['maturity'] = np.round(np.random.uniform(0.1, 2, size=(size)),2)
    df['risk_free_rate'] = np.round(np.random.uniform(0.01, 0.1, size=(size)),4)
    df['volatility'] = np.abs(np.random.normal(0.2,0.10, size=(size)))
    return df

## Pricing the options
def price_options(df):
    df = df
    prices = []
    for i in range(len(df)):
        prices.append(call_option(df.loc[i][0], df.loc[i][1], df.loc[i][2],df.loc[i][3], df.loc[i][4]))
    df["option_price"] = np.round(prices,2)
    return df

## Saving data 
def save_data(size):
    data = price_options(syntehtic_data(size))
    data.to_csv(r'optionprice.csv',index=False)

save_data(250000)  For good results in the neural net at least 250000
