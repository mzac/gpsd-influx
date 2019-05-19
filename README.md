# gpsd-influx

# Introduction
This script can be run as a daemon to collect information from a GPS and push it into an Influx Database.  This can be useful for tracking or for monitoring GPS drift.

# Reference
This script parses the GPSD Json output:

http://catb.org/gpsd/gpsd_json.html

# Requirements
* A GPS
* A dedicated computer to run the daemon on (I use a Raspberry Pi B)
* gpsd (http://www.catb.org/gpsd/)
* Influx database (https://www.influxdata.com/)

# Optional
* Grafana for visualizing the data (https://grafana.com/)

# Todo
- [ ] Create Docker Image

# Installation
## InfluxDB
Installation instructions for InfluxDB: https://docs.influxdata.com/influxdb/v1.7/introduction/installation/

Once you have Influx installed, then run the following commands to create a database for gpsd:
```
influx
CREATE DATABASE "gpsd"
```

If you only want to keep data for a specific number of days:
```
influx
CREATE DATABASE "gpsd" WITH DURATION 30d
```

## gpsd

Debian based install
```
apt-get update
apt-get install -y gpsd
```

Once it is intalled, make sure to edit */etc/default/gpsd* and change the *DEVICES* line to match the device for your GPS, ex:
```
# Default settings for the gpsd init script and the hotplug wrapper.

# Start the gpsd daemon automatically at boot time
START_DAEMON="true"

# Use USB hotplugging to add new USB devices automatically to the daemon
USBAUTO="true"

# Devices gpsd should collect to at boot time.
# They need to be read/writeable, either by user gpsd or the group dialout.
DEVICES="/dev/ttyUSB0"

# Other options you want to pass to gpsd
GPSD_OPTIONS=""
```

Enable and start gpsd
```
systemctl enable gpsd.sock
systemctl start gpsd.sock
```

If your gps is connected you can test that it is working by running the following command:
```
gpspipe -w -n 5
{"class":"VERSION","release":"3.16","rev":"3.16-4","proto_major":3,"proto_minor":11}
{"class":"DEVICES","devices":[{"class":"DEVICE","path":"/dev/ttyUSB0","driver":"SiRF","subtype":"9\u0006GSD4e_4.1.2-B2_RPATCH.02-F-GPS-4R-1301151 01/17/2013 017","activated":"2019-05-19T14:34:37.601Z","flags":1,"native":1,"bps":4800,"parity":"N","stopbits":1,"cycle":1.00}]}
{"class":"WATCH","enable":true,"json":true,"nmea":false,"raw":0,"scaled":false,"timing":false,"split24":false,"pps":false}
{"class":"TPV","device":"/dev/ttyUSB0","mode":3,"time":"2019-05-19T14:34:39.000Z","ept":0.005,"lat":45.xxxxxxxxxx,"lon":-73.xxxxxxxxxx,"alt":42.110,"epx":8.341,"epy":14.615,"epv":32.200,"track":0.0000,"speed":0.000,"climb":0.000,"eps":29.23,"epc":64.40}
```

On the TPV line you should see your latitude and longitude displayed.

# gpsd-influx script
Now that 

# Important

