#!/bin/bash

echo ""
echo "======= Vision Kube - Dockerized LTU 7.63, Traefik 0.1, Mungehosts win a Centos 6.0 Distribution"
echo "======= Deactivate the image storage for an application"
echo "======= Luc Michalski - 2015"
echo ""

ltud stop collector
ltud stop weki

# Need to find a way to get rest api binding some shellscripts or golang services to execute such cleaning
export MY_APPLICATION_KEY='app_key' 

dir_to_delete=`psql -p 7791 saas_si -qtc "update application_property set value=false from application where application_property.name='save_ref_image' and 
application.id_application=application_property.id_application and application.application_key='$MY_APPLICATION_KEY';select sw_conf.value || '/' || client.folder_path || '/' || 
application_property.value from application, application_property, sw_conf, client where application.id_application = application_property.id_application and client.id_client = 
application.id_client and sw_conf.name='storage_root_folder_path' and application_key='$MY_APPLICATION_KEY' and application_property.name='folder_path';"`

rm -rf $dir_to_delete/*

ltud start collector 
ltud start weki
