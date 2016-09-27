global with sharing class googlegantchart {

    public String oppList { get; set; }
     
    @RemoteAction   
    global static Opportunity[] loadrecords() {
        return [select Name,Task_Id__c,Task_Name__c, Start_Date__c,  End_Date__c,Duration__c,Dependencies__c,Percent_Complete__c from opportunity where Task_Id__c!=Null];
    }   
 
}