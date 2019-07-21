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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	ReportBuilder.Parameters.Вставить("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
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
//	|	ПрогнозПродаж.Period AS Period,
//	|	ПрогнозПродаж.Гостиница AS Гостиница,
//	|	ПрогнозПродаж.Услуга AS Услуга,
//	|	ПрогнозПродаж.Цена AS Цена,
//	|	ПрогнозПродаж.НомерРазмещения AS НомерРазмещения,
//	|	ПрогнозПродаж.Тариф AS Тариф,
//	|	ПрогнозПродаж.Клиент AS Клиент,
//	|	ПрогнозПродаж.Ресурс AS Ресурс,
//	|	ПрогнозПродаж.ВремяС AS ВремяС,
//	|	ПрогнозПродаж.ВремяПо AS ВремяПо,
//	|	ПрогнозПродаж.Примечания AS Примечания,
//	|	ПрогнозПродаж.Recorder,
//	|	ПрогнозПродаж.ДокОснование,
//	|	ПрогнозПродаж.ЭтоСторно,
//	|	ПрогнозПродаж.Валюта AS Валюта,
//	|	ПрогнозПродаж.Количество AS Количество,
//	|	ПрогнозПродаж.QuantityAccommodation AS QuantityAccommodation,
//	|	ПрогнозПродаж.QuantityReservation AS QuantityReservation,
//	|	ПрогнозПродаж.Сумма AS Сумма,
//	|	ПрогнозПродаж.SumAccommodation AS SumAccommodation,
//	|	ПрогнозПродаж.SumReservation AS SumReservation,
//	|	ПрогнозПродаж.SumWithoutVAT AS SumWithoutVAT,
//	|	ПрогнозПродаж.SumWithoutVATAccommodation AS SumWithoutVATAccommodation,
//	|	ПрогнозПродаж.SumWithoutVATReservation AS SumWithoutVATReservation,
//	|	ПрогнозПродаж.СуммаКомиссии AS СуммаКомиссии,
//	|	ПрогнозПродаж.CommissionSumAccommodation AS CommissionSumAccommodation,
//	|	ПрогнозПродаж.CommissionSumReservation AS CommissionSumReservation,
//	|	ПрогнозПродаж.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ПрогнозПродаж.CommissionSumWithoutVATAccommodation AS CommissionSumWithoutVATAccommodation,
//	|	ПрогнозПродаж.CommissionSumWithoutVATReservation AS CommissionSumWithoutVATReservation,
//	|	ПрогнозПродаж.СуммаСкидки AS СуммаСкидки,
//	|	ПрогнозПродаж.DiscountSumAccommodation AS DiscountSumAccommodation,
//	|	ПрогнозПродаж.DiscountSumReservation AS DiscountSumReservation,
//	|	ПрогнозПродаж.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ПрогнозПродаж.DiscountSumWithoutVATAccommodation AS DiscountSumWithoutVATAccommodation,
//	|	ПрогнозПродаж.DiscountSumWithoutVATReservation AS DiscountSumWithoutVATReservation,
//	|	ПрогнозПродаж.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|	ПрогнозПродаж.РазницаТарифИНачСуммой AS РазницаТарифИНачСуммой
//	|{SELECT
//	|	Period AS Period,
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	(HOUR(ПрогнозПродаж.Period)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	ПрогнозПродаж.CheckInDate AS CheckInDate,
//	|	(HOUR(ПрогнозПродаж.CheckInDate)) AS CheckInHour,
//	|	(DAY(ПрогнозПродаж.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ПрогнозПродаж.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ПрогнозПродаж.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ПрогнозПродаж.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ПрогнозПродаж.CheckInDate)) AS CheckInYear,
//	|	ПрогнозПродаж.CheckOutDate AS CheckOutDate,
//	|	ПрогнозПродаж.Status.* AS Status,
//	|	Цена AS Цена,
//	|	Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientAgeRange.* AS ClientAgeRange,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	ПрогнозПродаж.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	Примечания AS Примечания,
//	|	Recorder.* AS Recorder,
//	|	ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Питание.* AS Питание,
//	|	ПрогнозПродаж.КоличествоНомеров AS КоличествоНомеров,
//	|	ПрогнозПродаж.КоличествоМест AS КоличествоМест,
//	|	ПрогнозПродаж.КолДопМест AS КолДопМест,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ПрогнозПродаж.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ПрогнозПродаж.ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ЭтоСторно AS ЭтоСторно,
//	|	ПрогнозПродаж.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|	ПрогнозПродаж.РазницаТарифИНачСуммой AS РазницаТарифИНачСуммой,
//	|	Ресурс.* AS Ресурс,
//	|	ВремяС AS ВремяС,
//	|	ВремяПо AS ВремяПо,
//	|	Количество AS Количество,
//	|	QuantityReservation AS QuantityReservation,
//	|	QuantityAccommodation AS QuantityAccommodation,
//	|	Сумма AS Сумма,
//	|	SumReservation AS SumReservation,
//	|	SumAccommodation AS SumAccommodation,
//	|	SumWithoutVAT AS SumWithoutVAT,
//	|	SumWithoutVATReservation AS SumWithoutVATReservation,
//	|	SumWithoutVATAccommodation AS SumWithoutVATAccommodation,
//	|	СуммаКомиссии AS СуммаКомиссии,
//	|	CommissionSumReservation AS CommissionSumReservation,
//	|	CommissionSumAccommodation AS CommissionSumAccommodation,
//	|	КомиссияБезНДС AS КомиссияБезНДС,
//	|	CommissionSumWithoutVATReservation AS CommissionSumWithoutVATReservation,
//	|	CommissionSumWithoutVATAccommodation AS CommissionSumWithoutVATAccommodation,
//	|	СуммаСкидки AS СуммаСкидки,
//	|	DiscountSumReservation AS DiscountSumReservation,
//	|	DiscountSumAccommodation AS DiscountSumAccommodation,
//	|	СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	DiscountSumWithoutVATReservation AS DiscountSumWithoutVATReservation,
//	|	DiscountSumWithoutVATAccommodation AS DiscountSumWithoutVATAccommodation,
//	|	СуммаТарифаПрож AS СуммаТарифаПрож,
//	|	РазницаТарифИНачСуммой AS RateDiff}
//	|FROM
//	|	(SELECT
//	|		ServiceSales.Period AS Period,
//	|		ServiceSales.Гостиница AS Гостиница,
//	|		ServiceSales.Фирма AS Фирма,
//	|		ServiceSales.Валюта AS Валюта,
//	|		ServiceSales.Услуга AS Услуга,
//	|		ServiceSales.УчетнаяДата AS УчетнаяДата,
//	|		ServiceSales.СчетПроживания.DateTimeFrom AS CheckInDate,
//	|		ServiceSales.СчетПроживания.DateTimeTo AS CheckOutDate,
//	|		CASE
//	|			WHEN ServiceSales.ДокОснование.СтатусРазмещения IS NOT NULL 
//	|				THEN ServiceSales.ДокОснование.СтатусРазмещения
//	|			WHEN ServiceSales.ДокОснование.ReservationStatus IS NOT NULL 
//	|				THEN ServiceSales.ДокОснование.ReservationStatus
//	|			WHEN ServiceSales.ДокОснование.ResourceReservationStatus IS NOT NULL 
//	|				THEN ServiceSales.ДокОснование.ResourceReservationStatus
//	|			ELSE NULL
//	|		END AS Status,
//	|		ServiceSales.Цена AS Цена,
//	|		ServiceSales.НомерРазмещения AS НомерРазмещения,
//	|		ServiceSales.Клиент AS Клиент,
//	|		ServiceSales.ТипКлиента AS ТипКлиента,
//	|		ServiceSales.Клиент.Age AS ClientAge,
//	|		ServiceSales.Клиент.AgeRange AS ClientAgeRange,
//	|		ServiceSales.Клиент.Гражданство AS ClientCitizenship,
//	|		ServiceSales.Клиент.Region AS ClientRegion,
//	|		ServiceSales.Клиент.City AS ClientCity,
//	|		ServiceSales.Агент AS Агент,
//	|		ServiceSales.Контрагент AS Контрагент,
//	|		ServiceSales.Договор AS Договор,
//	|		ServiceSales.ГруппаГостей AS ГруппаГостей,
//	|		ServiceSales.МаретингНапрвл AS МаретингНапрвл,
//	|		ServiceSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		ServiceSales.СчетПроживания AS СчетПроживания,
//	|		ServiceSales.Recorder.Примечания AS Примечания,
//	|		ServiceSales.Recorder AS Recorder,
//	|		ServiceSales.ДокОснование AS ДокОснование,
//	|		ServiceSales.TripPurpose AS TripPurpose,
//	|		ServiceSales.СпособОплаты AS СпособОплаты,
//	|		ServiceSales.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|		ServiceSales.КолДопМест AS КолДопМест,
//	|		ServiceSales.КоличествоМест AS КоличествоМест,
//	|		ServiceSales.КоличествоМестНомер AS КоличествоМестНомер,
//	|		ServiceSales.КоличествоЧеловек AS КоличествоЧеловек,
//	|		ServiceSales.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|		ServiceSales.КоличествоНомеров AS КоличествоНомеров,
//	|		ServiceSales.ТипНомера AS ТипНомера,
//	|		ServiceSales.RoomRateType AS RoomRateType,
//	|		ServiceSales.Тариф AS Тариф,
//	|		ServiceSales.СтавкаНДС AS СтавкаНДС,
//	|		ServiceSales.Автор AS Автор,
//	|		ServiceSales.ЭтоСторно AS ЭтоСторно,
//	|		ServiceSales.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|		ServiceSales.РазницаТарифИНачСуммой AS РазницаТарифИНачСуммой,
//	|		CASE
//	|			WHEN NOT ServiceSales.ДокОснование.Питание IS NULL 
//	|				THEN ServiceSales.ДокОснование.Питание
//	|			WHEN ISNULL(ServiceSales.Услуга.Ресурс.IsBoardPlace, FALSE)
//	|				THEN ServiceSales.Услуга.Ресурс
//	|			ELSE &qEmptyResource
//	|		END AS Питание,
//	|		ServiceSales.Ресурс AS Ресурс,
//	|		ServiceSales.ВремяС AS ВремяС,
//	|		ServiceSales.ВремяПо AS ВремяПо,
//	|		ServiceSales.Количество AS Количество,
//	|		0 AS QuantityReservation,
//	|		ServiceSales.Количество AS QuantityAccommodation,
//	|		ServiceSales.Продажи AS Сумма,
//	|		0 AS SumReservation,
//	|		ServiceSales.Продажи AS SumAccommodation,
//	|		ServiceSales.ПродажиБезНДС AS SumWithoutVAT,
//	|		0 AS SumWithoutVATReservation,
//	|		ServiceSales.ПродажиБезНДС AS SumWithoutVATAccommodation,
//	|		ServiceSales.СуммаКомиссии AS СуммаКомиссии,
//	|		0 AS CommissionSumReservation,
//	|		ServiceSales.СуммаКомиссии AS CommissionSumAccommodation,
//	|		ServiceSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|		0 AS CommissionSumWithoutVATReservation,
//	|		ServiceSales.КомиссияБезНДС AS CommissionSumWithoutVATAccommodation,
//	|		ServiceSales.СуммаСкидки AS СуммаСкидки,
//	|		0 AS DiscountSumReservation,
//	|		ServiceSales.СуммаСкидки AS DiscountSumAccommodation,
//	|		ServiceSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|		0 AS DiscountSumWithoutVATReservation,
//	|		ServiceSales.СуммаСкидкиБезНДС AS DiscountSumWithoutVATAccommodation
//	|	FROM
//	|		AccumulationRegister.Продажи AS ServiceSales
//	|	WHERE
//	|		ServiceSales.Гостиница IN HIERARCHY(&qHotel)
//	|		AND ServiceSales.Услуга IN HIERARCHY(&qService)
//	|		AND (ServiceSales.Услуга IN (&qServicesList)
//	|				OR NOT &qUseServicesList)
//	|		AND (ServiceSales.НомерРазмещения IN HIERARCHY (&qRoom)
//	|				OR &qRoomIsEmpty)
//	|		AND ServiceSales.Period BETWEEN &qPeriodFrom AND &qPeriodTo
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		ServiceSalesForecast.Period,
//	|		ServiceSalesForecast.Гостиница,
//	|		ServiceSalesForecast.Фирма,
//	|		ServiceSalesForecast.Валюта,
//	|		ServiceSalesForecast.Услуга,
//	|		ServiceSalesForecast.УчетнаяДата,
//	|		ServiceSalesForecast.Recorder.CheckInDate,
//	|		ServiceSalesForecast.Recorder.CheckOutDate,
//	|		CASE
//	|			WHEN ServiceSalesForecast.Recorder.ReservationStatus IS NOT NULL 
//	|				THEN ServiceSalesForecast.Recorder.ReservationStatus
//	|			WHEN ServiceSalesForecast.Recorder.ResourceReservationStatus IS NOT NULL 
//	|				THEN ServiceSalesForecast.Recorder.ResourceReservationStatus
//	|			ELSE NULL
//	|		END,
//	|		ServiceSalesForecast.Цена,
//	|		ServiceSalesForecast.НомерРазмещения,
//	|		ServiceSalesForecast.Клиент,
//	|		ServiceSalesForecast.ТипКлиента,
//	|		ServiceSalesForecast.Клиент.Age,
//	|		ServiceSalesForecast.Клиент.AgeRange,
//	|		ServiceSalesForecast.Клиент.Гражданство,
//	|		ServiceSalesForecast.Клиент.Region,
//	|		ServiceSalesForecast.Клиент.City,
//	|		ServiceSalesForecast.Агент,
//	|		ServiceSalesForecast.Контрагент,
//	|		ServiceSalesForecast.Договор,
//	|		ServiceSalesForecast.ГруппаГостей,
//	|		ServiceSalesForecast.МаретингНапрвл,
//	|		ServiceSalesForecast.ИсточИнфоГостиница,
//	|		ServiceSalesForecast.СчетПроживания,
//	|		ServiceSalesForecast.Примечания,
//	|		ServiceSalesForecast.Recorder,
//	|		ServiceSalesForecast.Recorder,
//	|		ServiceSalesForecast.TripPurpose,
//	|		ServiceSalesForecast.СпособОплаты,
//	|		ServiceSalesForecast.Recorder.ВидРазмещения,
//	|		ServiceSalesForecast.КолДопМест,
//	|		ServiceSalesForecast.КоличествоМест,
//	|		ServiceSalesForecast.КоличествоМестНомер,
//	|		ServiceSalesForecast.КоличествоЧеловек,
//	|		ServiceSalesForecast.КоличествоГостейНомер,
//	|		ServiceSalesForecast.КоличествоНомеров,
//	|		ServiceSalesForecast.ТипНомера,
//	|		ServiceSalesForecast.RoomRateType,
//	|		ServiceSalesForecast.Тариф,
//	|		ServiceSalesForecast.СтавкаНДС,
//	|		ServiceSalesForecast.Автор,
//	|		ServiceSalesForecast.ЭтоСторно,
//	|		ServiceSalesForecast.СуммаТарифаПрож,
//	|		ServiceSalesForecast.РазницаТарифИНачСуммой,
//	|		CASE
//	|			WHEN NOT ServiceSalesForecast.Recorder.Питание IS NULL 
//	|				THEN ServiceSalesForecast.Recorder.Питание
//	|			WHEN ISNULL(ServiceSalesForecast.Услуга.Ресурс.IsBoardPlace, FALSE)
//	|				THEN ServiceSalesForecast.Услуга.Ресурс
//	|			ELSE &qEmptyResource
//	|		END,
//	|		ServiceSalesForecast.Ресурс,
//	|		ServiceSalesForecast.ВремяС,
//	|		ServiceSalesForecast.ВремяПо,
//	|		ServiceSalesForecast.Количество,
//	|		ServiceSalesForecast.Количество,
//	|		0,
//	|		ServiceSalesForecast.Продажи,
//	|		ServiceSalesForecast.Продажи,
//	|		0,
//	|		ServiceSalesForecast.ПродажиБезНДС,
//	|		ServiceSalesForecast.ПродажиБезНДС,
//	|		0,
//	|		ServiceSalesForecast.СуммаКомиссии,
//	|		ServiceSalesForecast.СуммаКомиссии,
//	|		0,
//	|		ServiceSalesForecast.КомиссияБезНДС,
//	|		ServiceSalesForecast.КомиссияБезНДС,
//	|		0,
//	|		ServiceSalesForecast.СуммаСкидки,
//	|		ServiceSalesForecast.СуммаСкидки,
//	|		0,
//	|		ServiceSalesForecast.СуммаСкидкиБезНДС,
//	|		ServiceSalesForecast.СуммаСкидкиБезНДС,
//	|		0
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж AS ServiceSalesForecast
//	|	WHERE
//	|		ServiceSalesForecast.Гостиница IN HIERARCHY(&qHotel)
//	|		AND ServiceSalesForecast.Услуга IN HIERARCHY(&qService)
//	|		AND (ServiceSalesForecast.Услуга IN (&qServicesList)
//	|				OR NOT &qUseServicesList)
//	|		AND (ServiceSalesForecast.НомерРазмещения IN HIERARCHY (&qRoom)
//	|				OR &qRoomIsEmpty)
//	|		AND ServiceSalesForecast.Period BETWEEN &qForecastPeriodFrom AND &qForecastPeriodTo) AS ПрогнозПродаж
//	|{WHERE
//	|	ПрогнозПродаж.Period AS Period,
//	|	ПрогнозПродаж.Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	ПрогнозПродаж.Валюта.* AS Валюта,
//	|	ПрогнозПродаж.Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	ПрогнозПродаж.CheckInDate AS CheckInDate,
//	|	ПрогнозПродаж.CheckOutDate AS CheckOutDate,
//	|	ПрогнозПродаж.Status AS Status,
//	|	ПрогнозПродаж.Цена AS Цена,
//	|	ПрогнозПродаж.Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientAgeRange.* AS ClientAgeRange,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	ПрогнозПродаж.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	ПрогнозПродаж.Примечания AS Примечания,
//	|	ПрогнозПродаж.Recorder.* AS Recorder,
//	|	ПрогнозПродаж.ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Питание.* AS Питание,
//	|	ПрогнозПродаж.КоличествоНомеров AS КоличествоНомеров,
//	|	ПрогнозПродаж.КоличествоМест AS КоличествоМест,
//	|	ПрогнозПродаж.КолДопМест AS КолДопМест,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ПрогнозПродаж.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ПрогнозПродаж.ТипНомера.* AS ТипНомера,
//	|	ПрогнозПродаж.НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.RoomRateType.* AS RoomRateType,
//	|	ПрогнозПродаж.Тариф.* AS Тариф,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ПрогнозПродаж.ЭтоСторно AS ЭтоСторно,
//	|	ПрогнозПродаж.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|	ПрогнозПродаж.РазницаТарифИНачСуммой AS РазницаТарифИНачСуммой,
//	|	ПрогнозПродаж.Ресурс.* AS Ресурс,
//	|	ПрогнозПродаж.ВремяС AS ВремяС,
//	|	ПрогнозПродаж.ВремяПо AS ВремяПо,
//	|	ПрогнозПродаж.Количество AS Количество,
//	|	ПрогнозПродаж.QuantityReservation AS QuantityReservation,
//	|	ПрогнозПродаж.QuantityAccommodation AS QuantityAccommodation,
//	|	ПрогнозПродаж.Сумма AS Сумма,
//	|	ПрогнозПродаж.SumReservation AS SumReservation,
//	|	ПрогнозПродаж.SumAccommodation AS SumAccommodation,
//	|	ПрогнозПродаж.SumWithoutVAT AS SumWithoutVAT,
//	|	ПрогнозПродаж.SumWithoutVATReservation AS SumWithoutVATReservation,
//	|	ПрогнозПродаж.SumWithoutVATAccommodation AS SumWithoutVATAccommodation,
//	|	ПрогнозПродаж.СуммаКомиссии AS СуммаКомиссии,
//	|	ПрогнозПродаж.CommissionSumReservation AS CommissionSumReservation,
//	|	ПрогнозПродаж.CommissionSumAccommodation AS CommissionSumAccommodation,
//	|	ПрогнозПродаж.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ПрогнозПродаж.CommissionSumWithoutVATReservation AS CommissionSumWithoutVATReservation,
//	|	ПрогнозПродаж.CommissionSumWithoutVATAccommodation AS CommissionSumWithoutVATAccommodation,
//	|	ПрогнозПродаж.СуммаСкидки AS СуммаСкидки,
//	|	ПрогнозПродаж.DiscountSumReservation AS DiscountSumReservation,
//	|	ПрогнозПродаж.DiscountSumAccommodation AS DiscountSumAccommodation,
//	|	ПрогнозПродаж.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ПрогнозПродаж.DiscountSumWithoutVATReservation AS DiscountSumWithoutVATReservation,
//	|	ПрогнозПродаж.DiscountSumWithoutVATAccommodation AS DiscountSumWithoutVATAccommodation,
//	|	ПрогнозПродаж.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|	ПрогнозПродаж.РазницаТарифИНачСуммой AS RateDiff}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Гостиница,
//	|	Услуга,
//	|	НомерРазмещения,
//	|	Period
//	|{ORDER BY
//	|	Period AS Period,
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	ПрогнозПродаж.CheckInDate AS CheckInDate,
//	|	ПрогнозПродаж.CheckOutDate AS CheckOutDate,
//	|	ПрогнозПродаж.Status.* AS Status,
//	|	Цена AS Цена,
//	|	Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientAgeRange.* AS ClientAgeRange,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	ПрогнозПродаж.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	Recorder.* AS Recorder,
//	|	ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Питание.* AS Питание,
//	|	ПрогнозПродаж.КоличествоНомеров AS КоличествоНомеров,
//	|	ПрогнозПродаж.КоличествоМест AS КоличествоМест,
//	|	ПрогнозПродаж.КолДопМест AS КолДопМест,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ПрогнозПродаж.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ПрогнозПродаж.ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ЭтоСторно AS ЭтоСторно,
//	|	ПрогнозПродаж.СуммаТарифаПрож AS СуммаТарифаПрож,
//	|	ПрогнозПродаж.РазницаТарифИНачСуммой AS РазницаТарифИНачСуммой,
//	|	Ресурс.* AS Ресурс,
//	|	ВремяС AS ВремяС,
//	|	ВремяПо AS ВремяПо,
//	|	Количество AS Количество,
//	|	QuantityReservation AS QuantityReservation,
//	|	QuantityAccommodation AS QuantityAccommodation,
//	|	Сумма AS Сумма,
//	|	SumReservation AS SumReservation,
//	|	SumAccommodation AS SumAccommodation,
//	|	SumWithoutVAT AS SumWithoutVAT,
//	|	SumWithoutVATReservation AS SumWithoutVATReservation,
//	|	SumWithoutVATAccommodation AS SumWithoutVATAccommodation,
//	|	СуммаКомиссии AS СуммаКомиссии,
//	|	CommissionSumReservation AS CommissionSumReservation,
//	|	CommissionSumAccommodation AS CommissionSumAccommodation,
//	|	КомиссияБезНДС AS КомиссияБезНДС,
//	|	CommissionSumWithoutVATReservation AS CommissionSumWithoutVATReservation,
//	|	CommissionSumWithoutVATAccommodation AS CommissionSumWithoutVATAccommodation,
//	|	СуммаСкидки AS СуммаСкидки,
//	|	DiscountSumReservation AS DiscountSumReservation,
//	|	DiscountSumAccommodation AS DiscountSumAccommodation,
//	|	СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	DiscountSumWithoutVATReservation AS DiscountSumWithoutVATReservation,
//	|	DiscountSumWithoutVATAccommodation AS DiscountSumWithoutVATAccommodation}
//	|TOTALS
//	|	SUM(Количество),
//	|	SUM(QuantityAccommodation),
//	|	SUM(QuantityReservation),
//	|	SUM(Сумма),
//	|	SUM(SumAccommodation),
//	|	SUM(SumReservation),
//	|	SUM(SumWithoutVAT),
//	|	SUM(SumWithoutVATAccommodation),
//	|	SUM(SumWithoutVATReservation),
//	|	SUM(СуммаКомиссии),
//	|	SUM(CommissionSumAccommodation),
//	|	SUM(CommissionSumReservation),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(CommissionSumWithoutVATAccommodation),
//	|	SUM(CommissionSumWithoutVATReservation),
//	|	SUM(СуммаСкидки),
//	|	SUM(DiscountSumAccommodation),
//	|	SUM(DiscountSumReservation),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(DiscountSumWithoutVATAccommodation),
//	|	SUM(DiscountSumWithoutVATReservation),
//	|	SUM(СуммаТарифаПрож),
//	|	SUM(РазницаТарифИНачСуммой)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Гостиница,
//	|	Услуга,
//	|	НомерРазмещения,
//	|	Period
//	|{TOTALS BY
//	|	Period AS Period,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	(HOUR(ПрогнозПродаж.Period)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	(HOUR(ПрогнозПродаж.CheckInDate)) AS CheckInHour,
//	|	(DAY(ПрогнозПродаж.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ПрогнозПродаж.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ПрогнозПродаж.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ПрогнозПродаж.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ПрогнозПродаж.CheckInDate)) AS CheckInYear,
//	|	ПрогнозПродаж.Status.* AS Status,
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Услуга.* AS Услуга,
//	|	Цена AS Цена,
//	|	Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientAgeRange.* AS ClientAgeRange,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	ПрогнозПродаж.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	Recorder.* AS Recorder,
//	|	ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Питание.* AS Питание,
//	|	ПрогнозПродаж.КоличествоНомеров AS КоличествоНомеров,
//	|	ПрогнозПродаж.КоличествоМест AS КоличествоМест,
//	|	ПрогнозПродаж.КолДопМест AS КолДопМест,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ПрогнозПродаж.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ПрогнозПродаж.ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	Ресурс.* AS Ресурс,
//	|	ВремяС AS ВремяС,
//	|	ВремяПо AS ВремяПо,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ЭтоСторно AS IsStorno}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Services sales forecast';ru='Планируемое оказание услуг';de='Geplante Leistungserbringung'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Undefined;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//Function pmIsResource(pName) Экспорт
//	If pName = "Количество" 
//	   Or pName = "QuantityAccommodation" 
//	   Or pName = "QuantityReservation" 
//	   Or pName = "Сумма" 
//	   Or pName = "SumAccommodation" 
//	   Or pName = "SumReservation" 
//	   Or pName = "SumWithoutVAT" 
//	   Or pName = "SumWithoutVATAccommodation" 
//	   Or pName = "SumWithoutVATReservation" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "CommissionSumAccommodation" 
//	   Or pName = "CommissionSumReservation" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "CommissionSumWithoutVATAccommodation" 
//	   Or pName = "CommissionSumWithoutVATReservation" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "DiscountSumAccommodation" 
//	   Or pName = "DiscountSumReservation" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "DiscountSumWithoutVATAccommodation" 
//	   Or pName = "DiscountSumWithoutVATReservation" 
//	   Or pName = "СуммаТарифаПрож" 
//	   Or pName = "РазницаТарифИНачСуммой" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
