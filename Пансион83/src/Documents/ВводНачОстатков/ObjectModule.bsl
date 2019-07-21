//-----------------------------------------------------------------------------
Процедура PostAccumulatingDiscountResources()
	For Each vRow In Balances Do
		Movement = RegisterRecords.НакопитСкидки.AddReceipt();
		FillPropertyValues(Movement, ThisObject);
		FillPropertyValues(Movement, vRow);
		Movement.Period = Date;
		If ЗначениеЗаполнено(DiscountType) And DiscountType.BonusCalculationFactor <> 0 Тогда
			Movement.Ресурс = 0;
		Else
			Movement.Бонус = 0;
		EndIf;
	EndDo;
	RegisterRecords.НакопитСкидки.Write();
КонецПроцедуры //PostAccumulatingDiscountResources

//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pPostingMode)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Accumulating discount resources
	PostAccumulatingDiscountResources();
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	// Check that attributes are filled
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(DiscountType) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Тип скидки> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Скидка type> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Скидка type> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ТипСкидки", pAttributeInErr);
	EndIf;
	If ЗначениеЗаполнено(DiscountType) And НЕ DiscountType.IsAccumulatingDiscount Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Тип скидки должен быть накопительным!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "Скидка type is not accumulating!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "Скидка type is not accumulating!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ТипСкидки", pAttributeInErr);
	EndIf;
	If ЗначениеЗаполнено(DiscountType) And НЕ ЗначениеЗаполнено(DiscountType.AccumulatingDiscountDimension) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Измерение накопительной скидки> у типа скидки должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "Скидка type <Accumulating Скидка dimension> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "Скидка type <Accumulating Скидка dimension> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ТипСкидки", pAttributeInErr);
	EndIf;
	// Check rows
	For Each vRow In Balances Do
		If НЕ ЗначениеЗаполнено(vRow.DiscountDimension) Тогда
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "В строке " + Format(vRow.LineNumber, "ND=6; NFD=0; NG=") + " реквизит <Измерение накопительной скидки> должен быть заполнен!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "<Accumulating Скидка dimension type> attribute should be filled in row " + Format(vRow.LineNumber, "ND=6; NFD=0; NG=") + "!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "<Accumulating Скидка dimension type> attribute should be filled in row " + Format(vRow.LineNumber, "ND=6; NFD=0; NG=") + "!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "Balances", pAttributeInErr);
			Break;
		EndIf;
	EndDo;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //CheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = CurrentDate();
	Author = ПараметрыСеанса.ТекПользователь;
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill from session parameters
	Гостиница = ПараметрыСеанса.ТекущаяГостиница;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
	Перем vMessage, vAttributeInErr;
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If pWriteMode = DocumentWriteMode.Posting Тогда
		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
		If pCancel Тогда
			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
			Message(NStr(vMessage), MessageStatus.Attention);
			ВызватьИсключение NStr(vMessage);
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

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
