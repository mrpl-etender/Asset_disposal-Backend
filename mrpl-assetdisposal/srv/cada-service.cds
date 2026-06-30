using sap.mrpl.assetdisposal as db from '../db/schema';



service CapitalAssetsDisposalService  {
       
    entity AssetDisposalMaster as projection on db.AssetDisposalMaster;
    entity CADARequests as projection on db.CADARequests;
    entity CADAAssets as projection on db.CADAAssets;
    entity CadaApp as projection on db.CadaApp;
    entity Comments as projection on db.Comments;
    entity Attachments as projection on db.Attachments;
    entity Plants as projection on db.Plants;
    entity Departments as projection on db.Departments;
    entity DisposalModes as projection on db.DisposalModes;
    entity Employees as projection on db.Employees; 
    entity EmployeeAuthMaster  as projection on db.EmpAuthLevels;
    entity AssetMaster as projection on db.AssetMaster;
    entity UOM as projection on db.UOM;

    function createNewVersion(RequestNo : String) returns {
        CADANo       : String;
        newVersionNo : Integer;
        message      : String;
    };

}
