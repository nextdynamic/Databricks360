#!/bin/bash

solutionname='adb360'
location='northcentralus'
subscriptionid='86ce20a8-27b2-40db-addc-106723cabeae'
serviceprincipalname='devops-sc'
adbinteractprincipalname='adb360-sp'
locationshortname='ncus'

# Debugging
# set -x

month=$(date -d "$D" '+%m')
day=$(date -d "$D" '+%d')

dailysolutionname="$solutionname$month$day"
echo "solution name: $dailysolutionname"

rgDev="rg-$locationshortname-$dailysolutionname-dev"
rgPrd="rg-$locationshortname-$dailysolutionname-prd"

# get service principal object id
serviceprincipaloid=$(az ad sp list --display-name $serviceprincipalname --query "[].id" -o tsv)
# serviceprincipaloid=$(az ad sp list --display-name $serviceprincipalname --query "[0].id" -o json | sed 's/"//g')
echo "found $serviceprincipaloid for devops-sc"

#adbspoid=$(az ad sp list --display-name $adbinteractprincipalname --query "[0].id" -o json | sed 's/"//g')
adbspoid=$(az ad sp list --display-name $adbinteractprincipalname --query "[0].id" -o tsv)
echo "found $adbspoid for adb-sp"

erg=$(az group list --query "[?name=='$rgDev'].name" -o tsv)
if [ -z "$erg" ] 
    then 
        echo 'resourcegroup does not exist, create it'
        az group create -n $rgDev -l $location
        
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
        az role assignment create --role 'Contributor' --assignee $adbspoid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgDev"
    else
        echo 'resourcegroup exists, delete and recreate it'
        az group delete -n $rgDev -y
        az group create -n $rgDev -l $location
        az role assignment create --role 'Contributor' --assignee ${serviceprincipaloid} --scope "/subscriptions/${subscriptionid}/resourceGroups/${rgDev}"
        az role assignment create --role 'Contributor' --assignee ${adbspoid} --scope "/subscriptions/${subscriptionid}/resourceGroups/${rgDev}"
        az role assignment create --role 'User Access Administrator' --assignee ${serviceprincipaloid} --scope "/subscriptions/${subscriptionid}/resourceGroups/${rgDev}"
fi

erg=$(az group list --query "[?name=='$rgPrd'].name" -o tsv)
if [ -z "$erg" ] 
    then 
        echo 'resourcegroup does not exist, create it'
        az group create -n $rgPrd -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgPrd"
        az role assignment create --role 'Contributor' --assignee $adbspoid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgPrd"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgPrd"
    else
        echo 'resourcegroup exists, delete and recreate it'
        az group delete -n $rgPrd -y
        az group create -n $rgPrd -l $location
        az role assignment create --role 'Contributor' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgPrd"
        az role assignment create --role 'Contributor' --assignee $adbspoid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgPrd"
        az role assignment create --role 'User Access Administrator' --assignee $serviceprincipaloid --scope "/subscriptions/$subscriptionid/resourceGroups/$rgPrd"
fi

echo 'finished'