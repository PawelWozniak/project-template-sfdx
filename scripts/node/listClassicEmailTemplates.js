/** 
 * List all classic email templates and save results to csv file.
 * @author Paweł Woźniak
*/
var utils = require('./xUtils.js');

var query = 'SELECT Id, Name, DeveloperName FROM EmailTemplate ORDER BY Name ASC'

utils.queryAndSaveResults(query, false, 'ClassicEmailTemplates.csv');