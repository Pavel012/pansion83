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
Процедура BeforeWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If НЕ ЗначениеЗаполнено(CreateDate) Тогда
		CreateDate = CurrentDate();
		Author = ПараметрыСеанса.ТекПользователь;
	EndIf;
КонецПроцедуры //BeforeWrite

