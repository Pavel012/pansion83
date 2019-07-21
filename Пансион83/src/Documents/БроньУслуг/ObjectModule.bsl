////-----------------------------------------------------------------------------
//Процедура FillRRHAttributes(pRRHRec, pPeriod)
//	FillPropertyValues(pRRHRec, ThisObject);
//	
//	pRRHRec.Period = pPeriod;
//КонецПроцедуры //FillRRHAttributes
//
////-----------------------------------------------------------------------------
//Процедура FillServiceRRHAttributes(pRRHRec, pSrvRow, pPeriod)
//	FillPropertyValues(pRRHRec, ThisObject);
//	FillPropertyValues(pRRHRec, pSrvRow);
//	pRRHRec.Ресурс = pSrvRow.ServiceResource;
//	pRRHRec.ТипРесурса = pSrvRow.ServiceResource.Owner;
//	pRRHRec.DateTimeFrom = BegOfDay(pSrvRow.УчетнаяДата) + (pSrvRow.ВремяС - BegOfDay(pSrvRow.ВремяС));
//	If pSrvRow.ВремяС < pSrvRow.ВремяПо Тогда
//		pRRHRec.DateTimeTo = BegOfDay(pSrvRow.УчетнаяДата) + (pSrvRow.ВремяПо - BegOfDay(pSrvRow.ВремяПо));
//	Else
//		pRRHRec.DateTimeTo = BegOfDay(pSrvRow.УчетнаяДата) + 24*3600 + (pSrvRow.ВремяПо - BegOfDay(pSrvRow.ВремяПо));
//	EndIf;
//	pRRHRec.Продолжительность = cmCalculateDurationInHours(pRRHRec.DateTimeFrom, pRRHRec.DateTimeTo);
//	pRRHRec.RowNumber = pSrvRow.LineNumber;
//	pRRHRec.Period = pPeriod;
//КонецПроцедуры //FillRRHAttributes
//
////-----------------------------------------------------------------------------
//Процедура PostToResourceReservationHistory(pCancel)
//	// Do main resorce movements
//	If ЗначениеЗаполнено(Resource) Тогда
//		vRRHRec = RegisterRecords.ИсторияБрониРесурсов.Add();
//		FillRRHAttributes(vRRHRec, Date);
//	EndIf;	
//		
//	// Check services
//	For Each vSrvRow In Services Do
//		If ЗначениеЗаполнено(vSrvRow.ServiceResource) And TypeOf(vSrvRow.ServiceResource) = Type("CatalogRef.Ресурсы") And vSrvRow.DoResourceReservation Тогда
//			// Do additional resource movements
//			vRRHRec = RegisterRecords.ИсторияБрониРесурсов.Add();
//			FillServiceRRHAttributes(vRRHRec, vSrvRow, Date);
//		EndIf;
//	EndDo;
//	
//	// Write RegisterRecords	
//	RegisterRecords.ИсторияБрониРесурсов.Write();
//КонецПроцедуры //PostToResourceReservationHistory
//
////-----------------------------------------------------------------------------
//Процедура FillSFAttributes(pSFRec, pSrvRec, pPeriod)
//	FillPropertyValues(pSFRec, ThisObject);
//	FillPropertyValues(pSFRec, pSrvRec);
//	
//	pSFRec.Period = pPeriod;
//	pSFRec.ДокОснование = Ref;
//	pSFRec.СчетПроживания = ChargingFolio;
//	
//	If ЗначениеЗаполнено(pSrvRec.ServiceResource) And TypeOf(pSrvRec.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//		pSFRec.Ресурс = pSrvRec.ServiceResource;
//	EndIf;
//	
//	// Fill Контрагент, contract and payment method from the folio
//	If ЗначениеЗаполнено(ChargingFolio) Тогда
//		pSFRec.Контрагент = ChargingFolio.Контрагент;
//		pSFRec.Договор = ChargingFolio.Contract;
//		pSFRec.Агент = ChargingFolio.Agent;
//		pSFRec.ГруппаГостей = ChargingFolio.GuestGroup;
//		pSFRec.СпособОплаты = ChargingFolio.PaymentMethod;
//	EndIf;
//	
//	vSumInReportingCurrency = Round(cmConvertCurrencies(pSrvRec.Сумма - pSrvRec.СуммаСкидки, FolioCurrency, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	vVATSumInReportingCurrency = Round(cmConvertCurrencies(pSrvRec.СуммаНДС - pSrvRec.НДСскидка, FolioCurrency, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	pSFRec.Продажи = vSumInReportingCurrency;
//	pSFRec.ПродажиБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	pSFRec.СуммаНДС = vVATSumInReportingCurrency;
//	pSFRec.ДоходНомеров = 0;
//	pSFRec.ДоходПродажиБезНДС = 0;
//	pSFRec.ДоходДопМеста = 0;
//	pSFRec.ДоходДопМестаБезНДС = 0;
//	pSFRec.Цена = cmRecalculatePrice(vSumInReportingCurrency, pSrvRec.Количество);
//	pSFRec.Количество = pSrvRec.Количество;
//	pSFRec.ДоходРес = 0;
//	pSFRec.ДоходРесБезНДС = 0;
//	
//	If pSrvRec.IsResourceRevenue Тогда
//		pSFRec.ДоходРес = pSFRec.Продажи;
//		pSFRec.ДоходРесБезНДС = pSFRec.ПродажиБезНДС;
//		pSFRec.ПроданоЧасовРесурса = pSFRec.Количество;
//		If pSFRec.Услуга.IsPricePerMinute Тогда
//			pSFRec.ПроданоЧасовРесурса = pSFRec.Количество/60;
//		EndIf;
//	EndIf;
//	
//	vCommissionSumInReportingCurrency = Round(cmConvertCurrencies(pSrvRec.СуммаКомиссии, FolioCurrency, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	vVATCommissionSumInReportingCurrency = Round(cmConvertCurrencies(pSrvRec.СуммаКомиссииНДС, FolioCurrency, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	
//	pSFRec.СуммаКомиссии = vCommissionSumInReportingCurrency;
//	pSFRec.КомиссияБезНДС = vCommissionSumInReportingCurrency - vVATCommissionSumInReportingCurrency;
//	
//	vDiscountSumInReportingCurrency = Round(cmConvertCurrencies(pSrvRec.СуммаСкидки, FolioCurrency, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	vVATDiscountSumInReportingCurrency = Round(cmConvertCurrencies(pSrvRec.НДСскидка, FolioCurrency, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	
//	pSFRec.СуммаСкидки = vDiscountSumInReportingCurrency;
//	pSFRec.СуммаСкидкиБезНДС = vDiscountSumInReportingCurrency - vVATDiscountSumInReportingCurrency;
//	
//	pSFRec.ПроданоНомеров = 0;
//	pSFRec.ПроданоМест = 0;
//	pSFRec.ПроданоДопМест = 0;
//	pSFRec.ЧеловекаДни = 0;
//	pSFRec.ЗаездГостей = 0;
//	pSFRec.ЗаездНомеров = 0;
//	pSFRec.ЗаездМест = 0;
//	pSFRec.ЗаездДополнительныхМест = 0;
//	
//	// Check if Контрагент and agent are the same
//	If ЗначениеЗаполнено(ChargingFolio) Тогда
//		vDoNotPostCommission = False;
//		If ЗначениеЗаполнено(ChargingFolio.Agent) And ChargingFolio.Agent.DoNotPostCommission Тогда
//			vDoNotPostCommission = True;
//		EndIf;
//		If НЕ vDoNotPostCommission Тогда
//			If ЗначениеЗаполнено(ChargingFolio.Agent) And 
//			   ChargingFolio.Agent <> ChargingFolio.Контрагент And 
//			   vCommissionSumInReportingCurrency <> 0 Тогда
//				pSFRec.СуммаКомиссии = 0;
//				pSFRec.КомиссияБезНДС = 0;
//				
//				// Add new record
//				vSFRec = RegisterRecords.ПрогнозПродаж.Add();
//				FillPropertyValues(vSFRec, pSFRec, , "RecordType");
//				
//				// Fill dimensions
//				vSFRec.Контрагент = ChargingFolio.Agent;
//				vSFRec.Договор = ChargingFolio.Agent.AgentCommissionContract;
//				vSFRec.Агент = ChargingFolio.Agent;
//				vSFRec.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//				
////				 Reset resources
//				vSFRec.Продажи = 0;
//				vSFRec.ПродажиБезНДС = 0;
//				vSFRec.ДоходНомеров = 0;
//				vSFRec.ДоходПродажиБезНДС = 0;
//				vSFRec.ДоходДопМеста = 0;
//				vSFRec.ДоходДопМестаБезНДС = 0;
//				vSFRec.Количество = 0;
//				vSFRec.СуммаСкидки = 0;
//				vSFRec.СуммаСкидкиБезНДС = 0;
//				vSFRec.ПроданоНомеров = 0;
//				vSFRec.ПроданоМест = 0;
//				vSFRec.ПроданоДопМест = 0;
//				vSFRec.ЧеловекаДни = 0;
//				vSFRec.ЗаездГостей = 0;
//				vSFRec.ЗаездНомеров = 0;
//				vSFRec.ЗаездМест = 0;
//				vSFRec.ЗаездДополнительныхМест = 0;
//				vSFRec.ДоходРес = 0;
//				vSFRec.ДоходРесБезНДС = 0;
//				vSFRec.ПроданоЧасовРесурса = 0;
//				
//				// Fill commission
//				vSFRec.СуммаКомиссии = vCommissionSumInReportingCurrency;
//				vSFRec.КомиссияБезНДС = vCommissionSumInReportingCurrency - vVATCommissionSumInReportingCurrency;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillSFAttributes
//
////-----------------------------------------------------------------------------
//Процедура FillARFAttributes(pARFRec, pSrvRec, pPeriod)
//	FillPropertyValues(pARFRec, ThisObject);
//	FillPropertyValues(pARFRec, pSrvRec);
//	
//	pARFRec.Period = pPeriod;
//	pARFRec.ДокОснование = Ref;
//	
//	If ЗначениеЗаполнено(pSrvRec.ServiceResource) And TypeOf(pSrvRec.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//		pARFRec.Ресурс = pSrvRec.ServiceResource;
//	EndIf;
//	
//	// Fill Контрагент, contract and payment method from the folio
//	If ЗначениеЗаполнено(ChargingFolio) Тогда
//		pARFRec.Контрагент = ChargingFolio.Контрагент;
//		pARFRec.Договор = ChargingFolio.Contract;
//		pARFRec.Агент = ChargingFolio.Agent;
//		pARFRec.ГруппаГостей = ChargingFolio.GuestGroup;
//		pARFRec.СпособОплаты = ChargingFolio.PaymentMethod;
//	EndIf;
//	
//	vSumInFolioCurrency = pSrvRec.Сумма - pSrvRec.СуммаСкидки;
//	vVATSumInFolioCurrency = pSrvRec.СуммаНДС - pSrvRec.НДСскидка;
//	pARFRec.Продажи = vSumInFolioCurrency;
//	pARFRec.ПродажиБезНДС = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	pARFRec.ДоходНомеров = 0;
//	pARFRec.ДоходПродажиБезНДС = 0;
//	pARFRec.ДоходДопМеста = 0;
//	pARFRec.ДоходДопМестаБезНДС = 0;
//	pARFRec.Цена = cmRecalculatePrice(vSumInFolioCurrency, pSrvRec.Количество);
//	pARFRec.Количество = pSrvRec.Количество;
//	
//	vDiscountSumInFolioCurrency = pSrvRec.СуммаСкидки;
//	vVATDiscountSumInFolioCurrency = pSrvRec.НДСскидка;
//	pARFRec.СуммаСкидки = vDiscountSumInFolioCurrency;
//	pARFRec.СуммаСкидкиБезНДС = vDiscountSumInFolioCurrency - vVATDiscountSumInFolioCurrency;
//	
//	pARFRec.ПроданоНомеров = 0;
//	pARFRec.ПроданоМест = 0;
//	pARFRec.ПроданоДопМест = 0;
//	pARFRec.ЧеловекаДни = 0;
//	pARFRec.ЗаездГостей = 0;
//	pARFRec.ЗаездНомеров = 0;
//	pARFRec.ЗаездМест = 0;
//	pARFRec.ЗаездДополнительныхМест = 0;
//	
//	pARFRec.ПланПродаж = pARFRec.Продажи;
//	pARFRec.ExpectedSalesWithoutVAT = pARFRec.ПродажиБезНДС;
//	pARFRec.ExpectedRoomRevenue = pARFRec.ДоходНомеров;
//	pARFRec.ExpectedRoomRevenueWithoutVAT = pARFRec.ДоходПродажиБезНДС;
//	pARFRec.ExpectedExtraBedRevenue = pARFRec.ДоходДопМеста;
//	pARFRec.ExpectedExtraBedRevenueWithoutVAT = pARFRec.ДоходДопМестаБезНДС;
//	pARFRec.ПланСуммаСкидки = pARFRec.СуммаСкидки;
//	pARFRec.ExpectedDiscountSumWithoutVAT = pARFRec.СуммаСкидкиБезНДС;
//	pARFRec.ПланПродажиНомеров = pARFRec.ПроданоНомеров;
//	pARFRec.ПланПродажиМест = pARFRec.ПроданоМест;
//	pARFRec.ПланПродажиДопМест = pARFRec.ПроданоДопМест;
//	pARFRec.ExpectedGuestDays = pARFRec.ЧеловекаДни;
//	pARFRec.ExpectedGuestsCheckedIn = pARFRec.ЗаездГостей;
//	pARFRec.ExpectedRoomsCheckedIn = pARFRec.ЗаездНомеров;
//	pARFRec.ПланЗаездМест = pARFRec.ЗаездМест;
//	pARFRec.ПланЗаездДопМест = pARFRec.ЗаездДополнительныхМест;
//	pARFRec.ПланКоличество = pARFRec.Количество;
//	
//	// Commission
//	pARFRec.СуммаКомиссии = pSrvRec.СуммаКомиссии;
//	pARFRec.КомиссияБезНДС = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//	pARFRec.КомиссияПлан = pARFRec.СуммаКомиссии;
//	pARFRec.ExpectedCommissionSumWithoutVAT = pARFRec.КомиссияБезНДС;
//	
//	// Check if Контрагент and agent are the same
//	If ЗначениеЗаполнено(ChargingFolio) Тогда
//		vDoNotPostCommission = False;
//		If ЗначениеЗаполнено(ChargingFolio.Agent) And ChargingFolio.Agent.DoNotPostCommission Тогда
//			vDoNotPostCommission = True;
//		EndIf;
//		If vDoNotPostCommission Тогда
//			pARFRec.СуммаКомиссии = 0;
//			pARFRec.КомиссияБезНДС = 0;
//			pARFRec.КомиссияПлан = 0;
//			pARFRec.ExpectedCommissionSumWithoutVAT = 0;
//		Else
//			If ЗначениеЗаполнено(ChargingFolio.Agent) And 
//			   ChargingFolio.Agent <> ChargingFolio.Контрагент And 
//			   pSrvRec.СуммаКомиссии <> 0 Тогда
//				pARFRec.СуммаКомиссии = 0;
//				pARFRec.КомиссияБезНДС = 0;
//				pARFRec.КомиссияПлан = 0;
//				pARFRec.ExpectedCommissionSumWithoutVAT = 0;
//				
//				// Add new record
//				vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//				FillPropertyValues(vARFRec, pARFRec, , "RecordType");
//				
//				// Fill dimensions
//				vARFRec.Контрагент = ChargingFolio.Agent;
//				vARFRec.Договор = ChargingFolio.Agent.AgentCommissionContract;
//				vARFRec.Агент = ChargingFolio.Agent;
//				vARFRec.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//				
//				// Reset resources
//				vARFRec.Продажи = 0;
//				vARFRec.ПродажиБезНДС = 0;
//				vARFRec.ДоходНомеров = 0;
//				vARFRec.ДоходПродажиБезНДС = 0;
//				vARFRec.ДоходДопМеста = 0;
//				vARFRec.ДоходДопМестаБезНДС = 0;
//				vARFRec.Количество = 0;
//				vARFRec.СуммаСкидки = 0;
//				vARFRec.СуммаСкидкиБезНДС = 0;
//				vARFRec.ПроданоНомеров = 0;
//				vARFRec.ПроданоМест = 0;
//				vARFRec.ПроданоДопМест = 0;
//				vARFRec.ЧеловекаДни = 0;
//				vARFRec.ЗаездГостей = 0;
//				vARFRec.ЗаездНомеров = 0;
//				vARFRec.ЗаездМест = 0;
//				vARFRec.ЗаездДополнительныхМест = 0;
//				
//				vARFRec.ПланПродаж = 0;
//				vARFRec.ExpectedSalesWithoutVAT = 0;
//				vARFRec.ExpectedRoomRevenue = 0;
//				vARFRec.ExpectedRoomRevenueWithoutVAT = 0;
//				vARFRec.ExpectedExtraBedRevenue = 0;
//				vARFRec.ExpectedExtraBedRevenueWithoutVAT = 0;
//				vARFRec.ПланКоличество = 0;
//				vARFRec.ПланСуммаСкидки = 0;
//				vARFRec.ExpectedDiscountSumWithoutVAT = 0;
//				vARFRec.ПланПродажиНомеров = 0;
//				vARFRec.ПланПродажиМест = 0;
//				vARFRec.ПланПродажиДопМест = 0;
//				vARFRec.ExpectedGuestDays = 0;
//				vARFRec.ExpectedGuestsCheckedIn = 0;
//				vARFRec.ExpectedRoomsCheckedIn = 0;
//				vARFRec.ПланЗаездМест = 0;
//				vARFRec.ПланЗаездДопМест = 0;
//				
//				// Fill commission
//				vARFRec.СуммаКомиссии = pSrvRec.СуммаКомиссии;
//				vARFRec.КомиссияБезНДС = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//				vARFRec.КомиссияПлан = vARFRec.СуммаКомиссии;
//				vARFRec.ExpectedCommissionSumWithoutVAT = vARFRec.КомиссияБезНДС;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillARFAttributes
//
////-----------------------------------------------------------------------------
//Процедура FillExpectedARFAttributes(pARFRec, pSrvRec, pPeriod)
//	FillPropertyValues(pARFRec, ThisObject);
//	FillPropertyValues(pARFRec, pSrvRec);
//	
//	pARFRec.Period = pPeriod;
//	pARFRec.ДокОснование = Ref;
//	
//	If ЗначениеЗаполнено(pSrvRec.ServiceResource) And TypeOf(pSrvRec.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//		pARFRec.Ресурс = pSrvRec.ServiceResource;
//	EndIf;
//	
//	// Fill Контрагент, contract and payment method from the folio
//	If ЗначениеЗаполнено(ChargingFolio) Тогда
//		pARFRec.Контрагент = ChargingFolio.Контрагент;
//		pARFRec.Договор = ChargingFolio.Contract;
//		pARFRec.Агент = ChargingFolio.Agent;
//		pARFRec.ГруппаГостей = ChargingFolio.GuestGroup;
//		pARFRec.СпособОплаты = ChargingFolio.PaymentMethod;
//	EndIf;
//	
//	vSumInFolioCurrency = pSrvRec.Сумма - pSrvRec.СуммаСкидки;
//	vVATSumInFolioCurrency = pSrvRec.СуммаНДС - pSrvRec.НДСскидка;
//	pARFRec.ПланПродаж = vSumInFolioCurrency;
//	pARFRec.ExpectedSalesWithoutVAT = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	pARFRec.ExpectedRoomRevenue = 0;
//	pARFRec.ExpectedRoomRevenueWithoutVAT = 0;
//	pARFRec.ExpectedExtraBedRevenue = 0;
//	pARFRec.ExpectedExtraBedRevenueWithoutVAT = 0;
//	pARFRec.Цена = cmRecalculatePrice(vSumInFolioCurrency, pSrvRec.Количество);
//	pARFRec.ПланКоличество = pSrvRec.Количество;
//	
//	vDiscountSumInFolioCurrency = pSrvRec.СуммаСкидки;
//	vVATDiscountSumInFolioCurrency = pSrvRec.НДСскидка;
//	pARFRec.ПланСуммаСкидки = vDiscountSumInFolioCurrency;
//	pARFRec.ExpectedDiscountSumWithoutVAT = vDiscountSumInFolioCurrency - vVATDiscountSumInFolioCurrency;
//	
//	pARFRec.ПланПродажиНомеров = 0;
//	pARFRec.ПланПродажиМест = 0;
//	pARFRec.ПланПродажиДопМест = 0;
//	pARFRec.ExpectedGuestDays = 0;
//	pARFRec.ExpectedGuestsCheckedIn = 0;
//	pARFRec.ExpectedRoomsCheckedIn = 0;
//	pARFRec.ПланЗаездМест = 0;
//	pARFRec.ПланЗаездДопМест = 0;
//	
//	pARFRec.Продажи = 0;
//	pARFRec.ПродажиБезНДС = 0;
//	pARFRec.ДоходНомеров = 0;
//	pARFRec.ДоходПродажиБезНДС = 0;
//	pARFRec.ДоходДопМеста = 0;
//	pARFRec.ДоходДопМестаБезНДС = 0;
//	pARFRec.СуммаКомиссии = 0;
//	pARFRec.КомиссияБезНДС = 0;
//	pARFRec.СуммаСкидки = 0;
//	pARFRec.СуммаСкидкиБезНДС = 0;
//	pARFRec.ПроданоНомеров = 0;
//	pARFRec.ПроданоМест = 0;
//	pARFRec.ПроданоДопМест = 0;
//	pARFRec.ЧеловекаДни = 0;
//	pARFRec.ЗаездГостей = 0;
//	pARFRec.ЗаездНомеров = 0;
//	pARFRec.ЗаездМест = 0;
//	pARFRec.ЗаездДополнительныхМест = 0;
//	pARFRec.Количество = 0;
//	
//	// Commission
//	pARFRec.КомиссияПлан = pSrvRec.СуммаКомиссии;
//	pARFRec.ExpectedCommissionSumWithoutVAT = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//	
//	// Check if Контрагент and agent are the same
//	If ЗначениеЗаполнено(ChargingFolio) Тогда
//		vDoNotPostCommission = False;
//		If ЗначениеЗаполнено(ChargingFolio.Agent) And ChargingFolio.Agent.DoNotPostCommission Тогда
//			vDoNotPostCommission = True;
//		EndIf;
//		If vDoNotPostCommission Тогда
//			pARFRec.КомиссияПлан = 0;
//			pARFRec.ExpectedCommissionSumWithoutVAT = 0;
//		Else
//			If ЗначениеЗаполнено(ChargingFolio.Agent) And 
//			   ChargingFolio.Agent <> ChargingFolio.Контрагент And 
//			   pSrvRec.СуммаКомиссии <> 0 Тогда
//				pARFRec.КомиссияПлан = 0;
//				pARFRec.ExpectedCommissionSumWithoutVAT = 0;
//				
//				// Add new record
//				vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//				FillPropertyValues(vARFRec, pARFRec, , "RecordType");
//				
//				// Fill dimensions
//				vARFRec.Контрагент = ChargingFolio.Agent;
//				vARFRec.Договор = ChargingFolio.Agent.AgentCommissionContract;
//				vARFRec.Агент = ChargingFolio.Agent;
//				vARFRec.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//				
//				// Reset expected resources
//				vARFRec.ПланПродаж = 0;
//				vARFRec.ExpectedSalesWithoutVAT = 0;
//				vARFRec.ExpectedRoomRevenue = 0;
//				vARFRec.ExpectedRoomRevenueWithoutVAT = 0;
//				vARFRec.ExpectedExtraBedRevenue = 0;
//				vARFRec.ExpectedExtraBedRevenueWithoutVAT = 0;
//				vARFRec.ПланКоличество = 0;
//				vARFRec.ПланСуммаСкидки = 0;
//				vARFRec.ExpectedDiscountSumWithoutVAT = 0;
//				vARFRec.ПланПродажиНомеров = 0;
//				vARFRec.ПланПродажиМест = 0;
//				vARFRec.ПланПродажиДопМест = 0;
//				vARFRec.ExpectedGuestDays = 0;
//				vARFRec.ExpectedGuestsCheckedIn = 0;
//				vARFRec.ExpectedRoomsCheckedIn = 0;
//				vARFRec.ПланЗаездМест = 0;
//				vARFRec.ПланЗаездДопМест = 0;
//				
//				// Fill expected commission
//				vARFRec.КомиссияПлан = pSrvRec.СуммаКомиссии;
//				vARFRec.ExpectedCommissionSumWithoutVAT = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillExpectedARFAttributes
//
////-----------------------------------------------------------------------------
//Процедура FillServiceRegistrationAttributes(pSRRec, pSrvRec, pPeriod) 
//	pSRRec.Period = pPeriod;
//	
//	FillPropertyValues(pSRRec, ThisObject);
//	FillPropertyValues(pSRRec, pSrvRec);
//	
//	// Fill folio
//	pSRRec.СчетПроживания = ChargingFolio;
//	
//	// Fill parent document by this document ref
//	pSRRec.ДокОснование = Ref;
//	
//	// Fill accounting date
//	pSRRec.УчетнаяДата = BegOfDay(pPeriod);
//	
//	// Resources
//	pSRRec.Сумма = pSrvRec.Сумма - pSrvRec.СуммаСкидки;
//	
//	// Attributes
//	pSRRec.Цена = cmRecalculatePrice(pSRRec.Сумма, pSRRec.Количество);
//КонецПроцедуры //FillServiceRegistrationAttributes
//
////-----------------------------------------------------------------------------
//Процедура PostToForecastSales(pCancel)
//	// Do movement on accounting date for each service in services
//	For Each vSrvRec In Services Do	
//		If НЕ ResourceReservationStatus.DoNotChargeForecastServices Тогда
//			If ЗначениеЗаполнено(vSrvRec.Service) And ЗначениеЗаполнено(vSrvRec.Service.ServiceType) And 
//			   vSrvRec.Service.ServiceType.ActualAmountIsChargedExternally And 
//			   vSrvRec.AccountingDate < BegOfDay(CurrentDate()) Тогда
//			Else
//				vSFRec = RegisterRecords.ПрогнозПродаж.Add();
//				FillSFAttributes(vSFRec, vSrvRec, vSrvRec.AccountingDate);
//				
//				vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//				FillARFAttributes(vARFRec, vSrvRec, vSrvRec.AccountingDate);
//			EndIf;
//		EndIf;
//	EndDo;
//			
//	// Write RegisterRecords	
//	If НЕ ResourceReservationStatus.DoNotChargeForecastServices Тогда
//		RegisterRecords.ПрогнозПродаж.Write();
//		RegisterRecords.ПрогнозРеализации.Write();
//	EndIf;
//КонецПроцедуры //PostToForecastSales
//
////-----------------------------------------------------------------------------
//Процедура PostToExpectedCustomerSales(pCancel)
//	// Do movement on accounting date for each service in services
//	For Each vSrvRec In Services Do	
//		If ЗначениеЗаполнено(vSrvRec.Service) Тогда
//			If ЗначениеЗаполнено(ResourceReservationStatus) And ResourceReservationStatus.ServicesAreDelivered Тогда
//				vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//				FillExpectedARFAttributes(vARFRec, vSrvRec, vSrvRec.AccountingDate);
//			ElsIf НЕ ЗначениеЗаполнено(vSrvRec.Service.ServiceType) Or ЗначениеЗаполнено(vSrvRec.Service.ServiceType) And 
//			      НЕ vSrvRec.Service.ServiceType.ActualAmountIsChargedExternally Тогда
//				vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//				FillExpectedARFAttributes(vARFRec, vSrvRec, vSrvRec.AccountingDate);
//			EndIf;
//		EndIf;
//	EndDo;
//			
//	// Write RegisterRecords	
//	RegisterRecords.ПрогнозРеализации.Write();
//КонецПроцедуры //PostToExpectedCustomerSales
//
////-----------------------------------------------------------------------------
//Процедура PostToRegisters(pCancel)
//	// To the resource reservation history
//	PostToResourceReservationHistory(pCancel);
//	// If reservation is active
//	If ResourceReservationStatus.IsActive Тогда
//		// To the forecast sales
//		If НЕ DoCharging Тогда
//			PostToForecastSales(pCancel);
//		EndIf;
//	EndIf;
//КонецПроцедуры //PostToRegisters
//
////-----------------------------------------------------------------------------
//Процедура DoChargeTransfer(vServiceRow, pChargeRow)
//	If pChargeRow <> Неопределено Тогда
//		If pChargeRow.СчетПроживания <> ChargingFolio Тогда
//			If НЕ ЗначениеЗаполнено(pChargeRow.ПеремещениеНачисления) Тогда
//				vChargeObj = pChargeRow.Ref.GetObject();
//				vChargeObj.СчетПроживания = ChargingFolio;
//				If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//					vChargeObj.Write(DocumentWriteMode.Posting);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //DoChargeTransfer
//
////-----------------------------------------------------------------------------
//Процедура DoCharge(vServiceRow, pChargeRow)
//	If ЗначениеЗаполнено(vServiceRow.УчетнаяДата) Тогда
//		If pChargeRow = Неопределено Тогда
//			vChargeObj = Documents.Начисление.CreateDocument();
//		Else
//			vChargeObj = pChargeRow.Ref.GetObject();
//		EndIf;
//		
//		FillPropertyValues(vChargeObj, vServiceRow);
//		
//		// Resource
//		If ЗначениеЗаполнено(vServiceRow.ServiceResource) And TypeOf(vServiceRow.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//			vChargeObj.Ресурс = vServiceRow.ServiceResource; 
//		EndIf;
//		
//		// Fill identity parameters
//		vChargeObj.ДатаДок = vServiceRow.УчетнаяДата;
//		vChargeObj.SetTime(AutoTimeMode.DontUse);
//		vChargeObj.ДокОснование = ThisObject.Ref;
//		vChargeObj.Автор = ПараметрыСеанса.ТекПользователь;
//		vChargeObj.СчетПроживания = ChargingFolio;
//		
//		// Fill charge exchange rate date and folio and reporting currency exchange rates
//		vChargeObj.ExchangeRateDate = ?(ЗначениеЗаполнено(vServiceRow.УчетнаяДата), vServiceRow.УчетнаяДата, ExchangeRateDate);
//		vChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.ВалютаЛицСчета, vChargeObj.ExchangeRateDate);
//		vChargeObj.ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.Валюта, vChargeObj.ExchangeRateDate);
//		
//		// Fill charge payment section
//		vChargeObj.PaymentSection = vChargeObj.Услуга.PaymentSection;
//		
//		// Post charge
//		If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//			vChargeObj.Write(DocumentWriteMode.Posting);
//		EndIf;
//	EndIf;
//КонецПроцедуры //DoCharge
//
////-----------------------------------------------------------------------------
//Процедура DeleteCharge(pCharges, pChargeRow)
//	vChargeObj = pChargeRow.Ref.GetObject();
//	pCharges.Delete(pChargeRow);
//	If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//		vChargeObj.SetDeletionMark(True);
//	EndIf;
//КонецПроцедуры //DeleteCharge
//
////-----------------------------------------------------------------------------
//Процедура ChargeServiceDifferences(pTab, pServices, pCharges)
//	vUpdatedCharges = New СписокЗначений();
//	// For each row in differenses table
//	For Each vRow In pTab Do
//		// Try to find the same row in the existing charges
//		vChargeRow = cmGetResourceReservationChargeRow(pCharges, vRow);
//		// Try to find the same row in the existing services
//		vServiceRow = cmGetResourceReservationChargeRow(pServices, vRow);
//		// Check search results
//		If vChargeRow = Неопределено And vServiceRow = Неопределено Тогда
//			ВызватьИсключение NStr("en = 'Failed to build charges list! Please contact product support team.'; 
//			           |de = 'Failed to build charges list! Please contact product support team.'; 
//			           |ru = 'Ошибка при формировании таблицы начислений. Пожалуйста сообщите об ошибке команде сопровождения программы.'");
//		ElsIf vChargeRow = Неопределено And vServiceRow <> Неопределено Тогда
//			// No such row in previously charged services, so do charging
//			DoCharge(vServiceRow, vChargeRow);
//		ElsIf vChargeRow <> Неопределено And vServiceRow = Неопределено Тогда
//			// No such row in current services, so delete previous charge
//			DeleteCharge(pCharges, vChargeRow);
//		ElsIf vUpdatedCharges.FindByValue(vChargeRow.Ref) = Неопределено Тогда		
//			vUpdatedCharges.Add(vChargeRow.Ref);
//			// Check resources for the row. If all are 0 then check should we 
//			// change folio for this charge
//			If cmResourceReservationServiceResourcesAreZero(vRow) Тогда
//				DoChargeTransfer(vServiceRow, vChargeRow);
//			Else
//				// Update old charge with current service data
//				DoCharge(vServiceRow, vChargeRow);
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //ChargeServiceDifferences
//
////-----------------------------------------------------------------------------
//Процедура PostToAccumulatingDiscountResources(pServices)
//	pServices.Columns.Add("IsRoomRevenue", cmGetBooleanTypeDescription());
//	pServices.Columns.Add("ЧеловекаДни", cmGetNumberTypeDescription(19, 7));
//	pServices.Columns.Add("ЗаездГостей", cmGetNumberTypeDescription(19, 7));
//	pServices.FillValues(False, "IsRoomRevenue");
//	pServices.FillValues(0, "ЧеловекаДни");
//	pServices.FillValues(0, "ЗаездГостей");
//	vAccDiscounts = cmGetAccumulatingDiscountTypes(DiscountType);
//	For Each vAccDiscount In vAccDiscounts Do
//		vDiscountType = vAccDiscount.ТипСкидки;
//		If TurnOffAutomaticDiscounts Тогда
//			If DiscountType <> vDiscountType Тогда
//				Continue;
//			EndIf;
//		EndIf;
//		vDiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//		For Each vSrvRow In pServices Do
//			vService = vSrvRow.Услуга;
//			If cmIsServiceInServiceGroup(vService, vDiscountServiceGroup) Тогда
//				vDiscountTypeObj = vDiscountType.GetObject();
//				vDiscountDimension = Неопределено;
//				vResource = vDiscountTypeObj.pmCalculateResource(vSrvRow, NumberOfPersons, ChargingFolio, DiscountCard, vDiscountDimension);
//				If vResource <> 0 Тогда
//					If ЗначениеЗаполнено(vDiscountDimension) Тогда
//						Movement = RegisterRecords.НакопитСкидки.Add();
//						If vResource > 0 Тогда
//							Movement.RecordType = AccumulationRecordType.Receipt;
//						Else
//							Movement.RecordType = AccumulationRecordType.Expense;
//						EndIf;
//						Movement.Period = vSrvRow.УчетнаяДата;
//						Movement.ТипСкидки = vDiscountType;
//						Movement.ИзмерениеСкидки = vDiscountDimension;
//						If vDiscountType.IsPerVisit Or vDiscountType.BonusCalculationFactor <> 0 Тогда
//							Movement.ГруппаГостей = GuestGroup;
//						EndIf;
//						Movement.Ресурс = vResource;
//						If vDiscountTypeObj.BonusCalculationFactor <> 0 Тогда
//							Movement.Бонус = vResource * vDiscountTypeObj.BonusCalculationFactor;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndDo;
//	RegisterRecords.НакопитСкидки.Write();
//КонецПроцедуры //PostToAccumulatingDiscountResources
//
////-----------------------------------------------------------------------------
//Процедура ChargeServices(pCancel, pPostingMode)
//	vForecastWrite = False;
//	vServiceRegistrationWrite = False;
//	
//	// 1. Build table of already charged services
//	vChargesTab = cmGetTableOfAlreadyChargedServices(ThisObject.Ref);
//	
//	// 2. Create table of document services
//	vServicesTab = Services.Unload();
//	If НЕ DoCharging Тогда
//		vServicesTab.Clear();
//		
//		// Write to accumulation discount resources
//		If ЗначениеЗаполнено(ResourceReservationStatus) And ResourceReservationStatus.IsActive Тогда
//			PostToAccumulatingDiscountResources(vServicesTab);
//		EndIf;
//	EndIf;
//	// Remove services that shouldn't be charged to the folio
//	If НЕ DoChargingIgnoringProhibition Тогда
//		i = 0;
//		While i < vServicesTab.Count() Do
//			vSrv = vServicesTab.Get(i);
//			If ЗначениеЗаполнено(vSrv.Услуга) And ЗначениеЗаполнено(vSrv.Услуга.ServiceType) And 
//			   vSrv.Услуга.ServiceType.ActualAmountIsChargedExternally Тогда
//				// Post service to the forecast registers
//				If ЗначениеЗаполнено(ResourceReservationStatus) And 
//				   ResourceReservationStatus.IsActive And 
//				   НЕ ResourceReservationStatus.ServicesAreDelivered And 
//				   vSrv.УчетнаяДата >= BegOfDay(CurrentDate()) Тогда
//					// Write to sales forecast
//					vSFRec = RegisterRecords.ПрогнозПродаж.Add();
//					FillSFAttributes(vSFRec, vSrv, vSrv.УчетнаяДата);
//					
//				    // Write to accounts receivable forecast
//					vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//					FillARFAttributes(vARFRec, vSrv, vSrv.УчетнаяДата);
//					
//					vForecastWrite = True;
//					
//					// Post to service registration if necessary
//					If vSrv.Услуга.ServiceRegistrationIsTurnedOn Тогда
//						vSRRec = RegisterRecords.РегистрацияУслуги.AddReceipt();
//						FillServiceRegistrationAttributes(vSRRec, vSrv, vSrv.УчетнаяДата);
//						
//						vServiceRegistrationWrite = True;
//					EndIf;
//				EndIf;
//
//				// Delete service
//				vServicesTab.Delete(i);
//			Else
//				i = i + 1;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Add analitical dimensions to the services table
//	cmAddResourceReservationServicesDimensionsColumns(vServicesTab);
//	
//	// If accommodation is active
//	For Each vSrv In vServicesTab Do
//		// Fill is manual column
//		If vSrv.IsManualPrice Тогда
//			vSrv.IsManual = True;
//		EndIf;
//		// Fill additional charge attributes
//		cmFillResourceReservationServicesDimensionsColumns(vSrv, ThisObject);
//	EndDo;
//	
//	// 3. Build difference table between already charged services and 
//	// services in the document. We will do it ignoring folios.
//	vServicesDifferenceTab = cmGetResourceReservationServicesDifference(vServicesTab, vChargesTab);
//	
//	// 4. Set current folio and service remarks
//	pmSetCurrentFolio(vServicesTab);
//	
//	// 5. Create charging for each service in difference services
//	ChargeServiceDifferences(vServicesDifferenceTab, vServicesTab, vChargesTab);
//	
//	// 6. Write forecast registers
//	If vForecastWrite Тогда
//		RegisterRecords.ПрогнозПродаж.Write();
//		RegisterRecords.ПрогнозРеализации.Write();
//	EndIf;
//	
//	// 7. Write service registration registers
//	If vServiceRegistrationWrite Тогда
//		RegisterRecords.РегистрацияУслуги.Write();
//	EndIf;
//КонецПроцедуры //ChargeServices
//
////-----------------------------------------------------------------------------
//Процедура pmSetCurrentFolio(pServices) Экспорт
//	For Each vSrvRow In pServices Do
//		// Set current service folio
//		If ЗначениеЗаполнено(ChargingFolio) Тогда
//			vSrvRow.СчетПроживания = ChargingFolio;
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmSetCurrentFolio
//
////-----------------------------------------------------------------------------
//Процедура FillFolioParameters(pCancel)
//	// Set parameters of the charging folio
//	If ЗначениеЗаполнено(ChargingFolio) Тогда
//		If ЗначениеЗаполнено(ChargingFolio.ParentDoc) And 
//		  (TypeOf(ChargingFolio.ParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(ChargingFolio.ParentDoc) = Type("DocumentRef.Reservation")) Тогда
//			Return;
//		EndIf;
//		vFolioRef = ChargingFolio;
//		vFolioObj = vFolioRef.GetObject();
//		vFolioIsChanged = False;
//		If vFolioObj.ВалютаЛицСчета <> FolioCurrency Тогда
//			vFolioObj.ВалютаЛицСчета = FolioCurrency;
//			vFolioIsChanged = True;
//		EndIf;
//		If НЕ ChargingFolio.IsMaster Тогда
//			If vFolioObj.Гостиница <> Гостиница Тогда
//				vFolioObj.Гостиница = Гостиница;
//				vFolioIsChanged = True;
//			EndIf;
//			If НЕ vFolioObj.DoNotUpdateCompany Тогда
//				If vFolioObj.Фирма <> Фирма Тогда
//					vFolioObj.Фирма = Фирма;
//					vFolioIsChanged = True;
//				EndIf;
//			EndIf;
//			If vFolioObj.ДокОснование <> ThisObject.Ref Тогда
//				vFolioObj.ДокОснование = ThisObject.Ref;
//				vFolioIsChanged = True;
//			EndIf;
//			If ЗначениеЗаполнено(Owner) Тогда
//				If TypeOf(Owner) = Type("CatalogRef.Договора") Тогда
//					If vFolioObj.Контрагент <> Owner.Owner Or vFolioObj.Договор <> Owner Тогда
//						vFolioObj.Контрагент = Owner.Owner;
//						vFolioObj.Договор = Owner;
//						vFolioIsChanged = True;
//					EndIf;
//				Else
//					If vFolioObj.Контрагент <> Owner Тогда
//						vFolioObj.Контрагент = Owner;
//						vFolioObj.Договор = Справочники.Договора.EmptyRef();
//						vFolioIsChanged = True;
//					EndIf;
//				EndIf;
//			Else
//				If vFolioObj.Контрагент <> Owner Тогда
//					vFolioObj.Контрагент = Контрагент;
//					vFolioIsChanged = True;
//				EndIf;
//				If vFolioObj.Договор <> Contract Тогда
//					vFolioObj.Договор = Contract;
//					vFolioIsChanged = True;
//				EndIf;
//			EndIf;
//			If vFolioObj.Агент <> Agent Тогда
//				vFolioObj.Агент = Agent;
//				vFolioIsChanged = True;
//			EndIf;
//			If vFolioObj.ГруппаГостей <> GuestGroup Тогда
//				vFolioObj.ГруппаГостей = GuestGroup;
//				vFolioIsChanged = True;
//			EndIf;
//			If vFolioObj.Клиент <> Client Тогда
//				vFolioObj.Клиент = Client;
//				vFolioIsChanged = True;
//			EndIf;
//			If vFolioObj.DateTimeFrom <> DateTimeFrom Тогда
//				vFolioObj.DateTimeFrom = DateTimeFrom;
//				vFolioIsChanged = True;
//			EndIf;
//			If vFolioObj.DateTimeTo <> DateTimeTo Тогда
//				vFolioObj.DateTimeTo = DateTimeTo;
//				vFolioIsChanged = True;
//			EndIf;
//			If ЗначениеЗаполнено(PlannedPaymentMethod) Тогда
//				If vFolioObj.СпособОплаты <> PlannedPaymentMethod Тогда
//					vFolioObj.СпособОплаты = PlannedPaymentMethod;
//					vFolioIsChanged = True;
//				EndIf;
//			EndIf;
//			If ЗначениеЗаполнено(ResourceReservationStatus) Тогда
//				If НЕ ResourceReservationStatus.IsActive Or 
//				   ResourceReservationStatus.ServicesAreDelivered Тогда
//					If НЕ vFolioObj.IsClosed Тогда
//						// Check that there is no other active documents referencing this folio
//						vFolioDocs = cmGetActiveFolioDocuments(vFolioObj.Ref, Ref);
//						// Close folio
//						If vFolioDocs.Count() = 0 Тогда
//							vFolioObj.IsClosed = True;
//							vFolioIsChanged = True;
//						EndIf;
//					EndIf;
//				Else
//					If vFolioObj.IsClosed Тогда
//						// Open folio
//						vFolioObj.IsClosed = False;
//						vFolioIsChanged = True;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//		If vFolioIsChanged Тогда
//			vFolioObj.Write(DocumentWriteMode.Write);
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillFolioParameters
//
////-----------------------------------------------------------------------------
//Процедура SetFolioStatuses(pCancel)
//	If НЕ ResourceReservationStatus.IsActive Or 
//	   ResourceReservationStatus.ServicesAreDelivered Тогда
//		// Close all folios of the current document
//		vFolios = cmGetActiveDocumentFolios(Ref);
//		For Each vFoliosRow In vFolios Do
//			If ЗначениеЗаполнено(vFoliosRow.СчетПроживания) Тогда
//				If НЕ vFoliosRow.СчетПроживания.IsMaster Тогда
//					vFolioRef = vFoliosRow.СчетПроживания;
//					// Check that there is no other active documents referencing this folio
//					vFolioDocs = cmGetActiveFolioDocuments(vFolioRef, Ref);
//					If НЕ vFolioRef.IsClosed Тогда
//						// Close folio
//						If vFolioDocs.Count() = 0 Тогда
//							vFolioObj = vFolioRef.GetObject();
//							vFolioObj.IsClosed = True;
//							vFolioObj.Write(DocumentWriteMode.Write);
//						EndIf;
//					Else
//						// Open folio
//						If vFolioDocs.Count() > 0 Тогда
//							vFolioObj = vFolioRef.GetObject();
//							vFolioObj.IsClosed = False;
//							vFolioObj.Write(DocumentWriteMode.Write);
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//		// Check should we close guest group folios or not
//		If ЗначениеЗаполнено(GuestGroup) And GuestGroup.ChargingRules.Count() > 0 Тогда
//			vActiveGroupDocs = cmGetActiveGuestGroupDocuments(GuestGroup);
//			If vActiveGroupDocs.Count() = 0 Тогда
//				For Each vGGCRRow In GuestGroup.ChargingRules Do
//					If ЗначениеЗаполнено(vGGCRRow.ChargingFolio) And НЕ vGGCRRow.ChargingFolio.IsClosed Тогда
//						vFolioObj = vGGCRRow.ChargingFolio.GetObject();
//						vFolioObj.IsClosed = True;
//						vFolioObj.Write(DocumentWriteMode.Write);
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//	Else
//		// Activate all folios of the current document
//		vFolios = cmGetInactiveDocumentFolios(Ref);
//		For Each vFoliosRow In vFolios Do
//			If ЗначениеЗаполнено(vFoliosRow.СчетПроживания) Тогда
//				If НЕ vFoliosRow.СчетПроживания.IsMaster Тогда
//					vFolioRef = vFoliosRow.СчетПроживания;
//					If vFolioRef.IsClosed Тогда
//						vFolioObj = vFolioRef.GetObject();
//						vFolioObj.IsClosed = False;
//						vFolioObj.Write(DocumentWriteMode.Write);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//		// Check should we open guest group folios or not
//		If ЗначениеЗаполнено(GuestGroup) And GuestGroup.ChargingRules.Count() > 0 Тогда
//			For Each vGGCRRow In GuestGroup.ChargingRules Do
//				If ЗначениеЗаполнено(vGGCRRow.ChargingFolio) And vGGCRRow.ChargingFolio.IsClosed Тогда
//					vFolioObj = vGGCRRow.ChargingFolio.GetObject();
//					vFolioObj.IsClosed = False;
//					vFolioObj.Write(DocumentWriteMode.Write);
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//КонецПроцедуры //SetFolioStatuses
//
////-----------------------------------------------------------------------------
//Процедура MoveClients(pCancel, pPostingMode)
//	If ЗначениеЗаполнено(Client) Тогда
//		vDoWrite = False;
//		vClientObj = Неопределено;
//		If ЗначениеЗаполнено(ResourceReservationStatus) Тогда
//			If ResourceReservationStatus.IsActive Тогда
//				If Client.Parent <> Справочники.Клиенты.ReservedGuests And 
//				   Client.Parent <> Справочники.Клиенты.BlackListPersons And
//				   Client.Parent <> Справочники.Клиенты.CheckedInGuests Тогда
//					vClientObj = Client.GetObject();
//					vClientObj.Parent = Справочники.Клиенты.ReservedGuests;
//					vDoWrite = True;
//				EndIf;
//			EndIf;
//		EndIf;
//		If НЕ IsBlankString(Phone) And IsBlankString(Client.Телефон) Тогда
//			If НЕ vDoWrite Тогда
//				vClientObj = Client.GetObject();
//			EndIf;
//			vClientObj.Телефон = TrimAll(Phone);
//			vDoWrite = True;
//		EndIf;
//		If НЕ IsBlankString(Fax) And IsBlankString(Client.Fax) Тогда
//			If НЕ vDoWrite Тогда
//				vClientObj = Client.GetObject();
//			EndIf;
//			vClientObj.Fax = TrimAll(Fax);
//			vDoWrite = True;
//		EndIf;
//		If НЕ IsBlankString(EMail) And IsBlankString(Client.EMail) Тогда
//			If НЕ vDoWrite Тогда
//				vClientObj = Client.GetObject();
//			EndIf;
//			vClientObj.EMail = TrimAll(EMail);
//			vDoWrite = True;
//		EndIf;
//		If vDoWrite Тогда
//			vClientObj.Write();
//			vClientObj.pmWriteToClientChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//		EndIf;
//	EndIf;
//КонецПроцедуры //MoveClients
//
////-----------------------------------------------------------------------------
//Function pmGetResourceReservationHistoryState(pPeriod) Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	*
//	|FROM
//	|	InformationRegister.ResourceReservationChangeHistory.SliceLast(&qPeriod, БроньУслуг = &qResourceReservation) AS ResourceReservationChangeHistorySliceLast";
//	vQry.SetParameter("qPeriod", pPeriod);
//	vQry.SetParameter("qResourceReservation", Ref);
//	vResStates = vQry.Execute().Unload();
//	Return vResStates;
//EndFunction //pmGetResourceReservationHistoryState
//
////-----------------------------------------------------------------------------
//Процедура FillGroupParameters()
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		// Контрагент
//		vUpdateCustomer = False;
//		If GuestGroup.OneCustomerPerGuestGroup Тогда
//			If GuestGroup.Контрагент <> Контрагент Тогда
//				vUpdateCustomer = True;
//			EndIf;
//		EndIf;
//		// Client
//		vUpdateClient = False;
//		If ЗначениеЗаполнено(Client) And НЕ GuestGroup.FixedClient Тогда
//			If НЕ ЗначениеЗаполнено(GuestGroup.Client) Тогда
//				vUpdateClient = True;
//			EndIf;
//		EndIf;
//		// Client document
//		vUpdateClientDoc = False;
//		If НЕ ЗначениеЗаполнено(GuestGroup.ClientDoc) Or 
//		   ЗначениеЗаполнено(GuestGroup.ClientDoc) And TypeOf(GuestGroup.ClientDoc) = Type("DocumentRef.БроньУслуг") And 
//		   GuestGroup.FixedClient And ЗначениеЗаполнено(GuestGroup.Client) And GuestGroup.Client = Client Тогда
//			vUpdateClientDoc = True;
//		EndIf;
//		// Group status
//		vUpdateGroupStatus = False;
//		vGuestGroupStatus = cmGetGuestGroupStatus(GuestGroup);
//		If GuestGroup.Status <> vGuestGroupStatus Тогда
//			vUpdateGroupStatus = True;
//		EndIf;
//		// Group period and number of guests checked-in
//		vUpdatePeriod = False;
//		vGroupParams = cmGetGroupPeriodAndGuestsCheckedIn(GuestGroup);
//		If vGroupParams.Count() = 0 Тогда
//			If DateTimeFrom < GuestGroup.CheckInDate Or
//			   DateTimeTo > GuestGroup.CheckOutDate Or 
//			   НЕ ЗначениеЗаполнено(GuestGroup.CheckInDate) Тогда
//				vUpdatePeriod = True;
//			EndIf;
//		EndIf;
//		// Update guest group
//		If vUpdateCustomer Or vUpdateClient Or vUpdateClientDoc Or vUpdateGroupStatus Or vUpdatePeriod Тогда
//			vGroupObj = GuestGroup.GetObject();
//			If vUpdateCustomer Тогда
//				vGroupObj.Контрагент = Контрагент;
//			EndIf;
//			If vUpdateClient Тогда
//				vGroupObj.Клиент = Client;
//				vGroupObj.ClientDoc = Ref;
//			ElsIf vUpdateClientDoc Тогда
//				vGroupObj.ClientDoc = Ref;
//			EndIf;
//			If vUpdatePeriod Тогда
//				If DateTimeFrom < GuestGroup.CheckInDate Or НЕ ЗначениеЗаполнено(GuestGroup.CheckInDate) Тогда
//					vGroupObj.CheckInDate = DateTimeFrom;
//				EndIf;
//				If DateTimeTo > GuestGroup.CheckOutDate Тогда
//					vGroupObj.CheckOutDate = DateTimeTo;
//				EndIf;
//				vGroupObj.Продолжительность = cmCalculateDuration(, vGroupObj.CheckInDate, vGroupObj.CheckOutDate);
//			EndIf;
//			If vUpdateGroupStatus Тогда
//				vGroupObj.Status = vGuestGroupStatus;
//			EndIf;
//			vGroupObj.Write();
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillGroupParameters
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pPostingMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Add data locks
//	vDataLock = New DataLock();
//	If ЗначениеЗаполнено(Resource) Тогда
//		vResItem = vDataLock.Add("Catalog.Ресурсы");
//		vResItem.Mode = DataLockMode.Exclusive;
//		vResItem.SetValue("Ref", Resource);
//	EndIf;
//	If vDataLock.Count() > 0 Тогда
//		vDataLock.Lock();
//	EndIf;
//	// Clear register records
//	RegisterRecords.ИсторияБрониРесурсов.Clear();
//	RegisterRecords.ПрогнозПродаж.Clear();
//	RegisterRecords.ПрогнозРеализации.Clear();
//	// Fill folio parameters
//	If ResourceReservationStatus.IsActive Тогда
//		FillFolioParameters(pCancel);
//	EndIf;
//	SetFolioStatuses(pCancel);
//	// Post to registers
//	PostToRegisters(pCancel);
//	If НЕ pCancel Тогда
//		pCancel	= pmCheckDocumentAttributes(True, vMessage, vAttributeInErr);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//	Else
//		Return;
//	EndIf;
//	// Post to expected Контрагент sales. Those records are used to compare charged guest group services with planned ones
//	If ResourceReservationStatus.IsActive Тогда
//		If DoCharging Тогда
//			PostToExpectedCustomerSales(pCancel);
//		EndIf;
//	EndIf;
//	// Post services if necessary
//	ChargeServices(pCancel, pPostingMode);
//	// Move guests to the appropriate folder
//	MoveClients(pCancel, pPostingMode);
//	// Fill head of group, group Контрагент, group period and number of clients
//	FillGroupParameters();
//	// Check should we update Контрагент/contract/agent/planned payment method in all resource reservations of the same guest group
//	If GuestGroup.OneCustomerPerGuestGroup Тогда
//		vResDocs = GuestGroup.GetObject().pmGetResourceReservations();
//		For Each vResDocsRow In vResDocs Do
//			vCurReservation = vResDocsRow.Reservation;
//			If vCurReservation <> Ref Тогда
//				vResourceReservationIsChanged = False;
//				If vCurReservation.Контрагент <> Контрагент Or
//				   vCurReservation.Договор <> Contract Or
//				   vCurReservation.КонтактноеЛицо <> ContactPerson Or
//				   vCurReservation.PlannedPaymentMethod <> PlannedPaymentMethod Or
//				   vCurReservation.Owner <> Owner Or
//				   vCurReservation.Скидка <> Discount Or
//				   vCurReservation.ТипСкидки <> DiscountType Or
//				   vCurReservation.ОснованиеСкидки <> DiscountConfirmationText Or
//				   vCurReservation.DiscountServiceGroup <> DiscountServiceGroup Or
//				   vCurReservation.ДисконтКарт <> DiscountCard Or
//				   vCurReservation.TurnOffAutomaticDiscounts <> TurnOffAutomaticDiscounts Тогда
//					vResourceReservationIsChanged = True;
//				EndIf;
//				If vResourceReservationIsChanged Тогда
//					vCurReservationObj = vCurReservation.GetObject();
//					vCurReservationObj.Контрагент = Контрагент;
//					vCurReservationObj.Договор = Contract;
//					vCurReservationObj.КонтактноеЛицо = ContactPerson;
//					vCurReservationObj.Агент = Agent;
//					vCurReservationObj.Owner = Owner;
//					vCurReservationObj.PlannedPaymentMethod = PlannedPaymentMethod;
//					vCurReservationObj.Скидка = Discount;
//					vCurReservationObj.ТипСкидки = DiscountType;
//					vCurReservationObj.ОснованиеСкидки = DiscountConfirmationText;
//					vCurReservationObj.DiscountServiceGroup = DiscountServiceGroup;
//					vCurReservationObj.ДисконтКарт = DiscountCard;
//					vCurReservationObj.TurnOffAutomaticDiscounts = TurnOffAutomaticDiscounts;
//					// Recalculate services
//					vCurReservationObj.pmCalculateServices();
//					// Post document
//					vCurReservationObj.Write(DocumentWriteMode.Posting);
//					// Save data to the document history
//					vCurReservationObj.pmWriteToResourceReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //Posting
//
////-----------------------------------------------------------------------------
//Процедура pmUndoPosting(pCancel) Экспорт
//	// Build table of already charged services and then delete all (or future) chargings 
//	vChargesTab = cmGetTableOfAlreadyChargedServices(ThisObject.Ref);
//	For Each vChargesRec In vChargesTab Do
//		vChargeObj = vChargesRec.Ref.GetObject();
//		If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//			vChargeObj.SetDeletionMark(True);
//		EndIf;
//	EndDo;
//КонецПроцедуры //UndoPosting
//
////-----------------------------------------------------------------------------
//Процедура UndoPosting(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Check user permissions to change status
//	If НЕ cmCheckUserPermissions("HavePermissionToEditResourceReservations") Тогда
//		If (НЕ ЗначениеЗаполнено(Автор.Отдел) And Автор <> ПараметрыСеанса.ТекПользователь Or 
//		   ЗначениеЗаполнено(Автор.Отдел) And Автор <> ПараметрыСеанса.ТекПользователь And 
//		   ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Отдел) And 
//		   Автор.Отдел <> ПараметрыСеанса.ТекПользователь.Отдел) Тогда
//			ВызватьИсключение NStr("en='You do not have rights to edit resource reservations!'; ru='У вас нет прав на редактирование брони ресурсов!'; de='Es gibt keine Rechte, die Ressourcenbuchungen zu editieren!'");
//		EndIf;
//	EndIf;
//	If НЕ cmCheckUserPermissions("HavePermissionToEditClosedForEditDocuments") Тогда
//		If IsClosedForEdit Тогда
//			ВызватьИсключение NStr("en='You do not have rights to change closed for edit document!';ru='У вас нет прав на изменение документа с включенным запретом редактирования!';de='Sie haben keine Rechte, das Dokument zu bearbeiten mit eingeschlossenem Bearbeitungsverbot!'");
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ResourceReservationStatus) And ResourceReservationStatus.ServicesAreDelivered Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToEditCompletedResourceReservations") Тогда
//			ВызватьИсключение NStr("en='You do not have rights to edit completed resource reservations where services are delivered!'; ru='У вас нет прав на редактирование завершенной брони ресурсов по которой все услуги оказаны!'; de='Es gibt keine Rechte, die geschlossen Ressourcenbuchungen zu editieren!'");
//		EndIf;
//	EndIf;
//	// Remove charges
//	pmUndoPosting(pCancel)
//КонецПроцедуры //UndoPosting
//
////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Remove charges
//	If Posted Тогда
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And DoCharging And 
//		  (Services.Total("Сумма") <> 0 Or Services.Total("Количество") <> 0) And 
//		   ЗначениеЗаполнено(ResourceReservationStatus) And ResourceReservationStatus.ServicesAreDelivered And 
//		   cmGetDocumentCharges(Ref, Неопределено, Неопределено, Гостиница, Неопределено, True).Count() > 0 Тогда
//			vDocBalanceIsZero = False;
//			vDocBalancesRow = cmGetDocumentCurrentAccountsReceivableBalance(Ref);
//			If vDocBalancesRow <> Неопределено Тогда
//				If vDocBalancesRow.SumBalance = 0 And vDocBalancesRow.QuantityBalance = 0 Тогда
//					vDocBalanceIsZero = True;
//				EndIf;
//			Else
//				vDocBalanceIsZero = True;
//			EndIf;
//			If vDocBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='All resource reservation charges are closed by settlements! Resource reservation is read only.';
//				             |ru='Все начисления брони ресурсов уже закрыты актами об оказании услуг! Редактирование такой брони запрещено.';
//							 |de='Alle Anrechnungen der Ressourcenreservierung wurden bereits durch Übergabeprotokolle über die Dienstleistungserbringung geschlossen! Die Bearbeitung einer solchen Reservierung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		pmUndoPosting(pCancel);
//	EndIf;
//КонецПроцедуры //BeforeDelete
//
////-----------------------------------------------------------------------------
//Процедура FillRChgAttributes(pRChgRec, pPeriod, pUser)
//	FillPropertyValues(pRChgRec, ThisObject);
//	
//	pRChgRec.Period = pPeriod;
//	pRChgRec.БроньУслуг = ThisObject.Ref;
//	pRChgRec.User = pUser;
//	
//	// Store tabular parts
//	vServicePackages = New ValueStorage(ServicePackages.Unload());
//	pRChgRec.ПакетыУслуг = vServicePackages;
//	vServices = New ValueStorage(Services.Unload());
//	pRChgRec.Услуги = vServices;
//КонецПроцедуры //FillRChgAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmWriteToResourceReservationChangeHistory(pPeriod, pUser) Экспорт
//	// Get channges description
//	vChanges = cmGetObjectChanges(ThisObject);
//	If НЕ IsBlankString(vChanges) Тогда
//		// Do movement on current date
//		vRChgRec = InformationRegisters.ИсторияИзмБрониРесурсов.CreateRecordManager();
//		
//		FillRChgAttributes(vRChgRec, pPeriod, pUser);
//		vRChgRec.Changes = vChanges;
//		
//		// Write record
//		vRChgRec.Write(True);
//	EndIf;
//КонецПроцедуры //pmWriteToResourceReservationChangeHistory
//
////-----------------------------------------------------------------------------
//Процедура pmRestoreAttributesFromHistory(pRChgRec) Экспорт
//	FillPropertyValues(ThisObject, pRChgRec, , "Number, Date, Автор");
//	If НЕ IsBlankString(pRChgRec.НомерДока) Тогда
//		Number = pRChgRec.НомерДока;
//	EndIf;
//	If ЗначениеЗаполнено(pRChgRec.ДатаДок) Тогда
//		Date = pRChgRec.ДатаДок;
//	EndIf;
//	If ЗначениеЗаполнено(pRChgRec.Автор) Тогда
//		Автор = pRChgRec.Автор;
//	EndIf;
//	// Restore tabular parts
//	vServicePackages = pRChgRec.ПакетыУслуг.Get();
//	If vServicePackages <> Неопределено Тогда
//		ServicePackages.Load(vServicePackages);
//	Else
//		ServicePackages.Clear();
//	EndIf;
//	vServices = pRChgRec.Услуги.Get();
//	If vServices <> Неопределено Тогда
//		Services.Load(vServices);
//	Else
//		Services.Clear();
//	EndIf;
//КонецПроцедуры //pmRestoreAttributesFromHistory
//
////-----------------------------------------------------------------------------
//Function pmGetPreviousObjectState(pPeriod) Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	*
//	|FROM
//	|	InformationRegister.ResourceReservationChangeHistory.SliceLast(&qPeriod, БроньУслуг = &qDoc) AS ResourceReservationChangeHistory";
//	vQry.SetParameter("qPeriod", pPeriod);
//	vQry.SetParameter("qDoc", Ref);
//	vStates = vQry.Execute().Unload();
//	If vStates.Count() > 0 Тогда
//		Return vStates.Get(0);
//	Else
//		Return Неопределено;
//	EndIf;
//EndFunction //pmGetPreviousObjectState
//
////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pIsPosted, pMessage, pAttributeInErr, pDoNotCheckRests = False) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//	vMsgTextEn = "";
//	vMsgTextDe = "";
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Фирма) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Фирма> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Фирма> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Фирма> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Фирма", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата курса> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ReportingCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Отчетная валюта> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Reporting Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Reporting Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Валюта", pAttributeInErr);
//	EndIf;
//	If ReportingCurrencyExchangeRate <= 0 Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Курс отчетной валюты> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Reporting Валюта exchange rate> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Reporting Валюта exchange rate> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ReportingCurrencyExchangeRate", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(GuestGroup) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения группы> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Клиент group> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Клиент group> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ГруппаГостей", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ResourceReservationStatus) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Статус брони> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Reservation status> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Reservation status> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ResourceReservationStatus", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ChargingFolio) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Лицевой счет> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ChargingFolio", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(FolioCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта лицевого счета> должна быть заполнена!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ВалютаЛицСчета", pAttributeInErr);
//	EndIf;
//	If FolioCurrencyExchangeRate = 0 Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Курс валюты лицевого счета> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания Валюта exchange rate> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания Валюта exchange rate> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "FolioCurrencyExchangeRate", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(DateTimeFrom) And ЗначениеЗаполнено(DateTimeTo) Тогда
//		If DateTimeFrom > DateTimeTo Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Время окончания брони должно быть позже времени начала брони!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Reservation period to should be after reservation period from time!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Reservation period to should be after reservation period from time!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "DateTimeTo", pAttributeInErr);
//		Else
//			If ЗначениеЗаполнено(Contract) Тогда
//				If Contract.PeriodCheckType = 0 Тогда
//					If ЗначениеЗаполнено(Contract.ValidFromDate) And 
//					   DateTimeFrom < BegOfDay(Contract.ValidFromDate) Or
//					   ЗначениеЗаполнено(Contract.ValidToDate) And
//					   DateTimeFrom > EndOfDay(Contract.ValidToDate) Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Выбранный договор не действует на указанном периоде брони!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "Договор is not valid on period selected!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "Договор is not valid on period selected!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "Договор", pAttributeInErr);
//					EndIf;
//				ElsIf Contract.PeriodCheckType = 1 Тогда
//					If ЗначениеЗаполнено(Contract.ValidFromDate) And 
//					   Date < BegOfDay(Contract.ValidFromDate) Or
//					   ЗначениеЗаполнено(Contract.ValidToDate) And
//					   Date > EndOfDay(Contract.ValidToDate) Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Выбранный договор не действует на дату создания брони!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "Договор is not valid on reservation creation date!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "Договор is not valid on reservation creation date!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "Договор", pAttributeInErr);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ResourceReservationStatus) Тогда
//		If ResourceReservationStatus.IsActive Тогда
//			// Check resource availability
//			If ЗначениеЗаполнено(Resource) And НЕ pDoNotCheckRests Тогда
//				// Check resource
//				If НЕ cmCheckResourceAvailability(Resource, ThisObject.Ref, pIsPosted, 
//												   DateTimeFrom, DateTimeTo, vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//					vHasErrors = True; 
//					pAttributeInErr = ?(pAttributeInErr = "", "DateTimeFrom", pAttributeInErr);
//				EndIf;
//				// Check child resources
//				vChildren = Resource.GetObject().pmGetResourceChildren();
//				For Each vChildrenRow In vChildren Do
//					If НЕ cmCheckResourceAvailability(vChildrenRow.Ресурс, ThisObject.Ref, pIsPosted, 
//													   DateTimeFrom, DateTimeTo, vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//						vHasErrors = True; 
//						pAttributeInErr = ?(pAttributeInErr = "", "DateTimeFrom", pAttributeInErr);
//					EndIf;
//				EndDo;
//				// Check parent resource
//				vParentResource = Resource.Parent;
//				If ЗначениеЗаполнено(vParentResource) Тогда
//					If НЕ cmCheckResourceAvailability(vParentResource, ThisObject.Ref, pIsPosted, 
//													   DateTimeFrom, DateTimeTo, vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//						vHasErrors = True; 
//						pAttributeInErr = ?(pAttributeInErr = "", "DateTimeFrom", pAttributeInErr);
//					EndIf;
//				EndIf;
//			EndIf;
//			// Check services
//			If НЕ pDoNotCheckRests Тогда
//				For Each vSrvRow In Services Do
//					If ЗначениеЗаполнено(vSrvRow.ServiceResource) And TypeOf(vSrvRow.ServiceResource) = Type("CatalogRef.Ресурсы") And vSrvRow.DoResourceReservation Тогда
//						vDateTimeFrom = vSrvRow.AccountingDate + (vSrvRow.TimeFrom - BegOfDay(vSrvRow.TimeFrom));
//						vDateTimeTo = vSrvRow.AccountingDate + (vSrvRow.TimeTo - BegOfDay(vSrvRow.TimeTo));
//						// Check service resource
//						If НЕ cmCheckResourceAvailability(vSrvRow.ServiceResource, ThisObject.Ref, pIsPosted, 
//														   vDateTimeFrom, vDateTimeTo, vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//							vHasErrors = True; 
//							pAttributeInErr = ?(pAttributeInErr = "", "Услуги", pAttributeInErr);
//						EndIf;
//						// Check child resources
//						vChildren = vSrvRow.ServiceResource.GetObject().pmGetResourceChildren();
//						For Each vChildrenRow In vChildren Do
//							If НЕ cmCheckResourceAvailability(vChildrenRow.Ресурс, ThisObject.Ref, pIsPosted, 
//															   vDateTimeFrom, vDateTimeTo, vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//								vHasErrors = True; 
//								pAttributeInErr = ?(pAttributeInErr = "", "Услуги", pAttributeInErr);
//							EndIf;
//						EndDo;
//						// Check parent resource
//						vParentResource = vSrvRow.ServiceResource.Parent;
//						If ЗначениеЗаполнено(vParentResource) Тогда
//							If НЕ cmCheckResourceAvailability(vParentResource, ThisObject.Ref, pIsPosted, 
//															   vDateTimeFrom, vDateTimeTo, vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//								vHasErrors = True; 
//								pAttributeInErr = ?(pAttributeInErr = "", "Услуги", pAttributeInErr);
//							EndIf;
//						EndIf;
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check services
//	For Each vSrvRow In Services Do
//		If vSrvRow.Price <> 0 And vSrvRow.Sum = 0 Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В строке услуг №" + Format(vSrvRow.LineNumber, "ND=10; NFD=0; NG=") + " указана цена, но не рассчитана сума услуги!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Услуга with line number " + Format(vSrvRow.LineNumber, "ND=10; NFD=0; NG=") + " has Цена but Услуга amount is not calculated!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Услуга with line number " + Format(vSrvRow.LineNumber, "ND=10; NFD=0; NG=") + " has Цена but Услуга amount is not calculated!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Услуги", pAttributeInErr);
//			Break;
//		EndIf;
//	EndDo;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmInitializePeriod() Экспорт
//	If НЕ ЗначениеЗаполнено(DateTimeFrom) Тогда
//		DateTimeFrom = (BegOfDay(Date) + 1) + 12*3600; // + 1 day
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DateTimeTo) Тогда
//		DateTimeTo = Date(Year(DateTimeFrom), Month(DateTimeFrom), Day(DateTimeFrom), 
//							Hour(DateTimeFrom), Minute(DateTimeFrom), 0) + Duration*3600;
//	EndIf;
//КонецПроцедуры //pmInitializePeriod
//
////-----------------------------------------------------------------------------
//// Calculates and returns duration for giving reservation start and end times
////-----------------------------------------------------------------------------
//Function pmCalculateDuration() Экспорт
//	Return cmCalculateDurationInHours(DateTimeFrom, DateTimeTo);
//EndFunction //pmCalculateDuration
//
////-----------------------------------------------------------------------------
//// Calculates and returns check out date based on giving duration and check in date
////-----------------------------------------------------------------------------
//Function pmCalculateDateTimeTo() Экспорт
//	vDateTimeTo = DateTimeTo;
//	If ЗначениеЗаполнено(DateTimeFrom) Тогда
//		vDateTimeTo = cm0SecondShift(DateTimeFrom + Duration*3600);
//	EndIf;
//	Return vDateTimeTo;
//EndFunction //pmCalculateDateTimeTo
//
////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Автор = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate
//
////-----------------------------------------------------------------------------
//Процедура pmCreateGuestGroup() Экспорт
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ Гостиница.AssignReservationGuestGroupsManually Тогда
//			vGuestGroupObj = Справочники.ГруппыГостей.CreateItem();
//			vGuestGroupObj.Owner = Гостиница;
//			vGuestGroupFolder = Гостиница.GetObject().pmGetGuestGroupFolder();
//			If ЗначениеЗаполнено(vGuestGroupFolder) Тогда
//				vGuestGroupObj.Parent = vGuestGroupFolder;
//				vGuestGroupObj.SetNewCode();
//			EndIf;
//			vGuestGroupObj.OneCustomerPerGuestGroup = Гостиница.OneCustomerPerGuestGroup;
//			vGuestGroupObj.Write();
//			// Fill document attribute
//			GuestGroup = vGuestGroupObj.Ref;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmCreateGuestGroup
//
////-----------------------------------------------------------------------------
//Процедура pmCreateFolio() Экспорт
//	// Check if resource is filled and check resource template folio
//	vTemplateFolio = Documents.СчетПроживания.EmptyRef();
//	If ЗначениеЗаполнено(Resource) And ЗначениеЗаполнено(Resource.TemplateFolio) Тогда
//		vTemplateFolio = Resource.TemplateFolio;
//	ElsIf ЗначениеЗаполнено(ResourceType) And ЗначениеЗаполнено(ResourceType.TemplateFolio) Тогда
//		vTemplateFolio = ResourceType.TemplateFolio;
//	EndIf;
//	If ЗначениеЗаполнено(vTemplateFolio) Тогда
//		vIsTemplate = НЕ vTemplateFolio.IsMaster;
//		If vIsTemplate Тогда
//			// Create new folio from template
//			vFolioObj = Documents.СчетПроживания.CreateDocument();
//			cmFillFolioFromTemplate(vFolioObj, vTemplateFolio, Гостиница, Date);
//			vFolioObj.ДокОснование = ThisObject.Ref;
//			vFolioObj.Write(DocumentWriteMode.Write);
//			
//			// Fill document charging folio
//			ChargingFolio = vFolioObj.Ref;
//			FolioCurrency = vFolioObj.ВалютаЛицСчета;
//			FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ?(ЗначениеЗаполнено(ExchangeRateDate), ExchangeRateDate, Date));
//		Else
//			// Fill document charging folio
//			ChargingFolio = vTemplateFolio;
//			FolioCurrency = vTemplateFolio.FolioCurrency;
//			FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ?(ЗначениеЗаполнено(ExchangeRateDate), ExchangeRateDate, Date));
//		EndIf;
//		Return;
//	EndIf;
//	// Take hotel charging rules
//	vChargingRules = Неопределено;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If Гостиница.ChargingRules.Count() > 0 Тогда
//			vChargingRules = Гостиница.ChargingRules.Unload();
//		EndIf;
//	EndIf;
//	// Check list of template rules
//	If vChargingRules = Неопределено Тогда
//		// Create new folio and take parameters from the hotel
//		vFolioObj = Documents.СчетПроживания.CreateDocument();
//		cmFillFolioFromTemplate(vFolioObj, Неопределено, Гостиница, Date);
//		vFolioObj.ДокОснование = ThisObject.Ref;
//		vFolioObj.Write(DocumentWriteMode.Write);
//		
//		// Fill document charging folio
//		ChargingFolio = vFolioObj.Ref;
//		FolioCurrency = vFolioObj.ВалютаЛицСчета;
//		FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ?(ЗначениеЗаполнено(ExchangeRateDate), ExchangeRateDate, Date));
//	Else
//		For Each vRule In vChargingRules Do
//			vIsTemplate = True;
//			vTemplateFolio = vRule.ChargingFolio;
//			If ЗначениеЗаполнено(vTemplateFolio) Тогда
//				vIsTemplate = НЕ vTemplateFolio.IsMaster;
//			EndIf;
//			If vIsTemplate Тогда
//				// Create new folio from template
//				vFolioObj = Documents.СчетПроживания.CreateDocument();
//				cmFillFolioFromTemplate(vFolioObj, vTemplateFolio, Гостиница, Date);
//				vFolioObj.ДокОснование = ThisObject.Ref;
//				vFolioObj.Write(DocumentWriteMode.Write);
//				
//				// Fill document charging folio
//				ChargingFolio = vFolioObj.Ref;
//				FolioCurrency = vFolioObj.ВалютаЛицСчета;
//				FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ?(ЗначениеЗаполнено(ExchangeRateDate), ExchangeRateDate, Date));
//			Else
//				// Fill document charging folio
//				ChargingFolio = vRule.ChargingFolio;
//				FolioCurrency = vRule.ChargingFolio.ВалютаЛицСчета;
//				FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ?(ЗначениеЗаполнено(ExchangeRateDate), ExchangeRateDate, Date));
//			EndIf;
//			Break;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmCreateFolio
//
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill author and document date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ ЗначениеЗаполнено(Фирма) Тогда
//			Фирма = Гостиница.Фирма;
//		EndIf;
//		If ЗначениеЗаполнено(Автор) And ЗначениеЗаполнено(Автор.Фирма) Тогда
//			Фирма = Автор.Фирма;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(ResourceReservationStatus) Тогда
//			ResourceReservationStatus = Гостиница.NewResourceReservationStatus;
//			If ЗначениеЗаполнено(ResourceReservationStatus) Тогда
//				DoCharging = ResourceReservationStatus.DoCharging;
//			EndIf;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(PlannedPaymentMethod) Тогда
//			PlannedPaymentMethod = Гостиница.PlannedPaymentMethod;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(ReportingCurrency) Тогда
//			ReportingCurrency = Гостиница.ReportingCurrency;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(Owner) Тогда
//			If ЗначениеЗаполнено(Гостиница.IndividualsContract) Тогда
//				Owner = Гостиница.IndividualsContract;
//			ElsIf ЗначениеЗаполнено(Гостиница.IndividualsCustomer) Тогда
//				Owner = Гостиница.IndividualsCustomer;
//			EndIf;
//		EndIf;
//		ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, Date);
//		// Initialize document period
//		pmInitializePeriod();
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		ExchangeRateDate = Date;
//	EndIf;
//	// Create guest group if is new
//	If НЕ ЗначениеЗаполнено(GuestGroup) Тогда
//		pmCreateGuestGroup();
//	EndIf;
//	// Create charging folio if is new
//	If НЕ ЗначениеЗаполнено(ChargingFolio) Тогда
//		pmCreateFolio();
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetAccumulatingDiscountResources() Экспорт
//	// Initialize map with resources
//	vRes = New ValueTable();
//	vRes.Columns.Add("ТипСкидки", cmGetCatalogTypeDescription("ТипыСкидок"), "Скидка type", 20);
//	vRes.Columns.Add("ИзмерениеСкидки", cmGetDiscountDimensionTypeDescription(), "Скидка dimension", 20);
//	vRes.Columns.Add("Ресурс", cmGetAccumulatingDiscountResourceTypeDescription(), "Скидка Ресурс", 20);
//	vRes.Columns.Add("Бонус", cmGetAccumulatingDiscountResourceTypeDescription(), "Бонус", 20);
//	// Get list of accumulating discount types defined in the catalog
//	vAccDisTypes = cmGetAccumulatingDiscountTypes(DiscountType);
//	// Get resources
//	For Each vAccDisType In vAccDisTypes Do
//		vDiscountType = vAccDisType.ТипСкидки;
//		vDiscountTypeObj = vDiscountType.GetObject();
//		vAccDisRes = vDiscountTypeObj.pmGetAccumulatingDiscountResources(BegOfDay(DateTimeFrom),
//		                                                                 Контрагент,
//		                                                                 Contract,
//		                                                                 Client,
//		                                                                 DiscountCard,
//		                                                                 ?(vDiscountType.IsPerVisit, GuestGroup, Неопределено));
//		If vAccDisRes.Count() = 0 Тогда
//			vResRow = vRes.Add();
//			vResRow.ТипСкидки = vDiscountType;
//			vResRow.ИзмерениеСкидки = vDiscountTypeObj.pmGetDefaultAccumulatingDiscountDimension();
//			vResRow.Ресурс = 0;
//			vResRow.Бонус = 0;
//		Else
//			For Each vAccDis In vAccDisRes Do
//				vResRow = vRes.Add();
//				vResRow.ТипСкидки = vAccDis.ТипСкидки;
//				vResRow.ИзмерениеСкидки = vAccDis.ИзмерениеСкидки;
//				vResRow.Ресурс = vAccDis.Ресурс;
//				vResRow.Бонус = vAccDis.Бонус;
//			EndDo;
//		EndIf;
//	EndDo;
//	// Return
//	Return vRes;
//EndFunction //pmGetAccumulatingDiscountResources
//
////-----------------------------------------------------------------------------
//// Get reservation prices for all day types of ГруппаНомеров rate
////-----------------------------------------------------------------------------
//Function pmCalculatePricePresentation(Val pLang = Неопределено) Экспорт
//	vPricePresentation = "";
//	If pLang = Неопределено Тогда
//		pLang = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	vPrices = pmGetPrices();
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.UseMaximumPriceInPricePresentation Тогда
//		vMaxPrice = 0;
//		For Each vPrice In vPrices Do
//			If vPrice.Цена > vMaxPrice Тогда
//				vMaxPrice = vPrice.Цена;
//			EndIf;
//		EndDo;
//		vPricePresentation = cmFormatSum(vMaxPrice, FolioCurrency, "NZ=---", pLang);
//	Else
//		For Each vPrice In vPrices Do
//			If НЕ IsBlankString(vPricePresentation) Тогда
//				vPricePresentation = vPricePresentation + Chars.LF;
//			EndIf;
//			vPricePresentation = vPricePresentation + cmFormatSum(vPrice.Цена, FolioCurrency, "NZ=---", pLang) + 
//			                     ?(ЗначениеЗаполнено(vPrice.ТипДняКалендаря), " - " + vPrice.ТипДняКалендаря.GetObject().pmGetDayTypeDescription(pLang), "");
//		EndDo;
//	EndIf;
//	// Check length of price presentation
//	If StrLen(vPricePresentation) > 250 Тогда
//		vPricePresentation = Left(vPricePresentation, 247) + "...";
//	EndIf;
//	// Return
//	Return vPricePresentation;
//EndFunction //pmCalculatePricePresentation
//
////-----------------------------------------------------------------------------
//// Calculates services for the given document.
//// Returns False if warnings were rised during services calculation. Otherwise
//// returns True
////-----------------------------------------------------------------------------
//Function pmCalculateServices(rWarnings = "", pPeriodDiscount = 0, pPeriodDiscountType = Неопределено, 
//                                             pPeriodDiscountServiceGroup = Неопределено, pPeriodDiscountConfirmationText = "") Экспорт
//	// Fill period
//	vDateTimeFrom = DateTimeFrom;
//	vDateTimeTo = DateTimeTo;
//	// Save services with prices changed manually
//	vMCServices = Services.Unload();
//	i = 0;
//	While i < vMCServices.Count() Do
//		vSrv = vMCServices.Get(i);
//		If НЕ vSrv.IsManualPrice Тогда
//			vMCServices.Delete(i);
//		Else
//			i = i + 1;
//		EndIf;
//	EndDo;
//	// First clear services added automatically
//	i = 0;
//	While i < Services.Count() Do
//		vSrv = Services.Get(i);
//		If НЕ vSrv.IsManual Тогда
//			Services.Delete(i);
//		Else
//			vSrv.Фирма = Фирма;
//			i = i + 1;
//		EndIf;
//	EndDo;
//	// Check should we calculate services at all
//	If DoNotCalculateServices Тогда
//		Return False;
//	EndIf;
//	// Get list of accumulating discount types with actual resources
//	vAccDiscounts = pmGetAccumulatingDiscountResources();
//	// Initialize value of discount should be applied to the whole period
//	vPeriodDiscount = pPeriodDiscount;
//	vPeriodDiscountType = pPeriodDiscountType;
//	vPeriodDiscountServiceGroup = pPeriodDiscountServiceGroup;
//	vPeriodDiscountConfirmationText = pPeriodDiscountConfirmationText;
//	// Get list of price records for the given resource type and resource
//	vPrices = cmGetResourcePrices(Гостиница, vDateTimeFrom, vDateTimeTo, ClientType, ResourceType, Resource, ServicePackage, ServicePackages);
//	If ЗначениеЗаполнено(ClientType) And vPrices.Count() = 0 Тогда
//		vPrices = cmGetResourcePrices(Гостиница, vDateTimeFrom, vDateTimeTo, Справочники.ТипыКлиентов.EmptyRef(), ResourceType, Resource, ServicePackage, ServicePackages);
//	EndIf;
//	// Create discount type object
//	vIsAmountDiscount = False;
//	vFixedDiscount = Discount;
//	vFixedDiscountTypeObj = Неопределено;
//	If ЗначениеЗаполнено(DiscountType) Тогда
//		vFixedDiscountTypeObj = DiscountType.GetObject();
//		If DiscountType.IsAmountDiscount Тогда
//			vIsAmountDiscount = True;
//		EndIf;
//	EndIf;
//	// Build value table of discount percents per services
//	vFixedDiscountPercents = New ValueTable();
//	vFixedDiscountPercents.Columns.Add("Услуга", cmGetCatalogTypeDescription("Услуги"));
//	vFixedDiscountPercents.Columns.Add("Скидка", cmGetDiscountTypeDescription());
//	If ЗначениеЗаполнено(DiscountType) Тогда
//		If DiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//			vServices = vPrices.Copy(, "Услуга");
//			vServices.GroupBy("Услуга", );
//			For Each vServicesRow In vServices Do
//				If cmIsServiceInServiceGroup(vServicesRow.Услуга, DiscountServiceGroup) Тогда
//					vFixedDiscountPercentsRow = vFixedDiscountPercents.Add();
//					vFixedDiscountPercentsRow.Услуга = vServicesRow.Услуга;
//					vFixedDiscountPercentsRow.Скидка = vFixedDiscountTypeObj.pmGetDiscount(DateTimeFrom, vServicesRow.Услуга, Гостиница);
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	// Fill services
//	i = 0;
//	For Each vPricesRow In vPrices Do
//		If НЕ ЗначениеЗаполнено(vPricesRow.Услуга) Тогда
//			Continue;
//		EndIf;
//		vCurAccountingDate = vPricesRow.УчетнаяДата;
//		vCurCalendarDayType = vPricesRow.ТипДняКалендаря;
//		vCurTimetable = vPricesRow.Timetable;
//		vCurService = vPricesRow.Услуга;
//		vCurIsResourceRevenue = vPricesRow.IsResourceRevenue;
//		vCurIsPricePerPerson = vPricesRow.IsPricePerPerson;
//		vCurIsPricePerMinute = vPricesRow.IsPricePerMinute;
//		// Retrieve current fixed discount
//		If vFixedDiscountPercents.Count() > 0 Тогда
//			vFixedDiscountPercentsRow = vFixedDiscountPercents.Find(vCurService, "Услуга");
//			If vFixedDiscountPercentsRow <> Неопределено Тогда
//				vFixedDiscount = vFixedDiscountPercentsRow.Скидка;
//			EndIf;
//		EndIf;
//		// Check that service fit to the service group
//		If cmIsServiceInServiceGroup(vCurService, ServiceGroupToBeCharged) Тогда
//			vCurPrice = vPricesRow.Цена;
//			vCurCurrency = vPricesRow.Валюта;
//			vCurUnit = vCurService.ЕдИзмерения;
//			vCurFolio = ChargingFolio;
//			If НЕ ЗначениеЗаполнено(vCurFolio) Тогда
//				Continue;
//			EndIf;
//			vCurFolioCurrency = FolioCurrency;
//			vCurFolioCurrencyExchangeRate = FolioCurrencyExchangeRate;
//			vCurBaseCurrencyPrice = Round(cmConvertCurrencies(vCurPrice, vCurCurrency, , Гостиница.BaseCurrency, 1, ?(ЗначениеЗаполнено(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Гостиница), 2);
//			vCurPrice = Round(cmConvertCurrencies(vCurPrice, vCurCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ЗначениеЗаполнено(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Гостиница), 2);
//			vCurVATRate = vPricesRow.СтавкаНДС;
//			vCurMinQuantity = vPricesRow.MinimumQuantity;
//			vCurFoCQuantity = vPricesRow.FreeOfChargeQuantity;
//			vCurDateTimeFrom = vPricesRow.DateTimeFrom;
//			vCurDateTimeTo = vPricesRow.DateTimeTo;
//			vCurRemarks = TrimAll(vPricesRow.Примечания);
//			// Calculate quantity
//			vCurQuantity = vPricesRow.Количество;
//			If vCurQuantity = 0 Тогда
//				If vCurDateTimeFrom < vCurDateTimeTo Тогда
//					If EndOfDay(vCurDateTimeTo) = vCurDateTimeTo Тогда
//						vCurDateTimeTo = vCurDateTimeTo + 1;
//					EndIf;
//					If vCurIsPricePerMinute Тогда
//						vCurQuantity = (vCurDateTimeTo - cm0SecondShift(vCurDateTimeFrom))/60;
//					Else
//						vCurQuantity = (vCurDateTimeTo - cm0SecondShift(vCurDateTimeFrom))/3600;
//					EndIf;
//					// Check for free of charge quantity
//					If vCurFoCQuantity <> 0 Тогда
//						If vCurQuantity > vCurFoCQuantity Тогда
//							vCurQuantity = vCurQuantity - vCurFoCQuantity;
//						Else
//							vCurQuantity = 0;
//						EndIf;
//					EndIf;
//					// Check for minimum quantity
//					If vCurQuantity < vCurMinQuantity Тогда
//						vCurQuantity = vCurMinQuantity;
//					EndIf;
//				EndIf;
//			EndIf;
//			// Take number of persons into account
//			vCurSrvQuantity = vCurQuantity;
//			If vCurIsPricePerPerson Тогда
//				vCurQuantity = vCurQuantity * NumberOfPersons;
//			EndIf;
//			// Add service to the services tabular part if quantity is not zero
//			If vCurQuantity <> 0 Тогда
//				vSrv = Services.Вставить(i);
//				vSrv.ServiceId = String(New UUID());
//				i = i + 1;
//				vSrv.УчетнаяДата = vCurAccountingDate;
//				vSrv.Услуга = vCurService;
//				vSrv.Цена = vCurPrice;
//				vSrv.BaseCurrencyPrice = vCurBaseCurrencyPrice;
//				vSrv.ЕдИзмерения = vCurUnit;
//				vSrv.Количество = vCurQuantity;
//				vSrv.Сумма = Round(vCurPrice * vCurQuantity, 2);
//				vSrv.СтавкаНДС = vCurVATRate;
//				vSrv.СуммаНДС = cmCalculateVATSum(vCurVATRate, vSrv.Сумма);
//				vSrv.Примечания = vCurRemarks;
//				vSrv.Фирма = Фирма;
//				vSrv.ServiceResource = Resource;
//				vSrv.IsResourceRevenue = vCurIsResourceRevenue;
//				vSrv.ТипДняКалендаря = vCurCalendarDayType;
//				vSrv.Timetable = vCurTimetable;
//				vSrv.DateTimeFrom = vCurDateTimeFrom;
//				vSrv.DateTimeTo = vCurDateTimeTo;
//				If BegOfDay(vCurDateTimeFrom) = vCurDateTimeFrom And 
//				   EndOfDay(vCurDateTimeTo) = vCurDateTimeTo And 
//				   vCurDateTimeFrom < DateTimeFrom And
//				   vCurDateTimeTo > DateTimeTo Тогда
//					vSrv.ВремяС = DateTimeFrom;
//					vSrv.ВремяПо = DateTimeTo;
//				Else
//					vSrv.ВремяС = vCurDateTimeFrom;
//					vSrv.ВремяПо = vCurDateTimeTo;
//				EndIf;
//				vSrv.IsManual = False;
//				If vSrv.IsResourceRevenue Тогда
//					If vCurIsPricePerMinute Тогда
//						vSrv.ПроданоЧасовРесурса = vCurSrvQuantity/60;
//					Else
//						vSrv.ПроданоЧасовРесурса = vCurSrvQuantity;
//					EndIf;
//				EndIf;
//				// Fill resource and service times
//				If ЗначениеЗаполнено(vSrv.Услуга.Ресурс) And ЗначениеЗаполнено(vSrv.УчетнаяДата) Тогда
//					vSrv.ServiceResource = vSrv.Услуга.Ресурс;
//					vResourceObj = vSrv.ServiceResource.GetObject();
//					vDefaultTimes = vResourceObj.pmGetResourceDefaultChargingTimes(vSrv.УчетнаяДата);
//					If ЗначениеЗаполнено(vDefaultTimes.ВремяС) And ЗначениеЗаполнено(vDefaultTimes.ВремяПо) And vDefaultTimes.ВремяПо >= vDefaultTimes.ВремяС Тогда
//						vSrv.ВремяС = vDefaultTimes.ВремяС;
//						vSrv.ВремяПо = vDefaultTimes.ВремяПо;
//					EndIf;
//					If vSrv.ServiceResource <> Resource Тогда
//						vSrv.DoResourceReservation = True;
//					EndIf;
//				EndIf;
//				// Calculate discount for this service if applicable
//				vCurDiscount = 0;
//				vCurDiscountType = Неопределено;
//				vCurDiscountServiceGroup = Неопределено;
//				vCurDiscountConfirmationText = "";
//				// Check manual discount set in the document
//				If cmIsServiceInServiceGroup(vSrv.Услуга, DiscountServiceGroup) Тогда
//					vCurDiscount = vFixedDiscount;
//					vCurDiscountType = DiscountType;
//					vCurDiscountServiceGroup = DiscountServiceGroup;
//					vCurDiscountConfirmationText = DiscountConfirmationText;
//				EndIf;
//				// Check accumulating discounts
//				If НЕ TurnOffAutomaticDiscounts Тогда
//					// Check period discount
//					If vPeriodDiscount <> 0 Тогда
//						If cmFirstDiscountIsGreater(vPeriodDiscount, vCurDiscount) Тогда
//							vCurDiscount = vPeriodDiscount;
//							vCurDiscountType = vPeriodDiscountType;
//							vCurDiscountServiceGroup = vPeriodDiscountServiceGroup;
//							vCurDiscountConfirmationText = vPeriodDiscountConfirmationText;
//						EndIf;
//					EndIf;
//					// Retrieve accumulation discounts
//					For Each vAccDiscount In vAccDiscounts Do
//						vDiscountType = vAccDiscount.ТипСкидки;
//						vDiscountDimension = vAccDiscount.ИзмерениеСкидки;
//						vDiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//						If cmIsServiceInServiceGroup(vSrv.Услуга, vDiscountServiceGroup) And 
//						   НЕ vDiscountType.IsForRackRatesOnly Тогда
//							vDiscountTypeObj = vDiscountType.GetObject();
//							
//							// Check that this discount type fits to the service folio
//							vSrvDiscountDimension = Неопределено;
//							vSrvResource = vDiscountTypeObj.pmCalculateResource(vSrv, NumberOfPersons, ChargingFolio, DiscountCard, vSrvDiscountDimension, True);
//							If TypeOf(vSrvDiscountDimension) = TypeOf(vDiscountDimension) Тогда
//								// Add resource calculated for this service to the current discount resource
//								If vSrvResource <> 0 Тогда
//									vAccDiscount.Ресурс = vAccDiscount.Ресурс + vSrvResource;
//								EndIf;
//							   
//								// Retrieve discount percent valid for current discount resource										
//								vResource = vAccDiscount.Ресурс;
//								vDiscountConfirmationText = "";
//								vDiscount = vDiscountTypeObj.pmGetAccumulatingDiscount(vSrv.Услуга, vSrv.УчетнаяДата, 
//																					   vResource, 
//																					   vDiscountConfirmationText);
//								If vDiscount <> 0 Тогда
//									If cmFirstDiscountIsGreater(vDiscount, vCurDiscount) Тогда
//										vCurDiscount = vDiscount;
//										vCurDiscountType = vDiscountType;
//										vCurDiscountServiceGroup = vDiscountServiceGroup;
//										vCurDiscountConfirmationText = vDiscountConfirmationText;
//									EndIf;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndDo;
//				EndIf;
//				// Calculate discount sum
//				If vCurDiscount <> 0 Тогда
//					If cmIsServiceInServiceGroup(vSrv.Услуга, vCurDiscountServiceGroup) Тогда
//						vSrv.Скидка = vCurDiscount;
//						vSrv.ТипСкидки = vCurDiscountType;
//						vSrv.DiscountServiceGroup = vCurDiscountServiceGroup;
//						vSrv.ОснованиеСкидки = vCurDiscountConfirmationText;
//						// Check should we set value for the period discount
//						If ЗначениеЗаполнено(vCurDiscountType) Тогда
//							If vCurDiscountType.IsPerPeriod Тогда
//								If vCurDiscount > vPeriodDiscount And vCurDiscount > 0 Or 
//								   vCurDiscount < vPeriodDiscount And vCurDiscount < 0 Тогда
//									vPeriodDiscount = vCurDiscount;
//									vPeriodDiscountType = vCurDiscountType;
//									vPeriodDiscountServiceGroup = vCurDiscountServiceGroup;
//									vPeriodDiscountConfirmationText = vCurDiscountConfirmationText;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//				Else
//					If ЗначениеЗаполнено(DiscountType) And 
//					   DiscountType.IsAccumulatingDiscount And DiscountType.HasToBeDirectlyAssigned Тогда 
//						If cmIsServiceInServiceGroup(vSrv.Услуга, DiscountServiceGroup) Тогда
//							vSrv.Скидка = 0; // This is not mistake
//							vSrv.ТипСкидки = DiscountType;
//							vSrv.DiscountServiceGroup = DiscountServiceGroup;
//							vSrv.ОснованиеСкидки = DiscountConfirmationText;
//						EndIf;
//					EndIf;
//				EndIf;
//				pmCalculateServiceDiscounts(vSrv);
//				// Calculate commission for this service if applicable
//				pmCalculateServiceCommissions(vSrv);
//				// Try to find current service in the table of services changed manually
//				If vMCServices.Count() > 0 Тогда
//					vMCSrvRows = vMCServices.FindRows(New Structure("УчетнаяДата, Услуга, DateTimeFrom", vSrv.УчетнаяДата, vSrv.Услуга, vSrv.DateTimeFrom));
//					If vMCSrvRows.Count() > 0 Тогда
//						vMCSrv = vMCSrvRows.Get(0);
//						FillPropertyValues(vSrv, vMCSrv, , "LineNumber, Фирма, ПроданоЧасовРесурса, DateTimeFrom, DateTimeTo, Timetable, ТипДеньКалендарь");
//						If vSrv.IsResourceRevenue Тогда
//							If vCurIsPricePerMinute Тогда
//								vSrv.ПроданоЧасовРесурса = vSrv.Количество/60;
//							Else
//								vSrv.ПроданоЧасовРесурса = vSrv.Количество;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//	// Check amount discount
//	If vIsAmountDiscount And DiscountSum <> 0 Тогда
//		vDiscountSum = DiscountSum;
//		vNumServices = Services.Count();
//		If vNumServices > 0 Тогда
//			// Do first run
//			vNumDiscountServices = 0;
//			vFirstRunDiscountSum = Int(vDiscountSum/vNumServices);
//			For Each vSrvRow In Services Do
//				If vSrvRow.Sum <> 0 And vSrvRow.Sum >= vFirstRunDiscountSum And 
//				   cmIsServiceInServiceGroup(vSrvRow.Service, DiscountServiceGroup) Тогда
//					vSrvRow.DiscountSum = vFirstRunDiscountSum;
//					vSrvRow.VATDiscountSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.DiscountSum);
//					vDiscountSum = vDiscountSum - vFirstRunDiscountSum;
//					vNumDiscountServices = vNumDiscountServices + 1;
//				EndIf;
//			EndDo;
//			// Do second run
//			If vDiscountSum <> 0 And vNumDiscountServices > 0 Тогда
//				vSecondRunDiscountSum = Round(vDiscountSum/vNumDiscountServices, 2);
//				For Each vSrvRow In Services Do
//					If vSrvRow.Sum <> 0 And vSrvRow.Sum >= vSecondRunDiscountSum And 
//					   cmIsServiceInServiceGroup(vSrvRow.Service, DiscountServiceGroup) Тогда
//						If vDiscountSum > 0 Тогда
//							If vDiscountSum > vSecondRunDiscountSum Тогда
//								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vSecondRunDiscountSum;
//								vDiscountSum = vDiscountSum - vSecondRunDiscountSum;
//							Else
//								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vDiscountSum;
//								vDiscountSum = 0;
//							EndIf;
//						Else
//							If vDiscountSum < vSecondRunDiscountSum Тогда
//								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vSecondRunDiscountSum;
//								vDiscountSum = vDiscountSum - vSecondRunDiscountSum;
//							Else
//								vSrvRow.DiscountSum = vSrvRow.DiscountSum + vDiscountSum;
//								vDiscountSum = 0;
//							EndIf;
//						EndIf;
//						vSrvRow.VATDiscountSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.DiscountSum);
//					EndIf;
//				EndDo;
//			EndIf;
//			// Do third run
//			If vDiscountSum <> 0 And vNumDiscountServices > 0 Тогда
//				For Each vSrvRow In Services Do
//					If vSrvRow.Sum <> 0 And vSrvRow.Sum >= vDiscountSum And 
//					   cmIsServiceInServiceGroup(vSrvRow.Service, DiscountServiceGroup) Тогда
//						vSrvRow.DiscountSum = vSrvRow.DiscountSum + vDiscountSum;
//						vSrvRow.VATDiscountSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.DiscountSum);
//						vDiscountSum = 0;
//						Break;
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Calculate price presentation
//	vPricePresentation = pmCalculatePricePresentation();
//	If TrimAll(vPricePresentation) <> TrimAll(PricePresentation) Тогда
//		PricePresentation = TrimAll(vPricePresentation);
//	EndIf;
//	// Check should we call this function recursively to recalculate discounts
//	If vPeriodDiscount <> pPeriodDiscount Тогда
//		Return pmCalculateServices(rWarnings, vPeriodDiscount, vPeriodDiscountType, 
//		                                      vPeriodDiscountServiceGroup, vPeriodDiscountConfirmationText);
//	EndIf;
//	Return False;
//EndFunction //pmCalculateServices
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateServiceDiscounts(pSrvRow) Экспорт
//	pSrvRow.СуммаСкидки = Round(pSrvRow.Сумма * pSrvRow.Скидка/100, 2);
//	If ЗначениеЗаполнено(pSrvRow.ТипСкидки) Тогда
//		If pSrvRow.ТипСкидки.RoundPrice Тогда
//			pSrvRow.СуммаСкидки = cmRoundDiscountAmount(pSrvRow.СуммаСкидки, pSrvRow.ТипСкидки.RoundPriceDigits, pSrvRow.ТипСкидки.RoundPriceType);
//		EndIf;
//	EndIf;
//	pSrvRow.НДСскидка = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаСкидки);
//	pSrvRow.BaseCurrencyPrice = pSrvRow.BaseCurrencyPrice - Round(pSrvRow.BaseCurrencyPrice * pSrvRow.Скидка/100, 2);
//КонецПроцедуры //pmCalculateServiceDiscounts
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateServiceCommissions(pSrvRow) Экспорт
//	pSrvRow.СуммаКомиссии = 0;
//	pSrvRow.СуммаКомиссииНДС = 0;
//	If AgentCommission <> 0 Тогда
//		// Check that current service fit to the commission service group
//		If cmIsServiceInServiceGroup(pSrvRow.Услуга, AgentCommissionServiceGroup) Тогда
//			If AgentCommissionType = Перечисления.AgentCommissionTypes.Percent Тогда
//				pSrvRow.СуммаКомиссии = Round((pSrvRow.Сумма - pSrvRow.СуммаСкидки) * AgentCommission/100, 2);
//				pSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаКомиссии);
//			ElsIf AgentCommissionType = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//				If BegOfDay(DateTimeFrom) = BegOfDay(pSrvRow.УчетнаяДата) Тогда
//					pSrvRow.СуммаКомиссии = Round((pSrvRow.Сумма - pSrvRow.СуммаСкидки) * AgentCommission/100, 2);
//					pSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаКомиссии);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmCalculateServiceCommissions
//
////-----------------------------------------------------------------------------
//// Get resource reservation attributes valid on specified date
//// - pDate is optional. If is not specified, then function gets attributes on current date
//// Returns ValueTable 
////-----------------------------------------------------------------------------
//Function pmGetResourceReservationAttributes(Val pDate = Неопределено) Экспорт
//	// Fill parameter default values 
//	If НЕ ЗначениеЗаполнено(pDate) Тогда
//		pDate = CurrentDate();
//	EndIf;
//	
//	// Build and run query
//	qGetLastAttr = New Query;
//	qGetLastAttr.Text = 
//	"SELECT 
//	|	* 
//	|FROM
//	|	InformationRegister.ResourceReservationChangeHistory.SliceLast(
//	|	&qDate, 
//	|	БроньУслуг = &qResourceReservation) AS ResourceReservationChangeHistory";
//	qGetLastAttr.SetParameter("qDate", pDate);
//	qGetLastAttr.SetParameter("qResourceReservation", Ref);
//	vAttr = qGetLastAttr.Execute().Unload();
//	
//	Return vAttr;
//EndFunction //pmGetResourceReservationAttributes
//
////-----------------------------------------------------------------------------
//// Get reservation prices for all day types of ГруппаНомеров rate
////-----------------------------------------------------------------------------
//Function pmGetPrices() Экспорт
//	vPrices = Services.Unload();
//	// Remove not is resource revenue services
//	vNotResourceRevenueRows = vPrices.FindRows(New Structure("IsResourceRevenue", False));
//	If vNotResourceRevenueRows <> Неопределено Тогда
//		For Each vNotResourceRevenueRow In vNotResourceRevenueRows Do
//			vPrices.Delete(vNotResourceRevenueRow);
//		EndDo;
//	EndIf;
//	// Recalculate prices taking discounts into account
//	For Each vCurSrv In vPrices Do
//		If ЗначениеЗаполнено(Agent) And НЕ Agent.DoNotPostCommission And Agent = Контрагент And AgentCommission <> 0 And Agent = Owner Тогда
//			If vCurSrv.DiscountSum <> 0 Тогда
//				vCurSrv.Sum = vCurSrv.Sum - vCurSrv.DiscountSum - vCurSrv.CommissionSum;
//				cmSumOnChange(vCurSrv.Service, vCurSrv.Price, vCurSrv.Quantity, vCurSrv.Sum, vCurSrv.VATRate, vCurSrv.VATSum, True);
//			Else
//				vCurSrv.Sum = vCurSrv.Sum - vCurSrv.CommissionSum;
//				cmSumOnChange(vCurSrv.Service, vCurSrv.Price, vCurSrv.Quantity, vCurSrv.Sum, vCurSrv.VATRate, vCurSrv.VATSum, True);
//			EndIf;
//		Else
//			If vCurSrv.DiscountSum <> 0 Тогда
//				vCurSrv.Sum = vCurSrv.Sum - vCurSrv.DiscountSum;
//				cmSumOnChange(vCurSrv.Service, vCurSrv.Price, vCurSrv.Quantity, vCurSrv.Sum, vCurSrv.VATRate, vCurSrv.VATSum, True);
//			EndIf;
//		EndIf;
//	EndDo;	
//	// Group services by prices
//	vPrices.GroupBy("ТипДеньКалендарь, Услуга, Цена", );
//	// Return prices
//	Return vPrices;
//EndFunction //pmGetPrices
//
////-----------------------------------------------------------------------------
//Function pmGetDocumentLanguage() Экспорт
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If ЗначениеЗаполнено(Контрагент.Language) Тогда
//			Return Контрагент.Language;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Client) Тогда
//		If ЗначениеЗаполнено(Client.Language) Тогда
//			Return Client.Language;
//		EndIf;
//	EndIf;
//	Return Справочники.Локализация.EmptyRef();
//EndFunction //pmGetDocumentLanguage
//
////-----------------------------------------------------------------------------
//Процедура pmProcessHotelChange() Экспорт
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//		Фирма = Гостиница.Фирма;
//		ReportingCurrency = Гостиница.ReportingCurrency;
//		ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, Date);
//		// Recreate guest group as it has hotel as owner
//		pmCreateGuestGroup();
//	EndIf;
//КонецПроцедуры //pmProcessHotelChange	
//
////-----------------------------------------------------------------------------
//Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If pWriteMode = DocumentWriteMode.Posting Тогда
//		pCancel	= pmCheckDocumentAttributes(Posted, vMessage, vAttributeInErr, True);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And DoCharging And 
//		  (pWriteMode = DocumentWriteMode.UndoPosting Or DeletionMark) And 
//		  (Services.Total("Сумма") <> 0 Or Services.Total("Количество") <> 0) And 
//		   ЗначениеЗаполнено(ResourceReservationStatus) And ResourceReservationStatus.ServicesAreDelivered And 
//		   cmGetDocumentCharges(Ref, Неопределено, Неопределено, Гостиница, Неопределено, True).Count() > 0 Тогда
//			vDocBalanceIsZero = False;
//			vDocBalancesRow = cmGetDocumentCurrentAccountsReceivableBalance(Ref);
//			If vDocBalancesRow <> Неопределено Тогда
//				If vDocBalancesRow.SumBalance = 0 And vDocBalancesRow.QuantityBalance = 0 Тогда
//					vDocBalanceIsZero = True;
//				EndIf;
//			Else
//				vDocBalanceIsZero = True;
//			EndIf;
//			If vDocBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='All resource reservation charges are closed by settlements! Resource reservation is read only.';
//				             |ru='Все начисления брони ресурсов уже закрыты актами об оказании услуг! Редактирование такой брони запрещено.';
//							 |de='Alle Anrechnungen der Ressourcenreservierung wurden bereits durch Übergabeprotokolle über die Dienstleistungserbringung geschlossen! Die Bearbeitung einer solchen Reservierung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		If DeletionMark Тогда
//			If ЗначениеЗаполнено(ResourceReservationStatus) And ResourceReservationStatus.ServicesAreDelivered Тогда
//				If НЕ cmCheckUserPermissions("HavePermissionToEditCompletedResourceReservations") Тогда
//					pCancel = True;
//					Message(NStr("en='You do not have rights to edit completed resource reservations where services are delivered!'; ru='У вас нет прав на редактирование завершенной брони ресурсов по которой все услуги оказаны!'; de='Es gibt keine Rechte, die geschlossen Ressourcenbuchungen zu editieren!'"), MessageStatus.Attention);
//					Return;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("CatalogRef.ШаблоныОпераций") Тогда
//			// Fill attributes with default values
//			pmFillAttributesWithDefaultValues();
//			// Fill attributes from template
//			If ЗначениеЗаполнено(pBase.ИсточникИнфоГостиница) Тогда
//				SourceOfBusiness = pBase.ИсточникИнфоГостиница;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.МаркетингКод) Тогда
//				MarketingCode = pBase.МаркетингКод;
//				MarketingCodeConfirmationText = TrimAll(pBase.MarketingCodeConfirmationText);
//			EndIf;
//			If ЗначениеЗаполнено(pBase.ТипКлиента) Тогда
//				ClientType = pBase.ТипКлиента;
//				ClientTypeConfirmationText = TrimAll(pBase.СтрокаПодтверждения);
//			EndIf;
//			If ЗначениеЗаполнено(pBase.ТипРесурса) Тогда
//				ResourceType = pBase.ТипРесурса;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Ресурс) Тогда
//				Resource = pBase.Ресурс;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.ТипСкидки) Тогда
//				DiscountType = pBase.ТипСкидки;
//				DiscountConfirmationText = TrimAll(pBase.ОснованиеСкидки);
//			EndIf;
//			If pBase.Скидка <> 0 Тогда
//				Discount = pBase.Скидка;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.DiscountServiceGroup) Тогда
//				DiscountServiceGroup = pBase.DiscountServiceGroup;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.ResourceReservationStatus) Тогда
//				ResourceReservationStatus = pBase.ResourceReservationStatus;
//				DoCharging = pBase.DoCharging;
//			EndIf;
//			If НЕ IsBlankString(pBase.ConfirmationReply) Тогда
//				ConfirmationReply = TrimAll(pBase.ConfirmationReply);
//			EndIf;
//			If ЗначениеЗаполнено(pBase.PlannedPaymentMethod) Тогда
//				PlannedPaymentMethod = pBase.PlannedPaymentMethod;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Валюта) Тогда
//				ReportingCurrency = pBase.Валюта;
//				ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, ExchangeRateDate);
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Фирма) Тогда
//				Фирма = pBase.Фирма;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Контрагент) Тогда
//				Контрагент = pBase.Контрагент;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Договор) Тогда
//				Contract = pBase.Договор;
//			EndIf;
//			If НЕ IsBlankString(pBase.Примечания) Тогда
//				Remarks = TrimAll(pBase.Примечания);
//			EndIf;
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Размещение") Тогда
//			FillPropertyValues(ThisObject, pBase, , "Number, Date, Автор, DeletionMark, Posted");
//			ParentDoc = pBase;
//			DateTimeFrom = cm1SecondShift(pBase.CheckOutDate);
//			Duration = 1;
//			DateTimeTo = pmCalculateDateTimeTo();
//			// Fill attributes with default values
//			pmFillAttributesWithDefaultValues();
//		EndIf;
//		// Calculate services
//		pmCalculateServices();
//	Else
//		// Fill attributes with default values
//		pmFillAttributesWithDefaultValues();
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
//	EndIf;
//	If vPrefix <> "" Тогда
//		pPrefix = vPrefix;
//	EndIf;
//КонецПроцедуры //OnSetNewNumber
//
////-----------------------------------------------------------------------------
//Процедура OnCopy(pCopiedObject)
//	ExternalCode = "";
//	// Calculate services
//	pmCalculateServices();
//КонецПроцедуры //OnCopy
//
////-----------------------------------------------------------------------------
//Процедура pmSetDiscounts() Экспорт
//	// Check if manual discount is choosen
//	If ЗначениеЗаполнено(DiscountType) And DiscountType.IsManualDiscount Тогда
//		Return;
//	ElsIf НЕ ЗначениеЗаполнено(DiscountType) And Discount <> 0 Тогда
//		Return;
//	EndIf;
//	// Fill discounts from the different sources
//	DiscountType = Справочники.ТипыСкидок.EmptyRef();
//	DiscountConfirmationText = "";
//	DiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//	Discount = 0;
//	vOldTurnOffAutomaticDiscounts = TurnOffAutomaticDiscounts;
//	vTurnOffAutomaticDiscountsWasSet = False;
//	TurnOffAutomaticDiscounts = False;
//	If ЗначениеЗаполнено(DiscountCard) Тогда
//		If DiscountCard.TurnOffAutomaticDiscounts Тогда
//			TurnOffAutomaticDiscounts = DiscountCard.TurnOffAutomaticDiscounts;
//			vTurnOffAutomaticDiscountsWasSet = True;
//		EndIf;
//		If ЗначениеЗаполнено(DiscountCard.DiscountType) Тогда
//			vDiscountType = DiscountCard.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(DateTimeFrom, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				DiscountConfirmationText = DiscountCard.Metadata().Synonym + " " + TrimAll(DiscountCard.Description);
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				If НЕ vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//					Discount = vDiscount;
//				EndIf;
//				If ЗначениеЗаполнено(DiscountCard.ClientType) Тогда
//					ClientType = DiscountCard.ClientType;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;	
//	If ЗначениеЗаполнено(ClientType) Тогда
//		If ClientType.TurnOffAutomaticDiscounts Тогда
//			TurnOffAutomaticDiscounts = ClientType.TurnOffAutomaticDiscounts;
//			vTurnOffAutomaticDiscountsWasSet = True;
//		EndIf;
//		If ЗначениеЗаполнено(ClientType.DiscountType) Тогда
//			vDiscountType = ClientType.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(DateTimeFrom, , Гостиница);
//			If vDiscount > Discount Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				If IsBlankString(ClientTypeConfirmationText) Тогда
//					DiscountConfirmationText = NStr("en='Client type discount';ru='По типу клиента';de='Nach Kundentyp'");
//				Else
//					DiscountConfirmationText = ClientTypeConfirmationText;
//				EndIf;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				If НЕ vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//					Discount = vDiscount;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(MarketingCode) Тогда
//		If MarketingCode.TurnOffAutomaticDiscounts Тогда
//			TurnOffAutomaticDiscounts = MarketingCode.TurnOffAutomaticDiscounts;
//			vTurnOffAutomaticDiscountsWasSet = True;
//		EndIf;
//		If ЗначениеЗаполнено(MarketingCode.DiscountType) Тогда
//			vDiscountType = MarketingCode.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(DateTimeFrom, , Гостиница);
//			If vDiscount > Discount Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				If IsBlankString(MarketingCodeConfirmationText) Тогда
//					DiscountConfirmationText = NStr("en='Marketing code discount';ru='По направлению маркетинга';de='Nach Marketingrichtung'");
//				Else
//					DiscountConfirmationText = MarketingCodeConfirmationText;
//				EndIf;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				If НЕ vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//					Discount = vDiscount;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Client) Тогда
//		If ЗначениеЗаполнено(Client.DiscountType) Тогда
//			vDiscountType = Client.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(DateTimeFrom, , Гостиница);
//			If vDiscount > Discount Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				If IsBlankString(Client.DiscountConfirmationText) Тогда
//					DiscountConfirmationText = NStr("en='Client discount';ru='По клиенту';de='Nach Kunde'");
//				Else
//					DiscountConfirmationText = Client.DiscountConfirmationText;
//				EndIf;
//				If НЕ vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//					Discount = vDiscount;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If ЗначениеЗаполнено(Контрагент.DiscountType) Тогда
//			vDiscountType = Контрагент.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(DateTimeFrom, , Гостиница);
//			If vDiscount > Discount Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				If IsBlankString(Контрагент.DiscountConfirmationText) Тогда
//					DiscountConfirmationText = NStr("en='Контрагент discount';ru='По контрагенту';de='Nach Partner'");
//				Else
//					DiscountConfirmationText = Контрагент.DiscountConfirmationText;
//				EndIf;
//				If НЕ vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//					Discount = vDiscount;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Contract) Тогда
//		If ЗначениеЗаполнено(Contract.DiscountType) Тогда
//			vDiscountType = Contract.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(DateTimeFrom, , Гостиница);
//			If vDiscount > Discount Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				If IsBlankString(Contract.DiscountConfirmationText) Тогда
//					DiscountConfirmationText = NStr("en='Contract discount';ru='По договору';de='Nach Vertrag'");
//				Else
//					DiscountConfirmationText = Contract.DiscountConfirmationText;
//				EndIf;
//				If НЕ vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//					Discount = vDiscount;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(DiscountType) Тогда
//		If DiscountType.TurnOffAutomaticDiscounts Тогда
//			TurnOffAutomaticDiscounts = DiscountType.TurnOffAutomaticDiscounts;
//			vTurnOffAutomaticDiscountsWasSet = True;
//		EndIf;
//	EndIf;
//	If НЕ vTurnOffAutomaticDiscountsWasSet Тогда
//		TurnOffAutomaticDiscounts = vOldTurnOffAutomaticDiscounts;
//	EndIf;
//КонецПроцедуры //pmSetDiscounts
//
////-----------------------------------------------------------------------------
//Function pmGetThisDocumentRef() Экспорт
//	vObjectRef = Ref;
//	If ЭтоНовый() Тогда
//		vObjectRef = GetNewObjectRef();
//		If НЕ ЗначениеЗаполнено(vObjectRef) Тогда
//			SetNewObjectRef(Documents.БроньУслуг.GetRef());
//			vObjectRef = GetNewObjectRef();
//		EndIf;
//	EndIf;
//	Return vObjectRef;
//EndFunction //pmGetThisDocumentRef
