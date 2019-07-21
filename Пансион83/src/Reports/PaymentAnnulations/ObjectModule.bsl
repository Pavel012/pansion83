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
//	If ЗначениеЗаполнено(Employee) Тогда
//		If НЕ Employee.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter'") + 
//			                     TrimAll(Employee) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '") + 
//			                     TrimAll(Employee) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
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
//	If ЗначениеЗаполнено(PaymentSection) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Кассовая секция '; en = 'Payment section '") + 
//							 TrimAll(PaymentSection.Description) + 
//							 ";" + Chars.LF;
//	EndIf;					 
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
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qEmptyEmployee", Справочники.Сотрудники.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPaymentMethod", PaymentMethod);
//	ReportBuilder.Parameters.Вставить("qPaymentMethodIsEmpty", НЕ ЗначениеЗаполнено(PaymentMethod));
//	ReportBuilder.Parameters.Вставить("qCompany", Фирма);
//	ReportBuilder.Parameters.Вставить("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Фирма));
//	ReportBuilder.Parameters.Вставить("qPaymentSection", PaymentSection);
//	ReportBuilder.Parameters.Вставить("qPaymentSectionIsEmpty", НЕ ЗначениеЗаполнено(PaymentSection));
//	ReportBuilder.Parameters.Вставить("qCashRegister", CashRegister);
//	ReportBuilder.Parameters.Вставить("qCashRegisterIsEmpty", НЕ ЗначениеЗаполнено(CashRegister));
//	ReportBuilder.Parameters.Вставить("qSettlement", Справочники.СпособОплаты.Акт);
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
//	|	AnnulatedPayments.TypeOfAnnulation AS TypeOfAnnulation,
//	|	AnnulatedPayments.DateOfAnnulation AS DateOfAnnulation,
//	|	AnnulatedPayments.AuthorOfAnnulation AS AuthorOfAnnulation,
//	|	AnnulatedPayments.ДатаДок AS Date,
//	|	AnnulatedPayments.Ref AS Платеж,
//	|	AnnulatedPayments.PaymentCurrency AS PaymentCurrency,
//	|	AnnulatedPayments.СпособОплаты AS СпособОплаты,
//	|	AnnulatedPayments.Payer AS Payer,
//	|	AnnulatedPayments.PaymentSection AS PaymentSection,
//	|	AnnulatedPayments.Касса AS Касса,
//	|	AnnulatedPayments.Примечания,
//	|	AnnulatedPayments.Автор AS Автор,
//	|	AnnulatedPayments.Сумма AS Сумма,
//	|	AnnulatedPayments.СуммаНДС AS СуммаНДС,
//	|	1 AS Количество
//	|{SELECT
//	|	TypeOfAnnulation,
//	|	DateOfAnnulation,
//	|	AuthorOfAnnulation.*,
//	|	Date,
//	|	Платеж.*,
//	|	PaymentCurrency.*,
//	|	СпособОплаты.*,
//	|	Payer.*,
//	|	Касса.*,
//	|	PaymentSection.*,
//	|	Примечания,
//	|	Автор.*,
//	|	AnnulatedPayments.Фирма.*,
//	|	AnnulatedPayments.Гостиница.*,
//	|	AnnulatedPayments.ДокОснование.*,
//	|	AnnulatedPayments.СтавкаНДС.*,
//	|	Сумма,
//	|	СуммаНДС,
//	|	Количество,
//	|	(BEGINOFPERIOD(AnnulatedPayments.ДатаДок, DAY)) AS УчетнаяДата,
//	|	(WEEK(AnnulatedPayments.ДатаДок)) AS AccountingWeek,
//	|	(MONTH(AnnulatedPayments.ДатаДок)) AS AccountingMonth,
//	|	(QUARTER(AnnulatedPayments.ДатаДок)) AS AccountingQuarter,
//	|	(YEAR(AnnulatedPayments.ДатаДок)) AS AccountingYear}
//	|FROM
//	|	(SELECT
//	|		Платежи.TypeOfAnnulation AS TypeOfAnnulation,
//	|		Платежи.DateOfAnnulation AS DateOfAnnulation,
//	|		Платежи.AuthorOfAnnulation AS AuthorOfAnnulation,
//	|		Платежи.ДатаДок AS Date,
//	|		Платежи.Ref AS Ref,
//	|		Платежи.PaymentCurrency AS PaymentCurrency,
//	|		Платежи.СпособОплаты AS СпособОплаты,
//	|		Платежи.Payer AS Payer,
//	|		Платежи.Касса AS Касса,
//	|		Платежи.PaymentSection AS PaymentSection,
//	|		Платежи.Примечания AS Примечания,
//	|		Платежи.Автор AS Автор,
//	|		Платежи.Фирма AS Фирма,
//	|		Платежи.Гостиница AS Гостиница,
//	|		Платежи.ДокОснование AS ДокОснование,
//	|		Платежи.СтавкаНДС AS СтавкаНДС,
//	|		Платежи.Сумма AS Сумма,
//	|		Платежи.СуммаНДС AS СуммаНДС
//	|	FROM
//	|		Document.Платеж AS Платежи
//	|	WHERE
//	|		(NOT Платежи.Posted)
//	|		AND Платежи.DateOfAnnulation >= &qPeriodFrom
//	|		AND Платежи.DateOfAnnulation < &qPeriodTo
//	|		AND Платежи.СпособОплаты <> &qSettlement
//	|		AND (Платежи.AuthorOfAnnulation IN HIERARCHY (&qEmployee)
//	|				OR Платежи.AuthorOfAnnulation = &qEmptyEmployee)
//	|		AND (Платежи.Гостиница IN HIERARCHY (&qHotel)
//	|				OR &qHotelIsEmpty)
//	|		AND (Платежи.PaymentSection = &qPaymentSection
//	|				OR &qPaymentSectionIsEmpty)
//	|		AND (Платежи.СпособОплаты = &qPaymentMethod
//	|				OR &qPaymentMethodIsEmpty)
//	|		AND (Платежи.Фирма = &qCompany
//	|				OR &qCompanyIsEmpty)
//	|		AND (Платежи.Касса = &qCashRegister
//	|				OR &qCashRegisterIsEmpty)
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		CustomerPayments.TypeOfAnnulation,
//	|		CustomerPayments.DateOfAnnulation,
//	|		CustomerPayments.AuthorOfAnnulation,
//	|		CustomerPayments.ДатаДок,
//	|		CustomerPayments.Ref,
//	|		CustomerPayments.PaymentCurrency,
//	|		CustomerPayments.СпособОплаты,
//	|		CustomerPayments.Контрагент,
//	|		CustomerPayments.Касса,
//	|		CustomerPayments.PaymentSection,
//	|		CustomerPayments.Примечания,
//	|		CustomerPayments.Автор,
//	|		CustomerPayments.Фирма,
//	|		CustomerPayments.Гостиница,
//	|		CustomerPayments.ДокОснование,
//	|		CustomerPayments.СтавкаНДС,
//	|		CustomerPayments.Сумма,
//	|		CustomerPayments.СуммаНДС
//	|	FROM
//	|		Document.ПлатежКонтрагента AS CustomerPayments
//	|	WHERE
//	|		(NOT CustomerPayments.Posted)
//	|		AND CustomerPayments.DateOfAnnulation >= &qPeriodFrom
//	|		AND CustomerPayments.DateOfAnnulation < &qPeriodTo
//	|		AND CustomerPayments.СпособОплаты <> &qSettlement
//	|		AND (CustomerPayments.AuthorOfAnnulation IN HIERARCHY (&qEmployee)
//	|				OR CustomerPayments.AuthorOfAnnulation = &qEmptyEmployee)
//	|		AND (CustomerPayments.Гостиница IN HIERARCHY (&qHotel)
//	|				OR &qHotelIsEmpty)
//	|		AND (CustomerPayments.PaymentSection = &qPaymentSection
//	|				OR &qPaymentSectionIsEmpty)
//	|		AND (CustomerPayments.СпособОплаты = &qPaymentMethod
//	|				OR &qPaymentMethodIsEmpty)
//	|		AND (CustomerPayments.Фирма = &qCompany
//	|				OR &qCompanyIsEmpty)
//	|		AND (CustomerPayments.Касса = &qCashRegister
//	|				OR &qCashRegisterIsEmpty)) AS AnnulatedPayments
//	|{WHERE
//	|	AnnulatedPayments.TypeOfAnnulation AS TypeOfAnnulation,
//	|	AnnulatedPayments.DateOfAnnulation AS DateOfAnnulation,
//	|	AnnulatedPayments.AuthorOfAnnulation.* AS AuthorOfAnnulation,
//	|	AnnulatedPayments.Гостиница.*,
//	|	AnnulatedPayments.Фирма.*,
//	|	AnnulatedPayments.PaymentCurrency.*,
//	|	AnnulatedPayments.PaymentSection.*,
//	|	AnnulatedPayments.СпособОплаты.*,
//	|	AnnulatedPayments.Касса.*,
//	|	AnnulatedPayments.Payer.*,
//	|	AnnulatedPayments.Автор.*,
//	|	AnnulatedPayments.ДокОснование.*,
//	|	(BEGINOFPERIOD(AnnulatedPayments.ДатаДок, DAY)) AS УчетнаяДата,
//	|	(WEEK(AnnulatedPayments.ДатаДок)) AS AccountingWeek,
//	|	(MONTH(AnnulatedPayments.ДатаДок)) AS AccountingMonth,
//	|	(QUARTER(AnnulatedPayments.ДатаДок)) AS AccountingQuarter,
//	|	(YEAR(AnnulatedPayments.ДатаДок)) AS AccountingYear,
//	|	AnnulatedPayments.Ref.* AS Платеж,
//	|	AnnulatedPayments.ДатаДок,
//	|	AnnulatedPayments.Сумма,
//	|	AnnulatedPayments.СуммаНДС,
//	|	AnnulatedPayments.СтавкаНДС.*,
//	|	AnnulatedPayments.Remarks}
//	|
//	|ORDER BY
//	|	DateOfAnnulation
//	|{ORDER BY
//	|	TypeOfAnnulation,
//	|	DateOfAnnulation,
//	|	AuthorOfAnnulation.*,
//	|	Date,
//	|	Автор.*,
//	|	AnnulatedPayments.Гостиница.*,
//	|	AnnulatedPayments.Фирма.*,
//	|	PaymentCurrency.*,
//	|	PaymentSection.*,
//	|	СпособОплаты.*,
//	|	Касса.*,
//	|	Payer.*,
//	|	AnnulatedPayments.ДокОснование.*,
//	|	Платеж.*,
//	|	AnnulatedPayments.СтавкаНДС.*,
//	|	Сумма,
//	|	VATSum}
//	|TOTALS
//	|	SUM(Сумма),
//	|	SUM(СуммаНДС),
//	|	SUM(Количество)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	TypeOfAnnulation,
//	|	AuthorOfAnnulation.*,
//	|	Автор.*,
//	|	AnnulatedPayments.Гостиница.*,
//	|	AnnulatedPayments.Фирма.*,
//	|	PaymentCurrency.*,
//	|	PaymentSection.*,
//	|	СпособОплаты.*,
//	|	Касса.*,
//	|	Payer.*,
//	|	AnnulatedPayments.ДокОснование.*,
//	|	Платеж.*,
//	|	AnnulatedPayments.СтавкаНДС.*,
//	|	(BEGINOFPERIOD(AnnulatedPayments.ДатаДок, DAY)) AS УчетнаяДата,
//	|	(WEEK(AnnulatedPayments.ДатаДок)) AS AccountingWeek,
//	|	(MONTH(AnnulatedPayments.ДатаДок)) AS AccountingMonth,
//	|	(QUARTER(AnnulatedPayments.ДатаДок)) AS AccountingQuarter,
//	|	(YEAR(AnnulatedPayments.ДатаДок)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Payment annualations audit';RU='Аудит аннуляций платежей';de='Buchprüfung der Annullierungen von Zahlungen'");
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
