//-----------------------------------------------------------------------------
Function pmGetReservationStatusDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Description);
	Else
		If IsBlankString(DescriptionTranslations) Тогда
			vDescr = СокрЛП(Description);
		Else
			vDescr = СокрЛП(DescriptionTranslations);
		EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetReservationStatusDescription
