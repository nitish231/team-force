public class SObjectTreeChildWrpClass {

    @AuraEnabled
    public String ChildObjectLabel;
    
    @AuraEnabled
    public String ChildObjectAPIName;
    
    @AuraEnabled
    public SObject ChildRecordsList;
    
    @AuraEnabled
    public Boolean Childobjlabelandparentlabelsame = True;
    
    public SObjectTreeChildWrpClass(){
        
    }
}