<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
//the form has been posted without, so save it
		//notice the use of mysql_real_escape_string, keep everything safe!
		//also notice the sha1 function which hashes the password


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