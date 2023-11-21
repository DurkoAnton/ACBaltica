sap.ui.define(
    ["sap/fe/core/AppComponent"],
    function (Component) {
        "use strict";

        return Component.extend("partnerpage.Component", {
            metadata: {
                manifest: "json"
            },

            /**
             * Gets the component startup parameters, setting preferredMode to 'create'.
             * @public
             * @returns 
             */
            getStartupParameters: function() {
                console.log('1')
                return Promise.resolve({
                    preferredMode: ["create"]
                });
            },
           
        });
    }
);