<?php
  

session_start();
include 'connect.php';


$sql = "INSERT INTO
		Commission(user_id, product_id, com_date, com_amount)
	VALUES('" . mysqli_real_escape_string($con, $_POST['user_id']) . "',		  
		   '" . mysqli_real_escape_string($con, $_POST['product_id']) . "',
			NOW(),			
		   '" . mysqli_real_escape_string($con, $_POST['com_amount']) . "')";
						

if ($_POST['user_id'] == "") {
	$sql = "";
}		

// Check if there are results
$result = mysqli_query($con, $sql);

$amount = -1 * $_POST['com_amount'];
$wording = "Commission";
$type = 5;

$sql = "INSERT INTO
		Operation(user_id, op_date, op_type, op_amount, op_wording)
	VALUES('" . mysqli_real_escape_string($con, $_POST['user_id']) . "',		  
		   NOW(),
                    '" . mysqli_real_escape_string($con, $type) . "',
                    '" . mysqli_real_escape_string($con, $amount) . "',
                    '" . mysqli_real_escape_string($con, $wording) . "')";
								
// Check if there are results

$result = mysqli_query($con, $sql);


$sql = "UPDATE Capital 
        SET
         date_maj = NOW(), 
         balance = '" . mysqli_real_escape_string($con, $_POST['balance']) . "' 
         WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";


$result = mysqli_query($con, $sql);


if(!$result)
{
	//something went wrong, display the error	
     
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