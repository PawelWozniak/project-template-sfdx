@SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexDoc')

@isTest
public class TestDataFactory {

	// Lead

	/**
	 * @description create Lead and specify additional field values on create.
	 * @param numRecords how many records should be created
	 * @param fieldsValues custom values for fields
	 */
	public static List<Lead> createLeads(Integer numRecords, Map<String, Object> fieldsValues) {

		List<Lead> Leads = new List<Lead>();

		for (Integer i = 0; i < numRecords; i++) {
			Lead oneRecord = new Lead(
				FirstName = 'Mike',
				LastName = 'Leader',
				Company = 'Mike Leader Tools inc.'
				);

			Utils.addFieldValues(oneRecord, fieldsValues);

			Leads.add(oneRecord);
		}

		insert Leads;

		return Leads;
	}

	// Account

	/**
	 * @description create Accounts and specify additional field values on create.
	 * @param numRecords how many records should be created
	 * @param fieldsValues custom values for fields
	 */
	public static List<Account> createAccounts(Integer numRecords, Map<String, Object> fieldsValues) {
		return createAccounts(numRecords, fieldsValues, true);
	}

	public static List<Account> createAccounts(Integer numRecords, Map<String, Object> fieldsValues, Boolean toInsert) {
		List<Account> accts = new List<Account>();

		for (Integer i = 0; i < numRecords; i++) {
			Account acc = new Account(
				Name = 'Account_' + i,
				Type = Constants.ACCOUNT_TYPE_PARTNER,
				BillingCountry = 'Germany',
				BillingCity = 'Berlin',
				BillingStreet = 'BillingStreet ' + i,
				BillingPostalCode = '05-00' + i);

			Utils.addFieldValues(acc, fieldsValues);

			accts.add(acc);
		}

		if (toInsert) {
			insert accts;
		}

		return accts;
	}

	// Contact

	/**
	 * @description create Contacts and specify additional field values on create.
	 * @param numRecords how many records should be created
	 * @param acc Account object for which contacts should be added.
	 * @param fieldsValues custom values for fields
	 */
	public static List<Contact> createContacts(Integer numRecords, Account acc, Map<String, Object> fieldsValues) {

		List<Contact> contacts = new List<Contact>();

		for (Integer i = 0; i < numRecords; i++) {
			Contact cnt = new Contact(
				FirstName = 'John',
				LastName = 'Tester ' + acc.Name,
				AccountId = acc.Id,
				Status__c = 'Active');

			Utils.addFieldValues(cnt, fieldsValues);

			contacts.add(cnt);
		}

		insert contacts;

		return contacts;
	}
}