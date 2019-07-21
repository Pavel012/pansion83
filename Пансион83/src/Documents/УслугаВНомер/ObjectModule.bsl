////-----------------------------------------------------------------------------
//Function pmGetRoomServiceCharges() Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Начисление.Ref AS Начисление
//	|FROM
//	|	Document.Начисление AS Начисление
//	|WHERE
//	|	 Начисление.Posted = TRUE";
//	vQry.SetParameter("qParentRoomService", Ref);
//	Return vQry.Execute().Unload();
//EndFunction //pmGetRoomServiceCharges
//
////-----------------------------------------------------------------------------
//Function pmGetFoliosToChargeTo() Экспорт
//	vFolios = cmGetFoliosToChargeRoomService(ГруппаНомеров, ServiceDate, Client);
//	Return vFolios;
//EndFunction //pmGetFoliosToChargeTo
//
////-----------------------------------------------------------------------------
//Function pmGetFolioToChargeTo() Экспорт
//	vFolioTo = Documents.СчетПроживания.EmptyRef();
//	// Create table with accommodation folios
//	vAccFolios = New ValueTable();
//	vAccFolios.Columns.Add("Размещение", cmGetDocumentTypeDescription("Размещение"));
//	vAccFolios.Columns.Add("ЭтоГости", cmGetNumberTypeDescription(1, 0));
//	vAccFolios.Columns.Add("AccommodationDate", cmGetDateTimeTypeDescription());
//	vAccFolios.Columns.Add("IsPayingForTheRoom", cmGetNumberTypeDescription(1, 0));
//	vAccFolios.Columns.Add("СчетПроживания", cmGetDocumentTypeDescription("СчетПроживания"));
//	vAccFolios.Columns.Add("FolioDate", cmGetDateTimeTypeDescription());
//	vAccFolios.Columns.Add("FolioPriority", cmGetNumberTypeDescription(9, 0));
//	vAccFolios.Columns.Add("ThereIsDeposit", cmGetNumberTypeDescription(1, 0));
//	// Get service we will check
//	vService = RoomService;
//	If НЕ ЗначениеЗаполнено(vService) Тогда
//		vService = FixedService;
//	EndIf;
//	// Get list of all active suitable folios
//	vFolios = pmGetFoliosToChargeTo();
//	If ЗначениеЗаполнено(vService) Тогда
//		// Check client and charging rules for the service
//		For Each vFolioRow In vFolios Do
//			vFolio = vFolioRow.СчетПроживания;
//			vParentDoc = vFolio.ДокОснование;
//			If ЗначениеЗаполнено(vParentDoc) Тогда
//				If TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Тогда
//					vCRs = vParentDoc.ChargingRules.Unload();
//					cmAddGuestGroupChargingRules(vCRs, vParentDoc.ГруппаГостей);
//					vCRRow = vCRs.Find(vFolio, "ChargingFolio");
//					If vCRRow <> Неопределено Тогда
//						If cmIsServiceFitToTheChargingRule(vCRRow, vService, BegOfDay(Date), False, False) Тогда
//							vAccFoliosRowsArray = vAccFolios.FindRows(New Structure("Размещение, СчетПроживания", vParentDoc, vFolio));
//							If vAccFoliosRowsArray.Count() = 0 Тогда
//								vAccFoliosRow = vAccFolios.Add();
//								vAccFoliosRow.Размещение = vParentDoc;
//								vAccFoliosRow.AccommodationDate = vParentDoc.ДатаДок;
//								If ЗначениеЗаполнено(vParentDoc.СтатусРазмещения) Тогда
//									vAccFoliosRow.ЭтоГости = ?(vParentDoc.СтатусРазмещения.ЭтоГости, 1, 0);
//								EndIf;
//								vAccFoliosRow.IsPayingForTheRoom = 0;
//								If ЗначениеЗаполнено(vAccFoliosRow.Размещение.ВидРазмещения) Тогда
//									If vAccFoliosRow.Размещение.ВидРазмещения.ТипРазмещения = Перечисления.ВидыРазмещений.НомерРазмещения Тогда
//										vAccFoliosRow.IsPayingForTheRoom = 1;
//									EndIf;
//								EndIf;
//								vAccFoliosRow.СчетПроживания = vFolio;
//								vAccFoliosRow.FolioDate = vFolio.ДатаДок;
//								vAccFoliosRow.FolioPriority = vCRRow.LineNumber;
//								vAccFoliosRow.ThereIsDeposit = 0;
//								vFolioBalance = vFolio.GetObject().pmGetBalance('39991231235959');
//								If vFolioBalance < 0 Тогда
//									vAccFoliosRow.ThereIsDeposit = 1;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	// We will use folio of the client paing for the ГруппаНомеров and with deposit first. If not then we will use the oldest accommodations folio with lowest folio priority
//	If vAccFolios.Count() > 0 Тогда
//		vAccFolios.Sort("ЭтоГости Desc, IsPayingForTheRoom Desc, ThereIsDeposit Desc, AccommodationDate, Размещение, FolioPriority, FolioDate, СчетПроживания");
//		vFolioTo = vAccFolios.Get(0).СчетПроживания;
//	EndIf;
//	// If there was no suitable folio found then take the earliest one without Контрагент
//	If НЕ ЗначениеЗаполнено(vFolioTo) Тогда
//		// Return first active client folio
//		For Each vFoliosRow In vFolios Do
//			vWrkFolio = vFoliosRow.СчетПроживания;
//			If НЕ ЗначениеЗаполнено(vWrkFolio.Контрагент) Or 
//			   ЗначениеЗаполнено(vWrkFolio.Гостиница) And ЗначениеЗаполнено(vWrkFolio.Контрагент) And 
//			   (vWrkFolio.Контрагент = vWrkFolio.Гостиница.IndividualsCustomer Or vWrkFolio.Контрагент.BelongsToItem(Справочники.Customers.КонтрагентПоУмолчанию)) Тогда
//				vFolioTo = vWrkFolio;
//				Break;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Return
//	Return vFolioTo;
//EndFunction //pmGetFolioToChargeTo
//
////-----------------------------------------------------------------------------
//// Recalculate all sums based on ГруппаНомеров service charge Sum in document currency
////-----------------------------------------------------------------------------
//Процедура pmRecalculateSums() Экспорт
//	// ГруппаНомеров service charge sum
//	If RoomServicePriceIsWithVAT Тогда
//		Sum = Round(Price * Quantity, 2);
//	Else
//		// Get price with VAT
//		vPrice = Price;
//		If ЗначениеЗаполнено(VATRate) Тогда
//			vPrice = Round(Price * (100 + VATRate.Ставка)/100, 2);
//		EndIf;
//		Sum = Round(vPrice * Quantity, 2);
//	EndIf;
//	// All other bound sums
//	SumInFolioCurrency = 0;
//	VATSumInFolioCurrency = 0;
//	DiscountSumInFolioCurrency = 0;
//	VATDiscountSumInFolioCurrency = 0;
//	CommissionSumInFolioCurrency = 0;
//	VATCommissionSumInFolioCurrency = 0;
//	If ЗначениеЗаполнено(RoomService) Тогда
//		// In document currency
//		VATSum = cmCalculateVATSum(VATRate, Sum);
//		// In folio currency
//		If ЗначениеЗаполнено(FolioCurrency) Тогда
//			SumInFolioCurrency = Round(cmConvertCurrencies(Sum, Currency, CurrencyExchangeRate, FolioCurrency, FolioCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//			VATSumInFolioCurrency = cmCalculateVATSum(VATRate, SumInFolioCurrency);
//			// Discount
//			If cmIsServiceInServiceGroup(RoomService, DiscountServiceGroup) Тогда
//				DiscountSumInFolioCurrency = Round(SumInFolioCurrency * Discount / 100, 2);
//				VATDiscountSumInFolioCurrency = cmCalculateVATSum(VATRate, DiscountSumInFolioCurrency);
//			EndIf;
//			// Commission
//			If cmIsServiceInServiceGroup(RoomService, AgentCommissionServiceGroup) Тогда
//				If AgentCommissionType = Перечисления.AgentCommissionTypes.Percent Тогда
//					CommissionSumInFolioCurrency = Round((SumInFolioCurrency - DiscountSumInFolioCurrency) * AgentCommission/100, 2);
//					VATCommissionSumInFolioCurrency = cmCalculateVATSum(VATRate, CommissionSumInFolioCurrency);
//				ElsIf AgentCommissionType = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//					If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//						If (TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.Reservation") Or TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.Размещение")) And 
//						   BegOfDay(ЛицевойСчет.ParentDoc.CheckInDate) = BegOfDay(Date) Тогда
//							CommissionSumInFolioCurrency = Round((SumInFolioCurrency - DiscountSumInFolioCurrency) * AgentCommission/100, 2);
//							VATCommissionSumInFolioCurrency = cmCalculateVATSum(VATRate, CommissionSumInFolioCurrency);
//						ElsIf TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.БроньУслуг") And BegOfDay(ЛицевойСчет.ParentDoc.DateTimeFrom) = BegOfDay(Date) Тогда
//							CommissionSumInFolioCurrency = Round((SumInFolioCurrency - DiscountSumInFolioCurrency) * AgentCommission/100, 2);
//							VATCommissionSumInFolioCurrency = cmCalculateVATSum(VATRate, CommissionSumInFolioCurrency);
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	Else
//		Sum = 0;
//		VATSum = 0;
//	EndIf;
//	// Fixed service sum
//	FixedServiceSumInFolioCurrency = 0;
//	FixedServiceVATSumInFolioCurrency = 0;
//	FixedServiceDiscountSumInFolioCurrency = 0;
//	FixedServiceVATDiscountSumInFolioCurrency = 0;
//	FixedServiceCommissionSumInFolioCurrency = 0;
//	FixedServiceVATCommissionSumInFolioCurrency = 0;
//	If ЗначениеЗаполнено(FixedService) Тогда
//		// In document currency
//		FixedServiceVATSum = cmCalculateVATSum(FixedServiceVATRate, FixedServiceSum);
//		// In folio currency
//		If ЗначениеЗаполнено(FolioCurrency) Тогда
//			FixedServiceSumInFolioCurrency = Round(cmConvertCurrencies(FixedServiceSum, Currency, CurrencyExchangeRate, FolioCurrency, FolioCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//			FixedServiceVATSumInFolioCurrency = cmCalculateVATSum(FixedServiceVATRate, FixedServiceSumInFolioCurrency);
//			// Discount
//			If cmIsServiceInServiceGroup(FixedService, DiscountServiceGroup) Тогда
//				FixedServiceDiscountSumInFolioCurrency = Round(FixedServiceSumInFolioCurrency * Discount / 100, 2);
//				FixedServiceVATDiscountSumInFolioCurrency = cmCalculateVATSum(FixedServiceVATRate, FixedServiceDiscountSumInFolioCurrency);
//			EndIf;
//			// Commission
//			If cmIsServiceInServiceGroup(FixedService, AgentCommissionServiceGroup) Тогда
//				If AgentCommissionType = Перечисления.AgentCommissionTypes.Percent Тогда
//					FixedServiceCommissionSumInFolioCurrency = Round((FixedServiceSumInFolioCurrency - FixedServiceDiscountSumInFolioCurrency) * AgentCommission/100, 2);
//					FixedServiceVATCommissionSumInFolioCurrency = cmCalculateVATSum(FixedServiceVATRate, FixedServiceCommissionSumInFolioCurrency);
//				ElsIf AgentCommissionType = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//					If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//						If (TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.Reservation") Or TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.Размещение")) And 
//						   BegOfDay(ЛицевойСчет.ParentDoc.CheckInDate) = BegOfDay(Date) Тогда
//							FixedServiceCommissionSumInFolioCurrency = Round((FixedServiceSumInFolioCurrency - FixedServiceDiscountSumInFolioCurrency) * AgentCommission/100, 2);
//							FixedServiceVATCommissionSumInFolioCurrency = cmCalculateVATSum(FixedServiceVATRate, FixedServiceCommissionSumInFolioCurrency);
//						ElsIf TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.БроньУслуг") And BegOfDay(ЛицевойСчет.ParentDoc.DateTimeFrom) = BegOfDay(Date) Тогда
//							FixedServiceCommissionSumInFolioCurrency = Round((FixedServiceSumInFolioCurrency - FixedServiceDiscountSumInFolioCurrency) * AgentCommission/100, 2);
//							FixedServiceVATCommissionSumInFolioCurrency = cmCalculateVATSum(FixedServiceVATRate, FixedServiceCommissionSumInFolioCurrency);
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	Else
//		FixedServiceSum = 0;
//		FixedServiceVATSum = 0;
//	EndIf;
//КонецПроцедуры //pmRecalculateSums
//
////-----------------------------------------------------------------------------
//Процедура pmFillByFolio() Экспорт
//	If НЕ ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		Return;
//	EndIf;
//	// ЛицевойСчет currency
//	FolioCurrency = ЛицевойСчет.FolioCurrency;
//	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница) Тогда
//		If Гостиница <> ЛицевойСчет.Гостиница Тогда
//			Гостиница = ЛицевойСчет.Гостиница;
//			SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ЛицевойСчет.Фирма) Тогда
//		Фирма = ЛицевойСчет.Фирма;
//		VATRate = Фирма.VATRate;
//		FixedServiceVATRate = Фирма.VATRate;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If ЗначениеЗаполнено(FolioCurrency) Тогда
//			FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ExchangeRateDate);
//		Else
//			FolioCurrencyExchangeRate = 0;
//		EndIf;
//	Else
//		FolioCurrencyExchangeRate = 0;
//	EndIf;
//	// Parent document
//	If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) Тогда
//		// Client type
//		ClientType = ЛицевойСчет.ParentDoc.ТипКлиента;
//		ClientTypeConfirmationText = ЛицевойСчет.ParentDoc.СтрокаПодтверждения;
//		// Discount
//		If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc.ТипСкидки) And НЕ ЛицевойСчет.ParentDoc.ТипСкидки.DoNotApplyToExternalInterfaces Тогда
//			DiscountCard = ЛицевойСчет.ParentDoc.ДисконтКарт;
//			DiscountType = ЛицевойСчет.ParentDoc.ТипСкидки;
//			DiscountConfirmationText = ЛицевойСчет.ParentDoc.ОснованиеСкидки;
//			Discount = ЛицевойСчет.ParentDoc.Скидка;
//			DiscountServiceGroup = ЛицевойСчет.ParentDoc.DiscountServiceGroup;
//		EndIf;
//	EndIf;
//	// Commission
//	If ЗначениеЗаполнено(ЛицевойСчет.Agent) Тогда
//		AgentCommission = ЛицевойСчет.Agent.AgentCommission;
//		AgentCommissionType = ЛицевойСчет.Agent.AgentCommissionType;
//		AgentCommissionServiceGroup = ЛицевойСчет.Agent.AgentCommissionServiceGroup;
//	EndIf;
//КонецПроцедуры //pmFillByFolio
//
////-----------------------------------------------------------------------------
//Процедура FillChargeDocumentAttributesForRoomService(pChargeObj)
//	If pChargeObj.ДокОснование <> ЛицевойСчет.ParentDoc Тогда
//		pChargeObj.ДокОснование = ЛицевойСчет.ParentDoc;
//	EndIf;
//	If pChargeObj.ParentRoomService <> Ref Тогда
//		pChargeObj.ParentRoomService = Ref;
//	EndIf;
//	If pChargeObj.IsFixedCharge Тогда
//		pChargeObj.IsFixedCharge = False;
//	EndIf;
//	If pChargeObj.Гостиница <> Гостиница Тогда
//		pChargeObj.Гостиница = Гостиница;
//	EndIf;
//	If pChargeObj.ExchangeRateDate <> ExchangeRateDate Тогда
//		pChargeObj.ExchangeRateDate = ExchangeRateDate;
//	EndIf;
//	If pChargeObj.СчетПроживания <> ЛицевойСчет Тогда
//		pChargeObj.СчетПроживания = ЛицевойСчет;
//	EndIf;
//	If pChargeObj.ТипКлиента <> ClientType Тогда
//		pChargeObj.ТипКлиента = ClientType;
//	EndIf;
//	If TrimAll(pChargeObj.СтрокаПодтверждения) <> TrimAll(ClientTypeConfirmationText) Тогда
//		pChargeObj.СтрокаПодтверждения = ClientTypeConfirmationText;
//	EndIf;
//	If pChargeObj.Услуга <> RoomService Тогда
//		pChargeObj.Услуга = RoomService;
//		If ЗначениеЗаполнено(pChargeObj.Услуга) And pChargeObj.PaymentSection <> pChargeObj.Услуга.PaymentSection Тогда
//			pChargeObj.PaymentSection = pChargeObj.Услуга.PaymentSection;
//		EndIf;
//	EndIf;
//	If pChargeObj.Цена <> cmRecalculatePrice(SumInFolioCurrency, Quantity) Тогда
//		pChargeObj.Цена = cmRecalculatePrice(SumInFolioCurrency, Quantity);
//	EndIf;
//	If TrimAll(pChargeObj.ЕдИзмерения) <> TrimAll(Unit) Тогда
//		pChargeObj.ЕдИзмерения = Unit;
//	EndIf;
//	If pChargeObj.Количество <> Quantity Тогда
//		pChargeObj.Количество = Quantity;
//	EndIf;
//	If pChargeObj.Сумма <> SumInFolioCurrency Тогда
//		pChargeObj.Сумма = SumInFolioCurrency;
//	EndIf;
//	If pChargeObj.СтавкаНДС <> VATRate Тогда
//		pChargeObj.СтавкаНДС = VATRate;
//	EndIf;
//	If pChargeObj.СуммаНДС <> VATSumInFolioCurrency Тогда
//		pChargeObj.СуммаНДС = VATSumInFolioCurrency;
//	EndIf;
//	If TrimAll(pChargeObj.Примечания) <> TrimAll(Remarks) Тогда
//		pChargeObj.Примечания = Remarks;
//	EndIf;
//	If pChargeObj.IsRoomRevenue Тогда
//		pChargeObj.IsRoomRevenue = False;
//	EndIf;
//	If pChargeObj.IsInPrice Тогда
//		pChargeObj.IsInPrice = False;
//	EndIf;
//	If pChargeObj.ВалютаЛицСчета <> FolioCurrency Тогда
//		pChargeObj.ВалютаЛицСчета = FolioCurrency;
//	EndIf;
//	If pChargeObj.FolioCurrencyExchangeRate <> FolioCurrencyExchangeRate Тогда
//		pChargeObj.FolioCurrencyExchangeRate = FolioCurrencyExchangeRate;
//	EndIf;
//	If pChargeObj.Валюта <> ReportingCurrency Тогда
//		pChargeObj.Валюта = ReportingCurrency;
//	EndIf;
//	If pChargeObj.ReportingCurrencyExchangeRate <> ReportingCurrencyExchangeRate Тогда
//		pChargeObj.ReportingCurrencyExchangeRate = ReportingCurrencyExchangeRate;
//	EndIf;
//	If pChargeObj.Фирма <> Фирма Тогда
//		pChargeObj.Фирма = Фирма;
//	EndIf;
//	If pChargeObj.ДисконтКарт <> DiscountCard Тогда
//		pChargeObj.ДисконтКарт = DiscountCard;
//	EndIf;
//	If pChargeObj.ТипСкидки <> DiscountType Тогда
//		pChargeObj.ТипСкидки = DiscountType;
//	EndIf;
//	If TrimAll(pChargeObj.ОснованиеСкидки) <> TrimAll(DiscountConfirmationText) Тогда
//		pChargeObj.ОснованиеСкидки = DiscountConfirmationText;
//	EndIf;
//	If pChargeObj.Скидка <> Discount Тогда
//		pChargeObj.Скидка = Discount;
//	EndIf;
//	If pChargeObj.DiscountServiceGroup <> DiscountServiceGroup Тогда
//		pChargeObj.DiscountServiceGroup = DiscountServiceGroup;
//	EndIf;
//	If pChargeObj.СуммаСкидки <> DiscountSumInFolioCurrency Тогда
//		pChargeObj.СуммаСкидки = DiscountSumInFolioCurrency;
//	EndIf;
//	If pChargeObj.НДСскидка <> VATDiscountSumInFolioCurrency Тогда
//		pChargeObj.НДСскидка = VATDiscountSumInFolioCurrency;
//	EndIf;
//	If pChargeObj.КомиссияАгента <> AgentCommission Тогда
//		pChargeObj.КомиссияАгента = AgentCommission;
//	EndIf;
//	If pChargeObj.ВидКомиссииАгента <> AgentCommissionType Тогда
//		pChargeObj.ВидКомиссииАгента = AgentCommissionType;
//	EndIf;
//	If pChargeObj.КомиссияАгентУслуги <> AgentCommissionServiceGroup Тогда
//		pChargeObj.КомиссияАгентУслуги = AgentCommissionServiceGroup;
//	EndIf;
//	If pChargeObj.СуммаКомиссии <> CommissionSumInFolioCurrency Тогда
//		pChargeObj.СуммаКомиссии = CommissionSumInFolioCurrency;
//	EndIf;
//	If pChargeObj.СуммаКомиссииНДС <> VATCommissionSumInFolioCurrency Тогда
//		pChargeObj.СуммаКомиссииНДС = VATCommissionSumInFolioCurrency;
//	EndIf;
//	If TrimAll(pChargeObj.Details) <> TrimAll(Details) Тогда
//		pChargeObj.Details = Details;
//	EndIf;
//	If НЕ pChargeObj.IsAdditional Тогда
//		pChargeObj.IsAdditional = True;
//	EndIf;
//КонецПроцедуры //FillChargeDocumentAttributesForRoomService
//
////-----------------------------------------------------------------------------
//Процедура FillChargeDocumentAttributesForFixedServiceCharge(pChargeObj)
//	If pChargeObj.ДокОснование <> ЛицевойСчет.ParentDoc Тогда
//		pChargeObj.ДокОснование = ЛицевойСчет.ParentDoc;
//	EndIf;
//	If pChargeObj.ParentRoomService <> Ref Тогда
//		pChargeObj.ParentRoomService = Ref;
//	EndIf;
//	If НЕ pChargeObj.IsFixedCharge Тогда
//		pChargeObj.IsFixedCharge = True;
//	EndIf;
//	If pChargeObj.Гостиница <> Гостиница Тогда
//		pChargeObj.Гостиница = Гостиница;
//	EndIf;
//	If pChargeObj.ExchangeRateDate <> ExchangeRateDate Тогда
//		pChargeObj.ExchangeRateDate = ExchangeRateDate;
//	EndIf;
//	If pChargeObj.СчетПроживания <> ЛицевойСчет Тогда
//		pChargeObj.СчетПроживания = ЛицевойСчет;
//	EndIf;
//	If pChargeObj.ТипКлиента <> ClientType Тогда
//		pChargeObj.ТипКлиента = ClientType;
//	EndIf;
//	If TrimAll(pChargeObj.СтрокаПодтверждения) <> TrimAll(ClientTypeConfirmationText) Тогда
//		pChargeObj.СтрокаПодтверждения = ClientTypeConfirmationText;
//	EndIf;
//	If pChargeObj.Услуга <> FixedService Тогда
//		pChargeObj.Услуга = FixedService;
//		If ЗначениеЗаполнено(pChargeObj.Услуга) And pChargeObj.PaymentSection <> pChargeObj.Услуга.PaymentSection Тогда
//			pChargeObj.PaymentSection = pChargeObj.Услуга.PaymentSection;
//		EndIf;
//	EndIf;
//	If pChargeObj.Цена <> cmRecalculatePrice(FixedServiceSumInFolioCurrency, 1) Тогда
//		pChargeObj.Цена = cmRecalculatePrice(FixedServiceSumInFolioCurrency, 1);
//	EndIf;
//	If TrimAll(pChargeObj.ЕдИзмерения) <> TrimAll(FixedService.Unit) Тогда
//		pChargeObj.ЕдИзмерения = FixedService.Unit;
//	EndIf;
//	If pChargeObj.Количество <> 1 Тогда
//		pChargeObj.Количество = 1;
//	EndIf;
//	If pChargeObj.Сумма <> FixedServiceSumInFolioCurrency Тогда
//		pChargeObj.Сумма = FixedServiceSumInFolioCurrency;
//	EndIf;
//	If pChargeObj.СтавкаНДС <> FixedServiceVATRate Тогда
//		pChargeObj.СтавкаНДС = FixedServiceVATRate;
//	EndIf;
//	If pChargeObj.СуммаНДС <> FixedServiceVATSumInFolioCurrency Тогда
//		pChargeObj.СуммаНДС = FixedServiceVATSumInFolioCurrency;
//	EndIf;
//	If TrimAll(pChargeObj.Примечания) <> TrimAll(Remarks) Тогда
//		pChargeObj.Примечания = Remarks;
//	EndIf;
//	If pChargeObj.IsRoomRevenue Тогда
//		pChargeObj.IsRoomRevenue = False;
//	EndIf;
//	If pChargeObj.IsInPrice Тогда
//		pChargeObj.IsInPrice = False;
//	EndIf;
//	If pChargeObj.ВалютаЛицСчета <> FolioCurrency Тогда
//		pChargeObj.ВалютаЛицСчета = FolioCurrency;
//	EndIf;
//	If pChargeObj.FolioCurrencyExchangeRate <> FolioCurrencyExchangeRate Тогда
//		pChargeObj.FolioCurrencyExchangeRate = FolioCurrencyExchangeRate;
//	EndIf;
//	If pChargeObj.Валюта <> ReportingCurrency Тогда
//		pChargeObj.Валюта = ReportingCurrency;
//	EndIf;
//	If pChargeObj.ReportingCurrencyExchangeRate <> ReportingCurrencyExchangeRate Тогда
//		pChargeObj.ReportingCurrencyExchangeRate = ReportingCurrencyExchangeRate;
//	EndIf;
//	If pChargeObj.Фирма <> Фирма Тогда
//		pChargeObj.Фирма = Фирма;
//	EndIf;
//	If pChargeObj.ДисконтКарт <> DiscountCard Тогда
//		pChargeObj.ДисконтКарт = DiscountCard;
//	EndIf;
//	If pChargeObj.ТипСкидки <> DiscountType Тогда
//		pChargeObj.ТипСкидки = DiscountType;
//	EndIf;
//	If TrimAll(pChargeObj.ОснованиеСкидки) <> TrimAll(DiscountConfirmationText) Тогда
//		pChargeObj.ОснованиеСкидки = DiscountConfirmationText;
//	EndIf;
//	If pChargeObj.Скидка <> Discount Тогда
//		pChargeObj.Скидка = Discount;
//	EndIf;
//	If pChargeObj.DiscountServiceGroup <> DiscountServiceGroup Тогда
//		pChargeObj.DiscountServiceGroup = DiscountServiceGroup;
//	EndIf;
//	If pChargeObj.СуммаСкидки <> FixedServiceDiscountSumInFolioCurrency Тогда
//		pChargeObj.СуммаСкидки = FixedServiceDiscountSumInFolioCurrency;
//	EndIf;
//	If pChargeObj.НДСскидка <> FixedServiceVATDiscountSumInFolioCurrency Тогда
//		pChargeObj.НДСскидка = FixedServiceVATDiscountSumInFolioCurrency;
//	EndIf;
//	If pChargeObj.КомиссияАгента <> AgentCommission Тогда
//		pChargeObj.КомиссияАгента = AgentCommission;
//	EndIf;
//	If pChargeObj.ВидКомиссииАгента <> AgentCommissionType Тогда
//		pChargeObj.ВидКомиссииАгента = AgentCommissionType;
//	EndIf;
//	If pChargeObj.КомиссияАгентУслуги <> AgentCommissionServiceGroup Тогда
//		pChargeObj.КомиссияАгентУслуги = AgentCommissionServiceGroup;
//	EndIf;
//	If pChargeObj.СуммаКомиссии <> FixedServiceCommissionSumInFolioCurrency Тогда
//		pChargeObj.СуммаКомиссии = FixedServiceCommissionSumInFolioCurrency;
//	EndIf;
//	If pChargeObj.СуммаКомиссииНДС <> FixedServiceVATCommissionSumInFolioCurrency Тогда
//		pChargeObj.СуммаКомиссииНДС = FixedServiceVATCommissionSumInFolioCurrency;
//	EndIf;
//	If НЕ pChargeObj.IsAdditional Тогда
//		pChargeObj.IsAdditional = True;
//	EndIf;
//КонецПроцедуры //FillChargeDocumentAttributesForFixedServiceCharge
//
////-----------------------------------------------------------------------------
//Процедура SetChargeHotelAndNumber(pChargeObj)
//	If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.Гостиница) Тогда
//			If pChargeObj.Гостиница <> ЛицевойСчет.Гостиница Тогда
//				pChargeObj.Гостиница = ЛицевойСчет.Гостиница;
//				pChargeObj.SetNewNumber(TrimAll(pChargeObj.Гостиница.GetObject().pmGetPrefix()));
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //SetChargeHotelAndNumber	
//
////-----------------------------------------------------------------------------
//Процедура pmFillRoomServiceChargeType() Экспорт
//	RoomServiceChargeType = TrimAll(RoomService.Code);
//КонецПроцедуры //pmFillRoomServiceChargeType
//
////-----------------------------------------------------------------------------
//Процедура PostToRoomServices(pCharge, pFixedServiceCharge)
//	Movement = RegisterRecords.УслугиНомера.Add();
//	
//	Movement.Period = Date;
//	
//	FillPropertyValues(Movement, ThisObject);
//	
//	// Resources
//	Movement.Сумма = Sum;
//	
//	// Attributes
//	If pCharge <> Неопределено Тогда
//		Movement.Начисление = pCharge.Ref;
//	EndIf;
//	If pFixedServiceCharge <> Неопределено Тогда
//		Movement.FixedServiceCharge = pFixedServiceCharge.Ref;
//	EndIf;
//	
//	If ЗначениеЗаполнено(Movement.Начисление) Or ЗначениеЗаполнено(Movement.FixedServiceCharge) Тогда
//		RegisterRecords.УслугиНомера.Write();
//	EndIf;
//КонецПроцедуры //PostToRoomServices
//
////-----------------------------------------------------------------------------
//// Document will create charge for the ГруппаНомеров service charge specified
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pPostingMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// First check if there is posted charges for the current document
//	vCharges = pmGetRoomServiceCharges();
//	// Initialize charge objects
//	vChargeObj = Неопределено;
//	vFixedServiceChargeObj = Неопределено;
//	For Each vChargesRow In vCharges Do
//		If vChargesRow.Начисление.IsFixedCharge Тогда
//			vFixedServiceChargeObj = vChargesRow.Начисление.GetObject();
//		Else
//			vChargeObj = vChargesRow.Начисление.GetObject();
//		EndIf;
//	EndDo;
//	If ЗначениеЗаполнено(RoomService) Тогда
//		If vChargeObj = Неопределено Тогда
//			// Create charge document
//			vChargeObj = Documents.Начисление.CreateDocument();
//			vChargeObj.pmFillAttributesWithDefaultValues();
//			SetChargeHotelAndNumber(vChargeObj);
//		EndIf;
//	Else
//		If vChargeObj <> Неопределено Тогда
//			// Mark this document deleted
//			If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//				vChargeObj.SetDeletionMark(True);
//			EndIf;
//			vChargeObj = Неопределено;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(FixedService) Тогда
//		If vFixedServiceChargeObj = Неопределено Тогда
//			// Create charge document
//			vFixedServiceChargeObj = Documents.Начисление.CreateDocument();
//			vFixedServiceChargeObj.pmFillAttributesWithDefaultValues();
//			SetChargeHotelAndNumber(vFixedServiceChargeObj);
//		EndIf;
//	Else
//		If vFixedServiceChargeObj <> Неопределено Тогда
//			// Mark this document deleted
//			If НЕ cmIfChargeIsInClosedDay(vFixedServiceChargeObj) Тогда
//				vFixedServiceChargeObj.SetDeletionMark(True);
//			EndIf;
//			vFixedServiceChargeObj = Неопределено;
//		EndIf;
//	EndIf;
//	// Fill charges
//	If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		If vChargeObj <> Неопределено Тогда
//			// Post this document
//			FillChargeDocumentAttributesForRoomService(vChargeObj);
//			If vChargeObj.Modified() Тогда
//				If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//					vChargeObj.Write(DocumentWriteMode.Posting);
//				EndIf;
//			Endif;
//		EndIf;
//		If vFixedServiceChargeObj <> Неопределено Тогда
//			// Post this document
//			FillChargeDocumentAttributesForFixedServiceCharge(vFixedServiceChargeObj);
//			If vFixedServiceChargeObj.Modified() Тогда
//				If НЕ cmIfChargeIsInClosedDay(vFixedServiceChargeObj) Тогда
//					vFixedServiceChargeObj.Write(DocumentWriteMode.Posting);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Post to RoomServices register
//	PostToRoomServices(vChargeObj, vFixedServiceChargeObj);
//КонецПроцедуры //Posting
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
//	If НЕ ЗначениеЗаполнено(Currency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Валюта", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<НомерРазмещения> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ServiceDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата и время услуги> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Услуга Начисление date and time> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Услуга Начисление date and time> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ServiceDate", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата курса> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(RoomService) And НЕ ЗначениеЗаполнено(FixedService) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Как минимум одна из услуг должна быть указана!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "At least one Услуга should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "At least one Услуга should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "RoomService", pAttributeInErr);
//	EndIf;
//	If Sum <> 0 Тогда
//		If НЕ ЗначениеЗаполнено(ЛицевойСчет) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Реквизит <Фолио> должен быть заполнен!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
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
//	Author = ПараметрыСеанса.ТекПользователь;
//	Date = CurrentDate();
//КонецПроцедуры //pmFillAuthorAndDate
//
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill author and date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		Фирма = Гостиница.Фирма;
//		RoomServicePriceIsWithVAT = True;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			VATRate = Фирма.VATRate;
//			FixedServiceVATRate = Фирма.VATRate;
//		EndIf;
//		ExchangeRateDate = BegOfDay(Date); 
//		ServiceDate = Date;
//		Currency = Гостиница.BaseCurrency;
//		CurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, Currency, ExchangeRateDate);
//		ReportingCurrency = Гостиница.ReportingCurrency;
//		ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, ExchangeRateDate);
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
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
//	Else
//		// Check if this document is closed by settlement
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And 
//		  (pWriteMode = DocumentWriteMode.UndoPosting Or DeletionMark) And 
//		  (Sum <> 0 Or Quantity <> 0) And ЗначениеЗаполнено(ЛицевойСчет) And ЛицевойСчет.IsClosed And 
//		   cmGetRoomServiceDocumentCharges(Ref).Count() > 0 Тогда
//			vDocBalanceIsZero = False;
//			vDocBalancesRow = cmGetRoomServiceDocumentCurrentAccountsReceivableBalance(Ref);
//			If vDocBalancesRow <> Неопределено Тогда
//				If vDocBalancesRow.SumBalance = 0 And vDocBalancesRow.QuantityBalance = 0 Тогда
//					vDocBalanceIsZero = True;
//				EndIf;
//			Else
//				vDocBalanceIsZero = True;
//			EndIf;
//			If vDocBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='This document is closed by settlement! You can not change this document.';ru='Документ уже закрыт актом об оказании услуг! Редактирование такого докумена запрещено.';de='Das Dokument wurde bereits über ein Dienstleistungserbringungsprotokoll geschlossen! Die Bearbeitung eines solchen Dokuments ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
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
//Процедура UndoPosting(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// First check if there is posted charges for the current document
//	vCharges = pmGetRoomServiceCharges();
//	// Undo posting for them
//	For Each vChargesRow In vCharges Do
//		vChargeObj = vChargesRow.Начисление.GetObject();
//		vChargeObj.Write(DocumentWriteMode.UndoPosting);
//	EndDo;
//КонецПроцедуры //UndoPosting
//
////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If Posted Тогда
//		// Check if this document is closed by settlement
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And 
//		  (Sum <> 0 Or Quantity <> 0) And ЗначениеЗаполнено(ЛицевойСчет) And ЛицевойСчет.IsClosed And 
//		   cmGetRoomServiceDocumentCharges(Ref).Count() > 0 Тогда
//			vDocBalanceIsZero = False;
//			vDocBalancesRow = cmGetRoomServiceDocumentCurrentAccountsReceivableBalance(Ref);
//			If vDocBalancesRow <> Неопределено Тогда
//				If vDocBalancesRow.SumBalance = 0 And vDocBalancesRow.QuantityBalance = 0 Тогда
//					vDocBalanceIsZero = True;
//				EndIf;
//			Else
//				vDocBalanceIsZero = True;
//			EndIf;
//			If vDocBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='This document is closed by settlement! You can not change this document.';ru='Документ уже закрыт актом об оказании услуг! Редактирование такого докумена запрещено.';de='Das Dokument wurde bereits über ein Dienstleistungserbringungsprotokoll geschlossen! Die Bearbeitung eines solchen Dokuments ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		UndoPosting(pCancel);
//	EndIf;
//КонецПроцедуры //BeforeDelete
