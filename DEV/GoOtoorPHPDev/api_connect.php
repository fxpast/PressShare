<?php 
//connect.php


session_start();

 // Create connection
$con=mysqli_connect("localhost","stoug_admindev","yg6Q91r$","stougma26066com26632_DBPressShareDev");
 
$dt = new DateTime();
$dt->modify('- 2 hours');
$maintenant = $dt->format('Y-m-d H:i:s');  
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}



?>