//-----------------------------------------------------------------------------
// Data processors framework start
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Initialize attributes with default values
// Attention: This procedure could be called AFTER some attributes initialization
// routine, so it SHOULD NOT reset attributes being set before
//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	If НЕ ЗначениеЗаполнено(Period) Тогда
		Period = BegOfDay(CurrentDate()) - 365*24*3600;
	EndIf;
	If НЕ PurgeChargesMarkedForDeletion And 
	   НЕ PurgeFoliosMarkedForDeletion And
	   НЕ PurgeChangeHistoryRecords Тогда
		PurgeChargesMarkedForDeletion = True;
		PurgeFoliosMarkedForDeletion = True;
		MarkClientsWithoutReferencesDeleted = True;
		PurgeChangeHistoryRecords = False;
		PurgeClientDataScans = False;
		SaveClientDataScans2Disc = False;
		ClearProcessedOnly = False;
		PurgeClientIdentificationData = False;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Run data processor in silent mode
//-----------------------------------------------------------------------------
Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
	// Clear database
	pmClearDatabase(pIsInteractive);
КонецПроцедуры //pmRun

//-----------------------------------------------------------------------------
// Data processors framework end
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
Процедура DeleteDocumentsBatch(pDocsArray, pIsInteractive)
	// Check references to the objects
	vRefTab = FindByRef(pDocsArray);
	// Clear charges with references from the batch
	For Each vRefTabRow In vRefTab Do
		vDocRef = vRefTabRow[0];
		vDocRefIndex = pDocsArray.Find(vDocRef);
		If vDocRefIndex <> Неопределено Тогда
			pDocsArray.Delete(vDocRefIndex);
		EndIf;
	EndDo;
	// Delete all documents left in one transaction
	Try
		vCount = pDocsArray.Count();
		BeginTransaction(DataLockControlMode.Managed);
		For Each vDocRef In pDocsArray Do
			vDocRef.GetObject().Delete();
		EndDo;
		CommitTransaction();
		// Log current state
		vMessage = NStr("ru='Удалено документов: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'; 
		                |de='Documents deleted: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'; 
						|en='Documents deleted: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'");
		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, vMessage);
	Except
		vMessage = ErrorDescription();
		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
		EndIf;
		If TransactionActive() Тогда
			RollbackTransaction();
		EndIf;
	EndTry;
	pDocsArray.Clear();
КонецПроцедуры //DeleteDocumentsBatch 

//-----------------------------------------------------------------------------
Процедура PurgeChargesMarkedForDeletion(pIsInteractive)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Начисление.Ref
	|FROM
	|	Document.Начисление AS Начисление
	|WHERE
	|	Начисление.ДатаДок <= &qPeriod
	|	AND Начисление.DeletionMark
	|	AND (Начисление.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|ORDER BY
	|	Начисление.PointInTime";
	vQry.SetParameter("qPeriod", EndOfDay(Period));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vChargesQryRes = vQry.Execute().Choose(QueryResultIteration.Linear);
	// Process charges by 1000 pieces in batch
	vDocsArray = New Array();
	While vChargesQryRes.Next() Do
		vDocsArray.Add(vChargesQryRes.Ref);
		// Check count
		If vDocsArray.Count() = 1000 Тогда
			DeleteDocumentsBatch(vDocsArray, pIsInteractive);
		EndIf;
	EndDo;
	DeleteDocumentsBatch(vDocsArray, pIsInteractive);
КонецПроцедуры //PurgeChargesMarkedForDeletion

//-----------------------------------------------------------------------------
Процедура PurgeFoliosMarkedForDeletion(pIsInteractive)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СчетПроживания.Ref
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.ДатаДок <= &qPeriod
	|	AND СчетПроживания.DeletionMark
	|	AND (СчетПроживания.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|ORDER BY
	|	СчетПроживания.PointInTime";
	vQry.SetParameter("qPeriod", EndOfDay(Period));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vFoliosQryRes = vQry.Execute().Choose(QueryResultIteration.Linear);
	// Process folios by 1000 pieces in batch
	vDocsArray = New Array();
	While vFoliosQryRes.Next() Do
		vDocsArray.Add(vFoliosQryRes.Ref);
		// Check count
		If vDocsArray.Count() = 1000 Тогда
			DeleteDocumentsBatch(vDocsArray, pIsInteractive);
		EndIf;
	EndDo;
	DeleteDocumentsBatch(vDocsArray, pIsInteractive);
КонецПроцедуры //PurgeFoliosMarkedForDeletion

//-----------------------------------------------------------------------------
Процедура PurgeChangeHistoryRecords(pIsInteractive, pInfRegMgr, pInfRegNameEn, pInfRegNameRu, pCheckHotel)
	vInfRegSel = pInfRegMgr.Select(, EndOfDay(Period));
	// Do in transaction
	Try
		vCount = 0;
		BeginTransaction(DataLockControlMode.Managed);
		While vInfRegSel.Next() Do
			// Check hotel
			If pCheckHotel Тогда
				If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(vInfRegSel.Гостиница) Тогда
					If Гостиница.IsFolder Тогда
						If НЕ vInfRegSel.Гостиница.BelongsToItem(Гостиница) Тогда
							Continue;
						EndIf;
					Else
						If vInfRegSel.Гостиница <> Гостиница Тогда
							Continue;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
			vInfRegRecMgr = vInfRegSel.GetRecordManager();
			vInfRegRecMgr.Delete();
			vCount = vCount + 1;
			// Commit each 1000 records
			If vCount/1000 = Int(vCount/1000) Тогда
				CommitTransaction();
				BeginTransaction(DataLockControlMode.Managed);
			EndIf;
		EndDo;
		CommitTransaction();
		// Log current state
		vMessage = NStr("ru='Удалено записей регистра истории изменения " + pInfRegNameRu + ": " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'; 
		                |de='" + pInfRegNameEn + " change history records deleted: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'; 
						|en='" + pInfRegNameEn + " change history records deleted: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'");
		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, vMessage);
	Except
		vMessage = ErrorDescription();
		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
		EndIf;
		If TransactionActive() Тогда
			RollbackTransaction();
		Endif;
	EndTry;
КонецПроцедуры //PurgeChangeHistoryRecords

//-----------------------------------------------------------------------------
Процедура PurgeClientDataScans(pIsInteractive)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ДанныеКлиента.Ref,
	|	ДанныеКлиента.Posted
	|FROM
	|	Document.ДанныеКлиента AS ДанныеКлиента
	|WHERE
	|	ДанныеКлиента.ДатаДок <= &qPeriod
	|	AND (NOT &qClearProcessedOnly
	|			OR &qClearProcessedOnly
	|				AND ДанныеКлиента.Posted
	|				AND ДанныеКлиента.Status = &qProcessed)
	|	AND (ДанныеКлиента.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|
	|ORDER BY
	|	ДанныеКлиента.PointInTime";
	vQry.SetParameter("qProcessed", Перечисления.ScanStatuses.IsProcessed);
	vQry.SetParameter("qClearProcessedOnly", ClearProcessedOnly);
	vQry.SetParameter("qPeriod", EndOfDay(Period));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vDocs = vQry.Execute().Choose(QueryResultIteration.Linear);
	// Process folios by 1000 pieces in batch
	vDocsArray = New Array();
	While vDocs.Next() Do
		If SaveClientDataScans2Disc Тогда
			If НЕ vDocs.Posted Тогда
				vDocsArray.Add(vDocs.Ref);
			Else
				vClientDataScanRef = vDocs.Ref;
				If vClientDataScanRef.ScanPictures.Count() > 0 Тогда
					vClientDataScanObj = vClientDataScanRef.GetObject();
					i = 0;
					While i < vClientDataScanObj.ScanPictures.Count() Do
						vPictRow = vClientDataScanObj.ScanPictures.Get(i);
						vPicture = vPictRow.ScanPicture.Get();
						If vPicture = Неопределено Тогда
							vClientDataScanObj.ScanPictures.Delete(i);
							Continue;
						ElsIf TypeOf(vPicture) = Type("Picture") Тогда
							vCatalogName = "";
							vFileName = vClientDataScanObj.pmGetImageFileName(vPictRow, vCatalogName);
							vCatalog = New File(vCatalogName);
							If НЕ vCatalog.Exist() Тогда
								CreateDirectory(vCatalogName);
							EndIf;
							vPicture.Write(vCatalogName + vFileName);
							vPictRow.ScanPicture = New ValueStorage(vFileName);
						EndIf;
						i = i + 1;
					EndDo;
					vClientDataScanObj.Write(DocumentWriteMode.Write);
				Else
					vDocsArray.Add(vDocs.Ref);
				EndIf;
			EndIf;
		Else
			vDocsArray.Add(vDocs.Ref);
		EndIf;
		// Check count
		If vDocsArray.Count() = 1000 Тогда
			DeleteDocumentsBatch(vDocsArray, pIsInteractive);
		EndIf;
	EndDo;
	DeleteDocumentsBatch(vDocsArray, pIsInteractive);
КонецПроцедуры //PurgeClientDataScans

//-----------------------------------------------------------------------------
Процедура PurgeClientIdentificationDataFromStructure(pObj)
	pObj.IdentityDocumentIssueDate = Неопределено;
	pObj.IdentityDocumentIssuedBy = "";
	pObj.IdentityDocumentNumber = "";
	pObj.IdentityDocumentSeries = "";
	pObj.IdentityDocumentValidToDate = Неопределено;
КонецПроцедуры //PurgeClientIdentificationDataFromStructure

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Процедура MarkClientsWithoutReferencesDeleted(pIsInteractive)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref,
	|	Клиенты.Code,
	|	Клиенты.FullName,
	|	GuestAccommodations.Клиент AS AccommodationGuest,
	|	GuestReservations.Клиент AS ReservationGuest,
	|	GuestResourceReservations.Клиент AS ResourceReservationClient,
	|	Foreigners.Клиент AS ForeignersGuest,
	|	GuestFolios.Клиент AS FoliosClient
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|		LEFT JOIN Document.Размещение AS GuestAccommodations
	|		ON Клиенты.Ref = GuestAccommodations.Клиент
	|		LEFT JOIN Document.Reservation AS GuestReservations
	|		ON Клиенты.Ref = GuestReservations.Клиент
	|		LEFT JOIN Document.БроньУслуг AS GuestResourceReservations
	|		ON Клиенты.Ref = GuestResourceReservations.Клиент
	|		LEFT JOIN Document.ForeignerRegistryRecord AS Foreigners
	|		ON Клиенты.Ref = Foreigners.Клиент
	|		LEFT JOIN Document.СчетПроживания AS GuestFolios
	|		ON Клиенты.Ref = GuestFolios.Клиент
	|WHERE
	|	Клиенты.CreateDate <= &qPeriod
	|	AND NOT Клиенты.IsFolder
	|	AND NOT Клиенты.DeletionMark
	|	AND NOT Клиенты.ЧерныйЛист
	|	AND NOT Клиенты.БелыйЛист
	|	AND Клиенты.IdentityDocumentNumber = &qEmptyString
	|	AND GuestAccommodations.Клиент IS NULL 
	|	AND GuestReservations.Клиент IS NULL 
	|	AND GuestResourceReservations.Клиент IS NULL 
	|	AND Foreigners.Клиент IS NULL 
	|	AND GuestFolios.Клиент IS NULL 
	|
	|ORDER BY
	|	Клиенты.CreateDate";
	vQry.SetParameter("qPeriod", EndOfDay(Period));
	vQry.SetParameter("qEmptyString", "");
	vClients = vQry.Execute().Choose(QueryResultIteration.Linear);
	// Process clients
	
	While vClients.Next() Do
		Try
			vClientObj = vClients.Ref.GetObject();
			vClientObj.SetDeletionMark(True);
			WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Information, vClients.Ref.Metadata(), vClients.Ref, NStr("en='Client is marked for deletion: ';ru='Клиент помечен на удаление: ';de='Der Kunde ist zum Löschen markiert: '") + TrimAll(vClients.FullName) + " (" + TrimAll(vClients.Code) + ")");
		Except
			vMessage = NStr("en='Error trying to mark client deleted: ';ru='Ошибка пометки клиента на удаление: ';de='Fehler bei der Markierung des Kunden zum Löschen: '") + TrimAll(vClients.FullName) + " (" + TrimAll(vClients.Code) + ")" + Chars.LF + ErrorDescription();
			WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Warning, ?(ЗначениеЗаполнено(vClients.Ref), vClients.Ref.Metadata(), Неопределено), vClients.Ref, vMessage);
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Attention);
			EndIf;
		EndTry;
	EndDo;
