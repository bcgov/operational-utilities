## net-Tools
A set of Powershell scripts to query server IP and ports accessibility.
### In Windows, set the policy to enable PS Scripts
`PS C:\> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
### List of files
- Get the IP address for servers listed in a json file: [Get_ServerIP.ps1](https://github.com/bcgov/operational-utilities/blob/main/net-tools/Get_ServerIP.ps1)
- Query ports for accessibility: [Query_Ports.ps1](https://github.com/bcgov/operational-utilities/blob/main/net-tools/Query_Ports.ps1)
- Sample server port list JSON file: [serverPortList.json](https://github.com/bcgov/operational-utilities/blob/main/net-tools/serverPortList.json)
