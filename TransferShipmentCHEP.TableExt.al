tableextension 60108 "Transfer Shipment CHEP Ext" extends "Transfer Shipment Header"
{
    fields
    {
        field(60100; "CHEP Qty"; Integer)
        {
            Caption = 'CHEP Qty';
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(60101; "CHEP From"; Code[20])
        {
            Caption = 'CHEP From';
            DataClassification = CustomerContent;
        }

        // The destination CHEP account code — taken from the Transfer-to Location's CHEP From field
        field(60102; "CHEP To"; Code[20])
        {
            Caption = 'CHEP To';
            DataClassification = CustomerContent;
        }

        field(60103; "CHEP Export Status"; Enum "CHEP Export Status")
        {
            Caption = 'CHEP Export Status';
            DataClassification = CustomerContent;
        }

        field(60104; "CHEP Exported At"; DateTime)
        {
            Caption = 'CHEP Exported At';
            DataClassification = SystemMetadata;
        }

        field(60105; "CHEP Export Batch Id"; Code[20])
        {
            Caption = 'CHEP Export Batch Id';
            DataClassification = CustomerContent;
        }
    }
}
