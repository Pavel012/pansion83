//-----------------------------------------------------------------------------
// Description: Пересчитать сумму из одной валюты в другую. 
//             Функция позволяет заменить валюту передается в качестве входного параметра по 
//             другой валюте берется из внешней таблицы системы сопоставления
// Parameters: Amount, Currency from, Currency from exchange rate, Currency to, Currency to exchange rate, 
//             Exchange rate date, Гостиница, External system code
// Возврат value: Сумма в валюте
//-----------------------------------------------------------------------------
Функция cmExtConvertCurrencies(pSum, pCurrencyFrom, pCurrencyFromExchangeRate = 0, pCurrencyTo, pCurrencyToExchangeRate = 0, pExchangeRateDate, pHotel = Неопределено, pExternalSystemCode = "") Экспорт
	Если НЕ IsBlankString(pExternalSystemCode) And ЗначениеЗаполнено(pCurrencyTo) Тогда
		vCurrencyTo = cmGetObjectRefByExternalSystemCode(pHotel, pExternalSystemCode, "Валюты", Format(pCurrencyTo.Code, "ND=3; NFD=0; NG="));
		Если ЗначениеЗаполнено(vCurrencyTo) And vCurrencyTo <> pCurrencyTo Тогда
			Возврат Round(cmConvertCurrencies(pSum, pCurrencyFrom, pCurrencyFromExchangeRate, vCurrencyTo, 0, pExchangeRateDate, pHotel), 2);
		КонецЕсли;
	КонецЕсли;
	Возврат Round(cmConvertCurrencies(pSum, pCurrencyFrom, pCurrencyFromExchangeRate, pCurrencyTo, pCurrencyToExchangeRate, pExchangeRateDate, pHotel), 2);
КонецФункции //cmExtConvertCurrencies

