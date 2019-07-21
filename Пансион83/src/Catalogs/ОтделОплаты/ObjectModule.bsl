//-----------------------------------------------------------------------------
Function pmNormDescription() Экспорт
	If Left(СокрЛП(Description), StrLen(СокрЛП(Code))) <> СокрЛП(Code) Тогда
		Return СокрЛП(Code) + ?(IsBlankString(Description), "", " - " + СокрЛП(Description));
	Else
		Return СокрЛП(Description);
	EndIf;
EndFunction //pmNormDescription

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	Description = pmNormDescription();
КонецПроцедуры //BeforeWrite
