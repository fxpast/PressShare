<?php
//category.php
include 'connect.php';
include 'header.php';
//first select the category based on $_GET['cont_id']


if($_SESSION['signed_in'] == false | $_SESSION['user_level'] != 2 )
{
	//the user is not an admin
	echo 'Sorry, you do not have sufficient rights to access this page.';
}
else {
        
    $sql = "DELETE FROM Feedback WHERE feedback_id = '" . mysqli_real_escape_string($con, $_GET['id']) . "'";                 

    $result = mysqli_query($con, $sql);

    if(!$result)
    {
        echo 'The feedback could not be deleted, please try again later.' . mysql_error();
    }
    else
    {
        
        echo 'The feedback has been succesfully deleted';

    }

}


include 'footer.php';
?>