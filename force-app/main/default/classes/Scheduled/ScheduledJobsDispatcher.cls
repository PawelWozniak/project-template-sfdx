/**
 * @author      Paweł Woźniak
 * @created     2022-05-02
 * @description Dispatcher Class for scheduling jobs.
 */

/* Schedule this class from Anonymous Apex using:
   System.schedule('ScheduledJobsDispatcher hh:00 min', '0 00 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:05 min', '0 05 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:10 min', '0 10 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:15 min', '0 15 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:20 min', '0 20 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:25 min', '0 25 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:30 min', '0 30 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:35 min', '0 35 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:40 min', '0 40 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:45 min', '0 45 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:50 min', '0 50 * * * ?', new ScheduledJobsDispatcher());
   System.schedule('ScheduledJobsDispatcher hh:55 min', '0 55 * * * ?', new ScheduledJobsDispatcher());
 */

@SuppressWarnings('PMD.EmptyStatementBlock, PMD.UnusedLocalVariable, PMD.AvoidDebugStatements, PMD.AvoidGlobalModifier, PMD.ApexDoc')
global class ScheduledJobsDispatcher implements Schedulable {

	/** Configuration - here add tasks to execute **/

	public static void runEvery5Minutes() {

	}

	// hh:05, hh:20, hh:35, hh:50
	public static void runEvery15Minutes() {

	}

	// hh:10, hh:40
	public static void runEvery30Minutes() {

	}

	// hh:55
	public static void runEvery60Minutes() {

	}

	/* Scheduler code */
	global void execute(SchedulableContext sc) {
		Datetime now = Datetime.now();
		Integer hour = now.hour();
		Integer minute = now.minute();
		Integer dayOfMonth = now.day();
		Integer dayOfWeek = Integer.valueOf(now.format('u')); // 1 = Monday

		// Test will run on random time so we need a workaround for test coverage
		if (Test.isRunningTest()) {
			minute = 59;
		}

		// Scheduled jobs are launched sometimes with delay of 1-2 minutes.
		switch on minute {

			// Keep it empty for hourly run tasks
			when 0, 1, 2, 3, 4 {
				System.debug('ScheduledJobsDispatcher at hh:00 min');
				runEvery5Minutes();
				// Do not add any jobs here as Schedule section use this time slot
			}

			when 5, 6, 7, 8, 9 {
				System.debug('ScheduledJobsDispatcher at hh:05 min');
				runEvery5Minutes();
				runEvery15Minutes();
			}

			when 10, 11, 12, 13, 14 {
				System.debug('ScheduledJobsDispatcher at hh:10 min');
				runEvery5Minutes();
				runEvery30Minutes();
			}

			when 15, 16, 17, 18, 19 {
				System.debug('ScheduledJobsDispatcher at hh:15 min');
				runEvery5Minutes();
			}

			when 20, 21, 22, 23, 24 {
				System.debug('ScheduledJobsDispatcher at hh:20 min');
				runEvery5Minutes();
				runEvery15Minutes();
			}

			when 25, 26, 27, 28, 29 {
				System.debug('ScheduledJobsDispatcher at hh:25 min');
				runEvery5Minutes();
			}

			when 30, 31, 32, 33, 34 {
				System.debug('ScheduledJobsDispatcher at hh:30 min');
				runEvery5Minutes();
			}

			when 35, 36, 37, 38, 39 {
				System.debug('ScheduledJobsDispatcher at hh:35 min');
				runEvery5Minutes();
				runEvery15Minutes();
			}

			when 40, 41, 42, 43, 44 {
				System.debug('ScheduledJobsDispatcher at hh:40 min');
				runEvery5Minutes();
				runEvery30Minutes();
			}

			when 45, 46, 47, 48, 49 {
				System.debug('ScheduledJobsDispatcher at hh:45 min');
				runEvery5Minutes();
			}

			when 50, 51, 52, 53, 54 {
				System.debug('ScheduledJobsDispatcher at hh:50 min');
				runEvery5Minutes();
				runEvery15Minutes();
			}

			when 55, 56, 57, 58, 59 {
				System.debug('ScheduledJobsDispatcher at hh:55 min');
				runEvery5Minutes();
				runEvery60Minutes();
			}

			when else {
				System.debug('Could not match minutes: ' + minute);
			}
		}

		// Test will run on random time so we need a workaround for test coverage
		if (Test.isRunningTest()) {
			minute = 1;
			hour = 10;
		}

		// Use this section to schedule jobs that should run in off peek hours.
		// Schedule runs at h:00
		if (minute >= 0 && minute <= 4) {
			switch on hour {
				when 20 {
					System.debug('ScheduledJobsDispatcher at 20 hour');
				}
				when 21 {
					System.debug('ScheduledJobsDispatcher at 21 hour');
				}
				when 22 {
					System.debug('ScheduledJobsDispatcher at 22 hour');
				}
				when 23 {
					System.debug('ScheduledJobsDispatcher at 23 hour');
				}
				when 0 {
					System.debug('ScheduledJobsDispatcher at 0 hour');
				}
				when 1 {
					System.debug('ScheduledJobsDispatcher at 1 hour');
				}
				when 2 {
					System.debug('ScheduledJobsDispatcher at 2 hour');
				}
				when 3 {
					System.debug('ScheduledJobsDispatcher at 3 hour');
				}
				when 4 {
					System.debug('ScheduledJobsDispatcher at 4 hour');
				}
				when 5 {
					System.debug('ScheduledJobsDispatcher at 5 hour');
				}
				when 6 {
					System.debug('ScheduledJobsDispatcher at 6 hour');
				}
				when 7 {
					System.debug('ScheduledJobsDispatcher at 7 hour');
				}
				when 8 {
					System.debug('ScheduledJobsDispatcher at 8 hour');
				}
				when 9 {
					System.debug('ScheduledJobsDispatcher at 9 hour');
				}
				when 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 {

				}

				when else {
					System.debug('Could not match hour: ' + hour);
				}
			}
		}
	}

}