/**
 * @author		Paweł Woźniak
 * @created		2021-11-15
 * @isTesting	Util_DebugLogTools
 * @description
 */
@isTest
public with sharing class Util_DebugLogTools_Test {

	@isTest
	private static void deleteSuccessApexLogs() {

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new Util_DebugLogTools.sfApiResponseMock('deleteSuccessApexLogs'));

		Util_DebugLogTools.deleteSuccessApexLogs(30);

		Test.stopTest();
	}

}