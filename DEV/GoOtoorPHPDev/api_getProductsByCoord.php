<?php
 
session_start();
include 'api_connect.php';


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
        FROM (SELECT DISTINCT pr.prod_id, pr.prod_imageUrl, pr.prod_nom, pr.prod_date, pr.prod_prix, pr.prod_by_user, pr.prod_oth_user, 
        pr.prod_by_cat, c.cre_latitude prod_latitude, c.cre_longitude prod_longitude, c.cre_mapString prod_mapString, pr.prod_comment, pr.prod_etat, pr.prod_hidden, pr.prod_echange, pr.prod_closed 
              FROM Product pr INNER JOIN Creneau c ON (pr.prod_id = c.prod_id) WHERE c.cre_dateDebut <= '" . $maintenant . "' AND c.cre_dateFin >= '" . $maintenant . "') p, User u 
        WHERE p.prod_by_user = u.user_id and u.user_level > 0 and p.prod_hidden = 0 and p.prod_latitude >= '" . mysqli_real_escape_string($con, $_POST['minLat']) . 
            "' and p.prod_latitude <= '" . mysqli_real_escape_string($con, $_POST['maxLat']) . "' and p.prod_longitude >= '" . 
            mysqli_real_escape_string($con, $_POST['minLon']) . "' and p.prod_longitude <= '" . mysqli_real_escape_string($con, $_POST['maxLon']) . "'
             ORDER BY p.prod_by_user";
 
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