sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'partnerporta/test/integration/FirstJourney',
		'partnerporta/test/integration/pages/PartnerProfileList',
		'partnerporta/test/integration/pages/PartnerProfileObjectPage'
    ],
    function(JourneyRunner, opaJourney, PartnerProfileList, PartnerProfileObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('partnerporta') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onThePartnerProfileList: PartnerProfileList,
					onThePartnerProfileObjectPage: PartnerProfileObjectPage
                }
            },
            opaJourney.run
        );
    }
);