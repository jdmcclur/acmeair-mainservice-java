JMETER_HOME=${1}
SUT=${2}
THREADS=50

sleep 5

${JMETER_HOME}/bin/jmeter.sh -DusePureIDs=true -n -t AcmeAir-microservices-mpJwt-header.jmx -JHOST=${SUT} -JPORT=80 -JDURATION=10 -JTHREAD=1 -JRAMP=0 -JUSER=999
sleep 5
${JMETER_HOME}/bin/jmeter.sh -DusePureIDs=true -n -t AcmeAir-microservices-mpJwt-header.jmx -JHOST=${SUT} -JPORT=80 -JDURATION=60 -JTHREAD=${THREADS} -JRAMP=0 -JUSER=999
sleep 5
${JMETER_HOME}/bin/jmeter.sh -DusePureIDs=true -n -t AcmeAir-microservices-mpJwt-header.jmx -JHOST=${SUT} -JPORT=80 -JDURATION=180 -JTHREAD=${THREADS} -JRAMP=0 -JUSER=999
./getFootprint.sh ${SUT}
sleep 5
${JMETER_HOME}/bin/jmeter.sh -DusePureIDs=true -n -t AcmeAir-microservices-mpJwt-header.jmx -JHOST=${SUT} -JPORT=80 -JDURATION=180 -JTHREAD=${THREADS} -JRAMP=0 -JUSER=999
sleep 5
${JMETER_HOME}/bin/jmeter.sh -DusePureIDs=true -n -t AcmeAir-microservices-mpJwt-header.jmx -JHOST=${SUT} -JPORT=80 -JDURATION=300 -JTHREAD=${THREADS} -JRAMP=0 -JUSER=999

