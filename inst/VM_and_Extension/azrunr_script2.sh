#!/bin/bash

yes | sudo apt-get update

yes | sudo apt-get upgrade

yes | sudo add-apt-repository ppa:marutter/rrutter

yes | sudo apt update
yes | sudo apt-get install r-base

yes | sudo apt-get install apache2