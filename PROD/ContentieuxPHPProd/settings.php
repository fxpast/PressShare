<?php
//create_cat.php
include 'connect.php';
include 'header.php';
echo '<h2>Paramètrage à modifier</h2>';

if($_SESSION['signed_in'] == false | $_SESSION['user_level'] != 2 )
{
	//the user is not an admin
	echo 'Sorry, you do not have sufficient rights to access this page.';
}
else
{
    
    $sql = "SELECT * FROM ParamTable";
        
    $result = mysqli_query($con, $sql);
    if(!$result)
    {
            echo 'The setting could not be displayed, please try again later.';
    }
    else
    {
            
        while($row = $result->fetch_object())
        {
                //the user has admin rights
            if($_SERVER['REQUEST_METHOD'] != 'POST')
            {
                    //the form hasn't been posted yet, display it
                    echo '<form method="post" action="">
                            Distance Product: <input type="text" name="distanceProduct" value="' . $row->distanceProduct . '"/><br />
                            Region géolocalisation: <input type="text" name="regionGeoLocat" value="' . $row->regionGeoLocat . '"/><br />
                            Region produit: <input type="text" name="regionProduct" value="' . $row->regionProduct . '"/><br />
                            Commission en %: <input type="text" name="commisPourcBuy" value="' . $row->commisPourcBuy . '"/><br />
                            Commission en fixe: <input type="text" name="commisFixEx" value="' . $row->commisFixEx . '"/><br />
                            Maximum de jour declenchement: <input type="text" name="maxDayTrigger" value="' . $row->maxDayTrigger . '"/><br />
                            Montant d\'abonnement: <input type="text" name="subscriptAmount" value="' . $row->subscriptAmount . '"/><br />                        
                            Montant minimum du solde: <input type="text" name="minimumAmount" value="' . $row->minimumAmount . '"/><br />
                            Couleur générale de l\'appli: <input type="text" name="colorApp" value="' . $row->colorApp . '"/> <a href="http://html-color-codes.info" title="HTML color codes" target="_blank">HTML color codes</a> <br />			
                            <input type="submit" value="Update setting" />
                     </form>';
            }
            else
            {
                    //the form has been posted, so save it
                    $sql = "UPDATE ParamTable SET distanceProduct = '" . mysqli_real_escape_string($con, $_POST['distanceProduct']) . "',
                            regionGeoLocat = '" . mysqli_real_escape_string($con, $_POST['regionGeoLocat']) . "',
                            regionProduct = '" . mysqli_real_escape_string($con, $_POST['regionProduct']) . "',
                            commisPourcBuy = '" . mysqli_real_escape_string($con, $_POST['commisPourcBuy']) . "',
                            commisFixEx = '" . mysqli_real_escape_string($con, $_POST['commisFixEx']) . "',
                            maxDayTrigger = '" . mysqli_real_escape_string($con, $_POST['maxDayTrigger']) . "',
                            subscriptAmount = '" . mysqli_real_escape_string($con, $_POST['subscriptAmount']) . "',   
                            minimumAmount = '" . mysqli_real_escape_string($con, $_POST['minimumAmount']) . "',                      
                            colorApp = '" . mysqli_real_escape_string($con, $_POST['colorApp']) . "' 
                            WHERE
                                param_id = 1";
                                     
                    $result = mysqli_query($con, $sql);
                    
                    if(!$result)
                    {
                            //something went wrong, display the error
                            echo 'Error' . mysql_error();
                    }
                    else
                    {
                            echo 'Setting succesfully updated.';
                    }
            }

            
        
        }
    
    }


}
include 'footer.php';
mysqli_close($con);
?>
