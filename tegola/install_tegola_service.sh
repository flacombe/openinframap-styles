#!/bin/bash
#Install & Run Tegola service
#Dorian Galiana 10/12/2019
echo "Installation du service tegola dans systemd"
if [ ! -f /etc/systemd/system/tegola.service ]; then
  echo "Copy tegola.service file towards /etc/systemd/system first"
  exit 1;
fi

systemctl daemon-reload
systemctl enable tegola.service
systemctl start tegola.service

echo "Check du bon démarrage :"
systemctl status tegola.service
