<?php
 
// Create connection
$con=mysqli_connect("localhost","stoug_admin","6%u75Usd","stougma26066com26632_bdpress");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
// This SQL statement selects ALL from the table 'Locations'

if ($_POST['prod_hidden'] == FALSE) {
 
    $prod_hidden = 0;
}
else {
    $prod_hidden = 1;
}  

$sql = "UPDATE Product			
        SET prod_hidden = '" . mysqli_real_escape_string($con, $prod_hidden) . "',
        prod_oth_user = '" . mysqli_real_escape_string($con, $_POST['prod_oth_user']) . "'
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

