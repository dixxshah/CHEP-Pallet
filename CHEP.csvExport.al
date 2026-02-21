codeunit 60130 "CHEP CSV Export"
{
    Permissions =
        tabledata "Sales Shipment Header" = RM,
        tabledata "Transfer Shipment Header" = RM,
        tabledata "CHEP Export Log" = RIMD;

    procedure ExportNewShipments()
    var
        Shpt: Record "Sales Shipment Header";
        TransShpt: Record "Transfer Shipment Header";
        TempBlob: Codeunit "Temp Blob";
        OutS: OutStream;
        InS: InStream;
        FileName: Text;
        BatchId: Code[20];
        ExportCount: Integer;
        TempShpt: Record "Sales Shipment Header" temporary;
        TempTransShpt: Record "Transfer Shipment Header" temporary;
    begin
        BatchId := MakeBatchId();
        ExportCount := 0;

        TempBlob.CreateOutStream(OutS);
        WriteCsvHeader(OutS);

        // --- Sales Shipments ---
        // First pass: collect all eligible sales shipments into a temporary record
        Shpt.SetRange("CHEP Export Status", Shpt."CHEP Export Status"::New);
        Shpt.SetFilter("CHEP Qty", '>%1', 0);
        Shpt.SetFilter("CHEP No.", '<>%1', '');
        if Shpt.FindSet() then
            repeat
                TempShpt.Init();
                TempShpt.TransferFields(Shpt);
                TempShpt.Insert();
            until Shpt.Next() = 0;

        // --- Transfer Shipments ---
        // First pass: collect all eligible transfer shipments into a temporary record
        TransShpt.SetRange("CHEP Export Status", TransShpt."CHEP Export Status"::New);
        TransShpt.SetFilter("CHEP Qty", '>%1', 0);
        TransShpt.SetFilter("CHEP To", '<>%1', '');
        if TransShpt.FindSet() then
            repeat
                TempTransShpt.Init();
                TempTransShpt.TransferFields(TransShpt);
                TempTransShpt.Insert();
            until TransShpt.Next() = 0;

        if TempShpt.IsEmpty and TempTransShpt.IsEmpty then
            Error('No new CHEP shipments or transfers found to export.');

        // Second pass: process sales shipments
        if TempShpt.FindSet() then
            repeat
                if Shpt.Get(TempShpt."No.") then begin
                    WriteCsvLine(OutS, Shpt);
                    MarkExported(Shpt, BatchId);
                    LogExport(Shpt, BatchId);
                    ExportCount += 1;
                end;
            until TempShpt.Next() = 0;

        // Second pass: process transfer shipments
        if TempTransShpt.FindSet() then
            repeat
                if TransShpt.Get(TempTransShpt."No.") then begin
                    WriteCsvLineTransfer(OutS, TransShpt);
                    MarkExportedTransfer(TransShpt, BatchId);
                    LogExportTransfer(TransShpt, BatchId);
                    ExportCount += 1;
                end;
            until TempTransShpt.Next() = 0;

        TempBlob.CreateInStream(InS);
        FileName := StrSubstNo('CHEP_Pallets_%1_%2.csv', FormatDateISO(Today), BatchId);

        DownloadFromStream(InS, 'CHEP Export', '', 'CSV file (*.csv)|*.csv', FileName);
    end;

    local procedure WriteCsvHeader(var OutS: OutStream)
    var
        CrLf: Text[2];
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
        OutS.WriteText('ShipmentNo,Date,ShipToCode,PalletQty,FromCode,CHEPNo,ExternalDocNo' + CrLf);
    end;

    local procedure WriteCsvLine(var OutS: OutStream; Shpt: Record "Sales Shipment Header")
    var
        DateTxt: Text;
        CrLf: Text[2];
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
        DateTxt := FormatDateISO(Shpt."Posting Date");
        OutS.WriteText(StrSubstNo(
            '%1,%2,%3,%4,%5,%6,%7',
            EscapeCsv(Shpt."No."),
            DateTxt,
            EscapeCsv(Shpt."Ship-to Code"),
            Shpt."CHEP Qty",
            EscapeCsv(Shpt."CHEP From"),
            EscapeCsv(Shpt."CHEP No."),
            EscapeCsv(Shpt."External Document No.")
        ) + CrLf);
    end;

    local procedure WriteCsvLineTransfer(var OutS: OutStream; TransShpt: Record "Transfer Shipment Header")
    var
        DateTxt: Text;
        CrLf: Text[2];
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
        DateTxt := FormatDateISO(TransShpt."Posting Date");
        OutS.WriteText(StrSubstNo(
            '%1,%2,%3,%4,%5,%6,%7',
            EscapeCsv(TransShpt."No."),
            DateTxt,
            EscapeCsv(TransShpt."Transfer-to Code"),
            TransShpt."CHEP Qty",
            EscapeCsv(TransShpt."CHEP From"),
            EscapeCsv(TransShpt."CHEP To"),
            EscapeCsv(TransShpt."External Document No.")
        ) + CrLf);
    end;

    local procedure MarkExported(var Shpt: Record "Sales Shipment Header"; BatchId: Code[20])
    begin
        Shpt."CHEP Export Status" := Shpt."CHEP Export Status"::Exported;
        Shpt."CHEP Exported At" := CurrentDateTime();
        Shpt."CHEP Export Batch Id" := BatchId;
        Shpt.Modify(false);
    end;

    local procedure MarkExportedTransfer(var TransShpt: Record "Transfer Shipment Header"; BatchId: Code[20])
    begin
        TransShpt."CHEP Export Status" := TransShpt."CHEP Export Status"::Exported;
        TransShpt."CHEP Exported At" := CurrentDateTime();
        TransShpt."CHEP Export Batch Id" := BatchId;
        TransShpt.Modify(false);
    end;

    local procedure LogExport(Shpt: Record "Sales Shipment Header"; BatchId: Code[20])
    var
        Log: Record "CHEP Export Log";
    begin
        Log.Init();
        Log."Shipment No." := Shpt."No.";
        Log."Shipment Date" := Shpt."Posting Date";
        Log."Ship-to Code" := Shpt."Ship-to Code";
        Log."From Code" := Shpt."CHEP From";
        Log."CHEP No." := Shpt."CHEP No.";
        Log."CHEP Qty" := Shpt."CHEP Qty";
        Log."External Document No." := Shpt."External Document No.";
        Log."Source Type" := Log."Source Type"::Sale;
        Log."Exported At" := CurrentDateTime();
        Log."Exported By" := UserId();
        Log."Batch Id" := BatchId;
        Log.Insert(true);
    end;

    local procedure LogExportTransfer(TransShpt: Record "Transfer Shipment Header"; BatchId: Code[20])
    var
        Log: Record "CHEP Export Log";
    begin
        Log.Init();
        Log."Shipment No." := TransShpt."No.";
        Log."Shipment Date" := TransShpt."Posting Date";
        Log."Ship-to Code" := CopyStr(TransShpt."Transfer-to Code", 1, MaxStrLen(Log."Ship-to Code"));
        Log."From Code" := TransShpt."CHEP From";
        Log."CHEP No." := TransShpt."CHEP To";
        Log."CHEP Qty" := TransShpt."CHEP Qty";
        Log."External Document No." := TransShpt."External Document No.";
        Log."Source Type" := Log."Source Type"::Transfer;
        Log."Exported At" := CurrentDateTime();
        Log."Exported By" := UserId();
        Log."Batch Id" := BatchId;
        Log.Insert(true);
    end;

    procedure MakeBatchId(): Code[20]
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
