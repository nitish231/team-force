public class SObjectTreeWrpClass {
    
    @AuraEnabled
    public String APIName;
    
    @AuraEnabled
    public Boolean IsParent = False;
    
    @AuraEnabled
    public String LabelName;
    
    @AuraEnabled
    public String RecordType;
    
    @AuraEnabled
    public String RecordId;
    
    @AuraEnabled
    public String ChildObjectLabel;
    
    @AuraEnabled
    public Boolean hasChildRecords = False;
    
    @AuraEnabled
    public SObject ChildRecordsList;
    
    @AuraEnabled
    public List<SObject> RecordsList;
    
    @AuraEnabled
    public List<SObjectTreeChildWrpClass> ListOfChildRecords;
    
    @AuraEnabled
    public String ParentRecordName;
    
    public SObjectTreeWrpClass(){
        
    }
}