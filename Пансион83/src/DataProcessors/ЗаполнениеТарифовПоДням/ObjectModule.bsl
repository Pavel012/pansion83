////-----------------------------------------------------------------------------
//// Data processors framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура pmLoadDataProcessorAttributes(pParameter = Неопределено) Экспорт
//	cmLoadDataProcessorAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadDataProcessorAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmSaveDataProcessorAttributes() Экспорт
//	cmSaveDataProcessorAttributes(ThisObject);
//КонецПроцедуры //pmSaveDataProcessorAttributes
//
////-----------------------------------------------------------------------------
//// Initialize attributes with default values
//// Attention: This procedure could be called AFTER some attributes initialization
//// routine, so it SHOULD NOT reset attributes being set before
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			Тариф = Гостиница.Тариф;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = CurrentDate();
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		PeriodTo = CurrentDate() + 24*3600*30;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//// Run data processor in silent mode
////-----------------------------------------------------------------------------
//Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
//	// Do processing
//	pmDoFill(pIsInteractive);
//КонецПроцедуры //pmRun
//
////-----------------------------------------------------------------------------
//// Data processors framework end
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//
//
////-----------------------------------------------------------------------------
//Function GetListOfActiveCalendarDayTypes(pRoomRate)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	КалендарьДень.ТипДеньКалендарь AS ТипДеньКалендарь
//	|FROM
//	|	InformationRegister.КалендарьДень AS КалендарьДень
//	|WHERE
//	|	КалендарьДень.Calendar = &qCalendar
//	|	AND КалендарьДень.Period >= &qPeriodFrom
//	|	AND КалендарьДень.Period <= &qPeriodTo
//	|
//	|GROUP BY
//	|	КалендарьДень.ТипДеньКалендарь
//	|
//	|ORDER BY
//	|	КалендарьДень.ТипДеньКалендарь.ПорядокСортировки,
//	|	КалендарьДень.ТипДеньКалендарь.Description";
//	vQry.SetParameter("qCalendar", pRoomRate.Calendar);
//	vQry.SetParameter("qPeriodFrom", BegOfDay(PeriodFrom));
//	vQry.SetParameter("qPeriodTo", BegOfDay(PeriodTo));
//	Return vQry.Execute().Unload();
//EndFunction //GetListOfActiveCalendarDayTypes
//
////-----------------------------------------------------------------------------
//Function GetRoomRateCalendarDays(pRoomRate, pCalendarDayType)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	КалендарьДень.Period AS Period,
//	|	КалендарьДень.ТипДеньКалендарь
//	|FROM
//	|	InformationRegister.КалендарьДень AS КалендарьДень
//	|WHERE
//	|	КалендарьДень.Period >= &qPeriodFrom
//	|	AND КалендарьДень.Period <= &qPeriodTo
//	|	AND КалендарьДень.Calendar = &qCalendar
//	|	AND КалендарьДень.ТипДеньКалендарь = &qCalendarDayType
//	|
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qCalendar", pRoomRate.Calendar);
//	vQry.SetParameter("qCalendarDayType", pCalendarDayType);
//	vQry.SetParameter("qPeriodFrom", BegOfDay(PeriodFrom));
//	vQry.SetParameter("qPeriodTo", BegOfDay(PeriodTo));
//	Return vQry.Execute().Unload();
//EndFunction //GetRoomRateCalendarDays
//
////-----------------------------------------------------------------------------
//Function GetActiveSetRoomRatePrices(pRoomRate, pCalendarDayType, pPeriod)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomRatesSliceLast.ПриказТариф AS ПриказТариф,
//	|	RoomRatesSliceLast.Гостиница AS Гостиница,
//	|	RoomRatesSliceLast.Тариф AS Тариф,
//	|	RoomRatesSliceLast.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|	RoomRatesSliceLast.ПризнакЦены AS ПризнакЦены
//	|FROM
//	|	InformationRegister.Тарифы.SliceLast(
//	|			&qPeriod,
//	|			Тариф = &qRoomRate
//	|				AND ТипДеньКалендарь = &qCalendarDayType
//	|				AND (&qHotelIsFilled
//	|						AND Гостиница = &qHotel
//	|					OR NOT &qHotelIsFilled)) AS RoomRatesSliceLast
//	|
//	|ORDER BY
//	|	RoomRatesSliceLast.Тариф.ПорядокСортировки,
//	|	RoomRatesSliceLast.ТипДеньКалендарь.ПорядокСортировки";
//	vQry.SetParameter("qRoomRate", pRoomRate);
//	vQry.SetParameter("qCalendarDayType", pCalendarDayType);
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(Гостиница));
//	vQry.SetParameter("qPeriod", EndOfDay(pPeriod));
//	
//	Return vQry.Execute().Unload();
//EndFunction //cmGetActiveSetRoomRatePrices
//
////-----------------------------------------------------------------------------
//Function GetListOfActiveRoomTypes(pRoomType)
//	vRoomTypes = New ValueTable();
//	If ЗначениеЗаполнено(pRoomType) Тогда
//		If pRoomType.IsFolder Тогда
//			vRoomTypes = cmGetAllRoomTypes(Гостиница, pRoomType);
//		Else
//			vRoomTypes.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//			vRow = vRoomTypes.Add();
//			vRow.ТипНомера = pRoomType;
//		EndIf;
//	Else
//		vRoomTypes = cmGetAllRoomTypes(Гостиница);
//	EndIf;
//	Return vRoomTypes;
//EndFunction //GetListOfActiveRoomTypes
//
////-----------------------------------------------------------------------------
//Function GetListOfActiveAccommodationTypes(pAccommodationType)
//	vAccommodationTypes = New ValueTable();
//	If ЗначениеЗаполнено(pAccommodationType) Тогда
//		If pAccommodationType.IsFolder Тогда
//			vAccommodationTypes = cmGetAllAccommodationTypes(pAccommodationType);
//		Else
//			vAccommodationTypes.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
//			vRow = vAccommodationTypes.Add();
//			vRow.ВидРазмещения = pAccommodationType;
//		EndIf;
//	Else
//		vAccommodationTypes = cmGetAllAccommodationTypes();
//	EndIf;
//	Return vAccommodationTypes;
//EndFunction //GetListOfActiveAccommodationTypes
//	
////-----------------------------------------------------------------------------
//Процедура pmDoFill(pIsInteractive = False) Экспорт
//	// Log processing start
//	WriteLogEvent(NStr("en='DataProcessor.FillRoomRateDailyPrices';ru='Обработка.ЗаполнениеЦенТарифовПоДня';de='DataProcessor.FillRoomRateDailyPrices'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
//	
//	// Check parameters
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		vMessage = NStr("ru='Не указано начало периода!';
//		                |de='Der Beginn des Zeitraums ist nicht angegeben!'; 
//						|en='Period from is not set!'");
//		WriteLogEvent(NStr("en='DataProcessor.FillRoomRateDailyPrices';ru='Обработка.ЗаполнениеЦенТарифовПоДня';de='DataProcessor.FillRoomRateDailyPrices'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vMessage = NStr("ru='Не указано окончание периода!';
//		                |de='Das Ende des Zeitraums ist nicht angegeben!';
//						|en='Period to is not set!'");
//		WriteLogEvent(NStr("en='DataProcessor.FillRoomRateDailyPrices';ru='Обработка.ЗаполнениеЦенТарифовПоДня';de='DataProcessor.FillRoomRateDailyPrices'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	
//	// Create record set object
//	vRoomRateDailyPricesRecordSet = InformationRegisters.ТарифДни.CreateRecordSet();
//	
//	// Get all hotel ГруппаНомеров types and all accommodation types
//	vAllRoomTypes = cmGetAllRoomTypes(Гостиница, ТипНомера);
//	vAllAccommodationTypes = cmGetAllAccommodationTypes(, Гостиница);
//	vAllClientTypes = cmGetAllClientTypes(Гостиница);
//	vAllClientTypesRow = vAllClientTypes.Add();
//	vAllClientTypesRow.ТипКлиента = Справочники.ТипыКлиентов.EmptyRef();
//	
//	// Write records to the ГруппаНомеров rate daily prices information register
//	vRoomRates = GetListOfActiveRoomRates();
//	For Each vRoomRatesRow In vRoomRates Do
//		vCurRoomRate = vRoomRatesRow.Тариф;
//		vServicePackages = vCurRoomRate.GetObject().pmGetRoomRateServicePackagesList();
//		
//		// Get list of calendar day types valid for the given ГруппаНомеров rate and period
//		vCalendarDayTypes = GetListOfActiveCalendarDayTypes(vCurRoomRate);
//		For Each vCalendarDayTypesRow In vCalendarDayTypes Do
//			vCurCalendarDayType = vCalendarDayTypesRow.ТипДняКалендаря;
//			
//			// Do for each day in the current ГруппаНомеров rate calendar
//			vCalendarDays = GetRoomRateCalendarDays(vCurRoomRate, vCurCalendarDayType);
//			For Each vCalendarDaysRow In vCalendarDays Do
//				vCurDate = BegOfDay(vCalendarDaysRow.Period);
//				#IF CLIENT THEN
//					Status(NStr("en='Processing ГруппаНомеров rate: '; ru='Заполнение по тарифу: '; de='Füllen einer Tariff: '") + TrimAll(vCurRoomRate) + NStr("en=', day type: '; ru=', типу дня: '; de=', Datumtyp: '") + TrimAll(vCurCalendarDayType) + NStr("en=', date: '; ru=', дате: '; de=', Datum: '") + Format(vCurDate, "DF=dd.MM.yyyy") + "...");
//				#ENDIF
//				// Get active set ГруппаНомеров rate prices for the given ГруппаНомеров rate, calendar day type and date
//				vSetRoomRatePrices = GetActiveSetRoomRatePrices(vCurRoomRate, vCurCalendarDayType, vCurDate);
//				For Each vSetRoomRatePricesRow In vSetRoomRatePrices Do
//					vCurSetRoomRatePrices = vSetRoomRatePricesRow.ПриказТариф;
//					vCurPriceTag = vSetRoomRatePricesRow.ПризнакЦены;
//					vCurHotel = vSetRoomRatePricesRow.Гостиница;
//					
//					// Get document price rows
//					vPrices = vCurSetRoomRatePrices.GetObject().pmSortPrices(True);
//					
//					// Do  for each hotel ГруппаНомеров type
//					For Each vAllRoomTypesRow In vAllRoomTypes Do
//						vCurRoomType = vAllRoomTypesRow.ТипНомера;
//						If vCurRoomType.Owner <> vCurHotel Тогда
//							Continue;
//						EndIf;
//						
//						// Do  for each hotel accommodation type
//						For Each vAllAccommodationTypesRow In vAllAccommodationTypes Do
//							vCurAccommodationType = vAllAccommodationTypesRow.ВидРазмещения;
//							
//							// Check permitted accommodation types for the given ГруппаНомеров type
//							If vCurRoomType.AccommodationTypesAllowed.Count() > 0 Тогда
//								If vCurRoomType.AccommodationTypesAllowed.Find(vCurAccommodationType) = Неопределено Тогда
//									Continue;
//								EndIf;
//							EndIf;
//							
//							// Do for each hotel client type
//							For Each vAllClientTypesRow In vAllClientTypes Do
//								vCurClientType = vAllClientTypesRow.ТипКлиента;
//								
//								// Initialize day price and currency
//								vDayPrice = 0;
//								vDayPriceCurrency = Справочники.Валюты.EmptyRef();
//								
//								// Calculate day price
//								For Each vPricesRow In vPrices Do
//									// Check current client type
//									If vCurClientType <> vPricesRow.ТипКлиента Тогда
//										Continue;
//									EndIf;
//									
//									// Get list of active ГруппаНомеров types and check if current ГруппаНомеров type is in this list
//									vRoomTypes = GetListOfActiveRoomTypes(vPricesRow.ТипНомера);
//									If vRoomTypes.Find(vCurRoomType, "ТипНомера") = Неопределено Тогда
//										Continue;
//									EndIf;
//									
//									// Get list of active accommodation types and check if current accommodation type is in this list
//									vAccommodationTypes = GetListOfActiveAccommodationTypes(vPricesRow.ВидРазмещения);
//									If vAccommodationTypes.Find(vCurAccommodationType, "ВидРазмещения") = Неопределено Тогда
//										Continue;
//									EndIf;
//									
//									// Check that current service fits to the ГруппаНомеров rate service group
//									If ЗначениеЗаполнено(vPricesRow.Услуга) Тогда
//										If НЕ cmIsServiceInServiceGroup(vPricesRow.Услуга, vCurRoomRate.RoomRateServiceGroup) Тогда
//											Continue;
//										EndIf;
//									EndIf;
//									
//									// Use only in price services
//									If vPricesRow.IsInPrice Тогда
//										vPrice = vPricesRow.Цена;
//										vCurrency = vPricesRow.Валюта;
//										
//										// Fill day price currency 
//										If НЕ ЗначениеЗаполнено(vDayPriceCurrency) Тогда
//											vDayPriceCurrency = vCurrency;
//										EndIf;
//										
//										// Apply calendar day type discounts
//										If vCurCalendarDayType.Скидка <> 0 Тогда
//											If cmIsServiceInServiceGroup(vPricesRow.Услуга, vCurRoomRate.DiscountServiceGroup) Тогда
//												vPrice = vPrice - Round(vPrice * vCurCalendarDayType.Скидка / 100, 2);
//											EndIf;
//										EndIf;
//										
//										// Apply ГруппаНомеров rate discounts
//										If vCurRoomRate.Скидка <> 0 Тогда
//											If cmIsServiceInServiceGroup(vPricesRow.Услуга, vCurRoomRate.DiscountServiceGroup) Тогда
//												vPrice = vPrice - Round(vPrice * vCurRoomRate.Скидка / 100, 2);
//											EndIf;
//										EndIf;
//										
//										// Convert currencies if necessary
//										If vDayPriceCurrency <> vCurrency Тогда
//											vPrice = cmConvertCurrencies(vPrice, vCurrency, , vDayPriceCurrency, , vCurDate, vCurHotel);
//										EndIf;
//										
//										// Apply ГруппаНомеров rate price rounding rule
//										If vCurRoomRate.RoundPrice Тогда
//											vPrice = Round(vPrice, vCurRoomRate.RoundPriceDigits);
//										EndIf;
//										
//										vDayPrice = vDayPrice + vPrice;
//									EndIf;
//								EndDo; // by price rows
//								
//								// Take ГруппаНомеров rate service package prices into account
//								If ЗначениеЗаполнено(vDayPriceCurrency) Тогда
//									For Each vServicePackagesItem In vServicePackages Do
//										vCurServicePackage = vServicePackagesItem.Value;
//										
//										// Check service package is valid period
//										If vCurDate < vCurServicePackage.DateValidFrom Or ЗначениеЗаполнено(vCurServicePackage.DateValidTo) And vCurDate > vCurServicePackage.DateValidTo Тогда
//											Continue;
//										EndIf;
//										
//										For Each vSPRow In vCurServicePackage.Услуги Do
//											If vSPRow.IsInPrice Тогда
//												// Check current client type
//												If vCurClientType <> vSPRow.ТипКлиента Тогда
//													Continue;
//												EndIf;
//												
//												// Check current calendar day type
//												If ЗначениеЗаполнено(vSPRow.ТипДняКалендаря) And vCurCalendarDayType <> vSPRow.ТипДняКалендаря Тогда
//													Continue;
//												EndIf;
//												
//												// Check current accommodation type
//												If ЗначениеЗаполнено(vSPRow.ВидРазмещения) And vCurAccommodationType <> vSPRow.ВидРазмещения Тогда
//													Continue;
//												EndIf;
//												
//												vPrice = vSPRow.Цена * ?(vSPRow.Количество > 0, vSPRow.Количество, 1);
//												vCurrency = vSPRow.Валюта;
//												
//												// Convert currencies if necessary
//												If vDayPriceCurrency <> vCurrency Тогда
//													vPrice = cmConvertCurrencies(vPrice, vCurrency, , vDayPriceCurrency, , vCurDate, vCurHotel);
//												EndIf;
//												
//												// Apply ГруппаНомеров rate price rounding rule
//												If vCurRoomRate.RoundPrice Тогда
//													vPrice = Round(vPrice, vCurRoomRate.RoundPriceDigits);
//												EndIf;
//												
//												vDayPrice = vDayPrice + vPrice;
//											EndIf;
//										EndDo; // by service package services
//									EndDo; // by service packages
//								EndIf;
//										
//								// Add detailed record to the register
//								If ЗначениеЗаполнено(vDayPriceCurrency) Тогда
//									vDayPriceRec = vRoomRateDailyPricesRecordSet.Add();
//									vDayPriceRec.Period = vCurDate;
//									
//									vDayPriceRec.Гостиница = vCurHotel;
//									vDayPriceRec.Тариф = vCurRoomRate;
//									vDayPriceRec.ТипКлиента = vCurClientType;
//									vDayPriceRec.ПризнакЦены = vCurPriceTag;
//									vDayPriceRec.ТипНомера = vCurRoomType;
//									vDayPriceRec.ВидРазмещения = vCurAccommodationType;
//									
//									vDayPriceRec.Цена = vDayPrice;
//									vDayPriceRec.Валюта = vDayPriceCurrency;
//									vDayPriceRec.ТипДняКалендаря = vCurCalendarDayType;
//								EndIf;
//							EndDo; // by client types
//						EndDo; // by accommodation types
//					EndDo; // by ГруппаНомеров types
//				EndDo; // by set ГруппаНомеров rate prices document
//			EndDo; // by calendar days
//		EndDo; // by calendar day types
//	EndDo; // by ГруппаНомеров rates
//	
//	// Write records to the database
//	If vRoomRateDailyPricesRecordSet.Count() > 0 Тогда
//		vRoomRateDailyPricesRecordSet.Write(True);
//	EndIf;
//	
//	// Log end of processing
//	WriteLogEvent(NStr("en='DataProcessor.FillRoomRateDailyPrices';ru='Обработка.ЗаполнениеЦенТарифовПоДня';de='DataProcessor.FillRoomRateDailyPrices'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
//КонецПроцедуры //pmDoFill
