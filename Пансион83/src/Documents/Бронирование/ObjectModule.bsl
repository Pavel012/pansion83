//Перем EffectiveNumberOfRooms;
//Перем EffectiveNumberOfBeds;
//Перем EffectiveNumberOfAddBeds;
//Перем EffectiveNumberOfPersons;
//
//Перем RoomsWriteOff;
//Перем BedsWriteOff;
//Перем AdditionalBedsWriteOff;
//Перем PersonsWriteOff;
//
//Перем RoomsWithReservedStatus;
//Перем HavePermissionToDoBookingWithoutRooms;
//
//Перем StatusHasChanged;   
//
////-----------------------------------------------------------------------------
//Процедура CalculateResourcesToWriteOff(pRoomsRow)
//	If pRoomsRow <> Неопределено Тогда
//		// Calculate resources to write off for the current ГруппаНомеров
//		vPersonsPerRoom = ?(EffectiveNumberOfRooms > 0, Min(Int(EffectiveNumberOfPersons/EffectiveNumberOfRooms), ?(pRoomsRow.КоличествоМестНомер > 0, pRoomsRow.КоличествоМестНомер, 1)), 1);
//		PersonsWriteOff = Min(EffectiveNumberOfPersons, vPersonsPerRoom);
//		EffectiveNumberOfPersons = EffectiveNumberOfPersons - PersonsWriteOff;
//		EffectiveNumberOfPersons = ?(EffectiveNumberOfPersons < 0, 0, EffectiveNumberOfPersons);
//		
//		RoomsWriteOff = Min(EffectiveNumberOfRooms, 1);
//		EffectiveNumberOfRooms = EffectiveNumberOfRooms - RoomsWriteOff;
//		EffectiveNumberOfRooms = ?(EffectiveNumberOfRooms < 0, 0, EffectiveNumberOfRooms);
//		
//		BedsWriteOff = Min(EffectiveNumberOfBeds, pRoomsRow.КоличествоМестНомер);
//		EffectiveNumberOfBeds = EffectiveNumberOfBeds - BedsWriteOff;
//		EffectiveNumberOfBeds = ?(EffectiveNumberOfBeds < 0, 0, EffectiveNumberOfBeds);
//		
//		AdditionalBedsWriteOff = 0;
//	Else
//		// Calculate resources to write off
//		RoomsWriteOff = EffectiveNumberOfRooms;
//		BedsWriteOff = EffectiveNumberOfBeds;
//		AdditionalBedsWriteOff = EffectiveNumberOfAddBeds;
//		PersonsWriteOff = EffectiveNumberOfPersons;
//	EndIf;
//КонецПроцедуры //CalculateResourcesToWriteOff
//
////-----------------------------------------------------------------------------
//Процедура CalculateResourcesToWriteOffDetailed(pPeriod, pEffectiveNumberOfRoomsRow)
//	// Calculate resources to write off
//	RoomsWriteOff = pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//	BedsWriteOff = EffectiveNumberOfBeds;
//	AdditionalBedsWriteOff = EffectiveNumberOfAddBeds;
//	PersonsWriteOff = EffectiveNumberOfPersons;
//КонецПроцедуры //CalculateResourcesToWriteOffDetailed
//
////-----------------------------------------------------------------------------
//Процедура FillRIAttributes(pRIRec, pDate, pPeriod, pRoomsRow)
//	FillPropertyValues(pRIRec, ThisObject);
//	FillPropertyValues(pRIRec, pPeriod);
//	
//	pRIRec.Period = pDate;
//	pRIRec.ПериодС = pPeriod.CheckInDate;
//	pRIRec.ПериодПо = pPeriod.ДатаВыезда;
//	pRIRec.PeriodDuration = cmCalculateDuration(pPeriod.Тариф, pRIRec.ПериодС, pRIRec.ПериодПо);
//	pRIRec.CheckInAccountingDate = BegOfDay(CheckInDate);
//	pRIRec.CheckOutAccountingDate = BegOfDay(CheckOutDate);
//	pRIRec.CheckInDate = CheckInDate;
//	pRIRec.ДатаВыезда = CheckOutDate;
//	pRIRec.Продолжительность = Duration;
//	
//	If ЗначениеЗаполнено(pPeriod.Тариф) Тогда
//		pRIRec.RoomRateType = pPeriod.Тариф.RoomRateType;
//	EndIf;
//	
//	pRIRec.PricePresentation = PricePresentation;
//	
//	pRIRec.IsReservation = True;
//	
//	If pRoomsRow <> Неопределено Тогда
//		pRIRec.НомерРазмещения = pRoomsRow.НомерРазмещения;
//		pRIRec.КоличествоМестНомер = pRoomsRow.КоличествоМестНомер;
//		pRIRec.КоличествоГостейНомер = pRoomsRow.КоличествоГостейНомер;
//	EndIf;
//	
//	pRIRec.КоличествоНомеров = RoomsWriteOff;
//	pRIRec.КоличествоМест = BedsWriteOff;
//	pRIRec.КолДопМест = AdditionalBedsWriteOff;
//	pRIRec.КоличествоЧеловек = PersonsWriteOff;
//	
//	// Fill register record resources
//	pRIRec.ЗабронНомеров = RoomsWriteOff;
//	pRIRec.ЗабронированоМест = BedsWriteOff;
//	pRIRec.ЗабронДопМест = AdditionalBedsWriteOff;
//	pRIRec.ЗабронГостей = PersonsWriteOff;
//	
//	If ReservationStatus.IsGuaranteed Тогда
//		pRIRec.ГарантБроньНомеров = RoomsWriteOff;
//		pRIRec.ГарантБроньМест = BedsWriteOff;
//		pRIRec.GuaranteedAdditionalBedsReserved = AdditionalBedsWriteOff;
//		pRIRec.GuaranteedGuestsReserved = PersonsWriteOff;
//	EndIf;
//	
//	pRIRec.RoomsVacant = RoomsWriteOff;
//	pRIRec.BedsVacant = BedsWriteOff;
//	pRIRec.GuestsVacant = PersonsWriteOff;
//	
//	pRIRec.ExpectedRoomsCheckedIn = 0;
//	pRIRec.ПланЗаездМест = 0;
//	pRIRec.ПланЗаездДопМест = 0;
//	pRIRec.ExpectedGuestsCheckedIn = 0;
//	
//	pRIRec.GuaranteedExpectedRoomsCheckedIn = 0;
//	pRIRec.GuaranteedExpectedBedsCheckedIn = 0;
//	pRIRec.GuaranteedExpectedAdditionalBedsCheckedIn = 0;
//	pRIRec.GuaranteedExpectedGuestsCheckedIn = 0;
//	
//	pRIRec.ExpectedRoomsCheckedOut = 0;
//	pRIRec.ExpectedBedsCheckedOut = 0;
//	pRIRec.ExpectedAdditionalBedsCheckedOut = 0;
//	pRIRec.ExpectedGuestsCheckedOut = 0;
//	
//	If cm1SecondShift(pPeriod.CheckInDate) = cm1SecondShift(CheckInDate) And pRIRec.RecordType = AccumulationRecordType.Expense Тогда
//		pRIRec.ExpectedRoomsCheckedIn = RoomsWriteOff;
//		pRIRec.ПланЗаездМест = BedsWriteOff;
//		pRIRec.ПланЗаездДопМест = AdditionalBedsWriteOff;
//		pRIRec.ExpectedGuestsCheckedIn = PersonsWriteOff;
//		
//		If ReservationStatus.IsGuaranteed Тогда
//			pRIRec.GuaranteedExpectedRoomsCheckedIn = pRIRec.ExpectedRoomsCheckedIn;
//			pRIRec.GuaranteedExpectedBedsCheckedIn = pRIRec.ПланЗаездМест;
//			pRIRec.GuaranteedExpectedAdditionalBedsCheckedIn = pRIRec.ПланЗаездДопМест;
//			pRIRec.GuaranteedExpectedGuestsCheckedIn = pRIRec.ExpectedGuestsCheckedIn;
//		EndIf;
//	EndIf;
//	
//	If cm0SecondShift(pPeriod.ДатаВыезда) = cm0SecondShift(CheckOutDate) And pRIRec.RecordType = AccumulationRecordType.Receipt Тогда
//		pRIRec.ExpectedRoomsCheckedOut = RoomsWriteOff;
//		pRIRec.ExpectedBedsCheckedOut = BedsWriteOff;
//		pRIRec.ExpectedAdditionalBedsCheckedOut = AdditionalBedsWriteOff;
//		pRIRec.ExpectedGuestsCheckedOut = PersonsWriteOff;
//	EndIf;
//КонецПроцедуры //FillRIAttributes
//
////-----------------------------------------------------------------------------
//Процедура FillRIAttributesDetailed(pRIRec, pDate, pPeriod, pEffectiveNumberOfRoomsRow, pPrevNextEffectiveNumberOfRoomsRow)
//	FillPropertyValues(pRIRec, ThisObject);
//	FillPropertyValues(pRIRec, pPeriod);
//	
//	pRIRec.Period = pDate;
//	pRIRec.ПериодС = pPeriod.CheckInDate;
//	pRIRec.ПериодПо = pPeriod.ДатаВыезда;
//	pRIRec.PeriodDuration = cmCalculateDuration(pPeriod.Тариф, pRIRec.ПериодС, pRIRec.ПериодПо);
//	pRIRec.CheckInAccountingDate = BegOfDay(CheckInDate);
//	pRIRec.CheckOutAccountingDate = BegOfDay(CheckOutDate);
//	pRIRec.CheckInDate = CheckInDate;
//	pRIRec.ДатаВыезда = CheckOutDate;
//	pRIRec.Продолжительность = Duration;
//	
//	If ЗначениеЗаполнено(pPeriod.Тариф) Тогда
//		pRIRec.RoomRateType = pPeriod.Тариф.RoomRateType;
//	EndIf;
//	
//	pRIRec.PricePresentation = PricePresentation;
//	
//	pRIRec.IsReservation = True;
//	
//	pRIRec.КоличествоНомеров = pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//	pRIRec.КоличествоМест = BedsWriteOff;
//	pRIRec.КолДопМест = AdditionalBedsWriteOff;
//	pRIRec.КоличествоЧеловек = PersonsWriteOff;
//	
//	// Fill register record resources
//	pRIRec.ЗабронНомеров = pRIRec.КоличествоНомеров;
//	pRIRec.ЗабронированоМест = pRIRec.КоличествоМест;
//	pRIRec.ЗабронДопМест = pRIRec.КолДопМест;
//	pRIRec.ЗабронГостей = pRIRec.КоличествоЧеловек;
//	
//	If ReservationStatus.IsGuaranteed Тогда
//		pRIRec.ГарантБроньНомеров = pRIRec.КоличествоНомеров;
//		pRIRec.ГарантБроньМест = pRIRec.КоличествоМест;
//		pRIRec.GuaranteedAdditionalBedsReserved = pRIRec.КолДопМест;
//		pRIRec.GuaranteedGuestsReserved = pRIRec.КоличествоЧеловек;
//	EndIf;
//	
//	pRIRec.RoomsVacant = pRIRec.КоличествоНомеров;
//	pRIRec.BedsVacant = pRIRec.КоличествоМест;
//	pRIRec.GuestsVacant = pRIRec.КоличествоЧеловек;
//	
//	pRIRec.ExpectedRoomsCheckedIn = 0;
//	pRIRec.ПланЗаездМест = 0;
//	pRIRec.ПланЗаездДопМест = 0;
//	pRIRec.ExpectedGuestsCheckedIn = 0;
//	
//	pRIRec.GuaranteedExpectedRoomsCheckedIn = 0;
//	pRIRec.GuaranteedExpectedBedsCheckedIn = 0;
//	pRIRec.GuaranteedExpectedAdditionalBedsCheckedIn = 0;
//	pRIRec.GuaranteedExpectedGuestsCheckedIn = 0;
//	
//	pRIRec.ExpectedRoomsCheckedOut = 0;
//	pRIRec.ExpectedBedsCheckedOut = 0;
//	pRIRec.ExpectedAdditionalBedsCheckedOut = 0;
//	pRIRec.ExpectedGuestsCheckedOut = 0;
//	
//	If pRIRec.RecordType = AccumulationRecordType.Expense Тогда
//		If cm1SecondShift(pEffectiveNumberOfRoomsRow.ПериодС) = cm1SecondShift(CheckInDate) And 
//		   pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms <> 0 Тогда
//			pRIRec.ExpectedRoomsCheckedIn = pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//		ElsIf pPrevNextEffectiveNumberOfRoomsRow <> Неопределено And 
//		      pPrevNextEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0 And 
//		      pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms <> 0 Тогда
//			pRIRec.ExpectedRoomsCheckedIn = pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//		ElsIf pPrevNextEffectiveNumberOfRoomsRow <> Неопределено And 
//		      pPrevNextEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms <> 0 And 
//		      pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0 Тогда
//			pRIRec.ExpectedRoomsCheckedIn = -pPrevNextEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//		EndIf;
//		If cm1SecondShift(pEffectiveNumberOfRoomsRow.ПериодС) = cm1SecondShift(CheckInDate) Тогда
//			pRIRec.ПланЗаездМест = pRIRec.КоличествоМест;
//			pRIRec.ПланЗаездДопМест = pRIRec.КолДопМест;
//			pRIRec.ExpectedGuestsCheckedIn = pRIRec.КоличествоЧеловек;
//		EndIf;
//		
//		If ReservationStatus.IsGuaranteed Тогда
//			pRIRec.GuaranteedExpectedRoomsCheckedIn = pRIRec.ExpectedRoomsCheckedIn;
//			pRIRec.GuaranteedExpectedBedsCheckedIn = pRIRec.ПланЗаездМест;
//			pRIRec.GuaranteedExpectedAdditionalBedsCheckedIn = pRIRec.ПланЗаездДопМест;
//			pRIRec.GuaranteedExpectedGuestsCheckedIn = pRIRec.ExpectedGuestsCheckedIn;
//		EndIf;
//	Else
//		If cm0SecondShift(pEffectiveNumberOfRoomsRow.ПериодПо) = cm0SecondShift(CheckOutDate) And
//		   pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms <> 0 Тогда
//			pRIRec.ExpectedRoomsCheckedOut = pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//		ElsIf pPrevNextEffectiveNumberOfRoomsRow <> Неопределено And 
//		      pPrevNextEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0 And 
//		      pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms <> 0 Тогда
//			pRIRec.ExpectedRoomsCheckedOut = pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//		ElsIf pPrevNextEffectiveNumberOfRoomsRow <> Неопределено And 
//		      pPrevNextEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms <> 0 And 
//		      pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0 Тогда
//			pRIRec.ExpectedRoomsCheckedOut = -pPrevNextEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//		EndIf;
//		If cm0SecondShift(pEffectiveNumberOfRoomsRow.ПериодПо) = cm0SecondShift(CheckOutDate) Тогда
//			pRIRec.ExpectedBedsCheckedOut = pRIRec.КоличествоМест;
//			pRIRec.ExpectedAdditionalBedsCheckedOut = pRIRec.КолДопМест;
//			pRIRec.ExpectedGuestsCheckedOut = pRIRec.КоличествоЧеловек;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillRIAttributesDetailed
//
////-----------------------------------------------------------------------------
//Процедура WriteRoomInitializationRecord(pInitRecordDate, pHotel, pRoomType)
//	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//	
//	vRIRec.Period = pInitRecordDate;
//	vRIRec.Гостиница = pHotel;
//	vRIRec.ТипНомера = pRoomType;
//	vRIRec.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//	
//	vRIRec.ВсегоНомеров = 0;
//	vRIRec.ВсегоМест = 0;
//	vRIRec.ВсегоГостей = 0;
//	vRIRec.RoomsVacant = 0;
//	vRIRec.BedsVacant = 0;
//	vRIRec.GuestsVacant = 0;
//	
//	vRIRec.СчетчикДокКвота = 1;
//	
//	vRIRec.ДокОснование = Ref;
//	vRIRec.КоличествоМестНомер = 0;
//	vRIRec.КоличествоГостейНомер = 0;
//	vRIRec.Примечания = "";
//	vRIRec.Автор = Справочники.Сотрудники.EmptyRef();
//	vRIRec.IsRoomInventory = False;
//КонецПроцедуры //WriteRoomInitializationRecords
//
////-----------------------------------------------------------------------------
//Процедура PostToRoomInventory(pCancel, pPeriod, pRoomsRow = Неопределено)
//	// Write ГруппаНомеров inventory initialization record if necessary
//	vRH = cmGetReferenceHour(pPeriod.Тариф);
//	vRHInSeconds = vRH - BegOfDay(vRH);
//	If vRHInSeconds > 0 Тогда
//		If (pPeriod.CheckInDate - BegOfDay(pPeriod.CheckInDate) - 1) < vRHInSeconds Тогда
//			WriteRoomInitializationRecord(BegOfDay(pPeriod.CheckInDate) + vRHInSeconds + 1, pPeriod.Гостиница, pPeriod.ТипНомера);
//		EndIf;
//		If (pPeriod.ДатаВыезда - BegOfDay(pPeriod.ДатаВыезда)) > vRHInSeconds Тогда
//			WriteRoomInitializationRecord(BegOfDay(pPeriod.ДатаВыезда) + vRHInSeconds + 1, pPeriod.Гостиница, pPeriod.ТипНомера);
//		EndIf;
//	EndIf;
//	
//	// Calculate resources to write off from the ГруппаНомеров inventory for the giving period
//	CalculateResourcesToWriteOff(pRoomsRow);
//	
//	If PersonsWriteOff = 0 And
//	   RoomsWriteOff = 0 And
//	   BedsWriteOff = 0 And
//	   AdditionalBedsWriteOff = 0 Тогда
//		Return;
//	EndIf;
//	
//	// Do expense movement on check in date
//	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
//	FillRIAttributes(vRIRec, pPeriod.CheckInDate, pPeriod, pRoomsRow);
//		
//	// Do receipt movement on check out date
//	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//	FillRIAttributes(vRIRec, pPeriod.ДатаВыезда, pPeriod, pRoomsRow);
//	
//	// Write RegisterRecords	
//	RegisterRecords.ЗагрузкаНомеров.Write();
//	
//	// Change ГруппаНомеров status
//	If ЗначениеЗаполнено(Гостиница.ReservedRoomStatus) And 
//	   ReservationStatus.DoRoomStatusChange And 
//	   pPeriod.CheckInDate = CheckInDate Тогда
//		vRoom = Неопределено;
//		If pRoomsRow <> Неопределено Тогда
//			vRoom = pRoomsRow.НомерРазмещения;
//		Else
//			vRoom = pPeriod.НомерРазмещения;
//		EndIf;
//		If ЗначениеЗаполнено(vRoom) Тогда	   
//			If vRoom.СтатусНомера <> Гостиница.ReservedRoomStatus Тогда
//				If RoomsWithReservedStatus.FindByValue(vRoom) = Неопределено Тогда
//					RoomsWithReservedStatus.Add(vRoom);
//					DoChangeRoomStatus(Гостиница.ReservedRoomStatus, vRoom);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //PostToRoomInventory
//
////-----------------------------------------------------------------------------
//Процедура PostToRoomInventoryDetailed(pCancel, pPeriod, pEffectiveNumberOfRoomsRow, pPrevEffectiveNumberOfRoomsRow, pNextEffectiveNumberOfRoomsRow)
//	// Write ГруппаНомеров inventory initialization record if necessary
//	vRH = cmGetReferenceHour(pPeriod.Тариф);
//	vRHInSeconds = vRH - BegOfDay(vRH);
//	If vRHInSeconds > 0 Тогда
//		If (pPeriod.CheckInDate - BegOfDay(pPeriod.CheckInDate) - 1) < vRHInSeconds Тогда
//			WriteRoomInitializationRecord(BegOfDay(pPeriod.CheckInDate) + vRHInSeconds + 1, pPeriod.Гостиница, pPeriod.ТипНомера);
//		EndIf;
//		If (pPeriod.ДатаВыезда - BegOfDay(pPeriod.ДатаВыезда)) > vRHInSeconds Тогда
//			WriteRoomInitializationRecord(BegOfDay(pPeriod.ДатаВыезда) + vRHInSeconds + 1, pPeriod.Гостиница, pPeriod.ТипНомера);
//		EndIf;
//	EndIf;
//	
//	// Calculate resources to write off from the ГруппаНомеров inventory for the giving period
//	CalculateResourcesToWriteOffDetailed(pPeriod, pEffectiveNumberOfRoomsRow);
//	
//	If PersonsWriteOff = 0 And
//	   RoomsWriteOff = 0 And
//	   BedsWriteOff = 0 And
//	   AdditionalBedsWriteOff = 0 Тогда
//		Return;
//	EndIf;
//	
//	// Do expense movement on check in date
//	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
//	FillRIAttributesDetailed(vRIRec, pEffectiveNumberOfRoomsRow.ПериодС, pPeriod, pEffectiveNumberOfRoomsRow, pPrevEffectiveNumberOfRoomsRow);
//		
//	// Do receipt movement on check out date
//	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//	FillRIAttributesDetailed(vRIRec, pEffectiveNumberOfRoomsRow.ПериодПо, pPeriod, pEffectiveNumberOfRoomsRow, pNextEffectiveNumberOfRoomsRow);
//	
//	// Write RegisterRecords	
//	RegisterRecords.ЗагрузкаНомеров.Write();
//	
//	// Change ГруппаНомеров status
//	If ЗначениеЗаполнено(Гостиница.ReservedRoomStatus) And 
//	   ReservationStatus.DoRoomStatusChange And 
//	   pPeriod.CheckInDate = CheckInDate Тогда
//		vRoom = pPeriod.НомерРазмещения;
//		If ЗначениеЗаполнено(vRoom) Тогда	   
//			If vRoom.СтатусНомера <> Гостиница.ReservedRoomStatus Тогда
//				If RoomsWithReservedStatus.FindByValue(vRoom) = Неопределено Тогда
//					RoomsWithReservedStatus.Add(vRoom);
//					DoChangeRoomStatus(Гостиница.ReservedRoomStatus, vRoom);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //PostToRoomInventoryDetailed
//
////-----------------------------------------------------------------------------
//Процедура PostToWaitingList(pCancel)
//	// Clear register records
//	RegisterRecords.ОжиданиеБрони.Clear();
//	
//	// Do movement on document date
//	If ReservationStatus.IsInWaitingList Тогда
//		vWLRec = RegisterRecords.ОжиданиеБрони.Add();
//		
//		vWLRec.Period = Date;
//		vWLRec.Reservation = Ref;
//		vWLRec.Rating = Rating;
//	EndIf;
//			
//	// Write movements
//	RegisterRecords.ОжиданиеБрони.Write();
//КонецПроцедуры //PostToWaitingList
//
////-----------------------------------------------------------------------------
//Процедура PostToExpectedGuestGroups(pCancel)
//	// Clear register records
//	RegisterRecords.ПланируемыеГруппы.Clear();
//	
//	// Do movements for each day from the reservation period
//	If ReservationStatus.IsPreliminary Тогда
//		vEndOfDay = EndOfDay(CheckInDate);
//		While vEndOfDay <= CheckOutDate Do
//			vEGGRec = RegisterRecords.ПланируемыеГруппы.Add();
//			
//			FillPropertyValues(vEGGRec, ThisObject);
//			
//			vEGGRec.Period = vEndOfDay;
//			vEGGRec.Recorder = Ref;
//			
//			// Resources
//			vEGGRec.ЗабронНомеров = ?(NumberOfRooms <> 0, NumberOfRooms, ?(NumberOfBedsPerRoom <> 0, NumberOfBeds/NumberOfBedsPerRoom, 0));
//			vEGGRec.ЗабронированоМест = NumberOfBeds;
//			vEGGRec.ЗабронДопМест = NumberOfAdditionalBeds;
//			vEGGRec.ЗабронГостей = NumberOfPersons;
//			
//			// Next date
//			vEndOfDay = vEndOfDay + 24*3600;
//		EndDo;
//	EndIf;
//			
//	// Write movements
//	RegisterRecords.ПланируемыеГруппы.Write();
//КонецПроцедуры //PostToExpectedGuestGroups
//
////-----------------------------------------------------------------------------
//Процедура FillRQAttributes(pRQRec, pDate, pPeriod, pRoomsRow)
//	FillPropertyValues(pRQRec, ThisObject);
//	FillPropertyValues(pRQRec, pPeriod);
//	
//	If ЗначениеЗаполнено(RoomTypeUpgrade) And ЗначениеЗаполнено(RoomTypeUpgrade.BaseRoomType) And RoomTypeUpgrade.BaseRoomType = pPeriod.ТипНомера Тогда
//		pRQRec.ТипНомера = RoomTypeUpgrade;
//	EndIf;
//
//	pRQRec.Period = pDate;
//	
//	If ЗначениеЗаполнено(pPeriod.Тариф) Тогда
//		pRQRec.RoomRateType = pPeriod.Тариф.RoomRateType;
//	EndIf;
//	
//	pRQRec.ЗабронНомеров = RoomsWriteOff;
//	pRQRec.ЗабронированоМест = BedsWriteOff;
//	pRQRec.ОстаетсяНомеров = RoomsWriteOff;
//	pRQRec.ОстаетсяМест = BedsWriteOff;
//	
//	If ReservationStatus.IsGuaranteed Тогда
//		pRQRec.ГарантБроньНомеров = RoomsWriteOff;
//		pRQRec.ГарантБроньМест = BedsWriteOff;
//	EndIf;
//	
//	pRQRec.ДатаНачКвоты = pPeriod.CheckInDate;
//	pRQRec.ДатаКонКвоты = pPeriod.ДатаВыезда;
//	pRQRec.Продолжительность = cmCalculateDuration(pPeriod.Тариф, pPeriod.CheckInDate, pPeriod.ДатаВыезда);
//	
//	If pRoomsRow <> Неопределено Тогда
//		pRQRec.НомерРазмещения = pRoomsRow.НомерРазмещения;
//	EndIf;
//	
//	If НЕ RoomQuota.IsQuotaForRooms Тогда
//		pRQRec.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//	EndIf;
//	
//	pRQRec.IsReservation = True;
//КонецПроцедуры //FillRQAttributes
//
////-----------------------------------------------------------------------------
//Процедура FillRQAttributesDetailed(pRQRec, pDate, pPeriod, pPeriodFrom, pPeriodTo, pEffectiveNumberOfRooms)
//	FillPropertyValues(pRQRec, ThisObject);
//	FillPropertyValues(pRQRec, pPeriod);
//	
//	If ЗначениеЗаполнено(RoomTypeUpgrade) And ЗначениеЗаполнено(RoomTypeUpgrade.BaseRoomType) And RoomTypeUpgrade.BaseRoomType = pPeriod.ТипНомера Тогда
//		pRQRec.ТипНомера = RoomTypeUpgrade;
//	EndIf;
//
//	pRQRec.Period = pDate;
//	
//	If ЗначениеЗаполнено(pPeriod.Тариф) Тогда
//		pRQRec.RoomRateType = pPeriod.Тариф.RoomRateType;
//	EndIf;
//	
//	pRQRec.ЗабронНомеров = pEffectiveNumberOfRooms;
//	pRQRec.ЗабронированоМест = BedsWriteOff;
//	pRQRec.ОстаетсяНомеров = pEffectiveNumberOfRooms;
//	pRQRec.ОстаетсяМест = BedsWriteOff;
//	
//	If ReservationStatus.IsGuaranteed Тогда
//		pRQRec.ГарантБроньНомеров = pEffectiveNumberOfRooms;
//		pRQRec.ГарантБроньМест = BedsWriteOff;
//	EndIf;
//	
//	pRQRec.ДатаНачКвоты = pPeriodFrom;
//	pRQRec.ДатаКонКвоты = pPeriodTo;
//	pRQRec.Продолжительность = cmCalculateDuration(pPeriod.Тариф, pPeriodFrom, pPeriodTo);
//	
//	If НЕ RoomQuota.IsQuotaForRooms Тогда
//		pRQRec.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//	EndIf;
//	
//	pRQRec.IsReservation = True;
//КонецПроцедуры //FillRQAttributesDetailed
//
////-----------------------------------------------------------------------------
//Процедура FillRQRIAttributes(pRIRec, pDate, pDateFrom, pDateTo, pPeriod, pRoomsRow, pRoomsToWriteOff, pBedsToWriteOff)
//	FillPropertyValues(pRIRec, ThisObject);
//	FillPropertyValues(pRIRec, pPeriod);
//	
//	pRIRec.Period = pDate;
//	pRIRec.ПериодС = pPeriod.CheckInDate;
//	pRIRec.ПериодПо = pPeriod.ДатаВыезда;
//	pRIRec.PeriodDuration = cmCalculateDuration(pPeriod.Тариф, pRIRec.ПериодС, pRIRec.ПериодПо);
//	pRIRec.CheckInAccountingDate = BegOfDay(CheckInDate);
//	pRIRec.CheckOutAccountingDate = BegOfDay(CheckOutDate);
//	pRIRec.CheckInDate = CheckInDate;
//	pRIRec.ДатаВыезда = CheckOutDate;
//	pRIRec.Продолжительность = Duration;
//	
//	If ЗначениеЗаполнено(pPeriod.Тариф) Тогда
//		pRIRec.RoomRateType = pPeriod.Тариф.RoomRateType;
//	EndIf;
//	
//	pRIRec.PricePresentation = PricePresentation;
//	
//	pRIRec.IsRoomQuota = True;
//	
//	If pRoomsRow <> Неопределено Тогда
//		pRIRec.НомерРазмещения = pRoomsRow.НомерРазмещения;
//		pRIRec.КоличествоМестНомер = pRoomsRow.КоличествоМестНомер;
//		pRIRec.КоличествоГостейНомер = pRoomsRow.КоличествоГостейНомер;
//	EndIf;
//	
//	If НЕ RoomQuota.IsQuotaForRooms Тогда
//		pRIRec.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//	EndIf;
//	
//	pRIRec.КоличествоНомеров = pRoomsToWriteOff;
//	pRIRec.КоличествоМест = pBedsToWriteOff;
//	
//	// Fill register record resources
//	pRIRec.НомеровКвота = -pRoomsToWriteOff;
//	pRIRec.МестКвота = -pBedsToWriteOff;
//	pRIRec.RoomsVacant = -pRoomsToWriteOff;
//	pRIRec.BedsVacant = -pBedsToWriteOff;
//КонецПроцедуры //FillRQRIAttributes
//
////-----------------------------------------------------------------------------
//Процедура PostToRoomQuotaSales(pCancel, pPeriod, pRoomsRow = Неопределено)
//	If PersonsWriteOff = 0 And
//	   RoomsWriteOff = 0 And
//	   BedsWriteOff = 0 And
//	   AdditionalBedsWriteOff = 0 Тогда
//		Return;
//	EndIf;
//	
//	If BegOfDay(pPeriod.CheckInDate) <> BegOfDay(pPeriod.ДатаВыезда) Тогда
//		vEffectiveCheckInDate = cmMovePeriodFromToReferenceHour(pPeriod.CheckInDate, pPeriod.Тариф);
//		vEffectiveCheckOutDate = cmMovePeriodToToReferenceHour(pPeriod.ДатаВыезда, pPeriod.Тариф);
//	Else
//		vEffectiveCheckInDate = pPeriod.CheckInDate;
//		vEffectiveCheckOutDate = pPeriod.ДатаВыезда;
//	EndIf;
//	
//	// Do storno movements for ГруппаНомеров inventory
//	If RoomQuota.DoWriteOff And vEffectiveCheckInDate < vEffectiveCheckOutDate Тогда
//		If RoomsWriteOff > 0 Or
//		   BedsWriteOff > 0 Тогда
//			// Do expense movement on check in date
//			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
//			FillRQRIAttributes(vRIRec, vEffectiveCheckInDate, vEffectiveCheckInDate, vEffectiveCheckOutDate, pPeriod, pRoomsRow, RoomsWriteOff, BedsWriteOff);
//				
//			// Do receipt movement on check out date
//			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//			FillRQRIAttributes(vRIRec, vEffectiveCheckOutDate, vEffectiveCheckInDate, vEffectiveCheckOutDate, pPeriod, pRoomsRow, RoomsWriteOff, BedsWriteOff);
//					
//			// Write RegisterRecords	
//			RegisterRecords.ЗагрузкаНомеров.Write();
//		EndIf;
//	EndIf;
//
//	// Do expense movement on check in date moved to reference hour
//	If vEffectiveCheckInDate < vEffectiveCheckOutDate And 
//	   BegOfDay(pPeriod.CheckInDate) <> BegOfDay(pPeriod.ДатаВыезда) Тогда
//		vRQRec = RegisterRecords.ПродажиКвот.AddExpense();
//		FillRQAttributes(vRQRec, vEffectiveCheckInDate, pPeriod, pRoomsRow);
//			
//		// Do receipt movement on check out date moved to reference hour
//		vRQRec = RegisterRecords.ПродажиКвот.AddReceipt();
//		FillRQAttributes(vRQRec, vEffectiveCheckOutDate, pPeriod, pRoomsRow);
//			
//		// Write RegisterRecords	
//		RegisterRecords.ПродажиКвот.Write();
//	EndIf;
//КонецПроцедуры //PostToRoomQuotaSales
//
////-----------------------------------------------------------------------------
//Процедура PostToRoomQuotaSalesDetailed(pCancel, pPeriod, pEffectiveNumberOfRoomsRow)
//	// Allotment effective period
//	If BegOfDay(pEffectiveNumberOfRoomsRow.ПериодС) <> BegOfDay(pEffectiveNumberOfRoomsRow.ПериодПо) Тогда
//		vEffectiveCheckInDate = cmMovePeriodFromToReferenceHour(pEffectiveNumberOfRoomsRow.ПериодС, pPeriod.Тариф);
//		vEffectiveCheckOutDate = cmMovePeriodToToReferenceHour(pEffectiveNumberOfRoomsRow.ПериодПо, pPeriod.Тариф);
//	Else
//		vEffectiveCheckInDate = pEffectiveNumberOfRoomsRow.ПериодС;
//		vEffectiveCheckOutDate = pEffectiveNumberOfRoomsRow.ПериодПо;
//	EndIf;
//	
//	// Do storno movements for ГруппаНомеров inventory
//	If pPeriod.КвотаНомеров.DoWriteOff And vEffectiveCheckInDate < vEffectiveCheckOutDate Тогда
//		vRoomsToWriteOff = pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms;
//		vBedsToWriteOff = BedsWriteOff;
//		If vRoomsToWriteOff > 0 Or
//		   vBedsToWriteOff > 0 Тогда
//			// Do expense movement on check in date
//			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
//			FillRQRIAttributes(vRIRec, vEffectiveCheckInDate, vEffectiveCheckInDate, vEffectiveCheckOutDate, pPeriod, Неопределено, vRoomsToWriteOff, vBedsToWriteOff);
//				
//			// Do receipt movement on check out date
//			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//			FillRQRIAttributes(vRIRec, vEffectiveCheckOutDate, vEffectiveCheckInDate, vEffectiveCheckOutDate, pPeriod, Неопределено, vRoomsToWriteOff, vBedsToWriteOff);
//					
//			// Write RegisterRecords	
//			RegisterRecords.ЗагрузкаНомеров.Write();
//		EndIf;
//	EndIf;
//
//	// Do expense movement on check in date moved to reference hour
//	If vEffectiveCheckInDate < vEffectiveCheckOutDate And 
//	   BegOfDay(pEffectiveNumberOfRoomsRow.ПериодС) <> BegOfDay(pEffectiveNumberOfRoomsRow.ПериодПо) Тогда
//		vRQRec = RegisterRecords.ПродажиКвот.AddExpense();
//		FillRQAttributesDetailed(vRQRec, vEffectiveCheckInDate, pPeriod, pEffectiveNumberOfRoomsRow.ПериодС, pEffectiveNumberOfRoomsRow.ПериодПо, pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms);
//			
//		// Do receipt movement on check out date moved to reference hour
//		vRQRec = RegisterRecords.ПродажиКвот.AddReceipt();
//		FillRQAttributesDetailed(vRQRec, vEffectiveCheckOutDate, pPeriod, pEffectiveNumberOfRoomsRow.ПериодС, pEffectiveNumberOfRoomsRow.ПериодПо, pEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms);
//			
//		// Write RegisterRecords	
//		RegisterRecords.ПродажиКвот.Write();
//	EndIf;
//КонецПроцедуры //PostToRoomQuotaSalesDetailed
//
////-----------------------------------------------------------------------------
//Процедура FillSFAttributes(pSFRec, pSrvRec, pDate, pRoomsRow)
//	FillPropertyValues(pSFRec, ThisObject);
//	FillPropertyValues(pSFRec, pSrvRec);
//	
//	// Fill Контрагент, contract and payment method from the folio
//	If ЗначениеЗаполнено(pSrvRec.СчетПроживания) Тогда
//		pSFRec.Контрагент = pSrvRec.СчетПроживания.Контрагент;
//		pSFRec.Договор = pSrvRec.СчетПроживания.Договор;
//		pSFRec.Агент = pSrvRec.СчетПроживания.Агент;
//		pSFRec.ГруппаГостей = pSrvRec.СчетПроживания.ГруппаГостей;
//		pSFRec.СпособОплаты = pSrvRec.СчетПроживания.СпособОплаты;
//	EndIf;
//	
//	// Fill hotel product
//	If ЗначениеЗаполнено(pSFRec.Услуга) And pSFRec.Услуга.IsHotelProductService Тогда
//		If ЗначениеЗаполнено(pSFRec.СчетПроживания.ПутевкаКурсовка) Тогда
//			pSFRec.ПутевкаКурсовка = pSFRec.СчетПроживания.ПутевкаКурсовка;
//		Else
//			pSFRec.ПутевкаКурсовка = pSFRec.ПутевкаКурсовка;
//		EndIf;
//	Else
//		pSFRec.ПутевкаКурсовка = Справочники.ПутевкиКурсовки.EmptyRef();
//	EndIf;
//	
//	// Fill client
//	pSFRec.Клиент = Гость;
//	
//	// Fill accomodation parameters
//	If НЕ ЗначениеЗаполнено(pSrvRec.Тариф) Тогда
//		pSFRec.Тариф = Тариф;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.ВидРазмещения) Тогда
//		pSFRec.ВидРазмещения = AccommodationType;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.ТипНомера) Тогда
//		pSFRec.ТипНомера = RoomType;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.НомерРазмещения) Тогда
//		pSFRec.НомерРазмещения = ГруппаНомеров;
//	EndIf;
//	pSFRec.ТипРесурса = Справочники.ТипыРесурсов.EmptyRef();
//	If ЗначениеЗаполнено(pSrvRec.ServiceResource) And TypeOf(pSrvRec.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//		pSFRec.Ресурс = pSrvRec.ServiceResource;
//		pSFRec.ТипРесурса = pSFRec.Ресурс.Owner;
//	EndIf;
//	
//	pSFRec.Period = pDate;
//	pSFRec.ДокОснование = Ref;
//	
//	If pRoomsRow <> Неопределено Тогда
//		pSFRec.НомерРазмещения = pRoomsRow.НомерРазмещения;
//		pSFRec.КоличествоМестНомер = pRoomsRow.КоличествоМестНомер;
//		pSFRec.КоличествоГостейНомер = pRoomsRow.КоличествоГостейНомер;
//	EndIf;
//	
//	pSFRec.КоличествоНомеров = RoomsWriteOff;
//	pSFRec.КоличествоМест = BedsWriteOff;
//	pSFRec.КолДопМест = AdditionalBedsWriteOff;
//	pSFRec.КоличествоЧеловек = PersonsWriteOff;
//	
//	// Calculate write off coefficient
//	vWriteOffCoeff = 1;
//	If NumberOfPersons > 0 Тогда
//		vWriteOffCoeff = PersonsWriteOff / NumberOfPersons;
//	EndIf;
//	
//	// Recalculate forecast resources according to the write off coefficient
//	vSrvRec = New Structure("Цена, Количество, Сумма, СтавкаНДС, СуммаНДС, СуммаСкидки, НДСскидка, СуммаКомиссии, VATCommissionSum, ПроданоНомеров, ПроданоМест, ПроданоДопМест, ЧеловекаДни, ЗаездГостей, СуммаТарифаПрож", 
//	                        pSrvRec.Цена, pSrvRec.Количество, pSrvRec.Сумма, pSrvRec.СтавкаНДС, pSrvRec.СуммаНДС, pSrvRec.СуммаСкидки, pSrvRec.НДСскидка, pSrvRec.СуммаКомиссии, pSrvRec.СуммаКомиссииНДС, pSrvRec.ПроданоНомеров, pSrvRec.ПроданоМест, pSrvRec.ПроданоДопМест, pSrvRec.ЧеловекаДни, pSrvRec.ЗаездГостей, pSrvRec.СуммаТарифаПрож);
//	If vWriteOffCoeff <> 1 Тогда
//		vSrvRec.Quantity = Round(vWriteOffCoeff * vSrvRec.Quantity, 7);
//		vSrvRec.Sum = Round(vSrvRec.Price * vSrvRec.Quantity, 2);
//		vSrvRec.VATSum = cmCalculateVATSum(vSrvRec.VATRate, vSrvRec.Sum);
//		vSrvRec.DiscountSum = Round(vWriteOffCoeff * vSrvRec.DiscountSum, 2);
//		vSrvRec.VATDiscountSum = Round(vWriteOffCoeff * vSrvRec.VATDiscountSum, 2);
//		vSrvRec.CommissionSum = Round(vWriteOffCoeff * vSrvRec.CommissionSum, 2);
//		vSrvRec.VATCommissionSum = Round(vWriteOffCoeff * vSrvRec.VATCommissionSum, 2);
//		vSrvRec.RoomsRented = Round(vWriteOffCoeff * vSrvRec.RoomsRented, 7);
//		vSrvRec.BedsRented = Round(vWriteOffCoeff * vSrvRec.BedsRented, 7);
//		vSrvRec.AdditionalBedsRented = Round(vWriteOffCoeff * vSrvRec.AdditionalBedsRented, 7);
//		vSrvRec.GuestDays = Round(vWriteOffCoeff * vSrvRec.GuestDays, 7);
//		vSrvRec.GuestsCheckedIn = Round(vWriteOffCoeff * vSrvRec.GuestsCheckedIn, 7);
//		If pSrvRec.Количество <> 0 Тогда
//			vSrvRec.RateSum = Round(vSrvRec.RateSum / pSrvRec.Количество * vSrvRec.Quantity, 2);
//		EndIf;
//	EndIf;	
//	
//	vSumInFolioCurrency = vSrvRec.Sum - vSrvRec.DiscountSum;
//	vSumInReportingCurrency = Round(cmConvertCurrencies(vSumInFolioCurrency, pSrvRec.ВалютаЛицСчета, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	vVATSumInReportingCurrency = Round(cmConvertCurrencies(vSrvRec.VATSum - vSrvRec.VATDiscountSum, pSrvRec.ВалютаЛицСчета, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	vRateSumInReportingCurrency = Round(cmConvertCurrencies(vSrvRec.RateSum, pSrvRec.ВалютаЛицСчета, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	
//	pSFRec.Продажи = vSumInReportingCurrency;
//	pSFRec.ПродажиБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	pSFRec.СуммаНДС = vVATSumInReportingCurrency;
//	If pSrvRec.IsRoomRevenue Тогда
//		pSFRec.ДоходНомеров = vSumInReportingCurrency;
//		pSFRec.ДоходПродажиБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	EndIf;
//	If vSrvRec.AdditionalBedsRented <> 0 Тогда
//		pSFRec.ДоходДопМеста = vSumInReportingCurrency;
//		pSFRec.ДоходДопМестаБезНДС = vSumInReportingCurrency - vVATSumInReportingCurrency;
//	EndIf;
//	pSFRec.Цена = cmRecalculatePrice(vSumInReportingCurrency, vSrvRec.Quantity);
//	pSFRec.Количество = vSrvRec.Quantity;
//	pSFRec.ДоходРес = 0;
//	pSFRec.ДоходРесБезНДС = 0;
//	pSFRec.ПроданоЧасовРесурса = 0;
//	
//	vCommissionSumInReportingCurrency = Round(cmConvertCurrencies(vSrvRec.CommissionSum, pSrvRec.ВалютаЛицСчета, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	vVATCommissionSumInReportingCurrency = Round(cmConvertCurrencies(vSrvRec.VATCommissionSum, pSrvRec.ВалютаЛицСчета, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	pSFRec.СуммаКомиссии = vCommissionSumInReportingCurrency;
//	pSFRec.КомиссияБезНДС = vCommissionSumInReportingCurrency - vVATCommissionSumInReportingCurrency;
//	
//	vDiscountSumInReportingCurrency = Round(cmConvertCurrencies(vSrvRec.DiscountSum, pSrvRec.ВалютаЛицСчета, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	vVATDiscountSumInReportingCurrency = Round(cmConvertCurrencies(vSrvRec.VATDiscountSum, pSrvRec.ВалютаЛицСчета, , ReportingCurrency, , ?(ЗначениеЗаполнено(pSrvRec.УчетнаяДата), pSrvRec.УчетнаяДата, ExchangeRateDate), Гостиница), 2);
//	pSFRec.СуммаСкидки = vDiscountSumInReportingCurrency;
//	pSFRec.СуммаСкидкиБезНДС = vDiscountSumInReportingCurrency - vVATDiscountSumInReportingCurrency;
//	
//	pSFRec.ПроданоНомеров = vSrvRec.RoomsRented;
//	pSFRec.ПроданоМест = vSrvRec.BedsRented;
//	pSFRec.ПроданоДопМест = vSrvRec.AdditionalBedsRented;
//	pSFRec.ЧеловекаДни = vSrvRec.GuestDays;
//	pSFRec.ЗаездГостей = vSrvRec.GuestsCheckedIn;
//	
//	// Fill check-in resources
//	If pSFRec.ЗаездГостей <> 0 And pSFRec.Количество <> 0 Тогда
//		pSFRec.ЗаездНомеров = ?(pSFRec.ПроданоНомеров < 0, -1, 1) * pSFRec.ПроданоНомеров/pSFRec.Количество * Round(vWriteOffCoeff * RoomQuantity, 7);
//		pSFRec.ЗаездМест = ?(pSFRec.ПроданоМест < 0, -1, 1) * pSFRec.ПроданоМест/pSFRec.Количество * Round(vWriteOffCoeff * RoomQuantity, 7);
//		pSFRec.ЗаездДополнительныхМест = ?(pSFRec.ПроданоДопМест < 0, -1, 1) * pSFRec.ПроданоДопМест/pSFRec.Количество * Round(vWriteOffCoeff * RoomQuantity, 7);
//	Else
//		pSFRec.ЗаездНомеров = 0;
//		pSFRec.ЗаездМест = 0;
//		pSFRec.ЗаездДополнительныхМест = 0;
//	EndIf;
//	
//	If НЕ pSrvRec.IsManual And vRateSumInReportingCurrency <> 0 Тогда
//		pSFRec.СуммаТарифаПрож = vRateSumInReportingCurrency;
//		pSFRec.РазницаТарифИНачСуммой = vSumInReportingCurrency - vRateSumInReportingCurrency;
//	EndIf;
//		
//	// Write to the hotel product log
//	If ЗначениеЗаполнено(pSFRec.ПутевкаКурсовка) Тогда
//		vHPLRec = RegisterRecords.РеестрПутевокКурсовок.AddReceipt();
//		vHPLRec.Period = ?(ЗначениеЗаполнено(pSFRec.ПутевкаКурсовка.CreateDate), pSFRec.ПутевкаКурсовка.CreateDate, pDate);
//		vHPLRec.ВалютаЛицСчета = pSrvRec.ВалютаЛицСчета;
//		vHPLRec.Гостиница = Гостиница;
//		vHPLRec.ПутевкаКурсовка = pSFRec.ПутевкаКурсовка;
//		vHPLRec.Сумма = vSumInFolioCurrency;
//	EndIf;
//	
//	// Check if Контрагент and agent are the same
//	If ЗначениеЗаполнено(pSrvRec.СчетПроживания) Тогда
//		vDoNotPostCommission = False;
//		If ЗначениеЗаполнено(pSrvRec.СчетПроживания.Агент) And pSrvRec.СчетПроживания.Агент.DoNotPostCommission Тогда
//			vDoNotPostCommission = True;
//		EndIf;
//		If НЕ vDoNotPostCommission Тогда
//			If ЗначениеЗаполнено(pSrvRec.СчетПроживания.Агент) And 
//			   pSrvRec.СчетПроживания.Агент <> pSrvRec.СчетПроживания.Контрагент And 
//			   vCommissionSumInReportingCurrency <> 0 Тогда
//				pSFRec.СуммаКомиссии = 0;
//				pSFRec.КомиссияБезНДС = 0;
//			
//				// Add new record
//				vSFRec = RegisterRecords.ПрогнозПродаж.Add();
//				FillPropertyValues(vSFRec, pSFRec, , "RecordType");
//				
//				// Fill dimensions
//				vSFRec.Контрагент = pSrvRec.СчетПроживания.Агент;
//				vSFRec.Договор = pSrvRec.СчетПроживания.Агент.AgentCommissionContract;
//				vSFRec.Агент = pSrvRec.СчетПроживания.Агент;
//				vSFRec.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//				
//				// Reset resources
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
//				
//				vSFRec.СуммаТарифаПрож = 0;
//				vSFRec.РазницаТарифИНачСуммой = 0;
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
//Процедура FillARFAttributes(pARFRec, pSrvRec, pDate, pRoomsRow)
//	FillPropertyValues(pARFRec, ThisObject);
//	FillPropertyValues(pARFRec, pSrvRec);
//	
//	pARFRec.Period = pDate;
//	pARFRec.ДокОснование = Ref;
//	
//	// Fill client
//	pARFRec.Клиент = Гость;
//	
//	// Fill accommodation parameters
//	If НЕ ЗначениеЗаполнено(pSrvRec.Тариф) Тогда
//		pARFRec.Тариф = Тариф;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.ВидРазмещения) Тогда
//		pARFRec.ВидРазмещения = AccommodationType;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.ТипНомера) Тогда
//		pARFRec.ТипНомера = RoomType;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.НомерРазмещения) Тогда
//		pARFRec.НомерРазмещения = ГруппаНомеров;
//	EndIf;
//	If ЗначениеЗаполнено(pSrvRec.ServiceResource) And TypeOf(pSrvRec.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//		pARFRec.Ресурс = pSrvRec.ServiceResource;
//	EndIf;
//	
//	// Fill Контрагент, contract and payment method from the folio
//	If ЗначениеЗаполнено(pSrvRec.СчетПроживания) Тогда
//		pARFRec.Контрагент = pSrvRec.СчетПроживания.Контрагент;
//		pARFRec.Договор = pSrvRec.СчетПроживания.Договор;
//		pARFRec.Агент = pSrvRec.СчетПроживания.Агент;
//		pARFRec.ГруппаГостей = pSrvRec.СчетПроживания.ГруппаГостей;
//		pARFRec.СпособОплаты = pSrvRec.СчетПроживания.СпособОплаты;
//	EndIf;
//	
//	// Calculate write off coefficient
//	vWriteOffCoeff = 1;
//	If NumberOfPersons > 0 Тогда
//		vWriteOffCoeff = PersonsWriteOff / NumberOfPersons;
//	EndIf;
//	
//	// Recalculate forecast resources according to the write off coefficient
//	vSrvRec = New Structure("Цена, Количество, Сумма, СтавкаНДС, СуммаНДС, СуммаСкидки, НДСскидка, СуммаКомиссии, VATCommissionSum, ПроданоНомеров, ПроданоМест, ПроданоДопМест, ЧеловекаДни, ЗаездГостей", 
//	                        pSrvRec.Цена, pSrvRec.Количество, pSrvRec.Сумма, pSrvRec.СтавкаНДС, pSrvRec.СуммаНДС, pSrvRec.СуммаСкидки, pSrvRec.НДСскидка, pSrvRec.СуммаКомиссии, pSrvRec.СуммаКомиссииНДС, pSrvRec.ПроданоНомеров, pSrvRec.ПроданоМест, pSrvRec.ПроданоДопМест, pSrvRec.ЧеловекаДни, pSrvRec.ЗаездГостей);
//	If vWriteOffCoeff <> 1 Тогда
//		vSrvRec.Quantity = Round(vWriteOffCoeff * vSrvRec.Quantity, 7);
//		vSrvRec.Sum = Round(vSrvRec.Price * vSrvRec.Quantity, 2);
//		vSrvRec.VATSum = cmCalculateVATSum(vSrvRec.VATRate, vSrvRec.Sum);
//		vSrvRec.DiscountSum = Round(vWriteOffCoeff * vSrvRec.DiscountSum, 2);
//		vSrvRec.VATDiscountSum = Round(vWriteOffCoeff * vSrvRec.VATDiscountSum, 2);
//		vSrvRec.CommissionSum = Round(vWriteOffCoeff * vSrvRec.CommissionSum, 2);
//		vSrvRec.VATCommissionSum = Round(vWriteOffCoeff * vSrvRec.VATCommissionSum, 2);
//		vSrvRec.RoomsRented = Round(vWriteOffCoeff * vSrvRec.RoomsRented, 7);
//		vSrvRec.BedsRented = Round(vWriteOffCoeff * vSrvRec.BedsRented, 7);
//		vSrvRec.AdditionalBedsRented = Round(vWriteOffCoeff * vSrvRec.AdditionalBedsRented, 7);
//		vSrvRec.GuestDays = Round(vWriteOffCoeff * vSrvRec.GuestDays, 7);
//		vSrvRec.GuestsCheckedIn = Round(vWriteOffCoeff * vSrvRec.GuestsCheckedIn, 7);
//	EndIf;	
//	
//	vSumInFolioCurrency = vSrvRec.Sum - vSrvRec.DiscountSum;
//	vVATSumInFolioCurrency = vSrvRec.VATSum - vSrvRec.VATDiscountSum;
//	pARFRec.Продажи = vSumInFolioCurrency;
//	pARFRec.ПродажиБезНДС = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	If pSrvRec.IsRoomRevenue Тогда
//		pARFRec.ДоходНомеров = vSumInFolioCurrency;
//		pARFRec.ДоходПродажиБезНДС = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	EndIf;
//	If vSrvRec.AdditionalBedsRented <> 0 Тогда
//		pARFRec.ДоходДопМеста = vSumInFolioCurrency;
//		pARFRec.ДоходДопМестаБезНДС = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	EndIf;
//	pARFRec.Цена = cmRecalculatePrice(vSumInFolioCurrency, vSrvRec.Quantity);
//	pARFRec.Количество = vSrvRec.Quantity;
//	
//	vDiscountSumInFolioCurrency = vSrvRec.DiscountSum;
//	vVATDiscountSumInFolioCurrency = vSrvRec.VATDiscountSum;
//	pARFRec.СуммаСкидки = vDiscountSumInFolioCurrency;
//	pARFRec.СуммаСкидкиБезНДС = vDiscountSumInFolioCurrency - vVATDiscountSumInFolioCurrency;
//	
//	pARFRec.ПроданоНомеров = vSrvRec.RoomsRented;
//	pARFRec.ПроданоМест = vSrvRec.BedsRented;
//	pARFRec.ПроданоДопМест = vSrvRec.AdditionalBedsRented;
//	pARFRec.ЧеловекаДни = vSrvRec.GuestDays;
//	pARFRec.ЗаездГостей = vSrvRec.GuestsCheckedIn;
//	
//	// Fill check-in resources
//	If pARFRec.ЗаездГостей <> 0 And pARFRec.Количество <> 0 Тогда
//		pARFRec.ЗаездНомеров = ?(pARFRec.ПроданоНомеров < 0, -1, 1) * pARFRec.ПроданоНомеров/pARFRec.Количество * Round(vWriteOffCoeff * RoomQuantity, 7);
//		pARFRec.ЗаездМест = ?(pARFRec.ПроданоМест < 0, -1, 1) * pARFRec.ПроданоМест/pARFRec.Количество * Round(vWriteOffCoeff * RoomQuantity, 7);
//		pARFRec.ЗаездДополнительныхМест = ?(pARFRec.ПроданоДопМест < 0, -1, 1) * pARFRec.ПроданоДопМест/pARFRec.Количество * Round(vWriteOffCoeff * RoomQuantity, 7);
//	Else
//		pARFRec.ЗаездНомеров = 0;
//		pARFRec.ЗаездМест = 0;
//		pARFRec.ЗаездДополнительныхМест = 0;
//	EndIf;
//	
//	vSumInFolioCurrency = pSrvRec.Сумма - pSrvRec.СуммаСкидки;
//	vVATSumInFolioCurrency = pSrvRec.СуммаНДС - pSrvRec.НДСскидка;
//	
//	pARFRec.ПланКоличество = pSrvRec.Количество;
//	pARFRec.ПланПродаж = vSumInFolioCurrency;
//	pARFRec.ExpectedSalesWithoutVAT = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	If pSrvRec.IsRoomRevenue Тогда
//		pARFRec.ExpectedRoomRevenue = vSumInFolioCurrency;
//		pARFRec.ExpectedRoomRevenueWithoutVAT = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	EndIf;
//	If pSrvRec.ПроданоДопМест <> 0 Тогда
//		pARFRec.ExpectedExtraBedRevenue = vSumInFolioCurrency;
//		pARFRec.ExpectedExtraBedRevenueWithoutVAT = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	EndIf;
//	
//	vDiscountSumInFolioCurrency = pSrvRec.СуммаСкидки;
//	vVATDiscountSumInFolioCurrency = pSrvRec.НДСскидка;
//	pARFRec.ПланСуммаСкидки = vDiscountSumInFolioCurrency;
//	pARFRec.ExpectedDiscountSumWithoutVAT = vDiscountSumInFolioCurrency - vVATDiscountSumInFolioCurrency;
//	
//	pARFRec.ПланПродажиНомеров = pSrvRec.ПроданоНомеров;
//	pARFRec.ПланПродажиМест = pSrvRec.ПроданоМест;
//	pARFRec.ПланПродажиДопМест = pSrvRec.ПроданоДопМест;
//	pARFRec.ExpectedGuestDays = pSrvRec.ЧеловекаДни;
//	pARFRec.ExpectedGuestsCheckedIn = pSrvRec.ЗаездГостей;
//	
//	// Fill check-in resources
//	If pARFRec.ExpectedGuestsCheckedIn <> 0 And pARFRec.ПланКоличество <> 0 Тогда
//		pARFRec.ExpectedRoomsCheckedIn = ?(pARFRec.ПланПродажиНомеров < 0, -1, 1) * pARFRec.ПланПродажиНомеров/pARFRec.ПланКоличество * RoomQuantity;
//		pARFRec.ПланЗаездМест = ?(pARFRec.ПланПродажиМест < 0, -1, 1) * pARFRec.ПланПродажиМест/pARFRec.ПланКоличество * RoomQuantity;
//		pARFRec.ПланЗаездДопМест = ?(pARFRec.ПланПродажиДопМест < 0, -1, 1) * pARFRec.ПланПродажиДопМест/pARFRec.ПланКоличество * RoomQuantity;
//	Else
//		pARFRec.ExpectedRoomsCheckedIn = 0;
//		pARFRec.ПланЗаездМест = 0;
//		pARFRec.ПланЗаездДопМест = 0;
//	EndIf;
//	
//	// Commission sum
//	pARFRec.СуммаКомиссии = vSrvRec.CommissionSum;
//	pARFRec.КомиссияБезНДС = vSrvRec.CommissionSum - vSrvRec.VATCommissionSum;
//	pARFRec.КомиссияПлан = pSrvRec.СуммаКомиссии;
//	pARFRec.ExpectedCommissionSumWithoutVAT = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//	
//	// Check if Контрагент and agent are the same
//	If ЗначениеЗаполнено(pSrvRec.СчетПроживания) Тогда
//		vDoNotPostCommission = False;
//		If ЗначениеЗаполнено(pSrvRec.СчетПроживания.Агент) And pSrvRec.СчетПроживания.Агент.DoNotPostCommission Тогда
//			vDoNotPostCommission = True;
//		EndIf;
//		If vDoNotPostCommission Тогда
//			pARFRec.СуммаКомиссии = 0;
//			pARFRec.КомиссияБезНДС = 0;
//			pARFRec.КомиссияПлан = 0;
//			pARFRec.ExpectedCommissionSumWithoutVAT = 0;
//		Else
//			If ЗначениеЗаполнено(pSrvRec.СчетПроживания.Агент) And 
//			   pSrvRec.СчетПроживания.Агент <> pSrvRec.СчетПроживания.Контрагент And 
//			   (pSrvRec.СуммаКомиссии <> 0 Or vSrvRec.CommissionSum <> 0) Тогда
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
//				vARFRec.Контрагент = pSrvRec.СчетПроживания.Агент;
//				vARFRec.Договор = pSrvRec.СчетПроживания.Агент.AgentCommissionContract;
//				vARFRec.Агент = pSrvRec.СчетПроживания.Агент;
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
//				vARFRec.СуммаКомиссии = vSrvRec.CommissionSum;
//				vARFRec.КомиссияБезНДС = vSrvRec.CommissionSum - vSrvRec.VATCommissionSum;
//				vARFRec.КомиссияПлан = pSrvRec.СуммаКомиссии;
//				vARFRec.ExpectedCommissionSumWithoutVAT = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillARFAttributes
//
////-----------------------------------------------------------------------------
//Процедура FillExpectedARFAttributes(pARFRec, pSrvRec, pDate)
//	FillPropertyValues(pARFRec, ThisObject);
//	FillPropertyValues(pARFRec, pSrvRec);
//	
//	pARFRec.Period = pDate;
//	pARFRec.ДокОснование = Ref;
//	
//	// Fill client
//	pARFRec.Клиент = Гость;
//	
//	// Fill accommodation parameters
//	If НЕ ЗначениеЗаполнено(pSrvRec.Тариф) Тогда
//		pARFRec.Тариф = Тариф;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.ВидРазмещения) Тогда
//		pARFRec.ВидРазмещения = AccommodationType;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.ТипНомера) Тогда
//		pARFRec.ТипНомера = RoomType;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pSrvRec.НомерРазмещения) Тогда
//		pARFRec.НомерРазмещения = ГруппаНомеров;
//	EndIf;
//	If ЗначениеЗаполнено(pSrvRec.ServiceResource) And TypeOf(pSrvRec.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//		pARFRec.Ресурс = pSrvRec.ServiceResource;
//	EndIf;
//	
//	// Fill Контрагент, contract and payment method from the folio
//	If ЗначениеЗаполнено(pSrvRec.СчетПроживания) Тогда
//		pARFRec.Контрагент = pSrvRec.СчетПроживания.Контрагент;
//		pARFRec.Договор = pSrvRec.СчетПроживания.Договор;
//		pARFRec.Агент = pSrvRec.СчетПроживания.Агент;
//		pARFRec.ГруппаГостей = pSrvRec.СчетПроживания.ГруппаГостей;
//		pARFRec.СпособОплаты = pSrvRec.СчетПроживания.СпособОплаты;
//	EndIf;
//	
//	vSumInFolioCurrency = pSrvRec.Сумма - pSrvRec.СуммаСкидки;
//	vVATSumInFolioCurrency = pSrvRec.СуммаНДС - pSrvRec.НДСскидка;
//	pARFRec.ПланПродаж = vSumInFolioCurrency;
//	pARFRec.ExpectedSalesWithoutVAT = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	If pSrvRec.IsRoomRevenue Тогда
//		pARFRec.ExpectedRoomRevenue = vSumInFolioCurrency;
//		pARFRec.ExpectedRoomRevenueWithoutVAT = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	EndIf;
//	If pSrvRec.ПроданоДопМест <> 0 Тогда
//		pARFRec.ExpectedExtraBedRevenue = vSumInFolioCurrency;
//		pARFRec.ExpectedExtraBedRevenueWithoutVAT = vSumInFolioCurrency - vVATSumInFolioCurrency;
//	EndIf;
//	pARFRec.Цена = cmRecalculatePrice(vSumInFolioCurrency, pSrvRec.Количество);
//	pARFRec.ПланКоличество = pSrvRec.Количество;
//	
//	vDiscountSumInFolioCurrency = pSrvRec.СуммаСкидки;
//	vVATDiscountSumInFolioCurrency = pSrvRec.НДСскидка;
//	pARFRec.ПланСуммаСкидки = vDiscountSumInFolioCurrency;
//	pARFRec.ExpectedDiscountSumWithoutVAT = vDiscountSumInFolioCurrency - vVATDiscountSumInFolioCurrency;
//	
//	pARFRec.ПланПродажиНомеров = pSrvRec.ПроданоНомеров;
//	pARFRec.ПланПродажиМест = pSrvRec.ПроданоМест;
//	pARFRec.ПланПродажиДопМест = pSrvRec.ПроданоДопМест;
//	pARFRec.ExpectedGuestDays = pSrvRec.ЧеловекаДни;
//	pARFRec.ExpectedGuestsCheckedIn = pSrvRec.ЗаездГостей;
//	
//	// Fill check-in resources
//	If pARFRec.ExpectedGuestsCheckedIn <> 0 And pARFRec.ПланКоличество <> 0 Тогда
//		pARFRec.ExpectedRoomsCheckedIn = ?(pARFRec.ПланПродажиНомеров < 0, -1, 1) * pARFRec.ПланПродажиНомеров/pARFRec.ПланКоличество * RoomQuantity;
//		pARFRec.ПланЗаездМест = ?(pARFRec.ПланПродажиМест < 0, -1, 1) * pARFRec.ПланПродажиМест/pARFRec.ПланКоличество * RoomQuantity;
//		pARFRec.ПланЗаездДопМест = ?(pARFRec.ПланПродажиДопМест < 0, -1, 1) * pARFRec.ПланПродажиДопМест/pARFRec.ПланКоличество * RoomQuantity;
//	Else
//		pARFRec.ExpectedRoomsCheckedIn = 0;
//		pARFRec.ПланЗаездМест = 0;
//		pARFRec.ПланЗаездДопМест = 0;
//	EndIf;
//	
//	pARFRec.Продажи = 0;
//	pARFRec.ПродажиБезНДС = 0;
//	pARFRec.ДоходНомеров = 0;
//	pARFRec.ДоходПродажиБезНДС = 0;
//	pARFRec.ДоходДопМеста = 0;
//	pARFRec.ДоходДопМестаБезНДС = 0;
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
//	// Commission sum
//	pARFRec.СуммаКомиссии = 0;
//	pARFRec.КомиссияБезНДС = 0;
//	pARFRec.КомиссияПлан = pSrvRec.СуммаКомиссии;
//	pARFRec.ExpectedCommissionSumWithoutVAT = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//	
//	// Check if Контрагент and agent are the same
//	If ЗначениеЗаполнено(pSrvRec.СчетПроживания) Тогда
//		vDoNotPostCommission = False;
//		If ЗначениеЗаполнено(pSrvRec.СчетПроживания.Агент) And pSrvRec.СчетПроживания.Агент.DoNotPostCommission Тогда
//			vDoNotPostCommission = True;
//		EndIf;
//		If vDoNotPostCommission Тогда
//			pARFRec.КомиссияПлан = 0;
//			pARFRec.ExpectedCommissionSumWithoutVAT = 0;
//		Else
//			If ЗначениеЗаполнено(pSrvRec.СчетПроживания.Агент) And 
//			   pSrvRec.СчетПроживания.Агент <> pSrvRec.СчетПроживания.Контрагент And 
//			   pSrvRec.СуммаКомиссии <> 0 Тогда
//				pARFRec.КомиссияПлан = 0;
//				pARFRec.ExpectedCommissionSumWithoutVAT = 0;
//			
//				// Add new record
//				vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//				FillPropertyValues(vARFRec, pARFRec, , "RecordType");
//				
//				// Fill dimensions
//				vARFRec.Контрагент = pSrvRec.СчетПроживания.Агент;
//				vARFRec.Договор = pSrvRec.СчетПроживания.Агент.AgentCommissionContract;
//				vARFRec.Агент = pSrvRec.СчетПроживания.Агент;
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
//				// Fill commission
//				vARFRec.КомиссияПлан = pSrvRec.СуммаКомиссии;
//				vARFRec.ExpectedCommissionSumWithoutVAT = pSrvRec.СуммаКомиссии - pSrvRec.СуммаКомиссииНДС;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillExpectedARFAttributes
//
////-----------------------------------------------------------------------------
//Процедура PostToForecastSales(pCancel, pRoomsRow = Неопределено)
//	If PersonsWriteOff = 0 And ЗначениеЗаполнено(RoomType) And НЕ RoomType.IsVirtual Тогда
//		Return;
//	EndIf;
//	
//	// Do movement on accounting date for each service in services
//	For Each vSrvRec In Services Do	
//		If НЕ ReservationStatus.DoNotChargeForecastServices Тогда
//			vSFRec = RegisterRecords.ПрогнозПродаж.Add();
//			FillSFAttributes(vSFRec, vSrvRec, vSrvRec.AccountingDate, pRoomsRow);
//			
//			vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//			FillARFAttributes(vARFRec, vSrvRec, vSrvRec.AccountingDate, pRoomsRow);
//		EndIf;
//	EndDo;
//			
//	// Write RegisterRecords	
//	RegisterRecords.ПрогнозПродаж.Write();
//	RegisterRecords.РеестрПутевокКурсовок.Write();
//	RegisterRecords.ПрогнозРеализации.Write();
//КонецПроцедуры //PostToForecastSales
//
////-----------------------------------------------------------------------------
//Процедура PostToExpectedCustomerSales(pCancel)
//	RegisterRecords.ПрогнозРеализации.Clear();
//	
//	If ЗначениеЗаполнено(ReservationStatus) And НЕ ReservationStatus.IsActive And НЕ DoCharging Тогда
//		// Do movement on accounting date for each service in services
//		For Each vSrvRec In Services Do	
//			vARFRec = RegisterRecords.ПрогнозРеализации.Add();
//			FillExpectedARFAttributes(vARFRec, vSrvRec, vSrvRec.AccountingDate);
//		EndDo;
//	EndIf;
//			
//	// Write RegisterRecords	
//	RegisterRecords.ПрогнозРеализации.Write();
//КонецПроцедуры //PostToExpectedCustomerSales
//
////-----------------------------------------------------------------------------
//Процедура CalculateEffectiveNumberOfRooms(pPeriod)
//	// Calculate the effective resources to use
//	vEffectiveResources = cmCalculateEffectiveResourcesForReservation(pPeriod);
//	
//	// Fill effective resources from the structure received
//	EffectiveNumberOfBeds = vEffectiveResources.EffectiveNumberOfBeds;
//	EffectiveNumberOfAddBeds = vEffectiveResources.EffectiveNumberOfAddBeds;
//	EffectiveNumberOfPersons = vEffectiveResources.EffectiveNumberOfPersons;
//	EffectiveNumberOfRooms = vEffectiveResources.EffectiveNumberOfRooms;
//КонецПроцедуры //CalculateEffectiveNumberOfRooms
//
////-----------------------------------------------------------------------------
//Процедура pmPostToInventoryRegisters(pPeriod, pPostForecastSales = True, pCancel = False) Экспорт
//	// If reservation is active
//	If ReservationStatus.IsActive Тогда
//		// Calculate the effective number of rooms to write off
//		CalculateEffectiveNumberOfRooms(pPeriod);
//		// Check if rooms list is filled
//		If RoomQuantity > 1 Тогда
//			// Process each ГруппаНомеров in rooms reserved table
//			If Rooms.Count() > 0 Тогда
//				For Each vRoomsRow In Rooms Do
//					If vRoomsRow.IsUsed Тогда
//						Continue;
//					EndIf;
//					If НЕ ЗначениеЗаполнено(vRoomsRow.ГруппаНомеров) Тогда
//						Continue;
//					EndIf;
//					// Check ГруппаНомеров stop sale flag
//					If vRoomsRow.ГруппаНомеров.СнятСПродажи Тогда
//						vRemarks = "";
//						If cmIsRoomStopSalePeriod(vRoomsRow.ГруппаНомеров, pPeriod.CheckInDate, pPeriod.ДатаВыезда, vRemarks) Тогда
//							If НЕ cmCheckUserPermissions("HavePermissionToIgnoreStopSaleLimitations") Тогда
//								pCancel = True; 
//								vMessage = "ru='" + "Выбранный НомерРазмещения снят с продажи!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF) + "';
//								           |de='" + "НомерРазмещения choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF) + "';
//								           |en='" + "НомерРазмещения choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF) + "';";
//								WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, NStr(vMessage));
//								Message(NStr(vMessage), MessageStatus.Attention);
//								ВызватьИсключение NStr(vMessage);
//							EndIf;
//						EndIf;
//					EndIf;
//					// To the ГруппаНомеров inventory
//					PostToRoomInventory(pCancel, pPeriod, vRoomsRow);
//					// Check rooms availability
//					vMsgTextRu = ""; vMsgTextEn = ""; vMsgTextDe = "";
//					If НЕ cmCheckRoomAvailability(Гостиница, RoomQuota, pPeriod.ТипНомера, vRoomsRow.ГруппаНомеров, Ref, True, False,
//												   PersonsWriteOff, RoomsWriteOff, BedsWriteOff, AdditionalBedsWriteOff, 
//												   NumberOfBedsPerRoom, NumberOfPersonsPerRoom, Max(CurrentDate(), pPeriod.CheckInDate), pPeriod.ДатаВыезда, 
//												   vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//						pCancel = True; 
//						vMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//						WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, NStr(vMessage));
//						Message(NStr(vMessage), MessageStatus.Attention);
//						ВызватьИсключение NStr(vMessage);
//					EndIf;
//					// To the ГруппаНомеров quota sales
//					If ЗначениеЗаполнено(RoomQuota) Тогда
//						PostToRoomQuotaSales(pCancel, pPeriod, vRoomsRow);
//					EndIf;
//					// To the forecast sales
//					If НЕ DoCharging And pPeriod.CheckInDate = CheckInDate And pPostForecastSales Тогда
//						PostToForecastSales(pCancel, vRoomsRow);
//					EndIf;
//				EndDo;
//			Else
//				// Check rights to book without ГруппаНомеров
//				vMsgTextRu = ""; vMsgTextEn = ""; vMsgTextDe = "";
//				If НЕ HavePermissionToDoBookingWithoutRooms And НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//					pCancel = True;
//					vMsgTextRu = "У вас нет прав на бронирование по категориям номеров без указания номеров комнат!";
//					vMsgTextEn = "You do not have right to book by НомерРазмещения types without НомерРазмещения numbers!";
//					vMsgTextDe = "У вас нет прав на бронирование по категориям номеров без указания номеров комнат!";
//					vMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//					WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, NStr(vMessage));
//					Message(NStr(vMessage), MessageStatus.Attention);
//					ВызватьИсключение NStr(vMessage);
//				EndIf;
//			EndIf;
//			// To the ГруппаНомеров inventory
//			PostToRoomInventory(pCancel, pPeriod);
//			// To the ГруппаНомеров quota sales
//			If ЗначениеЗаполнено(RoomQuota) Тогда
//				PostToRoomQuotaSales(pCancel, pPeriod);
//			EndIf;
//			// To the forecast sales
//			If НЕ DoCharging And pPeriod.CheckInDate = CheckInDate And pPostForecastSales Тогда
//				PostToForecastSales(pCancel);
//			EndIf;
//		Else
//			// Check rights to book without ГруппаНомеров
//			vMsgTextRu = ""; vMsgTextEn = ""; vMsgTextDe = "";
//			If НЕ HavePermissionToDoBookingWithoutRooms And НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//				pCancel = True;
//				vMsgTextRu = "У вас нет прав на бронирование по категориям номеров без указания номеров комнат!";
//				vMsgTextEn = "You do not have right to book by НомерРазмещения types without НомерРазмещения numbers!";
//				vMsgTextDe = "У вас нет прав на бронирование по категориям номеров без указания номеров комнат!";
//				vMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//				WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, NStr(vMessage));
//				Message(NStr(vMessage), MessageStatus.Attention);
//				ВызватьИсключение NStr(vMessage);
//			EndIf;
//			// Calculate the effective number of rooms to write off
//			vPrevEffectiveNumberOfRoomsRow = Неопределено;
//			vNextEffectiveNumberOfRoomsRow = Неопределено;
//			vEffectiveNumberOfRooms = cmCalculateEffectiveNumberOfRoomsForReservation(pPeriod, EffectiveNumberOfRooms, EffectiveNumberOfBeds, EffectiveNumberOfAddBeds, EffectiveNumberOfPersons);
//			i = 0;
//			While i < vEffectiveNumberOfRooms.Count() Do
//				// To the ГруппаНомеров inventory
//				vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Get(i);
//				If i > 0 Тогда
//					vPrevEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Get(i - 1);
//				EndIf;
//				If i < (vEffectiveNumberOfRooms.Count() - 1) Тогда
//					vNextEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Get(i + 1);
//				Else
//					vNextEffectiveNumberOfRoomsRow = Неопределено;
//				EndIf;
//				PostToRoomInventoryDetailed(pCancel, pPeriod, vEffectiveNumberOfRoomsRow, vPrevEffectiveNumberOfRoomsRow, vNextEffectiveNumberOfRoomsRow);
//				// To the ГруппаНомеров quota sales
//				If ЗначениеЗаполнено(pPeriod.КвотаНомеров) Тогда
//					PostToRoomQuotaSalesDetailed(pCancel, pPeriod, vEffectiveNumberOfRoomsRow);
//				EndIf;
//				// Next row
//				i = i + 1;
//			EndDo;
//			// To the forecast sales
//			If НЕ DoCharging And pPeriod.CheckInDate = CheckInDate And pPostForecastSales Тогда
//				PostToForecastSales(pCancel);
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmPostToInventoryRegisters
//
////-----------------------------------------------------------------------------
//Процедура DoChargeTransfer(pTabRow, pChargeRow)
//	If pChargeRow <> Неопределено Тогда
//		If pChargeRow.СчетПроживания <> pTabRow.СчетПроживания Тогда
//			If НЕ ЗначениеЗаполнено(pChargeRow.ПеремещениеНачисления) Тогда
//				vChargeObj = pChargeRow.Ref.GetObject();
//				vChargeObj.СчетПроживания = pTabRow.СчетПроживания;
//				If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//					vChargeObj.Write(DocumentWriteMode.Posting);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //DoChargeTransfer
//
////-----------------------------------------------------------------------------
//Процедура DoCharge(pTabRow, pChargeRow)
//	If ЗначениеЗаполнено(pTabRow.УчетнаяДата) Тогда
//		If pChargeRow = Неопределено Тогда
//			vChargeObj = Documents.Начисление.CreateDocument();
//		Else
//			vChargeObj = pChargeRow.Ref.GetObject();
//		EndIf;
//		
//		FillPropertyValues(vChargeObj, pTabRow);
//		
//		// Resource
//		If ЗначениеЗаполнено(pTabRow.ServiceResource) And TypeOf(pTabRow.ServiceResource) = Type("CatalogRef.Ресурсы") Тогда
//			vChargeObj.Ресурс = pTabRow.ServiceResource; 
//		EndIf;
//		
//		// Fill identity parameters
//		vChargeObj.ДатаДок = pTabRow.УчетнаяДата;
//		vChargeObj.SetTime(AutoTimeMode.DontUse);
//		vChargeObj.ДокОснование = Ref;
//		vChargeObj.Автор = ПараметрыСеанса.ТекПользователь;
//		
//		// Fill charge exchange rate date and folio and reporting currency exchange rates
//		vChargeObj.ExchangeRateDate = ?(ЗначениеЗаполнено(pTabRow.УчетнаяДата), pTabRow.УчетнаяДата, ExchangeRateDate);
//		vChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.ВалютаЛицСчета, vChargeObj.ExchangeRateDate);
//		vChargeObj.ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(vChargeObj.Гостиница, vChargeObj.Валюта, vChargeObj.ExchangeRateDate);
//		
//		// Fill charge payment section
//		vChargeObj.PaymentSection = vChargeObj.Услуга.PaymentSection;
//		
//		// Do not add splitted services to the hotel product sales
//		If vChargeObj.ЭтоРазделение Тогда
//			vChargeObj.ПутевкаКурсовка = Справочники.ПутевкиКурсовки.EmptyRef();
//		EndIf;
//		
//		// Post charge
//		If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//			If ЗначениеЗаполнено(vChargeObj.СчетПроживания) Тогда
//				If vChargeObj.СчетПроживания.DeletionMark Тогда
//					vFolioObj = vChargeObj.СчетПроживания.GetObject();
//					vFolioObj.SetDeletionMark(False);
//				EndIf;
//				vChargeObj.Write(DocumentWriteMode.Posting);
//			EndIf;
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
//		vChargeRow = cmGetChargeRow(pCharges, vRow);
//		// Try to find the same row in the existing services
//		vServiceRow = cmGetChargeRow(pServices, vRow);
//		// Check search results
//		If vChargeRow = Неопределено And vServiceRow = Неопределено Тогда
//			ВызватьИсключение NStr("en='Failed to build charges list! Please contact product support team.';de='Failed to build charges list! Please contact product support team.';ru='Ошибка при формировании таблицы начислений. Пожалуйста сообщите об ошибке команде сопровождения программы.'");
//		ElsIf vChargeRow = Неопределено And vServiceRow <> Неопределено Тогда
//			// No such row in previously charged services, so do charging
//			If ЗначениеЗаполнено(vServiceRow.Услуга) And ЗначениеЗаполнено(vServiceRow.Услуга.ServiceType) And 
//			   vServiceRow.Услуга.ServiceType.ActualAmountIsChargedExternally And 
//			   (vServiceRow.УчетнаяДата < BegOfDay(CurrentDate()) Or ReservationStatus.IsCheckIn) Тогда
//			Else
//				DoCharge(vServiceRow, vChargeRow);
//			EndIf;
//		ElsIf vChargeRow <> Неопределено And vServiceRow = Неопределено Тогда
//			// No such row in current services, so delete previous charge
//			DeleteCharge(pCharges, vChargeRow);
//		ElsIf vUpdatedCharges.FindByValue(vChargeRow.Ref) = Неопределено Тогда		
//			If ЗначениеЗаполнено(vServiceRow.Услуга) And ЗначениеЗаполнено(vServiceRow.Услуга.ServiceType) And 
//			   vServiceRow.Услуга.ServiceType.ActualAmountIsChargedExternally And 
//			   (vServiceRow.УчетнаяДата < BegOfDay(CurrentDate()) Or ReservationStatus.IsCheckIn) Тогда
//				// Delete previous charge
//				DeleteCharge(pCharges, vChargeRow);
//			Else
//				vUpdatedCharges.Add(vChargeRow.Ref);
//				// Check resources for the row. If all are 0 then check should we 
//				// change folio for this charge
//				If cmServiceResourcesAreZero(vRow) Тогда
//					DoChargeTransfer(vServiceRow, vChargeRow);
//				Else
//					// Update old charge with current service data
//					DoCharge(vServiceRow, vChargeRow);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //ChargeServiceDifferences
//
////-----------------------------------------------------------------------------
//Процедура PostToAccumulatingDiscountResources()
//	// Clear register records
//	RegisterRecords.НакопитСкидки.Clear();
//	RegisterRecords.НакопитСкидки.Write();
//	// Get accummulating discount types
//	vAccDiscounts = cmGetAccumulatingDiscountTypes(DiscountType);
//	For Each vAccDiscount In vAccDiscounts Do
//		vDiscountType = vAccDiscount.ТипСкидки;
//		If TurnOffAutomaticDiscounts Тогда
//			If DiscountType <> vDiscountType Тогда
//				Continue;
//			EndIf;
//		EndIf;
//		vDiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//		For Each vSrvRow In Services Do
//			vService = vSrvRow.Service;
//			If cmIsServiceInServiceGroup(vService, vDiscountServiceGroup) Тогда
//				If НЕ vDiscountType.IsForRackRatesOnly Or vDiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(vSrvRow.Тариф) And vSrvRow.Тариф.IsRackRate Тогда 
//					vDiscountTypeObj = vDiscountType.GetObject();
//					vDiscountDimension = Неопределено;
//					vResource = vDiscountTypeObj.pmCalculateResource(vSrvRow, NumberOfPersons, vSrvRow.ЛицевойСчет, DiscountCard, vDiscountDimension);
//					If vResource <> 0 Тогда
//						If ЗначениеЗаполнено(vDiscountDimension) Тогда
//							Movement = RegisterRecords.НакопитСкидки.Add();
//							If vResource > 0 Тогда
//								Movement.RecordType = AccumulationRecordType.Receipt;
//							Else
//								Movement.RecordType = AccumulationRecordType.Expense;
//							EndIf;
//							Movement.Period = vSrvRow.AccountingDate;
//							Movement.ТипСкидки = vDiscountType;
//							Movement.ИзмерениеСкидки = vDiscountDimension;
//							If vDiscountType.IsPerVisit Or vDiscountType.BonusCalculationFactor <> 0 Тогда
//								Movement.ГруппаГостей = GuestGroup;
//							EndIf;
//							Movement.Ресурс = vResource;
//							If vDiscountTypeObj.BonusCalculationFactor <> 0 Тогда
//								Movement.Бонус = vResource * vDiscountTypeObj.BonusCalculationFactor;
//							EndIf;
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
//	// 1. Build table of already charged services
//	vChargesTab = cmGetTableOfAlreadyChargedServices(Ref);
//	
//	// 2. Create table of document services
//	vServicesTab = Services.Unload();
//	If НЕ DoCharging Тогда
//		vServicesTab.Clear();
//		
//		// Write to accumulation discount resources
//		If ЗначениеЗаполнено(ReservationStatus) And ReservationStatus.IsActive Тогда
//			PostToAccumulatingDiscountResources();
//		EndIf;
//	EndIf;
//	
//	// Add analitical dimensions to the services table
//	cmAddServicesDimensionsColumns(vServicesTab);
//	
//	// If accommodation is active
//	For Each vSrv In vServicesTab Do
//		// Fill is manual column
//		If vSrv.IsManualPrice Тогда
//			vSrv.IsManual = True;
//		EndIf;
//		// Try to set folio for the transfered charges
//		vChargesRows = vChargesTab.FindRows(New Structure("УчетнаяДата", vSrv.AccountingDate));
//		For Each vChargesRow In vChargesRows Do
//			If ЗначениеЗаполнено(vChargesRow.ПеремещениеНачисления) And
//			   vSrv.Service = vChargesRow.Услуга And
//			   vSrv.Price = vChargesRow.Цена And
//			   vSrv.VATRate = vChargesRow.СтавкаНДС And
//			   vSrv.IsManual = vChargesRow.IsManual Тогда
//				vSrv.ЛицевойСчет = vChargesRow.СчетПроживания;
//				vSrv.FolioCurrency = vSrv.ЛицевойСчет.ВалютаЛицСчета;
//				If ЗначениеЗаполнено(vSrv.ЛицевойСчет.Фирма) Тогда
//					vSrv.Фирма = vSrv.ЛицевойСчет.Фирма;
//				EndIf;
//				Break;
//			EndIf;
//		EndDo;
//		// Fill additional charge attributes
//		cmFillServicesDimensionsColumns(vSrv, ThisObject);
//	EndDo;
//	
//	// 3. Build difference table between already charged services and 
//	// services in the document. We will do it ignoring folios.
//	vServicesDifferenceTab = cmGetServicesDifference(vServicesTab, vChargesTab);
//	
//	// 4. Create charging for each service in difference services
//	ChargeServiceDifferences(vServicesDifferenceTab, vServicesTab, vChargesTab);
//КонецПроцедуры //ChargeServices
//
////-----------------------------------------------------------------------------
//Function pmGetCheckInDate() Экспорт
//	vCheckInDate = CheckInDate;
//	If ParentDoc = Ref Тогда
//		ParentDoc = Неопределено;
//	EndIf;
//	vParentDoc = ParentDoc;
//	While ЗначениеЗаполнено(vParentDoc) Do
//		If TypeOf(vParentDoc) = Type("DocumentRef.Reservation") Тогда
//			vCheckInDate = Min(vCheckInDate, vParentDoc.CheckInDate);
//			vParentDoc = vParentDoc.ДокОснование;
//		Else
//			Break;
//		EndIf;
//	EndDo;
//	Return vCheckInDate;
//EndFunction //pmGetCheckInDate
//
////-----------------------------------------------------------------------------
//Function pmGetFirstReservationInChain() Экспорт
//	vFirstResInChain = Ref;
//	While ЗначениеЗаполнено(vFirstResInChain.ДокОснование) Do
//		vFirstResInChain = vFirstResInChain.ДокОснование;
//	EndDo;
//	Return vFirstResInChain;
//EndFunction //pmGetFirstReservationInChain
//
////-----------------------------------------------------------------------------
//Function pmGetNextReservationInChain(pReservation = Неопределено) Экспорт
//	vNextDoc = Неопределено;
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.Posted
//	|	AND Reservation.ДокОснование = &qParentDoc
//	|	AND Reservation.CheckInDate > &qCheckInDate
//	|	AND (Reservation.ReservationStatus.IsActive
//	|			OR Reservation.ReservationStatus.ЭтоЗаезд
//	|	        OR Reservation.ReservationStatus.IsPreliminary)";
//	If ЗначениеЗаполнено(pReservation) Тогда
//		vQry.SetParameter("qParentDoc", pReservation);
//		vQry.SetParameter("qCheckInDate", pReservation.CheckInDate);
//	Else
//		vQry.SetParameter("qParentDoc", Ref);
//		vQry.SetParameter("qCheckInDate", CheckInDate);
//	EndIf;
//	vNextDocs = vQry.Execute().Unload();
//	If vNextDocs.Count() > 0 Тогда
//		vNextDoc = vNextDocs.Get(0).Ref;
//	EndIf;
//	REturn vNextDoc;
//EndFunction //pmGetNextReservationInChain
//
////-----------------------------------------------------------------------------
//Function pmGetLastReservationInChain() Экспорт
//	vLastResInChain = Ref;
//	vNextResInChain = pmGetNextReservationInChain();
//	While ЗначениеЗаполнено(vNextResInChain) Do
//		vLastResInChain = vNextResInChain;
//		vNextResInChain = pmGetNextReservationInChain(vNextResInChain);
//	EndDo;
//	If ЗначениеЗаполнено(vLastResInChain) And 
//	   (НЕ vLastResInChain.Posted Or НЕ ЗначениеЗаполнено(vLastResInChain.ReservationStatus) Or
//		(ЗначениеЗаполнено(vLastResInChain.ReservationStatus) And НЕ vLastResInChain.ReservationStatus.IsActive And НЕ vLastResInChain.ReservationStatus.ЭтоЗаезд And НЕ vLastResInChain.ReservationStatus.IsPreliminary)) Тогда
//		// Current reservation is not active and there are no active reservations after it
//		// So, try to check previous one
//		vParentRes = vLastResInChain.ДокОснование;
//		While ЗначениеЗаполнено(vParentRes) And TypeOf(vParentRes) = Type("DocumentRef.Reservation") And 
//		      (НЕ vParentRes.Posted Or НЕ ЗначениеЗаполнено(vParentRes.ReservationStatus) Or
//		       (ЗначениеЗаполнено(vParentRes.ReservationStatus) And НЕ vParentRes.ReservationStatus.IsActive And НЕ vParentRes.ReservationStatus.ЭтоЗаезд And НЕ vParentRes.ReservationStatus.IsPreliminary)) Do
//			vParentRes = vParentRes.ДокОснование;
//		EndDo;
//		If ЗначениеЗаполнено(vParentRes) And TypeOf(vParentRes) = Type("DocumentRef.Reservation") And 
//		   vParentRes.Posted And ЗначениеЗаполнено(vParentRes.ReservationStatus) And (vParentRes.ReservationStatus.IsActive Or vParentRes.ReservationStatus.ЭтоЗаезд Or vParentRes.ReservationStatus.IsPreliminary) Тогда
//			vLastResInChain = vParentRes;
//		EndIf;
//	EndIf;
//	Return vLastResInChain;
//EndFunction //pmGetLastReservationInChain
//
////-----------------------------------------------------------------------------
//Процедура FillFolioParameters(pCancel)
//	// Get last reservation in chain and use it to set folio parameters
//	vLastReservation = pmGetLastReservationInChain();
//	// Set parameters of the folios in the charging rules
//	For Each vCRRec In ChargingRules Do
//		If ЗначениеЗаполнено(vCRRec.ChargingFolio) Тогда
//			If НЕ vCRRec.IsMaster Тогда
//				If НЕ ЗначениеЗаполнено(vCRRec.Owner) Or 
//				   (TypeOf(vCRRec.Owner) <> Type("DocumentRef.Размещение") And 
//				    TypeOf(vCRRec.Owner) <> Type("DocumentRef.Reservation")) Тогда
//					vFolioRef = vCRRec.ChargingFolio;
//					// Skip transfer rules
//					If vCRRec.IsTransfer Тогда
//						Continue;
//					EndIf;
//					// Check if there is accommodation for this folio
//					If ЗначениеЗаполнено(vFolioRef.ParentDoc) And TypeOf(vFolioRef.ParentDoc) = Type("DocumentRef.Размещение") 
//					   And vFolioRef.ParentDoc.Posted And ЗначениеЗаполнено(vFolioRef.ParentDoc.СтатусРазмещения) And 
//					   vFolioRef.ParentDoc.СтатусРазмещения.Действует Тогда
//						Continue;
//					EndIf;
//					// Update folio attributes
//					vFolioIsChanged = False;
//					vFolioObj = vFolioRef.GetObject();
//					vFolioObj.Read();
//					If vFolioObj.Гостиница <> Гостиница Тогда
//						vFolioObj.Гостиница = Гостиница;
//						vFolioIsChanged = True;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And НЕ vFolioObj.DoNotUpdateCompany Тогда
//						If ЗначениеЗаполнено(ГруппаНомеров) And ЗначениеЗаполнено(ГруппаНомеров.Фирма) Or
//						   ЗначениеЗаполнено(RoomType) And ЗначениеЗаполнено(RoomType.Фирма) Or 
//						   ЗначениеЗаполнено(Тариф) And ЗначениеЗаполнено(Тариф.Фирма) Or 
//						   ((НЕ ЗначениеЗаполнено(ГруппаНомеров) Or ЗначениеЗаполнено(ГруппаНомеров) And НЕ ЗначениеЗаполнено(ГруппаНомеров.Фирма)) And 
//						    ЗначениеЗаполнено(RoomType) And НЕ ЗначениеЗаполнено(RoomType.Фирма) And 
//							ЗначениеЗаполнено(Тариф) And НЕ ЗначениеЗаполнено(Тариф.Фирма)) Тогда
//							If vFolioObj.Фирма <> Фирма Тогда
//								vFolioObj.Фирма = Фирма;
//								vFolioIsChanged = True;
//							EndIf;
//						EndIf;
//					EndIf;
//					If НЕ ЗначениеЗаполнено(vFolioObj.ДокОснование) Or 
//					   vFolioObj.ДокОснование <> Ref And 
//					   (TypeOf(vFolioObj.ДокОснование) <> Type("DocumentRef.Размещение") Or 
//					    TypeOf(vFolioObj.ДокОснование) = Type("DocumentRef.Размещение") And 
//						(НЕ vFolioObj.ДокОснование.Posted Or vFolioObj.ДокОснование.Posted And НЕ vFolioObj.ДокОснование.СтатусРазмещения.Действует)) Тогда
//						vFolioObj.ДокОснование = pmGetThisDocumentRef();
//						vFolioIsChanged = True;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And TypeOf(vCRRec.Owner) <> Type("CatalogRef.Clients") Тогда
//						If vFolioObj.Клиент <> Гость Тогда
//							vFolioObj.Клиент = Гость;
//							vFolioIsChanged = True;
//						EndIf;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And vFolioObj.ГруппаГостей <> GuestGroup Тогда
//						vFolioObj.ГруппаГостей = GuestGroup;
//						vFolioIsChanged = True;
//					EndIf;
//					If TypeOf(vCRRec.Owner) <> Type("CatalogRef.НомернойФонд") Тогда
//						If vFolioObj.НомерРазмещения <> ГруппаНомеров Тогда
//							vFolioObj.НомерРазмещения = ГруппаНомеров;
//							vFolioIsChanged = True;
//						EndIf;
//					EndIf;
//					vDateTimeFrom = pmGetCheckInDate();
//					If ЗначениеЗаполнено(vCRRec.ValidFromDate) Тогда
//						vRefHour = cmGetReferenceHour(Тариф);
//						vDateTimeFrom = cm1SecondShift(BegOfDay(vCRRec.ValidFromDate) + (vRefHour - BegOfDay(vRefHour)));
//					EndIf;
//					If vFolioObj.DateTimeFrom <> vDateTimeFrom Тогда
//						vFolioObj.DateTimeFrom = vDateTimeFrom;
//						vFolioIsChanged = True;
//					EndIf;
//					vDateTimeTo = vLastReservation.ДатаВыезда;
//					If ЗначениеЗаполнено(vCRRec.ValidToDate) Тогда
//						vRefHour = cmGetReferenceHour(Тариф);
//						vDateTimeTo = cm0SecondShift(BegOfDay(vCRRec.ValidToDate) + (vRefHour - BegOfDay(vRefHour)) + 24*3600);
//					EndIf;
//					If vFolioObj.DateTimeTo <> vDateTimeTo Тогда
//						vFolioObj.DateTimeTo = vDateTimeTo;
//						vFolioIsChanged = True;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Тогда
//						If НЕ ЗначениеЗаполнено(vFolioObj.СпособОплаты) Тогда
//							If ЗначениеЗаполнено(PlannedPaymentMethod) Тогда
//								If vFolioObj.СпособОплаты <> PlannedPaymentMethod Тогда
//									vFolioObj.СпособОплаты = PlannedPaymentMethod;
//									vFolioIsChanged = True;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//					If ЗначениеЗаполнено(ReservationStatus) Тогда
//						If НЕ ReservationStatus.IsCheckIn And НЕ ReservationStatus.IsActive And НЕ ReservationStatus.IsPreliminary Тогда
//							If НЕ vFolioObj.IsMaster And НЕ vFolioObj.IsClosed Тогда
//								// Check that there is no other active documents referencing this folio
//								vFolioDocs = cmGetActiveFolioDocuments(vFolioObj.Ref, Ref);
//								// Close folio
//								If vFolioDocs.Count() = 0 Тогда
//									vFolioObj.IsClosed = True;
//									vFolioIsChanged = True;
//								EndIf;
//							EndIf;
//						Else
//							If vFolioObj.IsClosed Тогда
//								vFolioObj.IsClosed = False;
//								vFolioIsChanged = True;
//							EndIf;
//						EndIf;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And Agent <> vFolioObj.Агент Тогда
//						vFolioObj.Агент = Agent;
//						vFolioIsChanged = True;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And ЗначениеЗаполнено(HotelProduct) Тогда
//						vHotelProductParent = Неопределено;
//						If HotelProduct.IsFolder Тогда
//							vHotelProductParent = HotelProduct;
//						Else
//							vHotelProductParent = HotelProduct.Parent;
//						EndIf;
//						If ЗначениеЗаполнено(vHotelProductParent) And ЗначениеЗаполнено(vHotelProductParent.PaymentSection) Тогда
//							vAccSrvFolio = pmGetAccommodationServiceChargingFolio();
//							If vCRRec.ChargingFolio = vAccSrvFolio Тогда
//								If vHotelProductParent.PaymentSection <> vFolioObj.PaymentSection Тогда
//									vFolioObj.PaymentSection = vHotelProductParent.PaymentSection;
//									vFolioIsChanged = True;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And ЗначениеЗаполнено(ClientType) And ЗначениеЗаполнено(ClientType.PaymentSection) Тогда
//						vAccSrvFolio = pmGetAccommodationServiceChargingFolio();
//						If vCRRec.ChargingFolio = vAccSrvFolio Тогда
//							If ClientType.PaymentSection <> vFolioObj.PaymentSection Тогда
//								vFolioObj.PaymentSection = ClientType.PaymentSection;
//								vFolioIsChanged = True;
//							EndIf;
//						EndIf;
//					EndIf;
//					If НЕ vFolioObj.IsMaster And ЗначениеЗаполнено(vCRRec.Owner) Тогда
//						If TypeOf(vCRRec.Owner) = Type("CatalogRef.Контрагенты") Тогда
//							If vFolioObj.Контрагент <> vCRRec.Owner Тогда
//								vFolioObj.Контрагент = vCRRec.Owner;
//								vFolioObj.Договор = Справочники.Договора.EmptyRef();
//								vFolioIsChanged = True;
//							EndIf;
//						ElsIf TypeOf(vCRRec.Owner) = Type("CatalogRef.Договора") Тогда
//							If vFolioObj.Договор <> vCRRec.Owner Тогда
//								vFolioObj.Контрагент = vCRRec.Owner.Owner;
//								vFolioObj.Договор = vCRRec.Owner;
//								vFolioIsChanged = True;
//							EndIf;
//						ElsIf TypeOf(vCRRec.Owner) = Type("CatalogRef.Clients") Тогда
//							If vFolioObj.Клиент <> vCRRec.Owner Тогда
//								vFolioObj.Клиент = vCRRec.Owner;
//								vFolioIsChanged = True;
//							EndIf;
//						EndIf;
//					Else
//						If НЕ vFolioObj.IsMaster And ЗначениеЗаполнено(vFolioObj.Контрагент) Тогда
//							vFolioObj.Контрагент = Справочники.Контрагенты.EmptyRef();
//							vFolioObj.Договор = Справочники.Договора.EmptyRef();
//							vFolioIsChanged = True;
//						EndIf;
//					EndIf;
//					If НЕ vFolioObj.IsMaster Тогда
//						vAccommodationServices = Services.FindRows(New Structure("СчетПроживания, IsRoomRevenue, IsInPrice, ЭтоРазделение", vFolioRef, True, True, False));
//						If vAccommodationServices.Count() > 0 Тогда
//							vFolioObj.Примечания = TrimAll(Remarks);
//							vFolioIsChanged = True;
//						EndIf;
//					EndIf;
//					If vFolioObj.DeletionMark Тогда
//						vFolioObj.DeletionMark = False;
//						vFolioIsChanged = True;
//					EndIf;
//					If vFolioIsChanged Тогда
//						vFolioObj.Write(DocumentWriteMode.Write);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//	// Process extra folios created manually
//	vFolios = cmGetActiveDocumentFolios(Ref);
//	For Each vFoliosRow In vFolios Do
//		If ЗначениеЗаполнено(vFoliosRow.СчетПроживания) Тогда
//			vFolioRef = vFoliosRow.СчетПроживания;
//			If ChargingRules.Find(vFolioRef, "ChargingFolio") <> Неопределено Тогда
//				Continue;
//			EndIf;
//			vFolioIsChanged = False;
//			vFolioObj = vFolioRef.GetObject();
//			vFolioObj.Read();
//			If vFolioObj.Гостиница <> Гостиница Тогда
//				vFolioObj.Гостиница = Гостиница;
//				vFolioIsChanged = True;
//			EndIf;
//			If НЕ vFolioObj.IsMaster And vFolioObj.Клиент <> Гость Тогда
//				vFolioObj.Клиент = Гость;
//				vFolioIsChanged = True;
//			EndIf;
//			If НЕ vFolioObj.IsMaster And vFolioObj.ГруппаГостей <> GuestGroup Тогда
//				vFolioObj.ГруппаГостей = GuestGroup;
//				vFolioIsChanged = True;
//			EndIf;
//			If vFolioObj.НомерРазмещения <> ГруппаНомеров Тогда
//				vFolioObj.НомерРазмещения = ГруппаНомеров;
//				vFolioIsChanged = True;
//			EndIf;
//			vDateTimeFrom = pmGetCheckInDate();
//			If vFolioObj.DateTimeFrom <> vDateTimeFrom Тогда
//				vFolioObj.DateTimeFrom = vDateTimeFrom;
//				vFolioIsChanged = True;
//			EndIf;
//			vDateTimeTo = vLastReservation.ДатаВыезда;
//			If vFolioObj.DateTimeTo <> vDateTimeTo Тогда
//				vFolioObj.DateTimeTo = vDateTimeTo;
//				vFolioIsChanged = True;
//			EndIf;
//			// Save changes if folio object was changed
//			If vFolioIsChanged Тогда
//				vFolioObj.Write(DocumentWriteMode.Write);
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //FillFolioParameters
//
////-----------------------------------------------------------------------------
//Процедура SetFolioStatuses(pCancel)
//	// Check current folio status state
//	If НЕ ReservationStatus.IsActive And НЕ ReservationStatus.IsPreliminary Тогда
//		// Close all folios of the current document
//		vFolios = cmGetActiveDocumentFolios(Ref);
//		For Each vFoliosRow In vFolios Do
//			If ЗначениеЗаполнено(vFoliosRow.СчетПроживания) Тогда
//				If НЕ vFoliosRow.СчетПроживания.IsMaster Тогда
//					vFolioRef = vFoliosRow.СчетПроживания;
//					// Check should we change folio status at all
//					If ЗначениеЗаполнено(AccommodationType) And AccommodationType.НачислятьНаЛицевойСчет And 
//					   ЗначениеЗаполнено(vFolioRef.ДокОснование) And vFolioRef.ДокОснование <> Ref Тогда
//						Continue;
//					EndIf;
//					// Check that there is no other active documents referencing this folio
//					vFolioDocs = cmGetActiveFolioDocuments(vFolioRef, Ref);
//					If НЕ vFolioRef.IsClosed Тогда
//						// Close folio
//						If vFolioDocs.Count() = 0 Тогда
//							vFolioObj = vFolioRef.GetObject();
//							vFolioObj.Read();
//							vFolioObj.IsClosed = True;
//							vFolioObj.Write(DocumentWriteMode.Write);
//						EndIf;
//					Else
//						// Open folio
//						If vFolioDocs.Count() > 0 Тогда
//							vFolioObj = vFolioRef.GetObject();
//							vFolioObj.Read();
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
//						vFolioObj.Read();
//						vFolioObj.IsClosed = True;
//						vFolioObj.Write(DocumentWriteMode.Write);
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//	Else
//		// Open all folios of the current document
//		vFolios = cmGetInactiveDocumentFolios(Ref);
//		For Each vFoliosRow In vFolios Do
//			If ЗначениеЗаполнено(vFoliosRow.СчетПроживания) Тогда
//				vFolioRef = vFoliosRow.СчетПроживания;
//				// Check should we change folio status at all
//				If ЗначениеЗаполнено(AccommodationType) And AccommodationType.НачислятьНаЛицевойСчет And 
//				   ЗначениеЗаполнено(vFolioRef.ДокОснование) And vFolioRef.ДокОснование <> Ref Тогда
//					Continue;
//				EndIf;
//				If vFolioRef.IsClosed Тогда
//					vFolioObj = vFolioRef.GetObject();
//					vFolioObj.Read();
//					vFolioObj.IsClosed = False;
//					vFolioObj.Write(DocumentWriteMode.Write);
//				EndIf;
//			EndIf;
//		EndDo;
//		// Check should we open guest group folios or not
//		If ЗначениеЗаполнено(GuestGroup) And GuestGroup.ChargingRules.Count() > 0 Тогда
//			For Each vGGCRRow In GuestGroup.ChargingRules Do
//				If ЗначениеЗаполнено(vGGCRRow.ChargingFolio) And vGGCRRow.ChargingFolio.IsClosed Тогда
//					vFolioObj = vGGCRRow.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					vFolioObj.IsClosed = False;
//					vFolioObj.Write(DocumentWriteMode.Write);
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//КонецПроцедуры //SetFolioStatuses
//
////-----------------------------------------------------------------------------
//Процедура DoChangeRoomStatus(pRoomStatus, pRoom)
//	If НЕ ЗначениеЗаполнено(pRoom) Тогда
//		Return;
//	EndIf;
//	
//	// Update status for ГруппаНомеров
//	If pRoom.СтатусНомера <> pRoomStatus Тогда
//		vRoomObj = pRoom.GetObject();
//		vRoomObj.Read();
//		vRoomObj.СтатусНомера = pRoomStatus;
//		vRoomObj.Write();
//		
//		// Add record to the ГруппаНомеров status change history
//		vRoomObj.pmWriteToRoomStatusChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь, TrimAll(ReservationStatus) + " - " + TrimAll(Гость) + " - " + String(Ref));
//	EndIf;
//КонецПроцедуры //DoChangeRoomStatus
//
////-----------------------------------------------------------------------------
//Процедура MoveGuests(pCancel, pPostingMode)
//	If ЗначениеЗаполнено(Гость) Тогда
//		vDoWrite = False;
//		vGuestObj = Неопределено;
//		If ЗначениеЗаполнено(ReservationStatus) Тогда
//			If ReservationStatus.IsActive Тогда
//				If Гость.Parent <> Справочники.Clients.ReservedGuests And 
//				   Гость.Parent <> Справочники.Clients.BlackListPersons And
//				   Гость.Parent <> Справочники.Clients.CheckedInGuests Тогда
//					vGuestObj = Гость.GetObject();
//					vGuestObj.Read();
//					vGuestObj.Parent = Справочники.Clients.ReservedGuests;
//					vDoWrite = True;
//				EndIf;
//			EndIf;
//		EndIf;
//		If НЕ IsBlankString(Phone) And IsBlankString(Гость.Телефон) Тогда
//			If НЕ vDoWrite Тогда
//				vGuestObj = Гость.GetObject();
//				vGuestObj.Read();
//			EndIf;
//			vGuestObj.Телефон = TrimAll(Phone);
//			vDoWrite = True;
//		EndIf;
//		If НЕ IsBlankString(Fax) And IsBlankString(Гость.Fax) Тогда
//			If НЕ vDoWrite Тогда
//				vGuestObj = Гость.GetObject();
//				vGuestObj.Read();
//			EndIf;
//			vGuestObj.Fax = TrimAll(Fax);
//			vDoWrite = True;
//		EndIf;
//		If НЕ IsBlankString(EMail) And IsBlankString(Гость.EMail) Тогда
//			If НЕ vDoWrite Тогда
//				vGuestObj = Гость.GetObject();
//				vGuestObj.Read();
//			EndIf;
//			vGuestObj.EMail = TrimAll(EMail);
//			vDoWrite = True;
//		EndIf;
//		If vDoWrite Тогда
//			vGuestObj.Write();
//			vGuestObj.pmWriteToClientChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//		EndIf;
//	EndIf;
//КонецПроцедуры //MoveGuests
//
////-----------------------------------------------------------------------------
//Процедура SetReservedStatusForSpareRooms()
//	If Rooms.Count() > 0 Тогда
//		// Calculate initial number of rooms to reserve
//		vRoomsReserved = ?(NumberOfBedsPerRoom > 0, NumberOfBeds/NumberOfBedsPerRoom, 0);
//		If vRoomsReserved > 0 Тогда
//			If Int(vRoomsReserved) <> vRoomsReserved Тогда
//				vRoomsReserved = Int(vRoomsReserved) + 1;
//			EndIf;
//			If Rooms.Count() > vRoomsReserved Тогда
//				// There are spare rooms
//				i = Rooms.Count();
//				While i > vRoomsReserved And i > 0 Do
//					vRoom = Rooms.Get(i - 1).НомерРазмещения;
//					If ЗначениеЗаполнено(vRoom) Тогда
//						If vRoom.СтатусНомера <> Гостиница.ReservedRoomStatus Тогда
//							If RoomsWithReservedStatus.FindByValue(vRoom) = Неопределено Тогда
//								RoomsWithReservedStatus.Add(vRoom);
//								DoChangeRoomStatus(Гостиница.ReservedRoomStatus, vRoom);
//							EndIf;
//						EndIf;
//					EndIf;
//					i = i - 1;
//				EndDo;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //SetReservedStatusForSpareRooms
//
////-----------------------------------------------------------------------------
//Процедура ClearReservedStatusFromRooms()
//	// Build list of rooms to process
//	vRooms = New СписокЗначений();
//	If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		vRooms.Add(ГруппаНомеров);
//	EndIf;
//	If Rooms.Count() > 0 Тогда
//		For Each vRoomsRow In Rooms Do
//			If ЗначениеЗаполнено(vRoomsRow.ГруппаНомеров) Тогда
//				If vRooms.FindByValue(vRoomsRow.ГруппаНомеров) = Неопределено Тогда
//					vRooms.Add(vRoomsRow.ГруппаНомеров);
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Process rooms
//	If vRooms.Count() > 0 Тогда
//		For Each vRoomsItem In vRooms Do
//			vRoom = vRoomsItem.Value;
//			If vRoom.СтатусНомера = Гостиница.ReservedRoomStatus Тогда
//				// Retrieve ГруппаНомеров's previous status
//				vRoomObj = vRoom.GetObject();
//				vRoomStates = vRoomObj.pmGetRoomStatusHistoryState(CurrentDate(), vRoom.СтатусНомера);
//				If vRoomStates.Count() > 0 Тогда
//					vRoomStatesRow = vRoomStates.Get(0);
//					// If previous ГруппаНомеров status is occupied or is vacant then check if there any in-house guests in the ГруппаНомеров
//					If vRoomStatesRow.СтатусНомера = Гостиница.OccupiedRoomStatus Тогда
//						vInHouseGuests = vRoomObj.pmGetInHouseGuests();
//						If vInHouseGuests.Count() > 0 Тогда
//							DoChangeRoomStatus(vRoomStatesRow.СтатусНомера, vRoom);
//						Else
//							// Set ГруппаНомеров status to the ГруппаНомеров status after check-out
//							DoChangeRoomStatus(Гостиница.RoomStatusAfterCheckOut, vRoom);
//						EndIf;
//					ElsIf vRoomStatesRow.СтатусНомера = Гостиница.VacantRoomStatus Тогда
//						vInHouseGuests = vRoomObj.pmGetInHouseGuests();
//						If vInHouseGuests.Count() = 0 Тогда
//							DoChangeRoomStatus(vRoomStatesRow.СтатусНомера, vRoom);
//						Else
//							// Set ГруппаНомеров status to the occupied
//							DoChangeRoomStatus(Гостиница.OccupiedRoomStatus, vRoom);
//						EndIf;
//					Else
//						DoChangeRoomStatus(vRoomStatesRow.СтатусНомера, vRoom);
//					EndIf;
//				Else
//					// Set ГруппаНомеров status to the vacant ГруппаНомеров status
//					DoChangeRoomStatus(Гостиница.VacantRoomStatus, vRoom);
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //ClearReservedStatusFromRooms
//
////-----------------------------------------------------------------------------
//Function pmGetReservationHistoryState(pPeriod) Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	*
//	|FROM
//	|	InformationRegister.ReservationChangeHistory.SliceLast(&qPeriod, Reservation = &qReservation) AS AccommodationChangeHistorySliceLast";
//	vQry.SetParameter("qPeriod", pPeriod);
//	vQry.SetParameter("qReservation", Ref);
//	vResStates = vQry.Execute().Unload();
//	Return vResStates;
//EndFunction //pmGetReservationHistoryState
//
////-----------------------------------------------------------------------------
//Процедура ClearReservedStatusFromOldRooms()
//	// Build list of current rooms
//	vNewRooms = New СписокЗначений();
//	If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		vNewRooms.Add(ГруппаНомеров);
//	Else
//		If Rooms.Count() > 0 Тогда
//			For Each vRoomsRow In Rooms Do
//				If ЗначениеЗаполнено(vRoomsRow.ГруппаНомеров) Тогда
//					If vNewRooms.FindByValue(vRoomsRow.ГруппаНомеров) = Неопределено Тогда
//						vNewRooms.Add(vRoomsRow.ГруппаНомеров);
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	// Retrieve document previous state
//	vPrevResStates = pmGetReservationHistoryState(CurrentDate());
//	If vPrevResStates.Count() > 0 Тогда
//		vPrevResStatesRow = vPrevResStates.Get(0);
//		// Get rooms that were in the previous document state but not in the current document state
//		vPrevRooms = New СписокЗначений();
//		If ЗначениеЗаполнено(vPrevResStatesRow.НомерРазмещения) Тогда
//			If vNewRooms.FindByValue(vPrevResStatesRow.НомерРазмещения) = Неопределено Тогда
//				vPrevRooms.Add(vPrevResStatesRow.НомерРазмещения);
//			EndIf;
//		EndIf;
//		vPrevRoomsTab = vPrevResStatesRow.НомернойФонд.Get();
//		If vPrevRoomsTab <> Неопределено Тогда
//			If vPrevRoomsTab.Count() > 0 Тогда
//				For Each vPrevRoomsTabRow In vPrevRoomsTab Do
//					If ЗначениеЗаполнено(vPrevRoomsTabRow.НомерРазмещения) Тогда
//						If vNewRooms.FindByValue(vPrevRoomsTabRow.НомерРазмещения) = Неопределено Тогда
//							If vPrevRooms.FindByValue(vPrevRoomsTabRow.НомерРазмещения) = Неопределено Тогда
//								vPrevRooms.Add(vPrevRoomsTabRow.НомерРазмещения);
//							EndIf;
//						EndIf;
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//		// Process previous rooms
//		If vPrevRooms.Count() > 0 Тогда
//			For Each vPrevRoomsItem In vPrevRooms Do
//				vRoom = vPrevRoomsItem.Value;
//				If vRoom.СтатусНомера = Гостиница.ReservedRoomStatus Тогда
//					// Retrieve ГруппаНомеров's previous status
//					vRoomObj = vRoom.GetObject();
//					vRoomStates = vRoomObj.pmGetRoomStatusHistoryState(CurrentDate(), vRoom.СтатусНомера);
//					If vRoomStates.Count() > 0 Тогда
//						vRoomStatesRow = vRoomStates.Get(0);
//						// If previous ГруппаНомеров status is occupied or is vacant then check if there any in-house guests in the ГруппаНомеров
//						If vRoomStatesRow.СтатусНомера = Гостиница.OccupiedRoomStatus Тогда
//							vInHouseGuests = vRoomObj.pmGetInHouseGuests();
//							If vInHouseGuests.Count() > 0 Тогда
//								DoChangeRoomStatus(vRoomStatesRow.СтатусНомера, vRoom);
//							Else
//								// Set ГруппаНомеров status to the ГруппаНомеров status after check-out
//								DoChangeRoomStatus(Гостиница.RoomStatusAfterCheckOut, vRoom);
//							EndIf;
//						ElsIf vRoomStatesRow.СтатусНомера = Гостиница.VacantRoomStatus Тогда
//							vInHouseGuests = vRoomObj.pmGetInHouseGuests();
//							If vInHouseGuests.Count() = 0 Тогда
//								DoChangeRoomStatus(vRoomStatesRow.СтатусНомера, vRoom);
//							Else
//								// Set ГруппаНомеров status to the occupied
//								DoChangeRoomStatus(Гостиница.OccupiedRoomStatus, vRoom);
//							EndIf;
//						Else
//							DoChangeRoomStatus(vRoomStatesRow.СтатусНомера, vRoom);
//						EndIf;
//					Else
//						// Set ГруппаНомеров status to the vacant ГруппаНомеров status
//						DoChangeRoomStatus(Гостиница.VacantRoomStatus, vRoom);
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//КонецПроцедуры //ClearReservedStatusFromOldRooms
//
////-----------------------------------------------------------------------------
//Процедура FillGroupParameters()
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		// Reservation manager
//		vUpdateReservationManager = False;
//		If НЕ ЗначениеЗаполнено(GuestGroup.ReservationManager) And 
//		   ЗначениеЗаполнено(ReservationStatus) And (ReservationStatus.IsActive And 
//		   НЕ ReservationStatus.IsCheckIn) Тогда
//			vUpdateReservationManager = True;
//		EndIf;
//		// Контрагент
//		vUpdateCustomer = False;
//		If GuestGroup.OneCustomerPerGuestGroup Тогда
//			If GuestGroup.Контрагент <> Контрагент Тогда
//				vUpdateCustomer = True;
//			EndIf;
//		EndIf;
//		// Client
//		vUpdateClient = False;
//		If ЗначениеЗаполнено(Гость) And НЕ GuestGroup.FixedClient Тогда
//			If НЕ ЗначениеЗаполнено(GuestGroup.Client) Or 
//			   (IsMaster And GuestGroup.Client <> Гость) Or 
//			   ЗначениеЗаполнено(GuestGroup.ClientDoc) And GuestGroup.ClientDoc = Ref Тогда
//				vUpdateClient = True;
//			EndIf;
//		EndIf;
//		// Client document
//		vUpdateClientDoc = False;
//		If НЕ ЗначениеЗаполнено(GuestGroup.ClientDoc) Or 
//		   ЗначениеЗаполнено(GuestGroup.ClientDoc) And TypeOf(GuestGroup.ClientDoc) <> Type("DocumentRef.Размещение") And 
//		   GuestGroup.FixedClient And ЗначениеЗаполнено(GuestGroup.Client) And GuestGroup.Client = Гость Тогда
//			vUpdateClientDoc = True;
//		EndIf;
//		// Group period and number of guests checked-in
//		vUpdatePeriod = False;
//		vUpdateGuestsCheckedIn = False;
//		vGroupParams = cmGetGroupPeriodAndGuestsCheckedIn(GuestGroup);
//		If vGroupParams.Count() > 0 Тогда
//			vGroupParamsRow = vGroupParams.Get(0);
//			If vGroupParamsRow.CheckInDate <> GuestGroup.CheckInDate Or
//			   vGroupParamsRow.ДатаВыезда <> GuestGroup.CheckOutDate Тогда
//				vUpdatePeriod = True;
//			EndIf;
//			If vGroupParamsRow.ЗаездГостей <> GuestGroup.GuestsCheckedIn Тогда
//				vUpdateGuestsCheckedIn = True;
//			EndIf;
//		EndIf;
//		// Group check date
//		vCheckDate = '00010101';
//		vUpdateCheckDate = False;
//		If НЕ ЗначениеЗаполнено(GuestGroup.CheckDate) Тогда
//			If ЗначениеЗаполнено(Contract) And (Contract.DaysBeforeCheckIn <> 0 Or Contract.DaysAfterReservation <> 0) Тогда
//				vUpdateCheckDate = True;
//				If Contract.DaysBeforeCheckIn <> 0 And ЗначениеЗаполнено(CheckInDate) Тогда
//					vCheckDate = BegOfDay(CheckInDate) - 24*3600*Contract.DaysBeforeCheckIn;
//				ElsIf Contract.DaysAfterReservation <> 0 And ЗначениеЗаполнено(Date) Тогда
//					vCheckDate = cmAddWorkingDays(BegOfDay(Date), (Contract.DaysAfterReservation + 1));
//				EndIf;
//			ElsIf ЗначениеЗаполнено(Контрагент) And (Контрагент.DaysBeforeCheckIn <> 0 Or Контрагент.DaysAfterReservation <> 0) Тогда
//				vUpdateCheckDate = True;
//				If Контрагент.DaysBeforeCheckIn <> 0 And ЗначениеЗаполнено(CheckInDate) Тогда
//					vCheckDate = BegOfDay(CheckInDate) - 24*3600*Контрагент.DaysBeforeCheckIn;
//				ElsIf Контрагент.DaysAfterReservation <> 0 And ЗначениеЗаполнено(Date) Тогда
//					vCheckDate = cmAddWorkingDays(BegOfDay(Date), (Контрагент.DaysAfterReservation + 1));
//				EndIf;
//			ElsIf ЗначениеЗаполнено(Гостиница) And (Гостиница.DaysBeforeCheckIn <> 0 Or Гостиница.DaysAfterReservation <> 0) Тогда
//				vUpdateCheckDate = True;
//				If Гостиница.DaysBeforeCheckIn <> 0 And ЗначениеЗаполнено(CheckInDate) Тогда
//					vCheckDate = BegOfDay(CheckInDate) - 24*3600*Гостиница.DaysBeforeCheckIn;
//				ElsIf Гостиница.DaysAfterReservation <> 0 And ЗначениеЗаполнено(Date) Тогда
//					vCheckDate = cmAddWorkingDays(BegOfDay(Date), (Гостиница.DaysAfterReservation + 1));
//				EndIf;
//			EndIf;
//		EndIf;
//		// Group status
//		vUpdateGroupStatus = False;
//		vGuestGroupStatus = cmGetGuestGroupStatus(GuestGroup);
//		If GuestGroup.Status <> vGuestGroupStatus Тогда
//			vUpdateGroupStatus = True;
//		EndIf;
//		// Update guest group params
//		If vUpdateReservationManager Or vUpdateCustomer Or vUpdateClient Or vUpdateClientDoc Or vUpdatePeriod Or vUpdateGuestsCheckedIn Or vUpdateGroupStatus Тогда
//			vGroupObj = GuestGroup.GetObject();
//			vGroupObj.Read();
//			If vUpdateReservationManager Тогда
//				vGroupObj.ReservationManager = ПараметрыСеанса.ТекПользователь;
//			EndIf;
//			If vUpdateCustomer Тогда
//				vGroupObj.Контрагент = Контрагент;
//			EndIf;
//			If vUpdateClient Тогда
//				vGroupObj.Клиент = Гость;
//				vGroupObj.ClientDoc = Ref;
//			ElsIf vUpdateClientDoc Тогда
//				vGroupObj.ClientDoc = Ref;
//			EndIf;
//			If vUpdatePeriod Тогда
//				vGroupObj.CheckInDate = vGroupParamsRow.CheckInDate;
//				vGroupObj.ДатаВыезда = vGroupParamsRow.ДатаВыезда;
//				vGroupObj.Продолжительность = cmCalculateDuration(Тариф, vGroupObj.CheckInDate, vGroupObj.ДатаВыезда);
//			EndIf;
//			If vUpdateGuestsCheckedIn Тогда
//				vGroupObj.ЗаездГостей = vGroupParamsRow.ЗаездГостей;
//			EndIf;
//			If vUpdateCheckDate And ЗначениеЗаполнено(vCheckDate) Тогда
//				vGroupObj.CheckDate = vCheckDate;
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
//Процедура pmUpdateHotelProductData() Экспорт
//	If ЗначениеЗаполнено(HotelProduct) Тогда
//		// We'll try to update hotel product sum and period here
//		vHPSum = 0;
//		vHPCurrency = Неопределено;
//		If ЗначениеЗаполнено(HotelProduct) Тогда
//			vHPCurrency = HotelProduct.Currency;
//		EndIf;
//		// We have to group all amounts by currencies
//		vSrv = Services.Unload(, "Услуга, Сумма, СуммаСкидки, ВалютаЛицСчета");
//		i = 0;
//		While i < vSrv.Count() Do
//			vSrvRow = vSrv.Get(i);
//			If НЕ ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//				vSrv.Delete(i);
//				Continue;
//			Else
//				If НЕ vSrvRow.Услуга.IsHotelProductService Тогда
//					vSrv.Delete(i);
//					Continue;
//				EndIf;
//			EndIf;
//			i = i + 1;
//		EndDo;
//		vSrv.GroupBy("ВалютаЛицСчета", "Сумма, СуммаСкидки");
//		For Each vTotal In vSrv Do
//			If vHPCurrency = vTotal.FolioCurrency Тогда
//				vHPSum = vHPSum + vTotal.Sum - vTotal.DiscountSum;
//			Else
//				vHPCurrency = Неопределено;
//			EndIf;
//		EndDo;
//		// Get hotel product payment date and payment method
//		vPaymentDate = Неопределено;
//		vPaymentMethod = Неопределено;
//		If НЕ ЗначениеЗаполнено(HotelProduct.PaymentDate) Тогда
//			vPaymentDate = HotelProduct.GetObject().pmGetHotelProductPaymentDate(vPaymentMethod);
//		EndIf;
//		// Update hotel product parameters
//		vUpdateSum = False;
//		vUpdatePeriod = False;
//		vUpdatePaymentDate = False;
//		vUpdateClient = False;
//		If ЗначениеЗаполнено(ReservationStatus) And ReservationStatus.IsActive And RoomQuantity = 1 Тогда
//			If ЗначениеЗаполнено(vHPCurrency) And vHPSum > 0 And HotelProduct.Sum <> vHPSum And 
//			   НЕ HotelProduct.FixProductCost Тогда
//				vUpdateSum = True;
//			EndIf;
//			If (CheckInDate <> HotelProduct.CheckInDate Or CheckOutDate <> HotelProduct.CheckOutDate) And 
//			   НЕ HotelProduct.FixProductPeriod And НЕ HotelProduct.FixPlannedPeriod Тогда
//				vUpdatePeriod = True;
//			EndIf;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(HotelProduct.PaymentDate) And ЗначениеЗаполнено(vPaymentDate) Тогда
//			vUpdatePaymentDate = True;
//		EndIf;
//		vClient = Неопределено;
//		If НЕ HotelProduct.FixedClient Тогда
//			vClient = HotelProduct.GetObject().pmGetHotelProductClient();
//			If ЗначениеЗаполнено(vClient) And vClient <> HotelProduct.Client Тогда
//				vUpdateClient = True;
//			EndIf;
//		EndIf;
//		If vUpdateSum Or vUpdatePeriod Or vUpdatePaymentDate Or vUpdateClient Тогда
//			Try
//				vHPObj = HotelProduct.GetObject();
//				vHPObj.Read();
//				If vUpdateSum Тогда
//					vHPObj.Сумма = vHPSum;
//				EndIf;
//				If vUpdatePeriod Тогда
//					vHPObj.CheckInDate = CheckInDate;
//					vHPObj.Продолжительность = Duration;
//					vHPObj.ДатаВыезда = CheckOutDate;
//				EndIf;
//				If vUpdatePaymentDate Тогда
//					vHPObj.PaymentDate = vPaymentDate;
//					If ЗначениеЗаполнено(vPaymentMethod) Тогда
//						vHPObj.СпособОплаты = vPaymentMethod;
//					EndIf;
//				EndIf;
//				If vUpdateClient Тогда
//					Client = vClient;
//				EndIf;
//				vHPObj.Write();
//			Except
//			EndTry;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmUpdateHotelProductData
//
////-----------------------------------------------------------------------------
//Процедура ClearInventoryRecordsForIntersectedDocs(pIntersectedDocs)
//	For Each vIntersectedDocsRow In pIntersectedDocs Do
//		vDocObj = vIntersectedDocsRow.Ref.GetObject();
//		vDocObj.pmClearInventoryRegisterRecords();
//		vIntersectedDocsRow.DocObj = vDocObj;
//	EndDo;
//КонецПроцедуры //ClearInventoryRecordsForIntersectedDocs
//
////-----------------------------------------------------------------------------
//Процедура RepostIntersectedDocs(pIntersectedDocs, pPeriodsRow, pMode = 0)
//	For Each vIntersectedDocsRow In pIntersectedDocs Do
//		vDocObj = vIntersectedDocsRow.DocObj;
//		// Build value table of accommodation periods
//		vPeriods = vDocObj.pmGetAccommodationPeriods();
//		// Process each accommodation period separately
//		For Each vPeriodsRow In vPeriods Do
//			If pMode = 1 And cm1SecondShift(vPeriodsRow.CheckInDate) > cm1SecondShift(pPeriodsRow.CheckInDate) Тогда
//				Continue;
//			ElsIf pMode = 2 And cm1SecondShift(vPeriodsRow.CheckInDate) <= cm1SecondShift(pPeriodsRow.CheckInDate) Тогда
//				Continue;
//			EndIf;
//			vDocObj.pmPostToInventoryRegisters(vPeriodsRow, False);
//		EndDo;
//	EndDo;
//КонецПроцедуры //RepostIntersectedDocs
//
////-----------------------------------------------------------------------------
//Процедура FillPeriodsRowWithDefaultValues(pPeriodsRow)
//	pPeriodsRow.Ref = Ref;
//	pPeriodsRow.Гостиница = Гостиница;
//	pPeriodsRow.КвотаНомеров = RoomQuota;
//	pPeriodsRow.CheckInDate = CheckInDate;
//	pPeriodsRow.ДатаВыезда = CheckOutDate;
//	pPeriodsRow.ТипНомера = RoomType;
//	pPeriodsRow.НомерРазмещения = ГруппаНомеров;
//	pPeriodsRow.ВидРазмещения = AccommodationType;
//	pPeriodsRow.Тариф = Тариф;
//	pPeriodsRow.КоличествоМестНомер = NumberOfBedsPerRoom;
//	pPeriodsRow.КоличествоГостейНомер = NumberOfPersonsPerRoom;
//	pPeriodsRow.КоличествоЧеловек = NumberOfPersons;
//	pPeriodsRow.КоличествоНомеров = NumberOfRooms;
//	pPeriodsRow.КоличествоМест = NumberOfBeds;
//	pPeriodsRow.КолДопМест = NumberOfAdditionalBeds;
//	pPeriodsRow.УчетнаяДата = BegOfDay(CheckInDate);
//КонецПроцедуры //FillPeriodsRowWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура UpdatePeriodsRow(pPeriods, pPeriodsRow, pRRRow)
//	vPrevPeriodsRow = pPeriodsRow;
//	vPeriodsRowIndex = pPeriods.IndexOf(pPeriodsRow);
//	If vPeriodsRowIndex > 0 Тогда
//		vPrevPeriodsRow = pPeriods.Get(vPeriodsRowIndex - 1);
//	EndIf;
//	If ЗначениеЗаполнено(pRRRow.ТипНомера) And pRRRow.ТипНомера <> vPrevPeriodsRow.ТипНомера Or
//	   ЗначениеЗаполнено(pRRRow.НомерРазмещения) And pRRRow.НомерРазмещения <> vPrevPeriodsRow.НомерРазмещения Or
//	   ЗначениеЗаполнено(pRRRow.ВидРазмещения) And pRRRow.ВидРазмещения <> vPrevPeriodsRow.ВидРазмещения Or
//	   ЗначениеЗаполнено(pRRRow.Тариф) And pRRRow.Тариф <> vPrevPeriodsRow.Тариф Тогда
//		If ЗначениеЗаполнено(pRRRow.ТипНомера) Тогда
//			pPeriodsRow.ТипНомера = pRRRow.ТипНомера;
//		Else
//			pPeriodsRow.ТипНомера = vPrevPeriodsRow.ТипНомера;
//		EndIf;
//		If ЗначениеЗаполнено(pRRRow.НомерРазмещения) Тогда
//			pPeriodsRow.НомерРазмещения = pRRRow.НомерРазмещения;
//		Else
//			pPeriodsRow.НомерРазмещения = vPrevPeriodsRow.НомерРазмещения;
//		EndIf;
//		If ЗначениеЗаполнено(pRRRow.ВидРазмещения) Тогда
//			pPeriodsRow.ВидРазмещения = pRRRow.ВидРазмещения;
//		Else
//			pPeriodsRow.ВидРазмещения = vPrevPeriodsRow.ВидРазмещения;
//		EndIf;
//		If ЗначениеЗаполнено(pRRRow.Тариф) Тогда
//			pPeriodsRow.Тариф = pRRRow.Тариф;
//		Else
//			pPeriodsRow.Тариф = vPrevPeriodsRow.Тариф;
//		EndIf;
//		// Retrieve ГруппаНомеров resources
//		If ЗначениеЗаполнено(pPeriodsRow.НомерРазмещения) Тогда
//			vRoomObj = pPeriodsRow.НомерРазмещения.GetObject();
//			vRoomAttr = vRoomObj.pmGetRoomAttributes(cm1SecondShift(pPeriodsRow.CheckInDate));
//			For Each vRoomAttrRow In vRoomAttr Do
//				pPeriodsRow.КоличествоМестНомер = vRoomAttrRow.КоличествоМестНомер;
//				pPeriodsRow.КоличествоГостейНомер = vRoomAttrRow.КоличествоГостейНомер;
//				pPeriodsRow.ТипНомера = vRoomAttrRow.ТипНомера;
//				Break;
//			EndDo;
//		ElsIf ЗначениеЗаполнено(pPeriodsRow.ТипНомера) Тогда
//			pPeriodsRow.КоличествоМестНомер = pPeriodsRow.ТипНомера.КоличествоМестНомер;
//			pPeriodsRow.КоличествоГостейНомер = pPeriodsRow.ТипНомера.КоличествоГостейНомер;
//		EndIf;
//		// Calculate resources
//		cmCalculateResources(pPeriodsRow.CheckInDate, pPeriodsRow.ТипНомера, pPeriodsRow.ВидРазмещения,
//							 pPeriodsRow.НомерРазмещения, 1, pPeriodsRow.КоличествоНомеров,
//							 pPeriodsRow.КоличествоМест, pPeriodsRow.КолДопМест, pPeriodsRow.КоличествоЧеловек, 
//							 pPeriodsRow.КоличествоМестНомер, pPeriodsRow.КоличествоГостейНомер);
//	EndIf;
//	// Update accounting date
//	pPeriodsRow.УчетнаяДата = BegOfDay(pPeriodsRow.CheckinDate);
//КонецПроцедуры //UpdatePeriodsRow
//
////-----------------------------------------------------------------------------
//Function pmGetAccommodationPeriods() Экспорт
//	// Create value table of accommodation periods
//	vPeriods = New ValueTable();
//	vPeriods.Columns.Add("Ref", cmGetDocumentTypeDescription("Reservation"));
//	vPeriods.Columns.Add("Гостиница", cmGetCatalogTypeDescription("Гостиницы"));
//	vPeriods.Columns.Add("КвотаНомеров", cmGetCatalogTypeDescription("КвотаНомеров"));
//	vPeriods.Columns.Add("CheckInDate", cmGetDateTimeTypeDescription());
//	vPeriods.Columns.Add("ДатаВыезда", cmGetDateTimeTypeDescription());
//	vPeriods.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//	vPeriods.Columns.Add("НомерРазмещения", cmGetCatalogTypeDescription("НомернойФонд"));
//	vPeriods.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
//	vPeriods.Columns.Add("Тариф", cmGetCatalogTypeDescription("Тарифы"));
//	vPeriods.Columns.Add("КоличествоМестНомер", cmGetNumberTypeDescription(6, 0));
//	vPeriods.Columns.Add("КоличествоГостейНомер", cmGetNumberTypeDescription(6, 0));
//	vPeriods.Columns.Add("КоличествоЧеловек", cmGetNumberTypeDescription(6, 0));
//	vPeriods.Columns.Add("КоличествоНомеров", cmGetNumberTypeDescription(6, 0));
//	vPeriods.Columns.Add("КоличествоМест", cmGetNumberTypeDescription(6, 0));
//	vPeriods.Columns.Add("КолДопМест", cmGetNumberTypeDescription(6, 0));
//	vPeriods.Columns.Add("IsRoomChange", cmGetBooleanTypeDescription());
//	vPeriods.Columns.Add("УчетнаяДата", cmGetDateTimeTypeDescription());
//	// Unload and sort ГруппаНомеров rates rows
//	vRoomRates = RoomRates.Unload();
//	vRoomRates.Sort("УчетнаяДата, ChangeTime");
//	// Fill value table of accommodation periods
//	vPeriodsRow = Неопределено;
//	If vRoomRates.Count() = 0 Тогда
//		vPeriodsRow = vPeriods.Add();
//		FillPeriodsRowWithDefaultValues(vPeriodsRow);
//	Else
//		For Each vRRRow In vRoomRates Do
//			If НЕ ЗначениеЗаполнено(vRRRow.AccountingDate) Or 
//			   BegOfDay(CheckInDate) > BegOfDay(vRRRow.AccountingDate) Or
//			   BegOfDay(CheckOutDate) <= BegOfDay(vRRRow.AccountingDate) Тогда
//				Continue;
//			EndIf;
//			If ЗначениеЗаполнено(vRRRow.RoomType) Or 
//			   ЗначениеЗаполнено(vRRRow.ГруппаНомеров) Or 
//			   ЗначениеЗаполнено(vRRRow.AccommodationType) Тогда 
//				If vPeriodsRow = Неопределено Тогда
//					vPeriodsRow = vPeriods.Add();
//					FillPeriodsRowWithDefaultValues(vPeriodsRow);
//					If BegOfDay(vRRRow.AccountingDate) > BegOfDay(CheckInDate) Тогда
//						If ЗначениеЗаполнено(vRRRow.ChangeTime) Тогда
//							vPeriodsRow.ДатаВыезда = cm0SecondShift(BegOfDay(vRRRow.AccountingDate) + (vRRRow.ChangeTime - BegOfDay(vRRRow.ChangeTime)));
//						Else
//							vPeriodsRow.ДатаВыезда = cmMovePeriodToToReferenceHour(vRRRow.AccountingDate, ?(ЗначениеЗаполнено(vRRRow.Тариф), vRRRow.Тариф, Тариф));
//						EndIf;
//						// Add new row
//						vPeriodsRow = vPeriods.Add();
//						FillPeriodsRowWithDefaultValues(vPeriodsRow);
//						If ЗначениеЗаполнено(vRRRow.ChangeTime) Тогда
//							vPeriodsRow.CheckInDate = cm1SecondShift(BegOfDay(vRRRow.AccountingDate) + (vRRRow.ChangeTime - BegOfDay(vRRRow.ChangeTime)));
//						Else
//							vPeriodsRow.CheckInDate = cmMovePeriodFromToReferenceHour(vRRRow.AccountingDate, ?(ЗначениеЗаполнено(vRRRow.Тариф), vRRRow.Тариф, Тариф));
//						EndIf;
//						vPeriodsRow.IsRoomChange = True;
//					EndIf;
//					If cmMovePeriodToToReferenceHour((vRRRow.AccountingDate + 24*3600), ?(ЗначениеЗаполнено(vRRRow.Тариф), vRRRow.Тариф, Тариф)) < CheckOutDate Тогда
//						If ЗначениеЗаполнено(vRRRow.ChangeTime) Тогда
//							vPeriodsRow.ДатаВыезда = cm0SecondShift(BegOfDay(vRRRow.AccountingDate + 24*3600) + (vRRRow.ChangeTime - BegOfDay(vRRRow.ChangeTime)));
//						Else
//							vPeriodsRow.ДатаВыезда = cmMovePeriodToToReferenceHour((vRRRow.AccountingDate + 24*3600), ?(ЗначениеЗаполнено(vRRRow.Тариф), vRRRow.Тариф, Тариф));
//						EndIf;
//					EndIf;
//					UpdatePeriodsRow(vPeriods, vPeriodsRow, vRRRow);
//				ElsIf ЗначениеЗаполнено(vRRRow.RoomType) And vRRRow.RoomType <> vPeriodsRow.ТипНомера Or 
//				      ЗначениеЗаполнено(vRRRow.ГруппаНомеров) And vRRRow.ГруппаНомеров <> vPeriodsRow.НомерРазмещения Or 
//				      ЗначениеЗаполнено(vRRRow.AccommodationType) And vRRRow.AccommodationType <> vPeriodsRow.ВидРазмещения Тогда
//					vPeriodCheckOutDate = Неопределено;
//					If ЗначениеЗаполнено(vRRRow.ChangeTime) Тогда
//						vPeriodCheckOutDate = cm0SecondShift(BegOfDay(vRRRow.AccountingDate) + (vRRRow.ChangeTime - BegOfDay(vRRRow.ChangeTime)));
//					Else
//						vPeriodCheckOutDate = cmMovePeriodToToReferenceHour(vRRRow.AccountingDate, vPeriodsRow.Тариф);
//					EndIf;
//					If vPeriodCheckOutDate < CheckOutDate Тогда
//						vPeriodsRow.ДатаВыезда = vPeriodCheckOutDate;
//						// Add new row
//						vPeriodsRow = vPeriods.Add();
//						FillPeriodsRowWithDefaultValues(vPeriodsRow);
//						If ЗначениеЗаполнено(vRRRow.ChangeTime) Тогда
//							vPeriodsRow.CheckInDate = cm1SecondShift(BegOfDay(vRRRow.AccountingDate) + (vRRRow.ChangeTime - BegOfDay(vRRRow.ChangeTime)));
//						Else
//							vPeriodsRow.CheckInDate = cmMovePeriodFromToReferenceHour(vRRRow.AccountingDate, ?(ЗначениеЗаполнено(vRRRow.Тариф), vRRRow.Тариф, Тариф));
//						EndIf;
//						vPeriodsRow.IsRoomChange = True;
//						UpdatePeriodsRow(vPeriods, vPeriodsRow, vRRRow);
//					Else
//						vPeriodsRow.ДатаВыезда = CheckOutDate;
//					EndIf;
//				Else
//					vPeriodCheckOutDate = Неопределено;
//					If ЗначениеЗаполнено(vRRRow.ChangeTime) Тогда
//						vPeriodCheckOutDate = cm0SecondShift(BegOfDay(vRRRow.AccountingDate + 24*3600) + (vRRRow.ChangeTime - BegOfDay(vRRRow.ChangeTime)));
//					Else
//						vPeriodCheckOutDate = cmMovePeriodToToReferenceHour((vRRRow.AccountingDate + 24*3600), vPeriodsRow.Тариф);
//					EndIf;
//					If vPeriodCheckOutDate < CheckOutDate Тогда
//						vPeriodsRow.ДатаВыезда = vPeriodCheckOutDate;
//					Else
//						vPeriodsRow.ДатаВыезда = CheckOutDate;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//		If vPeriods.Count() = 0 Тогда
//			vPeriodsRow = vPeriods.Add();
//			FillPeriodsRowWithDefaultValues(vPeriodsRow);
//		Else
//			vLastPeriodsRow = vPeriods.Get(vPeriods.Count() - 1);
//			If vLastPeriodsRow.ДатаВыезда < CheckOutDate Тогда
//				vLastPeriodsRow.ДатаВыезда = CheckOutDate;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check resulting periods
//	i = 0; 
//	While i < vPeriods.Count() Do
//		vPeriodsRow = vPeriods.Get(i);
//		If vPeriodsRow.CheckInDate >= vPeriodsRow.ДатаВыезда Тогда
//			vPeriods.Delete(i);
//		Else
//			i = i + 1;
//		EndIf;
//	EndDo;
//	Return vPeriods;
//EndFunction //pmGetAccommodationPeriods 
//
////-----------------------------------------------------------------------------
//Function pmGetAccommodationPlan() Экспорт
//	// Unload and sort ГруппаНомеров rates rows
//	vRoomRates = RoomRates.Unload();
//	vRoomRates.Sort("УчетнаяДата, ChangeTime");
//	// Do for each date in accommodation period
//	vRRRow = Неопределено;
//	vPrevRRRow = Неопределено;
//	vCurDate = BegOfDay(CheckInDate);
//	While vCurDate <= BegOfDay(CheckOutDate) Do
//		vRRRow = vRoomRates.Find(vCurDate, "УчетнаяДата");
//		If vRRRow = Неопределено Тогда
//			vRRRow = vRoomRates.Add();
//			vRRRow.УчетнаяДата = vCurDate;
//		EndIf;
//		If vPrevRRRow <> Неопределено Тогда
//			If НЕ ЗначениеЗаполнено(vRRRow.Тариф) Тогда
//				vRRRow.Тариф = vPrevRRRow.Тариф;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vRRRow.ВидРазмещения) Тогда
//				vRRRow.ВидРазмещения = vPrevRRRow.ВидРазмещения;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vRRRow.ТипНомера) Тогда
//				vRRRow.ТипНомера = vPrevRRRow.ТипНомера;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vRRRow.НомерРазмещения) Тогда
//				vRRRow.НомерРазмещения = vPrevRRRow.НомерРазмещения;
//			EndIf;
//			If IsBlankString(vRRRow.Скидка) Тогда
//				vRRRow.Скидка = vPrevRRRow.Скидка;
//			EndIf;
//			If IsBlankString(vRRRow.КомиссияАгента) Тогда
//				vRRRow.КомиссияАгента = vPrevRRRow.КомиссияАгента;
//			EndIf;
//		Else
//			If НЕ ЗначениеЗаполнено(vRRRow.Тариф) Тогда
//				vRRRow.Тариф = Тариф;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vRRRow.ВидРазмещения) Тогда
//				vRRRow.ВидРазмещения = AccommodationType;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vRRRow.ТипНомера) Тогда
//				vRRRow.ТипНомера = RoomType;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vRRRow.НомерРазмещения) Тогда
//				vRRRow.НомерРазмещения = ГруппаНомеров;
//			EndIf;
//			If IsBlankString(vRRRow.Скидка) Тогда
//				vRRRow.Скидка = "";
//			EndIf;
//			If IsBlankString(vRRRow.КомиссияАгента) Тогда
//				vRRRow.КомиссияАгента = Format(AgentCommission, "ND=6; NFD=2; NDS=.; NZ=; NG=");
//			EndIf;
//		EndIf;
//		vPrevRRRow = vRRRow;
//		vCurDate = vCurDate + 24*3600;
//	EndDo;
//	vRoomRates.Sort("УчетнаяДата, ChangeTime");
//	Return vRoomRates;
//EndFunction //pmGetAccommodationPlan 
//
////-----------------------------------------------------------------------------
//Процедура AddDataLocks(pPeriodsRow)
//	// Add data locks
//	vDataLock = New DataLock();
//	// ГруппаНомеров inventory
//	vRIItem = vDataLock.Add("AccumulationRegister.ЗагрузкаНомеров");
//	vRIItem.Mode = DataLockMode.Exclusive;
//	vRIItem.SetValue("ТипНомера", pPeriodsRow.ТипНомера);
//	// Lock ГруппаНомеров
//	If ЗначениеЗаполнено(pPeriodsRow.НомерРазмещения) Тогда
//		vRIItem.SetValue("НомерРазмещения", pPeriodsRow.НомерРазмещения);
//	EndIf;
//	vRIItem.SetValue("Period", New Range(cm1SecondShift(pPeriodsRow.CheckInDate), cm0SecondShift(pPeriodsRow.ДатаВыезда)));
//	// ГруппаНомеров quota sales
//	If ЗначениеЗаполнено(RoomQuota) Тогда
//		vRQSItem = vDataLock.Add("AccumulationRegister.ПродажиКвот");
//		vRQSItem.Mode = DataLockMode.Exclusive;
//		vRQSItem.SetValue("ТипНомера", pPeriodsRow.ТипНомера);
//		vRQSItem.SetValue("Period", New Range(cm1SecondShift(pPeriodsRow.CheckInDate), cm0SecondShift(pPeriodsRow.ДатаВыезда)));
//	EndIf;
//	// Set all locks
//	i = 0;
//	While i < 2 Do
//		Try
//			vDataLock.Lock();
//			Break;
//		Except
//			If i = 1 Тогда
//				ВызватьИсключение NStr("en='Failed to lock ГруппаНомеров inventory for update! Please retry later...';ru='Другие пользователи выполняют запись в базу данных! Повторите попытку позже...';de='Andere Nutzer führen bereits den Eintrag in die Datenbank aus! Wiederholen Sie den Versuch später…'");
//			EndIf;
//		EndTry;
//		i = i + 1;
//		// Wait for 10 seconds
//		cmWait(10);
//	EndDo;
//КонецПроцедуры //AddDataLocks 
//
////-----------------------------------------------------------------------------
//Function DoRoomInventoryPosting(pCancel) Экспорт
//	Перем vMessage, vAttributeInErr;
//	// Build value table of accommodation periods
//	vPeriods = pmGetAccommodationPeriods();
//	// Process each accommodation period separately
//	For Each vPeriodsRow In vPeriods Do
//		// Check should we repost any intersecting accommodations or reservations
//		vIntersectedDocs = New ValueTable();
//		If vPeriodsRow.КоличествоМест <> 0 Тогда
//			vIntersectedDocs = cmGetTableOfIntersectedDocs(vPeriodsRow);
//		EndIf;
//		// Add data locks
//		AddDataLocks(vPeriodsRow);
//		// Clear register records
//		If vPeriods.IndexOf(vPeriodsRow) = 0 Тогда
//			pmClearInventoryRegisterRecords();
//			pmClearSalesForecastRegisterRecords();
//		EndIf;
//		// Clear ГруппаНомеров inventory movements for all intersected docs
//		If vIntersectedDocs.Count() > 0 Тогда
//			ClearInventoryRecordsForIntersectedDocs(vIntersectedDocs);
//		EndIf;
//		// Repost intersected document prior to the current one 
//		If vIntersectedDocs.Count() > 0 Тогда
//			RepostIntersectedDocs(vIntersectedDocs, vPeriodsRow, 1);
//		EndIf;
//		// Post to registers
//		pmPostToInventoryRegisters(vPeriodsRow, True, pCancel);
//		// Repost intersected document after the current one 
//		If vIntersectedDocs.Count() > 0 And НЕ pCancel Тогда
//			RepostIntersectedDocs(vIntersectedDocs, vPeriodsRow, 2);
//		EndIf;
//		// Check ГруппаНомеров inventory and ГруппаНомеров quota vacant rooms
//		If НЕ pCancel Тогда
//			pCancel	= pmCheckDocumentAttributes(vPeriodsRow, True, vMessage, vAttributeInErr);
//			If pCancel Тогда
//				WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, NStr(vMessage));
//				Message(NStr(vMessage), MessageStatus.Attention);
//				ВызватьИсключение NStr(vMessage);
//			EndIf;
//		EndIf;
//	EndDo;
//EndFunction //DoRoomInventoryPosting 
//
////-----------------------------------------------------------------------------
//Процедура CheckRoomRates()
//	vRRAreChanged = False;
//	i = 0;
//	While i < RoomRates.Count() Do
//		vRRRow = RoomRates.Get(i);
//		If BegOfDay(vRRRow.УчетнаяДата) < BegOfDay(CheckInDate) Or 
//		   BegOfDay(vRRRow.УчетнаяДата) > BegOfDay(CheckOutDate) Тогда
//			RoomRates.Delete(i);
//			vRRAreChanged = True;
//		ElsIf НЕ ЗначениеЗаполнено(vRRRow.ВидРазмещения) And
//		      НЕ ЗначениеЗаполнено(vRRRow.НомерРазмещения) And 
//		      НЕ ЗначениеЗаполнено(vRRRow.ТипНомера) And 
//		      НЕ ЗначениеЗаполнено(vRRRow.Тариф) And 
//		      IsBlankString(vRRRow.Скидка) And 
//		      IsBlankString(vRRRow.КомиссияАгента) Тогда
//			RoomRates.Delete(i);
//			vRRAreChanged = True;
//		Else
//			i = i + 1;
//		EndIf;
//	EndDo;
//	If vRRAreChanged Тогда
//		RoomRates.Sort("УчетнаяДата, ChangeTime");
//	EndIf;
//КонецПроцедуры //CheckRoomRates
//
////-----------------------------------------------------------------------------
//Function pmCheckRoomMainFolios() Экспорт
//	vDoReloadDefault = False;
//	If ЗначениеЗаполнено(AccommodationType) Тогда
//		If AccommodationType.НачислятьНаЛицевойСчет Тогда
//			vRoomMainDoc = GetRoomMainReservation();
//			If ЗначениеЗаполнено(vRoomMainDoc) Тогда
//				For Each vRMCRRow In vRoomMainDoc.ChargingRules Do
//					If НЕ vRMCRRow.IsPersonal And НЕ vRMCRRow.IsTransfer And НЕ vRMCRRow.IsMaster Тогда
//						vRuleIsFound = False;
//						For Each vCRRow In ChargingRules Do
//							If vCRRow.IsTransfer And vRMCRRow.ChargingFolio = vCRRow.ChargingFolio Тогда
//								vRuleIsFound = True;
//								Break;
//							EndIf;
//						EndDo;
//						If vRuleIsFound Тогда
//							vDoReloadDefault = False;
//						Else
//							vDoReloadDefault = True;
//						EndIf;
//						Break;
//					EndIf;
//				EndDo;
//				If vDoReloadDefault Тогда
//					// Load 
//					pmReloadDefaultChargingRules(vRoomMainDoc);
//					// Automatic services list calculation	
//					pmCalculateServices();
//					// Set planned payment method
//					vPayer = pmSetPlannedPaymentMethod();
//				EndIf;
//			EndIf;
//		Else
//			If AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.Кровать Тогда
//				// If all charging rules are transfers to the ГруппаНомеров main folios then cancel this transfer
//				vDoReloadDefault = True;
//				For Each vCRRow In ChargingRules Do
//					If НЕ vCRRow.IsTransfer And НЕ vCRRow.IsMaster And НЕ vCRRow.IsPersonal Тогда
//						vDoReloadDefault = False;
//						Break;
//					EndIf;
//				EndDo;
//				If vDoReloadDefault Тогда
//					// Load 
//					pmLoadDefaultChargingRules();
//					// Automatic services list calculation	
//					pmCalculateServices();
//					// Set planned payment method
//					vPayer = pmSetPlannedPaymentMethod();
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	Return vDoReloadDefault;
//EndFunction //pmCheckRoomMainFolios
//
////-----------------------------------------------------------------------------
//Function pmCheckReservationChains() Экспорт
//	// Try to find previous reservation to be used as parent one
//	vPrevReservation = cmGetPreviousReservation(GuestGroup, CheckInDate, AccommodationType, , Гость);
//	If ЗначениеЗаполнено(vPrevReservation) Тогда
//		If vPrevReservation <> Ref And (vPrevReservation <> ParentDoc Or vPrevReservation = ParentDoc And 
//			                            vPrevReservation.ChargingRules.Count() > 0 And ChargingRules.Count() > 0 And 
//										vPrevReservation.ChargingRules.Get(vPrevReservation.ChargingRules.Count() - 1).ChargingFolio <> ChargingRules.Get(ChargingRules.Count() - 1).ChargingFolio) Тогда
//			cmFillAttributesFromParentDocument(ThisObject, vPrevReservation, True);
//			// Automatic services list calculation	
//			pmCalculateServices();
//			// Set planned payment method
//			vPayer = pmSetPlannedPaymentMethod();
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Тогда
//			ParentDoc = Неопределено;
//			pmLoadDefaultChargingRules();
//			// Automatic services list calculation	
//			pmCalculateServices();
//			// Set planned payment method
//			vPayer = pmSetPlannedPaymentMethod();
//		EndIf;
//	EndIf;
//	// Try to find next reservation and repost it
//	vNextReservation = cmGetNextReservation(GuestGroup, CheckOutDate, AccommodationType, Гость);
//	If ЗначениеЗаполнено(vNextReservation) And vNextReservation.ДокОснование <> Ref And vNextReservation <> Ref Тогда
//		vNextReservation.GetObject().Write(DocumentWriteMode.Posting);
//	EndIf;
//EndFunction //pmCheckReservationChains
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pPostingMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Check if ГруппаНомеров rates are valid
//	CheckRoomRates();
//	// Check charging rules
//	If ЗначениеЗаполнено(ReservationStatus) And RoomQuantity = 1 Тогда
//		If ReservationStatus.IsActive Or ReservationStatus.IsPreliminary Тогда
//			// Check reservation chains
//			If ЗначениеЗаполнено(Гость) Тогда
//				pmCheckReservationChains();
//			EndIf;
//			// Check if we have to rebuild guest folios
//			pmCheckRoomMainFolios();
//		EndIf;
//	EndIf;
//	// Post bound resource reservations
//	If ЗначениеЗаполнено(ReservationStatus) Тогда
//		vResourceReservations = cmGetChildResourceReservations(Ref, False);
//		If НЕ ReservationStatus.IsActive Or ReservationStatus.IsCheckIn Тогда
//			For Each vResourceReservationsRow In vResourceReservations Do
//				vResourceReservationObj = vResourceReservationsRow.Ref.GetObject();
//				If vResourceReservationObj.Posted Тогда
//					vResourceReservationObj.SetDeletionMark(True);
//				EndIf;
//			EndDo;
//		Else
//			vResourceReservationServices = pmGetResourceServices();
//			PostResourceReservations(vResourceReservationServices, vResourceReservations);
//		EndIf;
//	EndIf;
//	// Fill folio parameters
//	If ЗначениеЗаполнено(ReservationStatus) Тогда
//		If ReservationStatus.IsActive Or ReservationStatus.IsCheckIn Or ReservationStatus.IsPreliminary Тогда
//			FillFolioParameters(pCancel);
//		EndIf;
//		SetFolioStatuses(pCancel);
//	EndIf;
//	// Post to expected Контрагент sales. Those records are used to compare charged 
//	// guest group services with planned ones
//	PostToExpectedCustomerSales(pCancel);
//	// Post services if necessary
//	ChargeServices(pCancel, pPostingMode);
//	// Move guests to the appropriate folder
//	MoveGuests(pCancel, pPostingMode);
//	// Change ГруппаНомеров status
//	If ЗначениеЗаполнено(Гостиница.ReservedRoomStatus) Тогда
//		If ReservationStatus.IsActive And 
//		   ReservationStatus.DoRoomStatusChange Тогда
//			SetReservedStatusForSpareRooms();
//		Else
//			ClearReservedStatusFromRooms();
//		EndIf;
//		// Clear reserved status from rooms that were reserved before current document state
//		ClearReservedStatusFromOldRooms();
//	EndIf;
//	// Write document if it was changed
//	If Modified() Тогда
//		Write(DocumentWriteMode.Write);
//	EndIf;
//	// Delete all unused document folios not in charging rules
//	cmDeleteUnusedDocumentFolios(Ref);
//	// Do posting to ГруппаНомеров inventory
//	DoRoomInventoryPosting(pCancel);
//	If pCancel Тогда
//		Return;
//	EndIf;
//	// To the waiting list
//	PostToWaitingList(pCancel);
//	If pCancel Тогда
//		Return;
//	EndIf;
//	// To the expected preliminary groups
//	PostToExpectedGuestGroups(pCancel);
//	If pCancel Тогда
//		Return;
//	EndIf;
//	// Fill head of group guest, group Контрагент, group period and number of guests checked-in
//	FillGroupParameters();
//	// Update hotel product parameters
//	pmUpdateHotelProductData();
//	// Send change document status SMS
//	If StatusHasChanged Тогда
//		StatusHasChanged = False;
//		vMessageDeliveryError = "";
//		//If НЕ SMS.SendChangeDocumentSatusMessage(Ref, vMessageDeliveryError) Тогда
//		//	WriteLogEvent(NStr("en='Document.MessageDelivery';ru='Документ.РассылкаСообщений';de='Document.MessageDelivery'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, vMessageDeliveryError);
//		//	Message(vMessageDeliveryError, MessageStatus.Attention);
//		//EndIf;
//	EndIf;
//	// Switch off automatic write of register records
//	RegisterRecords.ПрогнозРеализации.Write = False;
//	RegisterRecords.НакопитСкидки.Write = False;
//	RegisterRecords.ПланируемыеГруппы.Write = False;
//	RegisterRecords.РеестрПутевокКурсовок.Write = False;
//	RegisterRecords.ОжиданиеБрони.Write = False;
//	RegisterRecords.ЗагрузкаНомеров.Write = False;
//	RegisterRecords.ПродажиКвот.Write = False;
//	RegisterRecords.ПрогнозПродаж.Write = False;
//КонецПроцедуры //Posting
//
////-----------------------------------------------------------------------------
//Процедура PostResourceReservations(pResourceReservationServices, pResourceReservations)
//	pResourceReservationServices.Columns.Add("БроньУслуг", cmGetDocumentTypeDescription("БроньУслуг"));
//	vDocsToDelete = New СписокЗначений();
//	For Each vRRSrvRow In pResourceReservationServices Do
//		// Try to search for such resource reservation
//		vDateTimeFrom = BegOfDay(vRRSrvRow.УчетнаяДата) + (vRRSrvRow.ВремяС - BegOfDay(vRRSrvRow.ВремяС));
//		vRRRows = pResourceReservations.FindRows(New Structure("Ресурс, DateTimeFrom", vRRSrvRow.ServiceResource, vDateTimeFrom));
//		If vRRRows.Count() = 1 Тогда
//			vRRRow = vRRRows.Get(0);
//			vRRSrvRow.БроньУслуг = vRRRow.Ref;
//		EndIf;
//	EndDo;
//	For Each vRRRow In pResourceReservations Do
//		If pResourceReservationServices.Find(vRRRow.Ref, "БроньУслуг") = Неопределено Тогда
//			vRRRow.Ref.GetObject().SetDeletionMark(True);
//		EndIf;
//	EndDo;
//	For Each vRRSrvRow In pResourceReservationServices Do
//		// Get resource reservation main parameters
//		vDateTimeFrom = BegOfDay(vRRSrvRow.УчетнаяДата) + (vRRSrvRow.ВремяС - BegOfDay(vRRSrvRow.ВремяС));
//		vDateTimeTo = BegOfDay(vRRSrvRow.УчетнаяДата) + (vRRSrvRow.ВремяПо - BegOfDay(vRRSrvRow.ВремяПо));
//		If vRRSrvRow.ВремяС >= vRRSrvRow.ВремяПо Тогда
//			vDateTimeTo = vDateTimeTo + 24*3600;
//		EndIf;
//		// Get resource reservation object
//		vFolio = vRRSrvRow.СчетПроживания;
//		vDocObj = Неопределено;
//		If ЗначениеЗаполнено(vRRSrvRow.БроньУслуг) Тогда
//			vDocObj = vRRSrvRow.БроньУслуг.GetObject();
//			vDocObj.Read();
//		Else
//			vDocObj = Documents.БроньУслуг.CreateDocument();
//		EndIf;
//		vDocObj.Гостиница = vFolio.Гостиница;
//		If НЕ ЗначениеЗаполнено(vDocObj.Гостиница) Тогда
//			vDocObj.Гостиница = Гостиница;
//		EndIf;
//		vDocObj.Фирма = vFolio.Фирма;
//		If НЕ ЗначениеЗаполнено(vDocObj.Фирма) Тогда
//			vDocObj.Фирма = Фирма;
//		EndIf;
//		vDocObj.ExchangeRateDate = ExchangeRateDate;
//		vDocObj.ChargingFolio = vFolio;
//		vDocObj.ВалютаЛицСчета = vRRSrvRow.ВалютаЛицСчета;
//		vDocObj.FolioCurrencyExchangeRate = vRRSrvRow.FolioCurrencyExchangeRate;
//		vDocObj.ГруппаГостей = vFolio.ГруппаГостей;
//		vDocObj.ResourceReservationStatus = vDocObj.Гостиница.NewResourceReservationStatus;
//		If ЗначениеЗаполнено(vDocObj.ResourceReservationStatus) Тогда
//			vDocObj.DoCharging = vDocObj.ResourceReservationStatus.DoCharging;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(vRRSrvRow.БроньУслуг) Тогда
//			vDocObj.pmFillAttributesWithDefaultValues();
//		EndIf;
//		vDocObj.Валюта = ReportingCurrency;
//		vDocObj.ReportingCurrencyExchangeRate = ReportingCurrencyExchangeRate;
//		vDocObj.ТипРесурса = vRRSrvRow.ServiceResource.Owner;
//		vDocObj.Ресурс = vRRSrvRow.ServiceResource;
//		vDocObj.ТипКлиента = ClientType;
//		vDocObj.СтрокаПодтверждения = ClientTypeConfirmationText;
//		vDocObj.PlannedPaymentMethod = vFolio.СпособОплаты;
//		vDocObj.DateTimeFrom = vDateTimeFrom;
//		vDocObj.DateTimeTo = vDateTimeTo;
//		vDocObj.Продолжительность = vDocObj.pmCalculateDuration();
//		vDocObj.КоличествоЧеловек = NumberOfPersons;
//		If ЗначениеЗаполнено(vFolio.Договор) Тогда
//			vDocObj.Owner = vFolio.Договор;
//		ElsIf ЗначениеЗаполнено(vFolio.Контрагент) Тогда
//			vDocObj.Owner = vFolio.Контрагент;
//		ElsIf ЗначениеЗаполнено(vDocObj.Гостиница) Тогда
//			If ЗначениеЗаполнено(vDocObj.Гостиница.IndividualsContract) Тогда
//				vDocObj.Owner = vDocObj.Гостиница.IndividualsContract;
//			Else
//				vDocObj.Owner = vDocObj.Гостиница.IndividualsCustomer;
//			EndIf;
//		Else
//			vDocObj.Owner = Неопределено;
//		EndIf;
//		vDocObj.Контрагент = Контрагент;
//		If ЗначениеЗаполнено(vDocObj.Контрагент) Тогда
//			vDocObj.ТипКонтрагента = vDocObj.Контрагент.ТипКонтрагента;
//		Else
//			vDocObj.ТипКонтрагента = CustomerType;
//		EndIf;
//		vDocObj.Договор = Contract;
//		vDocObj.Агент = vFolio.Агент;
//		If ЗначениеЗаполнено(vDocObj.Агент) Тогда
//			vDocObj.КомиссияАгента = AgentCommission;
//			vDocObj.ВидКомиссииАгента = AgentCommissionType;
//			vDocObj.КомиссияАгентУслуги = AgentCommissionServiceGroup;
//		Else
//			vDocObj.КомиссияАгента = 0;
//			vDocObj.ВидКомиссииАгента = Неопределено;
//			vDocObj.КомиссияАгентУслуги = Справочники.НаборыУслуг.EmptyRef();
//		EndIf;
//		vDocObj.Клиент = vFolio.Клиент;
//		vDocObj.КонтактноеЛицо = ContactPerson;
//		vDocObj.CreditCard = CreditCard;
//		vDocObj.Телефон = Phone;
//		vDocObj.Fax = Fax;
//		vDocObj.EMail = EMail;
//		vDocObj.PlannedPaymentMethod = vFolio.СпособОплаты;
//		vDocObj.МаркетингКод = MarketingCode;
//		vDocObj.MarketingCodeConfirmationText = MarketingCodeConfirmationText;
//		vDocObj.ИсточникИнфоГостиница = SourceOfBusiness;
//		vDocObj.ДокОснование = Ref;
//		vDocObj.Примечания = TrimAll(vRRSrvRow.Примечания);
//		vDocObj.DoNotCalculateServices = True;
//		vDocObj.DeletionMark = False;
//		vDocObj.pmCalculateServices();
//		vDocObj.Write(DocumentWriteMode.Posting);
//		vDocObj.pmWriteToResourceReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//	EndDo;
//КонецПроцедуры //PostResourceReservations	
//
////-----------------------------------------------------------------------------
//Function pmGetResourceServices() Экспорт
//	vRRServices = Services.Unload();
//	vRRServices.Clear();
//	For Each vSrvRow In Services Do
//		If ЗначениеЗаполнено(vSrvRow.AccountingDate) And 
//		   ЗначениеЗаполнено(vSrvRow.ServiceResource) And TypeOf(vSrvRow.ServiceResource) = Type("CatalogRef.Ресурсы") And 
//		   vSrvRow.DoResourceReservation Тогда
//			vRRServicesRow = vRRServices.Add();
//			FillPropertyValues(vRRServicesRow, vSrvRow);
//		EndIf;
//	EndDo;
//	Return vRRServices;
//EndFunction //pmGetResourceServices
//
////-----------------------------------------------------------------------------
//Процедура pmUndoPosting(pCancel) Экспорт
//	// 1. Check should we repost any intersecting accommodations or reservations
//	// Build value table of accommodation periods
//	vPeriods = pmGetAccommodationPeriods();
//	// Process each accommodation period separately
//	For Each vPeriodsRow In vPeriods Do
//		If vPeriodsRow.КоличествоМест <> 0 Тогда
//			vIntersectedDocs = cmGetTableOfIntersectedDocs(vPeriodsRow);
//			If vIntersectedDocs.Count() > 0 Тогда
//				// Clear registry records of the current document
//				pmClearInventoryRegisterRecords();
//				// Clear registry records for the intersecting documents
//				ClearInventoryRecordsForIntersectedDocs(vIntersectedDocs);
//				// Repost intersected documents
//				RepostIntersectedDocs(vIntersectedDocs, vPeriodsRow, 0);
//			EndIf;
//		EndIf;
//	EndDo;
//	// 2. Build table of already charged services and then delete all (or future) chargings 
//	vChargesTab = cmGetTableOfAlreadyChargedServices(Ref);
//	For Each vChargesRec In vChargesTab Do
//		vChargeObj = vChargesRec.Ref.GetObject();
//		If НЕ cmIfChargeIsInClosedDay(vChargeObj) Тогда
//			vChargeObj.SetDeletionMark(True);
//		EndIf;
//	EndDo;
//	// 3. Delete bound resource reservations
//	vResourceReservations = cmGetChildResourceReservations(Ref, True);
//	For Each vResourceReservationsRow In vResourceReservations Do
//		vResourceReservationObj = vResourceReservationsRow.Ref.GetObject();
//		vResourceReservationObj.SetDeletionMark(True);
//	EndDo;
//КонецПроцедуры //pmUndoPosting
//
////-----------------------------------------------------------------------------
//Процедура UndoPosting(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Remove ГруппаНомеров inventory movements, recalculate ГруппаНомеров inventory balances and delete charges
//	pmUndoPosting(pCancel);
//КонецПроцедуры //UndoPosting
//
////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Remove ГруппаНомеров inventory movements, recalculate ГруппаНомеров inventory balances and delete charges
//	If Posted Тогда
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And DoCharging And 
//		  (Services.Total("Сумма") <> 0 Or Services.Total("Количество") <> 0) And 
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
//				Message(NStr("en='All reservation charges are closed by settlements! Reservation is read only.';ru='Все начисления брони уже закрыты актами об оказании услуг! Редактирование такой брони запрещено.';de='Alle Anrechnungen der Reservierung wurden bereits durch Übergabeprotokolle über Dienstleistungserbringung geschlossen! Die Bearbeitung einer solchen Reservierung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		pmUndoPosting(pCancel);
//	EndIf;
//КонецПроцедуры //BeforeDelete
//
////-----------------------------------------------------------------------------
//Процедура pmClearInventoryRegisterRecords() Экспорт
//	RegisterRecords.ЗагрузкаНомеров.Clear();
//	RegisterRecords.ПродажиКвот.Clear();
//	// If posted
//	If Posted Тогда
//		// ГруппаНомеров inventory
//	    vRISet = AccumulationRegisters.ЗагрузкаНомеров.CreateRecordSet();
//	    vRISet.Filter.Recorder.Set(Ref);
//	    vRISet.Read();
//	    vRISet.Clear();
//	    vRISet.Write(True);
//		// ГруппаНомеров quota sales
//	    vRQSet = AccumulationRegisters.ПродажиКвот.CreateRecordSet();
//	    vRQSet.Filter.Recorder.Set(Ref);
//	    vRQSet.Read();
//	    vRQSet.Clear();
//	    vRQSet.Write(True);
//	EndIf;
//КонецПроцедуры //pmClearInventoryRegisterRecords
//
////-----------------------------------------------------------------------------
//Процедура pmClearSalesForecastRegisterRecords() Экспорт
//	RegisterRecords.ПрогнозПродаж.Clear();
//	RegisterRecords.РеестрПутевокКурсовок.Clear();
//	// If posted
//	If Posted Тогда
//		// Sales forecast
//	    vSFSet = AccumulationRegisters.ПрогнозПродаж.CreateRecordSet();
//	    vSFSet.Filter.Recorder.Set(Ref);
//	    vSFSet.Read();
//	    vSFSet.Clear();
//	    vSFSet.Write(True);
//		// Гостиница product log
//	    vHPLSet = AccumulationRegisters.РеестрПутевокКурсовок.CreateRecordSet();
//	    vHPLSet.Filter.Recorder.Set(Ref);
//	    vHPLSet.Read();
//	    vHPLSet.Clear();
//	    vHPLSet.Write(True);
//	EndIf;
//КонецПроцедуры //pmClearSalesForecastRegisterRecords
//
////-----------------------------------------------------------------------------
//Процедура FillRChgAttributes(pRChgRec, pPeriod, pUser)
//	FillPropertyValues(pRChgRec, ThisObject);
//	
//	pRChgRec.Period = pPeriod;
//	pRChgRec.Reservation = Ref;
//	pRChgRec.User = pUser;
//	
//	// Store tabular parts
//	vPrices = New ValueStorage(Prices.Unload());
//	pRChgRec.Prices = vPrices;
//	vRoomRates = New ValueStorage(RoomRates.Unload());
//	pRChgRec.Тарифы = vRoomRates;
//	vServicePackages = New ValueStorage(ServicePackages.Unload());
//	pRChgRec.ПакетыУслуг = vServicePackages;
//	vServices = New ValueStorage(Services.Unload());
//	pRChgRec.Услуги = vServices;
//	vChargingRules = New ValueStorage(ChargingRules.Unload());
//	pRChgRec.ChargingRules = vChargingRules;
//	vRooms = New ValueStorage(Rooms.Unload());
//	pRChgRec.НомернойФонд = vRooms;
//	vOccupationPercents = New ValueStorage(OccupationPercents.Unload());
//	pRChgRec.OccupationPercents = vOccupationPercents;
//	vRoomProperties = New ValueStorage(RoomProperties.Unload());
//	pRChgRec.СвойстваНомеров = vRoomProperties;
//КонецПроцедуры //FillRChgAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmWriteToReservationChangeHistory(pPeriod, pUser) Экспорт
//	// Get channges description
//	vChanges = cmGetObjectChanges(ThisObject);
//	If НЕ IsBlankString(vChanges) Тогда
//		// Do movement on current date
//		vRChgRec = InformationRegisters.ИсторияБрони.CreateRecordManager();
//		
//		FillRChgAttributes(vRChgRec, pPeriod, pUser);
//		vRChgRec.Changes = vChanges;
//		
//		// Write record
//		vRChgRec.Write(True);
//	EndIf;
//КонецПроцедуры //pmWriteToReservationChangeHistory
//
////-----------------------------------------------------------------------------
//Function pmGetPreviousObjectState(pPeriod) Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	*
//	|FROM
//	|	InformationRegister.ReservationChangeHistory.SliceLast(&qPeriod, Reservation = &qDoc) AS ReservationChangeHistory";
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
//	vPrices = pRChgRec.Prices.Get();
//	If vPrices <> Неопределено Тогда
//		Prices.Load(vPrices);
//	Else
//		Prices.Clear();
//	EndIf;
//	vRoomRates = pRChgRec.Тарифы.Get();
//	If vRoomRates <> Неопределено Тогда
//		RoomRates.Load(vRoomRates);
//	Else
//		RoomRates.Clear();
//	EndIf;
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
//	vChargingRules = pRChgRec.ChargingRules.Get();
//	If vChargingRules <> Неопределено Тогда
//		ChargingRules.Load(vChargingRules);
//	Else
//		ChargingRules.Clear();
//	EndIf;
//	vRooms = pRChgRec.НомернойФонд.Get();
//	If vRooms <> Неопределено Тогда
//		Rooms.Load(vRooms);
//	Else
//		Rooms.Clear();
//	EndIf;
//	vOccupationPercents = pRChgRec.OccupationPercents.Get();
//	If vOccupationPercents <> Неопределено Тогда
//		OccupationPercents.Load(vOccupationPercents);
//	Else
//		OccupationPercents.Clear();
//	EndIf;
//	vRoomProperties = pRChgRec.СвойстваНомеров.Get();
//	If vRoomProperties <> Неопределено Тогда
//		RoomProperties.Load(vRoomProperties);
//	Else
//		RoomProperties.Clear();
//	EndIf;
//КонецПроцедуры //pmRestoreAttributesFromHistory
//
////-----------------------------------------------------------------------------
//Function IsChangeOfAccommodationConditions() 
//	vIsChangeOfAccConditions = ReservationStatus.IsActive;
//	If Posted And ReservationStatus.IsActive Тогда
//		vPrevAccState = pmGetReservationAttributes(CurrentDate());
//		For Each vPrevAccStateRow In vPrevAccState Do
//			If cm0SecondShift(vPrevAccStateRow.CheckInDate) <= cm0SecondShift(CheckInDate) And
//			   cm0SecondShift(vPrevAccStateRow.ДатаВыезда) >= cm0SecondShift(CheckOutDate) And 
//			   vPrevAccStateRow.ТипНомера = RoomType And
//			   vPrevAccStateRow.ВидРазмещения = AccommodationType And
//			   vPrevAccStateRow.RoomQuantity >= RoomQuantity And 
//			   ЗначениеЗаполнено(ReservationStatus) And ЗначениеЗаполнено(vPrevAccStateRow.ReservationStatus) And 
//			   ReservationStatus.IsActive = vPrevAccStateRow.ReservationStatus.IsActive Тогда
//				vIsChangeOfAccConditions = False;
//			EndIf;
//			Break;
//		EndDo;
//	EndIf;
//	Return vIsChangeOfAccConditions;
//EndFunction //IsChangeOfAccommodationConditions
//
////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pPeriod, pIsPosted, pMessage, pAttributeInErr, pDoNotCheckRests = False) Экспорт
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
//	If НЕ ЗначениеЗаполнено(ReservationStatus) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Статус брони> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Reservation status> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Reservation status> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ReservationStatus", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(AccommodationType) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Вид размещения> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Размещение type> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Размещение type> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ВидРазмещения", pAttributeInErr);
//	ElsIf ЗначениеЗаполнено(Гость) And ЗначениеЗаполнено(CheckInDate) Тогда
//		If НЕ ЗначениеЗаполнено(Гость.ДатаРождения) Тогда
//			If AccommodationType.AllowedClientAgeFrom <> 0 Or 
//			   AccommodationType.AllowedClientAgeTo <> 0 Or 
//			   ЗначениеЗаполнено(AccommodationType.AllowedClientAgeRange) Тогда
//				vMsgTextRu = vMsgTextRu + "Не указана дата рождения гостя " + TrimAll(Гость) + "!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Date of birth is not specified for Клиент " + TrimAll(Гость) + "!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "Date of birth is not specified for Клиент " + TrimAll(Гость) + "!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Клиент", pAttributeInErr);
//				If НЕ cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Тогда
//					vHasErrors = True; 
//				Else
//					Message(NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';"), MessageStatus.Attention);
//				EndIf;
//			EndIf;
//		EndIf;
//		vGuestAge = Гость.GetObject().pmGetClientAge(CheckInDate);
//		If AccommodationType.AllowedClientAgeFrom > vGuestAge Тогда
//			vMsgTextRu = vMsgTextRu + "Возраст гостя должен быть больше или равен " + AccommodationType.AllowedClientAgeFrom + "!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Клиент has to be more or equal then " + AccommodationType.AllowedClientAgeFrom + " years old!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Клиент has to be more or equal then " + AccommodationType.AllowedClientAgeFrom + " years old!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Клиент", pAttributeInErr);
//			If НЕ cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Тогда
//				vHasErrors = True; 
//			Else
//				Message(NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';"), MessageStatus.Attention);
//			EndIf;
//		EndIf;
//		If AccommodationType.AllowedClientAgeTo > 0 And AccommodationType.AllowedClientAgeTo < vGuestAge Тогда
//			vMsgTextRu = vMsgTextRu + "Возраст гостя должен быть меньше " + AccommodationType.AllowedClientAgeTo + "!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Клиент has to be less then " + AccommodationType.AllowedClientAgeTo + " years old!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Клиент has to be less then " + AccommodationType.AllowedClientAgeTo + " years old!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Клиент", pAttributeInErr);
//			If НЕ cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Тогда
//				vHasErrors = True; 
//			Else
//				Message(NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';"), MessageStatus.Attention);
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(AccommodationType.AllowedClientAgeRange) Тогда
//			vGuestAgeRange = Гость.GetObject().pmGetClientAgeRange(vGuestAge);
//			If AccommodationType.AllowedClientAgeRange <> vGuestAgeRange Тогда
//				vMsgTextRu = vMsgTextRu + "Возраст гостя должен быть в возрастной группе " + AccommodationType.AllowedClientAgeRange + "!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Клиент age has to be in " + AccommodationType.AllowedClientAgeRange + " age range group!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "Клиент age has to be in " + AccommodationType.AllowedClientAgeRange + " age range group!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Клиент", pAttributeInErr);
//				If НЕ cmCheckUserPermissions("HavePermissionToIgnoreGuestAgeLimitations") Тогда
//					vHasErrors = True; 
//				Else
//					Message(NStr("ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';"), MessageStatus.Attention);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pPeriod.ТипНомера) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Тип номера> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения type> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Реквизит <Тип номера> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ТипНомера", pAttributeInErr);
//	Else
//		If pPeriod.ТипНомера.ВиртуальныйНомер Тогда
//			If НЕ cmCheckUserPermissions("HavePermissionToUseVirtualRooms") Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "У вас нет прав на бронирование виртуальных типов номеров!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "You do not have rights to reserve virtual НомерРазмещения types!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "У вас нет прав на бронирование виртуальных типов номеров!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "ТипНомера", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(pPeriod.НомерРазмещения) Тогда
//		If pPeriod.НомерРазмещения.ВиртуальныйНомер Тогда
//			If НЕ cmCheckUserPermissions("HavePermissionToUseVirtualRooms") Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "У вас нет прав на бронирование виртуальных номеров!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "You do not have rights to reserve virtual rooms!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "У вас нет прав на бронирование виртуальных номеров!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pPeriod.CheckInDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата заезда> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Check in date> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Реквизит <Дата заезда> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pPeriod.ДатаВыезда) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата выезда> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Check out date> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Реквизит <Дата выезда> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ДатаВыезда", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(pPeriod.CheckInDate) And ЗначениеЗаполнено(pPeriod.ДатаВыезда) Тогда
//		If pPeriod.CheckInDate > pPeriod.ДатаВыезда Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Дата выезда должна быть позже даты заезда!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Check out date should be after check in date!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Дата выезда должна быть позже даты заезда!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ДатаВыезда", pAttributeInErr);
//		Else
//			If ЗначениеЗаполнено(Contract) Тогда
//				If Contract.PeriodCheckType = 0 Тогда
//					If ЗначениеЗаполнено(Contract.ValidFromDate) And 
//					   CheckInDate < BegOfDay(Contract.ValidFromDate) Or
//					   ЗначениеЗаполнено(Contract.ValidToDate) And
//					   CheckInDate > EndOfDay(Contract.ValidToDate) Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Выбранный договор не действует на указанном периоде брони!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "Договор is not valid on period selected!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "Выбранный договор не действует на указанном периоде брони!" + Chars.LF;
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
//						vMsgTextDe = vMsgTextDe + "Выбранный договор не действует на дату создания брони!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "Договор", pAttributeInErr);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ReservationStatus) And IsChangeOfAccommodationConditions() Тогда
//		If ЗначениеЗаполнено(pPeriod.ТипНомера) Тогда
//			If pPeriod.ТипНомера.СнятСПродажи And NumberOfBeds > 0 Тогда
//				vRemarks = "";
//				If cmIsStopSalePeriod(pPeriod.ТипНомера, pPeriod.CheckInDate, pPeriod.ДатаВыезда, vRemarks) Тогда
//					If НЕ cmCheckUserPermissions("HavePermissionToIgnoreStopSaleLimitations") Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Выбранный тип номера снят с продажи!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
//						vMsgTextEn = vMsgTextEn + "НомерРазмещения type choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
//						vMsgTextDe = vMsgTextDe + "Выбранный тип номера снят с продажи!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
//						pAttributeInErr = ?(pAttributeInErr = "", "ТипНомера", pAttributeInErr);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(pPeriod.НомерРазмещения) Тогда
//			If pPeriod.НомерРазмещения.СнятСПродажи And NumberOfBeds > 0 Тогда
//				vRemarks = "";
//				If cmIsRoomStopSalePeriod(pPeriod.НомерРазмещения, pPeriod.CheckInDate, pPeriod.ДатаВыезда, vRemarks) Тогда
//					If НЕ cmCheckUserPermissions("HavePermissionToIgnoreStopSaleLimitations") Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Выбранный НомерРазмещения снят с продажи!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
//						vMsgTextEn = vMsgTextEn + "НомерРазмещения choosen is out of sale!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
//						vMsgTextDe = vMsgTextDe + "Выбранный НомерРазмещения снят с продажи!" + Chars.LF + ?(IsBlankString(vRemarks), "", vRemarks + Chars.LF);
//						pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Гость) Тогда
//		If Гость.DoNotCheckIn Тогда
//			If НЕ cmCheckUserPermissions("HavePermissionToIgnoreBlackListLimitations") Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "У гостя установлен режим запрета поселения!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Клиент check-in is forbidden!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "У гостя установлен режим запрета поселения!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Клиент", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(BoardPlace) Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToSkipBoardPlaceSetting") And НЕ pDoNotCheckRests Тогда
//			vBoardPlaces = cmGetBoardPlaces(Гостиница);
//			If vBoardPlaces.Count() > 0 Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "У вас нет прав на бронирование без указания места питания!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "You do not have rights to do booking with no board place setting!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "Es gibt kein Rechte auf Nahrung nicht in der Reservierung angeben!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Питание", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ pDoNotCheckRests And ЗначениеЗаполнено(ReservationStatus) Тогда
//		If ReservationStatus.IsActive Тогда
//			// Check rooms in quota availability
//			If ЗначениеЗаполнено(RoomQuota) And ЗначениеЗаполнено(pPeriod.ВидРазмещения) And 
//			   (pPeriod.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.Beds Or pPeriod.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения) Тогда
//				If RoomQuota.CustomerOrContractChangeIsNotAllowed Тогда
//					If RoomQuota.Контрагент <> Контрагент Or
//					   RoomQuota.Contract <> Contract Or
//					   RoomQuota.RoomRateType <> RoomRateType Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Бронирование с указанием контрагента/договора/типа тарифа отличных от них в выбранной квоте запрещено!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "It is not allowed to do reservation with Контрагент/Договор/НомерРазмещения rate type different from them in allotment choosen!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "Бронирование с указанием контрагента/договора/типа тарифа отличных от них в выбранной квоте запрещено!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "КвотаНомеров", pAttributeInErr);
//					EndIf;
//				EndIf;
//				vRoomType = pPeriod.ТипНомера;
//				If ЗначениеЗаполнено(RoomTypeUpgrade) And ЗначениеЗаполнено(RoomTypeUpgrade.BaseRoomType) And pPeriod.ТипНомера = RoomTypeUpgrade.BaseRoomType Тогда
//					vRoomType = RoomTypeUpgrade;
//				EndIf;
//				If НЕ cmCheckRoomQuotaAvailability(RoomQuota.Agent, RoomQuota.Контрагент, RoomQuota.Contract, RoomQuota, 
//				                                    Гостиница, vRoomType, pPeriod.НомерРазмещения, Ref, pIsPosted, True,
//				                                    pPeriod.КоличествоНомеров, pPeriod.КоличествоМест, 
//				                                    cmMovePeriodFromToReferenceHour(pPeriod.CheckInDate, pPeriod.Тариф), 
//				                                    cmMovePeriodToToReferenceHour(pPeriod.ДатаВыезда, pPeriod.Тариф), 
//				                                    vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//					vHasErrors = True; 
//					pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
//				EndIf;
//				If RoomQuota.IsForCheckInPeriods And pPeriod.CheckInDate = CheckInDate Тогда
//					If НЕ cmCheckCheckInPeriods(Гостиница, RoomQuota, CheckInDate, CheckOutDate) Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Указанный срок проживания не попадает на границы заездов!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "Размещение period specified is out from the check-in period dates!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "Указанный срок проживания не попадает на границы заездов!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "ДатаВыезда", pAttributeInErr);
//					EndIf;
//				EndIf;
//			EndIf;
//			// Check rooms availability if ГруппаНомеров quota is not set and ГруппаНомеров is choosen
//			If НЕ ЗначениеЗаполнено(RoomQuota) Or ЗначениеЗаполнено(pPeriod.НомерРазмещения) Or ЗначениеЗаполнено(RoomQuota) And НЕ RoomQuota.DoWriteOff Тогда
//				If НЕ cmCheckRoomAvailability(Гостиница, RoomQuota, pPeriod.ТипНомера, pPeriod.НомерРазмещения, Ref, pIsPosted, IsChangeOfAccommodationConditions(),
//				                               pPeriod.КоличествоЧеловек, pPeriod.КоличествоНомеров, pPeriod.КоличествоМест, pPeriod.КолДопМест, 
//				                               pPeriod.КоличествоМестНомер, pPeriod.КоличествоГостейНомер, Max(CurrentDate(), pPeriod.CheckInDate), pPeriod.ДатаВыезда, 
//				                               vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//					vHasErrors = True; 
//					pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//		// Get and check ГруппаНомеров rate restrictions
//		If ReservationStatus.IsActive Or ReservationStatus.IsPreliminary Or ReservationStatus.IsInWaitingList Тогда
//			If ЗначениеЗаполнено(Тариф) And BegOfDay(CheckInDate) >= BegOfDay(CurrentDate()) And НЕ ReservationStatus.IsCheckIn And НЕ ReservationStatus.IsNoShow Тогда 
//				vRestrStruct = Тариф.GetObject().pmGetRoomRateRestrictions(CheckInDate, CheckOutDate, ?(ЗначениеЗаполнено(RoomTypeUpgrade), RoomTypeUpgrade, RoomType), True);
//				If vRestrStruct.CTA Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Заезд в выбранную дату " + Format(CheckInDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTA включен)!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Check-in is closed (CTA is On) for the given check-in date " + Format(CheckInDate, "DF=dd.MM.yyyy") + "!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Check-in ist für den Check-in-Datum " + Format(CheckInDate, "DF=dd.MM.yyyy") + " geschlossen (CTA is On)!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
//				EndIf;
//				If vRestrStruct.CTD Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Выезд в выбранную дату " + Format(CheckOutDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTD включен)!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Check-out is closed (CTD is On) for the given check-out date " + Format(CheckOutDate, "DF=dd.MM.yyyy") + "!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Check-out ist für den Check-out-Datum " + Format(CheckOutDate, "DF=dd.MM.yyyy") + " geschlossen (CTD is On)!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "ДатаВыезда", pAttributeInErr);
//				EndIf;
//				If vRestrStruct.MLOS > 0 And Duration < vRestrStruct.MLOS And Тариф.MLOSIsBlocking Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Минимальная продолжительность проживания " + vRestrStruct.MLOS + " дней!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Minimum length of stay is " + vRestrStruct.MLOS + "!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Mindestaufenthaltsdauer beträgt " + vRestrStruct.MLOS + " Tage!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
//				EndIf;
//				If vRestrStruct.MaxLOS > 0 And Duration > vRestrStruct.MaxLOS Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Максимальная продолжительность проживания " + vRestrStruct.MaxLOS + " дней!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Maximum length of stay is " + vRestrStruct.MaxLOS + "!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Maximaleaufenthaltsdauer beträgt " + vRestrStruct.MaxLOS + " Tage!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "ДатаВыезда", pAttributeInErr);
//				EndIf;
//				If vRestrStruct.MinDaysBeforeCheckIn > 0 Тогда
//					vDaysBeforeCheckIn = Int((BegOfDay(CheckInDate) - BegOfDay(Date))/(24*3600));
//					If vDaysBeforeCheckIn < vRestrStruct.MinDaysBeforeCheckIn Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Минимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MinDaysBeforeCheckIn + "!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "Minimum days between booking and check-in dates is " + vRestrStruct.MinDaysBeforeCheckIn + "!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "Mindest Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MinDaysBeforeCheckIn + "!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
//					EndIf;
//				EndIf;
//				If vRestrStruct.MaxDaysBeforeCheckIn > 0 Тогда
//					vDaysBeforeCheckIn = Int((BegOfDay(CheckInDate) - BegOfDay(Date))/(24*3600));
//					If vDaysBeforeCheckIn > vRestrStruct.MaxDaysBeforeCheckIn Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "Максимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MaxDaysBeforeCheckIn + "!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "Maximum days between booking and check-in dates is " + vRestrStruct.MaxDaysBeforeCheckIn + "!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "Maximale Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MaxDaysBeforeCheckIn + "!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "CheckInDate", pAttributeInErr);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Контрагент) And 
//	   НЕ ЗначениеЗаполнено(Contract) And 
//	   НЕ ЗначениеЗаполнено(Agent) And 
//	   IsBlankString(Remarks) And 
//	   IsBlankString(ContactPerson) And 
//	   НЕ ЗначениеЗаполнено(Гость) And 
//	   ЗначениеЗаполнено(GuestGroup) And 
//	   IsBlankString(GuestGroup.Description) And 
//	   НЕ ЗначениеЗаполнено(GuestGroup.Client) And 
//	   НЕ ЗначениеЗаполнено(GuestGroup.Контрагент) And 
//	   GuestGroup.GuestsCheckedIn <= 0 Тогда
//		If ЗначениеЗаполнено(AccommodationType) And 
//		   AccommodationType.ТипРазмещения <> Перечисления.AccomodationTypes.AdditionalBed And 
//		   AccommodationType.ТипРазмещения <> Перечисления.AccomodationTypes.Together Тогда
//			If НЕ cmCheckUserPermissions("HavePermissionToCreateReservationsWithoutContactClientAndCustomerData") Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "В брони не указано кто бронирует! Не указаны контрагент, договор, контактное лицо, Клиент, агент, примечания." + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Контрагент, Договор, contact person, Агент, Клиент and Примечания are empty!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "В брони не указано кто бронирует! Не указаны контрагент, договор, контактное лицо, Клиент, агент, примечания." + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Клиент", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Контрагент) And 
//	   IsBlankString(Контрагент.Phone) And 
//	   IsBlankString(Контрагент.Fax) And 
//	   IsBlankString(Контрагент.EMail) And 
//	   IsBlankString(Контрагент.ContactPerson) And 
//	   Контрагент.ContactPersons.Count() = 0 Тогда
//		If ЗначениеЗаполнено(AccommodationType) And 
//		   AccommodationType.ТипРазмещения <> Перечисления.AccomodationTypes.AdditionalBed And 
//		   AccommodationType.ТипРазмещения <> Перечисления.AccomodationTypes.Together Тогда
//			If НЕ cmCheckUserPermissions("HavePermissionToDoBookingWithoutCustomerContactData") Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "В карточке заказчика не указана контактная информация! У вас нет прав бронировать без указания у заказчика хотя бы одного из полей: телефон, факс, e-mail, контактное лицо." + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Контрагент do not have contact data! You do not have rights to do reservation without Контрагент Телефон or fax or e-mail or contact person data entered!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "В карточке заказчика не указана контактная информация! У вас нет прав бронировать без указания у заказчика хотя бы одного из полей: телефон, факс, e-mail, контактное лицо." + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Контрагент", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check that there is no change ГруппаНомеров attributes in the period selected
//	If ЗначениеЗаполнено(pPeriod.НомерРазмещения) And ЗначениеЗаполнено(pPeriod.CheckInDate) And ЗначениеЗаполнено(pPeriod.ДатаВыезда) Тогда
//		If TypeOf(pPeriod) <> Type("DocumentObject.Reservation") Тогда
//			vChangeRoomAttrs = cmGetChangeRoomAttributes(pPeriod.НомерРазмещения, pPeriod.CheckInDate, pPeriod.ДатаВыезда);
//			If vChangeRoomAttrs.Count() > 0 Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "В плане брони не должно быть не учтенных изменений параметров выбранного номера!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "There should be no missed change НомерРазмещения attributes in the reservation plan!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "В плане брони не должно быть не учтенных изменений параметров выбранного номера!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check charging rules
//	For Each vCRRow In ChargingRules Do
//		If vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.AllButOne And НЕ ЗначениеЗаполнено(vCRRow.ChargingRuleValue) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана услуга!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Услуга is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана услуга!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
//		ElsIf vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.InServiceGroup And НЕ ЗначениеЗаполнено(vCRRow.ChargingRuleValue) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указан набор услуг!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Услуга group is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указан набор услуг!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
//		ElsIf vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.One And НЕ ЗначениеЗаполнено(vCRRow.ChargingRuleValue) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана услуга!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Услуга is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана услуга!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
//		ElsIf vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.NotInServiceGroup And НЕ ЗначениеЗаполнено(vCRRow.ChargingRuleValue) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указан набор услуг!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Услуга group is not filled in the charging rules row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " не указан набор услуг!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
//		EndIf;
//		If НЕ ЗначениеЗаполнено(vCRRow.Owner) And ЗначениеЗаполнено(vCRRow.ChargingFolio) And ЗначениеЗаполнено(vCRRow.ChargingFolio.PaymentMethod) And vCRRow.ChargingFolio.PaymentMethod.IsByBankTransfer Тогда
//			If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.IndividualsCustomer) Тогда
//				vCRRow.Owner = Гостиница.IndividualsCustomer;
//			Else
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " установлен способ оплаты контрагентом, а контрагент не указан!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Контрагент is not choosen in the charging rule owner in the row number " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " but Платеж method choosen states that СчетПроживания is payed by Контрагент!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "В правилах начисления в строке " + Format(vCRRow.LineNumber, "ND=4; NFD=0; NG=") + " установлен способ оплаты контрагентом, а контрагент не указан!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "ChargingRules", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndDo;
//	If vHasErrors Тогда
//		pMessage = "ru = '" + TrimAll(vMsgTextRu) + "';" + "en = '" + TrimAll(vMsgTextEn) + "';" + "de = '" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmInitializePeriod() Экспорт
//	vCoeff = 1;
//	If cmCheckUserPermissions("UseCurrentDateAsDefaultReservationCheckInDate") Тогда
//		vCoeff = 0;
//	EndIf;
//	If ЗначениеЗаполнено(Тариф) Тогда
//		vRRPer = ?(Тариф.PeriodInHours = 0, 24, Тариф.PeriodInHours);
//		vRRRH = Тариф.ReferenceHour;
//		vDefaultCheckInTime = Тариф.DefaultCheckInTime;
//		If НЕ ЗначениеЗаполнено(CheckInDate) Тогда
//			If ЗначениеЗаполнено(vDefaultCheckInTime) Тогда
//				If Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
//					CheckInDate = Date(Year(Date), Month(Date), Day(Date), 
//					                   Hour(vDefaultCheckInTime), Minute(vDefaultCheckInTime), 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				ElsIf Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
//					CheckInDate = Date(Year(Date), Month(Date), Day(Date), 
//					                   Hour(vDefaultCheckInTime), Minute(vDefaultCheckInTime), 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				ElsIf Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
//					CheckInDate = Date(Year(Date), Month(Date), Day(Date), 
//					                   Hour(vDefaultCheckInTime), Minute(vDefaultCheckInTime), 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				Else
//					CheckInDate = (Date + 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				EndIf;
//			Else
//				If Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
//					CheckInDate = Date(Year(Date), Month(Date), Day(Date), 
//					                   Hour(vRRRH), Minute(vRRRH), 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				ElsIf Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
//					CheckInDate = Date(Year(Date), Month(Date), Day(Date), 
//					                   8, 0, 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				ElsIf Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
//					CheckInDate = Date(Year(Date), Month(Date), Day(Date), 
//					                   8, 0, 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				Else
//					CheckInDate = (Date + 1) + 
//					              vCoeff*vRRPer*3600; // + 1 period of ГруппаНомеров rate
//				EndIf;
//			EndIf;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(CheckOutDate) Тогда
//			CheckOutDate = cmCalculateCheckOutDate(Тариф, CheckInDate, Duration);
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmInitializePeriod
//
////-----------------------------------------------------------------------------
//// Calculates and returns duration for giving check in and check out dates
////-----------------------------------------------------------------------------
//Function pmCalculateDuration() Экспорт
//	Return cmCalculateDuration(Тариф, CheckInDate, CheckOutDate);
//EndFunction //pmCalculateDuration
//
////-----------------------------------------------------------------------------
//// Calculates and returns check out date based on giving duration and check in date
////-----------------------------------------------------------------------------
//Function pmCalculateCheckOutDate() Экспорт
//	vCheckOutDate = CheckOutDate;
//	If ЗначениеЗаполнено(Тариф) And
//	   ЗначениеЗаполнено(CheckInDate) Тогда
//		vCheckOutDate = cmCalculateCheckOutDate(Тариф, CheckInDate, Duration);
//	EndIf;
//	Return vCheckOutDate;
//EndFunction //pmCalculateCheckOutDate
//
////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Автор = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate
//
////-----------------------------------------------------------------------------
//Процедура pmCreateGuestGroup(pIsProbe = False) Экспорт
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ Гостиница.AssignReservationGuestGroupsManually Тогда
//			vGuestGroupFolder = Гостиница.GetObject().pmGetGuestGroupFolder();
//			vGuestGroupRef = Неопределено;
//			If pIsProbe Тогда
//				vGuestGroupRef = Справочники.ГруппыГостей.FindByCode(1, False, vGuestGroupFolder, Гостиница);
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vGuestGroupRef) Тогда
//				vGuestGroupObj = Справочники.ГруппыГостей.CreateItem();
//			Else
//				vGuestGroupObj = vGuestGroupRef.GetObject();
//				vGuestGroupObj.Read();
//			EndIf;
//			vGuestGroupObj.Owner = Гостиница;
//			If ЗначениеЗаполнено(vGuestGroupFolder) Тогда
//				vGuestGroupObj.Parent = vGuestGroupFolder;
//				If pIsProbe Тогда
//					vGuestGroupObj.Code = 1;
//				Else
//					vGuestGroupObj.SetNewCode();
//				EndIf;
//			Else
//				If pIsProbe Тогда
//					vGuestGroupObj.Code = 1;
//				EndIf;			
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
//Процедура pmCreateFolios() Экспорт
//	vChargingRules = Неопределено;
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		vParent = Контрагент.Parent;
//		While ЗначениеЗаполнено(vParent) Do
//			If vParent.ChargingRules.Count() > 0 Тогда
//				vChargingRules = vParent.ChargingRules.Unload();
//				Break;
//			EndIf;
//			vParent = vParent.Parent;
//		EndDo;
//	EndIf;
//	If vChargingRules = Неопределено Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If Гостиница.ChargingRules.Count() > 0 Тогда
//				vChargingRules = Гостиница.ChargingRules.Unload();
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check list of template rules
//	If vChargingRules = Неопределено Тогда
//		// Create new folio and take parameters from the hotel
//		vFolioObj = Documents.СчетПроживания.CreateDocument();
//		cmFillFolioFromTemplate(vFolioObj, Неопределено, Гостиница, Date);
//		vFolioObj.ДокОснование = pmGetThisDocumentRef();
//		vFolioObj.Фирма = Фирма;
//		vFolioObj.Клиент = Гость;
//		vFolioObj.ГруппаГостей = GuestGroup;
//		vFolioObj.DateTimeFrom = CheckInDate;
//		vFolioObj.DateTimeTo = CheckOutDate;
//		vFolioObj.Write(DocumentWriteMode.Write);
//		
//		// Add it to the charging rules
//		vCR = ChargingRules.Add();
//		vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.Any;
//		vCR.ChargingFolio = vFolioObj.Ref;
//		If ЗначениеЗаполнено(vFolioObj.Договор) Тогда
//			vCR.Owner = vFolioObj.Договор;
//		ElsIf ЗначениеЗаполнено(vFolioObj.Контрагент) Тогда
//			vCR.Owner = vFolioObj.Контрагент;
//		EndIf;
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
//				vFolioObj.ДокОснование = pmGetThisDocumentRef();
//				If НЕ vFolioObj.DoNotUpdateCompany Тогда
//					vFolioObj.Фирма = Фирма;
//				EndIf;
//				vFolioObj.Клиент = Гость;
//				vFolioObj.ГруппаГостей = GuestGroup;
//				vFolioObj.DateTimeFrom = CheckInDate;
//				vFolioObj.DateTimeTo = CheckOutDate;
//				vFolioObj.Write(DocumentWriteMode.Write);
//				
//				// Add it to the charging rules
//				vCR = ChargingRules.Add();
//				FillPropertyValues(vCR, vRule, , "ChargingFolio");
//				vCR.ChargingFolio = vFolioObj.Ref;
//				If ЗначениеЗаполнено(vFolioObj.Договор) Тогда
//					vCR.Owner = vFolioObj.Договор;
//				ElsIf ЗначениеЗаполнено(vFolioObj.Контрагент) Тогда
//					vCR.Owner = vFolioObj.Контрагент;
//				EndIf;
//			Else
//				// Copy charging rule
//				vCR = ChargingRules.Add();
//				FillPropertyValues(vCR, vRule);
//				If ЗначениеЗаполнено(vCR.ChargingFolio.Contract) Тогда
//					vCR.Owner = vCR.ChargingFolio.Contract;
//				ElsIf ЗначениеЗаполнено(vCR.ChargingFolio.Контрагент) Тогда
//					vCR.Owner = vCR.ChargingFolio.Контрагент;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmCreateFolios
//
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues(pIsProbe = False) Экспорт
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
//		If НЕ ЗначениеЗаполнено(ReservationStatus) Тогда
//			ReservationStatus = Гостиница.СтатусНовойБрониПоУмолчанию;
//			// Update DoCharging flag
//			pmSetDoCharging();
//		EndIf;
//		If НЕ ЗначениеЗаполнено(Тариф) Тогда
//			Тариф = Гостиница.Тариф;
//			If ЗначениеЗаполнено(Тариф) Тогда
//				// Source of business
//				If ЗначениеЗаполнено(Тариф.SourceOfBusiness) Тогда
//					SourceOfBusiness = Тариф.SourceOfBusiness;
//				EndIf;
//				// Marketing code
//				If ЗначениеЗаполнено(Тариф.MarketingCode) Тогда
//					MarketingCode = Тариф.MarketingCode;
//				EndIf;
//				// Client type
//				If ЗначениеЗаполнено(Тариф.ClientType) Тогда
//					ClientType = Тариф.ClientType;
//					ClientTypeConfirmationText = Тариф.ClientTypeConfirmationText;
//				EndIf;
//				// Фирма
//				If ЗначениеЗаполнено(Тариф.Фирма) Тогда
//					Фирма = Тариф.Фирма;
//				EndIf;
//			EndIf;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(RoomRateServiceGroup) Тогда
//			RoomRateServiceGroup = Гостиница.RoomRateServiceGroup;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(PlannedPaymentMethod) Тогда
//			PlannedPaymentMethod = Гостиница.PlannedPaymentMethod;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(ReportingCurrency) Тогда
//			ReportingCurrency = Гостиница.ReportingCurrency;
//		EndIf;
//		ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, Date);
//		If Duration = 0 Тогда
//			Duration = Гостиница.Duration;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(AccommodationType) Тогда
//			AccommodationType = cmGetDefaultAccommodationType(Гостиница, RoomType);
//		EndIf;
//		// Initialize document period
//		pmInitializePeriod();
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		ExchangeRateDate = Date;
//	EndIf;
//	If RoomQuantity = 0 Тогда
//		RoomQuantity = 1;
//	EndIf;
//	// Create guest group if is new
//	If НЕ ЗначениеЗаполнено(GuestGroup) Тогда
//		pmCreateGuestGroup(pIsProbe);
//	EndIf;
//	// Create document folio if is new
//	If ChargingRules.Count() = 0 Тогда
//		pmCreateFolios();
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateResources(pRecalculateNumberOfPersonsInReservation = False) Экспорт
//	vIsVirtual = False;
//	// Fill ГруппаНомеров or ГруппаНомеров type resources
//	If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		vRoomAttrs = ГруппаНомеров.GetObject().pmGetRoomAttributes(cm1SecondShift(CheckInDate));
//		For Each vRoomAttrsRow In vRoomAttrs Do
//			NumberOfBedsPerRoom = vRoomAttrsRow.КоличествоМестНомер;
//			NumberOfPersonsPerRoom = vRoomAttrsRow.КоличествоГостейНомер;
//			RoomType = vRoomAttrsRow.ТипНомера;
//			vIsVirtual = vRoomAttrsRow.ВиртуальныйНомер;
//			Break;
//		EndDo;
//	ElsIf ЗначениеЗаполнено(RoomType) Тогда
//		NumberOfBedsPerRoom = RoomType.NumberOfBedsPerRoom;
//		NumberOfPersonsPerRoom = RoomType.NumberOfPersonsPerRoom;
//		vIsVirtual = RoomType.IsVirtual;
//	EndIf;
//	// Fill accommodation type resources
//	If ЗначениеЗаполнено(AccommodationType) And НЕ vIsVirtual Тогда
//		If AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.Номер Тогда
//			NumberOfRooms = RoomQuantity * AccommodationType.КоличНомеров;
//			NumberOfBeds = ?(AccommodationType.КоличНомеров = 0, 0, RoomQuantity * NumberOfBedsPerRoom);
//			NumberOfAdditionalBeds = RoomQuantity * AccommodationType.КолДопМест;
//			If НЕ pRecalculateNumberOfPersonsInReservation Or AccommodationType.NumberOfPersons4Reservation = 0 Тогда
//				If NumberOfPersons = 0 Тогда
//					NumberOfPersons = AccommodationType.КолПрожив;
//				EndIf;
//			Else
//				NumberOfPersons = RoomQuantity * AccommodationType.NumberOfPersons4Reservation;
//			EndIf;
//		ElsIf AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.Кровать Тогда
//			NumberOfRooms = 0;
//			NumberOfBeds = RoomQuantity * AccommodationType.КолМест;
//			NumberOfAdditionalBeds = RoomQuantity * AccommodationType.КолДопМест;
//			If НЕ pRecalculateNumberOfPersonsInReservation Or AccommodationType.NumberOfPersons4Reservation = 0 Тогда
//				If NumberOfPersons = 0 Тогда
//					NumberOfPersons = AccommodationType.КолПрожив;
//				EndIf;
//			Else
//				NumberOfPersons = RoomQuantity * AccommodationType.NumberOfPersons4Reservation;
//			EndIf;
//		ElsIf AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.ДополнительноеМесто Тогда
//			NumberOfRooms = 0;
//			NumberOfBeds = 0;
//			NumberOfAdditionalBeds = RoomQuantity * AccommodationType.КолДопМест;
//			If НЕ pRecalculateNumberOfPersonsInReservation Or AccommodationType.NumberOfPersons4Reservation = 0 Тогда
//				If NumberOfPersons = 0 Тогда
//					NumberOfPersons = AccommodationType.КолПрожив;
//				EndIf;
//			Else
//				NumberOfPersons = RoomQuantity * AccommodationType.NumberOfPersons4Reservation;
//			EndIf;
//		ElsIf AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.Совместно Тогда
//			NumberOfRooms = 0;
//			NumberOfBeds = 0;
//			NumberOfAdditionalBeds = RoomQuantity * AccommodationType.КолДопМест;
//			If НЕ pRecalculateNumberOfPersonsInReservation Or AccommodationType.NumberOfPersons4Reservation = 0 Тогда
//				If NumberOfPersons = 0 Тогда
//					NumberOfPersons = AccommodationType.КолПрожив;
//				EndIf;
//			Else
//				NumberOfPersons = RoomQuantity * AccommodationType.NumberOfPersons4Reservation;
//			EndIf;
//		EndIf;
//		If AccommodationType.КолПрожив = 0 Тогда
//			NumberOfPersons = 0;
//		EndIf;
//	Else
//		NumberOfRooms = 0;
//		NumberOfBeds = 0;
//		NumberOfAdditionalBeds = 0;
//	EndIf;
//КонецПроцедуры //pmCalculateResources
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
//		vAccDisRes = vDiscountTypeObj.pmGetAccumulatingDiscountResources(BegOfDay(CheckInDate),
//		                                                                 Контрагент,
//		                                                                 Contract,
//		                                                                 Гость,
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
//Function pmFillTypesTable(pRoomRate = Неопределено) Экспорт
//	// Create table of valid ГруппаНомеров types and accommodation types
//	vTypesTable = New ValueTable();
//	vTypesTable.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//	vTypesTable.Columns.Add("RoomTypeSortCode", cmGetSortCodeTypeDescription());
//	vTypesTable.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
//	vTypesTable.Columns.Add("AccommodationTypeSortCode", cmGetSortCodeTypeDescription());
//	// Check ГруппаНомеров rate
//	vRoomRate = Тариф;
//	If ЗначениеЗаполнено(pRoomRate) Тогда
//		vRoomRate = pRoomRate;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(vRoomRate) Тогда
//		Return vTypesTable;
//	EndIf;
//	// Initialize empty types flags
//	vIsEmptyRoomType = False;
//	vIsEmptyAccommodationType = False;
//	// Get list of price records for the given ГруппаНомеров rate
//	vPrices = vRoomRate.GetObject().pmGetRoomRatePrices(CheckInDate, ?(ЗначениеЗаполнено(PriceCalculationDate), PriceCalculationDate, Неопределено), ClientType, , , , , CheckInDate, CheckOutDate);
//	If ЗначениеЗаполнено(ClientType) And vPrices.Count() = 0 Тогда
//		vPrices = vRoomRate.GetObject().pmGetRoomRatePrices(CheckInDate, ?(ЗначениеЗаполнено(PriceCalculationDate), PriceCalculationDate, Неопределено), Справочники.ClientTypes.EmptyRef(), , , , , CheckInDate, CheckOutDate);
//	EndIf;
//	// Fill table with all type combinations from the price records
//	For Each vPricesRow In vPrices Do
//		If vPricesRow.IsRoomRevenue And vPricesRow.IsInPrice Тогда
//			vTypesTableRow = vTypesTable.Add();
//			vTypesTableRow.ТипНомера = vPricesRow.ТипНомера;
//			vTypesTableRow.ВидРазмещения = vPricesRow.ВидРазмещения;
//			If НЕ ЗначениеЗаполнено(vTypesTableRow.ТипНомера) Тогда
//				vIsEmptyRoomType = True;
//			Else
//				vTypesTableRow.RoomTypeSortCode = vPricesRow.RoomTypeSortCode;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vTypesTableRow.ВидРазмещения) Тогда
//				vIsEmptyAccommodationType = True;
//			Else
//				vTypesTableRow.AccommodationTypeSortCode = vPricesRow.AccommodationTypeSortCode;
//			EndIf;
//		EndIf;
//	EndDo;
//	// Group all types combinations
//	vTypesTable.GroupBy("ТипНомера, RoomTypeSortCode, ВидРазмещения, AccommodationTypeSortCode",);
//	// Detail empty ГруппаНомеров type records
//	If vIsEmptyRoomType Тогда
//		vRoomTypes = cmGetAllRoomTypes(Гостиница);
//		i = 0;
//		While i < vTypesTable.Count() Do
//			vTypesTableRow = vTypesTable.Get(i);
//			If НЕ ЗначениеЗаполнено(vTypesTableRow.ТипНомера) Тогда
//				vCurAccommodationType = vTypesTableRow.ВидРазмещения;
//				vCurAccommodationTypeSortCode = vTypesTableRow.AccommodationTypeSortCode;
//				vTypesTable.Delete(i);
//				For Each vRoomType In vRoomTypes Do
//					vTypesTableRow = vTypesTable.Вставить(i);
//					vTypesTableRow.ТипНомера = vRoomType.ТипНомера;
//					vTypesTableRow.RoomTypeSortCode = vRoomType.ТипНомера.ПорядокСортировки;
//					vTypesTableRow.ВидРазмещения = vCurAccommodationType;
//					vTypesTableRow.AccommodationTypeSortCode = vCurAccommodationTypeSortCode;
//					i = i + 1;
//				EndDo;
//			Else
//				i = i + 1;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Detail empty accommodation type records
//	If vIsEmptyAccommodationType Тогда
//		vAccommodationTypes = cmGetAllAccommodationTypes();
//		i = 0;
//		While i < vTypesTable.Count() Do
//			vTypesTableRow = vTypesTable.Get(i);
//			If НЕ ЗначениеЗаполнено(vTypesTableRow.ВидРазмещения) Тогда
//				vCurRoomType = vTypesTableRow.ТипНомера;
//				vCurRoomTypeSortCode = vTypesTableRow.RoomTypeSortCode;
//				vTypesTable.Delete(i);
//				For Each vAccommodationType In vAccommodationTypes Do
//					vTypesTableRow = vTypesTable.Вставить(i);
//					vTypesTableRow.ТипНомера = vCurRoomType;
//					vTypesTableRow.RoomTypeSortCode = vCurRoomTypeSortCode;
//					vTypesTableRow.ВидРазмещения = vAccommodationType.ВидРазмещения;
//					vTypesTableRow.AccommodationTypeSortCode = vAccommodationType.ВидРазмещения.ПорядокСортировки;
//					i = i + 1;
//				EndDo;
//			Else
//				i = i + 1;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Sort table by sort codes
//	vTypesTable.Sort("RoomTypeSortCode, AccommodationTypeSortCode");
//	// Return
//	Return vTypesTable;
//EndFunction //pmFillTypesTable
//
////-----------------------------------------------------------------------------
//// Get reservation prices for all day types of ГруппаНомеров rate
////-----------------------------------------------------------------------------
//Function pmCalculatePricePresentation(Val pLang = Неопределено) Экспорт
//	If ЗначениеЗаполнено(ReservationStatus) Тогда
//		If НЕ ReservationStatus.IsActive Тогда
//			If ReservationStatus.DoNoShowCharging Or ReservationStatus.DoLateAnnulationCharging Тогда
//				Return PricePresentation;
//			EndIf;
//		EndIf;
//	EndIf;
//	vPricePresentation = "";
//	If pLang = Неопределено Тогда
//		pLang = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	vPrices = pmGetPrices();
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.UseMaximumPriceInPricePresentation Тогда
//		vMaxPrice = 0;
//		vMaxPriceCurrency = Гостиница.BaseCurrency;
//		For Each vPrice In vPrices Do
//			If vPrice.Цена > vMaxPrice Тогда
//				vMaxPrice = vPrice.Цена;
//				vMaxPriceCurrency = vPrice.ВалютаЛицСчета;
//			EndIf;
//		EndDo;
//		vPricePresentation = cmFormatSum(vMaxPrice, vMaxPriceCurrency, "NZ=---", pLang);
//	Else
//		For Each vPrice In vPrices Do
//			If НЕ IsBlankString(vPricePresentation) Тогда
//				vPricePresentation = vPricePresentation + Chars.LF;
//			EndIf;
//			If ЗначениеЗаполнено(vPrice.УчетнаяДата) Тогда
//				vPricePresentation = vPricePresentation + cmFormatSum(vPrice.Цена, vPrice.ВалютаЛицСчета, "NZ=---", pLang) + 
//				                     " - " + Format(vPrice.УчетнаяДата, "DF=dd.MM");
//			Else
//				vPricePresentation = vPricePresentation + cmFormatSum(vPrice.Цена, vPrice.ВалютаЛицСчета, "NZ=---", pLang) + 
//				                     ?(ЗначениеЗаполнено(vPrice.ТипДняКалендаря), " - " + vPrice.ТипДняКалендаря.GetObject().pmGetDayTypeDescription(pLang), "");
//			EndIf;
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
//Function pmGetComplexCommission() Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT TOP 1
//	|	CommissionSliceLast.Period AS SliceLastPeriod,
//	|	CommissionSliceLast.Агент AS SliceLastAgent,
//	|	CommissionSliceLast.Договор AS SliceLastContract,
//	|	CommissionSliceLast.ServiceGroup AS SliceLastServiceGroup,
//	|	CommissionSliceLast.Гостиница AS SliceLastHotel,
//	|	CommissionSliceLast.Комиссия AS SliceLastCommission,
//	|	CommissionSliceLast.CommissionType AS SliceLastCommissionType
//	|INTO CommissionSliceLast
//	|FROM
//	|	InformationRegister.Комиссия.SliceLast(
//	|			&qPeriod,
//	|			Агент = &qAgent
//	|				AND Договор = &qContract
//	|				AND (Гостиница = &qHotel
//	|					OR Гостиница = &qEmptyHotel)) AS CommissionSliceLast
//	|
//	|ORDER BY
//	|	SliceLastPeriod DESC,
//	|	CommissionSliceLast.ServiceGroup.Code
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	ComplexCommission.Period AS Period,
//	|	ComplexCommission.Агент AS Агент,
//	|	ComplexCommission.Договор,
//	|	ComplexCommission.ServiceGroup AS ServiceGroup,
//	|	ComplexCommission.Гостиница,
//	|	ComplexCommission.Комиссия,
//	|	ComplexCommission.CommissionType
//	|FROM
//	|	InformationRegister.Комиссия AS ComplexCommission
//	|		INNER JOIN CommissionSliceLast AS CommissionSliceLast
//	|		ON ComplexCommission.Period = CommissionSliceLast.SliceLastPeriod
//	|			AND ComplexCommission.Агент = CommissionSliceLast.SliceLastAgent
//	|			AND ComplexCommission.Договор = CommissionSliceLast.SliceLastContract
//	|			AND ComplexCommission.Гостиница = CommissionSliceLast.SliceLastHotel
//	|
//	|ORDER BY
//	|	ComplexCommission.ServiceGroup.Code";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
//	vQry.SetParameter("qAgent", Agent);
//	vQry.SetParameter("qContract", Contract);
//	vQry.SetParameter("qPeriod", CheckInDate);
//	vComplexCommission = vQry.Execute().Unload();
//	Return vComplexCommission;
//EndFunction //pmGetComplexCommission
//
////-----------------------------------------------------------------------------
//// Calculates services for the given document.
//// Returns False if warnings were rised during services calculation. Otherwise
//// returns True
////-----------------------------------------------------------------------------
//Function pmCalculateServices(rWarnings = "", pPeriodDiscount = 0, pPeriodDiscountType = Неопределено, 
//                                             pPeriodDiscountServiceGroup = Неопределено, pPeriodDiscountConfirmationText = "") Экспорт
//	vWarnings = False;
//	vNoAccommodationService = True;
//	vCurPriceTag = Неопределено;
//	// Create table of charging rules
//	vCRTab = ChargingRules.Unload();
//	cmAddGuestGroupChargingRules(vCRTab, GuestGroup);
//	// Create table of manual prices
//	vMPTab = Prices.Unload();
//	// Create table of current services calendar day types for accounting dates
//	vDayTypes = Services.Unload();
//	vDayTypes.GroupBy("УчетнаяДата, Услуга, ТипДеньКалендарь, Тариф, ПризнакЦены", );
//	If НЕ ЗначениеЗаполнено(PriceCalculationDate) Тогда
//		vDayTypes.Clear();
//	EndIf;
//	// Save services with prices changed manually
//	vMCServices = Services.Unload();
//	vMCServices.Columns.Add("СпособОплаты", cmGetCatalogTypeDescription("СпособОплаты"));
//	i = 0;
//	While i < vMCServices.Count() Do
//		vSrv = vMCServices.Get(i);
//		If НЕ vSrv.IsManualPrice Тогда
//			vMCServices.Delete(i);
//		Else
//			If ЗначениеЗаполнено(vSrv.СчетПроживания) Тогда
//				vSrv.СпособОплаты = vSrv.СчетПроживания.СпособОплаты;
//			EndIf;
//			i = i + 1;
//		EndIf;
//	EndDo;
//	// First clear ГруппаНомеров rate services
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
//	// If reservation is not active and no show service should be charged then clear manual services
//	If ЗначениеЗаполнено(ReservationStatus) Тогда
//		If НЕ ReservationStatus.IsActive And 
//		   ReservationStatus.DoCharging And
//		   (ReservationStatus.DoNoShowCharging Or ReservationStatus.DoLateAnnulationCharging) Тогда
//			Services.Clear();
//		EndIf;
//	EndIf;
//	// Check folios for the manual services
//	pmSetFolioBasedOnChargingRules(Services, True);
//	// Check that ГруппаНомеров rate is filled
//	If НЕ ЗначениеЗаполнено(Тариф) Тогда
//		PricePresentation = "";
//		Return vWarnings;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Тариф.Calendar) Тогда
//		PricePresentation = "";
//		Return vWarnings;
//	EndIf;
//	// Check if we should do no show charge only
//	vCurFeeTerms = Неопределено;
//	vDoNoShowCharging = False;
//	vDoLateAnnulationCharging = False;
//	If ЗначениеЗаполнено(ReservationStatus) Тогда
//		If НЕ ReservationStatus.IsActive And 
//		  (ReservationStatus.DoNoShowCharging Or ReservationStatus.DoLateAnnulationCharging) Тогда
//			If ЗначениеЗаполнено(FeeTerms) Тогда
//				vCurFeeTerms = FeeTerms;
//			Else
//				If ЗначениеЗаполнено(Contract) And ЗначениеЗаполнено(Contract.FeeTerms) Тогда
//					vCurFeeTerms = Contract.FeeTerms;
//				ElsIf ЗначениеЗаполнено(Контрагент) And ЗначениеЗаполнено(Контрагент.FeeTerms) Тогда
//					vCurFeeTerms = Контрагент.FeeTerms;
//				ElsIf ЗначениеЗаполнено(Тариф) And ЗначениеЗаполнено(Тариф.FeeTerms) Тогда
//					vCurFeeTerms = Тариф.FeeTerms;
//				EndIf;
//			EndIf;
//			If ЗначениеЗаполнено(vCurFeeTerms) Тогда
//				If ReservationStatus.DoNoShowCharging Тогда
//					vDoNoShowCharging = True;
//				ElsIf ReservationStatus.DoLateAnnulationCharging Тогда
//					vDoLateAnnulationCharging = True;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Get list of accumulating discount types with actual resources
//	vAccDiscounts = pmGetAccumulatingDiscountResources();
//	// Initialize value of discount that should be applied to the whole reservation period
//	vPeriodDiscount = pPeriodDiscount;
//	vPeriodDiscountType = pPeriodDiscountType;
//	vPeriodDiscountServiceGroup = pPeriodDiscountServiceGroup;
//	vPeriodDiscountConfirmationText = pPeriodDiscountConfirmationText;
//	// Build list of service packages
//	vServicePackagesList = New СписокЗначений();
//	If ЗначениеЗаполнено(ServicePackage) Тогда
//		vServicePackagesList.Add(ServicePackage);
//	EndIf;
//	For Each vServicePackagesRow In ServicePackages Do
//		If ЗначениеЗаполнено(vServicePackagesRow.ServicePackage) Тогда
//			vServicePackagesList.Add(vServicePackagesRow.ServicePackage);
//		EndIf;
//	EndDo;
//	// Fill period
//	vCheckInDate = CheckInDate;
//	vCheckOutDate = CheckOutDate;
//	If ЗначениеЗаполнено(HotelProduct) Тогда
//		If HotelProduct.FixProductPeriod Тогда
//			vCheckInDate = HotelProduct.CheckInDate;
//			vCheckOutDate = HotelProduct.CheckOutDate;
//		EndIf;
//	EndIf;
//	// Get and check ГруппаНомеров rate restrictions
//	vRestrStruct = Тариф.GetObject().pmGetRoomRateRestrictions(CheckInDate, CheckOutDate, ?(ЗначениеЗаполнено(RoomTypeUpgrade), RoomTypeUpgrade, RoomType), True);
//	If vRestrStruct.CTA And НЕ ReservationStatus.IsCheckIn And НЕ ReservationStatus.IsNoShow And (ReservationStatus.IsActive Or ReservationStatus.IsPreliminary Or ReservationStatus.IsInWaitingList) Тогда
//		PricePresentation = "";
//		vWarnings = True;
//		vWarningsEn = "Check-in is closed (CTA is On) for the given check-in date " + Format(CheckInDate, "DF=dd.MM.yyyy") + "!";
//		vWarningsDe = "Check-in ist für den Check-in-Datum " + Format(CheckInDate, "DF=dd.MM.yyyy") + " geschlossen (CTA is On)!";
//		vWarningsRu = "Заезд в выбранную дату " + Format(CheckInDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTA включен)!";
//		rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
//		Return vWarnings;
//	EndIf;
//	If vRestrStruct.CTD And НЕ ReservationStatus.IsCheckIn And НЕ ReservationStatus.IsNoShow And (ReservationStatus.IsActive Or ReservationStatus.IsPreliminary Or ReservationStatus.IsInWaitingList) Тогда
//		PricePresentation = "";
//		vWarnings = True;
//		vWarningsEn = "Check-out is closed (CTD is On) for the given check-out date " + Format(CheckOutDate, "DF=dd.MM.yyyy") + "!";
//		vWarningsDe = "Check-out ist für den Check-out-Datum " + Format(CheckOutDate, "DF=dd.MM.yyyy") + " geschlossen (CTD is On)!";
//		vWarningsRu = "Выезд в выбранную дату " + Format(CheckOutDate, "DF=dd.MM.yyyy") + " запрещен в ограничениях указанных у тарифа (CTD включен)!";
//		rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
//		Return vWarnings;
//	EndIf;
//	If vRestrStruct.MLOS > 0 And Duration < vRestrStruct.MLOS Тогда
//		If Int((BegOfDay(vCheckOutDate) - BegOfDay(vCheckInDate))/(24*3600)) < vRestrStruct.MLOS Тогда
//			vCheckOutDate = cm0SecondShift(BegOfDay(vCheckInDate) + (vCheckOutDate - BegOfDay(vCheckOutDate)) + 24*3600*vRestrStruct.MLOS);
//		EndIf;
//		If Тариф.MLOSIsBlocking Тогда
//			PricePresentation = "";
//			vWarnings = True;
//			vWarningsRu = "Минимальная продолжительность проживания " + vRestrStruct.MLOS + " дней!";
//			vWarningsEn = "Minimum length of stay is " + vRestrStruct.MLOS + "!";
//			vWarningsDe = "Mindestaufenthaltsdauer beträgt " + vRestrStruct.MLOS + " Tage!";
//			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
//			Return vWarnings;
//		EndIf;
//	EndIf;
//	If vRestrStruct.MaxLOS > 0 And Duration > vRestrStruct.MaxLOS Тогда
//		PricePresentation = "";
//		vWarnings = True;
//		vWarningsRu = "Максимальная продолжительность проживания " + vRestrStruct.MaxLOS + " дней!";
//		vWarningsEn = "Maximum length of stay is " + vRestrStruct.MaxLOS + "!";
//		vWarningsDe = "Maximaleaufenthaltsdauer beträgt " + vRestrStruct.MaxLOS + " Tage!";
//		rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
//		Return vWarnings;
//	EndIf;
//	If vRestrStruct.MinDaysBeforeCheckIn > 0 Тогда
//		vDaysBeforeCheckIn = Int((BegOfDay(vCheckInDate) - BegOfDay(Date))/(24*3600));
//		If vDaysBeforeCheckIn < vRestrStruct.MinDaysBeforeCheckIn Тогда
//			PricePresentation = "";
//			vWarnings = True;
//			vWarningsRu = "Минимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MinDaysBeforeCheckIn + "!";
//			vWarningsEn = "Minimum days between booking and check-in dates is " + vRestrStruct.MinDaysBeforeCheckIn + "!";
//			vWarningsDe = "Mindest Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MinDaysBeforeCheckIn + "!";
//			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
//			Return vWarnings;
//		EndIf;
//	EndIf;
//	If vRestrStruct.MaxDaysBeforeCheckIn > 0 Тогда
//		vDaysBeforeCheckIn = Int((BegOfDay(vCheckInDate) - BegOfDay(Date))/(24*3600));
//		If vDaysBeforeCheckIn > vRestrStruct.MaxDaysBeforeCheckIn Тогда
//			PricePresentation = "";
//			vWarnings = True;
//			vWarningsRu = "Максимальное кол-во дней от даты бронирования до даты заезда " + vRestrStruct.MaxDaysBeforeCheckIn + "!";
//			vWarningsEn = "Maximum days between booking and check-in dates is " + vRestrStruct.MaxDaysBeforeCheckIn + "!";
//			vWarningsDe = "Maximale Tage zwischen Buchung und Check-in Daten ist " + vRestrStruct.MaxDaysBeforeCheckIn + "!";
//			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
//			Return vWarnings;
//		EndIf;
//	EndIf;
//	// Get accommodation condition periods
//	vAccommodationPeriods = pmGetAccommodationPeriods();
//	// Get and check ГруппаНомеров rate restrictions
//	vBegOfCheckInDate = BegOfDay(vCheckInDate);
//	vBegOfCheckOutDate = BegOfDay(vCheckOutDate);
//	// Fill occupation percents
//	vOccupationPercentsAreFilled = False;
//	If ЗначениеЗаполнено(Тариф) And ЗначениеЗаполнено(RoomType) Тогда
//		If Тариф.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercent Or 
//		   Тариф.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomType Or 
//		   Тариф.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Тогда
//			vOccupationPercentsAreFilled = True;
//			pmFillOccupationPercents(vBegOfCheckInDate, vBegOfCheckOutDate);
//		EndIf;
//	EndIf;
//	// Get list of price records for the given ГруппаНомеров rate
//	vRoom = ГруппаНомеров;
//	vRoomRoomType = RoomType;
//	vRoomType = RoomType;
//	If ЗначениеЗаполнено(RoomTypeUpgrade) Тогда
//		vRoomType = RoomTypeUpgrade;
//	EndIf;
//	vBasePrices = Тариф.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, ClientType, vRoomType, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate);
//	If ЗначениеЗаполнено(ClientType) And vBasePrices.Count() = 0 Тогда
//		vBasePrices = Тариф.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, Справочники.ClientTypes.EmptyRef(), vRoomType, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate);
//	EndIf;
//	// Check if we have other ГруппаНомеров types specified in the charging rules
//	vCRRoomTypePrices = New ValueTable();
//	vCRRoomTypePrices.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//	vCRRoomTypePrices.Columns.Add("Prices");
//	For Each vCRRow In vCRTab Do
//		If TypeOf(vCRRow.ChargingRuleValue) = Type("CatalogRef.ТипыНомеров") And 
//		   ЗначениеЗаполнено(vCRRow.ChargingRuleValue) Тогда
//			If vCRRoomTypePrices.Find(vCRRow.ChargingRuleValue, "ТипНомера") = Неопределено Тогда
//				vCRRoomTypePricesRow = vCRRoomTypePrices.Add();
//				vCRRoomTypePricesRow.ТипНомера = vCRRow.ChargingRuleValue;
//				vCRRoomTypePricesTable = Тариф.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, ClientType, vCRRoomTypePricesRow.ТипНомера, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate);
//				If ЗначениеЗаполнено(ClientType) And vCRRoomTypePricesTable.Count() = 0 Тогда
//					vCRRoomTypePricesTable = Тариф.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, Справочники.ClientTypes.EmptyRef(), vCRRoomTypePricesRow.ТипНомера, AccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate);
//				EndIf;
//				vCRRoomTypePricesRow.Prices = vCRRoomTypePricesTable;
//			EndIf;
//		EndIf;
//	EndDo;
//	// Build value table of ГруппаНомеров rates per accounting days
//	vRoomRates = pmGetAccommodationPlan();
//	vRoomRates.Columns.Add("Prices");
//	If vRoomRates.Count() > 0 Тогда
//		vRoomRatesDimensions = vRoomRates.Copy();
//		vRoomRatesDimensions.GroupBy("Тариф, ВидРазмещения, ТипНомера", );
//		vRoomRatesDimensions.Columns.Add("Prices");
//		For Each vRoomRatesDimensionsRow In vRoomRatesDimensions Do
//			vDimensionRoomRate = ?(ЗначениеЗаполнено(vRoomRatesDimensionsRow.Тариф), vRoomRatesDimensionsRow.Тариф, Тариф);
//			vDimensionAccommodationType = ?(ЗначениеЗаполнено(vRoomRatesDimensionsRow.ВидРазмещения), vRoomRatesDimensionsRow.ВидРазмещения, AccommodationType);
//			vDimensionRoomType = ?(ЗначениеЗаполнено(vRoomRatesDimensionsRow.ТипНомера) And НЕ ЗначениеЗаполнено(RoomTypeUpgrade), vRoomRatesDimensionsRow.ТипНомера, vRoomType);
//			vDimensionPrices = vDimensionRoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, ClientType, vDimensionRoomType, vDimensionAccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate);
//			If ЗначениеЗаполнено(ClientType) And vDimensionPrices.Count() = 0 Тогда
//				vDimensionPrices = vDimensionRoomRate.GetObject().pmGetRoomRatePrices(vCheckInDate, PriceCalculationDate, Справочники.ClientTypes.EmptyRef(), vDimensionRoomType, vDimensionAccommodationType, vServicePackagesList, , vCheckInDate, vCheckOutDate);
//			EndIf;
//			vRoomRatesDimensionsRow.Prices = vDimensionPrices;
//		EndDo;
//		For Each vRoomRatesRow In vRoomRates Do
//			vRoomRatesDimensionsRows = vRoomRatesDimensions.FindRows(New Structure("Тариф, ВидРазмещения, ТипНомера", vRoomRatesRow.Тариф, vRoomRatesRow.ВидРазмещения, vRoomRatesRow.ТипНомера));
//			If vRoomRatesDimensionsRows.Count() > 0 Тогда
//				vRoomRatesDimensionsRow = vRoomRatesDimensionsRows.Get(0);
//				vRoomRatesRow.Prices = vRoomRatesDimensionsRow.Prices;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Get complex commission
//	vComplexCommission = pmGetComplexCommission();
//	// Create discount type object
//	vIsAmountDiscount = False;
//	vUseDocumentDiscount = False;
//	vFixedDiscount = Discount;
//	vFixedDiscountTypeObj = Неопределено;
//	If ЗначениеЗаполнено(DiscountType) Тогда
//		vFixedDiscountTypeObj = DiscountType.GetObject();
//		If DiscountType.IsAmountDiscount Тогда
//			vIsAmountDiscount = True;
//			vUseDocumentDiscount = True;
//		Else
//			If НЕ DiscountType.IsAccumulatingDiscount And НЕ DiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//				vFixedDiscountPercent = vFixedDiscountTypeObj.pmGetDiscount(CheckInDate, , Гостиница);
//				If vFixedDiscountPercent <> vFixedDiscount Тогда
//					vUseDocumentDiscount = True;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Build value table of discount percents per days
//	vDiscountPercents = New ValueTable();
//	vDiscountPercents.Columns.Add("УчетнаяДата", cmGetDateTypeDescription());
//	vDiscountPercents.Columns.Add("Скидка", cmGetDiscountTypeDescription());
//	// Build value table of discount percents per services
//	vFixedServiceDiscount = 0;
//	vFixedDiscountPercents = New ValueTable();
//	vFixedDiscountPercents.Columns.Add("УчетнаяДата", cmGetDateTypeDescription());
//	vFixedDiscountPercents.Columns.Add("Услуга", cmGetCatalogTypeDescription("Услуги"));
//	vFixedDiscountPercents.Columns.Add("Скидка", cmGetDiscountTypeDescription());
//	vServices = vBasePrices.Copy(, "Услуга");
//	vServices.GroupBy("Услуга", );
//	// Get list of days with day types from ГруппаНомеров rate calendar
//	vDays = Тариф.Calendar.GetObject().pmGetDays(vCheckInDate, vCheckOutDate);
//	If vCheckInDate >= vCheckOutDate Тогда
//		vDays.Clear();
//	EndIf;
//	// Calculate quantity for each service from ГруппаНомеров rate
//	i = 0;
//	vFirstDayWithAccommodationService = True;
//	vFirstPeriod = Неопределено;
//	vRestOfCurAmount = 0;
//	vRestOfServiceSum = 0;
//	vChargingRuleAmountIsSet = False;
//	For Each vDayRow In vDays Do
//		vCurAccountingDate = vDayRow.Period;
//		If vFirstPeriod = Неопределено Тогда
//			vFirstPeriod = vCurAccountingDate;
//		EndIf;
//		vCurCalendarDayType = vDayRow.ТипДняКалендаря;
//		vCurTimetable = vDayRow.Timetable;
//		vCurPriceTag = Справочники.ПризнакЦены.EmptyRef();
//		// Build value table of discount percents per services
//		If ЗначениеЗаполнено(DiscountType) Тогда
//			If vCurAccountingDate >= DiscountType.DateValidFrom And 
//			   (НЕ ЗначениеЗаполнено(DiscountType.DateValidTo) Or ЗначениеЗаполнено(DiscountType.DateValidTo) And vCurAccountingDate <= DiscountType.DateValidTo) Тогда
//				If DiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Тогда
//					For Each vServicesRow In vServices Do
//						If cmIsServiceInServiceGroup(vServicesRow.Услуга, DiscountServiceGroup) Тогда
//							vFixedDiscountPercentsRow = vFixedDiscountPercents.Add();
//							vFixedDiscountPercentsRow.УчетнаяДата = vCurAccountingDate;
//							vFixedDiscountPercentsRow.Услуга = vServicesRow.Услуга;
//							vFixedDiscountPercentsRow.Скидка = vFixedDiscountTypeObj.pmGetDiscount(vCurAccountingDate, vServicesRow.Услуга, Гостиница);
//						EndIf;
//					EndDo;
//				Else
//					vDiscountPercentsRow = vDiscountPercents.Add();
//					vDiscountPercentsRow.УчетнаяДата = vCurAccountingDate;
//					vDiscountPercentsRow.Скидка = vFixedDiscountTypeObj.pmGetDiscount(vCurAccountingDate, , Гостиница);
//				EndIf;
//			EndIf;
//		EndIf;
//		// Get prices for the current accounting date
//		vPrices = vBasePrices;
//		vRoomRate = Тариф;
//		vAccommodationType = AccommodationType;
//		vRoomRatesRow = vRoomRates.Find(vCurAccountingDate, "УчетнаяДата");
//		If vRoomRatesRow <> Неопределено Тогда
//			vPrices = vRoomRatesRow.Prices;
//			If ЗначениеЗаполнено (vRoomRatesRow.Тариф) Тогда
//				vRoomRate = vRoomRatesRow.Тариф;
//				vCurCalendarDayType = cmGetCalendarDayType(vRoomRate, vCurAccountingDate, vCheckInDate, vCheckOutDate);
//			EndIf;
//			If ЗначениеЗаполнено (vRoomRatesRow.ВидРазмещения) Тогда
//				vAccommodationType = vRoomRatesRow.ВидРазмещения;
//			EndIf;
//			If ЗначениеЗаполнено(vRoomRatesRow.ТипНомера) And НЕ ЗначениеЗаполнено(RoomTypeUpgrade) Тогда
//				vRoomType = vRoomRatesRow.ТипНомера;
//			EndIf;
//			If ЗначениеЗаполнено(vRoomRatesRow.ТипНомера) Тогда
//				vRoomRoomType = vRoomRatesRow.ТипНомера;
//			EndIf;
//			If ЗначениеЗаполнено(vRoomRatesRow.НомерРазмещения) Тогда
//				vRoom = vRoomRatesRow.НомерРазмещения;
//			EndIf;
//		EndIf;
//		vDoesNotAffectRoomRevenueStatistics = False;
//		If ЗначениеЗаполнено(vRoomRoomType) Тогда
//			vDoesNotAffectRoomRevenueStatistics = vRoomRoomType.DoesNotAffectRoomRevenueStatistics;
//		EndIf;
//		// Check should we take price tags into account or not and 
//		// try to find appropriate price tag for the current accounting date
//		vPriceTagsAreUsed = False;
//		If ЗначениеЗаполнено(vRoomRate) Тогда
//			If ЗначениеЗаполнено(vRoomRate.PriceTagType) Тогда
//				vPriceTagsAreUsed = True;
//				vPriceTagRanges = cmGetPriceTagRanges(Гостиница, vRoomRate.PriceTagType, vCurAccountingDate);
//				If vRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByDurationOfStayByDays Тогда
//					vCurDurationInDays = (vCurAccountingDate - vBegOfCheckInDate)/(24*3600) + 1;
//					vCurDurationInDays = ?(vCurDurationInDays < 0, 0, vCurDurationInDays);
//					For Each vPriceTagRangesRow In vPriceTagRanges Do
//						If vCurDurationInDays >= vPriceTagRangesRow.StartValue And vCurDurationInDays <= vPriceTagRangesRow.EndValue Тогда
//							vCurPriceTag = vPriceTagRangesRow.ПризнакЦены;
//							Break;
//						EndIf;
//					EndDo;
//				ElsIf vRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByDurationOfStayByPeriod Тогда
//					vCurDurationInDays = (vBegOfCheckOutDate - vBegOfCheckInDate)/(24*3600);
//					vCurDurationInDays = ?(vCurDurationInDays <= 0, 1, vCurDurationInDays);
//					For Each vPriceTagRangesRow In vPriceTagRanges Do
//						If vCurDurationInDays >= vPriceTagRangesRow.StartValue And vCurDurationInDays <= vPriceTagRangesRow.EndValue Тогда
//							vCurPriceTag = vPriceTagRangesRow.ПризнакЦены;
//							Break;
//						EndIf;
//					EndDo;
//				ElsIf vRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercent Or 
//					  vRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomType Or 
//					  vRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Тогда
//					If НЕ vOccupationPercentsAreFilled And ЗначениеЗаполнено(Тариф) And ЗначениеЗаполнено(RoomType) Тогда
//						vOccupationPercentsAreFilled = True;
//						pmFillOccupationPercents(vBegOfCheckInDate, vBegOfCheckOutDate);
//					EndIf;
//					vCurOccupancyPercentRow = OccupationPercents.Find(vCurAccountingDate, "УчетнаяДата");
//					If vCurOccupancyPercentRow <> Неопределено Тогда
//						vCurOccupancyPercent = vCurOccupancyPercentRow.OccupationPercent;
//						For Each vPriceTagRangesRow In vPriceTagRanges Do
//							If vCurOccupancyPercent >= vPriceTagRangesRow.StartValue And vCurOccupancyPercent <= vPriceTagRangesRow.EndValue Тогда
//								vCurPriceTag = vPriceTagRangesRow.ПризнакЦены;
//								Break;
//							EndIf;
//						EndDo;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//		// Process each row in prices
//		For Each vPricesRow In vPrices Do
//			vCurService = vPricesRow.Услуга;
//			vCurIsRoomRevenue = vPricesRow.IsRoomRevenue;
//			vCurRoomRevenueAmountsOnly = ?(vDoesNotAffectRoomRevenueStatistics, vDoesNotAffectRoomRevenueStatistics, vPricesRow.RoomRevenueAmountsOnly);
//			vCurIsInPrice = vPricesRow.IsInPrice;
//			vCurAccountingDate = vDayRow.Period;
//			// Try to restore old calendar day type and old price tag values
//			If НЕ vPriceTagsAreUsed And НЕ vRoomRate.Calendar.IsPerPeriod Тогда
//				// Accounting date could be changed in cmCalculateServiceQuantity and we have to use this shifted date in search of old day type
//				vTmpMinQuantity = vPricesRow.MinimumQuantity;
//				vTmpRemarks = "";
//				vTmpPrice = vPricesRow.Цена;
//				vTmpCurrency = vPricesRow.Валюта;
//				vTmpAccountingDate = vCurAccountingDate;
//				// Calculate quantity
//				vTmpQuantity = cmCalculateServiceQuantity(vCurService, vPricesRow.QuantityCalculationRule, 
//				                                          vTmpAccountingDate, vCheckInDate, vCheckOutDate, 
//				                                          ThisObject, ThisObject, True, True, False, False, True, True, 
//				                                          vTmpPrice, vTmpCurrency, vTmpRemarks, , vTmpMinQuantity, vAccommodationPeriods);
//				// Search old service with the same accounting date
//				vDayTypeRows = vDayTypes.FindRows(New Structure("УчетнаяДата, Услуга", vTmpAccountingDate, vCurService));
//				If vDayTypeRows.Count() = 1 Тогда
//					vDayTypeRow = vDayTypeRows.Get(0);
//					If ЗначениеЗаполнено(vDayTypeRow.ТипДняКалендаря) And vDayTypeRow.Тариф = vRoomRate Тогда
//						vCurCalendarDayType = vDayTypeRow.ТипДняКалендаря;
//						vCurPriceTag = vDayTypeRow.ПризнакЦены;
//					EndIf;
//				EndIf;
//			EndIf;
//			// Check price tags
//			If vPriceTagsAreUsed Тогда
//				If vCurPriceTag <> vPricesRow.ПризнакЦены Тогда
//					Continue;
//				EndIf;
//			ElsIf ЗначениеЗаполнено(vPricesRow.ПризнакЦены) Тогда
//				Continue;
//			EndIf;
//			// Retrieve current fixed discount
//			vFixedServiceDiscount = 0;
//			If НЕ vUseDocumentDiscount Тогда
//				If vFixedDiscountPercents.Count() > 0 Тогда
//					vFixedDiscountPercentsRows = vFixedDiscountPercents.FindRows(New Structure("Услуга, УчетнаяДата", vCurService, vCurAccountingDate));
//					If vFixedDiscountPercentsRows.Count() > 0 Тогда
//						vFixedDiscountPercentsRow = vFixedDiscountPercentsRows.Get(0);
//						vFixedServiceDiscount = vFixedDiscountPercentsRow.Скидка;
//					EndIf;
//				ElsIf vDiscountPercents.Count() > 0 Тогда
//					vDiscountPercentsRows = vDiscountPercents.FindRows(New Structure("УчетнаяДата", vCurAccountingDate));
//					If vDiscountPercentsRows.Count() > 0 Тогда
//						vDiscountPercentsRow = vDiscountPercentsRows.Get(0);
//						vFixedDiscount = vDiscountPercentsRow.Скидка;
//					Else
//						vFixedDiscount = 0;
//					EndIf;
//				EndIf;
//			EndIf;
//			// Check if we should do fee charge only
//			If ЗначениеЗаполнено(vCurFeeTerms) And (vDoNoShowCharging Or vDoLateAnnulationCharging) Тогда
//				If vDoNoShowCharging Тогда
//					If vCurFeeTerms.NoShowChargeInPrice And НЕ vCurIsInPrice Тогда
//						Continue;
//					ElsIf НЕ vCurFeeTerms.NoShowChargeInPrice And НЕ vCurIsRoomRevenue Тогда
//						Continue;
//					EndIf;
//					If НЕ vCurFeeTerms.NoShowChargeWholePeriod And (vFirstPeriod <> vCurAccountingDate) Тогда
//						Continue;
//					EndIf;
//					If ЗначениеЗаполнено(vCurFeeTerms.NoShowService) Тогда
//						vCurService = vCurFeeTerms.NoShowService;
//						vCurIsRoomRevenue = vCurService.IsRoomRevenue;
//						vCurRoomRevenueAmountsOnly = ?(vDoesNotAffectRoomRevenueStatistics, vDoesNotAffectRoomRevenueStatistics, vCurService.RoomRevenueAmountsOnly);
//						vCurIsInPrice = vCurService.IsInPrice;
//					EndIf;
//				ElsIf vDoLateAnnulationCharging Тогда
//					If vCurFeeTerms.LateAnnulationChargeInPrice And НЕ vCurIsInPrice Тогда
//						Continue;
//					ElsIf НЕ vCurFeeTerms.LateAnnulationChargeInPrice And НЕ vCurIsRoomRevenue Тогда
//						Continue;
//					EndIf;
//					If НЕ vCurFeeTerms.LateAnnulationChargeWholePeriod And (vFirstPeriod <> vCurAccountingDate) Тогда
//						Continue;
//					EndIf;
//					If ЗначениеЗаполнено(vCurFeeTerms.LateAnnulationService) Тогда
//						vCurService = vCurFeeTerms.LateAnnulationService;
//						vCurIsRoomRevenue = vCurService.IsRoomRevenue;
//						vCurRoomRevenueAmountsOnly = ?(vDoesNotAffectRoomRevenueStatistics, vDoesNotAffectRoomRevenueStatistics, vCurService.RoomRevenueAmountsOnly);
//						vCurIsInPrice = vCurService.IsInPrice;
//					EndIf;
//				EndIf;
//			Else
//				If ЗначениеЗаполнено(ReservationStatus) And НЕ ReservationStatus.IsActive And 
//				  (ReservationStatus.DoNoShowCharging Or ReservationStatus.DoLateAnnulationCharging) Тогда
//					Break;
//				EndIf;
//			EndIf;
//			// Check that service fit to the ГруппаНомеров rate service group
//			If cmIsServiceInServiceGroup(vCurService, RoomRateServiceGroup) Тогда
//				If (vCurCalendarDayType = vPricesRow.ТипДняКалендаря) Or 
//				   (vPricesRow.ТипДняКалендаря = Справочники.CalendarDayTypes.EmptyRef() And 
//				    (ЗначениеЗаполнено(vPricesRow.QuantityCalculationRule) Or 
//				     vPricesRow.AccountingDayNumber = 0 And vCurAccountingDate = vPricesRow.УчетнаяДата Or 
//				     vPricesRow.AccountingDayNumber = 9999 And vCurAccountingDate = vBegOfCheckOutDate Or 
//				     vPricesRow.AccountingDayNumber <> 0 And vCurAccountingDate = (vBegOfCheckInDate + (vPricesRow.AccountingDayNumber - 1)*24*3600) Or 
//				     НЕ ЗначениеЗаполнено(vPricesRow.QuantityCalculationRule) And НЕ ЗначениеЗаполнено(vPricesRow.УчетнаяДата) And vPricesRow.AccountingDayNumber = 0)) Тогда
//					// Save current price
//					vCurPrice = vPricesRow.Цена;
//					vCurCurrency = vPricesRow.Валюта;
//					vCurUnit = vPricesRow.ЕдИзмерения;
//					vRestOfCurPrice = 0;
//					vCurRatePrice = vPricesRow.Цена;
//					// Check manual prices. Use it if one will be found.
//					cmGetManualPrice(vMPTab, vPricesRow.Услуга, vCurPrice, vCurCurrency, vCurUnit, vCurCalendarDayType);
//					// Check charging rules
//					vRoomRevenuePriceByRoomType = False;
//					For Each vCRRow In vCRTab Do
//						vCurIsSplit = False;
//						vNoDiscounts = False;
//						// Check if current service fit to the current charging rule
//						If cmIsServiceFitToTheChargingRule(vCRRow, vCurService, vCurAccountingDate, True, vCurIsRoomRevenue) Тогда
//							// Check charging rule and do price correction if necessary
//							If vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.RoomRevenuePrice Тогда
//								If TypeOf(vCRRow.ChargingRuleValue) = Type("Number") Тогда
//									If vCRRow.ChargingRuleValue <> 0 Тогда
//										If vCRRow.ChargingRuleValue < vPricesRow.Цена Тогда
//											vRestOfCurPrice = vCurPrice - vCRRow.ChargingRuleValue;
//											vCurPrice = vCRRow.ChargingRuleValue;
//										EndIf;
//									Else
//										Continue;
//									EndIf;
//								Else
//									Continue;
//								EndIf;
//							ElsIf vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.RoomRevenuePricePercent Тогда
//								If TypeOf(vCRRow.ChargingRuleValue) = Type("Number") Тогда
//									If vCRRow.ChargingRuleValue > 0 And vCRRow.ChargingRuleValue < 100 Тогда
//										vSavCurPrice = vCurPrice;	
//										vCurPrice = Round(vCurPrice * vCRRow.ChargingRuleValue / 100, 2);
//										vRestOfCurPrice = vSavCurPrice - vCurPrice;
//									Else
//										Continue;
//									EndIf;
//								Else
//									Continue;
//								EndIf;
//							ElsIf vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.RoomRevenueAmount Тогда
//								If TypeOf(vCRRow.ChargingRuleValue) = Type("Number") Тогда
//									If vCRRow.ChargingRuleValue > 0 Тогда
//										If НЕ vChargingRuleAmountIsSet Тогда
//											vChargingRuleAmountIsSet = True;
//											vRestOfCurAmount = vCRRow.ChargingRuleValue;
//										EndIf;
//										If vRestOfCurAmount <= 0 Тогда
//											Continue;
//										EndIf;
//									Else
//										Continue;
//									EndIf;
//								Else
//									Continue;
//								EndIf;
//							ElsIf vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.RoomRevenuePriceByRoomType Тогда
//								If TypeOf(vCRRow.ChargingRuleValue) = Type("CatalogRef.ТипыНомеров") Тогда
//									vCRRoomTypePricesRow = vCRRoomTypePrices.Find(vCRRow.ChargingRuleValue, "ТипНомера");
//									If vCRRoomTypePricesRow <> Неопределено Тогда
//										vCRPrices = vCRRoomTypePricesRow.Prices;
//										// Process each row in new prices
//										vCurCRPrice = 0;
//										vCurCRPriceIsFound = False;
//										For Each vCRPricesRow In vCRPrices Do
//											vCurCRService = vCRPricesRow.Услуга;
//											vCurCRIsRoomRevenue = vCRPricesRow.IsRoomRevenue;
//											vCurCRRoomRevenueAmountsOnly = vCRPricesRow.RoomRevenueAmountsOnly;
//											vCurCRIsInPrice = vCRPricesRow.IsInPrice;
//											// Check service package period
//											If ЗначениеЗаполнено(vCRPricesRow.ServicePackage) And 
//											  (vCurAccountingDate < vCRPricesRow.ServicePackageDateValidFrom Or vCurAccountingDate > vCRPricesRow.ServicePackageDateValidTo And ЗначениеЗаполнено(vCRPricesRow.ServicePackageDateValidTo)) Тогда
//												Continue;
//											EndIf;
//											// Check that service fit to the ГруппаНомеров rate service group
//											If cmIsServiceInServiceGroup(vCurCRService, RoomRateServiceGroup) Тогда
//												If (vCurCalendarDayType = vCRPricesRow.ТипДняКалендаря) Or 
//												   (vCRPricesRow.ТипДняКалендаря = Справочники.CalendarDayTypes.EmptyRef() And 
//												    (ЗначениеЗаполнено(vCRPricesRow.QuantityCalculationRule) Or 
//												     vCRPricesRow.AccountingDayNumber = 0 And vCurAccountingDate = vCRPricesRow.УчетнаяДата Or 
//												     vCRPricesRow.AccountingDayNumber = 9999 And vCurAccountingDate = vBegOfCheckOutDate Or 
//												     vCRPricesRow.AccountingDayNumber <> 0 And vCurAccountingDate = (vBegOfCheckInDate + (vCRPricesRow.AccountingDayNumber - 1)*24*3600) Or 
//												     НЕ ЗначениеЗаполнено(vCRPricesRow.QuantityCalculationRule) And НЕ ЗначениеЗаполнено(vCRPricesRow.УчетнаяДата) And vCRPricesRow.AccountingDayNumber = 0)) Тогда
//													// Save current price
//													vCurCRPrice = vCRPricesRow.Цена;
//													vCurCRPriceIsFound = True;
//													Break;
//												EndIf;
//											EndIf;
//										EndDo;
//										If vCurCRPriceIsFound Тогда
//											If vCurCRPrice < vPricesRow.Цена Тогда
//												vRestOfCurPrice = vCurPrice - vCurCRPrice;
//												vCurPrice = vCurCRPrice;
//												vRoomRevenuePriceByRoomType = True;
//											EndIf;
//										EndIf;
//									EndIf;
//								Else
//									Continue;
//								EndIf;
//							ElsIf vCRRow.ChargingRule = Перечисления.ChargingRuleTypes.RestOfRoomRevenuePrice Тогда
//								If vChargingRuleAmountIsSet Тогда
//									If vRestOfServiceSum > 0 Тогда
//										Continue;
//									EndIf;
//								Else
//									If vRestOfCurPrice <> 0 Тогда
//										vCurPrice = vRestOfCurPrice;
//										vRestOfCurPrice = 0;
//										vCurIsSplit = True;
//										If vRoomRevenuePriceByRoomType Тогда
//											vNoDiscounts = True;
//										EndIf;
//									Else
//										Continue;
//									EndIf;
//								EndIf;
//							EndIf;
//							// Check folio
//							vCurFolio = vCRRow.ChargingFolio;
//							If НЕ ЗначениеЗаполнено(vCurFolio) Тогда
//								Continue;
//							EndIf;
//							vCurFolioCurrency = vCurFolio.ВалютаЛицСчета;
//							vCurFolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, vCurFolioCurrency, ?(ЗначениеЗаполнено(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate));
//							vCurVATRate = vPricesRow.СтавкаНДС;
//							vCurQuantityCalculationRule = vPricesRow.QuantityCalculationRule;
//							vCurMinQuantity = vPricesRow.MinimumQuantity;
//							vCurRemarks = "";
//							// Calculate quantity
//							vCurQuantity = cmCalculateServiceQuantity(vPricesRow.Услуга, vCurQuantityCalculationRule, 
//							                                          vCurAccountingDate, vCheckInDate, vCheckOutDate, 
//							                                          ThisObject, ThisObject, True, True, False, False, True, True, 
//							                                          vCurPrice, vCurCurrency, vCurRemarks, , vCurMinQuantity, vAccommodationPeriods);
//							If vCurCurrency <> vCurFolioCurrency Тогда
//								vCurPriceInFolioCurrency = Round(cmConvertCurrencies(vCurPrice, vCurCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ЗначениеЗаполнено(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Гостиница), 2);
//								vCurRatePriceInFolioCurrency = Round(cmConvertCurrencies(vCurRatePrice, vCurCurrency, , vCurFolioCurrency, vCurFolioCurrencyExchangeRate, ?(ЗначениеЗаполнено(vCurAccountingDate), vCurAccountingDate, ExchangeRateDate), Гостиница), 2);
//							Else
//								vCurPriceInFolioCurrency = vCurPrice;
//								vCurRatePriceInFolioCurrency = vCurRatePrice;
//							EndIf;
//							vCurQuantity = vCurQuantity * vPricesRow.Количество;
//							// Take number of persons and ГруппаНомеров quantity into account
//							vCurSrvQuantity = vCurQuantity;
//							If vPricesRow.IsPricePerPerson Тогда
//								vCurQuantity = vCurQuantity * NumberOfPersons;
//							Else
//								vCurQuantity = vCurQuantity * RoomQuantity;
//							EndIf;
//							// Fill remarks
//							If НЕ IsBlankString(vPricesRow.Примечания) Тогда
//								vCurRemarks = vPricesRow.Примечания;
//							EndIf;
//							// Check service package period
//							If ЗначениеЗаполнено(vPricesRow.ServicePackage) And 
//							  (vCurAccountingDate < vPricesRow.ServicePackageDateValidFrom Or vCurAccountingDate > vPricesRow.ServicePackageDateValidTo And ЗначениеЗаполнено(vPricesRow.ServicePackageDateValidTo)) Тогда
//								Continue;
//							EndIf;
//							// Check if we should do no show or late annulation charge only
//							If ЗначениеЗаполнено(vCurFeeTerms) And (vDoNoShowCharging Or vDoLateAnnulationCharging) Тогда
//								If vDoNoShowCharging And ЗначениеЗаполнено(vCurFeeTerms.NoShowService) Or 
//								   vDoLateAnnulationCharging And ЗначениеЗаполнено(vCurFeeTerms.LateAnnulationService) Тогда
//									vCurSrvAttrs = vCurService.GetObject().pmGetServicePrices(Гостиница, vCurAccountingDate, ClientType);
//									If vCurSrvAttrs.Count() > 0 Тогда
//										vCurSrvAttrsRow = vCurSrvAttrs.Get(0);
//										vCurVATRate = vCurSrvAttrsRow.СтавкаНДС;
//									EndIf;
//								EndIf;
//								If vDoNoShowCharging Тогда
//									vCurPriceInFolioCurrency = Round(vCurPriceInFolioCurrency*vCurFeeTerms.NoShowFeePercent/100 + vCurFeeTerms.NoShowFeeSum, 2);
//								ElsIf vDoLateAnnulationCharging Тогда
//									vCurPriceInFolioCurrency = Round(vCurPriceInFolioCurrency*vCurFeeTerms.LateAnnulationFeePercent/100 + vCurFeeTerms.LateAnnulationFeeSum, 2);
//								EndIf;
//								// Try to find number of rooms left for fee
//								vWriteOffs = cmGetWriteOffsForReservation(Ref);
//								For Each vWriteOffRow In vWriteOffs Do
//									If NumberOfBedsPerRoom > 0 And 
//									   ЗначениеЗаполнено(vCurFeeTerms) And 
//									  (vCurService = vCurFeeTerms.NoShowService Or vCurService = vCurFeeTerms.LateAnnulationService) Тогда
//										vNumberOfRooms = NumberOfBeds/NumberOfBedsPerRoom;
//										If Int(vNumberOfRooms) <> vNumberOfRooms Тогда
//											vNumberOfRooms = Int(vNumberOfRooms) + 1;
//										EndIf;
//										vRoomsCheckedIn = vWriteOffRow.ЗаездМест/NumberOfBedsPerRoom;
//										If Int(vRoomsCheckedIn) <> vRoomsCheckedIn Тогда
//											vRoomsCheckedIn = Int(vRoomsCheckedIn) + 1;
//										EndIf;
//										vCoeff = vNumberOfRooms - vRoomsCheckedIn;
//									Else
//										vCoeff = NumberOfPersons - vWriteOffRow.ЗаездГостей;
//									EndIf;
//									If vCoeff > 0 Тогда 
//										vCurQuantity = vCurSrvQuantity * vCoeff;
//									Else
//										vCurQuantity = 0;
//									EndIf;
//									Break;
//								EndDo;
//							Else
//								If ЗначениеЗаполнено(ReservationStatus) Тогда
//									If vDoNoShowCharging Or vDoLateAnnulationCharging Тогда
//										Break;
//									EndIf;
//								EndIf;
//							EndIf;
//							// Process quantity calculation rule parameters
//							If ЗначениеЗаполнено(vCurQuantityCalculationRule) Тогда
//								// Skip if "Do not charge in reservations" flag is set
//								If vCurQuantityCalculationRule.DoNotChargeInReservations Тогда
//									Break;
//								EndIf;
//								// Skip service based on "foreigners only" or "citizens only" parameters
//							EndIf;
//							// Add service to the services tabular part if quantity is not zero
//							If vCurQuantity <> 0 Тогда
//								vSrv = Services.Вставить(i);
//								i = i + 1;
//								vSrv.СчетПроживания = vCurFolio;
//								vSrv.ВалютаЛицСчета = vCurFolioCurrency;
//								vSrv.FolioCurrencyExchangeRate = vCurFolioCurrencyExchangeRate;
//								vSrv.УчетнаяДата = vCurAccountingDate;
//								If ЗначениеЗаполнено(vCurFeeTerms) And (vCurService = vCurFeeTerms.LateAnnulationService Or vCurService = vCurFeeTerms.NoShowService) Тогда
//									If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditClosedDateDocs And ЗначениеЗаполнено(Гостиница.AccountingDate) And vSrv.УчетнаяДата < Гостиница.AccountingDate Тогда
//										vSrv.УчетнаяДата = vSrv.УчетнаяДата + 24*3600;
//									EndIf;
//								EndIf;
//								vSrv.Услуга = vCurService;
//								vSrv.Цена = vCurPriceInFolioCurrency;
//								// Check if this is free of charge day
//								If ЗначениеЗаполнено(DiscountType) And DiscountType.EachNDayIsFreeOfCharge > 0 And
//								   cmIsServiceInServiceGroup(vSrv.Услуга, DiscountServiceGroup) Тогда
//									vDayDiff = Round((BegOfDay(vSrv.УчетнаяДата) - BegOfDay(CheckInDate))/(24*3600), 0) + 1;
//									If vDayDiff <> 0 And Int(vDayDiff/DiscountType.EachNDayIsFreeOfCharge) = vDayDiff/DiscountType.EachNDayIsFreeOfCharge Тогда
//										vSrv.Цена = 0;
//										vCurPriceInFolioCurrency = 0;
//									EndIf;
//								EndIf;
//								vSrv.ЕдИзмерения = vCurUnit;
//								vSrv.Количество = vCurQuantity;
//								vSrv.Сумма = Round(vCurPriceInFolioCurrency * vCurQuantity, 2);
//								If vRoomRate.RoundPrice Тогда
//									vSrv.Сумма = Round(vSrv.Сумма, vRoomRate.RoundPriceDigits);
//								EndIf;
//								vSrv.СтавкаНДС = vCurVATRate;
//								vSrv.СуммаНДС = cmCalculateVATSum(vCurVATRate, vSrv.Сумма);
//								vSrv.Примечания = vCurRemarks;
//								If ЗначениеЗаполнено(vSrv.Услуга) Тогда
//									vSrv.IsResourceRevenue = vSrv.Услуга.IsResourceRevenue;
//									// Fill service composition
//									If НЕ IsBlankString(vSrv.Услуга.Composition) Тогда
//										vSrv.Примечания = TrimAll(vSrv.Услуга.Composition);
//									EndIf;
//									// Fill resource and service times
//									If ЗначениеЗаполнено(vSrv.Услуга.Ресурс) And ЗначениеЗаполнено(vSrv.УчетнаяДата) Тогда
//										vSrv.ServiceResource = vSrv.Услуга.Ресурс;
//										vResourceObj = vSrv.ServiceResource.GetObject();
//										vDefaultTimes = vResourceObj.pmGetResourceDefaultChargingTimes(vSrv.УчетнаяДата);
//										vSrv.ВремяС = vDefaultTimes.ВремяС;
//										vSrv.ВремяПо = vDefaultTimes.ВремяПо;
//										vSrv.DoResourceReservation = True;
//									EndIf;
//								EndIf;
//								vSrv.Фирма = Фирма;
//								vSrv.IsRoomRevenue = vCurIsRoomRevenue;
//								vSrv.IsInPrice = vCurIsInPrice;
//								vSrv.ЭтоРазделение = vCurIsSplit;
//								vSrv.RoomRevenueAmountsOnly = vCurRoomRevenueAmountsOnly;
//								vSrv.ТипДняКалендаря = vCurCalendarDayType;
//								If НЕ ЗначениеЗаполнено(vCurCalendarDayType) And ЗначениеЗаполнено(vCurAccountingDate) And ЗначениеЗаполнено(vRoomRate) Тогда
//									vSrv.ТипДняКалендаря = cmGetCalendarDayType(vRoomRate, vCurAccountingDate, vCheckInDate, vCheckOutDate);
//								EndIf;
//								vSrv.ПризнакЦены = vCurPriceTag;
//								vSrv.Тариф = vRoomRate;
//								vSrv.ВидРазмещения = vAccommodationType;
//								vSrv.НомерРазмещения = vRoom;
//								vSrv.ТипНомера = vRoomRoomType;
//								vSrv.Timetable = vCurTimetable;
//								vSrv.IsManual = False;
//								vSrv.СуммаТарифаПрож = Round(vCurRatePriceInFolioCurrency * vCurQuantity, 2);
//								If vRoomRate.RoundPrice Тогда
//									vSrv.СуммаТарифаПрож = Round(vSrv.СуммаТарифаПрож, vRoomRate.RoundPriceDigits);
//								EndIf;
//								// Calculate ГруппаНомеров sales parameters
//								If vSrv.IsRoomRevenue Тогда
//									vNoAccommodationService = False;
//								EndIf;
//								If vSrv.IsRoomRevenue And НЕ vSrv.ЭтоРазделение And НЕ vSrv.RoomRevenueAmountsOnly Тогда
//									vCurPeriodInHours = vCurQuantityCalculationRule.PeriodInHours;
//									vNumberOfPersonsPerRoom = NumberOfPersonsPerRoom;
//									vNumberOfBedsPerRoom = NumberOfBedsPerRoom;
//									vNumberOfPersons = NumberOfPersons;
//									vNumberOfRooms = NumberOfRooms;
//									vNumberOfBeds = NumberOfBeds;
//									vNumberOfAdditionalBeds = NumberOfAdditionalBeds;
//									vIsVirtual = False;
//									If ЗначениеЗаполнено(vRoom) Тогда
//										vIsVirtual = vRoom.ВиртуальныйНомер;
//									ElsIf ЗначениеЗаполнено(vRoomRoomType) Тогда
//										vIsVirtual = vRoomRoomType.ВиртуальныйНомер;
//									EndIf;
//									If vRoomRoomType <> RoomType Тогда
//										If ЗначениеЗаполнено(vRoom) Тогда
//											vRoomAttrs = vRoom.GetObject().pmGetRoomAttributes(cm1SecondShift(vCurAccountingDate));
//											For Each vRoomAttrsRow In vRoomAttrs Do
//												vNumberOfBedsPerRoom = vRoomAttrsRow.КоличествоМестНомер;
//												vNumberOfPersonsPerRoom = vRoomAttrsRow.КоличествоГостейНомер;
//												vIsVirtual = vRoomAttrsRow.ВиртуальныйНомер;
//												Break;
//											EndDo;
//										ElsIf ЗначениеЗаполнено(vRoomRoomType) Тогда
//											vNumberOfBedsPerRoom = vRoomRoomType.КоличествоМестНомер;
//											vNumberOfPersonsPerRoom = vRoomRoomType.КоличествоГостейНомер;
//											vIsVirtual = vRoomRoomType.ВиртуальныйНомер;
//										EndIf;
//									EndIf;
//									If vAccommodationType <> AccommodationType Тогда
//										// Fill accommodation type resources
//										If ЗначениеЗаполнено(vAccommodationType) And НЕ vIsVirtual Тогда
//											If vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения Тогда
//												vNumberOfRooms = vAccommodationType.КоличествоНомеров * RoomQuantity;
//												vNumberOfBeds = ?(vAccommodationType.КоличествоНомеров = 0, 0, vNumberOfBedsPerRoom * RoomQuantity);
//												vNumberOfAdditionalBeds = vAccommodationType.КолДопМест * RoomQuantity;
//											ElsIf vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.Beds Тогда
//												vNumberOfRooms = 0;
//												vNumberOfBeds = vAccommodationType.КоличествоМест * RoomQuantity;
//												vNumberOfAdditionalBeds = vAccommodationType.КолДопМест * RoomQuantity;
//											ElsIf vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.AdditionalBed Тогда
//												vNumberOfRooms = 0;
//												vNumberOfBeds = 0;
//												vNumberOfAdditionalBeds = vAccommodationType.КолДопМест * RoomQuantity;
//											ElsIf vAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.Together Тогда
//												vNumberOfRooms = 0;
//												vNumberOfBeds = 0;
//												vNumberOfAdditionalBeds = vAccommodationType.КолДопМест * RoomQuantity;
//											EndIf;
//										Else
//											vNumberOfRooms = 0;
//											vNumberOfBeds = 0;
//											vNumberOfAdditionalBeds = 0;
//										EndIf;
//									EndIf;
//									vSrv.ПроданоНомеров = ?(vNumberOfBedsPerRoom=0, 0, Round(vNumberOfBeds/vNumberOfBedsPerRoom*vCurSrvQuantity*vCurPeriodInHours/24, 7));
//									vSrv.ПроданоМест = Round(vNumberOfBeds*vCurSrvQuantity*vCurPeriodInHours/24, 7);
//									vSrv.ПроданоДопМест = Round(vNumberOfAdditionalBeds*vCurSrvQuantity*vCurPeriodInHours/24, 7);
//									vSrv.ЧеловекаДни = Round(vNumberOfPersons*vCurSrvQuantity*vCurPeriodInHours/24, 7);
//									If vFirstDayWithAccommodationService Тогда
//										vFirstDayWithAccommodationService = False;
//										vSrv.ЗаездГостей = vNumberOfPersons;
//									EndIf;
//								EndIf;
//								// Discounts
//								If НЕ vRoomRate.NoDiscounts And НЕ vNoDiscounts And (НЕ ЗначениеЗаполнено(Contract) Or ЗначениеЗаполнено(Contract) And НЕ Contract.NoDiscounts) Тогда
//									// Calculate discount for this service if applicable
//									vCurDiscount = 0;
//									vCurDiscountType = Неопределено;
//									vCurDiscountServiceGroup = Неопределено;
//									vCurDiscountConfirmationText = "";
//									// Check manual discount set in the document
//									If cmIsServiceInServiceGroup(vSrv.Услуга, DiscountServiceGroup) Тогда
//										vRRRow = vRoomRates.Find(vCurAccountingDate, "УчетнаяДата");
//										If vRRRow <> Неопределено And НЕ IsBlankString(vRRRow.Скидка) And 
//										   vSrv.IsRoomRevenue And НЕ vSrv.RoomRevenueAmountsOnly And НЕ vSrv.ЭтоРазделение Тогда
//											vCurDiscount = Number(vRRRow.Скидка);
//										ElsIf vFixedServiceDiscount <> 0 Тогда
//											vCurDiscount = vFixedServiceDiscount;
//										ElsIf vFixedDiscount <> 0 Тогда
//											vCurDiscount = vFixedDiscount;
//										EndIf;
//										If vCurDiscount <> 0 Тогда
//											vCurDiscountType = DiscountType;
//											vCurDiscountServiceGroup = DiscountServiceGroup;
//											vCurDiscountConfirmationText = DiscountConfirmationText;
//										EndIf;
//									EndIf;
//									// Check accumulating discounts
//									If НЕ TurnOffAutomaticDiscounts Тогда
//										// Check period discount
//										If vPeriodDiscount <> 0 Тогда
//											If cmFirstDiscountIsGreater(vPeriodDiscount, vCurDiscount) Тогда
//												vCurDiscount = vPeriodDiscount;
//												vCurDiscountType = vPeriodDiscountType;
//												vCurDiscountServiceGroup = vPeriodDiscountServiceGroup;
//												vCurDiscountConfirmationText = vPeriodDiscountConfirmationText;
//											EndIf;
//										EndIf;
//										// Retrieve accumulation discounts
//										For Each vAccDiscount In vAccDiscounts Do
//											vDiscountType = vAccDiscount.ТипСкидки;
//											If ЗначениеЗаполнено(vDiscountType) Тогда
//												If vCurAccountingDate < vDiscountType.DateValidFrom Or
//												   (vCurAccountingDate > vDiscountType.DateValidTo And ЗначениеЗаполнено(vDiscountType.DateValidTo)) Тогда
//													Continue;
//												EndIf;
//											EndIf;
//											vDiscountDimension = vAccDiscount.ИзмерениеСкидки;
//											vDiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//											If cmIsServiceInServiceGroup(vSrv.Услуга, vDiscountServiceGroup) And 
//											   (НЕ vDiscountType.IsForRackRatesOnly Or vDiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(vSrv.Тариф) And vSrv.Тариф.IsRackRate) Тогда
//												vDiscountTypeObj = vDiscountType.GetObject();
//												
//												// Check that this discount type fits to the service folio
//												vSrvDiscountDimension = Неопределено;
//												vSrvResource = vDiscountTypeObj.pmCalculateResource(vSrv, NumberOfPersons, vSrv.СчетПроживания, DiscountCard, vSrvDiscountDimension);
//												If TypeOf(vSrvDiscountDimension) = TypeOf(vDiscountDimension) Тогда
//													// Add resource calculated for this service to the current discount resource
//													If vSrvResource <> 0 Тогда
//														vAccDiscount.Ресурс = vAccDiscount.Ресурс + vSrvResource;
//													EndIf;
//												   
//													// Retrieve discount percent valid for current discount resource										
//													vResource = vAccDiscount.Ресурс;
//													vDiscountConfirmationText = "";
//													vDiscount = vDiscountTypeObj.pmGetAccumulatingDiscount(vSrv.Услуга, vSrv.УчетнаяДата, 
//													                                                       vResource, 
//													                                                       vDiscountConfirmationText);
//													If vDiscount <> 0 Тогда
//														If cmFirstDiscountIsGreater(vDiscount, vCurDiscount) Тогда
//															vCurDiscount = vDiscount;
//															vCurDiscountType = vDiscountType;
//															vCurDiscountServiceGroup = vDiscountServiceGroup;
//															vCurDiscountConfirmationText = vDiscountConfirmationText;
//														EndIf;
//													EndIf;
//												EndIf;
//											EndIf;
//										EndDo;
//									EndIf;
//									// Calculate discount sum
//									If vCurDiscount <> 0 Тогда
//										If cmIsServiceInServiceGroup(vSrv.Услуга, vCurDiscountServiceGroup) Тогда
//											If НЕ ЗначениеЗаполнено(vCurDiscountType) Or ЗначениеЗаполнено(vCurDiscountType) And (НЕ vCurDiscountType.IsForRackRatesOnly Or vCurDiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(vSrv.Тариф) And vSrv.Тариф.IsRackRate) Тогда
//												vSrv.Скидка = vCurDiscount;
//												vSrv.ТипСкидки = vCurDiscountType;
//												vSrv.DiscountServiceGroup = vCurDiscountServiceGroup;
//												vSrv.ОснованиеСкидки = vCurDiscountConfirmationText;
//											EndIf;
//											// Check should we set value for the period discount
//											If ЗначениеЗаполнено(vCurDiscountType) Тогда
//												If vCurDiscountType.IsPerPeriod Тогда
//													If vCurDiscount > vPeriodDiscount And vCurDiscount > 0 Or 
//													   vCurDiscount < vPeriodDiscount And vCurDiscount < 0 Тогда
//														vPeriodDiscount = vCurDiscount;
//														vPeriodDiscountType = vCurDiscountType;
//														vPeriodDiscountServiceGroup = vCurDiscountServiceGroup;
//														vPeriodDiscountConfirmationText = vCurDiscountConfirmationText;
//													EndIf;
//												EndIf;
//											EndIf;
//										EndIf;
//									Else
//										If ЗначениеЗаполнено(DiscountType) And 
//										   DiscountType.IsAccumulatingDiscount And DiscountType.HasToBeDirectlyAssigned Тогда 
//											If cmIsServiceInServiceGroup(vSrv.Услуга, DiscountServiceGroup) Тогда
//												If НЕ DiscountType.IsForRackRatesOnly Or DiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(vSrv.Тариф) And vSrv.Тариф.IsRackRate Тогда
//													vSrv.Скидка = 0; // This is not mistake
//													vSrv.ТипСкидки = DiscountType;
//													vSrv.DiscountServiceGroup = DiscountServiceGroup;
//													vSrv.ОснованиеСкидки = DiscountConfirmationText;
//												EndIf;
//											EndIf;
//										EndIf;
//									EndIf;
//									pmCalculateServiceDiscounts(vSrv);
//									If vRoomRevenuePriceByRoomType And vSrv.СуммаСкидки <> 0 And vSrv.Количество <> 0 Тогда
//										vRestOfCurPrice = vRestOfCurPrice + Round(vSrv.СуммаСкидки/vSrv.Количество, 2);
//									EndIf;
//								EndIf;
//								// Check if charging rule amount is set
//								If vChargingRuleAmountIsSet Тогда 
//									If vRestOfCurAmount > 0 Тогда
//										If (vSrv.Сумма - vSrv.СуммаСкидки) > vRestOfCurAmount Тогда
//											vRestOfServiceSum = (vSrv.Сумма - vSrv.СуммаСкидки) - vRestOfCurAmount;
//											vSrv.Сумма = vRestOfCurAmount;
//											vSrv.Скидка = 0;
//											vSrv.СуммаСкидки = 0;
//											vRestOfCurAmount = 0;
//											// Recalculate price and VAT sum
//											cmSumOnChange(vSrv.Услуга, vSrv.Цена, vSrv.Количество, vSrv.Сумма, vSrv.СтавкаНДС, vSrv.СуммаНДС, True);
//											// Recalculate commission for this service if applicable
//											pmCalculateServiceCommissions(vSrv);
//										Else
//											vRestOfCurAmount = vRestOfCurAmount - (vSrv.Сумма - vSrv.СуммаСкидки);
//											vRestOfServiceSum = 0;
//										EndIf;
//									ElsIf vRestOfServiceSum > 0 Тогда
//										vSrv.Сумма = vRestOfServiceSum;
//										vSrv.Цена = vRestOfServiceSum;
//										vSrv.Количество = 0;
//										vSrv.Скидка = 0;
//										vSrv.СуммаСкидки = 0;
//										vRestOfCurAmount = 0;
//										vRestOfServiceSum = 0;
//										// Recalculate VAT sum
//										vSrv.СуммаНДС = cmCalculateVATSum(vSrv.СтавкаНДС, vSrv.Сумма);
//										// Recalculate service ГруппаНомеров sales parameters
//										cmRecalculateServiceRoomSalesParameters(vSrv, ThisObject);
//									EndIf;
//								EndIf;
//								// Calculate commission for this service if applicable
//								pmSetServiceCommissions(vSrv, vRoomRates, vComplexCommission);
//								// Try to find current service in the table of services changed manually
//								If vMCServices.Count() > 0 Тогда
//									vMCSrvRows = vMCServices.FindRows(New Structure("УчетнаяДата, Услуга, ЭтоРазделение", vSrv.УчетнаяДата, vSrv.Услуга, vSrv.ЭтоРазделение));
//									If vMCSrvRows.Count() > 0 Тогда
//										vMCSrv = vMCSrvRows.Get(0);
//										If vMCSrv.QuantityIsChanged Тогда
//											FillPropertyValues(vSrv, vMCSrv, , "LineNumber, СчетПроживания, Фирма, НомерРазмещения, ТипНомера, ВидРазмещения, Тариф, ЗаездГостей, ЧеловекаДни, ПроданоДопМест, ПроданоМест, ПроданоНомеров, Timetable, ТипДеньКалендарь");
//										Else
//											FillPropertyValues(vSrv, vMCSrv, , "LineNumber, Количество, СчетПроживания, Фирма, НомерРазмещения, ТипНомера, ВидРазмещения, Тариф, ЗаездГостей, ЧеловекаДни, ПроданоДопМест, ПроданоМест, ПроданоНомеров, Timetable, ТипДеньКалендарь");
//										EndIf;
//										// Recalculate amount and VAT sum
//										cmPriceOnChange(vSrv.Цена, vSrv.Количество, vSrv.Сумма, vSrv.СтавкаНДС, vSrv.СуммаНДС);
//										// Recalculate discount for this service if applicable
//										pmCalculateServiceDiscounts(vSrv);
//										// Recalculate commission for this service if applicable
//										pmCalculateServiceCommissions(vSrv);
//										// Recalculate service ГруппаНомеров sales parameters
//										cmRecalculateServiceRoomSalesParameters(vSrv, ThisObject);
//									EndIf;
//								EndIf;
//								// We've found suitable charging rule so move to the other service
//								If vChargingRuleAmountIsSet Тогда
//									If vRestOfCurAmount > 0 Тогда
//										Break;
//									ElsIf vRestOfServiceSum <= 0 Тогда
//										Break;
//									EndIf;
//								Else
//									If vRestOfCurPrice = 0 Тогда
//										Break;
//									EndIf;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndDo;
//				EndIf;
//			EndIf;
//		EndDo;
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
//	Else
//		// Process warnings
//		vWarningsEn = "";
//		vWarningsDe = "";
//		vWarningsRu = "";
//		If vNoAccommodationService And NumberOfBeds > 0 Тогда
//			If ЗначениеЗаполнено(Тариф) And 
//			   ЗначениеЗаполнено(vRoomType) And 
//			   ЗначениеЗаполнено(AccommodationType) And 
//			   НЕ ЗначениеЗаполнено(RoomQuota) And 
//			   НЕ vRoomType.ВиртуальныйНомер Тогда
//				vWarnings = True;
//				vWarningsEn = "For Размещение period " + Format(CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + ", НомерРазмещения rate " + Тариф + ", НомерРазмещения type " + vRoomType + " and Размещение type " + AccommodationType + " Размещение Услуги will not be charged!";
//				vWarningsDe = "For Размещение period " + Format(CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + ", НомерРазмещения rate " + Тариф + ", НомерРазмещения type " + vRoomType + " and Размещение type " + AccommodationType + " Размещение Услуги will not be charged!";
//				vWarningsRu = "Для периода проживания " + Format(CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + ", тарифа " + Тариф + ", типа номера " + vRoomType + " и вида размещения " + AccommodationType + " услуги проживания начислены не будут!";
//			EndIf;
//		EndIf;
//		If vWarnings Тогда
//			rWarnings = "ru = '" + vWarningsRu + "'; de = '" + vWarningsDe + "'; en = '" + vWarningsEn + "'";
//			WriteLogEvent(NStr("en='Reservation.CalculateServices';ru='Резервирование.РасчетУслуг';de='Reservation.CalculateServices'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, NStr(rWarnings));
//			If ЗначениеЗаполнено(ReservationStatus) Тогда
//				If НЕ ReservationStatus.IsActive And 
//				   (ReservationStatus.DoNoShowCharging Or ReservationStatus.DoLateAnnulationCharging) Тогда
//					vWarnings = False;
//					rWarnings = "";
//				EndIf;
//			EndIf;
//		EndIf;
//		Return vWarnings;
//	EndIf;
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
//КонецПроцедуры //pmCalculateServiceDiscounts
//
////-----------------------------------------------------------------------------
//Процедура pmSetServiceCommissions(pSrvRow, pRoomRates, pComplexCommission = Неопределено) Экспорт
//	pSrvRow.ВидКомиссииАгента = Неопределено;
//	pSrvRow.КомиссияАгента = 0;
//	pSrvRow.СуммаКомиссии = 0;
//	pSrvRow.СуммаКомиссииНДС = 0;
//	If ЗначениеЗаполнено(Тариф) And НЕ Тариф.NoAgentCommission Тогда
//		vRRRow = pRoomRates.Find(pSrvRow.УчетнаяДата, "УчетнаяДата");
//		If vRRRow <> Неопределено And НЕ IsBlankString(vRRRow.КомиссияАгента) And Number(vRRRow.КомиссияАгента) <> 0 Тогда
//			pSrvRow.ВидКомиссииАгента = AgentCommissionType;
//			pSrvRow.КомиссияАгента = Number(vRRRow.КомиссияАгента);
//			If pSrvRow.КомиссияАгента <> 0 And Тариф.MaxAgentCommission <> 0 Тогда
//				pSrvRow.КомиссияАгента = Min(pSrvRow.КомиссияАгента, Тариф.MaxAgentCommission);
//			EndIf;
//			If pComplexCommission <> Неопределено And pComplexCommission.Count() > 0 Тогда
//				For Each vComplexCommissionRow In pComplexCommission Do
//					If cmIsServiceInServiceGroup(pSrvRow.Услуга, vComplexCommissionRow.ServiceGroup) Тогда
//						pSrvRow.ВидКомиссииАгента = vComplexCommissionRow.CommissionType;
//						pSrvRow.КомиссияАгента = vComplexCommissionRow.Комиссия;
//						If pSrvRow.КомиссияАгента <> 0 And Тариф.MaxAgentCommission <> 0 Тогда
//							pSrvRow.КомиссияАгента = Min(pSrvRow.КомиссияАгента, Тариф.MaxAgentCommission);
//						EndIf;
//						Break;
//					EndIf;
//				EndDo;
//			EndIf;
//		Else
//			pSrvRow.ВидКомиссииАгента = AgentCommissionType;
//			pSrvRow.КомиссияАгента = AgentCommission;
//			If pSrvRow.КомиссияАгента <> 0 And Тариф.MaxAgentCommission <> 0 Тогда
//				pSrvRow.КомиссияАгента = Min(pSrvRow.КомиссияАгента, Тариф.MaxAgentCommission);
//			EndIf;
//			If pComplexCommission <> Неопределено And pComplexCommission.Count() > 0 Тогда
//				For Each vComplexCommissionRow In pComplexCommission Do
//					If cmIsServiceInServiceGroup(pSrvRow.Услуга, vComplexCommissionRow.ServiceGroup) Тогда
//						pSrvRow.ВидКомиссииАгента = vComplexCommissionRow.CommissionType;
//						pSrvRow.КомиссияАгента = vComplexCommissionRow.Комиссия;
//						If pSrvRow.КомиссияАгента <> 0 And Тариф.MaxAgentCommission <> 0 Тогда
//							pSrvRow.КомиссияАгента = Min(pSrvRow.КомиссияАгента, Тариф.MaxAgentCommission);
//						EndIf;
//						Break;
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//		If pSrvRow.КомиссияАгента <> 0 Тогда
//			// Check that current service fit to the commission service group
//			If cmIsServiceInServiceGroup(pSrvRow.Услуга, AgentCommissionServiceGroup) Тогда
//				If pSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//					pSrvRow.СуммаКомиссии = Round((pSrvRow.Сумма - pSrvRow.СуммаСкидки) * pSrvRow.КомиссияАгента/100, 2);
//					pSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаКомиссии);
//				ElsIf pSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//					If BegOfDay(CheckInDate) = BegOfDay(pSrvRow.УчетнаяДата) Тогда
//						pSrvRow.СуммаКомиссии = Round((pSrvRow.Сумма - pSrvRow.СуммаСкидки) * pSrvRow.КомиссияАгента/100, 2);
//						pSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаКомиссии);
//					Else
//						pSrvRow.ВидКомиссииАгента = Неопределено;
//						pSrvRow.КомиссияАгента = 0;
//					EndIf;
//				Else
//					pSrvRow.ВидКомиссииАгента = Неопределено;
//					pSrvRow.КомиссияАгента = 0;
//				EndIf;
//			Else
//				pSrvRow.ВидКомиссииАгента = Неопределено;
//				pSrvRow.КомиссияАгента = 0;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmSetServiceCommissions
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateServiceCommissions(pSrvRow) Экспорт
//	pSrvRow.СуммаКомиссии = 0;
//	pSrvRow.СуммаКомиссииНДС = 0;
//	If ЗначениеЗаполнено(Тариф) And НЕ Тариф.NoAgentCommission Тогда
//		If pSrvRow.КомиссияАгента <> 0 Тогда
//			If Тариф.MaxAgentCommission <> 0 Тогда
//				pSrvRow.КомиссияАгента = Min(pSrvRow.КомиссияАгента, Тариф.MaxAgentCommission);
//			EndIf;
//			// Check that current service fit to the commission service group
//			If cmIsServiceInServiceGroup(pSrvRow.Услуга, AgentCommissionServiceGroup) Тогда
//				If AgentCommissionType = Перечисления.AgentCommissionTypes.Percent Тогда
//					pSrvRow.СуммаКомиссии = Round((pSrvRow.Сумма - pSrvRow.СуммаСкидки) * pSrvRow.КомиссияАгента/100, 2);
//					pSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаКомиссии);
//				ElsIf AgentCommissionType = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//					If BegOfDay(CheckInDate) = BegOfDay(pSrvRow.УчетнаяДата) Тогда
//						pSrvRow.СуммаКомиссии = Round((pSrvRow.Сумма - pSrvRow.СуммаСкидки) * pSrvRow.КомиссияАгента/100, 2);
//						pSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаКомиссии);
//					Else
//						pSrvRow.ВидКомиссииАгента = Неопределено;
//						pSrvRow.КомиссияАгента = 0;
//					EndIf;
//				Else
//					pSrvRow.ВидКомиссииАгента = Неопределено;
//					pSrvRow.КомиссияАгента = 0;
//				EndIf;
//			Else
//				pSrvRow.ВидКомиссииАгента = Неопределено;
//				pSrvRow.КомиссияАгента = 0;
//			EndIf;
//		EndIf;
//	Else
//		pSrvRow.ВидКомиссииАгента = Неопределено;
//		pSrvRow.КомиссияАгента = 0;
//	EndIf;
//КонецПроцедуры //pmCalculateServiceCommissions
//
////-----------------------------------------------------------------------------
//Процедура pmSetServiceFolioBasedOnChargingRules(pServiceRow, pChargingRules, pAssignNew = False) Экспорт
//	// Try to get current service folio
//	If НЕ pAssignNew Тогда
//		For Each vSrvRow In Services Do
//			If ЗначениеЗаполнено(vSrvRow.ЛицевойСчет) Тогда
//				If vSrvRow.Service = pServiceRow.Услуга And 
//				   vSrvRow.AccountingDate = pServiceRow.УчетнаяДата And 
//				   vSrvRow.Price = pServiceRow.Цена And 
//				   vSrvRow.IsSplit = pServiceRow.ЭтоРазделение And 
//				   TrimR(vSrvRow.Remarks) = TrimR(pServiceRow.Примечания) Тогда
//					pServiceRow.СчетПроживания = vSrvRow.ЛицевойСчет;
//					If ЗначениеЗаполнено(pServiceRow.СчетПроживания) And pServiceRow.ВалютаЛицСчета <> pServiceRow.СчетПроживания.ВалютаЛицСчета Тогда
//						pServiceRow.ВалютаЛицСчета = pServiceRow.СчетПроживания.ВалютаЛицСчета;
//						pServiceRow.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, pServiceRow.ВалютаЛицСчета, ?(ЗначениеЗаполнено(pServiceRow.УчетнаяДата), pServiceRow.УчетнаяДата, ExchangeRateDate));
//					EndIf;
//					Break;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(pServiceRow.СчетПроживания) Or pAssignNew Тогда
//		// Set folio according to the current charging rules
//		For Each vChargingRuleRow in pChargingRules Do
//			// Check if current service fit to the current charging rule
//			If cmIsServiceFitToTheChargingRule(vChargingRuleRow, pServiceRow.Услуга, pServiceRow.УчетнаяДата, НЕ pServiceRow.IsManual, pServiceRow.IsRoomRevenue) Тогда
//				// Check price split charging rules
//				If vChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePrice Тогда
//					If pServiceRow.ЭтоРазделение Тогда
//						Continue;
//					EndIf;
//				ElsIf vChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePricePercent Тогда
//					If pServiceRow.ЭтоРазделение Тогда
//						Continue;
//					EndIf;
//				ElsIf vChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenueAmount Тогда
//					If pServiceRow.ЭтоРазделение Тогда
//						Continue;
//					EndIf;
//				ElsIf vChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePriceByRoomType Тогда
//					If pServiceRow.ЭтоРазделение Тогда
//						Continue;
//					EndIf;
//				ElsIf vChargingRuleRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RestOfRoomRevenuePrice Тогда
//					If НЕ pServiceRow.ЭтоРазделение Тогда
//						Continue;
//					EndIf;
//				EndIf;
//				pServiceRow.СчетПроживания = vChargingRuleRow.ChargingFolio;
//				If ЗначениеЗаполнено(pServiceRow.СчетПроживания) And pServiceRow.ВалютаЛицСчета <> pServiceRow.СчетПроживания.ВалютаЛицСчета Тогда
//					pServiceRow.ВалютаЛицСчета = pServiceRow.СчетПроживания.ВалютаЛицСчета;
//					pServiceRow.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, pServiceRow.ВалютаЛицСчета, ?(ЗначениеЗаполнено(pServiceRow.УчетнаяДата), pServiceRow.УчетнаяДата, ExchangeRateDate));
//				EndIf;
//				Break;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmSetServiceFolioBasedOnChargingRules 
//
////-----------------------------------------------------------------------------
//Процедура pmSetFolioBasedOnChargingRules(pServices, pAssignNew = False, pCharges = Неопределено) Экспорт
//	// Create table of charging rules
//	vChargingRules = ChargingRules.Unload();
//	cmAddGuestGroupChargingRules(vChargingRules, GuestGroup);
//	// Process each service in the services value table
//	For Each vServiceRow In pServices Do
//		pmSetServiceFolioBasedOnChargingRules(vServiceRow, vChargingRules, pAssignNew);
//	EndDo;
//	// Try to set folio for the transfered charges
//	If pCharges <> Неопределено Тогда
//		For Each vServiceRow In pServices Do
//			vChargesRows = pCharges.FindRows(New Structure("УчетнаяДата", vServiceRow.УчетнаяДата));
//			For Each vChargesRow In vChargesRows Do
//				If ЗначениеЗаполнено(vChargesRow.ПеремещениеНачисления) And
//				   vServiceRow.Услуга = vChargesRow.Услуга And
//				   vServiceRow.Цена = vChargesRow.Цена And
//				   vServiceRow.СтавкаНДС = vChargesRow.СтавкаНДС And
//				   vServiceRow.IsManual = vChargesRow.IsManual Тогда
//					vServiceRow.СчетПроживания = vChargesRow.СчетПроживания;
//					If ЗначениеЗаполнено(vServiceRow.СчетПроживания) And vServiceRow.ВалютаЛицСчета = vServiceRow.СчетПроживания.ВалютаЛицСчета Тогда
//						vServiceRow.ВалютаЛицСчета = vServiceRow.СчетПроживания.ВалютаЛицСчета;
//						vServiceRow.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, vServiceRow.ВалютаЛицСчета, ?(ЗначениеЗаполнено(vServiceRow.УчетнаяДата), vServiceRow.УчетнаяДата, ExchangeRateDate));
//					EndIf;
//					Break;
//				EndIf;
//			EndDo;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmSetFolioBasedOnChargingRules 
//
////-----------------------------------------------------------------------------
//// Get reservation attributes valid on specified date
//// - pDate is optional. If is not specified, then function gets attributes on current date
//// Returns ValueTable 
////-----------------------------------------------------------------------------
//Function pmGetReservationAttributes(Val pDate = Неопределено) Экспорт
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
//	|	InformationRegister.ReservationChangeHistory.SliceLast(
//	|	&qDate, 
//	|	Reservation = &qReservation) AS ReservationChangeHistory";
//	qGetLastAttr.SetParameter("qDate", pDate);
//	qGetLastAttr.SetParameter("qReservation", Ref);
//	vAttr = qGetLastAttr.Execute().Unload();
//	
//	Return vAttr;
//EndFunction //pmGetReservationAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmLoadChargingRules(pOwner) Экспорт
//	// Get list of hotel default charging rules owners
//	vHotelCROwners = cmGetHotelDefaultChargingRuleOwners(Гостиница);
//	// Remove charging rules for objects of the same type
//	i = 0;
//	j = 0;
//	vCRTo = ChargingRules.Unload();
//	While i < vCRTo.Count() Do
//		vCRRow = vCRTo.Get(i);
//		If ЗначениеЗаполнено(vCRRow.Owner) Тогда
//			If TypeOf(pOwner) = TypeOf(vCRRow.Owner) Or 
//			   TypeOf(pOwner) = Type("CatalogRef.Договора") And TypeOf(vCRRow.Owner) = Type("CatalogRef.Контрагенты") Or
//			   TypeOf(pOwner) = Type("CatalogRef.Контрагенты") And TypeOf(vCRRow.Owner) = Type("CatalogRef.Договора") Тогда
//				If vHotelCROwners.FindByValue(vCRRow.Owner) = Неопределено Тогда
//					// Try to find hotel template rule of the same type
//					vHotelCRRows = Гостиница.ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vCRRow.СпособРазделенияОплаты, vCRRow.ПравилаНачисления, vCRRow.ValidFromDate, vCRRow.ValidToDate));
//					If vHotelCRRows.Count() <> 1 Тогда
//						// Delete charging rule row
//						vCRTo.Delete(i);
//						// Save Должность of the first deleted charging rule
//						If j = 0 Тогда
//							j = i;
//						EndIf;
//						Continue;
//					Else
//						vHotelCRRow = vHotelCRRows.Get(0);
//						// Update charging folio
//						vFolioObj = vCRRow.ChargingFolio.GetObject();
//						vFolioObj.Read();
//						cmFillFolioFromTemplate(vFolioObj, vHotelCRRow.ChargingFolio, Гостиница, Date);
//						vFolioObj.ДокОснование = pmGetThisDocumentRef();
//						If НЕ vFolioObj.DoNotUpdateCompany Тогда
//							vFolioObj.Фирма = Фирма;
//						EndIf;
//						vFolioObj.Клиент = Гость;
//						vFolioObj.DateTimeFrom = CheckInDate;
//						vFolioObj.DateTimeTo = CheckOutDate;
//						If НЕ vFolioObj.IsMaster Тогда
//							vFolioObj.ГруппаГостей = GuestGroup;
//						EndIf;
//						If TypeOf(pOwner) = Type("CatalogRef.Контрагенты") Тогда
//							vFolioObj.Контрагент = Справочники.Контрагенты.EmptyRef();
//						ElsIf TypeOf(pOwner) = Type("CatalogRef.Договора") Тогда
//							vFolioObj.Контрагент = Справочники.Контрагенты.EmptyRef();
//							vFolioObj.Договор = Справочники.Договора.EmptyRef();
//						ElsIf TypeOf(pOwner) = Type("CatalogRef.Clients") Тогда
//							vFolioObj.Клиент = Справочники.Clients.EmptyRef();
//						ElsIf TypeOf(pOwner) = Type("CatalogRef.НомернойФонд") Тогда
//							vFolioObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//						EndIf;
//						vFolioObj.Write(DocumentWriteMode.Write);
//						// Update owner
//						vCRRow.Owner = Неопределено;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	// Load changed charging rules to the tabular part
//	ChargingRules.Load(vCRTo);
//	// Check owner
//	If НЕ ЗначениеЗаполнено(pOwner) Тогда
//		If ChargingRules.Count() = 0 Тогда
//			pmCreateFolios();
//		EndIf;
//		Return;
//	EndIf;
//	vCRFrom = Неопределено;
//	If TypeOf(pOwner) = Type("CatalogRef.НомернойФонд") Тогда
//		If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//			If ChargingRules.Count() = 0 Тогда
//				pmCreateFolios();
//			EndIf;
//			Return;
//		EndIf;
//		vCRFrom = Гостиница.RoomChargingRules.Unload();
//	Else
//		vCRFrom = pOwner.ChargingRules.Unload();
//	EndIf;
//	If vCRFrom = Неопределено Тогда
//		If ChargingRules.Count() = 0 Тогда
//			pmCreateFolios();
//		EndIf;
//		Return;
//	EndIf;
//	If vCRFrom.Count() = 0 Тогда
//		If ChargingRules.Count() = 0 Тогда
//			pmCreateFolios();
//		EndIf;
//		Return;
//	EndIf;
//	vGuestGroupObj = Неопределено;
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		vGuestGroupObj = GuestGroup.GetObject();
//		vGuestGroupObj.Read();
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.UseGuestGroupFolios And ЗначениеЗаполнено(GuestGroup) Тогда
//		vCRTo = vGuestGroupObj.ChargingRules.Unload();
//		
//		// Вставить owners charging rules before this document charging rules
//		For Each vCRRow In vCRFrom Do
//			// Check if current folio should be used as template
//			vIsTemplate = True;
//			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//				vIsTemplate = НЕ vCRRow.ChargingFolio.IsMaster;
//			EndIf;
//			// Try to find existing charging rule of the same type
//			vReuseFolio = False;
//			vCRToRows = vCRTo.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vCRRow.СпособРазделенияОплаты, vCRRow.ПравилаНачисления, vCRRow.ValidFromDate, vCRRow.ValidToDate));
//			If vCRToRows.Count() = 1 Тогда
//				// Reuse existing one
//				vCRToRow = vCRToRows.Get(0);
//				vReuseFolio = True;
//			Else
//				// New charging rule row
//				vCRToRow = vCRTo.Вставить(j);
//				j = j + 1;
//			EndIf;
//			vCRToRow.СпособРазделенияОплаты = vCRRow.СпособРазделенияОплаты;
//			vCRToRow.ПравилаНачисления = vCRRow.ПравилаНачисления;
//			vCRToRow.ValidFromDate = vCRRow.ValidFromDate;
//			vCRToRow.ValidToDate = vCRRow.ValidToDate;
//			// Get template folio
//			If vIsTemplate Тогда
//				// If owner is ГруппаНомеров then try to find acive ГруппаНомеров folios first
//				If TypeOf(pOwner) = Type("CatalogRef.НомернойФонд") Тогда
//					vHotel = Гостиница;
//					vRoom = pOwner;
//					vFolioCurrency = Гостиница.FolioCurrency;
//					If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//						vFolioCurrency = vCRRow.ChargingFolio.ВалютаЛицСчета;
//					EndIf;
//					vRoomFolios = cmGetActiveRoomFolios(vHotel, vRoom, vFolioCurrency);
//					For Each vRoomFoliosRow in vRoomFolios Do
//						vCRRow.ChargingFolio = vRoomFoliosRow.СчетПроживания;
//						vIsTemplate = False;
//						Break;				
//					EndDo;
//				EndIf;
//			EndIf;
//			// If current charging folio is template then create new based on it
//			If НЕ vReuseFolio Тогда
//				If vIsTemplate Тогда
//					// Create new folio from template
//					vFolioObj = Documents.СчетПроживания.CreateDocument();
//					cmFillFolioFromTemplate(vFolioObj, vCRRow.ChargingFolio, Гостиница, Date);
//					vFolioObj.ДокОснование = Неопределено;
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//					vFolioObj.Клиент = vGuestGroupObj.Клиент;
//					vFolioObj.DateTimeFrom = vGuestGroupObj.CheckInDate;
//					vFolioObj.DateTimeTo = vGuestGroupObj.ДатаВыезда;
//					vFolioObj.ГруппаГостей = GuestGroup;
//				Else
//					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
//					vFolioObj = vCRToRow.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					vFolioObj.ДокОснование = Неопределено;
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//				EndIf;
//			Else
//				// Update folio from template
//				If vIsTemplate Тогда
//					vFolioObj = vCRToRow.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					cmFillFolioFromTemplate(vFolioObj, vCRRow.ChargingFolio, Гостиница, Date);
//					vFolioObj.ДокОснование = Неопределено;
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//					vFolioObj.Клиент = vGuestGroupObj.Клиент;
//					vFolioObj.DateTimeFrom = vGuestGroupObj.CheckInDate;
//					vFolioObj.DateTimeTo = vGuestGroupObj.ДатаВыезда;
//					vFolioObj.ГруппаГостей = GuestGroup;
//				Else
//					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
//					vFolioObj = vCRToRow.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					vFolioObj.ДокОснование = Неопределено;
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//				EndIf;
//			EndIf;
//			If TypeOf(pOwner) = Type("CatalogRef.Контрагенты") Тогда
//				vFolioObj.Контрагент = pOwner;
//				vGuestGroupObj.Контрагент = pOwner;
//			ElsIf TypeOf(pOwner) = Type("CatalogRef.Договора") Тогда
//				vFolioObj.Контрагент = pOwner.Owner;
//				vFolioObj.Договор = pOwner;
//				vGuestGroupObj.Контрагент = pOwner.Owner;
//			ElsIf TypeOf(pOwner) = Type("CatalogRef.Clients") Тогда
//				vFolioObj.Клиент = pOwner;
//				vGuestGroupObj.Клиент = pOwner;
//			ElsIf TypeOf(pOwner) = Type("CatalogRef.НомернойФонд") Тогда
//				vFolioObj.НомерРазмещения = pOwner;
//			EndIf;
//			vFolioObj.Write(DocumentWriteMode.Write);
//			vCRToRow.ChargingFolio = vFolioObj.Ref;
//		EndDo;
//		// Load changed charging rules to the tabular part
//		vGuestGroupObj.ChargingRules.Load(vCRTo);
//		
//		vGuestGroupObj.Write();
//		GuestGroup = vGuestGroupObj.Ref;
//	Else	
//		// Вставить owners charging rules before this document charging rules
//		For Each vCRRow In vCRFrom Do
//			// Check if current folio should be used as template
//			vIsTemplate = True;
//			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//				vIsTemplate = НЕ vCRRow.ChargingFolio.IsMaster;
//			EndIf;
//			// Try to find existing charging rule of the same type
//			vReuseFolio = False;
//			vCRToRows = vCRTo.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vCRRow.СпособРазделенияОплаты, vCRRow.ПравилаНачисления, vCRRow.ValidFromDate, vCRRow.ValidToDate));
//			If vCRToRows.Count() = 1 Тогда
//				// Reuse existing one
//				vCRToRow = vCRToRows.Get(0);
//				vReuseFolio = True;
//			Else
//				// New charging rule row
//				vCRToRow = vCRTo.Вставить(j);
//				j = j + 1;
//			EndIf;
//			vCRToRow.СпособРазделенияОплаты = vCRRow.СпособРазделенияОплаты;
//			vCRToRow.ПравилаНачисления = vCRRow.ПравилаНачисления;
//			vCRToRow.ValidFromDate = vCRRow.ValidFromDate;
//			vCRToRow.ValidToDate = vCRRow.ValidToDate;
//			vCRToRow.Owner = pOwner;
//			// Get template folio
//			If vIsTemplate Тогда
//				// If owner is ГруппаНомеров then try to find acive ГруппаНомеров folios first
//				If TypeOf(pOwner) = Type("CatalogRef.НомернойФонд") Тогда
//					vHotel = Гостиница;
//					vRoom = pOwner;
//					vFolioCurrency = Гостиница.FolioCurrency;
//					If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//						vFolioCurrency = vCRRow.ChargingFolio.ВалютаЛицСчета;
//					EndIf;
//					vRoomFolios = cmGetActiveRoomFolios(vHotel, vRoom, vFolioCurrency);
//					For Each vRoomFoliosRow in vRoomFolios Do
//						vCRRow.ChargingFolio = vRoomFoliosRow.СчетПроживания;
//						vIsTemplate = False;
//						Break;				
//					EndDo;
//				EndIf;
//			EndIf;
//			// If current charging folio is template then create new based on it
//			If НЕ vReuseFolio Тогда
//				If vIsTemplate Тогда
//					// Create new folio from template
//					vFolioObj = Documents.СчетПроживания.CreateDocument();
//					cmFillFolioFromTemplate(vFolioObj, vCRRow.ChargingFolio, Гостиница, Date);
//					vFolioObj.ДокОснование = pmGetThisDocumentRef();
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//					vFolioObj.Клиент = Гость;
//					vFolioObj.ГруппаГостей = GuestGroup;
//					vFolioObj.DateTimeFrom = CheckInDate;
//					vFolioObj.DateTimeTo = CheckOutDate;
//				Else
//					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
//					vFolioObj = vCRToRow.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					vFolioObj.ДокОснование = pmGetThisDocumentRef();
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//				EndIf;
//			Else
//				// Update folio from template
//				If vIsTemplate Тогда
//					vFolioObj = vCRToRow.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					cmFillFolioFromTemplate(vFolioObj, vCRRow.ChargingFolio, Гостиница, Date);
//					vFolioObj.ДокОснование = pmGetThisDocumentRef();
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//					vFolioObj.Клиент = Гость;
//					vFolioObj.ГруппаГостей = GuestGroup;
//					vFolioObj.DateTimeFrom = CheckInDate;
//					vFolioObj.DateTimeTo = CheckOutDate;
//				Else
//					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
//					vFolioObj = vCRToRow.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					vFolioObj.ДокОснование = pmGetThisDocumentRef();
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//				EndIf;
//			EndIf;
//			If TypeOf(pOwner) = Type("CatalogRef.Контрагенты") Тогда
//				vFolioObj.Контрагент = pOwner;
//			ElsIf TypeOf(pOwner) = Type("CatalogRef.Договора") Тогда
//				vFolioObj.Контрагент = pOwner.Owner;
//				vFolioObj.Договор = pOwner;
//			ElsIf TypeOf(pOwner) = Type("CatalogRef.Clients") Тогда
//				vFolioObj.Клиент = pOwner;
//			ElsIf TypeOf(pOwner) = Type("CatalogRef.НомернойФонд") Тогда
//				vFolioObj.НомерРазмещения = pOwner;
//			EndIf;
//			vFolioObj.Write(DocumentWriteMode.Write);
//			vCRToRow.ChargingFolio = vFolioObj.Ref;
//		EndDo;
//		// Load changed charging rules to the tabular part
//		ChargingRules.Load(vCRTo);
//	EndIf;
//	If ChargingRules.Count() = 0 Тогда
//		pmCreateFolios();
//	EndIf;
//КонецПроцедуры //pmLoadChargingRules
//
////-----------------------------------------------------------------------------
//Процедура pmRemoveChargingRules(pOwner) Экспорт
//	// Get list of hotel default charging rules owners
//	vHotelCROwners = cmGetHotelDefaultChargingRuleOwners(Гостиница);
//	// Remove charging rules for objects of the same type
//	i = 0;
//	vCRTo = ChargingRules.Unload();
//	While i < vCRTo.Count() Do
//		vCRRow = vCRTo.Get(i);
//		If TypeOf(vCRRow.Owner) = TypeOf(pOwner) And  
//		   ЗначениеЗаполнено(vCRRow.Owner) Тогда
//			If vHotelCROwners.FindByValue(vCRRow.Owner) = Неопределено Тогда
//				vCRTo.Delete(i);
//				Continue;
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	// Load changed charging rules to the tabular part
//	ChargingRules.Load(vCRTo);
//КонецПроцедуры //pmRemoveChargingRules
//
////-----------------------------------------------------------------------------
//Процедура pmRemoveIsMasterChargingRules() Экспорт
//	// Remove charging rules with "Is master" flag on
//	i = 0;
//	vCRTo = ChargingRules.Unload();
//	While i < vCRTo.Count() Do
//		vCRRow = vCRTo.Get(i);
//		If vCRRow.IsMaster Тогда
//			vCRTo.Delete(i);
//			Continue;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	// Load changed charging rules to the tabular part
//	ChargingRules.Load(vCRTo);
//КонецПроцедуры //pmRemoveIsMasterChargingRules
//
////-----------------------------------------------------------------------------
//Процедура pmLoadMasterChargingRules(pMasterDoc) Экспорт
//	// Remove "Is master" charging rules
//	i = 0;
//	j = 0;
//	vCRTo = ChargingRules.Unload();
//	While i < vCRTo.Count() Do
//		vCRRow = vCRTo.Get(i);
//		If vCRRow.IsMaster Тогда
//			vCRTo.Delete(i);
//			// Save Должность of first deleted row
//			If j = 0 Тогда
//				j = i;
//			EndIf;
//			Continue;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	// Load charging rules of the master document
//	If ЗначениеЗаполнено(pMasterDoc) Тогда
//		vCRFrom = pMasterDoc.ChargingRules.Unload();
//		If vCRFrom <> Неопределено Тогда
//			If vCRFrom.Count() > 0 Тогда
//				For Each vCRRow In vCRFrom Do
//					vCRToRow = vCRTo.Вставить(j);
//					vCRToRow.СпособРазделенияОплаты = vCRRow.СпособРазделенияОплаты;
//					vCRToRow.ПравилаНачисления = vCRRow.ПравилаНачисления;
//					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
//					vCRToRow.ValidFromDate = vCRRow.ValidFromDate;
//					vCRToRow.ValidToDate = vCRRow.ValidToDate;
//					vCRToRow.Owner = pMasterDoc;
//					vCRToRow.IsMaster = True;
//					vCRToRow.IsPersonal = True;
//					vCRToRow.IsTransfer = True;
//					j = j + 1;
//				EndDo;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Load changed charging rules to the tabular part
//	ChargingRules.Load(vCRTo);
//КонецПроцедуры //pmLoadMasterChargingRules
//
////-----------------------------------------------------------------------------
//Процедура pmOverloadMasterChargingRules(pMasterDoc) Экспорт
//	// Change owner and take master folios from the master document
//	For Each vCRRow In ChargingRules Do	
//		If vCRRow.IsMaster Тогда
//			vOldOwner = vCRRow.Owner;
//			If TypeOf(vOldOwner) = Type("DocumentRef.Размещение") Or
//			   TypeOf(vOldOwner) = Type("DocumentRef.Reservation") Тогда
//				// Try to find index of old owner folio in the old owner charging rules
//				vInd = -1;
//				For Each vOldOwnerCRRow In vOldOwner.ChargingRules Do
//					If vCRRow.ChargingFolio = vOldOwnerCRRow.ChargingFolio Тогда
//						vInd = vOldOwnerCRRow.LineNumber - 1;
//						Break;
//					EndIf;
//				EndDo;
//				// Replace old charging folio with folio from the new master doc by index
//				vCRRow.Owner = pMasterDoc;
//				If vInd >= 0 And pMasterDoc.ChargingRules.Count() > vInd Тогда
//					vNewOwnerCRRow = pMasterDoc.ChargingRules.Get(vInd);
//					vCRRow.ChargingFolio = vNewOwnerCRRow.ChargingFolio;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmOverloadMasterChargingRules
//
////-----------------------------------------------------------------------------
//Function GetRoomMainReservation()
//	vOneRoomDoc = Неопределено;
//	// Run query
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.Posted
//	|	AND Reservation.ГруппаГостей = &qGuestGroup
//	|	AND (Reservation.НомерРазмещения = &qRoom
//	|				AND &qRoomIsFilled
//	|			OR Reservation.НомерДока = &qNumber)
//	|	AND Reservation.ВидРазмещения.ТипРазмещения = &qAccommodationTypeType
//	|	AND Reservation.ReservationStatus.IsActive";
//	vQry.SetParameter("qGuestGroup", GuestGroup);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qRoomIsFilled", ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qAccommodationTypeType", Перечисления.AccomodationTypes.НомерРазмещения);
//	vQry.SetParameter("qNumber", Number);
//	vOneRoomDocs = vQry.Execute().Unload();
//	If vOneRoomDocs.Count() > 0 Тогда
//		vOneRoomDoc = vOneRoomDocs.Get(0).Ref;
//	ElsIf ЗначениеЗаполнено(RoomType) And RoomType.DoesNotAffectRoomRevenueStatistics Тогда
//		// Try to find main reservation by guest
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	Reservation.Ref
//		|FROM
//		|	Document.Reservation AS Reservation
//		|WHERE
//		|	Reservation.Posted
//		|	AND Reservation.ГруппаГостей = &qGuestGroup
//		|	AND Reservation.Клиент = &qGuest
//		|	AND &qGuestIsFilled
//		|	AND Reservation.ВидРазмещения.ТипРазмещения = &qAccommodationTypeType
//		|	AND Reservation.ReservationStatus.IsActive";
//		vQry.SetParameter("qGuestGroup", GuestGroup);
//		vQry.SetParameter("qGuest", Гость);
//		vQry.SetParameter("qGuestIsFilled", ЗначениеЗаполнено(Гость));
//		vQry.SetParameter("qAccommodationTypeType", Перечисления.AccomodationTypes.НомерРазмещения);
//		vQry.SetParameter("qNumber", Number);
//		vOneRoomDocs = vQry.Execute().Unload();
//		If vOneRoomDocs.Count() > 0 Тогда
//			vOneRoomDoc = vOneRoomDocs.Get(0).Ref;
//		EndIf;
//	EndIf;
//	Return vOneRoomDoc;
//EndFunction //GetRoomMainReservation
//
////-----------------------------------------------------------------------------
//Процедура pmLoadDefaultChargingRules() Экспорт
//	ChargingRules.Clear();
//	If ЗначениеЗаполнено(AccommodationType) And AccommodationType.НачислятьНаЛицевойСчет Тогда
//		vOneRoomDoc = GetRoomMainReservation();
//		If ЗначениеЗаполнено(vOneRoomDoc) Тогда
//			// Use folios from the one ГруппаНомеров document
//			If AccommodationType.НеСоздаватьПерсЛЦ Тогда
//				cmLoadMainRoomGuestChargingRules(ThisObject, vOneRoomDoc);
//			Else
//				cmUseParentChargingRules(ThisObject, vOneRoomDoc, True);
//			EndIf;
//			i = 0;
//			While i < ChargingRules.Count() Do
//				vCRRow = ChargingRules.Get(i);
//				If vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePrice Or
//				   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePriceByRoomType Or 
//				   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePricePercent Or 
//				   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenueAmount Or 
//				   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RestOfRoomRevenuePrice Тогда
//					ChargingRules.Delete(i);
//					Continue;
//				EndIf;
//				i = i + 1;
//			EndDo;
//		Else
//			pmCreateFolios();
//		EndIf;
//	Else
//		pmCreateFolios();
//	EndIf;
//	If ЗначениеЗаполнено(Контрагент) And НЕ ЗначениеЗаполнено(Contract) Тогда
//		pmLoadChargingRules(Контрагент);
//	EndIf;
//	If ЗначениеЗаполнено(Contract) Тогда
//		pmLoadChargingRules(Contract);
//	EndIf;
//	If ЗначениеЗаполнено(Гость) Тогда
//		pmLoadChargingRules(Гость);
//	EndIf;
//	If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		pmLoadChargingRules(ГруппаНомеров);
//	EndIf;
//КонецПроцедуры //pmLoadDefaultChargingRules
//
////-----------------------------------------------------------------------------
//Процедура pmReloadDefaultChargingRules(pOneRoomDoc) Экспорт
//	If AccommodationType.НеСоздаватьПерсЛЦ Тогда
//		// Load folios from the one ГруппаНомеров document and mark them as transfer
//		cmLoadMainRoomGuestChargingRules(ThisObject, pOneRoomDoc);
//	Else
//		// Clear all charging rules but personal or master
//		p = -1;
//		i = 0;
//		While i < ChargingRules.Count() Do
//			vCRRow = ChargingRules.Get(i);
//			If НЕ vCRRow.IsPersonal And НЕ vCRRow.IsMaster Тогда
//				ChargingRules.Delete(i);
//				// Save Должность of first deleted row
//				If p = -1 Тогда
//					p = i;
//				EndIf;
//				Continue;
//			EndIf;
//			i = i + 1;
//		EndDo;
//		If p = -1 Тогда
//			p = 0;
//		EndIf;
//		// Use folios from the one ГруппаНомеров document
//		For Each vRMCRRow In pOneRoomDoc.ChargingRules Do
//			If НЕ vRMCRRow.IsPersonal And НЕ vRMCRRow.IsMaster Тогда
//				vCRRow = ChargingRules.Вставить(p);
//				FillPropertyValues(vCRRow, vRMCRRow, , "LineNumber");
//				vCRRow.IsTransfer = True;
//				p = p + 1;
//			EndIf;
//		EndDo;
//		// Remove splitters
//		i = 0;
//		While i < ChargingRules.Count() Do
//			vCRRow = ChargingRules.Get(i);
//			If vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePrice Or
//			   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePriceByRoomType Or 
//			   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenuePricePercent Or 
//			   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RoomRevenueAmount Or 
//			   vCRRow.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.RestOfRoomRevenuePrice Тогда
//				ChargingRules.Delete(i);
//				Continue;
//			EndIf;
//			i = i + 1;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmReloadDefaultChargingRules
//
////-----------------------------------------------------------------------------
//Процедура pmAddBankTransferChargingRule() Экспорт
//	vCustomer = Контрагент;
//	vContract = Contract;
//	If НЕ ЗначениеЗаполнено(vCustomer) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			vCustomer = Гостиница.IndividualsCustomer;
//			vContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(vCustomer) Тогда
//		ВызватьИсключение NStr("en='Контрагент is not defined!';ru='Не указан контрагент!';de='Der Partner ist nicht angegeben!'");
//	EndIf;
//	// Get default owners charging rules
//	vOwnerCRs = Гостиница.CustomerChargingRules;
//	If ЗначениеЗаполнено(vContract) And vContract.ChargingRules.Count() > 0 Тогда
//		vOwnerCRs = vContract.ChargingRules;
//	ElsIf vCustomer.ChargingRules.Count() > 0  Тогда
//		vOwnerCRs = vCustomer.ChargingRules;
//	Else 
//		vCustomerParent = vCustomer.Parent;
//		While ЗначениеЗаполнено(vCustomerParent) Do
//			If vCustomerParent.ChargingRules.Count() > 0  Тогда
//				vOwnerCRs = vCustomerParent.ChargingRules;
//				Break;
//			EndIf;
//			vCustomerParent = vCustomerParent.Parent; 
//		EndDo;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.UseGuestGroupFolios And ЗначениеЗаполнено(GuestGroup) Тогда
//		If vOwnerCRs.Count() = 0 Тогда
//			vGuestGroupObj = GuestGroup.GetObject();
//			vGuestGroupObj.Read();
//			vGuestGroupObj.Контрагент = vCustomer;
//			
//			// Try to update existing charging rules
//			vCRIsFound = False;
//			vCRRows = vGuestGroupObj.ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", Перечисления.ChargingRuleTypes.InRate, Неопределено, '00010101', '00010101'));
//			If vCRRows.Count() = 1 Тогда
//				vCRIsFound = True;
//				vCR = vCRRows.Get(0);
//			Else
//				vCR = vGuestGroupObj.ChargingRules.Вставить(0);
//			EndIf;
//			
//			// Create new folio and use base rules
//			If vCRIsFound And ЗначениеЗаполнено(vCR.ChargingFolio) Тогда
//				vFolioObj = vCR.ChargingFolio.GetObject();
//				vFolioObj.Read();
//			Else
//				vFolioObj = Documents.СчетПроживания.CreateDocument();
//			EndIf;
//			cmFillFolioFromTemplate(vFolioObj, Неопределено, Гостиница, Date);
//			vFolioObj.ДокОснование = Неопределено;
//			vFolioObj.Фирма = Фирма;
//			vFolioObj.Контрагент = vCustomer;
//			vFolioObj.Договор = vContract;
//			vFolioObj.Агент = Agent;
//			vFolioObj.ГруппаГостей = GuestGroup;
//			vFolioObj.СпособОплаты = Гостиница.PaymentMethodForCustomerPayments;
//			If ЗначениеЗаполнено(vContract) Тогда
//				vFolioObj.ВалютаЛицСчета = vContract.AccountingCurrency;
//				If ЗначениеЗаполнено(vContract.PlannedPaymentMethod) Тогда
//					vFolioObj.СпособОплаты = vContract.PlannedPaymentMethod;
//				EndIf;
//			Else
//				vFolioObj.ВалютаЛицСчета = vCustomer.AccountingCurrency;
//				If ЗначениеЗаполнено(vCustomer.PlannedPaymentMethod) Тогда
//					vFolioObj.СпособОплаты = vCustomer.PlannedPaymentMethod;
//				EndIf;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
//				vFolioObj.Клиент = GuestGroup.Client;
//			EndIf;
//			vFolioObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//			vFolioObj.DateTimeFrom = GuestGroup.CheckInDate;
//			vFolioObj.DateTimeTo = GuestGroup.CheckOutDate;
//			vFolioObj.Write(DocumentWriteMode.Write);
//			
//			// Add new charging rule
//			vCR.ChargingFolio = vFolioObj.Ref;
//			vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InRate;
//			
//			// Save guest group
//			vGuestGroupObj.Write();
//		Else
//			vGuestGroupObj = GuestGroup.GetObject();
//			vGuestGroupObj.Read();
//			vGuestGroupObj.Контрагент = vCustomer;
//			
//			// Do for each owner charging rule
//			For i = 0 To (vOwnerCRs.Count() - 1) Do
//				vOwnerCRsRow = vOwnerCRs.Get(i);
//				If НЕ ЗначениеЗаполнено(vOwnerCRsRow.ChargingFolio) Тогда
//					Continue;
//				EndIf;
//				
//				// Try to find existing charging rule row with the same type
//				vCRIsFound = False;
//				vCRRows = vGuestGroupObj.ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vOwnerCRsRow.СпособРазделенияОплаты, vOwnerCRsRow.ПравилаНачисления, vOwnerCRsRow.ValidFromDate, vOwnerCRsRow.ValidToDate));
//				If vCRRows.Count() = 1 Тогда
//					vCRIsFound = True;
//					vCR = vCRRows.Get(0);
//				Else
//					vCR = vGuestGroupObj.ChargingRules.Вставить(i);
//				EndIf;
//				
//				// Get folio object
//				vFolioObj = Неопределено;
//				If vCRIsFound And ЗначениеЗаполнено(vCR.ChargingFolio) And НЕ vOwnerCRsRow.ChargingFolio.IsMaster Тогда
//					vFolioObj = vCR.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					cmFillFolioFromTemplate(vFolioObj, vOwnerCRsRow.ChargingFolio, Гостиница, Date);
//					vFolioObj.ДокОснование = Неопределено;
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//					vFolioObj.Контрагент = vCustomer;
//					vFolioObj.Договор = vContract;
//					vFolioObj.Агент = Agent;
//					vFolioObj.ГруппаГостей = GuestGroup;
//					vFolioObj.DateTimeFrom = GuestGroup.CheckInDate;
//					vFolioObj.DateTimeTo = GuestGroup.CheckOutDate;
//					If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
//						vFolioObj.Клиент = GuestGroup.Client;
//					EndIf;
//					vFolioObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//					vFolioObj.Write(DocumentWriteMode.Write);
//				Else
//					If НЕ vOwnerCRsRow.ChargingFolio.IsMaster Тогда
//						// Create new folio and take parameters from the template folio
//						vFolioObj = Documents.СчетПроживания.CreateDocument();
//						cmFillFolioFromTemplate(vFolioObj, vOwnerCRsRow.ChargingFolio, Гостиница, Date);
//						vFolioObj.ДокОснование = Неопределено;
//						If НЕ vFolioObj.DoNotUpdateCompany Тогда
//							vFolioObj.Фирма = Фирма;
//						EndIf;
//						vFolioObj.Контрагент = vCustomer;
//						vFolioObj.Договор = vContract;
//						vFolioObj.Агент = Agent;
//						vFolioObj.ГруппаГостей = GuestGroup;
//						vFolioObj.DateTimeFrom = GuestGroup.CheckInDate;
//						vFolioObj.DateTimeTo = GuestGroup.CheckOutDate;
//						If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
//							vFolioObj.Клиент = GuestGroup.Client;
//						EndIf;
//						vFolioObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//						vFolioObj.Write(DocumentWriteMode.Write);
//					Else
//						vFolioObj = vOwnerCRsRow.ChargingFolio.GetObject();
//						vFolioObj.Read();
//					EndIf;
//				EndIf;
//				
//				// Add new charging rule
//				vCR.ChargingFolio = vFolioObj.Ref;
//				vCR.СпособРазделенияОплаты = vOwnerCRsRow.СпособРазделенияОплаты;
//				vCR.ПравилаНачисления = vOwnerCRsRow.ПравилаНачисления;
//				vCR.ValidFromDate = vOwnerCRsRow.ValidFromDate;
//				vCR.ValidToDate = vOwnerCRsRow.ValidToDate;
//			EndDo;
//			
//			// Save guest group
//			vGuestGroupObj.Write();
//		EndIf;
//	Else
//		If vOwnerCRs.Count() = 0 Тогда
//			// Try to find existing charging rule row with the same type
//			vCRIsFound = False;
//			vCRRows = ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", Перечисления.ChargingRuleTypes.InRate, Неопределено, '00010101', '00010101'));
//			If vCRRows.Count() = 1 Тогда
//				vCRIsFound = True;
//				vCR = vCRRows.Get(0);
//			Else
//				vCR = ChargingRules.Вставить(0);
//			EndIf;
//			
//			// Create new folio and use base rules
//			If vCRIsFound And ЗначениеЗаполнено(vCR.ChargingFolio) Тогда
//				vFolioObj = vCR.ChargingFolio.GetObject();
//				vFolioObj.Read();
//			Else
//				vFolioObj = Documents.СчетПроживания.CreateDocument();
//			EndIf;
//			cmFillFolioFromTemplate(vFolioObj, Неопределено, Гостиница, Date);
//			If НЕ ЗначениеЗаполнено(vFolioObj.ДокОснование) Or 
//			   ЗначениеЗаполнено(vFolioObj.ДокОснование) And TypeOf(vFolioObj.ДокОснование) <> Type("DocumentRef.Размещение") Тогда
//				vFolioObj.ДокОснование = pmGetThisDocumentRef();
//			EndIf;
//			vFolioObj.Фирма = Фирма;
//			vFolioObj.Контрагент = vCustomer;
//			vFolioObj.Договор = vContract;
//			vFolioObj.Агент = Agent;
//			vFolioObj.ГруппаГостей = GuestGroup;
//			vFolioObj.СпособОплаты = Гостиница.PaymentMethodForCustomerPayments;
//			If ЗначениеЗаполнено(vContract) Тогда
//				vFolioObj.ВалютаЛицСчета = vContract.AccountingCurrency;
//				If ЗначениеЗаполнено(vContract.PlannedPaymentMethod) Тогда
//					vFolioObj.СпособОплаты = vContract.PlannedPaymentMethod;
//				EndIf;
//			Else
//				vFolioObj.ВалютаЛицСчета = vCustomer.AccountingCurrency;
//				If ЗначениеЗаполнено(vCustomer.PlannedPaymentMethod) Тогда
//					vFolioObj.СпособОплаты = vCustomer.PlannedPaymentMethod;
//				EndIf;
//			EndIf;
//			vFolioObj.Клиент = Гость;
//			vFolioObj.НомерРазмещения = ГруппаНомеров;
//			vFolioObj.DateTimeFrom = CheckInDate;
//			vFolioObj.DateTimeTo = CheckOutDate;
//			vFolioObj.Write(DocumentWriteMode.Write);
//			
//			// Add new charging rule
//			If ЗначениеЗаполнено(vContract) Тогда
//				vCR.Owner = vContract;
//			Else
//				vCR.Owner = vCustomer;
//			EndIf;
//			vCR.ChargingFolio = vFolioObj.Ref;
//			vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InRate;
//		Else
//			For i = 0 To (vOwnerCRs.Count() - 1) Do
//				vOwnerCRsRow = vOwnerCRs.Get(i);
//				If НЕ ЗначениеЗаполнено(vOwnerCRsRow.ChargingFolio) Тогда
//					Continue;
//				EndIf;
//				
//				// Try to find existing charging rule row with the same type
//				vCRIsFound = False;
//				vCRRows = ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vOwnerCRsRow.СпособРазделенияОплаты, vOwnerCRsRow.ПравилаНачисления, vOwnerCRsRow.ValidFromDate, vOwnerCRsRow.ValidToDate));
//				If vCRRows.Count() = 1 Тогда
//					vCRIsFound = True;
//					vCR = vCRRows.Get(0);
//				Else
//					vCR = ChargingRules.Вставить(i);
//				EndIf;
//				
//				// Get folio object
//				vFolioObj = Неопределено;
//				If vCRIsFound And ЗначениеЗаполнено(vCR.ChargingFolio) And НЕ vOwnerCRsRow.ChargingFolio.IsMaster Тогда
//					vFolioObj = vCR.ChargingFolio.GetObject();
//					vFolioObj.Read();
//					cmFillFolioFromTemplate(vFolioObj, vOwnerCRsRow.ChargingFolio, Гостиница, Date);
//					If НЕ ЗначениеЗаполнено(vFolioObj.ДокОснование) Or 
//					   ЗначениеЗаполнено(vFolioObj.ДокОснование) And TypeOf(vFolioObj.ДокОснование) <> Type("DocumentRef.Размещение") Тогда
//						vFolioObj.ДокОснование = pmGetThisDocumentRef();
//					EndIf;
//					If НЕ vFolioObj.DoNotUpdateCompany Тогда
//						vFolioObj.Фирма = Фирма;
//					EndIf;
//					vFolioObj.Контрагент = vCustomer;
//					vFolioObj.Договор = vContract;
//					vFolioObj.Агент = Agent;
//					vFolioObj.ГруппаГостей = GuestGroup;
//					vFolioObj.DateTimeFrom = CheckInDate;
//					vFolioObj.DateTimeTo = CheckOutDate;
//					vFolioObj.Клиент = Гость;
//					vFolioObj.НомерРазмещения = ГруппаНомеров;
//					vFolioObj.Write(DocumentWriteMode.Write);
//				Else
//					If НЕ vOwnerCRsRow.ChargingFolio.IsMaster Тогда
//						// Create new folio and take parameters from the template folio
//						vFolioObj = Documents.СчетПроживания.CreateDocument();
//						cmFillFolioFromTemplate(vFolioObj, vOwnerCRsRow.ChargingFolio, Гостиница, Date);
//						vFolioObj.ДокОснование = pmGetThisDocumentRef();
//						If НЕ vFolioObj.DoNotUpdateCompany Тогда
//							vFolioObj.Фирма = Фирма;
//						EndIf;
//						vFolioObj.Контрагент = vCustomer;
//						vFolioObj.Договор = vContract;
//						vFolioObj.Агент = Agent;
//						vFolioObj.ГруппаГостей = GuestGroup;
//						vFolioObj.DateTimeFrom = CheckInDate;
//						vFolioObj.DateTimeTo = CheckOutDate;
//						vFolioObj.Клиент = Гость;
//						vFolioObj.НомерРазмещения = ГруппаНомеров;
//						vFolioObj.Write(DocumentWriteMode.Write);
//					Else
//						vFolioObj = vOwnerCRsRow.ChargingFolio.GetObject();
//						vFolioObj.Read();
//					EndIf;
//				EndIf;
//				
//				// Add new charging rule
//				If ЗначениеЗаполнено(vContract) Тогда
//					vCR.Owner = vContract;
//				Else
//					vCR.Owner = vCustomer;
//				EndIf;
//				vCR.ChargingFolio = vFolioObj.Ref;
//				vCR.СпособРазделенияОплаты = vOwnerCRsRow.СпособРазделенияОплаты;
//				vCR.ПравилаНачисления = vOwnerCRsRow.ПравилаНачисления;
//				vCR.ValidFromDate = vOwnerCRsRow.ValidFromDate;
//				vCR.ValidToDate = vOwnerCRsRow.ValidToDate;
//			EndDo;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmAddBankTransferChargingRule
//
////-----------------------------------------------------------------------------
//// Get reservation prices for all day types of ГруппаНомеров rate
////-----------------------------------------------------------------------------
//Function pmGetPrices(pByDays = False) Экспорт
//	vPrices = Services.Unload();
//	If НЕ ЗначениеЗаполнено(Тариф) Тогда
//    	vPrices.Clear();
//		Return vPrices;
//	EndIf;
//	// Remove not in price services
//	vNotInPriceRows = vPrices.FindRows(New Structure("IsInPrice", False));
//	If vNotInPriceRows <> Неопределено Тогда
//		For Each vNotInPriceRow In vNotInPriceRows Do
//			vPrices.Delete(vNotInPriceRow);
//		EndDo;
//	EndIf;
//	// Recalculate prices taking discounts into account
//	For Each vCurSrv In vPrices Do
//		If ЗначениеЗаполнено(Agent) And Agent = Контрагент And AgentCommission <> 0 And 
//		   cmCustomerIsPayer(ChargingRules.Unload(), Контрагент, Contract, GuestGroup) Тогда
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
//		// Take quantity into account
//		If НЕ vCurSrv.IsRoomRevenue And vCurSrv.IsInPrice And vCurSrv.Price <> 0 Тогда
//			If vCurSrv.Service.ChargePerPerson Тогда
//				If NumberOfPersons <> 0 Тогда
//					vCurSrv.Price = vCurSrv.Sum / NumberOfPersons;
//				EndIf;
//			Else
//				If RoomQuantity <> 0 Тогда
//					vCurSrv.Price = vCurSrv.Sum / RoomQuantity;
//				EndIf;
//			EndIf;
//		EndIf;
//		// Change accounting dates for breakfast
//		If vCurSrv.IsInPrice And vCurSrv.Price <> 0 And 
//		   ЗначениеЗаполнено(vCurSrv.Service.QuantityCalculationRule) And
//		   vCurSrv.Service.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//			If BegOfDay(vCurSrv.AccountingDate) > BegOfDay(CheckInDate) Тогда
//				vCurSrv.AccountingDate = vCurSrv.AccountingDate - 24*3600;
//				vCurSrv.CalendarDayType = cmGetDocumentCalendarDayType(ThisObject, vCurSrv.AccountingDate);
//			EndIf;
//		EndIf;
//	EndDo;	
//	// Set is manual price flag for all services per accounting day where at least one manual price service is
//	vDays = vPrices.Copy(, "УчетнаяДата, IsManualPrice");
//	vDays.GroupBy("УчетнаяДата, IsManualPrice",);
//	vMPDays = vDays.FindRows(New Structure("IsManualPrice", True));
//	For Each vMPDay In vMPDays Do
//		vDayRows = vPrices.FindRows(New Structure("УчетнаяДата", vMPDay.УчетнаяДата));
//		For Each vDayRow In vDayRows Do
//			vDayRow.IsManualPrice = True;
//		EndDo;
//	EndDo;
//	// Group services by accounting date to get prices per day
//	vPrices.GroupBy("УчетнаяДата, ТипДеньКалендарь, Услуга, IsManualPrice, ВалютаЛицСчета", "Цена");
//	// Clear accounting date for all services where there is no manual price
//	For Each vRow In vPrices Do
//		If НЕ vRow.IsManualPrice And НЕ pByDays Тогда
//			vRow.AccountingDate = '00010101';
//		EndIf;
//	EndDo;
//	// Group services by all attributes to remove per accounting date groups
//	vPrices.GroupBy("УчетнаяДата, ТипДеньКалендарь, Услуга, ВалютаЛицСчета, Цена", );
//	// Remove duplicated rows (this means that we will take prices from check-in day only)
//	vPricesKeys = vPrices.CopyColumns();
//	i = 0;
//	While i < vPrices.Count() Do
//		vCurSrv = vPrices.Get(i);
//		vKeyRows = vPricesKeys.FindRows(New Structure("УчетнаяДата, ТипДеньКалендарь, Услуга, ВалютаЛицСчета", 
//		                                              vCurSrv.УчетнаяДата,
//		                                              vCurSrv.ТипДняКалендаря,
//		                                              vCurSrv.Услуга,
//		                                              vCurSrv.ВалютаЛицСчета));
//		If vKeyRows.Count() = 0 Тогда
//			vKeySrv = vPricesKeys.Add();
//			FillPropertyValues(vKeySrv, vCurSrv);
//			i = i + 1;
//		Else
//			// Delete duplicated row
//			vPrices.Delete(i);
//		EndIf;
//	EndDo;	
//	// Group prices by all dimension attributes except service to get final price per dimension group
//	vPrices.GroupBy("УчетнаяДата, ТипДеньКалендарь, ВалютаЛицСчета", "Цена");
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
//	If ЗначениеЗаполнено(Гость) Тогда
//		If ЗначениеЗаполнено(Гость.Language) Тогда
//			Return Гость.Language;
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
//		Тариф = Гостиница.Тариф;
//		RoomRateServiceGroup = Гостиница.RoomRateServiceGroup;
//		ReportingCurrency = Гостиница.ReportingCurrency;
//		ReportingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, ReportingCurrency, Date);
//		// Recreate guest group as it has hotel as owner
//		pmCreateGuestGroup();
//	EndIf;
//КонецПроцедуры //pmProcessHotelChange	
//
////-----------------------------------------------------------------------------
//Function pmGetAccommodations() Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Размещение.Ref
//	|FROM
//	|	Document.Размещение AS Размещение
//	|WHERE
//	|	Размещение.ДокОснование = &qParentDoc
//	|	AND Размещение.Posted = TRUE
//	|ORDER BY
//	|	Размещение.PointInTime";
//	vQry.SetParameter("qParentDoc", Ref);
//	vAccs = vQry.Execute().Unload();
//	Return vAccs;
//EndFunction //pmGetAccommodations
//
////-----------------------------------------------------------------------------
//Function pmSetPlannedPaymentMethod(rPayerStr = "") Экспорт
//	vPayer = Перечисления.КтоПлатит1.Клиент;
//	rPayerStr = "";
//	vAccSrvFolio = Неопределено;
//	vChargingRules = ChargingRules.Unload();
//	cmAddGuestGroupChargingRules(vChargingRules, GuestGroup);
//	If vChargingRules.Count() > 0 Тогда
//		If Services.Count() > 0 Тогда
//			// Set planned payment method from the accommodation service folio
//			i = Services.Count() - 1;
//			While i >= 0 Do
//				vSrvRow = Services.Get(i);
//				If ЗначениеЗаполнено(vSrvRow.СчетПроживания) Тогда
//					If vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice And НЕ vSrvRow.RoomRevenueAmountsOnly Тогда
//						vAccSrvFolio = vSrvRow.СчетПроживания;
//						Break;
//					EndIf;
//				EndIf;
//				i = i - 1;
//			EndDo;
//		EndIf;
//		If ЗначениеЗаполнено(vAccSrvFolio) And ЗначениеЗаполнено(vAccSrvFolio.СпособОплаты) Тогда
//			If PlannedPaymentMethod <> vAccSrvFolio.СпособОплаты Тогда
//				PlannedPaymentMethod = vAccSrvFolio.СпособОплаты;
//			EndIf;
//		Else
//			// Set planned payment method from the first charging rule
//			vCRRow = vChargingRules.Get(0);
//			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//				If ЗначениеЗаполнено(vCRRow.ChargingFolio.СпособОплаты) Тогда
//					vAccSrvFolio = vCRRow.ChargingFolio;
//					If PlannedPaymentMethod <> vAccSrvFolio.СпособОплаты Тогда
//						PlannedPaymentMethod = vAccSrvFolio.СпособОплаты;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(vAccSrvFolio) Тогда
//		vCustomer = Неопределено;
//		vClient = Неопределено;
//		For Each vCRRow In vChargingRules Do
//			If vCRRow.ChargingFolio = vAccSrvFolio Тогда 
//				If ЗначениеЗаполнено(vCRRow.Owner) Тогда
//					If TypeOf(vCRRow.Owner) = Type("CatalogRef.Контрагенты") Тогда
//						vCustomer = vCRRow.Owner;
//						Break;
//					ElsIf TypeOf(vCRRow.Owner) = Type("CatalogRef.Договора") Тогда
//						vCustomer = vCRRow.Owner.Owner;
//						Break;
//					ElsIf TypeOf(vCRRow.Owner) = Type("CatalogRef.Clients") Тогда
//						vClient = vCRRow.Owner;
//						Break;
//					EndIf;
//				Else
//					vClient = Гость;
//					Break;
//				EndIf;
//			EndIf;
//		EndDo;
//		If ЗначениеЗаполнено(vCustomer) Тогда
//			rPayerStr = TrimAll(vCustomer.Description);
//			If vCustomer = Контрагент Тогда
//				vPayer = Перечисления.КтоПлатит1.Контрагент;
//			Else
//				vPayer = Перечисления.КтоПлатит1.ChargingRules;
//			EndIf;
//		ElsIf ЗначениеЗаполнено(vClient) Тогда
//			rPayerStr = TrimAll(vClient.FullName);
//			If vClient = Гость Тогда
//				vPayer = Перечисления.КтоПлатит1.Клиент;
//			Else
//				vPayer = Перечисления.КтоПлатит1.ChargingRules;
//			EndIf;
//		ElsIf ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.IndividualsCustomer) Тогда
//			rPayerStr = TrimAll(Гостиница.IndividualsCustomer.Description);
//		EndIf;
//	EndIf;
//	Return vPayer;
//EndFunction //pmSetPlannedPaymentMethod
//
////-----------------------------------------------------------------------------
//Function pmGetAccommodationServiceChargingFolio() Экспорт
//	vAccSrvFolio = Неопределено;
//	If Services.Count() > 0 Тогда
//		For Each vSrvRow In Services Do
//			If vSrvRow.IsRoomRevenue And ЗначениеЗаполнено(vSrvRow.ЛицевойСчет) Тогда
//				vAccSrvFolio = vSrvRow.ЛицевойСчет;
//				Break;
//			EndIf;
//		EndDo;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(vAccSrvFolio) Тогда
//		vChargingRules = ChargingRules.Unload();
//		cmAddGuestGroupChargingRules(vChargingRules, GuestGroup);
//		If vChargingRules.Count() > 0 Тогда
//			vCRRow = vChargingRules.Get(0);
//			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//				vAccSrvFolio = vCRRow.ChargingFolio;
//			EndIf;
//		EndIf;
//	EndIf;
//	Return vAccSrvFolio;
//EndFunction //pmGetAccommodationServiceChargingFolio
//
////-----------------------------------------------------------------------------
//Процедура pmSetDoCharging() Экспорт 
//	vDoCharging = False;
//	If ЗначениеЗаполнено(ReservationStatus) And ReservationStatus.DoCharging And (НЕ ReservationStatus.DoChargingIfRoomIsFilled Or ReservationStatus.DoChargingIfRoomIsFilled And ЗначениеЗаполнено(ГруппаНомеров)) Тогда
//		vDoCharging = True;
//	EndIf;	
//	If DoCharging <> vDoCharging Тогда
//		DoCharging = vDoCharging;
//	EndIf;
//КонецПроцедуры //pmSetDoCharging
//
////-----------------------------------------------------------------------------
//Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	StatusHasChanged = False;
//	If pWriteMode = DocumentWriteMode.Проведение Тогда
//		pCancel	= pmCheckDocumentAttributes(ThisObject, Posted, vMessage, vAttributeInErr, True);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		Else
//			If ReservationStatus <> Ref.ReservationStatus Тогда
//				StatusHasChanged = True;
//			EndIf;
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And DoCharging And 
//		  (pWriteMode = DocumentWriteMode.ОтменаПроведения Or DeletionMark) And 
//		  (Services.Total("Сумма") <> 0 Or Services.Total("Количество") <> 0) And 
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
//				Message(NStr("en='All reservation charges are closed by settlements! Reservation is read only.';ru='Все начисления брони уже закрыты актами об оказании услуг! Редактирование такой брони запрещено.';de='Alle Anrechnungen der Reservierung wurden bereits durch Übergabeprotokolle über Dienstleistungserbringung geschlossen! Die Bearbeitung einer solchen Reservierung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ReservationStatus) Тогда
//		If (НЕ ReservationStatus.IsActive And 
//            НЕ ReservationStatus.IsCheckIn And 
//            НЕ ReservationStatus.IsInWaitingList And 
//		    НЕ ReservationStatus.IsPreliminary) Or 
//		   ReservationStatus.IsAnnulation Тогда
//			If НЕ ЗначениеЗаполнено(DateOfAnnulation) Тогда
//				DateOfAnnulation = CurrentDate();
//				AuthorOfAnnulation = ПараметрыСеанса.ТекПользователь;
//			EndIf;
//		Else
//			If ЗначениеЗаполнено(DateOfAnnulation) Тогда
//				DateOfAnnulation = '00010101';
//				AuthorOfAnnulation = Справочники.Сотрудники.EmptyRef();
//				AnnulationReason = Неопределено;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check DoCharging flag 
//	pmSetDoCharging();
//	// Fill guest full name (used to sort reservation's list by guest names)
//	If ЗначениеЗаполнено(Гость) Тогда
//		GuestFullName = Гость.FullName;
//	Else
//		GuestFullName = "";
//	EndIf;
//	// Check 1 second shift for check-in and check-out dates
//	If cm1SecondShift(CheckInDate) <> CheckInDate Тогда
//		CheckInDate = cm1SecondShift(CheckInDate);
//	EndIf;
//	If cm0SecondShift(CheckOutDate) <> CheckOutDate Тогда
//		CheckOutDate = cm1SecondShift(CheckOutDate);
//	EndIf;
//	// Check number of rooms and number of persons
//	If ЗначениеЗаполнено(AccommodationType) And AccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения And NumberOfRooms = 0 Тогда
//		pmCalculateResources();
//	EndIf;
//	// Calculate document sort code
//	SortCode = cmCalculateReservationSortCode(ThisObject);
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Function pmGetMasterReservation() Экспорт
//	vMasterDoc = Documents.Reservation.EmptyRef();
//	// Try to find master document in the list of all documents in the group
//	vGuestGroupReservations = GuestGroup.GetObject().pmGetReservations();
//	vMasterRow = vGuestGroupReservations.Find(True, "IsMaster");
//	If vMasterRow <> Неопределено Тогда
//		vMasterDoc = vMasterRow.Reservation;
//	EndIf;
//	Return vMasterDoc;
//EndFunction //pmGetMasterReservation
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("CatalogRef.ПутевкиКурсовки") Тогда
//			// Fill attributes with default values
//			pmFillAttributesWithDefaultValues();
//			// Fill reservation based on hotel product
//			HotelProduct = pBase.Ref;
//			RoomQuota = pBase.КвотаНомеров;
//			If ЗначениеЗаполнено(RoomQuota) Тогда
//				FillPropertyValues(ThisObject, RoomQuota, , "Примечания");
//			EndIf;
//			FillPropertyValues(ThisObject, HotelProduct, , "Примечания");
//			CheckInDate = cm1SecondShift(CheckInDate);
//			CheckOutDate = cm0SecondShift(CheckOutDate);
//			Duration = pmCalculateDuration();
//			// Calculate resources
//			pmCalculateResources();
//			// Calculate services
//			pmCalculateServices();
//			// Set planned payment method from the first charging rule
//			pmSetPlannedPaymentMethod();
//		ElsIf TypeOf(pBase) = Type("CatalogRef.ШаблоныОпераций") Тогда
//			// Reset price calculation date
//			PriceCalculationDate = '00010101';
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
//			If ЗначениеЗаполнено(pBase.КвотаНомеров) Тогда
//				RoomQuota = pBase.КвотаНомеров;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Тариф) Тогда
//				Тариф = pBase.Тариф;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.RoomRateType) Тогда
//				RoomRateType = pBase.RoomRateType;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.RoomRateServiceGroup) Тогда
//				RoomRateServiceGroup = pBase.RoomRateServiceGroup;
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
//			If ЗначениеЗаполнено(pBase.ReservationStatus) Тогда
//				ReservationStatus = pBase.ReservationStatus;
//				// Update DoCharging flag
//				pmSetDoCharging();
//			EndIf;
//			If НЕ IsBlankString(pBase.ConfirmationReply) Тогда
//				ConfirmationReply = TrimAll(pBase.ConfirmationReply);
//			EndIf;
//			If pBase.Rating <> 0 Тогда
//				Rating = pBase.Rating;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.PlannedPaymentMethod) Тогда
//				PlannedPaymentMethod = pBase.PlannedPaymentMethod;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.ВидРазмещения) Тогда
//				AccommodationType = pBase.ВидРазмещения;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.ТипНомера) Тогда
//				RoomType = pBase.ТипНомера;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.НомерРазмещения) Тогда
//				ГруппаНомеров = pBase.НомерРазмещения;
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
//			// Fill attributes with default values
//			pmFillAttributesWithDefaultValues();
//			// Fill check-in and check-out times from the ГруппаНомеров rate
//			If ЗначениеЗаполнено(Тариф) Тогда
//				vCheckInDate = CheckInDate;
//				If ЗначениеЗаполнено(Тариф.DefaultCheckInTime) Тогда
//					vCheckInDate = cm1SecondShift(BegOfDay(CheckInDate) + (Тариф.DefaultCheckInTime - BegOfDay(Тариф.DefaultCheckInTime)));
//				EndIf;
//				vCheckOutDate = CheckOutDate;
//				If Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour And 
//				   ЗначениеЗаполнено(Тариф.ReferenceHour) Тогда
//					vCheckOutDate = cm0SecondShift(BegOfDay(CheckOutDate) + (Тариф.ReferenceHour - BegOfDay(Тариф.ReferenceHour)));
//				EndIf;
//				If vCheckOutDate > vCheckInDate Тогда
//					CheckInDate = vCheckInDate;
//					CheckOutDate = vCheckOutDate;
//					Duration = pmCalculateDuration();
//				EndIf;
//			EndIf;
//			// Calculate resources
//			pmCalculateResources();
//			// Calculate services
//			pmCalculateServices();
//			// Set planned payment method from the first charging rule
//			pmSetPlannedPaymentMethod();
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Размещение") Тогда
//			// Fill attributes with default values
//			pmFillAttributesWithDefaultValues();
//			// Fill from base document
//			FillPropertyValues(ThisObject, pBase, , "Number, Date, Автор, DeletionMark, Posted");
//			RoomQuantity = 1;
//			ParentDoc = pBase;
//			CheckInDate = cm1SecondShift(CheckOutDate);
//			Duration = Гостиница.Duration;
//			CheckOutDate = pmCalculateCheckOutDate();
//			IsMaster = False;
//			// Clear old object charging rules list
//			ChargingRules.Clear();
//			// Create folios as copy of base folios
//			cmCreateChargingRulesBasedOnParent(ThisObject, pBase);
//			// Load prices
//			Prices.Load(pBase.Prices.Unload());
//			// Load ГруппаНомеров rates
//			RoomRates.Load(pBase.Тарифы.Unload());
//			// Load service packages
//			ServicePackages.Load(pBase.ПакетыУслуг.Unload());
//			// Load occupation percents
//			OccupationPercents.Load(pBase.OccupationPercents.Unload());
//			// Load manual services
//			pmLoadManualServicesFromParentDoc(pBase);
//			// Calculate resources
//			pmCalculateResources();
//			// Calculate services
//			pmCalculateServices();
//			// Load manual prices
//			pmLoadManualPricesFromParentDoc(pBase);
//			// Set planned payment method from the first charging rule
//			pmSetPlannedPaymentMethod();
//		EndIf;
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Процедура pmLoadManualServicesFromParentDoc(pBase, pIsUpdate = False) Экспорт
//	vChargingRules = ChargingRules.Unload();
//	vBaseChargingRules = pBase.ChargingRules.Unload();
//	// Remove manual services from the current document first
//	If pIsUpdate Тогда
//		vManualServicesArray = Services.FindRows(New Structure("IsManual", True));
//		For Each vRow In vManualServicesArray Do
//			Services.Delete(vRow);
//		EndDo;
//	EndIf;
//	// Load manual services
//	vBaseManualServicesArray = pBase.Услуги.Unload().FindRows(New Structure("IsManual", True));
//	For Each vBaseRow In vBaseManualServicesArray Do
//		vCurSrv = Services.Add();
//		FillPropertyValues(vCurSrv, vBaseRow);
//		// Recalculate quantity according to the number of persons
//		vCurSrv.Количество = vCurSrv.Количество / pBase.КоличествоЧеловек * NumberOfPersons;
//		// Recalculate resources
//		cmQuantityOnChange(vCurSrv.Цена, vCurSrv.Количество, vCurSrv.Сумма, vCurSrv.СтавкаНДС, vCurSrv.СуммаНДС);
//		// Recalculate service ГруппаНомеров sales parameters
//		cmRecalculateServiceRoomSalesParameters(vCurSrv, ThisObject);
//		// Try to find charging folio in the current document charging rules with the same conditions as in the base document
//		vCRWasFound = False;
//		vBaseCRRow = vBaseChargingRules.Find(vBaseRow.СчетПроживания, "ChargingFolio");
//		If vBaseCRRow <> Неопределено Тогда
//			vCRRows = vChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate, Owner", vBaseCRRow.СпособРазделенияОплаты, vBaseCRRow.ПравилаНачисления, vBaseCRRow.ValidFromDate, vBaseCRRow.ValidToDate, vBaseCRRow.Owner));
//			If vCRRows.Count() = 1 Тогда
//				vCRWasFound = True;
//				vCRRow = vCRRows.Get(0);
//				vCurSrv.СчетПроживания = vCRRow.ChargingFolio;
//			EndIf;
//		EndIf;
//		If НЕ vCRWasFound Тогда
//			// Assign charging folio according to the charging rules
//			pmSetServiceFolioBasedOnChargingRules(vCurSrv, vChargingRules, True);
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmLoadManualServicesFromParentDoc
//
////-----------------------------------------------------------------------------
//Процедура pmLoadManualPricesFromParentDoc(pBase) Экспорт
//	// Load manual prices
//	vManualPricesArray = pBase.Услуги.Unload().FindRows(New Structure("IsManualPrice, IsManual", True, False));
//	For Each vMPRow In vManualPricesArray Do
//		// Try to find appropriate automatic service
//		vServices = Services.FindRows(New Structure("УчетнаяДата, Услуга, IsManual", vMPRow.УчетнаяДата, vMPRow.Услуга, False));
//		For Each vCurSrv In vServices Do
//			If vCurSrv.ЭтоРазделение <> vMPRow.ЭтоРазделение Тогда
//				Continue;
//			EndIf;
//			If ЗначениеЗаполнено(vMPRow.СчетПроживания) And ЗначениеЗаполнено(pBase) And TypeOf(pBase) = Type("DocumentRef.Reservation") And pBase.RoomQuantity = 1 Тогда
//				FillPropertyValues(vCurSrv, vMPRow, , "УчетнаяДата, Услуга, IsManual, ВалютаЛицСчета, FolioCurrencyExchangeRate");
//				If vCurSrv.ВалютаЛицСчета <> vMPRow.СчетПроживания.ВалютаЛицСчета Тогда
//					vFolioObj = vMPRow.СчетПроживания.GetObject();
//					vFolioObj.Read();
//					vFolioObj.ВалютаЛицСчета = vCurSrv.ВалютаЛицСчета;
//					vFolioObj.Write(DocumentWriteMode.Write);
//				EndIf;
//			Else			
//				FillPropertyValues(vCurSrv, vMPRow, , "СчетПроживания, УчетнаяДата, Услуга, IsManual, ВалютаЛицСчета, FolioCurrencyExchangeRate");
//			EndIf;
//			// Change service quantity proportionally
//			If ЗначениеЗаполнено(pBase) And TypeOf(pBase) = Type("DocumentRef.Reservation") Тогда
//				vCurSrv.Количество = vCurSrv.Количество * (RoomQuantity / ?(pBase.RoomQuantity = 0, RoomQuantity, pBase.RoomQuantity));
//				// Recalculate service ГруппаНомеров sales parameters
//				cmRecalculateServiceRoomSalesParameters(vCurSrv, ThisObject);
//			EndIf;
//			// Recalculate all service resources
//			cmPriceOnChange(vCurSrv.Цена, vCurSrv.Количество, vCurSrv.Сумма, vCurSrv.СтавкаНДС, vCurSrv.СуммаНДС);
//			pmCalculateServiceDiscounts(vCurSrv);
//			pmCalculateServiceCommissions(vCurSrv);
//			vCurSrv.IsManualPrice = True;
//		EndDo;
//	EndDo;
//КонецПроцедуры //pmLoadManualPricesFromParentDoc
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
//	IsMaster = False;
//	ExternalCode = "";
//	AnnulationReason = Неопределено;
//	AuthorOfAnnulation = Справочники.Сотрудники.EmptyRef();
//	DateOfAnnulation = '00010101';
//	// Clear old object charging rules list
//	ChargingRules.Clear();
//	// Create folios as copy of base folios
//	cmCreateChargingRulesBasedOnParent(ThisObject, pCopiedObject.Ref);
//	// If there is master reservation in the group, then 
//	// load it's charging rules
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		vMasterDoc = pmGetMasterReservation();
//		If ЗначениеЗаполнено(vMasterDoc) Тогда
//			If pCopiedObject.IsMaster Тогда
//				pmLoadMasterChargingRules(vMasterDoc);
//			Else
//				// Check if there are already master charging rules
//				vMasterChargingRulesFound = cmCheckMasterChargingRulesArePresent(ThisObject);
//				If vMasterChargingRulesFound Тогда
//					pmOverloadMasterChargingRules(vMasterDoc);
//				Else
//					pmLoadMasterChargingRules(vMasterDoc);
//				EndIf;
//			EndIf;
//		Else
//			pmRemoveIsMasterChargingRules();
//		EndIf;
//	Else
//		pmRemoveIsMasterChargingRules();
//	EndIf;
//	// Calculate resources
//	pmCalculateResources();
//	// Calculate services
//	pmCalculateServices();
//	// Set planned payment method from the first charging rule
//	pmSetPlannedPaymentMethod();
//КонецПроцедуры //OnCopy
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateAccumulationDiscountForAdditionalService(pSrvRow) Экспорт
//	vAccDiscounts = pmGetAccumulatingDiscountResources();
//	If vAccDiscounts.Count() > 0 Тогда
//		vAccDiscountsRow = vAccDiscounts.Get(0);
//		vDiscountType = vAccDiscountsRow.ТипСкидки;
//		If НЕ ЗначениеЗаполнено(vDiscountType) Тогда
//			Return;
//		EndIf;
//		If pSrvRow.УчетнаяДата < vDiscountType.DateValidFrom Or
//		   (pSrvRow.УчетнаяДата > vDiscountType.DateValidTo And ЗначениеЗаполнено(vDiscountType.DateValidTo)) Тогда
//			Return;
//		EndIf;
//		vDiscountDimension = vAccDiscountsRow.ИзмерениеСкидки;
//		If cmIsServiceInServiceGroup(pSrvRow.Услуга, DiscountServiceGroup) And 
//		  (НЕ vDiscountType.IsForRackRatesOnly Or vDiscountType.IsForRackRatesOnly And ЗначениеЗаполнено(pSrvRow.Тариф) And pSrvRow.Тариф.IsRackRate) Тогда
//			vDiscountTypeObj = vDiscountType.GetObject();
//			For i = 1 To pSrvRow.LineNumber Do
//				vWrkSrvRow = Services.Get(i - 1);
//				If vWrkSrvRow.УчетнаяДата <= pSrvRow.УчетнаяДата Тогда
//					vSrvDiscountDimension = Неопределено;
//					vSrvResource = vDiscountTypeObj.pmCalculateResource(vWrkSrvRow, NumberOfPersons, vWrkSrvRow.СчетПроживания, DiscountCard, vSrvDiscountDimension);
//					If TypeOf(vSrvDiscountDimension) = TypeOf(vDiscountDimension) Тогда
//						If vSrvResource <> 0 Тогда
//							vAccDiscountsRow.Ресурс = vAccDiscountsRow.Ресурс + vSrvResource;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndDo;
//			vResource = vAccDiscountsRow.Ресурс;
//			vDiscountConfirmationText = "";
//			vDiscount = vDiscountTypeObj.pmGetAccumulatingDiscount(pSrvRow.Услуга, pSrvRow.УчетнаяДата, 
//																   vResource, 
//																   vDiscountConfirmationText);
//			If vDiscount <> 0 Тогда
//				pSrvRow.ТипСкидки = vDiscountType;
//				pSrvRow.Скидка = vDiscount;
//				pSrvRow.DiscountServiceGroup = DiscountServiceGroup;
//				pSrvRow.ОснованиеСкидки = vDiscountConfirmationText;
//			EndIf;
//		EndIf;
//	EndIf;						
//КонецПроцедуры //pmCalculateAccumulationDiscountForAdditionalService
//
////-----------------------------------------------------------------------------
//Процедура pmFillAccumulationDiscountForManualServices() Экспорт
//	// Fill accumulation discounts for manual services
//	If ЗначениеЗаполнено(DiscountType) And DiscountType.IsAccumulatingDiscount Тогда
//		For Each vSrvRow In Services Do
//			If vSrvRow.IsManual Тогда
//				If cmIsServiceInServiceGroup(vSrvRow.Service, DiscountServiceGroup) Тогда
//					pmCalculateAccumulationDiscountForAdditionalService(vSrvRow);
//					pmCalculateServiceDiscounts(vSrvRow);
//				Else
//					vSrvRow.DiscountType = Справочники.ТипыСкидок.EmptyRef();
//					vSrvRow.DiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//					vSrvRow.Discount = 0;
//					vSrvRow.DiscountConfirmationText = "";
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmFillAccumulationDiscountForManualServices
//
////-----------------------------------------------------------------------------
//Процедура pmClearManualServicesDiscount() Экспорт		
//	// Clear manual services discounts
//	For Each vSrvRow In Services Do
//		If vSrvRow.IsManual And ЗначениеЗаполнено(vSrvRow.DiscountType) Тогда
//			vSrvRow.DiscountType = Справочники.ТипыСкидок.EmptyRef();
//			vSrvRow.DiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//			vSrvRow.Discount = 0;
//			vSrvRow.DiscountConfirmationText = "";
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmClearManualServicesDiscount
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
//		If ЗначениеЗаполнено(DiscountCard.DiscountType) Тогда
//			vDiscountType = DiscountCard.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(CheckInDate, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.EachNDayIsFreeOfCharge > 0 Or
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
//			If ЗначениеЗаполнено(DiscountCard.Client) Тогда
//				If НЕ cmCheckUserPermissions("HavePermissionToUseClientDiscountCardWithAnyOtherClientHavingIt") Тогда
//					If vDiscountType.IsPersonalDiscount Тогда
//						If DiscountCard.Client <> Гость Тогда
//							DiscountCard = Справочники.ДисконтныеКарты.EmptyRef();
//							DiscountType = Справочники.ТипыСкидок.EmptyRef();
//							DiscountConfirmationText = "";
//							DiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//							Discount = 0;
//						EndIf;
//					ElsIf ЗначениеЗаполнено(GuestGroup) And ЗначениеЗаполнено(GuestGroup.Client) Тогда
//						If DiscountCard.Client <> GuestGroup.Client Тогда
//							DiscountCard = Справочники.ДисконтныеКарты.EmptyRef();
//							DiscountType = Справочники.ТипыСкидок.EmptyRef();
//							DiscountConfirmationText = "";
//							DiscountServiceGroup = Справочники.НаборыУслуг.EmptyRef();
//							Discount = 0;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(DiscountCard) And DiscountCard.TurnOffAutomaticDiscounts Тогда
//			TurnOffAutomaticDiscounts = DiscountCard.TurnOffAutomaticDiscounts;
//			vTurnOffAutomaticDiscountsWasSet = True;
//		EndIf;
//	EndIf;	
//	If ЗначениеЗаполнено(ClientType) Тогда
//		If ClientType.TurnOffAutomaticDiscounts Тогда
//			TurnOffAutomaticDiscounts = ClientType.TurnOffAutomaticDiscounts;
//			vTurnOffAutomaticDiscountsWasSet = True;
//		EndIf;
//		If ЗначениеЗаполнено(ClientType.DiscountType) Тогда
//			vDiscountType = ClientType.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(CheckInDate, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.EachNDayIsFreeOfCharge > 0 Or
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
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(CheckInDate, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.EachNDayIsFreeOfCharge > 0 Or
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
//	If ЗначениеЗаполнено(Гость) Тогда
//		If ЗначениеЗаполнено(Гость.DiscountType) Тогда
//			vDiscountType = Гость.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(CheckInDate, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.EachNDayIsFreeOfCharge > 0 Or
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				If IsBlankString(Гость.DiscountConfirmationText) Тогда
//					DiscountConfirmationText = NStr("en='Guest discount';ru='По гостю';de='Nach Gast'");
//				Else
//					DiscountConfirmationText = Гость.DiscountConfirmationText;
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
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(CheckInDate, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.EachNDayIsFreeOfCharge > 0 Or
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
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(CheckInDate, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.EachNDayIsFreeOfCharge > 0 Or
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
//	If ЗначениеЗаполнено(Тариф) Тогда
//		If ЗначениеЗаполнено(Тариф.DiscountType) Тогда
//			vDiscountType = Тариф.DiscountType;
//			vDiscount = vDiscountType.GetObject().pmGetDiscount(CheckInDate, , Гостиница);
//			If vDiscount > Discount Or vDiscountType.DifferentDiscountPercentsForServiceGroupsAllowed Or 
//			   vDiscountType.EachNDayIsFreeOfCharge > 0 Or
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.HasToBeDirectlyAssigned Or 
//			   vDiscountType.IsAccumulatingDiscount And vDiscountType.BonusCalculationFactor <> 0 Тогда 
//				DiscountType = vDiscountType;
//				DiscountServiceGroup = DiscountType.DiscountServiceGroup;
//				DiscountConfirmationText = NStr("en='ГруппаНомеров rate discount';ru='По тарифу';de='Nach Tarif'");
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
//		// Fill accumulation discounts for manual services
//		pmFillAccumulationDiscountForManualServices();
//	Else
//		// Clear manual services discounts
//		pmClearManualServicesDiscount();
//	EndIf;
//	If НЕ vTurnOffAutomaticDiscountsWasSet Тогда
//		TurnOffAutomaticDiscounts = vOldTurnOffAutomaticDiscounts;
//	EndIf;
//КонецПроцедуры //pmSetDiscounts
//
////-----------------------------------------------------------------------------
//Function pmGetAccommodationPlanAttributes(pDate, pRoomRates, pRoom, pRoomType, 
//	                                      pAccommodationType, pRoomRate, pCheckInDate) Экспорт
//	vCurStruct = New Structure("НомерРазмещения, ТипНомера, ВидРазмещения, Тариф, RoomChangeDate", 
//	                           pRoom, pRoomType, pAccommodationType, pRoomRate, pCheckInDate);
//	For Each vRRRow In pRoomRates Do
//		If vRRRow.УчетнаяДата > pDate Тогда
//			Break;
//		Else
//			If ЗначениеЗаполнено(vRRRow.НомерРазмещения) Тогда
//				vCurStruct.ГруппаНомеров = vRRRow.НомерРазмещения;
//				vCurStruct.RoomChangeDate = vRRRow.УчетнаяДата;
//			EndIf;
//			If ЗначениеЗаполнено(vRRRow.ТипНомера) Тогда
//				vCurStruct.RoomType = vRRRow.ТипНомера;
//			EndIf;
//			If ЗначениеЗаполнено(vRRRow.ВидРазмещения) Тогда
//				vCurStruct.AccommodationType = vRRRow.ВидРазмещения;
//			EndIf;
//			If ЗначениеЗаполнено(vRRRow.Тариф) Тогда
//				vCurStruct.Тариф = vRRRow.Тариф;
//			EndIf;
//		EndIf;	
//	EndDo;
//	Return vCurStruct;
//EndFunction //pmGetAccommodationPlanAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmDeleteUnusedChargingRuleFolios() Экспорт
//	vObjectRef = pmGetThisDocumentRef();
//	// If folio left in the list do not have any transactions based on it then delete it
//	For Each vCRRow In ChargingRules Do
//		If НЕ ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//			Continue;
//		EndIf;
//		vFolioRef = vCRRow.ChargingFolio;
//		If ЗначениеЗаполнено(vFolioRef.ParentDoc) And 
//		   vFolioRef.ParentDoc <> vObjectRef And 
//		  (ЗначениеЗаполнено(vFolioRef.ParentDoc.DataVersion) Or ЗначениеЗаполнено(vObjectRef.DataVersion)) Тогда
//			Continue;
//		EndIf;
//		If НЕ vFolioRef.IsMaster And НЕ vFolioRef.DeletionMark Тогда
//			vFolioObj = vFolioRef.GetObject();
//			vFolioObj.Read();
//			If ЭтоНовый() Тогда
//				vFolioObj.ДокОснование = Неопределено;
//				vFolioObj.Write(DocumentWriteMode.Write);
//			EndIf;
//			vTransCount = vFolioObj.pmGetAllFolioTransactionsCount();
//			If vTransCount = 0 Тогда
//				vFolioObj.IsClosed = True;
//				vFolioObj.Write(DocumentWriteMode.Write);
//				vFolioObj.SetDeletionMark(True);
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmDeleteUnusedChargingRuleFolios
//
////-----------------------------------------------------------------------------
//Function pmGetThisDocumentRef() Экспорт
//	vObjectRef = Ref;
//	If ЭтоНовый() Тогда
//		vObjectRef = GetNewObjectRef();
//		If НЕ ЗначениеЗаполнено(vObjectRef) Тогда
//			SetNewObjectRef(Documents.Reservation.GetRef());
//			vObjectRef = GetNewObjectRef();
//		EndIf;
//	EndIf;
//	Return vObjectRef;
//EndFunction //pmGetThisDocumentRef
//
////-----------------------------------------------------------------------------
//Процедура pmFillOccupationPercents(pPeriodFrom, pPeriodTo) Экспорт
//	// Fill occupation percents
//	vThereAreChanges = False;
//	vQry = New Query();
//	If ЗначениеЗаполнено(Тариф) And Тариф.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Тогда
//		vQry.Text = 
//		"SELECT
//		|	КалендарьДень.ТипДеньКалендарь AS DayType,
//		|	КалендарьДень.ТипДеньКалендарь.ПорядокСортировки AS DayTypeSortCode
//		|INTO CalendarDayTypes
//		|FROM
//		|	InformationRegister.КалендарьДень AS КалендарьДень
//		|WHERE
//		|	КалендарьДень.Calendar = &qCalendar
//		|	AND КалендарьДень.Period >= &qPeriodFrom
//		|	AND КалендарьДень.Period <= &qPeriodTo
//		|
//		|GROUP BY
//		|	КалендарьДень.ТипДеньКалендарь,
//		|	КалендарьДень.ТипДеньКалендарь.ПорядокСортировки
//		|;
//		|
//		|////////////////////////////////////////////////////////////////////////////////
//		|SELECT
//		|	DayTypesDays.ТипДеньКалендарь AS DayType,
//		|	MIN(DayTypesDays.Period) AS MinPeriodFrom,
//		|	MAX(DayTypesDays.Period) AS MaxPeriodTo
//		|FROM
//		|	InformationRegister.КалендарьДень AS DayTypesDays
//		|WHERE
//		|	DayTypesDays.Calendar = &qCalendar
//		|	AND DayTypesDays.Period >= &qStartPeriodFrom
//		|	AND DayTypesDays.Period <= &qEndPeriodTo
//		|	AND DayTypesDays.ТипДеньКалендарь IN
//		|			(SELECT
//		|				CalendarDayTypes.DayType
//		|			FROM
//		|				CalendarDayTypes)
//		|
//		|GROUP BY
//		|	DayTypesDays.ТипДеньКалендарь";
//		vQry.SetParameter("qCalendar", ?(ЗначениеЗаполнено(Тариф), Тариф.Calendar, Неопределено));
//		vQry.SetParameter("qStartPeriodFrom", pPeriodFrom - 24*3600*180);
//		vQry.SetParameter("qEndPeriodTo", EndOfDay(pPeriodTo) + 24*3600*180);
//		vQry.SetParameter("qPeriodFrom", pPeriodFrom);
//		vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
//		vDayTypes = vQry.Execute().Unload();
//		// Do for each day type found
//		For Each vDayTypesRow In vDayTypes Do
//			vQry.Text = 
//			"SELECT
//			|	SUM(ISNULL(PerDayType.ВсегоНомеров, 0)) AS ВсегоНомеров,
//			|	SUM(ISNULL(PerDayType.TotalRoomsBlocked, 0)) AS TotalRoomsBlocked,
//			|	SUM(ISNULL(PerDayType.ПроданоНомеров, 0)) AS ПроданоНомеров
//			|FROM
//			|	(SELECT
//			|		ВсегоНомеров.Period AS Period,
//			|		ВсегоНомеров.CounterClosingBalance AS CounterClosingBalance,
//			|		ISNULL(ВсегоНомеров.TotalRoomsClosingBalance, 0) AS ВсегоНомеров,
//			|		-ISNULL(ВсегоНомеров.RoomsBlockedClosingBalance, 0) AS TotalRoomsBlocked,
//			|		ISNULL(RoomSales.ПроданоНомеров, 0) AS ПроданоНомеров
//			|	FROM
//			|		AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//			|				&qPeriodFrom,
//			|				&qPeriodTo,
//			|				Day,
//			|				RegisterRecordsAndPeriodBoundaries,
//			|				Гостиница = &qHotel
//			|					AND ТипНомера = &qRoomType) AS ВсегоНомеров
//			|			LEFT JOIN (SELECT
//			|				ОборотыПродажиНомеров.Period AS Period,
//			|				SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров
//			|			FROM
//			|				(SELECT
//			|					RoomSales.Period AS Period,
//			|					RoomSales.RoomsRentedTurnover AS RoomsRentedTurnover
//			|				FROM
//			|					AccumulationRegister.Продажи.Turnovers(
//			|							&qPeriodFrom,
//			|							&qPeriodTo,
//			|							Day,
//			|							Гостиница = &qHotel
//			|								AND ТипНомера = &qRoomType
//			|								AND ДокОснование <> &qRef) AS RoomSales
//			|				
//			|				UNION ALL
//			|				
//			|				SELECT
//			|					RoomSalesForecast.Period,
//			|					RoomSalesForecast.RoomsRentedTurnover
//			|				FROM
//			|					AccumulationRegister.ПрогнозПродаж.Turnovers(
//			|							&qForecastPeriodFrom,
//			|							&qForecastPeriodTo,
//			|							Day,
//			|							Гостиница = &qHotel
//			|								AND ТипНомера = &qRoomType
//			|								AND ДокОснование <> &qRef) AS RoomSalesForecast) AS ОборотыПродажиНомеров
//			|			
//			|			GROUP BY
//			|				ОборотыПродажиНомеров.Period) AS RoomSales
//			|			ON ВсегоНомеров.Period = RoomSales.Period) AS PerDayType";
//			vQry.SetParameter("qHotel", Гостиница);
//			vQry.SetParameter("qRef", pmGetThisDocumentRef());
//			vQry.SetParameter("qRoomType", RoomType);
//			vQry.SetParameter("qPeriodFrom", vDayTypesRow.MinPeriodFrom);
//			vQry.SetParameter("qPeriodTo", EndOfDay(vDayTypesRow.MaxPeriodTo));
//			vQry.SetParameter("qForecastPeriodFrom", Max(vDayTypesRow.MinPeriodFrom, BegOfDay(CurrentDate())));
//			vQry.SetParameter("qForecastPeriodTo", Max(EndOfDay(vDayTypesRow.MaxPeriodTo), EndOfDay(CurrentDate()-24*3600)));
//			vStats = vQry.Execute().Unload();
//			If vStats.Count() = 1 Тогда
//				vStatsRow = vStats.Get(0);
//				vOccupationPercent = 0;
//				If vStatsRow.ВсегоНомеров <> Null And vStatsRow.TotalRoomsBlocked <> Null And vStatsRow.ПроданоНомеров <> Null And 
//				  (vStatsRow.ВсегоНомеров - vStatsRow.TotalRoomsBlocked) <> 0 Тогда
//					vOccupationPercent = Round(100*vStatsRow.ПроданоНомеров/(vStatsRow.ВсегоНомеров - vStatsRow.TotalRoomsBlocked), 2);
//				EndIf;
//				vAccountingDate = Max(vDayTypesRow.MinPeriodFrom, pPeriodFrom);
//				vMaxAccountingDate = Min(vDayTypesRow.MaxPeriodTo, pPeriodTo);
//				While vAccountingDate <= vMaxAccountingDate Do
//					vOPRow = OccupationPercents.Find(vAccountingDate, "УчетнаяДата");
//					If vOPRow = Неопределено Тогда
//						vThereAreChanges = True;
//						vOPRow = OccupationPercents.Add();
//						vOPRow.УчетнаяДата = vAccountingDate;
//						vOPRow.OccupationPercent = vOccupationPercent;
//					EndIf;
//					vAccountingDate = vAccountingDate + 24*3600;
//				EndDo;
//			EndIf;
//		EndDo;
//	ElsIf ЗначениеЗаполнено(Тариф) And Тариф.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomType Тогда
//		vQry.Text = 
//		"SELECT
//		|	ВсегоНомеров.Period AS Period,
//		|	ВсегоНомеров.CounterClosingBalance AS CounterClosingBalance,
//		|	ISNULL(ВсегоНомеров.TotalRoomsClosingBalance, 0) AS ВсегоНомеров,
//		|	-ISNULL(ВсегоНомеров.RoomsBlockedClosingBalance, 0) AS TotalRoomsBlocked,
//		|	ISNULL(RoomSales.ПроданоНомеров, 0) AS ПроданоНомеров
//		|FROM
//		|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//		|			&qPeriodFrom,
//		|			&qPeriodTo,
//		|			Day,
//		|			RegisterRecordsAndPeriodBoundaries,
//		|			Гостиница = &qHotel
//		|				AND ТипНомера = &qRoomType) AS ВсегоНомеров
//		|		LEFT JOIN (SELECT
//		|			ОборотыПродажиНомеров.Period AS Period,
//		|			SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров
//		|		FROM
//		|			(SELECT
//		|				RoomSales.Period AS Period,
//		|				RoomSales.RoomsRentedTurnover AS RoomsRentedTurnover
//		|			FROM
//		|				AccumulationRegister.Продажи.Turnovers(
//		|						&qPeriodFrom,
//		|						&qPeriodTo,
//		|						Day,
//		|						Гостиница = &qHotel
//		|							AND ТипНомера = &qRoomType
//		|							AND ДокОснование <> &qRef) AS RoomSales
//		|			
//		|			UNION ALL
//		|			
//		|			SELECT
//		|				RoomSalesForecast.Period,
//		|				RoomSalesForecast.RoomsRentedTurnover
//		|			FROM
//		|				AccumulationRegister.ПрогнозПродаж.Turnovers(
//		|						&qForecastPeriodFrom,
//		|						&qForecastPeriodTo,
//		|						Day,
//		|						Гостиница = &qHotel
//		|							AND ТипНомера = &qRoomType
//		|							AND ДокОснование <> &qRef) AS RoomSalesForecast) AS ОборотыПродажиНомеров
//		|		
//		|		GROUP BY
//		|			ОборотыПродажиНомеров.Period) AS RoomSales
//		|		ON ВсегоНомеров.Period = RoomSales.Period
//		|
//		|ORDER BY
//		|	ВсегоНомеров.Period";
//		vQry.SetParameter("qHotel", Гостиница);
//		vQry.SetParameter("qRef", pmGetThisDocumentRef());
//		vQry.SetParameter("qRoomType", ?(ЗначениеЗаполнено(RoomTypeUpgrade), RoomTypeUpgrade, RoomType));
//		vQry.SetParameter("qPeriodFrom", pPeriodFrom);
//		vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
//		vQry.SetParameter("qForecastPeriodFrom", Max(pPeriodFrom, BegOfDay(CurrentDate())));
//		vQry.SetParameter("qForecastPeriodTo", Max(EndOfDay(pPeriodTo), EndOfDay(CurrentDate()-24*3600)));
//		vDays = vQry.Execute().Unload();
//		For Each vDaysRow In vDays Do
//			vAccountingDate = BegOfDay(vDaysRow.Period);
//			vOPRow = OccupationPercents.Find(vAccountingDate, "УчетнаяДата");
//			If vOPRow = Неопределено Тогда
//				vThereAreChanges = True;
//				vOPRow = OccupationPercents.Add();
//				vOPRow.УчетнаяДата = vAccountingDate;
//				If vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked <> 0 Тогда
//					vOPRow.OccupationPercent = Round(100*vDaysRow.RoomsRented/(vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked), 2);
//				Else
//					vOPRow.OccupationPercent = 0;
//				EndIf;
//			EndIf;
//		EndDo;
//	Else
//		vQry.Text = 
//		"SELECT
//		|	ВсегоНомеров.Period AS Period,
//		|	ВсегоНомеров.CounterClosingBalance AS CounterClosingBalance,
//		|	ISNULL(ВсегоНомеров.TotalRoomsClosingBalance, 0) AS ВсегоНомеров,
//		|	ISNULL(-ВсегоНомеров.RoomsBlockedClosingBalance, 0) AS TotalRoomsBlocked,
//		|	ISNULL(RoomSales.ПроданоНомеров, 0) AS ПроданоНомеров
//		|FROM
//		|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница = &qHotel) AS ВсегоНомеров
//		|		LEFT JOIN (SELECT
//		|			ОборотыПродажиНомеров.Period AS Period,
//		|			SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров
//		|		FROM
//		|			(SELECT
//		|				RoomSales.Period AS Period,
//		|				RoomSales.RoomsRentedTurnover AS RoomsRentedTurnover
//		|			FROM
//		|				AccumulationRegister.Продажи.Turnovers(
//		|						&qPeriodFrom,
//		|						&qPeriodTo,
//		|						Day,
//		|						Гостиница = &qHotel
//		|							AND ДокОснование <> &qRef) AS RoomSales
//		|			
//		|			UNION ALL
//		|			
//		|			SELECT
//		|				RoomSalesForecast.Period,
//		|				RoomSalesForecast.RoomsRentedTurnover
//		|			FROM
//		|				AccumulationRegister.ПрогнозПродаж.Turnovers(
//		|						&qForecastPeriodFrom,
//		|						&qForecastPeriodTo,
//		|						Day,
//		|						Гостиница = &qHotel
//		|							AND ДокОснование <> &qRef) AS RoomSalesForecast) AS ОборотыПродажиНомеров
//		|		
//		|		GROUP BY
//		|			ОборотыПродажиНомеров.Period) AS RoomSales
//		|		ON ВсегоНомеров.Period = RoomSales.Period
//		|
//		|ORDER BY
//		|	ВсегоНомеров.Period";
//		vQry.SetParameter("qHotel", Гостиница);
//		vQry.SetParameter("qRef", pmGetThisDocumentRef());
//		vQry.SetParameter("qPeriodFrom", pPeriodFrom);
//		vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
//		vQry.SetParameter("qForecastPeriodFrom", Max(pPeriodFrom, BegOfDay(CurrentDate())));
//		vQry.SetParameter("qForecastPeriodTo", Max(EndOfDay(pPeriodTo), EndOfDay(CurrentDate()-24*3600)));
//		vDays = vQry.Execute().Unload();
//		For Each vDaysRow In vDays Do
//			vAccountingDate = BegOfDay(vDaysRow.Period);
//			vOPRow = OccupationPercents.Find(vAccountingDate, "УчетнаяДата");
//			If vOPRow = Неопределено Тогда
//				vThereAreChanges = True;
//				vOPRow = OccupationPercents.Add();
//				vOPRow.УчетнаяДата = vAccountingDate;
//				If vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked <> 0 Тогда
//					vOPRow.OccupationPercent = Round(100*vDaysRow.RoomsRented/(vDaysRow.TotalRooms - vDaysRow.TotalRoomsBlocked), 2);
//				Else
//					vOPRow.OccupationPercent = 0;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Resort occupation percents if there are changes
//	If vThereAreChanges Тогда
//		OccupationPercents.Sort("УчетнаяДата");
//	EndIf;
//	// Remove unused dates
//	i = 0;
//	While i < OccupationPercents.Count() Do
//		vOPRow = OccupationPercents.Get(i);
//		If vOPRow.УчетнаяДата < BegOfDay(pPeriodFrom) Or vOPRow.УчетнаяДата > BegOfDay(pPeriodTo) Тогда
//			OccupationPercents.Delete(i);
//		Else
//			i = i + 1;
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmFillOccupationPercents
//
////-----------------------------------------------------------------------------
//Процедура pmClearOccupationPercents() Экспорт
//	If ЗначениеЗаполнено(Тариф) And 
//	   (Тариф.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomType Or 
//	    Тариф.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType) Тогда
//		OccupationPercents.Clear();
//	EndIf;
//КонецПроцедуры //pmClearOccupancyPercents
//
////-----------------------------------------------------------------------------
//Процедура pmPrintConfirmation(vSpreadsheet, SelReservation, SelReservations, SelServicesFilter, SelServiceGroup, SelShowConfirmationForCurrentReservationOnly, SelLanguage, SelObjectPrintForm) Экспорт
//	// Basic checks
//	If НЕ ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		ВызватьИсключение "У документа должна быть указана гостиница";
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Some settings
//	vShowReservationNumbersInConfirmation = cmCheckUserPermissions("ShowReservationNumbersInConfirmation");
//	
//	// Fill and check grouping parameter
//	vParameter = Upper(TrimAll(SelObjectPrintForm.Parameter));
//	
//	// Choose template
//	vResObj = SelReservation.GetObject();
//	vSpreadsheet.Clear();
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = vResObj.GetTemplate("ReservationConfirmationEn");
//		ElsIf SelLanguage = Справочники.Локализация.DE Тогда
//			vTemplate = vResObj.GetTemplate("ReservationConfirmationDe");
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = vResObj.GetTemplate("ReservationConfirmationRu");
//		Else
//			ВызватьИсключение "Не найден шаблон печатной формы подтверждения бронирования для языка " + SelLanguage.Code;
//		EndIf;
//	Else
//		vTemplate = vResObj.GetTemplate("ReservationConfirmationRu");
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//		
//	// Load pictures
//	vLogoIsSet = False;
//	vLogo = New Picture;
//	If ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		If SelReservation.Гостиница.Logo <> Неопределено Тогда
//			vLogo = SelReservation.Гостиница.Logo.Get();
//			If vLogo = Неопределено Тогда
//				vLogo = New Picture;
//			Else
//				vLogoIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//
//	// Header
//	vHeader = vTemplate.GetArea("TopHeader");
//	// Гостиница
//	vHotelObj = SelReservation.Гостиница.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	mHotelPhones = TrimAll(SelReservation.Гостиница.Телефоны);
//	mHotelFax = TrimAll(SelReservation.Гостиница.Fax);
//	mHotelEMail = TrimAll(SelReservation.Гостиница.EMail);
//	// Contact person
//	mContactPersonName = TrimR(SelReservation.КонтактноеЛицо);
//	If IsBlankString(mContactPersonName) And 
//	   ЗначениеЗаполнено(SelReservation.ГруппаГостей) And ЗначениеЗаполнено(SelReservation.ГруппаГостей.Клиент) Тогда
//		mContactPersonName = TrimR(SelReservation.ГруппаГостей.Клиент);
//	EndIf;
//	// Контрагент
//	mCustomerLegacyName = "";
//	If ЗначениеЗаполнено(SelReservation.Контрагент) Тогда
//		mCustomerLegacyName = TrimAll(SelReservation.Контрагент.ЮрИмя);
//		If IsBlankString(mCustomerLegacyName) Тогда
//			mCustomerLegacyName = TrimAll(SelReservation.Контрагент.Description);
//		EndIf;
//	EndIf;
//	// Contract
//	mContractDescription = "";
//	If ЗначениеЗаполнено(SelReservation.Договор) Тогда
//		mContractDescription = TrimAll(SelReservation.Договор.Description);
//	EndIf;
//	// Fax and E-Mail
//	mFax = "";
//	mEMail = "";
//	If НЕ IsBlankString(SelReservation.Fax) Тогда
//		mFax = TrimAll(SelReservation.Fax);
//	EndIf;
//	If НЕ IsBlankString(SelReservation.EMail) Тогда
//		mEMail = TrimAll(SelReservation.EMail);
//	EndIf;
//	If ЗначениеЗаполнено(SelReservation.Контрагент) Тогда
//		If IsBlankString(mFax) Тогда
//			mFax = TrimAll(SelReservation.Контрагент.Fax);
//		EndIf;
//		If IsBlankString(mEMail) Тогда
//			mEMail = TrimAll(SelReservation.Контрагент.EMail);
//		EndIf;
//	ElsIf ЗначениеЗаполнено(SelReservation.ГруппаГостей) And ЗначениеЗаполнено(SelReservation.ГруппаГостей.Клиент) Тогда
//		If IsBlankString(mFax) Тогда
//			mFax = TrimAll(SelReservation.ГруппаГостей.Клиент.Fax);
//		EndIf;
//		If IsBlankString(mEMail) Тогда
//			mEMail = TrimAll(SelReservation.ГруппаГостей.Клиент.EMail);
//		EndIf;
//	EndIf;
//	// Confirmation header text
//	mFormHeader = "ПОДТВЕРЖДЕНИЕ БРОНИРОВАНИЯ';de='BESTÄTIGUNG DER RESERVIERUNG'";
//	mFormName = "подтверждения";
//	// Check if this reservation is in waiting list
//	IsWaitingList = False;
//	If ЗначениеЗаполнено(SelReservation) And ЗначениеЗаполнено(SelReservation.ReservationStatus) And SelReservation.ReservationStatus.IsInWaitingList Тогда
//		IsWaitingList = True;
//		mFormHeader = "ЗАЯВКА";
//		mFormName = "заявки";
//	EndIf;
//	// Document date
//	mDate = Format(SelReservation.ДатаДок, "DF='dd.MM.yyyy'");
//	// Guest group code
//	mGuestGroupCode = TrimAll(SelReservation.ГруппаГостей.Code);
//	vHotelPrefix = SelReservation.Гостиница.GetObject().pmGetPrefix();
//	If НЕ IsBlankString(vHotelPrefix) And SelReservation.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//		mGuestGroupCode = vHotelPrefix + mGuestGroupCode;
//	EndIf;
//	// Set parameters and put report section
//	vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//	vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//	vHeader.Parameters.mHotelPhones = mHotelPhones;
//	vHeader.Parameters.mHotelFax = mHotelFax;
//	vHeader.Parameters.mHotelEMail = mHotelEMail;
//	vHeader.Parameters.mContactPersonName = mContactPersonName;
//	vHeader.Parameters.mCustomerLegacyName = mCustomerLegacyName;
//	vHeader.Parameters.mContractDescription = mContractDescription;
//	vHeader.Parameters.mFax = mFax;
//	vHeader.Parameters.mEMail = mEMail;
//	vHeader.Parameters.mFormHeader = mFormHeader;
//	vHeader.Parameters.mFormName = mFormName;
//	vHeader.Parameters.mDate = mDate;
//	vHeader.Parameters.mGuestGroupCode = mGuestGroupCode;
//	// Logo
//	If vLogoIsSet Тогда
//		vHeader.Drawings.Logo.Print = True;
//		vHeader.Drawings.Logo.Picture = vLogo;
//	Else
//		vHeader.Drawings.Delete(vHeader.Drawings.Logo);
//	EndIf;
//	// Put top header		
//	vSpreadsheet.Put(vHeader);
//	
//	// Put Фирма data if necessary
//	If ЗначениеЗаполнено(SelReservation.Фирма) And SelReservation.Гостиница.PrintCompanyDataInReservationConfirmation Тогда
//		vCompanyHeader = vTemplate.GetArea("CompanyHeader");
//		vCompany = SelReservation.Фирма;
//		vCompanyObj = vCompany.GetObject();
//		vCompanyTIN = TrimAll(vCompany.ИНН);
//		vCompanyKPP = TrimAll(vCompany.KPP);
//		vCompanyHeader.Parameters.mTIN = "ИНН " + vCompanyTIN + ?(IsBlankString(vCompanyKPP), "", "/" + vCompanyKPP);
//		vAccount = SelReservation.Фирма.BankAccount;
//		vCompanyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//		vCompanyBankAccount = "";
//		If vAccount.IsDirectPayments Тогда
//			vCompanyBankAccount = "Р/С " + TrimAll(vAccount.НомерСчета);
//			vCompanyBankAccount = vCompanyBankAccount + " в " + TrimAll(TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка));
//			If НЕ IsBlankString(vAccount.КорСчет) Тогда
//				vCompanyBankAccount = vCompanyBankAccount + " К/С " + TrimAll(vAccount.КорСчет);
//			EndIf;
//			If НЕ IsBlankString(vAccount.БИКБанка) Тогда
//				vCompanyBankAccount = vCompanyBankAccount + ", БИК '" + TrimAll(vAccount.БИКБанка);
//			EndIf;
//		Else
//			vCompanyName = vCompanyName + ", Р/С " + TrimAll(vAccount.НомерСчета);
//			vCompanyName = vCompanyName +" в " + TrimAll(TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка));
//			If НЕ IsBlankString(vAccount.КорСчет) Тогда
//				vCompanyName = vCompanyName + ", К/С " + TrimAll(vAccount.КорСчет);
//			EndIf;
//			If НЕ IsBlankString(vAccount.БИКБанка) Тогда
//				vCompanyName = vCompanyName + ", БИК '" + TrimAll(vAccount.БИКБанка);
//			EndIf;
//			vCompanyBankAccount = "Р/С " + TrimAll(vAccount.CorrBankCorrAccountNumber);
//			vCompanyBankAccount = vCompanyBankAccount + " в " + TrimAll(TrimAll(vAccount.CorrBankName) + " " + TrimAll(vAccount.CorrBankCity));
//		EndIf;
//		If НЕ IsBlankString(vAccount.BankSWIFTCode) Тогда
//			vCompanyBankAccount = vCompanyBankAccount + Chars.LF + " SWIFT " + TrimAll(vAccount.BankSWIFTCode);
//		EndIf;
//		vCompanyHeader.Parameters.mCompanyName = vCompanyName;
//		vCompanyHeader.Parameters.mLegalAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//		vCompanyHeader.Parameters.mBankAccount = vCompanyBankAccount;
//		// Put Фирма header
//		vSpreadsheet.Put(vCompanyHeader);
//	EndIf;
//	
//	// Put bottom header		
//	vBottomHeader = vTemplate.GetArea("BottomHeader");
//	vBottomHeader.Parameters.mGuestGroupDescription = "";
//	If ЗначениеЗаполнено(SelReservation.ГруппаГостей) Тогда
//		vBottomHeader.Parameters.mGuestGroupDescription = TrimR(SelReservation.ГруппаГостей.Description);
//	EndIf;
//	vSpreadsheet.Put(vBottomHeader);
//	
//	// Get reservation currency
//	vCurrency = SelReservation.Гостиница.BaseCurrency;
//	For Each vSrvRow In SelReservation.Услуги Do
//		If vSrvRow.IsRoomRevenue Тогда
//			vCurrency = vSrvRow.ВалютаЛицСчета;
//			Break;
//		EndIf;
//	EndDo;
//	
//	// Total per guest group
//	vTotalSum = 0;
//	vTotalNumberOfPersons = 0;
//	vTotalNumberOfRooms = 0;
//	vTotalSumToBePayed = 0;
//	vTotalCommissionSum = 0;
//	vTotalVATCommissionSum = 0;
//	
//	// Guests in group
//	vGuestRowArea = vTemplate.GetArea("GuestRow");
//	If vShowReservationNumbersInConfirmation Тогда
//		vGuestRowArea = vTemplate.GetArea("GuestRowN");
//	EndIf;
//	vSrvRowArea = vTemplate.GetArea("SrvRow");
//	vAddSrvRowArea = vTemplate.GetArea("AddSrvRow");
//	vRowArea = vTemplate.GetArea("Row");
//	vReservations = SelReservation.ГруппаГостей.GetObject().pmGetReservations(True, ?(IsWaitingList, False, True), False, IsWaitingList, ?(SelShowConfirmationForCurrentReservationOnly, SelReservation, Неопределено), ?(SelShowConfirmationForCurrentReservationOnly, Неопределено, ?(SelReservations = Неопределено, Неопределено, ?(SelReservations.Count() > 1, SelReservations, Неопределено))));
//	vSplittedReserv = vReservations.Copy();
//	vSplittedReserv.Clear();
//	vSplittedReserv.Columns.Add("Количество", cmGetNumberTypeDescription(19, 7));
//	vSplittedReserv.Columns.Add("Amount", cmGetSumTypeDescription());
//	vSplittedReserv.Columns.Add("Валюта", cmGetCatalogTypeDescription("Валюты"));
//	vSplittedReserv.Columns.Add("Услуга", cmGetCatalogTypeDescription("Услуги"));
//	vSplittedReserv.Columns.Add("Услуги");
//	For Each vRes In vReservations Do
//		If ЗначениеЗаполнено(vRes.Status) And 
//		   (НЕ IsWaitingList And (vRes.Status.IsActive Or vRes.Status.ЭтоЗаезд Or vRes.Status.IsPreliminary) Or IsWaitingList) Тогда
//			vCurRes = vRes.Reservation;
//			vCurResObj = vCurRes.GetObject();
//			// Fill parameters
//			vGuestRowArea.Parameters.mGuestName = cmGetFullPersonName(vCurRes.Клиент);
//			If vShowReservationNumbersInConfirmation Тогда
//				vGuestRowArea.Parameters.mDocNumber = "Бронь №:" + cmGetDocumentNumberPresentation(vCurRes.НомерДока);
//			EndIf;
//			vSpreadsheet.Put(vGuestRowArea);
//			// Get reservation periods
//			vAccPeriods = vCurResObj.pmGetAccommodationPeriods();
//			// Group by current reservation services
//			If Find(vParameter, "JOIN_IN_PRICE_SERVICES_TO_MAIN_ROOM_GUEST") > 0 And vCurRes.RoomQuantity = 1 And ЗначениеЗаполнено(vCurRes.ВидРазмещения) And 
//			  (vCurRes.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения Or vCurRes.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.Together Or vCurRes.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.AdditionalBed) Тогда
//				vServices = cmGetReservationRoomServices(vCurRes);
//			Else
//				vServices = cmGetReservationServices(vCurRes);
//			EndIf;
//			// Filter services by Контрагент
//			If SelServicesFilter > 0 Тогда
//				i = 0;
//				While i < vServices.Count() Do
//					vSrvRow = vServices.Get(i);
//					If SelServicesFilter = 1 Тогда
//						If ЗначениеЗаполнено(vSrvRow.СчетПроживания.Контрагент) Тогда
//							vServices.Delete(i);
//							Continue;
//						EndIf;
//					ElsIf SelServicesFilter = 2 Тогда
//						If НЕ ЗначениеЗаполнено(vSrvRow.СчетПроживания.Контрагент) Тогда
//							vServices.Delete(i);
//							Continue;
//						EndIf;
//					EndIf;
//					i = i + 1;
//				EndDo;
//			EndIf;
//			// Filter services by service group
//			If ЗначениеЗаполнено(SelServiceGroup) Тогда
//				i = 0;
//				While i < vServices.Count() Do
//					vSrvRow = vServices.Get(i);
//					If НЕ cmIsServiceInServiceGroup(vSrvRow.Услуга, SelServiceGroup) Тогда
//						vServices.Delete(i);
//						Continue;
//					EndIf;
//					i = i + 1;
//				EndDo;
//			EndIf;
//			// Fill commission totals
//			vTotalCommissionSum = vTotalCommissionSum + vServices.Total("СуммаКомиссии");
//			vTotalVATCommissionSum = vTotalVATCommissionSum + vServices.Total("VATCommissionSum");
//			// Process services grouping parameters
//			If Find(vParameter, "DETAILED") = 0 Тогда
//				// Find accommodation service
//				vAccommodationService = Неопределено;	
//				For Each vSrvRow In vServices Do
//					If vSrvRow.IsRoomRevenue And НЕ vSrvRow.RoomRevenueAmountsOnly Тогда
//						vAccommodationService = vSrvRow.Услуга;
//						Break;
//					EndIf;
//				EndDo;
//				// Change accounting dates for breakfast
//				If Find(vParameter, "DETAILED") = 0 Тогда
//					For Each vSrvRow In vServices Do
//						If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.QuantityCalculationRule) And
//						   vSrvRow.Услуга.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//							If BegOfDay(vSrvRow.УчетнаяДата) > BegOfDay(vCurRes.CheckInDate) Тогда
//								vSrvRow.УчетнаяДата = vSrvRow.УчетнаяДата - 24*3600;
//							EndIf;
//						EndIf;
//					EndDo;
//				EndIf;
//				// Join services according to service parameters
//				If Find(vParameter, "DETAILED") = 0 Тогда
//					i = 0;
//					While i < vServices.Count() Do
//						vSrvRow = vServices.Get(i);
//						If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//							// Try to find service to hide current one to
//							vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, ВалютаЛицСчета", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.ВалютаЛицСчета));
//							If vHideToServices.Count() = 1 Тогда
//								vSrv2Hide2 = vHideToServices.Get(0);
//								vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//								vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
//								vSrv2Hide2.СуммаСкидки = vSrv2Hide2.СуммаСкидки + vSrvRow.СуммаСкидки;
//								vSrv2Hide2.НДСскидка = vSrv2Hide2.НДСскидка + vSrvRow.НДСскидка;
//								vSrv2Hide2.СуммаКомиссии = vSrv2Hide2.СуммаКомиссии + vSrvRow.СуммаКомиссии;
//								vSrv2Hide2.СуммаКомиссииНДС = vSrv2Hide2.СуммаКомиссииНДС + vSrvRow.СуммаКомиссииНДС;
//								vSrv2Hide2.Цена = cmRecalculatePrice(vSrv2Hide2.Сумма, vSrv2Hide2.Количество);
//								// Delete current service
//								vServices.Delete(i);
//								Continue;
//							EndIf;
//						EndIf;
//						i = i + 1;
//					EndDo;
//				EndIf;
//				// Change services
//				For Each vSrvRow In vServices Do
//					If Find(vParameter, "ALL") > 0 Тогда
//						If НЕ vSrvRow.IsRoomRevenue Or vSrvRow.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//							vSrvRow.Количество = ?(ЗначениеЗаполнено(vAccommodationService), 0, vSrvRow.Количество);
//							vSrvRow.Цена = 0;
//						EndIf;
//					Else
//						// Reset "is in price" flag if necessary
//						If Find(vParameter, "DETAILED") = 0 Тогда
//							If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.DoNotGroupIntoRoomRateOnPrint Тогда
//								vSrvRow.IsInPrice = False;
//							EndIf;
//							If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//								vSrvRow.IsRoomRevenue = True;
//								vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//								vSrvRow.Количество = ?(ЗначениеЗаполнено(vAccommodationService), 0, vSrvRow.Количество);
//								vSrvRow.Цена = 0;
//							ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//								If vSrvRow.RoomRevenueAmountsOnly Тогда
//									vSrvRow.Количество = 0;
//								EndIf;
//								vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//								vSrvRow.Цена = 0;
//								If vSrvRow.ЭтоРазделение Тогда
//									vSrvRow.Количество = 0;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndDo;
//				// Group by services
//				If Find(vParameter, "DETAILED") = 0 Тогда
//					vServices.GroupBy("УчетнаяДата, Услуга, ВалютаЛицСчета, IsRoomRevenue, RoomRevenueAmountsOnly, IsInPrice", "Сумма, СуммаНДС, СуммаСкидки, НДСскидка, Количество, Цена, ЗаездГостей, ЧеловекаДни, СуммаКомиссии, VATCommissionSum");
//				EndIf;
//				vServices.GroupBy("УчетнаяДата, Услуга, Цена, ВалютаЛицСчета, IsRoomRevenue, RoomRevenueAmountsOnly, IsInPrice", "Сумма, СуммаНДС, СуммаСкидки, НДСскидка, Количество, ЗаездГостей, ЧеловекаДни, СуммаКомиссии, VATCommissionSum");
//				// Recalculate price and sum for all services
//				For Each vSrvRow In vServices Do
//					vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//				EndDo;
//			EndIf;
//			// Split reservation period
//			vSplittedReserv.Clear();
//			vSRRow = vSplittedReserv.Add();
//			FillPropertyValues(vSRRow, vRes);
//			vAccPrice = Неопределено;
//			vSavCheckOutDate = Неопределено;
//			For Each vSrvRow In vServices Do
//				If ЗначениеЗаполнено(vSrvRow.Услуга) And 
//				   vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice And НЕ vSrvRow.RoomRevenueAmountsOnly Тогда
//					For Each vAccPeriodsRow In vAccPeriods Do
//						If ЗначениеЗаполнено(vSrvRow.УчетнаяДата) And vAccPeriodsRow.CheckInDate <= vSrvRow.УчетнаяДата And vAccPeriodsRow.ДатаВыезда > vSrvRow.УчетнаяДата Тогда
//							vSRRow.НомерРазмещения = vAccPeriodsRow.НомерРазмещения;
//							vSRRow.ТипНомера = vAccPeriodsRow.ТипНомера;
//							vSRRow.Тариф = vAccPeriodsRow.Тариф;
//							vSRRow.ВидРазмещения = vAccPeriodsRow.ВидРазмещения;
//							Break;
//						EndIf;
//					EndDo;
//					If vAccPrice = Неопределено Тогда
//					   vAccPrice = vSrvRow.Цена;
//					Else
//						If vAccPrice <> vSrvRow.Цена Тогда
//							vAccPrice = vSrvRow.Цена;
//							vSavCheckOutDate = vSRRow.ДатаВыезда;
//							If ЗначениеЗаполнено(vCurRes.Тариф) And vCurRes.Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
//								vSRRow.ДатаВыезда = BegOfDay(vSrvRow.УчетнаяДата) + (vCurRes.Тариф.ReferenceHour - BegOfDay(vCurRes.Тариф.ReferenceHour));
//							Else
//								vSRRow.ДатаВыезда = BegOfDay(vSrvRow.УчетнаяДата) + (vSRRow.ДатаВыезда - BegOfDay(vSRRow.ДатаВыезда));
//							EndIf;
//							vSRRow.Продолжительность = cmCalculateDuration(vCurRes.Тариф, vSRRow.CheckInDate, vSRRow.ДатаВыезда);
//							vNewSRRow = vSplittedReserv.Add();
//							FillPropertyValues(vNewSRRow, vSRRow);
//							vNewSRRow.CheckInDate = vSRRow.ДатаВыезда;
//							vNewSRRow.ДатаВыезда = vSavCheckOutDate;
//							vNewSRRow.Продолжительность = cmCalculateDuration(vCurRes.Тариф, vNewSRRow.CheckInDate, vNewSRRow.ДатаВыезда);
//							vNewSRRow.RoomQuantity = 0;
//							vNewSRRow.КоличествоЧеловек = 0;
//							vNewSRRow.Количество = 0;
//							vNewSRRow.Amount = 0;
//							vNewSRRow.Валюта = Справочники.Валюты.EmptyRef();
//							vNewSRRow.Услуга = Справочники.Услуги.EmptyRef();
//							vNewSRRow.Услуги = Неопределено;
//							vSRRow = vNewSRRow;
//						EndIf;
//					EndIf;
//				EndIf;
//				If vSRRow.Услуги = Неопределено Тогда
//					vSRRow.Услуги = vServices.Copy();
//					vSRRow.Услуги.Clear();
//				EndIf;
//				If Find(vParameter, "DETAILED") = 0 Тогда
//					If vSrvRow.IsInPrice Тогда
//						vSRRow.Amount = vSRRow.Amount + vSrvRow.Сумма - vSrvRow.СуммаСкидки;
//					ElsIf Find(vParameter, "ALL") > 0 Тогда
//						vSRRow.Amount = vSRRow.Amount + vSrvRow.Сумма - vSrvRow.СуммаСкидки;
//					EndIf;
//				Else
//					If vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice And НЕ vSrvRow.RoomRevenueAmountsOnly Тогда
//						vSRRow.Amount = vSRRow.Amount + vSrvRow.Сумма - vSrvRow.СуммаСкидки;
//					EndIf;
//				EndIf;
//				If vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice And НЕ vSrvRow.RoomRevenueAmountsOnly Тогда
//					vSRRow.Количество = vSRRow.Количество + vSrvRow.Количество;
//					vSRRow.Валюта = vSrvRow.ВалютаЛицСчета;
//					vSRRow.Услуга = vSrvRow.Услуга;
//				Else
//					If vSrvRow.Сумма <> 0 Тогда
//						vSRRowServicesRow = vSRRow.Услуги.Add();
//						FillPropertyValues(vSRRowServicesRow, vSrvRow);
//					EndIf;
//				EndIf;					
//			EndDo;
//			// Print periods in cycle
//			vCurService = Неопределено;
//			For Each vSRRow In vSplittedReserv Do
//				If ЗначениеЗаполнено(vSRRow.Услуга) And vCurService <> vSRRow.Услуга Тогда
//					vCurService = vSRRow.Услуга;
//					vSrvRowArea.Parameters.mServiceDescription = vSRRow.Услуга.GetObject().pmGetServiceDescription(SelLanguage);
//					If vSRRow.CheckInDate = vSRRow.ДатаВыезда And vSRRow.Amount = 0 Тогда
//						Continue;
//					EndIf;
//					// Put service row
//					vSpreadsheet.Put(vSrvRowArea);
//				EndIf;
//				If ЗначениеЗаполнено(vSRRow.Тариф) And vSRRow.Тариф.PeriodInHours = 24 And  
//				   vSRRow.Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour And 
//				   ((vSRRow.Тариф.DefaultCheckInTime - BegOfDay(vSRRow.Тариф.DefaultCheckInTime)) = (cm0SecondShift(vSRRow.CheckInDate) - BegOfDay(vSRRow.CheckInDate)) 
//				    Or НЕ ЗначениеЗаполнено(vSRRow.Тариф.DefaultCheckInTime) 
//					Or (vSRRow.Тариф.ReferenceHour - BegOfDay(vSRRow.Тариф.ReferenceHour)) = (cm0SecondShift(vSRRow.CheckInDate) - BegOfDay(vSRRow.CheckInDate))) And 
//				   (vSRRow.Тариф.ReferenceHour - BegOfDay(vSRRow.Тариф.ReferenceHour)) = (cm0SecondShift(vSRRow.ДатаВыезда) - BegOfDay(vSRRow.ДатаВыезда)) Тогда
//					vRowArea.Parameters.mPeriod = Format(vSRRow.CheckInDate, "DF='dd.MM.yy'") + " - " +
//					                          Format(vSRRow.ДатаВыезда, "DF='dd.MM.yy'");
//				Else
//					vRowArea.Parameters.mPeriod = Format(vSRRow.CheckInDate, "DF='dd.MM.yy HH:mm'") + " - " +
//					                          Format(vSRRow.ДатаВыезда, "DF='dd.MM.yy HH:mm'");
//				EndIf;
//				If ЗначениеЗаполнено(vSRRow.ВидРазмещения) Тогда
//					If vSRRow.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.Beds Тогда
//						If vSRRow.КоличествоМестНомер <> 0 Тогда
//							vNumberOfRooms = vSRRow.КоличествоМест/vSRRow.КоличествоМестНомер;
//							If vNumberOfRooms = 1 Тогда
//								vRowArea.Parameters.mQuantity = "1";
//							ElsIf vNumberOfRooms = 1/2 Тогда
//								vRowArea.Parameters.mQuantity = "1/2";
//							ElsIf vNumberOfRooms = 1/3 Тогда 
//								vRowArea.Parameters.mQuantity = "1/3";
//							ElsIf vNumberOfRooms = 1/4 Тогда 
//								vRowArea.Parameters.mQuantity = "1/4";
//							ElsIf vNumberOfRooms = 1/5 Тогда 
//								vRowArea.Parameters.mQuantity = "1/5";
//							ElsIf vNumberOfRooms = 1/6 Тогда 
//								vRowArea.Parameters.mQuantity = "1/6";
//							ElsIf vNumberOfRooms = 1/7 Тогда 
//								vRowArea.Parameters.mQuantity = "1/7";
//							ElsIf vNumberOfRooms = 1/8 Тогда 
//								vRowArea.Parameters.mQuantity = "1/8";
//							ElsIf vNumberOfRooms = 1/9 Тогда 
//								vRowArea.Parameters.mQuantity = "1/9";
//							Else
//								vRowArea.Parameters.mQuantity = Format(vNumberOfRooms, "ND=6; NFD=3");
//							EndIf;
//							vTotalNumberOfRooms = vTotalNumberOfRooms + vNumberOfRooms;
//						Else
//							vRowArea.Parameters.mQuantity = "";
//						EndIf;
//					ElsIf vSRRow.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения Тогда
//						vRowArea.Parameters.mQuantity = Format(vSRRow.RoomQuantity, "ND=6");
//						vTotalNumberOfRooms = vTotalNumberOfRooms + vSRRow.RoomQuantity;
//					Else
//						vRowArea.Parameters.mQuantity = "";
//					EndIf;
//				Else
//					vRowArea.Parameters.mQuantity = "";
//				EndIf;
//				vRowArea.Parameters.mNumberOfPersons = Format(vSRRow.КоличествоЧеловек, "ND=6");
//				vTotalNumberOfPersons = vTotalNumberOfPersons + vSRRow.КоличествоЧеловек;
//				vRoomTypeToPrint = vSRRow.ТипНомера;
//				If ЗначениеЗаполнено(vRoomTypeToPrint) And ЗначениеЗаполнено(vCurRes.ТипНомераРасчет) And vCurRes.ТипНомераРасчет.BaseRoomType = vRoomTypeToPrint Тогда
//					vRoomTypeToPrint = vCurRes.ТипНомераРасчет;
//				EndIf;
//				If ЗначениеЗаполнено(vSRRow.НомерРазмещения) And Find(vParameter, "NO_ROOM") = 0 Тогда
//					vRowArea.Parameters.mRoomType = TrimAll(vSRRow.НомерРазмещения.Description) + ?(ЗначениеЗаполнено(vRoomTypeToPrint), " - " + vRoomTypeToPrint.GetObject().pmGetRoomTypeDescription(SelLanguage), "");
//				Else
//					vRowArea.Parameters.mRoomType = ?(ЗначениеЗаполнено(vRoomTypeToPrint), vRoomTypeToPrint.GetObject().pmGetRoomTypeDescription(SelLanguage), "");
//				EndIf;
//				If ЗначениеЗаполнено(vSRRow.ВидРазмещения) Тогда
//					vRowArea.Parameters.mRoomType = vRowArea.Parameters.mRoomType + ", " + vSRRow.ВидРазмещения.GetObject().pmGetAccommodationTypeDescription(SelLanguage);
//				EndIf;
//				// Get accommodation prices for all day types of ГруппаНомеров rate
//				If vSRRow.Количество = 0 Тогда
//					mRoomRate = cmFormatSum(vSRRow.Amount, vSRRow.Валюта);
//				Else
//					mRoomRate = cmFormatSum(Round(vSRRow.Amount/vSRRow.Количество, 2), vSRRow.Валюта);
//				EndIf;
//				vRowArea.Parameters.mRoomRate = mRoomRate;
//				// Number of days
//				vRowArea.Parameters.mDays = Format(vSRRow.Продолжительность, "ND=6");
//				// Amount
//				vRowArea.Parameters.mAmount = cmFormatSum(vSRRow.Amount, vSRRow.Валюта);
//				// Fill totals
//				vTotalSum = vTotalSum + vSRRow.Amount;
//
//				// Put row
//				vSpreadsheet.Put(vRowArea);
//			EndDo;
//			// Put other services
//			For Each vSRRow In vSplittedReserv Do
//				If vSRRow.Услуги <> Неопределено Тогда
//					For Each vSRRowServicesRow In vSRRow.Услуги Do
//						If ЗначениеЗаполнено(vSRRowServicesRow.Услуга) And vSRRowServicesRow.Услуга <> vSRRow.Услуга Тогда
//							vAddSrvRowArea.Parameters.mServiceDescription = vSRRowServicesRow.Услуга.GetObject().pmGetServiceDescription(SelLanguage) + " - " + Format(vSRRowServicesRow.УчетнаяДата, "DF='dd.MM.yy'");
//							// Try to add remarks and resource
//							vServicesRows = vCurResObj.Услуги.FindRows(New Structure("УчетнаяДата, Услуга, ВалютаЛицСчета, IsRoomRevenue, RoomRevenueAmountsOnly, IsInPrice", vSRRowServicesRow.УчетнаяДата, vSRRowServicesRow.Услуга, vSRRowServicesRow.ВалютаЛицСчета, vSRRowServicesRow.IsRoomRevenue, vSRRowServicesRow.RoomRevenueAmountsOnly, vSRRowServicesRow.IsInPrice));
//							If vServicesRows.Count() = 1 Тогда
//								vServicesRow = vServicesRows.Get(0);
//								If ЗначениеЗаполнено(vServicesRow.ServiceResource) And ЗначениеЗаполнено(vServicesRow.ВремяС) And ЗначениеЗаполнено(vServicesRow.ВремяПо) Тогда
//									vAddSrvRowArea.Parameters.mServiceDescription = vAddSrvRowArea.Parameters.mServiceDescription + Chars.LF + Chars.Tab + 
//									TrimAll(?(TypeOf(vServicesRow.ServiceResource) = Type("String"), TrimAll(vServicesRow.ServiceResource), vServicesRow.ServiceResource.GetObject().pmGetResourceDescription(SelLanguage)) + " " + 
//									Format(vServicesRow.ВремяС, "DF=HH:mm") + " - " + Format(vServicesRow.ВремяПо, "DF=HH:mm") + Chars.LF + Chars.Tab + Chars.Tab + 
//									StrReplace(TrimAll(vServicesRow.Примечания), Chars.LF, Chars.LF + Chars.Tab + Chars.Tab));
//								EndIf;
//							EndIf;
//							// Amount
//							vAddSrvRowArea.Parameters.mAmount = cmFormatSum(vSRRowServicesRow.Сумма - vSRRowServicesRow.СуммаСкидки, vSRRowServicesRow.ВалютаЛицСчета);
//							// Fill totals
//							vTotalSum = vTotalSum + vSRRowServicesRow.Сумма - vSRRowServicesRow.СуммаСкидки;
//							// Put service row
//							vSpreadsheet.Put(vAddSrvRowArea);
//						EndIf;
//					EndDo;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndDo;
//	
//	// Create table of charging rules
//	vChargingRules = SelReservation.ChargingRules.Unload();
//	cmAddGuestGroupChargingRules(vChargingRules, SelReservation.ГруппаГостей);
//	
//	// Put group totals
//	If SelReservation.Контрагент = SelReservation.Агент And ЗначениеЗаполнено(SelReservation.Агент) And vTotalCommissionSum <> 0 And 
//	   cmCustomerIsPayer(vChargingRules, SelReservation.Контрагент, SelReservation.Договор, SelReservation.ГруппаГостей) Тогда
//		vTotalsRow = vTemplate.GetArea("TotalsRowCommission");
//		vTotalsRow.Parameters.mTotalNumberOfPersons = Format(vTotalNumberOfPersons, "ND=6");
//		vTotalsRow.Parameters.mTotalQuantity = Format(vTotalNumberOfRooms, "ND=6");
//		vTotalsRow.Parameters.mTotalAmount = cmFormatSum(vTotalSum, vCurrency);
//		vTotalsRow.Parameters.mAgentCommission = SelReservation.КомиссияАгента;
//		vTotalsRow.Parameters.mTotalCommissionSum = cmFormatSum(vTotalCommissionSum, vCurrency);
//		vTotalsRow.Parameters.mSumToBePaid = cmFormatSum(vTotalSum - vTotalCommissionSum, vCurrency);
//		vSpreadsheet.Put(vTotalsRow);
//	Else
//		vTotalsRow = vTemplate.GetArea("TotalsRow");
//		vTotalsRow.Parameters.mTotalNumberOfPersons = Format(vTotalNumberOfPersons, "ND=6");
//		vTotalsRow.Parameters.mTotalQuantity = Format(vTotalNumberOfRooms, "ND=6");
//		vTotalsRow.Parameters.mTotalAmount = cmFormatSum(vTotalSum, vCurrency);
//		vSpreadsheet.Put(vTotalsRow);
//	EndIf;
//	
//	// Confirmation reply
//	vConfRepl = vTemplate.GetArea("ConfirmationReply");
//	vConfirmationReply = "<Способ оплаты не установлен!>";
//	If vChargingRules.Count() > 0 Тогда
//		// Get first charging rule and if it is not for the owner, then get the last one
//		vCRRow = vChargingRules.Get(0);
//		If НЕ ЗначениеЗаполнено(vCRRow.Owner) Тогда
//			vCRRow = vChargingRules.Get(vChargingRules.Count()-1);
//		EndIf;
//		If ЗначениеЗаполнено(vCRRow.СпособРазделенияОплаты) And ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//			If ЗначениеЗаполнено(vCRRow.ChargingFolio.СпособОплаты) Тогда
//				vPaymentMethodObj = vCRRow.ChargingFolio.СпособОплаты.GetObject();
//				If vCRRow.СпособРазделенияОплаты <> Перечисления.ChargingRuleTypes.Any Тогда
//					vConfirmationReply = vPaymentMethodObj.pmGetPaymentMethodDescription(SelLanguage) + " - " + TrimAll(vCRRow.СпособРазделенияОплаты);
//				Else
//					vConfirmationReply = vPaymentMethodObj.pmGetPaymentMethodDescription(SelLanguage);
//				EndIf;
//				If НЕ SelShowConfirmationForCurrentReservationOnly Тогда
//					vGroupPayments = SelReservation.ГруппаГостей.GetObject().pmGetPaymentsTotals();
//					For Each vGroupPaymentsRow In vGroupPayments Do
//						If vGroupPayments.IndexOf(vGroupPaymentsRow) = 0 Тогда
//							vConfirmationReply = vConfirmationReply + Chars.LF + "'Платежи";
//						EndIf;
//						vConfirmationReply = vConfirmationReply + Chars.LF + Format(vGroupPaymentsRow.УчетнаяДата, "DF=dd.MM.yyyy") + " - " + cmFormatSum(vGroupPaymentsRow.Сумма, vGroupPaymentsRow.Валюта);
//					EndDo;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If Find(vParameter, "SHOW_AGENT_COMMISSION_PERCENT") > 0 Тогда
//		If ЗначениеЗаполнено(SelReservation.ВидКомиссииАгента) And SelReservation.КомиссияАгента > 0 Тогда
//			vConfirmationReply = vConfirmationReply + Chars.Tab + Chars.Tab + Chars.Tab + Chars.Tab + "Агентское вознаграждение " + SelReservation.КомиссияАгента + "%";
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(SelReservation.ГруппаГостей) And НЕ IsBlankString(SelReservation.ГруппаГостей.Примечания) Тогда
//		If НЕ IsBlankString(vConfirmationReply) Тогда
//			vConfirmationReply = vConfirmationReply + Chars.LF + Chars.LF + TrimAll(SelReservation.ГруппаГостей.Примечания);
//		Else
//			vConfirmationReply = TrimAll(SelReservation.ГруппаГостей.Примечания);
//		EndIf;
//	EndIf;
//	If НЕ IsBlankString(SelReservation.ConfirmationReply) Тогда
//		If НЕ IsBlankString(vConfirmationReply) Тогда
//			vConfirmationReply = vConfirmationReply + Chars.LF + Chars.LF + TrimAll(SelReservation.ConfirmationReply);
//		Else
//			vConfirmationReply = TrimAll(SelReservation.ConfirmationReply);
//		EndIf;
//	EndIf;
//	vConfRepl.Parameters.mConfirmationReply = vConfirmationReply;
//	vSpreadsheet.Put(vConfRepl);
//	
//	// Footer
//	vFooter = vTemplate.GetArea("Footer");
//	If ЗначениеЗаполнено(SelReservation.Фирма) And SelReservation.Фирма.DoNotPrintVAT Тогда
//		vFooter.Parameters.mVATPresentation = "";
//	Else
//		vFooter.Parameters.mVATPresentation = "* В цену входит НДС";
//		If ЗначениеЗаполнено(SelReservation) Тогда
//			If ЗначениеЗаполнено(SelReservation.Фирма) Тогда
//				If ЗначениеЗаполнено(SelReservation.Фирма.СтавкаНДС) Тогда
//					If SelReservation.Фирма.СтавкаНДС.Ставка = 0 Or
//					   SelReservation.Фирма.СтавкаНДС.БезНДС Тогда
//						vFooter.Parameters.mVATPresentation = "* Без НДС";
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ IsWaitingList Тогда
//		If ЗначениеЗаполнено(SelReservation.Тариф) And НЕ IsBlankString(SelReservation.Тариф.ReservationConditions) Тогда
//			vFooter.Parameters.mReservationConditions = SelReservation.Тариф.ReservationConditions;
//		ElsIf НЕ IsBlankString(SelReservation.Гостиница.ReservationConditions) Тогда
//			vFooter.Parameters.mReservationConditions = SelReservation.Гостиница.ReservationConditions;
//		Else
//			vFooter.Parameters.mReservationConditions ="ru='* Для аннулирования брони известите нас до 18:00 дня предшествующего дате заезда
//			|
//			|* Возможность поселения ранее указанного времени должна быть согласована с отделом бронирования";
//		EndIf;
//		If ЗначениеЗаполнено(SelReservation.ReservationStatus) And НЕ IsBlankString(SelReservation.ReservationStatus.ReservationConditions) Тогда
//			vFooter.Parameters.mReservationConditions = vFooter.Parameters.mReservationConditions + Chars.LF + SelReservation.ReservationStatus.ReservationConditions;
//		EndIf;
//	Else
//		vFooter.Parameters.mReservationConditions = "* Эта форма НЕ ЯВЛЯЕТСЯ подтверждением брони. 
//		|
//		|* Эта форма ЯВЛЯЕТСЯ уведомлением, что ваша заявка на бронирование зарегистрирована и по возможности МОЖЕТ быть удовлетворена позднее.
//		|
//		|* В случае удовлетворения заявки Вам будет распечатана и отправлена отдельная форма подтверждения брони.";
//	EndIf;
//	vFooter.Parameters.mReservationConditions = StrReplace(vFooter.Parameters.mReservationConditions, "\n", "");
//	vFooter.Parameters.mReservationDivisionContacts = vHotelObj.pmGetHotelReservationDivisionContacts(SelLanguage);
//	vFooter.Parameters.mAuthor = ?(ЗначениеЗаполнено(SelReservation.Автор), SelReservation.Автор.GetObject().pmGetEmployeeDescription(SelLanguage), "");
//	vNumOfEmptyLines = 0;
//	vEmptyRow = vTemplate.GetArea("EmptyRow");
//	vFooterArray = New Array();
//	vFooterArray.Add(vFooter);
//	Try
//		While vSpreadsheet.CheckPut(vFooterArray) Do
//			vFooterArray.Вставить(0, vEmptyRow);
//			vNumOfEmptyLines = vNumOfEmptyLines + 1;
//		EndDo;
//	Except
//	EndTry;
//	If vNumOfEmptyLines > 0 Тогда
//		vFooterArray.Delete(0);
//	EndIf;
//	For Each vArea In vFooterArray Do
//		vSpreadsheet.Put(vArea);
//	EndDo;
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintConfirmation
//
////-----------------------------------------------------------------------------
//Процедура pmPrintConfirmationWithServices(vSpreadsheet, SelReservation, SelReservations, SelServicesFilter, SelServiceGroup, SelShowConfirmationForCurrentReservationOnly, SelLanguage, SelObjectPrintForm) Экспорт
//	// Basic checks
//	If НЕ ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		ВызватьИсключение "У документа должна быть указана гостиница!";
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Some settings
//	vShowReservationNumbersInConfirmation = cmCheckUserPermissions("ShowReservationNumbersInConfirmation");
//	
//	// Fill and check grouping parameter
//	vParameter = UPPER(TrimAll(SelObjectPrintForm.Parameter));
//	
//	// Choose template
//	vResObj = SelReservation.GetObject();
//	vSpreadsheet.Clear();
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = vResObj.GetTemplate("ReservationConfirmationWithServicesRu");
//		Else
//			ВызватьИсключение "Не найден шаблон печатной формы подтверждения бронирования для языка " + SelLanguage.Code  ;
//		EndIf;
//	Else
//		vTemplate = vResObj.GetTemplate("ReservationConfirmationWithServicesRu");
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Load pictures
//	vLogoIsSet = False;
//	vLogo = New Picture;
//	If ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		If SelReservation.Гостиница.Logo <> Неопределено Тогда
//			vLogo = SelReservation.Гостиница.Logo.Get();
//			If vLogo = Неопределено Тогда
//				vLogo = New Picture;
//			Else
//				vLogoIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Header top
//	vHeader = vTemplate.GetArea("TopHeader");
//	// Гостиница
//	vHotelObj = SelReservation.Гостиница.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	mHotelPhones = TrimAll(SelReservation.Гостиница.Телефоны);
//	mHotelFax = TrimAll(SelReservation.Гостиница.Fax);
//	mHotelEMail = TrimAll(SelReservation.Гостиница.EMail);
//	// Contact person
//	mContactPersonName = TrimR(SelReservation.КонтактноеЛицо);
//	If IsBlankString(mContactPersonName) And 
//	   ЗначениеЗаполнено(SelReservation.ГруппаГостей) And ЗначениеЗаполнено(SelReservation.ГруппаГостей.Клиент) Тогда
//		mContactPersonName = TrimR(SelReservation.ГруппаГостей.Клиент);
//	EndIf;
//	// Контрагент
//	mCustomerLegacyName = "";
//	If ЗначениеЗаполнено(SelReservation.Контрагент) Тогда
//		mCustomerLegacyName = TrimAll(SelReservation.Контрагент.ЮрИмя);
//		If IsBlankString(mCustomerLegacyName) Тогда
//			mCustomerLegacyName = TrimAll(SelReservation.Контрагент.Description);
//		EndIf;
//	EndIf;
//	// Contract
//	mContractDescription = "";
//	If ЗначениеЗаполнено(SelReservation.Договор) Тогда
//		mContractDescription = TrimAll(SelReservation.Договор.Description);
//	EndIf;
//	// Fax and E-Mail
//	mFax = "";
//	mEMail = "";
//	If НЕ IsBlankString(SelReservation.Fax) Тогда
//		mFax = TrimAll(SelReservation.Fax);
//	EndIf;
//	If НЕ IsBlankString(SelReservation.EMail) Тогда
//		mEMail = TrimAll(SelReservation.EMail);
//	EndIf;
//	If ЗначениеЗаполнено(SelReservation.Контрагент) Тогда
//		If IsBlankString(mFax) Тогда
//			mFax = TrimAll(SelReservation.Контрагент.Fax);
//		EndIf;
//		If IsBlankString(mEMail) Тогда
//			mEMail = TrimAll(SelReservation.Контрагент.EMail);
//		EndIf;
//	ElsIf ЗначениеЗаполнено(SelReservation.ГруппаГостей) And ЗначениеЗаполнено(SelReservation.ГруппаГостей.Клиент) Тогда
//		If IsBlankString(mFax) Тогда
//			mFax = TrimAll(SelReservation.ГруппаГостей.Клиент.Fax);
//		EndIf;
//		If IsBlankString(mEMail) Тогда
//			mEMail = TrimAll(SelReservation.ГруппаГостей.Клиент.EMail);
//		EndIf;
//	EndIf;
//	// Confirmation header text
//	mFormHeader = "ПОДТВЕРЖДЕНИЕ БРОНИРОВАНИЯ";
//	mFormName = "подтверждения";
//	// Check if this reservation is in waiting list
//	IsWaitingList = False;
//	If ЗначениеЗаполнено(SelReservation) And ЗначениеЗаполнено(SelReservation.ReservationStatus) And SelReservation.ReservationStatus.IsInWaitingList Тогда
//		IsWaitingList = True;
//		mFormHeader = "ЗАЯВКА";
//		mFormName = "заявки";
//	EndIf;		
//	// Document date
//	mDate = Format(SelReservation.ДатаДок, "DF='dd.MM.yyyy'");
//	// Guest group code
//	mGuestGroupCode = TrimAll(SelReservation.ГруппаГостей.Code);
//	vHotelPrefix = SelReservation.Гостиница.GetObject().pmGetPrefix();
//	If НЕ IsBlankString(vHotelPrefix) And SelReservation.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//		mGuestGroupCode = vHotelPrefix + mGuestGroupCode;
//	EndIf;
//	// Set parameters and put report section
//	vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//	vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//	vHeader.Parameters.mHotelPhones = mHotelPhones;
//	vHeader.Parameters.mHotelFax = mHotelFax;
//	vHeader.Parameters.mHotelEMail = mHotelEMail;
//	vHeader.Parameters.mContactPersonName = mContactPersonName;
//	vHeader.Parameters.mCustomerLegacyName = mCustomerLegacyName;
//	vHeader.Parameters.mContractDescription = mContractDescription;
//	vHeader.Parameters.mFax = mFax;
//	vHeader.Parameters.mEMail = mEMail;
//	vHeader.Parameters.mFormHeader = mFormHeader;
//	vHeader.Parameters.mFormName = mFormName;
//	vHeader.Parameters.mDate = mDate;
//	vHeader.Parameters.mGuestGroupCode = mGuestGroupCode;
//	// Logo
//	If vLogoIsSet Тогда
//		vHeader.Drawings.Logo.Print = True;
//		vHeader.Drawings.Logo.Picture = vLogo;
//	Else
//		vHeader.Drawings.Delete(vHeader.Drawings.Logo);
//	EndIf;
//	// Put header		
//	vSpreadsheet.Put(vHeader);
//	
//	// Put Фирма data if necessary
//	If ЗначениеЗаполнено(SelReservation.Фирма) And SelReservation.Гостиница.PrintCompanyDataInReservationConfirmation Тогда
//		vCompanyHeader = vTemplate.GetArea("CompanyHeader");
//		vCompany = SelReservation.Фирма;
//		vCompanyObj = vCompany.GetObject();
//		vCompanyTIN = TrimAll(vCompany.ИНН);
//		vCompanyKPP = TrimAll(vCompany.KPP);
//		vCompanyHeader.Parameters.mTIN = "ИНН " + vCompanyTIN + ?(IsBlankString(vCompanyKPP), "", "/" + vCompanyKPP);
//		vAccount = SelReservation.Фирма.BankAccount;
//		vCompanyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//		vCompanyBankAccount = "";
//		If vAccount.IsDirectPayments Тогда
//			vCompanyBankAccount = "Р/С " + TrimAll(vAccount.НомерСчета);
//			vCompanyBankAccount = vCompanyBankAccount + " в " + TrimAll(TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка));
//			If НЕ IsBlankString(vAccount.КорСчет) Тогда
//				vCompanyBankAccount = vCompanyBankAccount + ", К/С '" + TrimAll(vAccount.КорСчет);
//			EndIf;
//			If НЕ IsBlankString(vAccount.БИКБанка) Тогда
//				vCompanyBankAccount = vCompanyBankAccount + ", БИК '" + TrimAll(vAccount.БИКБанка);
//			EndIf;
//		Else
//			vCompanyName = vCompanyName + ", Р/С '" + TrimAll(vAccount.НомерСчета);
//			vCompanyName = vCompanyName + " в " + TrimAll(TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка));
//			If НЕ IsBlankString(vAccount.КорСчет) Тогда
//				vCompanyName = vCompanyName + " К/С '" + TrimAll(vAccount.КорСчет);
//			EndIf;
//			If НЕ IsBlankString(vAccount.БИКБанка) Тогда
//				vCompanyName = vCompanyName + " БИК '" + TrimAll(vAccount.БИКБанка);
//			EndIf;
//			vCompanyBankAccount = "Р/С " + TrimAll(vAccount.CorrBankCorrAccountNumber);
//			vCompanyBankAccount = vCompanyBankAccount + " в " + TrimAll(TrimAll(vAccount.CorrBankName) + " " + TrimAll(vAccount.CorrBankCity));
//		EndIf;
//		If НЕ IsBlankString(vAccount.BankSWIFTCode) Тогда
//			vCompanyBankAccount = vCompanyBankAccount + Chars.LF +" SWIFT " + TrimAll(vAccount.BankSWIFTCode);
//		EndIf;
//		vCompanyHeader.Parameters.mCompanyName = vCompanyName;
//		vCompanyHeader.Parameters.mLegalAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//		vCompanyHeader.Parameters.mBankAccount = vCompanyBankAccount;
//		// Put Фирма header
//		vSpreadsheet.Put(vCompanyHeader);
//	EndIf;
//	
//	// Header bottom
//	vBottomHeader = vTemplate.GetArea("BottomHeader");
//	vBottomHeader.Parameters.mGuestGroupDescription = "";
//	If ЗначениеЗаполнено(SelReservation.ГруппаГостей) Тогда
//		vBottomHeader.Parameters.mGuestGroupDescription = TrimR(SelReservation.ГруппаГостей.Description);
//	EndIf;
//	vSpreadsheet.Put(vBottomHeader);
//	
//	// Table rows
//	vClient = vTemplate.GetArea("Клиент");
//	vRow = vTemplate.GetArea("Row");
//	vTableFooter = vTemplate.GetArea("TableFooter");
//	
//	// Build table of all guest group services
//	vServices = Неопределено;
//	vReservations = SelReservation.ГруппаГостей.GetObject().pmGetReservations(True, ?(IsWaitingList, False, True), False, IsWaitingList, ?(SelShowConfirmationForCurrentReservationOnly, SelReservation, Неопределено), ?(SelShowConfirmationForCurrentReservationOnly, Неопределено, ?(SelReservations = Неопределено, Неопределено, ?(SelReservations.Count() > 1, SelReservations, Неопределено))));
//	For Each vRes In vReservations Do
//		If ЗначениеЗаполнено(vRes.Status) And 
//		   (НЕ IsWaitingList And (vRes.Status.IsActive Or vRes.Status.ЭтоЗаезд Or vRes.Status.IsPreliminary) Or IsWaitingList) Тогда
//			vCurRes = vRes.Reservation;
//			If vServices = Неопределено Тогда
//				vServices = vCurRes.Услуги.Unload();
//				vServices.Clear();
//				vServices.Columns.Add("Reservation");
//				vServices.Columns.Add("Клиент");
//				vServices.Columns.Add("DateTimeFrom");
//				vServices.Columns.Add("DateTimeTo");
//			EndIf;
//			vCurResServices = cmGetReservationServices(vCurRes);
//			// Join services according to service parameters
//			If Find(vParameter, "DETAILED") = 0 Тогда
//				i = 0;
//				While i < vCurResServices.Count() Do
//					vSrvRow = vCurResServices.Get(i);
//					If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//						// Try to find service to hide current one to
//						vHideToServices = vCurResServices.FindRows(New Structure("Услуга, УчетнаяДата, ВалютаЛицСчета", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.ВалютаЛицСчета));
//						If vHideToServices.Count() = 1 Тогда
//							vSrv2Hide2 = vHideToServices.Get(0);
//							vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//							vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
//							vSrv2Hide2.СуммаСкидки = vSrv2Hide2.СуммаСкидки + vSrvRow.СуммаСкидки;
//							vSrv2Hide2.НДСскидка = vSrv2Hide2.НДСскидка + vSrvRow.НДСскидка;
//							vSrv2Hide2.СуммаКомиссии = vSrv2Hide2.СуммаКомиссии + vSrvRow.СуммаКомиссии;
//							vSrv2Hide2.СуммаКомиссииНДС = vSrv2Hide2.СуммаКомиссииНДС + vSrvRow.СуммаКомиссииНДС;
//							vSrv2Hide2.Цена = cmRecalculatePrice(vSrv2Hide2.Сумма, vSrv2Hide2.Количество);
//							// Delete current service
//							vCurResServices.Delete(i);
//							Continue;
//						EndIf;
//					EndIf;
//					i = i + 1;
//				EndDo;
//			EndIf;
//			// Filter services by Контрагент
//			If SelServicesFilter > 0 Тогда
//				i = 0;
//				While i < vCurResServices.Count() Do
//					vResSrvRow = vCurResServices.Get(i);
//					If SelServicesFilter = 1 Тогда
//						If ЗначениеЗаполнено(vResSrvRow.СчетПроживания.Контрагент) Тогда
//							vCurResServices.Delete(i);
//							Continue;
//						EndIf;
//					ElsIf SelServicesFilter = 2 Тогда
//						If НЕ ЗначениеЗаполнено(vResSrvRow.СчетПроживания.Контрагент) Тогда
//							vCurResServices.Delete(i);
//							Continue;
//						EndIf;
//					EndIf;
//					i = i + 1;
//				EndDo;
//			EndIf;
//			// Filter services by service group
//			If ЗначениеЗаполнено(SelServiceGroup) Тогда
//				i = 0;
//				While i < vCurResServices.Count() Do
//					vResSrvRow = vCurResServices.Get(i);
//					If НЕ cmIsServiceInServiceGroup(vResSrvRow.Услуга, SelServiceGroup) Тогда
//						vCurResServices.Delete(i);
//						Continue;
//					EndIf;
//					i = i + 1;
//				EndDo;
//			EndIf;
//			// Add current reservation services to the one value table of services
//			For Each vResSrvRow In vCurResServices Do
//				If Find(vParameter, "HIDE_ZERO_CLIENTS") > 0 Тогда
//					If vResSrvRow.Сумма = 0 Тогда
//						Continue;
//					EndIf;
//				EndIf;
//				vSrvRow = vServices.Add();
//				FillPropertyValues(vSrvRow, vResSrvRow);
//				vSrvRow.Клиент = vCurRes.Клиент;
//				vRoomTypeToPrint = vCurRes.ТипНомера;
//				If ЗначениеЗаполнено(vRoomTypeToPrint) And ЗначениеЗаполнено(vCurRes.ТипНомераРасчет) And vCurRes.ТипНомераРасчет.BaseRoomType = vRoomTypeToPrint Тогда
//					vRoomTypeToPrint = vCurRes.ТипНомераРасчет;
//				EndIf;
//				vSrvRow.ТипНомера = vRoomTypeToPrint;
//				If НЕ ЗначениеЗаполнено(vSrvRow.ВидРазмещения) Тогда
//					vSrvRow.ВидРазмещения = vCurRes.ВидРазмещения;
//				EndIf;
//				vSrvRow.DateTimeFrom = vCurRes.CheckInDate;
//				vSrvRow.DateTimeTo = vCurRes.ДатаВыезда;
//				vSrvRow.Reservation = vCurRes;
//			EndDo;
//		EndIf;
//	EndDo;
//	
//	// Get accommodation service name
//	vAccommodationService = Неопределено;	
//	If vServices <> Неопределено Тогда
//		For Each vSrvRow In vServices Do
//			If vSrvRow.IsRoomRevenue And НЕ vSrvRow.RoomRevenueAmountsOnly Тогда
//				vAccommodationService = vSrvRow.Услуга;
//				Break;
//			EndIf;
//		EndDo;
//		
//		// Print services
//		vTotalSum = 0;
//		vTotalVATSum = 0;
//		vTotalQuantity = 0;
//		vTotalNumberOfPersons = 0;
//		vTotalCommissionSum = vServices.Total("СуммаКомиссии");
//		vTotalVATCommissionSum = vServices.Total("VATCommissionSum");
//		
//		// Group by services by the accommodation conditions
//		vConditions = vServices.Copy();
//		i = 0;
//		While i < vConditions.Count() Do
//			vCndRow = vConditions.Get(0);
//			If НЕ vCndRow.IsRoomRevenue Тогда
//				vConditions.Delete(i);
//			Else
//				i = i + 1;
//			EndIf;
//		EndDo;
//		vConditions.GroupBy("ВидРазмещения, ТипНомера, DateTimeFrom, DateTimeTo", );
//		For Each vConditionsRow In vConditions Do
//			// Select services for the each condition
//			vRowsArray = vServices.FindRows(New Structure("ВидРазмещения, ТипНомера, DateTimeFrom, DateTimeTo", 
//			                                vConditionsRow.ВидРазмещения, vConditionsRow.ТипНомера, 
//			                                vConditionsRow.DateTimeFrom, vConditionsRow.DateTimeTo));
//			vCndServices = vServices.CopyColumns();
//			For Each vRowElement In vRowsArray Do
//				vCndServicesRow = vCndServices.Add();
//				FillPropertyValues(vCndServicesRow, vRowElement);
//			EndDo;
//			
//			vGuests = vCndServices.Copy();
//			vGuests.GroupBy("Reservation, Клиент", );
//			vGuests.Sort("Клиент");
//			vGuestNames = "";
//			For Each vGuestsRow In vGuests Do
//				If ЗначениеЗаполнено(vGuestsRow.Клиент) Тогда
//					If IsBlankString(vGuestNames) Тогда
//						If vGuests.Count() > 1 Тогда
//							vGuestNames = Chars.LF;
//						EndIf;
//						vGuestNames = vGuestNames + TrimAll(TrimAll(vGuestsRow.Клиент) + ?(vShowReservationNumbersInConfirmation," №'" + cmGetDocumentNumberPresentation(vGuestsRow.Reservation.НомерДока), ""));
//					Else
//						vGuestNames = vGuestNames + ", " + TrimAll(TrimAll(vGuestsRow.Клиент) + ?(vShowReservationNumbersInConfirmation," №'" + cmGetDocumentNumberPresentation(vGuestsRow.Reservation.НомерДока), ""));
//					EndIf;
//				EndIf;
//			EndDo;
//		
//			// Group sevices by accommodation by default
//			If Find(vParameter, "DETAILED") = 0 Тогда
//				For Each vSrvRow In vCndServices Do
//					If Find(vParameter, "ALL") > 0 Тогда
//						If НЕ vSrvRow.IsRoomRevenue Or vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//							vSrvRow.Количество = ?(ЗначениеЗаполнено(vAccommodationService), 0, vSrvRow.Количество);
//							vSrvRow.Цена = 0;
//						EndIf;
//					Else
//						// Reset "is in price" flag if necessary
//						If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.DoNotGroupIntoRoomRateOnPrint Тогда
//							vSrvRow.IsInPrice = False;
//						EndIf;
//						If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//							vSrvRow.Количество = ?(ЗначениеЗаполнено(vAccommodationService), 0, vSrvRow.Количество);
//							vSrvRow.Цена = 0;
//						ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//							vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//							vSrvRow.Цена = 0;
//							If vSrvRow.ЭтоРазделение Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndDo;
//			EndIf;
//			If Find(vParameter, "DETAILED") = 0 Тогда
//				vCndServices.GroupBy("Услуга", "Сумма, СуммаНДС, СуммаСкидки, НДСскидка, Количество, ЗаездГостей, ЧеловекаДни, Цена");
//			EndIf;
//			vCndServices.GroupBy("Услуга, Цена", "Сумма, СуммаНДС, СуммаСкидки, НДСскидка, Количество, ЗаездГостей, ЧеловекаДни");
//			// Recalculate price and sum for all services
//			For Each vSrvRow In vCndServices Do
//				vSrvRow.Сумма = vSrvRow.Сумма - vSrvRow.СуммаСкидки;
//				vSrvRow.СуммаНДС = vSrvRow.СуммаНДС - vSrvRow.НДСскидка;
//				vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//			EndDo;
//		
//			// Print condition header
//			vDateTimeFrom = Format(vConditionsRow.DateTimeFrom, "DF='dd.MM.yy HH:mm'");
//			vDateTimeTo = Format(vConditionsRow.DateTimeTo, "DF='dd.MM.yy HH:mm'");
//			vRoomType = "";
//			If ЗначениеЗаполнено(vConditionsRow.ТипНомера) Тогда
//				vRoomType = vConditionsRow.ТипНомера.GetObject().pmGetRoomTypeDescription(SelLanguage);
//			EndIf;
//			mCondition = ?(ЗначениеЗаполнено(vConditionsRow.DateTimeFrom), vDateTimeFrom + " - " + vDateTimeTo, "") + 
//					     ?(IsBlankString(vRoomType), "" , ", " + vRoomType) + 
//			             ?(IsBlankString(vGuestNames), "", ", " + vGuestNames);
//						 
//			// Set client area parameters
//			vClient.Parameters.mClient = mCondition;
//			// Put client area
//			vSpreadsheet.Put(vClient);
//			For Each vSrvRow In vCndServices Do
//				// Fill row parameters
//				mPrice = vSrvRow.Цена;
//				mSum = vSrvRow.Сумма;
//				mQuantity = ?(vSrvRow.Количество=0, "", vSrvRow.Количество);
//				If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//					If vSrvRow.Количество <> 0 Тогда
//						vServiceObj = vSrvRow.Услуга.GetObject();
//						If vSrvRow.ЗаездГостей <> 0 Тогда
//							vDuration = vSrvRow.ЧеловекаДни/vSrvRow.ЗаездГостей;
//							If vDuration <> 0 And vSrvRow.Количество > vDuration Тогда 
//								vQuantity = Round(vSrvRow.Количество/vDuration, 0);
//								mQuantity = ?(vQuantity = 0, "", Format(vQuantity, "ND=10; NFD=0; NG=") + "*" + vServiceObj.pmGetServiceQuantityPresentation(vDuration, SelLanguage));
//							Else
//								mQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Количество, SelLanguage);
//							EndIf;
//						Else
//							mQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Количество, SelLanguage);
//						EndIf;
//					EndIf;
//				EndIf;
//				mNumberOfPersons = vSrvRow.ЗаездГостей;
//				mDescription = Chars.Tab + ?(ЗначениеЗаполнено(vSrvRow.Услуга), vSrvRow.Услуга.GetObject().pmGetServiceDescription(SelLanguage), TrimAll(vSrvRow.Услуга));
//				
//				vTotalSum = vTotalSum + vSrvRow.Сумма;
//				vTotalVATSum = vTotalVATSum + vSrvRow.СуммаНДС;
//				If vSrvRow.Услуга = vAccommodationService Тогда
//					vTotalQuantity = vTotalQuantity + vSrvRow.Количество;
//					vTotalNumberOfPersons = vTotalNumberOfPersons + vSrvRow.ЗаездГостей;
//				EndIf;
//				
//				vRow.Parameters.mPrice = Format(mPrice, "ND=17; NFD=2");
//				vRow.Parameters.mQuantity = mQuantity;
//				vRow.Parameters.mNumberOfPersons = Format(mNumberOfPersons, "ND=8, NFD=0");
//				vRow.Parameters.mDescription = mDescription;
//				vRow.Parameters.mSum = Format(mSum, "ND=17; NFD=2");
//				
//				// Put row
//				If НЕ IsBlankString(mSum) Or НЕ IsBlankString(mNumberOfPersons) Тогда
//					vSpreadsheet.Put(vRow);
//				EndIf;
//			EndDo;
//		EndDo;
//	EndIf;
//	
//	// Create table of charging rules
//	vChargingRules = SelReservation.ChargingRules.Unload();
//	cmAddGuestGroupChargingRules(vChargingRules, SelReservation.ГруппаГостей);
//	
//	// Fill footer parameters
//	mTotalSum = Format(vTotalSum, "ND=17; NFD=2");
//	mTotalQuantity = Format(vTotalQuantity, "ND=17; NFD=0");
//	mTotalNumberOfPersons = Format(vTotalNumberOfPersons, "ND=17; NFD=0");
//	If ЗначениеЗаполнено(vAccommodationService) Тогда
//		If vTotalQuantity <> 0 Тогда
//			vServiceObj = vAccommodationService.GetObject();
//			mTotalQuantity = vServiceObj.pmGetServiceQuantityPresentation(vTotalQuantity, SelLanguage);
//		EndIf;
//	EndIf;
//	// Set parameters
//	If SelReservation.Контрагент = SelReservation.Агент And ЗначениеЗаполнено(SelReservation.Агент) And vTotalCommissionSum <> 0 And 
//	   cmCustomerIsPayer(vChargingRules, SelReservation.Контрагент, SelReservation.Договор, SelReservation.ГруппаГостей) Тогда
//		vTblFooter = vTemplate.GetArea("TableFooterCommission");
//		vTblFooter.Parameters.mTotalSum = mTotalSum;
//		vTblFooter.Parameters.mTotalQuantity = ""; //mTotalQuantity -- commented to avoid client misunderstanding;
//		vTblFooter.Parameters.mTotalNumberOfPersons = mTotalNumberOfPersons;
//		vTblFooter.Parameters.mAgentCommission = SelReservation.КомиссияАгента;
//		vTblFooter.Parameters.mTotalCommissionSum = Format(vTotalCommissionSum, "ND=17; NFD=2");
//		vTblFooter.Parameters.mSumToBePaid = Format(vTotalSum - vTotalCommissionSum, "ND=17; NFD=2");
//	Else
//		vTblFooter = vTemplate.GetArea("TableFooter");
//		vTblFooter.Parameters.mTotalSum = mTotalSum;
//		vTblFooter.Parameters.mTotalQuantity = ""; //mTotalQuantity -- commented to avoid client misunderstanding;
//		vTblFooter.Parameters.mTotalNumberOfPersons = mTotalNumberOfPersons;
//	EndIf;
//	// Put table footer
//	vSpreadsheet.Put(vTblFooter);
//	
//	// Confirmation reply
//	vConfRepl = vTemplate.GetArea("ConfirmationReply");
//	vConfirmationReply = "<Способ оплаты не установлен!>";
//	If vChargingRules.Count() > 0 Тогда
//		// Get first charging rule and if it is not for the owner, then get the last one
//		vCRRow = vChargingRules.Get(0);
//		If НЕ ЗначениеЗаполнено(vCRRow.Owner) Тогда
//			vCRRow = vChargingRules.Get(vChargingRules.Count()-1);
//		EndIf;
//		If ЗначениеЗаполнено(vCRRow.СпособРазделенияОплаты) And ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
//			If ЗначениеЗаполнено(vCRRow.ChargingFolio.СпособОплаты) Тогда
//				vPaymentMethodObj = vCRRow.ChargingFolio.СпособОплаты.GetObject();
//				If vCRRow.СпособРазделенияОплаты <> Перечисления.ChargingRuleTypes.Any Тогда
//					vConfirmationReply = vPaymentMethodObj.pmGetPaymentMethodDescription(SelLanguage) + " - " + TrimAll(vCRRow.СпособРазделенияОплаты);
//				Else
//					vConfirmationReply = vPaymentMethodObj.pmGetPaymentMethodDescription(SelLanguage);
//				EndIf;
//				If НЕ SelShowConfirmationForCurrentReservationOnly Тогда
//					vGroupPayments = SelReservation.ГруппаГостей.GetObject().pmGetPaymentsTotals();
//					For Each vGroupPaymentsRow In vGroupPayments Do
//						If vGroupPayments.IndexOf(vGroupPaymentsRow) = 0 Тогда
//							vConfirmationReply = vConfirmationReply + Chars.LF + "Платежи'";
//						EndIf;
//						vConfirmationReply = vConfirmationReply + Chars.LF + Format(vGroupPaymentsRow.УчетнаяДата, "DF=dd.MM.yyyy") + " - " + cmFormatSum(vGroupPaymentsRow.Сумма, vGroupPaymentsRow.Валюта);
//					EndDo;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If Find(vParameter, "SHOW_AGENT_COMMISSION_PERCENT") > 0 Тогда
//		If ЗначениеЗаполнено(SelReservation.ВидКомиссииАгента) And SelReservation.КомиссияАгента > 0 Тогда
//			vConfirmationReply = vConfirmationReply + Chars.Tab + Chars.Tab + Chars.Tab + Chars.Tab + "Агентское вознаграждение " + SelReservation.КомиссияАгента + "%";
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(SelReservation.ГруппаГостей) And НЕ IsBlankString(SelReservation.ГруппаГостей.Примечания) Тогда
//		If НЕ IsBlankString(vConfirmationReply) Тогда
//			vConfirmationReply = vConfirmationReply + Chars.LF + Chars.LF + TrimAll(SelReservation.ГруппаГостей.Примечания);
//		Else
//			vConfirmationReply = TrimAll(SelReservation.ГруппаГостей.Примечания);
//		EndIf;
//	EndIf;
//	If НЕ IsBlankString(SelReservation.ConfirmationReply) Тогда
//		If НЕ IsBlankString(vConfirmationReply) Тогда
//			vConfirmationReply = vConfirmationReply + Chars.LF + Chars.LF + TrimAll(SelReservation.ConfirmationReply);
//		Else
//			vConfirmationReply = TrimAll(SelReservation.ConfirmationReply);
//		EndIf;
//	EndIf;
//	vConfRepl.Parameters.mConfirmationReply = vConfirmationReply;
//	vSpreadsheet.Put(vConfRepl);
//	
//	// Footer
//	vFooter = vTemplate.GetArea("Footer");
//	If ЗначениеЗаполнено(SelReservation.Фирма) And SelReservation.Фирма.DoNotPrintVAT Тогда
//		vFooter.Parameters.mVATPresentation = "";
//	Else
//		vFooter.Parameters.mVATPresentation = "* В цену входит НДС";
//		If ЗначениеЗаполнено(SelReservation) Тогда
//			If ЗначениеЗаполнено(SelReservation.Фирма) Тогда
//				If ЗначениеЗаполнено(SelReservation.Фирма.СтавкаНДС) Тогда
//					If SelReservation.Фирма.СтавкаНДС.Ставка = 0 Or
//					   SelReservation.Фирма.СтавкаНДС.БезНДС Тогда
//						vFooter.Parameters.mVATPresentation = "* Без НДС";
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ IsWaitingList Тогда
//		If ЗначениеЗаполнено(SelReservation.Тариф) And НЕ IsBlankString(SelReservation.Тариф.ReservationConditions) Тогда
//			vFooter.Parameters.mReservationConditions = SelReservation.Тариф.ReservationConditions;
//		ElsIf НЕ IsBlankString(SelReservation.Гостиница.ReservationConditions) Тогда
//			vFooter.Parameters.mReservationConditions = SelReservation.Гостиница.ReservationConditions;
//		Else
//			vFooter.Parameters.mReservationConditions = "ru='* Для аннулирования брони известите нас до 18:00 дня предшествующего дате заезда
//			|* Возможность поселения ранее указанного времени должна быть согласована с отделом бронирования';  ";
//		EndIf;
//		If ЗначениеЗаполнено(SelReservation.ReservationStatus) And НЕ IsBlankString(SelReservation.ReservationStatus.ReservationConditions) Тогда
//			vFooter.Parameters.mReservationConditions = vFooter.Parameters.mReservationConditions + Chars.LF + SelReservation.ReservationStatus.ReservationConditions;
//		EndIf;
//	Else
//		vFooter.Parameters.mReservationConditions ="* Эта форма НЕ ЯВЛЯЕТСЯ подтверждением брони. 
//		|
//		|* Эта форма ЯВЛЯЕТСЯ уведомлением, что ваша заявка на бронирование зарегистрирована и по возможности МОЖЕТ быть удовлетворена позднее.
//		|
//		|* В случае удовлетворения заявки Вам будет распечатана и отправлена отдельная форма подтверждения брони.';";
//	EndIf;
//	vFooter.Parameters.mReservationConditions = StrReplace(vFooter.Parameters.mReservationConditions, "\n", "");
//	vFooter.Parameters.mReservationDivisionContacts = vHotelObj.pmGetHotelReservationDivisionContacts(SelLanguage);
//	vFooter.Parameters.mAuthor = ?(ЗначениеЗаполнено(SelReservation.Автор), SelReservation.Автор.GetObject().pmGetEmployeeDescription(SelLanguage), "");
//	
//	vNumOfEmptyLines = 0;
//	vEmptyRow = vTemplate.GetArea("EmptyRow");
//	vFooterArray = New Array();
//	vFooterArray.Add(vFooter);
//	Try
//		While vSpreadsheet.CheckPut(vFooterArray) Do
//			vFooterArray.Вставить(0, vEmptyRow);
//			vNumOfEmptyLines = vNumOfEmptyLines + 1;
//		EndDo;
//	Except
//	EndTry;
//	If vNumOfEmptyLines > 0 Тогда
//		vFooterArray.Delete(0);
//	EndIf;
//	For Each vArea In vFooterArray Do
//		vSpreadsheet.Put(vArea);
//	EndDo;
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintConfirmationWithServices
//
////-----------------------------------------------------------------------------
//Процедура pmPrintCancellation(vSpreadsheet, SelReservation, SelReservations, SelShowCancellationForCurrentReservationOnly, SelLanguage, SelObjectPrintForm) Экспорт
//	// Basic checks
//	If НЕ ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		ВызватьИсключение "У документа должна быть указана гостиница!";
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Choose template
//	vResObj = SelReservation.GetObject();
//	vSpreadsheet.Clear();
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = vResObj.GetTemplate("ReservationCancellationEn");
//		ElsIf SelLanguage = Справочники.Локализация.DE Тогда
//			vTemplate = vResObj.GetTemplate("ReservationCancellationDe");
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = vResObj.GetTemplate("ReservationCancellationRu");
//		Else
//			ВызватьИсключение "Не найден шаблон печатной формы аннуляции бронирования для языка " + SelLanguage.Code;
//		EndIf;
//	Else
//		vTemplate = vResObj.GetTemplate("ReservationCancellationRu");
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//		
//	// Load pictures
//	vLogoIsSet = False;
//	vLogo = New Picture;
//	If ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		If SelReservation.Гостиница.Logo <> Неопределено Тогда
//			vLogo = SelReservation.Гостиница.Logo.Get();
//			If vLogo = Неопределено Тогда
//				vLogo = New Picture;
//			Else
//				vLogoIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//
//	// Header
//	vHeader = vTemplate.GetArea("Header");
//	// Гостиница
//	vHotelObj = SelReservation.Гостиница.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	mHotelPhones = TrimAll(SelReservation.Гостиница.Телефоны);
//	mHotelFax = TrimAll(SelReservation.Гостиница.Fax);
//	mHotelEMail = TrimAll(SelReservation.Гостиница.EMail);
//	// Contact person
//	mContactPersonName = TrimR(SelReservation.КонтактноеЛицо);
//	If IsBlankString(mContactPersonName) And 
//	   ЗначениеЗаполнено(SelReservation.ГруппаГостей) And ЗначениеЗаполнено(SelReservation.ГруппаГостей.Клиент) Тогда
//		mContactPersonName = TrimR(SelReservation.ГруппаГостей.Клиент);
//	EndIf;
//	// Контрагент
//	mCustomerLegacyName = "";
//	If ЗначениеЗаполнено(SelReservation.Контрагент) Тогда
//		mCustomerLegacyName = TrimAll(SelReservation.Контрагент.ЮрИмя);
//		If IsBlankString(mCustomerLegacyName) Тогда
//			mCustomerLegacyName = TrimAll(SelReservation.Контрагент.Description);
//		EndIf;
//	EndIf;
//	// Contract
//	mContractDescription = "";
//	If ЗначениеЗаполнено(SelReservation.Договор) Тогда
//		mContractDescription = TrimAll(SelReservation.Договор.Description);
//	EndIf;
//	// Fax and E-Mail
//	mFax = "";
//	mEMail = "";
//	If НЕ IsBlankString(SelReservation.Fax) Тогда
//		mFax = TrimAll(SelReservation.Fax);
//	EndIf;
//	If НЕ IsBlankString(SelReservation.EMail) Тогда
//		mEMail = TrimAll(SelReservation.EMail);
//	EndIf;
//	If ЗначениеЗаполнено(SelReservation.Контрагент) Тогда
//		If IsBlankString(mFax) Тогда
//			mFax = TrimAll(SelReservation.Контрагент.Fax);
//		EndIf;
//		If IsBlankString(mEMail) Тогда
//			mEMail = TrimAll(SelReservation.Контрагент.EMail);
//		EndIf;
//	ElsIf ЗначениеЗаполнено(SelReservation.ГруппаГостей) And ЗначениеЗаполнено(SelReservation.ГруппаГостей.Клиент) Тогда
//		If IsBlankString(mFax) Тогда
//			mFax = TrimAll(SelReservation.ГруппаГостей.Клиент.Fax);
//		EndIf;
//		If IsBlankString(mEMail) Тогда
//			mEMail = TrimAll(SelReservation.ГруппаГостей.Клиент.EMail);
//		EndIf;
//	EndIf;
//	// Document date
//	mDate = Format(SelReservation.ДатаДок, "DF='dd.MM.yyyy'");
//	// Guest group code
//	mGuestGroupCode = TrimAll(SelReservation.ГруппаГостей.Code);
//	vHotelPrefix = SelReservation.Гостиница.GetObject().pmGetPrefix();
//	If НЕ IsBlankString(vHotelPrefix) And SelReservation.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//		mGuestGroupCode = vHotelPrefix + mGuestGroupCode;
//	EndIf;
//	// Set parameters and put report section
//	vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//	vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//	vHeader.Parameters.mHotelPhones = mHotelPhones;
//	vHeader.Parameters.mHotelFax = mHotelFax;
//	vHeader.Parameters.mHotelEMail = mHotelEMail;
//	vHeader.Parameters.mContactPersonName = mContactPersonName;
//	vHeader.Parameters.mCustomerLegacyName = mCustomerLegacyName;
//	vHeader.Parameters.mContractDescription = mContractDescription;
//	vHeader.Parameters.mFax = mFax;
//	vHeader.Parameters.mEMail = mEMail;
//	vHeader.Parameters.mDate = mDate;
//	vHeader.Parameters.mGuestGroupCode = mGuestGroupCode;
//	// Logo
//	If vLogoIsSet Тогда
//		vHeader.Drawings.Logo.Print = True;
//		vHeader.Drawings.Logo.Picture = vLogo;
//	Else
//		vHeader.Drawings.Delete(vHeader.Drawings.Logo);
//	EndIf;
//	// Put header		
//	vSpreadsheet.Put(vHeader);
//	
//	// Guests in group
//	vRow = vTemplate.GetArea("Row");
//	vReservations = SelReservation.ГруппаГостей.GetObject().pmGetReservations(True, False, True, False, ?(SelShowCancellationForCurrentReservationOnly, SelReservation, Неопределено), ?(SelShowCancellationForCurrentReservationOnly, Неопределено, ?(SelReservations = Неопределено, Неопределено, ?(SelReservations.Count() > 1, SelReservations, Неопределено))));
//	For Each vRes In vReservations Do
//		If ЗначениеЗаполнено(vRes.Status) And 
//		   (НЕ vRes.Status.IsActive And НЕ vRes.Status.ЭтоЗаезд And НЕ vRes.Status.IsPreliminary) Тогда
//			vCurRes = vRes.Reservation;
//			vCurResObj = vCurRes.GetObject();
//			// Get accommodation prices for all day types of ГруппаНомеров rate
//			mRoomRate = vCurResObj.pmCalculatePricePresentation(SelLanguage);
//			// Fill parameters
//			vRow.Parameters.mGuest = cmGetFullPersonName(vCurRes.Клиент) + Chars.LF + "Индив. №: ';de='Ind. Nr.:'" + cmGetDocumentNumberPresentation(vCurRes.НомерДока);
//			vRow.Parameters.mPeriod = Format(vCurRes.CheckInDate, "DF='dd.MM.yy HH:mm'") + " - " +
//			                          Format(vCurRes.ДатаВыезда, "DF='dd.MM.yy HH:mm'");
//			vRow.Parameters.mQuantity = Format(vCurRes.RoomQuantity, "ND=6");
//			vRoomTypeToPrint = vCurRes.ТипНомера;
//			If ЗначениеЗаполнено(vRoomTypeToPrint) And ЗначениеЗаполнено(vCurRes.ТипНомераРасчет) And vCurRes.ТипНомераРасчет.BaseRoomType = vRoomTypeToPrint Тогда
//				vRoomTypeToPrint = vCurRes.ТипНомераРасчет;
//			EndIf;
//			vRow.Parameters.mRoomType = ?(ЗначениеЗаполнено(vRoomTypeToPrint), vRoomTypeToPrint.GetObject().pmGetRoomTypeDescription(SelLanguage) + " - ", "") + 
//			                            ?(ЗначениеЗаполнено(vCurRes.ВидРазмещения), vCurRes.ВидРазмещения.GetObject().pmGetAccommodationTypeDescription(SelLanguage), "");
//			vRow.Parameters.mRoom = ?(ЗначениеЗаполнено(vCurRes.НомерРазмещения), TrimAll(vCurRes.НомерРазмещения.Description), "");
//			vRow.Parameters.mRoomRate = mRoomRate;
//			vRow.Parameters.mNumberOfPersons = Format(vCurRes.КоличествоЧеловек, "ND=6");
//			vSpreadsheet.Put(vRow);
//		EndIf;
//	EndDo;
//	
//	// Cancellation reply
//	vRepl = vTemplate.GetArea("CancellationReply");
//	vCancellationReply = "";
//	If НЕ IsBlankString(SelReservation.ConfirmationReply) Тогда
//		If НЕ IsBlankString(vCancellationReply) Тогда
//			vCancellationReply = vCancellationReply + Chars.LF + Chars.LF + TrimAll(SelReservation.ConfirmationReply);
//		Else
//			vCancellationReply = TrimAll(SelReservation.ConfirmationReply);
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(SelReservation.ReservationStatus) And НЕ IsBlankString(SelReservation.ReservationStatus.ReservationConditions) Тогда
//		vCancellationReply = vCancellationReply + Chars.LF + SelReservation.ReservationStatus.ReservationConditions;
//	EndIf;
//	vRepl.Parameters.mCancellationReply = vCancellationReply;
//	vSpreadsheet.Put(vRepl);
//	
//	// Footer
//	vFooter = vTemplate.GetArea("Footer");
//	vFooter.Parameters.mReservationDivisionContacts = vHotelObj.pmGetHotelReservationDivisionContacts(SelLanguage);
//	vFooter.Parameters.mAuthor = ?(ЗначениеЗаполнено(SelReservation.Автор), SelReservation.Автор.GetObject().pmGetEmployeeDescription(SelLanguage), "");
//	vNumOfEmptyLines = 0;
//	vEmptyRow = vTemplate.GetArea("EmptyRow");
//	vFooterArray = New Array();
//	vFooterArray.Add(vFooter);
//	Try
//		While vSpreadsheet.CheckPut(vFooterArray) Do
//			vFooterArray.Вставить(0, vEmptyRow);
//			vNumOfEmptyLines = vNumOfEmptyLines + 1;
//		EndDo;
//	Except
//	EndTry;
//	If vNumOfEmptyLines > 0 Тогда
//		vFooterArray.Delete(0);
//	EndIf;
//	For Each vArea In vFooterArray Do
//		vSpreadsheet.Put(vArea);
//	EndDo;
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintCancellation
//
////-----------------------------------------------------------------------------
//Процедура pmPrintPaymentOrder(vSpreadsheet, SelReservation, SelReservationObj, SelReservations, SelServicesFilter, SelLanguage, SelObjectPrintForm) Экспорт
//	// Basic checks
//	If НЕ ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		ВызватьИсключение "У документа должна быть указана гостиница!";
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Choose template
//	vResObj = SelReservation.GetObject();
//	vSpreadsheet.Clear();
//	vTemplate = vResObj.GetTemplate("PaymentOrderRu");
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Get template area
//	vArea = vTemplate.GetArea("PaymentOrder");
//	
//	// Initialize area parameters
//	mCompanyName = "";
//	mCompanyBank = "";
//	mCompanyBankAccount = "";
//	mCompanyBankAttributes = "";
//	mClientName = "";
//	mClientAddress = "";
//	mPaymentText = "";
//	mSum = "";
//	
//	// Guest group code
//	mGuestGroupCode = TrimAll(SelReservation.ГруппаГостей.Code);
//	vHotelPrefix = SelReservation.Гостиница.GetObject().pmGetPrefix();
//	If НЕ IsBlankString(vHotelPrefix) And SelReservation.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//		mGuestGroupCode = vHotelPrefix + mGuestGroupCode;
//	EndIf;
//	
//	// Фирма
//	If ЗначениеЗаполнено(SelReservation.Фирма) Тогда
//		vCompanyObj = SelReservation.Фирма.GetObject();
//		mCompanyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//		
//		mCompanyTIN = TrimAll(vCompanyObj.ИНН);
//		mCompanyKPP = TrimAll(vCompanyObj.KPP);
//		
//		If ЗначениеЗаполнено(vCompanyObj.BankAccount) Тогда
//			vAccount = vCompanyObj.BankAccount;
//			mCompanyBank = vAccount.НазваниеБанка;
//			mCompanyBankAccount = vAccount.НомерСчета;
//			mCompanyBankAttributes = "к/с №" + vAccount.КорСчет + " " + 
//			                         TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка) + 
//			                         " БИК " + TrimAll(vAccount.БИКБанка) + " ИНН " + TrimAll(vCompanyObj.ИНН);
//		EndIf;
//	EndIf;
//	
//	// Create table of charging rules
//	vChargingRules = SelReservation.ChargingRules.Unload();
//	cmAddGuestGroupChargingRules(vChargingRules, SelReservation.ГруппаГостей);
//	
//	// Build table of all guest group services
//	vServices = Неопределено;
//	vReservations = SelReservation.ГруппаГостей.GetObject().pmGetReservations(True, True, False, False, Неопределено, ?(SelReservations = Неопределено, Неопределено, ?(SelReservations.Count() > 1, SelReservations, Неопределено)));
//	For Each vRes In vReservations Do
//		If ЗначениеЗаполнено(vRes.Status) And 
//		   (vRes.Status.IsActive Or vRes.Status.ЭтоЗаезд Or vRes.Status.IsPreliminary) Тогда
//			vCurRes = vRes.Reservation;
//			If vServices = Неопределено Тогда
//				vServices = vCurRes.Услуги.Unload();
//				vServices.Clear();
//			EndIf;
//			vCurResServices = cmGetReservationServices(vCurRes);
//			// Filter services by Контрагент
//			If SelServicesFilter > 0 Тогда
//				i = 0;
//				While i < vCurResServices.Count() Do
//					vResSrvRow = vCurResServices.Get(i);
//					If SelServicesFilter = 1 Тогда
//						If ЗначениеЗаполнено(vResSrvRow.СчетПроживания.Контрагент) Тогда
//							vCurResServices.Delete(i);
//							Continue;
//						EndIf;
//					ElsIf SelServicesFilter = 2 Тогда
//						If НЕ ЗначениеЗаполнено(vResSrvRow.СчетПроживания.Контрагент) Тогда
//							vCurResServices.Delete(i);
//							Continue;
//						EndIf;
//					EndIf;
//					i = i + 1;
//				EndDo;
//			EndIf;
//			// Merge all services to the one value table
//			For Each vResSrvRow In vCurResServices Do
//				vSrvRow = vServices.Add();
//				FillPropertyValues(vSrvRow, vResSrvRow);
//			EndDo;
//		EndIf;
//	EndDo;
//	vTotalSum = 0;
//	vTotalVATSum = 0;
//	If vServices <> Неопределено Тогда
//		vTotalSum = vServices.Total("Сумма") - vServices.Total("СуммаСкидки");
//		vTotalVATSum = vServices.Total("СуммаНДС");
//		If SelReservation.Контрагент = SelReservation.Агент And ЗначениеЗаполнено(SelReservation.Агент) And 
//		   vServices.Total("СуммаКомиссии") <> 0 And 
//		   cmCustomerIsPayer(vChargingRules, SelReservation.Контрагент, SelReservation.Договор, SelReservation.ГруппаГостей) Тогда
//			vTotalSum = vTotalSum - vServices.Total("СуммаКомиссии");
//		EndIf;		
//	EndIf;
//	
//	// Get first folio in charging rules
//	vFolio = Неопределено;
//	vFolioNumber = "";
//	If SelReservationObj.ChargingRules.Count() = 0 Тогда
//		ВызватьИсключение "Не заданы правила начислений!";
//	Else
//		If ЗначениеЗаполнено(SelReservationObj.ChargingRules[0].ChargingFolio) Тогда
//			vFolio = SelReservationObj.ChargingRules[0].ChargingFolio;
//			vFolioNumber = cmGetDocumentNumberPresentation(vFolio.НомерДока);
//		EndIf;
//	EndIf;
//	
//	// Get payment order sum
//	mSum = cmFormatSum(vTotalSum, ?(ЗначениеЗаполнено(vFolio), vFolio.ВалютаЛицСчета, SelReservation.Гостиница.ВалютаЛицСчета));
//	
//	// No VAT
//	vNoVAT = "";
//	If vTotalVATSum = 0 Тогда
//		vNoVAT = " Без НДС'";
//	EndIf;
//	
//	// Payment text
//	mPaymentText = "Оплата брони №" + mGuestGroupCode +" фолио №" + vFolioNumber + vNoVAT + ".";
//	
//	// Client name and address
//	If ЗначениеЗаполнено(SelReservation.Клиент) Тогда
//		vGuest = SelReservation.Клиент;
//		mClientName = TrimAll(vGuest.FullName);
//		vGuestAddress = cmParseAddress(vGuest.Address);
//		mClientAddress = "";
//		If ЗначениеЗаполнено(vGuestAddress.PostCode) Тогда
//			mClientAddress = vGuestAddress.PostCode;
//		EndIf;
//		If ЗначениеЗаполнено(vGuestAddress.Region) Тогда
//			mClientAddress = TrimAll(mClientAddress) + " " + vGuestAddress.Region;
//		EndIf;
//		If ЗначениеЗаполнено(vGuestAddress.Area) Тогда
//			mClientAddress = TrimAll(mClientAddress) + " " + vGuestAddress.Area;
//		EndIf;
//		If ЗначениеЗаполнено(vGuestAddress.City) Тогда
//			mClientAddress = TrimAll(mClientAddress) + " " + vGuestAddress.City;
//		EndIf;
//		If ЗначениеЗаполнено(vGuestAddress.Street) Тогда
//			mClientAddress = TrimAll(mClientAddress) + " " + vGuestAddress.Street;
//		EndIf;
//		If ЗначениеЗаполнено(vGuestAddress.House) Тогда
//			mClientAddress = TrimAll(mClientAddress) + " " + vGuestAddress.House;
//		EndIf;
//		If ЗначениеЗаполнено(vGuestAddress.Flat) Тогда
//			mClientAddress = TrimAll(mClientAddress) + " " + vGuestAddress.Flat;
//		EndIf;
//	EndIf;
//	
//	// Set parameters and put payment order section
//	vArea.Parameters.mCompanyName = mCompanyName;
//	vArea.Parameters.mCompanyBank = mCompanyBank;
//	vArea.Parameters.mCompanyBankAccount = mCompanyBankAccount;
//	vArea.Parameters.mCompanyBankAttributes = mCompanyBankAttributes;
//	vArea.Parameters.mClientName = mClientName;
//	vArea.Parameters.mClientAddress = mClientAddress;
//	vArea.Parameters.mPaymentText = mPaymentText;
//	vArea.Parameters.mSum = mSum;
//	vSpreadsheet.Put(vArea);
//	
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintPaymentOrder
//
////-----------------------------------------------------------------------------
//Процедура pmPrintExpressCheckInInvitation(vSpreadsheet, SelReservation, SelReservations, SelShowConfirmationForCurrentReservationOnly, SelLanguage, SelObjectPrintForm) Экспорт
//	// Basic checks
//	If НЕ ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		ВызватьИсключение NStr("ru='У документа должна быть указана гостиница!';de='Bei dem Dokument muss das Гостиница angegeben sein!';en='Гостиница attribute should be filled!'");
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Some settings
//	vShowReservationNumbersInConfirmation = cmCheckUserPermissions("ShowReservationNumbersInConfirmation");
//	
//	// Fill and check grouping parameter
//	vParameter = Upper(TrimAll(SelObjectPrintForm.Parameter));
//	
//	// Choose template
//	vResObj = SelReservation.GetObject();
//	vSpreadsheet.Clear();
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = vResObj.GetTemplate("ReservationExpressCheckInInvitationEn");
//		ElsIf SelLanguage = Справочники.Локализация.DE Тогда
//			vTemplate = vResObj.GetTemplate("ReservationExpressCheckInInvitationDe");
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = vResObj.GetTemplate("ReservationExpressCheckInInvitationRu");
//		Else
//			ВызватьИсключение NStr("ru = 'Не найден шаблон печатной формы приглашения на экспресс-заселение для языка " + SelLanguage.Code + "!'; 
//			           |de = 'No reservation express check-in invitation print form template found for the " + SelLanguage.Code + " language!'; 
//			           |en = 'No reservation express check-in invitation print form template found for the " + SelLanguage.Code + " language!'");
//		EndIf;
//	Else
//		vTemplate = vResObj.GetTemplate("ReservationExpressCheckInInvitationRu");
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//		
//	// Load pictures
//	vLogoIsSet = False;
//	vLogo = New Picture;
//	If ЗначениеЗаполнено(SelReservation.Гостиница) Тогда
//		If SelReservation.Гостиница.Logo <> Неопределено Тогда
//			vLogo = SelReservation.Гостиница.Logo.Get();
//			If vLogo = Неопределено Тогда
//				vLogo = New Picture;
//			Else
//				vLogoIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Guests in group
//	vReservations = SelReservation.ГруппаГостей.GetObject().pmGetReservations(True, True, False, False, ?(SelShowConfirmationForCurrentReservationOnly, SelReservation, Неопределено), ?(SelShowConfirmationForCurrentReservationOnly, Неопределено, ?(SelReservations = Неопределено, Неопределено, ?(SelReservations.Count() > 1, SelReservations, Неопределено))));
//	For Each vRes In vReservations Do
//		If ЗначениеЗаполнено(vRes.Status) And vRes.Status.IsActive Тогда
//			vCurRes = vRes.Reservation;
//			vCurResObj = vCurRes.GetObject();
//
//			// Header
//			vHeader = vTemplate.GetArea("TopHeader");
//			// Гостиница
//			vHotelObj = vCurRes.Гостиница.GetObject();
//			mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//			mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//			mHotelPhones = TrimAll(vCurRes.Гостиница.Телефоны);
//			mHotelFax = TrimAll(vCurRes.Гостиница.Fax);
//			mHotelEMail = TrimAll(vCurRes.Гостиница.EMail);
//			// Guest
//			mGuestName = "";
//			If ЗначениеЗаполнено(vCurRes.Клиент) Тогда
//				mGuestName = TrimR(vCurRes.Клиент.FullName);
//			EndIf;
//			// E-Mail
//			mEMail = "";
//			If НЕ IsBlankString(vCurRes.EMail) Тогда
//				mEMail = TrimAll(vCurRes.EMail);
//			EndIf;
//			If ЗначениеЗаполнено(vCurRes.Контрагент) Тогда
//				If IsBlankString(mEMail) Тогда
//					mEMail = TrimAll(vCurRes.Контрагент.EMail);
//				EndIf;
//			ElsIf ЗначениеЗаполнено(vCurRes.ГруппаГостей) And ЗначениеЗаполнено(vCurRes.ГруппаГостей.Клиент) Тогда
//				If IsBlankString(mEMail) Тогда
//					mEMail = TrimAll(vCurRes.ГруппаГостей.Клиент.EMail);
//				EndIf;
//			EndIf;
//			// Document date
//			mDate = Format(vCurRes.ДатаДок, "DF='dd.MM.yyyy'");
//			// Guest group code
//			mGuestGroupCode = TrimAll(vCurRes.ГруппаГостей.Code);
//			vHotelPrefix = vCurRes.Гостиница.GetObject().pmGetPrefix();
//			If НЕ IsBlankString(vHotelPrefix) And vCurRes.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mGuestGroupCode = vHotelPrefix + mGuestGroupCode;
//			EndIf;
//			mReservationNumber = cmGetDocumentNumberPresentation(vCurRes.НомерДока);
//			// Set parameters and put report section
//			vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//			vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//			vHeader.Parameters.mHotelPhones = mHotelPhones;
//			vHeader.Parameters.mHotelFax = mHotelFax;
//			vHeader.Parameters.mHotelEMail = mHotelEMail;
//			vHeader.Parameters.mGuestName = mGuestName;
//			vHeader.Parameters.mEMail = mEMail;
//			vHeader.Parameters.mDate = mDate;
//			vHeader.Parameters.mGuestGroupCode = mGuestGroupCode;
//			vHeader.Parameters.mReservationNumber = mReservationNumber;
//			// Logo
//			If vLogoIsSet Тогда
//				vHeader.Drawings.Logo.Print = True;
//				vHeader.Drawings.Logo.Picture = vLogo;
//			Else
//				vHeader.Drawings.Delete(vHeader.Drawings.Logo);
//			EndIf;
//			// Put top header		
//			vSpreadsheet.Put(vHeader);
//			
//			// Print QR code
//			vQRCodeArea = vTemplate.GetArea("QRCode");
//			vResUUIDStr = String(vCurRes.UUID());
//			vQRCodeControl = vQRCodeArea.Drawings.QRCodeControl;
//			vQRCodeControl.Picture = cmGetQRCodePicture(vResUUIDStr);
//			vSpreadsheet.Put(vQRCodeArea);
//			
//			// Print reservation data
//			vResDataArea = vTemplate.GetArea("ReservationData");
//			vResDataArea.Parameters.mReservationData = Format(vCurRes.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(vCurRes.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + ", " + vCurRes.ТипНомера.GetObject().pmGetRoomTypeDescription(SelLanguage);
//			vSpreadsheet.Put(vResDataArea);
//			
//			// Footer
//			vFooter = vTemplate.GetArea("Footer");
//			vNumOfEmptyLines = 0;
//			vEmptyRow = vTemplate.GetArea("EmptyRow");
//			vFooterArray = New Array();
//			vFooterArray.Add(vFooter);
//			Try
//				While vSpreadsheet.CheckPut(vFooterArray) Do
//					vFooterArray.Вставить(0, vEmptyRow);
//					vNumOfEmptyLines = vNumOfEmptyLines + 1;
//				EndDo;
//			Except
//			EndTry;
//			If vNumOfEmptyLines > 0 Тогда
//				vFooterArray.Delete(0);
//			EndIf;
//			For Each vArea In vFooterArray Do
//				vSpreadsheet.Put(vArea);
//			EndDo;
//			
//			// Add page break
//			vSpreadsheet.PutHorizontalPageBreak();
//		EndIf;
//	EndDo;
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintExpressCheckInInvitation
//
////-----------------------------------------------------------------------------
//RoomsWithReservedStatus = New СписокЗначений();
//HavePermissionToDoBookingWithoutRooms = cmCheckUserPermissions("HavePermissionToDoBookingWithoutRooms");
//StatusHasChanged = False;
//
//RoomsWriteOff = 0;
//BedsWriteOff = 0;
//AdditionalBedsWriteOff = 0;
//PersonsWriteOff = 0;
