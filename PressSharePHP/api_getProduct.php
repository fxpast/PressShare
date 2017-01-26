<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
// This SQL statement selects ALL from the table 'Locations'



$sql = "SELECT p.*  
        FROM Product p, User u 
        WHERE prod_id = '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "' and p.prod_hidden = false and p.prod_by_user = u.user_id and u.user_level > 0 
        ORDER BY prod_by_user";
 
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