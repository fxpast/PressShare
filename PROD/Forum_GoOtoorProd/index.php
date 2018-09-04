<?php
//create_cat.php
include 'connect.php';
include 'header.php';
$sql = "SELECT
            categories.cat_id,
            categories.cat_name,
            categories.cat_description,
            COUNT(topics.topic_id) AS topics
    FROM
            categories
    LEFT JOIN
            topics
    ON
            topics.topic_cat = categories.cat_id
    GROUP BY
            categories.cat_name, categories.cat_description, categories.cat_id";

$result = mysqli_query($con, $sql);

if(!$result)
{
	echo 'The categories could not be displayed, please try again later.';
}
else
{
   
    $isOK = 0;
    
     //prepare the table
    echo '<table border="1">
              <tr>
                    <th>Category</th>
                    <th>Last topic</th>
              </tr>';	
     
    while($row = $result->fetch_object())
    {
     
        $isOK = 1;
                
        echo '<tr>';
                echo '<td class="leftpart">';
                        echo '<h3><a href="category.php?id=' . $row->cat_id . '">' . $row->cat_name . '</a></h3>' . $row->cat_description;
                echo '</td>';
                echo '<td class="rightpart">';
                
                //fetch last topic for each cat
                        $topicSql = "SELECT *
                                    FROM
                                            topics
                                    WHERE
                                            topic_cat = " . $row->cat_id . "
                                    ORDER BY
                                            topic_date
                                    DESC
                                    LIMIT 1";
                                    
                        
                        $topicsResult = mysqli_query($con, $topicSql);
                
                        if(!$topicsResult)
                        {
                            echo 'Last topic could not be displayed.';
                        }
                        else
                        {                            
                            $isOK = 0;
                            while($row = $topicsResult->fetch_object())
                            {

                                $isOK = 1;                                                                    
                                echo '<a href="topic.php?id=' . $row->topic_id . '">' . $row->topic_subject . '</a> at ' . date('d-m-Y', strtotime($row->topic_date));
                                
                            }

                            if($isOK == 0)
                            {                                        
                                echo 'no topics';
                                $isOK = 1; 
                            }
                              
                        }
                echo '</td>';
        echo '</tr>'; 
    }
    
    

    if($isOK == 0)
    {
        echo 'No categories defined yet.';
    }

}
include 'footer.php';
mysqli_close($con);
?>