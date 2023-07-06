@SuppressWarnings('PMD') // Suppressing all PMD warnings as this class can't be written to meet them.
public virtual class TriggerHandler {

	// static map of handler name, times run() was invoked
	private static Map<String, LoopCount> loopCountMap;
	private static Set<String> bypassedHandlers;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private TriggerContext context;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private Boolean isTriggerExecuting;

	// Cache for handler name
	private String cachedHandlerName;

	// static initialization
	static {
		loopCountMap = new Map<String, LoopCount>();
		bypassedHandlers = new Set<String>();
	}

	// constructor
	public TriggerHandler() {
		this.setTriggerContext();
	}

	public TriggerContext getTriggerContext() {
		return this.context;
	}

	/***************************************
	* public instance methods
	***************************************/

	// main method that will be called during execution
	public void run() {
		String handlerName = getHandlerName();

		if (!validateRun()) {
			return;
		}

		addToLoopCount();

		// dispatch to the correct handler method
		switch on this.context {
			when BEFORE_INSERT {
				System.debug(LoggingLevel.INFO, '############ 👉Enter: ' + handlerName + ' - Before Insert ############');
				Util_CheckRecursive.addTriggerEventCallCount(handlerName);
				this.beforeInsert();
				System.debug(LoggingLevel.INFO, '############ ✋Finished: ' + handlerName + ' - Before Insert ############');
				System.debug(LoggingLevel.INFO, '############ 🔥Aggregated queries: ' + Limits.getAggregateQueries() + ' ############');
				System.debug(LoggingLevel.INFO, '############ ⏰CPU Time used: ' + Limits.getCpuTime() + ' ############');
			}
			when BEFORE_UPDATE {
				System.debug(LoggingLevel.INFO, '############ 👉Enter: ' + handlerName + ' - Before Update ############');
				Util_CheckRecursive.addTriggerEventCallCount(handlerName);
				this.beforeUpdate();
				System.debug(LoggingLevel.INFO, '############ ✋Finished: ' + handlerName + ' - Before Update ############');
				System.debug(LoggingLevel.INFO, '############ 🔥Aggregated queries: ' + Limits.getAggregateQueries() + ' ############');
				System.debug(LoggingLevel.INFO, '############ ⏰CPU Time used: ' + Limits.getCpuTime() + ' ############');
			}
			when BEFORE_DELETE {
				System.debug(LoggingLevel.INFO, '############ 👉Enter: ' + handlerName + ' - Before Delete ############');
				Util_CheckRecursive.addTriggerEventCallCount(handlerName);
				this.beforeDelete();
				System.debug(LoggingLevel.INFO, '############ ✋Finished: ' + handlerName + ' - Before Delete ############');
				System.debug(LoggingLevel.INFO, '############ 🔥Aggregated queries: ' + Limits.getAggregateQueries() + ' ############');
				System.debug(LoggingLevel.INFO, '############ ⏰CPU Time used: ' + Limits.getCpuTime() + ' ############');
			}
			when AFTER_INSERT {
				System.debug(LoggingLevel.INFO, '############ 👉Enter: ' + handlerName + ' - After Insert ############');
				Util_CheckRecursive.addTriggerEventCallCount(handlerName);
				this.afterInsert();
				System.debug(LoggingLevel.INFO, '############ ✋Finished: ' + handlerName + ' - After Insert ############');
				System.debug(LoggingLevel.INFO, '############ 🔥Aggregated queries: ' + Limits.getAggregateQueries() + ' ############');
				System.debug(LoggingLevel.INFO, '############ ⏰CPU Time used: ' + Limits.getCpuTime() + ' ############');
			}
			when AFTER_UPDATE {
				System.debug(LoggingLevel.INFO, '############ 👉Enter: ' + handlerName + ' - After Update ############');
				Util_CheckRecursive.addTriggerEventCallCount(handlerName);
				this.afterUpdate();
				System.debug(LoggingLevel.INFO, '############ ✋Finished: ' + handlerName + ' - After Update ############');
				System.debug(LoggingLevel.INFO, '############ 🔥Aggregated queries: ' + Limits.getAggregateQueries() + ' ############');
				System.debug(LoggingLevel.INFO, '############ ⏰CPU Time used: ' + Limits.getCpuTime() + ' ############');
			}
			when AFTER_DELETE {
				System.debug(LoggingLevel.INFO, '############ 👉Enter: ' + handlerName + ' - After Delete ############');
				Util_CheckRecursive.addTriggerEventCallCount(handlerName);
				this.afterDelete();
				System.debug(LoggingLevel.INFO, '############ ✋Finished: ' + handlerName + ' - After Delete ############');
				System.debug(LoggingLevel.INFO, '############ 🔥Aggregated queries: ' + Limits.getAggregateQueries() + ' ############');
				System.debug(LoggingLevel.INFO, '############ ⏰CPU Time used: ' + Limits.getCpuTime() + ' ############');
			}
			when AFTER_UNDELETE {
				System.debug(LoggingLevel.INFO, '############ 👉Enter: ' + handlerName + ' - After Undelete ############');
				Util_CheckRecursive.addTriggerEventCallCount(handlerName);
				this.afterUndelete();
				System.debug(LoggingLevel.INFO, '############ ✋Finished: ' + handlerName + ' - After Undelete ############');
				System.debug(LoggingLevel.INFO, '############ 🔥Aggregated queries: ' + Limits.getAggregateQueries() + ' ############');
				System.debug(LoggingLevel.INFO, '############ ⏰CPU Time used: ' + Limits.getCpuTime() + ' ############');
			}
		}
	}

	public void setMaxLoopCount(Integer max) {
		String handlerName = getHandlerName();

		if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
			TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
		} else {
			TriggerHandler.loopCountMap.get(handlerName).setMax(max);
		}
	}

	public void clearMaxLoopCount() {
		this.setMaxLoopCount(-1);
	}

	/***************************************
	* public static methods
	***************************************/

	public static void bypass(String handlerName) {
		TriggerHandler.bypassedHandlers.add(handlerName);
	}

	public static void clearBypass(String handlerName) {
		TriggerHandler.bypassedHandlers.remove(handlerName);
	}

	public static Boolean isBypassed(String handlerName) {
		Boolean isHandlerBypassed = TriggerHandler.bypassedHandlers.contains(handlerName);

		if (isHandlerBypassed) {
			System.debug('This trigger handler >' + handlerName + '< is bypassed, skipping execution.');
		}

		return isHandlerBypassed;
	}

	public static void showBypassed() {
		System.debug ('Bypassed triggers handlers: ' + TriggerHandler.bypassedHandlers);
	}

	public static void clearAllBypasses() {
		TriggerHandler.bypassedHandlers.clear();
	}

	/***************************************
	* private instancemethods
	***************************************/

	@TestVisible
	private void setTriggerContext() {
		this.setTriggerContext(null, false);
	}

	@TestVisible
	private void setTriggerContext(String ctx, Boolean testMode) {
		if (!Trigger.isExecuting && !testMode) {
			this.isTriggerExecuting = false;
			return;
		} else {
			this.isTriggerExecuting = true;
		}

		if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
			(ctx != null && ctx == 'before insert')) {
			this.context = TriggerContext.BEFORE_INSERT;
		} else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
				   (ctx != null && ctx == 'before update')) {
			this.context = TriggerContext.BEFORE_UPDATE;
		} else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
				   (ctx != null && ctx == 'before delete')) {
			this.context = TriggerContext.BEFORE_DELETE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
				   (ctx != null && ctx == 'after insert')) {
			this.context = TriggerContext.AFTER_INSERT;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
				   (ctx != null && ctx == 'after update')) {
			this.context = TriggerContext.AFTER_UPDATE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
				   (ctx != null && ctx == 'after delete')) {
			this.context = TriggerContext.AFTER_DELETE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
				   (ctx != null && ctx == 'after undelete')) {
			this.context = TriggerContext.AFTER_UNDELETE;
		}
	}

	// increment the loop count
	@TestVisible
	private void addToLoopCount() {
		String handlerName = getHandlerName();

		if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
			System.debug('Trigger handler: ' + handlerName + ' loop: ' + TriggerHandler.loopCountMap.get(handlerName).getCount());
			Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();

			if (exceeded) {
				Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
				throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
			}
		} else {
			// System.debug ('########### No maximum loop count set for ' + handlerName + ' ############');
		}
	}

	// make sure this trigger should continue to run
	@TestVisible
	private Boolean validateRun() {
		if (!this.isTriggerExecuting || this.context == null) {
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		}

		return !TriggerHandler.isBypassed(getHandlerName());
	}

	@TestVisible
	private String getHandlerName() {
		if (this.cachedHandlerName == null) {
			this.cachedHandlerName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
		}

		return this.cachedHandlerName;
	}

	/***************************************
	* context methods
	***************************************/

	// context-specific methods for override
	@TestVisible
	protected virtual void beforeInsert() {
	}

	@TestVisible
	protected virtual void beforeUpdate() {
	}

	@TestVisible
	protected virtual void beforeDelete() {
	}

	@TestVisible
	protected virtual void afterInsert() {
	}

	@TestVisible
	protected virtual void afterUpdate() {
	}

	@TestVisible
	protected virtual void afterDelete() {
	}

	@TestVisible
	protected virtual void afterUndelete() {
	}

	/***************************************
	* inner classes
	***************************************/

	// inner class for managing the loop count per handler
	@TestVisible
	private class LoopCount {
		private Integer max;
		private Integer count;

		public LoopCount() {
			this.max = 5;
			this.count = 0;
		}

		public LoopCount(Integer max) {
			this.max = max;
			this.count = 0;
		}

		public Boolean increment() {
			this.count++;
			return this.exceeded();
		}

		public Boolean exceeded() {
			return this.max >= 0 && this.count > this.max;
		}

		public Integer getMax() {
			return this.max;
		}

		public Integer getCount() {
			return this.count;
		}

		public void setMax(Integer max) {
			this.max = max;
		}

	}

	// possible trigger contexts
	@TestVisible
	public enum TriggerContext {
		BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
		AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
		AFTER_UNDELETE
	}

	// exception class
	public class TriggerHandlerException extends Exception {}

}