<?php
	$data = @file("http://weather.yahooapis.com/forecastrss?w=698064&u=c");
	$data = explode('=',$data[28]);
	$data = explode(' ',$data[2]);
	$data = ereg_replace("\""," ",$data[0]);
	$data = htmlentities($data);
	$db = @new mysqli('localhost', 'mytronix.mta.dev', 'mytronix42', 'mta-dev');
	if (mysqli_connect_errno()) 
	{
		die ('Konnte keine Verbindung zur Datenbank aufbauen: '.mysqli_connect_error().'('.mysqli_connect_errno().')');
	}		
	$sql = "SELECT * FROM weather";
	if (!$result = $db->query($sql)) {
		echo $db->error;
	}
	if($result->num_rows > 0)
	{
		$sql = "UPDATE weather SET weatherid='".$data."';";
		if (!$result = $db->query($sql)) {
			echo $db->error;
		}		
	}
	else
	{
		$sql = "INSERT INTO weather (weatherid)VALUES('".$data."');";
		if (!$result = $db->query($sql)) {
			echo $db->error;
		}	
	}
		
?>	