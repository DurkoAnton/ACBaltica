const { executeHttpRequest } = require('@sap-cloud-sdk/core');


async function sendRequestToC4C(requestParams) {
    const destinationParams = { destinationName: 'C4C_DEMO' };
    const c4cResponse = await executeHttpRequest(destinationParams, requestParams, {
        fetchCsrfToken: true
    });
    return c4cResponse;
}


module.exports = { sendRequestToC4C };