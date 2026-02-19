pageextension 60101 "Ship-to Address CHEP PageExt" extends "Ship-to Address"
{
    layout
    {
        addlast(Content)
        {
            field("CHEP No."; Rec."CHEP No.")
            {
                ApplicationArea = All;
            }
        }
    }
}