const cds = require('@sap/cds');
const SequenceHelper = require('./lib/SequenceHelper');

module.exports = cds.service.impl(async function () {

   this.before('CREATE', 'AssetDisposalMaster', async (req) => {
        try {
            // 1. GENERATE REQUESTNO 
            const masterDef = cds.model.definitions['sap.mrpl.assetdisposal.AssetDisposalMaster'];
            const masterTable = masterDef['@cds.persistence.name'] || masterDef.name.replace(/\./g, '_').toUpperCase();

            const masterSeqHelper = new SequenceHelper({
                db: cds.db,
                sequence: 'RequestNoSeq',
                table: masterTable,
                field: 'RequestNo'
            });

            const nextMasterNo = await masterSeqHelper.getNextNumber();
            const generatedRequestNo = String(nextMasterNo).padStart(3, '0'); // e.g., "001"
            req.data.RequestNo = generatedRequestNo;

            // 2. GENERATE CADANO 
            if (req.data.cada) {
                const cadaDef = cds.model.definitions['sap.mrpl.assetdisposal.CADARequests'];
                const cadaTable = cadaDef['@cds.persistence.name'] || cadaDef.name.replace(/\./g, '_').toUpperCase();

                const cadaSeqHelper = new SequenceHelper({
                    db: cds.db,
                    sequence: 'CADANoSeq',
                    table: cadaTable,
                    field: 'CADANo'
                });

                let nextCadaNo = await cadaSeqHelper.getNextNumber();

                if (cds.db.kind !== 'hana' && nextCadaNo === 1) {
                    nextCadaNo = 1000000001;
                }

                req.data.cada.CADANo = String(nextCadaNo);
                req.data.cada.RequestNo_RequestNo = generatedRequestNo;
            }

        } catch (err) {
            console.error('>>> Error in combined sequence generation:', err);
            req.error(500, `Failed to initialize request sequence keys: ${err.message}`);
        }
    });
});