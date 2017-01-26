<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
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
    $json =  array("success" => "0", "error" => "echec connexion");    			    
}
else {
       
    $json =  array("success" => "1", "error" => "");    			    
}


echo json_encode($json);

// Close connections
mysqli_close($con);
?>

