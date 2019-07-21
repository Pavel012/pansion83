//-----------------------------------------------------------------------------
// Description: Standard client type control on change event processing routine
// Parameters: Client type, Client type confirmation text, Client type control, 
//             Whether to show default confirmation text pattern or not
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmClientTypeOnChange(pClientType, pClientTypeConfirmationText, 
                               pControl, pShowConfirmationText = False) Экспорт
	If ЗначениеЗаполнено(pClientType) Тогда
		If pClientType.AskForConfirmation Тогда
			If НЕ pShowConfirmationText Тогда
				pClientTypeConfirmationText = pClientType.ConfirmationPattern;
			EndIf;
			vRes = InputString(pClientTypeConfirmationText,
			                   NStr("ru='Заполните шаблон строки подтверждения!';
							        |de='Vorlage der Bestätigungszeile ausfüllen!';
			                        |en='Please fill confirmation text pattern!'"),
			                   100, False);
			If vRes Тогда
				If Upper(СокрЛП(pClientTypeConfirmationText)) = Upper(СокрЛП(pClientType.ConfirmationPattern)) Тогда
					Предупреждение(NStr("ru='Строка подтверждения совпадает с шаблоном! Выбор типа клиента будет отменен.';
					                  |de='Zeile für die Bestätigung stimmt mit Vorlage überein! Die Auswahl des Kundentyps wird zurückgesetzt!'; 
					                  |en='Confirmation text is the same as confirmation pattern! Client type will be cleared.'"));
					pClientType = Справочники.ТипыКлиентов.EmptyRef();
					pClientTypeConfirmationText = "";
				ElsIf IsBlankString(pClientTypeConfirmationText) Тогда
					Предупреждение(NStr("ru='Строка подтверждения не введена! Выбор типа клиента будет отменен.';
					                  |de='Die Zeile für die Bestätigung wurde nicht eingefügt! Die Auswahl des Kundentyps wird zurückgesetzt.'; 
									  |en='Confirmation text is not entered! Client type will be cleared.'"));
					pClientType = Справочники.ТипыКлиентов.EmptyRef();
					pClientTypeConfirmationText = "";
				EndIf;
			Else
				If НЕ pShowConfirmationText Тогда
					Предупреждение(NStr("ru='Строка подтверждения не введена! Выбор типа клиента будет отменен.';
					                  |de='Die Zeile für die Bestätigung wurde nicht eingefügt! Die Auswahl des Kundentyps wird zurückgesetzt.'; 
									  |en='Confirmation text is not entered! Client type will be cleared.'"));
					pClientType = Справочники.ТипыКлиентов.EmptyRef();
					pClientTypeConfirmationText = "";
				EndIf;
			EndIf;
		Else
			pClientTypeConfirmationText = "";
		EndIf;
	Else
		pClientTypeConfirmationText = "";
	EndIf;
	If IsBlankString(pClientTypeConfirmationText) Тогда
		If ЗначениеЗаполнено(pClientType) Тогда
			If pClientType.AskForConfirmation Тогда
				If pControl <> Неопределено Тогда
					pControl.Caption = NStr("ru='< введите строку подтверждения > ';
					                        |de='< führen Sie die Bestätigungszeile ein > '; 
					                        |en='< enter confirmation string > '");
				EndIf;
			EndIf;
		EndIf;
	Else
		If pControl <> Неопределено Тогда
			pControl.Caption = СокрЛП(pClientTypeConfirmationText);
		EndIf;
	EndIf;
КонецПроцедуры //cmClientTypeOnChange

//-----------------------------------------------------------------------------
// Description: Standard marketing code control on change event processing routine
// Parameters: Marketing code, Marketing code confirmation text, Marketing code control, 
//             Whether to show default confirmation text pattern or not
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmMarketingCodeOnChange(pMarketingCode, pMarketingCodeConfirmationText, 
                                  pControl, pShowConfirmationText = False) Экспорт
	If ЗначениеЗаполнено(pMarketingCode) Тогда
		If pMarketingCode.AskForConfirmation Тогда
			If НЕ pShowConfirmationText Тогда
				pMarketingCodeConfirmationText = pMarketingCode.ConfirmationPattern;
			EndIf;
			vRes = InputString(pMarketingCodeConfirmationText,
			                   NStr("ru='Заполните шаблон строки подтверждения!';
							        |de='Vorlage der Bestätigungszeile ausfüllen!'; 
			                        |en = 'Please fill confirmation text pattern!'"),
			                   100, False);
			If vRes Тогда
				If Upper(СокрЛП(pMarketingCodeConfirmationText)) = Upper(СокрЛП(pMarketingCode.ConfirmationPattern)) Тогда
					Предупреждение(NStr("ru='Строка подтверждения совпадает с шаблоном! Выбор направления маркетинга будет отменен.';
					                  |de='Zeile für die Bestätigung stimmt mit Vorlage überein! Die Auswahl der Marketingrichtung wird zurückgesetzt!'; 
					                  |en='Confirmation text is the same as confirmation pattern! Marketing code will be cleared.'"));
					pMarketingCode = Справочники.КодМаркетинга.EmptyRef();
					pMarketingCodeConfirmationText = "";
				ElsIf IsBlankString(pMarketingCodeConfirmationText) Тогда
					Предупреждение(NStr("ru='Строка подтверждения не введена! Выбор направления маркетинга будет отменен.';
					                  |de='Die Zeile für die Bestätigung wurde nicht eingefügt! Die Auswahl der Marketingrichtung wird zurückgesetzt.'; 
									  |en='Confirmation text is not entered! Marketing code will be cleared.'"));
					pMarketingCode = Справочники.КодМаркетинга.EmptyRef();
					pMarketingCodeConfirmationText = "";
				EndIf;
			Else
				If НЕ pShowConfirmationText Тогда
					Предупреждение(NStr("ru='Строка подтверждения не введена! Выбор направления маркетинга будет отменен.';
					                  |de='Die Zeile für die Bestätigung wurde nicht eingefügt! Die Auswahl der Marketingrichtung wird zurückgesetzt.'; 
									  |en='Confirmation text is not entered! Marketing code will be cleared.'"));
					pMarketingCode = Справочники.КодМаркетинга.EmptyRef();
					pMarketingCodeConfirmationText = "";
				EndIf;
			EndIf;
		Else
			pMarketingCodeConfirmationText = "";
		EndIf;
	Else
		pMarketingCodeConfirmationText = "";
	EndIf;
	If IsBlankString(pMarketingCodeConfirmationText) Тогда
		If ЗначениеЗаполнено(pMarketingCode) Тогда
			If pMarketingCode.AskForConfirmation Тогда
				If pControl <> Неопределено Тогда
					pControl.Caption = NStr("ru='< введите строку подтверждения > ';
					                        |de='< führen Sie die Bestätigungszeile ein > '; 
					                        |en='< enter confirmation string > '");
				EndIf;
			EndIf;
		EndIf;
	Else
		If pControl <> Неопределено Тогда
			pControl.Caption = СокрЛП(pMarketingCodeConfirmationText);
		EndIf;
	EndIf;
КонецПроцедуры //cmMarketingCodeOnChange

//-----------------------------------------------------------------------------
// Description: Standard dicount type control on change event processing routine
// Parameters: Discount percent number, Discount type, Discount type confiramtion text, 
//             Discount type control, Whether to show default confirmation text pattern or not, 
//             Whether to ask for the confirmation text or not
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmDiscountTypeOnChange(pDiscount, pDiscountType, pDiscountConfirmationText, pControl, 
                                 pShowConfirmationText = False, pAskForConfirmation = True) Экспорт
	If pAskForConfirmation = Неопределено Тогда
		pAskForConfirmation = True;
	EndIf;
	If ЗначениеЗаполнено(pDiscountType) Тогда
		If pAskForConfirmation Тогда
			If pDiscountType.AskForConfirmation Тогда
				If НЕ pShowConfirmationText Тогда
					pDiscountConfirmationText = pDiscountType.ConfirmationPattern;
				EndIf;
				vRes = InputString(pDiscountConfirmationText,
				                   NStr("ru='Заполните шаблон строки подтверждения!';
								        |de='Vorlage der Bestätigungszeile ausfüllen!'; 
				                        |en='Please fill confirmation text pattern!'"),
				                   100, False);
				If vRes Тогда
					If Upper(СокрЛП(pDiscountConfirmationText)) = Upper(СокрЛП(pDiscountType.ConfirmationPattern)) Тогда
						Предупреждение(NStr("ru='Строка подтверждения совпадает с шаблоном! Выбор типа скидки будет отменен.';
						                  |de='Zeile für die Bestätigung stimmt mit Vorlage überein! Die Auswahl der Art des Preisnachlasses wird zurückgesetzt!'; 
						                  |en='Confirmation text is the same as confirmation pattern! Discount type will be cleared.'"));
						pDiscount = 0;
						pDiscountType = Справочники.DiscountTypes.EmptyRef();
						pDiscountConfirmationText = "";
					ElsIf IsBlankString(pDiscountConfirmationText) Тогда
						Предупреждение(NStr("ru='Строка подтверждения не введена! Выбор типа скидки будет отменен.';
						                  |de='Die Zeile für die Bestätigung wurde nicht eingefügt! Die Auswahl der Art des Preisnachlasses wird zurückgesetzt.'; 
										  |en='Confirmation text is not entered! Discount type will be cleared.'"));
						pDiscount = 0;
						pDiscountType = Справочники.DiscountTypes.EmptyRef();
						pDiscountConfirmationText = "";
					EndIf;
				Else
					If НЕ pShowConfirmationText Тогда
						Предупреждение(NStr("ru='Строка подтверждения не введена! Выбор типа скидки будет отменен.';
						                  |de='Die Zeile für die Bestätigung wurde nicht eingefügt! Die Auswahl der Art des Preisnachlasses wird zurückgesetzt.'; 
										  |en='Confirmation text is not entered! Discount type will be cleared.'"));
						pDiscount = 0;
						pDiscountType = Справочники.DiscountTypes.EmptyRef();
						pDiscountConfirmationText = "";
					EndIf;
				EndIf;
			Else
				pDiscountConfirmationText = "";
			EndIf;
		EndIf;
	Else
		If pAskForConfirmation Тогда
			InputString(pDiscountConfirmationText,
			            NStr("ru='Заполните шаблон строки подтверждения!';
						     |de='Vorlage der Bestätigungszeile ausfüllen!'; 
			                 |en='Please fill confirmation text pattern!'"),
			            100, False);
		Else
			pDiscountConfirmationText = "";
		EndIf;
	EndIf;
	If pControl <> Неопределено Тогда
		If IsBlankString(pDiscountConfirmationText) Тогда
			pControl.Caption = NStr("ru='< введите строку подтверждения > ';
			                        |de='< führen Sie die Bestätigungszeile ein > '; 
			                        |en='< enter confirmation string > '");
		Else
			pControl.Caption = СокрЛП(pDiscountConfirmationText);
		EndIf;
	EndIf;
КонецПроцедуры //cmDiscountTypeOnChange

//-----------------------------------------------------------------------------
// Description: Standard client control start choice event processing routine
// Parameters: Object ref, Form, Client control, Default clients folder where to create new client, 
//             Document ref
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmClientStartChoice(pObjectRef, pForm, pControl, pDefaultFolder, pDocRef = Неопределено) Экспорт
	// Get clients search form
	vFrm = Справочники.Клиенты.GetChoiceForm("SearchForm", pControl);
	vFrm.ChoiceMode = True;
	vFrm.ChoiceInitialValue = pObjectRef;
	vFrm.MultipleChoice = False;
	vFrm.DefaultFolder = pDefaultFolder;
	If ЗначениеЗаполнено(pObjectRef) And 
	   TypeOf(pObjectRef) = Type("CatalogRef.Клиенты") Тогда
		vFrm.SelTemplateClient = pObjectRef;
	ElsIf ЗначениеЗаполнено(pDocRef) And 
	      TypeOf(pDocRef) = Type("CatalogRef.Клиенты") Тогда
		vFrm.SelTemplateClient = pDocRef;
	ElsIf ЗначениеЗаполнено(pDocRef) And 
	     (TypeOf(pDocRef) = Type("DocumentRef.Размещение") Or TypeOf(pDocRef) = Type("DocumentRef.Бронирование")) Тогда 
		vFrm.SelTemplateClient = pDocRef.Клиент;
	EndIf;
	If НЕ vFrm.IsOpen() Тогда
		vFrm.WindowAppearanceMode = WindowAppearanceModeVariant.Maximized;
	EndIf;
	vFrm.Open();
КонецПроцедуры //cmClientTextEditEnd

//-----------------------------------------------------------------------------
// Description: Standard client control text edit end event processing routine
// Parameters: Object ref, Form, Client control, Text entered, Default clients 
//             folder where to create new client, Document ref
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmClientTextEditEnd(pObjectRef, pForm, pControl, pText, pDefaultFolder, pDocRef = Неопределено) Экспорт
	// Get clients search form
	vFrm = Справочники.Клиенты.GetChoiceForm("SearchForm", pControl);
	vFrm.ChoiceMode = True;
	vFrm.ChoiceInitialValue = pObjectRef;
	vFrm.MultipleChoice = False;
	// Fill form attributes
	vText = СокрЛП(pText);
	// Check that identity document number is entered
	vWrk = cmCharRepl("0123456789", vText, "          ");
	If IsBlankString(vWrk) Тогда
		// Identity document number is entered
		vFrm.SelLastName = "";
		vFrm.SelFirstName = "";
		vFrm.SelSecondName = "";
		vFrm.SelIdentityDocumentNumber = vText;
	Else
		rLastName = "";
		rFirstName = "";
		rSecondName = "";
		rSex = Неопределено;
		// Try to parse text to last name, first name and second name
		cmParseClientFullName(vText, rLastName, rFirstName, rSecondName, rSex);
		// Guest description is entered
		vFrm.SelLastName = rLastName;
		vFrm.SelFirstName = rFirstName;
		vFrm.SelSecondName = rSecondName;
		vFrm.SelIdentityDocumentNumber = "";
	EndIf;
	vFrm.DefaultFolder = pDefaultFolder;
	If ЗначениеЗаполнено(pObjectRef) And 
	   TypeOf(pObjectRef) = Type("CatalogRef.Клиенты") Тогда
		vFrm.SelTemplateClient = pObjectRef;
	ElsIf ЗначениеЗаполнено(pDocRef) And 
	      TypeOf(pDocRef) = Type("CatalogRef.Клиенты") Тогда
		vFrm.SelTemplateClient = pDocRef;
	ElsIf ЗначениеЗаполнено(pDocRef) And 
	     (TypeOf(pDocRef) = Type("DocumentRef.Размещение") Or TypeOf(pDocRef) = Type("DocumentRef.Бронирование")) Тогда 
		vFrm.SelTemplateClient = pDocRef.Клиент;
	EndIf;
	If НЕ vFrm.IsOpen() Тогда
		vFrm.WindowAppearanceMode = WindowAppearanceModeVariant.Maximized;
	EndIf;
	vFrm.Open();
КонецПроцедуры //cmClientTextEditEnd

//-----------------------------------------------------------------------------
// Description: Asks user to enter guest check-out date
// Parameters: Guest check-in date, Guest planned check-out date
// Return value: Check-out date
//-----------------------------------------------------------------------------
Function cmGetCheckOutDate(pCheckInDate, pCheckOutDate) Экспорт
	vCheckOutDateTime = CurrentDate();
	If vCheckOutDateTime < pCheckInDate Тогда
		vCheckOutDateTime = pCheckInDate;
	EndIf;
	vFrm = GetCommonForm("ВводДатыВремя");
	If cmCheckUserPermissions("HavePermissionToUseReferenceHourAsDefaultCheckOutTime") Тогда
		vFrm.SelDate = BegOfDay(CurrentDate());
		If BegOfDay(pCheckOutDate) = BegOfDay(CurrentDate()) Тогда
			If CurrentDate() < pCheckOutDate Тогда
				vFrm.SelTime = cmExtractTime(CurrentDate());
			Else
				vFrm.SelTime = cmExtractTime(pCheckOutDate);
			EndIf;
		Else
			vFrm.SelTime = cmExtractTime(pCheckOutDate);
		EndIf;
	Else
		vFrm.SelDate = BegOfDay(CurrentDate());
		vFrm.SelTime = cmExtractTime(CurrentDate());
	EndIf;
	vFrm.SelDescription = NStr("ru='Укажите дату и время выселения...';
	                           |de='Geben Sie das Datum und die Zeit der Ausweisung an…'; 
							   |en='Input check-out date and time please...'");
	If НЕ cmCheckUserPermissions("HavePermissionToEditCheckOutDateTime") Тогда
		vFrm.SelIsProtected = True;
	EndIf;
	vCheckOutDateTime = vFrm.DoModal();
	// Check check out date and time entered
	If НЕ ЗначениеЗаполнено(vCheckOutDateTime) Тогда
		Предупреждение(NStr("ru='Процедура выселения отменена!';
		                  |de='Das Ausweisungsverfahren wurde abgebrochen'; 
						  |en='Check-out procedure is canceled!'"));
		Return vCheckOutDateTime;
	EndIf;
	While vCheckOutDateTime < pCheckInDate Do
		Предупреждение(NStr("ru='Вы ввели дату и время выселения, которые раньше чем дата и время заезда!';
		                  |de='Sie haben ein Abreisedatum und eine Abreisezeit eingegeben, die vor dem Anreisedatum und der Anreisezeit liegen!'; 
						  |en='You have entered check-out date and time that are earlier then check-in date and time!'"));
		vCheckOutDateTime = cmGetCheckOutDate(pCheckInDate, pCheckOutDate);
		If НЕ ЗначениеЗаполнено(vCheckOutDateTime) Тогда
			Return vCheckOutDateTime;
		EndIf;
	EndDo;
	If НЕ cmCheckUserPermissions("HavePermissionToSetCheckOutDateInThePast") Тогда
		vAllowedCheckOutDelayTime = 1;
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			vPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
			If ЗначениеЗаполнено(vPermissionGroup) Тогда
				If vPermissionGroup.AllowedCheckOutDelayTime > 0 Тогда
					vAllowedCheckOutDelayTime = vPermissionGroup.AllowedCheckOutDelayTime;
				EndIf;
			EndIf;
		EndIf;
		vTimeDiff = Round((CurrentDate() - vCheckOutDateTime)/3600, 3);
		While vTimeDiff > vAllowedCheckOutDelayTime Do
			Предупреждение(NStr("ru='Вы ввели дату выселения в прошлом. У вас есть права на выселение только текущей или будущей датой!';
			                  |de='Sie haben ein Räumungsdatum angegeben, das in der Vergangenheit liegt. Sie sind berechtigt, eine Räumung nur am aktuellen oder künftigen Datum vorzunehmen!'; 
			                  |en='You have entered check-out date in the past. You have rights to do check-out by current or future dates only!'"));
			vCheckOutDateTime = cmGetCheckOutDate(pCheckInDate, pCheckOutDate);
			If НЕ ЗначениеЗаполнено(vCheckOutDateTime) Тогда
				Return vCheckOutDateTime;
			EndIf;
			vTimeDiff = Round((CurrentDate() - vCheckOutDateTime)/3600, 3);
		EndDo;
	EndIf;
	Return vCheckOutDateTime; 
EndFunction //cmGetCheckOutDate

//-----------------------------------------------------------------------------
// Description: Checks user permission to issue door lock key card for the ГруппаНомеров
// Parameters: Door lock system driver data processor object
// Return value: True if operation is allowed, false if not
//-----------------------------------------------------------------------------
Function cmCheckPermissionsToIssueKeyCards(pDriverObj) Экспорт
	If НЕ cmCheckUserPermissions("HavePermissionToChangeCheckOutDateInDoorLockSystem") Тогда
		vParentDoc = pDriverObj.ДокОснование;
		If ЗначениеЗаполнено(vParentDoc) And TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Тогда
			If НЕ ЗначениеЗаполнено(vParentDoc.СтатусРазмещения) Or ЗначениеЗаполнено(vParentDoc.СтатусРазмещения) And (НЕ vParentDoc.СтатусРазмещения.ЭтоГости And vParentDoc.СтатусРазмещения.IsActive Or НЕ vParentDoc.СтатусРазмещения.IsActive) Тогда
				vMessage = NStr("en='You do not have rights to issue key cards for checked-out guests!'; 
				                |de='Sie haben keine Rechte an Schlüsselkarten für die checked-out Gäste ausgeben!'; 
								|ru='У вас нет прав выписывать ключи выехавшим гостям!'");
				WriteLogEvent(NStr("en='DoorLockSystem.Error';ru='СистемаЭлектронныхЗамков.Ошибка';de='DoorLockSystem.Error'"), EventLogLevel.Warning, pDriverObj.Metadata(), pDriverObj.Клиент, vMessage);
				Предупреждение(vMessage + Chars.LF + NStr("en='Operation will be canceled!';ru='Операция будет отменена!';de='Die Operation wird abgebrochen!'"));
				Return False;
			EndIf;
		EndIf;
	EndIf;
	vBalances = cmGetClientRoomBalances(New Boundary(BegOfDay(pDriverObj.ДатаВыезда), BoundaryType.Excluding), pDriverObj.НомерРазмещения, pDriverObj.Клиент);
	For Each vBalancesRow In vBalances Do
		If (vBalancesRow.ClientSumBalance + vBalancesRow.ClientLimitBalance) > 0 Тогда
			vMessage = NStr("en='Client has debt on " + Format(pDriverObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + " date for the " + СокрЛП(pDriverObj.НомерРазмещения) + " ГруппаНомеров!'; 
			                |de='Client has debt on " + Format(pDriverObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + " date for the " + СокрЛП(pDriverObj.НомерРазмещения) + " ГруппаНомеров!'; 
							|ru='На дату " + Format(pDriverObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + " у гостя в номере " + СокрЛП(pDriverObj.НомерРазмещения) + " есть задолженность!'");
			If НЕ cmCheckUserPermissions("HavePermissionToIssueKeyCardsForGuestsWithDebtsOnKeyValidToDate") Тогда
				WriteLogEvent(NStr("en='DoorLockSystem.Error';ru='СистемаЭлектронныхЗамков.Ошибка';de='DoorLockSystem.Error'"), EventLogLevel.Warning, pDriverObj.Metadata(), pDriverObj.Клиент, vMessage);
				Предупреждение(vMessage + Chars.LF + NStr("en='Operation will be canceled!';ru='Операция будет отменена!';de='Die Operation wird abgebrochen!'"));
				Return False;
			Else
				WriteLogEvent(NStr("en='KeyCardEvents.KeyIssuedWithBalance'; de='KeyCardEvents.KeyIssuedWithBalance'; ru='СигналыПоКлючам.ПериодДействияКлючаНеОплачен'"), EventLogLevel.Warning, pDriverObj.Metadata(), pDriverObj.Клиент, vMessage);
				Break;
			EndIf;
		EndIf;
	EndDo;
	If НЕ cmCheckUserPermissions("HavePermissionToIssueKeyCardsForGuestsWithDebtsOnKeyValidToDate") Тогда
		If ЗначениеЗаполнено(pDriverObj.ВидРазмещения) Тогда
			If pDriverObj.ВидРазмещения.ТипРазмещения = Перечисления.ВидыРазмещений.AdditionalBed Or
			   pDriverObj.ВидРазмещения.ТипРазмещения = Перечисления.ВидыРазмещений.Together Тогда
				vMessage = NStr("en='You do not have rights to issue keys to guests with " + СокрЛП(pDriverObj.ВидРазмещения) + " Размещение type! Operation will be canceled!'; 
				                |de='You do not have rights to issue keys to guests with " + СокрЛП(pDriverObj.ВидРазмещения) + " Размещение type! Operation will be canceled!'; 
				                |ru='У вас нет прав выписывать ключи гостям с видом размещения " + СокрЛП(pDriverObj.ВидРазмещения) + "! Операция будет отменена!'");
				WriteLogEvent(NStr("en='DoorLockSystem.Error';ru='СистемаЭлектронныхЗамков.Ошибка';de='DoorLockSystem.Error'"), EventLogLevel.Warning, pDriverObj.Metadata(), pDriverObj.Клиент, vMessage);
				Предупреждение(vMessage);
				Return False;
			EndIf;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(pDriverObj.СчетПроживания) And pDriverObj.СчетПроживания.IsClosed Тогда
		WriteLogEvent(NStr("en='KeyCardEvents.IssueKeyForClosedFolioRequest'; de='KeyCardEvents.IssueKeyForClosedFolioRequest'; ru='СигналыПоКлючам.ЗапросНаВыдачуКлючаПоЗакрытомуФолио'"), EventLogLevel.Warning, pDriverObj.Metadata(), pDriverObj.Клиент, СокрЛП(pDriverObj.Клиент) + ", " + СокрЛП(pDriverObj.НомерРазмещения) + ", " + Format(pDriverObj.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(pDriverObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'"));
	EndIf;
	WriteLogEvent(NStr("en='KeyCardEvents.IssueKeyRequest'; de='KeyCardEvents.IssueKeyRequest'; ru='СигналыПоКлючам.ЗапросНаВыдачуКлюча'"), EventLogLevel.Information, pDriverObj.Metadata(), pDriverObj.Клиент, СокрЛП(pDriverObj.Клиент) + ", " + СокрЛП(pDriverObj.НомерРазмещения) + ", " + Format(pDriverObj.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(pDriverObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'"));
	Return True;
EndFunction //cmCheckPermissionsToIssueKeyCards

//-----------------------------------------------------------------------------
// Description: Check should we turn "Fix reservation conditions" flag on while
//              checking-in guest
// Parameters: Accommodation object where to turn flag on, Reservation document reference
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmCheckFixReservationConditionsAtCheckIn(pAccObj, pResRef) Экспорт 
	If НЕ pAccObj.FixReservationConditions And ЗначениеЗаполнено(pAccObj.Гостиница) And НЕ pAccObj.Гостиница.UseReservationTimeForCheckIn Тогда
		If ЗначениеЗаполнено(pResRef.ReservationStatus) And НЕ pResRef.ReservationStatus.FixReservationConditions Тогда
			vDoAskAboutFixReservationConditions = True;
			If ЗначениеЗаполнено(pAccObj.ПутевкаКурсовка) And (pAccObj.ПутевкаКурсовка.FixProductPeriod Or pAccObj.ПутевкаКурсовка.FixPlannedPeriod Or pAccObj.ПутевкаКурсовка.FixProductCost) Тогда
				vDoAskAboutFixReservationConditions = False;
			EndIf;
			If vDoAskAboutFixReservationConditions Тогда
				If BegOfDay(CurrentDate()) > BegOfDay(pResRef.CheckInDate) Тогда
					vQueryText = NStr("en='Guest has late check-in (was expected on " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление for this delay?';
					                  |de='Guest has late check-in (was expected on " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление for this delay?';
									  |ru='Гость заезжает позже чем планировал (ожидаемые дата и время заезда " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ")! Нужно ли начислить штраф за опоздание?'");
					If DoQueryBox(vQueryText, QuestionDialogMode.YesNo, , DialogReturnCode.No) = DialogReturnCode.Yes Тогда
						pAccObj.FixReservationConditions = True;
						pAccObj.pmCalculateServices();
					EndIf;
				ElsIf BegOfDay(CurrentDate()) < BegOfDay(pResRef.CheckInDate) Тогда
					If ЗначениеЗаполнено(pResRef.PlannedPaymentMethod) And pResRef.PlannedPaymentMethod.IsByBankTransfer Тогда
						If ЗначениеЗаполнено(pResRef.Тариф) Тогда
							If НЕ pResRef.Тариф.IsRackRate Тогда
								vQueryText = NStr("en='Guest has early check-in (is expected on " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление early check-in days by rack rate?';
								                  |de='Guest has early check-in (is expected on " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление early check-in days by rack rate?';
												  |ru='Гость заезжает раньше чем планировал (дата и время заезда " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ")! Нужно ли начислить стоимость дней проживания до даты планируемого заезда по базовому тарифу?'");
								If DoQueryBox(vQueryText, QuestionDialogMode.YesNo, , DialogReturnCode.No) = DialogReturnCode.Yes Тогда
									pAccObj.FixReservationConditions = True;
									pAccObj.pmCalculateServices();
								EndIf;
							Else
								vQueryText = NStr("en='Guest has early check-in (is expected on " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ", Бронирование is expected to be paid by bank transfer)! Should we Начисление Клиент for early check-in days or let those days be payed by Контрагент?';
								                  |de='Guest has early check-in (is expected on " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ", Бронирование is expected to be paid by bank transfer)! Should we Начисление Клиент for early check-in days or let those days be payed by Контрагент?';
												  |ru='Гость заезжает раньше чем планировал (дата и время заезда " + Format(pResRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + ", бронь оплачивается организацией)! Нужно ли начислить стоимость дней проживания до даты планируемого заезда на самого гостя? Если ответить <Нет>, то стоимость дней раннего заезда попадет в счет организации.'");
								If DoQueryBox(vQueryText, QuestionDialogMode.YesNo, , DialogReturnCode.No) = DialogReturnCode.Yes Тогда
									pAccObj.FixReservationConditions = True;
									pAccObj.pmCalculateServices();
								EndIf;
							EndIf;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //cmCheckFixReservationConditionsAtCheckIn

//-----------------------------------------------------------------------------
// Description: Check should we turn "Fix reservation conditions" flag on while
//              checking-out guest
// Parameters: Accommodation object where to turn flag on, Reservation document reference
// Return value: None
//-----------------------------------------------------------------------------
Function cmCheckFixReservationConditionsAtCheckOut(pCheckOutDate, pResRef) Экспорт 
	vFixReservationConditions = False;
	If ЗначениеЗаполнено(pResRef.ReservationStatus) And НЕ pResRef.ReservationStatus.FixReservationConditions Тогда
		If ЗначениеЗаполнено(pResRef.PlannedPaymentMethod) And pResRef.PlannedPaymentMethod.IsByBankTransfer Тогда
			If BegOfDay(pCheckOutDate) < BegOfDay(pResRef.ДатаВыезда) Тогда
				vQueryText = NStr("en='Guest has early check-out (is expected on " + Format(pResRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление early check-out days according to the Бронирование?';
				                  |de='Guest has early check-out (is expected on " + Format(pResRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление early check-out days according to the Бронирование?';
								  |ru='Гость выезжает раньше чем ожидалось по брони (дата и время выезда по брони " + Format(pResRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + ")! Нужно ли начислить стоимость дней проживания до даты планируемого выезда?'");
				If DoQueryBox(vQueryText, QuestionDialogMode.YesNo, , DialogReturnCode.No) = DialogReturnCode.Yes Тогда
					vFixReservationConditions = True;
				EndIf;
			ElsIf (pCheckOutDate - pResRef.ДатаВыезда) > 3600 Тогда
				vQueryText = NStr("en='Guest has late check-out (was expected on " + Format(pResRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление late check-out by rack rate?';
				                  |de='Guest has late check-out (was expected on " + Format(pResRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + ")! Should we Начисление late check-out by rack rate?';
								  |ru='Гость выезжает позже чем ожидалось по брони (дата и время выезда по брони " + Format(pResRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + ")! Нужно ли начислить стоимость позднего выезда по базовому тарифу?'");
				If DoQueryBox(vQueryText, QuestionDialogMode.YesNo, , DialogReturnCode.No) = DialogReturnCode.Yes Тогда
					vFixReservationConditions = True;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	Return vFixReservationConditions;
EndFunction //cmCheckFixReservationConditionsAtCheckOut

//-----------------------------------------------------------------------------
// Description: Extends period of stay of all hotel in-house guests to the next 
//              hour from current time. I.e. if current time is 15:23 then period 
//              of stay will be extended to 16:00
// Parameters: Гостиница, period of stay of all in-house guests from this hotel will 
//             be extended
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmExtendInHouseGuestsPeriodOfStay(Val pHotel = Неопределено, Val pFreeOfChargeMinutes = 0, pIsInteractive = True) Экспорт
	// Fill hotel
	If pHotel = Неопределено Тогда
		If НЕ ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
			Return;
		EndIf;
		pHotel = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	// Check interactive mode
	If pIsInteractive = Неопределено Тогда
		pIsInteractive = True;
	EndIf;
	// Fill target check-out time 
	vCheckOutDate = CurrentDate();
	// Check free of charge minutes
	If pFreeOfChargeMinutes = 0 Тогда
		pFreeOfChargeMinutes = 20;
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			vPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
			If ЗначениеЗаполнено(vPermissionGroup) Тогда
				If vPermissionGroup.AllowedCheckOutDelayTime > 0 And vPermissionGroup.AllowedCheckOutDelayTime < 1 Тогда
					pFreeOfChargeMinutes = Round(vPermissionGroup.AllowedCheckOutDelayTime * 60, 0);
				ElsIf vPermissionGroup.RoomExaminationFreeOfChargeTime <> 0 Тогда
					pFreeOfChargeMinutes = Round(vPermissionGroup.RoomExaminationFreeOfChargeTime * 60, 0);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	// Build list of accommodations to process
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE (&qHotelIsEmpty
	|			OR Размещение.Гостиница = &qHotel)
	|	AND Размещение.Posted
	|	AND Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.СтатусРазмещения.ЭтоГости
	|	AND DATEDIFF(Размещение.ДатаВыезда, &qCheckOutDate, MINUTE) >= &qFreeOfChargePeriodInMinutes
	|
	|ORDER BY
	|	Размещение.PointInTime";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(pHotel));
	vQry.SetParameter("qCheckOutDate", vCheckOutDate);
	vQry.SetParameter("qFreeOfChargePeriodInMinutes", pFreeOfChargeMinutes);
	vDocs = vQry.Execute().Unload();
	For Each vDocsRow In vDocs Do
		Try
			BeginTransaction(DataLockControlMode.Managed);
			vAccObj = vDocsRow.Ref.GetObject();
			If vAccObj.pmGetNextAccommodationInChain() = Неопределено Тогда
				vAccObj.ДатаВыезда = BegOfDay(vAccObj.ДатаВыезда) + (Hour(vAccObj.ДатаВыезда) + 1) * 3600 + Minute(vAccObj.ДатаВыезда) * 60;
				vAccObj.Продолжительность = vAccObj.pmCalculateDuration();
				vAccObj.pmCalculateServices();
				vAccObj.Write(DocumentWriteMode.Posting);
				vAccObj.pmWriteToAccommodationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			EndIf;
			CommitTransaction();
		Except
			vMessage = ErrorDescription();
			WriteLogEvent(NStr("en='DataProcessor.ExtendInHouseGuestsPeriodOfStay';ru='Обработка.ПродлитьПериодПроживанияГостей';de='DataProcessor.ExtendInHouseGuestsPeriodOfStay'"), EventLogLevel.Warning, vAccObj.Metadata(), vAccObj.Ref, vMessage);
			If TransactionActive() Тогда
				RollbackTransaction();
			EndIf;
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Attention);
			EndIf;
		EndTry;
	EndDo;
	// Build list of accommodations to checking out
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Размещение.Ref AS Ref,
	|	Размещение.НомерРазмещения AS НомерРазмещения,
	|	Размещение.Клиент.FullName AS Клиент,
	|	Размещение.CheckInDate AS CheckInDate,
	|	Размещение.ДатаВыезда AS ДатаВыезда
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	(&qHotelIsEmpty
	|			OR Размещение.Гостиница = &qHotel)
	|	AND Размещение.Posted
	|	AND Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.СтатусРазмещения.ЭтоГости
	|	AND (Размещение.ВидРазмещения.ТипРазмещения = &qRoom
	|			OR Размещение.ВидРазмещения.ТипРазмещения = &qBeds)
	|	AND Размещение.ДатаВыезда < &qCheckOutDate
	|
	|ORDER BY
	|	Размещение.PointInTime";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(pHotel));
	vQry.SetParameter("qCheckOutDate", vCheckOutDate+900);
	vQry.SetParameter("qRoom", Перечисления.ВидыРазмещений.НомерРазмещения);
	vQry.SetParameter("qBeds", Перечисления.ВидыРазмещений.Beds);
	vAccDocs = vQry.Execute().Unload();
	If vAccDocs.Count()>0 Тогда
		vFrm = ПолучитьФорму("CommonForm.упрГостиНаВыезд",,, "упрГостиНаВыезд");
		If НЕ vFrm.IsOpen() Тогда
			For Each vDocsRow In vAccDocs Do
				vNewStr = vFrm.Docs.Add();
				vNewStr.Ref = vDocsRow.Ref;
				vNewStr.НомерРазмещения = vDocsRow.ГруппаНомеров;
				vNewStr.Клиент = vDocsRow.Guest;
				vNewStr.CheckInDate = vDocsRow.CheckInDate;
				vNewStr.ДатаВыезда = vDocsRow.CheckOutDate;
				If vDocsRow.CheckOutDate < CurrentDate() Тогда
					vNewStr.Icon = PictureLib.RedCube;
				Else
					vNewStr.Icon = PictureLib.YellowCube;
				EndIf;
			EndDo;
			vFrm.DoModal();
		EndIf;
	EndIf;
КонецПроцедуры //cmExtendInHouseGuestsPeriodOfStay

//-----------------------------------------------------------------------------
// Description: Checks if guest has to get its discount card according to the hotel rules
// Parameters: Client reference, Accommodation document object
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmIssueDiscountCard(pGuest, pDocObj) Экспорт
	// Run query to get discount card issue rules
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ПравилаВыдСкидКарт.AccumulatingDiscountType AS AccumulatingDiscountType,
	|	ПравилаВыдСкидКарт.ResourceFrom AS ResourceFrom,
	|	ПравилаВыдСкидКарт.ResourceTo AS ResourceTo,
	|	ПравилаВыдСкидКарт.ТипСкидки,
	|	ПравилаВыдСкидКарт.ТипКлиента,
	|	ПравилаВыдСкидКарт.ValidFrom,
	|	ПравилаВыдСкидКарт.ValidTo,
	|	ПравилаВыдСкидКарт.Notification,
	|	ПравилаВыдСкидКарт.ExternalAlgorithm,
	|	ПравилаВыдСкидКарт.UseResourcesPayedAsIndividual,
	|	ПравилаВыдСкидКарт.UseResourcesPayedByRackRates
	|FROM
	|	InformationRegister.ПравилаВыдСкидКарт AS ПравилаВыдСкидКарт
	|
	|ORDER BY
	|	ПравилаВыдСкидКарт.AccumulatingDiscountType.Order,
	|	ResourceFrom,
	|	ResourceTo";
	vRules = vQry.Execute().Unload();
	If vRules.Count() = 0 Тогда
		// No rules found
		Return;
	EndIf;
	// Get client object
	vClientObj = pGuest.GetObject();
	// Initialize some vars
	vPeriodTo = CurrentDate();
	If ЗначениеЗаполнено(pDocObj.Гостиница) And ЗначениеЗаполнено(pDocObj.Гостиница.DateToGetBonusBalance) Тогда
		If pDocObj.Гостиница.DateToGetBonusBalance = Перечисления.DatesToGetBonusBalance.CheckInDate Тогда
			If TypeOf(pDocObj) = Type("DocumentObject.БроньУслуг") Тогда
				vPeriodTo = BegOfDay(pDocObj.DateTimeFrom) - 1;
			Else
				vPeriodTo = BegOfDay(pDocObj.CheckInDate) - 1;
			EndIf;
		ElsIf pDocObj.Гостиница.DateToGetBonusBalance = Перечисления.DatesToGetBonusBalance.ДатаВыезда Тогда
			If TypeOf(pDocObj) = Type("DocumentObject.БроньУслуг") Тогда
				vPeriodTo = EndOfDay(pDocObj.DateTimeTo);
			Else
				vPeriodTo = EndOfDay(pDocObj.ДатаВыезда);
			EndIf;
		EndIf;
	EndIf;
	// Try to find rule suitable for the client
	vClientResource = 0;
	vClientRule = Неопределено;
	vCurAccumulatingDiscountType = Неопределено;
	For Each vRulesRow In vRules Do
		// Get type of client stats to check
		If НЕ ЗначениеЗаполнено(vRulesRow.AccumulatingDiscountType) Тогда
			// Wrong rule record
			Continue;
		EndIf;
		If vCurAccumulatingDiscountType <> vRulesRow.AccumulatingDiscountType Тогда
			vCurAccumulatingDiscountType = vRulesRow.AccumulatingDiscountType;
			vClientResource = 0;
			// Check for an external algorithm
			vExternalDataProcessor = vRulesRow.ExternalAlgorithm;
			If ЗначениеЗаполнено(vExternalDataProcessor) Тогда
				If vExternalDataProcessor.ExternalProcessingType <> Перечисления.ExternalProcessingTypes.Algorithm Тогда
					ВызватьИсключение NStr("en='Wrong external extension type! Should be <algorithm>';
					           |ru='Неверно указан тип внешнего модуля! Должен быть <Алгоритм>';
							   |de='Der Typ des externen Moduls ist falsch angegeben! Es muss einen <Algorithmus> geben'");
				Else
					vExternalAlgorithm = TrimR(vExternalDataProcessor.Algorithm);
					If IsBlankString(vExternalAlgorithm) Тогда
						ВызватьИсключение NStr("en='External algorithm is empty!';ru='Внешний алгоритм не указан!';de='Externer Algorithmus nicht angegeben!'");
					Else
						Execute(vExternalAlgorithm);
					EndIf;
				EndIf;
			Else
				// Get client statistics
				If vCurAccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.ByNumberOfGuestVisits Тогда
					vClientResource = vClientObj.pmCountNumberOfCheckIns(, vPeriodTo, vRulesRow.UseResourcesPayedAsIndividual, vRulesRow.UseResourcesPayedByRackRates);
				ElsIf vCurAccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.ByAccommodationDuration Тогда
					vClientResource = vClientObj.pmCountNumberOfNights(, vPeriodTo, vRulesRow.UseResourcesPayedAsIndividual, vRulesRow.UseResourcesPayedByRackRates);
				ElsIf vCurAccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.ByServicesTotalSum Тогда
					vRevenues = vClientObj.pmGetClientRevenueStatistics(, vPeriodTo, vRulesRow.UseResourcesPayedAsIndividual, vRulesRow.UseResourcesPayedByRackRates);
					vClientResource = vRevenues.Total("SalesTurnover");
				EndIf;
			EndIf;
		EndIf;
		If vRulesRow.ResourceFrom <= vClientResource And (vRulesRow.ResourceTo = 0 Or vRulesRow.ResourceTo > vClientResource) Тогда
			If vClientRule = Неопределено Тогда
				vClientRule = vRulesRow;
			Else
				If ЗначениеЗаполнено(vClientRule.ТипСкидки) And ЗначениеЗаполнено(vRulesRow.DiscountType) And vRulesRow.DiscountType.ПорядокСортировки > vClientRule.ТипСкидки.ПорядокСортировки Тогда
					vClientRule = vRulesRow;
				EndIf;
			EndIf;
		EndIf;
	EndDo;
	If vClientRule = Неопределено Тогда
		// Rule was not found
		Return;
	EndIf;
	// Try to find discount card that was already issued to this guest
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	DiscountCards.Ref
	|FROM
	|	Catalog.DiscountCards AS DiscountCards
	|WHERE
	|	NOT DiscountCards.DeletionMark
	|	AND DiscountCards.Клиент = &qClient
	|	AND DiscountCards.ТипКлиента = &qClientType
	|	AND DiscountCards.ValidFrom = &qValidFrom
	|	AND DiscountCards.ValidTo = &qValidTo
	|
	|ORDER BY
	|	DiscountCards.Code";
	vQry.SetParameter("qClient", pGuest);
	vQry.SetParameter("qClientType", vClientRule.ТипКлиента);
	vQry.SetParameter("qValidFrom", vClientRule.ValidFrom);
	vQry.SetParameter("qValidTo", vClientRule.ValidTo);
	vClientDiscountCards = vQry.Execute().Unload();
	// Check should we show notification or not
	vDiscountCard = Неопределено;
	vDoNotify = False;
	If vClientDiscountCards.Count() = 0 Тогда
		vDoNotify = True;
	Else
		vDiscountCard = vClientDiscountCards.Get(0).Ref;
		If vDiscountCard.ТипСкидки <> vClientRule.ТипСкидки Тогда
			vCardSortCode = 0;
			If ЗначениеЗаполнено(vDiscountCard.ТипСкидки) Тогда
				vCardSortCode = vDiscountCard.ТипСкидки.ПорядокСортировки;
			EndIf;
			vRuleSortCode = 0;
			If ЗначениеЗаполнено(vClientRule.ТипСкидки) Тогда
				vRuleSortCode = vClientRule.ТипСкидки.ПорядокСортировки;
			EndIf;
			If vRuleSortCode > vCardSortCode Тогда
				vDoNotify = True;
			EndIf;
		EndIf;
	EndIf;
	// Open form with "You have to issue discount card!" message notification
	If vDoNotify Тогда
		
		If vDiscountCard <> Неопределено Тогда
			vFrm = vDiscountCard.ПолучитьФорму("IssueDiscountCard", , pGuest);
		Else			
			vFrm = Справочники.DiscountCards.ПолучитьФорму("IssueDiscountCard", , pGuest);
		EndIf;
		vFrm.Клиент = pGuest;
		vFrm.ТипСкидки = vClientRule.ТипСкидки;
		vFrm.ТипКлиента = vClientRule.ТипКлиента;
		vFrm.ValidFrom = vClientRule.ValidFrom;
		vFrm.ValidTo = vClientRule.ValidTo;
		vFrm.Notification = vClientRule.Notification;
		vDiscountCard = vFrm.DoModal();
		
		If vDiscountCard <> Неопределено Тогда
			If TypeOf(pDocObj) = Type("DocumentObject.Размещение") And ЗначениеЗаполнено(pDocObj.СтатусРазмещения) And pDocObj.СтатусРазмещения.ЭтоГости Or
			   TypeOf(pDocObj) = Type("DocumentObject.Бронирование") And ЗначениеЗаполнено(pDocObj.ReservationStatus) And pDocObj.ReservationStatus.IsActive Or 
			   TypeOf(pDocObj) = Type("DocumentObject.БроньУслуг") And ЗначениеЗаполнено(pDocObj.ResourceReservationStatus) And pDocObj.ResourceReservationStatus.IsActive Тогда
				pDocObj.ДисконтКарт = vDiscountCard;
				// Set discounts
				pDocObj.pmSetDiscounts();
				// Automatic services list calculation	
				pDocObj.pmCalculateServices();
				// Save document
				pDocObj.Write(DocumentWriteMode.Posting);
				// Save to document change history
				If TypeOf(pDocObj) = Type("DocumentObject.БроньУслуг") Тогда
					pDocObj.pmWriteToResourceReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
				ElsIf TypeOf(pDocObj) = Type("DocumentObject.Размещение") Тогда
					pDocObj.pmWriteToAccommodationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
				Else
					pDocObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
				EndIf;
			EndIf;
		EndIf;
		// Оповестить change in discount cards
		Оповестить("ДисконтКарт.Write", vDiscountCard);
	Else
		If vClientDiscountCards.Count() > 0 Тогда
			Предупреждение(NStr("en='Discount card has already been issued to the guest!'; ru='Дисконтная карта гостю уже выдана!'; de='Rabatt-Karte bereits zu Gast ausgestellt worden!'"));
		EndIf;
	EndIf;
КонецПроцедуры //cmIssueDiscountCard
