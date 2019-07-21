//Перем IsInFileMode;

////-----------------------------------------------------------------------------
//Процедура FillRQInitializationAttributes(pRQRec, pPeriod)
//	pRQRec.КвотаНомеров = RoomQuota;
//	pRQRec.Гостиница = Гостиница;
//	pRQRec.ТипНомера = RoomType;
//	pRQRec.НомерРазмещения = ГруппаНомеров;

//	pRQRec.Period = pPeriod;
//	
//	pRQRec.НомеровКвота = 0;
//	pRQRec.МестКвота = 0;
//	pRQRec.ОстаетсяНомеров = 0;
//	pRQRec.ОстаетсяМест = 0;
//	
//	pRQRec.СчетчикДокКвота = 1;
//	
//	pRQRec.IsRoomQuota = False;
//КонецПроцедуры //FillRQAttributes

////-----------------------------------------------------------------------------
//Процедура FillRQAttributes(pRQRec, pRoomQuota, pPeriod)
//	FillPropertyValues(pRQRec, pRoomQuota);
//	FillPropertyValues(pRQRec, ThisObject);

//	pRQRec.КвотаНомеров = pRoomQuota;
//	pRQRec.Period = pPeriod;
//	
//	If ЗначениеЗаполнено(Тариф) Тогда
//		pRQRec.RoomRateType = Тариф.RoomRateType;
//	EndIf;
//	
//	pRQRec.НомеровКвота = NumberOfRooms;
//	pRQRec.МестКвота = NumberOfBeds;
//	pRQRec.ОстаетсяНомеров = NumberOfRooms;
//	pRQRec.ОстаетсяМест = NumberOfBeds;
//	If SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Remove Тогда
//		pRQRec.НомеровКвота = -pRQRec.НомеровКвота;
//		pRQRec.МестКвота = -pRQRec.МестКвота;
//		pRQRec.ОстаетсяНомеров = -pRQRec.ОстаетсяНомеров;
//		pRQRec.ОстаетсяМест = -pRQRec.ОстаетсяМест;
//	EndIf;
//	
//	pRQRec.СчетчикДокКвота = 0;
//	
//	pRQRec.IsRoomQuota = True;
//КонецПроцедуры //FillRQAttributes

////-----------------------------------------------------------------------------
//Процедура PostToRoomQuotaSales(pCancel)
//	// Do receipt movement on begin of time to initialize ГруппаНомеров quota balances
//	vRQRec = RegisterRecords.ПродажиКвот.AddReceipt();
//	FillRQInitializationAttributes(vRQRec, '20000101');
//	
//	// Do receipt movement on date from
//	vRQRec = RegisterRecords.ПродажиКвот.AddReceipt();
//	FillRQAttributes(vRQRec, RoomQuota, cm0SecondShift(DateFrom));
//		
//	// If end of ГруппаНомеров quota period is filled
//	If ЗначениеЗаполнено(DateTo) Тогда
//		// Do expense movement on date to
//		vRQRec = RegisterRecords.ПродажиКвот.AddExpense();
//		FillRQAttributes(vRQRec, RoomQuota, cm0SecondShift(DateTo));
//		
//		// Do receipt initialization movements on each day from the ГруппаНомеров quota period
//		If SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Add Тогда
//			vCurDate = DateFrom;
//			While vCurDate < DateTo Do
//				vRQRec = RegisterRecords.ПродажиКвот.AddReceipt();
//				FillRQInitializationAttributes(vRQRec, vCurDate);
//				vCurDate = vCurDate + 24*3600;
//			EndDo;		
//		EndIf;
//	EndIf;
//	
//	// Do inverted movements for the base allotment
//	If ЗначениеЗаполнено(BaseRoomQuota) Тогда
//		// Do expense movement on date from
//		vRQRec = RegisterRecords.ПродажиКвот.AddExpense();
//		FillRQAttributes(vRQRec, BaseRoomQuota, cm0SecondShift(DateFrom));
//			
//		// If end of ГруппаНомеров quota period is filled
//		If ЗначениеЗаполнено(DateTo) Тогда
//			// Do receipt movement on date to
//			vRQRec = RegisterRecords.ПродажиКвот.AddReceipt();
//			FillRQAttributes(vRQRec, BaseRoomQuota, cm0SecondShift(DateTo));
//		EndIf;
//	EndIf;
//			
//	// Write RegisterRecords	
//	RegisterRecords.ПродажиКвот.Write();
//КонецПроцедуры //PostToRoomQuotaSales

