/**
 * @description Deactivate all users except of currently authenticated and those listed.
 * Minumum API level is v57
 */

// Using name instead of Username as it has Org Id.
Set<String> excludedSystemNames = new Set<String> {
	'Automated Process', 'Chatter Expert', 'Integration User', 'Platform Integration User', 'Security User'
};

Set<String> excludedUserLogins = new Set<String>(); // Provide usernames (SF Logins)
String sandboxName = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();
if (sandboxName == null) {
	System.debug('###### This is PROD org. Script stopped ######');
	return;
}
String currentUser = UserInfo.getUserName();

excludedUserLogins.add(currentUser);

List<User> allUsers = new List<User>();
allUsers = [SELECT Id, Name, IsActive, Username
			FROM User
			WHERE Username NOT IN :excludedUserLogins
			AND Name NOT IN :excludedSystemNames];

for (User oneUser : allUsers) {
	oneUser.IsActive = false;
}

List<Database.SaveResult> saveResults = Database.update(allUsers, false);

Utils.logSuccessAndFailedSaveToDebugLog(saveResults, allUsers, new List<String> {'Username', 'IsActive'});