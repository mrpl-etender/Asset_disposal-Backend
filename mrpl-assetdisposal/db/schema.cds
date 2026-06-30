namespace sap.mrpl.assetdisposal;

using {
    cuid,
    managed, sap.common.CodeList
} from '@sap/cds/common';

entity AssetDisposalMaster : managed {
   key RequestNo       : String(10) @title: 'Request No';

    ProcessCode         : Association to one ProcessCode default 'X'
                            @title: 'Process Code';

    DocumentStatus      : Association to one DocumentStatus default 'X'
                            @title: 'Document Status';

    WorkflowStatus      : Association to one WorkflowStatus default 'Draft'
                            @title: 'Workflow Status';

    cada                : Composition of one CADARequests
                            on cada.RequestNo = $self;

    attachments         : Composition of many Attachments
                            on attachments.interaction = $self;
}

@cds.odata.valuelist
entity ProcessCode : CodeList {
    key code : String enum {
        new   = 'X';
        CADA  = 'A';
    };
    criticality : Integer;
}

@cds.odata.valuelist
entity DocumentStatus : CodeList {
    key code : String enum {
        NotCreated = 'X';
        Created    = 'C';
        Submitted  = 'S';
        Completed  = 'E';
    };
    criticality : Integer;
}

@cds.odata.valuelist
entity WorkflowStatus : CodeList {
    key code        : String enum {
        NotStarted = 'X';
        Rejected   = 'R';
        Pending    = 'P';
        Approved   = 'A';
    };
    criticality     : Integer;
}

entity CADARequests : managed {
    key RequestNo : Association to one AssetDisposalMaster;
    key CADANo : String(10);
    key VersionNo : Integer;
    RequestDate : Date;

    // @mandatory
    Plant : String(4);

    // @mandatory
    Department : String(10);

    RequestedBy : String(20);
    RequestedByName : String(120);

    // @mandatory
    BuyBackApplicable : String;

    // @mandatory
    CSRDistribution : String;

    FinanceComment : LargeString;
    NoteForApproval : LargeString;
    
    ModeOfDisposalRecommended : LargeString;
    RepairTransferredTo : LargeString;

    // @mandatory
    ReasonForDisposal : LargeString;

    AlternativeUsesExplored : LargeString;
    TotalOriginalCost : Decimal(15,2);
    TotalWrittenDownValue : Decimal(15,2);

    items : Composition of many CADAAssets on items.interaction = $self;
    approvals : Composition of many CADAApprovals on approvals.interaction = $self;
    // attachments : Composition of many Attachments on attachments.interaction = $self; 
    // comments : Composition of many CADAComments on comments.interaction = $self;
}

entity CADAAssets : cuid, managed {
    interaction : Association to one CADARequests;

    key CADANo : String(10);
    key ID : Integer;
    key VersionNo : Integer;

    // @mandatory
    AssetNumber : String(12);

    // @mandatory
    AssetDescription : String(50);

    // @mandatory
    ItemCoverage : String(30);

    // @mandatory
    Quantity : Decimal(13,3);

    // @mandatory
    UOM : String(3);

    AssetLocation : String(50);
    ExistingPONumber : String(20);
    ExistingPODate : Date;
    ReplacementRequired : String;
    NewPRNumber : String(20);
    BudgetCode : String(30);
    OriginalCost : Decimal(15,2);
    WrittenDownValue : Decimal(15,2);

    // @mandatory
    RebateClaimYear : String(4);

    DisposalType : Association to one DisposalType default 'Scrap'
                   @title: 'Disposal Type';

    EstimatedSaleValue : Decimal(15,2);
    Remarks : LargeString;
}

entity CADAApprovals :  managed {
        interaction : Association to  CADARequests;
    key CADANo      : String(10);
    key VersionNo   : Integer;
    key Emp_Code    : String(8)
        @assert.notNull: false;
    key Level       : Integer
        @assert.notNull: false;
        Emp_email   : String(30);
        Emp_name    : String(100);
        Emp_Desg    : String(100);
        Emp_Auth_l  : String(50);
        Next_level  : Integer;
        Status      : String(20);
        Department  : String;
        Remark      : String(1000);
}

entity EmpAuthLevels {
    key Level_ID        : Integer;
        description : String(100);
}

entity CADAComments : cuid, managed {
    interaction : Association to CADARequests;
    EmployeeId : String(20);
    EmployeeName : String(120);
    Status : String(30);
    CommentDate : Timestamp;
    CommentText : LargeString;
}

entity Attachments : cuid, managed {
    interaction : Association to AssetDisposalMaster;
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

entity EmployeeMaster {
    key Emp_Code        : String(50);   
    Emp_name            : String(255);  
    Emp_Auth_l          : String(100); 
    Emp_Sub             : String(500);  
    Emp_Desg            : String(255);  
    Emp_email           : String(255);  
    Emp_phone           : String(50);   
    Department          : String(100);  
    Department_code     : String(50);   
    Po_off_code         : String(50);   
}

entity AssetMaster {
    key AssetNo : String(12);
    AssetDescription : String(50);
    UOM : Association to UOM;
    AssetLocation : String(50);
    Active : Boolean default true;
}

entity UOM {
    key UOMCode : String(10);
    UOMDescription : String(50);
    Active : Boolean default true;
}