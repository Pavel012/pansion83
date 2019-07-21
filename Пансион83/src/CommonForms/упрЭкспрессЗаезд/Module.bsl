//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	OnCreateAtServerExport(pCancel);
КонецПроцедуры //OnCreateAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServerExport(pCancel = False, pParameter = Неопределено) Экспорт
	vReservation = Documents.Бронирование.EmptyRef();
	If ЗначениеЗаполнено(pParameter) And TypeOf(pParameter) = Type("DocumentRef.Бронирование") Тогда
		vReservation = pParameter;
	Else
		Parameters.Property("Key", vReservation);
	EndIf;
	If НЕ ЗначениеЗаполнено(vReservation) Or НЕ TypeOf(vReservation) = Type("DocumentRef.Бронирование") Тогда
		pCancel = True;
	EndIf;
	If НЕ pCancel Тогда
		If НЕ ЗначениеЗаполнено(GuestCount) Тогда
			GuestCount = 1;
		ElsIf GuestCount > 1 Тогда
			For vInd = 2 To GuestCount Do
				Try
					Items["GuestGroup"+String(vInd)].Visible = False;
				Except
				EndTry;
			EndDo;
			GuestCount = 1;
		EndIf;
		// Fill one ГруппаНомеров guests
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	Бронирование.Ref AS Ref,
		|	Бронирование.Клиент AS GuestRef
		|FROM
		|	Document.Бронирование AS Бронирование
		|WHERE
		|	Бронирование.ГруппаГостей = &qGroup
		|	AND (Бронирование.НомерРазмещения = &qRoom
		|				AND &qRoomIsFilled
		|			OR Бронирование.НомерДока = &qNumber
		|				AND NOT &qRoomIsFilled)
		|	AND Бронирование.Posted
		|	AND NOT Бронирование.DeletionMark
		|	AND (Бронирование.ReservationStatus.IsActive
		|			OR Бронирование.ReservationStatus.IsPreliminary
		|			OR Бронирование.ReservationStatus.IsInWaitingList)
		|	AND BEGINOFPERIOD(Бронирование.CheckInDate, DAY) = &qCheckInDateBegOfPeriod
		|
		|ORDER BY
		|	Бронирование.ВидРазмещения.ПорядокСортировки";
		vQry.SetParameter("qGroup", vReservation.ГруппаГостей);
		vQry.SetParameter("qRoom", vReservation.НомерРазмещения);
		vQry.SetParameter("qCheckInDateBegOfPeriod", BegOfDay(CurrentDate()));
		vQry.SetParameter("qRoomIsFilled", ЗначениеЗаполнено(vReservation.НомерРазмещения));
		vQry.SetParameter("qNumber", vReservation.НомерДока);
		vQry.SetParameter("qEmptyReservationStatusRef", Справочники.СтатусБрони.EmptyRef());
		vQry.SetParameter("qCurrentDateBegOfDay", BegOfDay(CurrentDate()));
		vQry.SetParameter("qEmptyRoom", Справочники.НомернойФонд.EmptyRef());
		vReservations = vQry.Execute().Unload();
		vIndex = 1;
		GuestCount = vReservations.Count();
		If vReservations.Count() > 0 Тогда
			For Each vReservRow In vReservations Do
				Try
					If vIndex <> 1 Тогда
						AddNewGuestFields(vIndex);
					EndIf;
					ЭтаФорма["ReservationRef"+String(vIndex)] = vReservRow.Ref;
					//Guest info
					ЭтаФорма["GuestRef"+String(vIndex)] = vReservRow.GuestRef;
					ЭтаФорма["GuestMainInformation"+String(vIndex)] = СокрЛП(vReservRow.GuestRef.Фамилия)+" "+СокрЛП(vReservRow.GuestRef.Имя)+" "+СокрЛП(vReservRow.GuestRef.Отчество);
					ЭтаФорма["GuestDateOfBirth"+String(vIndex)] = Format(vReservRow.GuestRef.ДатаРождения, "DF=dd.MM.yyyy");
					ЭтаФорма["GuestDocumentInformation"+String(vIndex)] = String(vReservRow.GuestRef.IdentityDocumentType)+", "+СокрЛП(vReservRow.GuestRef.IdentityDocumentSeries)+" "+СокрЛП(vReservRow.GuestRef.IdentityDocumentNumber);
					ЭтаФорма["GuestAddressInformation"+String(vIndex)] = СокрЛП(vReservRow.GuestRef.Address);
					ЭтаФорма["GuestMessagesInformation"+String(vIndex)] = СокрЛП(vReservRow.GuestRef.Примечания)+Chars.LF;
					If vReservRow.GuestRef.ЧерныйЛист Тогда
						Items["GuestMessagesInformation"+String(vIndex)].TextColor = New Color(255, 0, 0);
					ElsIf vReservRow.GuestRef.БелыйЛист Тогда
						Items["GuestMessagesInformation"+String(vIndex)].TextColor = New Color(0, 255, 0);
					EndIf;
					Items.RoomTypeDecoration.Title = String(vReservRow.Ref.ТипНомера)+"; "+Format(vReservRow.Ref.CheckInDate, "DF=dd.MM.yyyy")+"-"+Format(vReservRow.Ref.ДатаВыезда, "DF=dd.MM.yyyy");
					vMessages = cmGetMessagesForObject(vReservRow.GuestRef);
					For Each vMessage In vMessages Do
						ЭтаФорма["GuestMessagesInformation"+String(vIndex)] = ЭтаФорма["GuestMessagesInformation"+String(vIndex)] + СокрЛП(vMessage.Примечания) + "; " + Chars.LF;
					EndDo;
					//ГруппаНомеров
					If ЗначениеЗаполнено(vReservRow.Ref.НомерРазмещения) Тогда
						Items.FooterDecoration.Title = NStr("ru='Номер: '; en='ГруппаНомеров: '; de='Zimmer: '") + String(vReservRow.Ref.НомерРазмещения);
						Items.НомерРазмещения.Visible = False;
					Else
						Items.FooterDecoration.Title = NStr("ru='Номер: '; en='ГруппаНомеров: '; de='Zimmer: '");
						Items.НомерРазмещения.Visible = True;
					EndIf;
					// Load client photo
					vPicture = vReservRow.GuestRef.Photo.Get();
					If vPicture = Неопределено Тогда
						vPictureAddress = PutToTempStorage(PictureLib.Empty);
					Else    
						vPictureAddress = PutToTempStorage(vPicture);
					EndIf;
					ЭтаФорма["GuestPhoto"+String(vIndex)] = vPictureAddress;
					vIndex = vIndex + 1;
				Except
				EndTry;
			EndDo;
		Else
			pCancel = True;
		EndIf;
	EndIf;
