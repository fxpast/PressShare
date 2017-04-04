<?php
	
include 'connect.php';
include 'header.php';



if($_SESSION['signed_in'] == false | $_SESSION['user_level'] != 2 )
{
	//the user is not an admin
	echo 'Sorry, you do not have sufficient rights to access this page.';
}
else {
        
    $sql = "SELECT * FROM Feedback";

    $result = mysqli_query($con, $sql);


    $isOK = 0;

     //prepare the table
    echo '<table border="1">
              <tr>
                    <th>Feedback</th>
                    <th>Termimer</th>
              </tr>';	
     
    while($row = $result->fetch_object())
    {     
        $isOK = 1;                
        echo '<tr>';
                echo '<td class="leftpart">';
                         echo '<h3><a>' . $row->comment . '</a></h3>' . $row->origin;
                echo '</td>';  
                echo '<td class="rightpart">';
                         echo '<a href="deleteFeedback.php?id=' . $row->feedback_id . '">ok</a>';
                echo '</td>';             
        echo '</tr>'; 
    }

    if($isOK == 0)
    {
        echo 'No Feedback defined yet.';
    }
        
    
}
    
        
include 'footer.php';
mysqli_close($con);
?>



