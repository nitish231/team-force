public with sharing class DropboxUploadController {
    
    private String apiKey;
    private String apiSecret;
    private String redirectURI;
    private String Dropbox_Account_endpoint;
    private String Dropbox_files_endpoint;
    private String Dropbox_OAuth_authorize;
    private String Dropbox_OAuth_token;
    private String authorizationCode;
    private String refreshToken;
    
    public String code { get; set; }
    public String username { get; set; }
    public String fileName { get; set; }
    public Blob fileBody { get; set; }
    public Boolean success { get; set; }
    public Boolean connected { get; set; }
    
    public DropboxUploadController() {
        connected = false;
        success = false;
        apiKey = ''; // this is your dropbox apikey
        apiSecret = ''; // this is your dropbox api secret
        redirectURI = 'https://souravmoy-dev-ed--c.ap2.visual.force.com/apex/DropboxUpload'; // url of the vf page in which the dropbox login is done
        Dropbox_Account_endpoint = 'https://api.dropboxapi.com/1/account/info';
        Dropbox_files_endpoint = 'https://content.dropboxapi.com/1/files_put/auto/';
        Dropbox_OAuth_authorize = 'https://www.dropbox.com/1/oauth2/authorize';
        Dropbox_OAuth_token = 'https://api.dropboxapi.com/1/oauth2/token';
        
        code = ApexPages.currentPage().getParameters().get('code');
        if(code != null) {
            connected = true;
            authorizationCode = code;
            getRefreshToken();
            retrieveUserInfo();
        }
    }
    
    
    public PageReference getAuthorizationCode() {
        String uri = Dropbox_OAuth_authorize +
                     '?client_id=' + apiKey +
                     '&response_type=code' +
                     '&redirect_uri=' + redirectURI;
        PageReference pr = new PageReference(uri);
        pr.setRedirect(true);
        return pr;
    }
    
    private void getRefreshToken() {
        if(authorizationCode != null) {
            try {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                 
                req.setEndpoint(Dropbox_OAuth_token);  
                string bodyRequest = '';
                bodyRequest = 'code=' + EncodingUtil.urlEncode(authorizationCode, 'UTF-8');
                bodyRequest+= '&client_id=' + EncodingUtil.urlEncode(apiKey, 'UTF-8');
                bodyRequest+= '&client_secret=' + EncodingUtil.urlEncode(apiSecret, 'UTF-8');
                bodyRequest+= '&redirect_uri=' + EncodingUtil.urlEncode(redirectURI, 'UTF-8');
                bodyRequest+= '&grant_type=authorization_code';
                
                req.setBody(bodyRequest);    
                req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setMethod('POST');
                req.setTimeout(60*1000);
                
                HttpResponse res = h.send(req);  
                map<string, string> jsonValues = new map<string, string>();
                jsonValues = parseJSONToMap(res.getBody());
                if(jsonValues.containsKey('error')) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.'));
                }
                else {
                    refreshToken = jsonValues.get('access_token');
                }
            }
            catch(Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.'));
            }
        }
        else 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.'));
    }
    
    
    // method that returns the username of the connected dropbox account
    private void retrieveUserInfo() {
        if(refreshToken != null) {
            try {
                Http h = new Http();
                HttpRequest req = new HttpRequest(); 
                req.setEndpoint(Dropbox_Account_endpoint);
                
                req.setHeader('Authorization', 'Bearer '+refreshToken);
                req.setHeader('Content-Type', 'application/json; charset=UTF-8');
                req.setHeader('Accept','application/json');
                req.setMethod('GET');
                req.setTimeout(60*1000);
                
                HttpResponse res = h.send(req);
                map<string, string> jsonValues = new map<string, string>();
                jsonValues = parseJSONToMap(res.getBody());
                if(jsonValues.containsKey('error')){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.'));
                }
                else {
                     username = jsonValues.get('email');
                }
            }
            catch(Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.'));
            }
        }
        else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Couldn\'t connect to Dropbox.'));
    }
    
    
    // method that uploads files to dropbox
    public Boolean uploadToDropBox(Blob file, String filename) {
        try {
            String boundary = '----------9889464542212';
            String bodyEncoded = EncodingUtil.base64Encode(file);
            Blob bodyEncoded2 = EncodingUtil.base64Decode(bodyEncoded);
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String endpoint = Dropbox_files_endpoint + filename +'/?overwrite=false';
            req.setEndpoint(endpoint);
            req.setHeader('Authorization', 'Bearer '+refreshToken);
            req.setHeader('Content-Type', 'multipart/mixed; boundary="'+boundary+'"');
            req.setHeader('Content-length', String.valueOf(bodyEncoded.length()));
            req.setBodyAsBlob(bodyEncoded2);
            req.setMethod('PUT');
            req.setTimeout(60*1000);
            HttpResponse resp = http.send(req);
            map<string, string> jsonValues = new map<string, string>();
            jsonValues = parseJSONToMap(resp.getBody());
            if(jsonValues.containsKey('error')){
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+jsonValues.get('error'));
               ApexPages.addMessage(myMsg);
               return false;
            }
            else
              return true;
        }
        catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Files couldn\'t be uploaded to Dropbox.'));
            return false;
        }
    }
    
    private map<string, string> parseJSONToMap(string JSONValue){
        JSONParser parser = JSON.createParser(JSONValue);
        map<string, string> jsonMap = new map<string, string>();
        string keyValue = '';
        string tempValue = '';
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                keyValue = parser.getText();
                parser.nextToken();
                tempValue = parser.getText();
                jsonMap.put(keyValue, tempValue);            
            }
        }
        return jsonMap;
    }
    
    public void uploadFiles() {
        success = uploadToDropBox(fileBody, fileName);
    }

}