<?php
 

session_start();
include 'connect.php';



$sql = "INSERT INTO
		Operation(user_id, op_date, op_type, op_amount, op_wording)
	VALUES('" . mysqli_real_escape_string($con, $_POST['user_id']) . "',		  
		   NOW(),
                    '" . mysqli_real_escape_string($con, $_POST['op_type']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['op_amount']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['op_wording']) . "')";
						

if ($_POST['op_wording'] == "") {
	$sql = "";
}		

// Check if there are results

$result = mysqli_query($con, $sql);

if(!$result)
{
    
    
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