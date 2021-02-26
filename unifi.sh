#!/bin/bash

#Location of the externalscripts folder as seen by Zabbix
output_folder=$(echo "/usr/lib/zabbix/externalscripts/")

if [ "$1" == "site.discovery" ]; then
	IFS=$'\n' site_alias=(`cat $output_folder"unifi_sites.json" | jq .[] | grep -v ok | jq 'select(.desc == "Default" | not)' | jq "select(.desc | contains(\"IGNORE\") | not)" | jq -r .desc`)
	IFS=$'\n' site_name=(`cat $output_folder"unifi_sites.json" | jq .[] | grep -v ok | jq 'select(.desc == "Default" | not)' | jq "select(.desc | contains(\"IGNORE\") | not)" | jq -r .name`)
	IFS=$'\n' site_id=(`cat $output_folder"unifi_sites.json" | jq .[] | grep -v ok | jq 'select(.desc == "Default" | not)' | jq "select(.desc | contains(\"IGNORE\") | not)" | jq -r ._id`)
	c=0
	#Prepare json head and tail
	json_head="{\"data\":["
	json_tail="]}"
	json=$json_head
	for b in "${site_alias[@]}"; do
		#Convert site details to format for jq script
		#Declare 
		s1=$(echo '{#SITE_ALIAS}|{#SITE_NAME}|{#SITE_ID}')
		s2=$(echo $b"|"${site_name[c]}"|"${site_id[c]})
		s="${s1}"$'\n'"${s2}"
		#Convert to json
		json+=$(jq -Rn '
		( input  | split("|") ) as $keys |
		( inputs | split("|") ) as $vals |
		[[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries
		' <<<"$s")
		json+=","
		c=$c+1
	done
	json=$(echo ${json::-1})
	json+=$json_tail
	echo $json
fi
if [ "$1" == "device.discovery" ]; then
	IFS=$'\n' mac=(`cat $output_folder"unifi_devices.json" | jq --arg var "$2" '.[] | select(.site_name == $var)' | jq 'select(.disabled == false)' | jq -r .mac`)
	IFS=$'\n' name=(`cat $output_folder"unifi_devices.json" | jq --arg var "$2" '.[] | select(.site_name == $var)' | jq 'select(.disabled == false)' | jq -r .name`)
	c=0
	#Prepare json head and tail
	json_head="{\"data\":["
	json_tail="]}"
	json=$json_head
	for b in "${name[@]}"; do
		#Convert site details to format for jq script
		#Declare 
		s1=$(echo '{#DEVICE_NAME}|{#MAC}')
		s2=$(echo $b"|"${mac[c]})
		s="${s1}"$'\n'"${s2}"
		#Convert to json
		json+=$(jq -Rn '
		( input  | split("|") ) as $keys |
		( inputs | split("|") ) as $vals |
		[[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries
		' <<<"$s")
		json+=","
		c=$c+1
	done
	json=$(echo ${json::-1})
	json+=$json_tail
	echo $json
fi
if [ "$1" == "site.status" ]; then
	cat $output_folder"unifi_devices.json" | jq --arg var1 "$2" '(.[] | select(.site_name == $var1)).state' | sort -r | head -1
fi
if [ "$1" == "device.status" ]; then
	cat $output_folder"unifi_devices.json" | jq --arg var1 "$2" '(.[] | select(.mac == $var1))' | jq -r .state
fi
#Pulls full json list for every device at a site
if [ "$1" == "site.data" ]; then
	cat $output_folder"unifi_devices.json" | jq --arg var1 "$2" '(.[] | select(.site_name == $var1))' | jq -s
fi
