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
//	If ЗначениеЗаполнено(PaymentMethod) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Payment method ';ru='Способ оплаты ';de='Zahlungsmethode '") + 
//							 TrimAll(PaymentMethod.Description) + 
//							 ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", AddMonth(PeriodFrom, -12));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", AddMonth(PeriodTo, 1));
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
//	ReportBuilder.Parameters.Вставить("qPaymentMethod", PaymentMethod);
//	ReportBuilder.Parameters.Вставить("qIsEmptyPaymentMethod", НЕ ЗначениеЗаполнено(PaymentMethod));
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
//	ReportBuilder.Parameters.Вставить("qEmptyPaymentSection", Справочники.ОтделОплаты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qDepositTransfer", Справочники.СпособОплаты.ПеремещениеДепозита);
//	ReportBuilder.Parameters.Вставить("qSplitPaymentsByColumns", SplitPaymentsByColumns);
//	ReportBuilder.Parameters.Вставить("qPaymentPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPaymentPeriodTo", PeriodTo);
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
//	|	HotelProductPayments.ВалютаРасчетов,
//	|	HotelProductPayments.ГруппаГостей,
//	|	HotelProductPayments.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|	HotelProductPayments.ДокОснование AS ДокОснование,
//	|	HotelProductPayments.PaymentSection,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания.ПутевкаКурсовка
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|		WHEN NOT HotelProductPayments.ДокОснование.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.ДокОснование.ПутевкаКурсовка
//	|		ELSE &qEmptyHotelProduct
//	|	END AS ПутевкаКурсовка,
//	|	SUM(HotelProductPayments.Сумма) AS Сумма
//	|INTO HotelProductPayments
//	|FROM
//	|	AccumulationRegister.ВзаиморасчетыКонтрагенты AS HotelProductPayments
//	|WHERE
//	|	HotelProductPayments.RecordType = VALUE(AccumulationrecordType.Expense)
//	|	AND HotelProductPayments.Period >= &qPaymentPeriodFrom
//	|	AND HotelProductPayments.Period <= &qPaymentPeriodTo
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
//	|	AND (HotelProductPayments.Recorder.СпособОплаты = &qPaymentMethod
//	|			OR &qIsEmptyPaymentMethod)
//	|	AND CASE
//	|			WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|					AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|				THEN HotelProductPayments.СчетПроживания.ПутевкаКурсовка
//	|			WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|					AND HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|				THEN HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|			WHEN NOT HotelProductPayments.ДокОснование.ПутевкаКурсовка IS NULL 
//	|					AND HotelProductPayments.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|				THEN HotelProductPayments.ДокОснование.ПутевкаКурсовка
//	|			ELSE &qEmptyHotelProduct
//	|		END <> &qEmptyHotelProduct
//	|
//	|GROUP BY
//	|	HotelProductPayments.ВалютаРасчетов,
//	|	HotelProductPayments.ГруппаГостей,
//	|	HotelProductPayments.СчетПроживания.НомерРазмещения,
//	|	HotelProductPayments.ДокОснование,
//	|	HotelProductPayments.PaymentSection,
//	|	CASE
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания.ПутевкаКурсовка
//	|		WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|		WHEN NOT HotelProductPayments.ДокОснование.ПутевкаКурсовка IS NULL 
//	|				AND HotelProductPayments.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|			THEN HotelProductPayments.ДокОснование.ПутевкаКурсовка
//	|		ELSE &qEmptyHotelProduct
//	|	END
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
//	|	ПродажиПутевокКурсовок.PaymentAmount AS PaymentAmount,
//	|	ПродажиПутевокКурсовок.PaymentAmountWithoutVAT AS PaymentAmountWithoutVAT,
//	|	ПродажиПутевокКурсовок.CashSum AS CashSum,
//	|	ПродажиПутевокКурсовок.CreditCardSum AS CreditCardSum,
//	|	ПродажиПутевокКурсовок.BankTransferSum AS BankTransferSum
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
//	|	ПродажиПутевокКурсовок.PaymentSection.* AS PaymentSection,
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
//	|	PaymentAmount,
//	|	PaymentAmountWithoutVAT,
//	|	CashSum,
//	|	CreditCardSum,
//	|	BankTransferSum}
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
//	|		HotelProductTotalSales.PaymentSection AS PaymentSection,
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
//	|		SUM(HotelProductTotalSales.PaymentAmount) AS PaymentAmount,
//	|		SUM(HotelProductTotalSales.PaymentAmountWithoutVAT) AS PaymentAmountWithoutVAT,
//	|		SUM(HotelProductTotalSales.CashSum) AS CashSum,
//	|		SUM(HotelProductTotalSales.CreditCardSum) AS CreditCardSum,
//	|		SUM(HotelProductTotalSales.BankTransferSum) AS BankTransferSum,
//	|		COUNT(DISTINCT HotelProductTotalSales.ПутевкаКурсовка) AS Count
//	|	FROM
//	|		(SELECT
//	|			HotelProductTotalSalesTurnovers.Валюта AS Валюта,
//	|			HotelProductTotalSalesTurnovers.Гостиница AS Гостиница,
//	|			HotelProductTotalSalesTurnovers.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			HotelProductTotalSalesTurnovers.Агент AS Агент,
//	|			CASE
//	|				WHEN HotelProductTotalSalesTurnovers.Контрагент = &qEmptyCustomer
//	|					THEN HotelProductTotalSalesTurnovers.Гостиница.IndividualsCustomer
//	|				ELSE HotelProductTotalSalesTurnovers.Контрагент
//	|			END AS Контрагент,
//	|			CASE
//	|				WHEN HotelProductTotalSalesTurnovers.Контрагент = &qEmptyCustomer
//	|						AND HotelProductTotalSalesTurnovers.Договор = &qEmptyContract
//	|					THEN HotelProductTotalSalesTurnovers.Гостиница.IndividualsContract
//	|				ELSE HotelProductTotalSalesTurnovers.Договор
//	|			END AS Договор,
//	|			HotelProductTotalSalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|			HotelProductTotalSalesTurnovers.Клиент AS Клиент,
//	|			CASE
//	|				WHEN NOT HotelProductTotalSalesTurnovers.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|						AND HotelProductTotalSalesTurnovers.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					THEN HotelProductTotalSalesTurnovers.СчетПроживания
//	|				WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование IS NULL 
//	|					THEN HotelProductTotalSalesTurnovers.ДокОснование
//	|				ELSE HotelProductTotalSalesTurnovers.СчетПроживания
//	|			END AS ДокОснование,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|			CASE
//	|				WHEN NOT &qSplitPaymentsByColumns
//	|						AND NOT &qIsEmptyPaymentMethod
//	|					THEN &qPaymentMethod
//	|				WHEN NOT &qSplitPaymentsByColumns
//	|						AND &qIsEmptyPaymentMethod
//	|					THEN HotelProductTotalSalesTurnovers.СпособОплаты
//	|				ELSE &qEmptyPaymentMethod
//	|			END AS СпособОплаты,
//	|			HotelProductTotalSalesTurnovers.Услуга.PaymentSection AS PaymentSection,
//	|			HotelProductTotalSalesTurnovers.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.Тариф AS Тариф,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.ВидРазмещения AS ВидРазмещения,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.ТипКлиента AS ТипКлиента,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.МаретингНапрвл AS МаретингНапрвл,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.TripPurpose AS TripPurpose,
//	|			HotelProductTotalSalesTurnovers.ДокОснование.ТипСкидки AS ТипСкидки,
//	|			CASE
//	|				WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.CheckInDate IS NULL 
//	|					THEN HotelProductTotalSalesTurnovers.ДокОснование.CheckInDate
//	|				WHEN NOT HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeFrom IS NULL 
//	|					THEN HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeFrom
//	|				WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.DateTimeFrom IS NULL 
//	|					THEN HotelProductTotalSalesTurnovers.ДокОснование.DateTimeFrom
//	|				ELSE &qEmptyDate
//	|			END AS CheckInDate,
//	|			CASE
//	|				WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|					THEN HotelProductTotalSalesTurnovers.ДокОснование.CheckOutDate
//	|				WHEN NOT HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeTo IS NULL 
//	|					THEN HotelProductTotalSalesTurnovers.СчетПроживания.DateTimeTo
//	|				WHEN NOT HotelProductTotalSalesTurnovers.ДокОснование.DateTimeTo IS NULL 
//	|					THEN HotelProductTotalSalesTurnovers.ДокОснование.DateTimeTo
//	|				ELSE &qEmptyDate
//	|			END AS CheckOutDate,
//	|			HotelProductTotalSalesTurnovers.SalesTurnover AS Продажи,
//	|			HotelProductTotalSalesTurnovers.RoomRevenueTurnover AS ДоходНомеров,
//	|			HotelProductTotalSalesTurnovers.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|			HotelProductTotalSalesTurnovers.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|			HotelProductTotalSalesTurnovers.CommissionSumTurnover AS СуммаКомиссии,
//	|			HotelProductTotalSalesTurnovers.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|			HotelProductTotalSalesTurnovers.DiscountSumTurnover AS СуммаСкидки,
//	|			HotelProductTotalSalesTurnovers.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|			HotelProductTotalSalesTurnovers.RoomsRentedTurnover AS ПроданоНомеров,
//	|			HotelProductTotalSalesTurnovers.BedsRentedTurnover AS ПроданоМест,
//	|			HotelProductTotalSalesTurnovers.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|			HotelProductTotalSalesTurnovers.GuestDaysTurnover AS ЧеловекаДни,
//	|			HotelProductTotalSalesTurnovers.GuestsCheckedInTurnover AS ЗаездГостей,
//	|			0 AS PaymentAmount,
//	|			0 AS PaymentAmountWithoutVAT,
//	|			0 AS CashSum,
//	|			0 AS CreditCardSum,
//	|			0 AS BankTransferSum
//	|		FROM
//	|			AccumulationRegister.ПродажиПутевокКурсовок.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Period,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer)
//	|						AND (Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|							OR &qIsEmptyHotelProduct)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)) AS HotelProductTotalSalesTurnovers
//	|				INNER JOIN HotelProductPayments AS HotelProductPayments
//	|				ON HotelProductTotalSalesTurnovers.ГруппаГостей = HotelProductPayments.ГруппаГостей
//	|					AND HotelProductTotalSalesTurnovers.СчетПроживания.НомерРазмещения = HotelProductPayments.НомерРазмещения
//	|					AND HotelProductTotalSalesTurnovers.Услуга.PaymentSection = HotelProductPayments.PaymentSection
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			SalesForecastTurnovers.Валюта,
//	|			SalesForecastTurnovers.Гостиница,
//	|			SalesForecastTurnovers.ПутевкаКурсовка,
//	|			SalesForecastTurnovers.Агент,
//	|			CASE
//	|				WHEN SalesForecastTurnovers.Контрагент = &qEmptyCustomer
//	|					THEN SalesForecastTurnovers.Гостиница.IndividualsCustomer
//	|				ELSE SalesForecastTurnovers.Контрагент
//	|			END,
//	|			CASE
//	|				WHEN SalesForecastTurnovers.Контрагент = &qEmptyCustomer
//	|						AND SalesForecastTurnovers.Договор = &qEmptyContract
//	|					THEN SalesForecastTurnovers.Гостиница.IndividualsContract
//	|				ELSE SalesForecastTurnovers.Договор
//	|			END,
//	|			SalesForecastTurnovers.ГруппаГостей,
//	|			SalesForecastTurnovers.Клиент,
//	|			CASE
//	|				WHEN NOT SalesForecastTurnovers.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|						AND SalesForecastTurnovers.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					THEN SalesForecastTurnovers.СчетПроживания
//	|				WHEN NOT SalesForecastTurnovers.ДокОснование IS NULL 
//	|					THEN SalesForecastTurnovers.ДокОснование
//	|				ELSE SalesForecastTurnovers.СчетПроживания
//	|			END,
//	|			SalesForecastTurnovers.ДокОснование.КоличествоЧеловек,
//	|			CASE
//	|				WHEN NOT &qSplitPaymentsByColumns
//	|						AND NOT &qIsEmptyPaymentMethod
//	|					THEN &qPaymentMethod
//	|				WHEN NOT &qSplitPaymentsByColumns
//	|						AND &qIsEmptyPaymentMethod
//	|					THEN SalesForecastTurnovers.СпособОплаты
//	|				ELSE &qEmptyPaymentMethod
//	|			END,
//	|			SalesForecastTurnovers.Услуга.PaymentSection,
//	|			SalesForecastTurnovers.СчетПроживания.НомерРазмещения,
//	|			SalesForecastTurnovers.ДокОснование.Тариф,
//	|			SalesForecastTurnovers.ДокОснование.ВидРазмещения,
//	|			SalesForecastTurnovers.ДокОснование.ТипКлиента,
//	|			SalesForecastTurnovers.ДокОснование.МаретингНапрвл,
//	|			SalesForecastTurnovers.ДокОснование.ИсточИнфоГостиница,
//	|			SalesForecastTurnovers.ДокОснование.TripPurpose,
//	|			SalesForecastTurnovers.ДокОснование.ТипСкидки,
//	|			CASE
//	|				WHEN NOT SalesForecastTurnovers.ДокОснование.CheckInDate IS NULL 
//	|					THEN SalesForecastTurnovers.ДокОснование.CheckInDate
//	|				WHEN NOT SalesForecastTurnovers.СчетПроживания.DateTimeFrom IS NULL 
//	|					THEN SalesForecastTurnovers.СчетПроживания.DateTimeFrom
//	|				WHEN NOT SalesForecastTurnovers.ДокОснование.DateTimeFrom IS NULL 
//	|					THEN SalesForecastTurnovers.ДокОснование.DateTimeFrom
//	|				ELSE &qEmptyDate
//	|			END,
//	|			CASE
//	|				WHEN NOT SalesForecastTurnovers.ДокОснование.CheckOutDate IS NULL 
//	|					THEN SalesForecastTurnovers.ДокОснование.CheckOutDate
//	|				WHEN NOT SalesForecastTurnovers.СчетПроживания.DateTimeTo IS NULL 
//	|					THEN SalesForecastTurnovers.СчетПроживания.DateTimeTo
//	|				WHEN NOT SalesForecastTurnovers.ДокОснование.DateTimeTo IS NULL 
//	|					THEN SalesForecastTurnovers.ДокОснование.DateTimeTo
//	|				ELSE &qEmptyDate
//	|			END,
//	|			SalesForecastTurnovers.SalesTurnover,
//	|			SalesForecastTurnovers.RoomRevenueTurnover,
//	|			SalesForecastTurnovers.SalesWithoutVATTurnover,
//	|			SalesForecastTurnovers.RoomRevenueWithoutVATTurnover,
//	|			SalesForecastTurnovers.CommissionSumTurnover,
//	|			SalesForecastTurnovers.CommissionSumWithoutVATTurnover,
//	|			SalesForecastTurnovers.DiscountSumTurnover,
//	|			SalesForecastTurnovers.DiscountSumWithoutVATTurnover,
//	|			SalesForecastTurnovers.RoomsRentedTurnover,
//	|			SalesForecastTurnovers.BedsRentedTurnover,
//	|			SalesForecastTurnovers.AdditionalBedsRentedTurnover,
//	|			SalesForecastTurnovers.GuestDaysTurnover,
//	|			SalesForecastTurnovers.GuestsCheckedInTurnover,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Period,
//	|					Услуга.IsHotelProductService
//	|						AND ПутевкаКурсовка <> &qEmptyHotelProduct
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer)
//	|						AND (Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (ПутевкаКурсовка IN HIERARCHY (&qHotelProduct)
//	|							OR &qIsEmptyHotelProduct)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)) AS SalesForecastTurnovers
//	|				INNER JOIN HotelProductPayments AS HotelProductPayments
//	|				ON SalesForecastTurnovers.ГруппаГостей = HotelProductPayments.ГруппаГостей
//	|					AND (SalesForecastTurnovers.СчетПроживания.НомерРазмещения = HotelProductPayments.НомерРазмещения
//	|						OR SalesForecastTurnovers.ДокОснование.НомерДока = HotelProductPayments.ДокОснование.НомерДока
//	|							AND SalesForecastTurnovers.ДокОснование.НомерРазмещения = &qEmptyRoom)
//	|					AND SalesForecastTurnovers.Услуга.PaymentSection = HotelProductPayments.PaymentSection
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			GuestGroupPayments.ВалютаРасчетов,
//	|			GuestGroupPayments.Гостиница,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|						AND GuestGroupPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					THEN GuestGroupPayments.СчетПроживания.ПутевкаКурсовка
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|						AND GuestGroupPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|				ELSE GuestGroupPayments.ДокОснование.ПутевкаКурсовка
//	|			END,
//	|			GuestGroupPayments.СчетПроживания.Агент,
//	|			GuestGroupPayments.Контрагент,
//	|			GuestGroupPayments.Договор,
//	|			GuestGroupPayments.ГруппаГостей,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|						AND GuestGroupPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					THEN GuestGroupPayments.СчетПроживания.Клиент
//	|				ELSE GuestGroupPayments.Клиент
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|						AND GuestGroupPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|					THEN GuestGroupPayments.СчетПроживания
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование
//	|				WHEN NOT GuestGroupPayments.ДокОснование IS NULL 
//	|					THEN GuestGroupPayments.ДокОснование
//	|				ELSE GuestGroupPayments.СчетПроживания
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.КоличествоЧеловек IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.КоличествоЧеловек
//	|				ELSE GuestGroupPayments.ДокОснование.КоличествоЧеловек
//	|			END,
//	|			CASE
//	|				WHEN GuestGroupPayments.Recorder.СпособОплаты = &qDepositTransfer
//	|						AND NOT &qSplitPaymentsByColumns
//	|					THEN GuestGroupPayments.СчетПроживания.СпособОплаты
//	|				WHEN NOT &qSplitPaymentsByColumns
//	|					THEN GuestGroupPayments.Recorder.СпособОплаты
//	|				ELSE &qEmptyPaymentMethod
//	|			END,
//	|			GuestGroupPayments.PaymentSection,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.НомерРазмещения IS NULL 
//	|						AND GuestGroupPayments.СчетПроживания.НомерРазмещения <> &qEmptyRoom
//	|					THEN GuestGroupPayments.СчетПроживания.НомерРазмещения
//	|				WHEN GuestGroupPayments.НомерРазмещения <> &qEmptyRoom
//	|					THEN GuestGroupPayments.НомерРазмещения
//	|				ELSE GuestGroupPayments.ДокОснование.НомерРазмещения
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.Тариф IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.Тариф
//	|				ELSE GuestGroupPayments.ДокОснование.Тариф
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.ВидРазмещения IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.ВидРазмещения
//	|				ELSE GuestGroupPayments.ДокОснование.ВидРазмещения
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.ТипКлиента IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.ТипКлиента
//	|				ELSE GuestGroupPayments.ДокОснование.ТипКлиента
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.МаретингНапрвл IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.МаретингНапрвл
//	|				ELSE GuestGroupPayments.ДокОснование.МаретингНапрвл
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.ИсточИнфоГостиница IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.ИсточИнфоГостиница
//	|				ELSE GuestGroupPayments.ДокОснование.ИсточИнфоГостиница
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.TripPurpose IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.TripPurpose
//	|				ELSE GuestGroupPayments.ДокОснование.TripPurpose
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.ТипСкидки IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.ТипСкидки
//	|				ELSE GuestGroupPayments.ДокОснование.ТипСкидки
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.CheckInDate IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.CheckInDate
//	|				WHEN NOT GuestGroupPayments.ДокОснование.CheckInDate IS NULL 
//	|					THEN GuestGroupPayments.ДокОснование.CheckInDate
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.DateTimeFrom IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.DateTimeFrom
//	|				WHEN NOT GuestGroupPayments.ДокОснование.DateTimeFrom IS NULL 
//	|					THEN GuestGroupPayments.ДокОснование.DateTimeFrom
//	|				ELSE &qEmptyDate
//	|			END,
//	|			CASE
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.CheckOutDate IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.ДокОснование.CheckOutDate
//	|				WHEN NOT GuestGroupPayments.ДокОснование.CheckOutDate IS NULL 
//	|					THEN GuestGroupPayments.ДокОснование.CheckOutDate
//	|				WHEN NOT GuestGroupPayments.СчетПроживания.DateTimeTo IS NULL 
//	|					THEN GuestGroupPayments.СчетПроживания.DateTimeTo
//	|				WHEN NOT GuestGroupPayments.ДокОснование.DateTimeTo IS NULL 
//	|					THEN GuestGroupPayments.ДокОснование.DateTimeTo
//	|				ELSE &qEmptyDate
//	|			END,
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
//	|			GuestGroupPayments.Сумма,
//	|			GuestGroupPayments.Сумма - GuestGroupPayments.СуммаНДС,
//	|			CASE
//	|				WHEN GuestGroupPayments.Recorder.СпособОплаты.IsByCash
//	|					THEN GuestGroupPayments.Сумма
//	|				ELSE 0
//	|			END,
//	|			CASE
//	|				WHEN GuestGroupPayments.Recorder.СпособОплаты.IsByCreditCard
//	|					THEN GuestGroupPayments.Сумма
//	|				ELSE 0
//	|			END,
//	|			CASE
//	|				WHEN GuestGroupPayments.Recorder.СпособОплаты.IsByBankTransfer
//	|					THEN GuestGroupPayments.Сумма
//	|				ELSE 0
//	|			END
//	|		FROM
//	|			AccumulationRegister.ВзаиморасчетыКонтрагенты AS GuestGroupPayments
//	|		WHERE
//	|			GuestGroupPayments.RecordType = VALUE(AccumulationrecordType.Expense)
//	|			AND GuestGroupPayments.Period >= &qPaymentPeriodFrom
//	|			AND GuestGroupPayments.Period <= &qPeriodTo
//	|			AND (GuestGroupPayments.PaymentSection = &qEmptyPaymentSection
//	|						AND NOT GuestGroupPayments.СчетПроживания.Description LIKE &qFolioFilter
//	|					OR GuestGroupPayments.PaymentSection <> &qEmptyPaymentSection
//	|						AND ISNULL(GuestGroupPayments.PaymentSection.IsForHotelProducts, FALSE))
//	|			AND GuestGroupPayments.Гостиница IN HIERARCHY(&qHotel)
//	|			AND (GuestGroupPayments.Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|			AND (GuestGroupPayments.Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|			AND (GuestGroupPayments.ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|			AND (GuestGroupPayments.Recorder.СпособОплаты = &qPaymentMethod
//	|					OR &qIsEmptyPaymentMethod)
//	|			AND CASE
//	|					WHEN NOT GuestGroupPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|							AND GuestGroupPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|						THEN GuestGroupPayments.СчетПроживания.ПутевкаКурсовка
//	|					WHEN NOT GuestGroupPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|							AND GuestGroupPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|						THEN GuestGroupPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|					ELSE GuestGroupPayments.ДокОснование.ПутевкаКурсовка
//	|				END IN
//	|					(SELECT
//	|						HotelProductPayments.ПутевкаКурсовка
//	|					FROM
//	|						HotelProductPayments AS HotelProductPayments)) AS HotelProductTotalSales
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
//	|		HotelProductTotalSales.PaymentSection,
//	|		HotelProductTotalSales.НомерРазмещения,
//	|		HotelProductTotalSales.Тариф,
//	|		HotelProductTotalSales.ВидРазмещения,
//	|		HotelProductTotalSales.ТипКлиента,
//	|		HotelProductTotalSales.МаретингНапрвл,
//	|		HotelProductTotalSales.ИсточИнфоГостиница,
//	|		HotelProductTotalSales.TripPurpose,
//	|		HotelProductTotalSales.ТипСкидки) AS ПродажиПутевокКурсовок
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
//	|	ПродажиПутевокКурсовок.PaymentSection.* AS PaymentSection,
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
//	|	ПродажиПутевокКурсовок.PaymentAmount,
//	|	ПродажиПутевокКурсовок.PaymentAmountWithoutVAT,
//	|	ПродажиПутевокКурсовок.CashSum,
//	|	ПродажиПутевокКурсовок.CreditCardSum,
//	|	ПродажиПутевокКурсовок.BankTransferSum}
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
//	|	ПродажиПутевокКурсовок.PaymentSection.* AS PaymentSection,
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
//	|	PaymentAmount,
//	|	PaymentAmountWithoutVAT,
//	|	CashSum,
//	|	CreditCardSum,
//	|	BankTransferSum}
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
//	|	SUM(PaymentAmount),
//	|	SUM(PaymentAmountWithoutVAT),
//	|	SUM(CashSum),
//	|	SUM(CreditCardSum),
//	|	SUM(BankTransferSum)
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
//	|	ПродажиПутевокКурсовок.PaymentSection.* AS PaymentSection,
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
//	ReportBuilder.HeaderText = NStr("ru='Платежи по путевкам';de='Zahlungen im Reisechecks';en='Payments by vauchers'");
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
//	   Or pName = "PaymentAmount"
//	   Or pName = "PaymentAmountWithoutVAT" 
//	   Or pName = "CashSum" 
//	   Or pName = "CreditCardSum" 
//	   Or pName = "BankTransferSum" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
