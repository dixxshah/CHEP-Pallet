permissionset 60130 "CHEP PALLET"
{
    Caption = 'CHEP Pallet';
    Assignable = true;

    Permissions =
        tabledata "Sales Shipment Header" = RM,
        tabledata "Sales Shipment Line" = R, // optional if you later need lines
        tabledata Location = R,
        tabledata "CHEP Export Log" = RIMD,
        page "CHEP Export Log" = X,
        codeunit "CHEP CSV Export" = X,
        codeunit "CHEP Test Reset" = X;
}