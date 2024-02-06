#!/bin/bash

# autor: Luciano Kalabric Silva
# institution: Oswaldo Cruz Foundation, Goncalo Moniz Institute, Bahia, Brazil
# URL:
# last update: 13 OUT 2021
# Objetive: Updade/Upgrade and Install Linux packages, and keep a record of all installations
# Syntax: ./install_linuxpacks.sh <-u/-i/-l> <package_name/package_list *.packs file>
# Link: https://stackoverflow.com/questions/1298066/how-can-i-check-if-a-package-is-installed-and-install-it-if-not

# Packages files dir
PACKAGE_DIR="${HOME}/repos/bioinfo/"

# This script is good for superuser or root user only!!!
if [[ $(sudo -v) ]]; then
    sudo -v
    exit 0
fi

# Function to test if package exists in Debian
# https://stackoverflow.com/questions/1298066/how-can-i-check-if-a-package-is-installed-and-install-it-if-not
function package_exist() {
    dpkg -s $1 &> /dev/null
    return $?
}

function is_installed() {
     dpkg --verify "$1" 2>/dev/null
     return $?
}

# Validate parameters
if [ $# = 0 ]; then
	echo "Syntax: install_linuxpacks.sh <-i to install individual package/-l to install a list of packages> <package name or package list *.packs file>"
	exit 0;
else
#	if [[ -z $2 ]]; then
#		echo "Package name or package list *.packs file is required!"
#		echo "Syntax: install_linuxpacks.sh <-i to install individual package/-l to install a list of packages> <package name or package list *.packs file>"
#		exit 0
#	else
 		case $1 in
			"-u" ) echo "Update/Upgrade in progress..."
				# Pior to any installation it is recommended to update-upgrade your Linux Distro# Update & upgrade your Linux Distro
				echo "Updating & upgrading installed packages before starting any new installation..."
				sudo apt-get update
				sudo apt list --upgradable
				sudo apt-get upgrade    				
    			;;
   			"-i" ) echo "Installation in progress..."
				# Check if package is installed and install it if not
				PACKAGE_NAME=$2
 				#if ! package_exist ${PACKAGE_NAME}; then
				#	echo "Package name wrong or package list *.packs not found!"
				#	exit 0				
				#else
				#	echo "Package ${PACKAGE_NAME} is available in the Debian Distro!"
				#fi   				
				if ! is_installed $PACKAGE_NAME; then
					echo -e "$PACKAGE_NAME is not installed! Install? (y/n) \c"
					read -r
					echo $REPLY
					if [[ $REPLY = "y" ]]; then
						sudo apt-get install ${PACKAGE_NAME}
						echo "`date` sudo apt-get install $PACKAGE_NAME" >> ${HOME}/logs/install_linuxpackages.log
					else
						echo "You can install it anytime!"
					fi
				else
					echo "$PACKAGE_NAME already installed in your Linux Distro!"
				fi
    			;;
			"-l" ) echo "Listing package(s) name(s) and descrition..."
   				# Linux packages are listed in files *.packs at the following $PACKAGELIST_DIR
				PACKAGELIST_FILENAME=$2
   				mapfile PACKAGE_LIST < "${PACKAGE_DIR}/${PACKAGELIST_FILENAME}"			
       				for PACKAGE_NAME in "${PACKAGE_LIST[@]}"; do 
       					apt-cache search ^${PACKAGE_NAME}$
					if ! which $PACKAGE_NAME > /dev/null; then
						echo -e "$PACKAGE_NAME is not installed! Install? (y/n) \c"
						read -r
						echo $REPLY
						if [[ $REPLY = "y" ]]; then
							sudo apt-get install ${PACKAGE_NAME}
							echo "`date` sudo apt-get install $PACKAGE_NAME" >> ${HOME}/logs/install_linuxpackages.log
							else
							echo "You can install it anytime!"
						fi
					else
						echo "$PACKAGE_NAME already installed in your Linux Distro!"
					fi
	    			done
				exit 0
    			;;
			* ) echo "Invalid option!"; exit 0;;
		esac	
  			
	
#	fi
fi
