# script can be executed with
# Rscript download-saxony-monthly-temperature.r <csv file>
args<-commandArgs(TRUE)

if(length(args) < 1){
  message("Usage: download-saxony-monthly-temperature.r <csv file>")
  stop("no csv file provided")
}


library(rdwd)

library(readr)
library(ggplot2)
library(dplyr)

source("rdwd_tools.r")

stations = read_csv(
  args[1],
  col_names=c('station_id','date_start','date_end','geo_lon','geo_lat'
             ,'height','name','state')) %>%
  mutate(station_id = as.integer(station_id))

message("min/max date_start/end ", min(stations$date_start)," ",max(stations$date_end))

dflist = lapply(stations$station_id,
                download_station,
                stations=stations)

message('>> merging downloaded datasets')

df = bind_rows(dflist)

message(">> downloaded from bind rows")
message("min/max date_start/end ", min(df$date_start)," ",max(df$date_end))


df = df %>%
  left_join(stations, by = c("STATIONS_ID"="station_id"))

message(">> final dataset about to be store to disk")
message("min/max date_start/end ", min(df$date_start)," ",max(df$date_end))

ofile = 'saxony-monthly-temperature.csv'
write_csv(df,ofile)
message('>> data written to ',ofile)
