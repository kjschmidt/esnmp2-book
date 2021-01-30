#!/bin/sh

JAVA=java
CP=./SNMP4J.jar:log4j-1.2.9.jar:.

${JAVA} -cp ${CP} MainSnmpV2Receiver
echo ${JAVA} -cp ${CP} MainSnmpV2Receiver
