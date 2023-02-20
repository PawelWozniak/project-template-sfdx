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
		System.assert(isSandbox != null, 'Should return true or false');
	}

	@isTest
	private static void test_isInAsyncContext() {
		Boolean isInAsync = Utils.isInAsyncContext();
		System.assert(isInAsync != null, 'Should return true or false');
	}

	@isTest
	private static void test_getRTIdByDeveloperName() {
		Id rtId = Utils.getRTIdByDeveloperName('Lead', 'Master');
		System.assert(rtId != null, 'RecordTypeId should not be empty');
	}

	@isTest
	private static void testGetPicklistValues() {
		Set<Utils.picklistEntryDetails> pickValues = Utils.getPicklistValues('Account', 'AccountSource');
		System.assertEquals(false, pickValues.isEmpty(), 'Picklist values should not be empty.');
	}

	@isTest
	private static void testGetPicklistValuesAPItoLabelMap() {
		Map<String, String> apiToLabelMap = Utils.getPicklistValuesAPItoLabelMap('Account', 'AccountSource');
		System.assertEquals(false, apiToLabelMap.isEmpty(), 'API to Label Map should not be empty.');
	}

	@isTest
	private static void testGetSetOf() {
		List<User> users = [SELECT Id, Name FROM user LIMIT 10];
		Set<Id> uIds = Utils.getSetOfIds(users, 'Id');
		System.assert(!uIds.isEmpty(), 'Should not be empty');

		Set<String> uNames = Utils.getSetOfStrings(users, 'Name');
		System.assert(!uNames.isEmpty(), 'Should not be empty');
	}

	@isTest
	private static void testGetSetOfStrings_advanced() {
		List<PermissionSetAssignment> psa = [SELECT Id, PermissionSet.Name, Assignee.Profile.Name
											 FROM PermissionSetAssignment
											 LIMIT 1];
		Set<String> uNames = Utils.getSetOfStrings(psa, 'Assignee.Profile.Name');
		System.assert(!uNames.isEmpty(), 'Should not be empty');

	}

	@isTest
	private static void testThrowAuraHandledException() {
		try {
			Utils.throwAuraHandledException('Test message');
		}
		catch (Exception ex) {
			System.assertEquals('Test message', ex.getMessage(), 'Aura message should be our custom text');
		}
	}

	@SuppressWarnings('PMD.UnusedLocalVariable')
	@isTest
	private static void testThrowExceptionAsAuraHandled() {
		try {
			try {
				Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
			}
			catch (System.QueryException ex) {
				Utils.throwExceptionAsAuraHandled(ex);
			}
		}
		catch (AuraHandledException ahe) {
			System.assertEquals('List has no rows for assignment to SObject', ahe.getMessage(), 'Aura message should contain the same message as exception');
		}
	}

	@isTest
	@SuppressWarnings('PMD.UnusedLocalVariable')
	private static void testTriggerException() {
		// Query exception
		try {
			try {
				Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
			}
			catch (Exception ex) {
				throw new Utils.triggerException(ex, '1234');
			}
		}
		catch (Exception te) {
			System.assert(te.getMessage().startsWith('**1234** Caused by: System.QueryException: List has no rows for assignment to SObject.'), 'Custom Error should have transaction id.');
		}

		// DML Exception
		try {
			try {
				Lead newLead = new Lead();
				newLead.FirstName = 'Tester';
				insert newLead;
			}
			catch (Exception ex) {
				throw new Utils.triggerException(ex, '1234');
			}
		}
		catch (Exception te) {
			System.assert(te.getMessage().startsWith('**1234** Caused by: System.DmlException: Insert failed.'), 'Custom Error should have transaction id.' + te.getMessage());
		}
	}

	@isTest
	private static void test_formatException() {
		// Test DmlException
		try {
			Lead newLead = new Lead();
			newLead.FirstName = 'Tester';
			insert newLead;
		}
		catch (Exception ex) {
			String formattedError = Utils.formatException(ex);
			Assert.isTrue(formattedError.contains('Type: System.DmlException'));
		}
	}

	@IsTest
	private static void test_formatHttpRequestResponse() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new httpErrorMock(404));
		String requestId = null;

		String endPoint_URL = 'www.example.com/API/v1/account';
		String method = 'POST';

		Http httpCallout = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPoint_URL);
		request.setMethod(method);

		HttpResponse response = httpCallout.send(request);

		if (response.getStatusCode() == 200) {
			// Process response
		}
		else {
			String formattedError = Utils.formatHttpRequestResponse(request, response);
			Assert.isTrue(formattedError.contains('Endpoint: www.example.com/API/v1/account'));
			Assert.isTrue(formattedError.contains('Method: POST'));
		}

		// For increasing code coverage
		String emptyError = Utils.formatHttpRequestResponse(null, null);
		Assert.isTrue(emptyError.contains('*Request argument was null*'));
		Assert.isTrue(emptyError.contains('*Response argument was null*'));
	}

	@isTest
	private static void testCustomDebug() {
		System.assert(FeatureManagement.checkPermission('Can_Execute_Debug_Statement') != null, 'Missing custom permission.');
		String var1 = 'Test string';
		Utils.debug('Variable value: ' + var1);
		Utils.debug(LoggingLevel.FINE, 'Variable value: ' + var1);
	}

	@isTest
	private static void testNotifyInDebugLog() {
		Utils.notifyInDebugLog('Skipping this record processing as it don\'t match to criteria.');
	}

	@isTest
	private static void testGetQuiddity() {
		String quiddity = Utils.getQuiddity();
		System.assert(String.isNotEmpty(quiddity), 'Should contain value');
	}

	@isTest
	private static void testGetSetOfAssignedPermissionSetsToRunningUser() {
		Set<String> permSetsAssigned = Utils.getSetOfAssignedPermissionSetsToRunningUser();
		System.assert(permSetsAssigned.isEmpty() == false, 'Should not be empty');
	}

	@isTest
	private static void testAddFieldValues() {
		Account acc = new Account();

		Map<String, Object> additionalValues = new Map<String, Object>();
		additionalValues.put('Name', 'MyAccount');
		additionalValues.put('Type', 'Quotable Prospect');
		additionalValues.put('BillingCountry', 'Germany');
		additionalValues.put('BillingCity', 'BillingCity');
		additionalValues.put('BillingStreet', 'BillingStreet');
		additionalValues.put('BillingPostalCode', 'BillingPostalCode');

		Utils.addFieldValues(acc, additionalValues);

		System.assertEquals(acc.Name, 'MyAccount', 'Custom value should be set on account');
	}

	@isTest
	private static void testLogSuccessAndFailedSaveToDebugLog() {
		List<Account> accs = TestDataFactory.createAccounts(2, new Map<String, Object>());
		accs[1].Name = '';

		List<Database.SaveResult> saveResults = Database.update(accs, false);
		Utils.logSuccessAndFailedSaveToDebugLog(saveResults, accs);

	}

	@isTest
	private static void testParseDateDDMMYYYY() {
		Date expectedDate = Date.newInstance(2022, 04, 20);

		System.assertEquals(expectedDate, utils.parseDateDDMMYYYY('20.04.2022'), 'Should be date returned');
		System.assertEquals(expectedDate, utils.parseDateDDMMYYYY('20-04-2022'), 'Should be date returned');
		System.assertEquals(expectedDate, utils.parseDateDDMMYYYY('20042022'), 'Should be date returned');

		System.assertEquals(null, utils.parseDateDDMMYYYY('042022'), 'Should be null returned');
		System.assertEquals(null, utils.parseDateDDMMYYYY('20#04#2022'), 'Should be null returned');

		System.assertEquals(null, utils.parseDateDDMMYYYY(null), 'Should be null returned');
		System.assertEquals(null, utils.parseDateDDMMYYYY(''), 'Should be null returned');

	}

	@isTest
	private static void testDebugSendMeEmailWithObjectAsJSON() {
		List<Account> accs = TestDataFactory.createAccounts(1, new Map<String, Object>());
		try {
			Utils.debug_sendMeEmailWithObjectAsJSON(accs[0]);
		}
		catch (Exception e) {
			Utils.notifyInDebugLog('Sending email failed as it is turn off in configuration');
		}

	}

	@isTest
	private static void testIsPW() {
		Boolean isPw = Utils.isPW();
		System.assertNotEquals(null, isPw, 'Should return true or false');
	}

	// Not in a separate class to keep it as an independent module resistant for other changes.
	public class httpErrorMock implements HttpCalloutMock {

		Integer returnCode;

		public httpErrorMock(Integer returnCode) {
			this.returnCode = returnCode;
		}

		// 404 Not Found
		public HTTPResponse respond(HTTPRequest req) {
			if (returnCode == 404) {
				HttpResponse res = new HttpResponse();
				res.setHeader('Content-Type', 'application/json');
				res.setBody('{"error":{"message":"Not Found"},"success":false}');
				res.setStatusCode(returnCode);
				res.setStatus('Bad Request');
				return res;
			}

			System.debug('##### ^^^ Returning null from mock class. Something went wrong, check your code. ^^^ ######');
			return null;
		}

	}

}