({
	doInit : function(component) {
		var action = component.get("c.getAccountItems");
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var uniqueItems = _.orderBy(a.getReturnValue(), function(x){
                        return x.Name;
                },['asc']);
                component.set("v.accountItems", uniqueItems);
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    sortByName : function(component) {
        var items = component.get("v.accountItems");
        if(component.get("v.sort1") === "down"){
            var uniqueItems = _.orderBy(items, function(x){
                return x.Name;
            },['desc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort1", "up");
        } else {
            var uniqueItems = _.orderBy(items, function(x){
                return x.Name;
            },['asc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort1", "down");
        }
    },
    
    sortByCity : function(component) {
        var items = component.get("v.accountItems");
        if(component.get("v.sort2") === "down"){
            var uniqueItems = _.orderBy(items, function(x){
                return x.BillingCity;
            },['desc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort2", "up");
        } else {
            var uniqueItems = _.orderBy(items, function(x){
                return x.BillingCity;
            },['asc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort2", "down");
        }
    },
    
    sortByPhone : function(component) {
        var items = component.get("v.accountItems");
        if(component.get("v.sort3") === "down"){
            var uniqueItems = _.orderBy(items, function(x){
                return x.Phone;
            },['desc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort3", "up");
        } else {
            var uniqueItems = _.orderBy(items, function(x){
                return x.Phone;
            },['asc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort3", "down");
        }
    },
    
    sortByRevenue : function(component) {
        var items = component.get("v.accountItems");
        if(component.get("v.sort4") === "down"){
            var uniqueItems = _.orderBy(items, function(x){
                return x.AnnualRevenue;
            },['desc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort4", "up");
        } else {
            var uniqueItems = _.orderBy(items, function(x){
                return x.AnnualRevenue;
            },['asc']);
            component.set("v.accountItems", uniqueItems);
            component.set("v.sort4", "down");
        }
    },
})