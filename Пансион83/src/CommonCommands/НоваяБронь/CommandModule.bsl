//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CommandProcessing(CommandParameter, CommandExecuteParameters)
	OpenForm("CommonForm.упрРабочийСтол", , CommandExecuteParameters.Source, CommandExecuteParameters.Uniqueness, CommandExecuteParameters.Window);
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vDocFormParameters = New Structure;
	vDocFormParameters.Вставить("Document", УпрСерверныеФункции.cmGetDocumentItemRefByDocNumber("Бронирование", "", True) );
	vFrm = ПолучитьФорму("Document.Бронирование.ObjectForm", vDocFormParameters);
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vFrm.Open();
КонецПроцедуры //CommandProcessing
