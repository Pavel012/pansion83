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
//	// Initialie flags
//	If НЕ ShowHotelProductTotalAmount And 
//	   НЕ ShowHotelProductSales And 
//	   НЕ ShowHotelProductAccountsReceivable And 
//	   НЕ ShowGuestGroupPayments Тогда
//		ShowHotelProductTotalAmount = True;
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
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guest group ';ru='Группа ';de='Gruppe '") + 
//							 TrimAll(GuestGroup.Code) + 
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
//	ReportBuilder.Parameters.Вставить("qPrevPeriodFrom", BegOfMonth(BegOfMonth(PeriodFrom) - 1));
//	ReportBuilder.Parameters.Вставить("qPrevPeriodTo", PeriodFrom - 1);
//	ReportBuilder.Parameters.Вставить("qNextPeriodFrom", PeriodTo + 1);
//	ReportBuilder.Parameters.Вставить("qNextPeriodTo", EndOfMonth(EndOfMonth(PeriodTo) + 1));
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Customers.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qEmptyContract", Справочники.Contracts.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qHotelProduct", HotelProduct);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotelProduct", НЕ ЗначениеЗаполнено(HotelProduct));
//	ReportBuilder.Parameters.Вставить("qEmptyHotelProduct", Справочники.HotelProducts.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qIsEmptyGuestGroup", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qEmptyPaymentMethod", Справочники.СпособОплаты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qDurationCalculationRuleTypeByDays", Перечисления.DurationCalculationRuleTypes.ByDays);
//	ReportBuilder.Parameters.Вставить("qTogether", Перечисления.ВидыРазмещений.Together);
//	ReportBuilder.Parameters.Вставить("qAdditionalBed", Перечисления.ВидыРазмещений.AdditionalBed);
//	ReportBuilder.Parameters.Вставить("qEmptyRoom", Справочники.НомернойФонд.EmptyRef());
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
//	ReportBuilder.Parameters.Вставить("qShowHotelProductTotalAmount", ShowHotelProductTotalAmount);
//	ReportBuilder.Parameters.Вставить("qShowHotelProductSales", ShowHotelProductSales);
//	ReportBuilder.Parameters.Вставить("qShowHotelProductAccountsReceivable", ShowHotelProductAccountsReceivable);
//	ReportBuilder.Parameters.Вставить("qShowGuestGroupPayments", ShowGuestGroupPayments);
//	ReportBuilder.Parameters.Вставить("qEmptyPaymentSection", Справочники.ОтделОплаты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qDepositTransfer", Справочники.СпособОплаты.ПеремещениеДепозита);
//	ReportBuilder.Parameters.Вставить("qShowDifferencesOnly", ShowDifferencesOnly);
//	ReportBuilder.Parameters.Вставить("qSplitPaymentsByColumns", SplitPaymentsByColumns);
//	If IsBlankString(Гостиница.AdditionalServicesFolioCondition) Тогда
//		ReportBuilder.Parameters.Вставить("qFolioFilter", "~!999999999999");
//	Else
//		ReportBuilder.Parameters.Вставить("qFolioFilter", "%" + TrimAll(Гостиница.AdditionalServicesFolioCondition) + "%");
//	EndIf;
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
//	|	HotelProductGroups.ГруппаГостей AS ГруппаГостей,
//	|	HotelProductGroups.СчетПроживания AS СчетПроживания
//	|INTO HotelProductGroups
//	|FROM
//	|	AccumulationRegister.ПродажиПутевокКурсовок.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Period,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|					OR &qIsEmptyHotelProduct)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR NOT &qUseServicesList)) AS HotelProductGroups
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	HotelProductTotalSalesTurnovers.Валюта AS Валюта,
//	|	HotelProductTotalSalesTurnovers.Гостиница AS Гостиница,
//	|	HotelProductTotalSalesTurnovers.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	HotelProductTotalSalesTurnovers.Агент AS Агент,
//	|	CASE
//	|		WHEN HotelProductTotalSalesTurnovers.Контрагент = &qEmptyCustomer
//	|			THEN HotelProductTotalSalesTurnovers.Гостиница.IndividualsCustomer
//	|		ELSE HotelProductTotalSalesTurnovers.Контрагент
//	|	END AS Контрагент,
//	|	CASE
//	|		WHEN HotelProductTotalSalesTurnovers.Контрагент = &qEmptyCustomer
//	|				AND HotelProductTotalSalesTurnovers.Договор = &qEmptyContract
//	|			THEN HotelProductTotalSalesTurnovers.Гостиница.IndividualsContract
//	|		ELSE HotelProductTotalSalesTurnovers.Договор
//	|	END AS Договор,
//	|	HotelProductTotalSalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|	HotelProductTotalSalesTurnovers.Клиент AS Клиент,
//	|	CASE
//	|		WHEN NOT HotelProductTotalSalesTurnovers.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductTotalSalesTurnovers.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductTotalSalesTurnovers.СчетПроживания
//	|		WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование IS NULL 
//	|			THEN HotelProductTotalSalesTurnovers.ДокОснование
//	|		ELSE HotelProductTotalSalesTurnovers.СчетПроживания
//	|	END AS ДокОснование,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|	CASE
//	|		WHEN NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductTotalSalesTurnovers.СпособОплаты
//	|		ELSE &qEmptyPaymentMethod
//	|	END AS СпособОплаты,
//	|	HotelProductTotalSalesTurnovers.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.Тариф AS Тариф,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.ТипКлиента AS ТипКлиента,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.TripPurpose AS TripPurpose,
//	|	HotelProductTotalSalesTurnovers.ДокОснование.ТипСкидки AS ТипСкидки,
//	|	CASE
//	|		WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductTotalSalesTurnovers.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeFrom IS NULL 
//	|			THEN HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeFrom
//	|		WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN HotelProductTotalSalesTurnovers.ДокОснование.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductTotalSalesTurnovers.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeTo IS NULL 
//	|			THEN HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeTo
//	|		WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.DateTimeTo IS NULL 
//	|			THEN HotelProductTotalSalesTurnovers.ДокОснование.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	HotelProductTotalSalesTurnovers.SalesTurnover AS Продажи,
//	|	HotelProductTotalSalesTurnovers.RoomRevenueTurnover AS ДоходНомеров,
//	|	HotelProductTotalSalesTurnovers.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|	HotelProductTotalSalesTurnovers.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|	HotelProductTotalSalesTurnovers.CommissionSumTurnover AS СуммаКомиссии,
//	|	HotelProductTotalSalesTurnovers.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|	HotelProductTotalSalesTurnovers.DiscountSumTurnover AS СуммаСкидки,
//	|	HotelProductTotalSalesTurnovers.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|	HotelProductTotalSalesTurnovers.RoomsRentedTurnover AS ПроданоНомеров,
//	|	HotelProductTotalSalesTurnovers.BedsRentedTurnover AS ПроданоМест,
//	|	HotelProductTotalSalesTurnovers.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|	HotelProductTotalSalesTurnovers.GuestDaysTurnover AS ЧеловекаДни,
//	|	HotelProductTotalSalesTurnovers.GuestsCheckedInTurnover AS ЗаездГостей
//	|INTO HotelProductTotalSales
//	|FROM
//	|	AccumulationRegister.ПродажиПутевокКурсовок.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Period,
//	|			&qShowHotelProductTotalAmount
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|					OR &qIsEmptyHotelProduct)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR NOT &qUseServicesList)) AS HotelProductTotalSalesTurnovers
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	HotelProductSalesTurnovers.Валюта AS Валюта,
//	|	HotelProductSalesTurnovers.Гостиница AS Гостиница,
//	|	HotelProductSalesTurnovers.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	HotelProductSalesTurnovers.Агент AS Агент,
//	|	CASE
//	|		WHEN HotelProductSalesTurnovers.Контрагент = &qEmptyCustomer
//	|			THEN HotelProductSalesTurnovers.Гостиница.IndividualsCustomer
//	|		ELSE HotelProductSalesTurnovers.Контрагент
//	|	END AS Контрагент,
//	|	CASE
//	|		WHEN HotelProductSalesTurnovers.Контрагент = &qEmptyCustomer
//	|				AND HotelProductSalesTurnovers.Договор = &qEmptyContract
//	|			THEN HotelProductSalesTurnovers.Гостиница.IndividualsContract
//	|		ELSE HotelProductSalesTurnovers.Договор
//	|	END AS Договор,
//	|	HotelProductSalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|	HotelProductSalesTurnovers.Клиент AS Клиент,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnovers.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductSalesTurnovers.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductSalesTurnovers.СчетПроживания
//	|		WHEN NOT HotelProductSalesTurnovers.ДокОснование IS NULL 
//	|			THEN HotelProductSalesTurnovers.ДокОснование
//	|		ELSE HotelProductSalesTurnovers.СчетПроживания
//	|	END AS ДокОснование,
//	|	HotelProductSalesTurnovers.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|	CASE
//	|		WHEN NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductSalesTurnovers.СпособОплаты
//	|		ELSE &qEmptyPaymentMethod
//	|	END AS СпособОплаты,
//	|	HotelProductSalesTurnovers.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|	HotelProductSalesTurnovers.ДокОснование.Тариф AS Тариф,
//	|	HotelProductSalesTurnovers.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	HotelProductSalesTurnovers.ДокОснование.ТипКлиента AS ТипКлиента,
//	|	HotelProductSalesTurnovers.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|	HotelProductSalesTurnovers.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	HotelProductSalesTurnovers.ДокОснование.TripPurpose AS TripPurpose,
//	|	HotelProductSalesTurnovers.ДокОснование.ТипСкидки AS ТипСкидки,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnovers.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductSalesTurnovers.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductSalesTurnovers.СчетПроживания.DateTimeFrom IS NULL 
//	|			THEN HotelProductSalesTurnovers.СчетПроживания.DateTimeFrom
//	|		WHEN NOT HotelProductSalesTurnovers.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN HotelProductSalesTurnovers.ДокОснование.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductSalesTurnovers.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductSalesTurnovers.СчетПроживания.DateTimeTo IS NULL 
//	|			THEN HotelProductSalesTurnovers.СчетПроживания.DateTimeTo
//	|		WHEN NOT HotelProductSalesTurnovers.ДокОснование.DateTimeTo IS NULL 
//	|			THEN HotelProductSalesTurnovers.ДокОснование.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	HotelProductSalesTurnovers.SalesTurnover AS Продажи,
//	|	HotelProductSalesTurnovers.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|	HotelProductSalesTurnovers.GuestDaysTurnover AS ЧеловекаДни
//	|INTO HotelProductCurPeriodSales
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Period,
//	|			&qShowHotelProductSales
//	|				AND Услуга.IsHotelProductService
//	|				AND ПутевкаКурсовка <> &qEmptyHotelProduct
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|					OR &qIsEmptyHotelProduct)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR NOT &qUseServicesList)) AS HotelProductSalesTurnovers
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	HotelProductSalesTurnoversPrevPer.Валюта AS Валюта,
//	|	HotelProductSalesTurnoversPrevPer.Гостиница AS Гостиница,
//	|	HotelProductSalesTurnoversPrevPer.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	HotelProductSalesTurnoversPrevPer.Агент AS Агент,
//	|	CASE
//	|		WHEN HotelProductSalesTurnoversPrevPer.Контрагент = &qEmptyCustomer
//	|			THEN HotelProductSalesTurnoversPrevPer.Гостиница.IndividualsCustomer
//	|		ELSE HotelProductSalesTurnoversPrevPer.Контрагент
//	|	END AS Контрагент,
//	|	CASE
//	|		WHEN HotelProductSalesTurnoversPrevPer.Контрагент = &qEmptyCustomer
//	|				AND HotelProductSalesTurnoversPrevPer.Договор = &qEmptyContract
//	|			THEN HotelProductSalesTurnoversPrevPer.Гостиница.IndividualsContract
//	|		ELSE HotelProductSalesTurnoversPrevPer.Договор
//	|	END AS Договор,
//	|	HotelProductSalesTurnoversPrevPer.ГруппаГостей AS ГруппаГостей,
//	|	HotelProductSalesTurnoversPrevPer.Клиент AS Клиент,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductSalesTurnoversPrevPer.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductSalesTurnoversPrevPer.СчетПроживания
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.ДокОснование IS NULL 
//	|			THEN HotelProductSalesTurnoversPrevPer.ДокОснование
//	|		ELSE HotelProductSalesTurnoversPrevPer.СчетПроживания
//	|	END AS ДокОснование,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|	CASE
//	|		WHEN NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductSalesTurnoversPrevPer.СпособОплаты
//	|		ELSE &qEmptyPaymentMethod
//	|	END AS СпособОплаты,
//	|	HotelProductSalesTurnoversPrevPer.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.Тариф AS Тариф,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.ТипКлиента AS ТипКлиента,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.TripPurpose AS TripPurpose,
//	|	HotelProductSalesTurnoversPrevPer.ДокОснование.ТипСкидки AS ТипСкидки,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductSalesTurnoversPrevPer.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.СчетПроживания.DateTimeFrom IS NULL 
//	|			THEN HotelProductSalesTurnoversPrevPer.СчетПроживания.DateTimeFrom
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN HotelProductSalesTurnoversPrevPer.ДокОснование.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductSalesTurnoversPrevPer.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.СчетПроживания.DateTimeTo IS NULL 
//	|			THEN HotelProductSalesTurnoversPrevPer.СчетПроживания.DateTimeTo
//	|		WHEN NOT HotelProductSalesTurnoversPrevPer.ДокОснование.DateTimeTo IS NULL 
//	|			THEN HotelProductSalesTurnoversPrevPer.ДокОснование.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	HotelProductSalesTurnoversPrevPer.SalesTurnover AS Продажи,
//	|	HotelProductSalesTurnoversPrevPer.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|	HotelProductSalesTurnoversPrevPer.GuestDaysTurnover AS ЧеловекаДни
//	|INTO HotelProductPrevPeriodSales
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(
//	|			&qPrevPeriodFrom,
//	|			&qPrevPeriodTo,
//	|			Period,
//	|			&qShowHotelProductSales
//	|				AND Услуга.IsHotelProductService
//	|				AND ПутевкаКурсовка <> &qEmptyHotelProduct
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|					OR &qIsEmptyHotelProduct)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR NOT &qUseServicesList)) AS HotelProductSalesTurnoversPrevPer
//	|		INNER JOIN HotelProductCurPeriodSales AS HotelProductCurPeriodSales
//	|		ON HotelProductSalesTurnoversPrevPer.ПутевкаКурсовка = HotelProductCurPeriodSales.ПутевкаКурсовка
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	HotelProductSalesTurnoversNextPer.Валюта AS Валюта,
//	|	HotelProductSalesTurnoversNextPer.Гостиница AS Гостиница,
//	|	HotelProductSalesTurnoversNextPer.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	HotelProductSalesTurnoversNextPer.Агент AS Агент,
//	|	CASE
//	|		WHEN HotelProductSalesTurnoversNextPer.Контрагент = &qEmptyCustomer
//	|			THEN HotelProductSalesTurnoversNextPer.Гостиница.IndividualsCustomer
//	|		ELSE HotelProductSalesTurnoversNextPer.Контрагент
//	|	END AS Контрагент,
//	|	CASE
//	|		WHEN HotelProductSalesTurnoversNextPer.Контрагент = &qEmptyCustomer
//	|				AND HotelProductSalesTurnoversNextPer.Договор = &qEmptyContract
//	|			THEN HotelProductSalesTurnoversNextPer.Гостиница.IndividualsContract
//	|		ELSE HotelProductSalesTurnoversNextPer.Договор
//	|	END AS Договор,
//	|	HotelProductSalesTurnoversNextPer.ГруппаГостей AS ГруппаГостей,
//	|	HotelProductSalesTurnoversNextPer.Клиент AS Клиент,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductSalesTurnoversNextPer.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductSalesTurnoversNextPer.СчетПроживания
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.ДокОснование IS NULL 
//	|			THEN HotelProductSalesTurnoversNextPer.ДокОснование
//	|		ELSE HotelProductSalesTurnoversNextPer.СчетПроживания
//	|	END AS ДокОснование,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|	CASE
//	|		WHEN NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductSalesTurnoversNextPer.СпособОплаты
//	|		ELSE &qEmptyPaymentMethod
//	|	END AS СпособОплаты,
//	|	HotelProductSalesTurnoversNextPer.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.Тариф AS Тариф,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.ТипКлиента AS ТипКлиента,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.TripPurpose AS TripPurpose,
//	|	HotelProductSalesTurnoversNextPer.ДокОснование.ТипСкидки AS ТипСкидки,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductSalesTurnoversNextPer.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.СчетПроживания.DateTimeFrom IS NULL 
//	|			THEN HotelProductSalesTurnoversNextPer.СчетПроживания.DateTimeFrom
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN HotelProductSalesTurnoversNextPer.ДокОснование.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductSalesTurnoversNextPer.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.СчетПроживания.DateTimeTo IS NULL 
//	|			THEN HotelProductSalesTurnoversNextPer.СчетПроживания.DateTimeTo
//	|		WHEN NOT HotelProductSalesTurnoversNextPer.ДокОснование.DateTimeTo IS NULL 
//	|			THEN HotelProductSalesTurnoversNextPer.ДокОснование.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	HotelProductSalesTurnoversNextPer.SalesTurnover AS Продажи,
//	|	HotelProductSalesTurnoversNextPer.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|	HotelProductSalesTurnoversNextPer.GuestDaysTurnover AS ЧеловекаДни
//	|INTO HotelProductNextPeriodSales
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(
//	|			&qNextPeriodFrom,
//	|			&qNextPeriodTo,
//	|			Period,
//	|			&qShowHotelProductSales
//	|				AND Услуга.IsHotelProductService
//	|				AND ПутевкаКурсовка <> &qEmptyHotelProduct
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|					OR &qIsEmptyHotelProduct)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR NOT &qUseServicesList)) AS HotelProductSalesTurnoversNextPer
//	|		INNER JOIN HotelProductCurPeriodSales AS HotelProductCurPeriodSales
//	|		ON HotelProductSalesTurnoversNextPer.ПутевкаКурсовка = HotelProductCurPeriodSales.ПутевкаКурсовка
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	HotelProductAccountsReceivable.ВалютаРасчетов AS Валюта,
//	|	HotelProductAccountsReceivable.Гостиница AS Гостиница,
//	|	HotelProductAccountsReceivable.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	HotelProductAccountsReceivable.СчетПроживания.Агент AS Агент,
//	|	HotelProductAccountsReceivable.Контрагент AS Контрагент,
//	|	HotelProductAccountsReceivable.Договор AS Договор,
//	|	HotelProductAccountsReceivable.ГруппаГостей AS ГруппаГостей,
//	|	CASE
//	|		WHEN NOT HotelProductAccountsReceivable.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductAccountsReceivable.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductAccountsReceivable.СчетПроживания.Клиент
//	|		ELSE HotelProductAccountsReceivable.Клиент
//	|	END AS Клиент,
//	|	CASE
//	|		WHEN NOT HotelProductAccountsReceivable.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductAccountsReceivable.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductAccountsReceivable.СчетПроживания
//	|		WHEN NOT HotelProductAccountsReceivable.ДокОснование IS NULL 
//	|			THEN HotelProductAccountsReceivable.ДокОснование
//	|		ELSE HotelProductAccountsReceivable.СчетПроживания
//	|	END AS ДокОснование,
//	|	HotelProductAccountsReceivable.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|	CASE
//	|		WHEN NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductAccountsReceivable.СчетПроживания.СпособОплаты
//	|		ELSE &qEmptyPaymentMethod
//	|	END AS СпособОплаты,
//	|	CASE
//	|		WHEN NOT HotelProductAccountsReceivable.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductAccountsReceivable.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductAccountsReceivable.СчетПроживания.НомерРазмещения
//	|		WHEN HotelProductAccountsReceivable.НомерРазмещения <> &qEmptyRoom
//	|			THEN HotelProductAccountsReceivable.НомерРазмещения
//	|		ELSE HotelProductAccountsReceivable.ДокОснование.НомерРазмещения
//	|	END AS НомерРазмещения,
//	|	HotelProductAccountsReceivable.ДокОснование.Тариф AS Тариф,
//	|	HotelProductAccountsReceivable.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	HotelProductAccountsReceivable.ДокОснование.ТипКлиента AS ТипКлиента,
//	|	HotelProductAccountsReceivable.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|	HotelProductAccountsReceivable.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	HotelProductAccountsReceivable.ДокОснование.TripPurpose AS TripPurpose,
//	|	HotelProductAccountsReceivable.ДокОснование.ТипСкидки AS ТипСкидки,
//	|	CASE
//	|		WHEN NOT HotelProductAccountsReceivable.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductAccountsReceivable.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductAccountsReceivable.СчетПроживания.DateTimeFrom IS NULL 
//	|			THEN HotelProductAccountsReceivable.СчетПроживания.DateTimeFrom
//	|		WHEN NOT HotelProductAccountsReceivable.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN HotelProductAccountsReceivable.ДокОснование.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT HotelProductAccountsReceivable.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductAccountsReceivable.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductAccountsReceivable.СчетПроживания.DateTimeTo IS NULL 
//	|			THEN HotelProductAccountsReceivable.СчетПроживания.DateTimeTo
//	|		WHEN NOT HotelProductAccountsReceivable.ДокОснование.DateTimeTo IS NULL 
//	|			THEN HotelProductAccountsReceivable.ДокОснование.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	HotelProductAccountsReceivable.Сумма AS Сумма,
//	|	HotelProductAccountsReceivable.Сумма - HotelProductAccountsReceivable.СуммаНДС AS SumWithoutVAT
//	|INTO HotelProductAccountsReceivable
//	|FROM
//	|	AccumulationRegister.БухРеализацияУслуг AS HotelProductAccountsReceivable
//	|WHERE
//	|	&qShowHotelProductAccountsReceivable
//	|	AND HotelProductAccountsReceivable.Услуга.IsHotelProductService
//	|	AND HotelProductAccountsReceivable.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (HotelProductAccountsReceivable.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qIsEmptyCustomer)
//	|	AND (HotelProductAccountsReceivable.Договор = &qContract
//	|			OR &qIsEmptyContract)
//	|	AND (HotelProductAccountsReceivable.ГруппаГостей = &qGuestGroup
//	|			OR &qIsEmptyGuestGroup)
//	|	AND (HotelProductAccountsReceivable.ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|			OR &qIsEmptyHotelProduct)
//	|	AND (HotelProductAccountsReceivable.Услуга IN HIERARCHY (&qServicesList)
//	|			OR NOT &qUseServicesList)
//	|	AND HotelProductAccountsReceivable.ГруппаГостей IN
//	|			(SELECT
//	|				HotelProductGroups.ГруппаГостей
//	|			FROM
//	|				HotelProductGroups)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	HotelProductPeriodAccountsReceivable.ВалютаРасчетов AS Валюта,
//	|	HotelProductPeriodAccountsReceivable.Гостиница AS Гостиница,
//	|	HotelProductPeriodAccountsReceivable.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	HotelProductPeriodAccountsReceivable.СчетПроживания.Агент AS Агент,
//	|	HotelProductPeriodAccountsReceivable.Контрагент AS Контрагент,
//	|	HotelProductPeriodAccountsReceivable.Договор AS Договор,
//	|	HotelProductPeriodAccountsReceivable.ГруппаГостей AS ГруппаГостей,
//	|	CASE
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPeriodAccountsReceivable.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPeriodAccountsReceivable.СчетПроживания.Клиент
//	|		ELSE HotelProductPeriodAccountsReceivable.Клиент
//	|	END AS Клиент,
//	|	CASE
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPeriodAccountsReceivable.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPeriodAccountsReceivable.СчетПроживания
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.ДокОснование IS NULL 
//	|			THEN HotelProductPeriodAccountsReceivable.ДокОснование
//	|		ELSE HotelProductPeriodAccountsReceivable.СчетПроживания
//	|	END AS ДокОснование,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|	CASE
//	|		WHEN NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductPeriodAccountsReceivable.СчетПроживания.СпособОплаты
//	|		ELSE &qEmptyPaymentMethod
//	|	END AS СпособОплаты,
//	|	CASE
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPeriodAccountsReceivable.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPeriodAccountsReceivable.СчетПроживания.НомерРазмещения
//	|		WHEN HotelProductPeriodAccountsReceivable.НомерРазмещения <> &qEmptyRoom
//	|			THEN HotelProductPeriodAccountsReceivable.НомерРазмещения
//	|		ELSE HotelProductPeriodAccountsReceivable.ДокОснование.НомерРазмещения
//	|	END AS НомерРазмещения,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.Тариф AS Тариф,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.ТипКлиента AS ТипКлиента,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.TripPurpose AS TripPurpose,
//	|	HotelProductPeriodAccountsReceivable.ДокОснование.ТипСкидки AS ТипСкидки,
//	|	CASE
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductPeriodAccountsReceivable.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.СчетПроживания.DateTimeFrom IS NULL 
//	|			THEN HotelProductPeriodAccountsReceivable.СчетПроживания.DateTimeFrom
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN HotelProductPeriodAccountsReceivable.ДокОснование.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductPeriodAccountsReceivable.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.СчетПроживания.DateTimeTo IS NULL 
//	|			THEN HotelProductPeriodAccountsReceivable.СчетПроживания.DateTimeTo
//	|		WHEN NOT HotelProductPeriodAccountsReceivable.ДокОснование.DateTimeTo IS NULL 
//	|			THEN HotelProductPeriodAccountsReceivable.ДокОснование.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	HotelProductPeriodAccountsReceivable.Сумма AS Сумма,
//	|	HotelProductPeriodAccountsReceivable.Сумма - HotelProductPeriodAccountsReceivable.СуммаНДС AS SumWithoutVAT
//	|INTO HotelProductPeriodAccountsReceivable
//	|FROM
//	|	AccumulationRegister.БухРеализацияУслуг AS HotelProductPeriodAccountsReceivable
//	|WHERE
//	|	&qShowHotelProductAccountsReceivable
//	|	AND HotelProductPeriodAccountsReceivable.Period >= &qPeriodFrom
//	|	AND HotelProductPeriodAccountsReceivable.Period <= &qPeriodTo
//	|	AND HotelProductPeriodAccountsReceivable.Услуга.IsHotelProductService
//	|	AND HotelProductPeriodAccountsReceivable.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (HotelProductPeriodAccountsReceivable.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qIsEmptyCustomer)
//	|	AND (HotelProductPeriodAccountsReceivable.Договор = &qContract
//	|			OR &qIsEmptyContract)
//	|	AND (HotelProductPeriodAccountsReceivable.ГруппаГостей = &qGuestGroup
//	|			OR &qIsEmptyGuestGroup)
//	|	AND (HotelProductPeriodAccountsReceivable.ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|			OR &qIsEmptyHotelProduct)
//	|	AND (HotelProductPeriodAccountsReceivable.Услуга IN HIERARCHY (&qServicesList)
//	|			OR NOT &qUseServicesList)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	HotelProductPayments.ВалютаРасчетов AS Валюта,
//	|	HotelProductPayments.Гостиница AS Гостиница,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания.ПутевкаКурсовка
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|		ELSE HotelProductPayments.ДокОснование.ПутевкаКурсовка
//	|	END AS ПутевкаКурсовка,
//	|	HotelProductPayments.СчетПроживания.Агент AS Агент,
//	|	HotelProductPayments.Контрагент AS Контрагент,
//	|	HotelProductPayments.Договор AS Договор,
//	|	HotelProductPayments.ГруппаГостей AS ГруппаГостей,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания.Клиент
//	|		ELSE HotelProductPayments.Клиент
//	|	END AS Клиент,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование
//	|		WHEN NOT HotelProductPayments.ДокОснование IS NULL 
//	|			THEN HotelProductPayments.ДокОснование
//	|		ELSE HotelProductPayments.СчетПроживания
//	|	END AS ДокОснование,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.КоличествоЧеловек IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.КоличествоЧеловек
//	|		ELSE HotelProductPayments.ДокОснование.КоличествоЧеловек
//	|	END AS КоличествоЧеловек,
//	|	CASE
//	|		WHEN HotelProductPayments.Recorder.СпособОплаты = &qDepositTransfer
//	|				AND NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductPayments.СчетПроживания.СпособОплаты
//	|		WHEN NOT &qSplitPaymentsByColumns
//	|			THEN HotelProductPayments.Recorder.СпособОплаты
//	|		ELSE &qEmptyPaymentMethod
//	|	END AS СпособОплаты,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.НомерРазмещения IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.НомерРазмещения <> &qEmptyRoom
//	|			THEN HotelProductPayments.СчетПроживания.НомерРазмещения
//	|		WHEN HotelProductPayments.НомерРазмещения <> &qEmptyRoom
//	|			THEN HotelProductPayments.НомерРазмещения
//	|		ELSE HotelProductPayments.ДокОснование.НомерРазмещения
//	|	END AS НомерРазмещения,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.Тариф IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.Тариф
//	|		ELSE HotelProductPayments.ДокОснование.Тариф
//	|	END AS Тариф,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ВидРазмещения IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.ВидРазмещения
//	|		ELSE HotelProductPayments.ДокОснование.ВидРазмещения
//	|	END AS ВидРазмещения,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ТипКлиента IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.ТипКлиента
//	|		ELSE HotelProductPayments.ДокОснование.ТипКлиента
//	|	END AS ТипКлиента,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.МаретингНапрвл IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.МаретингНапрвл
//	|		ELSE HotelProductPayments.ДокОснование.МаретингНапрвл
//	|	END AS МаретингНапрвл,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ИсточИнфоГостиница IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.ИсточИнфоГостиница
//	|		ELSE HotelProductPayments.ДокОснование.ИсточИнфоГостиница
//	|	END AS ИсточИнфоГостиница,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.TripPurpose IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.TripPurpose
//	|		ELSE HotelProductPayments.ДокОснование.TripPurpose
//	|	END AS TripPurpose,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ТипСкидки IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.ТипСкидки
//	|		ELSE HotelProductPayments.ДокОснование.ТипСкидки
//	|	END AS ТипСкидки,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductPayments.ДокОснование.CheckInDate IS NULL 
//	|			THEN HotelProductPayments.ДокОснование.CheckInDate
//	|		WHEN NOT HotelProductPayments.СчетПроживания.DateTimeFrom IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.DateTimeFrom
//	|		WHEN NOT HotelProductPayments.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN HotelProductPayments.ДокОснование.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductPayments.ДокОснование.CheckOutDate IS NULL 
//	|			THEN HotelProductPayments.ДокОснование.CheckOutDate
//	|		WHEN NOT HotelProductPayments.СчетПроживания.DateTimeTo IS NULL 
//	|			THEN HotelProductPayments.СчетПроживания.DateTimeTo
//	|		WHEN NOT HotelProductPayments.ДокОснование.DateTimeTo IS NULL 
//	|			THEN HotelProductPayments.ДокОснование.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	HotelProductPayments.Сумма AS PaymentSum,
//	|	HotelProductPayments.Сумма - HotelProductPayments.СуммаНДС AS PaymentSumWithoutVAT,
//	|	CASE
//	|		WHEN HotelProductPayments.Recorder.СпособОплаты.IsByCash
//	|			THEN HotelProductPayments.Сумма
//	|		ELSE 0
//	|	END AS PaymentSumByCash,
//	|	CASE
//	|		WHEN HotelProductPayments.Recorder.СпособОплаты.IsByCreditCard
//	|			THEN HotelProductPayments.Сумма
//	|		ELSE 0
//	|	END AS PaymentSumByCreditCard,
//	|	CASE
//	|		WHEN HotelProductPayments.Recorder.СпособОплаты.IsByBankTransfer
//	|			THEN HotelProductPayments.Сумма
//	|		ELSE 0
//	|	END AS PaymentSumByBankTransfer,
//	|	CASE
//	|		WHEN HotelProductPayments.Recorder.СпособОплаты.IsViaInternetAcquiring
//	|			THEN HotelProductPayments.Сумма
//	|		ELSE 0
//	|	END AS PaymentSumByInternet,
//	|	CASE
//	|		WHEN HotelProductPayments.Recorder.СпособОплаты.IsByBonuses
//	|			THEN HotelProductPayments.Сумма
//	|		ELSE 0
//	|	END AS PaymentSumByBonuses,
//	|	CASE
//	|		WHEN HotelProductPayments.Recorder.СпособОплаты.IsByGiftCertificate
//	|			THEN HotelProductPayments.Сумма
//	|		ELSE 0
//	|	END AS PaymentSumByGiftCertificates
//	|INTO HotelProductPayments
//	|FROM
//	|	AccumulationRegister.ВзаиморасчетыКонтрагенты AS HotelProductPayments
//	|WHERE
//	|	&qShowGuestGroupPayments
//	|	AND HotelProductPayments.RecordType = VALUE(AccumulationrecordType.Expense)
//	|	AND (HotelProductPayments.PaymentSection = &qEmptyPaymentSection
//	|				AND NOT HotelProductPayments.СчетПроживания.Description LIKE &qFolioFilter
//	|			OR HotelProductPayments.PaymentSection <> &qEmptyPaymentSection
//	|				AND ISNULL(HotelProductPayments.PaymentSection.IsForHotelProducts, FALSE))
//	|	AND HotelProductPayments.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (HotelProductPayments.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qIsEmptyCustomer)
//	|	AND (HotelProductPayments.Договор = &qContract
//	|			OR &qIsEmptyContract)
//	|	AND (HotelProductPayments.ГруппаГостей = &qGuestGroup
//	|			OR &qIsEmptyGuestGroup)
//	|	AND HotelProductPayments.ГруппаГостей IN
//	|			(SELECT
//	|				HotelProductGroups.ГруппаГостей
//	|			FROM
//	|				HotelProductGroups AS HotelProductGroups)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	SalesByHotelProducts.Валюта AS Валюта,
//	|	SalesByHotelProducts.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	SUM(SalesByHotelProducts.Продажи) AS Продажи,
//	|	SUM(SalesByHotelProducts.PeriodSales) AS PeriodSales,
//	|	SUM(SalesByHotelProducts.NextPeriodSales) AS NextPeriodSales,
//	|	SUM(SalesByHotelProducts.PrevPeriodSales) AS PrevPeriodSales,
//	|	SUM(SalesByHotelProducts.SalesInSettlements) AS SalesInSettlements,
//	|	SUM(SalesByHotelProducts.PeriodSalesInSettlements) AS PeriodSalesInSettlements,
//	|	SUM(SalesByHotelProducts.PaymentAmount) AS PaymentAmount
//	|INTO SalesByHotelProducts
//	|FROM
//	|	(SELECT
//	|		HotelProductTotalSales.Валюта AS Валюта,
//	|		HotelProductTotalSales.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|		HotelProductTotalSales.Продажи AS Продажи,
//	|		0 AS PeriodSales,
//	|		0 AS NextPeriodSales,
//	|		0 AS PrevPeriodSales,
//	|		0 AS SalesInSettlements,
//	|		0 AS PeriodSalesInSettlements,
//	|		0 AS PaymentAmount
//	|	FROM
//	|		HotelProductTotalSales AS HotelProductTotalSales
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		HotelProductCurPeriodSales.Валюта,
//	|		HotelProductCurPeriodSales.Гостиница,
//	|		0,
//	|		HotelProductCurPeriodSales.Продажи,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		HotelProductCurPeriodSales AS HotelProductCurPeriodSales
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		HotelProductNextPeriodSales.Валюта,
//	|		HotelProductNextPeriodSales.Гостиница,
//	|		0,
//	|		0,
//	|		HotelProductNextPeriodSales.Продажи,
//	|		0,
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		HotelProductNextPeriodSales AS HotelProductNextPeriodSales
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		HotelProductPrevPeriodSales.Валюта,
//	|		HotelProductPrevPeriodSales.Гостиница,
//	|		0,
//	|		0,
//	|		0,
//	|		HotelProductPrevPeriodSales.Продажи,
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		HotelProductPrevPeriodSales AS HotelProductPrevPeriodSales
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		HotelProductAccountsReceivable.Валюта,
//	|		HotelProductAccountsReceivable.ПутевкаКурсовка,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		HotelProductAccountsReceivable.Сумма,
//	|		0,
//	|		0
//	|	FROM
//	|		HotelProductAccountsReceivable AS HotelProductAccountsReceivable
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		HotelProductPeriodAccountsReceivable.Валюта,
//	|		HotelProductPeriodAccountsReceivable.ПутевкаКурсовка,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		HotelProductPeriodAccountsReceivable.Сумма,
//	|		0
//	|	FROM
//	|		HotelProductPeriodAccountsReceivable AS HotelProductPeriodAccountsReceivable
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		HotelProductPayments.Валюта,
//	|		HotelProductPayments.ПутевкаКурсовка,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		HotelProductPayments.PaymentSum
//	|	FROM
//	|		HotelProductPayments AS HotelProductPayments) AS SalesByHotelProducts
//	|
//	|GROUP BY
//	|	SalesByHotelProducts.Валюта,
//	|	SalesByHotelProducts.ПутевкаКурсовка
//	|
//	|HAVING
//	|	SUM(SalesByHotelProducts.Продажи) = SUM(SalesByHotelProducts.PeriodSalesInSettlements) AND
//	|	SUM(SalesByHotelProducts.PeriodSalesInSettlements) = SUM(SalesByHotelProducts.PaymentAmount)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
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
//	|	ПродажиПутевокКурсовок.PeriodSales AS PeriodSales,
//	|	ПродажиПутевокКурсовок.PeriodSalesWithoutVAT AS PeriodSalesWithoutVAT,
//	|	ПродажиПутевокКурсовок.PeriodGuestDays AS PeriodGuestDays,
//	|	ПродажиПутевокКурсовок.PrevPeriodSales AS PrevPeriodSales,
//	|	ПродажиПутевокКурсовок.PrevPeriodSalesWithoutVAT AS PrevPeriodSalesWithoutVAT,
//	|	ПродажиПутевокКурсовок.PrevPeriodGuestDays AS PrevPeriodGuestDays,
//	|	ПродажиПутевокКурсовок.NextPeriodSales AS NextPeriodSales,
//	|	ПродажиПутевокКурсовок.NextPeriodSalesWithoutVAT AS NextPeriodSalesWithoutVAT,
//	|	ПродажиПутевокКурсовок.NextPeriodGuestDays AS NextPeriodGuestDays,
//	|	ПродажиПутевокКурсовок.SalesInSettlements AS SalesInSettlements,
//	|	ПродажиПутевокКурсовок.SalesWithoutVATInSettlements AS SalesWithoutVATInSettlements,
//	|	ПродажиПутевокКурсовок.PeriodSalesInSettlements AS PeriodSalesInSettlements,
//	|	ПродажиПутевокКурсовок.PeriodSalesWithoutVATInSettlements AS PeriodSalesWithoutVATInSettlements,
//	|	ПродажиПутевокКурсовок.PaymentAmount AS PaymentAmount,
//	|	ПродажиПутевокКурсовок.PaymentAmountWithoutVAT AS PaymentAmountWithoutVAT,
//	|	ПродажиПутевокКурсовок.CashSum AS CashSum,
//	|	ПродажиПутевокКурсовок.CreditCardSum AS CreditCardSum,
//	|	ПродажиПутевокКурсовок.BankTransferSum AS BankTransferSum,
//	|	ПродажиПутевокКурсовок.InternetSum AS InternetSum,
//	|	ПродажиПутевокКурсовок.BonusesSum AS BonusesSum,
//	|	ПродажиПутевокКурсовок.GiftCertificatesSum AS GiftCertificatesSum
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
//	|	ПродажиПутевокКурсовок.ДокОснование.* AS ДокОснование,
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
//	|	Count,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qTogether
//	|				THEN 0
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qAdditionalBed
//	|				THEN 0
//	|			ELSE ПродажиПутевокКурсовок.Count
//	|		END) AS FamilyCount,
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
//	|	PrevPeriodSales,
//	|	PrevPeriodSalesWithoutVAT,
//	|	PrevPeriodGuestDays,
//	|	PeriodSales,
//	|	PeriodSalesWithoutVAT,
//	|	PeriodGuestDays,
//	|	NextPeriodSales,
//	|	NextPeriodSalesWithoutVAT,
//	|	NextPeriodGuestDays,
//	|	SalesInSettlements,
//	|	SalesWithoutVATInSettlements,
//	|	PeriodSalesInSettlements,
//	|	PeriodSalesWithoutVATInSettlements,
//	|	PaymentAmount,
//	|	PaymentAmountWithoutVAT,
//	|	CashSum,
//	|	CreditCardSum,
//	|	BankTransferSum,
//	|	InternetSum,
//	|	BonusesSum,
//	|	GiftCertificatesSum}
//	|FROM
//	|	(SELECT
//	|		HotelProductTotalSales.Валюта AS Валюта,
//	|		HotelProductTotalSales.Гостиница AS Гостиница,
//	|		HotelProductTotalSales.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|		HotelProductTotalSales.Агент AS Агент,
//	|		HotelProductTotalSales.Контрагент AS Контрагент,
//	|		HotelProductTotalSales.Договор AS Договор,
//	|		HotelProductTotalSales.ГруппаГостей AS ГруппаГостей,
//	|		HotelProductTotalSales.Клиент AS Клиент,
//	|		HotelProductTotalSales.ДокОснование AS ДокОснование,
//	|		HotelProductTotalSales.КоличествоЧеловек AS КоличествоЧеловек,
//	|		HotelProductTotalSales.СпособОплаты AS PlannedPaymentMethod,
//	|		HotelProductTotalSales.НомерРазмещения AS НомерРазмещения,
//	|		HotelProductTotalSales.Тариф AS Тариф,
//	|		HotelProductTotalSales.ВидРазмещения AS ВидРазмещения,
//	|		HotelProductTotalSales.ТипКлиента AS ТипКлиента,
//	|		HotelProductTotalSales.МаретингНапрвл AS МаретингНапрвл,
//	|		HotelProductTotalSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		HotelProductTotalSales.TripPurpose AS TripPurpose,
//	|		HotelProductTotalSales.ТипСкидки AS ТипСкидки,
//	|		MIN(HotelProductTotalSales.CheckInDate) AS CheckInDate,
//	|		MAX(HotelProductTotalSales.CheckOutDate) AS CheckOutDate,
//	|		SUM(HotelProductTotalSales.Продажи) AS Продажи,
//	|		SUM(HotelProductTotalSales.ДоходНомеров) AS ДоходНомеров,
//	|		SUM(HotelProductTotalSales.ПродажиБезНДС) AS ПродажиБезНДС,
//	|		SUM(HotelProductTotalSales.ДоходПродажиБезНДС) AS ДоходПродажиБезНДС,
//	|		SUM(HotelProductTotalSales.СуммаКомиссии) AS СуммаКомиссии,
//	|		SUM(HotelProductTotalSales.КомиссияБезНДС) AS КомиссияБезНДС,
//	|		SUM(HotelProductTotalSales.СуммаСкидки) AS СуммаСкидки,
//	|		SUM(HotelProductTotalSales.СуммаСкидкиБезНДС) AS СуммаСкидкиБезНДС,
//	|		SUM(HotelProductTotalSales.ПроданоНомеров) AS ПроданоНомеров,
//	|		SUM(HotelProductTotalSales.ПроданоМест) AS ПроданоМест,
//	|		SUM(HotelProductTotalSales.ПроданоДопМест) AS ПроданоДопМест,
//	|		SUM(HotelProductTotalSales.ЧеловекаДни) AS ЧеловекаДни,
//	|		SUM(HotelProductTotalSales.ЗаездГостей) AS ЗаездГостей,
//	|		SUM(HotelProductTotalSales.PeriodSales) AS PeriodSales,
//	|		SUM(HotelProductTotalSales.PeriodSalesWithoutVAT) AS PeriodSalesWithoutVAT,
//	|		SUM(HotelProductTotalSales.PeriodGuestDays) AS PeriodGuestDays,
//	|		SUM(HotelProductTotalSales.PrevPeriodSales) AS PrevPeriodSales,
//	|		SUM(HotelProductTotalSales.PrevPeriodSalesWithoutVAT) AS PrevPeriodSalesWithoutVAT,
//	|		SUM(HotelProductTotalSales.PrevPeriodGuestDays) AS PrevPeriodGuestDays,
//	|		SUM(HotelProductTotalSales.NextPeriodSales) AS NextPeriodSales,
//	|		SUM(HotelProductTotalSales.NextPeriodSalesWithoutVAT) AS NextPeriodSalesWithoutVAT,
//	|		SUM(HotelProductTotalSales.NextPeriodGuestDays) AS NextPeriodGuestDays,
//	|		SUM(HotelProductTotalSales.SalesInSettlements) AS SalesInSettlements,
//	|		SUM(HotelProductTotalSales.SalesWithoutVATInSettlements) AS SalesWithoutVATInSettlements,
//	|		SUM(HotelProductTotalSales.PeriodSalesInSettlements) AS PeriodSalesInSettlements,
//	|		SUM(HotelProductTotalSales.PeriodSalesWithoutVATInSettlements) AS PeriodSalesWithoutVATInSettlements,
//	|		SUM(HotelProductTotalSales.PaymentAmount) AS PaymentAmount,
//	|		SUM(HotelProductTotalSales.PaymentAmountWithoutVAT) AS PaymentAmountWithoutVAT,
//	|		SUM(HotelProductTotalSales.CashSum) AS CashSum,
//	|		SUM(HotelProductTotalSales.CreditCardSum) AS CreditCardSum,
//	|		SUM(HotelProductTotalSales.BankTransferSum) AS BankTransferSum,
//	|		SUM(HotelProductTotalSales.InternetSum) AS InternetSum,
//	|		SUM(HotelProductTotalSales.BonusesSum) AS BonusesSum,
//	|		SUM(HotelProductTotalSales.GiftCertificatesSum) AS GiftCertificatesSum,
//	|		COUNT(DISTINCT HotelProductTotalSales.ПутевкаКурсовка) AS Count
//	|	FROM
//	|		(SELECT
//	|			HotelProductTotalSales.Валюта AS Валюта,
//	|			HotelProductTotalSales.Гостиница AS Гостиница,
//	|			HotelProductTotalSales.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			HotelProductTotalSales.Агент AS Агент,
//	|			HotelProductTotalSales.Контрагент AS Контрагент,
//	|			HotelProductTotalSales.Договор AS Договор,
//	|			HotelProductTotalSales.ГруппаГостей AS ГруппаГостей,
//	|			HotelProductTotalSales.Клиент AS Клиент,
//	|			HotelProductTotalSales.ДокОснование AS ДокОснование,
//	|			HotelProductTotalSales.КоличествоЧеловек AS КоличествоЧеловек,
//	|			HotelProductTotalSales.СпособОплаты AS СпособОплаты,
//	|			HotelProductTotalSales.НомерРазмещения AS НомерРазмещения,
//	|			HotelProductTotalSales.Тариф AS Тариф,
//	|			HotelProductTotalSales.ВидРазмещения AS ВидРазмещения,
//	|			HotelProductTotalSales.ТипКлиента AS ТипКлиента,
//	|			HotelProductTotalSales.МаретингНапрвл AS МаретингНапрвл,
//	|			HotelProductTotalSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			HotelProductTotalSales.TripPurpose AS TripPurpose,
//	|			HotelProductTotalSales.ТипСкидки AS ТипСкидки,
//	|			HotelProductTotalSales.CheckInDate AS CheckInDate,
//	|			HotelProductTotalSales.CheckOutDate AS CheckOutDate,
//	|			HotelProductTotalSales.Продажи AS Продажи,
//	|			HotelProductTotalSales.ДоходНомеров AS ДоходНомеров,
//	|			HotelProductTotalSales.ПродажиБезНДС AS ПродажиБезНДС,
//	|			HotelProductTotalSales.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|			HotelProductTotalSales.СуммаКомиссии AS СуммаКомиссии,
//	|			HotelProductTotalSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|			HotelProductTotalSales.СуммаСкидки AS СуммаСкидки,
//	|			HotelProductTotalSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|			HotelProductTotalSales.ПроданоНомеров AS ПроданоНомеров,
//	|			HotelProductTotalSales.ПроданоМест AS ПроданоМест,
//	|			HotelProductTotalSales.ПроданоДопМест AS ПроданоДопМест,
//	|			HotelProductTotalSales.ЧеловекаДни AS ЧеловекаДни,
//	|			HotelProductTotalSales.ЗаездГостей AS ЗаездГостей,
//	|			0 AS PeriodSales,
//	|			0 AS PeriodSalesWithoutVAT,
//	|			0 AS PeriodGuestDays,
//	|			0 AS PrevPeriodSales,
//	|			0 AS PrevPeriodSalesWithoutVAT,
//	|			0 AS PrevPeriodGuestDays,
//	|			0 AS NextPeriodSales,
//	|			0 AS NextPeriodSalesWithoutVAT,
//	|			0 AS NextPeriodGuestDays,
//	|			0 AS SalesInSettlements,
//	|			0 AS SalesWithoutVATInSettlements,
//	|			0 AS PeriodSalesInSettlements,
//	|			0 AS PeriodSalesWithoutVATInSettlements,
//	|			0 AS PaymentAmount,
//	|			0 AS PaymentAmountWithoutVAT,
//	|			0 AS CashSum,
//	|			0 AS CreditCardSum,
//	|			0 AS BankTransferSum,
//	|			0 AS InternetSum,
//	|			0 AS BonusesSum,
//	|			0 AS GiftCertificatesSum
//	|		FROM
//	|			HotelProductTotalSales AS HotelProductTotalSales
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			HotelProductCurPeriodSales.Валюта,
//	|			HotelProductCurPeriodSales.Гостиница,
//	|			HotelProductCurPeriodSales.ПутевкаКурсовка,
//	|			HotelProductCurPeriodSales.Агент,
//	|			HotelProductCurPeriodSales.Контрагент,
//	|			HotelProductCurPeriodSales.Договор,
//	|			HotelProductCurPeriodSales.ГруппаГостей,
//	|			HotelProductCurPeriodSales.Клиент,
//	|			HotelProductCurPeriodSales.ДокОснование,
//	|			HotelProductCurPeriodSales.КоличествоЧеловек,
//	|			HotelProductCurPeriodSales.СпособОплаты,
//	|			HotelProductCurPeriodSales.НомерРазмещения,
//	|			HotelProductCurPeriodSales.Тариф,
//	|			HotelProductCurPeriodSales.ВидРазмещения,
//	|			HotelProductCurPeriodSales.ТипКлиента,
//	|			HotelProductCurPeriodSales.МаретингНапрвл,
//	|			HotelProductCurPeriodSales.ИсточИнфоГостиница,
//	|			HotelProductCurPeriodSales.TripPurpose,
//	|			HotelProductCurPeriodSales.ТипСкидки,
//	|			HotelProductCurPeriodSales.CheckInDate,
//	|			HotelProductCurPeriodSales.CheckOutDate,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			HotelProductCurPeriodSales.Продажи,
//	|			HotelProductCurPeriodSales.ПродажиБезНДС,
//	|			HotelProductCurPeriodSales.ЧеловекаДни,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			HotelProductCurPeriodSales AS HotelProductCurPeriodSales
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			HotelProductPrevPeriodSales.Валюта,
//	|			HotelProductPrevPeriodSales.Гостиница,
//	|			HotelProductPrevPeriodSales.ПутевкаКурсовка,
//	|			HotelProductPrevPeriodSales.Агент,
//	|			HotelProductPrevPeriodSales.Контрагент,
//	|			HotelProductPrevPeriodSales.Договор,
//	|			HotelProductPrevPeriodSales.ГруппаГостей,
//	|			HotelProductPrevPeriodSales.Клиент,
//	|			HotelProductPrevPeriodSales.ДокОснование,
//	|			HotelProductPrevPeriodSales.КоличествоЧеловек,
//	|			HotelProductPrevPeriodSales.СпособОплаты,
//	|			HotelProductPrevPeriodSales.НомерРазмещения,
//	|			HotelProductPrevPeriodSales.Тариф,
//	|			HotelProductPrevPeriodSales.ВидРазмещения,
//	|			HotelProductPrevPeriodSales.ТипКлиента,
//	|			HotelProductPrevPeriodSales.МаретингНапрвл,
//	|			HotelProductPrevPeriodSales.ИсточИнфоГостиница,
//	|			HotelProductPrevPeriodSales.TripPurpose,
//	|			HotelProductPrevPeriodSales.ТипСкидки,
//	|			HotelProductPrevPeriodSales.CheckInDate,
//	|			HotelProductPrevPeriodSales.CheckOutDate,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			HotelProductPrevPeriodSales.Продажи,
//	|			HotelProductPrevPeriodSales.ПродажиБезНДС,
//	|			HotelProductPrevPeriodSales.ЧеловекаДни,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			HotelProductPrevPeriodSales AS HotelProductPrevPeriodSales
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			HotelProductNextPeriodSales.Валюта,
//	|			HotelProductNextPeriodSales.Гостиница,
//	|			HotelProductNextPeriodSales.ПутевкаКурсовка,
//	|			HotelProductNextPeriodSales.Агент,
//	|			HotelProductNextPeriodSales.Контрагент,
//	|			HotelProductNextPeriodSales.Договор,
//	|			HotelProductNextPeriodSales.ГруппаГостей,
//	|			HotelProductNextPeriodSales.Клиент,
//	|			HotelProductNextPeriodSales.ДокОснование,
//	|			HotelProductNextPeriodSales.КоличествоЧеловек,
//	|			HotelProductNextPeriodSales.СпособОплаты,
//	|			HotelProductNextPeriodSales.НомерРазмещения,
//	|			HotelProductNextPeriodSales.Тариф,
//	|			HotelProductNextPeriodSales.ВидРазмещения,
//	|			HotelProductNextPeriodSales.ТипКлиента,
//	|			HotelProductNextPeriodSales.МаретингНапрвл,
//	|			HotelProductNextPeriodSales.ИсточИнфоГостиница,
//	|			HotelProductNextPeriodSales.TripPurpose,
//	|			HotelProductNextPeriodSales.ТипСкидки,
//	|			HotelProductNextPeriodSales.CheckInDate,
//	|			HotelProductNextPeriodSales.CheckOutDate,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			HotelProductNextPeriodSales.Продажи,
//	|			HotelProductNextPeriodSales.ПродажиБезНДС,
//	|			HotelProductNextPeriodSales.ЧеловекаДни,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			HotelProductNextPeriodSales AS HotelProductNextPeriodSales
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			HotelProductAccountsReceivable.Валюта,
//	|			HotelProductAccountsReceivable.Гостиница,
//	|			HotelProductAccountsReceivable.ПутевкаКурсовка,
//	|			HotelProductAccountsReceivable.Агент,
//	|			HotelProductAccountsReceivable.Контрагент,
//	|			HotelProductAccountsReceivable.Договор,
//	|			HotelProductAccountsReceivable.ГруппаГостей,
//	|			HotelProductAccountsReceivable.Клиент,
//	|			HotelProductAccountsReceivable.ДокОснование,
//	|			HotelProductAccountsReceivable.КоличествоЧеловек,
//	|			HotelProductAccountsReceivable.СпособОплаты,
//	|			HotelProductAccountsReceivable.НомерРазмещения,
//	|			HotelProductAccountsReceivable.Тариф,
//	|			HotelProductAccountsReceivable.ВидРазмещения,
//	|			HotelProductAccountsReceivable.ТипКлиента,
//	|			HotelProductAccountsReceivable.МаретингНапрвл,
//	|			HotelProductAccountsReceivable.ИсточИнфоГостиница,
//	|			HotelProductAccountsReceivable.TripPurpose,
//	|			HotelProductAccountsReceivable.ТипСкидки,
//	|			HotelProductAccountsReceivable.CheckInDate,
//	|			HotelProductAccountsReceivable.CheckOutDate,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			HotelProductAccountsReceivable.Сумма,
//	|			HotelProductAccountsReceivable.SumWithoutVAT,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			HotelProductAccountsReceivable AS HotelProductAccountsReceivable
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			HotelProductPeriodAccountsReceivable.Валюта,
//	|			HotelProductPeriodAccountsReceivable.Гостиница,
//	|			HotelProductPeriodAccountsReceivable.ПутевкаКурсовка,
//	|			HotelProductPeriodAccountsReceivable.Агент,
//	|			HotelProductPeriodAccountsReceivable.Контрагент,
//	|			HotelProductPeriodAccountsReceivable.Договор,
//	|			HotelProductPeriodAccountsReceivable.ГруппаГостей,
//	|			HotelProductPeriodAccountsReceivable.Клиент,
//	|			HotelProductPeriodAccountsReceivable.ДокОснование,
//	|			HotelProductPeriodAccountsReceivable.КоличествоЧеловек,
//	|			HotelProductPeriodAccountsReceivable.СпособОплаты,
//	|			HotelProductPeriodAccountsReceivable.НомерРазмещения,
//	|			HotelProductPeriodAccountsReceivable.Тариф,
//	|			HotelProductPeriodAccountsReceivable.ВидРазмещения,
//	|			HotelProductPeriodAccountsReceivable.ТипКлиента,
//	|			HotelProductPeriodAccountsReceivable.МаретингНапрвл,
//	|			HotelProductPeriodAccountsReceivable.ИсточИнфоГостиница,
//	|			HotelProductPeriodAccountsReceivable.TripPurpose,
//	|			HotelProductPeriodAccountsReceivable.ТипСкидки,
//	|			HotelProductPeriodAccountsReceivable.CheckInDate,
//	|			HotelProductPeriodAccountsReceivable.CheckOutDate,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			HotelProductPeriodAccountsReceivable.Сумма,
//	|			HotelProductPeriodAccountsReceivable.SumWithoutVAT,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			HotelProductPeriodAccountsReceivable AS HotelProductPeriodAccountsReceivable
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			HotelProductPayments.Валюта,
//	|			HotelProductPayments.Гостиница,
//	|			HotelProductPayments.ПутевкаКурсовка,
//	|			HotelProductPayments.Агент,
//	|			HotelProductPayments.Контрагент,
//	|			HotelProductPayments.Договор,
//	|			HotelProductPayments.ГруппаГостей,
//	|			HotelProductPayments.Клиент,
//	|			HotelProductPayments.ДокОснование,
//	|			HotelProductPayments.КоличествоЧеловек,
//	|			HotelProductPayments.СпособОплаты,
//	|			HotelProductPayments.НомерРазмещения,
//	|			HotelProductPayments.Тариф,
//	|			HotelProductPayments.ВидРазмещения,
//	|			HotelProductPayments.ТипКлиента,
//	|			HotelProductPayments.МаретингНапрвл,
//	|			HotelProductPayments.ИсточИнфоГостиница,
//	|			HotelProductPayments.TripPurpose,
//	|			HotelProductPayments.ТипСкидки,
//	|			HotelProductPayments.CheckInDate,
//	|			HotelProductPayments.CheckOutDate,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			HotelProductPayments.PaymentSum,
//	|			HotelProductPayments.PaymentSumWithoutVAT,
//	|			HotelProductPayments.PaymentSumByCash,
//	|			HotelProductPayments.PaymentSumByCreditCard,
//	|			HotelProductPayments.PaymentSumByBankTransfer,
//	|			HotelProductPayments.PaymentSumByInternet,
//	|			HotelProductPayments.PaymentSumByBonuses,
//	|			HotelProductPayments.PaymentSumByGiftCertificates
//	|		FROM
//	|			HotelProductPayments AS HotelProductPayments) AS HotelProductTotalSales
//	|	
//	|	GROUP BY
//	|		HotelProductTotalSales.Валюта,
//	|		HotelProductTotalSales.Гостиница,
//	|		HotelProductTotalSales.ПутевкаКурсовка,
//	|		HotelProductTotalSales.Агент,
//	|		HotelProductTotalSales.Контрагент,
//	|		HotelProductTotalSales.Договор,
//	|		HotelProductTotalSales.ГруппаГостей,
//	|		HotelProductTotalSales.Клиент,
//	|		HotelProductTotalSales.ДокОснование,
//	|		HotelProductTotalSales.КоличествоЧеловек,
//	|		HotelProductTotalSales.СпособОплаты,
//	|		HotelProductTotalSales.НомерРазмещения,
//	|		HotelProductTotalSales.Тариф,
//	|		HotelProductTotalSales.ВидРазмещения,
//	|		HotelProductTotalSales.ТипКлиента,
//	|		HotelProductTotalSales.МаретингНапрвл,
//	|		HotelProductTotalSales.ИсточИнфоГостиница,
//	|		HotelProductTotalSales.TripPurpose,
//	|		HotelProductTotalSales.ТипСкидки) AS ПродажиПутевокКурсовок
//	|WHERE
//	|	(NOT &qShowDifferencesOnly
//	|			OR &qShowDifferencesOnly
//	|				AND NOT ПродажиПутевокКурсовок.ПутевкаКурсовка IN
//	|						(SELECT
//	|							SalesByHotelProducts.ПутевкаКурсовка
//	|						FROM
//	|							SalesByHotelProducts AS SalesByHotelProducts))
//	|{WHERE
//	|	ПродажиПутевокКурсовок.Валюта.*,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.КвотаНомеров.* AS КвотаНомеров,
//	|	ПродажиПутевокКурсовок.Гостиница.* AS Гостиница,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.ТипНомера.* AS ТипНомера,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ПродажиПутевокКурсовок.ПутевкаКурсовка.Parent.* AS HotelProductParent,
//	|	ПродажиПутевокКурсовок.Агент.* AS Агент,
//	|	ПродажиПутевокКурсовок.Контрагент.* AS Контрагент,
//	|	ПродажиПутевокКурсовок.Договор.* AS Договор,
//	|	ПродажиПутевокКурсовок.ГруппаГостей.* AS ГруппаГостей,
//	|	ПродажиПутевокКурсовок.Клиент.* AS Клиент,
//	|	ПродажиПутевокКурсовок.ДокОснование.* AS ДокОснование,
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
//	|	ПродажиПутевокКурсовок.Count,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qTogether
//	|				THEN 0
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qAdditionalBed
//	|				THEN 0
//	|			ELSE ПродажиПутевокКурсовок.Count
//	|		END) AS FamilyCount,
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
//	|	ПродажиПутевокКурсовок.PeriodSales,
//	|	ПродажиПутевокКурсовок.PeriodSalesWithoutVAT,
//	|	ПродажиПутевокКурсовок.PeriodGuestDays,
//	|	ПродажиПутевокКурсовок.PrevPeriodSales,
//	|	ПродажиПутевокКурсовок.PrevPeriodSalesWithoutVAT,
//	|	ПродажиПутевокКурсовок.PrevPeriodGuestDays,
//	|	ПродажиПутевокКурсовок.NextPeriodSales,
//	|	ПродажиПутевокКурсовок.NextPeriodSalesWithoutVAT,
//	|	ПродажиПутевокКурсовок.NextPeriodGuestDays,
//	|	ПродажиПутевокКурсовок.SalesInSettlements,
//	|	ПродажиПутевокКурсовок.SalesWithoutVATInSettlements,
//	|	ПродажиПутевокКурсовок.PeriodSalesInSettlements,
//	|	ПродажиПутевокКурсовок.PeriodSalesWithoutVATInSettlements,
//	|	ПродажиПутевокКурсовок.PaymentAmount,
//	|	ПродажиПутевокКурсовок.PaymentAmountWithoutVAT,
//	|	ПродажиПутевокКурсовок.CashSum,
//	|	ПродажиПутевокКурсовок.CreditCardSum,
//	|	ПродажиПутевокКурсовок.BankTransferSum,
//	|	ПродажиПутевокКурсовок.InternetSum,
//	|	ПродажиПутевокКурсовок.BonusesSum,
//	|	ПродажиПутевокКурсовок.GiftCertificatesSum}
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
//	|	ПродажиПутевокКурсовок.ДокОснование.* AS ДокОснование,
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
//	|	Count,
//	|	(CASE
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qTogether
//	|				THEN 0
//	|			WHEN ПродажиПутевокКурсовок.ВидРазмещения.ТипРазмещения = &qAdditionalBed
//	|				THEN 0
//	|			ELSE ПродажиПутевокКурсовок.Count
//	|		END) AS FamilyCount,
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
//	|	PeriodSales,
//	|	PeriodSalesWithoutVAT,
//	|	PeriodGuestDays,
//	|	NextPeriodSales,
//	|	NextPeriodSalesWithoutVAT,
//	|	NextPeriodGuestDays,
//	|	PrevPeriodSales,
//	|	PrevPeriodSalesWithoutVAT,
//	|	PrevPeriodGuestDays,
//	|	SalesInSettlements,
//	|	SalesWithoutVATInSettlements,
//	|	PeriodSalesInSettlements,
//	|	PeriodSalesWithoutVATInSettlements,
//	|	PaymentAmount,
//	|	PaymentAmountWithoutVAT,
//	|	CashSum,
//	|	CreditCardSum,
//	|	BankTransferSum,
//	|	InternetSum,
//	|	BonusesSum,
//	|	GiftCertificatesSum}
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
//	|	SUM(PeriodSales),
//	|	SUM(PeriodSalesWithoutVAT),
//	|	SUM(PeriodGuestDays),
//	|	SUM(PrevPeriodSales),
//	|	SUM(PrevPeriodSalesWithoutVAT),
//	|	SUM(PrevPeriodGuestDays),
//	|	SUM(NextPeriodSales),
//	|	SUM(NextPeriodSalesWithoutVAT),
//	|	SUM(NextPeriodGuestDays),
//	|	SUM(SalesInSettlements),
//	|	SUM(SalesWithoutVATInSettlements),
//	|	SUM(PeriodSalesInSettlements),
//	|	SUM(PeriodSalesWithoutVATInSettlements),
//	|	SUM(PaymentAmount),
//	|	SUM(PaymentAmountWithoutVAT),
//	|	SUM(CashSum),
//	|	SUM(CreditCardSum),
//	|	SUM(BankTransferSum),
//	|	SUM(InternetSum),
//	|	SUM(BonusesSum),
//	|	SUM(GiftCertificatesSum)
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
//	|	ПродажиПутевокКурсовок.ДокОснование.* AS ДокОснование,
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
//	ReportBuilder.HeaderText = NStr("EN='Vaucher sales'; RU='Продажи путевок'; DE='Verkauf von Reiseschecks'");
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
//	   Or pName = "Count" 
//	   Or pName = "FamilyCount" 
//	   Or pName = "ЧеловекаДни" 
//	   Or pName = "ЗаездГостей" 
//	   Or pName = "PrevPeriodSales"
//	   Or pName = "PrevPeriodSalesWithoutVAT"
//	   Or pName = "PrevPeriodGuestDays" 
//	   Or pName = "NextPeriodSales"
//	   Or pName = "NextPeriodSalesWithoutVAT"
//	   Or pName = "NextPeriodGuestDays" 
//	   Or pName = "PeriodSales"
//	   Or pName = "PeriodSalesWithoutVAT"
//	   Or pName = "PeriodGuestDays" 
//	   Or pName = "SalesInSettlements"
//	   Or pName = "SalesWithoutVATInSettlements"
//	   Or pName = "PeriodSalesInSettlements"
//	   Or pName = "PeriodSalesWithoutVATInSettlements"
//	   Or pName = "PaymentAmount"
//	   Or pName = "PaymentAmountWithoutVAT" 
//	   Or pName = "CashSum" 
//	   Or pName = "CreditCardSum" 
//	   Or pName = "BankTransferSum" 
//	   Or pName = "InternetSum" 
//	   Or pName = "BonusesSum" 
//	   Or pName = "GiftCertificatesSum" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
