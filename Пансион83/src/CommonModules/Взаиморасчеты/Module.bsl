//-----------------------------------------------------------------------------
// Описание: расчет суммы НДС
// Параметры: ставка НДС, сумма с учетом НДС
// Возврат стоимость: сумма НДС
//-----------------------------------------------------------------------------
Функция cmCalculateVATSum(pVATRate, pSum) Экспорт
	vVATSum = 0;
	Если ЗначениеЗаполнено(pVATRate) Тогда
		vTaxRate = pVATRate.Ставка;
		vVATSum = Round(pSum*vTaxRate/(100+vTaxRate), 2);
	КонецЕсли;
	Возврат vVATSum;
КонецФункции //cmCalculateVATSum

//-----------------------------------------------------------------------------
// Описание: пересчитывает сумму и сумму НДС на основе значений цены и количества
// Параметры: цена, количество, сумма к возврату, ставка НДС, сумма НДС к возврату
// Значение Возврат: нет
//-----------------------------------------------------------------------------
Процедура cmPriceOnChange(pPrice, pQuantity, pSum, pVATRate, pVATSum) Экспорт
	pSum = Round(pPrice * pQuantity, 2);
	pVATSum = cmCalculateVATSum(pVATRate, pSum);
КонецПроцедуры //cmQuantityOnChange

//-----------------------------------------------------------------------------
// Описание: пересчитывает сумму и сумму НДС на основе нового количества
// Параметры: цена, количество, сумма к возврату, ставка НДС, сумма НДС к возврату
// Значение Возврат: нет
//-----------------------------------------------------------------------------
Процедура cmQuantityOnChange(pPrice, pQuantity, pSum, pVATRate, pVATSum) Экспорт
	pSum = Round(pPrice * pQuantity, 2);
	pVATSum = cmCalculateVATSum(pVATRate, pSum);
КонецПроцедуры //cmQuantityOnChange

//-----------------------------------------------------------------------------
// Description: Recalculates price, quantity and VAT amount based on new amount
// Parameters: Service, Price, Quantity, Amount, VAT rate, VAT amount, Flag that indicates wether price or quantity should be recalculated
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSumOnChange(pService, pPrice, pQuantity, pSum, pVATRate, pVATSum, pRecalculatePrice = Ложь) Экспорт
	Если pRecalculatePrice = Неопределено Тогда
		pRecalculatePrice = Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pService) Тогда
		Если pPrice = 0 Тогда
			pPrice = PSum;
		КонецЕсли;
		pQuantity = Round(pSum / pPrice, 7);
	Иначе
		Если pQuantity = 0 Тогда
			pQuantity = 1;
		КонецЕсли;
		Если pService.RecalculatePriceWhenSumChanged или pRecalculatePrice Тогда
			pPrice = Round(pSum / pQuantity, 2);
		Иначе
			Если pPrice = 0 Тогда
				pPrice = Round(pSum / pQuantity, 2);
			Иначе
				pQuantity = Round(pSum / pPrice, 7);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	pVATSum = cmCalculateVATSum(pVATRate, pSum);
КонецПроцедуры //cmQuantityOnChange

//-----------------------------------------------------------------------------
// Description: Recalculate service ГруппаНомеров sales parameters like number of rooms and beds rented and so on
// Parameters: Service row, Accommodation or reservation object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmRecalculateServiceRoomSalesParameters(pSrvRow, pDocObj) Экспорт
	Если pSrvRow.IsRoomRevenue И Не pSrvRow.ЭтоРазделение Тогда
		vCurPeriodInHours = 24;
		Если ЗначениеЗаполнено(pSrvRow.Услуга) И ЗначениеЗаполнено(pSrvRow.Услуга.QuantityCalculationRule) Тогда
			Если pSrvRow.Услуга.QuantityCalculationRule.PeriodInHours <> 0 Тогда
				vCurPeriodInHours = pSrvRow.Услуга.QuantityCalculationRule.PeriodInHours;
			КонецЕсли;
		ИначеЕсли ЗначениеЗаполнено(pSrvRow.Тариф) И pSrvRow.Тариф.PeriodInHours <> 0 Тогда
			vCurPeriodInHours = pSrvRow.Тариф.PeriodInHours;
		КонецЕсли;
		Если vCurPeriodInHours <> 0 Тогда
			vRoomType = pSrvRow.ТипНомера;
			vRoom = pSrvRow.НомерРазмещения;
			vAccommodationType = pSrvRow.ВидРазмещения;
			//vNumberOfPersonsPerRoom = pDocObj.КоличествоГостейНомер;
			vNumberOfBedsPerRoom = pDocObj.КоличествоМестНомер;
			vNumberOfPersons = pDocObj.КоличествоЧеловек;
			//vNumberOfRooms = pDocObj.КоличествоНомеров;
			vNumberOfBeds = pDocObj.КоличествоМест;
			vNumberOfAdditionalBeds = pDocObj.КолДопМест;
			vIsVirtual = Ложь;
			Если vRoomType <> pDocObj.ТипНомера Тогда
				Если ЗначениеЗаполнено(vRoom) Тогда
					vRoomAttrs = vRoom.GetObject().pmGetRoomAttributes(cm1SecondShift(pSrvRow.УчетнаяДата));
					Для каждого vRoomAttrsRow из vRoomAttrs Цикл
						vNumberOfBedsPerRoom = vRoomAttrsRow.КоличествоМестНомер;
						//vNumberOfPersonsPerRoom = vRoomAttrsRow.КоличествоГостейНомер;
						vIsVirtual = vRoomAttrsRow.ВиртуальныйНомер;
						Break;
					КонецЦикла;
				ИначеЕсли ЗначениеЗаполнено(vRoomType) Тогда
					vNumberOfBedsPerRoom = vRoomType.КоличествоМестНомер;
					//vNumberOfPersonsPerRoom = vRoomType.КоличествоГостейНомер;
					vIsVirtual = vRoomType.ВиртуальныйНомер;
				КонецЕсли;
			КонецЕсли;
			Если pSrvRow.ВидРазмещения <> vAccommodationType Тогда
				// Fill accommodation type resources
				Если ЗначениеЗаполнено(vAccommodationType) И Не vIsVirtual Тогда
					Если vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения Тогда
						//vNumberOfRooms = vAccommodationType.КоличествоНомеров;
						vNumberOfBeds = ?(vAccommodationType.КоличествоНомеров = 0, 0, vNumberOfBedsPerRoom);
						vNumberOfAdditionalBeds = vAccommodationType.КолДопМест;
					ИначеЕсли vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.Beds Тогда
						//vNumberOfRooms = 0;
						vNumberOfBeds = vAccommodationType.КоличествоМест;
						vNumberOfAdditionalBeds = vAccommodationType.КолДопМест;
					ИначеЕсли vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.AdditionalBed Тогда
						//vNumberOfRooms = 0;
						vNumberOfBeds = 0;
						vNumberOfAdditionalBeds = vAccommodationType.КолДопМест;
					ИначеЕсли vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.Together Тогда
						//vNumberOfRooms = 0;
						vNumberOfBeds = 0;
						vNumberOfAdditionalBeds = vAccommodationType.КолДопМест;
					КонецЕсли;
				Иначе
					//vNumberOfRooms = 0;
					vNumberOfBeds = 0;
					vNumberOfAdditionalBeds = 0;
				КонецЕсли;
			КонецЕсли;
			pSrvRow.ПроданоНомеров = ?(vNumberOfBedsPerRoom = 0, 0, Round(vNumberOfBeds/vNumberOfBedsPerRoom*pSrvRow.Количество*vCurPeriodInHours/24, 7));
			pSrvRow.ПроданоМест = Round(vNumberOfBeds*pSrvRow.Количество*vCurPeriodInHours/24, 7);
			pSrvRow.ПроданоДопМест = Round(vNumberOfAdditionalBeds*pSrvRow.Количество*vCurPeriodInHours/24, 7);
			pSrvRow.ЧеловекаДни = Round(vNumberOfPersons*pSrvRow.Количество*vCurPeriodInHours/24, 7);
			Если TypeOf(pDocObj) = Type("DocumentObject.Бронирование") Тогда
				Если pDocObj.RoomQuantity > 1 Тогда
					pSrvRow.ПроданоНомеров = Round(pSrvRow.ПроданоНомеров/pDocObj.RoomQuantity, 7);
					pSrvRow.ПроданоМест = Round(pSrvRow.ПроданоМест/pDocObj.RoomQuantity, 7);
					pSrvRow.ПроданоДопМест = Round(pSrvRow.ПроданоДопМест/pDocObj.RoomQuantity, 7);
					pSrvRow.ЧеловекаДни = Round(pSrvRow.ЧеловекаДни/pDocObj.RoomQuantity, 7);
				КонецЕсли;
			КонецЕсли;
			Если pSrvRow.ЗаездГостей <> 0 Тогда
				pSrvRow.ЗаездГостей = pDocObj.КоличествоЧеловек;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmRecalculateServiceRoomSalesParameters

//-----------------------------------------------------------------------------
// Description: Returns currency exchange rate
// Parameters: Гостиница, Currency, Date to get rate on
// Возврат value: Currency exchange rate
//-----------------------------------------------------------------------------
Функция cmGetCurrencyExchangeRate(pHotel, pCurrency, pDate) Экспорт
	vRate = 0;
	
	// Common checks	
	Если Не ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение("ru= ERR: Ошибка вызова функции cmGetCurrencyExchangeRate.
				|CAUSE: В функцию передано пустое значение параметра pHotel.
				|DESC: Обязательный параметр pHotel должен быть явно указан.");
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pCurrency) Тогда
		ВызватьИсключение(" ERR: Ошибка вызова функции cmGetCurrencyExchangeRate.
				       |CAUSE: В функцию передано пустое значение параметра pCurrency.
					   |DESC: Обязательный параметр pCurrency должен быть явно указан.");
	КонецЕсли;
	
	// Check if currency is base currency
	Если pHotel.BaseCurrency = pCurrency Тогда
		Возврат 1;
	КонецЕсли;
	
	// Fill parameter default values 
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	КонецЕсли;
	
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT 
	|	* 
	|FROM
	|	РегистрСведений.КурсВалют.SliceLast(
	|	&qDate, 
	|	Гостиница = &qHotel AND Валюта = &qCurrency) AS КурсВалют";
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qCurrency", pCurrency);
	vExRt = vQry.Execute().Unload();
	
	// Get exchange rate
	Для каждого vExRtRow из VExRt Цикл
		vRate = vExRtRow.Rate/vExRtRow.Factor;
		Break;
	КонецЦикла;
	
	Возврат vRate;
КонецФункции //cmGetCurrencyExchangeRate

//-----------------------------------------------------------------------------
// Description: Returns currency exchange rates value table
// Parameters: Гостиница, Currency, Date to get rate on
// Возврат value: Currency exchange rates value table
//-----------------------------------------------------------------------------
Функция cmGetCurrencyExchangeRates(pHotel, pCurrency, pDate) Экспорт
	// Fill parameter default values 
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	КонецЕсли;
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT 
	|	* 
	|FROM
	|	РегистрСведений.КурсВалют.SliceLast(
	|	&qDate, TRUE" + 
		?(ValueISFilled(pHotel), " AND Гостиница IN HIERARCHY (&qHotel)", "") + 
		?(ЗначениеЗаполнено(pCurrency), " AND Валюта = &qCurrency", "") + "
	|	) AS КурсВалют";
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qCurrency", pCurrency);
	vList = vQry.Execute().Unload();
	Возврат vList;
КонецФункции //cmGetCurrencyExchangeRates

//-----------------------------------------------------------------------------
// Description: Recalculates amount from one currency to another
// Parameters: Amount to be recalculated, From currency, From currency exchange rate, To currency, To currency exchange rate, Exchange rate date, Гостиница
// Возврат value: Amount in to currency
//-----------------------------------------------------------------------------
Функция cmConvertCurrencies(pSum, pFromCurrency, pFromCurrencyExchangeRate = 0, pToCurrency, pToCurrencyExchangeRate = 0, pExchangeRateDate = Неопределено, pHotel = Неопределено) Экспорт
	Если pFromCurrency = pToCurrency И pFromCurrencyExchangeRate = pToCurrencyExchangeRate Тогда
		Возврат pSum;
	КонецЕсли;
	// Get exchange rates if not specified
	Если pFromCurrencyExchangeRate = 0 Тогда
		pFromCurrencyExchangeRate = cmGetCurrencyExchangeRate(pHotel, pFromCurrency, pExchangeRateDate);
	КонецЕсли;
	Если pToCurrencyExchangeRate = 0 Тогда
		pToCurrencyExchangeRate = cmGetCurrencyExchangeRate(pHotel, pToCurrency, pExchangeRateDate);
	КонецЕсли;
	Если pToCurrencyExchangeRate = 0 Тогда
		Возврат 0;
	КонецЕсли;
	Если pFromCurrencyExchangeRate = pToCurrencyExchangeRate Тогда
		Возврат pSum;
	КонецЕсли;
	// Convert input sum
	Возврат pSum*pFromCurrencyExchangeRate/pToCurrencyExchangeRate;
КонецФункции //cmConvertCurrencies

//-----------------------------------------------------------------------------
// Description: Tries to find service in the value table of manual prices. 
//              Если found change input price and currency to manual ones.
// Parameters: Manual prices value table, Service, Price to return, 
//             Service unit of measure to return, Calendar day type
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmGetManualPrice(pMPTab, pService, rPrice, rCurrency, rUnit, pCalendarDayType) Экспорт
	vMPRow = Неопределено;
	// 1. Check services of the same calendar day type as input parameter is
	vMPRows = pMPTab.FindRows(Новый Structure("Услуга, ТипДеньКалендарь", pService, pCalendarDayType));
	Если vMPRows.Count() > 0 Тогда
		vMPRow = vMPRows.Get(0);
	Иначе
		// 2. Check services only
		vMPRows = pMPTab.FindRows(Новый Structure("Услуга, ТипДеньКалендарь", pService, Справочники.CalendarDayTypes.EmptyRef()));
		Если vMPRows.Count() > 0 Тогда
			vMPRow = vMPRows.Get(0);
		КонецЕсли;
	КонецЕсли;
	Если Не vMPRow = Неопределено Тогда
		rPrice = vMPRow.Цена;
		rCurrency = vMPRow.Валюта;
		rUnit = vMPRow.ЕдИзмерения;
	КонецЕсли;
КонецПроцедуры //cmGetManualPrice

//-----------------------------------------------------------------------------
// Description: Checks whether given service is in the service group specified or not
// Parameters: Service to check, Service group where to check 
// Возврат value: Boolean, true if service was found in the service group, false if not
//-----------------------------------------------------------------------------
Функция cmIsServiceInServiceGroup(pService, pServiceGroup) Экспорт
	Если Не ЗначениеЗаполнено(pService) Тогда
		Возврат Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pServiceGroup) Тогда
		Возврат Истина;
	КонецЕсли;
	Если pServiceGroup.IncludeAll Тогда
		Возврат Истина;
	КонецЕсли;
	vSrvTab = pServiceGroup.Услуги.Unload();
	vSrvGrpRow = vSrvTab.Find(pService, "Услуга");
	Если Не vSrvGrpRow = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	// Check service groups
	Для каждого vSrvRow из pServiceGroup.Услуги Цикл
		Если ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
			Если ЗначениеЗаполнено(vSrvRow.Услуга.IsFolder) Тогда
				Если pService.BelongsToItem(vSrvRow.Услуга) Тогда
					Возврат Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;
КонецФункции //cmIsServiceInServiceGroup

//-----------------------------------------------------------------------------
// Description: Checks wether given service fits to the given charging rule row  
// Parameters: Charging rule row, Service to check, Service date, Whether given service is in the rate or not, 
//             Whether service is ГруппаНомеров revenue or not, Фирма
// Возврат value: Boolean, true if service fits to the charging rule, false if not
//-----------------------------------------------------------------------------
Функция cmIsServiceFitToTheChargingRule(pChargingRuleRow, pService, pDate, pIsInRate = Ложь, pIsRoomRevenue = Ложь, pCompany = Неопределено) Экспорт
	vDate = pDate;
	// First check charging rule priod
	Если (vDate < pChargingRuleRow.ValidFromDate) или
	   (vDate > pChargingRuleRow.ValidToDate) И ЗначениеЗаполнено(pChargingRuleRow.ValidToDate) Тогда
		Возврат Ложь;
	КонецЕсли;
	// Check Фирма
	Если ЗначениеЗаполнено(pCompany) Тогда
		Если ЗначениеЗаполнено(pChargingRuleRow.ChargingFolio) Тогда
			Если ЗначениеЗаполнено(pChargingRuleRow.ChargingFolio.Фирма) Тогда
				Если pChargingRuleRow.ChargingFolio.Фирма <> pCompany Тогда
					Возврат Ложь;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	// Тогда check rule types	   
	Если pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.Any Тогда
		Возврат Истина;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InRate Тогда
		Если pIsInRate Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.NotInRate Тогда
		Если Не pIsInRate Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.AllButOne Тогда
		Если pChargingRuleRow.ПравилаНачисления <> pService Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.One Тогда
		Если pChargingRuleRow.ПравилаНачисления = pService Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InServiceGroup Тогда
		Если cmIsServiceInServiceGroup(pService, pChargingRuleRow.ПравилаНачисления) Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.NotInServiceGroup Тогда
		Если Не cmIsServiceInServiceGroup(pService, pChargingRuleRow.ПравилаНачисления) Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePrice Тогда
		Если pIsRoomRevenue Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePricePercent Тогда
		Если pIsRoomRevenue Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenueAmount Тогда
		Если pIsInRate Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePriceByRoomType Тогда
		Если pIsRoomRevenue Тогда
			Возврат Истина;
		КонецЕсли;
	ИначеЕсли pChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RestOfRoomRevenuePrice Тогда
		Если pIsRoomRevenue Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	Возврат Ложь;
КонецФункции //cmIsServiceFitToTheChargingRule

//-----------------------------------------------------------------------------
// Description: Returns value table of charges for the accommodation or reservation specified
// Parameters: Reference to the accommodation or reservation document
// Возврат value: Value table with charges
//-----------------------------------------------------------------------------
Функция cmGetTableOfAlreadyChargedServices(pDoc) Экспорт
	// Common checks	
	Если Не ЗначениеЗаполнено(pDoc) Тогда
		ВызватьИсключение("ERR: Ошибка вызова функции cmGetTableOfAlreadyChargedServices.
				       |CAUSE: В функцию передано пустое значение параметра pDoc.
					   |DESC: Обязательный параметр pDoc должен быть явно указан." );
	КонецЕсли;
	
	// Build and run query
	qCharges = Новый Query;
	qCharges.Text = 
	"SELECT
	|	SalesMovement.Агент,
	|	SalesMovement.Контрагент,
	|	SalesMovement.Договор,
	|	SalesMovement.ГруппаГостей,
	|	SalesMovement.СпособОплаты,
	|	SalesMovement.УчетнаяДата,
	|	SalesMovement.Клиент,
	|	SalesMovement.Клиент.Гражданство AS ClientCitizenship,
	|	SalesMovement.Клиент.Region AS ClientRegion,
	|	SalesMovement.Клиент.City AS ClientCity,
	|	SalesMovement.Клиент.Age AS ClientAge,
	|	SalesMovement.МаретингНапрвл,
	|	SalesMovement.ИсточИнфоГостиница,
	|	SalesMovement.TripPurpose,
	|	SalesMovement.НомерРазмещения,
	|	SalesMovement.ТипНомера,
	|	SalesMovement.ВидРазмещения,
	|	SalesMovement.Тариф,
	|	SalesMovement.Ресурс,
	|	SalesMovement.Ресурс AS ServiceResource,
	|	SalesMovement.ТипРесурса,
	|	SalesMovement.ВремяС,
	|	SalesMovement.ВремяПо,
	|	SalesMovement.ДоходРес,
	|	SalesMovement.ДоходРесБезНДС,
	|	SalesMovement.ПроданоЧасовРесурса,
	|	НачислениеУслуг.Ref,
	|	НачислениеУслуг.DeletionMark,
	|	НачислениеУслуг.НомерДока,
	|	НачислениеУслуг.ДатаДок,
	|	НачислениеУслуг.Posted,
	|	НачислениеУслуг.ДокОснование,
	|	НачислениеУслуг.Гостиница,
	|	НачислениеУслуг.ExchangeRateDate,
	|	НачислениеУслуг.СчетПроживания,
	|	НачислениеУслуг.ТипКлиента,
	|	НачислениеУслуг.СтрокаПодтверждения,
	|	НачислениеУслуг.Услуга,
	|	НачислениеУслуг.Цена,
	|	НачислениеУслуг.ЕдИзмерения,
	|	НачислениеУслуг.Количество,
	|	НачислениеУслуг.Сумма,
	|	НачислениеУслуг.СтавкаНДС,
	|	НачислениеУслуг.СуммаНДС,
	|	НачислениеУслуг.Примечания,
	|	НачислениеУслуг.IsRoomRevenue,
	|	НачислениеУслуг.IsInPrice,
	|	НачислениеУслуг.IsResourceRevenue,
	|	НачислениеУслуг.ТипДеньКалендарь,
	|	НачислениеУслуг.Timetable,
	|	НачислениеУслуг.ПризнакЦены,
	|	НачислениеУслуг.ВалютаЛицСчета,
	|	НачислениеУслуг.FolioCurrencyExchangeRate,
	|	НачислениеУслуг.Валюта,
	|	НачислениеУслуг.ReportingCurrencyExchangeRate,
	|	НачислениеУслуг.Фирма,
	|	НачислениеУслуг.ПроданоНомеров,
	|	НачислениеУслуг.ПроданоМест,
	|	НачислениеУслуг.ПроданоДопМест,
	|	НачислениеУслуг.ЧеловекаДни,
	|	НачислениеУслуг.ЗаездГостей,
	|	НачислениеУслуг.ДисконтКарт,
	|	НачислениеУслуг.ТипСкидки,
	|	НачислениеУслуг.ОснованиеСкидки,
	|	НачислениеУслуг.Скидка,
	|	НачислениеУслуг.DiscountServiceGroup,
	|	НачислениеУслуг.СуммаСкидки,
	|	НачислениеУслуг.НДСскидка,
	|	НачислениеУслуг.КомиссияАгента,
	|	НачислениеУслуг.ВидКомиссииАгента,
	|	НачислениеУслуг.AgentCommissionServiceGroup,
	|	НачислениеУслуг.СуммаКомиссии,
	|	НачислениеУслуг.VATCommissionSum,
	|	НачислениеУслуг.ПутевкаКурсовка,
	|	НачислениеУслуг.IsFixedCharge,
	|	НачислениеУслуг.IsAdditional,
	|	НачислениеУслуг.IsManual,
	|	НачислениеУслуг.ЭтоРазделение,
	|	НачислениеУслуг.RoomRevenueAmountsOnly,
	|	НачислениеУслуг.СуммаТарифаПрож,
	|	НачислениеУслуг.ПеремещениеНачисления,
	|	НачислениеУслуг.Автор,
	|	НачислениеУслуг.Presentation,
	|	НачислениеУслуг.PointInTime,
	|	НачислениеУслуг.LineNumber
	|FROM
	|	Document.Начисление AS НачислениеУслуг
	|		LEFT JOIN AccumulationRegister.Продажи AS SalesMovement
	|		ON НачислениеУслуг.Ref = SalesMovement.Recorder
	|WHERE
	|	(НачислениеУслуг.ДокОснование = &qDoc
	|			OR &qIsAccommodation
	|				AND НачислениеУслуг.ДокОснование = &qRes)
	|	AND NOT НачислениеУслуг.IsAdditional
	|	AND НачислениеУслуг.Posted";
	qCharges.SetParameter("qDoc", pDoc);
	Если TypeOf(pDoc) = Type("DocumentRef.Размещение") И ЗначениеЗаполнено(pDoc.Бронирование) Тогда
		qCharges.SetParameter("qRes", pDoc.Бронирование);
		qCharges.SetParameter("qIsAccommodation", Истина);
	Иначе
		qCharges.SetParameter("qRes", Неопределено);
		qCharges.SetParameter("qIsAccommodation", Ложь);
	КонецЕсли;
	vCharges = qCharges.Execute().Unload();
	Возврат vCharges;
КонецФункции //cmGetTableOfAlreadyChargedServices

//-----------------------------------------------------------------------------
// Описание: Возвращает таблицу значений изменений для размещения или бронирования, который указан
// Параметры: Ссылка на проживание или документ резервирования, поддержки загрузки фильтр, контракт фильтра загрузки,
//             Гостиница (is used to get some parameters from), Whether to return charges from the closed folios only or not, Whether to check Контрагент or not
// Возвращаемое значение: Значения таблицы загрузки
//-----------------------------------------------------------------------------
Функция cmGetDocumentCharges(pDoc, pCustomer, pContract, pHotel, pIsClosed = Неопределено, pDoNotCheckCustomer = Ложь) Экспорт
	// Common checks	
	Если Не ЗначениеЗаполнено(pDoc) Тогда
		ВызватьИсключение("ERR: Ошибка вызова функции cmGetDocumentCharges.
				       |CAUSE: В функцию передано пустое значение параметра pDoc.
					   |DESC: Обязательный параметр pDoc должен быть явно указан.");
	КонецЕсли;
	
	// Сборка и запуск запроса
	qCharges = Новый Query;
	qCharges.Text = 
	"SELECT
	|	Взаиморасчеты.СчетПроживания AS СчетПроживания,
	|	BEGINOFPERIOD(Взаиморасчеты.Period, DAY) AS УчетнаяДата,
	|	Взаиморасчеты.Услуга,
	|	Взаиморасчеты.Цена,
	|	Взаиморасчеты.Количество,
	|	Взаиморасчеты.Начисление.ЕдИзмерения AS ЕдИзмерения,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -(Взаиморасчеты.Начисление.Сумма - Взаиморасчеты.Начисление.СуммаСкидки)
	|		ELSE Взаиморасчеты.Начисление.Сумма - Взаиморасчеты.Начисление.СуммаСкидки
	|	END AS Сумма,
	|	Взаиморасчеты.СтавкаНДС,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -(Взаиморасчеты.Начисление.СуммаНДС - Взаиморасчеты.Начисление.НДСскидка)
	|		ELSE Взаиморасчеты.Начисление.СуммаНДС - Взаиморасчеты.Начисление.НДСскидка
	|	END AS СуммаНДС,
	|	Взаиморасчеты.IsRoomRevenue,
	|	Взаиморасчеты.IsInPrice,
	|	Взаиморасчеты.ТипДеньКалендарь,
	|	Взаиморасчеты.Начисление.Timetable AS Timetable,
	|	Взаиморасчеты.Начисление.ПризнакЦены AS ПризнакЦены,
	|	Взаиморасчеты.ВалютаЛицСчета,
	|	Взаиморасчеты.Начисление.FolioCurrencyExchangeRate AS FolioCurrencyExchangeRate,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.ПроданоНомеров
	|		ELSE Взаиморасчеты.Начисление.ПроданоНомеров
	|	END AS ПроданоНомеров,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.ПроданоМест
	|		ELSE Взаиморасчеты.Начисление.ПроданоМест
	|	END AS ПроданоМест,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.ПроданоДопМест
	|		ELSE Взаиморасчеты.Начисление.ПроданоДопМест
	|	END AS ПроданоДопМест,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.ЧеловекаДни
	|		ELSE Взаиморасчеты.Начисление.ЧеловекаДни
	|	END AS ЧеловекаДни,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.ЗаездГостей
	|		ELSE Взаиморасчеты.Начисление.ЗаездГостей
	|	END AS ЗаездГостей,
	|	Взаиморасчеты.Начисление.ТипСкидки AS ТипСкидки,
	|	Взаиморасчеты.Начисление.Скидка AS Скидка,
	|	Взаиморасчеты.Начисление.DiscountServiceGroup AS DiscountServiceGroup,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.СуммаСкидки
	|		ELSE Взаиморасчеты.Начисление.СуммаСкидки
	|	END AS СуммаСкидки,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.НДСскидка
	|		ELSE Взаиморасчеты.Начисление.НДСскидка
	|	END AS НДСскидка,
	|	Взаиморасчеты.Начисление.ОснованиеСкидки AS ОснованиеСкидки,
	|	Взаиморасчеты.Начисление.ВидКомиссииАгента AS ВидКомиссииАгента,
	|	Взаиморасчеты.Начисление.КомиссияАгента AS КомиссияАгента,
	|	Взаиморасчеты.Начисление.AgentCommissionServiceGroup AS AgentCommissionServiceGroup,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.СуммаКомиссии
	|		ELSE Взаиморасчеты.Начисление.СуммаКомиссии
	|	END AS СуммаКомиссии,
	|	CASE
	|		WHEN Взаиморасчеты.Recorder REFS Document.Сторно
	|			THEN -Взаиморасчеты.Начисление.VATCommissionSum
	|		ELSE Взаиморасчеты.Начисление.VATCommissionSum
	|	END AS VATCommissionSum,
	|	Взаиморасчеты.Примечания,
	|	Взаиморасчеты.Начисление.Фирма AS Фирма,
	|	Взаиморасчеты.Начисление.Тариф AS Тариф,
	|	Взаиморасчеты.Начисление.ВидРазмещения AS ВидРазмещения,
	|	Взаиморасчеты.Начисление.ТипНомера AS ТипНомера,
	|	Взаиморасчеты.Начисление.НомерРазмещения AS НомерРазмещения,
	|	Взаиморасчеты.Начисление.Ресурс AS Ресурс,
	|	Взаиморасчеты.Начисление.IsManual AS IsManual,
	|	Взаиморасчеты.Начисление.IsManual AS IsManualPrice,
	|	Взаиморасчеты.Начисление.ЭтоРазделение AS ЭтоРазделение,
	|	Взаиморасчеты.Начисление.RoomRevenueAmountsOnly AS RoomRevenueAmountsOnly,
	|	Взаиморасчеты.Начисление.СуммаТарифаПрож AS СуммаТарифаПрож,
	|	Взаиморасчеты.Recorder AS Recorder
	|FROM
	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
	|WHERE
	|	Взаиморасчеты.RecordType = &qReceipt
	|	AND Взаиморасчеты.СчетПроживания IN
	|			(SELECT
	|				Folios.Ref
	|			FROM
	|				Document.СчетПроживания AS Folios
	|			WHERE
	|				Folios.ДокОснование = &qDoc
	|				AND (Folios.Контрагент = &qCustomer
	|					OR Folios.Контрагент = &qEmptyCustomer
	|						AND &qCustomer = &qIndividualsCustomer
	|					OR Folios.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|						AND Folios.Контрагент <> &qEmptyCustomer
	|					OR &qDoNotCheckCustomer)
	|				AND (Folios.Договор = &qContract
	|					OR Folios.Договор = &qEmptyContract
	|						AND &qContract = &qIndividualsContract
	|					OR &qDoNotCheckCustomer)
	|				AND NOT Folios.DeletionMark
	|				AND (Folios.IsClosed = &qIsClosed
	|					OR &qIsClosedNotSet))";
	qCharges.SetParameter("qDoc", pDoc);
	qCharges.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	qCharges.SetParameter("qCustomer", pCustomer);
	qCharges.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	qCharges.SetParameter("qIndividualsCustomer", pHotel.IndividualsCustomer);
	qCharges.SetParameter("qContract", pContract);
	qCharges.SetParameter("qEmptyContract", Справочники.Договора.EmptyRef());
	qCharges.SetParameter("qIndividualsContract", pHotel.IndividualsContract);
	qCharges.SetParameter("qIndividualsCustomerFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
	Если pIsClosed = Неопределено Тогда
		qCharges.SetParameter("qIsClosed", Ложь);
		qCharges.SetParameter("qIsClosedNotSet", Истина);
	Иначе
		qCharges.SetParameter("qIsClosed", pIsClosed);
		qCharges.SetParameter("qIsClosedNotSet", Ложь);
	КонецЕсли;
	qCharges.SetParameter("qDoNotCheckCustomer", pDoNotCheckCustomer);
	vCharges = qCharges.Execute().Unload();
	Для каждого vChargesRow из vCharges Цикл
		vChargesRow.Price = cmRecalculatePrice(vChargesRow.Sum, vChargesRow.Quantity);
	КонецЦикла;
	Возврат vCharges;
КонецФункции 

//-----------------------------------------------------------------------------
// Description: Returns value table of charges for the record phone call or record ГруппаНомеров service document
// Parameters: Reference to the record phone call or record ГруппаНомеров service document
// Возврат value: Value table with charges
//-----------------------------------------------------------------------------
Функция cmGetRoomServiceDocumentCharges(pDoc) Экспорт
	// Common checks	
	Если Не ЗначениеЗаполнено(pDoc) Тогда
		ВызватьИсключение "ERR: Ошибка вызова функции cmGetRoomServiceDocumentCharges.
				       |CAUSE: В функцию передано пустое значение параметра pDoc.
					   |DESC: Обязательный параметр pDoc должен быть явно указан.";
	КонецЕсли;
	
	// Build and run query
	qCharges = Новый Query;
	qCharges.Text = 
	"SELECT
	|	Взаиморасчеты.Recorder AS Начисление
	|FROM
	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
	|WHERE
	|	Взаиморасчеты.RecordType = &qReceipt
	|	AND Взаиморасчеты.Recorder.ParentRoomService = &qDoc";
	qCharges.SetParameter("qDoc", pDoc);
	qCharges.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vCharges = qCharges.Execute().Unload();
	Возврат vCharges;
КонецФункции //cmGetRoomServiceDocumentCharges

//-----------------------------------------------------------------------------
// Description: Adds new dimension columns to the accommodation or reservation services value table. 
//              Dimension columns are those used in dimensions of analitical register Sales
// Parameters: Value table with document services
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmAddServicesDimensionsColumns(pServicesTab) Экспорт
	pServicesTab.Columns.Add("Гостиница", cmGetCatalogTypeDescription("Hotels"), "Гостиница", 20);
	pServicesTab.Columns.Add("Агент", cmGetCatalogTypeDescription("Контрагенты"), "Агент", 20);
	pServicesTab.Columns.Add("AgentCommissionServiceGroup", cmGetCatalogTypeDescription("НаборыУслуг"), "Агент Комиссия Услуга group", 20);
	pServicesTab.Columns.Add("Контрагент", cmGetCatalogTypeDescription("Контрагенты"), "Контрагент", 20);
	pServicesTab.Columns.Add("Договор", cmGetCatalogTypeDescription("Договора"), "Договор", 20);
	pServicesTab.Columns.Add("ГруппаГостей", cmGetCatalogTypeDescription("ГруппыГостей"), "ГруппаГостей", 20);
	pServicesTab.Columns.Add("Клиент", cmGetCatalogTypeDescription("Клиенты"), "Клиент", 20);
	pServicesTab.Columns.Add("ТипКлиента", cmGetCatalogTypeDescription("ТипыКлиентов"), "Клиент type", 20);
	pServicesTab.Columns.Add("МаретингНапрвл", cmGetCatalogTypeDescription("КодМаркетинга"), "Marketing code", 20);
	pServicesTab.Columns.Add("ИсточИнфоГостиница", cmGetCatalogTypeDescription("ИсточИнфоГостиница"), "Source of business", 20);
	pServicesTab.Columns.Add("TripPurpose", cmGetCatalogTypeDescription("TripPurposes"), "Trip purpose", 20);
	pServicesTab.Columns.Add("СпособОплаты", cmGetCatalogTypeDescription("СпособОплаты"), "Платеж method", 20);
	pServicesTab.Columns.Add("ExchangeRateDate", cmGetDateTypeDescription(), "Exchange rate date", 20);
	pServicesTab.Columns.Add("КоличествоЧеловек", cmGetNumberOfPersonsTypeDescription(), "Number of persons", 10);
	pServicesTab.Columns.Add("Валюта", cmGetCatalogTypeDescription("Валюты"), "Reporting Валюта", 10);
	pServicesTab.Columns.Add("ReportingCurrencyExchangeRate", cmGetExchangeRateTypeDescription(), "Reporting Валюта exchange rate", 20);
	pServicesTab.Columns.Add("ДисконтКарт", cmGetCatalogTypeDescription("ДисконтныеКарты"), "Скидка card", 20);
	pServicesTab.Columns.Add("ПутевкаКурсовка", cmGetCatalogTypeDescription("ПутевкиКурсовки"), "Гостиница product", 20);
КонецПроцедуры //cmAddServicesDimensionsColumns

//-----------------------------------------------------------------------------
// Description: Fill service dimension avlues from the accommodation/reservation attributes
// Parameters: Service row, Document object, Client's Гражданство, region, city and age
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillServicesDimensionsColumns(pSrv, pObj) Экспорт
	pSrv.Гостиница = pObj.Гостиница;
	pSrv.Агент = pSrv.СчетПроживания.Агент;
	pSrv.КомиссияАгентУслуги = pObj.КомиссияАгентУслуги;
	pSrv.Контрагент = pSrv.СчетПроживания.Контрагент;
	pSrv.Договор = pSrv.СчетПроживания.Договор;
	pSrv.ГруппаГостей = pSrv.СчетПроживания.ГруппаГостей;
	Если Не ЗначениеЗаполнено(pSrv.Тариф) Тогда
		pSrv.Тариф = pObj.Тариф;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pSrv.ВидРазмещения) Тогда
		pSrv.ВидРазмещения = pObj.ВидРазмещения;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pSrv.НомерРазмещения) Тогда
		pSrv.НомерРазмещения = pObj.НомерРазмещения;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pSrv.ТипНомера) Тогда
		pSrv.ТипНомера = pObj.ТипНомера;
	КонецЕсли;
	pSrv.Клиент = pObj.Клиент;
	pSrv.ТипКлиента = pObj.ТипКлиента;
	pSrv.МаркетингКод = pObj.МаркетингКод;
	pSrv.ИсточникИнфоГостиница = pObj.ИсточникИнфоГостиница;
	pSrv.TripPurpose = pObj.TripPurpose;
	pSrv.СпособОплаты = pSrv.СчетПроживания.СпособОплаты;
	pSrv.ExchangeRateDate = pSrv.УчетнаяДата;
	pSrv.КоличествоЧеловек = pObj.КоличествоЧеловек;
	pSrv.Валюта = pObj.Валюта;
	pSrv.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(pSrv.Гостиница, pSrv.ВалютаЛицСчета, pSrv.ExchangeRateDate);
	pSrv.ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(pSrv.Гостиница, pSrv.Валюта, pSrv.ExchangeRateDate);
	pSrv.ДисконтКарт = pObj.ДисконтКарт;
	Если ЗначениеЗаполнено(pSrv.Услуга) И TypeOf(pSrv.Услуга) = Type("CatalogRef.Услуги") И 
	   pSrv.Услуга.IsHotelProductService Тогда
		Если ЗначениеЗаполнено(pSrv.СчетПроживания.ПутевкаКурсовка) Тогда
			pSrv.ПутевкаКурсовка = pSrv.СчетПроживания.ПутевкаКурсовка;
		Иначе
			pSrv.ПутевкаКурсовка = pObj.ПутевкаКурсовка;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmFillServicesDimensionsColumns

//-----------------------------------------------------------------------------
// Description: Compares value tables with old and new services with each other. 
// Parameters: Новый services value table, Old services value table
// Возврат value: Returns value table with rows that are not the same in both input value tables
//-----------------------------------------------------------------------------
Функция cmGetServicesDifference(pTabS, pTabC) Экспорт
	// Create resulting value table
	vDiffTabS = pTabS.Copy();
	
	// Add services from second table with negative resources
	Для каждого vTabCRow из pTabC Цикл
		vTabSRow = vDiffTabS.Add();
		FillPropertyValues(vTabSRow, vTabCRow);
		vTabSRow.Количество = -vTabCRow.Количество;
		vTabSRow.Сумма = -vTabCRow.Сумма;
		vTabSRow.СтавкаНДС = vTabCRow.СтавкаНДС;
		vTabSRow.СуммаНДС = -vTabCRow.СуммаНДС;
		vTabSRow.ПроданоНомеров = -vTabCRow.ПроданоНомеров;
		vTabSRow.ПроданоМест = -vTabCRow.ПроданоМест;
		vTabSRow.ПроданоДопМест = -vTabCRow.ПроданоДопМест;
		vTabSRow.ЧеловекаДни = -vTabCRow.ЧеловекаДни;
		vTabSRow.ЗаездГостей = -vTabCRow.ЗаездГостей;
		vTabSRow.СуммаКомиссии = -vTabCRow.СуммаКомиссии;
		vTabSRow.СуммаКомиссииНДС = -vTabCRow.СуммаКомиссииНДС;
		vTabSRow.СуммаСкидки = -vTabCRow.СуммаСкидки;
		vTabSRow.НДСскидка = -vTabCRow.НДСскидка;
		vTabSRow.СуммаТарифаПрож = -vTabCRow.СуммаТарифаПрож;
	КонецЦикла;
	
	// Reset folio to empty value
	vDiffTabS.FillValues(Documents.СчетПроживания.EmptyRef(), "СчетПроживания");
	
	// Group by services
	vGroupByColumns = "Гостиница, Фирма, Агент, Контрагент, Договор, ГруппаГостей, Тариф, Клиент, ТипКлиента, " + 
	                  "МаретингНапрвл, ИсточИнфоГостиница, TripPurpose, ТипНомера, НомерРазмещения, ВидРазмещения, СпособОплаты, ServiceResource, ВремяС, ВремяПо, " + 
	                  "УчетнаяДата, ExchangeRateDate, Услуга, ТипДеньКалендарь, Timetable, ПризнакЦены, ПутевкаКурсовка, " +
	                  "Цена, ЕдИзмерения, СтавкаНДС, Примечания, ВалютаЛицСчета, FolioCurrencyExchangeRate, СчетПроживания, " +
	                  "ДисконтКарт, ТипСкидки, ОснованиеСкидки, Скидка, КомиссияАгента, ВидКомиссииАгента, AgentCommissionServiceGroup, " +
	                  "Валюта, ReportingCurrencyExchangeRate, IsRoomRevenue, IsInPrice, IsManual, ЭтоРазделение, RoomRevenueAmountsOnly, НомерСтроки";
	vSumColumns = "Количество, Сумма, СуммаНДС, ПроданоНомеров, ПроданоМест, ПроданоДопМест, ЧеловекаДни, ЗаездГостей, СуммаКомиссии, VATCommissionSum, СуммаСкидки, НДСскидка, СуммаТарифаПрож"; 
	vDiffTabS.GroupBy(vGroupByColumns, vSumColumns);
	
	// Возврат result
	Возврат vDiffTabS;
КонецФункции //cmGetServicesDifference

//-----------------------------------------------------------------------------
// Description: Checks if all service row resources like amount, quantity, VAT quantity, discount sum and so on are equal zero
// Parameters: Service row to check
// Возврат value: Истина if all resources are zero, Ложь if at least one of them is not
//-----------------------------------------------------------------------------
Функция cmServiceResourcesAreZero(pSrvRow) Экспорт
	Если pSrvRow.Количество = 0 И
	   pSrvRow.Сумма = 0 И
	   pSrvRow.СуммаНДС = 0 И
	   pSrvRow.СуммаКомиссии = 0 И
	   pSrvRow.СуммаКомиссииНДС = 0 И
	   pSrvRow.СуммаСкидки = 0 И
	   pSrvRow.НДСскидка = 0 И
	   pSrvRow.ПроданоНомеров = 0 И
	   pSrvRow.ПроданоМест = 0 И
	   pSrvRow.ПроданоДопМест = 0 И
	   pSrvRow.ЧеловекаДни = 0 И
	   pSrvRow.ЗаездГостей = 0 И 
	   pSrvRow.СуммаТарифаПрож = 0 Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции //cmServiceResourcesAreZero

//-----------------------------------------------------------------------------
// Description: Tries to find row in the input services value table with the same 
//              accounting parameters as other input service row has
// Parameters: Services value table where to search, Services row with accounting parameter values to search
// Возврат value: Row from the input value table if found or undefined if not
//-----------------------------------------------------------------------------
Функция cmGetChargeRow(pTabC, pSrvRow) Экспорт
	vRows = pTabC.FindRows(Новый Structure("УчетнаяДата", pSrvRow.УчетнаяДата));
	Для каждого vRow из vRows Цикл
		Если pSrvRow.Услуга = vRow.Услуга И
		   //pSrvRow.Agent = vRow.Agent И
		   //pSrvRow.Контрагент = vRow.Контрагент И
		   //pSrvRow.Contract = vRow.Contract И
		   //pSrvRow.GuestGroup = vRow.GuestGroup И
		   //pSrvRow.AccommodationType = vRow.AccommodationType И
		   //pSrvRow.RoomRate = vRow.RoomRate И
		   //pSrvRow.Client = vRow.Client И
		   //pSrvRow.ClientType = vRow.ClientType И
		   //pSrvRow.MarketingCode = vRow.MarketingCode И
		   //pSrvRow.SourceOfBusiness = vRow.SourceOfBusiness И
		   //pSrvRow.TripPurpose = vRow.TripPurpose И
		   //pSrvRow.RoomType = vRow.RoomType И
		   //pSrvRow.ГруппаНомеров = vRow.ГруппаНомеров И
		   //pSrvRow.PaymentMethod = vRow.PaymentMethod И
		   //pSrvRow.ExchangeRateDate = vRow.ExchangeRateDate И
		   //pSrvRow.Гостиница = vRow.Гостиница И
		   //pSrvRow.CalendarDayType = vRow.CalendarDayType И
		   //pSrvRow.Timetable = vRow.Timetable И
		   //pSrvRow.PriceTag = vRow.PriceTag И
		   //pSrvRow.HotelProduct = vRow.HotelProduct И
		   //pSrvRow.Unit = vRow.Unit И
		   //pSrvRow.FolioCurrency = vRow.FolioCurrency И
		   //pSrvRow.FolioCurrencyExchangeRate = vRow.FolioCurrencyExchangeRate И
		   //pSrvRow.DiscountCard = vRow.DiscountCard И
		   //pSrvRow.DiscountType = vRow.DiscountType И
		   //pSrvRow.DiscountConfirmationText = vRow.DiscountConfirmationText И
		   //pSrvRow.Discount = vRow.Discount И
		   //pSrvRow.AgentCommissionType = vRow.AgentCommissionType И
		   //pSrvRow.AgentCommissionServiceGroup = vRow.AgentCommissionServiceGroup И
		   //pSrvRow.ReportingCurrency = vRow.ReportingCurrency И
		   //pSrvRow.ReportingCurrencyExchangeRate = vRow.ReportingCurrencyExchangeRate И
		   //pSrvRow.Фирма = vRow.Фирма И
		   pSrvRow.LineNumber = vRow.LineNumber И
		   pSrvRow.ServiceResource = vRow.ServiceResource И
		   pSrvRow.ВремяС = vRow.ВремяС И
		   pSrvRow.ВремяПо = vRow.ВремяПо И
		   TrimR(pSrvRow.Примечания) = TrimR(vRow.Примечания) И
		   pSrvRow.КомиссияАгента = vRow.КомиссияАгента И
		   pSrvRow.СтавкаНДС = vRow.СтавкаНДС И
		   pSrvRow.Цена = vRow.Цена И
		   pSrvRow.IsRoomRevenue = vRow.IsRoomRevenue И
		   pSrvRow.IsInPrice = vRow.IsInPrice И
		   pSrvRow.ЭтоРазделение = vRow.ЭтоРазделение И
		   pSrvRow.IsManual = vRow.IsManual И
		   pSrvRow.RoomRevenueAmountsOnly = vRow.RoomRevenueAmountsOnly Тогда
			Возврат vRow;
		КонецЕсли;
	КонецЦикла;
	Возврат Неопределено;
КонецФункции //cmGetChargeRow

//-----------------------------------------------------------------------------
// Description: Initializes new folio object with parameters from the template folio
// Parameters: ЛицевойСчет object to be initialized, Template folio reference, Гостиница to take default values from, Date used to get default values
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillFolioFromTemplate(pFolioObj, pTemplateRef = Неопределено, Val pHotel = Неопределено, Val pDate = Неопределено) Экспорт
	Если pHotel = Неопределено Тогда
		pHotel = ПараметрыСеанса.ТекущаяГостиница;
	КонецЕсли;
	pFolioObj.pmFillAttributesWithDefaultValues();
	Если ЗначениеЗаполнено(pDate) Тогда
		pFolioObj.ДатаДок = pDate;
	Иначе
		pFolioObj.SetTime(AutoTimeMode.CurrentOrLast);
	КонецЕсли;
	Если ЗначениеЗаполнено(pHotel) Тогда
		Если pHotel <> pFolioObj.Гостиница Тогда
			pFolioObj.Гостиница = pHotel;
			pFolioObj.IsClosed = Ложь;
			pFolioObj.ВалютаЛицСчета = pHotel.ВалютаЛицСчета;
			pFolioObj.СпособОплаты = pHotel.PlannedPaymentMethod;
			pFolioObj.SetNewNumber(СокрЛП(pHotel.GetObject().pmGetPrefix()));
		КонецЕсли;
	КонецЕсли;
	Если ЗначениеЗаполнено(pTemplateRef) Тогда
		Если Не pTemplateRef.IsMaster Тогда
			pFolioObj.Description = pTemplateRef.Description;
			pFolioObj.Фирма = pTemplateRef.Фирма;
			pFolioObj.ВалютаЛицСчета = pTemplateRef.ВалютаЛицСчета;
			pFolioObj.ДокОснование = pTemplateRef.ДокОснование;
			pFolioObj.Агент = pTemplateRef.Агент;
			pFolioObj.Контрагент = pTemplateRef.Контрагент;
			pFolioObj.Договор = pTemplateRef.Договор;
			pFolioObj.Клиент = pTemplateRef.Клиент;
			pFolioObj.ГруппаГостей = pTemplateRef.ГруппаГостей;
			pFolioObj.НомерРазмещения = pTemplateRef.НомерРазмещения;
			pFolioObj.DateTimeFrom = pTemplateRef.DateTimeFrom;
			pFolioObj.DateTimeTo = pTemplateRef.DateTimeTo;
			pFolioObj.PaymentSection = pTemplateRef.PaymentSection;
			pFolioObj.СпособОплаты = pTemplateRef.СпособОплаты;
			pFolioObj.CreditLimit = pTemplateRef.CreditLimit;
			pFolioObj.DoNotUpdateCompany = pTemplateRef.DoNotUpdateCompany;
			pFolioObj.ПутевкаКурсовка = pTemplateRef.ПутевкаКурсовка;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmFillFolioFromTemplate

//-----------------------------------------------------------------------------
// Description: Returns value table with list of active folios for the given ГруппаНомеров and currency. 
//              Folios created by accommodations or reservations for the given ГруппаНомеров are skipped. 
// Parameters: Гостиница, ГруппаНомеров, ЛицевойСчет currency
// Возврат value: Value table with ГруппаНомеров folios list
//-----------------------------------------------------------------------------
Функция cmGetActiveRoomFolios(pHotel, pRoom, pFolioCurrency) Экспорт
	// Common checks	
	Если Не ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetActiveRoomFolios function.
		               |CAUSE: Empty pHotel parameter value was passed to the function.
					   |DESC: Mandatory parameter pHotel should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetActiveRoomFolios.
				       |CAUSE: В функцию передано пустое значение параметра pHotel.
					   |DESC: Обязательный параметр pHotel должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetActiveRoomFolios.
				       |CAUSE: из die Funktion wurde ein leerer Wert des Parameters pHotel übertragen. 
					   |DESC: Das Pflichtparameter pHotel muss eindeutig angegeben sein.'"));
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetActiveRoomFolios function.
		               |CAUSE: Empty pRoom parameter value was passed to the function.
					   |DESC: Mandatory parameter pRoom should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetActiveRoomFolios.
				       |CAUSE: В функцию передано пустое значение параметра pRoom.
					   |DESC: Обязательный параметр pRoom должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetActiveRoomFolios.
				       |CAUSE: из die Funktion wurde ein leerer Wert des Parameters pRoom übertragen.
					   |DESC: Das Pflichtparameter pRoom muss eindeutig angegeben sein.'"));
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pFolioCurrency) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetActiveRoomFolios function.
		               |CAUSE: Empty pFolioCurrency parameter value was passed to the function.
					   |DESC: Mandatory parameter pFolioCurrency should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetActiveRoomFolios.
				       |CAUSE: В функцию передано пустое значение параметра pFolioCurrency.
					   |DESC: Обязательный параметр pFolioCurrency должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetActiveExchangeRate.
				       |CAUSE: из die Funktion wurde ein leerer Wert des Parameters pCurrency übertragen.
					   |DESC: Das Pflichtparameter pCurrency muss eindeutig angegeben sein.'"));
	КонецЕсли;
	
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	СчетПроживания.Ref AS СчетПроживания,
	|	СчетПроживания.IsClosed,
	|	СчетПроживания.ВалютаЛицСчета,
	|	СчетПроживания.Гостиница,
	|	СчетПроживания.НомерРазмещения,
	|	СчетПроживания.PointInTime AS PointInTime
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.IsClosed = FALSE
	|	AND СчетПроживания.ВалютаЛицСчета = &qFolioCurrency
	|	AND СчетПроживания.Гостиница = &qHotel
	|	AND СчетПроживания.НомерРазмещения = &qRoom
	|	AND СчетПроживания.Контрагент = &qEmptyCustomer
	|	AND СчетПроживания.Договор = &qEmptyContract
	|	AND СчетПроживания.Клиент = &qEmptyClient
	|	AND СчетПроживания.ГруппаГостей = &qEmptyGuestGroup
	|	AND СчетПроживания.DeletionMark = FALSE
	|ORDER BY
	|	PointInTime";
	vQry.SetParameter("qFolioCurrency", pFolioCurrency);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qEmptyCustomer", Справочники.Customers.EmptyRef());
	vQry.SetParameter("qEmptyContract", Справочники.Договора.EmptyRef());
	vQry.SetParameter("qEmptyClient", Справочники.Clients.EmptyRef());
	vQry.SetParameter("qEmptyGuestGroup", Справочники.ГруппыГостей.EmptyRef());
	vQryRes = vQry.Execute().Unload();
	
	Возврат vQryRes;
КонецФункции //cmGetActiveRoomFolios

//-----------------------------------------------------------------------------
// Description: Returns value table with list of active folios for the given document. 
// Parameters: Accommodation or Reservation reference
// Возврат value: Value table with folios list
//-----------------------------------------------------------------------------
Функция cmGetActiveDocumentFolios(pDoc) Экспорт
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	СчетПроживания.Ref AS СчетПроживания
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.ДокОснование = &qDoc
	|	AND СчетПроживания.IsClosed = FALSE
	|	AND СчетПроживания.DeletionMark = FALSE
	|
	|ORDER BY
	|	СчетПроживания.PointInTime";
	vQry.SetParameter("qDoc", pDoc);
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetActiveDocumentFolios

//-----------------------------------------------------------------------------
// Description: Returns value table with list of active documents bound to the folio given 
// Parameters: ЛицевойСчет document reference
// Возврат value: Value table with active documents
//-----------------------------------------------------------------------------
Функция cmGetActiveFolioDocuments(pFolio, pDoc) Экспорт
	// Check that there is no other active documents referencing this folio
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	БроньУслуг.Ref
	|FROM
	|	Document.БроньУслуг AS БроньУслуг
	|WHERE
	|	БроньУслуг.Posted
	|	AND БроньУслуг.ChargingFolio = &qFolio
	|	AND БроньУслуг.Ref <> &qDoc
	|	AND ISNULL(БроньУслуг.ResourceReservationStatus.IsActive, FALSE)
	|	AND (NOT ISNULL(БроньУслуг.ResourceReservationStatus.ServicesAreDelivered, FALSE))
	|
	|UNION ALL
	|
	|SELECT
	|	ReservationChargingRules.Ref
	|FROM
	|	Document.Бронирование.ChargingRules AS ReservationChargingRules
	|WHERE
	|	ReservationChargingRules.Ref.Posted
	|	AND ReservationChargingRules.ChargingFolio = &qFolio
	|	AND ReservationChargingRules.Ref <> &qDoc
	|	AND NOT ReservationChargingRules.IsTransfer
	|	AND (ISNULL(ReservationChargingRules.Ref.ReservationStatus.IsActive, FALSE)
	|				AND (NOT ISNULL(ReservationChargingRules.Ref.ReservationStatus.ЭтоЗаезд, FALSE))
	|			OR ISNULL(ReservationChargingRules.Ref.ReservationStatus.IsPreliminary, FALSE))
	|
	|UNION ALL
	|
	|SELECT
	|	AccommodationChargingRules.Ref
	|FROM
	|	Document.Размещение.ChargingRules AS AccommodationChargingRules
	|WHERE
	|	AccommodationChargingRules.Ref.Posted
	|	AND AccommodationChargingRules.ChargingFolio = &qFolio
	|	AND AccommodationChargingRules.Ref <> &qDoc
	|	AND NOT AccommodationChargingRules.IsTransfer
	|	AND ISNULL(AccommodationChargingRules.Ref.СтатусРазмещения.IsActive, FALSE)
	|	AND ISNULL(AccommodationChargingRules.Ref.СтатусРазмещения.ЭтоГости, FALSE)";
	vQry.SetParameter("qFolio", pFolio);
	vQry.SetParameter("qDoc", pDoc);
	vFolioDocs = vQry.Execute().Unload();
	Возврат vFolioDocs;
КонецФункции //cmGetActiveFolioDocuments

//-----------------------------------------------------------------------------
// Description: Returns value table with list of closed folios for the given document. 
// Parameters: Accommodation or Reservation reference
// Возврат value: Value table with folios list
//-----------------------------------------------------------------------------
Функция cmGetInactiveDocumentFolios(pDoc) Экспорт
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	СчетПроживания.Ref AS СчетПроживания
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.ДокОснование = &qDoc
	|	AND СчетПроживания.IsClosed = TRUE
	|	AND СчетПроживания.DeletionMark = FALSE
	|ORDER BY
	|	СчетПроживания.PointInTime";
	vQry.SetParameter("qDoc", pDoc);
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetInactiveDocumentFolios

//-----------------------------------------------------------------------------
// Description: Returns value table with balances for accommodations or reservations. 
//              Balances are normally returned for the guest check-out dates but if hotel has 
//              "Show debts on current date" parameter turned on, then balances are calculated for the current date
// Parameters: Value list with documents to return balances for, Гостиница
// Возврат value: Возврат value table row contains Client debt value, Client credit card preauthorisation balance, Контрагент debt value
//-----------------------------------------------------------------------------
Функция cmGetDocumentListBalances(pDocList, pHotel) Экспорт
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	AccountsBalance.ВалютаЛицСчета,
	|	AccountsBalance.FolioParentDoc,
	|	SUM(AccountsBalance.ClientSumBalance) AS ClientSumBalance,
	|	SUM(AccountsBalance.ClientLimitBalance) AS ClientLimitBalance,
	|	SUM(AccountsBalance.CustomerSumBalance) AS CustomerSumBalance,
	|	SUM(AccountsBalance.ClientCreditLimit) AS ClientCreditLimit
	|FROM
	|	(SELECT
	|		ClientAccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|		ClientAccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
	|		SUM(ClientAccountsBalance.SumBalance) AS ClientSumBalance,
	|		-SUM(ClientAccountsBalance.LimitBalance) AS ClientLimitBalance,
	|		0 AS CustomerSumBalance,
	|		SUM(ClientAccountsBalance.СчетПроживания.CreditLimit) AS ClientCreditLimit
	|	FROM
	|		AccumulationRegister.Взаиморасчеты.Balance(
	|				&qBalancesPeriod,
	|				(СчетПроживания.Контрагент = &qEmptyCustomer
	|					OR СчетПроживания.Контрагент = &qIndividualsCustomer
	|					OR СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder) AND СчетПроживания.Контрагент <> &qEmptyCustomer)
	|					AND СчетПроживания.ДокОснование IN (&qDocList)) AS ClientAccountsBalance
	|	
	|	GROUP BY
	|		ClientAccountsBalance.ВалютаЛицСчета,
	|		ClientAccountsBalance.СчетПроживания.ДокОснование
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		CustomerAccountsBalance.ВалютаЛицСчета,
	|		CustomerAccountsBalance.СчетПроживания.ДокОснование,
	|		0,
	|		-SUM(CustomerAccountsBalance.LimitBalance),
	|		SUM(CustomerAccountsBalance.SumBalance), 
	|		0
	|	FROM
	|		AccumulationRegister.Взаиморасчеты.Balance(
	|				&qBalancesPeriod,
	|				СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND (NOT СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder))
	|					AND СчетПроживания.ДокОснование IN (&qDocList)) AS CustomerAccountsBalance
	|	
	|	GROUP BY
	|		CustomerAccountsBalance.ВалютаЛицСчета,
	|		CustomerAccountsBalance.СчетПроживания.ДокОснование) AS AccountsBalance
	|
	|GROUP BY
	|	AccountsBalance.ВалютаЛицСчета,
	|	AccountsBalance.FolioParentDoc";
	vQry.SetParameter("qBalancesPeriod", ?(ЗначениеЗаполнено(pHotel), ?(pHotel.ShowDebtsOnCurrentDate, CurrentDate(), '39991231235959'), '39991231235959'));
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.ПустаяСсылка());
	vQry.SetParameter("qIndividualsCustomer", ?(ЗначениеЗаполнено(pHotel), pHotel.IndividualsCustomer, Справочники.Контрагенты.ПустаяСсылка()));
	vQry.SetParameter("qIndividualsCustomerFolder", Справочники.Контрагенты.IndividualsFolder);
	vQry.SetParameter("qDocList", pDocList);
	Возврат vQry.Execute().Unload();
КонецФункции //cmGetDocumentListBalances

//-----------------------------------------------------------------------------
// Description: Returns value table with balances for clients. 
//              Balances are normally returned for end of time but if hotel has 
//              "Show debts on current date" parameter turned on, then balances are calculated for the current date
// Parameters: Value list with clients to return balances for, Гостиница
// Возврат value: Возврат value table row contains Client debt value, Client credit card preauthorisation balance
//-----------------------------------------------------------------------------
Функция cmGetClientListBalances(pClientList, pHotel) Экспорт
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	AccountsBalance.ВалютаЛицСчета,
	|	AccountsBalance.FolioClient,
	|	SUM(AccountsBalance.ClientSumBalance) AS ClientSumBalance,
	|	SUM(AccountsBalance.ClientLimitBalance) AS ClientLimitBalance,
	|	SUM(AccountsBalance.CustomerSumBalance) AS CustomerSumBalance
	|FROM
	|	(SELECT
	|		ClientAccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|		ClientAccountsBalance.СчетПроживания.Клиент AS FolioClient,
	|		SUM(ClientAccountsBalance.SumBalance) AS ClientSumBalance,
	|		-SUM(ClientAccountsBalance.LimitBalance) AS ClientLimitBalance,
	|		0 AS CustomerSumBalance
	|	FROM
	|		AccumulationRegister.Взаиморасчеты.Balance(
	|				&qBalancesPeriod,
	|				(СчетПроживания.Контрагент = &qEmptyCustomer
	|					OR СчетПроживания.Контрагент = &qIndividualsCustomer
	|					OR СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|						AND СчетПроживания.Контрагент <> &qEmptyCustomer)
	|					AND СчетПроживания.Клиент IN (&qClientList)) AS ClientAccountsBalance
	|	
	|	GROUP BY
	|		ClientAccountsBalance.ВалютаЛицСчета,
	|		ClientAccountsBalance.СчетПроживания.Клиент
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		CustomerAccountsBalance.ВалютаЛицСчета,
	|		CustomerAccountsBalance.СчетПроживания.Клиент,
	|		0,
	|		-SUM(CustomerAccountsBalance.LimitBalance),
	|		SUM(CustomerAccountsBalance.SumBalance)
	|	FROM
	|		AccumulationRegister.Взаиморасчеты.Balance(
	|				&qBalancesPeriod,
	|				СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|					AND СчетПроживания.Клиент IN (&qClientList)) AS CustomerAccountsBalance
	|	
	|	GROUP BY
	|		CustomerAccountsBalance.ВалютаЛицСчета,
	|		CustomerAccountsBalance.СчетПроживания.Клиент) AS AccountsBalance
	|
	|GROUP BY
	|	AccountsBalance.ВалютаЛицСчета,
	|	AccountsBalance.FolioClient";
	vQry.SetParameter("qBalancesPeriod", ?(ЗначениеЗаполнено(pHotel), ?(pHotel.ShowDebtsOnCurrentDate, CurrentDate(), '39991231235959'), '39991231235959'));
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	vQry.SetParameter("qIndividualsCustomer", ?(ЗначениеЗаполнено(pHotel), pHotel.IndividualsCustomer, Справочники.Контрагенты.EmptyRef()));
	vQry.SetParameter("qIndividualsCustomerFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
	vQry.SetParameter("qClientList", pClientList);
	Возврат vQry.Execute().Unload();
КонецФункции //cmGetClientListBalances

//-----------------------------------------------------------------------------
// Description: Returns value table with balances in different currencies for the given client and ГруппаНомеров 
// Parameters: Date to calculate balances, ГруппаНомеров, Client
// Возврат value: Возврат value table row contains Client debt value, Client credit card preauthorisation balance
//-----------------------------------------------------------------------------
Функция cmGetClientRoomBalances(pPeriod, pRoom, pClient) Экспорт
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ClientAccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	SUM(ClientAccountsBalance.SumBalance) AS ClientSumBalance,
	|	SUM(ClientAccountsBalance.LimitBalance) AS ClientLimitBalance
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(
	|			&qPeriod,
	|			(СчетПроживания.Контрагент = &qEmptyCustomer
	|				OR СчетПроживания.Контрагент = &qIndividualsCustomer
	|				OR СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder) AND СчетПроживания.Контрагент <> &qEmptyCustomer)
	|				AND СчетПроживания.Клиент = &qClient
	|				AND СчетПроживания.НомерРазмещения = &qRoom) AS ClientAccountsBalance
	|
	|GROUP BY
	|	ClientAccountsBalance.ВалютаЛицСчета";
	vQry.SetParameter("qPeriod", ?(ЗначениеЗаполнено(pPeriod), pPeriod, '39991231235959'));
	vQry.SetParameter("qEmptyCustomer", Справочники.Customers.EmptyRef());
	Если ЗначениеЗаполнено(pRoom) Тогда
		vQry.SetParameter("qIndividualsCustomer", pRoom.Owner.IndividualsCustomer);
	Иначе
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
		vQry.SetParameter("qIndividualsCustomer", ?(ЗначениеЗаполнено(vHotel), vHotel.IndividualsCustomer, Справочники.Customers.EmptyRef()));
	КонецЕсли;
	vQry.SetParameter("qIndividualsCustomerFolder", Справочники.Customers.КонтрагентПоУмолчанию);
	vQry.SetParameter("qClient", pClient);
	vQry.SetParameter("qRoom", pRoom);
	Возврат vQry.Execute().Unload();
КонецФункции //cmGetClientRoomBalances

//-----------------------------------------------------------------------------
// Get balance for all folios in the value list. Balance is returned by payment sections
// - pDate is optional. Если is not specified, then function calculates current balance
// - pHotel is optional. Если is not specified, then function calculates balance for the 
//   folio hotel. Если it is not specified, then function calculates balance per all hotels.
// - pPaymentSection is optional. Если it is specified, then function calculates balance for the given payment section only
// Returns value table with balances for each folio from the input value list
//-----------------------------------------------------------------------------
Функция cmGetFoliosBalanceByPaymentSections(Val pDate = Неопределено, Val pHotel = Неопределено, Val pPaymentSection = Неопределено, pFoliosList) Экспорт
	// Fill parameter default values 
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
			Если Не ПараметрыСеанса.ТекущаяГостиница.ShowDebtsOnCurrentDate Тогда
				pDate = '39991231235959';
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	// Build query to get accounts balance
	vQry = Новый Query;
	vQry.Text =
	"SELECT
	|	SUM(ISNULL(AccountsBalance.SumBalance, 0)) AS SumBalance, 
	|	-SUM(ISNULL(AccountsBalance.LimitBalance, 0)) AS LimitBalance, " +
		?(ЗначениеЗаполнено(pHotel), "AccountsBalance.Гостиница AS Гостиница, ", "") + 
	"	AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	AccountsBalance.СчетПроживания AS СчетПроживания,
	|	AccountsBalance.PaymentSection.СтавкаНДС AS СтавкаНДС,
	|	AccountsBalance.PaymentSection AS PaymentSection
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(&qDate, " +
		?(ЗначениеЗаполнено(pHotel), "Гостиница = &qHotel AND ", "") +
		?(pPaymentSection <> Неопределено, "PaymentSection = &qPaymentSection AND ", "") +
		"СчетПроживания IN (&qFoliosList)) AS AccountsBalance
	|GROUP BY " +
		?(ЗначениеЗаполнено(pHotel), "AccountsBalance.Гостиница, ", "") +
	"	AccountsBalance.ВалютаЛицСчета,
	|	AccountsBalance.СчетПроживания,
	|	AccountsBalance.PaymentSection.СтавкаНДС,
	|	AccountsBalance.PaymentSection";
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qFoliosList", pFoliosList);
	vQry.SetParameter("qPaymentSection", pPaymentSection);
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetFoliosBalanceByPaymentSections

//-----------------------------------------------------------------------------
// Get balance for all folios in the value list
// - pDate is optional. Если is not specified, then function calculates current balance
// - pHotel is optional. Если is not specified, then function calculates balance for the 
//   folio hotel. Если it is not specified, then function calculates balance per all hotels.
// - pPaymentSection is optional. Если it is specified, then function calculates balance for the given payment section only
// Returns value table with balances for each folio from the input value list
//-----------------------------------------------------------------------------
Функция cmGetFoliosBalance(Val pDate = Неопределено, Val pHotel = Неопределено, Val pPaymentSection = Неопределено, pFoliosList) Экспорт
	// Fill parameter default values 
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
			Если Не ПараметрыСеанса.ТекущаяГостиница.ShowDebtsOnCurrentDate Тогда
				pDate = '39991231235959';
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	// Build query to get accounts balance
	vQry = Новый Query;
	Если ЗначениеЗаполнено(pHotel) Тогда
		vQry.Text =
		"SELECT
		|	AccountsBalance.Гостиница AS Гостиница,
		|	AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
		|	AccountsBalance.СчетПроживания AS СчетПроживания,
		|	ISNULL(AccountsBalance.SumClosingBalance, 0) AS SumBalance,
		|	ISNULL(AccountsBalance.SumReceipt, 0) AS AmountCharged,
		|	ISNULL(AccountsBalance.SumExpense, 0) AS AmountPaid,
		|	-ISNULL(AccountsBalance.LimitClosingBalance, 0) AS LimitBalance
		|FROM
		|	AccumulationRegister.Взаиморасчеты.BalanceANDTurnovers(
		|			,
		|			&qDate,
		|			PERIOD,
		|			RegisterRecordsANDPeriodBoundaries,
		|			Гостиница = &qHotel
		|				AND (NOT &qPaymentSectionIsFilled
		|					OR &qPaymentSectionIsFilled
		|						AND PaymentSection = &qPaymentSection)
		|				AND СчетПроживания IN (&qFoliosList)) AS AccountsBalance";
		vQry.SetParameter("qHotel", pHotel);
	Иначе
		vQry.Text =
		"SELECT
		|	AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
		|	AccountsBalance.СчетПроживания AS СчетПроживания,
		|	ISNULL(AccountsBalance.SumClosingBalance, 0) AS SumBalance,
		|	ISNULL(AccountsBalance.SumReceipt, 0) AS AmountCharged,
		|	ISNULL(AccountsBalance.SumExpense, 0) AS AmountPaid,
		|	-ISNULL(AccountsBalance.LimitClosingBalance, 0) AS LimitBalance
		|FROM
		|	AccumulationRegister.Взаиморасчеты.BalanceANDTurnovers(
		|			,
		|			&qDate,
		|			PERIOD,
		|			RegisterRecordsANDPeriodBoundaries,
		|			(NOT &qPaymentSectionIsFilled
		|				OR &qPaymentSectionIsFilled
		|					AND PaymentSection = &qPaymentSection)
		|				AND СчетПроживания IN (&qFoliosList)) AS AccountsBalance";
	КонецЕсли;
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qFoliosList", pFoliosList);
	vQry.SetParameter("qPaymentSection", pPaymentSection);
	vQry.SetParameter("qPaymentSectionIsFilled", ЗначениеЗаполнено(pPaymentSection));
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetFoliosBalance

//-----------------------------------------------------------------------------
// Get Контрагент balance for all folios in the value list
// - pDate is optional. Если is not specified, then function calculates current balance
// Returns value table with balances for each folio from the input value list
//-----------------------------------------------------------------------------
Функция cmGetGuestGroupsBalance(Val pDate = Неопределено, pFoliosList) Экспорт
	// Fill parameter default values 
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
			Если Не ПараметрыСеанса.ТекущаяГостиница.ShowDebtsOnCurrentDate Тогда
				pDate = '39991231235959';
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	// Build query to get accounts balance
	vQry = Новый Query;
	vQry.Text =
	"SELECT DISTINCT
	|	СчетПроживания.ГруппаГостей
	|INTO AllGuestGroups
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.Ref IN(&qFoliosList)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	СчетПроживания.Ref,
	|	СчетПроживания.ВалютаЛицСчета AS Валюта,
	|	СчетПроживания.Контрагент,
	|	СчетПроживания.Договор,
	|	СчетПроживания.ГруппаГостей
	|INTO AllFolios
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.Ref IN(&qFoliosList)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	AllFolios.Ref AS СчетПроживания,
	|	AllFolios.Валюта,
	|	ISNULL(GuestGroupBalances.SumBalance, 0) AS SumBalance
	|FROM
	|	AllFolios AS AllFolios
	|		LEFT JOIN (SELECT
	|			ВзаиморасчетыКонтрагенты.Контрагент AS Контрагент,
	|			ВзаиморасчетыКонтрагенты.Договор AS Договор,
	|			ВзаиморасчетыКонтрагенты.ГруппаГостей AS ГруппаГостей,
	|			ВзаиморасчетыКонтрагенты.Валюта AS Валюта,
	|			SUM(ВзаиморасчетыКонтрагенты.SumBalance) AS SumBalance
	|		FROM
	|			(SELECT
	|				CustomerAccountsBalance.Контрагент AS Контрагент,
	|				CustomerAccountsBalance.Договор AS Договор,
	|				CustomerAccountsBalance.ГруппаГостей AS ГруппаГостей,
	|				CustomerAccountsBalance.ВалютаРасчетов AS Валюта,
	|				CustomerAccountsBalance.SumBalance AS SumBalance
	|			FROM
	|				AccumulationRegister.ВзаиморасчетыКонтрагенты.Balance(
	|						&qDate,
	|						ГруппаГостей IN
	|							(SELECT
	|								AllGuestGroups.ГруппаГостей
	|							FROM
	|								AllGuestGroups AS AllGuestGroups)) AS CustomerAccountsBalance
	|			
	|			UNION ALL
	|			
	|			SELECT
	|				CurrentAccountsReceivableBalance.Контрагент,
	|				CurrentAccountsReceivableBalance.Договор,
	|				CurrentAccountsReceivableBalance.ГруппаГостей,
	|				CurrentAccountsReceivableBalance.ВалютаЛицСчета,
	|				CurrentAccountsReceivableBalance.SumBalance - CurrentAccountsReceivableBalance.CommissionSumBalance
	|			FROM
	|				AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|						&qDate,
	|						ГруппаГостей IN
	|							(SELECT
	|								AllGuestGroups.ГруппаГостей
	|							FROM
	|								AllGuestGroups AS AllGuestGroups)) AS CurrentAccountsReceivableBalance) AS ВзаиморасчетыКонтрагенты
	|		
	|		GROUP BY
	|			ВзаиморасчетыКонтрагенты.Контрагент,
	|			ВзаиморасчетыКонтрагенты.Договор,
	|			ВзаиморасчетыКонтрагенты.ГруппаГостей,
	|			ВзаиморасчетыКонтрагенты.Валюта) AS GuestGroupBalances
	|		ON AllFolios.Валюта = GuestGroupBalances.Валюта
	|			AND AllFolios.Контрагент = GuestGroupBalances.Контрагент
	|			AND AllFolios.Договор = GuestGroupBalances.Договор
	|			AND AllFolios.ГруппаГостей = GuestGroupBalances.ГруппаГостей";
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qFoliosList", pFoliosList);
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetGuestGroupsBalance

//-----------------------------------------------------------------------------
// Get value table with services found in the folios from the input value list
//-----------------------------------------------------------------------------
Функция cmGetFoliosServices(pFoliosList) Экспорт
	// Build query to get folio services
	vQry = Новый Query;
	vQry.Text =
	"SELECT
	|	FolioSales.Валюта,
	|	FolioSales.СчетПроживания,
	|	FolioSales.Услуга,
	|	FolioSales.Услуга.Code AS ServiceCode,
	|	FolioSales.Услуга.Description AS ServiceDescription,
	|	FolioSales.Услуга.ПорядокСортировки AS ServiceSortCode,
	|	FolioSales.SalesTurnover AS Продажи,
	|	FolioSales.QuantityTurnover AS Количество
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(, , Period, СчетПроживания IN (&qFoliosList)) AS FolioSales
	|
	|ORDER BY
	|	ServiceSortCode,
	|	ServiceDescription";
	vQry.SetParameter("qFoliosList", pFoliosList);
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetFoliosServices

//-----------------------------------------------------------------------------
// Description: Процедура is marked all unused accommodation/reservation folios as deleted
// Parameters: Document
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmDeleteUnusedDocumentFolios(pDoc, pBoundDocs = Неопределено) Экспорт
	// Build and run query to get all document folios
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	СчетПроживания.Ref AS СчетПроживания
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.ДокОснование = &qDoc
	|ORDER BY
	|	СчетПроживания.PointInTime";
	vQry.SetParameter("qDoc", pDoc);
	vAllFolios = vQry.Execute().Unload();
	// Leave folios not in the document charging rules
	Если TypeOf(pDoc) = Type("DocumentRef.БроньУслуг") Тогда
		// Resource reservation
		vRow = vAllFolios.Find(pDoc.ChargingFolio, "СчетПроживания");
		Если vRow <> Неопределено Тогда
			vFolioRef = vRow.СчетПроживания;
			Если vFolioRef.DeletionMark Тогда
				vFolioObj = vFolioRef.GetObject();
				vFolioObj.SetDeletionMark(Ложь);
			КонецЕсли;
			vAllFolios.Delete(vRow);
		КонецЕсли;
	Иначе
		// Accommodation and reservation
		vRules = pDoc.ChargingRules.Unload(, "ChargingFolio");
		Для каждого vRule из vRules Цикл
			vRow = vAllFolios.Find(vRule.ChargingFolio, "СчетПроживания");
			Если vRow <> Неопределено Тогда
				vFolioRef = vRow.СчетПроживания;
				Если vFolioRef.DeletionMark Тогда
					vFolioObj = vFolioRef.GetObject();
					vFolioObj.SetDeletionMark(Ложь);
				КонецЕсли;
				vAllFolios.Delete(vRow);
			Endif;
		КонецЦикла;
	КонецЕсли;
	// Если folio left in the list do not have any transactions based on it then delete it
	Для каждого vRow из vAllFolios Цикл
		vFolioRef = vRow.ЛицевойСчет;
		Если Не vFolioRef.IsMaster И Не vFolioRef.DeletionMark Тогда
			// Check if this folio present in other document charging rules
			vQry = Новый Query();
			vQry.Text = 
			"SELECT
			|	AccommodationChargingRules.Ref,
			|	AccommodationChargingRules.ChargingFolio
			|FROM
			|	Document.Размещение.ChargingRules AS AccommodationChargingRules
			|WHERE
			|	AccommodationChargingRules.ChargingFolio = &qFolio
			|	AND AccommodationChargingRules.Ref <> &qDoc
			|	AND AccommodationChargingRules.Ref.Posted
			|UNION ALL
			|SELECT
			|	ReservationChargingRules.Ref,
			|	ReservationChargingRules.ChargingFolio
			|FROM
			|	Document.Бронирование.ChargingRules AS ReservationChargingRules
			|WHERE
			|	ReservationChargingRules.ChargingFolio = &qFolio
			|	AND ReservationChargingRules.Ref <> &qDoc
			|	AND ReservationChargingRules.Ref.Posted";
			vQry.SetParameter("qFolio", vFolioRef);
			vQry.SetParameter("qDoc", pDoc);
			vDocs = vQry.Execute().Unload();
			// Check folio transactions
			Если vDocs.Count() = 0 Тогда
				vFolioObj = vFolioRef.GetObject();
				vTransCount = vFolioObj.pmGetAllFolioTransactionsCount();
				Если vTransCount = 0 Тогда
					// Check if this folio has active identification cards
					vActiveFolioCards = cmGetClientIdentificationCardsByFolio(vFolioRef);
					Если vActiveFolioCards.Count() = 0 Тогда
						// Set deletion mark
						vFolioObj.SetDeletionMark(Истина);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Если pBoundDocs = Неопределено Тогда
		pBoundDocs = Новый СписокЗначений();
	КонецЕсли;
	Если pBoundDocs.FindByValue(pDoc) = Неопределено Тогда
		pBoundDocs.Add(pDoc);
	КонецЕсли;
	// Check unused folios for other charging rules documents
	Для каждого vCRRow из pDoc.ChargingRules Цикл
		Если ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
			vDoc = vCRRow.ChargingFolio.ДокОснование;
			Если ЗначениеЗаполнено(vDoc) И vDoc <> pDoc Тогда
				Если pBoundDocs.FindByValue(vDoc) = Неопределено Тогда
					pBoundDocs.Add(vDoc);
					cmDeleteUnusedDocumentFolios(vDoc, pBoundDocs);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	// Check unused folios for other one ГруппаНомеров documents
	vOneRoomDocs = Новый ValueTable();
	Если TypeOf(pDoc) = Type("DocumentRef.Бронирование") Тогда
		vOneRoomDocs = cmGetOneRoomReservations(pDoc.НомерДока, pDoc.ГруппаГостей, pDoc.CheckInDate, pDoc.ДатаВыезда);
	ИначеЕсли TypeOf(pDoc) = Type("DocumentRef.Размещение") Тогда
		vOneRoomDocs = cmGetOneRoomAccommodations(pDoc.НомерРазмещения, pDoc.ГруппаГостей, pDoc.CheckInDate, pDoc.ДатаВыезда);
	КонецЕсли;
	Если vOneRoomDocs.Count() > 0 Тогда
		Для каждого vDocRow из vOneRoomDocs Цикл
			vDoc = vDocRow.Ссылка;
			Если ЗначениеЗаполнено(vDoc) И vDoc <> pDoc Тогда
				Если pBoundDocs.FindByValue(vDoc) = Неопределено Тогда
					pBoundDocs.Add(vDoc);
					cmDeleteUnusedDocumentFolios(vDoc, pBoundDocs);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры //cmDeleteUnusedDocumentFolios

//-----------------------------------------------------------------------------
// Description: Rounds number down, i.e. 
//              pRoundDigits = -1: 24 -> 20; 29 -> 20; -33 -> -40; -37 -> -40
//              pRoundDigits =  1: 2.43 -> 2.40; 2.49 -> 2.40; -3.33 -> -3.40; -3.37 -> -3.40
//-----------------------------------------------------------------------------
Функция cmRoundDown(pNumber, pRoundDigits) Экспорт
	vNumber = Round(pNumber, pRoundDigits);
	Если (vNumber - pNumber) > 0 Тогда
		vNumber = vNumber - Pow(10, -pRoundDigits);
	КонецЕсли;
	Возврат vNumber;
КонецФункции //cmRoundDown

//-----------------------------------------------------------------------------
// Description: Rounds number up, i.e. 
//              pRoundDigits = -1: 24 -> 30; 29 -> 30; -33 -> -30; -37 -> -30
//              pRoundDigits =  1: 2.43 -> 2.50; 2.49 -> 2.50; -3.33 -> -3.30; -3.37 -> -3.30
//-----------------------------------------------------------------------------
Функция cmRoundUp(pNumber, pRoundDigits) Экспорт
	vNumber = Round(pNumber, pRoundDigits);
	Если (vNumber - pNumber) < 0 Тогда
		vNumber = vNumber + Pow(10, -pRoundDigits);
	КонецЕсли;
	Возврат vNumber;
КонецФункции //cmRoundUp

//-----------------------------------------------------------------------------
// Description: Returns value table with active set ГруппаНомеров rate prices orders for the given list of ГруппаНомеров rates
// Parameters: Value list with ГруппаНомеров rates, Date to get active set ГруппаНомеров rate prices orders
// Возврат value: Value table with set ГруппаНомеров rate prices orders
//-----------------------------------------------------------------------------
Функция cmGetActiveSetRoomRatePrices(ПризнакЦены, Val Период = Неопределено) Экспорт
	// Check period
	Если Не ЗначениеЗаполнено(Период) Тогда
		Период = ТекущаяДата();
	КонецЕсли;
		// Run query
	vQry = Новый Query();
	vQry.Text = 
	"ВЫБРАТЬ
	|	ИсторияТарифыСрезПоследних.ПриказТариф AS ПриказТариф,
	|	ИсторияТарифыСрезПоследних.Тариф AS Тариф,
	|	ИсторияТарифыСрезПоследних.ТипДеньКалендарь AS ТипДеньКалендарь,
	|	ИсторияТарифыСрезПоследних.ПризнакЦены AS ПризнакЦены
	|ИЗ
	|	РегистрСведений.ИсторияТарифы AS ИсторияТарифыСрезПоследних
	|
	|ORDER BY
	|	ИсторияТарифыСрезПоследних.Тариф.ПорядокСортировки,
	|	ИсторияТарифыСрезПоследних.ТипДеньКалендарь.ПорядокСортировки";
	vQry.SetParameter("Период", Период);
	vQry.SetParameter("qПризнакЦены", ПризнакЦены);
	
	Возврат vQry.Execute().Unload();
КонецФункции //cmGetActiveSetRoomRatePrices

//-----------------------------------------------------------------------------
// Description: Returns value table with service prices for the given list of services
// Parameters: Value list with services, Гостиница, Date to get active prices, Client type
// Возврат value: Value table with service prices
//-----------------------------------------------------------------------------
Функция cmGetServicePrices(pServices, pHotel, Val pPeriod = Неопределено, Val pClientType = Неопределено) Экспорт
	// Common checks	
	Если Не ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetServicePrices function.
		               |CAUSE: Empty pHotel parameter value was passed to the function.
					   |DESC: Mandatory parameter pHotel should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetServicePrices.
				       |CAUSE: В функцию передано пустое значение параметра pHotel.
					   |DESC: Обязательный параметр pHotel должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetServicePrices.
				       |CAUSE: из die Funktion wurde ein leerer Wert des Parameters pHotel übertragen.
					   |DESC: Das Pflichtparameter pHotel muss eindeutig angegeben sein.'"));
	КонецЕсли;
	
	// Fill parameters default values 
	Если Не ЗначениеЗаполнено(pPeriod) Тогда
		pPeriod = CurrentDate();
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pClientType) Тогда
		pClientType = Справочники.ТипыКлиентов.ПустаяСсылка();
	КонецЕсли;
	
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ServicePricesSliceLast.Period,
	|	ServicePricesSliceLast.Гостиница,
	|	ServicePricesSliceLast.Услуга,
	|	ServicePricesSliceLast.Услуга.ЕдИзмерения AS ServiceUnit,
	|	ServicePricesSliceLast.ТипКлиента,
	|	ServicePricesSliceLast.Цена,
	|	ServicePricesSliceLast.Валюта,
	|	ServicePricesSliceLast.СтавкаНДС
	|FROM
	|	РегистрСведений.ServicePrices.SliceLast(
	|			&qPeriod,
	|			Гостиница = &qHotel
	|				AND Услуга IN (&qServices)
	|				AND ТипКлиента = &qClientType) AS ServicePricesSliceLast
	|
	|ORDER BY
	|	ServicePricesSliceLast.Услуга.ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPeriod", pPeriod);
	vQry.SetParameter("qServices", pServices);
	vQry.SetParameter("qClientType", pClientType);
	vPrices = vQry.Execute().Unload();
	
	Если ЗначениеЗаполнено(pClientType) Тогда
		// Run query
		vQry = Новый Query();
		vQry.Text = 
		"SELECT
		|	ServicePricesSliceLast.Period,
		|	ServicePricesSliceLast.Гостиница,
		|	ServicePricesSliceLast.Услуга,
		|	ServicePricesSliceLast.Услуга.ЕдИзмерения AS ServiceUnit,
		|	ServicePricesSliceLast.ТипКлиента,
		|	ServicePricesSliceLast.Цена,
		|	ServicePricesSliceLast.Валюта,
		|	ServicePricesSliceLast.СтавкаНДС
		|FROM
		|	РегистрСведений.ServicePrices.SliceLast(
		|			&qPeriod,
		|			Гостиница = &qHotel
		|				AND Услуга IN (&qServices)
		|				AND ТипКлиента = &qEmptyClientType) AS ServicePricesSliceLast
		|
		|ORDER BY
		|	ServicePricesSliceLast.Услуга.ПорядокСортировки";
		vQry.SetParameter("qHotel", pHotel);
		vQry.SetParameter("qPeriod", pPeriod);
		vQry.SetParameter("qServices", pServices);
		vQry.SetParameter("qEmptyClientType", Справочники.ТипыКлиентов.EmptyRef());
		vEmptyClientTypePrices = vQry.Execute().Unload();
		
		Для каждого vEmptyClientTypePricesRow из vEmptyClientTypePrices Цикл
			vServicePricesRows = vPrices.FindRows(Новый Structure("Гостиница, Услуга", vEmptyClientTypePricesRow.Гостиница, vEmptyClientTypePricesRow.Service));
			Если vServicePricesRows.Count() = 0 Тогда
				vPricesRow = vPrices.Add();
				FillPropertyValues(vPricesRow, vEmptyClientTypePricesRow);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат vPrices;
КонецФункции //cmGetServicePrices

//-----------------------------------------------------------------------------
// Description: Returns cash register driver data processor object based on cash register type
// Parameters: Cash register
// Возврат value: Cash register driver data processor object
//-----------------------------------------------------------------------------
Функция cmGetCashRegisterDataProcessor(pCashRegister) Экспорт
	// Check parameters
	Если Не ЗначениеЗаполнено(pCashRegister) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pCashRegister.CashRegisterDriver) Тогда
		Возврат Неопределено;
	КонецЕсли;
	// Create data processor object for the given driver name
	Try
		vDriverName = pCashRegister.CashRegisterDriver.Metadata().EnumValues[Перечисления.CashRegisterDrivers.IndexOf(pCashRegister.CashRegisterDriver)].Name;
		vDataProcessorObj = Обработки[vDriverName].Create();
		vDataProcessorObj.Касса = pCashRegister;
		Возврат vDataProcessorObj;
	Except
		Возврат Неопределено;
	EndTry;
КонецФункции //cmGetCashRegisterDataProcessor

//-----------------------------------------------------------------------------
// Description: Returns ribbon printer data processor object based on ribbon printer settings
// Parameters: Ribbon printer settings catalog item
// Возврат value: Ribbon printer driver data processor object
//-----------------------------------------------------------------------------
Функция cmGetRibbonPrinterDataProcessor(pSettings) Экспорт
	// Check parameters
	Если Не ЗначениеЗаполнено(pSettings) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если IsBlankString(pSettings.Model) Тогда
		Возврат Неопределено;
	КонецЕсли;
	// Create data processor object
	Try
		Если ЗначениеЗаполнено(pSettings.DriverType) И pSettings.DriverType = Перечисления.RibbonPrinterDrivers.Atol Тогда
			vDriverName = "AtolRibbonPrinterDriver";
		ИначеЕсли ЗначениеЗаполнено(pSettings.DriverType) И pSettings.DriverType = Перечисления.RibbonPrinterDrivers.Intermec Тогда
			vDriverName = "IntermecRibbonPrinterDriver";
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		vDataProcessorObj = Обработки[vDriverName].Create();
		vDataProcessorObj.RibbonPrinterConnectionParameters = pSettings;
		Возврат vDataProcessorObj;
	Except
		Возврат Неопределено;
	EndTry;
КонецФункции //cmGetRibbonPrinterDataProcessor

//-----------------------------------------------------------------------------
// Description: Returns pay card system driver data processor object based on pay card system parameters
// Parameters: Pay card system parameters reference
// Возврат value: Pay card system driver data processor object
//-----------------------------------------------------------------------------
Функция cmGetPayCardDataProcessor(pPCSystemParameters) Экспорт
	// Check parameters
	Если Не ЗначениеЗаполнено(pPCSystemParameters) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pPCSystemParameters.CreditCardsProcessingSystemType) Тогда
		Возврат Неопределено;
	КонецЕсли;
	// Create data processor object for the given driver name
	Try
		Если pPCSystemParameters.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.AtolPayCardSystemsDriver Тогда
			vDriverName = "AtolPayCardSystemsDriver";
		ИначеЕсли pPCSystemParameters.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.TrPosPOSTerminalsDriver Тогда
			vDriverName = "TrPosPOSTerminalsDriver";
		ИначеЕсли pPCSystemParameters.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.INPASPulsarSystemDriver Тогда
			vDriverName = "INPASPulsarSystemDriver";
		ИначеЕсли pPCSystemParameters.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.INPASSmartConnectorDriver Тогда
			vDriverName = "INPASSmartConnectorDriver";
		ИначеЕсли pPCSystemParameters.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.UCSSystemDriver Тогда
			vDriverName = "UCSSystemDriver";
		ИначеЕсли pPCSystemParameters.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.SberbankSBRFCOMSystemDriver Тогда
			vDriverName = "SberbankSBRFCOMSystemDriver";
		ИначеЕсли pPCSystemParameters.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.SberbankSBRFSystemDriver Тогда
			vDriverName = "SberbankSBRFSystemDriver";
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		vDataProcessorObj = Обработки[vDriverName].Create();
		vDataProcessorObj.ПараметрыПроцессинга = pPCSystemParameters;
		Возврат vDataProcessorObj;
	Except
		Возврат Неопределено;
	EndTry;
КонецФункции //cmGetPayCardDataProcessor

//-----------------------------------------------------------------------------
// Description: Returns list of payment methods allowed for the program user
// Parameters: Employee, Whether it is necessary to get list of money back payment methods, 
//             Cash register, Whether to return credit card payment methods only
// Возврат value: Value list of payment methods
//-----------------------------------------------------------------------------
Функция cmGetListOfPaymentMethodsAllowed(pEmployee, pIsReturn = Ложь, pCashRegister = Неопределено, pCreditCardsOnly = Ложь) Экспорт
	vList = Новый СписокЗначений();
	Если Не ЗначениеЗаполнено(pEmployee) Тогда
		Возврат vList;
	КонецЕсли;
	vPermissionGroup = cmGetEmployeePermissionGroup(pEmployee);
	Если Не ЗначениеЗаполнено(vPermissionGroup) Тогда
		Возврат vList;
	КонецЕсли;
	// Initialize user permissions
	UserHavePermissionToReturnCashDirectlyFromCashBox = cmCheckUserPermissions("HavePermissionToReturnCashDirectlyFromCashBox");
	UserShowReturnPaymentMethodsInReturnDocumentsOnly = cmCheckUserPermissions("ShowReturnPaymentMethodsInReturnDocumentsOnly");
	// Get employee permission group list of payment methods
	vList.LoadValues(vPermissionGroup.PaymentMethodsAllowed.UnloadColumn("СпособОплаты"));
	// Remove payment methods marked for deletion
	i = 0;
	While i < vList.Count() Цикл
		vListItem = vList.Get(i);
		vPaymentMethod = vListItem.Value;
		Если vPaymentMethod.DeletionMark Тогда
			vList.Delete(vListItem);
			Continue;
		КонецЕсли;
		i = i + 1;
	КонецЦикла;
	// Remove not applicable payment methods
	Если pIsReturn Тогда
		// Leave payment methods allowed for return according to the user permissions
		i = 0;
		While i < vList.Count() Цикл
			vListItem = vList.Get(i);
			vPaymentMethod = vListItem.Value;
			Если vPaymentMethod.IsByCash Тогда
				vHavePermissionToReturnCashDirectlyFromCashBox = UserHavePermissionToReturnCashDirectlyFromCashBox;
				Если ЗначениеЗаполнено(pCashRegister) Тогда
					Если pCashRegister.CashReturnDirectlyFromCashBoxIsAllowed Тогда
						vHavePermissionToReturnCashDirectlyFromCashBox = Истина;
					КонецЕсли;
				КонецЕсли;
				Если Не vHavePermissionToReturnCashDirectlyFromCashBox Тогда
					Если Не vPaymentMethod.IsForReturnOnly или vPaymentMethod.PrintCheque Тогда
						vList.Delete(vListItem);
						Continue;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			Если UserShowReturnPaymentMethodsInReturnDocumentsOnly Тогда
				Если Не vPaymentMethod.IsForReturnOnly Тогда
					vList.Delete(vListItem);
					Continue;
				КонецЕсли;
			КонецЕсли;
			i = i + 1;
		КонецЦикла;
	Иначе
		// Remove payment methods for return only
		i = 0;
		While i < vList.Count() Цикл
			vListItem = vList.Get(i);
			vPaymentMethod = vListItem.Value;
			Если vPaymentMethod.IsForReturnOnly Тогда
				vList.Delete(vListItem);
				Continue;
			КонецЕсли;
			i = i + 1;
		КонецЦикла;
		// Remove not credit cards
		Если pCreditCardsOnly Тогда
			i = 0;
			While i < vList.Count() Цикл
				vListItem = vList.Get(i);
				vPaymentMethod = vListItem.Value;
				Если Не vPaymentMethod.IsByCreditCard Тогда
					vList.Delete(vListItem);
					Continue;
				КонецЕсли;
				i = i + 1;
			КонецЦикла;
		Endif;
	КонецЕсли;
	Возврат vList;
КонецФункции //cmGetListOfPaymentMethodsAllowed

//-----------------------------------------------------------------------------
// Description: Returns list of cash registers allowed for the current user
// Parameters: Фирма, Workstation, Payment method
// Возврат value: Value list of cash registers
//-----------------------------------------------------------------------------
Функция cmGetListOfCashRegistersAllowed(pCompany = Неопределено, pWorkstation, pPaymentMethod = Неопределено) Экспорт
	vList = Новый СписокЗначений();
	Если Не ЗначениеЗаполнено(pWorkstation) Тогда
		Возврат vList;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pWorkstation.CashRegisters) Тогда
		Возврат vList;
	КонецЕсли;
	Для каждого vRow из pWorkstation.ККМ Цикл
		Если ЗначениеЗаполнено(vRow.Касса) Тогда
			Если vRow.Касса.Owner = pCompany или 
			   Не ЗначениеЗаполнено(pCompany) Тогда
				Если vRow.Касса.DeletionMark Тогда
					Continue;
				КонецЕсли;
				Если ЗначениеЗаполнено(pPaymentMethod) Тогда
					Если Не pPaymentMethod.BookByCashRegister И Не vRow.Касса.CashReturnDirectlyFromCashBoxIsAllowed Тогда
						Continue;
					КонецЕсли;
				КонецЕсли;
				vList.Add(vRow.Касса);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	// Add cash registers that are used based on agent contract
	Если vList.Count() = 0 И ЗначениеЗаполнено(pCompany) Тогда
		Для каждого vRow из pWorkstation.ККМ Цикл
			vCashRegister = vRow.Касса;
			Если ЗначениеЗаполнено(vCashRegister) И ЗначениеЗаполнено(vCashRegister.Гостиница) Тогда
				Если ЗначениеЗаполнено(vCashRegister.Гостиница.Фирма) И vCashRegister.Гостиница.Фирма = vCashRegister.Owner Тогда
					Если vCashRegister.DeletionMark Тогда
						Continue;
					КонецЕсли;
					Если ЗначениеЗаполнено(pPaymentMethod) Тогда
						Если Не pPaymentMethod.BookByCashRegister И Не vCashRegister.CashReturnDirectlyFromCashBoxIsAllowed Тогда
							Continue;
						КонецЕсли;
					КонецЕсли;
					vList.Add(vCashRegister);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Возврат vList;
КонецФункции //cmGetListOfCashRegistersAllowed

//-----------------------------------------------------------------------------
// Description: Returns list of all active cash registers
// Parameters: Фирма
// Возврат value: Value list of cash registers
//-----------------------------------------------------------------------------
Функция cmGetListOfAllCashRegisters(pCompany = Неопределено) Экспорт
	vList = Новый СписокЗначений;
Возврат vList;
КонецФункции //cmGetListOfAllCashRegisters

//-----------------------------------------------------------------------------
// Description: Returns list of all client or Контрагент credit cards 
// Parameters: Card owner
// Возврат value: Value list of credit cards
//-----------------------------------------------------------------------------
Функция cmGetListOfPayersCreditCards(pCardOwner) Экспорт
	vList = Новый СписокЗначений();
	Если Не ЗначениеЗаполнено(pCardOwner) Тогда
		Возврат vList;
	КонецЕсли;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CreditCards.Ref AS CreditCard
	|FROM
	|	Catalog.КредитныеКарты AS CreditCards
	|WHERE
	|	CreditCards.CardOwner = &qCardOwner
	|	AND CreditCards.DeletionMark = FALSE";
	vQry.SetParameter("qCardOwner", pCardOwner);
	vCards = vQry.Execute().Unload();
	vList.LoadValues(vCards.UnloadColumn("CreditCard"));
	Возврат vList;
КонецФункции //cmGetListOfPayersCreditCards

//-----------------------------------------------------------------------------
// Description: Returns list of all client discount cards 
// Parameters: Card owner
// Возврат value: Value table of discount cards data
//-----------------------------------------------------------------------------
Функция cmGetListOfClientDiscountCards(pClient) Экспорт
	vCards = Новый ValueTable();
	Если Не ЗначениеЗаполнено(pClient) Тогда
		Возврат vCards;
	КонецЕсли;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	DiscountCards.Ref AS ДисконтКарт, 
	|	DiscountCards.Code AS Code,
	|	DiscountCards.Description,
	|	DiscountCards.Identifier,
	|	DiscountCards.Клиент,
	|	DiscountCards.ТипСкидки,
	|	DiscountCards.ТипКлиента,
	|	DiscountCards.TurnOffAutomaticDiscounts,
	|	DiscountCards.ValidFrom,
	|	DiscountCards.ValidTo,
	|	DiscountCards.IsBlocked,
	|	DiscountCards.Примечания
	|FROM
	|	Catalog.ДисконтныеКарты AS DiscountCards
	|WHERE
	|	DiscountCards.Клиент = &qClient
	|	AND NOT DiscountCards.DeletionMark
	|
	|ORDER BY
	|	Code";
	vQry.SetParameter("qClient", pClient);
	vCards = vQry.Execute().Unload();
	Возврат vCards;
КонецФункции //cmGetListOfClientDiscountCards

//-----------------------------------------------------------------------------
// Description: Creates structure with credit card data. Fills credit card number
// Parameters: Credit card number
// Возврат value: Credit card data structure
//-----------------------------------------------------------------------------
Функция cmParseCreditCardData(pText) Экспорт
	vData = Новый Structure("CardType, CardNumber, CardHolder, CardValidTillDate, CardSecurityCode, CardIssuer, CardOwner");
	vData.CardType = Справочники.CreditCardTypes.EmptyRef();
	vData.CardNumber = СокрЛП(pText);
	Возврат vData;
КонецФункции //cmParseCreditCardData

//-----------------------------------------------------------------------------
// Description: Masks credit card number with * chars
// Parameters: Credit card number
// Возврат value: Masked credit card number
//-----------------------------------------------------------------------------
Функция cmGetCreditCardDescription(pCardNumber) Экспорт
	vCardDescription = "";
	vCardNumber = СокрЛП(pCardNumber);
	vCardNumberLength = StrLen(vCardNumber);
	vLeftVisiblePartIndex = 6;
	vMidVisiblePartIndex = vCardNumberLength - 4;
	vRightVisiblePartIndex = vCardNumberLength;
	Для i = 1 To vCardNumberLength Цикл
		Если i <= vLeftVisiblePartIndex или 
		   i > vMidVisiblePartIndex И i <= vRightVisiblePartIndex Тогда
			vCardDescription = vCardDescription + Mid(vCardNumber, i, 1);
		Иначе
			vCardDescription = vCardDescription + "*";
		КонецЕсли;
	КонецЦикла;
	Возврат vCardDescription; 
КонецФункции //cmGetCreditCardDescription	

//-----------------------------------------------------------------------------
// Description: Recalculates price based on amount and quantity
// Parameters: Amount, Quantity
// Возврат value: Price
//-----------------------------------------------------------------------------
Функция cmRecalculatePrice(pSum, pQuantity) Экспорт
	vQuantity = pQuantity;
	Если vQuantity = 0 Тогда
		vQuantity = 1;
	КонецЕсли;
	vPrice = Round(pSum / vQuantity, 2);
	Возврат vPrice;
КонецФункции //cmRecalculatePrice

//-----------------------------------------------------------------------------
// Description: Returns amount presentation in words
// Parameters: Amount, Currency, Language
// Возврат value: Amount presentation in words
//-----------------------------------------------------------------------------
Функция cmSumInWords(pSum, pCurrency, pLang) Экспорт
	vLocalizationCode = "";
	Если ЗначениеЗаполнено(pLang) Тогда
		Если Не IsBlankString(pLang.LocalizationCode) Тогда
			vLocalizationCode = СокрЛП(pLang.LocalizationCode);
		Иначе
			vLocalizationCode = "ru_RU";
		КонецЕсли;
	КонецЕсли;
	vNumberInWordsAttributes = "";
	Если ЗначениеЗаполнено(pCurrency) Тогда
		Если ЗначениеЗаполнено(pLang) Тогда
			vSumInWordsAttributesRow = pCurrency.SumInWordsAttributes.Find(pLang, "Language");
			Если vSumInWordsAttributesRow <> Неопределено Тогда
				vNumberInWordsAttributes = СокрЛП(vSumInWordsAttributesRow.NumberInWordsAttributes);
			КонецЕсли;
		Иначе
			vNumberInWordsAttributes = "рубль, рубля, рублей, м, копейка, копейки, копеек, ж, 2";
		КонецЕсли;
	КонецЕсли;
	vSumInWords = NumberInWords(pSum, "L=" + vLocalizationCode + "; SN=Истина; FN=Истина; FS=Ложь", vNumberInWordsAttributes);
	Возврат vSumInWords;
КонецФункции //cmSumInWords

//-----------------------------------------------------------------------------
// Description: Returns value table with charges not in settlements yet
// Parameters: Date to check settlements, Filter attributes: Контрагент, Contract, Accommodation/Reservation, Guest group, Currency, Гостиница
// Возврат value: Value table with charges that are not in settlements at the given date
//-----------------------------------------------------------------------------
Функция cmGetCurrentAccountsReceivableChargesWithBalances(Val pDate = Неопределено, pCustomer = Неопределено, pContract = Неопределено, pParentDoc = Неопределено, pGuestGroup = Неопределено, pCurrency, pHotel = Неопределено, pChargesToSkip = Неопределено) Экспорт
	// Fill parameter default values 
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	КонецЕсли;

	// Build query to get services
	vQry = Новый Query;
	vQry.Text =
	"SELECT
	|	CurrentAccountsReceivableBalance.Гостиница,
	|	CurrentAccountsReceivableBalance.Фирма,
	|	CurrentAccountsReceivableBalance.Контрагент,
	|	CurrentAccountsReceivableBalance.Договор,
	|	CurrentAccountsReceivableBalance.ГруппаГостей,
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета,
	|	CurrentAccountsReceivableBalance.СчетПроживания,
	|	CurrentAccountsReceivableBalance.ДокОснование,
	|	CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка AS ПутевкаКурсовка,
	|	CurrentAccountsReceivableBalance.Начисление AS Начисление,
	|	CurrentAccountsReceivableBalance.Начисление.Скидка AS Скидка,
	|	CurrentAccountsReceivableBalance.Начисление.СуммаСкидки AS СуммаСкидки,
	|	CurrentAccountsReceivableBalance.Начисление.ВидКомиссииАгента AS ВидКомиссииАгента,
	|	CurrentAccountsReceivableBalance.Начисление.КомиссияАгента AS КомиссияАгента,
	|	CurrentAccountsReceivableBalance.CommissionSumBalance,
	|	CurrentAccountsReceivableBalance.SumBalance,
	|	CurrentAccountsReceivableBalance.VATSumBalance,
	|	CurrentAccountsReceivableBalance.QuantityBalance
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|		&qPeriod, TRUE" +
			?(ЗначениеЗаполнено(pHotel), " AND Гостиница = &qHotel" , "") + 
			?(ЗначениеЗаполнено(pCustomer), " AND (Контрагент = &qCustomer OR Контрагент IN HIERARCHY (&qIndividualsCustomerFolder) AND Контрагент <> &qEmptyCustomer AND &qIsIndividualsCustomer OR Контрагент = &qEmptyCustomer AND &qIsIndividualsCustomer)" , "") + 
			?(ЗначениеЗаполнено(pContract), " AND Договор = &qContract" , "") + 
			?(ЗначениеЗаполнено(pParentDoc), " AND ДокОснование = &qParentDoc" , "") + 
			?(ЗначениеЗаполнено(pGuestGroup), " AND ГруппаГостей = &qGuestGroup" , "") + "
	|		AND ВалютаЛицСчета = &qCurrency
	|		AND (&qAll OR NOT &qAll AND Начисление NOT IN (&qChargesToSkip))) AS CurrentAccountsReceivableBalance
	|ORDER BY
	|	Начисление.ДатаДок,
	|	Начисление.PointInTime";
	// Set query parameters
	vQry.SetParameter("qPeriod", pDate);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qEmptyCustomer", Справочники.Customers.EmptyRef());
	vQry.SetParameter("qIndividualsCustomerFolder", Справочники.Customers.КонтрагентПоУмолчанию);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qParentDoc", pParentDoc);
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qCurrency", pCurrency);
	vQry.SetParameter("qAll", ?(pChargesToSkip = Неопределено, Истина, Ложь));
	vQry.SetParameter("qChargesToSkip", pChargesToSkip);
	// Individuals Контрагент
	vIsIndividualsCustomer = Ложь;
	Если ЗначениеЗаполнено(pCustomer) И ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		Если pCustomer = ПараметрыСеанса.ТекущаяГостиница.IndividualsCustomer Тогда
			vIsIndividualsCustomer = Истина;
		КонецЕсли;
	КонецЕсли;
	vQry.SetParameter("qIsIndividualsCustomer", vIsIndividualsCustomer);
	// Run query and return results
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetCurrentAccountsReceivableChargesWithBalances

//-----------------------------------------------------------------------------
// Description: Returns VAT invoice last used number
// Parameters: Фирма
// Возврат value: String, maximum VAT invoice number
//-----------------------------------------------------------------------------
Функция cmGetLastUsedVATInvoiceNumber(pCompany) Экспорт
	vNum = "";
	vQry = Новый Query();
	vQry.Text = 
	"SELECT TOP 1
	|	Акт.InvoiceNumber AS InvoiceNumber
	|FROM
	|	Document.Акт AS Акт
	|WHERE
	|	Акт.InvoiceNumber > &qEmptyNumber
	|	AND Акт.Фирма = &qCompany
	|ORDER BY
	|	InvoiceNumber DESC";
	vQry.SetParameter("qEmptyNumber", "                    ");
	vQry.SetParameter("qCompany", pCompany);
	vQryRes = vQry.Execute().Unload();
	Для каждого vRow из vQryRes Цикл
		vNum = СокрЛП(vRow.InvoiceNumber);
		Break;
	КонецЦикла;
	Возврат vNum;
КонецФункции //cmGetLastUsedVATInvoiceNumber

//-----------------------------------------------------------------------------
// Description: Returns next vacant VAT invoice number
// Parameters: VAT invoice number last used
// Возврат value: String, new VAT invoice number
//-----------------------------------------------------------------------------
Функция cmGetNextVATInvoiceNumber(pLastNumber = "") Экспорт
	// Add 1 to the numeric right part of number
	vNextNum = "";
	vNum = СокрЛП(pLastNumber);
	vNumStr = "";
	vPrefixStr = "";
	i = StrLen(vNum);
	While i > 0 Цикл
		vChar = Mid(vNum, i, 1);
		Если vChar = "0" или vChar = "1" или vChar = "2" или vChar = "3" или vChar = "4" или
		   vChar = "5" или vChar = "6" или vChar = "7" или vChar = "8" или vChar = "9" Тогда
			vNumStr = vChar + vNumStr;
		Иначе
			vPrefixStr = Left(vNum, i);
			Break;
		КонецЕсли;
		i = i - 1; 
	КонецЦикла;
	Если Не IsBlankString(vNumStr) Тогда
		vNumStrLen = StrLen(vNumStr);
		vNumNum = Number(vNumStr);
		vNextNum = vPrefixStr + Format(vNumNum+1, "ND=" + String(vNumStrLen) + "; NZ=; NLZ=; NG=");
	Иначе
		vNextNum = vPrefixStr + "1";
	КонецЕсли;
	Возврат vNextNum;
КонецФункции //cmGetNextVATInvoiceNumber

//-----------------------------------------------------------------------------
// Description: Returns value table with Контрагент accounts balances
// Parameters: Date to check balances at, Filter attributes: Контрагент, Contract, Guest group, Currency, Фирма, Гостиница
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetCustomerAccountsBalances(Val pDate = Неопределено, pCustomer = Неопределено, pContract = Неопределено, pGuestGroup = Неопределено, 
                                                              pCurrency = Неопределено, pCompany = Неопределено, pHotel = Неопределено, 
															  pShowCurrentAccountsReceivable = Неопределено, pShowForecastBalance = Неопределено) Экспорт
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = '39991231235959';
	КонецЕсли;
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	ВзаиморасчетыКонтрагенты.Контрагент,
	|	ВзаиморасчетыКонтрагенты.Договор,
	|	ВзаиморасчетыКонтрагенты.ГруппаГостей,
	|	ВзаиморасчетыКонтрагенты.ВалютаРасчетов,
	|	ВзаиморасчетыКонтрагенты.Фирма,
	|	ВзаиморасчетыКонтрагенты.Гостиница,
	|	SUM(ВзаиморасчетыКонтрагенты.Balance) AS Balance
	|FROM (
	|	SELECT
	|		CustomerAccountsBalance.Контрагент AS Контрагент,
	|		CustomerAccountsBalance.Договор AS Договор,
	|		CustomerAccountsBalance.ГруппаГостей AS ГруппаГостей,
	|		CustomerAccountsBalance.ВалютаРасчетов AS ВалютаРасчетов,
	|		CustomerAccountsBalance.Фирма AS Фирма,
	|		CustomerAccountsBalance.Гостиница AS Гостиница,
	|		CustomerAccountsBalance.SumBalance AS Balance
	|	FROM
	|		AccumulationRegister.ВзаиморасчетыКонтрагенты.Balance(
	|		&qPeriod, TRUE " +
			?(pHotel <> Неопределено, "AND Гостиница = &qHotel ", "") + 
			?(pCustomer <> Неопределено, "AND Контрагент = &qCustomer ", "") + 
			?(pContract <> Неопределено, "AND Договор = &qContract ", "") + 
			?(pGuestGroup <> Неопределено, "AND ГруппаГостей = &qGuestGroup ", "") + 
			?(pCompany <> Неопределено, "AND Фирма = &qCompany ", "") + 
			?(pCurrency <> Неопределено, "AND ВалютаРасчетов = &qCurrency ", "") + "
	|	) AS CustomerAccountsBalance
	|	UNION ALL
	|	SELECT
	|		CurrentAccountsReceivableBalance.Контрагент,
	|		CurrentAccountsReceivableBalance.Договор,
	|		CurrentAccountsReceivableBalance.ГруппаГостей,
	|		CurrentAccountsReceivableBalance.ВалютаЛицСчета,
	|		CurrentAccountsReceivableBalance.Фирма,
	|		CurrentAccountsReceivableBalance.Гостиница,
	|		(CurrentAccountsReceivableBalance.SumBalance - CurrentAccountsReceivableBalance.CommissionSumBalance)
	|	FROM
	|		AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|		, &qShowCurrentAccountsReceivable " +
			?(pHotel <> Неопределено, "AND Гостиница = &qHotel ", "") + 
			?(pCustomer <> Неопределено, "AND (Контрагент = &qCustomer OR &qIndividualsCustomerIsChoosen AND Контрагент IN HIERARCHY (&qIndividualsCustomerFolder) AND Контрагент <> &qEmptyCustomer OR &qIndividualsCustomerIsChoosen AND Контрагент = &qEmptyCustomer) ", "") + 
			?(pContract <> Неопределено, "AND Договор = &qContract ", "") + 
			?(pGuestGroup <> Неопределено, "AND ГруппаГостей = &qGuestGroup ", "") + 
			?(pCompany <> Неопределено, "AND Фирма = &qCompany ", "") + 
			?(pCurrency <> Неопределено, "AND ВалютаЛицСчета = &qCurrency ", "") + "
	|	) AS CurrentAccountsReceivableBalance
	|	UNION ALL
	|	SELECT
	|		CustomerAccountsForecast.Контрагент,
	|		CustomerAccountsForecast.Договор,
	|		CustomerAccountsForecast.ГруппаГостей,
	|		CustomerAccountsForecast.Валюта,
	|		CustomerAccountsForecast.Фирма,
	|		CustomerAccountsForecast.Гостиница,
	|		(CustomerAccountsForecast.SalesTurnover - CustomerAccountsForecast.CommissionSumTurnover)
	|	FROM
	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
	|		,, PERIOD, &qShowForecastBalance " +
			?(pHotel <> Неопределено, "AND Гостиница = &qHotel ", "") + 
			?(pCustomer <> Неопределено, "AND (Контрагент = &qCustomer OR &qIndividualsCustomerIsChoosen AND Контрагент IN HIERARCHY (&qIndividualsCustomerFolder) AND Контрагент <> &qEmptyCustomer OR &qIndividualsCustomerIsChoosen AND Контрагент = &qEmptyCustomer) ", "") + 
			?(pContract <> Неопределено, "AND Договор = &qContract ", "") + 
			?(pGuestGroup <> Неопределено, "AND ГруппаГостей = &qGuestGroup ", "") + 
			?(pCompany <> Неопределено, "AND Фирма = &qCompany ", "") + 
			?(pCurrency <> Неопределено, "AND Валюта = &qCurrency ", "") + "
	|	) AS CustomerAccountsForecast
	|) AS ВзаиморасчетыКонтрагенты
	|GROUP BY
	|	ВзаиморасчетыКонтрагенты.Контрагент,
	|	ВзаиморасчетыКонтрагенты.Договор,
	|	ВзаиморасчетыКонтрагенты.ГруппаГостей,
	|	ВзаиморасчетыКонтрагенты.ВалютаРасчетов,
	|	ВзаиморасчетыКонтрагенты.Фирма,
	|	ВзаиморасчетыКонтрагенты.Гостиница
	|ORDER BY
	|	ВзаиморасчетыКонтрагенты.Контрагент.Description,
	|	ВзаиморасчетыКонтрагенты.Договор.Description,
	|	ВзаиморасчетыКонтрагенты.ГруппаГостей.Code,
	|	ВзаиморасчетыКонтрагенты.Гостиница.ПорядокСортировки,
	|	ВзаиморасчетыКонтрагенты.Фирма.ПорядокСортировки,
	|	ВзаиморасчетыКонтрагенты.ВалютаРасчетов.ПорядокСортировки";
	vQry.SetParameter("qPeriod", pDate);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qCurrency", pCurrency);
	vQry.SetParameter("qCompany", pCompany);
	vQry.SetParameter("qHotel", pHotel);
	Если pShowCurrentAccountsReceivable = Неопределено Тогда
		vQry.SetParameter("qShowCurrentAccountsReceivable", ?(ЗначениеЗаполнено(pHotel), pHotel.ShowCurrentAccountsReceivable, Ложь));
	Иначе
		vQry.SetParameter("qShowCurrentAccountsReceivable", pShowCurrentAccountsReceivable);
	КонецЕсли;
	Если pShowForecastBalance = Неопределено Тогда
		vQry.SetParameter("qShowForecastBalance", Ложь);
	Иначе
		vQry.SetParameter("qShowForecastBalance", Истина);
	КонецЕсли;
	Если ЗначениеЗаполнено(pHotel) И ЗначениеЗаполнено(pCustomer) И pCustomer = pHotel.IndividualsCustomer Тогда
		vQry.SetParameter("qIndividualsCustomerIsChoosen", Истина);
	Иначе
		vQry.SetParameter("qIndividualsCustomerIsChoosen", Ложь);
	КонецЕсли;
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.ПустаяСсылка());
	vQry.SetParameter("qIndividualsCustomerFolder", Справочники.Контрагенты.IndividualsFolder);
	vResults = vQry.Execute().Unload();
	Возврат vResults;
КонецФункции //cmGetCustomerAccountsBalances

//-----------------------------------------------------------------------------
// Description: Calculates and returnes Контрагент undistributed advances
// Parameters: Date to check balances at, Filter attributes: Контрагент, Contract, Guest group, Currency, Фирма, Гостиница
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetCustomerUndistributedAdvances(pCustomer = Неопределено, pContract = Неопределено, pGuestGroup = Неопределено, 
                                            pCurrency = Неопределено, pCompany = Неопределено, pHotel = Неопределено, pPeriod = Неопределено) Экспорт
	// Get accounting balances
	vCustomerAccounts = cmGetCustomerAccountsBalances(pPeriod, 
	                                                  ?(ЗначениеЗаполнено(pCustomer), pCustomer, Неопределено),
													  ?(ЗначениеЗаполнено(pContract), pContract, Неопределено), 
													  ?(ЗначениеЗаполнено(pGuestGroup), pGuestGroup, Неопределено), 
	                                                  ?(ЗначениеЗаполнено(pCurrency), pCurrency, Неопределено),
													  ?(ЗначениеЗаполнено(pCompany), pCompany, Неопределено), 
													  ?(ЗначениеЗаполнено(pHotel), pHotel, Неопределено), Ложь);
	vCustomerAccounts.GroupBy("ВалютаРасчетов", "Balance");
	// Возврат table
	Возврат vCustomerAccounts;
КонецФункции //cmGetCustomerUndistributedAdvances

//-----------------------------------------------------------------------------
// Description: Returns list of invoices unpaied
// Parameters: Date to check invoice balances at, Filter attributes: Контрагент, Contract, Guest group, Currency, Фирма, Гостиница
// Возврат value: Value table with invoices
//-----------------------------------------------------------------------------
Функция cmGetInvoicesWithBalances(Val pDate = Неопределено, pCustomer = Неопределено, pContract = Неопределено, pGuestGroup = Неопределено, 
                                                          pCurrency = Неопределено, pCompany = Неопределено, pHotel = Неопределено) Экспорт
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = '39991231235959';
	КонецЕсли;
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	InvoiceAccountsBalance.СчетНаОплату AS СчетНаОплату,
	|	InvoiceAccountsBalance.СчетНаОплату.НомерДока AS InvoiceNumber,
	|	InvoiceAccountsBalance.СчетНаОплату.ДатаДок AS InvoiceDate,
	|	InvoiceAccountsBalance.Фирма AS Фирма,
	|	InvoiceAccountsBalance.Контрагент AS Контрагент,
	|	InvoiceAccountsBalance.Договор AS Договор,
	|	InvoiceAccountsBalance.ГруппаГостей AS ГруппаГостей,
	|	InvoiceAccountsBalance.СчетНаОплату.Сумма AS Сумма,
	|	InvoiceAccountsBalance.СчетНаОплату.СуммаНДС AS СуммаНДС,
	|	InvoiceAccountsBalance.ВалютаРасчетов AS ВалютаРасчетов,
	|	InvoiceAccountsBalance.SumBalance AS Balance
	|FROM
	|	AccumulationRegister.ВзаиморасчетыПоСчетам.Balance(&qPeriod, TRUE " + 
			?(pHotel <> Неопределено, "AND Гостиница = &qHotel ", "") + 
			?(pCustomer <> Неопределено, "AND Контрагент = &qCustomer ", "") + 
			?(pContract <> Неопределено, "AND Договор = &qContract ", "") + 
			?(pGuestGroup <> Неопределено, "AND ГруппаГостей = &qGuestGroup ", "") + 
			?(pCompany <> Неопределено, "AND Фирма = &qCompany ", "") + 
			?(pCurrency <> Неопределено, "AND ВалютаРасчетов = &qCurrency ", "") + "
	|	) AS InvoiceAccountsBalance
	|ORDER BY
	|	InvoiceAccountsBalance.СчетНаОплату.PointInTime";
	vQry.SetParameter("qPeriod", pDate);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qCurrency", pCurrency);
	vQry.SetParameter("qCompany", pCompany);
	vQry.SetParameter("qHotel", pHotel);
	vDocs = vQry.Execute().Unload();
	Возврат vDocs;
КонецФункции //cmGetInvoicesWithBalances

//-----------------------------------------------------------------------------
// Description: Returns amount of Контрагент accounts balance
// Parameters: Date to check balance at, Filter attributes: Контрагент, Contract, Guest group, Currency, Фирма, Гостиница
// Возврат value: Number, balance amount
//-----------------------------------------------------------------------------
Функция cmGetCustomerAccountsBalance(Val pDate = Неопределено, pCustomer, pContract, pGuestGroup, pCurrency, pCompany, pHotel) Экспорт
	vBalance = 0;
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = '39991231235959';
	КонецЕсли;
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CustomerAccountsBalance.Фирма,
	|	CustomerAccountsBalance.Контрагент,
	|	CustomerAccountsBalance.Договор,
	|	CustomerAccountsBalance.ГруппаГостей,
	|	CustomerAccountsBalance.ВалютаРасчетов,
	|	CustomerAccountsBalance.Гостиница,
	|	CustomerAccountsBalance.SumBalance AS Balance
	|FROM
	|	AccumulationRegister.ВзаиморасчетыКонтрагенты.Balance(
	|		&qPeriod,
	|		Контрагент = &qCustomer
	|		AND Договор = &qContract
	|		AND ВалютаРасчетов = &qCurrency
	|		AND Фирма = &qCompany
	|		AND ГруппаГостей = &qGuestGroup
	|		AND Гостиница = &qHotel) AS CustomerAccountsBalance";
	vQry.SetParameter("qPeriod", pDate);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qCurrency", pCurrency);
	vQry.SetParameter("qCompany", pCompany);
	vQry.SetParameter("qHotel", pHotel);
	vRes = vQry.Execute().Unload();
	Для каждого vRow из vRes Цикл
		vBalance = vBalance + vRow.Balance;
	КонецЦикла;
	Возврат vBalance;
КонецФункции //cmGetCustomerAccountsBalance	

//-----------------------------------------------------------------------------
// Description: Returns value table with invoice balances
// Parameters: Date to check balance at, List of invoices to get balances for
// Возврат value: Value table with invoice balances
//-----------------------------------------------------------------------------
Функция cmGetInvoiceBalances(Val pDate = Неопределено, pInvoices) Экспорт
	Если Не ЗначениеЗаполнено(pDate) Тогда
		pDate = '39991231235959';
	КонецЕсли;
	// Build and run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	InvoiceAccountsBalance.Фирма,
	|	InvoiceAccountsBalance.СчетНаОплату,
	|	InvoiceAccountsBalance.Гостиница,
	|	InvoiceAccountsBalance.SumBalance AS Balance
	|FROM
	|	AccumulationRegister.ВзаиморасчетыПоСчетам.Balance(
	|		&qPeriod,
	|		СчетНаОплату IN(&qInvoices)) AS InvoiceAccountsBalance";
	vQry.SetParameter("qPeriod", pDate);
	vQry.SetParameter("qInvoices", pInvoices);
	vRes = vQry.Execute().Unload();
	Возврат vRes;
КонецФункции //cmGetInvoiceBalances

//-----------------------------------------------------------------------------
// Description: Returns value table with list of all currencies
// Parameters: None
// Возврат value: Value table with currencies
//-----------------------------------------------------------------------------
Функция cmGetAllCurrencies() Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT 
	|	Валюты.Ref AS Валюта
	|FROM
	|	Catalog.Валюты AS Currencies
	|WHERE
	|	Валюты.DeletionMark = FALSE
	|ORDER BY Валюты.ПорядокСортировки";
	vList = vQry.Execute().Unload();
	Возврат vList;
КонецФункции //cmGetAllCurrencies

//-----------------------------------------------------------------------------
// Description: Returns value table with list of all card types
// Parameters: None
// Возврат value: Value table with client identification card types
//-----------------------------------------------------------------------------
Функция cmGetAllIdentificationCardTypes() Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	ТипКартИД.Ref AS IdentificationCardType,
	|	ТипКартИД.DoNotUseChargingRules,
	|	ТипКартИД.ExternalSystemsAllowed,
	|	ТипКартИД.AdditionalServicesFolioCondition,
	|	ТипКартИД.DoServiceRegistrationWithoutChargesControl,
	|	ТипКартИД.Description,
	|	ТипКартИД.Code,
	|	ТипКартИД.ПорядокСортировки,
	|	ТипКартИД.ColorName
	|FROM
	|	Catalog.ТипКартИД AS ТипКартИД
	|WHERE
	|	NOT ТипКартИД.DeletionMark
	|	AND NOT ТипКартИД.IsFolder
	|
	|ORDER BY
	|	ТипКартИД.ПорядокСортировки,
	|	ТипКартИД.Description";
	vList = vQry.Execute().Unload();
	Возврат vList;
КонецФункции //cmGetAllIdentificationCardTypes

//-----------------------------------------------------------------------------
// Description: Returns value list with all reasons for price chnage
// Parameters: None
// Возврат value: Value list with reasons
//-----------------------------------------------------------------------------
Функция cmGetAllReasonsForPriceChange() Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT 
	|	ПричиныИзмененияЦены.Ref AS Ref
	|FROM
	|	Catalog.ПричиныИзмененияЦены AS ПричиныИзмененияЦены
	|WHERE
	|	ПричиныИзмененияЦены.DeletionMark = FALSE
	|ORDER BY ПричиныИзмененияЦены.Description";
	vQryResult = vQry.Execute().Unload();
	vList = Новый СписокЗначений();
	vList.LoadValues(vQryResult.UnloadColumn("Ref"));
	Возврат vList;
КонецФункции //cmGetAllReasonsForPriceChange

//-----------------------------------------------------------------------------
// Description: Returns currency presentation
// Parameters: Currency, Language
// Возврат value: String, Currency presentation
//-----------------------------------------------------------------------------
Функция cmGetCurrencyPresentation(pCurrency, Val pLang = Неопределено) Экспорт
	Если Не ЗначениеЗаполнено(pLang) Тогда
		pLang = ПараметрыСеанса.ТекЛокализация;
	КонецЕсли;
	vCurrencyStr = "";
	Если ЗначениеЗаполнено(pCurrency) Тогда
		Если IsBlankString(pCurrency.CurrencySymbol) Тогда
			vCurrencyStr = pCurrency.GetObject().pmGetCurrencyDescription(pLang);
		Иначе
			vCurrencyStr = СокрЛП(pCurrency.CurrencySymbol);
		КонецЕсли;
	КонецЕсли;
	Возврат vCurrencyStr;
КонецФункции //cmGetCurrencyPresentation	

//-----------------------------------------------------------------------------
// Description: Returns value table with guest group client folios with debts
// Parameters: Guest group
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetGuestGroupClientsFoliosWithDebts(pGuestGroup) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	AccountsBalance.СчетПроживания AS СчетПроживания
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(&qEndOfTime, СчетПроживания.ГруппаГостей <> &qGuestGroup) AS AccountsBalance
	|WHERE
	|	AccountsBalance.СчетПроживания.Клиент IN (
	|	SELECT
	|		СчетПроживания.Клиент
	|	FROM
	|		Document.СчетПроживания AS СчетПроживания
	|	WHERE
	|		СчетПроживания.ГруппаГостей = &qGuestGroup
	|		AND СчетПроживания.Клиент <> &qEmptyClient
	|	GROUP BY
	|		СчетПроживания.Клиент
	|	)
	|GROUP BY
	|	AccountsBalance.СчетПроживания";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qEndOfTime", '39991231235959');
	vQry.SetParameter("qEmptyClient", Справочники.Clients.EmptyRef());
	vFolios = vQry.Execute().Unload();
	
	vFoliosList = Новый СписокЗначений();
	vFoliosList.LoadValues(vFolios.UnloadColumn("СчетПроживания"));
	
	Возврат vFoliosList;
КонецФункции //cmGetGuestGroupClientsFoliosWithDebts

//-----------------------------------------------------------------------------
// Description: Returns value table with client folios with debts
// Parameters: Client, Guest group
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetClientFoliosWithDebts(pClient, pGuestGroup) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	AccountsBalance.СчетПроживания AS СчетПроживания
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(
	|			&qEndOfTime,
	|			СчетПроживания.IsClosed
	|				AND СчетПроживания.Клиент = &qClient
	|				AND СчетПроживания.ГруппаГостей <> &qGuestGroup) AS AccountsBalance
	|
	|GROUP BY
	|	AccountsBalance.СчетПроживания";
	vQry.SetParameter("qClient", pClient);
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qEndOfTime", '39991231235959');
	vFolios = vQry.Execute().Unload();
	
	vFoliosList = Новый СписокЗначений();
	vFoliosList.LoadValues(vFolios.UnloadColumn("СчетПроживания"));
	
	Возврат vFoliosList;
КонецФункции //cmGetClientFoliosWithDebts

//-----------------------------------------------------------------------------
// Description: Returns value table with accommodation/reservation folios with debts
// Parameters: Value list of documents to check, Возврат folios with negative balances only
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetDocumentFoliosWithDebts(pDocsList, pDepositsOnly = Ложь) Экспорт
	vDocsList = Неопределено;
	Если TypeOf(pDocsList) <> Type("СписокЗначений") Тогда
		vDocsList = Новый СписокЗначений();
		vDocsList.Add(pDocsList);
	Иначе
		vDocsList = pDocsList;
	КонецЕсли;
	// Add group folios
	vGuestGroups = Новый СписокЗначений();
	vFoliosList = Новый СписокЗначений();
	Для каждого vDocItem из vDocsList Цикл
		vDoc = vDocItem.Value;
		Если ЗначениеЗаполнено(vDoc) И ЗначениеЗаполнено(vDoc.ГруппаГостей) Тогда
			vGuestGroup = vDoc.ГруппаГостей;
			Если vGuestGroups.FindByValue(vGuestGroup) = Неопределено Тогда
				vGuestGroups.Add(vGuestGroup);
				Для каждого vCRRow из vGuestGroup.ChargingRules Цикл
					Если ЗначениеЗаполнено(vCRRow.ChargingFolio) И vFoliosList.FindByValue(vCRRow.ChargingFolio) = Неопределено Тогда
						vFoliosList.Add(vCRRow.ChargingFolio);
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	AccountsBalance.СчетПроживания, " + 
	?(pDepositsOnly, "(AccountsBalance.SumBalance + AccountsBalance.LimitBalance) AS SumBalance ", "AccountsBalance.SumBalance ") + "
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(&qEndOfTime, СчетПроживания.ДокОснование IN (&qDocsList) OR СчетПроживания IN (&qFoliosList)) AS AccountsBalance " +
	?(pDepositsOnly, "WHERE (AccountsBalance.SumBalance + AccountsBalance.LimitBalance) < 0 ", "") + "
	|ORDER BY
	|	AccountsBalance.СчетПроживания.НомерРазмещения,
	|	AccountsBalance.СчетПроживания.DateTimeFrom,
	|	AccountsBalance.СчетПроживания.Клиент";
	vQry.SetParameter("qEndOfTime", '39991231235959');
	vQry.SetParameter("qDocsList", vDocsList);
	vQry.SetParameter("qFoliosList", vFoliosList);
	vFolios = vQry.Execute().Unload();
	Возврат vFolios;
КонецФункции //cmGetDocumentFoliosWithDebts

//-----------------------------------------------------------------------------
// Description: Calculates and returns Контрагент balance taking active reservations into account
// Parameters: Контрагент, Contract. Гостиница, Date to get balances at, Currency
// Возврат value: Number
//-----------------------------------------------------------------------------
Функция cmCalculateCustomerOperationalBalance(pCustomer, pContract = Неопределено, pHotel = Неопределено, Val pPeriod = Неопределено, rCurrency = Неопределено) Экспорт
	vBalance = 0;
	// Check parameters
	Если Не ЗначениеЗаполнено(pCustomer) Тогда
		Возврат vBalance;
	КонецЕсли;
	// Initialize parameters
	Если Не ЗначениеЗаполнено(pPeriod) Тогда
		pPeriod = '39991231235959';
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pHotel) Тогда
		pHotel = ПараметрыСеанса.ТекущаяГостиница;
	КонецЕсли;
	// Get Контрагент/contract currency
	rCurrency = pCustomer.ВалютаРасчетов;
	Если ЗначениеЗаполнено(pContract) Тогда
		rCurrency = pContract.ВалютаРасчетов;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(rCurrency) Тогда
		Возврат vBalance;
	КонецЕсли;
	// 1. Get Контрагент accounting balance
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CustomerAccountsBalance.ВалютаРасчетов,
	|	SUM(CustomerAccountsBalance.SumBalance) AS SumBalance
	|FROM
	|	AccumulationRegister.ВзаиморасчетыКонтрагенты.Balance(
	|			&qPeriod,
	|			Контрагент = &qCustomer " + 
					?(ЗначениеЗаполнено(pContract), "AND Договор = &qContract ", "") + "
	|				AND Гостиница = &qHotel) AS CustomerAccountsBalance
	|GROUP BY
	|	CustomerAccountsBalance.ВалютаРасчетов";
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPeriod", pPeriod);
	vAccountingBalances = vQry.Execute().Unload();
	Для каждого vAccountingBalancesRow из vAccountingBalances Цикл
		Если vAccountingBalancesRow.AccountingCurrency <> rCurrency Тогда
			vBalance = vBalance + cmConvertCurrencies(vAccountingBalancesRow.SumBalance, vAccountingBalancesRow.AccountingCurrency, , rCurrency, , CurrentDate(), pHotel);
		Иначе
			vBalance = vBalance + vAccountingBalancesRow.SumBalance;
		КонецЕсли;
	КонецЦикла;
	// 2. Add Контрагент current accounts receivable balance
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета, 
	|	SUM(CurrentAccountsReceivableBalance.SumBalance - CurrentAccountsReceivableBalance.CommissionSumBalance) AS SumBalance
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|			&qPeriod,
	|			Контрагент = &qCustomer " + 
					?(ЗначениеЗаполнено(pContract), "AND Договор = &qContract ", "") + "
	|				AND Гостиница = &qHotel) AS CurrentAccountsReceivableBalance
	|GROUP BY
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета";
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPeriod", pPeriod);
	vCurrentAccountsReceivableBalances = vQry.Execute().Unload();
	Для каждого vCurrentAccountsReceivableBalancesRow из vCurrentAccountsReceivableBalances Цикл
		Если vCurrentAccountsReceivableBalancesRow.FolioCurrency <> rCurrency Тогда
			vBalance = vBalance + cmConvertCurrencies(vCurrentAccountsReceivableBalancesRow.SumBalance, vCurrentAccountsReceivableBalancesRow.FolioCurrency, , rCurrency, , CurrentDate(), pHotel);
		Иначе
			vBalance = vBalance + vCurrentAccountsReceivableBalancesRow.SumBalance;
		КонецЕсли;
	КонецЦикла;
	// 3. Add Контрагент planned services turnover
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	SalesForecastTurnovers.Валюта,
	|	SUM(SalesForecastTurnovers.SalesTurnover - SalesForecastTurnovers.CommissionSumTurnover) AS SalesTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Контрагент = &qCustomer " +  
					?(ЗначениеЗаполнено(pContract), "AND Договор = &qContract ", "") + "
	|				AND Гостиница = &qHotel) AS SalesForecastTurnovers
	|GROUP BY
	|	SalesForecastTurnovers.Валюта";
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPeriodFrom", '00010101');
	vQry.SetParameter("qPeriodTo", '00010101');
	vPlannedServicesTurnovers = vQry.Execute().Unload();
	Для каждого vPlannedServicesTurnoversRow из vPlannedServicesTurnovers Цикл
		Если vPlannedServicesTurnoversRow.ReportingCurrency <> rCurrency Тогда
			vBalance = vBalance + cmConvertCurrencies(vPlannedServicesTurnoversRow.SalesTurnover, vPlannedServicesTurnoversRow.ReportingCurrency, , rCurrency, , CurrentDate(), pHotel);
		Иначе
			vBalance = vBalance + vPlannedServicesTurnoversRow.SalesTurnover;
		КонецЕсли;
	КонецЦикла;
	// Возврат balance
	Возврат vBalance;
КонецФункции //cmCalculateCustomerOperationalBalance

//-----------------------------------------------------------------------------
// Description: Calculates and returns agent commission amount for the given period
// Parameters: Agent, Контрагент, Contract, Гостиница, Begin of period, End of period, Currency
// Возврат value: Number
//-----------------------------------------------------------------------------
Функция cmCalculateAgentCommissionTurnovers(pAgent, pCustomer, pContract = Неопределено, pHotel = Неопределено, Val pPeriodFrom = Неопределено, Val pPeriodTo = Неопределено, rCurrency = Неопределено) Экспорт
	vCommissionTurnover = 0;
	// Check parameters
	Если Не ЗначениеЗаполнено(pAgent) Тогда
		Возврат vCommissionTurnover;
	КонецЕсли;
	// Initialize parameters
	Если Не ЗначениеЗаполнено(pPeriodFrom) Тогда
		pPeriodFrom = '00010101';
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pPeriodTo) Тогда
		pPeriodTo = '00010101';
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pHotel) Тогда
		pHotel = ПараметрыСеанса.ТекущаяГостиница;
	КонецЕсли;
	// Get Контрагент/contract currency
	rCurrency = pAgent.ВалютаРасчетов;
	Если ЗначениеЗаполнено(pContract) Тогда
		rCurrency = pContract.ВалютаРасчетов;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(rCurrency) Тогда
		Возврат vCommissionTurnover;
	КонецЕсли;
	// 1. Get Контрагент commission turnover
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	SalesTurnovers.Валюта,
	|	SUM(SalesTurnovers.CommissionSumTurnover) AS CommissionSumTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Агент = &qAgent " + 
					?(ЗначениеЗаполнено(pCustomer), "AND ДокОснование.Контрагент = &qCustomer ", "") + 
					?(ЗначениеЗаполнено(pContract), "AND ДокОснование.Договор = &qContract ", "") + "
	|				AND Гостиница = &qHotel) AS SalesTurnovers
	|GROUP BY
	|	SalesTurnovers.Валюта";
	vQry.SetParameter("qAgent", pAgent);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vServicesTurnovers = vQry.Execute().Unload();
	Для каждого vServicesTurnoversRow из vServicesTurnovers Цикл
		Если vServicesTurnoversRow.ReportingCurrency <> rCurrency Тогда
			vCommissionTurnover = vCommissionTurnover + cmConvertCurrencies(vServicesTurnoversRow.CommissionSumTurnover, vServicesTurnoversRow.ReportingCurrency, , rCurrency, , CurrentDate(), pHotel);
		Иначе
			vCommissionTurnover = vCommissionTurnover + vServicesTurnoversRow.CommissionSumTurnover;
		КонецЕсли;
	КонецЦикла;
	// 2. Add Контрагент planned services commission turnover
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	SalesForecastTurnovers.Валюта,
	|	SUM(SalesForecastTurnovers.CommissionSumTurnover) AS CommissionSumTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Агент = &qAgent " + 
					?(ЗначениеЗаполнено(pCustomer), "AND ДокОснование.Контрагент = &qCustomer ", "") + 
					?(ЗначениеЗаполнено(pContract), "AND ДокОснование.Договор = &qContract ", "") + "
	|				AND Гостиница = &qHotel) AS SalesForecastTurnovers
	|GROUP BY
	|	SalesForecastTurnovers.Валюта";
	vQry.SetParameter("qAgent", pAgent);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vPlannedServicesTurnovers = vQry.Execute().Unload();
	Для каждого vPlannedServicesTurnoversRow из vPlannedServicesTurnovers Цикл
		Если vPlannedServicesTurnoversRow.ReportingCurrency <> rCurrency Тогда
			vCommissionTurnover = vCommissionTurnover + cmConvertCurrencies(vPlannedServicesTurnoversRow.CommissionSumTurnover, vPlannedServicesTurnoversRow.ReportingCurrency, , rCurrency, , CurrentDate(), pHotel);
		Иначе
			vCommissionTurnover = vCommissionTurnover + vPlannedServicesTurnoversRow.CommissionSumTurnover;
		КонецЕсли;
	КонецЦикла;
	// Возврат commission turnover
	Возврат vCommissionTurnover;
КонецФункции //cmCalculateAgentCommissionTurnovers

//-----------------------------------------------------------------------------
// Description: Creates new or returns existing client identification card by card identifier
// Parameters: Card identifier, Card reference, ЛицевойСчет, Client, ГруппаНомеров, Check-in date, Check-out date, Whether to create new card or not
// Возврат value: Client identification card reference
//-----------------------------------------------------------------------------
Функция cmGetClientIdentificationCard(pIdentifier, pIDCardRef, pParentDoc, pFolio, pClient, pRoom, pDateTimeFrom, pDateTimeTo, pAdd = Истина, pCardUID = Неопределено, pUseDeleted = Ложь) Экспорт
	vIDCardRef = Справочники.КартаИД.EmptyRef();
	// Get list of cards for the current folio
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	КартаИД.Ref,
	|	КартаИД.Code AS Code,
	|	КартаИД.Description,
	|	КартаИД.IsBlocked,
	|	КартаИД.IsCheckedOut,
	|	КартаИД.Identifier,
	|	КартаИД.ДокОснование,
	|	КартаИД.СчетПроживания,
	|	КартаИД.ГруппаГостей,
	|	КартаИД.Клиент,
	|	КартаИД.НомерРазмещения,
	|	КартаИД.DateTimeFrom,
	|	КартаИД.DateTimeTo,
	|	КартаИД.Гостиница,
	|	КартаИД.BlockReason
	|FROM
	|	Catalog.КартаИД AS КартаИД
	|WHERE
	|	(&qUseDeleted
	|			OR NOT &qUseDeleted
	|				AND NOT КартаИД.DeletionMark)
	|	AND NOT КартаИД.IsBlocked
	|	AND (КартаИД.СчетПроживания = &qFolio
	|				AND &qFolioIsNotEmpty
	|			OR КартаИД.ДокОснование = &qParentDoc
	|				AND &qParentDocIsNotEmpty)
	|
	|ORDER BY
	|	Code";
	vQry.SetParameter("qUseDeleted", pUseDeleted);
	vQry.SetParameter("qFolio", pFolio);
	vQry.SetParameter("qFolioIsNotEmpty", ЗначениеЗаполнено(pFolio));
	vQry.SetParameter("qParentDoc", pParentDoc);
	vQry.SetParameter("qParentDocIsNotEmpty", ЗначениеЗаполнено(pParentDoc));
	vCards = vQry.Execute().Unload();
	Если ЗначениеЗаполнено(pFolio) И (pAdd или vCards.Count() = 0) Тогда
		// Create new client identification card
		Если ЗначениеЗаполнено(pIDCardRef) Тогда
			vIDCardObj = pIDCardRef.GetObject();
		Иначе
			vIDCardObj = Справочники.КартаИД.CreateItem();
			vIDCardObj.SetNewCode();
		КонецЕсли;
		vIDCardObj.Description = ?(ЗначениеЗаполнено(pClient), СокрЛП(pClient.FullName), "");
		Если ЗначениеЗаполнено(pIdentifier) Тогда
			vIDCardObj.Identifier = pIdentifier;
		Иначе
			vIDCardObj.Identifier = Format(cmCastToNumber(vIDCardObj.Code), "ND=12; NFD=0; NZ=; NLZ=; NG=");
		КонецЕсли;
		vIDCardObj.СчетПроживания = pFolio;
		vIDCardObj.ДокОснование = pParentDoc;
		vIDCardObj.ГруппаГостей = pFolio.ГруппаГостей;
		vIDCardObj.Клиент = pClient;
		vIDCardObj.НомерРазмещения = pRoom;
		vIDCardObj.DateTimeFrom = pDateTimeFrom;
		vIDCardObj.DateTimeTo = pDateTimeTo;
		vIDCardObj.IsBlocked = Ложь;
		vIDCardObj.BlockReason = "";
		vIDCardObj.IsCheckedOut = pFolio.IsClosed;
		vIDCardObj.Гостиница = pFolio.Гостиница;
		Если pCardUID <> Неопределено Тогда
			vIDCardObj.CardUID = СокрЛП(pCardUID);
		КонецЕсли;
		vIDCardObj.Автор = ПараметрыСеанса.ТекПользователь;
		vIDCardObj.CreateDate = CurrentDate();
		vIDCardObj.DeletionMark = Ложь;
		vIDCardObj.Write();
		// Get ref
		vIDCardRef = vIDCardObj.Ref;
	Иначе
		Если vCards.Count() > 0 Тогда
			vIDCardRef = vCards.Get(0).Ref;
			Если vIDCardRef.DeletionMark Тогда
				vIDCardObj = vIDCardRef.GetObject();
				vIDCardObj.SetDeletionMark(Ложь);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vIDCardRef;
КонецФункции //cmGetClientIdentificationCard

//-----------------------------------------------------------------------------
// Description: Функция tries to find and return client identification card by card identifier
// Parameters: Card identifier
// Возврат value: Client identification card reference or empty reference
//-----------------------------------------------------------------------------
Функция cmGetClientIdentificationCardById(pIdentifier, pUseDeleted = Ложь) Экспорт
	vCardRef = Справочники.КартаИД.EmptyRef();
	// Try to find client identification card by identifier
	vQry =  Новый Query();
	vQry.Text = 
	"SELECT
	|	КартаИД.Ref
	|FROM
	|	Catalog.КартаИД AS КартаИД
	|WHERE
	|	(&qUseDeleted
	|			OR NOT &qUseDeleted
	|				AND NOT КартаИД.DeletionMark)
	|	AND КартаИД.Identifier = &qIdentifier
	|
	|ORDER BY
	|	КартаИД.CreateDate DESC,
	|	КартаИД.Code DESC";
	vQry.SetParameter("qUseDeleted", pUseDeleted);
	vQry.SetParameter("qIdentifier", СокрЛП(pIdentifier));
	vCards = vQry.Execute().Unload();
	Если vCards.Count() > 0 Тогда
		vCardRef = vCards.Get(0).Ref;
	КонецЕсли;
	Возврат vCardRef;
КонецФункции //cmGetClientIdentificationCardById

//-----------------------------------------------------------------------------
// Description: Builds client identification card identifier from the data being read from the card
// Parameters: Data being read from the card
// Возврат value: String, card identifier
//-----------------------------------------------------------------------------
Функция cmGetCardIdentifier(pCardData) Экспорт
	vCardID = pCardData;
	Если StrLen(pCardData) > 4 Тогда
		// Remove prefix and suffix chars
		Если Right(pCardData, 3) = "+++" Тогда
			vCardID = Mid(СокрЛП(pCardData), 2);
			vCardID = Left(vCardID, StrLen(vCardID) - 3);
		ИначеЕсли Right(pCardData, 2) = "?," Тогда
			vCardID = Mid(СокрЛП(pCardData), 2);
			vCardID = Left(vCardID, StrLen(vCardID) - 2);
		ИначеЕсли CharCode(Left(pCardData, 1)) = 1110 И CharCode(Mid(pCardData, 14, 1)) = 191 Тогда
			vCardID = Mid(pCardData, 2, 12);
		ИначеЕсли CharCode(Left(pCardData, 1)) = 186 И CharCode(Mid(pCardData, 14, 1)) = 191 Тогда
			vCardID = Mid(pCardData, 2, 12);
		ИначеЕсли Left(pCardData, 1) = ";" И Mid(pCardData, 14, 1) = "?" Тогда
			vCardID = Mid(pCardData, 2, 12);
		ИначеЕсли Upper(Right(pCardData, 7)) = "NO CARD" И StrLen(СокрЛП(pCardData)) > 7 Тогда
			vCardID = СокрЛП(Left(СокрЛП(pCardData), StrLen(СокрЛП(pCardData)) - 7));
		КонецЕсли;
	Иначе
		vCardID = "";
	КонецЕсли;
	Возврат vCardID;
КонецФункции //cmGetCardIdentifier	

//-----------------------------------------------------------------------------
// Description: Returns value table with client identification cards by folio
// Parameters: ЛицевойСчет
// Возврат value: Value table with client identification cards
//-----------------------------------------------------------------------------
Функция cmGetClientIdentificationCardsByFolio(pFolio) Экспорт
	// Try to find client identification cards by folio
	vQry =  Новый Query();
	vQry.Text = 
	"SELECT
	|	КартаИД.Ref
	|FROM
	|	Catalog.КартаИД AS КартаИД
	|WHERE
	|	(NOT КартаИД.DeletionMark)
	|	AND КартаИД.СчетПроживания = &qFolio
	|ORDER BY
	|	Code";
	vQry.SetParameter("qFolio", pFolio);
	vCards = vQry.Execute().Unload();
	Возврат vCards;
КонецФункции //cmGetClientIdentificationCardsByFolio

//-----------------------------------------------------------------------------
// Description: Returns value table with client identification cards by parent document
// Parameters: Parent document (accommodation, reservation, resource reservation, set ГруппаНомеров quota)
// Возврат value: Value table with client identification cards
//-----------------------------------------------------------------------------
Функция cmGetClientIdentificationCardsByParentDoc(pParentDoc, pAll = Ложь) Экспорт
	// Try to find client identification cards by parent doc
	vQry =  Новый Query();
	vQry.Text = 
	"SELECT
	|	КартаИД.Ref
	|FROM
	|	Catalog.КартаИД AS КартаИД
	|WHERE
	|	(NOT КартаИД.DeletionMark OR &qAll)
	|	AND КартаИД.ДокОснование = &qParentDoc
	|ORDER BY
	|	Code";
	vQry.SetParameter("qParentDoc", pParentDoc);
	vQry.SetParameter("qAll", pAll);
	vCards = vQry.Execute().Unload();
	Возврат vCards;
КонецФункции //cmGetClientIdentificationCardsByParentDoc

//-----------------------------------------------------------------------------
// Description: Returns value table with client identification cards by ГруппаНомеров
// Parameters: ГруппаНомеров item reference
// Возврат value: Value table with client identification cards
//-----------------------------------------------------------------------------
Функция cmGetClientIdentificationCardsByRoom(pRoom, pAll = Ложь) Экспорт
	// Try to find client identification cards by parent doc
	vQry =  Новый Query();
	vQry.Text = 
	"SELECT
	|	КартаИД.Ref
	|FROM
	|	Catalog.КартаИД AS КартаИД
	|WHERE
	|	(NOT КартаИД.DeletionMark
	|			OR &qAll)
	|	AND КартаИД.НомерРазмещения = &qRoom
	|
	|ORDER BY
	|	КартаИД.Code";
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qAll", pAll);
	vCards = vQry.Execute().Unload();
	Возврат vCards;
КонецФункции //cmGetClientIdentificationCardsByRoom

//-----------------------------------------------------------------------------
// Description: Returns charging folio for given document and service
// Parameters: Reference to accommodation, reservation, resource reservation or 
//             set ГруппаНомеров quota document, Service reference
// Возврат value: ЛицевойСчет reference
//-----------------------------------------------------------------------------
Функция cmGetDocumentChargingFolioForService(pDoc, pService, pDate) Экспорт
	vFolio = Неопределено;
	Если TypeOf(pDoc) = Type("DocumentRef.Размещение") или
	   TypeOf(pDoc) = Type("DocumentRef.Бронирование") Тогда
		vChargingRules = pDoc.ChargingRules.Unload();
		cmAddGuestGroupChargingRules(vChargingRules, pDoc.ГруппаГостей);
		Для каждого vCRRow из vChargingRules Цикл
			Если cmIsServiceFitToTheChargingRule(vCRRow, pService, BegOfDay(pDate), Ложь, Ложь) Тогда
				vFolio = vCRRow.ChargingFolio;
				Break;
			КонецЕсли;
		КонецЦикла;
	ИначеЕсли TypeOf(pDoc) = Type("DocumentRef.БроньУслуг") Тогда
		vFolio = pDoc.ChargingFolio;
	ИначеЕсли TypeOf(pDoc) = Type("DocumentRef.СоставКвоты") Тогда
		vFolio = pDoc.ChargingFolio;
	КонецЕсли;
	Возврат vFolio;
КонецФункции //cmGetDocumentChargingFolioForService 

//-----------------------------------------------------------------------------
// Description: Returns service by service code
// Parameters: Service code
// Возврат value: Service reference
//-----------------------------------------------------------------------------
Функция cmGetServiceByCode(pServiceCode) Экспорт
	vService = Справочники.Услуги.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Услуги.Ref
	|FROM
	|	Catalog.Услуги AS Услуги
	|WHERE
	|	Услуги.Code = &qCode
	|	AND (NOT Услуги.DeletionMark)
	|	AND (NOT Услуги.IsFolder)";
	vQry.SetParameter("qCode", pServiceCode);
	vServices = vQry.Execute().Unload();
	Если vServices.Count() > 0 Тогда
		vService = vServices.Get(0).Ref;
	КонецЕсли;
	Возврат vService;
КонецФункции //cmGetServiceByCode

//-----------------------------------------------------------------------------
// Description: Returns list of service groups with service given
// Parameters: Service
// Возврат value: Value list of service groups
//-----------------------------------------------------------------------------
Функция cmGetListOfServiceServiceGroups(pService) Экспорт
	vServiceGroupsList = Новый СписокЗначений();
	// Run query to find all service groups with service choosen
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ServiceGroupsServices.Ref AS ServiceGroup
	|FROM
	|	Catalog.НаборыУслуг.Услуги AS ServiceGroupsServices
	|WHERE
	|	(NOT ServiceGroupsServices.Ref.DeletionMark)
	|	AND (NOT ServiceGroupsServices.Ref.IsFolder)
	|	AND ServiceGroupsServices.Услуга = &qService
	|GROUP BY
	|	ServiceGroupsServices.Ref
	|ORDER BY
	|	ServiceGroupsServices.Ref.ПорядокСортировки";
	vQry.SetParameter("qService", pService);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Цикл
		vServiceGroupsList.Add(vQryRes.ServiceGroup);
	КонецЦикла;
	Возврат vServiceGroupsList;
КонецФункции //cmGetListOfServiceServiceGroups

//-----------------------------------------------------------------------------
// Description: Returns list of contracts valid for the given period
// Parameters: Контрагент, Begin of period, End of period
// Возврат value: Value list of contracts
//-----------------------------------------------------------------------------
Функция cmGetListOfValidContracts(pOwner, pPeriodFrom = '00010101', pPeriodTo = '00010101', pCreateDate = '00010101') Экспорт
	// Build list of valid contracts
	vValidContracts = Новый СписокЗначений();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Договора.Ref
	|FROM
	|	Catalog.Договора AS Contracts
	|WHERE
	|	(Договора.Owner = &qOwner
	|			OR &qOwnerIsEmpty)
	|	AND (NOT Договора.DeletionMark)
	|	AND (Договора.PeriodCheckType = 0
	|				AND ((Договора.ValidFromDate <= &qPeriodFrom
	|						OR Договора.ValidFromDate = &qEmptyDate)
	|						AND (Договора.ValidToDate >= &qPeriodFrom
	|							OR Договора.ValidToDate = &qEmptyDate)
	|					OR &qPeriodFrom = &qEmptyDate)
	|				AND ((Договора.ValidFromDate <= &qPeriodTo
	|						OR Договора.ValidFromDate = &qEmptyDate)
	|						AND (Договора.ValidToDate >= &qPeriodTo
	|							OR Договора.ValidToDate = &qEmptyDate)
	|					OR &qPeriodTo = &qEmptyDate)
	|			OR Договора.PeriodCheckType = 1
	|				AND (Договора.ValidFromDate <= &qCreateDate
	|					OR Договора.ValidFromDate = &qEmptyDate
	|					OR &qCreateDate = &qEmptyDate)
	|				AND (Договора.ValidToDate >= &qCreateDate
	|					OR Договора.ValidToDate = &qEmptyDate
	|					OR &qCreateDate = &qEmptyDate))
	|
	|ORDER BY
	|	Договора.Description";
	vQry.SetParameter("qOwner", pOwner);
	vQry.SetParameter("qOwnerIsEmpty", Не ЗначениеЗаполнено(pOwner));
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qCreateDate", pCreateDate);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Цикл
		vValidContracts.Add(vQryRes.Ref);
	КонецЦикла;
	Возврат vValidContracts;
КонецФункции //cmGetListOfValidContracts

//-----------------------------------------------------------------------------
// Description: Returns first transaction for the given folio
// Parameters: ЛицевойСчет
// Возврат value: Refrence to the charge/payment
//-----------------------------------------------------------------------------
Функция cmGetFirstFolioTransaction(pFolio) Экспорт
	vTran = Неопределено;
	vQry =  Новый Query();
	vQry.Text = 
	"SELECT TOP 1
	|	Взаиморасчеты.Recorder
	|FROM
	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
	|WHERE
	|	Взаиморасчеты.СчетПроживания = &qFolio
	|ORDER BY
	|	Взаиморасчеты.Period";
	vQry.SetParameter("qFolio", pFolio);
	vQryRes = vQry.Execute().Unload();
	Если vQryRes.Count() > 0 Тогда
		vTran = vQryRes.Get(0).Recorder;
	КонецЕсли;
	Возврат vTran;
КонецФункции //cmGetFirstFolioTransaction

//-----------------------------------------------------------------------------
// Description: Returns value table with one row with first folio transaction and 
//              last folio transaction dates specified
// Parameters: ЛицевойСчет
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetFirstLastFolioCharges(pFolio) Экспорт
	vQry =  Новый Query();
	vQry.Text = 
	"SELECT
	|	Взаиморасчеты.СчетПроживания AS СчетПроживания,
	|	MAX(Взаиморасчеты.Period) AS FolioChargeMaxDate,
	|	MIN(Взаиморасчеты.Period) AS FolioChargeMinDate
	|FROM
	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
	|WHERE
	|	Взаиморасчеты.СчетПроживания = &qFolio
	|	AND Взаиморасчеты.RecordType = &qReceipt
	|
	|GROUP BY
	|	Взаиморасчеты.СчетПроживания";
	vQry.SetParameter("qFolio", pFolio);
	vQry.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetFirstLastFolioCharges

//-----------------------------------------------------------------------------
// Description: Returns client with maximum amount of services charged for the given group
// Parameters: Guest group, Client
// Возврат value: Client reference
//-----------------------------------------------------------------------------
Функция cmGetHeadOfGroupClient(pGuestGroup, pClient, rClientDoc) Экспорт
	vHGClient = pClient;
	rClientDoc = Неопределено;
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT TOP 1
	|	SalesTurnovers.Клиент AS Клиент,
	|	SalesTurnovers.ДокОснование AS ДокОснование,
	|	SalesTurnovers.ВидРазмещения,
	|	ISNULL(SalesTurnovers.ДокОснование.IsMaster, FALSE) AS IsMaster,
	|	SalesTurnovers.RoomRevenueTurnover AS RoomRevenueTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(, , Period, ГруппаГостей = &qGuestGroup) AS SalesTurnovers
	|
	|ORDER BY
	|	IsMaster DESC,
	|	RoomRevenueTurnover DESC,
	|	SalesTurnovers.ВидРазмещения.ПорядокСортировки";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vTopClients = vQry.Execute().Unload();
	Если vTopClients.Count() > 0 Тогда
		vHGClient = vTopClients.Get(0).Клиент;
		rClientDoc = vTopClients.Get(0).ДокОснование;
	КонецЕсли;
	// Возврат
	Возврат vHGClient;
КонецФункции //cmGetHeadOfGroupClient

//-----------------------------------------------------------------------------
// Description: Returns minimum check-in date, maximum check-out date and number of guests for the given group
// Parameters: Guest group
// Возврат value: Value table with one row
//-----------------------------------------------------------------------------
Функция cmGetGroupPeriodANDGuestsCheckedIn(pGuestGroup) Экспорт
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	GroupProperties.ГруппаГостей,
	|	MIN(GroupProperties.CheckInDate) AS CheckInDate,
	|	MAX(GroupProperties.ДатаВыезда) AS ДатаВыезда,
	|	SUM(GroupProperties.ЗаездГостей) AS ЗаездГостей
	|FROM
	|	(SELECT
	|		ЗагрузкаНомеров.ГруппаГостей AS ГруппаГостей,
	|		ЗагрузкаНомеров.CheckInDate AS CheckInDate,
	|		ЗагрузкаНомеров.ДатаВыезда AS ДатаВыезда,
	|		ЗагрузкаНомеров.ЗаездГостей + ЗагрузкаНомеров.ExpectedGuestsCheckedIn AS ЗаездГостей
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|	WHERE
	|		ЗагрузкаНомеров.ГруппаГостей = &qGuestGroup
	|		AND ЗагрузкаНомеров.RecordType = &qExpense
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		Reservations.ГруппаГостей,
	|		Reservations.CheckInDate,
	|		Reservations.ДатаВыезда,
	|		Reservations.КоличествоЧеловек
	|	FROM
	|		Document.Бронирование AS Reservations
	|	WHERE
	|		Reservations.Posted
	|		AND Reservations.ГруппаГостей = &qGuestGroup
	|		AND (NOT Reservations.ReservationStatus.IsActive)
	|		AND Reservations.ReservationStatus.IsPreliminary) AS GroupProperties
	|
	|GROUP BY
	|	GroupProperties.ГруппаГостей";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vGroupParams = vQry.Execute().Unload();
	// Возврат
	Возврат vGroupParams;
КонецФункции //cmGetGroupPeriodИGuestsCheckedIn

//-----------------------------------------------------------------------------
// Description: Returns calendar day type for the given ГруппаНомеров rate and date
// Parameters: ГруппаНомеров rate, Date
// Возврат value: Calendar day type reference
//-----------------------------------------------------------------------------
Функция cmGetCalendarDayType(pRoomRate, pDate, pCheckInDate, pCheckOutDate) Экспорт
	vCalendarDayType = Справочники.ТипДневногоКалендаря.ПустаяСсылка();
	Если ЗначениеЗаполнено(pRoomRate) И ЗначениеЗаполнено(pRoomRate.Calendar) Тогда
		Если pCheckInDate <> Неопределено И pCheckOutDate <> Неопределено И pDate >= BegOfDay(pCheckInDate) И pDate <= pCheckOutDate Тогда
			vCalendarDays = СохранениеНастроек.cmGetCalendarDays(pRoomRate.Calendar, pCheckInDate, pCheckOutDate, pCheckInDate, pCheckOutDate);
			vCalendarDaysRow = vCalendarDays.Find(pDate, "Period");
			Если vCalendarDaysRow <> Неопределено Тогда
				vCalendarDayType = vCalendarDaysRow.ТипДняКалендаря;
			КонецЕсли;
		Иначе
			vCalendarDays = pRoomRate.Calendar.GetObject().pmGetDays(pDate, pDate, pCheckInDate, pCheckOutDate);
			Если vCalendarDays.Count() > 0 Тогда
				vCalendarDayType = vCalendarDays.Get(0).ТипДняКалендаря;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vCalendarDayType;
КонецФункции //cmGetCalendarDayType

//-----------------------------------------------------------------------------
// Description: Returns calendar day type for the given document (accommodation
//              or reservation) and date
// Parameters: Document object (Accommodation object or Reservation object), Date
// Возврат value: Calendar day type reference
//-----------------------------------------------------------------------------
Функция cmGetDocumentCalendarDayType(pDocObj, pDate) Экспорт
	vCalendarDayType = Справочники.CalendarDayTypes.EmptyRef();
	// Try to find accommodation services for the given accounting date
	vRIRows = pDocObj.Услуги.FindRows(Новый Structure("УчетнаяДата, IsRoomRevenue", pDate, Истина));
	Если vRIRows.Count() > 0 Тогда
		vRIRow = vRIRows.Get(0);
		vCalendarDayType = vRIRow.ТипДняКалендаря;
	КонецЕсли;
	// Если nothing was found then try to get calendar day type by ГруппаНомеров rate
	Если Не ЗначениеЗаполнено(vCalendarDayType) Тогда
		vRoomRate = pDocObj.Тариф;
		vRoomRatesRow = pDocObj.Тарифы.Find(pDate, "УчетнаяДата");
		Если vRoomRatesRow <> Неопределено И ЗначениеЗаполнено(vRoomRatesRow.Тариф) Тогда
			vRoomRate = vRoomRatesRow.Тариф;
		КонецЕсли;
		vCalendarDayType = cmGetCalendarDayType(vRoomRate, pDate, pDocObj.CheckInDate, pDocObj.ДатаВыезда);
	КонецЕсли;
	Возврат vCalendarDayType;
КонецФункции //cmGetDocumentCalendarDayType

//-----------------------------------------------------------------------------
// Description: Returns value table with folios locked by processing
// Parameters: Persistent objects structure
// Возврат value: Value table with list of locked folios
//-----------------------------------------------------------------------------
Функция cmGetLockedFolios(глЛичныеОбъекты) Экспорт
	vLockedFolios = Неопределено;
	глЛичныеОбъекты.Property("LockedFolios", vLockedFolios);
	Если vLockedFolios = Неопределено Тогда
		vLockedFolios = Новый ValueTable();
		vLockedFolios.Columns.Add("Ref");
		vLockedFolios.Columns.Add("СчетПроживания", cmGetDocumentTypeDescription("СчетПроживания"));
		vLockedFolios.Columns.Add("OldParentDoc");
		глЛичныеОбъекты.Вставить("LockedFolios", vLockedFolios);
	КонецЕсли;
	Возврат vLockedFolios;
КонецФункции //cmGetLockedFolios

//-----------------------------------------------------------------------------
// Description: Removes all document folios from the locked folios list
// Parameters: Accommodation/Reservation, Persistent objects structure
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmUnlockFoliosByRef(pObjectRef, глЛичныеОбъекты) Экспорт
	vLockedFolios = cmGetLockedFolios(глЛичныеОбъекты);
	vLockedFoliosRows = vLockedFolios.FindRows(Новый Structure("Ref", pObjectRef));
	Для каждого vLockedFoliosRow из vLockedFoliosRows Цикл
		Try
			vFolioObj = vLockedFoliosRow.СчетПроживания.GetObject();
			Если ЗначениеЗаполнено(vFolioObj.ДокОснование) И Не vFolioObj.ДокОснование.Posted Тогда
				Если ЗначениеЗаполнено(vLockedFoliosRow.OldParentDoc) И vFolioObj.ДокОснование <> vLockedFoliosRow.OldParentDoc Тогда
					vFolioObj.ДокОснование = vLockedFoliosRow.OldParentDoc;
					vFolioObj.Write(DocumentWriteMode.Write);
				КонецЕсли;
			КонецЕсли;
		Except
		EndTry;
		vLockedFolios.Delete(vLockedFoliosRow);
	КонецЦикла;
КонецПроцедуры //cmUnlockFoliosByRef

//-----------------------------------------------------------------------------
// Description: Adds all document folios to the locked folios list
// Parameters: Charging rules value table, Accommodation/Reservation, Persistent objects structure
// Возврат value: Whether folios were locked successfully or not
//-----------------------------------------------------------------------------
Функция cmLockChargingRules(pChargingRules, pObjectRef, глЛичныеОбъекты) Экспорт
	vFoliosAreLocked = Истина;
	vLockedFolios = cmGetLockedFolios(глЛичныеОбъекты);
	Для каждого vCRRow из pChargingRules Цикл
		Если ЗначениеЗаполнено(vCRRow.ChargingFolio) И ЗначениеЗаполнено(vCRRow.ChargingFolio.ДокОснование) Тогда
			Если Не vCRRow.IsTransfer Тогда
				Try
					vOldParentDoc = vCRRow.ChargingFolio.ДокОснование;
					// Update folio parent document
					vFolioObject = vCRRow.ChargingFolio.GetObject();
					vFolioObject.ДокОснование = pObjectRef;
					vFolioObject.Write(DocumentWriteMode.Write);
					// Save this folio as locked by the current user session
					vLockedFoliosRows = vLockedFolios.FindRows(Новый Structure("Ref, СчетПроживания", pObjectRef, vCRRow.ChargingFolio));
					Если vLockedFoliosRows.Count() = 0 Тогда
						vLockedFoliosRow = vLockedFolios.Add();
						vLockedFoliosRow.Ref = pObjectRef;
						vLockedFoliosRow.СчетПроживания = vFolioObject.Ref;
						vLockedFoliosRow.OldParentDoc = vOldParentDoc;
					КонецЕсли;
				Except
					vFoliosAreLocked = Ложь;
					Break;
				EndTry;
			КонецЕсли;
		Иначе
			vFoliosAreLocked = Ложь;
			Break;
		КонецЕсли;
	КонецЦикла;
	Если Не vFoliosAreLocked Тогда
		cmUnlockFoliosByRef(pObjectRef, глЛичныеОбъекты);
	КонецЕсли;
	Возврат vFoliosAreLocked;
КонецФункции //cmLockChargingRules

//-----------------------------------------------------------------------------
// Description: Calculates minimum and maximum accounting dates for the given folio, accommodation/reservation
// Parameters: ЛицевойСчет, Accommodation/Reservation, Minimum transaction date to be calculated, Maximum transaction date to be calculated
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmGetServicesPeriodByFolio(pFolio, pDoc, rDateFrom, rDateTo) Экспорт
	Если ЗначениеЗаполнено(pFolio) Тогда
		rDateFrom = pFolio.DateTimeFrom;
		rDateTo = pFolio.DateTimeTo;
		Если pDoc.Услуги.Count() > 0 Тогда
			// Try to get min/max dates from folio charges
			vFirstLastCharges = cmGetFirstLastFolioCharges(pFolio);
			// Try to get min/max dates from services in the document
			vServices = pDoc.Услуги.Unload();
			vServices.Sort("УчетнаяДата");
			vRowsByFolio = vServices.FindRows(Новый Structure("СчетПроживания", pFolio));
			Если vRowsByFolio.Count() > 0 Тогда
				rDateFrom = vRowsByFolio.Get(0).УчетнаяДата;
				rDateTo = vRowsByFolio.Get(vRowsByFolio.Count()-1).УчетнаяДата;
				// Compare with first last folio charge dates
				Если vFirstLastCharges.Count() > 0 Тогда
					vFirstLastChargesRow = vFirstLastCharges.Get(0);
					Если ЗначениеЗаполнено(vFirstLastChargesRow.FolioChargeMaxDate) И 
					   ЗначениеЗаполнено(vFirstLastChargesRow.FolioChargeMinDate) Тогда
						Если BegOfDay(vFirstLastChargesRow.FolioChargeMinDate) = BegOfDay(rDateFrom) И 
						   ЗначениеЗаполнено(pFolio.DateTimeFrom) Тогда
							rDateFrom = pFolio.DateTimeFrom;
						КонецЕсли;
						Если BegOfDay(vFirstLastChargesRow.FolioChargeMaxDate) = BegOfDay(rDateTo) И 
						   ЗначениеЗаполнено(pFolio.DateTimeTo) Тогда
							rDateTo = pFolio.DateTimeTo;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmGetServicesPeriodByFolio

//-----------------------------------------------------------------------------
// Description: Calculates coupon barcode
// Parameters: Type of document as number: 1 - Charge, 2 - Reservation, 3 - Resource reservation
//             Document number
//             Service
// Возврат value: Coupon number as string
//-----------------------------------------------------------------------------
Функция cmBuildCouponBarCode(pType, pNumber, pService, pDate, pQuantity) Экспорт
	vDocTypeStr = Format(pType, "ND=1; NFD=0; NZ=; NLZ=; NG=");
	vDocNumberStr = Format(Number(cmGetDocumentNumberPresentation(СокрЛП(pNumber))), "ND=9; NFD=0; NZ=; NLZ=; NG=");
	Try
		vSrvCodeStr = Format(Number(СокрЛП(pService.Code)), "ND=5; NFD=0; NZ=; NLZ=; NG=");
	Except
		ВызватьИсключение NStr("en='Numbered service codes are supported only!';ru='Поддерживаются только числовые коды услуг!';de='Nur Zahlencodes der Dienstleistungen werden unterstützt!'");
	EndTry;
	vDayNumStr = Format((BegOfDay(pDate) - '20100101')/(24*3600), "ND=4; NFD=0; NZ=; NLZ=; NG=");
	vQuantityStr = Format(pType, "ND=3; NFD=0; NZ=; NLZ=; NG=");
	vCouponBarCode = "C" + vDocTypeStr + vDocNumberStr + vSrvCodeStr + vDayNumStr + vQuantityStr + "P";
	Возврат vCouponBarCode;
КонецФункции //cmBuildCouponBarCode

//-----------------------------------------------------------------------------
// Description: Parses coupon barcode
// Parameters: String, coupon barcode
// Возврат value: Structure with fields: AccountingDate, Service, GuestGroup, ГруппаНомеров, Resource, 
//                                      Client, Quantity, ЛицевойСчет, Recorder, GuestGroup
//-----------------------------------------------------------------------------
Функция cmParseCouponBarCode(pCouponBarCode, pHotel) Экспорт
	// Initialize structure
	vStruct = Новый Structure("УчетнаяДата, Услуга, НомерРазмещения, Ресурс, Клиент, Количество, СчетПроживания, Recorder, ГруппаГостей");
	// Normalize barcode
	pCouponBarCode = СокрЛП(pCouponBarCode);
	Если Upper(Left(pCouponBarCode, 1)) <> "C" И Upper(Right(pCouponBarCode, 1)) <> "P" Тогда
		pCouponBarCode = "C" + pCouponBarCode + "P";
	КонецЕсли;
	// Parse barcode
	vDocType = Number(Mid(pCouponBarCode, 2, 1));
	vDocNumber = cmGetDocumentNumberFromPresentation(Mid(pCouponBarCode, 3, 9), pHotel);
	vSrvCode = Format(Number(Mid(pCouponBarCode, 12, 5)), "ND=5; NFD=0; NZ=; NG=");
	vService = Справочники.Услуги.FindByCode(vSrvCode);
	vAccountingDate = '20100101' + Number(Mid(pCouponBarCode, 17, 5))*24*3600;
	vQuantity = Number(Mid(pCouponBarCode, 22, 3));
	// Get document, folio and client
	vGuestGroup = Справочники.ГруппыГостей.EmptyRef();
	vRoom = Справочники.Clients.EmptyRef();
	vResource = Справочники.Ресурсы.EmptyRef();
	vClient = Справочники.Clients.EmptyRef();
	vRecorder = Неопределено;
	vFolio = Documents.СчетПроживания.EmptyRef();
	Если vDocType = 1 Тогда // Charge
		vRecorder = Documents.Начисление.FindByNumber(vDocNumber, vAccountingDate);
		Если ЗначениеЗаполнено(vRecorder) Тогда
			vFolio = vRecorder.СчетПроживания;
			Если ЗначениеЗаполнено(vRecorder.ДокОснование) Тогда
				Если TypeOf(vRecorder.ДокОснование) = Type("DocumentRef.Размещение") или TypeOf(vRecorder.ДокОснование) = Type("DocumentRef.Бронирование") Тогда
					vClient = vRecorder.ДокОснование.Клиент;
					vRoom = vRecorder.ДокОснование.НомерРазмещения;
					vGuestGroup = vRecorder.ДокОснование.ГруппаГостей;
				ИначеЕсли TypeOf(vRecorder.ДокОснование) = Type("DocumentRef.БроньУслуг") Тогда
					vClient = vRecorder.ДокОснование.Клиент;
					vResource = vRecorder.ДокОснование.vResource;
					vGuestGroup = vRecorder.ДокОснование.ГруппаГостей;
				КонецЕсли;
			Иначе
				vClient = vFolio.Клиент;
				vRoom = vFolio.НомерРазмещения;
				vGuestGroup = vFolio.ГруппаГостей;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли vDocType = 2 Тогда // Reservation
		vRecorder = Documents.Бронирование.FindByNumber(vDocNumber, vAccountingDate);
		Если ЗначениеЗаполнено(vRecorder) Тогда
			vClient = vRecorder.Клиент;
			vRoom = vRecorder.НомерРазмещения;
			vGuestGroup = vRecorder.ГруппаГостей;
			vSrvRows = vRecorder.Услуги.FindRows(Новый Structure("Услуга, УчетнаяДата", vService, vAccountingDate));
			Если vSrvRows.Count() > 0 Тогда
				vSrvRow = vSrvRows.Get(0);
				vFolio = vSrvRow.СчетПроживания;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли vDocType = 3 Тогда // Resource reservation
		vRecorder = Documents.БроньУслуг.FindByNumber(vDocNumber, vAccountingDate);
		Если ЗначениеЗаполнено(vRecorder) Тогда
			vClient = vRecorder.Клиент;
			vResource = vRecorder.Ресурс;
			vFolio = vRecorder.ChargingFolio;
			vGuestGroup = vRecorder.ГруппаГостей;
		КонецЕсли;
	КонецЕсли;
	// Fill structure
	vStruct.AccountingDate = vAccountingDate;
	vStruct.Service = vService;
	vStruct.ГруппаНомеров = vRoom;
	vStruct.Resource = vResource;
	vStruct.Client = vClient;
	vStruct.Quantity = vQuantity;
	vStruct.ЛицевойСчет = vFolio;
	vStruct.Recorder = vRecorder;
	vStruct.GuestGroup = vGuestGroup;
	// Возврат structure
	Возврат vStruct;
КонецФункции //cmParseCouponBarCode

//-----------------------------------------------------------------------------
// Description: Returns value table with employees allowed to perform service specified
// Parameters: Service, Date to be used to get valid performers
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetServicePerformers(pService, pDate, pHotel) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ServicePerformersSliceLast.Period,
	|	ServicePerformersSliceLast.Услуга,
	|	ServicePerformersSliceLast.Гостиница,
	|	ServicePerformersSliceLast.Employee
	|FROM
	|	РегистрСведений.ОтветстУслуги.SliceLast(
	|			&qDate,
	|			(Услуга = &qService
	|				OR Услуга = &qServiceParent
	|				OR Услуга = &qServiceParentParent
	|				OR Услуга = &qServiceParentParentParent)
	|				AND (Гостиница = &qHotel
	|					OR Гостиница = &qEmptyHotel)) AS ServicePerformersSliceLast
	|
	|ORDER BY
	|	ServicePerformersSliceLast.Услуга.ПорядокСортировки,
	|	ServicePerformersSliceLast.Услуга.Description,
	|	ServicePerformersSliceLast.Employee.ПорядокСортировки,
	|	ServicePerformersSliceLast.Employee.Description";
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qService", pService);
	Если ЗначениеЗаполнено(pService) Тогда
		vQry.SetParameter("qServiceParent", pService.Parent);
		Если ЗначениеЗаполнено(pService.Parent) Тогда
			vQry.SetParameter("qServiceParentParent", pService.Parent.Parent);
			Если ЗначениеЗаполнено(pService.Parent.Parent) Тогда
				vQry.SetParameter("qServiceParentParentParent", pService.Parent.Parent.Parent);
			Иначе
				vQry.SetParameter("qServiceParentParentParent", Неопределено);
			КонецЕсли;
		Иначе
			vQry.SetParameter("qServiceParentParent", Неопределено);
			vQry.SetParameter("qServiceParentParentParent", Неопределено);
		КонецЕсли;
	Иначе
		vQry.SetParameter("qServiceParent", Неопределено);
		vQry.SetParameter("qServiceParentParent", Неопределено);
		vQry.SetParameter("qServiceParentParentParent", Неопределено);
	КонецЕсли;
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	Возврат vQry.Execute().Unload();
КонецФункции //cmGetServicePerformers

//-----------------------------------------------------------------------------
// Description: Returns bound service for the given one
// Parameters: Service catalog item reference
// Возврат value: Bound service reference if defined or Неопределено otherwise
//-----------------------------------------------------------------------------
Функция cmGetBoundService(pService) Экспорт
	vBoundService = Неопределено;
	Если ЗначениеЗаполнено(pService) Тогда
		Если ЗначениеЗаполнено(pService.BoundService) Тогда
			vBoundService = pService.BoundService;
		Иначе
			// Check folders
			vParent = pService.Parent;
			While ЗначениеЗаполнено(vParent) Цикл
				Если ЗначениеЗаполнено(vParent.BoundService) Тогда
					vBoundService = vParent.BoundService;
					Break;
				КонецЕсли;
				vParent = vParent.Parent;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	Возврат vBoundService;
КонецФункции //cmGetBoundService

//-----------------------------------------------------------------------------
// Description: Returns boolean flag indicating that document (accommodation or reservation) 
//              Контрагент is payer for some ГруппаНомеров rate services
// Parameters: Document charging rules, Контрагент reference, Contract reference, Guest group reference
// Возврат value: Boolean, true - if Контрагент is payer for some services, false - if not
//-----------------------------------------------------------------------------
Функция cmCustomerIsPayer(pChargingRules, pCustomer, pContract, pGuestGroup) Экспорт
	cmAddGuestGroupChargingRules(pChargingRules, pGuestGroup);
	vCustomerIsPayer = Ложь;
	Если ЗначениеЗаполнено(pCustomer) И pChargingRules.Find(pCustomer, "Owner") <> Неопределено или 
	   ЗначениеЗаполнено(pContract) И pChargingRules.Find(pContract, "Owner") <> Неопределено Тогда
		Если Не pCustomer.DoNotPostCommission Тогда
			vCustomerIsPayer = Истина;
		КонецЕсли;
	КонецЕсли;
	Возврат vCustomerIsPayer;
КонецФункции //cmCustomerIsPayer 

//-----------------------------------------------------------------------------
// Description: Adds guest group charging rules to the document charging rules value table
// Parameters: Document charging rules, Guest group reference
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmAddGuestGroupChargingRules(pChargingRules, pGuestGroup) Экспорт
	Если ЗначениеЗаполнено(pGuestGroup) И pGuestGroup.ChargingRules.Count() > 0 Тогда
		Для каждого vGGCRRow из pGuestGroup.ChargingRules Цикл
			vCRRow = pChargingRules.Вставить(pGuestGroup.ChargingRules.IndexOf(vGGCRRow));
			FillPropertyValues(vCRRow, vGGCRRow);
			Если ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
				Если ЗначениеЗаполнено(vCRRow.ChargingFolio.Договор) Тогда
					vCRRow.Owner = vCRRow.ChargingFolio.Договор;
				ИначеЕсли ЗначениеЗаполнено(vCRRow.ChargingFolio.Контрагент) Тогда
					vCRRow.Owner = vCRRow.ChargingFolio.Контрагент;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры //cmAddGuestGroupChargingRules

//-----------------------------------------------------------------------------
// Description: returns hotel default credit limit
// Parameters: Гостиница item reference
// Возврат value: Credit limit
//-----------------------------------------------------------------------------
Функция cmGetDefaultCreditLimit(pHotel) Экспорт
	vCreditLimit = 0;
	Если ЗначениеЗаполнено(pHotel) Тогда
		Для каждого vCRRow из pHotel.ChargingRules Цикл
			Если ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
				Если vCRRow.ChargingFolio.CreditLimit <> 0 Тогда
					vCreditLimit = vCRRow.ChargingFolio.CreditLimit;
					Break;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Возврат vCreditLimit;
КонецФункции //cmGetDefaultCreditLimit

//-----------------------------------------------------------------------------
// Description: Returns value list of Контрагент account documents for guest group
// Parameters: Guest group reference
// Возврат value: СписокЗначений with document references
//-----------------------------------------------------------------------------
Функция cmGetGuestGroupAccountingDocuments(pGuestGroup) Экспорт
	vDocsList = Новый СписокЗначений();
	vQry = Новый Query();
	vQry.Text = "SELECT
	            |	CustomerDocs.Ref AS Ref
	            |FROM
	            |	(SELECT
	            |		РаспределениеАванса.Ref AS Ref
	            |	FROM
	            |		Document.РаспределениеАванса AS РаспределениеАванса
	            |	WHERE
	            |		РаспределениеАванса.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		CustomerAdvanceDistributionGuestGroups.Ref
	            |	FROM
	            |		Document.РаспределениеАванса.ГруппыГостей AS CustomerAdvanceDistributionGuestGroups
	            |	WHERE
	            |		CustomerAdvanceDistributionGuestGroups.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		Возврат.Ref
	            |	FROM
	            |		Document.Возврат AS Возврат
	            |	WHERE
	            |		Возврат.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		Платеж.Ref
	            |	FROM
	            |		Document.Платеж AS Платеж
	            |	WHERE
	            |		Платеж.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		CustomerPayments.Ref
	            |	FROM
	            |		Document.ПлатежКонтрагента AS CustomerPayments
	            |	WHERE
	            |		CustomerPayments.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		CustomerPaymentContracts.Ref
	            |	FROM
	            |		Document.ПлатежКонтрагента.Договора AS CustomerPaymentContracts
	            |	WHERE
	            |		CustomerPaymentContracts.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		Акт.Ref
	            |	FROM
	            |		Document.Акт AS Акт
	            |	WHERE
	            |		Акт.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		SettlementServices.Ref
	            |	FROM
	            |		Document.Акт.Услуги AS SettlementServices
	            |	WHERE
	            |		SettlementServices.ГруппаГостей = &qGuestGroup) AS CustomerDocs
	            |
	            |GROUP BY
	            |	CustomerDocs.Ref";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vDocs = vQry.Execute().Unload();
	Для каждого vDocsRow из vDocs Цикл
		vDocsList.Add(vDocsRow.Ref);
	КонецЦикла;
	Возврат vDocsList;
КонецФункции //cmGetGuestGroupAccountingDocuments

//-----------------------------------------------------------------------------
// Description: Returns value list of invoices for guest group
// Parameters: Guest group reference
// Возврат value: СписокЗначений with invoice references
//-----------------------------------------------------------------------------
Функция cmGetGuestGroupInvoices(pGuestGroup) Экспорт
	vDocsList = Новый СписокЗначений();
	vQry = Новый Query();
	vQry.Text = "SELECT
	            |	Invoices.Ref AS Ref
	            |FROM
	            |	(SELECT
	            |		СчетНаОплату.Ref AS Ref
	            |	FROM
	            |		Document.СчетНаОплату AS СчетНаОплату
	            |	WHERE
	            |		СчетНаОплату.ГруппаГостей = &qGuestGroup
	            |	
	            |	UNION ALL
	            |	
	            |	SELECT
	            |		InvoiceServices.Ref
	            |	FROM
	            |		Document.СчетНаОплату.Услуги AS InvoiceServices
	            |	WHERE
	            |		InvoiceServices.ГруппаГостей = &qGuestGroup) AS Invoices
	            |
	            |GROUP BY
	            |	Invoices.Ref";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vDocs = vQry.Execute().Unload();
	Для каждого vDocsRow из vDocs Цикл
		vDocsList.Add(vDocsRow.Ref);
	КонецЦикла;
	Возврат vDocsList;
КонецФункции //cmGetGuestGroupInvoices

//-----------------------------------------------------------------------------
// Description: Returns if this charge is closed by settllement. 
//              It is so if both SumBalance И QuantityBalance columns of the returned row are zero
// Parameters: Charge document reference
// Возврат value: Value table row with SumBalance and QuantityBalance fields
//-----------------------------------------------------------------------------
Функция cmGetChargeCurrentAccountsReceivableBalance(pCharge) Экспорт
	vChargeBalancesRow = Неопределено;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CurrentAccountsReceivableBalance.Начисление,
	|	CurrentAccountsReceivableBalance.SumBalance,
	|	CurrentAccountsReceivableBalance.QuantityBalance
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|			&qEmptyDate,
	|			Начисление = &qCharge) AS CurrentAccountsReceivableBalance";
	vQry.SetParameter("qCharge", pCharge);
	vQry.SetParameter("qEmptyDate", '00010101');
	vChargeBalances = vQry.Execute().Unload();
	Если vChargeBalances.Count() > 0 Тогда
		vChargeBalancesRow = vChargeBalances.Get(0);
	КонецЕсли;
	Возврат vChargeBalancesRow;
КонецФункции //cmGetChargeCurrentAccountsReceivableBalance 

//-----------------------------------------------------------------------------
// Description: Returns if this charge is in closed day. 
//              It is so if for charge Фирма and hotel there is close of period 
//              document with date greater or equal charge date
// Parameters: Charge document reference
// Возврат value: Истина or Ложь
//-----------------------------------------------------------------------------
Функция cmIfChargeIsInClosedDay(pCharge) Экспорт
	vHotel = pCharge.Гостиница;
	Если ЗначениеЗаполнено(vHotel) И vHotel.DoNotEditClosedDateDocs И 
	   ЗначениеЗаполнено(vHotel.УчетнаяДата) И 
	   pCharge.ДатаДок < BegOfDay(vHotel.УчетнаяДата) Тогда
		Возврат Истина;
	Иначе 
		Возврат Ложь;
	КонецЕсли;
КонецФункции //cmIfChargeIsInClosedDay

//-----------------------------------------------------------------------------
// Description: Returns if this document charges are closed by settllements. 
//              It is so if both SumBalance И QuantityBalance columns of the returned row are zero
// Parameters: Accommodation/Reservation/Resource reservation document reference
// Возврат value: Value table row with SumBalance and QuantityBalance fields
//-----------------------------------------------------------------------------
Функция cmGetDocumentCurrentAccountsReceivableBalance(pParentDoc) Экспорт
	vDocBalancesRow = Неопределено;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CurrentAccountsReceivableBalance.ДокОснование,
	|	CurrentAccountsReceivableBalance.SumBalance,
	|	CurrentAccountsReceivableBalance.QuantityBalance
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|			&qEmptyDate,
	|			ДокОснование = &qParentDoc) AS CurrentAccountsReceivableBalance";
	vQry.SetParameter("qParentDoc", pParentDoc);
	vQry.SetParameter("qEmptyDate", '00010101');
	vDocBalances = vQry.Execute().Unload();
	Если vDocBalances.Count() > 0 Тогда
		vDocBalancesRow = vDocBalances.Get(0);
	КонецЕсли;
	Возврат vDocBalancesRow;
КонецФункции //cmGetDocumentCurrentAccountsReceivableBalance

//-----------------------------------------------------------------------------
// Description: Returns if this ГруппаНомеров service document charges are closed by settllements. 
//              It is so if both SumBalance И QuantityBalance columns of the returned row are zero
// Parameters: Record phone call or Record roomservice document references
// Возврат value: Value table row with SumBalance and QuantityBalance fields
//-----------------------------------------------------------------------------
Функция cmGetRoomServiceDocumentCurrentAccountsReceivableBalance(pParentDoc) Экспорт
	vDocBalancesRow = Неопределено;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CurrentAccountsReceivableBalance.ДокОснование,
	|	CurrentAccountsReceivableBalance.SumBalance,
	|	CurrentAccountsReceivableBalance.QuantityBalance
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(&qEmptyDate, Начисление.ParentRoomService = &qParentDoc) AS CurrentAccountsReceivableBalance";
	vQry.SetParameter("qParentDoc", pParentDoc);
	vQry.SetParameter("qEmptyDate", '00010101');
	vDocBalances = vQry.Execute().Unload();
	Если vDocBalances.Count() > 0 Тогда
		vDocBalancesRow = vDocBalances.Get(0);
	КонецЕсли;
	Возврат vDocBalancesRow;
КонецФункции //cmGetRoomServiceDocumentCurrentAccountsReceivableBalance

//-----------------------------------------------------------------------------
// Description: Returns table of price tag ranges valid for the date and type specified
// Parameters: Гостиница reference, price tag type enum reference, accounting date
// Возврат value: Value table with rows from the PriceTagRanges information register 
//-----------------------------------------------------------------------------
Функция cmGetPriceTagRanges(pHotel, pPriceTagType, pAccountingDate) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	PriceTagsSliceLast.ИзмЦены AS ИзмЦены
	|INTO ActiveOrders
	|FROM
	|	РегистрСведений.ПризнакЦены.SliceLast(
	|			&qPeriod,
	|			Гостиница = &qHotel
	|				AND PriceTagType = &qPriceTagType) AS PriceTagsSliceLast
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	PriceTagRanges.StartValue AS StartValue,
	|	PriceTagRanges.EndValue AS EndValue,
	|	PriceTagRanges.ПризнакЦены AS ПризнакЦены
	|FROM
	|	РегистрСведений.PriceTagRanges AS PriceTagRanges
	|WHERE
	|	PriceTagRanges.Гостиница = &qHotel
	|	AND PriceTagRanges.PriceTagType = &qPriceTagType
	|	AND PriceTagRanges.ИзмЦены IN
	|			(SELECT
	|				ActiveOrders.ИзмЦены
	|			FROM
	|				ActiveOrders AS ActiveOrders)
	|
	|ORDER BY
	|	StartValue,
	|	EndValue";
	vQry.SetParameter("qPeriod", BegOfDay(pAccountingDate));	
	vQry.SetParameter("qHotel", pHotel);	
	vQry.SetParameter("qPriceTagType", pPriceTagType);	
	Возврат vQry.Execute().Unload();
КонецФункции //cmGetPriceTagRanges

//-----------------------------------------------------------------------------
// Description: Returns table of occuancy percent values for each date from the period specified
// Parameters: Гостиница, Period from as date, Period to as date
// Возврат value: Value table with rows of accounting date and occupancy percent
//-----------------------------------------------------------------------------
Функция cmFillOccupationPercents(pHotel, pPeriodFrom, pPeriodTo) Экспорт
	vOccupationPercents = Новый ValueTable();
	vOccupationPercents.Columns.Add("УчетнаяДата", cmGetDateTypeDescription());
	vOccupationPercents.Columns.Add("OccupationPercent", cmGetNumberTypeDescription(19, 7));
	// Fill occupation percents
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ВсегоНомеров.Period AS Period,
	|	ISNULL(ВсегоНомеров.CounterClosingBalance, 0) AS CounterClosingBalance,
	|	ISNULL(ВсегоНомеров.TotalRoomsClosingBalance, 0) AS ВсегоНомеров,
	|	-ISNULL(ВсегоНомеров.RoomsBlockedClosingBalance, 0) AS TotalRoomsBlocked,
	|	ISNULL(RoomSales.ПроданоНомеров, 0) AS ПроданоНомеров
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceANDTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsИPeriodBoundaries, Гостиница = &qHotel) AS ВсегоНомеров
	|		LEFT JOIN (SELECT
	|			ОборотыПродажиНомеров.Period AS Period,
	|			SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров
	|		FROM
	|			(SELECT
	|				RoomSales.Period AS Period,
	|				RoomSales.RoomsRentedTurnover AS RoomsRentedTurnover
	|			FROM
	|				AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница = &qHotel) AS RoomSales
	|			
	|			UNION ALL
	|			
	|			SELECT
	|				RoomSalesForecast.Period,
	|				RoomSalesForecast.RoomsRentedTurnover
	|			FROM
	|				AccumulationRegister.ПрогнозПродаж.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Гостиница = &qHotel) AS RoomSalesForecast) AS ОборотыПродажиНомеров
	|		
	|		GROUP BY
	|			ОборотыПродажиНомеров.Period) AS RoomSales
	|		ON ВсегоНомеров.Period = RoomSales.Period
	|
	|ORDER BY
	|	ВсегоНомеров.Period";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPeriodFrom", BegOfDay(pPeriodFrom));
	vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
	vQry.SetParameter("qForecastPeriodFrom", Max(BegOfDay(pPeriodFrom), BegOfDay(CurrentDate())));
	vQry.SetParameter("qForecastPeriodTo", Max(EndOfDay(pPeriodTo), EndOfDay(CurrentDate()-24*3600)));
	vDays = vQry.Execute().Unload();
	Для каждого vDaysRow из vDays Цикл
		vAccountingDate = BegOfDay(vDaysRow.Period);
		vOPRow = vOccupationPercents.Find(vAccountingDate, "УчетнаяДата");
		Если vOPRow = Неопределено Тогда
			vOPRow = vOccupationPercents.Add();
			vOPRow.УчетнаяДата = vAccountingDate;
			Если vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked <> 0 Тогда
				vOPRow.OccupationPercent = Round(100*vDaysRow.RoomsRented/(vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked), 0);
			Иначе
				vOPRow.OccupationPercent = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Возврат vOccupationPercents;
КонецФункции //cmFillOccupationPercents

//-----------------------------------------------------------------------------
// Description: Returns table of occuancy percent values for each date from the 
//              period specified and for each ГруппаНомеров type
// Parameters: Гостиница, Period from as date, Period to as date
// Возврат value: Value table with rows of accounting date, ГруппаНомеров type and occupancy percent
//-----------------------------------------------------------------------------
Функция cmFillOccupationPercentsPerRoomType(pHotel, pRoomType, pPeriodFrom, pPeriodTo) Экспорт
	vOccupationPercents = Новый ValueTable();
	vOccupationPercents.Columns.Add("УчетнаяДата", cmGetDateTypeDescription());
	vOccupationPercents.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
	vOccupationPercents.Columns.Add("OccupationPercent", cmGetNumberTypeDescription(19, 7));
	// Fill occupation percents
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ВсегоНомеров.Period AS Period,
	|	ВсегоНомеров.ТипНомера AS ТипНомера,
	|	ISNULL(ВсегоНомеров.CounterClosingBalance, 0) AS CounterClosingBalance,
	|	ISNULL(ВсегоНомеров.TotalRoomsClosingBalance, 0) AS ВсегоНомеров,
	|	-ISNULL(ВсегоНомеров.RoomsBlockedClosingBalance, 0) AS TotalRoomsBlocked,
	|	ISNULL(RoomSales.ПроданоНомеров, 0) AS ПроданоНомеров
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceANDTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsИPeriodBoundaries, Гостиница = &qHotel AND (ТипНомера IN HIERARCHY (&qRoomType) OR &qRoomTypeIsEmpty)) AS ВсегоНомеров
	|		LEFT JOIN (SELECT
	|			ОборотыПродажиНомеров.Period AS Period,
	|			ОборотыПродажиНомеров.ТипНомера AS ТипНомера,
	|			SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров
	|		FROM
	|			(SELECT
	|				RoomSales.Period AS Period,
	|				RoomSales.ТипНомера AS ТипНомера,
	|				RoomSales.RoomsRentedTurnover AS RoomsRentedTurnover
	|			FROM
	|				AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница = &qHotel AND (ТипНомера IN HIERARCHY (&qRoomType) OR &qRoomTypeIsEmpty)) AS RoomSales
	|			
	|			UNION ALL
	|			
	|			SELECT
	|				RoomSalesForecast.Period,
	|				RoomSalesForecast.ТипНомера,
	|				RoomSalesForecast.RoomsRentedTurnover
	|			FROM
	|				AccumulationRegister.ПрогнозПродаж.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Гостиница = &qHotel AND (ТипНомера IN HIERARCHY (&qRoomType) OR &qRoomTypeIsEmpty)) AS RoomSalesForecast) AS ОборотыПродажиНомеров
	|		
	|		GROUP BY
	|			ОборотыПродажиНомеров.Period,
	|			ОборотыПродажиНомеров.ТипНомера) AS RoomSales
	|		ON ВсегоНомеров.Period = RoomSales.Period
	|			AND ВсегоНомеров.ТипНомера = RoomSales.ТипНомера
	|
	|ORDER BY
	|	ВсегоНомеров.Period,
	|	ВсегоНомеров.ТипНомера.ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoomTypeIsEmpty", Не ЗначениеЗаполнено(pRoomType));
	vQry.SetParameter("qPeriodFrom", BegOfDay(pPeriodFrom));
	vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
	vQry.SetParameter("qForecastPeriodFrom", Max(BegOfDay(pPeriodFrom), BegOfDay(CurrentDate())));
	vQry.SetParameter("qForecastPeriodTo", Max(EndOfDay(pPeriodTo), EndOfDay(CurrentDate()-24*3600)));
	vDays = vQry.Execute().Unload();
	Для каждого vDaysRow из vDays Цикл
		vAccountingDate = BegOfDay(vDaysRow.Period);
		vOPRows = vOccupationPercents.FindRows(Новый Structure("УчетнаяДата, ТипНомера", vAccountingDate, vDaysRow.RoomType));
		Если vOPRows.Count() = 0 Тогда
			vOPRow = vOccupationPercents.Add();
			vOPRow.УчетнаяДата = vAccountingDate;
			vOPRow.ТипНомера = vDaysRow.RoomType;
			Если vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked <> 0 Тогда
				vOPRow.OccupationPercent = Round(100*vDaysRow.RoomsRented/(vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked), 0);
			Иначе
				vOPRow.OccupationPercent = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Возврат vOccupationPercents;
КонецФункции //cmFillOccupationPercentsPerRoomType

//-----------------------------------------------------------------------------
// Description: Returns table of occuancy percent values for each date from the 
//              period specified and for each ГруппаНомеров type and day type
// Parameters: Гостиница, Period from as date, Period to as date
// Возврат value: Value table with rows of accounting date, ГруппаНомеров type and occupancy percent
//-----------------------------------------------------------------------------
Функция cmFillOccupationPercentsPerRoomTypePerDayType(pHotel, pRoomType, pPeriodFrom, pPeriodTo, pRoomRate) Экспорт
	vOccupationPercents = Новый ValueTable();
	vOccupationPercents.Columns.Add("УчетнаяДата", cmGetDateTypeDescription());
	vOccupationPercents.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
	vOccupationPercents.Columns.Add("OccupationPercent", cmGetNumberTypeDescription(19, 7));
	// Fill occupation percents
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	КалендарьДень.ТипДеньКалендарь AS DayType,
	|	КалендарьДень.ТипДеньКалендарь.ПорядокСортировки AS DayTypeSortCode
	|INTO CalendarDayTypes
	|FROM
	|	РегистрСведений.КалендарьДень AS КалендарьДень
	|WHERE
	|	КалендарьДень.Calendar = &qCalendar
	|	AND КалендарьДень.Period >= &qPeriodFrom
	|	AND КалендарьДень.Period <= &qPeriodTo
	|
	|GROUP BY
	|	КалендарьДень.ТипДеньКалендарь,
	|	КалендарьДень.ТипДеньКалендарь.ПорядокСортировки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	DayTypesDays.ТипДеньКалендарь AS DayType,
	|	MIN(DayTypesDays.Period) AS MinPeriodFrom,
	|	MAX(DayTypesDays.Period) AS MaxPeriodTo
	|FROM
	|	РегистрСведений.КалендарьДень AS DayTypesDays
	|WHERE
	|	DayTypesDays.Calendar = &qCalendar
	|	AND DayTypesDays.Period >= &qStartPeriodFrom
	|	AND DayTypesDays.Period <= &qEndPeriodTo
	|	AND DayTypesDays.ТипДеньКалендарь IN
	|			(SELECT
	|				CalendarDayTypes.DayType
	|			FROM
	|				CalendarDayTypes)
	|
	|GROUP BY
	|	DayTypesDays.ТипДеньКалендарь";
	vQry.SetParameter("qCalendar", ?(ЗначениеЗаполнено(pRoomRate), pRoomRate.Calendar, Неопределено));
	vQry.SetParameter("qStartPeriodFrom", BegOfDay(pPeriodFrom) - 24*3600*180);
	vQry.SetParameter("qEndPeriodTo", EndOfDay(pPeriodTo) + 24*3600*180);
	vQry.SetParameter("qPeriodFrom", BegOfDay(pPeriodFrom));
	vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
	vDayTypes = vQry.Execute().Unload();
	// Цикл for each day type found
	Для каждого vDayTypesRow из vDayTypes Цикл
		vQry.Text = 
		"SELECT
		|	PerDayType.ТипНомера AS ТипНомера,
		|	SUM(ISNULL(PerDayType.ВсегоНомеров, 0)) AS ВсегоНомеров,
		|	SUM(ISNULL(PerDayType.TotalRoomsBlocked, 0)) AS TotalRoomsBlocked,
		|	SUM(ISNULL(PerDayType.ПроданоНомеров, 0)) AS ПроданоНомеров
		|FROM
		|	(SELECT
		|		ВсегоНомеров.ТипНомера AS ТипНомера,
		|		ВсегоНомеров.Period AS Period,
		|		ВсегоНомеров.CounterClosingBalance AS CounterClosingBalance,
		|		ISNULL(ВсегоНомеров.TotalRoomsClosingBalance, 0) AS ВсегоНомеров,
		|		-ISNULL(ВсегоНомеров.RoomsBlockedClosingBalance, 0) AS TotalRoomsBlocked,
		|		ISNULL(RoomSales.ПроданоНомеров, 0) AS ПроданоНомеров
		|	FROM
		|		AccumulationRegister.ЗагрузкаНомеров.BalanceANDTurnovers(
		|				&qPeriodFrom,
		|				&qPeriodTo,
		|				Day,
		|				RegisterRecordsИPeriodBoundaries,
		|				Гостиница = &qHotel
		|					AND (ТипНомера IN HIERARCHY (&qRoomType)
		|						OR &qRoomTypeIsEmpty)) AS ВсегоНомеров
		|			LEFT JOIN (SELECT
		|				ОборотыПродажиНомеров.ТипНомера AS ТипНомера,
		|				ОборотыПродажиНомеров.Period AS Period,
		|				SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров
		|			FROM
		|				(SELECT
		|					RoomSales.ТипНомера AS ТипНомера,
		|					RoomSales.Period AS Period,
		|					RoomSales.RoomsRentedTurnover AS RoomsRentedTurnover
		|				FROM
		|					AccumulationRegister.Продажи.Turnovers(
		|							&qPeriodFrom,
		|							&qPeriodTo,
		|							Day,
		|							Гостиница = &qHotel
		|								AND (ТипНомера IN HIERARCHY (&qRoomType)
		|									OR &qRoomTypeIsEmpty)) AS RoomSales
		|				
		|				UNION ALL
		|				
		|				SELECT
		|					RoomSalesForecast.ТипНомера,
		|					RoomSalesForecast.Period,
		|					RoomSalesForecast.RoomsRentedTurnover
		|				FROM
		|					AccumulationRegister.ПрогнозПродаж.Turnovers(
		|							&qForecastPeriodFrom,
		|							&qForecastPeriodTo,
		|							Day,
		|							Гостиница = &qHotel
		|								AND (ТипНомера IN HIERARCHY (&qRoomType)
		|									OR &qRoomTypeIsEmpty)) AS RoomSalesForecast) AS ОборотыПродажиНомеров
		|			
		|			GROUP BY
		|				ОборотыПродажиНомеров.ТипНомера,
		|				ОборотыПродажиНомеров.Period) AS RoomSales
		|			ON ВсегоНомеров.Period = RoomSales.Period
		|				AND ВсегоНомеров.ТипНомера = RoomSales.ТипНомера) AS PerDayType
		|
		|GROUP BY
		|	PerDayType.ТипНомера";
		vQry.SetParameter("qHotel", pHotel);
		vQry.SetParameter("qRoomType", pRoomType);
		vQry.SetParameter("qRoomTypeIsEmpty", Не ЗначениеЗаполнено(pRoomType));
		vQry.SetParameter("qPeriodFrom", vDayTypesRow.MinPeriodFrom);
		vQry.SetParameter("qPeriodTo", EndOfDay(vDayTypesRow.MaxPeriodTo));
		vQry.SetParameter("qForecastPeriodFrom", Max(vDayTypesRow.MinPeriodFrom, BegOfDay(CurrentDate())));
		vQry.SetParameter("qForecastPeriodTo", Max(EndOfDay(vDayTypesRow.MaxPeriodTo), EndOfDay(CurrentDate()-24*3600)));
		vStats = vQry.Execute().Unload();
		Для каждого vStatsRow из vStats Цикл
			vOccupationPercent = 0;
			Если vStatsRow.TotalRooms <> Null И vStatsRow.TotalRoomsBlocked <> Null И vStatsRow.RoomsRented <> Null И 
			  (vStatsRow.TotalRooms - vStatsRow.TotalRoomsBlocked) <> 0 Тогда
				vOccupationPercent = Round(100*vStatsRow.RoomsRented/(vStatsRow.TotalRooms - vStatsRow.TotalRoomsBlocked), 2);
			КонецЕсли;
			vAccountingDate = Max(vDayTypesRow.MinPeriodFrom, BegOfDay(pPeriodFrom));
			vMaxAccountingDate = Min(vDayTypesRow.MaxPeriodTo, BegOfDay(pPeriodTo));
			While vAccountingDate <= vMaxAccountingDate Цикл
				vOPRow = vOccupationPercents.Find(vAccountingDate, "УчетнаяДата");
				Если vOPRow = Неопределено Тогда
					vOPRow = vOccupationPercents.Add();
					vOPRow.УчетнаяДата = vAccountingDate;
					vOPRow.ТипНомера = vStatsRow.RoomType;
					vOPRow.OccupationPercent = vOccupationPercent;
				КонецЕсли;
				vAccountingDate = vAccountingDate + 24*3600;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	Возврат vOccupationPercents;
КонецФункции //cmFillOccupationPercentsPerRoomTypePerDayType

//-----------------------------------------------------------------------------
// Description: Returns gift certificate balance for the given hotel
// Parameters: Гостиница, Gift certificate code
// Возврат value: Gift certificate balance amount
//-----------------------------------------------------------------------------
Функция cmGetGiftCertificateBalance(pHotel, pGiftCertificate, pDate) Экспорт
	Если IsBlankString(СокрЛП(pGiftCertificate)) Тогда
		Возврат 0;
	КонецЕсли;
	vGiftCertificatesArePerHotel = 0;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ПодарочСертификат.GiftCertificate,
	|	ПодарочСертификат.AmountBalance
	|FROM
	|	AccumulationRegister.ПодарочСертификат.Balance(
	|			&qDate,
	|			GiftCertificate = &qGiftCertificate
	|				AND (NOT &qHotelIsFilled
	|					OR &qHotelIsFilled
	|						AND Гостиница = &qHotel)) AS ПодарочСертификат";
	vQry.SetParameter("qDate", Новый Boundary(pDate, BoundaryType.Excluding));
	vQry.SetParameter("qGiftCertificate", СокрЛП(pGiftCertificate));
	vQry.SetParameter("qHotel", ?(vGiftCertificatesArePerHotel, pHotel, Справочники.Hotels.EmptyRef()));
	vQry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(?(vGiftCertificatesArePerHotel, pHotel, Справочники.Hotels.EmptyRef())));
	vQryRes = vQry.Execute().Unload();
	Если vQryRes.Count() > 0 Тогда
		Возврат vQryRes.Get(0).AmountBalance;
	Иначе
		Возврат 0;
	КонецЕсли;
КонецФункции //cmGetGiftCertificateBalance

//-----------------------------------------------------------------------------
// Description: Returns whether gift certificate is blocked or not for the given hotel
// Parameters: Гостиница, Gift certificate code, Date to check
// Возврат value: Boolean true if certificate is blocked, block reason as string
//-----------------------------------------------------------------------------
Функция cmGiftCertificateIsBlocked(Val pHotel, pGiftCertificate, pDate, rBlockReason) Экспорт
	rBlockReason = "";
	Если IsBlankString(СокрЛП(pGiftCertificate)) Тогда
		Возврат Ложь;
	КонецЕсли;
	vGiftCertificatesArePerHotel = 0;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	BlockedGiftCertificates.GiftCertificate,
	|	BlockedGiftCertificates.BlockReason,
	|	BlockedGiftCertificates.BlockDate,
	|	BlockedGiftCertificates.BlockAuthor,
	|	BlockedGiftCertificates.Гостиница,
	|	BlockedGiftCertificates.Period
	|FROM
	|	РегистрСведений.GiftCertificates AS BlockedGiftCertificates
	|WHERE
	|	BlockedGiftCertificates.GiftCertificate = &qGiftCertificate
	|	AND BlockedGiftCertificates.BlockDate <> &qEmptyDate
	|	AND BlockedGiftCertificates.BlockDate <= &qDate
	|	AND (NOT &qHotelIsFilled
	|			OR &qHotelIsFilled
	|				AND BlockedGiftCertificates.Гостиница = &qHotel)";
	vQry.SetParameter("qDate", BegOfDay(pDate));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qGiftCertificate", СокрЛП(pGiftCertificate));
	vQry.SetParameter("qHotel", ?(vGiftCertificatesArePerHotel, pHotel, Справочники.Hotels.EmptyRef()));
	vQry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(?(vGiftCertificatesArePerHotel, pHotel, Справочники.Hotels.EmptyRef())));
	vQryRes = vQry.Execute().Unload();
	Если vQryRes.Count() > 0 Тогда
		Для каждого vQryResRow из vQryRes Цикл
			rBlockReason = СокрЛП(vQryResRow.BlockReason);
			Возврат Истина;
		КонецЦикла;
		Возврат Ложь;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции //cmGiftCertificateIsBlocked

//-----------------------------------------------------------------------------
// Description: Returns whether gift certificate was issued
// Parameters: Гостиница, Gift certificate code
// Возврат value: Boolean true if certificate is found, false if not
//-----------------------------------------------------------------------------
Функция cmGiftCertificateExists(pHotel, pGiftCertificate) Экспорт
	Если IsBlankString(СокрЛП(pGiftCertificate)) Тогда
		Возврат Ложь;
	КонецЕсли;
	vQry = Новый Query();
	vQry.Text = 
	"SELECT DISTINCT
	|	GiftCertificates.GiftCertificate,
	|	GiftCertificates.Гостиница
	|FROM
	|	AccumulationRegister.ПодарочСертификат AS GiftCertificates
	|WHERE
	|	GiftCertificates.GiftCertificate = &qGiftCertificate
	|	AND GiftCertificates.RecordType = &qReceipt
	|	AND (NOT &qHotelIsFilled
	|			OR &qHotelIsFilled
	|				AND GiftCertificates.Гостиница = &qHotel)";
	vQry.SetParameter("qGiftCertificate", СокрЛП(pGiftCertificate));
	vQry.SetParameter("qHotel",  pHotel );
	//ry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(?(vGiftCertificatesArePerHotel, pHotel, Справочники.Hotels.EmptyRef())));
	vQry.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vQryRes = vQry.Execute().Unload();
	Если vQryRes.Count() > 0 Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции //cmGiftCertificateExists

//-----------------------------------------------------------------------------
Функция cmGetGiftCertificateCharges(pGiftCertificate, pCharge2Skip = Неопределено) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Начисление.Услуга,
	|	Начисление.Ref AS Начисление,
	|	Начисление.GiftCertificate AS GiftCertificate
	|FROM
	|	Document.Начисление AS Начисление
	|WHERE
	|	Начисление.Posted
	|	AND Начисление.GiftCertificate = &qGiftCertificate
	|	AND Начисление.Услуга.IsGiftCertificate
	|	AND Начисление.GiftCertificate <> &qEmptyString
	|	AND (&qCharge2SkipIsEmpty
	|			OR NOT &qCharge2SkipIsEmpty
	|				AND Начисление.Ref <> &qCharge2Skip)
	|
	|GROUP BY
	|	Начисление.Услуга,
	|	Начисление.Ref,
	|	Начисление.GiftCertificate
	|
	|ORDER BY
	|	GiftCertificate";
	vQry.SetParameter("qGiftCertificate", СокрЛП(pGiftCertificate));
	vQry.SetParameter("qEmptyString", "");
	vQry.SetParameter("qCharge2SkipIsEmpty", Не ЗначениеЗаполнено(pCharge2Skip));
	vQry.SetParameter("qCharge2Skip", pCharge2Skip);
	Возврат vQry.Execute().Unload();
КонецФункции //cmGetGiftCertificateCharges

//-----------------------------------------------------------------------------
// Description: Returns gift certificate data record
// Parameters: Гостиница, Gift certificate code
// Возврат value: Gift certificate record manager object
//-----------------------------------------------------------------------------
Функция cmGetGiftCertificateRecordManager(pHotel, pGiftCertificate) Экспорт
	Если IsBlankString(СокрЛП(pGiftCertificate)) Тогда
		Возврат Неопределено;
	КонецЕсли;
	vGiftCertificatesArePerHotel = Constants.GiftCertificatesArePerHotel.Get();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	*
	|FROM
	|	РегистрСведений.GiftCertificates AS GiftCertificates
	|WHERE
	|	GiftCertificates.GiftCertificate = &qGiftCertificate
	|	AND (NOT &qHotelIsFilled
	|			OR &qHotelIsFilled
	|				AND GiftCertificates.Гостиница = &qHotel)";
	vQry.SetParameter("qGiftCertificate", СокрЛП(pGiftCertificate));
	vQry.SetParameter("qHotel", ?(vGiftCertificatesArePerHotel, pHotel, Справочники.Hotels.EmptyRef()));
	vQry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(?(vGiftCertificatesArePerHotel, pHotel, Справочники.Hotels.EmptyRef())));
	vQryRes = vQry.Execute().Unload();
	Если vQryRes.Count() > 0 Тогда
		vRow = vQryRes.Get(0);
		vRM = РегистрыСведений.ПодарочСертификатСведения.CreateRecordManager();
		vRM.Period = vRow.Period;
		vRM.Гостиница = vRow.Гостиница;
		vRM.GiftCertificate = vRow.GiftCertificate;
		vRM.Read();
		Если vRM.Selected() Тогда
			Возврат vRM;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции //cmGetGiftCertificateRecordManager

//-----------------------------------------------------------------------------
// Description: Returns service item output in grams as number
// Parameters: service item output in grams as string
// Возврат value: service item output in grams as number
//-----------------------------------------------------------------------------
Функция cmParseServiceItemOutputString(pOutput) Экспорт
	Если IsBlankString(pOutput) Тогда
		Возврат 0;
	Иначе
		vOutputAmount = 0;
		vOutput = СокрЛП(pOutput);
		vOutput = StrReplace(vOutput, "\", "/");
		While Не IsBlankString(vOutput) Цикл
			vSlashPos = Find(vOutput, "/");
			Если vSlashPos > 1 Тогда
				vWord = СокрЛП(Left(vOutput, vSlashPos - 1));
				vOutput = СокрЛП(Mid(vOutput, vSlashPos + 1)); 
				Если Число(vWord) Тогда
					vOutputAmount = vOutputAmount + Number(vWord);
				КонецЕсли;
			Иначе
				Если Число(vOutput) Тогда
					vOutputAmount = vOutputAmount + Number(vOutput);
				КонецЕсли;
				Break;
			КонецЕсли;
		КонецЦикла;
		Возврат vOutputAmount;
	КонецЕсли;
КонецФункции //cmParseServiceItemOutputString

//-----------------------------------------------------------------------------
// Searches for Контрагент in hotel database by Контрагент from external database
//-----------------------------------------------------------------------------
Функция cmFindCustomers(pCustomer) Экспорт 
	Если pCustomer.Code = "" Тогда 
		Если pCustomer.ИНН<>"" Тогда
			 vCustomer = Справочники.Сотрудники.НайтиПоРеквизиту("ИНН",pCustomer.TIN);
		 КонецЕсли;	
		 Возврат ?(ЗначениеЗаполнено(vCustomer),vCustomer,Справочники.Customers.EmptyRef());
	Иначе	
		// 1. find by external code
		vCustomer = Справочники.Сотрудники.НайтиПоКоду("Код",pCustomer.Код);
		
		//2. find by ИНН
		Если Не ЗначениеЗаполнено(vCustomer) Тогда
			Если pCustomer.ИНН<>"" Тогда
				vCustomer = Справочники.Сотрудники.НайтиПоРеквизиту("ИНН",pCustomer.TIN);
			КонецЕсли;	
		КонецЕсли;	
		
		Если ЗначениеЗаполнено(vCustomer) Тогда
			Возврат 	vCustomer;
		КонецЕсли;	
		
		//3. create new Контрагент
		vCustomer = Справочники.Customers.CreateItem();
		
		vCustomer.Description 			= pCustomer.Description;
		vCustomer.ЮрИмя 			= pCustomer.FullDescription;
		vCustomer.ИНН 					= pCustomer.ИНН;
		vCustomer.KPP 					= pCustomer.KPP;
		vCustomer.ExternalCode 			= pCustomer.Code;
		vCustomer.PostAddress 			= pCustomer.PostAddress;
		vCustomer.LegacyAddress 		= pCustomer.LegalAddress;
		vCustomer.Телефон 				= pCustomer.Телефон;
		vCustomer.EMail 				= pCustomer.EMail;
		
		vCustomer.Write();
		
		//4. create new BankAccounts
		Если ЗначениеЗаполнено(pCustomer.BankAccountBIC) И ЗначениеЗаполнено(pCustomer.BankAccountNumber) Тогда
			
			vBankAccounts = Справочники.BankAccounts.CreateItem();
			
			vBankAccounts.Parent 				= vCustomer;
			vBankAccounts.БИКБанка 				= pCustomer.BankAccountBIC;
			vBankAccounts.НомерСчета			= pCustomer.BankAccountNumber;
			vBankAccounts.НазваниеБанка			 	= pCustomer.BankAccountBankName;
			vBankAccounts.КорСчет	= pCustomer.BankAccountBankCorrAccount;

			vBankAccounts.Write();

		КонецЕсли;
		
		Возврат ?(ЗначениеЗаполнено(vCustomer),vCustomer,Справочники.Customers.EmptyRef());
	КонецЕсли;	
КонецФункции // FindCustomers()

//-----------------------------------------------------------------------------
// Searches for storned transactions in value table and removes those pares
//-----------------------------------------------------------------------------
Процедура cmRemoveTransactionsWithStorno(pTransactions) Экспорт
	// Group by transactions by charge
	vTransactions = pTransactions.Copy();
	vTransactions.GroupBy("Начисление", "Сумма, Количество");
	// Check all transactions in list
	i = 0;
	While i < pTransactions.Count() Цикл
		vTrnRow = pTransactions.Get(i);
		Если ЗначениеЗаполнено(vTrnRow.Начисление) Тогда
			vCheckRow = vTransactions.Find(vTrnRow.Начисление, "Начисление");
			Если vCheckRow <> Неопределено Тогда
				Если vCheckRow.Сумма = 0 И vCheckRow.Количество = 0 Тогда
					pTransactions.Delete(i);
					Continue;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		i = i + 1;
	КонецЦикла;
КонецПроцедуры //cmRemoveTransactionsWithStorno
