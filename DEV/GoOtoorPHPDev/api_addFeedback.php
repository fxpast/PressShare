<?php
 

session_start();
include 'api_connect.php';


//`feedback_id`, `comment`, `origin`  
   
                                                                                                                                                                                 
$sql = "INSERT INTO Feedback(comment, origin)
        VALUES('" . mysqli_real_escape_string($con, $_POST['comment']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['origin']) . "')";

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