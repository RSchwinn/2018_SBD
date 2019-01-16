# loads data
adp_df = read.csv("adp.csv", header = F)
bls_df = read.csv("notseasonal.csv")
bls_seasonal_df = read.csv("seasonal.csv")

library(reshape2)
library(dplyr)
library(lubridate)
library(ggplot2)

# reshapes bls data
bls_df = melt(bls_df, id.vars = "Year") %>%
  arrange(Year)
bls_df$date = dmy(paste0("01", bls_df$variable, bls_df$Year)) 
bls_df = bls_df[,c(4,3)]


bls_seasonal_df = melt(bls_seasonal_df, id.vars = "Year") %>%
  arrange(Year) 
bls_seasonal_df$date = dmy(paste0("01", bls_seasonal_df$variable, bls_seasonal_df$Year))
bls_seasonal_df = bls_seasonal_df[,c(4,3)]


# fixes dates
adp_df[,1] = gsub("M", "01", adp_df[,1])
names(adp_df) = c("date", "adp_estimate" )
adp_df$date = ydm(adp_df$date)



df = merge(bls_df, bls_seasonal_df, by = "date")
df = merge(df, adp_df, by = "date")

df[,2] = as.numeric(df[,2])
df[,3] = as.numeric(df[,3])
df[,4] = as.numeric(gsub(",","",as.character(df[,4])))

names(df) = c("date", "bls_unadjusted", "bls_seasonal",  "adp")

df = melt(df, id.vars = "date")

p = ggplot(df, aes(x = date, y = value, group = variable)) 
p +  geom_line()
p = p +  geom_line(aes(color = variable))

library(plotly)

ggplotly(p)
