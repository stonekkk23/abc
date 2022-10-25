#!/bin/bash

checkDocker=$(which docker)
checkDockerCompose=$(which docker-compose)
if [ "$checkDocker" == "" ] && [ "$checkDockerCompose" == "" ]; then
	echo "Please install docker and docker-compose!"
	exit
elif [ "$checkDocker" == "" ]; then
	echo "Please install docker!"
	exit
fi
if [ "$checkDockerCompose" == "" ]; then
	echo "Please install docker-compose!"
	exit
fi

# echo "-----------------------------------------------"
# echo "Docker:" $(docker -v)
# echo "Docker-Compose:" $(docker-compose -v)
# echo "-----------------------------------------------"

rm -rf ./caddy/Caddyfile
rm -rf ./xray/config.json

cp ./caddy/Caddyfile.raw ./caddy/Caddyfile

read -p "Please input your server domain name(eg: abc.com): " domainName

if [ "$domainName" = "" ];then 
        echo "bye~"
        exit
else
	echo "Your domain name is: "$domainName
	sed -i "s/abc.com/$domainName/g" ./caddy/Caddyfile
fi

sys=$(uname)
if [ "$sys" == "Linux" ]; then
	uuid=$(cat /proc/sys/kernel/random/uuid)
elif [ "$sys" == "Darwin" ]; then
	uuid=$(echo $(uuidgen) | tr '[A-Z]' '[a-z]')
else
	uuid=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
fi

# make a secret domain for naiveproxy
randomDomain=$(openssl rand -hex 16)
sed -i "s/randomDomain/$randomDomain/g" ./caddy/Caddyfile

echo "-----------------------------------------------"
echo "NaiveProxy Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "Username: superuser"
echo "Password:" $trojan_password
echo "-----------------------------------------------"
echo "Please run 'docker-compose up -d' to build!"
echo "Enjoy it!"

cat <<-EOF >./info.txt
	-----------------------------------------------
	NaiveProxy Configuration:
	Server: $domainName
	Port: 443
	Username: superuser
	Password: $trojan_password
	-----------------------------------------------
EOF

