<?php

session_start();
include 'api_connect.php';
include 'bt_connect.php';
 
 

$sql = "SELECT *
    FROM
            User
    WHERE
            user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";
 

$isOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{	
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{          
	    $isOK  = 1;	   
	}        
}

 
if ($isOK == 1) { 

    $clientToken = Braintree_ClientToken::generate();

    if ($clientToken) {
        
       $json =  array("success" => "1", "clientToken" => $clientToken, "error" => "");  

    } 
    else {
        
        if ($_POST['lang'] == "us") 
        {
             $json =  array("success" => "0", "clientToken" => "", "error" => "impossible to generate a client token"); 
        }
        else if ($_POST['lang'] == "fr") 
        {
            $json =  array("success" => "0", "clientToken" => "", "error" => "impossible de générer un token client"); 
        } 
        
         
    }
    
    echo json_encode($json);
}



?>