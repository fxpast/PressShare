<?php
//create_cat.php
include 'connect.php';
include 'header.php';
echo '<h2>Arbitrage transaction</h2>';

if($_SESSION['signed_in'] == false | $_SESSION['user_level'] != 2 )
{
	//the user is not an admin
	echo 'Sorry, you do not have sufficient rights to access this page.';
}
else
{
    
    $sql1 = "SELECT t.trans_id, t.prod_id, t.trans_wording, t.trans_avis, u.user_email, u.user_nom, u.user_prenom, t.proprietaire, t.client_id, t.vendeur_id  
            FROM Transaction as t, User as u
            WHERE t.proprietaire = u.user_id and trans_arbitrage = 1 and t.trans_id = '" . mysqli_real_escape_string($con, $_GET['id']) . "'";  
        
    $result1 = mysqli_query($con, $sql1);
    if(!$result1)
    {
            echo 'The transaction could not be displayed, please try again later.';
    }
    else
    {
       $isOK = 0;     
        while($row1 = $result1->fetch_object())
        {
            $isOK = 1;
            //the user has admin rights
            if($_SERVER['REQUEST_METHOD'] != 'POST')
            {
                    //the form hasn't been posted yet, display it
                    
                    echo '<tr class="topic-post">                                        
                                        <td class="post-content">Produit : ' . $row1->trans_wording . '<br/> Cause annulation : ' . $row1->trans_avis . '</td>                                                                               
                                  </tr>';
                    
                    echo '<br /><br /><br /><br />';
                    
                    echo '<tr class="topic-post">                                        
                                            <td class="post-content">Transaction annuler par le client : ' . $row1->user_nom . ' ' . $row1->user_prenom . ' - ' . $row1->user_email . '</td>                                                                               
                                      </tr>';
                                      
                    echo '<br /><br />';
                                                 
                    echo '<tr class="topic-post">                                       
                                        <td class="post-content">' . htmlentities(stripslashes('Le client à tort : sa transaction sera validé, une commission fixe sera appliquée et le produit échangé sera terminé.')) . '</td>
                                  </tr>';
                    
                    echo '<br /><br />'; 
                                   
                    //user_id2 : client qui a annulé   
                    //user_id1 : client qui a confirmé                               
                    if ($row1->proprietaire == $row1->client_id) {
                          
                        echo '<form method="post" action=""> 
                                <input type="hidden" name="trans_id" value="' . $row1->trans_id . '"/>
                                <input type="hidden" name="prod_id" value="' . $row1->prod_id . '"/>  
                                <input type="hidden" name="user_id2" value="' . $row1->client_id . '"/>
                                <input type="hidden" name="user_id1" value="' . $row1->vendeur_id . '"/>
                                Confirmer: <input type="checkbox" name="scenario1" value=""/><br />                        		
                                <input type="submit" value="Valider" />
                        </form>';
                    
                                          
                        $sql2 = "SELECT t.trans_id, t.prod_id, t.trans_wording, t.trans_avis, u.user_email, u.user_nom, u.user_prenom, t.proprietaire, t.client_id, t.vendeur_id  
                        FROM Transaction as t, User as u
                        WHERE t.vendeur_id = u.user_id and trans_arbitrage = 1 and t.trans_id = '" . mysqli_real_escape_string($con, $_GET['id']) . "'";  
                
                    }
                    else if ($row1->proprietaire == $row1->vendeur_id) {
                            
                        echo '<form method="post" action=""> 
                                <input type="hidden" name="trans_id" value="' . $row1->trans_id . '"/>
                                <input type="hidden" name="prod_id" value="' . $row1->prod_id . '"/> 
                                <input type="hidden" name="user_id2" value="' . $row1->vendeur_id . '"/>
                                <input type="hidden" name="user_id1" value="' . $row1->client_id . '"/>
                                Confirmer: <input type="checkbox" name="scenario1" value=""/><br />                        		
                                <input type="submit" value="Valider" />
                        </form>';
                                        
                        $sql2 = "SELECT t.trans_id, t.prod_id, t.trans_wording, t.trans_avis, u.user_id, u.user_email, u.user_nom, u.user_prenom, t.proprietaire, t.client_id, t.vendeur_id  
                        FROM Transaction as t, User as u
                        WHERE t.client_id = u.user_id and trans_arbitrage = 1 and t.trans_id = '" . mysqli_real_escape_string($con, $_GET['id']) . "'";  
                    
                    }
                    
                     echo '<br /><br /><br />'; 
                      
                    $result2 = mysqli_query($con, $sql2);
    
                    while($row2 = $result2->fetch_object())
                        {
                          
                            echo '<tr class="topic-post">                                        
                                                <td class="post-content">Transaction acceptée par le client : ' . $row2->user_nom . ' ' . $row2->user_prenom . ' - ' . $row2->user_email . '</td>                                                                               
                                          </tr>';
                            echo '<br /><br />';              
                            echo '<tr class="topic-post">                                        
                                                <td class="post-content">' . htmlentities(stripslashes('Le client à tort : sa transaction sera annulé, la commission fixe sera remboursée et le produit échangé sera remis en vente.')) . '</td>
                                          </tr>';
                            
                            echo '<br /><br />';                                  
                            
                                    
                            //user_id2 : client qui a annulé   
                            //user_id1 : client qui a confirmé                                       
                            if ($row1->proprietaire == $row1->client_id) {
                                    
                                echo '<form method="post" action=""> 
                                        <input type="hidden" name="trans_id" value="' . $row1->trans_id . '"/>  
                                        <input type="hidden" name="prod_id" value="' . $row1->prod_id . '"/> 
                                        <input type="hidden" name="user_id2" value="' . $row1->client_id . '"/>
                                        <input type="hidden" name="user_id1" value="' . $row1->vendeur_id . '"/>
                                        Confirmer: <input type="checkbox" name="scenario2" value=""/><br />                        		
                                        <input type="submit" value="Valider" />
                                </form>';                            
                            }
                            else if ($row1->proprietaire == $row1->vendeur_id) {
                                    
                                echo '<form method="post" action=""> 
                                        <input type="hidden" name="trans_id" value="' . $row1->trans_id . '"/> 
                                        <input type="hidden" name="prod_id" value="' . $row1->prod_id . '"/> 
                                        <input type="hidden" name="user_id2" value="' . $row1->vendeur_id . '"/>
                                        <input type="hidden" name="user_id1" value="' . $row1->client_id . '"/>
                                        Confirmer: <input type="checkbox" name="scenario2" value=""/><br />                        		
                                        <input type="submit" value="Valider" />
                                </form>';                             
                            }
                            
                                     
                        }
                                
                     
            }
            else
            {
                
             
                if(isset($_POST['scenario1']))
                {
                    
                    //Commission fixe extrait de la table des paramètres          
                    $amount = 0;                      
                    $sql = "SELECT * FROM ParamTable";                        
                    
                    $result = mysqli_query($con, $sql);
                    
                    while($row = $result->fetch_object())
                    {
                        $amount = $row->commisFixEx;
                    }
                    
                    //ligne commission ajouté au profit de PressShare
                    $sql = "INSERT INTO Commission(user_id, product_id, com_date, com_amount)
                            VALUES('" . mysqli_real_escape_string($con, $_POST['user_id2']) . "',		  
                               '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "',
                                    NOW(),			
                               '" . mysqli_real_escape_string($con, $amount) . "')";
                    
                    $result = mysqli_query($con, $sql);
                    
                    //ligne opération ajouté au debit du client
                    $amount = -1 * $amount;
                    $wording = "Commission";
                    $type = 5;

                    $sql = "INSERT INTO
                                    Operation(user_id, op_date, op_type, op_amount, op_wording)
                            VALUES('" . mysqli_real_escape_string($con, $_POST['user_id2']) . "',		  
                                       NOW(),
                                        '" . mysqli_real_escape_string($con, $type) . "',
                                        '" . mysqli_real_escape_string($con, $amount) . "',
                                        '" . mysqli_real_escape_string($con, $wording) . "')";
   
                    $result = mysqli_query($con, $sql);
                    
                    //Debiter le capital du client
                    $sql = "SELECT * FROM Capital WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id2']) . "'";
                    $result = mysqli_query($con, $sql);
   
                    $capital = 0;
                    while($row = $result->fetch_object())
                    {
                        $capital = $row->balance;
                    }
                 
                    $capital = $capital + $amount;
                    $sql = "UPDATE Capital 
                            SET
                             date_maj = NOW(), 
                             balance = '" . mysqli_real_escape_string($con, $capital) . "' 
                             WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id2']) . "'";


                    $result = mysqli_query($con, $sql);
                    
                    
                    //Confirmer la transaction automatiquement
                    
                    $sql = "UPDATE Transaction			
                                    SET trans_valid = 2,            
                                    trans_avis = 'automatic arbitration',
                                    trans_arbitrage = 0
                            WHERE
                            trans_id = '" . mysqli_real_escape_string($con, $_POST['trans_id']) . "'";

                    $result = mysqli_query($con, $sql);

                    //Terminer le produit automatiquement
                    
                    $sql = "UPDATE Product			
                            SET prod_hidden = 1,
                            prod_closed = 1,
                            prod_oth_user = '" . mysqli_real_escape_string($con, $_POST['user_id1']) . "'
                            WHERE
                            prod_id = '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "'";


                    $result = mysqli_query($con, $sql);
                    
                    echo 'Transaction validée, commission débitée et produit terminé.';
                }
                else if(isset($_POST['scenario2']))
                {
                    
                    //Commission fixe extrait de la table des paramètres          
                    $amount = 0;                      
                    $sql = "SELECT * FROM ParamTable";                        
                    
                    $result = mysqli_query($con, $sql);
                    
                    while($row = $result->fetch_object())
                    {
                        $amount = $row->commisFixEx;
                    }
 

                    //ligne commission ajouté au debit de PressShare
                    $amount = -1 * $amount;
                    $sql = "INSERT INTO Commission(user_id, product_id, com_date, com_amount)
                            VALUES('" . mysqli_real_escape_string($con, $_POST['user_id1']) . "',		  
                               '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "',
                                    NOW(),			
                               '" . mysqli_real_escape_string($con, $amount) . "')";
                    
                    $result = mysqli_query($con, $sql);
                    
                   //ligne opération ajouté au credit du client
                    $amount = -1 * $amount;
                    $wording = "Commission";
                    $type = 5;

                    $sql = "INSERT INTO
                                    Operation(user_id, op_date, op_type, op_amount, op_wording)
                            VALUES('" . mysqli_real_escape_string($con, $_POST['user_id1']) . "',		  
                                       NOW(),
                                        '" . mysqli_real_escape_string($con, $type) . "',
                                        '" . mysqli_real_escape_string($con, $amount) . "',
                                        '" . mysqli_real_escape_string($con, $wording) . "')";
   
                    $result = mysqli_query($con, $sql);
                    
                   //Crediter le capital du client
                    $sql = "SELECT * FROM Capital WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id1']) . "'";
                    $result = mysqli_query($con, $sql);
   
                    $capital = 0;
                    while($row = $result->fetch_object())
                    {
                        $capital = $row->balance;
                    }
                 
                    $capital = $capital + $amount;
                    $sql = "UPDATE Capital 
                            SET
                             date_maj = NOW(), 
                             balance = '" . mysqli_real_escape_string($con, $capital) . "' 
                             WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['user_id1']) . "'";


                    $result = mysqli_query($con, $sql);
                     
                    //recherche les transactions d'échange du produit 
                    $sql = "SELECT * FROM Transaction WHERE prod_id = '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "' ORDER BY trans_date DESC LIMIT 2";
                  
                    $result = mysqli_query($con, $sql);
                  
                    while($row = $result->fetch_object())
                     {
                        //annuler automatiquement les transactions des client1 et client 2 sans arbitrage 
                        
                        $sql = "UPDATE Transaction			
                                        SET trans_valid = 1,            
                                        trans_avis = 'automatic canceled',
                                        trans_arbitrage = 0
                                WHERE
                                trans_id = '" . mysqli_real_escape_string($con, $row->trans_id) . "'";

                        $result1 = mysqli_query($con, $sql);

                     }
                 
                      
                    //Remise en vente automatique du produit
                    
                    $sql = "UPDATE Product			
                            SET prod_hidden = 0,
                            prod_closed = 0,
                            prod_oth_user = 0
                            WHERE
                            prod_id = '" . mysqli_real_escape_string($con, $_POST['prod_id']) . "'";


                    $result = mysqli_query($con, $sql);
 
                    echo 'Transaction annulée, commission créditée et produit terminé.';
                     
                }
                else {
                  echo 'Merci de confirmer avant de valider.';
                }
                

            }
        
        }
    
        
        if ($isOK == 0)
        {
            echo 'The transaction is already done.';
        }
    }


}
include 'footer.php';
mysqli_close($con);
?>
