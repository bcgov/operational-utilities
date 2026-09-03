<# Name: PMP_Concurrent_Request_Test.ps1
Purpose:
    Spawn multiple concurrent requests to test a PMP server.

Usage:
	o Short form:
        PMP_Concurrent_Request_Test.ps1 PMP_Token [#_of_Rounds]
	o Long form:
        PMP_Concurrent_Request_Test.ps1 -URL https://my_pmp.ca -Token PMP_Token -Rounds #_of_Rounds -Resource Resource_ID -Account Account_ID
Parameters:
	-URL: Optional. URL of your pmp server. Please set your default PMP URL.
    -Token: Mandatory. The PMP API Token to access PMP.
    -Rounds: Optional. The number of rounds to run. defaults to 1.
    -Resource: Optional. The ID (a number) of a PMP Resource you are querying. Defaults to 6315.
    -Account: Optional. The ID (a number) of a PMP Account you are querying. Defaults to 32406.
Example 1, short form:
    PMP_Concurrent_Request_Test.ps1 1ADA789***679F98 12
    Will spawn 12 concurrent request to the PMP server by using the token "1ADA789***679F98".
Example 2, long form:
	PMP_Concurrent_test.ps1 -url https://my_test_pmp.ca -token "1ADA789***679F98" -rounds 12 -Resource 1234 -Account 12345
Comments:
	o Set the default values for $URL, $Resource, and $Account before use.
	o To enable PS Scripts, run the command below in a PowerShell window (you only need to do this once):
		Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>


param(
    [string]$URL="https://my_pmp.ca",
    [Parameter(Position=0)][string]$Token,
    [Parameter(Position=1)][int]$Rounds=1,
    [string]$Resource=3214,
    [string]$Account=30006
)

workflow test-parallel{
    param(
        [string]$URL,
        [string]$Token,
        [int[]]$Numbers,
        [string]$Resource,
        [string]$Account
    )

    ForEach -Parallel ($n in $Numbers) {
        "Start Request $n at " + (Get-Date).ToString("yyyy-MM-dd hh:mm:ss.fff")
        curl.exe -k -H "AUTHTOKEN:$Token" $URL/restapi/json/v1/resources/$Resource/accounts/$Account
        "Processed Request $n at " + (Get-Date).ToString("yyyy-MM-dd hh:mm:ss.fff")
    }
}

$IntArray = @(1)
for ($i = 2; $i -le $Rounds; $i++) {
    $IntArray += $i
}

test-parallel -Numbers $IntArray -URL $URL -Token $Token -Resource $Resource -Account $Account
