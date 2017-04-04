<?php
//create_cat.php
include 'connect.php';
include 'header.php';
echo '<h2>Create a category</h2>';

if($_SESSION['signed_in'] == false)
{
    echo 'Connexion is necessary to access this page.';            
}
else {
 
    if($_SESSION['user_level'] != 2 )
        {
            //the user is not an admin
            echo 'Sorry, you do not have sufficient rights to access this page.';
        }
        else {
                //the user has admin rights
            if($_SERVER['REQUEST_METHOD'] != 'POST')
            {
                    //the form hasn't been posted yet, display it
                    echo '<form method="post" action="">
                            Category name: <input type="text" name="cont_name" /><br />
                            Category description:<br /> <textarea name="cont_description" /></textarea><br /><br />
                            <input type="submit" value="Add category" />
                     </form>';
            }
            else
            {
                    //the form has been posted, so save it
                    $sql = "INSERT INTO Contentieux(cont_name, cont_description)
                       VALUES('" . mysqli_real_escape_string($con, $_POST['cont_name']) . "',
                                     '" . mysqli_real_escape_string($con, $_POST['cont_description']) . "')";
                                     
                    $result = mysqli_query($con, $sql);
                    
                    if(!$result)
                    {
                            //something went wrong, display the error
                            echo 'Error' . mysql_error();
                    }
                    else
                    {
                            echo 'New category succesfully added.';
                    }
            }
            
        }   
}


include 'footer.php';
?>