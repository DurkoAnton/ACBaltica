const { sendRequestToC4C } = require('./ManageAPICalls');

function getObjectsWithDifferentPropertyValue(array1, array2, propertyName1, propertyName2) {
    // Use filter to create a new array containing objects from array1
    // where the specified property value is different in array2
    return array1.filter(item1 =>
        !array2.some(item2 => item1[propertyName1] === item2[propertyName2])
    );
}

function createAttachmentBody(item, results) {
    for (let attachment of item.Attachment) {
        try {
            let binaryData = attachment.content;
            let base64String = binaryData ? binaryData.toString('base64') : null;
            const body = {
                Binary: base64String,
                DocumentLink: attachment.url,
                MimeType: attachment.mediaType,
                Name: attachment.fileName
            };
            results.push(body);
        } catch (error) {
            console.error('Error processing attachment:', error);
        }
    }
}

async function linkSelectedOpportunity(serviceRequest, opportunityEntity, body) {
    if (serviceRequest.OrderID) {
        const opportunity = await SELECT.one.from(opportunityEntity).where({ ID: serviceRequest.OrderID });
        const results = [{
            TypeCode: "72",
            RoleCode: "1",
            ID: opportunity.InternalID
        }];
        body.ServiceRequestBusinessTransactionDocumentReference = { results };
    }
}

async function createNewCustomerInRemote(customerData, customerEntity, req) {
    if (customerData.UUID == null) {
        let body = {
            Name: customerData.CustomerFormattedName,
            RoleCode: 'CRM000'
        };
        let path = `/sap/c4c/odata/v1/c4codataapi/CorporateAccountCollection`;

        const createInC4CParameters = {
            method: 'POST',
            url: path,
            data: body,
            headers: { 'content-type': 'application/json' }
        };

        try {
            let c4cResponse = await sendRequestToC4C(createInC4CParameters);
            if (c4cResponse.status == '201') {
                // first creation -> save object id
                const objectID = c4cResponse.data.d.results.ObjectID;
                const UUID = c4cResponse.data.d.results.UUID;
                const internalID = c4cResponse.data.d.results.AccountID;

                await UPDATE(customerEntity, customerData.ID).with({ UUID: UUID, ObjectID: objectID, InternalID: internalID });
                //link new customer and current contact
                if (req.headers['x-username']) {
                    const email = req.headers['x-username'];
                    path += '(\'' + objectID + '\')/CorporateAccountHasContactPerson';
                    let contactID;
                    const currentPartner = await SELECT.one.from('PARTNER_PARTNERPROFILE').where({ Email: email });
                    if (currentPartner) {
                        contactID = currentPartner.CODE;
                    }
                    const linkBody = {
                        ContactID: contactID,
                        MainIndicator: true
                    };
                    let linkToContactC4CParameters = {
                        method: 'POST',
                        url: path,
                        data: linkBody,
                    };
                    await sendRequestToC4C(linkToContactC4CParameters);
                }
            }
        }
        catch (error) {
            console.log(error.message);
        }
    }
}

module.exports = { getObjectsWithDifferentPropertyValue, createAttachmentBody, linkSelectedOpportunity, createNewCustomerInRemote };