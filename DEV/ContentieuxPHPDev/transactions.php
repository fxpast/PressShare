<?php
	session_start();
        include 'api_connect.php';
	
	if(!isset($_SESSION['login']))
	{
		header("location: authentification.php");
	}
	
	//création de la requête
	$query = "SELECT * FROM Transaction" ;
	
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
			<title>Consultation des transactions</title>
		</head>
	' ;
	include("nav_bar.php") ;
     
	echo '
		<body>
			<div id="show">
				<table>
					<th><td> trans_id </td><td> trans_date </td><td> trans_type </td><td> trans_wording </td><td> trans_amount </td><td> prod_id </td>
                                        <td> client_id </td><td> vendeur_id </td><td> proprietaire </td><td> trans_valid </td><td> trans_avis </td><td> trans_arbitrage </td><td> Détails </td></th>
	' ;
	$result = mysqli_fetch_row($queryFeedback);
	while ($result != NULL)
	{
		echo '			
		<tr><td> '.$result[0].' </td><td> '.$result[1].' </td><td> '.$result[2].' </td><td> '.$result[3].' </td><td> '.$result[4].' </td><td> '.$result[5].' </td>
                <td> '.$result[6].' </td><td> '.$result[7].' </td><td> '.$result[8].' </td><td> '.$result[9].' </td><td> '.$result[10].' </td><td> '.$result[11].' </td><td> Détails </td></tr>
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