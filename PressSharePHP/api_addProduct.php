<?php


if ($_POST['prod_image'] != "")
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


// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  $json =  "Failed to connect to MySQL: " . mysqli_connect_error();
  echo json_encode($json);
  return;
}
 
//the form has been posted without, so save it
		//notice the use of mysql_real_escape_string, keep everything safe!
		//also notice the sha1 function which hashes the password


$sql = "INSERT INTO
		Product(prod_nom, prod_image, prod_date ,prod_prix, prod_by_user, prod_by_cat, 
		prod_latitude, prod_longitude, prod_mapString, prod_comment, prod_tempsDispo, prod_etat, prod_hidden)
	VALUES('" . mysqli_real_escape_string($con, $_POST['prod_nom']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['prod_image']) . "',
			NOW(),
		   " . mysqli_real_escape_string($con, $_POST['prod_prix']) . ",
		    " . mysqli_real_escape_string($con, $_POST['prod_by_user']) . ",
                    " . mysqli_real_escape_string($con, $_POST['prod_oth_user']) . ",
		     0,		   
		   " . mysqli_real_escape_string($con, $_POST['prod_latitude']) . ",
		   " . mysqli_real_escape_string($con, $_POST['prod_longitude']) . ",	
                    '" . mysqli_real_escape_string($con, $_POST['prod_mapString']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['prod_comment']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['prod_tempsDispo']) . "',	  
		   '" . mysqli_real_escape_string($con, $_POST['prod_etat']) . "',
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