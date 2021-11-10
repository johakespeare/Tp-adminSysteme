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
    <img      src="images/cafe.jpeg"      alt="cafe">
     <img      src="images/capybara.jpeg"      alt="capybara">
      <img      src="images/corse.png"      alt="corse">
       <img      src="images/poney.jpeg"     alt="poney">
    
    
    
  </body>
</html>


EOF

xdg-open "test.html"&


