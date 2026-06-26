namespace sap.mrpl.assetdisposal;

using {
    cuid,
    managed, sap.common.CodeList
} from '@sap/cds/common';

entity AssetDisposalMaster : cuid, managed {
   key RequestNo       : String(10) @title: 'Request No';

    ProcessCode         : Association to one ProcessCode default 'X'
                            @title: 'Process Code';

    DocumentStatus      : Association to one DocumentStatus default 'X'
                            @title: 'Document Status';

    WorkflowStatus      : Association to one WorkflowStatus default 'Draft'
                            @title: 'Workflow Status';

    cada                : Composition of one CADARequests
                            on cada.RequestNo = $self;
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
    CADANo : String(10);
    key RequestNo : Association to one AssetDisposalMaster;
    RequestDate : Date;

    @mandatory
    Plant : String(25);

    @mandatory
    Department : String(50);

    RequestedBy : String(20);
    RequestedByName : String(120);

    @mandatory
    BuyBackApplicable : String;

    @mandatory
    CSRDistribution : String;

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

    items : Composition of many CADAAssets on items.parent = $self;
    approvals : Composition of many CadaApp on approvals.parent = $self;
    comments : Composition of many Comments on comments.parent = $self;
    attachments : Composition of many Attachments on attachments.parent = $self; 
}

entity CADAAssets : cuid, managed {
    parent : Association to CADARequests;

    @mandatory
    AssetNumber : String(30);

    @mandatory
    AssetDescription : String(500);

    @mandatory
    ItemCoverage : String(30);

    @mandatory
    Quantity : Decimal(13,3);

    @mandatory
    UOM : String(10);

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

entity CadaApp :  managed {
        parent : Association to  CADARequests;
    key ID          : String(10);
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
    key code        : String(50);
        description : String(100);
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