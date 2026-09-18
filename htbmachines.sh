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
  echo -e "\t${purpleColour}i)${endcolour}${grayColour} Buscar por direccion IP${endColour}"
  echo -e "\t${purpleColour}y)${endcolour}${grayColour} Obtener link de la resolucion de la maquina en Youtube${endColour}"
  echo -e "\t${purpleColour}d)${endcolour}${grayColour} Buscar por dificultad de maquinas${endColour}"
  echo -e "\t${purpleColour}o)${endcolour}${grayColour} Buscar por sistema operativo${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endcolour}\n"
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
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}\n"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    if [ "$md5_temp_value" == "$md5_original_value" ]; then 
      echo -e "${yellowColour}[+]${endColour}${grayColour} No hay actualizaciones.${endColour}"
      rm bundle_temp.js
    else 
      echo -e "${yellowColour}[+]${endColour}${grayColour} Actualizaciones disponibles encontradas.${endColour}"
      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "${yellowColour}[+]${endColour}${greenColour} Datos actualizados correctamente.${endColour}"
    fi

    tput cnorm
  fi
}


function searchMachine(){
  machineName="$1"
  

  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')" 

  if [ "$machineName_checker" ]; then 
    echo -e "${yellowColour}\n[+]${endColour}${grayColour} Propiedades de la Maquina${endColour} ${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'  
  else 
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}


function searchIP(){
  ipAdress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente a la IP${endColour} ${blueColour}$ipAdress${endColour} ${grayColour}es${endColour} ${purpleColour}$machineName${endColour}\n"
  else 
    echo -e "\n${redColour}[!] La direccion IP proporcionada no existe${endColour}\n"
  fi  
}

function getYoutubeLink(){

  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  
  if [ $youtubeLink ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para esta maquina esta en el siguiente link:${endColour} ${blueColour}$youtubeLink${endColour}\n" 
  else
    echo -e "\n${redColour}[!] La direccion IP proporcionada no existe${endColour}\n"
  fi
}

function getMachinesByDifficulty(){
  difficulty="$1"
  
  results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$results_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Las maquinas marcadas con dificultad ${blueColour}$difficulty${endColour} ${grayColour}son:${endColour}\n"
    
  cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}\n"
  fi
}

function getOSMachines(){
  os="$1"


}
# Indicators
declare -i parameter_counter=0


while getopts "m:ui:y:d:o:h" arg; do 
  case $arg in 
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAdress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let parameter_counter+=5;;
    o) os="$OPTARG"; let parameter_counter+=6;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then 
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then 
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesByDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
else
  helpPanel 
fi

