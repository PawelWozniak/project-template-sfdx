/** 
 * List all custom labels and save to csv file.
 * @see https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/tooling_api_objects_externalstring.htm
 * @author Paweł Woźniak
*/
var utils = require('./xUtils.js');

var query = 'SELECT Id, Name, MasterLabel, Value, Category, NamespacePrefix, IsProtected FROM ExternalString'

utils.queryAndSaveResults(query, true, 'CustomLabels.csv');