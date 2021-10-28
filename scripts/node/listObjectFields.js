/** 
 * List all fields on object and save to csv file.
 * @see https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/tooling_api_objects_externalstring.htm
 * @author Paweł Woźniak
*/
var utils = require('./xUtils.js');
var objectAPIName = 'ServiceAppointment';

var query = 'SELECT Label, DeveloperName, DataType FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName  = \'' + objectAPIName + '\''

utils.queryAndSaveResults(query, objectAPIName + '_fields.csv');