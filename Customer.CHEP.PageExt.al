pageextension 60106 "Customer Card CHEP Ext" extends "Customer Card"
{
    layout
    {
        // Add the field inside the existing Shipping FastTab
        addlast(Shipping)
        {
            field("CHEP No."; Rec."CHEP No.")
            {
                ApplicationArea = All;
                Caption = 'CHEP No.'; // keeps UI short without renaming the actual field
                ToolTip = 'Default CHEP account number for this customer (used when Ship-to does not override).';
            }
        }
    }
}