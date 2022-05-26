#!/bin/bash
#
####################################################
##    This Function Clear a Security Group and    ##
##   add ONLY your particular ISP IP on SSH Host  ##
## ---------------------------------------------- ##
##            GREAT FOR DYNAMIC IP's              ##
####################################################

# PRE-REQS
# - DDNS (no-ip, DynDNS, etc)
# - AWS Account
# - AWS CLI

# If Script running in the instance itself. Ex.: (Bastion-Host) The instance must have at least the following permissions:
#
# ec2:DescribeSecurityGroupRules
# ec2:DescribeSecurityGroups
# ec2:RevokeSecurityGroupIngress
# ec2:AuthorizeSecurityGroupIngress

home_ip=$(dig YOUR-DDNS.COM +short) # Change For Your DNS
desc="Allow_SSH_To_My_IP" # Don't use spaces in this variable
region="us-east-1" # Change This if necessary
sg_id="sg-XXXXXXXXX" # Change For Your Bastion Host SG ID
json=$(aws ec2 describe-security-groups --group-id ${sg_id} --region ${region} --query "SecurityGroups[0].IpPermissions")

clear_sg(){
        aws ec2 --region ${region} revoke-security-group-ingress \
        --cli-input-json "{\"GroupId\": \"${sg_id}\", \"IpPermissions\": $json}"
        aws ec2 --region ${region} authorize-security-group-ingress \
        --group-id ${sg_id} --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp='${home_ip}'/32,Description='${desc}'}]'
}

clear_sg
