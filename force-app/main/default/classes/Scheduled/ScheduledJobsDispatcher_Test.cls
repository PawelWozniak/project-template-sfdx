/**
 * @author		Paweł Woźniak
 * @created		2022-09-14
 * @description	Testing ScheduledJobsDispatcher
 */

@isTest
public with sharing class ScheduledJobsDispatcher_Test {

    @isTest
	static void testSchedulerApex() {
		Test.StartTest();

		// Despite of setting strict time for run, scheduled class will be run at time when test is run.
		String jobId = System.schedule('testApexJobScheduler', '0 0 0 3 9 ? 2031', new  ScheduledJobsDispatcher());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
		System.assertEquals('0 0 0 3 9 ? 2031', ct.CronExpression, 'Should be scheduled at given time');
		
		Test.StopTest();
	}
}