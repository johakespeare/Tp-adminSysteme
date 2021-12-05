#!/bin/bash


PAGE_HTML=index.html
PATH_IMAGES=images
PATH_DB=database


function createHtml()
{
    touch $PAGE_HTML
    initHtml    
}

function initHtml()
{
	echo "<!DOCTYPE html>
	<html>
  	<head>
    		<title>TP admin système</title>
  	</head>
  		<body>
    		<h1>Les superbes images !!</h1> 
  		</body>
	</html>" >> $PAGE_HTML
	
}

function display()
{
	if ! [ -f "$PAGE_HTML" ] ; then
	createHtml
	fi
	afficherImages >> $PAGE_HTML
	afficherCommentaires >> $PAGE_HTML
	xdg-open "$PAGE_HTML"&
}


function afficherImages()
{
	
	
	if [ -z "ls $PATH_IMAGES"  ]
	then
		echo "<p> il n'y a pas d'image </p>"
	else		
		for image in $PATH_IMAGES"/"*;do
			echo '<img src="'$image'" width="100" height="100" alt="'$image'">'
		done	
	fi
}

function afficherCommentaires()
{

	while read -r id_com username content
	do
	  echo "<p>$username a dit '$content'</p>"

	done <  "$PATH_DB"/commentaires.csv

}



function error()
{
	echo "ERREUR : Mauvais paramètres!" >&2
	echo "Veuillez consulter l'option --help pour plus d'informations" >&2

}



function build()
{	
	if ! [ -z "$1" ] ; then
		if ! [ -d "$1" ] ; then	
			mkdir $1	
		fi
		
		#cp  $1 ../tp-admin_sys 
		#cd "$1"
		#$PATH_IMAGES=$1images
		display
				
	else
		echo "il manque un paramètre" >&2
		
	fi

}

function register()
{

	read -p "Entrez le nom d'utilisateur : " USER_NAME 
	
	isBlank "$USER_NAME" "nom d'utilisateur"
	until [ $(isRegistered "$USER_NAME") -eq 0 ]
	do
		echo "Le nom d'utilisateur $USER_NAME est déjà pris"
		read -p "Entrez le nom d'utilisateur : " USER_NAME 
		isBlank "$USER_NAME" "nom d'utilisateur"		
	done
	
	read -sp "Entrez le mot de passe : " USER_PASSWORD_1
	isBlank "$USER_PASSWORD_1" "mot de passe"

	read -sp "Entrez de nouveau le mot de passe : " USER_PASSWORD_2
	
	until [ $USER_PASSWORD_1 = $USER_PASSWORD_2 ]
	do	
		echo "les mots de passes sont différents">&2
		read -sp "Entrez le mot de passe : " USER_PASSWORD_1
		isBlank "$USER_PASSWORD_1" "mot de passe"
		read -sp "Entrez de nouveau le mot de passe : " USER_PASSWORD_2
			
	done
	echo $USER_NAME $USER_PASSWORD_1 >> "$PATH_DB"/users.csv
	
}

function isBlank()
{
 	if [ -z $1 ] ; then
	    echo "Le $2 ne peut pas être vide !" 
	    exit 0 
	fi 

}

function isRegistered()
{
	res=0
	while read -r username password
	do	  
	  if [ "$username" = $1 ] ; then
	  	res=1
	  fi	  
	done < "$PATH_DB"/users.csv
	echo $res	
}


function authenticate()
{
	read -p "Entrez le nom d'utilisateur : " USER_NAME 
	isBlank "$USER_NAME" "nom d'utilisateur"
	until [ $(isRegistered "$USER_NAME") -eq 1 ]
	do
		echo "nom d'utilisateur $USER_NAME inconnu"
		read -p "Entrez le nom d'utilisateur : " USER_NAME 
	done
	read -p "Entrez le mot de passe : " USER_PASSWORD
	isBlank "$USER_PASSWORD_1" "mot de passe"
	until [ $USER_PASSWORD = $(getMdp "$USER_NAME") ]
	do	
		echo "le mot de passe est incorrect ">&2
		read -p "Entrez le mot de passe : " USER_PASSWORD
		isBlank "$USER_PASSWORD_1" "mot de passe"
				
	done	
}

function getMdp()
{
	res='' 
	while read -r username password
	do
	 
	  if [ $username = $1 ] ; then
	  	res=$password
	  fi
	  
	done < "$PATH_DB"/users.csv
	echo $res
}


function aide()
{
while read -r line
	do
	 
	  echo "$line"
	  
	done < help.txt
	
}


function debug()
{
	echo "DEBUG"


}


if [ "$1" = "--help" ] ; then
	aide
	exit 0
elif [ "$1" = "--debug" ] ; then
	debug
	exit 0
elif [ "$1" = "build" ] ; then
	build $2
	exit 0

elif [ "$1" = "display" ] ; then
	display 
	exit 0

elif [ "$1" = "register" ] ; then
	register
	exit 0

elif [ "$1" = "authenticate" ] ; then
	authenticate
	exit 0

else
	error
	exit 0
fi


