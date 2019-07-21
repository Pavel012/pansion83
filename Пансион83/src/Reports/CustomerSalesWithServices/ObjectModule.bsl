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
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qContractIsEmpty", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qAgent", Agent);
//	ReportBuilder.Parameters.Вставить("qAgentIsEmpty", НЕ ЗначениеЗаполнено(Agent));
//	ReportBuilder.Parameters.Вставить("qAgentCommission", AgentCommission);
//	ReportBuilder.Parameters.Вставить("qByDays", ByDays);
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231');
//	ReportBuilder.Parameters.Вставить("qShowForecastByReservations", ShowForecastByReservations);
//	
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
//	|	CustomerTurnovers.Фирма AS Фирма,
//	|	CustomerTurnovers.Гостиница AS Гостиница,
//	|	CustomerTurnovers.Валюта AS Валюта,
//	|	CustomerTurnovers.Агент AS Агент,
//	|	CustomerTurnovers.Контрагент AS Контрагент,
//	|	CustomerTurnovers.Договор AS Договор,
//	|	CustomerTurnovers.ГруппаГостей AS ГруппаГостей,
//	|	CustomerTurnovers.ДокОснование AS ДокОснование,
//	|	CustomerTurnovers.Клиент AS Клиент,
//	|	CustomerTurnovers.ТипКлиента AS ТипКлиента,
//	|	CustomerTurnovers.TripPurpose AS TripPurpose,
//	|	CustomerTurnovers.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	CustomerTurnovers.МаретингНапрвл AS МаретингНапрвл,
//	|	CustomerTurnovers.CheckInDate AS CheckInDate,
//	|	CustomerTurnovers.CheckOutDate AS CheckOutDate,
//	|	CustomerTurnovers.ВидРазмещения AS ВидРазмещения,
//	|	CustomerTurnovers.Status AS Status,
//	|	CustomerTurnovers.НомерРазмещения AS НомерРазмещения,
//	|	CustomerTurnovers.ТипНомера AS ТипНомера,
//	|	CustomerTurnovers.Ресурс AS Ресурс,
//	|	CustomerTurnovers.Услуга AS Услуга,
//	|	CustomerTurnovers.УчетнаяДата AS УчетнаяДата,
//	|	CustomerTurnovers.Продажи AS Продажи,
//	|	CustomerTurnovers.ПродажиБезНДС AS ПродажиБезНДС,
//	|	CustomerTurnovers.ДоходНомеров AS ДоходНомеров,
//	|	CustomerTurnovers.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	CustomerTurnovers.ДоходДопМеста AS ДоходДопМеста,
//	|	CustomerTurnovers.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	CustomerTurnovers.MainBedsRevenue AS MainBedsRevenue,
//	|	CustomerTurnovers.MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	CustomerTurnovers.СуммаКомиссии AS СуммаКомиссии,
//	|	CustomerTurnovers.КомиссияБезНДС AS КомиссияБезНДС,
//	|	CustomerTurnovers.CalculatedCommissionSum AS CalculatedCommissionSum,
//	|	CustomerTurnovers.CalculatedCommissionSumWithoutVAT AS CalculatedCommissionSumWithoutVAT,
//	|	CustomerTurnovers.SalesWithoutCommission AS SalesWithoutCommission,
//	|	CustomerTurnovers.SalesWithoutCommissionWithoutVAT AS SalesWithoutCommissionWithoutVAT,
//	|	(CustomerTurnovers.Продажи + CustomerTurnovers.СуммаСкидки - CustomerTurnovers.CalculatedCommissionSum) AS SalesWithoutCalculatedCommission,
//	|	(CustomerTurnovers.ПродажиБезНДС + CustomerTurnovers.СуммаСкидкиБезНДС - CustomerTurnovers.CalculatedCommissionSumWithoutVAT) AS SalesWithoutCalculatedCommissionWithoutVAT,
//	|	CustomerTurnovers.BruttoSales AS BruttoSales,
//	|	CustomerTurnovers.BruttoSalesWithoutVAT AS BruttoSalesWithoutVAT,
//	|	CustomerTurnovers.СуммаСкидки AS СуммаСкидки,
//	|	CustomerTurnovers.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	CustomerTurnovers.ПроданоНомеров AS ПроданоНомеров,
//	|	CustomerTurnovers.ПроданоМест AS ПроданоМест,
//	|	CustomerTurnovers.ПроданоДопМест AS ПроданоДопМест,
//	|	CustomerTurnovers.ЧеловекаДни AS ЧеловекаДни,
//	|	CustomerTurnovers.ЗаездГостей AS ЗаездГостей,
//	|	CustomerTurnovers.ЗаездНомеров AS ЗаездНомеров,
//	|	CustomerTurnovers.ЗаездМест AS ЗаездМест,
//	|	CustomerTurnovers.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	CustomerTurnovers.Количество AS Количество
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
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.СпособОплаты.* AS СпособОплаты,
//	|	ДокОснование.*,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	Услуга.*,
//	|	УчетнаяДата,
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
//	|	SalesWithoutCommission,
//	|	SalesWithoutCommissionWithoutVAT,
//	|	SalesWithoutCalculatedCommission,
//	|	SalesWithoutCalculatedCommissionWithoutVAT,
//	|	BruttoSales,
//	|	BruttoSalesWithoutVAT,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Quantity}
//	|FROM
//	|	(SELECT
//	|		CustomerSales.Фирма AS Фирма,
//	|		CustomerSales.Гостиница AS Гостиница,
//	|		CustomerSales.Валюта AS Валюта,
//	|		CustomerSales.Агент AS Агент,
//	|		CASE
//	|			WHEN CustomerSales.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSales.Гостиница.IndividualsCustomer
//	|			ELSE CustomerSales.Контрагент
//	|		END AS Контрагент,
//	|		CASE
//	|			WHEN CustomerSales.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSales.Гостиница.IndividualsContract
//	|			ELSE CustomerSales.Договор
//	|		END AS Договор,
//	|		CustomerSales.ГруппаГостей AS ГруппаГостей,
//	|		CustomerSales.ДокОснование AS ДокОснование,
//	|		CustomerSales.Услуга AS Услуга,
//	|		CASE
//	|			WHEN &qByDays
//	|				THEN CustomerSales.УчетнаяДата
//	|			ELSE &qEmptyDate
//	|		END AS УчетнаяДата,
//	|		CustomerSales.Клиент AS Клиент,
//	|		CustomerSales.ТипКлиента AS ТипКлиента,
//	|		CustomerSales.TripPurpose AS TripPurpose,
//	|		CustomerSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		CustomerSales.МаретингНапрвл AS МаретингНапрвл,
//	|		CASE
//	|			WHEN CustomerSales.ДокОснование.CheckInDate IS NULL 
//	|				THEN CustomerSales.ДокОснование.DateTimeFrom
//	|			ELSE CustomerSales.ДокОснование.CheckInDate
//	|		END AS CheckInDate,
//	|		CASE
//	|			WHEN CustomerSales.ДокОснование.CheckOutDate IS NULL 
//	|				THEN CustomerSales.ДокОснование.DateTimeTo
//	|			ELSE CustomerSales.ДокОснование.CheckOutDate
//	|		END AS CheckOutDate,
//	|		CASE
//	|			WHEN NOT CustomerSales.ДокОснование.СтатусРазмещения IS NULL 
//	|				THEN CustomerSales.ДокОснование.СтатусРазмещения
//	|			WHEN NOT CustomerSales.ДокОснование.ReservationStatus IS NULL 
//	|				THEN CustomerSales.ДокОснование.ReservationStatus
//	|			ELSE CustomerSales.ДокОснование.ResourceReservationStatus
//	|		END AS Status,
//	|		CustomerSales.ВидРазмещения AS ВидРазмещения,
//	|		CustomerSales.НомерРазмещения AS НомерРазмещения,
//	|		CustomerSales.ТипНомера AS ТипНомера,
//	|		CustomerSales.Ресурс AS Ресурс,
//	|		CustomerSales.Тариф AS Тариф,
//	|		CustomerSales.СпособОплаты AS СпособОплаты,
//	|		SUM(CustomerSales.SalesTurnover) AS Продажи,
//	|		SUM(CustomerSales.SalesWithoutVATTurnover) AS ПродажиБезНДС,
//	|		SUM(CustomerSales.RoomRevenueTurnover) AS ДоходНомеров,
//	|		SUM(CustomerSales.RoomRevenueWithoutVATTurnover) AS ДоходПродажиБезНДС,
//	|		SUM(CustomerSales.ExtraBedRevenueTurnover) AS ДоходДопМеста,
//	|		SUM(CustomerSales.ExtraBedRevenueWithoutVATTurnover) AS ДоходДопМестаБезНДС,
//	|		SUM(CustomerSales.RoomRevenueTurnover) - SUM(CustomerSales.ExtraBedRevenueTurnover) AS MainBedsRevenue,
//	|		SUM(CustomerSales.RoomRevenueWithoutVATTurnover) - SUM(CustomerSales.ExtraBedRevenueWithoutVATTurnover) AS MainBedsRevenueWithoutVAT,
//	|		SUM(CustomerSales.CommissionSumTurnover) AS СуммаКомиссии,
//	|		SUM(CustomerSales.CommissionSumWithoutVATTurnover) AS КомиссияБезНДС,
//	|		SUM((CustomerSales.SalesTurnover + CustomerSales.DiscountSumTurnover) * &qAgentCommission / 100) AS CalculatedCommissionSum,
//	|		SUM((CustomerSales.SalesWithoutVATTurnover + CustomerSales.DiscountSumWithoutVATTurnover) * &qAgentCommission / 100) AS CalculatedCommissionSumWithoutVAT,
//	|		SUM(CustomerSales.SalesTurnover) + SUM(CustomerSales.DiscountSumTurnover) AS BruttoSales,
//	|		SUM(CustomerSales.SalesWithoutVATTurnover) + SUM(CustomerSales.DiscountSumWithoutVATTurnover) AS BruttoSalesWithoutVAT,
//	|		SUM(CustomerSales.SalesTurnover) - SUM(CustomerSales.CommissionSumTurnover) AS SalesWithoutCommission,
//	|		SUM(CustomerSales.SalesWithoutVATTurnover) - SUM(CustomerSales.CommissionSumWithoutVATTurnover) AS SalesWithoutCommissionWithoutVAT,
//	|		SUM(CustomerSales.DiscountSumTurnover) AS СуммаСкидки,
//	|		SUM(CustomerSales.DiscountSumWithoutVATTurnover) AS СуммаСкидкиБезНДС,
//	|		SUM(CustomerSales.RoomsRentedTurnover) AS ПроданоНомеров,
//	|		SUM(CustomerSales.BedsRentedTurnover) AS ПроданоМест,
//	|		SUM(CustomerSales.AdditionalBedsRentedTurnover) AS ПроданоДопМест,
//	|		SUM(CustomerSales.GuestDaysTurnover) AS ЧеловекаДни,
//	|		SUM(CustomerSales.GuestsCheckedInTurnover) AS ЗаездГостей,
//	|		SUM(CustomerSales.RoomsCheckedInTurnover) AS ЗаездНомеров,
//	|		SUM(CustomerSales.BedsCheckedInTurnover) AS ЗаездМест,
//	|		SUM(CustomerSales.AdditionalBedsCheckedInTurnover) AS ЗаездДополнительныхМест,
//	|		SUM(CustomerSales.QuantityTurnover) AS Количество
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qServicesPeriodFrom,
//	|				&qServicesPeriodTo,
////	|				Period,
//	|				" + ?(ByDays, "Day, ", "Period, ") + "
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
//	|	GROUP BY
//	|		CustomerSales.Фирма,
//	|		CustomerSales.Гостиница,
//	|		CustomerSales.Валюта,
//	|		CustomerSales.Агент,
//	|		CASE
//	|			WHEN CustomerSales.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSales.Гостиница.IndividualsCustomer
//	|			ELSE CustomerSales.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN CustomerSales.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSales.Гостиница.IndividualsContract
//	|			ELSE CustomerSales.Договор
//	|		END,
//	|		CustomerSales.ГруппаГостей,
//	|		CustomerSales.ДокОснование,
//	|		CustomerSales.Услуга,
//	|		CustomerSales.Клиент,
//	|		CustomerSales.ТипКлиента,
//	|		CustomerSales.TripPurpose,
//	|		CustomerSales.ИсточИнфоГостиница,
//	|		CustomerSales.МаретингНапрвл,
//	|		CASE
//	|			WHEN CustomerSales.ДокОснование.CheckInDate IS NULL 
//	|				THEN CustomerSales.ДокОснование.DateTimeFrom
//	|			ELSE CustomerSales.ДокОснование.CheckInDate
//	|		END,
//	|		CASE
//	|			WHEN CustomerSales.ДокОснование.CheckOutDate IS NULL 
//	|				THEN CustomerSales.ДокОснование.DateTimeTo
//	|			ELSE CustomerSales.ДокОснование.CheckOutDate
//	|		END,
//	|		CASE
//	|			WHEN NOT CustomerSales.ДокОснование.СтатусРазмещения IS NULL 
//	|				THEN CustomerSales.ДокОснование.СтатусРазмещения
//	|			WHEN NOT CustomerSales.ДокОснование.ReservationStatus IS NULL 
//	|				THEN CustomerSales.ДокОснование.ReservationStatus
//	|			ELSE CustomerSales.ДокОснование.ResourceReservationStatus
//	|		END,
//	|		CASE
//	|			WHEN &qByDays
//	|				THEN CustomerSales.УчетнаяДата
//	|			ELSE &qEmptyDate
//	|		END,
//	|		CustomerSales.ВидРазмещения,
//	|		CustomerSales.НомерРазмещения,
//	|		CustomerSales.ТипНомера,
//	|		CustomerSales.Ресурс,
//	|		CustomerSales.Тариф,
//	|		CustomerSales.СпособОплаты
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		CustomerSalesForecast.Фирма,
//	|		CustomerSalesForecast.Гостиница,
//	|		CustomerSalesForecast.Валюта,
//	|		CustomerSalesForecast.Агент,
//	|		CASE
//	|			WHEN CustomerSalesForecast.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSalesForecast.Гостиница.IndividualsCustomer
//	|			ELSE CustomerSalesForecast.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN CustomerSalesForecast.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSalesForecast.Гостиница.IndividualsContract
//	|			ELSE CustomerSalesForecast.Договор
//	|		END,
//	|		CustomerSalesForecast.ГруппаГостей,
//	|		CustomerSalesForecast.ДокОснование,
//	|		CustomerSalesForecast.Услуга,
//	|		CASE
//	|			WHEN &qByDays
//	|				THEN CustomerSalesForecast.УчетнаяДата
//	|			ELSE &qEmptyDate
//	|		END,
//	|		CustomerSalesForecast.Клиент,
//	|		CustomerSalesForecast.ТипКлиента,
//	|		CustomerSalesForecast.TripPurpose,
//	|		CustomerSalesForecast.ИсточИнфоГостиница,
//	|		CustomerSalesForecast.МаретингНапрвл,
//	|		CASE
//	|			WHEN CustomerSalesForecast.ДокОснование.CheckInDate IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.DateTimeFrom
//	|			ELSE CustomerSalesForecast.ДокОснование.CheckInDate
//	|		END,
//	|		CASE
//	|			WHEN CustomerSalesForecast.ДокОснование.CheckOutDate IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.DateTimeTo
//	|			ELSE CustomerSalesForecast.ДокОснование.CheckOutDate
//	|		END,
//	|		CASE
//	|			WHEN NOT CustomerSalesForecast.ДокОснование.СтатусРазмещения IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.СтатусРазмещения
//	|			WHEN NOT CustomerSalesForecast.ДокОснование.ReservationStatus IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.ReservationStatus
//	|			ELSE CustomerSalesForecast.ДокОснование.ResourceReservationStatus
//	|		END,
//	|		CustomerSalesForecast.ВидРазмещения,
//	|		CustomerSalesForecast.НомерРазмещения,
//	|		CustomerSalesForecast.ТипНомера,
//	|		CustomerSalesForecast.Ресурс,
//	|		CustomerSalesForecast.Тариф,
//	|		CustomerSalesForecast.СпособОплаты,
//	|		SUM(CustomerSalesForecast.SalesTurnover),
//	|		SUM(CustomerSalesForecast.SalesWithoutVATTurnover),
//	|		SUM(CustomerSalesForecast.RoomRevenueTurnover),
//	|		SUM(CustomerSalesForecast.RoomRevenueWithoutVATTurnover),
//	|		SUM(CustomerSalesForecast.ExtraBedRevenueTurnover),
//	|		SUM(CustomerSalesForecast.ExtraBedRevenueWithoutVATTurnover),
//	|		SUM(CustomerSalesForecast.RoomRevenueTurnover) - SUM(CustomerSalesForecast.ExtraBedRevenueTurnover),
//	|		SUM(CustomerSalesForecast.RoomRevenueWithoutVATTurnover) - SUM(CustomerSalesForecast.ExtraBedRevenueWithoutVATTurnover),
//	|		SUM(CustomerSalesForecast.CommissionSumTurnover),
//	|		SUM(CustomerSalesForecast.CommissionSumWithoutVATTurnover),
//	|		SUM((CustomerSalesForecast.SalesTurnover + CustomerSalesForecast.DiscountSumTurnover) * &qAgentCommission / 100),
//	|		SUM((CustomerSalesForecast.SalesWithoutVATTurnover + CustomerSalesForecast.DiscountSumWithoutVATTurnover) * &qAgentCommission / 100),
//	|		SUM(CustomerSalesForecast.SalesTurnover) + SUM(CustomerSalesForecast.DiscountSumTurnover),
//	|		SUM(CustomerSalesForecast.SalesWithoutVATTurnover) + SUM(CustomerSalesForecast.DiscountSumWithoutVATTurnover),
//	|		SUM(CustomerSalesForecast.SalesTurnover) - SUM(CustomerSalesForecast.CommissionSumTurnover),
//	|		SUM(CustomerSalesForecast.SalesWithoutVATTurnover) - SUM(CustomerSalesForecast.CommissionSumWithoutVATTurnover),
//	|		SUM(CustomerSalesForecast.DiscountSumTurnover),
//	|		SUM(CustomerSalesForecast.DiscountSumWithoutVATTurnover),
//	|		SUM(CustomerSalesForecast.RoomsRentedTurnover),
//	|		SUM(CustomerSalesForecast.BedsRentedTurnover),
//	|		SUM(CustomerSalesForecast.AdditionalBedsRentedTurnover),
//	|		SUM(CustomerSalesForecast.GuestDaysTurnover),
//	|		SUM(CustomerSalesForecast.GuestsCheckedInTurnover),
//	|		SUM(CustomerSalesForecast.RoomsCheckedInTurnover),
//	|		SUM(CustomerSalesForecast.BedsCheckedInTurnover),
//	|		SUM(CustomerSalesForecast.AdditionalBedsCheckedInTurnover),
//	|		SUM(CustomerSalesForecast.QuantityTurnover)
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qServicesPeriodFrom,
//	|				&qServicesPeriodTo,
////	|				Period,
//	|				" + ?(ByDays, "Day, ", "Period, ") + "
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
//	|							AND ДокОснование.CheckOutDate <= &qPeriodTo)) AS CustomerSalesForecast
//	|	
//	|	GROUP BY
//	|		CustomerSalesForecast.Фирма,
//	|		CustomerSalesForecast.Гостиница,
//	|		CustomerSalesForecast.Валюта,
//	|		CustomerSalesForecast.Агент,
//	|		CASE
//	|			WHEN CustomerSalesForecast.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSalesForecast.Гостиница.IndividualsCustomer
//	|			ELSE CustomerSalesForecast.Контрагент
//	|		END,
//	|		CASE
//	|			WHEN CustomerSalesForecast.Контрагент = &qEmptyCustomer
//	|				THEN CustomerSalesForecast.Гостиница.IndividualsContract
//	|			ELSE CustomerSalesForecast.Договор
//	|		END,
//	|		CustomerSalesForecast.ГруппаГостей,
//	|		CustomerSalesForecast.ДокОснование,
//	|		CustomerSalesForecast.Услуга,
//	|		CustomerSalesForecast.Клиент,
//	|		CustomerSalesForecast.ТипКлиента,
//	|		CustomerSalesForecast.TripPurpose,
//	|		CustomerSalesForecast.ИсточИнфоГостиница,
//	|		CustomerSalesForecast.МаретингНапрвл,
//	|		CASE
//	|			WHEN CustomerSalesForecast.ДокОснование.CheckInDate IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.DateTimeFrom
//	|			ELSE CustomerSalesForecast.ДокОснование.CheckInDate
//	|		END,
//	|		CASE
//	|			WHEN CustomerSalesForecast.ДокОснование.CheckOutDate IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.DateTimeTo
//	|			ELSE CustomerSalesForecast.ДокОснование.CheckOutDate
//	|		END,
//	|		CASE
//	|			WHEN NOT CustomerSalesForecast.ДокОснование.СтатусРазмещения IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.СтатусРазмещения
//	|			WHEN NOT CustomerSalesForecast.ДокОснование.ReservationStatus IS NULL 
//	|				THEN CustomerSalesForecast.ДокОснование.ReservationStatus
//	|			ELSE CustomerSalesForecast.ДокОснование.ResourceReservationStatus
//	|		END,
//	|		CASE
//	|			WHEN &qByDays
//	|				THEN CustomerSalesForecast.УчетнаяДата
//	|			ELSE &qEmptyDate
//	|		END,
//	|		CustomerSalesForecast.ВидРазмещения,
//	|		CustomerSalesForecast.НомерРазмещения,
//	|		CustomerSalesForecast.ТипНомера,
//	|		CustomerSalesForecast.Ресурс,
//	|		CustomerSalesForecast.Тариф,
//	|		CustomerSalesForecast.СпособОплаты) AS CustomerTurnovers
//	|		LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, ) AS ForeignerRegistryRecords
//	|		ON CustomerTurnovers.ДокОснование = ForeignerRegistryRecords.Размещение
//	|{WHERE
//	|	CustomerTurnovers.Фирма.*,
//	|	CustomerTurnovers.Гостиница.*,
//	|	CustomerTurnovers.Валюта.*,
//	|	CustomerTurnovers.Агент.*,
//	|	CustomerTurnovers.Контрагент.*,
//	|	CustomerTurnovers.Договор.*,
//	|	CustomerTurnovers.ГруппаГостей.*,
//	|	CustomerTurnovers.ДокОснование.*,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	CustomerTurnovers.Клиент.* AS Клиент,
//	|	CustomerTurnovers.ТипКлиента.* AS ТипКлиента,
//	|	CustomerTurnovers.TripPurpose.* AS TripPurpose,
//	|	CustomerTurnovers.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	CustomerTurnovers.МаретингНапрвл.* AS МаретингНапрвл,
//	|	CustomerTurnovers.CheckInDate AS CheckInDate,
//	|	CustomerTurnovers.CheckOutDate AS CheckOutDate,
//	|	CustomerTurnovers.ВидРазмещения.* AS ВидРазмещения,
//	|	CustomerTurnovers.Status.* AS Status,
//	|	CustomerTurnovers.НомерРазмещения.* AS НомерРазмещения,
//	|	CustomerTurnovers.ТипНомера.* AS ТипНомера,
//	|	CustomerTurnovers.Ресурс.* AS Ресурс,
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.СпособОплаты.* AS СпособОплаты,
//	|	CustomerTurnovers.Услуга.*,
//	|	CustomerTurnovers.УчетнаяДата AS УчетнаяДата,
//	|	CustomerTurnovers.Продажи,
//	|	CustomerTurnovers.ПродажиБезНДС,
//	|	CustomerTurnovers.ДоходНомеров,
//	|	CustomerTurnovers.ДоходПродажиБезНДС,
//	|	CustomerTurnovers.ДоходДопМеста,
//	|	CustomerTurnovers.ДоходДопМестаБезНДС,
//	|	CustomerTurnovers.MainBedsRevenue,
//	|	CustomerTurnovers.MainBedsRevenueWithoutVAT,
//	|	CustomerTurnovers.СуммаКомиссии,
//	|	CustomerTurnovers.КомиссияБезНДС,
//	|	CustomerTurnovers.CalculatedCommissionSum,
//	|	CustomerTurnovers.CalculatedCommissionSumWithoutVAT,
//	|	CustomerTurnovers.SalesWithoutCommission,
//	|	CustomerTurnovers.SalesWithoutCommissionWithoutVAT,
//	|	CustomerTurnovers.BruttoSales,
//	|	CustomerTurnovers.BruttoSalesWithoutVAT,
//	|	CustomerTurnovers.СуммаСкидки,
//	|	CustomerTurnovers.СуммаСкидкиБезНДС,
//	|	CustomerTurnovers.ПроданоНомеров,
//	|	CustomerTurnovers.ПроданоМест,
//	|	CustomerTurnovers.ПроданоДопМест,
//	|	CustomerTurnovers.ЧеловекаДни,
//	|	CustomerTurnovers.ЗаездГостей,
//	|	CustomerTurnovers.ЗаездНомеров,
//	|	CustomerTurnovers.ЗаездМест,
//	|	CustomerTurnovers.ЗаездДополнительныхМест,
//	|	CustomerTurnovers.Quantity}
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
//	|	Клиент,
//	|	Услуга,
//	|	УчетнаяДата
//	|{ORDER BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Агент.*,
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
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.СпособОплаты.* AS СпособОплаты,
//	|	ДокОснование.*,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	Услуга.*,
//	|	УчетнаяДата,
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
//	|	BruttoSales,
//	|	BruttoSalesWithoutVAT,
//	|	SalesWithoutCommission,
//	|	SalesWithoutCommissionWithoutVAT,
//	|	SalesWithoutCalculatedCommission,
//	|	SalesWithoutCalculatedCommissionWithoutVAT,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Quantity}
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходНомеров),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(ДоходДопМеста),
//	|	SUM(ДоходДопМестаБезНДС),
//	|	SUM(MainBedsRevenue),
//	|	SUM(MainBedsRevenueWithoutVAT),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(CalculatedCommissionSum),
//	|	SUM(CalculatedCommissionSumWithoutVAT),
//	|	SUM(SalesWithoutCommission),
//	|	SUM(SalesWithoutCommissionWithoutVAT),
//	|	SUM(SalesWithoutCalculatedCommission),
//	|	SUM(SalesWithoutCalculatedCommissionWithoutVAT),
//	|	SUM(BruttoSales),
//	|	SUM(BruttoSalesWithoutVAT),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ПроданоНомеров),
//	|	SUM(ПроданоМест),
//	|	SUM(ПроданоДопМест),
//	|	SUM(ЧеловекаДни),
//	|	SUM(ЗаездГостей),
//	|	SUM(ЗаездНомеров),
//	|	SUM(ЗаездМест),
//	|	SUM(ЗаездДополнительныхМест),
//	|	SUM(Количество)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	Валюта,
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	ДокОснование
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
//	|	Ресурс.*,
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.СпособОплаты.* AS СпособОплаты,
//	|	Услуга.*,
//	|	УчетнаяДата,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
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
//	ReportBuilder.HeaderText = NStr("EN='Контрагент sales with services';RU='Сводка по оказанным контрагентам услугам';de='Sammelbericht nach den Vertragspartnern geleisteten Diensten'");
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
