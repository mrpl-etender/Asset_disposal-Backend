using sap.mrpl.assetdisposal as db from '../db/schema';

<<<<<<< HEAD
@requires: 'authenticated-user'
=======
//@requires: 'authenticated-user'
>>>>>>> 68e6d3c (24-06-2026)


service CapitalAssetsDisposalService  {
       
    entity CADARequests as projection on db.CADARequests;
    entity CADAAssets as projection on db.CADAAssets;
    entity ApprovalHistory as projection on db.ApprovalHistory;
    entity Comments as projection on db.Comments;
    entity Attachments as projection on db.Attachments;
    entity Plants as projection on db.Plants;
    entity Departments as projection on db.Departments;
    entity DisposalModes as projection on db.DisposalModes;
    entity Employees as projection on db.Employees;   
}
