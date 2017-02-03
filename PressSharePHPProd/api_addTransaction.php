<?php
 

session_start();
include 'connect.php';



if ($_POST['trans_type'] == 2) //exchange
    {
        $sql = "INSERT INTO
            Transaction(trans_date, trans_type, trans_wording, trans_amount, prod_id, client_id, vendeur_id, proprietaire, trans_valide, trans_avis)
            VALUES(NOW(),
            '" . mysqli_real_escape_string($con, $_POST['trans_type']) . "',		  		  
                        '" . mysqli_real_escape_string($con, $_POST['trans_wording']) . "',
                         '" . mysqli_real_escape_string($con, $_POST['trans_amount']) . "',
                        '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "',
                        '" . mysqli_real_escape_string($con, $_POST['client_id']) . "',
                        '" . mysqli_real_escape_string($con, $_POST['vendeur_id']) . "',
                        '" . mysqli_real_escape_string($con, $_POST['vendeur_id']) . "',
                        0,
                        '" . mysqli_real_escape_string($con, $_POST['trans_avis']) . "')";
                                                    

        if ($_POST['trans_wording'] == "") {
                $sql = "";
        }		

        // Check if there are results
        $result = mysqli_query($con, $sql);


    }


//exchange and trade
$sql = "INSERT INTO
        Transaction(trans_date, trans_type, trans_wording, trans_amount, prod_id, client_id, vendeur_id, proprietaire, trans_valide, trans_avis)
	VALUES(NOW(),
        '" . mysqli_real_escape_string($con, $_POST['trans_type']) . "',		  		  
                    '" . mysqli_real_escape_string($con, $_POST['trans_wording']) . "',
                     '" . mysqli_real_escape_string($con, $_POST['trans_amount']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['client_id']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['vendeur_id']) . "',
                    '" . mysqli_real_escape_string($con, $_POST['client_id']) . "',
                    0,
                    '" . mysqli_real_escape_string($con, $_POST['trans_avis']) . "')";


// Check if there are results

$result = mysqli_query($con, $sql);

if(!$result)
{
	//something went wrong, display the error	
 
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