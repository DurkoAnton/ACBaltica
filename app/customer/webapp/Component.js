sap.ui.define(
    ["sap/fe/core/AppComponent"],
    function (Component) {
        "use strict";

        return Component.extend("customer.Component", {
           
            oncancel: function(oEvent) {
                console.log("Control was clicked.");
            },
            onclose: function(oEvent) {
                console.log("Control was clicked.");
            },
            onchange: function(oEvent) {
                console.log("Control was clicked.");
            },
            onkeydown: function(oEvent) {
                console.log("Control was clicked.");
            },
            onscroll: function(oEvent) {
                console.log("Control was clicked.");
            },
            metadata: {
                manifest: "json"
            },
        });
    }
);

