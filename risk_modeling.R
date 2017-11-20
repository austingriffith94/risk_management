# Austin Griffith
# 11/19/17
# Risk Management

# set working directory
# needs to be adjusted when on new computer
setwd("C:/Users/Austin/GIT_profile/risk_management")
getwd()

# import data
ret = read.csv("returns_main.csv", header=TRUE)
ret_c = read.csv("returns_comp.csv", header=TRUE)

# sum return percentages by day
# assumed equal investment in each firm
ret_sum = aggregate(.~DATE, data=ret, FUN=sum)

# VAR
len = length(ret)
i = 1
rend = c(0)

