
JAVAC=javac
CP=./SNMP4J.jar:log4j-1.2.9.jar:.

all: snmpset snmpwalk snmptrap v2trapreceiver v3trapreceiver

snmpset:
	${JAVAC} -cp ${CP} MainSnmpSet.java

snmpwalk:
	${JAVAC} -cp ${CP} MainSnmpWalk.java

snmptrap:
	${JAVAC} -cp ${CP} MainSnmpTrap.java

v2trapreceiver:
	${JAVAC} -cp ${CP} MainSnmpV2Receiver.java

v3trapreceiver:
	${JAVAC} -cp ${CP} MainSnmpV3Receiver.java

clean:
	rm *.class
