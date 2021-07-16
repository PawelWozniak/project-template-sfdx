## What you need for package based development.
This is short description. More details you can [read here](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_unlocked_pkg_create_pkg.htm).
Installed SFDX package.
Access to SF with enabled DevHub. In most cases it will be your Production org.

### Proper access to PROD
1. Create Permission Set `DevHub access for Developer` which will grant minimal required permissions for proper Packages Development.
1. On Permission set in System Permissions select: `Create and Update Second-Generation Packages`, `Delete Second-Generation Packages`.
1. Assign this permission set to developer who need to create package version.

### Registered with DevHub
1. You need to have account in PROD as described above
2. Authorize PROD as DevHub org `sfdx auth:web:login --setdefaultdevhubusername --setalias <OrgName>`, replace <OrgName> with your own name.

### Create Package
To create new package directory and add it to `sfdx-project.json` run:  
`sfdx force:package:create --name "My Package" --path "pkg-MyPackage" --packagetype Unlocked --nonamespace --description "Package description"`  
It return package Id 0Ho...  
This is one time action, don't repeat that when you want to create new version.

Other usefull commands:  
`sfdx force:package:list`  
`sfdx force:package:delete -p 0Ho...`

### Package version creation 
In order to create first version or new version after modification run this command:  
`sfdx force:package:version:create --package "My Package" --installationkey "Inst4latiOnPa$$word" --wait 10 --codecoverage --versiondescription "Changes in this version..."`  
this will create BETA version of package.  

Other usefull commands:  
`sfdx force:package:version:list` - Check all packages in DevHub and their versions.  
`sfdx force:package:version:report --package 04t...` - Check details of package: version, code coverage etc.  
`sfdx force:package:version:delete -p 04t...` - Delete package

### Promote package as production ready version
If package is tested and ready for PROD instalation it must be promoted:  
`sfdx force:package:version:promote --package "My Package@1.0.2-2"`

### Install package in org
`sfdx force:package:install --wait 10 --publishwait 10 --package "My Package@1.0.2-2" --installationkey "Inst4latiOnPa$$word" -u <TargetOrgAlias>`
