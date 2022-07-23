#!/bin/sh

source ./variables.list

# install authorized keys
cat ssh.authorized_keys >> ~/.ssh/authorized_keys

# full update before anything else
pacman -Syu --noconfirm

# disable any default services we don't want
for service in $(cat services.disable.list)
do
	systemctl disable $service --now
done

# install all packaes we need
pacman -S --needed --noconfirm $(cat packages.install.list)

# remove any default packages we don't need
pacman -Rs --noconfirm $(cat packages.remove.list)

# install config files
cp -r ./nginx/* /etc/nginx/
cp -r ./fail2ban/* /etc/fail2ban/
cp -r ./ssh/* /etc/ssh/

# enable all new services we do want
for service in $(cat services.enable.list)
do
	systemctl enable $service --now
done

certbot -n --nginx --agree-tos --email $EMAIL --expand --domains $DOMAINS

# we've reconfigured ssh, so we need to restart
#     but do so last in case it causes us to
#     disconnect
systemctl restart sshd
