<?php
//category.php
include 'connect.php';
include 'header.php';
//first select the category based on $_GET['cat_id']
$sql = "SELECT
            cat_id,
            cat_name,
            cat_description
        FROM
                categories
        WHERE
                cat_id = " . mysqli_real_escape_string($con, $_GET['id']);
                        

$result = mysqli_query($con, $sql);

if(!$result)
{
    echo 'The category could not be displayed, please try again later.' . mysql_error();
}
else
{
        $isOK = 0;
        while($row = $result->fetch_object())
        {
            $isOK = 1;

            //display category data
            while($row = $result->fetch_object())
            {
                echo '<h2>Topics in &prime;' . $row->cat_name . '&prime; category</h2><br />';
            }
    
            //do a query for the topics
            $sql = "SELECT	
                        topic_id,
                        topic_subject,
                        topic_date,
                        topic_cat
                    FROM
                            topics
                    WHERE
                            topic_cat = " . mysqli_real_escape_string($con, $_GET['id']);
            
            
            $result = mysqli_query($con, $sql);

            if(!$result)
            {
                echo 'The topics could not be displayed, please try again later.';
            }
            else
            {
                    $isOK = 0;
                    while($row = $result->fetch_object())
                    {
                        $isOK = 1;
                        
                        //prepare the table
                        echo '<table border="1">
                                  <tr>
                                        <th>Topic</th>
                                        <th>Created at</th>
                                  </tr>';	
                                
                        while($row = $result->fetch_object())
                        {				
                            echo '<tr>';
                                    echo '<td class="leftpart">';
                                            echo '<h3><a href="topic.php?id=' . $row->topic_id . '">' . $row->topic_subject . '</a><br /><h3>';
                                    echo '</td>';
                                    echo '<td class="rightpart">';
                                            echo date('d-m-Y', strtotime($row->topic_date));
                                    echo '</td>';
                            echo '</tr>';
                        }
                    
                    }

                    if($isOK == 0)
                    {
                        echo 'There are no topics in this category yet.';
                        $isOK = 1;
                    }
            
            }
    

           

        }

        if($isOK == 0)
	{
            echo 'This category does not exist.';
	}

        }
include 'footer.php';
?>