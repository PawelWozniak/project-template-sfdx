# template-sfdx

Template project for SFDX, based on official Salesforce structure.  
Base sfdx structure which was generated with SFDX 7.93.1 cli, Windows.  
`sfdx force:project:create --projectname template-sfdx`  
[Check latest CLI changelog here.](https://github.com/forcedotcom/cli/tree/main/releasenotes)

# Install required additonal software

1. Install SFDX cli https://developer.salesforce.com/tools/sfdxcli
2. Install latest LTS version of Node.js form https://nodejs.org/  
   Update global npm to latest version `npm -g install npm@latest`  
3. Create folder `C:\cli_tools` add it to system PATH
4. Download PMD from https://pmd.github.io and unzip it to `C:\cli_tools`, remove version number and leave only `pmd-bin`. Add `C:\cli_tools\pmd-bin\bin` to system PATH.
5. Download Uncrustify https://sourceforge.net/projects/uncrustify/ and unzip it to `C:\cli_tools\uncrustify`, add it to system PATH.

Verify. Open command line ([Windows Terminal](https://www.microsoft.com/pl-pl/p/windows-terminal/9n0dx20hk701) recommended) and type `pmd`, `uncrustify --version`, `node --version` all of this commands should not return errors.

# Additonal configuration on your computer (Windows 10)

1. Run `sfdx update`.
2. Install sfdx plugins:  
`sfdx plugins:install @salesforce/sfdx-diff`
3. Inside `template-sfdx` using command line run `npm install` which will install all required node modules which are defined in `package.json`  
   Check installed packages versions by `npm ls --depth=0`

# Modifications of template

### Project configuration changes made
1. In package.json removed `prettier --write` from lint-staged script as it was formatting files before committing to repository which caused huge diffs against org.

2. In `/config` added `PMD_01_BasicSet.xml` and `PMD_02_NamingConvention.xml` rule sets.  
Read more about rules configuration here https://pmd.github.io/latest/pmd_rules_apex_design.html  
By default only basic set is active.

### VSCode configuration
1. Added recommended extensions in `.vscode\extensions.json`
2. In `.vscode\settings.json` added sfdx, PMD, prettier, uncrustify, default formatters and editor configuration.  
Set line lenght to 160 characters as it is optimal for wide monitors.
