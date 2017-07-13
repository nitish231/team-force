public with sharing class ChartController {
    @AuraEnabled
    // Method to get the picklist values from Schema
    public static List < String > retrivepicklistvalues(string selectedObject, String selectedfield) {
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe(); // descibe sobjects    
        Map<string,string> Mapofpicklist = new Map<string,string> (); // new map for holding the picklist field values
        List<String> options = new List<String> (); //new list for holding all of the picklist options
        Schema.sObjectType sobjecttype = schemaMap.get(selectedObject);
        Schema.DescribeSObjectResult sobjectdescribe = sobjecttype.getDescribe(); //describe the sobject
        Map<String,Schema.SObjectField> fieldmap = sobjectdescribe.fields.getMap();
        List<Schema.PicklistEntry> picklistvalues = fieldmap.get(selectedfield).getDescribe().getPickListValues(); //get the list of picklist values from field on the sobject
        for (Schema.PicklistEntry a: picklistvalues) { //for all values in the picklist list
            Mapofpicklist.put(a.getValue(), a.getLabel());
        }
        for (string picklistapinames: Mapofpicklist.keyset()) {
            options.add(picklistapinames);
        }
        return options; //return the List of values
    }


    // Method to query the data from SObject
    @AuraEnabled
    public static List<wrapperclass> generateDataa(String selectedObject, String selectedfield) {
        String QueryStr = queryAllFrom(selectedObject);
        List < Sobject > groupedResults = Database.query(QueryStr);
        List < wrapperclass > lstofwrapperclass = new List < wrapperclass > ();
        Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
        Map < string, string > Mapofpicklist = new Map < string, string > ();
        List < String > options = new List < String > ();
        Schema.sObjectType sobject_type = schemaMap.get(selectedObject);
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map < String, Schema.SObjectField > fieldmap = sobject_describe.fields.getMap();
        for (Sobject sobj: groupedResults) {
            for (Schema.SObjectField field: fieldMap.values()) {
                if (string.valueof(field) == selectedfield) {
                    Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    wrapperclass wrap = new wrapperclass();
                    wrap.selectedfield = String.valueof(sobj.get(fieldResult.getName()));
                    wrap.lstofobj = sobj;
                    lstofwrapperclass.add(wrap);
                }
            }
        }
        return lstofwrapperclass;
    }

    // Wrapper calss to hold the record with selected picklist value
    public class wrapperclass {
        @AuraEnabled
        public string selectedfield;
        @AuraEnabled
        public Sobject lstofobj;
    }

    // Dynamic SOQL 
    public static string queryAllFrom(string sObjectType) {
        String query = 'SELECT ';
        for (Schema.SObjectField nameAPIfield: Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap().values()) {
            query += query == 'SELECT ' ? String.ValueOf(nameAPIfield) : ', ' + String.ValueOf(nameAPIfield);
        }
        return query + ' FROM ' + sObjectType;
    }
}
