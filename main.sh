#!/bin/bash


PAGE_HTML=index.html
PATH_IMAGES=""


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
	xdg-open "$PAGE_HTML"&
}


function afficherImages()
{
	
	$images = ls PATH_IMAGES
	if [ -z $images  ]
	then
		echo "<p> il n'y a pas d'image </p>"
	else		
		for image in PATH_IMAGES"/"*;do
			echo '<img src="'$image'" alt="'$image'">'
		done	
	fi
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
		#mv images $1
		#cd "$1"
		#$PATH_IMAGES=$1images
		#createHtml
				
	else
		echo "il manque un paramètre" >&2
		
	fi

}






if [ "$1" = "--help" ] ; then
	echo "AIDE">&2
	exit 0
fi
if [ "$1" = "build" ] ; then
	build $2
	exit 0
fi

if [ "$1" = "display" ] ; then
	display 
	exit 0
fi





























