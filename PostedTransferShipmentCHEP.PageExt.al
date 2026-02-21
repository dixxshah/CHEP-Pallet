pageextension 60108 "Posted Transfer Shpt CHEP Ext" extends "Posted Transfer Shipment"
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

                field("CHEP From"; Rec."CHEP From")
                {
                    ApplicationArea = All;
                }

                field("CHEP To"; Rec."CHEP To")
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
                trigger OnAction()
                var
                    CHEPExport: Codeunit "CHEP CSV Export";
                begin
                    CHEPExport.ExportNewShipments();
                end;
            }
        }
    }
}
