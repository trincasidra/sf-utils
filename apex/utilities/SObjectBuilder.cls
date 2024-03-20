@IsTest
public class SObjectBuilder {

    private SObject record;
    private final SObjectType sObjectType;
    private final Type deserializeType;

    public SObjectBuilder(SObjectType sObjectType) {
        this.sObjectType = sObjectType;
        this.record = sObjectType.newSObject(TestingUtils.generateId(sObjectType));
        this.deserializeType = Type.forName(this.sObjectType.getDescribe().getName());
    }

    public SObjectBuilder set(SObjectField field, Object value) {
        this.record.put(field, value);
        return this;
    }

    public SObjectBuilder setReadOnly(SObjectField field, Object value) {
        return setReadOnly(field.getDescribe().getName(), value);
    }

    public SObjectBuilder setReadOnly(String field, Object value) {
        Map<String, Object> fieldsByName = new Map<String, Object>(this.record.getPopulatedFieldsAsMap());
        fieldsByName.put(field, value);
        String jsonString = JSON.serializePretty(fieldsByName);
        this.record = (SObject)JSON.deserialize(jsonString, this.deserializeType);
        return this;
    }

    /**
     * Copyright (c), Andrew Fawcett
     * All rights reserved.
     *
     * Redistribution and use in source and binary forms, with or without modification, 
     *   are permitted provided that the following conditions are met:
     *
     * - Redistributions of source code must retain the above copyright notice, 
     *      this list of conditions and the following disclaimer.
     * - Redistributions in binary form must reproduce the above copyright notice, 
     *      this list of conditions and the following disclaimer in the documentation 
     *      and/or other materials provided with the distribution.
     * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
     *      may be used to endorse or promote products derived from this software without 
     *      specific prior written permission.
     *
     * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
     *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
     *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
     *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
     *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
     *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
     *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
     *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    **/

    // Source (modified): https://gist.github.com/afawcett/8dbfc0e1d8c43c982881
    public SObjectBuilder setRelationship(SObjectField relationshipField, List<SObject> children) {
        String relationshipName = null;
        for (ChildRelationship relation : record.getSObjectType().getDescribe().getChildRelationships()) {
            if (relation.getField() == relationshipField) {
                relationshipName = relation.getRelationshipName();
                break;
            }
        }

        JSONParser parentParser = JSON.createParser(JSON.serialize(record));
        JSONParser childrenParser = JSON.createParser(JSON.serialize(children));
        JSONGenerator combinedOutput = JSON.createGenerator(false);
        streamTokens(parentParser, combinedOutput, new InjectChildrenEventHandler(childrenParser, relationshipName, children));

        // Deserialize back into SObject complete with children
        record = (SObject)JSON.deserialize(combinedOutput.getAsString(), deserializeType);
        return this;
    }

    /* Example JSON structure for a single object:

        {
        "attributes" : {
            "type" : "Booking__c",
            "url" : "/services/data/v57.0/sobjects/Booking__c/a080Q000009VEv5QAG"
        },
        "Id" : "a080Q000009VEv5QAG",
        "CurrencyIsoCode" : "EUR",
        "Cases__r" : {
            "totalSize" : 2,
            "done" : true,
            "records" : [ {
                "attributes" : {
                    "type" : "Case",
                    "url" : "/services/data/v57.0/sobjects/Case/5000Q00000IhQX1QAN"
                },
                "Booking__c" : "a080Q000009VEv5QAG",
                "Id" : "5000Q00000IhQX1QAN",
                "Subject" : "Test json",
                "RecordTypeId" : "0123X0000015xeLQAQ",
                "CurrencyIsoCode" : "EUR"
            }, {
                "attributes" : {
                    "type" : "Case",
                    "url" : "/services/data/v57.0/sobjects/Case/5000Q00000IhQXOQA3"
                },
                "Booking__c" : "a080Q000009VEv5QAG",
                "Id" : "5000Q00000IhQXOQA3",
                "Subject" : "Test json",
                "RecordTypeId" : "0123X0000015xeLQAQ",
                "CurrencyIsoCode" : "EUR"
            } ]
        }
    }

    */

    // Monitors stream events for end of object for each SObject contained in the parent list, then injects the respective childs record list into the stream
    private class InjectChildrenEventHandler implements JSONParserEvents {
        private JSONParser childrenParser;
        private String relationshipName;
        private List<SObject> children;

        public InjectChildrenEventHandler(JSONParser childrenParser, String relationshipName, List<SObject> children) {
            this.childrenParser = childrenParser;
            this.relationshipName = relationshipName;
            this.children = children;
        }

        public void nextToken(JSONParser fromStream, Integer depth, JSONGenerator toStream) {
            // Inject children before closing the outer object tag (depth 1).
            JSONToken currentToken = fromStream.getCurrentToken();
            if(depth == 1 && currentToken == JSONToken.END_OBJECT) {
                toStream.writeFieldName(relationshipName);
                toStream.writeStartObject();
                toStream.writeNumberField('totalSize', children.size());
                toStream.writeBooleanField('done', true);
                toStream.writeFieldName('records');
                streamTokens(childrenParser, toStream, null);
                toStream.writeEndObject();
            }
        }
    }

    // Utility function to stream tokens from a reader to a write, while providing a basic eventing model
    private static void streamTokens(JSONParser fromStream, JSONGenerator toStream, JSONParserEvents events) {
        Integer depth = 0;
        while (fromStream.nextToken()!=null) {
            // Give event handler chance to inject
            if (events != null) {
                events.nextToken(fromStream, depth, toStream);
            }

            // Forward to output stream
            JSONToken currentToken = fromStream.getCurrentToken();
            system.debug(depth+' '+currentToken);
            if (currentToken == JSONToken.START_ARRAY) {
                toStream.writeStartArray();
                depth++;
            } else if (currentToken == JSONToken.START_OBJECT) {
                toStream.writeStartObject();
                depth++;
            } else if (currentToken == JSONToken.FIELD_NAME) {
                toStream.writeFieldName(fromStream.getCurrentName());
            } else if (currentToken == JSONToken.VALUE_STRING
                    || currentToken == JSONToken.VALUE_FALSE
                    || currentToken == JSONToken.VALUE_TRUE
                    || currentToken == JSONToken.VALUE_NUMBER_FLOAT
                    || currentToken == JSONToken.VALUE_NUMBER_INT) {
                toStream.writeString(fromStream.getText());
            } else if (currentToken == JSONToken.END_OBJECT) {
                toStream.writeEndObject();
                depth--;
            } else if (currentToken == JSONToken.END_ARRAY) {
                toStream.writeEndArray();
                depth--;
            }
            
            // Don't continue to stream beyond the initial starting point
            if(depth == 0) {
                break;
            } 
        }
    }

    // Basic event used during the above streaming
    private interface JSONParserEvents {
        void nextToken(JSONParser fromStream, Integer depth, JSONGenerator toStream);
    }

    public SObject build() {
        return record;
    }
}
