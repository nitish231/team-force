/**********************************************************************
    @ Apex Class  : ImportRecordsUtility
    @ Description : This utility class is used to create records from uploaded CSV files
    @ Created Date: December 27, 2016
    @ Author      : Souravmoy Gorai            
***********************************************************************/

public with sharing class ImportRecordsUtility {
    
    public static String objectName;
    public static String FFName;
    public static list<BLOB> filesList;
    public static list<sObject> sObjectRecordList;
    public static list<Attachment> attachmentList;
    public static set<String> fieldNamesSet;
    public static map<String, Integer> fieldNumberMap;
    public static map<String, Integer> headerAPIMap;
    
    // CONSTRUCTOR
    public static list<sObject> ImportRecords(String objectType, String fileFormat) {
        objectName = objectType;
        FFName = fileFormat;
        filesList = new list<BLOB>();
        sObjectRecordList = new list<sObject>();
        attachmentList = new list<Attachment>();
        fieldNamesSet = new set<String>();
        fieldNumberMap = new map<String, Integer>();
        headerAPIMap = new map<String,Integer>();
        
        getAllFiles();                          // get all CSV files from Distributor record
        sObjectRecordList = readFiles();        // read the CSV files
        
        system.debug('######### '+sObjectRecordList);
        return sObjectRecordList;
    }
    
    /**********************************************************
     * Method Name  :   getAllFiles
     * Description  :   This method get all the CSV files from 
     *                  Distributor record(for now)
     * Return type  :   void
     **********************************************************/
    public static void getAllFiles() {

        String fileExtension;
        list accList = [SELECT ID, Name FROM Account];
        system.debug('#### all accounts '+accList);
        list accIDList = new list();
        for(Account tempAcc : accList)
            accIDList.add(tempAcc.ID);
        attachmentList = [SELECT ID, Name, Body, BodyLength, ContentType, IsPrivate, ParentId FROM Attachment WHERE ParentId IN: accIDList];
        system.debug('#### all attachments '+attachmentList);
        for(Attachment tempAttach : attachmentList) {
            fileExtension = tempAttach.Name.substring(tempAttach.Name.lastIndexOf('.') + 1);
            system.debug('#### file extension '+fileExtension);
            if(fileExtension.equalsIgnoreCase('csv')) {
                filesList.add(tempAttach.Body);
            }
        }
    }
    
    /**********************************************************
     * Method Name  :   readFiles
     * Description  :   This method reads all the CSV files
     * Return type  :   void
     **********************************************************/
    public static list<sObject> readFiles() {
        
        Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectName).getDescribe().getSObjectType();
        system.debug(objectDef);
        list<sObject> objects = new list<sObject>();
        
        String fileToString;
        String[] headerFieldNames;                          // contains the Header field names
        String[] lineValues;                                // each data cell
        list<String> lines          = new list<String>();   // for single CSV file
        list<String> allLinesList   = new list<String>();   // all lines combined of all CSV files
        for(BLOB tempBlob : filesList) {
            fileToString = tempBlob.toString();
            system.debug('#### file '+fileToString);
            
            lines = fileToString.split('\r');               // using carriage return accomodates windows, unix, and mac files
            system.debug('#### lines '+lines);
            headerFieldNames = lines[0].split(',');
            system.debug('#### header field Names '+headerFieldNames);
            for(Integer i=0; i< headerFieldNames.size(); i++) {
                fieldNumberMap.put(headerFieldNames[i], i);
                fieldNamesSet.add(headerFieldNames[i].trim());
            }
            
            headerAPIMap = getHeaderAPINames(fieldNumberMap);
            system.debug('#### new API map '+headerAPIMap);
            
            for(Integer i=1; i< lines.size(); i++) {
                // Skip blank CSV lines (only commas)
                if (lines[i].replaceAll(',','').trim().length() == 0) break;
                
                sObject thisObj = objectDef.newSobject();
                lineValues = lines[i].split(',');
                for(String tempFieldAPIName : headerAPIMap.keySet()) {
                    Integer fieldNumber = headerAPIMap.get(tempFieldAPIName);
                    String fieldValue = lineValues[fieldNumber];
                    thisObj.put(tempFieldAPIName,fieldValue.trim());
                }
                
                objects.add(thisObj);
            }
            
        }
        
        return objects;
    }
    
    /**********************************************************
     * Method Name  :   getHeaderAPINames
     * Description  :   This method gets the field API names for the header values
     * Return type  :   map<String, Integer>
     **********************************************************/
    public static map<String,Integer> getHeaderAPINames(map<String,Integer> headerMap) {
        ID fileFormatID = [SELECT ID, Name FROM File_Format__c WHERE Name =: FFName].ID;
        list<Upload_File_Column__c> uploadFileColList = new list<Upload_File_Column__c>();
        map<String,String> colAPIMap = new map<String,String>();
        map<String,Integer> headerAPINumberMap = new map<String,Integer>();
        

        map<String,String> colAPIMap = new map<String,String>();
        list<Import_Column_API_Mapping__c> colAPIMapList = [ SELECT Name, Column_Name__c, Column_API_Name__c FROM Import_Column_API_Mapping__c ];
        for(Import_Column_API_Mapping__c tempColAPIMap : colAPIMapList) {
            colAPIMap.put(tempColAPIMap.Column_Name__c,tempColAPIMap.Column_API_Name__c);
        }

        uploadFileColList = [ SELECT ID, Name, File_Format__c, Column_Name__c, Column_Number__c, Column_Field_Name__c FROM Upload_File_Column__c WHERE File_Format__c =: fileFormatID];

        if(uploadFileColList.size() > 0) {
            for(Upload_File_Column__c tempUFCol : uploadFileColList) {
                for(String tempHdr : headerMap.keySet()) {
                    if(tempUFCol.Column_Name__c == tempHdr) {
                        String colAPI = colAPIMap.get(tempUFCol.Column_Field_Name__c);
                        headerAPINumberMap.put(colAPI,headerMap.get(tempHdr));
                    }
                }
            }
        }
        else {
            System.debug('########## No File Format found #########');
            return null;
        }
        return headerAPINumberMap;
    }
    
}