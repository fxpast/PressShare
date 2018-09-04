<?php

session_start();
include 'api_connect.php';
include 'bt_connect.php';
 
 
$sql = "SELECT *
    FROM
            User
    WHERE
            user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";
 

$isOK = 0; 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{	
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {          
        $isOK  = 1;	
        $braintreeID = $row->user_braintreeID;   
    }         
}

if ($isOK == 1) { 
    
    $amount = $_POST['amount'];
    $result = Braintree_Transaction::sale([
    'amount' => $amount,
    'customerId' => $braintreeID,
    'options' => ['storeInVaultOnSuccess' => true]
    ]);      
   
   if ($result->success) {        
        $json =  array("success" => "1", "btTransaction" => "0", "error" => "");                               
    } 
    else if ($result->transaction) {
                
        if ($_POST['lang'] == "us") 
        {
            
            $json =  array("success" => "0",  "btTransaction" => "0", "error" => "Error processing transaction, code: " . $result->transaction->processorResponseCode 
            . "\n  text: " . $result->transaction->processorResponseText);
                 
        }
        else if ($_POST['lang'] == "fr") 
        {
            
            $json =  array("success" => "0",  "btTransaction" => "0", "error" => "Erreur du processus de transaction, code: " . $result->transaction->processorResponseCode 
            . "\n  texte: " . $result->transaction->processorResponseText);
            
        }
         
    }
    else {
            
        if ($_POST['lang'] == "us") 
        {
            $message = "";
            foreach($result->errors->deepAll() AS $error) {
              $message = $message . $error->code . ": " . $error->message . "\n";
            }
            $json =  array("success" => "0",  "btTransaction" => "0", "error" => "Validation errors: " . $message);   
                 
        }
        else if ($_POST['lang'] == "fr") 
        {
            $message = "";
            foreach($result->errors->deepAll() AS $error) {
              $message = $message . $error->code . ": " . $error->message . "\n";
            }
            $json =  array("success" => "0",  "btTransaction" => "0", "error" => "Erreurs de validation: " . $message);            
        } 
            
    }
     
}
else {
    
    if ($_POST['lang'] == "us") 
    {                                                       
             $json =  array("success" => "0", "btTransaction" => "0", "error" => "customer id failure");   
    }
    else if ($_POST['lang'] == "fr") 
    {
             $json =  array("success" => "0", "btTransaction" => "0", "error" => "echec identifiant client");
    } 
    
}

 echo json_encode($json);



?>