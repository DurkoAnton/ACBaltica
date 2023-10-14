sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'partnerpage/test/integration/FirstJourney',
		'partnerpage/test/integration/pages/PartnerProfileObjectPage'
    ],
    function(JourneyRunner, opaJourney, PartnerProfileObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('partnerpage') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onThePartnerProfileObjectPage: PartnerProfileObjectPage
                }
            },
            opaJourney.run
        );
    }
);