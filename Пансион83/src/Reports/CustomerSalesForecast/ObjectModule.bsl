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
//		vParamPresentation = vParamPresentation + NStr("ru = 'Группа гостей '; en = 'Guest group '") + 
//							 TrimAll(TrimAll(GuestGroup.Code) + " " + TrimAll(GuestGroup.Description)) + 
//							 ";" + Chars.LF;
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
//	If ЗначениеЗаполнено(RoomType) Тогда
//		If НЕ RoomType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров type ';ru='Тип номера ';de='Zimmertyp'") + 
//			                     TrimAll(RoomType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров types folder ';ru='Группа типов номеров ';de='Gruppe Zimmertypen'") + 
//			                     TrimAll(RoomType.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	ReportBuilder.Parameters.Вставить("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
//	ReportBuilder.Parameters.Вставить("qService", Service);
//	ReportBuilder.Parameters.Вставить("qServiceIsEmpty", НЕ ЗначениеЗаполнено(Service));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qContractIsEmpty", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
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
//	|	ПрогнозПродаж.Гостиница AS Гостиница,
//	|	ПрогнозПродаж.Валюта AS Валюта,
//	|	ПрогнозПродаж.Контрагент AS Контрагент,
//	|	ПрогнозПродаж.Договор AS Договор,
//	|	ПрогнозПродаж.ПроданоНомеров AS ПроданоНомеров,
//	|	ПрогнозПродаж.RoomsRentedAccommodation AS RoomsRentedAccommodation,
//	|	ПрогнозПродаж.RoomsRentedReservation AS RoomsRentedReservation,
//	|	ПрогнозПродаж.ПроданоМест AS ПроданоМест,
//	|	ПрогнозПродаж.BedsRentedAccommodation AS BedsRentedAccommodation,
//	|	ПрогнозПродаж.BedsRentedReservation AS BedsRentedReservation,
//	|	ПрогнозПродаж.ПроданоДопМест AS ПроданоДопМест,
//	|	ПрогнозПродаж.AdditionalBedsRentedAccommodation AS AdditionalBedsRentedAccommodation,
//	|	ПрогнозПродаж.AdditionalBedsRentedReservation AS AdditionalBedsRentedReservation,
//	|	ПрогнозПродаж.ЧеловекаДни AS ЧеловекаДни,
//	|	ПрогнозПродаж.GuestDaysAccommodation AS GuestDaysAccommodation,
//	|	ПрогнозПродаж.GuestDaysReservation AS GuestDaysReservation,
//	|	ПрогнозПродаж.ЗаездГостей AS ЗаездГостей,
//	|	ПрогнозПродаж.GuestsCheckedInAccommodation AS GuestsCheckedInAccommodation,
//	|	ПрогнозПродаж.GuestsCheckedInReservation AS GuestsCheckedInReservation,
//	|	ПрогнозПродаж.ЗаездНомеров AS ЗаездНомеров,
//	|	ПрогнозПродаж.RoomsCheckedInAccommodation AS RoomsCheckedInAccommodation,
//	|	ПрогнозПродаж.RoomsCheckedInReservation AS RoomsCheckedInReservation,
//	|	ПрогнозПродаж.ЗаездМест AS ЗаездМест,
//	|	ПрогнозПродаж.BedsCheckedInAccommodation AS BedsCheckedInAccommodation,
//	|	ПрогнозПродаж.BedsCheckedInReservation AS BedsCheckedInReservation,
//	|	ПрогнозПродаж.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	ПрогнозПродаж.AdditionalBedsCheckedInAccommodation AS AdditionalBedsCheckedInAccommodation,
//	|	ПрогнозПродаж.AdditionalBedsCheckedInReservation AS AdditionalBedsCheckedInReservation,
//	|	ПрогнозПродаж.Количество AS Количество,
//	|	ПрогнозПродаж.QuantityAccommodation AS QuantityAccommodation,
//	|	ПрогнозПродаж.QuantityReservation AS QuantityReservation,
//	|	ПрогнозПродаж.Продажи AS Продажи,
//	|	ПрогнозПродаж.SalesAccommodation AS SalesAccommodation,
//	|	ПрогнозПродаж.SalesReservation AS SalesReservation,
//	|	ПрогнозПродаж.ПродажиБезНДС AS ПродажиБезНДС,
//	|	ПрогнозПродаж.SalesWithoutVATAccommodation AS SalesWithoutVATAccommodation,
//	|	ПрогнозПродаж.SalesWithoutVATReservation AS SalesWithoutVATReservation,
//	|	ПрогнозПродаж.ДоходНомеров AS ДоходНомеров,
//	|	ПрогнозПродаж.RoomRevenueAccommodation AS RoomRevenueAccommodation,
//	|	ПрогнозПродаж.RoomRevenueReservation AS RoomRevenueReservation,
//	|	ПрогнозПродаж.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	ПрогнозПродаж.RoomRevenueWithoutVATAccommodation AS RoomRevenueWithoutVATAccommodation,
//	|	ПрогнозПродаж.RoomRevenueWithoutVATReservation AS RoomRevenueWithoutVATReservation,
//	|	ПрогнозПродаж.ДоходДопМеста AS ДоходДопМеста,
//	|	ПрогнозПродаж.ExtraBedRevenueAccommodation AS ExtraBedRevenueAccommodation,
//	|	ПрогнозПродаж.ExtraBedRevenueReservation AS ExtraBedRevenueReservation,
//	|	ПрогнозПродаж.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	ПрогнозПродаж.ExtraBedRevenueWithoutVATAccommodation AS ExtraBedRevenueWithoutVATAccommodation,
//	|	ПрогнозПродаж.ExtraBedRevenueWithoutVATReservation AS ExtraBedRevenueWithoutVATReservation,
//	|	ПрогнозПродаж.MainBedsRevenue AS MainBedsRevenue,
//	|	ПрогнозПродаж.MainBedsRevenueAccommodation AS MainBedsRevenueAccommodation,
//	|	ПрогнозПродаж.MainBedsRevenueReservation AS MainBedsRevenueReservation,
//	|	ПрогнозПродаж.MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	ПрогнозПродаж.MainBedsRevenueWithoutVATAccommodation AS MainBedsRevenueWithoutVATAccommodation,
//	|	ПрогнозПродаж.MainBedsRevenueWithoutVATReservation AS MainBedsRevenueWithoutVATReservation,
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
//	|	ПрогнозПродаж.RoomPrice AS RoomPrice
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	ПрогнозПродаж.Тариф.* AS Тариф,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Клиент.* AS Клиент,
//	|	ПрогнозПродаж.Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	(HOUR(ПрогнозПродаж.УчетнаяДата)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	(BEGINOFPERIOD(ПрогнозПродаж.ДокОснование.CheckInDate, DAY)) AS CheckInDate,
//	|	(HOUR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInHour,
//	|	(DAY(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInYear,
//	|	ПрогнозПродаж.ДокОснование.RoomRateType.* AS RoomRateType,
//	|	ПрогнозПродаж.ДокОснование.НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.ДокОснование.ТипНомера.* AS ТипНомера,
//	|	ПрогнозПродаж.ДокОснование.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.ДокОснование.КвотаНомеров.* AS КвотаНомеров,
//	|	ПрогнозПродаж.ДокОснование.Скидка AS Скидка,
//	|	ПрогнозПродаж.ДокОснование.ТипСкидки.* AS ТипСкидки,
//	|	ПрогнозПродаж.ДокОснование.ДисконтКарт.* AS ДисконтКарт,
//	|	ПрогнозПродаж.ДокОснование.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ДокОснование.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.ДокОснование.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ДокОснование.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.ДокОснование.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ПрогнозПродаж.ДокОснование.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ПрогнозПродаж.ДокОснование.КомиссияАгента AS КомиссияАгента,
//	|	ПрогнозПродаж.ДокОснование.Автор.* AS Автор,
//	|	ПроданоНомеров AS ПроданоНомеров,
//	|	RoomsRentedAccommodation AS RoomsRentedAccommodation,
//	|	RoomsRentedReservation AS RoomsRentedReservation,
//	|	ПроданоМест AS ПроданоМест,
//	|	BedsRentedAccommodation AS BedsRentedAccommodation,
//	|	BedsRentedReservation AS BedsRentedReservation,
//	|	ПроданоДопМест AS ПроданоДопМест,
//	|	AdditionalBedsRentedAccommodation AS AdditionalBedsRentedAccommodation,
//	|	AdditionalBedsRentedReservation AS AdditionalBedsRentedReservation,
//	|	ЧеловекаДни AS ЧеловекаДни,
//	|	GuestDaysAccommodation AS GuestDaysAccommodation,
//	|	GuestDaysReservation AS GuestDaysReservation,
//	|	ЗаездГостей AS ЗаездГостей,
//	|	GuestsCheckedInAccommodation AS GuestsCheckedInAccommodation,
//	|	GuestsCheckedInReservation AS GuestsCheckedInReservation,
//	|	ЗаездНомеров AS ЗаездНомеров,
//	|	RoomsCheckedInAccommodation AS RoomsCheckedInAccommodation,
//	|	RoomsCheckedInReservation AS RoomsCheckedInReservation,
//	|	ЗаездМест AS ЗаездМест,
//	|	BedsCheckedInAccommodation AS BedsCheckedInAccommodation,
//	|	BedsCheckedInReservation AS BedsCheckedInReservation,
//	|	ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	AdditionalBedsCheckedInAccommodation AS AdditionalBedsCheckedInAccommodation,
//	|	AdditionalBedsCheckedInReservation AS AdditionalBedsCheckedInReservation,
//	|	Количество AS Количество,
//	|	QuantityAccommodation AS QuantityAccommodation,
//	|	QuantityReservation AS QuantityReservation,
//	|	Продажи AS Продажи,
//	|	SalesAccommodation AS SalesAccommodation,
//	|	SalesReservation AS SalesReservation,
//	|	ПродажиБезНДС AS ПродажиБезНДС,
//	|	SalesWithoutVATAccommodation AS SalesWithoutVATAccommodation,
//	|	SalesWithoutVATReservation AS SalesWithoutVATReservation,
//	|	ДоходНомеров AS ДоходНомеров,
//	|	RoomRevenueAccommodation AS RoomRevenueAccommodation,
//	|	RoomRevenueReservation AS RoomRevenueReservation,
//	|	ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	RoomRevenueWithoutVATAccommodation AS RoomRevenueWithoutVATAccommodation,
//	|	RoomRevenueWithoutVATReservation AS RoomRevenueWithoutVATReservation,
//	|	ДоходДопМеста AS ДоходДопМеста,
//	|	ExtraBedRevenueAccommodation AS ExtraBedRevenueAccommodation,
//	|	ExtraBedRevenueReservation AS ExtraBedRevenueReservation,
//	|	ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	ExtraBedRevenueWithoutVATAccommodation AS ExtraBedRevenueWithoutVATAccommodation,
//	|	ExtraBedRevenueWithoutVATReservation AS ExtraBedRevenueWithoutVATReservation,
//	|	MainBedsRevenue AS MainBedsRevenue,
//	|	MainBedsRevenueAccommodation AS MainBedsRevenueAccommodation,
//	|	MainBedsRevenueReservation AS MainBedsRevenueReservation,
//	|	MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	MainBedsRevenueWithoutVATAccommodation AS MainBedsRevenueWithoutVATAccommodation,
//	|	MainBedsRevenueWithoutVATReservation AS MainBedsRevenueWithoutVATReservation,
//	|	СуммаКомиссии AS СуммаКомиссии,
//	|	CommissionSumAccommodation AS CommissionSumAccommodation,
//	|	CommissionSumReservation AS CommissionSumReservation,
//	|	КомиссияБезНДС AS КомиссияБезНДС,
//	|	CommissionSumWithoutVATAccommodation AS CommissionSumWithoutVATAccommodation,
//	|	CommissionSumWithoutVATReservation AS CommissionSumWithoutVATReservation,
//	|	СуммаСкидки AS СуммаСкидки,
//	|	DiscountSumAccommodation AS DiscountSumAccommodation,
//	|	DiscountSumReservation AS DiscountSumReservation,
//	|	СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	DiscountSumWithoutVATAccommodation AS DiscountSumWithoutVATAccommodation,
//	|	DiscountSumWithoutVATReservation AS DiscountSumWithoutVATReservation,
//	|	RoomPrice}
//	|FROM
//	|	(SELECT
//	|		CustomerSalesUnion.Гостиница AS Гостиница,
//	|		CustomerSalesUnion.Фирма AS Фирма,
//	|		CustomerSalesUnion.Валюта AS Валюта,
//	|		CustomerSalesUnion.Агент AS Агент,
//	|		CustomerSalesUnion.Контрагент AS Контрагент,
//	|		CustomerSalesUnion.Договор AS Договор,
//	|		CustomerSalesUnion.ГруппаГостей AS ГруппаГостей,
//	|		CustomerSalesUnion.Клиент AS Клиент,
//	|		CustomerSalesUnion.Тариф AS Тариф,
//	|		CustomerSalesUnion.УчетнаяДата AS УчетнаяДата,
//	|		CustomerSalesUnion.ДокОснование AS ДокОснование,
//	|		CustomerSalesUnion.Услуга AS Услуга,
//	|		CustomerSalesUnion.СпособОплаты AS СпособОплаты,
//	|		SUM(CustomerSalesUnion.ПроданоНомеров) AS ПроданоНомеров,
//	|		SUM(CustomerSalesUnion.RoomsRentedAccommodation) AS RoomsRentedAccommodation,
//	|		SUM(CustomerSalesUnion.RoomsRentedReservation) AS RoomsRentedReservation,
//	|		SUM(CustomerSalesUnion.ПроданоМест) AS ПроданоМест,
//	|		SUM(CustomerSalesUnion.BedsRentedAccommodation) AS BedsRentedAccommodation,
//	|		SUM(CustomerSalesUnion.BedsRentedReservation) AS BedsRentedReservation,
//	|		SUM(CustomerSalesUnion.ПроданоДопМест) AS ПроданоДопМест,
//	|		SUM(CustomerSalesUnion.AdditionalBedsRentedAccommodation) AS AdditionalBedsRentedAccommodation,
//	|		SUM(CustomerSalesUnion.AdditionalBedsRentedReservation) AS AdditionalBedsRentedReservation,
//	|		SUM(CustomerSalesUnion.ЧеловекаДни) AS ЧеловекаДни,
//	|		SUM(CustomerSalesUnion.GuestDaysAccommodation) AS GuestDaysAccommodation,
//	|		SUM(CustomerSalesUnion.GuestDaysReservation) AS GuestDaysReservation,
//	|		SUM(CustomerSalesUnion.ЗаездГостей) AS ЗаездГостей,
//	|		SUM(CustomerSalesUnion.GuestsCheckedInAccommodation) AS GuestsCheckedInAccommodation,
//	|		SUM(CustomerSalesUnion.GuestsCheckedInReservation) AS GuestsCheckedInReservation,
//	|		SUM(CustomerSalesUnion.ЗаездНомеров) AS ЗаездНомеров,
//	|		SUM(CustomerSalesUnion.RoomsCheckedInAccommodation) AS RoomsCheckedInAccommodation,
//	|		SUM(CustomerSalesUnion.RoomsCheckedInReservation) AS RoomsCheckedInReservation,
//	|		SUM(CustomerSalesUnion.ЗаездМест) AS ЗаездМест,
//	|		SUM(CustomerSalesUnion.BedsCheckedInAccommodation) AS BedsCheckedInAccommodation,
//	|		SUM(CustomerSalesUnion.BedsCheckedInReservation) AS BedsCheckedInReservation,
//	|		SUM(CustomerSalesUnion.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест,
//	|		SUM(CustomerSalesUnion.AdditionalBedsCheckedInAccommodation) AS AdditionalBedsCheckedInAccommodation,
//	|		SUM(CustomerSalesUnion.AdditionalBedsCheckedInReservation) AS AdditionalBedsCheckedInReservation,
//	|		SUM(CustomerSalesUnion.Количество) AS Количество,
//	|		SUM(CustomerSalesUnion.QuantityAccommodation) AS QuantityAccommodation,
//	|		SUM(CustomerSalesUnion.QuantityReservation) AS QuantityReservation,
//	|		SUM(CustomerSalesUnion.Продажи) AS Продажи,
//	|		SUM(CustomerSalesUnion.SalesAccommodation) AS SalesAccommodation,
//	|		SUM(CustomerSalesUnion.SalesReservation) AS SalesReservation,
//	|		SUM(CustomerSalesUnion.ПродажиБезНДС) AS ПродажиБезНДС,
//	|		SUM(CustomerSalesUnion.SalesWithoutVATAccommodation) AS SalesWithoutVATAccommodation,
//	|		SUM(CustomerSalesUnion.SalesWithoutVATReservation) AS SalesWithoutVATReservation,
//	|		SUM(CustomerSalesUnion.ДоходНомеров) AS ДоходНомеров,
//	|		SUM(CustomerSalesUnion.RoomRevenueAccommodation) AS RoomRevenueAccommodation,
//	|		SUM(CustomerSalesUnion.RoomRevenueReservation) AS RoomRevenueReservation,
//	|		SUM(CustomerSalesUnion.ДоходПродажиБезНДС) AS ДоходПродажиБезНДС,
//	|		SUM(CustomerSalesUnion.RoomRevenueWithoutVATAccommodation) AS RoomRevenueWithoutVATAccommodation,
//	|		SUM(CustomerSalesUnion.RoomRevenueWithoutVATReservation) AS RoomRevenueWithoutVATReservation,
//	|		SUM(CustomerSalesUnion.ДоходДопМеста) AS ДоходДопМеста,
//	|		SUM(CustomerSalesUnion.ExtraBedRevenueAccommodation) AS ExtraBedRevenueAccommodation,
//	|		SUM(CustomerSalesUnion.ExtraBedRevenueReservation) AS ExtraBedRevenueReservation,
//	|		SUM(CustomerSalesUnion.ДоходДопМестаБезНДС) AS ДоходДопМестаБезНДС,
//	|		SUM(CustomerSalesUnion.ExtraBedRevenueWithoutVATAccommodation) AS ExtraBedRevenueWithoutVATAccommodation,
//	|		SUM(CustomerSalesUnion.ExtraBedRevenueWithoutVATReservation) AS ExtraBedRevenueWithoutVATReservation,
//	|		SUM(CustomerSalesUnion.MainBedsRevenue) AS MainBedsRevenue,
//	|		SUM(CustomerSalesUnion.MainBedsRevenueAccommodation) AS MainBedsRevenueAccommodation,
//	|		SUM(CustomerSalesUnion.MainBedsRevenueReservation) AS MainBedsRevenueReservation,
//	|		SUM(CustomerSalesUnion.MainBedsRevenueWithoutVAT) AS MainBedsRevenueWithoutVAT,
//	|		SUM(CustomerSalesUnion.MainBedsRevenueWithoutVATAccommodation) AS MainBedsRevenueWithoutVATAccommodation,
//	|		SUM(CustomerSalesUnion.MainBedsRevenueWithoutVATReservation) AS MainBedsRevenueWithoutVATReservation,
//	|		SUM(CustomerSalesUnion.СуммаКомиссии) AS СуммаКомиссии,
//	|		SUM(CustomerSalesUnion.CommissionSumAccommodation) AS CommissionSumAccommodation,
//	|		SUM(CustomerSalesUnion.CommissionSumReservation) AS CommissionSumReservation,
//	|		SUM(CustomerSalesUnion.КомиссияБезНДС) AS КомиссияБезНДС,
//	|		SUM(CustomerSalesUnion.CommissionSumWithoutVATAccommodation) AS CommissionSumWithoutVATAccommodation,
//	|		SUM(CustomerSalesUnion.CommissionSumWithoutVATReservation) AS CommissionSumWithoutVATReservation,
//	|		SUM(CustomerSalesUnion.СуммаСкидки) AS СуммаСкидки,
//	|		SUM(CustomerSalesUnion.DiscountSumAccommodation) AS DiscountSumAccommodation,
//	|		SUM(CustomerSalesUnion.DiscountSumReservation) AS DiscountSumReservation,
//	|		SUM(CustomerSalesUnion.СуммаСкидкиБезНДС) AS СуммаСкидкиБезНДС,
//	|		SUM(CustomerSalesUnion.DiscountSumWithoutVATAccommodation) AS DiscountSumWithoutVATAccommodation,
//	|		SUM(CustomerSalesUnion.DiscountSumWithoutVATReservation) AS DiscountSumWithoutVATReservation,
//	|		MAX(CustomerSalesUnion.RoomPrice) AS RoomPrice
//	|	FROM
//	|		(SELECT
//	|			CustomerSalesTurnovers.Гостиница AS Гостиница,
//	|			CustomerSalesTurnovers.Фирма AS Фирма,
//	|			CustomerSalesTurnovers.Валюта AS Валюта,
//	|			CustomerSalesTurnovers.Агент AS Агент,
//	|			CustomerSalesTurnovers.Контрагент AS Контрагент,
//	|			CustomerSalesTurnovers.Договор AS Договор,
//	|			CustomerSalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|			CustomerSalesTurnovers.Клиент AS Клиент,
//	|			CustomerSalesTurnovers.Тариф AS Тариф,
//	|			CustomerSalesTurnovers.УчетнаяДата AS УчетнаяДата,
//	|			CustomerSalesTurnovers.ДокОснование AS ДокОснование,
//	|			CustomerSalesTurnovers.Услуга AS Услуга,
//	|			CustomerSalesTurnovers.СпособОплаты AS СпособОплаты,
//	|			CustomerSalesTurnovers.RoomsRentedTurnover AS ПроданоНомеров,
//	|			CustomerSalesTurnovers.RoomsRentedTurnover AS RoomsRentedAccommodation,
//	|			0 AS RoomsRentedReservation,
//	|			CustomerSalesTurnovers.BedsRentedTurnover AS ПроданоМест,
//	|			CustomerSalesTurnovers.BedsRentedTurnover AS BedsRentedAccommodation,
//	|			0 AS BedsRentedReservation,
//	|			CustomerSalesTurnovers.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|			CustomerSalesTurnovers.AdditionalBedsRentedTurnover AS AdditionalBedsRentedAccommodation,
//	|			0 AS AdditionalBedsRentedReservation,
//	|			CustomerSalesTurnovers.GuestDaysTurnover AS ЧеловекаДни,
//	|			CustomerSalesTurnovers.GuestDaysTurnover AS GuestDaysAccommodation,
//	|			0 AS GuestDaysReservation,
//	|			CustomerSalesTurnovers.GuestsCheckedInTurnover AS ЗаездГостей,
//	|			CustomerSalesTurnovers.GuestsCheckedInTurnover AS GuestsCheckedInAccommodation,
//	|			0 AS GuestsCheckedInReservation,
//	|			CustomerSalesTurnovers.RoomsCheckedInTurnover AS ЗаездНомеров,
//	|			CustomerSalesTurnovers.RoomsCheckedInTurnover AS RoomsCheckedInAccommodation,
//	|			0 AS RoomsCheckedInReservation,
//	|			CustomerSalesTurnovers.BedsCheckedInTurnover AS ЗаездМест,
//	|			CustomerSalesTurnovers.BedsCheckedInTurnover AS BedsCheckedInAccommodation,
//	|			0 AS BedsCheckedInReservation,
//	|			CustomerSalesTurnovers.AdditionalBedsCheckedInTurnover AS ЗаездДополнительныхМест,
//	|			CustomerSalesTurnovers.AdditionalBedsCheckedInTurnover AS AdditionalBedsCheckedInAccommodation,
//	|			0 AS AdditionalBedsCheckedInReservation,
//	|			CustomerSalesTurnovers.QuantityTurnover AS Количество,
//	|			CustomerSalesTurnovers.QuantityTurnover AS QuantityAccommodation,
//	|			0 AS QuantityReservation,
//	|			CustomerSalesTurnovers.SalesTurnover AS Продажи,
//	|			CustomerSalesTurnovers.SalesTurnover AS SalesAccommodation,
//	|			0 AS SalesReservation,
//	|			CustomerSalesTurnovers.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|			CustomerSalesTurnovers.SalesWithoutVATTurnover AS SalesWithoutVATAccommodation,
//	|			0 AS SalesWithoutVATReservation,
//	|			CustomerSalesTurnovers.RoomRevenueTurnover AS ДоходНомеров,
//	|			CustomerSalesTurnovers.RoomRevenueTurnover AS RoomRevenueAccommodation,
//	|			0 AS RoomRevenueReservation,
//	|			CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|			CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover AS RoomRevenueWithoutVATAccommodation,
//	|			0 AS RoomRevenueWithoutVATReservation,
//	|			CustomerSalesTurnovers.ExtraBedRevenueTurnover AS ДоходДопМеста,
//	|			CustomerSalesTurnovers.ExtraBedRevenueTurnover AS ExtraBedRevenueAccommodation,
//	|			0 AS ExtraBedRevenueReservation,
//	|			CustomerSalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS ДоходДопМестаБезНДС,
//	|			CustomerSalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS ExtraBedRevenueWithoutVATAccommodation,
//	|			0 AS ExtraBedRevenueWithoutVATReservation,
//	|			CustomerSalesTurnovers.RoomRevenueTurnover - CustomerSalesTurnovers.ExtraBedRevenueTurnover AS MainBedsRevenue,
//	|			CustomerSalesTurnovers.RoomRevenueTurnover - CustomerSalesTurnovers.ExtraBedRevenueTurnover AS MainBedsRevenueAccommodation,
//	|			0 AS MainBedsRevenueReservation,
//	|			CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover - CustomerSalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS MainBedsRevenueWithoutVAT,
//	|			CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover - CustomerSalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS MainBedsRevenueWithoutVATAccommodation,
//	|			0 AS MainBedsRevenueWithoutVATReservation,
//	|			CustomerSalesTurnovers.CommissionSumTurnover AS СуммаКомиссии,
//	|			CustomerSalesTurnovers.CommissionSumTurnover AS CommissionSumAccommodation,
//	|			0 AS CommissionSumReservation,
//	|			CustomerSalesTurnovers.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|			CustomerSalesTurnovers.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATAccommodation,
//	|			0 AS CommissionSumWithoutVATReservation,
//	|			CustomerSalesTurnovers.DiscountSumTurnover AS СуммаСкидки,
//	|			CustomerSalesTurnovers.DiscountSumTurnover AS DiscountSumAccommodation,
//	|			0 AS DiscountSumReservation,
//	|			CustomerSalesTurnovers.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|			CustomerSalesTurnovers.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATAccommodation,
//	|			0 AS DiscountSumWithoutVATReservation,
//	|			CASE
//	|				WHEN CustomerSalesTurnovers.RoomsRentedTurnover = 0
//	|					THEN 0
//	|				ELSE CustomerSalesTurnovers.RoomRevenueTurnover / CustomerSalesTurnovers.RoomsRentedTurnover
//	|			END AS RoomPrice
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Period,
//	|					(Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qHotelIsEmpty)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qCustomerIsEmpty)
//	|						AND (Договор = &qContract
//	|							OR &qContractIsEmpty)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qGuestGroupIsEmpty)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qServiceIsEmpty)
//	|						AND (Услуга IN (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (ДокОснование.НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qRoomIsEmpty)
//	|						AND (ДокОснование.ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qRoomTypeIsEmpty)) AS CustomerSalesTurnovers
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			CustomerSalesForecastTurnovers.Гостиница,
//	|			CustomerSalesForecastTurnovers.Фирма,
//	|			CustomerSalesForecastTurnovers.Валюта,
//	|			CustomerSalesForecastTurnovers.Агент,
//	|			CustomerSalesForecastTurnovers.Контрагент,
//	|			CustomerSalesForecastTurnovers.Договор,
//	|			CustomerSalesForecastTurnovers.ГруппаГостей,
//	|			CustomerSalesForecastTurnovers.Клиент,
//	|			CustomerSalesForecastTurnovers.Тариф,
//	|			CustomerSalesForecastTurnovers.УчетнаяДата,
//	|			CustomerSalesForecastTurnovers.ДокОснование,
//	|			CustomerSalesForecastTurnovers.Услуга,
//	|			CustomerSalesForecastTurnovers.СпособОплаты,
//	|			CustomerSalesForecastTurnovers.RoomsRentedTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.RoomsRentedTurnover,
//	|			CustomerSalesForecastTurnovers.BedsRentedTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.BedsRentedTurnover,
//	|			CustomerSalesForecastTurnovers.AdditionalBedsRentedTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.AdditionalBedsRentedTurnover,
//	|			CustomerSalesForecastTurnovers.GuestDaysTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.GuestDaysTurnover,
//	|			CustomerSalesForecastTurnovers.GuestsCheckedInTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.GuestsCheckedInTurnover,
//	|			CustomerSalesForecastTurnovers.RoomsCheckedInTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.RoomsCheckedInTurnover,
//	|			CustomerSalesForecastTurnovers.BedsCheckedInTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.BedsCheckedInTurnover,
//	|			CustomerSalesForecastTurnovers.AdditionalBedsCheckedInTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.AdditionalBedsCheckedInTurnover,
//	|			CustomerSalesForecastTurnovers.QuantityTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.QuantityTurnover,
//	|			CustomerSalesForecastTurnovers.SalesTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.SalesTurnover,
//	|			CustomerSalesForecastTurnovers.SalesWithoutVATTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.SalesWithoutVATTurnover,
//	|			CustomerSalesForecastTurnovers.RoomRevenueTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.RoomRevenueTurnover,
//	|			CustomerSalesForecastTurnovers.RoomRevenueWithoutVATTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.RoomRevenueWithoutVATTurnover,
//	|			CustomerSalesForecastTurnovers.ExtraBedRevenueTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.ExtraBedRevenueTurnover,
//	|			CustomerSalesForecastTurnovers.ExtraBedRevenueWithoutVATTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.ExtraBedRevenueWithoutVATTurnover,
//	|			CustomerSalesForecastTurnovers.RoomRevenueTurnover - CustomerSalesForecastTurnovers.ExtraBedRevenueTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.RoomRevenueTurnover - CustomerSalesForecastTurnovers.ExtraBedRevenueTurnover,
//	|			CustomerSalesForecastTurnovers.RoomRevenueWithoutVATTurnover - CustomerSalesForecastTurnovers.ExtraBedRevenueWithoutVATTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.RoomRevenueWithoutVATTurnover - CustomerSalesForecastTurnovers.ExtraBedRevenueWithoutVATTurnover,
//	|			CustomerSalesForecastTurnovers.CommissionSumTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.CommissionSumTurnover,
//	|			CustomerSalesForecastTurnovers.CommissionSumWithoutVATTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.CommissionSumWithoutVATTurnover,
//	|			CustomerSalesForecastTurnovers.DiscountSumTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.DiscountSumTurnover,
//	|			CustomerSalesForecastTurnovers.DiscountSumWithoutVATTurnover,
//	|			0,
//	|			CustomerSalesForecastTurnovers.DiscountSumWithoutVATTurnover,
//	|			CASE
//	|				WHEN CustomerSalesForecastTurnovers.RoomsRentedTurnover = 0
//	|					THEN 0
//	|				ELSE CustomerSalesForecastTurnovers.RoomRevenueTurnover / CustomerSalesForecastTurnovers.RoomsRentedTurnover
//	|			END
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Period,
//	|					(Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qHotelIsEmpty)
//	|						AND (Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qCustomerIsEmpty)
//	|						AND (Договор = &qContract
//	|							OR &qContractIsEmpty)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qGuestGroupIsEmpty)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qServiceIsEmpty)
//	|						AND (Услуга IN (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (ДокОснование.НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qRoomIsEmpty)
//	|						AND (ДокОснование.ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qRoomTypeIsEmpty)) AS CustomerSalesForecastTurnovers) AS CustomerSalesUnion
//	|	
//	|	GROUP BY
//	|		CustomerSalesUnion.Гостиница,
//	|		CustomerSalesUnion.Фирма,
//	|		CustomerSalesUnion.Валюта,
//	|		CustomerSalesUnion.Агент,
//	|		CustomerSalesUnion.Контрагент,
//	|		CustomerSalesUnion.Договор,
//	|		CustomerSalesUnion.ГруппаГостей,
//	|		CustomerSalesUnion.Клиент,
//	|		CustomerSalesUnion.Тариф,
//	|		CustomerSalesUnion.УчетнаяДата,
//	|		CustomerSalesUnion.ДокОснование,
//	|		CustomerSalesUnion.Услуга,
//	|		CustomerSalesUnion.СпособОплаты) AS ПрогнозПродаж
//	|{WHERE
//	|	ПрогнозПродаж.Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	ПрогнозПродаж.Валюта.* AS Валюта,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.Тариф.* AS Тариф,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Клиент.* AS Клиент,
//	|	ПрогнозПродаж.Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	(HOUR(ПрогнозПродаж.УчетнаяДата)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	(BEGINOFPERIOD(ПрогнозПродаж.ДокОснование.CheckInDate, DAY)) AS CheckInDate,
//	|	(HOUR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInHour,
//	|	(DAY(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInYear,
//	|	ПрогнозПродаж.ДокОснование.RoomRateType.* AS RoomRateType,
//	|	ПрогнозПродаж.ДокОснование.НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.ДокОснование.ТипНомера.* AS ТипНомера,
//	|	ПрогнозПродаж.ДокОснование.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.ДокОснование.КвотаНомеров.* AS КвотаНомеров,
//	|	ПрогнозПродаж.ДокОснование.Скидка AS Скидка,
//	|	ПрогнозПродаж.ДокОснование.ТипСкидки.* AS ТипСкидки,
//	|	ПрогнозПродаж.ДокОснование.ДисконтКарт.* AS ДисконтКарт,
//	|	ПрогнозПродаж.ДокОснование.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ДокОснование.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.ДокОснование.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ДокОснование.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.ДокОснование.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ПрогнозПродаж.ДокОснование.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ПрогнозПродаж.ДокОснование.КомиссияАгента AS КомиссияАгента,
//	|	ПрогнозПродаж.ДокОснование.Автор.* AS Автор,
//	|	ПрогнозПродаж.ПроданоНомеров AS ПроданоНомеров,
//	|	ПрогнозПродаж.RoomsRentedAccommodation AS RoomsRentedAccommodation,
//	|	ПрогнозПродаж.RoomsRentedReservation AS RoomsRentedReservation,
//	|	ПрогнозПродаж.ПроданоМест AS ПроданоМест,
//	|	ПрогнозПродаж.BedsRentedAccommodation AS BedsRentedAccommodation,
//	|	ПрогнозПродаж.BedsRentedReservation AS BedsRentedReservation,
//	|	ПрогнозПродаж.ПроданоДопМест AS ПроданоДопМест,
//	|	ПрогнозПродаж.AdditionalBedsRentedAccommodation AS AdditionalBedsRentedAccommodation,
//	|	ПрогнозПродаж.AdditionalBedsRentedReservation AS AdditionalBedsRentedReservation,
//	|	ПрогнозПродаж.ЧеловекаДни AS ЧеловекаДни,
//	|	ПрогнозПродаж.GuestDaysAccommodation AS GuestDaysAccommodation,
//	|	ПрогнозПродаж.GuestDaysReservation AS GuestDaysReservation,
//	|	ПрогнозПродаж.ЗаездГостей AS ЗаездГостей,
//	|	ПрогнозПродаж.GuestsCheckedInAccommodation AS GuestsCheckedInAccommodation,
//	|	ПрогнозПродаж.GuestsCheckedInReservation AS GuestsCheckedInReservation,
//	|	ПрогнозПродаж.ЗаездНомеров AS ЗаездНомеров,
//	|	ПрогнозПродаж.RoomsCheckedInAccommodation AS RoomsCheckedInAccommodation,
//	|	ПрогнозПродаж.RoomsCheckedInReservation AS RoomsCheckedInReservation,
//	|	ПрогнозПродаж.ЗаездМест AS ЗаездМест,
//	|	ПрогнозПродаж.BedsCheckedInAccommodation AS BedsCheckedInAccommodation,
//	|	ПрогнозПродаж.BedsCheckedInReservation AS BedsCheckedInReservation,
//	|	ПрогнозПродаж.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	ПрогнозПродаж.AdditionalBedsCheckedInAccommodation AS AdditionalBedsCheckedInAccommodation,
//	|	ПрогнозПродаж.AdditionalBedsCheckedInReservation AS AdditionalBedsCheckedInReservation,
//	|	ПрогнозПродаж.Количество AS Количество,
//	|	ПрогнозПродаж.QuantityAccommodation AS QuantityAccommodation,
//	|	ПрогнозПродаж.QuantityReservation AS QuantityReservation,
//	|	ПрогнозПродаж.Продажи AS Продажи,
//	|	ПрогнозПродаж.SalesAccommodation AS SalesAccommodation,
//	|	ПрогнозПродаж.SalesReservation AS SalesReservation,
//	|	ПрогнозПродаж.ПродажиБезНДС AS ПродажиБезНДС,
//	|	ПрогнозПродаж.SalesWithoutVATAccommodation AS SalesWithoutVATAccommodation,
//	|	ПрогнозПродаж.SalesWithoutVATReservation AS SalesWithoutVATReservation,
//	|	ПрогнозПродаж.ДоходНомеров AS ДоходНомеров,
//	|	ПрогнозПродаж.RoomRevenueAccommodation AS RoomRevenueAccommodation,
//	|	ПрогнозПродаж.RoomRevenueReservation AS RoomRevenueReservation,
//	|	ПрогнозПродаж.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	ПрогнозПродаж.RoomRevenueWithoutVATAccommodation AS RoomRevenueWithoutVATAccommodation,
//	|	ПрогнозПродаж.RoomRevenueWithoutVATReservation AS RoomRevenueWithoutVATReservation,
//	|	ПрогнозПродаж.ДоходДопМеста AS ДоходДопМеста,
//	|	ПрогнозПродаж.ExtraBedRevenueAccommodation AS ExtraBedRevenueAccommodation,
//	|	ПрогнозПродаж.ExtraBedRevenueReservation AS ExtraBedRevenueReservation,
//	|	ПрогнозПродаж.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	ПрогнозПродаж.ExtraBedRevenueWithoutVATAccommodation AS ExtraBedRevenueWithoutVATAccommodation,
//	|	ПрогнозПродаж.ExtraBedRevenueWithoutVATReservation AS ExtraBedRevenueWithoutVATReservation,
//	|	ПрогнозПродаж.MainBedsRevenue AS MainBedsRevenue,
//	|	ПрогнозПродаж.MainBedsRevenueAccommodation AS MainBedsRevenueAccommodation,
//	|	ПрогнозПродаж.MainBedsRevenueReservation AS MainBedsRevenueReservation,
//	|	ПрогнозПродаж.MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	ПрогнозПродаж.MainBedsRevenueWithoutVATAccommodation AS MainBedsRevenueWithoutVATAccommodation,
//	|	ПрогнозПродаж.MainBedsRevenueWithoutVATReservation AS MainBedsRevenueWithoutVATReservation,
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
//	|	ПрогнозПродаж.RoomPrice AS RoomPrice}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	Валюта,
//	|	Контрагент,
//	|	Договор
//	|{ORDER BY
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	ПрогнозПродаж.Тариф.* AS Тариф,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Клиент.* AS Клиент,
//	|	ПрогнозПродаж.Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	(HOUR(ПрогнозПродаж.УчетнаяДата)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	(BEGINOFPERIOD(ПрогнозПродаж.ДокОснование.CheckInDate, DAY)) AS CheckInDate,
//	|	(HOUR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInHour,
//	|	(DAY(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInYear,
//	|	ПрогнозПродаж.ДокОснование.RoomRateType.* AS RoomRateType,
//	|	ПрогнозПродаж.ДокОснование.НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.ДокОснование.ТипНомера.* AS ТипНомера,
//	|	ПрогнозПродаж.ДокОснование.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.ДокОснование.КвотаНомеров.* AS КвотаНомеров,
//	|	ПрогнозПродаж.ДокОснование.Скидка AS Скидка,
//	|	ПрогнозПродаж.ДокОснование.ТипСкидки.* AS ТипСкидки,
//	|	ПрогнозПродаж.ДокОснование.ДисконтКарт.* AS ДисконтКарт,
//	|	ПрогнозПродаж.ДокОснование.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ДокОснование.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.ДокОснование.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ДокОснование.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.ДокОснование.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ПрогнозПродаж.ДокОснование.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ПрогнозПродаж.ДокОснование.КомиссияАгента AS КомиссияАгента,
//	|	ПрогнозПродаж.ДокОснование.Автор.* AS Автор,
//	|	ПроданоНомеров AS ПроданоНомеров,
//	|	RoomsRentedAccommodation AS RoomsRentedAccommodation,
//	|	RoomsRentedReservation AS RoomsRentedReservation,
//	|	ПроданоМест AS ПроданоМест,
//	|	BedsRentedAccommodation AS BedsRentedAccommodation,
//	|	BedsRentedReservation AS BedsRentedReservation,
//	|	ПроданоДопМест AS ПроданоДопМест,
//	|	AdditionalBedsRentedAccommodation AS AdditionalBedsRentedAccommodation,
//	|	AdditionalBedsRentedReservation AS AdditionalBedsRentedReservation,
//	|	ЧеловекаДни AS ЧеловекаДни,
//	|	GuestDaysAccommodation AS GuestDaysAccommodation,
//	|	GuestDaysReservation AS GuestDaysReservation,
//	|	ЗаездГостей AS ЗаездГостей,
//	|	GuestsCheckedInAccommodation AS GuestsCheckedInAccommodation,
//	|	GuestsCheckedInReservation AS GuestsCheckedInReservation,
//	|	ЗаездНомеров AS ЗаездНомеров,
//	|	RoomsCheckedInAccommodation AS RoomsCheckedInAccommodation,
//	|	RoomsCheckedInReservation AS RoomsCheckedInReservation,
//	|	ЗаездМест AS ЗаездМест,
//	|	BedsCheckedInAccommodation AS BedsCheckedInAccommodation,
//	|	BedsCheckedInReservation AS BedsCheckedInReservation,
//	|	ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	AdditionalBedsCheckedInAccommodation AS AdditionalBedsCheckedInAccommodation,
//	|	AdditionalBedsCheckedInReservation AS AdditionalBedsCheckedInReservation,
//	|	Количество AS Количество,
//	|	QuantityAccommodation AS QuantityAccommodation,
//	|	QuantityReservation AS QuantityReservation,
//	|	Продажи AS Продажи,
//	|	SalesAccommodation AS SalesAccommodation,
//	|	SalesReservation AS SalesReservation,
//	|	ПродажиБезНДС AS ПродажиБезНДС,
//	|	SalesWithoutVATAccommodation AS SalesWithoutVATAccommodation,
//	|	SalesWithoutVATReservation AS SalesWithoutVATReservation,
//	|	ДоходНомеров AS ДоходНомеров,
//	|	RoomRevenueAccommodation AS RoomRevenueAccommodation,
//	|	RoomRevenueReservation AS RoomRevenueReservation,
//	|	ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	RoomRevenueWithoutVATAccommodation AS RoomRevenueWithoutVATAccommodation,
//	|	RoomRevenueWithoutVATReservation AS RoomRevenueWithoutVATReservation,
//	|	ДоходДопМеста AS ДоходДопМеста,
//	|	ExtraBedRevenueAccommodation AS ExtraBedRevenueAccommodation,
//	|	ExtraBedRevenueReservation AS ExtraBedRevenueReservation,
//	|	ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	ExtraBedRevenueWithoutVATAccommodation AS ExtraBedRevenueWithoutVATAccommodation,
//	|	ExtraBedRevenueWithoutVATReservation AS ExtraBedRevenueWithoutVATReservation,
//	|	MainBedsRevenue AS MainBedsRevenue,
//	|	MainBedsRevenueAccommodation AS MainBedsRevenueAccommodation,
//	|	MainBedsRevenueReservation AS MainBedsRevenueReservation,
//	|	MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	MainBedsRevenueWithoutVATAccommodation AS MainBedsRevenueWithoutVATAccommodation,
//	|	MainBedsRevenueWithoutVATReservation AS MainBedsRevenueWithoutVATReservation,
//	|	СуммаКомиссии AS СуммаКомиссии,
//	|	CommissionSumAccommodation AS CommissionSumAccommodation,
//	|	CommissionSumReservation AS CommissionSumReservation,
//	|	КомиссияБезНДС AS КомиссияБезНДС,
//	|	CommissionSumWithoutVATAccommodation AS CommissionSumWithoutVATAccommodation,
//	|	CommissionSumWithoutVATReservation AS CommissionSumWithoutVATReservation,
//	|	СуммаСкидки AS СуммаСкидки,
//	|	DiscountSumAccommodation AS DiscountSumAccommodation,
//	|	DiscountSumReservation AS DiscountSumReservation,
//	|	СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	DiscountSumWithoutVATAccommodation AS DiscountSumWithoutVATAccommodation,
//	|	DiscountSumWithoutVATReservation AS DiscountSumWithoutVATReservation,
//	|	RoomPrice}
//	|TOTALS
//	|	SUM(ПроданоНомеров),
//	|	SUM(RoomsRentedAccommodation),
//	|	SUM(RoomsRentedReservation),
//	|	SUM(ПроданоМест),
//	|	SUM(BedsRentedAccommodation),
//	|	SUM(BedsRentedReservation),
//	|	SUM(ПроданоДопМест),
//	|	SUM(AdditionalBedsRentedAccommodation),
//	|	SUM(AdditionalBedsRentedReservation),
//	|	SUM(ЧеловекаДни),
//	|	SUM(GuestDaysAccommodation),
//	|	SUM(GuestDaysReservation),
//	|	SUM(ЗаездГостей),
//	|	SUM(GuestsCheckedInAccommodation),
//	|	SUM(GuestsCheckedInReservation),
//	|	SUM(ЗаездНомеров),
//	|	SUM(RoomsCheckedInAccommodation),
//	|	SUM(RoomsCheckedInReservation),
//	|	SUM(ЗаездМест),
//	|	SUM(BedsCheckedInAccommodation),
//	|	SUM(BedsCheckedInReservation),
//	|	SUM(ЗаездДополнительныхМест),
//	|	SUM(AdditionalBedsCheckedInAccommodation),
//	|	SUM(AdditionalBedsCheckedInReservation),
//	|	SUM(Количество),
//	|	SUM(QuantityAccommodation),
//	|	SUM(QuantityReservation),
//	|	SUM(Продажи),
//	|	SUM(SalesAccommodation),
//	|	SUM(SalesReservation),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(SalesWithoutVATAccommodation),
//	|	SUM(SalesWithoutVATReservation),
//	|	SUM(ДоходНомеров),
//	|	SUM(RoomRevenueAccommodation),
//	|	SUM(RoomRevenueReservation),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(RoomRevenueWithoutVATAccommodation),
//	|	SUM(RoomRevenueWithoutVATReservation),
//	|	SUM(ДоходДопМеста),
//	|	SUM(ExtraBedRevenueAccommodation),
//	|	SUM(ExtraBedRevenueReservation),
//	|	SUM(ДоходДопМестаБезНДС),
//	|	SUM(ExtraBedRevenueWithoutVATAccommodation),
//	|	SUM(ExtraBedRevenueWithoutVATReservation),
//	|	SUM(MainBedsRevenue),
//	|	SUM(MainBedsRevenueAccommodation),
//	|	SUM(MainBedsRevenueReservation),
//	|	SUM(MainBedsRevenueWithoutVAT),
//	|	SUM(MainBedsRevenueWithoutVATAccommodation),
//	|	SUM(MainBedsRevenueWithoutVATReservation),
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
//	|	MAX(RoomPrice)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	Валюта,
//	|	Контрагент,
//	|	Договор
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.СпособОплаты.* AS СпособОплаты,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	ПрогнозПродаж.Тариф.* AS Тариф,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.Клиент.* AS Клиент,
//	|	ПрогнозПродаж.Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	(HOUR(ПрогнозПродаж.УчетнаяДата)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	(BEGINOFPERIOD(ПрогнозПродаж.ДокОснование.CheckInDate, DAY)) AS CheckInDate,
//	|	(HOUR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInHour,
//	|	(DAY(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ПрогнозПродаж.ДокОснование.CheckInDate)) AS CheckInYear,
//	|	RoomPrice,
//	|	ПрогнозПродаж.ДокОснование.RoomRateType.* AS RoomRateType,
//	|	ПрогнозПродаж.ДокОснование.НомерРазмещения.* AS НомерРазмещения,
//	|	ПрогнозПродаж.ДокОснование.ТипНомера.* AS ТипНомера,
//	|	ПрогнозПродаж.ДокОснование.ВидРазмещения.* AS ВидРазмещения,
//	|	ПрогнозПродаж.ДокОснование.КвотаНомеров.* AS КвотаНомеров,
//	|	ПрогнозПродаж.ДокОснование.Скидка AS Скидка,
//	|	ПрогнозПродаж.ДокОснование.ТипСкидки.* AS ТипСкидки,
//	|	ПрогнозПродаж.ДокОснование.ДисконтКарт.* AS ДисконтКарт,
//	|	ПрогнозПродаж.ДокОснование.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ДокОснование.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.ДокОснование.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ДокОснование.TripPurpose.* AS TripPurpose,
//	|	ПрогнозПродаж.ДокОснование.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ПрогнозПродаж.ДокОснование.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ПрогнозПродаж.ДокОснование.КомиссияАгента AS КомиссияАгента,
//	|	ПрогнозПродаж.ДокОснование.Автор.* AS Author}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Контрагент sales forecast';RU='Прогноз продаж по контрагентам';de='Verkaufsprognose nach Vertragspartnern'");
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
//	If pName = "ПроданоНомеров" 
//	   Or pName = "RoomsRentedAccommodation" 
//	   Or pName = "RoomsRentedReservation" 
//	   Or pName = "ПроданоМест" 
//	   Or pName = "BedsRentedAccommodation" 
//	   Or pName = "BedsRentedReservation" 
//	   Or pName = "ПроданоДопМест" 
//	   Or pName = "AdditionalBedsRentedAccommodation" 
//	   Or pName = "AdditionalBedsRentedReservation" 
//	   Or pName = "ЗаездГостей" 
//	   Or pName = "GuestsCheckedInAccommodation" 
//	   Or pName = "GuestsCheckedInReservation" 
//	   Or pName = "ЗаездНомеров" 
//	   Or pName = "RoomsCheckedInAccommodation" 
//	   Or pName = "RoomsCheckedInReservation" 
//	   Or pName = "ЗаездМест" 
//	   Or pName = "BedsCheckedInAccommodation" 
//	   Or pName = "BedsCheckedInReservation" 
//	   Or pName = "ЗаездДополнительныхМест" 
//	   Or pName = "AdditionalBedsCheckedInAccommodation" 
//	   Or pName = "AdditionalBedsCheckedInReservation" 
//	   Or pName = "Количество" 
//	   Or pName = "QuantityAccommodation" 
//	   Or pName = "QuantityReservation" 
//	   Or pName = "ЧеловекаДни" 
//	   Or pName = "GuestDaysAccommodation" 
//	   Or pName = "GuestDaysReservation" 
//	   Or pName = "Продажи" 
//	   Or pName = "SalesAccommodation" 
//	   Or pName = "SalesReservation" 
//	   Or pName = "ПродажиБезНДС" 
//	   Or pName = "SalesWithoutVATAccommodation" 
//	   Or pName = "SalesWithoutVATReservation" 
//	   Or pName = "ДоходНомеров" 
//	   Or pName = "RoomRevenueAccommodation" 
//	   Or pName = "RoomRevenueReservation" 
//	   Or pName = "ДоходПродажиБезНДС" 
//	   Or pName = "RoomRevenueWithoutVATAccommodation" 
//	   Or pName = "RoomRevenueWithoutVATReservation" 
//	   Or pName = "ДоходДопМеста" 
//	   Or pName = "ExtraBedRevenueAccommodation" 
//	   Or pName = "ExtraBedRevenueReservation" 
//	   Or pName = "ДоходДопМестаБезНДС" 
//	   Or pName = "ExtraBedRevenueWithoutVATAccommodation" 
//	   Or pName = "ExtraBedRevenueWithoutVATReservation" 
//	   Or pName = "MainBedsRevenue" 
//	   Or pName = "MainBedsRevenueAccommodation" 
//	   Or pName = "MainBedsRevenueReservation" 
//	   Or pName = "MainBedsRevenueWithoutVAT" 
//	   Or pName = "MainBedsRevenueWithoutVATAccommodation" 
//	   Or pName = "MainBedsRevenueWithoutVATReservation" 
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
//	   Or pName = "DiscountSumWithoutVATReservation" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
