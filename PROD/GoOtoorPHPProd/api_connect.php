<?php 
//connect.php


session_start();

 // Create connection
$con=mysqli_connect("localhost","stoug_adminprod","eH!a72m1","stougma26066com26632_DBPressShareProd");
 
$dt = new DateTime();
$dt->modify('- 2 hours');
$maintenant = $dt->format('Y-m-d H:i:s');  
 

// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}



?>