<?php 
//connect.php


session_start();

 // Create connection
$con=mysqli_connect("localhost","stoug_website","2%1Lj9zi","stougma26066com26632_website");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}



?>