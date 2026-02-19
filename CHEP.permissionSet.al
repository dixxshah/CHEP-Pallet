permissionset 60130 "CHEP PALLET"
{
    Caption = 'CHEP Pallet';
    Assignable = true;

    Permissions =
        tabledata "Sales Shipment Header" = RM,
        tabledata "Sales Shipment Line" = R; // optional if you later need lines
}