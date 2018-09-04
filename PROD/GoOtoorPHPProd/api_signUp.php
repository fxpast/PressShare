<?php
 
session_start();
include 'api_connect.php';

  
//the form has been posted without, so save it
		//notice the use of mysql_real_escape_string, keep everything safe!
		//also notice the sha1 function which hashes the password

$password = "'" . $_POST['user_pass'] . "'";


$sql = "INSERT INTO
		User(user_pseudo, user_pass, user_email ,user_date, user_level, user_nom, 
		user_prenom, user_adresse, user_codepostal, user_ville, user_tokenPush, user_pays, user_derconnexion, 
		user_nbreconnexion, user_latitude, user_longitude, user_mapString, user_newpassword, user_braintreeID)
	VALUES('" . mysqli_real_escape_string($con, $_POST['user_pseudo']) . "',
		   '" . sha1($password) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_email']) . "',
		   '" . $maintenant . "',
			0,
		   '" . mysqli_real_escape_string($con, $_POST['user_nom']) . "',
		    '" . mysqli_real_escape_string($con, $_POST['user_prenom']) . "',
		     '" . mysqli_real_escape_string($con, $_POST['user_adresse']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_codepostal']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_ville']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['user_tokenPush']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_pays']) . "',
           '" . $maintenant . "',
                   0,
		   '" . mysqli_real_escape_string($con, $_POST['user_latitude']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_longitude']) . "',		  
		   '" . mysqli_real_escape_string($con, $_POST['user_mapString']) . "',
		   0,
                   '')";
						

if ($_POST['user_pseudo'] == "" || $_POST['user_email'] == "") {
	$sql = "";
}		

// Check if there are results
$result = mysqli_query($con, $sql);
if(!$result)
{
	//something went wrong, display the error	
                
    if ($_POST['lang'] == "us") 
    {                                                       
             $json =  array("success" => "0", "error" => "connection failure");   
    }
    else if ($_POST['lang'] == "fr") 
    {
             $json =  array("success" => "0", "error" => "echec connexion");
    } 

                
                                    		
}
else {			
   $json =  array("success" => "1", "error" => "");    		
}
echo json_encode($json);
 
// Close connections
mysqli_close($con);

?>