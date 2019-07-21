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
//		If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//			PeriodFrom = BegOfMonth(CurrentDate()); // For beg. of month
//			PeriodTo = EndOfDay(CurrentDate());
//		EndIf;
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
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If НЕ Фирма.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Фирма '; en = 'Фирма '") + 
//			                     TrimAll(Фирма.LegacyName) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа фирм '; en = 'Companies folder '") + 
//			                     TrimAll(Фирма.Description) + 
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
//	If ЗначениеЗаполнено(Currency) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Валюта '; en = 'Currency '") + 
//							 TrimAll(Currency.Description) + 
//							 ";" + Chars.LF;
//	EndIf;
//	If ShowExpiredInvoicesOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Show expired invoices only';ru='Только счета с просроченной оплатой';de='Nur Rechnungen mit versäumter Zahlung'") + 
//							 ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", ?(ЗначениеЗаполнено(PeriodFrom), PeriodFrom, '00010101010101'));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), PeriodTo, '39991231235959'));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qIsEmptyGuestGroup", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qCompany", Фирма);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCompany", НЕ ЗначениеЗаполнено(Фирма));
//	ReportBuilder.Parameters.Вставить("qCurrency", Currency);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCurrency", НЕ ЗначениеЗаполнено(Currency));
//	ReportBuilder.Parameters.Вставить("qBegOfCurrentDate", BegOfDay(CurrentDate()));
//	ReportBuilder.Parameters.Вставить("qShowExpiredInvoicesOnly", ShowExpiredInvoicesOnly);
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
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
//	|	Invoices.Гостиница AS Гостиница,
//	|	Invoices.Фирма AS Фирма,
//	|	Invoices.Валюта AS Валюта,
//	|	Invoices.Контрагент AS Контрагент,
//	|	Invoices.Договор AS Договор,
//	|	Invoices.ГруппаГостей AS ГруппаГостей,
//	|	Invoices.СчетНаОплату AS СчетНаОплату,
//	|	Invoices.Сумма AS Сумма,
//	|	InvoiceBalances.InvoiceBalance AS InvoiceBalance
//	|INTO Invoices
//	|FROM
//	|	(SELECT
//	|		InvoiceAccountsReceipt.Гостиница AS Гостиница,
//	|		InvoiceAccountsReceipt.Фирма AS Фирма,
//	|		InvoiceAccountsReceipt.ВалютаРасчетов AS Валюта,
//	|		InvoiceAccountsReceipt.Контрагент AS Контрагент,
//	|		InvoiceAccountsReceipt.Договор AS Договор,
//	|		InvoiceAccountsReceipt.ГруппаГостей AS ГруппаГостей,
//	|		InvoiceAccountsReceipt.СчетНаОплату AS СчетНаОплату,
//	|		SUM(InvoiceAccountsReceipt.Сумма) AS Сумма
//	|	FROM
//	|		AccumulationRegister.ВзаиморасчетыПоСчетам AS InvoiceAccountsReceipt
//	|	WHERE
//	|		InvoiceAccountsReceipt.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|		AND (NOT &qShowExpiredInvoicesOnly
//	|					AND InvoiceAccountsReceipt.Period >= &qPeriodFrom
//	|					AND InvoiceAccountsReceipt.Period <= &qPeriodTo
//	|				OR &qShowExpiredInvoicesOnly
//	|					AND InvoiceAccountsReceipt.СчетНаОплату.CheckDate <> &qEmptyDate
//	|					AND InvoiceAccountsReceipt.СчетНаОплату.CheckDate >= &qPeriodFrom
//	|					AND InvoiceAccountsReceipt.СчетНаОплату.CheckDate <= &qPeriodTo)
//	|		AND (InvoiceAccountsReceipt.Гостиница IN HIERARCHY (&qHotel)
//	|				OR &qIsEmptyHotel)
//	|		AND (InvoiceAccountsReceipt.Фирма IN HIERARCHY (&qCompany)
//	|				OR &qIsEmptyCompany)
//	|		AND (InvoiceAccountsReceipt.Контрагент IN HIERARCHY (&qCustomer)
//	|				OR &qIsEmptyCustomer)
//	|		AND (InvoiceAccountsReceipt.Договор IN HIERARCHY (&qContract)
//	|				OR &qIsEmptyContract)
//	|		AND (InvoiceAccountsReceipt.ГруппаГостей = &qGuestGroup
//	|				OR &qIsEmptyGuestGroup)
//	|		AND (InvoiceAccountsReceipt.ВалютаРасчетов = &qCurrency
//	|				OR &qIsEmptyCurrency)
//	|	
//	|	GROUP BY
//	|		InvoiceAccountsReceipt.Гостиница,
//	|		InvoiceAccountsReceipt.Фирма,
//	|		InvoiceAccountsReceipt.ВалютаРасчетов,
//	|		InvoiceAccountsReceipt.Контрагент,
//	|		InvoiceAccountsReceipt.Договор,
//	|		InvoiceAccountsReceipt.ГруппаГостей,
//	|		InvoiceAccountsReceipt.СчетНаОплату) AS Invoices
//	|		LEFT JOIN (SELECT
//	|			InvoiceAccountsBalance.СчетНаОплату AS СчетНаОплату,
//	|			InvoiceAccountsBalance.SumBalance AS InvoiceBalance
//	|		FROM
//	|			AccumulationRegister.ВзаиморасчетыПоСчетам.Balance(&qEmptyDate, ) AS InvoiceAccountsBalance) AS InvoiceBalances
//	|		ON Invoices.СчетНаОплату = InvoiceBalances.СчетНаОплату
//	|WHERE
//	|	(NOT &qShowExpiredInvoicesOnly
//	|			OR &qShowExpiredInvoicesOnly
//	|				AND InvoiceBalances.InvoiceBalance = Invoices.Сумма
//	|				AND Invoices.СчетНаОплату.CheckDate < &qBegOfCurrentDate)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	InvoiceAccountsExpense.Гостиница AS Гостиница,
//	|	InvoiceAccountsExpense.Фирма AS Фирма,
//	|	InvoiceAccountsExpense.ВалютаРасчетов AS Валюта,
//	|	InvoiceAccountsExpense.Контрагент AS Контрагент,
//	|	InvoiceAccountsExpense.Договор AS Договор,
//	|	InvoiceAccountsExpense.ГруппаГостей AS ГруппаГостей,
//	|	InvoiceAccountsExpense.СчетНаОплату AS СчетНаОплату,
//	|	InvoiceAccountsExpense.Recorder AS Платеж,
//	|	SUM(InvoiceAccountsExpense.Сумма) AS Сумма
//	|INTO InvoicePayments
//	|FROM
//	|	AccumulationRegister.ВзаиморасчетыПоСчетам AS InvoiceAccountsExpense
//	|WHERE
//	|	InvoiceAccountsExpense.RecordType = VALUE(AccumulationRecordType.Expense)
//	|	AND InvoiceAccountsExpense.СчетНаОплату IN
//	|			(SELECT
//	|				Invoices.СчетНаОплату
//	|			FROM
//	|				Invoices AS Invoices)
//	|
//	|GROUP BY
//	|	InvoiceAccountsExpense.Гостиница,
//	|	InvoiceAccountsExpense.Фирма,
//	|	InvoiceAccountsExpense.ВалютаРасчетов,
//	|	InvoiceAccountsExpense.Контрагент,
//	|	InvoiceAccountsExpense.Договор,
//	|	InvoiceAccountsExpense.ГруппаГостей,
//	|	InvoiceAccountsExpense.СчетНаОплату,
//	|	InvoiceAccountsExpense.Recorder
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	ВзаиморасчетыПоСчетам.Гостиница AS Гостиница,
//	|	ВзаиморасчетыПоСчетам.Фирма AS Фирма,
//	|	ВзаиморасчетыПоСчетам.Валюта AS Валюта,
//	|	ВзаиморасчетыПоСчетам.Контрагент AS Контрагент,
//	|	ВзаиморасчетыПоСчетам.Договор AS Договор,
//	|	ВзаиморасчетыПоСчетам.ГруппаГостей AS ГруппаГостей,
//	|	ВзаиморасчетыПоСчетам.СчетНаОплату AS СчетНаОплату,
//	|	ВзаиморасчетыПоСчетам.InvoiceAge AS InvoiceAge,
//	|	ВзаиморасчетыПоСчетам.DaysBeforeCheckIn AS DaysBeforeCheckIn,
//	|	ВзаиморасчетыПоСчетам.Платеж AS Платеж,
//	|	ВзаиморасчетыПоСчетам.PaymentDelay AS PaymentDelay,
//	|	ВзаиморасчетыПоСчетам.PaymentDaysBeforeCheckIn AS PaymentDaysBeforeCheckIn,
//	|	SUM(ВзаиморасчетыПоСчетам.SumReceipt) AS SumReceipt,
//	|	SUM(ВзаиморасчетыПоСчетам.SumExpense) AS SumExpense,
//	|	SUM(ВзаиморасчетыПоСчетам.SumBalance) AS SumBalance
//	|INTO ВзаиморасчетыПоСчетам
//	|FROM
//	|	(SELECT
//	|		Invoices.Гостиница AS Гостиница,
//	|		Invoices.Фирма AS Фирма,
//	|		Invoices.Валюта AS Валюта,
//	|		Invoices.Контрагент AS Контрагент,
//	|		Invoices.Договор AS Договор,
//	|		Invoices.ГруппаГостей AS ГруппаГостей,
//	|		Invoices.СчетНаОплату AS СчетНаОплату,
//	|		DATEDIFF(BEGINOFPERIOD(Invoices.СчетНаОплату.ДатаДок, DAY), &qBegOfCurrentDate, DAY) AS InvoiceAge,
//	|		DATEDIFF(&qBegOfCurrentDate, BEGINOFPERIOD(Invoices.ГруппаГостей.CheckInDate, DAY), DAY) AS DaysBeforeCheckIn,
//	|		NULL AS Платеж,
//	|		NULL AS PaymentDelay,
//	|		NULL AS PaymentDaysBeforeCheckIn,
//	|		Invoices.Сумма AS SumReceipt,
//	|		0 AS SumExpense,
//	|		Invoices.Сумма AS SumBalance
//	|	FROM
//	|		Invoices AS Invoices
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		InvoicePayments.Гостиница,
//	|		InvoicePayments.Фирма,
//	|		InvoicePayments.Валюта,
//	|		InvoicePayments.Контрагент,
//	|		InvoicePayments.Договор,
//	|		InvoicePayments.ГруппаГостей,
//	|		InvoicePayments.СчетНаОплату,
//	|		DATEDIFF(BEGINOFPERIOD(InvoicePayments.СчетНаОплату.ДатаДок, DAY), &qBegOfCurrentDate, DAY),
//	|		DATEDIFF(&qBegOfCurrentDate, BEGINOFPERIOD(InvoicePayments.ГруппаГостей.CheckInDate, DAY), DAY),
//	|		InvoicePayments.Платеж,
//	|		DATEDIFF(BEGINOFPERIOD(InvoicePayments.СчетНаОплату.ДатаДок, DAY), BEGINOFPERIOD(InvoicePayments.Платеж.ДатаДок, DAY), DAY),
//	|		DATEDIFF(BEGINOFPERIOD(InvoicePayments.Платеж.ДатаДок, DAY), BEGINOFPERIOD(InvoicePayments.ГруппаГостей.CheckInDate, DAY), DAY),
//	|		0,
//	|		InvoicePayments.Сумма,
//	|		-InvoicePayments.Сумма
//	|	FROM
//	|		InvoicePayments AS InvoicePayments) AS ВзаиморасчетыПоСчетам
//	|
//	|GROUP BY
//	|	ВзаиморасчетыПоСчетам.Гостиница,
//	|	ВзаиморасчетыПоСчетам.Фирма,
//	|	ВзаиморасчетыПоСчетам.Валюта,
//	|	ВзаиморасчетыПоСчетам.Контрагент,
//	|	ВзаиморасчетыПоСчетам.Договор,
//	|	ВзаиморасчетыПоСчетам.ГруппаГостей,
//	|	ВзаиморасчетыПоСчетам.СчетНаОплату,
//	|	ВзаиморасчетыПоСчетам.InvoiceAge,
//	|	ВзаиморасчетыПоСчетам.DaysBeforeCheckIn,
//	|	ВзаиморасчетыПоСчетам.Платеж,
//	|	ВзаиморасчетыПоСчетам.PaymentDelay,
//	|	ВзаиморасчетыПоСчетам.PaymentDaysBeforeCheckIn
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	ВзаиморасчетыПоСчетам.Валюта AS Валюта,
//	|	ВзаиморасчетыПоСчетам.Контрагент AS Контрагент,
//	|	ВзаиморасчетыПоСчетам.Договор AS Договор,
//	|	ВзаиморасчетыПоСчетам.ГруппаГостей AS ГруппаГостей,
//	|	ВзаиморасчетыПоСчетам.СчетНаОплату AS СчетНаОплату,
//	|	ВзаиморасчетыПоСчетам.InvoiceAge AS InvoiceAge,
//	|	ВзаиморасчетыПоСчетам.DaysBeforeCheckIn AS DaysBeforeCheckIn,
//	|	ВзаиморасчетыПоСчетам.Платеж AS Платеж,
//	|	ВзаиморасчетыПоСчетам.SumReceipt AS SumReceipt,
//	|	ВзаиморасчетыПоСчетам.SumExpense AS SumExpense,
//	|	ВзаиморасчетыПоСчетам.SumBalance AS SumBalance
//	|{SELECT
//	|	ВзаиморасчетыПоСчетам.Гостиница.*,
//	|	ВзаиморасчетыПоСчетам.Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	СчетНаОплату.*,
//	|	ВзаиморасчетыПоСчетам.СчетНаОплату.Примечания AS Примечания,
//	|	Платеж.*,
//	|	InvoiceAge,
//	|	DaysBeforeCheckIn,
//	|	ВзаиморасчетыПоСчетам.PaymentDelay,
//	|	ВзаиморасчетыПоСчетам.PaymentDaysBeforeCheckIn,
//	|	SumReceipt,
//	|	SumExpense,
//	|	SumBalance}
//	|FROM
//	|	ВзаиморасчетыПоСчетам AS ВзаиморасчетыПоСчетам
//	|{WHERE
//	|	ВзаиморасчетыПоСчетам.Гостиница.*,
//	|	ВзаиморасчетыПоСчетам.Фирма.*,
//	|	ВзаиморасчетыПоСчетам.Валюта.*,
//	|	ВзаиморасчетыПоСчетам.Контрагент.*,
//	|	ВзаиморасчетыПоСчетам.Договор.*,
//	|	ВзаиморасчетыПоСчетам.ГруппаГостей.*,
//	|	ВзаиморасчетыПоСчетам.InvoiceAge,
//	|	ВзаиморасчетыПоСчетам.PaymentDelay,
//	|	ВзаиморасчетыПоСчетам.DaysBeforeCheckIn,
//	|	ВзаиморасчетыПоСчетам.PaymentDaysBeforeCheckIn,
//	|	ВзаиморасчетыПоСчетам.СчетНаОплату.*,
//	|	ВзаиморасчетыПоСчетам.СчетНаОплату.Примечания AS Примечания,
//	|	ВзаиморасчетыПоСчетам.Платеж.*,
//	|	ВзаиморасчетыПоСчетам.SumReceipt AS SumReceipt,
//	|	ВзаиморасчетыПоСчетам.SumExpense AS SumExpense,
//	|	ВзаиморасчетыПоСчетам.SumBalance AS SumBalance}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Контрагент,
//	|	Договор,
//	|	ВзаиморасчетыПоСчетам.СчетНаОплату.ДатаДок,
//	|	ВзаиморасчетыПоСчетам.Платеж.ДатаДок
//	|{ORDER BY
//	|	ВзаиморасчетыПоСчетам.Гостиница.*,
//	|	ВзаиморасчетыПоСчетам.Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	InvoiceAge,
//	|	DaysBeforeCheckIn,
//	|	ВзаиморасчетыПоСчетам.PaymentDelay,
//	|	ВзаиморасчетыПоСчетам.PaymentDaysBeforeCheckIn,
//	|	СчетНаОплату.*,
//	|	Платеж.*,
//	|	SumReceipt,
//	|	SumExpense,
//	|	SumBalance}
//	|TOTALS
//	|	MAX(InvoiceAge),
//	|	MIN(DaysBeforeCheckIn),
//	|	SUM(SumReceipt),
//	|	SUM(SumExpense),
//	|	SUM(SumBalance)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Контрагент,
//	|	Договор,
//	|	СчетНаОплату
//	|{TOTALS BY
//	|	ВзаиморасчетыПоСчетам.Гостиница.*,
//	|	ВзаиморасчетыПоСчетам.Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	InvoiceAge,
//	|	DaysBeforeCheckIn,
//	|	СчетНаОплату.*,
//	|	Платеж.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Invoice accounts';RU='Взаиморасчеты по счетам-требованиям';de='Verrechnungen nach Rechnungen mit Zahlungsaufforderung'");
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
