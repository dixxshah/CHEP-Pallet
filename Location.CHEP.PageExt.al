pageextension 60104 "Location Card CHEP Ext" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("CHEP From"; Rec."CHEP From")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the CHEP account code for this location, used as the From code in CHEP pallet transfers.';
            }
        }
    }
}