КонецПроцедуры //OnCreateAtServerExport

//-----------------------------------------------------------------------------
&AtServer
Процедура AddNewGuestFields(pIndex)
	Try
		Try
			Items["GuestGroup"+String(pIndex)].Visible=True;
		Except
		EndTry;
		vTempArray = New Array;	
		vTempArray.Add(New FormAttribute("ReservationRef"+String(pIndex), New TypeDescription("DocumentRef.Бронирование")));
		vTempArray.Add(New FormAttribute("GuestRef"+String(pIndex), New TypeDescription("CatalogRef.Клиенты")));
		vTempArray.Add(New FormAttribute("GuestAddressInformation"+String(pIndex), New TypeDescription("String")));
		vTempArray.Add(New FormAttribute("GuestDateOfBirth"+String(pIndex), New TypeDescription("String")));
		vTempArray.Add(New FormAttribute("GuestDocumentInformation"+String(pIndex), New TypeDescription("String")));
		vTempArray.Add(New FormAttribute("GuestMainInformation"+String(pIndex), New TypeDescription("String")));
		vTempArray.Add(New FormAttribute("GuestMessagesInformation"+String(pIndex), New TypeDescription("String")));
		vTempArray.Add(New FormAttribute("GuestPhoto"+String(pIndex), New TypeDescription("String")));
		ChangeAttributes(vTempArray);
		
		//Guest group
		vGuestGroup = Items.Add("ГруппаГостей"+String(pIndex), Type("FormGroup"), Items.GuestsGroup);
		vGuestGroup.Title = NStr("en='""Guest №';ru='Группа ""Гость №';de='Gruppe ""Gast Nr.'")+String(pIndex)+NStr("ru='""';en='"" group';de='""'");
		vGuestGroup.ТипРазмещения = FormGroupType.UsualGroup;
		vGuestGroup.Representation = UsualGroupRepresentation.Line;
		vGuestGroup.Group = ChildFormItemsGroup.Horizontal;
		vGuestGroup.ShowTitle = False;
		//Guest photo
		vGuestPhotoField = Items.Add("GuestPhoto"+String(pIndex), Type("FormField"), vGuestGroup);
		vGuestPhotoField.ТипРазмещения = FormFieldType.PictureField;
		vGuestPhotoField.DataPath = "GuestPhoto"+String(pIndex);
		vGuestPhotoField.Title = NStr("en='Photo';ru='Фотография';de='Foto'");
		vGuestPhotoField.TitleLocation = FormItemTitleLocation.None; 
		vGuestPhotoField.Width = 12;
		vGuestPhotoField.Height = 5;
		vGuestPhotoField.HorizontalStretch = False;
		vGuestPhotoField.PictureSize = PictureSize.Proportionally;
		vGuestPhotoField.Border = New Border(ControlBorderType.WithoutBorder);
		//Main guest information group
		vMainInfoGroup = Items.Add("MainGuestInformationGroup"+String(pIndex), Type("FormGroup"), vGuestGroup);
		vMainInfoGroup.Title = NStr("en='Group ""Main guest information""';ru='Группа ""Основная информация""';de='Gruppe ""Hauptgästeinformation""'");
		vMainInfoGroup.ТипРазмещения = FormGroupType.UsualGroup;
		vMainInfoGroup.Representation = UsualGroupRepresentation.None;
		vMainInfoGroup.Group = ChildFormItemsGroup.Vertical;
		vMainInfoGroup.ShowTitle = False;
	    //Guest main information field
		vGuestMainInformationField = Items.Add("GuestMainInformation"+String(pIndex), Type("FormField"), vMainInfoGroup);
		vGuestMainInformationField.ТипРазмещения = FormFieldType.LabelField;
		vGuestMainInformationField.DataPath = "GuestMainInformation"+String(pIndex);
		vGuestMainInformationField.Title = NStr("en='Guest main information';ru='Основная информация о госте';de='Hauptgästeinformation'");
		vGuestMainInformationField.TitleLocation = FormItemTitleLocation.None; 
		vGuestMainInformationField.Font = New Font(,,True);
		//Date of birth and document information group
		vDoBAndDocInformationGroup = Items.Add("DateOfBirthAndDocumentInformationGroup"+String(pIndex), Type("FormGroup"), vMainInfoGroup);
		vDoBAndDocInformationGroup.Title = NStr("en='Group ""Date of birth and document information""';ru='Группа ""Дата рождения и информация о документе""';de='Gruppe ""Geburtsdatum und Dokumentinformationen""'");
		vDoBAndDocInformationGroup.ТипРазмещения = FormGroupType.UsualGroup;
		vDoBAndDocInformationGroup.Representation = UsualGroupRepresentation.None;
		vDoBAndDocInformationGroup.Group = ChildFormItemsGroup.Horizontal;
		vDoBAndDocInformationGroup.ShowTitle = False;
		//Guest date of birth field
		vGuestDateOfBirthField = Items.Add("GuestDateOfBirth"+String(pIndex), Type("FormField"), vDoBAndDocInformationGroup);
		vGuestDateOfBirthField.ТипРазмещения = FormFieldType.LabelField;
		vGuestDateOfBirthField.DataPath = "GuestDateOfBirth"+String(pIndex);
		vGuestDateOfBirthField.Title = NStr("en='Date of birth';ru='Дата рождения';de='Geburtsdatum'");
		vGuestDateOfBirthField.TitleLocation = FormItemTitleLocation.None; 
		vGuestDateOfBirthField.Width = 8;
		vGuestDateOfBirthField.HorizontalStretch = False;
		//Guest document information field
		vGuestDocumentInformationField = Items.Add("GuestDocumentInformation"+String(pIndex), Type("FormField"), vDoBAndDocInformationGroup);
		vGuestDocumentInformationField.ТипРазмещения = FormFieldType.LabelField;
		vGuestDocumentInformationField.DataPath = "GuestDocumentInformation"+String(pIndex);
		vGuestDocumentInformationField.Title = NStr("en='ГруппаНомеров';ru='Номер';de='Zimmer'");
		vGuestDocumentInformationField.TitleLocation = FormItemTitleLocation.None; 
		//Guest address information field
		vGuestAddressInformationField = Items.Add("GuestAddressInformation"+String(pIndex), Type("FormField"), vMainInfoGroup);
		vGuestAddressInformationField.ТипРазмещения = FormFieldType.LabelField;
		vGuestAddressInformationField.DataPath = "GuestAddressInformation"+String(pIndex);
		vGuestAddressInformationField.Title = NStr("en='Address';ru='Адрес';de='Adresse'");
		vGuestAddressInformationField.TitleLocation = FormItemTitleLocation.None; 
		//Guest messages field
		vGuestMessagesInformationField = Items.Add("GuestMessagesInformation"+String(pIndex), Type("FormField"), vMainInfoGroup);
		vGuestMessagesInformationField.ТипРазмещения = FormFieldType.InputField;
		vGuestMessagesInformationField.SkipOnInput = True;
		vGuestMessagesInformationField.MultiLine = True;
		vGuestMessagesInformationField.ReadOnly = True;
		vGuestMessagesInformationField.TextEdit = False;
		vGuestMessagesInformationField.BackColor = StyleColors.FormBackColor;
		vGuestMessagesInformationField.BorderColor = StyleColors.FormBackColor;
		vGuestMessagesInformationField.DataPath = "GuestMessagesInformation"+String(pIndex);
		vGuestMessagesInformationField.Title = NStr("en='Messages';ru='Сообщения';de='Nachrichten'");
		vGuestMessagesInformationField.TitleLocation = FormItemTitleLocation.None; 
	Except
	EndTry;
