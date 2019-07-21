Перем IsInFileMode;

//-----------------------------------------------------------------------------
Процедура WriteRoomInitializationRecords()
	// Write first initialization record to the 1st of january of year 2000
	vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
	
	vRIRec.Period = '20000101';
	vRIRec.Гостиница = Гостиница;
	vRIRec.ТипНомера = RoomType;
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
	If ЗначениеЗаполнено(RoomType) And RoomType.IsVirtual Тогда
		vAddInitRecords = False;
	EndIf;
	If vAddInitRecords Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	COUNT(*) AS Count
		|FROM
		|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
		|WHERE
		|	ЗагрузкаНомеров.СчетчикДокКвота > 0
		|	AND ЗагрузкаНомеров.Гостиница = &qHotel
		|	AND ЗагрузкаНомеров.ТипНомера = &qRoomType
		|	AND ЗагрузкаНомеров.Period > &qInitializationDate
		|	AND (ЗагрузкаНомеров.Recorder REFS Document.AddRoom
		|			OR ЗагрузкаНомеров.Recorder REFS Document.ПереселениеНомер)";
		vQry.SetParameter("qHotel", Гостиница);
		vQry.SetParameter("qRoomType", RoomType);
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
	vN = 15;
	If IsInFileMode Тогда
		vN = 3;
	EndIf;
	If vAddInitRecords Тогда
		vCurDate = BegOfDay(Min(Date, CurrentDate() - 24*3600));
		vEndOfInitializationPeriod = BegOfDay(Max(Date, CurrentDate())) + 366*vN*24*3600;
		While vCurDate < vEndOfInitializationPeriod Do
			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
			
			vRIRec.Period = vCurDate;
			vRIRec.Гостиница = Гостиница;
			vRIRec.ТипНомера = RoomType;
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
Процедура pmWriteToRoomChangeHistory() Экспорт
	// Add record to the ГруппаНомеров change history
	vRCHRec = InformationRegisters.ИзмененияРеквизитовНомеров.CreateRecordManager();
	
	vRCHRec.НомерРазмещения = Room;
	vRCHRec.Period = Date;
	vRCHRec.User = Author;
	vRCHRec.DocRecorder = Ref;
	
	FillPropertyValues(vRCHRec, ThisObject);
	
	vRCHRec.ДатаВводаЭкспл = Room.ДатаВводаЭкспл;
	
	vRCHRec.Write(True);
КонецПроцедуры //pmWriteToRoomChangeHistory

