// Replace with actual object type.
public class SelectorTemplate extends Selector {

    private SObjectType getObjectType() {
        return MyObject__c.SObjectType;
    }

    private List<String> getObjectFields() {
        return new List<String>{
            'Id',
            'Name',
            'CreatedDate',
            'OwnerId'
        };
    }
}
