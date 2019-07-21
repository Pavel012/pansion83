//-----------------------------------------------------------------------------
Function pmGetCountryDescription(pLang) Экспорт
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
EndFunction //pmGetCountryDescription

Процедура BeforeWrite(Cancel)
	Description = StrReplace(Description,", "," ");
	Description = StrReplace(Description,","," ");
КонецПроцедуры
