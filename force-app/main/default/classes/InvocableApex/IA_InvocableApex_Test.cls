/**
 * @author		Paweł Woźniak
 * @created		2022-09-16
 * @description	Tests for all invocable apex.
 */

@isTest
public with sharing class IA_InvocableApex_Test {

    @isTest
    private static void testLocalDateTimeToString() {
        List<ia_LocalDateTimeToString.InputFromFlow> simulateInput = new List<ia_LocalDateTimeToString.InputFromFlow>();
        List<ia_LocalDateTimeToString.OutputToFlow> invocableApexOutput = new List<ia_LocalDateTimeToString.OutputToFlow>();

        // Empty record without data
        ia_LocalDateTimeToString.InputFromFlow firstRecord = new ia_LocalDateTimeToString.InputFromFlow();
        simulateInput.add(firstRecord);

        ia_LocalDateTimeToString.InputFromFlow secondRecord = new ia_LocalDateTimeToString.InputFromFlow();
        secondRecord.givenDateTime = Datetime.now();
        simulateInput.add(secondRecord);

        invocableApexOutput = ia_LocalDateTimeToString.convertDateTimeToString(simulateInput);

        System.assertEquals(false, invocableApexOutput.get(0).isSuccess, 'No success as input was empty');
        System.assertEquals(true, invocableApexOutput.get(1).isSuccess, 'Success.');
        Utils.notifyInDebugLog('Date as String is >>' + invocableApexOutput.get(1).dateAsString + '<<.');
        System.assertEquals(true, String.isNotBlank(invocableApexOutput.get(1).dateAsString), 'Should contains value');
    }

}