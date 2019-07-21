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
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPaymentPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), PeriodTo, '39991231235959'));
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
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomer", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsCustomer, Справочники.Контрагенты.EmptyRef()));
//	ReportBuilder.Parameters.Вставить("qIndividualsContract", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsContract, Справочники.Договора.EmptyRef()));
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Контрагент) And Контрагент = Гостиница.IndividualsCustomer Тогда
//		ReportBuilder.Parameters.Вставить("qIndividualsCustomerIsChoosen", True);
//	Else
//		ReportBuilder.Parameters.Вставить("qIndividualsCustomerIsChoosen", False);
//	EndIf;
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
//	|	ВзаиморасчетыКонтрагенты.Валюта AS Валюта,
//	|	ВзаиморасчетыКонтрагенты.Контрагент AS Контрагент,
//	|	ВзаиморасчетыКонтрагенты.Договор AS Договор,
//	|	ВзаиморасчетыКонтрагенты.Гостиница AS Гостиница,
//	|	ВзаиморасчетыКонтрагенты.Фирма AS Фирма,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей AS ГруппаГостей,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.Description AS GuestGroupDescription,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.Клиент AS GuestGroupClient,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.CheckInDate AS GuestGroupCheckInDate,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.Продолжительность AS GuestGroupDuration,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.CheckOutDate AS GuestGroupCheckOutDate,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.ЗаездГостей AS GuestGroupGuestsCheckedIn,
//	|	ВзаиморасчетыКонтрагенты.SumOpeningBalance AS SumOpeningBalance,
//	|	ВзаиморасчетыКонтрагенты.SumExpense AS SumExpense,
//	|	ВзаиморасчетыКонтрагенты.SumReceipt AS SumReceipt,
//	|	ВзаиморасчетыКонтрагенты.SumTurnover AS SumTurnover,
//	|	ВзаиморасчетыКонтрагенты.SumClosingBalance AS SumClosingBalance,
//	|	ВзаиморасчетыКонтрагенты.CommissionSumTurnover AS CommissionSumTurnover,
//	|	ISNULL(PreauthorizationLimits.PreauthorizationBalance, 0) AS PreauthorizationBalance,
//	|	ВзаиморасчетыКонтрагенты.SumClosingBalance - ISNULL(PreauthorizationLimits.PreauthorizationBalance, 0) AS BalanceWithPreauthorization,
//	|	1 AS СчетчикДокКвота
//	|{SELECT
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	ГруппаГостей.*,
//	|	GuestGroupDescription,
//	|	GuestGroupClient,
//	|	GuestGroupCheckInDate,
//	|	GuestGroupDuration,
//	|	GuestGroupCheckOutDate,
//	|	GuestGroupGuestsCheckedIn,
//	|	CustomerLastPayment.LastPaymentDate AS LastPaymentDate,
//	|	CommissionSumTurnover,
//	|	SumOpeningBalance,
//	|	SumReceipt,
//	|	SumExpense,
//	|	SumTurnover,
//	|	SumClosingBalance,
//	|	PreauthorizationBalance,
//	|	BalanceWithPreauthorization,
//	|	(1) AS Counter}
//	|FROM
//	|	(SELECT
//	|		FullCustomerAccounts.Валюта AS Валюта,
//	|		FullCustomerAccounts.Контрагент AS Контрагент,
//	|		FullCustomerAccounts.Договор AS Договор,
//	|		FullCustomerAccounts.Гостиница AS Гостиница,
//	|		FullCustomerAccounts.Фирма AS Фирма,
//	|		FullCustomerAccounts.ГруппаГостей AS ГруппаГостей,
//	|		SUM(FullCustomerAccounts.SumOpeningBalance) AS SumOpeningBalance,
//	|		SUM(FullCustomerAccounts.SumReceipt) AS SumReceipt,
//	|		SUM(FullCustomerAccounts.SumExpense) AS SumExpense,
//	|		SUM(FullCustomerAccounts.SumTurnover) AS SumTurnover,
//	|		SUM(FullCustomerAccounts.SumClosingBalance) AS SumClosingBalance,
//	|		SUM(FullCustomerAccounts.CommissionSumTurnover) AS CommissionSumTurnover
//	|	FROM
//	|		(SELECT
//	|			AccountingCustomerAccounts.ВалютаРасчетов AS Валюта,
//	|			AccountingCustomerAccounts.Контрагент AS Контрагент,
//	|			AccountingCustomerAccounts.Договор AS Договор,
//	|			AccountingCustomerAccounts.Гостиница AS Гостиница,
//	|			AccountingCustomerAccounts.Фирма AS Фирма,
//	|			AccountingCustomerAccounts.ГруппаГостей AS ГруппаГостей,
//	|			AccountingCustomerAccounts.SumOpeningBalance AS SumOpeningBalance,
//	|			AccountingCustomerAccounts.SumReceipt AS SumReceipt,
//	|			AccountingCustomerAccounts.SumExpense AS SumExpense,
//	|			AccountingCustomerAccounts.SumTurnover AS SumTurnover,
//	|			AccountingCustomerAccounts.SumClosingBalance AS SumClosingBalance,
//	|			ISNULL(БухРеализацияУслуг.CommissionSumTurnover, 0) AS CommissionSumTurnover
//	|		FROM
//	|			AccumulationRegister.ВзаиморасчетыКонтрагенты.BalanceAndTurnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Period,
//	|					RegisterRecordsAndPeriodBoundaries,
//	|					(Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qIsEmptyHotel)
//	|						AND (Фирма IN HIERARCHY (&qCompany)
//	|							OR &qIsEmptyCompany)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer)
//	|						AND (Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (ВалютаРасчетов = &qCurrency
//	|							OR &qIsEmptyCurrency)
//	|						AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|								AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|						AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|								AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|						AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|								AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|						AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|								AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)) AS AccountingCustomerAccounts
//	|				LEFT JOIN (SELECT
//	|					AccountsReceivableTurnovers.ВалютаРасчетов AS ВалютаРасчетов,
//	|					AccountsReceivableTurnovers.Контрагент AS Контрагент,
//	|					AccountsReceivableTurnovers.Договор AS Договор,
//	|					AccountsReceivableTurnovers.Гостиница AS Гостиница,
//	|					AccountsReceivableTurnovers.Фирма AS Фирма,
//	|					AccountsReceivableTurnovers.ГруппаГостей AS ГруппаГостей,
//	|					AccountsReceivableTurnovers.CommissionSumTurnover AS CommissionSumTurnover
//	|				FROM
//	|					AccumulationRegister.БухРеализацияУслуг.Turnovers(
//	|							&qPeriodFrom,
//	|							&qPeriodTo,
//	|							Period,
//	|							(Гостиница IN HIERARCHY (&qHotel)
//	|								OR &qIsEmptyHotel)
//	|								AND (Фирма IN HIERARCHY (&qCompany)
//	|									OR &qIsEmptyCompany)
//	|								AND (Контрагент IN HIERARCHY (&qCustomer)
//	|									OR &qIsEmptyCustomer)
//	|								AND (Договор = &qContract
//	|									OR &qIsEmptyContract)
//	|								AND (ГруппаГостей = &qGuestGroup
//	|									OR &qIsEmptyGuestGroup)
//	|								AND (ВалютаРасчетов = &qCurrency
//	|									OR &qIsEmptyCurrency)
//	|								AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|									OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|										AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|								AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|									OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|										AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|								AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|									OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|										AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|								AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|									OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|										AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)) AS AccountsReceivableTurnovers) AS БухРеализацияУслуг
//	|				ON (БухРеализацияУслуг.ВалютаРасчетов = AccountingCustomerAccounts.ВалютаРасчетов)
//	|					AND (БухРеализацияУслуг.Контрагент = AccountingCustomerAccounts.Контрагент)
//	|					AND (БухРеализацияУслуг.Договор = AccountingCustomerAccounts.Договор)
//	|					AND (БухРеализацияУслуг.Гостиница = AccountingCustomerAccounts.Гостиница)
//	|					AND (БухРеализацияУслуг.Фирма = AccountingCustomerAccounts.Фирма)
//	|					AND (БухРеализацияУслуг.ГруппаГостей = AccountingCustomerAccounts.ГруппаГостей)
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			РелизацияТекОтчетПериод.ВалютаЛицСчета,
//	|			CASE
//	|				WHEN РелизацияТекОтчетПериод.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsCustomer
//	|				ELSE РелизацияТекОтчетПериод.Контрагент
//	|			END,
//	|			CASE
//	|				WHEN РелизацияТекОтчетПериод.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsContract
//	|				ELSE РелизацияТекОтчетПериод.Договор
//	|			END,
//	|			РелизацияТекОтчетПериод.Гостиница,
//	|			РелизацияТекОтчетПериод.Фирма,
//	|			РелизацияТекОтчетПериод.ГруппаГостей,
//	|			РелизацияТекОтчетПериод.SumOpeningBalance - РелизацияТекОтчетПериод.CommissionSumOpeningBalance,
//	|			РелизацияТекОтчетПериод.SumTurnover - РелизацияТекОтчетПериод.CommissionSumTurnover,
//	|			0,
//	|			РелизацияТекОтчетПериод.SumTurnover - РелизацияТекОтчетПериод.CommissionSumTurnover,
//	|			РелизацияТекОтчетПериод.SumClosingBalance - РелизацияТекОтчетПериод.CommissionSumClosingBalance,
//	|			РелизацияТекОтчетПериод.CommissionSumTurnover
//	|		FROM
//	|			AccumulationRegister.РелизацияТекОтчетПериод.BalanceAndTurnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Period,
//	|					RegisterRecordsAndPeriodBoundaries,
//	|					&qShowCurrentAccountsReceivable
//	|						AND (Гостиница IN HIERARCHY (&qHotel)
//	|							OR &qIsEmptyHotel)
//	|						AND (Фирма IN HIERARCHY (&qCompany)
//	|							OR &qIsEmptyCompany)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer
//	|							OR &qIndividualsCustomerIsChoosen
//	|								AND Контрагент = &qEmptyCustomer)
//	|						AND (Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (ВалютаЛицСчета = &qCurrency
//	|							OR &qIsEmptyCurrency)
//	|						AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|								AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|						AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|								AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|						AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|								AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|						AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|								AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)) AS РелизацияТекОтчетПериод
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ПрогнозРеализации.ВалютаЛицСчета,
//	|			CASE
//	|				WHEN ПрогнозРеализации.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsCustomer
//	|				ELSE ПрогнозРеализации.Контрагент
//	|			END,
//	|			CASE
//	|				WHEN ПрогнозРеализации.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsContract
//	|				ELSE ПрогнозРеализации.Договор
//	|			END,
//	|			ПрогнозРеализации.Гостиница,
//	|			ПрогнозРеализации.Фирма,
//	|			ПрогнозРеализации.ГруппаГостей,
//	|			0,
//	|			ПрогнозРеализации.SalesTurnover - ПрогнозРеализации.CommissionSumTurnover,
//	|			0,
//	|			ПрогнозРеализации.SalesTurnover - ПрогнозРеализации.CommissionSumTurnover,
//	|			ПрогнозРеализации.SalesTurnover - ПрогнозРеализации.CommissionSumTurnover,
//	|			ПрогнозРеализации.CommissionSumTurnover
//	|		FROM
//	|			AccumulationRegister.ПрогнозРеализации.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Period,
//	|					&qShowAccountsReceivableForecast
//	|						AND (Гостиница IN HIERARCHY (&qHotel)
//	|							OR &qIsEmptyHotel)
//	|						AND (Фирма IN HIERARCHY (&qCompany)
//	|							OR &qIsEmptyCompany)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer
//	|							OR &qIndividualsCustomerIsChoosen
//	|								AND Контрагент = &qEmptyCustomer)
//	|						AND (Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (ВалютаЛицСчета = &qCurrency
//	|							OR &qIsEmptyCurrency)
//	|						AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|								AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|						AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|								AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|						AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|								AND ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|						AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|								AND ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)) AS ПрогнозРеализации) AS FullCustomerAccounts
//	|	
//	|	GROUP BY
//	|		FullCustomerAccounts.Валюта,
//	|		FullCustomerAccounts.Контрагент,
//	|		FullCustomerAccounts.Договор,
//	|		FullCustomerAccounts.Гостиница,
//	|		FullCustomerAccounts.Фирма,
//	|		FullCustomerAccounts.ГруппаГостей) AS ВзаиморасчетыКонтрагенты
//	|		LEFT JOIN (SELECT
//	|			AccountsBalance.ВалютаЛицСчета AS Валюта,
//	|			CASE
//	|				WHEN AccountsBalance.СчетПроживания.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsCustomer
//	|				ELSE AccountsBalance.СчетПроживания.Контрагент
//	|			END AS Контрагент,
//	|			CASE
//	|				WHEN AccountsBalance.СчетПроживания.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsContract
//	|				ELSE AccountsBalance.СчетПроживания.Договор
//	|			END AS Договор,
//	|			AccountsBalance.Гостиница AS Гостиница,
//	|			AccountsBalance.СчетПроживания.Фирма AS Фирма,
//	|			AccountsBalance.СчетПроживания.ГруппаГостей AS ГруппаГостей,
//	|			-SUM(AccountsBalance.LimitBalance) AS PreauthorizationBalance
//	|		FROM
//	|			AccumulationRegister.Взаиморасчеты.Balance(
//	|					&qPeriodTo,
//	|					(Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qIsEmptyHotel)
//	|						AND (СчетПроживания.Фирма IN HIERARCHY (&qCompany)
//	|							OR &qIsEmptyCompany)
//	|						AND (СчетПроживания.Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer)
//	|						AND (СчетПроживания.Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (СчетПроживания.ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (ВалютаЛицСчета = &qCurrency
//	|							OR &qIsEmptyCurrency)
//	|						AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|								AND СчетПроживания.ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|						AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|							OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|								AND СчетПроживания.ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|						AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|								AND СчетПроживания.ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|						AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|							OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|								AND СчетПроживания.ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)) AS AccountsBalance
//	|		
//	|		GROUP BY
//	|			AccountsBalance.ВалютаЛицСчета,
//	|			CASE
//	|				WHEN AccountsBalance.СчетПроживания.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsCustomer
//	|				ELSE AccountsBalance.СчетПроживания.Контрагент
//	|			END,
//	|			CASE
//	|				WHEN AccountsBalance.СчетПроживания.Контрагент = &qEmptyCustomer
//	|					THEN &qIndividualsContract
//	|				ELSE AccountsBalance.СчетПроживания.Договор
//	|			END,
//	|			AccountsBalance.Гостиница,
//	|			AccountsBalance.СчетПроживания.Фирма,
//	|			AccountsBalance.СчетПроживания.ГруппаГостей) AS PreauthorizationLimits
//	|		ON ВзаиморасчетыКонтрагенты.Валюта = PreauthorizationLimits.Валюта
//	|			AND ВзаиморасчетыКонтрагенты.Контрагент = PreauthorizationLimits.Контрагент
//	|			AND ВзаиморасчетыКонтрагенты.Договор = PreauthorizationLimits.Договор
//	|			AND ВзаиморасчетыКонтрагенты.Гостиница = PreauthorizationLimits.Гостиница
//	|			AND ВзаиморасчетыКонтрагенты.Фирма = PreauthorizationLimits.Фирма
//	|			AND ВзаиморасчетыКонтрагенты.ГруппаГостей = PreauthorizationLimits.ГруппаГостей
//	|		LEFT JOIN (SELECT
//	|			CustomerPayments.ВалютаРасчетов AS Валюта,
//	|			CustomerPayments.Контрагент AS Контрагент,
//	|			CustomerPayments.Договор AS Договор,
//	|			CustomerPayments.Гостиница AS Гостиница,
//	|			CustomerPayments.Фирма AS Фирма,
//	|			CustomerPayments.ГруппаГостей AS ГруппаГостей,
//	|			MAX(BEGINOFPERIOD(CustomerPayments.Period, DAY)) AS LastPaymentDate
//	|		FROM
//	|			AccumulationRegister.ВзаиморасчетыКонтрагенты AS CustomerPayments
//	|		WHERE
//	|			CustomerPayments.RecordType = VALUE(AccumulationRecordType.Expense)
//	|			AND CustomerPayments.Period < &qPaymentPeriodTo
//	|			AND (CustomerPayments.Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|			AND (CustomerPayments.Фирма IN HIERARCHY (&qCompany)
//	|					OR &qIsEmptyCompany)
//	|			AND (CustomerPayments.Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|			AND (CustomerPayments.Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|			AND (CustomerPayments.ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|			AND (CustomerPayments.ВалютаРасчетов = &qCurrency
//	|					OR &qIsEmptyCurrency)
//	|			AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|					OR NOT &qGuestGroupCheckInPeriodFromIsEmpty
//	|						AND CustomerPayments.ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|			AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|					OR NOT &qGuestGroupCheckInPeriodToIsEmpty
//	|						AND CustomerPayments.ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|			AND (&qGuestGroupCreateDatePeriodFromIsEmpty
//	|					OR NOT &qGuestGroupCreateDatePeriodFromIsEmpty
//	|						AND CustomerPayments.ГруппаГостей.CreateDate >= &qGuestGroupCreateDatePeriodFrom)
//	|			AND (&qGuestGroupCreateDatePeriodToIsEmpty
//	|					OR NOT &qGuestGroupCreateDatePeriodToIsEmpty
//	|						AND CustomerPayments.ГруппаГостей.CreateDate <= &qGuestGroupCreateDatePeriodTo)
//	|		
//	|		GROUP BY
//	|			CustomerPayments.ВалютаРасчетов,
//	|			CustomerPayments.Контрагент,
//	|			CustomerPayments.Договор,
//	|			CustomerPayments.Гостиница,
//	|			CustomerPayments.Фирма,
//	|			CustomerPayments.ГруппаГостей) AS CustomerLastPayment
//	|		ON ВзаиморасчетыКонтрагенты.Валюта = CustomerLastPayment.Валюта
//	|			AND ВзаиморасчетыКонтрагенты.Контрагент = CustomerLastPayment.Контрагент
//	|			AND ВзаиморасчетыКонтрагенты.Договор = CustomerLastPayment.Договор
//	|			AND ВзаиморасчетыКонтрагенты.Гостиница = CustomerLastPayment.Гостиница
//	|			AND ВзаиморасчетыКонтрагенты.Фирма = CustomerLastPayment.Фирма
//	|			AND ВзаиморасчетыКонтрагенты.ГруппаГостей = CustomerLastPayment.ГруппаГостей
//	|{WHERE
//	|	ВзаиморасчетыКонтрагенты.Гостиница.* AS Гостиница,
//	|	ВзаиморасчетыКонтрагенты.Фирма.* AS Фирма,
//	|	ВзаиморасчетыКонтрагенты.Валюта.* AS Валюта,
//	|	ВзаиморасчетыКонтрагенты.Контрагент.* AS Контрагент,
//	|	ВзаиморасчетыКонтрагенты.Договор.* AS Договор,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.*,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.Description AS GuestGroupDescription,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.Клиент AS GuestGroupClient,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.CheckInDate AS GuestGroupCheckInDate,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.Продолжительность AS GuestGroupDuration,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.CheckOutDate AS GuestGroupCheckOutDate,
//	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.ЗаездГостей AS GuestGroupGuestsCheckedIn,
//	|	CustomerLastPayment.LastPaymentDate AS LastPaymentDate,
//	|	ВзаиморасчетыКонтрагенты.SumOpeningBalance,
//	|	ВзаиморасчетыКонтрагенты.SumExpense,
//	|	ВзаиморасчетыКонтрагенты.SumReceipt,
//	|	ВзаиморасчетыКонтрагенты.SumTurnover,
//	|	ВзаиморасчетыКонтрагенты.SumClosingBalance,
//	|	ВзаиморасчетыКонтрагенты.CommissionSumTurnover,
//	|	(ISNULL(PreauthorizationLimits.PreauthorizationBalance, 0)) AS PreauthorizationBalance,
//	|	(ВзаиморасчетыКонтрагенты.SumClosingBalance - ISNULL(PreauthorizationLimits.PreauthorizationBalance, 0)) AS BalanceWithPreauthorization}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Контрагент,
//	|	Договор
//	|{ORDER BY
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	GuestGroupClient.*,
//	|	GuestGroupCheckInDate,
//	|	GuestGroupDuration,
//	|	GuestGroupCheckOutDate,
//	|	GuestGroupGuestsCheckedIn,
//	|	CustomerLastPayment.LastPaymentDate AS LastPaymentDate,
//	|	SumOpeningBalance,
//	|	SumExpense,
//	|	SumReceipt,
//	|	SumTurnover,
//	|	SumClosingBalance,
//	|	CommissionSumTurnover,
//	|	PreauthorizationBalance,
//	|	BalanceWithPreauthorization}
//	|TOTALS
//	|	SUM(SumOpeningBalance),
//	|	SUM(SumExpense),
//	|	SUM(SumReceipt),
//	|	SUM(SumTurnover),
//	|	SUM(SumClosingBalance),
//	|	SUM(CommissionSumTurnover),
//	|	SUM(PreauthorizationBalance),
//	|	SUM(BalanceWithPreauthorization),
//	|	SUM(СчетчикДокКвота)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Контрагент HIERARCHY,
//	|	Договор
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	CustomerLastPayment.LastPaymentDate AS LastPaymentDate}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Контрагент accounts';RU='Баланс взаиморасчетов с контрагентами';de='Bilanz der Verrechnung mit Vertragspartnern'");
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
//	If pName = "SumOpeningBalance" Or
//	   pName = "SumExpence" Or 
//	   pName = "SumReceipt" Or 
//	   pName = "SumTurnover" Or 
//	   pName = "SumClosingBalance" Or
//	   pName = "СчетчикДокКвота" Or
//	   pName = "CommissionSumTurnover" Or
//	   pName = "PreauthorizationBalance" Or
//	   pName = "BalanceWithPreauthorization" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
