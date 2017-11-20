# Austin Griffith
# 11/19/17
# Risk Management

# set working directory
# needs to be adjusted when on new computer
setwd("C:/Users/Austin/GIT_profile/risk_management")
getwd()

invest = 1000000 # investment per firm
file1 = "returns_main"
file2 = "returns_comp"

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
  keeps = c("RET")
  ret_sum = subset(ret_sum, select = keeps)
  ret_vec = ret_sum[["RET"]]
  
  i = 1
  while(i < length(ret_vec))
  {
    ret_vec[i] = ret_vec[i]
    i = i + 1
  }
  
  data = list("port_val" = port, "returns" = ret_vec)
  
  return(data)
}

#reads files, gets vector of returns
data_m = read_func(file1,invest)
data_c = read_func(file2,invest)
r_vec = data_m$returns
r_comp = data_c$returns
conf = 0.95

vol = sd(r_vec)
avg_ret = mean(r_vec)

parvar = abs(qnorm(1-conf,0,1)*vol)
