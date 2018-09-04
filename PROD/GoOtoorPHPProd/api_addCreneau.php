<?php
 

session_start();
include 'api_connect.php';


// INSERT INTO `Creneau`(`prod_id`, `cre_dateDebut`, `cre_dateFin`,
// `cre_mapString`, `cre_latitude`, `cre_longitude`) 
// VALUES ('180','2018-04-26 10:26:50','2018-04-27 09:26:50','Le Mans','48.0075078','0.1981367')


$sql = "INSERT INTO Creneau(prod_id, cre_dateDebut, cre_dateFin, cre_repeat,
	cre_mapString, cre_latitude, cre_longitude) VALUES ('" .
	 mysqli_real_escape_string($con, $_POST['prod_id']) . "', '" .
	 mysqli_real_escape_string($con, $_POST['cre_dateDebut']) . "', '" .
	 mysqli_real_escape_string($con, $_POST['cre_dateFin']) . "', '" .
	 mysqli_real_escape_string($con, $_POST['cre_repeat']) . "', '" .
	 mysqli_real_escape_string($con, $_POST['cre_mapString']) . "',	'" .
	 mysqli_real_escape_string($con, $_POST['cre_latitude']) .	"', '" .
	 mysqli_real_escape_string($con, $_POST['cre_longitude']) . "')";
    
   
                                             

if ($_POST['cre_mapString'] == "") {
    $sql = "";
}		

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