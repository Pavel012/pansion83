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
//		PeriodFrom = BegOfMonth(CurrentDate()); // For beg of month
//		PeriodTo = EndOfDay(CurrentDate());
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
//	If ЗначениеЗаполнено(HotelProduct) Тогда
//		If НЕ HotelProduct.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Путевка '; en = 'Гостиница product '") + 
//			                     TrimAll(HotelProduct.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Тип путевок/курсовок '; en = 'Гостиница products type '") + 
//			                     TrimAll(HotelProduct.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
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
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qHotelProduct", HotelProduct);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotelProduct", НЕ ЗначениеЗаполнено(HotelProduct));
//	ReportBuilder.Parameters.Вставить("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
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
//	|	IssuedHotelProducts.ProductCode AS ProductCode,
//	|	IssuedHotelProducts.Recorder,
//	|	IssuedHotelProducts.Гостиница,
//	|	IssuedHotelProducts.Фирма,
//	|	IssuedHotelProducts.Контрагент,
//	|	IssuedHotelProducts.Договор,
//	|	IssuedHotelProducts.BillOfShipment,
//	|	IssuedHotelProducts.HotelProductParent,
//	|	IssuedHotelProducts.CheckInDate,
//	|	IssuedHotelProducts.Продолжительность,
//	|	IssuedHotelProducts.CheckOutDate,
//	|	IssuedHotelProducts.Цена,
//	|	IssuedHotelProducts.Валюта,
//	|	1 AS Count
//	|{SELECT
//	|	ProductCode,
//	|	Recorder.*,
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	BillOfShipment,
//	|	HotelProductParent.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	Цена,
//	|	Валюта.*,
//	|	Count}
//	|FROM
//	|	InformationRegister.IssuedHotelProducts AS IssuedHotelProducts
//	|WHERE
//	|	IssuedHotelProducts.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (IssuedHotelProducts.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qIsEmptyCustomer)
//	|	AND (IssuedHotelProducts.Договор = &qContract
//	|			OR &qIsEmptyContract)
//	|	AND (IssuedHotelProducts.HotelProductParent IN HIERARCHY (&qHotelProduct)
//	|			OR &qIsEmptyHotelProduct)
//	|	AND (NOT IssuedHotelProducts.ProductCode IN
//	|				(SELECT
//	|					Accommodations.ПутевкаКурсовка.Code
//	|				FROM
//	|					Document.Размещение AS Accommodations
//	|				WHERE
//	|					Accommodations.Posted
//	|					AND Accommodations.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					AND Accommodations.CheckInDate >= &qPeriodFrom
//	|					AND Accommodations.CheckInDate < &qPeriodTo
//	|					AND Accommodations.Гостиница IN HIERARCHY (&qHotel)
//	|		
//	|				UNION ALL
//	|		
//	|				SELECT
//	|					Reservations.ПутевкаКурсовка.Code
//	|				FROM
//	|					Document.Reservation AS Reservations
//	|				WHERE
//	|					Reservations.Posted
//	|					AND Reservations.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					AND Reservations.CheckInDate >= &qPeriodFrom
//	|					AND Reservations.CheckInDate < &qPeriodTo
//	|					AND Reservations.Гостиница IN HIERARCHY (&qHotel)))
//	|{WHERE
//	|	IssuedHotelProducts.ProductCode,
//	|	IssuedHotelProducts.Recorder.*,
//	|	IssuedHotelProducts.Гостиница.*,
//	|	IssuedHotelProducts.Фирма.*,
//	|	IssuedHotelProducts.Контрагент.*,
//	|	IssuedHotelProducts.Договор.*,
//	|	IssuedHotelProducts.BillOfShipment,
//	|	IssuedHotelProducts.HotelProductParent.*,
//	|	IssuedHotelProducts.CheckInDate,
//	|	IssuedHotelProducts.Продолжительность,
//	|	IssuedHotelProducts.CheckOutDate,
//	|	IssuedHotelProducts.Цена,
//	|	IssuedHotelProducts.Валюта.*,
//	|	(1) AS Count}
//	|
//	|ORDER BY
//	|	ProductCode
//	|{ORDER BY
//	|	ProductCode,
//	|	Recorder.*,
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	BillOfShipment,
//	|	HotelProductParent.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	Цена,
//	|	Валюта.*,
//	|	Count}
//	|TOTALS
//	|	SUM(Count)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	Recorder.*,
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	BillOfShipment,
//	|	HotelProductParent.*,
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
//	ReportBuilder.HeaderText = NStr("EN='Гостиница products issued but not sold';RU='Отгруженные но не проданные путевки';de='Ausgeladene aber nicht verkaufte Reiseschecks'");
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
