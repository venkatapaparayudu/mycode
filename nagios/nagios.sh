#!/bin/bash
function iptables_setup() {
systemctl stop firewalld
systemctl mask firewalld
yum install iptables-services
cp /root/nagios/iptables /etc/sysconfig/.
chmod 600 /etc/sysconfig/iptables
systemctl enable iptables
systemctl restart iptables
}
function req_pkgs() {
mkdir /nagios
echo "Checking Prerequisites and installing required packages...."
for pkg in epel-release git httpd php php-cli gcc glibc glibc-common gd gd-devel net-snmp unzip
do
  rpm -q $pkg | grep -i "not"
  N=`echo $?`
  if [ $N -gt 0 ]
  then
      echo "$pkg is installed"
  else
      yum install -y $pkg
  fi
done
}

function user_group_creation() {
echo "nagios user and nagcmd group creation..!"
getent passwd nagios
user=`echo $?`
if [ $user -gt 0 ]
then
     useradd nagios
     echo nagios | passwd -stdin nagios
else
    echo "Required user nagios is existed.....!"
fi

getent group nagcmd
group=`echo $?`
if [ $group -gt 0 ]
then
    groupadd nagcmd
    usermod -a -G nagcmd nagios
    usermod -a -G nagcmd apache
else
    echo "Required group nagcmd is existed.....!"
fi
}

function nagios_core_installation() {
echo "Installing Nagios Core - 4.4.1"
cd /nagios/
#wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.1.tar.gz
#wget http://192.168.2.202/downloads/nagios-4.4.1.tar.gz
tar xvzf /root/nagios/nagios-4.4.1.tar.gz
cd nagios-4.4.1
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
cd ~
}
function apache_restart() {
echo "Assgnging Password for Nagios GUI access...."
#echo nagiosadmin | htpasswd --stdin -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
systemctl enable httpd && systemctl restart httpd
}
function nagios_plugins_installation() {
echo "Installing Nagios Plugins....!"
cd /nagios/
#wget http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
#wget  http://192.168.2.202/downloads/nagios-plugins-2.2.1.tar.gz
tar xvzf /root/nagios/nagios-plugins-2.2.1.tar.gz
cd nagios-plugins-2.2.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install 
cd ~
}
function nagios_start() {
echo "Starting Nagios......"
systemctl start nagios
systemctl enable nagios
echo "Access Nagios with http://<IPADDRESS>/nagios"
}

req_pkgs
iptables_setup
user_group_creation
nagios_core_installation
apache_restart
nagios_plugins_installation
nagios_start
