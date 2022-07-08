trigger AccountTrigger on Account(before insert, before update, after insert, after update, after delete) {

	new AccountTH().run();

}