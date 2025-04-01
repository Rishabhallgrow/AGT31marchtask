codeunit 60109 "Sales Order Post Check"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, true)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ThresholdQty: Decimal;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then begin
            repeat
                if Item.Get(SalesLine."No.") then begin
                    Item.CalcFields(Inventory);
                    ThresholdQty := Item.Inventory;
                    if SalesLine.Quantity > ThresholdQty then begin
                        Error('Warning: The quantity entered for item %1 exceeds the defined threshold.', Item."No.");
                    end;
                end;
            until SalesLine.Next() = 0;
        end;
    end;
}