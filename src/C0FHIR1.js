/**
 * Fetches and parses a FHIR Bundle from VistA
 * @param {string} dfn - Patient IEN
 * @param {string} sdt - Start Date (FileMan format, e.g., "3250101")
 * @param {string} edt - End Date (FileMan format, e.g., "3260130")
 */
async function getVistAFHIRBundle(dfn, sdt = "", edt = "") {
    const rpcName = 'C0FHIR GET FULL BUNDLE';
    const context = 'C0FHIR CONTEXT';
    
    // Parameters: [DFN, ENCPTR (null for bulk), SDT, EDT]
    const params = [dfn, "", sdt, edt];

    try {
        // 1. Call the Broker (Assume 'vistaClient' is your connected instance)
        const rawResponse = await vistaClient.execute(rpcName, params, context);

        // 2. Concatenate the Global Array (VistA returns an array of strings)
        const jsonString = rawResponse.join('');
        const bundle = JSON.parse(jsonString);

        // 3. Check for Backend Errors
        const error = bundle.entry.find(e => e.resource.resourceType === 'OperationOutcome');
        if (error) {
            throw new Error(`VistA Error: ${error.resource.issue[0].diagnostics}`);
        }

        processBundle(bundle);

    } catch (err) {
        console.error("Integration Failed:", err.message);
    }
}

/**
 * Extracts and decodes clinical data from the Bundle
 */
function processBundle(bundle) {
    bundle.entry.forEach(entry => {
        const resource = entry.resource;

        switch (resource.resourceType) {
            case 'Patient':
                console.log(`Patient: ${resource.name[0].text} (${resource.birthDate})`);
                break;
                
            case 'DocumentReference':
                // Decode TIU Note from Base64
                const noteText = atob(resource.content[0].attachment.data);
                console.log(`Note (${resource.type.text}):\n${noteText}`);
                break;

            case 'Observation':
                if (resource.category[0].coding[0].code === 'laboratory') {
                    console.log(`Lab: ${resource.code.text} = ${resource.valueQuantity.value} ${resource.valueQuantity.unit}`);
                }
                break;
        }
    });
}
