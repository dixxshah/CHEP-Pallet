codeunit 60120 "CHEP Posting Subscribers"
{
    // Allows writing to posted shipment header through this codeunit
    Permissions = tabledata "Sales Shipment Header" = RM;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterInsertShipmentHeader', '', false, false)]
    local procedure OnAfterInsertShipmentHeader(var SalesShipmentHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header")
    var
        Cust: Record Customer;
        ShipTo: Record "Ship-to Address";
        Loc: Record Location;
        ChepNo: Code[20];
    begin
        // Copy qty (assuming Sales Header field is still "CHEP Qty")
        SalesShipmentHeader."CHEP Qty" := SalesHeader."CHEP Qty";

        // Default CHEP No. from Customer
        if SalesHeader."Sell-to Customer No." <> '' then
            if Cust.Get(SalesHeader."Sell-to Customer No.") then
                ChepNo := Cust."CHEP No.";

        // Override CHEP No. from Ship-to if present + non-blank
        if (SalesHeader."Sell-to Customer No." <> '') and (SalesHeader."Ship-to Code" <> '') then
            if ShipTo.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then
                if ShipTo."CHEP No." <> '' then
                    ChepNo := ShipTo."CHEP No.";

        // Write resolved CHEP No. onto posted shipment
        SalesShipmentHeader."CHEP No." := ChepNo;

        // Resolve CHEP From code from the shipment Location
        if SalesHeader."Location Code" <> '' then
            if Loc.Get(SalesHeader."Location Code") then
                SalesShipmentHeader."CHEP From" := Loc."CHEP From";

        // Default export status
        SalesShipmentHeader."CHEP Export Status" := SalesShipmentHeader."CHEP Export Status"::New;

        // Persist to posted shipment
        SalesShipmentHeader.Modify(false);
    end;
}