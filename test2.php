<?php
if(!extension_loaded('krb5')) {
	die('KRB5 Extension not installed');
}

//phpinfo();
//Ce fichier de test ne fonctionne pas correctement a déuger
try {

	$auth = new KRB5NegotiateAuth('docker-config/kerberos/krb5.keytab');

if($auth->doAuthentication()) {
	echo 'Success - authenticated as ' . $auth->getAuthenticatedUser();

	try {
		$cc = new KRB5CCache();
		$auth->getDelegatedCredentials($cc);
	} catch (Exception $error) {
		echo 'No delegated credentials available';
	}
} else {
	if(!empty($_SERVER['PHP_AUTH_USER'])) {
		header('HTTP/1.1 401 Unauthorized');
		header('WWW-Authenticate: Basic', false);
	} else {
		// verify basic authentication data
		echo 'authenticated using BASIC method<br />';
	}
}
}catch (Exception $exception){
	var_dump($exception->getMessage());die;
}
?>
