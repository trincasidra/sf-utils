public class RepositoryMock extends Repository {
    
    public RepositoryMock() {
        this.dml = new DmlMock();
    }

    public override List<SObject> get(ISelector query) {
        return getResults(query.getType());
    }

    private List<SObject> getResults(SObjectType objectType) {
        List<SObject> resultList = new List<SObject>();
        for(SObject potentialResult : dml.getRecords()) {
            if(potentialResult.getSObjectType() == objectType) {
                resultList.add(potentialResult);
            }
        }
        return resultList;
    }
}
