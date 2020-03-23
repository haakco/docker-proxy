#!/bin/sh

while read LINE; do
    echo $LINE |
    sed -E -e 's|http://download.oracle.com/otn-pub/java/jdk/(.+)\?.+|OK store-id=http://download.oracle.com/otn-pub/java/jdk/\1|'
done


