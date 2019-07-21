//-----------------------------------------------------------------------------
// Description: Checks if resource could be used
// Parameters: Resource, Document, Is posted, Reservation period, Error text in
//             russian, Error text in english
// Return value: True if resource could be used and false if not
//-----------------------------------------------------------------------------
Function cmCheckResourceAvailability(pResource, pDoc, pIsPosted, 
                                     pPeriodFrom, pPeriodTo, rMsgTextRu, rMsgTextEn, rMsgTextDe) Экспорт
	// Initialize working variables
	vOK = True;
	vMsgTextRu = "";
	vMsgTextEn = "";
	//vMsgTextDe = "";
	
	// Retrieve all necessary permissions
	vHavePermissionToUseOccupiedResources = cmCheckUserPermissions("HavePermissionToUseOccupiedResources");
	
	// Build and run query to check resource reservation history
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ResourceReservationHistory.Recorder,
	|	ResourceReservationHistory.DateTimeFrom,
	|	ResourceReservationHistory.DateTimeTo,
	|	ResourceReservationHistory.ГруппаГостей
	|FROM
	|	InformationRegister.ResourceReservationHistory AS ResourceReservationHistory
	|WHERE
	|	ResourceReservationHistory.Ресурс = &qResource
	|	AND ResourceReservationHistory.DateTimeFrom < &qPeriodTo
	|	AND ResourceReservationHistory.DateTimeTo > &qPeriodFrom
	|	AND ResourceReservationHistory.Recorder <> &qResourceReservation
	|	AND ResourceReservationHistory.ResourceReservationStatus.IsActive
	|ORDER BY
	|	ResourceReservationHistory.PointInTime"; 
	vQry.SetParameter("qResource", pResource);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qResourceReservation", pDoc);
	
	vQryTab = vQry.Execute().Unload();
	For Each vQryTabRow In vQryTab Do
		vMsgTextRu = "Ресурс " + СокрЛП(pResource) + " уже забронирован на период с " + 
		             Format(vQryTabRow.DateTimeFrom, "DF='dd.MM.yyyy HH:mm'") + " по " + 
		             Format(vQryTabRow.DateTimeTo, "DF='dd.MM.yyyy HH:mm'") + " для группы " + 
		             СокрЛП(vQryTabRow.GuestGroup.Code) + 
		             ?(IsBlankString(vQryTabRow.GuestGroup.Description), "", " (" + СокрЛП(vQryTabRow.GuestGroup.Description) + ")");
		vMessage = СокрЛП(vMsgTextRu);
		If НЕ vHavePermissionToUseOccupiedResources Тогда
			vOK = False;
			rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
			rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
		Else
			If cmShowNotEnoughRoomsMessages() Тогда
				Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
			EndIf;
		EndIf;
	EndDo;
	
	// OK
	Return vOK;
EndFunction //cmCheckResourceAvailability

//-----------------------------------------------------------------------------
// Description: Calculates and returns duration for giving start of resource 
//              reservation period and end of resource reservation period
// Parameters: Date & time from, Date & time to
// Return value: Number, duration in hours
//-----------------------------------------------------------------------------
Function cmCalculateDurationInHours(pDateTimeFrom, pDateTimeTo) Экспорт
	vDuration = 0;
	If ЗначениеЗаполнено(pDateTimeFrom) And
	   ЗначениеЗаполнено(pDateTimeTo) Тогда
		vPerInSec = cm0SecondShift(pDateTimeTo) - cm0SecondShift(pDateTimeFrom);
		vDuration = Round(vPerInSec/3600, 7);
	EndIf;
	Return vDuration;
EndFunction //cmCalculateDurationInHours

