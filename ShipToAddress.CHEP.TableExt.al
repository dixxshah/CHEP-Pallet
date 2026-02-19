tableextension 60100 "ShipTo Address CHEP Ext" extends "Ship-to Address"
{
    fields
    {
        field(60100; "CHEP No."; Code[20])
        {
            Caption = 'CHEP No.';
            DataClassification = CustomerContent;
        }
    }
}