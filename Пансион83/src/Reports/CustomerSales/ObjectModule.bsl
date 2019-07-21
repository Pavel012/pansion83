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
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByChargeDates;
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
//	If PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckInDates Тогда
//		vParamPresentation = vParamPresentation + NStr("en='By checked-in guests';ru='По заезду гостей';de='Nach Anreise der Gäste'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckOutDates Тогда
//		vParamPresentation = vParamPresentation + NStr("en='By checked-out guests';ru='По выезду гостей';de='Nach Abreise der Gäste'") + 
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
//	If ЗначениеЗаполнено(Agent) Тогда
//		If НЕ Agent.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Agent ';ru='Агент ';de='Vertreter'") + 
//			                     TrimAll(Agent.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Agents folder ';ru='Группа агентов ';de='Gruppe Vertreter'") + 
//			                     TrimAll(Agent.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Набор услуг '; en = 'Service group '") + 
//			                     TrimAll(ServiceGroup.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа наборов услуг '; en = 'Service groups folder '") + 
//			                     TrimAll(ServiceGroup.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ShowForecastByReservations Тогда
//		vParamPresentation = vParamPresentation + NStr("en='With forecast reservation sales';ru='С учетом планируемых продаж по брони';de='Unter Berücksichtigung geplanter Verkäufe aus Buchung'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If AgentCommission > 0 Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Commission calculated by ';ru='Расчет комиссии выполнен по ';de='Kommission berechnet von '") + Format(AgentCommission, "ND=6; NFD=2; NZ=; NG=") + 
//		                     "%;" + Chars.LF;
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
//	If PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckInDates Тогда
//		ReportBuilder.Parameters.Вставить("qByCheckInDates", True);
//	Else
//		ReportBuilder.Parameters.Вставить("qByCheckInDates", False);
//	EndIf;
//	If PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckOutDates Тогда
//		ReportBuilder.Parameters.Вставить("qByCheckOutDates", True);
//	Else
//		ReportBuilder.Parameters.Вставить("qByCheckOutDates", False);
//	EndIf;
//	If PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckInDates Or 
//	   PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckOutDates Тогда
//		ReportBuilder.Parameters.Вставить("qServicesPeriodFrom", '00010101');
//		ReportBuilder.Parameters.Вставить("qServicesPeriodTo", '39991231');
//		ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", BegOfDay(CurrentDate()));
//		ReportBuilder.Parameters.Вставить("qForecastPeriodTo", '39991231');
//	Else
//		ReportBuilder.Parameters.Вставить("qServicesPeriodFrom", PeriodFrom);
//		ReportBuilder.Parameters.Вставить("qServicesPeriodTo", PeriodTo);
//		ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//		ReportBuilder.Parameters.Вставить("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qContractIsEmpty", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qAgent", Agent);
//	ReportBuilder.Parameters.Вставить("qAgentIsEmpty", НЕ ЗначениеЗаполнено(Agent));
//	ReportBuilder.Parameters.Вставить("qAgentCommission", AgentCommission);
//	vUseServicesList = False;
//	vServicesList = New СписокЗначений();
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IncludeAll Тогда
//			vUseServicesList = True;
//			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
//		EndIf;
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qUseServicesList", vUseServicesList);
//	ReportBuilder.Parameters.Вставить("qServicesList", vServicesList);
//	ReportBuilder.Parameters.Вставить("qShowForecastByReservations", ShowForecastByReservations);
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231');
//	ReportBuilder.Parameters.Вставить("qEmptyString", "");
//	ReportBuilder.Parameters.Вставить("qShowPayedAmount", ShowPayedAmount);
//	ReportBuilder.Parameters.Вставить("qEmptyGuestGroup", Справочники.ГруппыГостей.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
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
//	|	ГруппыГостей.ГруппаГостей
//	|INTO ГруппыГостей
//	|FROM
//	|	(SELECT
//	|		CustomerSales.ГруппаГостей AS ГруппаГостей
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qServicesPeriodFrom,
//	|				&qServicesPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qCustomerIsEmpty)
//	|					AND (Договор IN HIERARCHY (&qContract)
//	|						OR &qContractIsEmpty)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qGuestGroupIsEmpty)
//	|					AND (Агент IN HIERARCHY (&qAgent)
//	|						OR &qAgentIsEmpty)
//	|					AND (Услуга IN (&qServicesList)
//	|						OR NOT &qUseServicesList)
//	|					AND (NOT &qByCheckInDates
//	|						OR &qByCheckInDates
//	|							AND ДокОснование.CheckInDate >= &qPeriodFrom
//	|							AND ДокОснование.CheckInDate <= &qPeriodTo)
//	|					AND (NOT &qByCheckOutDates
//	|						OR &qByCheckOutDates
//	|							AND ДокОснование.CheckOutDate >= &qPeriodFrom
//	|							AND ДокОснование.CheckOutDate <= &qPeriodTo)) AS CustomerSales
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		CustomerSalesForecast.ГруппаГостей
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|				&qForecastPeriodFrom,
//	|				&qForecastPeriodTo,
//	|				Period,
//	|				&qShowForecastByReservations
//	|					AND Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qCustomerIsEmpty)
//	|					AND (Договор IN HIERARCHY (&qContract)
//	|						OR &qContractIsEmpty)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qGuestGroupIsEmpty)
//	|					AND (Агент IN HIERARCHY (&qAgent)
//	|						OR &qAgentIsEmpty)
//	|					AND (Услуга IN (&qServicesList)
//	|						OR NOT &qUseServicesList)
//	|					AND (NOT &qByCheckInDates
//	|						OR &qByCheckInDates
//	|							AND ДокОснование.CheckInDate >= &qPeriodFrom
//	|							AND ДокОснование.CheckInDate <= &qPeriodTo)
//	|					AND (NOT &qByCheckOutDates
//	|						OR &qByCheckOutDates
//	|							AND ДокОснование.CheckOutDate >= &qPeriodFrom
//	|							AND ДокОснование.CheckOutDate <= &qPeriodTo)) AS CustomerSalesForecast) AS ГруппыГостей
//	|
//	|GROUP BY
//	|	ГруппыГостей.ГруппаГостей
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	CustomerSales.Фирма AS Фирма,
//	|	CustomerSales.Гостиница AS Гостиница,
//	|	CustomerSales.Валюта AS Валюта,
//	|	CustomerSales.Агент AS Агент,
//	|	CustomerSales.Контрагент AS Контрагент,
//	|	CustomerSales.Договор AS Договор,
//	|	CustomerSales.ГруппаГостей AS ГруппаГостей,
//	|	CustomerSales.Клиент AS Клиент,
//	|	CustomerSales.ТипКлиента AS ТипКлиента,
//	|	CustomerSales.TripPurpose AS TripPurpose,
//	|	CustomerSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	CustomerSales.МаретингНапрвл AS МаретингНапрвл,
//	|	CustomerSales.CheckInDate AS CheckInDate,
//	|	CustomerSales.CheckOutDate AS CheckOutDate,
//	|	CustomerSales.ВидРазмещения AS ВидРазмещения,
//	|	CustomerSales.Status AS Status,
//	|	CustomerSales.НомерРазмещения AS НомерРазмещения,
//	|	CustomerSales.ТипНомера AS ТипНомера,
//	|	CustomerSales.Ресурс AS Ресурс,
//	|	CustomerSales.Тариф AS Тариф,
//	|	CustomerSales.ДокОснование AS ДокОснование,
//	|	CustomerSales.СпособОплаты AS СпособОплаты,
//	|	CustomerSales.Продажи AS Продажи,
//	|	CustomerSales.ПродажиБезНДС AS ПродажиБезНДС,
//	|	CustomerSales.ДоходНомеров AS ДоходНомеров,
//	|	CustomerSales.RoomRevenueWithoutCommission AS RoomRevenueWithoutCommission,
//	|	CustomerSales.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	CustomerSales.RoomRevenueWithoutVATWithoutCommission AS RoomRevenueWithoutVATWithoutCommission,
//	|	CustomerSales.ДоходДопМеста AS ДоходДопМеста,
//	|	CustomerSales.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	CustomerSales.MainBedsRevenue AS MainBedsRevenue,
//	|	CustomerSales.MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	CustomerSales.СуммаКомиссии AS СуммаКомиссии,
//	|	CustomerSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|	CustomerSales.CalculatedCommissionSum AS CalculatedCommissionSum,
//	|	CustomerSales.CalculatedCommissionSumWithoutVAT AS CalculatedCommissionSumWithoutVAT,
//	|	CustomerSales.СуммаСкидки AS СуммаСкидки,
//	|	CustomerSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	CustomerSales.BruttoSales AS BruttoSales,
//	|	CustomerSales.BruttoSalesWithoutVAT AS BruttoSalesWithoutVAT,
//	|	CustomerSales.SalesWithoutCommission AS SalesWithoutCommission,
//	|	CustomerSales.SalesWithoutCommissionWithoutVAT AS SalesWithoutCommissionWithoutVAT,
//	|	CustomerSales.SalesWithoutCalculatedCommission AS SalesWithoutCalculatedCommission,
//	|	CustomerSales.SalesWithoutCalculatedCommissionWithoutVAT AS SalesWithoutCalculatedCommissionWithoutVAT,
//	|	CustomerSales.ПроданоНомеров AS ПроданоНомеров,
//	|	CustomerSales.ПроданоМест AS ПроданоМест,
//	|	CustomerSales.ПроданоДопМест AS ПроданоДопМест,
//	|	CustomerSales.ЧеловекаДни AS ЧеловекаДни,
//	|	CustomerSales.ЗаездГостей AS ЗаездГостей,
//	|	CustomerSales.ЗаездНомеров AS ЗаездНомеров,
//	|	CustomerSales.ЗаездМест AS ЗаездМест,
//	|	CustomerSales.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	CustomerSales.Количество AS Количество,
//	|	CustomerSales.PayedAmount AS PayedAmount,
//	|	CustomerSales.PayedByCashAmount AS PayedByCashAmount,
//	|	CustomerSales.PayedByCreditCardAmount AS PayedByCreditCardAmount,
//	|	CustomerSales.PayedByBankTransferAmount AS PayedByBankTransferAmount,
//	|	CustomerSales.PayedByInternetAcquiringAmount AS PayedByInternetAcquiringAmount,
//	|	CustomerSales.PayedByBonusesAmount AS PayedByBonusesAmount,
//	|	CustomerSales.PayedByGiftCertificatesAmount AS PayedByGiftCertificatesAmount
//	|{SELECT
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	TripPurpose.* AS TripPurpose,
//	|	ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	МаретингНапрвл.* AS МаретингНапрвл,
//	|	CheckInDate,
//	|	CheckOutDate,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	Тариф.*,
//	|	ДокОснование.*,
//	|	CustomerSales.Примечания AS Примечания,
//	|	CustomerSales.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	СпособОплаты.*,
//	|	Продажи,
//	|	ПродажиБезНДС,
//	|	ДоходНомеров,
//	|	RoomRevenueWithoutCommission,
//	|	ДоходПродажиБезНДС,
//	|	RoomRevenueWithoutVATWithoutCommission,
//	|	ДоходДопМеста,
//	|	ДоходДопМестаБезНДС,
//	|	MainBedsRevenue,
//	|	MainBedsRevenueWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	CalculatedCommissionSum,
//	|	CalculatedCommissionSumWithoutVAT,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	BruttoSales,
//	|	BruttoSalesWithoutVAT,
//	|	SalesWithoutCommission,
//	|	SalesWithoutCommissionWithoutVAT,
//	|	SalesWithoutCalculatedCommission,
//	|	SalesWithoutCalculatedCommissionWithoutVAT,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Количество,
//	|	PayedAmount,
//	|	PayedByCashAmount,
//	|	PayedByCreditCardAmount,
//	|	PayedByBankTransferAmount,
//	|	PayedByInternetAcquiringAmount,
//	|	PayedByBonusesAmount,
//	|	PayedByGiftCertificatesAmount}
//	|FROM
//	|	(SELECT
//	|		CustomerTurnovers.Фирма AS Фирма,
//	|		CustomerTurnovers.Гостиница AS Гостиница,
//	|		CustomerTurnovers.Валюта AS Валюта,
//	|		CustomerTurnovers.Агент AS Агент,
//	|		CASE
//	|			WHEN CustomerTurnovers.Контрагент = &qEmptyCustomer
//	|				THEN CustomerTurnovers.Гостиница.IndividualsCustomer
//	|			ELSE CustomerTurnovers.Контрагент
//	|		END AS Контрагент,
//	|		CASE
//	|			WHEN CustomerTurnovers.Контрагент = &qEmptyCustomer
//	|				THEN CustomerTurnovers.Гостиница.IndividualsContract
//	|			ELSE CustomerTurnovers.Договор
//	|		END AS Договор,
//	|		CustomerTurnovers.ГруппаГостей AS ГруппаГостей,
//	|		CustomerTurnovers.Клиент AS Клиент,
//	|		CustomerTurnovers.ТипКлиента AS ТипКлиента,
//	|		CustomerTurnovers.TripPurpose AS TripPurpose,
//	|		CustomerTurnovers.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		CustomerTurnovers.МаретингНапрвл AS МаретингНапрвл,
//	|		CustomerTurnovers.CheckInDate AS CheckInDate,
//	|		CustomerTurnovers.CheckOutDate AS CheckOutDate,
//	|		CustomerTurnovers.ВидРазмещения AS ВидРазмещения,
//	|		CustomerTurnovers.Status AS Status,
//	|		CustomerTurnovers.НомерРазмещения AS НомерРазмещения,
//	|		CustomerTurnovers.ТипНомера AS ТипНомера,
//	|		CustomerTurnovers.Ресурс AS Ресурс,
//	|		CustomerTurnovers.Тариф AS Тариф,
//	|		CustomerTurnovers.ДокОснование AS ДокОснование,
//	|		CustomerTurnovers.СпособОплаты AS СпособОплаты,
//	|		CustomerTurnovers.Примечания AS Примечания,
//	|		ForeignerRegistryRecords.ForeignerRegistryRecord AS ForeignerRegistryRecord,
//	|		SUM(CustomerTurnovers.Продажи) AS Продажи,
//	|		SUM(CustomerTurnovers.ПродажиБезНДС) AS ПродажиБезНДС,
//	|		SUM(CustomerTurnovers.ДоходНомеров) AS ДоходНомеров,
//	|		SUM(CustomerTurnovers.ДоходНомеров - CustomerTurnovers.СуммаКомиссии) AS RoomRevenueWithoutCommission,
//	|		SUM(CustomerTurnovers.ДоходПродажиБезНДС) AS ДоходПродажиБезНДС,
//	|		SUM(CustomerTurnovers.ДоходПродажиБезНДС - CustomerTurnovers.КомиссияБезНДС) AS RoomRevenueWithoutVATWithoutCommission,
//	|		SUM(CustomerTurnovers.ДоходДопМеста) AS ДоходДопМеста,
//	|		SUM(CustomerTurnovers.ДоходДопМестаБезНДС) AS ДоходДопМестаБезНДС,
//	|		SUM(CustomerTurnovers.MainBedsRevenue) AS MainBedsRevenue,
//	|		SUM(CustomerTurnovers.MainBedsRevenueWithoutVAT) AS MainBedsRevenueWithoutVAT,
//	|		SUM(CustomerTurnovers.СуммаКомиссии) AS СуммаКомиссии,
//	|		SUM(CustomerTurnovers.КомиссияБезНДС) AS КомиссияБезНДС,
//	|		SUM(CustomerTurnovers.CalculatedCommissionSum) AS CalculatedCommissionSum,
//	|		SUM(CustomerTurnovers.CalculatedCommissionSumWithoutVAT) AS CalculatedCommissionSumWithoutVAT,
//	|		SUM(CustomerTurnovers.СуммаСкидки) AS СуммаСкидки,
//	|		SUM(CustomerTurnovers.СуммаСкидкиБезНДС) AS СуммаСкидкиБезНДС,
//	|		SUM(CustomerTurnovers.Продажи + CustomerTurnovers.СуммаСкидки) AS BruttoSales,
//	|		SUM(CustomerTurnovers.ПродажиБезНДС + CustomerTurnovers.ПродажиБезНДС) AS BruttoSalesWithoutVAT,
//	|		SUM(CustomerTurnovers.Продажи - CustomerTurnovers.СуммаКомиссии) AS SalesWithoutCommission,
//	|		SUM(CustomerTurnovers.ПродажиБезНДС - CustomerTurnovers.КомиссияБезНДС) AS SalesWithoutCommissionWithoutVAT,
//	|		SUM(CustomerTurnovers.Продажи + CustomerTurnovers.СуммаСкидки - CustomerTurnovers.CalculatedCommissionSum) AS SalesWithoutCalculatedCommission,
//	|		SUM(CustomerTurnovers.ПродажиБезНДС + CustomerTurnovers.СуммаСкидкиБезНДС - CustomerTurnovers.CalculatedCommissionSumWithoutVAT) AS SalesWithoutCalculatedCommissionWithoutVAT,
//	|		SUM(CustomerTurnovers.ПроданоНомеров) AS ПроданоНомеров,
//	|		SUM(CustomerTurnovers.ПроданоМест) AS ПроданоМест,
//	|		SUM(CustomerTurnovers.ПроданоДопМест) AS ПроданоДопМест,
//	|		SUM(CustomerTurnovers.ЧеловекаДни) AS ЧеловекаДни,
//	|		SUM(CustomerTurnovers.ЗаездГостей) AS ЗаездГостей,
//	|		SUM(CustomerTurnovers.ЗаездНомеров) AS ЗаездНомеров,
//	|		SUM(CustomerTurnovers.ЗаездМест) AS ЗаездМест,
//	|		SUM(CustomerTurnovers.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест,
//	|		SUM(CustomerTurnovers.Количество) AS Количество,
//	|		SUM(CustomerTurnovers.PayedAmount) AS PayedAmount,
//	|		SUM(CustomerTurnovers.PayedByCashAmount) AS PayedByCashAmount,
//	|		SUM(CustomerTurnovers.PayedByCreditCardAmount) AS PayedByCreditCardAmount,
//	|		SUM(CustomerTurnovers.PayedByBankTransferAmount) AS PayedByBankTransferAmount,
//	|		SUM(CustomerTurnovers.PayedByInternetAcquiringAmount) AS PayedByInternetAcquiringAmount,
//	|		SUM(CustomerTurnovers.PayedByBonusesAmount) AS PayedByBonusesAmount,
//	|		SUM(CustomerTurnovers.PayedByGiftCertificatesAmount) AS PayedByGiftCertificatesAmount
//	|	FROM
//	|		(SELECT
//	|			CustomerSales.Фирма AS Фирма,
//	|			CustomerSales.Гостиница AS Гостиница,
//	|			CustomerSales.Валюта AS Валюта,
//	|			CustomerSales.Агент AS Агент,
//	|			CustomerSales.Контрагент AS Контрагент,
//	|			CustomerSales.Договор AS Договор,
//	|			CustomerSales.ДокОснование AS ДокОснование,
//	|			CAST(CustomerSales.ДокОснование.Примечания AS STRING(1024)) AS Примечания,
//	|			CustomerSales.ГруппаГостей AS ГруппаГостей,
//	|			CustomerSales.Клиент AS Клиент,
//	|			CustomerSales.ТипКлиента AS ТипКлиента,
//	|			CustomerSales.TripPurpose AS TripPurpose,
//	|			CustomerSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			CustomerSales.МаретингНапрвл AS МаретингНапрвл,
//	|			CASE
//	|				WHEN CustomerSales.ДокОснование.CheckInDate IS NULL 
//	|					THEN CustomerSales.ДокОснование.DateTimeFrom
//	|				ELSE CustomerSales.ДокОснование.CheckInDate
//	|			END AS CheckInDate,
//	|			CASE
//	|				WHEN CustomerSales.ДокОснование.CheckOutDate IS NULL 
//	|					THEN CustomerSales.ДокОснование.DateTimeTo
//	|				ELSE CustomerSales.ДокОснование.CheckOutDate
//	|			END AS CheckOutDate,
//	|			CASE
//	|				WHEN NOT CustomerSales.ДокОснование.СтатусРазмещения IS NULL 
//	|					THEN CustomerSales.ДокОснование.СтатусРазмещения
//	|				WHEN NOT CustomerSales.ДокОснование.ReservationStatus IS NULL 
//	|					THEN CustomerSales.ДокОснование.ReservationStatus
//	|				ELSE CustomerSales.ДокОснование.ResourceReservationStatus
//	|			END AS Status,
//	|			CustomerSales.ВидРазмещения AS ВидРазмещения,
//	|			CustomerSales.НомерРазмещения AS НомерРазмещения,
//	|			CustomerSales.ТипНомера AS ТипНомера,
//	|			CustomerSales.Тариф AS Тариф,
//	|			CustomerSales.Ресурс AS Ресурс,
//	|			CustomerSales.СпособОплаты AS СпособОплаты,
//	|			CustomerSales.SalesTurnover AS Продажи,
//	|			CustomerSales.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|			CustomerSales.RoomRevenueTurnover AS ДоходНомеров,
//	|			CustomerSales.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|			CustomerSales.ExtraBedRevenueTurnover AS ДоходДопМеста,
//	|			CustomerSales.ExtraBedRevenueWithoutVATTurnover AS ДоходДопМестаБезНДС,
//	|			CustomerSales.RoomRevenueTurnover - CustomerSales.ExtraBedRevenueTurnover AS MainBedsRevenue,
//	|			CustomerSales.RoomRevenueWithoutVATTurnover - CustomerSales.ExtraBedRevenueWithoutVATTurnover AS MainBedsRevenueWithoutVAT,
//	|			CustomerSales.CommissionSumTurnover AS СуммаКомиссии,
//	|			CustomerSales.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|			(CustomerSales.SalesTurnover + CustomerSales.DiscountSumTurnover) * &qAgentCommission / 100 AS CalculatedCommissionSum,
//	|			(CustomerSales.SalesWithoutVATTurnover + CustomerSales.DiscountSumWithoutVATTurnover) * &qAgentCommission / 100 AS CalculatedCommissionSumWithoutVAT,
//	|			CustomerSales.DiscountSumTurnover AS СуммаСкидки,
//	|			CustomerSales.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|			CustomerSales.RoomsRentedTurnover AS ПроданоНомеров,
//	|			CustomerSales.BedsRentedTurnover AS ПроданоМест,
//	|			CustomerSales.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|			CustomerSales.GuestDaysTurnover AS ЧеловекаДни,
//	|			CustomerSales.GuestsCheckedInTurnover AS ЗаездГостей,
//	|			CustomerSales.RoomsCheckedInTurnover AS ЗаездНомеров,
//	|			CustomerSales.BedsCheckedInTurnover AS ЗаездМест,
//	|			CustomerSales.AdditionalBedsCheckedInTurnover AS ЗаездДополнительныхМест,
//	|			CustomerSales.QuantityTurnover AS Количество,
//	|			0 AS PayedAmount,
//	|			0 AS PayedByCashAmount,
//	|			0 AS PayedByCreditCardAmount,
//	|			0 AS PayedByBankTransferAmount,
//	|			0 AS PayedByInternetAcquiringAmount,
//	|			0 AS PayedByBonusesAmount,
//	|			0 AS PayedByGiftCertificatesAmount
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qServicesPeriodFrom,
//	|					&qServicesPeriodTo,
//	|					Period,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qCustomerIsEmpty)
//	|						AND (Договор IN HIERARCHY (&qContract)
//	|							OR &qContractIsEmpty)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qGuestGroupIsEmpty)
//	|						AND (Агент IN HIERARCHY (&qAgent)
//	|							OR &qAgentIsEmpty)
//	|						AND (Услуга IN (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qByCheckInDates
//	|							OR &qByCheckInDates
//	|								AND ДокОснование.CheckInDate >= &qPeriodFrom
//	|								AND ДокОснование.CheckInDate <= &qPeriodTo)
//	|						AND (NOT &qByCheckOutDates
//	|							OR &qByCheckOutDates
//	|								AND ДокОснование.CheckOutDate >= &qPeriodFrom
//	|								AND ДокОснование.CheckOutDate <= &qPeriodTo)) AS CustomerSales
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			CustomerSalesForecast.Фирма,
//	|			CustomerSalesForecast.Гостиница,
//	|			CustomerSalesForecast.Валюта,
//	|			CustomerSalesForecast.Агент,
//	|			CustomerSalesForecast.Контрагент,
//	|			CustomerSalesForecast.Договор,
//	|			CustomerSalesForecast.ДокОснование,
//	|			CAST(CustomerSalesForecast.ДокОснование.Примечания AS STRING(1024)),
//	|			CustomerSalesForecast.ГруппаГостей,
//	|			CustomerSalesForecast.Клиент,
//	|			CustomerSalesForecast.ТипКлиента,
//	|			CustomerSalesForecast.TripPurpose,
//	|			CustomerSalesForecast.ИсточИнфоГостиница,
//	|			CustomerSalesForecast.МаретингНапрвл,
//	|			CASE
//	|				WHEN CustomerSalesForecast.ДокОснование.CheckInDate IS NULL 
//	|					THEN CustomerSalesForecast.ДокОснование.DateTimeFrom
//	|				ELSE CustomerSalesForecast.ДокОснование.CheckInDate
//	|			END,
//	|			CASE
//	|				WHEN CustomerSalesForecast.ДокОснование.CheckOutDate IS NULL 
//	|					THEN CustomerSalesForecast.ДокОснование.DateTimeTo
//	|				ELSE CustomerSalesForecast.ДокОснование.CheckOutDate
//	|			END,
//	|			CASE
//	|				WHEN NOT CustomerSalesForecast.ДокОснование.СтатусРазмещения IS NULL 
//	|					THEN CustomerSalesForecast.ДокОснование.СтатусРазмещения
//	|				WHEN NOT CustomerSalesForecast.ДокОснование.ReservationStatus IS NULL 
//	|					THEN CustomerSalesForecast.ДокОснование.ReservationStatus
//	|				ELSE CustomerSalesForecast.ДокОснование.ResourceReservationStatus
//	|			END,
//	|			CustomerSalesForecast.ВидРазмещения,
//	|			CustomerSalesForecast.НомерРазмещения,
//	|			CustomerSalesForecast.ТипНомера,
//	|			CustomerSalesForecast.Тариф,
//	|			CustomerSalesForecast.Ресурс,
//	|			CustomerSalesForecast.СпособОплаты,
//	|			CustomerSalesForecast.SalesTurnover,
//	|			CustomerSalesForecast.SalesWithoutVATTurnover,
//	|			CustomerSalesForecast.RoomRevenueTurnover,
//	|			CustomerSalesForecast.RoomRevenueWithoutVATTurnover,
//	|			CustomerSalesForecast.ExtraBedRevenueTurnover,
//	|			CustomerSalesForecast.ExtraBedRevenueWithoutVATTurnover,
//	|			CustomerSalesForecast.RoomRevenueTurnover - CustomerSalesForecast.ExtraBedRevenueTurnover,
//	|			CustomerSalesForecast.RoomRevenueWithoutVATTurnover - CustomerSalesForecast.ExtraBedRevenueWithoutVATTurnover,
//	|			CustomerSalesForecast.CommissionSumTurnover,
//	|			CustomerSalesForecast.CommissionSumWithoutVATTurnover,
//	|			(CustomerSalesForecast.SalesTurnover + CustomerSalesForecast.DiscountSumTurnover) * &qAgentCommission / 100,
//	|			(CustomerSalesForecast.SalesWithoutVATTurnover + CustomerSalesForecast.DiscountSumWithoutVATTurnover) * &qAgentCommission / 100,
//	|			CustomerSalesForecast.DiscountSumTurnover,
//	|			CustomerSalesForecast.DiscountSumWithoutVATTurnover,
//	|			CustomerSalesForecast.RoomsRentedTurnover,
//	|			CustomerSalesForecast.BedsRentedTurnover,
//	|			CustomerSalesForecast.AdditionalBedsRentedTurnover,
//	|			CustomerSalesForecast.GuestDaysTurnover,
//	|			CustomerSalesForecast.GuestsCheckedInTurnover,
//	|			CustomerSalesForecast.RoomsCheckedInTurnover,
//	|			CustomerSalesForecast.BedsCheckedInTurnover,
//	|			CustomerSalesForecast.AdditionalBedsCheckedInTurnover,
//	|			CustomerSalesForecast.QuantityTurnover,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Period,
//	|					&qShowForecastByReservations
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qCustomerIsEmpty)
//	|						AND (Договор IN HIERARCHY (&qContract)
//	|							OR &qContractIsEmpty)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qGuestGroupIsEmpty)
//	|						AND (Агент IN HIERARCHY (&qAgent)
//	|							OR &qAgentIsEmpty)
//	|						AND (Услуга IN (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qByCheckInDates
//	|							OR &qByCheckInDates
//	|								AND ДокОснование.CheckInDate >= &qPeriodFrom
//	|								AND ДокОснование.CheckInDate <= &qPeriodTo)
//	|						AND (NOT &qByCheckOutDates
//	|							OR &qByCheckOutDates
//	|								AND ДокОснование.CheckOutDate >= &qPeriodFrom
//	|								AND ДокОснование.CheckOutDate <= &qPeriodTo)) AS CustomerSalesForecast
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ВзаиморасчетыКонтрагенты.Фирма,
//	|			ВзаиморасчетыКонтрагенты.Гостиница,
//	|			ВзаиморасчетыКонтрагенты.ВалютаРасчетов,
//	|			ВзаиморасчетыКонтрагенты.СчетПроживания.Агент,
//	|			ВзаиморасчетыКонтрагенты.Контрагент,
//	|			ВзаиморасчетыКонтрагенты.Договор,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование,
//	|			CAST(ВзаиморасчетыКонтрагенты.ДокОснование.Примечания AS STRING(1024)),
//	|			ВзаиморасчетыКонтрагенты.ГруппаГостей,
//	|			ВзаиморасчетыКонтрагенты.Клиент,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование.ТипКлиента,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование.TripPurpose,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование.ИсточИнфоГостиница,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование.МаретингНапрвл,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.ДокОснование.CheckInDate IS NULL 
//	|					THEN ВзаиморасчетыКонтрагенты.ДокОснование.DateTimeFrom
//	|				ELSE ВзаиморасчетыКонтрагенты.ДокОснование.CheckInDate
//	|			END,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.ДокОснование.CheckOutDate IS NULL 
//	|					THEN ВзаиморасчетыКонтрагенты.ДокОснование.DateTimeTo
//	|				ELSE ВзаиморасчетыКонтрагенты.ДокОснование.CheckOutDate
//	|			END,
//	|			CASE
//	|				WHEN NOT ВзаиморасчетыКонтрагенты.ДокОснование.СтатусРазмещения IS NULL 
//	|					THEN ВзаиморасчетыКонтрагенты.ДокОснование.СтатусРазмещения
//	|				WHEN NOT ВзаиморасчетыКонтрагенты.ДокОснование.ReservationStatus IS NULL 
//	|					THEN ВзаиморасчетыКонтрагенты.ДокОснование.ReservationStatus
//	|				ELSE ВзаиморасчетыКонтрагенты.ДокОснование.ResourceReservationStatus
//	|			END,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование.ВидРазмещения,
//	|			ВзаиморасчетыКонтрагенты.НомерРазмещения,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование.ТипНомера,
//	|			ВзаиморасчетыКонтрагенты.ДокОснование.Тариф,
//	|			ВзаиморасчетыКонтрагенты.Ресурс,
//	|			ВзаиморасчетыКонтрагенты.СчетПроживания.СпособОплаты,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			ВзаиморасчетыКонтрагенты.Сумма,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.Recorder.СпособОплаты.IsByCash
//	|					THEN ВзаиморасчетыКонтрагенты.Сумма
//	|				ELSE 0
//	|			END,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.Recorder.СпособОплаты.IsByCreditCard
//	|					THEN ВзаиморасчетыКонтрагенты.Сумма
//	|				ELSE 0
//	|			END,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.Recorder.СпособОплаты.IsByBankTransfer
//	|					THEN ВзаиморасчетыКонтрагенты.Сумма
//	|				ELSE 0
//	|			END,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.Recorder.СпособОплаты.IsViaInternetAcquiring
//	|					THEN ВзаиморасчетыКонтрагенты.Сумма
//	|				ELSE 0
//	|			END,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.Recorder.СпособОплаты.IsByBonuses
//	|					THEN ВзаиморасчетыКонтрагенты.Сумма
//	|				ELSE 0
//	|			END,
//	|			CASE
//	|				WHEN ВзаиморасчетыКонтрагенты.Recorder.СпособОплаты.IsByGiftCertificate
//	|					THEN ВзаиморасчетыКонтрагенты.Сумма
//	|				ELSE 0
//	|			END
//	|		FROM
//	|			AccumulationRegister.ВзаиморасчетыКонтрагенты AS ВзаиморасчетыКонтрагенты
//	|		WHERE
//	|			&qShowPayedAmount
//	|			AND NOT ВзаиморасчетыКонтрагенты.Recorder REFS Document.Акт
//	|			AND ВзаиморасчетыКонтрагенты.Гостиница IN HIERARCHY(&qHotel)
//	|			AND (ВзаиморасчетыКонтрагенты.Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qCustomerIsEmpty)
//	|			AND (ВзаиморасчетыКонтрагенты.Договор IN HIERARCHY (&qContract)
//	|					OR &qContractIsEmpty)
//	|			AND (ВзаиморасчетыКонтрагенты.ГруппаГостей = &qGuestGroup
//	|					OR &qGuestGroupIsEmpty)
//	|			AND ВзаиморасчетыКонтрагенты.ГруппаГостей IN
//	|					(SELECT
//	|						ГруппыГостей.ГруппаГостей
//	|					FROM
//	|						ГруппыГостей AS GuestGroups)) AS CustomerTurnovers
//	|			LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, ) AS ForeignerRegistryRecords
//	|			ON CustomerTurnovers.ДокОснование = ForeignerRegistryRecords.Размещение
//	|	
//	|	GROUP BY
//	|		CustomerTurnovers.Фирма,
//	|		CustomerTurnovers.Гостиница,
//	|		CustomerTurnovers.Валюта,
//	|		CustomerTurnovers.Агент,
//	|		CASE
//	|			WHEN CustomerTurnovers.Контрагент = &qEmptyCustomer
//	|				THEN CustomerTurnovers.Гостиница.IndividualsCustomer
//	|			ELSE CustomerTurnovers.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN CustomerTurnovers.Контрагент = &qEmptyCustomer
//	|				THEN CustomerTurnovers.Гостиница.IndividualsContract
//	|			ELSE CustomerTurnovers.Договор
//	|		END,
//	|		CustomerTurnovers.ГруппаГостей,
//	|		CustomerTurnovers.Клиент,
//	|		CustomerTurnovers.ТипКлиента,
//	|		CustomerTurnovers.TripPurpose,
//	|		CustomerTurnovers.ИсточИнфоГостиница,
//	|		CustomerTurnovers.МаретингНапрвл,
//	|		CustomerTurnovers.CheckInDate,
//	|		CustomerTurnovers.CheckOutDate,
//	|		CustomerTurnovers.ВидРазмещения,
//	|		CustomerTurnovers.Status,
//	|		CustomerTurnovers.НомерРазмещения,
//	|		CustomerTurnovers.ТипНомера,
//	|		CustomerTurnovers.Ресурс,
//	|		CustomerTurnovers.Тариф,
//	|		CustomerTurnovers.ДокОснование,
//	|		CustomerTurnovers.СпособОплаты,
//	|		CustomerTurnovers.Примечания,
//	|		ForeignerRegistryRecords.ForeignerRegistryRecord) AS CustomerSales
//	|{WHERE
//	|	CustomerSales.Фирма.*,
//	|	CustomerSales.Гостиница.*,
//	|	CustomerSales.Валюта.*,
//	|	CustomerSales.Контрагент.*,
//	|	CustomerSales.Договор.*,
//	|	CustomerSales.ГруппаГостей.*,
//	|	CustomerSales.Агент.*,
//	|	CustomerSales.Клиент.*,
//	|	CustomerSales.ТипКлиента.* AS ТипКлиента,
//	|	CustomerSales.TripPurpose.* AS TripPurpose,
//	|	CustomerSales.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	CustomerSales.МаретингНапрвл.* AS МаретингНапрвл,
//	|	CustomerSales.CheckInDate,
//	|	CustomerSales.CheckOutDate,
//	|	CustomerSales.ВидРазмещения.*,
//	|	CustomerSales.Status.*,
//	|	CustomerSales.НомерРазмещения.*,
//	|	CustomerSales.ТипНомера.*,
//	|	CustomerSales.Ресурс.*,
//	|	CustomerSales.Тариф.*,
//	|	CustomerSales.ДокОснование.*,
//	|	CustomerSales.Примечания AS Примечания,
//	|	CustomerSales.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	CustomerSales.СпособОплаты.*,
//	|	CustomerSales.Продажи,
//	|	CustomerSales.ПродажиБезНДС,
//	|	CustomerSales.ДоходНомеров,
//	|	CustomerSales.ДоходПродажиБезНДС,
//	|	CustomerSales.ДоходДопМеста,
//	|	CustomerSales.ДоходДопМестаБезНДС,
//	|	CustomerSales.MainBedsRevenue,
//	|	CustomerSales.MainBedsRevenueWithoutVAT,
//	|	CustomerSales.СуммаКомиссии,
//	|	CustomerSales.КомиссияБезНДС,
//	|	CustomerSales.CalculatedCommissionSum,
//	|	CustomerSales.CalculatedCommissionSumWithoutVAT,
//	|	CustomerSales.СуммаСкидки,
//	|	CustomerSales.СуммаСкидкиБезНДС,
//	|	CustomerSales.ПроданоНомеров,
//	|	CustomerSales.ПроданоМест,
//	|	CustomerSales.ПроданоДопМест,
//	|	CustomerSales.ЧеловекаДни,
//	|	CustomerSales.ЗаездГостей,
//	|	CustomerSales.ЗаездНомеров,
//	|	CustomerSales.ЗаездМест,
//	|	CustomerSales.ЗаездДополнительныхМест,
//	|	CustomerSales.Количество,
//	|	CustomerSales.PayedAmount,
//	|	CustomerSales.PayedByCashAmount,
//	|	CustomerSales.PayedByCreditCardAmount,
//	|	CustomerSales.PayedByBankTransferAmount,
//	|	CustomerSales.PayedByInternetAcquiringAmount,
//	|	CustomerSales.PayedByBonusesAmount,
//	|	CustomerSales.PayedByGiftCertificatesAmount}
//	|
//	|ORDER BY
//	|	Фирма,
//	|	Гостиница,
//	|	Валюта,
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	TripPurpose.* AS TripPurpose,
//	|	ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	МаретингНапрвл.* AS МаретингНапрвл,
//	|	Агент.*,
//	|	CheckInDate,
//	|	CheckOutDate,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	Тариф.*,
//	|	ДокОснование.*,
//	|	CustomerSales.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	СпособОплаты.*,
//	|	Продажи,
//	|	ПродажиБезНДС,
//	|	ДоходНомеров,
//	|	ДоходПродажиБезНДС,
//	|	ДоходДопМеста,
//	|	ДоходДопМестаБезНДС,
//	|	MainBedsRevenue,
//	|	MainBedsRevenueWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	CalculatedCommissionSum,
//	|	CalculatedCommissionSumWithoutVAT,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	BruttoSales,
//	|	BruttoSalesWithoutVAT,
//	|	SalesWithoutCommission,
//	|	SalesWithoutCommissionWithoutVAT,
//	|	SalesWithoutCalculatedCommission,
//	|	SalesWithoutCalculatedCommissionWithoutVAT,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Количество,
//	|	PayedAmount,
//	|	PayedByCashAmount,
//	|	PayedByCreditCardAmount,
//	|	PayedByBankTransferAmount,
//	|	PayedByInternetAcquiringAmount,
//	|	PayedByBonusesAmount,
//	|	PayedByGiftCertificatesAmount}
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходНомеров),
//	|	SUM(RoomRevenueWithoutCommission),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(RoomRevenueWithoutVATWithoutCommission),
//	|	SUM(ДоходДопМеста),
//	|	SUM(ДоходДопМестаБезНДС),
//	|	SUM(MainBedsRevenue),
//	|	SUM(MainBedsRevenueWithoutVAT),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(CalculatedCommissionSum),
//	|	SUM(CalculatedCommissionSumWithoutVAT),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(BruttoSales),
//	|	SUM(BruttoSalesWithoutVAT),
//	|	SUM(SalesWithoutCommission),
//	|	SUM(SalesWithoutCommissionWithoutVAT),
//	|	SUM(SalesWithoutCalculatedCommission),
//	|	SUM(SalesWithoutCalculatedCommissionWithoutVAT),
//	|	SUM(ПроданоНомеров),
//	|	SUM(ПроданоМест),
//	|	SUM(ПроданоДопМест),
//	|	SUM(ЧеловекаДни),
//	|	SUM(ЗаездГостей),
//	|	SUM(ЗаездНомеров),
//	|	SUM(ЗаездМест),
//	|	SUM(ЗаездДополнительныхМест),
//	|	SUM(Количество),
//	|	SUM(PayedAmount),
//	|	SUM(PayedByCashAmount),
//	|	SUM(PayedByCreditCardAmount),
//	|	SUM(PayedByBankTransferAmount),
//	|	SUM(PayedByInternetAcquiringAmount),
//	|	SUM(PayedByBonusesAmount),
//	|	SUM(PayedByGiftCertificatesAmount)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	Валюта,
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей
//	|{TOTALS BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	TripPurpose.* AS TripPurpose,
//	|	ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	МаретингНапрвл.* AS МаретингНапрвл,
//	|	НомерРазмещения.*,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	ТипНомера.*,
//	|	Тариф.*,
//	|	Ресурс.*,
//	|	СпособОплаты.*,
//	|	CustomerSales.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	ДокОснование.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Контрагент sales';RU='Продажи по гостям оплачиваемым контрагентами';de='Verkäufe nach Gästen, die vom Vertragspartner bezahlt werden'");
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
