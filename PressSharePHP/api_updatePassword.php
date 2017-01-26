<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
// This SQL statement selects ALL from the table 'Locations'

    $sql = "SELECT 
            user_id,
            user_pseudo,
            user_pass,
            user_email,
            user_nom, 
			user_prenom
    FROM
            User
    WHERE
            user_email = '" . mysqli_real_escape_string($con, $_POST['user_email']) . "'";
            
            
if ($_POST['user_newpassword'] == FALSE) {
 
    $sql = $sql . " and user_pass = '" . sha1(mysqli_real_escape_string($con, $_POST['user_pass'])) . "'";
}

        
   
 
$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
	// If so, then create a results array and a temporary one
	// to hold the data
    
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
            // Add each row into our results array
            $userid = $row->user_id;
            $pseudo = $row->user_pseudo;
            $nom = $row->user_nom;
            $prenom = $row->user_prenom;
            $flgOK = 1;
              
	}
        
}


if ($flgOK == 0) {
    if ($_POST['lang'] == "us") 
    {
        $json =  array("success" => "0", "error" => "Connection failure email / password"); 
    }
    else if ($_POST['lang'] == "fr") 
    {
        $json =  array("success" => "0", "error" => "echec connexion email / password"); 
    } 
     		
}
else {
	    
	$sql = "UPDATE User			
	        SET user_pass = '" . sha1($_POST['user_lastpass']) . "',
	        user_newpassword = '" . $_POST['user_newpassword'] . "' 
	        WHERE
            user_id = '" . mysqli_real_escape_string($con, $userid) . "'";
	
	$flgOK = 0; 
	// Check if there are results
	if ($result = mysqli_query($con, $sql))
	{		
		$flgOK = 1;		    
	}
	
	
	if ($flgOK == 0) {
	    $json =  array("success" => "0", "error" => "echec connexion");    			    
	}
	else {
		if ($_POST['user_newpassword'] == TRUE) {
		
                    if ($_POST['lang'] == "us") 
                    { 
                        $message  = "Dear member,
                        Following your request here are your login credentials to your account.
                            Login connection : " . $pseudo . "
                            Password : " . $_POST['user_lastpass'] ;
                                                      //on envoie le mail
                        mail($_POST['user_email'], $prenom . ' ' . $nom . ' : Your password', $message, "From:admin@fxpast.com" );
                    }
                    else if ($_POST['lang'] == "fr") 
                    { 
                        $message  = "Cher membre,
                        Suite a votre demande voici vos identifiants de connexion a votre compte.
                        Login de connexion : " . $pseudo . "
                        Mot de passe : " . $_POST['user_lastpass'] ;
                                                      //on envoie le mail
                        mail($_POST['user_email'], $prenom . ' ' . $nom . ' : Votre mot de passe', $message, "From:admin@fxpast.com" );
                    }
                                                     
                      
	  	}
		$json =  array("success" => "1", "error" => "");    			    
	}
}

echo json_encode($json);

// Close connections
mysqli_close($con);
?>

