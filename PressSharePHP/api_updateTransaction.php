<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
// This SQL statement selects ALL from the table 'Locations'

    
if ($_POST['trans_arbitrage'] == FALSE) {
 
    $trans_arbitrage = 0;
}
else {
    $trans_arbitrage = 1;
}  


$sql = "UPDATE Transaction			
        SET trans_valide = '" . mysqli_real_escape_string($con, $_POST['trans_valide']) . "',
            trans_arbitrage = '" . mysqli_real_escape_string($con, $trans_arbitrage ) . "',
            trans_avis = '" . mysqli_real_escape_string($con, $_POST['trans_avis']) . "'
        WHERE
        trans_id = '" . mysqli_real_escape_string($con, $_POST['trans_id']) . "'";

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

