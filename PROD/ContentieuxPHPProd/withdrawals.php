<?php
	session_start();
        include 'api_connect.php';
	
	if(!isset($_SESSION['login']))
	{
		header("location: authentification.php");
	}
	
	//création de la requête
	$query = "SELECT * FROM OperationCredit";
	
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
			<title>Consultation des retraits</title>
		</head>
	' ;
	include("nav_bar.php") ;
	echo '
		<body>
			<div id="show">
				<table>
					<th><td> op_id </td><td> user_id </td><td> op_date </td><td> op_amount </td><td> Détails </td></th>
	' ;
	$result = mysqli_fetch_row($queryFeedback);
	while ($result != NULL)
	{
		echo '			
		<tr><td>'.$result[0].'</td><td>'.$result[1].'</td><td>'.$result[2].'</td><td>'.$result[3].'</td><td>Détails</td></tr>
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