КонецПроцедуры //AddNewGuestFields

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ChangeGuestItem(pCommand)
	vID = Right(ЭтаФорма.CurrentItem.Name, StrLen(ЭтаФорма.CurrentItem.Name)-6);
	ChangeTypeOfFields(vID, True);
КонецПроцедуры

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ChangeTypeOfFields(pID, pIsInput = False)
	Try
		If pIsInput Тогда
			Items["GuestFirstName"+pID].Enabled = True;
			Items["GuestSecondName"+pID].Enabled = True;
			Items["GuestLastName"+pID].Enabled = True;
			Items["GuestDateOfBirth"+pID].Enabled = True;
			Items["GuestEMail"+pID].Enabled = True;
			Items["GuestPhone"+pID].Enabled = True;
			Items["GuestCitizenship"+pID].Enabled = True;
			Items["GuestIdentityDocumentType"+pID].Enabled = True;
			Items["GuestIdentityDocumentNumber"+pID].Enabled = True;
			Items["GuestIdentityDocumentSeries"+pID].Enabled = True;
			Items["GuestIdentityDocumentIssueDate"+pID].Enabled = True;
			Items["GuestAddress"+pID].Enabled = True;
			Items["Change"+pID].Visible = False;
			Items["ChangeOK"+pID].Visible = True;
			Items["ChangeCancel"+pID].Visible = True;
		Else
			Items["GuestFirstName"+pID].Enabled = False;
			Items["GuestSecondName"+pID].Enabled = False;
			Items["GuestLastName"+pID].Enabled = False;
			Items["GuestDateOfBirth"+pID].Enabled = False;
			Items["GuestEMail"+pID].Enabled = False;
			Items["GuestPhone"+pID].Enabled = False;
			Items["GuestCitizenship"+pID].Enabled = False;
			Items["GuestIdentityDocumentType"+pID].Enabled = False;
			Items["GuestIdentityDocumentNumber"+pID].Enabled = False;
			Items["GuestIdentityDocumentSeries"+pID].Enabled = False;
			Items["GuestIdentityDocumentIssueDate"+pID].Enabled = False;
			Items["GuestAddress"+pID].Enabled = False;
			Items["Change"+pID].Visible = True;
			Items["ChangeOK"+pID].Visible = False;
			Items["ChangeCancel"+pID].Visible = False;
		EndIf;
	Except
	EndTry;
