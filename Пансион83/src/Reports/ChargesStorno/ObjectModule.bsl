//-----------------------------------------------------------------------------
// Reports framework start
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
// Initialize attributes with default values
// Attention: This procedure could be called AFTER some attributes initialization
// routine, so it SHOULD NOT reset attributes being set before
//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill parameters with default values
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
		PeriodFrom = BegOfDay(CurrentDate()); // For today
		PeriodTo = EndOfDay(PeriodFrom);
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetReportParametersPresentation() Экспорт
	vParamPresentation = "";
	If ЗначениеЗаполнено(Employee) Тогда
		If НЕ Employee.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter'") + 
			                     TrimAll(Employee) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '") + 
			                     TrimAll(Employee) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(Гостиница) Тогда
		If НЕ Гостиница.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='Гостиница ';ru='Гостиница ';de='Гостиница'") + 
			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("en='Hotels folder ';ru='Группа гостиниц ';de='Gruppe Hotels '") + 
			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
		                     ";" + Chars.LF;
	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
		                     ";" + Chars.LF;
	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
		                     ";" + Chars.LF;
	ElsIf PeriodFrom = PeriodTo Тогда
		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
		                     ";" + Chars.LF;
	
	Else
		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
		                     ";" + Chars.LF;
	EndIf;
	If ЗначениеЗаполнено(Room) Тогда
		If НЕ Room.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров ';ru='Номер ';de='Zimmer'") + 
			                     TrimAll(Room.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("en='Rooms folder ';ru='Группа номеров ';de='Gruppe Zimmer '") + 
			                     TrimAll(Room.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;							 
	If ЗначениеЗаполнено(Service) Тогда
		If НЕ Service.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='Service ';ru='Услуга ';de='Dienstleistung'") + 
			                     TrimAll(Service.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа услуг '; en = 'Services folder '") + 
			                     TrimAll(Service.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;					 
	If ЗначениеЗаполнено(ServiceGroup) Тогда
		If НЕ ServiceGroup.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Набор услуг '; en = 'Service group '") + 
			                     TrimAll(ServiceGroup.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа наборов услуг '; en = 'Service groups folder '") + 
			                     TrimAll(ServiceGroup.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;					 
	Return vParamPresentation;
EndFunction //pmGetReportParametersPresentation

//-----------------------------------------------------------------------------
// Runs report
//-----------------------------------------------------------------------------
Процедура pmGenerate(pSpreadsheet) Экспорт
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
	
	// Initialize report builder query generator attributes
	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
	
	// Fill report parameters
	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
	ReportBuilder.Parameters.Вставить("qService", Service);
	ReportBuilder.Parameters.Вставить("qRoom", Room);
	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(Room));
	vUseServicesList = False;
	vServicesList = New СписокЗначений();
	If ЗначениеЗаполнено(ServiceGroup) Тогда
		If НЕ ServiceGroup.IncludeAll Тогда
			vUseServicesList = True;
			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
		EndIf;
	EndIf;
	ReportBuilder.Parameters.Вставить("qUseServicesList", vUseServicesList);
	ReportBuilder.Parameters.Вставить("qServicesList", vServicesList);
	
	// Execute report builder query
	ReportBuilder.Execute();
	
	//// Apply appearance settings to the report template
	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
	//
	//// Output report to the spreadsheet
	//
	//ReportBuilder.Put(pSpreadsheet);
	////ReportBuilder.Template.Show(); // For debug purpose

	//// Apply appearance settings to the report spreadsheet
	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
КонецПроцедуры //pmGenerate
	
//-----------------------------------------------------------------------------
Процедура pmInitializeReportBuilder() Экспорт
	ReportBuilder = New ReportBuilder();
	
	// Initialize default query text
	QueryText = 
	"SELECT
	|	ServiceSales.Recorder.TypeOfStorno AS TypeOfStorno,
	|	ServiceSales.Фирма AS Фирма,
	|	ServiceSales.Гостиница AS Гостиница,
	|	ServiceSales.Валюта AS Валюта,
	|	ServiceSales.Услуга AS Услуга,
	|	ServiceSales.УчетнаяДата AS УчетнаяДата,
	|	ServiceSales.НомерРазмещения AS НомерРазмещения,
	|	ServiceSales.Контрагент,
	|	ServiceSales.Клиент AS Клиент,
	|	ServiceSales.Recorder,
	|	ServiceSales.ДокОснование,
	|	ServiceSales.Цена,
	|	-ServiceSales.Количество AS Количество,
	|	-ServiceSales.Продажи AS Сумма,
	|	-ServiceSales.ПродажиБезНДС AS SumWithoutVAT,
	|	-ServiceSales.СуммаКомиссии AS СуммаКомиссии,
	|	-ServiceSales.КомиссияБезНДС AS КомиссияБезНДС,
	|	-ServiceSales.СуммаСкидки AS СуммаСкидки,
	|	-ServiceSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
	|	1 AS NumberOfStornos,
	|	ServiceSales.Автор
	|{SELECT
	|	TypeOfStorno,
	|	Фирма.*,
	|	Гостиница.*,
	|	Валюта.*,
	|	Услуга.*,
	|	УчетнаяДата,
	|	Цена,
	|	НомерРазмещения.*,
	|	ServiceSales.Ресурс.*,
	|	ServiceSales.Агент.*,
	|	Контрагент.*,
	|	ServiceSales.Договор.*,
	|	ServiceSales.ТипКлиента.*,
	|	ServiceSales.МаретингНапрвл.*,
	|	ServiceSales.ИсточИнфоГостиница.*,
	|	Клиент.*,
	|	ServiceSales.СчетПроживания.*,
	|	Recorder.*,
	|	ДокОснование.*,
	|	ServiceSales.ГруппаГостей.*,
	|	ServiceSales.TripPurpose.*,
	|	ServiceSales.Клиент.Age AS ClientAge,
	|	ServiceSales.Клиент.Гражданство.* AS ClientCitizenship,
	|	ServiceSales.Клиент.Region AS ClientRegion,
	|	ServiceSales.Клиент.City AS ClientCity,
	|	ServiceSales.КолДопМест,
	|	ServiceSales.КоличествоМест,
	|	ServiceSales.КоличествоМестНомер,
	|	ServiceSales.КоличествоЧеловек,
	|	ServiceSales.КоличествоГостейНомер,
	|	ServiceSales.КоличествоНомеров,
	|	ServiceSales.СтавкаНДС.*,
	|	ServiceSales.ТипНомера.*,
	|	ServiceSales.RoomRateType.*,
	|	ServiceSales.Тариф.*,
	|	ServiceSales.PointInTime,
	|	Автор.*,
	|	(NULL) AS EmptyColumn,
	|	Количество,
	|	Сумма,
	|	SumWithoutVAT,
	|	СуммаКомиссии,
	|	КомиссияБезНДС,
	|	СуммаСкидки,
	|	СуммаСкидкиБезНДС,
	|	NumberOfStornos}
	|FROM
	|	AccumulationRegister.Продажи AS ServiceSales
	|WHERE
	|	ServiceSales.ЭтоСторно
	|	AND ServiceSales.Автор IN HIERARCHY(&qEmployee)
	|	AND ServiceSales.Гостиница IN HIERARCHY(&qHotel)
	|	AND ServiceSales.Period BETWEEN &qPeriodFrom AND &qPeriodTo
	|	AND ServiceSales.Услуга IN HIERARCHY(&qService)
	|	AND (ServiceSales.НомерРазмещения IN HIERARCHY (&qRoom)
	|			OR &qRoomIsEmpty)
	|	AND (ServiceSales.Услуга IN (&qServicesList)
	|			OR (NOT &qUseServicesList))
	|{WHERE
	|	ServiceSales.Recorder.TypeOfStorno AS TypeOfStorno,
	|	ServiceSales.Period,
	|	ServiceSales.Recorder.*,
	|	ServiceSales.Валюта.*,
	|	ServiceSales.Гостиница.*,
	|	ServiceSales.Услуга.*,
	|	ServiceSales.Цена,
	|	ServiceSales.ТипКлиента.*,
	|	ServiceSales.МаретингНапрвл.*,
	|	ServiceSales.ИсточИнфоГостиница.*,
	|	ServiceSales.Фирма.*,
	|	ServiceSales.УчетнаяДата,
	|	ServiceSales.ДокОснование.*,
	|	ServiceSales.СчетПроживания.*,
	|	ServiceSales.ГруппаГостей.*,
	|	ServiceSales.Клиент.*,
	|	ServiceSales.TripPurpose.*,
	|	ServiceSales.Клиент.Age AS ClientAge,
	|	ServiceSales.Клиент.Гражданство.* AS ClientCitizenship,
	|	ServiceSales.Клиент.Region AS ClientRegion,
	|	ServiceSales.Клиент.City AS ClientCity,
	|	ServiceSales.КолДопМест,
	|	ServiceSales.КоличествоМест,
	|	ServiceSales.КоличествоМестНомер,
	|	ServiceSales.КоличествоЧеловек,
	|	ServiceSales.КоличествоГостейНомер,
	|	ServiceSales.КоличествоНомеров,
	|	ServiceSales.НомерРазмещения.*,
	|	ServiceSales.Ресурс.*,
	|	ServiceSales.СтавкаНДС.*,
	|	ServiceSales.Агент.*,
	|	ServiceSales.Контрагент.*,
	|	ServiceSales.Договор.*,
	|	ServiceSales.ТипНомера.*,
	|	ServiceSales.Автор.*,
	|	ServiceSales.RoomRateType.*,
	|	ServiceSales.Тариф.*,
	|	(-ServiceSales.Количество) AS Количество,
	|	(-ServiceSales.Продажи) AS Сумма,
	|	(-ServiceSales.ПродажиБезНДС) AS SumWithoutVAT,
	|	(-ServiceSales.СуммаКомиссии) AS СуммаКомиссии,
	|	(-ServiceSales.КомиссияБезНДС) AS КомиссияБезНДС,
	|	(-ServiceSales.СуммаСкидки) AS СуммаСкидки,
	|	(-ServiceSales.СуммаСкидкиБезНДС) AS DiscountSumWithoutVAT}
	|
	|ORDER BY
	|	Валюта,
	|	Гостиница,
	|	Услуга,
	|	ServiceSales.Period
	|{ORDER BY
	|	TypeOfStorno,
	|	ServiceSales.Period,
	|	Валюта.*,
	|	Гостиница.*,
	|	Услуга.*,
	|	Цена,
	|	ServiceSales.ТипКлиента.*,
	|	ServiceSales.ИсточИнфоГостиница.*,
	|	Фирма.*,
	|	УчетнаяДата,
	|	Recorder.*,
	|	ДокОснование.*,
	|	ServiceSales.СчетПроживания.*,
	|	ServiceSales.ГруппаГостей.*,
	|	Клиент.*,
	|	ServiceSales.TripPurpose.*,
	|	ServiceSales.Клиент.Age AS ClientAge,
	|	ServiceSales.Клиент.Гражданство.* AS ClientCitizenship,
	|	ServiceSales.Клиент.Region AS ClientRegion,
	|	ServiceSales.Клиент.City AS ClientCity,
	|	ServiceSales.КолДопМест,
	|	ServiceSales.КоличествоМест,
	|	ServiceSales.КоличествоМестНомер,
	|	ServiceSales.КоличествоГостейНомер,
	|	ServiceSales.КоличествоНомеров,
	|	НомерРазмещения.*,
	|	ServiceSales.Ресурс.*,
	|	ServiceSales.СтавкаНДС.*,
	|	ServiceSales.Агент.*,
	|	Контрагент.*,
	|	ServiceSales.Договор.*,
	|	ServiceSales.ТипНомера.*,
	|	Автор.*,
	|	ServiceSales.RoomRateType.*,
	|	ServiceSales.Тариф.*}
	|TOTALS
	|	SUM(Количество),
	|	SUM(Сумма),
	|	SUM(SumWithoutVAT),
	|	SUM(СуммаКомиссии),
	|	SUM(КомиссияБезНДС),
	|	SUM(СуммаСкидки),
	|	SUM(СуммаСкидкиБезНДС),
	|	SUM(NumberOfStornos)
	|BY
	|	OVERALL,
	|	Валюта,
	|	Гостиница,
	|	Услуга
	|{TOTALS BY
	|	TypeOfStorno,
	|	Recorder.*,
	|	Валюта.*,
	|	Гостиница.*,
	|	Услуга.*,
	|	Цена,
	|	ServiceSales.ТипКлиента.*,
	|	ServiceSales.МаретингНапрвл.*,
	|	ServiceSales.ИсточИнфоГостиница.*,
	|	Фирма.*,
	|	УчетнаяДата,
	|	ДокОснование.*,
	|	ServiceSales.СчетПроживания.*,
	|	ServiceSales.ГруппаГостей.*,
	|	Клиент.*,
	|	ServiceSales.TripPurpose.*,
	|	ServiceSales.Клиент.Age AS ClientAge,
	|	ServiceSales.Клиент.Гражданство.* AS ClientCitizenship,
	|	ServiceSales.Клиент.Region AS ClientRegion,
	|	ServiceSales.Клиент.City AS ClientCity,
	|	НомерРазмещения.*,
	|	ServiceSales.Ресурс.*,
	|	ServiceSales.СтавкаНДС.*,
	|	ServiceSales.Агент.*,
	|	Контрагент.*,
	|	ServiceSales.Договор.*,
	|	ServiceSales.ТипНомера.*,
	|	Автор.*,
	|	ServiceSales.RoomRateType.*,
	|	ServiceSales.Тариф.*}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Charges storno audit';RU='Аудит сторно начислений';de='Buchprüfung des Storno der Berechnungen'");
	
	// Fill report builder fields presentations from the report template
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
