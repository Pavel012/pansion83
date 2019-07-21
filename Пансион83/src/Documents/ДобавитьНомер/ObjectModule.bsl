Перем IsInFileMode;

//-----------------------------------------------------------------------------
Процедура FillRoomAttributes(pRoomObj)
	pRoomObj.Owner = Гостиница;
	pRoomObj.Description = НомерКомнаты;
	pRoomObj.Parent = КатегорияНомера;
	pRoomObj.ТипНомера = ТипНомера;
	pRoomObj.КоличествоМестНомер = NumberOfBedsPerRoom;
	pRoomObj.КоличествоГостейНомер = NumberOfPersonsPerRoom;
	pRoomObj.ДатаВыводаЭкспл = OperationEndDate;
	pRoomObj.ПорядокСортировки = SortCode;
	pRoomObj.Фирма = Company;
	pRoomObj.Секция = RoomSection;
	pRoomObj.LockCode = LockCode;
	pRoomObj.SecurityCode = SecurityCode;
	If НЕ IsBlankString(Remarks) Тогда
		pRoomObj.Примечания = Remarks;
	EndIf;
	If НЕ IsBlankString(Этаж) Тогда
		pRoomObj.Этаж = Этаж;
	EndIf;
	pRoomObj.ВиртуальныйНомер = IsVirtual;
КонецПроцедуры //FillRoomAttributes

//-----------------------------------------------------------------------------
Процедура pmWriteToRoomChangeHistory() Экспорт
	// Add record to the ГруппаНомеров change history
	vRCHRec = InformationRegisters.ИзмененияРеквизитовНомеров.CreateRecordManager();
	
	vRCHRec.НомерРазмещения = Room;
	vRCHRec.Period = Date;
	vRCHRec.User = Author;
	vRCHRec.DocRecorder = Ref;
	vRCHRec.ДатаВводаЭкспл = Date;
	
	FillPropertyValues(vRCHRec, ThisObject);
	
	vRCHRec.Write(True);
КонецПроцедуры //pmWriteToRoomChangeHistory

