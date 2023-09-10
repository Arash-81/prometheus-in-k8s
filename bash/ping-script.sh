#!/bin/bash

ping_count=5
ping_file=/data/ping.txt
lock_file=/data/lock
touch $ping_file
touch $lock_file
echo "mutex is 0" > $lock_file

function getPing() {
    ping -c  $ping_count $1 > domain_info
    packet_loss=$(awk -v count="$ping_count" 'NR == (count + 4) {print $6}' domain_info | sed 's/%//')
    avg_ping=$(awk -v count="$ping_count" 'NR == (count + 5) {print $4}' domain_info | cut -d'/' -f2)
    min_ping=$(awk -v count="$ping_count" 'NR == (count + 5) {print $4}' domain_info | cut -d'/' -f1)
    max_ping=$(awk -v count="$ping_count" 'NR == (count + 5) {print $4}' domain_info | cut -d'/' -f3)
    jitter=$(echo "$max_ping - $min_ping" | bc)
    ip=$(awk 'NR == 1 {print $3}' domain_info | sed 's/[()]//g')

    echo "$1 jitter $jitter" >> $ping_file
    echo "$1 packet_loss $packet_loss" >> $ping_file
    echo "$1 avg_ping $avg_ping" >> $ping_file
}

while :; do
    if [[ "$(<$lock_file)" = "mutex is 0" ]]; then
        while IFS= read -r line
        do
            getPing $line
        done < /my-domain/urls
        echo "mutex is 1" > $lock_file
        sleep 30
    else
        sleep 5
    fi
done
