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
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If НЕ Контрагент.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("de='Firma';en='Контрагент ';ru='Контрагент '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("de='Gruppe Firmen';en='Customers folder ';ru='Группа контрагентов '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(Contract) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Contract ';ru='Договор ';de='Vertrag '") + 
//							 TrimAll(Contract.Description) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guest group ';ru='Группа ';de='Gruppe '") + 
//							 TrimAll(GuestGroup.Code) + 
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
//	ReportBuilder.Parameters.Вставить("qCompany", Фирма);
//	ReportBuilder.Parameters.Вставить("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Фирма));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qContractIsEmpty", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Output report to the spreadsheet
//	
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
//	|	ПеремещениеДепозита.ДатаДок AS Date,
//	|	ПеремещениеДепозита.Ref AS ПеремещениеДепозита,
//	|	ПеремещениеДепозита.SumInFolioFromCurrency,
//	|	ПеремещениеДепозита.FolioFromCurrency,
//	|	ПеремещениеДепозита.FolioFrom.Контрагент,
//	|	ПеремещениеДепозита.FolioFrom.Договор,
//	|	ПеремещениеДепозита.FolioFrom.ГруппаГостей,
//	|	ПеремещениеДепозита.FolioFrom.Клиент,
//	|	ПеремещениеДепозита.FolioFrom.НомерРазмещения,
//	|	ПеремещениеДепозита.FolioFrom.DateTimeFrom,
//	|	ПеремещениеДепозита.FolioFrom.DateTimeTo,
//	|	ПеремещениеДепозита.SumInFolioToCurrency,
//	|	ПеремещениеДепозита.FolioToCurrency,
//	|	ПеремещениеДепозита.FolioTo.Контрагент,
//	|	ПеремещениеДепозита.FolioTo.Договор,
//	|	ПеремещениеДепозита.FolioTo.ГруппаГостей,
//	|	ПеремещениеДепозита.FolioTo.Клиент,
//	|	ПеремещениеДепозита.FolioTo.НомерРазмещения,
//	|	ПеремещениеДепозита.FolioTo.DateTimeFrom,
//	|	ПеремещениеДепозита.FolioTo.DateTimeTo,
//	|	ПеремещениеДепозита.Примечания,
//	|	ПеремещениеДепозита.Автор
//	|{SELECT
//	|	Date,
//	|	ПеремещениеДепозита.*,
//	|	ПеремещениеДепозита.FolioFrom.*,
//	|	SumInFolioFromCurrency,
//	|	FolioFromCurrency.*,
//	|	ПеремещениеДепозита.FolioFrom.СпособОплаты.* AS FolioFromPaymentMethod,
//	|	FolioFromCustomer.*,
//	|	FolioFromContract.*,
//	|	FolioFromGuestGroup.*,
//	|	FolioFromClient.*,
//	|	FolioFromRoom.*,
//	|	FolioFromDateTimeFrom,
//	|	FolioFromDateTimeTo,
//	|	ПеремещениеДепозита.FolioTo.*,
//	|	SumInFolioToCurrency,
//	|	FolioToCurrency.*,
//	|	ПеремещениеДепозита.FolioTo.СпособОплаты.* AS FolioToPaymentMethod,
//	|	FolioToCustomer.*,
//	|	FolioToContract.*,
//	|	FolioToGuestGroup.*,
//	|	FolioToClient.*,
//	|	FolioToRoom.*,
//	|	FolioToDateTimeFrom,
//	|	FolioToDateTimeTo,
//	|	ПеремещениеДепозита.ДокОснование.*,
//	|	Примечания,
//	|	Автор.*,
//	|	ПеремещениеДепозита.Гостиница.*,
//	|	ПеремещениеДепозита.ExchangeRateDate,
//	|	ПеремещениеДепозита.FolioToCurrencyExchangeRate,
//	|	ПеремещениеДепозита.FolioFromCurrencyExchangeRate,
//	|	(BEGINOFPERIOD(ПеремещениеДепозита.ДатаДок, DAY)) AS УчетнаяДата,
//	|	(WEEK(ПеремещениеДепозита.ДатаДок)) AS AccountingWeek,
//	|	(MONTH(ПеремещениеДепозита.ДатаДок)) AS AccountingMonth,
//	|	(QUARTER(ПеремещениеДепозита.ДатаДок)) AS AccountingQuarter,
//	|	(YEAR(ПеремещениеДепозита.ДатаДок)) AS AccountingYear}
//	|FROM
//	|	Document.ПеремещениеДепозита AS ПеремещениеДепозита
//	|WHERE
//	|	(ПеремещениеДепозита.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|	AND (ПеремещениеДепозита.FolioFrom.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR ПеремещениеДепозита.FolioTo.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qCustomerIsEmpty)
//	|	AND (ПеремещениеДепозита.FolioFrom.Договор = &qContract
//	|			OR ПеремещениеДепозита.FolioTo.Договор = &qContract
//	|			OR &qContractIsEmpty)
//	|	AND (ПеремещениеДепозита.FolioFrom.ГруппаГостей = &qGuestGroup
//	|			OR ПеремещениеДепозита.FolioTo.ГруппаГостей = &qGuestGroup
//	|			OR &qGuestGroupIsEmpty)
//	|	AND ПеремещениеДепозита.ДатаДок >= &qPeriodFrom
//	|	AND ПеремещениеДепозита.ДатаДок < &qPeriodTo
//	|	AND ПеремещениеДепозита.Posted
//	|	AND (ПеремещениеДепозита.FolioFrom.Фирма IN HIERARCHY (&qCompany)
//	|			OR ПеремещениеДепозита.FolioTo.Фирма IN HIERARCHY (&qCompany)
//	|			OR &qCompanyIsEmpty)
//	|{WHERE
//	|	ПеремещениеДепозита.Ref.* AS ПеремещениеДепозита,
//	|	ПеремещениеДепозита.ДокОснование.*,
//	|	ПеремещениеДепозита.FolioFrom.*,
//	|	ПеремещениеДепозита.FolioTo.*,
//	|	ПеремещениеДепозита.Гостиница.*,
//	|	ПеремещениеДепозита.SumInFolioFromCurrency,
//	|	ПеремещениеДепозита.FolioFromCurrency.*,
//	|	ПеремещениеДепозита.SumInFolioToCurrency,
//	|	ПеремещениеДепозита.FolioToCurrency.*,
//	|	ПеремещениеДепозита.ExchangeRateDate,
//	|	ПеремещениеДепозита.Примечания,
//	|	ПеремещениеДепозита.Автор.*,
//	|	ПеремещениеДепозита.ДатаДок,
//	|	ПеремещениеДепозита.FolioToCurrencyExchangeRate,
//	|	ПеремещениеДепозита.FolioFromCurrencyExchangeRate,
//	|	ПеремещениеДепозита.FolioFrom.Контрагент.*,
//	|	ПеремещениеДепозита.FolioFrom.Договор.*,
//	|	ПеремещениеДепозита.FolioFrom.ГруппаГостей.*,
//	|	ПеремещениеДепозита.FolioFrom.Клиент.*,
//	|	ПеремещениеДепозита.FolioFrom.DateTimeFrom,
//	|	ПеремещениеДепозита.FolioFrom.DateTimeTo,
//	|	ПеремещениеДепозита.FolioFrom.НомерРазмещения.*,
//	|	ПеремещениеДепозита.FolioTo.Контрагент.*,
//	|	ПеремещениеДепозита.FolioTo.Договор.*,
//	|	ПеремещениеДепозита.FolioTo.ГруппаГостей.*,
//	|	ПеремещениеДепозита.FolioTo.Клиент.*,
//	|	ПеремещениеДепозита.FolioTo.DateTimeFrom,
//	|	ПеремещениеДепозита.FolioTo.DateTimeTo,
//	|	ПеремещениеДепозита.FolioTo.НомерРазмещения.*,
//	|	ПеремещениеДепозита.FolioTo.СпособОплаты.*,
//	|	ПеремещениеДепозита.FolioFrom.СпособОплаты.*}
//	|
//	|ORDER BY
//	|	Date
//	|{ORDER BY
//	|	ПеремещениеДепозита.*,
//	|	ПеремещениеДепозита.ДокОснование.*,
//	|	ПеремещениеДепозита.FolioFrom.*,
//	|	ПеремещениеДепозита.FolioTo.*,
//	|	ПеремещениеДепозита.Гостиница.*,
//	|	SumInFolioFromCurrency,
//	|	ПеремещениеДепозита.FolioFromCurrency.*,
//	|	SumInFolioToCurrency,
//	|	FolioToCurrency.*,
//	|	ПеремещениеДепозита.ExchangeRateDate,
//	|	Примечания,
//	|	Автор.*,
//	|	Date,
//	|	ПеремещениеДепозита.FolioToCurrencyExchangeRate,
//	|	ПеремещениеДепозита.FolioFromCurrencyExchangeRate,
//	|	FolioFromCustomer.*,
//	|	FolioFromContract.*,
//	|	FolioFromGuestGroup.*,
//	|	FolioFromClient.*,
//	|	FolioFromDateTimeFrom,
//	|	FolioFromDateTimeTo,
//	|	FolioFromRoom.*,
//	|	FolioToCustomer.*,
//	|	FolioToContract.*,
//	|	FolioToGuestGroup.*,
//	|	FolioToClient.*,
//	|	FolioToDateTimeFrom,
//	|	FolioToDateTimeTo,
//	|	FolioToRoom.*,
//	|	ПеремещениеДепозита.FolioTo.СпособОплаты.* AS FolioToPaymentMethod,
//	|	ПеремещениеДепозита.FolioFrom.СпособОплаты.* AS FolioFromPaymentMethod}
//	|TOTALS
//	|	SUM(SumInFolioFromCurrency),
//	|	SUM(SumInFolioToCurrency)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	ПеремещениеДепозита.Ref.* AS ПеремещениеДепозита,
//	|	ПеремещениеДепозита.ДокОснование.*,
//	|	ПеремещениеДепозита.FolioFrom.*,
//	|	ПеремещениеДепозита.FolioTo.*,
//	|	ПеремещениеДепозита.Гостиница.*,
//	|	FolioFromCurrency.*,
//	|	FolioToCurrency.*,
//	|	Автор.*,
//	|	FolioFromCustomer.*,
//	|	FolioFromContract.*,
//	|	FolioFromGuestGroup.*,
//	|	FolioFromClient.*,
//	|	FolioFromRoom.*,
//	|	FolioToCustomer.*,
//	|	FolioToContract.*,
//	|	FolioToGuestGroup.*,
//	|	FolioToClient.*,
//	|	FolioToRoom.*,
//	|	ПеремещениеДепозита.FolioFrom.СпособОплаты.* AS FolioFromPaymentMethod,
//	|	ПеремещениеДепозита.FolioTo.СпособОплаты.* AS FolioToPaymentMethod,
//	|	(BEGINOFPERIOD(ПеремещениеДепозита.ДатаДок, DAY)) AS УчетнаяДата,
//	|	(WEEK(ПеремещениеДепозита.ДатаДок)) AS AccountingWeek,
//	|	(MONTH(ПеремещениеДепозита.ДатаДок)) AS AccountingMonth,
//	|	(QUARTER(ПеремещениеДепозита.ДатаДок)) AS AccountingQuarter,
//	|	(YEAR(ПеремещениеДепозита.ДатаДок)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Deposit transfers';RU='Перемещения депозитов';de='Verschiebungen der Deposite'");
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
