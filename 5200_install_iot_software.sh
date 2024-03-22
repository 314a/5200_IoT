#!/bin/bash
# Bash Script zu Installation der Software und Libraries für das fächerübergreifende Modul 
# 5200 IoT 
# Installation von:
# - Python Libraries für die Pimoroni Sensoren
# - Klonen der Libraries mit Beispielen in Documents/Libraries 
# - Jupyter Notebook
# - MQTT, Mosquitto Broker und Clients
# - Node-Red
# - InfluxDB
# - Grafana
# - VNC

# Farbcodes für die Shell setzen, damit der Fortschritt des Scripts in Grün besser sichtbar ist.
COL='\033[0;32m' # Primary Color
NC='\033[0m' # No Color

# Shell Script für die Installation der benötigte Software
echo "${COL}Raspberry Pi aktualisieren${NC}"
sudo apt update
sudo apt full-upgrade -y
# remove unnecessary dependencies not needed anymore by the system
sudo apt autoremove -y

echo "${COL}VNC Installation${NC}"
# installation RealVNC
sudo apt-get install realvnc-vnc-server
sudo apt-get install realvnc-vnc-viewer

echo "${COL}i2c-tools Installation${NC}"
# Für I2C Tools und Sensoren muss I2C in raspi-config aktiviert sein
sudo apt install python3-smbus
sudo apt install -y i2c-tools

echo "${COL}Installation der Python Bibliotheken${NC}"
# Installation der Python Bibliotheken und Jupyter
# Jupyter Notebook
sudo pip3 install matplotlib scipy pigments numpy
sudo pip3 install jupyter
# jupter notebook installation testen
# jupyter notebook --notebook-dir ~/Documents
# jupyter-notebook –-ip 192.168.1.205 --port 9999
# jupyter-notebook --no-browser --ip=192.168.1.205 --port 9999
echo "${COL}Installation der Pimoroni & Adafruit Python Bibliotheken${NC}"
# Installation der Pimoroni Sensor Bibliotheken
# sudo apt update

# ST7789 Python Bibliothek für 1.54" square color SPI LCD 
# https://github.com/pimoroni/st7789-python
# Für die Nutzung muss die SPI Schnittstelle in raspi-config aktiviert sein
sudo apt install python3-rpi.gpio python3-spidev python3-pip python3-pil python3-numpy
sudo pip3 install st7789
# bme680 Python Bibliothek für BME 688 Temperatur, Luftfeuchtigkeit und Gas Sensor
# https://github.com/pimoroni/bme680-python
sudo pip3 install bme680
# icm20948 Python Bibliothek für 9DoF Motion Sensor
# https://github.com/pimoroni/icm20948-python
sudo pip3 install icm20948
# as7262 Python Bibliothek für 6 Kanal Spektralsensor
# https://github.com/pimoroni/icm20948-python
sudo pip3 install as7262
# max30105 Python Bibliothek für Heartrate, Oximeter, Smoke Sensor
# https://github.com/pimoroni/max30105-python
sudo pip3 install max30105
# vl53l5cx Python Bibliothek für 8x8 Time of Flight (ToF) Array
# https://github.com/pimoroni/vl53l5cx-python
# Für schnelleres Auslesen muss die Baud Rate des I2C Protokoll angepasst werden
# sudo nano /boot/config.txt
# folgende Zeile ergänzen
# dtparam=i2c_arm=on,i2c_arm_baudrate=400000
# Mit CTRL+o und CTRL+x die Datei speichern und schliessen.
sudo pip3 install vl53l5cx-ctypes
# mlx90640 Python Bibliothek für die Thermalkamera
# https://github.com/pimoroni/mlx90640-library C Bibliothek
# installation der adaftruit libraries
sudo pip3 install RPI.GPIO adafruit-blinka
sudo pip3 install adafruit-circuitpython-mlx90640

# auf die Python Distribution angepasste Installation (sicherer) - TODO test
# python3 -m pip install st7789
# python3 -m pip install bme680
# python3 -m pip install icm20948
# python3 -m pip install as7262
# python3 -m pip install max30105
# python3 -m pip install vl53l5cx-ctypes

# python3 -m pip install RPI.GPIO adafruit-blinka
# python3 -m pip install adafruit-circuitpython-mlx90640
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

# Anwendeungen: Mosquitto, InfluxDB, Node-Red, Grafana
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
sudo pip3 install paho-mqtt

echo "${COL}Node-Red Installation${NC}"
# Node-Red installieren
# https://nodered.org/docs/getting-started/raspberrypi
# bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
# add --help to display install options
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-pi --confirm-install
# Bestätige 2x
# 2x yes
# settingsfile initialisation menu:
# yes installation customise settings
# yes keep settings file at default location 
# no setup user security
# yes enable project features
# select manual workflow
# select default theme
# yes allow function nodes to load external modules

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
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.1-arm64.deb
sudo dpkg -i influxdb2-2.7.1-arm64.deb
sudo service influxdb start
# Test Installation und User aufsetzen: <IP>:8086

echo "${COL}Grafana Installation${NC}"
# Grafana installieren
# https://grafana.com/docs/grafana/latest/setup-grafana/installation/
# default username: admin, pw: admin
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
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