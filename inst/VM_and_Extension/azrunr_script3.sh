#!/bin/bash
sudo apt-get install gdebi-core

wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.1073-amd64.deb

sudo gdebi rstudio-server-1.3.1073-amd64.deb