# template-sfdx

Template project for SFDX, based on official Salesforce structure.  
Base sfdx structure which was generated with SFDX 7.93.1 cli, Windows.
`sfdx force:project:create --projectname template-sfdx`  
[Check latest CLI changelog here.](https://github.com/forcedotcom/cli/tree/main/releasenotes)

# Install required additonal software

1. Install latest LTS version of Node.js form https://nodejs.org/  
   Update global npm to latest version `npm -g install npm@latest`  
   Check `npm version` it should be higher than 7.7.5

# Additonal configuration on your computer (Windows 10)

1. Inside `template-sfdx` using command line run `npm install` which will install all required node modules which are defined in `package.json`  
   Check installed packages versions by `npm ls --depth=0`

# Modifications of template

### Node modules

1. Lowered `eslint` from version ^7.6.0 to ^6.8.0 as depended packages gives error during `npm install` that ^6 is a highest acceptable.
2. Updated `@salesforce/eslint-config-lwc` to ^0.10.0
