# CHEP Pallet Extension — User Guide
**Version 3.0.0 | Shah Trading | Business Central**

---

## Table of Contents
1. [Overview](#1-overview)
2. [One-Time Setup](#2-one-time-setup)
3. [Sales Orders — Recording CHEP Pallets](#3-sales-orders--recording-chep-pallets)
4. [Transfer Orders — Recording CHEP Pallets](#4-transfer-orders--recording-chep-pallets)
5. [Exporting to CHEP](#5-exporting-to-chep)
6. [CHEP Export Log](#6-chep-export-log)
7. [Re-exporting Transactions](#7-re-exporting-transactions)
8. [Troubleshooting — Posting Errors](#8-troubleshooting--posting-errors)

---

## 1. Overview

The CHEP Pallet extension tracks outgoing CHEP pallet movements and exports them to the CHEP portal in the required format. It supports both **Sales Shipments** and **Transfer Shipments**.

Each export produces a file with the following columns, matching the CHEP Bulk Transfer portal:

| Column | Description |
|---|---|
| Location | Your CHEP account code for the shipping location |
| Other Party | The customer's or destination's CHEP account code |
| Direction | Always "Out" |
| Movement Date | The shipment posting date |
| Ref | The shipment or transfer order number |
| Other Ref | The external document / customer PO number |
| Equipment | Always "4001" (48×40 CHEP Pallet) |
| Quantity | Number of CHEP pallets |

---

## 2. One-Time Setup

Before the extension can track and export pallets, the following must be configured. **Posting will be blocked** if CHEP Qty is entered but setup is missing.

### 2.1 Locations — CHEP From Code

Every warehouse location that ships CHEP pallets must have a CHEP account code.

1. Go to **Locations**
2. Open the relevant location
3. On the **CHEP** FastTab, enter the **CHEP From** code (your CHEP account number for that location, e.g. `4000230591`)
4. Repeat for each shipping location

### 2.2 Customers — CHEP No.

Every customer that receives CHEP pallets must have a CHEP account number.

1. Go to **Customers**
2. Open the relevant customer
3. On the **CHEP** FastTab, enter the **CHEP No.** (the customer's CHEP account number, e.g. `6198010700`)

### 2.3 Ship-to Addresses — CHEP No. (Optional Override)

If a customer has multiple ship-to addresses with different CHEP accounts:

1. Go to **Customers** → select the customer → **Ship-to Addresses**
2. Open the relevant ship-to address
3. Enter the **CHEP No.** for that specific ship-to location

> **Note:** If a ship-to address has a CHEP No., it overrides the customer's CHEP No. for that delivery. If the ship-to CHEP No. is blank, the customer's CHEP No. is used.

---

## 3. Sales Orders — Recording CHEP Pallets

### 3.1 Entering CHEP Quantity

1. Open or create a **Sales Order**
2. On the **CHEP** FastTab, enter the number of pallets in the **CHEP Qty** field
3. Process the order as normal (ship and invoice)

### 3.2 What Happens at Posting

When the sales order is posted:
- The **CHEP No.** is resolved from the customer (or ship-to address if set)
- The **CHEP From** code is resolved from the shipping location
- The posted shipment is flagged as **New** and queued for export
- If CHEP Qty > 0 but either the CHEP No. or CHEP From is missing, **posting is blocked** with a clear error message (see Section 8)

---

## 4. Transfer Orders — Recording CHEP Pallets

### 4.1 Entering CHEP Quantity

1. Open or create a **Transfer Order**
2. On the **CHEP** FastTab, enter the number of pallets in the **CHEP Qty** field
3. Post the transfer shipment as normal

### 4.2 What Happens at Posting

When the transfer shipment is posted:
- The **CHEP From** code is resolved from the Transfer-from Location
- The **CHEP To** code is resolved from the Transfer-to Location's CHEP From field
- The posted shipment is flagged as **New** and queued for export
- If CHEP Qty > 0 but either location is missing a CHEP From code, **posting is blocked** (see Section 8)

---

## 5. Exporting to CHEP

The export collects all shipments (sales and transfers) with status **New** and produces a file ready to upload to the CHEP portal.

### 5.1 Running the Export

The export action is available on three pages:

- **CHEP Export Log** (recommended — central location)
- **Posted Sales Shipments**
- **Posted Transfer Shipments**

On any of these pages, click one of:

| Action | Output |
|---|---|
| **Export CHEP CSV** | Comma-separated `.csv` file |
| **Export CHEP Excel** | XML Spreadsheet `.xml` file (opens in Excel) |

> **Note on the Excel file:** The file uses Microsoft's SpreadsheetML XML format and downloads with a `.xml` extension. When you open it, Excel recognises it immediately as a spreadsheet — no conversion needed. The bold header row and date formatting are preserved.

### 5.2 After Export

- All exported shipments are marked **Exported**
- The export is recorded in the **CHEP Export Log** with the batch ID, date, and user
- The file is ready to upload directly to the CHEP portal

---

## 6. CHEP Export Log

The Export Log provides a full history of every pallet movement that has been exported.

**Navigation:** Search for **CHEP Export Log** in Business Central

### Columns

| Column | Description |
|---|---|
| Entry No. | Auto-generated sequence number |
| Source Type | Sale or Transfer |
| Batch Id | Unique ID for the export run (timestamp-based) |
| Shipment No. | The posted shipment or transfer order number |
| Shipment Date | Posting date of the shipment |
| Ship-to Code | Destination location or customer ship-to code |
| From Code | CHEP From account (your location) |
| CHEP No. | CHEP account of the other party |
| CHEP Qty | Number of pallets exported |
| External Document No. | Customer PO or external reference |
| Exported At | Date and time of export |
| Exported By | User who ran the export |

---

## 7. Re-exporting Transactions

If a transaction needs to be re-submitted to the CHEP portal (e.g. the file was lost, or an entry was rejected), use the **Reset Export Flag** action on the CHEP Export Log.

### 7.1 Reset Selected Transactions

1. Go to the **CHEP Export Log**
2. Select the rows you want to re-export (use Shift+Click or the row checkboxes for multiple rows)
3. Click **Reset Export Flag**
4. Confirm the prompt: *"Reset X selected shipment(s) to New status for re-export?"*
5. The selected shipments are reset to **New** and will be included in the next export

### 7.2 Single Transaction — Reset Options

If only one row is focused (no multi-select):

1. Click **Reset Export Flag**
2. A menu appears with two options:
   - **Reset this shipment only** — resets just the focused shipment
   - **Reset all exported shipments** — resets every exported shipment in the system back to New

Choose the appropriate option. Selecting Cancel leaves everything unchanged.

> **Note:** The Export Log entries are kept as an audit trail — resetting the flag does not delete the log history. When the next export runs, new log entries are created for the re-exported transactions.

---

## 8. Troubleshooting — Posting Errors

The system will block posting if CHEP Qty is greater than zero but the required setup is missing. The error message identifies exactly what needs to be fixed.

### Error: No CHEP account on Customer or Ship-to

> *"Sales Order [No.]: CHEP Qty is [X] but no CHEP account (CHEP No.) is set on Customer [No.] / Ship-to [Code]. Set the CHEP No. on the customer or ship-to address before posting."*

**Fix:**
- Go to **Customers** → open the customer → set the **CHEP No.**
- OR go to **Customers** → **Ship-to Addresses** → open the ship-to → set the **CHEP No.**
- Then re-post the sales order

### Error: No CHEP From on Location (Sales)

> *"Sales Order [No.]: CHEP Qty is [X] but Location [Code] has no CHEP From account set up. Set the CHEP From code on the Location before posting."*

**Fix:**
- Go to **Locations** → open the shipping location → set the **CHEP From** code
- Then re-post the sales order

### Error: No CHEP From on Transfer-from Location

> *"Transfer Order [No.]: CHEP Qty is [X] but Transfer-from Location [Code] has no CHEP From account set up. Set the CHEP From code on the Location before posting."*

**Fix:**
- Go to **Locations** → open the Transfer-from location → set the **CHEP From** code
- Then re-post the transfer shipment

### Error: No CHEP From on Transfer-to Location

> *"Transfer Order [No.]: CHEP Qty is [X] but Transfer-to Location [Code] has no CHEP From account set up. Set the CHEP From code on the Location before posting."*

**Fix:**
- Go to **Locations** → open the Transfer-to location → set the **CHEP From** code
- Then re-post the transfer shipment

---

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.0.0 | 2024 | Initial release — Sales Shipment CHEP tracking and CSV export |
| 2.0.0 | 2025 | Added Transfer Order CHEP support; Export Log; Location and External Document No. fields |
| 3.0.0 | Feb 2026 | Excel/XML export; CHEP portal column format; posting validation for missing setup; Reset Export Flag for re-export |

---

*Shah Trading — Internal Document*
