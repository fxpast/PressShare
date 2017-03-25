<?php
	session_start();
        include 'api_connect.php';
	
	if(!isset($_SESSION['login']))
	{
		header("location: authentification.php");
	}
	
	
	//création de la requête
	$query = "SELECT * FROM ParamTable";
	
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
			<title>Consultation des paramètrages</title>
		</head>
	' ;
	include("nav_bar.php") ;
       
	echo '
		<body>
			<div id="show">
				<table>
					<th><td> param_id </td><td> distanceProduct </td><td> regionGeoLocat </td><td> regionProduct </td><td> commisPourcBuy </td>
                                        <td> commisFixEx </td><td> maxDayTrigger </td><td> subscriptAmount </td><td> minimumAmount </td><td> Détails </td> </th>
	' ;
	$result = mysqli_fetch_row($queryFeedback);
	while ($result != NULL)
	{
		echo '			
		<tr><td> '.$result[0].' </td><td> '.$result[1].' </td><td> '.$result[2].' </td><td> '.$result[3].' </td><td> '.$result[4].' </td>
                <td> '.$result[5].' </td><td> '.$result[6].' </td><td> '.$result[7].' </td><td> '.$result[8].' </td><td> Détails </td></tr>
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