////-----------------------------------------------------------------------------
//Процедура FillRIAttributes(pRIRec, pRoomQuota, pPeriod)
//	FillPropertyValues(pRIRec, ThisObject);
//	
//	pRIRec.КвотаНомеров = pRoomQuota;
//	pRIRec.Period = pPeriod;
//	pRIRec.ПериодС = cm0SecondShift(DateFrom);
//	pRIRec.ПериодПо = cm0SecondShift(DateTo);
//	
//	If ЗначениеЗаполнено(RoomType) And ЗначениеЗаполнено(RoomType.BaseRoomType) Тогда
//		pRIRec.ТипНомера = RoomType.BaseRoomType;
//	EndIf;		
//	
//	If ЗначениеЗаполнено(Тариф) Тогда
//		pRIRec.RoomRateType = Тариф.RoomRateType;
//	EndIf;
//	
//	pRIRec.CheckInDate = cm0SecondShift(DateFrom);
//	pRIRec.CheckInAccountingDate = BegOfDay(DateFrom);
//	pRIRec.CheckOutDate = cm0SecondShift(DateTo);
//	pRIRec.CheckOutAccountingDate = BegOfDay(DateTo);
//	
//	If ЗначениеЗаполнено(DateTo) And ЗначениеЗаполнено(ChargingFolio) And ЗначениеЗаполнено(Service) And Price > 0 Тогда
//		pRIRec.PricePresentation = cmFormatSum(Price, FolioCurrency, "NZ=---", ПараметрыСеанса.ТекЛокализация);
//		pRIRec.PlannedPaymentMethod = ChargingFolio.PaymentMethod;
//	Else
//		pRIRec.PricePresentation = "";
//	EndIf;
//	
//	pRIRec.НомеровКвота = NumberOfRooms;
//	pRIRec.МестКвота = NumberOfBeds;
//	pRIRec.RoomsVacant = NumberOfRooms;
//	pRIRec.BedsVacant = NumberOfBeds;
//	If SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Remove Тогда
//		pRIRec.НомеровКвота = -pRIRec.НомеровКвота;
//		pRIRec.МестКвота = -pRIRec.МестКвота;
//		pRIRec.RoomsVacant = -pRIRec.RoomsVacant;
//		pRIRec.BedsVacant = -pRIRec.BedsVacant;
//	EndIf;
//	
//	pRIRec.IsRoomQuota = True;
//КонецПроцедуры //FillRIAttributes

////-----------------------------------------------------------------------------
//Процедура WriteRoomInitializationRecords()
//	// Check if there are initialization records for the current ГруппаНомеров type
//	vAddInitRecords = True;
//	If ЗначениеЗаполнено(RoomType) And RoomType.IsVirtual Тогда
//		vAddInitRecords = False;
//	EndIf;
//	If vAddInitRecords Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	COUNT(*) AS Count
//		|FROM
//		|	AccumulationRegister.ЗагрузкаНомеров AS RoomInventory
//		|WHERE
//		|	ЗагрузкаНомеров.СчетчикДокКвота > 0
//		|	AND ЗагрузкаНомеров.Гостиница = &qHotel
//		|	AND ЗагрузкаНомеров.ТипНомера = &qRoomType
//		|	AND ЗагрузкаНомеров.Period > &qInitializationDate";
//		vQry.SetParameter("qHotel", Гостиница);
//		vQry.SetParameter("qRoomType", RoomType);
//		vQry.SetParameter("qInitializationDate", '20000101');
//		vQryRes = vQry.Execute().Unload();
//		If vQryRes.Count() > 0 Тогда
//			vQryResRow = vQryRes.Get(0);
//			If vQryResRow.Count > 0 Тогда
//				vAddInitRecords = False;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Write initialization records for all dates in the ГруппаНомеров type next N years
//	vN = 15;
//	If IsInFileMode Тогда
//		vN = 3;
//	EndIf;
//	If vAddInitRecords Тогда
//		// Write first initialization record to the 1st of january of year 2000
//		vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//		
//		vRIRec.Period = '20000101';
//		vRIRec.Гостиница = Гостиница;
//		vRIRec.ТипНомера = RoomType;
//		vRIRec.НомерРазмещения = ГруппаНомеров;
//		
//		vRIRec.ВсегоНомеров = 0;
//		vRIRec.ВсегоМест = 0;
//		vRIRec.ВсегоГостей = 0;
//		vRIRec.RoomsVacant = 0;
//		vRIRec.BedsVacant = 0;
//		vRIRec.GuestsVacant = 0;
//		
//		vRIRec.СчетчикДокКвота = 1;
//		
//		vRIRec.ДокОснование = Ref;
//		vRIRec.КоличествоМестНомер = 0;
//		vRIRec.КоличествоГостейНомер = 0;
//		vRIRec.Примечания = "";
//		vRIRec.Автор = Справочники.Employees.EmptyRef();
//		vRIRec.IsRoomInventory = False;
//		vCurDate = BegOfDay(Min(Date, CurrentDate() - 24*3600));
//		
//		// Write initialization records for all dates in the ГруппаНомеров type next N years
//		vEndOfInitializationPeriod = BegOfDay(Max(Date, CurrentDate())) + 366*vN*24*3600;
//		While vCurDate < vEndOfInitializationPeriod Do
//			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//			
//			vRIRec.Period = vCurDate;
//			vRIRec.Гостиница = Гостиница;
//			vRIRec.ТипНомера = RoomType;
//			vRIRec.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//			
//			vRIRec.ВсегоНомеров = 0;
//			vRIRec.ВсегоМест = 0;
//			vRIRec.ВсегоГостей = 0;
//			vRIRec.RoomsVacant = 0;
//			vRIRec.BedsVacant = 0;
//			vRIRec.GuestsVacant = 0;
//			
//			vRIRec.СчетчикДокКвота = 1;
//			
//			vRIRec.ДокОснование = Ref;
//			vRIRec.КоличествоМестНомер = 0;
//			vRIRec.КоличествоГостейНомер = 0;
//			vRIRec.Примечания = "";
//			vRIRec.Автор = Справочники.Employees.EmptyRef();
//			vRIRec.IsRoomInventory = False;
//			
//			vCurDate = vCurDate + 24*3600;
//		EndDo;
//	EndIf;
//КонецПроцедуры //WriteRoomInitializationRecords

