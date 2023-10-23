sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'requestapproval/test/integration/FirstJourney',
		'requestapproval/test/integration/pages/RequestApprovalList',
		'requestapproval/test/integration/pages/RequestApprovalObjectPage'
    ],
    function(JourneyRunner, opaJourney, RequestApprovalList, RequestApprovalObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('requestapproval') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheRequestApprovalList: RequestApprovalList,
					onTheRequestApprovalObjectPage: RequestApprovalObjectPage
                }
            },
            opaJourney.run
        );
    }
);