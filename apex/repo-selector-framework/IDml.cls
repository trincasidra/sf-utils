public interface IDml {
    SObject doInsert(SObject record);
    SObject doInsert(SObject record, Database.DMLOptions dmlOptions);
    List<SObject> doInsert(List<SObject> recordList);
    List<SObject> doInsert(List<SObject> recordList, Database.DMLOptions dmlOptions);
    SObject doUpdate(SObject record);
    List<SObject> doUpdate(List<SObject> recordList);
    List<SObject> doUpdate(List<SObject> recordList, Database.DMLOptions dmlOptions);
    SObject doUpsert(SObject record);
    List<SObject> doUpsert(List<SObject> recordList);
    List<SObject> doUpsert(List<SObject> recordList, Schema.SObjectField externalIDField);
    SObject doUndelete(SObject record);
    List<SObject> doUndelete(List<SObject> recordList);

    List<SObject> getRecords();

    void doDelete(SObject record);
    void doDelete(List<SObject> recordList);
    void doHardDelete(SObject record);
    void doHardDelete(List<SObject> recordList);
}
