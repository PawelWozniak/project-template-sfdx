
Id masterId = '';
String duplicate1Id = '';
String duplicate2Id = '';

mergeRecords(masterId, duplicate1Id, duplicate2Id);

/**
 *   @description Merge up to two records into master record. 
 *   It reparents all child records from duplicates to master.
 *  @param masterId record which is master and will stay after merging
 *  @param duplicate1Id first duplicated record
 *  @param duplicate2Id second duplicated record, optional. Can be empty string or null if not used.
 *  @since 2023-05-06
 */
private static Boolean mergeRecords (Id masterId, String duplicate1Id, String duplicate2Id) {

	// Get object name
	Schema.SObjectType objectName = masterId.getSobjectType();
    System.debug('Detected sObject type is: ' + objectName);

    // Query for master record
    String queryForMasterRecord = 'SELECT Id FROM ' + objectName +  ' WHERE Id = :masterId';
	List<sObject> masterRecord = Database.query(queryForMasterRecord);
	if (masterRecord.isEmpty()) {
		System.debug('⚠️Master record not found. Check if you have provided a valid Id or runing it on the proper Org. (PROD/sandbox)');
		return null;
	}

    // Create list of duplicates
	List<Id> duplicates = new List<Id>();

	if (!String.isBlank(duplicate1Id)) duplicates.add(Id.valueOf(duplicate1Id));
	if (!String.isBlank(duplicate2Id)) duplicates.add(Id.valueOf(duplicate2Id));

    // Merge records into master
	List<Database.MergeResult> mergeResults = Database.merge(masterRecord.get(0), duplicates, false);
	return logMergeResults(mergeResults);

}

/**
 * @description Parse Merge results and write to debug log.
 */
private static Boolean logMergeResults(List<Database.MergeResult> mergeResults) {
	Boolean hasErrors = false;

	for (Database.MergeResult mergeResult : mergeResults) {
        System.debug('👉 Merge on sObject: ' + mergeResult.getId().getSobjectType() + '.');
		if (mergeResult.isSuccess()) {
			System.debug('##################### ✅SUCCESS MERGE RESULTS ############################');
			// Get the master ID from the result
			System.debug('Master record ID: ' + mergeResult.getId());

			// Get the IDs of the merged records
			System.debug('IDs of merged records: ' + mergeResult.getMergedRecordIds());

			// Get the ID of the reparented record
			System.debug('Reparented records ID: ' + mergeResult.getUpdatedRelatedIds());

		}
		else {
			System.debug('############################# ❌MERGE ERRORS ############################');

			for (Database.Error err : mergeResult.getErrors()) {
				// Write each error to the debug output
				String errString = 'Errors: ' + err.getStatusCode() + ' - ' + err.getMessage();
				System.debug(errString);
			}

			hasErrors = true;
		}

		System.debug('################################# END #################################');
        System.debug('👈');
	}

	return hasErrors;
}