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

# Important

