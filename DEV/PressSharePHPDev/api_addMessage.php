<?php
 

session_start();
include 'api_connect.php';



$sql = "INSERT INTO
		Message(expediteur, destinataire, proprietaire, vendeur_id, client_id, product_id, date_ajout ,contenu, deja_lu_exp, deja_lu_dest)
	VALUES('" . mysqli_real_escape_string($con, $_POST['expediteur']) . "',		  
		   '" . mysqli_real_escape_string($con, $_POST['destinataire']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['expediteur']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['vendeur_id']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['client_id']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['product_id']) . "',
			NOW(),			
		   '" . mysqli_real_escape_string($con, $_POST['contenu']) . "',
                   0,
                   0)";
						

if ($_POST['contenu'] == "") {
	$sql = "";
}		

// Check if there are results
$result = mysqli_query($con, $sql);


$sql = "INSERT INTO
		Message(expediteur, destinataire, proprietaire, vendeur_id, client_id, product_id, date_ajout ,contenu, deja_lu_exp, deja_lu_dest)
	VALUES('" . mysqli_real_escape_string($con, $_POST['expediteur']) . "',		  
		   '" . mysqli_real_escape_string($con, $_POST['destinataire']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['destinataire']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['vendeur_id']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['client_id']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['product_id']) . "',
			NOW(),			
		   '" . mysqli_real_escape_string($con, $_POST['contenu']) . "',
                   0,
                   0)";
						


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