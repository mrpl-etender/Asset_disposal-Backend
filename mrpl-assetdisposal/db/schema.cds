namespace sap.mrpl.assetdisposal;

using {
    cuid,
    managed, sap.common.CodeList
} from '@sap/cds/common';

entity CADARequests : cuid, managed {
    RequestNo : String(20);
    RequestDate : Date;

    @mandatory
    Plant : Association to Plants;

    @mandatory
    Department : Association to Departments;

    RequestedBy : String(20);
    RequestedByName : String(120);

    @mandatory
    BuyBackApplicable : Boolean default false;

    @mandatory
    CSRDistribution : Boolean default false;
    
    FinanceComment : LargeString;
    NoteForApproval : LargeString;
    VersionNo : Integer default 1;
    ModeOfDisposalRecommended : LargeString;
    RepairTransferredTo : LargeString;

    @mandatory
    ReasonForDisposal : LargeString;
    
    AlternativeUsesExplored : LargeString;
    TotalOriginalCost : Decimal(15,2);
    TotalWrittenDownValue : Decimal(15,2);

    WorkflowStatus : Association to one WorkflowStatus default 'Draft'
                     @title: 'Workflow Status';
                     
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

    @mandatory
    AssetNumber :  Association to AssetMaster;

    @mandatory
    AssetDescription : String(500);

    @mandatory
    ItemCoverage : Association to one CoverageType default 'Partial'
                   @title: 'Item Coverage';

    @mandatory
    Quantity : Decimal(13,3);

    @mandatory
    UOM : Association to UOM;
    
    AssetLocation : String(100);
    ExistingPONumber : String(20);
    ExistingPODate : Date;
    ReplacementRequired : Boolean default false;
    NewPRNumber : String(20);
    BudgetCode : String(30);
    OriginalCost : Decimal(15,2);
    WrittenDownValue : Decimal(15,2);

    @mandatory
    RebateOriginalCost : Decimal(15,2);
    @mandatory
    RebateWrittenDownValue : Decimal(15,2);
    @mandatory
    RebateClaimYear : String(4);
    
    DisposalType : Association to one DisposalType default 'Scrap'
                   @title: 'Disposal Type';

    EstimatedSaleValue : Decimal(15,2);
    Remarks : LargeString;
}

entity ApprovalHistory : cuid, managed {
    parent : Association to CADARequests;
    LevelNo : Integer;
    ApproverId : String(20);
    ApproverName : String(120);
    Designation : String(120);
    
    ApprovalStatus : Association to one ApprovalStatus default 'Pending'
                     @title: 'Approval Status';

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

@cds.odata.valuelist
entity WorkflowStatus : CodeList {
    key code : String enum {
        Draft      = 'Draft';
        Submitted  = 'Submitted';
        InApproval = 'InApproval';
        Approved   = 'Approved';
        Rejected   = 'Rejected';
        Cancelled  = 'Cancelled';
    };
    criticality : Integer;
}

@cds.odata.valuelist
entity ApprovalStatus : CodeList {
    key code : String enum {
        Pending  = 'Pending';
        Approved = 'Approved';
        Rejected = 'Rejected';
        Returned = 'Returned';
    };
    criticality : Integer;
}

@cds.odata.valuelist
entity DisposalType : CodeList {
    key code : String enum {
        Scrap    = 'Scrap';
        Sale     = 'Sale';
        Transfer = 'Transfer';
        BuyBack  = 'BuyBack';
        Donation = 'Donation';
        CSR      = 'CSR';
    };
    criticality : Integer;
}

@cds.odata.valuelist
entity CoverageType : CodeList {
    key code : String enum {
        Complete = 'Complete';
        Partial  = 'Partial';
    };
    criticality : Integer;
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

entity AssetMaster {
    key AssetNo : String(30);
    AssetDescription : String(500);
    UOM : Association to UOM;
    AssetLocation : String(100);
    Active : Boolean default true;
}

entity UOM {
    key UOMCode : String(10);
    UOMDescription : String(50);
    Active : Boolean default true;
}