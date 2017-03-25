<?php
 

session_start();
include 'api_connect.php';


// This SQL statement selects ALL from the table 'Locations'

$sql = "SELECT *
    FROM
            User
    WHERE
            user_email = '" . mysqli_real_escape_string($con, $_POST['user_email']) . "'";
            
 
$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
	// If so, then create a results array and a temporary one
	// to hold the data
    
 	$resultArray = array();
	$tempArray = array();
	
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
		// Add each row into our results array                
        $flgOK = 1;
        $nbreConnexion = $row->user_nbreconnexion + 1;
        $userid = $row->user_id;          
        $tempArray = $row;
	 	array_push($resultArray, $tempArray);                
	}
        
}


if ($flgOK == 0) {
    
        if ($_POST['lang'] == "us") 
        {                
                $jsonArray =  array("success" => "0", "user" => array(), "error" => "connection failure");        
        }
        else if ($_POST['lang'] == "fr") 
        {
                $jsonArray =  array("success" => "0", "user" => array(), "error" => "echec connexion");
        } 
          
}
else {
	
	$sql = "UPDATE User			
	        SET user_derconnexion = NOW(), 
	         user_nbreconnexion = '" . mysqli_real_escape_string($con, $nbreConnexion) . "'	         
	        WHERE
            user_id = '" . mysqli_real_escape_string($con, $userid) . "'";

	$result = mysqli_query($con, $sql);	
	
	$jsonArray =  array("success" => "1", "user" => $resultArray, "error" => ""); 
}

echo json_encode($jsonArray);


// Close connections
mysqli_close($con);
?>