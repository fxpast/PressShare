<?php
//create_cat.php
include 'connect.php';
include 'header.php';

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
                   
            $sql = "SELECT * FROM Contentieux";

            $result = mysqli_query($con, $sql);

            if(!$result)
            {
                echo 'The Contentieux could not be displayed, please try again later.';
            }
            else
            {
               
                $isOK = 0;
                
                 //prepare the table
                echo '<table border="1">
                          <tr>
                                <th>Category</th>
                          </tr>';	
                 
                while($row = $result->fetch_object())
                {     
                    $isOK = 1;                
                    echo '<tr>';
                            echo '<td class="leftpart">';
                                    echo '<h3><a href="' . $row->cont_path . '">' . $row->cont_name . '</a></h3>' . $row->cont_description;
                            echo '</td>';                               
                    echo '</tr>'; 
                }
                
                if($isOK == 0)
                {
                    echo 'No Contentieux defined yet.';
                }

            }
             
        }
        
}

include 'footer.php';
mysqli_close($con);
?>