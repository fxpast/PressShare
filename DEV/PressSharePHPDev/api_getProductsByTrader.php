<?php
 
session_start();
include 'connect.php';


// This SQL statement selects ALL from the table 'Locations'

$sql = "SELECT *
    FROM
            User
    WHERE
            user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";
 
$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
	
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
	    $flgOK = 1;	   
	}
        
}

if ($flgOK == 0) { 
	
        if ($_POST['lang'] == "us") 
        {                
                $jsonArray =  array("success" => "0", "allproducts" => array(), "error" => "connection failure");       
        }
        else if ($_POST['lang'] == "fr") 
        {
                $jsonArray =  array("success" => "0", "allproducts" => array(), "error" => "echec connexion"); 
        } 
          	
	echo json_encode($jsonArray);
	return ;
}


$sql = "SELECT p.*  
        FROM Product p, User u 
        WHERE p.prod_by_user = u.user_id and u.user_level > 0 and p.prod_hidden = 1 and (p.prod_by_user = '" . mysqli_real_escape_string($con, $_POST['user_id']) . 
            "' or p.prod_oth_user = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "') ORDER BY p.prod_date DESC";
 
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
                $jsonArray =  array("success" => "0", "allproducts" => array(), "error" => "no product");      
        }
        else if ($_POST['lang'] == "fr") 
        {
               $jsonArray =  array("success" => "0", "allproducts" => array(), "error" => "aucun produit");
        } 

	     
}
else {
	$jsonArray =  array("success" => "1", "allproducts" => $resultArray, "error" => "");     
}
 
echo json_encode($jsonArray);

// Close connections
mysqli_close($con);
?>