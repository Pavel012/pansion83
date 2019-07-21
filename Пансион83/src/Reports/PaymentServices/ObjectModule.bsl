////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes
//
////-----------------------------------------------------------------------------
//// Initialize attributes with default values
//// Attention: This procedure could be called AFTER some attributes initialization
//// routine, so it SHOULD NOT reset attributes being set before
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill parameters with default values
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = BegOfDay(CurrentDate()); // For today
//		PeriodTo = EndOfDay(PeriodFrom);
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetReportParametersPresentation() Экспорт
//	vParamPresentation = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ Гостиница.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Гостиница ';ru='Гостиница ';de='Гостиница'") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Hotels folder ';ru='Группа гостиниц ';de='Gruppe Hotels '") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom = PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom < PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '") + PeriodPresentation(PeriodFrom, PeriodTo, cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(PaymentMethod) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Способ оплаты '; en = 'Payment method '") + 
//							 TrimAll(PaymentMethod.Description) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If НЕ Фирма.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Фирма '; en = 'Фирма '") + 
//			                     TrimAll(Фирма.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа фирм '; en = 'Companies folder '") + 
//			                     TrimAll(Фирма.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;					 
//	//If ЗначениеЗаполнено(PaymentSection) Тогда
//	//	vParamPresentation = vParamPresentation + NStr("ru = 'Кассовая секция '; en = 'Payment section '") + 
//	//						 TrimAll(PaymentSection.Description) + 
//	//						 ";" + Chars.LF;
//	//EndIf;					 
//	//If ЗначениеЗаполнено(CashRegister) Тогда
//	//	vParamPresentation = vParamPresentation + NStr("ru = 'ККМ '; en = 'Cash register '") + 
//	//						 TrimAll(CashRegister.Description) + 
//	//						 ";" + Chars.LF;
//	//EndIf;					 
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation
//
////-----------------------------------------------------------------------------
//// Runs report
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet) Экспорт
//	Перем vTemplateAttributes;
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//	
//	// Initialize report builder query generator attributes
//	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
//	
//	// Fill report parameters
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPaymentMethod", PaymentMethod);
//	ReportBuilder.Parameters.Вставить("qPaymentMethodIsEmpty", НЕ ЗначениеЗаполнено(PaymentMethod));
//	ReportBuilder.Parameters.Вставить("qCompany", Фирма);
//	ReportBuilder.Parameters.Вставить("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Фирма));
//	//ReportBuilder.Parameters.Вставить("qPaymentSection", PaymentSection);
//	//ReportBuilder.Parameters.Вставить("qPaymentSectionIsEmpty", НЕ ЗначениеЗаполнено(PaymentSection));
//	//ReportBuilder.Parameters.Вставить("qCashRegister", CashRegister);
//	//ReportBuilder.Parameters.Вставить("qCashRegisterIsEmpty", НЕ ЗначениеЗаполнено(CashRegister));
//	
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Output report to the spreadsheet
//	ReportBuilder.Put(pSpreadsheet);
//	//ReportBuilder.Template.Show(); // For debug purpose
//
//	// Apply appearance settings to the report spreadsheet
//	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
//КонецПроцедуры //pmGenerate
//	
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	PaymentServicesBalanceAndTurnovers.Услуга AS Услуга,
//	|	PaymentServicesBalanceAndTurnovers.SumExpense AS SumExpense
//	|{SELECT
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.* AS СчетПроживания,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Гостиница.* AS FolioHotel,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Контрагент.* AS FolioCustomer,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Договор.* AS FolioContract,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Клиент.* AS FolioClient,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ГруппаГостей.* AS FolioGuestGroup,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
//	|	Услуга.* AS Услуга,
//	|	PaymentServicesBalanceAndTurnovers.Услуга.ServiceType.* AS ServiceType,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.* AS Платеж,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.PaymentSection.* AS PaymentPaymentSection,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.СпособОплаты.* AS PaymentPaymentMethod,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Payer.* AS PaymentPayer,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Касса.* AS PaymentCashRegister,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Автор.* AS PaymentAuthor,
//	|	(BEGINOFPERIOD(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок, DAY)) AS УчетнаяДата,
//	|	(WEEK(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingWeek,
//	|	(MONTH(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingMonth,
//	|	(QUARTER(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingQuarter,
//	|	(YEAR(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingYear,
//	|	SumExpense}
//	|FROM
//	|	AccumulationRegister.ПлатежиУслуги.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Period,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			Платеж <> UNDEFINED
//	|				AND (СчетПроживания.Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qHotelIsEmpty)
//	|				AND (СчетПроживания.Фирма IN HIERARCHY (&qCompany)
//	|					OR &qCompanyIsEmpty)
//	|				AND (Платеж.СпособОплаты = &qPaymentMethod
//	|					OR &qPaymentMethodIsEmpty)
//	|				AND (Платеж.PaymentSection = &qPaymentSection
//	|					OR &qPaymentSectionIsEmpty)
//	|				AND (Платеж.Касса = &qCashRegister
//	|					OR &qCashRegisterIsEmpty)) AS PaymentServicesBalanceAndTurnovers
//	|{WHERE
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.* AS СчетПроживания,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Гостиница.* AS FolioHotel,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Контрагент.* AS FolioCustomer,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Договор.* AS FolioContract,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Клиент.* AS FolioClient,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ГруппаГостей.* AS FolioGuestGroup,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
//	|	PaymentServicesBalanceAndTurnovers.Услуга.* AS Услуга,
//	|	PaymentServicesBalanceAndTurnovers.Услуга.ServiceType.* AS ServiceType,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.* AS Платеж,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.PaymentSection.* AS PaymentPaymentSection,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.СпособОплаты.* AS PaymentPaymentMethod,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Payer.* AS PaymentPayer,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Касса.* AS PaymentCashRegister,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Автор.* AS PaymentAuthor,
//	|	(BEGINOFPERIOD(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок, DAY)) AS УчетнаяДата,
//	|	PaymentServicesBalanceAndTurnovers.SumOpeningBalance,
//	|	PaymentServicesBalanceAndTurnovers.SumClosingBalance,
//	|	PaymentServicesBalanceAndTurnovers.SumReceipt,
//	|	PaymentServicesBalanceAndTurnovers.SumExpense}
//	|
//	|ORDER BY
//	|	Услуга
//	|{ORDER BY
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.* AS СчетПроживания,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Гостиница.* AS FolioHotel,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Контрагент.* AS FolioCustomer,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Договор.* AS FolioContract,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Клиент.* AS FolioClient,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ГруппаГостей.* AS FolioGuestGroup,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
//	|	Услуга.* AS Услуга,
//	|	PaymentServicesBalanceAndTurnovers.Услуга.ServiceType.* AS ServiceType,
//	|	(BEGINOFPERIOD(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок, DAY)) AS УчетнаяДата,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.* AS Платеж,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.PaymentSection.* AS PaymentPaymentSection,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.СпособОплаты.* AS PaymentPaymentMethod,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Payer.* AS PaymentPayer,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Касса.* AS PaymentCashRegister,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Автор.* AS PaymentAuthor,
//	|	SumExpense}
//	|TOTALS
//	|	SUM(SumExpense)
//	|BY
//	|	OVERALL,
//	|	Услуга HIERARCHY
//	|{TOTALS BY
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.* AS СчетПроживания,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Гостиница.* AS FolioHotel,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Контрагент.* AS FolioCustomer,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Договор.* AS FolioContract,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.Клиент.* AS FolioClient,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.ГруппаГостей.* AS FolioGuestGroup,
//	|	PaymentServicesBalanceAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
//	|	Услуга.* AS Услуга,
//	|	PaymentServicesBalanceAndTurnovers.Услуга.ServiceType.* AS ServiceType,
//	|	(BEGINOFPERIOD(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок, DAY)) AS УчетнаяДата,
//	|	(WEEK(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingWeek,
//	|	(MONTH(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingMonth,
//	|	(QUARTER(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingQuarter,
//	|	(YEAR(PaymentServicesBalanceAndTurnovers.Платеж.ДатаДок)) AS AccountingYear,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.* AS Платеж,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.PaymentSection.* AS PaymentPaymentSection,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.СпособОплаты.* AS PaymentPaymentMethod,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Payer.* AS PaymentPayer,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Касса.* AS PaymentCashRegister,
//	|	PaymentServicesBalanceAndTurnovers.Платеж.Автор.* AS PaymentAuthor}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Payments distribution to services charged';RU='Распределение платежей по оказанным услугам';de='Aufteilung der Zahlungen nach erbrachten Diensten'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
