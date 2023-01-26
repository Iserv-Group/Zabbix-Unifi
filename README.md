# Overview
 The purpose of these templates is to monitor the up status of Unifi devices that are connected to a cloud or Dream Machine controller through Zabbix. This is accomplished by making API calls against a Unifi controller using the built-in script item in Zabbix. Because these templates use the built-in script item, it can easily be deployed on the Zabbix server, or any proxy that has web access to the controller.
 ## Script Details
 This repository contains four different templates. Two of them work together to monitor standard Unifi controllers, the other are copies of the first with slight adjustments to monitor Dream Machines
## Templated Zabbix items and triggers
 The template is configured to create low priority alerts after a few minutes if a device or entire network becomes unreachable, then create increasingly higher priority alerts if the devices remain offline. The discovery process creates a single host within Zabbix for each Unifi site and adds it to a group based off its site name on the controller. 
Alerts for discovered devices are dependent on an alert for the entire site. This is to reduce alerting to a single alarm if all the devices at a site go offline at the same time. 
# Setup
 1.	Download the yaml template file. 
 2. Import the file into your Zabbix installation
 3. Create a host for each Controller/Dream Machine you would like to monitor
 4. After attaching the relevant site discovery template, switch to the macros tab and provide values for base_url, username and password. Base_url should include a trailing slash.
 
 
