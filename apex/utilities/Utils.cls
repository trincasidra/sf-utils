public without sharing class Utils {

    public static Datetime safeParseDatetime(String dt) {
        try {
            return Datetime.parse(dt);
        } catch (exception e) {}
        try {
            return Datetime.valueOfGmt(dt);
        } catch (exception e) {}
        return parseDatetimeAsJson(dt);
    }

    public static Datetime parseDatetimeAsJson(String dt) {
        return (Datetime)JSON.deserialize('"' + dt + '"', Datetime.class);
    }

    public static List<Id> filter(List<String> idsToFilter, Schema.SObjectType objectType) {
        return filter((List<Id>)idsToFilter, objectType);
    }

    public static List<Id> filter(List<Id> idsToFilter, Schema.SObjectType objectType) {
        List<Id> filteredIds = new List<Id>();
        for (Id idToFilter : idsToFilter) {
            if (idToFilter.getSobjectType() == objectType) filteredIds.add(idToFilter);
        }
        return filteredIds;
    }

    public static List<SObject> filter(List<SObject> sobjectsToFilter, Schema.SObjectType objectType) {
        List<SObject> filteredSobjects = new List<SObject>();
        for (SObject sobjectToFilter : sobjectsToFilter) {
            if (sobjectToFilter.getSobjectType() == objectType) filteredSobjects.add(sobjectToFilter);
        }
        return filteredSobjects;
    }

    public static SObject getOrInitRecordFromMap(Id recordId, Map<Id, SObject> existingRecordsById) {
        SObject record;
        if (existingRecordsById.containsKey(recordId)) record = existingRecordsById.get(recordId);
        else {
            record = recordId.getSObjectType().newSObject();
            record.Id = recordId;
        }
        return record;
    }

    public static List<String> getFieldAsList(List<SObject> records, Schema.SObjectField field) {
        return getFieldAsList(records, field.getDescribe().getName(), false);
    }

    public static List<String> getFieldAsList(List<SObject> records, Schema.SObjectField field, Boolean purgeNulls) {
        return getFieldAsList(records, field.getDescribe().getName(), purgeNulls);
    }

    public static List<String> getFieldAsList(List<SObject> records, String fieldName) {
        return getFieldAsList(records, fieldName, false);
    }

    public static List<String> getFieldAsList(List<SObject> records, String fieldName, Boolean purgeNulls) {
        List<String> values = new List<String>();
        for (SObject record : records) {
            if (purgeNulls && record.get(fieldName) == null) continue;
            values.add((String)record.get(fieldName));
        }
        return values;
    }

    public static Map<String, List<SObject>> groupByField(List<SObject> records, Schema.SobjectField field) {
        return groupByField(records, field.getDescribe().getName());
    }

    public static Map<String, List<SObject>> groupByField(List<SObject> records, String fieldName) {
        Map<String, List<SObject>> groupedRecords = new Map<String, List<SObject>>();
        for (SObject record : records) {
            String fieldValue = (String)record.get(fieldName);
            if (fieldValue == null) continue;
            if (!groupedRecords.containsKey(fieldValue)) groupedRecords.put(fieldValue, new List<SObject>());
            groupedRecords.get(fieldValue).add(record);
        }
        return groupedRecords;
    }

    public static Map<String, SObject> groupByFieldUnique(List<SObject> records, Schema.SobjectField field) {
        return groupByFieldUnique(records, field.getDescribe().getName());
    }

    public static Map<String, SObject> groupByFieldUnique(List<SObject> records, String fieldName) {
        Map<String, SObject> mappedRecords = new Map<String, SObject>();
        for (SObject record : records) {
            String fieldValue = (String)record.get(fieldName);
            if (fieldValue == null) continue;
            mappedRecords.put(fieldValue, record);
        }
        return mappedRecords;
    }

    public static Boolean isFieldChanged(SObjectField field, SObject newRecord, SObject oldRecord) {
        return oldRecord == null || newRecord.get(field) != oldRecord.get(field);
    }

    public static Boolean isAnyFieldChanged(List<SObjectField> fields, SObject newRecord, SObject oldRecord) {
        for (SObjectField field : fields) {
            if (isFieldChanged(field, newRecord, oldRecord)) return true;
        }
        return false;
    }

    public static Boolean areAllFieldsChanged(List<SObjectField> fields, SObject newRecord, SObject oldRecord) {
        for (SObjectField field : fields) {
            if (!isFieldChanged(field, newRecord, oldRecord)) return false;
        }
        return true;
    }

    public static Boolean containsAny(String input, List<String> blacklist) {
        for (String blacklistedInput : blacklist) {
            if (input.contains(blacklistedInput)) {
                return true;
            }
        }
        return false;
    }

    public static Boolean containsNone(String input, List<String> blacklist) {
        return !containsAny(input, blacklist);
    }

    public static String cleanHtml(String input) {
        return cleanHtml(input, Constants.DEFAULT_EMAIL_SUBSTRING_SIZE);
    }

    public static String cleanHtml(String input, Integer substringSize) {
        String output = input;

        // Remove <head> tag and all it includes
        try {
            if (output.contains('<head>') && output.contains('</head>')) {
                List<String> firstSplit = output.split('<head>');
                List<String> secondSplit = firstSplit[1].split('</head>');
                output = firstSplit[0]+secondSplit[1];
            }
        } catch(exception e) {
            // Just in case
        }

        // Remove unneeded whitespaces and linejumps
        try {
            // Substring into blocks of n characters to avoid having "regex too complicated" error.
            Integer substringsAmount = Integer.valueOf(output.length() / substringSize);
            List<String> outputSubstrings = new List<String>();
            for (Integer i = 0; i < substringsAmount; i++) {
                outputSubstrings.add(removeExtraNewlinesAndTrim(output.substring(i * substringSize, (i+1) * substringSize)));
            }
            // Handle the remaning characters after all substrings.
            if (output.length() > (substringSize * (substringsAmount + 1))) {
                outputSubstrings.add(removeExtraNewlinesAndTrim(output.substring(substringsAmount * substringSize)));
            }
            // Handle everything at once when length is less than substring size.
            if (substringsAmount == 0) {
                outputSubstrings.add(removeExtraNewlinesAndTrim(output));
            }
            output = String.join(outputSubstrings, '');
        } catch(exception e) {
            // And again
        }

        return output;
    }

    public static String removeExtraNewlinesAndTrim(String input) {
        List<String> lines = new List<String>();
        for (String line : input.split('\n')) {
            line = line.trim();
            if (!String.isEmpty(line)) {
                lines.add(line);
            }
        }
        return String.join(lines, '\n');
    }
}