//-----------------------------------------------------------------------------
Процедура CreateRoom(pCancel)
	// If there's no ГруппаНомеров with such ГруппаНомеров number then it will be created. 
	// Otherwise if there is no change ГруппаНомеров documents after this one then
	// all ГруппаНомеров attributes will be changed. If this document is not the last
	// one for this ГруппаНомеров, then only operation start date will be changed.
	vRoomRef = Room;
	If НЕ ЗначениеЗаполнено(vRoomRef) Тогда
		vRoomRef = Справочники.НомернойФонд.FindByDescription(НомерКомнаты, True, Неопределено, Гостиница);
	EndIf;
	If ЗначениеЗаполнено(vRoomRef) Тогда
		vRoomObj = vRoomRef.GetObject();
		vRoomAttr = vRoomObj.pmGetRoomAttributes('39991231235959');
		For Each vRoomAttrRow In vRoomAttr Do
			If vRoomAttrRow.DocRecorder = ThisObject.Ref Or
			   НЕ ЗначениеЗаполнено(vRoomAttrRow.DocRecorder) Тогда
				FillRoomAttributes(vRoomObj);
			Else
				If TypeOf(vRoomAttrRow.DocRecorder) = Type("DocumentRef.ДобавитьНомер") Тогда
					ВызватьИсключение NStr("en='There is already one <Add ГруппаНомеров> document for the ГруппаНомеров choosen! You can not create more then one <Add ГруппаНомеров> document for the ГруппаНомеров. Please change the old one or use <Change ГруппаНомеров> document instead.';
					           |ru='Для указанного номера уже создан документ <Ввод номера в НФ>! У одного номера может быть только один документ ввода в НФ. Пожалуйста найдите и измените предыдущий документ или используйте документ <Изменить номер>.';
							   |de='Für das angegebene Zimmer wurde bereits das Dokument <Eingabe des Zimmers im Zimmerbestand> erstellt! Für ein Zimmer kann es nur ein Dokument über die Eingabe in den Zimmerbestand geben. Bitte finden Sie und ändern Sie das vorangehende Dokument oder verwenden Sie das Dokument <Zimmer ändern>.'");
				EndIf;
			EndIf;
		EndDo;
	Else
		vRoomObj = Справочники.НомернойФонд.CreateItem();
		FillRoomAttributes(vRoomObj);
		vRoomObj.СтатусНомера = Гостиница.VacantRoomStatus;
	EndIf;
		
	vRoomObj.ДатаВводаЭкспл = Date;
	vRoomObj.Write();
	
	// Remove records from the ГруппаНомеров change history
	UndoPosting(pCancel);
	
	// Set ГруппаНомеров document attribute and save it
	Room = vRoomObj.Ref;
	Write(DocumentWriteMode.Write);
	
	// Add record to the ГруппаНомеров change history
	pmWriteToRoomChangeHistory();
КонецПроцедуры //CreateRoom

//-----------------------------------------------------------------------------
Процедура WriteRoomInitializationRecords()
	// Write first initialization record to the 1st of january of year 2000
	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
	
	vRIRec.Period = '20000101';
	vRIRec.Гостиница = Гостиница;
	vRIRec.ТипНомера = ТипНомера;
	vRIRec.НомерРазмещения = Room;
	
	vRIRec.ВсегоНомеров = 0;
	vRIRec.ВсегоМест = 0;
	vRIRec.ВсегоГостей = 0;
	vRIRec.RoomsVacant = 0;
	vRIRec.BedsVacant = 0;
	vRIRec.GuestsVacant = 0;
	
	vRIRec.СчетчикДокКвота = 1;
	
	vRIRec.ДокОснование = Ref;
	vRIRec.КоличествоМестНомер = 0;
	vRIRec.КоличествоГостейНомер = 0;
	vRIRec.Примечания = "";
	vRIRec.Автор = Справочники.Employees.EmptyRef();
	vRIRec.IsRoomInventory = False;
	
	// Check if there are initialization records for the current ГруппаНомеров type
	vAddInitRecords = True;
	If ЗначениеЗаполнено(ТипНомера) And ТипНомера.IsVirtual Тогда
		vAddInitRecords = False;
	EndIf;
	If vAddInitRecords Тогда
		vQry =  New Query();
		vQry.Text = 
		"SELECT
		|	COUNT(*) AS Count
		|FROM
		|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
		|WHERE
		|	ЗагрузкаНомеров.СчетчикДокКвота > 0
		|	AND ЗагрузкаНомеров.Гостиница = &qГостиница
		|	AND ЗагрузкаНомеров.ТипНомера = &qRoomType
		|	AND ЗагрузкаНомеров.Period > &qInitializationDate
		|	AND (ЗагрузкаНомеров.Recorder REFS Document.AddRoom
		|			OR ЗагрузкаНомеров.Recorder REFS Document.ПереселениеНомер)";
		vQry.SetParameter("qГостиница", Гостиница);
		vQry.SetParameter("qRoomType", ТипНомера);
		vQry.SetParameter("qInitializationDate", AddMonth(CurrentDate(), 12));
		vQryRes = vQry.Execute().Unload();
		If vQryRes.Count() > 0 Тогда
			vQryResRow = vQryRes.Get(0);
			If vQryResRow.Count > 0 Тогда
				vAddInitRecords = False;
			EndIf;
		EndIf;
	EndIf;
	
	// Write initialization records for all dates in the ГруппаНомеров type next N years
	If vAddInitRecords Тогда
		vN = 15;
		If IsInFileMode Тогда
			vN = 3;
		EndIf;
		vCurDate = BegOfDay(Min(Date, CurrentDate() - 24*3600));
		vEndOfInitializationPeriod = BegOfDay(Max(Date, CurrentDate())) + 366*vN*24*3600;
		While vCurDate < vEndOfInitializationPeriod Do
			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
			
			vRIRec.Period = vCurDate;
			vRIRec.Гостиница = Гостиница;
			vRIRec.ТипНомера = ТипНомера;
			vRIRec.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
			
			vRIRec.ВсегоНомеров = 0;
			vRIRec.ВсегоМест = 0;
			vRIRec.ВсегоГостей = 0;
			vRIRec.RoomsVacant = 0;
			vRIRec.BedsVacant = 0;
			vRIRec.GuestsVacant = 0;
			
			vRIRec.СчетчикДокКвота = 1;
			
			vRIRec.ДокОснование = Ref;
			vRIRec.КоличествоМестНомер = 0;
			vRIRec.КоличествоГостейНомер = 0;
			vRIRec.Примечания = "";
			vRIRec.Автор = Справочники.Employees.EmptyRef();
			vRIRec.IsRoomInventory = False;
			
			vCurDate = vCurDate + 24*3600;
		EndDo;
	EndIf;
КонецПроцедуры //WriteRoomInitializationRecords

//-----------------------------------------------------------------------------
Процедура PostToRegisters(pCancel)
	// Clear register records
	RegisterRecords.ЗагрузкаНомеров.Clear();
	// To ГруппаНомеров inventory
	If IsVirtual = False Тогда
		// Add ГруппаНомеров inventory initialization records
		WriteRoomInitializationRecords();
		
		// Add ГруппаНомеров to the ГруппаНомеров inventory		
		vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
		
		vRIRec.Period = Date;
		vRIRec.Гостиница = Гостиница;
		vRIRec.ТипНомера = ТипНомера;
		vRIRec.НомерРазмещения = Room;
		
		If ЗначениеЗаполнено(ТипНомера) And ТипНомера.DoesNotAffectRoomRevenueStatistics Тогда
			vRIRec.ВсегоНомеров = 0;
			vRIRec.ВсегоМест = 0;
			vRIRec.ВсегоГостей = 0;
		Else
			vRIRec.ВсегоНомеров = 1;
			vRIRec.ВсегоМест = NumberOfBedsPerRoom;
			vRIRec.ВсегоГостей = NumberOfPersonsPerRoom;
		EndIf;
		vRIRec.RoomsVacant = 1;
		vRIRec.BedsVacant = NumberOfBedsPerRoom;
		vRIRec.GuestsVacant = NumberOfPersonsPerRoom;
		
		vRIRec.СчетчикДокКвота = 0;
		
		vRIRec.ДокОснование = Ref;
		vRIRec.КоличествоМестНомер = NumberOfBedsPerRoom;
		vRIRec.КоличествоГостейНомер = NumberOfPersonsPerRoom;
		vRIRec.Примечания = Remarks;
		vRIRec.Автор = Author;
		vRIRec.IsRoomInventory = True;
		
		If ЗначениеЗаполнено(OperationEndDate) Тогда
			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
			
			vRIRec.Period = OperationEndDate;
			vRIRec.Гостиница = Гостиница;
			vRIRec.ТипНомера = ТипНомера;
			vRIRec.НомерРазмещения = Room;
			
			If ЗначениеЗаполнено(ТипНомера) And ТипНомера.DoesNotAffectRoomRevenueStatistics Тогда
				vRIRec.ВсегоНомеров = 0;
				vRIRec.ВсегоМест = 0;
				vRIRec.ВсегоГостей = 0;
			Else
				vRIRec.ВсегоНомеров = 1;
				vRIRec.ВсегоМест = NumberOfBedsPerRoom;
				vRIRec.ВсегоГостей = NumberOfPersonsPerRoom;
			EndIf;
			vRIRec.RoomsVacant = 1;
			vRIRec.BedsVacant = NumberOfBedsPerRoom;
			vRIRec.GuestsVacant = NumberOfPersonsPerRoom;
			
			vRIRec.ДокОснование = Ref;
			vRIRec.КоличествоМестНомер = NumberOfBedsPerRoom;
			vRIRec.КоличествоГостейНомер = NumberOfPersonsPerRoom;
			vRIRec.Примечания = Remarks;
			vRIRec.Автор = Author;
			vRIRec.IsRoomInventory = True;
		EndIf;
		
		RegisterRecords.ЗагрузкаНомеров.Write();
	EndIf;
КонецПроцедуры //PostToRegisters

//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pPostingMode)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Fill execution mode
	IsInFileMode = False;
	If Left(InfoBaseConnectionString(), 5) = "File=" Тогда
		IsInFileMode = True;
	EndIf;
	// Do posting
	CreateRoom(pCancel);
	PostToRegisters(pCancel);
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Процедура UndoPosting(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Remove records from the ГруппаНомеров change history
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomChangeHistory.Period,
	|	RoomChangeHistory.НомерРазмещения
	|FROM
	|	InformationRegister.RoomChangeHistory AS RoomChangeHistory
	|WHERE
	|	RoomChangeHistory.DocRecorder = &qDocRecorder";
	vQry.SetParameter("qDocRecorder", Ref);
	vChanges = vQry.Execute().Unload();
	If vChanges.Count() > 0 Тогда
		vRCHRec = InformationRegisters.ИзмененияРеквизитовНомеров.CreateRecordManager();
		For Each vChangesRow In vChanges Do
			vRCHRec.НомерРазмещения = vChangesRow.ГруппаНомеров;
			vRCHRec.Период = vChangesRow.Период;
			vRCHRec.Read();
			If vRCHRec.Selected() Тогда
				vRCHRec.Delete();
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //UndoPosting

//-----------------------------------------------------------------------------
Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
	EndIf;
	If TrimAll(НомерКомнаты) = "" Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения комнаты> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<НомерРазмещения number> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<НомерРазмещения number> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "НомерКомнаты", pAttributeInErr);
	Else
		// Check that there is no such ГруппаНомеров already
		If ЭтоНовый() Тогда
			If ЗначениеЗаполнено(Гостиница) Тогда
				vRoomRef = Справочники.НомернойФонд.FindByDescription(НомерКомнаты, True, Неопределено, Гостиница);
				If vRoomRef <> Справочники.НомернойФонд.EmptyRef() Тогда
					vHasErrors = True; 
					vMsgTextRu = vMsgTextRu + "Такой НомерРазмещения в Номерном Фонде уже есть!" + Chars.LF;
					vMsgTextEn = vMsgTextEn + "This НомерРазмещения is present in НомерРазмещения Inventory already!" + Chars.LF;
					vMsgTextDe = vMsgTextDe + "This НомерРазмещения is present in НомерРазмещения Inventory already!" + Chars.LF;
					pAttributeInErr = ?(pAttributeInErr = "", "НомерКомнаты", pAttributeInErr);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(ТипНомера) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Тип номера> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<НомерРазмещения type> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<НомерРазмещения type> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ТипНомера", pAttributeInErr);
	EndIf;
	If НЕ IsVirtual And NumberOfBedsPerRoom = 0 Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Количество мест в номере> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Number of beds per НомерРазмещения> attribute should be more then zero!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Number of beds per НомерРазмещения> attribute should be more then zero!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "КоличествоМестНомер", pAttributeInErr);
	EndIf;
	If НЕ IsVirtual And NumberOfPersonsPerRoom = 0 Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Количество гостей в номере> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Number of persons per НомерРазмещения> attribute should be more then zero!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Number of persons per НомерРазмещения> attribute should be more then zero!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "КоличествоГостейНомер", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //CheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = BegOfYear(CurrentDate());
	Author = ПараметрыСеанса.ТекПользователь;
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and date
	pmFillAuthorAndDate();
	// Initialize attributes with default values
	SortCode = Number(Right(Number, 8))*100;
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.CurrentГостиница;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
	Перем vMessage, vAttributeInErr;
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	
	If pWriteMode = DocumentWriteMode.Posting Тогда
		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
		If pCancel Тогда
			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
			Message(NStr(vMessage), MessageStatus.Attention);
			ВызватьИсключение NStr(vMessage);
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура BeforeDelete(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	
	If Posted Тогда
		UndoPosting(pCancel);
	EndIf;
КонецПроцедуры //BeforeDelete

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(Гостиница) Тогда
		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.CurrentГостиница) Тогда
		vPrefix = TrimAll(ПараметрыСеанса.CurrentГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	// Clear ГруппаНомеров reference
	Room = Справочники.НомернойФонд.EmptyRef();
КонецПроцедуры //OnCopy

//-----------------------------------------------------------------------------
IsInFileMode = False;