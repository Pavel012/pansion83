//-----------------------------------------------------------------------------
&AtServer
Function CheckUserPermission()
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		If НЕ ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
			Return True;
		EndIf;
	EndIf;
	Return False;
EndFunction //CheckUserPermission

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CommandProcessing(CommandParameter, CommandExecuteParameters)
	If НЕ CheckUserPermission() Тогда
		ShowMessageBox(Неопределено, NStr("en='You do not have rights to this function!';ru='У вас нет прав на эту функцию!';de='Sie haben keine Rechte für diese Funktion!'"));
		Return;
	EndIf;
	OpenForm("Document.Размещение.ФормаСписка", , CommandExecuteParameters.Source, CommandExecuteParameters.Uniqueness, CommandExecuteParameters.Window);
КонецПроцедуры //CommandProcessing
