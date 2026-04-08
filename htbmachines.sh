#!/bin/bash 

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm
  exit 1
}
# Ctrl+C
trap ctrl_c INT

# Variables Globales
main_url="https://htbmachines.github.io/bundle.js" 

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso: ${endColour}"
  echo -e "\t${purpleColour}u)${endcolour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endcolour}${grayColour} Buscar por nombre de maquina${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endcolour}\n"
}

function searchMachine(){
  machineName="$1"
  echo "$machineName"
}

function updateFiles(){
  if [ ! -f bundle.js ]; then 
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${greyColour} Descargando Datos...${endColour}\n"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${greyColour} Datos descargados correctamente.${endColour}\n"
    tput cnorm 
  else
    echo "El archivo existe."  
  fi
}


# Indicators
declare -i parameter_counter=0


while getopts "m:uh" arg; do 
  case $arg in 
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then 
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then 
  updateFiles
else
  helpPanel 
fi

