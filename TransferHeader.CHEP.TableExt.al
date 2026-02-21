tableextension 60107 "Transfer Header CHEP Ext" extends "Transfer Header"
{
    fields
    {
        field(60100; "CHEP Qty"; Integer)
        {
            Caption = 'CHEP Qty';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
    }
}
