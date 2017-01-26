<?php
 

 $result = unlink("images/" . $_POST['prod_image'] . ".jpg");

 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
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

