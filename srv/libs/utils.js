
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

module.exports = { getObjectsWithDifferentPropertyValue, createAttachmentBody };