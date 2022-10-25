/**
 * @author		Paweł Woźniak
 * @created		2021-03-29
 * @description	Methods that are frequently used.
 */

@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity')
public without sharing class Utils {

	private static Boolean isSandbox = null;
	private static Boolean isInAsyncContext = null;
	private static Boolean canExecuteDebug = null;

	/**
	 * @description Check if current org is Sandbox
	 * @return true/false
	 */
	public static Boolean isSandbox() {
		if (isSandbox == null) {
			isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
		}

		return isSandbox;
	}

	/**
	 * @description Check if code is already executing in async context. Usefully for triggers which can be run from batch apex on records update.
	 * Use it to avoid "Future method cannot be called from a future or batch method"
	 * if (!isInAsyncContext) { someFutureMethod; } else { otherNonFutureMethod; }
	 * @return boolean
	 */
	public static Boolean isInAsyncContext() {
		if (isInAsyncContext == null) {
			isInAsyncContext = System.isBatch() || System.isFuture() || System.isQueueable();
		}

		return isInAsyncContext;
	}

	/****************************** Get info from Schema ******************************/

	/**
	 * @description Get record Type Id by Name
	 * @param objectName string with object API name.
	 * @param rtName record type name.
	 * @return Id of record type.
	 */
	public static String getRTIdByName(String objectName, String rtName) {
		Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(rtName).getRecordTypeId();
		return recordTypeId;
	}

	/**
	 * @description Get record Type Id by Developer Name
	 * @param objectName string with object API name.
	 * @param rtDeveloperName record type API name.
	 * @return Id of record type.
	 */
	public static String getRTIdByDeveloperName(String objectName, String rtDeveloperName) {
		Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
		return recordTypeId;
	}

	/**
	 * @description Get all values for given picklist field.
	 * @param objectName SF Object API name.
	 * @param fieldName Field API name.
	 * @return picklistEntryDetails custom class with results.
	 */
	public static Set<picklistEntryDetails> getPicklistValues(String objectName, String fieldName) {
		Set<picklistEntryDetails> picklistEntryDetailsSet = new Set<picklistEntryDetails> ();

		Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
		Schema.DisplayType fieldType = fieldDescribe.getType();

		if (fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST) {
			List<Schema.PicklistEntry> pickEntries = fieldDescribe.getPicklistValues();

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

	/**
	 * @description Custom type for returning values of picklist.
	 */
	public class picklistEntryDetails {
		/** @description picklist label visible for user */
		public String label {get; set;}
		/** @description picklist entry API name */
		public String apiName {get; set;}
		/** @description true if it is default entry */
		public boolean isDefault {get; set;}
	}

	/**
	 * @description Use it instead of query with toLabel() to save SOQL queries in triggers.
	 * @param objectName SF Object API name.
	 * @param fieldName Field API name.
	 * @return Map<String, String>
	 */
	public static Map<String, String> getPicklistValuesAPItoLabelMap(String objectName, String fieldName) {
		Map<String, String> picklistApiToLabelMap = new Map<String, String>();
		Set<picklistEntryDetails> pve = getPicklistValues(objectName, fieldName);

		for (picklistEntryDetails ped : pve) {
			picklistApiToLabelMap.put(ped.apiName, ped.label);
		}

		return picklistApiToLabelMap;
	}

	/********************************* Collections ************************************/

	/**
	 * @description Get set of values from list of records.
	 * Example usage:
	 * List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity];
	 * Set<Id> setOfAccountIds = IMUtils.getSetOfIds(opps, 'AccountId');
	 * @param recordsList List of salesforce object records
	 * @param fieldName of the Id type field
	 * @return Set<Id> for selected field across all records.
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
	 * @description Get set of values from list of records. Results may be used with .contains() or as input for another query.
	 * @param recordsList records list from query results
	 * @param fieldName field from which you want to make a Set of values.
	 * @return Set Of Strings cut out from given records list.
	 * Example usage see getSetOfAssignedPermissionSets() in this class.
	 */
	public static Set<String> getSetOfStrings(List<SObject> recordsList, String fieldName) {
		Set<String> setOfValues = new Set<String> ();
		List<String> splitFieldName = new List<String>();

		if (fieldName.contains('.')) {
			splitFieldName = fieldName.split('\\.');
		}

		for (SObject oneRecord : recordsList) {
			String stringFieldValue = '';

			if (splitFieldName.isEmpty()) {
				stringFieldValue = (String) oneRecord.get(fieldName);
			}
			else {
				Integer numOfSegments = splitFieldName.size();
				sObject tmpObject = oneRecord;

				for (Integer i = 0; i < numOfSegments - 1; i++) {
					tmpObject = tmpObject.getSObject(splitFieldName.get(i));
				}

				stringFieldValue = (String) tmpObject.get(splitFieldName.get(numOfSegments - 1));
			}

			if (String.isNotEmpty(stringFieldValue)) {
				setOfValues.add(stringFieldValue);
			}
		}

		return setOfValues;
	}

	/******************************** Custom exceptions ********************************/
	/**
	 * @description Throws AuraHandledException which is shown in message box on Aura/LWC Page.
	 * Use this method to be able check message by e.getMessage() in tests. See Utils_Test.cls
	 * @param userVisibleMessage Any string with message for user.
	 */
	public static void throwAuraHandledException(String userVisibleMessage) {
		AuraHandledException ahe = new AuraHandledException(userVisibleMessage);
		ahe.setMessage(userVisibleMessage);
		throw ahe;
	}

	/**
	 * @description Rethrow apex exception as Aura Handled Exception. Then error message is more clear for user.
	 * @param ex apex exception
	 */
	public static void throwExceptionAsAuraHandled(Exception ex) {
		AuraHandledException ahe = new AuraHandledException(ex.getMessage());
		ahe.setMessage(ex.getMessage());

		if (ex.getCause() != null) {
			ahe.initCause(ex.getCause());
		}

		throw ahe;
	}

	/**
	 * @description Use in triggers to rethrow exception with additional information with Request Id.
	 * With such exception if user send error message screen shoot with request id visible we are able to match it with Runtime Error Logger entry.
	 * Example, put this inside your trigger:
	 * try {
	 *     new TriggerHandlerClassName().run();
	 * } catch (Exception ex) {
	 *	Logger.error('AccountTH failed with exception.', Trigger.new, e);
	 *	Logger.saveLog();
	 *	throw new Utils.triggerException (e, Logger.getTransactionId());
	 *
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
	 * @description Throw custom NullPointer Exception
	 * Use it when catching NullPointerException
	 * Example:
	 *	catch (NullPointerException npe) {
	 *		String msg = '⚠️ If you got this error then... (add here a possible reason for error) ⚠️';
	 *		throw new Utils.CustomNullPointerException(msg, npe);
	 *	}
	 */
	public class CustomNullPointerException extends Exception {}

	/****************************** Debug logs ******************************/

	/**
	 * @description Check if user have permission set: Can Execute Debug Statement⚠
	 * @return boolean
	 */
	public static boolean userCanExecuteDebug() {
		if (canExecuteDebug == null) {
			canExecuteDebug = FeatureManagement.checkPermission('Can_Execute_Debug_Statement');
		}

		return canExecuteDebug;
	}

	/**
	 * @description This method check if current user has rights to see debugs and then display them. Must have permission set: Can Execute Debug Statement⚠
	 * It was introduced to optimize code runtime as debug statements slow down code execution. See link for more details.
	 * @param obj any object.
	 * @link http://bobbuzzard.blogspot.com/2021/05/the-impact-of-systemdebug.html
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void debug(Object obj) {
		if (userCanExecuteDebug()) {
			System.debug(LoggingLevel.ERROR, obj);
		}
	}

	/**
	 * @description This method check if current user has rights to see debugs and then display them. Must have permission set: Can Execute Debug Statement⚠
	 * It was introduced to optimize code runtime as debug statements slow down code execution. See link for more details.
	 * @param logLevel provide logging level. https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_LoggingLevel.htm
	 * @param obj any object.
	 * @link http://bobbuzzard.blogspot.com/2021/05/the-impact-of-systemdebug.html
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void debug(System.LoggingLevel logLevel, Object obj) {
		if (userCanExecuteDebug()) {
			System.debug(logLevel, obj);
		}
	}

	/**
	 *  @description Notify in logs about some important actions like skipping record processing so it can be seen in logs easily why. DO NOT USE it for debugging.
	 *  Example usage: if (some condition check) else {Utils.notifyInDebugLog('Not updating record ' + acc.Name + ' as it don't meet the criteria');}
	 * 	Such notifications will be visible even on lowest details settings. Useful for explanations if you want to see why records were skipped.
	 *  @param message string with message to be shown in debug logs.
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	public static void notifyInDebugLog(String message) {
		System.debug(LoggingLevel.ERROR, '@#@📢' + message);
	}

	/*********************************** Other *****************************************/

	/**
	 * @description Get current quiddity.
	 * @link https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_Quiddity.htm#topic-title
	 * @return quiddity name
	 */
	public static String getQuiddity() {
		return Request.getCurrent().getQuiddity().name();
	}

	/**
	 * @description Make a set with all permission sets assigned to user.
	 * @return Set<String> of assigned permissions.
	 */
	public static Set<String> getSetOfAssignedPermissionSetsToRunningUser() {
		List<PermissionSetAssignment> assignedPermSets = [SELECT Id, PermissionSet.Name
														  FROM PermissionSetAssignment
														  WHERE AssigneeId = :UserInfo.getUserId()];

		return getSetOfStrings(assignedPermSets, 'PermissionSet.Name');

	}

	/**
	 * @description Helper method which add fields values passed to main object creation method by user.
	 * Usefully if you need some non standard values or alter default values.
	 * @param sObj any object. Since sObj is a reference it will be updated without need of returning value.
	 * @param fieldsValues Map with custom field values. Define them as: new Map<String, Object> {'My_Field_name__c' => 'value'}
	 */
	public static void addFieldValues(SObject sObj, Map<String, Object> fieldsValues) {
		if (fieldsValues == null || fieldsValues.isEmpty()) {
			return;
		}

		for (String field : fieldsValues.keySet()) {
			sObj.put(field, fieldsValues.get(field));
		}
	}

	/**
	 * @description Log in debug logs Success and Failed records saves.
	 * Use with: List<Database.SaveResult> saveResults = Database.update(recordToSave, false);
	 * @param saveResults List<Database.SaveResult> save results of given list of records
	 * @param savedRecords List<sObject> List of records which were saved.
	 * @return boolean Were all records saved with success? TRUE - All Succeeded, FALSE - some failed.
	 * Use return result with Nebula Logger to log error in case of failures.
	 */
	public static boolean logSuccessAndFailedSaveToDebugLog(List<Database.SaveResult> saveResults, List<sObject> savedRecords) {

		List<String> saveSuccess = new List<String>();
		Map<String, List<String>> saveErrors = new Map<String, List<String>>();

		for (Integer i = 0; i < saveResults.size(); i++) {
			Database.SaveResult saveRes = saveResults.get(i);
			Id recordId = savedRecords.get(i).Id;
			String recordName = '*Missing Record Name*';
			try {
				recordName = String.valueOf(savedRecords.get(i).get('Name'));
			} catch (System.SObjectException ex) {
				Utils.notifyInDebugLog('Add >Name< to SOQL query to catch record Name and improve logs. [Utils.logSuccessAndFailedSaveToDebugLog]');
			}

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

		printSaveResultsInDebugLog(saveSuccess, saveErrors);

		// Were all records saved with success?
		if (saveErrors.isEmpty()) {
			return true;
		}

		return false;
	}

	/**
	 * @description Actual printing success and failed saves in debug logs
	 * @param saveSuccess List of strings with save results success messages
	 * @param saveErrors List of strings with save results error messages
	 */
	@SuppressWarnings('PMD.AvoidDebugStatements')
	private static void printSaveResultsInDebugLog(List<String> saveSuccess, Map<String, List<String>> saveErrors) {
		if (!saveSuccess.isEmpty()) {
			System.debug('#@# Records updated with success: ');

			for (String header : saveSuccess) {
				System.debug(LoggingLevel.INFO, header);
			}
		}

		if (!saveErrors.isEmpty()) {
			System.debug('#@# Those records are not updated because of errors: ');

			for (String header : saveErrors.keySet()) {
				System.debug(LoggingLevel.INFO, header);

				for (String errString : saveErrors.get(header)) {
					System.debug(LoggingLevel.INFO, errString);
				}
			}
		}
	}

	/**************************** Date and Time conversion ***************************/
	/**
	 * @description Parse given date string.
	 * @param dateString Accepted formats 20.04.2022; 20-04-2022; 20042022
	 * @return Date object
	 */
	public static date parseDateDDMMYYYY(String dateString) {
		if (String.isEmpty(dateString)) {
			return null;
		}

		List<String> dateSplit = new List<String>();

		if (dateString.length() == 10) {
			if (dateString.countMatches('.') == 2) {
				dateSplit = dateString.split('\\.');
			}
			else if (dateString.countMatches('-') == 2) {
				dateSplit = dateString.split('-');
			}
		}
		else if (dateString.length() == 8) {
			dateSplit.add(dateString.left(2));
			dateSplit.add(dateString.mid(2, 2));
			dateSplit.add(dateString.right(4));
		}

		if (dateSplit.isEmpty()) {
			return null;
		}

		Date parsedDate = Date.newInstance(Integer.valueOf(dateSplit.get(2)), Integer.valueOf(dateSplit.get(1)), Integer.valueOf(dateSplit.get(0)));
		return parsedDate;
	}

	/******************************* Methods for Debugging ********************************/

	/**
	 * @description Send object as JSON to running user email. Use it for debugging.
	 * @param anyObject pass any object, it will be serialized to pretty formatted JSON.
	 */
	public static void debug_sendMeEmailWithObjectAsJSON (Object anyObject) {

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
	 * @description Check if running user is Paweł Woźniak.
	 * This method is used in case of debugging to run code only for me.
	 * You may delete that if I am no longer working on this project.
	 * @return boolean
	 */
	public static Boolean isPW() {
		boolean isPW = UserInfo.getUserName().startsWith('pawel.wozniak');
		return isPW;
	}

}