//-----------------------------------------------------------------------------
Function pmGetDayTypeDescription(pLang = Неопределено) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Description);
		EndIf;
	Return vDescr;
EndFunction //pmGetDayTypeDescription
