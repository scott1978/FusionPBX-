#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "安装PostgreSQL 14 & Installing PostgreSQL 14"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#included in the distribution
verbose "rpm -ivh --quiet pgdg-centos96-9.6-3.noarch.rpm start"
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
verbose "rpm -ivh --quiet pgdg-centos96-14.noarch.rpm end"
yum -y update
yum -y install postgresql14 postgresql14-server postgresql14-libs postgresql14-contrib

#send a message
verbose "初始化PostgreSQL数据库 & Initalize PostgreSQL database"

#initialize the database
/usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl enable postgresql-14
systemctl start postgresql-14

#allow loopback
sed -i 's/\(host  *all  *all  *127.0.0.1\/32  *\)ident/\1md5/' /var/lib/pgsql/14/data/pg_hba.conf
sed -i 's/\(host  *all  *all  *::1\/128  *\)ident/\1md5/' /var/lib/pgsql/14/data/pg_hba.conf

#systemd
systemctl daemon-reload
systemctl restart postgresql-14

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp

#add the databases, users and grant permissions to them
sudo -u postgres /usr/pgsql-14/bin/psql -d fusionpbx -c "DROP SCHEMA public cascade;";
sudo -u postgres /usr/pgsql-14/bin/psql -d fusionpbx -c "CREATE SCHEMA public;";
sudo -u postgres /usr/pgsql-14/bin/psql -c "CREATE DATABASE fusionpbx";
sudo -u postgres /usr/pgsql-14/bin/psql -c "CREATE DATABASE freeswitch";
sudo -u postgres /usr/pgsql-14/bin/psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/pgsql-14/bin/psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/pgsql-14/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres /usr/pgsql-14/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres /usr/pgsql-14/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
cd $cwd

#send a message
verbose "PostgreSQL 14 安装完成 & PostgreSQL 14 installed"
