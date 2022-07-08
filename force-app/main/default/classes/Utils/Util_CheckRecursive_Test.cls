/**
 * @author      Pawel Wozniak
 * @created     2021-07-05
 * @isTesting   Util_CheckRecursive
 * @description
 * @url         https://www.linkedin.com/pulse/salesforce-admins-thoughts-recursion-apex-david-vickers/
 */

@IsTest
private class Util_CheckRecursive_Test {
	@isTest
	private static void testIsFirstCallOf() {
		System.assertEquals(true, Util_CheckRecursive.isFirstCallOf('MyString'));
		System.assertEquals(false, Util_CheckRecursive.isFirstCallOf('MyString'));
		System.assertEquals(false, Util_CheckRecursive.isFirstCallOf('MyString'));
	}

	@IsTest
	static void testCountingAndReset() {
		System.assertEquals(0, Util_CheckRecursive.numberofCalls('Testme'), 'Zero calls before');
		System.assertEquals(1, Util_CheckRecursive.iveBeenCalled('Testme'), 'First call happen');
		System.assertEquals(1, Util_CheckRecursive.numberofCalls('Testme'), 'One call before');
		System.assertEquals(2, Util_CheckRecursive.iveBeenCalled('Testme'), 'Second calls happen');
		// Reset counter
		Util_CheckRecursive.ResetAll();
		System.assertEquals(0, Util_CheckRecursive.numberofCalls('Testme'), 'Zero calls before');
		System.assertEquals(1, Util_CheckRecursive.iveBeenCalled('Testme'), 'First call happen');
		System.assertEquals(1, Util_CheckRecursive.numberofCalls('Testme'), 'One call before');
		System.assertEquals(2, Util_CheckRecursive.iveBeenCalled('Testme'), 'Second calls happen');

	}

	@isTest
	private static void testSetOfIds() {
		Util_CheckRecursive.setOfIDs.add('0030000589687541ABC');
		System.assertEquals(true, Util_CheckRecursive.setOfIDs.contains('0030000589687541ABC'));
	}

    @isTest
    private static void testTriggerRunCounting() {
        
        Object triggerFile = 'ClassName:abc';
        Util_CheckRecursive.addTriggerEventCallCount(triggerFile);
        Integer count = Util_CheckRecursive.getTriggerEventCallCount(triggerFile);
        System.assertEquals(1, count, 'How many times trigger was called?');

    }

}