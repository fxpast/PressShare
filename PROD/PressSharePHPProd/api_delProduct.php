<?php
 


session_start();
include 'connect.php';



 $result = unlink("images/" . $_POST['prod_imageUrl'] . ".jpg");


// This SQL statement selects ALL from the table 'Locations'

    $sql = "DELETE 
    FROM
            Product
    WHERE
            prod_id = " . mysqli_real_escape_string($con, $_POST['prod_id']);

  
 
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

