({
    // Getting picklist values from apex controller and displaying in the field when the page is loaded
    doInit : function(component, event, helper){
        component.title="SObject Tree structure";
        var action = component.get("c.initializeObjectNames");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.ListOfSObjectNames", items);
            }
        })
        $A.enqueueAction(action);
    },
    // Getting records when Get Records button event fired
    getObjectRecords : function(component, event, helper) {
        helper.queryRecords(component);
    }
})