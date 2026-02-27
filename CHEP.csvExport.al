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
        OutS.WriteText('Location,Other Party,Direction,Movement Date,Ref,Other Ref,Equipment,Quantity' + CrLf);
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
            '%1,%2,%3,%4,%5,%6,%7,%8',
            EscapeCsv(Shpt."CHEP From"),        // Location
            EscapeCsv(Shpt."CHEP No."),         // Other Party
            'Out',                              // Direction
            DateTxt,                            // Movement Date
            EscapeCsv(Shpt."No."),              // Ref
            EscapeCsv(Shpt."External Document No."), // Other Ref
            '4001',                             // Equipment
            Shpt."CHEP Qty"                     // Quantity
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
            '%1,%2,%3,%4,%5,%6,%7,%8',
            EscapeCsv(TransShpt."CHEP From"),        // Location
            EscapeCsv(TransShpt."CHEP To"),          // Other Party
            'Out',                                   // Direction
            DateTxt,                                 // Movement Date
            EscapeCsv(TransShpt."Transfer Order No."), // Ref
            EscapeCsv(TransShpt."External Document No."), // Other Ref
            '4001',                                  // Equipment
            TransShpt."CHEP Qty"                     // Quantity
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

    procedure ExportNewShipmentsExcel()
    var
        TempBlob: Codeunit "Temp Blob";
        OutS: OutStream;
        InS: InStream;
        Shpt: Record "Sales Shipment Header";
        TransShpt: Record "Transfer Shipment Header";
        TempShpt: Record "Sales Shipment Header" temporary;
        TempTransShpt: Record "Transfer Shipment Header" temporary;
        FileName: Text;
        BatchId: Code[20];
    begin
        BatchId := MakeBatchId();

        // Collect eligible sales shipments
        Shpt.SetRange("CHEP Export Status", Shpt."CHEP Export Status"::New);
        Shpt.SetFilter("CHEP Qty", '>%1', 0);
        Shpt.SetFilter("CHEP No.", '<>%1', '');
        if Shpt.FindSet() then
            repeat
                TempShpt.Init();
                TempShpt.TransferFields(Shpt);
                TempShpt.Insert();
            until Shpt.Next() = 0;

        // Collect eligible transfer shipments
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

        TempBlob.CreateOutStream(OutS, TextEncoding::UTF8);
        WriteXmlHeader(OutS);

        // Process sales shipments
        if TempShpt.FindSet() then
            repeat
                if Shpt.Get(TempShpt."No.") then begin
                    WriteXmlRowShipment(OutS, Shpt);
                    MarkExported(Shpt, BatchId);
                    LogExport(Shpt, BatchId);
                end;
            until TempShpt.Next() = 0;

        // Process transfer shipments
        if TempTransShpt.FindSet() then
            repeat
                if TransShpt.Get(TempTransShpt."No.") then begin
                    WriteXmlRowTransfer(OutS, TransShpt);
                    MarkExportedTransfer(TransShpt, BatchId);
                    LogExportTransfer(TransShpt, BatchId);
                end;
            until TempTransShpt.Next() = 0;

        WriteXmlFooter(OutS);

        TempBlob.CreateInStream(InS);
        FileName := StrSubstNo('CHEP_Pallets_%1_%2.xml', FormatDateISO(Today), BatchId);
        DownloadFromStream(InS, 'CHEP Export', '', 'XML Spreadsheet (*.xml)|*.xml', FileName);
    end;

    local procedure WriteXmlHeader(var OutS: OutStream)
    var
        NL: Text[2];
    begin
        NL[1] := 13; NL[2] := 10;
        OutS.WriteText('<?xml version="1.0" encoding="UTF-8"?>' + NL);
        OutS.WriteText('<?mso-application progid="Excel.Sheet"?>' + NL);
        OutS.WriteText('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + NL);
        OutS.WriteText(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">' + NL);
        OutS.WriteText('<Styles>' + NL);
        OutS.WriteText('<Style ss:ID="h"><Font ss:Bold="1"/></Style>' + NL);
        OutS.WriteText('<Style ss:ID="d"><NumberFormat ss:Format="YYYY\-MM\-DD"/></Style>' + NL);
        OutS.WriteText('</Styles>' + NL);
        OutS.WriteText('<Worksheet ss:Name="CHEP Export"><Table>' + NL);
        OutS.WriteText('<Row>');
        WriteXmlCell(OutS, 'Location', true);
        WriteXmlCell(OutS, 'Other Party', true);
        WriteXmlCell(OutS, 'Direction', true);
        WriteXmlCell(OutS, 'Movement Date', true);
        WriteXmlCell(OutS, 'Ref', true);
        WriteXmlCell(OutS, 'Other Ref', true);
        WriteXmlCell(OutS, 'Equipment', true);
        WriteXmlCell(OutS, 'Quantity', true);
        OutS.WriteText('</Row>' + NL);
    end;

    local procedure WriteXmlFooter(var OutS: OutStream)
    begin
        OutS.WriteText('</Table></Worksheet></Workbook>');
    end;

    local procedure WriteXmlCell(var OutS: OutStream; Value: Text; Bold: Boolean)
    begin
        if Bold then
            OutS.WriteText('<Cell ss:StyleID="h"><Data ss:Type="String">' + XmlEncode(Value) + '</Data></Cell>')
        else
            OutS.WriteText('<Cell><Data ss:Type="String">' + XmlEncode(Value) + '</Data></Cell>');
    end;

    local procedure WriteXmlCellNum(var OutS: OutStream; Value: Integer)
    begin
        OutS.WriteText('<Cell><Data ss:Type="Number">' + Format(Value) + '</Data></Cell>');
    end;

    local procedure WriteXmlCellDate(var OutS: OutStream; Value: Date)
    begin
        OutS.WriteText('<Cell ss:StyleID="d"><Data ss:Type="DateTime">' + FormatDateISO(Value) + 'T00:00:00.000</Data></Cell>');
    end;

    local procedure WriteXmlRowShipment(var OutS: OutStream; Shpt: Record "Sales Shipment Header")
    var
        NL: Text[2];
    begin
        NL[1] := 13; NL[2] := 10;
        OutS.WriteText('<Row>');
        WriteXmlCell(OutS, Shpt."CHEP From", false);               // Location
        WriteXmlCell(OutS, Shpt."CHEP No.", false);                // Other Party
        WriteXmlCell(OutS, 'Out', false);                          // Direction
        WriteXmlCellDate(OutS, Shpt."Posting Date");               // Movement Date
        WriteXmlCell(OutS, Shpt."No.", false);                     // Ref
        WriteXmlCell(OutS, Shpt."External Document No.", false);   // Other Ref
        WriteXmlCell(OutS, '4001', false);                         // Equipment
        WriteXmlCellNum(OutS, Shpt."CHEP Qty");                    // Quantity
        OutS.WriteText('</Row>' + NL);
    end;

    local procedure WriteXmlRowTransfer(var OutS: OutStream; TransShpt: Record "Transfer Shipment Header")
    var
        NL: Text[2];
    begin
        NL[1] := 13; NL[2] := 10;
        OutS.WriteText('<Row>');
        WriteXmlCell(OutS, TransShpt."CHEP From", false);               // Location
        WriteXmlCell(OutS, TransShpt."CHEP To", false);                 // Other Party
        WriteXmlCell(OutS, 'Out', false);                               // Direction
        WriteXmlCellDate(OutS, TransShpt."Posting Date");               // Movement Date
        WriteXmlCell(OutS, TransShpt."Transfer Order No.", false);      // Ref
        WriteXmlCell(OutS, TransShpt."External Document No.", false);   // Other Ref
        WriteXmlCell(OutS, '4001', false);                              // Equipment
        WriteXmlCellNum(OutS, TransShpt."CHEP Qty");                    // Quantity
        OutS.WriteText('</Row>' + NL);
    end;

    local procedure XmlEncode(Value: Text): Text
    begin
        Value := Value.Replace('&', '&amp;');
        Value := Value.Replace('<', '&lt;');
        Value := Value.Replace('>', '&gt;');
        exit(Value);
    end;

    procedure ResetExportFlag(var SelectedLog: Record "CHEP Export Log")
    var
        Shpt: Record "Sales Shipment Header";
        TransShpt: Record "Transfer Shipment Header";
        Choice: Integer;
        ResetAll: Boolean;
        ResetCount: Integer;
    begin
        if SelectedLog.Count = 1 then begin
            SelectedLog.FindFirst();
            Choice := StrMenu(
                'Reset this shipment only,Reset all exported shipments',
                1,
                StrSubstNo('Shipment %1 is selected. What would you like to reset?', SelectedLog."Shipment No."));
            if Choice = 0 then exit;
            ResetAll := (Choice = 2);
        end else begin
            if not Confirm('Reset %1 selected shipment(s) to New status for re-export?', true, SelectedLog.Count) then
                exit;
            ResetAll := false;
        end;

        if ResetAll then begin
            Shpt.SetRange("CHEP Export Status", Shpt."CHEP Export Status"::Exported);
            if Shpt.FindSet(true) then
                repeat
                    DoResetShipment(Shpt);
                    ResetCount += 1;
                until Shpt.Next() = 0;

            TransShpt.SetRange("CHEP Export Status", TransShpt."CHEP Export Status"::Exported);
            if TransShpt.FindSet(true) then
                repeat
                    DoResetTransferShipment(TransShpt);
                    ResetCount += 1;
                until TransShpt.Next() = 0;
        end else begin
            if SelectedLog.FindSet() then
                repeat
                    case SelectedLog."Source Type" of
                        SelectedLog."Source Type"::Sale:
                            if Shpt.Get(SelectedLog."Shipment No.") then begin
                                DoResetShipment(Shpt);
                                ResetCount += 1;
                            end;
                        SelectedLog."Source Type"::Transfer:
                            if TransShpt.Get(SelectedLog."Shipment No.") then begin
                                DoResetTransferShipment(TransShpt);
                                ResetCount += 1;
                            end;
                    end;
                until SelectedLog.Next() = 0;
        end;

        Message('%1 shipment(s) reset to New and queued for re-export.', ResetCount);
    end;

    local procedure DoResetShipment(var Shpt: Record "Sales Shipment Header")
    begin
        Shpt."CHEP Export Status" := Shpt."CHEP Export Status"::New;
        Shpt."CHEP Exported At" := 0DT;
        Shpt."CHEP Export Batch Id" := '';
        Shpt.Modify(false);
    end;

    local procedure DoResetTransferShipment(var TransShpt: Record "Transfer Shipment Header")
    begin
        TransShpt."CHEP Export Status" := TransShpt."CHEP Export Status"::New;
        TransShpt."CHEP Exported At" := 0DT;
        TransShpt."CHEP Export Batch Id" := '';
        TransShpt.Modify(false);
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
