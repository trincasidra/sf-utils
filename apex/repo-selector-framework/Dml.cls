public inherited sharing virtual class Dml implements IDml {
    
    @testVisible
    private static Integer maxDmlChunking = 10;

    public virtual List<SObject> getRecords() { return null; }

    public virtual SObject doInsert(SObject record) {
        return this.doInsert(new List<SObject>{record})[0];
    }
    public virtual SObject doInsert(SObject record, Database.DMLOptions dmlOptions) {
        return this.doInsert(new List<SObject>{record}, dmlOptions)[0];
    }
    public virtual List<SObject> doInsert(List<SObject> records) {
        this.sortToPreventChunkingErrors(records);
        Database.insert(records);
        return records;
    }
    public virtual List<SObject> doInsert(List<SObject> records, Database.DMLOptions dmlOptions) {
        this.sortToPreventChunkingErrors(records);
        Database.insert(records, dmlOptions);
        return records;
    }

    public virtual SObject doUpdate(SObject record) { return this.doUpdate(new List<SObject>{record})[0]; }
    public virtual List<SObject> doUpdate(List<SObject> records) {
        this.sortToPreventChunkingErrors(records);
        Database.update(records);
        return records;
    }
    public virtual List<SObject> doUpdate(List<SObject> records, Database.DMLOptions dmlOptions) {
        this.sortToPreventChunkingErrors(records);
        Database.update(records, dmlOptions);
        return records;
    }

    public virtual SObject doUpsert(SObject record) {
        return this.doUpsert(new List<SOBject>{ record })[0];
    }

    public virtual List<SObject> doUpsert(List<SObject> records) {
        this.sortToPreventChunkingErrors(records);
        Database.upsert(records);
        return records;
    }

    public virtual List<SObject> doUpsert(List<SObject> records, Schema.SObjectField externalIdField) {
        Database.upsert(records, externalIdField);
        return records;
    }

    public virtual SObject doUndelete(SObject record) { return this.doUnDelete(new List<SObject>{record})[0]; }
    public virtual List<SObject> doUndelete(List<SObject> records) {
        Database.undelete(records);
        return records;
    }

    public virtual void doDelete(SObject record) { this.doDelete(new List<SObject>{ record }); }
    public virtual void doDelete(List<SObject> records) {
        if(!records.isEmpty()) {
            Database.delete(records);
        }
    }

    public virtual void doHardDelete(SObject record) { this.doHardDelete(new List<SObject>{ record }); }
    public virtual void doHardDelete(List<SObject> records) {
        this.doDelete(records);
        if(!records.isEmpty()) {
            Database.emptyRecycleBin(records);
        }
    }

    private void sortToPreventChunkingErrors(List<SObject> records) {
        // Prevents a chunking error that can occur if SObject types are in the list out of order.
        // No need to sort if the list size is below the limit
        if(records.size() >= maxDmlChunking) {
            records.sort();
        }
    }
}
