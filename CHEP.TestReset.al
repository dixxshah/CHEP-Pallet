codeunit 60140 "CHEP Test Reset"
{
    Permissions =
        tabledata "Sales Shipment Header" = RM,
        tabledata "Transfer Shipment Header" = RM,
        tabledata "CHEP Export Log" = RD;

    procedure ResetExportData()
    var
        Shpt: Record "Sales Shipment Header";
        TransShpt: Record "Transfer Shipment Header";
        Log: Record "CHEP Export Log";
        ShptCount: Integer;
        TransShptCount: Integer;
        LogCount: Integer;
    begin
        if not Confirm('This will reset ALL exported CHEP shipments and transfers back to New and delete the entire export log.\n\nContinue?') then
            exit;

        // Reset sales shipments
        Shpt.SetRange("CHEP Export Status", Shpt."CHEP Export Status"::Exported);
        ShptCount := Shpt.Count();
        if Shpt.FindSet(true) then
            repeat
                Shpt."CHEP Export Status" := Shpt."CHEP Export Status"::New;
                Shpt."CHEP Exported At" := 0DT;
                Shpt."CHEP Export Batch Id" := '';
                Shpt.Modify(false);
            until Shpt.Next() = 0;

        // Reset transfer shipments
        TransShpt.SetRange("CHEP Export Status", TransShpt."CHEP Export Status"::Exported);
        TransShptCount := TransShpt.Count();
        if TransShpt.FindSet(true) then
            repeat
                TransShpt."CHEP Export Status" := TransShpt."CHEP Export Status"::New;
                TransShpt."CHEP Exported At" := 0DT;
                TransShpt."CHEP Export Batch Id" := '';
                TransShpt.Modify(false);
            until TransShpt.Next() = 0;

        LogCount := Log.Count();
        Log.DeleteAll(false);

        Message('Reset complete.\n%1 sales shipment(s) reset to New.\n%2 transfer shipment(s) reset to New.\n%3 log entry(ies) deleted.',
            ShptCount, TransShptCount, LogCount);
    end;
}
