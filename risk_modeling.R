# Austin Griffith
# 11/19/17
# Risk Management

# set working directory
# needs to be adjusted when on new computer
setwd("C:/Users/Austin/GIT_profile/risk_management")
getwd()
library(fGarch)
library(plotly)
packageVersion('plotly')

#---------------------functions---------------------#

# import data
# returns are in %
# sum return percentages by day
# assumed equal investment weight in each firm
read_func <- function(value, I)
{
  filename = paste(value, ".csv", sep="")
  ret = read.csv(filename, header=TRUE)
  
  firms = ret[["PERMNO"]]
  count = length(unique(firms))
  port = count*I
   
  ret_sum = aggregate(.~DATE, data=ret, FUN=sum)
  ret_sum = ret_sum[order(as.Date(ret_sum$DATE, "%m/%d/%Y"), decreasing=FALSE),] 
  ret_date = unique(ret_sum[["DATE"]])
  
  keeps = c("RET","DATE")
  ret_sum = ret_sum[keeps]
  
  # gets average
  i = 1
  while(i < nrow(ret_sum))
  {
    ret_sum[i,"RET"] = ret_sum[i,"RET"]/count
    i = i + 1
  }
  
  data = list("portfolio" = port, "returns" = ret_sum)
  return(data)
}

#function to calculate var
var_calc <- function(returns,port,a)
{
  r_vec = returns[["RET"]]
  vol = sd(r_vec)
  cumdist = qnorm(1-a,0,1)
  
  var = abs(quantile(r_vec,1-a))
  dol_var = abs(quantile(r_vec,1-a)*port)
  exp_short = vol*dnorm(cumdist)/(1-a)

  data = list("VaR" = var, "$VaR" = dol_var, 
              "Expected_Shortfall" = exp_short)
  return(data)
}

# risk metrics one day modeling
oneday_f <- function(returns,hist_returns,a)
{
  # initial variance using historical data
  # variance based off of previous 10 days
  hist = hist_returns[["RET"]]
  variance_0 = var(hist[length(hist)-10:length(hist)])
  
  # variables for while loop
  lamda = 0.94
  i = 1
  variance = c(0)
  var = c(0)
  exp_short = c(0)
  cumdist = qnorm(1-a,0,1)
  
  while(i <= nrow(returns))
  {
    variance_1 = lamda*variance_0 + (1-lamda)*((returns[i,"RET"])^2)
    variance[i] = variance_1
    var[i] = -1*sqrt(variance_1)*cumdist
    exp_short[i] = sqrt(variance_1)*dnorm(cumdist)/(1-a)
    
    variance_0 = variance_1
    i = i + 1
  }
  returns$rm_variance = variance
  returns$VaR = var
  returns$ExpShort = exp_short
  return(returns)
}

# garch model
garch_f <- function(returns,hist_returns,a)
{
  # initial variance using historical data
  # variance based off of previous 10 days
  hist = hist_returns[["RET"]]
  variance_0 = var(hist[length(hist)-10:length(hist)])
  
  # function to solve for garch model variables
  x.g = garchFit(~garch(1,1),returns[["RET"]])
  summary(x.g)
  coef(x.g)
  
  # variables for loop and garch model
  i = 1
  variance = c(0)
  var = c(0)
  exp_short = c(0)
  cumdist = qnorm(1-a,0,1)
  alpha = coef(x.g)[3]
  beta = coef(x.g)[4]
  omega = coef(x.g)[2]
  
  while(i <= nrow(returns))
  {
    variance_1 = omega + beta*variance_0 + alpha*((returns[i,"RET"])^2)
    variance[i] = variance_1
    var[i] = -1*sqrt(variance_1)*cumdist
    exp_short[i] = sqrt(variance_1)*dnorm(cumdist)/(1-a)
    
    variance_0 = variance_1
    i = i + 1
  }
  returns$VaR = var
  returns$ExpShort = exp_short
  returns$g_variance = variance
  return(returns)
}

# histogram function with normal dist overlay
vec_histogram <- function(x, names)
{
  h = hist(x, breaks=(length(x)/50), col="red", xlab=names$xlabel, 
          main=names$title) 
  xfit = seq(min(x),max(x),length=40) 
  yfit = dnorm(xfit, mean=mean(x), sd=sd(x)) 
  yfit = yfit*diff(h$mids[1:2])*length(x) 
  lines(xfit, yfit, col="blue", lwd=2)
}

#---------------------calculations---------------------#

invest = 1000000 # investment per firm
file1 = "returns_main"
file2 = "returns_comp"
file3 = "returns_main_hist"
file4 = "returns_comp_hist"

# reads files, gets list of returns and value
data_m = read_func(file1,invest)
data_c = read_func(file2,invest)
data_mh = read_func(file3,invest)
data_ch = read_func(file4,invest)

# confidence interval for var
conf = 0.95

# pulls var calculations
var_m = var_calc(data_m$returns,data_m$portfolio,conf)
var_c = var_calc(data_c$returns,data_c$portfolio,conf)
var_m
var_c

oneday_m = oneday_f(data_m$returns,data_mh$returns,conf)
oneday_c = oneday_f(data_c$returns,data_ch$returns,conf)
garch_m = garch_f(data_m$returns,data_mh$returns,conf)
garch_c = garch_f(data_c$returns,data_ch$returns,conf)

#---------------------graphing---------------------#

# lists with labels for histograms
hist_label_m = list("title" = "2005 to 2010 Returns w/ Normal Curve",
                       "xlabel" = "Daily Returns")
hist_label_c = list("title" = "2000 to 2010 Returns w/ Normal Curve",
                       "xlabel" = "Daily Returns") 

# write histograms for historical returns
vec_histogram(data_m$returns[["RET"]], hist_label_m)
vec_histogram(data_c$returns[["RET"]], hist_label_c)

# graph variance, VaR and ES
time = c(1:nrow(oneday_m))
time = time/252 + 2005
data = data.frame(garch_m,time)
data$y = data$g_variance
names = list("main" = "Garch Model Variance Main",
             "yaxis" = "Variance of Returns")

plot_ly(data, x = ~time, y = ~y, name = names$main, 
        type = "scatter", mode = "lines", 
        line = list(color = 'rgb(205, 12, 24)', width = 1.5)) %>%
layout(title = names$name,
       xaxis = list(title = "Years"),
       yaxis = list (title = names$yaxis))




