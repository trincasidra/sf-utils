public class TestingUtils {

    public class TestException extends Exception {}

    private static Integer startingNumber = 1;

    public static String generateId(Schema.SObjectType sObjectType) {
        String result = String.valueOf(startingNumber++);
        String prefix = sObjectType.getDescribe().getKeyPrefix();
        if (sObjectType == CaseHistory.sObjectType) prefix = '017';
        return prefix + '0'.repeat(12-result.length()) + result;
    }

    public static SObject generateId(SObject objectInstance) {
        if(objectInstance.Id == null) objectInstance.Id = generateId(objectInstance.getSObjectType());
        return objectInstance;
    }

    public static void generateIds(List<SObject> records) {
        for (SObject record : records) {
            if (record.Id == null) generateId(record);
        }
    }
}
