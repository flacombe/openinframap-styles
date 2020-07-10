#!/bin/bash
#Install & Run Tegola service
#Dorian Galiana 10/12/2019
echo "Installation du service tegola dans systemd"
ln -s tegola.service /etc/systemd/system/tegola.service
systemctl daemon-reload
systemctl enable tegola.service
systemctl start tegola.service

echo "Check du bon démarrage :"
systemctl status tegola.service
