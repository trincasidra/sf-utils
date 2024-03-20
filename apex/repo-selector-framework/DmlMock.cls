public virtual class DmlMock extends Dml {
    
    @testVisible
    private Map<Id, SObject> records = new Map<Id, SObject>();
    @testVisible
    private Map<Id, SObject> deletedRecords = new Map<Id, SObject>();

    public override List<SObject> getRecords() {
        return records.values();
    }

    public override List<SObject> doInsert(List<SObject> recordList) {
        TestingUtils.generateIds(recordList);
        records.putAll(recordList);
        return recordList;
    }

    public override List<SObject> doInsert(List<SObject> recordList, Database.DMLOptions dmlOptions) {
        return doInsert(recordList);
    }

    public override List<SObject> doUpdate(List<SObject> recordList) {
        for (SObject record : recordList) {
            if (record.Id == null) { throw new DmlException(); }
        }
        records.putAll(recordList);
        return recordList;
    }

    public override List<SObject> doUpdate(List<SObject> recordList, Database.DMLOptions dmlOptions) {
        return doUpdate(recordList);
    }

    public override List<SObject> doUpsert(List<SObject> recordList) {
        for (SObject record : recordList) {
            if (record.Id == null) { TestingUtils.generateId(record); }
        }
        TestingUtils.generateIds(recordList);
        records.putAll(recordList);
        return recordList;
    }

    public override List<SObject> doUpsert(List<SObject> recordList, Schema.SObjectField field) {
        return this.doUpsert(recordList);
    }

    public override List<SObject> doUndelete(List<SObject> recordList) {
        for (SObject record : recordList) {
            if (record.Id == null) { throw new DmlException(); }
            SObject undeletedRecord = deletedRecords.remove(record.Id);
            if (undeletedRecord == null) { throw new DmlException(); }
            records.put(undeletedRecord.Id, undeletedRecord);
        }
        return recordList;
    }

    public override void doDelete(List<SObject> recordList) {
        for (SObject record : recordList) {
            if (record.Id == null) { throw new DmlException(); }
            SObject deletedRecord = records.remove(record.Id);
            if (deletedRecord == null) { throw new DmlException(); }
            deletedRecords.put(deletedRecord.Id, deletedRecord);
        }
    }

    public override void doHardDelete(List<SObject> recordList) {
        this.doDelete(recordList);
        for (SObject record : recordList) {
            deletedRecords.remove(record.Id);
        }
    }
}
