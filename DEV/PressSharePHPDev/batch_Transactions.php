<?php


session_start();
include 'connect.php';


//RESULT FORMAT:
// '%y Year %m Month %d Day %h Hours %i Minute %s Seconds'        =>  1 Year 3 Month 14 Day 11 Hours 49 Minute 36 Seconds
// '%y Year %m Month %d Day'                                    =>  1 Year 3 Month 14 Days
// '%m Month %d Day'                                            =>  3 Month 14 Day
// '%d Day %h Hours'                                            =>  14 Day 11 Hours
// '%d Day'                                                        =>  14 Days
// '%h Hours %i Minute %s Seconds'                                =>  11 Hours 49 Minute 36 Seconds
// '%i Minute %s Seconds'                                        =>  49 Minute 36 Seconds
// '%h Hours                                                    =>  11 Hours
// '%a Days                                                        =>  468 Days
function dateDifference($date_1 , $date_2 , $differenceFormat = '%a' )
{
    $datetime1 = date_create($date_1);
    $datetime2 = date_create($date_2);
    
    $interval = date_diff($datetime1, $datetime2);
    
    $value =  $interval->format($differenceFormat);
    return abs($value);
}



$maxDay = 0;      //max count of day     
$comAmount = 0.00; //amount commission
                         
$sql = "SELECT * FROM ParamTable";
 
if ($result = mysqli_query($con, $sql))
{
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {  
        $maxDay = $row->maxDayTrigger; 
        $comAmount = $row->commissionPrice; 
    }
} 



//---------------------------------------------------------------------------------------
//One has confirmed while the other has canceled it then trans_arbitrage must be enabled
//---------------------------------------------------------------------------------------

$flgOK = 0;	                         
//1 : the transaction is canceled.
$sql = "SELECT * FROM Transaction  WHERE trans_valid = 1 and trans_arbitrage = 0";
 
if ($result = mysqli_query($con, $sql))
{
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {                 
        $dateTrans = $row->trans_date;              
        $user_id = $row->proprietaire;
        $transId = $row->trans_id;
        $prodId = $row->prod_id;
        $clientId = $row->client_id;
        $vendeurId = $row->vendeur_id;  
        
        $today=date('d-m-Y');
        //$dateTrans= date('d-m-Y', strtotime($today. ' + ' . $maxDay .' days'));
        $dayDiff = dateDifference($today, $dateTrans);

        if ($dayDiff >= $maxDay) {
        
            //2 : the transaction has been confirmed.
            $sql = "SELECT * FROM Transaction  WHERE trans_valid = 2 and prod_id = '" . mysqli_real_escape_string($con, $prodId) . "' 
                    and client_id = '" . mysqli_real_escape_string($con, $clientId) . "' 
                    and vendeur_id = '" . mysqli_real_escape_string($con, $vendeurId) . "'";  
                    
             
            if ($result1 = mysqli_query($con, $sql))
            {
                // Loop through each row in the result set             
                while($row = $result1->fetch_object())
                {  
                    
                    // Arbitration transaction is anabled
                    $sql = "UPDATE Transaction SET trans_arbitrage = 1 WHERE trans_id = '" . mysqli_real_escape_string($con, $transId) . "'";

                    if ($result2 = mysqli_query($con, $sql))
                    {		
                        $flgOK = 1;		    
                    } 
                    
                    break;
                       
                       
                }
            }
            
        }
                                               
    }
        
}

 


