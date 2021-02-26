#!/bin/bash

#Login details
controller="1.1.1.1" #Domain name or IP of Unifi controller
port="8443" #Port number used for API calls. Should be same port number used to access the web interface. 
username="EnterYourControllerUsernameHere"
password="EnterYourControllerPasswordHere"
output_folder=$(echo "/usr/lib/zabbix/externalscripts/") #Folder where the two .json output files will be saved
#Login and retreive session cookies
#Use the -k option to not check the SSL certificate
curl -k -c cookies.tmp --location --request POST "https://$controller:$port/api/login" --header 'Content-Type: application/json' --data-raw "{\"username\": \"$username\",\"password\": \"$password\"}"

#Pull site info
curl -k -b cookies.tmp --location --request GET "https://$controller:$port/api/self/sites" --header 'Content-Type: application/json' | jq '(.[] | .[])' | jq -s > $output_folder"unifi_sites.json"

#Pulls device details for all sites
#Pull list of Site "Names" used for further discovery(Not the site name found in the dashboard)
IFS=$'\n' sites=(`curl -k -b cookies.tmp --location --request GET "https://$controller:$port/api/self/sites" --header 'Content-Type: application/json' | jq '(.[] | .[])' | grep -v "ok" |jq 'select(.name != "default")' | jq -r .name`)
#Loop through each site and discover devices at each site. Saves all output to a temp file
for i in "${sites[@]}"; do
	curl -k -b cookies.tmp --location --request GET "https://$controller:$port/api/s/$i/stat/device-basic" --header 'Content-Type: application/json' | jq '(.[] | .[])' | grep -v "ok" | jq -s --arg var "$i" 'map(.site_name = $var)' >> $output_folder"unifi_devices.tmp"
done

#Move contents of temp file to production json file. 
mv -f $output_folder"unifi_devices.tmp" $output_folder"unifi_devices.json"

