public virtual class Selector implements ISelector {
    
    private final SObjectType objectType;
    private final List<String> objectFields;

    private Boolean isSubquery = false;
    private String relationshipName;
    private Integer queryLimit = 50000;

    private List<QueryCondition> queryConditions = new List<QueryCondition>();
    private List<String> orders = new List<String>();
    private List<ISelector> subqueries = new List<ISelector>();

    private Boolean shortCircuit = false;
    private Object bindVar;

    public Selector() {
        this.objectType = getObjectType();
        this.objectFields = getObjectFields();
    }

    private virtual SObjectType getObjectType() { return null; }

    private virtual List<String> getObjectFields() { return null; }

    public SObjectType getType() {
        return objectType;
    }

    public Object getBindVar() {
        return bindVar;
    }

    private virtual String getSelectAndFrom() {
        return 'SELECT ' + addSelectFields() + '\nFROM ' + (isSubquery ? relationshipName : objectType.getDescribe().getName());
    }

    private String addSelectFields() {
        Set<String> fieldStrings = new Set<String>{ 'Id' };
        for (String objectField : objectFields) {
            fieldStrings.add(objectField);
        }
        for (ISelector subquery : subqueries) {
            fieldStrings.add('(' + subquery.build() + ')');
        }
        return String.join(new List<String>(fieldStrings), ', ');
    }

    public ISelector withSubquery(ISelector subquery) {
        this.subqueries.add(subquery);
        return this;
    }

    public ISelector whereOr(List<QueryCondition> orConditions) {
        return whereIs(QueryCondition.orQuery(orConditions));
    }

    public ISelector whereOr(QueryCondition condition1, QueryCondition condition2) {
        return whereIs(QueryCondition.orQuery(condition1, condition2));
    }

    public ISelector whereEquals(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.equals(field, predicate));
    }
    public ISelector whereEquals(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.equals(field, predicates));
    }
    public ISelector whereEquals(String fieldName, Object predicate) {
        return whereIs(QueryCondition.equals(fieldName, predicate));
    }
    public ISelector whereEquals(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.equals(fieldName, predicates));
    }

    public ISelector whereNotEquals(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.notEquals(field, predicate));
    }
    public ISelector whereNotEquals(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.notEquals(field, predicates));
    }
    public ISelector whereNotEquals(String fieldName, Object predicate) {
        return whereIs(QueryCondition.notEquals(fieldName, predicate));
    }
    public ISelector whereNotEquals(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.notEquals(fieldName, predicates));
    }

    public ISelector whereGreaterThan(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.greaterThan(field, predicate));
    }
    public ISelector whereGreaterThan(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.greaterThan(field, predicates));
    }
    public ISelector whereGreaterThan(String fieldName, Object predicate) {
        return whereIs(QueryCondition.greaterThan(fieldName, predicate));
    }
    public ISelector whereGreaterThan(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.greaterThan(fieldName, predicates));
    }

    public ISelector whereGreaterThanOrEqual(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.greaterThanOrEqual(field, predicate));
    }
    public ISelector whereGreaterThanOrEqual(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.greaterThanOrEqual(field, predicates));
    }
    public ISelector whereGreaterThanOrEqual(String fieldName, Object predicate) {
        return whereIs(QueryCondition.greaterThanOrEqual(fieldName, predicate));
    }
    public ISelector whereGreaterThanOrEqual(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.greaterThanOrEqual(fieldName, predicates));
    }

    public ISelector whereLessThan(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.lessThan(field, predicate));
    }
    public ISelector whereLessThan(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.lessThan(field, predicates));
    }
    public ISelector whereLessThan(String fieldName, Object predicate) {
        return whereIs(QueryCondition.lessThan(fieldName, predicate));
    }
    public ISelector whereLessThan(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.lessThan(fieldName, predicates));
    }

    public ISelector whereLessThanOrEqual(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.lessThanOrEqual(field, predicate));
    }
    public ISelector whereLessThanOrEqual(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.lessThanOrEqual(field, predicates));
    }
    public ISelector whereLessThanOrEqual(String fieldName, Object predicate) {
        return whereIs(QueryCondition.lessThanOrEqual(fieldName, predicate));
    }
    public ISelector whereLessThanOrEqual(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.lessThanOrEqual(fieldName, predicates));
    }

    public ISelector whereLike(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.likeQuery(field, predicate));
    }
    public ISelector whereLike(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.likeQuery(field, predicates));
    }
    public ISelector whereLike(String fieldName, Object predicate) {
        return whereIs(QueryCondition.likeQuery(fieldName, predicate));
    }
    public ISelector whereLike(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.likeQuery(fieldName, predicates));
    }

    public ISelector whereNotLike(SObjectField field, Object predicate) {
        return whereIs(QueryCondition.notLike(field, predicate));
    }
    public ISelector whereNotLike(SObjectField field, List<Object> predicates) {
        return whereIs(QueryCondition.notLike(field, predicates));
    }
    public ISelector whereNotLike(String fieldName, Object predicate) {
        return whereIs(QueryCondition.notLike(fieldName, predicate));
    }
    public ISelector whereNotLike(String fieldName, List<Object> predicates) {
        return whereIs(QueryCondition.notLike(fieldName, predicates));
    }

    public ISelector whereIs(QueryCondition newCondition) {
        return whereIs(new List<QueryCondition>{ newCondition });
    }

    public ISelector whereIs(List<QueryCondition> newConditions) {
        for (QueryCondition newCondition : newConditions) {
            queryConditions.add(newCondition);
        }
        return this;
    }

    public ISelector orderBy(SObjectField objectField) {
        return orderByAsc(objectField);
    }

    public ISelector orderByAsc(SObjectField objectField) {
        return orderBy(true, objectField);
    }

    public ISelector orderByDesc(SObjectField objectField) {
        return orderBy(false, objectField);
    }

    public ISelector orderBy(Boolean isAscending, SObjectField objectField) {
        orders.add(objectField.getDescribe().getName() + (isAscending ? ' ASC' : ' DESC'));
        return this;
    }

    public ISelector setLimit(Integer newLimit) {
        queryLimit = newLimit;
        return this;
    }

    public ISelector setParentRelationship(String parentRelationship) {
        isSubquery = true;
        relationshipName = parentRelationship;
        return this;
    }

    private String getWheres() {
        List<String> wheres = new List<String>();
        for (QueryCondition queryCondition : this.queryConditions) {
            if (queryCondition.isEmpty()) {
                shortCircuit = true;
            } else if(this.bindVar == null) {
                // at some point, it would be nice to support multiple bind variables
                // for collection-based arguments; for now, we only support them for NOT LIKE
                // arguments - and even then, only once per full query
                // multiple NOT LIKEs (for different fields) are supported
                // by chaining queries together, if necessary
                this.bindVar = queryCondition.getBindVars();
            }
            wheres.add(queryCondition.toString());
        }
        return '\nWHERE ' + String.join(wheres, '\nAND ');
    }

    private String getOrders() {
        return 'ORDER BY ' + String.join(orders, ', ');
    }

    private String getLimit() {
        return 'LIMIT '+queryLimit;
    }

    public String build() {
        List<String> queryParts = new List<String>();
        queryParts.add(getSelectAndFrom());
        if (!queryConditions.isEmpty()) { queryParts.add(getWheres()); }
        if (!orders.isEmpty()) { queryParts.add(getOrders()); }
        if (shortCircuit) { return null; }
        queryParts.add(getLimit());
        return String.join(queryParts, ' ');
    }
}