//-----------------------------------------------------------------------------
// Description:Рассчитывает стоимость номера количество услуг за определенную дату.
//              Функция позволяет цена и описание услуги
// Parameters: Service, Quantity calculation rule, Accounting date, 
//             Accommodation period from date, Accommodation period to date, 
//             Accommodation/Reservation object, Reservation object,
//             Is check-in flag, Is reservation flag, Is before ГруппаНомеров change flag, 
//             Is ГруппаНомеров change flag, Is check-out flag, One time charges are mandatory, 
//             Service price (could be changed and returned), Currency, Service remarks (return parameter), 
//             Is day use flag (return parameter)
// Возврат value: Число, день количество
//-----------------------------------------------------------------------------
Функция cmCalculateServiceQuantity(pService, pQuantityCalculationRule, pAccountingDate, 
                                    Val pDateFrom, Val pDateTo, 
                                    pDocumentObj = Неопределено, pReservationObj = Неопределено, 
                                    pIsCheckIn = True, pIsReservation = False, 
                                    pIsBeforeRoomChange = False, pIsRoomChange = False, pIsCheckOut = True, pIsOneTimeChargeNecessary = True, 
                                    pPrice = 0, pCurrency = Неопределено, rRemarks = "", rIsDayUse = False, pMinQuantity = 0, pAccommodationPeriods = Неопределено) Экспорт
	// Common checks	
	Если НЕ ЗначениеЗаполнено(pService) Тогда
		ВызватьИсключение("ERR: Ошибка вызова функции cmCalculateServiceQuantity.
				       |CAUSE: В функцию передано пустое значение параметра pSevice.
					   |DESC: Обязательный параметр pService должен быть явно указан.");
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(pAccountingDate) Тогда
		ВызватьИсключение("ERR: Ошибка вызова функции cmCalculateServiceQuantity.
				       |CAUSE: В функцию передано пустое значение параметра pAccountingDate.
					   |DESC: Обязательный параметр pAccountingDate должен быть явно указан.");
	КонецЕсли;
	Если pDateTo < pDateFrom Тогда
		ВызватьИсключение("ERR: Ошибка вызова функции cmCalculateServiceQuantity.
				       |CAUSE: Дата и время pDateTo меньше даты и времени pDateFrom.
					   |DESC: У периода бронирования/проживания окончание периода раньше начала.");
	КонецЕсли;
	// Init return parameters
	rRemarks = "";
	rIsDayUse = False;
	// Check quantity calculation rule
	Если НЕ ЗначениеЗаполнено(pQuantityCalculationRule) Тогда
		Возврат 1;
	КонецЕсли;
	// Retrieve all parameters
	vSrvPH = pQuantityCalculationRule.PeriodInHours;
	vSrvRHIsUsed = pQuantityCalculationRule.ReferenceHourIsUsed;
	vSrvRH = pQuantityCalculationRule.ReferenceHour;
	vSrvQCR = pQuantityCalculationRule.QuantityCalculationRuleType;
	vSrvECRR = pQuantityCalculationRule.EarlyCheckInRoundingRule;
	vSrvLCRR = pQuantityCalculationRule.CheckOutDelayRoundingRule;
	vSrvCRR = pQuantityCalculationRule.CheckInRoundingRule;
	vSrvMRH = pQuantityCalculationRule.RoomChangeAlwaysAtReferenceHourTime;
	// Calculate additional parameters
	vAD = BegOfDay(pAccountingDate);
	vDF = BegOfDay(pDateFrom);
	vDT = BegOfDay(pDateTo);
	// Check period length in hours
	vPL = (pDateTo - pDateFrom)/3600;
	Если vPL <= pQuantityCalculationRule.RoomExaminationFreeOfChargeTime Тогда
		Возврат 0;
	ИначеЕсли (pIsBeforeRoomChange Or pIsRoomChange) And vPL <= pQuantityCalculationRule.FreeOfChargeChangeRoomTime Тогда
		Возврат 0;
	ИначеЕсли vPL <= pQuantityCalculationRule.ChargeByHoursTime Тогда
		Если vAD = vDF Тогда
			Если vSrvCRR = Перечисления.QuantityRoundingRules.Int Тогда
				vPL = Int(vPL);
			ИначеЕсли vSrvCRR = Перечисления.QuantityRoundingRules.Round Тогда
				vPL = Round(vPL, 0);
			ИначеЕсли vSrvCRR = Перечисления.QuantityRoundingRules.Full Тогда
				Если Int(vPL) <> vPL Тогда
					vPL = Int(vPL) + 1;
				КонецЕсли;
			КонецЕсли;
			Возврат Round(vPL/24, 7);
		ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Размещение Тогда
			Возврат 0;
		КонецЕсли;
	ИначеЕсли vPL <= pQuantityCalculationRule.ChargeByQuarterOfADayTime Тогда
		Если vAD = vDF Тогда
			Возврат Round(6/24, 7);
		ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Размещение Тогда
			Возврат 0;
		КонецЕсли;
	ИначеЕсли vPL <= pQuantityCalculationRule.ChargeByHalfOfADayTime And vAD = vDF Тогда
		Если vAD = vDF Тогда
			Возврат Round(12/24, 7);
		ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Размещение Тогда
			Возврат 0;
		КонецЕсли;
	КонецЕсли;
	// Split algorithms by quantity calculation rules
	Если vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Размещение Тогда
		Если НЕ vSrvRHIsUsed Тогда
			vSrvRH = '00010101' + (pDateFrom - BegOfDay(pDateFrom));
		КонецЕсли;
		Если vSrvPH <> 24 Тогда
			ВызватьИсключение("ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не верно задана периодичность услуги для вида расчета <Проживание>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Проживание>, период должен быть равен 24 часам.");
		КонецЕсли;
		// Calculate day price if hotel product with fixed cost is choosen
		Если pDocumentObj <> Неопределено And ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка) And pPrice > 0 Тогда
			vProductSum = pDocumentObj.ПутевкаКурсовка.Сумма;
			Если pDocumentObj.ПутевкаКурсовка.FixProductCost And
			   vProductSum > 0 Тогда
				Если pDocumentObj.ПутевкаКурсовка.FixProductPeriod Or pDocumentObj.ПутевкаКурсовка.FixPlannedPeriod Тогда
					// Get duration from the product 
					vDuration = pDocumentObj.ПутевкаКурсовка.Продолжительность;
				Иначе
					// Get duration from the document
					Если TypeOf(pDocumentObj) = Type("DocumentObject.Размещение") And pDocumentObj.FixReservationConditions And pReservationObj <> Неопределено Тогда
						vDuration = pReservationObj.Продолжительность;
					Иначе
						vDuration = pDocumentObj.Продолжительность;
					КонецЕсли;
				КонецЕсли;
				Если vDuration > 0 Тогда
					vQ = 0;
					// Calculate effective day price
					vDayPrice = Int(vProductSum/vDuration);
					// Set last day price to the rest of the product cost
					vLastDayPrice = vProductSum - vDayPrice*(vDuration - 1);
					// Get check-out date based on duration
					vDT = vDF + (vDuration-1)*24*3600;
					// Update current ГруппаНомеров rate price
					Если vAD = vDT Тогда
						pPrice = vLastDayPrice;
						Если ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка.Валюта) Тогда
							pCurrency = pDocumentObj.ПутевкаКурсовка.Валюта;
						КонецЕсли;
						vQ = 1;
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
					ИначеЕсли vAD < vDT Тогда
						pPrice = vDayPrice;
						Если ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка.Валюта) Тогда
							pCurrency = pDocumentObj.ПутевкаКурсовка.Валюта;
						КонецЕсли;
						vQ = 1;
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
					Иначе
						pPrice = 0;
						vQ = 0;
					КонецЕсли;
					// Возврат
					Возврат vQ;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		// Normal calculation
		vQ = 0;
		// Check if this is ГруппаНомеров change
		Если vSrvMRH And pIsRoomChange Тогда
			// Move check-in date to the nearest next/previous reference hour
			vDateFrom = Дата(Year(pDateFrom), Month(pDateFrom), Day(pDateFrom), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
			Если vDateFrom < pDateTo Тогда
				pDateFrom = vDateFrom;
				vDF = BegOfDay(pDateFrom);
			КонецЕсли;
		КонецЕсли;
		// Calculate 3 numbers: 
		// 1. Early check in part if accounting date equals check in date
		Если vAD = vDF And pIsCheckIn Тогда
			vSkipEarlyCheckIn = False;
			vIsOneDay = False;
			vTQ = (pDateTo - pDateFrom)/(3600*24);
			Если vTQ <= 1 Тогда
				vIsOneDay = True;
			КонецЕсли;
			Если vIsOneDay Тогда
				Если НЕ pQuantityCalculationRule.FirstDayStartsAtReferenceHourTime Тогда
					// No early check-in at all
					vSkipEarlyCheckIn = True;
				КонецЕсли;
			КонецЕсли;
			Если НЕ vSkipEarlyCheckIn Тогда
				vDFRH = Дата(Year(pDateFrom), Month(pDateFrom), Day(pDateFrom), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
				Если pDateFrom < vDFRH Тогда
					vEQ = (vDFRH - pDateFrom)/3600;
					Если vEQ <= pQuantityCalculationRule.FreeOfChargeEarlyCheckInTime Тогда
						vEQ = 0;
						vQ = vQ + Round(vEQ/24, 7);
					ИначеЕсли vEQ <= pQuantityCalculationRule.ChargeByHoursEarlyCheckInTime Тогда
						Если vSrvECRR = Перечисления.QuantityRoundingRules.Int Тогда
							vEQ = Int(vEQ);
						ИначеЕсли vSrvECRR = Перечисления.QuantityRoundingRules.Round Тогда
							vEQ = Round(vEQ, 0);
						ИначеЕсли vSrvECRR = Перечисления.QuantityRoundingRules.Full Тогда
							Если Int(vEQ) <> vEQ Тогда
								vEQ = Int(vEQ) + 1;
							КонецЕсли;
						КонецЕсли;
						rRemarks = NStr("ru='Ранний заезд на " + vEQ + " часов';en='Early check in for " + vEQ + " hours';de='Early check in for " + vEQ + " hours'");
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли vEQ <= pQuantityCalculationRule.ChargeByQuarterOfADayEarlyCheckInTime Тогда
						vEQ = 6;
						rRemarks = NStr("ru='Ранний заезд на " + vEQ + " часов';en='Early check in for " + vEQ + " hours';de='Early check in for " + vEQ + " hours'");
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли vEQ <= pQuantityCalculationRule.ChargeByHalfOfADayEarlyCheckInTime Тогда
						vEQ = 12;
						rRemarks = NStr("en='Early check in for half of a day';ru='Ранний заезд на полсуток';de='Um 12 Stunden frühere Anreise'");
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли pQuantityCalculationRule.Do1DayEarlyCheckInCharge Тогда
						vEQ = 24;
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		// 2. Main part (which is 1 or less actually)
		Если vDF = vDT Тогда
			Если vAD = vDF And НЕ pIsRoomChange Тогда
				vQ = vQ + 1;
			КонецЕсли;
		Иначе
			Если (vAD >= vDF) And (vAD < vDT) Тогда
				vQ = vQ + 1;
			КонецЕсли;
		КонецЕсли;
		// 3. Late check out part if accounting date equals check out date
		Если vAD = vDT And (pIsCheckOut Or НЕ vSrvMRH) Тогда
			// Check should we add check out delay time to the quantity if guest took only 1 night
			vIsOneDay = False;
			vIsBetween1And2 = False;
			vTQ = (pDateTo - pDateFrom)/(3600*24);
			Если vTQ <= 1 Тогда
				vIsOneDay = True;
			ИначеЕсли vTQ < 1.5 Тогда
				vIsBetween1And2 = True;
			КонецЕсли;
			vSkipDelayCalculation = False;
			Если vIsOneDay And pIsCheckIn Тогда
				Если НЕ pQuantityCalculationRule.FirstDayEndsAtReferenceHourTime Тогда
					// No late check out at all
					vSkipDelayCalculation = True;
				КонецЕсли;
			КонецЕсли;
			Если НЕ vSkipDelayCalculation Тогда
				// Calculate base for delay time
				vDFRH = Дата(Year(pDateFrom), Month(pDateFrom), Day(pDateFrom), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
				vDTRH = Дата(Year(pDateTo), Month(pDateTo), Day(pDateTo), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
				Если pQuantityCalculationRule.CalculateDelayFromCheckOutTimeForFirstDay And 
				   vIsBetween1And2 And pIsCheckIn And pDateFrom > vDFRH Тогда
					vDTB = Дата(Year(pDateTo), Month(pDateTo), Day(pDateTo), Hour(pDateFrom), Minute(pDateFrom), Second(pDateFrom));
				Иначе
					vDTB = vDTRH;
				КонецЕсли;
				// Calculate delay time
				Если pDateTo > vDTB Тогда
					vLQ = (pDateTo - vDTB)/3600;
					Если vLQ <= pQuantityCalculationRule.FreeOfChargeCheckOutDelayTime Тогда
						vLQ = 0;
						vQ = vQ + Round(vLQ/24, 7);
					ИначеЕсли vLQ <= pQuantityCalculationRule.ChargeByHoursCheckOutDelayTime Тогда
						Если vSrvLCRR = Перечисления.QuantityRoundingRules.Int Тогда
							vLQ = Int(vLQ);
						ИначеЕсли vSrvLCRR = Перечисления.QuantityRoundingRules.Round Тогда
							vLQ = Round(vLQ, 0);
						ИначеЕсли vSrvLCRR = Перечисления.QuantityRoundingRules.Full Тогда
							Если Int(vLQ) <> vLQ Тогда
								vLQ = Int(vLQ) + 1;
							КонецЕсли;
						КонецЕсли;
						rRemarks = NStr("ru='Задержка выезда на " + vLQ + " часов';en='Late check out for " + vLQ + " hours';de='Late check out for " + vLQ + " hours'");
						vQ = vQ + Round(vLQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли vLQ <= pQuantityCalculationRule.ChargeByQuarterOfADayCheckOutDelayTime Тогда
						vLQ = 6;
						rRemarks = NStr("ru='Задержка выезда на " + vLQ + " часов';en='Late check out for " + vLQ + " hours';de='Late check out for " + vLQ + " hours'");
						vQ = vQ + Round(vLQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли vLQ <= pQuantityCalculationRule.ChargeByHalfOfADayCheckOutDelayTime Тогда
						vLQ = 12;
						rRemarks = NStr("en='Late check out for half a day';ru='Задержка выезда на полсуток';de='Abreiseverzögerung um 12 Stunden'");
						vQ = vQ + Round(vLQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли pQuantityCalculationRule.Do1DayCheckOutDelayCharge Тогда
						vLQ = 24;
						vQ = vQ + Round(vLQ/24, 7);
						rIsDayUse = True;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		// Check for minimum quantity
		Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
			vQ = pMinQuantity;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.LateCheckOut Тогда
		Если НЕ vSrvRHIsUsed Тогда
			vSrvRH = '00010101' + (pDateFrom - BegOfDay(pDateFrom));
		КонецЕсли;
		Если vSrvPH = 0 Тогда
			ВызватьИсключение("ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не задана периодичность услуги для вида расчета <Поздний выезд>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Поздний выезд>, период должен быть указан.");
		КонецЕсли;
		// Check if we should move check-in or check-out times to the reference hour
		Если НЕ pIsCheckOut Тогда
			Возврат 0;
		КонецЕсли;
		// Late check out part if accounting date equals check out date
		vQ = 0;
		Если vAD = vDT Тогда
			// Check should we add check out delay time to the quantity if guest took only 1 night
			vIsOneDay = False;
			vIsBetween1And2 = False;
			vTQ = (pDateTo - pDateFrom)/(3600*24);
			Если vTQ <= 1 Тогда
				vIsOneDay = True;
			ИначеЕсли vTQ < 1.5 Тогда
				vIsBetween1And2 = True;
			КонецЕсли;
			Если vIsOneDay And pIsCheckIn Тогда
				Если НЕ pQuantityCalculationRule.FirstDayEndsAtReferenceHourTime Тогда
					// No late check out at all
					Возврат 0;
				КонецЕсли;
			КонецЕсли;
			// Calculate base for delay time
			vDFRH = Дата(Year(pDateFrom), Month(pDateFrom), Day(pDateFrom), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
			vDTRH = Дата(Year(pDateTo), Month(pDateTo), Day(pDateTo), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
			Если pQuantityCalculationRule.CalculateDelayFromCheckOutTimeForFirstDay And 
			   vIsBetween1And2 And pIsCheckIn And pDateFrom > vDFRH Тогда
				vDTB = Дата(Year(pDateTo), Month(pDateTo), Day(pDateTo), Hour(pDateFrom), Minute(pDateFrom), Second(pDateFrom));
			Иначе
				vDTB = vDTRH;
			КонецЕсли;
			// Calculate delay time
			Если pDateTo > vDTB Тогда
				vLQ = (pDateTo - vDTB)/3600;
				Если vLQ <= pQuantityCalculationRule.FreeOfChargeCheckOutDelayTime Тогда
					vLQ = 0;
					vQ = vQ + Round(vLQ/24, 7);
				ИначеЕсли vLQ <= pQuantityCalculationRule.ChargeByHoursCheckOutDelayTime Тогда
					Если vSrvLCRR = Перечисления.QuantityRoundingRules.Int Тогда
						vLQ = Int(vLQ);
					ИначеЕсли vSrvLCRR = Перечисления.QuantityRoundingRules.Round Тогда
						vLQ = Round(vLQ, 0);
					ИначеЕсли vSrvLCRR = Перечисления.QuantityRoundingRules.Full Тогда
						Если Int(vLQ) <> vLQ Тогда
							vLQ = Int(vLQ) + 1;
						КонецЕсли;
					КонецЕсли;
					rRemarks = NStr("ru = 'Задержка выезда на " + vLQ + " часов'; en = 'Late check out for " + vLQ + " hours'; de = 'Late check out for " + vLQ + " hours'");
					vQ = vQ + Round(vLQ/24, 7);
					rIsDayUse = True;
				ИначеЕсли vLQ <= pQuantityCalculationRule.ChargeByQuarterOfADayCheckOutDelayTime Тогда
					vLQ = 6;
					rRemarks = NStr("ru = 'Задержка выезда на " + vLQ + " часов'; en = 'Late check out for " + vLQ + " hours'; de = 'Late check out for " + vLQ + " hours'");
					vQ = vQ + Round(vLQ/24, 7);
					rIsDayUse = True;
				ИначеЕсли vLQ <= pQuantityCalculationRule.ChargeByHalfOfADayCheckOutDelayTime Тогда
					vLQ = 12;
					rRemarks = "Задержка выезда на полсуток";
					vQ = vQ + Round(vLQ/24, 7);
					rIsDayUse = True;
				ИначеЕсли pQuantityCalculationRule.Do1DayCheckOutDelayCharge Тогда
					vLQ = 24;
					vQ = vQ + Round(vLQ/24, 7);
					rIsDayUse = True;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если vSrvPH <> 24 Тогда
			// Recalculate late check-out
			vQ = Round(vQ*(24/vSrvPH), 0);
		КонецЕсли;
		// Check for minimum quantity
		Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
			vQ = pMinQuantity;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.EarlyCheckIn Or 
	      vSrvQCR = Перечисления.QuantityCalculationRuleTypes.BreakfastEarlyCheckIn Тогда
		Если НЕ vSrvRHIsUsed Тогда
			vSrvRH = '00010101' + (pDateFrom - BegOfDay(pDateFrom));
		КонецЕсли;
		Если vSrvPH = 0 Тогда
			ВызватьИсключение(NStr("en='ERR: Error calling cmCalculateServiceQuantity function.
			               |CAUSE: Услуга period in hours is not specified for Количество calculation rule <Early check-in>.
						   |DESC: Услуга period in hours should not be equal 0 hours for Количество calculation rule <Early check-in>.';
					   |ru='ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не задана периодичность услуги для вида расчета <Ранний заезд>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Ранний заезд>, период должен быть указан.';
					   |de='ERR: Fehler bei Aufruf der Funktion cmCalculateServiceQuantity.
					       |CAUSE: Die Regelmäßigkeit für die Abrechnungsart <Frühe Anreise> ist nicht angegeben.
						   |DESC: Bei einer Dienstleistung, für die die Quantität nach der Abrechnungsart <Frühe Anreise> berechnet wird, muss der Zeitraum angegeben sein.'"));
		КонецЕсли;
		Если НЕ pIsCheckIn Тогда
			Возврат 0;
		КонецЕсли;
		// Early check in part if accounting date equals check in date
		vQ = 0;
		Если vAD = vDF Тогда
			vSkipEarlyCheckIn = False;
			vIsOneDay = False;
			vTQ = (pDateTo - pDateFrom)/(3600*24);
			Если vTQ <= 1 Тогда
				vIsOneDay = True;
			КонецЕсли;
			Если vIsOneDay Тогда
				Если НЕ pQuantityCalculationRule.FirstDayStartsAtReferenceHourTime Тогда
					// No early check-in at all
					vSkipEarlyCheckIn = True;
				КонецЕсли;
			КонецЕсли;
			Если НЕ vSkipEarlyCheckIn Тогда
				vDFRH = Дата(Year(pDateFrom), Month(pDateFrom), Day(pDateFrom), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
				Если pDateFrom < vDFRH Тогда
					vEQ = (vDFRH - pDateFrom)/3600;
					Если vEQ <= pQuantityCalculationRule.FreeOfChargeEarlyCheckInTime Тогда
						vEQ = 0;
						vQ = vQ + Round(vEQ/24, 7);
					ИначеЕсли vEQ <= pQuantityCalculationRule.ChargeByHoursEarlyCheckInTime Тогда
						Если vSrvECRR = Перечисления.QuantityRoundingRules.Int Тогда
							vEQ = Int(vEQ);
						ИначеЕсли vSrvECRR = Перечисления.QuantityRoundingRules.Round Тогда
							vEQ = Round(vEQ, 0);
						ИначеЕсли vSrvECRR = Перечисления.QuantityRoundingRules.Full Тогда
							Если Int(vEQ) <> vEQ Тогда
								vEQ = Int(vEQ) + 1;
							КонецЕсли;
						КонецЕсли;
						rRemarks = NStr("ru = 'Ранний заезд на " + vEQ + " часов'; en = 'Early check in for " + vEQ + " hours'; de = 'Early check in for " + vEQ + " hours'");
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли vEQ <= pQuantityCalculationRule.ChargeByQuarterOfADayEarlyCheckInTime Тогда
						vEQ = 6;
						rRemarks = NStr("ru = 'Ранний заезд на " + vEQ + " часов'; en = 'Early check in for " + vEQ + " hours'; de = 'Early check in for " + vEQ + " hours'");
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли vEQ <= pQuantityCalculationRule.ChargeByHalfOfADayEarlyCheckInTime Тогда
						vEQ = 12;
						rRemarks = NStr("en='Early check in for half of a day';ru='Ранний заезд на полсуток';de='Um 12 Stunden frühere Anreise'");
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					ИначеЕсли pQuantityCalculationRule.Do1DayEarlyCheckInCharge Тогда
						vEQ = 24;
						vQ = vQ + Round(vEQ/24, 7);
						rIsDayUse = True;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если vSrvPH <> 24 Тогда
			// Recalculate early check-in
			vQ = Round(vQ*(24/vSrvPH), 0);
		КонецЕсли;
		// Check for minimum quantity
		Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
			vQ = pMinQuantity;
		КонецЕсли;
		// Move accounting date one day back
		Если vQ <> 0 And vSrvQCR = Перечисления.QuantityCalculationRuleTypes.EarlyCheckIn Тогда
			pAccountingDate = pAccountingDate - 24*3600;
		КонецЕсли;			
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.ReferenceHourTransfers Тогда
		Если НЕ vSrvRHIsUsed Тогда
			vSrvRH = '00010101' + (pDateFrom - BegOfDay(pDateFrom));
		КонецЕсли;
		Если vSrvPH <> 24 Тогда
			ВызватьИсключение(NStr("en='ERR: Error calling cmCalculateServiceQuantity function.
			               |CAUSE: Услуга period in hours is wrong for Количество calculation rule <Reference hour transfers>.
						   |DESC: Услуга period in hours should be equal 24 hours for Количество calculation rule <Reference hour transfers>.';
					   |ru='ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не верно задана периодичность услуги для вида расчета <Переходы через расчетный час>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Переходы через расчетный час>, период должен быть равен 24 часам.';
					   |de='ERR: Fehler bei Aufruf der Funktion cmCalculateServiceQuantity.
					       |CAUSE: Falsche Eingabe der Regelmäßigkeit für die Abrechnungsart <Größer als die Abrechnungsstunde>.
						   |DESC: Bei einer Dienstleistung, für die die Quantität nach der Abrechnungsart <Größer als die Abrechnungsstunde> berechnet wird, muss der Zeitraum 24 Stunden betragen.'"));
		КонецЕсли;
		vQ = 0;
		vD = Дата(Year(vDF), Month(vDF), Day(vDF), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
		vNDRH = vD + 24*3600;
		While vD < pDateTo Do
			Если vD >= pDateFrom Тогда
				Если vAD = BegOfDay(vD) Тогда
					vQ = 1;
					// Check for minimum quantity
					Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
						vQ = pMinQuantity;
					КонецЕсли;
					Возврат vQ;
				КонецЕсли;
			КонецЕсли;
			vD = vD + 24*3600;
		EndDo;
		Если pDateTo <= vNDRH And vAD = BegOfDay(pDateFrom) And 
		   pIsCheckIn And pIsCheckOut And 
		   pQuantityCalculationRule.ChargeMealsAtFirstDay Тогда
			vQ = 1;
			// Check for minimum quantity
			Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
				vQ = pMinQuantity;
			КонецЕсли;
			Возврат vQ;
		КонецЕсли;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
		Если НЕ vSrvRHIsUsed Тогда
			ВызватьИсключение(NStr("en='ERR: Error calling cmCalculateServiceQuantity function.
			               |CAUSE: Reference hour is not defined for Количество calculation rule <Breakfast>.
						   |DESC: Reference hour is mandatory parameter for Количество calculation rule <Breakfast> and should be filled.';
					   |ru='ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не определен расчетный час для вида расчета <Завтрак>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Завтрак>, должен быть указан расчетный час.';
					   |de='ERR: Fehler bei Aufruf der Funktion cmCalculateServiceQuantity.
					       |CAUSE: Die Abrechnungsstunde für die Abrechnungsart <Frühstück> ist nicht festgelegt.
						   |DESC: Bei einer Dienstleistung, für die die Quantität nach der Abrechnungsart <Frühstück> berechnet wird, muss die Abrechnungsstunde angegeben sein.'"));
		КонецЕсли;
		Если vSrvPH <> 24 Тогда
			ВызватьИсключение(NStr("en='ERR: Error calling cmCalculateServiceQuantity function.
			               |CAUSE: Услуга period in hours is wrong for Количество calculation rule <Breakfast>.
						   |DESC: Услуга period in hours should be equal 24 hours for Количество calculation rule <Breakfast>.';
					   |ru='ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не верно задана периодичность услуги для вида расчета <Завтрак>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Завтрак>, период должен быть равен 24 часам.';
					   |de='ERR: Fehler bei Aufruf der Funktion cmCalculateServiceQuantity.
					       |CAUSE: Falsche Eingabe der Regelmäßigkeit für die Abrechnungsart <Frühstück>.
						   |DESC: Bei einer Dienstleistung, für die die Quantität nach der Abrechnungsart <Frühstück> berechnet wird, muss der Zeitraum 24 Stunden betragen.'"));
		КонецЕсли;
		vQ = 0;
		// The only difference between ReferenceHourTransfers and Breakfast is
		// that first day is not calculated for breakfast
		vAD = vAD + 24*3600;
		vD = Дата(Year(vDF), Month(vDF), Day(vDF), Hour(vSrvRH), Minute(vSrvRH), Second(vSrvRH));
		vFDRH = vD;
		vNDRH = vD + 24*3600;
		While vD < pDateTo Do
			Если vD >= pDateFrom Тогда
				Если BegOfDay(vD) <> vDF Тогда
					Если vAD = BegOfDay(vD) Тогда
						vQ = 1;
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
						pAccountingDate = pAccountingDate + 24*3600;
						Возврат vQ;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			vD = vD + 24*3600;
		EndDo;
		Если pDateTo <= vNDRH And BegOfDay(pAccountingDate) = BegOfDay(pDateFrom) And 
		   pIsCheckIn And pIsCheckOut Тогда
			Если pDateFrom <= vFDRH Тогда
				pAccountingDate = pAccountingDate - 24*3600;
				vQ = 1;
			ИначеЕсли pQuantityCalculationRule.ChargeMealsAtFirstDay Тогда
				pAccountingDate = pAccountingDate - 24*3600;
				vQ = 1;
			КонецЕсли;
			// Check for minimum quantity
			Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
				vQ = pMinQuantity;
			КонецЕсли;
		КонецЕсли;
		pAccountingDate = pAccountingDate + 24*3600;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.NumberOfDays Тогда
		// Calculate day price if hotel product with fixed cost is choosen
		Если pDocumentObj <> Неопределено And ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка) And pPrice > 0 Тогда
			vProductSum = pDocumentObj.ПутевкаКурсовка.Сумма;
			Если pDocumentObj.ПутевкаКурсовка.FixProductCost And
			   vProductSum > 0 Тогда
				Если pDocumentObj.ПутевкаКурсовка.FixProductPeriod Or pDocumentObj.ПутевкаКурсовка.FixPlannedPeriod Тогда
					// Get duration from the product 
					vDuration = pDocumentObj.ПутевкаКурсовка.Продолжительность;
				Иначе
					// Get duration from the document
					Если TypeOf(pDocumentObj) = Type("DocumentObject.Размещение") And pDocumentObj.FixReservationConditions And pReservationObj <> Неопределено Тогда
						vDuration = pReservationObj.Продолжительность;
					Иначе
						vDuration = pDocumentObj.Продолжительность;
					КонецЕсли;
				КонецЕсли;
				Если vDuration > 0 Тогда
					vQ = 0;
					// Calculate effective day price
					vDayPrice = Int(vProductSum/vDuration);
					// Set last day price to the rest of the product cost
					vLastDayPrice = vProductSum - vDayPrice*(vDuration - 1);
					// Get check-out date based on duration
					vDT = vDF + (vDuration-1)*24*3600;
					// Update current ГруппаНомеров rate price
					Если vAD = vDT Тогда
						pPrice = vLastDayPrice;
						Если ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка.Валюта) Тогда
							pCurrency = pDocumentObj.ПутевкаКурсовка.Валюта;
						КонецЕсли;
						vQ = 1;
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
					ИначеЕсли vAD < vDT Тогда
						pPrice = vDayPrice;
						Если ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка.Валюта) Тогда
							pCurrency = pDocumentObj.ПутевкаКурсовка.Валюта;
						КонецЕсли;
						vQ = 1;
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
					Иначе
						pPrice = 0;
						vQ = 0;
					КонецЕсли;
					// Возврат
					Возврат vQ;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		// Normal calculation
		vQ = 0;
		Если vDF = vDT Тогда
			Если vAD = vDF Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
				Возврат vQ;
			КонецЕсли;
		Иначе
			Если (vAD >= vDF) And (vAD < vDT) Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
				Возврат vQ;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.ПутевкаКурсовка Тогда
		// Calculate day price if hotel product with fixed cost is choosen
		Если pDocumentObj <> Неопределено And ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка) And pPrice > 0 Тогда
			vProductSum = pDocumentObj.ПутевкаКурсовка.Сумма;
			Если pDocumentObj.ПутевкаКурсовка.FixProductCost And
			   vProductSum > 0 Тогда
				Если pDocumentObj.ПутевкаКурсовка.FixProductPeriod Or pDocumentObj.ПутевкаКурсовка.FixPlannedPeriod Тогда
					// Get duration from the product 
					vDuration = pDocumentObj.ПутевкаКурсовка.Продолжительность;
				Иначе
					// Get duration from the document
					Если TypeOf(pDocumentObj) = Type("DocumentObject.Размещение") And pDocumentObj.FixReservationConditions And pReservationObj <> Неопределено Тогда
						vDuration = pReservationObj.Продолжительность;
					Иначе
						vDuration = pDocumentObj.Продолжительность;
					КонецЕсли;
				КонецЕсли;
				Если vDuration > 0 Тогда
					vQ = 0;
					// Calculate effective day price
					vDayPrice = Int(vProductSum/vDuration);
					// Set last day price to the rest of the product cost
					vLastDayPrice = vProductSum - vDayPrice*(vDuration - 1);
					// Get check-out date based on duration
					vDT = vDF + (vDuration-1)*24*3600;
					// Update current ГруппаНомеров rate price
					Если vAD = vDT Тогда
						pPrice = vLastDayPrice;
						Если ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка.Валюта) Тогда
							pCurrency = pDocumentObj.ПутевкаКурсовка.Валюта;
						КонецЕсли;
						vQ = 1;
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
					ИначеЕсли vAD < vDT Тогда
						pPrice = vDayPrice;
						Если ЗначениеЗаполнено(pDocumentObj.ПутевкаКурсовка.Валюта) Тогда
							pCurrency = pDocumentObj.ПутевкаКурсовка.Валюта;
						КонецЕсли;
						vQ = 1;
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
					Иначе
						pPrice = 0;
						vQ = 0;
					КонецЕсли;
					// Возврат
					Возврат vQ;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		// Normal calculation
		vQ = 0;		
		// 1. Main part which is 1 actually
		Если vDF = vDT Тогда
			Если vAD = vDF And НЕ pIsRoomChange Тогда
				vQ = 1;
			КонецЕсли;
		Иначе
			Если vAD >= vDF And vAD < vDT Тогда
				vQ = 1;
			КонецЕсли;
		КонецЕсли;
		// 2. Late check out part if accounting date equals check out date
		Если vAD = vDT And pIsCheckOut And vAD > vDF Тогда
			// Calculate base for delay time
			vDTB = Дата(Year(pDateTo), Month(pDateTo), Day(pDateTo), Hour(pDateFrom), Minute(pDateFrom), Second(pDateFrom));
			// Calculate delay time
			vLQ = Int((pDateTo - vDTB)/3600);
			Если vLQ >= 0 Тогда
				Если vLQ <= pQuantityCalculationRule.ChargeByHalfOfADayCheckOutDelayTime Тогда
					vLQ = 12;
					rRemarks = NStr("en='Late check out for half a day';ru='Задержка выезда на полсуток';de='Abreiseverzögerung um 12 Stunden'");
					vQ = vQ + Round(vLQ/24, 7);
					rIsDayUse = True;
				Иначе
					vLQ = 24;
					vQ = vQ + Round(vLQ/24, 7);
					rIsDayUse = True;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Monthly Тогда
		vQ = 0;
		// Monthly is a calculation rule where price is specified per month
		// Функция always returns 1 and recalculate price as 
		// Price/(Number of days in accounting date month)
		Если vSrvPH <> 24 Тогда
			ВызватьИсключение(NStr("en='ERR: Error calling cmCalculateServiceQuantity function.
			               |CAUSE: Услуга period in hours is wrong for Количество calculation rule <Monthly>.
						   |DESC: Услуга period in hours should be equal 24 hours for Количество calculation rule <Monthly>.';
					   |ru='ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не верно задана периодичность услуги для вида расчета <Помесячно>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Помесячно>, период должен быть равен 24 часам.';
					   |de='ERR: Fehler bei Aufruf der Funktion cmCalculateServiceQuantity.
					       |CAUSE: Falsche Eingabe der Regelmäßigkeit für die Abrechnungsart <Größer als die Abrechnungsstunde>.
						   |DESC: Bei einer Dienstleistung, für die die Quantität nach der Abrechnungsart <Größer als die Abrechnungsstunde> berechnet wird, muss der Zeitraum 24 Stunden betragen.'"));
		КонецЕсли;
		vProbeDate = vDF;
		Если Day(vAD) >= Day(vDF) Тогда
			vProbeDate = vAD;
		Иначе
			vProbeDate = BegOfDay(BegOfMonth(vAD) - 1);
		КонецЕсли;			
		vNumDaysPerMonth = Round((EndOfMonth(vProbeDate) - BegOfMonth(vProbeDate))/(24*3600), 0);
		vPrice = Round(pPrice/vNumDaysPerMonth, 2);
		vMonthes = Month(vAD) - Month(vDF);
		Если vMonthes < 0 Тогда
			vMonthes = vMonthes + 12;
		КонецЕсли;
		Если vMonthes = 0 Тогда
			vMonthes = 1;
		КонецЕсли;
		Если vDF = vDT Тогда
			Если vAD = vDF Тогда
				pPrice = vPrice;
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
				Возврат vQ;
			КонецЕсли;
		Иначе
			Если vAD < vDT Тогда
				// To get per month price exactly as it was in ГруппаНомеров rate we calculate it
				// special way for the last day of month
				//Если BegOfDay(vAD) = (BegOfDay(AddMonth(vDF, vMonthes)) - 24*3600) Тогда
				Если Day(vAD) = vNumDaysPerMonth Тогда
					pPrice = pPrice - vPrice*(vNumDaysPerMonth - 1);
				Иначе
					pPrice = vPrice;
				КонецЕсли;
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
				Возврат vQ;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.OneTimeCharge Тогда
		vQ = 0;
		// Returns 1 for the first day only
		Если pIsOneTimeChargeNecessary And pIsCheckIn Тогда
			Если vDF = vAD Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
				Возврат vQ;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Бронирование Тогда
		vQ = 0;
		// Returns 1 for the first day only if this function is called from reservation or
		// accommodation is filled based on reservation
		Если pIsReservation And pIsCheckIn Тогда
			Если vDF = vAD Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
				Возврат vQ;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Int Тогда
		// Calculates int number of periods for the specified period.
		// Returns this number devided by number of days for the specified period
		vQ = Int((pDateTo - cm0SecondShift(pDateFrom))/(3600*vSrvPH));
		Если vSrvPH <> 24 Or vQ < 1 Тогда
			Если vAD <> vDF Тогда
				vQ = 0;
			Иначе
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			КонецЕсли;
		Иначе
			vCurQ = (vAD - vDF)/(3600*24) + 1;
			Если vCurQ <= Int(vQ) Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			ИначеЕсли vQ > (vCurQ - 1) Тогда
				vQ = vQ - vCurQ + 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			Иначе
				vQ = 0;
			КонецЕсли;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Precise Тогда
		// Calculates number of periods for the specified period.
		// Returns this number devided by number of days for the specified period
		vQ = (pDateTo - cm0SecondShift(pDateFrom))/(3600*vSrvPH);
		Если (vQ - Int(vQ)) > pQuantityCalculationRule.RoomExaminationFreeOfChargeTime Тогда
			vQ = Round(Int(vQ), 7);
		Иначе
			vQ = Int(vQ);
		КонецЕсли;
		Если vSrvPH <> 24 Or vQ < 1 Тогда
			Если vAD <> vDF Тогда
				vQ = 0;
			Иначе
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			КонецЕсли;
		Иначе
			vCurQ = (vAD - vDF)/(3600*24) + 1;
			Если vCurQ <= Int(vQ) Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			ИначеЕсли vQ > (vCurQ - 1) Тогда
				vQ = vQ - vCurQ + 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			Иначе
				vQ = 0;
			КонецЕсли;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Round Тогда
		// Calculates rounded number of periods for the specified period.
		// Returns this number devided by number of days for the specified period
		vQ = (pDateTo - cm0SecondShift(pDateFrom))/(3600*vSrvPH);
		Если (vQ - Int(vQ)) > pQuantityCalculationRule.RoomExaminationFreeOfChargeTime Тогда
			vQ = Round(Int(vQ), 0);
		Иначе
			vQ = Int(vQ);
		КонецЕсли;
		Если vSrvPH <> 24 Or vQ < 1 Тогда
			Если vAD <> vDF Тогда
				vQ = 0;
			Иначе
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			КонецЕсли;
		Иначе
			vCurQ = (vAD - vDF)/(3600*24) + 1;
			Если vCurQ <= Int(vQ) Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			ИначеЕсли vQ > (vCurQ - 1) Тогда
				vQ = vQ - vCurQ + 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			Иначе
				vQ = 0;
			КонецЕсли;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Full Тогда
		// Calculates full number of periods for the specified period.
		// Returns this number devided by number of days for the specified period
		vQ = (pDateTo - cm0SecondShift(pDateFrom))/(3600*vSrvPH);
		Если (vQ - Int(vQ)) > pQuantityCalculationRule.RoomExaminationFreeOfChargeTime Тогда
			vQ = Int(vQ) + 1;
		Иначе
			vQ = Int(vQ);
		КонецЕсли;
		Если vSrvPH <> 24 Or vQ < 1 Тогда
			Если vAD <> vDF Тогда
				vQ = 0;
			Иначе
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			КонецЕсли;
		Иначе
			vCurQ = (vAD - vDF)/(3600*24) + 1;
			Если vCurQ <= Int(vQ) Тогда
				vQ = 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			ИначеЕсли vQ > (vCurQ - 1) Тогда
				vQ = vQ - vCurQ + 1;
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			Иначе
				vQ = 0;
			КонецЕсли;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.Hostel Тогда
		// Calculates number of days of accommodation for the given month and charge it by one service at check-in or the first day of month
		Если vSrvPH <> 24 Тогда
			ВызватьИсключение("ERR: Ошибка вызова функции cmCalculateServiceQuantity.
					       |CAUSE: Не верно задана периодичность услуги для вида расчета <Общежитие>.
						   |DESC: У услуги, для которой количество рассчитывается по виду расчета <Общежитие>, период должен быть равен 24 часам.");
		КонецЕсли;
		Если pAccommodationPeriods = Неопределено Тогда
			Если vAD = vDF Or vAD = BegOfMonth(vAD) Тогда
				vED = Min(BegOfDay(EndOfMonth(vAD) + 1), BegOfDay(vDT));
				vQ = (vED - vAD)/(3600*vSrvPH);
				// Check for minimum quantity
				Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
					vQ = pMinQuantity;
				КонецЕсли;
			Иначе
				vQ = 0;
			КонецЕсли;
		Иначе
			vQ = 0;
			For Each vAccommodationPeriodsRow In pAccommodationPeriods Do
				vDF = BegOfDay(vAccommodationPeriodsRow.CheckInDate);
				vDT = BegOfDay(vAccommodationPeriodsRow.ДатаВыезда);
				Если vAD >= vDF And vAD < vDT And vDF < vDT Or vAD = vDF And vAD = vDT And vDF = vDT Тогда
					Если vAD = vDF Or vAD = BegOfMonth(vAD) Тогда
						vED = Min(BegOfDay(EndOfMonth(vAD) + 1), vDT);
						vQ = (vED - vAD)/(3600*vSrvPH);
						// Check for minimum quantity
						Если pMinQuantity <> 0 And vQ < pMinQuantity Тогда
							vQ = pMinQuantity;
						КонецЕсли;
					КонецЕсли;
					Break;
				КонецЕсли;
			EndDo;
		КонецЕсли;
		Возврат vQ;
	ИначеЕсли vSrvQCR = Перечисления.QuantityCalculationRuleTypes.External Тогда
		// Calculates quantity according to the external algorithm
		Execute(TrimR(pQuantityCalculationRule.ExternalAlgorithm.Algorithm));
		Возврат vQ;
	КонецЕсли;	
	Возврат 0;
КонецФункции //cmCalculateServiceQuantity

//-----------------------------------------------------------------------------
// Description: Returns client balance by client identification card code.
//              Функция can return XDTO object or comma separated values string and 
//              could be called as web-service or thru COM connection
// Parameters: Card identifier, Type of function output
// Возврат value: XDTO or String
//-----------------------------------------------------------------------------
Функция cmGetClientIdentificationCardBalance(pIdentifier, pOutputType = "CSV", pExternalSystemCode = "") Экспорт
	WriteLogEvent("Получение баланса по карте идентификации клиента", EventLogLevel.Information, , , 
	              "Идентификатор карты: " + pIdentifier + Chars.LF + 
	              "Код внешней системы: " + pExternalSystemCode);
	
	// Initialize return string
	vRetStr = "";
	vBalance = 0;
	vLimit = 0;
	vClientFullName = "";
	vHotelName = "";
	vRoomCode = "";
	vCheckInDate = '00010101';
	vCheckOutDate = '00010101';
	vIsCheckedOut = False;
	vIsBlocked = False;
	vBlockReason = "";
	vCreditLimit = 0;
	vGuestGroupCode	= 0;
	vCustomerName = "";
	vPaymentMethodName = "";
	vFolioCurrencyCode = "";
	vRoomRateCode = "";
	vDiscount = 0;
	vDiscountType = Неопределено;
	vDiscountCard = Неопределено;
	vClientCode = "";
	
	// Try to find client identification card by identifier
	vQry =  New Query();
	vQry.Text = 
	"SELECT
	|	КартаИД.Ref,
	|	КартаИД.CreateDate AS CreateDate,
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
	|	КартаИД.BlockReason,
	|	ISNULL(КартаИД.IdentificationCardType.DoNotUseChargingRules, FALSE) AS DoNotUseChargingRules,
	|	ISNULL(КартаИД.IdentificationCardType.ExternalSystemsAllowed, &qEmptyString) AS ExternalSystemsAllowed,
	|	1 AS ПорядокСортировки
	|FROM
	|	Catalog.КартаИД AS КартаИД
	|WHERE
	|	NOT КартаИД.DeletionMark
	|	AND КартаИД.Identifier = &qIdentifier
	|
	|UNION ALL
	|
	|SELECT
	|	ДисконтныеКарты.Ref,
	|	ISNULL(Folios.ДатаДок, ДисконтныеКарты.ValidFrom),
	|	ДисконтныеКарты.Code,
	|	ДисконтныеКарты.Description,
	|	ДисконтныеКарты.IsBlocked,
	|	ISNULL(NOT Folios.ДокОснование.СтатусРазмещения.ЭтоГости, TRUE),
	|	ДисконтныеКарты.Identifier,
	|	Folios.ДокОснование,
	|	Folios.Ref,
	|	Folios.ГруппаГостей,
	|	ДисконтныеКарты.Клиент,
	|	Folios.НомерРазмещения,
	|	ISNULL(Folios.DateTimeFrom, &qEmptyDate),
	|	ISNULL(Folios.DateTimeTo, &qEmptyDate),
	|	ISNULL(Folios.Гостиница, &qCurrentHotel),
	|	ДисконтныеКарты.Примечания,
	|	FALSE,
	|	&qEmptyString,
	|	CASE
	|		WHEN Folios.Ref IS NULL 
	|			THEN 3
	|		ELSE 2
	|	END
	|FROM
	|	Catalog.ДисконтныеКарты AS DiscountCards
	|		LEFT JOIN Document.СчетПроживания AS Folios
	|		ON (NOT Folios.IsClosed)
	|			AND (NOT Folios.DeletionMark)
	|			AND (Folios.Клиент = ДисконтныеКарты.Клиент
	|					AND Folios.Клиент <> &qEmptyClient
	|				OR Folios.ДокОснование.ДисконтКарт = ДисконтныеКарты.Ref)
	|			AND (Folios.Контрагент = &qEmptyCustomer
	|				OR Folios.Контрагент = Folios.Гостиница.IndividualsCustomer
	|				OR Folios.Контрагент IN HIERARCHY (&qIndividualsFolder))
	|			AND (Folios.Гостиница.AdditionalServicesFolioCondition = &qEmptyString
	|				OR Folios.Гостиница.AdditionalServicesFolioCondition <> &qEmptyString
	|					AND Folios.Description = Folios.Гостиница.AdditionalServicesFolioCondition)
	|WHERE
	|	NOT ДисконтныеКарты.DeletionMark
	|	AND ДисконтныеКарты.Identifier = &qIdentifier
	|	AND ДисконтныеКарты.ValidFrom <= &qCurrentDate
	|	AND (ДисконтныеКарты.ValidTo = &qEmptyDate
	|			OR ДисконтныеКарты.ValidTo <> &qEmptyDate
	|				AND ДисконтныеКарты.ValidTo >= &qCurrentDate)
	|
	|ORDER BY
	|	ПорядокСортировки,
	|	CreateDate DESC,
	|	Code DESC";
	vQry.УстановитьПараметр("qIdentifier", СокрЛП(pIdentifier));
	vQry.УстановитьПараметр("qEmptyClient", Справочники.Clients.EmptyRef());
	vQry.УстановитьПараметр("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	vQry.УстановитьПараметр("qIndividualsFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
	vQry.УстановитьПараметр("qEmptyString", "                                                  ");
	vQry.УстановитьПараметр("qCurrentDate", CurrentDate());
	vQry.УстановитьПараметр("qEmptyDate", '00010101');
	vQry.УстановитьПараметр("qCurrentHotel", ПараметрыСеанса.ТекущаяГостиница);
	vCards = vQry.Execute().Unload();
	Если vCards.Count() > 0 Тогда
		vCardRow = vCards.Get(0);
		
		// Check if external system is allowed
		Если НЕ IsBlankString(pExternalSystemCode) And НЕ IsBlankString(vCardRow.ExternalSystemsAllowed) Тогда
			Если Find(vCardRow.ExternalSystemsAllowed, СокрЛП(pExternalSystemCode)) = 0 Тогда
				vErrorMessage = СокрЛП(vCardRow.Ref.IdentificationCardType) + NStr("en=' card is not allowed!'; ru=' карта не принимается!'; de=' Karte ist nicht erlaubt!'");
				Если pOutputType = "CSV" Тогда
					ВызватьИсключение vErrorMessage;
				Иначе
					vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/restaurant/", "ClientIdentificationCardBalance"));
					vRetXDTO.Balance = 0;
					vRetXDTO.Клиент = vClientFullName;
					vRetXDTO.Гостиница = vHotelName;
					vRetXDTO.НомерРазмещения = vRoomCode;
					vRetXDTO.CheckInDate = vCheckInDate;
					vRetXDTO.ДатаВыезда = vCheckOutDate;
					vRetXDTO.IsCheckedOut = vIsCheckedOut;
					vRetXDTO.IsBlocked = True;
					vRetXDTO.BlockReason = Left(vErrorMessage, 100);
					vRetXDTO.CreditLimit = vCreditLimit;
					vRetXDTO.ГруппаГостей = vGuestGroupCode;
					vRetXDTO.Контрагент = vCustomerName;
					vRetXDTO.СпособОплаты = vPaymentMethodName;
					vRetXDTO.ВалютаЛицСчета = vFolioCurrencyCode;
					vRetXDTO.Тариф = vRoomRateCode;
					vRetXDTO.Скидка = vDiscount;
					vRetXDTO.ТипСкидки = ?(ЗначениеЗаполнено(vDiscountType), СокрЛП(vDiscountType.Description), "");
					vRetXDTO.ДисконтКарт = ?(ЗначениеЗаполнено(vDiscountCard), СокрЛП(vDiscountCard.Identifier), "");
					vRetXDTO.ClientCode = vClientCode;
					Возврат vRetXDTO;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		// Get folio from the client identification card
		vFolioCondition = ?(ЗначениеЗаполнено(vCardRow.Гостиница), СокрЛП(vCardRow.Гостиница.AdditionalServicesFolioCondition), "");
		vFolioRef = vCardRow.СчетПроживания;
		//vHotel = Неопределено;
		Если ЗначениеЗаполнено(vFolioRef) Тогда
			//vHotel = vFolioRef.Гостиница;
			vIsCheckedOut = vFolioRef.IsClosed;
			Если vFolioRef.IsClosed Тогда
				vCreditLimit = 0;
			ИначеЕсли ЗначениеЗаполнено(vFolioRef.Гостиница) Тогда
				Если vFolioRef.Гостиница.NoCreditLimit Тогда
					vCreditLimit = 999999999;
				Иначе
					vCreditLimit = vFolioRef.CreditLimit;
				КонецЕсли;
			КонецЕсли;
			vCustomerName = ?(ЗначениеЗаполнено(vFolioRef.Контрагент), СокрЛП(vFolioRef.Контрагент.Description), "");
			vPaymentMethodName = ?(ЗначениеЗаполнено(vFolioRef.СпособОплаты), СокрЛП(vFolioRef.СпособОплаты.Description), "");
			vFolioCurrencyCode = ?(ЗначениеЗаполнено(vFolioRef.ВалютаЛицСчета), СокрЛП(vFolioRef.ВалютаЛицСчета.Code), "");
			Если vCardRow.DoNotUseChargingRules Or IsBlankString(vFolioCondition) Or НЕ IsBlankString(vFolioCondition) And Find(vFolioRef.Description, vFolioCondition) > 0 Тогда
				vBalance = vFolioRef.GetObject().pmGetBalance('39991231235959', , , vLimit);
				vBalance = vBalance - vLimit;
			КонецЕсли;
			Если ЗначениеЗаполнено(vFolioRef.ДокОснование) And 
			   (TypeOf(vFolioRef.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(vFolioRef.ДокОснование) = Type("DocumentRef.Бронирование")) Тогда
				vRoomRateCode = ?(ЗначениеЗаполнено(vFolioRef.ДокОснование.Тариф), СокрЛП(vFolioRef.ДокОснование.Тариф.Description), "");
			КонецЕсли;
		КонецЕсли;
		vClientFullName = ?(ЗначениеЗаполнено(vCardRow.Клиент), СокрЛП(vCardRow.Клиент.FullName), "");
		vClientCode = ?(ЗначениеЗаполнено(vCardRow.Клиент), СокрЛП(vCardRow.Клиент.Code), "");
		vHotelName = ?(ЗначениеЗаполнено(vCardRow.Гостиница), СокрЛП(vCardRow.Гостиница.Description), "");
		vRoomCode = ?(ЗначениеЗаполнено(vCardRow.НомерРазмещения), СокрЛП(vCardRow.НомерРазмещения.Description), "");
		vCheckInDate = vCardRow.DateTimeFrom;
		vCheckOutDate = vCardRow.DateTimeTo;
		vIsBlocked = vCardRow.IsBlocked;
		vBlockReason = СокрЛП(vCardRow.BlockReason);
		vGuestGroupCode	= ?(ЗначениеЗаполнено(vCardRow.ГруппаГостей), Number(vCardRow.ГруппаГостей.Code), 0);
		
		// Get discount data
		Если ЗначениеЗаполнено(vCardRow.СчетПроживания) And ЗначениеЗаполнено(vCardRow.СчетПроживания.FolioDiscountCard) And НЕ ЗначениеЗаполнено(vCardRow.ДокОснование) Тогда
			vDiscountCard = vCardRow.СчетПроживания.FolioDiscountCard;
			vDiscountType = vDiscountCard.ТипСкидки;
			vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vCardRow.Гостиница);
		ИначеЕсли ЗначениеЗаполнено(vCardRow.СчетПроживания) And ЗначениеЗаполнено(vCardRow.СчетПроживания.FolioDiscountType) And НЕ ЗначениеЗаполнено(vCardRow.ДокОснование) Тогда
			vDiscountType = vCardRow.СчетПроживания.FolioDiscountType;
			vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vCardRow.Гостиница);
		ИначеЕсли ЗначениеЗаполнено(vCardRow.ДокОснование) And 
		     (TypeOf(vCardRow.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(vCardRow.ДокОснование) = Type("DocumentRef.Бронирование") Or TypeOf(vCardRow.ДокОснование) = Type("DocumentRef.БроньУслуг")) And 
			  ЗначениеЗаполнено(vCardRow.ДокОснование.ДисконтКарт) Тогда
			vDiscountCard = vCardRow.ДокОснование.ДисконтКарт;
			vDiscountType = vDiscountCard.ТипСкидки;
			vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vCardRow.Гостиница);
		ИначеЕсли ЗначениеЗаполнено(vCardRow.ДокОснование) And 
		     (TypeOf(vCardRow.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(vCardRow.ДокОснование) = Type("DocumentRef.Бронирование") Or TypeOf(vCardRow.ДокОснование) = Type("DocumentRef.БроньУслуг")) And 
			  ЗначениеЗаполнено(vCardRow.ДокОснование.ТипСкидки) Тогда
			vDiscountType = vCardRow.ДокОснование.ТипСкидки;
			vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vCardRow.Гостиница);
		Иначе
			Если ЗначениеЗаполнено(vCardRow.Клиент) Тогда
				Если ЗначениеЗаполнено(vCardRow.Клиент.ТипСкидки) Тогда
					vDiscountType = vCardRow.Клиент.ТипСкидки;
					vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vCardRow.Гостиница);
				Иначе
					vDiscountCard = cmGetDiscountCardByClient(vCardRow.Клиент);
					Если ЗначениеЗаполнено(vDiscountCard) And ЗначениеЗаполнено(vDiscountCard.ТипСкидки) Тогда
						vDiscountType = vDiscountCard.ТипСкидки;
						vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vCardRow.Гостиница);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если ЗначениеЗаполнено(vDiscountType) And vDiscountType.DoNotApplyToExternalInterfaces Тогда
			vDiscount = 0;
			vDiscountType = Неопределено;
			vDiscountCard = Неопределено;
		КонецЕсли;
		
		// Add balances from the other parent document client folios
		Если ЗначениеЗаполнено(vCardRow.ДокОснование) And ЗначениеЗаполнено(vFolioRef) And НЕ vCardRow.DoNotUseChargingRules Тогда
			// Check if this folio is in charging rules
			vChargingRulesFolios = New СписокЗначений();
			vCardFolioIsInChargingRules = False;
			vCardParentDoc = vCardRow.ДокОснование;
			Если TypeOf(vCardParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(vCardParentDoc) = Type("DocumentRef.Бронирование") Тогда
				vCardParentDocGuestGroup = vCardParentDoc.ГруппаГостей;
				vChargingRules = vCardParentDoc.ChargingRules;
				Если vChargingRules.Find(vFolioRef, "ChargingFolio") <> Неопределено Тогда
					vCardFolioIsInChargingRules = True;
				Иначе
					Если ЗначениеЗаполнено(vCardParentDocGuestGroup) And vCardParentDocGuestGroup.ChargingRules.Count() > 0 Тогда
						vCardParentDocGuestGroupChargingRules = vCardParentDocGuestGroup.ChargingRules;
						Если vCardParentDocGuestGroupChargingRules.Find(vFolioRef, "ChargingFolio") <> Неопределено Тогда
							vCardFolioIsInChargingRules = True;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
				For Each vPDCRRow In vChargingRules Do
					Если vChargingRulesFolios.FindByValue(vPDCRRow.ChargingFolio) = Неопределено Тогда
						vChargingRulesFolios.Add(vPDCRRow.ChargingFolio);
					КонецЕсли;
				EndDo;
				Если ЗначениеЗаполнено(vCardParentDocGuestGroup) And vCardParentDocGuestGroup.ChargingRules.Count() > 0 Тогда
					vCardParentDocGuestGroupChargingRules = vCardParentDocGuestGroup.ChargingRules;
					For Each vPDGGCRRow In vCardParentDocGuestGroupChargingRules Do
						Если vChargingRulesFolios.FindByValue(vPDGGCRRow.ChargingFolio) = Неопределено Тогда
							vChargingRulesFolios.Add(vPDGGCRRow.ChargingFolio);
						КонецЕсли;
					EndDo;
				КонецЕсли;
			ИначеЕсли TypeOf(vCardParentDoc) = Type("DocumentRef.БроньУслуг") Or TypeOf(vCardParentDoc) = Type("DocumentRef.СоставКвоты") Тогда
				Если vFolioRef = vCardParentDoc.ChargingFolio Тогда
					vCardFolioIsInChargingRules = True;
				КонецЕсли;
				Если ЗначениеЗаполнено(vCardParentDoc.ChargingFolio) Тогда
					Если vChargingRulesFolios.FindByValue(vCardParentDoc.ChargingFolio) = Неопределено Тогда
						vChargingRulesFolios.Add(vCardParentDoc.ChargingFolio);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			Если vCardFolioIsInChargingRules Тогда
				vQryBalances =  New Query();
				vQryBalances.Text = 
				"SELECT
				|	ClientAccountsBalance.СчетПроживания AS СчетПроживания,
				|	ClientAccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
				|	ISNULL(ClientAccountsBalance.СчетПроживания.Гостиница.NoCreditLimit, FALSE) AS NoCreditLimit,
				|	ClientAccountsBalance.СчетПроживания.IsClosed AS IsClosed,
				|	ClientAccountsBalance.СчетПроживания.CreditLimit AS CreditLimit,
				|	ISNULL(ClientAccountsBalance.SumBalance, 0) + ISNULL(ClientAccountsBalance.LimitBalance, 0) AS ClientBalance
				|FROM
				|	AccumulationRegister.Взаиморасчеты.Balance(
				|			&qBalancesPeriod,
				|			СчетПроживания <> &qFolio
				|				AND СчетПроживания IN (&qChargingRulesFolios)
				|				AND СчетПроживания.ДокОснование = &qParentDoc
				|				AND (СчетПроживания.Контрагент = &qEmptyCustomer
				|					OR СчетПроживания.Контрагент = &qIndividualsCustomer
				|					OR СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
				|						AND СчетПроживания.Контрагент <> &qEmptyCustomer)
				|				AND (СчетПроживания.Description LIKE &qFolioDescription
				|					OR &qFolioDescriptionIsEmpty)) AS ClientAccountsBalance";
				vQryBalances.УстановитьПараметр("qBalancesPeriod", '39991231235959');
				vQryBalances.УстановитьПараметр("qFolio", vFolioRef);
				vQryBalances.УстановитьПараметр("qChargingRulesFolios", vChargingRulesFolios);
				vQryBalances.УстановитьПараметр("qParentDoc", vCardRow.ДокОснование);
				vQryBalances.УстановитьПараметр("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
				vQryBalances.УстановитьПараметр("qIndividualsCustomer", ?(ЗначениеЗаполнено(vCardRow.Гостиница), vCardRow.Гостиница.IndividualsCustomer, Справочники.Контрагенты.EmptyRef()));
				vQryBalances.УстановитьПараметр("qIndividualsCustomerFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
				vQryBalances.УстановитьПараметр("qFolioDescription", "%" + ?(ЗначениеЗаполнено(vCardRow.Гостиница), СокрЛП(vCardRow.Гостиница.AdditionalServicesFolioCondition), "") + "%");
				vQryBalances.УстановитьПараметр("qFolioDescriptionIsEmpty", ?(ЗначениеЗаполнено(vCardRow.Гостиница), IsBlankString(vCardRow.Гостиница.AdditionalServicesFolioCondition), True));
				vFolios = vQryBalances.Execute().Unload();
				For Each vFoliosRow In vFolios Do
					Если vFoliosRow.FolioCurrency = vFolioRef.ВалютаЛицСчета Тогда
						vBalance = vBalance + vFoliosRow.ClientBalance;
						Если НЕ vFoliosRow.IsClosed Тогда
							Если vFoliosRow.NoCreditLimit Тогда
								vCreditLimit = 999999999;
							Иначе
								vCreditLimit = Max(vCreditLimit, vFoliosRow.CreditLimit);
							КонецЕсли;
						КонецЕсли;
					Иначе
						vBalance = vBalance + cmConvertCurrencies(vFoliosRow.ClientBalance, vFoliosRow.FolioCurrency, , vFolioRef.ВалютаЛицСчета, , CurrentDate(), ?(ЗначениеЗаполнено(vCardRow.Гостиница), vCardRow.Гостиница, vFolioRef.Гостиница));
						Если НЕ vFoliosRow.IsClosed Тогда
							Если vFoliosRow.NoCreditLimit Тогда
								vCreditLimit = 999999999;
							Иначе
								vCreditLimit = Max(vCreditLimit, cmConvertCurrencies(vFoliosRow.CreditLimit, vFoliosRow.FolioCurrency, , vFolioRef.ВалютаЛицСчета, , CurrentDate(), ?(ЗначениеЗаполнено(vCardRow.Гостиница), vCardRow.Гостиница, vFolioRef.Гостиница)));
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
				EndDo;
			КонецЕсли;
		КонецЕсли;
		
		// Add client bonuses
		vDocDiscountCard = Неопределено;
		Если ЗначениеЗаполнено(vCardRow.ДокОснование) And TypeOf(vCardRow.ДокОснование) <> Type("DocumentRef.СоставКвоты") Тогда
			Если ЗначениеЗаполнено(vCardRow.ДокОснование.ДисконтКарт) Тогда
				vDocDiscountCard = vCardRow.ДокОснование.ДисконтКарт;
			КонецЕсли;
		КонецЕсли;
		Если ЗначениеЗаполнено(vCardRow.Клиент) And ЗначениеЗаполнено(vFolioRef) Тогда
			vClientObj = vCardRow.Клиент.GetObject();
			vBonus = 0;
			vBonusAmount = vClientObj.pmGetBonusesAmount(vFolioRef.Гостиница, vFolioRef.ВалютаЛицСчета, vDocDiscountCard, vBonus);
			Если vCreditLimit < 999999999 Тогда
				vCreditLimit = vCreditLimit + vBonusAmount;
			КонецЕсли;
		КонецЕсли;
	Иначе
		vIsBlocked = True;
		vBlockReason = NStr("en='Unknown card!';ru='Неизвестная карта!';de='Unbekannte Karte!'");
	КонецЕсли;
	
	// Build return string in CSV format
	vRetStr = Format(vBalance, "ND=17; NFD=2; NDS=.; NZ=; NG=") + "," + 
	          """" + cmRemoveComma(vClientFullName) + """" + "," + 
	          """" + cmRemoveComma(vHotelName) + """" + "," + 
	          """" + vRoomCode + """" + "," + 
	          """" + Format(vCheckInDate, "DF='dd.MM.yyyy HH:mm'") + """" + "," + 
	          """" + Format(vCheckOutDate, "DF='dd.MM.yyyy HH:mm'") + """" + "," + 
	          ?(vIsCheckedOut, 1, 0) + "," + 
	          ?(vIsBlocked, 1, 0) + "," + 
	          """" + cmRemoveComma(vBlockReason) + """" + "," + 
	          Format(vCreditLimit, "ND=17; NFD=2; NDS=.; NZ=; NG=") + "," + 
	          Format(vGuestGroupCode, "ND=12; NFD=0; NZ=; NG=") + "," + 
	          """" + cmRemoveComma(vCustomerName) + """" + "," + 
	          """" + cmRemoveComma(vPaymentMethodName) + """" + "," + 
			  """" + vFolioCurrencyCode + """" + "," + 
			  """" + vRoomRateCode + """" + "," + 
			  ?(vDiscount <> 0, Format(vDiscount, "ND=6; NFD=2; NDS=.; NZ=; NG="), "0") + "," +
			  """" + ?(ЗначениеЗаполнено(vDiscountType), cmRemoveComma(vDiscountType.Description), "") + """" + "," + 
			  """" + ?(ЗначениеЗаполнено(vDiscountCard), cmRemoveComma(vDiscountCard.Identifier), "") + """" + "," + 
			  """" + vClientCode + """";
	WriteLogEvent(NStr("en='Get client identification card balance';ru='Получение баланса по карте идентификации клиента';de='Erhalten der Bilanz nach der Kundenidentifikationskarte'"), EventLogLevel.Information, , , NStr("en='Возврат string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	
	// Возврат based on output type
	Если pOutputType = "CSV" Тогда
		Возврат vRetStr;
	Иначе
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/restaurant/", "ClientIdentificationCardBalance"));
		vRetXDTO.Balance = vBalance;
		vRetXDTO.Клиент = vClientFullName;
		vRetXDTO.Гостиница = vHotelName;
		vRetXDTO.НомерРазмещения = vRoomCode;
		vRetXDTO.CheckInDate = vCheckInDate;
		vRetXDTO.ДатаВыезда = vCheckOutDate;
		vRetXDTO.IsCheckedOut = vIsCheckedOut;
		vRetXDTO.IsBlocked = vIsBlocked;
		vRetXDTO.BlockReason = Left(vBlockReason, 100);
		vRetXDTO.CreditLimit = vCreditLimit;
		vRetXDTO.ГруппаГостей = vGuestGroupCode;
		vRetXDTO.Контрагент = vCustomerName;
		vRetXDTO.СпособОплаты = vPaymentMethodName;
		vRetXDTO.ВалютаЛицСчета = vFolioCurrencyCode;
		vRetXDTO.Тариф = vRoomRateCode;
		vRetXDTO.Скидка = vDiscount;
		vRetXDTO.ТипСкидки = ?(ЗначениеЗаполнено(vDiscountType), СокрЛП(vDiscountType.Description), "");
		vRetXDTO.ДисконтКарт = ?(ЗначениеЗаполнено(vDiscountCard), СокрЛП(vDiscountCard.Identifier), "");
		vRetXDTO.ClientCode = vClientCode;
		Возврат vRetXDTO;
	КонецЕсли;
КонецФункции //cmGetClientIdentificationCardBalance

//-----------------------------------------------------------------------------
// Description: Функция returns client photo by code
// Parameters: Client code as string
// Возврат value: Picture object or Неопределено
//-----------------------------------------------------------------------------
Функция cmGetClientPhoto(pCode) Экспорт
	vCode = СокрЛП(pCode);
	Если НЕ IsBlankString(vCode) Тогда
		vClt = Справочники.Clients.FindByCode(vCode);
		Если vClt.Photo <> Неопределено Тогда
			Возврат vClt.Photo.Get();
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции //cmGetClientPhoto

//-----------------------------------------------------------------------------
// Description: Функция returns client details by code
// Parameters: Client code as string
// Возврат value: XDTO
//-----------------------------------------------------------------------------
Функция cmGetGuestDetails(pCode, pOutputType = "CSV") Экспорт
	// Log input parameters
	WriteLogEvent(NStr("en='Get guest details';ru='Получить данные гостя';de='Daten des Gastes erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='Guest code: ';ru='Код гостя: ';de='Code des Gastes: '") + pCode);
	
	// Initialize return parameters				  
	vRetStr = "";
	vRetXDTO = Неопределено;
	Если pOutputType <> "CSV" Тогда
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/restaurant/", "GuestDetails"));
	КонецЕсли;
	
	vGuest = Справочники.Clients.FindByCode(СокрЛП(pCode));
	Если vGuest = Неопределено Тогда
		WriteLogEvent(NStr("en='Guest not be found';ru='Гость не найден';de='Gast nicht gefunden'"), EventLogLevel.Information, , , 
	              NStr("en='Guest code: ';ru='Код гостя: ';de='Code des Gastes: '") + pCode);
		Возврат Неопределено;
	КонецЕсли;
	vGuestPhoto = cmGetClientPhoto(pCode);
	Если НЕ vGuestPhoto = Неопределено Тогда 
		vFileName = TempFilesDir()+"clientphoto";
		vGuestPhoto.Write(vFileName);
		vBinData = New BinaryData(vFileName);
	КонецЕсли;
	vRetStr = cmRemoveComma(СокрЛП(vGuest.Фамилия)) + "," + 
	          """" + cmRemoveComma(СокрЛП(vGuest.Имя)) + """" + "," + 
			  """" + cmRemoveComma(СокрЛП(vGuest.Отчество)) + """" + "," + 
			  """" + Format(vGuest.ДатаРождения, "DF='dd.MM.yyyy HH:mm'") + """" + "," + 
			  """" + ?(ЗначениеЗаполнено(vBinData), Base64String(vBinData), "") + """"; 
	// Возврат based on output type
	Если pOutputType = "CSV" Тогда
		Возврат vRetStr;
	Иначе
		vRetXDTO.GuestLastName = СокрЛП(vGuest.Фамилия);
		vRetXDTO.GuestFirstName = СокрЛП(vGuest.Имя);
		vRetXDTO.GuestSecondName = СокрЛП(vGuest.Отчество);
		vRetXDTO.GuestDateOfBirth = vGuest.ДатаРождения;
		vRetXDTO.GuestPhoto = ?(ЗначениеЗаполнено(vBinData), Base64String(vBinData), "");
		Возврат vRetXDTO;
	КонецЕсли;
КонецФункции //cmGetGuestDetails

//-----------------------------------------------------------------------------
// Description: Функция returns in-house accommodation for the given discount card
// Parameters: Discount card item ref
// Возврат value: Accommodation document ref
//-----------------------------------------------------------------------------
Функция cmGetDiscountCardAccommodation(pDiscountCard) Экспорт
	Если НЕ ЗначениеЗаполнено(pDiscountCard) Тогда
		Возврат Documents.Размещение.EmptyRef();
	КонецЕсли;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Posted
	|	AND Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.СтатусРазмещения.ЭтоГости
	|	AND Размещение.ДисконтКарт = &qDiscountCard
	|TOTALS BY
	|	Размещение.ДатаДок,
	|	Размещение.PointInTime,
	|	Размещение.НомерРазмещения.ПорядокСортировки,
	|	Размещение.ВидРазмещения.ПорядокСортировки";
	vQry.УстановитьПараметр("qDiscountCard", pDiscountCard);
	vAccommodations = vQry.Execute().Unload();
	Если vAccommodations.Count() > 0 Тогда
		Возврат vAccommodations.Get(0).Ref;
	Иначе
		Возврат Documents.Размещение.EmptyRef();
	КонецЕсли;
КонецФункции //cmGetDiscountCardAccommodation

//-----------------------------------------------------------------------------
// Description: Функция returns in-house accommodation for the given client
// Parameters: Client item ref
// Возврат value: Accommodation document ref
//-----------------------------------------------------------------------------
Функция cmGetClientAccommodation(pClient) Экспорт
	Если НЕ ЗначениеЗаполнено(pClient) Тогда
		Возврат Documents.Размещение.EmptyRef();
	КонецЕсли;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Posted
	|	AND Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.СтатусРазмещения.ЭтоГости
	|	AND Размещение.Клиент = &qGuest
	|TOTALS BY
	|	Размещение.ДатаДок,
	|	Размещение.PointInTime,
	|	Размещение.НомерРазмещения.ПорядокСортировки,
	|	Размещение.ВидРазмещения.ПорядокСортировки";
	vQry.УстановитьПараметр("qGuest", pClient);
	vAccommodations = vQry.Execute().Unload();
	Если vAccommodations.Count() > 0 Тогда
		Возврат vAccommodations.Get(0).Ref;
	Иначе
		Возврат Documents.Размещение.EmptyRef();
	КонецЕсли;
КонецФункции //cmGetClientAccommodation

//-----------------------------------------------------------------------------
// Description: Charges service by client identification card code.
//              Функция could be called as web-service or thru COM connection
// Parameters: Card identifier, Service code to be charged, Amount , Quantity, Charge remarks, Charge details, Currency code, External system code
// Возврат value: Empty string if charge was done successfully or error description
//-----------------------------------------------------------------------------
Функция cmChargeExternalService(pIdentifier, pServiceCode = "", pSum, pQuantity = 1, pRemarks = "", pChargeDetails = "", pCurrencyCode = "", pExternalSystemCode = "", pVATRate = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Card identifier: ';ru='Идентификатор карты: ';de='Kartenidentifikator: '") + pIdentifier + Chars.LF + 
	              NStr("en='Service code: ';ru='Код услуги: ';de='Dienstleistungscode: '") + pServiceCode + Chars.LF + 
	              NStr("en='Sum: ';ru='Сумма: ';de='Summe: '") + pSum + Chars.LF + 
	              NStr("en='Quantity: ';ru='Количество: ';de='Anzahl: '") + pQuantity + Chars.LF + 
	              NStr("en='Currency: ';ru='Валюта: ';de='Währung: '") + pCurrencyCode + Chars.LF + 
	              NStr("en='Remarks: ';ru='Описание: ';de='Beschreibung: '") + pRemarks + Chars.LF + 
	              NStr("en='Details: ';ru='Детали: ';de='Details: '") + pChargeDetails);
	Try
		// Get card reference by card identifier
		vCard = cmGetClientIdentificationCardById(pIdentifier);
		Если НЕ ЗначениеЗаполнено(vCard) Тогда
			// Try to find discount card
			vDiscountCard = cmGetDiscountCardById(pIdentifier);
			Если НЕ ЗначениеЗаполнено(vDiscountCard) Тогда
				WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
				              NStr("en='Client identification card was not found!';ru='Не найдена карта клиента!';de='Kundenkarte nicht gefunden!'"));
				Возврат NStr("en='Client identification card was not found!';ru='Не найдена карта клиента!';de='Kundenkarte nicht gefunden!'");
			КонецЕсли;
			vAccommodation = cmGetDiscountCardAccommodation(vDiscountCard);
			Если НЕ ЗначениеЗаполнено(vAccommodation) Тогда
				Если НЕ ЗначениеЗаполнено(vDiscountCard.Клиент) Тогда
					WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
					              NStr("en='Client identification card was not found!';ru='Не найдена карта клиента!';de='Kundenkarte nicht gefunden!'"));
					Возврат NStr("en='Client identification card was not found!';ru='Не найдена карта клиента!';de='Kundenkarte nicht gefunden!'");
				КонецЕсли;
				vAccommodation = cmGetClientAccommodation(vDiscountCard.Клиент);
			КонецЕсли;
			Если НЕ ЗначениеЗаполнено(vAccommodation) Тогда
				WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
				              NStr("en='Client identification card was not found!';ru='Не найдена карта клиента!';de='Kundenkarte nicht gefunden!'"));
				Возврат NStr("en='Client identification card was not found!';ru='Не найдена карта клиента!';de='Kundenkarte nicht gefunden!'");
			КонецЕсли;
			vCard = New Structure("Гостиница, ДокОснование, СчетПроживания", vAccommodation.Гостиница, vAccommodation, Documents.СчетПроживания.EmptyRef());
		Иначе
			Если ЗначениеЗаполнено(vCard.IdentificationCardType) And НЕ IsBlankString(vCard.IdentificationCardType.ExternalSystemsAllowed) And НЕ IsBlankString(pExternalSystemCode) Тогда
				Если Find(СокрЛП(vCard.IdentificationCardType.ExternalSystemsAllowed), СокрЛП(pExternalSystemCode)) = 0 Тогда
					Возврат NStr("en='It is forbidden to use this card in ';ru='Использовать эту карту в ';de='Benutzen Sie diese Karte im '") + СокрЛП(pExternalSystemCode) + NStr("en=' system!';ru=' запрещено!';de=' ist verboten!'");
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		// Get hotel
		vHotel = Неопределено;
		Если ЗначениеЗаполнено(vCard.Гостиница) Тогда
			vHotel = vCard.Гостиница;
		ИначеЕсли ЗначениеЗаполнено(vCard.ParentDoc) Тогда
			vHotel = vCard.ParentDoc.Гостиница;
		ИначеЕсли ValueisFilled(vCard.ЛицевойСчет) Тогда
			vHotel = vCard.ЛицевойСчет.Гостиница;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vHotel) Тогда
			WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
			              NStr("en='Гостиница is not set!';ru='Не удалось определить гостиницу!';de='Das Гостиница konnte nicht bestimmt werden!'"));
			Возврат NStr("en='Гостиница is not set!';ru='Не удалось определить гостиницу!';de='Das Гостиница konnte nicht bestimmt werden!'");
		КонецЕсли;
		vRemarks = СокрЛП(pRemarks);
		// Get service to be charged by service code or hotel
		vService = Справочники.Услуги.EmptyRef();
		Если Upper(СокрЛП(pExternalSystemCode)) = "RKEEPER" OR Upper(СокрЛП(pExternalSystemCode)) = "R-KEEPER" Тогда
			Если НЕ IsBlankString(vRemarks) Тогда
				vRestoranCode = "";
				vRestoranStartPos = Find(Lower(vRemarks), "ресторан:");
				vRestoranEndPos = 0;
				Если vRestoranStartPos > 0 Тогда
					vRestoranEndPos = Find(Mid(vRemarks, vRestoranStartPos + 9), ";");
					Если vRestoranEndPos > 0 Тогда
						vRestoranCode = СокрЛП(Mid(vRemarks, vRestoranStartPos + 9, vRestoranEndPos - 1));
					КонецЕсли;
				КонецЕсли;
				vKassaCode = "";
				vKassaStartPos = Find(Lower(vRemarks), "НомерРазмещения кассы:");
				vKassaEndPos = 0;
				Если vKassaStartPos > 0 Тогда
					vKassaEndPos = Find(Mid(vRemarks, vKassaStartPos + 12), ";");
					Если vKassaEndPos > 0 Тогда
						vKassaCode = СокрЛП(Mid(vRemarks, vKassaStartPos + 12, vKassaEndPos - 1));
						vKassaEndPos = vKassaStartPos + 12 + vKassaEndPos;
					КонецЕсли;
				КонецЕсли;
				Если НЕ IsBlankString(vRestoranCode) Or НЕ IsBlankString(vKassaCode) Тогда
					Если НЕ IsBlankString(vRestoranCode) And IsBlankString(vKassaCode) Тогда
						vService = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Услуги", vRestoranCode);
					ИначеЕсли IsBlankString(vRestoranCode) And НЕ IsBlankString(vKassaCode) Тогда
						vService = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Услуги", vKassaCode);
					ИначеЕсли НЕ IsBlankString(vRestoranCode) And НЕ IsBlankString(vKassaCode) Тогда
						vService = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Услуги", vRestoranCode + "/" + vKassaCode);
					КонецЕсли;
				КонецЕсли;
				Если vKassaEndPos > 0 Тогда
					vRemarks = Mid(vRemarks, vKassaEndPos + 1);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vService) Тогда
			Если IsBlankString(pServiceCode) Тогда
				vService = vHotel.CateringService;
			Иначе
				vService = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Услуги", СокрЛП(pServiceCode));
				Если НЕ ЗначениеЗаполнено(vService) Тогда
					vService = cmGetServiceByCode(СокрЛП(pServiceCode));
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vService) Тогда
			vService = vHotel.CateringService;
		КонецЕсли;		
		Если НЕ ЗначениеЗаполнено(vService) Тогда
			WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
			              NStr("en='Service is not set!';ru='Не удалось определить услугу!';de='Die Dienstleistung konnte nicht bestimmt werden!'"));
			Возврат NStr("en='Service is not set!';ru='Не удалось определить услугу!';de='Die Dienstleistung konnte nicht bestimmt werden!'");
		КонецЕсли;
		// Get folio by card
		vFolio = Documents.СчетПроживания.EmptyRef();
		Если ЗначениеЗаполнено(vCard.IdentificationCardType) And vCard.IdentificationCardType.DoNotUseChargingRules Тогда
			vFolio = vCard.ЛицевойСчет;
		Иначе
			Если ЗначениеЗаполнено(vCard.ParentDoc) Тогда
				vCardParentDoc = vCard.ParentDoc;
				vCardFolioIsInChargingRules = False;
				Если TypeOf(vCardParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(vCardParentDoc) = Type("DocumentRef.Бронирование") Тогда
					vChargingRules = vCardParentDoc.ChargingRules;
					Если vChargingRules.Find(vCard.ЛицевойСчет, "ChargingFolio") <> Неопределено Тогда
						vCardFolioIsInChargingRules = True;
					Иначе
						vCardParentDocGuestGroup = vCardParentDoc.ГруппаГостей;
						Если ЗначениеЗаполнено(vCardParentDocGuestGroup) And vCardParentDocGuestGroup.ChargingRules.Count() > 0 Тогда
							vCardParentDocGuestGroupChargingRules = vCardParentDocGuestGroup.ChargingRules;
							Если vCardParentDocGuestGroupChargingRules.Find(vCard.ЛицевойСчет, "ChargingFolio") <> Неопределено Тогда
								vCardFolioIsInChargingRules = True;
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
				ИначеЕсли TypeOf(vCardParentDoc) = Type("DocumentRef.БроньУслуг") Or TypeOf(vCardParentDoc) = Type("DocumentRef.СоставКвоты") Тогда
					Если vCard.ЛицевойСчет = vCardParentDoc.ChargingFolio Тогда
						vCardFolioIsInChargingRules = True;
					КонецЕсли;
				КонецЕсли;
				Если vCardFolioIsInChargingRules Тогда
					vFolio = cmGetDocumentChargingFolioForService(vCardParentDoc, vService, CurrentDate());
				Иначе
					vFolio = vCard.ЛицевойСчет;
				КонецЕсли;
			Иначе
				vFolio = vCard.ЛицевойСчет;
			КонецЕсли;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vFolio) Тогда
			WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
			              NStr("en='ЛицевойСчет is not set for the client identification card!';ru='У карты клиента не указано фолио!';de='Bei der Kundenkarte ist kein ЛицевойСчет angegeben!'"));
			Возврат NStr("en='ЛицевойСчет is not set for the client identification card!';ru='У карты клиента не указано фолио!';de='Bei der Kundenkarte ist kein ЛицевойСчет angegeben!'");
		КонецЕсли;
		Если vFolio.DeletionMark Тогда
			WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
			              NStr("en='Attempt to charge to the marked for deletion folio! Operation is canceled.';ru='Попытка выполнить начисление на помеченный на удаление счет! Операция прервана.';de='Versuch, eine Einzahlung auf ein zum Löschen markiertes Konto zu tätigen! Die Operation ist abgebrochen.'"));
			Возврат NStr("en='Attempt to charge to the marked for deletion folio! Operation is canceled.';ru='Попытка выполнить начисление на помеченный на удаление счет! Операция прервана.';de='Versuch, eine Einzahlung auf ein zum Löschen markiertes Konto zu tätigen! Die Operation ist abgebrochen.'");
		КонецЕсли;
		Если vFolio.IsClosed Тогда
			WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
			              NStr("en='Attempt to charge to the closed folio! Operation is canceled.';ru='Попытка выполнить начисление на закрытый счет! Операция прервана.';de='Versuch, eine Einzahlung auf ein geschlossenes Konto zu tätigen! Die Operation ist abgebrochen.'")+"N "+String(vFolio.НомерДока));
			Возврат NStr("en='Attempt to charge to the closed folio! Operation is canceled.';ru='Попытка выполнить начисление на закрытый счет! Операция прервана.';de='Versuch, eine Einzahlung auf ein geschlossenes Konto zu tätigen! Die Operation ist abgebrochen.'")+"N "+String(vFolio.НомерДока);
		КонецЕсли;
		// Check folio balance
		vLimit = 0;
		vFolioObj = vFolio.GetObject();
		vBalance = vFolioObj.pmGetBalance('39991231235959', , Неопределено, vLimit);
		Если (vBalance + pSum) > vFolio.CreditLimit And НЕ vHotel.NoCreditLimit Тогда
			vText = NStr("en='Sum of charge amount with folio debt is greater then folio credit limit! Operation is canceled.'; 
			             |de='Sum of charge amount with folio debt is greater then folio credit limit! Operation is canceled.'; 
			             |ru='После начисления услуги долг на лицевом счете " + cmFormatSum((vBalance + pSum), vFolio.ВалютаЛицСчета) + " превысит установленную глубину кредита " + cmFormatSum(vFolio.CreditLimit, vFolio.ВалютаЛицСчета) + "! Операция прервана.'");
			WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
			              vText);
			Возврат vText;
		КонецЕсли;		
		// Create charge document
		vChargeObj = Documents.Начисление.CreateDocument();
		//vChargeObj.pmFillAttributesWithDefaultValues();
		Если ЗначениеЗаполнено(vFolio.Гостиница) Тогда
			Если vChargeObj.Гостиница <> vFolio.Гостиница Тогда
				vChargeObj.Гостиница = vFolio.Гостиница;
				vChargeObj.SetNewNumber(СокрЛП(vChargeObj.Гостиница.GetObject().pmGetPrefix()));
			КонецЕсли;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vChargeObj.Гостиница) Тогда
			WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Warning, , , 
			              NStr("en='Гостиница is not set!';ru='Не удалось установить гостиницу!';de='Das Гостиница konnte nicht festgelegt werden!'"));
			Возврат NStr("en='Гостиница is not set!';ru='Не удалось установить гостиницу!';de='Das Гостиница konnte nicht festgelegt werden!'");
		КонецЕсли;
		// Get currency by code
		vCurrency = Справочники.Валюты.EmptyRef();
		Если НЕ IsBlankString(pCurrencyCode) Тогда
			vCurrency = cmGetObjectRefByExternalSystemCode(vChargeObj.Гостиница, pExternalSystemCode, "Валюты", pCurrencyCode);
		КонецЕсли;
		// VAT rate may come from interface
		vVATRate = Справочники.СтавкаНДС.EmptyRef();
		Если pVATRate <> Неопределено Тогда
			vQ = New Query("SELECT
			|	СтавкаНДС.Ref
			|FROM
			|	Catalog.СтавкаНДС AS СтавкаНДС
			|WHERE
			|	СтавкаНДС.Ставка = &qTaxRate
			|	AND NOT СтавкаНДС.DeletionMark");
			vQ.УстановитьПараметр("qTaxRate", pVATrate);
			vQRes = vQ.Execute().Choose();
			Если vQRes.Next() Тогда
				vVATRate = vQRes.Ref;
			КонецЕсли;			
		КонецЕсли;
		Если vVATRate = Справочники.СтавкаНДС.EmptyRef() Тогда
			Если ЗначениеЗаполнено(vFolio.Гостиница.Фирма) Тогда
				vVATRate = vFolio.Гостиница.Фирма.СтавкаНДС;
			КонецЕсли;
			vServicePrices = vService.GetObject().pmGetServicePrices(vFolio.Гостиница, CurrentDate());
			Если vServicePrices.Count() > 0 Тогда
				vVATRate = vServicePrices.Get(0).СтавкаНДС;
			КонецЕсли;
		КонецЕсли;		
		// Post this document
		vChargeObj.ДокОснование = vFolio.ДокОснование;
		vChargeObj.IsFixedCharge = False;
		vChargeObj.Гостиница = vFolio.Гостиница;
		Если ЗначениеЗаполнено(vFolio.ДокОснование) And TypeOf(vFolio.ДокОснование) = Type("DocumentRef.БроньУслуг") And
		   ЗначениеЗаполнено(vFolio.ДокОснование.ExchangeRateDate) And 
		   ЗначениеЗаполнено(vChargeObj.Услуга) And ЗначениеЗаполнено(vChargeObj.Услуга.ServiceType) And 
		   vChargeObj.Услуга.ServiceType.ActualAmountIsChargedExternally Тогда
			vChargeObj.ExchangeRateDate = vFolio.ДокОснование.ExchangeRateDate;
		КонецЕсли;
		vChargeObj.ВалютаЛицСчета = vFolio.ВалютаЛицСчета;
		vChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.ВалютаЛицСчета, vChargeObj.ExchangeRateDate);
		vChargeObj.Валюта = vFolio.Гостиница.Валюта;
		vChargeObj.ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.Валюта, vChargeObj.ExchangeRateDate);
		vChargeObj.СчетПроживания = vFolio;
		vChargeObj.Услуга = vService;
		vChargeObj.PaymentSection = vChargeObj.Услуга.PaymentSection;
		vSum = pSum;
		vQuantity = pQuantity;
		Если vSum < 0 And vQuantity > 0 Тогда
			vQuantity = -vQuantity;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vCurrency) Or vCurrency = vChargeObj.ВалютаЛицСчета Тогда
			vChargeObj.Цена = cmRecalculatePrice(vSum, vQuantity);
		Иначе
			vSum = cmExtConvertCurrencies(pSum, vCurrency, , vChargeObj.ВалютаЛицСчета, vChargeObj.FolioCurrencyExchangeRate, vChargeObj.ExchangeRateDate, vChargeObj.Гостиница, pExternalSystemCode);
			vChargeObj.Цена = cmRecalculatePrice(vSum, vQuantity);
		КонецЕсли;
		vChargeObj.ЕдИзмерения = vService.ЕдИзмерения;
		vChargeObj.Количество = vQuantity;
		vChargeObj.Сумма = vSum;
		vChargeObj.СтавкаНДС = vVATRate;
		vChargeObj.СуммаНДС = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.Сумма);
		vChargeObj.Примечания = vRemarks;
		vChargeObj.IsRoomRevenue = vService.IsRoomRevenue;
		vChargeObj.IsInPrice = vService.IsInPrice;
		vChargeObj.Фирма = vFolio.Фирма;
		vChargeObj.IsAdditional = True;
		vChargeObj.Details = СокрЛП(pChargeDetails);
		vChargeObj.Write(DocumentWriteMode.Posting);
		WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Information, , , 
					  NStr("en='Charge was posted - OK!';ru='Транзакция записана в БД!';de='Transaktion ist in die Datenbank eingetragen!'"));
	Except
		WriteLogEvent(NStr("en='Charge external service';ru='Начисление услуги из внешней системы';de='Anrechnung von Dienstleistungen aus dem externen System'"), EventLogLevel.Error, , , 
					  NStr("en='Error description: ';ru='Описание ошибки: ';de='Fehlerbeschreibung: '") + ErrorDescription());
		Возврат ErrorDescription();
	EndTry;
	Возврат "";
КонецФункции //cmChargeExternalService

//-----------------------------------------------------------------------------
// Searches folio by it's number
//-----------------------------------------------------------------------------
Функция cmFindFolioByNumber(pFolioNumber, pHotel) Экспорт
	Если ЗначениеЗаполнено(pHotel) And pHotel.UseFolioAccountingNumberPrefix Тогда
		vFolioNumber = cmGetFolioProformaNumberFromPresentation(pFolioNumber, pHotel);
	Иначе	
		vFolioNumber = cmGetDocumentNumberFromPresentation(pFolioNumber, pHotel);
	КонецЕсли;
	vFolio = Documents.СчетПроживания.FindByNumber(vFolioNumber);
	Возврат vFolio;
КонецФункции //cmFindFolioByNumber

//-----------------------------------------------------------------------------
// Description: Charges service by folio number.
//              Функция could be called as web-service or thru COM connection
// Parameters: ЛицевойСчет number, Service code to be charged, Amount , Quantity, Charge remarks, Charge details, Гостиница code, External system code, Currency code
// Возврат value: Empty string if charge was done successfully or error description
//-----------------------------------------------------------------------------
Функция cmChargeExternalServiceByFolio(pFolioNumber, pServiceCode = "", pSum, pQuantity = 1, pRemarks = "", pChargeDetails = "", pHotelCode = "", pExternalSystemCode = "", pCurrencyCode = "", pVATRate = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Charge external service by folio';ru='Начисление услуги из внешней системы по лицевому счету';de='Anrechnung von Dienstleistungen aus dem externen System nach dem Personenkonto'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница: ';ru='Гостиница: ';de='Гостиница: '") + pHotelCode + Chars.LF + 
	              NStr("en='ЛицевойСчет number: ';ru='Номер фолио: ';de='Folionummer: '") + pFolioNumber + Chars.LF + 
	              NStr("en='Service code: ';ru='Код услуги: ';de='Dienstleistungscode: '") + pServiceCode + Chars.LF + 
	              NStr("en='Sum: ';ru='Сумма: ';de='Summe: '") + pSum + Chars.LF + 
	              NStr("en='Quantity: ';ru='Количество: ';de='Anzahl: '") + pQuantity + Chars.LF + 
	              NStr("en='Currency: ';ru='Валюта: ';de='Währung: '") + pCurrencyCode + Chars.LF + 
	              NStr("en='Remarks: ';ru='Описание: ';de='Beschreibung: '") + pRemarks + Chars.LF + 
	              NStr("en='Details: ';ru='Детали: ';de='Details: '") + pChargeDetails);
	Try
		// Get hotel
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
		Если НЕ IsBlankString(pHotelCode) Тогда
			vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
		КонецЕсли;
		// Get currency by code
		vCurrency = Справочники.Валюты.EmptyRef();
		Если НЕ IsBlankString(pCurrencyCode) Тогда
			vCurrency = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Валюты", pCurrencyCode);
		КонецЕсли;
		// Get folio reference by folio number
		vFolio = cmFindFolioByNumber(pFolioNumber, vHotel);
		Если НЕ ЗначениеЗаполнено(vFolio) Тогда
			WriteLogEvent(NStr("en='Charge external service by folio';ru='Начисление услуги из внешней системы по лицевому счету';de='Anrechnung von Dienstleistungen aus dem externen System nach dem Personenkonto'"), EventLogLevel.Warning, , , 
			              NStr("en='ЛицевойСчет was not found!';ru='Фолио не найдено по номеру!';de='ЛицевойСчет wurde nach der Nummer nicht gefunden!'"));
			Возврат NStr("en='ЛицевойСчет was not found!';ru='Фолио не найдено по номеру!';de='Folio wurde nach der Nummer nicht gefunden!'");
		КонецЕсли;
		Если ЗначениеЗаполнено(vFolio.Гостиница) Тогда
			vHotel = vFolio.Гостиница;
		КонецЕсли;
		Если vFolio.DeletionMark Тогда
			WriteLogEvent(NStr("en='Charge external service by folio';ru='Начисление услуги из внешней системы по лицевому счету';de='Anrechnung von Dienstleistungen aus dem externen System nach dem Personenkonto'"), EventLogLevel.Warning, , , 
			              NStr("en='Attempt to charge to the marked for deletion folio! Operation is canceled.';ru='Попытка выполнить начисление на помеченный на удаление счет! Операция прервана.';de='Versuch, eine Einzahlung auf ein zum Löschen markiertes Konto zu tätigen! Die Operation ist abgebrochen.'"));
			Возврат NStr("en='Attempt to charge to the marked for deletion folio! Operation is canceled.';ru='Попытка выполнить начисление на помеченный на удаление счет! Операция прервана.';de='Versuch, eine Einzahlung auf ein zum Löschen markiertes Konto zu tätigen! Die Operation ist abgebrochen.'");
		КонецЕсли;
		// Create charge document
		vChargeObj = Documents.Начисление.CreateDocument();
		//vChargeObj.pmFillAttributesWithDefaultValues();
		Если ЗначениеЗаполнено(vFolio.Гостиница) Тогда
			Если vChargeObj.Гостиница <> vFolio.Гостиница Тогда
				vChargeObj.Гостиница = vFolio.Гостиница;
				vChargeObj.SetNewNumber(СокрЛП(vChargeObj.Гостиница.GetObject().pmGetPrefix()));
			КонецЕсли;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vChargeObj.Гостиница) Тогда
			WriteLogEvent(NStr("en='Charge external service by folio';ru='Начисление услуги из внешней системы по лицевому счету';de='Anrechnung von Dienstleistungen aus dem externen System nach dem Personenkonto'"), EventLogLevel.Warning, , , 
			              NStr("en='Гостиница is not set!';ru='Не удалось установить гостиницу!';de='Das Гостиница konnte nicht festgelegt werden!'"));
			Возврат NStr("en='Гостиница is not set!';ru='Не удалось установить гостиницу!';de='Das Гостиница konnte nicht festgelegt werden!'");
		КонецЕсли;
		// Get service to be charged by service code or hotel
		vService = Справочники.Услуги.EmptyRef();
		Если IsBlankString(pServiceCode) Тогда
			vService = vChargeObj.Гостиница.CateringService;
		Иначе
			vService = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Услуги", СокрЛП(pServiceCode));
			Если НЕ ЗначениеЗаполнено(vService) Тогда
				vService = cmGetServiceByCode(СокрЛП(pServiceCode));
			КонецЕсли;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vService) Тогда
			vService = vChargeObj.Гостиница.CateringService;
		КонецЕсли;		
		Если НЕ ЗначениеЗаполнено(vService) Тогда
			WriteLogEvent(NStr("en='Charge external service by folio';ru='Начисление услуги из внешней системы по лицевому счету';de='Anrechnung von Dienstleistungen aus dem externen System nach dem Personenkonto'"), EventLogLevel.Warning, , , 
			              NStr("en='Service is not set!';ru='Не удалось определить услугу!';de='Die Dienstleistung konnte nicht bestimmt werden!'"));
			Возврат NStr("en='Service is not set!';ru='Не удалось определить услугу!';de='Die Dienstleistung konnte nicht bestimmt werden!'");
		КонецЕсли;
		//VAT rate may come from interface
		vVATRate = Справочники.СтавкаНДС.EmptyRef();
		Если pVATRate <> Неопределено Тогда
			vQ = New Query("SELECT
			|	СтавкаНДС.Ref
			|FROM
			|	Catalog.СтавкаНДС AS СтавкаНДС
			|WHERE
			|	СтавкаНДС.Ставка = &qTaxRate
			|	AND NOT СтавкаНДС.DeletionMark");
			vQ.УстановитьПараметр("qTaxRate", pVATrate);
			vQRes = vQ.Execute().Choose();
			Если vQRes.Next() Тогда
				vVATRate = vQRes.Ref;
			КонецЕсли;			
		КонецЕсли;
		Если vVATRate = Справочники.СтавкаНДС.EmptyRef() Тогда
			vVATRate = Справочники.СтавкаНДС.EmptyRef();
			Если ЗначениеЗаполнено(vFolio.Гостиница.Фирма) Тогда
				vVATRate = vFolio.Гостиница.Фирма.СтавкаНДС;
			КонецЕсли;
			vServicePrices = vService.GetObject().pmGetServicePrices(vFolio.Гостиница, CurrentDate());
			Если vServicePrices.Count() > 0 Тогда
				vVATRate = vServicePrices.Get(0).СтавкаНДС;
			КонецЕсли;
		КонецЕсли;		
		// Post this document
		vChargeObj.ДокОснование = vFolio.ДокОснование;
		vChargeObj.IsFixedCharge = False;
		vChargeObj.Гостиница = vFolio.Гостиница;
		vChargeObj.СчетПроживания = vFolio;
		vChargeObj.Услуга = vService;
		vChargeObj.PaymentSection = vChargeObj.Услуга.PaymentSection;
		Если ЗначениеЗаполнено(vFolio.ДокОснование) And TypeOf(vFolio.ДокОснование) = Type("DocumentRef.БроньУслуг") And
		   ЗначениеЗаполнено(vFolio.ДокОснование.ExchangeRateDate) And 
		   ЗначениеЗаполнено(vChargeObj.Услуга) And ЗначениеЗаполнено(vChargeObj.Услуга.ServiceType) And 
		   vChargeObj.Услуга.ServiceType.ActualAmountIsChargedExternally Тогда
			vChargeObj.ExchangeRateDate = vFolio.ДокОснование.ExchangeRateDate;
		КонецЕсли;
		vChargeObj.ВалютаЛицСчета = vFolio.ВалютаЛицСчета;
		vChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.ВалютаЛицСчета, vChargeObj.ExchangeRateDate);
		vChargeObj.Валюта = vFolio.Гостиница.Валюта;
		vChargeObj.ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.Валюта, vChargeObj.ExchangeRateDate);
		vSum = pSum;
		Если НЕ ЗначениеЗаполнено(vCurrency) Or vCurrency = vChargeObj.ВалютаЛицСчета Тогда
			vChargeObj.Цена = cmRecalculatePrice(vSum, pQuantity);
		Иначе
			vSum = cmExtConvertCurrencies(pSum, vCurrency, , vChargeObj.ВалютаЛицСчета, vChargeObj.FolioCurrencyExchangeRate, vChargeObj.ExchangeRateDate, vHotel, pExternalSystemCode);
			vChargeObj.Цена = cmRecalculatePrice(vSum, pQuantity);
		КонецЕсли;
		vChargeObj.ЕдИзмерения = vService.ЕдИзмерения;
		vChargeObj.Количество = pQuantity;
		vChargeObj.Сумма = vSum;
		vChargeObj.СтавкаНДС = vVATRate;
		vChargeObj.СуммаНДС = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.Сумма);
		vChargeObj.Примечания = pRemarks;
		vChargeObj.IsRoomRevenue = vService.IsRoomRevenue;
		vChargeObj.IsInPrice = vService.IsInPrice;
		vChargeObj.Фирма = vFolio.Фирма;
		vChargeObj.IsAdditional = True;
		vChargeObj.Details = СокрЛП(pChargeDetails);
		vChargeObj.Write(DocumentWriteMode.Posting);
		WriteLogEvent(NStr("en='Charge external service by folio';ru='Начисление услуги из внешней системы по лицевому счету';de='Anrechnung von Dienstleistungen aus dem externen System nach dem Personenkonto'"), EventLogLevel.Information, , , 
					  NStr("en='Charge was posted - OK!';ru='Транзакция записана в БД!';de='Transaktion ist in die Datenbank eingetragen!'"));
	Except
		WriteLogEvent(NStr("en='Charge external service by folio';ru='Начисление услуги из внешней системы по лицевому счету';de='Anrechnung von Dienstleistungen aus dem externen System nach dem Personenkonto'"), EventLogLevel.Error, , , 
					  NStr("en='Error description: ';ru='Описание ошибки: ';de='Fehlerbeschreibung: '") + ErrorDescription());
		Возврат ErrorDescription();
	EndTry;
	Возврат "";
