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
//	If ShowPlan Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'План/факт'; en = 'Plan/Fact'") +
//		                     ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(CurrentDate()), PeriodFrom));
//	ReportBuilder.Parameters.Вставить("qService", Service);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
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
//	ReportBuilder.Parameters.Вставить("qShowPlan", ShowPlan);
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
//	|	Registration.Гостиница AS Гостиница,
//	|	Registration.Услуга AS Услуга,
//	|	Registration.Period AS Period,
//	|	Registration.НомерРазмещения AS НомерРазмещения,
//	|	Registration.Ресурс,
//	|	Registration.Клиент AS Клиент,
//	|	Registration.ГруппаГостей,
//	|	Registration.СчетПроживания,
//	|	Registration.ВалютаЛицСчета,
//	|	Registration.FolioDateTimeFrom AS FolioDateTimeFrom,
//	|	Registration.FolioDateTimeTo AS FolioDateTimeTo,
//	|	Registration.Recorder,
//	|	Registration.Автор,
//	|	Registration.Количество AS Количество,
//	|	Registration.Сумма AS Сумма,
//	|	Registration.PlanQuantity AS PlanQuantity,
//	|	Registration.PlanSum AS PlanSum
//	|{SELECT
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	Period,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, DAY)) AS УчетнаяДата,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, MONTH)) AS AccountingMonth,
//	|	(HOUR(Registration.Period)) AS RegistrationHour,
//	|	НомерРазмещения.*,
//	|	Registration.ТипНомера.* AS ТипНомера,
//	|	Ресурс.*,
//	|	Клиент.*,
//	|	ГруппаГостей.*,
//	|	Registration.Контрагент.* AS Контрагент,
//	|	Registration.Питание.* AS Питание,
//	|	Registration.ВидРазмещения.* AS ВидРазмещения,
//	|	СчетПроживания.*,
//	|	ВалютаЛицСчета.*,
//	|	FolioDateTimeFrom,
//	|	FolioDateTimeTo,
//	|	Recorder.*,
//	|	Автор.*,
//	|	Registration.Цена,
//	|	Registration.ЕдИзмерения,
//	|	Registration.ДокОснование.*,
//	|	Registration.Примечания,
//	|	Количество,
//	|	Сумма,
//	|	PlanQuantity,
//	|	PlanSum}
//	|FROM
//	|	(SELECT
//	|		РегистрацияУслуги.Гостиница AS Гостиница,
//	|		РегистрацияУслуги.Услуга AS Услуга,
//	|		РегистрацияУслуги.УчетнаяДата AS УчетнаяДата,
//	|		РегистрацияУслуги.Period AS Period,
//	|		РегистрацияУслуги.НомерРазмещения AS НомерРазмещения,
//	|		РегистрацияУслуги.ТипНомера AS ТипНомера,
//	|		РегистрацияУслуги.Ресурс AS Ресурс,
//	|		РегистрацияУслуги.Клиент AS Клиент,
//	|		РегистрацияУслуги.ГруппаГостей AS ГруппаГостей,
//	|		РегистрацияУслуги.Контрагент AS Контрагент,
//	|		РегистрацияУслуги.Питание AS Питание,
//	|		РегистрацияУслуги.ВидРазмещения AS ВидРазмещения,
//	|		РегистрацияУслуги.СчетПроживания AS СчетПроживания,
//	|		РегистрацияУслуги.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|		РегистрацияУслуги.FolioDateTimeFrom AS FolioDateTimeFrom,
//	|		РегистрацияУслуги.FolioDateTimeTo AS FolioDateTimeTo,
//	|		РегистрацияУслуги.ДокОснование AS ДокОснование,
//	|		РегистрацияУслуги.Примечания AS Примечания,
//	|		РегистрацияУслуги.Recorder AS Recorder,
//	|		РегистрацияУслуги.Автор AS Автор,
//	|		РегистрацияУслуги.ЕдИзмерения AS ЕдИзмерения,
//	|		РегистрацияУслуги.Цена AS Цена,
//	|		SUM(РегистрацияУслуги.Количество) AS Количество,
//	|		SUM(РегистрацияУслуги.Сумма) AS Сумма,
//	|		SUM(РегистрацияУслуги.PlanQuantity) AS PlanQuantity,
//	|		SUM(РегистрацияУслуги.PlanSum) AS PlanSum
//	|	FROM
//	|		(SELECT
//	|			ServiceRegistrations.Гостиница AS Гостиница,
//	|			ServiceRegistrations.Услуга AS Услуга,
//	|			ServiceRegistrations.УчетнаяДата AS УчетнаяДата,
//	|			ServiceRegistrations.ДатаДок AS Period,
//	|			ServiceRegistrations.НомерРазмещения AS НомерРазмещения,
//	|			ServiceRegistrations.НомерРазмещения.ТипНомера AS ТипНомера,
//	|			ServiceRegistrations.Ресурс AS Ресурс,
//	|			ServiceRegistrations.Клиент AS Клиент,
//	|			ServiceRegistrations.ГруппаГостей AS ГруппаГостей,
//	|			ServiceRegistrations.СчетПроживания.Контрагент AS Контрагент,
//	|			ServiceRegistrations.СчетПроживания.ДокОснование.Питание AS Питание,
//	|			ServiceRegistrations.СчетПроживания AS СчетПроживания,
//	|			ServiceRegistrations.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|			ServiceRegistrations.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
//	|			ServiceRegistrations.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
//	|			ServiceRegistrations.ДокОснование AS ДокОснование,
//	|			ServiceRegistrations.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|			CAST(ServiceRegistrations.Примечания AS STRING(1024)) AS Примечания,
//	|			ServiceRegistrations.Ref AS Recorder,
//	|			ServiceRegistrations.Автор AS Автор,
//	|			ServiceRegistrations.ЕдИзмерения AS ЕдИзмерения,
//	|			ServiceRegistrations.Цена AS Цена,
//	|			ServiceRegistrations.Количество AS Количество,
//	|			ServiceRegistrations.Сумма AS Сумма,
//	|			0 AS PlanQuantity,
//	|			0 AS PlanSum
//	|		FROM
//	|			Document.РегистрацияУслуги AS ServiceRegistrations
//	|		WHERE
//	|			ServiceRegistrations.Posted
//	|			AND ServiceRegistrations.Гостиница IN HIERARCHY(&qHotel)
//	|			AND ServiceRegistrations.УчетнаяДата BETWEEN &qPeriodFrom AND &qPeriodTo
//	|			AND ServiceRegistrations.Услуга IN HIERARCHY(&qService)
//	|			AND (ServiceRegistrations.НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qRoomIsEmpty)
//	|			AND (ServiceRegistrations.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qRoomTypeIsEmpty)
//	|			AND (ServiceRegistrations.Услуга IN (&qServicesList)
//	|					OR NOT &qUseServicesList)
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ServiceSales.Гостиница,
//	|			ServiceSales.Услуга,
//	|			ServiceSales.УчетнаяДата,
//	|			ServiceSales.Period,
//	|			ServiceSales.НомерРазмещения,
//	|			ServiceSales.ТипНомера,
//	|			ServiceSales.Ресурс,
//	|			ServiceSales.Клиент,
//	|			ServiceSales.ГруппаГостей,
//	|			ServiceSales.Контрагент,
//	|			ServiceSales.СчетПроживания.ДокОснование.Питание,
//	|			ServiceSales.СчетПроживания,
//	|			ServiceSales.СчетПроживания.ВалютаЛицСчета,
//	|			ServiceSales.СчетПроживания.DateTimeFrom,
//	|			ServiceSales.СчетПроживания.DateTimeTo,
//	|			ServiceSales.ДокОснование,
//	|			ServiceSales.ВидРазмещения,
//	|			CAST(ServiceSales.Recorder.Примечания AS STRING(1024)),
//	|			ServiceSales.Recorder,
//	|			ServiceSales.Автор,
//	|			ServiceSales.Услуга.ЕдИзмерения,
//	|			ServiceSales.Цена,
//	|			0,
//	|			0,
//	|			ServiceSales.Количество,
//	|			ServiceSales.Продажи
//	|		FROM
//	|			AccumulationRegister.Продажи AS ServiceSales
//	|		WHERE
//	|			&qShowPlan
//	|			AND ServiceSales.Гостиница IN HIERARCHY(&qHotel)
//	|			AND ServiceSales.Period BETWEEN &qPeriodFrom AND &qPeriodTo
//	|			AND ServiceSales.Услуга IN HIERARCHY(&qService)
//	|			AND (ServiceSales.НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qRoomIsEmpty)
//	|			AND (ServiceSales.ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qRoomTypeIsEmpty)
//	|			AND (ServiceSales.Услуга IN (&qServicesList)
//	|					OR NOT &qUseServicesList)
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ServiceSalesForecast.Гостиница,
//	|			ServiceSalesForecast.Услуга,
//	|			ServiceSalesForecast.УчетнаяДата,
//	|			ServiceSalesForecast.Period,
//	|			ServiceSalesForecast.НомерРазмещения,
//	|			ServiceSalesForecast.ТипНомера,
//	|			ServiceSalesForecast.Ресурс,
//	|			ServiceSalesForecast.Клиент,
//	|			ServiceSalesForecast.ГруппаГостей,
//	|			ServiceSalesForecast.Контрагент,
//	|			ServiceSalesForecast.СчетПроживания.ДокОснование.Питание,
//	|			ServiceSalesForecast.СчетПроживания,
//	|			ServiceSalesForecast.СчетПроживания.ВалютаЛицСчета,
//	|			ServiceSalesForecast.СчетПроживания.DateTimeFrom,
//	|			ServiceSalesForecast.СчетПроживания.DateTimeTo,
//	|			ServiceSalesForecast.ДокОснование,
//	|			ServiceSalesForecast.ВидРазмещения,
//	|			CAST(ServiceSalesForecast.Recorder.Примечания AS STRING(1024)),
//	|			ServiceSalesForecast.Recorder,
//	|			ServiceSalesForecast.Автор,
//	|			ServiceSalesForecast.Услуга.ЕдИзмерения,
//	|			ServiceSalesForecast.Цена,
//	|			0,
//	|			0,
//	|			ServiceSalesForecast.Количество,
//	|			ServiceSalesForecast.Продажи
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж AS ServiceSalesForecast
//	|		WHERE
//	|			&qShowPlan
//	|			AND ServiceSalesForecast.Гостиница IN HIERARCHY(&qHotel)
//	|			AND ServiceSalesForecast.Period >= &qForecastPeriodFrom
//	|			AND ServiceSalesForecast.Period <= &qPeriodTo
//	|			AND ServiceSalesForecast.Услуга IN HIERARCHY(&qService)
//	|			AND (ServiceSalesForecast.НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qRoomIsEmpty)
//	|			AND (ServiceSalesForecast.ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qRoomTypeIsEmpty)
//	|			AND (ServiceSalesForecast.Услуга IN (&qServicesList)
//	|					OR NOT &qUseServicesList)) AS РегистрацияУслуги
//	|	
//	|	GROUP BY
//	|		РегистрацияУслуги.Гостиница,
//	|		РегистрацияУслуги.Услуга,
//	|		РегистрацияУслуги.УчетнаяДата,
//	|		РегистрацияУслуги.Period,
//	|		РегистрацияУслуги.НомерРазмещения,
//	|		РегистрацияУслуги.ТипНомера,
//	|		РегистрацияУслуги.Ресурс,
//	|		РегистрацияУслуги.Клиент,
//	|		РегистрацияУслуги.ГруппаГостей,
//	|		РегистрацияУслуги.Контрагент,
//	|		РегистрацияУслуги.Питание,
//	|		РегистрацияУслуги.ВидРазмещения,
//	|		РегистрацияУслуги.СчетПроживания,
//	|		РегистрацияУслуги.ВалютаЛицСчета,
//	|		РегистрацияУслуги.FolioDateTimeFrom,
//	|		РегистрацияУслуги.FolioDateTimeTo,
//	|		РегистрацияУслуги.ДокОснование,
//	|		РегистрацияУслуги.Примечания,
//	|		РегистрацияУслуги.Recorder,
//	|		РегистрацияУслуги.Автор,
//	|		РегистрацияУслуги.ЕдИзмерения,
//	|		РегистрацияУслуги.Цена) AS Registration
//	|{WHERE
//	|	Registration.Гостиница.*,
//	|	Registration.Услуга.*,
//	|	Registration.Period AS Period,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, DAY)) AS УчетнаяДата,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, MONTH)) AS AccountingMonth,
//	|	(HOUR(Registration.Period)) AS RegistrationHour,
//	|	Registration.НомерРазмещения.*,
//	|	Registration.ТипНомера.*,
//	|	Registration.Ресурс.*,
//	|	Registration.Клиент.*,
//	|	Registration.ГруппаГостей.*,
//	|	Registration.Контрагент.* AS Контрагент,
//	|	Registration.Питание.* AS Питание,
//	|	Registration.ВидРазмещения.* AS ВидРазмещения,
//	|	Registration.СчетПроживания.*,
//	|	Registration.ВалютаЛицСчета.*,
//	|	Registration.Recorder.*,
//	|	Registration.Автор.*,
//	|	Registration.ДокОснование.*,
//	|	Registration.Примечания,
//	|	Registration.Цена,
//	|	Registration.ЕдИзмерения,
//	|	Registration.Количество,
//	|	Registration.Сумма,
//	|	Registration.PlanQuantity,
//	|	Registration.PlanSum}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	Услуга,
//	|	Period
//	|{ORDER BY
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	Period,
//	|	(HOUR(Registration.Period)) AS RegistrationHour,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, DAY)) AS УчетнаяДата,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, MONTH)) AS AccountingMonth,
//	|	НомерРазмещения.*,
//	|	Registration.ТипНомера.*,
//	|	Ресурс.*,
//	|	Клиент.*,
//	|	ГруппаГостей.*,
//	|	Registration.Контрагент.* AS Контрагент,
//	|	Registration.Питание.* AS Питание,
//	|	Registration.ВидРазмещения.* AS ВидРазмещения,
//	|	СчетПроживания.*,
//	|	ВалютаЛицСчета.*,
//	|	FolioDateTimeFrom,
//	|	FolioDateTimeTo,
//	|	Recorder.*,
//	|	Автор.*,
//	|	Registration.ДокОснование.*,
//	|	Registration.Примечания,
//	|	Registration.Цена,
//	|	Registration.ЕдИзмерения AS Количество,
//	|	Сумма,
//	|	PlanQuantity,
//	|	PlanSum}
//	|TOTALS
//	|	SUM(Количество),
//	|	SUM(Сумма),
//	|	SUM(PlanQuantity),
//	|	SUM(PlanSum)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	Услуга
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, DAY)) AS УчетнаяДата,
//	|	(BEGINOFPERIOD(Registration.УчетнаяДата, MONTH)) AS AccountingMonth,
//	|	(HOUR(Registration.Period)) AS RegistrationHour,
//	|	НомерРазмещения.*,
//	|	Registration.ТипНомера.*,
//	|	Ресурс.*,
//	|	Клиент.*,
//	|	ГруппаГостей.*,
//	|	Registration.Контрагент.* AS Контрагент,
//	|	Registration.Питание.* AS Питание,
//	|	Registration.ВидРазмещения.* AS ВидРазмещения,
//	|	СчетПроживания.*,
//	|	ВалютаЛицСчета.*,
//	|	Recorder.*,
//	|	Автор.*,
//	|	Registration.ДокОснование.*,
//	|	Registration.ЕдИзмерения,
//	|	Registration.Price}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Registered services';de='In der Tat registriert Dienstleistungen';ru='Фактически зарегистрированные услуги'");
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
