public class DeleteComponentsClass {
    
    // Initializing elements
    public String selectedType{get;set;}
    public String componentName{get;set;}
    public List<DeleteComponentsWrpClass> componentItems{get;set;}

    // Getting picklist elements
    public static List<SelectOption> getDataTypes(){
        
        List<String> itemTypes = new List<String>{'ActionLinkGroupTemplate','AnalyticSnapshot','ApexClass','ApexComponent','ApexPage',
            'ApexTrigger','AppMenu','ApprovalProcess','AssignmentRules','AuraDefinitionBundle','AuthProvider','AutoResponseRules','BusinessProcess',
            'CallCenter','ChannelLayout','Community','CompactLayout','CorsWhitelistOrigin','CustomApplication','CustomField','CustomMetadata',
            'CustomObject','CustomObjectTranslation','CustomPageWebLink','CustomPermission','CustomSite','CustomTab','Dashboard','Document',
            'EmailTemplate','EscalationRules','ExternalDataSource','FieldSet','FlexiPage','FlowDefinition','Group','HomePageComponent','HomePageLayout',
            'Layout','Letterhead','ListView','MatchingRule','NamedCredential','PermissionSet','PlatformCachePartition','Portal','PostTemplate',
            'Profile','Queue','QuickAction','RecordType','RemoteSiteSetting','Report','ReportType','Role','Scontrol','Settings','SharingCriteriaRule',
            'SharingOwnerRule','SharingReason','SharingRules','SharingSet','SiteDotCom','StaticResource','UserPermissions','ValidationRule',
            'WebLink','Workflow','WorkflowAlert','WorkflowFieldUpdate','WorkflowOutboundMessage','WorkflowRule','WorkflowTask'};
        
        List<SelectOption> customTypes = new List<SelectOption>();
        customTypes.add(new SelectOption('','--None--'));
        for(String item : itemTypes){
            customTypes.add(new SelectOption(item,item));
        }
        
        return customTypes;
    }
    
    // Adding Items to the List
    public void add(){
        
        List<String> splitItems = componentName.split(';');
        
        for(String Item : splitItems){
            DeleteComponentsWrpClass compItem = new DeleteComponentsWrpClass();
            compItem.compName = Item;
            compItem.compType = selectedType;
            if(componentItems == null){
                componentItems = new List<DeleteComponentsWrpClass>();
            }
            componentItems.add(compItem);
        }
        componentName = null;
        
    }
    
    // Deploying zip file
    @RemoteAction
    public static String getDeployContent(String zipData){
        
        MetadataService.MetadataPort service = createService();
        
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
      deployOptions.purgeOnDelete = false;
      deployOptions.rollbackOnError = true;
      deployOptions.testLevel = 'NoTestRun';
      deployOptions.singlePackage = true;   
        
      MetadataService.AsyncResult AsyncResult = service.deploy(zipData, DeployOptions); 
        
        return ('Success');
    }
    
    // Cancel button action
    public PageReference cancel(){
        
        PageReference pageRef = new PageReference('/home/home.jsp');
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    // Delete button action
    public PageReference deleteItems(){
        
        Long startTime = System.now().getTime();
        Integer delay = 5000;
        
        do {
             // Do nothing 
        }while (System.now().getTime() - startTime < delay);
        
        PageReference pageRef = new PageReference('/changemgmt/monitorDeployment.apexp');
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    // Creating service
    private static MetadataService.MetadataPort createService() { 
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
      service.SessionHeader = new MetadataService.SessionHeader_element();
      service.endpoint_x = 'https://coyg-dev-ed.my.salesforce.com/services/Soap/m/35.0';
      service.timeout_x = 120000;
      service.SessionHeader.sessionId = UserInfo.getSessionId();
      return service;   
        
    }
    
    // Wrapper Class
    public class DeleteComponentsWrpClass {
        
        public String compType{get;set;}
        public String compName{get;set;}
    
        public DeleteComponentsWrpClass(){
        
        }
    }
    
}