//-----------------------------------------------------------------------------
Процедура ChangeRoom(pCancel)
	// ГруппаНомеров atributes should be changed only if current document is the last one
	vRoomObj = Room.GetObject();
	vRoomAttr = vRoomObj.pmGetRoomAttributes('39991231235959');
	For Each vRoomAttrRow In vRoomAttr Do
		If ЗначениеЗаполнено(vRoomAttrRow.DocRecorder) Тогда
			If vRoomAttrRow.DocRecorder.ДатаДок > Date Тогда
				Return;
			ElsIf vRoomAttrRow.DocRecorder.ДатаДок = Date And vRoomAttrRow.DocRecorder <> Ref Тогда
				ВызватьИсключение NStr("en='There is already one <Add ГруппаНомеров> or <Change ГруппаНомеров> document for the date choosen! You can not create more then one <Add/Change ГруппаНомеров> documents for the same moment. Please change date of the current document.';
				           |ru='Для указанного номера уже существуют документы <Ввод номера в НФ> или <Изменить номер> с такой же датой документа! У одного номера в один момент времени может быть только один документ ввода в НФ/изменения реквизитов номера. Пожалуйста измените дату текущего документа.';
						   |de='Für das angegebene Zimmer wurde bereits das Dokument <Eingabe des Zimmers im Zimmerbestand> oder <Zimmer ändern> erstellt! Für ein Zimmer für einen Zeitpunkt muss es nur ein Dokument über die Eingabe in den Zimmerbestand/Änderung von Zimmerrequisiten geben. Bitte ändern Sie das Datum des aktuellen Dokuments.'");
			EndIf;
		EndIf;
	EndDo;
	
	// Change current ГруппаНомеров attributes
	vRoomObj.Owner = Гостиница;
	vRoomObj.Description = RoomNumber;
	vRoomObj.Parent = RoomGroup;
	vRoomObj.ТипНомера = RoomType;
	vRoomObj.КоличествоМестНомер = NumberOfBedsPerRoom;
	vRoomObj.КоличествоГостейНомер = NumberOfPersonsPerRoom;
	vRoomObj.ДатаВыводаЭкспл = OperationEndDate;
	vRoomObj.ПорядокСортировки = SortCode;
	vRoomObj.Фирма = Company;
	vRoomObj.Секция = RoomSection;
	vRoomObj.LockCode = LockCode;
	vRoomObj.SecurityCode = SecurityCode;
	If НЕ IsBlankString(Remarks) Тогда
		vRoomObj.Примечания = Remarks;
	EndIf;
	If НЕ IsBlankString(Floor) Тогда
		vRoomObj.Этаж = Floor;
	EndIf;
	vRoomObj.ВиртуальныйНомер = IsVirtual;
	
	vRoomObj.Write();
	
	// Remove records from the ГруппаНомеров change history
	UndoPosting(pCancel);
	
	// Add record to the ГруппаНомеров change history
	pmWriteToRoomChangeHistory();
КонецПроцедуры //ChangeRoom

//-----------------------------------------------------------------------------
Процедура PostToRegisters(pCancel)
	// Clear register records
	RegisterRecords.ЗагрузкаНомеров.Clear();
	
	// Get all ГруппаНомеров attributes valid on change date
	vRoomObj = Room.GetObject();
	vRoomAttr = vRoomObj.pmGetRoomAttributes(New Boundary(Date, BoundaryType.Excluding));
	
	// To ГруппаНомеров inventory
	If IsVirtual = False Тогда
		// Add ГруппаНомеров inventory initialization records
		WriteRoomInitializationRecords();
		// Do expense movement
		For Each vRoomAttrRow In vRoomAttr Do
			If НЕ vRoomAttrRow.ВиртуальныйНомер And 
			  (НЕ ЗначениеЗаполнено(vRoomAttrRow.ДатаВыводаЭкспл) Or ЗначениеЗаполнено(vRoomAttrRow.ДатаВыводаЭкспл) And vRoomAttrRow.ДатаВыводаЭкспл > Date) Тогда
				vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
				
				vRIRec.Period = Date;
				vRIRec.Гостиница = vRoomAttrRow.Гостиница;
				vRIRec.ТипНомера = vRoomAttrRow.ТипНомера;
				vRIRec.НомерРазмещения = Room;
				
				If ЗначениеЗаполнено(vRoomAttrRow.ТипНомера) And vRoomAttrRow.ТипНомера.DoesNotAffectRoomRevenueStatistics Тогда
					vRIRec.ВсегоНомеров = 0;
					vRIRec.ВсегоМест = 0;
					vRIRec.ВсегоГостей = 0;
				Else
					vRIRec.ВсегоНомеров = 1;
					vRIRec.ВсегоМест = vRoomAttrRow.КоличествоМестНомер;
					vRIRec.ВсегоГостей = vRoomAttrRow.КоличествоГостейНомер;
				EndIf;
				vRIRec.RoomsVacant = 1;
				vRIRec.BedsVacant = vRoomAttrRow.КоличествоМестНомер;
				vRIRec.GuestsVacant = vRoomAttrRow.КоличествоГостейНомер;
				
				vRIRec.ДокОснование = ThisObject.Ref;
				vRIRec.КоличествоМестНомер = vRoomAttrRow.КоличествоМестНомер;
				vRIRec.КоличествоГостейНомер = vRoomAttrRow.КоличествоГостейНомер;
				vRIRec.Примечания = Remarks;
				vRIRec.Автор = Author;
				vRIRec.IsRoomInventory = True;
				
				If ЗначениеЗаполнено(vRoomAttrRow.ДатаВыводаЭкспл) Тогда
					vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
					
					vRIRec.Period = vRoomAttrRow.ДатаВыводаЭкспл;
					vRIRec.Гостиница = vRoomAttrRow.Гостиница;
					vRIRec.ТипНомера = vRoomAttrRow.ТипНомера;
					vRIRec.НомерРазмещения = Room;
					
					If ЗначениеЗаполнено(vRoomAttrRow.ТипНомера) And vRoomAttrRow.ТипНомера.DoesNotAffectRoomRevenueStatistics Тогда
						vRIRec.ВсегоНомеров = 0;
						vRIRec.ВсегоМест = 0;
						vRIRec.ВсегоГостей = 0;
					Else
						vRIRec.ВсегоНомеров = 1;
						vRIRec.ВсегоМест = vRoomAttrRow.КоличествоМестНомер;
						vRIRec.ВсегоГостей = vRoomAttrRow.КоличествоГостейНомер;
					EndIf;
					vRIRec.RoomsVacant = 1;
					vRIRec.BedsVacant = vRoomAttrRow.КоличествоМестНомер;
					vRIRec.GuestsVacant = vRoomAttrRow.КоличествоГостейНомер;
					
					vRIRec.ДокОснование = ThisObject.Ref;
					vRIRec.КоличествоМестНомер = vRoomAttrRow.КоличествоМестНомер;
					vRIRec.КоличествоГостейНомер = vRoomAttrRow.КоличествоГостейНомер;
					vRIRec.Примечания = Remarks;
					vRIRec.Автор = Author;
					vRIRec.IsRoomInventory = True;
				EndIf;
			EndIf;
		EndDo;
		
		// Do receipt movement
		vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
		
		vRIRec.Period = Date;
		vRIRec.Гостиница = Гостиница;
		vRIRec.ТипНомера = RoomType;
		vRIRec.НомерРазмещения = Room;
		
		If ЗначениеЗаполнено(RoomType) And RoomType.DoesNotAffectRoomRevenueStatistics Тогда
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
		
		vRIRec.ДокОснование = ThisObject.Ref;
		vRIRec.КоличествоМестНомер = NumberOfBedsPerRoom;
		vRIRec.КоличествоГостейНомер = NumberOfPersonsPerRoom;
		vRIRec.Примечания = Remarks;
		vRIRec.Автор = Author;
		vRIRec.IsRoomInventory = True;
		
		If ЗначениеЗаполнено(OperationEndDate) Тогда
			vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
				
			vRIRec.Period = OperationEndDate;
			vRIRec.Гостиница = Гостиница;
			vRIRec.ТипНомера = RoomType;
			vRIRec.НомерРазмещения = Room;
				
			If ЗначениеЗаполнено(RoomType) And RoomType.DoesNotAffectRoomRevenueStatistics Тогда
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
				
			vRIRec.ДокОснование = ThisObject.Ref;
			vRIRec.КоличествоМестНомер = NumberOfBedsPerRoom;
			vRIRec.КоличествоГостейНомер = NumberOfPersonsPerRoom;
			vRIRec.Примечания = Remarks;
			vRIRec.Автор = Author;
			vRIRec.IsRoomInventory = True;
		EndIf;
			
		RegisterRecords.ЗагрузкаНомеров.Write();
	Else
		// Do expense movement
		For Each vRoomAttrRow In vRoomAttr Do
			If НЕ vRoomAttrRow.ВиртуальныйНомер Тогда
				vRIRec = RegisterRecords.ЗагрузкаНомеров.AddExpense();
				
				vRIRec.Period = Date;
				vRIRec.Гостиница = vRoomAttrRow.Гостиница;
				vRIRec.ТипНомера = vRoomAttrRow.ТипНомера;
				vRIRec.НомерРазмещения = Room;
				
				If ЗначениеЗаполнено(vRoomAttrRow.ТипНомера) And vRoomAttrRow.ТипНомера.DoesNotAffectRoomRevenueStatistics Тогда
					vRIRec.ВсегоНомеров = 0;
					vRIRec.ВсегоМест = 0;
					vRIRec.ВсегоГостей = 0;
				Else
					vRIRec.ВсегоНомеров = 1;
					vRIRec.ВсегоМест = vRoomAttrRow.КоличествоМестНомер;
					vRIRec.ВсегоГостей = vRoomAttrRow.КоличествоГостейНомер;
				EndIf;
				vRIRec.RoomsVacant = 1;
				vRIRec.BedsVacant = vRoomAttrRow.КоличествоМестНомер;
				vRIRec.GuestsVacant = vRoomAttrRow.КоличествоГостейНомер;
				
				vRIRec.ДокОснование = ThisObject.Ref;
				vRIRec.КоличествоМестНомер = vRoomAttrRow.КоличествоМестНомер;
				vRIRec.КоличествоГостейНомер = vRoomAttrRow.КоличествоГостейНомер;
				vRIRec.Примечания = Remarks;
				vRIRec.Автор = Author;
				vRIRec.IsRoomInventory = True;
				
				If ЗначениеЗаполнено(vRoomAttrRow.ДатаВыводаЭкспл) Тогда
					vRIRec = RegisterRecords.ЗагрузкаНомеров.AddReceipt();
					
					vRIRec.Period = vRoomAttrRow.ДатаВыводаЭкспл;
					vRIRec.Гостиница = vRoomAttrRow.Гостиница;
					vRIRec.ТипНомера = vRoomAttrRow.ТипНомера;
					vRIRec.НомерРазмещения = Room;
					
					If ЗначениеЗаполнено(vRoomAttrRow.ТипНомера) And vRoomAttrRow.ТипНомера.DoesNotAffectRoomRevenueStatistics Тогда
						vRIRec.ВсегоНомеров = 0;
						vRIRec.ВсегоМест = 0;
						vRIRec.ВсегоГостей = 0;
					Else
						vRIRec.ВсегоНомеров = 1;
						vRIRec.ВсегоМест = vRoomAttrRow.КоличествоМестНомер;
						vRIRec.ВсегоГостей = vRoomAttrRow.КоличествоГостейНомер;
					EndIf;
					vRIRec.RoomsVacant = 1;
					vRIRec.BedsVacant = vRoomAttrRow.КоличествоМестНомер;
					vRIRec.GuestsVacant = vRoomAttrRow.КоличествоГостейНомер;
					
					vRIRec.ДокОснование = ThisObject.Ref;
					vRIRec.КоличествоМестНомер = vRoomAttrRow.КоличествоМестНомер;
					vRIRec.КоличествоГостейНомер = vRoomAttrRow.КоличествоГостейНомер;
					vRIRec.Примечания = Remarks;
					vRIRec.Автор = Author;
					vRIRec.IsRoomInventory = True;
				EndIf;
			EndIf;
		EndDo;
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
	// Lock ГруппаНомеров
	vDataLock = New DataLock();
	vRItem = vDataLock.Add("Catalog.НомернойФонд");
	vRItem.Mode = DataLockMode.Exclusive;
	vRItem.SetValue("Ref", Room);
	vDataLock.Lock();
	// Change ГруппаНомеров attributes
	ChangeRoom(pCancel);
	// Write to ГруппаНомеров inventory
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
			vRCHRec.Period = vChangesRow.Period;
			vRCHRec.Read();
			If vRCHRec.Selected() Тогда
				vRCHRec.Delete();
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //UndoPosting

//-----------------------------------------------------------------------------
Function GetRoomOperations()
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.НомерРазмещения = &qRoom
	|	AND (ЗагрузкаНомеров.ПериодС < &qPeriodTo
	|			OR &qPeriodToIsEmpty)
	|	AND (ЗагрузкаНомеров.ПериодПо > &qPeriodFrom
	|			OR ЗагрузкаНомеров.ПериодПо = &qEmptyDate
	|				AND ЗагрузкаНомеров.IsBlocking)
	|	AND (ЗагрузкаНомеров.IsBlocking
	|			OR ЗагрузкаНомеров.IsReservation
	|			OR ЗагрузкаНомеров.IsAccommodation
	|			OR ЗагрузкаНомеров.IsRoomQuota)
	|
	|ORDER BY
	|	ЗагрузкаНомеров.Period";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qRoom", Room);
	vQry.SetParameter("qPeriodFrom", Date);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qPeriodTo", OperationEndDate);
	vQry.SetParameter("qPeriodToIsEmpty", НЕ ЗначениеЗаполнено(OperationEndDate));
	Return vQry.Execute().Unload();
