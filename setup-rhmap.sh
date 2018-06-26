#!/bin/bash
echo " "
echo "___  ____       _     _     _  __ _        ______ _   _ ___  ___  ___  ______ "
echo "|  \/  (_)     (_)   | |   (_)/ _| |       | ___ \ | | ||  \/  | / _ \ | ___ \\"
echo "| .  . |_ _ __  _ ___| |__  _| |_| |_   __ | |_/ / |_| || .  . |/ /_\ \| |_/ /"
echo "| |\/| | | '_ \| / __| '_ \| |  _| __| |__||    /|  _  || |\/| ||  _  ||  __/ "
echo "| |  | | | | | | \__ \ | | | | | | |_      | |\ \| | | || |  | || | | || |    "
echo "\_|  |_/_|_| |_|_|___/_| |_|_|_|  \__|     \_| \_\_| |_/\_|  |_/\_| |_/\_|    "
echo " "
echo " "

                                                                               

function Progress {
	let precentage=(${1}*100/${2}*100)/100
	let done=(${precentage}*6)/10
	let undone=60-$done
# Build progressbar string lengths
	done=$(printf "%${done}s")
	undone=$(printf "%${undone}s")
# Output example:
# Progress : [####################--------------------] 50%
printf "\rProgress : [${done// /#}${undone// /-}] ${precentage}%%"

}


# login to docker
docker login

echo Enter your minishift ip only e.g. 192.168.64.4:
read IP
echo " "
echo $IP
echo " "
echo "IP address set in inventory file"

# Create inventory file and add your Minishift IP address
rm ~/minishift-example
cp minishift-example ~/minishift-example

# Check for os because sed works differently on linux and mac
if [[ "$OSTYPE" == "linux-gnu" ]]
then
    echo "Linux detected"
    sed -i "s/ip_address/${IP}/g" ~/minishift-example
elif [[ "$OSTYPE" == "darwin"* ]]
then
    echo "OSX detected"
    sed -i '' "s/ip_address/${IP}/g" ~/minishift-example
fi

# # setting the docker pull secret for any new pod
oc login https://$IP:8443 -u developer -p developer

# kill and remove existing observe process
kill $(ps aux | grep '[o]c_observe_dev' | awk '{print $2}')

chmod +x ./oc_observe_dev.sh
echo "premissions set on oc obeserve script"
oc observe projects -- ./oc_observe_dev.sh > /dev/null 2>&1 &
echo "observe project and set secret"


# Delete existing project if "./setup-rhmap.sh -c"
if [[ $1 = "-c" ]]
then
    echo "Deleting existing projects"
    oc delete project rhmap-core > /dev/null 2>&1
    oc delete project rhmap-1-node-mbaas > /dev/null 2>&1
    oc delete project $(oc projects | grep 'RHMAP Environment' | awk '{print $1}') > /dev/null 2>&1
    echo "Waiting for OpenShift to remove projects"
    echo " "
    echo " "
fi
# create the projects
i=200
until oc new-project rhmap-1-node-mbaas > /dev/null 2>&1 && oc new-project rhmap-core > /dev/null 2>&1
do
    sleep 0.1
    num=$[$num+1]
    if (( $num < $i ))
    then
        Progress ${num} ${i}
    fi
done
Progress ${i} ${i}
echo " "
echo " "

# checkout the correct branch e.g. release-4.6.0-rc1
echo "enter branch/tag name e.g. release-4.6.0-rc1:"
read branch

cd ~/work/fh-openshift-templates
git checkout master 
git pull upstream master
git fetch upstream master --prune --tags
git checkout "$branch"
cd ~/work/fh-core-openshift-templates
git checkout master 
git pull upstream master
git fetch upstream master --prune --tags
git checkout "$branch"
cd ~/work/rhmap-ansible
git checkout master 
git pull upstream master
git fetch upstream master --prune --tags
git checkout "$branch"


# ansible installer for rhmap
sudo ansible-playbook -i ~/minishift-example --tags=deploy -e strict_mode=false -e core_templates_dir=~/work/fh-core-openshift-templates/generated -e mbaas_templates_dir=~/work/fh-openshift-templates -e mbaas_target_id=test playbooks/core.yml
sudo ansible-playbook -i ~/minishift-example --tags=deploy -e strict_mode=false -e core_templates_dir=~/work/fh-core-openshift-templates/generated -e mbaas_templates_dir=~/work/fh-openshift-templates -e mbaas_target_id=test playbooks/1-node-mbaas.yml

# details for rhmap
echo " "
echo " "
echo " _____ _             _ _             _        __      "
echo "/  ___| |           | (_)           (_)      / _|     "
echo "\ \`--.| |_ _   _  __| |_  ___   ___  _ _ __ | |_ ___  "
echo " \`--. \ __| | | |/ _\` | |/ _ \ |___|| | '_ \|  _/ _ \ "
echo "/\__/ / |_| |_| | (_| | | (_) |     | | | | | || (_) |"
echo "\____/ \__|\__,_|\__,_|_|\___/      |_|_| |_|_| \___/ "
echo " "
echo " "
oc project rhmap-core > /dev/null 2>&1
echo "RHMAP Studio URL : "
echo "https://"$(oc get route/rhmap -o template --template {{.spec.host}})
echo " "
echo "RHMAP Studio Login Details : "
echo "Studio login = "$(oc set env pod/$(oc get pods | grep 'millicore' | awk '{print $1}') --list | grep FH_ADMIN_USER_NAME | awk -F'=' '{print $2}')
echo "Studio password = "$(oc set env pod/$(oc get pods | grep 'millicore' | awk '{print $1}') --list | grep FH_ADMIN_USER_PASSWORD | awk -F'=' '{print $2}')
echo " "
echo " "
echo "Openshift Console URL :"
echo "https://${IP}:8443/console/"
echo " "
echo " "
echo "___  ____                            _____           "
echo "|  \/  | |                          |  ___|          "
echo "| .  . | |__   __ _  __ _ ___   ___ | |__ _ ____   __"
echo "| |\/| | '_ \ / _\` |/ _\` / __| |___||  __| '_ \ \ / /"
echo "| |  | | |_) | (_| | (_| \__ \      | |__| | | \ V / "
echo "\_|  |_/_.__/ \__,_|\__,_|___/      \____/_| |_|\_/  "
echo " "
echo " "
oc project rhmap-1-node-mbaas > /dev/null 2>&1
echo "DETAILS FOR CREATING AN MBAAS TARGET AND ENVIRONMENT IN RHMAP"
echo " "
echo "Mbaas key : "
oc env dc/fh-mbaas --list | grep FHMBAAS_KEY
echo " "
echo "Mbaas url :"
echo "https://"$(oc get route/mbaas -o template --template {{.spec.host}})
echo " "
# `oc whoami -t` generates a one time token
echo "oAuth token for enviroment setup :"
echo "https://${IP}:8443/oauth/token/request "
oc whoami -t



                                                     