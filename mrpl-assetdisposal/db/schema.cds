namespace sap.mrpl.assetdisposal;

using {
    cuid,
    managed
} from '@sap/cds/common';

entity CADARequests : cuid, managed {
    RequestNo : String(20);
    RequestDate : Date;
    Plant : Association to Plants;
    Department : Association to Departments;
    RequestedBy : String(20);
    RequestedByName : String(120);
    BuyBackApplicable : Boolean default false;
    CSRDistribution : Boolean default false;
    FinanceComment : LargeString;
    NoteForApproval : LargeString;
    VersionNo : Integer default 1;
    ModeOfDisposalRecommended : LargeString;
    RepairTransferredTo : LargeString;
    ReasonForDisposal : LargeString;
    AlternativeUsesExplored : LargeString;
    TotalOriginalCost : Decimal(15,2);
    TotalWrittenDownValue : Decimal(15,2);
    WorkflowStatus : WorkflowStatus default 'Draft';
    WorkflowInstanceId : String(100);
    TaskInstanceId : String(100);
    CurrentApproverId : String(50);
    CurrentApproverName : String(120);
    SubmittedOn : Timestamp;
    ApprovedOn : Timestamp;
    items : Composition of many CADAAssets on items.parent = $self;
    approvals : Composition of many ApprovalHistory on approvals.parent = $self;
    comments : Composition of many Comments on comments.parent = $self;
    attachments : Composition of many Attachments on attachments.parent = $self;
}

entity CADAAssets : cuid, managed {
    parent : Association to CADARequests;
    AssetNumber : String(30);
    AssetDescription : String(500);
    ItemCoverage : CoverageType;
    Quantity : Decimal(13,3);
    UOM : String(10);
    AssetLocation : String(100);
    ExistingPONumber : String(20);
    ExistingPODate : Date;
    ReplacementRequired : Boolean default false;
    NewPRNumber : String(20);
    BudgetCode : String(30);
    OriginalCost : Decimal(15,2);
    WrittenDownValue : Decimal(15,2);
    RebateOriginalCost : Decimal(15,2);
    RebateWrittenDownValue : Decimal(15,2);
    RebateClaimYear : String(4);
    DisposalType : DisposalType;
    EstimatedSaleValue : Decimal(15,2);
    Remarks : LargeString;
}

entity ApprovalHistory : cuid, managed {
    parent : Association to CADARequests;
    LevelNo : Integer;
    ApproverId : String(20);
    ApproverName : String(120);
    Designation : String(120);
    ApprovalStatus : ApprovalStatus;
    Remarks : LargeString;
    ActionDate : Timestamp;
}

entity Comments : cuid, managed {
    parent : Association to CADARequests;
    EmployeeId : String(20);
    EmployeeName : String(120);
    Status : String(30);
    CommentDate : Timestamp;
    CommentText : LargeString;
}

entity Attachments : cuid, managed {
    parent : Association to CADARequests;
    FileName : String(255);
    MimeType : String(100);
    FileSize : Integer;
    DocumentId : String(100);
    RepositoryType : String(50);
    UploadedBy : String(120);
    UploadedOn : Timestamp;
}

entity ApprovalMatrix : cuid, managed {
    Plant : Association to Plants;
    DisposalMode : Association to DisposalModes;
    MinAmount : Decimal(15,2);
    MaxAmount : Decimal(15,2);
    ApprovalLevel : Integer;
    ApproverRole : String(50);
    Active : Boolean default true;
}

type WorkflowStatus : String enum {
    Draft; Submitted; InApproval; Approved; Rejected; Cancelled;
}

type ApprovalStatus : String enum {
    Pending; Approved; Rejected; Returned;
}

type DisposalType : String enum {
    Scrap; Sale; Transfer; BuyBack; Donation; CSR;
}

type CoverageType : String enum {
    Complete; Partial;
}

entity Plants {
    key PlantCode : String(10);
    PlantName : String(100);
    CompanyCode : String(10);
    Active : Boolean default true;
}

entity Departments {
    key DeptCode : String(20);
    DeptName : String(100);
    Plant : Association to Plants;
    Active : Boolean default true;
}

entity DisposalModes {
    key ModeCode : String(20);
    Description : String(100);
    Active : Boolean default true;
}

entity Employees {
    key EmployeeId : String(20);
    EmployeeName : String(120);
    Email : String(255);
    Designation : String(100);
    Department : Association to Departments;
}