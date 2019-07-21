//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pMode)
	// Fill employee that closed message and date and time when it was closed
	If IsClosed And НЕ ЗначениеЗаполнено(DateWhenClosed) Тогда
		DateWhenClosed = CurrentDate();
		ClosedBy = ПараметрыСеанса.ТекПользователь;
		ThisObject.Write(DocumentWriteMode.Write);
	ElsIf НЕ IsClosed And ЗначениеЗаполнено(DateWhenClosed) Тогда
		DateWhenClosed = Неопределено;
		ClosedBy = Справочники.Сотрудники.EmptyRef();
		ThisObject.Write(DocumentWriteMode.Write);
	EndIf;
	
	// Clear register records
	RegisterRecords.Задачи.Clear();
	
	// Build list of accounting dates
	vDates = New СписокЗначений();
	If НЕ ЗначениеЗаполнено(ValidFromDate) And НЕ ЗначениеЗаполнено(ValidToDate) Тогда
		vDates.Add('00010101');
	ElsIf ЗначениеЗаполнено(ValidFromDate) And НЕ ЗначениеЗаполнено(ValidToDate) Тогда
		vDates.Add(BegOfDay(ValidFromDate));
	Else
		vDay = BegOfDay(Date);
		If ЗначениеЗаполнено(ValidFromDate) Тогда
			vDay = BegOfDay(ValidFromDate);
		EndIf;
		vEnd = BegOfDay(ValidToDate);
		While vDay <= vEnd Do
			vDates.Add(vDay);
			vDay = vDay + 24*3600;
		EndDo;
	EndIf;
	
	// Do for each day in message period
	For Each vDatesItem In vDates Do
		vAccountingDate = vDatesItem.Value;
		
		// Post to messages register
		Record = RegisterRecords.Задачи.Add();
		
		Record.УчетнаяДата = vAccountingDate;
		Record.Period = Date;
		Record.ДокОснование = ParentDoc;
		//Record.Object = ByObject;
		Record.ValidFromDate = ValidFromDate;
		Record.ValidToDate = ValidToDate;
		Record.CloseToDate = CloseToDate;
		Record.Примечания = Remarks;
		Record.ForEmployee = ForEmployee;
		Record.ForDepartment = ForDepartment;
		Record.IsClosed = IsClosed;
		Record.PopUp = PopUp;
		Record.Автор = Автор;
		Record.ClosedBy = ClosedBy;
		Record.DateWhenClosed = DateWhenClosed;
		Record.MessageType = MessageType;
		Record.MessageStatus = MessageStatus;
		Record.Color = Color;
		Record.B24TaskID = B24TaskID;
	EndDo;

	// Write register records
	RegisterRecords.Задачи.Write();
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Function CheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If НЕ ЗначениеЗаполнено(Remarks) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Текст сообщения> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Примечания> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Примечания> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Примечания", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //CheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = CurrentDate();
	Автор = ПараметрыСеанса.ТекПользователь;
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill message status
	If НЕ ЗначениеЗаполнено(MessageStatus) Тогда
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
			MessageStatus = ПараметрыСеанса.ТекущаяГостиница.MessageStatus;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber

//-----------------------------------------------------------------------------
Процедура pmAddComment(pCommentText = "") Экспорт
	vCommentRow = Comments.Add();
	vCommentRow.Period = CurrentDate();
	vCommentRow.Employee = ПараметрыСеанса.ТекПользователь;
	vCommentRow.MessageStatus = MessageStatus;
	vCommentRow.Comments = TrimR(pCommentText);
КонецПроцедуры //pmAddComment

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) And ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.MessageStatus) Тогда
		MessageStatus = ПараметрыСеанса.ТекущаяГостиница.MessageStatus;
	EndIf;
	IsClosed = False;
	ClosedBy = Неопределено;
	DateWhenClosed = Неопределено;
КонецПроцедуры //OnCopy
