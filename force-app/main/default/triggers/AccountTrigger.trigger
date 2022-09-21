trigger AccountTrigger on Account(before insert, before update, after insert, after update, after delete) {

	try {
		new AccountTH().run();
	}
	catch (Exception e) {
		Logger.error('AccountTH failed with exception.', Trigger.new, e);
		Logger.saveLog();
		throw new Utils.triggerException (e, Logger.getTransactionId());
	}

}