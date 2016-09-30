
public with sharing class DynamicController {

    public String RepName { get; set; }
    
    public PageReference changeOwer() {
    
        //Getting the report data
        Httprequest req= new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v29.0/analytics/reports/00O90000009BCxY/');
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer '+UserInfo.getSessionID());
        Http httpReq = new Http();
        HttpResponse res =httpReq.send(req);
        string body =res.getBody();
        system.debug('ReportStr'+body);

        //The Logic will be changed based on te requirement
        body = body.subStringBetween('"reportMetadata"', '}}');
        string subString = body.subStringBetween('"column":"USERS.NAME",', '}');
        System.debug('Chek'+subString);
        string newBody = '"operator":"equals","value":"'+RepName+'"';
        string LatestBody = body.replace(subString, newBody);
        string PostBody = '{"reportMetadata"'+LatestBody+'}}}';
        System.debug('PostBody'+PostBody);
        //Updating the Report
        Httprequest reqt =new HttpRequest();
        reqt.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v34.0/analytics/reports/00O90000009BCxY?_HttpMethod=PATCH');
        reqt.setMethod('POST');
        reqt.setbody(PostBody);
        reqt.setHeader('Content-Type','application/json');
        reqt.setHeader('Authorization','Bearer '+UserInfo.getSessionID());
        Http httpReq2= new Http();
        HttpResponse ress=httpReq2.send(reqt);
                
        return null;
    }


    
}
