public virtual class QueryCondition {
    
    private enum Operator {
        EQUALS,
        NOT_EQUALS,
        LESS_THAN,
        LESS_THAN_OR_EQUAL,
        GREATER_THAN,
        GREATER_THAN_OR_EQUAL,
        ALIKE, // like is a reserved word
        NOT_LIKE
    }

    private final String fieldName;
    private final Operator operator;
    private final List<Object> predicates;

    private Boolean isIterable = false;

    private static final String EMPTY = '\'\'';

    public static QueryCondition equals(SObjectField field, Object predicate) {
        return equals(field, new List<Object>{ predicate });
    }

    public static QueryCondition equals(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.EQUALS, predicates);
    }

    public static QueryCondition equals(String fieldName, Object predicate) {
        return equals(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition equals(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.EQUALS, predicates);
    }

    public static QueryCondition isNull(SObjectField field) {
        return new QueryCondition(field, Operator.EQUALS, null);
    }

    public static QueryCondition isNull(String fieldName) {
        return new QueryCondition(fieldName, Operator.EQUALS, null);
    }

    public static QueryCondition notNull(SObjectField field) {
        return new QueryCondition(field, Operator.NOT_EQUALS, null);
    }

    public static QueryCondition notNull(String fieldName) {
        return new QueryCondition(fieldName, Operator.NOT_EQUALS, null);
    }

    public static QueryCondition notEquals(SObjectField field, Object predicate) {
        return notEquals(field, new List<Object>{ predicate });
    }

    public static QueryCondition notEquals(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.NOT_EQUALS, predicates);
    }

    public static QueryCondition notEquals(String fieldName, Object predicate) {
        return notEquals(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition notEquals(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.NOT_EQUALS, predicates);
    }

    public static QueryCondition lessThan(SObjectField field, Object predicate) {
        return lessThan(field, new List<Object>{ predicate });
    }

    public static QueryCondition lessThan(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.LESS_THAN, predicates);
    }

    public static QueryCondition lessThan(String fieldName, Object predicate) {
        return lessThan(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition lessThan(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.LESS_THAN, predicates);
    }

    public static QueryCondition lessThanOrEqual(SObjectField field, Object predicate) {
        return lessThanOrEqual(field, new List<Object>{ predicate });
    }

    public static QueryCondition lessThanOrEqual(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.LESS_THAN_OR_EQUAL, predicates);
    }

    public static QueryCondition lessThanOrEqual(String fieldName, Object predicate) {
        return lessThanOrEqual(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition lessThanOrEqual(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.LESS_THAN_OR_EQUAL, predicates);
    }

    public static QueryCondition greaterThan(SObjectField field, Object predicate) {
        return greaterThan(field, new List<Object>{ predicate });
    }

    public static QueryCondition greaterThan(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.GREATER_THAN, predicates);
    }
    
    public static QueryCondition greaterThan(String fieldName, Object predicate) {
        return greaterThan(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition greaterThan(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.GREATER_THAN, predicates);
    }

    public static QueryCondition greaterThanOrEqual(SObjectField field, Object predicate) {
        return greaterThanOrEqual(field, new List<Object>{ predicate });
    }

    public static QueryCondition greaterThanOrEqual(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.GREATER_THAN_OR_EQUAL, predicates);
    }

    public static QueryCondition greaterThanOrEqual(String fieldName, Object predicate) {
        return greaterThanOrEqual(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition greaterThanOrEqual(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.GREATER_THAN_OR_EQUAL, predicates);
    }

    // like is a reserved keyword
    public static QueryCondition likeQuery(SObjectField field, Object predicate) {
        return likeQuery(field, new List<Object>{ predicate });
    }

    public static QueryCondition likeQuery(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.ALIKE, predicates);
    }

    public static QueryCondition likeQuery(String fieldName, Object predicate) {
        return likeQuery(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition likeQuery(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.ALIKE, predicates);
    }

    public static QueryCondition notLike(SObjectField field, Object predicate) {
        return notLike(field, new List<Object>{ predicate });
    }

    public static QueryCondition notLike(SObjectField field, List<Object> predicates) {
        return new QueryCondition(field, Operator.NOT_LIKE, predicates);
    }

    public static QueryCondition notLike(String fieldName, Object predicate) {
        return notLike(fieldName, new List<Object>{ predicate });
    }

    public static QueryCondition notLike(String fieldName, List<Object> predicates) {
        return new QueryCondition(fieldName, Operator.NOT_LIKE, predicates);
    }

    // or is a reserved keyword
    public static QueryCondition orQuery(QueryCondition innerQuery, QueryCondition secondInnerQuery) {
        return orQuery(new List<QueryCondition>{ innerQuery, secondInnerQuery });
    }

    public static QueryCondition orQuery(List<QueryCondition> innerQueries) {
        return new OrQuery(innerQueries);
    }

    private class OrQuery extends QueryCondition {
        private final List<QueryCondition> queries;
        private final String orDelimiter = ' OR ';

        public OrQuery(List<QueryCondition> queries) {
            super();
            this.queries = queries;
        }

        public override String toString() {
            String baseString = '(';
            for (QueryCondition innerQuery : this.queries) {
                baseString += innerQuery.toString() + this.orDelimiter;
            }
            return baseString.removeEnd(this.orDelimiter) + ')';
        }
    }

    public static QueryCondition andQuery(QueryCondition innerQuery, QueryCondition secondInnerQuery) {
        return andQuery(new List<QueryCondition>{ innerQuery, secondInnerQuery });
    }

    public static QueryCondition andQuery(List<QueryCondition> innerQueries) {
        return new AndQuery(innerQueries);
    }

    private class AndQuery extends QueryCondition {
        private final List<QueryCondition> queries;
        private final String andDelimiter = ' AND ';

        public AndQuery(List<QueryCondition> queries) {
            super();
            this.queries = queries;
        }

        public override String toString() {
            String baseString = '(';
            for (QueryCondition innerQuery : this.queries) {
                baseString += innerQuery.toString() + this.andDelimiter;
            }
            return baseString.removeEnd(this.andDelimiter) + ')';
        }
    }

    protected QueryCondition() {
    }

    private QueryCondition(String fieldName, Operator operator, List<Object> predicates) {
        this.fieldName = fieldName;
        this.operator = operator;
        this.predicates = predicates;
    }

    private QueryCondition(SObjectField field, Operator operator, List<Object> predicates) {
        this(field.getDescribe().getName(), operator, predicates);
    }

    public List<Object> getBindVars() {
        return this.predicates;
    }

    public virtual override String toString() {
        String predicateValue = this.getPredicate(this.predicates);
        this.isIterable = this.isIterable || this.predicates.size() > 1;
        if (this.operator == QueryCondition.Operator.NOT_LIKE) {
            String endingString = ' ' + (this.isIterable ? ':bindVar' : predicateValue);
            // who knows why this is the format they wanted
            return '(' + String.format(this.getOperator(), new List<String>{ this.fieldName }) + endingString + ')';
        }
        return this.fieldName + ' ' + this.getOperator() + ' ' + predicateValue;
    }

    public Boolean isEmpty() {
        return this.getPredicate(this.predicates) == EMPTY;
    }

    public Boolean equals(Object thatObject) {
        if (thatObject instanceof QueryCondition) {
            QueryCondition that = (QueryCondition) thatObject;
            return this.toString() == that.toString();
        }

        return false;
    }

    private String getOperator() {
        String returnVal = '';
        switch on this.operator {
            when EQUALS {
                returnVal = isIterable ? 'in' : '=';
            }
            when NOT_EQUALS {
                returnVal = isIterable ? 'not in' : '!=';
            }
            when LESS_THAN {
                returnVal = '<';
            }
            when LESS_THAN_OR_EQUAL {
                returnVal = '<=';
            }
            when GREATER_THAN {
                returnVal = '>';
            }
            when GREATER_THAN_OR_EQUAL {
                returnVal = '>=';
            }
            when ALIKE {
                returnVal = 'like';
            }
            when NOT_LIKE {
                returnVal = 'not {0} like';
            }
        }
        return returnVal;
    }

    private String getPredicate(Object predicate) {
        if (predicate == null) {
            return 'null';
        } else if (predicate instanceof Date) {
            // Datetime is not an instanceof Date
            Datetime dt = (Datetime) predicate;
            return dt.format('yyyy-MM-dd', 'GMT');
        } else if (predicate instanceof Datetime) {
            // the most annoying one
            Datetime dt = (Datetime) predicate;
            return dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
        } else if (predicate instanceof List<Object>) {
            List<Object> localPredicates = (List<Object>) predicate;
            if (localPredicates.isEmpty()) {
                return EMPTY;
            }
            List<String> innerStrings = new List<String>();
            for (Object innerPred : localPredicates) {
                // recurse for string value
                String innerString = this.getPredicate(innerPred);
                innerStrings.add(innerString);
            }
            String start = innerStrings.size() > 1 ? '(' : '';
            String ending = innerStrings.size() > 1 ? ')' : '';
            return start + String.join(innerStrings, ',') + ending;
        } else if (predicate instanceof String) {
            String input = (String) predicate;
            return '\'' + String.escapeSingleQuotes(input) + '\'';
        }

        // it could still be a Set, which is notoriously hard to detect for
        // due to instanceof Iterable<String> returning false for Sets, despite
        // Set.class implementing the interface ...
        try {
            Iterable<Object> objectSet = (Iterable<Object>) predicate;
            List<String> innerList = new List<String>();
            Iterator<Object> objectSetIterator = objectSet.iterator();
            while (objectSetIterator.hasNext()) {
                innerList.add(String.valueOf(objectSetIterator.next()));
            }
            this.isIterable = innerList.size() > 1;

            return this.getPredicate(innerList);
        } catch (Exception ex) {
            // do nothing, it didn't work
        }
        return String.valueOf(predicate);
    }
}
