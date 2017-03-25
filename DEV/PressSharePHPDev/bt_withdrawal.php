<?php

session_start();
include 'api_connect.php';
include 'bt_connect.php';
 
$sql = "SELECT *
    FROM
            User
    WHERE
            user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";

$braintreeID = "";  

// Check if there are results
if ($result = mysqli_query($con, $sql))
{	
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {          	
        $braintreeID = $row->user_braintreeID;   
    }  
          
}

$amount = $_POST['amount'];

$isOK = 0; 

$collection = Braintree_Transaction::search([
  Braintree_TransactionSearch::customerId()->is($braintreeID),
]);


foreach($collection as $transaction) {
    $btTransID = $transaction->id;
    $btAmount = $transaction->amount;        
    $status = $transaction->status;
    $type = $transaction->type;
     
    if ($type == "sale" && ($status == "settled" || $status == "settling")) { 
        
           if ($amount == $btAmount && $amount > 0) {
                $result = Braintree_Transaction::refund($btTransID, $amount);
                $amount = 0;                
                $isOK = 1; 
                break;
           }
                       
    }        
    else if ($type == "sale" && ($status == "authorized" || $status == "submitted_for_settlement")) {  
       
        if ($amount == $btAmount && $amount > 0) {
            $result = Braintree_Transaction::void($btTransID); 
            $amount = 0; 
            $isOK = 1;
            break;                   
        }
           
          
    }
    
    
}



foreach($collection as $transaction) {
    $btTransID = $transaction->id;
    $btAmount = $transaction->amount;        
    $status = $transaction->status;
    $type = $transaction->type;
    
    if ($type == "sale" && ($status == "settled" || $status == "settling")) { 
        
           if ($amount <= $btAmount && $amount > 0) {
                $result = Braintree_Transaction::refund($btTransID, $amount);
                $amount = 0;
                $isOK = 1;
                break;
           }
           else {                       
                $result = Braintree_Transaction::refund($btTransID);
                $amount = $amount - $btAmount;
           } 
                       
    }        
    else if ($type == "sale" && ($status == "authorized" || $status == "submitted_for_settlement")) { 
       
        if ($amount >= $btAmount && $amount > 0) {
            $result = Braintree_Transaction::void($btTransID); 
            $amount = $amount - $btAmount;
            $isOK = 1;                    
        }
           
          
    }
    
    
}


$amountStr = "0" . $amount;

if ($isOK == 0) {
      
    $json =  array("success" => "1", "btTransaction" => $amountStr, "error" => ""); 
    
}
else if ($result->success) {
    
   $json =  array("success" => "1", "btTransaction" => $amountStr, "error" => "");                  
    
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

 
echo json_encode($json);
  

?>