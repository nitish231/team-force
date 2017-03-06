({
    // Get the child related records
    showHidePanel : function(component) {
        var recid;
        if(component.get("v.ext") === "plus") {
            if(component.get("v.IsParentRecords")){
                recid = component.get("v.ListOfRecords.Id");
            } else {
                recid = component.get("v.ListOfRecords.ChildRecordsList.Id");
            }
            var action = component.get("c.getChildObjectDetails");
            action.setParams({
                "detailId" : recid
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log("inside action params");
                    component.set("v.ext", "minus");
                    component.set("v.SObjectChildList",response.getReturnValue());
                    var itemList = component.get("v.SObjectChildList.ListOfChildRecords");
                    var itemAPI = component.get("v.SObjectChildList.APIName");
                    var itemLabel = component.get("v.SObjectChildList.LabelName");
                    var ChildItems = component.get("v.SObjectChildList.hasChildRecords");
                    var ParentItems = component.get("v.SObjectChildList.IsParent");
                    $A.createComponent(
                        "c:SobjectTreeMiddleCmp", {
                            "objectDetails" : itemList,
                            "objectAPIName" : itemAPI,
                            "objectLabel" : itemLabel,
                            "ChildRecordsPresent" : ChildItems,
                            "IsParentRecords" : ParentItems
                        },
                        function(newCmp, status, errorMessage){
                            //Add the new button to the body array
                            if (status === "SUCCESS") {
                                var body = component.get("v.body");
                                body = newCmp;
                                component.set("v.body", body);
                            }
                            else if (status === "INCOMPLETE") {
                                
                            }
                                else if (status === "ERROR") {
                                    
                                }
                        });
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.ext", "plus");
            component.set("v.SObjectChildList",[]);
        }
    },
    
    // Navigate to detail page
    navigateToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        var recid;
        if(component.get("v.IsParentRecords")){
            recid = component.get("v.ListOfRecords.Id");
        } else {
            recid = component.get("v.ListOfRecords.ChildRecordsList.Id");
        }
        navEvt.setParams({
            "recordId": recid,
        });
        navEvt.fire();
    }
})