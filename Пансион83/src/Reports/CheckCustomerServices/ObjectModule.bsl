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
//	If ЗначениеЗаполнено(Agent) Тогда
//		If НЕ Agent.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Agent ';ru='Агент ';de='Vertreter'") + 
//			                     TrimAll(Agent.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Agents folder ';ru='Группа агентов ';de='Gruppe Vertreter'") + 
//			                     TrimAll(Agent.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qServicesPeriodFrom", '00010101');
//	ReportBuilder.Parameters.Вставить("qServicesPeriodTo", '39991231235959');
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qContractIsEmpty", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qAgent", Agent);
//	ReportBuilder.Parameters.Вставить("qAgentIsEmpty", НЕ ЗначениеЗаполнено(Agent));
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qShowExpectedAmounts", ShowExpectedAmounts);
//	vShowPrice = False;
//	If ReportBuilder.SelectedFields.Find("Цена") <> Неопределено Тогда
//		vShowPrice = True;
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qShowPrice", vShowPrice);
//	vShowExpectedPrice = False;
//	If ReportBuilder.SelectedFields.Find("ExpectedPrice") <> Неопределено Тогда
//		vShowExpectedPrice = True;
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qShowExpectedPrice", vShowExpectedPrice);
//	vShowServices = False;
//	If ReportBuilder.SelectedFields.Find("Услуга") <> Неопределено Тогда
//		vShowServices = True;
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qShowServices", vShowServices);
//	ReportBuilder.Parameters.Вставить("qEmptyService", Справочники.Услуги.EmptyRef());
//	vShowDates = False;
//	If ReportBuilder.SelectedFields.Find("УчетнаяДата") <> Неопределено Тогда
//		vShowDates = True;
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qShowDates", vShowDates);
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
//	ReportBuilder.Parameters.Вставить("qEmptyAccommodationType", Справочники.ВидыРазмещения.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyRoomType", Справочники.ТипыНомеров.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyRoom", Справочники.НомернойФонд.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyRoomRate", Справочники.Тарифы.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyResource", Справочники.Ресурсы.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyReservation", Documents.Reservation.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyResourceReservationStatus", Справочники.СтатусБрониРесурсов.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyPaymentMethod", Справочники.СпособОплаты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyClient", Справочники.Клиенты.EmptyRef());
//	
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	//// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	//
//	//// Output report to the spreadsheet
//	//ReportBuilder.Put(pSpreadsheet);
//	////ReportBuilder.Template.Show(); // For debug purpose
//
//	//// Apply appearance settings to the report spreadsheet
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
//	|	БухРеализацияУслуг.Фирма AS Фирма,
//	|	БухРеализацияУслуг.Гостиница AS Гостиница,
//	|	БухРеализацияУслуг.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	ISNULL(БухРеализацияУслуг.СчетПроживания.Агент, &qEmptyCustomer) AS Агент,
//	|	ISNULL(БухРеализацияУслуг.СчетПроживания.СпособОплаты, &qEmptyPaymentMethod) AS СпособОплаты,
//	|	БухРеализацияУслуг.Контрагент AS Контрагент,
//	|	БухРеализацияУслуг.Договор AS Договор,
//	|	БухРеализацияУслуг.ГруппаГостей AS ГруппаГостей,
//	|	БухРеализацияУслуг.ДокОснование AS ДокОснование,
//	|	CAST(БухРеализацияУслуг.ДокОснование.Примечания AS STRING(1024)) AS Примечания,
//	|	ISNULL(БухРеализацияУслуг.Начисление.Услуга, &qEmptyService) AS Услуга,
//	|	BEGINOFPERIOD(БухРеализацияУслуг.Period, DAY) AS УчетнаяДата,
//	|	CASE
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.Клиент IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.Клиент
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.Клиент IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.Клиент
//	|		ELSE ISNULL(БухРеализацияУслуг.СчетПроживания.Клиент, &qEmptyClient)
//	|	END AS Клиент,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.ДокОснование.CheckInDate IS NULL 
//	|			THEN ISNULL(БухРеализацияУслуг.СчетПроживания.DateTimeFrom, &qEmptyDate)
//	|		ELSE БухРеализацияУслуг.ДокОснование.CheckInDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.ДокОснование.CheckOutDate IS NULL 
//	|			THEN ISNULL(БухРеализацияУслуг.СчетПроживания.DateTimeTo, &qEmptyDate)
//	|		ELSE БухРеализацияУслуг.ДокОснование.CheckOutDate
//	|	END AS CheckOutDate,
//	|	CASE
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.СтатусРазмещения IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.СтатусРазмещения
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.ReservationStatus IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.ReservationStatus
//	|		ELSE ISNULL(БухРеализацияУслуг.ДокОснование.ResourceReservationStatus, &qEmptyResourceReservationStatus)
//	|	END AS Status,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.ВидРазмещения = &qEmptyAccommodationType
//	|				AND NOT БухРеализацияУслуг.ДокОснование.ВидРазмещения IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.ВидРазмещения
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.ВидРазмещения, &qEmptyAccommodationtype)
//	|	END AS ВидРазмещения,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.НомерРазмещения = &qEmptyRoom
//	|				AND NOT БухРеализацияУслуг.ДокОснование.НомерРазмещения IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.НомерРазмещения
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.НомерРазмещения, &qEmptyRoom)
//	|	END AS НомерРазмещения,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.ТипНомера = &qEmptyRoomType
//	|				AND NOT БухРеализацияУслуг.ДокОснование.ТипНомера IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.ТипНомера
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.ТипНомера, &qEmptyRoomType)
//	|	END AS ТипНомера,
//	|	ISNULL(БухРеализацияУслуг.ДокОснование.Ресурс, &qEmptyResource) AS Ресурс,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.Тариф = &qEmptyRoomRate
//	|				AND NOT БухРеализацияУслуг.ДокОснование.Тариф IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.Тариф
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.Тариф, &qEmptyRoomRate)
//	|	END AS Тариф,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN ISNULL(БухРеализацияУслуг.ДокОснование.Reservation, &qEmptyReservation)
//	|		ELSE БухРеализацияУслуг.ДокОснование
//	|	END AS Reservation,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Количество <> 0
//	|			THEN CAST((ISNULL(БухРеализацияУслуг.Начисление.Сумма, 0) - ISNULL(БухРеализацияУслуг.Начисление.СуммаСкидки, 0)) / БухРеализацияУслуг.Количество AS NUMBER(17, 2))
//	|		ELSE 0
//	|	END AS Цена,
//	|	ISNULL(БухРеализацияУслуг.Начисление.ЭтоРазделение, FALSE) AS ЭтоРазделение,
//	|	SUM(БухРеализацияУслуг.Количество) AS Количество,
//	|	SUM(БухРеализацияУслуг.Сумма) AS Продажи,
//	|	SUM(БухРеализацияУслуг.Сумма - БухРеализацияУслуг.СуммаНДС) AS ПродажиБезНДС,
//	|	SUM(CASE
//	|			WHEN ISNULL(БухРеализацияУслуг.Начисление.IsRoomRevenue, FALSE)
//	|				THEN БухРеализацияУслуг.Сумма
//	|			ELSE 0
//	|		END) AS ДоходНомеров,
//	|	SUM(CASE
//	|			WHEN ISNULL(БухРеализацияУслуг.Начисление.IsRoomRevenue, FALSE)
//	|				THEN БухРеализацияУслуг.Сумма - БухРеализацияУслуг.СуммаНДС
//	|			ELSE 0
//	|		END) AS ДоходПродажиБезНДС,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.СуммаКомиссии, 0)
//	|			ELSE -ISNULL(БухРеализацияУслуг.Начисление.СуммаКомиссии, 0)
//	|		END) AS СуммаКомиссии,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.СуммаКомиссии, 0) - ISNULL(БухРеализацияУслуг.Начисление.VATCommissionSum, 0)
//	|			ELSE -(ISNULL(БухРеализацияУслуг.Начисление.СуммаКомиссии, 0) - ISNULL(БухРеализацияУслуг.Начисление.VATCommissionSum, 0))
//	|		END) AS КомиссияБезНДС,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.СуммаСкидки, 0)
//	|			ELSE -ISNULL(БухРеализацияУслуг.Начисление.СуммаСкидки, 0)
//	|		END) AS СуммаСкидки,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.СуммаСкидки, 0) - ISNULL(БухРеализацияУслуг.Начисление.НДСскидка, 0)
//	|			ELSE -(ISNULL(БухРеализацияУслуг.Начисление.СуммаСкидки, 0) - ISNULL(БухРеализацияУслуг.Начисление.НДСскидка, 0))
//	|		END) AS СуммаСкидкиБезНДС,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоНомеров, 0)
//	|			ELSE -ISNULL(БухРеализацияУслуг.Начисление.ПроданоНомеров, 0)
//	|		END) AS ПроданоНомеров,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоМест, 0)
//	|			ELSE -ISNULL(БухРеализацияУслуг.Начисление.ПроданоМест, 0)
//	|		END) AS ПроданоМест,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоДопМест, 0)
//	|			ELSE -ISNULL(БухРеализацияУслуг.Начисление.ПроданоДопМест, 0)
//	|		END) AS ПроданоДопМест,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ЧеловекаДни, 0)
//	|			ELSE -ISNULL(БухРеализацияУслуг.Начисление.ЧеловекаДни, 0)
//	|		END) AS ЧеловекаДни,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0)
//	|			ELSE -ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0)
//	|		END) AS ЗаездГостей,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Количество > 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоНомеров, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество < 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN -ISNULL(БухРеализацияУслуг.Начисление.ПроданоНомеров, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество > 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NOT NULL 
//	|				THEN -ISNULL(БухРеализацияУслуг.Начисление.ПроданоНомеров, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество < 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NOT NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоНомеров, 0) / БухРеализацияУслуг.Количество
//	|			ELSE 0
//	|		END) AS ЗаездНомеров,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Количество > 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоМест, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество < 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN -ISNULL(БухРеализацияУслуг.Начисление.ПроданоМест, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество > 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NOT NULL 
//	|				THEN -ISNULL(БухРеализацияУслуг.Начисление.ПроданоМест, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество < 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NOT NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоМест, 0) / БухРеализацияУслуг.Количество
//	|			ELSE 0
//	|		END) AS ЗаездМест,
//	|	SUM(CASE
//	|			WHEN БухРеализацияУслуг.Количество > 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоДопМест, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество < 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NULL 
//	|				THEN -ISNULL(БухРеализацияУслуг.Начисление.ПроданоДопМест, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество > 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NOT NULL 
//	|				THEN -ISNULL(БухРеализацияУслуг.Начисление.ПроданоДопМест, 0) / БухРеализацияУслуг.Количество
//	|			WHEN БухРеализацияУслуг.Количество < 0
//	|					AND ISNULL(БухРеализацияУслуг.Начисление.ЗаездГостей, 0) <> 0
//	|					AND БухРеализацияУслуг.Recorder.ParentCharge IS NOT NULL 
//	|				THEN ISNULL(БухРеализацияУслуг.Начисление.ПроданоДопМест, 0) / БухРеализацияУслуг.Количество
//	|			ELSE 0
//	|		END) AS ЗаездДополнительныхМест
//	|INTO ChargedAccountsReceivable
//	|FROM
//	|	AccumulationRegister.РелизацияТекОтчетПериод AS БухРеализацияУслуг
//	|WHERE
//	|	БухРеализацияУслуг.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|	AND БухРеализацияУслуг.Period >= &qServicesPeriodFrom
//	|	AND БухРеализацияУслуг.Period <= &qServicesPeriodTo
//	|	AND БухРеализацияУслуг.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (БухРеализацияУслуг.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qCustomerIsEmpty)
//	|	AND (БухРеализацияУслуг.Договор IN HIERARCHY (&qContract)
//	|			OR &qContractIsEmpty)
//	|	AND (БухРеализацияУслуг.ГруппаГостей = &qGuestGroup
//	|			OR &qGuestGroupIsEmpty)
//	|	AND (БухРеализацияУслуг.СчетПроживания.Агент IN HIERARCHY (&qAgent)
//	|			OR &qAgentIsEmpty)
//	|	AND (NOT БухРеализацияУслуг.ДокОснование.CheckInDate IS NULL 
//	|				AND БухРеализацияУслуг.ДокОснование.CheckInDate >= &qPeriodFrom
//	|			OR NOT БухРеализацияУслуг.ДокОснование.DateTimeFrom IS NULL 
//	|				AND БухРеализацияУслуг.ДокОснование.DateTimeFrom >= &qPeriodFrom)
//	|	AND (NOT БухРеализацияУслуг.ДокОснование.CheckInDate IS NULL 
//	|				AND БухРеализацияУслуг.ДокОснование.CheckInDate <= &qPeriodTo
//	|			OR NOT БухРеализацияУслуг.ДокОснование.DateTimeFrom IS NULL 
//	|				AND БухРеализацияУслуг.ДокОснование.DateTimeFrom <= &qPeriodTo)
//	|	AND (БухРеализацияУслуг.Начисление.Услуга IN (&qServicesList)
//	|			OR NOT &qUseServicesList)
//	|	AND (БухРеализацияУслуг.Сумма <> 0
//	|			OR БухРеализацияУслуг.Количество <> 0)
//	|
//	|GROUP BY
//	|	БухРеализацияУслуг.Фирма,
//	|	БухРеализацияУслуг.Гостиница,
//	|	БухРеализацияУслуг.ВалютаЛицСчета,
//	|	ISNULL(БухРеализацияУслуг.СчетПроживания.Агент, &qEmptyCustomer),
//	|	ISNULL(БухРеализацияУслуг.СчетПроживания.СпособОплаты, &qEmptyPaymentMethod),
//	|	БухРеализацияУслуг.Контрагент,
//	|	БухРеализацияУслуг.Договор,
//	|	БухРеализацияУслуг.ГруппаГостей,
//	|	БухРеализацияУслуг.ДокОснование,
//	|	CAST(БухРеализацияУслуг.ДокОснование.Примечания AS STRING(1024)),
//	|	ISNULL(БухРеализацияУслуг.Начисление.Услуга, &qEmptyService),
//	|	BEGINOFPERIOD(БухРеализацияУслуг.Period, DAY),
//	|	CASE
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.Клиент IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.Клиент
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.Клиент IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.Клиент
//	|		ELSE ISNULL(БухРеализацияУслуг.СчетПроживания.Клиент, &qEmptyClient)
//	|	END,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.ДокОснование.CheckInDate IS NULL 
//	|			THEN ISNULL(БухРеализацияУслуг.СчетПроживания.DateTimeFrom, &qEmptyDate)
//	|		ELSE БухРеализацияУслуг.ДокОснование.CheckInDate
//	|	END,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.ДокОснование.CheckOutDate IS NULL 
//	|			THEN ISNULL(БухРеализацияУслуг.СчетПроживания.DateTimeTo, &qEmptyDate)
//	|		ELSE БухРеализацияУслуг.ДокОснование.CheckOutDate
//	|	END,
//	|	CASE
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.СтатусРазмещения IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.СтатусРазмещения
//	|		WHEN NOT БухРеализацияУслуг.ДокОснование.ReservationStatus IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.ReservationStatus
//	|		ELSE ISNULL(БухРеализацияУслуг.ДокОснование.ResourceReservationStatus, &qEmptyResourceReservationStatus)
//	|	END,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.ВидРазмещения = &qEmptyAccommodationType
//	|				AND NOT БухРеализацияУслуг.ДокОснование.ВидРазмещения IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.ВидРазмещения
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.ВидРазмещения, &qEmptyAccommodationtype)
//	|	END,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.НомерРазмещения = &qEmptyRoom
//	|				AND NOT БухРеализацияУслуг.ДокОснование.НомерРазмещения IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.НомерРазмещения
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.НомерРазмещения, &qEmptyRoom)
//	|	END,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.ТипНомера = &qEmptyRoomType
//	|				AND NOT БухРеализацияУслуг.ДокОснование.ТипНомера IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.ТипНомера
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.ТипНомера, &qEmptyRoomType)
//	|	END,
//	|	ISNULL(БухРеализацияУслуг.ДокОснование.Ресурс, &qEmptyResource),
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Начисление.Тариф = &qEmptyRoomRate
//	|				AND NOT БухРеализацияУслуг.ДокОснование.Тариф IS NULL 
//	|			THEN БухРеализацияУслуг.ДокОснование.Тариф
//	|		ELSE ISNULL(БухРеализацияУслуг.Начисление.Тариф, &qEmptyRoomRate)
//	|	END,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.ДокОснование.DateTimeFrom IS NULL 
//	|			THEN ISNULL(БухРеализацияУслуг.ДокОснование.Reservation, &qEmptyReservation)
//	|		ELSE БухРеализацияУслуг.ДокОснование
//	|	END,
//	|	CASE
//	|		WHEN БухРеализацияУслуг.Количество <> 0
//	|			THEN CAST((ISNULL(БухРеализацияУслуг.Начисление.Сумма, 0) - ISNULL(БухРеализацияУслуг.Начисление.СуммаСкидки, 0)) / БухРеализацияУслуг.Количество AS NUMBER(17, 2))
//	|		ELSE 0
//	|	END,
//	|	ISNULL(БухРеализацияУслуг.Начисление.ЭтоРазделение, FALSE)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	ПрогнозРеализации.Фирма AS Фирма,
//	|	ПрогнозРеализации.Гостиница AS Гостиница,
//	|	ПрогнозРеализации.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	ПрогнозРеализации.Агент AS Агент,
//	|	ПрогнозРеализации.СпособОплаты AS СпособОплаты,
//	|	ПрогнозРеализации.Контрагент AS Контрагент,
//	|	ПрогнозРеализации.Договор AS Договор,
//	|	ПрогнозРеализации.ГруппаГостей AS ГруппаГостей,
//	|	ПрогнозРеализации.Recorder AS ДокОснование,
//	|	CAST(ПрогнозРеализации.Recorder.Примечания AS STRING(1024)) AS Примечания,
//	|	ПрогнозРеализации.Услуга AS Услуга,
//	|	ПрогнозРеализации.УчетнаяДата AS УчетнаяДата,
//	|	ПрогнозРеализации.Клиент AS Клиент,
//	|	CASE
//	|		WHEN NOT ПрогнозРеализации.Recorder.CheckInDate IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.CheckInDate
//	|		WHEN NOT ПрогнозРеализации.Recorder.DateTimeFrom IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN NOT ПрогнозРеализации.Recorder.CheckOutDate IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.CheckOutDate
//	|		WHEN NOT ПрогнозРеализации.Recorder.DateTimeTo IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END AS CheckOutDate,
//	|	CASE
//	|		WHEN NOT ПрогнозРеализации.Recorder.ReservationStatus IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.ReservationStatus
//	|		ELSE ISNULL(ПрогнозРеализации.Recorder.ResourceReservationStatus, &qEmptyResourceReservationStatus)
//	|	END AS Status,
//	|	CASE
//	|		WHEN ПрогнозРеализации.ВидРазмещения = &qEmptyAccommodationType
//	|				AND NOT ПрогнозРеализации.Recorder.ВидРазмещения IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.ВидРазмещения
//	|		ELSE ПрогнозРеализации.ВидРазмещения
//	|	END AS ВидРазмещения,
//	|	CASE
//	|		WHEN ПрогнозРеализации.НомерРазмещения = &qEmptyRoom
//	|				AND NOT ПрогнозРеализации.Recorder.НомерРазмещения IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.НомерРазмещения
//	|		ELSE ПрогнозРеализации.НомерРазмещения
//	|	END AS НомерРазмещения,
//	|	CASE
//	|		WHEN ПрогнозРеализации.ТипНомера = &qEmptyRoomType
//	|				AND NOT ПрогнозРеализации.Recorder.ТипНомера IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.ТипНомера
//	|		ELSE ПрогнозРеализации.ТипНомера
//	|	END AS ТипНомера,
//	|	CASE
//	|		WHEN ПрогнозРеализации.Ресурс = &qEmptyResource
//	|				AND NOT ПрогнозРеализации.Recorder.Ресурс IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.Ресурс
//	|		ELSE ПрогнозРеализации.Ресурс
//	|	END AS Ресурс,
//	|	CASE
//	|		WHEN ПрогнозРеализации.Тариф = &qEmptyRoomRate
//	|				AND NOT ПрогнозРеализации.Recorder.Тариф IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.Тариф
//	|		ELSE ПрогнозРеализации.Тариф
//	|	END AS Тариф,
//	|	ПрогнозРеализации.Recorder AS Reservation,
//	|	CASE
//	|		WHEN NOT &qShowExpectedPrice
//	|			THEN 0
//	|		WHEN ПрогнозРеализации.ПланКоличество <> 0
//	|			THEN CAST(ПрогнозРеализации.ПланПродаж / ПрогнозРеализации.ПланКоличество AS NUMBER(17, 2))
//	|		ELSE 0
//	|	END AS ExpectedPrice,
//	|	ПрогнозРеализации.ЭтоРазделение AS ЭтоРазделение,
//	|	SUM(ПрогнозРеализации.ПланКоличество) AS ПланКоличество,
//	|	SUM(ПрогнозРеализации.ПланПродаж) AS ПланПродаж,
//	|	SUM(ПрогнозРеализации.ExpectedSalesWithoutVAT) AS ExpectedSalesWithoutVAT,
//	|	SUM(ПрогнозРеализации.ExpectedRoomRevenue) AS ExpectedRoomRevenue,
//	|	SUM(ПрогнозРеализации.ExpectedRoomRevenueWithoutVAT) AS ExpectedRoomRevenueWithoutVAT,
//	|	SUM(ПрогнозРеализации.КомиссияПлан) AS КомиссияПлан,
//	|	SUM(ПрогнозРеализации.ExpectedCommissionSumWithoutVAT) AS ExpectedCommissionSumWithoutVAT,
//	|	SUM(ПрогнозРеализации.ПланСуммаСкидки) AS ПланСуммаСкидки,
//	|	SUM(ПрогнозРеализации.ExpectedDiscountSumWithoutVAT) AS ExpectedDiscountSumWithoutVAT,
//	|	SUM(ПрогнозРеализации.ПланПродажиНомеров) AS ПланПродажиНомеров,
//	|	SUM(ПрогнозРеализации.ПланПродажиМест) AS ПланПродажиМест,
//	|	SUM(ПрогнозРеализации.ПланПродажиДопМест) AS ПланПродажиДопМест,
//	|	SUM(ПрогнозРеализации.ExpectedGuestDays) AS ExpectedGuestDays,
//	|	SUM(ПрогнозРеализации.ExpectedGuestsCheckedIn) AS ExpectedGuestsCheckedIn,
//	|	SUM(ПрогнозРеализации.ExpectedRoomsCheckedIn) AS ExpectedRoomsCheckedIn,
//	|	SUM(ПрогнозРеализации.ПланЗаездМест) AS ПланЗаездМест,
//	|	SUM(ПрогнозРеализации.ПланЗаездДопМест) AS ПланЗаездДопМест
//	|INTO ExpectedAccountsReceivable
//	|FROM
//	|	AccumulationRegister.ПрогнозРеализации AS ПрогнозРеализации
//	|WHERE
//	|	&qShowExpectedAmounts
//	|	AND ПрогнозРеализации.Period >= &qServicesPeriodFrom
//	|	AND ПрогнозРеализации.Period <= &qServicesPeriodTo
//	|	AND ПрогнозРеализации.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (ПрогнозРеализации.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qCustomerIsEmpty)
//	|	AND (ПрогнозРеализации.Договор IN HIERARCHY (&qContract)
//	|			OR &qContractIsEmpty)
//	|	AND (ПрогнозРеализации.ГруппаГостей = &qGuestGroup
//	|			OR &qGuestGroupIsEmpty)
//	|	AND (ПрогнозРеализации.Агент IN HIERARCHY (&qAgent)
//	|			OR &qAgentIsEmpty)
//	|	AND (NOT ПрогнозРеализации.Recorder.CheckInDate IS NULL 
//	|				AND ПрогнозРеализации.Recorder.CheckInDate >= &qPeriodFrom
//	|			OR NOT ПрогнозРеализации.Recorder.DateTimeFrom IS NULL 
//	|				AND ПрогнозРеализации.Recorder.DateTimeFrom >= &qPeriodFrom)
//	|	AND (NOT ПрогнозРеализации.Recorder.CheckInDate IS NULL 
//	|				AND ПрогнозРеализации.Recorder.CheckInDate <= &qPeriodTo
//	|			OR NOT ПрогнозРеализации.Recorder.DateTimeFrom IS NULL 
//	|				AND ПрогнозРеализации.Recorder.DateTimeFrom <= &qPeriodTo)
//	|	AND (ПрогнозРеализации.Услуга IN (&qServicesList)
//	|			OR NOT &qUseServicesList)
//	|	AND (ПрогнозРеализации.ПланКоличество <> 0
//	|			OR ПрогнозРеализации.ПланПродаж <> 0)
//	|
//	|GROUP BY
//	|	ПрогнозРеализации.Фирма,
//	|	ПрогнозРеализации.Гостиница,
//	|	ПрогнозРеализации.ВалютаЛицСчета,
//	|	ПрогнозРеализации.Агент,
//	|	ПрогнозРеализации.СпособОплаты,
//	|	ПрогнозРеализации.Контрагент,
//	|	ПрогнозРеализации.Договор,
//	|	ПрогнозРеализации.ГруппаГостей,
//	|	ПрогнозРеализации.Recorder,
//	|	CAST(ПрогнозРеализации.Recorder.Примечания AS STRING(1024)),
//	|	ПрогнозРеализации.Услуга,
//	|	ПрогнозРеализации.УчетнаяДата,
//	|	ПрогнозРеализации.Клиент,
//	|	CASE
//	|		WHEN NOT ПрогнозРеализации.Recorder.CheckInDate IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.CheckInDate
//	|		WHEN NOT ПрогнозРеализации.Recorder.DateTimeFrom IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.DateTimeFrom
//	|		ELSE &qEmptyDate
//	|	END,
//	|	CASE
//	|		WHEN NOT ПрогнозРеализации.Recorder.CheckOutDate IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.CheckOutDate
//	|		WHEN NOT ПрогнозРеализации.Recorder.DateTimeTo IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.DateTimeTo
//	|		ELSE &qEmptyDate
//	|	END,
//	|	CASE
//	|		WHEN NOT ПрогнозРеализации.Recorder.ReservationStatus IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.ReservationStatus
//	|		ELSE ISNULL(ПрогнозРеализации.Recorder.ResourceReservationStatus, &qEmptyResourceReservationStatus)
//	|	END,
//	|	CASE
//	|		WHEN ПрогнозРеализации.ВидРазмещения = &qEmptyAccommodationType
//	|				AND NOT ПрогнозРеализации.Recorder.ВидРазмещения IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.ВидРазмещения
//	|		ELSE ПрогнозРеализации.ВидРазмещения
//	|	END,
//	|	CASE
//	|		WHEN ПрогнозРеализации.НомерРазмещения = &qEmptyRoom
//	|				AND NOT ПрогнозРеализации.Recorder.НомерРазмещения IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.НомерРазмещения
//	|		ELSE ПрогнозРеализации.НомерРазмещения
//	|	END,
//	|	CASE
//	|		WHEN ПрогнозРеализации.ТипНомера = &qEmptyRoomType
//	|				AND NOT ПрогнозРеализации.Recorder.ТипНомера IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.ТипНомера
//	|		ELSE ПрогнозРеализации.ТипНомера
//	|	END,
//	|	CASE
//	|		WHEN ПрогнозРеализации.Ресурс = &qEmptyResource
//	|				AND NOT ПрогнозРеализации.Recorder.Ресурс IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.Ресурс
//	|		ELSE ПрогнозРеализации.Ресурс
//	|	END,
//	|	CASE
//	|		WHEN ПрогнозРеализации.Тариф = &qEmptyRoomRate
//	|				AND NOT ПрогнозРеализации.Recorder.Тариф IS NULL 
//	|			THEN ПрогнозРеализации.Recorder.Тариф
//	|		ELSE ПрогнозРеализации.Тариф
//	|	END,
//	|	CASE
//	|		WHEN NOT &qShowExpectedPrice
//	|			THEN 0
//	|		WHEN ПрогнозРеализации.ПланКоличество <> 0
//	|			THEN CAST(ПрогнозРеализации.ПланПродаж / ПрогнозРеализации.ПланКоличество AS NUMBER(17, 2))
//	|		ELSE 0
//	|	END,
//	|	ПрогнозРеализации.ЭтоРазделение,
//	|	ПрогнозРеализации.Recorder
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	CustomerTurnovers.Фирма AS Фирма,
//	|	CustomerTurnovers.Гостиница AS Гостиница,
//	|	CustomerTurnovers.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	CustomerTurnovers.СпособОплаты AS СпособОплаты,
//	|	CustomerTurnovers.Агент AS Агент,
//	|	CustomerTurnovers.Контрагент AS Контрагент,
//	|	CustomerTurnovers.Договор AS Договор,
//	|	CustomerTurnovers.ГруппаГостей AS ГруппаГостей,
//	|	CustomerTurnovers.ДокОснование AS ДокОснование,
//	|	CustomerTurnovers.Reservation AS Reservation,
//	|	CustomerTurnovers.Клиент AS Клиент,
//	|	CustomerTurnovers.CheckInDate AS CheckInDate,
//	|	CustomerTurnovers.CheckOutDate AS CheckOutDate,
//	|	CustomerTurnovers.ВидРазмещения AS ВидРазмещения,
//	|	CustomerTurnovers.Status AS Status,
//	|	CustomerTurnovers.НомерРазмещения AS НомерРазмещения,
//	|	CustomerTurnovers.ТипНомера AS ТипНомера,
//	|	CustomerTurnovers.Ресурс AS Ресурс,
//	|	CustomerTurnovers.Услуга AS Услуга,
//	|	CustomerTurnovers.УчетнаяДата AS УчетнаяДата,
//	|	CustomerTurnovers.Продажи AS Продажи,
//	|	CustomerTurnovers.ПродажиБезНДС AS ПродажиБезНДС,
//	|	CustomerTurnovers.ДоходНомеров AS ДоходНомеров,
//	|	CustomerTurnovers.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	CustomerTurnovers.СуммаКомиссии AS СуммаКомиссии,
//	|	CustomerTurnovers.КомиссияБезНДС AS КомиссияБезНДС,
//	|	CustomerTurnovers.СуммаСкидки AS СуммаСкидки,
//	|	CustomerTurnovers.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	CustomerTurnovers.ПроданоНомеров AS ПроданоНомеров,
//	|	CustomerTurnovers.ПроданоМест AS ПроданоМест,
//	|	CustomerTurnovers.ПроданоДопМест AS ПроданоДопМест,
//	|	CustomerTurnovers.ЧеловекаДни AS ЧеловекаДни,
//	|	CustomerTurnovers.ЗаездГостей AS ЗаездГостей,
//	|	CustomerTurnovers.ЗаездНомеров AS ЗаездНомеров,
//	|	CustomerTurnovers.ЗаездМест AS ЗаездМест,
//	|	CustomerTurnovers.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	CustomerTurnovers.Количество AS Количество,
//	|	CustomerTurnovers.ПланПродаж AS ПланПродаж,
//	|	CustomerTurnovers.ExpectedSalesWithoutVAT AS ExpectedSalesWithoutVAT,
//	|	CustomerTurnovers.ExpectedRoomRevenue AS ExpectedRoomRevenue,
//	|	CustomerTurnovers.ExpectedRoomRevenueWithoutVAT AS ExpectedRoomRevenueWithoutVAT,
//	|	CustomerTurnovers.КомиссияПлан AS КомиссияПлан,
//	|	CustomerTurnovers.ExpectedCommissionSumWithoutVAT AS ExpectedCommissionSumWithoutVAT,
//	|	CustomerTurnovers.ПланСуммаСкидки AS ПланСуммаСкидки,
//	|	CustomerTurnovers.ExpectedDiscountSumWithoutVAT AS ExpectedDiscountSumWithoutVAT,
//	|	CustomerTurnovers.ПланПродажиНомеров AS ПланПродажиНомеров,
//	|	CustomerTurnovers.ПланПродажиМест AS ПланПродажиМест,
//	|	CustomerTurnovers.ПланПродажиДопМест AS ПланПродажиДопМест,
//	|	CustomerTurnovers.ExpectedGuestDays AS ExpectedGuestDays,
//	|	CustomerTurnovers.ExpectedGuestsCheckedIn AS ExpectedGuestsCheckedIn,
//	|	CustomerTurnovers.ExpectedRoomsCheckedIn AS ExpectedRoomsCheckedIn,
//	|	CustomerTurnovers.ПланЗаездМест AS ПланЗаездМест,
//	|	CustomerTurnovers.ПланЗаездДопМест AS ПланЗаездДопМест,
//	|	CustomerTurnovers.ПланКоличество AS ПланКоличество
//	|{SELECT
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	ВалютаЛицСчета.*,
//	|	СпособОплаты.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	CheckOutDate,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.Цена AS Цена,
//	|	CustomerTurnovers.ExpectedPrice AS ExpectedPrice,
//	|	ДокОснование.*,
//	|	CustomerTurnovers.Примечания AS Примечания,
//	|	Reservation.*,
//	|	Услуга.*,
//	|	УчетнаяДата,
//	|	(CASE
//	|			WHEN CustomerTurnovers.Продажи <> CustomerTurnovers.ПланПродаж
//	|					AND NOT CustomerTurnovers.Reservation IS NULL 
//	|					AND NOT CustomerTurnovers.Reservation = &qEmptyReservation
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS PlanAndFactAreDifferent,
//	|	Продажи,
//	|	ПродажиБезНДС,
//	|	ДоходНомеров,
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
//	|	ПланПродаж,
//	|	ExpectedSalesWithoutVAT,
//	|	ExpectedRoomRevenue,
//	|	ExpectedRoomRevenueWithoutVAT,
//	|	КомиссияПлан,
//	|	ExpectedCommissionSumWithoutVAT,
//	|	ПланСуммаСкидки,
//	|	ExpectedDiscountSumWithoutVAT,
//	|	ПланПродажиНомеров,
//	|	ПланПродажиМест,
//	|	ПланПродажиДопМест,
//	|	ExpectedGuestDays,
//	|	ExpectedGuestsCheckedIn,
//	|	ExpectedRoomsCheckedIn,
//	|	ПланЗаездМест,
//	|	ПланЗаездДопМест,
//	|	ExpectedQuantity}
//	|FROM
//	|	(SELECT
//	|		CustomerSales.Фирма AS Фирма,
//	|		CustomerSales.Гостиница AS Гостиница,
//	|		CustomerSales.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|		CustomerSales.СпособОплаты AS СпособОплаты,
//	|		CustomerSales.Агент AS Агент,
//	|		CustomerSales.Контрагент AS Контрагент,
//	|		CustomerSales.Договор AS Договор,
//	|		CustomerSales.ГруппаГостей AS ГруппаГостей,
//	|		CustomerSales.ДокОснование AS ДокОснование,
//	|		CustomerSales.Примечания AS Примечания,
//	|		CustomerSales.Услуга AS Услуга,
//	|		CustomerSales.УчетнаяДата AS УчетнаяДата,
//	|		CustomerSales.Клиент AS Клиент,
//	|		CustomerSales.CheckInDate AS CheckInDate,
//	|		CustomerSales.CheckOutDate AS CheckOutDate,
//	|		CustomerSales.Status AS Status,
//	|		CustomerSales.ВидРазмещения AS ВидРазмещения,
//	|		CustomerSales.НомерРазмещения AS НомерРазмещения,
//	|		CustomerSales.ТипНомера AS ТипНомера,
//	|		CustomerSales.Ресурс AS Ресурс,
//	|		CustomerSales.Тариф AS Тариф,
//	|		CustomerSales.Reservation AS Reservation,
//	|		CustomerSales.Цена AS Цена,
//	|		CustomerSales.ExpectedPrice AS ExpectedPrice,
//	|		SUM(CustomerSales.Продажи) AS Продажи,
//	|		SUM(CustomerSales.ПродажиБезНДС) AS ПродажиБезНДС,
//	|		SUM(CustomerSales.ДоходНомеров) AS ДоходНомеров,
//	|		SUM(CustomerSales.ДоходПродажиБезНДС) AS ДоходПродажиБезНДС,
//	|		SUM(CustomerSales.СуммаКомиссии) AS СуммаКомиссии,
//	|		SUM(CustomerSales.КомиссияБезНДС) AS КомиссияБезНДС,
//	|		SUM(CustomerSales.СуммаСкидки) AS СуммаСкидки,
//	|		SUM(CustomerSales.СуммаСкидкиБезНДС) AS СуммаСкидкиБезНДС,
//	|		SUM(CustomerSales.ПроданоНомеров) AS ПроданоНомеров,
//	|		SUM(CustomerSales.ПроданоМест) AS ПроданоМест,
//	|		SUM(CustomerSales.ПроданоДопМест) AS ПроданоДопМест,
//	|		SUM(CustomerSales.ЧеловекаДни) AS ЧеловекаДни,
//	|		SUM(CustomerSales.ЗаездГостей) AS ЗаездГостей,
//	|		SUM(CustomerSales.ЗаездНомеров) AS ЗаездНомеров,
//	|		SUM(CustomerSales.ЗаездМест) AS ЗаездМест,
//	|		SUM(CustomerSales.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест,
//	|		SUM(CustomerSales.Количество) AS Количество,
//	|		SUM(CustomerSales.ПланПродаж) AS ПланПродаж,
//	|		SUM(CustomerSales.ExpectedSalesWithoutVAT) AS ExpectedSalesWithoutVAT,
//	|		SUM(CustomerSales.ExpectedRoomRevenue) AS ExpectedRoomRevenue,
//	|		SUM(CustomerSales.ExpectedRoomRevenueWithoutVAT) AS ExpectedRoomRevenueWithoutVAT,
//	|		SUM(CustomerSales.КомиссияПлан) AS КомиссияПлан,
//	|		SUM(CustomerSales.ExpectedCommissionSumWithoutVAT) AS ExpectedCommissionSumWithoutVAT,
//	|		SUM(CustomerSales.ПланСуммаСкидки) AS ПланСуммаСкидки,
//	|		SUM(CustomerSales.ExpectedDiscountSumWithoutVAT) AS ExpectedDiscountSumWithoutVAT,
//	|		SUM(CustomerSales.ПланПродажиНомеров) AS ПланПродажиНомеров,
//	|		SUM(CustomerSales.ПланПродажиМест) AS ПланПродажиМест,
//	|		SUM(CustomerSales.ПланПродажиДопМест) AS ПланПродажиДопМест,
//	|		SUM(CustomerSales.ExpectedGuestDays) AS ExpectedGuestDays,
//	|		SUM(CustomerSales.ExpectedGuestsCheckedIn) AS ExpectedGuestsCheckedIn,
//	|		SUM(CustomerSales.ExpectedRoomsCheckedIn) AS ExpectedRoomsCheckedIn,
//	|		SUM(CustomerSales.ПланЗаездМест) AS ПланЗаездМест,
//	|		SUM(CustomerSales.ПланЗаездДопМест) AS ПланЗаездДопМест,
//	|		SUM(CustomerSales.ПланКоличество) AS ПланКоличество
//	|	FROM
//	|		(SELECT
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Фирма IS NULL 
//	|					THEN ExpectedAccountsReceivable.Фирма
//	|				ELSE ChargedAccountsReceivable.Фирма
//	|			END AS Фирма,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Гостиница IS NULL 
//	|					THEN ExpectedAccountsReceivable.Гостиница
//	|				ELSE ChargedAccountsReceivable.Гостиница
//	|			END AS Гостиница,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.ВалютаЛицСчета IS NULL 
//	|					THEN ExpectedAccountsReceivable.ВалютаЛицСчета
//	|				ELSE ChargedAccountsReceivable.ВалютаЛицСчета
//	|			END AS ВалютаЛицСчета,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Агент IS NULL 
//	|					THEN ExpectedAccountsReceivable.Агент
//	|				ELSE ChargedAccountsReceivable.Агент
//	|			END AS Агент,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.СпособОплаты IS NULL 
//	|					THEN ExpectedAccountsReceivable.СпособОплаты
//	|				ELSE ChargedAccountsReceivable.СпособОплаты
//	|			END AS СпособОплаты,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Контрагент IS NULL 
//	|					THEN ExpectedAccountsReceivable.Контрагент
//	|				ELSE ChargedAccountsReceivable.Контрагент
//	|			END AS Контрагент,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Договор IS NULL 
//	|					THEN ExpectedAccountsReceivable.Договор
//	|				ELSE ChargedAccountsReceivable.Договор
//	|			END AS Договор,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.ГруппаГостей IS NULL 
//	|					THEN ExpectedAccountsReceivable.ГруппаГостей
//	|				ELSE ChargedAccountsReceivable.ГруппаГостей
//	|			END AS ГруппаГостей,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.ДокОснование IS NULL 
//	|					THEN ExpectedAccountsReceivable.ДокОснование
//	|				ELSE ChargedAccountsReceivable.ДокОснование
//	|			END AS ДокОснование,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.ДокОснование IS NULL 
//	|					THEN ExpectedAccountsReceivable.Примечания
//	|				ELSE ChargedAccountsReceivable.Примечания
//	|			END AS Примечания,
//	|			CASE
//	|				WHEN NOT &qShowServices
//	|					THEN &qEmptyService
//	|				WHEN ChargedAccountsReceivable.Услуга IS NULL 
//	|					THEN ExpectedAccountsReceivable.Услуга
//	|				ELSE ChargedAccountsReceivable.Услуга
//	|			END AS Услуга,
//	|			CASE
//	|				WHEN NOT &qShowDates
//	|					THEN &qEmptyDate
//	|				WHEN ChargedAccountsReceivable.УчетнаяДата IS NULL 
//	|					THEN ExpectedAccountsReceivable.УчетнаяДата
//	|				ELSE ChargedAccountsReceivable.УчетнаяДата
//	|			END AS УчетнаяДата,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Клиент IS NULL 
//	|					THEN ExpectedAccountsReceivable.Клиент
//	|				ELSE ChargedAccountsReceivable.Клиент
//	|			END AS Клиент,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.CheckInDate IS NULL 
//	|					THEN ExpectedAccountsReceivable.CheckInDate
//	|				ELSE ChargedAccountsReceivable.CheckInDate
//	|			END AS CheckInDate,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.CheckOutDate IS NULL 
//	|					THEN ExpectedAccountsReceivable.CheckOutDate
//	|				ELSE ChargedAccountsReceivable.CheckOutDate
//	|			END AS CheckOutDate,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Status IS NULL 
//	|					THEN ExpectedAccountsReceivable.Status
//	|				ELSE ChargedAccountsReceivable.Status
//	|			END AS Status,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.ВидРазмещения IS NULL 
//	|					THEN ExpectedAccountsReceivable.ВидРазмещения
//	|				ELSE ChargedAccountsReceivable.ВидРазмещения
//	|			END AS ВидРазмещения,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.НомерРазмещения IS NULL 
//	|					THEN ExpectedAccountsReceivable.НомерРазмещения
//	|				ELSE ChargedAccountsReceivable.НомерРазмещения
//	|			END AS НомерРазмещения,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.ТипНомера IS NULL 
//	|					THEN ExpectedAccountsReceivable.ТипНомера
//	|				ELSE ChargedAccountsReceivable.ТипНомера
//	|			END AS ТипНомера,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Ресурс IS NULL 
//	|					THEN ExpectedAccountsReceivable.Ресурс
//	|				ELSE ChargedAccountsReceivable.Ресурс
//	|			END AS Ресурс,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Тариф IS NULL 
//	|					THEN ExpectedAccountsReceivable.Тариф
//	|				ELSE ChargedAccountsReceivable.Тариф
//	|			END AS Тариф,
//	|			CASE
//	|				WHEN ChargedAccountsReceivable.Reservation IS NULL 
//	|					THEN ExpectedAccountsReceivable.Reservation
//	|				ELSE ChargedAccountsReceivable.Reservation
//	|			END AS Reservation,
//	|			CASE
//	|				WHEN NOT &qShowPrice
//	|					THEN 0
//	|				WHEN ChargedAccountsReceivable.Цена IS NULL 
//	|					THEN ISNULL(ExpectedAccountsReceivable.ExpectedPrice, 0)
//	|				ELSE ChargedAccountsReceivable.Цена
//	|			END AS Цена,
//	|			CASE
//	|				WHEN NOT &qShowExpectedPrice
//	|					THEN 0
//	|				ELSE ISNULL(ExpectedAccountsReceivable.ExpectedPrice, 0)
//	|			END AS ExpectedPrice,
//	|			ISNULL(ChargedAccountsReceivable.Количество, 0) AS Количество,
//	|			ISNULL(ChargedAccountsReceivable.Продажи, 0) AS Продажи,
//	|			ISNULL(ChargedAccountsReceivable.ПродажиБезНДС, 0) AS ПродажиБезНДС,
//	|			ISNULL(ChargedAccountsReceivable.ДоходНомеров, 0) AS ДоходНомеров,
//	|			ISNULL(ChargedAccountsReceivable.ДоходПродажиБезНДС, 0) AS ДоходПродажиБезНДС,
//	|			ISNULL(ChargedAccountsReceivable.СуммаКомиссии, 0) AS СуммаКомиссии,
//	|			ISNULL(ChargedAccountsReceivable.КомиссияБезНДС, 0) AS КомиссияБезНДС,
//	|			ISNULL(ChargedAccountsReceivable.СуммаСкидки, 0) AS СуммаСкидки,
//	|			ISNULL(ChargedAccountsReceivable.СуммаСкидкиБезНДС, 0) AS СуммаСкидкиБезНДС,
//	|			ISNULL(ChargedAccountsReceivable.ПроданоНомеров, 0) AS ПроданоНомеров,
//	|			ISNULL(ChargedAccountsReceivable.ПроданоМест, 0) AS ПроданоМест,
//	|			ISNULL(ChargedAccountsReceivable.ПроданоДопМест, 0) AS ПроданоДопМест,
//	|			ISNULL(ChargedAccountsReceivable.ЧеловекаДни, 0) AS ЧеловекаДни,
//	|			ISNULL(ChargedAccountsReceivable.ЗаездГостей, 0) AS ЗаездГостей,
//	|			ISNULL(ChargedAccountsReceivable.ЗаездНомеров, 0) AS ЗаездНомеров,
//	|			ISNULL(ChargedAccountsReceivable.ЗаездМест, 0) AS ЗаездМест,
//	|			ISNULL(ChargedAccountsReceivable.ЗаездДополнительныхМест, 0) AS ЗаездДополнительныхМест,
//	|			ISNULL(ExpectedAccountsReceivable.ПланКоличество, 0) AS ПланКоличество,
//	|			ISNULL(ExpectedAccountsReceivable.ПланПродаж, 0) AS ПланПродаж,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedSalesWithoutVAT, 0) AS ExpectedSalesWithoutVAT,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedRoomRevenue, 0) AS ExpectedRoomRevenue,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedRoomRevenueWithoutVAT, 0) AS ExpectedRoomRevenueWithoutVAT,
//	|			ISNULL(ExpectedAccountsReceivable.КомиссияПлан, 0) AS КомиссияПлан,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedCommissionSumWithoutVAT, 0) AS ExpectedCommissionSumWithoutVAT,
//	|			ISNULL(ExpectedAccountsReceivable.ПланСуммаСкидки, 0) AS ПланСуммаСкидки,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedDiscountSumWithoutVAT, 0) AS ExpectedDiscountSumWithoutVAT,
//	|			ISNULL(ExpectedAccountsReceivable.ПланПродажиНомеров, 0) AS ПланПродажиНомеров,
//	|			ISNULL(ExpectedAccountsReceivable.ПланПродажиМест, 0) AS ПланПродажиМест,
//	|			ISNULL(ExpectedAccountsReceivable.ПланПродажиДопМест, 0) AS ПланПродажиДопМест,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedGuestDays, 0) AS ExpectedGuestDays,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedGuestsCheckedIn, 0) AS ExpectedGuestsCheckedIn,
//	|			ISNULL(ExpectedAccountsReceivable.ExpectedRoomsCheckedIn, 0) AS ExpectedRoomsCheckedIn,
//	|			ISNULL(ExpectedAccountsReceivable.ПланЗаездМест, 0) AS ПланЗаездМест,
//	|			ISNULL(ExpectedAccountsReceivable.ПланЗаездДопМест, 0) AS ПланЗаездДопМест
//	|		FROM
//	|			ChargedAccountsReceivable AS ChargedAccountsReceivable
//	|				FULL JOIN (SELECT
//	|					ПрогнозРеализации.Фирма AS Фирма,
//	|					ПрогнозРеализации.Гостиница AS Гостиница,
//	|					ПрогнозРеализации.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|					ПрогнозРеализации.Агент AS Агент,
//	|					ПрогнозРеализации.СпособОплаты AS СпособОплаты,
//	|					ПрогнозРеализации.Контрагент AS Контрагент,
//	|					ПрогнозРеализации.Договор AS Договор,
//	|					ПрогнозРеализации.ГруппаГостей AS ГруппаГостей,
//	|					ПрогнозРеализации.ДокОснование AS ДокОснование,
//	|					ПрогнозРеализации.Примечания AS Примечания,
//	|					ПрогнозРеализации.Услуга AS Услуга,
//	|					ПрогнозРеализации.УчетнаяДата AS УчетнаяДата,
//	|					ПрогнозРеализации.Клиент AS Клиент,
//	|					ПрогнозРеализации.CheckInDate AS CheckInDate,
//	|					ПрогнозРеализации.CheckOutDate AS CheckOutDate,
//	|					ПрогнозРеализации.Status AS Status,
//	|					ПрогнозРеализации.ВидРазмещения AS ВидРазмещения,
//	|					ПрогнозРеализации.НомерРазмещения AS НомерРазмещения,
//	|					ПрогнозРеализации.ТипНомера AS ТипНомера,
//	|					ПрогнозРеализации.Ресурс AS Ресурс,
//	|					ПрогнозРеализации.Тариф AS Тариф,
//	|					ПрогнозРеализации.Reservation AS Reservation,
//	|					ПрогнозРеализации.ExpectedPrice AS ExpectedPrice,
//	|					ПрогнозРеализации.ЭтоРазделение AS ЭтоРазделение,
//	|					ПрогнозРеализации.ПланКоличество AS ПланКоличество,
//	|					ПрогнозРеализации.ПланПродаж AS ПланПродаж,
//	|					ПрогнозРеализации.ExpectedSalesWithoutVAT AS ExpectedSalesWithoutVAT,
//	|					ПрогнозРеализации.ExpectedRoomRevenue AS ExpectedRoomRevenue,
//	|					ПрогнозРеализации.ExpectedRoomRevenueWithoutVAT AS ExpectedRoomRevenueWithoutVAT,
//	|					ПрогнозРеализации.КомиссияПлан AS КомиссияПлан,
//	|					ПрогнозРеализации.ExpectedCommissionSumWithoutVAT AS ExpectedCommissionSumWithoutVAT,
//	|					ПрогнозРеализации.ПланСуммаСкидки AS ПланСуммаСкидки,
//	|					ПрогнозРеализации.ExpectedDiscountSumWithoutVAT AS ExpectedDiscountSumWithoutVAT,
//	|					ПрогнозРеализации.ПланПродажиНомеров AS ПланПродажиНомеров,
//	|					ПрогнозРеализации.ПланПродажиМест AS ПланПродажиМест,
//	|					ПрогнозРеализации.ПланПродажиДопМест AS ПланПродажиДопМест,
//	|					ПрогнозРеализации.ExpectedGuestDays AS ExpectedGuestDays,
//	|					ПрогнозРеализации.ExpectedGuestsCheckedIn AS ExpectedGuestsCheckedIn,
//	|					ПрогнозРеализации.ExpectedRoomsCheckedIn AS ExpectedRoomsCheckedIn,
//	|					ПрогнозРеализации.ПланЗаездМест AS ПланЗаездМест,
//	|					ПрогнозРеализации.ПланЗаездДопМест AS ПланЗаездДопМест
//	|				FROM
//	|					ExpectedAccountsReceivable AS ПрогнозРеализации) AS ExpectedAccountsReceivable
//	|				ON ChargedAccountsReceivable.Reservation = ExpectedAccountsReceivable.Reservation
//	|					AND ChargedAccountsReceivable.Клиент = ExpectedAccountsReceivable.Клиент
//	|					AND ChargedAccountsReceivable.Услуга = ExpectedAccountsReceivable.Услуга
//	|					AND ChargedAccountsReceivable.УчетнаяДата = ExpectedAccountsReceivable.УчетнаяДата
//	|					AND ChargedAccountsReceivable.ЭтоРазделение = ExpectedAccountsReceivable.ЭтоРазделение) AS CustomerSales
//	|	
//	|	GROUP BY
//	|		CustomerSales.Фирма,
//	|		CustomerSales.Гостиница,
//	|		CustomerSales.ВалютаЛицСчета,
//	|		CustomerSales.СпособОплаты,
//	|		CustomerSales.Агент,
//	|		CustomerSales.Контрагент,
//	|		CustomerSales.Договор,
//	|		CustomerSales.ГруппаГостей,
//	|		CustomerSales.ДокОснование,
//	|		CustomerSales.Примечания,
//	|		CustomerSales.Reservation,
//	|		CustomerSales.Услуга,
//	|		CustomerSales.УчетнаяДата,
//	|		CustomerSales.Клиент,
//	|		CustomerSales.CheckInDate,
//	|		CustomerSales.CheckOutDate,
//	|		CustomerSales.Status,
//	|		CustomerSales.ВидРазмещения,
//	|		CustomerSales.НомерРазмещения,
//	|		CustomerSales.ТипНомера,
//	|		CustomerSales.Ресурс,
//	|		CustomerSales.Тариф,
//	|		CustomerSales.ExpectedPrice,
//	|		CustomerSales.Цена) AS CustomerTurnovers
//	|{WHERE
//	|	CustomerTurnovers.Фирма.*,
//	|	CustomerTurnovers.Гостиница.*,
//	|	CustomerTurnovers.ВалютаЛицСчета.*,
//	|	CustomerTurnovers.СпособОплаты.*,
//	|	CustomerTurnovers.Агент.*,
//	|	CustomerTurnovers.Контрагент.*,
//	|	CustomerTurnovers.Договор.*,
//	|	CustomerTurnovers.ГруппаГостей.*,
//	|	CustomerTurnovers.ДокОснование.*,
//	|	CustomerTurnovers.Примечания AS Примечания,
//	|	CustomerTurnovers.Reservation.*,
//	|	CustomerTurnovers.Клиент.* AS Клиент,
//	|	CustomerTurnovers.CheckInDate AS CheckInDate,
//	|	CustomerTurnovers.CheckOutDate AS CheckOutDate,
//	|	CustomerTurnovers.ВидРазмещения.* AS ВидРазмещения,
//	|	CustomerTurnovers.Status.* AS Status,
//	|	CustomerTurnovers.НомерРазмещения.* AS НомерРазмещения,
//	|	CustomerTurnovers.ТипНомера.* AS ТипНомера,
//	|	CustomerTurnovers.Ресурс.* AS Ресурс,
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.Цена AS Цена,
//	|	CustomerTurnovers.ExpectedPrice AS ExpectedPrice,
//	|	CustomerTurnovers.Услуга.*,
//	|	CustomerTurnovers.УчетнаяДата AS УчетнаяДата,
//	|	(CASE
//	|			WHEN CustomerTurnovers.Продажи <> CustomerTurnovers.ПланПродаж
//	|					AND NOT CustomerTurnovers.Reservation IS NULL 
//	|					AND NOT CustomerTurnovers.Reservation = &qEmptyReservation
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS PlanAndFactAreDifferent,
//	|	CustomerTurnovers.Продажи,
//	|	CustomerTurnovers.ПродажиБезНДС,
//	|	CustomerTurnovers.ДоходНомеров,
//	|	CustomerTurnovers.ДоходПродажиБезНДС,
//	|	CustomerTurnovers.СуммаКомиссии,
//	|	CustomerTurnovers.КомиссияБезНДС,
//	|	CustomerTurnovers.СуммаСкидки,
//	|	CustomerTurnovers.СуммаСкидкиБезНДС,
//	|	CustomerTurnovers.ПроданоНомеров,
//	|	CustomerTurnovers.ПроданоМест,
//	|	CustomerTurnovers.ПроданоДопМест,
//	|	CustomerTurnovers.ЧеловекаДни,
//	|	CustomerTurnovers.ЗаездГостей,
//	|	CustomerTurnovers.ЗаездНомеров,
//	|	CustomerTurnovers.ЗаездМест,
//	|	CustomerTurnovers.ЗаездДополнительныхМест,
//	|	CustomerTurnovers.Количество,
//	|	CustomerTurnovers.ПланПродаж,
//	|	CustomerTurnovers.ExpectedSalesWithoutVAT,
//	|	CustomerTurnovers.ExpectedRoomRevenue,
//	|	CustomerTurnovers.ExpectedRoomRevenueWithoutVAT,
//	|	CustomerTurnovers.КомиссияПлан,
//	|	CustomerTurnovers.ExpectedCommissionSumWithoutVAT,
//	|	CustomerTurnovers.ПланСуммаСкидки,
//	|	CustomerTurnovers.ExpectedDiscountSumWithoutVAT,
//	|	CustomerTurnovers.ПланПродажиНомеров,
//	|	CustomerTurnovers.ПланПродажиМест,
//	|	CustomerTurnovers.ПланПродажиДопМест,
//	|	CustomerTurnovers.ExpectedGuestDays,
//	|	CustomerTurnovers.ExpectedGuestsCheckedIn,
//	|	CustomerTurnovers.ExpectedRoomsCheckedIn,
//	|	CustomerTurnovers.ПланЗаездМест,
//	|	CustomerTurnovers.ПланЗаездДопМест,
//	|	CustomerTurnovers.ExpectedQuantity}
//	|
//	|ORDER BY
//	|	Фирма,
//	|	Гостиница,
//	|	ВалютаЛицСчета,
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	CheckInDate,
//	|	Клиент,
//	|	Услуга,
//	|	УчетнаяДата
//	|{ORDER BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	ВалютаЛицСчета.*,
//	|	СпособОплаты.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Агент.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	CheckOutDate,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.Цена AS Цена,
//	|	CustomerTurnovers.ExpectedPrice AS ExpectedPrice,
//	|	ДокОснование.*,
//	|	Reservation.*,
//	|	Услуга.*,
//	|	УчетнаяДата,
//	|	Продажи,
//	|	ПродажиБезНДС,
//	|	ДоходНомеров,
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
//	|	ПланПродаж,
//	|	КомиссияПлан,
//	|	ПланСуммаСкидки,
//	|	ПланПродажиНомеров,
//	|	ПланПродажиМест,
//	|	ПланПродажиДопМест,
//	|	ПланЗаездМест,
//	|	ПланЗаездДопМест,
//	|	ExpectedQuantity}
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходНомеров),
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
//	|	SUM(Количество),
//	|	SUM(ПланПродаж),
//	|	SUM(КомиссияПлан),
//	|	SUM(ПланСуммаСкидки),
//	|	SUM(ПланПродажиНомеров),
//	|	SUM(ПланПродажиМест),
//	|	SUM(ПланПродажиДопМест), 
//	|	SUM(ПланЗаездМест),
//	|	SUM(ПланЗаездДопМест),
//	|	SUM(ПланКоличество)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	ВалютаЛицСчета,
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	ДокОснование
//	|{TOTALS BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	ВалютаЛицСчета.*,
//	|	СпособОплаты.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	НомерРазмещения.*,
//	|	ВидРазмещения.*,
//	|	Status.*,
//	|	ТипНомера.*,
//	|	Ресурс.*,
//	|	CustomerTurnovers.Тариф.* AS Тариф,
//	|	CustomerTurnovers.Цена AS Цена,
//	|	CustomerTurnovers.ExpectedPrice AS ExpectedPrice,
//	|	Услуга.*,
//	|	УчетнаяДата,
//	|	Reservation,
//	|	ДокОснование.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Check Контрагент services';RU='Сверка начислений по контрагентам';de='Abgleich der Berechnungen nach Vertragspartnern'");
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
