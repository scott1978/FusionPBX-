#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh

#send a message
verbose "开始安装FreeSWITCH & Installing FreeSWITCH"
echo "scott" > /etc/yum/vars/signalwireusername
echo "pat_2mLLY6czvUx4F8U2ChrGwQ59" > /etc/yum/vars/signalwiretoken
yum install -y https://$(< /etc/yum/vars/signalwireusername):$(< /etc/yum/vars/signalwiretoken)@freeswitch.signalwire.com/repo/yum/centos-release/freeswitch-release-repo-0-1.noarch.rpm epel-release
yum install -y freeswitch-config-vanilla freeswitch-lang-en freeswitch-sounds-en
systemctl enable freeswitch
#send a message
verbose "FreeSWITCH 安装完成 & FreeSWITCH installed"
