<?php
	
include 'connect.php';
include 'header.php';


if($_SESSION['signed_in'] == false | $_SESSION['user_level'] != 2 )
{
	//the user is not an admin
	echo 'Sorry, you do not have sufficient rights to access this page.';
}
else {
        
    $sql = "SELECT c.op_id, c.op_date, c.op_amount, u.user_braintreeID, u.user_email, u.user_nom, u.user_prenom  
            FROM OperationCredit as c, User as u
            WHERE c.user_id = u.user_id";  
        
    $result = mysqli_query($con, $sql);

    $isOK = 0;

     //prepare the table
    echo '<table border="1">
              <tr>
                    <th>Carte de credit</th>
                    <th>Terminer</th>
              </tr>';	
     
    while($row = $result->fetch_object())
    {     
        $isOK = 1;                
        echo '<tr>';
                echo '<td class="leftpart">';
                         echo '<h3><a> Compte Braintree : ' . $row->user_braintreeID . ' - Utilisateur : ' . $row->user_nom .
                          ' ' . $row->user_prenom . ' - ' . $row->user_email . ' - Montant : ' . $row->op_amount . '€ le ' . date('d-m-Y', strtotime($row->op_date)) . '</a></h3>';
                echo '</td>'; 
                echo '<td class="rightpart">';
                        echo '<a href="deleteWithdrawals.php?id=' . $row->op_id . '">ok</a>';
                echo '</td>';              
        echo '</tr>'; 
    }

    if($isOK == 0)
    {
        echo 'No withdrawal defined yet.';
    }

}

        
        
include 'footer.php';
mysqli_close($con);
?>
