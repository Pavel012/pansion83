//Перем vParentDoc;
//Перем vClient;
//Перем vSumInReportingCurrency;
//Перем vRateSumInReportingCurrency;
//Перем vVATSumInReportingCurrency;
//Перем vDiscountSumInReportingCurrency;
//Перем vVATDiscountSumInReportingCurrency;
//Перем vCommissionSumInReportingCurrency;
//Перем vVATCommissionSumInReportingCurrency;
//
////-----------------------------------------------------------------------------
//Процедура PostToAccounts()
//	RegisterRecords.Взаиморасчеты.Clear();
//	
//	Movement = RegisterRecords.Взаиморасчеты.Add();
//	
//	Movement.RecordType = AccumulationRecordType.Receipt;
//	Movement.Period = Date;
//	
//	FillPropertyValues(Movement, ЛицевойСчет);
//	FillPropertyValues(Movement, ThisObject);
//	
//	// Fill resource, ГруппаНомеров and ГруппаНомеров type
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		If TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//			If НЕ ЗначениеЗаполнено(Resource) Тогда
//				Movement.Ресурс = ParentDoc.Ресурс;
//			EndIf;
//		ElsIf TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or 
//		      TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Тогда
//			If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				Movement.НомерРазмещения = ParentDoc.НомерРазмещения;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Resources
//	Movement.Сумма = Sum - DiscountSum;
//	Movement.СуммаНДС = VATSum - VATDiscountSum;
//	// Take commission into account
//	If ЗначениеЗаполнено(ЛицевойСчет.Agent) And СуммаКомиссии <> 0 Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.Контрагент) And НЕ ЛицевойСчет.Контрагент.DoNotPostCommission And ЛицевойСчет.Agent = ЛицевойСчет.Контрагент Тогда
//			Movement.Сумма = Movement.Сумма - СуммаКомиссии;
//			Movement.СуммаНДС = Movement.СуммаНДС - СуммаКомиссииНДС;
//		EndIf;
//	EndIf;
//	
//	// Attributes
//	Movement.Услуга = Service;
//	Movement.Количество = Movement.Количество;
//	Movement.Начисление = Ref;
//	//Movement.Цена = cmRecalculatePrice(Movement.Сумма, Movement.Количество);
//	
//	// Payment section
//	If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.SplitFolioBalanceByPaymentSections Тогда
//		Movement.PaymentSection = Справочники.ОтделОплаты.EmptyRef();
//	EndIf;
//	
//	RegisterRecords.Взаиморасчеты.Write = True;
//КонецПроцедуры //PostToAccounts
//
////-----------------------------------------------------------------------------
//Процедура PostToAccumulatingDiscountResources()
//	RegisterRecords.НакопитСкидки.Clear();
//	
//	vAccDiscounts = cmGetAccumulatingDiscountTypes(DiscountType);
//	For Each vAccDiscount In vAccDiscounts Do
//		vDiscountType = vAccDiscount.ТипСкидки;
//		If ЗначениеЗаполнено(ParentDoc) And 
//		   (TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Or 
//		    TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or
//		    TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг")) And 
//		   ParentDoc.TurnOffAutomaticDiscounts Тогда
//			If DiscountType <> vDiscountType Тогда
//				Continue;
//			EndIf;
//		EndIf;
//		If НЕ vDiscountType.IsForRackRatesOnly Or vDiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(Тариф) And Тариф.IsRackRate Тогда 
//			vDiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//			If cmIsServiceInServiceGroup(Service, vDiscountServiceGroup) And НЕ Service.IsGiftCertificate Тогда
//				vDiscountTypeObj = vDiscountType.GetObject();
//				vDiscountDimension = Неопределено;
//				vNumberOfPersons = 1;
//				If ЗначениеЗаполнено(ParentDoc) And 
//				   (TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or 
//				    TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Or 
//					TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг")) Тогда
//					vNumberOfPersons = ParentDoc.КоличествоЧеловек;
//				EndIf;
//				vResource = vDiscountTypeObj.pmCalculateResource(Ref, vNumberOfPersons, ЛицевойСчет, DiscountCard, vDiscountDimension);
//				If vResource <> 0 Тогда
//					If ЗначениеЗаполнено(vDiscountDimension) Тогда
//						Movement = RegisterRecords.НакопитСкидки.Add();
//						If vResource > 0 Тогда
//							Movement.RecordType = AccumulationRecordType.Receipt;
//						Else
//							Movement.RecordType = AccumulationRecordType.Expense;
//						EndIf;
//						Movement.Period = Date;
//						Movement.ТипСкидки = vDiscountType;
//						Movement.ИзмерениеСкидки = vDiscountDimension;
//						If vDiscountType.IsPerVisit Or vDiscountType.BonusCalculationFactor <> 0 Тогда
//							If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//								Movement.ГруппаГостей = ЛицевойСчет.ParentDoc.ГруппаГостей;
//							Else
//								Movement.ГруппаГостей = ЛицевойСчет.GuestGroup;
//							EndIf;
//						EndIf;
//						Movement.Ресурс = vResource;
//						If vDiscountTypeObj.BonusCalculationFactor <> 0 Тогда
//							Movement.Бонус = vResource * vDiscountTypeObj.BonusCalculationFactor;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//	
//	RegisterRecords.НакопитСкидки.Write = True;
//КонецПроцедуры //PostToAccumulatingDiscountResources
//
////-----------------------------------------------------------------------------
//Процедура PostToCurrentAccountsReceivable()
//	RegisterRecords.РелизацияТекОтчетПериод.Clear();
//	
//	Movement = RegisterRecords.РелизацияТекОтчетПериод.Add();
//	
//	Movement.RecordType = AccumulationRecordType.Receipt;
//	Movement.Period = Date;
//	Movement.Начисление = Ref;
//	
//	If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		FillPropertyValues(Movement, ЛицевойСчет);
//	EndIf;
//	FillPropertyValues(Movement, ThisObject);
//	
//	// Resources
//	Movement.Количество = Quantity;
//	Movement.Сумма = Sum - DiscountSum;
//	Movement.СуммаНДС = VATSum - VATDiscountSum;
//	Movement.СуммаКомиссии = СуммаКомиссии;
//	
//	// Commission
//	If НЕ ЗначениеЗаполнено(ЛицевойСчет.Agent) Тогда
//		Movement.СуммаКомиссии = 0;
//	ElsIf СуммаКомиссии <> 0 And ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.Agent) Тогда
//		vDoNotPostCommission = False;
//		If ЛицевойСчет.Agent.DoNotPostCommission Тогда
//			vDoNotPostCommission = True;
//		EndIf;
//		If vDoNotPostCommission Or ЛицевойСчет.Agent <> ЛицевойСчет.Контрагент Тогда
//			Movement.СуммаКомиссии = 0;
//			
//			// Add new register record for the agent
//			If НЕ vDoNotPostCommission Тогда
//				Movement = RegisterRecords.РелизацияТекОтчетПериод.Add();
//				
//				Movement.RecordType = AccumulationRecordType.Receipt;
//				Movement.Period = Date;
//				Movement.Начисление = Ref;
//				
//				If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//					FillPropertyValues(Movement, ЛицевойСчет);
//				EndIf;
//				FillPropertyValues(Movement, ThisObject);
//				
//				// Dimensions
//				Movement.Контрагент = ЛицевойСчет.Agent;
//				Movement.Договор = ЛицевойСчет.Agent.AgentCommissionContract;
//				Movement.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//				
//				// Resources
//				Movement.Количество = 0;
//				Movement.Сумма = 0;
//				Movement.СуммаНДС = 0;
//				Movement.СуммаКомиссии = СуммаКомиссии;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	RegisterRecords.РелизацияТекОтчетПериод.Write = True;
//КонецПроцедуры //PostToCurrentAccountsReceivable
//
////-----------------------------------------------------------------------------
//Процедура PostToPaymentServices()
//	RegisterRecords.ПлатежиУслуги.Clear();
//	
//	Movement = RegisterRecords.ПлатежиУслуги.Add();
//	
//	Movement.RecordType = AccumulationRecordType.Receipt;
//	Movement.Period = Date;
//	Movement.СчетПроживания = ЛицевойСчет;
//	Movement.Услуга = Service;
//	
//	// Resources
//	Movement.Сумма = Sum - DiscountSum;
//	
//	RegisterRecords.ПлатежиУслуги.Write = True;
//КонецПроцедуры //PostToPaymentServices
//
////-----------------------------------------------------------------------------
//Процедура PostToSales()
//	RegisterRecords.Продажи.Clear();
//	
//	Movement = RegisterRecords.Продажи.Add();
//	Movement.Period = Date;
//	
//	Movement.ДокОснование = vParentDoc;
//	
//	FillPropertyValues(Movement, vParentDoc, , "ДокОснование");
//	FillPropertyValues(Movement, ThisObject, , "ДокОснование");
//	Movement.Услуга = Service;
//	
//	// Fill Контрагент, contract, guest group, agent from the folio
//	Movement.Контрагент = ЛицевойСчет.Контрагент;
//	Movement.Договор = ЛицевойСчет.Contract;
//	Movement.ГруппаГостей = ЛицевойСчет.GuestGroup;
//	Movement.Агент = ЛицевойСчет.Agent;
//	Movement.СпособОплаты = ЛицевойСчет.PaymentMethod;
//	
//	// Fill ГруппаНомеров rate, accommodation type, ГруппаНомеров and ГруппаНомеров type
//	If ЗначениеЗаполнено(vParentDoc) Тогда
//		If TypeOf(vParentDoc) = Type("DocumentRef.Бронирование") Or TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Тогда
//			If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				Movement.НомерРазмещения = vParentDoc.НомерРазмещения;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(RoomType) Тогда
//				Movement.ТипНомера = vParentDoc.ТипНомера;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(AccommodationType) Тогда
//				Movement.ВидРазмещения = vParentDoc.ВидРазмещения;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(Тариф) Тогда
//				Movement.Тариф = vParentDoc.Тариф;
//			EndIf;
//		ElsIf TypeOf(vParentDoc) = Type("DocumentRef.СчетПроживания") Тогда
//			If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				Movement.НомерРазмещения = vParentDoc.НомерРазмещения;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Movement.Тариф) Тогда
//		Movement.RoomRateType = Movement.Тариф.RoomRateType;
//	EndIf;
//	If ЗначениеЗаполнено(Resource) Тогда
//		Movement.ТипРесурса = Resource.Owner;
//	EndIf;
//			
//	// Fill analitical parameters
//	If ЗначениеЗаполнено(vParentDoc) Тогда
//		If TypeOf(vParentDoc) = Type("DocumentRef.СоставКвоты") Тогда
//			If ЗначениеЗаполнено(vParentDoc.КвотаНомеров) Тогда
//				If ЗначениеЗаполнено(vParentDoc.КвотаНомеров.Договор) Тогда
//					Movement.МаркетингКод = vParentDoc.КвотаНомеров.Договор.МаркетингКод;
//					Movement.ИсточникИнфоГостиница = vParentDoc.КвотаНомеров.Договор.ИсточникИнфоГостиница;
//				ElsIf ЗначениеЗаполнено(vParentDoc.КвотаНомеров.Контрагент) Тогда
//					Movement.МаркетингКод = vParentDoc.КвотаНомеров.Контрагент.МаркетингКод;
//					Movement.ИсточникИнфоГостиница = vParentDoc.КвотаНомеров.Контрагент.ИсточникИнфоГостиница;
//				EndIf;
//			EndIf;
//		EndIf;
//	ElsIf ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.Contract) Тогда
//			Movement.МаркетингКод = ЛицевойСчет.Contract.MarketingCode;
//			Movement.ИсточникИнфоГостиница = ЛицевойСчет.Contract.SourceOfBusiness;
//		ElsIf ЗначениеЗаполнено(ЛицевойСчет.Контрагент) Тогда
//			Movement.МаркетингКод = ЛицевойСчет.Контрагент.MarketingCode;
//			Movement.ИсточникИнфоГостиница = ЛицевойСчет.Контрагент.SourceOfBusiness;
//		EndIf;
//		If ЗначениеЗаполнено(ЛицевойСчет.Client) Тогда
//			If ЗначениеЗаполнено(ЛицевойСчет.Client.MarketingCode) Тогда
//				Movement.МаркетингКод = ЛицевойСчет.Client.MarketingCode;
//			EndIf;
//			If ЗначениеЗаполнено(ЛицевойСчет.Client.SourceOfBusiness) Тогда
//				Movement.ИсточникИнфоГостиница = ЛицевойСчет.Client.SourceOfBusiness;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	Movement.Количество = Movement.Количество;
//	
//	Movement.Продажи = vSumInReportingCurrency;
//	Movement.ПродажиБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	Movement.СуммаНДС = vVATSumInReportingCurrency;
//	If IsRoomRevenue Тогда
//		Movement.ДоходНомеров = vSumInReportingCurrency;
//		Movement.ДоходПродажиБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	Else
//		Movement.ДоходНомеров = 0;
//		Movement.ДоходПродажиБезНДС = 0;
//	EndIf;
//	If Movement.ПроданоДопМест <> 0 Тогда
//		Movement.ДоходДопМеста = vSumInReportingCurrency;
//		Movement.ДоходДопМестаБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	Else
//		Movement.ДоходДопМеста = 0;
//		Movement.ДоходДопМестаБезНДС = 0;
//	EndIf;
//	If IsResourceRevenue Тогда
//		If НЕ RoomRevenueAmountsOnly Тогда
//			Movement.ПроданоЧасовРесурса = Movement.Количество;
//			If Movement.Услуга.IsPricePerMinute Тогда
//				Movement.ПроданоЧасовРесурса = Movement.Количество/60;
//			EndIf;
//		EndIf;
//		Movement.ДоходРес = Movement.Продажи;
//		Movement.ДоходРесБезНДС = Movement.ПродажиБезНДС;
//	EndIf;
//	
//	Movement.СуммаСкидки = vDiscountSumInReportingCurrency;
//	Movement.СуммаСкидкиБезНДС = vDiscountSumInReportingCurrency - vVATDiscountSumInReportingCurrency;
//	If vDiscountSumInReportingCurrency = 0 Тогда
//		Movement.Скидка = 0;
//		Movement.ТипСкидки = Справочники.DiscountTypes.EmptyRef();
//	EndIf;
//	
//	Movement.СуммаКомиссии = vCommissionSumInReportingCurrency;
//	Movement.КомиссияБезНДС = vCommissionSumInReportingCurrency - vVATCommissionSumInReportingCurrency;
//	
//	If Movement.ЗаездГостей <> 0 And Movement.Количество <> 0 Тогда
//		Movement.ЗаездНомеров = ?(Movement.ПроданоНомеров < 0, -1, 1) * Movement.ПроданоНомеров/Movement.Количество;
//		Movement.ЗаездМест = ?(Movement.ПроданоМест < 0, -1, 1) * Movement.ПроданоМест/Movement.Количество;
//		Movement.ЗаездДополнительныхМест = ?(Movement.ПроданоДопМест < 0, -1, 1) * Movement.ПроданоДопМест/Movement.Количество;
//	Else
//		Movement.ЗаездНомеров = 0;
//		Movement.ЗаездМест = 0;
//		Movement.ЗаездДополнительныхМест = 0;
//	EndIf;
//	
//	Movement.Клиент = vClient;
//	
//	// Fill ГруппаНомеров rate deviation
//	If НЕ IsAdditional And RateSum <> 0 Тогда
//		Movement.СуммаТарифаПрож = vRateSumInReportingCurrency;
//		Movement.РазницаТарифИНачСуммой = vSumInReportingCurrency - vRateSumInReportingCurrency;
//	EndIf;
//	
//	Movement.УчетнаяДата = BegOfDay(Date);
//	Movement.Цена = cmRecalculatePrice(vSumInReportingCurrency, Quantity);
//	Movement.ЭтоСторно = False;
//	
//	RegisterRecords.Продажи.Write = True;
//КонецПроцедуры //PostToSales
//
////-----------------------------------------------------------------------------
//Процедура PostToHotelProductSales()
//	RegisterRecords.ПродажиПутевокКурсовок.Clear();
//	
//	Movement = RegisterRecords.ПродажиПутевокКурсовок.Add();
//	
//	If ЗначениеЗаполнено(ПутевкаКурсовка) And ЗначениеЗаполнено(ПутевкаКурсовка.CheckInDate) And ПутевкаКурсовка.FixProductPeriod Тогда
//		Movement.Period = BegOfDay(ПутевкаКурсовка.CheckInDate);
//	ElsIf ЗначениеЗаполнено(vParentDoc) Тогда
//		If (TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Or 
//			TypeOf(vParentDoc) = Type("DocumentRef.Бронирование")) And 
//		   ЗначениеЗаполнено(vParentDoc.CheckInDate) Тогда
//			Movement.Period = BegOfDay(vParentDoc.CheckInDate);
//		ElsIf TypeOf(vParentDoc) = Type("DocumentRef.СчетПроживания") And 
//			  ЗначениеЗаполнено(vParentDoc.DateTimeFrom) Тогда
//			Movement.Period = BegOfDay(vParentDoc.DateTimeFrom);
//		Else
//			Movement.Period = Date;
//		EndIf;
//	Else
//		Movement.Period = Date;
//	EndIf;
//	
//	Movement.ДокОснование = vParentDoc;
//	
//	FillPropertyValues(Movement, vParentDoc, , "ДокОснование");
//	FillPropertyValues(Movement, ThisObject, , "ДокОснование");
//	Movement.Услуга = Service;
//	
//	// Fill ГруппаНомеров rate, accommodation type, ГруппаНомеров and ГруппаНомеров type
//	If ЗначениеЗаполнено(vParentDoc) Тогда
//		If TypeOf(vParentDoc) = Type("DocumentRef.Бронирование") Or TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Тогда
//			If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				Movement.НомерРазмещения = vParentDoc.НомерРазмещения;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(RoomType) Тогда
//				Movement.ТипНомера = vParentDoc.ТипНомера;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(AccommodationType) Тогда
//				Movement.ВидРазмещения = vParentDoc.ВидРазмещения;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(Тариф) Тогда
//				Movement.Тариф = vParentDoc.Тариф;
//			EndIf;
//		ElsIf TypeOf(vParentDoc) = Type("DocumentRef.СчетПроживания") Тогда
//			If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				Movement.НомерРазмещения = vParentDoc.НомерРазмещения;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	Movement.Продажи = vSumInReportingCurrency;
//	Movement.ПродажиБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	If IsRoomRevenue Тогда
//		Movement.ДоходНомеров = vSumInReportingCurrency;
//		Movement.ДоходПродажиБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	Else
//		Movement.ДоходНомеров = 0;
//		Movement.ДоходПродажиБезНДС = 0;
//	EndIf;
//	If Movement.ПроданоДопМест <> 0 Тогда
//		Movement.ДоходДопМеста = vSumInReportingCurrency;
//		Movement.ДоходДопМестаБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	Else
//		Movement.ДоходДопМеста = 0;
//		Movement.ДоходДопМестаБезНДС = 0;
//	EndIf;
//	Movement.СуммаСкидки = vDiscountSumInReportingCurrency;
//	Movement.СуммаСкидкиБезНДС = vDiscountSumInReportingCurrency - vVATDiscountSumInReportingCurrency;
//	Movement.СуммаКомиссии = vCommissionSumInReportingCurrency;
//	Movement.КомиссияБезНДС = vCommissionSumInReportingCurrency - vVATCommissionSumInReportingCurrency;
//	
//	If Movement.ЗаездГостей <> 0 And Movement.Количество <> 0 Тогда
//		Movement.ЗаездНомеров = ?(Movement.ПроданоНомеров < 0, -1, 1) * Movement.ПроданоНомеров/Movement.Количество;
//		Movement.ЗаездМест = ?(Movement.ПроданоМест < 0, -1, 1) * Movement.ПроданоМест/Movement.Количество;
//		Movement.ЗаездДополнительныхМест = ?(Movement.ПроданоДопМест < 0, -1, 1) * Movement.ПроданоДопМест/Movement.Количество;
//	Else
//		Movement.ЗаездНомеров = 0;
//		Movement.ЗаездМест = 0;
//		Movement.ЗаездДополнительныхМест = 0;
//	EndIf;
//	
//	Movement.Клиент = vClient;
//	
//	Movement.УчетнаяДата = BegOfDay(Date);
//	Movement.Цена = cmRecalculatePrice(vSumInReportingCurrency, Quantity);
//	Movement.ЭтоСторно = False;
//	
//	// Fill Контрагент, contract, guest group, agent from the folio
//	Movement.Контрагент = ЛицевойСчет.Контрагент;
//	Movement.Договор = ЛицевойСчет.Contract;
//	Movement.ГруппаГостей = ЛицевойСчет.GuestGroup;
//	Movement.Агент = ЛицевойСчет.Agent;
//	Movement.СпособОплаты = ЛицевойСчет.PaymentMethod;
//	
//	RegisterRecords.ПродажиПутевокКурсовок.Write = True;
//	
//	// Write to the hotel product log
//	RegisterRecords.РеестрПутевокКурсовок.Clear();
//	
//	LogMovement = RegisterRecords.РеестрПутевокКурсовок.AddReceipt();
//	
//	FillPropertyValues(LogMovement, ThisObject);
//	LogMovement.Period = ?(ЗначениеЗаполнено(ПутевкаКурсовка.CreateDate), ПутевкаКурсовка.CreateDate, Date);
//	LogMovement.Сумма = Sum - DiscountSum;
//	
//	RegisterRecords.РеестрПутевокКурсовок.Write = True;
//КонецПроцедуры //PostToHotelProductSales
//
////-----------------------------------------------------------------------------
//Процедура PostToAnaliticalRegisters()
//	// Fill parent doc	
//	vParentDoc = ParentDoc;
//	If НЕ ЗначениеЗаполнено(vParentDoc) Тогда
//		vParentDoc = ЛицевойСчет;
//	EndIf;
//	
//	vClient = Справочники.Клиенты.EmptyRef();
//	vStruct = New Structure("Клиент", Неопределено);
//	FillPropertyValues(vStruct, vParentDoc);
//	If ЗначениеЗаполнено(vStruct.Client) Тогда
//		vClient = vStruct.Client;
//	Else
//		If TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Тогда
//			vClient = vParentDoc.Guest;
//		ElsIf TypeOf(vParentDoc) = Type("DocumentRef.Бронирование") Тогда 
//			vClient = vParentDoc.Guest;
//		ElsIf TypeOf(vParentDoc) = Type("DocumentRef.БроньУслуг") Тогда 
//			vClient = vParentDoc.Client;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(vClient) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//			vParentDoc = ЛицевойСчет.ParentDoc;
//			If TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Тогда
//				vClient = vParentDoc.Клиент;
//			ElsIf TypeOf(vParentDoc) = Type("DocumentRef.Бронирование") Тогда 
//				vClient = vParentDoc.Клиент;
//			ElsIf TypeOf(vParentDoc) = Type("DocumentRef.БроньУслуг") Тогда 
//				vClient = vParentDoc.Клиент;
//			EndIf;
//		EndIf;	
//	EndIf;
//	
//	// Fill resources in reporting currency
//	vSumInReportingCurrency = Round(cmConvertCurrencies(Sum - DiscountSum, FolioCurrency, FolioCurrencyExchangeRate, ReportingCurrency, ReportingCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	vVATSumInReportingCurrency = cmCalculateVATSum(VATRate, vSumInReportingCurrency);
//	vDiscountSumInReportingCurrency = Round(cmConvertCurrencies(DiscountSum, FolioCurrency, FolioCurrencyExchangeRate, ReportingCurrency, ReportingCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	vVATDiscountSumInReportingCurrency = cmCalculateVATSum(VATRate, vDiscountSumInReportingCurrency);
//	vCommissionSumInReportingCurrency = Round(cmConvertCurrencies(СуммаКомиссии, FolioCurrency, FolioCurrencyExchangeRate, ReportingCurrency, ReportingCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	vVATCommissionSumInReportingCurrency = cmCalculateVATSum(VATRate, vCommissionSumInReportingCurrency);
//	vRateSumInReportingCurrency = Round(cmConvertCurrencies(RateSum, FolioCurrency, FolioCurrencyExchangeRate, ReportingCurrency, ReportingCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	
//	// Post to the sales
//	PostToSales();
//	
//	// Post to the hotel product sales
//	If ЗначениеЗаполнено(ПутевкаКурсовка) And ЗначениеЗаполнено(Service) And Service.IsHotelProductService Тогда
//		PostToHotelProductSales();
//	EndIf;
//КонецПроцедуры //PostToAnaliticalRegisters
//
////-----------------------------------------------------------------------------
//Процедура PostToServiceRegistration()
//	RegisterRecords.РегистрацияУслуги.Clear();
//	
//	Movement = RegisterRecords.РегистрацияУслуги.Add();
//	
//	Movement.RecordType = AccumulationRecordType.Receipt;
//	Movement.Period = Date;
//	
//	FillPropertyValues(Movement, ЛицевойСчет);
//	If ValueisFilled(ParentDoc) Тогда
//		FillPropertyValues(Movement, ParentDoc);
//	EndIf;
//	FillPropertyValues(Movement, ThisObject);
//	Movement.Услуга = Service;
//	
//	// Fill accounting date
//	Movement.УчетнаяДата = BegOfDay(Date);
//	
//	// Fill resource
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		If TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//			If НЕ ЗначениеЗаполнено(Resource) Тогда
//				Movement.Ресурс = ParentDoc.Ресурс;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Fill ГруппаНомеров and client
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		If TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or 
//		   TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Тогда
//			Movement.Клиент = ParentDoc.Клиент;
//			If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				Movement.НомерРазмещения = ParentDoc.НомерРазмещения;
//			EndIf;
//		EndIf;
//	Else
//		If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//			Movement.НомерРазмещения = ЛицевойСчет.ГруппаНомеров;
//		EndIf;
//	EndIf;
//	
//	// Resources
//	Movement.Сумма = Sum - DiscountSum;
//	Movement.Количество = Quantity;
//	
//	// Attributes
//	Movement.Цена = cmRecalculatePrice(Movement.Сумма, Movement.Количество);
//	
//	RegisterRecords.РегистрацияУслуги.Write = True;
//КонецПроцедуры //PostToServiceRegistration
//
////-----------------------------------------------------------------------------
//Function GetBoundServiceTurnover(pService, rQuantity)
//	vTurnover = 0;
//	rQuantity = 0;
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	SalesTurnovers.Услуга,
//	|	SalesTurnovers.SalesTurnover AS SumTurnover,
//	|	SalesTurnovers.QuantityTurnover
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Period,
//	|			СчетПроживания = &qFolio
//	|				AND Услуга = &qService) AS SalesTurnovers";
//	vQry.SetParameter("qPeriodFrom", '00010101');
//	vQry.SetParameter("qPeriodTo", '00010101');
//	vQry.SetParameter("qService", pService);
//	vQry.SetParameter("qFolio", ЛицевойСчет);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do
//		vTurnover = vTurnover + vQryResRow.SumTurnover;
//		rQuantity = rQuantity + vQryResRow.QuantityTurnover;
//	EndDo;
//	Return vTurnover;
//EndFunction //GetBoundServiceTurnover
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// 1. Check should we clear hotel product from the charge
//	If ЗначениеЗаполнено(ПутевкаКурсовка) Тогда
//		If ЗначениеЗаполнено(Service) And НЕ Service.IsHotelProductService Тогда
//			ПутевкаКурсовка = Справочники.ПутевкиКурсовки.EmptyRef();
//			Write(DocumentWriteMode.Write);
//		EndIf;
//	EndIf;
//	
//	// 2. Post to Accounts
//	PostToAccounts();
//	
//	// 3. Post to Accumulating discounts
//	PostToAccumulatingDiscountResources();
//	
//	// 4. Post to Current accounts receivable
//	PostToCurrentAccountsReceivable();
//	
//	// 5. Post to Payment services
//	If Гостиница.DoPaymentsDistributionToServices Тогда
//		PostToPaymentServices();
//	EndIf;
//	
//	// 6. Fill analitics
//	PostToAnaliticalRegisters();
//	
//	// 7. Post to service registration
//	If ЗначениеЗаполнено(Service) And Service.ServiceRegistrationIsTurnedOn Тогда
//		PostToServiceRegistration();
//	EndIf;
//	
//	// 8. If bound service is defined for the current one then we have to do
//	// couple of movements where second one is correction for the bound service
//	vBoundService = cmGetBoundService(Service);
//	If vBoundService = Service Тогда
//		vBoundService = Неопределено;
//	EndIf;
//	If ЗначениеЗаполнено(vBoundService) And НЕ IsFixedCharge Тогда
//		vBoundChargeObj = Неопределено;
//		If ЗначениеЗаполнено(BoundCharge) Тогда
//			vBoundChargeObj = BoundCharge.GetObject();
//			If BoundCharge.Posted Тогда
//				vBoundChargeObj.Write(DocumentWriteMode.UndoPosting);
//			EndIf;
//		EndIf;
//		// Check if bound service was charged at all
//		vBoundServiceQuantity = 0;
//		vBoundServiceTurnover = GetBoundServiceTurnover(vBoundService, vBoundServiceQuantity);
//		If vBoundServiceTurnover > 0 And (Sum - DiscountSum) > 0 And Price <> 0 Тогда
//			If НЕ ЗначениеЗаполнено(BoundCharge) Тогда
//				vBoundChargeObj = Documents.Начисление.CreateDocument();
//			ElsIf BoundCharge.DeletionMark Тогда
//				vBoundChargeObj.SetDeletionMark(False);
//			EndIf;
//			FillPropertyValues(vBoundChargeObj, ThisObject, , "Number, BoundCharge");
//			vBoundChargeObj.Услуга = vBoundService;
//			vBoundChargeObj.BoundCharge = Ref;
//			vBoundChargeObj.IsFixedCharge = True;
//			vCoeff = 1;
//			vBoundChargeSum = Sum - DiscountSum;
//			If (Sum - DiscountSum) > vBoundServiceTurnover Тогда
//				vCoeff = -vBoundServiceTurnover/(Sum - DiscountSum);
//				vBoundChargeSum = vBoundServiceTurnover;
//			EndIf;
//			If Quantity > vBoundServiceQuantity Тогда
//				vBoundChargeObj.Количество = -vBoundServiceQuantity;
//			Else
//				vBoundChargeObj.Количество = -vBoundChargeObj.Количество;
//			EndIf;
//			vBoundChargeObj.Сумма = -vBoundChargeSum;
//			If vBoundChargeObj.Количество <> 0 Тогда
//				vBoundChargeObj.Цена = Round(vBoundChargeObj.Сумма/vBoundChargeObj.Количество, 2);
//			Else
//				vBoundChargeObj.Цена = vBoundChargeSum;
//			EndIf;
//			vBoundChargeObj.СуммаНДС = vCoeff * (vBoundChargeObj.СуммаНДС - vBoundChargeObj.НДСскидка);
//			vBoundChargeObj.Скидка = 0;
//			vBoundChargeObj.ОснованиеСкидки = "";
//			vBoundChargeObj.ТипСкидки = Справочники.DiscountTypes.EmptyRef();
//			vBoundChargeObj.DiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//			vBoundChargeObj.ДисконтКарт = Справочники.ДисконтныеКарты.EmptyRef();
//			vBoundChargeObj.СуммаСкидки = 0;
//			vBoundChargeObj.НДСскидка = 0;
//			vBoundChargeObj.СуммаКомиссии = vCoeff * vBoundChargeObj.СуммаКомиссии;
//			vBoundChargeObj.СуммаКомиссииНДС = vCoeff * vBoundChargeObj.СуммаКомиссииНДС;
//			vBoundChargeObj.ПроданоНомеров = 0;
//			vBoundChargeObj.ПроданоМест = 0;
//			vBoundChargeObj.ПроданоДопМест = 0;
//			vBoundChargeObj.ЧеловекаДни = 0;
//			vBoundChargeObj.ЗаездГостей = 0;
//			vBoundChargeObj.Write(DocumentWriteMode.Posting);
//			// Fill reference
//			BoundCharge = vBoundChargeObj.Ref;
//			IsFixedCharge = False;
//			Write(DocumentWriteMode.Write);
//		Else
//			If ЗначениеЗаполнено(BoundCharge) And НЕ BoundCharge.DeletionMark Тогда
//				vBoundChargeObj.SetDeletionMark(True);
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //Posting
//
////-----------------------------------------------------------------------------
//Процедура UndoPosting(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If ЗначениеЗаполнено(BoundCharge) And НЕ IsFixedCharge Тогда
//		If BoundCharge.Posted Тогда
//			vBoundChargeObj = BoundCharge.GetObject();
//			vBoundChargeObj.Write(DocumentWriteMode.UndoPosting);
//		EndIf;
//	EndIf;
//КонецПроцедуры //UndoPosting
//
////-----------------------------------------------------------------------------
//Процедура pmFillCalendarDayTypeByFolio() Экспорт
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		If TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or
//		   TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Тогда
//			If ЗначениеЗаполнено(ParentDoc.Тариф) And ЗначениеЗаполнено(ParentDoc.Тариф.Calendar) Тогда
//				vCalendarDays = ParentDoc.Тариф.Calendar.GetObject().pmGetDays(Date, Date, ParentDoc.CheckInDate, ParentDoc.ДатаВыезда);
//				If vCalendarDays.Count() > 0 Тогда
//					CalendarDayType = vCalendarDays.Get(0).ТипДняКалендаря;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillCalendarDayTypeByFolio
//
////-----------------------------------------------------------------------------
//Процедура pmFillByFolio(pFolio) Экспорт
//	If pFolio = Documents.СчетПроживания.EmptyRef() Тогда
//		Return;
//	EndIf;
//	// ЛицевойСчет and folio currency
//	ЛицевойСчет = pFolio;
//	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница) Тогда
//		If Гостиница <> ЛицевойСчет.Гостиница Тогда
//			Гостиница = ЛицевойСчет.Гостиница;
//			SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ЛицевойСчет.Фирма) Тогда
//		Фирма = ЛицевойСчет.Фирма;
//		VATRate = Фирма.VATRate;
//	EndIf;
//	FolioCurrency = ЛицевойСчет.FolioCurrency;
//	FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ExchangeRateDate);
//	// Client
//	If ЗначениеЗаполнено(pFolio.Клиент) Тогда
//		// Client type
//		ClientType = pFolio.Клиент.ТипКлиента;
//		ClientTypeConfirmationText = pFolio.Клиент.СтрокаПодтверждения;
//	EndIf;
//	// ГруппаНомеров and ГруппаНомеров type
//	If ЗначениеЗаполнено(pFolio.НомерРазмещения) Тогда
//		ГруппаНомеров = pFolio.НомерРазмещения;
//		If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//			RoomType = ГруппаНомеров.ТипНомера;
//		EndIf;
//	EndIf;
//	// Parent document
//	ParentDoc = pFolio.ДокОснование;
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		// Client type
//		ClientType = ParentDoc.ТипКлиента;
//		ClientTypeConfirmationText = ParentDoc.СтрокаПодтверждения;
//		// Discount
//		DiscountCard = ParentDoc.ДисконтКарт;
//		DiscountType = ParentDoc.ТипСкидки;
//		DiscountConfirmationText = ParentDoc.ОснованиеСкидки;
//		Discount = ParentDoc.Скидка;
//		DiscountServiceGroup = ParentDoc.DiscountServiceGroup;
//		// Marketing code
//		MarketingCode = ParentDoc.МаркетингКод;
//		MarketingCodeConfirmationText = ParentDoc.MarketingCodeConfirmationText;
//		// Source of business
//		SourceOfBusiness = ParentDoc.ИсточникИнфоГостиница;
//	Else
//		// Discount
//		DiscountCard = pFolio.FolioDiscountCard;
//		DiscountType = pFolio.FolioDiscountType;
//		DiscountConfirmationText = "";
//		If ЗначениеЗаполнено(DiscountType) Тогда
//			DiscountConfirmationText = DiscountType.ConfirmationPattern;
//			DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//			If DiscountType.IsAccumulatingDiscount Тогда
//				pmCalculateAccumulationDiscount();
//			Else	
//				vDiscountTypeObj = DiscountType.GetObject();
//				Discount = DiscountType.GetObject().pmGetDiscount(Date, Service, Гостиница);
//			EndIf;
//		EndIf;
//	EndIf;
//	// Calendar day type
//	pmFillCalendarDayTypeByFolio();
//	// Commission
//	If ЗначениеЗаполнено(ЛицевойСчет.Agent) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//			КомиссияАгента = ЛицевойСчет.ParentDoc.КомиссияАгента;
//			ВидКомиссииАгента = ЛицевойСчет.ParentDoc.ВидКомиссииАгента;
//			КомиссияАгентУслуги = ЛицевойСчет.ParentDoc.КомиссияАгентУслуги;
//		Else
//			КомиссияАгента = ЛицевойСчет.Agent.КомиссияАгента;
//			ВидКомиссииАгента = ЛицевойСчет.Agent.ВидКомиссииАгента;
//			КомиссияАгентУслуги = ЛицевойСчет.Agent.КомиссияАгентУслуги;
//		EndIf;
//	EndIf;
//	// Гостиница product
//	If ЗначениеЗаполнено(ЛицевойСчет.HotelProduct) Тогда
//		ПутевкаКурсовка = ЛицевойСчет.HotelProduct;
//	EndIf;
//КонецПроцедуры //pmFillByFolio
//
////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
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
//	If НЕ ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Лицевой счет> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
//	Else
//		If ЛицевойСчет.DeletionMark Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "<Лицевой счет> помечен на удаление!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<СчетПроживания> is marked for deletion!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<СчетПроживания> is marked for deletion!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Service) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Услуга> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Услуга> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Услуга> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Услуга", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ReportingCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Отчетная валюта> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Reporting Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Reporting Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Валюта", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата курса> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
//	EndIf;
//	If Price = 0 And Sum <> 0 Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Цена> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Цена> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Цена> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(Service) And Service.IsGiftCertificate Тогда
//		If НЕ IsBlankString(GiftCertificate) Тогда
//			vOtherGiftCertCharges = cmGetGiftCertificateCharges(GiftCertificate, Ref);
//			If vOtherGiftCertCharges.Count() > 0 Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Подарочный сертификат (" + TrimAll(GiftCertificate) + ") уже был продан!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Gift certificate (" + TrimAll(GiftCertificate) + ") was already sold!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "Gift certificate (" + TrimAll(GiftCertificate) + ") was already sold!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//			EndIf;
//			If Quantity <> 1 Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Реквизит <Количество> должен быть равен 1!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "<Количество> attribute should be 1!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "<Количество> attribute should be 1!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Количество", pAttributeInErr);
//			Endif;
//		EndIf;
//	EndIf;
//	If НЕ Posted Тогда
//		If НЕ ЗначениеЗаполнено(ClientType)  Тогда
//			If НЕ cmCheckUserPermissions("HavePermissionToSkipInputOfClientType") Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Реквизит <Тип клиента> должен быть заполнен!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "<Клиент type> attribute should be filled!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "<Клиент type> attribute should be filled!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "ТипКлиента", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check user rights to do storno
//	If Sum < 0 Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToEditPostedFolioTransactions") Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "У вас нет прав на сторнирование начислений!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "You do not have rights to Сторно charges!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "You do not have rights to Сторно charges!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Сумма", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //CheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Author = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate
//
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Suppose it is additional service
//	IsAdditional = True;
//	// Fill author and document date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	ExchangeRateDate = BegOfDay(CurrentDate());
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		FolioCurrency  = Гостиница.FolioCurrency;
//		FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ExchangeRateDate);
//		ReportingCurrency = Гостиница.ReportingCurrency;
//		ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, ExchangeRateDate);
//		Фирма = Гостиница.Фирма;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.СчетПроживания") Тогда
//			pmFillByFolio(pBase);
//		EndIf;
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If pWriteMode = DocumentWriteMode.Posting Тогда
//		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//		If Sum < 0 And НЕ ЗначениеЗаполнено(BoundCharge) Тогда
//			WriteLogEvent(NStr("en='SuspiciousEvents.ChargeWithNegativeSum';de='SuspiciousEvents.ChargeWithNegativeSum';ru='СигналыОПодозрительныхДействиях.НачислениеСОтрицательнойСуммой'"), EventLogLevel.Warning, Metadata(), Ref, TrimAll(Service) + ", " + cmFormatSum(Sum, FolioCurrency));
//		EndIf;
//	Else
//		// Check if this charge is closed by settlement
//		If Posted And ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And 
//		   pWriteMode = DocumentWriteMode.UndoPosting And 
//		  (Sum <> 0 Or Quantity <> 0) And IsAdditional And 
//		   ЗначениеЗаполнено(ЛицевойСчет) And ЛицевойСчет.IsClosed Тогда
//			vChargeBalanceIsZero = False;
//			vChargeBalancesRow = cmGetChargeCurrentAccountsReceivableBalance(Ref);
//			If vChargeBalancesRow <> Неопределено Тогда
//				If vChargeBalancesRow.SumBalance = 0 And vChargeBalancesRow.QuantityBalance = 0 Тогда
//					vChargeBalanceIsZero = True;
//				EndIf;
//			Else
//				vChargeBalanceIsZero = True;
//			EndIf;
//			If vChargeBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='This charge is closed by settlement! Charge is read only.';
//				             |ru='Начисление уже закрыто актом об оказании услуг! Редактирование такого начисления запрещено.';
//							 |de='Die Anrechnung wurde bereits über ein Übergabeprotokoll über die Erbringung von Dienstleistungen geschlossen! Die Bearbeitung einer solchen Anrechnung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check if this charge is in closed day
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditClosedDateDocs And 
//	  (pWriteMode = DocumentWriteMode.Posting Or pWriteMode = DocumentWriteMode.UndoPosting) And  
//	  (НЕ ЗначениеЗаполнено(ChargeTransfer) Or ЗначениеЗаполнено(ChargeTransfer) And cmIfChargeIsInClosedDay(ChargeTransfer)) Тогда
//		vChargeIsInClosedDay = cmIfChargeIsInClosedDay(ThisObject);
//		If vChargeIsInClosedDay Тогда
//			pCancel = True;
//			If ЭтоНовый() Тогда
//				Message(NStr("en='Charge date is closed! You can not post charge on this day.';
//				             |ru='День закрыт! Нельзя провести начисление этой датой.';
//							 |de='Der Tag ist geschlossen! Eine Anrechnung zu diesem Datum ist nicht möglich.'"), MessageStatus.Attention);
//			Else
//				Message(NStr("en='This charge is in closed day! Charge is read only.';
//				             |ru='Начисление в закрытом дне! Редактирование такого начисления запрещено.';
//							 |de='Anrechnung am geschlossenen Tag! Die Bearbeitung einer solchen Abrechnung ist verboten.'"), MessageStatus.Attention);
//			EndIf;
//			Return;
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура OnWrite(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If DeletionMark Тогда
//		Try
//			// Delete bound charge
//			If ЗначениеЗаполнено(BoundCharge) And НЕ IsFixedCharge Тогда
//				vRepostCharges = False;
//				vBoundChargeObj = BoundCharge.GetObject();
//				If BoundCharge.Posted Тогда
//					vBoundChargeObj.Write(DocumentWriteMode.UndoPosting);
//					vRepostCharges = True;
//				EndIf;
//				If НЕ vBoundChargeObj.DeletionMark Тогда
//					vBoundChargeObj.SetDeletionMark(True);
//					vRepostCharges = True;
//				EndIf;
//				// Repost all other charges
//				If vRepostCharges Тогда
//					vFolioObj = ЛицевойСчет.GetObject();
//					vFolioObj.pmRepostAdditionalCharges(Ref);
//				EndIf;
//			EndIf;
//			// Delete bound storno
//			If IsAdditional Тогда
//				vQry = New Query();
//				vQry.Text = 
//				"SELECT
//				|	Сторно.Ref
//				|FROM
//				|	Document.Сторно AS Сторно
//				|WHERE
//				|	Сторно.Posted
//				|	AND Сторно.ParentCharge = &qCharge";
//				vQry.SetParameter("qCharge", Ref);
//				vStornos = vQry.Execute().Unload();
//				For Each vStornosRow In vStornos Do
//					vStornoObj = vStornosRow.Ref.GetObject();
//					vStornoObj.SetDeletionMark(True);
//				EndDo;
//			EndIf;
//			// Delete bound resource reservation document
//			If IsAdditional And ЗначениеЗаполнено(Service) And ЗначениеЗаполнено(Service.Resource) And 
//			   ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") And 
//			   НЕ ParentDoc.DoCharging And ParentDoc.Posted Тогда
//				ParentDoc.ПолучитьОбъект().УстановитьПометкуУдаления(Истина);
//			EndIf;
//		Except
//		EndTry;
//	EndIf;
//КонецПроцедуры //OnWrite
//
////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Write log event
//	If Posted Тогда
//		// Check if this charge is closed by settlement
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And 
//		  (Sum <> 0 Or Quantity <> 0) And 
//		   ЗначениеЗаполнено(ЛицевойСчет) And ЛицевойСчет.IsClosed Тогда
//			vChargeBalanceIsZero = False;
//			vChargeBalancesRow = cmGetChargeCurrentAccountsReceivableBalance(Ref);
//			If vChargeBalancesRow <> Неопределено Тогда
//				If vChargeBalancesRow.SumBalance = 0 And vChargeBalancesRow.QuantityBalance = 0 Тогда
//					vChargeBalanceIsZero = True;
//				EndIf;
//			Else
//				vChargeBalanceIsZero = True;
//			EndIf;
//			If vChargeBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='This charge is closed by settlement! Charge is read only.';
//				             |ru='Начисление уже закрыто актом об оказании услуг! Редактирование такого начисления запрещено.';
//							 |de='Die Anrechnung wurde bereits über ein Übergabeprotokoll über die Erbringung von Dienstleistungen geschlossen! Die Bearbeitung einer solchen Anrechnung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		// Check if this charge is in closed day
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditClosedDateDocs Тогда
//			vChargeIsInClosedDay = cmIfChargeIsInClosedDay(Ref);
//			If vChargeIsInClosedDay Тогда
//				pCancel = True;
//				Message(NStr("en='This charge is in closed day! Charge is read only.';
//				             |ru='Начисление в закрытом дне! Редактирование такого начисления запрещено.';
//							 |de='Anrechnung am geschlossenen Tag! Die Bearbeitung einer solchen Abrechnung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		// Log charge deletion
//		WriteLogEvent(NStr("en='SuspiciousEvents.ChargeDeletion';de='SuspiciousEvents.ChargeDeletion';ru='СигналыОПодозрительныхДействиях.УдалениеНачисления'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Document deletion';ru='Непосредственное удаление';de='Unmittelbare Löschung'") + Chars.LF + TrimAll(Service) + ", " + cmFormatSum(Sum, FolioCurrency));
//	EndIf;
//	// Delete bound charge
//	If ЗначениеЗаполнено(BoundCharge) And НЕ IsFixedCharge Тогда
//		vBoundChargeObj = BoundCharge.GetObject();
//		If BoundCharge.Posted Тогда
//			vBoundChargeObj.Write(DocumentWriteMode.UndoPosting);
//		EndIf;
//		vBoundChargeObj.Delete();
//		// Repost all other charges
//		vFolioObj = ЛицевойСчет.GetObject();
//		vFolioObj.pmRepostAdditionalCharges(Ref);
//	EndIf;
//	// Delete bound resource reservation document
//	If IsAdditional And ЗначениеЗаполнено(Service) And ЗначениеЗаполнено(Service.Resource) And 
//	   ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") And 
//	   НЕ ParentDoc.DoCharging And ParentDoc.Posted Тогда
//		ParentDoc.GetObject().SetDeletionMark(True);
//	EndIf;
//КонецПроцедуры //BeforeDelete
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
//	EndIf;
//	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
//	EndIf;
//	If vPrefix <> "" Тогда
//		pPrefix = vPrefix;
//	EndIf;
//КонецПроцедуры //OnSetNewNumber
//
////-----------------------------------------------------------------------------
//Function pmGetAccumulatingDiscountResources() Экспорт
//	// Initialize map with resources
//	vRes = New ValueTable();
//	vRes.Columns.Add("ТипСкидки", cmGetCatalogTypeDescription("ТипыСкидок"), "Скидка type", 20);
//	vRes.Columns.Add("ИзмерениеСкидки", cmGetDiscountDimensionTypeDescription(), "Скидка dimension", 20);
//	vRes.Columns.Add("Ресурс", cmGetAccumulatingDiscountResourceTypeDescription(), "Скидка Ресурс", 20);
//	vRes.Columns.Add("Бонус", cmGetAccumulatingDiscountResourceTypeDescription(), "Бонус", 20);
//	// Check folio
//	If НЕ ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		Return vRes;
//	EndIf;
//	// Get list of accumulating discount types defined in the catalog
//	vAccDisTypes = cmGetAccumulatingDiscountTypes(DiscountType);
//	// Get resources
//	For Each vAccDisType In vAccDisTypes Do
//		vDiscountType = vAccDisType.ТипСкидки;
//		vDiscountTypeObj = vDiscountType.GetObject();
//		vAccDisRes = vDiscountTypeObj.pmGetAccumulatingDiscountResources(Date,
//		                                                                 ЛицевойСчет.Контрагент,
//		                                                                 ЛицевойСчет.Contract,
//		                                                                 ЛицевойСчет.Client,
//		                                                                 DiscountCard,
//		                                                                 ?(vDiscountType.IsPerVisit, ЛицевойСчет.GuestGroup, Неопределено));
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
//Процедура pmCalculateAccumulationDiscount() Экспорт
//	vAccDiscounts = ParentDoc.GetObject().pmGetAccumulatingDiscountResources();
//	If vAccDiscounts.Count() > 0 Тогда
//		vAccDiscountsRow = vAccDiscounts.Get(0);
//		vDiscountType = vAccDiscountsRow.ТипСкидки;
//		If НЕ ЗначениеЗаполнено(vDiscountType) Тогда
//			Return;
//		EndIf;
//		vAccountingDate = BegOfDay(Date);
//		If BegOfDay(vAccountingDate) < vDiscountType.DateValidFrom Or
//		   (vAccountingDate > vDiscountType.DateValidTo And ЗначениеЗаполнено(vDiscountType.DateValidTo)) Тогда
//			Return;
//		EndIf;
//		vDiscountDimension = vAccDiscountsRow.ИзмерениеСкидки;
//		If cmIsServiceInServiceGroup(Service, DiscountServiceGroup) And 
//		  (НЕ vDiscountType.IsForRackRatesOnly Or vDiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(Тариф) And Тариф.IsRackRate) Тогда
//			vDiscountTypeObj = vDiscountType.GetObject();
//			vResource = vAccDiscountsRow.Ресурс;
//			vDiscountConfirmationText = "";
//			vDiscount = vDiscountTypeObj.pmGetAccumulatingDiscount(Service, vAccountingDate, 
//																   vResource, 
//																   vDiscountConfirmationText);
//			If vDiscount <> 0 Тогда
//				DiscountType = vDiscountType;
//				Discount = vDiscount;
//				DiscountConfirmationText = vDiscountConfirmationText;
//			EndIf;
//		EndIf;
//	EndIf;						
//КонецПроцедуры //pmCalculateAccumulationDiscount
//
////-----------------------------------------------------------------------------
//Процедура pmSetDiscounts() Экспорт
//	// Check if manual discount is choosen
//	If ЗначениеЗаполнено(DiscountType) And DiscountType.IsManualDiscount Тогда
//		Return;
//	ElsIf НЕ ЗначениеЗаполнено(DiscountType) And Discount <> 0 Тогда
//		Return;
//	EndIf;
//	// Get number of persons
//	vNumberOfPersons = 1;
//	If ЗначениеЗаполнено(ParentDoc) And 
//	   (TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or 
//		TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Or 
//		TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг")) Тогда
//		vNumberOfPersons = ParentDoc.КоличествоЧеловек;
//	EndIf;
//	// Initialize discounts
//	DiscountType = Справочники.DiscountTypes.EmptyRef();
//	DiscountConfirmationText = "";
//	DiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//	Discount = 0;
//	If ЗначениеЗаполнено(DiscountCard) Тогда
//		If ЗначениеЗаполнено(DiscountCard.DiscountType) Тогда
//			vDiscountType = DiscountCard.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(Date, Service, Гостиница);
//			If vDiscount > Discount Or (vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned) Тогда 
//				DiscountType = vDiscountType;
//				DiscountConfirmationText = DiscountCard.Metadata().Synonym + " " + TrimAll(DiscountCard.Description);
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				Discount = vDiscount;
//				If ЗначениеЗаполнено(DiscountCard.ClientType) Тогда
//					ClientType = DiscountCard.ClientType;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ClientType) Тогда
//		If ЗначениеЗаполнено(ClientType.DiscountType) Тогда
//			vDiscountType = ClientType.DiscountType;
//			vDiscount = ClientType.DiscountType.GetObject().pmGetDiscount(Date, Service, Гостиница);
//			If vDiscount > Discount Or (vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned) Тогда 
//				DiscountType = ClientType.DiscountType;
//				If IsBlankString(ClientTypeConfirmationText) Тогда
//					DiscountConfirmationText = NStr("en='Client type discount';ru='По типу клиента';de='Nach Kundentyp'");
//				Else
//					DiscountConfirmationText = ClientTypeConfirmationText;
//				EndIf;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				vDiscountTypeObj = DiscountType.GetObject();
//				Discount = vDiscount;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) <> Type("DocumentRef.СоставКвоты") Тогда
//		If ЗначениеЗаполнено(ParentDoc.ТипСкидки) Тогда
//			vDiscountType = ParentDoc.ТипСкидки;
//			If vDiscountType.IsAccumulatingDiscount Тогда
//				DiscountType = vDiscountType;
//				DiscountConfirmationText = TrimAll(ParentDoc.ОснованиеСкидки);
//				DiscountServiceGroup = ParentDoc.DiscountServiceGroup;
//				pmCalculateAccumulationDiscount();
//			Else
//				vDiscount = vDiscountType.GetObject().pmGetDiscount(Date, Service, Гостиница);
//				If vDiscount > Discount Or (vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned) Тогда 
//					DiscountType = vDiscountType;
//					DiscountConfirmationText = TrimAll(ParentDoc.ОснованиеСкидки);
//					DiscountServiceGroup = ParentDoc.DiscountServiceGroup;
//					Discount = vDiscount;
//				EndIf;
//			EndIf;
//		EndIf;
//	ElsIf ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.Client) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.Client.DiscountType) Тогда
//			vDiscountType = ЛицевойСчет.Client.DiscountType;
//			If vDiscountType.IsAccumulatingDiscount Тогда
//				DiscountType = vDiscountType;
//				DiscountConfirmationText = "";
//				DiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//				pmCalculateAccumulationDiscount();
//			Else
//				vDiscount = vDiscountType.GetObject().pmGetDiscount(Date, Service, Гостиница);
//				If vDiscount > Discount Or (vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned) Тогда 
//					DiscountType = vDiscountType;
//					DiscountConfirmationText = "";
//					DiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//					Discount = vDiscount;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Accummulating discounts
//	If ЗначениеЗаполнено(Service) Тогда
//		vSkipAccumulatingDiscounts = False;
//		If ЗначениеЗаполнено(DiscountType) And DiscountType.TurnOffAutomaticDiscounts Or 
//		   ЗначениеЗаполнено(DiscountCard) And DiscountCard.TurnOffAutomaticDiscounts Or 
//		   ЗначениеЗаполнено(ClientType) And ClientType.TurnOffAutomaticDiscounts Or 
//		   ЗначениеЗаполнено(MarketingCode) And MarketingCode.TurnOffAutomaticDiscounts Тогда
//			vSkipAccumulatingDiscounts = True;
//		EndIf;
//		If НЕ vSkipAccumulatingDiscounts Тогда
//			vCurDiscount = 0;
//			vCurDiscountType = Справочники.DiscountTypes.EmptyRef();
//			vCurDiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//			vCurDiscountConfirmationText = "";
//			// Check accumulating discounts
//			vCheckAccDiscounts = True;
//			If ЗначениеЗаполнено(ParentDoc) And 
//			   (TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Or 
//			    TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or
//			    TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг")) And 
//			   ParentDoc.TurnOffAutomaticDiscounts Тогда
//				vCheckAccDiscounts = False;
//			EndIf;
//			If ЗначениеЗаполнено(ClientType) Тогда
//				If ClientType.TurnOffAutomaticDiscounts Тогда
//					vCheckAccDiscounts = False;
//				EndIf;
//			EndIf;
//			If ЗначениеЗаполнено(DiscountType) Тогда
//				If DiscountType.TurnOffAutomaticDiscounts Тогда
//					vCheckAccDiscounts = False;
//				EndIf;
//			EndIf;
//			If vCheckAccDiscounts Тогда
//				// Read all configured accumulating discount types
//				vAccDiscounts = pmGetAccumulatingDiscountResources();
//				// Check all accumulation discounts
//				For Each vAccDiscount In vAccDiscounts Do
//					vDiscountType = vAccDiscount.ТипСкидки;
//					vDiscountDimension = vAccDiscount.ИзмерениеСкидки;
//					vDiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//					If cmIsServiceInServiceGroup(Service, vDiscountServiceGroup) And 
//					  (НЕ vDiscountType.IsForRackRatesOnly Or vDiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(Тариф) And Тариф.IsRackRate) Тогда
//						vDiscountTypeObj = vDiscountType.GetObject();
//						
//						// Check that this discount type fits to the service folio
//						vSrvDiscountDimension = Неопределено;
//						vSrvResource = vDiscountTypeObj.pmCalculateResource(ThisObject, vNumberOfPersons, ЛицевойСчет, DiscountCard, vSrvDiscountDimension);
//						If TypeOf(vSrvDiscountDimension) = TypeOf(vDiscountDimension) Тогда
//							// Retrieve discount percent valid for current discount resource										
//							vResource = vAccDiscount.Ресурс;
//							vDiscountConfirmationText = "";
//							vDiscount = vDiscountTypeObj.pmGetAccumulatingDiscount(Service, Date, 
//																				   vResource, 
//																				   vDiscountConfirmationText);
//							If vDiscount <> 0 Тогда
//								If cmFirstDiscountIsGreater(vDiscount, vCurDiscount) Тогда
//									vCurDiscount = vDiscount;
//									vCurDiscountType = vDiscountType;
//									vCurDiscountServiceGroup = vDiscountServiceGroup;
//									vCurDiscountConfirmationText = vDiscountConfirmationText;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndDo;
//				// Apply accumulating discount
//				If vCurDiscount <> 0 Тогда 
//					If cmIsServiceInServiceGroup(Service, vCurDiscountServiceGroup) Тогда
//						If vCurDiscount > Discount Тогда
//							Discount = vCurDiscount;
//							DiscountType = vCurDiscountType;
//							DiscountServiceGroup = vCurDiscountServiceGroup;
//							DiscountConfirmationText = vCurDiscountConfirmationText;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmSetDiscounts
//
////-----------------------------------------------------------------------------
//Процедура pmRecalculateAmounts() Экспорт
//	If ЗначениеЗаполнено(Service) Тогда
//		If Service.RecalculatePriceWhenSumChanged And НЕ IsSplit Тогда
//			If Quantity = 0 And Sum > 0 Тогда
//				Quantity = 1;
//			EndIf;
//			Price = ?(Quantity = 0, 0, Round(Sum / Quantity, 2));
//		Else
//			Quantity = ?(Price = 0, 1, Round(Sum / Price, 7));
//		EndIf;
//	Else
//		Quantity = ?(Price = 0, 1, Round(Sum / Price, 7));
//	EndIf;
//	VATSum = cmCalculateVATSum(VATRate, Sum);
//	// ГруппаНомеров sales resources
//	RoomsRented = 0;
//	BedsRented = 0;
//	AdditionalBedsRented = 0;
//	GuestDays = 0;
//	GuestsCheckedIn = 0;
//	If IsRoomRevenue And НЕ IsSplit And ЗначениеЗаполнено(Service) Тогда
//		If ЗначениеЗаполнено(ParentDoc) And 
//		  (TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Or TypeOf(ParentDoc) = Type("DocumentRef.Размещение")) Тогда
//			vCurPeriodInHours = 24;
//			If ЗначениеЗаполнено(Service.QuantityCalculationRule) Тогда
//				If Service.QuantityCalculationRule.PeriodInHours <> 0 Тогда
//					vCurPeriodInHours = Service.QuantityCalculationRule.PeriodInHours;
//				EndIf;
//			ElsIf ЗначениеЗаполнено(Тариф) And Тариф.PeriodInHours <> 0 Тогда
//				vCurPeriodInHours = Тариф.PeriodInHours;
//			EndIf;
//			If vCurPeriodInHours <> 0 Тогда
//				RoomsRented = ?(ParentDoc.КоличествоМестНомер = 0, 0, Round(ParentDoc.КоличествоМест/ParentDoc.КоличествоМестНомер*Quantity*vCurPeriodInHours/24, 7));
//				BedsRented = Round(ParentDoc.КоличествоМест*Quantity*vCurPeriodInHours/24, 7);
//				AdditionalBedsRented = Round(ParentDoc.КолДопМест*Quantity*vCurPeriodInHours/24, 7);
//				GuestDays = Round(ParentDoc.КоличествоЧеловек*Quantity*vCurPeriodInHours/24, 7);
//				If BegOfDay(ParentDoc.CheckInDate) = BegOfDay(Date) Тогда
//					GuestsCheckedIn = ParentDoc.КоличествоЧеловек;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Discount
//	DiscountSum = 0;
//	VATDiscountSum = 0;
//	If ЗначениеЗаполнено(Service) Тогда
//		If cmIsServiceInServiceGroup(Service, DiscountServiceGroup) Тогда
//			If НЕ ЗначениеЗаполнено(DiscountType) Or ЗначениеЗаполнено(DiscountType) And (НЕ DiscountType.IsForRackRatesOnly Or DiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(Тариф) And Тариф.IsRackRate) Тогда
//				DiscountSum = Round(Sum * Discount / 100, 2);
//				VATDiscountSum = cmCalculateVATSum(VATRate, DiscountSum);
//			EndIf;
//		EndIf;
//	EndIf;
//	// Commission
//	СуммаКомиссии = 0;
//	СуммаКомиссииНДС = 0;
//	If ЗначениеЗаполнено(Service) Тогда
//		If cmIsServiceInServiceGroup(Service, КомиссияАгентУслуги) Тогда
//			If ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//				СуммаКомиссии = Round((Sum - DiscountSum) * КомиссияАгента/100, 2);
//				СуммаКомиссииНДС = cmCalculateVATSum(VATRate, СуммаКомиссии);
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmRecalculateAmounts
//
////-----------------------------------------------------------------------------
//Процедура pmPostResourceReservation(pDateFrom, pDateTill) Экспорт
//	If НЕ IsAdditional Or IsManual Тогда
//		Return;
//	EndIf;
//	// Create/update resource reservation document
//	vDocObj = Неопределено;
//	If ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//		vDocObj = ParentDoc.GetObject();
//	Else
//		vDocObj = Documents.БроньУслуг.CreateDocument();
//		vDocObj.pmFillAuthorAndDate();
//	EndIf;
//	vDocObj.ChargingFolio = ЛицевойСчет;
//	vDocObj.ВалютаЛицСчета = FolioCurrency;
//	vDocObj.FolioCurrencyExchangeRate = FolioCurrencyExchangeRate;
//	vDocObj.Валюта = ReportingCurrency;
//	vDocObj.ReportingCurrencyExchangeRate = ReportingCurrencyExchangeRate;
//	vDocObj.Гостиница = Гостиница;
//	If ЗначениеЗаполнено(Resource) Тогда
//		vDocObj.ТипРесурса = Resource.Owner;
//		vDocObj.Ресурс = Resource;
//	Else
//		vDocObj.ТипРесурса = Справочники.ТипыРесурсов.EmptyRef();
//		vDocObj.Ресурс = Справочники.Ресурсы.EmptyRef();
//	EndIf;
//	vDocObj.Фирма = ЛицевойСчет.Фирма;
//	If НЕ ЗначениеЗаполнено(vDocObj.Фирма) Тогда
//		vDocObj.Фирма = Фирма;
//	EndIf;
//	vDocObj.ExchangeRateDate = CurrentDate();
//	vDocObj.ГруппаГостей = ЛицевойСчет.GuestGroup;
//	If NOT ЗначениеЗаполнено(vDocObj.ГруппаГостей) Тогда
//		vDocObj.pmCreateGuestGroup();
//	EndIf;
//	vDocObj.ТипКлиента = ClientType;
//	vDocObj.СтрокаПодтверждения = ClientTypeConfirmationText;
//	vDocObj.PlannedPaymentMethod = ЛицевойСчет.PaymentMethod;
//	vDocObj.ResourceReservationStatus = Гостиница.NewResourceReservationStatus;
//	If ЗначениеЗаполнено(vDocObj.ResourceReservationStatus) Тогда
//		vDocObj.DoCharging = vDocObj.ResourceReservationStatus.DoCharging;
//	EndIf;
//	vDocObj.DateTimeFrom = pDateFrom;
//	vDocObj.DateTimeTo = pDateTill;
//	vDocObj.Продолжительность = vDocObj.pmCalculateDuration();
//	If ЗначениеЗаполнено(ЛицевойСчет.Contract) Тогда
//		vDocObj.Owner = ЛицевойСчет.Contract;
//	ElsIf ЗначениеЗаполнено(ЛицевойСчет.Контрагент) Тогда
//		vDocObj.Owner = ЛицевойСчет.Контрагент;
//	ElsIf ЗначениеЗаполнено(vDocObj.Гостиница) Тогда
//		If ЗначениеЗаполнено(vDocObj.Гостиница.IndividualsContract) Тогда
//			vDocObj.Owner = vDocObj.Гостиница.IndividualsContract;
//		Else
//			vDocObj.Owner = vDocObj.Гостиница.IndividualsCustomer;
//		EndIf;
//	Else
//		vDocObj.Owner = Неопределено;
//	EndIf;
//	If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//		vDocObj.Контрагент = ЛицевойСчет.ParentDoc.Контрагент;
//		If ЗначениеЗаполнено(vDocObj.Контрагент) Тогда
//			vDocObj.ТипКонтрагента = vDocObj.Контрагент.ТипКонтрагента;
//		EndIf;
//		vDocObj.Договор = ЛицевойСчет.ParentDoc.Договор;
//	Else
//		If ЗначениеЗаполнено(vDocObj.Owner) Тогда
//			If ЗначениеЗаполнено(vDocObj.Гостиница) And (vDocObj.Owner = vDocObj.Гостиница.IndividualsCustomer Or vDocObj.Owner = vDocObj.Гостиница.IndividualsContract) Тогда
//				vDocObj.Контрагент = Справочники.Контрагенты.EmptyRef();
//				vDocObj.Договор = Справочники.Договора.EmptyRef();
//			Else
//				If TypeOf(vDocObj.Owner) = Type("CatalogRef.Договора") Тогда
//					vDocObj.Контрагент = vDocObj.Owner.Owner;
//					vDocObj.Договор = vDocObj.Owner;
//				ElsIf TypeOf(vDocObj.Owner) = Type("CatalogRef.Контрагенты") Тогда
//					vDocObj.Контрагент = vDocObj.Owner;
//					vDocObj.Договор = Справочники.Договора.EmptyRef();
//				EndIf;
//			EndIf;
//		Else
//			vDocObj.Контрагент = Справочники.Контрагенты.EmptyRef();
//			vDocObj.Договор = Справочники.Договора.EmptyRef();
//		EndIf;
//	EndIf;
//	vDocObj.Агент = ЛицевойСчет.Agent;
//	If ЗначениеЗаполнено(vDocObj.Агент) Тогда
//		vDocObj.КомиссияАгента = КомиссияАгента;
//		vDocObj.ВидКомиссииАгента = ВидКомиссииАгента;
//		vDocObj.КомиссияАгентУслуги = КомиссияАгентУслуги;
//	Else
//		vDocObj.КомиссияАгента = 0;
//		vDocObj.ВидКомиссииАгента = Неопределено;
//		vDocObj.КомиссияАгентУслуги = Справочники.НаборыУслуг.EmptyRef();
//	EndIf;
//	vDocObj.Клиент = ЛицевойСчет.Client;
//	If ЗначениеЗаполнено(ЛицевойСчет.Client) Тогда
//		vDocObj.Телефон = ЛицевойСчет.Client.Телефон;
//		vDocObj.Fax = ЛицевойСчет.Client.Fax;
//		vDocObj.EMail = ЛицевойСчет.Client.EMail;
//	EndIf;
//	vDocObj.МаркетингКод = MarketingCode;
//	vDocObj.MarketingCodeConfirmationText = MarketingCodeConfirmationText;
//	vDocObj.ИсточникИнфоГостиница = SourceOfBusiness;
//	If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//		vDocObj.КоличествоЧеловек = ЛицевойСчет.ParentDoc.КоличествоЧеловек;
//		vDocObj.КонтактноеЛицо = TrimR(ЛицевойСчет.ParentDoc.КонтактноеЛицо);
//		vDocObj.CreditCard = ЛицевойСчет.ParentDoc.CreditCard;
//		vDocObj.Телефон = ЛицевойСчет.ParentDoc.Телефон;
//		vDocObj.Fax = ЛицевойСчет.ParentDoc.Fax;
//		vDocObj.EMail = ЛицевойСчет.ParentDoc.EMail;
//	EndIf;
//	If ЗначениеЗаполнено(vDocObj.Клиент) Тогда
//		// Check if client has master charging rules
//		vClientMasterFolio = Неопределено;
//		For Each vCRRow In vDocObj.Клиент.ChargingRules Do
//			If ЗначениеЗаполнено(vCRRow.ChargingFolio) And vCRRow.ChargingFolio.IsMaster Тогда
//				If vCRRow.ChargingFolio.Клиент = vDocObj.Клиент Тогда
//					vClientMasterFolio = vCRRow.ChargingFolio;
//					Break;
//				EndIf;
//			EndIf;
//		EndDo;
//		If ЗначениеЗаполнено(vClientMasterFolio) And vClientMasterFolio <> vDocObj.ChargingFolio Тогда
//			vDocObj.ChargingFolio = vClientMasterFolio;
//			vDocObj.ВалютаЛицСчета = vDocObj.ChargingFolio.ВалютаЛицСчета;
//			vDocObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vDocObj.Гостиница, vDocObj.Валюта, vDocObj.ExchangeRateDate);
//		EndIf;
//	EndIf;
//	vDocObj.Примечания = TrimAll(Remarks);
//	vDocObj.DoNotCalculateServices = True;
//	vDocObj.DeletionMark = False;
//	vDocObj.pmCalculateServices();
//	vDocObj.Write(РежимЗаписиДокумента.Проведение);
//	vDocObj.pmWriteToResourceReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//	If ParentDoc <> vDocObj.Ref Тогда
//		Read();
//		ParentDoc = vDocObj.Ref;
//		Write(режимзаписидокумента.Запись);
//	EndIf;
//КонецПроцедуры //pmPostResourceReservation
