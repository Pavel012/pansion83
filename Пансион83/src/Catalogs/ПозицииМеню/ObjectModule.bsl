//-----------------------------------------------------------------------------
Function pmGetServiceItemDescription(pLang) Экспорт
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
EndFunction //pmGetServiceItemDescription

//-----------------------------------------------------------------------------
Function pmGetServiceItemUnitDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Unit);
	Else
		If IsBlankString(UnitTranslations) Тогда
			vDescr = СокрЛП(Unit);
		Else
			vDescr = СокрЛП(UnitTranslations);
		EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetServiceItemUnitDescription
