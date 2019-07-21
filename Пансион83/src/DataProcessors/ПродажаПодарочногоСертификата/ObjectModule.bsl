////-----------------------------------------------------------------------------
//Процедура pmLoadDataProcessorAttributes(pParameter) Экспорт
//	If ЗначениеЗаполнено(pParameter) And TypeOf(pParameter) = Type("DocumentRef.СчетПроживания") Тогда
//		ЛицевойСчет = pParameter;
//	EndIf;
//	Гостиница = ЛицевойСчет.Гостиница;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	SPAWSDLHostAddress = Гостиница.SPAConnectionString;
//КонецПроцедуры //pmLoadDataProcessorAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmRun(pParameter, pIsInteractive) Экспорт
//	#IF CLIENT THEN
//		vForm = DataProcessor.ПолучитьФорму();
//		vForm.Open();
//	#ENDIF
//КонецПроцедуры //pmRun
//
////-----------------------------------------------------------------------------
//Function pmWriteCertificate() Экспорт
//	Try
//		BeginTransaction();
//		If Гостиница.ExportGiftCertificatesToSPA Тогда
//			vErrorText = pmSynchroniseWithSPA();
//			If ЗначениеЗаполнено(vErrorText) Тогда
//				ВызватьИсключение vErrorText;
//			EndIf;
//		EndIf;
//		vErrorText = pmDoCertificateCharge();
//		If ЗначениеЗаполнено(vErrorText) Тогда
//			ВызватьИсключение vErrorText;
//		EndIf;
//		If НЕ OnlyCharge Тогда 
//			If НЕ pmDoCertificatePayment() Тогда
//				ВызватьИсключение NStr("en='Payment post error';ru='Ошибка проводки платежа';de='Fehler bei der Zahlungsdurchführung'");
//			EndIf;
//		EndIf;
//		CommitTransaction();
//	Except
//		vErrorDescription = ErrorDescription();
//		vResult = pmDeleteSPACertificate();
//		If ЗначениеЗаполнено(vResult) Тогда
//			Message(vResult);
//		EndIf;
//		If TransactionActive() Тогда
//			RollbackTransaction();
//		EndIf;
//		Return vErrorDescription;
//	EndTry;
//EndFunction //pmWriteCertificate
//
////-----------------------------------------------------------------------------
//Function pmDoCertificateCharge()
//	vError = "";
//	vQuantity = 1;
//	// Get hotel
//	vHotel = Неопределено;
//	vSum = 0;
//	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница) Тогда
//		vHotel = ЛицевойСчет.Гостиница;
//	ElsIf ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//		vHotel = ЛицевойСчет.ParentDoc.Гостиница;
//	Else
//		vHotel = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		vError = NStr("en='Гостиница is not set!';ru='Не удалось определить гостиницу!';de='Das Гостиница konnte nicht bestimmt werden!'");
//		Return vError;
//	EndIf;
//	// Get service to be charged by service code or hotel
//	vService = Certificate;
//	
//	vServicePrices = vService.GetObject().pmGetServicePrices(ЛицевойСчет.Гостиница, CurrentDate());
//	vVATRate = Справочники.СтавкаНДС.EmptyRef();
//	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница.Фирма) Тогда
//		vVATRate = ЛицевойСчет.Гостиница.Фирма.VATRate;
//	EndIf;
//	If vServicePrices.Count() > 0 Тогда
//		vVATRate = vServicePrices.Get(0).СтавкаНДС;
//		vSum = vServicePrices.Get(0).Цена;
//	EndIf;
//	
//	// Create charge document
//	vChargeObj = Documents.Начисление.CreateDocument();
//	vChargeObj.pmFillAttributesWithDefaultValues();
//	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница) Тогда
//		If vChargeObj.Гостиница <> ЛицевойСчет.Гостиница Тогда
//			vChargeObj.Гостиница = ЛицевойСчет.Гостиница;
//			vChargeObj.SetNewNumber(TrimAll(vChargeObj.Гостиница.GetObject().pmGetPrefix()));
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(vChargeObj.Гостиница) Тогда
//		vError = NStr("en='Гостиница is not set!';ru='Не удалось установить гостиницу!';de='Das Гостиница konnte nicht festgelegt werden!'");
//		Return vError;
//	EndIf;
//	
//	// Get currency by code
//	vCurrency = ЛицевойСчет.FolioCurrency;
//	If НЕ ЗначениеЗаполнено(vCurrency) Тогда
//		vCurrency = vHotel.ВалютаЛицСчета;
//	EndIf;
//	
//	// Post this document
//	vChargeObj.ДокОснование = ЛицевойСчет.ParentDoc;
//	vChargeObj.IsFixedCharge = False;
//	vChargeObj.Гостиница = ЛицевойСчет.Гостиница;
//	If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) And TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.БроньУслуг") And
//		ЗначениеЗаполнено(ЛицевойСчет.ParentDoc.ExchangeRateDate) And 
//		ЗначениеЗаполнено(vChargeObj.Услуга) And ЗначениеЗаполнено(vChargeObj.Услуга.ServiceType) And 
//		vChargeObj.Услуга.ServiceType.ActualAmountIsChargedExternally Тогда
//		vChargeObj.ExchangeRateDate = ЛицевойСчет.ParentDoc.ExchangeRateDate;
//	EndIf;
//	vChargeObj.ВалютаЛицСчета = ЛицевойСчет.FolioCurrency;
//	vChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.ВалютаЛицСчета, vChargeObj.ExchangeRateDate);
//	vChargeObj.Валюта = ЛицевойСчет.Гостиница.ReportingCurrency;
//	vChargeObj.ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.Валюта, vChargeObj.ExchangeRateDate);
//	vChargeObj.СчетПроживания = ЛицевойСчет;
//	vChargeObj.Услуга = vService;
//	vChargeObj.PaymentSection = vChargeObj.Услуга.PaymentSection;
//	If vSum < 0 And vQuantity > 0 Тогда
//		vQuantity = -vQuantity;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(vCurrency) Or vCurrency = vChargeObj.ВалютаЛицСчета Тогда
//		vChargeObj.Цена = cmRecalculatePrice(vSum, vQuantity);
//	Else
//		vSum = cmExtConvertCurrencies(vSum, vCurrency, , vChargeObj.ВалютаЛицСчета, vChargeObj.FolioCurrencyExchangeRate, vChargeObj.ExchangeRateDate, vChargeObj.Гостиница, "");
//		vChargeObj.Цена = cmRecalculatePrice(vSum, vQuantity);
//	EndIf;
//	vChargeObj.ЕдИзмерения = vService.ЕдИзмерения;
//	vChargeObj.Количество = vQuantity;
//	vChargeObj.Сумма = vSum;
//	vChargeObj.СтавкаНДС = vVATRate;
//	vChargeObj.СуммаНДС = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.Сумма);
//	vChargeObj.IsRoomRevenue = vService.IsRoomRevenue;
//	vChargeObj.IsInPrice = vService.IsInPrice;
//	vChargeObj.Фирма = ЛицевойСчет.Фирма;
//	vChargeObj.IsAdditional = True;
//	vChargeObj.GiftCertificate = TrimAll(CertificateNumber);
//	vChargeObj.Write(DocumentWriteMode.Posting);
//	Return vError;
//EndFunction //pmDoCertificateCharge
//
////-----------------------------------------------------------------------------
//Function pmDoCertificatePayment()
//	// Create payment for the folio being found
//	vPaymentObj = Documents.Платеж.CreateDocument();
//	vPaymentObj.Fill(ЛицевойСчет);
//	vPaymentObj.GiftCertificate = TrimAll(CertificateNumber);
//	// Get service to be charged by service code or hotel
//	vSum = 0;
//	vService = Certificate;
//	vServicePrices = vService.GetObject().pmGetServicePrices(ЛицевойСчет.Гостиница, CurrentDate());
//	vVATRate = Справочники.СтавкаНДС.EmptyRef();
//	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница.Фирма) Тогда
//		vVATRate = ЛицевойСчет.Гостиница.Фирма.VATRate;
//	EndIf;
//	If vServicePrices.Count() > 0 Тогда
//		vVATRate = vServicePrices.Get(0).СтавкаНДС;
//		vSum = vServicePrices.Get(0).Цена;
//	EndIf;
//    // Get currency by code
//	vCurrency = ЛицевойСчет.FolioCurrency;
//	If НЕ ЗначениеЗаполнено(vCurrency) Тогда
//		vCurrency = ЛицевойСчет.Гостиница.FolioCurrency;
//	EndIf;
//	If ЗначениеЗаполнено(vCurrency) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//			vExchangeRateDate = ЛицевойСчет.ParentDoc.ExchangeRateDate;
//		Else
//			vExchangeRateDate = CurrentDate();
//		EndIf;
//		vSum = cmExtConvertCurrencies(vSum, vCurrency, , ЛицевойСчет.FolioCurrency, cmGetCurrencyExchangeRate(ЛицевойСчет.Гостиница, ЛицевойСчет.FolioCurrency, vExchangeRateDate), vExchangeRateDate, ЛицевойСчет.Гостиница, "");
//	EndIf;
//    vPaymentObj.Сумма = vSum;
//	vPaymentObj.SumInFolioCurrency = vSum;                                  
//	vFrm = vPaymentObj.ПолучитьФорму(,, ЛицевойСчет);
//	vFrm.DoModal();
//	If НЕ ЗначениеЗаполнено(vPaymentObj.Ref) Or НЕ vPaymentObj.Posted Тогда
//		Return False;
//	EndIf;
//	Return True;
//EndFunction //pmDoCertificatePayment
//
////-----------------------------------------------------------------------------
//Function pmDeleteSPACertificate()
//	Try	
//		vDefinition = New WSDefinitions(SPAWSDLHostAddress + "/1CHotelInterfaces.1cws?WSDL");
//		For Each vService In vDefinition.Services Do
//			If vService.Name = "HotelInterfaces" Тогда
//				vNamespaceURI = vService.NamespaceURI;
//				break;
//			EndIf;
//		EndDo;
//		If НЕ ЗначениеЗаполнено(vNamespaceURI) Тогда
//			vNamespaceURI = "http://www.salon1c.ru/ws/Interfaces/Гостиница";
//		EndIf;
//		vProxy = New WSProxy(vDefinition,vNamespaceURI,"HotelInterfaces","HotelInterfacesSoap");
//		vResult = vProxy.DeleteCertificate(TrimAll(Certificate.Code), CertificateNumber, ?(ЗначениеЗаполнено(ЛицевойСчет.Client), TrimAll(ЛицевойСчет.Client.Code), ""));
//		If ЗначениеЗаполнено(vResult) Тогда
//			ВызватьИсключение vResult;
//		EndIf;
//	Except
//		vErrorDescription = ErrorDescription();
//		Return vErrorDescription;
//	EndTry;
//EndFunction //pmDeleteSPACertificate
//
////-----------------------------------------------------------------------------
//Function pmSynchroniseWithSPA()
//	Try	
//		vDefinition = New WSDefinitions(SPAWSDLHostAddress + "/1CHotelInterfaces.1cws?WSDL");
//		For Each vService In vDefinition.Services Do
//			If vService.Name = "HotelInterfaces" Тогда
//				vNamespaceURI = vService.NamespaceURI;
//				break;
//			EndIf;
//		EndDo;
//		If НЕ ЗначениеЗаполнено(vNamespaceURI) Тогда
//			vNamespaceURI = "http://www.salon1c.ru/ws/Interfaces/Гостиница";
//		EndIf;
//		vGuestCode = TrimAll(ЛицевойСчет.Client.Code);
//		vGuestLastName = TrimAll(ЛицевойСчет.Client.Фамилия);
//		vGuestFirstName = TrimAll(ЛицевойСчет.Client.Имя);
//		vGuestSecondName = TrimAll(ЛицевойСчет.Client.Отчество);
//		If ЗначениеЗаполнено(ЛицевойСчет.Client.ДатаРождения) Тогда
//			vGuestDateOfBirth = Format(ЛицевойСчет.Client.ДатаРождения, "DF=yyyyMMdd");
//		Else
//			vGuestDateOfBirth = "";
//		EndIf;
//		vProxy = New WSProxy(vDefinition,vNamespaceURI,"HotelInterfaces","HotelInterfacesSoap");
//		vResult = vProxy.WriteExternalCertificate(TrimAll(Certificate.Code), CertificateNumber, vGuestLastName, vGuestFirstName, vGuestSecondName, vGuestDateOfBirth, vGuestCode);
//		If ЗначениеЗаполнено(vResult) Тогда
//			ВызватьИсключение vResult;
//		EndIf;
//	Except
//		vErrorDescription = ErrorDescription();
//		Return vErrorDescription;
//	EndTry;
//EndFunction //pmSynchroniseWithSPA