#!/bin/bash

PATH_IMAGES=images
PATH_DB=database




function createHtml()
{
    touch $1/index.html
    echo "<!DOCTYPE html>
	<html>
	<head>
		<title>TP admin système</title>
	</head>
		<body>
		<h1>Les superbes images !!</h1> 
		</body>
	</html>" >> $1/index.html
    afficherImages $1 >> $1/index.html
    afficherCommentaires >> $1/index.html



}




function display()
{	
	if [ -f "$1" ] ; then
		xdg-open "$1"&
	else
		echo "le fichier $1 n'existe pas"
	fi
}





function majHtml()
{
	rm $1/index.html
	createHtml $1


}






function afficherImages()
{
	if [ -z "ls $1/$PATH_IMAGES"  ]
	then
		echo "<p> il n'y a pas d'image </p>"
	else		
		cd $1
		for image in "$PATH_IMAGES/"*;do
			echo '<img src="'$image'" width="100" height="100" alt="'$image'">'
		done	
		cd - > uselessfile
	fi
	


}




function afficherCommentaires()
{

	while read -r username content
	do
	  echo "<p>$username a dit '$content'</p>"

	done <  "$PATH_DB"/commentaires.csv

}


function foldExists()
{
	read -p "Le dossier $1 existe déjà, Voulez vous le remplacer ? O pour oui ou N pour non: " CONFIRMATION	
	if [ $CONFIRMATION = "O" ]; then
		rm -rf $1
		mkdir $1			
	elif [ $CONFIRMATION = "N" ]; then
		echo "Aucune modification du dossier $1" 
	else
		echo " ERREUR : mauvaise option, les options acceptées sont O et N"
		exit 0
	fi
}





function build()
{	
	if ! [ -z "$1" ] ; then
		if [ -d "$1" ] ; then
			foldExists $1
		else 
			mkdir $1	
		fi			
		buildImagesFolder $1
		buildHtml $1	
		
	else
		echo "il manque un paramètre" >&2
		exit 0
		
	fi

}




function buildImagesFolder()
{
	if [ -d "$1/images" ] ; then	
		foldExists "$1/images"			
	else		
		cp -r images $1
	fi
}




function buildHtml()
{
	PATH_HTML=$1/index.html
	if    [ -f "$PATH_HTML" ] ; then
			
			echo "le fichier $PATH_HTML existe déjà" 
			read -p "Voulez vous le supprimer pour en créer un nouveau ? O pour oui ou N pour non: " CONFIRMATION
			if [ $CONFIRMATION = "O" ]; then
				rm $PATH_HTML
				createHtml $1
			elif [ $CONFIRMATION = "N" ]; then
				echo "Aucune modification" >&2
			else
				echo "Option inconnue"
				exit 0
			fi
	else
			
			createHtml $1
	fi
	display $PATH_HTML
		
}






function register()
{

	#inputUser USER_NAME "nom d'utilisateur"
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
		isBlank "$USER_NAME" "nom d'utilisateur"
	done
	read -sp "Entrez le mot de passe : " USER_PASSWORD
	isBlank "$USER_PASSWORD" "mot de passe"
	until [ $USER_PASSWORD = $(getMdp "$USER_NAME") ]
	do	
		echo "le mot de passe est incorrect ">&2
		read -sp "Entrez le mot de passe : " USER_PASSWORD
		isBlank "$USER_PASSWORD" "mot de passe"
				
	done	
	echo $USER_NAME
}

function getMdp()
{
	res='' 
	while read -r username password
	do
	 
	  if [ "$username" = $1 ] ; then
	  	res=$password
	  fi
	  
	done < "$PATH_DB"/users.csv
	echo $res
}




function add_comment()
{
	
	if [ -f $1 ]; then
		USER_NAME=$(authenticate)
		if [ "$USER_NAME" == "Le nom d'utilisateur ne peut pas être vide !" ]||[ "$USER_NAME" == "Le mot de passe ne peut pas être vide !" ]; then
			exit 0
		fi
		echo $USER_NAME $2 >> "$PATH_DB"/commentaires.csv
		majHtml $1
		
	else
		echo "le fichier n'existe pas"
	fi
	
	

}

function add_images() #$1 = dossier où on veut mettre la photo #2 =image qu'on veut ajouter
{

	if [ -d $1 ]; then		
		if [ -f $2 ] ; then
			USER_NAME=$(authenticate)
			if [ "$USER_NAME" == "Le nom d'utilisateur ne peut pas être vide !" ]||[ "$USER_NAME" == "Le mot de passe ne peut pas être vide !" ]; then
				exit 0
			fi			
			
		
				mv $2 $1/images
			
						
			majHtml $1
			
			
		else
		
			echo " le fichier $2 n'existe pas "
		
		fi
		
	else
		echo "le dossier $1 n'existe pas"
		
	fi


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


function error()
{	echo "ERREUR : Mauvais paramètre(s)!" >&2
	echo "Veuillez consulter l'option --help pour plus d'informations" >&2
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
	display $2
	exit 0
elif [ "$1" = "register" ] ; then
	register
	exit 0

elif [ "$1" = "authenticate" ] ; then
	authenticate
	exit 0
	
elif [ "$1" = "add_comment" ] ; then
	add_comment $2 $3
	exit 0
elif [ "$1" = "add_images" ] ; then
	add_images $2 $3
	exit 0


else
	error
	exit 0
fi


