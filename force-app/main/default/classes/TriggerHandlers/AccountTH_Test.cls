/**
 * @author		Paweł Woźniak
 * @created		2022-09-14
 * @description Test class for AccountTH
 */

@isTest
public without sharing class AccountTH_Test {

	@isTest
	private static void testAccountCreation() {
		Map<String, Object> accCustomFieldValues = new Map<String, Object>();
		accCustomFieldValues.put('Description', 'This is a test Account.');

		Test.startTest();
		TestDataFactory.createAccounts(1, accCustomFieldValues);
		Test.stopTest();

		List<Account> accs = [SELECT Id, Description FROM Account];
		System.assertEquals(accs.size(), 1, 'Should be 1 Account created');

		accs[0].Description = 'This is a test Account to be updated.';
		update accs;

		delete accs;

	}

	/**
	 * @description This test set flag "forceException" on trigger which cause that NullPointerException is thrown, which cause DmlException.
	 * This was added to test catch path on Trigger to get 100% coverage. Otherwise it trigger is covered in 33%.
	 */
	@isTest
	private static void test_TestExceptionPath() {
		AccountTH.forceException = true;

		Account newAccount = new Account();

		Utils.verifyIfCustomNullPointerExceptionWasThrown(newAccount);

	}

}