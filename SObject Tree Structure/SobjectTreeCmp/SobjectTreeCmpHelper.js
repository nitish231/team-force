({
    queryRecords : function(component) {
        if(component.get("v.selectedObject").split('///')[0] !== "None") {
            var action = component.get("c.getParentSObjectRecords");
            action.setParams({
                "objectAPI" : component.get("v.selectedObject").split('///')[0],
                "SObjectLabel" : component.get("v.selectedObject").split('///')[1]
            })
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    component.set("v.SObjectList",response.getReturnValue());
                    var itemList = component.get("v.SObjectList.RecordsList");
                    var itemAPI = component.get("v.SObjectList.APIName");
                    var itemLabel = component.get("v.SObjectList.LabelName");
                    var ChildItems = component.get("v.SObjectList.hasChildRecords");
                    var ParentItems = component.get("v.SObjectList.IsParent");
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
                                else if (status === "ERROR") {
                                    var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            component.set("v.ErrorMessage", "ERROR: " + errors[0].message);
                                            $A.util.removeClass(component.find("alert-id"), "showHide");
                                        }
                                    }
                                }
                                    else{
                                        component.set("v.ErrorMessage", "ERROR: Unknown Error.");
                						$A.util.removeClass(component.find("alert-id"), "showHide");
                                    }
                        });
                }
            })
            $A.enqueueAction(action);
        }
    }
})