table 60131 "CHEP Export Log"
{
    Caption = 'CHEP Export Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Shipment No."; Code[20])
        {
            Caption = 'Shipment No.';
            DataClassification = CustomerContent;
        }

        field(3; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
            DataClassification = CustomerContent;
        }

        field(4; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
        }

        field(5; "CHEP No."; Code[20])
        {
            Caption = 'CHEP No.';
            DataClassification = CustomerContent;
        }

        field(6; "CHEP Qty"; Integer)
        {
            Caption = 'CHEP Qty';
            MinValue = 0;
            DataClassification = CustomerContent;
        }

        field(7; "Exported At"; DateTime)
        {
            Caption = 'Exported At';
            DataClassification = SystemMetadata;
        }

        field(8; "Exported By"; Code[50])
        {
            Caption = 'Exported By';
            DataClassification = SystemMetadata;
        }

        field(9; "Batch Id"; Code[20])
        {
            Caption = 'Batch Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(Key2; "Batch Id")
        {
        }

        key(Key3; "Shipment No.")
        {
        }
    }

    trigger OnInsert()
    begin
        // Auto-increment Entry No.
        if "Entry No." = 0 then begin
            if not FindLast() then
                "Entry No." := 1
            else
                "Entry No." := "Entry No." + 1;
        end;
    end;
}