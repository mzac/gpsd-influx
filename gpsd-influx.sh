#!/bin/bash

influx_url="http://influx.lab.local:8086"
influx_db="gpsd"
update_interval=10

for arg in "$@"
do
    if [ "$arg" == "--debug" ] || [ "$arg" == "-d" ]
    then
        debug_output=1
    fi
done

while true
do

tpv=$(gpspipe -w -n 5 | grep -m 1 TPV | python -mjson.tool)

gpsd_alt=$(echo "$tpv" | grep "alt" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_climb=$(echo "$tpv" | grep "climb" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_device=$(echo "$tpv" | grep "device" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_epc=$(echo "$tpv" | grep "epc" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_eps=$(echo "$tpv" | grep "eps" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_ept=$(echo "$tpv" | grep "ept" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_epv=$(echo "$tpv" | grep "epv" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_epx=$(echo "$tpv" | grep "epx" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_epy=$(echo "$tpv" | grep "epy" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_lat=$(echo "$tpv" | grep "lat" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_lon=$(echo "$tpv" | grep "lon" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_mode=$(echo "$tpv" | grep "mode" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_speed=$(echo "$tpv" | grep "speed" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
gpsd_track=$(echo "$tpv" | grep "track" | cut -d: -f2 | cut -d, -f1 | tr -d ' ')

gpsd_hostname=$(hostname)

if [ ! -z "$gpsd_lat" -a ! -z "$gpsd_lon" -a ! -z "$gpsd_alt" ]; then

    temp_data=$(mktemp /tmp/gpsd.XXXXXXXXX)
    
    # https://docs.influxdata.com/influxdb/v1.7/guides/writing_data/
    
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=alt value=$gpsd_alt" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=climb value=$gpsd_climb" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=epc value=$gpsd_epc" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=eps value=$gpsd_eps" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=ept value=$gpsd_ept" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=epv value=$gpsd_epv" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=epx value=$gpsd_epx" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=epy value=$gpsd_epy" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=lat value=$gpsd_lat" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=lon value=$gpsd_lon" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=mode value=$gpsd_mode" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=speed value=$gpsd_speed" >> $temp_data
    echo "gpsd,host=$gpsd_hostname,device="$gpsd_device",tpv=track value=$gpsd_track" >> $temp_data

    if [ $debug_output -eq 1 ]; then
        echo "--------------------------------------------------------------------------------"
        echo "TPV"
        echo "$tpv"
        echo "--------------------------------------------------------------------------------"
        echo "Sending to Influx:"
        cat $temp_data
        echo "--------------------------------------------------------------------------------"
    fi

    curl_result=$(curl -s -i -XPOST "$influx_url/write?db=$influx_db" --data-binary @$temp_data)

    if [ $debug_output -eq 1 ]; then
        echo "$curl_result"
    fi

    rm -f $temp_data
    
else
    if [ $debug_output -eq 1 ]; then
        echo "No GPS Fix - Not Sending Update"
        echo $tpv
        echo "--------------------------------------------------------------------------------"
    fi
fi

sleep $update_interval

unset tpv

unset gpsd_alt
unset gpsd_climb
unset gpsd_device
unset gpsd_epc
unset gpsd_eps
unset gpsd_ept
unset gpsd_epv
unset gpsd_epx
unset gpsd_epy
unset gpsd_lat
unset gpsd_lon
unset gpsd_mode
unset gpsd_speed
unset gpsd_time
unset gpsd_track

unset ns_timestamp
unset temp_data

done
