/**
 * @author		Paweł Woźniak
 * @created		2021-03-29
 * @JIRA task
 * @description	Methods that are frequently used.
 */

public without sharing class Utils {

	private static Boolean isSandbox = null;
	private static Boolean isInAsyncContext = null;
	private static Boolean canExecuteDebug = null;

	// Check if current org is Sandbox
	public static Boolean isSandbox() {
		if (isSandbox == null) {
			isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
		}

		return isSandbox;
	}

	// Check if code is already executing in async context. Usefull for triggers which can be run from batch apex on records update.
	// Use it to avoid "Future method cannot be called from a future or batch method"
	// if (!isInAsyncContext) { someFutureMethod; } else { otherNonFutureMethod; }
	public static Boolean isInAsyncContext() {
		if (isInAsyncContext == null) {
			isInAsyncContext = System.isBatch() || System.isFuture() || System.isQueueable();
		}

		return isInAsyncContext;
	}

	/* Get info from Schema */

	// Get record Type Id by Name
	public static String getRTIdByName(String objectName, String rtName) {
		Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(rtName).getRecordTypeId();
		return recordTypeId;
	}

	// Get record Type Id by Developer Name
	public static String getRTIdByDeveloperName(String objectName, String rtDeveloperName) {
		Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
		return recordTypeId;
	}

	/* Collections */

	/* Get set of values from list of records. Example usage:
	      List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity];
	      Set<Id> setOfAccountIds = IMUtils.getSetOfIds(opps, 'AccountId');
	      List<Account> accs = [SELECT Id, Name FROM Account WHERE Id IN :setOfAccountIds];
	 */
	public static Set<Id> getSetOfIds(List<SObject> recordsList, String fieldName) {
		Set<Id> setOfValues = new Set<Id> ();

		for (SObject oneRecord : recordsList) {
			Id idFieldValue = (Id) oneRecord.get(fieldName);

			if (idFieldValue != null) {
				setOfValues.add(idFieldValue);
			}
		}

		return setOfValues;
	}

	/**
	 * Get set of values from list of records. Results may be used with .contains() or as input for another query.
	 * @param recordsList records list from query reults
	 * @param fieldName field from which you want to make a Set of values.
	 * Example usage see getSetOfAssignedPermissionSets() in this class.
	 */
	public static Set<String> getSetOfStrings(List<SObject> recordsList, String fieldName) {
		Set<String> setOfValues = new Set<String> ();
		List<String> splitedFieldName = new List<String>();

		if (fieldName.contains('.')) {
			splitedFieldName = fieldName.split('\\.');
		}

		for (SObject oneRecord : recordsList) {
			String stringFieldValue = '';

			if (splitedFieldName.isEmpty()) {
				stringFieldValue = (String) oneRecord.get(fieldName);
			}
			else {
				Integer numOfSegments = splitedFieldName.size();
				sObject tmpObject = oneRecord;

				for (Integer i = 0; i < numOfSegments - 1; i++) {
					tmpObject = tmpObject.getSObject(splitedFieldName.get(i));
				}

				stringFieldValue = (String) tmpObject.get(splitedFieldName.get(numOfSegments - 1));
			}

			if (String.isNotEmpty(stringFieldValue)) {
				setOfValues.add(stringFieldValue);
			}
		}

		return setOfValues;
	}

	/* Custom exceptions */
	// Use this method to be able check message by e.getMessage() in tests. See Utils_Test.cls
	public static void throwAuraHandledException(String userVisibleMessage) {
		AuraHandledException ahe = new AuraHandledException(userVisibleMessage);
		ahe.setMessage(userVisibleMessage);
		throw ahe;
	}

	public static void throwExceptionAsAuraHandled(Exception ex) {
		AuraHandledException ahe = new AuraHandledException(ex.getMessage());
		ahe.setMessage(ex.getMessage());

		if (ex.getCause() != null) {
			ahe.initCause(ex.getCause());
		}

		throw ahe;
	}

	/**
	 * @description Use in triggers to rethrow exception with additional information with Request Id
	 * Example, put this inside yout trigger:
	 * try {
	 *     new TriggerHandlerClassName().run();
	 * } catch (Exception ex) {
	 *     String requestID = RuntimeErrorLog.saveException('ServiceAppointmentTH', ex.getTypeName(), null, ex);
	 *     throw new Utils.triggerException (ex, requestID);
	 * }
	 */
	public class triggerException extends Exception {
		/**
		 * @description rethrows an error with custom message which contains requestId.
		 * @param ex exception thrown in trigger
		 * @param requestID requestID returned by calling RuntimeErrorLog.saveException(); Use it to search for log entry in "Runtime Error Logs" object.
		 */
		public triggerException (Exception ex, String requestID) {
			String message = '**' + requestID + '**' + ' Caused by: ' + ex.getTypeName() + ': ' + ex.getMessage() + '. # ' + ex.getStackTraceString().split(', column 1')[0] + ' #';
			this.setMessage(message);
		}
	}

	/**
	 * Throw custom Nullpointer Excepetion
	 * Use it when catching NullPointerException
	 * Example:
	 *	catch (NullPointerException npe) {
	 *		String msg = '⚠️ If you got this error then... (add here a possible reason for error) ⚠️';
	 *		throw new Utils.CustomNullPointerException(msg, npe);
	 *	}
	 */
	public class CustomNullPointerException extends Exception {}

	/* Debug logs */

	/**
	 * This method check if current user has rights to see debugs and then display them. Must have parmission set: Can Execute Debug Statment⚠
	 * It was introduced to optimize code runtime as debug statments slow down code execution. See link for more details.
	 * @param obj any object.
	 * @link http://bobbuzzard.blogspot.com/2021/05/the-impact-of-systemdebug.html
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void debug(Object obj) {
		if (canExecuteDebug == null) {
			canExecuteDebug = FeatureManagement.checkPermission('Can_Execute_Debug_Statement');
		}

		if (canExecuteDebug) {
			System.debug(LoggingLevel.INFO, obj);
		}
	}

	/**
	 * This method check if current user has rights to see debugs and then display them. Must have parmission set: Can Execute Debug Statment⚠
	 * It was introduced to optimize code runtime as debug statments slow down code execution. See link for more details.
	 * @param obj any object.
	 * @link http://bobbuzzard.blogspot.com/2021/05/the-impact-of-systemdebug.html
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void debug(System.LoggingLevel loglevel, Object obj) {
		if (canExecuteDebug == null) {
			canExecuteDebug = FeatureManagement.checkPermission('Can_Execute_Debug_Statement');
		}

		if (canExecuteDebug) {
			System.debug(loglevel, obj);
		}
	}

	/**
	 *  Notify in logs about some important actions like skipping record processing so it can be seen in logs eaisly why. DO NOT USE it for debugging.
	 *  Example usage: if (do something if conditions are met) else {Utils.notifyInDebugLog('Not updating record ' + acc.Name + ' as it don't meet the criteria');}
	 *  @param message string with message to be shown in debug logs.
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void notifyInDebugLog(String message) {
		System.debug(LoggingLevel.INFO, '📢' + message);
	}

	/* Other */

	/**
	 * Get current quiditty.
	 * @link https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_Quiddity.htm#topic-title
	 */
	public static String getQuiddity() {
		return Request.getCurrent().getQuiddity().name();
	}

	/**
	 * Make a set with all permission sets assigned to user.
	 *
	 */
	public static Set<String> getSetOfAssignedPermissionSetsToRunningUser() {
		List<PermissionSetAssignment> assignedPermSets = [SELECT Id, PermissionSet.Name
														  FROM PermissionSetAssignment
														  WHERE AssigneeId = :Userinfo.getUserId()];

		return getSetOfStrings(assignedPermSets, 'PermissionSet.Name');

	}

	/**
	 * @description Helper method which add fields values passed to main object creation method by user.
	 * Usefull if you need some non standard values or alter default values.
	 * @param sObj any object. Since sObj is a reference it will be updated without need of returning value.
	 * @param fieldsValues Map with custom field values. Deifne them as: new Map<String, Object> {'My_Field_name__c' => 'value'}
	 * @author Pawel Wozniak
	 */
	public static void addFieldValues(SObject sObj, Map<String, Object> fieldsValues) {
		if (fieldsValues == null || fieldsValues.isEmpty()) {
			return;
		}

		for (String field : fieldsValues.keySet()) {
			sObj.put(field, fieldsValues.get(field));
		}
	}

	// Not used yet.
	/**
	 * @description Update existing record or add new to Map of records that will be updated in datapase at the end of trasaction.
	 * @param ofObject Map with records which are cumulated for update
	 * @param key Id of object which we want to check if exists in Map.
	 * @param mapOfFieldValues map with API field name and value to store.
	 *
	 * Example usage:
	 * Map<String, Object> mapOfFieldValues = new Map<String, Object> (Shipping_Terms__c => sa.Shipping_Conditions__c);
	 * updateOrAddRecord(woForUpdate, sa.ParentRecordId, mapOfFieldValues);
	 */
	/* private static void updateOrAddRecord (Map<Id, sObject> sfObject, Id key, Map<String, Object> mapOfFieldValues) {
	        if (sfObject.containsKey(key)) {
	                for (String field : mapOfFieldValues.keySet()) {
	                        sfObject.get(key).put(field, mapOfFieldValues.get(field));
	                }
	        } else {
	                sObject obj = key.getSobjectType().newSObject(key);

	                for (String field : mapOfFieldValues.keySet()) {
	                        obj.put(field, mapOfFieldValues.get(field));
	                }

	                sfObject.put(key, obj);
	        }
	   } */

	public static Set<picklistEntryDetails> getPicklistValues(String objectName, String fieldName) {
		Set<picklistEntryDetails> picklistEntryDetailsSet = new Set<picklistEntryDetails> ();

		Schema.DescribeFieldResult fieldDecribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
		Schema.DisplayType fieldType = fieldDecribe.getType();

		if (fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST) {
			List<Schema.PicklistEntry> pickEntries = fieldDecribe.getPicklistValues();

			for (Schema.PicklistEntry pve : pickEntries) {
				picklistEntryDetails pv = new picklistEntryDetails();
				pv.label = pve.getLabel();
				pv.apiName = pve.getValue();
				pv.isDefault = pve.isDefaultValue();
				picklistEntryDetailsSet.add(pv);
			}
		}

		return picklistEntryDetailsSet;
	}

	public class picklistEntryDetails {
		public String label {get; set;}
		public String apiName {get; set;}
		public boolean isDefault {get; set;}
	}

	/**
	 * @description Send object as JSON to running user email. Use it for debugging.
	 * @param anyObject pass any object, it will be serialized to pretty formatted JSON.
	 */
	public static void debug_sendMeEmailWithObjectAsJSON (Object anyObject) {

		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		List<String> toAddresses = new List<String> {
			UserInfo.getUserEmail()
		};
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Code Debug');
		mail.setSubject('Code Debug');

		mail.setPlainTextBody('======== JSON Start =======\n' + JSON.serializePretty(anyObject) + '\n======== JSON End =======' );
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
	}

	/**
	 * @description Log in debug logs Success and Failed records saves.
	 * Use with: List<Database.SaveResult> saveResults = Database.update(recordToSave, false);
	 */
	public static void logSuccessAndFailedSave(List<Database.SaveResult> saveResults, List<sObject> recordToSave) {

		List<String> saveSuccess = new List<String>();
		Map<String, List<String>> saveErrors = new Map<String, List<String>>();

		for (Integer i = 0; i < saveResults.size(); i++) {
			Database.SaveResult saveRes = saveResults.get(i);
			Id recordId = recordToSave.get(i).Id;
			String recordName = String.valueOf(recordToSave.get(i)?.get('Name'));
			String recordString = recordId + ' ' + '"' + recordName + '"';

			if (saveRes.isSuccess()) {
				String header = '#@# Successfully saved Id: ' + recordString;
				saveSuccess.add(header);
			}
			else {
				List<String> errorsList = new List<String>();
				String header = '#@# Failed to save Id: ' + recordString;

				for (Database.Error err : saveRes.getErrors()) {
					String errString = 'Errors: ' + err.getStatusCode() + ' - ' + err.getMessage();
					errorsList.add(errString);
				}

				saveErrors.put(header, errorsList);
			}
		}

		printSaveResults(saveSuccess, saveErrors);
	}

	/**
	 * @description Actual printing success and failed saves.
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	private static void printSaveResults(List<String> saveSuccess, Map<String, List<String>> saveErrors) {
		if (!saveSuccess.isEmpty()) {
			System.debug('#@# Records updated with success: ');

			for (String header : saveSuccess) {
				System.debug(Logginglevel.INFO, header);
			}
		}

		if (!saveErrors.isEmpty()) {
			System.debug('#@# Those records are not updated because of errors: ');

			for (String header : saveErrors.keySet()) {
				System.debug(Logginglevel.INFO, header);

				for (String errString : saveErrors.get(header)) {
					System.debug(Logginglevel.INFO, errString);
				}
			}
		}
	}

}