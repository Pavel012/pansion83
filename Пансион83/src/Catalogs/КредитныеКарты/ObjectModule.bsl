//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	Автор = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура OnSetNewCode(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = СокрЛП(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewCode

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	Автор = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
КонецПроцедуры //OnCopy
