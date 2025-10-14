#!/bin/bash
# Bash Script zur Installation der Software und Libraries für das fächerübergreifende Modul 
# Shell Script erfordert Unix LF Line Ending (Notepad++ / Edit EOL Conversion / Unix LF
# 5200 IoT 
# Installation von:
# - Klonen der Beispiele der Python Libraries der Sensoren in Documents/Libraries 
# - Jupyter Notebook
# - MQTT, Mosquitto Broker und Clients
# - Node-Red
# - InfluxDB
# - Grafana
# - VNC
#
# Farbcodes für die Shell setzen, damit der Fortschritt des Scripts in Grün besser sichtbar ist.
COL='\033[0;32m' # Primary Color
NC='\033[0m' # No Color
# Raspberry Pi Version
echo "${COL}Raspberry Pi Version${NC}"
hostnamectl
cat /proc/cpuinfo | grep Model
# Shell Script für die Installation der benötigte Software
echo "${COL}Raspberry Pi aktualisieren${NC}"
sudo apt update
sudo apt full-upgrade -y
# remove unnecessary dependencies not needed anymore by the system
sudo apt autoremove -y
#echo "${COL}VNC Installation${NC}"
# installation RealVNC
sudo apt-get install realvnc-vnc-server
sudo apt-get install realvnc-vnc-viewer

echo "${COL}i2c-tools Installation${NC}"
# Für I2C Tools und Sensoren muss I2C in raspi-config aktiviert sein
sudo apt install python3-smbus
sudo apt install -y i2c-tools

# Anwendungen: Mosquitto, InfluxDB, Node-Red, Grafana
echo "${COL}Mosquitto Server, Clients und Python Libraries Installation${NC}"
# Mosquitto installieren
sudo apt install mosquitto -y
sudo apt install mosquitto-clients -y
sudo systemctl enable mosquitto.service
# Datei /etc/mosquitto/mosquitto.conf editieren
# sudo nano /etc/mosquitto/mosquitto.conf
# und am Ende der Datei folgendes einfügen ohne #!
# listener 1883
# allow_anonymous true
sudo systemctl restart mosquitto
# https://randomnerdtutorials.com/how-to-install-mosquitto-broker-on-raspberry-pi
# https://plantprogrammer.de/mqtt-auf-dem-raspberry-pi-mosquitto/
# pip install paho-mqtt
echo "${COL}Node-Red Installation${NC}"
# Node-Red installieren
# https://nodered.org/docs/getting-started/raspberrypi
# bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
# add --help to display install options
# "bash <(curl -sL url) --options" führt zu Fehler, möglich, dass "proces substitution" nicht in der bash möglich ist. Foglich das Skript mit curl laden, mit chmod auf executable setzen und mit den gewünschten Optionen ausführen.
# Hence, download the script, make it executable with chmod and execute the script.
curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered -o update-nodejs-and-nodered.sh
chmod +x update-nodejs-and-nodered.sh
bash update-nodejs-and-nodered.sh --confirm-root --confirm-pi --confirm-install --no-init
rm update-nodejs-and-nodered.sh
# erstelle das init file mit: sudo node-red admin init
# Bestätige 2x
# 2x yes
# settingsfile initialisation menu:
# yes installation customise settings
# yes keep settings file at default location 
# no setup user security
# yes enable project features
# select manual workflow
# select default theme
# select default text editor component
# yes allow function nodes to load external modules
# TODO: https://nodered.org/docs/user-guide/runtime/securing-node-red
# node-red als admin initialisieren
# node-red admin init

# Node-Red testen
# node-red start
# node-red stop
# Node-Red Services aktivieren 
sudo systemctl enable nodered.service
sudo systemctl start nodered.service
# sudo systemctl status nodered.service
# Testen der Installation <ip>:1880
# influx erweiterung suchen - node-red-contrib-influxdb

echo "${COL}InfluxDB Installation${NC}"
# Influx installieren
# https://docs.influxdata.com/influxdb/v2/install/?t=Raspberry+Pi
# Test Installation und User aufsetzen: <IP>:8086
# GPG key file: influxdata-archive.key
# Primary key fingerprint: 24C975CBA61A024EE1B631787C3D57159FC2F927

# Ubuntu and Debian
# Add the InfluxData key to verify downloads and add the repository
curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key
gpg --show-keys --with-fingerprint --with-colons ./influxdata-archive.key 2>&1 \
| grep -q '^fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927:$' \
&& cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/keyrings/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list
# Install influxdb
sudo apt-get update && sudo apt-get install influxdb2 -y
sudo service influxdb start
# Influxdb Status verifizieren
# sudo service influxdb status 

echo "${COL}Grafana Installation${NC}"
# Grafana installieren
# https://grafana.com/docs/grafana/latest/setup-grafana/installation/
# default username: admin, pw: admin
sudo apt-get install -y apt-transport-https software-properties-common wget
# import the GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
# add repository for stable releases
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# Updates the list of available packages
sudo apt-get update
# Installs the latest OSS release:
sudo apt-get install grafana -y

sudo systemctl daemon-reload
sudo systemctl start grafana-server

# sudo systemctl status grafana-server
# enable grafana to start on boot
sudo systemctl enable grafana-server.service
# installation testen <IP>:3000, default user: admin, pw: admin change password
# remove unnecessary dependencies not needed anymore by the system
sudo apt autoremove -y

echo "${COL}Klonen der Pimoroni Python Bibliotheken${NC}"
echo "${COL}in Documents/Libraries${NC}"
# alle Libraries mit deren Beispiel code in den Ordner Documents clonen
cd Documents
mkdir Libraries
cd Libraries
# Klonen der Bibliotheken
git clone https://github.com/pimoroni/st7789-python
git clone https://github.com/pimoroni/bme680-python 
git clone https://github.com/pimoroni/icm20948-python
git clone https://github.com/pimoroni/as7262-python
git clone https://github.com/pimoroni/max30105-python
git clone https://github.com/pimoroni/vl53l5cx-python
git clone https://github.com/pimoroni/mlx90640-library
cd ../../