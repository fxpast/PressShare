<?php
	session_start();
        include 'api_connect.php';
	
	if(!isset($_SESSION['login']))
	{
		header("location: authentification.php");
	}
	
	$U_login = $_SESSION['login'];
	

	//création de la requête
	
	
	echo '
		<!DOCTYPE html>
		<html lang="fr">
		<head>
			<meta charset="utf-8" />
			<link rel="stylesheet" type="text/css" href="style.css"/>
			<title>Acceuil</title>
		</head>
	' ;
	include("nav_bar.php") ;
	echo '</html>' ;
?>