КонецПроцедуры //MarkClientsWithoutReferencesDeleted

//-----------------------------------------------------------------------------
Процедура PurgeClientIdentificationData(pIsInteractive)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref,
	|	Клиенты.Code,
	|	Клиенты.FullName,
	|	LastCheckOuts.CheckOutDate,
	|	Foreigners.Ref AS ForeignerRegistryRecord
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|		LEFT JOIN (SELECT
	|			Accommodations.Клиент AS Клиент,
	|			MAX(Accommodations.CheckOutDate) AS CheckOutDate
	|		FROM
	|			Document.Размещение AS Accommodations
	|		WHERE
	|			Accommodations.Posted
	|			AND Accommodations.СтатусРазмещения.IsActive
	|		
	|		GROUP BY
	|			Accommodations.Клиент) AS LastCheckOuts
	|		ON Клиенты.Ref = LastCheckOuts.Клиент
	|		LEFT JOIN Document.ForeignerRegistryRecord AS Foreigners
	|		ON Клиенты.Ref = Foreigners.Клиент
	|WHERE
	|	Клиенты.CreateDate <= &qPeriod
	|	AND (NOT Клиенты.IsFolder)
	|	AND Клиенты.IdentityDocumentNumber > &qEmptyString
	|	AND ISNULL(LastCheckOuts.CheckOutDate, &qEmptyDate) <= &qPeriod
	|
	|ORDER BY
	|	Клиенты.CreateDate";
	vQry.SetParameter("qPeriod", EndOfDay(Period));
	vQry.SetParameter("qEmptyString", "");
	vQry.SetParameter("qEmptyDate", '00010101');
	vClients = vQry.Execute().Choose(QueryResultIteration.Linear);
	// Process clients
	vRecMgr = InformationRegisters.ИсторияИзмКлиентов.CreateRecordManager();
	vForRecMgr = InformationRegisters.ЖурналИзмененийМС.CreateRecordManager();
	While vClients.Next() Do
		Try
			BeginTransaction(DataLockControlMode.Managed);
			vClientObj = vClients.Ref.GetObject();
			If НЕ IsBlankString(vClientObj.IdentityDocumentNumber) Тогда
				PurgeClientIdentificationDataFromStructure(vClientObj);
				
				// Save changes
				vClientObj.Write();
				// Clear client change history records
				vCCHQry = New Query();
				vCCHQry.Text = 
				"SELECT
				|	ИсторияИзмКлиентов.Period AS Period,
				|	ИсторияИзмКлиентов.Клиент
				|FROM
				|	InformationRegister.ИсторияИзмКлиентов AS ИсторияИзмКлиентов
				|WHERE
				|	ИсторияИзмКлиентов.Клиент = &qClient
				|ORDER BY
				|	Period";
				vCCHQry.SetParameter("qClient", vClientObj.Ref);
				vCCHRows = vCCHQry.Execute().Unload();
				For Each vCCHRow In vCCHRows Do
					vRecMgr.Period = vCCHRow.Period;
					vRecMgr.Клиент = vClientObj.Ref;
					vRecMgr.Read();
					If vRecMgr.Selected() Тогда
						PurgeClientIdentificationDataFromStructure(vRecMgr);
						
						// Save changes
						vRecMgr.Write(True);
					EndIf;
				EndDo;
			EndIf;
			// Clear client foreigner registry record
			If ЗначениеЗаполнено(vClients.ForeignerRegistryRecord) Тогда
				vDocObj = vClients.ForeignerRegistryRecord.GetObject();
				PurgeClientIdentificationDataFromStructure(vDocObj);
				// Save changes
				vDocObj.Write(DocumentWriteMode.Write);
				// Clear foreigner registry record change history records
				vCHQry = New Query();
				vCHQry.Text = 
				"SELECT
				|	ForeignerRegistryRecordChangeHistory.Period AS Period,
				|	ForeignerRegistryRecordChangeHistory.ForeignerRegistryRecord
				|FROM
				|	InformationRegister.ForeignerRegistryRecordChangeHistory AS ForeignerRegistryRecordChangeHistory
				|WHERE
				|	ForeignerRegistryRecordChangeHistory.ForeignerRegistryRecord = &qForeignerRegistryRecord
				|ORDER BY
				|	Period";
				vCHQry.SetParameter("qForeignerRegistryRecord", vDocObj.Ref);
				vCHRows = vCHQry.Execute().Unload();
				For Each vCHRow In vCHRows Do
					vForRecMgr.Period = vCHRow.Period;
					vForRecMgr.ForeignerRegistryRecord = vDocObj.Ref;
					vForRecMgr.Read();
					If vForRecMgr.Selected() Тогда
						PurgeClientIdentificationDataFromStructure(vForRecMgr);
						// Save changes
						vForRecMgr.Write(True);
					EndIf;
				EndDo;
			EndIf;
			CommitTransaction();
			WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Information, vClients.Ref.Metadata(), vClients.Ref, NStr("en='Indentification data were cleared for the client ';ru='Очищены идентификационные данные клиента ';de='Identifikationsdaten des Kunden wurden gelöscht '") + TrimAll(vClients.FullName) + " (" + TrimAll(vClients.Code) + ")");
		Except
			vMessage = ErrorDescription();
			WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Warning, vClients.Ref.Metadata(), vClients.Ref, vMessage);
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Attention);
			EndIf;
			If TransactionActive() Тогда
				RollbackTransaction();
			EndIf;
		EndTry;
	EndDo;
