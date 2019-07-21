//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pPostingMode)
	If Status = Перечисления.ScanStatuses.IsProcessed Тогда
		// Create guest if it is missing
		If НЕ ЗначениеЗаполнено(Guest) And ЗначениеЗаполнено(ParentDoc) Тогда
			vCltObj = Справочники.Клиенты.CreateItem();
			vCltObj.pmFillAttributesWithDefaultValues();
			vCltObj.Parent = Справочники.Клиенты.CheckedInGuests;
			vCltObj.Write();
			Guest = vCltObj.Ref;
			ThisObject.Write(DocumentWriteMode.Write);
		EndIf;
		// Update guest data if there are changes
		If ЗначениеЗаполнено(Guest) Тогда
			vGuestObj = Guest.GetObject();
			If НЕ IsBlankString(LastName) Тогда
				If vGuestObj.Фамилия <> LastName Тогда
					vGuestObj.Фамилия = LastName;
					vGuestObj.FullName = vGuestObj.pmGetFullName();
				EndIf;
			EndIf;
			If НЕ IsBlankString(FirstName) Тогда
				If vGuestObj.Имя <> FirstName Тогда
					vGuestObj.Имя = FirstName;
					vGuestObj.FullName = vGuestObj.pmGetFullName();
				EndIf;
			EndIf;
			If НЕ IsBlankString(SecondName) Тогда
				If vGuestObj.Отчество <> SecondName Тогда
					vGuestObj.Отчество = SecondName;
					vGuestObj.FullName = vGuestObj.pmGetFullName();
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(Sex) Тогда
				If vGuestObj.Пол <> Sex Тогда
					vGuestObj.Пол = Sex;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(Citizenship) Тогда
				If vGuestObj.Гражданство <> Citizenship Тогда
					vGuestObj.Гражданство = Citizenship;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(DateOfBirth) Тогда
				If vGuestObj.ДатаРождения <> DateOfBirth Тогда
					vGuestObj.ДатаРождения = DateOfBirth;
				EndIf;
			EndIf;
			If НЕ IsBlankString(PlaceOfBirth) Тогда
				If TrimAll(vGuestObj.PlaceOfBirth) <> TrimAll(PlaceOfBirth) Тогда
					vGuestObj.PlaceOfBirth = PlaceOfBirth;
				EndIf;
			EndIf;
			If НЕ IsBlankString(Address) Тогда
				If TrimAll(vGuestObj.Address) <> TrimAll(Address) Тогда
					vGuestObj.Address = Address;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(IdentityDocumentType) Тогда
				If vGuestObj.IdentityDocumentType <> IdentityDocumentType Тогда
					vGuestObj.IdentityDocumentType = IdentityDocumentType;
				EndIf;
			EndIf;
			If НЕ IsBlankString(IdentityDocumentNumber) Тогда
				If TrimAll(vGuestObj.IdentityDocumentNumber) <> TrimAll(IdentityDocumentNumber) Тогда
					vGuestObj.IdentityDocumentNumber = IdentityDocumentNumber;
				EndIf;
			EndIf;
			If НЕ IsBlankString(IdentityDocumentSeries) Тогда
				If TrimAll(vGuestObj.IdentityDocumentSeries) <> TrimAll(IdentityDocumentSeries) Тогда
					vGuestObj.IdentityDocumentSeries = IdentityDocumentSeries;
				EndIf;
			EndIf;
			If НЕ IsBlankString(IdentityDocumentUnitCode) Тогда
				If TrimAll(vGuestObj.IdentityDocumentUnitCode) <> TrimAll(IdentityDocumentUnitCode) Тогда
					vGuestObj.IdentityDocumentUnitCode = IdentityDocumentUnitCode;
				EndIf;
			EndIf;
			If НЕ IsBlankString(IdentityDocumentIssuedBy) Тогда
				If TrimAll(vGuestObj.IdentityDocumentIssuedBy) <> TrimAll(IdentityDocumentIssuedBy) Тогда
					vGuestObj.IdentityDocumentIssuedBy = IdentityDocumentIssuedBy;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(IdentityDocumentIssueDate) Тогда
				If vGuestObj.IdentityDocumentIssueDate <> IdentityDocumentIssueDate Тогда
					vGuestObj.IdentityDocumentIssueDate = IdentityDocumentIssueDate;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(IdentityDocumentValidToDate) Тогда
				If vGuestObj.IdentityDocumentValidToDate <> IdentityDocumentValidToDate Тогда
					vGuestObj.IdentityDocumentValidToDate = IdentityDocumentValidToDate;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(AddressRegistrationDate) Тогда
							EndIf;
			vPhoto = Photo.Get();
			If vPhoto <> Неопределено Тогда
				vGuestObj.Photo = New ValueStorage(vPhoto);
			EndIf;
			vSignature = Signature.Get();
			If vSignature <> Неопределено Тогда
				vGuestObj.Подпись = New ValueStorage(vSignature);
			EndIf;
			// Check that guest object was changed
			If vGuestObj.Modified() Тогда
				vGuestObj.Write();
				// Write to guest change history
				vGuestObj.pmWriteToClientChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			EndIf;
		EndIf;
		// Update accommodation data if there are changes
		If ЗначениеЗаполнено(ParentDoc) Тогда
			vAccObj = ParentDoc.GetObject();
			// Guest full name
			If ЗначениеЗаполнено(Guest) Тогда
				If vAccObj.Клиент <> Guest Тогда
					vAccObj.Клиент = Guest;
				EndIf;
				If vAccObj.GuestFullName <> Guest.FullName Тогда
					vAccObj.GuestFullName = Guest.FullName;
				EndIf;
			EndIf;
			// Trip purpose
			//If ЗначениеЗаполнено(TripPurpose) Тогда
			//	If vAccObj.TripPurpose <> TripPurpose Тогда
			//		vAccObj.TripPurpose = TripPurpose;
			//	EndIf;
			//EndIf;
			// Check that accommodation object was changed
			If vAccObj.Modified() Тогда
				vAccObj.Write(DocumentWriteMode.Posting);
				// Write to accommodation change history
				vAccObj.pmWriteToAccommodationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			EndIf;
		EndIf;
		// Update foreigner registry records
		If ЗначениеЗаполнено(ParentDoc) Тогда
			vFRRs = ParentDoc.GetObject().pmGetForeignerRegistryRecords();
			If vFRRs <> Неопределено And vFRRs.Count() > 0 Тогда
				For Each vFRRsRow In vFRRs Do
					vFRRObj = vFRRsRow.ForeignerRegistryRecord.GetObject();
					FillPropertyValues(vFRRObj, ThisObject, , "Number, Автор, Примечания, НомерРазмещения, ДокОснование, Клиент, Гостиница"); 
					vFRRObj.Write(DocumentWriteMode.Posting);
					vFRRObj.pmWriteToForeignerRegistryRecordChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
				EndDo;
			Else
				If ЗначениеЗаполнено(Guest) And ЗначениеЗаполнено(Citizenship) And ЗначениеЗаполнено(Гостиница) And 
				   Citizenship <> Гостиница.Гражданство Тогда
					vFRRObj = Documents.ForeignerRegistryRecord.CreateDocument();
					vFRRObj.Fill(ParentDoc);
					FillPropertyValues(vFRRObj, ThisObject, , "Number, Автор, Примечания, НомерРазмещения, ДокОснование, Клиент, Гостиница"); 
					vFRRObj.Write(DocumentWriteMode.Posting);
					vFRRObj.pmWriteToForeignerRegistryRecordChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = CurrentDate();
	Author = ПараметрыСеанса.ТекПользователь;
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill from session parameters
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	If НЕ ЗначениеЗаполнено(Status) Тогда
		Status = Перечисления.ScanStatuses.ЭтоНовый;
	EndIf;
	//CheckPointNumber = Справочники.КПП.EmptyRef();
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetImageCatalogName(pRow) Экспорт
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		ВызватьИсключение NStr("en='Гостиница is not filled! ';ru='У документа не заполнена гостиница! ';de='Bei dem Dokument ist das Гостиница nicht eingetragen! '") + Ref;
	EndIf;
	vBLOBRootFolder = TrimAll(Гостиница.BLOBRootFolder);
	vNonReplicatingAttributes = Гостиница.GetObject().pmGetNonReplicatingAttributes();
	If vNonReplicatingAttributes.Count() > 0 Тогда
		vBLOBRootFolder = TrimAll(vNonReplicatingAttributes.Get(0).BLOBRootFolder);
	EndIf;
	vDelimeter = "\";
	If Find(vBLOBRootFolder, "/") > 0 Тогда
		vDelimeter = "/";
	EndIf;
	If Right(vBLOBRootFolder, 1) <> vDelimeter Тогда
		vBLOBRootFolder = vBLOBRootFolder + vDelimeter;
	EndIf;
	rCatalogName = vBLOBRootFolder + "ДанныеКлиента" + vDelimeter + TrimAll(Number) + "_" + Format(Date, "DF=yyyy-MM-dd") + vDelimeter;
	Return rCatalogName;
