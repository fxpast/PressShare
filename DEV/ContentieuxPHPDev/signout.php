<?php
//signout.php
include 'connect.php';
include 'header.php';
echo '<h2>Sign out</h2>';
//check if user if signed in
if($_SESSION['signed_in'] == true)
{
	//unset all variables
	$_SESSION['signed_in'] = NULL;
	$_SESSION['user_pseudo'] = NULL;
	$_SESSION['user_id']   = NULL;
	echo 'Succesfully signed out.';
}
else
{
	echo 'You are not signed in. Would you <a href="signin.php">like to</a>?';
}
include 'footer.php';
?>