codeunit 60100 OrderValidationSubscriber1apr
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, true)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then
                repeat
                    if SalesLine."No." = '1896-S' then begin
                        Error('Order contains restricted item 1896-S.');
                        IsHandled := true;
                        exit;
                    end;
                until SalesLine.Next() = 0;
        end;
    end;
}