////-----------------------------------------------------------------------------
//Процедура PostToRoomInventory(pCancel)
//	// Add ГруппаНомеров inventory initialization records
//	WriteRoomInitializationRecords();
//	
//	// Do expense movement on date from
//	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
//	FillRIAttributes(vRIRec, RoomQuota, cm0SecondShift(DateFrom));
//		
//	// Do receipt movement on date to
//	If ЗначениеЗаполнено(DateTo) Тогда
//		vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//		FillRIAttributes(vRIRec, RoomQuota, cm0SecondShift(DateTo));
//	EndIf;
//	
//	// Do inverted movements for the base allotment
//	If ЗначениеЗаполнено(BaseRoomQuota) Тогда
//		// Do receipt movement on date from
//		vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//		FillRIAttributes(vRIRec, BaseRoomQuota, cm0SecondShift(DateFrom));
//			
//		// Do expense movement on date to
//		If ЗначениеЗаполнено(DateTo) Тогда
//			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
//			FillRIAttributes(vRIRec, BaseRoomQuota, cm0SecondShift(DateTo));
//		EndIf;
//	EndIf;		
//			
//	// Write RegisterRecords	
//	RegisterRecords.ЗагрузкаНомеров.Write();
//КонецПроцедуры //PostToRoomInventory

////-----------------------------------------------------------------------------
//Процедура DoCharge(pPeriod, pCancel)
//	vChargeObj = Documents.Начисление.CreateDocument();
//	
//	FillPropertyValues(vChargeObj, ChargingFolio, , "Number, Date, Автор, DeletionMark, Posted");
//	FillPropertyValues(vChargeObj, ThisObject, , "Number, Date, Автор, DeletionMark, Posted");
//	
//	vChargeObj.ДатаДок = pPeriod;
//	vChargeObj.SetTime(AutoTimeMode.DontUse);
//	vChargeObj.ДокОснование = ThisObject.Ref;
//	vChargeObj.Автор = ПараметрыСеанса.ТекПользователь;
//	
//	vChargeObj.СчетПроживания = ChargingFolio;
//	vChargeObj.Количество = ?(NumberOfBeds<>0, ?(NumberOfBeds<0, -1, 1), 1);
//	If SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Remove Тогда
//		vChargeObj.Количество = -vChargeObj.Количество;
//	EndIf;
//	vChargeObj.ЕдИзмерения = Service.Unit;
//	vChargeObj.Сумма = vChargeObj.Количество*vChargeObj.Цена;
//	vChargeObj.СуммаНДС = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.Сумма);
//	If vChargeObj.IsRoomRevenue Тогда
//		vChargeObj.ПроданоНомеров = NumberOfRooms;
//		vChargeObj.ПроданоМест = NumberOfBeds;
//		If SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Remove Тогда
//			vChargeObj.ПроданоНомеров = -vChargeObj.ПроданоНомеров;
//			vChargeObj.ПроданоМест = -vChargeObj.ПроданоМест;
//		EndIf;
//		vChargeObj.ПроданоДопМест = 0;
//		vChargeObj.ЧеловекаДни = 0;
//		vChargeObj.ЗаездГостей = 0;
//	EndIf;
//	
//	// Fill charge exchange rate date and folio and reporting currency exchange rates
//	vChargeObj.ExchangeRateDate = BegOfDay(vChargeObj.ДатаДок);
//	vChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.ВалютаЛицСчета, vChargeObj.ExchangeRateDate);
//	vChargeObj.ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.Валюта, vChargeObj.ExchangeRateDate);
//	
//	// Fill charge payment section
//	vChargeObj.PaymentSection = vChargeObj.Услуга.PaymentSection;
//		
//	// Post charge
//	If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//		vChargeObj.Write(DocumentWriteMode.Posting);
//	EndIf;
//КонецПроцедуры //DoCharge