//0 : the transaction is running.
$sql = "SELECT * FROM Transaction  WHERE trans_valid = 0";
 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {
        // Add each row into our results array
        $dateTrans = $row->trans_date;
        $user_id = $row->proprietaire;
        $transId = $row->trans_id;
        $prodId = $row->prod_id;
        $clientId = $row->client_id;
        $vendeurId = $row->vendeur_id;
        $transAmount = $row->trans_amount;
        $totalCom  = $transAmount * $comAmount;
        
        
        $today=date('d-m-Y');
        //$dateTrans= date('d-m-Y', strtotime($today. ' + ' . $maxDay .' days'));
        $dayDiff = dateDifference($today, $dateTrans);

        if ($dayDiff >= $maxDay) {
        
                //----------------------------------------------------------------------------------------------------------------
                //A commission of 5% is debited for the one who has not decided on his transaction while the other confirmed it.
                // After that his transaction is confirmed. The client's capital is decreased of commission
                //----------------------------------------------------------------------------------------------------------------

                //2 : the transaction has been confirmed.
                $sql = "SELECT * FROM Transaction  WHERE trans_valid = 2 and prod_id = '" . mysqli_real_escape_string($con, $prodId) . "' 
                and client_id = '" . mysqli_real_escape_string($con, $clientId) . "' 
                and vendeur_id = '" . mysqli_real_escape_string($con, $vendeurId) . "'";
                
                $flgOK = 0; 
                if ($result1 = mysqli_query($con, $sql))
                {
                    // Loop through each row in the result set             
                    while($row = $result1->fetch_object())
                    {    
                        //A commission of 5% is debited                              
                        $sql = "INSERT INTO
                                        Commission(user_id, product_id, com_date, com_amount)
                                VALUES('" . mysqli_real_escape_string($con, $user_id) . "',		  
                                           '" . mysqli_real_escape_string($con, $prodId) . "',
                                                NOW(),			
                                           '" . mysqli_real_escape_string($con, $totalCom) . "')";
                                        
                        if ($result2 = mysqli_query($con, $sql))
                        {                           
                            $flgOK = 1;	                                
                        }
                        
                        
                        $totalCom = -1 * $totalCom;
                        
                        //A commission of 5% is debited in operation client
                        $sql = "INSERT INTO
                                        Operation(user_id, op_date, op_type, op_amount, op_wording)
                                VALUES('" . mysqli_real_escape_string($con, $user_id) . "',		  
                                           NOW(),
                                            5,
                                            '" . mysqli_real_escape_string($con, $totalCom) . "',
                                            'Commission')";
                                        
                        if ($result2 = mysqli_query($con, $sql))
                        {                           
                            $flgOK = 1;	                                
                        }
                        
                        
                        //The client's capital is decreased of commission
                        $sql = "SELECT * FROM Capital WHERE user_id = '" . mysqli_real_escape_string($con, $user_id) . "'";
                        if ($result2 = mysqli_query($con, $sql))
                        {
                            // Loop through each row in the result set             
                            while($row = $result2->fetch_object())
                            {   
                                $balance = $row->balance; 
                                $balance = $balance + $totalCom;                               
                                $sql = "UPDATE Capital SET
                                     date_maj = NOW(), 
                                     balance = '" . mysqli_real_escape_string($con, $balance) . "' 
                                     WHERE user_id = '" . mysqli_real_escape_string($con, $user_id) . "'";
                                $result3 = mysqli_query($con, $sql);
                                     	
                            }

                        }
                            
                        
                        //2 : the transaction has been confirmed.
                        $sql = "UPDATE Transaction SET trans_valid = 2 WHERE trans_id = '" . mysqli_real_escape_string($con, $transId) . "'";
                        
                        if ($result4 = mysqli_query($con, $sql))
                        {		
                            $flgOK = 1;		    
                        } 
                                                                                            
                        break;                                               
                    }
                   
                        
                }
                                
               
                //------------------------------------------------------------------------------------------------------------------------------------------------------
                //The reject counter is incremented for one who has not decided on his transaction for a purchase and for an exchange while the other has canceled it.
                // After that his transaction is canceled for both purchase and exchange.
                //------------------------------------------------------------------------------------------------------------------------------------------------------

                if ($flgOK == 0) {
                    
                    $flgOK = 1;	                         
                    $sql = "SELECT * FROM Capital  WHERE user_id = '" . mysqli_real_escape_string($con, $user_id) . "'";
                     
                    if ($result1 = mysqli_query($con, $sql))
                    {
                        // Loop through each row in the result set
                        $failureCount = 0;
                        while($row = $result1->fetch_object())
                        {                       
                            $failureCount = $row->failure_count; 
                            $failureCount = $failureCount + 1;
                            
                            $sql = "UPDATE Capital SET failure_count = '" . mysqli_real_escape_string($con, $failureCount) . "' WHERE
                                user_id = '" . mysqli_real_escape_string($con, $user_id) . "'";
                                                            
                            if ($result2 = mysqli_query($con, $sql))
                            {		
                                $flgOK = 1;		    
                            }          
                                                                           
                        }
                            
                    }
                    
                    //1 : the transaction has been canceled and Arbitration transaction disabled
                    $sql = "UPDATE Transaction SET trans_valid = 1, trans_avis = 'automatic canceled' WHERE trans_id = '" . mysqli_real_escape_string($con, $transId) . "'";
                    
                    if ($result1 = mysqli_query($con, $sql))
                    {		
                        $flgOK = 1;		    
                    } 
                        
                }
                
        }
       
    }
        
}



//-------------------------------------------------------------------------------------------------------------------------
//If transaction is canceled the product becomes visible. If transaction is running or confirmed the product remains hidden 
//-------------------------------------------------------------------------------------------------------------------------

$sql = "SELECT * FROM Product  WHERE prod_hidden = 1";
 
if ($result = mysqli_query($con, $sql))
{
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {   
        $prodId = $row->prod_id;
        //0 : transaction is running or 2 : transaction is confirmed
        $sql = "SELECT * FROM Transaction  WHERE prod_id = '" . mysqli_real_escape_string($con, $prodId) . "' and (trans_valid = 0 or trans_valid = 2)";
        if ($result1 = mysqli_query($con, $sql))
        {
            $flgOK = 0;
            // Loop through each row in the result set
            while($row = $result1->fetch_object())
            {   
                $flgOK = 1;
                break;
            }
            
            if ($flgOK == 0) {
                $sql = "UPDATE Product SET prod_hidden = 0 , prod_oth_user = 0 WHERE prod_id = '" . mysqli_real_escape_string($con, $prodId) . "'";
                $result2 = mysqli_query($con, $sql);
            }
        } 
    }
}




// Close connections
mysqli_close($con);
?>