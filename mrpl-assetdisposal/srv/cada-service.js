const cds = require('@sap/cds');
const SequenceHelper = require('./lib/SequenceHelper');
const { CADARequests, CADAAssets, CadaApp} = cds.entities('sap.mrpl.assetdisposal');
const {SELECT,INSERT,UPDATE,DELETE} = require("@sap/cds/lib/ql/cds-ql");

module.exports = cds.service.impl((srv) => {
    srv.before("CREATE", "AssetDisposalMaster", _AssetDisposalSequenceR);
    srv.on("createNewVersion", _createNewVersion);
});

const _AssetDisposalSequenceR = async (req) => {
    try {
        const masterDef = cds.model.definitions['sap.mrpl.assetdisposal.AssetDisposalMaster'];
        const masterTable = masterDef['@cds.persistence.name'] || masterDef.name.replace(/\./g, '_').toUpperCase();

        const masterSeqHelper = new SequenceHelper({
            db: cds.db,
            sequence: 'RequestNoSeq',
            table: masterTable,
            field: 'RequestNo'
        });

        const nextMasterNo = await masterSeqHelper.getNextNumber();
        const generatedRequestNo = String(nextMasterNo).padStart(3, '0');
        req.data.RequestNo = generatedRequestNo;

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

            const generatedCadaNo = String(nextCadaNo);

            req.data.cada.CADANo = generatedCadaNo;
            req.data.cada.RequestNo_RequestNo = generatedRequestNo;

            if (req.data.cada.items && Array.isArray(req.data.cada.items)) {
                req.data.cada.items.forEach(item => {
                    item.CADANo = generatedCadaNo;
                    if (req.data.cada.VersionNo) {
                        item.VersionNo = req.data.cada.VersionNo;
                    }
                });
            }

            if (req.data.cada.approvals && Array.isArray(req.data.cada.approvals)) {
                req.data.cada.approvals.forEach(app => {
                    app.CADANo = generatedCadaNo;
                });
            }
        }

    } catch (err) {
        console.error('>>> Error in combined sequence generation:', err);
        req.error(500, `Failed to initialize request sequence keys: ${err.message}`);
    }

}

const _createNewVersion = async (req) => {

    try {
        let { RequestNo } = req.data;

        if (!RequestNo) {
            return req.error(400, "Missing required parameter: RequestNo");
        }

        RequestNo = String(RequestNo).trim().replace(/^['"]+|['"]+$/g, '');

        const existingRequest = await SELECT.one.from(CADARequests).where({RequestNo_RequestNo: RequestNo}).orderBy({VersionNo: 'desc'});

        if (!existingRequest) {
            return req.error(404, `No CADA Request found for RequestNo: ${RequestNo}`);
        }

        const fixedCADANo = existingRequest.CADANo;
        const newVersionNo = existingRequest.VersionNo + 1;

        const existingAssets = await SELECT.from(CADAAssets)
            .where({
                interaction_CADANo: fixedCADANo,
                interaction_RequestNo_RequestNo: RequestNo,
                interaction_VersionNo: existingRequest.VersionNo
            });

        const existingApprovals = await SELECT.from(CadaApp)
            .where({
                interaction_CADANo: fixedCADANo,
                interaction_RequestNo_RequestNo: RequestNo,
                interaction_VersionNo: existingRequest.VersionNo
            });

        const skipFields = ['CADANo', 'RequestNo_RequestNo', 'VersionNo', 'createdAt', 'createdBy', 'modifiedAt', 'modifiedBy'];

        const newRequest = {
            ...Object.fromEntries(Object.entries(existingRequest).filter(([k]) => !skipFields.includes(k))),
            CADANo: fixedCADANo,
            RequestNo_RequestNo: RequestNo,
            VersionNo: newVersionNo,
            createdAt: new Date(),
            createdBy: req.user?.id ?? 'system',
            modifiedAt: new Date(),
            modifiedBy: req.user?.id ?? 'system',
        };

        await INSERT.into(CADARequests).entries(newRequest);

        if (existingAssets?.length > 0) {
            const assetSkipFields = ['CADANo', 'VersionNo', 'interaction_CADANo', 'interaction_RequestNo_RequestNo', 'interaction_VersionNo', 'createdAt', 'createdBy', 'modifiedAt', 'modifiedBy'];

            const newAssets = existingAssets.map(asset => ({
                ...Object.fromEntries(Object.entries(asset).filter(([k]) => !assetSkipFields.includes(k))),
                CADANo: fixedCADANo,
                VersionNo: newVersionNo,
                interaction_CADANo: fixedCADANo,
                interaction_RequestNo_RequestNo: RequestNo,
                interaction_VersionNo: newVersionNo,
                createdAt: new Date(),
                createdBy: req.user?.id ?? 'system',
                modifiedAt: new Date(),
                modifiedBy: req.user?.id ?? 'system',
            }));

            await INSERT.into(CADAAssets).entries(newAssets);
        }

        if (existingApprovals?.length > 0) {
            const appSkipFields = ['CADANo', 'VersionNo', 'interaction_CADANo', 'interaction_RequestNo_RequestNo', 'interaction_VersionNo', 'createdAt', 'createdBy', 'modifiedAt', 'modifiedBy'];

            const newApprovals = existingApprovals.map(app => ({
                ...Object.fromEntries(Object.entries(app).filter(([k]) => !appSkipFields.includes(k))),
                CADANo: fixedCADANo,
                VersionNo: newVersionNo,
                interaction_CADANo: fixedCADANo,
                interaction_RequestNo_RequestNo: RequestNo,
                interaction_VersionNo: newVersionNo,
                createdAt: new Date(),
                createdBy: req.user?.id ?? 'system',
                modifiedAt: new Date(),
                modifiedBy: req.user?.id ?? 'system',
            }));

            await INSERT.into(CadaApp).entries(newApprovals);
        }

        return {
            CADANo: fixedCADANo,
            newVersionNo,
            message: `Version ${newVersionNo} created for RequestNo ${RequestNo} (CADANo: ${fixedCADANo})`
        };

    } catch (err) {
        console.error('>>> Error in createNewVersion:', err);
        req.error(500, `Failed to create new version: ${err.message}`);
    }
}