<?php

session_start();
include 'connect.php';


if ($_POST['prodImageOld'] != "")
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
    
    
    unlink("'images/" . $_POST['prodImageOld'] . ".jpg'");

}




// This SQL statement selects ALL from the table 'Locations'

if ($_POST['prod_hidden'] == "false") {
 
    $prod_hidden = 0;
}
else {
    $prod_hidden = 1;
}  

if ($_POST['prod_echange'] == "false") {
 
    $prod_echange = 0;
}
else {
    $prod_echange = 1;
}  



$sql = "UPDATE Product			
        SET prod_nom = '" . mysqli_real_escape_string($con, $_POST['prod_nom']) . "',         
         prod_prix = '" . mysqli_real_escape_string($con, $_POST['prod_prix']) . "',
         prod_latitude = '" . mysqli_real_escape_string($con, $_POST['prod_latitude']) . "',
         prod_longitude = '" . mysqli_real_escape_string($con, $_POST['prod_longitude']) . "',
         prod_mapString = '" . mysqli_real_escape_string($con, $_POST['prod_mapString']) . "',
         prod_comment = '" . mysqli_real_escape_string($con, $_POST['prod_comment']) . "',
         prod_tempsDispo = '" . mysqli_real_escape_string($con, $_POST['prod_tempsDispo']) . "',
         prod_etat = '" . mysqli_real_escape_string($con, $_POST['prod_etat']) . "',
         prod_hidden = '" . mysqli_real_escape_string($con, $prod_hidden) . "',
         prod_echange = '" . mysqli_real_escape_string($con, $prod_echange) . "',
         prod_imageUrl = '" . mysqli_real_escape_string($con, $_POST['prod_imageUrl']) . "'        
        WHERE
        prod_id = '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "'";


$result = mysqli_query($con, $sql);



$flgOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{		
        $flgOK = 1;		    
}


if ($flgOK == 0) {
 
    if ($_POST['lang'] == "us") 
    {
            $json =  array("success" => "0", "error" => "connection failure"); 
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

