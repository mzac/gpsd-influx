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

## gpsd-influx script

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

# Important

