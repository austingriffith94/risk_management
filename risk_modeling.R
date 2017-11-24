# Austin Griffith
# 11/19/17
# Risk Management

# set working directory
# needs to be adjusted when on new computer
setwd("C:/Users/Austin/GIT_profile/risk_management")
getwd()

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

  data = list("VaR"=var, "$VaR"=dol_var, 
              "Expected_Shortfall" = exp_short)
  return(data)
}

# risk metrics one day modeling
oneday_f <- function(returns,port,hist_returns,a)
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
  exp_short= c(0)
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
  returns$m_variance = variance
  returns$VaR = var
  returns$ExpShort = exp_short
  return(returns)
}

# garch model
garch_f <- function(returns,hist_returns)
{
  # initial variance using historical data
  # variance based off of previous 10 days
  hist = hist_returns[["RET"]]
  variance_0 = var(hist[length(hist)-10:length(hist)])
  
  # function to solve for garch model variables
  library(fGarch)
  x.g = garchFit(~garch(1,1),returns[["RET"]])
  summary(x.g)
  coef(x.g)
  
  # variables for loop and garch model
  i = 1
  variance = c(0)
  alpha = coef(x.g)[4]
  beta = coef(x.g)[3]
  omega = coef(x.g)[1]
  
  while(i <= nrow(returns))
  {
    variance_1 = omega + beta*variance_0 + alpha*((returns[i,"RET"])^2)
    variance[i] = variance_1
    
    variance_0 = variance_1
    i = i + 1
  }
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

oneday_m = oneday_f(data_m$returns,data_m$portfolio,
                  data_mh$returns,conf)
oneday_c = oneday_f(data_c$returns,data_c$portfolio,
                  data_ch$returns,conf)
garch_m = garch_f(data_m$returns,data_mh$returns)
garch_c = garch_f(data_c$returns,data_ch$returns)

#---------------------graphing---------------------#

# lists with labels for histograms
hist_returns_m = list("title" = "2005 to 2010 Returns w/ Normal Curve",
                       "xlabel" = "Daily Returns")
hist_returns_c = list("title" = "2000 to 2010 Returns w/ Normal Curve",
                       "xlabel" = "Daily Returns") 

# write histograms for historical returns
vec_histogram(data_m$returns[["RET"]], hist_returns_m)
vec_histogram(data_c$returns[["RET"]], hist_returns_c)

# garch code

oneday_m = garch_f(oneday_m)
oneday_c = garch_f(oneday_c)

time = c(1:nrow(oneday_m))
time = time/252 + 2005
plot(time,oneday_m$new_variance)
plot(time,oneday_m$variance)

time = c(1:nrow(oneday_c))
time = time/252 + 2000
plot(time,oneday_c$new_variance)
plot(time,oneday_c$variance)

