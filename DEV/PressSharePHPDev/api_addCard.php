<?php
 

session_start();
include 'api_connect.php';
include 'bt_connect.php';

if ($_POST['main_card'] == "false") {
 
    $main_card = 0;
    $parDefaut = false;
}
else {
    $main_card = 1;
    $parDefaut = true;
}  
  

$sql = "SELECT *
    FROM
            User
    WHERE
            user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";
 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{	
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {          	    
        $braintreeID = $row->user_braintreeID;   
    } 
               
}

$nonceFromTheClient = $_POST['tokenizedCard'];

if ($braintreeID == "") {
    
    $result = Braintree_Customer::create([
        'paymentMethodNonce' => $nonceFromTheClient
    ]);
    
    if ($result->success) {
            
        $braintreeID = $result->customer->id;
        $nonceFromTheClient = $result->customer->paymentMethods[0]->token;
        
        $sql = "UPDATE User SET user_braintreeID = '" . mysqli_real_escape_string($con, $braintreeID) . "'	         
                    WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id']) . "'";

        $result = mysqli_query($con, $sql);        
    }
            
}
else {
  
    $result = Braintree_PaymentMethod::create([
    'customerId' => $braintreeID,
    'paymentMethodNonce' => $nonceFromTheClient,
    'options' => [
          'makeDefault' => $parDefaut 
        ]
    ]);
    
    $nonceFromTheClient = $result->paymentMethod->token;
          
}
     

if($nonceFromTheClient != "")
{
   
                                                                                                                                                                                 
    $sql = "INSERT INTO Card(typeCard_id, user_id, tokenizedCard, card_lastNumber, main_card)
            VALUES('" . mysqli_real_escape_string($con, $_POST['typeCard_id']) . "',
                       '" . mysqli_real_escape_string($con, $_POST['user_id']) . "',		  
                       '" . mysqli_real_escape_string($con, $nonceFromTheClient) . "',
                       '" . mysqli_real_escape_string($con, $_POST['card_lastNumber']) . "',
                        '" . mysqli_real_escape_string($con, $main_card) . "'
                       )";

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


}
else {

        if ($_POST['lang'] == "us") 
        {
            $json =  array("success" => "0", "error" => "payment Method token failure"); 
        }
        else if ($_POST['lang'] == "fr") 
        {
            $json =  array("success" => "0", "error" => "echec paiement methode token"); 
        } 
          
}    
                                                                       
                                                                                                         


echo json_encode($json);
 
// Close connections
mysqli_close($con);

?>