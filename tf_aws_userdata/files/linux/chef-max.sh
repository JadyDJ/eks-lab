#!/bin/bash

CHEF_RUNLIST="${chef_role}"
CHEF_ENV="${chef_env}"
INTERVAL="${chef_interval}"
S3_BUCKET="jdtest-terraform-states"
COOKBOOK="${chef_cookbook}"
INPUTVERSION="${chef_cookbook_version}"
version="$(chef-client --version)"
#my_region="$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)"
#my_region="us-east-1"
# CURL_ARG="--connect-timeout 5 --max-time 30 --retry 5 --retry-delay 0"
# --max-time 30     (how long each retry will wait)
# --retry 5         (it will retry 5 times)
# --retry-delay 0   (an exponential backoff algorithm)
# --retry-max-time  (total time before it's considered failed)

if [[ $version == *"Chef: 11"* ]]
    then
    (echo "version=12.12.15"; curl $${CURL_ARG} -L $${S3_BUCKET}/utils/install.sh) | bash;
fi

if [[ $INPUTVERSION == *"latest"* ]]
then
    VERSION="%5BRELEASE%5D"
else
    VERSION="$${INPUTVERSION}"
fi

mkdir -p /etc/chef
# curl $${CURL_ARG} -o /etc/chef/merge.sh "$${S3_BUCKET}/utils/merge.sh"
# curl $${CURL_ARG} -o /etc/chef/chef-max.sh "$${S3_BUCKET}/utils/chef-max.sh"
# curl $${CURL_ARG} -o /etc/chef/cookbooks.tar.gz "$${S3_BUCKET}/cookbooks/$${COOKBOOK}/$${COOKBOOK}.$${VERSION}.tar.gz"
s3 cp --region us-east-1 s3://${S3_BUCKET}/utils/merge.sh  /etc/chef/merge.sh
s3 cp --region us-east-1 s3://${S3_BUCKET}/utils/chef-max.sh /etc/chef/chef-max.sh
s3 cp --region us-east-1 s3://${S3_BUCKET}/cookbooks/${COOKBOOK}/${COOKBOOK}.${VERSION}.tar.gz /etc/chef/cookbooks.tar.gz
cd /etc/chef && tar -xvf cookbooks.tar.gz && echo ${S3_BUCKET}/cookbooks/$${COOKBOOK}/$${COOKBOOK}.$${VERSION}.tar.gz > artifactory-value && rm -rf /etc/chef/cookbooks.tar.gz
cd /etc/chef && echo $${CHEF_ENV} > env-value && echo ${COOKBOOK} > cookbook-value && echo $${CHEF_RUNLIST} > roles-value && chmod 777 merge.sh && chmod 777 chef-max.sh && ./merge.sh cookbooks/$${COOKBOOK}/environments/$${CHEF_ENV}.json cookbooks/$${COOKBOOK}/roles/$${CHEF_RUNLIST}.json > json_attribs.json
echo 'export PATH=$PATH:/etc/chef' >> ~/.bashrc && source ~/.bashrc
mkdir -p /var/log/chef
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
HOSTNAME=$(hostname)
NODE_ID="$${INSTANCE_ID}--$${HOSTNAME}"
echo  "
log_level               :info
log_location            \"/var/log/chef/client.log\"
local_mode              true
node_name               \"$NODE_ID\"
" >> /etc/chef/client.rb
if [[ $${INTERVAL} -eq "0" ]];
then
    echo "No interval is set, running chef-max once."
    chef-max.sh
else
    echo "Interval is set at $${INTERVAL}, activating cron"
    crontab -l > tempcron
    echo "$${INTERVAL} /etc/chef/chef-max.sh" >> tempcron
    crontab tempcron
    rm tempcron
    chef-max.sh
fi
