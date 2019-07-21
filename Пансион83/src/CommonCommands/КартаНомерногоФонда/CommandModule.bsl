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
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 40, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	OpenForm("CommonForm.упрКартаНомерногоФонда", , CommandExecuteParameters.Source, CommandExecuteParameters.Uniqueness, CommandExecuteParameters.Window);
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CommandProcessing
