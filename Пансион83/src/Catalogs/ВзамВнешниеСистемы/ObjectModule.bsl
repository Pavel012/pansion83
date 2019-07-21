//-----------------------------------------------------------------------------
Процедура pmClearSessionAttributes() Экспорт
	SessionID = "";
	SessionStartTime = '00010101';
	SessionLastActivityTime = '00010101';
КонецПроцедуры //pmClearSessionAttributes

//-----------------------------------------------------------------------------
Процедура pmSetNewSessionAttributes(pSessionID) Экспорт
	SessionID = TrimR(pSessionID);
	SessionStartTime = CurrentDate();
	SessionLastActivityTime = SessionStartTime;
КонецПроцедуры //pmSetNewSessionAttributes

//-----------------------------------------------------------------------------
Процедура pmUpdateSessionAttributes(pFull = True) Экспорт
	SessionLastActivityTime = CurrentDate();
	If pFull Тогда
		LastFullSynchronizationTime = SessionLastActivityTime;
	EndIf;
КонецПроцедуры //pmUpdateSessionAttributes

//-----------------------------------------------------------------------------
Процедура OnSetNewCode(pStandardProcessing, pPrefix)
	pStandardProcessing = False;
	vUUID = New UUID();
	Code = String(vUUID);
КонецПроцедуры //OnSetNewCode
