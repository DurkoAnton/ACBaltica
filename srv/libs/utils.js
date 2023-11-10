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

async function createItemsBody(items, itemProductTable, opportunityID) {
    let results = [];
    for (let item of items) {
        const itemProduct = await SELECT.one.from(itemProductTable).where({ InternalID: item.ProductID })
        if (itemProduct) {
            let itemInst = {
                toOpportunity_ID: opportunityID,
                ItemProductID: itemProduct.ID
            }
            results.push(itemInst)
        }
    }
    return results;
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

                const result = await UPDATE(customerEntity, customerData.ID).with({ UUID: UUID, ObjectID: objectID, InternalID: internalID });
                //link new customer and current contact
                //if (req.headers['x-username']) {
                    const email = 'andrei_matys@atlantconsult.com';
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
                //}
            }
        }
        catch (error) {
            console.log(error.message);
        }
    }
}

async function deleteCustomerInstances(c4cResponse, customersFromDB, Customer) {
    const partnerId = c4cResponse.data.d.results[0].ContactID;
    const corporateAccounts = c4cResponse.data.d.results[0].ContactIsContactPersonFor;
    const partnerCustomersFromDB = customersFromDB.filter(obj => obj.MainContactID === partnerId);

    // get objects from one array that are not present in another array of objects
    // customers in DB that are not in remote will be deleted
    const customersToBeDeleted = partnerCustomersFromDB.filter(obj1 => !corporateAccounts.some(obj2 => obj2.CorporateAccount.UUID === obj1.UUID) && obj1.UUID != null);
    if (customersToBeDeleted.length) {
        const customerUUIDs = customersToBeDeleted.map(item => item.UUID);
        await DELETE.from(Customer).where({ UUID: customerUUIDs });
    }
}

async function deleteOpportunityInstances(c4cResponse, opportunitiesFromDB, Opportunity) {
    const opportunitiesFromRemote = c4cResponse.data.d.results;

    const opportunitiesToBeDeleted = opportunitiesFromDB.filter(obj1 => !opportunitiesFromRemote.some(obj2 => obj2.UUID === obj1.UUID));
    if (opportunitiesToBeDeleted.length) {
        const opportunityUUIDs = opportunitiesToBeDeleted.map(item => item.UUID);
        await DELETE.from(Opportunity).where({ UUID: opportunityUUIDs });
    }
}

async function deleteServiceRequestInstances(c4cResponse, serviceRequestsFromDB, ServiceRequest) {
    const serviceRequestsFromRemote = c4cResponse.data.d.results;

    const serviceRequestsToBeDeleted = serviceRequestsFromDB.filter(obj1 => !serviceRequestsFromRemote.some(obj2 => obj2.UUID === obj1.UUID) && obj1.UUID != null);
    if (serviceRequestsToBeDeleted.length) {
        const serviceRequestUUIDs = serviceRequestsToBeDeleted.map(item => item.UUID);
        await DELETE.from(ServiceRequest).where({ UUID: serviceRequestUUIDs });
    }
}

module.exports = { getObjectsWithDifferentPropertyValue, createAttachmentBody, linkSelectedOpportunity, createNewCustomerInRemote, createItemsBody, deleteCustomerInstances, deleteOpportunityInstances, deleteServiceRequestInstances };