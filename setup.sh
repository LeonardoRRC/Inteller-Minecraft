#!/bin/bash

plugin_id1="103183"
plugin_id2="57242"
file_name1="neoperformance.jar"
file_name2="spark.jar"

if [ ! -d "plugins" ]; then
    mkdir plugins
fi

cd plugins

if [ ! -f "$file_name1" ]; then
    download_url1=$(curl -s "https://api.spiget.org/v2/resources/$plugin_id1/download" | jq -r '.url')
    wget -O "$file_name1" "$download_url1"
fi

if [ ! -f "$file_name2" ]; then
    download_url2=$(curl -s "https://api.spiget.org/v2/resources/$plugin_id2/download" | jq -r '.url')
    wget -O "$file_name2" "$download_url2"
fi

cd ..

java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar server.jar
