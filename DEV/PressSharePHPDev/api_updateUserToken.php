<?php
 
 
session_start();
include 'connect.php';
  
//the form has been posted without, so save it
		//notice the use of mysql_real_escape_string, keep everything safe!
		//also notice the sha1 function which hashes the password

$sql = "UPDATE User SET	user_tokenPush = '" . mysqli_real_escape_string($con, $_POST['user_tokenPush']) . "' WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";


// Check if there are results
$result = mysqli_query($con, $sql);
if(!$result)
{
	//something went wrong, display the error	
            
        if ($_POST['lang'] == "us") 
        {                                                       
                 $json =  array("success" => "0", "error" => "connection database user failure");   
        }
        else if ($_POST['lang'] == "fr") 
        {
                 $json =  array("success" => "0", "error" => "echec connexion base de donnée user");
        } 

                  		
}
else {			
   $json =  array("success" => "1", "error" => "");    		
}
echo json_encode($json);
 
// Close connections
mysqli_close($con);

?>