КонецФункции //cmChargeExternalServiceByFolio

//-----------------------------------------------------------------------------
// Description: Charges service by ГруппаНомеров code.
//              Функция could be called as web-service or thru COM connection
// Parameters: ГруппаНомеров code, Charge date and time, Amount, Client code, Currency code, Service code to be charged, Quantity, Charge type as string, Charge remarks, Charge details, Гостиница code, External system code
// Возврат value: Empty string if charge was done successfully or error description
//-----------------------------------------------------------------------------
Функция cmChargeRoomService(pRoomCode, pOrderTime, pSum, pClientCode="", pCurrencyCode="", pServiceCode = "", pQuantity = 1, pChargeType = "", pRemarks = "", pChargeDetails = "", pHotelName = "", pExternalSystemCode = "", pVATrate = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Charge ГруппаНомеров service';ru='Начисление услуги по номеру комнаты';de='Anrechnung der Dienstleistung nach Zimmernummer'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница name: ';ru='Гостиница: ';de='Гостиница: '") + pHotelName + Chars.LF + 
	              NStr("en='ГруппаНомеров code: ';ru='Номер комнаты: ';de='Zimmernummer: '") + pRoomCode + Chars.LF + 
	              NStr("en='Order date and time: ';ru='Дата и время заказа: ';de='Datum und Zeit der Bestellung: '") + pOrderTime + Chars.LF + 
	              NStr("en='Client code: ';ru='Код клиента: ';de='Kundencode: '") + pClientCode + Chars.LF + 
	              NStr("en='Currency code: ';ru='Код валюты: ';de='Währungscode: '") + pCurrencyCode + Chars.LF + 
	              NStr("en='Service code: ';ru='Код услуги: ';de='Dienstleistungscode: '") + pServiceCode + Chars.LF + 
	              NStr("en='Sum: ';ru='Сумма: ';de='Summe: '") + pSum + Chars.LF + 
	              NStr("en='Quantity: ';ru='Количество: ';de='Anzahl: '") + pQuantity + Chars.LF + 
	              NStr("en='Charge type: ';ru='Тип начисления: ';de='Art der Berechnung: '") + pChargeType + Chars.LF + 
	              NStr("en='Remarks: ';ru='Описание: ';de='Beschreibung: '") + pRemarks + Chars.LF + 
	              NStr("en='Details: ';ru='Детали: ';de='Details: '") + pChargeDetails);
	Try
		// Get ГруппаНомеров by ГруппаНомеров code
		vRoom = Справочники.НомернойФонд.EmptyRef();
		Если НЕ IsBlankString(pRoomCode) Тогда
			vRoom = cmGetRoomByCode(pRoomCode, pHotelName, pExternalSystemCode);
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vRoom) Тогда
			WriteLogEvent(NStr("en='Charge ГруппаНомеров service';ru='Начисление услуги по номеру комнаты';de='Anrechnung der Dienstleistung nach Zimmernummer'"), EventLogLevel.Warning, , , 
			              NStr("en='ГруппаНомеров is not set!';ru='Не удалось определить номер!';de='Die Nummer konnte nicht bestimmt werden!'"));
			Возврат NStr("en='ГруппаНомеров is not set!';ru='Не удалось определить номер!';de='Die Nummer konnte nicht bestimmt werden!'");
		КонецЕсли;
		vHotel = vRoom.Owner;
		
		// Create new interface document object
		vRoomServiceObj = Documents.УслугаВНомер.CreateDocument();
		vRoomServiceObj.Гостиница = vHotel;
		//vRoomServiceObj.pmFillAuthorAndDate();
		vRoomServiceObj.SetNewNumber();
		//vRoomServiceObj.pmFillAttributesWithDefaultValues();
		
		// Get service to be charged by service code or hotel
		vService = Справочники.Услуги.EmptyRef();
		Если IsBlankString(pServiceCode) Тогда
			vService = vRoomServiceObj.Гостиница.CateringService;
		Иначе
			vService = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Услуги", СокрЛП(pServiceCode));
			Если НЕ ЗначениеЗаполнено(vService) Тогда
				vService = cmGetServiceByCode(СокрЛП(pServiceCode));
			КонецЕсли;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vService) Тогда
			vService = vRoomServiceObj.Гостиница.CateringService;
		КонецЕсли;		
		Если НЕ ЗначениеЗаполнено(vService) Тогда
			WriteLogEvent(NStr("en='Charge ГруппаНомеров service';ru='Начисление услуги по номеру комнаты';de='Anrechnung der Dienstleistung nach Zimmernummer'"), EventLogLevel.Warning, , , 
			              NStr("en='Service is not set!';ru='Не удалось определить услугу!';de='Die Dienstleistung konnte nicht bestimmt werden!'"));
			Возврат NStr("en='Service is not set!';ru='Не удалось определить услугу!';de='Die Dienstleistung konnte nicht bestimmt werden!'");
		КонецЕсли;
		//VAT rate may come from interface
		vVATRate = Справочники.СтавкаНДС.EmptyRef();
		Если pVATRate <> Неопределено Тогда
			vQ = New Query("SELECT
			|	СтавкаНДС.Ref
			|FROM
			|	Catalog.СтавкаНДС AS СтавкаНДС
			|WHERE
			|	СтавкаНДС.Ставка = &qTaxRate
			|	AND NOT СтавкаНДС.DeletionMark");
			vQ.УстановитьПараметр("qTaxRate", pVATrate);
			vQRes = vQ.Execute().Choose();
			Если vQRes.Next() Тогда
				vVATRate = vQRes.Ref;
			КонецЕсли;			
		КонецЕсли;
		Если vVATRate = Справочники.СтавкаНДС.EmptyRef() Тогда
			vServicePrices = vService.GetObject().pmGetServicePrices(vRoomServiceObj.Гостиница, CurrentDate());
			Если vServicePrices.Count() > 0 Тогда
				vVATRate = vServicePrices.Get(0).СтавкаНДС;
			КонецЕсли;
		КонецЕсли;		
		// Get client by client code
		vClient = Справочники.Clients.EmptyRef();
		Если НЕ IsBlankString(pClientCode) Тогда
			vClient = Справочники.Clients.FindByCode(pClientCode);
		КонецЕсли;
		
		// Get currency by currency code
		vCurrency = Справочники.Валюты.EmptyRef();
		Если НЕ IsBlankString(pCurrencyCode) Тогда
			vCurrency = cmGetObjectRefByExternalSystemCode(vRoomServiceObj.Гостиница, pExternalSystemCode, "Валюты", pCurrencyCode);
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vCurrency) And ЗначениеЗаполнено(vRoomServiceObj.Гостиница) Тогда
			vCurrency = vRoomServiceObj.Гостиница.ВалютаЛицСчета;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(vCurrency) Тогда
			WriteLogEvent(NStr("en='Charge ГруппаНомеров service';ru='Начисление услуги по номеру комнаты';de='Anrechnung der Dienstleistung nach Zimmernummer'"), EventLogLevel.Warning, , , 
			              NStr("en='Currency is not set!';ru='Не удалось определить валюту начисления!';de='Die Währung der Anrechnung konnte nicht bestimmt werden!'"));
			Возврат NStr("en='Currency is not set!';ru='Не удалось определить валюту начисления!';de='Die Währung der Anrechnung konnte nicht bestimmt werden!'");
		КонецЕсли;
		
		// Fill order sum
		vRoomServiceObj.УслугиНомер = vService;
		vRoomServiceObj.ЕдИзмерения = vService.ЕдИзмерения;
		vRoomServiceObj.RoomServiceChargeType = ?(IsBlankString(pChargeType), NStr("en='Restaurant';ru='Ресторан';de='Restaurant'"), pChargeType);
		vRoomServiceObj.Количество = ?(pQuantity = 0, 1, pQuantity);
		vRoomServiceObj.Сумма = pSum;
		vRoomServiceObj.Цена = Round(vRoomServiceObj.Сумма/vRoomServiceObj.Количество, 2);
		
		// Fill currency attributes
		vRoomServiceObj.Валюта = vCurrency;
		vRoomServiceObj.CurrencyExchangeRate = cmGetCurrencyExchangeRate(vRoomServiceObj.Гостиница, vRoomServiceObj.Валюта, vRoomServiceObj.ExchangeRateDate);
		
		// Fill call attributes
		vRoomServiceObj.ServiceDate = Дата(pOrderTime);
		
		// Try to find folio to charge to
		vRoomServiceObj.НомерРазмещения = vRoom;
		Если ЗначениеЗаполнено(vRoomServiceObj.НомерРазмещения) Тогда
			Если ЗначениеЗаполнено(vRoomServiceObj.НомерРазмещения.Фирма) Тогда
				vRoomServiceObj.Фирма = vRoomServiceObj.НомерРазмещения.Фирма;
				Если НЕ ЗначениеЗаполнено(vRoomServiceObj.УслугиНомер) Тогда
					vRoomServiceObj.СтавкаНДС = vRoomServiceObj.Фирма.СтавкаНДС;
				КонецЕсли;
				Если НЕ ЗначениеЗаполнено(vRoomServiceObj.FixedService) Тогда
					vRoomServiceObj.FixedServiceVATRate = vRoomServiceObj.Фирма.СтавкаНДС;
				КонецЕсли;
			КонецЕсли;
			vRoomServiceObj.Клиент = vClient; 
			//vRoomServiceObj.СчетПроживания = vRoomServiceObj.pmGetFolioToChargeTo();
		КонецЕсли;
		
		// Try to find active ГруппаНомеров folio
		Если НЕ ЗначениеЗаполнено(vRoomServiceObj.СчетПроживания) Тогда
			vFolios = cmGetActiveRoomFolios(vRoomServiceObj.Гостиница, vRoomServiceObj.НомерРазмещения, vRoomServiceObj.Валюта);
			Если vFolios.Count() > 0 Тогда
				vRow = vFolios.Get(0);
				vRoomServiceObj.СчетПроживания = vRow.СчетПроживания;
			КонецЕсли;
		КонецЕсли;
		
		// Create new empty one
		Если НЕ ЗначениеЗаполнено(vRoomServiceObj.СчетПроживания) Тогда
			ВызватьИсключение NStr("en='There are no suitable open folios for the guest!';ru='У гостя нет подходящих открытых лицевых счетов!';de='Der Gast hat keine passenden offenen Personenkonten!'");
			
			//@skip-warning
			vFolioObj = Документы.СчетПроживания.СоздатьДокумент();
			vFolioObj.Гостиница = vRoomServiceObj.Гостиница;
			//vFolioObj.pmFillAttributesWithDefaultValues();
			vFolioObj.НомерРазмещения = vRoomServiceObj.НомерРазмещения;
			vFolioObj.Description = NStr("en='Restaurant orders on vacant rooms';ru='Заказы ресторана на свободные номера';de='Restaurantbestellungen auf freie Plätze'");
			vFolioObj.Write(DocumentWriteMode.Write);
			
			vRoomServiceObj.СчетПроживания = vFolioObj.Ref;
			
			vMessage = NStr("ru='Создано фолио: " + String(vRoomServiceObj.СчетПроживания) + "'; 
			                |de='ЛицевойСчет " + String(vRoomServiceObj.СчетПроживания) + " was created';
			                |en='ЛицевойСчет " + String(vRoomServiceObj.СчетПроживания) + " was created'");
			WriteLogEvent(NStr("en='Charge ГруппаНомеров service';ru='Начисление услуги по номеру комнаты';de='Anrechnung der Dienstleistung nach Zimmernummer'"), EventLogLevel.Note, vRoomServiceObj.СчетПроживания.Metadata(), vRoomServiceObj.СчетПроживания, vMessage);
		КонецЕсли;
		
		// Process folio
		//vRoomServiceObj.pmFillByFolio();
		//vRoomServiceObj.pmRecalculateSums();
		
		// Fill remarks & details
		vRoomServiceObj.Примечания = СокрЛП(pRemarks);
		vRoomServiceObj.Details = СокрЛП(pChargeDetails);
		
		// Post current document
		vRoomServiceObj.Write(DocumentWriteMode.Posting);
		
		WriteLogEvent(NStr("en='Charge ГруппаНомеров service';ru='Начисление услуги по номеру комнаты';de='Anrechnung der Dienstleistung nach Zimmernummer'"), EventLogLevel.Information, , , 
					  NStr("en='Charge was posted - OK!';ru='Транзакция записана в БД!';de='Transaktion ist in die Datenbank eingetragen!'"));
	Except
		WriteLogEvent(NStr("en='Charge ГруппаНомеров service';ru='Начисление услуги по номеру комнаты';de='Anrechnung der Dienstleistung nach Zimmernummer'"), EventLogLevel.Error, , , 
					  NStr("en='Error description: ';ru='Описание ошибки: ';de='Fehlerbeschreibung: '") + ErrorDescription());
		Возврат ErrorDescription();
	EndTry;
	Возврат "";
КонецФункции //cmChargeRoomService

//-----------------------------------------------------------------------------
// Description: Returns list of guests by name and ГруппаНомеров.
//              Функция could be called as web-service or thru COM connection
// Parameters: Guest name or part of guest name, ГруппаНомеров code, Гостиница code, Output type (XDTO or CSV)
// Возврат value: XDTO object or CSV strings separated by line feed character
//-----------------------------------------------------------------------------
Функция cmGetHotelGuestsList(pGuestName = "", pRoomCode = "", pHotelName = "", pOutputType = "CSV", pExtSystemCode = "") Экспорт
	// Initialize return parameters				  
	vRetStr = "";
	vRetXDTO = Неопределено;
	vGuestItemType = Неопределено;
	Если pOutputType <> "CSV" Тогда
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/restaurant/", "GuestsList"));
		vGuestItemType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/restaurant/", "GuestItem");
		vGuestItemsType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/restaurant/", "GuestItems");
		vRetXDTO.GuestItems = XDTOFactory.Create(vGuestItemsType);
	КонецЕсли;
	
	// Initialize input parameters
	Если pGuestName = Неопределено Тогда
		pGuestName = "";
	КонецЕсли;
	Если pRoomCode = Неопределено Тогда
		pRoomCode = "";
	КонецЕсли;
	Если pHotelName = Неопределено Тогда
		pHotelName = "";
	КонецЕсли;
	
	vExtSystemCode = "TraktirFO3";
	Если НЕ IsBlankString(pExtSystemCode) Тогда
		vExtSystemCode = TrimR(pExtSystemCode);
	КонецЕсли;
	vHotel = cmGetHotelByCode(pHotelName, vExtSystemCode);
				  
	// Find ГруппаНомеров by code
	vRoomCode = TrimR(pRoomCode);
	vRoom = cmGetRoomByCode(pRoomCode, pHotelName, vExtSystemCode);
	Если ЗначениеЗаполнено(vRoom) Тогда
		vRoomCode = TrimR(vRoom.Description);
		vHotel = vRoom.Owner;
	КонецЕсли;		
	
	// Log input parameters
	WriteLogEvent(NStr("en='Get list of hotel guests';ru='Получить список гостей гостиницы';de='Liste der Hotelgäste erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='Guest name: ';ru='Имя гостя: ';de='Name des Gastes: '") + pGuestName + Chars.LF +
	              NStr("en='ГруппаНомеров code: ';ru='Код номера: ';de='Zimmercode: '") + pRoomCode + " (" + vRoom + ")" + Chars.LF +
	              NStr("en='Гостиница name: ';ru='Название гостиницы: ';de='Bezeichnung des Hotels: '") + pHotelName + " (" + СокрЛП(vHotel) + ")" + Chars.LF + 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExtSystemCode + " (" + СокрЛП(vExtSystemCode) + ")");
	
	// Try to find guests by input parameters
	vQry = New Query();
	vQry.Text = 
	"SELECT DISTINCT
	|	ЗагрузкаНомеров.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Клиент.FullName AS GuestFullName,
	|	ISNULL(ЗагрузкаНомеров.Клиент.Code, &qEmptyString) AS GuestCode,
	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
	|	ЗагрузкаНомеров.Гостиница.Description AS HotelDescription,
	|	ЗагрузкаНомеров.НомерРазмещения.Description AS RoomDescription,
	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
	|	ЗагрузкаНомеров.Recorder.ДатаВыезда AS ДатаВыезда,
	|	ЗагрузкаНомеров.Recorder.ВидРазмещения AS ВидРазмещения,
	|	ЗагрузкаНомеров.Recorder.НомерДока AS AccommodationCode,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки AS ТипСкидки,
	|	ISNULL(ЗагрузкаНомеров.ГруппаГостей.Code, 0) AS GuestGroupCode,
	|	ЗагрузкаНомеров.Контрагент.Description AS CustomerDescription,
	|	ЗагрузкаНомеров.PlannedPaymentMethod.Description AS PlannedPaymentMethodDescription,
	|	ISNULL(ClientBalances.ClientBalance, 0) + ISNULL(ClientBalances.ClientLimit, 0) AS ClientBalance,
	|	ISNULL(ClientCreditLimit.CreditLimit, 0) AS CreditLimit,
	|	CASE
	|		WHEN ClientBalances.ВалютаЛицСчета IS NULL 
	|			THEN ClientCreditLimit.ВалютаЛицСчета
	|		ELSE ClientBalances.ВалютаЛицСчета
	|	END AS ВалютаЛицСчета,
	|	CASE
	|		WHEN ClientBalances.ВалютаЛицСчета IS NULL 
	|			THEN ClientCreditLimit.ВалютаЛицСчета.Code
	|		ELSE ClientBalances.ВалютаЛицСчета.Code
	|	END AS FolioCurrencyCode
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|		LEFT JOIN (SELECT
	|			ClientAccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|			ClientAccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
	|			SUM(ClientAccountsBalance.SumBalance) AS ClientBalance,
	|			SUM(ClientAccountsBalance.LimitBalance) AS ClientLimit
	|		FROM
	|			AccumulationRegister.Взаиморасчеты.Balance(
	|					&qBalancesPeriod,
	|					NOT СчетПроживания.IsClosed
	|						AND (СчетПроживания.Контрагент = &qEmptyCustomer
	|							OR СчетПроживания.Контрагент = &qIndividualsCustomer
	|							OR СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|								AND СчетПроживания.Контрагент <> &qEmptyCustomer
	|							OR СчетПроживания.Description LIKE &qFolioDescription
	|								AND NOT &qFolioDescriptionIsEmpty)
	|						AND (СчетПроживания.Description LIKE &qFolioDescription
	|							OR &qFolioDescriptionIsEmpty)) AS ClientAccountsBalance
	|		
	|		GROUP BY
	|			ClientAccountsBalance.ВалютаЛицСчета,
	|			ClientAccountsBalance.СчетПроживания.ДокОснование) AS ClientBalances
	|		ON ЗагрузкаНомеров.Recorder = ClientBalances.FolioParentDoc
	|			AND ЗагрузкаНомеров.Recorder.Гостиница.ВалютаЛицСчета = ClientBalances.ВалютаЛицСчета
	|		LEFT JOIN (SELECT
	|			ClientFolios.ВалютаЛицСчета AS ВалютаЛицСчета,
	|			ClientFolios.ДокОснование AS FolioParentDoc,
	|			MAX(CASE
	|					WHEN ClientFolios.Гостиница.NoCreditLimit
	|						THEN 999999999
	|					WHEN ClientFolios.Контрагент <> &qEmptyCustomer
	|							AND ClientFolios.Контрагент <> &qIndividualsCustomer
	|							AND ClientFolios.Контрагент.Parent <> &qIndividualsCustomerFolder
	|							AND ClientFolios.Description LIKE &qFolioDescription
	|							AND NOT &qFolioDescriptionIsEmpty
	|						THEN 999999999
	|					ELSE ClientFolios.CreditLimit
	|				END) AS CreditLimit
	|		FROM
	|			Document.СчетПроживания AS ClientFolios
	|		WHERE
	|			NOT ClientFolios.IsClosed
	|			AND (ClientFolios.Контрагент = &qEmptyCustomer
	|					OR ClientFolios.Контрагент = &qIndividualsCustomer
	|					OR ClientFolios.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|						AND ClientFolios.Контрагент <> &qEmptyCustomer
	|					OR ClientFolios.Description LIKE &qFolioDescription
	|						AND NOT &qFolioDescriptionIsEmpty)
	|			AND (ClientFolios.Description LIKE &qFolioDescription
	|					OR &qFolioDescriptionIsEmpty)
	|		
	|		GROUP BY
	|			ClientFolios.ВалютаЛицСчета,
	|			ClientFolios.ДокОснование) AS ClientCreditLimit
	|		ON ЗагрузкаНомеров.Recorder = ClientCreditLimit.FolioParentDoc
	|			AND ЗагрузкаНомеров.Recorder.Гостиница.ВалютаЛицСчета = ClientCreditLimit.ВалютаЛицСчета
	|WHERE
	|	ЗагрузкаНомеров.IsAccommodation
	|	AND ЗагрузкаНомеров.ЭтоГости
	|	AND ЗагрузкаНомеров.RecordType = &qRecordType
	|	AND ЗагрузкаНомеров.CheckInDate <= &qCurrentDate
	|	AND (ЗагрузкаНомеров.ДатаВыезда >= &qCurrentDate
	|			OR ЗагрузкаНомеров.ДатаВыезда = ЗагрузкаНомеров.Recorder.ДатаВыезда)
	|	AND ЗагрузкаНомеров.Клиент <> &qEmptyClient
	|	AND (ЗагрузкаНомеров.Гостиница.Description = &qHotelName
	|			OR ЗагрузкаНомеров.Гостиница.Code = &qHotelName
	|			OR &qEmptyHotel)
	|	AND (ЗагрузкаНомеров.НомерРазмещения.Description = &qRoomCode
	|			OR &qEmptyRoomCode)
	|	AND (ЗагрузкаНомеров.Клиент.Description LIKE &qGuestName
	|			OR &qEmptyGuestName)
	|
	|ORDER BY
	|	HotelDescription,
	|	RoomDescription,
	|	GuestFullName";
	vQry.УстановитьПараметр("qBalancesPeriod", '39991231235959');
	vQry.УстановитьПараметр("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	vQry.УстановитьПараметр("qIndividualsCustomer", ?(ЗначениеЗаполнено(vHotel), vHotel.IndividualsCustomer, Справочники.Контрагенты.EmptyRef()));
	vQry.УстановитьПараметр("qIndividualsCustomerFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
	vQry.УстановитьПараметр("qEmptyClient", Справочники.Clients.EmptyRef());
	vQry.УстановитьПараметр("qRecordType", AccumulationRecordType.Expense);
	vQry.УстановитьПараметр("qHotelName", TrimR(pHotelName));
	vQry.УстановитьПараметр("qEmptyHotel", IsBlankString(pHotelName));
	vQry.УстановитьПараметр("qGuestName", Upper(TrimR(pGuestName)) + "%");
	vQry.УстановитьПараметр("qEmptyGuestName", IsBlankString(pGuestName));
	vQry.УстановитьПараметр("qRoomCode", TrimR(vRoomCode));
	vQry.УстановитьПараметр("qEmptyRoomCode", IsBlankString(vRoomCode));
	vQry.УстановитьПараметр("qEmptyString", "");
	vQry.УстановитьПараметр("qFolioDescription", "%" + СокрЛП(vHotel.AdditionalServicesFolioCondition) + "%");
	vQry.УстановитьПараметр("qFolioDescriptionIsEmpty", IsBlankString(vHotel.AdditionalServicesFolioCondition));
	vQry.УстановитьПараметр("qCurrentDate", CurrentDate());
	vGuests = vQry.Execute().Unload();
	For Each vGuestsRow In vGuests Do
		// Get discount data
		vDiscount = 0;
		vDiscountType = Неопределено;
		vDiscountCard = Неопределено;
		Если ЗначениеЗаполнено(vGuestsRow.DiscountCard) Тогда
			vDiscountCard = vGuestsRow.DiscountCard;
			vDiscountType = vDiscountCard.ТипСкидки;
			vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
		ИначеЕсли ЗначениеЗаполнено(vGuestsRow.DiscountType) Тогда
			vDiscountType = vGuestsRow.DiscountType;
			vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
		Иначе
			Если ЗначениеЗаполнено(vGuestsRow.Guest) Тогда
				Если ЗначениеЗаполнено(vGuestsRow.Guest.ТипСкидки) Тогда
					vDiscountType = vGuestsRow.Guest.ТипСкидки;
					vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
				Иначе
					vDiscountCard = cmGetDiscountCardByClient(vGuestsRow.Guest);
					Если ЗначениеЗаполнено(vDiscountCard) And ЗначениеЗаполнено(vDiscountCard.ТипСкидки) Тогда
						vDiscountType = vDiscountCard.ТипСкидки;
						vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если ЗначениеЗаполнено(vDiscountType) And vDiscountType.DoNotApplyToExternalInterfaces Тогда
			vDiscount = 0;
			vDiscountType = Неопределено;
			vDiscountCard = Неопределено;
		КонецЕсли;
		
		vIsRoomShare = False;
		Если ЗначениеЗаполнено(vGuestsRow.AccommodationType) And vGuestsRow.AccommodationType.ТипРазмещения <> Перечисления.AccomodationTypes.НомерРазмещения Тогда
			vIsRoomShare = True;
		КонецЕсли;
		
		// Document discount card
		vDocDiscountCard = Неопределено;
		Если ЗначениеЗаполнено(vGuestsRow.DiscountCard) Тогда
			vDocDiscountCard = vGuestsRow.DiscountCard;
		КонецЕсли;
		
		// Add client bonuses
		Если ЗначениеЗаполнено(vGuestsRow.Guest) And ЗначениеЗаполнено(vGuestsRow.FolioCurrency) Тогда
			vClientObj = vGuestsRow.Guest.GetObject();
			vBonus = 0;
			vBonusAmount = vClientObj.pmGetBonusesAmount(vGuestsRow.Гостиница, vGuestsRow.FolioCurrency, vDocDiscountCard, vBonus);
			Если vGuestsRow.CreditLimit < 999999999 Тогда
				vGuestsRow.CreditLimit = vGuestsRow.CreditLimit + vBonusAmount;
			КонецЕсли;
		КонецЕсли;
		
		// Build return string in CSV format
		vRetStr = vRetStr + """" + cmRemoveComma(vGuestsRow.GuestFullName) + ?(ЗначениеЗаполнено(vDocDiscountCard), "(DC " + СокрЛП(vDocDiscountCard.Identifier) + ")", "") + """" + "," + 
		          """" + СокрЛП(vGuestsRow.GuestCode) + """" + "," + 
		          """" + cmRemoveComma(vGuestsRow.HotelDescription) + """" + "," + 
		          """" + cmRemoveComma(vGuestsRow.RoomDescription) + """" + "," + 
		          """" + Format(Дата(vGuestsRow.CheckInDate), "DF='dd.MM.yyyy HH:mm'") + """" + "," + 
		          """" + Format(Дата(vGuestsRow.CheckOutDate), "DF='dd.MM.yyyy HH:mm'") + """" + "," + 
		          Format(vGuestsRow.GuestGroupCode, "ND=12; NFD=0; NZ=; NG=") + "," + 
		          """" + cmRemoveComma(vGuestsRow.CustomerDescription) + """" + "," + 
		          """" + cmRemoveComma(vGuestsRow.PlannedPaymentMethodDescription) + """" + "," + 
		          Format(vGuestsRow.ClientBalance, "ND=17; NFD=2; NDS=.; NZ=; NG=") + "," + 
		          Format(vGuestsRow.CreditLimit, "ND=17; NFD=2; NDS=.; NZ=; NG=") + "," + 
		          """" + СокрЛП(vGuestsRow.FolioCurrencyCode) + """" + "," + 
		          ?(vDiscount <> 0, Format(vDiscount, "ND=6; NFD=2; NDS=.; NZ=; NG="), "0") + "," +
		          """" + ?(ЗначениеЗаполнено(vDiscountType), cmRemoveComma(vDiscountType.Description), "") + """" + "," + 
		          """" + ?(ЗначениеЗаполнено(vDiscountCard), cmRemoveComma(vDiscountCard.Identifier), "") + """" + "," + 
				  """" + СокрЛП(vGuestsRow.AccommodationCode) + """" + "," + 
				  """" + СокрЛП(vIsRoomShare) + """" + Chars.LF;
				  
		// Build XDTO return object
		Если pOutputType <> "CSV" Тогда
			vGuestItem = XDTOFactory.Create(vGuestItemType);
			vGuestItem.Клиент = СокрЛП(vGuestsRow.GuestFullName) + ?(ЗначениеЗаполнено(vDocDiscountCard), "(DC " + СокрЛП(vDocDiscountCard.Identifier) + ")", "");
			vGuestItem.GuestCode = vGuestsRow.GuestCode;
			vGuestItem.Гостиница = СокрЛП(vGuestsRow.HotelDescription);
			vGuestItem.НомерРазмещения = СокрЛП(vGuestsRow.RoomDescription);
			vGuestItem.CheckInDate = Дата(vGuestsRow.CheckInDate);
			vGuestItem.ДатаВыезда = Дата(vGuestsRow.CheckOutDate);
			vGuestItem.ГруппаГостей = vGuestsRow.GuestGroupCode;
			vGuestItem.Контрагент = СокрЛП(vGuestsRow.CustomerDescription);
			vGuestItem.СпособОплаты = СокрЛП(vGuestsRow.PlannedPaymentMethodDescription);
			vGuestItem.ClientBalance = vGuestsRow.ClientBalance;
			vGuestItem.CreditLimit = vGuestsRow.CreditLimit;
			vGuestItem.ВалютаЛицСчета = СокрЛП(vGuestsRow.FolioCurrencyCode);
			vGuestItem.Скидка = vDiscount;
			vGuestItem.ТипСкидки = ?(ЗначениеЗаполнено(vDiscountType), СокрЛП(vDiscountType.Description), "");
			vGuestItem.ДисконтКарт = ?(ЗначениеЗаполнено(vDiscountCard), СокрЛП(vDiscountCard.Identifier), "");
			vGuestItem.AccommodationCode = СокрЛП(vGuestsRow.AccommodationCode);
			vGuestItem.IsRoomShare = vIsRoomShare;
			
			vRetXDTO.GuestItems.GuestItem.Add(vGuestItem);
		КонецЕсли;
	EndDo;
	
	// Возврат based on output type
	WriteLogEvent(NStr("en='Get list of hotel guests';ru='Получить список гостей гостиницы';de='Liste der Hotelgäste erhalten'"), EventLogLevel.Information, , , NStr("en='Возврат string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	Если pOutputType = "CSV" Тогда
		Возврат vRetStr;
	Иначе
		Возврат vRetXDTO;
	КонецЕсли;
КонецФункции //cmGetHotelGuestsList

//-----------------------------------------------------------------------------
// Description: Returns folio parameters including folio balance.
//              Функция could be called as web-service or thru COM connection
// Parameters: ЛицевойСчет number, Гостиница code, External system code, Output type (XDTO or CSV)
// Возврат value: XDTO object or Comma Separated Values string
//-----------------------------------------------------------------------------
Функция cmGetFolioDescription(pFolioNumber, pHotelCode = "", pExternalSystemCode = "", pOutputType = "CSV") Экспорт
	// Log input parameters
	WriteLogEvent(NStr("en='Get folio description';ru='Получить данные лицевого счета';de='Daten der Personenkontos erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница: ';ru='Гостиница: ';de='Гостиница: '") + pHotelCode + Chars.LF + 
	              NStr("en='ЛицевойСчет number: ';ru='Номер фолио: ';de='Folionummer: '") + pFolioNumber);
	
	// Initialize return parameters				  
	vRetStr = "";
	vRetXDTO = Неопределено;
	Если pOutputType <> "CSV" Тогда
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel6.ru/interfaces/restaurant/", "СчетПроживания"));
	КонецЕсли;
	
	// Get hotel
	vHotel = ПараметрыСеанса.ТекущаяГостиница;
	Если НЕ IsBlankString(pHotelCode) Тогда
		vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	КонецЕсли;
	
	// Get folio reference by folio number
	vFolio = cmFindFolioByNumber(pFolioNumber, vHotel);
	Если НЕ ЗначениеЗаполнено(vFolio) Тогда
		WriteLogEvent(NStr("en='Get folio description';ru='Получить данные лицевого счета';de='Daten der Personenkontos erhalten'"), EventLogLevel.Warning, , , 
					  NStr("en='ЛицевойСчет was not found!';ru='Лицевой счет не найден по номеру!';de='Das Personenkonto wurde nach der Nummer nicht gefunden!'"));
		Если pOutputType <> "CSV" Тогда
			ВызватьИсключение NStr("en='ЛицевойСчет was not found!';ru='Лицевой счет не найден по номеру!';de='Das Personenkonto wurde nach der Nummer nicht gefunden!'");
		Иначе
			Возврат NStr("en='ЛицевойСчет was not found!';ru='Лицевой счет не найден по номеру!';de='Das Personenkonto wurde nach der Nummer nicht gefunden!'");
		КонецЕсли;
	КонецЕсли;
	Если ЗначениеЗаполнено(vFolio.Гостиница) Тогда
		vHotel = vFolio.Гостиница;
	КонецЕсли;
	Если vFolio.IsClosed Тогда
		Если pOutputType <> "CSV" Тогда
			ВызватьИсключение NStr("en='ЛицевойСчет is closed!';ru='Лицевой счет закрыт!';de='Das Personenkonto ist geschlossen!'");
		Иначе
			Возврат NStr("en='ЛицевойСчет is closed!';ru='Лицевой счет закрыт!';de='Das Personenkonto ist geschlossen!'");
		КонецЕсли;
	КонецЕсли;
	Если NOT ЗначениеЗаполнено(vFolio.Контрагент) AND NOT ЗначениеЗаполнено(vFolio.Клиент) Тогда
		Если pOutputType <> "CSV" Тогда
			ВызватьИсключение NStr("en='It is not allowed to charge this folio. ЛицевойСчет owner is not specified.';ru='Лицевой счет нельзя использовать для данного способа закрытия заказа! Не задан владелец фолио.';de='Das Personenkonto darf nicht für diese Art der Bestellschließung verwendet werden! Der ЛицевойСчет-Besitzer ist nicht angegeben.'");
		Иначе
			Возврат NStr("en='It is not allowed to charge this folio. ЛицевойСчет owner is not specified.';ru='Лицевой счет нельзя использовать для данного способа закрытия заказа! Не задан владелец фолио.';de='Das Personenkonto darf nicht für diese Art der Bestellschließung verwendet werden! Der ЛицевойСчет-Besitzer ist nicht angegeben.'");
		КонецЕсли;
	КонецЕсли;
	
	// Get folio balance
	vLimit = 0;
	vFolioBalance = vFolio.GetObject().pmGetBalance( , , , vLimit);
	vFolioBalance = vFolioBalance + vLimit;
	
	// Get discount data
	vDiscount = 0;
	vDiscountType = Неопределено;
	vDiscountCard = Неопределено;
	Если ЗначениеЗаполнено(vFolio.FolioDiscountCard) Тогда
		vDiscountCard = vFolio.FolioDiscountCard;
		vDiscountType = vDiscountCard.ТипСкидки;
		vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
	ИначеЕсли ЗначениеЗаполнено(vFolio.FolioDiscountType) Тогда
		vDiscountType = vFolio.FolioDiscountType;
		vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
	ИначеЕсли ЗначениеЗаполнено(vFolio.ДокОснование) And 
	     (TypeOf(vFolio.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(vFolio.ДокОснование) = Type("DocumentRef.Бронирование") Or TypeOf(vFolio.ДокОснование) = Type("DocumentRef.БроньУслуг")) And 
		  ЗначениеЗаполнено(vFolio.ДокОснование.ДисконтКарт) Тогда
		vDiscountCard = vFolio.ДокОснование.ДисконтКарт;
		vDiscountType = vDiscountCard.ТипСкидки;
		vDiscount = vFolio.ДокОснование.Скидка;
	ИначеЕсли ЗначениеЗаполнено(vFolio.ДокОснование) And 
	     (TypeOf(vFolio.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(vFolio.ДокОснование) = Type("DocumentRef.Бронирование") Or TypeOf(vFolio.ДокОснование) = Type("DocumentRef.БроньУслуг")) And 
		  ЗначениеЗаполнено(vFolio.ДокОснование.ТипСкидки) Тогда
		vDiscountType = vFolio.ДокОснование.ТипСкидки;
		vDiscount = vFolio.ДокОснование.Скидка;
	ИначеЕсли ЗначениеЗаполнено(vFolio.Клиент) Тогда
		Если ЗначениеЗаполнено(vFolio.Клиент.ТипСкидки) Тогда
			vDiscountType = vFolio.Клиент.ТипСкидки;
			vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
		Иначе
			vDiscountCard = cmGetDiscountCardByClient(vFolio.Клиент);
			Если ЗначениеЗаполнено(vDiscountCard) And ЗначениеЗаполнено(vDiscountCard.ТипСкидки) Тогда
				vDiscountType = vDiscountCard.ТипСкидки;
				vDiscount = vDiscountType.GetObject().pmGetDiscount(, , vHotel);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Если ЗначениеЗаполнено(vDiscountType) And vDiscountType.DoNotApplyToExternalInterfaces Тогда
		vDiscount = 0;
		vDiscountType = Неопределено;
		vDiscountCard = Неопределено;
	КонецЕсли;
	
	vCreditLimit = vFolio.CreditLimit;
	Если vFolio.IsClosed Тогда
		vCreditLimit = 0;
	Иначе
		Если ЗначениеЗаполнено(vHotel) And vHotel.NoCreditLimit Тогда
			vCreditLimit = 999999999;
		КонецЕсли;
	КонецЕсли;
	
	// Add client bonuses
	Если ЗначениеЗаполнено(vFolio.Клиент) Тогда
		vDocDiscountCard = Неопределено;
		Если ЗначениеЗаполнено(vFolio.ДокОснование) And 
		  (TypeOf(vFolio.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(vFolio.ДокОснование) = Type("DocumentRef.Бронирование") Or TypeOf(vFolio.ДокОснование) = Type("DocumentRef.БроньУслуг")) And 
		   ЗначениеЗаполнено(vFolio.ДокОснование.ДисконтКарт) Тогда
			vDocDiscountCard = vFolio.ДокОснование.ДисконтКарт;
		КонецЕсли;
		vClientObj = vFolio.Клиент.GetObject();
		vBonus = 0;
		vBonusAmount = vClientObj.pmGetBonusesAmount(vFolio.Гостиница, vFolio.ВалютаЛицСчета, vDocDiscountCard, vBonus);
		Если vCreditLimit < 999999999 Тогда
			vCreditLimit = vCreditLimit + vBonusAmount;
		КонецЕсли;
	КонецЕсли;
	
	// Build return string in CSV format
	vRetStr = """" + "" + """" + ","; //Error description 
	vRetStr = vRetStr + """" + СокрЛП(СокрЛП(vFolio.НомерДока)) + """" + ",";
	vRetStr = vRetStr + """" + cmRemoveComma(vFolio.Description) + """" + ",";
	vRetStr = vRetStr + """" + cmRemoveComma(vHotel.Description) + """" + ","; 
	vRetStr = vRetStr + """" + СокрЛП(vFolio.НомерРазмещения) + """" + ",";
	vRetStr = vRetStr + """" + Format(vFolio.DateTimeFrom, "DF='dd.MM.yyyy HH:mm'") + """" + ",";
	vRetStr = vRetStr + """" + Format(vFolio.DateTimeTo, "DF='dd.MM.yyyy HH:mm'") + """" + ",";
	vRetStr = vRetStr + ?(ЗначениеЗаполнено(vFolio.ГруппаГостей), Format(vFolio.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG="), 0) + ",";
	vRetStr = vRetStr + """" + cmRemoveComma(vFolio.Контрагент) + """" + ",";
	vRetStr = vRetStr + """" + ?(ЗначениеЗаполнено(vFolio.Контрагент), СокрЛП(vFolio.Контрагент.Code),"") + """" + ",";
	vRetStr = vRetStr + """" + cmRemoveComma(vFolio.СпособОплаты) + """" + ",";
	vRetStr = vRetStr + Format(vFolioBalance, "ND=17; NFD=2; NDS=.; NZ=; NG=") + ",";
	vRetStr = vRetStr + """" + СокрЛП(vFolio.ВалютаЛицСчета.Code) + """" + ",";
	vRetStr = vRetStr + Format(vCreditLimit, "ND=17; NFD=2; NDS=.; NZ=; NG=") + ",";
	vRetStr = vRetStr + """" + ?(ЗначениеЗаполнено(vFolio.Клиент), cmRemoveComma(vFolio.Клиент.FullName), "") + """" + ",";
	vRetStr = vRetStr + """" + ?(ЗначениеЗаполнено(vFolio.Клиент), СокрЛП(vFolio.Клиент.Code), "") + """" + ",";
	vRetStr = vRetStr + ?(vDiscount <> 0, Format(vDiscount, "ND=6; NFD=2; NDS=.; NZ=; NG="), "0") + ",";
	vRetStr = vRetStr + """" + ?(ЗначениеЗаполнено(vDiscountType), cmRemoveComma(vDiscountType.Description), "") + """" + ",";
	vRetStr = vRetStr + """" + ?(ЗначениеЗаполнено(vDiscountCard), cmRemoveComma(vDiscountCard.Identifier), "") + """";
	// Build XDTO return object
	Если pOutputType <> "CSV" Тогда
		vRetXDTO.FolioNumber = СокрЛП(vFolio.НомерДока);
		vRetXDTO.FolioDescription = Left(СокрЛП(vFolio.Description), 2048);
		vRetXDTO.Гостиница = СокрЛП(vHotel.Description);
		vRetXDTO.НомерРазмещения = СокрЛП(vFolio.НомерРазмещения);
		vRetXDTO.CheckInDate = vFolio.DateTimeFrom;
		vRetXDTO.ДатаВыезда = vFolio.DateTimeTo;
		vRetXDTO.ГруппаГостей = ?(ЗначениеЗаполнено(vFolio.ГруппаГостей), vFolio.ГруппаГостей.Code, 0);
		vRetXDTO.Контрагент = СокрЛП(vFolio.Контрагент);
		vRetXDTO.СпособОплаты = СокрЛП(vFolio.СпособОплаты);
		vRetXDTO.FolioBalance = vFolioBalance;
		vRetXDTO.ВалютаЛицСчета = СокрЛП(vFolio.ВалютаЛицСчета.Code);
		vRetXDTO.CreditLimit = vCreditLimit;
		vRetXDTO.Клиент = ?(ЗначениеЗаполнено(vFolio.Клиент), СокрЛП(vFolio.Клиент.FullName), "");
		vRetXDTO.ClientCode = ?(ЗначениеЗаполнено(vFolio.Клиент), СокрЛП(vFolio.Клиент.Code), "");
		vRetXDTO.CustomerCode = ?(ЗначениеЗаполнено(vFolio.Контрагент), СокрЛП(vFolio.Контрагент.Code), "");
		vRetXDTO.Скидка = vDiscount;
		vRetXDTO.ТипСкидки = ?(ЗначениеЗаполнено(vDiscountType), СокрЛП(vDiscountType.Description), "");
		vRetXDTO.ДисконтКарт = ?(ЗначениеЗаполнено(vDiscountCard), СокрЛП(vDiscountCard.Identifier), "");
	КонецЕсли;
	
	// Возврат based on output type
	WriteLogEvent(NStr("en='Get folio description';ru='Получить данные лицевого счета';de='Daten der Personenkontos erhalten'"), EventLogLevel.Information, , , NStr("en='Возврат string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	Если pOutputType = "CSV" Тогда
		Возврат vRetStr;
	Иначе
		Возврат vRetXDTO;
	КонецЕсли;
КонецФункции //cmGetFolioDescription 

//-----------------------------------------------------------------------------
Функция cmGetInvoiceList(pPeriodFrom, pPeriodTo) Экспорт 
	WriteLogEvent(NStr("en='GetInvoiceList'; ru='Получение счетов на оплату, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo);
	
	vInvoiceTableType 				= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "InvoiceTable");
	vInvoiceTableRowType			= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "InvoiceTableRow");
	vInvoiceListType 				= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "InvoiceList");
	vInvoiceTableServicesType 		= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "InvoiceTableServices");
	vInvoiceTableServicesRowType	= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "InvoiceTableServicesRow");
	vServicesItemRowType			= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "ServicesItemRow");
	vAccountingCustomerType	        = XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "CustomersItemRow");
	vAccountingContractType	        = XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "Договор");
	vCompanyType	        		= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "CompanyItemRow");
	vAccountingCurrencyType	        = XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "ВалютаРасчетов");
	vVATRateType	        		= XDTOFactory.Type("http://www.1chotel.ru/interfaces6/accounting/", "СтавкаНДС");
	
	vRetXDTO 						= XDTOFactory.Create(vInvoiceListType);
	vRetXDTO.InvoiceTable			= XDTOFactory.Create(vInvoiceTableType);
	vRetXDTO.ErrorDescription 	= "";
	
	Try
		vQry = New Query;
		vQry.Text = 
		"SELECT DISTINCT
		|	InvoiceServices.Ref
		|FROM
		|	Document.СчетНаОплату.Услуги AS InvoiceServices
		|WHERE
		|	InvoiceServices.Ref.ChangeDate >= &qPeriodFrom
		|	AND InvoiceServices.Ref.ChangeDate <= &qEndOfTimes
		|	AND InvoiceServices.Ref.Posted
		|	AND InvoiceServices.Сумма <> 0
		|
		|ORDER BY
		|	InvoiceServices.Ref.ДатаДок";
		vQry.УстановитьПараметр("qPeriodFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qEndOfTimes",pPeriodTo);
		vTrans = vQry.Execute().Unload();
		For Each mRow In vTrans Do
			vInvoiceRow  		= XDTOFactory.Create(vInvoiceTableRowType);
			vAccountingCustomer = XDTOFactory.Create(vAccountingCustomerType);
			vAccountingContract = XDTOFactory.Create(vAccountingContractType); 
			vCompany			= XDTOFactory.Create(vCompanyType);
			vAccountingCurrency	= XDTOFactory.Create(vAccountingCurrencyType);
			
			vAccountingCustomer.Code 					=  ?(ЗначениеЗаполнено(mRow.Ref.Контрагент),mRow.Ref.Контрагент.Code,"");
			vAccountingCustomer.Description 			=  mRow.Ref.Контрагент.Description;
			vAccountingCustomer.ExternalCode 			=  mRow.Ref.Контрагент.ExternalCode;
			vAccountingCustomer.ИНН 					=  mRow.Ref.Контрагент.ИНН;
			
			vAccountingContract.Code 					=  ?(ЗначениеЗаполнено(mRow.Ref.Договор),mRow.Ref.Договор.Code,"");
			vAccountingContract.Description 			=  mRow.Ref.Договор.Description;
			vAccountingContract.ExternalCode 			=  mRow.Ref.Договор.ExternalCode;
			
			vCompany.Code 								=  ?(ЗначениеЗаполнено(mRow.Ref.Фирма),mRow.Ref.Фирма.Code,"");
			vCompany.Description 						=  mRow.Ref.Фирма.Description;
			vCompany.ExternalCode 						=  mRow.Ref.Фирма.ExternalCode;
			
			vAccountingCurrency.Code 					=  ?(ЗначениеЗаполнено(mRow.Ref.ВалютаРасчетов),mRow.Ref.ВалютаРасчетов.Code,"");
			vAccountingCurrency.Description 			=  mRow.Ref.ВалютаРасчетов.Description;
			
			vTableServices	= XDTOFactory.Create(vInvoiceTableServicesType);
			For Each vRow In mRow.Ref.Услуги Do
				vService			= XDTOFactory.Create(vServicesItemRowType);
				vServiceRow  		= XDTOFactory.Create(vInvoiceTableServicesRowType);
				vVATRate            = XDTOFactory.Create(vVATRateType); 
				
				vService.Code							=  vRow.Услуга.Code;
				vService.Description  					=  vRow.Услуга.Description;
				vService.ExternalCode       			=  vRow.Услуга.ExternalCode;
				vService.IsRoomRevenue       			=  vRow.Услуга.IsRoomRevenue;
				vService.ServiceTypeDescription   		=  ?(ЗначениеЗаполнено(vRow.Услуга.ServiceType),vRow.Услуга.ServiceType.Description,"");
				vService.ServiceTypeCode   		 		=  ?(ЗначениеЗаполнено(vRow.Услуга.ServiceType),vRow.Услуга.ServiceType.Code,"");

				vVATRate.Ставка                        =  vRow.СтавкаНДС.Ставка;
				vVATRate.Description                    =  vRow.СтавкаНДС.Description;
				
				vServiceRow.Услуга                     =  vService;
				vServiceRow.Цена                    	=  vRow.Цена;
				vServiceRow.Количество                    =  vRow.Количество;
				vServiceRow.СтавкаНДС                     =  vVATRate;
				vServiceRow.СуммаНДС                      =  vRow.СуммаНДС;
				vServiceRow.Сумма                     	=  vRow.Сумма;
				vServiceRow.Примечания                     =  vRow.Примечания;
				
				vTableServices.InvoiceTableServicesRow.Add(vServiceRow);	
			EndDo;
			
			vInvoiceRow.НомерДока							=  mRow.Ref.НомерДока;
			vInvoiceRow.Контрагент				=  vAccountingCustomer;
			vInvoiceRow.Договор				=  vAccountingContract;
			vInvoiceRow.ExternalCode					=  mRow.Ref.ExternalCode;
			vInvoiceRow.Period							=  mRow.Ref.ДатаДок;
			vInvoiceRow.ВалютаРасчетов   			=  vAccountingCurrency;
			vInvoiceRow.Фирма							=  vCompany;
			vInvoiceRow.TableServices					=  vTableServices;
			
			vRetXDTO.InvoiceTable.InvoiceTableRow.Add(vInvoiceRow);
		EndDo;
		
		Возврат vRetXDTO;
		
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
	EndTry;
КонецФункции	  //cmGetInvoiceList

//-----------------------------------------------------------------------------
Функция cmGetServices(pPeriodFrom,pPeriodTo) Экспорт 
	WriteLogEvent(NStr("en='Get services list'; ru='Получение списка услуг, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo);
	
	vServiceType 			= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "Услуги");
	vServiceItemRowType 	= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "ServicesItemRow");
	vServiceListType 		= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "ServicesList");
	
	vRetXDTO 				= XDTOFactory.Create(vServiceListType);
	vRetXDTO.Услуги   	= XDTOFactory.Create(vServiceType);
	vRetXDTO.ErrorDescription 	= "";
	
	Try
		vQry = new Query;
		vQry.Text = "SELECT
		            |	UsedServices.Услуга.Code AS Code,
		            |	UsedServices.Услуга.Description AS Description,
		            |	UsedServices.Услуга.ExternalCode AS ExternalCode,
		            |	UsedServices.Услуга
		            |FROM
		            |	(SELECT
		            |		AccountsReceivableTurnovers.Услуга AS Услуга
		            |	FROM
		            |		AccumulationRegister.БухРеализацияУслуг.Turnovers(&qPeriodFrom, &qPeriodTo, Period, ) AS AccountsReceivableTurnovers
		            |	
		            |	UNION ALL
		            |	
		            |	SELECT
		            |		InvoiceServices.Услуга
		            |	FROM
		            |		Document.СчетНаОплату.Услуги AS InvoiceServices
		            |	WHERE
		            |		InvoiceServices.Ref.Posted
		            |		AND InvoiceServices.Ref.ChangeDate >= &qPeriodFrom
		            |		AND InvoiceServices.Ref.ChangeDate <= &qPeriodTo) AS UsedServices
		            |
		            |GROUP BY
		            |	UsedServices.Услуга.Code,
		            |	UsedServices.Услуга.Description,
		            |	UsedServices.Услуга.ExternalCode,
		            |	UsedServices.Услуга";
		
		vQry.УстановитьПараметр("qPeriodFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qPeriodTo", pPeriodTo);
		vTrans = vQry.Execute().Unload();
		
		WriteLogEvent(NStr("en='Get services list'; ru='Получение списка услуг'"), EventLogLevel.Information, 
		, , NStr("en='Services count: '; ru='Количество полученных услуг: '") +vTrans.Count());
		
		
		For Each mRow In vTrans Do
			vServiceItemRow = XDTOFactory.Create(vServiceItemRowType);
			
			vServiceItemRow.Code					 =  mRow.Code;
			vServiceItemRow.Description  			 =  mRow.Description;
			vServiceItemRow.ExternalCode    		 =  mRow.ExternalCode;
			vServiceItemRow.IsRoomRevenue   		 =  mRow.Service.IsRoomRevenue;
			vServiceItemRow.ServiceTypeDescription   =  ?(ЗначениеЗаполнено(mRow.Service.ServiceType),mRow.Service.ServiceType.Description,"");
			vServiceItemRow.ServiceTypeCode   		 =  ?(ЗначениеЗаполнено(mRow.Service.ServiceType),mRow.Service.ServiceType.Code,"");
			
			vRetXDTO.Услуги.ServicesItemRow.Add(vServiceItemRow);
		EndDo;
		
		Возврат vRetXDTO;	
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
	EndTry;
КонецФункции  //cmGetServices

//-----------------------------------------------------------------------------
Функция cmGetCustomers(pPeriodFrom, pPeriodTo, pCompanyCode = "") Экспорт
	WriteLogEvent(NStr("en='Get customers list'; ru='Получение списка контрагентов'"), EventLogLevel.Information, , , 
	              NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom + Chars.LF + 
				  NStr("en='Дата to: '; ru='Дата окончания: '") + pPeriodTo + Chars.LF + 
				  NStr("en='Фирма code: '; ru='Код фирмы: '") + pCompanyCode);
	
	vCustomers 				= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "Контрагенты");
	vCustomersItemRowType 	= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "CustomersItemRow");
	vCustomersListType 		= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "CustomersList");
	
	vRetXDTO 				= XDTOFactory.Create(vCustomersListType);
	vRetXDTO.Контрагенты   	= XDTOFactory.Create(vCustomers);
	vRetXDTO.ErrorDescription 	= "";
	
	Try
		vQry = new Query;
		vQry.Text = 
		"SELECT
		|	Common.Контрагент.Code AS Code,
		|	Common.Контрагент.Description AS Description,
		|	Common.Контрагент.ИНН AS ИНН,
		|	Common.Контрагент.ExternalCode AS ExternalCode
		|FROM
		|	(SELECT
		|		CashRegisterDailyReceiptsTurnovers.Контрагент AS Контрагент
		|	FROM
		|		AccumulationRegister.ВыручкаПоСменам.Turnovers(&qPeriodFrom, &qPeriodTo, Period, ) AS CashRegisterDailyReceiptsTurnovers
		|	WHERE
		|		(&qCompanyCodeIsEmpty
		|				OR NOT &qCompanyCodeIsEmpty
		|					AND CashRegisterDailyReceiptsTurnovers.Фирма.ExternalCode = &qCompanyCode)
		|	
		|	GROUP BY
		|		CashRegisterDailyReceiptsTurnovers.Контрагент
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		AccountsReceivableTurnovers.Контрагент
		|	FROM
		|		AccumulationRegister.БухРеализацияУслуг.Turnovers(
		|				&qPeriodFrom,
		|				&qPeriodTo,
		|				Period,
		|				&qCompanyCodeIsEmpty
		|					OR NOT &qCompanyCodeIsEmpty
		|						AND Фирма.ExternalCode = &qCompanyCode) AS AccountsReceivableTurnovers
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		InvoiceServices.Ref.Контрагент
		|	FROM
		|		Document.СчетНаОплату.Услуги AS InvoiceServices
		|	WHERE
		|		InvoiceServices.Ref.ChangeDate >= &qPeriodFrom
		|		AND InvoiceServices.Ref.ChangeDate <= &qPeriodTo
		|		AND (&qCompanyCodeIsEmpty
		|				OR NOT &qCompanyCodeIsEmpty
		|					AND InvoiceServices.Ref.Фирма.ExternalCode = &qCompanyCode)) AS Common
		|
		|GROUP BY
		|	Common.Контрагент.ExternalCode,
		|	Common.Контрагент.ИНН,
		|	Common.Контрагент.Code,
		|	Common.Контрагент.Description
		|
		|ORDER BY
		|	Common.Контрагент.Description";
		vQry.УстановитьПараметр("qCompanyCode", pCompanyCode);
		vQry.УстановитьПараметр("qCompanyCodeIsEmpty", IsBlankString(pCompanyCode));
		vQry.УстановитьПараметр("qPeriodFrom", 	pPeriodFrom);
		vQry.УстановитьПараметр("qPeriodTo", 		pPeriodTo);
		vTrans = vQry.Execute().Unload();
		For Each mRow In vTrans Do
			vCustomersItemRow = XDTOFactory.Create(vCustomersItemRowType);
			FillPropertyValues(vCustomersItemRow,mRow);
			vRetXDTO.Контрагенты.CustomersItemRow.Add(vCustomersItemRow);
		EndDo;
		Возврат vRetXDTO;	
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, , , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
	EndTry;
