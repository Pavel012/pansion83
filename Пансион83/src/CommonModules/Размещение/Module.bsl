//-----------------------------------------------------------------------------
// Description: Returns customers with description starting from the given text
// Parameters: First letters of Контрагент name to be searched, Maximum number of 
//             customers to return
// Return value: Value table with customers found
//-----------------------------------------------------------------------------
Function cmGetCustomersList(pText, pMaxNumber = 10) Экспорт
	// Build and run query
	qGetList = New Query;
	qGetList.Text = 
	"SELECT DISTINCT TOP " + pMaxNumber + "
	|	Customers.Code,
	|	Customers.Description,
	|	Customers.ЮрИмя,
	|	Customers.ИНН,
	|	Customers.Ref
	|FROM
	|	Catalog.Customers AS Customers
	|WHERE
	|	Customers.IsFolder = False AND
	|	Customers.DeletionMark = False AND
	|	Customers.Description LIKE &qName
	|ORDER BY Description";
	qGetList.SetParameter("qName", "%" + pText + "%");
	vList = qGetList.Execute().Unload();
	Return vList;
EndFunction //cmGetCustomersList

//-----------------------------------------------------------------------------
// Description: Returns customers presentation string that is composed of 
//              Контрагент legacy name and Контрагент ИНН
// Parameters: Value table row or structure with Контрагент's data 
// Return value: String, Контрагент presentation
//-----------------------------------------------------------------------------
Function cmGetCustomerPresentation(pRow) Экспорт
	vD = СокрЛП(pRow.Description);
	vLN = СокрЛП(pRow.LegacyName);
	vTIN = СокрЛП(pRow.TIN);
	vN = ?(IsBlankString(vLN), vD, vLN) + " (" + cmGetDocumentNumberPresentation(pRow.Code) + " - " + СокрЛП(pRow.Description) + ")";
	Return vN + ?(IsBlankString(vTIN), "", NStr("ru = ', ИНН: '; en = ', ИНН: '; de = ', ИНН: '") + vTIN);
EndFunction //cmGetCustomerPresentation

//-----------------------------------------------------------------------------
// Description: Standard Контрагент control text edit end event processing routine
// Parameters: Object, Form, Контрагент control, Text being entered, Контрагент 
//             reference to return, Standard processing flag
// Return value: True if Контрагент was found and was set to the control value, 
//               False if not
//-----------------------------------------------------------------------------
Function cmCustomerTextEditEnd(pObject, pForm, pControl, pText, pValue, pStandardProcessing) Экспорт
	vIsChanged = False;
	vText = СокрЛП(pText);
	vTab = cmGetCustomersList(vText, 10);
	If vTab.Count() = 1 Тогда
		pStandardProcessing = False;
		vRow = vTab.Get(0);
		pValue = vRow.Ref;
		vIsChanged = True;
	ElsIf vTab.Count() > 1 Тогда
		pStandardProcessing = False;
		vList = New СписокЗначений;
		For Each vRow In vTab Do
			vList.Add(vRow.Ref, cmGetCustomerPresentation(vRow));
		EndDo;
		vRef = pForm.ChooseFromList(vList, pControl);
		If vRef <> Неопределено Тогда
			pValue = vRef.Value;
			vIsChanged = True;
		EndIf;
	EndIf;
	Return vIsChanged;
EndFunction //cmCustomerTextEditEnd

//-----------------------------------------------------------------------------
// Description: Returns list of guest groups found by code or hotel
// Parameters: Guest group code as Number or String, Гостиница, Maximum number of records to return
// Return value: Value table of guest groups found
//-----------------------------------------------------------------------------
Function cmGetGuestGroupsList(pCode, pHotel, pMaxNumber = 10) Экспорт
	// Build and run query
	qGetList = New Query;
	qGetList.Text = 
	"SELECT DISTINCT TOP " + pMaxNumber + "
	|	GuestGroups.Code,
	|	GuestGroups.Description,
	|	GuestGroups.Parent,
	|	GuestGroups.Ref
	|FROM
	|	Catalog.GuestGroups AS GuestGroups
	|WHERE
	|	GuestGroups.Owner = &qHotel AND 
	|	GuestGroups.Code = &qCode AND 
	|	GuestGroups.IsFolder = False AND
	|	GuestGroups.DeletionMark = False
	|ORDER BY Description";
	qGetList.SetParameter("qHotel", pHotel);
	qGetList.SetParameter("qCode", Number(pCode));
	vList = qGetList.Execute().Unload();
	Return vList;
EndFunction //cmGetGuestGroupsList

//-----------------------------------------------------------------------------
// Description: Returns guest group presentation string being built from code, 
//              group description and group remarks
// Parameters: Value table row or Structure with guest group data
// Return value: Guest group presentation string
//-----------------------------------------------------------------------------
Function cmGetGuestGroupPresentation(pRow) Экспорт
	vP = "";
	If ЗначениеЗаполнено(pRow.Parent) Тогда
		vP = СокрЛП(pRow.Parent.Description);
	EndIf;
	vC = СокрЛП(pRow.Code);
	vD = СокрЛП(pRow.Description);
	vR = СокрЛП(pRow.Ref.Примечания);
	vN = ?(IsBlankString(vP), "", vP + "/") + vC + ?(vD="", "", " (" + vD + ")") + ?(vR="", "", ", " + vR);
	Return vN;
EndFunction //cmGetGuestGroupPresentation

//-----------------------------------------------------------------------------
// Description: Standard guest group control text edit end event processing routine
// Parameters: Object, Form, Guest group control, Text being entered, Guest group 
//             reference to return, Standard processing flag
// Return value: True if Guest group was found and was set to the control value, 
//               False if not
//-----------------------------------------------------------------------------
Function cmGuestGroupTextEditEnd(pObject, pForm, pControl, pText, pValue, pStandardProcessing) Экспорт
	vIsChanged = False;
	pStandardProcessing = False;
	vText = СокрЛП(pText);
	vTab = cmGetGuestGroupsList(vText, pObject.Гостиница, 10);
	If vTab.Count() = 1 Тогда
		vRow = vTab.Get(0);
		pValue = vRow.Ref;
		vIsChanged = True;
	ElsIf vTab.Count() > 1 Тогда
		vList = New СписокЗначений;
		For Each vRow In vTab Do
			vList.Add(vRow.Ref, cmGetGuestGroupPresentation(vRow));
		EndDo;
		vRef = pForm.ChooseFromList(vList, pControl);
		If vRef <> Неопределено Тогда
			pValue = vRef.Value;
			vIsChanged = True;
		EndIf;
	ElsIf ЗначениеЗаполнено(pObject.Гостиница) And pObject.Гостиница.AssignReservationGuestGroupsManually Тогда
		Try
			vGroupObj = Справочники.GuestGroups.CreateItem();
			vGroupObj.Code = Number(pText);
			vGroupObj.Owner = pObject.Гостиница;
			vGuestGroupFolder = pObject.Гостиница.GetObject().pmGetGuestGroupFolder();
			If ЗначениеЗаполнено(vGuestGroupFolder) Тогда
				vGroupObj.Parent = vGuestGroupFolder;
			EndIf;
			If ЗначениеЗаполнено(vGroupObj.Owner) Тогда
				vGroupObj.OneCustomerPerGuestGroup = vGroupObj.Owner.OneCustomerPerGuestGroup;
			EndIf;
			vGroupObj.Write();
			pValue = vGroupObj.Ref;
			vIsChanged = True;
		Except
		EndTry;
	Else
		pStandardProcessing = True;
	EndIf;
	Return vIsChanged;
EndFunction //cmGuestGroupTextEditEnd

//-----------------------------------------------------------------------------
// Description: Returns client's list filtered by client name, identity document 
//              data and phone number
// Parameters: Client last name string, Client first name string, Client second name string,
//             Identity document number string, Identity document series string, Phone number string,
//             Boolean - Whether to use substring search for the client name (search requested string 
//             in any part of the name) or use search comparing first letters of name with requested 
//             string
// Return value: Value table with clients found
//-----------------------------------------------------------------------------
Function cmGetClientsList(pLastName, pFirstName, pSecondName, pIdentityDocNumber, pIdentityDocSeries, pPhone, pEMail, pUseSubstringSearch = False) Экспорт
	// Build and run query
	qGetList = New Query;
	qGetList.Text = 
	"SELECT 
	|	Clients.Ref,
	|	Clients.Description,
	|	Clients.Фамилия,
	|	Clients.Имя,
	|	Clients.Отчество,
	|	Clients.Sex,
	|	Clients.ДатаРождения,
	|	Clients.IdentityDocumentType,
	|	Clients.IdentityDocumentSeries,
	|	Clients.IdentityDocumentNumber,
	|	Clients.IdentityDocumentIssueDate,
	|	Clients.Автор,
	|	Clients.CreateDate
	|FROM
	|	Catalog.Clients AS Clients
	|WHERE
	|	Clients.IsFolder = FALSE AND " + 
		?(IsBlankString(pIdentityDocNumber), "", "Clients.IdentityDocumentNumber = &qIdentityDocNumber AND ") + 
		?(IsBlankString(pIdentityDocSeries), "", "Clients.IdentityDocumentSeries = &qIdentityDocSeries AND ") + 
		?(pUseSubstringSearch,
		?(IsBlankString(pLastName), "", "(Clients.Description LIKE &qDescription OR Clients.Description LIKE &qDescriptionTrans OR Clients.Имя LIKE &qFirstName OR Clients.Имя LIKE &qFirstNameTrans OR Clients.Отчество LIKE &qSecondName OR Clients.Отчество LIKE &qSecondNameTrans) AND "), 
		?(IsBlankString(pLastName), "", "(Clients.Description LIKE &qDescription OR Clients.Description LIKE &qDescriptionTrans) AND ") + 
		?(IsBlankString(pFirstName), "", "(Clients.Имя LIKE &qFirstName OR Clients.Имя LIKE &qFirstNameTrans) AND ") + 
		?(IsBlankString(pSecondName), "", "(Clients.Отчество LIKE &qSecondName OR Clients.Отчество LIKE &qSecondNameTrans) AND ")) + 
		?(IsBlankString(pPhone), "", "Clients.Телефон LIKE &qPhone AND ") + 
		?(IsBlankString(pEMail), "", "Clients.EMail LIKE &qEMail AND ") + 
		"Clients.DeletionMark = FALSE
	|ORDER BY 
	|	Description, 
	|	CreateDate";
	If pUseSubstringSearch Тогда
		qGetList.SetParameter("qDescription", "%"+pLastName+"%");
		If IsBlankString(pFirstName) Тогда
			qGetList.SetParameter("qFirstName", "%"+pLastName+"%");
		Else
			qGetList.SetParameter("qFirstName", "%"+pFirstName+"%");
		EndIf;
		If IsBlankString(pSecondName) Тогда
			qGetList.SetParameter("qSecondName", "%"+pLastName+"%");
		Else
			qGetList.SetParameter("qSecondName", "%"+pSecondName+"%");
		EndIf;
		// Transliterate names
		qGetList.SetParameter("qDescriptionTrans", "%"+cmTransliterate(pLastName)+"%");
		If IsBlankString(pFirstName) Тогда
			qGetList.SetParameter("qFirstNameTrans", "%"+cmTransliterate(pLastName)+"%");
		Else
			qGetList.SetParameter("qFirstNameTrans", "%"+cmTransliterate(pFirstName)+"%");
		EndIf;
		If IsBlankString(pSecondName) Тогда
			qGetList.SetParameter("qSecondNameTrans", "%"+cmTransliterate(pLastName)+"%");
		Else
			qGetList.SetParameter("qSecondNameTrans", "%"+cmTransliterate(pSecondName)+"%");
		EndIf;
	Else
		qGetList.SetParameter("qDescription", pLastName+"%");
		qGetList.SetParameter("qFirstName", pFirstName+"%");
		qGetList.SetParameter("qSecondName", pSecondName+"%");
		// Transliterate names
		qGetList.SetParameter("qDescriptionTrans", cmTransliterate(pLastName)+"%");
		qGetList.SetParameter("qFirstNameTrans", cmTransliterate(pFirstName)+"%");
		qGetList.SetParameter("qSecondNameTrans", cmTransliterate(pSecondName)+"%");
	EndIf;
	qGetList.SetParameter("qIdentityDocNumber", pIdentityDocNumber);
	qGetList.SetParameter("qIdentityDocSeries", pIdentityDocSeries);
	qGetList.SetParameter("qPhone", "%"+pPhone+"%");
	qGetList.SetParameter("qEMail", "%"+pEMail+"%");
	vList = qGetList.Execute().Unload();
	Return vList;
EndFunction //cmGetClientsList

//-----------------------------------------------------------------------------
// Description: Returns client's list filtered by client name, identity document 
//              data and phone number. Additionaly for each client found program 
//              checks whether there are any clients reserved together with this client 
//              in the same ГруппаНомеров and from the same guest group. If yes then those clients
//              are also being added to the return list
// Parameters: Client last name string, Client first name string, Client second name string,
//             Identity document number string, Identity document series string, Phone number string,
//             Boolean - Whether to use substring search for the client name (search requested string 
//             in any part of the name) or use search comparing first letters of name with requested 
//             string
// Return value: Value table with clients found
//-----------------------------------------------------------------------------
Function cmGetOneRoomResClientsList(pLastName, pFirstName, pSecondName, pIdentityDocNumber, pIdentityDocSeries, pPhone, pUseSubstringSearch = False) Экспорт
	// Build and run query
	qGetList = New Query;
	qGetList.Text = 
	"SELECT
	|	Clients.Ref
	|INTO Clients
	|FROM
	|	Catalog.Clients AS Clients
	|WHERE
	|	Clients.IsFolder = FALSE AND " + 
		?(IsBlankString(pIdentityDocNumber), "", "Clients.IdentityDocumentNumber = &qIdentityDocNumber AND ") + 
		?(IsBlankString(pIdentityDocSeries), "", "Clients.IdentityDocumentSeries = &qIdentityDocSeries AND ") + 
		?(pUseSubstringSearch,
			?(IsBlankString(pLastName), "", "(Clients.Description LIKE &qDescription OR Clients.Description LIKE &qDescriptionTrans OR Clients.FullName LIKE &qDescription OR Clients.FullName LIKE &qDescriptionTrans OR Clients.Имя LIKE &qFirstName OR Clients.Имя LIKE &qFirstNameTrans OR Clients.Отчество LIKE &qSecondName OR Clients.Отчество LIKE &qSecondNameTrans) AND "), 
			?(IsBlankString(pLastName), "", "(Clients.Description LIKE &qDescription OR Clients.Description LIKE &qDescriptionTrans OR Clients.FullName LIKE &qDescription OR Clients.FullName LIKE &qDescriptionTrans) AND ") + 
			?(IsBlankString(pFirstName), "", "(Clients.Имя LIKE &qFirstName OR Clients.Имя LIKE &qFirstNameTrans) AND ") + 
			?(IsBlankString(pSecondName), "", "(Clients.Отчество LIKE &qSecondName OR Clients.Отчество LIKE &qSecondNameTrans) AND ")) + 
		?(IsBlankString(pPhone), "", "Clients.Телефон LIKE &qPhone AND ") + "
	|	Clients.DeletionMark = FALSE
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Reservations.НомерДока,
	|	Reservations.НомерРазмещения,
	|	Reservations.ГруппаГостей
	|INTO Reservations
	|FROM
	|	Document.Бронирование AS Reservations
	|WHERE
	|	Reservations.Клиент <> &qEmptyClient AND
	|	Reservations.Клиент IN
	|			(SELECT
	|				Clients.Ref
	|			FROM
	|				Clients AS Clients)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	ResClients.Ref AS Бронирование,
	|	ResClients.Клиент AS Ref,
	|	ResClients.Клиент.Description AS Description,
	|	ResClients.Клиент.Фамилия AS Фамилия,
	|	ResClients.Клиент.Имя AS Имя,
	|	ResClients.Клиент.Отчество AS Отчество,
	|	ResClients.Клиент.Sex AS Sex,
	|	ResClients.Клиент.ДатаРождения AS ДатаРождения,
	|	ResClients.Клиент.IdentityDocumentType AS IdentityDocumentType,
	|	ResClients.Клиент.IdentityDocumentSeries AS IdentityDocumentSeries,
	|	ResClients.Клиент.IdentityDocumentNumber AS IdentityDocumentNumber,
	|	ResClients.Клиент.IdentityDocumentIssueDate AS IdentityDocumentIssueDate,
	|	ResClients.Клиент.Автор AS Автор,
	|	ResClients.Клиент.CreateDate AS CreateDate
	|FROM
	|	Document.Бронирование AS ResClients
	|WHERE
	|	ResClients.НомерДока IN
	|		(SELECT
	|			Reservations.НомерДока
	|		FROM
	|			Reservations AS Reservations)
	|		AND ResClients.ГруппаГостей IN 
	|			(SELECT
	|				Reservations.ГруппаГостей
	|			FROM
	|				Reservations AS Reservations
	|			WHERE
	|				Reservations.НомерРазмещения = &qEmptyRoom)
	|	OR ResClients.НомерРазмещения IN
	|		(SELECT
	|			Reservations.НомерРазмещения
	|		FROM
	|			Reservations AS Reservations
	|		WHERE
	|			Reservations.НомерРазмещения <> &qEmptyRoom)
	|		AND ResClients.ГруппаГостей IN
	|		(SELECT
	|			Reservations.ГруппаГостей
	|		FROM
	|			Reservations AS Reservations
	|		WHERE
	|			Reservations.НомерРазмещения <> &qEmptyRoom)
	|
	|ORDER BY
	|	Description,
	|	CreateDate";
	If pUseSubstringSearch Тогда
		qGetList.SetParameter("qDescription", pLastName+"%");
		If IsBlankString(pFirstName) Тогда
			qGetList.SetParameter("qFirstName", pLastName+"%");
		Else
			qGetList.SetParameter("qFirstName", pFirstName+"%");
		EndIf;
		If IsBlankString(pSecondName) Тогда
			qGetList.SetParameter("qSecondName", pLastName+"%");
		Else
			qGetList.SetParameter("qSecondName", pSecondName+"%");
		EndIf;
		// Transliterate names
		qGetList.SetParameter("qDescriptionTrans", cmTransliterate(pLastName)+"%");
		If IsBlankString(pFirstName) Тогда
			qGetList.SetParameter("qFirstNameTrans", cmTransliterate(pLastName)+"%");
		Else
			qGetList.SetParameter("qFirstNameTrans", cmTransliterate(pFirstName)+"%");
		EndIf;
		If IsBlankString(pSecondName) Тогда
			qGetList.SetParameter("qSecondNameTrans", cmTransliterate(pLastName)+"%");
		Else
			qGetList.SetParameter("qSecondNameTrans", cmTransliterate(pSecondName)+"%");
		EndIf;
	Else
		qGetList.SetParameter("qDescription", pLastName+"%");
		qGetList.SetParameter("qFirstName", pFirstName+"%");
		qGetList.SetParameter("qSecondName", pSecondName+"%");
		// Transliterate names
		qGetList.SetParameter("qDescriptionTrans", cmTransliterate(pLastName)+"%");
		qGetList.SetParameter("qFirstNameTrans", cmTransliterate(pFirstName)+"%");
		qGetList.SetParameter("qSecondNameTrans", cmTransliterate(pSecondName)+"%");
	EndIf;
	qGetList.SetParameter("qIdentityDocNumber", pIdentityDocNumber);
	qGetList.SetParameter("qIdentityDocSeries", pIdentityDocSeries);
	qGetList.SetParameter("qPhone", "%"+pPhone+"%");
	qGetList.SetParameter("qEmptyRoom", Справочники.НомернойФонд.EmptyRef());
	qGetList.SetParameter("qEmptyClient", Справочники.Clients.EmptyRef());
	vList = qGetList.Execute().Unload();
	Return vList;
EndFunction //cmGetOneRoomResClientsList

//-----------------------------------------------------------------------------
// Description: Returns client's list filtered by client name, identity document 
//              data and phone number. Additionaly for each client found program 
//              checks whether there are any clients living together with this client 
//              in the same ГруппаНомеров and from the same guest group. If yes then those clients
//              are also being added to the return list
// Parameters: Client last name string, Client first name string, Client second name string,
//             Identity document number string, Identity document series string, Phone number string,
//             Boolean - Whether to use substring search for the client name (search requested string 
//             in any part of the name) or use search comparing first letters of name with requested 
//             string
// Return value: Value table with clients found
//-----------------------------------------------------------------------------
Function cmGetOneRoomAccClientsList(pLastName, pFirstName, pSecondName, pIdentityDocNumber, pIdentityDocSeries, pPhone, pUseSubstringSearch = False) Экспорт
	// Build and run query
	qGetList = New Query;
	qGetList.Text = 
	"SELECT
	|	Accommodations.НомерРазмещения,
	|	Accommodations.ГруппаГостей
	|INTO RoomsByGuestData
	|FROM
	|	Document.Размещение AS Accommodations
	|WHERE
	|	Accommodations.Клиент <> &qEmptyClient AND 
	|	Accommodations.Клиент IN
	|		(SELECT
	|			Clients.Ref
	|		FROM
	|			Catalog.Clients AS Clients
	|		WHERE
	|			Clients.IsFolder = FALSE AND " + 
		?(IsBlankString(pIdentityDocNumber), "", "Clients.IdentityDocumentNumber = &qIdentityDocNumber AND ") + 
		?(IsBlankString(pIdentityDocSeries), "", "Clients.IdentityDocumentSeries = &qIdentityDocSeries AND ") + 
		?(pUseSubstringSearch,
			?(IsBlankString(pLastName), "", "(Clients.Description LIKE &qDescription OR Clients.Description LIKE &qDescriptionTrans OR Clients.FullName LIKE &qDescription OR Clients.FullName LIKE &qDescriptionTrans OR Clients.Имя LIKE &qFirstName OR Clients.Имя LIKE &qFirstNameTrans OR Clients.Отчество LIKE &qSecondName OR Clients.Отчество LIKE &qSecondNameTrans) AND "), 
			?(IsBlankString(pLastName), "", "(Clients.Description LIKE &qDescription OR Clients.Description LIKE &qDescriptionTrans OR Clients.FullName LIKE &qDescription OR Clients.FullName LIKE &qDescriptionTrans) AND ") + 
			?(IsBlankString(pFirstName), "", "(Clients.Имя LIKE &qFirstName OR Clients.Имя LIKE &qFirstNameTrans) AND ") + 
			?(IsBlankString(pSecondName), "", "(Clients.Отчество LIKE &qSecondName OR Clients.Отчество LIKE &qSecondNameTrans) AND ")) + 
		?(IsBlankString(pPhone), "", "Clients.Телефон LIKE &qPhone AND ") + 
									 "Clients.DeletionMark = FALSE) 
	|GROUP BY
	|	Accommodations.НомерРазмещения,
	|	Accommodations.ГруппаГостей
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	AccClients.Ref AS Размещение,
	|	AccClients.Клиент AS Ref,
	|	AccClients.Клиент.Description AS Description,
	|	AccClients.Клиент.Фамилия AS Фамилия,
	|	AccClients.Клиент.Имя AS Имя,
	|	AccClients.Клиент.Отчество AS Отчество,
	|	AccClients.Клиент.Sex AS Sex,
	|	AccClients.Клиент.ДатаРождения AS ДатаРождения,
	|	AccClients.Клиент.IdentityDocumentType AS IdentityDocumentType,
	|	AccClients.Клиент.IdentityDocumentSeries AS IdentityDocumentSeries,
	|	AccClients.Клиент.IdentityDocumentNumber AS IdentityDocumentNumber,
	|	AccClients.Клиент.IdentityDocumentIssueDate AS IdentityDocumentIssueDate,
	|	AccClients.Клиент.Автор AS Автор,
	|	AccClients.Клиент.CreateDate AS CreateDate
	|FROM
	|	Document.Размещение AS AccClients
	|INNER JOIN
	|	RoomsByGuestData
	|	ON RoomsByGuestData.НомерРазмещения = AccClients.НомерРазмещения
	|		AND RoomsByGuestData.ГруппаГостей = AccClients.ГруппаГостей
	|ORDER BY 
	|	AccClients.Клиент.Description, 
	|	AccClients.Клиент.CreateDate";
	If pUseSubstringSearch Тогда
		qGetList.SetParameter("qDescription", pLastName+"%");
		If IsBlankString(pFirstName) Тогда
			qGetList.SetParameter("qFirstName", pLastName+"%");
		Else
			qGetList.SetParameter("qFirstName", pFirstName+"%");
		EndIf;
		If IsBlankString(pSecondName) Тогда
			qGetList.SetParameter("qSecondName", pLastName+"%");
		Else
			qGetList.SetParameter("qSecondName", pSecondName+"%");
		EndIf;
		// Transliterate names
		qGetList.SetParameter("qDescriptionTrans", cmTransliterate(pLastName)+"%");
		If IsBlankString(pFirstName) Тогда
			qGetList.SetParameter("qFirstNameTrans", cmTransliterate(pLastName)+"%");
		Else
			qGetList.SetParameter("qFirstNameTrans", cmTransliterate(pFirstName)+"%");
		EndIf;
		If IsBlankString(pSecondName) Тогда
			qGetList.SetParameter("qSecondNameTrans", cmTransliterate(pLastName)+"%");
		Else
			qGetList.SetParameter("qSecondNameTrans", cmTransliterate(pSecondName)+"%");
		EndIf;
	Else
		qGetList.SetParameter("qDescription", pLastName+"%");
		qGetList.SetParameter("qFirstName", pFirstName+"%");
		qGetList.SetParameter("qSecondName", pSecondName+"%");
		// Transliterate names
		qGetList.SetParameter("qDescriptionTrans", cmTransliterate(pLastName)+"%");
		qGetList.SetParameter("qFirstNameTrans", cmTransliterate(pFirstName)+"%");
		qGetList.SetParameter("qSecondNameTrans", cmTransliterate(pSecondName)+"%");
	EndIf;
	qGetList.SetParameter("qIdentityDocNumber", pIdentityDocNumber);
	qGetList.SetParameter("qIdentityDocSeries", pIdentityDocSeries);
	qGetList.SetParameter("qPhone", "%"+pPhone+"%");
	qGetList.SetParameter("qEmptyClient", Справочники.Clients.EmptyRef());
	vList = qGetList.Execute().Unload();
	Return vList;
EndFunction //cmGetOneRoomAccClientsList

//-----------------------------------------------------------------------------
// Description: ГруппаНомеров main reservation for the given reservation number and guest group
// Parameters: Reservation number as string, Guest group item reference
// Return value: ГруппаНомеров main reservation document reference or undefined if nothing is found
//-----------------------------------------------------------------------------
Function cmGetOneRoomReservation(pReservationNumber, pGuestGroup, pRoom = Неопределено) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Бронирование.Ref
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	(NOT &qRoomIsFilled AND Бронирование.НомерДока = &qNumber OR &qRoomIsFilled AND Бронирование.НомерРазмещения = &qRoom)
	|	AND Бронирование.ГруппаГостей = &qGuestGroup
	|	AND Бронирование.Posted
	|	AND Бронирование.ReservationStatus.IsActive
	|	AND Бронирование.ВидРазмещения.ТипРазмещения = &qRoomAccommodationType
	|
	|ORDER BY
	|	Бронирование.ДатаДок,
	|	Бронирование.PointInTime";
	vQry.SetParameter("qNumber", СокрЛП(pReservationNumber));
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qRoomIsFilled", ЗначениеЗаполнено(pRoom));
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qRoomAccommodationType", Перечисления.AccomodationTypes.НомерРазмещения);
	vOneRoomDocs = vQry.Execute().Unload();
	If vOneRoomDocs.Count() > 0 Тогда
		Return vOneRoomDocs.Get(0).Ref;
	Else
		Return Неопределено;
	EndIf;
EndFunction //cmGetOneRoomReservation

//-----------------------------------------------------------------------------
// Description: Returns list of one ГруппаНомеров reservations for the given reservation number and guest group
// Parameters: Reservation number as string, Guest group item reference, Accommodation period
// Return value: Value table with one ГруппаНомеров reservations
//-----------------------------------------------------------------------------
Function cmGetOneRoomReservations(pReservationNumber, pGuestGroup, pCheckInDate, pCheckOutDate, pGetInactive = False) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Docs.Ref,
	|	Docs.ПорядокСортировки
	|FROM
	|	Document.Бронирование AS Docs
	|WHERE
	|	Docs.НомерДока = &qNumber
	|	AND Docs.ГруппаГостей = &qGuestGroup
	|	AND Docs.Posted
	|	AND (NOT &qGetInactive
	|				AND Docs.ReservationStatus.IsActive
	|			OR &qGetInactive
	|				AND NOT Docs.ReservationStatus.IsActive)
	|	AND Docs.CheckInDate < &qCheckOutDate
	|	AND Docs.ДатаВыезда > &qCheckInDate
	|	AND NOT Docs.ТипНомера.ВиртуальныйНомер
	|	AND Docs.ТипНомера.КоличествоМестНомер < 5
	|
	|ORDER BY
	|	Docs.ПорядокСортировки";
	vQry.SetParameter("qNumber", СокрЛП(pReservationNumber));
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", pCheckOutDate);
	vQry.SetParameter("qGetInactive", pGetInactive);
	vOneRoomDocs = vQry.Execute().Unload();
	Return vOneRoomDocs;
EndFunction //cmGetOneRoomReservations

//-----------------------------------------------------------------------------
// Description: Returns number of one ГруппаНомеров reservation guests
// Parameters: Reservation number as string, ГруппаНомеров item reference, Guest group item reference, Accommodation period
// Return value: Number of one ГруппаНомеров guests
//-----------------------------------------------------------------------------
Function cmGetNumberOfOneRoomReservationPersons(pReservationNumber, pRoom, pGuestGroup, pCheckInDate, pCheckOutDate) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ISNULL(SUM(Docs.КоличествоЧеловек), 0) AS КоличествоЧеловек
	|FROM
	|	Document.Бронирование AS Docs
	|WHERE
	|	Docs.Posted
	|	AND Docs.ГруппаГостей = &qGuestGroup
	|	AND (&qRoomIsEmpty AND Docs.НомерДока = &qNumber OR NOT &qRoomIsEmpty AND Docs.НомерРазмещения = &qRoom)
	|	AND Docs.ReservationStatus.IsActive
	|	AND Docs.CheckInDate < &qCheckOutDate
	|	AND Docs.ДатаВыезда > &qCheckInDate";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qNumber", СокрЛП(pReservationNumber));
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qRoomIsEmpty", НЕ ЗначениеЗаполнено(pRoom));
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", pCheckOutDate);
	vOneRoomDocs = vQry.Execute().Unload();
	If vOneRoomDocs.Count() > 0 Тогда
		Return vOneRoomDocs.Get(0).КоличествоЧеловек;
	Else
		Return 0;
	EndIf;
EndFunction //cmGetNumberOfOneRoomReservationPersons

//-----------------------------------------------------------------------------
// Description: Returns one ГруппаНомеров accommodation with ГруппаНомеров accommodation type for 
//              the given ГруппаНомеров and guest group
// Parameters: ГруппаНомеров item reference, Guest group item reference, Accommodation period
// Return value: Accommodation document reference
//-----------------------------------------------------------------------------
Function cmGetOneRoomAccommodation(pRoom, pGuestGroup, pCheckInDate, pCheckOutDate) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Docs.Ref
	|FROM
	|	Document.Размещение AS Docs
	|WHERE
	|	Docs.НомерРазмещения = &qRoom
	|	AND Docs.ГруппаГостей = &qGuestGroup
	|	AND Docs.Posted
	|	AND Docs.СтатусРазмещения.IsActive
	|	AND Docs.CheckInDate < &qCheckOutDate
	|	AND Docs.ДатаВыезда > &qCheckInDate
	|	AND Docs.ВидРазмещения.ТипРазмещения = &qRoomAccommodationType
	|ORDER BY
	|	Docs.ДатаДок,
	|	Docs.PointInTime";
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", pCheckOutDate);
	vQry.SetParameter("qRoomAccommodationType", Перечисления.AccomodationTypes.НомерРазмещения);
	vOneRoomDocs = vQry.Execute().Unload();
	If vOneRoomDocs.Count() > 0 Тогда
		Return vOneRoomDocs.Get(0).Ref;
	Else
		Return Неопределено;
	EndIf;
EndFunction //cmGetOneRoomAccommodation

//-----------------------------------------------------------------------------
// Description: Returns list of one ГруппаНомеров accommodations for the given ГруппаНомеров and guest group
// Parameters: ГруппаНомеров item reference, Guest group item reference, Accommodation period
// Return value: Value table with one ГруппаНомеров accommodations
//-----------------------------------------------------------------------------
Function cmGetOneRoomAccommodations(pRoom, pGuestGroup, pCheckInDate, pCheckOutDate) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Docs.Ref,
	|	Docs.ПорядокСортировки
	|FROM
	|	Document.Размещение AS Docs
	|WHERE
	|	Docs.НомерРазмещения = &qRoom
	|	AND Docs.ГруппаГостей = &qGuestGroup
	|	AND Docs.Posted
	|	AND Docs.СтатусРазмещения.IsActive
	|	AND Docs.CheckInDate < &qCheckOutDate
	|	AND Docs.ДатаВыезда > &qCheckInDate
	|	AND NOT Docs.ТипНомера.ВиртуальныйНомер
	|	AND Docs.ТипНомера.КоличествоМестНомер < 7
	|
	|ORDER BY
	|	Docs.ДатаДок,
	|	Docs.PointInTime";
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", pCheckOutDate);
	vOneRoomDocs = vQry.Execute().Unload();
	Return vOneRoomDocs;
EndFunction //cmGetOneRoomAccommodations

//-----------------------------------------------------------------------------
// Description: Returns client's presentation string being built from client  
//              full name, birth date, identity document data and client remarks
// Parameters: Value table row or Structure with client data
// Return value: Client presentation string
//-----------------------------------------------------------------------------
Function cmGetClientPresentation(pRow) Экспорт
	//vD = СокрЛП(pRow.Description);
	vLN = СокрЛП(pRow.Фамилия);
	vFN = СокрЛП(pRow.Имя);
	vSN = СокрЛП(pRow.Отчество);
	vDB = pRow.ДатаРождения;
	vIT = СокрЛП(pRow.IdentityDocumentType);
	vIS = СокрЛП(pRow.IdentityDocumentSeries);
	vIN = СокрЛП(pRow.IdentityDocumentNumber);
	//vID = pRow.IdentityDocumentIssueDate;
	vR = СокрЛП(pRow.Ref.Примечания);
	vN = vLN + ?(vFN="", "", " " + vFN) + ?(vSN="", "", " " + vSN) + 
	     ?(ЗначениеЗаполнено(vDB), NStr("ru = ', р.'; en = ', b.'; de = ', g.d.'") + Format(vDB, "DF='dd-MM-yyyy'"), "") + 
	     ?(vIN="", "", ", " + vIT + NStr("ru = ' №'; en = ' N'; de = ' Nr.'") + vIS + " " + vIN) + 
	     ?(vR="", "", ", " + vR) + 
	     "               ";
	Return vN;
EndFunction //cmGetClientPresentation

//-----------------------------------------------------------------------------
// Description: Calculates number of guests/rooms being already checked-in by  
//              given reservation
// Parameters: Reservation document reference
// Return value: Value table with one row for the given reservation
//-----------------------------------------------------------------------------
Function cmGetWriteOffsForReservation(pReservation) Экспорт
	// Calculate write off done by accommodations
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.ДокОснование,
	|	SUM(ЗагрузкаНомеров.ЗаездНомеров) AS ЗаездНомеров,
	|	SUM(ЗагрузкаНомеров.ЗаездМест) AS ЗаездМест,
	|	SUM(ЗагрузкаНомеров.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест,
	|	SUM(ЗагрузкаНомеров.ЗаездГостей) AS ЗаездГостей
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.ДокОснование = &qParentDoc
	|	AND ЗагрузкаНомеров.RecordType = &qRecordType
	|GROUP BY
	|	ЗагрузкаНомеров.ДокОснование";
	vQry.SetParameter("qParentDoc", pReservation);
	vQry.SetParameter("qRecordType", AccumulationRecordType.Expense);
	vWriteOffs = vQry.Execute().Unload();
	Return vWriteOffs;
EndFunction //cmGetWriteOffsForReservation

//-----------------------------------------------------------------------------
// Description: Calculates number of guests/rooms being already checked-in for  
//              the given reservation's value list
// Parameters: Value list with reservations
// Return value: Value table with rows for each reservation from the input list
//-----------------------------------------------------------------------------
Function cmGetCheckedInGuestsForReservationsList(pResList) Экспорт
	// Calculate write off done by accommodations
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.ДокОснование AS ДокОснование,
	|	ЗагрузкаНомеров.ДокОснование.ВидРазмещения AS ВидРазмещения,
	|	SUM(ЗагрузкаНомеров.ЗаездНомеров) AS ЗаездНомеров,
	|	SUM(ЗагрузкаНомеров.ЗаездМест) AS ЗаездМест,
	|	SUM(ЗагрузкаНомеров.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест,
	|	SUM(ЗагрузкаНомеров.ЗаездГостей) AS ЗаездГостей
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.ДокОснование IN(&qDocList)
	|	AND ЗагрузкаНомеров.RecordType = &qRecordType
	|GROUP BY
	|	ЗагрузкаНомеров.ДокОснование";
	vQry.SetParameter("qDocList", pResList);
	vQry.SetParameter("qRecordType", AccumulationRecordType.Expense);
	vCheckedInGuests = vQry.Execute().Unload();
	Return vCheckedInGuests;
EndFunction //cmGetCheckedInGuestsForReservationsList

//-----------------------------------------------------------------------------
// Description: Returns value table of accommodations being already checked-in for  
//              the given reservation's value list
// Parameters: Value list with reservations
// Return value: Value table with rows of accommodations for each reservation 
//               from the input list
//-----------------------------------------------------------------------------
Function cmGetCheckedInAccommodationsForReservationsList(pResList) Экспорт
	// Calculate write off done by accommodations
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.ДокОснование AS ДокОснование,
	|	ЗагрузкаНомеров.Recorder AS Размещение,
	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
	|	ЗагрузкаНомеров.ТипНомера.Code AS RoomTypeCode,
	|	ЗагрузкаНомеров.ТипНомера.Description AS RoomTypeDescription,
	|	ЗагрузкаНомеров.Тариф AS Тариф,
	|	ЗагрузкаНомеров.Тариф.Description AS RoomRateDescription,
	|	ЗагрузкаНомеров.Recorder.ServicePackage AS ServicePackage,
	|	ЗагрузкаНомеров.Recorder.ServicePackage.Description AS ServicePackageDescription,
	|	ЗагрузкаНомеров.ВидРазмещения AS ВидРазмещения,
	|	ЗагрузкаНомеров.ВидРазмещения.Description AS AccommodationTypeDescription,
	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate,
	|	ЗагрузкаНомеров.Продолжительность AS Продолжительность,
	|	ЗагрузкаНомеров.ДатаВыезда AS ДатаВыезда,
	|	ЗагрузкаНомеров.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Клиент.FullName AS GuestFullName,
	|	ЗагрузкаНомеров.Клиент.Description AS GuestDescription
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.ДокОснование IN(&qDocList)
	|	AND ЗагрузкаНомеров.RecordType = &qRecordType
	|	AND ЗагрузкаНомеров.IsAccommodation
	|
	|ORDER BY
	|	ЗагрузкаНомеров.Recorder.ДатаДок,
	|	ЗагрузкаНомеров.Recorder.PointInTime";
	vQry.SetParameter("qDocList", pResList);
	vQry.SetParameter("qRecordType", AccumulationRecordType.Expense);
	vCheckedInGuests = vQry.Execute().Unload();
	Return vCheckedInGuests;
EndFunction //cmGetCheckedInAccommodationsForReservationsList

//-----------------------------------------------------------------------------
// Description: Returns minimum number of vacant rooms/beds for the period given  
// Parameters: Гостиница, ГруппаНомеров type to filter output, ГруппаНомеров to filter output,
//             Begin of period date, End of period date
// Return value: Value table with one row for the hotel with numbers of vacant 
//               rooms and beds
//-----------------------------------------------------------------------------
Function cmGetRestOfVacantRooms(pHotel, pRoomType, pRoom, pDateFrom, pDateTo) Экспорт
	// Common checks	
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetRestOfVacantRooms function.
		               |CAUSE: Empty pHotel parameter value was passed to the function.
					   |DESC: Mandatory parameter pHotel should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetRestOfVacantRooms.
				       |CAUSE: В функцию передано пустое значение параметра pHotel.
					   |DESC: Обязательный параметр pHotel должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetOfVacantRooms.
				       |CAUSE: In die Funktion wurde ein leerer Wert des Parameters pHotel übertragen.
					   |DESC: Das Pflichtparameter pHotel muss eindeutig angegeben sein.'"));
	EndIf;
	
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalance.Гостиница AS Гостиница,
	|	MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
	|	MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS ВсегоМест,
	|	MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS ВсегоНомеров,
	|	MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant,
	|	MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant
	|
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|	                                                       Second, 
	|	                                                       RegisterRecordsAndPeriodBoundaries, 
	|	                                                       Гостиница = &qHotel" +
		                                                       ?(ЗначениеЗаполнено(pRoomType), " AND ТипНомера = &qRoomType", "") + 
		                                                       ?(ЗначениеЗаполнено(pRoom), " AND НомерРазмещения = &qRoom", "") + "
	|) AS RoomInventoryBalance
	|
	|GROUP BY
	|	RoomInventoryBalance.Гостиница";
	
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	
	vQryTab = vQry.Execute().Unload();
	
	Return vQryTab;
EndFunction //cmGetRestOfVacantRooms

//-----------------------------------------------------------------------------
// Description: Returns value table. Each value table row has period with number 
//              of rooms/beds vacant for this period. All periods are inside period
//              being specified as input parameter
// Parameters: Гостиница, ГруппаНомеров type to filter output, ГруппаНомеров to filter output,
//             Begin of period date, End of period date
// Return value: Value table with numbers of vacant rooms and beds
//-----------------------------------------------------------------------------
Function cmGetVacantRoomsByPeriodsForAccommodation(pHotel, pRoomType, pRoom, pDateFrom, pDateTo) Экспорт
	// Common checks	
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetVacantRoomsByPeriods function.
		               |CAUSE: Empty pHotel parameter value was passed to the function.
					   |DESC: Mandatory parameter pHotel should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetVacantRoomsByPeriods.
				       |CAUSE: В функцию передано пустое значение параметра pHotel.
					   |DESC: Обязательный параметр pHotel должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetVacantRoomsByPeriods.
				       |CAUSE: In die Funktion wurde ein leerer Wert des Parameters pHotel übertragen.
					   |DESC: Das Pflichtparameter pHotel muss eindeutig angegeben sein.'"));
	EndIf;
	
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalance.Гостиница AS Гостиница,
	|	RoomInventoryBalance.ТипНомера AS ТипНомера,
	|	RoomInventoryBalance.Period AS ПериодС,
	|	RoomInventoryBalance.Period AS ПериодПо,
	|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
	|	RoomInventoryBalance.TotalBedsClosingBalance AS ВсегоМест,
	|	RoomInventoryBalance.TotalRoomsClosingBalance AS ВсегоНомеров,
	|	RoomInventoryBalance.RoomsVacantClosingBalance AS RoomsVacant,
	|	RoomInventoryBalance.BedsVacantClosingBalance AS BedsVacant
	|
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|	                                                       Second, 
	|	                                                       RegisterRecordsAndPeriodBoundaries, 
	|	                                                       Гостиница = &qHotel" +
		                                                       ?(ЗначениеЗаполнено(pRoomType), ?(pRoomType.IsFolder, " AND ТипНомера IN HIERARCHY(&qRoomType)", " AND ТипНомера = &qRoomType"), "") + 
		                                                       ?(ЗначениеЗаполнено(pRoom), ?(pRoom.IsFolder, " AND НомерРазмещения IN HIERARCHY(&qRoom)", " AND НомерРазмещения = &qRoom"), "") + "
	|) AS RoomInventoryBalance
	|ORDER BY
	|	RoomInventoryBalance.ТипНомера.ПорядокСортировки,
	|	RoomInventoryBalance.Period";
	
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	
	vQryTab = vQry.Execute().Unload();
	
	// Process query tab joining adjacent rows into the one with period from and period to columns
	i = 0;
	While i < (vQryTab.Count() - 1) Do
		vCurRow = vQryTab.Get(i);
		vNextRow = vQryTab.Get(i + 1);
		If vCurRow.ТипНомера = vNextRow.ТипНомера Тогда
			vCurRow.ПериодПо = vNextRow.ПериодС;
			If vCurRow.RoomsVacant = vNextRow.RoomsVacant And 
			   vCurRow.BedsVacant = vNextRow.BedsVacant Тогда
				vQryTab.Delete(i + 1);
			Else
				i = i + 1;
			EndIf;
		Else
			i = i + 1;
		EndIf;
	EndDo;
	
	// Remove not joined rows 
	i = 0;
	While i < vQryTab.Count() Do
		vCurRow = vQryTab.Get(i);
		If vCurRow.ПериодС = vCurRow.ПериодПо Тогда
			vQryTab.Delete(i);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	
	// Return resulting table
	Return vQryTab;
EndFunction //cmGetVacantRoomsByPeriodsForAccommodation

//-----------------------------------------------------------------------------
// Description: Returns value table. Each value table row has period with number 
//              of rooms/beds vacant for this period. All periods are inside period
//              being specified as input parameter
// Parameters: Гостиница, ГруппаНомеров type to filter output, ГруппаНомеров to filter output, ГруппаНомеров quota to filter output
//             Begin of period date, End of period date
// Return value: Value table with numbers of vacant rooms and beds
//-----------------------------------------------------------------------------
Function cmGetVacantRoomsByPeriodsForReservation(pHotel, pRoomType, pRoom, pRoomQuota, pDateFrom, pDateTo) Экспорт
	// Common checks	
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetVacantRoomsByPeriods function.
		               |CAUSE: Empty pHotel parameter value was passed to the function.
					   |DESC: Mandatory parameter pHotel should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetVacantRoomsByPeriods.
				       |CAUSE: В функцию передано пустое значение параметра pHotel.
					   |DESC: Обязательный параметр pHotel должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetVacantRoomsByPeriods.
				       |CAUSE: In die Funktion wurde ein leerer Wert des Parameters pHotel übertragen.
					   |DESC: Das Pflichtparameter pHotel muss eindeutig angegeben sein.'"));
				   EndIf;
	// Initialize ГруппаНомеров
	vRoom = pRoom;
	
	// Build and run query
	vQry = New Query;
	If НЕ ЗначениеЗаполнено(pRoomQuota) Or ЗначениеЗаполнено(pRoomQuota) And НЕ pRoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(vRoom) Тогда
		vQry.SetParameter("qRoom", vRoom);
		vQry.Text = 
		"SELECT
		|	RoomInventoryBalance.Гостиница AS Гостиница,
		|	RoomInventoryBalance.ТипНомера AS ТипНомера,
		|	RoomInventoryBalance.Period AS ПериодС,
		|	RoomInventoryBalance.Period AS ПериодПо,
		|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
		|	RoomInventoryBalance.TotalBedsClosingBalance AS ВсегоМест,
		|	RoomInventoryBalance.TotalRoomsClosingBalance AS ВсегоНомеров,
		|	RoomInventoryBalance.RoomsVacantClosingBalance AS RoomsVacant,
		|	RoomInventoryBalance.BedsVacantClosingBalance AS BedsVacant
		|
		|FROM
		|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
		|	                                                       Second, 
		|	                                                       RegisterRecordsAndPeriodBoundaries, 
		|	                                                       Гостиница = &qHotel" +
			                                                       ?(ЗначениеЗаполнено(pRoomType), ?(pRoomType.IsFolder, " AND ТипНомера IN HIERARCHY(&qRoomType)", " AND ТипНомера = &qRoomType"), "") + 
			                                                       ?(ЗначениеЗаполнено(vRoom), ?(vRoom.IsFolder, " AND НомерРазмещения IN HIERARCHY(&qRoom)", " AND НомерРазмещения = &qRoom"), "") + "
		|) AS RoomInventoryBalance
		|ORDER BY
		|	RoomInventoryBalance.ТипНомера.ПорядокСортировки,
		|	RoomInventoryBalance.Period";
	Else
		vQry.SetParameter("qRoomQuota", pRoomQuota);
		If ЗначениеЗаполнено(vRoom) Тогда
			If vRoom.IsFolder Тогда
				vQry.SetParameter("qRoom", vRoom);
			Else
				If pRoomQuota.IsQuotaForRooms Тогда
					vQry.SetParameter("qRoom", vRoom);
				Else
					vRoom = Неопределено;
				EndIf;
			EndIf;
		EndIf;
		vQry.Text = 
		"SELECT
		|	RoomQuotaBalance.Гостиница AS Гостиница,
		|	RoomQuotaBalance.ТипНомера AS ТипНомера,
		|	RoomQuotaBalance.Period AS ПериодС,
		|	RoomQuotaBalance.Period AS ПериодПо,
		|	RoomQuotaBalance.CounterClosingBalance AS CounterClosingBalance,
		|	RoomQuotaBalance.BedsInQuotaClosingBalance AS ВсегоМест,
		|	RoomQuotaBalance.RoomsInQuotaClosingBalance AS ВсегоНомеров,
		|	RoomQuotaBalance.RoomsRemainsClosingBalance AS RoomsVacant,
		|	RoomQuotaBalance.BedsRemainsClosingBalance AS BedsVacant
		|
		|FROM
		|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
		|	                                                       Second, 
		|	                                                       RegisterRecordsAndPeriodBoundaries, 
		|	                                                       Гостиница = &qHotel 
		|	                                                       AND КвотаНомеров = &qRoomQuota" + 
			                                                       ?(ЗначениеЗаполнено(pRoomType), ?(pRoomType.IsFolder, " AND ТипНомера IN HIERARCHY(&qRoomType)", " AND ТипНомера = &qRoomType"), "") + 
			                                                       ?(ЗначениеЗаполнено(vRoom), ?(vRoom.IsFolder, " AND НомерРазмещения IN HIERARCHY(&qRoom)", " AND НомерРазмещения = &qRoom"), "") + "
		|) AS RoomQuotaBalance
		|ORDER BY
		|	RoomQuotaBalance.ТипНомера.ПорядокСортировки,
		|	RoomQuotaBalance.Period";
	EndIf;
	
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	
	vQryTab = vQry.Execute().Unload();
	
	// Process query tab joining adjacent rows into the one with period from and period to columns
	i = 0;
	While i < (vQryTab.Count() - 1) Do
		vCurRow = vQryTab.Get(i);
		vNextRow = vQryTab.Get(i + 1);
		If vCurRow.ТипНомера = vNextRow.ТипНомера Тогда
			vCurRow.ПериодПо = vNextRow.ПериодС;
			If vCurRow.RoomsVacant = vNextRow.RoomsVacant And 
			   vCurRow.BedsVacant = vNextRow.BedsVacant Тогда
				vQryTab.Delete(i + 1);
			Else
				i = i + 1;
			EndIf;
		Else
			i = i + 1;
		EndIf;
	EndDo;
	
	// Remove not joined rows 
	i = 0;
	While i < vQryTab.Count() Do
		vCurRow = vQryTab.Get(i);
		If vCurRow.ПериодС = vCurRow.ПериодПо Тогда
			vQryTab.Delete(i);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	
	// Return resulting table
	Return vQryTab;
EndFunction //cmGetVacantRoomsByPeriodsForReservation

//-----------------------------------------------------------------------------
// Description: Returns accommodations or reservations intersecting by period 
//              with given document
// Parameters: Accommodation or reservation reference, Whether to check intersection 
//             for the documents from the same ГруппаНомеров only or not
// Return value: Value table with list of intersected documents
//-----------------------------------------------------------------------------
Function cmGetTableOfIntersectedDocs(pPeriod, pRoomIntersectionOnly = False) Экспорт
	// Build and run main query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	MIN(MinCheckInDates1.ПериодС) AS NextPeriodFrom1
	|INTO AfterCheckIn1ГруппаНомеров
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MinCheckInDates1
	|WHERE
	|	&qRoomIsFilled
	|	AND MinCheckInDates1.НомерРазмещения = &qRoom
	|	AND MinCheckInDates1.ТипНомера = &qRoomType
	|	AND NOT MinCheckInDates1.ТипНомера.ВиртуальныйНомер
	|	AND MinCheckInDates1.RecordType = &qExpense
	|	AND MinCheckInDates1.RoomsVacant <> 0
	|	AND MinCheckInDates1.BedsVacant <> 0
	|	AND MinCheckInDates1.BedsVacant < MinCheckInDates1.КоличествоМестНомер
	|	AND MinCheckInDates1.ПериодС >= &qPeriodFrom
	|	AND MinCheckInDates1.ПериодС <= &qPeriodTo
	|	AND MinCheckInDates1.Recorder <> &qCurDoc
	|	AND (MinCheckInDates1.Recorder REFS Document.Размещение
	|			OR MinCheckInDates1.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MIN(MinCheckInDates2.ПериодС) AS NextPeriodFrom2
	|INTO AfterCheckIn1EmptyRoom
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MinCheckInDates2
	|WHERE
	|	MinCheckInDates2.НомерРазмещения = &qEmptyRoom
	|	AND MinCheckInDates2.ТипНомера = &qRoomType
	|	AND NOT MinCheckInDates2.ТипНомера.ВиртуальныйНомер
	|	AND MinCheckInDates2.RecordType = &qExpense
	|	AND MinCheckInDates2.RoomsVacant <> 0
	|	AND MinCheckInDates2.BedsVacant <> 0
	|	AND MinCheckInDates2.BedsVacant < MinCheckInDates2.КоличествоМестНомер
	|	AND MinCheckInDates2.ПериодС >= &qPeriodFrom
	|	AND MinCheckInDates2.ПериодС <= &qPeriodTo
	|	AND MinCheckInDates2.Recorder <> &qCurDoc
	|	AND (MinCheckInDates2.Recorder REFS Document.Размещение
	|			OR MinCheckInDates2.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MIN(MinCheckInDates3.ПериодС) AS NextPeriodFrom3
	|INTO AfterCheckIn0ГруппаНомеров
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MinCheckInDates3
	|WHERE
	|	&qRoomIsFilled
	|	AND MinCheckInDates3.НомерРазмещения = &qRoom
	|	AND MinCheckInDates3.ТипНомера = &qRoomType
	|	AND NOT MinCheckInDates3.ТипНомера.ВиртуальныйНомер
	|	AND MinCheckInDates3.RecordType = &qExpense
	|	AND MinCheckInDates3.RoomsVacant = 0
	|	AND MinCheckInDates3.BedsVacant <> 0
	|	AND MinCheckInDates3.BedsVacant < MinCheckInDates3.КоличествоМестНомер
	|	AND MinCheckInDates3.ПериодС >= &qPeriodFrom
	|	AND MinCheckInDates3.ПериодС <= &qPeriodTo
	|	AND MinCheckInDates3.Recorder <> &qCurDoc
	|	AND (MinCheckInDates3.Recorder REFS Document.Размещение
	|			OR MinCheckInDates3.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MIN(MinCheckInDates4.ПериодС) AS NextPeriodFrom4
	|INTO AfterCheckIn0EmptyRoom
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MinCheckInDates4
	|WHERE
	|	MinCheckInDates4.НомерРазмещения = &qEmptyRoom
	|	AND MinCheckInDates4.ТипНомера = &qRoomType
	|	AND NOT MinCheckInDates4.ТипНомера.ВиртуальныйНомер
	|	AND MinCheckInDates4.RecordType = &qExpense
	|	AND MinCheckInDates4.RoomsVacant = 0
	|	AND MinCheckInDates4.BedsVacant <> 0
	|	AND MinCheckInDates4.BedsVacant < MinCheckInDates4.КоличествоМестНомер
	|	AND MinCheckInDates4.ПериодС >= &qPeriodFrom
	|	AND MinCheckInDates4.ПериодС <= &qPeriodTo
	|	AND MinCheckInDates4.Recorder <> &qCurDoc
	|	AND (MinCheckInDates4.Recorder REFS Document.Размещение
	|			OR MinCheckInDates4.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MAX(MaxCheckOutDates5.ПериодС) AS PrevPeriodFrom5
	|INTO BeforeCheckIn1ГруппаНомеров
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MaxCheckOutDates5
	|WHERE
	|	&qRoomIsFilled
	|	AND MaxCheckOutDates5.НомерРазмещения = &qRoom
	|	AND MaxCheckOutDates5.ТипНомера = &qRoomType
	|	AND NOT MaxCheckOutDates5.ТипНомера.ВиртуальныйНомер
	|	AND MaxCheckOutDates5.RecordType = &qExpense
	|	AND MaxCheckOutDates5.RoomsVacant <> 0
	|	AND MaxCheckOutDates5.BedsVacant <> 0
	|	AND MaxCheckOutDates5.BedsVacant < MaxCheckOutDates5.КоличествоМестНомер
	|	AND MaxCheckOutDates5.ПериодС <= &qPeriodFrom
	|	AND MaxCheckOutDates5.ПериодПо >= &qPeriodFrom
	|	AND MaxCheckOutDates5.Recorder <> &qCurDoc
	|	AND (MaxCheckOutDates5.Recorder REFS Document.Размещение
	|			OR MaxCheckOutDates5.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MAX(MaxCheckOutDates6.ПериодС) AS PrevPeriodFrom6
	|INTO BeforeCheckIn1EmptyRoom
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MaxCheckOutDates6
	|WHERE
	|	MaxCheckOutDates6.НомерРазмещения = &qEmptyRoom
	|	AND MaxCheckOutDates6.ТипНомера = &qRoomType
	|	AND NOT MaxCheckOutDates6.ТипНомера.ВиртуальныйНомер
	|	AND MaxCheckOutDates6.RecordType = &qExpense
	|	AND MaxCheckOutDates6.RoomsVacant <> 0
	|	AND MaxCheckOutDates6.BedsVacant <> 0
	|	AND MaxCheckOutDates6.BedsVacant < MaxCheckOutDates6.КоличествоМестНомер
	|	AND MaxCheckOutDates6.ПериодС <= &qPeriodFrom
	|	AND MaxCheckOutDates6.ПериодПо >= &qPeriodFrom
	|	AND MaxCheckOutDates6.Recorder <> &qCurDoc
	|	AND (MaxCheckOutDates6.Recorder REFS Document.Размещение
	|			OR MaxCheckOutDates6.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MAX(MaxCheckOutDates7.ПериодС) AS PrevPeriodFrom7
	|INTO BeforeCheckIn0ГруппаНомеров
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MaxCheckOutDates7
	|WHERE
	|	&qRoomIsFilled
	|	AND MaxCheckOutDates7.НомерРазмещения = &qRoom
	|	AND MaxCheckOutDates7.ТипНомера = &qRoomType
	|	AND NOT MaxCheckOutDates7.ТипНомера.ВиртуальныйНомер
	|	AND MaxCheckOutDates7.RecordType = &qExpense
	|	AND MaxCheckOutDates7.RoomsVacant = 0
	|	AND MaxCheckOutDates7.BedsVacant <> 0
	|	AND MaxCheckOutDates7.BedsVacant < MaxCheckOutDates7.КоличествоМестНомер
	|	AND MaxCheckOutDates7.ПериодС <= &qPeriodFrom
	|	AND MaxCheckOutDates7.ПериодПо >= &qPeriodFrom
	|	AND MaxCheckOutDates7.Recorder <> &qCurDoc
	|	AND (MaxCheckOutDates7.Recorder REFS Document.Размещение
	|			OR MaxCheckOutDates7.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MAX(MaxCheckOutDates8.ПериодС) AS PrevPeriodFrom8
	|INTO BeforeCheckIn0EmptyRoom
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS MaxCheckOutDates8
	|WHERE
	|	MaxCheckOutDates8.НомерРазмещения = &qEmptyRoom
	|	AND MaxCheckOutDates8.ТипНомера = &qRoomType
	|	AND NOT MaxCheckOutDates8.ТипНомера.ВиртуальныйНомер
	|	AND MaxCheckOutDates8.RecordType = &qExpense
	|	AND MaxCheckOutDates8.RoomsVacant = 0
	|	AND MaxCheckOutDates8.BedsVacant <> 0
	|	AND MaxCheckOutDates8.BedsVacant < MaxCheckOutDates8.КоличествоМестНомер
	|	AND MaxCheckOutDates8.ПериодС <= &qPeriodFrom
	|	AND MaxCheckOutDates8.ПериодПо >= &qPeriodFrom
	|	AND MaxCheckOutDates8.Recorder <> &qCurDoc
	|	AND (MaxCheckOutDates8.Recorder REFS Document.Размещение
	|			OR MaxCheckOutDates8.Recorder REFS Document.Бронирование)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	ЗагрузкаНомеров.Ref AS Ref,
	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate,
	|	ЗагрузкаНомеров.ДатаВыезда AS ДатаВыезда,
	|	ЗагрузкаНомеров.Ref.PointInTime AS PointInTime,
	|	ЗагрузкаНомеров.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	(SELECT
	|		AfterCheckInDocs1ГруппаНомеров.Recorder AS Ref,
	|		AfterCheckInDocs1ГруппаНомеров.НомерРазмещения AS НомерРазмещения,
	|		AfterCheckInDocs1ГруппаНомеров.ПериодС AS CheckInDate,
	|		AfterCheckInDocs1ГруппаНомеров.ПериодПо AS ДатаВыезда,
	|		1 AS ПорядокСортировки
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS AfterCheckInDocs1ГруппаНомеров
	|			INNER JOIN AfterCheckIn1ГруппаНомеров AS AfterCheckIn1ГруппаНомеров
	|			ON AfterCheckInDocs1ГруппаНомеров.ПериодС = AfterCheckIn1ГруппаНомеров.NextPeriodFrom1
	|	WHERE
	|		&qRoomIsFilled
	|		AND AfterCheckInDocs1ГруппаНомеров.НомерРазмещения = &qRoom
	|		AND AfterCheckInDocs1ГруппаНомеров.ТипНомера = &qRoomType
	|		AND NOT AfterCheckInDocs1ГруппаНомеров.ТипНомера.ВиртуальныйНомер
	|		AND AfterCheckInDocs1ГруппаНомеров.RecordType = &qExpense
	|		AND AfterCheckInDocs1ГруппаНомеров.RoomsVacant <> 0
	|		AND AfterCheckInDocs1ГруппаНомеров.BedsVacant <> 0
	|		AND AfterCheckInDocs1ГруппаНомеров.BedsVacant < AfterCheckInDocs1ГруппаНомеров.КоличествоМестНомер
	|		AND AfterCheckInDocs1ГруппаНомеров.ПериодС >= &qPeriodFrom
	|		AND AfterCheckInDocs1ГруппаНомеров.ПериодС <= &qPeriodTo
	|		AND AfterCheckInDocs1ГруппаНомеров.Recorder <> &qCurDoc
	|		AND (AfterCheckInDocs1ГруппаНомеров.Recorder REFS Document.Размещение
	|				OR AfterCheckInDocs1ГруппаНомеров.Recorder REFS Document.Бронирование)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		AfterCheckInDocs1EmptyRoom.Recorder,
	|		AfterCheckInDocs1EmptyRoom.НомерРазмещения,
	|		AfterCheckInDocs1EmptyRoom.ПериодС,
	|		AfterCheckInDocs1EmptyRoom.ПериодПо,
	|		2
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS AfterCheckInDocs1EmptyRoom
	|			INNER JOIN AfterCheckIn1EmptyRoom AS AfterCheckIn1EmptyRoom
	|			ON AfterCheckInDocs1EmptyRoom.ПериодС = AfterCheckIn1EmptyRoom.NextPeriodFrom2
	|	WHERE
	|		AfterCheckInDocs1EmptyRoom.НомерРазмещения = &qEmptyRoom
	|		AND AfterCheckInDocs1EmptyRoom.ТипНомера = &qRoomType
	|		AND NOT AfterCheckInDocs1EmptyRoom.ТипНомера.ВиртуальныйНомер
	|		AND AfterCheckInDocs1EmptyRoom.RecordType = &qExpense
	|		AND AfterCheckInDocs1EmptyRoom.RoomsVacant <> 0
	|		AND AfterCheckInDocs1EmptyRoom.BedsVacant <> 0
	|		AND AfterCheckInDocs1EmptyRoom.BedsVacant < AfterCheckInDocs1EmptyRoom.КоличествоМестНомер
	|		AND AfterCheckInDocs1EmptyRoom.ПериодС >= &qPeriodFrom
	|		AND AfterCheckInDocs1EmptyRoom.ПериодС <= &qPeriodTo
	|		AND AfterCheckInDocs1EmptyRoom.Recorder <> &qCurDoc
	|		AND (AfterCheckInDocs1EmptyRoom.Recorder REFS Document.Размещение
	|				OR AfterCheckInDocs1EmptyRoom.Recorder REFS Document.Бронирование)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		AfterCheckInDocs0ГруппаНомеров.Recorder,
	|		AfterCheckInDocs0ГруппаНомеров.НомерРазмещения,
	|		AfterCheckInDocs0ГруппаНомеров.ПериодС,
	|		AfterCheckInDocs0ГруппаНомеров.ПериодПо,
	|		3
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS AfterCheckInDocs0ГруппаНомеров
	|			INNER JOIN AfterCheckIn0ГруппаНомеров AS AfterCheckIn0ГруппаНомеров
	|			ON AfterCheckInDocs0ГруппаНомеров.ПериодС = AfterCheckIn0ГруппаНомеров.NextPeriodFrom3
	|	WHERE
	|		&qRoomIsFilled
	|		AND AfterCheckInDocs0ГруппаНомеров.НомерРазмещения = &qRoom
	|		AND AfterCheckInDocs0ГруппаНомеров.ТипНомера = &qRoomType
	|		AND NOT AfterCheckInDocs0ГруппаНомеров.ТипНомера.ВиртуальныйНомер
	|		AND AfterCheckInDocs0ГруппаНомеров.RecordType = &qExpense
	|		AND AfterCheckInDocs0ГруппаНомеров.RoomsVacant = 0
	|		AND AfterCheckInDocs0ГруппаНомеров.BedsVacant <> 0
	|		AND AfterCheckInDocs0ГруппаНомеров.BedsVacant < AfterCheckInDocs0ГруппаНомеров.КоличествоМестНомер
	|		AND AfterCheckInDocs0ГруппаНомеров.ПериодС >= &qPeriodFrom
	|		AND AfterCheckInDocs0ГруппаНомеров.ПериодС <= &qPeriodTo
	|		AND AfterCheckInDocs0ГруппаНомеров.Recorder <> &qCurDoc
	|		AND (AfterCheckInDocs0ГруппаНомеров.Recorder REFS Document.Размещение
	|				OR AfterCheckInDocs0ГруппаНомеров.Recorder REFS Document.Бронирование)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		AfterCheckInDocs0EmptyRoom.Recorder,
	|		AfterCheckInDocs0EmptyRoom.НомерРазмещения,
	|		AfterCheckInDocs0EmptyRoom.ПериодС,
	|		AfterCheckInDocs0EmptyRoom.ПериодПо,
	|		4
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS AfterCheckInDocs0EmptyRoom
	|			INNER JOIN AfterCheckIn0EmptyRoom AS AfterCheckIn0EmptyRoom
	|			ON AfterCheckInDocs0EmptyRoom.ПериодС = AfterCheckIn0EmptyRoom.NextPeriodFrom4
	|	WHERE
	|		AfterCheckInDocs0EmptyRoom.НомерРазмещения = &qEmptyRoom
	|		AND AfterCheckInDocs0EmptyRoom.ТипНомера = &qRoomType
	|		AND NOT AfterCheckInDocs0EmptyRoom.ТипНомера.ВиртуальныйНомер
	|		AND AfterCheckInDocs0EmptyRoom.RecordType = &qExpense
	|		AND AfterCheckInDocs0EmptyRoom.RoomsVacant = 0
	|		AND AfterCheckInDocs0EmptyRoom.BedsVacant <> 0
	|		AND AfterCheckInDocs0EmptyRoom.BedsVacant < AfterCheckInDocs0EmptyRoom.КоличествоМестНомер
	|		AND AfterCheckInDocs0EmptyRoom.ПериодС >= &qPeriodFrom
	|		AND AfterCheckInDocs0EmptyRoom.ПериодС <= &qPeriodTo
	|		AND AfterCheckInDocs0EmptyRoom.Recorder <> &qCurDoc
	|		AND (AfterCheckInDocs0EmptyRoom.Recorder REFS Document.Размещение
	|				OR AfterCheckInDocs0EmptyRoom.Recorder REFS Document.Бронирование)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		BeforeCheckInDocs1ГруппаНомеров.Recorder,
	|		BeforeCheckInDocs1ГруппаНомеров.НомерРазмещения,
	|		BeforeCheckInDocs1ГруппаНомеров.ПериодС,
	|		BeforeCheckInDocs1ГруппаНомеров.ПериодПо,
	|		5
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS BeforeCheckInDocs1ГруппаНомеров
	|			INNER JOIN BeforeCheckIn1ГруппаНомеров AS BeforeCheckIn1ГруппаНомеров
	|			ON BeforeCheckInDocs1ГруппаНомеров.ПериодС = BeforeCheckIn1ГруппаНомеров.PrevPeriodFrom5
	|	WHERE
	|		&qRoomIsFilled
	|		AND BeforeCheckInDocs1ГруппаНомеров.НомерРазмещения = &qRoom
	|		AND BeforeCheckInDocs1ГруппаНомеров.ТипНомера = &qRoomType
	|		AND NOT BeforeCheckInDocs1ГруппаНомеров.ТипНомера.ВиртуальныйНомер
	|		AND BeforeCheckInDocs1ГруппаНомеров.RecordType = &qExpense
	|		AND BeforeCheckInDocs1ГруппаНомеров.RoomsVacant <> 0
	|		AND BeforeCheckInDocs1ГруппаНомеров.BedsVacant <> 0
	|		AND BeforeCheckInDocs1ГруппаНомеров.BedsVacant < BeforeCheckInDocs1ГруппаНомеров.КоличествоМестНомер
	|		AND BeforeCheckInDocs1ГруппаНомеров.ПериодС >= &qPeriodFrom
	|		AND BeforeCheckInDocs1ГруппаНомеров.ПериодС <= &qPeriodTo
	|		AND BeforeCheckInDocs1ГруппаНомеров.Recorder <> &qCurDoc
	|		AND (BeforeCheckInDocs1ГруппаНомеров.Recorder REFS Document.Размещение
	|				OR BeforeCheckInDocs1ГруппаНомеров.Recorder REFS Document.Бронирование)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		BeforeCheckInDocs1EmptyRoom.Recorder,
	|		BeforeCheckInDocs1EmptyRoom.НомерРазмещения,
	|		BeforeCheckInDocs1EmptyRoom.ПериодС,
	|		BeforeCheckInDocs1EmptyRoom.ПериодПо,
	|		6
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS BeforeCheckInDocs1EmptyRoom
	|			INNER JOIN BeforeCheckIn1EmptyRoom AS BeforeCheckIn1EmptyRoom
	|			ON BeforeCheckInDocs1EmptyRoom.ПериодС = BeforeCheckIn1EmptyRoom.PrevPeriodFrom6
	|	WHERE
	|		BeforeCheckInDocs1EmptyRoom.НомерРазмещения = &qEmptyRoom
	|		AND BeforeCheckInDocs1EmptyRoom.ТипНомера = &qRoomType
	|		AND NOT BeforeCheckInDocs1EmptyRoom.ТипНомера.ВиртуальныйНомер
	|		AND BeforeCheckInDocs1EmptyRoom.RecordType = &qExpense
	|		AND BeforeCheckInDocs1EmptyRoom.RoomsVacant <> 0
	|		AND BeforeCheckInDocs1EmptyRoom.BedsVacant <> 0
	|		AND BeforeCheckInDocs1EmptyRoom.BedsVacant < BeforeCheckInDocs1EmptyRoom.КоличествоМестНомер
	|		AND BeforeCheckInDocs1EmptyRoom.ПериодС >= &qPeriodFrom
	|		AND BeforeCheckInDocs1EmptyRoom.ПериодС <= &qPeriodTo
	|		AND BeforeCheckInDocs1EmptyRoom.Recorder <> &qCurDoc
	|		AND (BeforeCheckInDocs1EmptyRoom.Recorder REFS Document.Размещение
	|				OR BeforeCheckInDocs1EmptyRoom.Recorder REFS Document.Бронирование)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		BeforeCheckInDocs0ГруппаНомеров.Recorder,
	|		BeforeCheckInDocs0ГруппаНомеров.НомерРазмещения,
	|		BeforeCheckInDocs0ГруппаНомеров.ПериодС,
	|		BeforeCheckInDocs0ГруппаНомеров.ПериодПо,
	|		7
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS BeforeCheckInDocs0ГруппаНомеров
	|			INNER JOIN BeforeCheckIn0ГруппаНомеров AS BeforeCheckIn0ГруппаНомеров
	|			ON BeforeCheckInDocs0ГруппаНомеров.ПериодС = BeforeCheckIn0ГруппаНомеров.PrevPeriodFrom7
	|	WHERE
	|		&qRoomIsFilled
	|		AND BeforeCheckInDocs0ГруппаНомеров.НомерРазмещения = &qRoom
	|		AND BeforeCheckInDocs0ГруппаНомеров.ТипНомера = &qRoomType
	|		AND NOT BeforeCheckInDocs0ГруппаНомеров.ТипНомера.ВиртуальныйНомер
	|		AND BeforeCheckInDocs0ГруппаНомеров.RecordType = &qExpense
	|		AND BeforeCheckInDocs0ГруппаНомеров.RoomsVacant = 0
	|		AND BeforeCheckInDocs0ГруппаНомеров.BedsVacant <> 0
	|		AND BeforeCheckInDocs0ГруппаНомеров.BedsVacant < BeforeCheckInDocs0ГруппаНомеров.КоличествоМестНомер
	|		AND BeforeCheckInDocs0ГруппаНомеров.ПериодС >= &qPeriodFrom
	|		AND BeforeCheckInDocs0ГруппаНомеров.ПериодС <= &qPeriodTo
	|		AND BeforeCheckInDocs0ГруппаНомеров.Recorder <> &qCurDoc
	|		AND (BeforeCheckInDocs0ГруппаНомеров.Recorder REFS Document.Размещение
	|				OR BeforeCheckInDocs0ГруппаНомеров.Recorder REFS Document.Бронирование)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		BeforeCheckInDocs0EmptyRoom.Recorder,
	|		BeforeCheckInDocs0EmptyRoom.НомерРазмещения,
	|		BeforeCheckInDocs0EmptyRoom.ПериодС,
	|		BeforeCheckInDocs0EmptyRoom.ПериодПо,
	|		8
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS BeforeCheckInDocs0EmptyRoom
	|			INNER JOIN BeforeCheckIn0EmptyRoom AS BeforeCheckIn0EmptyRoom
	|			ON BeforeCheckInDocs0EmptyRoom.ПериодС = BeforeCheckIn0EmptyRoom.PrevPeriodFrom8
	|	WHERE
	|		BeforeCheckInDocs0EmptyRoom.НомерРазмещения = &qEmptyRoom
	|		AND BeforeCheckInDocs0EmptyRoom.ТипНомера = &qRoomType
	|		AND NOT BeforeCheckInDocs0EmptyRoom.ТипНомера.ВиртуальныйНомер
	|		AND BeforeCheckInDocs0EmptyRoom.RecordType = &qExpense
	|		AND BeforeCheckInDocs0EmptyRoom.RoomsVacant = 0
	|		AND BeforeCheckInDocs0EmptyRoom.BedsVacant <> 0
	|		AND BeforeCheckInDocs0EmptyRoom.BedsVacant < BeforeCheckInDocs0EmptyRoom.КоличествоМестНомер
	|		AND BeforeCheckInDocs0EmptyRoom.ПериодС >= &qPeriodFrom
	|		AND BeforeCheckInDocs0EmptyRoom.ПериодС <= &qPeriodTo
	|		AND BeforeCheckInDocs0EmptyRoom.Recorder <> &qCurDoc
	|		AND (BeforeCheckInDocs0EmptyRoom.Recorder REFS Document.Размещение
	|				OR BeforeCheckInDocs0EmptyRoom.Recorder REFS Document.Бронирование)) AS ЗагрузкаНомеров
	|
	|GROUP BY
	|	ЗагрузкаНомеров.Ref,
	|	ЗагрузкаНомеров.НомерРазмещения,
	|	ЗагрузкаНомеров.CheckInDate,
	|	ЗагрузкаНомеров.ДатаВыезда,
	|	ЗагрузкаНомеров.Ref.PointInTime,
	|	ЗагрузкаНомеров.ПорядокСортировки
	|
	|ORDER BY
	|	ЗагрузкаНомеров.ПорядокСортировки,
	|	ЗагрузкаНомеров.CheckInDate,
	|	ЗагрузкаНомеров.Ref.PointInTime";
	vQry.SetParameter("qRoom", pPeriod.НомерРазмещения);
	vQry.SetParameter("qRoomIsFilled", ЗначениеЗаполнено(pPeriod.НомерРазмещения));
	vQry.SetParameter("qEmptyRoom", Справочники.НомернойФонд.EmptyRef());
	vQry.SetParameter("qRoomType", pPeriod.ТипНомера);
	vQry.SetParameter("qBeds", Перечисления.AccomodationTypes.Beds);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qPeriodFrom", pPeriod.CheckInDate);
	vQry.SetParameter("qPeriodTo", pPeriod.ДатаВыезда);
	vQry.SetParameter("qCurDoc", pPeriod.Ref);
	vQryTab = vQry.Execute().Unload();
	
	// Resume only one document of each search type (1 - 8)
	i = 0;
	vPrevTypeProcessed = 0;
	While i < vQryTab.Count() Do
		vQryRow = vQryTab.Get(i);
		If vPrevTypeProcessed <> vQryRow.ПорядокСортировки Тогда
			vPrevTypeProcessed = vQryRow.ПорядокСортировки;
		Else
			vQryTab.Delete(i);
			Continue;
		EndIf;
		i = i + 1;
	EndDo;
	vQryTab.GroupBy("Ref, НомерРазмещения, CheckInDate, ДатаВыезда, PointInTime", );
	
	// Add column to store document objects
	vQryTab.Columns.Add("DocObj");
	
	// Return resulting table
	Return vQryTab;
EndFunction //cmGetTableOfIntersectedDocs

//-----------------------------------------------------------------------------
// Description: Returns string with description of documents (accommodations and reservations) 
//              in the given ГруппаНомеров for the period specified
// Parameters: Гостиница, ГруппаНомеров type, ГруппаНомеров, Document reference, Start of period to check, End of period to check
// Return value: String with description
//-----------------------------------------------------------------------------
Function cmGetDescriptionOfRoomDocuments(pHotel, pRoomType, pRoom, pDoc, pPeriodFrom, pPeriodTo) Экспорт
	vStr = "";
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryByRoom.Recorder,
	|	RoomInventoryByRoom.ГруппаГостей,
	|	RoomInventoryByRoom.Клиент AS Клиент,
	|	CASE
	|		WHEN (NOT(RoomInventoryByRoom.СтатусРазмещения IS NULL 
	|					OR RoomInventoryByRoom.СтатусРазмещения = &qEmptyAccommodationStatus))
	|			THEN RoomInventoryByRoom.СтатусРазмещения
	|		WHEN (NOT(RoomInventoryByRoom.ReservationStatus IS NULL 
	|					OR RoomInventoryByRoom.ReservationStatus = &qEmptyReservationStatus))
	|			THEN RoomInventoryByRoom.ReservationStatus
	|		WHEN (NOT(RoomInventoryByRoom.RoomBlockType IS NULL 
	|					OR RoomInventoryByRoom.RoomBlockType = &qEmptyRoomBlockType))
	|			THEN RoomInventoryByRoom.RoomBlockType
	|		ELSE NULL
	|	END AS Status,
	|	MIN(RoomInventoryByRoom.CheckInDate) AS CheckInDate,
	|	MAX(RoomInventoryByRoom.ДатаВыезда) AS ДатаВыезда
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryByRoom
	|WHERE
	|	RoomInventoryByRoom.Гостиница = &qHotel
	|	AND RoomInventoryByRoom.НомерРазмещения = &qRoom
	|	AND RoomInventoryByRoom.ТипНомера = &qRoomType
	|	AND RoomInventoryByRoom.RecordType = &qExpense
	|	AND RoomInventoryByRoom.CheckInDate < &qPeriodTo
	|	AND (RoomInventoryByRoom.ДатаВыезда > &qPeriodFrom
	|			OR RoomInventoryByRoom.Recorder.ДатаКонКвоты = &qEmptyDate)
	|	AND RoomInventoryByRoom.Recorder <> &qDoc
	|
	|GROUP BY
	|	RoomInventoryByRoom.Recorder,
	|	RoomInventoryByRoom.ГруппаГостей,
	|	RoomInventoryByRoom.Клиент,
	|	CASE
	|		WHEN (NOT(RoomInventoryByRoom.СтатусРазмещения IS NULL 
	|					OR RoomInventoryByRoom.СтатусРазмещения = &qEmptyAccommodationStatus))
	|			THEN RoomInventoryByRoom.СтатусРазмещения
	|		WHEN (NOT(RoomInventoryByRoom.ReservationStatus IS NULL 
	|					OR RoomInventoryByRoom.ReservationStatus = &qEmptyReservationStatus))
	|			THEN RoomInventoryByRoom.ReservationStatus
	|		WHEN (NOT(RoomInventoryByRoom.RoomBlockType IS NULL 
	|					OR RoomInventoryByRoom.RoomBlockType = &qEmptyRoomBlockType))
	|			THEN RoomInventoryByRoom.RoomBlockType
	|		ELSE NULL
	|	END
	|
	|ORDER BY
	|	CheckInDate,
	|	ДатаВыезда";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qDoc", pDoc);
	vQry.SetParameter("qEmptyAccommodationStatus", Справочники.AccommodationStatuses.EmptyRef());
	vQry.SetParameter("qEmptyReservationStatus", Справочники.СтатусБрони.EmptyRef());
	vQry.SetParameter("qEmptyRoomBlockType", Справочники.ВидБлокНомеров.EmptyRef());
	vQryTab = vQry.Execute().Unload();
	For Each vRow In vQryTab Do
		vStr = vStr + СокрЛП(vRow.Status) + ", " + Format(vRow.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(vRow.CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + ", " + СокрЛП(vRow.GuestGroup) + " - " + СокрЛП(vRow.Guest) + Chars.LF;
	EndDo;
	Return vStr;		
EndFunction //cmGetDescriptionOfRoomDocuments

//-----------------------------------------------------------------------------
// Description: Checks if it is possible to check-in to the given ГруппаНомеров
// Parameters: Гостиница, ГруппаНомеров type, ГруппаНомеров, Document reference, Whether document is 
//             posted or not, Whether to check ГруппаНомеров availability only or also
//             check number of vacant rooms for the ГруппаНомеров type given,
//             Number of persons in the document being checked,
//             Number of rooms in the document being checked,
//             Number of beds in the document being checked,
//             Number of additional beds in the document being checked,
//             Number of beds per ГруппаНомеров, Number of persons per ГруппаНомеров, 
//             Start of period to check, End of period to check,
//             Message text in russian language to be returned in case of error,
//             Message text in english language to be returned in case of error,
//             Whether current user has permission to check-in to the occupied rooms or not,
//             Whether current user has permission to do overbooking or not,
//             Whether current user has permission to ignore maximum number of 
//             guests per ГруппаНомеров limitation or not
// Return value: True if rooms are available, False if not
//-----------------------------------------------------------------------------
Function cmCheckRoomAvailability(pHotel, pRoomQuota, pRoomType, pRoom, pDoc, pIsPosted, pCheckRoomTypeBalances, 
                                 pNumberOfPersons, pNumberOfRooms, pNumberOfBeds, pNumberOfAdditionalBeds, 
                                 pNumberOfBedsPerRoom, pNumberOfPersonsPerRoom, 
                                 pDateFrom, pDateTo, rMsgTextRu, rMsgTextEn, rMsgTextDe, 
								 pHavePermissionToUseOccupiedRooms = Неопределено, 
								 pHavePermissionToDoOverbooking = Неопределено,
								 pHavePermissionToIgnoreNumberOfGuestsPerRoomLimits = Неопределено) Экспорт
	// Check period
	If pDateFrom >= pDateTo Тогда
		Return True;
	EndIf;
								 
	// Initialize working variables
	vOK = True;
	vRoomsVacant = 0;
	vBedsVacant = 0;
	vGuestsVacant = 0;
	
	// Retrieve all necessary permissions
	vHavePermissionToUseOccupiedRooms = cmCheckUserPermissions("HavePermissionToUseOccupiedRooms");
	vHavePermissionToDoOverbooking = cmCheckUserPermissions("HavePermissionToDoOverbooking");
	vHavePermissionToIgnoreNumberOfGuestsPerRoomLimits = cmCheckUserPermissions("HavePermissionToIgnoreNumberOfGuestsPerRoomLimits");
	
	// Take permissions from parameters
	If pHavePermissionToUseOccupiedRooms <> Неопределено Тогда
		vHavePermissionToUseOccupiedRooms = pHavePermissionToUseOccupiedRooms;
	EndIf;
	If pHavePermissionToDoOverbooking <> Неопределено Тогда
		vHavePermissionToDoOverbooking = pHavePermissionToDoOverbooking;
	EndIf;
	If pHavePermissionToIgnoreNumberOfGuestsPerRoomLimits <> Неопределено Тогда
		vHavePermissionToIgnoreNumberOfGuestsPerRoomLimits = pHavePermissionToIgnoreNumberOfGuestsPerRoomLimits;
	EndIf;
	
	// Build and run query to check ГруппаНомеров inventory
	If ЗначениеЗаполнено(pRoom) And НЕ pRoom.ВиртуальныйНомер Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	RoomInventoryBalance.Гостиница AS Гостиница,
		|	RoomInventoryBalance.ТипНомера AS ТипНомера,
		|	RoomInventoryBalance.НомерРазмещения AS НомерРазмещения,
		|	MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
		|	MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS ВсегоМест,
		|	MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS ВсегоНомеров,
		|	MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant,
		|	MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
		|	MIN(RoomInventoryBalance.GuestsVacantClosingBalance) AS GuestsVacant
		|FROM
		|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
		|			&qDateFrom,
		|			&qDateTo,
		|			Second,
		|			RegisterRecordsAndPeriodBoundaries,
		|			Гостиница = &qHotel
		|				AND ТипНомера = &qRoomType
		|				AND НомерРазмещения = &qRoom) AS RoomInventoryBalance
		|
		|GROUP BY
		|	RoomInventoryBalance.Гостиница,
		|	RoomInventoryBalance.ТипНомера,
		|	RoomInventoryBalance.НомерРазмещения";
		
		vQry.SetParameter("qHotel", pHotel);
		vQry.SetParameter("qRoomType", pRoomType);
		vQry.SetParameter("qRoom", pRoom);
		vQry.SetParameter("qDateFrom", pDateFrom);
		vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
		
		vQryTab = vQry.Execute().Unload();
		For Each vQryTabRow In vQryTab Do
			vRoomsVacant = vQryTabRow.RoomsVacant;
			vBedsVacant = vQryTabRow.BedsVacant;
			vGuestsVacant = vQryTabRow.GuestsVacant;
			Break;
		EndDo;

		// Check ГруппаНомеров inventory
		vNotEnoughRooms = 0;
		vNotEnoughBeds = 0;
		vNotEnoughGuests = 0;
		If pIsPosted Тогда
			vNotEnoughRooms = -vRoomsVacant;
			vNotEnoughBeds = -vBedsVacant;
			vNotEnoughGuests = -vGuestsVacant;
		Else
			vNotEnoughRooms = pNumberOfRooms - vRoomsVacant;
			vNotEnoughBeds = pNumberOfBeds - vBedsVacant;
			vNotEnoughGuests = pNumberOfPersons - vGuestsVacant;
		EndIf;
		
		vMsgTextRu = "НомерРазмещения " + СокрЛП(pRoom) + " занят!";
		vMsgTextEn = "НомерРазмещения " + СокрЛП(pRoom) + " is occupied!";
		vMsgTextDe = "НомерРазмещения " + СокрЛП(pRoom) + " is occupied!";
		
		If pNumberOfRooms > 0 Тогда
			If vNotEnoughRooms > 0 Тогда
				vDesc = Chars.LF + Chars.LF + cmGetDescriptionOfRoomDocuments(pHotel, pRoomType, pRoom, pDoc, pDateFrom, pDateTo);
				vMsgTextRu = vMsgTextRu + vDesc;
				vMsgTextEn = vMsgTextEn + vDesc;
				vMsgTextDe = vMsgTextDe + vDesc;
				vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
				If НЕ vHavePermissionToUseOccupiedRooms And ЗначениеЗаполнено(pRoom) Тогда
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
					Else
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
					vOK = False;
					rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
					rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
					rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
				Else
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
						If cmShowNotEnoughRoomsMessages() Тогда
							Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
						EndIf;
					Else
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
				EndIf;
			ElsIf vNotEnoughBeds > 0 Тогда
				vMsgTextRu = vMsgTextRu + Chars.LF + "В номере не хватает " + vNotEnoughBeds + " свободных мест!";
				vMsgTextEn = vMsgTextEn + Chars.LF + vNotEnoughBeds + " vacant beds are not available!";
				vMsgTextDe = vMsgTextDe + Chars.LF + vNotEnoughBeds + " vacant beds are not available!";
				vDesc = Chars.LF + Chars.LF + cmGetDescriptionOfRoomDocuments(pHotel, pRoomType, pRoom, pDoc, pDateFrom, pDateTo);
				vMsgTextRu = vMsgTextRu + vDesc;
				vMsgTextEn = vMsgTextEn + vDesc;
				vMsgTextDe = vMsgTextDe + vDesc;
				vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
				If НЕ vHavePermissionToUseOccupiedRooms And ЗначениеЗаполнено(pRoom) Тогда
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
					Else
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
					vOK = False;
					rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
					rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
					rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
				Else
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
						If cmShowNotEnoughRoomsMessages() Тогда
							Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
						EndIf;
					Else
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
				EndIf;
			EndIf;
		ElsIf pNumberOfBeds > 0 Тогда
			If vNotEnoughBeds > 0 Тогда
				vMsgTextRu = vMsgTextRu + Chars.LF + "В номере не хватает " + vNotEnoughBeds + " свободных мест!";
				vMsgTextEn = vMsgTextEn + Chars.LF + vNotEnoughBeds + " vacant beds are not available!";
				vMsgTextDe = vMsgTextDe + Chars.LF + vNotEnoughBeds + " vacant beds are not available!";
				vDesc = Chars.LF + Chars.LF + cmGetDescriptionOfRoomDocuments(pHotel, pRoomType, pRoom, pDoc, pDateFrom, pDateTo);
				vMsgTextRu = vMsgTextRu + vDesc;
				vMsgTextEn = vMsgTextEn + vDesc;
				vMsgTextDe = vMsgTextDe + vDesc;
				vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
				If НЕ vHavePermissionToUseOccupiedRooms And ЗначениеЗаполнено(pRoom) Тогда
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
					Else
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
					vOK = False;
					rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
					rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
					rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
				Else
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
						If cmShowNotEnoughRoomsMessages() Тогда
							Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
						EndIf;
					Else
						WriteLogEvent(NStr("en='RoomInventory.RoomIsOccupied';ru='НомернойФонд.НомерЗанят';de='RoomInventory.RoomIsOccupied'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	
		// Check number of guests per ГруппаНомеров
		If vNotEnoughGuests > 0 Тогда
			vMsgTextRu = "В номере " + СокрЛП(pRoom);
			vMsgTextEn = "НомерРазмещения " + СокрЛП(pRoom) + " is occupied!";
			vMsgTextDe = "НомерРазмещения " + СокрЛП(pRoom) + " is occupied!";
			vMsgTextRu = vMsgTextRu + " невозможно разместить " + vNotEnoughGuests + " гостей!" + Chars.LF + 
			             "Максимальное число гостей в номере " + pNumberOfPersonsPerRoom + Chars.LF + 
			             "Уже размещено в номере " + (pNumberOfPersonsPerRoom - pNumberOfPersons + vNotEnoughGuests) + Chars.LF + 
			             "Необходимо разместить " + pNumberOfPersons + " гостей";
			vMsgTextEn = vMsgTextEn + " Unable to check-in " + vNotEnoughGuests + " guests!" + Chars.LF +  
			             "Maximum number of guests per НомерРазмещения is " + pNumberOfPersonsPerRoom + Chars.LF + 
			             "Guests already in НомерРазмещения " + (pNumberOfPersonsPerRoom - pNumberOfPersons + vNotEnoughGuests) + Chars.LF + 
			             "It is necessary to check in " + pNumberOfPersons + " guests!";
			vMsgTextDe = vMsgTextDe + " Unable to check-in " + vNotEnoughGuests + " guests!" + Chars.LF +  
			             "Maximum number of guests per НомерРазмещения is " + pNumberOfPersonsPerRoom + Chars.LF + 
			             "Guests already in НомерРазмещения " + (pNumberOfPersonsPerRoom - pNumberOfPersons + vNotEnoughGuests) + Chars.LF + 
			             "It is necessary to check in " + pNumberOfPersons + " guests!";
			vDesc = Chars.LF + Chars.LF + cmGetDescriptionOfRoomDocuments(pHotel, pRoomType, pRoom, pDoc, pDateFrom, pDateTo);
			vMsgTextRu = vMsgTextRu + vDesc;
			vMsgTextEn = vMsgTextEn + vDesc;
			vMsgTextDe = vMsgTextDe + vDesc;
			vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
			If НЕ vHavePermissionToIgnoreNumberOfGuestsPerRoomLimits Тогда
				vOK = False;
				rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
				rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
				rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
			Else
				If ЗначениеЗаполнено(pDoc) Тогда
					WriteLogEvent(NStr("en='Document.Posting';ru='Документ.Проведение';de='Document.Posting'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
					If cmShowNotEnoughRoomsMessages() Тогда
						Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
					EndIf;
				Else
					WriteLogEvent(NStr("en='Document.Posting';ru='Документ.Проведение';de='Document.Posting'"), EventLogLevel.Warning, , , vMessage);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	
	// Check ГруппаНомеров type balances
	If НЕ ЗначениеЗаполнено(pRoomQuota) And ЗначениеЗаполнено(pRoomType) And НЕ pRoomType.ВиртуальныйНомер Тогда
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	RoomInventoryBalance.Гостиница AS Гостиница,
		|	RoomInventoryBalance.ТипНомера AS ТипНомера,
		|	MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
		|	MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS ВсегоМест,
		|	MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS ВсегоНомеров,
		|	MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant,
		|	MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
		|	MIN(RoomInventoryBalance.GuestsVacantClosingBalance) AS GuestsVacant
		|FROM
		|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
		|			&qDateFrom,
		|			&qDateTo,
		|			Second,
		|			RegisterRecordsAndPeriodBoundaries,
		|			Гостиница = &qHotel
		|				AND ТипНомера = &qRoomType) AS RoomInventoryBalance
		|
		|GROUP BY
		|	RoomInventoryBalance.Гостиница,
		|	RoomInventoryBalance.ТипНомера";
		
		vQry.SetParameter("qHotel", pHotel);
		vQry.SetParameter("qRoomType", pRoomType);
		vQry.SetParameter("qDateFrom", pDateFrom);
		vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
		
		vQryTab = vQry.Execute().Unload();
		For Each vQryTabRow In vQryTab Do
			vRoomsVacant = vQryTabRow.RoomsVacant;
			vBedsVacant = vQryTabRow.BedsVacant;
			vGuestsVacant = vQryTabRow.GuestsVacant;
			Break;
		EndDo;

		// Check ГруппаНомеров type inventory
		vNotEnoughRooms = 0;
		vNotEnoughBeds = 0;
		If pIsPosted Тогда
			vNotEnoughRooms = -vRoomsVacant;
			vNotEnoughBeds = -vBedsVacant;
		Else
			vNotEnoughRooms = pNumberOfRooms - vRoomsVacant;
			vNotEnoughBeds = pNumberOfBeds - vBedsVacant;
		EndIf;
		
		vMsgTextRu = "";
		vMsgTextEn = "";
		vMsgTextDe = "";
		If ЗначениеЗаполнено(pRoomType) Тогда
			vMsgTextRu = "По типу номера " + СокрЛП(pRoomType);
			vMsgTextEn = "For НомерРазмещения type " + СокрЛП(pRoomType);
			vMsgTextDe = "For НомерРазмещения type " + СокрЛП(pRoomType);
		Else
			vMsgTextRu = "Всего";
			vMsgTextEn = "Total";
			vMsgTextDe = "Total";
		EndIf;
		
		If pNumberOfRooms > 0 Тогда
			If vNotEnoughRooms > 0 Тогда
				vMsgTextRu = vMsgTextRu + " не хватает " + vNotEnoughRooms + " свободных номеров!";
				vMsgTextEn = vMsgTextEn + " " + vNotEnoughRooms + " vacant НомернойФонд are not available!";
				vMsgTextDe = vMsgTextDe + " " + vNotEnoughRooms + " vacant НомернойФонд are not available!";
				vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
				If НЕ vHavePermissionToDoOverbooking And pCheckRoomTypeBalances Тогда
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
					Else
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
					vOK = False;
					rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
					rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
					rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
				Else
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
						If cmShowNotEnoughRoomsMessages() Тогда
							Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
						EndIf;
					Else
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
				EndIf;
			ElsIf vNotEnoughBeds > 0 Тогда
				vMsgTextRu = vMsgTextRu + " не хватает " + vNotEnoughBeds + " свободных мест!";
				vMsgTextEn = vMsgTextEn + " " + vNotEnoughBeds + " vacant beds are not available!";
				vMsgTextDe = vMsgTextDe + " " + vNotEnoughBeds + " vacant beds are not available!";
				vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
				If НЕ vHavePermissionToDoOverbooking And pCheckRoomTypeBalances Тогда
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
					Else
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, , , vMessage);
					EndIf;						
					vOK = False;
					rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
					rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
					rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
				Else
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
						If cmShowNotEnoughRoomsMessages() Тогда
							Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
						EndIf;
					Else
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, , , vMessage);
					EndIf;						
				EndIf;
			EndIf;
		ElsIf pNumberOfBeds > 0 Тогда
			If vNotEnoughBeds > 0 Тогда
				vMsgTextRu = vMsgTextRu + " не хватает " + vNotEnoughBeds + " свободных мест!";
				vMsgTextEn = vMsgTextEn + " " + vNotEnoughBeds + " vacant beds are not available!";
				vMsgTextDe = vMsgTextDe + " " + vNotEnoughBeds + " vacant beds are not available!";
				vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
				If НЕ vHavePermissionToDoOverbooking And pCheckRoomTypeBalances Тогда
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
					Else
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
					vOK = False;
					rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
					rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
					rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
				Else
					If ЗначениеЗаполнено(pDoc) Тогда
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
						If cmShowNotEnoughRoomsMessages() Тогда
							Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
						EndIf;
					Else
						WriteLogEvent(NStr("en='RoomInventory.NoVacantRooms';ru='НомернойФонд.НетСвободныхНомеров';de='RoomInventory.NoVacantRooms'"), EventLogLevel.Warning, , , vMessage);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	
	// OK
	Return vOK;
EndFunction //cmCheckRoomAvailability

//-----------------------------------------------------------------------------
// Description: Returns value table with active ГруппаНомеров blocks
// Parameters: Гостиница, ГруппаНомеров type, ГруппаНомеров, Start of period, End of period
//             Rooms value list
// Return value: Value table with ГруппаНомеров block documents found
//-----------------------------------------------------------------------------
Function cmGetRoomBlocks(pHotel, pRoomType, pRoom, pDateFrom, pDateTo, pRooms = Неопределено) Экспорт
	// Build and run query to check ГруппаНомеров blocks
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder AS БлокНомер,
	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера, 
	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения, 
	|	ЗагрузкаНомеров.RoomBlockType AS RoomBlockType, 
	|	ЗагрузкаНомеров.RoomBlockType.ПорядокСортировки AS RoomBlockTypeSortCode, 
	|	ЗагрузкаНомеров.CheckInDate AS ДатаНачКвоты, 
	|	ЗагрузкаНомеров.ДатаВыезда AS ДатаКонКвоты, 
	|	ЗагрузкаНомеров.Примечания AS Примечания 
	|
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|
	|WHERE
	|	ЗагрузкаНомеров.IsBlocking = TRUE AND " +
		?(ЗначениеЗаполнено(pHotel), "ЗагрузкаНомеров.Гостиница IN HIERARCHY(&qHotel) AND ", "") +
		?(ЗначениеЗаполнено(pRoomType), "ЗагрузкаНомеров.ТипНомера IN HIERARCHY(&qRoomType) AND ", "") +
		?(ЗначениеЗаполнено(pRoom), "ЗагрузкаНомеров.НомерРазмещения IN HIERARCHY(&qRoom) AND ", "") + 
		?(pRooms <> Неопределено, "ЗагрузкаНомеров.НомерРазмещения IN (&qRooms) AND ", "") + "
	|	ЗагрузкаНомеров.RecordType = &qExpense AND " + 
		?(ЗначениеЗаполнено(pDateTo), "ЗагрузкаНомеров.CheckInDate < &qDateTo AND ", "") + "
	|	(ЗагрузкаНомеров.ДатаВыезда > &qDateFrom OR ЗагрузкаНомеров.ДатаВыезда = &qEmptyDate)
	|
	|ORDER BY
	|	RoomBlockTypeSortCode";
	
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qRooms", pRooms);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", pDateTo);
	vQry.SetParameter("qEmptyDate", Date(1, 1, 1));
	
	vQryTab = vQry.Execute().Unload();
	
	// Return
	Return vQryTab;
EndFunction //cmGetRoomBlocks

//-----------------------------------------------------------------------------
// Description: Returns value table with accommodations intersecting by period with
//              input parameter period and for the given hotel, ГруппаНомеров type,
//              ГруппаНомеров or rooms list
// Parameters: Гостиница, ГруппаНомеров type, ГруппаНомеров, Start of period, End of period,
//             Rooms value list
// Return value: Value table with accommodations found
//-----------------------------------------------------------------------------
Function cmGetRoomGuests(pHotel, pRoomType, pRoom, pDateFrom, pDateTo, pRooms = Неопределено) Экспорт
	// Build and run query to get ГруппаНомеров guests
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder AS Размещение,
	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера, 
	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения, 
	|	ЗагрузкаНомеров.Клиент AS Клиент, 
	|	ЗагрузкаНомеров.Контрагент AS Контрагент, 
	|	ЗагрузкаНомеров.ГруппаГостей.Description AS GuestGroupDescription, 
	|	ЗагрузкаНомеров.CheckInDate AS ДатаНачКвоты, 
	|	ЗагрузкаНомеров.ДатаВыезда AS ДатаКонКвоты, 
	|	ЗагрузкаНомеров.КоличествоЧеловек AS КоличествоЧеловек 
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.IsAccommodation = TRUE AND " +
		?(ЗначениеЗаполнено(pHotel), "ЗагрузкаНомеров.Гостиница IN HIERARCHY(&qHotel) AND ", "") +
		?(ЗначениеЗаполнено(pRoomType), "ЗагрузкаНомеров.ТипНомера IN HIERARCHY(&qRoomType) AND ", "") +
		?(ЗначениеЗаполнено(pRoom), "ЗагрузкаНомеров.НомерРазмещения IN HIERARCHY(&qRoom) AND ", "") + 
		?(pRooms <> Неопределено, "ЗагрузкаНомеров.НомерРазмещения IN (&qRooms) AND ", "") + "
	|	ЗагрузкаНомеров.RecordType = &qExpense AND 
	|	ЗагрузкаНомеров.ПериодС < &qDateTo AND 
	|	ЗагрузкаНомеров.ПериодПо > &qDateFrom
	|ORDER BY
	|	ЗагрузкаНомеров.НомерРазмещения.ПорядокСортировки,
	|	ЗагрузкаНомеров.CheckInDate,
	|	ЗагрузкаНомеров.Клиент.Description";
	
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qRooms", pRooms);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", pDateTo);
	
	vQryTab = vQry.Execute().Unload();
	
	// Return
	Return vQryTab;
EndFunction //cmGetRoomGuests

//-----------------------------------------------------------------------------
// Description: Returns value table with in-house accommodations with check-in 
//              date after specified one
// Parameters: Гостиница, ГруппаНомеров type, ГруппаНомеров, Period
// Return value: Value table with accommodations found
//-----------------------------------------------------------------------------
Function cmGetRoomNextGuests(pHotel, pRoomType, pRoom, pDate) Экспорт
	// Build and run query to get ГруппаНомеров guests
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder AS Размещение,
	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
	|	ЗагрузкаНомеров.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Контрагент AS Контрагент,
	|	ЗагрузкаНомеров.ГруппаГостей.Description AS GuestGroupDescription,
	|	ЗагрузкаНомеров.CheckInDate AS ДатаНачКвоты,
	|	ЗагрузкаНомеров.ДатаВыезда AS ДатаКонКвоты,
	|	ЗагрузкаНомеров.КоличествоЧеловек AS КоличествоЧеловек
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.IsAccommodation
	|	AND ЗагрузкаНомеров.ЭтоГости
	|	AND ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.ТипНомера = &qRoomType
	|	AND ЗагрузкаНомеров.НомерРазмещения = &qRoom
	|	AND ЗагрузкаНомеров.RecordType = &qExpense
	|	AND ЗагрузкаНомеров.CheckInDate > &qDate
	|
	|ORDER BY
	|	ЗагрузкаНомеров.НомерРазмещения.ПорядокСортировки,
	|	ЗагрузкаНомеров.CheckInDate,
	|	ЗагрузкаНомеров.Клиент.Description";
	
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qDate", pDate);
	
	vQryTab = vQry.Execute().Unload();
	
	// Return
	Return vQryTab;
EndFunction //cmGetRoomNextGuests

//-----------------------------------------------------------------------------
// Description: Returns ГруппаНомеров presentation string consisting of number of in-house
//              guests for the giving period per guest sex and Гражданство
// Parameters: Гостиница, ГруппаНомеров, Date & time, Returns number of occupied beds in the ГруппаНомеров, 
//             Returns number of in-house persons
// Return value: ГруппаНомеров presentation string
//-----------------------------------------------------------------------------
Function cmGetRoomPresentation(pHotel, pRoom, Val pPeriod = Неопределено, rOccupiedBeds = 0, rOccupiedPersons = 0) Экспорт
	If pPeriod = Неопределено Тогда
		pPeriod = CurrentDate();
	EndIf;
	// Build and run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Клиент.Sex AS Sex,
	|	ЗагрузкаНомеров.Клиент.Гражданство.ISOCode AS Country,
	|	SUM(ЗагрузкаНомеров.КоличествоЧеловек) AS КоличествоЧеловек,
	|	SUM(ЗагрузкаНомеров.КоличествоМест) AS КоличествоМест
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.НомерРазмещения = &qRoom
	|	AND ЗагрузкаНомеров.RecordType = &qExpense
	|	AND ЗагрузкаНомеров.Period = ЗагрузкаНомеров.ПериодС
	|	AND ЗагрузкаНомеров.ПериодС <= &qPeriod
	|	AND ЗагрузкаНомеров.ПериодПо > &qPeriod
	|	AND ЗагрузкаНомеров.IsAccommodation
	|
	|GROUP BY
	|	ЗагрузкаНомеров.Клиент.Sex,
	|	ЗагрузкаНомеров.Клиент.Гражданство.ISOCode";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qPeriod", pPeriod);
	vQryTab = vQry.Execute().Unload();
	
	rOccupiedBeds = 0;
	rOccupiedPersons = 0;
	vRoomStr = СокрЛП(pRoom);
	
	If vQryTab.Count() > 0 Тогда
		rOccupiedBeds = vQryTab.Total("КоличествоМест");
		rOccupiedPersons = vQryTab.Total("КоличествоЧеловек");
		vRoomStr = vRoomStr + " -";
		
		For Each vRow In vQryTab Do
			vRoomStr = vRoomStr + " " + Format(vRow.NumberOfPersons, "ND=6; NFD=0") + ?(ЗначениеЗаполнено(vRow.Country), "(" + vRow.Country + ")", "") + ?(ЗначениеЗаполнено(vRow.Sex), Left(String(vRow.Sex), 1), "?");
		EndDo;
	EndIf;
	
	Return vRoomStr;
EndFunction //cmGetRoomPresentation

//-----------------------------------------------------------------------------
// Description: Returns hotel by external system hotel code
// Parameters: Гостиница code, External system code 
// Return value: Гостиница reference
//-----------------------------------------------------------------------------
Function cmGetHotelByCode(pHotel, pExternalSystemCode = "") Экспорт
	vHotel = Справочники.Hotels.EmptyRef();
	If pHotel = Неопределено Тогда
		pHotel = "";
	EndIf;
	If НЕ IsBlankString(pHotel) Тогда
		// Try to find hotel in the mapping information register
		If НЕ IsBlankString(pExternalSystemCode) Тогда
			vHotel = cmGetObjectRefByExternalSystemCode(Справочники.Hotels.EmptyRef(), pExternalSystemCode, "Hotels", pHotel);
		EndIf;
		// Find hotel by code
		If НЕ ЗначениеЗаполнено(vHotel) Тогда
			vHotel = Справочники.Hotels.FindByCode(pHotel);
			If НЕ ЗначениеЗаполнено(vHotel) Тогда
				vHotel = Справочники.Hotels.FindByDescription(pHotel, True);
			EndIf;
		EndIf;
	EndIf;
	// Take hotel from the system parameters
	If НЕ ЗначениеЗаполнено(vHotel) Тогда
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	Return vHotel;
EndFunction //cmGetHotelByCode

//-----------------------------------------------------------------------------
// Description: Returns ГруппаНомеров by ГруппаНомеров description and hotel
// Parameters: ГруппаНомеров description, Гостиница
// Return value: ГруппаНомеров reference
//-----------------------------------------------------------------------------
Function cmGetRoomByCode(pRoomCode, Val pHotel = "", pExtSystemCode = "") Экспорт
	// Find hotel by code
	vHotel = cmGetHotelByCode(pHotel, pExtSystemCode);
	// Find ГруппаНомеров by code
	vRoom = Справочники.НомернойФонд.EmptyRef();
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	НомернойФонд.Ref
	|FROM
	|	Catalog.НомернойФонд AS НомернойФонд
	|WHERE
	|	НомернойФонд.Description = &qRoomCode
	|	AND (NOT НомернойФонд.DeletionMark)
	|	AND (NOT НомернойФонд.IsFolder)
	|	AND НомернойФонд.Owner = &qHotel";
	vQry.SetParameter("qRoomCode", pRoomCode);
	vQry.SetParameter("qHotel", vHotel);
	vRooms = vQry.Execute().Unload();
	If vRooms.Count() > 0 Тогда
		vRoom = vRooms.Get(0).Ref;
	Else
		vRoom = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "НомернойФонд", TrimR(pRoomCode));
		If НЕ ЗначениеЗаполнено(vRoom) Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	НомернойФонд.Ref
			|FROM
			|	Catalog.НомернойФонд AS НомернойФонд
			|WHERE
			|	НомернойФонд.Description = &qRoomCode
			|	AND (NOT НомернойФонд.DeletionMark)
			|	AND (NOT НомернойФонд.IsFolder)";
			vQry.SetParameter("qRoomCode", pRoomCode);
			vRooms = vQry.Execute().Unload();
			If vRooms.Count() > 0 Тогда
				vRoom = vRooms.Get(0).Ref;
			EndIf;
		EndIf;
	EndIf;
	Return vRoom;
EndFunction //cmGetRoomByCode

//-----------------------------------------------------------------------------
// Description: Sets catalog list control owner filter to the current hotel
// Parameters: Form
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmSetDefaultOwnerHotel(pForm) Экспорт
	vCurHotel = ПараметрыСеанса.ТекущаяГостиница;
	If ЗначениеЗаполнено(vCurHotel) Тогда
		vFlt = pForm.ЭлементыФормы.CatalogList.Value.Filter.Owner;
		vFlt.ComparisonType = ComparisonType.Equal;
		vFlt.Value = vCurHotel;
		vFlt.Use = True;
	EndIf;
КонецПроцедуры //cmSetDefaultOwnerHotel

//-----------------------------------------------------------------------------
// Description: Returns value table with all hotels
// Parameters: None
// Return value: Value table with hotels
//-----------------------------------------------------------------------------
Function cmGetAllHotels() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	Hotels.Ref AS Гостиница
	|FROM
	|	Catalog.Hotels AS Hotels
	|WHERE
	|	Hotels.DeletionMark = FALSE AND 
	|	Hotels.IsFolder = FALSE
	|ORDER BY Hotels.ПорядокСортировки";
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllHotels

//-----------------------------------------------------------------------------
// Description: Returns value table with all companies
// Parameters: None
// Return value: Value table with companies
//-----------------------------------------------------------------------------
Function cmGetAllCompanies() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Companies.Ref AS Фирма
	|FROM
	|	Справочник.Фирмы AS Companies
	|WHERE
	|	Companies.DeletionMark = FALSE
	|	AND Companies.IsFolder = FALSE
	|ORDER BY
	|	Companies.ПорядокСортировки";
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllCompanies

//-----------------------------------------------------------------------------
// Description: Returns value table with all countries
// Parameters: None
// Return value: Value table with countries
//-----------------------------------------------------------------------------
Function cmGetAllCountries() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	Countries.Ref AS Country
	|FROM
	|	Catalog.Countries AS Countries
	|WHERE
	|	Countries.DeletionMark = FALSE AND 
	|	Countries.IsFolder = FALSE
	|ORDER BY Countries.Description";
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllCountries

//-----------------------------------------------------------------------------
// Description: Returns value table with all ГруппаНомеров types
// Parameters: Гостиница, ГруппаНомеров types folder to return items from
// Return value: Value table with ГруппаНомеров types
//-----------------------------------------------------------------------------
Function cmGetAllRoomTypes(pHotel, pRoomTypeFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	ТипыНомеров.Ref AS ТипНомера
	|FROM
	|	Catalog.ТипыНомеров AS ТипыНомеров
	|WHERE
	|	ТипыНомеров.Owner = &qHotel AND
	|	ТипыНомеров.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pRoomTypeFolder), "ТипыНомеров.Ref IN HIERARCHY(&qRoomTypeFolder) AND ", "") + "
	|	ТипыНомеров.DeletionMark = FALSE
	|ORDER BY ТипыНомеров.ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomTypeFolder", pRoomTypeFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllRoomTypes

//-----------------------------------------------------------------------------
// Description: Returns value table with all calendar day types
// Parameters: Calendar day types folder to return items from
// Return value: Value table with calendar day types
//-----------------------------------------------------------------------------
Function cmGetAllCalendarDayTypes(pCalendarDayTypeFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	CalendarDayTypes.Ref AS ТипДеньКалендарь
	|FROM
	|	Catalog.CalendarDayTypes AS CalendarDayTypes
	|WHERE 
	|	(CalendarDayTypes.Гостиница = &qHotel OR CalendarDayTypes.Гостиница = &qEmptyHotel) AND
	|	CalendarDayTypes.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pCalendarDayTypeFolder), "CalendarDayTypes.Ref IN HIERARCHY(&qCalendarDayTypeFolder) AND ", "") + "
	|	CalendarDayTypes.DeletionMark = FALSE
	|ORDER BY CalendarDayTypes.ПорядокСортировки";
	vQry.SetParameter("qCalendarDayTypeFolder", pCalendarDayTypeFolder);
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllCalendarDayTypes

//-----------------------------------------------------------------------------
// Description: Returns value table with all schedule day types
// Parameters: Schedule day types folder to return items from
// Return value: Value table with schedule day types
//-----------------------------------------------------------------------------
Function cmGetAllScheduleDayTypes(pScheduleDayTypeFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	ТипыДнейГрафРаботы.Ref AS ScheduleDayType
	|FROM
	|	Catalog.ТипыДнейГрафРаботы AS ТипыДнейГрафРаботы
	|WHERE 
	|	ТипыДнейГрафРаботы.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pScheduleDayTypeFolder), "ТипыДнейГрафРаботы.Ref IN HIERARCHY(&qScheduleDayTypeFolder) AND ", "") + "
	|	ТипыДнейГрафРаботы.DeletionMark = FALSE
	|ORDER BY ТипыДнейГрафРаботы.ПорядокСортировки";
	vQry.SetParameter("qScheduleDayTypeFolder", pScheduleDayTypeFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllScheduleDayTypes

//-----------------------------------------------------------------------------
// Description: Returns value table with all ГруппаНомеров rates
// Parameters: Гостиница, ГруппаНомеров rates folder to return items from
// Return value: Value table with ГруппаНомеров rates
//-----------------------------------------------------------------------------
Function cmGetAllRoomRates(pHotel, pRoomRateFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	Тарифы.Ref AS Тариф
	|FROM
	|	Catalog.Тарифы AS Тарифы
	|WHERE
	|	(Тарифы.Гостиница = &qHotel OR Тарифы.Гостиница = &qEmptyHotel) AND
	|	Тарифы.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pRoomRateFolder), "Тарифы.Ref IN HIERARCHY(&qRoomRateFolder) AND ", "") + "
	|	Тарифы.DeletionMark = FALSE
	|ORDER BY Тарифы.ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vQry.SetParameter("qRoomRateFolder", pRoomRateFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllRoomRates

//-----------------------------------------------------------------------------
// Description: Returns value table with all payment sections
// Parameters: None
// Return value: Value table with payment sections
//-----------------------------------------------------------------------------
Function cmGetAllPaymentSections() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ОтделОплаты.Ref AS PaymentSection
	|FROM
	|	Catalog.ОтделОплаты AS ОтделОплаты
	|WHERE
	|	(ОтделОплаты.Гостиница = &qHotel
	|			OR ОтделОплаты.Гостиница = &qEmptyHotel)
	|	AND ОтделОплаты.DeletionMark = FALSE
	|
	|ORDER BY
	|	ОтделОплаты.Code";
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllPaymentSections

//-----------------------------------------------------------------------------
// Description: Returns value table with all services
// Parameters: Services folder to return items from
// Return value: Value table with services
//-----------------------------------------------------------------------------
Function cmGetAllServices(pServicesFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	Услуги.Ref AS Услуга
	|FROM
	|	Catalog.Услуги AS Услуги
	|WHERE
	|	Услуги.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pServicesFolder), "Услуги.Ref IN HIERARCHY(&qServicesFolder) AND ", "") + "
	|	Услуги.DeletionMark = FALSE AND 
	|	(Услуги.Гостиница = &qHotel
	|			OR Услуги.Гостиница = &qEmptyHotel)
	|ORDER BY Услуги.ПорядокСортировки";
	vQry.SetParameter("qServicesFolder", pServicesFolder);
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllServices

//-----------------------------------------------------------------------------
// Description: Returns value list with all ГруппаНомеров properties valid for the given hotel
// Parameters: ГруппаНомеров properties folder to return items from, Гостиница
// Return value: Value table with ГруппаНомеров properties
//-----------------------------------------------------------------------------
Function cmGetAllRoomProperties(pRoomPropertiesFolder = Неопределено, pHotel = Неопределено) Экспорт
	vList = New СписокЗначений();
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	СвойстваНомеров.Ref AS RoomProperty
	|FROM
	|	Catalog.СвойстваНомеров AS СвойстваНомеров
	|WHERE
	|	NOT СвойстваНомеров.DeletionMark
	|	AND NOT СвойстваНомеров.IsFolder
	|	AND (СвойстваНомеров.Ref IN HIERARCHY (&qRoomPropertiesFolder)
	|			OR &qRoomPropertiesFolderIsEmpty)
	|	AND (СвойстваНомеров.Гостиница = &qHotel
	|			OR СвойстваНомеров.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	СвойстваНомеров.ПорядокСортировки,
	|	СвойстваНомеров.Description";
	vQry.SetParameter("qRoomPropertiesFolder", pRoomPropertiesFolder);
	vQry.SetParameter("qRoomPropertiesFolderIsEmpty", НЕ ЗначениеЗаполнено(pRoomPropertiesFolder));
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vQryResults = vQry.Execute().Unload();
	For Each vQryResultsRow In vQryResults Do
		vList.Add(vQryResultsRow.RoomProperty);
	EndDo;
	Return vList;
EndFunction //cmGetAllRoomProperties

//-----------------------------------------------------------------------------
// Description: Returns value table with all accommodation templates
// Parameters: Гостиница, Accommodation templates folder to return items from
// Return value: Value table with accommodation templates
//-----------------------------------------------------------------------------
Function cmGetAllAccommodationTemplates(pHotel, pAccTemplFolder = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	AccommodationTemplates.Ref AS AccommodationTemplate
	|FROM
	|	Справочник.ШаблоныРазмещения AS AccommodationTemplates
	|WHERE
	|	(AccommodationTemplates.Гостиница = &qHotel OR AccommodationTemplates.Гостиница = &qEmptyHotel) AND
	|	AccommodationTemplates.ПометкаУдаления = FALSE
	|ORDER BY AccommodationTemplates.Код";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vQry.SetParameter("qAccTemplFolder", pAccTemplFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllAccommodationTemplates

//-----------------------------------------------------------------------------
// Description: Returns value table with all accommodation types
// Parameters: Accommodation types folder to return items from
// Return value: Value table with accommodation types
//-----------------------------------------------------------------------------
Function cmGetAllAccommodationTypes(pAccommodationTypeFolder = Неопределено, pHotel = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	ВидыРазмещений.Ref AS ВидРазмещения
	|FROM
	|	Catalog.ВидыРазмещений AS ВидыРазмещений
	|WHERE 
	|	ВидыРазмещений.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pAccommodationTypeFolder), "ВидыРазмещений.Ref IN HIERARCHY(&qAccommodationTypeFolder) AND ", "") + "
	|	ВидыРазмещений.DeletionMark = FALSE
	|	AND (NOT &qHotelIsEmptyRef AND (ВидыРазмещений.Гостиница = &qHotel
	|			OR ВидыРазмещений.Гостиница = &qEmptyHotel) OR &qHotelIsEmptyRef)
	|ORDER BY ВидыРазмещений.ПорядокСортировки";
	vQry.SetParameter("qAccommodationTypeFolder", pAccommodationTypeFolder);
	vQry.SetParameter("qHotel", ?(pHotel = Неопределено, ПараметрыСеанса.ТекущаяГостиница, pHotel));
	vQry.SetParameter("qHotelIsEmptyRef", ?(pHotel = Справочники.Hotels.EmptyRef(), True, False));
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllAccommodationTypes

//-----------------------------------------------------------------------------
// Description: Returns value list with all main ГруппаНомеров guests accommodation types
// Parameters: Гостиница 
// Return value: Value list with accommodation types
//-----------------------------------------------------------------------------
Function cmGetMainRoomGuestAccommodationTypes(pHotel) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ВидыРазмещений.Ref AS Ref
	|FROM
	|	Catalog.ВидыРазмещений AS ВидыРазмещений
	|WHERE
	|	ВидыРазмещений.IsFolder = FALSE
	|	AND ВидыРазмещений.DeletionMark = FALSE
	|	AND (ВидыРазмещений.ТипРазмещения = &qRoom
	|			OR ВидыРазмещений.ТипРазмещения = &qBeds)
	|	AND (ВидыРазмещений.Гостиница = &qHotel
	|			OR ВидыРазмещений.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ВидыРазмещений.ПорядокСортировки";
	vQry.SetParameter("qRoom", Перечисления.AccomodationTypes.НомерРазмещения);
	vQry.SetParameter("qBeds", Перечисления.AccomodationTypes.Beds);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vQryRes = vQry.Execute().Unload();
	vList = New СписокЗначений();
	vList.LoadValues(vQryRes.UnloadColumn("Ref"));
	Return vList;
EndFunction //cmGetMainRoomGuestAccommodationTypes

//-----------------------------------------------------------------------------
// Description: Returns first reference to the "Together" accommodation type
// Parameters: None
// Return value: Accommodation type or empty ref
//-----------------------------------------------------------------------------
Function cmGetAccommodationTypeTogether(pHotel = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ВидыРазмещений.Ref AS ВидРазмещения
	|FROM
	|	Catalog.ВидыРазмещений AS ВидыРазмещений
	|WHERE
	|	NOT ВидыРазмещений.IsFolder
	|	AND NOT ВидыРазмещений.DeletionMark
	|	AND ВидыРазмещений.ТипРазмещения = &qTogether
	|	AND (ВидыРазмещений.Гостиница = &qHotel
	|			OR ВидыРазмещений.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ВидыРазмещений.ПорядокСортировки";
	vQry.SetParameter("qTogether", Перечисления.AccomodationTypes.Together);
	vQry.SetParameter("qHotel", ?(ЗначениеЗаполнено(pHotel), pHotel, ПараметрыСеанса.ТекущаяГостиница));
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vList = vQry.Execute().Unload();
	If vList.Count() > 0 Тогда
		Return vList.Get(0).ВидРазмещения;
	Else
		Return Справочники.ВидыРазмещений.EmptyRef();
	EndIf;
EndFunction //cmGetAccommodationTypeTogether

//-----------------------------------------------------------------------------
// Description: Returns first reference to the "ГруппаНомеров" accommodation type
// Parameters: None
// Return value: Accommodation type or empty ref
//-----------------------------------------------------------------------------
Function cmGetAccommodationTypeRoom(pHotel = Неопределено) Экспорт
	// Build and run query
	Запрос = Новый Запрос();
	Запрос.Текст = 
	"ВЫБРАТЬ
	|ВидРазмещения.ссылка КАК ВРазмещения
	|ИЗ
	|Справочник.ВидыРазмещения КАК ВидРазмещения
	|ГДЕ
	|	НЕ ВидРазмещения.ЭтоГруппа
	|	И НЕ ВидРазмещения.ПометкаУдаления
	|	И ВидРазмещения.ТипРазмещения = &qRoom
	|	И (ВидРазмещения.Гостиница = &qHotel
	|			ИЛИ ВидРазмещения.Гостиница = &qEmptyHotel)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВидРазмещения.ПорядокСортировки";
	Запрос.SetParameter("qRoom", Перечисления.ВидыРазмещений.НомерРазмещения);
	Запрос.SetParameter("qHotel", ?(ЗначениеЗаполнено(pHotel), pHotel, ПараметрыСеанса.ТекущаяГостиница));
	Запрос.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vList = Запрос.Выполнить().Выгрузить();
	If vList.Count() > 0 Тогда
		Return vList.Get(0).ВРазмещения;
	Else
		Return Справочники.ВидыРазмещений.EmptyRef();
	EndIf;
EndFunction //cmGetAccommodationTypeRoom

//-----------------------------------------------------------------------------
// Description: Returns first reference to the "Bed" accommodation type
// Parameters: None
// Return value: Accommodation type or empty ref
//-----------------------------------------------------------------------------
Function cmGetAccommodationTypeBed(pHotel = Неопределено) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ВидыРазмещений.Ref AS ВидРазмещения
	|FROM
	|	Catalog.ВидыРазмещений AS ВидыРазмещений
	|WHERE
	|	NOT ВидыРазмещений.IsFolder
	|	AND NOT ВидыРазмещений.DeletionMark
	|	AND ВидыРазмещений.ТипРазмещения = &qBed
	|	AND (ВидыРазмещений.Гостиница = &qHotel
	|			OR ВидыРазмещений.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ВидыРазмещений.ПорядокСортировки";
	vQry.SetParameter("qBed", Перечисления.AccomodationTypes.Beds);
	vQry.SetParameter("qHotel", ?(ЗначениеЗаполнено(pHotel), pHotel, ПараметрыСеанса.ТекущаяГостиница));
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vList = vQry.Execute().Unload();
	If vList.Count() > 0 Тогда
		Return vList.Get(0).ВидРазмещения;
	Else
		Return Справочники.ВидыРазмещений.EmptyRef();
	EndIf;
EndFunction //cmGetAccommodationTypeBed

//-----------------------------------------------------------------------------
// Description: Calculates reservation and accommodation resources like 
//              number of beds, number of rooms, number of additional beds, 
//              number or persons, number of beds per ГруппаНомеров, number of persons per ГруппаНомеров
// Parameters: Date & time, ГруппаНомеров type, accommodation type, ГруппаНомеров, Number of rooms, 
//             Whether to recalculate number of persons resource in the document or not
// Return value: None, Input parameters are calculated and returned
//-----------------------------------------------------------------------------
Процедура cmCalculateResources(pDate, pRoomType, pAccommodationType, pRoom = Неопределено, 
                               pRoomQuantity, rNumberOfRooms, rNumberOfBeds, 
                               rNumberOfAdditionalBeds, rNumberOfPersons, 
                               rNumberOfBedsPerRoom, rNumberOfPersonsPerRoom,
							   pRecalculateNumberOfPersonsInReservation = False) Экспорт
	vIsVirtual = False;
	rNumberOfBedsPerRoom = 0;
	If ЗначениеЗаполнено(pRoom) Тогда
		vRoomObj = pRoom.GetObject();
		vRoomAttr = vRoomObj.pmGetRoomAttributes(pDate);
		For Each vRoomAttrRow In vRoomAttr Do
			rNumberOfBedsPerRoom = vRoomAttrRow.КоличествоМестНомер;
			rNumberOfPersonsPerRoom = vRoomAttrRow.КоличествоГостейНомер;
			vIsVirtual = vRoomAttrRow.ВиртуальныйНомер;
			Break;
		EndDo;
	ElsIf ЗначениеЗаполнено(pRoomType) Тогда
		rNumberOfBedsPerRoom = pRoomType.КоличествоМестНомер;
		rNumberOfPersonsPerRoom = pRoomType.КоличествоГостейНомер;
		vIsVirtual = pRoomType.ВиртуальныйНомер;
	EndIf;
	If ЗначениеЗаполнено(pAccommodationType) And НЕ vIsVirtual Тогда
		If pAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения Тогда
			rNumberOfRooms = pRoomQuantity * pAccommodationType.КоличествоНомеров;
			rNumberOfBeds = ?(pAccommodationType.КоличествоНомеров = 0, 0, pRoomQuantity * rNumberOfBedsPerRoom);
			rNumberOfAdditionalBeds = pRoomQuantity * pAccommodationType.КолДопМест;
			vNumberOfPersons = pRoomQuantity * pAccommodationType.КоличествоЧеловек;
			If НЕ pRecalculateNumberOfPersonsInReservation Or pAccommodationType.NumberOfPersons4Reservation = 0 Тогда
				If rNumberOfPersons = 0 Тогда
					rNumberOfPersons = vNumberOfPersons;
				EndIf;
			Else
				rNumberOfPersons = pRoomQuantity * pAccommodationType.NumberOfPersons4Reservation;
			EndIf;
		ElsIf pAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.Beds Тогда
			rNumberOfRooms = 0;
			rNumberOfBeds = pRoomQuantity * pAccommodationType.КоличествоМест;
			rNumberOfAdditionalBeds = pRoomQuantity * pAccommodationType.КолДопМест;
			vNumberOfPersons = pRoomQuantity * pAccommodationType.КоличествоЧеловек;
			If НЕ pRecalculateNumberOfPersonsInReservation Or pAccommodationType.NumberOfPersons4Reservation = 0 Тогда
				If rNumberOfPersons = 0 Тогда
					rNumberOfPersons = vNumberOfPersons;
				EndIf;
			Else
				rNumberOfPersons = pRoomQuantity * pAccommodationType.NumberOfPersons4Reservation;
			EndIf;
		ElsIf pAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.AdditionalBed Тогда
			rNumberOfRooms = 0;
			rNumberOfBeds = 0;
			rNumberOfAdditionalBeds = pRoomQuantity * pAccommodationType.КолДопМест;
			vNumberOfPersons = pRoomQuantity * pAccommodationType.КоличествоЧеловек;
			If НЕ pRecalculateNumberOfPersonsInReservation Or pAccommodationType.NumberOfPersons4Reservation = 0 Тогда
				If rNumberOfPersons = 0 Тогда
					rNumberOfPersons = vNumberOfPersons;
				EndIf;
			Else
				rNumberOfPersons = pRoomQuantity * pAccommodationType.NumberOfPersons4Reservation;
			EndIf;
		ElsIf pAccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.Together Тогда
			rNumberOfRooms = 0;
			rNumberOfBeds = 0;
			rNumberOfAdditionalBeds = pRoomQuantity * pAccommodationType.КолДопМест;
			vNumberOfPersons = pRoomQuantity * pAccommodationType.КоличествоЧеловек;
			If НЕ pRecalculateNumberOfPersonsInReservation Or pAccommodationType.NumberOfPersons4Reservation = 0 Тогда
				If rNumberOfPersons = 0 Тогда
					rNumberOfPersons = vNumberOfPersons;
				EndIf;
			Else
				rNumberOfPersons = pRoomQuantity * pAccommodationType.NumberOfPersons4Reservation;
			EndIf;
		EndIf;
		If pAccommodationType.КоличествоЧеловек = 0 Тогда
			rNumberOfPersons = 0;
		EndIf;
	Else
		rNumberOfRooms = 0;
		rNumberOfBeds = 0;
		rNumberOfAdditionalBeds = 0;
	EndIf;
КонецПроцедуры //cmCalculateResources

//-----------------------------------------------------------------------------
// Description: Returns value table with all day times 
// Parameters: None
// Return value: Value table with day times
//-----------------------------------------------------------------------------
Function cmGetDayTimes() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	DayTimes.Ref AS DayTime,
	|	DayTimes.Code AS Code,
	|	DayTimes.Description,
	|	DayTimes.Time,
	|	DayTimes.Time4CheckOutDate,
	|	DayTimes.Presentation
	|FROM
	|	Catalog.DayTimes AS DayTimes
	|WHERE
	|	DayTimes.DeletionMark = FALSE
	|
	|ORDER BY
	|	Code";
	vDayTimes = vQry.Execute().Unload();
	REturn vDayTimes;
EndFunction //cmGetDayTimes

//-----------------------------------------------------------------------------
// Description: Returns value table with client accommodations and active 
//              reservations 
// Parameters: Client
// Return value: Value table with client accommodations/reservations data
//-----------------------------------------------------------------------------
Function cmLoadClientAccommodationHistory(pClient) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Размещение.ГруппаГостей AS ГруппаГостей,
	|	Размещение.ГруппаГостей.Description AS GuestGroupDescription,
	|	Размещение.CheckInDate AS CheckInDate,
	|	Размещение.ДатаВыезда,
	|	Размещение.НомерРазмещения,
	|	Размещение.ТипНомера,
	|	Размещение.Тариф,
	|	Размещение.ВидРазмещения,
	|	1 AS AccommodationCount,
	|	0 AS ReservationCount,
	|	Размещение.Ref AS Document,
	|	Размещение.Примечания AS Примечания
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Клиент = &qClient
	|	AND Размещение.СтатусРазмещения.Действует
	|	AND Размещение.Posted
	|
	|UNION ALL
	|
	|SELECT
	|	Бронирование.ГруппаГостей,
	|	Бронирование.ГруппаГостей.Description AS GuestGroupDescription,
	|	Бронирование.CheckInDate,
	|	Бронирование.ДатаВыезда,
	|	Бронирование.НомерРазмещения,
	|	Бронирование.ТипНомера,
	|	Бронирование.Тариф,
	|	Бронирование.ВидРазмещения,
	|	0,
	|	1,
	|	Бронирование.Ref,
	|	Бронирование.Примечания
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.Клиент = &qClient
	|	AND Бронирование.ReservationStatus.ShowInClientsSearchForm = TRUE
	|	AND Бронирование.Posted
	|
	|ORDER BY
	|	CheckInDate";
	vQry.SetParameter("qClient", pClient);
	vQryTab = vQry.Execute().Unload();
	Return vQryTab;
EndFunction //cmLoadClientAccommodationHistory

//-----------------------------------------------------------------------------
// Description: Returns value table with all ГруппаНомеров properties
// Parameters: None
// Return value: Value table with ГруппаНомеров properties
//-----------------------------------------------------------------------------
Function cmGetAllProperties() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СвойстваНомеров.Ref AS RoomProperty,
	|	СвойстваНомеров.Code AS Code,
	|	СвойстваНомеров.Description AS Description,
	|	СвойстваНомеров.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.СвойстваНомеров AS СвойстваНомеров
	|WHERE
	|	СвойстваНомеров.DeletionMark = FALSE
	|	AND СвойстваНомеров.IsFolder = FALSE
	|	AND (СвойстваНомеров.Гостиница = &qHotel
	|			OR СвойстваНомеров.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ПорядокСортировки";
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllProperties

//-----------------------------------------------------------------------------
// Description: Returns value table with all reservation statuses
// Parameters: None
// Return value: Value table with reservation statuses
//-----------------------------------------------------------------------------
Function cmGetAllReservationStatuses(pSkipCheckIn = False) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусБрони.Ref AS ReservationStatus,
	|	СтатусБрони.Code AS Code,
	|	СтатусБрони.Description AS Description,
	|	СтатусБрони.ПорядокСортировки AS ПорядокСортировки,
	|	СтатусБрони.IsActive AS IsActive
	|FROM
	|	Catalog.СтатусБрони AS СтатусБрони
	|WHERE
	|	NOT СтатусБрони.DeletionMark
	|	AND NOT СтатусБрони.IsFolder
	|	AND (NOT СтатусБрони.ЭтоЗаезд
	|				AND &qSkipCheckIn
	|			OR NOT &qSkipCheckIn)
	|	AND (СтатусБрони.Гостиница = &qHotel
	|			OR СтатусБрони.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ПорядокСортировки";
	vQry.SetParameter("qSkipCheckIn", pSkipCheckIn);
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllReservationStatuses

//-----------------------------------------------------------------------------
// Description: Returns value table with all accommodation statuses
// Parameters: None
// Return value: Value table with accommodation statuses
//-----------------------------------------------------------------------------
Function cmGetAllAccommodationStatuses() Экспорт
	Запрос = Новый Запрос();
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СтатусРазмещения.ссылка КАК СтатусРазмещения,
	|	СтатусРазмещения.Код КАК Код,
	|	СтатусРазмещения.Наименование КАК Наименование,
	|	СтатусРазмещения.Действует КАК Действует,
	|	СтатусРазмещения.СортировкаКод КАК СортировкаКод
	|ИЗ
	|	Справочник.СтатусРазмещения КАК СтатусРазмещения
	|ГДЕ
	|	СтатусРазмещения.ПометкаУдаления = ЛОЖЬ
	|	И СтатусРазмещения.ЭтоГруппа = ЛОЖЬ
	|
	|УПОРЯДОЧИТЬ ПО
	|	СортировкаКод";
	vElements = Запрос.Выполнить().Выгрузить();
	Return vElements;
EndFunction //cmGetAllAccommodationStatuses

//-----------------------------------------------------------------------------
// Description: Returns value list with all checked in accommodation statuses
// Parameters: None
// Return value: Value list with accommodation statuses
//-----------------------------------------------------------------------------
Function cmGetCheckedInAccommodationStatuses() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	AccommodationStatuses.Ref AS СтатусРазмещения
	|FROM
	|	Catalog.AccommodationStatuses AS AccommodationStatuses
	|WHERE
	|	NOT AccommodationStatuses.DeletionMark
	|	AND NOT AccommodationStatuses.IsFolder
	|	AND AccommodationStatuses.IsActive
	|	AND AccommodationStatuses.ЭтоГости
	|
	|ORDER BY
	|	AccommodationStatuses.ПорядокСортировки";
	vElements = vQry.Execute().Unload();
	vElementsList = New СписокЗначений();
	vElementsList.LoadValues(vElements.UnloadColumn("СтатусРазмещения"));
	Return vElementsList;
EndFunction //cmGetCheckedInAccommodationStatuses

//-----------------------------------------------------------------------------
// Description: Returns value list with all checked out accommodation statuses
// Parameters: None
// Return value: Value list with accommodation statuses
//-----------------------------------------------------------------------------
Function cmGetCheckedOutAccommodationStatuses() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	AccommodationStatuses.Ref AS СтатусРазмещения
	|FROM
	|	Catalog.AccommodationStatuses AS AccommodationStatuses
	|WHERE
	|	NOT AccommodationStatuses.DeletionMark
	|	AND NOT AccommodationStatuses.IsFolder
	|	AND AccommodationStatuses.IsActive
	|	AND AccommodationStatuses.ЭтоВыезд
	|	AND NOT AccommodationStatuses.ЭтоГости
	|
	|ORDER BY
	|	AccommodationStatuses.ПорядокСортировки";
	vElements = vQry.Execute().Unload();
	vElementsList = New СписокЗначений();
	vElementsList.LoadValues(vElements.UnloadColumn("СтатусРазмещения"));
	Return vElementsList;
EndFunction //cmGetCheckedOutAccommodationStatuses

//-----------------------------------------------------------------------------
// Description: Returns value table with all ГруппаНомеров statuses
// Parameters: None
// Return value: Value table with ГруппаНомеров statuses
//-----------------------------------------------------------------------------
Function cmGetAllRoomStatuses() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусыНомеров.Ref AS СтатусНомера,
	|	СтатусыНомеров.Code AS Code,
	|	СтатусыНомеров.RoomStatusIcon AS RoomStatusIcon,
	|	СтатусыНомеров.Description AS Description,
	|	СтатусыНомеров.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.СтатусыНомеров AS СтатусыНомеров
	|WHERE
	|	СтатусыНомеров.DeletionMark = FALSE
	|	AND СтатусыНомеров.IsFolder = FALSE
	|	AND (СтатусыНомеров.Гостиница = &qHotel
	|			OR СтатусыНомеров.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ПорядокСортировки,
	|	Description";
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.ПустаяСсылка());
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllRoomStatuses

//-----------------------------------------------------------------------------
// Description: Returns value table with all ГруппаНомеров interface types
// Parameters: None
// Return value: Value table with ГруппаНомеров interface types
//-----------------------------------------------------------------------------
Function cmGetAllRoomInterfaceTypes() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ВидУслугВНомерах.Ref AS СтатусНомера,
	|	ВидУслугВНомерах.Code AS Code,
	|	ВидУслугВНомерах.Description AS Description
	|FROM
	|	Catalog.ВидУслугВНомерах AS ВидУслугВНомерах
	|WHERE
	|	ВидУслугВНомерах.DeletionMark = FALSE
	|	AND (ВидУслугВНомерах.Гостиница = &qHotel
	|			OR ВидУслугВНомерах.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	Code";
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllRoomInterfaceTypes

//-----------------------------------------------------------------------------
// Description: Returns value table with ГруппаНомеров statuses allowed to the current user
// Parameters: None
// Return value: Value table with ГруппаНомеров statuses
//-----------------------------------------------------------------------------
Function cmGetAllowedRoomStatuses(pEmployee = Неопределено) Экспорт
	// Initialize table
	vElements = New ValueTable();
	vElements.Columns.Add("СтатусНомера", cmGetCatalogTypeDescription("СтатусыНомеров"));
	// Try to get current user permission group
	vEmployee = ПараметрыСеанса.ТекПользователь;
	If ЗначениеЗаполнено(pEmployee) Тогда
		vEmployee = pEmployee;
	EndIf;
	If ЗначениеЗаполнено(vEmployee) Тогда
		vPermissionGroup = cmGetEmployeePermissionGroup(vEmployee);
		If ЗначениеЗаполнено(vPermissionGroup) Тогда
			For Each vRoomStatusRow In vPermissionGroup.RoomStatusesAllowed Do
				vElementsRow = vElements.Add();
				vElementsRow.СтатусНомера = vRoomStatusRow.СтатусНомера;
			EndDo;
		EndIf;
	EndIf;
	Return vElements;
EndFunction //cmGetAllowedRoomStatuses

//-----------------------------------------------------------------------------
// Description: Returns value table with door lock system authorizations 
//              allowed to the current user
// Parameters: None
// Return value: Value table with door lock system authorizations
//-----------------------------------------------------------------------------
Function cmGetAllowedDoorLockSystemAuthorizations() Экспорт
	// Initialize table
	vElements = New ValueTable();
	vElements.Columns.Add("DoorLockSystemAuthorization", cmGetCatalogTypeDescription("DoorLockSystemAuthorizations"));
	// Try to get current user permission group
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
		If ЗначениеЗаполнено(vPermissionGroup) Тогда
			For Each vAuthRow In vPermissionGroup.DoorLockSystemAuthorizations Do
				vElementsRow = vElements.Add();
				vElementsRow.DoorLockSystemAuthorization = vAuthRow.DoorLockSystemAuthorization;
			EndDo;
		EndIf;
	EndIf;
	Return vElements;
EndFunction //cmGetAllowedDoorLockSystemAuthorizations

//-----------------------------------------------------------------------------
// Description: Returns value table with all client types
// Parameters: None
// Return value: Value table with client types
//-----------------------------------------------------------------------------
Function cmGetAllClientTypes(pHotel = Неопределено) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ClientTypes.Ref AS ТипКлиента,
	|	ClientTypes.Code AS Code,
	|	ClientTypes.Description AS Description,
	|	ClientTypes.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Справочник.ТипыКлиентов AS ClientTypes
	|WHERE
	|	ClientTypes.DeletionMark = FALSE
	|	AND ClientTypes.IsFolder = FALSE
	|	AND NOT &qHotelIsEmptyRef AND (ClientTypes.Гостиница = &qHotel
	|			OR ClientTypes.Гостиница = &qEmptyHotel) OR &qHotelIsEmptyRef
	|
	|ORDER BY
	|	ПорядокСортировки,
	|	Description";
	vQry.SetParameter("qHotel", ?(pHotel = Неопределено, ПараметрыСеанса.ТекущаяГостиница, pHotel));
	vQry.SetParameter("qHotelIsEmptyRef", ?(pHotel = Справочники.Гостиницы.ПустаяСсылка(), True, False));
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.ПустаяСсылка());
	vElements = vQry.Execute().Unload();
	// Check user permissions
	vPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
	If ЗначениеЗаполнено(vPermissionGroup) Тогда
		If vPermissionGroup.ClientTypesAllowed.Count() > 0 Тогда
			i = 0;
			While i < vElements.Count() Do
				vRow = vElements.Get(i);
				If vPermissionGroup.ClientTypesAllowed.Find(vRow.ТипКлиента, "ТипКлиента") = Неопределено Тогда
					vElements.Delete(i);
				Else
					i = i + 1;
				EndIf;
			EndDo;
		EndIf;
	EndIf;	
	Return vElements;
EndFunction //cmGetAllClientTypes

//-----------------------------------------------------------------------------
// Description: Returns value table with all price tags
// Parameters: None
// Return value: Value table with price tags
//-----------------------------------------------------------------------------
Function cmGetAllPriceTags() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ПризнакЦены.Ref AS ПризнакЦены,
	|	ПризнакЦены.Code AS Code,
	|	ПризнакЦены.Description AS Description,
	|	ПризнакЦены.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.ПризнакЦены AS ПризнакЦены
	|WHERE
	|	ПризнакЦены.DeletionMark = FALSE
	|	AND ПризнакЦены.IsFolder = FALSE
	|	AND (ПризнакЦены.Гостиница = &qHotel
	|			OR ПризнакЦены.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ПорядокСортировки,
	|	Description";
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vElements = vQry.Execute().Unload();	
	Return vElements;
EndFunction //cmGetAllPriceTags

//-----------------------------------------------------------------------------
// Description: Returns value table with all trip purposes
// Parameters: None
// Return value: Value table with trip purposes
//-----------------------------------------------------------------------------
Function cmGetAllTripPurposes() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	TripPurposes.Ref AS TripPurpose,
	|	TripPurposes.Code AS Code,
	|	TripPurposes.Description AS Description,
	|	TripPurposes.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.TripPurposes AS TripPurposes
	|WHERE
	|	NOT TripPurposes.DeletionMark
	|
	|ORDER BY
	|	ПорядокСортировки,
	|	Description";
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllTripPurposes

//-----------------------------------------------------------------------------
// Description: Returns value table with all sources of business
// Parameters: None
// Return value: Value table with sources of business
//-----------------------------------------------------------------------------
Function cmGetAllSourcesOfBusiness() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ИсточИнфоГостиница.Ref AS ИсточИнфоГостиница,
	|	ИсточИнфоГостиница.Code AS Code,
	|	ИсточИнфоГостиница.Description AS Description,
	|	ИсточИнфоГостиница.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.ИсточИнфоГостиница AS ИсточИнфоГостиница
	|WHERE
	|	ИсточИнфоГостиница.DeletionMark = FALSE
	|	AND ИсточИнфоГостиница.IsFolder = FALSE
	|
	|ORDER BY
	|	ПорядокСортировки,
	|	Description";
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllSourcesOfBusiness

//-----------------------------------------------------------------------------
// Description: Returns value table with all guarantee types
// Parameters: None
// Return value: Value table with guarantee types
//-----------------------------------------------------------------------------
Function cmGetAllGuaranteeTypes() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	GuaranteeTypes.Ref AS ИсточИнфоГостиница,
	|	GuaranteeTypes.Code AS Code,
	|	GuaranteeTypes.Description AS Description
	|FROM
	|	Catalog.GuaranteeTypes AS GuaranteeTypes
	|WHERE
	|	NOT GuaranteeTypes.DeletionMark
	|ORDER BY
	|	Description";
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllGuaranteeTypes

//-----------------------------------------------------------------------------
// Description: Returns count of guarantee types
// Parameters: None
// Return value: Number of active guarantee types
//-----------------------------------------------------------------------------
Function cmGetGuaranteeTypesCount() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	COUNT(*) AS Count
	|FROM
	|	Catalog.GuaranteeTypes AS GuaranteeTypes
	|WHERE
	|	NOT GuaranteeTypes.DeletionMark";
	vElements = vQry.Execute().Unload();
	If vElements.Count() > 0 Тогда
		Return vElements.Get(0).Count;
	Else
		Return 0;
	EndIf;
EndFunction //cmGetGuaranteeTypesCount

//-----------------------------------------------------------------------------
// Description: Returns value table with folios suitable for charging ГруппаНомеров service.
//              First folio returned is the newest one
// Parameters: ГруппаНомеров, Service registration date, Client
// Return value: Value table with folios
//-----------------------------------------------------------------------------
Function cmGetFoliosToChargeRoomService(pRoom, pDate, pClient = Неопределено) Экспорт
	// Select all active folios for the ГруппаНомеров specified
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СчетПроживания.Ref AS СчетПроживания,
	|	СчетПроживания.IsMaster AS IsMaster,
	|	СчетПроживания.ВалютаЛицСчета AS ВалютаЛицСчета
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	(NOT СчетПроживания.IsClosed)
	|	AND (NOT СчетПроживания.DeletionMark)
	|	AND NOT СчетПроживания.ДокОснование REFS Document.Бронирование
	|	AND СчетПроживания.НомерРазмещения = &qRoom
	|	AND СчетПроживания.DateTimeFrom <= &qDate " +
		?(ЗначениеЗаполнено(pClient), "AND СчетПроживания.Клиент = &qClient ", "") + "
	|ORDER BY
	|	IsMaster DESC,
	|	СчетПроживания.PointInTime DESC";
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qClient", pClient);
	vFolios = vQry.Execute().Unload();
	// Remove client filter and try again if nothing was found
	If ЗначениеЗаполнено(pClient) And vFolios.Count() = 0 Тогда
		vQry.Text = 
		"SELECT
		|	СчетПроживания.Ref AS СчетПроживания,
		|	СчетПроживания.IsMaster AS IsMaster,
		|	СчетПроживания.ВалютаЛицСчета AS ВалютаЛицСчета
		|FROM
		|	Document.СчетПроживания AS СчетПроживания
		|WHERE
		|	(NOT СчетПроживания.IsClosed)
		|	AND (NOT СчетПроживания.DeletionMark)
		|	AND NOT СчетПроживания.ДокОснование REFS Document.Бронирование
		|	AND СчетПроживания.НомерРазмещения = &qRoom
		|	AND СчетПроживания.DateTimeFrom <= &qDate
		|
		|ORDER BY
		|	IsMaster DESC,
		|	СчетПроживания.PointInTime DESC";
		vQry.SetParameter("qRoom", pRoom);
		vQry.SetParameter("qDate", pDate);
		vFolios = vQry.Execute().Unload();
	EndIf;
	// Try again to search by accommodation period if nothing was found
	If vFolios.Count() = 0 Тогда
		vQry.Text = 
		"SELECT
		|	СчетПроживания.Ref AS СчетПроживания,
		|	СчетПроживания.IsMaster AS IsMaster,
		|	СчетПроживания.ВалютаЛицСчета AS ВалютаЛицСчета
		|FROM
		|	Document.СчетПроживания AS СчетПроживания
		|WHERE
		|	(NOT СчетПроживания.DeletionMark)
		|	AND NOT СчетПроживания.ДокОснование REFS Document.Бронирование
		|	AND СчетПроживания.НомерРазмещения = &qRoom
		|	AND СчетПроживания.DateTimeFrom <= &qDate
		|	AND СчетПроживания.DateTimeTo >= &qDate
		|	AND (&qClientIsFilled AND СчетПроживания.Клиент = &qClient OR NOT &qClientIsFilled)
		|
		|ORDER BY
		|	IsMaster DESC,
		|	СчетПроживания.PointInTime DESC";
		vQry.SetParameter("qRoom", pRoom);
		vQry.SetParameter("qDate", pDate);
		vQry.SetParameter("qClient", pClient);
		vQry.SetParameter("qClientIsFilled", ЗначениеЗаполнено(pClient));
		vFolios = vQry.Execute().Unload();
	EndIf;
	// Add master folios from document charging rules
	i = 0;
	vUsedParentDocs = New СписокЗначений();
	vCopyFolios = vFolios.Copy();
	For Each vFoliosRow In vCopyFolios Do
		vParentDoc = vFoliosRow.ЛицевойСчет.ДокОснование;
		If vUsedParentDocs.FindByValue(vParentDoc) = Неопределено Тогда
			vUsedParentDocs.Add(vParentDoc);
			If ЗначениеЗаполнено(vParentDoc) And 
			  (TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(vParentDoc) = Type("DocumentRef.Бронирование")) Тогда
				For Each vCRRow In vParentDoc.ChargingRules Do
					vChargingFolio = vCRRow.ChargingFolio;
					If ЗначениеЗаполнено(vChargingFolio) And vChargingFolio.IsMaster And НЕ vChargingFolio.IsClosed And НЕ vChargingFolio.DeletionMark Тогда
						If vFolios.Find(vChargingFolio, "СчетПроживания") = Неопределено Тогда
							vMasterFoliosRow = vFolios.Вставить(i);
							vMasterFoliosRow.СчетПроживания = vChargingFolio;
							vMasterFoliosRow.IsMaster = vChargingFolio.IsMaster;
							vMasterFoliosRow.ВалютаЛицСчета = vChargingFolio.ВалютаЛицСчета;
							i = i + 1;
						EndIf;
					EndIf;
				EndDo;
			EndIf;
		EndIf;
	EndDo;
	Return vFolios;
EndFunction //cmGetFoliosToChargeRoomService

//-----------------------------------------------------------------------------
// Description: Returns value table with employees with rights to sign foreigner
//              notification form
// Parameters: None
// Return value: Value table with employees
//-----------------------------------------------------------------------------
Function cmGetEmployeesWithPermissionToSignNotificationForm(pHotel = Неопределено) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	EmployeesAllowedToSign.Employee AS Employee
	|FROM
	|	(SELECT
	|		Employees.Ref AS Employee
	|	FROM
	|		Catalog.Employees AS Employees
	|	WHERE
	|		Employees.PermissionGroup.HavePermissionToSignForeignerNotificationForm
	|		AND (Employees.Гостиница = &qEmptyHotel
	|				OR Employees.Гостиница = &qHotel)
	|		AND NOT Employees.DeletionMark
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		СотрРеквНеизм.Employee
	|	FROM
	|		InformationRegister.СотрРеквНеизм AS СотрРеквНеизм
	|	WHERE
	|		СотрРеквНеизм.PermissionGroup.HavePermissionToSignForeignerNotificationForm
	|		AND (СотрРеквНеизм.Employee.Гостиница = &qEmptyHotel
	|				OR СотрРеквНеизм.Employee.Гостиница = &qHotel)
	|		AND NOT СотрРеквНеизм.Employee.DeletionMark) AS EmployeesAllowedToSign
	|
	|GROUP BY
	|	EmployeesAllowedToSign.Employee
	|
	|ORDER BY
	|	EmployeesAllowedToSign.Employee.ПорядокСортировки,
	|	EmployeesAllowedToSign.Employee.Description";
	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
	vQry.SetParameter("qHotel", pHotel);
	vEmps = vQry.Execute().Unload();
	Return vEmps;
EndFunction //cmGetEmployeesWithPermissionToSignNotificationForm

//-----------------------------------------------------------------------------
// Description: Creates new reservation or accommodation charging rules based on 
//              charging rules from the given document
// Parameters: Object, Template document
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmCreateChargingRulesBasedOnParent(pObj, pBase) Экспорт
	pObj.ChargingRules.Clear();
	// Load default charging rules
	i = pBase.ChargingRules.Count() - 1;
	While i >= 0 Do
		vBaseCRRow = pBase.ChargingRules.Get(i);
		// Create new folio as copy of base one if it is not master one
		vNewFolio = vBaseCRRow.ChargingFolio;
		If НЕ vBaseCRRow.IsMaster Тогда
			If ЗначениеЗаполнено(vBaseCRRow.ChargingFolio) And НЕ vBaseCRRow.ChargingFolio.IsMaster Тогда
				vNewFolioObj = vBaseCRRow.ChargingFolio.GetObject().Copy();
				vNewFolioObj.ДатаДок = CurrentDate();
				vNewFolioObj.Автор = ПараметрыСеанса.ТекПользователь;
				vNewFolioObj.ДокОснование = Неопределено;
				vNewFolioObj.Write(DocumentWriteMode.Write);
				vNewFolio = vNewFolioObj.Ref;
			EndIf;
		EndIf;
		vCRRow = pObj.ChargingRules.Вставить(0);
		FillPropertyValues(vCRRow, vBaseCRRow, , "ChargingFolio");
		vCRRow.ChargingFolio = vNewFolio;
		i = i - 1;
	EndDo;
КонецПроцедуры //cmCreateChargingRulesBasedOnParent

//-----------------------------------------------------------------------------
// Description: Fills new reservation or accommodation charging rules by
//              charging rules from the given document and mark all of them as transfer
// Parameters: Object, Template document
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmLoadMainRoomGuestChargingRules(pObj, pBase) Экспорт
	// Use folios from the base document
	pObj.ChargingRules.Load(pBase.ChargingRules.Unload());
	// Mark charging rules as transfer
	For Each vCRRow In pObj.ChargingRules Do
		vCRRow.IsPersonal = False;
		vCRRow.IsTransfer = True;
	EndDo;
КонецПроцедуры //cmLoadMainRoomGuestChargingRules

//-----------------------------------------------------------------------------
// Description: Fills new reservation or accommodation charging rules based on 
//              charging rules from the given document
// Parameters: Object, Template document
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmUseParentChargingRules(pObj, pBase, pIsTransfer = False) Экспорт
	// Use folios from the base document
	pObj.ChargingRules.Load(pBase.ChargingRules.Unload());
	// Delete personal charging rules
	i = 0;
	While i < pObj.ChargingRules.Count() Do
		vCRRow = pObj.ChargingRules.Get(i);
		If vCRRow.IsPersonal And pIsTransfer Тогда
			pObj.ChargingRules.Delete(i);
		Else
			If pIsTransfer Тогда
				vCRRow.IsTransfer = pIsTransfer;
			EndIf;
			i = i + 1;
		EndIf;
	EndDo;
	// Load hotel personal charging rules
	If ЗначениеЗаполнено(pBase.Гостиница) And pIsTransfer Тогда
		For Each vHotelCRRow In pBase.Гостиница.ChargingRules Do
			If vHotelCRRow.IsPersonal Тогда
				vNewCRRowFolio = vHotelCRRow.ChargingFolio.GetObject();
				If НЕ vNewCRRowFolio.IsMaster Тогда
					vNewCRRowFolio = vNewCRRowFolio.Copy();
				EndIf;
				vNewCRRowFolio.ДатаДок = CurrentDate();
				vNewCRRowFolio.Автор = ПараметрыСеанса.ТекПользователь;
				vNewCRRowFolio.ДокОснование = ?(ЗначениеЗаполнено(pObj.Ref), pObj.Ref, pObj.GetNewObjectRef());
				vNewCRRowFolio.Клиент = pObj.Клиент;
				vNewCRRowFolio.НомерРазмещения = pObj.НомерРазмещения;
				vNewCRRowFolio.DateTimeFrom = pObj.CheckInDate;
				vNewCRRowFolio.DateTimeTo = pObj.ДатаВыезда;
				vNewCRRowFolio.ГруппаГостей = pObj.ГруппаГостей;
				If НЕ vNewCRRowFolio.DoNotUpdateCompany Тогда
					vNewCRRowFolio.Фирма = pObj.Фирма;
				EndIf;
				vNewCRRowFolio.Write(DocumentWriteMode.Write);
				// Fill charging rule
				vPrsCRRow = pObj.ChargingRules.Add();
				FillPropertyValues(vPrsCRRow, vHotelCRRow, , "LineNumber");
				vPrsCRRow.ChargingFolio = vNewCRRowFolio.Ref;
				vPrsCRRow.IsTransfer = False;
			EndIf;
		EndDo;
	EndIf;
	// Check if there are at least one charging rule
	If pObj.ChargingRules.Count() = 0 Тогда
		// Create default document charging rules
		pObj.pmCreateFolios();
	EndIf;
КонецПроцедуры //cmUseParentChargingRules

//-----------------------------------------------------------------------------
// Description: Checks if client identification document is in the list of 
//              forbidden identification documents
// Parameters: Type of identification document, Series of the identification document,
//             Number of the identification document, Returns description of forbidden
//             document if it is found
// Return value: True if document was found in the forbidden list, False if not
//-----------------------------------------------------------------------------
Function cmIsClientIdentityDocumentInForbiddenList(pIDType, pIDSeries, pIDNumber, rIDRemarks) Экспорт
	rIDRemarks = "";
	If IsBlankString(pIDSeries) And IsBlankString(pIDNumber) Тогда
		Return False;
	EndIf;
	vQry = New Query();
	vQry.Text = "SELECT
	            |	ForbiddenIdentificationDocuments.Примечания
	            |FROM
	            |	InformationRegister.ForbiddenIdentificationDocuments AS ForbiddenIdentificationDocuments
	            |WHERE
	            |	ForbiddenIdentificationDocuments.IdentityDocumentType = &qIDType
	            |	AND ForbiddenIdentificationDocuments.IdentityDocumentSeries = &qIDSeries
	            |	AND ForbiddenIdentificationDocuments.IdentityDocumentNumber = &qIDNumber";
	vQry.SetParameter("qIDType", pIDType);
	vQry.SetParameter("qIDSeries", pIDSeries);
	vQry.SetParameter("qIDNumber", pIDNumber);
	vQryRes = vQry.Execute().Unload();
	If vQryRes.Count() > 0 Тогда
		vRow = vQryRes.Get(0);
		rIDRemarks = СокрЛП(vRow.Примечания);
		Return True;
	EndIf;
	Return False;
EndFunction //cmIsClientIdentityDocumentInForbiddenList

//-----------------------------------------------------------------------------
// Description: Calculates effective number of rooms that accommodation should 
//              write off from the vacant rooms
// Parameters: Accommodation object
// Return value: Number of rooms to write off
//-----------------------------------------------------------------------------
Function cmCalculateEffectiveNumberOfRoomsForAccommodation(pAccObj) Экспорт
	// Calculate the effective number of rooms to write off
	vEffectiveNumberOfRooms = New ValueTable();
	vEffectiveNumberOfRooms.Columns.Add("EffectiveNumberOfRooms", cmGetNumberTypeDescription(10, 0));
	vEffectiveNumberOfRooms.Columns.Add("ПериодС", cmGetDateTimeTypeDescription());
	vEffectiveNumberOfRooms.Columns.Add("ПериодПо", cmGetDateTimeTypeDescription());
	If pAccObj.КоличествоНомеров <> 0 Тогда
		vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Add();
		vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = pAccObj.КоличествоНомеров;
		vEffectiveNumberOfRoomsRow.ПериодС = pAccObj.CheckInDate;
		vEffectiveNumberOfRoomsRow.ПериодПо = pAccObj.ДатаВыезда;
	Else
		If pAccObj.КоличествоМестНомер = 0 Тогда
			vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Add();
			vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0;
			vEffectiveNumberOfRoomsRow.ПериодС = pAccObj.CheckInDate;
			vEffectiveNumberOfRoomsRow.ПериодПо = pAccObj.ДатаВыезда;
		Else
			// Run query to get periods where number of vacant rooms has changed
			vVacantPeriods = cmGetVacantRoomsByPeriodsForAccommodation(pAccObj.Гостиница, pAccObj.ТипНомера, pAccObj.НомерРазмещения, pAccObj.CheckInDate, pAccObj.ДатаВыезда);
			// Process each period
			For Each vVacantPeriodsRow In vVacantPeriods Do
				vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Add();
				vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0;
				vEffectiveNumberOfRoomsRow.ПериодС = vVacantPeriodsRow.ПериодС;
				vEffectiveNumberOfRoomsRow.ПериодПо = vVacantPeriodsRow.ПериодПо;
				// Calculation
				vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = Int(pAccObj.КоличествоМест/pAccObj.КоличествоМестНомер);
				vRestOfNumberOfBeds = pAccObj.КоличествоМест - vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms * pAccObj.КоличествоМестНомер;
				If vRestOfNumberOfBeds <> 0 Тогда
					// Get the total number of occupied beds
					vNumberOfOccupiedBeds = vVacantPeriodsRow.ВсегоМест - vVacantPeriodsRow.BedsVacant;
					vNumberOfOccupiedRooms = vVacantPeriodsRow.ВсегоНомеров - vVacantPeriodsRow.RoomsVacant;
					// If this accommodation is in ГруппаНомеров quota and ГруппаНомеров quota is written off then we should 
					// correct results with number of rooms/beds reserved or checked-in already
					If ЗначениеЗаполнено(pAccObj.КвотаНомеров) And 
					   pAccObj.КвотаНомеров.DoWriteOff And pAccObj.КвотаНомеров.IsQuotaForRooms Тогда
						vEffCheckInDate = cmMovePeriodFromToReferenceHour(vVacantPeriodsRow.ПериодС, pAccObj.Тариф);
						vEffCheckOutDate = cmMovePeriodToToReferenceHour(vVacantPeriodsRow.ПериодПо, pAccObj.Тариф);
						If vEffCheckInDate < vEffCheckOutDate Тогда
							vQuotaRests = cmCalculateRoomQuotaResources(pAccObj.КвотаНомеров, pAccObj.КвотаНомеров.Агент, pAccObj.КвотаНомеров.Контрагент, pAccObj.КвотаНомеров.Договор, pAccObj.Гостиница, pAccObj.ТипНомера, pAccObj.НомерРазмещения, vEffCheckInDate, vEffCheckOutDate);
							For Each vQuotaRestsRow In vQuotaRests Do
								vNumberOfOccupiedBeds = vNumberOfOccupiedBeds - vQuotaRestsRow.МестКвота - vQuotaRestsRow.ЗабронированоМест - vQuotaRestsRow.ИспользованоМест;
								vNumberOfOccupiedRooms = vNumberOfOccupiedRooms - vQuotaRestsRow.НомеровКвота - vQuotaRestsRow.ЗабронНомеров - vQuotaRestsRow.ИспользованоНомеров;
							EndDo;
						EndIf;
					EndIf;
					// Calculate should we add 1 to the effective number of occupied rooms
					If ЗначениеЗаполнено(pAccObj.НомерРазмещения) Тогда
						If vNumberOfOccupiedRooms = 0 Тогда
							vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms + 1;
						EndIf;
					Else
						vRestOfNumberOfBeds = vNumberOfOccupiedRooms * pAccObj.КоличествоМестНомер - vNumberOfOccupiedBeds - vRestOfNumberOfBeds;
						If vRestOfNumberOfBeds < 0 Тогда
							vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms + 1;
						EndIf;
					EndIf;
				EndIf;
			EndDo;
		EndIf;
	EndIf;
	// Join rows
	i = 1;
	While i < vEffectiveNumberOfRooms.Count() Do
		vRow = vEffectiveNumberOfRooms.Get(i);
		vPrevRow = vEffectiveNumberOfRooms.Get(i - 1);
		If vPrevRow.EffectiveNumberOfRooms = vRow.EffectiveNumberOfRooms Тогда
			vPrevRow.ПериодПо = vRow.ПериодПо;
			vEffectiveNumberOfRooms.Delete(i);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	Return vEffectiveNumberOfRooms;
EndFunction //cmCalculateEffectiveNumberOfRoomsForAccommodation

//-----------------------------------------------------------------------------
// Description: Calculates effective number of rooms that reservation should 
//              write off from the vacant rooms
// Parameters: Accommodation object
// Return value: Number of rooms to write off
//-----------------------------------------------------------------------------
Function cmCalculateEffectiveNumberOfRoomsForReservation(pAccObj, pEffectiveNumberOfRooms, pEffectiveNumberOfBeds, pEffectiveNumberOfAddBeds, pEffectiveNumberOfPersons) Экспорт
	// Calculate the effective number of rooms to write off
	vEffectiveNumberOfRooms = New ValueTable();
	vEffectiveNumberOfRooms.Columns.Add("EffectiveNumberOfRooms", cmGetNumberTypeDescription(10, 0));
	vEffectiveNumberOfRooms.Columns.Add("ПериодС", cmGetDateTimeTypeDescription());
	vEffectiveNumberOfRooms.Columns.Add("ПериодПо", cmGetDateTimeTypeDescription());
	If pAccObj.КоличествоНомеров <> 0 Тогда
		vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Add();
		vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = Min(pAccObj.КоличествоНомеров, pEffectiveNumberOfRooms);
		vEffectiveNumberOfRoomsRow.ПериодС = pAccObj.CheckInDate;
		vEffectiveNumberOfRoomsRow.ПериодПо = pAccObj.ДатаВыезда;
	Else
		If pAccObj.КоличествоМестНомер = 0 Тогда
			vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Add();
			vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0;
			vEffectiveNumberOfRoomsRow.ПериодС = pAccObj.CheckInDate;
			vEffectiveNumberOfRoomsRow.ПериодПо = pAccObj.ДатаВыезда;
		Else
			// Run query to get periods where number of vacant rooms has changed
			vVacantPeriods = cmGetVacantRoomsByPeriodsForReservation(pAccObj.Гостиница, pAccObj.ТипНомера, pAccObj.НомерРазмещения, pAccObj.КвотаНомеров, pAccObj.CheckInDate, pAccObj.ДатаВыезда);
			// Process each period
			If vVacantPeriods.Count() = 0 Тогда
				vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Add();
				vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = Min(pAccObj.КоличествоНомеров, pEffectiveNumberOfRooms);
				vEffectiveNumberOfRoomsRow.ПериодС = pAccObj.CheckInDate;
				vEffectiveNumberOfRoomsRow.ПериодПо = pAccObj.ДатаВыезда;
			Else
				For Each vVacantPeriodsRow In vVacantPeriods Do
					vEffectiveNumberOfRoomsRow = vEffectiveNumberOfRooms.Add();
					vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = 0;
					vEffectiveNumberOfRoomsRow.ПериодС = vVacantPeriodsRow.ПериодС;
					vEffectiveNumberOfRoomsRow.ПериодПо = vVacantPeriodsRow.ПериодПо;
					// Calculation
					vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = Int(pAccObj.КоличествоМест/pAccObj.КоличествоМестНомер);
					vRestOfNumberOfBeds = pAccObj.КоличествоМест - vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms * pAccObj.КоличествоМестНомер;
					If vRestOfNumberOfBeds <> 0 Тогда
						// Get the total number of occupied beds
						vNumberOfOccupiedBeds = vVacantPeriodsRow.ВсегоМест - vVacantPeriodsRow.BedsVacant;
						vNumberOfOccupiedRooms = vVacantPeriodsRow.ВсегоНомеров - vVacantPeriodsRow.RoomsVacant;
						// If this accommodation is in ГруппаНомеров quota and ГруппаНомеров quota is written off then we should 
						// correct results with number of rooms/beds reserved or checked-in already
						If ЗначениеЗаполнено(pAccObj.КвотаНомеров) And 
						   pAccObj.КвотаНомеров.DoWriteOff And pAccObj.КвотаНомеров.IsQuotaForRooms Тогда
							vEffCheckInDate = cmMovePeriodFromToReferenceHour(vVacantPeriodsRow.ПериодС, pAccObj.Тариф);
							vEffCheckOutDate = cmMovePeriodToToReferenceHour(vVacantPeriodsRow.ПериодПо, pAccObj.Тариф);
							If vEffCheckInDate < vEffCheckOutDate Тогда
								vQuotaRests = cmCalculateRoomQuotaResources(pAccObj.КвотаНомеров, pAccObj.КвотаНомеров.Агент, pAccObj.КвотаНомеров.Контрагент, pAccObj.КвотаНомеров.Договор, pAccObj.Гостиница, pAccObj.ТипНомера, pAccObj.НомерРазмещения, vEffCheckInDate, vEffCheckOutDate);
								For Each vQuotaRestsRow In vQuotaRests Do
									vNumberOfOccupiedBeds = vNumberOfOccupiedBeds - vQuotaRestsRow.МестКвота - vQuotaRestsRow.ЗабронированоМест - vQuotaRestsRow.ИспользованоМест;
									vNumberOfOccupiedRooms = vNumberOfOccupiedRooms - vQuotaRestsRow.НомеровКвота - vQuotaRestsRow.ЗабронНомеров - vQuotaRestsRow.ИспользованоНомеров;
								EndDo;
							EndIf;
						EndIf;
						// Calculate should we add 1 to the effective number of occupied rooms
						If ЗначениеЗаполнено(pAccObj.НомерРазмещения) And (НЕ ЗначениеЗаполнено(pAccObj.КвотаНомеров) Or ЗначениеЗаполнено(pAccObj.КвотаНомеров) And НЕ pAccObj.КвотаНомеров.IsQuotaForRooms) Тогда
							If vNumberOfOccupiedRooms = 0 Тогда
								vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms + 1;
							EndIf;
						Else
							vRestOfNumberOfBeds = vNumberOfOccupiedRooms * pAccObj.КоличествоМестНомер - vNumberOfOccupiedBeds - vRestOfNumberOfBeds;
							If vRestOfNumberOfBeds < 0 Тогда
								vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms = vEffectiveNumberOfRoomsRow.EffectiveNumberOfRooms + 1;
							EndIf;
						EndIf;
					EndIf;
				EndDo;
			EndIf;
		EndIf;
	EndIf;
	// Join rows
	i = 1;
	While i < vEffectiveNumberOfRooms.Count() Do
		vRow = vEffectiveNumberOfRooms.Get(i);
		vPrevRow = vEffectiveNumberOfRooms.Get(i - 1);
		If vPrevRow.EffectiveNumberOfRooms = vRow.EffectiveNumberOfRooms Тогда
			vPrevRow.ПериодПо = vRow.ПериодПо;
			vEffectiveNumberOfRooms.Delete(i);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	Return vEffectiveNumberOfRooms;
EndFunction //cmCalculateEffectiveNumberOfRoomsForReservation

//-----------------------------------------------------------------------------
// Description: Calculates effective number of rooms, beds, number of persons that 
//              reservation should write off from the vacant rooms
// Parameters: Reservation object
// Return value: Structure with rooms, beds, persons to write off
//-----------------------------------------------------------------------------
Function cmCalculateEffectiveResourcesForReservation(pResObj) Экспорт
	// Initialize effective resources structure
	vEffectiveResources = New Structure("EffectiveNumberOfBeds, EffectiveNumberOfAddBeds, EffectiveNumberOfPersons, EffectiveNumberOfRooms", 0, 0, 0, 0);
	
	// Initialize working variables for reservation resources
	vNumberOfRooms = pResObj.КоличествоНомеров;
	vNumberOfBeds = pResObj.КоличествоМест;
	vNumberOfAdditionalBeds = pResObj.КолДопМест;
	vNumberOfPersons = pResObj.КоличествоЧеловек;
	
	// Calculate write offs done by accommodations based on this reservation
	vWriteOffs = cmGetWriteOffsForReservation(pResObj.Ref);
	
	// Correct resources according to the write offs
	If vWriteOffs.Count() > 0 Тогда
		For Each vWriteOffRow In vWriteOffs Do
			vNumberOfRooms = vNumberOfRooms - vWriteOffRow.ЗаездНомеров;
			vNumberOfBeds = vNumberOfBeds - vWriteOffRow.ЗаездМест;
			vNumberOfAdditionalBeds = vNumberOfAdditionalBeds - vWriteOffRow.ЗаездДополнительныхМест;
			vNumberOfPersons = vNumberOfPersons - vWriteOffRow.ЗаездГостей;
		EndDo;
		
		If vNumberOfRooms < 0 Тогда
			vNumberOfRooms = 0;
		EndIf;
		If vNumberOfBeds < 0 Тогда
			vNumberOfBeds = 0;
		EndIf;
		If vNumberOfAdditionalBeds < 0 Тогда
			vNumberOfAdditionalBeds = 0;
		EndIf;
		If vNumberOfPersons < 0 Тогда
			vNumberOfPersons = 0;
		EndIf;
	EndIf;
	
	// Set effective resources to be used by the document
	vEffectiveNumberOfBeds = vNumberOfBeds;
	vEffectiveNumberOfAddBeds = vNumberOfAdditionalBeds;
	vEffectiveNumberOfPersons = vNumberOfPersons;
	
	// Calculate the effective number of rooms to write off
	vEffectiveNumberOfRooms = 0;
	If vNumberOfRooms <> 0 Тогда
		vEffectiveNumberOfRooms = vNumberOfRooms;
	Else
		If pResObj.КоличествоМестНомер <> 0 Тогда
			vEffectiveNumberOfRooms = Int(vNumberOfBeds/pResObj.КоличествоМестНомер);
			vRestOfNumberOfBeds = vNumberOfBeds - vEffectiveNumberOfRooms * pResObj.КоличествоМестНомер;
			If vRestOfNumberOfBeds <> 0 Тогда
				// Get the total number of occupied beds
				vNumberOfOccupiedBeds = 0;
				vNumberOfOccupiedRooms = 0;
				vRestsTab = cmGetRestOfVacantRooms(pResObj.Гостиница, pResObj.ТипНомера, pResObj.НомерРазмещения, pResObj.CheckInDate, pResObj.ДатаВыезда);
				For Each vRestsTabRow In vRestsTab Do
					vNumberOfOccupiedBeds = vNumberOfOccupiedBeds + vRestsTabRow.ВсегоМест - vRestsTabRow.BedsVacant;
					vNumberOfOccupiedRooms = vNumberOfOccupiedRooms + vRestsTabRow.ВсегоНомеров - vRestsTabRow.RoomsVacant;
				EndDo;
				// If this reservation is in ГруппаНомеров quota and ГруппаНомеров quota is written off then we should 
				// correct results with number of rooms/beds reserved or checked-in already
				If ЗначениеЗаполнено(pResObj.КвотаНомеров) And pResObj.КвотаНомеров.DoWriteOff And 
				   (pResObj.КвотаНомеров.IsQuotaForRooms And ЗначениеЗаполнено(pResObj.НомерРазмещения) Or (НЕ ЗначениеЗаполнено(pResObj.НомерРазмещения))) Тогда
					vEffCheckInDate = cmMovePeriodFromToReferenceHour(pResObj.CheckInDate, pResObj.Тариф);
					vEffCheckOutDate = cmMovePeriodToToReferenceHour(pResObj.ДатаВыезда, pResObj.Тариф);
					If vEffCheckInDate < vEffCheckOutDate Тогда
						vQuotaRests = cmCalculateRoomQuotaResources(pResObj.КвотаНомеров, pResObj.КвотаНомеров.Агент, pResObj.КвотаНомеров.Контрагент, pResObj.КвотаНомеров.Договор, pResObj.Гостиница, pResObj.ТипНомера, pResObj.НомерРазмещения, vEffCheckInDate, vEffCheckOutDate);
						For Each vQuotaRestsRow In vQuotaRests Do
							vNumberOfOccupiedBeds = vNumberOfOccupiedBeds - vQuotaRestsRow.МестКвота - vQuotaRestsRow.ЗабронированоМест - vQuotaRestsRow.ИспользованоМест;
							vNumberOfOccupiedRooms = vNumberOfOccupiedRooms - vQuotaRestsRow.НомеровКвота - vQuotaRestsRow.ЗабронНомеров - vQuotaRestsRow.ИспользованоНомеров;
						EndDo;
					EndIf;
				EndIf;
				// Calculate should we add 1 to the effective number of occupied rooms
				If ЗначениеЗаполнено(pResObj.НомерРазмещения) Тогда
					If vNumberOfOccupiedRooms = 0 Тогда
						vEffectiveNumberOfRooms = vEffectiveNumberOfRooms + 1;
					EndIf;
				Else
					If (vNumberOfOccupiedRooms * pResObj.КоличествоМестНомер) >= vNumberOfOccupiedBeds Тогда
						vRestOfNumberOfBeds = vNumberOfOccupiedRooms * pResObj.КоличествоМестНомер - vNumberOfOccupiedBeds - vRestOfNumberOfBeds;
						If vRestOfNumberOfBeds < 0 Тогда
							vEffectiveNumberOfRooms = vEffectiveNumberOfRooms + 1;
						EndIf;
					Else
						vEffectiveNumberOfRooms = vEffectiveNumberOfRooms + 1;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	
	// Fill resources structure with calculated values
	vEffectiveResources.EffectiveNumberOfBeds = vEffectiveNumberOfBeds;
	vEffectiveResources.EffectiveNumberOfAddBeds = vEffectiveNumberOfAddBeds;
	vEffectiveResources.EffectiveNumberOfPersons = vEffectiveNumberOfPersons;
	vEffectiveResources.EffectiveNumberOfRooms = vEffectiveNumberOfRooms;
	
	// Return resources
	Return vEffectiveResources;
EndFunction //cmCalculateEffectiveResourcesForReservation

//-----------------------------------------------------------------------------
// Description: Returns reference hour for the given ГруппаНомеров rate
// Parameters: ГруппаНомеров rate
// Return value: Reference hour time 
//-----------------------------------------------------------------------------
Function cmGetReferenceHour(Val pRoomRate) Экспорт
	vRefHour = '00010101120000';
	vRoomRate = pRoomRate;
	If НЕ ЗначениеЗаполнено(vRoomRate) And ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) And 
	   ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.Тариф) Тогда
		vRoomRate = ПараметрыСеанса.ТекущаяГостиница.Тариф;
	EndIf;
	If ЗначениеЗаполнено(vRoomRate) Тогда
		If vRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
			vRefHour = vRoomRate.ReferenceHour;
		EndIf;
	EndIf;
	Return vRefHour;
EndFunction //cmGetReferenceHour

//-----------------------------------------------------------------------------
// Description: Returns default check-in time for the given ГруппаНомеров rate
// Parameters: ГруппаНомеров rate
// Return value: Default check-in time 
//-----------------------------------------------------------------------------
Function cmGetDefaultCheckInTime(pRoomRate) Экспорт
	vCheckInTime = '00010101120000';
	If ЗначениеЗаполнено(pRoomRate) Тогда
		If ЗначениеЗаполнено(pRoomRate.DefaultCheckInTime) Тогда
			vCheckInTime = pRoomRate.DefaultCheckInTime;
		EndIf;
	EndIf;
	Return vCheckInTime;
EndFunction //cmGetDefaultCheckInTime

//-----------------------------------------------------------------------------
// Description: Moves check-in date to the nearest reference hour
// Parameters: Check-in date, ГруппаНомеров rate
// Return value: Check-in date with time set to the reference hour
//-----------------------------------------------------------------------------
Function cmMovePeriodFromToReferenceHour(pPeriodFrom, pRoomRate) Экспорт
	vRefHour = cmGetReferenceHour(pRoomRate);
	Return cm1SecondShift(BegOfDay(pPeriodFrom) + (vRefHour - BegOfDay(vRefHour)));
EndFunction //cmMovePeriodFromToReferenceHour

//-----------------------------------------------------------------------------
// Description: Moves check-out date to the nearest reference hour
// Parameters: Check-out date, ГруппаНомеров rate
// Return value: Check-out date with time set to the reference hour
//-----------------------------------------------------------------------------
Function cmMovePeriodToToReferenceHour(pPeriodTo, pRoomRate) Экспорт
	vRefHour = cmGetReferenceHour(pRoomRate);
	Return cm0SecondShift(BegOfDay(pPeriodTo) + (vRefHour - BegOfDay(vRefHour)));
EndFunction //cmMovePeriodToToReferenceHour

//-----------------------------------------------------------------------------
// Description: Returns value table with ГруппаНомеров attributes changes 
// Parameters: ГруппаНомеров, Period from date, Period to date
// Return value: Value table with ГруппаНомеров changes
//-----------------------------------------------------------------------------
Function cmGetChangeRoomAttributes(pRoom, pPeriodFrom, pPeriodTo) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.НомерРазмещения = &qRoom
	|	AND ЗагрузкаНомеров.Period > &qPeriodFrom
	|	AND ЗагрузкаНомеров.Period < &qPeriodTo
	|	AND ЗагрузкаНомеров.IsRoomInventory
	|ORDER BY
	|	ЗагрузкаНомеров.Period";
	vQry.SetParameter("qHotel", pRoom.Owner);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", ?(ЗначениеЗаполнено(pPeriodTo), pPeriodTo, '39991231'));
	Return vQry.Execute().Unload();
EndFunction //cmGetChangeRoomAttributes

//-----------------------------------------------------------------------------
// Description: Checks if there is stop sale set for the ГруппаНомеров type given for the 
//              period given
// Parameters: ГруппаНомеров type, Period from date, Period to date, Returns stop sale 
//             description if found
// Return value: True if ГруппаНомеров type is on stop sale for the given period, False if not
//-----------------------------------------------------------------------------
Function cmIsStopSalePeriod(pRoomType, pPeriodFrom, pPeriodTo, rRemarks = "", pShowPeriod = False) Экспорт
	rRemarks = "";
	vIsStopSale = False;
	For Each vRow In pRoomType.ПериодыСнятияСПродажи Do
		If vRow.СнятСПродажи Тогда
			If ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС < pPeriodTo And vRow.ПериодПо > pPeriodFrom And pPeriodTo <> pPeriodFrom Or 
			   ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС <= pPeriodFrom And vRow.ПериодПо > pPeriodTo And pPeriodTo = pPeriodFrom Or 
			   НЕ ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) Or
			   НЕ ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодПо > pPeriodFrom Or
			   ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС < pPeriodTo Тогда
				vIsStopSale = True;
				If pShowPeriod Тогда
					rRemarks = Format(vRow.ПериодС, "DF='dd.MM.yy HH:mm'") + " - " + Format(vRow.ПериодПо, "DF='dd.MM.yy HH:mm'") + Chars.LF + Chars.Tab + СокрЛП(vRow.Примечания);
				Else
					rRemarks = СокрЛП(vRow.Примечания);
				EndIf;
				Break;
			EndIf;
		EndIf;
	EndDo;
	Return vIsStopSale;
EndFunction //cmIsStopSalePeriod

//-----------------------------------------------------------------------------
// Description: Checks if there is internet stop sale set for the ГруппаНомеров type given for the 
//              period given
// Parameters: ГруппаНомеров type, Period from date, Period to date, Returns stop sale 
//             description if found
// Return value: True if ГруппаНомеров type is on internet stop sale for the given period, False if not
//-----------------------------------------------------------------------------
Function cmIsStopInternetSalePeriod(pRoomType, pPeriodFrom, pPeriodTo, rRemarks = "") Экспорт
	rRemarks = "";
	vIsStopSale = False;
	For Each vRow In pRoomType.ПериодыСнятияСПродажи Do
		If vRow.СнятСПродажи Or vRow.StopInternetSale Тогда
			If ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС < pPeriodTo And vRow.ПериодПо > pPeriodFrom And pPeriodTo <> pPeriodFrom Or 
			   ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС <= pPeriodFrom And vRow.ПериодПо > pPeriodTo And pPeriodTo = pPeriodFrom Or
			   НЕ ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) Or
			   НЕ ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодПо > pPeriodFrom Or
			   ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС < pPeriodTo Тогда
				vIsStopSale = True;
				rRemarks = СокрЛП(vRow.Примечания);
				Break;
			EndIf;
		EndIf;
	EndDo;
	Return vIsStopSale;
EndFunction //cmIsStopInternetSalePeriod

//-----------------------------------------------------------------------------
// Description: Checks if there is stop sale set for the ГруппаНомеров given for the 
//              period given
// Parameters: ГруппаНомеров, Period from date, Period to date, Returns stop sale 
//             description if found
// Return value: True if ГруппаНомеров is on stop sale for the given period, False if not
//-----------------------------------------------------------------------------
Function cmIsRoomStopSalePeriod(pRoom, pPeriodFrom, pPeriodTo, rRemarks = "", pShowPeriod = False) Экспорт
	rRemarks = "";
	vIsStopSale = False;
	For Each vRow In pRoom.ПериодыСнятияСПродажи Do
		If vRow.СнятСПродажи Тогда
			If ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС < pPeriodTo And vRow.ПериодПо > pPeriodFrom And pPeriodTo <> pPeriodFrom Or 
			   ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС <= pPeriodFrom And vRow.ПериодПо > pPeriodTo And pPeriodTo = pPeriodFrom Or 
			   НЕ ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) Or
			   НЕ ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодПо > pPeriodFrom Or
			   ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) And vRow.ПериодС < pPeriodTo Тогда
				vIsStopSale = True;
				If pShowPeriod Тогда
					rRemarks = Format(vRow.ПериодС, "DF='dd.MM.yy HH:mm'") + " - " + Format(vRow.ПериодПо, "DF='dd.MM.yy HH:mm'") + Chars.LF + Chars.Tab + СокрЛП(vRow.Примечания);
				Else
					rRemarks = СокрЛП(vRow.Примечания);
				EndIf;
				Break;
			EndIf;
		EndIf;
	EndDo;
	Return vIsStopSale;
EndFunction //cmIsRoomStopSalePeriod

//-----------------------------------------------------------------------------
// Description: Returns list of default hotel charging rule owners. 
// Parameters: Гостиница
// Return value: Value list of customers/contracts
//-----------------------------------------------------------------------------
Function cmGetHotelDefaultChargingRuleOwners(pHotel) Экспорт
	vOwners = New СписокЗначений();
	If ЗначениеЗаполнено(pHotel) Тогда
		For Each vCRRow In pHotel.ChargingRules Do
			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
				If ЗначениеЗаполнено(vCRRow.ChargingFolio.Договор) Тогда
					vOwners.Add(vCRRow.ChargingFolio.Договор);
				ElsIf ЗначениеЗаполнено(vCRRow.ChargingFolio.Контрагент) Тогда
					vOwners.Add(vCRRow.ChargingFolio.Контрагент);
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	Return vOwners;
EndFunction //cmGetHotelDefaultChargingRuleOwners

//-----------------------------------------------------------------------------
// Description: Returns list of vacant rooms for accommodation 
// Parameters: Number of vacant beds that ГруппаНомеров should have, Гостиница, Фирма, 
//             ГруппаНомеров quota, ГруппаНомеров type, ГруппаНомеров status, Period from date, Period to date
// Return value: Value table with vacant rooms
//-----------------------------------------------------------------------------
Function cmGetVacantRoomsList(pNumberOfBeds, pHotel, pCompany, pRoomQuota, pRoomType, pRoomStatus = Неопределено, pDateFrom, pDateTo) Экспорт
	// Clear resulting table
	vTableBoxRooms = New ValueTable();
	vTableBoxRooms.Columns.Add("НомерРазмещения", cmGetCatalogTypeDescription("НомернойФонд"));
	vTableBoxRooms.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
	vTableBoxRooms.Columns.Add("Фирма", cmGetCatalogTypeDescription("Companies"));
	vTableBoxRooms.Columns.Add("VacantFrom", cmGetDateTimeTypeDescription());
	vTableBoxRooms.Columns.Add("VacantTo", cmGetDateTimeTypeDescription());
	vTableBoxRooms.Columns.Add("BedsVacant", cmGetNumberTypeDescription(10, 0));
	vTableBoxRooms.Columns.Add("ПорядокСортировки", cmGetNumberTypeDescription(8, 0));
	vTableBoxRooms.Columns.Add("IsFolder", cmGetBooleanTypeDescription());
	
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		Return vTableBoxRooms;
	EndIf;
	
	// Initialize working array
	vRoomsArray = New Array();
	
	// Run query to get rooms in ГруппаНомеров quota if filled
	vUseRoomQuota = False;
	vRoomsInQuota = New СписокЗначений();
	If ЗначениеЗаполнено(pRoomQuota) Тогда
		If НЕ pRoomQuota.DeletionMark And pRoomQuota.IsQuotaForRooms Тогда
			vUseRoomQuota = True;
			vQry = New Query();
			vQry.Text = "SELECT
			            |	ПродажиКвот.НомерРазмещения,
			            |	ПродажиКвот.ТипНомера,
			            |	MIN(ПродажиКвот.RoomsInQuotaClosingBalance) AS RoomsInQuotaClosingBalance,
			            |	MIN(ПродажиКвот.BedsInQuotaClosingBalance) AS BedsInQuotaClosingBalance,
			            |	MIN(ПродажиКвот.CounterClosingBalance)
			            |FROM
			            |	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
			            |			&qDateFrom,
			            |			&qDateTo,
			            |			Second,
			            |			RegisterRecordsAndPeriodBoundaries, " + 
										?(ЗначениеЗаполнено(pHotel), "Гостиница IN HIERARCHY (&qHotel)", "TRUE") + 
										?(ЗначениеЗаполнено(pRoomType), " AND ТипНомера IN HIERARCHY (&qRoomType)", "") + "
			            |				AND КвотаНомеров IN HIERARCHY (&qRoomQuota)) AS ПродажиКвот
						|WHERE " + 
							?(ЗначениеЗаполнено(pCompany), "(ПродажиКвот.ТипНомера.Фирма = &qCompany) OR (ПродажиКвот.НомерРазмещения.Фирма = &qCompany) OR (ПродажиКвот.ТипНомера.Фирма = &qEmptyCompany AND ПродажиКвот.НомерРазмещения.Фирма = &qEmptyCompany)", "TRUE") + "
			            |
			            |GROUP BY
			            |	ПродажиКвот.НомерРазмещения,
			            |	ПродажиКвот.ТипНомера
			            |
			            |ORDER BY
			            |	ПродажиКвот.НомерРазмещения.ПорядокСортировки";
			vQry.SetParameter("qRoomQuota", pRoomQuota);
			vQry.SetParameter("qHotel", pHotel);
			vQry.SetParameter("qRoomType", pRoomType);
			vQry.SetParameter("qDateFrom", pDateFrom);
			vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
			vQry.SetParameter("qCompany", pCompany);
			vQry.SetParameter("qEmptyCompany", Справочники.Companies.EmptyRef());
			vQryResults = vQry.Execute().Unload();
			For Each vQryResultsRow In vQryResults Do
				vRoomsInQuota.Add(vQryResultsRow.Room);
			EndDo;
		EndIf;
	EndIf;
	
	// Run query to get number of vacant rooms for ГруппаНомеров types
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ТипыНомеров.ТипНомера AS ТипНомера,
	|	ТипыНомеров.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	ТипыНомеров.BedsVacant AS BedsVacant,
	|	ТипыНомеров.RoomsVacant AS RoomsVacant,
	|	ТипыНомеров.ТипНомера.Фирма AS Фирма
	|
	|FROM(
	|	SELECT
	|		RoomTypesBalance.ТипНомера AS ТипНомера,
	|		MAX(RoomTypesBalance.ВсегоМест) AS ВсегоМест,
	|		MAX(RoomTypesBalance.ВсегоНомеров) AS ВсегоНомеров,
	|		MAX(RoomTypesBalance.BedsVacant) AS BedsVacant,
	|		MAX(RoomTypesBalance.RoomsVacant) AS RoomsVacant
	|	FROM (
	|		SELECT
	|			RoomInventoryBalance.ТипНомера AS ТипНомера,
	|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
	|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS ВсегоМест,
	|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS ВсегоНомеров,
	|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
	|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
	|		FROM
	|			AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|		    	                                                   Second, 
	|		        	                                               RegisterRecordsAndPeriodBoundaries, " +
			        	                                               ?(ЗначениеЗаполнено(pHotel), "Гостиница IN HIERARCHY (&qHotel)", "TRUE") + 
			        	                                               ?(ЗначениеЗаполнено(pRoomType), " AND ТипНомера IN HIERARCHY (&qRoomType)", "") + 
			        	                                               ?(vUseRoomQuota, " AND НомерРазмещения IN (&qRoomsInQuota)", "") + "
	|		) AS RoomInventoryBalance
	|		GROUP BY
	|			RoomInventoryBalance.ТипНомера
	|		UNION ALL
	|		SELECT
	|			RoomQuotaSalesBalance.ТипНомера AS ТипНомера,
	|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
	|		FROM
	|			AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|		    	                                                    Second, 
	|		           	                                                RegisterRecordsAndPeriodBoundaries, &qUseRoomQuota" +
				                                                        ?(ЗначениеЗаполнено(pRoomQuota), " AND КвотаНомеров IN HIERARCHY(&qRoomQuota)", "") + 
			      	                                                    ?(ЗначениеЗаполнено(pHotel), " AND Гостиница IN HIERARCHY (&qHotel)", "") + 
			        	                                                ?(ЗначениеЗаполнено(pRoomType), " AND ТипНомера IN HIERARCHY (&qRoomType)", "") + 
			        	                                                ?(vUseRoomQuota, " AND НомерРазмещения IN (&qRoomsInQuota)", "") + "
	|		) AS RoomQuotaSalesBalance
	|		GROUP BY
	|			RoomQuotaSalesBalance.ТипНомера
	|	) AS RoomTypesBalance
	|	WHERE
	|		RoomTypesBalance.ТипНомера.DeletionMark = FALSE 
	|	GROUP BY
	|		RoomTypesBalance.ТипНомера
	|	) AS ТипыНомеров
	|
	|WHERE " + 
		?(ЗначениеЗаполнено(pCompany), "(ТипыНомеров.ТипНомера.Фирма = &qCompany) OR (ТипыНомеров.ТипНомера.Фирма = &qEmptyCompany)", "TRUE") + "
	|
	|ORDER BY
	|	RoomTypeSortCode";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	vQry.SetParameter("qCompany", pCompany);
	vQry.SetParameter("qEmptyCompany", Справочники.Companies.EmptyRef());
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qRoomsInQuota", vRoomsInQuota);
	vQry.SetParameter("qUseRoomQuota", ЗначениеЗаполнено(pRoomQuota));
	vQryResult = vQry.Execute();
	//vRoomTypes = vQryResult.Unload();
	
	// Run query to get list of available rooms
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	НомернойФонд.НомерРазмещения AS НомерРазмещения,
	|	НомернойФонд.НомерРазмещения.ПорядокСортировки AS ПорядокСортировки,
	|	НомернойФонд.ТипНомера AS ТипНомера,
	|	НомернойФонд.ВсегоМест AS ВсегоМест,
	|	НомернойФонд.ВсегоНомеров AS ВсегоНомеров,
	|	НомернойФонд.BedsVacant AS BedsVacant,
	|	НомернойФонд.RoomsVacant AS RoomsVacant,
	|	НомернойФонд.НомерРазмещения.Фирма AS Фирма
	|
	|FROM(
	|	
	|	SELECT
	|		RoomBalance.НомерРазмещения AS НомерРазмещения,
	|		RoomBalance.ТипНомера AS ТипНомера,
	|		MAX(RoomBalance.ВсегоМест) AS ВсегоМест,
	|		MAX(RoomBalance.ВсегоНомеров) AS ВсегоНомеров,
	|		MAX(RoomBalance.BedsVacant) AS BedsVacant,
	|		MAX(RoomBalance.RoomsVacant) AS RoomsVacant
	|	FROM (
	|		SELECT
	|			RoomInventoryBalance.НомерРазмещения AS НомерРазмещения,
	|			RoomInventoryBalance.ТипНомера AS ТипНомера,
	|			MIN(RoomInventoryBalance.CounterClosingBalance) AS CounterClosingBalance,
	|			MIN(RoomInventoryBalance.TotalBedsClosingBalance) AS ВсегоМест,
	|			MIN(RoomInventoryBalance.TotalRoomsClosingBalance) AS ВсегоНомеров,
	|			MIN(RoomInventoryBalance.BedsVacantClosingBalance) AS BedsVacant,
	|			MIN(RoomInventoryBalance.RoomsVacantClosingBalance) AS RoomsVacant
	|		FROM
	|			AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|		    	                                                   Second, 
	|		        	                                               RegisterRecordsAndPeriodBoundaries, " +
			            	                                           ?(ЗначениеЗаполнено(pHotel), "Гостиница IN HIERARCHY(&qHotel)", "TRUE") + 
			                	                                       ?(ЗначениеЗаполнено(pRoomType), " AND ТипНомера IN HIERARCHY(&qRoomType)", "") + 
			                    	                                   ?(vUseRoomQuota, " AND НомерРазмещения IN (&qRoomsInQuota)", "") + "
	|		) AS RoomInventoryBalance
	|		GROUP BY
	|			RoomInventoryBalance.НомерРазмещения,
	|			RoomInventoryBalance.ТипНомера 
	|		UNION ALL
	|		SELECT
	|			RoomQuotaSalesBalance.НомерРазмещения,
	|			RoomQuotaSalesBalance.ТипНомера,
	|			MIN(RoomQuotaSalesBalance.CounterClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsInQuotaClosingBalance),
	|			MIN(RoomQuotaSalesBalance.BedsRemainsClosingBalance),
	|			MIN(RoomQuotaSalesBalance.RoomsRemainsClosingBalance)
	|		FROM
	|			AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|			                                                        Second, 
	|			                                                        RegisterRecordsAndPeriodBoundaries, &qUseRoomQuota" +
				                                                        ?(ЗначениеЗаполнено(pRoomQuota), " AND КвотаНомеров IN HIERARCHY(&qRoomQuota)", "") + 
				                                                        ?(ЗначениеЗаполнено(pHotel), " AND Гостиница IN HIERARCHY(&qHotel)", "") + 
				                                                        ?(ЗначениеЗаполнено(pRoomType), " AND ТипНомера IN HIERARCHY(&qRoomType)", "") + 
				                                                        ?(vUseRoomQuota, " AND НомерРазмещения IN (&qRoomsInQuota)", "") + "
	|		) AS RoomQuotaSalesBalance
	|		GROUP BY
	|			RoomQuotaSalesBalance.НомерРазмещения,
	|			RoomQuotaSalesBalance.ТипНомера 
	|	) AS RoomBalance
	|
	|	WHERE
	|		RoomBalance.НомерРазмещения.DeletionMark = FALSE" +
			?(pRoomStatus <> Неопределено, " AND RoomBalance.НомерРазмещения.СтатусНомера = &qRoomStatus", "") + "
	|
	|	GROUP BY
	|		RoomBalance.ТипНомера,
	|		RoomBalance.НомерРазмещения
	|	HAVING  
	|		MAX(RoomBalance.BedsVacant) >= &qNumberOfBeds 
	|	) AS НомернойФонд
	|
	|WHERE " + 
		?(ЗначениеЗаполнено(pCompany), "(НомернойФонд.ТипНомера.Фирма = &qCompany) OR (НомернойФонд.НомерРазмещения.Фирма = &qCompany) OR (НомернойФонд.ТипНомера.Фирма = &qEmptyCompany AND НомернойФонд.НомерРазмещения.Фирма = &qEmptyCompany)", "TRUE") + "
	|
	|ORDER BY
	|	ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	vQry.SetParameter("qCompany", pCompany);
	vQry.SetParameter("qEmptyCompany", Справочники.Companies.EmptyRef());
	vQry.SetParameter("qNumberOfBeds", pNumberOfBeds);
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qRoomsInQuota", vRoomsInQuota);
	vQry.SetParameter("qUseRoomQuota", ЗначениеЗаполнено(pRoomQuota));
	vQry.SetParameter("qRoomStatus", pRoomStatus);
	vQryResult = vQry.Execute();
	vRooms = vQryResult.Unload();
	
	// Get the value list of all vacant rooms
	vRoomsList = New СписокЗначений();
	For Each vRoom In vRooms Do
		vCurRoom = vRoom.ГруппаНомеров;
		If ЗначениеЗаполнено(vCurRoom) Тогда
			If vRoomsList.FindByValue(vCurRoom) = Неопределено Тогда
				vRoomsList.Add(vCurRoom);
			EndIf;
		EndIf;
	EndDo;
	
	// Get the table of nearest dates when rooms became busy
	vQryReserv = New Query();
	vQryReserv.Text = 
	"SELECT
	|	ЗагрузкаНомеров.НомерРазмещения,
	|	MIN(ЗагрузкаНомеров.ПериодС) AS CheckInDate,
	|	ЗагрузкаНомеров.НомерРазмещения.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.НомерРазмещения IN(&qRooms)
	|	AND ЗагрузкаНомеров.RecordType = &qExpense
	|	AND ЗагрузкаНомеров.ПериодС >= &qDateTo
	|	AND ЗагрузкаНомеров.ПериодС < &qNextDateTo
	|	AND (ЗагрузкаНомеров.IsReservation OR ЗагрузкаНомеров.IsAccommodation)
	|GROUP BY
	|	ЗагрузкаНомеров.НомерРазмещения
	|ORDER BY
	|	ПорядокСортировки";
	vQryReserv.SetParameter("qRooms", vRoomsList);
	vQryReserv.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQryReserv.SetParameter("qDateTo", pDateTo);
	vQryReserv.SetParameter("qNextDateTo", pDateTo + 7*24*3600); // Look only for 7 days in the future
	vReserves = vQryReserv.Execute().Unload();
	
	// Get table of nearest times when rooms became vacant
	vNumDays = 100;
	vQryVacant = New Query();
	vQryVacant.Text = 
	"SELECT
	|	ЗагрузкаНомеров.НомерРазмещения,
	|	MAX(ЗагрузкаНомеров.ПериодПо) AS ДатаВыезда,
	|	ЗагрузкаНомеров.НомерРазмещения.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.НомерРазмещения IN(&qRooms)
	|	AND ЗагрузкаНомеров.RecordType = &qReceipt
	|	AND ЗагрузкаНомеров.ПериодПо <= &qDateFrom
	|	AND ЗагрузкаНомеров.ПериодПо > &qPrevDateFrom
	|	AND (ЗагрузкаНомеров.IsReservation OR ЗагрузкаНомеров.IsAccommodation)
	|GROUP BY
	|	ЗагрузкаНомеров.НомерРазмещения
	|ORDER BY
	|	ПорядокСортировки";
	vQryVacant.SetParameter("qRooms", vRoomsList);
	vQryVacant.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vQryVacant.SetParameter("qDateFrom", pDateFrom);
	vQryVacant.SetParameter("qPrevDateFrom", pDateFrom - vNumDays*24*3600); // Look for 100 days in the past
	vVacants = vQryVacant.Execute().Unload();

	// Fill result table
	For Each vRoom In vRooms Do
		vCurRoomType = vRoom.RoomType;
		vCurRoom = vRoom.ГруппаНомеров;
		
		// Ignore duplicated totals
		If НЕ ЗначениеЗаполнено(vCurRoom) Тогда
			Continue;
		Else
			If НЕ ЗначениеЗаполнено(vCurRoomType) Тогда
				Continue;
			EndIf;
		EndIf;
		If vRoomsArray.Find(vCurRoom) = Неопределено Тогда
			vRoomsArray.Add(vCurRoom);
		Else
			Continue;
		EndIf;
		
		// Add new row
		vTableRow = vTableBoxRooms.Add();
		//vRowIndex = vTableBoxRooms.IndexOf(vTableRow);
		
		// Fill main parameters
		vTableRow.НомерРазмещения = vCurRoom;
		vTableRow.ТипНомера = vCurRoomType;
		vTableRow.ПорядокСортировки = vRoom.SortCode;
		vTableRow.BedsVacant = vRoom.BedsVacant;
		vTableRow.IsFolder = vCurRoom.IsFolder;
		vTableRow.Фирма = vCurRoom.Фирма;
		
		// Fill vacant from
		If НЕ vCurRoom.IsFolder Тогда
			If vTableRow.BedsVacant > 0 Тогда
				vRow = vVacants.Find(vCurRoom, "НомерРазмещения");
				If vRow <> Неопределено Тогда
					vTableRow.VacantFrom = vRow.ДатаВыезда;
				EndIf;
			EndIf;
		EndIf;
		
		// Fill vacant to
		If НЕ vCurRoom.IsFolder Тогда
			If vTableRow.BedsVacant > 0 Тогда
				vRow = vReserves.Find(vCurRoom, "НомерРазмещения");
				If vRow <> Неопределено Тогда
					vTableRow.VacantTo = vRow.CheckInDate;
				EndIf;
			EndIf;
		EndIf;
	EndDo;
	
	Return vTableBoxRooms;
EndFunction //cmGetVacantRoomsList

//-----------------------------------------------------------------------------
// Description: Returns default vacant ГруппаНомеров for check-in
// Parameters: Number of vacant beds that ГруппаНомеров should have, Гостиница, Фирма, 
//             ГруппаНомеров quota, ГруппаНомеров type, ГруппаНомеров status, Period from date, Period to date
// Return value: ГруппаНомеров
//-----------------------------------------------------------------------------
Function cmGetDefaultRoom(pNumberOfBeds, pHotel, pCompany, pRoomQuota, pRoomType, pDateFrom, pDateTo) Экспорт
	WriteLogEvent(NStr("en='Get default ГруппаНомеров';ru='Получить номер по умолчанию';de='Get default ГруппаНомеров'"), EventLogLevel.Information, , , 
	              NStr("en='Гостиница: ';ru='Гостиница: ';de='Гостиница: '") + pHotel + Chars.LF + 
	              NStr("en='Фирма: ';ru='Фирма: ';de='Kompanie: '") + pCompany + Chars.LF + 
	              NStr("en='Allotment: ';ru='Квота: ';de='Allotment: '") + pRoomQuota + Chars.LF + 
	              NStr("en='ГруппаНомеров type: ';ru='Тип номера: ';de='Zimmertyp: '") + pRoomType + Chars.LF + 
	              NStr("en='Number of beds: ';ru='Кол-во мест: ';de='Number of beds: '") + pNumberOfBeds + Chars.LF + 
	              NStr("en='Period from: ';ru='Период с: ';de='Period von: '") + pDateFrom + Chars.LF + 
	              NStr("en='Period to: ';ru='Период по: ';de='Period zu: '") + pDateTo); 
	
	vDftRoom = Справочники.НомернойФонд.EmptyRef();
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		Return vDftRoom;
	EndIf;
	
	// Get search default ГруппаНомеров policy
	vFillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.NoDefaultRoom;
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
		If ЗначениеЗаполнено(vPermissionGroup) Тогда
			If ЗначениеЗаполнено(vPermissionGroup.FillDefaultRoomPolicy) Тогда
				vFillDefaultRoomPolicy = vPermissionGroup.FillDefaultRoomPolicy;
			EndIf;
		EndIf;
	EndIf;
	
	// Search default ГруппаНомеров if necessary
	WriteLogEvent(NStr("en='Get default ГруппаНомеров';ru='Получить номер по умолчанию';de='Get default ГруппаНомеров'"), EventLogLevel.Information, , , СокрЛП(vFillDefaultRoomPolicy));
	If vFillDefaultRoomPolicy <> Перечисления.FillDefaultRoomPolicies.NoDefaultRoom And pNumberOfBeds > 0 Тогда
		// Fill ГруппаНомеров status filter
		vRoomStatus = Неопределено;
		If BegOfDay(pDateFrom) <= BegOfDay(CurrentDate()) Тогда
			vRoomStatus = pHotel.VacantRoomStatus;
		EndIf;
		// Get list of vacant rooms
		vVacantRooms = cmGetVacantRoomsList(pNumberOfBeds, pHotel, pCompany, pRoomQuota, pRoomType, vRoomStatus, pDateFrom, pDateTo);
		If vVacantRooms.Count() = 0 Тогда
			WriteLogEvent(NStr("en='Get default ГруппаНомеров';ru='Получить номер по умолчанию';de='Get default ГруппаНомеров'"), EventLogLevel.Information, , , "No vacant НомернойФонд was found!");
		Else
			WriteLogEvent(NStr("en='Get default ГруппаНомеров';ru='Получить номер по умолчанию';de='Get default ГруппаНомеров'"), EventLogLevel.Information, , , "Vacant НомернойФонд count is " + vVacantRooms.Count());
		EndIf;
		If vFillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.UseMaximumCapacityPolicy Тогда
			// Try to find ГруппаНомеров with minimum period from last check-out date to current check-in date
			If vVacantRooms.Count() > 0 Тогда
				vVacantRooms.Sort("VacantFrom Desc, ПорядокСортировки Desc");
				// We will use randomly one of first 5 most suitable rooms
				vRndGen = New RandomNumberGenerator(CurrentDate() - '00010101');
				i = vRndGen.RandomNumber(0, Min(4, vVacantRooms.Count() - 1));
				vDftRoom = vVacantRooms.Get(i).НомерРазмещения;
			EndIf;
		ElsIf vFillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.UseBalancedCapacityPolicy Тогда
			// Try to find ГруппаНомеров with maximum period from last check-out date to current check-in date
			If vVacantRooms.Count() > 0 Тогда
				vVacantRooms.Sort("VacantFrom Asc, ПорядокСортировки Desc");
				// We will use randomly one of first 5 most suitable rooms
				vRndGen = New RandomNumberGenerator(CurrentDate() - '00010101');
				i = vRndGen.RandomNumber(0, Min(4, vVacantRooms.Count() - 1));
				vDftRoom = vVacantRooms.Get(i).НомерРазмещения;
			EndIf;
		EndIf;
	EndIf;
	
	// Return ГруппаНомеров being found
	If ЗначениеЗаполнено(vFillDefaultRoomPolicy) Тогда
		WriteLogEvent(NStr("en='Get default ГруппаНомеров';ru='Получить номер по умолчанию';de='Get default ГруппаНомеров'"), EventLogLevel.Information, , , "НомерРазмещения found " + vDftRoom);
	EndIf;
	Return vDftRoom;
EndFunction //cmGetDefaultRoom

//-----------------------------------------------------------------------------
// Description: Returns list of vacant rooms for reservation
// Parameters: Number of vacant beds that ГруппаНомеров should have, Гостиница, Фирма, 
//             ГруппаНомеров quota, ГруппаНомеров type, Period from date, Period to date
// Return value: Value table with vacant rooms
//-----------------------------------------------------------------------------
Function cmGetListOfVacantRoomsForReservation(pNumberOfBeds, pHotel, pCompany, pRoomQuota, pRoomType, pDateFrom, pDateTo) Экспорт
	vRoomsList = New СписокЗначений();
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		Return vRoomsList;
	EndIf;
	
	// Get search default ГруппаНомеров policy
	vFillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.NoDefaultRoom;
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
		If ЗначениеЗаполнено(vPermissionGroup) Тогда
			If ЗначениеЗаполнено(vPermissionGroup.FillDefaultRoomPolicy) Тогда
				vFillDefaultRoomPolicy = vPermissionGroup.FillDefaultRoomPolicy;
			EndIf;
		EndIf;
	EndIf;
	
	// Get list of vacant rooms
	If pNumberOfBeds > 0 Тогда
		// Get list of vacant rooms
		vRoomsList = cmGetVacantRoomsList(pNumberOfBeds, pHotel, pCompany, pRoomQuota, pRoomType, Неопределено, pDateFrom, pDateTo);
	
		// Sort rooms according to the default ГруппаНомеров search policy
		If vFillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.NoDefaultRoom Тогда
			// Try to find rooms with minimum period from last check-out date to current expected check-in date
			If vRoomsList.Count() > 0 Тогда
				vRoomsList.Sort("ПорядокСортировки");
			EndIf;
		ElsIf vFillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.UseMaximumCapacityPolicy Тогда
			// Try to find rooms with minimum period from last check-out date to current expected check-in date
			If vRoomsList.Count() > 0 Тогда
				vRoomsList.Sort("VacantFrom Desc, ПорядокСортировки");
			EndIf;
		ElsIf vFillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.UseBalancedCapacityPolicy Тогда
			// Try to find ГруппаНомеров with maximum period from last check-out date to current expected check-in date
			If vRoomsList.Count() > 0 Тогда
				vRoomsList.Sort("VacantFrom Asc, ПорядокСортировки Desc");
			EndIf;
		EndIf;
	EndIf;
	
	// Return list of vacant rooms
	Return vRoomsList;
EndFunction //cmGetListOfVacantRoomsForReservation

//-----------------------------------------------------------------------------
// Description: Checks accommodation for the suspicious events and writes them 
//              to the system log file
// Parameters: Document object (Accommodation or Reservation)
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmWriteSuspiciousAccommodationEvents(pDocObj) Экспорт
	// Try to read last record from document change history
	vLastDocAttrs = pDocObj.pmGetAccommodationAttributes();
	If vLastDocAttrs.Count() > 0 Тогда
		vLastDocAttrsRow = vLastDocAttrs.Get(0);
		
		// Compare Контрагент and write event if changed
		If vLastDocAttrsRow.Контрагент <> pDocObj.Контрагент Тогда
			vEventGroup = NStr("en='SuspiciousEvents.AccommodationCustomerChange'; 
			                   |de='SuspiciousEvents.AccommodationCustomerChange'; 
			                   |ru='СигналыОПодозрительныхДействиях.ИзменениеКонтрагентаВРазмещении'");
			vEventDescription = NStr("en='Контрагент change: " + СокрЛП(vLastDocAttrsRow.Контрагент) + " -> " + СокрЛП(pDocObj.Контрагент) + "'; 
			                         |ru='Изменение контрагента: " + СокрЛП(vLastDocAttrsRow.Контрагент) + " -> " + СокрЛП(pDocObj.Контрагент) + "'");
			WriteLogEvent(vEventGroup, EventLogLevel.Warning, pDocObj.Metadata(), pDocObj.Ref, vEventDescription, EventLogEntryTransactionMode.Transactional);
		EndIf;
		
		// Compare agent and write event if changed
		If vLastDocAttrsRow.Агент <> pDocObj.Агент Тогда
			vEventGroup = NStr("en='SuspiciousEvents.AccommodationAgentChange'; 
			                   |de='SuspiciousEvents.AccommodationAgentChange'; 
			                   |ru='СигналыОПодозрительныхДействиях.ИзменениеАгентаВРазмещении'");
			vEventDescription = NStr("en='Agent change: " + СокрЛП(vLastDocAttrsRow.Агент) + " -> " + СокрЛП(pDocObj.Агент) + "'; 
			                         |de='Agent change: " + СокрЛП(vLastDocAttrsRow.Агент) + " -> " + СокрЛП(pDocObj.Агент) + "'; 
			                         |ru='Изменение агента: " + СокрЛП(vLastDocAttrsRow.Агент) + " -> " + СокрЛП(pDocObj.Агент) + "'");
			WriteLogEvent(vEventGroup, EventLogLevel.Warning, pDocObj.Metadata(), pDocObj.Ref, vEventDescription, EventLogEntryTransactionMode.Transactional);
		EndIf;
		
		// Compare ГруппаНомеров and write event if changed
		If vLastDocAttrsRow.НомерРазмещения <> pDocObj.НомерРазмещения Тогда
			vEventGroup = NStr("en='SuspiciousEvents.AccommodationRoomChange'; 
			                   |de='SuspiciousEvents.AccommodationRoomChange'; 
			                   |ru='СигналыОПодозрительныхДействиях.ИзменениеНомераВРазмещении'");
			vEventDescription = NStr("en='ГруппаНомеров change: " + СокрЛП(vLastDocAttrsRow.НомерРазмещения) + " -> " + СокрЛП(pDocObj.НомерРазмещения) + "'; 
			                         |de='ГруппаНомеров change: " + СокрЛП(vLastDocAttrsRow.НомерРазмещения) + " -> " + СокрЛП(pDocObj.НомерРазмещения) + "'; 
			                         |ru='Изменение номера: " + СокрЛП(vLastDocAttrsRow.НомерРазмещения) + " -> " + СокрЛП(pDocObj.НомерРазмещения) + "'");
			WriteLogEvent(vEventGroup, EventLogLevel.Warning, pDocObj.Metadata(), pDocObj.Ref, vEventDescription, EventLogEntryTransactionMode.Transactional);
		EndIf;
		
		// Write event if accommodation was canceled
		If ЗначениеЗаполнено(vLastDocAttrsRow.СтатусРазмещения) And ЗначениеЗаполнено(pDocObj.СтатусРазмещения) And 
		   vLastDocAttrsRow.СтатусРазмещения.IsActive And НЕ pDocObj.СтатусРазмещения.IsActive Тогда
			vEventGroup = NStr("en='SuspiciousEvents.CancelAccommodation'; 
			                   |de='SuspiciousEvents.CancelAccommodation'; 
			                   |ru='СигналыОПодозрительныхДействиях.ОтменаРазмещения'");
			vEventDescription = NStr("en='Cancel accommodation: " + СокрЛП(vLastDocAttrsRow.СтатусРазмещения) + " -> " + СокрЛП(pDocObj.СтатусРазмещения) + "'; 
			                         |de='Cancel accommodation: " + СокрЛП(vLastDocAttrsRow.СтатусРазмещения) + " -> " + СокрЛП(pDocObj.СтатусРазмещения) + "'; 
			                         |ru='Отмена размещения: " + СокрЛП(vLastDocAttrsRow.СтатусРазмещения) + " -> " + СокрЛП(pDocObj.СтатусРазмещения) + "'");
			WriteLogEvent(vEventGroup, EventLogLevel.Warning, pDocObj.Metadata(), pDocObj.Ref, vEventDescription, EventLogEntryTransactionMode.Transactional);
		EndIf;
		
		// Write event if late check-out
		If ЗначениеЗаполнено(vLastDocAttrsRow.СтатусРазмещения) And ЗначениеЗаполнено(pDocObj.СтатусРазмещения) And 
		   vLastDocAttrsRow.СтатусРазмещения.ЭтоГости And НЕ pDocObj.СтатусРазмещения.ЭтоГости And 
		   pDocObj.СтатусРазмещения.ЭтоВыезд And pDocObj.СтатусРазмещения.IsActive Тогда
			If (CurrentDate() - pDocObj.ДатаВыезда) > 2*3600 Тогда
				vEventGroup = NStr("en='SuspiciousEvents.LateCheckOut'; 
				                   |de='SuspiciousEvents.LateCheckOut'; 
				                   |ru='СигналыОПодозрительныхДействиях.ПозднееВыселение'");
				vEventDescription = NStr("en='Late check-out: " + Format(CurrentDate(), "DF='dd.MM.yyyy HH:mm'") + " - " + Format(pDocObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + " = " + Format(Round((CurrentDate() - pDocObj.ДатаВыезда)/3600, 1), "ND=10; NFD=1; NZ=; NG=") + "h.'; 
				                         |de='Late check-out: " + Format(CurrentDate(), "DF='dd.MM.yyyy HH:mm'") + " - " + Format(pDocObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + " = " + Format(Round((CurrentDate() - pDocObj.ДатаВыезда)/3600, 1), "ND=10; NFD=1; NZ=; NG=") + "h.'; 
				                         |ru='Позднее выселение: " + Format(CurrentDate(), "DF='dd.MM.yyyy HH:mm'") + " - " + Format(pDocObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + " = " + Format(Round((CurrentDate() - pDocObj.ДатаВыезда)/3600, 1), "ND=10; NFD=1; NZ=; NG=") + "ч.'");
				WriteLogEvent(vEventGroup, EventLogLevel.Warning, pDocObj.Metadata(), pDocObj.Ref, vEventDescription, EventLogEntryTransactionMode.Transactional);
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //cmWriteSuspiciousAccommodationEvents

//-----------------------------------------------------------------------------
// Description: Checks if document has master charging rules
// Parameters: Document reference
// Return value: True if document has master charging rules, false if not
//-----------------------------------------------------------------------------
Function cmCheckMasterChargingRulesArePresent(pDoc) Экспорт
	// Check if there are already master charging rules
	vMasterChargingRulesFound = False;
	vMasterChargingRules = pDoc.ChargingRules.FindRows(New Structure("IsMaster", True));
	For Each vMasterChargingRulesRow In vMasterChargingRules Do
		If ЗначениеЗаполнено(vMasterChargingRulesRow.Owner) Тогда
			If TypeOf(vMasterChargingRulesRow.Owner) = Type("DocumentRef.Бронирование") Or 
			   TypeOf(vMasterChargingRulesRow.Owner) = Type("DocumentRef.Размещение") Тогда
				vMasterChargingRulesFound = True;
				Break;
			EndIf;
		EndIf;
	EndDo;
	Return vMasterChargingRulesFound;
EndFunction //cmCheckMasterChargingRulesArePresent 

//-----------------------------------------------------------------------------
// Description: Returns list of ГруппаНомеров interface status documents for the given ГруппаНомеров
// Parameters: ГруппаНомеров, Period from date, Period to date
// Return value: Value table with ГруппаНомеров interface status documents
//-----------------------------------------------------------------------------
Function cmGetRoomInterfaceStatuses(pRoom, pPeriodFrom, pPeriodTo = Неопределено) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусДопУслугиНомер.Ref,
	|	СтатусДопУслугиНомер.Гостиница,
	|	СтатусДопУслугиНомер.НомерРазмещения,
	|	СтатусДопУслугиНомер.InterfaceType,
	|	СтатусДопУслугиНомер.RoomInterfaceType,
	|	СтатусДопУслугиНомер.Примечания,
	|	СтатусДопУслугиНомер.IsProcessed,
	|	СтатусДопУслугиНомер.IsCanceled,
	|	СтатусДопУслугиНомер.MessageDateTime,
	|	СтатусДопУслугиНомер.MessageIsDelivered,
	|	СтатусДопУслугиНомер.MessageDeliveryDateTime,
	|	СтатусДопУслугиНомер.НомерДока,
	|	СтатусДопУслугиНомер.ДатаДок,
	|	СтатусДопУслугиНомер.ДокОснование,
	|	СтатусДопУслугиНомер.Автор,
	|	СтатусДопУслугиНомер.CancellationAuthor,
	|	СтатусДопУслугиНомер.CancellationDate
	|FROM
	|	Document.СтатусДопУслугиНомер AS СтатусДопУслугиНомер
	|WHERE
	|	СтатусДопУслугиНомер.НомерРазмещения = &qRoom
	|	AND СтатусДопУслугиНомер.ДатаДок >= &qPeriodFrom
	|	AND (СтатусДопУслугиНомер.ДатаДок < &qPeriodTo
	|			OR &qPeriodToIsEmpty)
	|	AND NOT СтатусДопУслугиНомер.DeletionMark
	|
	|ORDER BY
	|	СтатусДопУслугиНомер.PointInTime";
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qPeriodToIsEmpty", НЕ ЗначениеЗаполнено(pPeriodTo));
	Return vQry.Execute().Unload();
EndFunction //cmGetRoomInterfaceStatuses

//-----------------------------------------------------------------------------
// Description: Returns number of hours allowed for a guest to examine a ГруппаНомеров 
//              without a charge
// Parameters: None
// Return value: Number of hours allowed
//-----------------------------------------------------------------------------
Function cmGetRoomExaminationFreeOfChargeTime() Экспорт
	vHrs = 0;
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vCurUsr = ПараметрыСеанса.ТекПользователь;
		If ЗначениеЗаполнено(vCurUsr) Тогда
			vCurUsrPermGrp = cmGetEmployeePermissionGroup(vCurUsr);
			If ЗначениеЗаполнено(vCurUsrPermGrp) Тогда
				vHrs = vCurUsrPermGrp.RoomExaminationFreeOfChargeTime;
			EndIf;
		EndIf;
	EndIf;
	Return vHrs;
EndFunction //cmGetRoomExaminationFreeOfChargeTime

//-----------------------------------------------------------------------------
// Description: Returns value table with reservation services
// Parameters: Reservation reference
// Return value: Value table with services
//-----------------------------------------------------------------------------
Function cmGetReservationServices(pResRef) Экспорт
	// Unload document services
	vServices = pResRef.Услуги.Unload();
	If pResRef.DoCharging Тогда
		vServices.Clear();
	EndIf;
	
	// Get reservation charges for the folios
	vCharges = cmGetDocumentCharges(pResRef, pResRef.Контрагент, pResRef.Договор, pResRef.Гостиница, Неопределено, True);
	For Each vChargesRow In vCharges Do
		vSrvRow = vServices.Add();
		FillPropertyValues(vSrvRow, vChargesRow);
		vSrvRow.Сумма = vSrvRow.Сумма + vSrvRow.СуммаСкидки;
	EndDo;
	
	// Update ГруппаНомеров type if necessary
	vRoomTypeToPrint = pResRef.ТипНомера;
	If ЗначениеЗаполнено(vRoomTypeToPrint) And ЗначениеЗаполнено(pResRef.ТипНомераРасчет) And pResRef.ТипНомераРасчет.BaseRoomType = vRoomTypeToPrint Тогда
		vRoomTypeToPrint = pResRef.ТипНомераРасчет;
		For Each vSrvRow In vServices Do
			If vSrvRow.ТипНомера = pResRef.ТипНомера Тогда
				vSrvRow.ТипНомера = vRoomTypeToPrint;
			EndIf;
		EndDo;
	EndIf;
	
	// Return value table
	Return vServices;
EndFunction //cmGetReservationServices

//-----------------------------------------------------------------------------
// Returns value table with services for all ГруппаНомеров reservations
//-----------------------------------------------------------------------------
Function cmGetReservationRoomServices(pResRef) Экспорт
	If ЗначениеЗаполнено(pResRef.ВидРазмещения) And pResRef.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.НомерРазмещения Тогда
		vServices = cmGetReservationServices(pResRef);
		vOneRoomReservations = cmGetOneRoomReservations(pResRef.НомерДока, pResRef.ГруппаГостей, pResRef.CheckInDate, pResRef.ДатаВыезда);
		For Each vResRow In vOneRoomReservations Do
			vResRef = vResRow.Ref;
			If vResRef <> pResRef Тогда
				vAddServices = cmGetReservationServices(vResRef);
				For Each vAddServicesRow In vAddServices Do
					If vAddServicesRow.IsInPrice Тогда
						vSrvRow = vServices.Add();
						FillPropertyValues(vSrvRow, vAddServicesRow); 
						vSrvRow.Количество = 0;
					EndIf;
				EndDo;
			EndIf;
		EndDo;
		Return vServices;
	ElsIf ЗначениеЗаполнено(pResRef.ВидРазмещения) And pResRef.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.Beds Тогда
		Return cmGetReservationServices(pResRef);
	Else
		vServices = cmGetReservationServices(pResRef);
		vOneRoomReservations = cmGetOneRoomReservations(pResRef.НомерДока, pResRef.ГруппаГостей, pResRef.CheckInDate, pResRef.ДатаВыезда);
		If vOneRoomReservations.Count() > 1 Тогда
			vMainRoomDoc = vOneRoomReservations.Get(0).Ref;
			If vMainRoomDoc.RoomQuantity = 1 Тогда
				For Each vServicesRow In vServices Do
					If vServicesRow.IsInPrice Тогда
						vServicesRow.Цена = 0;
						vServicesRow.Сумма = 0;
						vServicesRow.СуммаСкидки = 0;
						vServicesRow.СуммаНДС = 0;
					EndIf;
				EndDo;
			EndIf;
		EndIf;
		Return vServices;
	EndIf;
EndFunction //cmGetReservationRoomServices

//-----------------------------------------------------------------------------
// Description: Returns string to be used to sort selected accommodations or reservations
// Parameters: Reservation or accommodation reference
// Return value: String
//-----------------------------------------------------------------------------
Function cmBuildAccommodationSortingPresentation(pDoc) Экспорт
	vStr = "";
	If ЗначениеЗаполнено(pDoc.НомерРазмещения) Тогда
		vStr = vStr + Format(pDoc.НомерРазмещения.ПорядокСортировки, "ND=8; NFD=0; NZ=; NLZ=; NG=");
	Else
		vStr = vStr + Format(0, "ND=8; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	If ЗначениеЗаполнено(pDoc.ТипНомера) Тогда
		vStr = vStr + Format(pDoc.ТипНомера.ПорядокСортировки, "ND=8; NFD=0; NZ=; NLZ=; NG=");
	Else
		vStr = vStr + Format(0, "ND=8; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	If НЕ IsBlankString(pDoc.НомерДока) Тогда
		vStr = vStr + pDoc.НомерДока;
	Else
		vStr = vStr + "            ";
	EndIf;
	If ЗначениеЗаполнено(pDoc.ДатаДок) Тогда
		vStr = vStr + Format(pDoc.ДатаДок, "DF=yyyyMMddHHmmss");
	Else
		vStr = vStr + "              ";
	EndIf;
	If ЗначениеЗаполнено(pDoc.ВидРазмещения) Тогда
		vStr = vStr + Format(pDoc.ВидРазмещения.ПорядокСортировки, "ND=4; NFD=0; NZ=; NLZ=; NG=");
	Else
		vStr = vStr + Format(0, "ND=4; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	If ЗначениеЗаполнено(pDoc.CheckInDate) Тогда
		vStr = vStr + Format(pDoc.CheckInDate, "DF=yyyyMMddHHmmss");
	Else
		vStr = vStr + "              ";
	EndIf;
	vStr = vStr + String(pDoc.PointInTime());
	Return vStr;
EndFunction //cmBuildAccommodationSortingPresentation

//-----------------------------------------------------------------------------
// Description: Returns first available "together" accommodation type
// Parameters: None
// Return value: Reference to the "Accommodation types" catalog item
//-----------------------------------------------------------------------------
Function cmGetTogetherAccommodationType() Экспорт
	vTogether = Неопределено;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ВидыРазмещений.Ref
	|FROM
	|	Catalog.ВидыРазмещений AS ВидыРазмещений
	|WHERE
	|	(NOT ВидыРазмещений.DeletionMark)
	|	AND (NOT ВидыРазмещений.IsFolder)
	|	AND ВидыРазмещений.ТипРазмещения = &qTogether
	|
	|ORDER BY
	|	ВидыРазмещений.ПорядокСортировки,
	|	ВидыРазмещений.Description";
	vQry.SetParameter("qTogether", Перечисления.AccomodationTypes.Together);
	vTypes = vQry.Execute().Unload();
	If vTypes.Count() > 0 Тогда
		vTogether = vTypes.Get(0).Ref;
	EndIf;
	Return vTogether;
EndFunction //cmGetTogetherAccommodationType 

//-----------------------------------------------------------------------------
// Description: Returns starting date and time for key card to open door lock
// Parameters: Guest check-in date and time
// Return value: Date and time to start opening door lock
//-----------------------------------------------------------------------------
Function cmGetKeyCardCheckInTime(pCheckInDate, pIsReservation = False) Экспорт
	vCheckInDate = pCheckInDate;
	If BegOfDay(CurrentDate()) = BegOfDay(pCheckInDate) And CurrentDate() < pCheckInDate Тогда
		If НЕ pIsReservation Тогда
			vCheckInDate = CurrentDate();
		EndIf;
	ElsIf BegOfDay(CurrentDate()) > BegOfDay(pCheckInDate) Тогда
		vCheckInDate = CurrentDate();
	ElsIf НЕ pIsReservation Тогда
		vCheckInDate = CurrentDate();
	EndIf;
	Return vCheckInDate;
EndFunction //cmGetKeyCardCheckInTime

//-----------------------------------------------------------------------------
// Description: Returns guest group status according to the guest group document statuses
// Parameters: Guest group catalog item reference
// Return value: Guest group status reference
//-----------------------------------------------------------------------------
Function cmGetGuestGroupStatus(pGuestGroup) Экспорт
	vGroupStatus = Неопределено;
	If ЗначениеЗаполнено(pGuestGroup) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT TOP 1
		|	GroupDocuments.Status AS Status,
		|	GroupDocuments.Order AS Order
		|FROM
		|	(SELECT
		|		Бронирование.ReservationStatus AS Status,
		|		CASE
		|			WHEN Бронирование.ReservationStatus.IsPreliminary
		|				THEN 1
		|			WHEN Бронирование.ReservationStatus.IsActive
		|				THEN 2
		|			WHEN Бронирование.ReservationStatus.IsNoShow
		|				THEN 3
		|			WHEN Бронирование.ReservationStatus.ЭтоЗаезд
		|				THEN 10
		|			WHEN Бронирование.ReservationStatus.IsAnnulation
		|				THEN 15
		|			ELSE 90
		|		END AS Order
		|	FROM
		|		Document.Бронирование AS Бронирование
		|	WHERE
		|		Бронирование.Posted
		|		AND Бронирование.ГруппаГостей = &qGuestGroup
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		БроньУслуг.ResourceReservationStatus,
		|		CASE
		|			WHEN БроньУслуг.ResourceReservationStatus.ServicesAreDelivered
		|				THEN 55
		|			ELSE 50
		|		END
		|	FROM
		|		Document.БроньУслуг AS БроньУслуг
		|	WHERE
		|		БроньУслуг.Posted
		|		AND БроньУслуг.ГруппаГостей = &qGuestGroup
		|	
		|	UNION ALL
		|	
		|	SELECT
		|		CASE
		|			WHEN Размещение.СтатусРазмещения.IsActive
		|					AND Размещение.СтатусРазмещения.ЭтоГости
		|				THEN &qCheckInReservationStatus
		|			WHEN Размещение.СтатусРазмещения.IsActive
		|				THEN &qCheckOutAccommodationStatus
		|		END,
		|		CASE
		|			WHEN Размещение.СтатусРазмещения.IsActive
		|					AND Размещение.СтатусРазмещения.ЭтоГости
		|				THEN 11
		|			WHEN Размещение.СтатусРазмещения.IsActive
		|				THEN 9
		|			ELSE 95
		|		END
		|	FROM
		|		Document.Размещение AS Размещение
		|	WHERE
		|		Размещение.Posted
		|		AND Размещение.СтатусРазмещения.IsActive
		|		AND Размещение.ГруппаГостей = &qGuestGroup) AS GroupDocuments
		|
		|ORDER BY
		|	Order";
		vQry.SetParameter("qGuestGroup", pGuestGroup);
		vQry.SetParameter("qCheckInReservationStatus", pGuestGroup.Owner.CheckInReservationStatus);
		vQry.SetParameter("qCheckOutAccommodationStatus", pGuestGroup.Owner.CheckOutAccommodationStatus);
		vQryRes = vQry.Execute().Unload();
		If vQryRes.Count() > 0 Тогда
			vGroupStatus = vQryRes.Get(0).Status;
		EndIf;
	EndIf;
	Return vGroupStatus;
EndFunction //cmGetGuestGroupStatus

//-----------------------------------------------------------------------------
// Description: Returns value list of guest group statuses that are interesting 
//              to the sales manager
// Parameters: None
// Return value: Value list of group status references
//-----------------------------------------------------------------------------
Function cmGetSalesGuestGroupStatuses() Экспорт
	vStatusesList = New СписокЗначений();
	// Build list of active or preliminary group statuses
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусБрони.Ref AS Ref,
	|	СтатусБрони.ПорядокСортировки AS ПорядокСортировки,
	|	СтатусБрони.Description AS Description
	|FROM
	|	Catalog.СтатусБрони AS СтатусБрони
	|WHERE
	|	(NOT СтатусБрони.DeletionMark)
	|	AND (NOT СтатусБрони.IsFolder)
	|	AND (СтатусБрони.IsActive
	|			OR СтатусБрони.IsPreliminary)
	|
	|UNION ALL
	|
	|SELECT
	|	СтатусБрониРесурсов.Ref,
	|	СтатусБрониРесурсов.ПорядокСортировки,
	|	СтатусБрониРесурсов.Description
	|FROM
	|	Catalog.СтатусБрониРесурсов AS СтатусБрониРесурсов
	|WHERE
	|	(NOT СтатусБрониРесурсов.DeletionMark)
	|	AND (NOT СтатусБрониРесурсов.IsFolder)
	|	AND СтатусБрониРесурсов.IsActive
	|	AND (NOT СтатусБрониРесурсов.ServicesAreDelivered)
	|
	|ORDER BY
	|	ПорядокСортировки,
	|	Description";
	vStatuses = vQry.Execute().Unload();
	For Each vStatusesRow In vStatuses Do
		vStatusesList.Add(vStatusesRow.Ref);
	EndDo;
	Return vStatusesList;
EndFunction //cmGetSalesGuestGroupStatuses

//-----------------------------------------------------------------------------
// Description: Returns value list of events that are not marked for deletion and
//              with periods intersecting with period requested
// Parameters: Period starting date, Period ending date, Гостиница (could be empty)
// Return value: Value table with events
//-----------------------------------------------------------------------------
Function cmGetAccommodationTemplatesValidForRoomType(pRoomType = Неопределено, pNumberOfPersons = 0) Экспорт
	vAccTmplates = New СписокЗначений();
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	AccommodationTemplates.Ref
	|FROM
	|	Catalog.AccommodationTemplates AS AccommodationTemplates
	|WHERE
	|	(NOT AccommodationTemplates.DeletionMark)
	|
	|ORDER BY
	|	AccommodationTemplates.Code";
	vAccTmplatesRows = vQry.Execute().Unload();
	For Each vAccTmplatesRow In vAccTmplatesRows Do
		vAccTemplateRef = vAccTmplatesRow.Ref;
		If vAccTemplateRef.ТипыНомеров.Count() = 0 Or НЕ ЗначениеЗаполнено(pRoomType) Тогда
			If ЗначениеЗаполнено(pRoomType) Тогда
				If ЗначениеЗаполнено(vAccTemplateRef.Гостиница) Тогда
					If vAccTemplateRef.Гостиница = pRoomType.Owner Тогда
						If pNumberOfPersons = 0 Тогда
							vAccTmplates.Add(vAccTemplateRef);
						ElsIf vAccTemplateRef.ВидыРазмещений.Count() = pNumberOfPersons Тогда
							vAccTmplates.Add(vAccTemplateRef);
						EndIf;							
					EndIf;
				Else
					If pNumberOfPersons = 0 Тогда
						vAccTmplates.Add(vAccTemplateRef);
					ElsIf vAccTemplateRef.ВидыРазмещений.Count() = pNumberOfPersons Тогда
						vAccTmplates.Add(vAccTemplateRef);
					EndIf;							
				EndIf;
			Else
				If pNumberOfPersons = 0 Тогда
					vAccTmplates.Add(vAccTemplateRef);
				ElsIf vAccTemplateRef.ВидыРазмещений.Count() = pNumberOfPersons Тогда
					vAccTmplates.Add(vAccTemplateRef);
				EndIf;							
			EndIf;
		Else
			If vAccTemplateRef.ТипыНомеров.Find(pRoomType, "ТипНомера") <> Неопределено Тогда
				If pNumberOfPersons = 0 Тогда
					vAccTmplates.Add(vAccTemplateRef);
				ElsIf vAccTemplateRef.ВидыРазмещений.Count() = pNumberOfPersons Тогда
					vAccTmplates.Add(vAccTemplateRef);
				EndIf;							
			EndIf;
		EndIf;
	EndDo;
	Return vAccTmplates;
EndFunction //cmGetAccommodationTemplatesValidForRoomType

//-----------------------------------------------------------------------------
// Description: Checks if accommodation period starts and ends on the same dates 
//              as check-in periods for the allotment given
// Parameters: Гостиница item reference, allotment item reference, 
//             check-in date, check-out date
// Return value: True if check is OK, False if not
//-----------------------------------------------------------------------------
Function cmCheckCheckInPeriods(pHotel, pRoomQuota, pCheckInDate, pCheckOutDate) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomRateCheckInPeriods.Гостиница,
	|	RoomRateCheckInPeriods.Тариф,
	|	RoomRateCheckInPeriods.КвотаНомеров,
	|	RoomRateCheckInPeriods.CheckInDate,
	|	RoomRateCheckInPeriods.Продолжительность,
	|	RoomRateCheckInPeriods.ДатаВыезда
	|FROM
	|	InformationRegister.RoomQuotaCheckInPeriods AS RoomRateCheckInPeriods
	|WHERE
	|	RoomRateCheckInPeriods.Гостиница = &qHotel
	|	AND RoomRateCheckInPeriods.КвотаНомеров = &qRoomQuota
	|	AND (BEGINOFPERIOD(RoomRateCheckInPeriods.CheckInDate, DAY) = &qCheckInDate
	|			OR BEGINOFPERIOD(RoomRateCheckInPeriods.ДатаВыезда, DAY) = &qCheckOutDate)
	|	AND (NOT RoomRateCheckInPeriods.IsNotActive)";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qCheckInDate", BegOfDay(pCheckInDate));
	vQry.SetParameter("qCheckOutDate", BegOfDay(pCheckOutDate));
	vPeriods = vQry.Execute().Unload();
	vStartIsFound = False;
	vEndIsFound = False;
	For Each vPeriodsRow In vPeriods Do
		If BegOfDay(vPeriodsRow.CheckInDate) = BegOfDay(pCheckInDate) Тогда
			vStartIsFound = True;
		EndIf;
		If BegOfDay(vPeriodsRow.CheckOutDate) = BegOfDay(pCheckOutDate) Тогда
			vEndIsFound = True;
		EndIf;
		If vStartIsFound And vEndIsFound Тогда
			Break;
		EndIf;
	EndDo;
	If vStartIsFound And vEndIsFound Тогда
		Return True;
	Else
		Return False;
	EndIf;
EndFunction //cmCheckCheckInPeriods

//-----------------------------------------------------------------------------
// Description: Returns list of check-in periods suitable for accommodation or reservation
// Parameters: Гостиница item reference, allotments folder reference, ГруппаНомеров type item reference, 
//             check-in date, check-out date
// Return value: Value table with list of check-in periods
//-----------------------------------------------------------------------------
Function cmGetCheckInPeriodsWithBalances(pHotel, pRoomQuota, pRoomType, pCustomer, pCheckInDate, pCheckOutDate) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalances.Period AS PeriodDate,
	|	RoomInventoryBalances.Гостиница AS Гостиница,
	|	RoomInventoryBalances.ТипНомера AS ТипНомера,
	|	RoomInventoryBalances.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	&qEmptyRoomQuota AS КвотаНомеров,
	|	&qEmptyString AS RoomQuotaDescription,
	|	0 AS RoomQuotaSortCode,
	|	RoomInventoryBalances.CounterClosingBalance,
	|	RoomInventoryBalances.RoomsVacantClosingBalance AS RoomsVacant,
	|	RoomInventoryBalances.BedsVacantClosingBalance AS BedsVacant
	|INTO RoomInventoryBalances
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Day,
	|			RegisterRecordsAndPeriodBoundaries,
	|			&qRoomQuotaIsEmpty
	|				AND Гостиница = &qHotel
	|				AND ТипНомера = &qRoomType) AS RoomInventoryBalances
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	AllotmentBalances.Period AS PeriodDate,
	|	AllotmentBalances.Гостиница AS Гостиница,
	|	AllotmentBalances.ТипНомера AS ТипНомера,
	|	AllotmentBalances.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	AllotmentBalances.КвотаНомеров AS КвотаНомеров,
	|	AllotmentBalances.КвотаНомеров.Description AS RoomQuotaDescription,
	|	AllotmentBalances.КвотаНомеров.ПорядокСортировки AS RoomQuotaSortCode,
	|	AllotmentBalances.CounterClosingBalance AS CounterClosingBalance,
	|	AllotmentBalances.RoomsInQuotaClosingBalance AS НомеровКвота,
	|	AllotmentBalances.BedsInQuotaClosingBalance AS МестКвота,
	|	AllotmentBalances.RoomsRemainsClosingBalance AS ОстаетсяНомеров,
	|	AllotmentBalances.BedsRemainsClosingBalance AS ОстаетсяМест
	|INTO AllotmentBalances
	|FROM
	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Day,
	|			RegisterRecordsAndPeriodBoundaries,
	|			NOT &qRoomQuotaIsEmpty
	|				AND КвотаНомеров <> &qEmptyRoomQuota
	|				AND Гостиница = &qHotel
	|				AND ТипНомера = &qRoomType
	|				AND (КвотаНомеров IN HIERARCHY (&qRoomQuota)
	|					OR &qRoomQuotaIsEmpty
	|					OR КвотаНомеров = &qBaseRoomQuota
	|						AND &qBaseRoomQuotaIsFilled)
	|				AND (КвотаНомеров.Контрагент = &qCustomer
	|					OR КвотаНомеров.Контрагент = &qEmptyCustomer
	|					OR &qCustomerIsEmpty)) AS AllotmentBalances
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomQuotaCheckInPeriods.Гостиница AS Гостиница,
	|	RoomQuotaCheckInPeriods.КвотаНомеров AS КвотаНомеров,
	|	RoomQuotaCheckInPeriods.КвотаНомеров.Description AS RoomQuotaDescription,
	|	RoomQuotaCheckInPeriods.КвотаНомеров.ПорядокСортировки AS RoomQuotaSortCode,
	|	RoomQuotaCheckInPeriods.CheckInDate AS CheckInDate,
	|	RoomQuotaCheckInPeriods.Продолжительность AS Продолжительность,
	|	RoomQuotaCheckInPeriods.ДатаВыезда AS ДатаВыезда,
	|	BEGINOFPERIOD(RoomQuotaCheckInPeriods.CheckInDate, DAY) AS BegOfCheckInDate,
	|	BEGINOFPERIOD(RoomQuotaCheckInPeriods.ДатаВыезда, DAY) AS BegOfCheckOutDate
	|INTO CheckInPeriods
	|FROM
	|	InformationRegister.RoomQuotaCheckInPeriods AS RoomQuotaCheckInPeriods
	|WHERE
	|	NOT RoomQuotaCheckInPeriods.IsNotActive
	|	AND RoomQuotaCheckInPeriods.Гостиница = &qHotel
	|	AND (RoomQuotaCheckInPeriods.КвотаНомеров IN HIERARCHY (&qRoomQuota)
	|			OR &qRoomQuotaIsEmpty
	|			OR RoomQuotaCheckInPeriods.КвотаНомеров = &qBaseRoomQuota
	|				AND &qBaseRoomQuotaIsFilled)
	|	AND (RoomQuotaCheckInPeriods.КвотаНомеров.Контрагент = &qCustomer
	|			OR RoomQuotaCheckInPeriods.КвотаНомеров = &qEmptyRoomQuota
	|			OR RoomQuotaCheckInPeriods.КвотаНомеров.Контрагент = &qEmptyCustomer
	|			OR &qCustomerIsEmpty)
	|	AND (BEGINOFPERIOD(RoomQuotaCheckInPeriods.CheckInDate, DAY) >= BEGINOFPERIOD(&qPeriodFrom, DAY)
	|			AND BEGINOFPERIOD(RoomQuotaCheckInPeriods.ДатаВыезда, DAY) <= BEGINOFPERIOD(&qPeriodTo, DAY))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	BalancesByDates.PeriodDate AS PeriodDate,
	|	BalancesByDates.Гостиница AS Гостиница,
	|	BalancesByDates.ТипНомера AS ТипНомера,
	|	BalancesByDates.RoomTypeSortCode AS RoomTypeSortCode,
	|	BalancesByDates.КвотаНомеров AS КвотаНомеров,
	|	BalancesByDates.RoomQuotaDescription AS RoomQuotaDescription,
	|	BalancesByDates.RoomQuotaSortCode AS RoomQuotaSortCode,
	|	SUM(BalancesByDates.RoomsVacant) AS RoomsVacant,
	|	SUM(BalancesByDates.BedsVacant) AS BedsVacant,
	|	SUM(BalancesByDates.НомеровКвота) AS НомеровКвота,
	|	SUM(BalancesByDates.МестКвота) AS МестКвота,
	|	SUM(BalancesByDates.ОстаетсяНомеров) AS ОстаетсяНомеров,
	|	SUM(BalancesByDates.ОстаетсяМест) AS ОстаетсяМест
	|INTO BalancesByDates
	|FROM
	|	(SELECT
	|		InventoryBalances.PeriodDate AS PeriodDate,
	|		InventoryBalances.Гостиница AS Гостиница,
	|		InventoryBalances.ТипНомера AS ТипНомера,
	|		InventoryBalances.RoomTypeSortCode AS RoomTypeSortCode,
	|		InventoryBalances.КвотаНомеров AS КвотаНомеров,
	|		InventoryBalances.RoomQuotaDescription AS RoomQuotaDescription,
	|		InventoryBalances.RoomQuotaSortCode AS RoomQuotaSortCode,
	|		InventoryBalances.RoomsVacant AS RoomsVacant,
	|		InventoryBalances.BedsVacant AS BedsVacant,
	|		0 AS НомеровКвота,
	|		0 AS МестКвота,
	|		0 AS ОстаетсяНомеров,
	|		0 AS ОстаетсяМест
	|	FROM
	|		RoomInventoryBalances AS InventoryBalances
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		AllotmentBalances.PeriodDate,
	|		AllotmentBalances.Гостиница,
	|		AllotmentBalances.ТипНомера,
	|		AllotmentBalances.RoomTypeSortCode,
	|		AllotmentBalances.КвотаНомеров,
	|		AllotmentBalances.RoomQuotaDescription,
	|		AllotmentBalances.RoomQuotaSortCode,
	|		0,
	|		0,
	|		AllotmentBalances.НомеровКвота,
	|		AllotmentBalances.МестКвота,
	|		AllotmentBalances.ОстаетсяНомеров,
	|		AllotmentBalances.ОстаетсяМест
	|	FROM
	|		AllotmentBalances AS AllotmentBalances) AS BalancesByDates
	|
	|GROUP BY
	|	BalancesByDates.PeriodDate,
	|	BalancesByDates.Гостиница,
	|	BalancesByDates.ТипНомера,
	|	BalancesByDates.RoomTypeSortCode,
	|	BalancesByDates.КвотаНомеров,
	|	BalancesByDates.RoomQuotaDescription,
	|	BalancesByDates.RoomQuotaSortCode
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	BalancesByDates.Гостиница AS Гостиница,
	|	BalancesByDates.ТипНомера AS ТипНомера,
	|	BalancesByDates.RoomTypeSortCode AS RoomTypeSortCode,
	|	BalancesByDates.КвотаНомеров AS КвотаНомеров,
	|	BalancesByDates.RoomQuotaDescription AS RoomQuotaDescription,
	|	BalancesByDates.RoomQuotaSortCode AS RoomQuotaSortCode,
	|	CASE
	|		WHEN NOT ISNULL(BalancesByDates.КвотаНомеров.IsForCheckInPeriods, FALSE)
	|			THEN ISNULL(CheckInPeriods.Продолжительность, 1)
	|		ELSE CheckInPeriods.Продолжительность
	|	END AS Продолжительность,
	|	ISNULL(CheckInPeriods.CheckInDate, DATEADD(BalancesByDates.PeriodDate, SECOND, &qCheckInHourSeconds)) AS CheckInDate,
	|	ISNULL(CheckInPeriods.ДатаВыезда, DATEADD(BalancesByDates.PeriodDate, SECOND, &qNextDayCheckInHourSeconds)) AS ДатаВыезда,
	|	MIN(BalancesByDates.RoomsVacant) AS RoomsVacant,
	|	MIN(BalancesByDates.BedsVacant) AS BedsVacant,
	|	MIN(BalancesByDates.НомеровКвота) AS НомеровКвота,
	|	MIN(BalancesByDates.МестКвота) AS МестКвота,
	|	MIN(BalancesByDates.ОстаетсяНомеров) AS ОстаетсяНомеров,
	|	MIN(BalancesByDates.ОстаетсяМест) AS ОстаетсяМест
	|FROM
	|	BalancesByDates AS BalancesByDates
	|		LEFT JOIN CheckInPeriods AS CheckInPeriods
	|		ON BalancesByDates.Гостиница = CheckInPeriods.Гостиница
	|			AND BalancesByDates.КвотаНомеров = CheckInPeriods.КвотаНомеров
	|			AND BalancesByDates.PeriodDate >= CheckInPeriods.BegOfCheckInDate
	|			AND BalancesByDates.PeriodDate < CheckInPeriods.BegOfCheckOutDate
	|WHERE
	|	NOT CheckInPeriods.Продолжительность IS NULL 
	|	AND BalancesByDates.Гостиница = &qHotel
	|	AND BalancesByDates.ТипНомера = &qRoomType
	|	AND (BalancesByDates.КвотаНомеров IN HIERARCHY (&qRoomQuota)
	|			OR &qRoomQuotaIsEmpty
	|			OR BalancesByDates.КвотаНомеров = &qBaseRoomQuota
	|				AND &qBaseRoomQuotaIsFilled)
	|	AND ISNULL(CheckInPeriods.ДатаВыезда, DATEADD(BalancesByDates.PeriodDate, SECOND, &qNextDayCheckInHourSeconds)) <= &qPeriodTo
	|
	|GROUP BY
	|	BalancesByDates.Гостиница,
	|	BalancesByDates.ТипНомера,
	|	BalancesByDates.RoomTypeSortCode,
	|	BalancesByDates.КвотаНомеров,
	|	BalancesByDates.RoomQuotaDescription,
	|	BalancesByDates.RoomQuotaSortCode,
	|	CASE
	|		WHEN NOT ISNULL(BalancesByDates.КвотаНомеров.IsForCheckInPeriods, FALSE)
	|			THEN ISNULL(CheckInPeriods.Продолжительность, 1)
	|		ELSE CheckInPeriods.Продолжительность
	|	END,
	|	ISNULL(CheckInPeriods.CheckInDate, DATEADD(BalancesByDates.PeriodDate, SECOND, &qCheckInHourSeconds)),
	|	ISNULL(CheckInPeriods.ДатаВыезда, DATEADD(BalancesByDates.PeriodDate, SECOND, &qNextDayCheckInHourSeconds))
	|
	|ORDER BY
	|	RoomTypeSortCode,
	|	RoomQuotaSortCode,
	|	RoomQuotaDescription,
	|	CheckInDate,
	|	Продолжительность";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(pCustomer));
	vQry.SetParameter("qEmptyCustomer", Справочники.Customers.EmptyRef());
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qEmptyRoomQuota", Справочники.КвотаНомеров.EmptyRef());
	vQry.SetParameter("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(pRoomQuota));
	If ЗначениеЗаполнено(pRoomQuota) And НЕ pRoomQuota.IsFolder Тогда
		If ЗначениеЗаполнено(pRoomQuota.BaseRoomQuota) And НЕ pRoomQuota.BaseRoomQuota.IsFolder Тогда
			vQry.SetParameter("qBaseRoomQuota", pRoomQuota.BaseRoomQuota);
			vQry.SetParameter("qBaseRoomQuotaIsFilled", True);
		Else
			vQry.SetParameter("qBaseRoomQuota", Справочники.КвотаНомеров.EmptyRef());
			vQry.SetParameter("qBaseRoomQuotaIsFilled", False);
		EndIf;
	Else
		vQry.SetParameter("qBaseRoomQuota", Справочники.КвотаНомеров.EmptyRef());
		vQry.SetParameter("qBaseRoomQuotaIsFilled", False);
	EndIf;
	vQry.SetParameter("qPeriodFrom", pCheckInDate);
	vQry.SetParameter("qPeriodTo", pCheckOutDate);
	vQry.SetParameter("qEmptyString", "");
	vRefHour = cmGetReferenceHour(pHotel.Тариф);
	vCheckInHourSeconds = vRefHour - BegOfDay(vRefHour);
	vQry.SetParameter("qCheckInHourSeconds", vCheckInHourSeconds + 1);
	vQry.SetParameter("qNextDayCheckInHourSeconds", vCheckInHourSeconds + (24*3600));
	Return vQry.Execute().Unload();
EndFunction //cmGetCheckInPeriodsWithBalances

//-----------------------------------------------------------------------------
// Description: Returns list of check-in periods suitable for accommodation or reservation
// Parameters: Гостиница item reference, allotments folder reference, ГруппаНомеров type item reference, 
//             check-in date, check-out date
// Return value: Value table with list of check-in periods
//-----------------------------------------------------------------------------
Function cmGetSuitableAllotments(pCheckInPeriods, pCheckInDate, pCheckOutDate) Экспорт
	// Process table of check-in periods
	If pCheckInPeriods.Count() > 1 Тогда
		i = 0;
		While i < (pCheckInPeriods.Count() - 1) Do
			vCheckInPeriodsRow = pCheckInPeriods.Get(i);
			vNextCheckInPeriodsRow = pCheckInPeriods.Get(i + 1);
			If vCheckInPeriodsRow.Гостиница = vNextCheckInPeriodsRow.Гостиница And 
			   vCheckInPeriodsRow.ТипНомера = vNextCheckInPeriodsRow.ТипНомера And 
			   vCheckInPeriodsRow.КвотаНомеров = vNextCheckInPeriodsRow.КвотаНомеров Тогда
				If vCheckInPeriodsRow.ДатаВыезда < vNextCheckInPeriodsRow.CheckInDate Тогда
                	vNewCheckInPeriodsRow = pCheckInPeriods.Вставить(i + 1);
					FillPropertyValues(vNewCheckInPeriodsRow, vNextCheckInPeriodsRow);
					vNewCheckInPeriodsRow.CheckInDate = vCheckInPeriodsRow.ДатаВыезда;
					vNewCheckInPeriodsRow.ДатаВыезда = vNextCheckInPeriodsRow.CheckInDate;
					vNewCheckInPeriodsRow.RoomsVacant = 0;
					vNewCheckInPeriodsRow.BedsVacant = 0;
					vNewCheckInPeriodsRow.НомеровКвота = 0;
					vNewCheckInPeriodsRow.МестКвота = 0;
					vNewCheckInPeriodsRow.ОстаетсяНомеров = 0;
					vNewCheckInPeriodsRow.ОстаетсяМест = 0;
					i = i + 1;
				EndIf;
			EndIf;
			i = i + 1;
		EndDo;
	EndIf;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Allotments.Гостиница AS Гостиница,
	|	Allotments.ТипНомера AS ТипНомера,
	|	Allotments.RoomTypeSortCode AS RoomTypeSortCode,
	|	Allotments.КвотаНомеров AS КвотаНомеров,
	|	Allotments.RoomQuotaDescription AS RoomQuotaDescription,
	|	Allotments.RoomQuotaSortCode AS RoomQuotaSortCode,
	|	Allotments.CheckInDate AS CheckInDate,
	|	Allotments.ДатаВыезда AS ДатаВыезда,
	|	Allotments.RoomsVacant AS RoomsVacant,
	|	Allotments.BedsVacant AS BedsVacant,
	|	Allotments.НомеровКвота AS НомеровКвота,
	|	Allotments.МестКвота AS МестКвота,
	|	Allotments.ОстаетсяНомеров AS ОстаетсяНомеров,
	|	Allotments.ОстаетсяМест AS ОстаетсяМест
	|INTO SuitableAllotments
	|FROM
	|	&qSuitableAllotments AS Allotments
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	SuitableAllotments.Гостиница AS Гостиница,
	|	SuitableAllotments.ТипНомера AS ТипНомера,
	|	SuitableAllotments.RoomTypeSortCode AS RoomTypeSortCode,
	|	SuitableAllotments.КвотаНомеров AS КвотаНомеров,
	|	SuitableAllotments.RoomQuotaDescription AS RoomQuotaDescription,
	|	SuitableAllotments.RoomQuotaSortCode AS RoomQuotaSortCode,
	|	MIN(SuitableAllotments.CheckInDate) AS CheckInDate,
	|	MAX(SuitableAllotments.ДатаВыезда) AS ДатаВыезда,
	|	MIN(SuitableAllotments.RoomsVacant) AS RoomsVacant,
	|	MIN(SuitableAllotments.BedsVacant) AS BedsVacant,
	|	MIN(SuitableAllotments.НомеровКвота) AS НомеровКвота,
	|	MIN(SuitableAllotments.МестКвота) AS МестКвота,
	|	MIN(SuitableAllotments.ОстаетсяНомеров) AS ОстаетсяНомеров,
	|	MIN(SuitableAllotments.ОстаетсяМест) AS ОстаетсяМест
	|FROM
	|	SuitableAllotments AS SuitableAllotments
	|
	|GROUP BY
	|	SuitableAllotments.Гостиница,
	|	SuitableAllotments.ТипНомера,
	|	SuitableAllotments.RoomTypeSortCode,
	|	SuitableAllotments.КвотаНомеров,
	|	SuitableAllotments.RoomQuotaDescription,
	|	SuitableAllotments.RoomQuotaSortCode
	|
	|HAVING
	|	(MIN(SuitableAllotments.RoomsVacant) > 0
	|		OR MIN(SuitableAllotments.ОстаетсяНомеров) > 0) AND
	|	BEGINOFPERIOD(MIN(SuitableAllotments.CheckInDate), DAY) = BEGINOFPERIOD(&qPeriodFrom, DAY) AND
	|	BEGINOFPERIOD(MAX(SuitableAllotments.ДатаВыезда), DAY) = BEGINOFPERIOD(&qPeriodTo, DAY)
	|
	|ORDER BY
	|	RoomTypeSortCode,
	|	ОстаетсяНомеров DESC,
	|	RoomsVacant DESC,
	|	RoomQuotaSortCode,
	|	RoomQuotaDescription";
	vQry.SetParameter("qSuitableAllotments", pCheckInPeriods);
	vQry.SetParameter("qPeriodFrom", pCheckInDate);
	vQry.SetParameter("qPeriodTo", pCheckOutDate);
	Return vQry.Execute().Unload();
EndFunction //cmGetSuitableAllotments

//-----------------------------------------------------------------------------
// Description: Returns list of document resource reservations 
// Parameters: Parent document
// Return value: Value table with resource reservation references
//-----------------------------------------------------------------------------
Function cmGetChildResourceReservations(pDoc, pPostedOnly = False) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	БроньУслуг.Ref,
	|	БроньУслуг.Ресурс,
	|	БроньУслуг.ТипРесурса,
	|	БроньУслуг.DateTimeFrom,
	|	БроньУслуг.DateTimeTo
	|FROM
	|	Document.БроньУслуг AS БроньУслуг
	|WHERE
	|	БроньУслуг.ДокОснование = &qParentDoc
	|	AND (NOT &qPostedOnly
	|			OR &qPostedOnly
	|				AND БроньУслуг.Posted)
	|
	|ORDER BY
	|	БроньУслуг.ДатаДок,
	|	БроньУслуг.PointInTime";
	vQry.SetParameter("qParentDoc", pDoc);
	vQry.SetParameter("qPostedOnly", pPostedOnly);
	Return vQry.Execute().Unload();
EndFunction //cmGetChildResourceReservations

//-----------------------------------------------------------------------------
// Description: Completely deletes accommodations and reservations in the parameter value 
//              list from the database. All folios, charges and payments will be saved but folios
//              will be anonymized
// Parameters: Value list with references to documents to delete
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmDeleteAccommodationsLeavingCharges(pAccList) Экспорт
	// Build value list of parent and child documents that should be deleted
	vDocsList = New СписокЗначений();
	For Each vAccListItem In pAccList Do
		vCurAcc = vAccListItem.Value;
		vCurAccObj = vCurAcc.GetObject();
		vDocsList.Add(vCurAcc);
		vPrevDoc = vCurAcc;
		While ЗначениеЗаполнено(vPrevDoc.ДокОснование) Do
			If vDocsList.FindByValue(vPrevDoc.ДокОснование) = Неопределено Тогда
				vDocsList.Вставить(0, vPrevDoc.ДокОснование);
				vResResDocs = cmGetChildResourceReservations(vPrevDoc.ДокОснование);
				For Each vResResDocsRow In vResResDocs Do
					If vDocsList.FindByValue(vResResDocsRow.Ref) = Неопределено Тогда
						vDocsList.Add(vResResDocsRow.Ref);
					EndIf;
				EndDo;
			EndIf;
			vPrevDoc = vPrevDoc.ДокОснование;
		EndDo;
		vNextDoc = vCurAccObj.pmGetNextAccommodationInChain();
		While ЗначениеЗаполнено(vNextDoc) Do
			If vDocsList.FindByValue(vNextDoc) = Неопределено Тогда
				vDocsList.Add(vNextDoc);
				vResResDocs = cmGetChildResourceReservations(vNextDoc);
				For Each vResResDocsRow In vResResDocs Do
					If vDocsList.FindByValue(vResResDocsRow.Ref) = Неопределено Тогда
						vDocsList.Add(vResResDocsRow.Ref);
					EndIf;
				EndDo;
			EndIf;
			vNextDoc = vNextDoc.GetObject().pmGetNextAccommodationInChain();
		EndDo;
		vChildReservations = vCurAccObj.pmGetChildReservations();
		For Each vChildReservationsRow In vChildReservations Do
			If vDocsList.FindByValue(vChildReservationsRow.Бронирование) = Неопределено Тогда
				vDocsList.Add(vChildReservationsRow.Бронирование);
				vResResDocs = cmGetChildResourceReservations(vChildReservationsRow.Бронирование);
				For Each vResResDocsRow In vResResDocs Do
					If vDocsList.FindByValue(vResResDocsRow.Ref) = Неопределено Тогда
						vDocsList.Add(vResResDocsRow.Ref);
					EndIf;
				EndDo;
			EndIf;
		EndDo;
		vResResDocs = cmGetChildResourceReservations(vCurAcc);
		For Each vResResDocsRow In vResResDocs Do
			If vDocsList.FindByValue(vResResDocsRow.Ref) = Неопределено Тогда
				vDocsList.Add(vResResDocsRow.Ref);
			EndIf;
		EndDo;
	EndDo;
	
	// Try to find folios, preauthorizations, payments, returns, deposit transfers, charges, storno and charge transfers bound to this document
	For Each vDocsListItem In vDocsList Do
		vDocRef = vDocsListItem.Value;
		vDocObj = vDocRef.GetObject();
		
		// Find folios
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	СчетПроживания.Ref
		|FROM
		|	Document.СчетПроживания AS СчетПроживания
		|WHERE
		|	СчетПроживания.ДокОснование = &qParentDoc
		|
		|ORDER BY
		|	СчетПроживания.ДатаДок,
		|	СчетПроживания.PointInTime";
		vQry.SetParameter("qParentDoc", vDocRef);
		vDocFolios = vQry.Execute().Unload();
		For Each vDocFoliosRow In vDocFolios Do
			vDocFolio = vDocFoliosRow.Ref;
			vDocFolioObj = vDocFolio.GetObject();
			
			// Update folio
			vDocFolioObj.ДокОснование = Неопределено;
			vDocFolioObj.Клиент = Справочники.Clients.EmptyRef();
			vDocFolioObj.Write(DocumentWriteMode.Write);
			
			// Repost folio transactions
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	НачислениеУслуг.Ref AS Ref
			|FROM
			|	Document.Начисление AS НачислениеУслуг
			|WHERE
			|	НачислениеУслуг.СчетПроживания = &qFolio
			|
			|UNION ALL
			|
			|SELECT
			|	Сторно.Ref
			|FROM
			|	Document.Сторно AS Сторно
			|WHERE
			|	Сторно.ParentCharge.СчетПроживания = &qFolio
			|
			|UNION ALL
			|
			|SELECT
			|	ChargeTransfers.Ref
			|FROM
			|	Document.ПеремещениеНачисления AS ChargeTransfers
			|WHERE
			|	(ChargeTransfers.FolioFrom = &qFolio
			|			OR ChargeTransfers.FolioTo = &qFolio)
			|
			|UNION ALL
			|
			|SELECT
			|	DepositTransfers.Ref
			|FROM
			|	Document.ПеремещениеДепозита AS DepositTransfers
			|WHERE
			|	(DepositTransfers.FolioFrom = &qFolio
			|			OR DepositTransfers.FolioTo = &qFolio)
			|
			|UNION ALL
			|
			|SELECT
			|	Preauthorisations.Ref
			|FROM
			|	Document.ПреАвторизация AS Preauthorisations
			|WHERE
			|	Preauthorisations.СчетПроживания = &qFolio
			|
			|UNION ALL
			|
			|SELECT
			|	Платежи.Ref
			|FROM
			|	Document.Платеж AS Платежи
			|WHERE
			|	Платежи.СчетПроживания = &qFolio
			|
			|UNION ALL
			|
			|SELECT
			|	Returns.Ref
			|FROM
			|	Document.Возврат AS Returns
			|WHERE
			|	Returns.СчетПроживания = &qFolio
			|
			|UNION ALL
			|
			|SELECT
			|	ServiceRegistrations.Ref
			|FROM
			|	Document.РегистрацияУслуги AS ServiceRegistrations
			|WHERE
			|	ServiceRegistrations.СчетПроживания = &qFolio";
			vQry.SetParameter("qFolio", vDocFolio);
			vFolioDocs = vQry.Execute().Unload();
			For Each vFolioDocsRow In vFolioDocs Do
				vFolioDoc = vFolioDocsRow.Ref;
				vFolioDocObj = vFolioDoc.GetObject();
				If TypeOf(vFolioDoc) = Type("DocumentRef.Начисление") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
				ElsIf TypeOf(vFolioDoc) = Type("DocumentRef.Сторно") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
				ElsIf TypeOf(vFolioDoc) = Type("DocumentRef.ПеремещениеНачисления") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
				ElsIf TypeOf(vFolioDoc) = Type("DocumentRef.ПеремещениеДепозита") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
				ElsIf TypeOf(vFolioDoc) = Type("DocumentRef.ПреАвторизация") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
					vFolioDocObj.Payer = Неопределено;
				ElsIf TypeOf(vFolioDoc) = Type("DocumentRef.Платеж") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
					vFolioDocObj.Payer = Неопределено;
				ElsIf TypeOf(vFolioDoc) = Type("DocumentRef.Возврат") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
					vFolioDocObj.Payer = Неопределено;
				ElsIf TypeOf(vFolioDoc) = Type("DocumentRef.РегистрацияУслуги") Тогда
					vFolioDocObj.ДокОснование = Неопределено;
					vFolioDocObj.Клиент = Неопределено;
				EndIf;
				If vFolioDocObj.Posted Тогда
					vFolioDocObj.Write(DocumentWriteMode.Posting);
				Else
					vFolioDocObj.Write(DocumentWriteMode.Write);
				EndIf;
			EndDo;
		EndDo;
		
		// Update bound documents
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	НачислениеУслуг.Ref AS Ref
		|FROM
		|	Document.Начисление AS НачислениеУслуг
		|WHERE
		|	НачислениеУслуг.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	Сторно.Ref
		|FROM
		|	Document.Сторно AS Сторно
		|WHERE
		|	Сторно.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	ChargeTransfers.Ref
		|FROM
		|	Document.ПеремещениеНачисления AS ChargeTransfers
		|WHERE
		|	ChargeTransfers.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	DepositTransfers.Ref
		|FROM
		|	Document.ПеремещениеДепозита AS DepositTransfers
		|WHERE
		|	DepositTransfers.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	Preauthorisations.Ref
		|FROM
		|	Document.ПреАвторизация AS Preauthorisations
		|WHERE
		|	Preauthorisations.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	Платежи.Ref
		|FROM
		|	Document.Платеж AS Платежи
		|WHERE
		|	Платежи.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	Returns.Ref
		|FROM
		|	Document.Возврат AS Returns
		|WHERE
		|	Returns.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	RoomInterfaceStatuses.Ref
		|FROM
		|	Document.СтатусДопУслугиНомер AS RoomInterfaceStatuses
		|WHERE
		|	RoomInterfaceStatuses.ДокОснование = &qParentDoc
		|
		|UNION ALL
		|
		|SELECT
		|	ServiceRegistrations.Ref
		|FROM
		|	Document.РегистрацияУслуги AS ServiceRegistrations
		|WHERE
		|	ServiceRegistrations.ДокОснование = &qParentDoc";
		vQry.SetParameter("qParentDoc", vDocRef);
		vBoundDocs = vQry.Execute().Unload();
		For Each vBoundDocsRow In vBoundDocs Do
			vBoundDoc = vBoundDocsRow.Ref;
			vBoundDocObj = vBoundDoc.GetObject();
			If TypeOf(vBoundDoc) = Type("DocumentRef.Начисление") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.Сторно") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.ПеремещениеНачисления") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.ПеремещениеДепозита") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.ПреАвторизация") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
				vBoundDocObj.Payer = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.Платеж") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
				vBoundDocObj.Payer = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.Возврат") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
				vBoundDocObj.Payer = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.СтатусДопУслугиНомер") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
			ElsIf TypeOf(vBoundDoc) = Type("DocumentRef.РегистрацияУслуги") Тогда
				vBoundDocObj.ДокОснование = Неопределено;
				vBoundDocObj.Клиент = Неопределено;
			EndIf;
			If vBoundDocObj.Posted Тогда
				vBoundDocObj.Write(DocumentWriteMode.Posting);
			Else
				vBoundDocObj.Write(DocumentWriteMode.Write);
			EndIf;
			If TypeOf(vBoundDoc) = Type("DocumentRef.СтатусДопУслугиНомер") Тогда
				vBoundDocObj.Delete();
			EndIf;
		EndDo;
		
		// Clear document parent, charging rules and services
		vDocObj.ДокОснование = Неопределено;
		If TypeOf(vDocRef) = Type("DocumentRef.Размещение") Тогда
			vDocObj.Бронирование = Неопределено;
			vDocObj.ChargingRules.Clear();
			vDocObj.Услуги.Clear();
		ElsIf TypeOf(vDocRef) = Type("DocumentRef.Бронирование") Тогда
			vDocObj.ChargingRules.Clear();
			vDocObj.Услуги.Clear();
		ElsIf TypeOf(vDocRef) = Type("DocumentRef.БроньУслуг") Тогда
			vDocObj.Услуги.Clear();
		EndIf;
		vDocObj.Write(DocumentWriteMode.Write);
		
		// Delete client identification cards
		vIDCards = cmGetClientIdentificationCardsByParentDoc(vDocRef, True);
		For Each vIDCardsRow In vIDCards Do
			vIDCardsRow.Ref.GetObject().Delete();
		EndDo;
		
		// Update guest groups
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	GuestGroups.Ref
		|FROM
		|	Catalog.GuestGroups AS GuestGroups
		|WHERE
		|	GuestGroups.ClientDoc = &qParentDoc
		|
		|ORDER BY
		|	GuestGroups.Owner.Code,
		|	GuestGroups.Code";
		vQry.SetParameter("qParentDoc", vDocRef);
		vGuestGroups = vQry.Execute().Unload();
		For Each vGuestGroupsRow In vGuestGroups Do
			vGuestGroupObj = vGuestGroupsRow.Ref.GetObject();
			vGuestGroupObj.Клиент = Неопределено;
			vGuestGroupObj.ClientDoc = Неопределено;
			vGuestGroupObj.Write();
		EndDo;			
		
		// Update invoices
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	СчетНаОплату.Ref
		|FROM
		|	Document.СчетНаОплату AS СчетНаОплату
		|WHERE
		|	СчетНаОплату.ДокОснование = &qParentDoc
		|
		|ORDER BY
		|	СчетНаОплату.ДатаДок,
		|	СчетНаОплату.PointInTime";
		vQry.SetParameter("qParentDoc", vDocRef);
		vInvoices = vQry.Execute().Unload();
		For Each vInvoicesRow In vInvoices Do
			vInvoiceObj = vInvoicesRow.Ref.GetObject();
			vInvoiceObj.ДокОснование = Неопределено;
			If vInvoiceObj.Posted Тогда
				vInvoiceObj.Write(DocumentWriteMode.Posting);
			Else
				vInvoiceObj.Write(DocumentWriteMode.Write);
			EndIf;
		EndDo;			
		
		// Delete document client data scans
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ДанныеКлиента.Ref
		|FROM
		|	Document.ДанныеКлиента AS ДанныеКлиента
		|WHERE
		|	ДанныеКлиента.ДокОснование = &qParentDoc
		|
		|ORDER BY
		|	ДанныеКлиента.ДатаДок,
		|	ДанныеКлиента.PointInTime";
		vQry.SetParameter("qParentDoc", vDocRef);
		vDataScans = vQry.Execute().Unload();
		For Each vDataScansRow In vDataScans Do
			vDataScansRow.Ref.GetObject().Delete();
		EndDo;			
		
		// Delete foreigner registry records
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ForeignerRegistryRecord.Ref
		|FROM
		|	Document.ForeignerRegistryRecord AS ForeignerRegistryRecord
		|WHERE
		|	ForeignerRegistryRecord.ДокОснование = &qParentDoc
		|
		|ORDER BY
		|	ForeignerRegistryRecord.ДатаДок,
		|	ForeignerRegistryRecord.PointInTime";
		vQry.SetParameter("qParentDoc", vDocRef);
		vFRecs = vQry.Execute().Unload();
		For Each vFRecsRow In vFRecs Do
			vFRecsRow.Ref.GetObject().Delete();
		EndDo;			
		
		// Delete messages
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Задача.Ref
		|FROM
		|	Document.Задача AS Задача
		|WHERE
		|	(Задача.ДокОснование = &qParentDoc
		|			OR Задача.ByObject = &qParentDoc)
		|
		|ORDER BY
		|	Задача.ДатаДок,
		|	Задача.PointInTime";
		vQry.SetParameter("qParentDoc", vDocRef);
		vMessages = vQry.Execute().Unload();
		For Each vMessagesRow In vMessages Do
			vMessagesRow.Ref.GetObject().Delete();
		EndDo;			
		
		// Delete ГруппаНомеров interface statuses
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	СтатусДопУслугиНомер.Ref
		|FROM
		|	Document.СтатусДопУслугиНомер AS СтатусДопУслугиНомер
		|WHERE
		|	СтатусДопУслугиНомер.ДокОснование = &qParentDoc
		|
		|ORDER BY
		|	СтатусДопУслугиНомер.ДатаДок,
		|	СтатусДопУслугиНомер.PointInTime";
		vQry.SetParameter("qParentDoc", vDocRef);
		vRIStatuses = vQry.Execute().Unload();
		For Each vRIStatusesRow In vRIStatuses Do
			vRIStatusesRow.Ref.GetObject().Delete();
		EndDo;			
		
		// Clear document from operation schedules
		vQry = New Query();
		vQry.Text = 
		"SELECT DISTINCT
		|	OperationScheduleOperations.Ref
		|FROM
		|	Document.ПланРабот.Работы AS OperationScheduleOperations
		|WHERE
		|	OperationScheduleOperations.ДокОснование = &qParentDoc
		|
		|ORDER BY
		|	OperationScheduleOperations.Ref.ДатаДок";
		vQry.SetParameter("qParentDoc", vDocRef);
		vSchedules = vQry.Execute().Unload();
		For Each vSchedulesRow In vSchedules Do
			vScheduleObj = vSchedulesRow.Ref.GetObject();
			For Each vOprRow In vScheduleObj.Работы Do
				If vOprRow.ДокОснование = vDocRef Тогда
					vOprRow.ДокОснование = Неопределено;
				EndIf;
			EndDo;
			vScheduleObj.Write(DocumentWriteMode.Write);
		EndDo;			
		
		// Update and repost settlements
		vQry = New Query();
		vQry.Text = 
		"SELECT DISTINCT
		|	SettlementServices.Ref
		|FROM
		|	Document.Акт.Услуги AS SettlementServices
		|WHERE
		|	(SettlementServices.ДокОснование = &qParentDoc
		|			OR SettlementServices.Ref.ДокОснование = &qParentDoc)
		|
		|ORDER BY
		|	SettlementServices.Ref.ДатаДок,
		|	SettlementServices.Ref.PointInTime";
		vQry.SetParameter("qParentDoc", vDocRef);
		vSettlements = vQry.Execute().Unload();
		For Each vSettlementsRow In vSettlements Do
			vSettlementObj = vSettlementsRow.Ref.GetObject();
			If vSettlementObj.ДокОснование = vDocRef Тогда
				vSettlementObj.ДокОснование = Неопределено;
			EndIf;
			For Each vSrvRow In vSettlementObj.Услуги Do
				If vSrvRow.ДокОснование = vDocRef Тогда
					vSrvRow.Клиент = Неопределено;
					vSrvRow.ДокОснование = Неопределено;
				EndIf;
			EndDo;
			If vSettlementObj.Posted Тогда
				vSettlementObj.Write(DocumentWriteMode.Posting);
			Else
				vSettlementObj.Write(DocumentWriteMode.Write);
			EndIf;
		EndDo;			
		
		// Set deletion mark to the document
		If НЕ vDocRef.DeletionMark Тогда
			vDocObj.SetDeletionMark(True);
		EndIf;
		
		// Clear document change history
		vMgr = Неопределено;
		vDimensionName = "";
		If TypeOf(vDocRef) = Type("DocumentRef.Размещение") Тогда
			vDimensionName = "Размещение";
			vMgr = InformationRegisters.ИсторияИзмененийРазмещения;
		ElsIf TypeOf(vDocRef) = Type("DocumentRef.Бронирование") Тогда
			vDimensionName = "Бронирование";
			vMgr = InformationRegisters.ИсторияБрони;
		ElsIf TypeOf(vDocRef) = Type("DocumentRef.БроньУслуг") Тогда
			vDimensionName = "БроньУслуг";
			vMgr = InformationRegisters.ИсторияИзмБрониРесурсов;
		EndIf;
		If vMgr <> Неопределено Тогда
			vSel = vMgr.Select(,, New Structure(vDimensionName, vDocRef));
			While vSel.Next() Do
				vRecMgr = vSel.GetRecordManager();
				vRecMgr.Delete();
			EndDo;
		EndIf;
		
		// Clear safety system events
		vSSERcdMgr = InformationRegisters.SafetySystemEvents.CreateRecordManager();
		vSSEQry = New Query();
		vSSEQry.Text = 
		"SELECT
		|	SafetySystemEvents.Period AS Period,
		|	SafetySystemEvents.НомерРазмещения,
		|	SafetySystemEvents.EventType,
		|	SafetySystemEvents.Гостиница,
		|	SafetySystemEvents.ДокОснование
		|FROM
		|	InformationRegister.SafetySystemEvents AS SafetySystemEvents
		|WHERE
		|	SafetySystemEvents.ДокОснование = &qParentDoc
		|
		|ORDER BY
		|	Period";
		vSSEQry.SetParameter("qParentDoc", vDocRef);
		vSSEvents = vSSEQry.Execute().Unload();
		For Each vSSEventsRow In vSSEvents Do
			vSSERcdMgr.Period = vSSEventsRow.Period;
			vSSERcdMgr.НомерРазмещения = vSSEventsRow.ГруппаНомеров;
			vSSERcdMgr.EventType = vSSEventsRow.EventType;
			vSSERcdMgr.Гостиница = vSSEventsRow.Гостиница;
			vSSERcdMgr.Read();
			If vSSERcdMgr.Selected() Тогда
				vSSERcdMgr.Delete();
			EndIf;
		EndDo;
		
		// Clear ГруппаНомеров status change history
		vRSCHRcdMgr = InformationRegisters.ИзмСтатусовНомеров.CreateRecordManager();
		vRSCHQry = New Query();
		vRSCHQry.Text = 
		"SELECT
		|	ИсторияИзмСтатусаНомеров.Period,
		|	ИсторияИзмСтатусаНомеров.НомерРазмещения,
		|	ИсторияИзмСтатусаНомеров.СтатусНомера,
		|	ИсторияИзмСтатусаНомеров.Примечания,
		|	ИсторияИзмСтатусаНомеров.User
		|FROM
		|	InformationRegister.ИсторияИзмСтатусаНомеров AS ИсторияИзмСтатусаНомеров
		|WHERE
		|	ИсторияИзмСтатусаНомеров.Примечания LIKE &qRemarks
		|
		|ORDER BY
		|	ИсторияИзмСтатусаНомеров.НомерРазмещения.ПорядокСортировки,
		|	ИсторияИзмСтатусаНомеров.Period";
		vRSCHQry.SetParameter("qRemarks", "%" + String(vDocRef) + "%");
		vRSCHEvents = vRSCHQry.Execute().Unload();
		For Each vRSCHEventsRow In vRSCHEvents Do
			vRSCHRcdMgr.Period = vRSCHEventsRow.Period;
			vRSCHRcdMgr.НомерРазмещения = vRSCHEventsRow.ГруппаНомеров;
			vRSCHRcdMgr.Read();
			If vRSCHRcdMgr.Selected() Тогда
				vRSCHRcdMgr.Delete();
			EndIf;
		EndDo;
	EndDo;
		
	// Check references and delete document completely
	For Each vDocsListItem In vDocsList Do
		vDocRef = vDocsListItem.Value;
		vDocObj = vDocRef.GetObject();
		
		// Check references to the document
		vDocsArray = New Array();
		vDocsArray.Add(vDocRef);
		vRefsTab = FindByRef(vDocsArray);
		If vRefsTab.Count() > 0 Тогда
			vMessage = "Найдены ссылки, которые не могут быть автоматически обработаны!";
			For Each vRefsTabRow In vRefsTab Do
				vMessage = vMessage + Chars.LF + СокрЛП(vRefsTabRow[0]) + " - " + СокрЛП(vRefsTabRow[1]);
			EndDo;
			ВызватьИсключение vMessage;
		EndIf;
		
		// Delete document completely from the database
		vDocObj.Delete();
	EndDo;
		
	// Clear employee actions history
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Employees.Ref
	|FROM
	|	Catalog.Employees AS Employees
	|WHERE
	|	NOT Employees.IsFolder
	|
	|ORDER BY
	|	Employees.Code";
	vEmployees = vQry.Execute().Unload();
	For Each vEmployeesRow In vEmployees Do
		vEmployeeObj = vEmployeesRow.Ref.GetObject();
		vEmployeeObj.ПослИсполОбъекты = Неопределено;
		vEmployeeObj.Write();
	EndDo;
КонецПроцедуры //cmDeleteAccommodationsLeavingCharges

//-----------------------------------------------------------------------------
// Description: Returns reservation that could be used as parent for the current one
// Parameters: Guest group ref where to search for, check-in date of the current reservation, accommodation type of the current reservation
// Return value: Reservation document reference or undefined
//-----------------------------------------------------------------------------
Function cmGetPreviousReservation(pGuestGroup, pCheckInDate, pAccommodationType, pParentDocsList = Неопределено, pGuest = Неопределено) Экспорт
	If pParentDocsList = Неопределено Тогда
		pParentDocsList = New СписокЗначений();
	EndIf;
	vReservation = Неопределено;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	UsedReservations.ДокОснование AS Ref
	|INTO UsedReservations
	|FROM
	|	Document.Бронирование AS UsedReservations
	|WHERE
	|	UsedReservations.ДокОснование <> &qUndefined
	|	AND UsedReservations.Posted
	|	AND (UsedReservations.ReservationStatus.IsActive
	|			OR UsedReservations.ReservationStatus.ЭтоЗаезд)
	|	AND UsedReservations.ГруппаГостей = &qGuestGroup
	|	AND UsedReservations.ВидРазмещения = &qAccommodationType
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Бронирование.Ref
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.Posted
	|	AND (Бронирование.ReservationStatus.IsActive
	|			OR Бронирование.ReservationStatus.ЭтоЗаезд)
	|	AND Бронирование.ГруппаГостей = &qGuestGroup
	|	AND (NOT &qDoNotCheckGuest
	|			OR &qDoNotCheckGuest
	|				AND Бронирование.ВидРазмещения = &qAccommodationType)
	|	AND (Бронирование.GuestFullName = &qGuestFullName
	|			OR Бронирование.Клиент = &qGuest
	|			OR &qDoNotCheckGuest)
	|	AND BEGINOFPERIOD(Бронирование.ДатаВыезда, DAY) = &qDate
	|	AND Бронирование.CheckInDate < &qCheckInDate
	|	AND (NOT &qDoNotCheckGuest
	|			OR &qDoNotCheckGuest
	|				AND NOT Бронирование.Ref IN
	|						(SELECT
	|							UsedReservations.Ref
	|						FROM
	|							UsedReservations AS UsedReservations))
	|	AND NOT Бронирование.Ref IN (&qParentDocsList)
	|
	|ORDER BY
	|	Бронирование.ДатаДок,
	|	Бронирование.PointInTime";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qDate", BegOfDay(pCheckInDate));
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qAccommodationType", pAccommodationType);
	vQry.SetParameter("qUndefined", Неопределено);
	vQry.SetParameter("qParentDocsList", pParentDocsList);
	vQry.SetParameter("qGuestFullName", ?(ЗначениеЗаполнено(pGuest), TrimR(pGuest.FullName), ""));
	vQry.SetParameter("qGuest", pGuest);
	vQry.SetParameter("qDoNotCheckGuest", НЕ ЗначениеЗаполнено(pGuest));
	vReservations = vQry.Execute().Unload();
	If vReservations.Count() > 0 Тогда
		vReservationsRow = vReservations.Get(0);
		vReservation = vReservationsRow.Ref;
	EndIf;
	Return vReservation;
EndFunction //cmGetPreviousReservation

//-----------------------------------------------------------------------------
// Description: Returns reservation that is next in guest reservation chain
// Parameters: Guest group ref where to search for, check-out date of the current reservation, accommodation type of the current reservation, Guest of the current reservation
// Return value: Reservation document reference or undefined
//-----------------------------------------------------------------------------
Function cmGetNextReservation(pGuestGroup, pCheckOutDate, pAccommodationType, pGuest = Неопределено) Экспорт
	vReservation = Неопределено;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Бронирование.Ref
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.Posted
	|	AND (Бронирование.ReservationStatus.IsActive
	|			OR Бронирование.ReservationStatus.ЭтоЗаезд)
	|	AND Бронирование.ГруппаГостей = &qGuestGroup
	|	AND (NOT &qDoNotCheckGuest
	|			OR &qDoNotCheckGuest
	|				AND Бронирование.ВидРазмещения = &qAccommodationType)
	|	AND (Бронирование.GuestFullName = &qGuestFullName
	|			OR Бронирование.Клиент = &qGuest
	|			OR &qDoNotCheckGuest)
	|	AND BEGINOFPERIOD(Бронирование.CheckInDate, DAY) = &qDate
	|	AND Бронирование.ДатаВыезда > &qCheckOutDate
	|
	|ORDER BY
	|	Бронирование.ДатаДок,
	|	Бронирование.PointInTime";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qDate", BegOfDay(pCheckOutDate));
	vQry.SetParameter("qCheckOutDate", pCheckOutDate);
	vQry.SetParameter("qAccommodationType", pAccommodationType);
	vQry.SetParameter("qGuestFullName", ?(ЗначениеЗаполнено(pGuest), TrimR(pGuest.FullName), ""));
	vQry.SetParameter("qGuest", pGuest);
	vQry.SetParameter("qDoNotCheckGuest", НЕ ЗначениеЗаполнено(pGuest));
	vReservations = vQry.Execute().Unload();
	If vReservations.Count() > 0 Тогда
		vReservationsRow = vReservations.Get(0);
		vReservation = vReservationsRow.Ref;
	EndIf;
	Return vReservation;
EndFunction //cmGetNextReservation

//-----------------------------------------------------------------------------
// Description: Returns accommodation that could be used as parent for the current one
// Parameters: Guest group ref where to search for, check-in date of the current accommodation, accommodation type of the current accommodation
// Return value: Accommodation document reference or undefined
//-----------------------------------------------------------------------------
Function cmGetPreviousAccommodation(pGuestGroup, pCheckInDate, pAccommodationType, pParentDocsList = Неопределено, pGuest = Неопределено) Экспорт
	If pParentDocsList = Неопределено Тогда
		pParentDocsList = New СписокЗначений();
	EndIf;
	vAccommodation = Неопределено;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	UsedAccommodations.ДокОснование AS Ref
	|INTO UsedAccommodations
	|FROM
	|	Document.Размещение AS UsedAccommodations
	|WHERE
	|	UsedAccommodations.ДокОснование <> &qUndefined
	|	AND UsedAccommodations.Posted
	|	AND UsedAccommodations.СтатусРазмещения.IsActive
	|	AND UsedAccommodations.ГруппаГостей = &qGuestGroup
	|	AND UsedAccommodations.ВидРазмещения = &qAccommodationType
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Posted
	|	AND Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.ГруппаГостей = &qGuestGroup
	|	AND (NOT &qDoNotCheckGuest
	|			OR &qDoNotCheckGuest
	|				AND Размещение.ВидРазмещения = &qAccommodationType)
	|	AND (Размещение.GuestFullName = &qGuestFullName
	|			OR Размещение.Клиент = &qGuest
	|			OR &qDoNotCheckGuest)
	|	AND BEGINOFPERIOD(Размещение.ДатаВыезда, DAY) = &qDate
	|	AND Размещение.CheckInDate < &qCheckInDate
	|	AND (NOT &qDoNotCheckGuest
	|			OR &qDoNotCheckGuest
	|				AND NOT Размещение.Ref IN
	|						(SELECT
	|							UsedAccommodations.Ref
	|						FROM
	|							UsedAccommodations AS UsedAccommodations))
	|	AND NOT Размещение.Ref IN (&qParentDocsList)
	|
	|ORDER BY
	|	Размещение.ДатаДок,
	|	Размещение.PointInTime";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qDate", BegOfDay(pCheckInDate));
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qAccommodationType", pAccommodationType);
	vQry.SetParameter("qUndefined", Неопределено);
	vQry.SetParameter("qGuest", pGuest);
	vQry.SetParameter("qGuestFullName", ?(ЗначениеЗаполнено(pGuest), TrimR(pGuest.FullName), ""));
	vQry.SetParameter("qDoNotCheckGuest", НЕ ЗначениеЗаполнено(pGuest));
	vQry.SetParameter("qParentDocsList", pParentDocsList);
	vAccommodations = vQry.Execute().Unload();
	If vAccommodations.Count() > 0 Тогда
		vAccommodationsRow = vAccommodations.Get(0);
		vAccommodation = vAccommodationsRow.Ref;
	EndIf;
	Return vAccommodation;
EndFunction //cmGetPreviousAccommodation

//-----------------------------------------------------------------------------
// Description: Returns accommodation that is next in guest accommodation chain
// Parameters: Guest group ref where to search for, check-out date of the current accommodation, accommodation type of the current accommodation, Guest of the current accommodation
// Return value: Accommodation document reference or undefined
//-----------------------------------------------------------------------------
Function cmGetNextAccommodation(pGuestGroup, pCheckOutDate, pAccommodationType, pGuest = Неопределено) Экспорт
	vAccommodation = Неопределено;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Posted
	|	AND Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.ГруппаГостей = &qGuestGroup
	|	AND (NOT &qDoNotCheckGuest
	|			OR &qDoNotCheckGuest
	|				AND Размещение.ВидРазмещения = &qAccommodationType)
	|	AND (Размещение.GuestFullName = &qGuestFullName
	|			OR Размещение.Клиент = &qGuest
	|			OR &qDoNotCheckGuest)
	|	AND BEGINOFPERIOD(Размещение.CheckInDate, DAY) = &qDate
	|	AND Размещение.ДатаВыезда > &qCheckOutDate
	|
	|ORDER BY
	|	Размещение.ДатаДок,
	|	Размещение.PointInTime";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQry.SetParameter("qDate", BegOfDay(pCheckOutDate));
	vQry.SetParameter("qCheckOutDate", pCheckOutDate);
	vQry.SetParameter("qAccommodationType", pAccommodationType);
	vQry.SetParameter("qGuest", pGuest);
	vQry.SetParameter("qGuestFullName", ?(ЗначениеЗаполнено(pGuest), TrimR(pGuest.FullName), ""));
	vQry.SetParameter("qDoNotCheckGuest", НЕ ЗначениеЗаполнено(pGuest));
	vAccommodations = vQry.Execute().Unload();
	If vAccommodations.Count() > 0 Тогда
		vAccommodationsRow = vAccommodations.Get(0);
		vAccommodation = vAccommodationsRow.Ref;
	EndIf;
	Return vAccommodation;
EndFunction //cmGetNextAccommodation

//-----------------------------------------------------------------------------
// Description: Fills document (reservation or accommodation) attributes from the parent document
// Parameters: Document object to update, Refrence to the parent document
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmFillAttributesFromParentDocument(pDocObj, pParentDoc, pDoNotFillGuest = False) Экспорт
	If pDocObj.Ref = pParentDoc Тогда
		Return;
	EndIf;
	If НЕ pDoNotFillGuest Тогда
		pDocObj.Клиент = pParentDoc.Клиент;
		pDocObj.GuestFullName = pParentDoc.GuestFullName;
		pDocObj.Car = pParentDoc.Car;
		pDocObj.Примечания = pParentDoc.Примечания;
	EndIf;
	pDocObj.Контрагент = pParentDoc.Контрагент;
	pDocObj.ТипКонтрагента = pParentDoc.ТипКонтрагента;
	pDocObj.Договор = pParentDoc.Договор;
	pDocObj.Агент = pParentDoc.Агент;
	pDocObj.ВидКомиссииАгента = pParentDoc.ВидКомиссииАгента;
	pDocObj.КомиссияАгента = pParentDoc.КомиссияАгента;
	pDocObj.КомиссияАгентУслуги = pParentDoc.КомиссияАгентУслуги;
	pDocObj.КонтактноеЛицо = pParentDoc.КонтактноеЛицо;
	pDocObj.Телефон = pParentDoc.Телефон;
	pDocObj.Fax = pParentDoc.Fax;
	pDocObj.EMail = pParentDoc.EMail;
	pDocObj.PlannedPaymentMethod = pParentDoc.PlannedPaymentMethod;
	pDocObj.ТипКлиента = pParentDoc.ТипКлиента;
	pDocObj.СтрокаПодтверждения = pParentDoc.СтрокаПодтверждения;
	pDocObj.TripPurpose = pParentDoc.TripPurpose;
	pDocObj.МаркетингКод = pParentDoc.МаркетингКод;
	pDocObj.MarketingCodeConfirmationText = pParentDoc.MarketingCodeConfirmationText;
	pDocObj.ИсточникИнфоГостиница = pParentDoc.ИсточникИнфоГостиница;
	pDocObj.RoomRateServiceGroup = pParentDoc.RoomRateServiceGroup;
	pDocObj.ServicePackage = pParentDoc.ServicePackage;
	pDocObj.Фирма = pParentDoc.Фирма;
	pDocObj.ТипСкидки = pParentDoc.ТипСкидки;
	pDocObj.Скидка = pParentDoc.Скидка;
	pDocObj.СуммаСкидки = pParentDoc.СуммаСкидки;
	pDocObj.ДисконтКарт = pParentDoc.ДисконтКарт;
	pDocObj.DiscountServiceGroup = pParentDoc.DiscountServiceGroup;
	pDocObj.ОснованиеСкидки = pParentDoc.ОснованиеСкидки;
	pDocObj.TurnOffAutomaticDiscounts = pParentDoc.TurnOffAutomaticDiscounts;
	pDocObj.CreditCard = pParentDoc.CreditCard;
	pDocObj.НеПечататьТариф = pParentDoc.НеПечататьТариф;
	pDocObj.ДокОснование = pParentDoc;
	pDocObj.ChargingRules.Load(pParentDoc.ChargingRules.Unload());
	pDocObj.ПакетыУслуг.Load(pParentDoc.ПакетыУслуг.Unload());
КонецПроцедуры //cmFillAttributesFromParentDocument

//-----------------------------------------------------------------------------
// Description: Returns value table with active guest group documents
// Parameters: Refrence to the guest group item
// Return value: Value table with document references
//-----------------------------------------------------------------------------
Function cmGetActiveGuestGroupDocuments(pGuestGroup) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Бронирование.Ref,
	|	Бронирование.PointInTime AS PointInTime,
	|	Бронирование.ДатаДок AS Date
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	(Бронирование.ReservationStatus.IsActive
	|			OR Бронирование.ReservationStatus.IsPreliminary)
	|	AND Бронирование.Posted
	|	AND Бронирование.ГруппаГостей = &qGuestGroup
	|
	|UNION ALL
	|
	|SELECT
	|	БроньУслуг.Ref,
	|	БроньУслуг.PointInTime,
	|	БроньУслуг.ДатаДок
	|FROM
	|	Document.БроньУслуг AS БроньУслуг
	|WHERE
	|	БроньУслуг.ResourceReservationStatus.IsActive
	|	AND БроньУслуг.Posted
	|	AND БроньУслуг.ГруппаГостей = &qGuestGroup
	|
	|UNION ALL
	|
	|SELECT
	|	Размещение.Ref,
	|	Размещение.PointInTime,
	|	Размещение.ДатаДок
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.СтатусРазмещения.ЭтоГости
	|	AND Размещение.Posted
	|	AND Размещение.ГруппаГостей = &qGuestGroup
	|
	|ORDER BY
	|	Date,
	|	PointInTime";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vDocs = vQry.Execute().Unload();
	Return vDocs;
EndFunction //cmGetActiveGuestGroupDocuments 

//-----------------------------------------------------------------------------
// Description: Returns hash code used to sort documents
// Parameters: Document (accommodation or reservation) object
// Return value: Number used as sort code
//-----------------------------------------------------------------------------
Function cmCalculateReservationSortCode(pObj) Экспорт
	// Гостиница
	vHotelSortCode = "0000"; //4
	If ЗначениеЗаполнено(pObj.Гостиница) Тогда
		vHotelSortCode = Format(pObj.Гостиница.ПорядокСортировки, "ND=4; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	// Guest group
	vGroupSortCode = "000000000000"; //12
	If ЗначениеЗаполнено(pObj.ГруппаГостей) Тогда
		vGroupSortCode = Format(pObj.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	// ГруппаНомеров
	vRoomSortCode = "00000000"; //8
	If ЗначениеЗаполнено(pObj.НомерРазмещения) Тогда
		vRoomSortCode = Format(pObj.НомерРазмещения.ПорядокСортировки, "ND=8; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	// ГруппаНомеров type
	vRoomTypeSortCode = "00000000"; //8
	If ЗначениеЗаполнено(pObj.ТипНомера) Тогда
		vRoomTypeSortCode = Format(pObj.ТипНомера.ПорядокСортировки, "ND=8; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	// Number
	vDocNumberSortCode = "000000000000"; //12
	If НЕ IsBlankString(pObj.НомерДока) Тогда
		vDocNumber = 0;
		Try
			vDocNumber = Number(cmGetDocumentNumberPresentation(pObj.НомерДока));
		Except
		EndTry;
		vDocNumberSortCode = Format(vDocNumber, "ND=12; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	// Check in date
	vCheckInDateSortCode = "000000000000"; //12
	If ЗначениеЗаполнено(pObj.CheckInDate) Тогда
		vCheckInDateSortCode = Format(Year(pObj.CheckInDate)*10000000 + DayOfYear(pObj.CheckInDate)*10000 + Int((pObj.CheckInDate - BegOfDay(pObj.CheckInDate))/60), "ND=12; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	// Accommodation type
	vAccommodationTypeSortCode = "0000"; //4
	If ЗначениеЗаполнено(pObj.ВидРазмещения) Тогда
		vAccommodationTypeSortCode = Format(pObj.ВидРазмещения.ПорядокСортировки, "ND=4; NFD=0; NZ=; NLZ=; NG=");
	EndIf;
	// Build sort code as 60 chars hash
	vSortCode = vHotelSortCode + vGroupSortCode + vRoomSortCode + vRoomTypeSortCode + vDocNumberSortCode + vCheckInDateSortCode + vAccommodationTypeSortCode;
	Return vSortCode;
EndFunction //cmCalculateReservationSortCode

//-----------------------------------------------------------------------------
// Description: Function returns date to be used as default check-out date for accommodation
// Parameters: Document (accommodation or reservation) reference
// Return value: Check-out date
//-----------------------------------------------------------------------------
Function cmGetLastCheckOutDateInChain(pDocRef, pIgnoreRoomTypeChange = False) Экспорт
	vCheckOutDate = pDocRef.ДатаВыезда;
	If TypeOf(pDocRef) = Type("DocumentObject.Размещение") Тогда
		//vDocObj = pDocRef;
		vDocRef = pDocRef.Ref;
	Else
		//vDocObj = pDocRef.GetObject();
		vDocRef = pDocRef;
	EndIf;
	If TypeOf(vDocRef) = Type("DocumentRef.Размещение") Тогда
		//vParentReservation = vDocObj.pmGetParentReservation();
	Else
		vParentReservation = vDocRef;
	EndIf;
	If ЗначениеЗаполнено(vParentReservation) Тогда
		vParentReservationObj = vParentReservation.GetObject();
		vNextReservationInChain = vParentReservationObj.pmGetNextReservationInChain();
		While ЗначениеЗаполнено(vNextReservationInChain) Do
			If (vNextReservationInChain.ТипНомера = vDocRef.ТипНомера And НЕ pIgnoreRoomTypeChange) Or pIgnoreRoomTypeChange Тогда
				If vNextReservationInChain.ДатаВыезда > vCheckOutDate Тогда
					vCheckOutDate = vNextReservationInChain.ДатаВыезда;
				EndIf;
			Else
				Break;   
			EndIf;
			vNextReservationInChain = vNextReservationInChain.GetObject().pmGetNextReservationInChain();
		EndDo;
	EndIf;
	Return vCheckOutDate;
EndFunction //cmGetLastCheckOutDateInChain

//-----------------------------------------------------------------------------
// Description: Function returns reservation conditions for the given document
// Parameters: Document (accommodation or reservation) object
// Return value: String. Reservation conditions
//-----------------------------------------------------------------------------
Function cmGetReservationConditions(pDocObj, pLanguage) Экспорт
	vResCond = "";
	If (TypeOf(pDocObj) = Type("DocumentObject.Бронирование") Or TypeOf(pDocObj) = Type("DocumentObject.Размещение")) And ЗначениеЗаполнено(pDocObj.Тариф) Тогда
		If НЕ IsBlankString(pDocObj.Тариф.ReservationConditions) Тогда
			//vResCond = cmNStpDocObj.RoomRate.ReservationConditions;
		EndIf;
	ElsIf ЗначениеЗаполнено(pDocObj.Гостиница) Тогда
		If НЕ IsBlankString(pDocObj.Гостиница.ReservationConditions) Тогда
			vResCond =pDocObj.Гостиница.ReservationConditions;
		EndIf;
	EndIf;
	If TypeOf(pDocObj) = Type("DocumentObject.Бронирование") Тогда
		If ЗначениеЗаполнено(pDocObj.ReservationStatus) And НЕ IsBlankString(pDocObj.ReservationStatus.ReservationConditions) Тогда
			vResCond = vResCond + Chars.LF + pDocObj.ReservationStatus.ReservationConditions;
		EndIf;
	EndIf;
	Return vResCond;
EndFunction //cmGetReservationConditions

//-----------------------------------------------------------------------------
// Description: Stores information about key card being issued
// Parameters: Card type as string (New - new card, Add - additional card), 
//             ГруппаНомеров item reference, Card issue period, 
//             Accommodation or Reservation referece, Guest item reference
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmWriteKeyCardSecuritySystemEvent(pCardType, pCardCode, pRoom, pEventDescription, pPeriodFrom, pPeriodTo, pDoc, pGuest, pNumberOfKeys = 1) Экспорт
	vRecMgr = InformationRegisters.SafetySystemEvents.CreateRecordManager();
	If pCardType <> "CANCEL" Тогда
		// Update IsActive flag if new key card is being issued
		If Upper(pCardType) = "NEW" Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	SafetySystemEvents.Period AS Period,
			|	SafetySystemEvents.НомерРазмещения,
			|	SafetySystemEvents.EventType,
			|	SafetySystemEvents.Гостиница
			|FROM
			|	InformationRegister.SafetySystemEvents AS SafetySystemEvents
			|WHERE
			|	SafetySystemEvents.НомерРазмещения = &qRoom
			|	AND SafetySystemEvents.EventType = &qEventType
			|	AND SafetySystemEvents.Гостиница = &qHotel
			|	AND SafetySystemEvents.IsActive
			|
			|ORDER BY
			|	Period";
			vQry.SetParameter("qHotel", pRoom.Owner);
			vQry.SetParameter("qRoom", pRoom);
			vQry.SetParameter("qEventType", "IssueKeyCard");
			vActiveRows = vQry.Execute().Choose();
			While vActiveRows.Next() Do
				vRecMgr.Period = vActiveRows.Period;
				vRecMgr.НомерРазмещения = vActiveRows.НомерРазмещения;
				vRecMgr.EventType = vActiveRows.EventType;
				vRecMgr.Гостиница = vActiveRows.Гостиница;
				vRecMgr.Read();
				If vRecMgr.Selected() Тогда
					vRecMgr.IsActive = False;
					vRecMgr.Write();
				EndIf;
			EndDo;
		EndIf;
		// Write record to the information register
		vRecMgr = InformationRegisters.SafetySystemEvents.CreateRecordManager();
		vRecMgr.Period = CurrentDate();
		vRecMgr.Автор = ПараметрыСеанса.ТекПользователь;
		vRecMgr.Гостиница = pRoom.Owner;
		vRecMgr.НомерРазмещения = pRoom;
		vRecMgr.EventType = "IssueKeyCard";
		vRecMgr.CardType = Upper(pCardType);
		vRecMgr.CardCode = pCardCode;
		vRecMgr.EventDescription = pEventDescription;
		vRecMgr.IsActive = True;
		vRecMgr.Клиент = pGuest;
		vRecMgr.ДокОснование = pDoc;
		vRecMgr.ПериодС = pPeriodFrom;
		vRecMgr.ПериодПо = pPeriodTo;
		vRecMgr.NumberOfKeys = pNumberOfKeys;
		vRecMgr.Write();
	Else
		// Cancel all previously issued active cards
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	SafetySystemEvents.Period AS Period,
		|	SafetySystemEvents.НомерРазмещения,
		|	SafetySystemEvents.EventType,
		|	SafetySystemEvents.Гостиница,
		|	SafetySystemEvents.IsActive
		|FROM
		|	InformationRegister.SafetySystemEvents AS SafetySystemEvents
		|WHERE
		|	SafetySystemEvents.НомерРазмещения = &qRoom
		|	AND SafetySystemEvents.Гостиница = &qHotel
		|	AND SafetySystemEvents.IsActive
		|
		|ORDER BY
		|	Period";
		vQry.SetParameter("qHotel", pRoom.Owner);
		vQry.SetParameter("qRoom", pRoom);
		vActiveRows = vQry.Execute().Choose();
		While vActiveRows.Next() Do
			vRecMgr.Period = vActiveRows.Period;
			vRecMgr.НомерРазмещения = vActiveRows.НомерРазмещения;
			vRecMgr.EventType = vActiveRows.EventType;
			vRecMgr.Гостиница = vActiveRows.Гостиница;
			vRecMgr.Read();
			If vRecMgr.Selected() Тогда
				If vRecMgr.ПериодС < CurrentDate() And vRecMgr.ПериодПо > CurrentDate() Тогда
					vRecMgr.ПериодПо = CurrentDate();
				EndIf;
				vRecMgr.IsActive = False;
				vRecMgr.Write();
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //cmWriteKeyCardSecuritySystemEvent

//-----------------------------------------------------------------------------
// Description: This function checks character if it is valid e-mail character
// Parameters: Character
// Return value: contact person e-mail as string
//-----------------------------------------------------------------------------
Function cmIsValidEMailChar(pChar) Экспорт
	vValidChars = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890._~!#$%&?*+-=^";
	If Find(vValidChars, pChar) > 0 Тогда
		Return True;
	Else
		Return False;
	EndIf;
EndFunction //cmIsValidEMailChar

//-----------------------------------------------------------------------------
// Description: This function extracts e-mail from the contact person data
// Parameters: Contact person data as string
// Return value: contact person e-mail as string
//-----------------------------------------------------------------------------
Function cmGetContactPersonEMail(pContactPerson) Экспорт
	vEMail = "";
	vContactPerson = СокрЛП(pContactPerson);
	vAtPos = Find(vContactPerson, "@");
	If vAtPos > 1 Тогда
		vStart = 1;
		i = vAtPos - 1;
		While i > 0 Do
			vChar = Mid(vContactPerson, i, 1);
			If НЕ cmIsValidEMailChar(vChar) Тогда
				vStart = i + 1;
				Break;
			Else
				vStart = i;
			EndIf;
			i = i - 1;
		EndDo;
		vEnd = vAtPos + 1;
		i = vAtPos + 1;
		While i <= StrLen(vContactPerson) Do
			vChar = Mid(pContactPerson, i, 1);
			If НЕ cmIsValidEMailChar(vChar) Тогда
				vEnd = i - 1;
				Break;
			Else
				vEnd = i;
			EndIf;
			i = i + 1;
		EndDo;
		vLen = vEnd - vStart + 1;
		vEMail = Mid(vContactPerson, vStart, vLen);
	EndIf;
	Return vEMail;
EndFunction //cmGetContactPersonEMail

//-----------------------------------------------------------------------------
// Description: Returns icon of the given ГруппаНомеров status
// Parameters: ГруппаНомеров status 
// Return value: Picture object
//-----------------------------------------------------------------------------
Function cmGetRoomStatusIcon(pRoomStatus) Экспорт
	vPicture = PictureLib.Empty;
	If ЗначениеЗаполнено(pRoomStatus) Тогда
		If ЗначениеЗаполнено(pRoomStatus.RoomStatusIcon) Тогда
			If pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Occupied Тогда
				vPicture = PictureLib.Occupied;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Reserved Тогда
				vPicture = PictureLib.Reserved;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Waiting Тогда
				vPicture = PictureLib.Waiting;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.TidyingUp Тогда
				vPicture = PictureLib.TidyingUp;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.ВыездФакт Тогда
				vPicture = PictureLib.ВыездФакт;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Vacant Тогда
				vPicture = PictureLib.Vacant;
			EndIf;
		EndIf;
	EndIf;
	Return vPicture;
EndFunction //cmGetRoomStatusIcon

//-----------------------------------------------------------------------------
// Description: Returns default accommodation type for the given ГруппаНомеров type and hotel
// Parameters: Гостиница item reference, ГруппаНомеров type item reference  
// Return value: Accommodation type reference
//-----------------------------------------------------------------------------
Function cmGetDefaultAccommodationType(pHotel, pRoomType) Экспорт
	vAccommodationType = Справочники.СтатусРазмещения.ПустаяСсылка();
	If ЗначениеЗаполнено(pRoomType) And НЕ pRoomType.IsFolder And ЗначениеЗаполнено(pRoomType.ВидРазмещения) Тогда
		vAccommodationType = pRoomType.ВидРазмещения;
	ElsIf ЗначениеЗаполнено(pHotel) And НЕ pHotel.IsFolder And ЗначениеЗаполнено(pHotel.ВидРазмещения) Тогда
		vAccommodationType = pHotel.ВидРазмещения;
	Else
		vAccommodationType = cmGetAccommodationTypeRoom(pHotel);
	EndIf;
	Return vAccommodationType;
EndFunction //cmGetDefaultAccommodationType

//-----------------------------------------------------------------------------
// Returns earliest active reservation check-in date for the given hotel
//-----------------------------------------------------------------------------
Function cmGetMinCheckInDate(pHotel) Экспорт
	vMinDate = BegOfDay(CurrentDate());
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	MIN(Бронирование.CheckInDate) AS CheckInDate
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.CheckInDate <= &qEndOfToday
	|	AND Бронирование.Гостиница IN HIERARCHY (&qHotel)
	|	AND Бронирование.Posted
	|	AND Бронирование.ReservationStatus.IsActive";
	vQry.SetParameter("qEndOfToday", EndOfDay(CurrentDate()));
	vQry.SetParameter("qHotel", pHotel);
	vResults = vQry.Execute().Unload();
	If vResults.Count() > 0 Тогда
		vMinCheckInDate = vResults.Get(0).CheckInDate;
		If TypeOf(vMinCheckInDate) = Type("Date") And ЗначениеЗаполнено(vMinCheckInDate) Тогда
			vMinDate = BegOfDay(vMinCheckInDate);
		EndIf;
	EndIf;
	Return vMinDate;
EndFunction //cmGetMinCheckInDate 