КонецПроцедуры

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ChangeOK(pCommand)
	vID = Right(ЭтаФорма.CurrentItem.Name, StrLen(ЭтаФорма.CurrentItem.Name)-8);
	ChangeTypeOfFields(vID);
КонецПроцедуры

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ChangeCancel(pCommand)
	vID = Right(ЭтаФорма.CurrentItem.Name, StrLen(ЭтаФорма.CurrentItem.Name)-12);
	ChangeTypeOfFields(vID);
КонецПроцедуры

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RoomStartChoice(pItem, pChoiceData, pStandardProcessing)
	pStandardProcessing = False;
	vHotel = УпрСерверныеФункции.cmGetAttributeByRef(ReservationRef1, "Гостиница");
	If НЕ ЗначениеЗаполнено(vHotel) Тогда
		vHotel = УпрСерверныеФункции.cmGetCurrentHotelAttribute();
	EndIf;
	vRoomType = УпрСерверныеФункции.cmGetAttributeByRef(ReservationRef1, "ТипНомера");
	vRoomQuota = УпрСерверныеФункции.cmGetAttributeByRef(ReservationRef1, "КвотаНомеров");
	vNumberOfBeds = УпрСерверныеФункции.cmGetAttributeByRef(ReservationRef1, "КоличествоМест");
	vNumberOfRooms = УпрСерверныеФункции.cmGetAttributeByRef(ReservationRef1, "КоличествоНомеров");
	vCheckInDate = УпрСерверныеФункции.cmGetAttributeByRef(ReservationRef1, "CheckInDate");
	vCheckOutDate = УпрСерверныеФункции.cmGetAttributeByRef(ReservationRef1, "ДатаВыезда");
	#IF ThickClientOrdinaryApplication THEN
		vRoomQuantity = 1;
		vNumberOfBeds = Max(vNumberOfBeds, GuestCount);
		vFrm = ПолучитьФорму("Catalog.НомернойФонд.Form.ФормаПодбора", , pItem);
		vFrm.SelDateFrom = vCheckInDate;
		vFrm.SelDateTo = vCheckOutDate;
		If ЗначениеЗаполнено(vRoomQuota) Тогда
			vFrm.SelRoomQuota = vRoomQuota;
		Else
			vFrm.SelRoomQuota = Неопределено;
		EndIf;
		If ЗначениеЗаполнено(vRoomType) Тогда
			vFrm.SelRoomType = vRoomType;
		Else
			vFrm.SelRoomType = Неопределено;
		EndIf;
		vFrm.SelNumberOfBeds = ?(vRoomQuantity>0, Int(vNumberOfBeds/vRoomQuantity), 0);
		vFrm.SelNumberOfRooms = ?(vRoomQuantity>0, Int(vNumberOfRooms/vRoomQuantity), 0);
		vFrm.Гостиница = vHotel;
		vFrm.ChoiceMode = True;
	#Else
		vFrm = ПолучитьФорму("Catalog.НомернойФонд.ФормаВыбора", , pItem);
		vFrm.ДатаНачКвоты = vCheckInDate;
		vFrm.ДатаКонКвоты = vCheckOutDate;
		If ЗначениеЗаполнено(vRoomQuota) Тогда
			vFrm.SelRoomQuota = vRoomQuota;
		Else
			vFrm.SelRoomQuota = Неопределено;
		EndIf;
		If ЗначениеЗаполнено(vRoomType) Тогда
			vFrm.SelRoomType = vRoomType;
		Else
			vFrm.SelRoomType = Неопределено;
		EndIf;
		vFrm.SelNumberOfBeds = vNumberOfBeds;
		vFrm.SelNumberOfRooms = vNumberOfRooms;
		vFrm.Гостиница = vHotel;
	#EndIf
	vFrm.Open();
