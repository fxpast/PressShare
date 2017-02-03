<?php
 
session_start();
include 'connect.php';

  
// This SQL statement selects ALL from the table 'Locations'


if ($_POST['deja_lu_exp'] == FALSE) {
 
    $dejaluExp = 0;
}
else {
    $dejaluExp = 1;
}    

    
if ($_POST['deja_lu_dest'] == FALSE) {
 
    $dejaluDest = 0;
}
else {
    $dejaluDest = 1;
} 

        
$sql = "UPDATE Message			
        SET deja_lu_exp = '" . $dejaluExp . "',
            deja_lu_dest = '" . $dejaluDest . "'
        WHERE
        message_id = '" . mysqli_real_escape_string($con, $_POST['message_id']) . "'";

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
       
    $json =  array("success" => "1", "error" => "");    			    
}


echo json_encode($json);

// Close connections
mysqli_close($con);
?>

