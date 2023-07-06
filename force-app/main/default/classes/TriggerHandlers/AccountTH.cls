/**
 * @author		Paweł Woźniak
 * @created		2022-07-08
 * @description	Trigger Handler class for object Account (Account).
 */

@SuppressWarnings('PMD.EmptyStatementBlock')
public without sharing class AccountTH extends TriggerHandler {

	@TestVisible
	private static boolean forceException = false;

	private List<Account> newRecords;
	private Map<Id, Account> newRecordsMap;
	private Map<Id, Account> oldRecordsMap;

	/** @description Constructor. On class instantiation fill in class variables with values from Trigger global variable */
	public AccountTH() {
		this.newRecords = (List<Account>) Trigger.new;
		this.newRecordsMap = (Map<Id, Account>) Trigger.newMap;
		this.oldRecordsMap = (Map<Id, Account>) Trigger.oldMap;
	}

	/* Before */
	// Insert. newRecords
	public override void beforeInsert() {
		// Added for better test coverage of Trigger class. Do not use it for any other purpose.
		if (forceException == true) { throw new Utils.CustomNullPointerException(); }
	}

	// Update. newRecords, newRecordsMap, oldRecordsMap
	public override void beforeUpdate() {

	}

	/* After */
	// Insert. newRecords, newRecordsMap
	public override void afterInsert() {

	}

	// Update. newRecords, newRecordsMap, oldRecordsMap
	public override void afterUpdate() {

	}

	/* Delete */
	// Before. oldRecordsMap
	public override void beforeDelete() {

	}

	// After: oldRecordsMap
	public override void afterDelete() {

	}

	/* UnDelete */
	// After: newRecords, newRecordsMap
	public override void afterUndelete() {

	}

	/********** Here add full logic. **********/

}