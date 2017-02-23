<?php
 

session_start();
include 'connect.php';

$cardNumber = "'" . $_POST['card_number'] . "'";
$cardOwner = "'" . $_POST['card_owner'] . "'";
$cardDate = "'" . $_POST['card_date'] . "'";
$cardCrypto = "'" . $_POST['card_crypto'] . "'";


$sql = "INSERT INTO
		Card(typeCard_id, user_id, card_number, card_lastNumber, card_owner, card_date, card_crypto, main_card)
	VALUES('" . mysqli_real_escape_string($con, $_POST['typeCard_id']) . "',
                   '" . mysqli_real_escape_string($con, $_POST['user_id']) . "',		  
                   '" . sha1($cardNumber) . "',
                   '" . mysqli_real_escape_string($con, $_POST['card_lastNumber']) . "',
                   '" . sha1($cardOwner) . "',
                   '" . sha1($cardDate) . "',
                   '" . sha1($cardCrypto) . "',
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