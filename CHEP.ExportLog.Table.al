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

        field(10; "From Code"; Code[20])
        {
            Caption = 'From Code';
            DataClassification = CustomerContent;
        }

        field(11; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }

        field(12; "Source Type"; Enum "CHEP Source Type")
        {
            Caption = 'Source Type';
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
    var
        LastLog: Record "CHEP Export Log";
    begin
        // Auto-increment Entry No.
        // Use a separate record variable so FindLast() does not overwrite
        // the current buffer's SystemId, which would cause a duplicate key error.
        if "Entry No." = 0 then begin
            if LastLog.FindLast() then
                "Entry No." := LastLog."Entry No." + 1
            else
                "Entry No." := 1;
        end;
    end;
}