КонецФункции  //cmGetCustomers

//-----------------------------------------------------------------------------
Функция cmGetCompany(pPeriodFrom, pPeriodTo) Экспорт
	vCompanyType 				= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "Фирма");
	vCompanyItemRowType 		= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "CompanyItemRow");
	vCompanyListType 			= XDTOFactory.Type("http://www.1chotel.ru/interfaces7/accounting/", "CompanyList");
	
	vRetXDTO 					= XDTOFactory.Create(vCompanyListType);
	vRetXDTO.Фирма   			= XDTOFactory.Create(vCompanyType);
	vRetXDTO.ErrorDescription 	= "";
	
	Try
		vQry = new Query;
		vQry.Text =
		"SELECT
		|	Common.Фирма.Description AS Description,
		|	Common.Фирма.ExternalCode AS ExternalCode,
		|	Common.Фирма.Code AS Code
		|FROM
		|	(SELECT
		|		CashRegisterDailyReceiptsTurnovers.Фирма AS Фирма
		|	FROM
		|		AccumulationRegister.ВыручкаПоСменам.Turnovers(&qPeriodFrom, &qPeriodTo, Period, ) AS CashRegisterDailyReceiptsTurnovers
		|	
		|	GROUP BY
		|		CashRegisterDailyReceiptsTurnovers.Фирма
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		AccountsReceivableTurnovers.Фирма
		|	FROM
		|		AccumulationRegister.БухРеализацияУслуг.Turnovers(&qPeriodFrom, &qPeriodTo, Period, ) AS AccountsReceivableTurnovers
		|	
		|	GROUP BY
		|		AccountsReceivableTurnovers.Фирма) AS Common
		|
		|GROUP BY
		|	Common.Фирма.Description,
		|	Common.Фирма.ExternalCode,
		|	Common.Фирма.Code
		|
		|ORDER BY
		|	Common.Фирма.Description";
		
		vQry.УстановитьПараметр("qPeriodFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qPeriodTo", pPeriodTo);
		vTrans = vQry.Execute().Unload();
		
		
		For Each mRow In vTrans Do
			vCompanyItemRow = XDTOFactory.Create(vCompanyItemRowType);
			
			FillPropertyValues(vCompanyItemRow,mRow);
			
			vRetXDTO.Фирма.CompanyItemRow.Add(vCompanyItemRow);
		EndDo;
		
		Возврат vRetXDTO;	
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
		
	EndTry;
	
КонецФункции  //cmGetCompany

//-----------------------------------------------------------------------------
Функция cmGetSettlement(pCompanyCode,pPeriodFrom,pPeriodTo) Экспорт
	WriteLogEvent(NStr("en='Get settlement list'; ru='Получение списка актов, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo
	+Chars.LF+NStr("en='Фирма сode: '; ru='Код фирмы: '")+pCompanyCode);

	vSettlementType 				= XDTOFactory.Type("http://www.1chote7l.ru/interfaces7/accounting/", "Акт");
	vSettlementItemRowType 			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "SettlementItemRow");
	vSettlementListType 			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "SettlementList");
	vAccountingCustomerType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CustomersItemRow");
	vAccountingContractType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "Договор");
	vCompanyType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CompanyItemRow");
	vGuestGroupType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ГруппаГостей");
	vAccountingCurrencyType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ВалютаРасчетов");
	
	vRetXDTO 					= XDTOFactory.Create(vSettlementListType);
	vRetXDTO.Акт   		= XDTOFactory.Create(vSettlementType);
	vRetXDTO.ErrorDescription 	= "";
	Try	
		vQry = new Query;
		vQry.Text = 
		"SELECT
		|	Акт.Ref,
		|	Акт.ДатаДок,
		|	Акт.НомерДока,
		|	Акт.Posted,
		|	Акт.Гостиница,
		|	Акт.Фирма,
		|	Акт.Контрагент,
		|	Акт.Договор,
		|	Акт.ГруппаГостей,
		|	Акт.Сумма,
		|	Акт.ВалютаРасчетов,
		|	Акт.InvoiceNumber,
		|	Акт.ExternalCode
		|FROM
		|	Document.Акт AS Акт
		|WHERE
		|	Акт.ChangeDate >= &qDateFrom
		|	AND Акт.ChangeDate <= &qDateTo";
		Если ЗначениеЗаполнено(pCompanyCode) Тогда
			vQry.УстановитьПараметр("qCompanyCode", pCompanyCode);
			vQry.Text = vQry.Text + "
			|	AND Акт.Фирма.ExternalCode = &qCompanyCode";
		КонецЕсли;
		vQry.Text = vQry.Text +"
		|	AND (NOT Акт.DoNotExportToTheAccountingSystem)
		|	AND Акт.Posted";
		vQry.УстановитьПараметр("qDateFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qDateTo", pPeriodTo);	
		vTrans = vQry.Execute().Unload();	
		
		For Each mRow In vTrans Do
			vSettlementItemRow  = XDTOFactory.Create(vSettlementItemRowType);
			vAccountingCustomer = XDTOFactory.Create(vAccountingCustomerType);
			vAccountingContract = XDTOFactory.Create(vAccountingContractType); 
			vCompany			= XDTOFactory.Create(vCompanyType);
			vGuestGroup			= XDTOFactory.Create(vGuestGroupType);
			vAccountingCurrency	= XDTOFactory.Create(vAccountingCurrencyType);
			
			//Fill Accounting Контрагент
			FillPropertyValues(vAccountingCustomer,mRow.AccountingCustomer);
			//Fill Accounting Contract
			FillPropertyValues(vAccountingContract,mRow.AccountingContract);
			//Fill Фирма
			FillPropertyValues(vCompany,mRow.Company);
            //Fill Guest Group
			FillPropertyValues(vGuestGroup,mRow.GuestGroup);
			//Fill Accounting Currency
			FillPropertyValues(vAccountingCurrency,mRow.AccountingCurrency);

			vSettlementItemRow.Контрагент		=  vAccountingCustomer;
			vSettlementItemRow.Договор		=  vAccountingContract;
			vSettlementItemRow.ГруппаГостей				=  vGuestGroup;
			vSettlementItemRow.ExternalCode				=  mRow.ExternalCode;
			vSettlementItemRow.НомерДока					=  mRow.Number;
			vSettlementItemRow.ДатаДок						=  mRow.Дата;
			vSettlementItemRow.Сумма						=  mRow.Sum;
			vSettlementItemRow.ВалютаРасчетов   	=  vAccountingCurrency;
			vSettlementItemRow.Фирма					=  vCompany;
			
			vRetXDTO.Акт.SettlementItemRow.Add(vSettlementItemRow);
		EndDo;
		Возврат vRetXDTO;	
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
		
	EndTry;
КонецФункции  //cmGetSettlement

//-----------------------------------------------------------------------------
Функция cmGetSettlementTable(pDocNumber,pPeriodFrom,pPeriodTo) Экспорт
	WriteLogEvent(NStr("en='Get services settlement table, input parameters'; ru='Получение списка услуг по акту, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo
	+Chars.LF+NStr("en='Doc Number: '; ru='Номер акта: '")+pDocNumber);
	
	vSettlementServicesTableType 	= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "SettlementServicesTable");
	vSettlementServicesTableRowType	= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "SettlementServicesTableRow");
	vSettlementServicesListType 	= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "SettlementServicesList");
	vAccountingCustomerType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CustomersItemRow");
	vAccountingContractType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "Договор");
	vCompanyType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CompanyItemRow");
	vGuestGroupType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ГруппаГостей");
	vAccountingCurrencyType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ВалютаРасчетов");
	vClientType	        			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "Клиент");
	vRoomType	        			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "НомерРазмещения");
	vFolioType	        			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "СчетПроживания");
	vVATRateType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "СтавкаНДС");
	vParentDocType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ДокОснование");
	vServicesType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ServicesItemRow");
	
	vRetXDTO 						= XDTOFactory.Create(vSettlementServicesListType);
	vRetXDTO.SettlementServicesTable= XDTOFactory.Create(vSettlementServicesTableType);
	vRetXDTO.ErrorDescription 	= "";
	Try
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	БухРеализацияУслуг.Period,
		|	БухРеализацияУслуг.Recorder AS Recorder,
		|	БухРеализацияУслуг.Recorder.НомерДока AS RecorderNumber,
		|	БухРеализацияУслуг.Recorder.ExternalCode AS ExternalCode,
		|	БухРеализацияУслуг.LineNumber,
		|	БухРеализацияУслуг.Active,
		|	БухРеализацияУслуг.Фирма,
		|	БухРеализацияУслуг.Контрагент,
		|	БухРеализацияУслуг.Договор,
		|	БухРеализацияУслуг.ГруппаГостей,
		|	БухРеализацияУслуг.ВалютаРасчетов,
		|	БухРеализацияУслуг.Услуга,
		|	БухРеализацияУслуг.Гостиница,
		|	БухРеализацияУслуг.Сумма,
		|	БухРеализацияУслуг.СуммаНДС,
		|	БухРеализацияУслуг.Количество,
		|	БухРеализацияУслуг.СчетПроживания,
		|	БухРеализацияУслуг.Клиент,
		|	БухРеализацияУслуг.НомерРазмещения,
		|	БухРеализацияУслуг.УчетнаяДата,
		|	БухРеализацияУслуг.Цена,
		|	БухРеализацияУслуг.СтавкаНДС
		|FROM
		|	AccumulationRegister.БухРеализацияУслуг AS БухРеализацияУслуг
		|WHERE
		|	БухРеализацияУслуг.Period >= &qDateFrom
		|	AND БухРеализацияУслуг.Period <= &qDateTo
		|	AND БухРеализацияУслуг.Recorder.НомерДока = &qDocNumber
		|
		|ORDER BY
		|	RecorderNumber,
		|	БухРеализацияУслуг.PointInTime";
		vQry.УстановитьПараметр("qDateFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qDateTo", pPeriodTo);
		vQry.УстановитьПараметр("qDocNumber", pDocNumber);
		
		vTrans = vQry.Execute().Unload();
		WriteLogEvent(NStr("en='Get services settlement table'; ru='Получение списка услуг по акту'"), EventLogLevel.Information, 
		, , NStr("en='Services count: '; ru='Количество полученных услуг: '") +vTrans.Count());
		
		For Each mRow In vTrans Do
			vSetServiceItemRow  = XDTOFactory.Create(vSettlementServicesTableRowType);
			vAccountingCustomer = XDTOFactory.Create(vAccountingCustomerType);
			vAccountingContract = XDTOFactory.Create(vAccountingContractType); 
			vCompany			= XDTOFactory.Create(vCompanyType);
			vGuestGroup			= XDTOFactory.Create(vGuestGroupType);
			vAccountingCurrency	= XDTOFactory.Create(vAccountingCurrencyType);
			vClient				= XDTOFactory.Create(vClientType);
			vRoom				= XDTOFactory.Create(vRoomType);
			vFolio				= XDTOFactory.Create(vFolioType);
			vParentDoc			= XDTOFactory.Create(vParentDocType);
			vVATRate			= XDTOFactory.Create(vVATRateType);
			vServices           = XDTOFactory.Create(vServicesType);
			
			vAccountingCustomer.Code 					=  ?(ЗначениеЗаполнено(mRow.AccountingCustomer),mRow.AccountingCustomer.Code,"");
			vAccountingCustomer.Description 			=  mRow.AccountingCustomer.Description;
			vAccountingCustomer.ExternalCode 			=  mRow.AccountingCustomer.ExternalCode;
			vAccountingCustomer.ИНН 					=  mRow.AccountingCustomer.ИНН;
			
			vAccountingContract.Code 					=  ?(ЗначениеЗаполнено(mRow.AccountingContract),mRow.AccountingContract.Code,"");
			vAccountingContract.Description 			=  mRow.AccountingContract.Description;
			vAccountingContract.ExternalCode 			=  mRow.AccountingContract.ExternalCode;
			
			vCompany.Code 								=  ?(ЗначениеЗаполнено(mRow.Company),mRow.Фирма.Code,"");
			vCompany.Description 						=  mRow.Фирма.Description;
			vCompany.ExternalCode 						=  mRow.Фирма.ExternalCode;
			
			vGuestGroup.Code 							=  ?(ЗначениеЗаполнено(mRow.GuestGroup),mRow.GuestGroup.Code,"");
			vGuestGroup.Description 					=  mRow.GuestGroup.Description;
			vGuestGroup.ExternalCode 					=  mRow.GuestGroup.ExternalCode;
			
			vAccountingCurrency.Code 					=  ?(ЗначениеЗаполнено(mRow.AccountingCurrency),mRow.AccountingCurrency.Code,"");
			vAccountingCurrency.Description 			=  mRow.AccountingCurrency.Description;
			
			vClient.Code 								=  ?(ЗначениеЗаполнено(mRow.Client),mRow.Client.Code,"");
			vClient.Description 						=  mRow.Client.Description;
			
			vRoom.Code 									=  ?(ЗначениеЗаполнено(mRow.Room),mRow.ГруппаНомеров.Code,"");
			vRoom.Description 							=  mRow.ГруппаНомеров.Description;
			
			vFolio.DateTimeFrom 						=  mRow.ЛицевойСчет.DateTimeFrom;
			vFolio.DateTimeTo 							=  mRow.ЛицевойСчет.DateTimeTo;
			vFolio.НомерДока 								=  mRow.ЛицевойСчет.НомерДока;
			vFolio.Description 							=  mRow.ЛицевойСчет.Description;
			vParentDoc.HasOfficialLetter            	=  False;

			//Fill VATRate
			FillPropertyValues(vVATRate,mRow.VATRate);
			//Fill Service
			FillPropertyValues(vServices,mRow.Service);
			
			Если  ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование) Тогда
				vParentDoc.HasOfficialLetter            =  ?(mRow.ЛицевойСчет.ДокОснование.Metadata().Attributes.Find("HasOfficialLetter")<>Неопределено,mRow.ЛицевойСчет.ДокОснование.HasOfficialLetter,False);
				vGuest									=  XDTOFactory.Create(vClientType);
				
				Если mRow.ЛицевойСчет.ДокОснование.Metadata().Attributes.Find("Клиент")<>Неопределено  Тогда
					vGuest.Code 							=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Code,"");
					vGuest.Description 						=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Description,"");
				ИначеЕсли mRow.ЛицевойСчет.ДокОснование.Metadata().Attributes.Find("Клиент")<>Неопределено  Тогда
					vGuest.Code 						=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Code,"");
					vGuest.Description 					=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Description,"");
				Иначе
					vGuest.Code 						=  "";
					vGuest.Description 					=  "";
				КонецЕсли;
				vParentDoc.Клиент            			=  vGuest;
			КонецЕсли;	
			vFolioGuestGroup                       		=  XDTOFactory.Create(vGuestGroupType);  
			vFolioGuestGroup.Code 						=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ГруппаГостей),mRow.ЛицевойСчет.ГруппаГостей.Code,"");
			vFolioGuestGroup.Description 				=  mRow.ЛицевойСчет.ГруппаГостей.Description;
			vFolioGuestGroup.ExternalCode 				=  mRow.ЛицевойСчет.ГруппаГостей.ExternalCode;
			vFolio.ГруппаГостей							=  vFolioGuestGroup;
			vFolio.ДокОснование 							=  vParentDoc;
			
			vSetServiceItemRow.Контрагент		=  vAccountingCustomer;
			vSetServiceItemRow.Договор		=  vAccountingContract;
			vSetServiceItemRow.ГруппаГостей				=  vGuestGroup;
			vSetServiceItemRow.СчетПроживания					=  vFolio;
			vSetServiceItemRow.RecorderNumber			=  mRow.RecorderNumber;
			vSetServiceItemRow.Period					=  mRow.Period;
			vSetServiceItemRow.ВалютаРасчетов   	=  vAccountingCurrency;
			vSetServiceItemRow.Фирма					=  vCompany;
			vSetServiceItemRow.Сумма						=  mRow.Sum;
			vSetServiceItemRow.Цена					=  mRow.Price;
			vSetServiceItemRow.Количество					=  mRow.Quantity;
			vSetServiceItemRow.СтавкаНДС					=  vVATRate;
			vSetServiceItemRow.Клиент					=  vClient;
			vSetServiceItemRow.Услуги					=  vServices;
			vSetServiceItemRow.НомерРазмещения						=  vRoom;
			vSetServiceItemRow.ExternalCode				=  mRow.ExternalCode;
			vSetServiceItemRow.IsAgentService			=  mRow.Service.IsAgentService;

			vRetXDTO.SettlementServicesTable.SettlementServicesTableRow.Add(vSetServiceItemRow);
		EndDo;
		Возврат vRetXDTO;
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
		
	EndTry;
	
