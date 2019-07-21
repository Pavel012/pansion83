////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------
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
//	|	CASE
//	|		WHEN CustomerTurnovers.ДокОснование.Клиент IS NULL 
//	|			THEN CustomerTurnovers.ДокОснование.Клиент
//	|		ELSE CustomerTurnovers.ДокОснование.Клиент
//	|	END AS Клиент,
//	|	CASE
//	|		WHEN CustomerTurnovers.ДокОснование.CheckInDate IS NULL 
//	|			THEN CustomerTurnovers.ДокОснование.DateTimeFrom
//	|		ELSE CustomerTurnovers.ДокОснование.CheckInDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN CustomerTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|			THEN CustomerTurnovers.ДокОснование.DateTimeTo
//	|		ELSE CustomerTurnovers.ДокОснование.CheckOutDate
//	|	END AS CheckOutDate,
//	|	CustomerTurnovers.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	CASE
//	|		WHEN (NOT CustomerTurnovers.ДокОснование.СтатусРазмещения IS NULL )
//	|			THEN CustomerTurnovers.ДокОснование.СтатусРазмещения
//	|		WHEN (NOT CustomerTurnovers.ДокОснование.ReservationStatus IS NULL )
//	|			THEN CustomerTurnovers.ДокОснование.ReservationStatus
//	|		ELSE CustomerTurnovers.ДокОснование.ResourceReservationStatus
//	|	END AS Status,
//	|	CustomerTurnovers.ДокОснование.НомерРазмещения AS НомерРазмещения,
//	|	CustomerTurnovers.ДокОснование.ТипНомера AS ТипНомера,
//	|	CustomerTurnovers.ДокОснование.Ресурс AS Ресурс,
//	|	CustomerTurnovers.Услуга AS Услуга,
//	|	SUM(CustomerTurnovers.Продажи) AS Продажи,
//	|	SUM(CustomerTurnovers.ПродажиБезНДС) AS ПродажиБезНДС,
//	|	SUM(CustomerTurnovers.ДоходНомеров) AS ДоходНомеров,
//	|	SUM(CustomerTurnovers.ДоходПродажиБезНДС) AS ДоходПродажиБезНДС,
//	|	SUM(CustomerTurnovers.СуммаКомиссии) AS СуммаКомиссии,
//	|	SUM(CustomerTurnovers.КомиссияБезНДС) AS КомиссияБезНДС,
//	|	SUM(CustomerTurnovers.СуммаСкидки) AS СуммаСкидки,
//	|	SUM(CustomerTurnovers.СуммаСкидкиБезНДС) AS СуммаСкидкиБезНДС,
//	|	SUM(CustomerTurnovers.ПроданоНомеров) AS ПроданоНомеров,
//	|	SUM(CustomerTurnovers.ПроданоМест) AS ПроданоМест,
//	|	SUM(CustomerTurnovers.ПроданоДопМест) AS ПроданоДопМест,
//	|	SUM(CustomerTurnovers.ЧеловекаДни) AS ЧеловекаДни,
//	|	SUM(CustomerTurnovers.ЗаездГостей) AS ЗаездГостей
//	|{SELECT
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	CheckOutDate,
//	|	ВидРазмещения,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	CustomerTurnovers.ДокОснование.Тариф.* AS Тариф,
//	|	ДокОснование.*,
//	|	Услуга.*,
//	|	Продажи,
//	|	ПродажиБезНДС,
//	|	ДоходНомеров,
//	|	ДоходПродажиБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	GuestsCheckedIn}
//	|FROM
//	|	(SELECT
//	|		CustomerSales.Фирма AS Фирма,
//	|		CustomerSales.Гостиница AS Гостиница,
//	|		CustomerSales.Валюта AS Валюта,
//	|		CustomerSales.Агент AS Агент,
//	|		CustomerSales.Контрагент AS Контрагент,
//	|		CustomerSales.Договор AS Договор,
//	|		CustomerSales.ГруппаГостей AS ГруппаГостей,
//	|		CustomerSales.ДокОснование AS ДокОснование,
//	|		CustomerSales.Услуга AS Услуга,
//	|		CustomerSales.SalesTurnover AS Продажи,
//	|		CustomerSales.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|		CustomerSales.RoomRevenueTurnover AS ДоходНомеров,
//	|		CustomerSales.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|		CustomerSales.CommissionSumTurnover AS СуммаКомиссии,
//	|		CustomerSales.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|		CustomerSales.DiscountSumTurnover AS СуммаСкидки,
//	|		CustomerSales.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|		CustomerSales.RoomsRentedTurnover AS ПроданоНомеров,
//	|		CustomerSales.BedsRentedTurnover AS ПроданоМест,
//	|		CustomerSales.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|		CustomerSales.GuestDaysTurnover AS ЧеловекаДни,
//	|		CustomerSales.GuestsCheckedInTurnover AS ЗаездГостей
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				,
//	|				,
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
//	|						OR (NOT &qUseServicesList))
//	|					AND (ДокОснование.CheckOutDate IS NOT NULL 
//	|							AND &qPeriodFrom <= ДокОснование.CheckOutDate
//	|							AND &qPeriodTo >= ДокОснование.CheckOutDate
//	|							AND (ДокОснование.ReservationStatus IS NOT NULL 
//	|								OR ДокОснование.СтатусРазмещения IS NOT NULL 
//	|									AND ДокОснование.СтатусРазмещения.ЭтоВыезд)
//	|						OR ДокОснование.DateTimeTo IS NOT NULL 
//	|							AND &qPeriodFrom <= ДокОснование.DateTimeTo
//	|							AND &qPeriodTo >= ДокОснование.DateTimeTo)) AS CustomerSales) AS CustomerTurnovers
//	|{WHERE
//	|	CustomerTurnovers.Фирма.*,
//	|	CustomerTurnovers.Гостиница.*,
//	|	CustomerTurnovers.Валюта.*,
//	|	CustomerTurnovers.Агент.*,
//	|	CustomerTurnovers.Контрагент.*,
//	|	CustomerTurnovers.Договор.*,
//	|	CustomerTurnovers.ГруппаГостей.*,
//	|	CustomerTurnovers.ДокОснование.*,
//	|	(CASE
//	|			WHEN CustomerTurnovers.ДокОснование.Клиент IS NULL 
//	|				THEN CustomerTurnovers.ДокОснование.Клиент
//	|			ELSE CustomerTurnovers.ДокОснование.Клиент
//	|		END) AS Клиент,
//	|	(CASE
//	|			WHEN CustomerTurnovers.ДокОснование.CheckInDate IS NULL 
//	|				THEN CustomerTurnovers.ДокОснование.DateTimeFrom
//	|			ELSE CustomerTurnovers.ДокОснование.CheckInDate
//	|		END) AS CheckInDate,
//	|	(CASE
//	|			WHEN CustomerTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|				THEN CustomerTurnovers.ДокОснование.DateTimeTo
//	|			ELSE CustomerTurnovers.ДокОснование.CheckOutDate
//	|		END) AS CheckOutDate,
//	|	CustomerTurnovers.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	(CASE
//	|			WHEN (NOT CustomerTurnovers.ДокОснование.СтатусРазмещения IS NULL )
//	|				THEN CustomerTurnovers.ДокОснование.СтатусРазмещения
//	|			WHEN (NOT CustomerTurnovers.ДокОснование.ReservationStatus IS NULL )
//	|				THEN CustomerTurnovers.ДокОснование.ReservationStatus
//	|			ELSE CustomerTurnovers.ДокОснование.ResourceReservationStatus
//	|		END) AS Status,
//	|	CustomerTurnovers.ДокОснование.НомерРазмещения AS НомерРазмещения,
//	|	CustomerTurnovers.ДокОснование.ТипНомера AS ТипНомера,
//	|	CustomerTurnovers.ДокОснование.Ресурс AS Ресурс,
//	|	CustomerTurnovers.ДокОснование.Тариф.* AS Тариф,
//	|	CustomerTurnovers.Услуга.*,
//	|	CustomerTurnovers.Продажи,
//	|	CustomerTurnovers.ПродажиБезНДС,
//	|	CustomerTurnovers.ДоходНомеров,
//	|	CustomerTurnovers.ДоходПродажиБезНДС,
//	|	CustomerTurnovers.СуммаКомиссии,
//	|	CustomerTurnovers.КомиссияБезНДС,
//	|	CustomerTurnovers.СуммаСкидки,
//	|	CustomerTurnovers.СуммаСкидкиБезНДС,
//	|	CustomerTurnovers.ПроданоНомеров,
//	|	CustomerTurnovers.ПроданоМест,
//	|	CustomerTurnovers.ПроданоДопМест,
//	|	CustomerTurnovers.ЧеловекаДни,
//	|	CustomerTurnovers.GuestsCheckedIn}
//	|
//	|GROUP BY
//	|	CustomerTurnovers.Фирма,
//	|	CustomerTurnovers.Гостиница,
//	|	CustomerTurnovers.Валюта,
//	|	CustomerTurnovers.Агент,
//	|	CustomerTurnovers.Контрагент,
//	|	CustomerTurnovers.Договор,
//	|	CustomerTurnovers.ГруппаГостей,
//	|	CustomerTurnovers.ДокОснование,
//	|	CASE
//	|		WHEN CustomerTurnovers.ДокОснование.Клиент IS NULL 
//	|			THEN CustomerTurnovers.ДокОснование.Клиент
//	|		ELSE CustomerTurnovers.ДокОснование.Клиент
//	|	END,
//	|	CASE
//	|		WHEN CustomerTurnovers.ДокОснование.CheckInDate IS NULL 
//	|			THEN CustomerTurnovers.ДокОснование.DateTimeFrom
//	|		ELSE CustomerTurnovers.ДокОснование.CheckInDate
//	|	END,
//	|	CASE
//	|		WHEN CustomerTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|			THEN CustomerTurnovers.ДокОснование.DateTimeTo
//	|		ELSE CustomerTurnovers.ДокОснование.CheckOutDate
//	|	END,
//	|	CustomerTurnovers.ДокОснование.ВидРазмещения,
//	|	CASE
//	|		WHEN (NOT CustomerTurnovers.ДокОснование.СтатусРазмещения IS NULL )
//	|			THEN CustomerTurnovers.ДокОснование.СтатусРазмещения
//	|		WHEN (NOT CustomerTurnovers.ДокОснование.ReservationStatus IS NULL )
//	|			THEN CustomerTurnovers.ДокОснование.ReservationStatus
//	|		ELSE CustomerTurnovers.ДокОснование.ResourceReservationStatus
//	|	END,
//	|	CustomerTurnovers.ДокОснование.НомерРазмещения,
//	|	CustomerTurnovers.ДокОснование.ТипНомера,
//	|	CustomerTurnovers.ДокОснование.Ресурс,
//	|	CustomerTurnovers.Услуга
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
//	|	Услуга
//	|{ORDER BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Агент.*,
//	|	Клиент,
//	|	CheckInDate,
//	|	CheckOutDate,
//	|	ВидРазмещения.*,
//	|	Status,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	ДокОснование.*,
//	|	Услуга.*,
//	|	Продажи,
//	|	ПродажиБезНДС,
//	|	ДоходНомеров,
//	|	ДоходПродажиБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	GuestsCheckedIn}
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходНомеров),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ПроданоНомеров),
//	|	SUM(ПроданоМест),
//	|	SUM(ПроданоДопМест),
//	|	SUM(ЧеловекаДни),
//	|	SUM(ЗаездГостей)
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
//	|	Клиент,
//	|	НомерРазмещения.*,
//	|	ВидРазмещения.*,
//	|	Status,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	Услуга.*,
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
//	ReportBuilder.HeaderText = NStr("EN='Expected check-out with services';RU='Планируемый выезд с услугами';de='Geplante Abreise mit Diensten'");
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
