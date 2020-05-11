# Introduction
This script can be run as a daemon to collect information from a GPS and push it into an Influx Database.  This can be useful for tracking or for monitoring GPS drift.

![grafana dashboard](https://github.com/mzac/gpsd-influx/blob/master/gpsd-grafana.png)

* Grafana Dashboard: https://grafana.com/dashboards/10226
* Dashboard Source: https://github.com/mzac/gpsd-influx/blob/master/gpsd-1558277406816.json

# Reference
* JSON output of gpspipe: http://catb.org/gpsd/gpsd_json.html

* GPS on Raspberry Pi: http://wiki.dragino.com/index.php?title=Getting_GPS_to_work_on_Raspberry_Pi_3_Model_B

# Requirements
* A serial GPS
* A dedicated computer to run the daemon on (I use a Raspberry Pi B)
* gpsd (http://www.catb.org/gpsd/)
* InfluxDB (https://www.influxdata.com/)
* Python

# Optional
* Grafana for visualizing the data (https://grafana.com/)

# Todo
- [ ] Create Docker Image
- [x] Re-write script in Python (done but needs testing)

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
{"class":"TPV","device":"/dev/ttyUSB0","mode":3,"time":"2019-05-19T14:34:39.000Z","ept":0.005,"lat":45.xxxxxxxxx,"lon":-73.xxxxxxxxx,"alt":42.110,"epx":8.341,"epy":14.615,"epv":32.200,"track":0.0000,"speed":0.000,"climb":0.000,"eps":29.23,"epc":64.40}
```

On the TPV line you should see your latitude and longitude displayed.

# gpsd-influx script
Now that gpsd is installed and working, you can install the script.

```
git clone https://github.com/mzac/gpsd-influx.git /opt/gpsd-influx
chmod a+x /opt/gpsd-influx/gpsd-influx.sh
```

Edit the script and make sure to change the variables at the top to match your configuration:
```
# Your InfluxDB Server
influx_url="http://influx.lab.local:8086"
# Your InfluxDB Database
influx_db="gpsd"
# Number of seconds between updates
update_interval=10
```

Once that is complete, you can test the script with the debug flag:
```
/opt/gpsd-influx/gpsd-influx.sh -d
--------------------------------------------------------------------------------
TPV
{
    "alt": 38.627,
    "class": "TPV",
    "climb": 0.0,
    "device": "/dev/ttyUSB0",
    "epc": 64.4,
    "eps": 29.23,
    "ept": 0.005,
    "epv": 32.2,
    "epx": 8.341,
    "epy": 14.615,
    "lat": 45.xxxxxxxxx,
    "lon": -73.xxxxxxxxx,
    "mode": 3,
    "speed": 0.0,
    "time": "2019-05-19T14:40:12.000Z",
    "track": 0.0
}
--------------------------------------------------------------------------------
Sending to Influx:
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=alt value=38.627
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=climb value=0.0
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=epc value=64.4
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=eps value=29.23
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=ept value=0.005
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=epv value=32.2
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=epx value=8.341
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=epy value=14.615
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=lat value=45.xxxxxxxxx
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=lon value=-73.xxxxxxxxx
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=mode value=3
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=speed value=0.0
gpsd,host=pi-gpsd,device="/dev/ttyUSB0",tpv=track value=0.0
--------------------------------------------------------------------------------
HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: 04355c63-7a44-11e9-9970-0242ac130002
X-Influxdb-Build: OSS
X-Influxdb-Version: 1.7.6
X-Request-Id: 04355c63-7a44-11e9-9970-0242ac130002
Date: Sun, 19 May 2019 14:40:15 GMT

```
If you didn't get any errors you should be good to go to setup the script to run as a daemon.

```
cat <<EOF >> /etc/systemd/system/gpsd-influx.service

[Unit]
Description=GPSD to Influx
After=syslog.target

[Service]
ExecStart=/opt/gpsd-influx/gpsd-influx.sh
KillMode=process
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF
```

Now you can enable and start the daemon:
```
systemctl enable gpsd-influx.service
systemctl start gpsd-influx.service
```
