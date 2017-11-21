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
  avg_ret = mean(r_vec)
  
  var = abs(quantile(r_vec,1-a))
  dol_var = port*(1-exp(-var))
  par_var = abs(qnorm(1-a,0,1)*vol*port)
  hist_var = abs(quantile(r_vec,1-a)*port)

  data = list("VaR"=var, "$VaR"=dol_var, "Parametric"=par_var, 
              "Historical"=hist_var)
  return(data)
}

# one day var calculations
var_oneday <- function(r_vec,port,hist,a)
{
  #initial variance using historical data
  variance_0 = var(hist)
  
  #variables for while loop
  lamda = 0.94
  i = 1
  variance = c(0)
  var = c(0)
  while(i <= length(r_vec))
  {
    variance_1 = lamda*variance_0 + (1-lamda)*(r_vec[i]^2)
    variance[i] = variance_1
    
    var[i] = -1*sqrt(variance_1)*qnorm(1-a,0,1)
    
    variance_0 = variance_1
    i = i + 1
  }
  data = list("variance" = variance, "oneday" = var)
  return(data)
}

# general histogram function
vec_hist <- function(x, names)
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

#reads files, gets list of returns and value
data_m = read_func(file1,invest)
data_c = read_func(file2,invest)
data_mh = read_func(file3,invest)
data_ch = read_func(file4,invest)

#confidence interval for var
conf = 0.95

# pulls var calculations
var_m = var_calc(data_m$returns,data_m$portfolio,conf)
var_c = var_calc(data_c$returns,data_c$portfolio,conf)

main = var_oneday(data_m$returns,date_m$portfolio,
                  data_mh$returns,conf)
comp = var_oneday(data_c$returns,date_c$portfolio,
                  data_ch$returns,conf)

#---------------------graphing---------------------#

# lists with labels for histograms
hist_returns_m = list("title" = "2005 to 2010 Returns w/ Normal Curve",
                       "xlabel" = "Daily Returns")
hist_returns_c = list("title" = "2000 to 2010 Returns w/ Normal Curve",
                       "xlabel" = "Daily Returns") 

# write histograms for historical returns
vec_hist(data_m$returns, hist_returns_m)
vec_hist(data_c$returns, hist_returns_c)


y = main$oneday
x = data_m$dates
plot(x,y)

