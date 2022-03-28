public without sharing class Util_DebugLogTools {

	/**
	 * Delete Success debug logs
	 * @description Delete all Debug logs which are success. Use it for cleaning debug log if it is not displaying new logs anymore.
	 * @param olderThanMinutes number of minutes to leave.
	 * @example run as anonymous code: Util_DebugLogTools.deleteSuccessApexLogs(30);
	 * @author Paweł Woźniak
	 */
	@Future(callout = true)
	public static void deleteSuccessApexLogs(Integer olderThanMinutes) {
		List<String> apiCallsList = new List<String> ();
		Set<String> successStatusTranslations = new Set<String> {
			'Success', 'SUCCESS', 'Erfolg'
		};                                                                                  // Put all translations from your SF org. SF saves debug log in user local language.
		List<ApexLog> ApexLoglist = [SELECT Id, StartTime, Status
		                             FROM ApexLog
		                             WHERE Status IN :successStatusTranslations
		                             AND StartTime <:Datetime.now().addMinutes(-olderThanMinutes)
		                             ORDER BY StartTime];

		Set<Id> apexLogIds = new Set<Id> ();

		for (ApexLog apexLogRecord : ApexLoglist) {
			apexLogIds.add(apexLogRecord.Id);
		}

		// Add fake Ids for test
		if (Test.isRunningTest()) {
			Schema.SObjectType sot = ApexLog.getSObjectType();

			for (Integer i = 1; i < 200; i++) {
				String counterValue = String.valueOf(i);
				apexLogIds.add( sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - counterValue.length()) + counterValue);
			}
		}

		List<Set<Id>> chunks = splitIdSetToChunks(apexLogIds, 150); // Chunk size 150 is optimal as more thank 180 gives error "URI too Long".

		for (Set<Id> chunk : chunks) {
			String apiAction = '/composite/sobjects?ids='; // Max len for delete 16 000 characters

			for (Id alId : chunk) {
				apiAction += alId + ',';
			}

			apiAction = apiAction.removeEnd(',');
			HttpResponse res = callSFAPI(apiAction, 'DELETE', null);
		}
	}

	/**
	 * @description  Split big set of Ids to small chunks. Usefull with API calls.
	 * @author Paweł Woźniak
	 */
	private static List<Set<Id>> splitIdSetToChunks(Set<Id> ids, Integer chunkSize) {
		List<Set<Id>> chunks = new List<Set<Id>> ();

		Integer globalCounter = 0;
		Integer counter = 0;
		Integer recordsCount = ids.size();

		Set<Id> oneBatch = new Set<Id> ();

		for (Id oneId : ids) {
			globalCounter++;

			if (counter <= chunkSize && globalCounter < recordsCount) {
				oneBatch.add(oneId);
				counter++;
			}
			else {
				chunks.add(oneBatch.clone());
				counter = 0;
				oneBatch.clear();
			}
		}

		return chunks;
	}

	// Calling SF API internally https://salesforce.stackexchange.com/questions/183578/how-do-i-call-the-salesforce-api-from-a-lightning-component/183692#183692
	private static HttpResponse callSFAPI(String apiAction, String method, String requestBody) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		req.setHeader('Accept', 'application/json');

		// Workaroud for missing PATCH method in SF https://salesforce.stackexchange.com/questions/57215/how-can-i-make-a-patch-http-callout-from-apex
		if (method == 'PATCH') {
			req.setMethod('POST');
			req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v45.0' + apiAction + '?_HttpMethod=PATCH');
		} else {
			req.setMethod(method); // POST, GET, DELETE.
			req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v45.0' + apiAction);
		}

		if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
			req.setHeader('Content-Type', 'application/json');
			req.setBody(requestBody);
		}

		System.debug('Request: ' + req.getBody());
		HttpResponse res = makeHTTPRequest(req);
		System.debug('Response body: ' + res.getBody());
		return res;
	}

	private static HttpResponse makeHTTPRequest(HttpRequest req) {
		Http h = new Http();
		HttpResponse res = h.send(req);

		if (res.getStatusCode() != 200 && res.getStatusCode() != 201 && res.getStatusCode() != 204) {
			System.debug('Call failed: ' + res.getStatusCode() + ' ' + res.getStatus() + '\n' + res.getBody());
		} else {
			System.debug('Call succesfull: ' + res.getStatusCode() + ' ' + res.getStatus());
		}

		return res;
	}

	// Mock for SFApi response. Used for test run.

	public class sfApiResponseMock implements HttpCalloutMock {

		private String responseName = '';
		private String deleteSuccessApexLogs = '';

		public sfApiResponseMock(String responseName) {
			this.responseName = responseName;
		}

		public HTTPResponse respond(HTTPRequest req) {

			System.debug('Inside ' + responseName);
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(200);
			res.setStatus('OK');

			if (responseName == 'deleteSuccessApexLogs') {
				res.setBody(this.deleteSuccessApexLogs);
			}
			else {
				System.debug('##### ^^^ Returning null from mock class. Something went wrong, check your code. ^^^ ######');
				return null;
			}

			return res;

		}

	}
}