EndFunction //GetRoomOperations

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
	If НЕ ЗначениеЗаполнено(Room) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<НомерРазмещения> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<НомерРазмещения> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
	EndIf;
	If TrimAll(RoomNumber) = "" Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <НомерРазмещения комнаты> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<НомерРазмещения number> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<НомерРазмещения number> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "НомерКомнаты", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(RoomType) Тогда
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
	If ЗначениеЗаполнено(Room) Тогда
		If Room.ДатаВводаЭкспл >= Date Тогда
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "Дата изменения параметров номера должена быть позже даты ввода номера в эксплуатацию!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "НомерРазмещения attributes change date should be after НомерРазмещения operation start date!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "НомерРазмещения attributes change date should be after НомерРазмещения operation start date!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "Date", pAttributeInErr);
		EndIf;
	EndIf;
	// Check that there is no ГруппаНомеров blocks, reservations or accommodations intersecting with document date or ГруппаНомеров operation end date
	If ЭтоНовый() And ЗначениеЗаполнено(Room) Тогда
		If ЗначениеЗаполнено(Date) Тогда
			vRoomOperations = GetRoomOperations();
			If vRoomOperations.Count() > 0 Тогда
				vHasErrors = True; 
				vMsgTextRu = vMsgTextRu + "По выбранному номеру на периоде изменения параметров номера существуют действующие блокировки, резервирования или размещения!" + Chars.LF;
				vMsgTextEn = vMsgTextEn + "There are НомерРазмещения blocks, reservations or accommodations for the НомерРазмещения selected for the НомерРазмещения attributes change period!" + Chars.LF;
				vMsgTextDe = vMsgTextDe + "There are НомерРазмещения blocks, reservations or accommodations for the НомерРазмещения selected for the НомерРазмещения attributes change period!" + Chars.LF;
				pAttributeInErr = ?(pAttributeInErr = "", "НомерРазмещения", pAttributeInErr);
			EndIf;
		EndIf;
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = BegOfDay(CurrentDate());
	Author = ПараметрыСеанса.ТекПользователь;
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill ГруппаНомеров attributes
	If ЗначениеЗаполнено(Room) Тогда
		vRoomObj = Room.GetObject();
		vRoomAttr = vRoomObj.pmGetRoomAttributes(Date);
		For Each vRoomAttrRow In vRoomAttr Do
			Гостиница = vRoomAttrRow.Гостиница;
			RoomGroup = vRoomAttrRow.КатегорияНомера;
			RoomNumber = vRoomAttrRow.НомерКомнаты;
			RoomType = vRoomAttrRow.ТипНомера;
			NumberOfBedsPerRoom = vRoomAttrRow.КоличествоМестНомер;
			NumberOfPersonsPerRoom = vRoomAttrRow.КоличествоГостейНомер;
			OperationEndDate = vRoomAttrRow.ДатаВыводаЭкспл;
			SortCode = Room.Сортировка;
			Company = Room.Фирма;
			RoomSection = Room.Секция;
			LockCode = Room.LockCode;
			SecurityCode = Room.SecurityCode;
			Remarks = Room.Remarks;
			IsVirtual = vRoomAttrRow.ВиртуальныйНомер;
		EndDo;
	EndIf;
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
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
Процедура Filling(pBase)
	If ЗначениеЗаполнено(pBase) Тогда
		If TypeOf(pBase) = Type("CatalogRef.НомернойФонд") Тогда
			Room = pBase;
			pmFillAttributesWithDefaultValues();
		EndIf;
	EndIf;
КонецПроцедуры //Filling

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(Гостиница) Тогда
		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber

//-----------------------------------------------------------------------------
IsInFileMode = False;
