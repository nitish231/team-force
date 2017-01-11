/**********************************************************************
    @ Apex Class  : ImportRecordsUtility
    @ Description : This utility class is used to create records from uploaded CSV files
    @ Created Date: December 27, 2016
    @ Author      : Souravmoy Gorai
***********************************************************************/

public with sharing class ImportRecordsUtility {

    public static String objectName;
    public static String FFName;
    public static list filesList;
    public static list sObjectRecordList;
    public static list attachmentList;
    public static set fieldNamesSet;
    public static map fieldNumberMap;
    public static map headerAPIMap;

    // CONSTRUCTOR
    public static list ImportRecords(String objectType, String fileFormat) {
        objectName = objectType;
        FFName = fileFormat;
        filesList = new list();
        sObjectRecordList = new list();
        attachmentList = new list();
        fieldNamesSet = new set();
        fieldNumberMap = new map();
        headerAPIMap = new map();

        getAllFiles();                          // get all CSV files from Account record
        sObjectRecordList = readFiles();        // read the CSV files

        system.debug('######### '+sObjectRecordList);
        return sObjectRecordList;
    }

    /**********************************************************
     * Method Name  :   getAllFiles
     * Description  :   This method get all the CSV files from
     *                  Account record(for now)
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
    public static list readFiles() {

        Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectName).getDescribe().getSObjectType();
        list objects = new list();

        String fileToString;
        String[] headerFieldNames;                          // contains the Header field names
        String[] lineValues;                                // each data cell
        list lines          = new list();   // for single CSV file
        list allLinesList   = new list();   // all lines combined of all CSV files
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
     * Return type  :   map
     **********************************************************/
    public static map getHeaderAPINames(map headerMap) {
        list fileFormatList = FileFormatService.getFileFormatByName('Product Hierarchy');
        list uploadFileColList = new list();
        map colAPIMap = ColumnAPIMappingService.getColAPIMappingCS();
        map headerAPINumberMap = new map();

        for(File_Format__c tempFF : fileFormatList) {
            uploadFileColList = UploadFileColumnService.getUploadFileColumnByFileFormatID(tempFF.ID);
        }
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