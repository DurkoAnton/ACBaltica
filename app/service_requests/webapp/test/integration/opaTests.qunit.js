sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'servicerequests/test/integration/FirstJourney',
		'servicerequests/test/integration/pages/ServiceRequestList',
		'servicerequests/test/integration/pages/ServiceRequestObjectPage'
    ],
    function(JourneyRunner, opaJourney, ServiceRequestList, ServiceRequestObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('servicerequests') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheServiceRequestList: ServiceRequestList,
					onTheServiceRequestObjectPage: ServiceRequestObjectPage
                }
            },
            opaJourney.run
        );
    }
);