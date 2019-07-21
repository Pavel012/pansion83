//-----------------------------------------------------------------------------
Function pmGetHotelPrintName(pLang) Экспорт
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		Return СокрЛП(PrintName);
	EndIf;
	If IsBlankString(PrintNameTranslations) Тогда
		Return СокрЛП(PrintName);
	EndIf;
	Return СокрЛП(PrintNameTranslations);
EndFunction //pmGetHotelPrintName

//-----------------------------------------------------------------------------
Function pmGetHotelPostAddressPresentation(pLang) Экспорт
	vPostAddress = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vPostAddress = СокрЛП(PostAddress);
	Else
		If IsBlankString(PostAddressTranslations) Тогда
			vPostAddress = СокрЛП(PostAddress);
		Else
			vPostAddress = СокрЛП(PostAddressTranslations);
		EndIf;
	EndIf;
	Return vPostAddress;
EndFunction //pmGetHotelPostAddressPresentation

//-----------------------------------------------------------------------------
Function pmGetHotelHowToDriveToTheHotelDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(HowToDriveToTheHotel);
	Else
		If IsBlankString(HowToDriveToTheHotelTranslations) Тогда
			vDescr = СокрЛП(HowToDriveToTheHotel);
		Else
			vDescr = СокрЛП(HowToDriveToTheHotelTranslations);
		EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetHotelHowToDriveToTheHotelDescription

//-----------------------------------------------------------------------------
Function pmGetHotelReservationDivisionContacts(pLang) Экспорт
	vCont = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vCont = СокрЛП(ReservationDivisionContacts);
	Else
		If IsBlankString(ReservationDivisionContactsTranslations) Тогда
			vCont = СокрЛП(ReservationDivisionContacts);
		Else
			vCont = СокрЛП(ReservationDivisionContactsTranslations);
		EndIf;
	EndIf;
	Return vCont;
EndFunction //cmGetHotelReservationDivisionContacts

//-----------------------------------------------------------------------------
Function pmGetHotelSalesDivisionContacts(pLang) Экспорт
	vCont = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vCont = СокрЛП(SalesDivisionContacts);
	Else
		If IsBlankString(SalesDivisionContactsTranslations) Тогда
			vCont = СокрЛП(SalesDivisionContacts);
		Else
			vCont = СокрЛП(SalesDivisionContactsTranslations);
		EndIf;
	EndIf;
	Return vCont;
EndFunction //pmGetHotelSalesDivisionContacts

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Initialize default parameters
	ShowSalesInReportsWithVAT = True;
	DoNotEditSettledDocs = True;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetNonReplicatingAttributes() Экспорт
	Return СохранениеНастроек.cmGetNonReplicatingHotelAttributes(Ref);
EndFunction //pmGetNonReplicatingAttributes

//-----------------------------------------------------------------------------
Function pmGetPrefix() Экспорт
	vAttrs = pmGetNonReplicatingAttributes();
	If vAttrs.Count() = 0 Тогда
		Return СокрЛП(Prefix);
	Else
		vAttrsRow = vAttrs.Get(0);
		Return СокрЛП(vAttrsRow.Prefix);
	EndIf;
EndFunction //pmGetPrefix

//-----------------------------------------------------------------------------
Function pmGetFolioProFormaNumberPrefix() Экспорт
	vAttrs = pmGetNonReplicatingAttributes();
	If vAttrs.Count() = 0 Тогда
		Return СокрЛП(FolioProFormaNumberPrefix);
	Else
		vAttrsRow = vAttrs.Get(0);
		Return СокрЛП(vAttrsRow.FolioProFormaNumberPrefix);
	EndIf;
EndFunction //pmGetFolioProFormaNumberPrefix

//-----------------------------------------------------------------------------
Function pmGetFolioAccountingNumberPrefix() Экспорт
	vAttrs = pmGetNonReplicatingAttributes();
	If vAttrs.Count() = 0 Тогда
		Return СокрЛП(FolioAccountingNumberPrefix);
	Else
		vAttrsRow = vAttrs.Get(0);
		Return СокрЛП(vAttrsRow.FolioAccountingNumberPrefix);
	EndIf;
EndFunction //pmGetFolioAccountingNumberPrefix

//-----------------------------------------------------------------------------
Function pmGetGuestGroupFolder() Экспорт
	vAttrs = pmGetNonReplicatingAttributes();
	If vAttrs.Count() = 0 Тогда
		Return GuestGroupFolder;
	Else
		vAttrsRow = vAttrs.Get(0);
		Return vAttrsRow.GuestGroupFolder;
	EndIf;
EndFunction //pmGetGuestGroupFolder