////-----------------------------------------------------------------------------
//Процедура ChargeServices(pCancel)
//	vPeriod = BegOfDay(DateFrom);
//	vPeriodTo = BegOfDay(DateTo);
//	While vPeriod < vPeriodTo Do
//		DoCharge(vPeriod, pCancel);
//		
//		vPeriod = vPeriod + 24*3600;
//	EndDo;
//КонецПроцедуры //ChargeServices

////-----------------------------------------------------------------------------
//Процедура RepostIntersectedDocuments()
//	// If this document is referenced by allotment ГруппаНомеров types then skip reposting
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomQuotasRoomTypes.СоставКвоты
//	|FROM
//	|	Catalog.КвотаНомеров.ТипыНомеров AS RoomQuotasRoomTypes
//	|WHERE
//	|	RoomQuotasRoomTypes.СоставКвоты = &qRef";
//	vQry.SetParameter("qRef", Ref);
//	vAllotments = vQry.Execute().Unload();
//	If vAllotments.Count() > 0 Тогда
//		Return;
//	EndIf;
//	// Run query to get list of documents to be reposted
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ЗагрузкаНомеров.Recorder
//	|INTO RecordersWithRoomQuotaWriteOffs
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров AS RoomInventory
//	|WHERE
//	|	ЗагрузкаНомеров.КвотаНомеров = &qRoomQuota
//	|	AND ЗагрузкаНомеров.IsRoomQuota
//	|	AND ЗагрузкаНомеров.Period >= &qPeriodFrom
//	|	AND ЗагрузкаНомеров.Period <= &qPeriodTo
//	|	AND ЗагрузкаНомеров.ТипНомера = &qRoomType
//	|	AND (ЗагрузкаНомеров.НомерРазмещения = &qRoom
//	|			OR &qRoomIsEmpty)
//	|	AND ЗагрузкаНомеров.Гостиница = &qHotel
//	|	AND ЗагрузкаНомеров.BedsVacant = RoomInventory.МестКвота
//	|	AND ЗагрузкаНомеров.BedsVacant < 0
//	|	AND (NOT ЗагрузкаНомеров.Recorder REFS Document.СоставКвоты)
//	|
//	|GROUP BY
//	|	ЗагрузкаНомеров.Recorder
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomQuotaDocs.Recorder
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров AS RoomQuotaDocs
//	|WHERE
//	|	RoomQuotaDocs.КвотаНомеров = &qRoomQuota
//	|	AND (RoomQuotaDocs.IsReservation
//	|			OR RoomQuotaDocs.IsAccommodation)
//	|	AND RoomQuotaDocs.Period >= &qPeriodFrom
//	|	AND RoomQuotaDocs.Period <= &qPeriodTo
//	|	AND RoomQuotaDocs.ТипНомера = &qRoomType
//	|	AND (RoomQuotaDocs.НомерРазмещения = &qRoom
//	|			OR &qRoomIsEmpty)
//	|	AND RoomQuotaDocs.Гостиница = &qHotel
//	|	AND (RoomQuotaDocs.ВидРазмещения.ТипРазмещения = &qRoom OR RoomQuotaDocs.ВидРазмещения.ТипРазмещения = &qBeds)
//	|	AND (NOT RoomQuotaDocs.Recorder IN
//	|				(SELECT
//	|					RecordersWithRoomQuotaWriteOffs.Recorder
//	|				FROM
//	|					RecordersWithRoomQuotaWriteOffs AS RecordersWithRoomQuotaWriteOffs))
//	|
//	|GROUP BY
//	|	RoomQuotaDocs.Recorder";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qRoomQuota", RoomQuota);
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qPeriodFrom", cm0SecondShift(DateFrom));
//	vQry.SetParameter("qPeriodTo", cm0SecondShift(DateTo));
//	vQry.SetParameter("qRoom", Перечисления.AccomodationTypes.НомерРазмещения);
//	vQry.SetParameter("qBeds", Перечисления.AccomodationTypes.Beds);
//	vDocs = vQry.Execute().Unload();
//	For Each vDocsRow In vDocs Do
//		vDocObj = vDocsRow.Recorder.GetObject();
//		vDocObj.Write(DocumentWriteMode.Posting);
//	EndDo;
//КонецПроцедуры //RepostIntersectedDocuments

