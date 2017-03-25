<?php
	session_start();
        include 'api_connect.php';
	
	if(!isset($_SESSION['login']))
	{
		header("location: authentification.php");
	}
	
	//création de la requête
	$query = "SELECT * FROM Feedback";
	
	//envoie de la requête et stockage de la reponse
	$queryFeedback = mysqli_query($con,$query);
	//$numRow = mysql
	
	//Menu
	echo '
		<!DOCTYPE html>
		<html lang="fr">
		<head>
			<meta charset="utf-8" />
			<link rel="stylesheet" type="text/css" href="style.css"/>
			<title>Les retours d\'informations</title>
		</head>
	' ;
	include("nav_bar.php") ;
       
       // feedback_id = 0
            //comment = ""
            //origin = ""
	echo '
		<body>
			<div id="show">
				<table>
					<th><td> feedback_id </td><td> comment </td><td> origin </td><td> Détails </td> </th>
	' ;
	$result = mysqli_fetch_row($queryFeedback);
	while ($result != NULL)
	{
		echo '			
		<tr><td> '.$result[0].' </td><td> '.$result[1].' </td><td> '.$result[2].' </td><td> Détails </td></tr>
		' ;
		$result = mysqli_fetch_row($queryFeedback);
	}
	echo '
				</table>
			</div>
		</body>
	' ;
	echo '</html>' ;
	
	mysqli_free_result($result) ;
?>