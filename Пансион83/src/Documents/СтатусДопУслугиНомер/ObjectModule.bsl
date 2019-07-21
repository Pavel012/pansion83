//-----------------------------------------------------------------------------
Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(RoomInterfaceType) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Тип доп. услуги> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Interface type> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Interface type> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "RoomInterfaceType", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(Room) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<НомерРазмещения> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<НомерРазмещения> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Автор = ПараметрыСеанса.ТекПользователь;
	Date = CurrentDate();
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and date
	pmFillAuthorAndDate();
	// Fill from session parameters
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	IsProcessed = False;
	IsCanceled = False;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
	Перем vMessage, vAttributeInErr;
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If pWriteMode = DocumentWriteMode.Write Тогда
		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
		If pCancel Тогда
			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
			Message(NStr(vMessage), MessageStatus.Attention);
			ВызватьИсключение NStr(vMessage);
		EndIf;
	EndIf;
	If IsCanceled Тогда
		If НЕ ЗначениеЗаполнено(CancellationDate) Тогда
			CancellationDate = CurrentDate();
			CancellationAuthor = ПараметрыСеанса.ТекПользователь;
		EndIf;
	Else
		If ЗначениеЗаполнено(CancellationDate) Тогда
			CancellationDate = Неопределено;
			CancellationAuthor = Справочники.Сотрудники.EmptyRef();
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(Гостиница) Тогда
		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	pmFillAuthorAndDate();
	IsProcessed = False;
	IsCanceled = False;
	CancellationAuthor = Справочники.Сотрудники.EmptyRef();
	CancellationDate = Неопределено;
КонецПроцедуры //OnCopy

//-----------------------------------------------------------------------------
Процедура Filling(pBase)
	// Fill attributes with default values
	pmFillAttributesWithDefaultValues();
	// Fill from the base
	If ЗначениеЗаполнено(pBase) Тогда
		If TypeOf(pBase) = Type("CatalogRef.НомернойФонд") Тогда
			Room = pBase;
			Гостиница = pBase.Owner;
		ElsIf TypeOf(pBase) = Type("DocumentRef.Размещение") Тогда
			ParentDoc = pBase;
			Гостиница = pBase.Гостиница;
			Room = pBase.НомерРазмещения;
		EndIf;
	EndIf;
КонецПроцедуры //Filling