////-----------------------------------------------------------------------------
//Процедура CheckNegativeRoomQuotaBalances()
//	vQry = New Query;
//	vQry.Text = 
//	"SELECT
//	|	ПродажиКвот.Гостиница,
//	|	ПродажиКвот.КвотаНомеров,
//	|	ПродажиКвот.ТипНомера, " + 
//	?((RoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(ГруппаНомеров)), "ПродажиКвот.НомерРазмещения, ", "") + "
//	|	MIN(ПродажиКвот.RoomsInQuotaClosingBalance) AS НомеровКвота,
//	|	MIN(ПродажиКвот.BedsInQuotaClosingBalance) AS МестКвота,
//	|	MIN(ПродажиКвот.RoomsRemainsClosingBalance) AS ОстаетсяНомеров,
//	|	MIN(ПродажиКвот.BedsRemainsClosingBalance) AS ОстаетсяМест
//	|
//	|FROM
//	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
//	|	                                                        Second, 
//	|	                                                        RegisterRecordsAndPeriodBoundaries, 
//	|	                                                        КвотаНомеров = &qRoomQuota AND 
//	|	                                                        Гостиница = &qHotel AND 
//	|	                                                        ТипНомера = &qRoomType" +
//																?((RoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(ГруппаНомеров)), " AND НомерРазмещения = &qRoom", "") + "
//	|) AS ПродажиКвот
//	|
//	|GROUP BY
//	|	ПродажиКвот.Гостиница,
//	|	ПродажиКвот.КвотаНомеров,
//	|	ПродажиКвот.ТипНомера" + ?((RoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(ГруппаНомеров)), ", ПродажиКвот.НомерРазмещения", "");
//	vQry.SetParameter("qRoomQuota", RoomQuota);
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qDateFrom", DateFrom);
//	vQry.SetParameter("qDateTo", New Boundary(DateTo, BoundaryType.Excluding));
//	vQryTab = vQry.Execute().Unload();
//	If vQryTab.Count() = 1 Тогда
//		vQryRow = vQryTab.Get(0);
//		If vQryRow.НомеровКвота < 0 Or vQryRow.МестКвота < 0 Тогда
//			ВызватьИсключение NStr("en='НЕ enough rooms in the allotment!';ru='Невозможно снять запрошенное кол-во номеров, т.к. квота будет выведена в минус!';de='Die Buchung der angegebenen Anzahl von Zimmern ist nicht möglich, da die Quote einen negativen Wert erreichen wird!'");
//		EndIf;
//	EndIf;
//КонецПроцедуры //CheckNegativeRoomQuotaBalances

////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Fill execution mode
//	IsInFileMode = False;
//	If Left(InfoBaseConnectionString(), 5) = "File=" Тогда
//		IsInFileMode = True;
//	EndIf;
//	// Undo posting first
//	UndoPosting(pCancel);
//	// Do charging to the folio specified
//	If RoomQuota.DoCharge And ЗначениеЗаполнено(ChargingFolio) And ЗначениеЗаполнено(Service) Тогда
//		ChargeServices(pCancel);
//	EndIf;
//	// Add data locks
//	vDataLock = New DataLock();
//	vRQItem = vDataLock.Add("AccumulationRegister.ПродажиКвот");
//	vRQItem.Mode = DataLockMode.Exclusive;
//	vRQItem.SetValue("КвотаНомеров", RoomQuota);
//	vRQItem.SetValue("ТипНомера", RoomType);
//	vDataLock.Lock();
//	// Post to ГруппаНомеров quota sales
//	PostToRoomQuotaSales(pCancel);
//	// Post to ГруппаНомеров inventory if necessary
//	If RoomQuota.DoWriteOff Тогда
//		PostToRoomInventory(pCancel);
//	EndIf;
//	// Check ГруппаНомеров quota balances
//	If НЕ pCancel Тогда
//		pCancel	= pmCheckDocumentAttributes(True, vMessage, vAttributeInErr, False);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//	EndIf;
//	// Try to find reservations and accommodations that should be reposted
//	If SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Add Тогда
//		RepostIntersectedDocuments();
//	ElsIf SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Remove Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToDoRoomQuotaOversales") Тогда
//			CheckNegativeRoomQuotaBalances();
//		EndIf;
//	EndIf;
//КонецПроцедуры //Posting

////-----------------------------------------------------------------------------
//Процедура UndoPosting(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Delete all chargings
//	vChargesTab = cmGetTableOfAlreadyChargedServices(ThisObject.Ref);
//	For Each vChargesRec In vChargesTab Do
//		vChargeObj = vChargesRec.Ref.GetObject();
//		If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//			vChargeObj.SetDeletionMark(True);
//		EndIf;
//	EndDo;
//КонецПроцедуры //UndoPosting

////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pIsPosted, pMessage, pAttributeInErr, pDoNotCheckRests = False) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//	vMsgTextEn = "";
//	vMsgTextDe = "";
//	If НЕ ЗначениеЗаполнено(RoomQuota) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Квота номеров> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения allotment> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<НомерРазмещения allotment> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "КвотаНомеров", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения allotment> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<НомерРазмещения allotment> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(RoomType) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Тип номера> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения type> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<НомерРазмещения type> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ТипНомера", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(RoomQuota) Тогда
//		If ЗначениеЗаполнено(RoomQuota.Гостиница) And RoomQuota.Гостиница <> Гостиница Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "<Гостиница> операции отличается от гостиницы квоты!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Operation <Гостиница> is different from allotment hotel!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Operation <Гостиница> unterscheidet sich von den Гостиница im Allotment!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//		EndIf;
//		If RoomQuota.IsQuotaForRooms Тогда
//			If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения> должен быть заполнен, т.к. выбрана квота по номерам!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "<НомерРазмещения> attribute should be filled because you have choosen allotment for rooms!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "<НомерРазмещения> attribute should be filled because you have choosen allotment for rooms!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//			EndIf;
//		Else
//			If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения> должен быть пустой, т.к. выбрана квота по типам номеров!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "<НомерРазмещения> attribute should be empty because you have choosen НомерРазмещения type allotment!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "<НомерРазмещения> attribute should be empty because you have choosen НомерРазмещения type allotment!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//			EndIf;
//		EndIf;
//		If RoomQuota.DoCharge Тогда
//			If НЕ ЗначениеЗаполнено(ChargingFolio) Or НЕ ЗначениеЗаполнено(Service) Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Для начисления услуг по квоте должны быть заполнены <Лицевой счет>, <Услуга>!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "<СчетПроживания>, <Услуга> should be filled to Начисление services!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "<СчетПроживания>, <Услуга> should be filled to Начисление services!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "ChargingFolio", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(RoomType) And ЗначениеЗаполнено(Гостиница) Тогда
//		If RoomType.Owner <> Гостиница Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "<Гостиница> операции отличается от гостиницы типа номера!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Operation <Гостиница> is different from НомерРазмещения type hotel!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Operation <Гостиница> unterscheidet sich von den Гостиница im Zimmertyp!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SetRoomQuotaType) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Вид движения> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Movement type> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Movement type> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "SetRoomQuotaType", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DateFrom) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата начала периода квоты номеров> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Start of НомерРазмещения allotment period> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Start of НомерРазмещения allotment period> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ДатаНачКвоты", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DateTo) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата окончания периода квоты номеров> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<End of НомерРазмещения allotment period> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<End of НомерРазмещения allotment period> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ДатаКонКвоты", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(DateFrom) And ЗначениеЗаполнено(DateTo) And DateFrom >= DateTo Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Дата начала периода изменения квоты номеров должна быть раньше чем дата окончания периода изменения квоты!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "Start of change НомерРазмещения allotment period should be earlier then end of change НомерРазмещения allotment period!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Start of change НомерРазмещения allotment period should be earlier then end of change НомерРазмещения allotment period!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ДатаНачКвоты", pAttributeInErr);
//	EndIf;
//	// Check that there are priods with check-in date started from the document period from and ending with document period to
//	If ЗначениеЗаполнено(RoomQuota) And RoomQuota.IsForCheckInPeriods Тогда
//		If НЕ cmCheckCheckInPeriods(Гостиница, RoomQuota, DateFrom, DateTo) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Указанный период не попадает на границы заездов!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Period specified is out from the check-in period dates!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Period specified is out from the check-in period dates!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ДатаКонКвоты", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(BaseRoomQuota) And BaseRoomQuota.IsForCheckInPeriods Тогда
//		If НЕ cmCheckCheckInPeriods(Гостиница, BaseRoomQuota, DateFrom, DateTo) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Указанный период не попадает на границы заездов квоты с которой списываются номера!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Period specified is out from the check-in period dates of the allotment to write off НомернойФонд from!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Period specified is out from the check-in period dates of the allotment to write off НомернойФонд from!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ДатаКонКвоты", pAttributeInErr);
//		EndIf;
//	EndIf;
//	// Check allotment vacant rooms balances
//	If НЕ pDoNotCheckRests Тогда
//		If ЗначениеЗаполнено(RoomQuota) Тогда
//			If НЕ cmCheckRoomQuotaAvailability(RoomQuota.Agent, RoomQuota.Контрагент, RoomQuota.Contract, RoomQuota, 
//			                                    Гостиница, RoomType, ГруппаНомеров, ThisObject.Ref, pIsPosted, True,
//												NumberOfRooms, NumberOfBeds, 
//			                                    cm1SecondShift(DateFrom), cm0SecondShift(DateTo), 
//			                                    vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//				vHasErrors = True; 
//				pAttributeInErr = ?(pAttributeInErr = "", "ДатаНачКвоты", pAttributeInErr);
//			EndIf;
//			If ЗначениеЗаполнено(RoomType) And НЕ ЗначениеЗаполнено(BaseRoomQuota) Тогда
//				If НЕ cmCheckRoomAvailability(Гостиница, Неопределено, ?(ЗначениеЗаполнено(RoomType.BaseRoomType), RoomType.BaseRoomType, RoomType), ГруппаНомеров, Ref, pIsPosted, НЕ ЗначениеЗаполнено(ГруппаНомеров),
//				                               0, NumberOfRooms, NumberOfBeds, 0, 
//				                               NumberOfBedsPerRoom, NumberOfPersonsPerRoom, Max(CurrentDate(), cm1SecondShift(DateFrom)), cm0SecondShift(DateTo), 
//				                               vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//					vHasErrors = True; 
//					pAttributeInErr = ?(pAttributeInErr = "", "ДатаНачКвоты", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(BaseRoomQuota) And SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Add Тогда
//			If НЕ cmCheckRoomQuotaAvailability(BaseRoomQuota.Agent, BaseRoomQuota.Контрагент, BaseRoomQuota.Contract, BaseRoomQuota, 
//			                                    Гостиница, RoomType, ГруппаНомеров, ThisObject.Ref, pIsPosted, True,
//												NumberOfRooms, NumberOfBeds, 
//			                                    cm1SecondShift(DateFrom), cm0SecondShift(DateTo), 
//			                                    vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//				vHasErrors = True; 
//				pAttributeInErr = ?(pAttributeInErr = "", "ДатаНачКвоты", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes

////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Автор = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate

////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill author and document date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	ExchangeRateDate = Date;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//		If НЕ ЗначениеЗаполнено(ReportingCurrency) Тогда
//			ReportingCurrency = Гостиница.ReportingCurrency;
//		EndIf;
//		ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, ExchangeRateDate);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SetRoomQuotaType) Тогда
//		SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Add;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DateFrom) Тогда
//		DateFrom = BegOfday(CurrentDate());
//		DateFrom = pmInitializeDateFrom();
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues

////-----------------------------------------------------------------------------
//// Calculates and returns duration for giving check in and check out dates
////-----------------------------------------------------------------------------
//Function pmCalculateDuration() Экспорт
//	vRoomRate = Справочники.Тарифы.EmptyRef();
//	If ЗначениеЗаполнено(Тариф) Тогда
//		vRoomRate = Тариф;
//	Else
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If ЗначениеЗаполнено(Гостиница.Тариф) Тогда
//				vRoomRate = Гостиница.Тариф;
//			EndIf;
//		EndIf;
//	EndIf;
//	Return cmCalculateDuration(vRoomRate, DateFrom, DateTo);
//EndFunction //pmCalculateDuration

////-----------------------------------------------------------------------------
//// Calculates and returns ГруппаНомеров quota end date based on giving duration and start date
////-----------------------------------------------------------------------------
//Function pmCalculateDateTo() Экспорт
//	vDateTo = DateTo;
//	If ЗначениеЗаполнено(DateFrom) And
//	   Duration > 0 Тогда
//		vRoomRate = Справочники.Тарифы.EmptyRef();
//		If ЗначениеЗаполнено(Тариф) Тогда
//			vRoomRate = Тариф;
//		Else
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				If ЗначениеЗаполнено(Гостиница.Тариф) Тогда
//					vRoomRate = Гостиница.Тариф;
//				EndIf;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(vRoomRate) Тогда
//			vRRPer = ?(vRoomRate.PeriodInHours = 0, 24, vRoomRate.PeriodInHours);
//			vRRRH = vRoomRate.ReferenceHour;
//			vDateFrom = DateFrom;
//			If vRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
//				vDateFrom = Date(Year(vDateFrom), Month(vDateFrom), Day(vDateFrom), 
//				                 Hour(vRRRH), Minute(vRRRH), 0);
//			EndIf;
//			vDateTo = vDateFrom + Duration*vRRPer*3600;
//		Else
//			vDateTo = DateFrom + Duration*24*3600;
//		EndIf;
//	EndIf;
//	Return cm0SecondShift(vDateTo);
//EndFunction //pmCalculateDateTo

