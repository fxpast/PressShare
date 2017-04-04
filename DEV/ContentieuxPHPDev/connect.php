<?php 
//connect.php


session_start();

 // Create connection
$con=mysqli_connect("localhost","stoug_admindev","yg6Q91r$","stougma26066com26632_DBPressShareDev");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}



?>