<?php 
session_start();
//connect.php
$server	  = 'localhost';
$username = 'stoug_admin';
$password = '6%u75Usd';
$database = 'stougma26066com26632_bdpress';

if(!mysql_connect($server, $username, $password))
{
 	exit('Error: could not establish database connection');
}
if(!mysql_select_db($database))
{
 	exit('Error: could not select the database');
}
?>