КонецПроцедуры //PurgeClientIdentificationData

//-----------------------------------------------------------------------------
Процедура PurgeMessages(pIsInteractive)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Задача.Ref
	|FROM
	|	Document.Задача AS Задача
	|WHERE
	|	Задача.ДатаДок <= &qPeriod
	|
	|ORDER BY
	|	Задача.PointInTime";
	vQry.SetParameter("qPeriod", EndOfDay(Period));
	vDocs = vQry.Execute().Choose(QueryResultIteration.Linear);
	// Process documents by 1000 pieces in batch
	vDocsArray = New Array();
	While vDocs.Next() Do
		vDocsArray.Add(vDocs.Ref);
		// Check count
		If vDocsArray.Count() = 1000 Тогда
			DeleteDocumentsBatch(vDocsArray, pIsInteractive);
		EndIf;
	EndDo;
	DeleteDocumentsBatch(vDocsArray, pIsInteractive);
КонецПроцедуры //PurgeMessages

//-----------------------------------------------------------------------------
//Процедура PurgeSMSDelivery(pIsInteractive)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	SMSDelivery.Ref
//	|FROM
//	|	Document.SMSDelivery AS SMSDelivery
//	|WHERE
//	|	SMSDelivery.Date <= &qPeriod
//	|	AND (SMSDelivery.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|
//	|ORDER BY
//	|	SMSDelivery.PointInTime";
//	vQry.SetParameter("qPeriod", EndOfDay(Period));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	vDocs = vQry.Execute().Choose(QueryResultIteration.Linear);
//	// Process documents by 1000 pieces in batch
//	vDocsArray = New Array();
//	While vDocs.Next() Do
//		vDocsArray.Add(vDocs.Ref);
//		// Check count
//		If vDocsArray.Count() = 1000 Тогда
//			DeleteDocumentsBatch(vDocsArray, pIsInteractive);
//		EndIf;
//	EndDo;
//	DeleteDocumentsBatch(vDocsArray, pIsInteractive);
//КонецПроцедуры //PurgeSMSDelivery

