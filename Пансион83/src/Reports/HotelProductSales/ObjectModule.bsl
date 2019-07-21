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
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qHotelProduct", HotelProduct);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotelProduct", НЕ ЗначениеЗаполнено(HotelProduct));
//	ReportBuilder.Parameters.Вставить("qEmptyHotelProduct", Справочники.HotelProducts.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qDurationCalculationRuleTypeByDays", Перечисления.DurationCalculationRuleTypes.ByDays);
//	ReportBuilder.Parameters.Вставить("qTogether", Перечисления.ВидыРазмещений.Together);
//	ReportBuilder.Parameters.Вставить("qAdditionalBed", Перечисления.ВидыРазмещений.AdditionalBed);
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
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	ПродажиПутевокКурсовок.Агент AS Агент,
//	|	ПродажиПутевокКурсовок.Контрагент AS Контрагент,
//	|	ПродажиПутевокКурсовок.Договор AS Договор,
//	|	ПродажиПутевокКурсовок.ГруппаГостей AS ГруппаГостей,
//	|	ПродажиПутевокКурсовок.Клиент AS Клиент,
//	|	ПродажиПутевокКурсовок.Count AS Count,
//	|	CASE
//	|		WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qTogether
//	|			THEN 0
//	|		WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qAdditionalBed
//	|			THEN 0
//	|		ELSE ПродажиПутевокКурсовок.Count
//	|	END AS FamilyCount,
//	|	ПродажиПутевокКурсовок.Продажи AS Продажи,
//	|	ПродажиПутевокКурсовок.ДоходНомеров AS ДоходНомеров,
//	|	ПродажиПутевокКурсовок.ПродажиБезНДС AS ПродажиБезНДС,
//	|	ПродажиПутевокКурсовок.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	ПродажиПутевокКурсовок.СуммаКомиссии AS СуммаКомиссии,
//	|	ПродажиПутевокКурсовок.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ПродажиПутевокКурсовок.СуммаСкидки AS СуммаСкидки,
//	|	ПродажиПутевокКурсовок.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ПродажиПутевокКурсовок.ПроданоНомеров AS ПроданоНомеров,
//	|	ПродажиПутевокКурсовок.ПроданоМест AS ПроданоМест,
//	|	ПродажиПутевокКурсовок.ПроданоДопМест AS ПроданоДопМест,
//	|	ПродажиПутевокКурсовок.ЧеловекаДни AS ЧеловекаДни,
//	|	ПродажиПутевокКурсовок.ЗаездГостей AS ЗаездГостей,
//	|	ПродажиПутевокКурсовок.ЗаездНомеров AS ЗаездНомеров,
//	|	ПродажиПутевокКурсовок.ЗаездМест AS ЗаездМест,
//	|	ПродажиПутевокКурсовок.ЗаездДополнительныхМест AS ЗаездДополнительныхМест
//	|{SELECT
//	|	Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	Гостиница.*,
//	|	ПутевкаКурсовка.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.Parent.* AS HotelProductParent,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	Count,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qTogether
//	|				THEN 0
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qAdditionalBed
//	|				THEN 0
//	|			ELSE ПродажиПутевокКурсовок.Count
//	|		END) AS FamilyCount,
//	|	ПродажиПутевокКурсовок.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПродажиПутевокКурсовок.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ПродажиПутевокКурсовок.Тариф.* AS Тариф,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.* AS ВидРазмещения,
//	|	ПродажиПутевокКурсовок.ТипКлиента.* AS ТипКлиента,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПродажиПутевокКурсовок.TripPurpose.* AS TripPurpose,
//	|	ПродажиПутевокКурсовок.ТипСкидки.* AS ТипСкидки,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.* AS НомерРазмещения,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.ТипНомера.* AS ТипНомера,
//	|	ПродажиПутевокКурсовок.CheckInDate AS CheckInDate,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.Тариф.DurationCalculationRuleType = &qDurationCalculationRuleTypeByDays
//	|				THEN DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), ENDOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|			WHEN BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY) = BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY)
//	|				THEN 1
//	|			ELSE DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|		END) AS Продолжительность,
//	|	ПродажиПутевокКурсовок.CheckOutDate AS CheckOutDate,
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
//	|	AdditionalBedsCheckedIn}
//	|FROM
//	|	(SELECT
//	|		HotelProductSalesTurnovers.Валюта AS Валюта,
//	|		HotelProductSalesTurnovers.Гостиница AS Гостиница,
//	|		HotelProductSalesTurnovers.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|		HotelProductSalesTurnovers.Агент AS Агент,
//	|		HotelProductSalesTurnovers.Контрагент AS Контрагент,
//	|		HotelProductSalesTurnovers.Договор AS Договор,
//	|		HotelProductSalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|		HotelProductSalesTurnovers.Клиент AS Клиент,
//	|		HotelProductSalesTurnovers.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|		HotelProductSalesTurnovers.СпособОплаты AS PlannedPaymentMethod,
//	|		HotelProductSalesTurnovers.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|		HotelProductSalesTurnovers.ДокОснование.Тариф AS Тариф,
//	|		HotelProductSalesTurnovers.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|		HotelProductSalesTurnovers.ДокОснование.ТипКлиента AS ТипКлиента,
//	|		HotelProductSalesTurnovers.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|		HotelProductSalesTurnovers.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		HotelProductSalesTurnovers.ДокОснование.TripPurpose AS TripPurpose,
//	|		HotelProductSalesTurnovers.ДокОснование.ТипСкидки AS ТипСкидки,
//	|		MIN(CASE
//	|				WHEN NOT HotelProductSalesTurnovers.ДокОснование.CheckInDate IS NULL 
//	|					THEN HotelProductSalesTurnovers.ДокОснование.CheckInDate
//	|				WHEN NOT HotelProductSalesTurnovers.СчетПроживания.DateTimeFrom IS NULL 
//	|					THEN HotelProductSalesTurnovers.СчетПроживания.DateTimeFrom
//	|				WHEN NOT HotelProductSalesTurnovers.ДокОснование.DateTimeFrom IS NULL 
//	|					THEN HotelProductSalesTurnovers.ДокОснование.DateTimeFrom
//	|				ELSE &qEmptyDate
//	|			END) AS CheckInDate,
//	|		MAX(CASE
//	|				WHEN NOT HotelProductSalesTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|					THEN HotelProductSalesTurnovers.ДокОснование.CheckOutDate
//	|				WHEN NOT HotelProductSalesTurnovers.СчетПроживания.DateTimeTo IS NULL 
//	|					THEN HotelProductSalesTurnovers.СчетПроживания.DateTimeTo
//	|				WHEN NOT HotelProductSalesTurnovers.ДокОснование.DateTimeTo IS NULL 
//	|					THEN HotelProductSalesTurnovers.ДокОснование.DateTimeTo
//	|				ELSE &qEmptyDate
//	|			END) AS CheckOutDate,
//	|		SUM(HotelProductSalesTurnovers.SalesTurnover) AS Продажи,
//	|		SUM(HotelProductSalesTurnovers.RoomRevenueTurnover) AS ДоходНомеров,
//	|		SUM(HotelProductSalesTurnovers.SalesWithoutVATTurnover) AS ПродажиБезНДС,
//	|		SUM(HotelProductSalesTurnovers.RoomRevenueWithoutVATTurnover) AS ДоходПродажиБезНДС,
//	|		SUM(HotelProductSalesTurnovers.CommissionSumTurnover) AS СуммаКомиссии,
//	|		SUM(HotelProductSalesTurnovers.CommissionSumWithoutVATTurnover) AS КомиссияБезНДС,
//	|		SUM(HotelProductSalesTurnovers.DiscountSumTurnover) AS СуммаСкидки,
//	|		SUM(HotelProductSalesTurnovers.DiscountSumWithoutVATTurnover) AS СуммаСкидкиБезНДС,
//	|		SUM(HotelProductSalesTurnovers.RoomsRentedTurnover) AS ПроданоНомеров,
//	|		SUM(HotelProductSalesTurnovers.BedsRentedTurnover) AS ПроданоМест,
//	|		SUM(HotelProductSalesTurnovers.AdditionalBedsRentedTurnover) AS ПроданоДопМест,
//	|		SUM(HotelProductSalesTurnovers.GuestDaysTurnover) AS ЧеловекаДни,
//	|		SUM(HotelProductSalesTurnovers.GuestsCheckedInTurnover) AS ЗаездГостей,
//	|		SUM(HotelProductSalesTurnovers.RoomsCheckedInTurnover) AS ЗаездНомеров,
//	|		SUM(HotelProductSalesTurnovers.BedsCheckedInTurnover) AS ЗаездМест,
//	|		SUM(HotelProductSalesTurnovers.AdditionalBedsCheckedInTurnover) AS ЗаездДополнительныхМест,
//	|		COUNT(DISTINCT HotelProductSalesTurnovers.ПутевкаКурсовка) AS Count
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Day,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Контрагент IN HIERARCHY (&qCustomer)
//	|						OR &qIsEmptyCustomer)
//	|					AND (Договор = &qContract
//	|						OR &qIsEmptyContract)
//	|					AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|						OR &qIsEmptyHotelProduct)
//	|					AND ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR NOT &qUseServicesList)) AS HotelProductSalesTurnovers
//	|	
//	|	GROUP BY
//	|		HotelProductSalesTurnovers.Валюта,
//	|		HotelProductSalesTurnovers.Гостиница,
//	|		HotelProductSalesTurnovers.ПутевкаКурсовка,
//	|		HotelProductSalesTurnovers.Агент,
//	|		HotelProductSalesTurnovers.Контрагент,
//	|		HotelProductSalesTurnovers.Договор,
//	|		HotelProductSalesTurnovers.ГруппаГостей,
//	|		HotelProductSalesTurnovers.Клиент,
//	|		HotelProductSalesTurnovers.ДокОснование.КоличествоЧеловек,
//	|		HotelProductSalesTurnovers.СпособОплаты,
//	|		HotelProductSalesTurnovers.СчетПроживания.НомерРазмещения,
//	|		HotelProductSalesTurnovers.ДокОснование.Тариф,
//	|		HotelProductSalesTurnovers.ДокОснование.ВидРазмещения,
//	|		HotelProductSalesTurnovers.ДокОснование.ТипКлиента,
//	|		HotelProductSalesTurnovers.ДокОснование.МаретингНапрвл,
//	|		HotelProductSalesTurnovers.ДокОснование.ИсточИнфоГостиница,
//	|		HotelProductSalesTurnovers.ДокОснование.TripPurpose,
//	|		HotelProductSalesTurnovers.ДокОснование.ТипСкидки) AS ПродажиПутевокКурсовок
//	|{WHERE
//	|	ПродажиПутевокКурсовок.Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	ПродажиПутевокКурсовок.Гостиница.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.Parent.* AS HotelProductParent,
//	|	ПродажиПутевокКурсовок.Агент.*,
//	|	ПродажиПутевокКурсовок.Контрагент.*,
//	|	ПродажиПутевокКурсовок.Договор.*,
//	|	ПродажиПутевокКурсовок.ГруппаГостей.*,
//	|	ПродажиПутевокКурсовок.Клиент.*,
//	|	ПродажиПутевокКурсовок.Count AS Count,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qTogether
//	|				THEN 0
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qAdditionalBed
//	|				THEN 0
//	|			ELSE ПродажиПутевокКурсовок.Count
//	|		END) AS FamilyCount,
//	|	ПродажиПутевокКурсовок.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПродажиПутевокКурсовок.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ПродажиПутевокКурсовок.Тариф.* AS Тариф,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.* AS ВидРазмещения,
//	|	ПродажиПутевокКурсовок.ТипКлиента.* AS ТипКлиента,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПродажиПутевокКурсовок.TripPurpose.* AS TripPurpose,
//	|	ПродажиПутевокКурсовок.ТипСкидки.* AS ТипСкидки,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.* AS НомерРазмещения,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.ТипНомера.* AS ТипНомера,
//	|	ПродажиПутевокКурсовок.CheckInDate AS CheckInDate,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.Тариф.DurationCalculationRuleType = &qDurationCalculationRuleTypeByDays
//	|				THEN DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), ENDOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|			WHEN BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY) = BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY)
//	|				THEN 1
//	|			ELSE DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|		END) AS Продолжительность,
//	|	ПродажиПутевокКурсовок.CheckOutDate AS CheckOutDate,
//	|	ПродажиПутевокКурсовок.Продажи,
//	|	ПродажиПутевокКурсовок.ДоходНомеров,
//	|	ПродажиПутевокКурсовок.ПродажиБезНДС,
//	|	ПродажиПутевокКурсовок.ДоходПродажиБезНДС,
//	|	ПродажиПутевокКурсовок.СуммаКомиссии,
//	|	ПродажиПутевокКурсовок.КомиссияБезНДС,
//	|	ПродажиПутевокКурсовок.СуммаСкидки,
//	|	ПродажиПутевокКурсовок.СуммаСкидкиБезНДС,
//	|	ПродажиПутевокКурсовок.ПроданоНомеров,
//	|	ПродажиПутевокКурсовок.ПроданоМест,
//	|	ПродажиПутевокКурсовок.ПроданоДопМест,
//	|	ПродажиПутевокКурсовок.ЧеловекаДни,
//	|	ПродажиПутевокКурсовок.ЗаездГостей,
//	|	ПродажиПутевокКурсовок.ЗаездНомеров,
//	|	ПродажиПутевокКурсовок.ЗаездМест,
//	|	ПродажиПутевокКурсовок.AdditionalBedsCheckedIn}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Контрагент,
//	|	ПутевкаКурсовка
//	|{ORDER BY
//	|	Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	Гостиница.*,
//	|	ПутевкаКурсовка.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.Parent.* AS HotelProductParent,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	ПродажиПутевокКурсовок.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПродажиПутевокКурсовок.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ПродажиПутевокКурсовок.Тариф.* AS Тариф,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.* AS ВидРазмещения,
//	|	ПродажиПутевокКурсовок.ТипКлиента.* AS ТипКлиента,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПродажиПутевокКурсовок.TripPurpose.* AS TripPurpose,
//	|	ПродажиПутевокКурсовок.ТипСкидки.* AS ТипСкидки,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.* AS НомерРазмещения,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.ТипНомера.* AS ТипНомера,
//	|	ПродажиПутевокКурсовок.CheckInDate AS CheckInDate,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.Тариф.DurationCalculationRuleType = &qDurationCalculationRuleTypeByDays
//	|				THEN DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), ENDOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|			WHEN BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY) = BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY)
//	|				THEN 1
//	|			ELSE DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|		END) AS Продолжительность,
//	|	ПродажиПутевокКурсовок.CheckOutDate AS CheckOutDate,
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
//	|	AdditionalBedsCheckedIn}
//	|TOTALS
//	|	SUM(Count),
//	|	SUM(FamilyCount),
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
//	|	SUM(ЗаездДополнительныхМест)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Контрагент HIERARCHY
//	|{TOTALS BY
//	|	Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	Гостиница.*,
//	|	ПутевкаКурсовка.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.Parent.* AS HotelProductParent,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.Тариф.DurationCalculationRuleType = &qDurationCalculationRuleTypeByDays
//	|				THEN DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), ENDOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|			WHEN BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY) = BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY)
//	|				THEN 1
//	|			ELSE DATEDIFF(BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckInDate, DAY), BEGINOFPERIOD(ПродажиПутевокКурсовок.CheckOutDate, DAY), DAY)
//	|		END) AS Продолжительность,
//	|	ПродажиПутевокКурсовок.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПродажиПутевокКурсовок.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.* AS НомерРазмещения,
//	|	ПродажиПутевокКурсовок.НомерРазмещения.ТипНомера.* AS ТипНомера,
//	|	ПродажиПутевокКурсовок.Тариф.* AS Тариф,
//	|	ПродажиПутевокКурсовок.ВидРазмещения.* AS ВидРазмещения,
//	|	ПродажиПутевокКурсовок.ТипКлиента.* AS ТипКлиента,
//	|	ПродажиПутевокКурсовок.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПродажиПутевокКурсовок.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПродажиПутевокКурсовок.TripPurpose.* AS TripPurpose,
//	|	ПродажиПутевокКурсовок.ТипСкидки.* AS DiscountType}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Гостиница product sales';RU='Продажи путевок';de='Verkauf von Reiseschecks'");
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
//	   Or pName = "FamilyCount" 
//	   Or pName = "Count" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
