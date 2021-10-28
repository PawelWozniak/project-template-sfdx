/**
 * Clear Salesforce Debug logs
 */
const fsExtra = require('fs-extra');

let folder = '.sfdx/tools/testresults/apex';
fsExtra.emptyDir(folder, err => {
    if (err) return console.error(err)
    console.log('SFDX tests results deleted.')
  })
  