//-----------------------------------------------------------------------------
// Description: Returns value table with services that should be automatically 
//              charged for the given resource
// Parameters: Гостиница, Date & time from, Date & time to, Client type, Resource type, 
//             Resource, Service package, Service packages value list
// Return value: Value table with services and prices
//-----------------------------------------------------------------------------
Function cmGetResourcePrices(pHotel, pDateTimeFrom, pDateTimeTo, pClientType, pResourceType, pResource, pServicePackage, pServicePackages = Неопределено) Экспорт
	// Run query to get resource prices from the information register
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	BEGINOFPERIOD(КалендарьДень.Period, DAY) AS УчетнаяДата,
	|	КалендарьДень.ТипДеньКалендарь AS ТипДеньКалендарь,
	|	КалендарьДень.Timetable AS Timetable,
	|	ResourcePrices.PriceTime AS PriceTime,
	|	ResourcePrices.PriceQuantity AS PriceQuantity,
	|	&qEmptyDate AS DateTimeFrom,
	|	&qEmptyDate AS DateTimeTo,
	|	ResourcePrices.Услуга AS Услуга,
	|	ResourcePrices.Цена AS Цена,
	|	ResourcePrices.Валюта AS Валюта,
	|	0 AS Количество,
	|	ResourcePrices.Услуга.ЕдИзмерения AS ЕдИзмерения,
	|	ResourcePrices.СтавкаНДС AS СтавкаНДС,
	|	ResourcePrices.MinimumQuantity AS MinimumQuantity,
	|	ResourcePrices.FreeOfChargeQuantity AS FreeOfChargeQuantity,
	|	ResourcePrices.IsResourceRevenue AS IsResourceRevenue,
	|	ResourcePrices.IsPricePerPerson AS IsPricePerPerson,
	|	ResourcePrices.IsPricePerMinute AS IsPricePerMinute
	|FROM
	|	InformationRegister.КалендарьДень AS КалендарьДень
	|		LEFT JOIN InformationRegister.ResourcePrices.SliceLast(
	|				&qDateTimeFrom,
	|				(Гостиница = &qHotel
	|					OR Гостиница = &qEmptyHotel)
	|					AND ТипКлиента = &qClientType
	|					AND (Ресурс = &qResource
	|						OR ТипРесурса = &qResourceType
	|							AND Ресурс = &qEmptyResource
	|						OR ТипРесурса = &qEmptyResourceType
	|							AND Ресурс = &qEmptyResource)) AS ResourcePrices
	|		ON (КалендарьДень.ТипДеньКалендарь = ResourcePrices.ТипДеньКалендарь
	|				OR ResourcePrices.ТипДеньКалендарь = &qEmptyCalendarDayType)
	|WHERE
	|	КалендарьДень.Calendar = &qCalendar
	|	AND КалендарьДень.Period >= BEGINOFPERIOD(&qDateTimeFrom, DAY)
	|	AND КалендарьДень.Period <= BEGINOFPERIOD(&qDateTimeTo, DAY)
	|
	|ORDER BY
	|	КалендарьДень.Period,
	|	ResourcePrices.Услуга.IsResourceRevenue DESC,
	|	ResourcePrices.Услуга.ПорядокСортировки,
	|	ResourcePrices.Услуга.Description,
	|	PriceTime,
	|	PriceQuantity";
	vQry.SetParameter("qEmptyDate", '00010101'); 
	vQry.SetParameter("qDateTimeFrom", pDateTimeFrom); 
	vQry.SetParameter("qDateTimeTo", pDateTimeTo); 
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef()); 
	vQry.SetParameter("qClientType", pClientType);
	vQry.SetParameter("qResource", pResource);
	vQry.SetParameter("qEmptyResource", Справочники.Ресурсы.EmptyRef()); 
	vQry.SetParameter("qResourceType", pResourceType);
	vQry.SetParameter("qEmptyResourceType", Справочники.ТипыРесурсов.EmptyRef()); 
	vQry.SetParameter("qEmptyCalendarDayType", Справочники.ТипДневногоКалендаря.EmptyRef()); 
	vQry.SetParameter("qCalendar", ?(ЗначениеЗаполнено(pResource), pResource.Calendar, Справочники.Календари.EmptyRef()));
	vQry.SetParameter("qEmptyQuantityCalculationRule", Справочники.ПравилаНачисленияКоличестваУслуг.EmptyRef()); 
	vPrices = vQry.Execute().Unload();
	vPrices.Columns.Add("Примечания", cmGetStringTypeDescription());
	// Process prices retrieved to fill service period and check price time and quantity
	vPrevPricesRow = Неопределено;
	vPrevPriceQuantity = 0;
	i = 0;
	While i < vPrices.Count() Do
		vPricesRow = vPrices.Get(i);
		If НЕ ЗначениеЗаполнено(vPricesRow.Услуга) Тогда
			i = i + 1;
			Continue;
		EndIf;
		// Calculate number of hours or minutes between period from and period to
		vSrvQuantity = 0;
		If ЗначениеЗаполнено(pDateTimeFrom) And ЗначениеЗаполнено(pDateTimeTo) Тогда
			If pDateTimeFrom < pDateTimeTo Тогда
				If vPricesRow.Услуга.IsPricePerMinute Тогда
					vSrvQuantity = Int(((pDateTimeTo - pDateTimeFrom) + 1)/60); // in minutes
				Else
					vSrvQuantity = Int(((pDateTimeTo - pDateTimeFrom) + 1)/3600); // in hours
				EndIf;
			EndIf;
		EndIf;
		// Check should we move to the next row
		vNumberOfDeletedRows = 0;
		// Delete service price records with price quantity greater then calculated price quantity
		If vPricesRow.PriceQuantity > vSrvQuantity Тогда
			vPrices.Delete(vPricesRow);
			Continue;
		ElsIf vPricesRow.PriceQuantity > vPrevPriceQuantity Тогда
			If vPrevPricesRow <> Неопределено Тогда
				If vPrevPricesRow.УчетнаяДата = vPricesRow.УчетнаяДата And 
				   vPrevPricesRow.Услуга = vPricesRow.Услуга Тогда
					vPrices.Delete(vPrevPricesRow);
					vPrevPricesRow = Неопределено;
					vNumberOfDeletedRows = vNumberOfDeletedRows + 1;
				EndIf;
			EndIf;
		EndIf;
		vPrevPriceQuantity = vPricesRow.PriceQuantity;
		// Fill service price period
		vPricePeriodFrom = vPricesRow.УчетнаяДата;
		If vPricesRow.PriceTime > BegOfDay(vPricesRow.PriceTime) Тогда
			vPricePeriodFrom = vPricePeriodFrom + (vPricesRow.PriceTime - BegOfDay(vPricesRow.PriceTime));
		EndIf;
		vPricesRow.DateTimeFrom = vPricePeriodFrom;
		vPricesRow.DateTimeTo = EndOfDay(vPricePeriodFrom);
		If vPricesRow.DateTimeTo > pDateTimeTo Тогда
			vPricesRow.DateTimeTo = pDateTimeTo;
		EndIf;
		// Check previous price row
		If vPrevPricesRow <> Неопределено Тогда
			If vPrevPricesRow.УчетнаяДата = vPricesRow.УчетнаяДата And 
			   vPrevPricesRow.Услуга = vPricesRow.Услуга Тогда
				If vPricesRow.DateTimeFrom <= pDateTimeFrom And
				   vPrevPricesRow.DateTimeFrom < vPricesRow.DateTimeFrom Тогда
					vPrices.Delete(vPrevPricesRow);
					vPrevPricesRow = Неопределено;
					vNumberOfDeletedRows = vNumberOfDeletedRows + 1;
				EndIf;
			EndIf;
		EndIf;
		// Check end of resource reservaion period
		If pDateTimeTo <= vPricesRow.DateTimeFrom Тогда
			vPrices.Delete(vPricesRow);
			vNumberOfDeletedRows = vNumberOfDeletedRows + 1;
		Else
			// Fill end of period for the previous price row
			If vPrevPricesRow <> Неопределено Тогда
				If vPrevPricesRow.УчетнаяДата = vPricesRow.УчетнаяДата And 
				   vPrevPricesRow.Услуга = vPricesRow.Услуга Тогда
					If vPricesRow.DateTimeFrom <= pDateTimeTo And
					   vPrevPricesRow.DateTimeFrom < vPricesRow.DateTimeFrom Тогда
						vPrevPricesRow.DateTimeTo = vPricesRow.DateTimeFrom;
					EndIf;
				EndIf;
			EndIf;
			// Check start of period for the current row
			If vPricesRow.DateTimeFrom <= pDateTimeFrom Тогда
				vPricesRow.DateTimeFrom = pDateTimeFrom;
			EndIf;
			// Delete previous prices row if it's attributes are the same as for the new one
			If vPrevPricesRow <> Неопределено Тогда
				If vPrevPricesRow.УчетнаяДата = vPricesRow.УчетнаяДата And 
				   vPrevPricesRow.Услуга = vPricesRow.Услуга Тогда
					If vPricesRow.DateTimeFrom = vPrevPricesRow.DateTimeFrom And 
					   vPricesRow.DateTimeTo = vPrevPricesRow.DateTimeTo Тогда
						vPrices.Delete(vPrevPricesRow);
						vNumberOfDeletedRows = vNumberOfDeletedRows + 1;
					EndIf;
				EndIf;
			EndIf;
			// Save previous prices row
			vPrevPricesRow = vPricesRow;
		EndIf;
		// Next row
		i = i - vNumberOfDeletedRows + 1;
	EndDo;
	// Add services from the service package
	If ЗначениеЗаполнено(pServicePackage) Or (pServicePackages <> Неопределено And pServicePackages.Count() > 0) Тогда
		vServicePackages = New СписокЗначений();
		If ЗначениеЗаполнено(pServicePackage) Тогда
			vServicePackages.Add(pServicePackage);
		EndIf;
		If pServicePackages <> Неопределено And pServicePackages.Count() > 0 Тогда
			For Each pServicePackagesRow In pServicePackages Do
				If ЗначениеЗаполнено(pServicePackagesRow.ServicePackage) Тогда
					vServicePackages.Add(pServicePackagesRow.ServicePackage);
				EndIf;
			EndDo;
		EndIf;
		For Each vServicePackagesItem In vServicePackages Do
			vServicePackage = vServicePackagesItem.Value;
			If vServicePackage.DateValidFrom <= BegOfDay(pDateTimeFrom) And 
			   (vServicePackage.DateValidTo >= BegOfDay(pDateTimeFrom) Or НЕ ЗначениеЗаполнено(vServicePackage.DateValidTo)) Тогда
				vServices = vServicePackage.GetObject().pmGetServices(pDateTimeFrom);
				vSPRows = vServices.FindRows(New Structure("ТипКлиента", pClientType));
				If vSPRows.Count() = 0 And ЗначениеЗаполнено(pClientType) Тогда
					vSPRows = vServices.FindRows(New Structure("ТипКлиента", Справочники.ТипыКлиентов.EmptyRef()));
				EndIf;
				If vSPRows.Count() > 0 Тогда
					vDays = New ValueTable();
					If ЗначениеЗаполнено(pResource) And ЗначениеЗаполнено(pResource.Calendar) Тогда
						vDays = pResource.Calendar.GetObject().pmGetDays(pDateTimeFrom, pDateTimeTo);
					EndIf;
					For Each vSPRow In vSPRows Do
						// Get accounting date
						vAccountingDate = ?(ЗначениеЗаполнено(pDateTimeFrom), BegOfDay(pDateTimeFrom), BegOfDay(CurrentDate()));
						If ЗначениеЗаполнено(vSPRow.УчетнаяДата) Тогда
							vAccountingDate = vSPRow.УчетнаяДата;
						ElsIf vSPRow.AccountingDayNumber = 9999 Тогда
							vAccountingDate = ?(ЗначениеЗаполнено(pDateTimeTo), BegOfDay(pDateTimeTo), BegOfDay(CurrentDate()));
						ElsIf vSPRow.AccountingDayNumber > 0 Тогда
							vAccountingDate = ?(ЗначениеЗаполнено(pDateTimeFrom), BegOfDay(pDateTimeFrom) + (vSPRow.AccountingDayNumber - 1)*24*3600, BegOfDay(CurrentDate()) + (vSPRow.AccountingDayNumber - 1)*24*3600);
						ElsIf ЗначениеЗаполнено(vSPRow.QuantityCalculationRule) Тогда
							vAccountingDate = ?(ЗначениеЗаполнено(pDateTimeFrom), BegOfDay(pDateTimeFrom), BegOfDay(CurrentDate()));
						EndIf;
						// Get calendar day type and timetable 
						vCalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
						vTimetable = Справочники.Расписания.EmptyRef();
						If vDays.Count() > 0 Тогда
							vDaysRow = vDays.Find(vAccountingDate, "Period");
							If vDaysRow <> Неопределено Тогда
								vCalendarDayType = vDaysRow.ТипДняКалендаря;
								vTimetable = vDaysRow.РаспорядокДня;
							EndIf;
						EndIf;
						// Check calendar day type
						If ЗначениеЗаполнено(vSPRow.ТипДняКалендаря) And vSPRow.ТипДняКалендаря <> vCalendarDayType Тогда
							Continue;
						EndIf;
						// Add prices row
						vPricesRow = vPrices.Add();
						vPricesRow.УчетнаяДата = vAccountingDate;
						vPricesRow.ТипДняКалендаря = vCalendarDayType;
						vPricesRow.РаспорядокДня = vTimetable;
						vPricesRow.PriceTime = '00010101';
						vPricesRow.PriceQuantity = 0;
						vPricesRow.DateTimeFrom = vPricesRow.УчетнаяДата;
						vPricesRow.DateTimeTo = EndOfDay(vPricesRow.УчетнаяДата);
						vPricesRow.Услуга = vSPRow.Услуга;
						vPricesRow.Цена = vSPRow.Цена;
						vPricesRow.Валюта = vSPRow.Валюта;
						vPricesRow.Количество = vSPRow.Количество;
						vRemarks = СокрЛП(vSPRow.Примечания);
						If ЗначениеЗаполнено(vSPRow.QuantityCalculationRule) Тогда
							vIsDayUse = False;
							// Calculate quantity
							vQuantity = cmCalculateServiceQuantity(vSPRow.Услуга, vSPRow.QuantityCalculationRule, 
																   vPricesRow.УчетнаяДата, pDateTimeFrom, pDateTimeTo, 
																   Неопределено, Неопределено, True, True, False, False, True, True, 
																   vSPRow.Цена, vSPRow.Валюта, vRemarks, vIsDayUse);
							// Remove prices row if quantity is equal 0
							If vQuantity = 0 Тогда
								vPrices.Delete(vPricesRow);
								Continue;
							Else
								vPricesRow.Количество = vPricesRow.Количество * vQuantity;
							EndIf;
						EndIf;
						vPricesRow.ЕдИзмерения = vSPRow.ЕдИзмерения;
						vPricesRow.СтавкаНДС = vSPRow.СтавкаНДС;
						vPricesRow.MinimumQuantity = 0;
						vPricesRow.FreeOfChargeQuantity = 0;
						vPricesRow.IsResourceRevenue = vPricesRow.Услуга.IsResourceRevenue;
						vPricesRow.IsPricePerPerson = vSPRow.IsServicePerPerson;
						vPricesRow.IsPricePerMinute = False;
						vPricesRow.Примечания = vRemarks;
					EndDo;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	Return vPrices;
