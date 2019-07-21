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
//	If ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Оперативный баланс на '; en = 'Operative balance on '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", '00010101');
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPaymentPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), PeriodTo, '39991231235959'));
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodFrom", GuestGroupCheckInPeriodFrom);
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodFromIsEmpty", НЕ ЗначениеЗаполнено(GuestGroupCheckInPeriodFrom));
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodTo", GuestGroupCheckInPeriodTo);
//	ReportBuilder.Parameters.Вставить("qGuestGroupCheckInPeriodToIsEmpty", НЕ ЗначениеЗаполнено(GuestGroupCheckInPeriodTo));
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
//	|	OperationalAccounts.Фирма AS Фирма,
//	|	OperationalAccounts.Валюта AS Валюта,
//	|	OperationalAccounts.Контрагент AS Контрагент,
//	|	OperationalAccounts.Договор AS Договор,
//	|	OperationalAccounts.Гостиница AS Гостиница,
//	|	OperationalAccounts.ГруппаГостей AS ГруппаГостей,
//	|	SUM(OperationalAccounts.AccountingBalance) AS AccountingBalance,
//	|	SUM(OperationalAccounts.CurrentSum) AS CurrentSum,
//	|	SUM(OperationalAccounts.ForecastSum) AS ForecastSum,
//	|	SUM(OperationalAccounts.AccountingBalance) + SUM(OperationalAccounts.CurrentSum) + SUM(OperationalAccounts.ForecastSum) AS SumBalance
//	|{SELECT
//	|	Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	Гостиница.* AS Гостиница,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	CustomerLastPayment.LastPaymentDate AS LastPaymentDate,
//	|	AccountingBalance,
//	|	CurrentSum,
//	|	ForecastSum,
//	|	SumBalance}
//	|FROM
//	|	(SELECT
//	|		ВзаиморасчетыКонтрагенты.Гостиница AS Гостиница,
//	|		ВзаиморасчетыКонтрагенты.Фирма AS Фирма,
//	|		ВзаиморасчетыКонтрагенты.ВалютаРасчетов AS Валюта,
//	|		ВзаиморасчетыКонтрагенты.Контрагент AS Контрагент,
//	|		ВзаиморасчетыКонтрагенты.Договор AS Договор,
//	|		ВзаиморасчетыКонтрагенты.ГруппаГостей AS ГруппаГостей,
//	|		ВзаиморасчетыКонтрагенты.SumBalance AS AccountingBalance,
//	|		0 AS CurrentSum,
//	|		0 AS ForecastSum
//	|	FROM
//	|		AccumulationRegister.ВзаиморасчетыКонтрагенты.Balance(
//	|				&qPeriodTo,
//	|				(Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|					AND (Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer)
//	|					AND (Договор = &qContract
//	|						OR &qIsEmptyContract)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|					AND (ВалютаРасчетов = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|					AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR (NOT &qGuestGroupCheckInPeriodFromIsEmpty)
//	|							AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|					AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR (NOT &qGuestGroupCheckInPeriodToIsEmpty)
//	|							AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)) AS ВзаиморасчетыКонтрагенты
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
//	|		0,
//	|		РелизацияТекОтчетПериод.SumBalance - РелизацияТекОтчетПериод.CommissionSumBalance,
//	|		0
//	|	FROM
//	|		AccumulationRegister.РелизацияТекОтчетПериод.Balance(
//	|				&qPeriodTo,
//	|				(Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|					AND (Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer
//	|						OR &qIndividualsCustomerIsChoosen
//	|							AND Контрагент = &qEmptyCustomer)
//	|					AND (Договор = &qContract
//	|						OR &qIsEmptyContract)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|					AND (ВалютаЛицСчета = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|					AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR (NOT &qGuestGroupCheckInPeriodFromIsEmpty)
//	|							AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|					AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR (NOT &qGuestGroupCheckInPeriodToIsEmpty)
//	|							AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)) AS РелизацияТекОтчетПериод
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		CustomerSalesForecast.Гостиница,
//	|		CustomerSalesForecast.Фирма,
//	|		CustomerSalesForecast.Валюта,
//	|		CASE
//	|			WHEN CustomerSalesForecast.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsCustomer
//	|			ELSE CustomerSalesForecast.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN CustomerSalesForecast.Контрагент = &qEmptyCustomer
//	|				THEN &qIndividualsContract
//	|			ELSE CustomerSalesForecast.Договор
//	|		END,
//	|		CustomerSalesForecast.ГруппаГостей,
//	|		0,
//	|		0,
//	|		CustomerSalesForecast.SalesTurnover - CustomerSalesForecast.CommissionSumTurnover
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Period,
//	|				(Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|					AND (Фирма IN HIERARCHY (&qCompany)
//	|						OR &qIsEmptyCompany)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer
//	|						OR &qIndividualsCustomerIsChoosen
//	|							AND Контрагент = &qEmptyCustomer)
//	|					AND (Договор = &qContract
//	|						OR &qIsEmptyContract)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qIsEmptyGuestGroup)
//	|					AND (Валюта = &qCurrency
//	|						OR &qIsEmptyCurrency)
//	|					AND (&qGuestGroupCheckInPeriodFromIsEmpty
//	|						OR (NOT &qGuestGroupCheckInPeriodFromIsEmpty)
//	|							AND ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|					AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|						OR (NOT &qGuestGroupCheckInPeriodToIsEmpty)
//	|							AND ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)) AS CustomerSalesForecast) AS OperationalAccounts
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
//	|					OR (NOT &qGuestGroupCheckInPeriodFromIsEmpty)
//	|						AND CustomerPayments.ГруппаГостей.CheckInDate >= &qGuestGroupCheckInPeriodFrom)
//	|			AND (&qGuestGroupCheckInPeriodToIsEmpty
//	|					OR (NOT &qGuestGroupCheckInPeriodToIsEmpty)
//	|						AND CustomerPayments.ГруппаГостей.CheckInDate <= &qGuestGroupCheckInPeriodTo)
//	|		
//	|		GROUP BY
//	|			CustomerPayments.ВалютаРасчетов,
//	|			CustomerPayments.Контрагент,
//	|			CustomerPayments.Договор,
//	|			CustomerPayments.Гостиница,
//	|			CustomerPayments.Фирма,
//	|			CustomerPayments.ГруппаГостей) AS CustomerLastPayment
//	|		ON OperationalAccounts.Валюта = CustomerLastPayment.Валюта
//	|			AND OperationalAccounts.Контрагент = CustomerLastPayment.Контрагент
//	|			AND OperationalAccounts.Договор = CustomerLastPayment.Договор
//	|			AND OperationalAccounts.Гостиница = CustomerLastPayment.Гостиница
//	|			AND OperationalAccounts.Фирма = CustomerLastPayment.Фирма
//	|			AND OperationalAccounts.ГруппаГостей = CustomerLastPayment.ГруппаГостей
//	|{WHERE
//	|	OperationalAccounts.Гостиница.*,
//	|	OperationalAccounts.Фирма.*,
//	|	OperationalAccounts.Валюта.*,
//	|	OperationalAccounts.Контрагент.*,
//	|	OperationalAccounts.Договор.*,
//	|	OperationalAccounts.ГруппаГостей.*,
//	|	CustomerLastPayment.LastPaymentDate AS LastPaymentDate,
//	|	OperationalAccounts.AccountingBalance,
//	|	OperationalAccounts.CurrentSum,
//	|	OperationalAccounts.ForecastSum,
//	|	(SUM(OperationalAccounts.AccountingBalance) + SUM(OperationalAccounts.CurrentSum) + SUM(OperationalAccounts.ForecastSum)) AS SumBalance}
//	|
//	|GROUP BY
//	|	OperationalAccounts.Фирма,
//	|	OperationalAccounts.Валюта,
//	|	OperationalAccounts.Контрагент,
//	|	OperationalAccounts.Договор,
//	|	OperationalAccounts.Гостиница,
//	|	OperationalAccounts.ГруппаГостей
//	|
//	|ORDER BY
//	|	Фирма,
//	|	Валюта,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей
//	|{ORDER BY
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	Гостиница.*,
//	|	ГруппаГостей.*,
//	|	CustomerLastPayment.LastPaymentDate AS LastPaymentDate,
//	|	AccountingBalance,
//	|	CurrentSum,
//	|	ForecastSum,
//	|	SumBalance}
//	|TOTALS
//	|	SUM(AccountingBalance),
//	|	SUM(CurrentSum),
//	|	SUM(ForecastSum),
//	|	SUM(SumBalance)
//	|BY
//	|	OVERALL,
//	|	Фирма HIERARCHY,
//	|	Валюта,
//	|	Контрагент HIERARCHY,
//	|	Договор,
//	|	Гостиница HIERARCHY,
//	|	ГруппаГостей
//	|{TOTALS BY
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	Гостиница.*,
//	|	ГруппаГостей.*,
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
//	ReportBuilder.HeaderText = NStr("EN='Operational Контрагент accounts balance';RU='Оперативный баланс взаиморасчетов с контрагентами';de='Operative Bilanz der gegenseitigen Verrechnung mit  den Vertragspartnern'");
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
//	If pName = "AccountingBalance" Or
//	   pName = "CurrentSum" Or 
//	   pName = "ForecastSum" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
