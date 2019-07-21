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
//	ReportBuilder.Parameters.Вставить("qBegOfTime", '00010101');
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231235959');
//	ReportBuilder.Parameters.Вставить("qBegOfCurrentDate", BegOfDay(CurrentDate()));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qContractIsEmpty", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qReservation", Reservation);
//	ReportBuilder.Parameters.Вставить("qReservationIsEmpty", НЕ ЗначениеЗаполнено(Reservation));
//	ReportBuilder.Parameters.Вставить("qShowInvoicesAndDeposits", ShowInvoicesAndDeposits);
//	ReportBuilder.Parameters.Вставить("qEmptyString", "");
//	ReportBuilder.Parameters.Вставить("qSent", Перечисления.AttachmentStatuses.Sent);
//	ReportBuilder.Parameters.Вставить("qReady", Перечисления.AttachmentStatuses.Ready);
//	ReportBuilder.Parameters.Вставить("qEmptyEmployee", Справочники.Employees.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyAttachmentType", Перечисления.AttachmentTypes.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qVATRate", ?(ЗначениеЗаполнено(Гостиница), ?(ЗначениеЗаполнено(Гостиница.Фирма), ?(ЗначениеЗаполнено(Гостиница.Фирма.VATRate), Гостиница.Фирма.VATRate.Ставка, 0), 0), 0));
//	ReportBuilder.Parameters.Вставить("qShowGroupBalances", ShowGroupBalances);
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
//	|	PlannedCheckIn.ГруппаГостей AS ГруппаГостей,
//	|	MIN(PlannedCheckIn.CheckInDate) AS CheckInDate,
//	|	MAX(PlannedCheckIn.CheckOutDate) AS CheckOutDate
//	|INTO ПланируемыеГруппы
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров AS PlannedCheckIn
//	|WHERE
//	|	(&qShowGroupBalances
//	|			OR &qShowInvoicesAndDeposits)
//	|	AND PlannedCheckIn.RecordType = VALUE(AccumulationRecordType.Expense)
//	|	AND PlannedCheckIn.IsReservation = TRUE
//	|	AND (&qHotelIsEmpty
//	|			OR PlannedCheckIn.Гостиница IN HIERARCHY (&qHotel))
//	|	AND PlannedCheckIn.CheckInDate >= &qPeriodFrom
//	|	AND PlannedCheckIn.CheckInDate <= &qPeriodTo
//	|	AND (&qCustomerIsEmpty
//	|			OR PlannedCheckIn.Контрагент IN HIERARCHY (&qCustomer))
//	|	AND (&qContractIsEmpty
//	|			OR PlannedCheckIn.Договор = &qContract)
//	|	AND (&qGuestGroupIsEmpty
//	|			OR PlannedCheckIn.ГруппаГостей = &qGuestGroup)
//	|	AND (&qReservationIsEmpty
//	|			OR PlannedCheckIn.Recorder = &qReservation)
//	|
//	|GROUP BY
//	|	PlannedCheckIn.ГруппаГостей
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	PlannedCheckIn.Клиент AS Клиент
//	|INTO ExpectedGuests
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров AS PlannedCheckIn
//	|WHERE
//	|	PlannedCheckIn.RecordType = VALUE(AccumulationRecordType.Expense)
//	|	AND PlannedCheckIn.IsReservation = TRUE
//	|	AND (&qHotelIsEmpty
//	|			OR PlannedCheckIn.Гостиница IN HIERARCHY (&qHotel))
//	|	AND PlannedCheckIn.CheckInDate >= &qPeriodFrom
//	|	AND PlannedCheckIn.CheckInDate <= &qPeriodTo
//	|	AND (&qCustomerIsEmpty
//	|			OR PlannedCheckIn.Контрагент IN HIERARCHY (&qCustomer))
//	|	AND (&qContractIsEmpty
//	|			OR PlannedCheckIn.Договор = &qContract)
//	|	AND (&qGuestGroupIsEmpty
//	|			OR PlannedCheckIn.ГруппаГостей = &qGuestGroup)
//	|	AND (&qReservationIsEmpty
//	|			OR PlannedCheckIn.Recorder = &qReservation)
//	|
//	|GROUP BY
//	|	PlannedCheckIn.Клиент
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	AccountsBalance.СчетПроживания AS СчетПроживания,
//	|	AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	AccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|	SUM(AccountsBalance.SumBalance + AccountsBalance.LimitBalance) AS FolioBalance
//	|INTO FolioBalances
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты.Balance(
//	|			&qEndOfTime,
//	|			&qShowInvoicesAndDeposits
//	|				AND (&qHotelIsEmpty
//	|					OR СчетПроживания.Гостиница IN HIERARCHY (&qHotel))
//	|				AND (&qCustomerIsEmpty
//	|					OR СчетПроживания.Контрагент IN HIERARCHY (&qCustomer))
//	|				AND (&qContractIsEmpty
//	|					OR СчетПроживания.Договор = &qContract)
//	|				AND (&qGuestGroupIsEmpty
//	|					OR СчетПроживания.ГруппаГостей = &qGuestGroup)
//	|				AND СчетПроживания.ГруппаГостей IN
//	|					(SELECT
//	|						ПланируемыеГруппы.ГруппаГостей
//	|					FROM
//	|						ПланируемыеГруппы AS ПланируемыеГруппы)
//	|				AND (&qReservationIsEmpty
//	|					OR СчетПроживания.ДокОснование = &qReservation)) AS AccountsBalance
//	|
//	|GROUP BY
//	|	AccountsBalance.СчетПроживания,
//	|	AccountsBalance.ВалютаЛицСчета,
//	|	AccountsBalance.СчетПроживания.ДокОснование
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	GuestGroupSales.ГруппаГостей AS ГруппаГостей,
//	|	GuestGroupSales.Валюта AS Валюта,
//	|	SUM(GuestGroupSales.SalesTurnover) AS SalesTurnover,
//	|	SUM(GuestGroupSales.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover
//	|INTO GuestGroupSales
//	|FROM
//	|	(SELECT
//	|		SalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|		SalesTurnovers.Валюта AS Валюта,
//	|		SalesTurnovers.SalesTurnover AS SalesTurnover,
//	|		SalesTurnovers.SalesWithoutVATTurnover AS SalesWithoutVATTurnover
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				,
//	|				,
//	|				Period,
//	|				&qShowGroupBalances
//	|					AND ГруппаГостей IN
//	|						(SELECT
//	|							ПланируемыеГруппы.ГруппаГостей
//	|						FROM
//	|							ПланируемыеГруппы AS ПланируемыеГруппы)) AS SalesTurnovers
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		SalesForecastTurnovers.ГруппаГостей,
//	|		SalesForecastTurnovers.Валюта,
//	|		SalesForecastTurnovers.SalesTurnover,
//	|		SalesForecastTurnovers.SalesWithoutVATTurnover
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|				,
//	|				,
//	|				Period,
//	|				&qShowGroupBalances
//	|					AND ГруппаГостей IN
//	|						(SELECT
//	|							ПланируемыеГруппы.ГруппаГостей
//	|						FROM
//	|							ПланируемыеГруппы AS ПланируемыеГруппы)) AS SalesForecastTurnovers) AS GuestGroupSales
//	|
//	|GROUP BY
//	|	GuestGroupSales.ГруппаГостей,
//	|	GuestGroupSales.Валюта
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	GuestGroupPayments.ГруппаГостей AS ГруппаГостей,
//	|	GuestGroupPayments.ВалютаРасчетов AS ВалютаРасчетов,
//	|	SUM(ISNULL(GuestGroupPayments.SumExpense, 0)) AS PaymentsTurnover,
//	|	SUM(ISNULL(GuestGroupPayments.SumExpense - GuestGroupPayments.SumExpense * &qVATRate / (100 + &qVATRate), 0)) AS PaymentsWithoutVATTurnover
//	|INTO GuestGroupPayments
//	|FROM
//	|	AccumulationRegister.ВзаиморасчетыКонтрагенты.BalanceAndTurnovers(
//	|			,
//	|			,
//	|			Period,
//	|			RegisterRecords,
//	|			&qShowGroupBalances
//	|				AND ГруппаГостей IN
//	|					(SELECT
//	|						ПланируемыеГруппы.ГруппаГостей
//	|					FROM
//	|						ПланируемыеГруппы AS ПланируемыеГруппы)) AS GuestGroupPayments
//	|
//	|GROUP BY
//	|	GuestGroupPayments.ГруппаГостей,
//	|	GuestGroupPayments.ВалютаРасчетов
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	GuestGroupBalances.ГруппаГостей AS ГруппаГостей,
//	|	GuestGroupBalances.Валюта AS Валюта,
//	|	SUM(GuestGroupBalances.SalesTurnover) AS Продажи,
//	|	SUM(GuestGroupBalances.SalesWithoutVATTurnover) AS ПродажиБезНДС,
//	|	SUM(GuestGroupBalances.PaymentsTurnover) AS Платежи,
//	|	SUM(GuestGroupBalances.PaymentsWithoutVATTurnover) AS PaymentsWithoutVAT,
//	|	SUM(GuestGroupBalances.GroupBalance) AS GroupBalance,
//	|	SUM(GuestGroupBalances.GroupBalanceWithoutVAT) AS GroupBalanceWithoutVAT
//	|INTO GuestGroupBalances
//	|FROM
//	|	(SELECT
//	|		GuestGroupSales.ГруппаГостей AS ГруппаГостей,
//	|		GuestGroupSales.Валюта AS Валюта,
//	|		GuestGroupSales.SalesTurnover AS SalesTurnover,
//	|		GuestGroupSales.SalesWithoutVATTurnover AS SalesWithoutVATTurnover,
//	|		0 AS PaymentsTurnover,
//	|		0 AS PaymentsWithoutVATTurnover,
//	|		GuestGroupSales.SalesTurnover AS GroupBalance,
//	|		GuestGroupSales.SalesWithoutVATTurnover AS GroupBalanceWithoutVAT
//	|	FROM
//	|		GuestGroupSales AS GuestGroupSales
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		GuestGroupPayments.ГруппаГостей,
//	|		GuestGroupPayments.ВалютаРасчетов,
//	|		0,
//	|		0,
//	|		GuestGroupPayments.PaymentsTurnover,
//	|		GuestGroupPayments.PaymentsWithoutVATTurnover,
//	|		-GuestGroupPayments.PaymentsTurnover,
//	|		-GuestGroupPayments.PaymentsWithoutVATTurnover
//	|	FROM
//	|		GuestGroupPayments AS GuestGroupPayments) AS GuestGroupBalances
//	|
//	|GROUP BY
//	|	GuestGroupBalances.ГруппаГостей,
//	|	GuestGroupBalances.Валюта
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
//	|	ЗагрузкаНомеров.ГруппаГостей AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Контрагент,
//	|	ЗагрузкаНомеров.ReservationStatus,
//	|	ЗагрузкаНомеров.Клиент AS Клиент,
//	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера,
//	|	ЗагрузкаНомеров.ВидРазмещения,
//	|	ЗагрузкаНомеров.Тариф,
//	|	ЗагрузкаНомеров.PlannedPaymentMethod,
//	|	ЗагрузкаНомеров.Примечания,
//	|	ЗагрузкаНомеров.Recorder AS Recorder,
//	|	ЗагрузкаНомеров.ЗабронГостей AS ЗабронГостей,
//	|	ЗагрузкаНомеров.ЗабронНомеров AS ЗабронНомеров,
//	|	ЗагрузкаНомеров.ЗабронированоМест AS ЗабронированоМест,
//	|	ЗагрузкаНомеров.ЗабронДопМест AS ЗабронДопМест,
//	|	ЗагрузкаНомеров.PricePresentation,
//	|	ЗагрузкаНомеров.GuestGroupSales AS GuestGroupSales,
//	|	ЗагрузкаНомеров.GuestGroupSalesWithoutVAT AS GuestGroupSalesWithoutVAT,
//	|	ЗагрузкаНомеров.GuestGroupPayments AS GuestGroupPayments,
//	|	ЗагрузкаНомеров.GuestGroupPaymentsWithoutVAT AS GuestGroupPaymentsWithoutVAT,
//	|	ЗагрузкаНомеров.GuestGroupBalances AS GuestGroupBalances,
//	|	ЗагрузкаНомеров.GuestGroupBalancesWithoutVAT AS GuestGroupBalancesWithoutVAT,
//	|	ClientTotals.NumberOfCheckins AS NumberOfCheckins
//	|{SELECT
//	|	Гостиница.*,
//	|	ГруппаГостей.*,
//	|	ЗагрузкаНомеров.ТипКонтрагента.*,
//	|	Контрагент.*,
//	|	ЗагрузкаНомеров.Договор.*,
//	|	ЗагрузкаНомеров.КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Агент.*,
//	|	ReservationStatus.*,
//	|	ЗагрузкаНомеров.ТипКлиента.*,
//	|	(CASE
//	|			WHEN NOT ЗагрузкаНомеров.Контрагент.ClientTypeRemarks IS NULL 
//	|					AND ЗагрузкаНомеров.Контрагент.ClientTypeRemarks <> &qEmptyString
//	|				THEN ЗагрузкаНомеров.Контрагент.ClientTypeRemarks
//	|			ELSE ЗагрузкаНомеров.ТипКлиента.Примечания
//	|		END) AS ClientTypeRemarks,
//	|	Клиент.*,
//	|	ЗагрузкаНомеров.Клиент.Примечания AS GuestRemarks,
//	|	CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность,
//	|	CheckOutDate,
//	|	ЗагрузкаНомеров.СрокБрони,
//	|	ЗагрузкаНомеров.CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.CheckInDate)) AS CheckInYear,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateHour,
//	|	(BEGINOFPERIOD(ЗагрузкаНомеров.Recorder.ДатаДок, DAY)) AS CreateDate,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateYear,
//	|	ЗагрузкаНомеров.НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	ВидРазмещения.*,
//	|	ЗагрузкаНомеров.RoomRateType.*,
//	|	Тариф.*,
//	|	PricePresentation,
//	|	PlannedPaymentMethod.*,
//	|	ЗабронНомеров,
//	|	ЗабронированоМест,
//	|	ЗабронДопМест,
//	|	ЗабронГостей,
//	|	Примечания,
//	|	ЗагрузкаНомеров.HousekeepingRemarks,
//	|	ЗагрузкаНомеров.Car,
//	|	ЗагрузкаНомеров.IsMaster,
//	|	ЗагрузкаНомеров.ПутевкаКурсовка.*,
//	|	ЗагрузкаНомеров.КвотаНомеров.*,
//	|	ЗагрузкаНомеров.МаретингНапрвл.*,
//	|	ЗагрузкаНомеров.TripPurpose.*,
//	|	ЗагрузкаНомеров.ИсточИнфоГостиница.*,
//	|	ЗагрузкаНомеров.ДисконтКарт.*,
//	|	ЗагрузкаНомеров.ТипСкидки.*,
//	|	ЗагрузкаНомеров.Скидка,
//	|	ЗагрузкаНомеров.КомиссияАгента,
//	|	ЗагрузкаНомеров.ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.RoomQuantity,
//	|	ЗагрузкаНомеров.КоличествоМестНомер,
//	|	ЗагрузкаНомеров.КоличествоГостейНомер,
//	|	ЗагрузкаНомеров.Фирма.*,
//	|	ЗагрузкаНомеров.ДокОснование.*,
//	|	ЗагрузкаНомеров.Автор.*,
//	|	Recorder.*,
//	|	ЗагрузкаНомеров.Recorder.ExternalCode AS ExternalCode,
//	|	ЗагрузкаНомеров.PointInTime,
//	|	ЗагрузкаНомеров.Account.*,
//	|	ЗагрузкаНомеров.ВалютаСчета.*,
//	|	(NULL) AS EmptyColumn,
//	|	ЗагрузкаНомеров.InvoiceAge,
//	|	ЗагрузкаНомеров.DaysBeforeCheckIn,
//	|	ЗагрузкаНомеров.SumInvoice,
//	|	ЗагрузкаНомеров.SumPayed,
//	|	ЗагрузкаНомеров.AccountBalance,
//	|	GuestGroupSales,
//	|	GuestGroupSalesWithoutVAT,
//	|	GuestGroupPayments,
//	|	GuestGroupPaymentsWithoutVAT,
//	|	GuestGroupBalances,
//	|	GuestGroupBalancesWithoutVAT,
//	|	NumberOfCheckins,
//	|	(CASE
//	|			WHEN GuestGroupLastAttachments.AttachmentType IS NULL 
//	|				THEN &qEmptyAttachmentType
//	|			ELSE GuestGroupLastAttachments.AttachmentType
//	|		END) AS AttachmentType,
//	|	(CASE
//	|			WHEN (CAST(GuestGroupLastAttachments.DocumentText AS STRING(100))) <> &qEmptyString
//	|				THEN GuestGroupLastAttachments.DocumentText
//	|			WHEN (CAST(GuestGroupLastAttachments.Примечания AS STRING(100))) <> &qEmptyString
//	|				THEN GuestGroupLastAttachments.Примечания
//	|			WHEN (CAST(GuestGroupLastAttachments.FileName AS STRING(100))) <> &qEmptyString
//	|				THEN GuestGroupLastAttachments.FileName
//	|			ELSE &qEmptyString
//	|		END) AS AttachmentText,
//	|	(CASE
//	|			WHEN GuestGroupLastAttachments.Автор IS NULL 
//	|				THEN &qEmptyEmployee
//	|			ELSE GuestGroupLastAttachments.Автор
//	|		END) AS AttachmentAuthor}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryMovements.Recorder.Гостиница AS Гостиница,
//	|		RoomInventoryMovements.Recorder.ГруппаГостей AS ГруппаГостей,
//	|		RoomInventoryMovements.Recorder.ТипКонтрагента AS ТипКонтрагента,
//	|		RoomInventoryMovements.Recorder.Контрагент AS Контрагент,
//	|		RoomInventoryMovements.Recorder.Договор AS Договор,
//	|		RoomInventoryMovements.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|		RoomInventoryMovements.Recorder.Агент AS Агент,
//	|		RoomInventoryMovements.Recorder.ReservationStatus AS ReservationStatus,
//	|		RoomInventoryMovements.Recorder.ТипКлиента AS ТипКлиента,
//	|		RoomInventoryMovements.Recorder.Клиент AS Клиент,
//	|		RoomInventoryMovements.Recorder.CheckInDate AS CheckInDate,
//	|		RoomInventoryMovements.Recorder.Продолжительность AS Продолжительность,
//	|		RoomInventoryMovements.Recorder.CheckOutDate AS CheckOutDate,
//	|		RoomInventoryMovements.Recorder.СрокБрони AS СрокБрони,
//	|		RoomInventoryMovements.CheckInAccountingDate AS CheckInAccountingDate,
//	|		RoomInventoryMovements.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|		RoomInventoryMovements.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryMovements.ТипНомера AS ТипНомера,
//	|		RoomInventoryMovements.ВидРазмещения AS ВидРазмещения,
//	|		RoomInventoryMovements.RoomRateType AS RoomRateType,
//	|		RoomInventoryMovements.Тариф AS Тариф,
//	|		RoomInventoryMovements.Recorder.PricePresentation AS PricePresentation,
//	|		RoomInventoryMovements.Recorder.PlannedPaymentMethod AS PlannedPaymentMethod,
//	|		RoomInventoryMovements.ЗабронНомеров AS ЗабронНомеров,
//	|		RoomInventoryMovements.ЗабронированоМест AS ЗабронированоМест,
//	|		RoomInventoryMovements.ЗабронДопМест AS ЗабронДопМест,
//	|		RoomInventoryMovements.ЗабронГостей AS ЗабронГостей,
//	|		RoomInventoryMovements.Recorder.Примечания AS Примечания,
//	|		RoomInventoryMovements.Recorder.HousekeepingRemarks AS HousekeepingRemarks,
//	|		RoomInventoryMovements.Recorder.Car AS Car,
//	|		RoomInventoryMovements.Recorder.IsMaster AS IsMaster,
//	|		RoomInventoryMovements.Recorder.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|		RoomInventoryMovements.Recorder.КвотаНомеров AS КвотаНомеров,
//	|		RoomInventoryMovements.Recorder.МаретингНапрвл AS МаретингНапрвл,
//	|		RoomInventoryMovements.Recorder.TripPurpose AS TripPurpose,
//	|		RoomInventoryMovements.Recorder.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		RoomInventoryMovements.Recorder.ДисконтКарт AS ДисконтКарт,
//	|		RoomInventoryMovements.Recorder.ТипСкидки AS ТипСкидки,
//	|		RoomInventoryMovements.Recorder.Скидка AS Скидка,
//	|		RoomInventoryMovements.Recorder.КомиссияАгента AS КомиссияАгента,
//	|		RoomInventoryMovements.Recorder.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|		RoomInventoryMovements.Recorder.RoomQuantity AS RoomQuantity,
//	|		RoomInventoryMovements.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
//	|		RoomInventoryMovements.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|		RoomInventoryMovements.Recorder.Фирма AS Фирма,
//	|		RoomInventoryMovements.Recorder.ДокОснование AS ДокОснование,
//	|		RoomInventoryMovements.Recorder.Автор AS Автор,
//	|		RoomInventoryMovements.Recorder AS Recorder,
//	|		RoomInventoryMovements.Recorder.PointInTime AS PointInTime,
//	|		ReservationFolioBalances.СчетПроживания AS Account,
//	|		ReservationFolioBalances.ВалютаЛицСчета AS ВалютаСчета,
//	|		DATEDIFF(&qBegOfCurrentDate, BEGINOFPERIOD(RoomInventoryMovements.Recorder.CheckInDate, DAY), DAY) AS DaysBeforeCheckIn,
//	|		0 AS InvoiceAge,
//	|		0 AS SumInvoice,
//	|		ISNULL(ReservationFolioBalances.FolioBalance, 0) AS AccountBalance,
//	|		0 AS SumPayed,
//	|		GuestGroupBalances.Продажи AS GuestGroupSales,
//	|		GuestGroupBalances.ПродажиБезНДС AS GuestGroupSalesWithoutVAT,
//	|		GuestGroupBalances.Платежи AS GuestGroupPayments,
//	|		GuestGroupBalances.PaymentsWithoutVAT AS GuestGroupPaymentsWithoutVAT,
//	|		GuestGroupBalances.Balances AS GuestGroupBalances,
//	|		GuestGroupBalances.BalancesWithoutVAT AS GuestGroupBalancesWithoutVAT
//	|	FROM
//	|		(SELECT
//	|			RoomInventoryDetailedMovements.Recorder AS Recorder,
//	|			RoomInventoryDetailedMovements.НомерРазмещения AS НомерРазмещения,
//	|			RoomInventoryDetailedMovements.ТипНомера AS ТипНомера,
//	|			RoomInventoryDetailedMovements.ВидРазмещения AS ВидРазмещения,
//	|			RoomInventoryDetailedMovements.RoomRateType AS RoomRateType,
//	|			RoomInventoryDetailedMovements.Тариф AS Тариф,
//	|			RoomInventoryDetailedMovements.CheckInAccountingDate AS CheckInAccountingDate,
//	|			RoomInventoryDetailedMovements.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|			MAX(RoomInventoryDetailedMovements.ExpectedRoomsCheckedIn) AS ЗабронНомеров,
//	|			MAX(RoomInventoryDetailedMovements.ПланЗаездМест) AS ЗабронированоМест,
//	|			MAX(RoomInventoryDetailedMovements.ПланЗаездДопМест) AS ЗабронДопМест,
//	|			MAX(RoomInventoryDetailedMovements.ExpectedGuestsCheckedIn) AS ЗабронГостей
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryDetailedMovements
//	|		WHERE
//	|			RoomInventoryDetailedMovements.RecordType = VALUE(AccumulationRecordType.Expense)
//	|			AND RoomInventoryDetailedMovements.IsReservation
//	|			AND (&qHotelIsEmpty
//	|					OR RoomInventoryDetailedMovements.Гостиница IN HIERARCHY (&qHotel))
//	|			AND RoomInventoryDetailedMovements.CheckInDate >= &qPeriodFrom
//	|			AND RoomInventoryDetailedMovements.CheckInDate < &qPeriodTo
//	|			AND (&qCustomerIsEmpty
//	|					OR RoomInventoryDetailedMovements.Контрагент IN HIERARCHY (&qCustomer))
//	|			AND (&qContractIsEmpty
//	|					OR RoomInventoryDetailedMovements.Договор = &qContract)
//	|			AND (&qGuestGroupIsEmpty
//	|					OR RoomInventoryDetailedMovements.ГруппаГостей = &qGuestGroup)
//	|			AND (&qReservationIsEmpty
//	|					OR RoomInventoryDetailedMovements.Recorder = &qReservation)
//	|		
//	|		GROUP BY
//	|			RoomInventoryDetailedMovements.Recorder,
//	|			RoomInventoryDetailedMovements.CheckInAccountingDate,
//	|			RoomInventoryDetailedMovements.CheckOutAccountingDate,
//	|			RoomInventoryDetailedMovements.НомерРазмещения,
//	|			RoomInventoryDetailedMovements.ТипНомера,
//	|			RoomInventoryDetailedMovements.ВидРазмещения,
//	|			RoomInventoryDetailedMovements.RoomRateType,
//	|			RoomInventoryDetailedMovements.Тариф) AS RoomInventoryMovements
//	|			LEFT JOIN (SELECT
//	|				FolioBalances.СчетПроживания AS СчетПроживания,
//	|				FolioBalances.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|				FolioBalances.FolioParentDoc AS FolioParentDoc,
//	|				FolioBalances.FolioBalance AS FolioBalance
//	|			FROM
//	|				FolioBalances AS FolioBalances) AS ReservationFolioBalances
//	|			ON RoomInventoryMovements.Recorder = ReservationFolioBalances.FolioParentDoc
//	|			LEFT JOIN (SELECT
//	|				GuestGroupBalances.ГруппаГостей AS ГруппаГостей,
//	|				GuestGroupBalances.Валюта AS Валюта,
//	|				GuestGroupBalances.Продажи AS Продажи,
//	|				GuestGroupBalances.ПродажиБезНДС AS ПродажиБезНДС,
//	|				GuestGroupBalances.Платежи AS Платежи,
//	|				GuestGroupBalances.PaymentsWithoutVAT AS PaymentsWithoutVAT,
//	|				GuestGroupBalances.GroupBalance AS Balances,
//	|				GuestGroupBalances.GroupBalanceWithoutVAT AS BalancesWithoutVAT
//	|			FROM
//	|				GuestGroupBalances AS GuestGroupBalances) AS GuestGroupBalances
//	|			ON RoomInventoryMovements.Recorder.ГруппаГостей = GuestGroupBalances.ГруппаГостей
//	|				AND RoomInventoryMovements.Recorder.Валюта = GuestGroupBalances.Валюта
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		InvoiceAccountsTurnovers.Гостиница,
//	|		InvoiceAccountsTurnovers.ГруппаГостей,
//	|		NULL,
//	|		InvoiceAccountsTurnovers.Контрагент,
//	|		InvoiceAccountsTurnovers.Договор,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.КонтактноеЛицо,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		GuestGroupTotals.CheckInDate,
//	|		DATEDIFF(GuestGroupTotals.CheckInDate, GuestGroupTotals.CheckOutDate, DAY),
//	|		GuestGroupTotals.CheckOutDate,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.Примечания,
//	|		&qEmptyString,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		InvoiceAccountsTurnovers.Фирма,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.ДокОснование,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.Автор,
//	|		NULL,
//	|		NULL,
//	|		InvoiceAccountsTurnovers.СчетНаОплату,
//	|		InvoiceAccountsTurnovers.ВалютаРасчетов,
//	|		0,
//	|		DATEDIFF(BEGINOFPERIOD(InvoiceAccountsTurnovers.СчетНаОплату.ДатаДок, DAY), &qBegOfCurrentDate, DAY),
//	|		InvoiceAccountsTurnovers.SumReceipt,
//	|		InvoiceAccountsTurnovers.SumReceipt - InvoiceAccountsTurnovers.SumExpense,
//	|		InvoiceAccountsTurnovers.SumExpense,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		AccumulationRegister.ВзаиморасчетыПоСчетам.Turnovers(
//	|				&qBegOfTime,
//	|				&qEndOfTime,
//	|				Period,
//	|				&qShowInvoicesAndDeposits
//	|					AND (&qHotelIsEmpty
//	|						OR Гостиница IN HIERARCHY (&qHotel))
//	|					AND (&qGuestGroupIsEmpty
//	|						OR ГруппаГостей = &qGuestGroup)
//	|					AND ГруппаГостей IN
//	|						(SELECT
//	|							ПланируемыеГруппы.ГруппаГостей
//	|						FROM
//	|							ПланируемыеГруппы AS ПланируемыеГруппы)) AS InvoiceAccountsTurnovers
//	|			LEFT JOIN (SELECT
//	|				ПланируемыеГруппы.ГруппаГостей AS ГруппаГостей,
//	|				ПланируемыеГруппы.CheckInDate AS CheckInDate,
//	|				ПланируемыеГруппы.CheckOutDate AS CheckOutDate
//	|			FROM
//	|				ПланируемыеГруппы AS ПланируемыеГруппы) AS GuestGroupTotals
//	|			ON InvoiceAccountsTurnovers.ГруппаГостей = GuestGroupTotals.ГруппаГостей) AS ЗагрузкаНомеров
//	|		LEFT JOIN (SELECT
//	|			ClientTurnovers.Клиент AS Клиент,
//	|			ClientTurnovers.GuestsCheckedInTurnover AS NumberOfCheckins
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					,
//	|					&qPeriodTo,
//	|					PERIOD,
//	|					(&qHotelIsEmpty
//	|						OR Гостиница IN HIERARCHY (&qHotel))
//	|						AND Клиент IN
//	|							(SELECT
//	|								ExpectedGuests.Клиент
//	|							FROM
//	|								ExpectedGuests AS ExpectedGuests)) AS ClientTurnovers) AS ClientTotals
//	|		ON ЗагрузкаНомеров.Клиент = ClientTotals.Клиент
//	|		LEFT JOIN InformationRegister.GuestGroupAttachments.SliceLast(&qPeriodFrom, ) AS GuestGroupLastAttachments
//	|		ON ЗагрузкаНомеров.ГруппаГостей = GuestGroupLastAttachments.ГруппаГостей
//	|			AND (GuestGroupLastAttachments.AttachmentStatus <> &qSent)
//	|			AND (GuestGroupLastAttachments.AttachmentStatus <> &qReady)
//	|{WHERE
//	|	ЗагрузкаНомеров.Recorder.*,
//	|	ЗагрузкаНомеров.Recorder.ExternalCode AS ExternalCode,
//	|	ЗагрузкаНомеров.Гостиница.*,
//	|	ЗагрузкаНомеров.ТипНомера.*,
//	|	ЗагрузкаНомеров.НомерРазмещения.*,
//	|	ЗагрузкаНомеров.Контрагент.*,
//	|	ЗагрузкаНомеров.ТипКонтрагента.*,
//	|	ЗагрузкаНомеров.Договор.*,
//	|	ЗагрузкаНомеров.КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Агент.*,
//	|	ЗагрузкаНомеров.ГруппаГостей.*,
//	|	ЗагрузкаНомеров.ДокОснование.*,
//	|	ЗагрузкаНомеров.ПутевкаКурсовка.*,
//	|	ЗагрузкаНомеров.ReservationStatus.*,
//	|	ЗагрузкаНомеров.CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность,
//	|	ЗагрузкаНомеров.CheckOutDate,
//	|	ЗагрузкаНомеров.СрокБрони,
//	|	ЗагрузкаНомеров.CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate,
//	|	ЗагрузкаНомеров.ЗабронГостей,
//	|	ЗагрузкаНомеров.ЗабронНомеров,
//	|	ЗагрузкаНомеров.ЗабронированоМест,
//	|	ЗагрузкаНомеров.ЗабронДопМест,
//	|	ЗагрузкаНомеров.КвотаНомеров.*,
//	|	ЗагрузкаНомеров.RoomQuantity,
//	|	ЗагрузкаНомеров.ТипКлиента.*,
//	|	ЗагрузкаНомеров.Клиент.*,
//	|	ЗагрузкаНомеров.Клиент.Примечания AS GuestRemarks,
//	|	ЗагрузкаНомеров.МаретингНапрвл.*,
//	|	ЗагрузкаНомеров.TripPurpose.*,
//	|	ЗагрузкаНомеров.ИсточИнфоГостиница.*,
//	|	ЗагрузкаНомеров.RoomRateType.*,
//	|	ЗагрузкаНомеров.Тариф.*,
//	|	ЗагрузкаНомеров.PricePresentation,
//	|	ЗагрузкаНомеров.ДисконтКарт,
//	|	ЗагрузкаНомеров.ТипСкидки,
//	|	ЗагрузкаНомеров.Скидка,
//	|	ЗагрузкаНомеров.PlannedPaymentMethod.*,
//	|	ЗагрузкаНомеров.Автор.*,
//	|	ЗагрузкаНомеров.Car,
//	|	ЗагрузкаНомеров.Примечания,
//	|	ЗагрузкаНомеров.HousekeepingRemarks,
//	|	ЗагрузкаНомеров.КомиссияАгента,
//	|	ЗагрузкаНомеров.ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.IsMaster,
//	|	ЗагрузкаНомеров.Account.*,
//	|	ЗагрузкаНомеров.DaysBeforeCheckIn,
//	|	ЗагрузкаНомеров.InvoiceAge,
//	|	ЗагрузкаНомеров.ВалютаСчета.*,
//	|	ЗагрузкаНомеров.AccountBalance,
//	|	ЗагрузкаНомеров.SumInvoice,
//	|	ЗагрузкаНомеров.SumPayed,
//	|	ClientTotals.NumberOfCheckins,
//	|	ЗагрузкаНомеров.GuestGroupSales AS GuestGroupSales,
//	|	ЗагрузкаНомеров.GuestGroupSalesWithoutVAT AS GuestGroupSalesWithoutVAT,
//	|	ЗагрузкаНомеров.GuestGroupPayments AS GuestGroupPayments,
//	|	ЗагрузкаНомеров.GuestGroupPaymentsWithoutVAT AS GuestGroupPaymentsWithoutVAT,
//	|	ЗагрузкаНомеров.GuestGroupBalances AS GuestGroupBalances,
//	|	ЗагрузкаНомеров.GuestGroupBalancesWithoutVAT AS GuestGroupBalancesWithoutVAT,
//	|	(CASE
//	|			WHEN GuestGroupLastAttachments.AttachmentType IS NULL 
//	|				THEN &qEmptyAttachmentType
//	|			ELSE GuestGroupLastAttachments.AttachmentType
//	|		END) AS AttachmentType,
//	|	(CASE
//	|			WHEN (CAST(GuestGroupLastAttachments.DocumentText AS STRING(100))) <> &qEmptyString
//	|				THEN GuestGroupLastAttachments.DocumentText
//	|			WHEN (CAST(GuestGroupLastAttachments.Примечания AS STRING(100))) <> &qEmptyString
//	|				THEN GuestGroupLastAttachments.Примечания
//	|			WHEN (CAST(GuestGroupLastAttachments.FileName AS STRING(100))) <> &qEmptyString
//	|				THEN GuestGroupLastAttachments.FileName
//	|			ELSE &qEmptyString
//	|		END) AS AttachmentText,
//	|	(CASE
//	|			WHEN GuestGroupLastAttachments.Автор IS NULL 
//	|				THEN &qEmptyEmployee
//	|			ELSE GuestGroupLastAttachments.Автор
//	|		END) AS AttachmentAuthor}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	ГруппаГостей,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Контрагент.*,
//	|	ЗагрузкаНомеров.ТипКонтрагента.*,
//	|	ЗагрузкаНомеров.Договор.*,
//	|	ЗагрузкаНомеров.Агент.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	ЗагрузкаНомеров.МаретингНапрвл.*,
//	|	ЗагрузкаНомеров.TripPurpose.*,
//	|	ЗагрузкаНомеров.ИсточИнфоГостиница.*,
//	|	ЗагрузкаНомеров.RoomRateType.*,
//	|	ЗагрузкаНомеров.ТипКлиента.*,
//	|	Тариф.*,
//	|	PricePresentation,
//	|	ЗагрузкаНомеров.ДисконтКарт,
//	|	ЗагрузкаНомеров.ТипСкидки.*,
//	|	PlannedPaymentMethod.*,
//	|	ЗагрузкаНомеров.НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Гостиница.*,
//	|	ЗагрузкаНомеров.PointInTime,
//	|	CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность,
//	|	CheckOutDate,
//	|	ЗагрузкаНомеров.СрокБрони,
//	|	ЗабронГостей,
//	|	ЗабронНомеров,
//	|	ЗабронированоМест,
//	|	ЗабронДопМест,
//	|	ЗагрузкаНомеров.Автор.*,
//	|	ЗагрузкаНомеров.CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.CheckInDate)) AS CheckInYear,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateHour,
//	|	(BEGINOFPERIOD(ЗагрузкаНомеров.Recorder.ДатаДок, DAY)) AS CreateDate,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateYear,
//	|	Recorder.*,
//	|	ЗагрузкаНомеров.Recorder.ExternalCode AS ExternalCode,
//	|	ЗагрузкаНомеров.КвотаНомеров,
//	|	ЗагрузкаНомеров.Account.*,
//	|	ЗагрузкаНомеров.ВалютаСчета.*,
//	|	ЗагрузкаНомеров.DaysBeforeCheckIn,
//	|	ЗагрузкаНомеров.InvoiceAge,
//	|	ЗагрузкаНомеров.AccountBalance,
//	|	ЗагрузкаНомеров.SumInvoice,
//	|	ЗагрузкаНомеров.SumPayed,
//	|	NumberOfCheckins,
//	|	GuestGroupSales,
//	|	GuestGroupSalesWithoutVAT,
//	|	GuestGroupPayments,
//	|	GuestGroupPaymentsWithoutVAT,
//	|	GuestGroupBalances,
//	|	GuestGroupBalancesWithoutVAT}
//	|TOTALS
//	|	SUM(ЗабронГостей),
//	|	SUM(ЗабронНомеров),
//	|	SUM(ЗабронированоМест),
//	|	SUM(ЗабронДопМест),
//	|	CASE
//	|		WHEN NOT Recorder IS NULL 
//	|			THEN 0
//	|		WHEN ГруппаГостей IS NULL 
//	|			THEN 0
//	|		ELSE MAX(GuestGroupSales)
//	|	END AS GuestGroupSales,
//	|	CASE
//	|		WHEN NOT Recorder IS NULL 
//	|			THEN 0
//	|		WHEN ГруппаГостей IS NULL 
//	|			THEN 0
//	|		ELSE MAX(GuestGroupSalesWithoutVAT)
//	|	END AS GuestGroupSalesWithoutVAT,
//	|	CASE
//	|		WHEN NOT Recorder IS NULL 
//	|			THEN 0
//	|		WHEN ГруппаГостей IS NULL 
//	|			THEN 0
//	|		ELSE MAX(GuestGroupPayments)
//	|	END AS GuestGroupPayments,
//	|	CASE
//	|		WHEN NOT Recorder IS NULL 
//	|			THEN 0
//	|		WHEN ГруппаГостей IS NULL 
//	|			THEN 0
//	|		ELSE MAX(GuestGroupPaymentsWithoutVAT)
//	|	END AS GuestGroupPaymentsWithoutVAT,
//	|	CASE
//	|		WHEN NOT Recorder IS NULL 
//	|			THEN 0
//	|		WHEN ГруппаГостей IS NULL 
//	|			THEN 0
//	|		ELSE MAX(GuestGroupBalances)
//	|	END AS GuestGroupBalances,
//	|	CASE
//	|		WHEN NOT Recorder IS NULL 
//	|			THEN 0
//	|		WHEN ГруппаГостей IS NULL 
//	|			THEN 0
//	|		ELSE MAX(GuestGroupBalancesWithoutVAT)
//	|	END AS GuestGroupBalancesWithoutVAT
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	ГруппаГостей,
//	|	Recorder
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	ЗагрузкаНомеров.CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.CheckInDate)) AS CheckInYear,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateHour,
//	|	(BEGINOFPERIOD(ЗагрузкаНомеров.Recorder.ДатаДок, DAY)) AS CreateDate,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.ДатаДок)) AS CreateYear,
//	|	ТипНомера.*,
//	|	ЗагрузкаНомеров.НомерРазмещения.*,
//	|	Контрагент.*,
//	|	ЗагрузкаНомеров.ТипКонтрагента.*,
//	|	ЗагрузкаНомеров.Договор.*,
//	|	ЗагрузкаНомеров.КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Агент.*,
//	|	ГруппаГостей.*,
//	|	ЗагрузкаНомеров.ПутевкаКурсовка.*,
//	|	ReservationStatus.*,
//	|	ЗагрузкаНомеров.КвотаНомеров.*,
//	|	ЗагрузкаНомеров.ТипКлиента.*,
//	|	ЗагрузкаНомеров.МаретингНапрвл.*,
//	|	ЗагрузкаНомеров.TripPurpose.*,
//	|	ЗагрузкаНомеров.ИсточИнфоГостиница.*,
//	|	ЗагрузкаНомеров.RoomRateType.*,
//	|	ЗагрузкаНомеров.Тариф.*,
//	|	ЗагрузкаНомеров.Автор.*,
//	|	PricePresentation,
//	|	ЗагрузкаНомеров.ДисконтКарт,
//	|	ЗагрузкаНомеров.ТипСкидки,
//	|	Recorder.*,
//	|	PlannedPaymentMethod.*,
//	|	ЗагрузкаНомеров.Account.*,
//	|	ЗагрузкаНомеров.ВалютаСчета.*,
//	|	NumberOfCheckins}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Expected check in';RU='Планируемый заезд';de='Geplante Anreise'");
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
