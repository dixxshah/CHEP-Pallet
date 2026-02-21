codeunit 60121 "CHEP Transfer Post Subscribers"
{
    // Allows writing to posted transfer shipment header through this codeunit
    Permissions = tabledata "Transfer Shipment Header" = RM;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptHeader', '', false, false)]
    local procedure OnAfterInsertTransShptHeader(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        FromLoc: Record Location;
        ToLoc: Record Location;
    begin
        // Copy CHEP Qty from Transfer Order header
        TransferShipmentHeader."CHEP Qty" := TransferHeader."CHEP Qty";

        // Resolve CHEP From code from the Transfer-from Location
        if TransferHeader."Transfer-from Code" <> '' then
            if FromLoc.Get(TransferHeader."Transfer-from Code") then
                TransferShipmentHeader."CHEP From" := FromLoc."CHEP From";

        // Resolve CHEP To code from the Transfer-to Location's CHEP From field
        if TransferHeader."Transfer-to Code" <> '' then
            if ToLoc.Get(TransferHeader."Transfer-to Code") then
                TransferShipmentHeader."CHEP To" := ToLoc."CHEP From";

        // Default export status
        TransferShipmentHeader."CHEP Export Status" := TransferShipmentHeader."CHEP Export Status"::New;

        // Persist to posted transfer shipment
        TransferShipmentHeader.Modify(false);
    end;
}
