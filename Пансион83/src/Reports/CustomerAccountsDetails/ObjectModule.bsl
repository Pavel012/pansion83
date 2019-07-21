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
//			If НЕ ShowCurrentAccountsReceivable And Гостиница.ShowCurrentAccountsReceivable Тогда
//				ShowCurrentAccountsReceivable = Гостиница.ShowCurrentAccountsReceivable;
//			EndIf;
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
//	If ЗначениеЗаполнено(GuestGroupCheckInPeriodFrom) Or ЗначениеЗаполнено(GuestGroupCheckInPeriodTo) Тогда
//		If НЕ ЗначениеЗаполнено(GuestGroupCheckInPeriodFrom) And ЗначениеЗаполнено(GuestGroupCheckInPeriodTo) Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем заезда в периоде по '; en = 'Choose groups with check-in date in period to '") + 
//			                     Format(GuestGroupCheckInPeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//			                     ";" + Chars.LF;
//		ElsIf ЗначениеЗаполнено(GuestGroupCheckInPeriodFrom) And НЕ ЗначениеЗаполнено(GuestGroupCheckInPeriodTo) Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем заезда в периоде с '; en = 'Choose groups with check-in date in period from '") + 
//			                     Format(GuestGroupCheckInPeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//			                     ";" + Chars.LF;
//		ElsIf GuestGroupCheckInPeriodFrom = GuestGroupCheckInPeriodTo Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем заезда равным '; en = 'Choose groups with check-in date equal '") + 
//			                     Format(GuestGroupCheckInPeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//			                     ";" + Chars.LF;
//		ElsIf GuestGroupCheckInPeriodFrom < GuestGroupCheckInPeriodTo Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем заезда в периоде '; en = 'Choose groups with check-in date in period '") + PeriodPresentation(GuestGroupCheckInPeriodFrom, GuestGroupCheckInPeriodTo, cmLocalizationCode()) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Guest group check-in period is wrong!';ru='Неправильно задан период отбора групп по дате и времени заезда!';de='Auswahlzeitraum der Gruppen nach Datum und Uhrzeit wurde falsch eingegeben!'") + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(GuestGroupCreateDatePeriodFrom) Or ЗначениеЗаполнено(GuestGroupCreateDatePeriodTo) Тогда
//		If НЕ ЗначениеЗаполнено(GuestGroupCreateDatePeriodFrom) And ЗначениеЗаполнено(GuestGroupCreateDatePeriodTo) Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем создания в периоде по '; en = 'Choose groups with create date in period to '") + 
//			                     Format(GuestGroupCreateDatePeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//			                     ";" + Chars.LF;
//		ElsIf ЗначениеЗаполнено(GuestGroupCreateDatePeriodFrom) And НЕ ЗначениеЗаполнено(GuestGroupCreateDatePeriodTo) Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем создания в периоде с '; en = 'Choose groups with create date in period from '") + 
//			                     Format(GuestGroupCreateDatePeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//			                     ";" + Chars.LF;
//		ElsIf GuestGroupCreateDatePeriodFrom = GuestGroupCreateDatePeriodTo Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем создания равным '; en = 'Choose groups with create date equal '") + 
//			                     Format(GuestGroupCreateDatePeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//			                     ";" + Chars.LF;
//		ElsIf GuestGroupCreateDatePeriodFrom < GuestGroupCreateDatePeriodTo Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор групп с датой и временем создания в периоде '; en = 'Choose groups with create date in period '") + PeriodPresentation(GuestGroupCreateDatePeriodFrom, GuestGroupCreateDatePeriodTo, cmLocalizationCode()) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Guest group create period is wrong!';ru='Неправильно задан период отбора групп по дате и времени создания!';de='Erstellungszeitraum der Gruppen nach Datum und Uhrzeit wurde falsch eingegeben!'") + 
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
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", ?(ЗначениеЗаполнено(PeriodFrom), PeriodFrom, '00010101010101'));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), PeriodTo, '39991231235958'));
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodFrom", GuestGroupCheckInPeriodFrom);
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodFromIsEmpty", НЕ ЗначениеЗаполнено(GuestGroupCheckInPeriodFrom));
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodTo", GuestGroupCheckInPeriodTo);
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodToIsEmpty", НЕ ЗначениеЗаполнено(GuestGroupCheckInPeriodTo));
//	ReportBuilder.Parameters.Вставить("qGuestGroupCreateDatePeriodFrom", GuestGroupCreateDatePeriodFrom);
//	ReportBuilder.Parameters.Вставить("qGuestGroupCreateDatePeriodFromIsEmpty", НЕ ЗначениеЗаполнено(GuestGroupCreateDatePeriodFrom));
//	ReportBuilder.Parameters.Вставить("qGuestGroupCreateDatePeriodTo", GuestGroupCreateDatePeriodTo);
//	ReportBuilder.Parameters.Вставить("qGuestGroupCreateDatePeriodToIsEmpty", НЕ ЗначениеЗаполнено(GuestGroupCreateDatePeriodTo));
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
//	ReportBuilder.Parameters.Вставить("qShowCurrentAccountsReceivable", ShowCurrentAccountsReceivable);
//	ReportBuilder.Parameters.Вставить("qShowAccountsReceivableForecast", ShowAccountsReceivableForecast);
//	ReportBuilder.Parameters.Вставить("qUndefined", Неопределено);
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomer", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsCustomer, Справочники.Контрагенты.EmptyRef()));
//	ReportBuilder.Parameters.Вставить("qIndividualsContract", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsContract, Справочники.Договора.EmptyRef()));
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Контрагент) And Контрагент = Гостиница.IndividualsCustomer Тогда
//		ReportBuilder.Parameters.Вставить("qIndividualsCustomerIsChoosen", True);
//	Else
//		ReportBuilder.Parameters.Вставить("qIndividualsCustomerIsChoosen", False);
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qInPriceServicesFolioType", TrimAll(InPriceServicesFolioType) + "%");
//	ReportBuilder.Parameters.Вставить("qShowInPriceAmountsOnly", ShowInPriceAmountsOnly);
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
//	|	ВзаиморасчетыКонтрагенты.Валюта AS Валюта,
//	|	ВзаиморасчетыКонтрагенты.Контрагент AS Контрагент,
//	|	ВзаиморасчетыКонтрагенты.Договор AS Договор,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей AS ГруппаГостей,
//	|	BEGINOFPERIOD(ВзаиморасчетыКонтрагенты.Recorder.ДатаДок, DAY) AS RecorderAccountingDate,
//	|	ВзаиморасчетыКонтрагенты.Recorder AS Recorder,
//	|	ВзаиморасчетыКонтрагенты.Recorder.Примечания AS RecorderRemarks,
//	|	ВзаиморасчетыКонтрагенты.СуммаКомиссии AS СуммаКомиссии,
//	|	ВзаиморасчетыКонтрагенты.SumReceipt AS SumReceipt,
//	|	ВзаиморасчетыКонтрагенты.SumExpense AS SumExpense,
//	|	ВзаиморасчетыКонтрагенты.Сумма AS Сумма,
//	|	ВзаиморасчетыКонтрагенты.СуммаНДС AS СуммаНДС
//	|{SELECT
//	|	ВзаиморасчетыКонтрагенты.Гостиница.*,
//	|	ВзаиморасчетыКонтрагенты.Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	RecorderAccountingDate,
//	|	Recorder.*,
//	|	RecorderRemarks,
//	|	СуммаКомиссии,
//	|	SumReceipt,
//	|	SumExpense,
//	|	Сумма,
//	|	VATSum}
//	|FROM
//	|	(SELECT
//	|		CustomerAccountsBalance.Гостиница AS Гостиница,
//	|		CustomerAccountsBalance.Фирма AS Фирма,
//	|		CustomerAccountsBalance.ВалютаРасчетов AS Валюта,
//	|		CustomerAccountsBalance.Контрагент AS Контрагент,
//	|		CustomerAccountsBalance.Договор AS Договор,
//	|		CustomerAccountsBalance.ГруппаГостей AS ГруппаГостей,
//	|		NULL AS Recorder,
//	|		0 AS СуммаКомиссии,
//	|		SUM(CustomerAccountsBalance.SumBalance) AS Сумма,
//	|		0 AS SumReceipt,
//	|		0 AS SumExpense,
//	|		0 AS СуммаНДС
//	|	FROM
//	|		AccumulationRegister.ВзаиморасчетыКонтрагенты.Balance(
//	|				&qPeriodFrom,
//	|				(Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|					AND (Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer)
//	|					AND (Договор IN HIERARCHY (&qContract)
//	|						OR &qIsEmptyContract)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|					AND (ВалютаРасчетов = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|					AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|							AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|					AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|							AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|					AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|							AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|					AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|							AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)) AS CustomerAccountsBalance
//	|	
//	|	GROUP BY
//	|		CustomerAccountsBalance.Гостиница,
//	|		CustomerAccountsBalance.Фирма,
//	|		CustomerAccountsBalance.ВалютаРасчетов,
//	|		CustomerAccountsBalance.Контрагент,
//	|		CustomerAccountsBalance.Договор,
//	|		CustomerAccountsBalance.ГруппаГостей
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		CustomerAccountsDetailed.Гостиница,
//	|		CustomerAccountsDetailed.Фирма,
//	|		CustomerAccountsDetailed.ВалютаРасчетов,
//	|		CustomerAccountsDetailed.Контрагент,
//	|		CustomerAccountsDetailed.Договор,
//	|		CustomerAccountsDetailed.ГруппаГостей,
//	|		CustomerAccountsDetailed.Recorder,
//	|		ISNULL(AccountsReceivableTurnovers.СуммаКомиссии, 0),
//	|		CustomerAccountsDetailed.Сумма,
//	|		CustomerAccountsDetailed.SumReceipt,
//	|		CustomerAccountsDetailed.SumExpense,
//	|		CustomerAccountsDetailed.СуммаНДС
//	|	FROM
//	|		(SELECT
//	|			CustomerAccountsRecords.Гостиница AS Гостиница,
//	|			CustomerAccountsRecords.Фирма AS Фирма,
//	|			CustomerAccountsRecords.ВалютаРасчетов AS ВалютаРасчетов,
//	|			CustomerAccountsRecords.Контрагент AS Контрагент,
//	|			CustomerAccountsRecords.Договор AS Договор,
//	|			CustomerAccountsRecords.ГруппаГостей AS ГруппаГостей,
//	|			CustomerAccountsRecords.Recorder AS Recorder,
//	|			SUM(CASE
//	|					WHEN CustomerAccountsRecords.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|						THEN CustomerAccountsRecords.Сумма
//	|					ELSE -CustomerAccountsRecords.Сумма
//	|				END) AS Сумма,
//	|			SUM(CASE
//	|					WHEN CustomerAccountsRecords.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|						THEN CustomerAccountsRecords.Сумма
//	|					ELSE 0
//	|				END) AS SumReceipt,
//	|			SUM(CASE
//	|					WHEN CustomerAccountsRecords.RecordType = VALUE(AccumulationRecordType.Expense)
//	|						THEN CustomerAccountsRecords.Сумма
//	|					ELSE 0
//	|				END) AS SumExpense,
//	|			SUM(CASE
//	|					WHEN CustomerAccountsRecords.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|						THEN CustomerAccountsRecords.СуммаНДС
//	|					ELSE 0
//	|				END) AS СуммаНДС
//	|		FROM
//	|			AccumulationRegister.ВзаиморасчетыКонтрагенты AS CustomerAccountsRecords
//	|		WHERE
//	|			CustomerAccountsRecords.Period >= &qPeriodFrom
//	|			AND CustomerAccountsRecords.Period <= &qPeriodTo
//	|			AND (CustomerAccountsRecords.Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|			AND (CustomerAccountsRecords.Фирма IN HIERARCHY (&qCompany)
//	|					OR &qIsEmptyCompany)
//	|			AND (CustomerAccountsRecords.Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|			AND (CustomerAccountsRecords.Договор IN HIERARCHY (&qContract)
//	|					OR &qIsEmptyContract)
//	|			AND (CustomerAccountsRecords.ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|			AND (CustomerAccountsRecords.ВалютаРасчетов = &qCurrency
//	|					OR &qIsEmptyCurrency)
//	|			AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|					OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|						AND CustomerAccountsRecords.ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|			AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|					OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|						AND CustomerAccountsRecords.ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|			AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|					OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|						AND CustomerAccountsRecords.ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|			AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|					OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|						AND CustomerAccountsRecords.ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)
//	|			AND (NOT &qShowInPriceAmountsOnly
//	|					OR &qShowInPriceAmountsOnly
//	|						AND CustomerAccountsRecords.СчетПроживания.Description LIKE &qInPriceServicesFolioType)
//	|		
//	|		GROUP BY
//	|			CustomerAccountsRecords.Гостиница,
//	|			CustomerAccountsRecords.Фирма,
//	|			CustomerAccountsRecords.ВалютаРасчетов,
//	|			CustomerAccountsRecords.Контрагент,
//	|			CustomerAccountsRecords.Договор,
//	|			CustomerAccountsRecords.ГруппаГостей,
//	|			CustomerAccountsRecords.Recorder) AS CustomerAccountsDetailed
//	|			LEFT JOIN (SELECT
//	|				БухРеализацияУслуг.Гостиница AS Гостиница,
//	|				БухРеализацияУслуг.Фирма AS Фирма,
//	|				БухРеализацияУслуг.ВалютаРасчетов AS ВалютаРасчетов,
//	|				БухРеализацияУслуг.Контрагент AS Контрагент,
//	|				БухРеализацияУслуг.Договор AS Договор,
//	|				БухРеализацияУслуг.ГруппаГостей AS ГруппаГостей,
//	|				БухРеализацияУслуг.Recorder AS Recorder,
//	|				SUM(БухРеализацияУслуг.СуммаКомиссии) AS СуммаКомиссии
//	|			FROM
//	|				AccumulationRegister.БухРеализацияУслуг AS БухРеализацияУслуг
//	|			WHERE
//	|				БухРеализацияУслуг.Period >= &qPeriodFrom
//	|				AND БухРеализацияУслуг.Period <= &qPeriodTo
//	|				AND (БухРеализацияУслуг.Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qIsEmptyHotel)
//	|				AND (БухРеализацияУслуг.Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|				AND (БухРеализацияУслуг.Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer)
//	|				AND (БухРеализацияУслуг.Договор IN HIERARCHY (&qContract)
//	|						OR &qIsEmptyContract)
//	|				AND (БухРеализацияУслуг.ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|				AND (БухРеализацияУслуг.ВалютаРасчетов = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|				AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|							AND БухРеализацияУслуг.ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|				AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|							AND БухРеализацияУслуг.ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|				AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|							AND БухРеализацияУслуг.ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|				AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|							AND БухРеализацияУслуг.ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)
//	|				AND (NOT &qShowInPriceAmountsOnly
//	|						OR &qShowInPriceAmountsOnly
//	|							AND БухРеализацияУслуг.Услуга.IsInPrice)
//	|			
//	|			GROUP BY
//	|				БухРеализацияУслуг.Гостиница,
//	|				БухРеализацияУслуг.Фирма,
//	|				БухРеализацияУслуг.ВалютаРасчетов,
//	|				БухРеализацияУслуг.Контрагент,
//	|				БухРеализацияУслуг.Договор,
//	|				БухРеализацияУслуг.ГруппаГостей,
//	|				БухРеализацияУслуг.Recorder) AS AccountsReceivableTurnovers
//	|			ON CustomerAccountsDetailed.Гостиница = AccountsReceivableTurnovers.Гостиница
//	|				AND CustomerAccountsDetailed.Фирма = AccountsReceivableTurnovers.Фирма
//	|				AND CustomerAccountsDetailed.ВалютаРасчетов = AccountsReceivableTurnovers.ВалютаРасчетов
//	|				AND CustomerAccountsDetailed.Контрагент = AccountsReceivableTurnovers.Контрагент
//	|				AND CustomerAccountsDetailed.Договор = AccountsReceivableTurnovers.Договор
//	|				AND CustomerAccountsDetailed.ГруппаГостей = AccountsReceivableTurnovers.ГруппаГостей
//	|				AND CustomerAccountsDetailed.Recorder = AccountsReceivableTurnovers.Recorder
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		CurrentAccountsReceivableBalance.Гостиница,
//	|		CurrentAccountsReceivableBalance.Фирма,
//	|		CurrentAccountsReceivableBalance.ВалютаЛицСчета,
//	|		CASE
//	|			WHEN CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsCustomer
//	|			ELSE CurrentAccountsReceivableBalance.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsContract
//	|			ELSE CurrentAccountsReceivableBalance.Договор
//	|		END,
//	|		NULL,
//	|		NULL,
//	|		0,
//	|		SUM(CurrentAccountsReceivableBalance.SumBalance - CurrentAccountsReceivableBalance.CommissionSumBalance),
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		AccumulationRegister.РелизацияТекОтчетПериод.Balance(
//	|				&qPeriodFrom,
//	|				&qShowCurrentAccountsReceivable
//	|					AND (Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qIsEmptyHotel)
//	|					AND (Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer
//	|						OR &qIndividualsCustomerIsChoosen
//	|							AND Контрагент = &qEmptyCustomer)
//	|					AND (Договор IN HIERARCHY (&qContract)
//	|						OR &qIsEmptyContract)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|					AND (ВалютаЛицСчета = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|					AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|							AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|					AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|							AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|					AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|							AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|					AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|							AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)
//	|					AND (NOT &qShowInPriceAmountsOnly
//	|						OR &qShowInPriceAmountsOnly
//	|							AND СчетПроживания.Description LIKE &qInPriceServicesFolioType)) AS CurrentAccountsReceivableBalance
//	|	
//	|	GROUP BY
//	|		CurrentAccountsReceivableBalance.Гостиница,
//	|		CurrentAccountsReceivableBalance.Фирма,
//	|		CurrentAccountsReceivableBalance.ВалютаЛицСчета,
//	|		CASE
//	|			WHEN CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsCustomer
//	|			ELSE CurrentAccountsReceivableBalance.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsContract
//	|			ELSE CurrentAccountsReceivableBalance.Договор
//	|		END
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		РелизацияТекОтчетПериод.Гостиница,
//	|		РелизацияТекОтчетПериод.Фирма,
//	|		РелизацияТекОтчетПериод.ВалютаЛицСчета,
//	|		CASE
//	|			WHEN РелизацияТекОтчетПериод.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsCustomer
//	|			ELSE РелизацияТекОтчетПериод.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN РелизацияТекОтчетПериод.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsContract
//	|			ELSE РелизацияТекОтчетПериод.Договор
//	|		END,
//	|		РелизацияТекОтчетПериод.ГруппаГостей,
//	|		CASE
//	|			WHEN РелизацияТекОтчетПериод.ДокОснование = &qUndefined
//	|				THEN РелизацияТекОтчетПериод.СчетПроживания
//	|			ELSE РелизацияТекОтчетПериод.ДокОснование
//	|		END,
//	|		SUM(РелизацияТекОтчетПериод.CommissionSumTurnover),
//	|		SUM(РелизацияТекОтчетПериод.SumTurnover - РелизацияТекОтчетПериод.CommissionSumTurnover),
//	|		SUM(РелизацияТекОтчетПериод.SumTurnover - РелизацияТекОтчетПериод.CommissionSumTurnover),
//	|		0,
//	|		0
//	|	FROM
//	|		AccumulationRegister.РелизацияТекОтчетПериод.BalanceAndTurnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Period,
//	|				RegisterRecordsAndPeriodBoundaries,
//	|				&qShowCurrentAccountsReceivable
//	|					AND (Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qIsEmptyHotel)
//	|					AND (Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer
//	|						OR &qIndividualsCustomerIsChoosen
//	|							AND Контрагент = &qEmptyCustomer)
//	|					AND (Договор IN HIERARCHY (&qContract)
//	|						OR &qIsEmptyContract)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|					AND (ВалютаЛицСчета = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|					AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|							AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|					AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|							AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|					AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|							AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|					AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|							AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)
//	|					AND (NOT &qShowInPriceAmountsOnly
//	|						OR &qShowInPriceAmountsOnly
//	|							AND СчетПроживания.Description LIKE &qInPriceServicesFolioType)) AS РелизацияТекОтчетПериод
//	|	
//	|	GROUP BY
//	|		РелизацияТекОтчетПериод.Гостиница,
//	|		РелизацияТекОтчетПериод.Фирма,
//	|		РелизацияТекОтчетПериод.ВалютаЛицСчета,
//	|		CASE
//	|			WHEN РелизацияТекОтчетПериод.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsCustomer
//	|			ELSE РелизацияТекОтчетПериод.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN РелизацияТекОтчетПериод.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsContract
//	|			ELSE РелизацияТекОтчетПериод.Договор
//	|		END,
//	|		РелизацияТекОтчетПериод.ГруппаГостей,
//	|		CASE
//	|			WHEN РелизацияТекОтчетПериод.ДокОснование = &qUndefined
//	|				THEN РелизацияТекОтчетПериод.СчетПроживания
//	|			ELSE РелизацияТекОтчетПериод.ДокОснование
//	|		END
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		ПрогнозРеализации.Гостиница,
//	|		ПрогнозРеализации.Фирма,
//	|		ПрогнозРеализации.ВалютаЛицСчета,
//	|		CASE
//	|			WHEN ПрогнозРеализации.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsCustomer
//	|			ELSE ПрогнозРеализации.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN ПрогнозРеализации.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsContract
//	|			ELSE ПрогнозРеализации.Договор
//	|		END,
//	|		ПрогнозРеализации.ГруппаГостей,
//	|		ПрогнозРеализации.ДокОснование,
//	|		SUM(ПрогнозРеализации.CommissionSumTurnover),
//	|		SUM(ПрогнозРеализации.SalesTurnover - ПрогнозРеализации.CommissionSumTurnover),
//	|		SUM(ПрогнозРеализации.SalesTurnover - ПрогнозРеализации.CommissionSumTurnover),
//	|		0,
//	|		0
//	|	FROM
//	|		AccumulationRegister.ПрогнозРеализации.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Period,
//	|				&qShowAccountsReceivableForecast
//	|					AND (Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qIsEmptyHotel)
//	|					AND (Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer
//	|						OR &qIndividualsCustomerIsChoosen
//	|							AND Контрагент = &qEmptyCustomer)
//	|					AND (Договор IN HIERARCHY (&qContract)
//	|						OR &qIsEmptyContract)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|					AND (ВалютаЛицСчета = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|					AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|							AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|					AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|							AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|					AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|							AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|					AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|						OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|							AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)
//	|					AND (NOT &qShowInPriceAmountsOnly
//	|						OR &qShowInPriceAmountsOnly
//	|							AND Услуга.IsInPrice)) AS ПрогнозРеализации
//	|	
//	|	GROUP BY
//	|		ПрогнозРеализации.Гостиница,
//	|		ПрогнозРеализации.Фирма,
//	|		ПрогнозРеализации.ВалютаЛицСчета,
//	|		CASE
//	|			WHEN ПрогнозРеализации.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsCustomer
//	|			ELSE ПрогнозРеализации.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN ПрогнозРеализации.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsContract
//	|			ELSE ПрогнозРеализации.Договор
//	|		END,
//	|		ПрогнозРеализации.ГруппаГостей,
//	|		ПрогнозРеализации.ДокОснование) AS ВзаиморасчетыКонтрагенты
//	|{WHERE
//	|	ВзаиморасчетыКонтрагенты.Гостиница.*,
//	|	ВзаиморасчетыКонтрагенты.Фирма.*,
//	|	ВзаиморасчетыКонтрагенты.Валюта.*,
//	|	ВзаиморасчетыКонтрагенты.Контрагент.*,
//	|	ВзаиморасчетыКонтрагенты.Договор.*,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.*,
//	|	(BEGINOFPERIOD(ВзаиморасчетыКонтрагенты.Recorder.ДатаДок, DAY)) AS RecorderAccountingDate,
//	|	ВзаиморасчетыКонтрагенты.Recorder.*}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	ВзаиморасчетыКонтрагенты.Recorder.PointInTime
//	|{ORDER BY
//	|	ВзаиморасчетыКонтрагенты.Гостиница.*,
//	|	ВзаиморасчетыКонтрагенты.Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Recorder.*}
//	|TOTALS
//	|	SUM(СуммаКомиссии),
//	|	SUM(SumReceipt),
//	|	SUM(SumExpense),
//	|	SUM(Сумма),
//	|	SUM(СуммаНДС)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей
//	|{TOTALS BY
//	|	ВзаиморасчетыКонтрагенты.Гостиница.*,
//	|	ВзаиморасчетыКонтрагенты.Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	RecorderAccountingDate,
//	|	Recorder.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Контрагент accounts details';RU='Детальный баланс взаиморасчетов с контрагентами';de='Detaillierte Bilanz der Verrechnung mit Vertragspartnern'");
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