////-----------------------------------------------------------------------------
//// Initialize ГруппаНомеров quota start time based on giving ГруппаНомеров rate
////-----------------------------------------------------------------------------
//Function pmInitializeDateFrom() Экспорт
//	vDateFrom = DateFrom;
//	If ЗначениеЗаполнено(vDateFrom) Тогда
//		vRoomRate = Справочники.Тарифы.EmptyRef();
//		If ЗначениеЗаполнено(Тариф) Тогда
//			vRoomRate = Тариф;
//		Else
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				If ЗначениеЗаполнено(Гостиница.Тариф) Тогда
//					vRoomRate = Гостиница.Тариф;
//				EndIf;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(vRoomRate) Тогда
//			vRRRH = vRoomRate.ReferenceHour;
//			If vRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
//				vDateFrom = Date(Year(vDateFrom), Month(vDateFrom), Day(vDateFrom), 
//				                 Hour(vRRRH), Minute(vRRRH), 0);
//			EndIf;
//		EndIf;
//	EndIf;
//	Return cm0SecondShift(vDateFrom);
//EndFunction //pmInitializeDateFrom

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
//		// Check if this document is closed by settlement
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And 
//		  (pWriteMode = DocumentWriteMode.UndoPosting Or DeletionMark) And 
//		   Price <> 0 And ЗначениеЗаполнено(ChargingFolio) And ChargingFolio.IsClosed And 
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
//				Message(NStr("en='This document is closed by settlement! You can not change this document.';ru='Документ уже закрыт актом об оказании услуг! Редактирование такого документа запрещено.';de='Das Dokument wurde bereits über ein Dienstleistungserbringungsprotokoll geschlossen! Die Bearbeitung eines solchen Dokuments ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite

////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	pmFillAttributesWithDefaultValues();
//	If TypeOf(pBase) = Type("CatalogRef.КвотаНомеров") Тогда
//		RoomQuota = pBase.Ref;
//		If ЗначениеЗаполнено(pBase.RoomRateType) Тогда
//			RoomRateType = pBase.RoomRateType; 
//		EndIf;
//		If ЗначениеЗаполнено(pBase.Тариф) Тогда
//			Тариф = pBase.Тариф; 
//		EndIf;
//		If ЗначениеЗаполнено(pBase.RoomRateServiceGroup) Тогда
//			RoomRateServiceGroup = pBase.RoomRateServiceGroup; 
//		EndIf;
//		If ЗначениеЗаполнено(pBase.Гостиница) Тогда
//			Гостиница = pBase.Гостиница;
//			Тариф = Гостиница.Тариф;
//			RoomRateServiceGroup = Гостиница.RoomRateServiceGroup;
//			If ЗначениеЗаполнено(Тариф) Тогда
//				RoomRateServiceGroup = Тариф.RoomRateServiceGroup;
//			EndIf;
//		EndIf;		
//	ElsIf TypeOf(pBase) = Type("DocumentRef.СоставКвоты") Тогда
//		FillPropertyValues(ThisObject, pBase, , "Number, Date, Автор, DeletionMark, Posted, ДокОснование");
//		ParentDoc = pBase;
//		SetRoomQuotaType = Перечисления.SetRoomQuotaTypes.Remove;
//		// Set date from to current date
//		DateFrom = cm0SecondShift(BegOfDay(CurrentDate()) + (DateFrom - BegOfDay(DateFrom)));
//		If ЗначениеЗаполнено(RoomQuota) Тогда
//			If RoomQuota.ReleaseTime <> 0 Тогда
//				DateFrom = cm0SecondShift(DateFrom + RoomQuota.ReleaseTime * 24 * 3600);
//			EndIf;
//		EndIf;
//		// Reset duration to the 1 day and recalculate date to
//		Duration = 1;
//		DateTo = pmCalculateDateTo();
//		// Calculate quota balances for the period set
//		pmGetRoomQuotaBalances();
//	EndIf;
//КонецПроцедуры //Filling

////-----------------------------------------------------------------------------
//Процедура pmGetRoomQuotaBalances() Экспорт
//	If НЕ ЗначениеЗаполнено(RoomQuota) Тогда
//		Return;
//	EndIf;
//	// Calculate quota balances for the period set
//	vResources = cmCalculateRoomQuotaResources(RoomQuota, RoomQuota.Agent, RoomQuota.Контрагент, RoomQuota.Contract, Гостиница, RoomType, ГруппаНомеров, cm1SecondShift(DateFrom), cm0SecondShift(DateTo));
//	If vResources.Count() = 1 Тогда
//		vResRow = vResources.Get(0);
//		// Set resources
//		NumberOfRooms = vResRow.ОстаетсяНомеров;
//		NumberOfBeds = vResRow.ОстаетсяМест;
//	Else
//		// Set resources to 0
//		NumberOfRooms = 0;
//		NumberOfBeds = 0;
//	EndIf;
//КонецПроцедуры //pmGetRoomQuotaBalances

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

////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If Posted Тогда
//		// Check if this document is closed by settlement
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And 
//		   Price <> 0 And ЗначениеЗаполнено(ChargingFolio) And ChargingFolio.IsClosed And 
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
//				Message(NStr("en='This document is closed by settlement! You can not change this document.';ru='Документ уже закрыт актом об оказании услуг! Редактирование такого документа запрещено.';de='Das Dokument wurde bereits über ein Dienstleistungserbringungsprotokoll geschlossen! Die Bearbeitung eines solchen Dokuments ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		UndoPosting(pCancel);
//	EndIf;
//КонецПроцедуры //BeforeDelete

////-----------------------------------------------------------------------------
//IsInFileMode = False;
