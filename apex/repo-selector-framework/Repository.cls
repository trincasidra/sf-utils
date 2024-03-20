public inherited sharing virtual class Repository implements IRepository {
    
    @testVisible
    protected IDml dml;
    private static IRepository repo;

    public static IRepository getInstance() {
        if(repo == null) {
            repo = new Repository();
        }

        return repo;
    }

    @testVisible
    private static IRepository getMockInstance() {
        repo = new RepositoryMock();
        return repo;
    }

    protected Repository() {
        this.dml = new Dml();
    }

    public virtual List<SObject> get(ISelector query) {
        return this.performQuery(query.build(), query.getBindVar());
    }

    private List<SObject> performQuery(String finalQuery, Object bindVar) {
        List<SObject> results = (finalQuery == null) ? new List<SObject>() : Database.query(finalQuery);
        return results;
    }

    public SObject doInsert(SObject record) {
        return this.dml.doInsert(record);
    }
    public SObject doInsert(SObject record, Database.DMLOptions dmlOptions) {
        return this.dml.doInsert(record, dmlOptions);
    }
    public List<SObject> doInsert(List<SObject> records) {
        return this.dml.doInsert(records);
    }
    public List<SObject> doInsert(List<SObject> records, Database.DMLOptions dmlOptions) {
        return this.dml.doInsert(records, dmlOptions);
    }

    public SObject doUpdate(SObject record) {
        return this.dml.doUpdate(record);
    }
    public List<SObject> doUpdate(List<SObject> records) {
        return this.dml.doUpdate(records);
    }
    public List<SObject> doUpdate(List<SObject> records, Database.DMLOptions dmlOptions) {
        return this.dml.doUpdate(records, dmlOptions);
    }

    public SObject doUpsert(SObject record) {
        return this.dml.doUpsert(record);
    }
    public List<SObject> doUpsert(List<SObject> records) {
        return this.dml.doUpsert(records);
    }
    public List<SObject> doUpsert(List<SObject> records, Schema.SObjectField field) {
        return this.dml.doUpsert(records, field);
    }

    public SObject doUndelete(SObject record) {
        return this.dml.doUnDelete(record);
    }
    public List<SObject> doUndelete(List<SObject> records) {
        return this.dml.doUndelete(records);
    }

    public void doDelete(SObject record) {
        this.dml.doDelete(record);
    }
    public void doDelete(List<SObject> records) {
        this.dml.doDelete(records);
    }

    public void doHardDelete(SObject record) {
        this.dml.doHardDelete(record);
    }
    public void doHardDelete(List<SObject> records) {
        this.dml.doHardDelete(records);
    }
}
