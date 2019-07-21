//-----------------------------------------------------------------------------
Function pmGetCompanyPrintName(pLang) Экспорт
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		Return СокрЛП(LegacyName);
	EndIf;
	If IsBlankString(PrintNameTranslations) Тогда
		Return СокрЛП(LegacyName);
	EndIf;
	Return СокрЛП(PrintNameTranslations);
EndFunction //pmGetCompanyPrintName

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Function pmCheckCompanyAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	If IsBlankString(Code) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Код> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Code> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Code", pAttributeInErr);
	EndIf;
	If IsBlankString(Description) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Наименование> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Description> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Description", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(LegacyName) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Официальное название> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Legacy name> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ЮрИмя", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(LegacyAddress) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Юридический адрес> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Legacy address> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "LegacyAddress", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(VATRate) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Ставка НДС> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<VAT Rate> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "СтавкаНДС", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckCompanyAttributes

//-----------------------------------------------------------------------------
Function pmGetCompanyBankAccounts(pAccountCurrency) Экспорт
	vQry = New Query();
	vQry.Text = "SELECT
	            |	BankAccounts.Ref AS BankAccount
	            |FROM
	            |	Catalog.БанковскиеСчета AS BankAccounts
	            |WHERE
	            |	BankAccounts.Owner = &qOwner
	            |	AND BankAccounts.ВалютаСчета = &qAccountCurrency
	            |	AND (NOT BankAccounts.DeletionMark)
	            |ORDER BY
	            |	BankAccounts.Code";
	vQry.SetParameter("qOwner", Ref);
	vQry.SetParameter("qAccountCurrency", pAccountCurrency);
	vAccounts = vQry.Execute().Unload();
	Return vAccounts;
EndFunction //pmGetCompanyBankAccounts

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	ExternalCode = "";
КонецПроцедуры //OnCopy
