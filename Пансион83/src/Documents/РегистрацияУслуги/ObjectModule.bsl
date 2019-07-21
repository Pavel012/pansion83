//-----------------------------------------------------------------------------
Процедура PostToServiceRegistration()
	Movement = RegisterRecords.РегистрацияУслуги.Add();
	
	Movement.RecordType = AccumulationRecordType.Expense;
	Movement.Period = Date;
	
	// Fill properties
	FillPropertyValues(Movement, ЛицевойСчет);
	FillPropertyValues(Movement, ThisObject);
	
	// Fill accounting date
	Movement.УчетнаяДата = ?(ЗначениеЗаполнено(AccountingDate), AccountingDate, BegOfDay(Date));
	
	// Fill resource
	If ЗначениеЗаполнено(ParentDoc) Тогда
		If TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
			Movement.Ресурс = ParentDoc.Ресурс;
		EndIf;
	EndIf;
	
	// Resources
	Movement.Сумма = Sum;
	
	// Attributes
	//Movement.Цена = cmRecalculatePrice(Movement.Сумма, Movement.Количество);
	
	RegisterRecords.РегистрацияУслуги.Write();
КонецПроцедуры //PostToServiceRegistration

//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pMode)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Post to service registration
	PostToServiceRegistration();
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Процедура pmFillByFolio(pFolio) Экспорт
	If pFolio = Documents.СчетПроживания.EmptyRef() Тогда
		Return;
	EndIf;
	// ЛицевойСчет and folio currency
	ЛицевойСчет = pFolio;
	FolioCurrency = ЛицевойСчет.FolioCurrency;
	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница) Тогда
		If Гостиница <> ЛицевойСчет.Гостиница Тогда
			Гостиница = ЛицевойСчет.Гостиница;
			SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
		EndIf;
	EndIf;
	// Guest group, client, ГруппаНомеров
	GuestGroup = pFolio.ГруппаГостей;
	Client = pFolio.Клиент;
	Room = pFolio.НомерРазмещения;
	// Fill parent document
	ParentDoc = pFolio.ДокОснование;
	// Fill resource
	If ЗначениеЗаполнено(ParentDoc) Тогда
		If TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
			Resource = ParentDoc.Ресурс;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillByFolio

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
	If НЕ ЗначениеЗаполнено(ЛицевойСчет) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Лицевой счет> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<СчетПроживания> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<СчетПроживания> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(Service) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Услуга> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Услуга> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Услуга> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Услуга", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(FolioCurrency) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта фолио> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<СчетПроживания Валюта> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<СчетПроживания Валюта> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ВалютаЛицСчета", pAttributeInErr);
	EndIf;
	// Check that only one service per day per guest is allowed
	If ЗначениеЗаполнено(Service) And Service.ServiceRegistrationIsTurnedOn And Service.MaxOneServicePerDayIsAllowed Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	РегистрацияУслуги.Ref
		|FROM
		|	Document.РегистрацияУслуги AS РегистрацияУслуги
		|WHERE
		|	РегистрацияУслуги.Ref <> &qDoc
		|	AND РегистрацияУслуги.Posted
		|	AND РегистрацияУслуги.УчетнаяДата = &qAccountingDate
		|	AND РегистрацияУслуги.Клиент = &qClient
		|	AND РегистрацияУслуги.Услуга = &qService
		|
		|ORDER BY
		|	РегистрацияУслуги.PointInTime";
		vQry.SetParameter("qDoc", Ref);
		vQry.SetParameter("qAccountingDate", AccountingDate);
		vQry.SetParameter("qClient", Client);
		vQry.SetParameter("qService", Service);
		vDocs = vQry.Execute().Unload();
		If vDocs.Count() > 0 Тогда
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "Разрешено использовать только одну услугу в день!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "One Услуга per day is allowed only!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "Ein Услуга pro Tag ist erlaubt!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "Клиент", pAttributeInErr);
		EndIf;
	EndIf;
	// Call external algorithm if any
	vUserExitProc = Справочники.ВнешниеОбработки.ServiceRegistrationDocumentAttributesCheck;
	If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm And НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
		Execute(TrimAll(vUserExitProc.Algorithm));
	EndIf;
	// Check results
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = CurrentDate();
	Автор = ПараметрыСеанса.ТекПользователь;
	AccountingDate = BegOfDay(Date);
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill from session parameters
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	If ЗначениеЗаполнено(Гостиница) Тогда
		FolioCurrency  = Гостиница.FolioCurrency;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура Filling(pBase)
	// Fill attributes with default values
	pmFillAttributesWithDefaultValues();
	// Fill from the base
	If ЗначениеЗаполнено(pBase) Тогда
		If TypeOf(pBase) = Type("DocumentRef.СчетПроживания") Тогда
			pmFillByFolio(pBase);
		EndIf;
	EndIf;
КонецПроцедуры //Filling

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
			ВызватьИсключение NStr(vMessage);
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(Гостиница) Тогда
		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
	EndIf;
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber
