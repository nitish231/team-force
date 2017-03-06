public with sharing class SobjectsTreeCompController {
    
    // Used to display SObjects in picklist 
    @AuraEnabled
    public static List<SObjectTreeWrpClass> initializeObjectNames() {
        // Initilize the variables
        List<SObjectTreeWrpClass> objNames = new List<SObjectTreeWrpClass>();
        List<String> tempList = new List<String>();
        Map<String,String> objectstodisplay = new Map<String,String>();
        
        // Get the custom metadata records
        List<Object_With_Child_Relationship_Name__mdt> lstofmetadataRecords = [select MasterLabel, Child_Relationship_Name__c, Parent_Object_API_Name__c from Object_With_Child_Relationship_Name__mdt]; 
        for(Object_With_Child_Relationship_Name__mdt obj : lstofmetadataRecords){
            objectstodisplay.put(obj.Parent_Object_API_Name__c,obj.Parent_Object_API_Name__c);
        }
        // Describing SObjects present the system
        for(Schema.SObjectType objectType : Schema.getGlobalDescribe().Values()) {
            Schema.DescribeSObjectResult SObjectObj = objectType.getDescribe();
            String name = objectType.getDescribe().getName();
            // Checking SObject present in the Metadata
            if(objectstodisplay.get(name) == name) {
                tempList.add(objectType.getDescribe().getLabel()+'///'+objectType.getDescribe().getName());
            }
        }
        
        // Sorting SObjects
        tempList.sort();
        for(String str : tempList) {
            SObjectTreeWrpClass obj = new SObjectTreeWrpClass();
            List<String> splitList = str.split('///');
            obj.APIName = splitList[1];
            obj.LabelName = splitList[0];
            objNames.add(obj);
        }
        return objNames;
    }
    
    @AuraEnabled
    public static SObjectTreeWrpClass getParentSObjectRecords(String objectAPI) {
        // Initilize the variables
        List<SObject> lstofSObjectRecords = new List<SObject>();
        List<String> lstOfLookupfields = new List<String>();
        Map<String,List<String>> selectedChild = new Map<String,List<String>>();
        Boolean ChildRecordsPresent = false;
        
        // Getting API Name of the selected SObject
        SObjectType objAPIName = Schema.getGlobalDescribe().get(objectAPI);
        DescribeSObjectResult objDescribe = objAPIName.getDescribe();
        String objectLabel = objDescribe.getLabel();
        Map<String, SObjectField> fields = objDescribe.fields.getMap();
        Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>();
        
        // Getting all child related objects
        for (Schema.ChildRelationship childRelation: objDescribe.getChildRelationships()) {
            System.debug('name '+ childRelation.getChildSObject());
            // Checking selected SObject and related SObject are same or not
            if(childRelation.getChildSObject() == objAPIName) {
                if(!selectedChild.containsKey(String.valueof(childRelation.getChildSObject()))) {
                    selectedChild.put(String.valueof(childRelation.getChildSObject()), new List< String >());
                }
                selectedChild.get(String.valueof(childRelation.getChildSObject())).add(String.valueof(childRelation.getRelationshipName()));
            }
        }
        if(selectedChild.keySet().contains(string.valueof(objectAPI))){
            // Looping all fields to get the reference fields
            for(String fieldName : fields.keyset()){
                Schema.DescribeFieldResult lfieldLabel = fields.get(fieldName).getDescribe();
                Schema.DisplayType dType = lfieldLabel.getType();
                string fieldType = String.ValueOf(dType);
                if(fieldType == 'REFERENCE' && fieldName != 'ownerid'
                   && fieldName != 'recordtypeid' && fieldName != 'createdbyid' && fieldName != 'lastmodifiedbyid'){
                       lstOfLookupfields.add(fieldName);
                   }
            }
        }
        // Framing SOQL dynamically 
        String parentId = '';
        String queryStr = 'select id,name from ' + objectAPI+' WHERE ';
        if(lstOfLookupfields.size() > 0){
            integer i=0;
            for(string lookupname : lstOfLookupfields){
                if(i==0){
                    queryStr += lookupname+' = :parentId';
                    i++;
                }
            }
            lstofSObjectRecords = Database.query(queryStr);
        }
        else{
            string queryStrin = 'select Id,Name from ' + objectAPI;
            lstofSObjectRecords = Database.query(queryStrin);
        }
        SObjectTreeWrpClass recordDetails = new SObjectTreeWrpClass();
        recordDetails.APIName = objectAPI;
        recordDetails.LabelName = objectLabel;
        recordDetails.RecordsList = lstofSObjectRecords;
        recordDetails.hasChildRecords = ChildRecordsPresent;
        recordDetails.IsParent = True;
        return recordDetails;    
    }
    
    // Used to retrive records when we click on arrow button
    @AuraEnabled
    public static SObjectTreeWrpClass getChildObjectDetails(String detailId){
        // Get the object API Name Based recordId
        id RecordIdValue = Id.valueOf(detailId);
        String SObjectName = RecordIdValue.getSObjectType().getDescribe().getName();
        // Initialize the variables
        List<SObject> lstofSObjectRecords = new List<SObject>();
        List<String> allChildRelationShipNames = new List<String>();
        Map<Schema.SObjectType,String> Sobjectwithchildrelations = new Map<Schema.SObjectType,String>();
        Map<String,string> selectedChild = new Map<String,string>();
        Map<Schema.SObjectType,set<String>> Sobjectwithchildrelationships = new Map<Schema.SObjectType,set<String>>();
        Map<String,Set<String>> parentobjectswithchildrelationships = new Map<String,Set<String>>();  
        set<string> setstringofchildrelations = new Set<string>();
        Set<String> deduplicationofchildrelationshipnames = new Set<string>();
        // Schema description
        SObjectType objAPIName = Schema.getGlobalDescribe().get(SObjectName);
        String objectLabel = objAPIName.getDescribe().getLabel();
        DescribeSObjectResult objDef = objAPIName.getDescribe();
        
        // Querying custom metadate and adding parent SObject and child relationship names to Map
        List<Object_With_Child_Relationship_Name__mdt> lstofmetadataRecords = [select MasterLabel, Child_Relationship_Name__c, Parent_Object_API_Name__c from Object_With_Child_Relationship_Name__mdt]; 
        for(Object_With_Child_Relationship_Name__mdt objwithchldrelations : lstofmetadataRecords){
            if(objwithchldrelations.Child_Relationship_Name__c != null){
                setstringofchildrelations.add(objwithchldrelations.Child_Relationship_Name__c);
                parentobjectswithchildrelationships.put(objwithchldrelations.Parent_Object_API_Name__c,setstringofchildrelations );
            }
        }
        
        // Getting all child relationship names
        for(Schema.ChildRelationship childRelation: objDef.getChildRelationships()) {
            Schema.SObjectField vv = childRelation.getField();
            if(parentobjectswithchildrelationships.containskey(SObjectName)){
                for(String parentwithrelationship : parentobjectswithchildrelationships.get(SObjectName)){
                    if(parentwithrelationship == childRelation.getrelationshipname()){
                        Sobjectwithchildrelations.put(childRelation.getChildSObject(), childRelation.getrelationshipname() + '/' +vv);
                    }
                }
            }
        }
        // Looping all child SObjects
        for(Schema.SObjectType SObjectAPINames : Sobjectwithchildrelations.keySet()){
            String name = SObjectAPINames.getDescribe().getName();
            DescribeSObjectResult objDescribe = SObjectAPINames.getDescribe();
            Map<String, SObjectField> objfields = objDescribe.fields.getMap();
            set<String> lstFieldNames = new set<String>();
            set<String> lstFieldNa = new set<String>();
            // Looping all fields of a perticular child SObject
            for(String fieldName : objfields.keyset()){
                Schema.DescribeFieldResult lfieldLabel = objfields.get(fieldName).getDescribe();
                Schema.DisplayType dType = lfieldLabel.getType();
                string fieldType = String.ValueOf(dType);
                // Checking if the field datatype is reference
                if(fieldType == 'REFERENCE' && fieldName != 'ownerid'
                   && fieldName != null && fieldName != '' && fieldName != 'recordtypeid' && fieldName != 'createdbyid' && fieldName != 'lastmodifiedbyid'){
                       List<Schema.SObjectType> sobjectrelatedto = lfieldLabel.getReferenceTo();
                       string RelatedToObject = string.valueOf(sobjectrelatedto);
                       if(RelatedToObject.contains(SObjectName)){
                           string ChildrelationshipName = Sobjectwithchildrelations.get(SObjectAPINames);
                           if(!ChildrelationshipName.contains('null')){
                               lstFieldNames.add(fieldName+'/'+RelatedToObject+'/'+ChildrelationshipName);
                               Sobjectwithchildrelationships.put(SObjectAPINames, lstFieldNames);
                               allChildRelationShipNames.add(ChildrelationshipName);
                           }
                       }
                   }
            }
        }
        // Framing SOQL dynamically
        String queryStr;
        queryStr = 'SELECT id,Name ';
        string queryfield='';
        string relatedfield='';
        for(Schema.sObjectType ss : Sobjectwithchildrelationships.keySet()){
            // Get the all fields from related child objects
            SObjectType objAPINames = Schema.getGlobalDescribe().get(String.valueof(ss));
            DescribeSObjectResult objDescribes = objAPINames.getDescribe();
            Map<String, SObjectField> fields = objDescribes.fields.getMap();
            String commaSepratedFields = '';
            for(String fieldName : fields.keyset()){
                Schema.DescribeFieldResult lfieldLabel = fields.get(fieldName).getDescribe();
                Schema.DisplayType dType = lfieldLabel.getType();
                string fieldType = String.ValueOf(dType);
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = fieldName;
                }else if(fieldType == 'REFERENCE' || fieldType == 'String'){
                    commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                }
            }
            // Frame a soql based on relationship name
            integer childrelationshipnames = 0;
            for(String relatedchildrelationshipnames : Sobjectwithchildrelationships.get(ss)){
                List<string> splitvalue = relatedchildrelationshipnames.split('/');
                string relatedtoobjectfield = splitvalue[0];
                string relatedtoobject = splitvalue[1];
                string splittedObjectname = relatedtoobject.removeStart('(');
                string spltobjname = splittedObjectname.removeEnd(')');
                string childrelationship = splitvalue[2];
                if(!deduplicationofchildrelationshipnames.contains(childrelationship) && childrelationship != null && childrelationship != ''){
                    deduplicationofchildrelationshipnames.add(childrelationship);
                    queryfield +=',(SELECT '+commaSepratedFields+' from '+childrelationship+')';
                }
            }
        }
        queryStr+= queryfield + ' from ' + SObjectName+' WHERE Id =: detailId';
        lstofSObjectRecords = Database.query(queryStr);
        List<SObjectTreeChildWrpClass> childRecords = new List<SObjectTreeChildWrpClass>();
        SObjectTreeWrpClass recordDetails = new SObjectTreeWrpClass();
        Boolean ChildRecordsPresent;
        // Splitting the child records from parent to child query
        for(SObject parentRecord : Database.query(queryStr)) {
            Set<SObject> childRecordsdetails = new Set<SObject>();
            for(String childrelationship : allChildRelationShipNames){
                List<String> seperateChildRelationShipName = childrelationship.split('/');
                String SeperatedRelationShipName = seperateChildRelationShipName[0];
                for(SObject child : parentRecord.getSObjects(SeperatedRelationShipName)) {
                    ChildRecordsPresent = True;
                    if(child != null && !childRecordsdetails.contains(child)){
                        SObjectType childobj = child.getSobjectType();
                        String ChildobjectLabel = childobj.getDescribe().getLabel();
                        SObjectTreeChildWrpClass recordDetailswithchildobjectname = new SObjectTreeChildWrpClass();
                        recordDetailswithchildobjectname.ChildObjectLabel = ChildobjectLabel;
                        recordDetailswithchildobjectname.ChildRecordsList = child;
                        recordDetailswithchildobjectname.ChildObjectAPIName = childobj.getDescribe().getName();
                        childRecords.add(recordDetailswithchildobjectname);
                        childRecordsdetails.add(child);
                    }
                }
            }
        }        
        recordDetails.APIName = SObjectName;
        recordDetails.LabelName = objectLabel;
        if(childRecords.size() > 0){
            recordDetails.ListOfChildRecords = childRecords;
        }
        recordDetails.hasChildRecords = ChildRecordsPresent;
        return recordDetails;
    }
}