EndFunction //cmGetResourcePrices

//-----------------------------------------------------------------------------
// Description: Returns value table with services that should be automatically 
//              charged for the given resource
// Parameters: Гостиница, Date & time from, Date & time to, Client type, Resource type, 
//             Resource, Service package, Service packages value list
// Return value: Value table with services and prices
//-----------------------------------------------------------------------------
Процедура cmAddResourceReservationServicesDimensionsColumns(pServicesTab) Экспорт
	pServicesTab.Columns.Add("Гостиница", cmGetCatalogTypeDescription("Гостиницы"), "Гостиница", 20);
	pServicesTab.Columns.Add("Агент", cmGetCatalogTypeDescription("Контрагенты"), "Агент", 20);
	pServicesTab.Columns.Add("Контрагент", cmGetCatalogTypeDescription("Контрагенты"), "Контрагент", 20);
	pServicesTab.Columns.Add("Договор", cmGetCatalogTypeDescription("Договора"), "Договор", 20);
	pServicesTab.Columns.Add("ГруппаГостей", cmGetCatalogTypeDescription("ГруппыГостей"), "ГруппаГостей", 20);
	pServicesTab.Columns.Add("ТипКлиента", cmGetCatalogTypeDescription("ТипыКлиентов"), "Клиент type", 20);
	pServicesTab.Columns.Add("МаретингНапрвл", cmGetCatalogTypeDescription("КодМаркетинга"), "Marketing code", 20);
	pServicesTab.Columns.Add("ИсточИнфоГостиница", cmGetCatalogTypeDescription("ИсточИнфоГостиница"), "Source of business", 20);
	pServicesTab.Columns.Add("СпособОплаты", cmGetCatalogTypeDescription("СпособОплаты"), "Платеж method", 20);
	pServicesTab.Columns.Add("ExchangeRateDate", cmGetDateTypeDescription(), "Exchange rate date", 20);
	pServicesTab.Columns.Add("КоличествоЧеловек", cmGetNumberOfPersonsTypeDescription(), "Number of persons", 10);
	pServicesTab.Columns.Add("СчетПроживания", cmGetDocumentTypeDescription("СчетПроживания"), "Charging СчетПроживания", 10);
	pServicesTab.Columns.Add("ВалютаЛицСчета", cmGetCatalogTypeDescription("Валюты"), "СчетПроживания Валюта", 10);
	pServicesTab.Columns.Add("FolioCurrencyExchangeRate", cmGetExchangeRateTypeDescription(), "СчетПроживания Валюта exchange rate", 20);
	pServicesTab.Columns.Add("Валюта", cmGetCatalogTypeDescription("Валюты"), "Reporting Валюта", 10);
	pServicesTab.Columns.Add("ReportingCurrencyExchangeRate", cmGetExchangeRateTypeDescription(), "Reporting Валюта exchange rate", 20);
	pServicesTab.Columns.Add("ДисконтКарт", cmGetCatalogTypeDescription("ДисконтныеКарты"), "Скидка card", 20);
	pServicesTab.Columns.Add("КомиссияАгента", cmGetAgentCommissionTypeDescription(), "Агент Комиссия", 10);
	pServicesTab.Columns.Add("ВидКомиссииАгента", cmGetEnumTypeDescription("AgentCommissionTypes"), "Агент Комиссия type", 10);
	pServicesTab.Columns.Add("ПутевкаКурсовка", cmGetCatalogTypeDescription("HotelProducts"), "Гостиница product", 20);
	pServicesTab.Columns.Add("ТипРесурса", cmGetCatalogTypeDescription("ТипыРесурсов"), "Ресурс type", 20);
	pServicesTab.Columns.Add("Ресурс", cmGetCatalogTypeDescription("Ресурсы"), "Ресурс type", 20);
	pServicesTab.Columns.Add("ДоходРес", cmGetNumberTypeDescription(19, 7), "Ресурс revenue", 10);
	pServicesTab.Columns.Add("ДоходРесБезНДС", cmGetNumberTypeDescription(19, 7), "Ресурс revenue without VAT", 10);
КонецПроцедуры //cmAddResourceReservationServicesDimensionsColumns

//-----------------------------------------------------------------------------
// Description: Fills sales accummulation registers dimensions columns for the 
//              services value table row
// Parameters: Services valu table row, Resource reservation object, Client 
//             Гражданство, Client region, Client city, Client age
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmFillResourceReservationServicesDimensionsColumns(pSrv, pObj) Экспорт
	pSrv.Гостиница = pObj.Гостиница;
	pSrv.Агент = pObj.Агент;
	pSrv.Контрагент = pObj.Контрагент;
	pSrv.Договор = pObj.Договор;
	pSrv.ГруппаГостей = pObj.ГруппаГостей;
	pSrv.ТипКлиента = pObj.ТипКлиента;
	pSrv.МаркетингКод = pObj.МаркетингКод;
	pSrv.ИсточникИнфоГостиница = pObj.ИсточникИнфоГостиница;
	pSrv.ТипРесурса = pObj.ТипРесурса;
	pSrv.Ресурс = pObj.Ресурс;
	pSrv.СпособОплаты = pObj.ChargingFolio.СпособОплаты;
	pSrv.ExchangeRateDate = pObj.ExchangeRateDate;
	pSrv.КоличествоЧеловек = pObj.КоличествоЧеловек;
	pSrv.ВалютаЛицСчета = pObj.ВалютаЛицСчета;
	pSrv.FolioCurrencyExchangeRate = pObj.FolioCurrencyExchangeRate;
	pSrv.Валюта = pObj.Валюта;
	pSrv.ReportingCurrencyExchangeRate = pObj.ReportingCurrencyExchangeRate;
	pSrv.ДисконтКарт = pObj.ДисконтКарт;
	pSrv.КомиссияАгента = pObj.КомиссияАгента;
	pSrv.ВидКомиссииАгента = pObj.ВидКомиссииАгента;
	If pSrv.IsResourceRevenue Тогда
		pSrv.ДоходРес = pSrv.Сумма;
		pSrv.ДоходРесБезНДС = pSrv.Сумма - pSrv.СуммаСкидки;
	EndIf;
КонецПроцедуры //cmFillResourceReservationServicesDimensionsColumns

//-----------------------------------------------------------------------------
// Description: Calculates subtraction of two value table with services. 
// Parameters: First value table with services to subtract from, Secon value
//             table with services which is subtracted
// Return value: None
//-----------------------------------------------------------------------------
Function cmGetResourceReservationServicesDifference(pTabS, pTabC) Экспорт
	// Create resulting value table
	vDiffTabS = pTabS.Copy();
	
	// Add services from second table with negative resources
	For Each vTabCRow In pTabC Do
		vTabSRow = vDiffTabS.Add();
		FillPropertyValues(vTabSRow, vTabCRow);
		vTabSRow.Количество = -vTabCRow.Количество;
		vTabSRow.Сумма = -vTabCRow.Сумма;
		vTabSRow.СтавкаНДС = vTabCRow.СтавкаНДС;
		vTabSRow.СуммаНДС = -vTabCRow.СуммаНДС;
		vTabSRow.ПроданоЧасовРесурса = -vTabCRow.ПроданоЧасовРесурса;
		vTabSRow.IsResourceRevenue = vTabCRow.IsResourceRevenue;
		vTabSRow.IsManual = vTabCRow.IsManual;
		vTabSRow.СуммаКомиссии = -vTabCRow.СуммаКомиссии;
		vTabSRow.СуммаКомиссииНДС = -vTabCRow.СуммаКомиссииНДС;
		vTabSRow.СуммаСкидки = -vTabCRow.СуммаСкидки;
		vTabSRow.НДСскидка = -vTabCRow.НДСскидка;
		vTabSRow.ДоходРес = -vTabCRow.ДоходРес;
		vTabSRow.ДоходРесБезНДС = -vTabCRow.ДоходРесБезНДС;
	EndDo;
	
	// Reset folio to empty value
	vDiffTabS.FillValues(Documents.СчетПроживания.EmptyRef(), "СчетПроживания");
	
	// Group by services
	vGroupByColumns = "Гостиница, Фирма, Агент, Контрагент, Договор, ГруппаГостей, ТипКлиента, " + 
	                  "МаретингНапрвл, ИсточИнфоГостиница, ТипРесурса, Ресурс, СпособОплаты, ServiceResource, ВремяС, ВремяПо, " + 
	                  "УчетнаяДата, ExchangeRateDate, Услуга, ТипДеньКалендарь, Timetable, " +
	                  "Цена, ЕдИзмерения, СтавкаНДС, Примечания, ВалютаЛицСчета, FolioCurrencyExchangeRate, СчетПроживания, " +
	                  "ДисконтКарт, ТипСкидки, ОснованиеСкидки, Скидка, КомиссияАгента, ВидКомиссииАгента, " +
	                  "Валюта, ReportingCurrencyExchangeRate, IsResourceRevenue, IsManual, LineNumber";
	vSumColumns = "Количество, Сумма, СуммаНДС, ПроданоЧасовРесурса, СуммаКомиссии, VATCommissionSum, СуммаСкидки, НДСскидка, ДоходРес, ДоходРесБезНДС"; 
	vDiffTabS.GroupBy(vGroupByColumns, vSumColumns);
	
	// Return result
	Return vDiffTabS;
EndFunction //cmGetResourceReservationServicesDifference

//-----------------------------------------------------------------------------
// Description: Checks if all service row resources are zero
// Parameters: Services value table row
// Return value: True if all resources are zero
//-----------------------------------------------------------------------------
Function cmResourceReservationServiceResourcesAreZero(pSrvRow) Экспорт
	If pSrvRow.Количество = 0 And
	   pSrvRow.Сумма = 0 And
	   pSrvRow.СуммаНДС = 0 And
	   pSrvRow.СуммаКомиссии = 0 And
	   pSrvRow.СуммаКомиссииНДС = 0 And
	   pSrvRow.СуммаСкидки = 0 And
	   pSrvRow.НДСскидка = 0 And
	   pSrvRow.ПроданоЧасовРесурса = 0 And
	   pSrvRow.ДоходРес = 0 And
	   pSrvRow.ДоходРесБезНДС = 0 Тогда
		Return True;
	Else
		Return False;
	EndIf;
EndFunction //cmResourceReservationServiceResourcesAreZero

//-----------------------------------------------------------------------------
// Description: Tries to find row in the given value table with 
//              columns equal to the data in the input services row
// Parameters: Services value table, Services value table row
// Return value: Services value table row if it was found, undefined otherwise
//-----------------------------------------------------------------------------
Function cmGetResourceReservationChargeRow(pTabC, pSrvRow) Экспорт
	vRows = pTabC.FindRows(New Structure("УчетнаяДата", pSrvRow.УчетнаяДата));
	For Each vRow In vRows Do
		If pSrvRow.Услуга = vRow.Услуга And
		   //pSrvRow.Agent = vRow.Agent And
		   //pSrvRow.Контрагент = vRow.Контрагент And
		   //pSrvRow.Contract = vRow.Contract And
		   //pSrvRow.GuestGroup = vRow.GuestGroup And
		   //pSrvRow.ClientType = vRow.ClientType And
		   //pSrvRow.MarketingCode = vRow.MarketingCode And
		   //pSrvRow.SourceOfBusiness = vRow.SourceOfBusiness And
		   //pSrvRow.ResourceType = vRow.ResourceType And
		   //pSrvRow.Resource = vRow.Resource And
		   //pSrvRow.PaymentMethod = vRow.PaymentMethod And
		   //pSrvRow.ExchangeRateDate = vRow.ExchangeRateDate And
		   //pSrvRow.Гостиница = vRow.Гостиница And
		   //pSrvRow.CalendarDayType = vRow.CalendarDayType And
		   //pSrvRow.Timetable = vRow.Timetable And
		   //pSrvRow.Unit = vRow.Unit And
		   //pSrvRow.FolioCurrency = vRow.FolioCurrency And
		   //pSrvRow.FolioCurrencyExchangeRate = vRow.FolioCurrencyExchangeRate And
		   //pSrvRow.DiscountCard = vRow.DiscountCard And
		   //pSrvRow.DiscountType = vRow.DiscountType And
		   //pSrvRow.DiscountConfirmationText = vRow.DiscountConfirmationText And
		   //pSrvRow.Discount = vRow.Discount And
		   //pSrvRow.AgentCommissionType = vRow.AgentCommissionType And
		   //pSrvRow.ReportingCurrency = vRow.ReportingCurrency And
		   //pSrvRow.ReportingCurrencyExchangeRate = vRow.ReportingCurrencyExchangeRate And
		   //pSrvRow.Фирма = vRow.Фирма And
		   pSrvRow.LineNumber = vRow.LineNumber And
		   pSrvRow.ServiceResource = vRow.ServiceResource And
		   pSrvRow.ВремяС = vRow.ВремяС And
		   pSrvRow.ВремяПо = vRow.ВремяПо And
		   TrimR(pSrvRow.Примечания) = TrimR(vRow.Примечания) And
		   pSrvRow.КомиссияАгента = vRow.КомиссияАгента And
		   pSrvRow.СтавкаНДС = vRow.СтавкаНДС And
		   pSrvRow.Цена = vRow.Цена And
		   pSrvRow.IsResourceRevenue = vRow.IsResourceRevenue And
		   pSrvRow.IsManual = vRow.IsManual Тогда
			Return vRow;
		EndIf;
	EndDo;
	Return Неопределено;
EndFunction //cmGetResourceReservationChargeRow

//-----------------------------------------------------------------------------
// Description: Returns value table with folio balances for the given 
//              resource reservation documents value list
// Parameters: Resource reservation documents value list, Гостиница
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetResourceReservationListBalances(pDocList, pHotel) Экспорт
	// Build and run query
	Запрос = Новый Запрос();
	Запрос.Text = 
	"SELECT
	|	FolioAccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	FolioAccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
	|	SUM(FolioAccountsBalance.SumBalance) AS FolioSumBalance,
	|	-SUM(FolioAccountsBalance.LimitBalance) AS FolioLimitBalance
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(
	|			&qBalancesPeriod,
	|				СчетПроживания.ДокОснование IN (&qDocList)) AS FolioAccountsBalance
	|
	|GROUP BY
	|	FolioAccountsBalance.ВалютаЛицСчета,
	|	FolioAccountsBalance.СчетПроживания.ДокОснование";
	Запрос.SetParameter("qBalancesPeriod", ?(ЗначениеЗаполнено(pHotel), ?(pHotel.ShowDebtsOnCurrentDate, CurrentDate(), '39991231235959'), '39991231235959'));
	Запрос.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	Запрос.SetParameter("qDocList", pDocList);
	Return Запрос.Execute().Unload();
