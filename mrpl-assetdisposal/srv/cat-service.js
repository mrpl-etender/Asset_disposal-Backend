const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {
    const { AssetDisposalMaster } = this.entities;
    const { CADARequests } = this.entities;

    this.before('CREATE', 'AssetDisposalMaster', async (req) => {
        
        // 1. Fetch ALL existing RequestNos to handle string sorting correctly in JavaScript
        const records = await SELECT.from(AssetDisposalMaster).columns('RequestNo');

        let maxNumber = 0;

        // 2. Loop through and find the actual numeric maximum
        if (records && records.length > 0) {
            records.forEach(rec => {
                if (rec.RequestNo) {
                    const num = parseInt(rec.RequestNo, 10);
                    if (!isNaN(num) && num > maxNumber) {
                        maxNumber = num;
                    }
                }
            });
        }

        // 3. Increment the highest number found
        const nextNumber = maxNumber + 1;
        const paddingLength = nextNumber >= 1000 ? String(nextNumber).length : 3;
        const formattedRequestNo = String(nextNumber).padStart(paddingLength, '0');

        // 5. Assign to payload
        req.data.RequestNo = formattedRequestNo;
    });

    this.before('CREATE', 'CADARequests', async (req) => {
        
        // 1. Fetch the highest existing CADANo from the database
        const lastRequest = await SELECT.one.from(CADARequests).columns('CADANo').orderBy('CADANo desc');

        let nextNumber;

        if (lastRequest && lastRequest.CADANo) {
            // 2. If records exist, increment the highest number by 1
            const lastNum = parseInt(lastRequest.CADANo, 10);
            nextNumber = lastNum + 1;
        } else {
            // 3. Fallback for the very first record in the database
            nextNumber = 1000000001;
        }

        // 4. Assign the generated 10-digit string to the payload
        req.data.CADANo = String(nextNumber);
    });
});