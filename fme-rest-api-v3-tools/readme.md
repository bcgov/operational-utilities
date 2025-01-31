## FME-REST-API-V3-Tools
A set of Powershell scripts to access FME REST API version 3.
### In Windows, set the policy to enable PS Scripts
`PS C:\> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
### List of scripts
- Common supporting functions: [FME_RestAPI_Common.psm1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/FME_RestAPI_Common.psm1)
- Get Repositories: Download FME Repositories in JSON format through FME API. [Get_FMERepositories.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Get_FMERepositories.ps1)
- Get Schedules: Download FME Schedules in JSON format through FME API. [fme-rest-api-v3-tools/Get_FMESchedules.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Get_FMESchedules.ps1)
- Set Schedules: Read FME Schedules from a JSON file, and write schedule items back to FME. [Set_FMESchedules.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Set_FMESchedules.ps1)
- Update Schedules: Read current FME Schedules, apply global changes and then write back to FME. [Update_FMESchedules.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Update_FMESchedules.ps1)
- Get Users: Download FME Users (Accounts) in JSON format through FME API. [Get_FMEUsers.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Get_FMEUsers.ps1)
- Get LDAP Users: Download FME LDAP Users in JSON format through FME API. The `"server"` field in the output JSON file is the `Name` of the `Authentication Services` in FME Flow (Server) under `ADMIN -> User Management -> Authentication Services -> Name`. [Get_FMELdapUsers.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Get_FMELdapUsers.ps1)
- Get User Roles: Download FME User Roles in JSON format through FME API. [Get_FMEUserRoles.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Get_FMEUserRoles.ps1)
- Set User Roles: Read FME User Roles from a JSON file, and write the items back to FME. [Set_FMEUserRoles.ps1](https://github.com/bcgov/operational-utilities/blob/main/fme-rest-api-v3-tools/Set_FMEUserRoles.ps1)
