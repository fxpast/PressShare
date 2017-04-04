<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nl" lang="nl">
<head>
 	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
 	<meta name="description" content="A short description." />
 	<meta name="keywords" content="put, keywords, here" />
 	<title>PressShare</title>
	<link rel="stylesheet" href="style.css" type="text/css">
</head>
<body>
<h1>Gestion des contentieux PressShare</h1>
	<div id="wrapper">
	<div id="menu">
		<a class="item" href="index.php">Home</a> -		
		<a class="item" href="create_cat.php">Create a category</a>
		
		<div id="userbar">
		<?php
		if($_SESSION['signed_in'])
		{
			echo 'Hello <b>' . htmlentities($_SESSION['user_pseudo']) . '</b>. Not you? <a class="item" href="signout.php">Sign out</a>';
		}
		else
		{
			echo '<a class="item" href="signin.php">Sign in</a>';
		}
		?>
		</div>
	</div>
		<div id="content">