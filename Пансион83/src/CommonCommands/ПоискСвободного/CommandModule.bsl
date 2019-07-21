//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CommandProcessing(CommandParameter, CommandExecuteParameters)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 40, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	OpenForm("CommonForm.упрНаличиеНомеров", , CommandExecuteParameters.Source, CommandExecuteParameters.Uniqueness, CommandExecuteParameters.Window);
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CommandProcessing
