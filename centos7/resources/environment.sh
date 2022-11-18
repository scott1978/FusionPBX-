#!/bin/sh

#operating system details
os_name=$(uname -s)
os_version=$(uname -r)
os_mode='unknown'

#cpu details
cpu_name=$(uname -m)
cpu_architecture='unknown'
cpu_mode='unknown'

#check what the CPU and OS are
if [ .$cpu_name = .'armv7l' ]; then
	# RaspberryPi 3 is actually armv8l but current Raspbian reports the cpu as armv7l and no Raspbian 64Bit has been released at this time
	os_mode='32'
	cpu_mode='32'
	cpu_architecture='arm'
elif [ .$cpu_name = .'armv8l' ]; then
	# We currently have no test case for armv8l
	os_mode='unknown'
	cpu_mode='64'
	cpu_architecture='arm'
elif [ .$cpu_name = .'i386' ]; then
	os_mode='32'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
		cpu_mode='64'
	else
		cpu_mode='32'
	fi
	cpu_architecture='x86'
elif [ .$cpu_name = .'i686' ]; then
	os_mode='32'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
		cpu_mode='64'
	else
		cpu_mode='32'
	fi
	cpu_architecture='x86'
elif [ .$cpu_name = .'x86_64' ]; then
	os_mode='64'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
		os_mode='64'
	else
		os_mode='32'
	fi
	cpu_architecture='x86'
else
	error "您正在使用不受支持的cpu '$cpu_name'& You are using an unsupported cpu '$cpu_name'"
	exit 3
fi
	
if [ .$cpu_architecture = .'arm' ]; then
	error " 不支持 arm CentOS 系统 & CentOS on arm is not supported at this time"
	exit 3
elif [ .$cpu_architecture = .'x86' ]; then
	if [ .$os_mode = .'32' ]; then
		error "不支持您使用的是32位操作系统 & You are using a 32bit OS this is unsupported"
		if [ .$cpu_mode = .'64' ]; then
			warning " 您的CPU是64位，您应该考虑使用64位操作系统重新安装 & Your CPU is 64bit you should consider reinstalling with a 64bit OS"
		fi
		exit 3
	elif [ .$os_mode = .'64' ]; then
		verbose "检测到正确的CPU和操作系统 & Correct CPU and Operating System detected"
	else
		error "不支持未知操作系统模式 '$os_mode' & Unknown Operating System mode '$os_mode' is unsupported"
		warning "检测到的环境为 & Detected environment was :-"
		warning "系统名称 & os_name:'$os_name'"
		warning "系统类型 & os_mode:'$os_mode'"
		warning "CPU & cpu_name:'$cpu_name'"
		warning "CPU结构 & cpu_architecture:'$cpu_architecture'"
		exit 3
	fi
else
	error "您使用的是不支持的系统结构 & You are using an unsupported architecture '$cpu_architecture'"
	warning "检测到的环境为 &  Detected environment was :-"
	warning "系统名称 & os_name:'$os_name'"
	warning "系统类型 &  os_mode:'$os_mode'"
	warning "CPU & cpu_name:'$cpu_name'"
	exit 3
fi