КонецФункции  //cmGetSettlementTable

//-----------------------------------------------------------------------------
Функция cmWriteSettlementExtCode(pNumber, pExternalCode, pPeriodFrom, pPeriodTo) Экспорт
	WriteLogEvent(NStr("en='WriteSettlementExtCode'; ru='Сохранение внешнего кода документа'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo
	+Chars.LF+NStr("en='Number: '; ru='Number: '")+pNumber+Chars.LF+NStr("en='ExternalCode: '; ru='ExternalCode: '")+pExternalCode);
	

	Попытка
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	БухРеализацияУслуг.Recorder AS Recorder
		|FROM
		|	AccumulationRegister.БухРеализацияУслуг AS БухРеализацияУслуг
		|WHERE
		|	БухРеализацияУслуг.Period >= &qDateFrom
		|	AND БухРеализацияУслуг.Period <= &qDateTo
		|	AND БухРеализацияУслуг.Recorder.НомерДока = &qDocNumber
		|
		|ORDER BY
		|	БухРеализацияУслуг.PointInTime";
		vQry.УстановитьПараметр("qDateFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qDateTo", pPeriodTo);
		vQry.УстановитьПараметр("qDocNumber", pNumber);
		
		vTrans = vQry.Execute().Unload();
		Если vTrans.Count()>0 Тогда
			vDoc = vTrans[0].Recorder.GetObject();
			vDoc.ExternalCode = pExternalCode;
			vDoc.write();
		КонецЕсли;	
		Возврат "";
	Исключение
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write document'; ru='Ошибка записи документа'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	КонецПопытки;
	
КонецФункции  //cmWriteSettlementExtCode

//-----------------------------------------------------------------------------
Функция cmWriteCashRegisterExtCode(pNumber, pExternalCode, pPeriodFrom, pPeriodTo) Экспорт
	WriteLogEvent(NStr("en='WriteCashRegisterExtCode'; ru='Сохранение внешнего кода документа'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo
	+Chars.LF+NStr("en='Number: '; ru='Number: '")+pNumber+Chars.LF+NStr("en='ExternalCode: '; ru='ExternalCode: '")+pExternalCode);
	
	Try
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	ЗакрытиеКассовойСмены.Ref
		|FROM
		|	Document.ЗакрытиеКассовойСмены AS ЗакрытиеКассовойСмены
		|WHERE
		|	ЗакрытиеКассовойСмены.ДатаДок >= &qDateFrom
		|	AND ЗакрытиеКассовойСмены.ДатаДок <= &qDateTo
		|	AND ЗакрытиеКассовойСмены.НомерДока = &qDocNumber
		|
		|ORDER BY
		|	ЗакрытиеКассовойСмены.PointInTime";
		vQry.УстановитьПараметр("qDateFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qDateTo", pPeriodTo);
		vQry.УстановитьПараметр("qDocNumber", pNumber);
		
		vTrans = vQry.Execute().Unload();
		Если vTrans.Count()>0 Тогда
			vDoc = vTrans[0].Ref.GetObject();
			vDoc.ExternalCode = pExternalCode;
			vDoc.write();
		КонецЕсли;	
		Возврат "";
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write document'; ru='Ошибка записи документа'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	EndTry;
	
КонецФункции  //cmWriteCashRegisterExtCode

//-----------------------------------------------------------------------------
Функция cmWriteCustomerExtCode(pCode,pExternalCode) Экспорт
	Try
		vCustomer = Справочники.Контрагенты.FindByCode(pCode).GetObject();
		vCustomer.ExternalCode = pExternalCode;
		vCustomer.Write();
		Возврат "";
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write'; ru='Ошибка записи'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	EndTry;
КонецФункции   //cmWriteCustomerExtCode

//-----------------------------------------------------------------------------
Функция cmWriteCompanyExtCode(pCode,pExternalCode) Экспорт
	Try
		vCompany = Справочники.Companies.FindByCode(pCode).GetObject();
		vCompany.ExternalCode = pExternalCode;
		vCompany.Write();
		Возврат "";
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write'; ru='Ошибка записи'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	EndTry;
КонецФункции  //cmWriteCompanyExtCode

//-----------------------------------------------------------------------------
Функция cmWriteServicesExtCode(pCode,pExternalCode) Экспорт
	Try
		vService = Справочники.Услуги.FindByCode(pCode).GetObject();
		vService.ExternalCode = pExternalCode;
		vService.Write();
		Возврат "";
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write'; ru='Ошибка записи'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	EndTry;
КонецФункции  //cmWriteServicesExtCode

//-----------------------------------------------------------------------------
Функция cmWriteInvoiceExtCode(pNumber, pExternalCode, pPeriodFrom, pPeriodTo) Экспорт 
	WriteLogEvent(NStr("en='WriteInvoiceExtCode'; ru='Сохранение внешнего кода документа'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo
	+Chars.LF+NStr("en='Number: '; ru='Number: '")+pNumber+Chars.LF+NStr("en='ExternalCode: '; ru='ExternalCode: '")+pExternalCode);
	Try
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	СчетНаОплату.Ref
		|FROM
		|	Document.СчетНаОплату AS СчетНаОплату
		|WHERE
		|	СчетНаОплату.ChangeDate >= &qPeriodFrom
		|	AND СчетНаОплату.ChangeDate <= &qPeriodTo
		|	AND СчетНаОплату.НомерДока = &Number";
		vQry.УстановитьПараметр("qPeriodFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qPeriodTo", pPeriodTo);
		vQry.УстановитьПараметр("Number", pNumber);
		
		vTrans = vQry.Execute().Unload();
		Если vTrans.Count()>0 Тогда
			WriteLogEvent(NStr("en='Error write document'; ru='Ошибка записи документа'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='документ найден: '"));

			vDoc = vTrans[0].Ref.GetObject();
			vDoc.ExternalCode = pExternalCode;
			vDoc.write();
		КонецЕсли;	
		Возврат "";
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write document'; ru='Ошибка записи документа'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	EndTry;
	
КонецФункции	 //cmWriteInvoiceExtCode

//-----------------------------------------------------------------------------
Процедура cmWriteInvoicePayment(pHotelCode = Неопределено, pCompanyCode = Неопределено, pPaymentExternalCode, pPaymentDate, pPaymentNumber, pCustomer, pIsPosted, pIsMarkedDeleted, pPaymentDetails, pRemarks, pExtSystemCode = Неопределено,pAccountingCurrencyCode) Экспорт
	
	WriteLogEvent(NStr("en = 'AccountingInterfaces.WriteInvoicePayment'; ru = 'ОбменСБухгалтерией.ЗаписатьПлатежПоСчету'; de = 'AccountingInterfaces.WriteInvoicePayment'"), EventLogLevel.Information, , , 
	"Код отеля: " +TrimR(pHotelCode) + ", " +Chars.LF+"Код Фирмы: " + TrimR(pCompanyCode) + ", " +Chars.LF+"Гуид платежа: "+ pPaymentExternalCode + ", " 
	+Chars.LF+"Дата платежа: "+ TrimR(pPaymentDate) + ", " +Chars.LF+"НомерРазмещения документа: "+ TrimR(pPaymentNumber) + ", "+Chars.LF+"Проведен: " + TrimR(pIsPosted) + ", " +Chars.LF+"Помечен на удаление: "+ pIsMarkedDeleted + ", " 
	+Chars.LF+"Примечание: "+ pRemarks + ", " +Chars.LF+"Код во внешней системе: "+ TrimR(pExtSystemCode)+Chars.LF+"Код валюты: "+ TrimR(pAccountingCurrencyCode));
	Try
		// Initialize error description
		//vErrorDescription = "";
		// Try to find hotel by name or code
		vHotel = cmGetHotelByCode(pHotelCode, pExtSystemCode);
		vCompany = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "Companies", pCompanyCode);
		// Try to find Фирма
		vCompany = Справочники.Companies.EmptyRef();
		Если НЕ IsBlankString(pCompanyCode) Тогда
			vCompany = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "Companies", pCompanyCode);
		КонецЕсли;
		Если vCompany = Справочники.Companies.EmptyRef() Тогда
			vCompany = vHotel.Фирма;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(vHotel) Тогда
			
			Если vHotel.UseGuestGroupFolios Тогда
				//1. Если используется режим "Счет на группу", то делаем "Платеж". Для этого определяем фолио.
				//Идем по ТЧ счетов - для каждого счета определяем фолио по которому он должен провести платеж.
				// а) если счет на основании фолио - то берем его.
				// б) Если счет на основании брони ресурсов - то берем фолио из брони
				// в) если счет на основании брони или размещения - то берем фолио из Правил начисления брони - первое или то на котрое ложится проживание.
				// г) если счет по группе - то берем фолио из правил начисления группы
				//    если в группе нет правил начисления, то создаем эти правила и на него вешаем платеж?
				//    или ищем фолио из документов группы.
				//    или ничего не делаем
			Иначе
				//2. если режим выключен, то используем "Платеж контрагента".
				// в ТЧ счетов заполняем счета по списку расшифровки платежа
				// в ТЧ групп заполняем группы по списку счетов.
				// проводим.
				//Попробуем найти документ по гуиду
				vDok = Documents.ПлатежКонтрагента.FindByAttribute("ExternalCode",pPaymentExternalCode);
				
				//Если не нашли, тогда будем создавать
				Если vDok = Documents.ПлатежКонтрагента.EmptyRef() Тогда
					
					vDok = Documents.ПлатежКонтрагента.CreateDocument();
				Иначе
					WriteLogEvent(NStr("en = 'AccountingInterfaces.WriteInvoicePayment'; ru = 'ОбменСБухгалтерией.ЗаписатьПлатежПоСчету'; de = 'AccountingInterfaces.WriteInvoicePayment'"), EventLogLevel.Information, 
					,vDok, NStr("en='Find Payment by ExternalCode: '; ru='Документ платеж найден по коду во внешней системе: '; de='Find Payment by ExternalCode: '") +pPaymentExternalCode);
					
					vDok = vDok.GetObject();
					
					//ставим галки согласно источнику
					vDok.DeletionMark 				= pIsMarkedDeleted;
					vDok.Posted	      				= pIsPosted;
				КонецЕсли; 
				
				//Перезаполним все реквизиты платежа, может кто нибудь поменял реквизиты
				vDok.Гостиница          				= vHotel;
				vDok.Фирма						= vCompany;
				vDok.ДатаДок 							= pPaymentDate;
				vDok.ExchangeRateDate				= pPaymentDate;
				
				vDok.Контрагент				= cmFindCustomers(pCustomer);
				vDok.Примечания						= pRemarks;
				
				qPaymentCurrency 					= Справочники.Валюты.FindByCode(СокрЛП(pAccountingCurrencyCode));
				
				vDok.СпособОплаты					= vHotel.PaymentMethodForCustomerPayments;
				vDok.PaymentDocNumber				= pPaymentNumber;
				vDok.PaymentCurrency				= qPaymentCurrency;
				vDok.ВалютаРасчетов  			= ?(ЗначениеЗаполнено(vDok.Контрагент.ВалютаРасчетов),vDok.Контрагент.ВалютаРасчетов,qPaymentCurrency);
				vDok.PaymentCurrencyExchangeRate  	= cmGetCurrencyExchangeRate(vHotel,qPaymentCurrency,pPaymentDate);
				vDok.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vHotel,vDok.ВалютаРасчетов,pPaymentDate);
				vDok.ExternalCode					= pPaymentExternalCode;
				
				vDok.Договора.Clear();
				vDok.Invoices.Clear();
				
				//1. fill Contracts table
				//For Each Str In pPaymentDetails Do
				//	
				//EndDo;
				
				//2. fill Invoices table
				For Each Str In pPaymentDetails.PaymentDetailsRow Do
					vInvoce = Documents.СчетНаОплату.FindByAttribute("ExternalCode",Str.ExternalCode);
					Если vInvoce = Documents.СчетНаОплату.EmptyRef() Тогда
						//счет не наш, загружать не нужно
						Continue;
					КонецЕсли;	
					
					WriteLogEvent(NStr("en = 'AccountingInterfaces.WriteInvoicePayment'; ru = 'ОбменСБухгалтерией.ЗаписатьПлатежПоСчету'; de = 'AccountingInterfaces.WriteInvoicePayment'"), EventLogLevel.Information, 
					,vInvoce, NStr("en='Find Invoice: '; ru='Счет найден: '; de='Find Invoice: '") +vInvoce.НомерДока);

					strInv = vDok.Invoices.Add();
					strInv.СчетНаОплату  						=  vInvoce;
					strInv.Сумма 								=  Str.Сумма;
					strInv.SumInAccountingCurrency			=  Str.Сумма;
					strInv.ВалютаРасчетов      			=  qPaymentCurrency;
					strInv.AccountingCurrencyExchangeRate	=  vDok.AccountingCurrencyExchangeRate;
					vDok.pmCalculateCustomerAccountsMapForInvoice(strInv);
				EndDo;

				Если vDok.Invoices.Count() = 0 And vDok.Договора.Count() = 0 Тогда
					//Sum = Round(cmConvertCurrencies(vDok.SumInAccountingCurrency, vDok.ВалютаРасчетов, vDok.AccountingCurrencyExchangeRate, vDok.PaymentCurrency, vDok.PaymentCurrencyExchangeRate, vDok.ExchangeRateDate, vDok.Гостиница), 2);
				КонецЕсли;
				
				// Recalculate invoices
				For Each vRow In vDok.Invoices Do
					vRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vDok.Гостиница, vRow.ВалютаРасчетов, vDok.ExchangeRateDate);
					vRow.Сумма = Round(cmConvertCurrencies(vRow.SumInAccountingCurrency, vRow.ВалютаРасчетов, vRow.AccountingCurrencyExchangeRate, vDok.PaymentCurrency, vDok.PaymentCurrencyExchangeRate, vDok.ExchangeRateDate, vDok.Гостиница), 2);
					vRow.Balance = vRow.СчетНаОплату.Сумма; 
				EndDo;
				
				// Recalculate contracts
				For Each vRow In vDok.Договора Do
					vRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vDok.Гостиница, vRow.ВалютаРасчетов, vDok.ExchangeRateDate);
					vRow.Сумма = Round(cmConvertCurrencies(vRow.SumInAccountingCurrency, vRow.ВалютаРасчетов, vRow.AccountingCurrencyExchangeRate, vDok.PaymentCurrency, vDok.PaymentCurrencyExchangeRate, vDok.ExchangeRateDate, vDok.Гостиница), 2);
					vRow.Balance =  vRow.Сумма;
				EndDo;
				
				// Recalculate totals
				vDok.pmCalculateSums();
				
				Если vDok.Invoices.Count() > 0  Тогда
					vDok.Write();
					WriteLogEvent(NStr("en = 'AccountingInterfaces.WriteInvoicePayment'; ru = 'ОбменСБухгалтерией.ЗаписатьПлатежПоСчету'; de = 'AccountingInterfaces.WriteInvoicePayment'"), EventLogLevel.Information, 
					,vDok.ref, NStr("en='Document write: '; ru='Документ записан: '; de='Document write: '") +vDok.ref.НомерДока);
					
					vDok.Write(DocumentWriteMode.Posting);
				КонецЕсли;
				
				WriteLogEvent(NStr("en = 'AccountingInterfaces.WriteInvoicePayment'; ru = 'ОбменСБухгалтерией.ЗаписатьПлатежПоСчету'; de = 'AccountingInterfaces.WriteInvoicePayment'"), EventLogLevel.Information, 
				, , NStr("en='Document posting: '; ru='Документ проведен: '; de='Document posting: '") +vDok.НомерДока);

			КонецЕсли;
		Иначе 
			WriteLogEvent(NStr("en = 'AccountingInterfaces.WriteInvoicePayment'; ru = 'ОбменСБухгалтерией.ЗаписатьПлатежПоСчету'; de = 'AccountingInterfaces.WriteInvoicePayment'"), EventLogLevel.Error, 
				, , NStr("en='Гостиница is not find!!!'; ru='Гостиница не найдена, платеж не загружен!'; de='Гостиница is not find'"));

		КонецЕсли;
		
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en = 'AccountingInterfaces.WriteInvoicePayment'; ru = 'ОбменСБухгалтерией.ЗаписатьПлатежПоСчету'; de = 'AccountingInterfaces.WriteInvoicePayment'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '; de='Runtime Error: '") +vError);
	EndTry;