//-----------------------------------------------------------------------------
//Процедура PurgeSMSMessagesBeingSent(pIsInteractive)
//	vInfRegSel = InformationRegisters.SMSMessages.Select(, EndOfDay(Period));
//	// Do in transaction
//	Try
//		vCount = 0;
//		BeginTransaction(DataLockControlMode.Managed);
//		While vInfRegSel.Next() Do
//			vInfRegRecMgr = vInfRegSel.GetRecordManager();
//			vInfRegRecMgr.Delete();
//			vCount = vCount + 1;
//			// Commit each 1000 records
//			If vCount/1000 = Int(vCount/1000) Тогда
//				CommitTransaction();
//				BeginTransaction(DataLockControlMode.Managed);
//			EndIf;
//		EndDo;
//		CommitTransaction();
//		// Log current state
//		vMessage = NStr("ru='Удалено записей регистра истории отправленных СМС: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'; 
//		                |de='SMS messages being sent records deleted: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'; 
//						|en='SMS messages being sent records deleted: " + Format(vCount, "ND=17; NFD=0; NZ=; NG=") + "'");
//		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, vMessage);
//	Except
//		vMessage = ErrorDescription();
//		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//		EndIf;
//		If TransactionActive() Тогда
//			RollbackTransaction();
//		Endif;
//	EndTry;
//КонецПроцедуры //PurgeSMSMessagesBeingSent