КонецПроцедуры

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура IssueKeyCardCommand(pCommand)
	vCheckResult = CheckUserPermissionToIssueKeyCards();
	If vCheckResult Тогда
		vAccList = CheckIn();
		// Print forms that should be printed for check-in
		#IF ThickClientOrdinaryApplication THEN
			For Each vAccItem In vAccList Do
				vFrm = vAccItem.Value.ПолучитьФорму();
				vFrm.InitializeGroupFormsAndActions();
				vFrm.PerformAutomaticPrinting(vAccItem.Value.GetObject());
			EndDo;
		#ENDIF
		// Issue key cards
		vIndex = 1;
		For Each vAccItem In vAccList Do
			Items.HelpMessageGroup.Visible = True;
			Items.HelpMessageDecoration.Title = NStr("ru='Приложите ключ для гостя №'; en='Put a key for the guest #'; de='Legte einen schlüssel für den Gast #'")+String(vIndex)+" ("+УпрСерверныеФункции.cmGetAttributeByRef(vAccItem.Value, "GuestFullName")+")";
			
			vIndex = vIndex + 1;
		EndDo;
		ЭтаФорма.Close();
	ElsIf vCheckResult = Неопределено Тогда
		Message(NStr("en='You have to issue key cards from the folios list of the current accommodation!';ru='Вы должны выдавать ключи из списка лицевых счетов гостя!';de='Sie müssen Schlüssel aus der Liste der Personenkonten des Gastes ausgeben!'"));
	Else
		Message(NStr("en='Door lock system is not configurated properly for the current workstation!';ru='Система электронных замков на данном рабочем месте не настроена!';de='Das System für elektronische Schlösser ist auf diesem Arbeitsplatz nicht eingestellt!'"));
	EndIf;
