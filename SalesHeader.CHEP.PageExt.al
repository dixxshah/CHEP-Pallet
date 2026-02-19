pageextension 60102 "Sales Order CHEP Ext" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("CHEP Qty"; Rec."CHEP Qty")
            {
                ApplicationArea = All;
            }
        }
    }
}