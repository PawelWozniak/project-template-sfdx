/**
 * Clear Salesforce Debug logs
 */
const fsExtra = require('fs-extra');

let folder = '.sfdx/tools/debug/logs';
fsExtra.emptyDir(folder, err => {
    if (err) return console.error(err)
    console.log('SFDX debug logs deleted.')
  })