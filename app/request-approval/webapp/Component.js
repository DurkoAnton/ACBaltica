sap.ui.define(
    ["sap/fe/core/AppComponent"],
    function (Component) {
        "use strict";

        return Component.extend("requestapproval.Component", {
            metadata: {
                manifest: "json"
            },
            onListNavigationExtension: function (oEvent) {
                var oNavigationController = this.extensionAPI.getNavigationController();
                var oBindingContext = oEvent.getSource().getBindingContext();
                var oObject = oBindingContext.getObject();
                oNavigationController.navigateExternal("toApp2", {
                    
                });
                return true;
            },
        });
    }
);