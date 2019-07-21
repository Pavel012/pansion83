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
//	If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		If НЕ ГруппаНомеров.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров ';ru='Номер ';de='Zimmer'") + 
//			                     TrimAll(ГруппаНомеров.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Rooms folder ';ru='Группа номеров ';de='Gruppe Zimmer '") + 
//			                     TrimAll(ГруппаНомеров.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(Service) Тогда
//		If НЕ Service.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Service ';ru='Услуга ';de='Dienstleistung'") + 
//			                     TrimAll(Service.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа услуг '; en = 'Services folder '") + 
//			                     TrimAll(Service.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qService", Service);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
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
//	ReportBuilder.Parameters.Вставить("qEmptyCountry", Справочники.Страны.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyString", "");
//	ReportBuilder.Parameters.Вставить("qEmptyResource", Справочники.Ресурсы.EmptyRef());
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
//	|	ServiceSales.Фирма AS Фирма,
//	|	ServiceSales.Гостиница AS Гостиница,
//	|	ServiceSales.Валюта AS Валюта,
//	|	ServiceSales.Услуга AS Услуга,
//	|	ServiceSales.УчетнаяДата AS УчетнаяДата,
//	|	ServiceSales.НомерРазмещения AS НомерРазмещения,
//	|	ServiceSales.Контрагент AS Контрагент,
//	|	ServiceSales.Клиент AS Клиент,
//	|	ServiceSales.Recorder AS Recorder,
//	|	ServiceSales.ДокОснование AS ДокОснование,
//	|	ServiceSales.Цена AS Цена,
//	|	ServiceSales.Количество AS Количество,
//	|	ServiceSales.Продажи AS Сумма,
//	|	ServiceSales.ПродажиБезНДС AS SumWithoutVAT,
//	|	ServiceSales.СуммаКомиссии AS СуммаКомиссии,
//	|	ServiceSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ServiceSales.СуммаСкидки AS СуммаСкидки,
//	|	ServiceSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ServiceSales.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|	ServiceSales.РазницаТарифИНачСуммой AS РазницаТарифИНачСуммой,
//	|	ServiceSales.ЭтоСторно AS ЭтоСторно,
//	|	ServiceSales.Автор AS Автор,
//	|	ServiceSales.Period AS Period
//	|{SELECT
//	|	Period,
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Услуга.*,
//	|	УчетнаяДата,
//	|	Цена,
//	|	НомерРазмещения.*,
//	|	ServiceSales.Ресурс.*,
//	|	ServiceSales.Агент.*,
//	|	Контрагент.*,
//	|	ServiceSales.Договор.*,
//	|	ServiceSales.ТипКлиента.*,
//	|	ServiceSales.МаретингНапрвл.*,
//	|	ServiceSales.ИсточИнфоГостиница.*,
//	|	Клиент.*,
//	|	ServiceSales.СчетПроживания.*,
//	|	ServiceSales.Примечания AS Примечания,
//	|	Recorder.*,
//	|	ДокОснование.*,
//	|	ServiceSales.Питание.*,
//	|	ServiceSales.ГруппаГостей.*,
//	|	ServiceSales.TripPurpose.*,
//	|	ServiceSales.ClientAge AS ClientAge,
//	|	ServiceSales.ClientCitizenship.* AS ClientCitizenship,
//	|	ServiceSales.ClientRegion AS ClientRegion,
//	|	ServiceSales.ClientCity AS ClientCity,
//	|	ServiceSales.КолДопМест,
//	|	ServiceSales.КоличествоМест,
//	|	ServiceSales.КоличествоМестНомер,
//	|	ServiceSales.КоличествоЧеловек,
//	|	ServiceSales.КоличествоГостейНомер,
//	|	ServiceSales.КоличествоНомеров,
//	|	ServiceSales.СтавкаНДС.*,
//	|	ServiceSales.ТипНомера.*,
//	|	ServiceSales.RoomRateType.*,
//	|	ServiceSales.Тариф.*,
//	|	ServiceSales.PointInTime,
//	|	Автор.*,
//	|	ServiceSales.Performer.* AS Performer,
//	|	ЭтоСторно,
//	|	ServiceSales.IsRoomRevenue AS IsRoomRevenue,
//	|	ServiceSales.IsResourceRevenue AS IsResourceRevenue,
//	|	Количество,
//	|	Сумма,
//	|	SumWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	СуммаТарифаПрож,
//	|	RateDiff}
//	|FROM
//	|	(SELECT
//	|		ServiceSalesMovements.Period AS Period,
//	|		ServiceSalesMovements.Фирма AS Фирма,
//	|		ServiceSalesMovements.Гостиница AS Гостиница,
//	|		ServiceSalesMovements.Валюта AS Валюта,
//	|		ServiceSalesMovements.Услуга AS Услуга,
//	|		ServiceSalesMovements.УчетнаяДата AS УчетнаяДата,
//	|		ServiceSalesMovements.Цена AS Цена,
//	|		ServiceSalesMovements.НомерРазмещения AS НомерРазмещения,
//	|		ServiceSalesMovements.Ресурс AS Ресурс,
//	|		ServiceSalesMovements.Агент AS Агент,
//	|		ServiceSalesMovements.Контрагент AS Контрагент,
//	|		ServiceSalesMovements.Договор AS Договор,
//	|		ServiceSalesMovements.ТипКлиента AS ТипКлиента,
//	|		ServiceSalesMovements.МаретингНапрвл AS МаретингНапрвл,
//	|		ServiceSalesMovements.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		ServiceSalesMovements.Клиент AS Клиент,
//	|		ServiceSalesMovements.СчетПроживания AS СчетПроживания,
//	|		ServiceSalesMovements.Recorder.Примечания AS Примечания,
//	|		ServiceSalesMovements.Recorder AS Recorder,
//	|		ServiceSalesMovements.ДокОснование AS ДокОснование,
//	|		CASE
//	|			WHEN NOT ServiceSalesMovements.ДокОснование.Питание IS NULL 
//	|				THEN ServiceSalesMovements.ДокОснование.Питание
//	|			WHEN ISNULL(ServiceSalesMovements.Услуга.Ресурс.IsBoardPlace, FALSE)
//	|				THEN ServiceSalesMovements.Услуга.Ресурс
//	|			ELSE &qEmptyResource
//	|		END AS Питание,
//	|		ServiceSalesMovements.ГруппаГостей AS ГруппаГостей,
//	|		ServiceSalesMovements.TripPurpose AS TripPurpose,
//	|		ISNULL(ServiceSalesMovements.Клиент.Age, 0) AS ClientAge,
//	|		ISNULL(ServiceSalesMovements.Клиент.Гражданство, &qEmptyCountry) AS ClientCitizenship,
//	|		ISNULL(ServiceSalesMovements.Клиент.Region, &qEmptyString) AS ClientRegion,
//	|		ISNULL(ServiceSalesMovements.Клиент.City, &qEmptyString) AS ClientCity,
//	|		ServiceSalesMovements.КолДопМест AS КолДопМест,
//	|		ServiceSalesMovements.КоличествоМест AS КоличествоМест,
//	|		ServiceSalesMovements.КоличествоМестНомер AS КоличествоМестНомер,
//	|		ServiceSalesMovements.КоличествоЧеловек AS КоличествоЧеловек,
//	|		ServiceSalesMovements.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|		ServiceSalesMovements.КоличествоНомеров AS КоличествоНомеров,
//	|		ServiceSalesMovements.СтавкаНДС AS СтавкаНДС,
//	|		ServiceSalesMovements.ТипНомера AS ТипНомера,
//	|		ServiceSalesMovements.RoomRateType AS RoomRateType,
//	|		ServiceSalesMovements.Тариф AS Тариф,
//	|		ServiceSalesMovements.PointInTime AS PointInTime,
//	|		ServiceSalesMovements.Автор AS Автор,
//	|		CASE
//	|			WHEN ServiceSalesMovements.Recorder.Performer IS NULL 
//	|				THEN ServiceSalesMovements.Recorder.ParentCharge.Performer
//	|			ELSE ServiceSalesMovements.Recorder.Performer
//	|		END AS Performer,
//	|		ServiceSalesMovements.ЭтоСторно AS ЭтоСторно,
//	|		CASE
//	|			WHEN ServiceSalesMovements.Recorder.IsRoomRevenue IS NULL 
//	|				THEN ServiceSalesMovements.Recorder.ParentCharge.IsRoomRevenue
//	|			ELSE ServiceSalesMovements.Recorder.IsRoomRevenue
//	|		END AS IsRoomRevenue,
//	|		CASE
//	|			WHEN ServiceSalesMovements.Recorder.IsResourceRevenue IS NULL 
//	|				THEN ServiceSalesMovements.Recorder.ParentCharge.IsResourceRevenue
//	|			ELSE ServiceSalesMovements.Recorder.IsResourceRevenue
//	|		END AS IsResourceRevenue,
//	|		ServiceSalesMovements.Количество AS Количество,
//	|		ServiceSalesMovements.Продажи AS Продажи,
//	|		ServiceSalesMovements.ПродажиБезНДС AS ПродажиБезНДС,
//	|		ServiceSalesMovements.СуммаКомиссии AS СуммаКомиссии,
//	|		ServiceSalesMovements.КомиссияБезНДС AS КомиссияБезНДС,
//	|		ServiceSalesMovements.СуммаСкидки AS СуммаСкидки,
//	|		ServiceSalesMovements.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|		ServiceSalesMovements.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|		ServiceSalesMovements.РазницаТарифИНачСуммой AS РазницаТарифИНачСуммой
//	|	FROM
//	|		AccumulationRegister.Продажи AS ServiceSalesMovements
//	|	WHERE
//	|		ServiceSalesMovements.Гостиница IN HIERARCHY(&qHotel)
//	|		AND ServiceSalesMovements.Period BETWEEN &qPeriodFrom AND &qPeriodTo
//	|		AND ServiceSalesMovements.Услуга IN HIERARCHY(&qService)
//	|		AND (ServiceSalesMovements.НомерРазмещения IN HIERARCHY (&qRoom)
//	|				OR &qRoomIsEmpty)
//	|		AND (ServiceSalesMovements.Услуга IN (&qServicesList)
//	|				OR NOT &qUseServicesList)) AS ServiceSales
//	|{WHERE
//	|	ServiceSales.Period,
//	|	ServiceSales.Recorder.*,
//	|	ServiceSales.Валюта.*,
//	|	ServiceSales.Гостиница.*,
//	|	ServiceSales.Услуга.*,
//	|	ServiceSales.Цена,
//	|	ServiceSales.ТипКлиента.*,
//	|	ServiceSales.МаретингНапрвл.*,
//	|	ServiceSales.ИсточИнфоГостиница.*,
//	|	ServiceSales.Фирма.*,
//	|	ServiceSales.УчетнаяДата,
//	|	ServiceSales.ДокОснование.*,
//	|	ServiceSales.СчетПроживания.*,
//	|	ServiceSales.Recorder.Примечания AS Примечания,
//	|	ServiceSales.Питание.*,
//	|	ServiceSales.ГруппаГостей.*,
//	|	ServiceSales.Клиент.*,
//	|	ServiceSales.TripPurpose.*,
//	|	ServiceSales.ClientAge AS ClientAge,
//	|	ServiceSales.ClientCitizenship.* AS ClientCitizenship,
//	|	ServiceSales.ClientRegion AS ClientRegion,
//	|	ServiceSales.ClientCity AS ClientCity,
//	|	ServiceSales.КолДопМест,
//	|	ServiceSales.КоличествоМест,
//	|	ServiceSales.КоличествоМестНомер,
//	|	ServiceSales.КоличествоЧеловек,
//	|	ServiceSales.КоличествоГостейНомер,
//	|	ServiceSales.КоличествоНомеров,
//	|	ServiceSales.НомерРазмещения.*,
//	|	ServiceSales.Ресурс.*,
//	|	ServiceSales.СтавкаНДС.*,
//	|	ServiceSales.Агент.*,
//	|	ServiceSales.ЭтоСторно,
//	|	ServiceSales.IsRoomRevenue AS IsRoomRevenue,
//	|	ServiceSales.IsResourceRevenue AS IsResourceRevenue,
//	|	ServiceSales.Контрагент.*,
//	|	ServiceSales.Договор.*,
//	|	ServiceSales.ТипНомера.*,
//	|	ServiceSales.Автор.*,
//	|	ServiceSales.Performer.* AS Performer,
//	|	ServiceSales.RoomRateType.*,
//	|	ServiceSales.Тариф.*,
//	|	ServiceSales.Количество,
//	|	ServiceSales.Продажи AS Сумма,
//	|	ServiceSales.ПродажиБезНДС AS SumWithoutVAT,
//	|	ServiceSales.СуммаКомиссии,
//	|	ServiceSales.КомиссияБезНДС,
//	|	ServiceSales.СуммаСкидки,
//	|	ServiceSales.СуммаСкидкиБезНДС,
//	|	ServiceSales.СуммаТарифаПрож,
//	|	ServiceSales.RateDiff}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Гостиница,
//	|	Услуга,
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	Цена,
//	|	ServiceSales.ТипКлиента.*,
//	|	ServiceSales.ИсточИнфоГостиница.*,
//	|	Фирма.*,
//	|	УчетнаяДата,
//	|	Recorder.*,
//	|	ДокОснование.*,
//	|	ServiceSales.СчетПроживания.*,
//	|	ServiceSales.Питание.*,
//	|	ServiceSales.ГруппаГостей.*,
//	|	Клиент.*,
//	|	ServiceSales.TripPurpose.*,
//	|	ServiceSales.ClientAge AS ClientAge,
//	|	ServiceSales.ClientCitizenship.* AS ClientCitizenship,
//	|	ServiceSales.ClientRegion AS ClientRegion,
//	|	ServiceSales.ClientCity AS ClientCity,
//	|	ServiceSales.КолДопМест,
//	|	ServiceSales.КоличествоМест,
//	|	ServiceSales.КоличествоМестНомер,
//	|	ServiceSales.КоличествоГостейНомер,
//	|	ServiceSales.КоличествоНомеров,
//	|	НомерРазмещения.*,
//	|	ServiceSales.Ресурс.*,
//	|	ServiceSales.СтавкаНДС.*,
//	|	ServiceSales.Агент.*,
//	|	ЭтоСторно,
//	|	ServiceSales.IsRoomRevenue AS IsRoomRevenue,
//	|	ServiceSales.IsResourceRevenue AS IsResourceRevenue,
//	|	Контрагент.*,
//	|	ServiceSales.Договор.*,
//	|	ServiceSales.ТипНомера.*,
//	|	Автор.*,
//	|	ServiceSales.Performer.* AS Performer,
//	|	ServiceSales.RoomRateType.*,
//	|	ServiceSales.Тариф.*}
//	|TOTALS
//	|	SUM(Количество),
//	|	SUM(Сумма),
//	|	SUM(SumWithoutVAT),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(СуммаТарифаПрож),
//	|	SUM(РазницаТарифИНачСуммой)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Гостиница,
//	|	Услуга
//	|{TOTALS BY
//	|	Recorder.*,
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	Цена,
//	|	ServiceSales.ТипКлиента.*,
//	|	ServiceSales.МаретингНапрвл.*,
//	|	ServiceSales.ИсточИнфоГостиница.*,
//	|	Фирма.*,
//	|	УчетнаяДата,
//	|	ДокОснование.*,
//	|	ServiceSales.СчетПроживания.*,
//	|	ServiceSales.Питание.*,
//	|	ServiceSales.ГруппаГостей.*,
//	|	Клиент.*,
//	|	ServiceSales.TripPurpose.*,
//	|	ServiceSales.ClientAge AS ClientAge,
//	|	ServiceSales.ClientCitizenship.* AS ClientCitizenship,
//	|	ServiceSales.ClientRegion AS ClientRegion,
//	|	ServiceSales.ClientCity AS ClientCity,
//	|	НомерРазмещения.*,
//	|	ServiceSales.Ресурс.*,
//	|	ServiceSales.СтавкаНДС.*,
//	|	ServiceSales.Агент.*,
//	|	ЭтоСторно,
//	|	ServiceSales.IsRoomRevenue AS IsRoomRevenue,
//	|	ServiceSales.IsResourceRevenue AS IsResourceRevenue,
//	|	Контрагент.*,
//	|	ServiceSales.Договор.*,
//	|	ServiceSales.ТипНомера.*,
//	|	Автор.*,
//	|	ServiceSales.Performer.* AS Performer,
//	|	ServiceSales.RoomRateType.*,
//	|	ServiceSales.Тариф.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Services sales';ru='Сводка по оказанным услугам';de='Bericht zu erbrachten Dienstleistungen'");
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
