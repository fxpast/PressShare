
<?php

//Parameter : product_id, destinataire, tokenPush, contenu, lang

session_start();
include 'api_connect.php';



//----------------------------------------- Main program -----------------------------------------------


 // The Badge Number for the Application Icon (integer >=0).
$tBadge = 1; 

// This SQL statement selects message never open

$sql = "SELECT COUNT(*) total FROM Message WHERE product_id = '" . mysqli_real_escape_string($con, $_POST['product_id']) . "' 
        and destinataire = '" . mysqli_real_escape_string($con, $_POST['destinataire']) . "'
        and proprietaire = '" . mysqli_real_escape_string($con, $_POST['destinataire']) . "' 
        and deja_lu = 0";
 
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
	// If so, then create a results array and a temporary one
	// to hold the data    
	$resultArray = array();
	$tempArray = array();
		
	// Loop through each row in the result set
      
	while($row = $result->fetch_object())
	{
            // Add each row into our results array
            $tBadge = $row->total;                     
	}
        
}
else {
    
    if ($_POST['lang'] == "us") 
    {
        $json =  array("success" => "0", "error" => "Connection database message failure"); 
    }
    else if ($_POST['lang'] == "fr") 
    {
        $json =  array("success" => "0", "error" => "echec connexion base de donnée message"); 
    } 
    
    
    echo json_encode($json);

    // Close connections
    mysqli_close($con);
    return;
     	    
}

$sql = "SELECT user_tokenPush, user_device FROM User WHERE user_id = '" . mysqli_real_escape_string($con, $_POST['destinataire']) . "'";


// Check if there are results
if ($result = mysqli_query($con, $sql))
{
	// If so, then create a results array and a temporary one
	// to hold the data    
	$resultArray = array();
	$tempArray = array();
		
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
            // Provide the Device Identifier (Ensure that the Identifier does not have spaces in it).
            // Replace this token with the token of the iOS device that is to receive the notification.
            
            $tToken  = $row->user_tokenPush; 
            $tDevice = $row->user_device; 
                    
	}
        
}
else {
    
    if ($_POST['lang'] == "us") 
    {
        $json =  array("success" => "0", "error" => "Connection database user failure"); 
    }
    else if ($_POST['lang'] == "fr") 
    {
        $json =  array("success" => "0", "error" => "echec connexion base de donnée user"); 
    } 
    
    
    echo json_encode($json);

    // Close connections
    mysqli_close($con);
    return;
     	    
}



if($tDevice == "android") {
    pushAndroid($_POST['contenu'], $_POST['product_id'], $tToken, $tBadge);
    
} else if($tDevice == "ios") {
    
    pushiOS($_POST['contenu'], $_POST['product_id'], $tToken, $tBadge);
}
    
 

// Close connections
mysqli_close($con);



//-------------------------  Android ----------------------------------

function pushAndroid($tAlert, $product_id, $tToken, $tBadge) {
    
      
    // API access key from Google API's Console
    define( 'API_ACCESS_KEY', 'AIzaSyD36K5i4u4RtuSkYTI223DgmiVmjoZs2P4' );

    // prep the bundle
    $msg = array
    (
            'message' 	    =>  $tAlert . '_' . $product_id . '_' . $tBadge,
            'title'         => 'PressShare Contact',
            'vibrate'	    => 1,
            'sound'	    => 1,
            'largeIcon'	    => 'large_icon',
            'smallIcon'	    => 'small_icon'
    );
    $fields = array
    (
            'to' 	=> $tToken,
            'data'	=> $msg
    );
     
    $headers = array
    (
            'Authorization: key=' . API_ACCESS_KEY,
            'Content-Type: application/json'
    );
     
    $ch = curl_init();
    curl_setopt( $ch,CURLOPT_URL, 'https://android.googleapis.com/gcm/send' );
    curl_setopt( $ch,CURLOPT_POST, true );
    curl_setopt( $ch,CURLOPT_HTTPHEADER, $headers );
    curl_setopt( $ch,CURLOPT_RETURNTRANSFER, true );
    curl_setopt( $ch,CURLOPT_SSL_VERIFYPEER, false );
    curl_setopt( $ch,CURLOPT_POSTFIELDS, json_encode( $fields ) );
    $tResult = curl_exec($ch );


    $isOK = strstr($tResult, '"success":1');

 
    if ($isOK) {
       
        $json =  array("success" => "1", "error" => "");   
      
    }  else {
        
        if ($_POST['lang'] == "us") 
        {
            $json =  array("success" => "0", "error" => 'Could not Deliver Message : ' . $tResult); 
        }
        else if ($_POST['lang'] == "fr") 
        {
            $json =  array("success" => "0", "error" => 'Impossible de delivrer le message :' . $tResult); 
        } 
              
    }



     
 

    // Close the Connection to the Server.

    curl_close( $ch );

    echo json_encode($json);

}


//-------------------------  iOS ----------------------------------

function pushiOS($tAlert, $product_id, $tToken, $tBadge) {
    

 
// Provide the Host Information.

$tHost = 'gateway.push.apple.com';

$tPort = 2195;

// Provide the Certificate and Key Data.

$tCert = 'PressSharePushCertifKey.pem';

// Provide the Private Key Passphrase (alternatively you can keep this secrete

// and enter the key manually on the terminal -> remove relevant line from code).

// Replace XXXXX with your Passphrase

$tPassphrase = 'pasgtd';

// The message that is to appear on the dialog.

$tAlert = $_POST['contenu'];

$product_id = $_POST['product_id'];


// Audible Notification Option.

$tSound = 'default';

// The content that is returned by the LiveCode "pushNotificationReceived" message.

$tPayload = 'APNS Message Handled';

// Create the message content that is to be sent to the device.

$tBody['aps'] = array (

'alert' => $tAlert,

'badge' => $tBadge,

'sound' => $tSound,

'product_id' => $product_id,

);

$tBody ['payload'] = $tPayload;

// Encode the body to JSON.

$tBody = json_encode ($tBody);

// Create the Socket Stream.

$tContext = stream_context_create ();

stream_context_set_option ($tContext, 'ssl', 'local_cert', $tCert);

// Remove this line if you would like to enter the Private Key Passphrase manually.

stream_context_set_option ($tContext, 'ssl', 'passphrase', $tPassphrase);

// Open the Connection to the APNS Server.

$tSocket = stream_socket_client ('ssl://'.$tHost.':'.$tPort, $error, $errstr, 30, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $tContext);

// Check if we were able to open a socket.

if (!$tSocket) {
    exit ("APNS Connection Failed: $error $errstr" . PHP_EOL);
}
// Build the Binary Notification.

$tMsg = chr (0) . chr (0) . chr (32) . pack ('H*', $tToken) . pack ('n', strlen ($tBody)) . $tBody;

// Send the Notification to the Server.

$tResult = fwrite ($tSocket, $tMsg, strlen ($tMsg));

if ($tResult) {

        $json =  array("success" => "1", "error" => "");    
}
else {
    
    if ($_POST['lang'] == "us") 
    {
        $json =  array("success" => "0", "error" => 'Could not Deliver Message to APNS' . PHP_EOL); 
    }
    else if ($_POST['lang'] == "fr") 
    {
        $json =  array("success" => "0", "error" => 'Impossible de delivrer le message à APNS' . PHP_EOL); 
    } 
    
}
// Close the Connection to the Server.


echo json_encode($json);

fclose ($tSocket);

    
}



?>