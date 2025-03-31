report 60109 "LabelPrintCode"
{
    DefaultLayout = RDLC;
    RDLCLayout = './labelprint.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Label Print';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            column(Buy_from_Vendor_Name; "Buy-from Vendor Name") { }
            column(No_PurchaseHeader; "No.") { }


            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(No_item; "No.") { }

                column(BarcdItemNo; BarcdItemNo) { }

                // Loop through labels based on "Qty. to Invoice"
                dataitem(Integer; Integer)
                {
                    DataItemLinkReference = "Purchase Line";
                    DataItemTableView = sorting(Number);

                    column(Number1; Number) { }
                    trigger OnPreDataItem()
                    var
                        myInt: Integer;
                    begin
                        SetFilter(Number, '%1..%2', 1, "Purchase Line".Quantity);
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        GenerateBarcode();
                    end;
                }
            }
        }
    }

    requestpage
    {
        AboutTitle = 'Label Printing';
        AboutText = 'This report prints labels based on the "Qty. to Invoice".';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
    }

    procedure GenerateBarcode()
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
        BarcodeSymbology: Enum "Barcode Symbology";
        BarcodeString: Code[50];
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
        BarcodeSymbology := Enum::"Barcode Symbology"::Code128;

        // Clean barcode input
        BarcodeString := "Purchase Line"."No.";


        BarcodeFontProvider.ValidateInput(BarcodeString, BarcodeSymbology);
        BarcdItemNo := BarcodeFontProvider.EncodeFont(BarcodeString, BarcodeSymbology);
    end;



    var
        BarcdItemNo: Text;
        QtyToPrint: Integer;
}
