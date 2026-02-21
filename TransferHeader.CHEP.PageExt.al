pageextension 60107 "Transfer Order CHEP Ext" extends "Transfer Order"
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
