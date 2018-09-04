
<?php 
//connect.php


session_start();

 // Create connection
$con=mysqli_connect("localhost","stoug_forum","E63!2rof","stougma26066com26632_forum");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}



?>