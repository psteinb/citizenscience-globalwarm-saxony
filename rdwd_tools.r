library(rdwd)
library(readr)
library(ggplot2)
library(dplyr)

download_station = function(sid, stations){

  cat('looking into ',sid,'\n')

  if( !is.integer(stations$station_id) ){
    stations$station_id = as.integer(stations$station_id)
  }

  station_info = stations %>% filter(station_id == sid)

  #extract row for this station
  station_name = station_info$name

  cat(':: selecting',sid,'(',station_name,')','\n')
  station_link = selectDWD(id=sid, res='monthly', var='kl', per='historical')

  station_data = tryCatch({dataDWD(station_link, progbar=T,read=T)},
                          warning = function(w){ cat(paste('something fishy with',sid, station_name,'\n')); },
                          error = function(e){ print(paste('unable to download',sid,station_name,e,'\n'));return(NA) },
                          finally = { cat('>> ',sid, 'downloaded successfully','\n') })

  if(is.null(station_data) || is.na(station_data) == T){
    cat('!!',sid,'failed\n')
    return(station_data)
  }

  #for an explanation of column names see
  #https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/monthly/kl/historical/DESCRIPTION_obsgermany_climate_monthly_kl_historical_en.pdf
  rdf = station_data %>%
    select(STATIONS_ID,MESS_DATUM_BEGINN,MESS_DATUM_ENDE,MO_TT,MO_TX,MO_TN) %>%
    mutate(STATIONS_ID = as.integer(STATIONS_ID)) %>%
    as_tibble()
    ## left_join(station_info, by = c("STATIONS_ID"="station_id")) %>%


  cat(":: obtained","\t",station_info$name,'\n')
  cat(typeof(rdf))
  return(rdf)
}
