////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------

////-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes

////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes

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
//	If ЗначениеЗаполнено(CashRegister) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'ККМ '; en = 'Cash register '") + 
//							 TrimAll(CashRegister.Description) + 
//							 ";" + Chars.LF;
//	EndIf;					 
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation

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
//	ReportBuilder.Parameters.Вставить("qCashRegister", CashRegister);
//	ReportBuilder.Parameters.Вставить("qCashRegisterIsEmpty", НЕ ЗначениеЗаполнено(CashRegister));
//	ReportBuilder.Parameters.Вставить("qSettlement", Справочники.СпособОплаты.Акт);
//	ReportBuilder.Parameters.Вставить("qPrintDebitors", PrintDebitors);
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
//	|	Платежи.Period AS Period,
//	|	Платежи.Recorder,
//	|	Платежи.PaymentCurrency AS PaymentCurrency,
//	|	Платежи.СпособОплаты AS СпособОплаты,
//	|	Платежи.Payer AS Payer,
//	|	Платежи.PaymentSection AS PaymentSection,
//	|	Платежи.Касса AS Касса,
//	|	Платежи.Примечания,
//	|	Платежи.Автор AS Автор,
//	|	Платежи.Сумма AS Сумма,
//	|	Платежи.СуммаНДС AS СуммаНДС,
//	|	Платежи.SumReceipt AS SumReceipt,
//	|	Платежи.VATSumReceipt AS VATSumReceipt,
//	|	Платежи.SumExpense AS SumExpense,
//	|	Платежи.VATSumExpense AS VATSumExpense
//	|{SELECT
//	|	Period,
//	|	Recorder.*,
//	|	PaymentCurrency.*,
//	|	СпособОплаты.*,
//	|	Payer.*,
//	|	Платежи.Recorder.Контрагент.* AS Контрагент,
//	|	Платежи.Recorder.Договор.* AS Договор,
//	|	Платежи.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	Платежи.Recorder.СчетНаОплату.* AS СчетНаОплату,
//	|	Касса.*,
//	|	PaymentSection.*,
//	|	Примечания,
//	|	Автор.*,
//	|	Платежи.Фирма.*,
//	|	Платежи.Гостиница.*,
//	|	Платежи.ДокОснование.*,
//	|	Платежи.СтавкаНДС.*,
//	|	Сумма,
//	|	СуммаНДС,
//	|	SumReceipt,
//	|	VATSumReceipt,
//	|	SumExpense,
//	|	VATSumExpense,
//	|	Платежи.УчетнаяДата,
//	|	(WEEK(Платежи.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(Платежи.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(Платежи.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(Платежи.УчетнаяДата)) AS AccountingYear,
//	|	CloseCashRegisterDays.Автор.* AS CloseCashRegisterDayAuthor,
//	|	CloseCashRegisterDays.ДатаДок AS CloseCashRegisterDate,
//	|	(BEGINOFPERIOD(CloseCashRegisterDays.ДатаДок, DAY)) AS CloseCashRegisterDay}
//	|FROM
//	|	AccumulationRegister.Платежи AS Платежи
//	|		LEFT JOIN Document.ЗакрытиеКассовойСмены AS CloseCashRegisterDays
//	|		ON Платежи.Касса = CloseCashRegisterDays.Касса
//	|			AND Платежи.Period >= CloseCashRegisterDays.ДатаНачКвоты
//	|			AND Платежи.Period < CloseCashRegisterDays.ДатаДок
//	|			AND (CloseCashRegisterDays.Posted)
//	|WHERE
//	|	Платежи.Period >= &qPeriodFrom
//	|	AND Платежи.Period <= &qPeriodTo
//	|	AND (Платежи.СпособОплаты <> &qSettlement
//	|			OR &qPrintDebitors)
//	|	AND (Платежи.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|	AND (Платежи.PaymentSection = &qPaymentSection
//	|			OR &qPaymentSectionIsEmpty)
//	|	AND (Платежи.СпособОплаты = &qPaymentMethod
//	|			OR &qPaymentMethodIsEmpty)
//	|	AND (Платежи.Фирма = &qCompany
//	|			OR &qCompanyIsEmpty)
//	|	AND (Платежи.Касса = &qCashRegister
//	|			OR &qCashRegisterIsEmpty)
//	|{WHERE
//	|	Платежи.Гостиница.*,
//	|	Платежи.Фирма.*,
//	|	Платежи.PaymentCurrency.*,
//	|	Платежи.PaymentSection.*,
//	|	Платежи.СпособОплаты.*,
//	|	Платежи.Recorder.*,
//	|	Платежи.Recorder.Контрагент.* AS Контрагент,
//	|	Платежи.Recorder.Договор.* AS Договор,
//	|	Платежи.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	Платежи.Recorder.СчетНаОплату.* AS СчетНаОплату,
//	|	Платежи.Касса.*,
//	|	Платежи.Payer.*,
//	|	Платежи.Автор.*,
//	|	Платежи.ДокОснование.*,
//	|	Платежи.УчетнаяДата,
//	|	(WEEK(Платежи.Period)) AS AccountingWeek,
//	|	(MONTH(Платежи.Period)) AS AccountingMonth,
//	|	(QUARTER(Платежи.Period)) AS AccountingQuarter,
//	|	(YEAR(Платежи.Period)) AS AccountingYear,
//	|	Платежи.Period,
//	|	Платежи.Сумма,
//	|	Платежи.СуммаНДС,
//	|	Платежи.SumExpense,
//	|	Платежи.VATSumExpense,
//	|	Платежи.SumReceipt,
//	|	Платежи.VATSumReceipt,
//	|	Платежи.СтавкаНДС.*,
//	|	Платежи.Примечания,
//	|	CloseCashRegisterDays.Автор.* AS CloseCashRegisterDayAuthor,
//	|	CloseCashRegisterDays.ДатаДок AS CloseCashRegisterDate,
//	|	(BEGINOFPERIOD(CloseCashRegisterDays.ДатаДок, DAY)) AS CloseCashRegisterDay}
//	|
//	|ORDER BY
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	Платежи.Гостиница.*,
//	|	Платежи.Фирма.*,
//	|	PaymentCurrency.*,
//	|	PaymentSection.*,
//	|	СпособОплаты.*,
//	|	Касса.*,
//	|	Payer.*,
//	|	Автор.*,
//	|	Платежи.ДокОснование.*,
//	|	Recorder.*,
//	|	Платежи.Recorder.Контрагент.* AS Контрагент,
//	|	Платежи.Recorder.Договор.* AS Договор,
//	|	Платежи.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	Платежи.Recorder.СчетНаОплату.* AS СчетНаОплату,
//	|	Платежи.СтавкаНДС.*,
//	|	Сумма,
//	|	СуммаНДС,
//	|	SumExpense,
//	|	VATSumExpense,
//	|	SumReceipt,
//	|	VATSumReceipt,
//	|	CloseCashRegisterDays.Автор.* AS CloseCashRegisterDayAuthor,
//	|	CloseCashRegisterDays.ДатаДок AS CloseCashRegisterDate,
//	|	(BEGINOFPERIOD(CloseCashRegisterDays.ДатаДок, DAY)) AS CloseCashRegisterDay}
//	|TOTALS
//	|	SUM(Сумма),
//	|	SUM(СуммаНДС),
//	|	SUM(SumReceipt),
//	|	SUM(VATSumReceipt),
//	|	SUM(SumExpense),
//	|	SUM(VATSumExpense)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	Платежи.Гостиница.*,
//	|	Платежи.Фирма.*,
//	|	PaymentCurrency.*,
//	|	PaymentSection.*,
//	|	СпособОплаты.*,
//	|	Касса.*,
//	|	Payer.*,
//	|	Автор.*,
//	|	Платежи.ДокОснование.*,
//	|	Recorder.*,
//	|	Платежи.Recorder.Контрагент.* AS Контрагент,
//	|	Платежи.Recorder.Договор.* AS Договор,
//	|	Платежи.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	Платежи.Recorder.СчетНаОплату.* AS СчетНаОплату,
//	|	Платежи.СтавкаНДС.*,
//	|	Платежи.УчетнаяДата,
//	|	(WEEK(Платежи.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(Платежи.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(Платежи.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(Платежи.УчетнаяДата)) AS AccountingYear,
//	|	CloseCashRegisterDays.Автор.* AS CloseCashRegisterDayAuthor,
//	|	CloseCashRegisterDays.ДатаДок AS CloseCashRegisterDate,
//	|	(BEGINOFPERIOD(CloseCashRegisterDays.ДатаДок, DAY)) AS CloseCashRegisterDay}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Payments';RU='Платежи';de='Zahlungen'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder

////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
