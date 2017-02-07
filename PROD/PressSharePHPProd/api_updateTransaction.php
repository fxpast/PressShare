<?php
 

session_start();
include 'connect.php';
 
// This SQL statement selects ALL from the table 'Locations'

$sql = "UPDATE Transaction			
        SET trans_valid = '" . mysqli_real_escape_string($con, $_POST['trans_valid']) . "',            
            trans_avis = '" . mysqli_real_escape_string($con, $_POST['trans_avis']) . "'
        WHERE
        trans_id = '" . mysqli_real_escape_string($con, $_POST['trans_id']) . "'";

$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{		
        $flgOK = 1;		    
}


if ($flgOK == 0) {
                     
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

