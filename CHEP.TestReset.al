codeunit 60140 "CHEP Test Reset"
{
    Permissions =
        tabledata "Sales Shipment Header" = RM,
        tabledata "CHEP Export Log" = RD;

    procedure ResetExportData()
    var
        Shpt: Record "Sales Shipment Header";
        Log: Record "CHEP Export Log";
        ShptCount: Integer;
        LogCount: Integer;
    begin
        if not Confirm('This will reset ALL exported CHEP shipments back to New and delete the entire export log.\n\nContinue?') then
            exit;

        Shpt.SetRange("CHEP Export Status", Shpt."CHEP Export Status"::Exported);
        ShptCount := Shpt.Count();
        if Shpt.FindSet(true) then
            repeat
                Shpt."CHEP Export Status" := Shpt."CHEP Export Status"::New;
                Shpt."CHEP Exported At" := 0DT;
                Shpt."CHEP Export Batch Id" := '';
                Shpt.Modify(false);
            until Shpt.Next() = 0;

        LogCount := Log.Count();
        Log.DeleteAll(false);

        Message('Reset complete.\n%1 shipment(s) reset to New.\n%2 log entry(ies) deleted.', ShptCount, LogCount);
    end;
}
