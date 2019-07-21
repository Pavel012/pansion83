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
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qHotelProduct", HotelProduct);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotelProduct", НЕ ЗначениеЗаполнено(HotelProduct));
//	ReportBuilder.Parameters.Вставить("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
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
//	|	ПродажиПутевокКурсовок.Валюта AS Валюта,
//	|	ПродажиПутевокКурсовок.Гостиница AS Гостиница,
//	|	ПродажиПутевокКурсовок.ТипНомера AS ТипНомера,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	ПродажиПутевокКурсовок.Агент AS Агент,
//	|	ПродажиПутевокКурсовок.Контрагент AS Контрагент,
//	|	ПродажиПутевокКурсовок.Договор AS Договор,
//	|	ПродажиПутевокКурсовок.ГруппаГостей AS ГруппаГостей,
//	|	ПродажиПутевокКурсовок.УчетнаяДата AS УчетнаяДата,
//	|	ПродажиПутевокКурсовок.ДокОснование,
//	|	ПродажиПутевокКурсовок.Услуга AS Услуга,
//	|	ПродажиПутевокКурсовок.SalesTurnover AS Продажи,
//	|	ПродажиПутевокКурсовок.RoomRevenueTurnover AS ДоходНомеров,
//	|	ПродажиПутевокКурсовок.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|	ПродажиПутевокКурсовок.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|	ПродажиПутевокКурсовок.CommissionSumTurnover AS СуммаКомиссии,
//	|	ПродажиПутевокКурсовок.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|	ПродажиПутевокКурсовок.DiscountSumTurnover AS СуммаСкидки,
//	|	ПродажиПутевокКурсовок.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|	ПродажиПутевокКурсовок.RoomsRentedTurnover AS ПроданоНомеров,
//	|	ПродажиПутевокКурсовок.BedsRentedTurnover AS ПроданоМест,
//	|	ПродажиПутевокКурсовок.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|	ПродажиПутевокКурсовок.GuestDaysTurnover AS ЧеловекаДни,
//	|	ПродажиПутевокКурсовок.GuestsCheckedInTurnover AS ЗаездГостей,
//	|	ПродажиПутевокКурсовок.RoomsCheckedInTurnover AS ЗаездНомеров,
//	|	ПродажиПутевокКурсовок.BedsCheckedInTurnover AS ЗаездМест,
//	|	ПродажиПутевокКурсовок.AdditionalBedsCheckedInTurnover AS ЗаездДополнительныхМест,
//	|	ПродажиПутевокКурсовок.QuantityTurnover AS Количество
//	|{SELECT
//	|	Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	ПутевкаКурсовка.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ПродажиБезНДС,
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
//	|	Количество,
//	|	УчетнаяДата,
//	|	(WEEK(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingYear,
//	|	ПродажиПутевокКурсовок.СчетПроживания.*,
//	|	ПродажиПутевокКурсовок.Клиент.*,
//	|	ПродажиПутевокКурсовок.Цена,
//	|	ПродажиПутевокКурсовок.Тариф.*,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.*,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.*,
//	|	ПродажиПутевокКурсовок.ТипКлиента.*,
//	|	ПродажиПутевокКурсовок.TripPurpose.*,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.*,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.*,
//	|	ПродажиПутевокКурсовок.Ресурс.*,
//	|	ПродажиПутевокКурсовок.ТипРесурса.*,
//	|	ПродажиПутевокКурсовок.Автор.*,
//	|	ПродажиПутевокКурсовок.Скидка,
//	|	ПродажиПутевокКурсовок.ТипСкидки.*,
//	|	ПродажиПутевокКурсовок.ДисконтКарт.*,
//	|	ПродажиПутевокКурсовок.КомиссияАгента,
//	|	ПродажиПутевокКурсовок.ВидКомиссииАгента.*,
//	|	ПродажиПутевокКурсовок.СпособОплаты.*,
//	|	ПродажиПутевокКурсовок.СтавкаНДС.*,
//	|	ПродажиПутевокКурсовок.Фирма.*}
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|					OR &qIsEmptyHotelProduct)
//	|				AND (ПутевкаКурсовка <> &qEmptyHotelProduct)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR (NOT &qUseServicesList))) AS ПродажиПутевокКурсовок
//	|{WHERE
//	|	ПродажиПутевокКурсовок.Валюта.*,
//	|	ПродажиПутевокКурсовок.Гостиница.*,
//	|	ПродажиПутевокКурсовок.ТипНомера.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.*,
//	|	ПродажиПутевокКурсовок.Агент.*,
//	|	ПродажиПутевокКурсовок.Контрагент.*,
//	|	ПродажиПутевокКурсовок.Договор.*,
//	|	ПродажиПутевокКурсовок.ГруппаГостей.*,
//	|	ПродажиПутевокКурсовок.УчетнаяДата,
//	|	ПродажиПутевокКурсовок.ДокОснование.*,
//	|	ПродажиПутевокКурсовок.Услуга.*,
//	|	ПродажиПутевокКурсовок.SalesTurnover,
//	|	ПродажиПутевокКурсовок.RoomRevenueTurnover,
//	|	ПродажиПутевокКурсовок.SalesWithoutVATTurnover,
//	|	ПродажиПутевокКурсовок.RoomRevenueWithoutVATTurnover,
//	|	ПродажиПутевокКурсовок.CommissionSumTurnover,
//	|	ПродажиПутевокКурсовок.CommissionSumWithoutVATTurnover,
//	|	ПродажиПутевокКурсовок.DiscountSumTurnover,
//	|	ПродажиПутевокКурсовок.DiscountSumWithoutVATTurnover,
//	|	ПродажиПутевокКурсовок.RoomsRentedTurnover,
//	|	ПродажиПутевокКурсовок.BedsRentedTurnover,
//	|	ПродажиПутевокКурсовок.AdditionalBedsRentedTurnover,
//	|	ПродажиПутевокКурсовок.GuestDaysTurnover,
//	|	ПродажиПутевокКурсовок.GuestsCheckedInTurnover,
//	|	ПродажиПутевокКурсовок.RoomsCheckedInTurnover,
//	|	ПродажиПутевокКурсовок.BedsCheckedInTurnover,
//	|	ПродажиПутевокКурсовок.AdditionalBedsCheckedInTurnover,
//	|	ПродажиПутевокКурсовок.QuantityTurnover,
//	|	ПродажиПутевокКурсовок.СчетПроживания.*,
//	|	ПродажиПутевокКурсовок.Клиент.*,
//	|	ПродажиПутевокКурсовок.Цена,
//	|	ПродажиПутевокКурсовок.Услуга.*,
//	|	ПродажиПутевокКурсовок.Тариф.*,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.*,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.*,
//	|	ПродажиПутевокКурсовок.ТипКлиента.*,
//	|	ПродажиПутевокКурсовок.TripPurpose.*,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.*,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.*,
//	|	ПродажиПутевокКурсовок.Ресурс.*,
//	|	ПродажиПутевокКурсовок.ТипРесурса.*,
//	|	ПродажиПутевокКурсовок.Автор.*,
//	|	ПродажиПутевокКурсовок.Скидка,
//	|	ПродажиПутевокКурсовок.ТипСкидки.*,
//	|	ПродажиПутевокКурсовок.ДисконтКарт.*,
//	|	ПродажиПутевокКурсовок.КомиссияАгента,
//	|	ПродажиПутевокКурсовок.ВидКомиссииАгента.*,
//	|	ПродажиПутевокКурсовок.СпособОплаты.*,
//	|	ПродажиПутевокКурсовок.СтавкаНДС.*,
//	|	ПродажиПутевокКурсовок.Фирма.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS RoomQuota}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	ТипНомера,
//	|	ПутевкаКурсовка
//	|{ORDER BY
//	|	Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	ПутевкаКурсовка.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ПродажиБезНДС,
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
//	|	Количество,
//	|	УчетнаяДата,
//	|	(WEEK(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingYear,
//	|	ПродажиПутевокКурсовок.СчетПроживания.*,
//	|	ПродажиПутевокКурсовок.Клиент.*,
//	|	ПродажиПутевокКурсовок.Цена,
//	|	ПродажиПутевокКурсовок.Услуга.*,
//	|	ПродажиПутевокКурсовок.Тариф.*,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.*,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.*,
//	|	ПродажиПутевокКурсовок.ТипКлиента.*,
//	|	ПродажиПутевокКурсовок.TripPurpose.*,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.*,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.*,
//	|	ПродажиПутевокКурсовок.Ресурс.*,
//	|	ПродажиПутевокКурсовок.ТипРесурса.*,
//	|	ПродажиПутевокКурсовок.Автор.*,
//	|	ПродажиПутевокКурсовок.Скидка,
//	|	ПродажиПутевокКурсовок.ТипСкидки.*,
//	|	ПродажиПутевокКурсовок.ДисконтКарт.*,
//	|	ПродажиПутевокКурсовок.КомиссияАгента,
//	|	ПродажиПутевокКурсовок.ВидКомиссииАгента.*,
//	|	ПродажиПутевокКурсовок.СпособОплаты.*,
//	|	ПродажиПутевокКурсовок.СтавкаНДС.*,
//	|	ПродажиПутевокКурсовок.Фирма.*}
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(ДоходНомеров),
//	|	SUM(ПродажиБезНДС),
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
//	|	Валюта,
//	|	ТипНомера HIERARCHY,
//	|	ПутевкаКурсовка HIERARCHY
//	|{TOTALS BY
//	|	ПродажиПутевокКурсовок.Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	ПродажиПутевокКурсовок.Гостиница.*,
//	|	ПродажиПутевокКурсовок.ТипНомера.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.*,
//	|	ПродажиПутевокКурсовок.Агент.*,
//	|	ПродажиПутевокКурсовок.Контрагент.*,
//	|	ПродажиПутевокКурсовок.Договор.*,
//	|	ПродажиПутевокКурсовок.ГруппаГостей.*,
//	|	ПродажиПутевокКурсовок.ДокОснование.*,
//	|	ПродажиПутевокКурсовок.Услуга.*,
//	|	ПродажиПутевокКурсовок.УчетнаяДата,
//	|	(WEEK(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПродажиПутевокКурсовок.УчетнаяДата)) AS AccountingYear,
//	|	ПродажиПутевокКурсовок.СчетПроживания.*,
//	|	ПродажиПутевокКурсовок.Клиент.*,
//	|	ПродажиПутевокКурсовок.Цена,
//	|	ПродажиПутевокКурсовок.Тариф.*,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.*,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.*,
//	|	ПродажиПутевокКурсовок.ТипКлиента.*,
//	|	ПродажиПутевокКурсовок.TripPurpose.*,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.*,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.*,
//	|	ПродажиПутевокКурсовок.Ресурс.*,
//	|	ПродажиПутевокКурсовок.ТипРесурса.*,
//	|	ПродажиПутевокКурсовок.Автор.*,
//	|	ПродажиПутевокКурсовок.Скидка,
//	|	ПродажиПутевокКурсовок.ТипСкидки.*,
//	|	ПродажиПутевокКурсовок.ДисконтКарт.*,
//	|	ПродажиПутевокКурсовок.КомиссияАгента,
//	|	ПродажиПутевокКурсовок.ВидКомиссииАгента.*,
//	|	ПродажиПутевокКурсовок.СпособОплаты.*,
//	|	ПродажиПутевокКурсовок.СтавкаНДС.*,
//	|	ПродажиПутевокКурсовок.Фирма.*,
//	|	ПродажиПутевокКурсовок.Гостиница.*,
//	|	ПродажиПутевокКурсовок.Валюта.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Гостиница product sales turnovers';RU='Обороты продаж путевок и курсовок';de='Umsätze der Verkäufe von Reiseschecks und Kurkarten'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//Function pmIsResource(pName) Экспорт
//	If pName = "Продажи" 
//	   Or pName = "ДоходНомеров" 
//	   Or pName = "ПродажиБезНДС" 
//	   Or pName = "ДоходПродажиБезНДС" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "ПроданоНомеров" 
//	   Or pName = "ПроданоМест" 
//	   Or pName = "ПроданоДопМест" 
//	   Or pName = "ЧеловекаДни" 
//	   Or pName = "ЗаездГостей" 
//	   Or pName = "ЗаездНомеров" 
//	   Or pName = "ЗаездМест" 
//	   Or pName = "ЗаездДополнительныхМест" 
//	   Or pName = "Количество" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