КонецПроцедуры  //cmWriteInvoicePayment

//-----------------------------------------------------------------------------
Функция cmWritePaymentSectionsExtCode(pCode, pExternalCode) Экспорт
	Try
		vService = Справочники.ОтделОплаты.FindByCode(pCode).GetObject();
		vService.ExternalCode = pExternalCode;
		vService.Write();
		Возврат "";
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write'; ru='Ошибка записи'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	EndTry;
КонецФункции  //cmWritePaymentSectionsExtCode

//-----------------------------------------------------------------------------
Функция cmWritePaymentMethodsExtCode(pCode, pExternalCode) Экспорт
	Try
		vService = Справочники.СпособОплаты.FindByCode(pCode).GetObject();
		vService.ExternalCode = pExternalCode;
		vService.Write();
		Возврат "";
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Error write'; ru='Ошибка записи'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		
		Возврат vError;
	EndTry;
КонецФункции  //cmWritePaymentSectionsExtCode

//-----------------------------------------------------------------------------
Функция cmGetCloseOfCashRegisterDay(pPeriodFrom, pPeriodTo) Экспорт
	WriteLogEvent(NStr("en='GetCloseOfCashRegisterDay'; ru='Получение списка смен, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo);
	
	vCashRegisterDayType 			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CashRegisterDay");
	vCashRegisterDayItemType		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CashRegisterDayItem");
	vCashRegisterDayListType 		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CashRegisterDayList");
	vCashRegisterType	        	= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "Касса");
	
	vRetXDTO 						= XDTOFactory.Create(vCashRegisterDayListType);
	vRetXDTO.CashRegisterDay		= XDTOFactory.Create(vCashRegisterDayType);
	vRetXDTO.ErrorDescription 	= "";
	
	Try
		vQry = New Query;
		vQry.Text = 
		"SELECT *
		|FROM
		|	Document.ЗакрытиеКассовойСмены AS ЗакрытиеКассовойСмены
		|WHERE
		|	ЗакрытиеКассовойСмены.ДатаДок >= &qDateFrom
		|	AND ЗакрытиеКассовойСмены.ДатаДок <= &qDateTo
		|
		|ORDER BY
		|	ЗакрытиеКассовойСмены.ДатаДок";	
		
		vQry.УстановитьПараметр("qDateFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qDateTo", pPeriodTo);
		
		vTrans = vQry.Execute().Unload();
		
		For Each mRow In vTrans Do
			vCashRegisterDay 	= XDTOFactory.Create(vCashRegisterDayItemType); 
			vCashRegister       = XDTOFactory.Create(vCashRegisterType);
			
			FillPropertyValues(vCashRegister,mRow.CashRegister);
			FillPropertyValues(vCashRegisterDay,mRow,,"Касса");
			
			vCashRegisterDay.Касса 		=  vCashRegister;
			
			vRetXDTO.CashRegisterDay.CashRegisterDayItem.Add(vCashRegisterDay);
		EndDo;
		
		Возврат vRetXDTO;
		
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
		
	EndTry;
	
	
КонецФункции   //cmGetCloseOfCashRegisterDay

//-----------------------------------------------------------------------------
Функция cmGetPaymentList(pPeriodFrom, pPeriodTo, pDocNumber,pCashRegisterCode) Экспорт
	WriteLogEvent(NStr("en='CashRegisterDailyReceipts'; ru='Получение данных по кассе, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo
	+Chars.LF+NStr("en='Doc Number: '; ru='Номер смены: '")+pDocNumber
	+Chars.LF+NStr("en='Code KKM: '; ru='Код ККМ: '")+pCashRegisterCode);
	
	vPaymentTableType 				= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "PaymentTable");
	vPaymentRowType					= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "PaymentRow");
	vPaymentListType 				= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "PaymentList");
	vAccountingCustomerType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CustomersItemRow");
	vAccountingContractType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "Договор");
	vCompanyType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "CompanyItemRow");
	vGuestGroupType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ГруппаГостей");
	vAccountingCurrencyType	        = XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ВалютаРасчетов");
	vClientType	        			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "Клиент");
	vCashRegisterType	        	= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "Касса");
	vPaymentMethodType	        	= XDTOFactory.Type("http://www.1chot7el.ru/interfaces/accounting/", "СпособОплаты");
	vPaymentSectionType	        	= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "PaymentSectionsRow");
	vFolioType	        			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "СчетПроживания");
	vVATRateType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "СтавкаНДС");
	vParentDocType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ДокОснование");
	vPaymentRowType	        		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "PaymentRow");
	
	vRetXDTO 						= XDTOFactory.Create(vPaymentListType);
	vRetXDTO.PaymentTable			= XDTOFactory.Create(vPaymentTableType);
	vRetXDTO.ErrorDescription 	= "";
	
	Try
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	ВыручкаПоСменам.Period,
		|	ВыручкаПоСменам.Recorder,
		|	ВыручкаПоСменам.LineNumber,
		|	ВыручкаПоСменам.Active,
		|	ВыручкаПоСменам.RecordType,
		|	ВыручкаПоСменам.Фирма,
		|	ВыручкаПоСменам.Касса,
		|	ВыручкаПоСменам.Валюта,
		|	ВыручкаПоСменам.PaymentSection,
		|	ВыручкаПоСменам.СпособОплаты,
		|	ВыручкаПоСменам.Контрагент,
		|	ВыручкаПоСменам.Договор,
		|	ВыручкаПоСменам.ГруппаГостей,
		|	ВыручкаПоСменам.Платеж,
		|	ВыручкаПоСменам.Сумма,
		|	ВыручкаПоСменам.СуммаНДС,
		|	ВыручкаПоСменам.PaymentSum,
		|	ВыручкаПоСменам.VATPaymentSum,
		|	ВыручкаПоСменам.ReturnSum,
		|	ВыручкаПоСменам.VATReturnSum,
		|	ВыручкаПоСменам.Payer,
		|	ВыручкаПоСменам.СчетПроживания,
		|	ВыручкаПоСменам.Recorder.СтавкаНДС AS СтавкаНДС
		|FROM
		|	AccumulationRegister.ВыручкаПоСменам AS ВыручкаПоСменам
		|WHERE
		|	ВыручкаПоСменам.RecordType = VALUE(AccumulationRecordType.Receipt)
		|	AND ВыручкаПоСменам.Period >= &qDateFrom
		|	AND ВыручкаПоСменам.Period <= &qDateTo
		|	AND ВыручкаПоСменам.Касса.Code = &qCashRegisterCode
		|
		|ORDER BY
		|	ВыручкаПоСменам.PointInTime";	
		vQry.УстановитьПараметр("qDateFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qDateTo",pPeriodTo);
		vQry.УстановитьПараметр("qCashRegisterCode", pDocNumber);
		vTrans = vQry.Execute().Unload();
		
		For Each mRow In vTrans Do
			vPaymentRow  		= XDTOFactory.Create(vPaymentRowType);
			vAccountingCustomer = XDTOFactory.Create(vAccountingCustomerType);
			vAccountingContract = XDTOFactory.Create(vAccountingContractType); 
			vCompany			= XDTOFactory.Create(vCompanyType);
			vGuestGroup			= XDTOFactory.Create(vGuestGroupType);
			vAccountingCurrency	= XDTOFactory.Create(vAccountingCurrencyType);
			vClient				= XDTOFactory.Create(vClientType);
			vFolio				= XDTOFactory.Create(vFolioType);
			vParentDoc			= XDTOFactory.Create(vParentDocType);
			vVATRate			= XDTOFactory.Create(vVATRateType);
			vCashRegister       = XDTOFactory.Create(vCashRegisterType);
			vPaymentMethod      = XDTOFactory.Create(vPaymentMethodType);
			vPaymentSection     = XDTOFactory.Create(vPaymentSectionType);
			
			vAccountingCustomer.Code 					=  ?(ЗначениеЗаполнено(mRow.Customer),mRow.Контрагент.Code,"");
			vAccountingCustomer.Description 			=  mRow.Контрагент.Description;
			vAccountingCustomer.ExternalCode 			=  mRow.Контрагент.ExternalCode;
			vAccountingCustomer.ИНН 					=  mRow.Контрагент.ИНН;
			
			vAccountingContract.Code 					=  ?(ЗначениеЗаполнено(mRow.Contract),mRow.Contract.Code,"");
			vAccountingContract.Description 			=  mRow.Contract.Description;
			vAccountingContract.ExternalCode 			=  mRow.Contract.ExternalCode;
			
			vCompany.Code 								=  ?(ЗначениеЗаполнено(mRow.Company),mRow.Фирма.Code,"");
			vCompany.Description 						=  mRow.Фирма.Description;
			vCompany.ExternalCode 						=  mRow.Фирма.ExternalCode;
			
			vGuestGroup.Code 							=  ?(ЗначениеЗаполнено(mRow.GuestGroup),mRow.GuestGroup.Code,"");
			vGuestGroup.Description 					=  mRow.GuestGroup.Description;
			vGuestGroup.ExternalCode 					=  mRow.GuestGroup.ExternalCode;
			
			vAccountingCurrency.Code 					=  ?(ЗначениеЗаполнено(mRow.Currency),mRow.Currency.Code,"");
			vAccountingCurrency.Description 			=  mRow.Currency.Description;
			
			vClient.Code 								=  ?(ЗначениеЗаполнено(mRow.Payer),mRow.Payer.Code,"");
			vClient.Description 						=  ?(ЗначениеЗаполнено(mRow.Payer),mRow.Payer.Description,"");
			
			vCashRegister.Code 							=  ?(ЗначениеЗаполнено(mRow.CashRegister),mRow.CashRegister.Code,"");
			vCashRegister.Description 					=  mRow.CashRegister.Description;
			
			vPaymentMethod.Code 						=  ?(ЗначениеЗаполнено(mRow.PaymentMethod),mRow.PaymentMethod.Code,"");
			vPaymentMethod.Description 					=  mRow.PaymentMethod.Description;
			vPaymentMethod.IsByCreditCard 				=  mRow.PaymentMethod.IsByCreditCard;
			vPaymentMethod.ExternalCode 				=  mRow.PaymentMethod.ExternalCode;
			
			vPaymentSection.Code 						=  ?(ЗначениеЗаполнено(mRow.PaymentSection),mRow.PaymentSection.Code,"");
			vPaymentSection.Description 				=  mRow.PaymentSection.Description;
			vPaymentSection.ExternalCode 				=  mRow.PaymentSection.ExternalCode;

			vFolio.DateTimeFrom 						=  mRow.ЛицевойСчет.DateTimeFrom;
			vFolio.DateTimeTo 							=  mRow.ЛицевойСчет.DateTimeTo;
			vFolio.НомерДока 								=  mRow.ЛицевойСчет.НомерДока;
			vFolio.Description 							=  mRow.ЛицевойСчет.Description;

			vVATRate.Ставка                            =  mRow.VATRate.Ставка;
			vVATRate.Description                        =  mRow.VATRate.Description;

			vParentDoc.HasOfficialLetter            	=  False;
			
			Если  ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование) Тогда
				vParentDoc.HasOfficialLetter            =  ?(mRow.ЛицевойСчет.ДокОснование.Metadata().Attributes.Find("HasOfficialLetter")<>Неопределено,mRow.ЛицевойСчет.ДокОснование.HasOfficialLetter,False);
				vGuest									=  XDTOFactory.Create(vClientType);
				
				Если mRow.ЛицевойСчет.ДокОснование.Metadata().Attributes.Find("Клиент")<>Неопределено  Тогда
					vGuest.Code 							=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Code,"");
					vGuest.Description 						=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Description,"");
				ИначеЕсли mRow.ЛицевойСчет.ДокОснование.Metadata().Attributes.Find("Клиент")<>Неопределено  Тогда
					vGuest.Code 						=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Code,"");
					vGuest.Description 					=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ДокОснование.Клиент),mRow.ЛицевойСчет.ДокОснование.Клиент.Description,"");
				Иначе
					vGuest.Code 						=  "";
					vGuest.Description 					=  "";
				КонецЕсли;
				vParentDoc.Клиент            			=  vGuest;
			КонецЕсли;	
			vFolioGuestGroup                       		=  XDTOFactory.Create(vGuestGroupType);  
			vFolioGuestGroup.Code 						=  ?(ЗначениеЗаполнено(mRow.ЛицевойСчет.ГруппаГостей),mRow.ЛицевойСчет.ГруппаГостей.Code,"");
			vFolioGuestGroup.Description 				=  mRow.ЛицевойСчет.ГруппаГостей.Description;
			vFolioGuestGroup.ExternalCode 				=  mRow.ЛицевойСчет.ГруппаГостей.ExternalCode;
			vFolio.ГруппаГостей							=  vFolioGuestGroup;
			vFolio.ДокОснование 							=  vParentDoc;
			
			vPaymentRow.RecorderNumber					=  mRow.Recorder.НомерДока;
			vPaymentRow.Контрагент				=  vAccountingCustomer;
			vPaymentRow.Договор				=  vAccountingContract;
			vPaymentRow.ГруппаГостей						=  vGuestGroup;
			vPaymentRow.СчетПроживания							=  vFolio;
			vPaymentRow.Period							=  mRow.Period;
			vPaymentRow.ВалютаРасчетов   			=  vAccountingCurrency;
			vPaymentRow.Фирма							=  vCompany;
			vPaymentRow.Сумма								=  mRow.Sum;
			vPaymentRow.СуммаНДС							=  mRow.VATSum;
			vPaymentRow.СтавкаНДС							=  vVATRate;
			vPaymentRow.Клиент							=  vClient;
			vPaymentRow.СпособОплаты					=  vPaymentMethod;
			vPaymentRow.PaymentSection					=  vPaymentSection;
			vPaymentRow.Касса					=  vCashRegister;
			
			vRetXDTO.PaymentTable.PaymentRow.Add(vPaymentRow);
		EndDo;
		Возврат vRetXDTO;
		
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
		
	EndTry;
	
КонецФункции  //cmGetPaymentList

//-----------------------------------------------------------------------------
Функция cmGetPaymentMethods(pPeriodFrom, pPeriodTo) Экспорт
	WriteLogEvent(NStr("en='Payment methods list'; ru='Получение списка методов оплат, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo);
	
	vPaymentMethodsType 			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "СпособОплаты");
	vPaymentMethodRowType 			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "СпособОплаты");
	vPaymentMethodsListType 		= XDTOFactory.Type("http://www.1chot7el.ru/interfaces/accounting/", "PaymentMethodsList");
	
	vRetXDTO 						= XDTOFactory.Create(vPaymentMethodsListType);
	vRetXDTO.СпособОплаты   		= XDTOFactory.Create(vPaymentMethodsType);
	vRetXDTO.ErrorDescription 		= "";
	
	Try
		vQry = new Query;
		vQry.Text = 
		"SELECT
		|	CashRegisterDailyReceiptsTurnovers.СпособОплаты As СпособОплаты
		|FROM
		|	(SELECT
		|		ЗакрытиеКассовойСмены.Ref AS Ref,
		|		ЗакрытиеКассовойСмены.ДатаДок AS Дата,
		|		ЗакрытиеКассовойСмены.ДатаНачКвоты AS ДатаНачКвоты
		|	FROM
		|		Document.ЗакрытиеКассовойСмены AS ЗакрытиеКассовойСмены
		|	WHERE
		|		ЗакрытиеКассовойСмены.ДатаДок <= &qPeriodTo
		|		AND ЗакрытиеКассовойСмены.ДатаНачКвоты >= &qPeriodFrom
		|		AND ЗакрытиеКассовойСмены.DeletionMark = FALSE) AS UsedServices
		|		LEFT JOIN AccumulationRegister.ВыручкаПоСменам.Turnovers(, , Record, ) AS CashRegisterDailyReceiptsTurnovers
		|		ON (CashRegisterDailyReceiptsTurnovers.Period >= UsedServices.ДатаНачКвоты)
		|			AND (CashRegisterDailyReceiptsTurnovers.Period <= UsedServices.ДатаДок)
		|WHERE
		|	CashRegisterDailyReceiptsTurnovers.СпособОплаты.Code IS NOT NULL 
		|
		|GROUP BY
		|	CashRegisterDailyReceiptsTurnovers.СпособОплаты";
		
		vQry.УстановитьПараметр("qPeriodFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qPeriodTo", pPeriodTo);
		vTrans = vQry.Execute().Unload();
		
		For Each mRow In vTrans Do
			vPaymentMethodRow = XDTOFactory.Create(vPaymentMethodRowType);
			
			FillPropertyValues(vPaymentMethodRow, mRow.PaymentMethod);
			
			vRetXDTO.СпособОплаты.СпособОплаты.Add(vPaymentMethodRow);
		EndDo;
		
		Возврат vRetXDTO;	
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
	EndTry;
	
КонецФункции	//cmGetPaymentMethods

//-----------------------------------------------------------------------------
Функция cmGetPaymentSections(pPeriodFrom, pPeriodTo) Экспорт
	WriteLogEvent(NStr("en='Payment sections list'; ru='Получение списка секций, входящие параметры'"), EventLogLevel.Information, 
	, , NStr("en='Дата from: '; ru='Дата начала: '") + pPeriodFrom+Chars.LF+NStr("en='Дата to: '; ru='Дата окончания: '")+pPeriodTo);
	
	vPaymentSectionsType 			= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "ОтделОплаты");
	vPaymentSectionsRowType 		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "PaymentSectionsRow");
	vPaymentSectionsListType 		= XDTOFactory.Type("http://www.1chote7l.ru/interfaces/accounting/", "PaymentSectionsList");
	
	vRetXDTO 						= XDTOFactory.Create(vPaymentSectionsListType);
	vRetXDTO.ОтделОплаты   		= XDTOFactory.Create(vPaymentSectionsType);
	vRetXDTO.ErrorDescription 		= "";
	
	Try
		vQry = new Query;
		vQry.Text = "SELECT
		|	CashRegisterDailyReceiptsTurnovers.PaymentSection.Code AS Code,
		|	CashRegisterDailyReceiptsTurnovers.PaymentSection.Description AS Description,
		|	CashRegisterDailyReceiptsTurnovers.PaymentSection.ExternalCode AS ExternalCode
		|FROM
		|	(SELECT
		|		ЗакрытиеКассовойСмены.Ref AS Ref,
		|		ЗакрытиеКассовойСмены.ДатаДок AS Дата,
		|		ЗакрытиеКассовойСмены.ДатаНачКвоты AS ДатаНачКвоты
		|	FROM
		|		Document.ЗакрытиеКассовойСмены AS ЗакрытиеКассовойСмены
		|	WHERE
		|		ЗакрытиеКассовойСмены.ДатаДок <= &qPeriodTo
		|		AND ЗакрытиеКассовойСмены.ДатаНачКвоты >= &qPeriodFrom
		|		AND ЗакрытиеКассовойСмены.DeletionMark = FALSE) AS UsedServices
		|		LEFT JOIN AccumulationRegister.ВыручкаПоСменам.Turnovers(, , Record, ) AS CashRegisterDailyReceiptsTurnovers
		|		ON (CashRegisterDailyReceiptsTurnovers.Period >= UsedServices.ДатаНачКвоты)
		|			AND (CashRegisterDailyReceiptsTurnovers.Period <= UsedServices.ДатаДок)
		|WHERE
		|	CashRegisterDailyReceiptsTurnovers.PaymentSection.Code IS NOT NULL 
		|
		|GROUP BY
		|	CashRegisterDailyReceiptsTurnovers.PaymentSection.Description,
		|	CashRegisterDailyReceiptsTurnovers.PaymentSection.ExternalCode,
		|	CashRegisterDailyReceiptsTurnovers.PaymentSection.Code
		|
		|ORDER BY
		|	Code";
		
		vQry.УстановитьПараметр("qPeriodFrom", pPeriodFrom);
		vQry.УстановитьПараметр("qPeriodTo", pPeriodTo);
		vTrans = vQry.Execute().Unload();
		
		WriteLogEvent(NStr("en='Get services list'; ru='Получение списка услуг'"), EventLogLevel.Information, 
		, , NStr("en='Services count: '; ru='Количество полученных услуг: '") +vTrans.Count());
		
		
		For Each mRow In vTrans Do
			vPaymentSectionsItemRow = XDTOFactory.Create(vPaymentSectionsRowType);
			
			FillPropertyValues(vPaymentSectionsItemRow,mRow);
			
			vRetXDTO.ОтделОплаты.PaymentSectionsRow.Add(vPaymentSectionsItemRow);
		EndDo;
		
		Возврат vRetXDTO;	
	Except
		vError = ErrorDescription();
		WriteLogEvent(NStr("en='Runtime Error'; ru='Ошибка получения данных'"), EventLogLevel.Error, 
		, , NStr("en='Runtime Error: '; ru='Ошибка выполнения: '") +vError);
		vRetXDTO.ErrorDescription = vError;
		Возврат  vRetXDTO;
	EndTry;
	
КонецФункции  //cmGetPaymentSections

//-----------------------------------------------------------------------------
// Description: Pay by certificate.
//              Функция could be called as web-service or thru COM connection
// Parameters: Certificate number,  Amount , Charge remarks, Charge details, External system code, Currency code, VatRate
// Возврат value: Empty string if charge was done successfully or error description
//-----------------------------------------------------------------------------
Функция cmPayByCertificate(pCertificateNumber, pSum, pRemarks="", pDetails="", pExternalSystemCode="",pHotelCode="", pCurrency="", pVatRate=Неопределено) Экспорт 
	WriteLogEvent("Оплата сертификатом", EventLogLevel.Information, , , 
    "Код внешней системы: " + pExternalSystemCode + Chars.LF + "Гостиница: " + pHotelCode + Chars.LF + "НДС: " + pVatRate + Chars.LF + 
	"НомерРазмещения сертификата: " + pCertificateNumber + Chars.LF + "Сумма: " + pSum + Chars.LF + 
	"Валюта:" + pCurrency + Chars.LF + "Описание: " + pRemarks + Chars.LF + "Детали:" + pDetails);
	Try
		// Get hotel
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
		Если НЕ IsBlankString(pHotelCode) Тогда
			vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
		КонецЕсли;
		// Get currency by code
		vCurrency = Справочники.Валюты.EmptyRef();
		Если НЕ IsBlankString(pCurrency) Тогда
			vCurrency = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Валюты", pCurrency);
		КонецЕсли;
		
		//1. CREATE FOLIO
		FolioObj = Documents.СчетПроживания.CreateDocument();
		//FolioObj.pmFillAttributesWithDefaultValues();
		FolioObj.ДатаДок = CurrentDate();
		FolioObj.DateTimeFrom = BegOfDay(CurrentDate());
		FolioObj.DateTimeTo = EndOfDay(CurrentDate());
		FolioObj.Description = NStr("en='Сharge from Traktir';ru='Начисление из Трактира';de='Laden aus Traktir'");
		FolioObj.Write();
		
		vFolio =  FolioObj.Ref;
		
		//2.CHARGE SERVICE BY FOLIO
		vError =  cmChargeExternalServiceByFolio(vFolio.НомерДока, "", pSum, 1, pRemarks, pDetails, pHotelCode, pExternalSystemCode, pCurrency, pVATRate);
		Если НЕ vError="" Тогда
			Возврат vError;
		КонецЕсли;	
		
		vQr = New Query("SELECT
		|	СпособОплаты.Ref
		|FROM
		|	Catalog.СпособОплаты AS СпособОплаты
		|WHERE
		|	NOT СпособОплаты.DeletionMark
		|	AND СпособОплаты.IsByGiftCertificate");
		vRes = vQr.Execute().Unload();
		Если vRes.Count()>0 Тогда
			vPaymentMethod = vRes[0].Ref;
		Иначе 
			vPaymentMethod = vHotel.PlannedPaymentMethod;
		КонецЕсли;
		
		//3. CREATE PAYMENT FOR THE FOLIO
		vPaymentObj = Documents.Платеж.CreateDocument();
		vPaymentObj.Fill(vFolio);
		vPaymentObj.PaymentCurrency = vCurrency;
		vPaymentObj.СпособОплаты = vPaymentMethod;
		// Payment sections
		vPaymentSection = "";
		Если ЗначениеЗаполнено(vPaymentObj.Гостиница) And vPaymentObj.Гостиница.SplitFolioBalanceByPaymentSections Тогда
			vPaymentObj.ОтделОплаты.Clear();
			vPSRow = vPaymentObj.ОтделОплаты.Add();
			vPSRow.PaymentSection = vPaymentSection;
			vPSRow.Сумма = pSum;
			vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, 
			vPaymentObj.ВалютаЛицСчета, vPaymentObj.FolioCurrencyExchangeRate, 
			vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
			Если ЗначениеЗаполнено(vPaymentSection) And ЗначениеЗаполнено(vPaymentSection.СтавкаНДС) Тогда
				vPSRow.СтавкаНДС = vPaymentSection.СтавкаНДС;
			Иначе
				vPSRow.СтавкаНДС = vPaymentObj.СтавкаНДС;
			КонецЕсли;
			vPSRow.СуммаНДС = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.Сумма);
			vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, 
			vPaymentObj.ВалютаЛицСчета, vPaymentObj.FolioCurrencyExchangeRate, 
			vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
			vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.SumInFolioCurrency);
			//vPaymentObj.pmCalculateTotalsByPaymentSections();
		Иначе
			//vPaymentObj.PaymentSection = vPaymentSection;
			vPaymentObj.Сумма = pSum;
			Если TypeOf(vPaymentObj) = Type("DocumentObject.Платеж") Тогда
				//vPaymentObj.pmRecalculateSums();
			ИначеЕсли TypeOf(vPaymentObj) = Type("DocumentObject.ПлатежКонтрагента") Тогда
				vPaymentObj.SumInAccountingCurrency = Round(cmConvertCurrencies(vPaymentObj.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, vPaymentObj.ВалютаРасчетов, vPaymentObj.AccountingCurrencyExchangeRate, vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
			КонецЕсли;
		КонецЕсли;
		// Reference and authorization codes
		vPaymentObj.ReferenceNumber = "";
		vPaymentObj.AuthorizationCode = "";
		// Payment remarks
		vPaymentObj.SlipText = "";
		// External system payment code
		vPaymentObj.ExternalCode = TrimR(pExternalSystemCode);
		//Gift Certificate
		vPaymentObj.GiftCertificate = TrimR(pCertificateNumber);
		// Set Контрагент as payer
		Если ЗначениеЗаполнено(vPaymentObj.Контрагент) And ЗначениеЗаполнено(vPaymentObj.СпособОплаты) And vPaymentObj.СпособОплаты.IsByBankTransfer Тогда
			Если ЗначениеЗаполнено(vPaymentObj.Гостиница) And vPaymentObj.Контрагент <> vPaymentObj.Гостиница.IndividualsCustomer Тогда
				vPaymentObj.Payer = vPaymentObj.Контрагент;
			КонецЕсли;
		КонецЕсли;
		// Post payment
		vPaymentObj.Write(DocumentWriteMode.Posting);
		
		//4.Close folio
		FolioObj.IsClosed = True;
		FolioObj.Write();
	Except
				Возврат ErrorDescription();
	EndTry;
	Возврат "";
КонецФункции // cmPayByCertificate()
