public with sharing class LookupPage1Controller {
    public Boolean render1 {
        get;
        set;
    }
    List < Book__c > records = new List < Book__c > ();
    public String searchvalue {
        get;
        set;
    }
    public LookupPage1Controller() {
        try {
            searchvalue = ApexPages.currentPage().getParameters().get('parentname');
            String id = ApexPages.currentPage().getParameters().get('parentid');
            if (String.IsNotBlank(searchvalue)) {
                render1 = true;
                records = [Select Name, Author__c, Price__c from Book__c where Name like: +searchvalue + '%'
                    order by Name asc
                ];
            } else {
                render1 = true;
                records = [Select Name, Author__c, Price__c from Book__c order by Name asc];
            }
        } catch (Exception e) {}
    }
    public List < Book__c > getRecords() {
        if (records.size() != 0) {
            return records;
        } else {
            return null;
        }
    }
    public PageReference onkeyupAction() {
        searchAction();
        return null;
    }
    public PageReference searchAction() {
        render1 = true;
        records = [Select Name, Author__c, Price__c from Book__c where Name like: +searchvalue + '%'
            order by Name asc
        ];
        if (records.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Records Found'));
        }
        return null;
    }
}