//-----------------------------------------------------------------------------
Процедура pmClearDatabase(pIsInteractive = False) Экспорт
	WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
	// Check parameters
	If НЕ ЗначениеЗаполнено(Period) Тогда
		vMessage = NStr("ru='Не указана дата, по которую удалять объекты и записи!';de='Das Datum, an dem die Objekte und die Eintragungen gelöscht werden sollen, ist nicht angegeben!';en='Date to keep objects and records is not specified!'");
		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
			Return;
		Else
			ВызватьИсключение vMessage;
		EndIf;
	EndIf;
	// Process charges
	If PurgeChargesMarkedForDeletion Тогда
		PurgeChargesMarkedForDeletion(pIsInteractive);
	EndIf;
	// Process folios
	If PurgeFoliosMarkedForDeletion Тогда
		PurgeFoliosMarkedForDeletion(pIsInteractive);
	EndIf;
	// Process history records
	If PurgeChangeHistoryRecords Тогда
		// Accommodation change history
		vInfRegMgr = InformationRegisters.ИсторияИзмененийРазмещения;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "Размещение", "размещений", True);
		// Reservation change history
		vInfRegMgr = InformationRegisters.ИсторияБрони;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "Reservation", "резервирований", True);
		// Resource reservation change history
		vInfRegMgr = InformationRegisters.ИсторияИзмБрониРесурсов;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "Ресурс reservation", "брони ресурсов", True);
		// Foreigner registry record change history
		vInfRegMgr = InformationRegisters.ЖурналИзмененийМС;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "Foreigner registry record", "записей в журнал регистрации иностранцев", True);
		// Client change history
		vInfRegMgr = InformationRegisters.ИсторияИзмКлиентов;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "Клиент", "клиентов", False);
		// Контрагент change history
		vInfRegMgr = InformationRegisters.ИсторияИзмКонтрагентов;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "Контрагент", "контрагентов", False);
		// Contract change history
		vInfRegMgr = InformationRegisters.ИсторияИзмКлиентов;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "Договор", "договоров", False);
		// ГруппаНомеров status change history
		vInfRegMgr = InformationRegisters.ИзмСтатусовНомеров;
		PurgeChangeHistoryRecords(pIsInteractive, vInfRegMgr, "НомерРазмещения status", "статусов номеров", False);
	EndIf;
	// Process clients without references
	If MarkClientsWithoutReferencesDeleted Тогда
		MarkClientsWithoutReferencesDeleted(pIsInteractive);
	EndIf;
	// Process client data scans
	If PurgeClientDataScans Тогда
		PurgeClientDataScans(pIsInteractive);
	EndIf;
	// Process client identification data
	If PurgeClientIdentificationData Тогда
		PurgeClientIdentificationData(pIsInteractive);
	EndIf;
	// Process program messages
	If PurgeMessages Тогда
		PurgeMessages(pIsInteractive);
	EndIf;
	// Process SMS messages
		WriteLogEvent(NStr("en='DataProcessor.ClearDatabase';ru='Обработка.ОчисткаБазыДанных';de='DataProcessor.ClearDatabase'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
КонецПроцедуры //pmClearDatabase
