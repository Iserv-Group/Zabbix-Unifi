# Overview
 The purpose of this script is to monitor the up status of Unifi devices that are connected to a cloud controller through Zabbix. This is accomplished by making API calls against a Unifi controller using the external scripts function in Zabbix. Because this script uses external checks exclusively, everything is checked on the Zabbix server.
## Script Details
 To allow for separation of the controller credentials from Zabbix, there are two scripts, the unifi_status.sh script pulls data from the API and outputs it to a json file for the unifi.sh script that is used by Zabbix for discovery and status purposes.
## Templated Zabbix items and triggers
 The template is configured to create low priority alerts after a few minutes if a device or entire network becomes unreachable, then create increasingly higher priority alerts if the devices remain offline. The discovery process creates a single host within Zabbix for each Unifi site and adds it to a group based off its site name in on the controller. 
 Alerts for discovered devices are dependent on an alert for the entire site. This is to reduce alerting to a single alarm if all the devices at a site go offline at the same time. 
# Installation
 1.	Start by downloading the repository and moving both scripts to your Zabbix installation.
 2.	Place the unifi_status.sh script in a secure location on the Zabbix server and limit the read/write privileges on the script to super users to protect your API key. 
 3.	Modify the variables at the top of the unifi_status.sh script
	1. Enter the URL or IP of your controller
	2.	Add credentials for the API to use
	3. Change the output folder to the location of the externalscripts folder of your Zabbix installation 
 4. Place the unifi.sh script in the externalscripts folder.
 5. Modify the folder variables at the top of the unifi.sh script to match your installation 
 6.	Run the unifi_status.sh script to see if a valid json file is created at externalscripts/unifi.json
 7.	Assuming the test was successful, add the following line to a crontab that has privileges to read/execute both scripts. Make sure to use the full path to the script, instead of the example below. 

 ```
 * * * * * /home/user/scripts/unifi_status.sh
 ```

 8. Import the template into Zabbix
 9. Create a Host Group with the name of Ubiquiti/Unifi and give permissions to your users. 
 10. Apply the Unifi Site Discovery template to your Zabbix host, then run the discovery rule. 
