#!/bin/bash

#Copyright ou © ou Copr. Peslerbes Jean-Baptiste - EPSILON
#personne morale lorsque le logiciel est créé sous un lien de subordination
#employé/employeur en ajoutant éventuellement en dessous "contributeur :
#[Peslerbes Jean-Baptiste - Projet EPSILON], (14 Avril 2019)

#peslerbes@et.esiea.fr

#Ce logiciel est un programme informatique servant pour le projet EPSILON - lancement du conteneur côté client

#Ce logiciel est régi par la licence [CeCILL|CeCILL-B|CeCILL-C] soumise au droit français et
#respectant les principes de diffusion des logiciels libres. Vous pouvez
#utiliser, modifier et/ou redistribuer ce programme sous les conditions
#de la licence [CeCILL|CeCILL-B|CeCILL-C] telle que diffusée par le CEA, le CNRS et l'INRIA
#sur le site "http://www.cecill.info".

#En contrepartie de l'accessibilité au code source et des droits de copie,
#de modification et de redistribution accordés par cette licence, il n'est
#offert aux utilisateurs qu'une garantie limitée.  Pour les mêmes raisons,
#seule une responsabilité restreinte pèse sur l'auteur du programme,  le
#titulaire des droits patrimoniaux et les concédants successifs.

#A cet égard  l'attention de l'utilisateur est attirée sur les risques
#associés au chargement,  à l'utilisation,  à la modification et/ou au
#développement et à la reproduction du logiciel par l'utilisateur étant
#donné sa spécificité de logiciel libre, qui peut le rendre complexe à
#manipuler et qui le réserve donc à des développeurs et des professionnels
#avertis possédant  des  connaissances  informatiques approfondies.  Les
#utilisateurs sont donc invités à charger  et  tester  l'adéquation  du
#logiciel à leurs besoins dans des conditions permettant d'assurer la
#sécurité de leurs systèmes et ou de leurs données et, plus généralement,
#à l'utiliser et l'exploiter dans les mêmes conditions de sécurité.

#Le fait que vous puissiez accéder à cet en-tête signifie que vous avez
#pris connaissance de la licence [CeCILL|CeCILL-B|CeCILL-C], et que vous en avez accepté les
#termes.

#--!!--README--!!--
#Dans le dossier vous devez avoir :
# - Le dockerfile de l'image a installer --> Nommée dockerfile
# - Ce script

#Ce script permet de lancer un conteneur qui ouvre un firefox. D'ici, on peut joindre guacamole et ainsi se connecter aux stations à distance (FDP/SSH)

#Le dockerfile ne prends actuellement pas en compte freelan/https.

#Chemin du fichier
chemin='./logs'
#Chemin du dockerfile
dockerfile='./dockerfile'


#Fonction permettant de tester la présence de docker sur son système : Renvoie un message dans le cas contraire
function test_docker_installed(){

  echo -e "DEBUT : Fonction test_docker_installed" >>$chemin 2>&1

  docker -v >> $chemin 2>&1

  if [[ "$?" -eq "127" ]]; then
    echo -e "Docker n'est pas installé..."
    return 1
  else
    echo -e "Docker est installé..."
    return 0
  fi

}

#Fonction permettant de tester la présence du dockerfile permettant l'installation de l'image
function test_dockerfile_present(){
  echo -e "DEBUT : Fonction test_dockerfile_present" >>$chemin 2>&1

  if [ -f $dockerfile ];then
  echo "Le dockerFile est présent.";
  return 0
  else
  echo "Aucun dockerfile $dockerfile n'a été trouvé..."
  return 1
  fi

}

#Focntion qui détecte la présence de l'image docker (après le build)
function search_image() {
  echo -e "DEBUT : Fonction search_image" >>$chemin 2>&1
  docker images | awk -F ' '  '{print $1}' | grep '^firefox' >>$chemin 2>&1

  if [[ "$?" -eq "0" ]]; then
  echo -e "L'image a été trouvée..."
  return 0
  else
  echo -e "L'image n'existe pas..."
  return 1
  fi
}

#Fonction qui build l'image si elle n'existe pas
function build_image() {
  echo -e "DEBUT : Fonction build_image" >>$chemin 2>&1
  docker build -t firefox -f $dockerfile .

  if [[ "$?" -eq "0" ]]; then
    echo -e "Build réussi :) !"
    return 0
  else
    echo -e "Problème lors de la création de l'image..."
    docker image rm firefox >>$chemin 2>&1
    return 1
  fi

}

#Fonction qui créer le conteneur
function run_container(){

  echo -e "DEBUT : Fonction run_container" >>$chemin 2>&1
  #ICI --> La commande pour run votre image
  #docker run -tdi --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -p 443:443 --name dfirefox firefox
  docker run firefox

  if [[ "$?" -eq "0" ]]; then
    echo -e "Lancement du conteneur \"firefox\" réussi ! "
    return 0
  else
    echo -e "Echec du lancement du conteneur \"firefox\"..."
    docker rm firefox >>$chemin 2>&1
    return 1
  fi

}

#   0-Création du fichier de logs
echo -e "Lancement du script..." > $chemin

#   1-On test l'installation de docker --> Success : On continue (0) // On envoie un message et on quitte le programme
test_docker_installed

flag=$?

echo -e "FIN : test_docker_installed : $flag" >> $chemin

if [[ "$flag" -eq "1" ]]; then
  echo "Veuillez installer docker avant d'utiliser le script... Le script va se fermer..."
  exit 0
fi

#   2-On regarde si l'image docker est présente ou si il faut la créer
search_image

flag=$?

echo -e "FIN : search_image: $flag" >> $chemin

if [[ "$flag" -eq "1" ]]; then
  echo "L'image n'a pas été trouvée...Lancement du build de l'image..."

  #   2.1-On regarde si le fichier du Dockerfile est présent
  test_dockerfile_present

  flag=$?

  echo -e "FIN : test_dockerfile_present: $flag" >> $chemin

  if [[ "$flag" -eq "1" ]]; then
    echo "Installation de l'image impossible sans le dockerFile... Le script va se fermer..."
    exit 0
  fi
  #   2.2-Build de l'image
  build_image

  flag=$?

  echo -e "FIN : build_image: $flag" >> $chemin

  if [[ "$flag" -eq "1" ]]; then
    echo "Erreur lors de la création de l'image...Le programme va fermer"
    exit 0
  fi

fi
# 3 - Lancement du conteneur
run_container


flag=$?

echo -e "FIN : run_container: $flag" >> $chemin

if [[ "$flag" -eq "1" ]]; then
  echo "Erreur lors du lancement du conteneur...Le programme va fermer"
  exit 0
fi

echo -e " Tout c'est bien passé ! Fin du script..." >>$chemin 2>&1


























#FIN
