#!/bin/bash

API_URL="$1"
TOKEN="$2"
USER_NUMBER="$3"

function show_usage {
   echo " Invalid number of arguments "
   echo " Usage: $(basename $0) <Api_url> <Token> <User_count> respectively "
   exit 1
}

#Main

if [[ $# -le 2 ]] # if user enter less than 3 arguments exit with below echo message.
    then
        show_usage
elif [[ $# -ge 4 ]] # if user enter more than 3/required argument exit with usage.
    then
        show_usage
else
    oc login $API_URL --token=$TOKEN
fi

oc scale deployments/opendatahub-operator --replicas=0 -n openshift-operators

sleep 5

# Loop over given user number to patch each deployment config.

for (( c=1; c<=$USER_NUMBER; c++ ))
do 
oc patch dc/jupyterhub -p '{"spec":{"template":{"spec":{"containers":[{"name":"jupyterhub","image":"quay.io/odh-jupyterhub/jupyterhub-img:v0.1.5"}]}}}}' -n opendatahub-user$c

oc patch dc/jupyterhub -p '{"spec":{"template":{"spec":{"initContainers":[{"name":"wait-for-database","image":"quay.io/odh-jupyterhub/jupyterhub-img:v0.1.5"}]}}}}' -n opendatahub-user$c

sleep 2
echo "patching completed for user$c"
done
