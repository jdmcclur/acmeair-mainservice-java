
## Acme Air - Quarkus Experiments

## Prerequisites
You will need mongo DB running on another machine. I am running with 3.6.23, which is old. I also put the db in memory, which may not be necessary.
```
mkdir /ramdisk_mongo
mount -o size=8G -t tmpfs none /ramdisk_mongo/
mkdir -p /ramdisk_mongo/data/db
./mongod --dbpath /ramdisk_mongo/data/db --bind_ip_all --fork --logpath=/ramdisk_mongo/mongo.log --logappend
```

Clone the five services into the same directory.
```
mkdir acmeair
cd acmeair
git clone -b quarkus-exp git@github.com:jdmcclur/acmeair-authservice-java.git
git clone -b quarkus-exp git@github.com:jdmcclur/acmeair-bookingservice-java.git
git clone -b quarkus-exp git@github.com:jdmcclur/acmeair-customerservice-java.git
git clone -b quarkus-exp git@github.com:jdmcclur/acmeair-flightservice-java.git
git clone -b quarkus-exp git@github.com:jdmcclur/acmeair-mainservice-java.git
```

## Build Instructions
Update the following line in the files below with where mongo DB is running.
```
ENV QUARKUS_MONGODB_CONNECTION_STRING=mongodb://10.16.112.86:27017
```
```
acmeair-bookingservice-java/Dockerfile.quarkus.native
acmeair-bookingservice-java/Dockerfile.quarkus.semeru
acmeair-customerservice-java/Dockerfile.quarkus.native
acmeair-customerservice-java/Dockerfile.quarkus.semeru
acmeair-flightservice-java/Dockerfile.quarkus.native
acmeair-flightservice-java/Dockerfile.quarkus.semeru
```


### Build Quarkus Native images
```
cd acmeair-mainservice-java
./build.native.all.sh
```

### Build Semeru CRIU images.
Insert the security token into the .env file. (You can ask me for it).
```
CRIU_AUTH_HEADER="Authorization: Bearer REPLACE_WITH_TOKEN"
```

```
cd acmeair-mainservice-java
./build.semeru.all.sh
```

Note: You may need to change to a newer JDK build (line 93) or newer Tomcat build (line 132) in Dockerfile.semeru.criu.

## Test First Request and Footprint at First Request

I test authservice for footprint at first request (and under load) on 1 cpu.
```
cd acmeair-mainservice-java
mkdir logs
./testFirstRequest.sh [IMAGE] [NUMBER_OF_CPUS]
```

Example(s)
```
./testFirstRequest.sh quarkus-native-authservice 1
./testFirstRequest.sh quarkus-semeru-authservice 1
```


## Throughput Instructions

Start the services and (re)load the DB.
```
cd acmeair-mainservice-java
./start.native.all.sh  (or ./start.semeru.all.sh)
./load.sh
```

## On another machine (the driver), configure and run jmeter.

### Download and unzip Apache JMeter. https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip (/opt/apache-jmeter-5.6.3/ for this example)

### Edit the following /opt/apache-jmeter-5.6.3/bin/jmeter.properties
```
#---------------------------------------------------------------------------
# Summariser - Generate Summary Results - configuration (mainly applies to non-GUI mode)
#---------------------------------------------------------------------------
#
# Comment the following property to disable the default non-GUI summariser
# [or change the value to rename it]
# (applies to non-GUI mode only)
summariser.name=summary
#
# interval between summaries (in seconds) default 30 seconds
summariser.interval=5
#
# Write messages to log file
summariser.log=true
#
# Write messages to System.out
summariser.out=true
```

### Also edit this line to enable saving cookies
```
CookieManager.save.cookies=true
```

### Copy the files in jmeter-files to the driver.
### Then copy acmeair-jmeter-1.1.0-SNAPSHOT.jar and json-simple-1.1.1.jar to  /opt/apache-jmeter-5.6.3/lib/ext/

### The getFootprint.sh script gets the footprint measurement after heavy load. This script needs to access (ssh) the System Under Test without needing a password. So you will need to allow that (or comment it out of the runAcmeAirMS.sh script).

### Run Jmeter
```
./runAcmeAirMS.sh [JMETER_HOME] [SUT]
```
Example:
```
./runAcmeAirMS.sh /opt/apache-jmeter-5.6.3 checkers06.rtp.raleigh.ibm.com
```

The throughput measurement is the summary number of the last 5:00 run (The last summary = line of the last run). (805.1 below)
```
summary = 244400 in 00:05:04 =  805.1/s Avg:    61 Min:     0 Max:  4438 Err:     0 (0.00%)
```

Stop the services on the SUT.
```
podman stop -a
```
