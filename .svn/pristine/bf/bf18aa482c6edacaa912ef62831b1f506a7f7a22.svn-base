Function SDP_Add_Notes {Param($credentials = $null,
								$domain = "PARMA.INTERNAL",
								$jobnumber=$null,
								[switch]$ShowNotes,
								$Notes=$null,
								$url="http://sdp:8080/servlets/RequestServlet")
	# Live System: http://sdp:8080/servlets/RequestServlet
	# Test system: http://vc2sdp-02:8080/servlets/RequestServlet
	if ($ShowNotes.IsPresent -eq $true){$isPublic = "true"}else{$isPublic = "false"}
	$wc = new-object system.net.WebClient 
	$col = new-object System.Collections.Specialized.NameValueCollection 
	$col.Add("workOrderID", $jobnumber)
	$col.Add("username", $credentials.username.trim("\"))
	$col.Add("password", $credentials.GetNetworkCredential().password)
	$col.Add("isPublic", $isPublic)
	$col.Add("DOMAIN_NAME", $domain)
	$col.Add("logonDomainName", "AD_AUTH")
	$col.Add("notesText", $notes)
	$col.Add("operation", "AddNotes")
	$wc.QueryString = $col
	$webpage = $wc.UploadValues($url, "POST", $col)
	$response = [System.Text.Encoding]::ASCII.GetString($webpage)
	[xml]$response = [System.Text.Encoding]::ASCII.GetString($webpage)
	return $response
}

function Execute-HTTPPostCommand {param([string]$target = $null)
$username = "administrator"
$password = "mypass"
$webRequest = [System.Net.WebRequest]::Create($target)
$webRequest.ContentType = "text/html"
$PostStr = [System.Text.Encoding]::UTF8.GetBytes($Post)
$webrequest.ContentLength = $PostStr.Length
$webRequest.ServicePoint.Expect100Continue = $false
$webRequest.Credentials = New-Object System.Net.NetworkCredential -ArgumentList $username, $password 
$webRequest.PreAuthenticate = $true
$webRequest.Method = "POST"
$requestStream = $webRequest.GetRequestStream()
	$requestStream.Write($PostStr, 0,$PostStr.length)
	$requestStream.Close()
    [System.Net.WebResponse]$resp = $webRequest.GetResponse()
    $rs = $resp.GetResponseStream()
    [System.IO.StreamReader]$sr = New-Object System.IO.StreamReader -argumentList $rs
    [string]$results = $sr.ReadToEnd()
	return $results
}


#$post = "volume=6001F930010310000195000200000000&arrayendpoint=2000001F930010A4&hostendpoint=100000051ED4469C&lun=2"
#$URL = "http://vm-manageengine/servlets/RequestServlet"
#Execute-HTTPPostCommand $URL