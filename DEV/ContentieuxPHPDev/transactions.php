<?php
	
include 'connect.php';
include 'header.php';


if($_SESSION['signed_in'] == false | $_SESSION['user_level'] != 2 )
{
	//the user is not an admin
	echo 'Sorry, you do not have sufficient rights to access this page.';
}
else {
    
    $sql = "SELECT * FROM Transaction WHERE trans_arbitrage = 1 order by trans_date ASC";

    $result = mysqli_query($con, $sql);


    $isOK = 0;

     //prepare the table
    echo '<table border="1">
              <tr>
                    <th>Transactions</th>
                    <th>Date</th>
              </tr>';	
     
    while($row = $result->fetch_object())
    {     
        $isOK = 1;                
        echo '<tr>';
                echo '<td class="leftpart">';
                         echo '<h3><a href="detailTransactions.php?id=' . $row->trans_id . '">' . $row->trans_wording . '</a></h3>' . $row->trans_avis;
                echo '</td>';  
                echo '<td class="rightpart">';
                        echo date('d-m-Y', strtotime($row->trans_date));
                echo '</td>';             
        echo '</tr>'; 
    }

    if($isOK == 0)
    {
        echo 'No transaction defined yet.';
    }
          
          
}
  
        
include 'footer.php';
mysqli_close($con);
?>