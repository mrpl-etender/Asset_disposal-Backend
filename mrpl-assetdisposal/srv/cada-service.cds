using sap.mrpl.assetdisposal as db from '../db/schema';
using ZMM_DAN_TO_SALES_SRV as assetdisposal_S4 from './external/ZMM_DAN_TO_SALES_SRV.csn';


service CapitalAssetsDisposalService  {
       
    entity AssetDisposalMaster as projection on db.AssetDisposalMaster;
    entity CADARequests as projection on db.CADARequests;
    entity CADAAssets as projection on db.CADAAssets;
    entity CADAApprovals as projection on db.CADAApprovals;
    entity CADAComments as projection on db.CADAComments;
    entity Attachments as projection on db.Attachments;
    entity Plants as projection on assetdisposal_S4.PlantSet;
    entity Departments as projection on assetdisposal_S4.Controlling_DeptSet;
    entity DisposalModes as projection on db.DisposalModes;
    entity EmployeeMaster as projection on db.EmployeeMaster; 
    entity EmployeeAuthMaster  as projection on db.EmpAuthLevels;
    entity AssetMaster as projection on db.AssetMaster;
    entity UOM as projection on db.UOM;

    function createCADARequestVersion(RequestNo : String) returns {
        CADANo       : String;
        newVersionNo : Integer;
        message      : String;
    };

}
