codeunit 60130 "CHEP CSV Export"
{
    Permissions =
        tabledata "Sales Shipment Header" = RM,
        tabledata "CHEP Export Log" = RIMD;

    procedure ExportNewShipments()
    var
        Shpt: Record "Sales Shipment Header";
        TempBlob: Codeunit "Temp Blob";
        OutS: OutStream;
        InS: InStream;
        FileName: Text;
        BatchId: Code[20];
        ExportCount: Integer;
    begin
        BatchId := MakeBatchId();
        ExportCount := 0;

        TempBlob.CreateOutStream(OutS);
        WriteCsvHeader(OutS);

        Shpt.SetCurrentKey("CHEP Export Status");
        Shpt.SetRange("CHEP Export Status", Shpt."CHEP Export Status"::New);

        if Shpt.FindSet(true) then
            repeat
                if Shpt."CHEP Qty" > 0 then begin
                    if Shpt."CHEP No." = '' then
                        Error(
                            'Missing CHEP No. for Posted Shipment %1 (Ship-to Code: %2).',
                            Shpt."No.",
                            Shpt."Ship-to Code"
                        );

                    WriteCsvLine(OutS, Shpt);
                    MarkExported(Shpt, BatchId);
                    LogExport(Shpt, BatchId);

                    ExportCount += 1;
                end;
            until Shpt.Next() = 0;

        if ExportCount = 0 then
            Error('No new CHEP shipments found to export.');

        TempBlob.CreateInStream(InS);
        FileName := StrSubstNo('CHEP_Pallets_%1_%2.csv', FormatDateISO(Today), BatchId);

        DownloadFromStream(InS, 'CHEP Export', '', 'CSV file (*.csv)|*.csv', FileName);
    end;

    local procedure WriteCsvHeader(var OutS: OutStream)
    begin
        OutS.WriteText('Date,PalletQty,CHEPNo');
        OutS.WriteText('\r\n');
    end;

    local procedure WriteCsvLine(var OutS: OutStream; Shpt: Record "Sales Shipment Header")
    var
        DateTxt: Text;
    begin
        DateTxt := FormatDateISO(Shpt."Posting Date");
        OutS.WriteText(StrSubstNo(
            '%1,%2,%3',
            DateTxt,
            Shpt."CHEP Qty",
            EscapeCsv(Shpt."CHEP No.")
        ));
        OutS.WriteText('\r\n');
    end;

    local procedure MarkExported(var Shpt: Record "Sales Shipment Header"; BatchId: Code[20])
    begin
        Shpt."CHEP Export Status" := Shpt."CHEP Export Status"::Exported;
        Shpt."CHEP Exported At" := CurrentDateTime();
        Shpt."CHEP Export Batch Id" := BatchId;
        Shpt.Modify(true);
    end;

    local procedure LogExport(Shpt: Record "Sales Shipment Header"; BatchId: Code[20])
    var
        Log: Record "CHEP Export Log";
    begin
        Log.Init();
        Log."Shipment No." := Shpt."No.";
        Log."Shipment Date" := Shpt."Posting Date";
        Log."Ship-to Code" := Shpt."Ship-to Code";
        Log."CHEP No." := Shpt."CHEP No.";
        Log."CHEP Qty" := Shpt."CHEP Qty";
        Log."Exported At" := CurrentDateTime();
        Log."Exported By" := UserId();
        Log."Batch Id" := BatchId;
        Log.Insert(true);
    end;

    local procedure MakeBatchId(): Code[20]
    var
        Raw: Text;
    begin
        // Example output: 20260218T210530
        Raw := Format(CurrentDateTime(), 0, 9);
        Raw := DelChr(Raw, '=', '-:/ .');
        exit(CopyStr(Raw, 1, 20));
    end;

    local procedure FormatDateISO(D: Date): Text
    begin
        // returns YYYY-MM-DD
        exit(StrSubstNo('%1-%2-%3',
            Pad2(Format(Date2DMY(D, 3))), // year
            Pad2(Format(Date2DMY(D, 2))), // month
            Pad2(Format(Date2DMY(D, 1)))  // day
        ));
    end;

    local procedure Pad2(T: Text): Text
    begin
        if StrLen(T) = 1 then
            exit('0' + T);
        exit(T);
    end;

    local procedure EscapeCsv(Value: Text): Text
    var
        V: Text;
    begin
        // Proper CSV escaping: wrap in quotes and double any internal quotes
        if (StrPos(Value, ',') > 0) or (StrPos(Value, '"') > 0) then begin
            V := Value;
            V := V.Replace('"', '""');
            exit('"' + V + '"');
        end;

        exit(Value);
    end;
}