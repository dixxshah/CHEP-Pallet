page 60131 "CHEP Export Log"
{
    Caption = 'CHEP Export Log';
    PageType = List;
    SourceTable = "CHEP Export Log";
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Source Type"; Rec."Source Type") { ApplicationArea = All; }
                field("Batch Id"; Rec."Batch Id") { ApplicationArea = All; }
                field("Shipment No."; Rec."Shipment No.") { ApplicationArea = All; }
                field("Shipment Date"; Rec."Shipment Date") { ApplicationArea = All; }
                field("Ship-to Code"; Rec."Ship-to Code") { ApplicationArea = All; }
                field("From Code"; Rec."From Code") { ApplicationArea = All; }
                field("CHEP No."; Rec."CHEP No.") { ApplicationArea = All; }
                field("CHEP Qty"; Rec."CHEP Qty") { ApplicationArea = All; }
                field("External Document No."; Rec."External Document No.") { ApplicationArea = All; }
                field("Exported At"; Rec."Exported At") { ApplicationArea = All; }
                field("Exported By"; Rec."Exported By") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Export CHEP CSV")
            {
                ApplicationArea = All;
                Caption = 'Export CHEP CSV';
                Image = Export;
                trigger OnAction()
                var
                    CHEPExport: Codeunit "CHEP CSV Export";
                begin
                    CHEPExport.ExportNewShipments();
                end;
            }
            action("Reset for Testing")
            {
                ApplicationArea = All;
                Caption = 'Reset for Testing';
                Image = Restore;
                trigger OnAction()
                var
                    CHEPReset: Codeunit "CHEP Test Reset";
                begin
                    CHEPReset.ResetExportData();
                end;
            }
        }
    }
}
