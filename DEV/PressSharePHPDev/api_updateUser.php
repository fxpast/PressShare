<?php
 

session_start();
include 'connect.php';
 
//the form has been posted without, so save it
		//notice the use of mysql_real_escape_string, keep everything safe!
		//also notice the sha1 function which hashes the password

$password = "'" . $_POST['user_pass'] . "'";


$sql = "UPDATE User SET
		user_pseudo = '" . mysqli_real_escape_string($con, $_POST['user_pseudo']) . "',
		user_pass = '" . sha1($password) . "',
                user_level = '" . mysqli_real_escape_string($con, $_POST['user_level']) . "',
		user_email = '" . mysqli_real_escape_string($con, $_POST['user_email']) . "',
		user_nom = '" . mysqli_real_escape_string($con, $_POST['user_nom']) . "',
		user_prenom = '" . mysqli_real_escape_string($con, $_POST['user_prenom']) . "',
		user_adresse = '" . mysqli_real_escape_string($con, $_POST['user_adresse']) . "',
		user_codepostal = '" . mysqli_real_escape_string($con, $_POST['user_codepostal']) . "',
		user_ville = '" . mysqli_real_escape_string($con, $_POST['user_ville']) . "',
                user_tokenPush = '" . mysqli_real_escape_string($con, $_POST['user_tokenPush']) . "',                
		user_pays = '" . mysqli_real_escape_string($con, $_POST['user_pays']) . "'
		WHERE
        user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";


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