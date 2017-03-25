<?php
 


session_start();
include 'api_connect.php';

  
//the form has been posted without, so save it
		//notice the use of mysql_real_escape_string, keep everything safe!
		//also notice the sha1 function which hashes the password

$sql = "SELECT * FROM Capital WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";
       
       
$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{

    $flgOK = 1;
    $resultArray = array();
    $tempArray = array();
            
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {
        // Add each row into our results array
        $tempArray = $row;
        array_push($resultArray, $tempArray);
        $flgOK = 2;
       
    }
    
        
}


if ($flgOK == 0) { 
        if ($_POST['lang'] == "us") 
        {                                   
                 $jsonArray =  array("success" => "0", "allcapitals" => array(), "error" => "connection failure");      
        }
        else if ($_POST['lang'] == "fr") 
        {
                 $jsonArray =  array("success" => "0", "allcapitals" => array(), "error" => "echec connexion"); 
        } 
    
       
}
else if ($flgOK == 1)   {
            
    $sql = "INSERT INTO Capital(user_id, date_maj, balance, failure_count) VALUES('" . mysqli_real_escape_string($con, $_POST['user_id']) . "', NOW(), 0, 0)";
                                                    
    // Check if there are results
    $result = mysqli_query($con, $sql);
 

    $sql = "SELECT * FROM Capital WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";
           
    
    // Check if there are results
    if ($result = mysqli_query($con, $sql))
    {

        $resultArray = array();
        $tempArray = array();
                
        // Loop through each row in the result set
        while($row = $result->fetch_object())
        {
            // Add each row into our results array
            $tempArray = $row;
            array_push($resultArray, $tempArray);
        }
        
        $jsonArray =  array("success" => "1", "allcapitals" => $resultArray, "error" => "");  
            
    }

	     
}
else if ($flgOK == 2)   {
    $jsonArray =  array("success" => "1", "allcapitals" => $resultArray, "error" => "");     
}
 
 

echo json_encode($jsonArray);
 
// Close connections
mysqli_close($con);

?>