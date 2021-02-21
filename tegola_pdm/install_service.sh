#!/bin/bash
#Install & Run Tegola service
#Dorian Galiana 10/12/2019
echo "Installation du service tegola dans systemd"
if [ ! -f /etc/systemd/system/tegola_pdm.service ]; then
  echo "Copy tegola_pdm.service file towards /etc/systemd/system first"
  exit 1;
fi

systemctl daemon-reload
systemctl enable tegola_pdm.service
systemctl start tegola_pdm.service

echo "Check du bon démarrage :"
systemctl status tegola_pdm.service
