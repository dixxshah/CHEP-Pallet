tableextension 60102 "Sales Shpt CHEP Ext" extends "Sales Shipment Header"
{
    fields
    {
        field(60100; "CHEP Qty"; Integer) { Caption = 'CHEP Qty'; MinValue = 0; }
        field(60101; "CHEP No."; Code[20]) { Caption = 'CHEP No.'; }

        field(60102; "CHEP Export Status"; Enum "CHEP Export Status") { Caption = 'CHEP Export Status'; }
        field(60103; "CHEP Exported At"; DateTime) { Caption = 'CHEP Exported At'; }
        field(60104; "CHEP Export Batch Id"; Code[20]) { Caption = 'CHEP Export Batch Id'; }
    }
}