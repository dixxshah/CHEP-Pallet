tableextension 60101 "Sales Header CHEP Ext" extends "Sales Header"
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