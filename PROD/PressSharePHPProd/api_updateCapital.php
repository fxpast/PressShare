<?php
 

session_start();
include 'api_connect.php';

  
// This SQL statement selects ALL from the table 'Locations'


$sql = "UPDATE Capital 
        SET
         date_maj = NOW(), 
         failure_count = '" . mysqli_real_escape_string($con, $_POST['failure_count']) . "', 
         balance = '" . mysqli_real_escape_string($con, $_POST['balance']) . "' 
         WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";

$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{		
        $flgOK = 1;		    
}


if ($flgOK == 0) {
    
    if ($_POST['lang'] == "us") 
    {
        $json =  array("success" => "0", "error" => "Connection failure"); 
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

