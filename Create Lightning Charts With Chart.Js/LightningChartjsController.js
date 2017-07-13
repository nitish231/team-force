({
    doinit : function(component,event,helper){
        var sobje = component.get("v.sObj");
        var field = component.get("v.field");
        var action = component.get("c.retrivepicklistvalues");
        action.setParams({
        	selectedObject : sobje,
            selectedfield : field
    	});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.picklistvalues",response.getReturnValue());
                helper.displaydata(component,event,helper);
            }
        });
        $A.enqueueAction(action);
    }
})
