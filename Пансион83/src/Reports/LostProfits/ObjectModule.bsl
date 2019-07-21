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
//	ReportBuilder.Parameters.Вставить("qServicesPeriodFrom", '00010101');
//	ReportBuilder.Parameters.Вставить("qServicesPeriodTo", '39991231');
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
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231');
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
//	|	CustomerTurnovers.Фирма AS Фирма,
//	|	CustomerTurnovers.Гостиница AS Гостиница,
//	|	CustomerTurnovers.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	CustomerTurnovers.Агент AS Агент,
//	|	CustomerTurnovers.Контрагент AS Контрагент,
//	|	CustomerTurnovers.Договор AS Договор,
//	|	CustomerTurnovers.ГруппаГостей AS ГруппаГостей,
//	|	CustomerTurnovers.Клиент AS Клиент,
//	|	CustomerTurnovers.CheckInDate AS CheckInDate,
//	|	CustomerTurnovers.CheckOutDate,
//	|	CustomerTurnovers.ВидРазмещения AS ВидРазмещения,
//	|	CustomerTurnovers.Status AS Status,
//	|	CustomerTurnovers.НомерРазмещения AS НомерРазмещения,
//	|	CustomerTurnovers.ТипНомера AS ТипНомера,
//	|	CustomerTurnovers.Ресурс AS Ресурс,
//	|	CustomerTurnovers.Тариф AS Тариф,
//	|	CustomerTurnovers.ДокОснование AS ДокОснование,
//	|	CustomerTurnovers.СпособОплаты AS СпособОплаты,
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
//	|	SUM(CustomerTurnovers.ЗаездГостей) AS ЗаездГостей,
//	|	SUM(CustomerTurnovers.ЗаездНомеров) AS ЗаездНомеров,
//	|	SUM(CustomerTurnovers.ЗаездМест) AS ЗаездМест,
//	|	SUM(CustomerTurnovers.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест,
//	|	SUM(CustomerTurnovers.Количество) AS Количество
//	|{SELECT
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	ВалютаЛицСчета.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	CheckOutDate,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	Тариф.*,
//	|	ДокОснование.*,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	СпособОплаты.*,
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
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Quantity}
//	|FROM
//	|	(SELECT
//	|		CustomerSales.Фирма AS Фирма,
//	|		CustomerSales.Гостиница AS Гостиница,
//	|		CustomerSales.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|		CustomerSales.Агент AS Агент,
//	|		CustomerSales.ДокОснование.Контрагент AS Контрагент,
//	|		CustomerSales.ДокОснование.Договор AS Договор,
//	|		CustomerSales.ДокОснование AS ДокОснование,
//	|		CustomerSales.ГруппаГостей AS ГруппаГостей,
//	|		CustomerSales.Клиент AS Клиент,
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
//	|			WHEN (NOT CustomerSales.ДокОснование.СтатусРазмещения IS NULL )
//	|				THEN CustomerSales.ДокОснование.СтатусРазмещения
//	|			WHEN (NOT CustomerSales.ДокОснование.ReservationStatus IS NULL )
//	|				THEN CustomerSales.ДокОснование.ReservationStatus
//	|			ELSE CustomerSales.ДокОснование.ResourceReservationStatus
//	|		END AS Status,
//	|		CustomerSales.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|		CustomerSales.ДокОснование.НомерРазмещения AS НомерРазмещения,
//	|		CustomerSales.ДокОснование.ТипНомера AS ТипНомера,
//	|		CustomerSales.Тариф AS Тариф,
//	|		CustomerSales.ДокОснование.Ресурс AS Ресурс,
//	|		CustomerSales.СпособОплаты AS СпособОплаты,
//	|		CustomerSales.Услуга AS Услуга,
//	|		CustomerSales.ExpectedSalesTurnover AS Продажи,
//	|		CustomerSales.ExpectedSalesWithoutVATTurnover AS ПродажиБезНДС,
//	|		CustomerSales.ExpectedRoomRevenueTurnover AS ДоходНомеров,
//	|		CustomerSales.ExpectedRoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|		CustomerSales.ExpectedCommissionSumTurnover AS СуммаКомиссии,
//	|		CustomerSales.ExpectedCommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|		CustomerSales.ExpectedDiscountSumTurnover AS СуммаСкидки,
//	|		CustomerSales.ExpectedDiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|		CustomerSales.ExpectedRoomsRentedTurnover AS ПроданоНомеров,
//	|		CustomerSales.ExpectedBedsRentedTurnover AS ПроданоМест,
//	|		CustomerSales.ExpectedAdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|		CustomerSales.ExpectedGuestDaysTurnover AS ЧеловекаДни,
//	|		CustomerSales.ExpectedGuestsCheckedInTurnover AS ЗаездГостей,
//	|		CustomerSales.ExpectedRoomsCheckedInTurnover AS ЗаездНомеров,
//	|		CustomerSales.ExpectedBedsCheckedInTurnover AS ЗаездМест,
//	|		CustomerSales.ExpectedAdditionalBedsCheckedInTurnover AS ЗаездДополнительныхМест,
//	|		CustomerSales.ExpectedQuantityTurnover AS Количество
//	|	FROM
//	|		AccumulationRegister.ПрогнозРеализации.Turnovers(
//	|				&qServicesPeriodFrom,
//	|				&qServicesPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (ДокОснование.Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qCustomerIsEmpty)
//	|					AND (ДокОснование.Договор IN HIERARCHY (&qContract)
//	|						OR &qContractIsEmpty)
//	|					AND (ГруппаГостей = &qGuestGroup
//	|						OR &qGuestGroupIsEmpty)
//	|					AND (Агент IN HIERARCHY (&qAgent)
//	|						OR &qAgentIsEmpty)
//	|					AND (Услуга IN (&qServicesList)
//	|						OR (NOT &qUseServicesList))
//	|					AND (ДокОснование.CheckInDate >= &qPeriodFrom
//	|						AND ДокОснование.CheckInDate <= &qPeriodTo)) AS CustomerSales) AS CustomerTurnovers
//	|		LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, ) AS ForeignerRegistryRecords
//	|		ON CustomerTurnovers.ДокОснование = ForeignerRegistryRecords.Размещение
//	|WHERE
//	|	(NOT ISNULL(CustomerTurnovers.Status.IsActive, TRUE))
//	|	AND (NOT ISNULL(CustomerTurnovers.Status.ЭтоЗаезд, TRUE))
//	|	AND (NOT ISNULL(CustomerTurnovers.Status.IsAnnulation, TRUE))
//	|	AND (NOT ISNULL(CustomerTurnovers.Status.DoNoShowCharging, TRUE))
//	|	AND (NOT ISNULL(CustomerTurnovers.Status.DoLateAnnulationCharging, TRUE))
//	|{WHERE
//	|	CustomerTurnovers.Фирма.*,
//	|	CustomerTurnovers.Гостиница.*,
//	|	CustomerTurnovers.ВалютаЛицСчета.*,
//	|	CustomerTurnovers.Контрагент.*,
//	|	CustomerTurnovers.Договор.*,
//	|	CustomerTurnovers.ГруппаГостей.*,
//	|	CustomerTurnovers.Агент.*,
//	|	CustomerTurnovers.Клиент.*,
//	|	CustomerTurnovers.CheckInDate,
//	|	CustomerTurnovers.CheckOutDate,
//	|	CustomerTurnovers.ВидРазмещения.*,
//	|	CustomerTurnovers.Status.*,
//	|	CustomerTurnovers.НомерРазмещения.*,
//	|	CustomerTurnovers.ТипНомера.*,
//	|	CustomerTurnovers.Ресурс.*,
//	|	CustomerTurnovers.Тариф.*,
//	|	CustomerTurnovers.ДокОснование.*,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	CustomerTurnovers.СпособОплаты.*,
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
//	|	CustomerTurnovers.ЗаездГостей,
//	|	CustomerTurnovers.ЗаездНомеров,
//	|	CustomerTurnovers.ЗаездМест,
//	|	CustomerTurnovers.ЗаездДополнительныхМест,
//	|	CustomerTurnovers.Quantity}
//	|
//	|GROUP BY
//	|	CustomerTurnovers.Фирма,
//	|	CustomerTurnovers.Гостиница,
//	|	CustomerTurnovers.ВалютаЛицСчета,
//	|	CustomerTurnovers.Агент,
//	|	CustomerTurnovers.Контрагент,
//	|	CustomerTurnovers.Договор,
//	|	CustomerTurnovers.ГруппаГостей,
//	|	CustomerTurnovers.Клиент,
//	|	CustomerTurnovers.CheckInDate,
//	|	CustomerTurnovers.CheckOutDate,
//	|	CustomerTurnovers.ВидРазмещения,
//	|	CustomerTurnovers.Status,
//	|	CustomerTurnovers.НомерРазмещения,
//	|	CustomerTurnovers.ТипНомера,
//	|	CustomerTurnovers.Ресурс,
//	|	CustomerTurnovers.Тариф,
//	|	CustomerTurnovers.ДокОснование,
//	|	CustomerTurnovers.СпособОплаты
//	|
//	|ORDER BY
//	|	Фирма,
//	|	Гостиница,
//	|	ВалютаЛицСчета,
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	ВалютаЛицСчета.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
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
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	СпособОплаты.*,
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
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
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
//	|	ВалютаЛицСчета,
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей
//	|{TOTALS BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	ВалютаЛицСчета.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	НомерРазмещения.*,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	ТипНомера.*,
//	|	Тариф.*,
//	|	Ресурс.*,
//	|	СпособОплаты.*,
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
//	ReportBuilder.HeaderText = NStr("EN='Lost profits';RU='Упущенная выгода';de='Entgangener Gewinn'");
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
