//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CommandProcessing(CommandParameter, CommandExecuteParameters)
	OpenForm("Document.Бронирование.ФормаСписка", , CommandExecuteParameters.Source, CommandExecuteParameters.Uniqueness, CommandExecuteParameters.Window);
КонецПроцедуры //CommandProcessing
