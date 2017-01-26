<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
//the form has been posted without, so save it
		//notice the use of mysql_real_escape_string, keep everything safe!
		//also notice the sha1 function which hashes the password


$sql = "INSERT INTO
		User(user_pseudo, user_pass, user_email ,user_date, user_level, user_nom, 
		user_prenom, user_adresse, user_codepostal, user_ville, user_pays, user_derconnexion, 
		user_nbreconnexion, user_latitude, user_longitude, user_mapString, user_newpassword)
	VALUES('" . mysqli_real_escape_string($con, $_POST['user_pseudo']) . "',
		   '" . sha1($_POST['user_pass']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_email']) . "',
			NOW(),
			0,
		   '" . mysqli_real_escape_string($con, $_POST['user_nom']) . "',
		    '" . mysqli_real_escape_string($con, $_POST['user_prenom']) . "',
		     '" . mysqli_real_escape_string($con, $_POST['user_adresse']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_codepostal']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_ville']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_pays']) . "',
                   NOW(),
                   0,
		   '" . mysqli_real_escape_string($con, $_POST['user_latitude']) . "',
		   '" . mysqli_real_escape_string($con, $_POST['user_longitude']) . "',		  
		   '" . mysqli_real_escape_string($con, $_POST['user_mapString']) . "',
		   0)";
						

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