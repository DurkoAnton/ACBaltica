sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'opportunitiesportal/test/integration/FirstJourney',
		'opportunitiesportal/test/integration/pages/OpportunityList',
		'opportunitiesportal/test/integration/pages/OpportunityObjectPage'
    ],
    function(JourneyRunner, opaJourney, OpportunityList, OpportunityObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('opportunitiesportal') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheOpportunityList: OpportunityList,
					onTheOpportunityObjectPage: OpportunityObjectPage
                }
            },
            opaJourney.run
        );
    }
);