КонецПроцедуры //IssueKeyCardCommand

//-----------------------------------------------------------------------------
&AtServer
Function CheckIn()
	vSuccess = True;
	vAccList = New СписокЗначений;
	// Write
	BeginTransaction(DataLockControlMode.Managed);
	For vInd = 1 To GuestCount Do
		Try
			vReservationRef = ЭтаФорма["ReservationRef"+String(vInd)];
			If vReservationRef.НомерРазмещения <> Room And ЗначениеЗаполнено(Room) Тогда
				Try
					vResObj = vReservationRef.GetObject();
					vResObj.НомерРазмещения = Room;
					vResObj.Write();
				Except
					vSuccess = False;
					vErrInfo = ErrorInfo();
					// Rollback any transaction if active
					If TransactionActive() Тогда
						RollbackTransaction();
					EndIf;
					// Log and show error information
					WriteLogEvent(NStr("en='Document.Posting';ru='Документ.Проведение';de='Document.Posting'"), EventLogLevel.Warning, vResObj.Metadata(), vReservationRef, cmGetRootErrorDescription(vErrInfo));
					Message(vErrInfo.Description);
					Break;
				EndTry;
			EndIf;
			vAccObject = Documents.Размещение.CreateDocument();
			vAccObject.Fill(vReservationRef);
			vAccObject.Write(DocumentWriteMode.Posting);
			vAccList.Add(vAccObject.Ref);
		Except
			vSuccess = False;
			vErrInfo = ErrorInfo();
			// Rollback any transaction if active
			If TransactionActive() Тогда
				RollbackTransaction();
			EndIf;
			// Log and show error information
			WriteLogEvent(NStr("en='Document.Posting';ru='Документ.Проведение';de='Document.Posting'"), EventLogLevel.Warning, vAccObject.Metadata(), vAccObject.Ref, cmGetRootErrorDescription(vErrInfo));
			Message(vErrInfo.Description);
			Break;
		EndTry;
	EndDo;
	If vSuccess Тогда
		CommitTransaction();
	EndIf;
	Return vAccList;
EndFunction //CheckIn

//-----------------------------------------------------------------------------
&AtServer
Function CheckUserPermissionToIssueKeyCards()
	// Check parameters
	vWstn = ПараметрыСеанса.РабочееМесто;
	If НЕ ЗначениеЗаполнено(vWstn) Тогда
		Return False;
	EndIf;
	If НЕ vWstn.HasConnectionToDoorLockSystem Тогда
		Return False;
	EndIf;
	If НЕ ЗначениеЗаполнено(vWstn.DoorLockSystemParameters) Тогда
		Return False;
	EndIf;
	vDLST = vWstn.DoorLockSystemParameters.DoorLockSystemType;
	If НЕ ЗначениеЗаполнено(vDLST) Тогда
		Return False;
	EndIf;
	// Chek user permission to issue key cards from the accommodations list
	If ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) Тогда
		If ПараметрыСеанса.РабочееМесто.HasConnectionToDoorLockSystem And 
			ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.DoorLockSystemParameters) Тогда
			If ПараметрыСеанса.РабочееМесто.DoorLockSystemParameters.DoKeyCardsFromFoliosOnly Тогда
				Return Неопределено;
			EndIf;
		EndIf;
	EndIf;
	Return True;
EndFunction //CheckUserPermissionToIssueKeyCards
