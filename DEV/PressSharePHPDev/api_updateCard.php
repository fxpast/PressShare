<?php
 
session_start();
include 'api_connect.php';
include 'bt_connect.php';
  
// This SQL statement selects ALL from the table 'Locations'


if ($_POST['main_card'] == "false") {
 
    $mainCard = 0;
    $isMainCard = false;
}
else {
    $mainCard = 1;
    $isMainCard = true;
}    


$token = $_POST['tokenizedCard'];

$result = Braintree_PaymentMethod::update(
  $token,
  [
    'options' => [
      'makeDefault' => $isMainCard
    ]
  ]
);
 
$flgOK = 0;  
if ($result->success) {
     
    $sql = "UPDATE Card			
        SET main_card = '" . $mainCard . "'
        WHERE
        card_id = '" . mysqli_real_escape_string($con, $_POST['card_id']) . "'";

    // Check if there are results
    if ($result = mysqli_query($con, $sql))
    {		
        $flgOK = 1;		    
    }

}
       
        
if ($flgOK == 0) {
    
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

