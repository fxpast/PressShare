<?php
 
session_start();
include 'connect.php';

  
// This SQL statement selects ALL from the table 'Locations'

    $sql = "DELETE 
    FROM
            Card
    WHERE
            card_id = " . mysqli_real_escape_string($con, $_POST['card_id']);

  
 
// Check if there are results
$result = mysqli_query($con, $sql);
if(!$result)
{
	//something went wrong, display the error	
  $json =  array("success" => "0", "error" => $sql);
     		
}
else {			
    
   $json =  array("success" => "1", "error" => ""); 
    		
}
echo json_encode($json);
 
// Close connections
mysqli_close($con);
?>