EndFunction //cmGetResourceReservationListBalances

//-----------------------------------------------------------------------------
// Description: Returns value table with all resource reservation statuses
// Parameters: None
// Return value: Value table with resource reservation statuses 
//-----------------------------------------------------------------------------
Function cmGetAllResourceReservationStatuses() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусБрониРесурсов.Ref AS ResourceReservationStatus,
	|	СтатусБрониРесурсов.Code AS Code,
	|	СтатусБрониРесурсов.Description AS Description,
	|	СтатусБрониРесурсов.ПорядокСортировки AS ПорядокСортировки,
	|	СтатусБрониРесурсов.IsActive,
	|	СтатусБрониРесурсов.IsGuaranteed,
	|	СтатусБрониРесурсов.DoCharging,
	|	СтатусБрониРесурсов.ServicesAreDelivered
	|FROM
	|	Catalog.СтатусБрониРесурсов AS СтатусБрониРесурсов
	|WHERE
	|	NOT СтатусБрониРесурсов.DeletionMark
	|	AND NOT СтатусБрониРесурсов.IsFolder
	|	AND (СтатусБрониРесурсов.Гостиница = &qHotel
	|			OR СтатусБрониРесурсов.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ПорядокСортировки";
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.ПустаяСсылка());
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllResourceReservationStatuses

//-----------------------------------------------------------------------------
// Description: Returns services are delivered resource reservation statuses
// Parameters: Гостиница reference
// Return value: Resource reservation status reference
//-----------------------------------------------------------------------------
Function cmGetDeliveredResourceReservationStatus(pHotel) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусБрониРесурсов.Ref AS ResourceReservationStatus
	|FROM
	|	Catalog.СтатусБрониРесурсов AS СтатусБрониРесурсов
	|WHERE
	|	NOT СтатусБрониРесурсов.DeletionMark
	|	AND NOT СтатусБрониРесурсов.IsFolder
	|	AND СтатусБрониРесурсов.IsActive
	|	AND СтатусБрониРесурсов.ServicesAreDelivered
	|	AND (СтатусБрониРесурсов.Гостиница = &qHotel
	|			OR СтатусБрониРесурсов.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	СтатусБрониРесурсов.ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vElements = vQry.Execute().Unload();
	If vElements.Count() > 0 Тогда
		Return vElements.Get(0).ResourceReservationStatus;
	ElsIf ЗначениеЗаполнено(pHotel) Тогда
		Return pHotel.NewResourceReservationStatus;
	EndIf;
	Return Справочники.СтатусБрониРесурсов.EmptyRef();
EndFunction //cmGetDeliveredResourceReservationStatus 

//-----------------------------------------------------------------------------
// Description: Returns value table with all resources
// Parameters: Гостиница, Resources folder where to search resources
// Return value: Value table with resources
//-----------------------------------------------------------------------------
Function cmGetAllResources(pHotel, pResourcesFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	Ресурсы.Ref AS Ресурс
	|FROM
	|	Catalog.Ресурсы AS Ресурсы
	|WHERE
	|	(Ресурсы.Гостиница = &qHotel OR &qHotelIsEmpty) AND " + 
		?(ЗначениеЗаполнено(pResourcesFolder), "Ресурсы.Ref IN HIERARCHY(&qResourcesFolder) AND ", "") + "
	|	Ресурсы.DeletionMark = FALSE
	|ORDER BY Ресурсы.ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(pHotel));
	vQry.SetParameter("qResourcesFolder", pResourcesFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllResources

//-----------------------------------------------------------------------------
// Description: Returns value list with all resources where "is board place" flag is switched on
// Parameters: Гостиница, Resources folder where to search resources
// Return value: Value list with resources
//-----------------------------------------------------------------------------
Function cmGetBoardPlaces(pHotel, pResourcesFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	Ресурсы.Ref AS Ресурс
	|FROM
	|	Catalog.Ресурсы AS Ресурсы
	|WHERE
	|	(Ресурсы.Гостиница = &qHotel OR &qHotelIsEmpty) AND
	|	Ресурсы.IsBoardPlace AND " + 
		?(ЗначениеЗаполнено(pResourcesFolder), "Ресурсы.Ref IN HIERARCHY(&qResourcesFolder) AND ", "") + "
	|	NOT Ресурсы.DeletionMark
	|ORDER BY 
	|	Ресурсы.ПорядокСортировки, 
	|	Ресурсы.Description";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(pHotel));
	vQry.SetParameter("qResourcesFolder", pResourcesFolder);
	vBoardPlaces = vQry.Execute().Unload();
	vList = New СписокЗначений();
	For Each vBoardPlacesRow In vBoardPlaces Do
		vList.Add(vBoardPlacesRow.Resource);
	EndDo;
	Return vList;
EndFunction //cmGetBoardPlaces

//-----------------------------------------------------------------------------
// Description: Returns value table with all resources where "is board place" flag is switched on and 
//              door lock system additional authorization is set
// Parameters: Гостиница item reference, Door lock system authorisation item reference
// Return value: Value table with resources
//-----------------------------------------------------------------------------
Function cmGetBoardPlacesByDoorLockSystemAuthorization(pHotel, pDoorLockSystemAuthorization) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Ресурсы.Ref AS Питание
	|FROM
	|	Catalog.Ресурсы AS Ресурсы
	|WHERE
	|	(Ресурсы.Гостиница = &qHotel
	|			OR Ресурсы.Гостиница = &qEmptyHotel)
	|	AND Ресурсы.IsBoardPlace
	|	AND Ресурсы.DoorLockSystemAuthorization = &qDoorLockSystemAuthorization
	|	AND NOT Ресурсы.DeletionMark
	|
	|ORDER BY
	|	Ресурсы.ПорядокСортировки,
	|	Ресурсы.Description";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vQry.SetParameter("qDoorLockSystemAuthorization", pDoorLockSystemAuthorization);
	vBoardPlaces = vQry.Execute().Unload();
	Return vBoardPlaces;
EndFunction //cmGetBoardPlacesByDoorLockSystemAuthorization

//-----------------------------------------------------------------------------
// Description: Returns service used quantity for given date and time period
// Parameters: Service item reference, Date, Time from, time to
// Return value: Number
//-----------------------------------------------------------------------------
Function cmGetServiceUsedQuantity(pService, pAccountingDate, pTimeFrom, pTimeTo, pDocumentToSkip = Неопределено) Экспорт
	vQ = 0;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SUM(SalesMovements.Количество) AS Количество
	|FROM
	|	AccumulationRegister.Продажи AS SalesMovements
	|WHERE
	|	SalesMovements.Услуга = &qService
	|	AND (NOT &qDocumentIsFilled
	|			OR &qDocumentIsFilled
	|				AND SalesMovements.ДокОснование <> &qDocument)
	|	AND (NOT &qDocumentIsFilled
	|			OR &qDocumentIsFilled
	|				AND SalesMovements.Recorder <> &qDocument)
	|	AND SalesMovements.УчетнаяДата = &qDate
	|	AND (SalesMovements.ВремяС = &qEmptyDate
	|				AND SalesMovements.ВремяПо = &qEmptyDate
	|			OR &qTimeFrom = &qEmptyDate
	|				AND &qTimeTo = &qEmptyDate
	|			OR SalesMovements.ВремяС < SalesMovements.ВремяПо
	|				AND &qTimeFrom < &qTimeTo
	|				AND SalesMovements.ВремяС < &qTimeTo
	|				AND SalesMovements.ВремяПо > &qTimeFrom
	|			OR SalesMovements.ВремяС >= SalesMovements.ВремяПо
	|				AND &qTimeFrom < &qTimeTo
	|				AND &qTimeTo > SalesMovements.ВремяС
	|			OR SalesMovements.ВремяС < SalesMovements.ВремяПо
	|				AND &qTimeFrom >= &qTimeTo
	|				AND SalesMovements.ВремяПо > &qTimeFrom
	|			OR SalesMovements.ВремяС >= SalesMovements.ВремяПо
	|				AND &qTimeFrom >= &qTimeTo
	|				AND &qTimeTo > SalesMovements.ВремяС
	|			OR SalesMovements.ВремяС >= SalesMovements.ВремяПо
	|				AND &qTimeFrom >= &qTimeTo
	|				AND &qTimeFrom < SalesMovements.ВремяПо)
	|
	|UNION ALL
	|
	|SELECT
	|	SUM(SalesForecastMovements.Количество)
	|FROM
	|	AccumulationRegister.ПрогнозПродаж AS SalesForecastMovements
	|WHERE
	|	SalesForecastMovements.Услуга = &qService
	|	AND (NOT &qDocumentIsFilled
	|			OR &qDocumentIsFilled
	|				AND SalesForecastMovements.Recorder <> &qDocument)
	|	AND SalesForecastMovements.УчетнаяДата = &qDate
	|	AND (SalesForecastMovements.ВремяС = &qEmptyDate
	|				AND SalesForecastMovements.ВремяПо = &qEmptyDate
	|			OR &qTimeFrom = &qEmptyDate
	|				AND &qTimeTo = &qEmptyDate
	|			OR SalesForecastMovements.ВремяС < SalesForecastMovements.ВремяПо
	|				AND &qTimeFrom < &qTimeTo
	|				AND SalesForecastMovements.ВремяС < &qTimeTo
	|				AND SalesForecastMovements.ВремяПо > &qTimeFrom
	|			OR SalesForecastMovements.ВремяС >= SalesForecastMovements.ВремяПо
	|				AND &qTimeFrom < &qTimeTo
	|				AND &qTimeTo > SalesForecastMovements.ВремяС
	|			OR SalesForecastMovements.ВремяС < SalesForecastMovements.ВремяПо
	|				AND &qTimeFrom >= &qTimeTo
	|				AND SalesForecastMovements.ВремяПо > &qTimeFrom
	|			OR SalesForecastMovements.ВремяС >= SalesForecastMovements.ВремяПо
	|				AND &qTimeFrom >= &qTimeTo
	|				AND &qTimeTo > SalesForecastMovements.ВремяС
	|			OR SalesForecastMovements.ВремяС >= SalesForecastMovements.ВремяПо
	|				AND &qTimeFrom >= &qTimeTo
	|				AND &qTimeFrom < SalesForecastMovements.ВремяПо)";
	vQry.SetParameter("qService", pService);
	vQry.SetParameter("qDate", pAccountingDate);
	vQry.SetParameter("qTimeFrom", pTimeFrom);
	vQry.SetParameter("qTimeTo", pTimeTo);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qDocument", pDocumentToSkip);
	vQry.SetParameter("qDocumentIsFilled", ЗначениеЗаполнено(pDocumentToSkip));
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		If vQryResRow.Quantity <> Null Тогда
			vQ = vQ + vQryResRow.Quantity;
		EndIf;
	EndDo;
	Return vQ;
EndFunction //cmGetServiceUsedQuantity
