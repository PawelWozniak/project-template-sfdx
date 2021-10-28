/** 
 * List all validation rules and save results to csv file.
 * @author Paweł Woźniak
*/
var utils = require('./xUtils.js');

var query = 'SELECT Id, ValidationName, Active, Description, EntityDefinition.DeveloperName, ErrorDisplayField, ErrorMessage FROM ValidationRule'

utils.queryAndSaveResults(query, 'ValidationRules.csv');