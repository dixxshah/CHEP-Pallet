pageextension 60103 "Posted Sales Shpt CHEP Ext" extends "Posted Sales Shipment"
{
    layout
    {
        addlast(Content)
        {
            group(CHEP)
            {
                Caption = 'CHEP';

                field("CHEP Qty"; Rec."CHEP Qty")
                {
                    ApplicationArea = All;
                }

                field("CHEP No."; Rec."CHEP No.")
                {
                    ApplicationArea = All;
                }

                field("CHEP From"; Rec."CHEP From")
                {
                    ApplicationArea = All;
                }

                field("CHEP Export Status"; Rec."CHEP Export Status")
                {
                    ApplicationArea = All;
                }

                field("CHEP Exported At"; Rec."CHEP Exported At")
                {
                    ApplicationArea = All;
                }

                field("CHEP Export Batch Id"; Rec."CHEP Export Batch Id")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addlast(Processing)
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
            action("Export CHEP Excel")
            {
                ApplicationArea = All;
                Caption = 'Export CHEP Excel';
                Image = ExportToExcel;
                trigger OnAction()
                var
                    CHEPExport: Codeunit "CHEP CSV Export";
                begin
                    CHEPExport.ExportNewShipmentsExcel();
                end;
            }
        }
    }
}