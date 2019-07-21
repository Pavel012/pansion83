//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If НЕ ЗначениеЗаполнено(DateFrom) Or НЕ ЗначениеЗаполнено(DateTo) Тогда
		ВызватьИсключение NStr("en='Event period should be filled!';ru='Период проведения мероприятия должен быть заполнен!';de='Der Zeitraum für die Durchführung von Veranstaltungen muss ausgefüllt sein!'");
	EndIf;
	If DateFrom > DateTo Тогда
		ВызватьИсключение NStr("en='Wrong event period! Date from is after date to.';ru='Период проведения мероприятия указан неверно! Дата начала периода позже даты окончания периода.';de='Der Zeitraum für die Durchführung von Veranstaltungen ist falsch angegeben! Das Datum des Zeitraumbeginns liegt nach dem Datum des Zeitraumendes.'");
	EndIf;
КонецПроцедуры //BeforeWrite

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

