# risk_management

The risk management folder solves for VaR, $VaR, expected shortfall, and variance for two periods of time. There are also calculations of the Garch model and RiskMetrics model for daily variance, VaR and expected shortfall. The current sets of data provided are for 2005-2010, and 2000-2010 for comparisons.

## Risk Measures
### VaR and $VaR

VaR is a measure of the potential loss from extreme negative returns within a certain confidence. $VaR is a measure of the potential loss of value from an extreme negative return. Both values can be expressed by the following relationship:

    Pr(r > -VaR) = p
    Pr($Loss > $VaR) = p

where
- p is the percentage confidence for the interval
- r is the returns over the period being observed

Based on this probability relationship, VaR can be solved by the equation:

    VaR = -σ * Φ-1(p)
    $VaR = VaR * Vpf

where
- p is the percentage confidence for the interval
- σ is the volatility of returns over the period being observed
- Φ-1(p) is the cumulative density function, and represents the number such that 100% of the probability mass is below p
- Vpf is the value of the portfolio at risk

### Expected Shortfall

Expected shortfall (ES), or 'TailVaR', accounts for the magnitude of large losses as well as their probability of occurring. The ES tells us the expected value of tomorrow’s loss, conditional on it being worse than the VaR. The ES computes the average of the tail outcomes weighted by their probabilities.

ES can be expressed by the following relationship:

    ES = -E[r | r < -VaR]

where
- r is the returns over the period being observed

Due to this conditional relationship between returns and VaR, ES can be solved for by the following equation:

    ES = σ * φ(Φ-1(p))/p

where
- p is the percentage confidence for the interval
- σ is the volatility of returns over the period being observed
- Φ-1(p) is the cumulative density function, and represents the number such that 100% of the probability mass is below p
- φ is the density function

## Risk Models
### RiskMetrics Model



## File Explanation
#### DSF_cleaner.sas
The sas file cleans the data from the DSF file used for the modeling and risk measures. It can be altered to pull from any period of time should there be a desire to compare another set to two time periods.

This code is responsible for outputting the csvs available in this folder. For this particular case, the time periods selected are 2005-2010 and 2000-2010. The code also is used for the random sample of 100 firms from the data. This was simply used to limit the size of the imported csv, as the DSF file has tens of thousands of firms. However, the R code is written so that it can take any number of firms, as it reads the number of unique permnos when importing. The random selection was seeded with a unique number to allow for repetition.

#### risk_modeling.R
This is the main code for working with the functions and models. It was used to create the .Rmd file. However, this code isn't limited by the writeup of the markup file. The functions allow it to be used for any set of csvs that are set up in the correct format. All the user has to do is set up the correct file name and path, and the code should be able to compare two sets of data, or can be slightly altered to graph just one set of data.

#### risk_model.Rmd and risk_model.html
The markdown file that comments on the code's contents, as well as the outputs. To gain a better understanding of the code, you should read the .Rmd file, or its respective .html.

#### fGarch.pdf
The .pdf is a manual for use of the fGarch library for R. It is extremely useful for understanding how to execute the main functions within the library, as well as to gain a better understanding of how to solve for the GARCH model variables.

## extra_data
This folder holds another set of data. There is an addtional set of returns data and the respective sas file used to clean them. For these csvs, the years are 2000-2010 for the main, and 1980-1990 for the comparison. For each time period, there are now 200 firms, to show the code works with any number of firms. The .R and .Rmd file are also present, with the only changes to them being path for the working directory. There is a .html output to display a comparison between the two time periods.
