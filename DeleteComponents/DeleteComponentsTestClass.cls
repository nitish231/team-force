@isTest()
public class DeleteComponentsTestClass {
    
    public static testmethod void unitTest(){
        
        Test.startTest();
        
        List<SelectOption> itemTypesTest = DeleteComponentsClass.getDataTypes();
        
        PageReference pageRef = page.DeleteComponents;
        Test.setCurrentPage(pageRef);
        
        DeleteComponentsClass controller = new DeleteComponentsClass();
        controller.cancel();
        controller.componentName = 'apexclass;page';
        controller.add();
        controller.deleteItems();
        
        Test.stopTest();
        
    }
    
}