<?php
 

session_start();
include 'api_connect.php';

  
// This SQL statement selects ALL from the table 'Locations'

$sql = "SELECT * FROM Product WHERE prod_id = '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "'";
 
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
		$tempArray = $row;
	    array_push($resultArray, $tempArray);
	   
	}
        
        $flgOK = 1;        
}


if ($flgOK == 0) { 
        if ($_POST['lang'] == "us") 
        {                
                $jsonArray =  array("success" => "0", "aproduct" => array(), "error" => "no product");      
        }
        else if ($_POST['lang'] == "fr") 
        {
               $jsonArray =  array("success" => "0", "aproduct" => array(), "error" => "aucun produit");
        } 
	     
}
else {
	$jsonArray =  array("success" => "1", "aproduct" => $resultArray, "error" => "");     
}
 
echo json_encode($jsonArray);

// Close connections
mysqli_close($con);
?>