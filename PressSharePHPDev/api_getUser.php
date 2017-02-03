<?php
 

session_start();
include 'connect.php';

  
// This SQL statement selects ALL from the table 'Locations'


$sql = "SELECT *
    FROM
            User
    WHERE
            user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";
 

$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
	
     	$resultArray = array();
	$tempArray = array();
		
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
            // Add each row into our results array
            $tempArray = $row;
	    array_push($resultArray, $tempArray);
	    $flgOK = 1;
	   
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
	$jsonArray =  array("success" => "1", "user" => $resultArray, "error" => "");     
}
 
echo json_encode($jsonArray);

// Close connections
mysqli_close($con);
?>