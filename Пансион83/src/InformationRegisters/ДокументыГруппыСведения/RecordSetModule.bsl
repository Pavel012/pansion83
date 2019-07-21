//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel, pReplacing)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	For Each vRecRow In ThisObject Do
		If НЕ ЗначениеЗаполнено(vRecRow.Автор) Тогда
			vRecRow.Автор = ПараметрыСеанса.ТекПользователь;
		EndIf;
	EndDo;
КонецПроцедуры //BeforeWrite