EndFunction //pmGetImageCatalogName

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Процедура Filling(pBase)
	// Fill attributes with default values
	pmFillAttributesWithDefaultValues();
	// Fill from the base
	If ЗначениеЗаполнено(pBase) Тогда
		If TypeOf(pBase) = Type("DocumentRef.Размещение") Тогда
			ParentDoc = pBase;
			GuestGroup = pBase.ГруппаГостей;
			Room = pBase.НомерРазмещения;
			Guest = pBase.Клиент;
			//TripPurpose = pBase.TripPurpose;
			If ЗначениеЗаполнено(Guest) Тогда
				FillPropertyValues(ThisObject, Guest);
				//PlaceOfBirth = TrimAll(Guest.Гражданство);
				If ЗначениеЗаполнено(pBase.Гостиница)  Тогда
					ArrivedFrom = Guest.Гражданство;
					IsFromAbroad = True;
					If ЗначениеЗаполнено(pBase.CheckInDate) Тогда
						BorderCrossingDate = BegOfDay(pBase.CheckInDate);
					Else
						BorderCrossingDate = BegOfDay(CurrentDate());
					EndIf;
					MigrationCardDateFrom = BorderCrossingDate;
					If ЗначениеЗаполнено(pBase.ДатаВыезда) Тогда
						MigrationCardDateTo = BegOfDay(pBase.ДатаВыезда);
					Else
						MigrationCardDateTo = MigrationCardDateFrom + 90*24*3600;
					EndIf;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(pBase.Гостиница) Тогда
				If Гостиница <> pBase.Гостиница Тогда
					Гостиница = pBase.Гостиница;
					SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
				EndIf;
			EndIf;
		ElsIf TypeOf(pBase) = Type("CatalogRef.Клиенты") Тогда
			ParentDoc = Неопределено;
			GuestGroup = Справочники.ГруппыГостей.EmptyRef();
			Room = Справочники.НомернойФонд.EmptyRef();
			Guest = pBase;
			//TripPurpose = Справочники.TripPurposes.EmptyRef();
			If ЗначениеЗаполнено(Guest) Тогда
				FillPropertyValues(ThisObject, Guest);
				PlaceOfBirth = TrimAll(Guest.Citizenship);
				If ЗначениеЗаполнено(Гостиница) And 
				   ЗначениеЗаполнено(Guest.Citizenship) And 
				   ЗначениеЗаполнено(Гостиница.Citizenship) And 
				   Guest.Гражданство <> Гостиница.Гражданство Тогда
					ArrivedFrom = Guest.Гражданство;
					IsFromAbroad = True;
					BorderCrossingDate = BegOfDay(CurrentDate());
					MigrationCardDateFrom = BorderCrossingDate;
					MigrationCardDateTo = MigrationCardDateFrom + 90*24*3600;
				EndIf;
			EndIf;
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
Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
	If pWriteMode <> DocumentWriteMode.UndoPosting Тогда
		If ЗначениеЗаполнено(Гостиница) And НЕ IsBlankString(Гостиница.BLOBRootFolder) Тогда
			For Each vPictRow In ScanPictures Do
				vPicture = vPictRow.ScanPicture.Get();
				If TypeOf(vPicture) = Type("Picture") Тогда
					Try
						vCatalogName = "";
						vFileName = "";// pmGetImageFileName(vPictRow, vCatalogName);
						vCatalog = New File(vCatalogName);
						If НЕ vCatalog.Exist() Тогда
							CreateDirectory(vCatalogName);
						EndIf;
						vPicture.Write(vCatalogName + vFileName);
						vPictRow.ScanPicture = New ValueStorage(vFileName);
					Except
						vPictRow.ScanPicture = New ValueStorage(vPicture);
					EndTry;
				EndIf;
			EndDo;
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite
