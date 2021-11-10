#!/bin/bash
touch test.html
cat > test.html << EOF

<!DOCTYPE html>
<html>
  <head>
    <title>TP admin système</title>
  </head>
  <body>
    <h1>Les superbes images !!</h1> 
  </body>
</html>


EOF


function afficherImages(){
	images=$(ls images)
	
	if [ -z "$images" ]
	then
		echo "<p> il n'y a pas d'image </p>"
	fi
	
	for image in $images
	do
		echo '<img src="images/'$image'" alt="'$image'">'
	done	
}


afficherImages >>test.html

xdg-open "test.html"&


