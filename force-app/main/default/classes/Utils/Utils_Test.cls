/**
 * @author		Paweł Woźniak
 * @created		2021-03-29
 * @isTesting	Utils
 * @description	Test class for Utils.cls
 */

@isTest
public without sharing class Utils_Test {

	@isTest
	private static void test_isSandbox() {
		Boolean isSandbox = Utils.isSandbox();
		System.assert(isSandbox != null);
	}

	@isTest
	private static void test_isInAsyncContext() {
		Boolean isInAsync = Utils.isInAsyncContext();
		System.assert(isInAsync != null);
	}

	@isTest
	private static void test_getRTIdByName() {
		Id rtId = Utils.getRTIdByName('Lead', 'Master');
		System.assert(rtId != null);
	}

	@isTest
	private static void test_getRTIdByDeveloperName() {
		Id rtId = Utils.getRTIdByDeveloperName('Lead', 'Master');
		System.assert(rtId != null);
	}

	@isTest
	private static void test_getSetOf() {
		List<User> users = [SELECT Id, Name FROM user LIMIT 10];
		Set<Id> uIds = Utils.getSetOfIds(users, 'Id');
		System.assert(!uIds.isEmpty(), 'Should not be empty');

		Set<String> uNames = Utils.getSetOfStrings(users, 'Name');
		System.assert(!uNames.isEmpty(), 'Should not be empty');
	}

	@isTest
	private static void test_getSetOfStrings_advanced() {
		List<PermissionSetAssignment> psa = [SELECT Id, PermissionSet.Name, Assignee.Profile.Name
		                                     FROM PermissionSetAssignment
		                                     LIMIT 1];
		Set<String> uNames = Utils.getSetOfStrings(psa, 'Assignee.Profile.Name');
		System.assert(!uNames.isEmpty(), 'Should not be empty');

	}

	@isTest
	private static void test_throwAuraHandledException() {
		try {
			Utils.throwAuraHandledException('Test message');
		} catch (Exception ex) {
			System.assertEquals('Test message', ex.getMessage());
		}
	}

	@SuppressWarnings('PMD.UnusedLocalVariable')
	@isTest
	private static void test_throwExceptionAsAuraHandled() {
		try {
			try {
				Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
			} catch (System.QueryException ex) {
				Utils.throwExceptionAsAuraHandled(ex);
			}
		}
		catch (AuraHandledException ahe) {
			System.assertEquals('List has no rows for assignment to SObject', ahe.getMessage());
		}
	}

	@isTest
	private static void testCustomDebug() {
		System.assert(FeatureManagement.checkPermission('Can_Execute_Debug_Statement') != null, 'Missing custom permission.');
		String var1 = 'Test string';
		Utils.debug('Variable value: ' + var1);
	}

	@isTest
	private static void testAddFieldValues() {
		Account acc = new Account();
		
		Map<String, Object> aditonalValues = new Map<String, Object>();
		aditonalValues.put('Name', 'MyAccount');
		aditonalValues.put('SBQQ__RenewalModel__c', 'Contract Based');
		aditonalValues.put('Type', 'Quotable Prospect');
		aditonalValues.put('BillingCountry', 'Denmark');
		aditonalValues.put('BillingCity', 'BillingCity');
		aditonalValues.put('BillingStreet', 'BillingStreet');
		aditonalValues.put('BillingPostalCode', 'BillingPostalCode');
		aditonalValues.put('Customer_Number__c', 'cust3');

		Utils.addFieldValues(acc, aditonalValues);

		insert acc;
		
	}

	@isTest
	private static void testGetPicklistValues() {
		Set<Utils.picklistEntryDetails> pvals = Utils.getPicklistValues('Account', 'AccountSource');
		System.assertEquals(false, pvals.isEmpty(), 'Pvals should not be empty.');
	}

	@isTest
	private static void testParseDateDDMMYYYY() {
		Date expectedDate = Date.newInstance(2022, 04, 20);

		System.assertEquals(expectedDate, utils.parseDateDDMMYYYY('20.04.2022'));
		System.assertEquals(expectedDate, utils.parseDateDDMMYYYY('20-04-2022'));
		System.assertEquals(expectedDate, utils.parseDateDDMMYYYY('20042022'));
		
		System.assertEquals(null, utils.parseDateDDMMYYYY('042022'));
		System.assertEquals(null, utils.parseDateDDMMYYYY('20#04#2022'));

		System.assertEquals(null, utils.parseDateDDMMYYYY(null));
		System.assertEquals(null, utils.parseDateDDMMYYYY(''));
		
	}

}