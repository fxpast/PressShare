<?php


session_start();
include 'connect.php';



if ($_POST['prod_imageUrl'] != "")
{
    $target_dir = "images/" . basename($_FILES["file"]["name"]);
        
    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_dir)) 
    {
        $json =  array("success" => "1", "error" => ""); 
    }
    else {
        
            
        if ($_POST['lang'] == "us") 
        {
             $json =  array("success" => "0", "error" => "Sorry, there was an error uploading your file.");
        }
        else if ($_POST['lang'] == "fr") 
        {
             $json =  array("success" => "0", "error" => "Desolé, il y avait une erreur dans le chargement de ton fichier.");
        } 
         
         
       
        echo json_encode($json);
        return;
    }

}


if ($_POST['prod_echange'] == "false") {
 
    $prod_echange = 0;
}
else {
    $prod_echange = 1;
}  


$sql = "INSERT INTO
		Product(prod_nom, prod_imageUrl, prod_date ,prod_prix, prod_by_user, prod_oth_user, prod_by_cat, 
		prod_latitude, prod_longitude, prod_mapString, prod_comment, prod_tempsDispo, prod_etat, prod_hidden, prod_echange, prod_closed)
	VALUES('" . mysqli_real_escape_string($con, $_POST['prod_nom']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['prod_imageUrl']) . "',
			NOW(),
		   " . mysqli_real_escape_string($con, $_POST['prod_prix']) . ",
		    " . mysqli_real_escape_string($con, $_POST['prod_by_user']) . ",
                     0,
		     0,		   
		   " . mysqli_real_escape_string($con, $_POST['prod_latitude']) . ",
		   " . mysqli_real_escape_string($con, $_POST['prod_longitude']) . ",	
                    '" . mysqli_real_escape_string($con, $_POST['prod_mapString']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['prod_comment']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['prod_tempsDispo']) . "',	  
		   '" . mysqli_real_escape_string($con, $_POST['prod_etat']) . "',
                   0,
                   " . mysqli_real_escape_string($con, $prod_echange) . ",
                   0)";
                   			

if ($_POST['prod_nom'] == "") {
	
      if ($_POST['lang'] == "us") 
        {
              $json =  array("success" => "0", "error" => "invalid name");
        }
        else if ($_POST['lang'] == "fr") 
        {
               $json =  array("success" => "0", "error" => "nom invalide");
        } 
        

 echo json_encode($json);
 return;
  
}		

// Check if there are results
$result = mysqli_query($con, $sql);
if(!$result)
{
	//something went wrong, display the error	
  $json =  array("success" => "0", "error" => $sql);
     		
}
else {			
    
   $json =  array("success" => "1", "error" => ""); 

    		
}
echo json_encode($json);
 
// Close connections
mysqli_close($con);

?>