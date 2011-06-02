#!/bin/bash

# directory where your keys are stored, they should be in the format of
# keyname.pem, i.e. Group1Key.pem.  They should be the exact same name
# as the 'Key Pair Name' in the EC2 console.
KEYDIR=~/.ssh/

# username to connect with
USERNAME=awsuser

# See .init_ec2 file for config details, this describes your keypairs, etc.
source .init_ec2

# Get the block of info from AWS
ec2info=`ec2-describe-instances`

# Just pull out lines with the Name tag for now
grepped=`echo "$ec2info" | grep Name | grep -i $1`

# No matches for supplied name
if [ "$?" -eq "1" ]; then
	echo "No instances matched."
	exit
fi

# Grep out the names only and count the results
instanceNames=`echo "$grepped" | awk '{ print \$5; }'`
instanceLines=`echo "$instanceNames" | wc -l`

# Should only have one match here
if [ "$instanceLines" -gt "1" ]; then
	echo "Be more specific, which did you mean?"
	echo "$instanceNames"
	exit
fi

# Get the instance ID
instanceID=`echo $grepped | awk '{ print \$3; }'`

# Get the DNS record for this instance
dns=`echo "$ec2info" | grep 'INSTANCE' | grep $instanceID | cut -f 4`

# Get the keypairname for this instance
key=`echo "$ec2info" | grep 'INSTANCE' | grep $instanceID | cut -f 7`

# OSX only:
# AppleScript to launch a new terminal window connecting to the supplied
# DNS record with the supplied keyname
#osascript 2>/dev/null <<EOF
#	tell application "Terminal"
#		activate
#		do script with command "ssh -i $KEYDIR/$key.pem $USERNAME@$dns"
#	end tell
#EOF

# Any Unix system:
ssh -i $KEYDIR/$key.pem $USERNAME@$dns

# TODO: add a menu to pick which instance to connect to when you
#	get multiple choices, instead of calling the user a dummy
