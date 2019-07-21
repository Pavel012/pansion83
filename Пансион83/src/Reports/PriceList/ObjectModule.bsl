////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------

////-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes

////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes

////-----------------------------------------------------------------------------
//// Initialize attributes with default values
//// Attention: This procedure could be called AFTER some attributes initialization
//// routine, so it SHOULD NOT reset attributes being set before
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill parameters with default values
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If НЕ ЗначениеЗаполнено(Тариф) Тогда
//				Тариф = Гостиница.Тариф;
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Period) Тогда
//		Period = CurrentDate(); // For today
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues

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
//	If НЕ ЗначениеЗаполнено(Period) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("ru = 'Цены на '; en = 'Prices per '") + 
//		                     Format(Period, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(Тариф) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров rate ';ru='Тариф ';de='Tarif'") + 
//							 TrimAll(Тариф.Description) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(ClientType) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Client type ';ru='Тип клиента ';de='Kundentyp'") + 
//							 TrimAll(ClientType.Description) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(CalendarDayType) Тогда
//		If НЕ CalendarDayType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Тип дня '; en = 'Day type '") + 
//			                     CalendarDayType.GetObject().pmGetDayTypeDescription(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа типов дней '; en = 'Day types folder '") + 
//			                     CalendarDayType.GetObject().pmGetDayTypeDescription(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation

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
//	ReportBuilder.Parameters.Вставить("qPeriod", Period);
//	ReportBuilder.Parameters.Вставить("qRoomRate", Тариф);
//	ReportBuilder.Parameters.Вставить("qClientType", ClientType);
//	ReportBuilder.Parameters.Вставить("qCalendarDayType", CalendarDayType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCalendarDayType", НЕ ЗначениеЗаполнено(CalendarDayType));
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
//	|	RoomRatePrices.ТипНомера AS ТипНомера,
//	|	RoomRatePrices.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
//	|	RoomRatePrices.ВидРазмещения AS ВидРазмещения,
//	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки AS AccommodationTypeSortCode,
//	|	RoomRatePrices.CalendarDayType AS CalendarDayType,
//	|	RoomRatePrices.CalendarDayType.ПорядокСортировки AS CalendarDayTypeSortCode,
//	|	RoomRatePrices.PriceTag AS PriceTag,
//	|	RoomRatePrices.PriceTag.ПорядокСортировки AS PriceTagSortCode,
//	|	RoomRatePrices.Валюта AS Валюта,
//	|	SUM(CASE
//	|			WHEN RoomRatePrices.IsPricePerPerson
//	|					AND RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation > 1
//	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation
//	|			WHEN RoomRatePrices.IsPricePerPerson
//	|					AND RoomRatePrices.ВидРазмещения.КоличествоЧеловек > 1
//	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.КоличествоЧеловек
//	|			ELSE RoomRatePrices.Цена
//	|		END) AS Цена
//	|{SELECT
//	|	ТипНомера.*,
//	|	ВидРазмещения.*,
//	|	CalendarDayType.*,
//	|	PriceTag.*,
//	|	Цена,
//	|	Валюта.*}
//	|FROM
//	|	InformationRegister.RoomRatePrices AS RoomRatePrices
//	|WHERE
//	|	RoomRatePrices.Гостиница = &qHotel
//	|	AND RoomRatePrices.Тариф = &qRoomRate
//	|	AND RoomRatePrices.ТипКлиента = &qClientType
//	|	AND (RoomRatePrices.CalendarDayType IN HIERARCHY (&qCalendarDayType)
//	|			OR &qIsEmptyCalendarDayType)
//	|	AND RoomRatePrices.IsInPrice = TRUE
//	|	AND RoomRatePrices.ПриказТариф IN
//	|			(SELECT
//	|				RoomRatesSliceLast.ПриказТариф AS ПриказТариф
//	|			FROM
//	|				InformationRegister.Тарифы.SliceLast(&qPeriod, Гостиница = &qHotel
//	|					AND Тариф = &qRoomRate) AS RoomRatesSliceLast)
//	|{WHERE
//	|	RoomRatePrices.Гостиница.*,
//	|	RoomRatePrices.Тариф.*,
//	|	RoomRatePrices.CalendarDayType.*,
//	|	RoomRatePrices.PriceTag.*,
//	|	RoomRatePrices.ТипКлиента.*,
//	|	RoomRatePrices.ТипНомера.*,
//	|	RoomRatePrices.ВидРазмещения.*}
//	|
//	|GROUP BY
//	|	RoomRatePrices.ТипНомера,
//	|	RoomRatePrices.ВидРазмещения,
//	|	RoomRatePrices.CalendarDayType,
//	|	RoomRatePrices.PriceTag,
//	|	RoomRatePrices.Валюта,
//	|	RoomRatePrices.ТипНомера.ПорядокСортировки,
//	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки,
//	|	RoomRatePrices.CalendarDayType.ПорядокСортировки,
//	|	RoomRatePrices.PriceTag.ПорядокСортировки
//	|
//	|ORDER BY
//	|	RoomTypeSortCode,
//	|	AccommodationTypeSortCode,
//	|	CalendarDayTypeSortCode,
//	|	PriceTagSortCode,
//	|	Валюта
//	|{ORDER BY
//	|	ТипНомера.*,
//	|	RoomTypeSortCode,
//	|	ВидРазмещения.*,
//	|	AccommodationTypeSortCode,
//	|	CalendarDayType.*,
//	|	CalendarDayTypeSortCode,
//	|	PriceTag.*,
//	|	PriceTagSortCode,
//	|	Валюта.*,
//	|	Price}
//	|TOTALS
//	|	MAX(Цена)
//	|BY
//	|	ТипНомера,
//	|	ВидРазмещения
//	|{TOTALS BY
//	|	ТипНомера.*,
//	|	ВидРазмещения.*,
//	|	CalendarDayType.*,
//	|	PriceTag.*,
//	|	Валюта.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Price list';RU='Прайс-лист';de='Preisliste'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder

////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
