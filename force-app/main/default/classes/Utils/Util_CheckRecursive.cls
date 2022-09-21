/**
 * @author      Paweł Woźniak
 * @created     2021-07-05
 * @description Utility class which help to controls trigger recursive execution. Max trigger depth is 16.
 * @url         https://www.linkedin.com/pulse/salesforce-admins-thoughts-recursion-apex-david-vickers/
 */
public class Util_CheckRecursive {

	/** @description Use this static variable for checking if record was already processed.
	 * Util_CheckRecursive.setOfIDs.add('RecordId');
	 * Util_CheckRecursive.setOfIDs.contains('RecordId');
	 * In test methods clear it after DML. Util_CheckRecursive.setOfIDs.clear();
	 */
	public static Set<String> setOfIDs = new Set<String>();

	// For logic below which counts how many times string was called.
	public static Map<String, Integer> called = new Map<String, Integer> ();

	/**
	 * @description Use this method to simplify check in triggers if such record was processed already.
	 * Example usage:
	 * if (!isFirstCallOf('methodName' + record.Id)) { continue; }
	 * @param input string with unique Id.
	 * @return true if such string was called for the first time. false if it is 2nd any more.
	 */
	public static Boolean isFirstCallOf(String input) {
		if (iveBeenCalled(input) > 1) {
			return false;
		}
		else {
			return true;
		}
	}

	/**
	 *  @description Reset all counters
	 */
	public static void resetAll() {
		called = new Map<String, Integer> ();
	}

	/**
	 *  @description Call this to check how many times trigger was called for records
	 *  @param input String to check
	 *  @return Integer How many times string was called
	 */
	public static Integer numberOfCalls(String input) {
		if (!called.containsKey(input)) {
			return 0;
		}
		else {
			return called.get(input);
		}
	}

	/**
	 *  @description Call this method with record Id to increase count of how many times trigger was called for recordId.
	 *  @param input String with record Id or any other string like method name.
	 *  @return Integer how many times such string was called.
	 */
	public static Integer iveBeenCalled(String input) {
		if (!called.containsKey(input)) {
			called.put(input, 1);
		}
		else {
			Integer i = called.get(input);
			i++;
			called.put(input, i);
		}

		Integer calledCount = called.get(input);
		// System.debug('' + input + ' already called ' + calledCount + ' times');
		return calledCount;
	}

	/* Example usage:
	    for (Opportunity record : opL) {
	        if (Util_CheckRecursive.IveBeenCalled(record.Id) > 10){
	        System.debug('Skipped recursive invocation for Record: ' + record.Id);
	        continue;
	    }
	    // Trigger body here
	   }
	 */

	/**
	 *  @description Count how many times trigger action was run. It decodes name and operation based on passed trigger.
	 *  @param triggerClass Object. Pass "this" and name will be decoded. See Example section below.
	 *  @return Integer how many times trigger class:operation was run.
	 */
	public static Integer addTriggerEventCallCount(Object triggerClass) {
		String triggerName = String.valueOf(triggerClass).split(':') [0].trim();
		return addTriggerEventCallCount(triggerName);
	}

	/**
	 *  @description Count how many times trigger action was run. It decodes name and operation based on passed trigger.
	 * 	@param triggerClassName Pass class name as string.
	 *  @return Integer how many times trigger class:operation was run.
	 */
	public static Integer addTriggerEventCallCount(String triggerClassName) {
		System.TriggerOperation triggerEvent = Trigger.operationType;
		return addTriggerEventCallCount(triggerClassName, triggerEvent);
	}

	@SuppressWarnings('PMD.AvoidDebugStatements')
	private static Integer addTriggerEventCallCount(String triggerClassName, System.TriggerOperation triggerEvent) {
		String input = triggerClassName + ':' + triggerEvent;

		Integer calledCount = iveBeenCalled(input);

		if (calledCount == 1) {
			System.debug(LoggingLevel.INFO, '############ ✔️Trigger: ' + input + ' is run for the 1st time.✔️ ############');
		}

		if (calledCount > 1) {
			System.debug(LoggingLevel.INFO, '############ 🔔Trigger: ' + input + ' is running multiple times: ' + calledCount + '.🔔 ############');
		}

		return calledCount;

	}

	/**
	 * @description Get integer how many times trigger class:operation was run
	 * @param triggerClass Object. Pass "this" and name will be decoded. See Example section below.
	 * @return Integer how many times trigger class:operation was run.
	 */
	public static Integer getTriggerEventCallCount (Object triggerClass) {
		String triggerName = String.valueOf(triggerClass).split(':') [0].trim();
		return getTriggerEventCallCount(triggerName);
	}

	/**
	 * @description Get integer how many times trigger class:operation was run
	 * @param triggerClassName Pass class name as string.
	 * @return Integer how many times trigger class:operation was run.
	 */
	public static Integer getTriggerEventCallCount (String triggerClassName) {
		System.TriggerOperation triggerEvent = Trigger.operationType;
		String input = triggerClassName + ':' + triggerEvent;
		return numberOfCalls(input);
	}

}