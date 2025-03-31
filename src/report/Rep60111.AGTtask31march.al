report 60111 "AGTtask31march"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Purchasevendor.rdl';
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.", "Search Name", "Vendor Posting Group";
            column(Vendor_No; "No.") { }
            column(Vendor_Name; Name) { }
            dataitem("Value Entry"; "Value Entry")
            {
                DataItemLink = "Source No." = field("No."), "Global Dimension 1 Code" = field("Global Dimension 1 Filter"), "Global Dimension 2 Code" = field("Global Dimension 2 Filter");
                DataItemTableView = sorting("Source Type", "Source No.", "Item No.", "Posting Date") where("Source Type" = const(Vendor), "Expected Cost" = const(false));
                RequestFilterFields = "Posting Date", "Item No.", "Inventory Posting Group";
                column(itemnol; "Item No.") { }
                column(totalcostit; CostAmountActual) { }
                column(quantity; InvoicedQuantity)
                {
                    DecimalPlaces = 0 : 5;
                }
                trigger OnAfterGetRecord()
                begin
                    if not Item.Get("Item No.") then
                        Item.Init();

                    if ResetItemTotal then begin
                        ResetItemTotal := false;
                        InvoicedQuantity := "Invoiced Quantity";
                        CostAmountActual := "Cost Amount (Actual)";
                        DiscountAmount := "Discount Amount";
                    end else begin
                        InvoicedQuantity += "Invoiced Quantity";
                        CostAmountActual += "Cost Amount (Actual)";
                        DiscountAmount += "Discount Amount";
                    end;

                    if not (ValueEntry.Next() = 0) then begin
                        if ValueEntry."Item No." = "Item No." then
                            CurrReport.Skip();
                        ResetItemTotal := true
                    end
                end;

                trigger OnPreDataItem()
                begin
                    ResetItemTotal := true;
                    ValueEntry.SetCurrentKey("Source Type", "Source No.", "Item No.", "Posting Date");
                    ValueEntry.CopyFilters("Value Entry");
                    // ValueEntry.SETFILTER("Posting Date", '%1..%2', StartDate, EndDate);
                    if ValueEntry.FindSet() then;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if PrintOnlyOnePerPageReq then
                    PageGroupNo := PageGroupNo + 1;
            end;

            trigger OnPreDataItem()
            begin
                PageGroupNo := 1;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(StartDate; StartDate)
                    {
                        ApplicationArea = all;
                        Caption = 'Start Date';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = all;
                        Caption = 'End Date';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        FormatDocument: Codeunit "Format Document";
    begin
        VendFilter := FormatDocument.GetRecordFiltersWithCaptions(Vendor);
        ItemLedgEntryFilter := "Value Entry".GetFilters();
        PeriodText := "Value Entry".GetFilter("Posting Date");
    end;

    var
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        VendFilter: Text;
        ItemLedgEntryFilter: Text;
        PeriodText: Text;
        PrintOnlyOnePerPageReq: Boolean;
        InvoicedQuantity: Decimal;
        PageGroupNo: Integer;
        CostAmountActual: Decimal;
        DiscountAmount: Decimal;
        PeriodTxt: Label 'Period: %1', Comment = '%1 - period text';
        TableFilterTxt: Label '%1: %2', Locked = true;
        StartDate: Date;
        EndDate: Date;

    protected var
        ResetItemTotal: Boolean;

    procedure InitializeRequest(NewPrintOnlyOnePerPage: Boolean)
    begin
        PrintOnlyOnePerPageReq := NewPrintOnlyOnePerPage;
    end;
}