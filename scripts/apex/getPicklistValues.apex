/**
 * Anonymous apex for getting picklist values
 * Usage: 
 * sfdx force:apex:execute -f scripts\apex\getPicklistValues.apex
 */

String objectName = 'Account';
String fieldName = 'AccountSource';

Set<Utils.picklistEntryDetails> pvals = Utils.getPicklistValues(objectName, fieldName);

System.debug('**************************************************************');
System.debug('************ ' + objectName + '.' + fieldName + ' ************');
Integer i = 1;
for (Utils.picklistEntryDetails pv : pvals) {
    String line = '* ' + i + '. ' + pv.label + ' (' + pv.apiName + ')';
    line += pv.isDefault ? ' [Default] ' : '';
    System.debug(line);
    i++;
}

System.debug('***************************************************************');
System.debug('***************************************************************');