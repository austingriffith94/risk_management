# Austin Griffith
# 11/19/17
# Risk Management

# set working directory
# needs to be adjusted when on new computer
setwd("C:/Users/Austin/GIT_profile/risk_management")
getwd()

file1 = "returns_main"
file2 = "returns_comp"

# import data
# returns are in %
# sum return percentages by day
# assumed equal investment in each firm
read_func <- function(value)
{
  filename = paste(value, ".csv", sep="")
  ret = read.csv(filename, header=TRUE)
  
   
  ret_sum = aggregate(.~DATE, data=ret, FUN=sum)
  keeps = c("RET")
  ret_sum = subset(ret_sum, select = keeps)
  ret_vec = ret_sum[["RET"]]
  return(ret_vec)
}

#reads files, gets vector of returns
r_vec = read_func(file1)
rc_vec = read_func(file2)



data = c(length(r_vec),mean(r_vec),sd(r_vec),252*mean(r_vec))
names(data) = c("Total Days","Daily Return","Daily Vol","Annual Return")
data
