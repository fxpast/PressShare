<?php
	session_start();
        include 'api_connect.php';
	
	if(isset($_SESSION['login']))
	{
		header("location: index.php");
	}
	
	$errmsg = "";
	$access_allowed = false;
	
	if(isset($_POST["signin"]))
	{
		if(empty($_POST["login"]) || empty($_POST["pwd"]))
			$errmsg = "Tous les champs ne sont pas remplis" ;
		else
		{
		
                    //Données utilisateur
                    $U_login = $_POST["login"] ;
                    $U_pwd = "'".$_POST["pwd"]."'" ;
                    $U_pwd_encrypt = sha1($U_pwd) ;
                    
                    //création de la requête
                    $query = "SELECT user_pseudo, user_pass, user_level 
                    FROM User 
                    WHERE user_pseudo='".$U_login."' AND user_pass = '".$U_pwd_encrypt."'" ;
                    
                    //envoie de la requête et stockage de la reponse
                    $queryFeedback = mysqli_query($con,$query);
                    $result = mysqli_fetch_array($queryFeedback);
                    
                    //traitement de la requête
                    if ($queryFeedback && $result['user_level'] == 2)
                    {
                            $access_allowed = true;
                    }
                    else
                    {
                            $access_allowed = false;
                            $errmsg = "Identifiant ou mot de passe erroné" ;
                    }
                    mysqli_free_result($result) ;
                            
		}
	}
	
	if(!$access_allowed)
	{
		echo '
			<!DOCTYPE html>
			<html lang="fr">
			<head>
				<meta charset="utf-8" />
				<link rel="stylesheet" type="text/css" href="style.css"/>
				<title>Authentification</title>
			</head>
			
			<body>
				<div id="authentificationBox">
					<h1>Authentification</h1>
					<form action="" method="Post">
					<span class="errmsg">'.$errmsg.'</span><br/>
						Utilisateur : <input name="login"/> <br/>
						Mot de passe : <input type="password" name="pwd"/> <br/><br/>
						<input type="submit" name="signin" value="Connexion"/>
					</form>
				</div>
			</body>
			
			<footer>
			</footer>
			</html>
		' ;
	}
	else
	{
		$_SESSION['login'] = $U_login ;
		header("Refresh:0") ;
	}
?>