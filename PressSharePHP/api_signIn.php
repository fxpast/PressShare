<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
// This SQL statement selects ALL from the table 'Locations'

	 
$sql = "SELECT *
    FROM
            User
    WHERE
            user_pseudo = '" . mysqli_real_escape_string($con, $_POST['user_pseudo']) . "'";
            
 
$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
	// If so, then create a results array and a temporary one
	// to hold the data
    
 	$resultArray = array();
	$tempArray = array();
	
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
		// Add each row into our results array
        $hashage = $row->user_pass;
        $password =  sha1($_POST['user_pass']);
                
        if ($password == $hashage) {
            $flgOK = 1;    
            $nbreConnexion = $row->user_nbreconnexion + 1;
            $userid = $row->user_id;          
          	$tempArray = $row;
  			array_push($resultArray, $tempArray);
        }
        else {
            $flgOK = 2;                  
        }
                
	}
        
}


if ($flgOK == 0 || $flgOK == 2) { 
    
        
        if ($_POST['lang'] == "us") 
        {                                   
                 $jsonArray =  array("success" => "0", "user" => array(), "error" => "connection failure");       
        }
        else if ($_POST['lang'] == "fr") 
        {
                 $jsonArray =  array("success" => "0", "user" => array(), "error" => "echec connexion"); 
        } 

	    
}
else {
	
	$sql = "UPDATE User			
	        SET user_derconnexion = NOW(), 
	         user_nbreconnexion = '" . mysqli_real_escape_string($con, $nbreConnexion) . "'	         
	        WHERE
            user_id = '" . mysqli_real_escape_string($con, $userid) . "'";

	$result = mysqli_query($con, $sql);	
	
	$jsonArray =  array("success" => "1", "user" => $resultArray, "error" => "");     
	
}
echo json_encode($jsonArray);


// Close connections
mysqli_close($con);
?>