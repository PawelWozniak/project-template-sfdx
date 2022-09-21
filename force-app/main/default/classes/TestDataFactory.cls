@SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexDoc')

@isTest
public class TestDataFactory {

	/**
	 * @description create accounts and specify additional field values on create.
	 * @param numAccts how many accounts should be created
	 * @param fieldsValues custom values for fields
	 */
	public static List<Account> createAccounts(Integer numAccts, Map<String, Object> fieldsValues) {
		return createAccounts(numAccts, fieldsValues, true);
	}

	public static List<Account> createAccounts(Integer numAccts, Map<String, Object> fieldsValues, Boolean toInsert) {
		List<Account> accts = new List<Account>();

		for (Integer i = 0; i < numAccts; i++) {
			Account a = new Account(
				Name = 'Account' + i,
				Type = Constants.ACCOUNT_TYPE_PARTNER,
				BillingCountry = 'Germany',
				BillingCity = 'Munich' + i,
				BillingStreet = 'BillingStreet' + i,
				BillingPostalCode = 'BillingPostalCode' + i);

			Utils.addFieldValues(a, fieldsValues);

			accts.add(a);
		}

		if (toInsert) {
			insert accts;
		}

		return accts;
	}

}