@isTest
private class TriggerManagerTest {

    @isTest
    private static void testManager() {
        Assert.isTrue(TriggerManager.shouldRun(AccountHandler.Class));

        TriggerManager.bypassAll();
        Assert.isFalse(TriggerManager.shouldRun(AccountHandler.Class));

        TriggerManager.reset();
        Assert.isTrue(TriggerManager.shouldRun(AccountHandler.Class));

        TriggerManager.bypass(AccountHandler.Class);
        Assert.isFalse(TriggerManager.shouldRun(AccountHandler.Class));
    }
}
