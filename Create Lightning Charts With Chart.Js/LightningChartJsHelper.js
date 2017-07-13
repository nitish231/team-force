    ({
        displaydata : function(component, event, helper) {
            var sobje = component.get("v.sObj");
            var field = component.get("v.field");
            var map = new Map();
            var listofpicklistvalues = component.get("v.picklistvalues")
            var action = component.get("c.generateDataa");
            action.setParams({
                selectedObject : sobje,
                selectedfield : field
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var outputresponse = response.getReturnValue();
                if (state === "SUCCESS") {
                    for(var j=0; j< listofpicklistvalues.length; j++){
                        var openopps=0;
                        for(var i=0; i < outputresponse.length; i++){
                            console.log('res::'+outputresponse[i].selectedfield);
                            if(listofpicklistvalues[j] === outputresponse[i].selectedfield){
                                console.log('inside if');
                                openopps = openopps+1;
                            }
                        }
                        map.set(listofpicklistvalues[j],openopps);
                        
                    }
                    this.helperMethod(component, event, helper, map, listofpicklistvalues);
                } else {
    
                }
            });
            $A.enqueueAction(action);
           },
        
        
        helperMethod : function(component, event, helper, map, listofpicklistvalues) {
            var doughnutData = [];
            var labelNames = [];
            var bcolor = [];
            var typeofchart = component.get("v.Charttype");
            var field = component.get("v.field");
            for (var i = 0; i < listofpicklistvalues.length; i++) {
                var color = this.getRandomColor();
                labelNames.push(listofpicklistvalues[i]); 
                doughnutData.push(map.get(listofpicklistvalues[i])); 
                bcolor.push(color);
            }
            // chart code
          var mydoughnutChart = new Chart(document.getElementById("doughnutChart"), {
                type: typeofchart,
                data: {
                    labels: labelNames,
                    datasets: [{
                        backgroundColor: bcolor,
                        data: doughnutData
                    }]
                },
                options: {
                    legend: { display: false },
                    title: {
                        display: true,
                        text: field +' Vs Count',
                    }
                }
            });
          },
       // This function will generate colors dynamically 
        getRandomColor : function(component) {
            var letters = '0123456789ABCDEF';
            var color = '#';
            for (var i = 0; i < 6; i++ ) {
                color += letters[Math.floor(Math.random() * 16)];
            }
            return color;
        }
    })
