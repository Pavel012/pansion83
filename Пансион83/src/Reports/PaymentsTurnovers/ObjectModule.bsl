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
//		PeriodFrom = BegOfMonth(CurrentDate()); // For beg of month
//		PeriodTo = EndOfDay(CurrentDate());
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
//		vParamPresentation = vParamPresentation + NStr("ru = 'Группа гостей '; en = 'Guest group '") + 
//							 TrimAll(TrimAll(GuestGroup.Code) + " " + TrimAll(GuestGroup.Description)) + 
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
//Процедура pmGenerate(pSpreadsheet, pAddChart = False) Экспорт
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qIsEmptyGuestGroup", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qCompany", Фирма);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCompany", НЕ ЗначениеЗаполнено(Фирма));
//	ReportBuilder.Parameters.Вставить("qSettlement", Справочники.СпособОплаты.Акт);
//	ReportBuilder.Parameters.Вставить("qPrintDebitors", PrintDebitors);
//	ReportBuilder.Parameters.Вставить("qDepositTransfer", Справочники.СпособОплаты.ПеремещениеДепозита);
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
//	
//	// Add chart 
//	If pAddChart Тогда
//		cmAddReportChart(pSpreadsheet, ThisObject);
//	EndIf;
//КонецПроцедуры //pmGenerate
//	
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	Платежи.Гостиница AS Гостиница,
//	|	Платежи.Фирма AS Фирма,
//	|	Платежи.PaymentCurrency AS PaymentCurrency,
//	|	Платежи.PaymentSection AS PaymentSection,
//	|	Платежи.СпособОплаты AS СпособОплаты,
//	|	Платежи.Касса AS Касса,
//	|	Платежи.Payer AS Payer,
//	|	Платежи.Автор AS Автор,
//	|	Платежи.УчетнаяДата AS УчетнаяДата,
//	|	Платежи.ДокОснование,
//	|	Платежи.SumTurnover AS Сумма,
//	|	Платежи.VATSumTurnover AS СуммаНДС,
//	|	Платежи.SumExpenseTurnover AS SumExpense,
//	|	Платежи.VATSumExpenseTurnover AS VATSumExpense,
//	|	Платежи.SumReceiptTurnover AS SumReceipt,
//	|	Платежи.VATSumReceiptTurnover AS VATSumReceipt
//	|{SELECT
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	PaymentCurrency.*,
//	|	PaymentSection.*,
//	|	СпособОплаты.*,
//	|	Касса.*,
//	|	Payer.*,
//	|	Автор.*,
//	|	ДокОснование.*,
//	|	Сумма,
//	|	СуммаНДС,
//	|	SumExpense,
//	|	VATSumExpense,
//	|	SumReceipt,
//	|	VATSumReceipt,
//	|	УчетнаяДата,
//	|	(WEEK(Платежи.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(Платежи.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(Платежи.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(Платежи.УчетнаяДата)) AS AccountingYear}
//	|FROM
//	|	AccumulationRegister.Платежи.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (ДокОснование.Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (ДокОснование.Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ДокОснование.ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (Фирма IN HIERARCHY (&qCompany)
//	|					OR &qIsEmptyCompany)
//	|				AND (СпособОплаты <> &qSettlement
//	|					OR &qPrintDebitors)
//	|				AND СпособОплаты <> &qDepositTransfer) AS Платежи
//	|{WHERE
//	|	Платежи.Гостиница.*,
//	|	Платежи.Фирма.*,
//	|	Платежи.PaymentCurrency.*,
//	|	Платежи.PaymentSection.*,
//	|	Платежи.СпособОплаты.*,
//	|	Платежи.Касса.*,
//	|	Платежи.Payer.*,
//	|	Платежи.Автор.*,
//	|	Платежи.ДокОснование.*,
//	|	Платежи.SumTurnover AS Сумма,
//	|	Платежи.VATSumTurnover AS СуммаНДС,
//	|	Платежи.SumExpenseTurnover AS SumExpense,
//	|	Платежи.VATSumExpenseTurnover AS VATSumExpense,
//	|	Платежи.SumReceiptTurnover AS SumReceipt,
//	|	Платежи.VATSumReceiptTurnover AS VATSumReceipt,
//	|	Платежи.УчетнаяДата,
//	|	(WEEK(Платежи.Period)) AS AccountingWeek,
//	|	(MONTH(Платежи.Period)) AS AccountingMonth,
//	|	(QUARTER(Платежи.Period)) AS AccountingQuarter,
//	|	(YEAR(Платежи.Period)) AS AccountingYear}
//	|
//	|ORDER BY
//	|	PaymentCurrency,
//	|	СпособОплаты
//	|{ORDER BY
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	PaymentCurrency.*,
//	|	PaymentSection.*,
//	|	СпособОплаты.*,
//	|	Касса.*,
//	|	Payer.*,
//	|	Автор.*,
//	|	ДокОснование.*,
//	|	Сумма,
//	|	СуммаНДС,
//	|	SumExpense,
//	|	VATSumExpense,
//	|	SumReceipt,
//	|	VATSumReceipt,
//	|	УчетнаяДата,
//	|	(WEEK(Платежи.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(Платежи.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(Платежи.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(Платежи.УчетнаяДата)) AS AccountingYear}
//	|TOTALS
//	|	SUM(Сумма),
//	|	SUM(СуммаНДС),
//	|	SUM(SumExpense),
//	|	SUM(VATSumExpense),
//	|	SUM(SumReceipt),
//	|	SUM(VATSumReceipt)
//	|BY
//	|	OVERALL,
//	|	PaymentCurrency,
//	|	СпособОплаты HIERARCHY
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	PaymentCurrency.*,
//	|	PaymentSection.*,
//	|	СпособОплаты.*,
//	|	Касса.*,
//	|	Payer.*,
//	|	Автор.*,
//	|	ДокОснование.*,
//	|	УчетнаяДата,
//	|	(WEEK(Платежи.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(Платежи.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(Платежи.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(Платежи.УчетнаяДата)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Payments turnovers';RU='Обороты по платежам';de='Umsätze nach Zahlungen'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//Function pmIsResource(pName) Экспорт
//	If pName = "Сумма" 
//	   Or pName = "СуммаНДС" 
//	   Or pName = "SumExpense" 
//	   Or pName = "VATSumExpense" 
//	   Or pName = "SumReceipt" 
//	   Or pName = "VATSumReceipt" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
