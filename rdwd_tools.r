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
  station_link = selectDWD(id=sid, res='monthly', var='kl', per='historical', current=T)
  dummy = data.frame(STATIONS_ID=integer(),
                       MESS_DATUM_BEGINN=integer(),
                       MESS_DATUM_ENDE=integer(),
                       MO_TT=double(),
                       MO_TX=double(),
                       MO_TN=double()
                     )

  station_df = tryCatch({dataDWD(station_link, progbar=T,read=T)},
                          warning = function(w){ cat(paste('WARNING something fishy with',sid, station_name,'\n',w,'\n'));return(dummy) },
                          error = function(e){ cat(paste('ERROR unable to download',sid,station_name,e,'\n'));return(dummy) },
                          finally = { cat(paste('SUCCESS ',sid, 'downloaded successfully','\n')) }
                          )

  ## if(is.null(station_df) || is.na(station_df) == T){
  ##   cat('!!',sid,'failed\n')

  ##   return(dummy)
  ## }

  #for an explanation of column names see
  #https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/monthly/kl/historical/DESCRIPTION_obsgermany_climate_monthly_kl_historical_en.pdf
  rdf = station_df %>%
    as_tibble() %>%
    select(STATIONS_ID,MESS_DATUM,MO_TT,MO_TX,MO_TN) %>%
    mutate(STATIONS_ID = as.integer(STATIONS_ID))
    ## left_join(station_info, by = c("STATIONS_ID"="station_id")) %>%


  cat(paste(":: obtained",station_info$name,"with",nrow(rdf),'rows\n'))
  cat(typeof(rdf))
  return(rdf)
}
