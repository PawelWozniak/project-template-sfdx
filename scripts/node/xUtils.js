/**
 * Utils used in scripts
 */
// @ts-check

fs = require('fs-extra');
const { exec } = require('child_process');


module.exports = {
    queryAndSaveResults: function (query, useToolingAPI, filename) {

        var command = 'sfdx force:data:soql:query --query "' + query + '" --resultformat csv';
        if (useToolingAPI) {
            command += ' --usetoolingapi';
        }
        console.log('Command: ' + command);
        console.log('Query: ' + query);

        exec(command, { 'shell': 'powershell.exe' }, (error, stdout, stderr) => {
            if (error == null) {
                fs.outputFile('../../temp/' + filename, stdout, function (err) {
                    if (err) return console.log(err);
                });
            } else {
                console.log('stdout: ' + stdout);
                console.log('stderr: ' + stderr);
                //console.log('error: ' + error);
            }
        })
    }
}
