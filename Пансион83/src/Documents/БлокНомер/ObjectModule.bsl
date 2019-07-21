////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// Lock ГруппаНомеров
//	vDataLock = New DataLock();
//	vRItem = vDataLock.Add("Catalog.НомернойФонд");
//	vRItem.Mode = DataLockMode.Exclusive;
//	vRItem.SetValue("Ref", ГруппаНомеров);
//	vDataLock.Lock();
//	
//	// Clear register records
//	RegisterRecords.БлокирНомеров.Clear();
//	RegisterRecords.ЗагрузкаНомеров.Clear();
//	
//	// Get ГруппаНомеров attributes on set ГруппаНомеров block date from
//	vRoomObj = ГруппаНомеров.GetObject();
//	vRoomAttrs = vRoomObj.pmGetRoomAttributes(DateFrom);
//	For Each vRoomAttrsRow In vRoomAttrs Do
//		// 1. Add movements to the ГруппаНомеров inventory register
//		
//		// Add ГруппаНомеров block start movement
//		vStartBlock = RegisterRecords.ЗагрузкаНомеров.AddExpense();
//		
//		vStartBlock.Period = cm1SecondShift(DateFrom);
//		vStartBlock.ПериодС = vStartBlock.Period;
//		vStartBlock.ПериодПо = DateTo;
//		
//		FillPropertyValues(vStartBlock, ThisObject);
//		
//		vStartBlock.ТипНомера = vRoomAttrsRow.ТипНомера;
//		vStartBlock.CheckInDate = DateFrom;
//		vStartBlock.CheckOutDate = DateTo;
//		vStartBlock.CheckInAccountingDate = BegOfDay(DateFrom);
//		vStartBlock.CheckOutAccountingDate = BegOfDay(DateTo);
//		
//		vStartBlock.ЗаблокМест = vRoomAttrsRow.КоличествоМестНомер;
//		vStartBlock.ЗаблокНомеров = 1;
//		vStartBlock.BedsVacant = vRoomAttrsRow.КоличествоМестНомер;
//		vStartBlock.RoomsVacant = 1;
//		
//		vStartBlock.КоличествоМест = vRoomAttrsRow.КоличествоМестНомер;
//		vStartBlock.КоличествоНомеров = 1;
//		vStartBlock.КоличествоМестНомер = vRoomAttrsRow.КоличествоМестНомер;
//		vStartBlock.КоличествоГостейНомер = vRoomAttrsRow.КоличествоГостейНомер;
//		
//		vStartBlock.IsBlocking = True;
//		
//		// Add ГруппаНомеров block end movement
//		If ЗначениеЗаполнено(DateTo) Тогда
//			vEndBlock = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
//		
//			vEndBlock.Period = cm0SecondShift(DateTo);
//			vEndBlock.ПериодС = cm1SecondShift(DateFrom);
//			vEndBlock.ПериодПо = DateTo;
//			
//			FillPropertyValues(vEndBlock, ThisObject);
//			
//			vEndBlock.ТипНомера = vRoomAttrsRow.ТипНомера;
//			vEndBlock.CheckInDate = DateFrom;
//			vEndBlock.CheckOutDate = DateTo;
//			vEndBlock.CheckInAccountingDate = BegOfDay(DateFrom);
//			vEndBlock.CheckOutAccountingDate = BegOfDay(DateTo);
//			
//			vEndBlock.ЗаблокМест = vRoomAttrsRow.КоличествоМестНомер;
//			vEndBlock.ЗаблокНомеров = 1;
//			vEndBlock.BedsVacant = vRoomAttrsRow.КоличествоМестНомер;
//			vEndBlock.RoomsVacant = 1;
//			
//			vEndBlock.КоличествоМест = vRoomAttrsRow.КоличествоМестНомер;
//			vEndBlock.КоличествоНомеров = 1;
//			vEndBlock.КоличествоМестНомер = vRoomAttrsRow.КоличествоМестНомер;
//			vEndBlock.КоличествоГостейНомер = vRoomAttrsRow.КоличествоГостейНомер;
//		
//			vEndBlock.IsBlocking = True;
//		EndIf;
//		
//		// Write movements to the ГруппаНомеров Inventory register
//		RegisterRecords.ЗагрузкаНомеров.Write();
//		
//		// 2. Add movements to the ГруппаНомеров blocks register
//		
//		// Add ГруппаНомеров block start movement
//		vStartBlock = RegisterRecords.БлокирНомеров.AddReceipt();
//		
//		vStartBlock.Period = cm1SecondShift(DateFrom);
//		
//		FillPropertyValues(vStartBlock, ThisObject);
//		
//		vStartBlock.ТипНомера = vRoomAttrsRow.ТипНомера;
//		
//		vStartBlock.ЗаблокМест = vRoomAttrsRow.КоличествоМестНомер;
//		vStartBlock.ЗаблокНомеров = 1;
//		
//		// Add ГруппаНомеров block end movement
//		If ЗначениеЗаполнено(DateTo) Тогда
//			vEndBlock = RegisterRecords.БлокирНомеров.AddExpense();
//		
//			vEndBlock.Period = cm0SecondShift(DateTo);
//			
//			FillPropertyValues(vEndBlock, ThisObject);
//			
//			vEndBlock.ТипНомера = vRoomAttrsRow.ТипНомера;
//			
//			vEndBlock.ЗаблокМест = vRoomAttrsRow.КоличествоМестНомер;
//			vEndBlock.ЗаблокНомеров = 1;
//		EndIf;
//		
//		// Write movements to the ГруппаНомеров blocks register
//		RegisterRecords.БлокирНомеров.Write();
//	EndDo;
//	
//	// 3. Try to update ГруппаНомеров has blocks status
//	vDoUpdate = True;
//	If IsFinished Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	БлокНомер.Ref
//		|FROM
//		|	Document.БлокНомер AS БлокНомер
//		|WHERE
//		|	БлокНомер.IsFinished = FALSE AND 
//		|	БлокНомер.Posted = TRUE AND 
//		|	БлокНомер.НомерРазмещения = &qRoom";
//		vQry.SetParameter("qRoom", ГруппаНомеров);
//		vBlocks = vQry.Execute().Unload();
//		If vBlocks.Count() > 0 Тогда
//			vDoUpdate = False;
//		Else
//			If НЕ ГруппаНомеров.ЕстьБлокировки Тогда
//				vDoUpdate = False;
//			EndIf;
//		EndIf;
//	Else
//		If ГруппаНомеров.ЕстьБлокировки Тогда
//			vDoUpdate = False;
//		EndIf;
//	EndIf;
//	If vDoUpdate Тогда
//		vRoomObj = ГруппаНомеров.GetObject();
//		vRoomObj.ЕстьБлокировки = НЕ IsFinished;
//		vRoomObj.Write();
//	EndIf;
//	
//	// Change ГруппаНомеров status
//	ChangeRoomStatus(pCancel, pMode);
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
//		vMsgTextDe = vMsgTextDe + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Реквизит <НомерРазмещения> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(RoomBlockType) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Тип блокировки> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения block type> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Реквизит <Тип блокировки> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "RoomBlockType", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DateFrom) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата начала периода блокировки> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Start of НомерРазмещения block period> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Реквизит <Дата начала периода блокировки> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ДатаНачКвоты", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(DateFrom) Тогда
//		If ЗначениеЗаполнено(DateTo) Тогда
//			If DateFrom > DateTo Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Дата окончания периода блокировки должна быть позже даты начала периода блокировки!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "End of НомерРазмещения block period should be after start of НомерРазмещения block period!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "Дата окончания периода блокировки должна быть позже даты начала периода блокировки!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "ДатаКонКвоты", pAttributeInErr);
//			EndIf;
//		ElsIf ЗначениеЗаполнено(Гостиница) And Гостиница.EnableRoomInventoryChangeHistoryLogging Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "При включенном в карточке гостиницы режиме логирования истории изменения остатков свободных номеров дата окончания периода блокировки должна быть заполнена!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "End of НомерРазмещения block period should be filled if НомерРазмещения inventory changes logging is turned on for the current hotel!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "При включенном в карточке гостиницы режиме логирования истории изменения остатков свободных номеров дата окончания периода блокировки должна быть заполнена!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "ДатаКонКвоты", pAttributeInErr);
//		EndIf;
//		If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//			vBlocks = cmGetRoomBlocks(Гостиница, Неопределено, ГруппаНомеров, DateFrom, DateTo);
//			For Each vBlocksRow In vBlocks Do
//				If vBlocksRow.БлокНомер <> Ref Тогда
//					vHasErrors = True;
//					vMsgTextRu = vMsgTextRu + "У номера " + vBlocksRow.НомерРазмещения + " уже найдена блокировка с типом " + 
//											  vBlocksRow.RoomBlockType + " на периоде " + PeriodPresentation(vBlocksRow.ДатаНачКвоты, vBlocksRow.ДатаКонКвоты, cmLocalizationCode()) + "!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "НомерРазмещения " + vBlocksRow.НомерРазмещения + " has already block of type " + 
//											  vBlocksRow.RoomBlockType + " on period " + PeriodPresentation(vBlocksRow.ДатаНачКвоты, vBlocksRow.ДатаКонКвоты, cmLocalizationCode()) + "!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "У номера " + vBlocksRow.НомерРазмещения + " уже найдена блокировка с типом " + 
//											  vBlocksRow.RoomBlockType + " на периоде " + PeriodPresentation(vBlocksRow.ДатаНачКвоты, vBlocksRow.ДатаКонКвоты, cmLocalizationCode()) + "!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "RoomBlockType", pAttributeInErr);
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	// Check that there is no change ГруппаНомеров attributes in the period selected
//	If ЗначениеЗаполнено(ГруппаНомеров) And ЗначениеЗаполнено(DateFrom) Тогда
//		vChangeRoomAttrs = cmGetChangeRoomAttributes(ГруппаНомеров, DateFrom, DateTo);
//		If vChangeRoomAttrs.Count() > 0 Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В периоде действия блокировки не должно быть изменений параметров выбранного номера!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "There should be no change НомерРазмещения attributes in the НомерРазмещения block period!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "В периоде действия блокировки не должно быть изменений параметров выбранного номера!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
//		Else
//			vRoomAttrs = ГруппаНомеров.GetObject().pmGetRoomAttributes(DateFrom);
//			If vRoomAttrs.Count() > 0 Тогда
//				vRoomAttrsRow = vRoomAttrs.Get(0);
//				If НЕ cmCheckRoomAvailability(Гостиница, Справочники.КвотаНомеров.EmptyRef(), vRoomAttrsRow.ТипНомера, ГруппаНомеров, Ref, Posted, True,
//				                               0, 1, vRoomAttrsRow.КоличествоМестНомер, , 
//				                               vRoomAttrsRow.КоличествоМестНомер, vRoomAttrsRow.КоличествоГостейНомер, Max(CurrentDate(), DateFrom), ?(ЗначениеЗаполнено(DateTo), DateTo, '39991231120000'), 
//				                               vMsgTextRu, vMsgTextEn, vMsgTextDe) Тогда
//					vHasErrors = True; 
//					pAttributeInErr = ?(pAttributeInErr = "", "ДатаНачКвоты", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Автор = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate
//
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill author and document date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DateFrom) Тогда
//		DateFrom = cm1SecondShift(CurrentDate());
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//// Calculates and returns duration for giving period
////-----------------------------------------------------------------------------
//Function pmCalculateDuration() Экспорт
//	vDuration = 0;
//	If ЗначениеЗаполнено(DateFrom) And
//	   ЗначениеЗаполнено(DateTo) Тогда
//		vPerInSec = DateTo - DateFrom;
//		vDuration = Round(vPerInSec/24/3600, 0);
//	EndIf;
//	Return vDuration;
//EndFunction //pmCalculateDuration
//
////-----------------------------------------------------------------------------
//// Calculates and returns end of the period date based on giving duration
////-----------------------------------------------------------------------------
//Function pmCalculateDateTo() Экспорт
//	vDateTo = cm0SecondShift(DateTo);
//	If ЗначениеЗаполнено(DateFrom) Тогда
//		If Duration > 0 Тогда
//			vDateTo = cm0SecondShift(DateFrom + Duration*24*3600);
//		EndIf;
//	EndIf;
//	Return vDateTo;
//EndFunction //pmCalculateDateTo
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
//Процедура Filling(pBase)
//	pmFillAttributesWithDefaultValues();
//	If TypeOf(pBase) = Type("CatalogRef.ВидБлокНомеров") Тогда
//		RoomBlockType = pBase.Ref;
//	ElsIf TypeOf(pBase) = Type("CatalogRef.НомернойФонд") Тогда
//		Гостиница = pBase.Owner;
//		ГруппаНомеров = pBase.Ref;
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Процедура DoChangeRoomStatus(pRoomStatus, pRoom = Неопределено)
//	// Update status for ГруппаНомеров
//	vRoomObj = Неопределено;
//	If ЗначениеЗаполнено(pRoom) Тогда
//		vRoomObj = pRoom.GetObject();
//	Else
//		vRoomObj = ГруппаНомеров.GetObject();
//	EndIf;
//	If vRoomObj.СтатусНомера <> pRoomStatus Тогда
//		vRoomObj.СтатусНомера = pRoomStatus;
//		vRoomObj.Write();
//		
//		// Add record to the ГруппаНомеров status change history
//		vRoomObj.pmWriteToRoomStatusChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь, String(Ref));
//	EndIf;
//КонецПроцедуры //DoChangeRoomStatus
//
////-----------------------------------------------------------------------------
//Процедура ChangeRoomStatus(pCancel, pPostingMode)
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.OutOfOrderRoomStatus) Тогда
//		// Change status of the current ГруппаНомеров if this is out of order (repair)
//		If ЗначениеЗаполнено(ГруппаНомеров) And ЗначениеЗаполнено(RoomBlockType) And RoomBlockType.IsRoomRepair Тогда
//			If IsFinished Тогда
//				If DateTo <= CurrentDate() And ГруппаНомеров.СтатусНомера = Гостиница.OutOfOrderRoomStatus And ЗначениеЗаполнено(Гостиница.RoomStatusAfterRoomBlock) Тогда
//					DoChangeRoomStatus(Гостиница.RoomStatusAfterRoomBlock);
//				EndIf;
//			Else
//				If DateFrom <= CurrentDate() And (DateTo > CurrentDate() Or НЕ ЗначениеЗаполнено(DateTo)) Тогда
//					DoChangeRoomStatus(Гостиница.OutOfOrderRoomStatus);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //ChangeRoomStatus
