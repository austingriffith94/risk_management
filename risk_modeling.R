# Austin Griffith
# 11/19/17
# Risk Management

# set working directory
# needs to be adjusted when on new computer
setwd("C:/Users/Austin/GIT_profile/risk_management")
getwd()

file1 = "returns_main"
file2 = "returns_comp"

read_func <- function(value)
{
  # import data
  filename = paste(value, ".csv", sep="")
  ret = read.csv(filename, header=TRUE)
  
  # sum return percentages by day
  # assumed equal investment in each firm
  ret_sum = aggregate(.~DATE, data=ret, FUN=sum)
  keeps = c("RET")
  ret_sum = subset(ret_sum, select = keeps)
  ret_vec = ret_sum[["RET"]]
}

returns = read_func(file1)
returns_comp = read_func(file2)
i = 1



