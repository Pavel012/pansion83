//-----------------------------------------------------------------------------
// Description: Finds client by client code
// Parameters: Client code
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByCode(pClientCode) Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by code
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	Клиенты.Code = &qClientCode
	|	AND (NOT Клиенты.DeletionMark)
	|	AND (NOT Клиенты.IsFolder)
	|ORDER BY
	|	Клиенты.Description,
	|	Клиенты.CreateDate";
	vQry.SetParameter("qClientCode", pClientCode);
	vClients = vQry.Execute().Unload();
	If vClients.Count() > 0 Тогда
		vClient = vClients.Get(0).Ref;
	EndIf;
	Return vClient;
EndFunction //cmGetClientByCode

//-----------------------------------------------------------------------------
// Description: Finds client by client external system code
// Parameters: Client external system code
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByExternalCode(pExternalCode) Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by external code or reservation external code
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	Клиенты.ExternalCode = &qExternalCode
	|	AND (NOT Клиенты.DeletionMark)
	|	AND (NOT Клиенты.IsFolder)
	|ORDER BY
	|	Клиенты.Description,
	|	Клиенты.CreateDate";
	vQry.SetParameter("qExternalCode", СокрЛП(pExternalCode));
	vClients = vQry.Execute().Unload();
	If vClients.Count() > 0 Тогда
		vClient = vClients.Get(0).Ref;
	EndIf;
	Return vClient;
EndFunction //cmGetClientByExternalCode

//-----------------------------------------------------------------------------
// Description: Finds client by client names and birth date
// Parameters: Client last name string, Client first name string, Client second name string,
//             Client birth date
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByFullnameAndBirthDate(pClientLastName, pClientFirstName, pClientSecondName, pClientBirthDate) Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by names and birth date
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	Клиенты.Фамилия = &qClientLastName
	|	AND Клиенты.Имя = &qClientFirstName
	|	AND Клиенты.Отчество = &qClientSecondName
	|	AND Клиенты.ДатаРождения = &qClientBirthDate
	|	AND (NOT Клиенты.DeletionMark)
	|	AND (NOT Клиенты.IsFolder)
	|ORDER BY
	|	Клиенты.FullName DESC,
	|	Клиенты.ДатаРождения DESC,
	|	Клиенты.IdentityDocumentNumber DESC,
	|	Клиенты.CreateDate";
	vQry.SetParameter("qClientLastName", Title(СокрЛП(pClientLastName)));
	vQry.SetParameter("qClientFirstName", Title(СокрЛП(pClientFirstName)));
	vQry.SetParameter("qClientSecondName", Title(СокрЛП(pClientSecondName)));
	vQry.SetParameter("qClientBirthDate", pClientBirthDate);
	vClients = vQry.Execute().Unload();
	If vClients.Count() > 0 Тогда
		vClient = vClients.Get(0).Ref;
	EndIf;
	Return vClient;
EndFunction //cmGetClientByFullnameAndBirthDate

//-----------------------------------------------------------------------------
// Description: Finds client by client names and phone number
// Parameters: Client last name string, Client first name string, Client second name string,
//             Client phone number
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByFullnameAndPhone(pClientLastName, pClientFirstName, pClientSecondName="", pPhone="") Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by names and birth date
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	Клиенты.Фамилия = &qClientLastName
	|	AND Клиенты.Имя = &qClientFirstName " + 
		?(ЗначениеЗаполнено(pClientSecondName), " AND Клиенты.Отчество = &qClientSecondName ", "") + 
		?(ЗначениеЗаполнено(pPhone), " AND Клиенты.Телефон = &qPhone ", "") + 
	   "AND (NOT Клиенты.DeletionMark)
	|	AND (NOT Клиенты.IsFolder)
	|ORDER BY
	|	Клиенты.FullName DESC,
	|	Клиенты.IdentityDocumentNumber DESC,
	|	Клиенты.CreateDate";
	vQry.SetParameter("qClientLastName", Title(СокрЛП(pClientLastName)));
	vQry.SetParameter("qClientFirstName", Title(СокрЛП(pClientFirstName)));
	If ЗначениеЗаполнено(pClientSecondName) Тогда
		vQry.SetParameter("qClientSecondName", Title(СокрЛП(pClientSecondName)));
	EndIf;
	//If ЗначениеЗаполнено(pPhone) Тогда
	//	vQry.SetParameter("qPhone", SMS.GetValidPhoneNumber(pPhone));
	//EndIf;
	vClients = vQry.Execute().Unload();
	If vClients.Count() > 0 Тогда
		vClient = vClients.Get(0).Ref;
	ElsIf НЕ IsBlankString(pClientSecondName) And НЕ IsBlankString(pPhone) Тогда
		vClient = cmGetClientByFullnameAndPhone(pClientLastName, pClientFirstName, , pPhone);
	EndIf;
	Return vClient;
EndFunction //cmGetClientByFullnameAndPhone

//-----------------------------------------------------------------------------
// Description: Finds client by client names and EMail
// Parameters: Client last name string, Client first name string, Client second name string,
//             Client EMail
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByFullnameAndEmail(pClientLastName, pClientFirstName, pClientSecondName="", pEmail="") Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by names and birth date
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	Клиенты.Фамилия = &qClientLastName
	|	AND Клиенты.Имя = &qClientFirstName " + 
		?(ЗначениеЗаполнено(pClientSecondName), " AND Клиенты.Отчество = &qClientSecondName ", "") + 
		?(ЗначениеЗаполнено(pEmail), " AND Клиенты.Email = &qEmail ", "") + 
	   "AND (NOT Клиенты.DeletionMark)
	|	AND (NOT Клиенты.IsFolder)
	|ORDER BY
	|	Клиенты.FullName DESC,
	|	Клиенты.IdentityDocumentNumber DESC,
	|	Клиенты.CreateDate";
	vQry.SetParameter("qClientLastName", Title(СокрЛП(pClientLastName)));
	vQry.SetParameter("qClientFirstName", Title(СокрЛП(pClientFirstName)));
	If ЗначениеЗаполнено(pClientSecondName) Тогда
		vQry.SetParameter("qClientSecondName", Title(СокрЛП(pClientSecondName)));
	EndIf;
	If ЗначениеЗаполнено(pEmail) Тогда
		vQry.SetParameter("qEmail", СокрЛП(pEmail));
	EndIf;
	vClients = vQry.Execute().Unload();
	If vClients.Count() > 0 Тогда
		vClient = vClients.Get(0).Ref;
	ElsIf НЕ IsBlankString(pClientSecondName) And НЕ IsBlankString(pEmail) Тогда
		vClient = cmGetClientByFullnameAndEmail(pClientLastName, pClientFirstName, , pEmail);
	EndIf;
	Return vClient;
EndFunction //cmGetClientByFullnameAndEmail

//-----------------------------------------------------------------------------
// Description: Finds client by phone and e-mail
// Parameters: Client phone and e-mail
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByPhoneAndEMail(pPhone, pEMail) Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by e-mail
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	NOT Клиенты.IsFolder
	|	"+?(ЗначениеЗаполнено(pEMail), " AND Клиенты.EMail = &qEMail ", " ")+
	"	"+?(ЗначениеЗаполнено(pPhone), " AND Клиенты.Телефон = &qPhone ", " ")+
	"	AND NOT Клиенты.DeletionMark
	|
	|ORDER BY
	|	Клиенты.FullName DESC,
	|	Клиенты.ДатаРождения DESC,
	|	Клиенты.IdentityDocumentNumber DESC,
	|	Клиенты.CreateDate";
	If ЗначениеЗаполнено(pEMail) Тогда
		vQry.SetParameter("qEMail", СокрЛП(pEMail));
	EndIf;
	//If ЗначениеЗаполнено(pPhone) Тогда
	//	vQry.SetParameter("qPhone", СокрЛП(SMS.GetValidPhoneNumber(pPhone)));
	//EndIf;
	vClients = vQry.Execute().Unload();
	If vClients.Count() = 1 Тогда
		vClient = vClients.Get(0).Ref;
	EndIf;
	Return vClient;
EndFunction //cmGetClientByPhoneAndEMail

//-----------------------------------------------------------------------------
// Description: Finds client by discound card id
// Parameters: Discount card identifier
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByPromoCode(pPromoCode) Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by e-mail
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ДисконтныеКарты.Клиент AS Клиент
	|FROM
	|	Catalog.ДисконтныеКарты AS DiscountCards
	|WHERE
	|	ДисконтныеКарты.Identifier = &qPromoCode
	|	AND ДисконтныеКарты.Клиент <> &qEmptyClient
	|	AND NOT ДисконтныеКарты.Клиент.DeletionMark
	|
	|ORDER BY
	|	ДисконтныеКарты.Клиент.FullName DESC,
	|	ДисконтныеКарты.Клиент.ДатаРождения DESC,
	|	ДисконтныеКарты.Клиент.IdentityDocumentNumber DESC,
	|	ДисконтныеКарты.Клиент.CreateDate";
	vQry.SetParameter("qPromoCode", СокрЛП(pPromoCode));
	vQry.SetParameter("qEmptyClient", Справочники.Клиенты.EmptyRef());
	vClients = vQry.Execute().Unload();
	If vClients.Count() = 1 Тогда
		vClient = vClients.Get(0).Клиент;
	EndIf;
	Return vClient;
EndFunction //cmGetClientByPromoCode

//-----------------------------------------------------------------------------
// Description: Finds client by e-mail
// Parameters: Client e-mail
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByEMail(pEMail) Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	// Try to find client by e-mail
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	Клиенты.EMail = &qEMail
	|	AND NOT Клиенты.DeletionMark
	|	AND NOT Клиенты.IsFolder
	|
	|ORDER BY
	|	Клиенты.FullName DESC,
	|	Клиенты.ДатаРождения DESC,
	|	Клиенты.IdentityDocumentNumber DESC,
	|	Клиенты.CreateDate";
	vQry.SetParameter("qEMail", СокрЛП(pEMail));
	vClients = vQry.Execute().Unload();
	If vClients.Count() > 0 Тогда
		vClient = vClients.Get(0).Ref;
	EndIf;
	Return vClient;
EndFunction //cmGetClientByEMail

//-----------------------------------------------------------------------------
// Description: Finds client by phone
// Parameters: Client phone
// Return value: Client reference
//-----------------------------------------------------------------------------
Function cmGetClientByPhone(pPhone) Экспорт
	vClient = Справочники.Клиенты.EmptyRef();
	//// Try to find client by phone number
	//vQry = New Query();
	//vQry.Text = 
	//"SELECT
	//|	Клиенты.Ref
	//|FROM
	//|	Catalog.Клиенты AS Клиенты
	//|WHERE
	//|	Клиенты.Phone = &qPhone
	//|	AND NOT Клиенты.DeletionMark
	//|	AND NOT Клиенты.IsFolder
	//|
	//|ORDER BY
	//|	Клиенты.FullName DESC,
	//|	Клиенты.DateOfBirth DESC,
	//|	Клиенты.IdentityDocumentNumber DESC,
	//|	Клиенты.CreateDate";
	//vQry.SetParameter("qPhone", SMS.GetValidPhoneNumber(pPhone));
	//vClients = vQry.Execute().Unload();
	//If vClients.Count() > 0 Тогда
	//	vClient = vClients.Get(0).Ref;
	//EndIf;
	Return vClient;
EndFunction //cmGetClientByPhone
                                                
//-----------------------------------------------------------------------------
// Description: This API is used to create new client from an external system data 
//              or update one with changed data
// Parameters: Client data fileds
// Return value: String with client code if success, String with error description 
//               in case of failure
//-----------------------------------------------------------------------------
Function cmWriteExternalClient(pExtClientCode, pExtReservationCode, 
                               pClientLastName, pClientFirstName, pClientSecondName, 
                               pClientSexCode, pClientCitizenshipCode, pClientBirthDate,
                               pClientPhone, pClientFax, pClientEMail, pClientRemarks, pClientSendSMS = Неопределено,  
                               pHotelCode, pExternalSystemCode, pParentCode = "", 
							   pLanguage = Неопределено, pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Write external client';ru='Записать внешнего клиента';de='den externen Kunden einschreiben'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='External client code: ';ru='Код клиента во внешней системе: ';de='Kundencode im externen System: '") + pExtClientCode + Chars.LF + 
	              NStr("en='External reservation code: ';ru='Код брони во внешней системе: ';de='Reservierungscode im externen System: '") + pExtReservationCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='Client last name: ';ru='Фамилия гостя: ';de='Familienname des Gastes: '") + pClientLastName + Chars.LF + 
	              NStr("en='Client first name: ';ru='Имя гостя: ';de='Name des Gastes: '") + pClientFirstName + Chars.LF + 
	              NStr("en='Client second name: ';ru='Отчество гостя: ';de='Vatersname des Gastes: '") + pClientSecondName + Chars.LF + 
	              NStr("en='Client sex code: ';ru='Код пола гостя: ';de='Code des Geschlechts des Gastes: '") + pClientSexCode + Chars.LF + 
	              NStr("en='Client Гражданство code: ';ru='Код гражданства гостя: ';de='Code der Stadtbürgerschaft des Gastes: '") + pClientCitizenshipCode + Chars.LF + 
	              NStr("en='Client birth date: ';ru='Дата рождения гостя: ';de='Geburtsdatum des Gastes: '") + Format(pClientBirthDate, "DF='dd.MM.yyyy'") + Chars.LF + 
	              NStr("en='Client phone: ';ru='Телефон гостя: ';de='Telefon des Gastes: '") + pClientPhone + Chars.LF + 
	              NStr("en='Client fax: ';ru='Факс гостя: ';de='Fax des Gastes:'") + pClientFax + Chars.LF + 
	              NStr("en='Client E-Mail: ';ru='E-Mail гостя: ';de='E-Mail-Adresse des Gastes: '") + pClientEMail + Chars.LF + 
	              NStr("en='Client remarks: ';ru='Примечания гостя: ';de='Anmerkungen des Gastes: '") + pClientRemarks + Chars.LF + 
	              NStr("en='Send SMS: ';ru='Рассылка СМС: ';de='Versand von SMS: '") + pClientSendSMS + Chars.LF + 
	              NStr("en='Language: ';ru='Язык гостя: ';de='Sprache des Gastes: '") + pLanguage + Chars.LF + 
	              NStr("en='Parent folder code: ';ru='Код родительской группы: ';de='Code der Elterngruppe: '") + СокрЛП(pParentCode));
	Try
		vCltObj = Неопределено;
		// Try to find hotel by name or code
		vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
		// Initialize client reference
		vCltRef = Неопределено;
		// Try to find client by full name and birth date
		If НЕ IsBlankString(pClientLastName) And 
		   НЕ IsBlankString(pClientFirstName) And
		   ЗначениеЗаполнено(pClientBirthDate) Тогда
			vCltRef = cmGetClientByFullNameAndBirthdate(pClientLastName, pClientFirstName, pClientSecondName, BegOfDay(pClientBirthDate));
		EndIf;
		// Try to find client by external client code or by external system code
		If НЕ ЗначениеЗаполнено(vCltRef) And НЕ IsBlankString(pExtClientCode) Тогда
			vCltRef = cmGetClientByExternalCode(pExtClientCode);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCltRef) And НЕ IsBlankString(pExtReservationCode) Тогда
			vCltRef = cmGetClientByExternalCode(pExtReservationCode);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCltRef) And НЕ IsBlankString(pClientPhone) Тогда
			vCltRef = cmGetClientByFullnameAndPhone(pClientLastName, pClientFirstName, pClientSecondName, pClientPhone);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCltRef) And НЕ IsBlankString(pClientEMail) Тогда
			vCltRef = cmGetClientByFullnameAndEmail(pClientLastName, pClientFirstName, pClientSecondName, pClientEMail);
		EndIf;
		If ЗначениеЗаполнено(vCltRef) Тогда
			If НЕ IsBlankString(pClientSecondName) And ЗначениеЗаполнено(vCltRef.Отчество) Тогда
				If Lower(СокрЛП(vCltRef.Отчество)) <> Lower(СокрЛП(pClientSecondName)) Тогда
					vCltRef = Неопределено;
				EndIf;
			EndIf;
		EndIf;
		// Check client reference
		If ЗначениеЗаполнено(vCltRef) Тогда
			// Log that we've found client by external code
			WriteLogEvent(NStr("en='Write external client';ru='Записать внешнего клиента';de='Den externen Kunden einschreiben'"), EventLogLevel.Information, vCltRef.Metadata(), vCltRef, NStr("en='Client is found by external code!';ru='Клиент найден по коду во внешней системе!';de='Der Kunde wurde nach dem Code im externen System gefunden!'"));
			// Get client object
			vCltObj = vCltRef.GetObject();
		Else
			// Create new client object
			vCltObj = Справочники.Клиенты.CreateItem();
			// Author and date
			vCltObj.Автор = ПараметрыСеанса.ТекПользователь;
			vCltObj.CreateDate = CurrentDate();
			// External code
			If НЕ IsBlankString(pExtClientCode) Тогда
				vCltObj.ExternalCode = pExtClientCode;
			ElsIf НЕ IsBlankString(pExtReservationCode) Тогда
				vCltObj.ExternalCode = pExtReservationCode;
			EndIf;
			// Default charging rules
			If vHotel.AlwaysCreateDefaultChargingRulesForNewClients Тогда
				vCltObj.pmCreateFolios(vHotel, vCltObj.CreateDate);
			EndIf;
		EndIf;
		// Parent folder
		If НЕ IsBlankString(pParentCode) Тогда
			vCltObj.Parent = Справочники.Клиенты.FindByCode(pParentCode);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCltObj.Parent) Тогда
			vCltObj.Parent = Справочники.Клиенты.ReservedGuests;
		EndIf;
		// Language
		If ЗначениеЗаполнено(pLanguage) Тогда
			vCltObj.Language = pLanguage;
		EndIf;
		// Initialization based on hotel
		If ЗначениеЗаполнено(vHotel) Тогда
			// Гражданство
			If НЕ ЗначениеЗаполнено(vCltObj.Citizenship) Тогда
				If IsBlankString(pClientCitizenshipCode) Тогда
					vCltObj.Гражданство = vHotel.Гражданство;
				Else
					vCltObj.Гражданство = cmGetCountryByCode(pClientCitizenshipCode);
				EndIf;
			ElsIf НЕ IsBlankString(pClientCitizenshipCode) Тогда
				vCltObj.Гражданство = cmGetCountryByCode(pClientCitizenshipCode);
			EndIf;
			// Language
			If НЕ ЗначениеЗаполнено(vCltObj.Language) Тогда
				vCltObj.Language = vHotel.Language;
			EndIf;
			// Identity document
			If НЕ ЗначениеЗаполнено(vCltObj.IdentityDocumentType) Тогда
				If vCltObj.Гражданство = vHotel.Гражданство Тогда
					vCltObj.IdentityDocumentType = vHotel.IdentityDocumentType;
				Else
					vCltObj.IdentityDocumentType = vHotel.IdentityDocumentTypeForForeigners;
				EndIf;
			EndIf;
		EndIf;
		// Names
		If pExternalSystemCode = "WUBOOK" Тогда
			If IsBlankString(vCltObj.Имя) Тогда
				vCltObj.Имя = Title(СокрЛП(pClientFirstName));
			EndIf;
			If IsBlankString(vCltObj.Фамилия) Тогда
				vCltObj.Фамилия = Title(СокрЛП(pClientLastName));
			EndIf;
			If IsBlankString(vCltObj.Отчество) Тогда
				vCltObj.Отчество = Title(СокрЛП(pClientSecondName));
			EndIf;
		Else
			If НЕ IsBlankString(pClientFirstName) Тогда
				vCltObj.Имя = Title(СокрЛП(pClientFirstName));
			EndIf;
			If НЕ IsBlankString(pClientLastName) Тогда
				vCltObj.Фамилия = Title(СокрЛП(pClientLastName));
			EndIf;
			If НЕ IsBlankString(pClientSecondName) Тогда
				vCltObj.Отчество = Title(СокрЛП(pClientSecondName));
			EndIf;
		EndIf;
		// Birth date
		If ЗначениеЗаполнено(pClientBirthDate) Тогда
			If pExternalSystemCode = "WUBOOK" Тогда
				If НЕ ЗначениеЗаполнено(vCltObj.ДатаРождения) Тогда
					vCltObj.ДатаРождения = BegOfDay(pClientBirthDate);
				EndIf;
			Else
				vCltObj.ДатаРождения = BegOfDay(pClientBirthDate);
			EndIf;
		EndIf;
		// Sex
		If НЕ IsBlankString(pClientSexCode) Тогда
			vSexLetter = Upper(Left(СокрЛП(pClientSexCode), 1));
			If vSexLetter = "F" Or vSexLetter = "Ж" Тогда
				vCltObj.Пол = Перечисления.Пол.Female;
			Else
				vCltObj.Пол = Перечисления.Пол.Male;
			EndIf;
		Else
			vCltObj.Пол = cmGetSexByNames(vCltObj.Фамилия, vCltObj.Имя, vCltObj.Отчество);
		EndIf;
		// Contacts
		If НЕ IsBlankString(pClientPhone) Тогда
			vCltObj.Телефон = СокрЛП(pClientPhone);
		EndIf;
		If НЕ IsBlankString(pClientFax) Тогда
			vCltObj.Fax = СокрЛП(pClientFax);
		EndIf;
		If НЕ IsBlankString(pClientEMail) Тогда
			vCltObj.EMail = СокрЛП(pClientEMail);
		EndIf;
		// Remarks
		If НЕ IsBlankString(pClientRemarks) Тогда
			vCltObj.Примечания = СокрЛП(pClientRemarks);
		EndIf;
		// No SMS delivery
				// Run some internal client functions to fill some client parameters
		vCltObj.Description = vCltObj.pmGetDescription();
		vCltObj.FullName = vCltObj.pmGetFullName();
		// Run some internal client functions to fill some client parameters
		vCltObj.Description = vCltObj.pmGetDescription();
		vCltObj.FullName = vCltObj.pmGetFullName();
		// Write item
		vCltObj.Write();
		// Save data to the client change history
		vCltObj.pmWriteToClientChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
		// Build return string
		vRetStr = """" + СокрЛП(vCltObj.Code) + """" + "," + """" + """";
		// Log success		
		WriteLogEvent(NStr("en='Write external client';ru='Записать внешнего клиента';de='den externen Kunden einschreiben'"), EventLogLevel.Information, , , 
					  NStr("en='Client was saved - OK!';ru='Клиент записан в БД!';de='Der Kunde ist in die Datenbank geschrieben!'") + Chars.LF + vRetStr);
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalClientStatus"));
			vRetXDTO.ClientCode = vCltObj.Code;
			vRetXDTO.ErrorDescription = "";
			Return vRetXDTO;
		EndIf;
	Except
		vErrorDescription = ErrorDescription();
		// Write log event
		WriteLogEvent(NStr("en='Write external client';ru='Записать внешнего клиента';de='Den externen Kunden einschreiben'"), EventLogLevel.Error, , , 
					  NStr("en='Error description: ';ru='Описание ошибки: ';de='Fehlerbeschreibung: '") + ErrorDescription());
		// Build return string
		vRetStr = """" + """" + "," + """" + vErrorDescription + """";
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalClientStatus"));
			vRetXDTO.ClientCode = "";
			vRetXDTO.ErrorDescription = vErrorDescription;
			Return vRetXDTO;
		EndIf;
	EndTry;
EndFunction //cmWriteExternalClient

//-----------------------------------------------------------------------------
// Description: Finds Контрагент by ИНН and KPP
// Parameters: Контрагент ИНН, Контрагент KPP, Контрагент name used to create new Контрагент, 
//             Whether to create new Контрагент if nothing was found or not
// Return value: Контрагент reference
//-----------------------------------------------------------------------------
Function cmGetCustomerByExternalCode(pCustomerExternalCode) Экспорт
	vCustomer = Справочники.Контрагенты.EmptyRef();
	// Try to find Контрагент by description or external code
	If НЕ IsBlankString(pCustomerExternalCode) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Контрагенты.Ref
		|FROM
		|	Catalog.Контрагенты AS Customers
		|WHERE
		|	Контрагенты.ExternalCode = &qExternalCode
		|	AND NOT Контрагенты.DeletionMark
		|	AND NOT Контрагенты.IsFolder
		|
		|ORDER BY
		|	Контрагенты.Code DESC";
		vQry.SetParameter("qExternalCode", СокрЛП(pCustomerExternalCode));
		vCustomers = vQry.Execute().Unload();
		If vCustomers.Count() > 0 Тогда
			vCustomer = vCustomers.Get(0).Ref;
		EndIf;
	EndIf;
	Return vCustomer;
EndFunction //cmGetCustomerByExternalCode

//-----------------------------------------------------------------------------
// Description: Finds Контрагент by name
// Parameters: Контрагент name, Whether to create new Контрагент if nothing was found or not
// Return value: Контрагент reference
//-----------------------------------------------------------------------------
Function cmGetCustomerByName(pCustomerName, pDateOfBirth = '00010101', pCreate = True, pIsIndividualPerson = False, pPaymentMethod = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Get Контрагент by name';ru='Поиск контрагента по наименованию';de='Suche nach dem Partner nach Bezeichnung'"), EventLogLevel.Information, , , NStr("en='Input parameters: ';ru='Входные параметры: ';de='Eingangsparameter:'") + Chars.LF +
	              NStr("en='Контрагент name: ';ru='Наименование контрагента: ';de='Bezeichnung des Partners: '") + pCustomerName + Chars.LF + 
	              NStr("en='Date of birth: ';ru='Дата рождения: ';de='Geburtsdatum: '") + BegOfDay(pDateOfBirth) + Chars.LF + 
	              NStr("en='Is individuals person: ';ru='Частное лицо: ';de='Privatperson: '") + pIsIndividualPerson + Chars.LF + 
	              NStr("en='Payment method: ';ru='Способ оплаты: ';de='Zahlungsmethode: '") + pPaymentMethod + Chars.LF + 
	              NStr("en='Do create new if not found: ';ru='Создавать новую карточку если не найден: ';de='Neue Karte generieren falls nicht gefunden: '") + pCreate);
	vCustomer = Справочники.Контрагенты.EmptyRef();
	// Try to find Контрагент by description or external code
	If НЕ IsBlankString(pCustomerName) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Контрагенты.Ref
		|FROM
		|	Catalog.Контрагенты AS Customers
		|WHERE
		|	(Контрагенты.Description = &qCustomerName
		|			OR Контрагенты.ЮрИмя = &qCustomerName
		|			OR Контрагенты.ExternalCode = &qCustomerName)
		|	AND NOT Контрагенты.DeletionMark
		|	AND NOT Контрагенты.IsFolder
		|	AND (NOT &qIsIndividual
		|			OR &qIsIndividual
		|				AND Контрагенты.Ref IN HIERARCHY (&qIndividualsFolder)
		|				AND (Контрагенты.ДатаРождения = &qDateOfBirth
		|					OR &qDateOfBirthIsEmpty))
		|
		|ORDER BY
		|	Контрагенты.Code DESC";
		vQry.SetParameter("qCustomerName", Upper(СокрЛП(pCustomerName)));
		vQry.SetParameter("qIsIndividual", pIsIndividualPerson);
		vQry.SetParameter("qIndividualsFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
		vQry.SetParameter("qDateOfBirth", BegOfDay(pDateOfBirth));
		vQry.SetParameter("qDateOfBirthIsEmpty", НЕ ЗначениеЗаполнено(BegOfDay(pDateOfBirth)));
		vCustomers = vQry.Execute().Unload();
		If vCustomers.Count() > 0 Тогда
			vCustomer = vCustomers.Get(0).Ref;
			WriteLogEvent(NStr("en='Get Контрагент by name';ru='Поиск контрагента по наименованию';de='Suche nach dem Partner nach Bezeichnung'"), EventLogLevel.Information, , , NStr("en='Контрагент is found: ';ru='Найден контрагент: ';de='Partner gefunden: '") + СокрЛП(vCustomer.Description) + " (" + СокрЛП(vCustomer.Code) + ")");
		ElsIf pCreate Тогда
			WriteLogEvent(NStr("en='Get Контрагент by name';ru='Поиск контрагента по наименованию';de='Suche nach dem Partner nach Bezeichnung'"), EventLogLevel.Information, , , NStr("en='Контрагент is not found!';ru='Не найден контрагент!';de='Partner nicht gefunden!'"));
			// Create new Контрагент
			vCustomerObj = Справочники.Контрагенты.CreateItem();
			If pIsIndividualPerson Тогда
				vIndividualsFolder = Constants.КонтрагентПоУмолчанию.Get();
				If НЕ ЗначениеЗаполнено(vIndividualsFolder) Тогда
					vIndividualsFolder = Справочники.Контрагенты.КонтрагентПоУмолчанию;
				EndIf;
				vCustomerObj.Parent = vIndividualsFolder;
				If ЗначениеЗаполнено(pDateOfBirth) Тогда
					vCustomerObj.ДатаРождения = pDateOfBirth;
				EndIf;
			EndIf;
			vCustomerObj.Description = СокрЛП(pCustomerName);
			vCustomerObj.pmFillAttributesWithDefaultValues();
			If ЗначениеЗаполнено(pPaymentMethod) Тогда
				vCustomerObj.PlannedPaymentMethod = pPaymentMethod;
				If vCustomerObj.ChargingRules.Count() > 0 Тогда
					v1CRRow = vCustomerObj.ChargingRules.Get(0);
					v1CRRowFolioObj = v1CRRow.ChargingFolio.GetObject();
					v1CRRowFolioObj.СпособОплаты = pPaymentMethod;
					v1CRRowFolioObj.Write(DocumentWriteMode.Write);
				EndIf;
			EndIf;
			vCustomerObj.Write();
			// Save data to the Контрагент change history
			vCustomerObj.pmWriteToCustomerChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			// Fill reference
			vCustomer = vCustomerObj.Ref;
		EndIf;
	EndIf;
	Return vCustomer;
EndFunction //cmGetCustomerByName 

//-----------------------------------------------------------------------------
// Description: Finds Контрагент by ИНН and KPP
// Parameters: Контрагент ИНН, Контрагент KPP, Контрагент name used to create new Контрагент, 
//             Whether to create new Контрагент if nothing was found or not
// Return value: Контрагент reference
//-----------------------------------------------------------------------------
Function cmGetCustomerByTIN(pCustomerTIN, pCustomerKPP, pCustomerName, pCreate = True) Экспорт
	vCustomer = Справочники.Контрагенты.EmptyRef();
	// Try to find Контрагент by description or external code
	If НЕ IsBlankString(pCustomerTIN) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Контрагенты.Ref
		|FROM
		|	Catalog.Контрагенты AS Customers
		|WHERE
		|	Контрагенты.ИНН = &qCustomerTIN
		|	AND (NOT &qDoNotCheckKPP
		|				AND Контрагенты.KPP = &qCustomerKPP
		|			OR &qDoNotCheckKPP)
		|	AND NOT Контрагенты.DeletionMark
		|	AND NOT Контрагенты.IsFolder
		|
		|ORDER BY
		|	Контрагенты.Description";
		vQry.SetParameter("qCustomerTIN", СокрЛП(pCustomerTIN));
		vQry.SetParameter("qCustomerKPP", СокрЛП(pCustomerKPP));
		If IsBlankString(pCustomerKPP) Or StrLen(СокрЛП(pCustomerTIN)) > 10 Тогда
			vQry.SetParameter("qDoNotCheckKPP", True);
		Else
			vQry.SetParameter("qDoNotCheckKPP", False);
		EndIf;
		vCustomers = vQry.Execute().Unload();
		If vCustomers.Count() > 0 Тогда
			vCustomer = vCustomers.Get(0).Ref;
		ElsIf pCreate And НЕ IsBlankString(pCustomerName) Тогда
			// Create new Контрагент
			vCustomerObj = Справочники.Контрагенты.CreateItem();
			vCustomerObj.Description = СокрЛП(pCustomerName);
			vCustomerObj.ЮрИмя = Title(СокрЛП(vCustomerObj.Description));
			vCustomerObj.ИНН = СокрЛП(pCustomerTIN);
			vCustomerObj.KPP = СокрЛП(pCustomerKPP);
			vCustomerObj.pmFillAttributesWithDefaultValues();
			vCustomerObj.Write();
			// Save data to the Контрагент change history
			vCustomerObj.pmWriteToCustomerChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			// Fill reference
			vCustomer = vCustomerObj.Ref;
		EndIf;
	EndIf;
	Return vCustomer;
EndFunction //cmGetCustomerByTIN 

//-----------------------------------------------------------------------------
// Description: Finds contract by description
// Parameters: Контрагент ref, Contract description, Whether to create new contract 
//             if nothing was found or not
// Return value: Contract reference
//-----------------------------------------------------------------------------
Function cmGetContractByName(pCustomerRef, pContractName, pCreate = True) Экспорт
	vContract = Справочники.Договора.EmptyRef();
	// Try to find contract by code, description or external code
	If НЕ IsBlankString(pContractName) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Договора.Ref
		|FROM
		|	Catalog.Договора AS Contracts
		|WHERE
		|	(Договора.Code = &qContractName
		|			OR Договора.Description = &qContractName
		|			OR Договора.ExternalCode = &qContractName)
		|	AND (NOT Договора.DeletionMark)
		|	AND Договора.Owner = &qCustomer
		|ORDER BY
		|	Договора.Code";
		vQry.SetParameter("qContractName", СокрЛП(pContractName));
		vQry.SetParameter("qCustomer", pCustomerRef);
		vContracts = vQry.Execute().Unload();
		If vContracts.Count() > 0 Тогда
			vContract = vContracts.Get(0).Ref;
		ElsIf pCreate And ЗначениеЗаполнено(pCustomerRef) Тогда
			// Create new contract
			vContractObj = Справочники.Договора.CreateItem();
			vContractObj.Code = СокрЛП(pContractName);
			vContractObj.Description = СокрЛП(pContractName);
			vContractObj.Owner = pCustomerRef;
			vContractObj.pmFillAttributesWithDefaultValues();
			vContractObj.Write();
			// Save data to the contract change history
			//vContractObj.pmWriteToContractChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			// Fill reference
			vContract = vContractObj.Ref;
		EndIf;
	EndIf;
	Return vContract;
EndFunction //cmGetContractByName 

//-----------------------------------------------------------------------------
// Description: Searches reservation by it's external code
// Parameters: Гостиница, Reservation external code
// Return value: Reservation reference
//-----------------------------------------------------------------------------
Function cmGetReservationByExternalCode(pHotelRef, pExtReservationCode) Экспорт
	vReservation = Documents.Бронирование.EmptyRef();
	// Try to find reservation by external code
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Reservations.Ref
	|FROM
	|	Document.Бронирование AS Reservations
	|WHERE
	|	Reservations.ExternalCode = &qExternalCode
	|	AND (NOT Reservations.DeletionMark)
	|	AND Reservations.Гостиница = &qHotel
	|ORDER BY
	|	Reservations.PointInTime";
	vQry.SetParameter("qHotel", pHotelRef);
	vQry.SetParameter("qExternalCode", СокрЛП(pExtReservationCode));
	vReservations = vQry.Execute().Unload();
	If vReservations.Count() > 0 Тогда
		vReservation = vReservations.Get(0).Ref;
	EndIf;
	Return vReservation;
EndFunction //cmGetReservationByExternalCode

//-----------------------------------------------------------------------------
// Description: Searches guest group by it's external code. This function can 
//              create new guest group if nothing was found
// Parameters: Гостиница, Guest group external code, Guest group description, 
//             Guest group Контрагент name as string, Whether to create new guest 
//             group if nothing was found
// Return value: Guest froup reference
//-----------------------------------------------------------------------------
Function cmGetGuestGroupByExternalCode(pHotelRef, pExtGroupCode, pExtGroupDescription, pGroupCustomerName, pCreateNew = True) Экспорт
	vGuestGroup = Справочники.ГруппыГостей.EmptyRef();
	// Try to find guest group by external code
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ГруппыГостей.Ref
	|FROM
	|	Catalog.ГруппыГостей AS GuestGroups
	|WHERE
	|	ГруппыГостей.ExternalCode = &qExternalCode
	|	AND (NOT ГруппыГостей.DeletionMark)
	|	AND (NOT ГруппыГостей.IsFolder)
	|	AND ГруппыГостей.Owner = &qHotel
	|ORDER BY
	|	ГруппыГостей.Code";
	vQry.SetParameter("qHotel", pHotelRef);
	vQry.SetParameter("qExternalCode", СокрЛП(pExtGroupCode));
	vGuestGroups = vQry.Execute().Unload();
	If vGuestGroups.Count() > 0 Тогда
		vGuestGroup = vGuestGroups.Get(0).Ref;
	ElsIf pCreateNew Тогда
		// Create new guest group
		vGuestGroupObj = Справочники.ГруппыГостей.CreateItem();
		vGuestGroupObj.Owner = pHotelRef;
		vGuestGroupFolder = pHotelRef.GetObject().pmGetGuestGroupFolder();
		If ЗначениеЗаполнено(vGuestGroupFolder) Тогда
			vGuestGroupObj.Parent = vGuestGroupFolder;
			vGuestGroupObj.SetNewCode();
		EndIf;
		If ЗначениеЗаполнено(vGuestGroupObj.Owner) Тогда
			vGuestGroupObj.OneCustomerPerGuestGroup = vGuestGroupObj.Owner.OneCustomerPerGuestGroup;
		EndIf;
		If НЕ IsBlankString(СокрЛП(pExtGroupCode)) And СокрЛП(pExtGroupCode) <> "0" Тогда
			vGuestGroupObj.ExternalCode = СокрЛП(pExtGroupCode);
			If StrLen(СокрЛП(pExtGroupCode)) < 36 Тогда
				If IsBlankString(pExtGroupDescription) Тогда
					vGuestGroupObj.Description = СокрЛП(pExtGroupCode);
				Else
					vGuestGroupObj.Description = СокрЛП(pExtGroupCode) + " - " + СокрЛП(pExtGroupDescription);
				EndIf;
			Else
				vGuestGroupObj.Description = СокрЛП(pExtGroupDescription);
			EndIf;
		Else
			vGuestGroupObj.Description = СокрЛП(pExtGroupDescription);
		EndIf;
		If НЕ IsBlankString(pGroupCustomerName) Тогда
			vGuestGroupObj.Контрагент = cmGetCustomerByName(pGroupCustomerName);
		EndIf;
		vGuestGroupObj.Write();
		// Fill reference
		vGuestGroup = vGuestGroupObj.Ref;
	ElsIf Число(pExtGroupCode) Тогда
		vGuestGroup = Справочники.ГруппыГостей.FindByCode(Number(pExtGroupCode), False, , pHotelRef);
	EndIf;
	Return vGuestGroup;
EndFunction //cmGetGuestGroupByExternalCode

//-----------------------------------------------------------------------------
// Description: This API is used to create/update reservation from the external system.
//              Reservation will not be posted by default
// Parameters: External reservation data, External system code, Whether to post 
//             new reservation or write only, Returns error description if any
// Return value: Reservation object
//-----------------------------------------------------------------------------
Function cmWriteExternalReservationRow(pExtReservationCode, pExtGroupCode, pExtGroupDescription, pGroupCustomerName,  
                                       pReservationStatusCode, pPeriodFrom, pPeriodTo, pHotelCode, pRoomTypeCode, 
                                       pAccommodationTypeCode, pClientTypeCode, pRoomQuotaCode, pRoomRateCode,
                                       pCustomerName, pContractName, pAgentName, pContactPerson, 
                                       pNumberOfRooms, pNumberOfPersons, 
                                       pExtClientCode, pClientLastName, pClientFirstName, pClientSecondName, 
                                       pClientSexCode, pClientCitizenshipCode, pClientBirthDate, 
                                       pClientPhone, pClientFax, pClientEMail, pClientRemarks, pClientSendSMS = Неопределено, pRemarks, pCar, 
                                       pPlannedPaymentMethodCode, pCreateDate = Неопределено, pExternalSystemCode, pDoPosting = False, 
									   pPromoCode = "", rErrorDescription = "", pSkipNotification = False, 
									   pReservationNumber = "", pRoomReservation = Неопределено, pIgnoreCustomerChargingRules = False,
									   pLanguage = Неопределено, rOldReservationStatus = Неопределено, pTransferData = Неопределено, pExtraServices = Неопределено, 
									   pCreditCardData = Неопределено, pDiscountType = Неопределено, pDiscountSum = Неопределено, pRoomCode = "") Экспорт
	If TypeOf(pClientBirthDate) <> Type("Date") Тогда
		pClientBirthDate = '00010101';
	EndIf;
	vDocObj = Неопределено;
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Try to find marketing code
	vMarketingCode = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "КодМаркетинга", pExternalSystemCode);
	// Create new marketing code
	If НЕ ЗначениеЗаполнено(vMarketingCode) Тогда
		Try
			vMarketingCodeObj = Справочники.КодМаркетинга.CreateItem();
			vMarketingCodeObj.Гостиница = vHotel;
			vMarketingCodeObj.Description = СокрЛП(pExternalSystemCode);
			vMarketingCodeObj.Code = Left(СокрЛП(pExternalSystemCode), 5);
			vMarketingCodeObj.Write();
			vMarketingCode = vMarketingCodeObj.Ref;
		Except
		EndTry;
	EndIf;
	// Fill guest group external code
	vGuestGroup = Неопределено;
	If НЕ IsBlankString(pExtGroupCode) Тогда
		vGuestGroup = cmGetGuestGroupByExternalCode(vHotel, pExtGroupCode, pExtGroupDescription, pGroupCustomerName);
	EndIf;
	// Initialize occupation percents
	vOccupationPercents = Неопределено;
	// Try to get accommodation type
	vAccommodationType = Неопределено;
	If НЕ IsBlankString(pAccommodationTypeCode) Тогда
		vAccommodationType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ВидыРазмещения", pAccommodationTypeCode);
		// Reset reservation number
		If ЗначениеЗаполнено(vAccommodationType) And 
		  (vAccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.НомерРазмещения) Тогда
			pReservationNumber = "";
		ElsIf ЗначениеЗаполнено(vAccommodationType) And НЕ IsBlankString(pReservationNumber) Тогда
			vOneRoomDoc = cmGetOneRoomReservation(pReservationNumber, vGuestGroup);
			If ЗначениеЗаполнено(vOneRoomDoc) Тогда
				vOccupationPercents = vOneRoomDoc.OccupationPercents.Unload();
			EndIf;
		EndIf;
	EndIf;
	// Try to get discount type
	vDiscountType = Неопределено;
	If НЕ IsBlankString(pDiscountType) Тогда
		vDiscountType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыСкидок", pDiscountType);
	EndIf;
	// Try to find existing reservation with given external code
	If НЕ IsBlankString(pExtReservationCode) Тогда
		vDocRef = cmGetReservationByExternalCode(vHotel, pExtReservationCode);
	EndIf;
	If ЗначениеЗаполнено(vDocRef) Тогда
		// Log that we've found client by external code
		WriteLogEvent(NStr("en='Write external reservation';ru='Записать внешнюю бронь';de='Eine externe Reservierung einschreiben'"), EventLogLevel.Information, vDocRef.Metadata(), vDocRef, NStr("en='Reservation is found by external code!';ru='Бронь найдена по коду во внешней системе!';de='Die Reservierung wurde nach dem Code im externen System gefunden!'"));
		// Save current reservation status
		rOldReservationStatus = vDocRef.ReservationStatus;
		// Get reservation object
		vDocObj = vDocRef.GetObject();
		// Fill reservation status
		vReservationStatus = Справочники.СтатусБрони.EmptyRef();
		If ЗначениеЗаполнено(vHotel) Тогда
			vReservationStatus = vHotel.СтатусНовойБрониПоУмолчанию;
			If НЕ IsBlankString(pReservationStatusCode) Тогда
				vReservationStatus = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СтатусБрони", pReservationStatusCode);
			EndIf;
			If ЗначениеЗаполнено(vReservationStatus) And vDocObj.ReservationStatus <> vReservationStatus Тогда
				If НЕ vDocObj.ReservationStatus.ЭтоЗаезд Тогда
					vDocObj.ReservationStatus = vReservationStatus;
				EndIf;
			EndIf;
		EndIf;
		// Fill guest group external code
		If НЕ IsBlankString(pExtGroupCode) Тогда
			vDocObj.ГруппаГостей = vGuestGroup;
		EndIf;
	Else
		// Create new reservation
		vDocObj = Documents.Бронирование.CreateDocument();
		// Fill reservation hotel
		If ЗначениеЗаполнено(vHotel) And vHotel <> ПараметрыСеанса.ТекущаяГостиница Тогда
			vDocObj.Гостиница = vHotel;
			If IsBlankString(pReservationNumber) Тогда
				vDocObj.SetNewNumber();
			EndIf;
		EndIf;
		// Fill reservation number
		If НЕ IsBlankString(pReservationNumber) Тогда
			vDocObj.НомерДока = TrimR(pReservationNumber);
		EndIf;
		// Fill reservation status
		If НЕ IsBlankString(pReservationStatusCode) Тогда
			vDocObj.ReservationStatus = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СтатусБрони", pReservationStatusCode);
		EndIf;
		// Fill guest group external code
		If НЕ IsBlankString(pExtGroupCode) Тогда
			vDocObj.ГруппаГостей = vGuestGroup;
		Endif;
		// Fill other default atributes
		//vDocObj.pmFillAttributesWithDefaultValues();
		// Employee Фирма
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Фирма) Тогда
			vDocObj.Фирма = ПараметрыСеанса.ТекПользователь.Фирма;
		EndIf;
		// External code
		vDocObj.ExternalCode = СокрЛП(pExtReservationCode);
		// Create date
		If ЗначениеЗаполнено(pCreateDate) Тогда
			vDocObj.SetTime(AutoTimeMode.DontUse);
			vDocObj.ДатаДок = pCreateDate;
			If НЕ IsBlankString(pReservationNumber) Тогда
				vDocObj.ДатаДок = vDocObj.ДатаДок + 1;
			EndIf;
		EndIf;
	EndIf;
	// Check should we do chargings
	vDocObj.pmSetDoCharging();
	// Fill base reservation attributes
	vDocObj.CheckInDate = cm1SecondShift(pPeriodFrom);
	vDocObj.Продолжительность = 0; // will be calculated further
	vDocObj.ДатаВыезда = cm0SecondShift(pPeriodTo);
	If НЕ IsBlankString(pRoomTypeCode) Тогда
		vDocObj.ТипНомера = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыНомеров", pRoomTypeCode);
		If ЗначениеЗаполнено(vDocObj.ТипНомера) And ЗначениеЗаполнено(vDocObj.ТипНомера.BaseRoomType) Тогда
			vDocObj.ТипНомераРасчет = vDocObj.ТипНомера;
			vDocObj.ТипНомера = vDocObj.ТипНомера.BaseRoomType;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vAccommodationType) Тогда
		vDocObj.ВидРазмещения = vAccommodationType;
	EndIf;
	If ЗначениеЗаполнено(vDiscountType) Тогда
		vDocObj.ТипСкидки = vDiscountType;
		If vDiscountType.IsAmountDiscount And ЗначениеЗаполнено(pDiscountSum) Тогда
			If Число(pDiscountSum) Тогда
				vDocObj.СуммаСкидки = Number(pDiscountSum);
			EndIf;
		EndIf;
	EndIf;
	If НЕ IsBlankString(pClientTypeCode) Тогда
		vDocObj.ТипКлиента = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыКлиентов", pClientTypeCode);
	EndIf;
	If НЕ IsBlankString(pRoomRateCode) Тогда
		vDocObj.Тариф = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Тарифы", pRoomRateCode);
		vDocObj.ДатаЦены = '00010101';
	EndIf;
	If НЕ ЗначениеЗаполнено(vDocObj.Тариф) Тогда
		If ЗначениеЗаполнено(vDocObj.Гостиница) Тогда
			vDocObj.Тариф = vDocObj.Гостиница.Тариф;
			vDocObj.ДатаЦены = '00010101';
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vDocObj.ТипНомера) Тогда
		If ЗначениеЗаполнено(vDocObj.ТипНомера.Фирма) Тогда
			vDocObj.Фирма = vDocObj.ТипНомера.Фирма;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vDocObj.Тариф) Тогда
		If ЗначениеЗаполнено(vDocObj.Тариф.ИсточникИнфоГостиница) Тогда
			vDocObj.ИсточникИнфоГостиница = vDocObj.Тариф.ИсточникИнфоГостиница;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Тариф.МаркетингКод) Тогда
			vDocObj.МаркетингКод = vDocObj.Тариф.МаркетингКод;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Тариф.ТипКлиента) Тогда
			vDocObj.ТипКлиента = vDocObj.Тариф.ТипКлиента;
			vDocObj.СтрокаПодтверждения = vDocObj.Тариф.СтрокаПодтверждения;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Тариф.Фирма) Тогда
			vDocObj.Фирма = vDocObj.Тариф.Фирма;
		EndIf;
	EndIf;
	If НЕ IsBlankString(pPlannedPaymentMethodCode) Тогда
		vPaymentMethod = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СпособОплаты", pPlannedPaymentMethodCode);
		If ЗначениеЗаполнено(vPaymentMethod) Тогда
			vDocObj.PlannedPaymentMethod = vPaymentMethod;
		EndIf;
	EndIf;
	If НЕ IsBlankString(pCustomerName) Тогда
		If pCustomerName = "USE_CLIENT" Тогда
			If ЗначениеЗаполнено(vDocObj.ГруппаГостей) And vDocObj.ГруппаГостей.OneCustomerPerGuestGroup And ЗначениеЗаполнено(vDocObj.ГруппаГостей.Контрагент) Тогда
				vDocObj.Контрагент = vDocObj.ГруппаГостей.Контрагент;
			Else
				If НЕ IsBlankString(pPlannedPaymentMethodCode) Тогда
					vDocObj.Контрагент = cmGetCustomerByName(pClientLastName + " " + pClientFirstName + " " + pClientSecondName, pClientBirthDate, True, True, vDocObj.PlannedPaymentMethod);
				Else
					vDocObj.Контрагент = cmGetCustomerByName(pClientLastName + " " + pClientFirstName + " " + pClientSecondName, pClientBirthDate, True, True);
				EndIf;					
			EndIf;
		Else
			vDocObj.Контрагент = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Контрагенты", pCustomerName);
			If НЕ ЗначениеЗаполнено(vDocObj.Контрагент) Тогда
				vDocObj.Контрагент = cmGetCustomerByName(pCustomerName);
			EndIf;
		EndIf;
	EndIf;
	If НЕ IsBlankString(pContractName) Тогда
		vDocObj.Договор = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Договора", pContractName);
		If НЕ ЗначениеЗаполнено(vDocObj.Договор) Тогда
			vDocObj.Договор = cmGetContractByName(vDocObj.Контрагент, pContractName, False);
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Договор) Тогда
			vDocObj.Контрагент = vDocObj.Договор.Owner;
			If ЗначениеЗаполнено(vDocObj.Договор.Тариф) Тогда
				vDocObj.Тариф = vDocObj.Договор.Тариф;
			EndIf;
		EndIf;
	EndIf;
	If НЕ IsBlankString(pAgentName) Тогда
		vDocObj.Агент = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Контрагенты", pAgentName);
		If НЕ ЗначениеЗаполнено(vDocObj.Агент) Тогда
			vDocObj.Агент = cmGetCustomerByName(pAgentName);
			If ЗначениеЗаполнено(vDocObj.Агент) Тогда
				vDocObj.КомиссияАгента = vDocObj.Агент.КомиссияАгента;
				vDocObj.ВидКомиссииАгента = vDocObj.Агент.ВидКомиссииАгента;
				vDocObj.КомиссияАгентУслуги = vDocObj.Агент.КомиссияАгентУслуги;
			EndIf;
		EndIf;
	EndIf;
	If НЕ IsBlankString(pContactPerson) Тогда
		vDocObj.КонтактноеЛицо = СокрЛП(pContactPerson);
	EndIf;
	If ЗначениеЗаполнено(vDocObj.ReservationStatus) And НЕ vDocObj.ReservationStatus.ЭтоЗаезд Тогда
		If НЕ IsBlankString(pRoomQuotaCode) Тогда
			vDocObj.КвотаНомеров = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "КвотаНомеров", pRoomQuotaCode);
			If ЗначениеЗаполнено(vDocObj.КвотаНомеров) And ЗначениеЗаполнено(vDocObj.КвотаНомеров.Фирма) Тогда
				vDocObj.Фирма = vDocObj.КвотаНомеров.Фирма;
			EndIf;
		EndIf;
	EndIf;
	If pNumberOfRooms > 0 Тогда
		vDocObj.RoomQuantity = pNumberOfRooms;
	EndIf;
	If pNumberOfPersons > 0 Тогда
		vDocObj.КоличествоЧеловек = pNumberOfPersons;
	EndIf;
	vSourceOfBusiness = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ИсточИнфоГостиница", pExternalSystemCode);
	If ЗначениеЗаполнено(vSourceOfBusiness) And НЕ ЗначениеЗаполнено(vDocObj.ИсточникИнфоГостиница) Тогда
		vDocObj.ИсточникИнфоГостиница = vSourceOfBusiness;
	EndIf;
	If ЗначениеЗаполнено(vMarketingCode) And НЕ ЗначениеЗаполнено(vDocObj.МаркетингКод) Тогда
		vDocObj.МаркетингКод = vMarketingCode;
	EndIf;
	vIgnoreCustomerPaymentMethod = False;
	If НЕ IsBlankString(pPlannedPaymentMethodCode) Тогда
		vIgnoreCustomerPaymentMethod = True;
	EndIf;
	// Fill default values based on document attributes already filled
	If ЗначениеЗаполнено(vDocObj.Контрагент) Тогда
		vDocObj.ТипКонтрагента = vDocObj.Контрагент.ТипКонтрагента;
		If ЗначениеЗаполнено(vDocObj.ТипКонтрагента) Тогда
			If НЕ ЗначениеЗаполнено(vDocObj.RoomRateType) Тогда
				vDocObj.RoomRateType = vDocObj.ТипКонтрагента.RoomRateType;
			EndIf;
		EndIf;
		If IsBlankString(vDocObj.КонтактноеЛицо) Тогда
			If НЕ IsBlankString(vDocObj.Контрагент.КонтактноеЛицо) Тогда
				vDocObj.КонтактноеЛицо = TrimR(vDocObj.Контрагент.КонтактноеЛицо);
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Контрагент.PlannedPaymentMethod) And НЕ pIgnoreCustomerChargingRules And НЕ vIgnoreCustomerPaymentMethod Тогда
			vDocObj.PlannedPaymentMethod = vDocObj.Контрагент.PlannedPaymentMethod;
		EndIf;
		If НЕ ЗначениеЗаполнено(vDocObj.Агент) Or IsBlankString(pAgentName) Тогда
			If ЗначениеЗаполнено(vDocObj.Контрагент.Агент) Тогда
				vDocObj.Агент = vDocObj.Контрагент.Агент;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Контрагент.ВидКомиссииАгента) Тогда
				If НЕ ЗначениеЗаполнено(vDocObj.Агент) Тогда
					vDocObj.Агент = vDocObj.Контрагент;
				EndIf;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Агент) Тогда
			vDocObj.КомиссияАгента = vDocObj.Агент.КомиссияАгента;
			vDocObj.ВидКомиссииАгента = vDocObj.Агент.ВидКомиссииАгента;
			vDocObj.КомиссияАгентУслуги = vDocObj.Агент.КомиссияАгентУслуги;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Контрагент.Тариф) Тогда
			vDocObj.Тариф = vDocObj.Контрагент.Тариф;
			vDocObj.RoomRateServiceGroup = vDocObj.Контрагент.RoomRateServiceGroup;
			vDocObj.ДатаЦены = '00010101';
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Тариф) Тогда
			If ЗначениеЗаполнено(vDocObj.Тариф.ИсточникИнфоГостиница) Тогда
				vDocObj.ИсточникИнфоГостиница = vDocObj.Тариф.ИсточникИнфоГостиница;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.МаркетингКод) Тогда
				vDocObj.МаркетингКод = vDocObj.Тариф.МаркетингКод;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.ТипКлиента) Тогда
				vDocObj.ТипКлиента = vDocObj.Тариф.ТипКлиента;
				vDocObj.СтрокаПодтверждения = vDocObj.Тариф.СтрокаПодтверждения;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.Фирма) Тогда
				vDocObj.Фирма = vDocObj.Тариф.Фирма;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Контрагент.МаркетингКод) Тогда
			vDocObj.МаркетингКод = vDocObj.Контрагент.МаркетингКод;
			vDocObj.MarketingCodeConfirmationText = "";
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Контрагент.ИсточникИнфоГостиница) Тогда
			vDocObj.ИсточникИнфоГостиница = vDocObj.Контрагент.ИсточникИнфоГостиница;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Контрагент.ТипКлиента) Тогда
			vDocObj.ТипКлиента = vDocObj.Контрагент.ТипКлиента;
			vDocObj.СтрокаПодтверждения = vDocObj.Контрагент.СтрокаПодтверждения;
		EndIf;
		If НЕ IsBlankString(vDocObj.Контрагент.Примечания) And vDocObj.Контрагент.CopyRemarksToDocuments Тогда
			vDocObj.Примечания = СокрЛП(СокрЛП(vDocObj.Контрагент.Примечания) + Chars.LF + СокрЛП(vDocObj.Примечания));
		EndIf;
		If НЕ ЗначениеЗаполнено(vDocObj.Договор) And ЗначениеЗаполнено(vDocObj.Контрагент.Договор) Тогда
			vDocObj.Договор = vDocObj.Контрагент.Договор;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vDocObj.Договор) Тогда
		If ЗначениеЗаполнено(vDocObj.Договор.PlannedPaymentMethod) And НЕ pIgnoreCustomerChargingRules And НЕ vIgnoreCustomerPaymentMethod Тогда
			vDocObj.PlannedPaymentMethod = vDocObj.Договор.PlannedPaymentMethod;
		EndIf;
		If НЕ ЗначениеЗаполнено(vDocObj.Договор.Агент) Тогда
			If vDocObj.Агент = vDocObj.Контрагент Тогда
				If vDocObj.Договор.КомиссияАгента <> 0 Тогда
					vDocObj.КомиссияАгента = vDocObj.Договор.КомиссияАгента;
					vDocObj.ВидКомиссииАгента = vDocObj.Договор.ВидКомиссииАгента;
					vDocObj.КомиссияАгентУслуги = vDocObj.Договор.КомиссияАгентУслуги;
				EndIf;
			EndIf;
		Else
			If НЕ ЗначениеЗаполнено(vDocObj.Агент) Or IsBlankString(pAgentName) Тогда
				vDocObj.Агент = vDocObj.Договор.Агент;
				If vDocObj.Договор.КомиссияАгента <> 0 Тогда
					vDocObj.КомиссияАгента = vDocObj.Договор.КомиссияАгента;
					vDocObj.ВидКомиссииАгента = vDocObj.Договор.ВидКомиссииАгента;
					vDocObj.КомиссияАгентУслуги = vDocObj.Договор.КомиссияАгентУслуги;
				EndIf;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Договор.Тариф) Тогда
			vDocObj.Тариф = vDocObj.Договор.Тариф;
			vDocObj.RoomRateServiceGroup = vDocObj.Договор.RoomRateServiceGroup;
			vDocObj.ДатаЦены = '00010101';
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Тариф) Тогда
			If ЗначениеЗаполнено(vDocObj.Тариф.ИсточникИнфоГостиница) Тогда
				vDocObj.ИсточникИнфоГостиница = vDocObj.Тариф.ИсточникИнфоГостиница;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.МаркетингКод) Тогда
				vDocObj.МаркетингКод = vDocObj.Тариф.МаркетингКод;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.ТипКлиента) Тогда
				vDocObj.ТипКлиента = vDocObj.Тариф.ТипКлиента;
				vDocObj.СтрокаПодтверждения = vDocObj.Тариф.СтрокаПодтверждения;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.Фирма) Тогда
				vDocObj.Фирма = vDocObj.Тариф.Фирма;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Договор.Фирма) Тогда
			vDocObj.Фирма = vDocObj.Договор.Фирма;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Договор.МаркетингКод) Тогда
			vDocObj.МаркетингКод = vDocObj.Договор.МаркетингКод;
			vDocObj.MarketingCodeConfirmationText = "";
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Договор.ИсточникИнфоГостиница) Тогда
			vDocObj.ИсточникИнфоГостиница = vDocObj.Договор.ИсточникИнфоГостиница;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Договор.ТипКлиента) Тогда
			vDocObj.ТипКлиента = vDocObj.Договор.ТипКлиента;
			vDocObj.СтрокаПодтверждения = vDocObj.Договор.СтрокаПодтверждения;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vDocObj.Агент) Тогда
		If ЗначениеЗаполнено(vDocObj.Агент.МаркетингКод) Тогда
			vDocObj.МаркетингКод = vDocObj.Агент.МаркетингКод;
			vDocObj.MarketingCodeConfirmationText = "";
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Агент.ИсточникИнфоГостиница) Тогда
			vDocObj.ИсточникИнфоГостиница = vDocObj.Агент.ИсточникИнфоГостиница;
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Агент.ТипКлиента) Тогда
			vDocObj.ТипКлиента = vDocObj.Агент.ТипКлиента;
			vDocObj.СтрокаПодтверждения = vDocObj.Агент.СтрокаПодтверждения;
		EndIf;
	EndIf;
	// Try to find client by external code
	vGuestRef = Справочники.Клиенты.EmptyRef();
	// Create new client
	If НЕ IsBlankString(pClientLastName) Тогда
		vRC = cmWriteExternalClient(pExtClientCode, pExtReservationCode, 
									pClientLastName, pClientFirstName, pClientSecondName, 
									pClientSexCode, pClientCitizenshipCode, pClientBirthDate,
									pClientPhone, pClientFax, pClientEMail, pClientRemarks, pClientSendSMS,  
									pHotelCode, pExternalSystemCode, Справочники.Клиенты.ReservedGuests, 
									pLanguage, "XDTO");
		If IsBlankString(vRC.ErrorDescription) Тогда
			// Try to find client by external client code or by external system code
			If НЕ IsBlankString(vRC.ClientCode) Тогда
				vGuestRef = cmGetClientByCode(СокрЛП(vRC.ClientCode));
			EndIf;
		Else
			rErrorDescription = vRC.ErrorDescription;
			// Write log event
			WriteLogEvent(NStr("en='Write external reservation';ru='Записать внешнюю бронь';de='eine externe Reservierung einschreiben'"), EventLogLevel.Error, , , 
						  NStr("en='Error description: ';ru='Описание ошибки: ';de='Fehlerbeschreibung: '") + rErrorDescription);
			// Return nothing
			Return Неопределено;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vGuestRef) Тогда
		vDocObj.Клиент = vGuestRef;
		// Marketing code
		If ЗначениеЗаполнено(vGuestRef.МаркетингКод) Тогда
			vDocObj.МаркетингКод = vGuestRef.МаркетингКод;
			vDocObj.MarketingCodeConfirmationText = "";
		EndIf;
		// Source of business
		If ЗначениеЗаполнено(vGuestRef.ИсточникИнфоГостиница) Тогда
			vDocObj.ИсточникИнфоГостиница = vGuestRef.ИсточникИнфоГостиница;
		EndIf;
		// Client type
		If НЕ ЗначениеЗаполнено(vDocObj.ТипКлиента) Тогда
			If ЗначениеЗаполнено(vGuestRef.ТипКлиента) Тогда
				vDocObj.ТипКлиента = vGuestRef.ТипКлиента;
				vDocObj.СтрокаПодтверждения = vGuestRef.СтрокаПодтверждения;
			EndIf;
		EndIf;
		// ГруппаНомеров rate
		If ЗначениеЗаполнено(vDocObj.Клиент.Тариф) Тогда
			vDocObj.Тариф = vDocObj.Клиент.Тариф;
			vDocObj.RoomRateServiceGroup = vDocObj.Клиент.RoomRateServiceGroup;
			vDocObj.ДатаЦены = '00010101';
		EndIf;
		If ЗначениеЗаполнено(vDocObj.Тариф) Тогда
			If ЗначениеЗаполнено(vDocObj.Тариф.ИсточникИнфоГостиница) Тогда
				vDocObj.ИсточникИнфоГостиница = vDocObj.Тариф.ИсточникИнфоГостиница;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.МаркетингКод) Тогда
				vDocObj.МаркетингКод = vDocObj.Тариф.МаркетингКод;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.ТипКлиента) Тогда
				vDocObj.ТипКлиента = vDocObj.Тариф.ТипКлиента;
				vDocObj.СтрокаПодтверждения = vDocObj.Тариф.СтрокаПодтверждения;
			EndIf;
			If ЗначениеЗаполнено(vDocObj.Тариф.Фирма) Тогда
				vDocObj.Фирма = vDocObj.Тариф.Фирма;
			EndIf;
		EndIf;
	EndIf;
	// Transfer
	If pTransferData <> Неопределено AND pTransferData.Need Тогда
		// Try to get transfer service according to place of transfer
		vTranseferService = cmGetObjectRefByExternalSystemCode(vDocObj.Гостиница, pExternalSystemCode, "Услуги", pTransferData.Place);
		If ЗначениеЗаполнено(vTranseferService) Тогда
			vCurRow = vDocObj.Услуги.Add();
			vCurRow.УчетнаяДата = pTransferData.ДатаДок;
			vCurRow.IsManual = True;
			vCurRow.Услуга = vTranseferService;
			vCurRow.Примечания = Format(pTransferData.ДатаДок,"DF='dd.MM.yyyy HH:mm'")+", "+pTransferData.Place+", "+pTransferData.Примечания;
			vCurRow.ЕдИзмерения = vCurRow.Услуга.ЕдИзмерения;
			vChargingRules = vDocObj.ChargingRules.Unload();
			cmAddGuestGroupChargingRules(vChargingRules, vDocObj.ГруппаГостей);
			// Fill folio and folio currency for service
			vDocObj.pmSetServiceFolioBasedOnChargingRules(vCurRow, vChargingRules, True);
			vCurRow.ТипДняКалендаря = cmGetCalendarDayType(vDocObj.Тариф, vCurRow.УчетнаяДата, vDocObj.CheckInDate, vDocObj.ДатаВыезда);
	        vCurRow.Фирма = vCurRow.СчетПроживания.Фирма;
			// Get service prices
			vTPrices = vCurRow.Услуга.GetObject().pmGetServicePrices(vDocObj.Гостиница,vCurRow.УчетнаяДата,vDocObj.ТипКлиента);
			If vTPrices.Count() > 0 Тогда
				vCurRow.Количество = 1;
				vCurRow.Цена = cmConvertCurrencies(vTPrices[0].Цена, vTPrices[0].Валюта, , vCurRow.ВалютаЛицСчета, , vCurRow.УчетнаяДата, vDocObj.Гостиница);
				vCurRow.СтавкаНДС = vTPrices[0].СтавкаНДС;
				vCurRow.Сумма = vCurRow.Цена;
			Else
				vCurRow.Количество = 1;
				vCurRow.Цена = 0;
				vCurRow.СтавкаНДС = ?(ЗначениеЗаполнено(vCurRow.Фирма),vCurRow.Фирма.СтавкаНДС,vDocObj.Фирма.СтавкаНДС);
				vCurRow.Сумма = 0;
			EndIf;
			vCurRow.СуммаНДС = cmCalculateVATSum(vCurRow.СтавкаНДС, vCurRow.Сумма);
		Else
			// Transfer service is not found so just write a remarks to reservation
			pRemarks = Format(pTransferData.ДатаДок, "DF='dd.MM.yyyy HH:mm'") + ", " + СокрЛП(pTransferData.Place) + Chars.LF + 
				              СокрЛП(pTransferData.Примечания)+Chars.CR+СокрЛП(pRemarks);
		EndIf;		
	EndIf;
	// Extra services
	If pExtraServices <> Неопределено Тогда
		For Each vExtraServicesItem In pExtraServices Do
			vExtraServiceStruct = vExtraServicesItem.Value;
			// Try to get extra service item reference
			vExtraServicePackage = cmGetObjectRefByExternalSystemCode(vDocObj.Гостиница, pExternalSystemCode, "ПакетыУслуг", vExtraServiceStruct.Услуга);
			If ЗначениеЗаполнено(vExtraServicePackage) Тогда
				vIsRemoved = Неопределено;
				vExtraServiceStruct.Property("IsRemoved", vIsRemoved);
				If vIsRemoved = Неопределено Тогда
					vIsRemoved = False;
				EndIf;
				If НЕ vIsRemoved Тогда
					vIsSetAsMainSP = False;
					If НЕ ЗначениеЗаполнено(vDocObj.ServicePackage) Тогда
						vDocObj.ServicePackage = vExtraServicePackage;
						vIsSetAsMainSP = True;
					EndIf;
					vSPIsFound = False;
					spi = 0;
					While spi < vDocObj.ПакетыУслуг.Count() Do
						vSPRow = vDocObj.ПакетыУслуг.Get(spi);
						If ЗначениеЗаполнено(vSPRow.ServicePackage) And vSPRow.ServicePackage = vExtraServicePackage Тогда
							If vIsSetAsMainSP Тогда
								vDocObj.ПакетыУслуг.Delete(spi);
								vSPIsFound = True;
								Continue;
							Else
								vSPIsFound = True;
							EndIf;
						EndIf;
						spi = spi + 1;
					EndDo;
					If НЕ vSPIsFound And НЕ vIsSetAsMainSP Тогда
						vCurRow = vDocObj.ПакетыУслуг.Add();
						vCurRow.ServicePackage = vExtraServicePackage;
					EndIf;
				Else
					If ЗначениеЗаполнено(vDocObj.ServicePackage) And vDocObj.ServicePackage = vExtraServicePackage Тогда
						vDocObj.ServicePackage = Неопределено;
					EndIf;
					spi = 0;
					While spi < vDocObj.ПакетыУслуг.Count() Do
						vSPRow = vDocObj.ПакетыУслуг.Get(spi);
						If ЗначениеЗаполнено(vSPRow.ServicePackage) And vSPRow.ServicePackage = vExtraServicePackage Тогда
							vDocObj.ПакетыУслуг.Delete(spi);
						Else
							spi = spi + 1;
						EndIf;
					EndDo;
				EndIf;
			Else
				// Try to get extra service item reference
				vExtraService = cmGetObjectRefByExternalSystemCode(vDocObj.Гостиница, pExternalSystemCode, "Услуги", vExtraServiceStruct.Услуга);
				If ЗначениеЗаполнено(vExtraService) Тогда
					vChargeDate = vExtraServiceStruct.ChargeDate;
					If НЕ ЗначениеЗаполнено(vChargeDate) Тогда
						vChargeDate = vDocObj.CheckInDate;
					EndIf;
					vCurRow = vDocObj.Услуги.Add();
					vCurRow.УчетнаяДата = vChargeDate;
					vCurRow.IsManual = True;
					vCurRow.Услуга = vExtraService;
					If ЗначениеЗаполнено(vExtraServiceStruct.Примечания) Тогда
						vCurRow.Примечания = Format(vChargeDate, "DF='dd.MM.yyyy HH:mm'")+", "+СокрЛП(vExtraServiceStruct.Примечания);
					EndIf;
					vCurRow.ЕдИзмерения = vExtraService.ЕдИзмерения;
					vChargingRules = vDocObj.ChargingRules.Unload();
					cmAddGuestGroupChargingRules(vChargingRules, vDocObj.ГруппаГостей);
					// Fill folio and folio currency for service
					vDocObj.pmSetServiceFolioBasedOnChargingRules(vCurRow, vChargingRules, True);
					vCurRow.ТипДняКалендаря = cmGetCalendarDayType(vDocObj.Тариф, vCurRow.УчетнаяДата, vDocObj.CheckInDate, vDocObj.ДатаВыезда);
			        vCurRow.Фирма = vCurRow.СчетПроживания.Фирма;
					// Get service price currency
					vPriceCurrency = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Валюты", vExtraServiceStruct.Валюта);
					If НЕ ЗначениеЗаполнено(vPriceCurrency) Тогда
						If ЗначениеЗаполнено(vHotel.ВалютаЛицСчета) Тогда
							vPriceCurrency = vHotel.ВалютаЛицСчета;
						Else
							ВызватьИсключение NStr("en='Extra service currency not found! ';ru='Валюта доп. услуги не найдена по коду! ';de='Währung der zus. Dienstleistung wurde nicht nach dem Code gefunden! '") + vExtraServiceStruct.Валюта;
						EndIf;
					EndIf;
					// Get service VAT rate
					vTPrices = vCurRow.Услуга.GetObject().pmGetServicePrices(vDocObj.Гостиница, vCurRow.УчетнаяДата, vDocObj.ТипКлиента);
					If vTPrices.Count() > 0 Тогда
						vCurRow.СтавкаНДС = vTPrices[0].СтавкаНДС;
					Else				
						ВызватьИсключение NStr("en='Extra service VAT rate is not defined! ';ru='Для доп. услуги не определена ставка НДС! ';de='Für die zusätzliche Dienstleistung ist kein MwSt.-Satz festgelegt! '") + vCurRow.Услуга;
					EndIf;			
					vQuantity = vExtraServiceStruct.Количество;
					If НЕ ЗначениеЗаполнено(vQuantity) Тогда
						vQuantity = 1;
					EndIf;
					vCurRow.Количество = vQuantity;
					vCurRow.Цена = cmConvertCurrencies(vExtraServiceStruct.Цена, vPriceCurrency, , vCurRow.ВалютаЛицСчета, , vCurRow.УчетнаяДата, vDocObj.Гостиница);
					vCurRow.Сумма = Round(vCurRow.Цена * vCurRow.Количество, 2);
					vCurRow.СуммаНДС = cmCalculateVATSum(vCurRow.СтавкаНДС, vCurRow.Сумма);
				Else
					ВызватьИсключение NStr("en='Extra service not found! ';ru='Доп. услуга не найдена по коду! ';de='Zusätzliche Dienstleistung wurde nach dem Code nicht gefunden! '") + vExtraServiceStruct.Услуга;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	// Credit card data
	If pCreditCardData <> Неопределено And ЗначениеЗаполнено(vDocObj.Клиент) Тогда
		// Search cards with given owner and number
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	КредитныеКарты.Ref AS CreditCard
		|FROM
		|	Catalog.КредитныеКарты AS CreditCards
		|WHERE
		|	КредитныеКарты.CardOwner = &qCardOwner
		|	AND КредитныеКарты.CardNumber = &qCardNumber
		|	AND КредитныеКарты.DeletionMark = FALSE";
		vQry.SetParameter("qCardOwner", vDocObj.Клиент);
		vQry.SetParameter("qCardNumber", СокрЛП(pCreditCardData.CardNumber));
		vCards = vQry.Execute().Unload();
		vCreditCardRef = Неопределено;
		If vCards.Count() > 0 Тогда
			// Return first found
			vCreditCardRef = vCards.Get(0).CreditCard;
		Else
			// Create new card if necessary
			vCardObj = Справочники.КредитныеКарты.CreateItem();
			vCardObj.CardOwner = vDocObj.Клиент;
			vCardObj.Description = cmGetCreditCardDescription(СокрЛП(pCreditCardData.CardNumber));
			vCardObj.CardNumber = СокрЛП(pCreditCardData.CardNumber);
			vCardObj.CardHolder = СокрЛП(pCreditCardData.CardHolder);
			vCardObj.CardValidTillDate = pCreditCardData.CardValidTillDate;
			vCardObj.CardSecurityCode = СокрЛП(pCreditCardData.CardSecurityCode);
			vCardObj.Автор = ПараметрыСеанса.ТекПользователь;
			vCardObj.CreateDate = CurrentDate();
			vCardObj.Write();
			vCreditCardRef = vCardObj.Ref;
		EndIf;
		If ЗначениеЗаполнено(vCreditCardRef) Тогда
			vDocObj.CreditCard = vCreditCardRef;
		EndIf;
	EndIf;
	// Contacts
	vDocObj.Телефон = СокрЛП(pClientPhone);
	vDocObj.Fax = СокрЛП(pClientFax);
	vDocObj.EMail = СокрЛП(pClientEMail);
	// Reservation remarks and car description
	vDocObj.Примечания = СокрЛП(pRemarks);
	vDocObj.Car = СокрЛП(pCar);
	// Call API to fill duration
	vDocObj.Продолжительность = vDocObj.pmCalculateDuration();
	// Calculate discounts
	vDocObj.pmSetDiscounts();
	If НЕ IsBlankString(pPromoCode) Тогда
		vPromoDiscountType = Неопределено;
		// Try to find discount card by promo code
		vPromoDiscountCard = Справочники.ДисконтныеКарты.FindByAttribute("Identifier", СокрЛП(pPromoCode));
		If ЗначениеЗаполнено(vPromoDiscountCard) And НЕ vPromoDiscountCard.DeletionMark And vPromoDiscountCard.ValidFrom < vDocObj.ДатаВыезда And (vPromoDiscountCard.ValidTo = '00010101' Or vPromoDiscountCard.ValidTo > vDocObj.CheckInDate) Тогда
			vPromoDiscountType = vPromoDiscountCard.ТипСкидки;
		EndIf;
		// Try to find discount type by promo code
		If НЕ ЗначениеЗаполнено(vPromoDiscountType) Тогда
			vPromoDiscountType = Справочники.ТипыСкидок.FindByCode(СокрЛП(pPromoCode));
		EndIf;
		If ЗначениеЗаполнено(vPromoDiscountType) And НЕ vPromoDiscountType.DeletionMark And НЕ vPromoDiscountType.IsFolder Тогда
			vDiscountTypeIsActive = True;
			If ЗначениеЗаполнено(vPromoDiscountType.DateValidFrom) And vDocObj.CheckInDate < BegOfDay(vPromoDiscountType.DateValidFrom) Тогда
				vDiscountTypeIsActive = False;
			ElsIf ЗначениеЗаполнено(vPromoDiscountType.DateValidTo) And vDocObj.ДатаВыезда > EndOfDay(vPromoDiscountType.DateValidTo) Тогда
				vDiscountTypeIsActive = False;
			EndIf;
			If vDiscountTypeIsActive Тогда
				vDocObj.ДисконтКарт = vPromoDiscountCard;
				vDocObj.ТипСкидки = vPromoDiscountType;
				vDocObj.DiscountServiceGroup = vDocObj.ТипСкидки.DiscountServiceGroup;
				vDiscountTypeObj = vDocObj.ТипСкидки.GetObject();
				vDocObj.Скидка = vDiscountTypeObj.pmGetDiscount(vDocObj.CheckInDate, , vDocObj.Гостиница);
				For Each vRRRow In vDocObj.Тарифы Do
					vRRRow.Скидка = "";
				EndDo;
			EndIf;
		EndIf;
	EndIf;
	// Try to find previous reservation to be used as template for guest and charging rules
	vPrevReservation = cmGetPreviousReservation(vDocObj.ГруппаГостей, vDocObj.CheckInDate, vDocObj.ВидРазмещения, , vDocObj.Клиент);
	If ЗначениеЗаполнено(vPrevReservation) Тогда
		// Fill bound attributes
		cmFillAttributesFromParentDocument(vDocObj, vPrevReservation, True);
	Else
		If ЗначениеЗаполнено(pRoomReservation) And ЗначениеЗаполнено(vDocObj.ВидРазмещения) And vDocObj.ВидРазмещения.НачислятьНаЛицевойСчет Тогда
			// Use folios from the one ГруппаНомеров document
			cmUseParentChargingRules(vDocObj, pRoomReservation, True);
		Else
			// Call API to fill default charging rules
			If НЕ pIgnoreCustomerChargingRules Тогда
				vDocObj.pmLoadChargingRules(?(ЗначениеЗаполнено(vDocObj.Договор), vDocObj.Договор, vDocObj.Контрагент));
			EndIf;
			// Fill charging rules according to the payment method selected
			If ЗначениеЗаполнено(vDocObj.PlannedPaymentMethod) Тогда
				// Get first charging rules row
				v1CRRow = vDocObj.ChargingRules.Get(0);
				// Check planned payment method
				If vDocObj.PlannedPaymentMethod.IsByBankTransfer Тогда
					If ЗначениеЗаполнено(vDocObj.Контрагент) Тогда
						If ЗначениеЗаполнено(v1CRRow.Owner) And 
						   (v1CRRow.Owner = vDocObj.Контрагент Or v1CRRow.Owner = vDocObj.Договор) Тогда
							// Update folio payment method to the document one
							vFolioObj = v1CRRow.ChargingFolio.GetObject();
							vFolioObj.СпособОплаты = vDocObj.PlannedPaymentMethod;
							vFolioObj.Write(DocumentWriteMode.Write);
						Else
							// Create new folio and take parameters from the hotel
							If НЕ pIgnoreCustomerChargingRules Тогда
								vFolioObj = Documents.СчетПроживания.CreateDocument();
								cmFillFolioFromTemplate(vFolioObj, Неопределено, vDocObj.Гостиница, vDocObj.ДатаДок);
								vFolioObj.ДокОснование = vDocObj.Ref;
								vFolioObj.Контрагент = vDocObj.Контрагент;
								vFolioObj.Договор = vDocObj.Договор;
								vFolioObj.Агент = vDocObj.Агент;
								vFolioObj.ГруппаГостей = vDocObj.ГруппаГостей;
								vFolioObj.ВалютаЛицСчета = vDocObj.Контрагент.ВалютаРасчетов;
								vFolioObj.СпособОплаты = vDocObj.PlannedPaymentMethod;
								vFolioObj.Write(DocumentWriteMode.Write);
								// Add this folio to the reservation charging rules
								vCR = vDocObj.ChargingRules.Вставить(0);
								vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InRate;
								If ЗначениеЗаполнено(vDocObj.Договор) Тогда
									vCR.Owner = vDocObj.Договор;
								Else
									vCR.Owner = vDocObj.Контрагент;
								EndIf;
								vCR.ChargingFolio = vFolioObj.Ref;
							EndIf;
						EndIf;
					EndIf;
				Else
					If ЗначениеЗаполнено(v1CRRow.Owner) And 
					   (v1CRRow.Owner = vDocObj.Контрагент Or v1CRRow.Owner = vDocObj.Договор) And
					   ЗначениеЗаполнено(v1CRRow.ChargingFolio.СпособОплаты) And 
					   v1CRRow.ChargingFolio.СпособОплаты.IsByBankTransfer Тогда
						// Delete this charging rules row
						If vDocObj.ChargingRules.Count() > 1 Тогда
							vDocObj.ChargingRules.Delete(0);
						EndIf;
					EndIf;
					// Get first charging rules row
					v1CRRow = vDocObj.ChargingRules.Get(0);
					// Update folio payment method to the document one
					vFolioObj = v1CRRow.ChargingFolio.GetObject();
					vFolioObj.СпособОплаты = vDocObj.PlannedPaymentMethod;
					vFolioObj.Write(DocumentWriteMode.Write);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	// Load occupation percents
	If vOccupationPercents <> Неопределено Тогда
		vDocObj.OccupationPercents.Load(vOccupationPercents);
	EndIf;
	// Calculate resources
	//vDocObj.//pmCalculateResources();
	// Fill ГруппаНомеров
	If НЕ IsBlankString(pRoomCode) Тогда
		vDocObj.НомерРазмещения = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "НомернойФонд", pRoomCode);
	Else
		If НЕ ЗначениеЗаполнено(vDocObj.НомерРазмещения) And ЗначениеЗаполнено(vDocObj.ВидРазмещения) And vDocObj.ВидРазмещения.ТипРазмещения = Перечисления.ВидыРазмещений.НомерРазмещения Тогда
			vDocObj.НомерРазмещения = cmGetDefaultRoom(vDocObj.КоличествоМест, vDocObj.Гостиница, vDocObj.Фирма, vDocObj.КвотаНомеров, vDocObj.ТипНомера, vDocObj.CheckInDate, vDocObj.ДатаВыезда);
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vDocObj.НомерРазмещения) Тогда
		If ЗначениеЗаполнено(vDocObj.НомерРазмещения.Фирма) Тогда
			vDocObj.Фирма = vDocObj.НомерРазмещения.Фирма;
		EndIf;
	EndIf;
	// Calculate services
	vDocObj.pmCalculateServices();
	// Set planned payment method
	vDocObj.pmSetPlannedPaymentMethod();
	// Write document
	If pDoPosting Тогда
		vDocObj.Write(DocumentWriteMode.Posting);
	Else
		If vDocObj.Posted Тогда
			vDocObj.Write(DocumentWriteMode.Posting);
		Else
			vDocObj.Write(DocumentWriteMode.Write);
		EndIf;
	EndIf;
	// Save data to the reservation change history
	vDocObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
	// Write guest group attachment that reservation was received
	vSkipNotification = pSkipNotification;
	If НЕ vSkipNotification And ЗначениеЗаполнено(vDocObj.ГруппаГостей.Клиент) And 
	   НЕ IsBlankString(vDocObj.ГруппаГостей.Клиент.EMail) And 
	   ЗначениеЗаполнено(vDocObj.ReservationStatus) Тогда
		cmWriteReservationConfirmationGuestGroupAttachment(vDocObj);	   
	EndIf;
	// Return
	Return vDocObj;
EndFunction //cmWriteExternalReservationRow

//-----------------------------------------------------------------------------
// Description: This API is used to write reservation confirmation print form to the guest group attachments information register
// Parameters: External reservation object, Language, 
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmWriteReservationConfirmationGuestGroupAttachment(vDocObj) Экспорт
	vHotel = vDocObj.Гостиница;
	vLanguage = vHotel.Language;
	If ЗначениеЗаполнено(vDocObj.ГруппаГостей.Клиент.Language) Тогда
		vLanguage = vDocObj.ГруппаГостей.Клиент.Language;
	EndIf;
	// Print reservation confirmation
	vConfirmationSpreadsheet = New SpreadsheetDocument();
	vObjectPrintForm = Справочники.ПечатныеФормы.ReservationPrintConfirmationRu;
	If vLanguage = Справочники.Локализация.EN Тогда
		vObjectPrintForm = Справочники.ПечатныеФормы.ReservationPrintConfirmationEn;
	ElsIf vLanguage = Справочники.Локализация.DE Тогда
		vObjectPrintForm = Справочники.ПечатныеФормы.ReservationPrintConfirmationDe;
	EndIf;
	If ЗначениеЗаполнено(vObjectPrintForm.ExternalProcessing) Тогда
		vExtDataProcessor = cmGetExternalDataProcessorObject(vObjectPrintForm.ExternalProcessing);
		vExtDataProcessor.pmPrintConfirmation(vConfirmationSpreadsheet, vDocObj.Ref, Неопределено, 0, Справочники.НаборыУслуг.EmptyRef(), False, False, vLanguage, vObjectPrintForm);
	Else
		vDocObj.pmPrintConfirmation(vConfirmationSpreadsheet, vDocObj.Ref, Неопределено, 0, Справочники.НаборыУслуг.EmptyRef(), False, vLanguage, vObjectPrintForm);
	EndIf;
	// Save reservation confirmation to the temp PDF file
	vConfirmationFileName = StrReplace(vDocObj.Ref.Metadata().Presentation() + " " + Format(vDocObj.ГруппаГостей.Code, "ND=12; NFD=0; NG="), " ", "_") + ".pdf";
	vConfirmationFilePath = cmGetFullFileName(vConfirmationFileName, TempFilesDir());
	vConfirmationSpreadsheet.Write(vConfirmationFilePath, SpreadsheetDocumentFileType.PDF);
	// Add record to guest group attachements
	vGrpAttachmentsRecPeriod = CurrentDate();
	vGrpAttachmentsRecMgr = InformationRegisters.ДокументыГруппыСведения.CreateRecordManager();
	// Try to find period without other attachments
	vGrpAttachmentsRecMgr.Period = vGrpAttachmentsRecPeriod;
	vGrpAttachmentsRecMgr.ГруппаГостей = vDocObj.ГруппаГостей;
	vGrpAttachmentsRecMgr.Read();
	While vGrpAttachmentsRecMgr.Selected() Do
		vGrpAttachmentsRecPeriod = vGrpAttachmentsRecPeriod + 1;
		vGrpAttachmentsRecMgr.Period = vGrpAttachmentsRecPeriod;
		vGrpAttachmentsRecMgr.ГруппаГостей = vDocObj.ГруппаГостей;
		vGrpAttachmentsRecMgr.Read();
	EndDo;
	// Create new attachment using period found before
	vGrpAttachmentsRecMgr.Period = vGrpAttachmentsRecPeriod;
	vGrpAttachmentsRecMgr.ГруппаГостей = vDocObj.ГруппаГостей;
	vGrpAttachmentsRecMgr.Fax = vDocObj.ГруппаГостей.Клиент.Fax;
	vGrpAttachmentsRecMgr.EMail = vDocObj.ГруппаГостей.Клиент.EMail;
	vGrpAttachmentsRecMgr.AttachmentStatus = Перечисления.AttachmentStatuses.Ready;
	vGrpAttachmentsRecMgr.AttachmentType = Перечисления.AttachmentTypes.EMail;
	vGrpAttachmentsRecMgr.Примечания = vHotel.GetObject().pmGetHotelPrintName(vLanguage) + "Бронь №" + Format(vDocObj.ГруппаГостей.Code, "ND=12; NFD=0; NG=") + ", статус '" + 
	                                vDocObj.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage);
	vGrpAttachmentsRecMgr.DocumentText = "Автоматизированная система рассылки уведомлений об изменении статусов брони:'" + Chars.LF + Chars.LF +"Ваша бронь НомерРазмещения " + Format(vDocObj.ГруппаГостей.Code, "ND=12; NFD=0; NG=") + " создана и успешно обработана!'" + Chars.LF + Chars.LF + 
	                                     ?(ЗначениеЗаполнено(vDocObj.Клиент), "Клиент: " + СокрЛП(vDocObj.Клиент.FullName) + Chars.LF, "") + 
	                                     ?(ЗначениеЗаполнено(vDocObj.CheckInDate) And ЗначениеЗаполнено(vDocObj.ДатаВыезда), "Период проживания: "+ Format(vDocObj.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - "  + Format(vDocObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + Chars.LF, "") + 
										 "Тип номера: " + vDocObj.ТипНомера.GetObject().pmGetRoomTypeDescription(vLanguage) + Chars.LF + Chars.LF + 
										 "Статус брони установлен на " + vDocObj.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage) + Chars.LF + Chars.LF + 
										 СокрЛП(cmGetReservationConditions(vDocObj, vLanguage)) + Chars.LF + Chars.LF + 
										 СокрЛП(vDocObj.Гостиница.GetObject().pmGetHotelPostAddressPresentation(vLanguage)) + Chars.LF + Chars.LF + 
										 СокрЛП(vDocObj.Гостиница.GetObject().pmGetHotelHowToDriveToTheHotelDescription(vLanguage)) + Chars.LF + Chars.LF + "С уважением," + Chars.LF + 
										 vHotel.GetObject().pmGetHotelPrintName(vLanguage) + Chars.LF + 
										 ПараметрыСеанса.ИмяКонфигурации;
	vFile = New File(vConfirmationFilePath);
	If vFile.Exist() And vFile.IsFile() Тогда
		vGrpAttachmentsRecMgr.FileName = vConfirmationFileName;
		vGrpAttachmentsRecMgr.FileLoadTime = CurrentDate();
		vGrpAttachmentsRecMgr.FileLastChangeTime = vFile.GetModificationTime();
		vBinary = New BinaryData(vConfirmationFilePath);
		vGrpAttachmentsRecMgr.ExtFile = New ValueStorage(vBinary);
		DeleteFiles(vConfirmationFilePath);
	EndIf;
	// Call user exit procedure to give possibility to override message subject and message text
	vUserExitProc = Справочники.ВнешниеОбработки.WriteExternalReservationConfirmation;
	If ЗначениеЗаполнено(vUserExitProc) Тогда
		If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
			If НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
				Execute(СокрЛП(vUserExitProc.Algorithm));
			EndIf;
		EndIf;
	EndIf;
	// Write attachment
	vGrpAttachmentsRecMgr.Write();
КонецПроцедуры //cmWriteReservationConfirmationGuestGroupAttachment

//-----------------------------------------------------------------------------
// Description: This API is used to write reservation confirmation print form to the guest group attachments information register
// Parameters: External reservation object, Language, 
// Return value: None
//-----------------------------------------------------------------------------
Function cmWriteReservationInvoiceGuestGroupAttachment(vDocObj) Экспорт
	// Get hotel and language
	vHotel = vDocObj.Гостиница;
	vLanguage = vHotel.Language;
	If ЗначениеЗаполнено(vDocObj.Контрагент.Language) Тогда
		vLanguage = vDocObj.Контрагент.Language;
	EndIf;
	
	// Create and write guest group invoice object
	vInvoiceObj = Documents.СчетНаОплату.CreateDocument();
	vInvoiceObj.Fill(vDocObj.Ref);
	vInvoiceObj.ДокОснование = Неопределено;
	vInvoiceObj.Fill(vDocObj.ГруппаГостей);
	vBase64Text = "";
	If vInvoiceObj.Услуги.Count() = 0 Тогда
		Return vBase64Text;
	EndIf;
	vInvoiceObj.PrintWithCompanyStamp = True;
	vInvoiceObj.Write(DocumentWriteMode.Posting);
		
	// Print guest group invoice
	vInvoiceSpreadsheet = New SpreadsheetDocument();
	vObjectPrintForm = Справочники.ПечатныеФормы.InvoicePrintShortInvoiceGroupByServiceRu;
	If vLanguage = Справочники.Локализация.EN Тогда
		vObjectPrintForm = Справочники.ПечатныеФормы.InvoicePrintShortInvoiceGroupByServiceEn;
	ElsIf vLanguage = Справочники.Локализация.DE Тогда
		vObjectPrintForm = Справочники.ПечатныеФормы.InvoicePrintShortInvoiceGroupByServiceDe;
	EndIf;
	mInvoiceNumber = "";
	If ЗначениеЗаполнено(vObjectPrintForm.ExternalProcessing) Тогда
		vExtDataProcessor = cmGetExternalDataProcessorObject(vObjectPrintForm.ExternalProcessing);
		vExtDataProcessor.pmPrintInvoice(vInvoiceSpreadsheet, vInvoiceObj.Ref, vLanguage, "ByService", vObjectPrintForm, mInvoiceNumber);
	Else
		//vInvoiceObj.pmPrintInvoiceShort(vInvoiceSpreadsheet, vLanguage, "ByService", vObjectPrintForm, mInvoiceNumber);
	EndIf;
	
	// Save invoice form to the temp PDF file
	vInvoiceFileName = StrReplace(StrReplace(StrReplace(vInvoiceObj.Ref.Metadata().Presentation() + " " + cmGetDocumentNumberPresentation(vInvoiceObj.НомерДока), " ", "_"), "/", "-"), "\", "-") + ".pdf";
	vInvoiceFilePath = cmGetFullFileName(vInvoiceFileName, TempFilesDir());
	vInvoiceSpreadsheet.Write(vInvoiceFilePath, SpreadsheetDocumentFileType.PDF);
	vBD = New BinaryData(vInvoiceFilePath);
	vBase64Text = Base64String(vBD);
	
	// Add record to guest group attachements
	vGrpAttachmentsRecPeriod = CurrentDate();
	vGrpAttachmentsRecMgr = InformationRegisters.ДокументыГруппыСведения.CreateRecordManager();
	// Try to find period without other attachments
	vGrpAttachmentsRecMgr.Period = vGrpAttachmentsRecPeriod;
	vGrpAttachmentsRecMgr.ГруппаГостей = vInvoiceObj.ГруппаГостей;
	vGrpAttachmentsRecMgr.Read();
	While vGrpAttachmentsRecMgr.Selected() Do
		vGrpAttachmentsRecPeriod = vGrpAttachmentsRecPeriod + 1;
		vGrpAttachmentsRecMgr.Period = vGrpAttachmentsRecPeriod;
		vGrpAttachmentsRecMgr.ГруппаГостей = vInvoiceObj.ГруппаГостей;
		vGrpAttachmentsRecMgr.Read();
	EndDo;
	// Create new attachment using period found before
	vGrpAttachmentsRecMgr.Period = vGrpAttachmentsRecPeriod;
	vGrpAttachmentsRecMgr.ГруппаГостей = vInvoiceObj.ГруппаГостей;
	vGrpAttachmentsRecMgr.Fax = vInvoiceObj.Контрагент.Fax;
	vGrpAttachmentsRecMgr.EMail = vInvoiceObj.Контрагент.EMail;
	vGrpAttachmentsRecMgr.AttachmentStatus = Перечисления.AttachmentStatuses.Ready;
	vGrpAttachmentsRecMgr.AttachmentType = Перечисления.AttachmentTypes.EMail;
	vGrpAttachmentsRecMgr.Примечания = vHotel.GetObject().pmGetHotelPrintName(vLanguage) +"Счет на оплату № " + cmGetDocumentNumberPresentation(vInvoiceObj.НомерДока) + " по брони № " + Format(vInvoiceObj.ГруппаГостей.Code, "ND=12; NFD=0; NG=") + "'";
	vGrpAttachmentsRecMgr.DocumentText = "Автоматизированная рассылка счетов на оплату:" + Chars.LF + Chars.LF +"Счет на оплату № " + cmGetDocumentNumberPresentation(vInvoiceObj.НомерДока) + " от " + Format(vInvoiceObj.ДатаДок, "DF=dd.MM.yyyy") + " создан по брони № " + Format(vInvoiceObj.ГруппаГостей.Code, "ND=12; NFD=0; NG=") + "'" + Chars.LF + Chars.LF + 
	                                     ?(ЗначениеЗаполнено(vInvoiceObj.Контрагент), "Организация: " + СокрЛП(vInvoiceObj.Контрагент.LegacyName) + Chars.LF, "") + 
	                                     ?(ЗначениеЗаполнено(vDocObj.Клиент),"Клиент:" + СокрЛП(vDocObj.Клиент.FullName) + Chars.LF, "") + 
	                                     ?(ЗначениеЗаполнено(vDocObj.CheckInDate) И ЗначениеЗаполнено(vDocObj.ДатаВыезда),"Период проживания: " + Format(vDocObj.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - "  + Format(vDocObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + Chars.LF, "") + Chars.LF + Chars.LF + 
										 "С уважением," + Chars.LF + vHotel.GetObject().pmGetHotelPrintName(vLanguage) + Chars.LF + ПараметрыСеанса.ИмяКонфигурации;
	vFile = New File(vInvoiceFilePath);
	If vFile.Exist() And vFile.IsFile() Тогда
		vGrpAttachmentsRecMgr.FileName = vInvoiceFileName;
		vGrpAttachmentsRecMgr.FileLoadTime = CurrentDate();
		vGrpAttachmentsRecMgr.FileLastChangeTime = vFile.GetModificationTime();
		vBinary = New BinaryData(vInvoiceFilePath);
		vGrpAttachmentsRecMgr.ExtFile = New ValueStorage(vBinary);
		DeleteFiles(vInvoiceFilePath);
	EndIf;
	// Call user exit procedure to give possibility to override message subject and message text
	vUserExitProc = Справочники.ВнешниеОбработки.WriteGuestGroupInvoice;
	If ЗначениеЗаполнено(vUserExitProc) Тогда
		If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
			If НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
				Execute(СокрЛП(vUserExitProc.Algorithm));
			EndIf;
		EndIf;
	EndIf;
	// Write attachment
	vGrpAttachmentsRecMgr.Write();
	Return vBase64Text;
EndFunction //cmWriteReservationInvoiceGuestGroupAttachment

//-----------------------------------------------------------------------------
// Description: This API is used to create/update reservation from the external system.
//              Reservation will not be posted by default. This function could be 
//              called in simple cases when there is only one reservation in the group.
//              This function is wrapper and is using cmWriteExternalReservationRow
//              to create/update reservation
// Parameters: External reservation data, External system code, Whether to post 
//             new reservation or write only, Language code, Type of return value:
//             XDTO object or Colon Separated Values string
// Return value: XDTO ExternalReservationStatus object or CSV string
//-----------------------------------------------------------------------------
Function cmWriteExternalReservation(pExtReservationCode, pExtGroupCode, pExtGroupDescription, pGroupCustomerName,  
                                    pReservationStatusCode, pPeriodFrom, pPeriodTo, pHotelCode, pRoomTypeCode, 
                                    pAccommodationTypeCode, pClientTypeCode, pRoomQuotaCode, pRoomRateCode,
                                    pCustomerName, pContractName, pAgentName, pContactPerson, 
                                    pNumberOfRooms, pNumberOfPersons, 
                                    pExtClientCode, pClientLastName, pClientFirstName, pClientSecondName, 
                                    pClientSexCode, pClientCitizenshipCode, pClientBirthDate, 
                                    pClientPhone, pClientFax, pClientEMail, pClientRemarks, pClientSendSMS = Неопределено, pRemarks, pCar, 
                                    pPlannedPaymentMethodCode, pExternalSystemCode, pDoPosting = False, pPromoCode = "", 
                                    pLanguageCode = "RU", pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Write external reservation';ru='Записать внешнюю бронь';de='eine externe Reservierung einschreiben'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='External reservation code: ';ru='Код брони во внешней системе: ';de='Reservierungscode im externen System: '") + pExtReservationCode + Chars.LF + 
	              NStr("en='External group code: ';ru='Код группы во внешней системе: ';de='Gruppencode im externen System: '") + pExtGroupCode + Chars.LF + 
	              NStr("en='External group description: ';ru='Описание группы во внешней системе: ';de='Gruppenbeschreibung im externen System: '") + pExtGroupDescription + Chars.LF + 
	              NStr("en='Group Контрагент name: ';ru='Наименование контрагента группы: ';de='Bezeichnung des GruppenPartners: '") + pGroupCustomerName + Chars.LF + 
	              NStr("en='Reservation status code: ';ru='Код статуса брони: ';de='Reservierungsstatuscode: '") + pReservationStatusCode + Chars.LF + 
	              NStr("en='Period from: ';ru='Период с: ';de='Zeitraum ab: '") + Format(pPeriodFrom, "DF='dd.MM.yyyy HH:mm'") + Chars.LF + 
	              NStr("en='Period to: ';ru='Период по: ';de='Zeitraum bis: '") + Format(pPeriodTo, "DF='dd.MM.yyyy HH:mm'") + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + pRoomTypeCode + Chars.LF + 
	              NStr("en='Accommodation type code: ';ru='Код вида размещения: ';de='Code des Unterbringungstyps: '") + pAccommodationTypeCode + Chars.LF + 
	              NStr("en='Client type code: ';ru='Код типа клиента: ';de='Kundentypcode: '") + pClientTypeCode + Chars.LF + 
	              NStr("en='Allotment code: ';ru='Код квоты номеров: ';de='Zimmerquotencode: '") + pRoomQuotaCode + Chars.LF + 
	              NStr("en='ГруппаНомеров rate code: ';ru='Код тарифа: ';de='Tarifcode: '") + pRoomRateCode + Chars.LF + 
	              NStr("en='Контрагент name: ';ru='Наименование контрагента в брони: ';de='Bezeichnung des Partners in der Reservierung: '") + pCustomerName + Chars.LF + 
	              NStr("en='Contract name: ';ru='Наименование договора в брони: ';de='Bezeichnung für die Reservierung: '") + pContractName + Chars.LF + 
	              NStr("en='Agent name: ';ru='Наименование агента в брони: ';de='Bezeichnung des Vertreters in der Reservierung: '") + pAgentName + Chars.LF + 
	              NStr("en='Contact person: ';ru='Контактное лицо: ';de='Kontaktperson: '") + pContactPerson + Chars.LF + 
	              NStr("en='Number of rooms: ';ru='Количество номеров: ';de='Zimmeranzahl: '") + pNumberOfRooms + Chars.LF + 
	              NStr("en='Number of persons: '; ru='Количество гостей: '") + pNumberOfPersons + Chars.LF + 
	              NStr("en='External client code: ';ru='Код клиента во внешней системы: ';de='Kundecode im externen System: '") + pExtClientCode + Chars.LF + 
	              NStr("en='Client last name: ';ru='Фамилия гостя: ';de='Familienname des Gastes: '") + pClientLastName + Chars.LF + 
	              NStr("en='Client first name: ';ru='Имя гостя: ';de='Name des Gastes: '") + pClientFirstName + Chars.LF + 
	              NStr("en='Client second name: ';ru='Отчество гостя: ';de='Vatersname des Gastes: '") + pClientSecondName + Chars.LF + 
	              NStr("en='Client sex code: ';ru='Код пола гостя: ';de='Code des Geschlechts des Gastes: '") + pClientSexCode + Chars.LF + 
	              NStr("en='Client Гражданство code: ';ru='Код гражданства гостя: ';de='Code der Stadtbürgerschaft des Gastes: '") + pClientCitizenshipCode + Chars.LF + 
	              NStr("en='Client birth date: ';ru='Дата рождения гостя: ';de='Geburtsdatum des Gastes: '") + Format(pClientBirthDate, "DF='dd.MM.yyyy'") + Chars.LF + 
	              NStr("en='Client phone: ';ru='Телефон гостя: ';de='Telefon des Gastes: '") + pClientPhone + Chars.LF + 
	              NStr("en='Client fax: ';ru='Факс гостя: ';de='Fax des Gastes: '") + pClientFax + Chars.LF + 
	              NStr("en='Client E-Mail: ';ru='E-Mail гостя: ';de='E-Mail-Adresse des Gastes: '") + pClientEMail + Chars.LF + 
	              NStr("en='Client remarks: ';ru='Примечания гостя: ';de='Anmerkungen des Gastes: '") + pClientRemarks + Chars.LF + 
	              NStr("en='SMS delivery: ';ru='СМС раззылка: ';de='SMS Versand: '") + pClientSendSMS + Chars.LF + 
	              NStr("en='Reservation remarks: ';ru='Примечания к брони: ';de='Anmerkungen zur Buchung: '") + pRemarks + Chars.LF + 
	              NStr("en='Car: ';ru='Автомобиль: ';de='Fahrzeug: '") + pCar + Chars.LF + 
	              NStr("en='Planned payment method code: ';ru='Код планируемого способа оплаты: ';de='Code der geplanten Zahlungsmethode: '") + pPlannedPaymentMethodCode + Chars.LF + 
				  NStr("en='Promotion code: ';ru='Промо код: ';de='Promo Code: '") + pPromoCode + Chars.LF + 
	              NStr("en='Do posting: ';ru='Проводить бронь: ';de='Buchung ausführen: '") + pDoPosting);
	rErrorDescription = "";
	Try
		// Get language
		vLanguage = cmGetLanguageByCode(pLanguageCode);
		// Write new reservation object
		vDocObj = cmWriteExternalReservationRow(pExtReservationCode, pExtGroupCode, pExtGroupDescription, pGroupCustomerName,  
                                                pReservationStatusCode, pPeriodFrom, pPeriodTo, pHotelCode, pRoomTypeCode, 
                                                pAccommodationTypeCode, pClientTypeCode, pRoomQuotaCode, pRoomRateCode,
                                                pCustomerName, pContractName, pAgentName, pContactPerson, 
                                                pNumberOfRooms, pNumberOfPersons, 
                                                pExtClientCode, pClientLastName, pClientFirstName, pClientSecondName, 
                                                pClientSexCode, pClientCitizenshipCode, pClientBirthDate, 
                                                pClientPhone, pClientFax, pClientEMail, pClientRemarks, pClientSendSMS, pRemarks, pCar, 
                                                pPlannedPaymentMethodCode, , pExternalSystemCode, pDoPosting, pPromoCode, 
									            rErrorDescription, , , , , vLanguage);
		If vDocObj <> Неопределено And IsBlankString(rErrorDescription) Тогда
			// Fill reservation totals assuming that all sums are in one currency.
			vExtReservationStatusCode = "";
			vExtReservationStatusCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, pExternalSystemCode, "СтатусБрони", vDocObj.ReservationStatus);
			If IsBlankString(vExtReservationStatusCode) Тогда
				vExtReservationStatusCode = СокрЛП(vDocObj.ReservationStatus.Description);
			EndIf;
			vReservationStatusDescription = vDocObj.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage);
			vReservationCurrency = Справочники.Валюты.EmptyRef();
			vReservationExtCurrencyCode = "";
			vReservationSum = 0;
			vReservationSumPresentation = "";
			If vDocObj.Услуги.Count() > 0 Тогда
				vReservationCurrency = vDocObj.Услуги.Get(0).ВалютаЛицСчета;
				vReservationExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, pExternalSystemCode, "Валюты", vReservationCurrency);
				If IsBlankString(vReservationExtCurrencyCode) Тогда
					vReservationExtCurrencyCode = СокрЛП(vReservationCurrency.Description);
				EndIf;
				vReservationSum = vDocObj.Услуги.Total("Сумма") - vDocObj.Услуги.Total("СуммаСкидки");
				vReservationSumPresentation = cmFormatSum(vReservationSum, vReservationCurrency, "NZ=");
			EndIf;
			// Get base currency code
			vBaseCurrency = vDocObj.Гостиница.BaseCurrency;
			vExtBaseCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, pExternalSystemCode, "Валюты", vBaseCurrency);
			If IsBlankString(vExtBaseCurrencyCode) Тогда
				vExtBaseCurrencyCode = СокрЛП(vBaseCurrency.Description);
			EndIf;
			// Get currency rate
			vReservationCurrencyRate = 1;
			If ЗначениеЗаполнено(vReservationCurrency) Тогда
				vReservationCurrencyRate = cmGetCurrencyExchangeRate(vDocObj.Гостиница, vReservationCurrency, CurrentDate());
			EndIf;
			// Fill reservation first day price
			vFirstDaySumCurrency = Неопределено;
			vFirstDaySum = 0;
			vFirstDaySumPresentation = "";
			vPrices = vDocObj.pmGetPrices(True);
			vFirstAccDate = Неопределено;
			For Each vPricesRow In vPrices Do
				If НЕ ЗначениеЗаполнено(vFirstAccDate) Тогда
					vFirstAccDate = vPricesRow.УчетнаяДата;
					vFirstDaySumCurrency = vPricesRow.ВалютаЛицСчета;
				EndIf;
				If vPricesRow.УчетнаяДата = vFirstAccDate Тогда
					vFirstDaySum = vFirstDaySum + vPricesRow.Цена;
				Else
					Break;
				EndIf;
			EndDo;
			If vFirstDaySumCurrency <> vReservationCurrency Тогда
				vFirstDaySum = Round(cmConvertCurrencies(vFirstDaySum, vFirstDaySumCurrency, , vReservationCurrency, , CurrentDate(), vDocObj.Гостиница), 2);
			EndIf;
			If vFirstDaySum <> 0 Тогда
				vFirstDaySumPresentation = cmFormatSum(vFirstDaySum, vReservationCurrency, "NZ=");
			EndIf;
			// Build return string
			vRetStr = """" + """" + "," + """" + СокрЛП(vDocObj.НомерДока) + """" + "," + """" + СокрЛП(vDocObj.ExternalCode) + """" + "," + 
			          """" + СокрЛП(vExtReservationStatusCode) + """" + "," + """" + cmRemoveComma(vDocObj.ConfirmationReply) + """" + "," + 
			          """" + СокрЛП(vDocObj.Posted) + """" + "," + """" + Format(vDocObj.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=") + """" + "," + 
			          """" + СокрЛП(vDocObj.ReservationStatus.Code) + """" + "," + """" + cmRemoveComma(vReservationStatusDescription) + """" + "," + 
			          """" + СокрЛП(vReservationExtCurrencyCode) + """" + "," + """" + СокрЛП(vReservationCurrency.Code) + """" + "," + """" + cmRemoveComma(vReservationCurrency.Description) + """" + "," + 
			          Format(vReservationSum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
					  """" + cmRemoveComma(vReservationSumPresentation) + """" + "," + 
			          Format(vFirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
			          """" + cmRemoveComma(vFirstDaySumPresentation) + """";
					  
			// Log success		
			WriteLogEvent(NStr("en='Write external reservation';ru='Записать внешнюю бронь';de='Eine externe Reservierung einschreiben'"), EventLogLevel.Information, , , 
						  NStr("en='Reservation was saved - OK!';ru='Бронь записана в БД!';de='Die Reservierung wurde in die Datenbank geschrieben!'") + Chars.LF + vRetStr);
			// Write message to the reservation Отдел that new reservation was created
			If ЗначениеЗаполнено(vDocObj.Гостиница) And ЗначениеЗаполнено(vDocObj.Гостиница.ReservationDepartment) Тогда
				vPeriodStr = ", " + Format(vDocObj.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(vDocObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'");
				vMsgText = NStr("en='New external reservation was created! Reservation data: Group code " + СокрЛП(vDocObj.ГруппаГостей) + vPeriodStr + ", НомерРазмещения type " + СокрЛП(vDocObj.ТипНомера) + ", Размещение type " + СокрЛП(vDocObj.ВидРазмещения) + ", number of НомернойФонд " + Format(vDocObj.RoomQuantity, "ND=8; NFD=0; NZ=; NG=") + ", Клиент " + СокрЛП(vDocObj.Клиент) + "'; 
				                |de='New external reservation was created! Reservation data: Group code " + СокрЛП(vDocObj.ГруппаГостей) + vPeriodStr + ", НомерРазмещения type " + СокрЛП(vDocObj.ТипНомера) + ", Размещение type " + СокрЛП(vDocObj.ВидРазмещения) + ", number of НомернойФонд " + Format(vDocObj.RoomQuantity, "ND=8; NFD=0; NZ=; NG=") + ", Клиент " + СокрЛП(vDocObj.Клиент) + "'; 
				                |ru='Создана новая внешняя бронь! Данные брони: Код группы " + СокрЛП(vDocObj.ГруппаГостей) + vPeriodStr + ", тип номера " + СокрЛП(vDocObj.ТипНомера) + ", вид размещения " + СокрЛП(vDocObj.ВидРазмещения) + ", кол-во номеров " + Format(vDocObj.RoomQuantity, "ND=8; NFD=0; NZ=; NG=") + ", ФИО гостя " + СокрЛП(vDocObj.Клиент) + "'");
				// Call API
				cmSendMessageToDepartment(vDocObj.Гостиница.ReservationDepartment, vMsgText, Неопределено, True, vDocObj.Ref);
			EndIf;
			// Return based on output type
			If pOutputType = "CSV" Тогда
				Return vRetStr;
			Else
				vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatus"));
				vRetXDTO.ErrorDescription = "";
				vStatusRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatusRow"));
				vStatusRow.IsPosted = vDocObj.Posted;
				vStatusRow.ReservationNumber = СокрЛП(vDocObj.НомерДока);
				vStatusRow.ReservationStatus = vExtReservationStatusCode;
				vStatusRow.ReservationStatusCode = СокрЛП(vDocObj.ReservationStatus.Code);
				vStatusRow.ReservationStatusDescription = vReservationStatusDescription;
				vStatusRow.ConfirmationReply = Left(СокрЛП(vDocObj.ConfirmationReply), 2048);
				vStatusRow.ГруппаГостей = Format(vDocObj.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=");
				If ЗначениеЗаполнено(vDocObj.Клиент) Тогда
					vStatusRow.GuestFullName = TrimR(vDocObj.Клиент.FullName);
					vStatusRow.GuestBirthDate = vDocObj.Клиент.ДатаРождения;
					vStatusRow.GuestPassport = TrimR(TrimR(vDocObj.Клиент.IdentityDocumentSeries) + " " + TrimR(vDocObj.Клиент.IdentityDocumentNumber));
					vStatusRow.GuestPhone = TrimR(vDocObj.Клиент.Телефон);
					vStatusRow.GuestFax = TrimR(vDocObj.Клиент.Fax);
					vStatusRow.GuestEMail = TrimR(vDocObj.Клиент.EMail);
					vStatusRow.GuestIdentityDocumentType = СокрЛП(vDocObj.Клиент.IdentityDocumentType.Code); 
					vStatusRow.GuestIdentityDocumentSeries = СокрЛП(vDocObj.Клиент.IdentityDocumentSeries);
					vStatusRow.GuestIdentityDocumentNumber = СокрЛП(vDocObj.Клиент.IdentityDocumentNumber);
					vStatusRow.GuestIdentityDocumentIssuedBy = СокрЛП(vDocObj.Клиент.IdentityDocumentIssuedBy);
					vStatusRow.GuestIdentityDocumentValidToDate = vDocObj.Клиент.IdentityDocumentValidToDate;
					vStatusRow.GuestIdentityDocumentIssueDate = vDocObj.Клиент.IdentityDocumentIssueDate;
					vStatusRow.GuestCitizenship = СокрЛП(vDocObj.Клиент.Гражданство.ISOCode);
					vStatusRow.GuestSendSMS = НЕ vDocObj.Клиент.NoSMSDelivery;
					vStatusRow.GuestSex = Left(СокрЛП(String(vDocObj.Клиент.Пол)), 1);
					vStatusRow.GuestLastName = СокрЛП(vDocObj.Клиент.Фамилия);
					vStatusRow.GuestFirstName = СокрЛП(vDocObj.Клиент.Имя);
					vStatusRow.GuestSecondName = СокрЛП(vDocObj.Клиент.Отчество);
					vStatusRow.GuestAddress = СокрЛП(vDocObj.Клиент.Address);
				Else
					vStatusRow.GuestFullName = "";
					vStatusRow.GuestBirthDate = Неопределено;
					vStatusRow.GuestPassport = "";
					vStatusRow.GuestPhone = "";
					vStatusRow.GuestFax = "";
					vStatusRow.GuestEMail = "";
					vStatusRow.GuestIdentityDocumentType = ""; 
					vStatusRow.GuestIdentityDocumentSeries = ""; 
					vStatusRow.GuestIdentityDocumentNumber = ""; 
					vStatusRow.GuestIdentityDocumentIssuedBy = ""; 
					vStatusRow.GuestIdentityDocumentValidToDate = Неопределено;
					vStatusRow.GuestIdentityDocumentIssueDate = Неопределено;
					vStatusRow.GuestCitizenship = ""; 
					vStatusRow.GuestSendSMS = Неопределено;
					vStatusRow.GuestSex = ""; 
					vStatusRow.GuestLastName = ""; 
					vStatusRow.GuestFirstName = ""; 
					vStatusRow.GuestSecondName = ""; 
					vStatusRow.GuestAddress = "";
				EndIf;
				vStatusRow.Валюта = vReservationExtCurrencyCode;
				vStatusRow.CurrencyCode = СокрЛП(vReservationCurrency.Code);
				vStatusRow.CurrencyDescription = СокрЛП(vReservationCurrency.Description);
				vStatusRow.BaseCurrency = vExtBaseCurrencyCode;
				vStatusRow.CurrencyRate = vReservationCurrencyRate;
				vStatusRow.Сумма = vReservationSum;
				vStatusRow.SumPresentation = vReservationSumPresentation;
				vStatusRow.FirstDaySum = vFirstDaySum;
				vStatusRow.FirstDaySumPresentation = vFirstDaySumPresentation;
				vStatusRow.PaymentMethodCodesAllowedOnline = vDocObj.Тариф.PaymentMethodCodesAllowedOnline;
				vStatusRow.ExtReservationCode = СокрЛП(vDocObj.ExternalCode);
				vStatusRow.RoomQuotaCode = СокрЛП(vDocObj.КвотаНомеров.Code);
				vRetXDTO.ExternalReservationStatusRow = vStatusRow;
				Return vRetXDTO;
			EndIf;
		Else
			ВызватьИсключение rErrorDescription;
		EndIf;
	Except
		vErrorDescription = ErrorDescription();
		// Write log event
		WriteLogEvent(NStr("en='Write external reservation';ru='Записать внешнюю бронь';de='Eine externe Reservierung einschreiben'"), EventLogLevel.Error, , , 
					  NStr("en='Error description: ';ru='Описание ошибки: ';de='Fehlerbeschreibung: '") + vErrorDescription);
		// Build return string
		vRetStr = """" + vErrorDescription + """";
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatus"));
			vRetXDTO.ErrorDescription = Left(vErrorDescription, 2048);
			Return vRetXDTO;
		EndIf;
	EndTry;
EndFunction //cmWriteExternalReservation

//-----------------------------------------------------------------------------
// Description: This API is used to create/update group of reservations from the external system.
//              Reservation will not be posted by default. This function could be 
//              called in simple cases when there is only one reservation in the group.
//              This function is wrapper and is using cmWriteExternalReservationRow
//              to create/update reservations. Only web-service call type (XDTO) is supported
// Parameters: External reservation data, External system code, Whether to post 
//             new reservation or write only, Language code
// Return value: XDTO ExternalReservationStatus object
//-----------------------------------------------------------------------------
Function cmWriteExternalGroupReservation(pWriteExternalGroupReservation, pLanguageCode = "RU") Экспорт
	rErrorDescription = "";
	vDocObj = Неопределено;
	// Do in one transaction
	vInternalTransaction = False;
	If НЕ TransactionActive() Тогда
		BeginTransaction(DataLockControlMode.Managed);
		vInternalTransaction = True;
	EndIf;
	Try
		vExtSystemCode = "";
		vCurrency = Справочники.Валюты.EmptyRef();
		vCurrencyExtCode = "";
		vBaseCurrency = "";
		vExtBaseCurrencyCode = "";
		vCurrencyRate = 0;
		vMainGuest = Неопределено;
		vMainCustomer = Неопределено;
		vMainContract = Неопределено;
		vMainAgent = Неопределено;
		vRoomUUIDs = New ValueTable();
		vRoomUUIDs.Columns.Add("UUID", cmGetStringTypeDescription());
		vRoomUUIDs.Columns.Add("ReservationNumber", cmGetStringTypeDescription());
		vRoomUUIDs.Columns.Add("ReservationDate", cmGetDateTimeTypeDescription());
		vRoomUUIDs.Columns.Add("RoomCode", cmGetStringTypeDescription());
		// Stop SMS delivery for this transaction
		ПараметрыСеанса.SMSDeliveryIsStopped = True;
		// Get language
		vLanguage = cmGetLanguageByCode(pLanguageCode);
		// Initialize guest group
		vGuestGroup = Справочники.ГруппыГостей.EmptyRef();
		// Initialize totals
		vTotalSum = 0;
		//vTotalSumPresentation = "";
		// Initialize guest group total first day price
		vTotalFirstDaySum = 0;
		vTotalFirstDaySumPresentation = "";
		// Build return object
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalGroupReservationStatus"));
		vRetXDTO.ErrorDescription = "";
		// Transfer rules
		vNeedTransfer = "";
		vTransferData = New Structure("Need, Date, Place, Примечания");
		vTransferData.Need = False;
		Try 
			If pWriteExternalGroupReservation.TransferBooked Тогда
				vNeedTransfer = vNeedTransfer + Format(pWriteExternalGroupReservation.TransferTime, "DF='dd.MM.yyyy HH:mm'") + ", " + СокрЛП(pWriteExternalGroupReservation.TransferPlace) + Chars.LF + 
				                СокрЛП(pWriteExternalGroupReservation.TransferRemarks);
				vTransferData.Need = True;
				vTransferData.Date    = pWriteExternalGroupReservation.TransferTime;
				vTransferData.Place   = pWriteExternalGroupReservation.TransferPlace;
				vTransferData.Remarks = pWriteExternalGroupReservation.TransferRemarks;
			EndIf;
		Except
		EndTry;
		// Extra services
		vExtraServices = New СписокЗначений();
		Try
			If pWriteExternalGroupReservation.ChargeExtraServices <> Неопределено Тогда
				For Each vExtraChargeSevice In pWriteExternalGroupReservation.ChargeExtraServices.ChargeExtraServiceRow Do
					vExtraServicesItem = New Structure("Услуга, Цена, Количество, Примечания, Валюта, ChargeDate", vExtraChargeSevice.Услуга, vExtraChargeSevice.Цена, vExtraChargeSevice.Количество, vExtraChargeSevice.Примечания, vExtraChargeSevice.Валюта, vExtraChargeSevice.ChargeDate);
					vExtraServices.Add(vExtraServicesItem);
				EndDo;
			EndIf;
		Except
		EndTry;
		// Credit card
		vCreditCardData = New Structure("CardNumber, CardHolder, CardValidTillDate, CardSecurityCode", "", "", '00010101', "");
		Try
			If pWriteExternalGroupReservation.CreditCardData <> Неопределено Тогда
				vCreditCardData.CardNumber = СокрЛП(pWriteExternalGroupReservation.CreditCardData.CardNumber);
				vCreditCardData.CardHolder = СокрЛП(pWriteExternalGroupReservation.CreditCardData.CardHolder);
				vCreditCardData.CardValidTillDate = BegOfMonth(pWriteExternalGroupReservation.CreditCardData.CardValidTillDate);
				vCreditCardData.CardSecurityCode = СокрЛП(pWriteExternalGroupReservation.CreditCardData.CardSecurityCode);
			EndIf;
		Except
		EndTry;
		// Login
		vLogin = "";
		Try
			vLogin = TrimR(pWriteExternalGroupReservation.Login);
		Except
		EndTry;
		// Iterate thru reservation rows
		vUUID = New UUID();
		vUUIDStr = String(vUUID);
		vReservationNumber = "";
		vRoomCode = "";
		vReservationDate = Неопределено;
		i = 0;
		For Each vRow In pWriteExternalGroupReservation.WriteExternalGroupReservationRow Do
			i = i + 1;
			WriteLogEvent(NStr("en='Write external reservation';ru='Записать внешнюю бронь';de='eine externe Reservierung einschreiben'"), EventLogLevel.Information, , , 
			              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + vRow.ExternalSystemCode + Chars.LF + 
			              NStr("en='External reservation code: ';ru='Код брони во внешней системе: ';de='Reservierungscode im externen System: '") + vRow.ReservationCode + Chars.LF + 
			              NStr("en='External group code: ';ru='Код группы во внешней системе: ';de='Gruppencode im externen System: '") + vRow.GroupCode + Chars.LF + 
			              NStr("en='External group description: ';ru='Описание группы во внешней системе: ';de='Gruppenbeschreibung im externen System: '") + vRow.GroupDescription + Chars.LF + 
			              NStr("en='Group Контрагент name: ';ru='Наименование контрагента группы: ';de='Bezeichnung des GruppenPartners: '") + vRow.GroupCustomer + Chars.LF + 
			              NStr("en='Reservation status code: ';ru='Код статуса брони: ';de='Reservierungsstatuscode: '") + vRow.ReservationStatus + Chars.LF + 
			              NStr("en='Period from: ';ru='Период с: ';de='Zeitraum ab: '") + Format(vRow.ПериодС, "DF='dd.MM.yyyy HH:mm'") + Chars.LF + 
			              NStr("en='Period to: ';ru='Период по: ';de='Zeitraum bis: '") + Format(vRow.ПериодПо, "DF='dd.MM.yyyy HH:mm'") + Chars.LF + 
			              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + vRow.Гостиница + Chars.LF + 
			              NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + vRow.ТипНомера + Chars.LF + 
			              NStr("en='ГруппаНомеров code: ';ru='Код номера: ';de='Zimmercode: '") + vRow.НомерРазмещения + Chars.LF + 
			              NStr("en='Accommodation type code: ';ru='Код вида размещения: ';de='Code des Unterbringungstyps: '") + vRow.ВидРазмещения + Chars.LF + 
			              NStr("en='Client type code: ';ru='Код типа клиента: ';de='Kundentypcode: '") + vRow.ТипКлиента + Chars.LF + 
			              NStr("en='Allotment code: ';ru='Код квоты номеров: ';de='Zimmerquotencode: '") + vRow.КвотаНомеров + Chars.LF + 
			              NStr("en='ГруппаНомеров rate code: ';ru='Код тарифа: ';de='Tarifcode: '") + vRow.Тариф + Chars.LF + 
			              NStr("en='Контрагент name: ';ru='Наименование контрагента в брони: ';de='Bezeichnung des Partners in der Reservierung: '") + vRow.Контрагент + Chars.LF + 
			              NStr("en='Contract name: ';ru='Наименование договора в брони: ';de='Bezeichnung für die Reservierung: '") + ?(IsBlankString(vLogin), vRow.Договор, vLogin) + Chars.LF + 
			              NStr("en='Agent name: ';ru='Наименование агента в брони: ';de='Bezeichnung des Vertreters in der Reservierung: '") + vRow.Агент + Chars.LF + 
			              NStr("en='Contact person: ';ru='Контактное лицо: ';de='Kontaktperson: '") + vRow.КонтактноеЛицо + Chars.LF + 
			              NStr("en='Number of rooms: ';ru='Количество номеров: ';de='Zimmeranzahl: '") + vRow.КоличествоНомеров + Chars.LF + 
			              NStr("en='Number of persons: '; ru='Количество гостей: '") + vRow.КоличествоЧеловек + Chars.LF + 
			              NStr("en='External client code: ';ru='Код клиента во внешней системы: ';de='Kundecode im externen System: '") + vRow.Клиент.ClientCode + Chars.LF + 
			              NStr("en='Client last name: ';ru='Фамилия гостя: ';de='Familienname des Gastes: '") + vRow.Клиент.ClientLastName + Chars.LF + 
			              NStr("en='Client first name: ';ru='Имя гостя: ';de='Name des Gastes: '") + vRow.Клиент.ClientFirstName + Chars.LF + 
			              NStr("en='Client second name: ';ru='Отчество гостя: ';de='Vatersname des Gastes: '") + vRow.Клиент.ClientSecondName + Chars.LF + 
			              NStr("en='Client sex code: ';ru='Код пола гостя: ';de='Code des Geschlechts des Gastes: '") + vRow.Клиент.ClientSex + Chars.LF + 
			              NStr("en='Client Гражданство code: ';ru='Код гражданства гостя: ';de='Code der Stadtbürgerschaft des Gastes: '") + vRow.Клиент.ClientCitizenship + Chars.LF + 
			              NStr("en='Client birth date: ';ru='Дата рождения гостя: ';de='Geburtsdatum des Gastes: '") + Format(vRow.Клиент.ClientBirthDate, "DF='dd.MM.yyyy'") + Chars.LF + 
			              NStr("en='Client phone: ';ru='Телефон гостя: ';de='Telefon des Gastes: '") + vRow.Клиент.ClientPhone + Chars.LF + 
			              NStr("en='Client fax: ';ru='Факс гостя: ';de='Fax des Gastes: '") + vRow.Клиент.ClientFax + Chars.LF + 
			              NStr("en='Client E-Mail: ';ru='E-Mail гостя: ';de='E-Mail-Adresse des Gastes: '") + vRow.Клиент.ClientEMail + Chars.LF + 
			              NStr("en='Client remarks: ';ru='Примечания гостя: ';de='Anmerkungen des Gastes: '") + vRow.Клиент.ClientRemarks + Chars.LF + 
			              NStr("en='Send SMS: ';ru='СМС рассылка: ';de='SMS Versand: '") + vRow.Клиент.Get("ClientSendSMS") + Chars.LF + 
			              NStr("en='Reservation remarks: ';ru='Примечания к брони: ';de='Anmerkungen zur Buchung: '") + vRow.ReservationRemarks + Chars.LF + 
			              NStr("en='Car: ';ru='Автомобиль: ';de='Fahrzeug: '") + vRow.Car + Chars.LF + 
			              NStr("en='Planned payment method code: ';ru='Код планируемого способа оплаты: ';de='Code der geplanten Zahlungsmethode: '") + vRow.PlannedPaymentMethod + Chars.LF + 
						  NStr("en='Discount type: '; ru='Тип скидки: '; de='Discount-Typ'") + vRow.ТипСкидки + Chars.LF + 
			              NStr("en='Discount sum: '; ru='Сумма скидки: '; de='Discount Summe'") + vRow.СуммаСкидки + Chars.LF + 
			              NStr("en='Do posting: ';ru='Проводить бронь: ';de='Buchung ausführen: '") + vRow.DoPosting);
			// Initialize external system code
			If IsBlankString(vExtSystemCode) Тогда
				vExtSystemCode = vRow.ExternalSystemCode;
			EndIf;
			vExtGuestGroupCode = TrimR(vRow.GroupCode);
			If IsBlankString(vExtGuestGroupCode) Тогда
				vExtGuestGroupCode = vUUIDStr;
			EndIf;
			// Try to fill reservation number
			vRoomUUID = "";
			vRoomUUIDsRow = Неопределено;
			vReservationDate = Неопределено;
			If НЕ IsBlankString(vRow.НомерРазмещения) And StrLen(СокрЛП(vRow.НомерРазмещения)) = 36 Тогда
				vRoomUUID = СокрЛП(vRow.НомерРазмещения);
				vRoomUUIDsRow = vRoomUUIDs.Find(vRoomUUID, "UUID");
				If vRoomUUIDsRow <> Неопределено And НЕ IsBlankString(vRoomUUIDsRow.ReservationNumber) Тогда
					vReservationNumber = vRoomUUIDsRow.ReservationNumber;
					vReservationDate = vRoomUUIDsRow.ReservationDate + 1;
					vRoomCode = vRoomUUIDsRow.RoomCode;
				Else
					vReservationNumber = "";
					vRoomCode = "";
				EndIf;
			Else
				vRoomCode = "";
			EndIf;
			// Transfer data is charged only for the first guest
			If i > 1 Тогда
				vTransferData = Неопределено;
				vExtraServices = Неопределено;
				vCreditCardData = Неопределено;
			EndIf;
			// Write new reservation
			vDocObj = cmWriteExternalReservationRow(vRow.ReservationCode, vExtGuestGroupCode,  vRow.GroupDescription, vRow.GroupCustomer,  
	                                                vRow.ReservationStatus, vRow.ПериодС, vRow.ПериодПо, vRow.Гостиница, vRow.ТипНомера, 
	                                                vRow.ВидРазмещения, vRow.ТипКлиента, vRow.КвотаНомеров, vRow.Тариф,
	                                                vRow.Контрагент, ?(IsBlankString(vLogin), vRow.Договор, vLogin), vRow.Агент, vRow.КонтактноеЛицо, 
	                                                vRow.КоличествоНомеров, vRow.КоличествоЧеловек, 
	                                                vRow.Клиент.ClientCode, vRow.Клиент.ClientLastName, vRow.Клиент.ClientFirstName, vRow.Клиент.ClientSecondName, 
	                                                vRow.Клиент.ClientSex, vRow.Клиент.ClientCitizenship, vRow.Клиент.ClientBirthDate, 
	                                                vRow.Car, 
	                                                vRow.PlannedPaymentMethod, vReservationDate, vRow.ExternalSystemCode, vRow.DoPosting, vRow.PromoCode, 
										            rErrorDescription, True, vReservationNumber, , , vLanguage, , vTransferData, vExtraServices, vCreditCardData, vRow.ТипСкидки, vRow.СуммаСкидки, vRoomCode);
			If vDocObj <> Неопределено And IsBlankString(rErrorDescription) Тогда
				// Fill reservation number
				If ЗначениеЗаполнено(vDocObj.ВидРазмещения) And 
				  (vDocObj.ВидРазмещения.ТипРазмещения = Перечисления.ВидыРазмещений.НомерРазмещения Or vDocObj.ВидРазмещения.ТипРазмещения = Перечисления.AccomodationTypes.Beds) Тогда
					vReservationNumber = TrimR(vDocObj.НомерДока);
					vRoomCode = TrimR(vDocObj.НомерРазмещения);
				EndIf;
				// Store reservation number and ГруппаНомеров code mapping
				If НЕ IsBlankString(vRoomUUID) Тогда
					If vRoomUUIDsRow = Неопределено Тогда
						vRoomUUIDsRow = vRoomUUIDs.Add();
						vRoomUUIDsRow.UUID = vRoomUUID;
						vRoomUUIDsRow.ReservationNumber = TrimR(vDocObj.НомерДока);
						vRoomUUIDsRow.ReservationDate = vDocObj.ДатаДок;
						vRoomUUIDsRow.RoomCode = TrimR(vDocObj.НомерРазмещения);
					EndIf;
				EndIf;
				// Fill reservation totals assuming that all sums are in one currency.
				vExtReservationStatusCode = "";
				vExtReservationStatusCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, vRow.ExternalSystemCode, "СтатусБрони", vDocObj.ReservationStatus);
				If IsBlankString(vExtReservationStatusCode) Тогда
					vExtReservationStatusCode = СокрЛП(vDocObj.ReservationStatus.Description);
				EndIf;
				vReservationStatusDescription = vDocObj.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage);
				vReservationSum = 0;
				vReservationCurrency = Справочники.Валюты.EmptyRef();
				vReservationExtCurrencyCode = "";
				vReservationSumPresentation = "";
				If vDocObj.Услуги.Count() > 0 Тогда
					vReservationCurrency = vDocObj.Услуги.Get(0).ВалютаЛицСчета;
					vReservationExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, vRow.ExternalSystemCode, "Валюты", vReservationCurrency);
					If IsBlankString(vReservationExtCurrencyCode) Тогда
						vReservationExtCurrencyCode = СокрЛП(vReservationCurrency.Description);
					EndIf;
					vReservationSum = vDocObj.Услуги.Total("Сумма") - vDocObj.Услуги.Total("СуммаСкидки");
					vReservationSumPresentation = cmFormatSum(vReservationSum, vReservationCurrency, "NZ=");
				EndIf;
				If НЕ ЗначениеЗаполнено(vCurrency) Тогда
					vCurrency = vReservationCurrency;
					vCurrencyExtCode = vReservationExtCurrencyCode;
				EndIf;
				// Get base currency code
				If НЕ ЗначениеЗаполнено(vBaseCurrency) Тогда
					vBaseCurrency = vDocObj.Гостиница.BaseCurrency;
					vExtBaseCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, vRow.ExternalSystemCode, "Валюты", vBaseCurrency);
					If IsBlankString(vExtBaseCurrencyCode) Тогда
						vExtBaseCurrencyCode = СокрЛП(vBaseCurrency.Description);
					EndIf;
				EndIf;
				// Get currency rate
				vReservationCurrencyRate = 1;
				If ЗначениеЗаполнено(vReservationCurrency) Тогда
					vReservationCurrencyRate = cmGetCurrencyExchangeRate(vDocObj.Гостиница, vReservationCurrency, CurrentDate());
				EndIf;
				If vCurrencyRate = 0 Тогда
					vCurrencyRate = vReservationCurrencyRate;
				EndIf;
				// Get total amount
				If vReservationCurrency = vCurrency Тогда
					vTotalSum = vTotalSum + vReservationSum;
				Else
					vTotalSum = vTotalSum + Round(cmConvertCurrencies(vReservationSum, vReservationCurrency, , vCurrency, , CurrentDate(), vDocObj.Гостиница), 2);
				EndIf;
				// ГруппаНомеров types and accommodation types
				vExtRoomTypeCode = "";
				vRoomTypeCode = "";
				vRoomTypeDescription = "";
				If ЗначениеЗаполнено(vDocObj.ТипНомераРасчет) Тогда
					vRoomTypeObj = vDocObj.ТипНомераРасчет.GetObject();
					vRoomTypeCode = СокрЛП(vDocObj.ТипНомераРасчет.Code);
					vRoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
					vExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, vRow.ExternalSystemCode, "ТипыНомеров", vDocObj.ТипНомераРасчет);
					If IsBlankString(vExtRoomTypeCode) Тогда
						vExtRoomTypeCode = СокрЛП(vDocObj.ТипНомераРасчет.Description);
					EndIf;
				ElsIf ЗначениеЗаполнено(vDocObj.ТипНомера) Тогда
					vRoomTypeObj = vDocObj.ТипНомера.GetObject();
					vRoomTypeCode = СокрЛП(vDocObj.ТипНомера.Code);
					vRoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
					vExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, vRow.ExternalSystemCode, "ТипыНомеров", vDocObj.ТипНомера);
					If IsBlankString(vExtRoomTypeCode) Тогда
						vExtRoomTypeCode = СокрЛП(vDocObj.ТипНомера.Description);
					EndIf;
				EndIf;
				vExtAccommodationTypeCode = "";
				vAccommodationTypeCode = "";
				vAccommodationTypeDescription = "";
				If ЗначениеЗаполнено(vDocObj.ВидРазмещения) Тогда
					vAccommodationTypeObj = vDocObj.ВидРазмещения.GetObject();
					vAccommodationTypeCode = СокрЛП(vDocObj.ВидРазмещения.Code);
					vAccommodationTypeDescription = vAccommodationTypeObj.pmGetAccommodationTypeDescription(vLanguage);
					vExtAccommodationTypeCode = cmGetObjectExternalSystemCodeByRef(vDocObj.Гостиница, vRow.ExternalSystemCode, "ВидыРазмещения", vDocObj.ВидРазмещения);
					If IsBlankString(vExtAccommodationTypeCode) Тогда
						vExtAccommodationTypeCode = СокрЛП(vDocObj.ВидРазмещения.Description);
					EndIf;
				EndIf;
				// Fill reservation first day price
				vFirstDaySum = 0;
				vFirstDaySumCurrency = Неопределено;
				vFirstDaySumPresentation = "";
				vPrices = vDocObj.pmGetPrices(True);
				vFirstAccDate = Неопределено;
				For Each vPricesRow In vPrices Do
					If НЕ ЗначениеЗаполнено(vFirstAccDate) Тогда
						vFirstAccDate = vPricesRow.УчетнаяДата;
						vFirstDaySumCurrency = vPricesRow.ВалютаЛицСчета;
					EndIf;
					If vPricesRow.УчетнаяДата = vFirstAccDate Тогда
						vFirstDaySum = vFirstDaySum + vPricesRow.Цена;
					Else
						Break;
					EndIf;
				EndDo;
				If vFirstDaySumCurrency <> vCurrency Тогда
					vFirstDaySum = Round(cmConvertCurrencies(vFirstDaySum, vFirstDaySumCurrency, , vCurrency, , CurrentDate(), vDocObj.Гостиница), 2);
				EndIf;
				vFirstDaySumPresentation = cmFormatSum(vFirstDaySum, vCurrency, "NZ=");
				// Fill guest group first day price totals
				vTotalFirstDaySum = vTotalFirstDaySum + vFirstDaySum;
				// Save guest group
				vGuestGroup = vDocObj.ГруппаГостей;
				// Build return string
				vRetStr = """" + """" + "," + """" + СокрЛП(vDocObj.НомерДока) + """" + "," + """" + СокрЛП(vExtReservationStatusCode) + """" + "," + """" + cmRemoveComma(vDocObj.ConfirmationReply) + """" + "," + 
				          """" + СокрЛП(vDocObj.Posted) + """" + "," + """" + Format(vDocObj.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=") + """" + "," + 
				          """" + СокрЛП(vDocObj.ReservationStatus.Code) + """" + "," + """" + cmRemoveComma(vReservationStatusDescription) + """" + "," + 
				          Format(vDocObj.RoomQuantity, "ND=10; NFD=0; NZ=; NG=") + "," + Format(vDocObj.КоличествоЧеловек, "ND=10; NFD=0; NZ=; NG=") + "," + 
				          """" + СокрЛП(vExtRoomTypeCode) + """" + "," + """" + СокрЛП(vRoomTypeCode) + """" + "," + """" + cmRemoveComma(vRoomTypeDescription) + """" + "," + 
				          """" + СокрЛП(vExtAccommodationTypeCode) + """" + "," + """" + СокрЛП(vAccommodationTypeCode) + """" + "," + """" + cmRemoveComma(vAccommodationTypeDescription) + """" + "," + 
				          """" + Format(vDocObj.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + """" + "," + Format(vDocObj.Продолжительность, "ND=10; NFD=0; NZ=; NG=") + "," + """" + Format(vDocObj.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + """" + "," +
				          """" + СокрЛП(vReservationExtCurrencyCode) + """" + "," + """" + СокрЛП(vReservationCurrency.Code) + """" + "," + """" + cmRemoveComma(vReservationCurrency.Description) + """" + "," + 
				          Format(vReservationSum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
						  """" + cmRemoveComma(vReservationSumPresentation) + """" + "," + 
				          Format(vFirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
				          """" + cmRemoveComma(vFirstDaySumPresentation) + """";
				// Log success		
				WriteLogEvent(NStr("en='Write external reservation';ru='Записать внешнюю бронь';de='Eine externe Reservierung einschreiben'"), EventLogLevel.Information, , , 
							  NStr("en='Reservation was saved - OK!';ru='Бронь записана в БД!';de='Die Reservierung wurde in die Datenbank geschrieben!'") + Chars.LF + vRetStr);
				// Attach status row to the return object
				vStatusRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatusRow"));
				vStatusRow.IsPosted = vDocObj.Posted;
				vStatusRow.ReservationNumber = СокрЛП(vDocObj.НомерДока);
				vStatusRow.ReservationStatus = vExtReservationStatusCode;
				vStatusRow.ReservationStatusCode = СокрЛП(vDocObj.ReservationStatus.Code);
				vStatusRow.ReservationStatusDescription = vReservationStatusDescription;
				vStatusRow.ConfirmationReply = Left(СокрЛП(vDocObj.ConfirmationReply), 2048);
				vStatusRow.ГруппаГостей = Format(vDocObj.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=");
				If ЗначениеЗаполнено(vDocObj.Клиент) Тогда
					vStatusRow.GuestCode = СокрЛП(vDocObj.Клиент.Code);
					vStatusRow.GuestFullName = TrimR(vDocObj.Клиент.FullName);
					vStatusRow.GuestBirthDate = vDocObj.Клиент.ДатаРождения;
					vStatusRow.GuestPassport = TrimR(TrimR(vDocObj.Клиент.IdentityDocumentSeries) + " " + TrimR(vDocObj.Клиент.IdentityDocumentNumber));
					vStatusRow.GuestPhone = TrimR(vDocObj.Клиент.Телефон);
					vStatusRow.GuestFax = TrimR(vDocObj.Клиент.Fax);
					vStatusRow.GuestEMail = TrimR(vDocObj.Клиент.EMail);
					vStatusRow.GuestIdentityDocumentType = СокрЛП(vDocObj.Клиент.IdentityDocumentType.Code); 
					vStatusRow.GuestIdentityDocumentSeries = СокрЛП(vDocObj.Клиент.IdentityDocumentSeries);
					vStatusRow.GuestIdentityDocumentNumber = СокрЛП(vDocObj.Клиент.IdentityDocumentNumber);
					vStatusRow.GuestIdentityDocumentIssuedBy = СокрЛП(vDocObj.Клиент.IdentityDocumentIssuedBy);
					vStatusRow.GuestIdentityDocumentValidToDate = vDocObj.Клиент.IdentityDocumentValidToDate;
					vStatusRow.GuestIdentityDocumentIssueDate = vDocObj.Клиент.IdentityDocumentIssueDate;
					vStatusRow.GuestCitizenship = СокрЛП(vDocObj.Клиент.Гражданство.ISOCode);
					vStatusRow.GuestSendSMS = НЕ vDocObj.Клиент.NoSMSDelivery;
					vStatusRow.GuestSex = Left(СокрЛП(String(vDocObj.Клиент.Пол)), 1);
					vStatusRow.GuestLastName = СокрЛП(vDocObj.Клиент.Фамилия);
					vStatusRow.GuestFirstName = СокрЛП(vDocObj.Клиент.Имя);
					vStatusRow.GuestSecondName = СокрЛП(vDocObj.Клиент.Отчество);
					vStatusRow.GuestAddress = СокрЛП(vDocObj.Клиент.Address);
				Else
					vStatusRow.GuestCode = "";
					vStatusRow.GuestFullName = "";
					vStatusRow.GuestBirthDate = Неопределено;
					vStatusRow.GuestPassport = "";
					vStatusRow.GuestPhone = "";
					vStatusRow.GuestFax = "";
					vStatusRow.GuestEMail = "";
					vStatusRow.GuestIdentityDocumentType = ""; 
					vStatusRow.GuestIdentityDocumentSeries = ""; 
					vStatusRow.GuestIdentityDocumentNumber = ""; 
					vStatusRow.GuestIdentityDocumentIssuedBy = ""; 
					vStatusRow.GuestIdentityDocumentValidToDate = Неопределено;
					vStatusRow.GuestIdentityDocumentIssueDate = Неопределено;
					vStatusRow.GuestCitizenship = ""; 
					vStatusRow.GuestSendSMS = Неопределено;
					vStatusRow.GuestSex = ""; 
					vStatusRow.GuestLastName = ""; 
					vStatusRow.GuestFirstName = ""; 
					vStatusRow.GuestSecondName = ""; 
					vStatusRow.GuestAddress = "";
				EndIf;
				vStatusRow.RoomQuantity = vDocObj.RoomQuantity;
				vStatusRow.КоличествоЧеловек = vDocObj.КоличествоЧеловек;
				vStatusRow.ТипНомера = vExtRoomTypeCode;
				vStatusRow.RoomTypeCode = vRoomTypeCode;
				vStatusRow.RoomTypeDescription = vRoomTypeDescription;
				vStatusRow.ВидРазмещения = vExtAccommodationTypeCode;
				vStatusRow.AccommodationTypeCode = vAccommodationTypeCode;
				vStatusRow.AccommodationTypeDescription = vAccommodationTypeDescription;
				vStatusRow.CheckInDate = vDocObj.CheckInDate;
				vStatusRow.Продолжительность = vDocObj.Продолжительность;
				vStatusRow.ДатаВыезда = vDocObj.ДатаВыезда;
				vStatusRow.Валюта = vReservationExtCurrencyCode;
				vStatusRow.CurrencyCode = СокрЛП(vReservationCurrency.Code);
				vStatusRow.CurrencyDescription = СокрЛП(vReservationCurrency.Description);
				vStatusRow.BaseCurrency = vExtBaseCurrencyCode;
				vStatusRow.CurrencyRate = vReservationCurrencyRate;
				vStatusRow.Сумма = vReservationSum;
				vStatusRow.SumPresentation = vReservationSumPresentation;
				vStatusRow.FirstDaySum = vFirstDaySum;
				vStatusRow.FirstDaySumPresentation = vFirstDaySumPresentation;
				vStatusRow.PaymentMethodCodesAllowedOnline = vDocObj.Тариф.PaymentMethodCodesAllowedOnline;
				vStatusRow.ExtReservationCode = СокрЛП(vDocObj.ExternalCode);
				vStatusRow.RoomQuotaCode = СокрЛП(vDocObj.КвотаНомеров.Code);
				
				vRetXDTO.ExternalReservationStatusRow.Add(vStatusRow);
				
				// Fill main guest, Контрагент, contract, agent
				If ЗначениеЗаполнено(vDocObj.ГруппаГостей) Тогда
					vMainGuest = vDocObj.ГруппаГостей.Клиент;
					If ЗначениеЗаполнено(vDocObj.ГруппаГостей.ClientDoc) Тогда
						vMainCustomer = vDocObj.ГруппаГостей.ClientDoc.Контрагент;
						vMainContract = vDocObj.ГруппаГостей.ClientDoc.Договор;
						vMainAgent = vDocObj.ГруппаГостей.ClientDoc.Агент;
					EndIf;
				EndIf;
			Else
				vReservationNumber = "";
				vRoomCode = "";
				ВызватьИсключение rErrorDescription;
			EndIf;
		EndDo;
		// Write message to the reservation Отдел that new reservation was created
		If ЗначениеЗаполнено(vGuestGroup) And IsBlankString(rErrorDescription) And ЗначениеЗаполнено(vGuestGroup.Owner) And ЗначениеЗаполнено(vGuestGroup.Owner.ReservationDepartment) Тогда
			vReservationDepartment = vGuestGroup.Owner.ReservationDepartment;
			vClientDoc = vGuestGroup.ClientDoc;
			If ЗначениеЗаполнено(vClientDoc) And TypeOf(vClientDoc) = Type("DocumentRef.Бронирование") Тогда
				vPeriodStr = ", " + Format(vGuestGroup.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(vGuestGroup.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'");
				vMsgText = NStr("en='New external reservation was created! Reservation data: Group code " + СокрЛП(vGuestGroup) + vPeriodStr + ", НомерРазмещения type " + СокрЛП(vClientDoc.ТипНомера) + ", Клиент " + СокрЛП(vClientDoc.Клиент) + "'; 
				                |de='New external reservation was created! Reservation data: Group code " + СокрЛП(vGuestGroup) + vPeriodStr + ", НомерРазмещения type " + СокрЛП(vClientDoc.ТипНомера) + ", Клиент " + СокрЛП(vClientDoc.Клиент) + "'; 
				                |ru='Создана новая внешняя бронь! Данные брони: Код группы " + СокрЛП(vGuestGroup) + vPeriodStr + ", тип номера " + СокрЛП(vClientDoc.ТипНомера) + ", ФИО гостя " + СокрЛП(vClientDoc.Клиент) + "'");
				// Call API
				cmSendMessageToDepartment(vReservationDepartment, vMsgText, Неопределено, True, vGuestGroup);
			EndIf;
		EndIf;
		// Send E-Mail notification
		If vDocObj <> Неопределено And IsBlankString(rErrorDescription) Тогда
			If ЗначениеЗаполнено(vDocObj.ГруппаГостей.Клиент) And ЗначениеЗаполнено(vDocObj.ГруппаГостей.ClientDoc) And 
			   НЕ IsBlankString(vDocObj.ГруппаГостей.Клиент.EMail) And ЗначениеЗаполнено(vDocObj.ReservationStatus) Тогда
				vClientDocObj = vDocObj.ГруппаГостей.ClientDoc.GetObject();
				If TypeOf(vClientDocObj) = Type("DocumentObject.Бронирование") Тогда
					cmWriteReservationConfirmationGuestGroupAttachment(vClientDocObj);
				EndIf;
			EndIf;
		EndIf;
		// Send invoice by E-Mail
		If vDocObj <> Неопределено And IsBlankString(rErrorDescription) Тогда
			If ЗначениеЗаполнено(vDocObj.ГруппаГостей.Контрагент) And ЗначениеЗаполнено(vDocObj.ГруппаГостей.ClientDoc) And 
			   НЕ IsBlankString(vDocObj.ГруппаГостей.Контрагент.EMail) And ЗначениеЗаполнено(vDocObj.ReservationStatus) And vDocObj.ReservationStatus.IsActive And 
			   ЗначениеЗаполнено(vDocObj.ГруппаГостей.ClientDoc.Контрагент) And ЗначениеЗаполнено(vDocObj.ГруппаГостей.ClientDoc.PlannedPaymentMethod) And vDocObj.ГруппаГостей.ClientDoc.PlannedPaymentMethod.IsByBankTransfer Тогда
				vClientDocObj = vDocObj.ГруппаГостей.ClientDoc.GetObject();
				If TypeOf(vClientDocObj) = Type("DocumentObject.Бронирование") Тогда
					If НЕ vDocObj.ГруппаГостей.Контрагент.BelongsToItem(Справочники.Контрагенты.КонтрагентПоУмолчанию) And vDocObj.ГруппаГостей.Контрагент <> vDocObj.Гостиница.IndividualsCustomer Тогда
						cmWriteReservationInvoiceGuestGroupAttachment(vClientDocObj);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		// Release SMS delivery for this transaction
		ПараметрыСеанса.SMSDeliveryIsStopped = False;
		// Send reservation change status SMS notification
		If vDocObj <> Неопределено And IsBlankString(rErrorDescription) Тогда
			If ЗначениеЗаполнено(vDocObj.ГруппаГостей) And ЗначениеЗаполнено(vDocObj.ГруппаГостей.ClientDoc) Тогда
				vClientDocObj = vDocObj.ГруппаГостей.ClientDoc.GetObject();
				If TypeOf(vClientDocObj) = Type("DocumentObject.Бронирование") Тогда
					//vMessageDeliveryError = "";
					//If НЕ SMS.SendChangeDocumentSatusMessage(vClientDocObj.Ref, vMessageDeliveryError) Тогда
					//	WriteLogEvent(NStr("en='Document.MessageDelivery';ru='Документ.РассылкаСообщений';de='Document.MessageDelivery'"), EventLogLevel.Warning, vClientDocObj.Metadata(), vClientDocObj.Ref, vMessageDeliveryError);
					//EndIf;
				EndIf;
			EndIf;
		EndIf;
		// Fill first day price totals attributes
		If vTotalFirstDaySum <> 0 Тогда
			vTotalFirstDaySumPresentation = cmFormatSum(vTotalFirstDaySum, vCurrency, "NZ=");
		EndIf;
		// Add totals
		vRetXDTO.ГруппаГостей = Format(vGuestGroup.Code, "ND=12; NFD=0; NZ=; NG=; NN=");
		vRetXDTO.UUID = String(vGuestGroup.UUID());
		If ЗначениеЗаполнено(vMainCustomer) Тогда
			vRetXDTO.Контрагент = TrimR(vMainCustomer.Description);
			vRetXDTO.CustomerLegacyName = СокрЛП(vMainCustomer.LegacyName);
			vRetXDTO.CustomerLegacyAddress = СокрЛП(vMainCustomer.LegacyAddress);
			vRetXDTO.CustomerTIN = СокрЛП(vMainCustomer.TIN);
			vRetXDTO.CustomerKPP = СокрЛП(vMainCustomer.KPP);
			vRetXDTO.CustomerEMail = СокрЛП(vMainCustomer.EMail);
			vRetXDTO.CustomerPhone = СокрЛП(vMainCustomer.Телефон);
		Else
			vRetXDTO.Контрагент = "";
			vRetXDTO.CustomerLegacyName = "";
			vRetXDTO.CustomerLegacyAddress = "";
			vRetXDTO.CustomerTIN = "";
			vRetXDTO.CustomerKPP = "";
			vRetXDTO.CustomerEMail = "";
			vRetXDTO.CustomerPhone = "";
		EndIf;
		If ЗначениеЗаполнено(vMainContract) Тогда
			vRetXDTO.Договор = TrimR(vMainContract.Description);
		Else
			vRetXDTO.Договор = "";
		EndIf;
		If ЗначениеЗаполнено(vMainAgent) Тогда
			vRetXDTO.Агент = TrimR(vMainAgent.Description);
		Else
			vRetXDTO.Агент = "";
		EndIf;
		If ЗначениеЗаполнено(vMainGuest) Тогда
			vRetXDTO.GuestCode = СокрЛП(vMainGuest.Code);
			vRetXDTO.GuestFullName = TrimR(vMainGuest.FullName);
			vRetXDTO.GuestBirthDate = vMainGuest.ДатаРождения;
			vRetXDTO.GuestPassport = TrimR(TrimR(vMainGuest.IdentityDocumentSeries) + " " + TrimR(vMainGuest.IdentityDocumentNumber));
			vRetXDTO.GuestPhone = TrimR(vMainGuest.Телефон);
			vRetXDTO.GuestFax = TrimR(vMainGuest.Fax);
			vRetXDTO.GuestEMail = TrimR(vMainGuest.EMail);
		Else
			vRetXDTO.GuestCode = "";
			vRetXDTO.GuestFullName = "";
			vRetXDTO.GuestBirthDate = Неопределено;
			vRetXDTO.GuestPassport = "";
			vRetXDTO.GuestPhone = "";
			vRetXDTO.GuestFax = "";
			vRetXDTO.GuestEMail = "";
		EndIf;
		vRetXDTO.Валюта = vCurrencyExtCode;
		vRetXDTO.CurrencyCode = СокрЛП(vCurrency.Code);
		vRetXDTO.CurrencyDescription = СокрЛП(vCurrency.Description);
		vRetXDTO.BaseCurrency = vExtBaseCurrencyCode;
		vRetXDTO.CurrencyRate = vCurrencyRate;
		vRetXDTO.TotalSum = vTotalSum;
		vRetXDTO.TotalSumPresentation = cmFormatSum(vTotalSum, vCurrency, "NZ=");
		vRetXDTO.BalanceAmount = vTotalSum;
		vRetXDTO.BalanceAmountPresentation = cmFormatSum(vTotalSum, vCurrency, "NZ=");
		vRetXDTO.FirstDaySum = vTotalFirstDaySum;
		vRetXDTO.FirstDaySumPresentation = vTotalFirstDaySumPresentation;
		vRetXDTO.HotelName = vGuestGroup.Owner.GetObject().pmGetHotelPrintName(vLanguage);
		vRetXDTO.HotelCode = СокрЛП(vGuestGroup.Owner.Code);
		vRetXDTO.ReservationConditions = vGuestGroup.Owner.ReservationConditions;
		If ЗначениеЗаполнено(vGuestGroup.ClientDoc) And 
		  (TypeOf(vGuestGroup.ClientDoc) = Type("DocumentRef.Размещение") Or TypeOf(vGuestGroup.ClientDoc) = Type("DocumentRef.Бронирование")) Тогда
			vRoomRate = vGuestGroup.ClientDoc.Тариф;
			If ЗначениеЗаполнено(vRoomRate) Тогда
				vRetXDTO.RoomRateCode = СокрЛП(vRoomRate.Code);
				vRetXDTO.RoomRateDescription = vRoomRate.GetObject().pmGetRoomRateDescription(vLanguage);
				vRetXDTO.ReservationConditions = vRoomRate.ReservationConditions;
				vRetXDTO.ReservationConditionsShort = vRoomRate.ReservationConditionsShort;
				vRetXDTO.ReservationConditionsOnline = vRoomRate.ReservationConditionsOnline;
				vRetXDTO.PaymentMethodCodesAllowedOnline = СокрЛП(vRoomRate.PaymentMethodCodesAllowedOnline);
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vGuestGroup.CheckDate) Тогда
			vRetXDTO.CheckDate = vGuestGroup.CheckDate;
		EndIf;
		vRetXDTO.ExtGuestGroupCode = СокрЛП(vGuestGroup.ExternalCode);
		// Commit transaction
		If vInternalTransaction And TransactionActive() Тогда
			CommitTransaction();
		EndIf;
		// Return 
		Return vRetXDTO;
	Except
		vErrorDescription = ErrorDescription();
		// Write log event
		WriteLogEvent("Записать внешнюю бронь", EventLogLevel.Error, , ,"Описание ошибки: " + vErrorDescription);
		// Rollback transaction
		If vInternalTransaction And TransactionActive() Тогда
			RollbackTransaction();
		EndIf;
		// Run SMS delivery for this transaction
		ПараметрыСеанса.SMSDeliveryIsStopped = False;
		// Return
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chote7l.ru/interfaces/reservation/", "ExternalGroupReservationStatus"));
		vRetXDTO.ErrorDescription = Left(vErrorDescription, 2048);
		vRetXDTO.ГруппаГостей = "";
		vRetXDTO.UUID = "";
		vRetXDTO.Валюта = "";
		vRetXDTO.TotalSum = 0;
		vRetXDTO.TotalSumPresentation = "";
		vRetXDTO.BalanceAmount = 0;
		vRetXDTO.BalanceAmountPresentation = "";
		vRetXDTO.FirstDaySum = 0;
		vRetXDTO.FirstDaySumPresentation = "";
		Return vRetXDTO;
	EndTry;
EndFunction //cmWriteExternalGroupReservation

//-----------------------------------------------------------------------------
// Description: This API is used to retrive reservation status data from the external system
// Parameters: External reservation code, Гостиница code, External system code, Language code, 
//             Type of return value: XDTO object or CSV string
// Return value: XDTO ExternalReservationStatus object
//-----------------------------------------------------------------------------
Function cmGetExternalReservationStatus(pExtReservationCode, pHotelCode, pExternalSystemCode, pLanguageCode = "RU", pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Get external reservation status';ru='Получить статус внешней брони';de='Liste externer Reservierung erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='External system reservation identifier: ';ru='Идентификатор брони во внешней системе: ';de='Identifikator der Reservierung im externen System: '") + pExtReservationCode);
	// Get language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Try to find existing reservation with given external code
	vErrorDescription = "";
	vDocRef = cmGetReservationByExternalCode(vHotel, pExtReservationCode);
	If ЗначениеЗаполнено(vDocRef) Тогда
		// Fill reservation totals assuming that all sums are in one currency.
		vExtReservationStatusCode = "";
		vExtReservationStatusCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "СтатусБрони", vDocRef.ReservationStatus);
		If IsBlankString(vExtReservationStatusCode) Тогда
			vExtReservationStatusCode = СокрЛП(vDocRef.ReservationStatus.Description);
		EndIf;
		vReservationStatusDescription = vDocRef.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage);
		vReservationSum = 0;
		vReservationCurrency = Справочники.Валюты.EmptyRef();
		vReservationExtCurrencyCode = "";
		vReservationSumPresentation = "";
		If vDocRef.Услуги.Count() > 0 Тогда
			vReservationCurrency = vDocRef.Услуги.Get(0).ВалютаЛицСчета;
			vReservationExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "Валюты", vReservationCurrency);
			If IsBlankString(vReservationExtCurrencyCode) Тогда
				vReservationExtCurrencyCode = СокрЛП(vReservationCurrency.Description);
			EndIf;
			vReservationSum = vDocRef.Услуги.Total("Сумма") - vDocRef.Услуги.Total("СуммаСкидки");
			vReservationSumPresentation = cmFormatSum(vReservationSum, vReservationCurrency, "NZ=");
		EndIf;
		// Get base currency code
		vBaseCurrency = vDocRef.Гостиница.BaseCurrency;
		vExtBaseCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "Валюты", vBaseCurrency);
		If IsBlankString(vExtBaseCurrencyCode) Тогда
			vExtBaseCurrencyCode = СокрЛП(vBaseCurrency.Description);
		EndIf;
		// Get currency rate
		vReservationCurrencyRate = 1;
		If ЗначениеЗаполнено(vReservationCurrency) Тогда
			vReservationCurrencyRate = cmGetCurrencyExchangeRate(vDocRef.Гостиница, vReservationCurrency, CurrentDate());
		EndIf;
		// ГруппаНомеров type and accommodation type
		vExtRoomTypeCode = "";
		vRoomTypeCode = "";
		vRoomTypeDescription = "";
		If ЗначениеЗаполнено(vDocRef.ТипНомераРасчет) Тогда
			vRoomTypeObj = vDocRef.ТипНомераРасчет.GetObject();
			vRoomTypeCode = СокрЛП(vDocRef.ТипНомераРасчет.Code);
			vRoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
			vExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "ТипыНомеров", vDocRef.ТипНомераРасчет);
			If IsBlankString(vExtRoomTypeCode) Тогда
				vExtRoomTypeCode = СокрЛП(vDocRef.ТипНомераРасчет.Description);
			EndIf;
		ElsIf ЗначениеЗаполнено(vDocRef.ТипНомера) Тогда
			vRoomTypeObj = vDocRef.ТипНомера.GetObject();
			vRoomTypeCode = СокрЛП(vDocRef.ТипНомера.Code);
			vRoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
			vExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "ТипыНомеров", vDocRef.ТипНомера);
			If IsBlankString(vExtRoomTypeCode) Тогда
				vExtRoomTypeCode = СокрЛП(vDocRef.ТипНомера.Description);
			EndIf;
		EndIf;
		vExtAccommodationTypeCode = "";
		vAccommodationTypeCode = "";
		vAccommodationTypeDescription = "";
		If ЗначениеЗаполнено(vDocRef.ВидРазмещения) Тогда
			vAccommodationTypeObj = vDocRef.ВидРазмещения.GetObject();
			vAccommodationTypeCode = СокрЛП(vDocRef.ВидРазмещения.Code);
			vAccommodationTypeDescription = vAccommodationTypeObj.pmGetAccommodationTypeDescription(vLanguage);
			vExtAccommodationTypeCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "ВидыРазмещения", vDocRef.ВидРазмещения);
			If IsBlankString(vExtAccommodationTypeCode) Тогда
				vExtAccommodationTypeCode = СокрЛП(vDocRef.ВидРазмещения.Description);
			EndIf;
		EndIf;
		// Fill reservation first day price
		vFirstDaySum = 0;
		vFirstDaySumCurrency = Неопределено;
		vFirstDaySumPresentation = "";
		vPrices = vDocRef.GetObject().pmGetPrices(True);
		vFirstAccDate = Неопределено;
		For Each vPricesRow In vPrices Do
			If НЕ ЗначениеЗаполнено(vFirstAccDate) Тогда
				vFirstAccDate = vPricesRow.УчетнаяДата;
				vFirstDaySumCurrency = vPricesRow.ВалютаЛицСчета;
			EndIf;
			If vPricesRow.УчетнаяДата = vFirstAccDate Тогда
				vFirstDaySum = vFirstDaySum + vPricesRow.Цена;
			Else
				Break;
			EndIf;
		EndDo;
		If vFirstDaySumCurrency <> vReservationCurrency Тогда
			vFirstDaySum = Round(cmConvertCurrencies(vFirstDaySum, vFirstDaySumCurrency, , vReservationCurrency, , CurrentDate(), vDocRef.Гостиница), 2);
		EndIf;
		If vFirstDaySum <> 0 Тогда
			vFirstDaySumPresentation = cmFormatSum(vFirstDaySum, vReservationCurrency, "NZ=");
		EndIf;
		// Build return string
		vRetStr = """" + vErrorDescription + """" + "," + """" + СокрЛП(vDocRef.НомерДока) + """" + "," + 
		          """" + СокрЛП(vExtReservationStatusCode) + """" + "," + """" + cmRemoveComma(vDocRef.ConfirmationReply) + """" + "," + 
		          """" + СокрЛП(vDocRef.Posted) + """" + "," + """" + Format(vDocRef.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=") + """" + "," + 
		          """" + СокрЛП(vDocRef.ReservationStatus.Code) + """" + "," + """" + cmRemoveComma(vReservationStatusDescription) + """" + "," + 
				  Format(vDocRef.RoomQuantity, "ND=10; NFD=0; NZ=; NG=") + "," + Format(vDocRef.КоличествоЧеловек, "ND=10; NFD=0; NZ=; NG=") + "," + 
				  """" + СокрЛП(vExtRoomTypeCode) + """" + "," + """" + СокрЛП(vRoomTypeCode) + """" + "," + """" + cmRemoveComma(vRoomTypeDescription) + """" + "," + 
				  """" + СокрЛП(vExtAccommodationTypeCode) + """" + "," + """" + СокрЛП(vAccommodationTypeCode) + """" + "," + """" + cmRemoveComma(vAccommodationTypeDescription) + """" + "," + 
				  """" + Format(vDocRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + """" + "," + Format(vDocRef.Продолжительность, "ND=10; NFD=0; NZ=; NG=") + "," + """" + Format(vDocRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + """" + "," + 
				  """" + СокрЛП(vReservationExtCurrencyCode) + """" + "," + """" + СокрЛП(vReservationCurrency.Code) + """" + "," + """" + cmRemoveComma(vReservationCurrency.Description) + """" + "," + 
		          Format(vReservationSum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
				  """" + cmRemoveComma(vReservationSumPresentation) + """" + "," + 
				  Format(vFirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
				  """" + cmRemoveComma(vFirstDaySumPresentation) + """";
		// Write log event
		WriteLogEvent(NStr("en='Get external reservation status';ru='Получить статус внешней брони';de='Liste externer Reservierung erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf:'") + vRetStr);
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vStatusRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatusRow"));
			vStatusRow.IsPosted = vDocRef.Posted;
			vStatusRow.ReservationNumber = СокрЛП(vDocRef.НомерДока);
			vStatusRow.ReservationStatus = vExtReservationStatusCode;
			vStatusRow.ReservationStatusCode = СокрЛП(vDocRef.ReservationStatus.Code);
			vStatusRow.ReservationStatusDescription = vReservationStatusDescription;
			vStatusRow.ConfirmationReply = Left(СокрЛП(vDocRef.ConfirmationReply), 2048);
			vStatusRow.ГруппаГостей = Format(vDocRef.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=");
			If ЗначениеЗаполнено(vDocRef.Клиент) Тогда
				vStatusRow.GuestFullName = TrimR(vDocRef.Клиент.FullName);
				vStatusRow.GuestBirthDate = vDocRef.Клиент.ДатаРождения;
				vStatusRow.GuestPassport = TrimR(TrimR(vDocRef.Клиент.IdentityDocumentSeries) + " " + TrimR(vDocRef.Клиент.IdentityDocumentNumber));
				vStatusRow.GuestPhone = TrimR(vDocRef.Клиент.Телефон);
				vStatusRow.GuestFax = TrimR(vDocRef.Клиент.Fax);
				vStatusRow.GuestEMail = TrimR(vDocRef.Клиент.EMail);
				vStatusRow.GuestIdentityDocumentType = СокрЛП(vDocRef.Клиент.IdentityDocumentType.Code); 
				vStatusRow.GuestIdentityDocumentSeries = СокрЛП(vDocRef.Клиент.IdentityDocumentSeries);
				vStatusRow.GuestIdentityDocumentNumber = СокрЛП(vDocRef.Клиент.IdentityDocumentNumber);
				vStatusRow.GuestIdentityDocumentIssuedBy = СокрЛП(vDocRef.Клиент.IdentityDocumentIssuedBy);
				vStatusRow.GuestIdentityDocumentValidToDate = vDocRef.Клиент.IdentityDocumentValidToDate;
				vStatusRow.GuestIdentityDocumentIssueDate = vDocRef.Клиент.IdentityDocumentIssueDate;
				vStatusRow.GuestCitizenship = СокрЛП(vDocRef.Клиент.Гражданство.ISOCode);
				vStatusRow.GuestSendSMS = НЕ vDocRef.Клиент.NoSMSDelivery;
				vStatusRow.GuestSex = Left(СокрЛП(String(vDocRef.Клиент.Пол)), 1);
				vStatusRow.GuestLastName = СокрЛП(vDocRef.Клиент.Фамилия);
				vStatusRow.GuestFirstName = СокрЛП(vDocRef.Клиент.Имя);
				vStatusRow.GuestSecondName = СокрЛП(vDocRef.Клиент.Отчество);
				vStatusRow.GuestAddress = СокрЛП(vDocRef.Клиент.Address);
			Else
				vStatusRow.GuestFullName = "";
				vStatusRow.GuestBirthDate = Неопределено;
				vStatusRow.GuestPassport = "";
				vStatusRow.GuestPhone = "";
				vStatusRow.GuestFax = "";
				vStatusRow.GuestEMail = "";
				vStatusRow.GuestIdentityDocumentType = ""; 
				vStatusRow.GuestIdentityDocumentSeries = ""; 
				vStatusRow.GuestIdentityDocumentNumber = ""; 
				vStatusRow.GuestIdentityDocumentIssuedBy = ""; 
				vStatusRow.GuestIdentityDocumentValidToDate = Неопределено;
				vStatusRow.GuestIdentityDocumentIssueDate = Неопределено;
				vStatusRow.GuestCitizenship = ""; 
				vStatusRow.GuestSendSMS = Неопределено;
				vStatusRow.GuestSex = ""; 
				vStatusRow.GuestLastName = ""; 
				vStatusRow.GuestFirstName = ""; 
				vStatusRow.GuestSecondName = ""; 
				vStatusRow.GuestAddress = "";
			EndIf;
			vStatusRow.RoomQuantity = vDocRef.RoomQuantity;
			vStatusRow.КоличествоЧеловек = vDocRef.КоличествоЧеловек;
			vStatusRow.ТипНомера = vExtRoomTypeCode;
			vStatusRow.RoomTypeCode = vRoomTypeCode;
			vStatusRow.RoomTypeDescription = vRoomTypeDescription;
			vStatusRow.ВидРазмещения = vExtAccommodationTypeCode;
			vStatusRow.AccommodationTypeCode = vAccommodationTypeCode;
			vStatusRow.AccommodationTypeDescription = vAccommodationTypeDescription;
			vStatusRow.CheckInDate = vDocRef.CheckInDate;
			vStatusRow.Продолжительность = vDocRef.Продолжительность;
			vStatusRow.ДатаВыезда = vDocRef.ДатаВыезда;
			vStatusRow.Валюта = vReservationExtCurrencyCode;
			vStatusRow.CurrencyCode = СокрЛП(vReservationCurrency.Code);
			vStatusRow.CurrencyDescription = СокрЛП(vReservationCurrency.Description);
			vStatusRow.BaseCurrency = vExtBaseCurrencyCode;
			vStatusRow.CurrencyRate = vReservationCurrencyRate;
			vStatusRow.Сумма = vReservationSum;
			vStatusRow.SumPresentation = vReservationSumPresentation;
			vStatusRow.FirstDaySum = vFirstDaySum;
			vStatusRow.FirstDaySumPresentation = vFirstDaySumPresentation;
			vStatusRow.PaymentMethodCodesAllowedOnline = vDocRef.Тариф.PaymentMethodCodesAllowedOnline;
			vStatusRow.ExtReservationCode = СокрЛП(vDocRef.ExternalCode);
			vStatusRow.RoomQuotaCode = СокрЛП(vDocRef.КвотаНомеров.Code);
			
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatus"));
			vRetXDTO.ErrorDescription = "";
			vRetXDTO.ExternalReservationStatusRow = vStatusRow;
			Return vRetXDTO;
		EndIf;
	Else
		vErrorDescription = NStr("en='Reservation was not found by external system code!';ru='Не удалось найти бронь по ее коду во внешней системе!';de='Die Reservierung konnte nach ihrem Code im externen System nicht gefunden werden!'");
		// Build return string
		vRetStr = """" + vErrorDescription + """";
		// Write log event
		WriteLogEvent(NStr("en='Get external reservation status';ru='Получить статус внешней брони';de='Liste externer Reservierung erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatus"));
			vRetXDTO.ErrorDescription = vErrorDescription;
			Return vRetXDTO;
		EndIf;
	EndIf;
EndFunction //cmGetExternalReservationStatus

//-----------------------------------------------------------------------------
// Description: This API is used to retrive guest group status data
// Parameters: External guest group code, Гостиница code, External system code, Language code, 
//             Type of return value: XDTO object or CSV string
// Return value: XDTO ExternalGroupReservationStatus object
//-----------------------------------------------------------------------------
Function cmGetExternalGroupReservationStatus(pExtGroupCode, pHotelCode, pExternalSystemCode, pLanguageCode = "RU", pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Get external group reservation status';ru='Получить статус внешней группы';de='Satus der externen Gruppe erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='External system group code: ';ru='Код группы во внешней системе: ';de='Gruppencode im externen System: '") + pExtGroupCode);
	vRetStr = "";
	// Get language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Try to find existing guest group with given external code
	vErrorDescription = "";
	vMainCustomer = Неопределено;
	vMainContract = Неопределено;
	vMainAgent = Неопределено;
	If StrLen(pExtGroupCode) = 36 Тогда
		vGroupRef = Справочники.ГруппыГостей.GetRef(New UUID(СокрЛП(pExtGroupCode)));
	Else
		vGroupRef = cmGetGuestGroupByExternalCode(vHotel, pExtGroupCode, "", "", False);
	EndIf;
	If ЗначениеЗаполнено(vGroupRef) Тогда
		// Get group totals
		vGroupObj = vGroupRef.GetObject();
		vReservations = vGroupObj.pmGetReservations(True, True);
		vSalesTotals = vGroupObj.pmGetSalesTotals();
		vPaymentTotals = vGroupObj.pmGetPaymentsTotals();
		If ЗначениеЗаполнено(vGroupRef.ClientDoc) Тогда
			vMainCustomer = vGroupRef.ClientDoc.Контрагент;
			vMainContract = vGroupRef.ClientDoc.Договор;
			vMainAgent = vGroupRef.ClientDoc.Агент;
		EndIf;
		// Get total group amount
		vSum = 0;
		vCurrency = vHotel.BaseCurrency;
		vExtCurrencyCode = "";
		vSumPresentation = "";
		If vSalesTotals.Count() > 0 Тогда
			vCurrency = vSalesTotals.Get(0).Валюта;
			For Each vSalesTotalsRow In vSalesTotals Do
				If vSalesTotalsRow.Валюта = vCurrency Тогда
					vSum = vSum + vSalesTotalsRow.Продажи + vSalesTotalsRow.ПрогнозПродаж;
				Else
					vSum = vSum + cmConvertCurrencies(vSalesTotalsRow.Продажи + vSalesTotalsRow.ПрогнозПродаж, vSalesTotalsRow.Валюта, , vCurrency, , CurrentDate(), vHotel);
				EndIf;
			EndDo;
			vSum = Round(vSum, 2);
		EndIf;
		vSumPresentation = cmFormatSum(vSum, vCurrency, "NZ=");
		vExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vGroupRef.Owner, pExternalSystemCode, "Валюты", vCurrency);
		If IsBlankString(vExtCurrencyCode) Тогда
			vExtCurrencyCode = СокрЛП(vCurrency.Description);
		EndIf;
		// Get base currency code
		vBaseCurrency = vHotel.BaseCurrency;
		vExtBaseCurrencyCode = cmGetObjectExternalSystemCodeByRef(vGroupRef.Owner, pExternalSystemCode, "Валюты", vBaseCurrency);
		If IsBlankString(vExtBaseCurrencyCode) Тогда
			vExtBaseCurrencyCode = СокрЛП(vBaseCurrency.Description);
		EndIf;
		// Get currency rate
		vCurrencyRate = cmGetCurrencyExchangeRate(vHotel, vCurrency, CurrentDate());
		// Get group balance
		vPaymentSum = 0;
		For Each vPaymentTotalsRow In vPaymentTotals Do
			If vPaymentTotalsRow.Валюта = vCurrency Тогда
				vPaymentSum = vPaymentSum + vPaymentTotalsRow.Сумма;
			Else
				vPaymentSum = vPaymentSum + cmConvertCurrencies(vPaymentTotalsRow.Сумма, vPaymentTotalsRow.Валюта, , vCurrency, , CurrentDate(), vHotel);
			EndIf;
			vPaymentSum = Round(vPaymentSum, 2);
		EndDo;
		vBalanceAmount = vSum - vPaymentSum;
		vBalanceAmountPresentation = cmFormatSum(vBalanceAmount, vCurrency, "NZ=");
		// Initialize first day amount
		vFirstDayAmount = 0;
		vFirstDayAmountPresentation = "";
		// Check number of ГруппаНомеров reservations found
		If vReservations.Count() = 0 Тогда
			If ЗначениеЗаполнено(vGroupRef.Status) Тогда
				If TypeOf(vGroupRef.Status) = Type("CatalogRef.СтатусБрони") Тогда
					vErrorDescription = "Бронь аннулирована! Статус брони:" ;
				ElsIf TypeOf(vGroupRef.Status) = Type("CatalogRef.СтатусРазмещения") Тогда 
					vErrorDescription = "По брони оформлено поселение!";
				ElsIf TypeOf(vGroupRef.Status) = Type("CatalogRef.СтатусБрониРесурсов") Тогда 
					vErrorDescription = "В группе нет брони номеров";
				EndIf;
			Else
				vErrorDescription = "Бронь аннулирована!";
			EndIf;
		EndIf;
		// Build return XDTO object
		If pOutputType = "XDTO" Тогда
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chote7l.ru/interfaces/reservation/", "ExternalGroupReservationStatus"));
			vRetXDTO.ErrorDescription = "";
			vRetXDTO.ГруппаГостей = Format(vGroupRef.Code, "ND=12; NFD=0; NZ=; NG=; NN=");
			vRetXDTO.UUID = String(vGroupRef.UUID());
			If vReservations.Count() = 0 Тогда
				// Build return string
				vRetStr = """" + vErrorDescription + """" + "," + 
				          """" + Format(vGroupRef.Code, "ND=12; NFD=0; NZ=; NG=; NN=") + """" + "," + 
						  """" + СокрЛП(vGroupRef.ExternalCode) + """";
				// Write log event
				WriteLogEvent("Получить статус внешней группы", EventLogLevel.Information, , ,"Строка возврата:" + vRetStr);
				// Fill error description
				vRetXDTO.ErrorDescription = vErrorDescription;
				// Return
				Return vRetXDTO;
			EndIf;
			If ЗначениеЗаполнено(vMainCustomer) Тогда
				vRetXDTO.Контрагент = TrimR(vMainCustomer.Description);
				vRetXDTO.CustomerLegacyName = СокрЛП(vMainCustomer.LegacyName);
				vRetXDTO.CustomerLegacyAddress = СокрЛП(vMainCustomer.LegacyAddress);
				vRetXDTO.CustomerTIN = СокрЛП(vMainCustomer.TIN);
				vRetXDTO.CustomerKPP = СокрЛП(vMainCustomer.KPP);
				vRetXDTO.CustomerEMail = СокрЛП(vMainCustomer.EMail);
				vRetXDTO.CustomerPhone = СокрЛП(vMainCustomer.Телефон);
			Else
				vRetXDTO.Контрагент = "";
				vRetXDTO.CustomerLegacyName = "";
				vRetXDTO.CustomerLegacyAddress = "";
				vRetXDTO.CustomerTIN = "";
				vRetXDTO.CustomerKPP = "";
				vRetXDTO.CustomerEMail = "";
				vRetXDTO.CustomerPhone = "";
			EndIf;
			If ЗначениеЗаполнено(vMainContract) Тогда
				vRetXDTO.Договор = TrimR(vMainContract.Description);
			Else
				vRetXDTO.Договор = "";
			EndIf;
			If ЗначениеЗаполнено(vMainAgent) Тогда
				vRetXDTO.Агент = TrimR(vMainAgent.Description);
			Else
				vRetXDTO.Агент = "";
			EndIf;
			If ЗначениеЗаполнено(vGroupRef.Клиент) Тогда
				vRetXDTO.GuestCode = СокрЛП(vGroupRef.Клиент.Code);
				vRetXDTO.GuestFullName = TrimR(vGroupRef.Клиент.FullName);
				If ЗначениеЗаполнено(vGroupRef.Клиент.ДатаРождения) Тогда
					vRetXDTO.GuestBirthDate = vGroupRef.Клиент.ДатаРождения;
				Else
					vRetXDTO.GuestBirthDate = '00010101';
				EndIf;
				vRetXDTO.GuestPassport = TrimR(TrimR(vGroupRef.Клиент.IdentityDocumentSeries) + " " + TrimR(vGroupRef.Клиент.IdentityDocumentNumber));
				vRetXDTO.GuestPhone = TrimR(vGroupRef.Клиент.Телефон);
				vRetXDTO.GuestFax = TrimR(vGroupRef.Клиент.Fax);
				vRetXDTO.GuestEMail = TrimR(vGroupRef.Клиент.EMail);
			Else
				vRetXDTO.GuestCode = "";
				vRetXDTO.GuestFullName = "";
				vRetXDTO.GuestBirthDate = '00010101';
				vRetXDTO.GuestPassport = "";
				vRetXDTO.GuestPhone = "";
				vRetXDTO.GuestFax = "";
				vRetXDTO.GuestEMail = "";
			EndIf;
			vRetXDTO.Валюта = vExtCurrencyCode;
			vRetXDTO.CurrencyCode = TrimR(vCurrency.Code);
			vRetXDTO.CurrencyDescription = TrimR(vCurrency.Description);
			vRetXDTO.BaseCurrency = vExtBaseCurrencyCode;
			vRetXDTO.CurrencyRate = vCurrencyRate;
			vRetXDTO.TotalSum = vSum;
			vRetXDTO.TotalSumPresentation = vSumPresentation;
			vRetXDTO.BalanceAmount = vBalanceAmount;
			vRetXDTO.BalanceAmountPresentation = vBalanceAmountPresentation;
			vRetXDTO.ReservationConditions = vGroupRef.Owner.ReservationConditions;
			If ЗначениеЗаполнено(vGroupRef.ClientDoc) And 
			  (TypeOf(vGroupRef.ClientDoc) = Type("DocumentRef.Размещение") Or TypeOf(vGroupRef.ClientDoc) = Type("DocumentRef.Бронирование")) Тогда
				vRoomRate = vGroupRef.ClientDoc.Тариф;
				If ЗначениеЗаполнено(vRoomRate) Тогда
					vRetXDTO.RoomRateCode = СокрЛП(vRoomRate.Code);
					vRetXDTO.RoomRateDescription = vRoomRate.GetObject().pmGetRoomRateDescription(vLanguage);
					vRetXDTO.ReservationConditions = vRoomRate.ReservationConditions;
					vRetXDTO.ReservationConditionsShort = vRoomRate.ReservationConditionsShort;
					vRetXDTO.ReservationConditionsOnline = vRoomRate.ReservationConditionsOnline;
					vRetXDTO.PaymentMethodCodesAllowedOnline = СокрЛП(vRoomRate.PaymentMethodCodesAllowedOnline);
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(vGroupRef.CheckDate) Тогда
				vRetXDTO.CheckDate = vGroupRef.CheckDate;
			EndIf;
			vRetXDTO.ExtGuestGroupCode = СокрЛП(vGroupRef.ExternalCode);
		ElsIf pOutputType = "CSV" Тогда
			If vReservations.Count() = 0 Тогда
				// Build return string
				vRetStr = """" + vErrorDescription + """" + "," + 
				          """" + Format(vGroupRef.Code, "ND=12; NFD=0; NZ=; NG=; NN=") + """" + "," +
						  """" + СокрЛП(vGroupRef.ExternalCode) + """";
				// Write log event
				WriteLogEvent("Получить статус внешней группы", EventLogLevel.Information, , , "Строка возврата: " + vRetStr);
				// Return
				Return vRetStr;
			EndIf;
		EndIf;			
		// Do for each document in the group
		vDocsStr = "";
		For Each vReservationsRow In vReservations Do
			vDocRef = vReservationsRow.Бронирование;
			// Fill reservation totals assuming that all sums are in one currency.
			vExtReservationStatusCode = "";
			vExtReservationStatusCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "СтатусБрони", vDocRef.ReservationStatus);
			If IsBlankString(vExtReservationStatusCode) Тогда
				vExtReservationStatusCode = СокрЛП(vDocRef.ReservationStatus.Description);
			EndIf;
			vReservationStatusDescription = vDocRef.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage);
			vReservationSum = 0;
			vReservationCurrency = Справочники.Валюты.EmptyRef();
			vReservationExtCurrencyCode = "";
			vReservationSumPresentation = "";
			If vDocRef.Услуги.Count() > 0 Тогда
				vReservationCurrency = vDocRef.Услуги.Get(0).ВалютаЛицСчета;
				vReservationExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "Валюты", vReservationCurrency);
				If IsBlankString(vReservationExtCurrencyCode) Тогда
					vReservationExtCurrencyCode = СокрЛП(vReservationCurrency.Description);
				EndIf;
				vReservationSum = vDocRef.Услуги.Total("Сумма") - vDocRef.Услуги.Total("СуммаСкидки");
				vReservationSumPresentation = cmFormatSum(vReservationSum, vReservationCurrency, "NZ=");
			EndIf;
			// Get base currency code
			vBaseCurrency = vDocRef.Гостиница.BaseCurrency;
			vExtBaseCurrencyCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "Валюты", vBaseCurrency);
			If IsBlankString(vExtBaseCurrencyCode) Тогда
				vExtBaseCurrencyCode = СокрЛП(vBaseCurrency.Description);
			EndIf;
			// Get currency rate
			vReservationCurrencyRate = 1;
			If ЗначениеЗаполнено(vReservationCurrency) Тогда
				vReservationCurrencyRate = cmGetCurrencyExchangeRate(vDocRef.Гостиница, vReservationCurrency, CurrentDate());
			EndIf;
			// ГруппаНомеров type and accommodation type
			vExtRoomTypeCode = "";
			vRoomTypeCode = "";
			vRoomTypeDescription = "";
			If ЗначениеЗаполнено(vDocRef.ТипНомераРасчет) Тогда
				vRoomTypeObj = vDocRef.ТипНомераРасчет.GetObject();
				vRoomTypeCode = СокрЛП(vDocRef.ТипНомераРасчет.Code);
				vRoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
				vExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "ТипыНомеров", vDocRef.ТипНомераРасчет);
				If IsBlankString(vExtRoomTypeCode) Тогда
					vExtRoomTypeCode = СокрЛП(vDocRef.ТипНомераРасчет.Description);
				EndIf;
			ElsIf ЗначениеЗаполнено(vDocRef.ТипНомера) Тогда
				vRoomTypeObj = vDocRef.ТипНомера.GetObject();
				vRoomTypeCode = СокрЛП(vDocRef.ТипНомера.Code);
				vRoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
				vExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "ТипыНомеров", vDocRef.ТипНомера);
				If IsBlankString(vExtRoomTypeCode) Тогда
					vExtRoomTypeCode = СокрЛП(vDocRef.ТипНомера.Description);
				EndIf;
			EndIf;
			vExtAccommodationTypeCode = "";
			vAccommodationTypeCode = "";
			vAccommodationTypeDescription = "";
			If ЗначениеЗаполнено(vDocRef.ВидРазмещения) Тогда
				vAccommodationTypeObj = vDocRef.ВидРазмещения.GetObject();
				vAccommodationTypeCode = СокрЛП(vDocRef.ВидРазмещения.Code);
				vAccommodationTypeDescription = vAccommodationTypeObj.pmGetAccommodationTypeDescription(vLanguage);
				vExtAccommodationTypeCode = cmGetObjectExternalSystemCodeByRef(vDocRef.Гостиница, pExternalSystemCode, "ВидыРазмещения", vDocRef.ВидРазмещения);
				If IsBlankString(vExtAccommodationTypeCode) Тогда
					vExtAccommodationTypeCode = СокрЛП(vDocRef.ВидРазмещения.Description);
				EndIf;
			EndIf;
			// Fill reservation first day price
			vFirstDaySum = 0;
			vFirstDaySumCurrency = Неопределено;
			vFirstDaySumPresentation = "";
			vPrices = vDocRef.GetObject().pmGetPrices(True);
			vFirstAccDate = Неопределено;
			For Each vPricesRow In vPrices Do
				If НЕ ЗначениеЗаполнено(vFirstAccDate) Тогда
					vFirstAccDate = vPricesRow.УчетнаяДата;
					vFirstDaySumCurrency = vPricesRow.ВалютаЛицСчета;
				EndIf;
				If vPricesRow.УчетнаяДата = vFirstAccDate Тогда
					vFirstDaySum = vFirstDaySum + vPricesRow.Цена;
				Else
					Break;
				EndIf;
			EndDo;
			If vFirstDaySumCurrency <> vCurrency Тогда
				vFirstDaySum = Round(cmConvertCurrencies(vFirstDaySum, vFirstDaySumCurrency, , vCurrency, , CurrentDate(), vDocRef.Гостиница), 2);
			EndIf;
			If vFirstDaySum <> 0 Тогда
				vFirstDaySumPresentation = cmFormatSum(vFirstDaySum, vCurrency, "NZ=");
			EndIf;
			vFirstDayAmount = vFirstDayAmount + vFirstDaySum;
			// Build return string
			vDocsStr = vDocsStr + Chars.LF + """" + СокрЛП(vDocRef.НомерДока) + """" + "," + """" + СокрЛП(vDocRef.ExternalCode) + """" + "," + 
			          """" + СокрЛП(vExtReservationStatusCode) + """" + "," + """" + cmRemoveComma(vDocRef.ConfirmationReply) + """" + "," + 
			          """" + СокрЛП(vDocRef.Posted) + """" + "," + """" + Format(vDocRef.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=") + """" + "," + 
			          """" + СокрЛП(vDocRef.ReservationStatus.Code) + """" + "," + """" + cmRemoveComma(vReservationStatusDescription) + """" + "," + 
					  Format(vDocRef.RoomQuantity, "ND=10; NFD=0; NZ=; NG=") + "," + Format(vDocRef.КоличествоЧеловек, "ND=10; NFD=0; NZ=; NG=") + "," + 
					  """" + СокрЛП(vExtRoomTypeCode) + """" + "," + """" + СокрЛП(vRoomTypeCode) + """" + "," + """" + cmRemoveComma(vRoomTypeDescription) + """" + "," + 
					  """" + СокрЛП(vExtAccommodationTypeCode) + """" + "," + """" + СокрЛП(vAccommodationTypeCode) + """" + "," + """" + cmRemoveComma(vAccommodationTypeDescription) + """" + "," + 
					  """" + Format(vDocRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + """" + "," + Format(vDocRef.Продолжительность, "ND=10; NFD=0; NZ=; NG=") + "," + """" + Format(vDocRef.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + """" + "," + 
					  """" + СокрЛП(vReservationExtCurrencyCode) + """" + "," + """" + СокрЛП(vReservationCurrency.Code) + """" + "," + """" + cmRemoveComma(vReservationCurrency.Description) + """" + "," + 
			          Format(vReservationSum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
					  """" + cmRemoveComma(vReservationSumPresentation) + """" + "," + 
					  Format(vFirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
					  """" + cmRemoveComma(vFirstDaySumPresentation) + """";
			If pOutputType = "XDTO" Тогда
				vStatusRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExternalReservationStatusRow"));
				vStatusRow.IsPosted = vDocRef.Posted;
				vStatusRow.ReservationNumber = СокрЛП(vDocRef.НомерДока);
				vStatusRow.ReservationStatus = vExtReservationStatusCode;
				vStatusRow.ReservationStatusCode = СокрЛП(vDocRef.ReservationStatus.Code);
				vStatusRow.ReservationStatusDescription = vReservationStatusDescription;
				vStatusRow.ConfirmationReply = Left(СокрЛП(vDocRef.ConfirmationReply), 2048);
				vStatusRow.ГруппаГостей = Format(vDocRef.ГруппаГостей.Code, "ND=12; NFD=0; NZ=; NG=; NN=");
				If ЗначениеЗаполнено(vDocRef.Клиент) Тогда
					vStatusRow.GuestCode = СокрЛП(vDocRef.Клиент.Code);
					vStatusRow.GuestFullName = TrimR(vDocRef.Клиент.FullName);
					If ЗначениеЗаполнено(vDocRef.Клиент.ДатаРождения) Тогда
						vStatusRow.GuestBirthDate = vDocRef.Клиент.ДатаРождения;
					Else
						vStatusRow.GuestBirthDate = '00010101';
					EndIf;
					vStatusRow.GuestPassport = TrimR(TrimR(vDocRef.Клиент.IdentityDocumentSeries) + " " + TrimR(vDocRef.Клиент.IdentityDocumentNumber));
					vStatusRow.GuestPhone = TrimR(vDocRef.Клиент.Телефон);
					vStatusRow.GuestFax = TrimR(vDocRef.Клиент.Fax);
					vStatusRow.GuestEMail = TrimR(vDocRef.Клиент.EMail);
					vStatusRow.GuestIdentityDocumentType = СокрЛП(vDocRef.Клиент.IdentityDocumentType.Code); 
					vStatusRow.GuestIdentityDocumentSeries = СокрЛП(vDocRef.Клиент.IdentityDocumentSeries);
					vStatusRow.GuestIdentityDocumentNumber = СокрЛП(vDocRef.Клиент.IdentityDocumentNumber);
					vStatusRow.GuestIdentityDocumentIssuedBy = СокрЛП(vDocRef.Клиент.IdentityDocumentIssuedBy);
					vStatusRow.GuestIdentityDocumentValidToDate = vDocRef.Клиент.IdentityDocumentValidToDate;
					vStatusRow.GuestIdentityDocumentIssueDate = vDocRef.Клиент.IdentityDocumentIssueDate;
					vStatusRow.GuestCitizenship = СокрЛП(vDocRef.Клиент.Гражданство.ISOCode);
					vStatusRow.GuestSendSMS = НЕ vDocRef.Клиент.NoSMSDelivery;
					vStatusRow.GuestSex = Left(СокрЛП(String(vDocRef.Клиент.Пол)), 1);
					vStatusRow.GuestLastName = СокрЛП(vDocRef.Клиент.Фамилия);
					vStatusRow.GuestFirstName = СокрЛП(vDocRef.Клиент.Имя);
					vStatusRow.GuestSecondName = СокрЛП(vDocRef.Клиент.Отчество);
					vStatusRow.GuestAddress = СокрЛП(vDocRef.Клиент.Address);
				Else
					vStatusRow.GuestCode = "";
					vStatusRow.GuestFullName = "";
					vStatusRow.GuestBirthDate = '00010101';
					vStatusRow.GuestPassport = "";
					vStatusRow.GuestPhone = "";
					vStatusRow.GuestFax = "";
					vStatusRow.GuestEMail = "";
					vStatusRow.GuestIdentityDocumentType = ""; 
					vStatusRow.GuestIdentityDocumentSeries = ""; 
					vStatusRow.GuestIdentityDocumentNumber = ""; 
					vStatusRow.GuestIdentityDocumentIssuedBy = ""; 
					vStatusRow.GuestIdentityDocumentValidToDate = Неопределено;
					vStatusRow.GuestIdentityDocumentIssueDate = Неопределено;
					vStatusRow.GuestCitizenship = ""; 
					vStatusRow.GuestSendSMS = Неопределено;
					vStatusRow.GuestSex = ""; 
					vStatusRow.GuestLastName = ""; 
					vStatusRow.GuestFirstName = ""; 
					vStatusRow.GuestSecondName = "";
					vStatusRow.GuestAddress = "";
				EndIf;
				vStatusRow.RoomQuantity = vDocRef.RoomQuantity;
				vStatusRow.КоличествоЧеловек = vDocRef.КоличествоЧеловек;
				vStatusRow.ТипНомера = vExtRoomTypeCode;
				vStatusRow.RoomTypeCode = vRoomTypeCode;
				vStatusRow.RoomTypeDescription = vRoomTypeDescription;
				vStatusRow.ВидРазмещения = vExtAccommodationTypeCode;
				vStatusRow.AccommodationTypeCode = vAccommodationTypeCode;
				vStatusRow.AccommodationTypeDescription = vAccommodationTypeDescription;
				vStatusRow.CheckInDate = vDocRef.CheckInDate;
				vStatusRow.Продолжительность = vDocRef.Продолжительность;
				vStatusRow.ДатаВыезда = vDocRef.ДатаВыезда;
				vStatusRow.Валюта = vReservationExtCurrencyCode;
				vStatusRow.CurrencyCode = СокрЛП(vReservationCurrency.Code);
				vStatusRow.CurrencyDescription = СокрЛП(vReservationCurrency.Description);
				vStatusRow.BaseCurrency = vExtBaseCurrencyCode;
				vStatusRow.CurrencyRate = vReservationCurrencyRate;
				vStatusRow.Сумма = vReservationSum;
				vStatusRow.SumPresentation = vReservationSumPresentation;
				vStatusRow.FirstDaySum = vFirstDaySum;
				vStatusRow.FirstDaySumPresentation = vFirstDaySumPresentation;
				vStatusRow.PaymentMethodCodesAllowedOnline = vDocRef.Тариф.PaymentMethodCodesAllowedOnline;
				vStatusRow.ExtReservationCode = СокрЛП(vDocRef.ExternalCode);
				vStatusRow.RoomQuotaCode = СокрЛП(vDocRef.КвотаНомеров.Code);
				
				//Extra sevices
				vQ = New Query;
				//vDocObj = Documents.Бронирование.CreateDocument();
				vQ.Text = "SELECT
				          |	ReservationServices.Ref,
				          |	ReservationServices.Услуга.Code AS ServiceCode,
				          |	ReservationServices.Услуга,
				          |	ReservationServices.Сумма,
				          |	ReservationServices.Скидка,
				          |	ReservationServices.ВалютаЛицСчета AS Валюта,
				          |	ReservationServices.ВалютаЛицСчета.Code AS CurrencyCode,
				          |	ReservationServices.Примечания
				          |FROM
				          |	Document.Бронирование.Услуги AS ReservationServices
				          |WHERE
				          |	ReservationServices.Ref = &Ref
				          |	AND ReservationServices.IsManual";
				vQ.SetParameter("Ref",vDocRef);
				
				
				
			EndIf;
		EndDo;
		vFirstDayAmount = Round(vFirstDayAmount, 2);
		vFirstDayAmountPresentation = cmFormatSum(vFirstDayAmount, vCurrency, "NZ=");
		// Build return string
		vRetStr = """" + vErrorDescription + """" + "," + 
		          """" + Format(vGroupRef.Code, "ND=12; NFD=0; NZ=; NG=; NN=") + """" + "," + 
		          """" + СокрЛП(vGroupRef.ExternalCode) + """" + "," + 
		          """" + СокрЛП(vExtCurrencyCode) + """" + "," + 
				  Format(vSum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
		          """" + cmRemoveComma(vSumPresentation) + """" + "," + 
				  Format(vFirstDayAmount, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
				  """" + cmRemoveComma(vFirstDayAmountPresentation) + """" + "," + 
				  Format(vBalanceAmount, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
				  """" + cmRemoveComma(vBalanceAmountPresentation) + """" + "," + 
		          vDocsStr;
		// Write log event
		WriteLogEvent(NStr("en='Get external group reservation status';ru='Получить статус внешней группы';de='Satus der externen Gruppe erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO.FirstDaySum = vFirstDayAmount;
			vRetXDTO.FirstDaySumPresentation = vFirstDayAmountPresentation;
			vRetXDTO.HotelName = vGroupObj.Owner.GetObject().pmGetHotelPrintName(vLanguage);
			vRetXDTO.HotelCode = СокрЛП(vGroupObj.Owner.Code);
			vRetXDTO.ErrorDescription = "";
		EndIf;
		Return vRetXDTO;
	Else
		vErrorDescription = "Не удалось найти группу по ее коду во внешней системе!";
		// Build return string
		vRetStr = """" + vErrorDescription + """";
		// Write log event
		WriteLogEvent("Получить статус внешней группы", EventLogLevel.Information, , , "Строка возврата:" + vRetStr);
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chot7el.ru/interfaces/reservation/", "ExternalGroupReservationStatus"));
			vRetXDTO.ErrorDescription = vErrorDescription;
			Return vRetXDTO;
		EndIf;
	EndIf;
EndFunction //cmGetExternalGroupReservationStatus

//-----------------------------------------------------------------------------
// Description: This API is used to retrieve daily vacant ГруппаНомеров balances for the 
//              given ГруппаНомеров quota or ГруппаНомеров inventory in total
// Parameters: Гостиница, ГруппаНомеров type, Контрагент, Contract, Agent, ГруппаНомеров quota, Period from,
//             Period to
// Return value: Value table with vacant ГруппаНомеров balances grouped by hotel, ГруппаНомеров type and day
//-----------------------------------------------------------------------------
Function cmGetRoomQuotaBalances(pHotel, pRoomType, pCustomer, pContract, pAgent, pRoomQuota, pPeriodFrom, pPeriodTo) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	КвотаНомеров.Гостиница AS Гостиница,
	|	КвотаНомеров.ТипНомера AS ТипНомера,
	|	КвотаНомеров.КвотаНомеров AS КвотаНомеров,
	|	КвотаНомеров.Period AS Period,
	|	SUM(КвотаНомеров.RoomsVacant) AS RoomsVacant,
	|	SUM(КвотаНомеров.BedsVacant) AS BedsVacant,
	|	SUM(КвотаНомеров.НомеровКвота) AS НомеровКвота,
	|	SUM(КвотаНомеров.МестКвота) AS МестКвота,
	|	SUM(КвотаНомеров.RoomsChargedInQuota) AS RoomsChargedInQuota,
	|	SUM(КвотаНомеров.BedsChargedInQuota) AS BedsChargedInQuota,
	|	SUM(КвотаНомеров.ЗабронНомеров) AS ЗабронНомеров,
	|	SUM(КвотаНомеров.ЗабронированоМест) AS ЗабронированоМест,
	|	SUM(КвотаНомеров.ИспользованоНомеров) AS ИспользованоНомеров,
	|	SUM(КвотаНомеров.ИспользованоМест) AS ИспользованоМест,
	|	SUM(КвотаНомеров.ОстаетсяНомеров) AS ОстаетсяНомеров,
	|	SUM(КвотаНомеров.ОстаетсяМест) AS ОстаетсяМест
	|FROM
	|	(SELECT
	|		ТипыНомеров.Owner AS Гостиница,
	|		ТипыНомеров.Ref AS ТипНомера,
	|		&qEmptyRoomQuota AS КвотаНомеров,
	|		ЗагрузкаНомеров.Period AS Period,
	|		ЗагрузкаНомеров.RoomsVacant AS RoomsVacant,
	|		ЗагрузкаНомеров.BedsVacant AS BedsVacant,
	|		NULL AS НомеровКвота,
	|		NULL AS МестКвота,
	|		NULL AS RoomsChargedInQuota,
	|		NULL AS BedsChargedInQuota,
	|		NULL AS ЗабронНомеров,
	|		NULL AS ЗабронированоМест,
	|		NULL AS ИспользованоНомеров,
	|		NULL AS ИспользованоМест,
	|		NULL AS ОстаетсяНомеров,
	|		NULL AS ОстаетсяМест
	|	FROM
	|		Catalog.ТипыНомеров AS ТипыНомеров
	|			LEFT JOIN (SELECT
	|				RoomInventoryBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|				BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY) AS Period,
	|				MAX(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|				MIN(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance) AS RoomsVacant,
	|				MIN(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance) AS BedsVacant
	|			FROM
	|				AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|						&qPeriodFrom,
	|						&qPeriodTo,
	|						SECOND,
	|						RegisterRecordsAndPeriodBoundaries,
	|						(Гостиница IN HIERARCHY (&qHotel)
	|							OR &qHotelIsEmpty)
	|							AND (ТипНомера IN HIERARCHY (&qRoomType)
	|								OR &qRoomTypeIsEmpty)) AS RoomInventoryBalanceAndTurnovers
	|			
	|			GROUP BY
	|				RoomInventoryBalanceAndTurnovers.ТипНомера,
	|				BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY)) AS ЗагрузкаНомеров
	|			ON (ЗагрузкаНомеров.ТипНомера = ТипыНомеров.Ref)
	|	WHERE
	|		&qRoomQuotaIsEmpty
	|		AND NOT ТипыНомеров.DeletionMark
	|		AND NOT ТипыНомеров.IsFolder
	|		AND NOT ТипыНомеров.ВиртуальныйНомер
	|		AND (ТипыНомеров.Owner IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|		AND (ТипыНомеров.Ref IN HIERARCHY (&qRoomType)
	|				OR &qRoomTypeIsEmpty)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		ТипыНомеров.Owner,
	|		ТипыНомеров.Ref,
	|		ПродажиКвот.КвотаНомеров,
	|		ПродажиКвот.Period,
	|		NULL,
	|		NULL,
	|		ПродажиКвот.НомеровКвота,
	|		ПродажиКвот.МестКвота,
	|		ПродажиКвот.RoomsChargedInQuota,
	|		ПродажиКвот.BedsChargedInQuota,
	|		ПродажиКвот.ЗабронНомеров,
	|		ПродажиКвот.ЗабронированоМест,
	|		ПродажиКвот.ИспользованоНомеров,
	|		ПродажиКвот.ИспользованоМест,
	|		ПродажиКвот.ОстаетсяНомеров,
	|		ПродажиКвот.ОстаетсяМест
	|	FROM
	|		Catalog.ТипыНомеров AS ТипыНомеров
	|			LEFT JOIN (SELECT
	|				RoomQuotaSalesBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|				RoomQuotaSalesBalanceAndTurnovers.КвотаНомеров AS КвотаНомеров,
	|				RoomQuotaSalesBalanceAndTurnovers.Period AS Period,
	|				RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
	|				RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS НомеровКвота,
	|				RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS МестКвота,
	|				CASE
	|					WHEN ISNULL(RoomQuotaSalesBalanceAndTurnovers.КвотаНомеров.DoCharge, FALSE)
	|						THEN RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance
	|					ELSE 0
	|				END AS RoomsChargedInQuota,
	|				CASE
	|					WHEN ISNULL(RoomQuotaSalesBalanceAndTurnovers.КвотаНомеров.DoCharge, FALSE)
	|						THEN RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance
	|					ELSE 0
	|				END AS BedsChargedInQuota,
	|				-RoomQuotaSalesBalanceAndTurnovers.RoomsReservedClosingBalance AS ЗабронНомеров,
	|				-RoomQuotaSalesBalanceAndTurnovers.BedsReservedClosingBalance AS ЗабронированоМест,
	|				-RoomQuotaSalesBalanceAndTurnovers.InHouseRoomsClosingBalance AS ИспользованоНомеров,
	|				-RoomQuotaSalesBalanceAndTurnovers.InHouseBedsClosingBalance AS ИспользованоМест,
	|				RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS ОстаетсяНомеров,
	|				RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS ОстаетсяМест
	|			FROM
	|				AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|						&qPeriodFrom,
	|						&qPeriodTo,
	|						Day,
	|						RegisterRecordsAndPeriodBoundaries,
	|						(Гостиница IN HIERARCHY (&qHotel)
	|							OR &qHotelIsEmpty)
	|							AND (ТипНомера IN HIERARCHY (&qRoomType)
	|								OR &qRoomTypeIsEmpty)
	|							AND КвотаНомеров IN HIERARCHY (&qRoomQuota)
	|							AND (КвотаНомеров.Агент IN HIERARCHY (&qAgent)
	|								OR &qAgentIsEmpty)
	|							AND (КвотаНомеров.Контрагент IN HIERARCHY (&qCustomer)
	|								OR &qCustomerIsEmpty)
	|							AND (КвотаНомеров.Договор = &qContract
	|								OR &qContractIsEmpty)) AS RoomQuotaSalesBalanceAndTurnovers) AS ПродажиКвот
	|			ON (ПродажиКвот.ТипНомера = ТипыНомеров.Ref)
	|	WHERE
	|		NOT &qRoomQuotaIsEmpty
	|		AND NOT ТипыНомеров.DeletionMark
	|		AND NOT ТипыНомеров.IsFolder
	|		AND NOT ТипыНомеров.ВиртуальныйНомер
	|		AND (ТипыНомеров.Owner IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|		AND (ТипыНомеров.Ref IN HIERARCHY (&qRoomType)
	|				OR &qRoomTypeIsEmpty)) AS КвотаНомеров
	|
	|GROUP BY
	|	КвотаНомеров.Гостиница,
	|	КвотаНомеров.ТипНомера,
	|	КвотаНомеров.КвотаНомеров,
	|	КвотаНомеров.Period
	|
	|ORDER BY
	|	КвотаНомеров.Гостиница.ПорядокСортировки,
	|	КвотаНомеров.ТипНомера.ПорядокСортировки,
	|	КвотаНомеров.КвотаНомеров.Code,
	|	Period";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(pHotel));
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(pRoomType));
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(pCustomer));
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qContractIsEmpty", НЕ ЗначениеЗаполнено(pContract));
	vQry.SetParameter("qAgent", pAgent);
	vQry.SetParameter("qAgentIsEmpty", НЕ ЗначениеЗаполнено(pAgent));
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(pRoomQuota));
	vQry.SetParameter("qPeriodFrom", BegOfDay(pPeriodFrom));
	vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
	vQry.SetParameter("qEmptyRoomQuota", Справочники.КвотаНомеров.EmptyRef());
	vQry.SetParameter("qShiftInSeconds", -43200);
	vQryRes = vQry.Execute().Unload();
	vQryRes.GroupBy("Гостиница, ТипНомера, Period", "RoomsVacant, BedsVacant, НомеровКвота, МестКвота, " + 
	                                           "RoomsChargedInQuota, BedsChargedInQuota, ЗабронНомеров, ЗабронированоМест, " + 
	                                           "ИспользованоНомеров, ИспользованоМест, ОстаетсяНомеров, ОстаетсяМест");
	Return vQryRes;
EndFunction //cmGetRoomQuotaBalances

//-----------------------------------------------------------------------------
Процедура GetDayAccommodationTypePrice(pPeriod, pPrices, pCalendarDayType, pRoomType, 
                                       pSingleAccommodationType, rSingleAccommodationTypePrice, rSingleAccommodationTypePriceCurrency,
                                       pDoubleAccommodationType, rDoubleAccommodationTypePrice, rDoubleAccommodationTypePriceCurrency, 
                                       pTripleAccommodationType, rTripleAccommodationTypePrice, rTripleAccommodationTypePriceCurrency, 
                                       pExtraBedAccommodationType, rExtraBedAccommodationTypePrice, rExtraBedAccommodationTypePriceCurrency)
	// Process single accommodation type
	vAccountingDate = BegOfDay(pPeriod);
	//rAccommodationTypePrice = 0;
	//rAccommodationTypePriceCurrency = Справочники.Валюты.EmptyRef();
	If pPrices.Count() > 0 And (ЗначениеЗаполнено(pSingleAccommodationType) Or ЗначениеЗаполнено(pDoubleAccommodationType) Or ЗначениеЗаполнено(pTripleAccommodationType) Or ЗначениеЗаполнено(pExtraBedAccommodationType)) Тогда
		// Get suitable prices
		For Each vPricesRow In pPrices Do
			If (НЕ ЗначениеЗаполнено(vPricesRow.УчетнаяДата) Or ЗначениеЗаполнено(vPricesRow.УчетнаяДата) And vPricesRow.УчетнаяДата = vAccountingDate) And 
			   (НЕ ЗначениеЗаполнено(vPricesRow.ТипДняКалендаря) Or ЗначениеЗаполнено(vPricesRow.ТипДняКалендаря) And vPricesRow.ТипДняКалендаря = pCalendarDayType) And 
			   (НЕ ЗначениеЗаполнено(vPricesRow.ТипНомера) Or ЗначениеЗаполнено(vPricesRow.ТипНомера) And vPricesRow.ТипНомера = pRoomType) Тогда
				If (НЕ ЗначениеЗаполнено(vPricesRow.ВидРазмещения) Or ЗначениеЗаполнено(vPricesRow.ВидРазмещения) And vPricesRow.ВидРазмещения = pSingleAccommodationType) Тогда
					If vPricesRow.IsRoomRevenue And НЕ ЗначениеЗаполнено(rSingleAccommodationTypePriceCurrency) Тогда
						rSingleAccommodationTypePriceCurrency = vPricesRow.Валюта;
					EndIf;
					If vPricesRow.IsInPrice Тогда
						If ЗначениеЗаполнено(vPricesRow.ServicePackage) And 
						  (pPeriod < vPricesRow.ServicePackageDateValidFrom Or pPeriod > vPricesRow.ServicePackageDateValidTo And ЗначениеЗаполнено(vPricesRow.ServicePackageDateValidTo)) Тогда
							Continue;
						EndIf;
						If vPricesRow.IsPricePerPerson Тогда
							rSingleAccommodationTypePrice = rSingleAccommodationTypePrice + ?(vPricesRow.КоличествоЧеловек = 0, 1, vPricesRow.КоличествоЧеловек) * ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						Else
							rSingleAccommodationTypePrice = rSingleAccommodationTypePrice + ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						EndIf;
					EndIf;
				EndIf;
				If (НЕ ЗначениеЗаполнено(vPricesRow.ВидРазмещения) Or ЗначениеЗаполнено(vPricesRow.ВидРазмещения) And vPricesRow.ВидРазмещения = pDoubleAccommodationType) Тогда
					If vPricesRow.IsRoomRevenue And НЕ ЗначениеЗаполнено(rDoubleAccommodationTypePriceCurrency) Тогда
						rDoubleAccommodationTypePriceCurrency = vPricesRow.Валюта;
					EndIf;
					If vPricesRow.IsInPrice Тогда
						If ЗначениеЗаполнено(vPricesRow.ServicePackage) And 
						  (pPeriod < vPricesRow.ServicePackageDateValidFrom Or pPeriod > vPricesRow.ServicePackageDateValidTo And ЗначениеЗаполнено(vPricesRow.ServicePackageDateValidTo)) Тогда
							Continue;
						EndIf;
						If vPricesRow.IsPricePerPerson Тогда
							rDoubleAccommodationTypePrice = rDoubleAccommodationTypePrice + ?(vPricesRow.КоличествоЧеловек = 0, 1, vPricesRow.КоличествоЧеловек) * ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						Else
							rDoubleAccommodationTypePrice = rDoubleAccommodationTypePrice + ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						EndIf;
					EndIf;
				EndIf;
				If (НЕ ЗначениеЗаполнено(vPricesRow.ВидРазмещения) Or ЗначениеЗаполнено(vPricesRow.ВидРазмещения) And vPricesRow.ВидРазмещения = pTripleAccommodationType) Тогда
					If vPricesRow.IsRoomRevenue And НЕ ЗначениеЗаполнено(rTripleAccommodationTypePriceCurrency) Тогда
						rTripleAccommodationTypePriceCurrency = vPricesRow.Валюта;
					EndIf;
					If vPricesRow.IsInPrice Тогда
						If ЗначениеЗаполнено(vPricesRow.ServicePackage) And 
						  (pPeriod < vPricesRow.ServicePackageDateValidFrom Or pPeriod > vPricesRow.ServicePackageDateValidTo And ЗначениеЗаполнено(vPricesRow.ServicePackageDateValidTo)) Тогда
							Continue;
						EndIf;
						If vPricesRow.IsPricePerPerson Тогда
							rTripleAccommodationTypePrice = rTripleAccommodationTypePrice + ?(vPricesRow.КоличествоЧеловек = 0, 1, vPricesRow.КоличествоЧеловек) * ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						Else
							rTripleAccommodationTypePrice = rTripleAccommodationTypePrice + ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						EndIf;
					EndIf;
				EndIf;
				If (НЕ ЗначениеЗаполнено(vPricesRow.ВидРазмещения) Or ЗначениеЗаполнено(vPricesRow.ВидРазмещения) And vPricesRow.ВидРазмещения = pExtraBedAccommodationType) Тогда
					If vPricesRow.IsRoomRevenue And НЕ ЗначениеЗаполнено(rExtraBedAccommodationTypePriceCurrency) Тогда
						rExtraBedAccommodationTypePriceCurrency = vPricesRow.Валюта;
					EndIf;
					If vPricesRow.IsInPrice Тогда
						If ЗначениеЗаполнено(vPricesRow.ServicePackage) And 
						  (pPeriod < vPricesRow.ServicePackageDateValidFrom Or pPeriod > vPricesRow.ServicePackageDateValidTo And ЗначениеЗаполнено(vPricesRow.ServicePackageDateValidTo)) Тогда
							Continue;
						EndIf;
						If vPricesRow.IsPricePerPerson Тогда
							rExtraBedAccommodationTypePrice = rExtraBedAccommodationTypePrice + ?(vPricesRow.КоличествоЧеловек = 0, 1, vPricesRow.КоличествоЧеловек) * ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						Else
							rExtraBedAccommodationTypePrice = rExtraBedAccommodationTypePrice + ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //GetDayAccommodationTypePrice

//-----------------------------------------------------------------------------
Function cmGetEffectivePriceTags(pHotel, pRoomRate, Val pRoomType, pPeriodFrom, pPeriodTo, rPriceTagsList) Экспорт
	vRoomType = pRoomType;
	If pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercent Or
	   pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomType Or
	   pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Тогда
		If ЗначениеЗаполнено(vRoomType) And ЗначениеЗаполнено(vRoomType.BaseRoomType) Тогда
			vRoomType = vRoomType.BaseRoomType;
		EndIf;
	EndIf;
	rPriceTagsList = New СписокЗначений();
	vOccupationPercents = New ValueTable();
	If pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercent Тогда
		vOccupationPercents = cmFillOccupationPercents(pHotel, pPeriodFrom, pPeriodTo);
	ElsIf pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomType Тогда
		vOccupationPercents = cmFillOccupationPercentsPerRoomType(pHotel, vRoomType, pPeriodFrom, pPeriodTo);
	ElsIf pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Тогда
		vOccupationPercents = cmFillOccupationPercentsPerRoomTypePerDayType(pHotel, vRoomType, pPeriodFrom, pPeriodTo, pRoomRate);
	EndIf;
	vTable = New ValueTable();
	vTable.Columns.Add("Period", cmGetDateTypeDescription());
	vTable.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
	vTable.Columns.Add("ПризнакЦены", cmGetCatalogTypeDescription("ПризнакЦены"));
	vCurDate = BegOfDay(pPeriodFrom);
	While vCurDate <= BegOfDay(pPeriodTo) Do
		vPriceTagRanges = cmGetPriceTagRanges(pHotel, pRoomRate.PriceTagType, vCurDate);
		If ЗначениеЗаполнено(pRoomRate) And ЗначениеЗаполнено(pRoomRate.PriceTagType) Тогда
			vCurPriceTag = Справочники.ПризнакЦены.EmptyRef();
			If pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByDurationOfStayByDays Тогда
				vCurDurationInDays = (vCurDate - BegOfDay(pPeriodFrom))/(24*3600) + 1;
				vCurDurationInDays = ?(vCurDurationInDays < 0, 0, vCurDurationInDays);
				For Each vPriceTagRangesRow In vPriceTagRanges Do
					If vCurDurationInDays >= vPriceTagRangesRow.StartValue And vCurDurationInDays <= vPriceTagRangesRow.EndValue Тогда
						vCurPriceTag = vPriceTagRangesRow.ПризнакЦены;
						Break;
					EndIf;
				EndDo;
				vTableRow = vTable.Add();
				vTableRow.Period = vCurDate;
				vTableRow.ПризнакЦены = vCurPriceTag;
				If rPriceTagsList.FindByValue(vCurPriceTag) = Неопределено Тогда
					rPriceTagsList.Add(vCurPriceTag);
				EndIf;
			ElsIf pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByDurationOfStayByPeriod Тогда
				vCurDurationInDays = (BegOfDay(pPeriodTo) - BegOfDay(pPeriodFrom))/(24*3600);
				vCurDurationInDays = ?(vCurDurationInDays <= 0, 1, vCurDurationInDays);
				For Each vPriceTagRangesRow In vPriceTagRanges Do
					If vCurDurationInDays >= vPriceTagRangesRow.StartValue And vCurDurationInDays <= vPriceTagRangesRow.EndValue Тогда
						vCurPriceTag = vPriceTagRangesRow.ПризнакЦены;
						Break;
					EndIf;
				EndDo;
				vTableRow = vTable.Add();
				vTableRow.Period = vCurDate;
				vTableRow.ПризнакЦены = vCurPriceTag;
				If rPriceTagsList.FindByValue(vCurPriceTag) = Неопределено Тогда
					rPriceTagsList.Add(vCurPriceTag);
				EndIf;
			ElsIf pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercent Тогда
				vCurOccupancyPercentRow = vOccupationPercents.Find(vCurDate, "УчетнаяДата");
				If vCurOccupancyPercentRow <> Неопределено Тогда
					vCurOccupancyPercent = vCurOccupancyPercentRow.OccupationPercent;
					For Each vPriceTagRangesRow In vPriceTagRanges Do
						If vCurOccupancyPercent >= vPriceTagRangesRow.StartValue And vCurOccupancyPercent <= vPriceTagRangesRow.EndValue Тогда
							vCurPriceTag = vPriceTagRangesRow.ПризнакЦены;
							Break;
						EndIf;
					EndDo;
				EndIf;
				vTableRow = vTable.Add();
				vTableRow.Period = vCurDate;
				vTableRow.ПризнакЦены = vCurPriceTag;
				If rPriceTagsList.FindByValue(vCurPriceTag) = Неопределено Тогда
					rPriceTagsList.Add(vCurPriceTag);
				EndIf;
			ElsIf pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomType Or 
			      pRoomRate.PriceTagType = Перечисления.PriceTagTypes.ByOccupancyPercentPerRoomTypePerDayType Тогда
				vCurOccupancyPercentRows = vOccupationPercents.FindRows(New Structure("УчетнаяДата", vCurDate));
				If vCurOccupancyPercentRows.Count() > 0 Тогда
					For Each vCurOccupancyPercentRow In vCurOccupancyPercentRows Do
						vCurRoomType = vCurOccupancyPercentRow.ТипНомера;
						vCurOccupancyPercent = vCurOccupancyPercentRow.OccupationPercent;
						For Each vPriceTagRangesRow In vPriceTagRanges Do
							If vCurOccupancyPercent >= vPriceTagRangesRow.StartValue And vCurOccupancyPercent <= vPriceTagRangesRow.EndValue Тогда
								vCurPriceTag = vPriceTagRangesRow.ПризнакЦены;
								Break;
							EndIf;
						EndDo;
						vTableRow = vTable.Add();
						vTableRow.Period = vCurDate;
						vTableRow.ТипНомера = vCurRoomType;
						vTableRow.ПризнакЦены = vCurPriceTag;
						If rPriceTagsList.FindByValue(vCurPriceTag) = Неопределено Тогда
							rPriceTagsList.Add(vCurPriceTag);
						EndIf;
					EndDo;
				EndIf;
			EndIf;
		Else
			vTableRow = vTable.Add();
			vTableRow.Period = vCurDate;
			vTableRow.ПризнакЦены = Справочники.ПризнакЦены.EmptyRef();
			If rPriceTagsList.FindByValue(vCurPriceTag) = Неопределено Тогда
				rPriceTagsList.Add(Справочники.ПризнакЦены.EmptyRef());
			EndIf;
		EndIf;
		vCurDate = vCurDate + 24*3600;
	EndDo;
	Return vTable;
EndFunction //cmGetEffectivePriceTags

//-----------------------------------------------------------------------------
Процедура cmRemovePriceTags(pPrices, pPriceTagsList, pPriceTags) Экспорт
	i = 0;
	While i < pPrices.Count() Do
		vRow = pPrices.Get(i);
		vPriceTagsList = pPriceTagsList;
		vPriceTagsPerRoomType = pPriceTags.FindRows(New Structure("ТипНомера", vRow.ТипНомера));
		If vPriceTagsPerRoomType.Count() > 0 Тогда
			vPriceTagsList = New СписокЗначений();
			For Each vPriceTagsPerRoomTypeRow In vPriceTagsPerRoomType Do
				vPriceTagsList.Add(vPriceTagsPerRoomTypeRow.ПризнакЦены);
			EndDo;
		EndIf;
		If vPriceTagsList.FindByValue(vRow.ПризнакЦены) = Неопределено Тогда
			pPrices.Delete(vRow);
			Continue;
		EndIf;
		i = i + 1;
	EndDo;
КонецПроцедуры //cmRemovePriceTags

//-----------------------------------------------------------------------------
Процедура GetDayPrices(pPeriod, pPrices, pPriceTags, pRoomRate, pRoomType, pSingle, pDouble, pTriple, pAddBed, pSinglePrice, pSinglePriceCurrency, pDoublePrice, pDoublePriceCurrency, pTriplePrice, pTriplePriceCurrency, pAddBedPrice, pAddBedPriceCurrency, pAllAccommodationTypes, pAccommodationTypePrices);
	vAccountingDate = BegOfDay(pPeriod);
	vPriceTag = Справочники.ПризнакЦены.EmptyRef();
	vPriceTagsRows = pPriceTags.FindRows(New Structure("Period, ТипНомера", vAccountingDate, pRoomType));
	If vPriceTagsRows.Count() = 0 Тогда
		vPriceTagsRows = pPriceTags.FindRows(New Structure("Period", vAccountingDate));
	EndIf;
	If vPriceTagsRows.Count() > 0 Тогда
		vPriceTagsRow = vPriceTagsRows.Get(0);
		vPriceTag = vPriceTagsRow.ПризнакЦены;
	EndIf;
	vPrices = pPrices.FindRows(New Structure("ПризнакЦены, IsInPrice", vPriceTag, True));

	// Get calendar day type
	vCalendarDayType = cmGetCalendarDayType(pRoomRate, vAccountingDate, Неопределено, Неопределено);
	
	// Process all accommodation types
	GetDayAccommodationTypePrice(pPeriod, vPrices, vCalendarDayType, pRoomType, pSingle, pSinglePrice, pSinglePriceCurrency, pDouble, pDoublePrice, pDoublePriceCurrency, pTriple, pTriplePrice, pTriplePriceCurrency, pAddBed, pAddBedPrice, pAddBedPriceCurrency);
	
	// Fill value table with accommodation prices
	If vPrices.Count() > 0 Тогда
		For Each vAllAccommodationTypesRow In pAllAccommodationTypes Do
			vAccommodationType = vAllAccommodationTypesRow.ВидРазмещения;
			vAccommodationTypePrice = 0;
			vAccommodationTypePriceCurrency = Неопределено;
			// Get suitable prices
			For Each vPricesRow In vPrices Do
				vPrAccDate = vPricesRow.УчетнаяДата;
				vPrCalDayType = vPricesRow.ТипДняКалендаря;
				vPrRoomType = vPricesRow.ТипНомера;
				vPrAccType = vPricesRow.ВидРазмещения;
				If (НЕ ЗначениеЗаполнено(vPrAccDate) Or ЗначениеЗаполнено(vPrAccDate) And vPrAccDate = vAccountingDate) And 
				   (НЕ ЗначениеЗаполнено(vPrCalDayType) Or ЗначениеЗаполнено(vPrCalDayType) And vPrCalDayType = vCalendarDayType) And 
				   (НЕ ЗначениеЗаполнено(vPrRoomType) Or ЗначениеЗаполнено(vPrRoomType) And vPrRoomType = pRoomType) And 
				   (НЕ ЗначениеЗаполнено(vPrAccType) Or ЗначениеЗаполнено(vPrAccType) And vPrAccType = vAccommodationType) Тогда
					If vPricesRow.IsRoomRevenue And НЕ ЗначениеЗаполнено(vAccommodationTypePriceCurrency) Тогда
						vAccommodationTypePriceCurrency = vPricesRow.Валюта;
					EndIf;
					If vPricesRow.IsInPrice Тогда
						If vPricesRow.IsPricePerPerson Тогда
							vAccommodationTypePrice = vAccommodationTypePrice + ?(vPricesRow.КоличествоЧеловек = 0, 1, vPricesRow.КоличествоЧеловек) * ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						Else
							vAccommodationTypePrice = vAccommodationTypePrice + ?(vPricesRow.Количество = 0, 1, vPricesRow.Количество) * vPricesRow.Цена;
						EndIf;
					EndIf;
				EndIf;
			EndDo;
			// Add accommodation type data to the value table
			If ЗначениеЗаполнено(vAccommodationTypePriceCurrency) Тогда
				vATPRow = pAccommodationTypePrices.Add();
				vATPRow.ВидРазмещения = vAccommodationType;
				vATPRow.Цена = vAccommodationTypePrice;
				vATPRow.PriceCurrency = vAccommodationTypePriceCurrency;
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //GetDayPrices

//-----------------------------------------------------------------------------
Function GetObjectExternalSystemCodeByRef(pCodesCash, pHotel, pExtSystemCode, pCatalogName, pItemRef)
	vCashRows = pCodesCash.FindRows(New Structure("Гостиница, ItemRef", pHotel, pItemRef));
	If vCashRows.Count() = 1 Тогда
		// Take code from the cash
		vExtItemCode = vCashRows.Get(0).ExtItemCode;
	Else
		// Take code from the settings information register
		vExtItemCode = cmGetObjectExternalSystemCodeByRef(pHotel, pExtSystemCode, pCatalogName, pItemRef);
		// Save code to the cash
		vCashRow = pCodesCash.Add();
		vCashRow.Гостиница = pHotel;
		vCashRow.ItemRef = pItemRef;
		vCashRow.ExtItemCode = vExtItemCode;
	EndIf;
	Return vExtItemCode;
EndFunction //GetObjectExternalSystemCodeByRef

//-----------------------------------------------------------------------------
// Description: This API is used to retrieve daily vacant ГруппаНомеров balances for the 
//              given ГруппаНомеров quota or ГруппаНомеров inventory in total and join this data with
//              ГруппаНомеров rate prices. Prices are returned for 1 guest, 2 guests in one ГруппаНомеров,
//              3 guests in one ГруппаНомеров and for additional bed
// Parameters: Гостиница, ГруппаНомеров type, Контрагент, Contract, Agent, ГруппаНомеров quota, Period from,
//             Period to, ГруппаНомеров rate code, Client type code, Flags what data to return, 
//             External system code, Language code, Output type: CSV, XDTO or XML, 
//             XML Writer to use in case of XML output
// Return value: CSV strings or XML or XDO RoomInventoryBalance object with vacant ГруппаНомеров 
//               balances grouped by hotel, ГруппаНомеров type and day joined with prices for the 
//               given ГруппаНомеров rate
//-----------------------------------------------------------------------------
Function cmGetRoomInventoryBalance(pHotelCode, pRoomTypeCode, pCustomerName, pContractName, pAgentName, 
                                   pRoomQuotaCode, pPeriodFrom, pPeriodTo, pRoomRateCode =  "", pClientTypeCode = "", 
								   pOutputRoomsVacant = True, pOutputBedsVacant = False, pOutputRoomsRemains = False, pOutputBedsRemains = False, 
								   pOutputRoomsInQuota = False, pOutputBedsInQuota = False, pOutputRoomsChargedInQuota = False, pOutputBedsChargedInQuota = False, 
								   pOutputRoomsReserved = False, pOutputBedsReserved = False, pOutputInHouseRooms = False, pOutputInHouseBeds = False, 
								   pExternalSystemCode, pLanguageCode = "RU", pOutputType = "CSV", pXMLWriter = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Get ГруппаНомеров inventory balance';ru='Получить остатки свободных номеров';de='Restbestände an freien Zimmern erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + pRoomTypeCode + Chars.LF + 
	              NStr("en='Allotment code: ';ru='Код квоты номеров: ';de='Zimmerquotencode: '") + pRoomQuotaCode + Chars.LF + 
	              NStr("en='Контрагент name: ';ru='Название контрагента: ';de='Bezeichnung des Partners: '") + pCustomerName + Chars.LF + 
	              NStr("en='Contract name: ';ru='Название договора: ';de='Bezeichnung des Vertrags: '") + pContractName + Chars.LF + 
	              NStr("en='Agent name: ';ru='Название агента: ';de='Bezeichnung des Vertreters: '") + pAgentName + Chars.LF + 
	              NStr("en='Period from: ';ru='Начало периода: ';de='Zeitraumbeginn: '") + pPeriodFrom + Chars.LF + 
	              NStr("en='Period to: ';ru='Конец периода: ';de='Zeitraumende: '") + pPeriodTo + Chars.LF +  
	              NStr("en='ГруппаНомеров rate code: ';ru='Код тарифа: ';de='Tarifcode: '") + pRoomRateCode + Chars.LF + 
	              NStr("en='Client type code: ';ru='Код типа клиента: ';de='Kundentypcode: '") + pClientTypeCode + Chars.LF + 
	              NStr("en='Output rooms vacant for the hotel: ';ru='Возвращать число свободных номеров по всей гостинице: ';de='Die Anzahl von freien Zimmern im gesamten Гостиница zurückgeben: '") + pOutputRoomsVacant + Chars.LF + 
	              NStr("en='Output beds vacant for the hotel: ';ru='Возвращать число свободных мест по всей гостинице: ';de='Die Anzahl von freien Plätzen im gesamten Гостиница zurückgeben: '") + pOutputBedsVacant + Chars.LF + 
	              NStr("en='Output rooms vacant for the allotment: ';ru='Возвращать число свободных номеров по квоте: ';de='Anzahl von freien Zimmern nach der Quote zurückgeben:'") + pOutputRoomsRemains + Chars.LF + 
	              NStr("en='Output beds vacant for the allotment: ';ru='Возвращать число свободных мест по квоте: ';de='Anzahl von freien Plätzen nach der Quote zurückgeben: '") + pOutputBedsRemains + Chars.LF + 
	              NStr("en='Output rooms in the allotment: ';ru='Возвращать число номеров в квоте: ';de='Die Anzahl von Zimmern in der Quote zurückgeben: '") + pOutputRoomsInQuota + Chars.LF + 
	              NStr("en='Output beds in the allotment: ';ru='Возвращать число мест в квоте: ';de='Die Anzahl von Plätzen in der Quote zurückgeben: '") + pOutputBedsInQuota + Chars.LF + 
	              NStr("en='Output charged rooms in the allotment: ';ru='Возвращать число номеров в оплаченной жесткой квоте: ';de='Die Anzahl von Zimmern in der bezahlten festen Quote zurückgeben: '") + pOutputRoomsChargedInQuota + Chars.LF + 
	              NStr("en='Output charged beds in the allotment: ';ru='Возвращать число мест в оплаченной жесткой квоте: ';de='Die Anzahl von Plätzen in der bezahlten festen Quote zurückgeben: '") + pOutputBedsChargedInQuota + Chars.LF + 
	              NStr("en='Output rooms reserved: ';ru='Возвращать число забронированных номеров: ';de='Die Anzahl von reservierten Zimmern zurückgeben: '") + pOutputRoomsReserved + Chars.LF + 
	              NStr("en='Output beds reserved: ';ru='Возвращать число забронированных мест: ';de='Die Anzahl von reservierten Plätzen zurückgeben: '") + pOutputBedsReserved + Chars.LF + 
	              NStr("en='Output inhouse rooms: ';ru='Возвращать число занятых номеров: ';de='Die Anzahl von belegten Zimmern zurückgeben: '") + pOutputInHouseRooms + Chars.LF + 
	              NStr("en='Output inhouse beds: ';ru='Возвращать число занятых мест: ';de='Die Anzahl von belegten Plätzen zurückgeben: '") + pOutputInHouseBeds);
	// Retrieve parameter references based on codes
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	vRoomType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыНомеров", pRoomTypeCode);
	vRoomQuota = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "КвотаНомеров", pRoomQuotaCode);
	vRoomRate = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Тарифы", pRoomRateCode);
	vClientType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыКлиентов", pClientTypeCode);
	vCustomer = cmGetCustomerByName(pCustomerName);
	vContract = cmGetContractByName(vCustomer, pContractName);
	vAgent = cmGetCustomerByName(pAgentName);
	// Create cash of external system codes
	vCodesCash = New ValueTable();
	vCodesCash.Columns.Add("Гостиница", cmGetCatalogTypeDescription("Гостиницы"));
	vCodesCash.Columns.Add("ItemRef");
	vCodesCash.Columns.Add("ExtItemCode", cmGetStringTypeDescription());
	// Call API to get value table with balances
	vBalances = cmGetRoomQuotaBalances(vHotel, vRoomType, vCustomer, vContract, vAgent, vRoomQuota, pPeriodFrom, pPeriodTo);
	// Check for stop internet sales
	For Each vRow In vBalances Do
		If vRow.Period = Null Тогда
			Continue;
		EndIf;
		If vRow.ТипНомера.СнятСПродажи Тогда
			vRemarks = "";
			If cmIsStopInternetSalePeriod(vRow.ТипНомера, vRow.Period, vRow.Period, vRemarks) Тогда
				vRow.RoomsVacant = 0;
				vRow.BedsVacant = 0;
				vRow.ОстаетсяНомеров = 0;
				vRow.ОстаетсяМест = 0;
			EndIf;
		EndIf;
	EndDo;
	// Initialize accommodation types to get prices for
	vSingle = Справочники.ВидыРазмещения.EmptyRef();
	vDouble = Справочники.ВидыРазмещения.EmptyRef();
	vTriple = Справочники.ВидыРазмещения.EmptyRef();
	vAddBed = Справочники.ВидыРазмещения.EmptyRef();
	vAccTypes = New ValueTable();
	vAccommodationTypePrices = New ValueTable();
	vAccommodationTypePrices.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
	vAccommodationTypePrices.Columns.Add("Цена", cmGetSumTypeDescription());
	vAccommodationTypePrices.Columns.Add("PriceCurrency", cmGetCatalogTypeDescription("Валюты"));
	// Get ГруппаНомеров rate prices if ГруппаНомеров rate is specified
	If ЗначениеЗаполнено(vRoomRate) Тогда
		vRoomRateObj = vRoomRate.GetObject();
		vServicePackagesList = vRoomRateObj.pmGetRoomRateServicePackagesList();
		vPrices = vRoomRateObj.pmGetRoomRatePrices(pPeriodFrom, , vClientType, vRoomType, , vServicePackagesList, , pPeriodFrom, pPeriodTo, True);
		vPriceTagsList = New СписокЗначений();
		vPriceTags = cmGetEffectivePriceTags(vHotel, vRoomRate, vRoomType, pPeriodFrom, pPeriodTo, vPriceTagsList);
		cmRemovePriceTags(vPrices, vPriceTagsList, vPriceTags);
		
		// Get accommodation types to return prices for
		vAccTypes = cmGetAllAccommodationTypes();
		For Each vAccTypesRow In vAccTypes Do
			If vAccTypesRow.ВидРазмещения.ТипРазмещения = Перечисления.ВидыРазмещений.НомерРазмещения Тогда
				If НЕ ЗначениеЗаполнено(vSingle) Тогда
					vSingle = vAccTypesRow.ВидРазмещения;
				ElsIf НЕ ЗначениеЗаполнено(vDouble) Тогда
					vDouble = vAccTypesRow.ВидРазмещения;
				ElsIf НЕ ЗначениеЗаполнено(vTriple) Тогда
					vTriple = vAccTypesRow.ВидРазмещения;
				EndIf;
			ElsIf vAccTypesRow.ВидРазмещения.ТипРазмещения = Перечисления.ВидыРазмещений.AdditionalBed Тогда
				If НЕ ЗначениеЗаполнено(vAddBed) Тогда
					vAddBed = vAccTypesRow.ВидРазмещения;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	// Add columns with hotel and ГруппаНомеров type external codes
	vBalances.Columns.Add("ExtHotelCode", cmGetStringTypeDescription());
	vBalances.Columns.Add("ExtRoomTypeCode", cmGetStringTypeDescription());
	vBalances.Columns.Add("Single", cmGetCatalogTypeDescription("ВидыРазмещения"));
	vBalances.Columns.Add("SinglePriceCurrency", cmGetCatalogTypeDescription("Валюты"));
	vBalances.Columns.Add("SinglePrice", cmGetNumberTypeDescription(17, 2));
	vBalances.Columns.Add("Double", cmGetCatalogTypeDescription("ВидыРазмещения"));
	vBalances.Columns.Add("DoublePriceCurrency", cmGetCatalogTypeDescription("Валюты"));
	vBalances.Columns.Add("DoublePrice", cmGetNumberTypeDescription(17, 2));
	vBalances.Columns.Add("Triple", cmGetCatalogTypeDescription("ВидыРазмещения"));
	vBalances.Columns.Add("TriplePriceCurrency", cmGetCatalogTypeDescription("Валюты"));
	vBalances.Columns.Add("TriplePrice", cmGetNumberTypeDescription(17, 2));
	vBalances.Columns.Add("AddBed", cmGetCatalogTypeDescription("ВидыРазмещения"));
	vBalances.Columns.Add("AddBedPriceCurrency", cmGetCatalogTypeDescription("Валюты"));
	vBalances.Columns.Add("AddBedPrice", cmGetNumberTypeDescription(17, 2));
	vBalances.Columns.Add("AccommodationTypePrices");
	// Build return string
	vRetStr = "";
	For Each vRow In vBalances Do
		If vRow.Period = Null Тогда
			Continue;
		EndIf;
		vRow.Period = EndOfDay(vRow.Period);
		vRow.ExtHotelCode = "";
		If ЗначениеЗаполнено(vRow.Гостиница) Тогда
			vRow.ExtHotelCode = GetObjectExternalSystemCodeByRef(vCodesCash, Справочники.Гостиницы.EmptyRef(), pExternalSystemCode, "Hotels", vRow.Гостиница);
		EndIf;
		vRow.ExtRoomTypeCode = "";
		If ЗначениеЗаполнено(vRow.ТипНомера) Тогда
			vRow.ExtRoomTypeCode = GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "ТипыНомеров", vRow.ТипНомера);
		EndIf;
		// Get prices
		vAccommodationTypePrices.Clear();
		If ЗначениеЗаполнено(vRoomRate) Тогда
			vRow.Single = vSingle;
			vRow.Double = vDouble;
			vRow.Triple = vTriple;
			vRow.AddBed = vAddBed;
			GetDayPrices(vRow.Period, vPrices, vPriceTags, vRoomRate, vRow.ТипНомера, 
			             vRow.Single, vRow.Double, vRow.Triple, vRow.AddBed, 
			             vRow.SinglePrice, vRow.SinglePriceCurrency, 
			             vRow.DoublePrice, vRow.DoublePriceCurrency, 
			             vRow.TriplePrice, vRow.TriplePriceCurrency, 
			             vRow.AddBedPrice, vRow.AddBedPriceCurrency, 
						 vAccTypes, vAccommodationTypePrices);
			vRow.AccommodationTypePrices = vAccommodationTypePrices.Copy(); 
		EndIf;
		// Build return string
		vRetStr = vRetStr + """" + vRow.ExtHotelCode + """" + "," + """" + TrimR(vRow.Гостиница.Code) + """" + "," + """" + vRow.ExtRoomTypeCode + """" + "," + """" + TrimR(vRow.ТипНомера.Code) + """" + "," + 
		          """" + Format(vRow.Period, "DF=yyyy-MM-dd") + """" + "," + 
		          ?(pOutputRoomsVacant, Format(vRow.RoomsVacant, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
		          ?(pOutputBedsVacant, Format(vRow.BedsVacant, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
		          ?(pOutputRoomsInQuota, Format(vRow.НомеровКвота, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(pOutputBedsInQuota, Format(vRow.МестКвота, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(pOutputRoomsChargedInQuota, Format(vRow.RoomsChargedInQuota, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(pOutputBedsChargedInQuota, Format(vRow.BedsChargedInQuota, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
		          ?(pOutputRoomsReserved, Format(vRow.ЗабронНомеров, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(pOutputBedsReserved, Format(vRow.ЗабронированоМест, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(pOutputInHouseRooms, Format(vRow.ИспользованоНомеров, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(pOutputInHouseBeds, Format(vRow.ИспользованоМест, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
		          ?(pOutputRoomsRemains, Format(vRow.ОстаетсяНомеров, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(pOutputBedsRemains, Format(vRow.ОстаетсяМест, "ND=10; NFD=0; NZ=; NG=; NN="), "") + "," + 
				  ?(ЗначениеЗаполнено(vRow.Single), Format(vRow.SinglePrice, "ND=17; NFD=2; NDS=.; NG="), "") + "," + 
				  ?(ЗначениеЗаполнено(vRow.Single), """" + GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.SinglePriceCurrency) + """", """" + """") + "," + 
				  ?(ЗначениеЗаполнено(vRow.Double), Format(vRow.DoublePrice, "ND=17; NFD=2; NDS=.; NG="), "") + "," + 
				  ?(ЗначениеЗаполнено(vRow.Double), """" + GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.DoublePriceCurrency) + """", """" + """") + "," + 
				  ?(ЗначениеЗаполнено(vRow.Triple), Format(vRow.TriplePrice, "ND=17; NFD=2; NDS=.; NG="), "") + "," + 
				  ?(ЗначениеЗаполнено(vRow.Triple), """" + GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.TriplePriceCurrency) + """", """" + """") + "," + 
				  ?(ЗначениеЗаполнено(vRow.AddBed), Format(vRow.AddBedPrice, "ND=17; NFD=2; NDS=.; NG="), "") + "," + 
				  ?(ЗначениеЗаполнено(vRow.AddBed), """" + GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.AddBedPriceCurrency) + """", """" + """") + 
				  Chars.LF;
	EndDo;
	WriteLogEvent(NStr("en='Get ГруппаНомеров inventory balance';ru='Получить остатки свободных номеров';de='Restbestände an freien Zimmern erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	// Return based on output type
	If pOutputType = "CSV" Тогда
		Return vRetStr;
	Else
		// Write XML
		If pOutputType = "XML" Тогда
			pXMLWriter.WriteStartElement("RoomInventoryBalance");
		EndIf;
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "RoomInventoryBalance"));
		vRetRowType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "RoomInventoryBalanceRow");
		For Each vRow In vBalances Do
			If vRow.Period = Null Тогда
				Continue;
			EndIf;
			vRetRow = XDTOFactory.Create(vRetRowType);
			vRetRow.Гостиница = vRow.ExtHotelCode;
			vRetRow.HotelCode = TrimR(vRow.Гостиница.Code);
			vRetRow.ТипНомера = vRow.ExtRoomTypeCode;
			vRetRow.RoomTypeCode = TrimR(vRow.ТипНомера.Code);
			vRetRow.Period = vRow.Period;
			If pOutputRoomsVacant Тогда
				vRetRow.RoomsVacant = vRow.RoomsVacant;
			EndIf;
			If pOutputBedsVacant Тогда
				vRetRow.BedsVacant = vRow.BedsVacant;
			EndIf;
			If pOutputRoomsInQuota Тогда
				vRetRow.НомеровКвота = vRow.НомеровКвота;
			EndIf;
			If pOutputBedsInQuota Тогда
				vRetRow.МестКвота = vRow.МестКвота;
			EndIf;
			If pOutputRoomsChargedInQuota Тогда
				vRetRow.RoomsChargedInQuota = vRow.RoomsChargedInQuota;
			EndIf;
			If pOutputBedsChargedInQuota Тогда
				vRetRow.BedsChargedInQuota = vRow.BedsChargedInQuota;
			EndIf;
			If pOutputRoomsReserved Тогда
				vRetRow.ЗабронНомеров = vRow.ЗабронНомеров;
			EndIf;
			If pOutputBedsReserved Тогда
				vRetRow.ЗабронированоМест = vRow.ЗабронированоМест;
			EndIf;
			If pOutputInHouseRooms Тогда
				vRetRow.ИспользованоНомеров = vRow.ИспользованоНомеров;
			EndIf;
			If pOutputInHouseBeds Тогда
				vRetRow.ИспользованоМест = vRow.ИспользованоМест;
			EndIf;
			If pOutputRoomsRemains Тогда
				vRetRow.ОстаетсяНомеров = vRow.ОстаетсяНомеров;
			EndIf;
			If pOutputBedsRemains Тогда
				vRetRow.ОстаетсяМест = vRow.ОстаетсяМест;
			EndIf;
			If ValueisFilled(vRow.Single) Тогда
				vRetRow.SinglePriceCurrency = GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.SinglePriceCurrency); 
				vRetRow.SinglePriceCurrencyCode = Format(vRow.SinglePriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG="); 
				vRetRow.SinglePrice = vRow.SinglePrice;
			Else
				vRetRow.SinglePriceCurrency = ""; 
				vRetRow.SinglePriceCurrencyCode = ""; 
				vRetRow.SinglePrice = 0;
			EndIf;
			If ValueisFilled(vRow.Double) Тогда
				vRetRow.DoublePriceCurrency = GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.DoublePriceCurrency); 
				vRetRow.DoublePriceCurrencyCode = Format(vRow.DoublePriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG="); 
				vRetRow.DoublePrice = vRow.DoublePrice;
			Else
				vRetRow.DoublePriceCurrency = ""; 
				vRetRow.DoublePriceCurrencyCode = ""; 
				vRetRow.DoublePrice = 0;
			EndIf;
			If ValueisFilled(vRow.Triple) Тогда
				vRetRow.TriplePriceCurrency = GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.TriplePriceCurrency);
				vRetRow.TriplePriceCurrencyCode = Format(vRow.TriplePriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG="); 
				vRetRow.TriplePrice = vRow.TriplePrice;
			Else
				vRetRow.TriplePriceCurrency = ""; 
				vRetRow.TriplePriceCurrencyCode = ""; 
				vRetRow.TriplePrice = 0;
			EndIf;
			If ValueisFilled(vRow.AddBed) Тогда
				vRetRow.AdditionalBedPriceCurrency = GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.AddBedPriceCurrency); 
				vRetRow.AdditionalBedPriceCurrencyCode = Format(vRow.AddBedPriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG="); 
				vRetRow.AdditionalBedPrice = vRow.AddBedPrice;
			Else
				vRetRow.AdditionalBedPriceCurrency = ""; 
				vRetRow.AdditionalBedPriceCurrencyCode = ""; 
				vRetRow.AdditionalBedPrice = 0;
			EndIf;
			vAccommodationTypePricesType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypePrices");
			vAccommodationTypePrices = XDTOFactory.Create(vAccommodationTypePricesType);
			vAccommodationTypePriceRowType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypePriceRow");
			If ЗначениеЗаполнено(vRoomRate) Тогда
				For Each vAccTypePricesRow In vRow.AccommodationTypePrices Do
					vAccommodationTypePriceRow = XDTOFactory.Create(vAccommodationTypePriceRowType);
					vAccommodationTypePriceRow.ВидРазмещения = GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "ВидыРазмещения", vAccTypePricesRow.ВидРазмещения); 
					vAccommodationTypePriceRow.AccommodationTypeCode = TrimR(vAccTypePricesRow.ВидРазмещения.Code); 
					vAccommodationTypePriceRow.Цена = vAccTypePricesRow.Цена;
					vAccommodationTypePriceRow.PriceCurrency = GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vAccTypePricesRow.PriceCurrency);
					vAccommodationTypePriceRow.PriceCurrencyCode = Format(vAccTypePricesRow.PriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG="); 
					vAccommodationTypePrices.AccommodationTypePriceRow.Add(vAccommodationTypePriceRow);
				EndDo;
			EndIf;
			vRetRow.AccommodationTypePrices = vAccommodationTypePrices;
			vRetXDTO.RoomInventoryBalanceRow.Add(vRetRow);
			// Write XML
			If pOutputType = "XML" Тогда
				pXMLWriter.WriteStartElement("RoomInventoryBalanceRow");
				
				pXMLWriter.WriteStartElement("Гостиница");
				pXMLWriter.WriteText(vRow.ExtHotelCode);
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("HotelCode");
				pXMLWriter.WriteText(TrimR(vRow.Гостиница.Code));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("ТипНомера");
				pXMLWriter.WriteText(vRow.ExtRoomTypeCode);
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("RoomTypeCode");
				pXMLWriter.WriteText(TrimR(vRow.ТипНомера.Code));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("Period");
				pXMLWriter.WriteText(Format(vRow.Period, "DF='yyyy-MM-dd HH:mm:ss'"));
				pXMLWriter.WriteEndElement();
				
				If pOutputRoomsVacant Тогда
					pXMLWriter.WriteStartElement("RoomsVacant");
					pXMLWriter.WriteText(Format(vRow.RoomsVacant, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputBedsVacant Тогда
					pXMLWriter.WriteStartElement("BedsVacant");
					pXMLWriter.WriteText(Format(vRow.BedsVacant, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputRoomsInQuota Тогда
					pXMLWriter.WriteStartElement("НомеровКвота");
					pXMLWriter.WriteText(Format(vRow.НомеровКвота, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputBedsInQuota Тогда
					pXMLWriter.WriteStartElement("МестКвота");
					pXMLWriter.WriteText(Format(vRow.МестКвота, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputRoomsChargedInQuota Тогда
					pXMLWriter.WriteStartElement("RoomsChargedInQuota");
					pXMLWriter.WriteText(Format(vRow.RoomsChargedInQuota, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputBedsChargedInQuota Тогда
					pXMLWriter.WriteStartElement("BedsChargedInQuota");
					pXMLWriter.WriteText(Format(vRow.BedsChargedInQuota, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputRoomsReserved Тогда
					pXMLWriter.WriteStartElement("ЗабронНомеров");
					pXMLWriter.WriteText(Format(vRow.ЗабронНомеров, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputBedsReserved Тогда
					pXMLWriter.WriteStartElement("ЗабронированоМест");
					pXMLWriter.WriteText(Format(vRow.ЗабронированоМест, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputInHouseRooms Тогда
					pXMLWriter.WriteStartElement("ИспользованоНомеров");
					pXMLWriter.WriteText(Format(vRow.ИспользованоНомеров, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputInHouseBeds Тогда
					pXMLWriter.WriteStartElement("ИспользованоМест");
					pXMLWriter.WriteText(Format(vRow.ИспользованоМест, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputRoomsRemains Тогда
					pXMLWriter.WriteStartElement("ОстаетсяНомеров");
					pXMLWriter.WriteText(Format(vRow.ОстаетсяНомеров, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If pOutputBedsRemains Тогда
					pXMLWriter.WriteStartElement("ОстаетсяМест");
					pXMLWriter.WriteText(Format(vRow.ОстаетсяМест, "ND=10; NFD=0; NZ=; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If ValueisFilled(vRow.Single) Тогда
					pXMLWriter.WriteStartElement("SingleRoomPrice");
					pXMLWriter.WriteAttribute("Валюта", GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.SinglePriceCurrency)); 
					pXMLWriter.WriteAttribute("CurrencyCode", Format(vRow.SinglePriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG=")); 
					pXMLWriter.WriteText(Format(vRow.SinglePrice, "ND=17; NFD=2; NDS=.; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If ValueisFilled(vRow.Double) Тогда
					pXMLWriter.WriteStartElement("DoubleRoomPrice");
					pXMLWriter.WriteAttribute("Валюта", GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.DoublePriceCurrency)); 
					pXMLWriter.WriteAttribute("CurrencyCode", Format(vRow.DoublePriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG=")); 
					pXMLWriter.WriteText(Format(vRow.DoublePrice, "ND=17; NFD=2; NDS=.; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If ValueisFilled(vRow.Triple) Тогда
					pXMLWriter.WriteStartElement("TripleRoomPrice");
					pXMLWriter.WriteAttribute("Валюта", GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.TriplePriceCurrency)); 
					pXMLWriter.WriteAttribute("CurrencyCode", Format(vRow.TriplePriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG=")); 
					pXMLWriter.WriteText(Format(vRow.TriplePrice, "ND=17; NFD=2; NDS=.; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If ValueisFilled(vRow.AddBed) Тогда
					pXMLWriter.WriteStartElement("AdditionalBedPrice");
					pXMLWriter.WriteAttribute("Валюта", GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.AddBedPriceCurrency)); 
					pXMLWriter.WriteAttribute("CurrencyCode", Format(vRow.AddBedPriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG=")); 
					pXMLWriter.WriteText(Format(vRow.AddBedPrice, "ND=17; NFD=2; NDS=.; NG="));
					pXMLWriter.WriteEndElement();
				EndIf;
				If ЗначениеЗаполнено(vRoomRate) Тогда
					pXMLWriter.WriteStartElement("AccommodationTypePrices");
					For Each vAccTypePricesRow In vRow.AccommodationTypePrices Do
						pXMLWriter.WriteStartElement("ВидРазмещения");
						pXMLWriter.WriteAttribute("Code", TrimR(vAccTypePricesRow.ВидРазмещения.Code));
						pXMLWriter.WriteAttribute("Description", GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "ВидыРазмещения", vAccTypePricesRow.ВидРазмещения));
						pXMLWriter.WriteAttribute("Валюта", GetObjectExternalSystemCodeByRef(vCodesCash, vRow.Гостиница, pExternalSystemCode, "Валюты", vAccTypePricesRow.PriceCurrency)); 
						pXMLWriter.WriteAttribute("CurrencyCode", Format(vAccTypePricesRow.PriceCurrency.Code, "ND=3; NFD=0; NZ=; NLZ=; NG=")); 
						pXMLWriter.WriteText(Format(vAccTypePricesRow.Цена, "ND=17; NFD=2; NDS=.; NG="));
						pXMLWriter.WriteEndElement();
					EndDo;
					pXMLWriter.WriteEndElement();
				EndIf;
				pXMLWriter.WriteEndElement();
			EndIf;
		EndDo;
		// Write XML
		If pOutputType = "XML" Тогда
			pXMLWriter.WriteEndElement();
		EndIf;
		Return vRetXDTO;
	EndIf;
EndFunction //cmGetRoomInventoryBalance

//-----------------------------------------------------------------------------
// Description: Calculates and returns duration for giving check-in and check-out dates
// Parameters: ГруппаНомеров rate, Check-in date & time, Check-out date & time
// Return value: Number, duration in days or hours
//-----------------------------------------------------------------------------
Function cmCalculateDuration(pRoomRate = Неопределено, pCheckInDate, pCheckOutDate) Экспорт
	vDuration = 0;
	If ЗначениеЗаполнено(pRoomRate) And
	   ЗначениеЗаполнено(pCheckInDate) And
	   ЗначениеЗаполнено(pCheckOutDate) Тогда
		vRRPer = ?(pRoomRate.PeriodInHours = 0, 24, pRoomRate.PeriodInHours);
		If pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour And 
		   pRoomRate.ReferenceHour = '00010101' Тогда
			vPerInSec = EndOfDay(pCheckOutDate) - BegOfDay(pCheckInDate);
			vDuration = Round(vPerInSec/vRRPer/3600, 0);
		ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
			vReferenceHour = pRoomRate.ReferenceHour - BegOfDay(pRoomRate.ReferenceHour);
			vPerInSec = (BegOfDay(pCheckOutDate) + vReferenceHour) - (BegOfDay(pCheckInDate) + vReferenceHour);
			vDuration = Round(vPerInSec/vRRPer/3600, 0);
		ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
			vPerInSec = EndOfDay(pCheckOutDate) - BegOfDay(pCheckInDate);
			vDuration = Round(vPerInSec/vRRPer/3600, 0);
		ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
			vPerInSec = pCheckOutDate - pCheckInDate;
			vDuration = Round(vPerInSec/vRRPer/3600, 0);
		Else
			vPerInSec = pCheckOutDate - pCheckInDate;
			vDuration = Round(vPerInSec/vRRPer/3600, 0);
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(pRoomRate) And
	   ЗначениеЗаполнено(pCheckInDate) And
	   ЗначениеЗаполнено(pCheckOutDate) Тогда
		vRRPer = 24;
		vPerInSec = pCheckOutDate - pCheckInDate;
		vDuration = Round(vPerInSec/vRRPer/3600, 0);
	EndIf;
	Return vDuration;
EndFunction //cmCalculateDuration

//-----------------------------------------------------------------------------
// Description: Calculates and returns check-out date & time for the given check-in
//              date and duration
// Parameters: ГруппаНомеров rate, Check-in date & time, Duration in days or hours
// Return value: Date, check-out date & time
//-----------------------------------------------------------------------------
Function cmCalculateCheckOutDate(pRoomRate = Неопределено, pCheckInDate, pDuration) Экспорт
	vCheckInDate = cm0SecondShift(pCheckInDate);
	vCheckOutDate = Неопределено;
	vPeriodInHours = 24;
	If ЗначениеЗаполнено(pRoomRate) Тогда
		vPeriodInHours = ?(pRoomRate.PeriodInHours = 0, vPeriodInHours, pRoomRate.PeriodInHours);
		vReferenceHour = pRoomRate.ReferenceHour - BegOfDay(pRoomRate.ReferenceHour);
		If pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
			If vReferenceHour = 0 Тогда
				vCheckOutDate = BegOfDay(vCheckInDate) + vReferenceHour + pDuration * vPeriodInHours * 3600 - 1;
			Else
				vCheckOutDate = BegOfDay(vCheckInDate) + vReferenceHour + pDuration * vPeriodInHours * 3600;
			EndIf;
		ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
			vCheckOutDate = BegOfDay(vCheckInDate) + pDuration * vPeriodInHours * 3600 - 3 * 3600;
		ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
			vCheckInTime = vCheckInDate - BegOfDay(vCheckInDate);
			If vCheckInTime <= 9*3600 Тогда // Breakfast check-in
				vCheckOutDate = BegOfDay(vCheckInDate) + pDuration * vPeriodInHours * 3600 + 7 * 3600;
			ElsIf vCheckInTime <= 14*3600 Тогда // Lunch check-in
				vCheckOutDate = BegOfDay(vCheckInDate) + pDuration * vPeriodInHours * 3600 + 12 * 3600;
			ElsIf vCheckInTime <= 20*3600 Тогда // Supper check-in
				vCheckOutDate = BegOfDay(vCheckInDate) + pDuration * vPeriodInHours * 3600 + 18 * 3600;
			Else  // Late check-in
				vCheckOutDate = BegOfDay(vCheckInDate) + pDuration * vPeriodInHours * 3600 + 21 * 3600;
			EndIf;
		Else
			vCheckOutDate = vCheckInDate + pDuration * vPeriodInHours * 3600;
		EndIf;
	Else
		если   pDuration = 0 тогда
			pDuration =1;
			КонецЕсли;
		vCheckOutDate = vCheckInDate + pDuration * vPeriodInHours * 3600;
	EndIf;
	Return cm0SecondShift(vCheckOutDate); 
EndFunction //cmCalculateCheckOutDate

//-----------------------------------------------------------------------------
// Description: Calculates and returns check-in date & time for the given check-out
//              date and duration
// Parameters: ГруппаНомеров rate, Check-out date & time, Duration in days or hours
// Return value: Date, check-in date & time
//-----------------------------------------------------------------------------
Function cmCalculateCheckInDate(pRoomRate = Неопределено, pCheckOutDate, pDuration) Экспорт
	vCheckInDate = Неопределено;
	vPeriodInHours = 24;
	If ЗначениеЗаполнено(pRoomRate) Тогда
		vPeriodInHours = ?(pRoomRate.PeriodInHours = 0, vPeriodInHours, pRoomRate.PeriodInHours);
		vReferenceHour = pRoomRate.ReferenceHour - BegOfDay(pRoomRate.ReferenceHour);
		If pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
			vCheckInDate = BegOfDay(pCheckOutDate) + vReferenceHour - pDuration * vPeriodInHours * 3600;
		ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
			vCheckInDate = BegOfDay(pCheckOutDate) - (pDuration - 1) * vPeriodInHours * 3600 + 8 * 3600;
		ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
			vCheckOutTime = pCheckOutDate - BegOfDay(pCheckOutDate);
			If vCheckOutTime <= 8*3600 Тогда // Before breakfast check-out
				vCheckInDate = BegOfDay(pCheckOutDate) - pDuration * vPeriodInHours * 3600 + 8 * 3600;
			ElsIf vCheckOutTime <= 13*3600 Тогда // Before lunch check-out
				vCheckInDate = BegOfDay(pCheckOutDate) - pDuration * vPeriodInHours * 3600 + 12 * 3600;
			ElsIf vCheckOutTime <= 19*3600 Тогда // Before supper check-out
				vCheckInDate = BegOfDay(pCheckOutDate) - pDuration * vPeriodInHours * 3600 + 18 * 3600;
			Else // Late check-out
				vCheckInDate = BegOfDay(pCheckOutDate) - pDuration * vPeriodInHours * 3600 + 21 * 3600;
			EndIf;
		Else
			vCheckInDate = pCheckOutDate - pDuration * vPeriodInHours * 3600;
		EndIf;
	Else
		vCheckInDate = pCheckOutDate - pDuration * vPeriodInHours * 3600;
	EndIf;
	Return cm1SecondShift(vCheckInDate);
EndFunction //cmCalculateCheckInDate

//-----------------------------------------------------------------------------
// Description: Initializes date & time based on giving ГруппаНомеров rate
// Parameters: Date to be initialized, ГруппаНомеров rate
// Return value: Date
//-----------------------------------------------------------------------------
Function cmInitializeDateTime(pDateTime, pRoomRate) Экспорт
	vDateTime = pDateTime;
	If ЗначениеЗаполнено(vDateTime) Тогда
		If ЗначениеЗаполнено(pRoomRate) Тогда
			vRRRH = pRoomRate.ReferenceHour;
			If pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
				vDateTime = Date(Year(vDateTime), Month(vDateTime), Day(vDateTime), 
				                 Hour(vRRRH), Minute(vRRRH), 0);
			ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
				vDateTime = Date(Year(vDateTime), Month(vDateTime), Day(vDateTime), 
				                 8, 0, 0);
			ElsIf pRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
				vDateTime = Date(Year(vDateTime), Month(vDateTime), Day(vDateTime), 
				                 8, 0, 0);
			EndIf;
		EndIf;
	EndIf;
	Return cm0SecondShift(vDateTime);
EndFunction //cmInitializeDateTime

//-----------------------------------------------------------------------------
// Description: This function checks any ГруппаНомеров services and phone calls that could be charged
//              before guest was really registered in program. Program checks period from the 
//              guest check-in time to the current time. Nothing is done if current user do not
//              have permissions to change guest check-in time 
// Parameters: Accommodation document reference
// Return value: None
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Returnes value table with ГруппаНомеров type/accommodation type pairs
//              defined (valid) for the given ГруппаНомеров rate and client type. It also
//              returns number of vacant rooms and total number of rooms for the 
//              ГруппаНомеров types
// Parameters: Гостиница, ГруппаНомеров rate, Client type, ГруппаНомеров type (as filter), ГруппаНомеров quota 
//             (to calculate vacant rooms in quota), period from date, period to date
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetRoomTypesWithBalancesAndPrices(pHotel, pRoomRate, pClientType, pRoomType, pRoomQuota, pCheckInDate, pCheckOutDate) Экспорт
	// First get active for check in date set ГруппаНомеров rate prices documents
	vOrders = cmGetActiveSetRoomRatePrices(pRoomRate, pCheckInDate);
	vSetRoomRatePrices = New СписокЗначений();
	vSetRoomRatePrices.LoadValues(vOrders.UnloadColumn("ПриказТариф"));
	
	// Retrieve set ГруппаНомеров rate prices documents rows
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomRatePrices.Гостиница AS Гостиница,
	|	RoomRatePrices.Гостиница.ПорядокСортировки AS HotelSortCode,
	|	RoomRatePrices.ТипНомера AS ТипНомера,
	|	RoomRatePrices.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	RoomRatePrices.ВидРазмещения,
	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки AS AccommodationTypeSortCode,
	|	RoomRatePrices.ТипДеньКалендарь AS ТипДеньКалендарь,
	|	RoomRatePrices.ПризнакЦены AS ПризнакЦены,
	|	RoomRatePrices.Валюта AS Валюта,
	|	SUM(CASE
	|			WHEN RoomRatePrices.IsPricePerPerson
	|					AND RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation > 1
	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation
	|			WHEN RoomRatePrices.IsPricePerPerson
	|					AND RoomRatePrices.ВидРазмещения.КоличествоЧеловек > 1
	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.КоличествоЧеловек
	|			ELSE RoomRatePrices.Цена
	|		END) AS Цена,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.ВсегоНомеров, 0)
	|			ELSE ISNULL(КвотаНомеров.НомеровКвота, 0)
	|		END) AS ВсегоНомеров,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.ВсегоМест, 0)
	|			ELSE ISNULL(КвотаНомеров.МестКвота, 0)
	|		END) AS ВсегоМест,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.RoomsAvailable, 0)
	|			WHEN &qRoomQuotaDoNotWriteOff
	|					AND ISNULL(ЗагрузкаНомеров.RoomsAvailable, 0) < ISNULL(КвотаНомеров.ОстаетсяНомеров, 0)
	|				THEN ISNULL(ЗагрузкаНомеров.RoomsAvailable, 0)
	|			ELSE ISNULL(КвотаНомеров.ОстаетсяНомеров, 0)
	|		END) AS RoomsAvailable,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.BedsAvailable, 0)
	|			WHEN &qRoomQuotaDoNotWriteOff
	|					AND ISNULL(ЗагрузкаНомеров.BedsAvailable, 0) < ISNULL(КвотаНомеров.ОстаетсяМест, 0)
	|				THEN ISNULL(ЗагрузкаНомеров.BedsAvailable, 0)
	|			ELSE ISNULL(КвотаНомеров.ОстаетсяМест, 0)
	|		END) AS BedsAvailable,
	|	0 AS Количество,
	|	MAX(RoomRatePrices.ТипНомера.КоличествоГостейНомер) AS КоличествоГостейНомер
	|FROM
	|	InformationRegister.RoomRatePrices AS RoomRatePrices
	|		LEFT JOIN (SELECT
	|			RoomInventoryBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.CounterClosingBalance, 0)) AS CounterClosingBalance,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance, 0)) AS ВсегоНомеров,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance, 0)) AS ВсегоМест,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance, 0)) AS RoomsAvailable,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance, 0)) AS BedsAvailable
	|		FROM
	|			AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|					&qCheckInDate,
	|					&qCheckOutDate,
	|					Second,
	|					RegisterRecordsAndPeriodBoundaries,
	|					Гостиница = &qHotel
	|						AND ТипНомера IN HIERARCHY (&qRoomType)) AS RoomInventoryBalanceAndTurnovers
	|		
	|		GROUP BY
	|			RoomInventoryBalanceAndTurnovers.ТипНомера) AS ЗагрузкаНомеров
	|		ON RoomRatePrices.ТипНомера = ЗагрузкаНомеров.ТипНомера
	|		LEFT JOIN (SELECT
	|			RoomQuotaSalesBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance, 0)) AS CounterClosingBalance,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance, 0)) AS НомеровКвота,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance, 0)) AS МестКвота,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance, 0)) AS ОстаетсяНомеров,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance, 0)) AS ОстаетсяМест
	|		FROM
	|			AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|					&qCheckInDate,
	|					&qCheckOutDate,
	|					Second,
	|					RegisterRecordsAndPeriodBoundaries,
	|					Гостиница = &qHotel
	|						AND ТипНомера IN HIERARCHY (&qRoomType)
	|						AND КвотаНомеров IN HIERARCHY (&qRoomQuota)) AS RoomQuotaSalesBalanceAndTurnovers
	|		
	|		GROUP BY
	|			RoomQuotaSalesBalanceAndTurnovers.ТипНомера) AS КвотаНомеров
	|		ON RoomRatePrices.ТипНомера = КвотаНомеров.ТипНомера
	|WHERE
	|	RoomRatePrices.Гостиница = &qHotel
	|	AND RoomRatePrices.Тариф = &qRoomRate
	|	AND RoomRatePrices.ТипКлиента = &qClientType
	|	AND RoomRatePrices.ТипНомера IN HIERARCHY(&qRoomType)
	|	AND RoomRatePrices.ПриказТариф IN(&qSetRoomRatePrices)
	|	AND RoomRatePrices.IsInPrice = TRUE
	|
	|GROUP BY
	|	RoomRatePrices.Гостиница,
	|	RoomRatePrices.ТипНомера,
	|	RoomRatePrices.ВидРазмещения,
	|	RoomRatePrices.ТипДеньКалендарь,
	|	RoomRatePrices.ПризнакЦены,
	|	RoomRatePrices.Валюта,
	|	RoomRatePrices.ТипНомера.ПорядокСортировки,
	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки,
	|	RoomRatePrices.Гостиница.ПорядокСортировки
	|
	|ORDER BY
	|	HotelSortCode,
	|	RoomTypeSortCode,
	|	AccommodationTypeSortCode,
	|	ТипДеньКалендарь,
	|	Валюта";
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", New Boundary(pCheckOutDate, BoundaryType.Excluding));
	vQry.SetParameter("qClientType", pClientType);
	vQry.SetParameter("qRoomRate", pRoomRate);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(pRoomQuota));
	vQry.SetParameter("qRoomQuotaDoNotWriteOff", ?(ЗначениеЗаполнено(pRoomQuota), НЕ pRoomQuota.DoWriteOff, False));
	vQry.SetParameter("qSetRoomRatePrices", vSetRoomRatePrices);
	vList = vQry.Execute().Unload();
	
	// Process ГруппаНомеров rate service packages
	If ЗначениеЗаполнено(pRoomRate) Тогда
		vPackagesList = pRoomRate.GetObject().pmGetRoomRateServicePackagesList();
		For Each vPackagesListItem In vPackagesList Do
			vServicePackage = vPackagesListItem.Value;
			If ЗначениеЗаполнено(vServicePackage) Тогда
				If vServicePackage.DateValidFrom <= BegOfDay(pCheckInDate) And 
				   (vServicePackage.DateValidTo >= BegOfDay(pCheckInDate) Or НЕ ЗначениеЗаполнено(vServicePackage.DateValidTo)) Тогда
					vServices = vServicePackage.GetObject().pmGetServices(pCheckInDate);
					For Each vServicePackageRow In vServices Do
						If vServicePackageRow.IsInPrice Тогда
							For Each vListRow In vList Do
								If vListRow.Currency = vServicePackageRow.Валюта And 
								   (pClientType = vServicePackageRow.ТипКлиента Or ЗначениеЗаполнено(pClientType) And НЕ ЗначениеЗаполнено(vServicePackageRow.ТипКлиента)) And
								   (vListRow.AccommodationType = vServicePackageRow.ВидРазмещения Or НЕ ЗначениеЗаполнено(vServicePackageRow.ВидРазмещения)) Тогда
									vListRow.Price = vListRow.Price + vServicePackageRow.Количество * vServicePackageRow.Цена;
								EndIf;
							EndDo;
						EndIf;
					EndDo;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	
	// Add discounts from ГруппаНомеров rate discount type
	If ЗначениеЗаполнено(pRoomRate) And ЗначениеЗаполнено(pRoomRate.ТипСкидки) Тогда
		vDiscountTypeObj = pRoomRate.ТипСкидки.GetObject();
		vDiscount = vDiscountTypeObj.pmGetDiscount(cm1SecondShift(pCheckInDate), , pHotel);
		For Each vListRow In vList Do
			vListRow.Price = vListRow.Price - Round(vListRow.Price*vDiscount/100, 2);
		EndDo;
	EndIf;
	
	// Return value table with ГруппаНомеров types and prices
	Return vList;
EndFunction //cmGetRoomTypesWithBalancesAndPrices

//-----------------------------------------------------------------------------
// Description: Returnes value table with ГруппаНомеров types and with number of vacant rooms 
//              and total number of rooms for each ГруппаНомеров type
// Parameters: Гостиница, ГруппаНомеров type (as filter), ГруппаНомеров quota 
//             (to calculate vacant rooms in quota), period from date, period to date
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetRoomTypesWithBalances(pHotel, pRoomType, pRoomQuota, pCheckInDate, pCheckOutDate) Экспорт
	// Log function call
	WriteLogEvent(NStr("en='Get ГруппаНомеров types with balances';ru='Получить остатки свободных номеров по категориям';de='Restbestände an freien Zimmern nach Kategorien erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotel + Chars.LF + 
	              NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + pRoomType + Chars.LF + 
	              NStr("en='Allotment code: ';ru='Код квоты: ';de='Quotencode: '") + pRoomQuota + Chars.LF + 
	              NStr("en='Period from: ';ru='Начало периода: ';de='Zeitraumbeginn: '") + pCheckInDate + Chars.LF + 
	              NStr("en='Period to: ';ru='Конец периода: ';de='Zeitraumende: '") + pCheckOutDate);
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomTypeBalances.Гостиница AS Гостиница,
	|	RoomTypeBalances.Гостиница.ПорядокСортировки AS HotelSortCode,
	|	RoomTypeBalances.ТипНомера AS ТипНомера,
	|	RoomTypeBalances.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(RoomTypeBalances.ВсегоНомеров, 0)
	|			ELSE ISNULL(RoomTypeBalances.НомеровКвота, 0)
	|		END) AS ВсегоНомеров,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(RoomTypeBalances.ВсегоМест, 0)
	|			ELSE ISNULL(RoomTypeBalances.МестКвота, 0)
	|		END) AS ВсегоМест,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(RoomTypeBalances.RoomsAvailable, 0)
	|			WHEN &qRoomQuotaDoNotWriteOff
	|					AND ISNULL(RoomTypeBalances.RoomsAvailable, 0) < ISNULL(RoomTypeBalances.ОстаетсяНомеров, 0)
	|				THEN ISNULL(RoomTypeBalances.RoomsAvailable, 0)
	|			ELSE ISNULL(RoomTypeBalances.ОстаетсяНомеров, 0)
	|		END) AS RoomsAvailable,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(RoomTypeBalances.BedsAvailable, 0)
	|			WHEN &qRoomQuotaDoNotWriteOff
	|					AND ISNULL(RoomTypeBalances.BedsAvailable, 0) < ISNULL(RoomTypeBalances.ОстаетсяМест, 0)
	|				THEN ISNULL(RoomTypeBalances.BedsAvailable, 0)
	|			ELSE ISNULL(RoomTypeBalances.ОстаетсяМест, 0)
	|		END) AS BedsAvailable,
	|	MAX(RoomTypeBalances.ТипНомера.КоличествоГостейНомер) AS КоличествоГостейНомер
	|FROM
	|	(SELECT
	|		RoomInventoryBalanceAndTurnovers.Гостиница AS Гостиница,
	|		RoomInventoryBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|		MIN(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|		MIN(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS ВсегоНомеров,
	|		MIN(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS ВсегоМест,
	|		MIN(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance) AS RoomsAvailable,
	|		MIN(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance) AS BedsAvailable,
	|		MIN(ISNULL(КвотаНомеров.НомеровКвота, 0)) AS НомеровКвота,
	|		MIN(ISNULL(КвотаНомеров.МестКвота, 0)) AS МестКвота,
	|		MIN(ISNULL(КвотаНомеров.ОстаетсяНомеров, 0)) AS ОстаетсяНомеров,
	|		MIN(ISNULL(КвотаНомеров.ОстаетсяМест, 0)) AS ОстаетсяМест
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|				&qCheckInDate,
	|				&qCheckOutDate,
	|				Second,
	|				RegisterRecordsAndPeriodBoundaries,
	|				Гостиница = &qHotel
	|					AND ТипНомера IN HIERARCHY (&qRoomType)) AS RoomInventoryBalanceAndTurnovers
	|			LEFT JOIN (SELECT
	|				RoomQuotaSalesBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|				MIN(RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|				MIN(RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance) AS НомеровКвота,
	|				MIN(RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance) AS МестКвота,
	|				MIN(RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance) AS ОстаетсяНомеров,
	|				MIN(RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance) AS ОстаетсяМест
	|			FROM
	|				AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|						&qCheckInDate,
	|						&qCheckOutDate,
	|						Second,
	|						RegisterRecordsAndPeriodBoundaries,
	|						Гостиница = &qHotel
	|							AND ТипНомера IN HIERARCHY (&qRoomType)
	|							AND КвотаНомеров IN HIERARCHY (&qRoomQuota)) AS RoomQuotaSalesBalanceAndTurnovers
	|			
	|			GROUP BY
	|				RoomQuotaSalesBalanceAndTurnovers.ТипНомера) AS КвотаНомеров
	|			ON RoomInventoryBalanceAndTurnovers.ТипНомера = КвотаНомеров.ТипНомера
	|	
	|	GROUP BY
	|		RoomInventoryBalanceAndTurnovers.Гостиница,
	|		RoomInventoryBalanceAndTurnovers.ТипНомера) AS RoomTypeBalances
	|
	|GROUP BY
	|	RoomTypeBalances.Гостиница,
	|	RoomTypeBalances.Гостиница.ПорядокСортировки,
	|	RoomTypeBalances.ТипНомера,
	|	RoomTypeBalances.ТипНомера.ПорядокСортировки
	|
	|HAVING
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(RoomTypeBalances.RoomsAvailable, 0)
	|			WHEN &qRoomQuotaDoNotWriteOff
	|					AND ISNULL(RoomTypeBalances.RoomsAvailable, 0) < ISNULL(RoomTypeBalances.ОстаетсяНомеров, 0)
	|				THEN ISNULL(RoomTypeBalances.RoomsAvailable, 0)
	|			ELSE ISNULL(RoomTypeBalances.ОстаетсяНомеров, 0)
	|		END) > 0
	|
	|ORDER BY
	|	HotelSortCode,
	|	RoomTypeSortCode";
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", New Boundary(pCheckOutDate, BoundaryType.Excluding));
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(pRoomQuota));
	vQry.SetParameter("qRoomQuotaDoNotWriteOff", ?(ЗначениеЗаполнено(pRoomQuota), НЕ pRoomQuota.DoWriteOff, False));
	vList = vQry.Execute().Unload();
	// Return value table with ГруппаНомеров types and prices
	Return vList;
EndFunction //cmGetRoomTypesWithBalances

//-----------------------------------------------------------------------------
// Description: Returnes value table with ГруппаНомеров type/accommodation type pairs
//              defined (valid) for the given ГруппаНомеров rate and client type. 
// Parameters: Гостиница, ГруппаНомеров rate, Client type, ГруппаНомеров type (as filter), ГруппаНомеров quota 
//             (to calculate vacant rooms in quota), period from date, period to date
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetRoomTypesWithPricesByRoom(pHotel, pRoomRate, pClientType, pRoomType, pCheckInDate, pCheckOutDate, pAccommodationType = Неопределено) Экспорт
	// First get active for check in date set ГруппаНомеров rate prices documents
	vOrders = cmGetActiveSetRoomRatePrices(pRoomRate, pCheckInDate);
	vSetRoomRatePrices = New СписокЗначений();
	vSetRoomRatePrices.LoadValues(vOrders.UnloadColumn("ПриказТариф"));
	
	If pAccommodationType = Неопределено Or НЕ ЗначениеЗаполнено(pAccommodationType) Тогда
		vAccommodationType = cmGetAccommodationTypeRoom(pHotel);
	Else
		vAccommodationType = pAccommodationType;
	EndIf;
	
	// Retrieve set ГруппаНомеров rate prices documents rows
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomRatePrices.Гостиница AS Гостиница,
	|	RoomRatePrices.Гостиница.ПорядокСортировки AS HotelSortCode,
	|	RoomRatePrices.ТипНомера AS ТипНомера,
	|	RoomRatePrices.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	RoomRatePrices.ВидРазмещения AS ВидРазмещения,
	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки AS AccommodationTypeSortCode,
	|	RoomRatePrices.ТипДеньКалендарь AS ТипДеньКалендарь,
	|	RoomRatePrices.ПризнакЦены AS ПризнакЦены,
	|	RoomRatePrices.Валюта AS Валюта,
	|	SUM(CASE
	|			WHEN RoomRatePrices.IsPricePerPerson
	|					AND RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation > 1
	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation
	|			WHEN RoomRatePrices.IsPricePerPerson
	|					AND RoomRatePrices.ВидРазмещения.КоличествоЧеловек > 1
	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.КоличествоЧеловек
	|			ELSE RoomRatePrices.Цена
	|		END) AS Цена
	|FROM
	|	InformationRegister.RoomRatePrices AS RoomRatePrices
	|WHERE
	|	RoomRatePrices.Гостиница = &qHotel
	|	AND RoomRatePrices.Тариф = &qRoomRate
	|	AND RoomRatePrices.ТипКлиента = &qClientType
	|	AND RoomRatePrices.ТипНомера IN HIERARCHY(&qRoomType)
	|	AND RoomRatePrices.ПриказТариф IN(&qSetRoomRatePrices)
	|	AND RoomRatePrices.IsInPrice = TRUE
	|	AND RoomRatePrices.ВидРазмещения IN HIERARCHY(&qAccType)
	|
	|GROUP BY
	|	RoomRatePrices.Гостиница,
	|	RoomRatePrices.ТипНомера,
	|	RoomRatePrices.ВидРазмещения,
	|	RoomRatePrices.ТипДеньКалендарь,
	|	RoomRatePrices.ПризнакЦены,
	|	RoomRatePrices.Валюта,
	|	RoomRatePrices.ТипНомера.ПорядокСортировки,
	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки,
	|	RoomRatePrices.Гостиница.ПорядокСортировки
	|
	|ORDER BY
	|	HotelSortCode,
	|	RoomTypeSortCode,
	|	AccommodationTypeSortCode,
	|	ТипДеньКалендарь,
	|	Валюта";
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", New Boundary(pCheckOutDate, BoundaryType.Excluding));
	vQry.SetParameter("qClientType", pClientType);
	vQry.SetParameter("qRoomRate", pRoomRate);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qAccType", vAccommodationType);
	vQry.SetParameter("qSetRoomRatePrices", vSetRoomRatePrices);
	vList = vQry.Execute().Unload();
	
	// Process ГруппаНомеров rate service packages
	If ЗначениеЗаполнено(pRoomRate) Тогда
		vPackagesList = pRoomRate.GetObject().pmGetRoomRateServicePackagesList();
		For Each vPackagesListItem In vPackagesList Do
			vServicePackage = vPackagesListItem.Value;
			If ЗначениеЗаполнено(vServicePackage) Тогда
				If vServicePackage.DateValidFrom <= BegOfDay(pCheckInDate) And 
				   (vServicePackage.DateValidTo >= BegOfDay(pCheckInDate) Or НЕ ЗначениеЗаполнено(vServicePackage.DateValidTo)) Тогда
					vServices = vServicePackage.GetObject().pmGetServices(pCheckInDate);
					For Each vServicePackageRow In vServices Do
						If vServicePackageRow.IsInPrice Тогда
							For Each vListRow In vList Do
								If vListRow.Currency = vServicePackageRow.Валюта And 
								   (pClientType = vServicePackageRow.ТипКлиента Or ЗначениеЗаполнено(pClientType) And НЕ ЗначениеЗаполнено(vServicePackageRow.ТипКлиента)) And
								   (vListRow.AccommodationType = vServicePackageRow.ВидРазмещения Or НЕ ЗначениеЗаполнено(vServicePackageRow.ВидРазмещения)) Тогда
									vListRow.Price = vListRow.Price + vServicePackageRow.Количество * vServicePackageRow.Цена;
								EndIf;
							EndDo;
						EndIf;
					EndDo;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	
	// Add discounts from ГруппаНомеров rate discount type
	If ЗначениеЗаполнено(pRoomRate) And ЗначениеЗаполнено(pRoomRate.ТипСкидки) Тогда
		vDiscountTypeObj = pRoomRate.ТипСкидки.GetObject();
		vDiscount = vDiscountTypeObj.pmGetDiscount(cm1SecondShift(pCheckInDate), , pHotel);
		For Each vListRow In vList Do
			vListRow.Price = vListRow.Price - Round(vListRow.Price*vDiscount/100, 2);
		EndDo;
	EndIf;
	
	// Return value table with ГруппаНомеров types and prices
	Return vList;
EndFunction //cmGetRoomTypesWithPricesByRoom

//-----------------------------------------------------------------------------
// Description: Returnes value table with calendar day types found for the given
//              ГруппаНомеров rate and period
// Parameters: ГруппаНомеров rate, period from date, period to date
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetEffectiveCalendarDayTypes(pRoomRate, pCheckInDate, pCheckOutDate) Экспорт
	If ЗначениеЗаполнено(pRoomRate) And ЗначениеЗаполнено(pRoomRate.Calendar) Тогда
		vList = pRoomRate.Calendar.GetObject().pmGetDays(pCheckInDate, pCheckOutDate, pCheckInDate, pCheckOutDate);
		vList.Sort("CalendarDayTypeSortCode");
		vList.GroupBy("ТипДеньКалендарь", );
	Else
		vList = New ValueTable();
		vList.Columns.Add("ТипДеньКалендарь", cmGetCatalogTypeDescription("ТипДневногоКалендаря"));
	EndIf;
	Return vList;
EndFunction //cmGetEffectiveCalendarDayTypes

//-----------------------------------------------------------------------------
// Description: This function searches calendar day types of the second value 
//              table in the rows of the first value table. If equal rows are found
//              they are deleted from the first value table
// Parameters: First value table with calendar day types where to search and where to delete,
//             Second value table with source rows to be searched
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmRemoveCalendarDayTypes(pRoomTypes, pCalendarDayTypes) Экспорт
	i = 0;
	While i < pRoomTypes.Count() Do
		vRow = pRoomTypes.Get(i);
		If ЗначениеЗаполнено(vRow.ТипДняКалендаря) Тогда
			If pCalendarDayTypes.Find(vRow.ТипДняКалендаря, "ТипДеньКалендарь") = Неопределено Тогда
				pRoomTypes.Delete(vRow);
				Continue;
			EndIf;
		EndIf;
		i = i + 1;
	EndDo;
КонецПроцедуры //cmRemoveCalendarDayTypes

//-----------------------------------------------------------------------------
// Description: This function searches input value table and checks each ГруппаНомеров type 
//              whether it is stop saled for the given period or not. If yes then 
//              this ГруппаНомеров type is deleted from the value table
// Parameters: Value table with ГруппаНомеров types, Period from date, Period to date
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmRemoveStopSalePeriods(pRoomTypes, pPeriodFrom, pPeriodTo) Экспорт
	i = 0;
	While i < pRoomTypes.Count() Do
		vRow = pRoomTypes.Get(i);
		If vRow.ТипНомера.СнятСПродажи Тогда
			vRemarks = "";
			If cmIsStopInternetSalePeriod(vRow.ТипНомера, pPeriodFrom, pPeriodTo, vRemarks) Тогда
				pRoomTypes.Delete(vRow);
				Continue;
			EndIf;
		EndIf;
		i = i + 1;
	EndDo;
КонецПроцедуры //cmRemoveStopSalePeriods

//-----------------------------------------------------------------------------
// Description: This API is used to return value table of ГруппаНомеров types vacant for the 
//              given period. For each ГруппаНомеров type this function returns prices for
//              all accommodation types defined
// Parameters: Гостиница code, ГруппаНомеров rate code, Client type code, ГруппаНомеров type code, ГруппаНомеров 
///            quota (allotment) code, Period from date, Period to date, External 
//             system code, Language code, Output type: XDTO object or strings in 
//             CSV format
// Return value: XDTO AvailableRoomTypesWithPrices object or CSV strings
//-----------------------------------------------------------------------------
Function cmGetAvailableRoomTypesWithPrices(pHotelCode, pRoomRateCode, pClientTypeCode, pRoomTypeCode, pRoomQuotaCode, pPeriodFrom, pPeriodTo, pExternalSystemCode, pLanguageCode = "RU", pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Get available ГруппаНомеров types with prices';ru='Получить остатки свободных номеров с ценами';de='Restbestände an freien Zimmern mit Preisen erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='ГруппаНомеров rate code: ';ru='Код тарифа: ';de='Tarifcode: '") + pRoomRateCode + Chars.LF + 
	              NStr("en='Client type code: ';ru='Код типа клиента: ';de='Kundentypcode: '") + pClientTypeCode + Chars.LF + 
	              NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + pRoomTypeCode + Chars.LF + 
	              NStr("en='Allotment code: ';ru='Код квоты: ';de='Quotencode: '") + pRoomQuotaCode + Chars.LF + 
	              NStr("en='Period from: ';ru='Начало периода: ';de='Zeitraumbeginn: '") + pPeriodFrom + Chars.LF + 
	              NStr("en='Period to: ';ru='Конец периода: ';de='Zeitraumende: '") + pPeriodTo);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Retrieve parameter references based on codes
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	vRoomRate = Справочники.Тарифы.EmptyRef();
	If IsBlankString(pRoomRateCode) Тогда
		If ЗначениеЗаполнено(vHotel) Тогда
			vRoomRate = vHotel.Тариф;
		EndIf;
	Else
		vRoomRate = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Тарифы", pRoomRateCode);
	EndIf;
	If НЕ ЗначениеЗаполнено(vRoomRate) Тогда
		If ЗначениеЗаполнено(vHotel) Тогда
			vRoomRate = vHotel.Тариф;
		EndIf;
	EndIf;
	vClientType = Справочники.ТипыКлиентов.EmptyRef();
	If НЕ IsBlankString(pClientTypeCode) Тогда
		vClientType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыКлиентов", pClientTypeCode);
	EndIf;
	vRoomType = Справочники.ТипыНомеров.EmptyRef();
	If НЕ IsBlankString(pRoomTypeCode) Тогда
		vRoomType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыНомеров", pRoomTypeCode);
	EndIf;
	vRoomQuota = Справочники.КвотаНомеров.EmptyRef();
	If НЕ IsBlankString(pRoomQuotaCode) Тогда
		vRoomQuota = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "КвотаНомеров", pRoomQuotaCode);
	EndIf;
	
	// 1. Run query to retrieve prices and available rooms/beds 
	vRoomTypes = cmGetRoomTypesWithBalancesAndPrices(vHotel, vRoomRate, vClientType, vRoomType, vRoomQuota, pPeriodFrom, pPeriodTo);
	
	// 2. Run query to retrieve list of day types that are into the search period
	vCalendarDayTypes = cmGetEffectiveCalendarDayTypes(vRoomRate, pPeriodFrom, pPeriodTo);
	
	// 3. Remove calendar day types not into the search period from the list of prices
	cmRemoveCalendarDayTypes(vRoomTypes, vCalendarDayTypes);
	
	// 4. Remove price tags not into the search period from the list of prices
	vPriceTagsList = New СписокЗначений();
	vPriceTags = cmGetEffectivePriceTags(vHotel, vRoomRate, vRoomType, pPeriodFrom, pPeriodTo, vPriceTagsList);
	cmRemovePriceTags(vRoomTypes, vPriceTagsList, vPriceTags);
	
	// 4. Remove stop sale periods from the list of prices
	cmRemoveStopSalePeriods(vRoomTypes, pPeriodFrom, pPeriodTo);
	
	// 5. Sort ГруппаНомеров types list
	vRoomTypes.Sort("HotelSortCode, RoomTypeSortCode, AccommodationTypeSortCode, ТипДеньКалендарь, Валюта");
	
	// Add columns with hotel, ГруппаНомеров type, accommodation type and calendar day type external codes
	vRoomTypes.Columns.Add("ExtHotelCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("ExtRoomTypeCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("RoomTypeCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("RoomTypeDescription", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("ExtAccommodationTypeCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("AccommodationTypeCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("AccommodationTypeDescription", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("ExtCalendarDayTypeCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("CalendarDayTypeCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("CalendarDayTypeDescription", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("ExtCurrencyCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("CurrencyCode", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("CurrencyDescription", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("PricePresentation", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("RoomTypePictureLink", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("RoomTypeInfoLink", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("AccommodationTypePictureLink", cmGetStringTypeDescription());
	vRoomTypes.Columns.Add("AccommodationTypeInfoLink", cmGetStringTypeDescription());
	
	// Variable with reservation conditions
	vPaymentMethodCodesAllowedOnline = "";
	vReservationConditionsShort = "";
	vReservationConditionsOnline = "";
	vReservationConditions = "* Для аннулирования брони известите отдел бронирования до 18:00 дня предшествующего дате заезда
		|* Возможность поселения ранее указанного времени должна быть согласована с отделом бронирования";
	If ЗначениеЗаполнено(vHotel) And НЕ IsBlankString(vHotel.ReservationConditions) Тогда
		vReservationConditions = vHotel.ReservationConditions;
	EndIf;
	If ЗначениеЗаполнено(vRoomRate) And НЕ IsBlankString(vRoomRate.ReservationConditions) Тогда
		vReservationConditions = vRoomRate.ReservationConditions;
		vReservationConditionsShort =vRoomRate.ReservationConditionsShort;
		vReservationConditionsOnline = vRoomRate.ReservationConditionsOnline;
		vPaymentMethodCodesAllowedOnline = СокрЛП(vRoomRate.PaymentMethodCodesAllowedOnline);
	EndIf;
	vReservationConditions = Left(vReservationConditions, 2048);
	vReservationConditionsShort = Left(vReservationConditionsShort, 2048);
	vReservationConditionsOnline = Left(vReservationConditionsOnline, 2048);
	vPaymentMethodCodesAllowedOnline = Left(vPaymentMethodCodesAllowedOnline, 2048);
	
	// 6. Build return string
	vRetStr = "";
	For Each vRow In vRoomTypes Do
		vRow.ExtHotelCode = "";
		If ЗначениеЗаполнено(vRow.Гостиница) Тогда
			vRow.ExtHotelCode = cmGetObjectExternalSystemCodeByRef(Справочники.Гостиницы.EmptyRef(), pExternalSystemCode, "Hotels", vRow.Гостиница);
			If IsBlankString(vRow.ExtHotelCode) Тогда
				vRow.ExtHotelCode = СокрЛП(vRow.Гостиница.Description);
			EndIf;
		EndIf;
		vRow.ExtRoomTypeCode = "";
		vRow.RoomTypeCode = "";
		vRow.RoomTypeDescription = "";
		If ЗначениеЗаполнено(vRow.ТипНомера) Тогда
			vRoomTypeObj = vRow.ТипНомера.GetObject();
			vRow.RoomTypeCode = СокрЛП(vRow.ТипНомера.Code);
			vRow.RoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
			vRow.ExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vRow.Гостиница, pExternalSystemCode, "ТипыНомеров", vRow.ТипНомера);
			If IsBlankString(vRow.ExtRoomTypeCode) Тогда
				vRow.ExtRoomTypeCode = СокрЛП(vRow.ТипНомера.Description);
			EndIf;
			vRow.ExtRoomTypeCode = Left(vRow.ExtRoomTypeCode, 36);
			vRow.RoomTypePictureLink = СокрЛП(vRow.ТипНомера.RoomTypePictureLink);
			If НЕ IsBlankString(vRow.ТипНомера.RoomTypeInfoLink) Тогда
				vRow.RoomTypeInfoLink = vRow.ТипНомера.RoomTypeInfoLink;
			Else
				vRow.RoomTypeInfoLink = СокрЛП(vRow.RoomTypeDescription);
			EndIf;
		EndIf;
		vRow.ExtAccommodationTypeCode = "";
		vRow.AccommodationTypeCode = "";
		vRow.AccommodationTypeDescription = "";
		If ЗначениеЗаполнено(vRow.ВидРазмещения) Тогда
			vAccommodationTypeObj = vRow.ВидРазмещения.GetObject();
			vRow.AccommodationTypeCode = СокрЛП(vRow.ВидРазмещения.Code);
			vRow.AccommodationTypeDescription = vAccommodationTypeObj.pmGetAccommodationTypeDescription(vLanguage);
			vRow.ExtAccommodationTypeCode = cmGetObjectExternalSystemCodeByRef(vRow.Гостиница, pExternalSystemCode, "ВидыРазмещения", vRow.ВидРазмещения);
			If IsBlankString(vRow.ExtAccommodationTypeCode) Тогда
				vRow.ExtAccommodationTypeCode = СокрЛП(vRow.ВидРазмещения.Description);
			EndIf;
			vRow.ExtAccommodationTypeCode = Left(vRow.ExtAccommodationTypeCode, 36);
			vRow.AccommodationTypePictureLink = СокрЛП(vRow.ВидРазмещения.WebSitePictureLink);
			If НЕ IsBlankString(vRow.ВидРазмещения.WebSiteInfoLink) Тогда
				vRow.AccommodationTypeInfoLink = vRow.ВидРазмещения.WebSiteInfoLink;
			Else
				vRow.AccommodationTypeInfoLink = СокрЛП(vRow.AccommodationTypeDescription);
			EndIf;
		EndIf;
		vRow.ExtCalendarDayTypeCode = "";
		vRow.CalendarDayTypeCode = "";
		vRow.CalendarDayTypeDescription = "";
		If ЗначениеЗаполнено(vRow.ТипДняКалендаря) Тогда
			vCalendarDayTypeObj = vRow.ТипДняКалендаря.GetObject();
			vRow.CalendarDayTypeCode = СокрЛП(vRow.ТипДняКалендаря.Code);
			vRow.CalendarDayTypeDescription = vCalendarDayTypeObj.pmGetDayTypeDescription(vLanguage);
			vRow.ExtCalendarDayTypeCode = cmGetObjectExternalSystemCodeByRef(vRow.Гостиница, pExternalSystemCode, "ТипДневногоКалендаря", vRow.ТипДняКалендаря);
			If IsBlankString(vRow.ExtCalendarDayTypeCode) Тогда
				vRow.ExtCalendarDayTypeCode = СокрЛП(vRow.ТипДняКалендаря.Description);
			EndIf;
			vRow.ExtCalendarDayTypeCode = Left(vRow.ExtCalendarDayTypeCode, 36);
		EndIf;
		vRow.ExtCurrencyCode = "";
		vRow.CurrencyCode = "";
		vRow.CurrencyDescription = "";
		If ЗначениеЗаполнено(vRow.Валюта) Тогда
			vCurrencyObj = vRow.Валюта.GetObject();
			vRow.CurrencyCode = СокрЛП(vRow.Валюта.Code);
			vRow.CurrencyDescription = vCurrencyObj.pmGetCurrencyDescription(vLanguage);
			vRow.ExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vRow.Гостиница, pExternalSystemCode, "Валюты", vRow.Валюта);
			If IsBlankString(vRow.ExtCurrencyCode) Тогда
				vRow.ExtCurrencyCode = СокрЛП(vRow.Валюта.Description);
			EndIf;
		EndIf;
		vRow.PricePresentation = cmFormatSum(vRow.Цена, vRow.Валюта, "NZ=");
		vRetStr = vRetStr + """" + vRow.ExtHotelCode + """" + "," + """" + vRow.ExtRoomTypeCode + """" + "," + 
		          """" + vRow.ExtAccommodationTypeCode + """" + "," + """" + vRow.ExtCalendarDayTypeCode + """" + "," + 
		          Format(vRow.ВсегоНомеров, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + Format(vRow.ВсегоМест, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
		          Format(vRow.RoomsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + Format(vRow.BedsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
		          """" + vRow.ExtCurrencyCode + """" + "," + Format(vRow.Цена, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
				  """" + vRow.RoomTypeCode + """" + "," + """" + cmRemoveComma(vRow.RoomTypeDescription) + """" + "," + 
				  """" + vRow.AccommodationTypeCode + """" + "," + """" + cmRemoveComma(vRow.AccommodationTypeDescription) + """" + "," + 
				  """" + vRow.CalendarDayTypeCode + """" + "," + """" + cmRemoveComma(vRow.CalendarDayTypeDescription) + """" + "," + 
				  """" + vRow.CurrencyCode + """" + "," + """" + cmRemoveComma(vRow.CurrencyDescription) + """" + "," + 
				  """" + cmRemoveComma(vRow.PricePresentation) + """" + "," + 
				  """" + cmRemoveComma(vRow.RoomTypePictureLink) + """" + "," + """" + cmRemoveComma(vRow.RoomTypeInfoLink) + """" + "," + 
				  """" + cmRemoveComma(vRow.AccommodationTypePictureLink) + """" + "," + """" + cmRemoveComma(vRow.AccommodationTypeInfoLink) + """" + "," + 
		          Format(vRow.КоличествоГостейНомер, "ND=10; NFD=0; NZ=; NG=; NN=") + Chars.LF;
	EndDo;
	WriteLogEvent("Получить остатки свободных номеров с ценами", EventLogLevel.Information, , ,"Строка возврата: " + vRetStr);
	// Return based on output type
	If pOutputType = "CSV" Тогда
		Return vRetStr;
	Else
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chote7l.ru/interfaces/reservation/", "AvailableRoomTypesWithPrices"));
		vRetXDTO.ReservationConditions = vReservationConditions;
		vRetXDTO.ReservationConditionsShort = vReservationConditionsShort;
		vRetXDTO.ReservationConditionsOnline = vReservationConditionsOnline;
		vRetXDTO.PaymentMethodCodesAllowedOnline = vPaymentMethodCodesAllowedOnline;
		vRetRows = XDTOFactory.Create(XDTOFactory.Type("http://www.1chot7el.ru/interfaces/reservation/", "AvailableRoomTypesWithPricesRows"));
		For Each vRow In vRoomTypes Do
			vRetRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1cho7tel.ru/interfaces/reservation/", "AvailableRoomTypesWithPricesRow"));
			vRetRow.Гостиница = vRow.ExtHotelCode;
			vRetRow.ТипНомера = vRow.ExtRoomTypeCode;
			vRetRow.ВидРазмещения = vRow.ExtAccommodationTypeCode;
			vRetRow.ТипДняКалендаря = vRow.ExtCalendarDayTypeCode;
			vRetRow.ВсегоНомеров = vRow.ВсегоНомеров;
			vRetRow.ВсегоМест = vRow.ВсегоМест;
			vRetRow.RoomsAvailable = vRow.RoomsAvailable;
			vRetRow.BedsAvailable = vRow.BedsAvailable;
			vRetRow.Валюта = vRow.ExtCurrencyCode;
			vRetRow.Цена = vRow.Цена;
			vRetRow.RoomTypeCode = vRow.RoomTypeCode;
			vRetRow.RoomTypeDescription = vRow.RoomTypeDescription;
			vRetRow.AccommodationTypeCode = vRow.AccommodationTypeCode;
			vRetRow.AccommodationTypeDescription = vRow.AccommodationTypeDescription;
			vRetRow.CalendarDayTypeCode = vRow.CalendarDayTypeCode;
			vRetRow.CalendarDayTypeDescription = vRow.CalendarDayTypeDescription;
			vRetRow.CurrencyCode = vRow.CurrencyCode;
			vRetRow.CurrencyDescription = vRow.CurrencyDescription;
			vRetRow.PricePresentation = vRow.PricePresentation;
			vRetRow.RoomTypePictureLink = vRow.RoomTypePictureLink;
			vRetRow.RoomTypeInfoLink = vRow.RoomTypeInfoLink;
			vRetRow.AccommodationTypePictureLink = vRow.AccommodationTypePictureLink;
			vRetRow.AccommodationTypeInfoLink = vRow.AccommodationTypeInfoLink;
			vRetRow.КоличествоГостейНомер = vRow.КоличествоГостейНомер;
			
			vRetRows.AvailableRoomTypesWithPricesRow.Add(vRetRow);
		EndDo;
		vRetXDTO.AvailableRoomTypesWithPricesRows = vRetRows;
		Return vRetXDTO;
	EndIf;
EndFunction //cmGetAvailableRoomTypesWithPrices

//-----------------------------------------------------------------------------
// Description: This API is used to return value table of ГруппаНомеров types vacant for the 
//              given period. For each ГруппаНомеров type this function returns prices for
//              all accommodation types defined
// Parameters: Гостиница code, External system code, Language code, Output type: XDTO 
//             object or strings in CSV format, ГруппаНомеров rate code
// Return value: XDTO HotelParameters object or CSV string
//-----------------------------------------------------------------------------
Function cmGetHotelParameters(pHotelCode, pExternalSystemCode, pLanguageCode = "RU", pOutputType = "CSV", pRoomRateCode = "") Экспорт
	WriteLogEvent(NStr("en='Get hotel parameters';ru='Получить параметры гостиницы';de='Hotelparameter erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF +
	              NStr("en='ГруппаНомеров rate code: ';ru='Код тарифа: ';de='Tarifcode: '") + pRoomRateCode);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Retrieve parameter references based on codes
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Build return string
	vRetStr = "";
	If ЗначениеЗаполнено(vHotel) Тогда
		// Retrieve ГруппаНомеров rate
		vRoomRate = Справочники.Тарифы.EmptyRef();
		If IsBlankString(pRoomRateCode) Тогда
			vRoomRate = vHotel.Тариф;
		Else
			vRoomRate = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Тарифы", pRoomRateCode);
		EndIf;
		// Fill hotel parameters
		vHotelObj = vHotel.GetObject();
		vHotelPrintName = Left(vHotelObj.pmGetHotelPrintName(vLanguage), 1024);
		vReservationConditions = "";
		vReservationConditionsShort = "";
		vReservationConditionsOnline = "";
		vPaymentMethodCodesAllowedOnline = "";
		If ЗначениеЗаполнено(vRoomRate) And НЕ IsBlankString(vRoomRate.ReservationConditions) Тогда
			vReservationConditions = vRoomRate.ReservationConditions;
			vReservationConditionsShort = vRoomRate.ReservationConditionsShort;
			vReservationConditionsOnline = vRoomRate.ReservationConditionsOnline;
			vPaymentMethodCodesAllowedOnline = СокрЛП(vRoomRate.PaymentMethodCodesAllowedOnline);
		ElsIf НЕ IsBlankString(vHotelObj.ReservationConditions) Тогда
			vReservationConditions = vHotelObj.ReservationConditions;
		Else
			vReservationConditions = "* Для аннулирования брони известите отдел бронирования до 18:00 дня предшествующего дате заезда
				|
				|* Возможность поселения ранее указанного времени должна быть согласована с отделом бронирования";
		EndIf;
		vReservationConditions = Left(vReservationConditions, 2048);
		vReservationConditionsShort = Left(vReservationConditionsShort, 2048);
		vReservationConditionsOnline = Left(vReservationConditionsOnline, 2048);
		vPaymentMethodCodesAllowedOnline = Left(vPaymentMethodCodesAllowedOnline, 2048);
		vHotelPostAddress = Left(vHotelObj.pmGetHotelPostAddressPresentation(vLanguage), 2048);
		vHowToDriveToTheHotel = Left(vHotelObj.pmGetHotelHowToDriveToTheHotelDescription(vLanguage), 2048);
		vReservationDivisionContacts = Left(vHotelObj.pmGetHotelReservationDivisionContacts(vLanguage), 2048);
		vHotelPhones = Left(vHotelObj.Phones, 50);
		vHotelFax = Left(vHotelObj.Fax, 50);
		vHotelEMail = Left(СокрЛП(vHotelObj.EMail), 50);
		vHotelLogoLink = СокрЛП(vHotelObj.HotelLogoLink);
		vServerTimeZone = -(StandardTimeOffset(,) + DaylightTimeOffset(,));
		// Get maximum number of adults and children
		vMaxAdults = 0;
		vMaxKids = 0;
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ISNULL(MAX(НомернойФонд.КоличествоМестНомер), 0) AS MaxNumberOfBedsPerRoom,
		|	ISNULL(MAX(НомернойФонд.КоличествоГостейНомер), 0) AS MaxNumberOfPersonsPerRoom,
		|	ISNULL(MAX(НомернойФонд.КоличествоГостейНомер - НомернойФонд.КоличествоМестНомер), 0) AS MaxNumberOfAdditionalBeds
		|FROM
		|	Catalog.НомернойФонд AS НомернойФонд
		|WHERE
		|	NOT НомернойФонд.DeletionMark
		|	AND NOT НомернойФонд.IsFolder
		|	AND NOT НомернойФонд.ВиртуальныйНомер
		|	AND НомернойФонд.Owner = &qHotel";
		vQry.SetParameter("qHotel", vHotel);
		vPersonsData = vQry.Execute().Unload();
		If vPersonsData.Count() > 0 Тогда
			vPersonsDataRow = vPersonsData.Get(0);
			vMaxAdults = vPersonsDataRow.MaxNumberOfPersonsPerRoom;
			vMaxKids = vPersonsDataRow.MaxNumberOfPersonsPerRoom;
		EndIf;
		// Build return string		
		vRetStr = vRetStr + """" + СокрЛП(vHotel.Code) + """" + "," + """" + vHotelPrintName + """" + "," + """" + vReservationConditions + """" + "," + 
		          """" + vHotelPostAddress + """" + "," + """" + vHowToDriveToTheHotel + """" + "," + 
		          """" + vReservationDivisionContacts + """" + "," + """" + vHotelPhones + """" + "," + 
				  """" + vHotelFax + """" + "," + """" + vHotelEMail + """" + "," + 
				  """" + vHotelLogoLink + """" + "," + Format(vServerTimeZone, "ND=6; NFD=0; NZ=; NG=") + "," + 
				  Format(vMaxAdults, "ND=10; NFD=0; NZ=; NG=") + "," + Format(vMaxKids, "ND=10; NFD=0; NZ=; NG=");
	Else
		ВызватьИсключение NStr("en='Гостиница code was wrong!';ru='Код гостиницы указан не верно!';de='Code des Hotels ist falsch angegeben!'");
	EndIf;
	WriteLogEvent(NStr("en='Get hotel attributes';ru='Получить параметры гостиницы';de='Hotelparameter erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	// Return based on output type
	If pOutputType = "CSV" Тогда
		Return vRetStr;
	Else
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "HotelParameters"));
		vRetXDTO.HotelCode = СокрЛП(vHotel.Code);
		vRetXDTO.HotelPrintName = vHotelPrintName;
		vRetXDTO.ReservationConditions = vReservationConditions;
		vRetXDTO.ReservationConditionsShort = vReservationConditionsShort;
		vRetXDTO.ReservationConditionsOnline = vReservationConditionsOnline;
		vRetXDTO.PaymentMethodCodesAllowedOnline = vPaymentMethodCodesAllowedOnline;
		vRetXDTO.HotelPostAddress = vHotelPostAddress;
		vRetXDTO.HowToDriveToTheHotel = vHowToDriveToTheHotel;
		vRetXDTO.ReservationDivisionContacts = vReservationDivisionContacts;
		vRetXDTO.HotelPhones = vHotelPhones;
		vRetXDTO.HotelFax = vHotelFax;
		vRetXDTO.HotelEMail = vHotelEMail;
		vRetXDTO.HotelLogoLink = vHotelLogoLink;
		vRetXDTO.ServerTimeZone = vServerTimeZone;
		vRetXDTO.MaxAdults = vMaxAdults;
		vRetXDTO.MaxKids = vMaxKids;
		Return vRetXDTO;
	EndIf;
EndFunction //cmGetHotelParameters

//-----------------------------------------------------------------------------
Function GetInvoiceByExternalSystemCode(pInvoiceCode)
	If TypeOf(pInvoiceCode) <> Type("String") Or IsBlankString(pInvoiceCode) Тогда
		Return Documents.СчетНаОплату.EmptyRef();
	EndIf;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СчетНаОплату.Ref
	|FROM
	|	Document.СчетНаОплату AS СчетНаОплату
	|WHERE
	|	NOT СчетНаОплату.DeletionMark
	|	AND СчетНаОплату.ExternalCode = &qExternalCode
	|
	|ORDER BY
	|	СчетНаОплату.ChangeDate DESC,
	|	СчетНаОплату.ДатаДок DESC";
	vQry.SetParameter("qExternalCode", pInvoiceCode);
	vInvoices = vQry.Execute().Unload();
	If vInvoices.Count() > 0 Тогда
		Return vInvoices.Get(0).Ref;
	Else
		Return Documents.СчетНаОплату.EmptyRef();
	EndIf;
EndFunction //GetInvoiceByExternalSystemCode

//-----------------------------------------------------------------------------
// Description: Writes external payment to the external reservation folio 
// Parameters: External reservation code, External guest group code, External client 
//             code, Payer name, Payment method, Payment amount (number), Payment 
//             currency, Payment section,  Гостиница code, External system code, Credit \
//             card processing reference number, Credit card processing authorisation 
//             code, Remarks as string, Output type: XDTO GuestGroupPaymentStatus object 
//             or string in CSV format
// Return value: XDTO GuestGroupPaymentStatus object or CSV string
//-----------------------------------------------------------------------------
Function cmWriteExternalPayment(pExtReservationCode, pExtGroupCode, pExtClientCode, 
                                pExtPayerCode = "", pPayerTIN = "", pPayerKPP = "", pPayerName = "", 
                                pPaymentMethod, pSum, pCurrency, pPaymentSection, pHotelCode, pExternalSystemCode, 
								pReferenceNumber, pAuthorizationCode, pRemarks, pGuaranteedReservationStatus = "", 
								pPaymentDate = Неопределено, pCompanyCode = "", pPaymentExternalCode = "", 
								pOutputType = "CSV", pExternalPaymentData = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Write external payment';ru='Записать внешний платеж';de='eine externe Zahlung einschreiben'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='External reservation code: ';ru='Код брони во внешней системе: ';de='Reservierungscode im externen System: '") + pExtReservationCode + Chars.LF + 
	              NStr("en='External group code: ';ru='Код группы во внешней системе: ';de='Gruppencode im externen System: '") + pExtGroupCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='External client code: ';ru='Код клиента во внешней системы: ';de='Kundecode im externen System: '") + pExtClientCode + Chars.LF + 
	              NStr("en='External payer code: ';ru='Код плательщика во внешней системе: ';de='Zahlercode im externen System: '") + pExtPayerCode + Chars.LF + 
	              NStr("en='Payer name: ';ru='Наименование плательщика: ';de='Bezeichnung des Zahlers: '") + pPayerName + Chars.LF + 
	              NStr("en='Payer ИНН: ';ru='ИНН плательщика: ';de='INN des Zahlers: '") + pPayerTIN + Chars.LF + 
	              NStr("en='Payer KPP: ';ru='КПП плательщика: ';de='Zahler-KPP: '") + pPayerKPP + Chars.LF + 
	              NStr("en='Payment method code: ';ru='Код способа оплаты: ';de='Code der Zahlungsmethode: '") + pPaymentMethod + Chars.LF + 
	              NStr("en='Payment section code: ';ru='Код кассовой секции: ';de='Code der Kassensektion: '") + pPaymentSection + Chars.LF + 
	              NStr("en='Reference number: ';ru='Референс номер: ';de='Referenznummer: '") + pReferenceNumber + Chars.LF + 
	              NStr("en='Authorization code: ';ru='Код авторизации: ';de='Autorisierungscode: '") + pAuthorizationCode + Chars.LF + 
	              NStr("en='Remarks: ';ru='Примечания: ';de='Anmerkungen: '") + pRemarks + Chars.LF + 
	              NStr("en='Guaranteed reservation status: ';ru='Статус оплаченной брони: ';de='Status der bezahlten Reservierung: '") + pGuaranteedReservationStatus + Chars.LF + 
	              NStr("en='Currency code: ';ru='Код валюты: ';de='Währungscode: '") + pCurrency + Chars.LF + 
	              NStr("en='Payment date: ';ru='Дата платежа: ';de='Zahlungsdatum: '") + pPaymentDate + Chars.LF + 
	              NStr("en='Фирма code: ';ru='Код фирмы: ';de='Firmencode: '") + pCompanyCode + Chars.LF + 
	              NStr("en='Payment external code: ';ru='Код платежа во внешней системе: ';de='Zahlungscode im externen System: '") + pPaymentExternalCode + Chars.LF + 
	              NStr("en='Payment sum: ';ru='Сумма платежа: ';de='Summe der Zahlung: '") + Format(pSum, "ND=17; NFD=2; NZ="));
	If pExternalPaymentData <> Неопределено Тогда
		WriteLogEvent(NStr("en='Write external payment';ru='Записать внешний платеж';de='eine externe Zahlung einschreiben'"), EventLogLevel.Information, , , 
		              NStr("en='Card number: ';ru='Номер карты: ';de='Kartenummer: '") + pExternalPaymentData.CardNumber + Chars.LF + 
		              NStr("en='Order number: ';ru='Номер заказа: ';de='Bestellungsnummer: '") + pExternalPaymentData.OrderNumber + Chars.LF + 
		              NStr("en='Card holder: ';ru='Держатель карты: ';de='Kartenhalter: '") + pExternalPaymentData.CardHolder + Chars.LF + 
		              NStr("en='Invoice code: ';ru='Код счета на оплату: ';de='Rechnungscode: '") + pExternalPaymentData.InvoiceCode + Chars.LF + 
					  NStr("en='Payment external code from acc: ';ru='Код платежа в бух системе: ';de='Zahlungscode im externen System: '") + pExternalPaymentData.ExternalPaymentCode + Chars.LF + 
		              NStr("en='Operation date: ';ru='Дата операции: ';de='Betriebsdatum: '") + Format(pExternalPaymentData.ДатаДок, "DF='dd.MM.yyyy HH:mm'"));
	EndIf;
	Try
		// Save current timestamp and start transaction
		vCurrentDate = CurrentDate();
		BeginTransaction(DataLockControlMode.Managed);
		// Initialize error description
		vErrorDescription = "";
		// Try to find hotel by name or code
		vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
		// Try to find existing reservation with given external code
		vDocRef = Documents.Бронирование.EmptyRef();
		If НЕ IsBlankString(pExtReservationCode) Тогда
			vDocRef = cmGetReservationByExternalCode(vHotel, pExtReservationCode);
		EndIf;
		//
		If НЕ ЗначениеЗаполнено(pPaymentExternalCode) And pExternalPaymentData <> Неопределено Тогда
			pPaymentExternalCode = pExternalPaymentData.ExternalPaymentCode; 
		EndIf;	
		// Try to find guest group by code
		vGuestGroup = Справочники.ГруппыГостей.EmptyRef();
		If НЕ IsBlankString(pExtGroupCode) Тогда
			Try
				vGuestGroup = Справочники.ГруппыГостей.FindByCode(Number(pExtGroupCode), False, , vHotel);
			Except
			EndTry;
			If НЕ ЗначениеЗаполнено(vGuestGroup) Тогда
				vGuestGroup = cmGetGuestGroupByExternalCode(vHotel, pExtGroupCode, "", "", False);
			EndIf;
		EndIf;
		// Invoice
		vInvoiceRef = Неопределено;
		If pExternalPaymentData <> Неопределено And ЗначениеЗаполнено(pExternalPaymentData.Get("InvoiceCode")) Тогда
			vInvoiceCode = pExternalPaymentData.Get("InvoiceCode");
			vInvoiceRef = GetInvoiceByExternalSystemCode(vInvoiceCode);
			If ЗначениеЗаполнено(vInvoiceRef) Тогда
				If ЗначениеЗаполнено(vInvoiceRef.ГруппаГостей) And НЕ ЗначениеЗаполнено(vGuestGroup) Тогда
					vGuestGroup = vInvoiceRef.ГруппаГостей;
				EndIf;
			Else
				// Silently return from function because this invoice is not from this database. Simply skip this call
				vRetStr = "";
				If TransactionActive() Тогда
					RollbackTransaction();
				EndIf;
				// Log success		
				WriteLogEvent(NStr("en='Write external payment';ru='Записать внешний платеж';de='Eine externe Zahlung einschreiben'"), EventLogLevel.Information, , , 
							  NStr("en='Invoice code passed is not from hotel database - SKIPPING THIS CALL!';ru='Счет на оплату не найден по переданному коду! Этот счет не из отельной базы - ВЫЗОВ НЕ ОБРАБАТЫВАЕМ';de='Rechnung nicht über den übertragenen Code gefunden! Dieses Proformarechnung ist kein Гостиница - Anruf wird übersprungen.'"));
				// Return based on output type
				If pOutputType = "CSV" Тогда
					Return vRetStr;
				Else
					vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GuestGroupPaymentStatus"));
					vRetXDTO.PaymentNumber = "";
					vRetXDTO.ErrorDescription = "";
					vRetXDTO.TotalSum = 0;
					vRetXDTO.TotalSumPresentation = "";
					vRetXDTO.Balance = 0;
					vRetXDTO.BalancePresentation = "";
					vRetXDTO.UUID = "";
					Return vRetXDTO;
				EndIf;
			EndIf;
		EndIf;
		// Try to find client by code
		vClient = Справочники.Клиенты.EmptyRef();
		If НЕ IsBlankString(pExtClientCode) Тогда
			vClient = cmGetClientByExternalCode(pExtClientCode);
			If НЕ ЗначениеЗаполнено(vClient) Тогда
				vClient = cmGetClientByCode(pExtClientCode);
			EndIf;
		EndIf;
		// Try to find Фирма
		vCompany = Справочники.Фирмы.EmptyRef();
		If НЕ IsBlankString(pCompanyCode) Тогда
			vCompany = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Фирмы", pCompanyCode);
		EndIf;
		// Try to find payment method
		vPaymentMethod = Справочники.СпособОплаты.EmptyRef();
		If НЕ IsBlankString(pPaymentMethod) Тогда
			vPaymentMethod = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СпособОплаты", pPaymentMethod);
		EndIf;
		// Try to find payment section
		vPaymentSection = Справочники.ОтделОплаты.EmptyRef();
		If НЕ IsBlankString(pPaymentSection) Тогда
			vPaymentSection = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ОтделОплаты", pPaymentSection);
			If НЕ ЗначениеЗаполнено(vPaymentSection) And Число(pPaymentSection) And String(pPaymentSection) <> "0" Тогда
				vPaymentSection = Справочники.ОтделОплаты.FindByCode(Number(pPaymentSection));
			EndIf;
		EndIf;
		// Try to find reservation status
		vGuaranteedReservationStatus = Справочники.СтатусБрони.EmptyRef();
		If НЕ IsBlankString(pGuaranteedReservationStatus) Тогда
			vGuaranteedReservationStatus = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СтатусБрони", pGuaranteedReservationStatus);
		Else
			vGuaranteedReservationStatus = vHotel.GuaranteedReservationStatus;
		EndIf;
		// Try to find currency
		vCurrency = Справочники.Валюты.EmptyRef();
		If НЕ IsBlankString(pCurrency) Тогда
			If Число(pCurrency) Тогда
				vCurrency = Справочники.Валюты.FindByCode(Number(pCurrency));
			EndIf;
			If НЕ ЗначениеЗаполнено(vCurrency) Тогда
				vCurrency = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Валюты", pCurrency);
			EndIf;
		EndIf;
		// Try to find payer
		vCustomer = Справочники.Контрагенты.EmptyRef();
		If НЕ IsBlankString(pExtPayerCode) Тогда
			// Try to find Контрагент by external code
			vCustomer = cmGetCustomerByExternalCode(TrimR(pExtPayerCode));
		EndIf;
		If НЕ ЗначениеЗаполнено(vCustomer) And НЕ IsBlankString(pPayerTIN) Тогда
			// Try to find Контрагент by ИНН and KPP
			vCustomer = cmGetCustomerByTIN(TrimR(pPayerTIN), TrimR(pPayerKPP), "", False);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCustomer) And НЕ IsBlankString(pPayerName) Тогда
			// Try to find Контрагент by name
			vCustomer = cmGetCustomerByName(Upper(TrimR(pPayerName)), , False);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCustomer) And НЕ IsBlankString(pExtPayerCode) And НЕ IsBlankString(pPayerTIN) And НЕ IsBlankString(pPayerName) Тогда 
			vCustomerObj = Справочники.Контрагенты.CreateItem();
			vCustomerObj.pmFillAttributesWithDefaultValues();
			vCustomerObj.Description = TrimR(pPayerName);
			vCustomerObj.ЮрИмя = TrimR(vCustomerObj.Description);
			vCustomerObj.ИНН = TrimR(pPayerTIN);
			vCustomerObj.KPP = TrimR(pPayerKPP);
			vCustomerObj.ExternalCode = TrimR(pExtPayerCode);
			vCustomerObj.Write();
			vCustomerObj.pmWriteToCustomerChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			vCustomer = vCustomerObj.Ref;
		EndIf;
		// Check parameters
		If pSum = 0 Тогда
			ВызватьИсключение NStr("en='Payment sum should be filled!';ru='Сумма платежа должна быть указана!';de='Summe der Zahlung muss angegeben werden!'");
		ElsIf НЕ ЗначениеЗаполнено(vHotel) Тогда
			ВызватьИсключение NStr("en='Гостиница should be specified!';ru='Гостиница должна быть указана!';de='Das Гостиница muss angegeben sein!'");
		ElsIf НЕ ЗначениеЗаполнено(vCurrency) Тогда
			ВызватьИсключение NStr("en='Payment curency should be specified!';ru='Валюта платежа должна быть указана!';de='Die Zahlungswährung muss angegeben werden!'");
		ElsIf НЕ ЗначениеЗаполнено(vPaymentMethod) Тогда
			ВызватьИсключение NStr("en='Payment method should be choosen!';ru='Способ оплаты должен быть указан!';de='Zahlungsmethode muss definiert werden!'");
		EndIf;
		// Reset payment object
		vPaymentObj = Неопределено;
		// Try to find payment document by external payment code
		If НЕ IsBlankString(pPaymentExternalCode) Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	Платежи.Ref AS Ref,
			|	Платежи.ДатаДок AS Date
			|FROM
			|	Document.Платеж AS Платежи
			|WHERE
			|	Платежи.ExternalCode = &qExternalCode
			|
			|UNION ALL
			|
			|SELECT
			|	CustomerPayments.Ref,
			|	CustomerPayments.ДатаДок
			|FROM
			|	Document.ПлатежКонтрагента AS CustomerPayments
			|WHERE
			|	CustomerPayments.ExternalCode = &qExternalCode
			|
			|UNION ALL
			|
			|SELECT
			|	Returns.Ref,
			|	Returns.ДатаДок
			|FROM
			|	Document.Возврат AS Returns
			|WHERE
			|	Returns.ExternalCode = &qExternalCode
			|
			|ORDER BY
			|	Date";
			vQry.SetParameter("qExternalCode", TrimR(pPaymentExternalCode));
			vPayments = vQry.Execute().Unload();
			For Each vPaymentsRow In vPayments Do
				vWrkPaymentRef = vPaymentsRow.Ref;
				If vPayments.IndexOf(vPaymentsRow) > 0 Тогда
					If НЕ vWrkPaymentRef.DeletionMark Тогда
						vWrkPaymentObj = vWrkPaymentRef.GetObject();
						vWrkPaymentObj.SetDeletionMark(True);
					EndIf;
				Else
					If НЕ ЗначениеЗаполнено(vGuestGroup) And TypeOf(vWrkPaymentRef) <> Type("DocumentRef.ПлатежКонтрагента") Or 
					   ЗначениеЗаполнено(vGuestGroup) And TypeOf(vWrkPaymentRef) = Type("DocumentRef.ПлатежКонтрагента") Тогда
						If НЕ vWrkPaymentRef.DeletionMark Тогда
							vWrkPaymentObj = vWrkPaymentRef.GetObject();
							vWrkPaymentObj.SetDeletionMark(True);
						EndIf;
					Else
						vPaymentObj = vWrkPaymentRef.GetObject();
						If vPaymentObj.DeletionMark Тогда
							vPaymentObj.SetDeletionMark(False);
						EndIf;
					EndIf;
				EndIf;
			EndDo;
		EndIf;
		// Find guest group folio to write payment to
		If ЗначениеЗаполнено(vGuestGroup) Тогда
			// Fill hotel from guest group
			vHotel = vGuestGroup.Owner;
			// Run query to get folios to charge to
			vFolio = Неопределено;
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				vQry = New Query();
				vQry.Text = 
				"SELECT
				|	СчетПроживания.Ref,
				|	СчетПроживания.ДокОснование
				|FROM
				|	Document.СчетПроживания AS СчетПроживания
				|WHERE
				|	(NOT СчетПроживания.DeletionMark)
				|	AND СчетПроживания.Гостиница = &qHotel
				|	AND (СчетПроживания.ДокОснование = &qParentDoc
				|			OR &qParentDocIsEmpty)
				|	AND СчетПроживания.ГруппаГостей = &qGuestGroup
				|	AND (СчетПроживания.Клиент = &qClient
				|			OR &qClientIsEmpty)
				|	AND (СчетПроживания.Контрагент = &qCustomer
				|			OR &qCustomerIsEmpty)
				|	AND (СчетПроживания.Фирма = &qCompany
				|			OR &qCompanyIsEmpty)
				|ORDER BY
				|	СчетПроживания.PointInTime";
				vQry.SetParameter("qHotel", vHotel);
				vQry.SetParameter("qParentDoc", vDocRef);
				vQry.SetParameter("qParentDocIsEmpty", НЕ ЗначениеЗаполнено(vDocRef));
				vQry.SetParameter("qGuestGroup", vGuestGroup);
				vQry.SetParameter("qClient", vClient);
				vQry.SetParameter("qClientIsEmpty", НЕ ЗначениеЗаполнено(vClient));
				vQry.SetParameter("qCustomer", vCustomer);
				vQry.SetParameter("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(vCustomer));
				vQry.SetParameter("qCompany", vCompany);
				vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(vCompany));
				WriteLogEvent(NStr("en='Write external payment';ru='Записать внешний платеж';de='Eine externe Zahlung einschreiben'"), EventLogLevel.Information, vGuestGroup.Metadata(), vGuestGroup, 
							  NStr("en='Folios search:';ru='Поиск лицевых счетов:';de='Suche nach Personenkonten:'") + Chars.LF + 
							  "qHotel: " + vHotel + Chars.LF +
							  "qGuestGroup: " + vGuestGroup + Chars.LF +
							  "qParentDoc: " + vDocRef + Chars.LF +
							  "qParentDocIsEmpty: " + (НЕ ЗначениеЗаполнено(vDocRef)) + Chars.LF +
							  "qClient: " + vClient + ?(ЗначениеЗаполнено(vClient), " (" + СокрЛП(vClient.Code) + ")", "") + Chars.LF +
							  "qClientIsEmpty: " + (НЕ ЗначениеЗаполнено(vClient)) + Chars.LF +
							  "qCustomer: " + vCustomer + ?(ЗначениеЗаполнено(vCustomer), " (" + СокрЛП(vCustomer.Code) + ")", "") + Chars.LF +
							  "qCustomerIsEmpty: " + (НЕ ЗначениеЗаполнено(vCustomer)) + Chars.LF +
							  "qCompany: " + vCompany + ?(ЗначениеЗаполнено(vCompany), " (" + СокрЛП(vCompany.Code) + ")", "") + Chars.LF +
							  "qCompanyIsEmpty: " + (НЕ ЗначениеЗаполнено(vCompany)));
				vFolios = vQry.Execute().Unload();
				// Find folio with ГруппаНомеров revenue services
				For Each vFoliosRow In vFolios Do
					WriteLogEvent(NStr("en='Write external payment';ru='Записать внешний платеж';de='Eine externe Zahlung einschreiben'"), EventLogLevel.Information, vFoliosRow.Ref.Metadata(), vFoliosRow.Ref, 
								  NStr("en='Checking folio...';ru='Проверяем лицевой счет...';de='Wir überprüfen das Personenkonto...'"));
					If ЗначениеЗаполнено(vFoliosRow.ParentDoc) Тогда
						If TypeOf(vFoliosRow.ParentDoc) = Type("DocumentRef.Размещение") Or
						   TypeOf(vFoliosRow.ParentDoc) = Type("DocumentRef.Бронирование") Тогда
							If vFoliosRow.ParentDoc.Услуги.Count() > 0 Тогда
								vRoomRevenueServices = vFoliosRow.ParentDoc.Услуги.FindRows(New Structure("IsRoomRevenue", True));
								If vRoomRevenueServices.Count() > 0 Тогда
									vFolio = vRoomRevenueServices.Get(0).СчетПроживания;
									Break;
								EndIf;
							EndIf;
						EndIf;
					EndIf;
				EndDo;
			EndIf;
			// Get folio from group charging rules
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				If vGuestGroup.ChargingRules.Count() > 0 Тогда
					vGGCRRow = vGuestGroup.ChargingRules.Get(0);
					If ЗначениеЗаполнено(vGGCRRow.ChargingFolio) Тогда
						vFolio = vGGCRRow.ChargingFolio;
					EndIf;
				EndIf;
			EndIf;
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				ВызватьИсключение NStr("en='Payment folio was not found!';ru='Не найден лицевой счет!';de='Personenkonto nicht gefunden!'");
			EndIf;
			WriteLogEvent(NStr("en='Write external payment';ru='Записать внешний платеж';de='Eine externe Zahlung einschreiben'"), EventLogLevel.Information, vFolio.Metadata(), vFolio, 
						  NStr("en='ЛицевойСчет is choosen...';ru='Назначен лицевой счет...';de='Personenkonto wurde festgelegt…'"));
			// Create payment for the folio being found
			If vPaymentObj = Неопределено Тогда
				vPaymentObj = Documents.Платеж.CreateDocument();
				vPaymentObj.Гостиница = vHotel;
			EndIf;
			vPaymentObj.Fill(vFolio);
			If pPaymentDate <> Неопределено Тогда
				vPaymentObj.ДатаДок = pPaymentDate;
			EndIf;
			If ЗначениеЗаполнено(vCompany) Тогда
				vPaymentObj.Фирма = vCompany;
			EndIf;
			If НЕ IsBlankString(pPayerName) Тогда
				vPaymentObj.Примечания = pPayerName;
			EndIf;
			vPaymentObj.PaymentCurrency = vCurrency;
			vPaymentObj.СпособОплаты = vPaymentMethod;
			// Invoice
			If ЗначениеЗаполнено(vInvoiceRef) Тогда
				vPaymentObj.СчетНаОплату = vInvoiceRef;
			Else
				vInvoices = vFolio.ГруппаГостей.GetObject().pmGetInvoices(vFolio.Контрагент, vFolio.Договор);
				For Each vInvoicesRow In vInvoices Do
					If pSum > 0 And vInvoicesRow.Balance > 0 Тогда
						vPaymentObj.СчетНаОплату = vInvoices.Get(0).СчетНаОплату;
						Break;
					ElsIf pSum < 0 And vInvoicesRow.Balance = 0 Тогда
						vPaymentObj.СчетНаОплату = vInvoices.Get(0).СчетНаОплату;
						Break;
					EndIf;
				EndDo;
			EndIf;
			// Payment sections
			If ЗначениеЗаполнено(vPaymentObj.Гостиница) And vPaymentObj.Гостиница.SplitFolioBalanceByPaymentSections Тогда
				vPaymentObj.ОтделОплаты.Clear();
				vPSRow = vPaymentObj.ОтделОплаты.Add();
				vPSRow.PaymentSection = vPaymentSection;
				vPSRow.Сумма = pSum;
				vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, 
																      vPaymentObj.ВалютаЛицСчета, vPaymentObj.FolioCurrencyExchangeRate, 
																      vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
				If ЗначениеЗаполнено(vPaymentSection) And ЗначениеЗаполнено(vPaymentSection.СтавкаНДС) Тогда
					vPSRow.СтавкаНДС = vPaymentSection.СтавкаНДС;
				Else
					vPSRow.СтавкаНДС = vPaymentObj.СтавкаНДС;
				EndIf;
				vPSRow.СуммаНДС = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.Сумма);
				vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, 
																      vPaymentObj.ВалютаЛицСчета, vPaymentObj.FolioCurrencyExchangeRate, 
																      vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
				vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.SumInFolioCurrency);
				vPaymentObj.pmCalculateTotalsByPaymentSections();
			Else
				vPaymentObj.PaymentSection = vPaymentSection;
				vPaymentObj.Сумма = pSum;
				If TypeOf(vPaymentObj) = Type("DocumentObject.Платеж") Тогда
				//	vPaymentObj.pmRecalculateSums();
				ElsIf TypeOf(vPaymentObj) = Type("DocumentObject.ПлатежКонтрагента") Тогда
					vPaymentObj.SumInAccountingCurrency = Round(cmConvertCurrencies(vPaymentObj.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, vPaymentObj.ВалютаРасчетов, vPaymentObj.AccountingCurrencyExchangeRate, vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
				EndIf;
			EndIf;
			// Reference and authorization codes
			vPaymentObj.ReferenceNumber = СокрЛП(pReferenceNumber);
			vPaymentObj.AuthorizationCode = СокрЛП(pAuthorizationCode);
			// Payment remarks
			vPaymentObj.SlipText = TrimR(pRemarks);
			// External system payment code
			vPaymentObj.ExternalCode = TrimR(pPaymentExternalCode);
			// Set Контрагент as payer
			If ЗначениеЗаполнено(vPaymentObj.Контрагент) And ЗначениеЗаполнено(vPaymentObj.СпособОплаты) And vPaymentObj.СпособОплаты.IsByBankTransfer Тогда
				If ЗначениеЗаполнено(vPaymentObj.Гостиница) And vPaymentObj.Контрагент <> vPaymentObj.Гостиница.IndividualsCustomer Тогда
					vPaymentObj.Payer = vPaymentObj.Контрагент;
				EndIf;
			EndIf;
			// Credit card
			vCreditCard = Справочники.КредитныеКарты.EmptyRef();
			If pExternalPaymentData <> Неопределено Тогда
				If ЗначениеЗаполнено(pExternalPaymentData.CardNumber) Тогда
					// Search cards with given owner and number
					vQry = New Query();
					vQry.Text = 
					"SELECT
					|	КредитныеКарты.Ref AS CreditCard
					|FROM
					|	Catalog.КредитныеКарты AS CreditCards
					|WHERE
					|	КредитныеКарты.CardOwner = &qCardOwner
					|	AND КредитныеКарты.CardNumber = &qCardNumber
					|	AND КредитныеКарты.DeletionMark = FALSE";
					vQry.SetParameter("qCardOwner", vPaymentObj.Payer);
					vQry.SetParameter("qCardNumber", СокрЛП(pExternalPaymentData.CardNumber));
					vCards = vQry.Execute().Unload();
					If vCards.Count() > 0 Тогда
						// Return first found
						vCreditCard = vCards.Get(0).CreditCard;
					Else
						vCreditCardObj = Справочники.КредитныеКарты.CreateItem();
						vCreditCardObj.Description = cmGetCreditCardDescription(pExternalPaymentData.CardNumber);
						vCreditCardObj.pmFillAttributesWithDefaultValues();
						vCreditCardObj.CardOwner = vPaymentObj.Payer;
						vCreditCardObj.CardNumber = pExternalPaymentData.CardNumber;
						vCreditCardObj.CardHolder = pExternalPaymentData.CardHolder;
						vCreditCardObj.Write();
						vCreditCard = vCreditCardObj.Ref;
					EndIf;
				EndIf;
				If ЗначениеЗаполнено(pExternalPaymentData.ДатаДок) Тогда
					vPaymentObj.CardOperationDate = pExternalPaymentData.ДатаДок;
				EndIf;
				If ЗначениеЗаполнено(pExternalPaymentData.OrderNumber) Тогда
					vPaymentObj.OrderNumber = pExternalPaymentData.OrderNumber;
				EndIf;
			EndIf;
			vPaymentObj.CreditCard = vCreditCard;
			// Post payment
			vPaymentObj.Write(DocumentWriteMode.Posting);
			// Update guest group reservation status
			If ЗначениеЗаполнено(vGuaranteedReservationStatus) Тогда 
				vReservations = vGuestGroup.GetObject().pmGetReservations(True, True);
				For Each vReservationsRow In vReservations Do
					If ЗначениеЗаполнено(vReservationsRow.Status) And vReservationsRow.Status.IsActive And vReservationsRow.Status <> vGuaranteedReservationStatus Тогда
						vReservationObj = vReservationsRow.Бронирование.GetObject();
						vReservationObj.ReservationStatus = vGuaranteedReservationStatus;
						vReservationObj.pmSetDoCharging();
						Try
							vReservationObj.Write(DocumentWriteMode.Posting);
							// Write to the document change history
							vReservationObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
						Except
							// Log exception if any
							WriteLogEvent("Записать внешний платеж", EventLogLevel.Warning, vReservationObj.Metadata(), vReservationObj.Ref, 
							              "Ошибка при изменении статуса брони на " + СокрЛП(vGuaranteedReservationStatus) + ":" + Chars.LF + 
							              ErrorDescription());
						EndTry;
					EndIf;
				EndDo;
			EndIf;
			// Write guest group attachment that payment was received
			vLanguage = vHotel.Language;
			If ЗначениеЗаполнено(vPaymentObj.Payer) And ЗначениеЗаполнено(vPaymentObj.Payer.Language) Тогда
				vLanguage = vPaymentObj.Payer.Language;
			EndIf;
			vRemarks = vHotel.GetObject().pmGetHotelPrintName(vLanguage) + 
			           ". Платеж №" + СокрЛП(vPaymentObj.НомерДока) + " от " + Format(vPaymentObj.ДатаДок, "DF=dd.MM.yy") + "'";
			vDocumentText = "Автоматизированная система рассылки уведомлений об изменении статусов брони:" + Chars.LF + Chars.LF +
								   ?(ЗначениеЗаполнено(vGuestGroup) And ЗначениеЗаполнено(vGuestGroup.Клиент), "Клиент: " + СокрЛП(vGuestGroup.Клиент.FullName) + Chars.LF, "") + 
								   ?(ЗначениеЗаполнено(vGuestGroup) And ЗначениеЗаполнено(vGuestGroup.CheckInDate) And ЗначениеЗаполнено(vGuestGroup.ДатаВыезда), "Период проживания: "+ Format(vGuestGroup.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - "  + Format(vGuestGroup.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + Chars.LF, "") + 
								   Chars.LF +"Платеж на сумму " + cmFormatSum(vPaymentObj.Сумма, vPaymentObj.PaymentCurrency, "NZ=") + " по брони НомерРазмещения " + Format(vGuestGroup.Code, "ND=12; NFD=0; NG=") + " был получен и успешно обработан!'" + Chars.LF + 
			                       ?(ЗначениеЗаполнено(vGuaranteedReservationStatus), Chars.LF + "Статус брони был изменен на " + vGuaranteedReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage) + Chars.LF, Chars.LF) + Chars.LF + "Детали платежа " + Chars.LF + 
			                       СокрЛП(vPaymentObj.SlipText) + Chars.LF + Chars.LF + "С уважением,'" + Chars.LF + 
			                       vHotel.GetObject().pmGetHotelPrintName(vLanguage) + Chars.LF + 
					               ПараметрыСеанса.ИмяКонфигурации;
			// Call user exit procedure to give possibility to override message subject ans message text
			vUserExitProc = Справочники.ВнешниеОбработки.WriteGuestGroupPaymentConfirmation;
			If ЗначениеЗаполнено(vUserExitProc) Тогда
				If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
					If НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
						Execute(СокрЛП(vUserExitProc.Algorithm));
					EndIf;
				EndIf;
			EndIf;
			// Write attachment
			cmWriteGuestGroupAttachment(vGuestGroup, Перечисления.AttachmentTypes.EMail, vRemarks, vDocumentText);
		ElsIf ЗначениеЗаполнено(vCustomer) Тогда
			WriteLogEvent("Записать внешний платеж", EventLogLevel.Information, vCustomer.Metadata(), vCustomer, "Контрагент" + СокрЛП(vCustomer));
			// Create payment for the folio being found
			If vPaymentObj = Неопределено Тогда
				vPaymentObj = Documents.ПлатежКонтрагента.CreateDocument();
			EndIf;
			If ЗначениеЗаполнено(vCustomer.Договор) Тогда
				WriteLogEvent("Записать внешний платеж", EventLogLevel.Information, vCustomer.Договор.Metadata(), vCustomer.Договор, 
						      "Заполнить по договору" + СокрЛП(vCustomer.Договор));
				vPaymentObj.Fill(vCustomer.Договор);
				WriteLogEvent("Записать внешний платеж", EventLogLevel.Information, vCustomer.Договор.Metadata(), vCustomer.Договор, 
						      "Договор в платеже установлен на " + СокрЛП(vPaymentObj.Договор));
			Else
				WriteLogEvent("Записать внешний платеж';", EventLogLevel.Information, vCustomer.Договор.Metadata(), vCustomer.Договор, 
						      "Заполнить по контрагенту " + СокрЛП(vCustomer));
				vPaymentObj.Fill(vCustomer);
				WriteLogEvent("Записать внешний платеж", EventLogLevel.Information, vPaymentObj.Договор.Metadata(), vPaymentObj.Договор, 
						      "Договор в платеже установлен на "+ СокрЛП(vPaymentObj.Договор));
			EndIf;
			If pPaymentDate <> Неопределено Тогда
				vPaymentObj.ДатаДок = pPaymentDate;
			EndIf;
			If ЗначениеЗаполнено(vCompany) Тогда
				vPaymentObj.Фирма = vCompany;
			EndIf;
			vPaymentObj.PaymentCurrency = vCurrency;
			vPaymentObj.СпособОплаты = vPaymentMethod;
			vPaymentObj.PaymentSection = vPaymentSection;
			vPaymentObj.Сумма = pSum;
			vPaymentObj.SumInAccountingCurrency = Round(cmConvertCurrencies(vPaymentObj.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, vPaymentObj.ВалютаРасчетов, vPaymentObj.AccountingCurrencyExchangeRate, vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
			vPaymentObj.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
			vPaymentObj.СчетНаОплату = Documents.СчетНаОплату.EmptyRef();
			vPaymentObj.Договора.Clear();
			vPaymentObj.Invoices.Clear();
			vPaymentObj.pmCalculateSums();
			// Reference and authorization codes
			vPaymentObj.ReferenceNumber = СокрЛП(pReferenceNumber);
			vPaymentObj.AuthorizationCode = СокрЛП(pAuthorizationCode);
			// Payment remarks
			vPaymentObj.SlipText = TrimR(pRemarks);
			// External system payment code
			vPaymentObj.ExternalCode = TrimR(pPaymentExternalCode);
			// Post payment
			vPaymentObj.Write(DocumentWriteMode.Posting);
		Else
			ВызватьИсключение NStr("en='Failed to get Контрагент!';ru='Не удалось определить контрагента!';de='Der Partner konnte nicht bestimmt werden!'");
		EndIf;
		vGroupObj = vGuestGroup.GetObject();
		vSalesTotals = vGroupObj.pmGetSalesTotals();
		vPaymentTotals = vGroupObj.pmGetPaymentsTotals();
		// Get total group amount
		vSum = 0;
		vCurrency = vHotel.BaseCurrency;
		vExtCurrencyCode = "";
		vSumPresentation = "";
		If vSalesTotals.Count() > 0 Тогда
			vCurrency = vSalesTotals.Get(0).Валюта;
			For Each vSalesTotalsRow In vSalesTotals Do
				If vSalesTotalsRow.Валюта = vCurrency Тогда
					vSum = vSum + vSalesTotalsRow.Продажи + vSalesTotalsRow.ПрогнозПродаж;
				Else
					vSum = vSum + cmConvertCurrencies(vSalesTotalsRow.Продажи + vSalesTotalsRow.ПрогнозПродаж, vSalesTotalsRow.Валюта, , vCurrency, , CurrentDate(), vHotel);
				EndIf;
			EndDo;
			vSum = Round(vSum, 2);
		EndIf;
		vSumPresentation = cmFormatSum(vSum, vCurrency, "NZ=");
		vExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vGuestGroup.Owner, pExternalSystemCode, "Валюты", vCurrency);
		If IsBlankString(vExtCurrencyCode) Тогда
			vExtCurrencyCode = СокрЛП(vCurrency.Description);
		EndIf;
		// Get base currency code
		vBaseCurrency = vHotel.BaseCurrency;
		vExtBaseCurrencyCode = cmGetObjectExternalSystemCodeByRef(vGuestGroup.Owner, pExternalSystemCode, "Валюты", vBaseCurrency);
		If IsBlankString(vExtBaseCurrencyCode) Тогда
			vExtBaseCurrencyCode = СокрЛП(vBaseCurrency.Description);
		EndIf;
		// Get currency rate
		//vCurrencyRate = cmGetCurrencyExchangeRate(vHotel, vCurrency, CurrentDate());
		// Get group balance
		vPaymentSum = 0;
		For Each vPaymentTotalsRow In vPaymentTotals Do
			If vPaymentTotalsRow.Валюта = vCurrency Тогда
				vPaymentSum = vPaymentSum + vPaymentTotalsRow.Сумма;
			Else
				vPaymentSum = vPaymentSum + cmConvertCurrencies(vPaymentTotalsRow.Сумма, vPaymentTotalsRow.Валюта, , vCurrency, , CurrentDate(), vHotel);
			EndIf;
			vPaymentSum = Round(vPaymentSum, 2);
		EndDo;
		vBalanceAmount = vSum - vPaymentSum;
		vBalanceAmountPresentation = cmFormatSum(vBalanceAmount, vCurrency, "NZ=");
		// Check time period
		If (CurrentDate() - vCurrentDate) > 20 And  vInvoiceRef = Неопределено Тогда
			ВызватьИсключение NStr("Откат транзакции продолжающейся более 20 секунд!");
		EndIf;
		CommitTransaction();
		// Build return string
		vRetStr = """" + СокрЛП(vPaymentObj.НомерДока) + """" + "," + """" + """";
		// Log success		
		WriteLogEvent("Записать внешний платеж", EventLogLevel.Information, vPaymentObj.Metadata(), vPaymentObj.Ref, 
					  "Платеж записан в БД!" + Chars.LF + vRetStr);
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1cho7tel.ru/interfaces/reservation/", "GuestGroupPaymentStatus"));
			vRetXDTO.PaymentNumber = СокрЛП(vPaymentObj.НомерДока);
			vRetXDTO.ErrorDescription = "";
			vRetXDTO.TotalSum = vSum;
			vRetXDTO.TotalSumPresentation = vSumPresentation;
			vRetXDTO.Balance = vBalanceAmount;
			vRetXDTO.BalancePresentation = vBalanceAmountPresentation;
			vRetXDTO.UUID = String(vGuestGroup.UUID());
			Return vRetXDTO;
		EndIf;
	Except
		vErrorDescription = ErrorDescription();
		If TransactionActive() Тогда
			RollbackTransaction();
		EndIf;
		// Write log event
		WriteLogEvent("Записать внешний платеж", EventLogLevel.Error, , , 
		              "Описание ошибки: " + ErrorDescription());
		// Send error notifications
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And not IsBlankString(ПараметрыСеанса.ТекПользователь.BccEMail) Тогда
			WriteLogEvent("Записать внешний платеж", EventLogLevel.Error, , , 
						  "Отправка e-mail уведомления об ошибке:" + "Ошибка при сохранении внешнего платежа!"+ pExtGroupCode + ", " + pExtPayerCode + " = " + pSum + " " + pCurrency + " -> " + СокрЛП(ПараметрыСеанса.ТекПользователь.BccEMail));
			vEMailErrorMessage = "";
			РегламентныеЗадания.cmSendTextByEMail("Ошибка при сохранении внешнего платежа! "+ pExtGroupCode + ", " + pExtPayerCode + " = " + pSum + " " + pCurrency, pExtGroupCode + ", " + pExtPayerCode + " = " + pSum + " " + pCurrency + Chars.LF + Chars.LF + vErrorDescription, ПараметрыСеанса.ТекПользователь.BccEMail, False, vEMailErrorMessage);
			If НЕ IsBlankString(vEMailErrorMessage) Тогда
				WriteLogEvent("Записать внешний платеж", EventLogLevel.Error, , , 
							  "Не удалось отправить e-mail уведомление об ошибке: " + vEMailErrorMessage);
			EndIf;
		EndIf;
		// Build return string
		vRetStr = """" + """" + "," + """" + vErrorDescription + """";
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1cho7tel.ru/interfaces/reservation/", "GuestGroupPaymentStatus"));
			vRetXDTO.PaymentNumber = "";
			vRetXDTO.ErrorDescription = Left(vErrorDescription, 2048);
			vRetXDTO.TotalSum = 0;
			vRetXDTO.TotalSumPresentation = "";
			vRetXDTO.Balance = 0;
			vRetXDTO.BalancePresentation = "";
			vRetXDTO.UUID = "";
			Return vRetXDTO;
		EndIf;
	EndTry;
EndFunction //cmWriteExternalPayment

//-----------------------------------------------------------------------------
// Description: Writes external payment to the external reservation folio 
// Parameters: External reservation code, External guest group code, External client 
//             code, Payer name, Payment method, Payment amount (number), Payment 
//             currency, Payment section,  Гостиница code, External system code, Credit \
//             card processing reference number, Credit card processing authorisation 
//             code, Remarks as string, Output type: XDTO ErrorDescription object 
//             or string in CSV format
// Return value: XDTO ErrorDescription, Type - String or object or CSV string
//-----------------------------------------------------------------------------
Function cmWritePaymentExternalFOSystem(pHotelCode="", pPayerName, pPaymentDate = Неопределено, pExternalSystemCode, 
								pCard, pFolioNumber, pRoom, pPaymentMethod, pCurrencyCode, pSum, pRemarks, 
								pPaymentExternalCode = "",	pOutputType = "CSV", pPaymentSectionCode = "") Экспорт
	WriteLogEvent(NStr("en='Write external payment FO system'; de='Write external payment FO system'; ru='Записать внешний платеж фронт-офисной ситемы'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: '; de='External system code: '; ru='Код внешней системы: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='ЛицевойСчет number: '; de='ЛицевойСчет number: '; ru='Номер фолио: '") + pFolioNumber + Chars.LF +
				  NStr("en='Payer name: '; de='Payer name: '; ru='Плательщик: '") + pPayerName + Chars.LF +
				  NStr("en='ГруппаНомеров number: '; de='ГруппаНомеров number: '; ru='Номер комнаты: '") + pRoom + Chars.LF +
	              NStr("en='Гостиница code: '; de='Гостиница code: '; ru='Код гостиницы: '") + pHotelCode + Chars.LF + 
	              NStr("en='Card client code: '; de='Card client code: '; ru='Код карты клиента: '") + pCard + Chars.LF + 
	              NStr("en='Payment method code: '; de='Payment method code: '; ru='Код способа оплаты: '") + pPaymentMethod + Chars.LF + 
	              NStr("en='Remarks: '; de='Remarks: '; ru='Примечания: '") + pRemarks + Chars.LF + 
	              NStr("en='Currency code: '; de='Currency code: '; ru='Код валюты: '") + pCurrencyCode + Chars.LF + 
	              NStr("en='Payment date: '; de='Payment date: '; ru='Дата платежа: '") + pPaymentDate + Chars.LF + 
	              NStr("en='Payment external code: '; de='Payment external code: '; ru='Код платежа во внешней системе: '") + pPaymentExternalCode + Chars.LF + 
	              NStr("en='Payment section: '; de='Payment section: '; ru='Код кассовой секции: '") + pPaymentSectionCode + Chars.LF + 
	              NStr("en='Payment amount: '; de='Payment amount: '; ru='Сумма платежа: '") + Format(pSum, "ND=17; NFD=2; NZ="));
	Try
		// Initialize error description
		vErrorDescription = "";
		// Try to find hotel by name or code
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
		If НЕ IsBlankString(pHotelCode) Тогда
			vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
		EndIf;
		// Get currency by code
		vCurrency = Справочники.Валюты.EmptyRef();
		If НЕ IsBlankString(pCurrencyCode) Тогда
			vCurrency = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Валюты", pCurrencyCode);
		EndIf;
					
		// Try to find payment method
		vPaymentMethod = Справочники.СпособОплаты.EmptyRef();
		If НЕ IsBlankString(pPaymentMethod) Тогда
			vPaymentMethod = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СпособОплаты", pPaymentMethod);
		EndIf;
		
		// Try to find payment section
		vPaymentSection = Справочники.ОтделОплаты.EmptyRef();
		If СокрЛП(pPaymentSectionCode) <> "" Тогда
			vPaymentSection = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ОтделОплаты", СокрЛП(pPaymentSectionCode));
		EndIf;
		vPaymentObj = Неопределено;
		
		// Check parameters
		If pSum = 0 Тогда
			ВызватьИсключение NStr("en='Payment sum should be filled!'; de='Payment sum should be filled!'; ru='Сумма платежа должна быть указана!'");
		ElsIf НЕ ЗначениеЗаполнено(vHotel) Тогда
			ВызватьИсключение NStr("en='Гостиница should be specified!'; de='Гостиница should be specified!'; ru='Гостиница должна быть указана!'");
		ElsIf НЕ ЗначениеЗаполнено(vCurrency) Тогда
			ВызватьИсключение NStr("en='Payment curency should be specified!'; de='Payment curency should be specified!'; ru='Валюта платежа должна быть указана!'");
		ElsIf НЕ ЗначениеЗаполнено(vPaymentMethod) Тогда
			ВызватьИсключение NStr("en='Payment method should be choosen!'; de='Payment method should be choosen!'; ru='Способ оплаты должен быть указан!'");
		EndIf;
		
		// Find client card and write payment to folio
		If ЗначениеЗаполнено(pCard) Тогда
			// Get card reference by card identifier
			vCard = cmGetClientIdentificationCardById(pCard);
			If НЕ ЗначениеЗаполнено(vCard) Тогда
				WriteLogEvent(NStr("en='External payment'; de='External payment'; ru='Платеж из внешней системы'"), EventLogLevel.Warning, , , 
				NStr("en='Client identification card was not found!'; de='Client identification card was not found!'; ru='Не найдена карта клиента!'"));
				ВызватьИсключение NStr("en='Client identification card was not found!'; de='Client identification card was not found!'; ru='Не найдена карта клиента!'");
			EndIf;
			
			// Run query to get folios to charge to
			vFolio = vCard.СчетПроживания;
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				ВызватьИсключение NStr("en='Payment folio was not found!'; de='Payment folio was not found!'; ru='Не найден лицевой счет!'");
			EndIf;
			If vFolio.DeletionMark Тогда
				WriteLogEvent(NStr("en='Write external payment by folio'; de='Write external payment by folio'; ru='Платеж из внешней системы по лицевому счету'"), EventLogLevel.Warning, , , 
				NStr("en='Attempt to write payment to the marked for deletion folio! Operation is canceled.'; de='Attempt to write payment to the marked for deletion folio! Operation is canceled.'; ru='Попытка выполнить платеж на помеченный на удаление счет! Операция прервана.'"));
				ВызватьИсключение NStr("en='Attempt to write payment to the marked for deletion folio! Operation is canceled.'; de='Attempt to write payment to the folio marked for deletion! Operation is canceled.'; ru='Попытка выполнить платеж на помеченный на удаление счет! Операция прервана.'");
			EndIf;
			
			WriteLogEvent(NStr("en='Write external payment'; de='Write external payment'; ru='Записать внешний платеж'"), EventLogLevel.Information, vFolio.Metadata(), vFolio, 
			NStr("en='ЛицевойСчет is choosen...'; de='ЛицевойСчет is choosen...'; ru='Назначен лицевой счет...'"));
			//write payment by ГруппаНомеров
		ElsIf ЗначениеЗаполнено(pRoom) Тогда
			// Get ГруппаНомеров by ГруппаНомеров code
			vRoom = Справочники.НомернойФонд.EmptyRef();
			If НЕ IsBlankString(pRoom) Тогда
				vRoom = cmGetRoomByCode(pRoom, pHotelCode, pExternalSystemCode);
			EndIf;
			
			If НЕ ЗначениеЗаполнено(vRoom) Тогда
				ВызватьИсключение NStr("en='ГруппаНомеров was not found!'; de='ГруппаНомеров was not found!'; ru='Не верный номер комнаты'");
			EndIf;
			
			WriteLogEvent(NStr("en='Write external payment'; de='Write external payment'; ru='Записать внешний платеж'"), EventLogLevel.Information, vRoom.Metadata(), vRoom, 
			NStr("en='ГруппаНомеров '; de='Zimmer '; ru='Комната '") + СокрЛП(pRoom));
			
			// Run query to get folios to charge to			  
			vFolio = cmGetFoliosToChargeRoomService(pRoom,?(pPaymentDate=Неопределено,CurrentDate(),pPaymentDate));			  
			
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				ВызватьИсключение NStr("en='Payment folio was not found!'; de='Payment folio was not found!'; ru='Не найден лицевой счет!'");
			EndIf;
			
			If vFolio.DeletionMark Тогда
				WriteLogEvent(NStr("en='Write external payment by folio'; de='Write external payment by folio'; ru='Платеж из внешней системы по лицевому счету'"), EventLogLevel.Warning, , , 
				NStr("en='Attempt to charge to the marked for deletion folio! Operation is canceled.'; de='Attempt to charge to the marked for deletion folio! Operation is canceled.'; ru='Попытка выполнить начисление на помеченный на удаление счет! Операция прервана.'"));
				ВызватьИсключение NStr("en='Attempt to charge to the marked for deletion folio! Operation is canceled.'; de='Attempt to charge to the marked for deletion folio! Operation is canceled.'; ru='Попытка выполнить платеж на помеченный на удаление счет! Операция прервана.'");
			EndIf;
			
			//write payment by folio
		ElsIf ЗначениеЗаполнено(pFolioNumber) Тогда
			// Get folio reference by folio number
			vFolioNumber = cmGetDocumentNumberFromPresentation(pFolioNumber, vHotel);
			vFolio = Documents.СчетПроживания.FindByNumber(vFolioNumber);
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				ВызватьИсключение NStr("en='Payment folio was not found!'; de='Payment folio was not found!'; ru='Не найден лицевой счет!'");
			EndIf;
			WriteLogEvent(NStr("en='Write external payment'; de='Write external payment'; ru='Записать внешний платеж'"), EventLogLevel.Information, vFolio.Metadata(), vFolio, 
			NStr("en='ЛицевойСчет is choosen...'; de='ЛицевойСчет is choosen...'; ru='Назначен лицевой счет...'"));
			
			If vFolio.DeletionMark Тогда
				WriteLogEvent(NStr("en='Write external payment by folio'; de='Write external payment by folio'; ru='Платеж из внешней системы по лицевому счету'"), EventLogLevel.Warning, , , 
				NStr("en='Attempt to write payment to the marked for deletion folio! Operation is canceled.'; de='Attempt to write payment to the marked for deletion folio! Operation is canceled.'; ru='Попытка выполнить начисление на помеченный на удаление счет! Операция прервана.'"));
				ВызватьИсключение NStr("en='Attempt to write payment to the marked for deletion folio! Operation is canceled.'; de='Attempt to write payment to the marked for deletion folio! Operation is canceled.'; ru='Попытка выполнить платеж на помеченный на удаление счет! Операция прервана.'");
			EndIf;
		EndIf;
		// Create payment for the folio being found
		If vPaymentObj = Неопределено Тогда
			vPaymentObj = Documents.Платеж.CreateDocument();
		EndIf;
		vPaymentObj.Fill(vFolio);
		If pPaymentDate <> Неопределено Тогда
			vPaymentObj.ДатаДок = pPaymentDate;
		EndIf;
		If НЕ IsBlankString(pPayerName) Тогда
			vPaymentObj.Примечания = pPayerName;
		EndIf;
		vPaymentObj.PaymentCurrency = vCurrency;
		vPaymentObj.СпособОплаты = vPaymentMethod;
		// Invoice
		If ЗначениеЗаполнено(vFolio.ГруппаГостей) Тогда
			vInvoices = vFolio.ГруппаГостей.GetObject().pmGetInvoices(vFolio.Контрагент, vFolio.Договор);
			For Each vInvoicesRow In vInvoices Do
				If pSum > 0 And vInvoicesRow.Balance > 0 Тогда
					vPaymentObj.СчетНаОплату = vInvoices.Get(0).СчетНаОплату;
					Break;
				ElsIf pSum < 0 And vInvoicesRow.Balance = 0 Тогда
					vPaymentObj.СчетНаОплату = vInvoices.Get(0).СчетНаОплату;
					Break;
				EndIf;
			EndDo;
		EndIf;
		// Payment sections
		If ЗначениеЗаполнено(vPaymentObj.Гостиница) And vPaymentObj.Гостиница.SplitFolioBalanceByPaymentSections Тогда
			vPaymentObj.ОтделОплаты.Clear();
			vPSRow = vPaymentObj.ОтделОплаты.Add();
			vPSRow.PaymentSection = vPaymentSection;
			vPSRow.Сумма = pSum;
			vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, 
			vPaymentObj.ВалютаЛицСчета, vPaymentObj.FolioCurrencyExchangeRate, 
			vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
			If ЗначениеЗаполнено(vPaymentSection) And ЗначениеЗаполнено(vPaymentSection.СтавкаНДС) Тогда
				vPSRow.СтавкаНДС = vPaymentSection.СтавкаНДС;
			Else
				vPSRow.СтавкаНДС = vPaymentObj.СтавкаНДС;
			EndIf;
			vPSRow.СуммаНДС = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.Сумма);
			vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, 
			vPaymentObj.ВалютаЛицСчета, vPaymentObj.FolioCurrencyExchangeRate, 
			vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
			vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.SumInFolioCurrency);
			vPaymentObj.pmCalculateTotalsByPaymentSections();
		Else
			vPaymentObj.PaymentSection = vPaymentSection;
			vPaymentObj.Сумма = pSum;
			If TypeOf(vPaymentObj) = Type("DocumentObject.Платеж") Тогда
				//vPaymentObj.pmRecalculateSums();
			ElsIf TypeOf(vPaymentObj) = Type("DocumentObject.ПлатежКонтрагента") Тогда
				vPaymentObj.SumInAccountingCurrency = Round(cmConvertCurrencies(vPaymentObj.Сумма, vPaymentObj.PaymentCurrency, vPaymentObj.PaymentCurrencyExchangeRate, vPaymentObj.ВалютаРасчетов, vPaymentObj.AccountingCurrencyExchangeRate, vPaymentObj.ExchangeRateDate, vPaymentObj.Гостиница), 2);
			EndIf;
		EndIf;
		// Reference and authorization codes
		vPaymentObj.ReferenceNumber = "";
		vPaymentObj.AuthorizationCode = "";
		// Payment remarks
		vPaymentObj.SlipText = "";
		// External system payment code
		vPaymentObj.ExternalCode = TrimR(pPaymentExternalCode);
		// Set Контрагент as payer
		If ЗначениеЗаполнено(vPaymentObj.Контрагент) And ЗначениеЗаполнено(vPaymentObj.СпособОплаты) And vPaymentObj.СпособОплаты.IsByBankTransfer Тогда
			If ЗначениеЗаполнено(vPaymentObj.Гостиница) And vPaymentObj.Контрагент <> vPaymentObj.Гостиница.IndividualsCustomer Тогда
				vPaymentObj.Payer = vPaymentObj.Контрагент;
			EndIf;
		EndIf;
		// Post payment
		vPaymentObj.Write(DocumentWriteMode.Posting);

		// Build return string
		vRetStr = """" + СокрЛП(vPaymentObj.НомерДока) + """" + "," + """" + """";

		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			Return "";
		EndIf;
	Except
		vErrorDescription = ErrorDescription();
		// Write log event
		WriteLogEvent(NStr("en='Write external payment'; de='Write external payment'; ru='Записать внешний платеж'"), EventLogLevel.Error, , , 
					  NStr("en='Error description: '; de='Error description: '; ru='Описание ошибки: '") + ErrorDescription());
					  
		// Build return string
		vRetStr = """" + """" + "," + """" + vErrorDescription + """";
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			Return Left(vErrorDescription, 2048);
		EndIf;
	EndTry;
EndFunction //cmWriteExternalPayment

//-----------------------------------------------------------------------------
// Description: This procedure marks external payments for deletion for the given period
// Parameters: Period from, Period to, External system code, Гостиница code, Фирма code
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmClearExternalPayments(pPeriodFrom, pPeriodTo, pExternalSystemCode = "", pHotelCode = "", pCompanyCode = "") Экспорт
	WriteLogEvent(NStr("en='Clear external payments';ru='Очистить платежи внешней системы';de='Zahlungen des externen Systems löschen'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='Фирма code: ';ru='Код фирмы: ';de='Firmencode: '") + pCompanyCode + Chars.LF + 
	              NStr("en='Period from: ';ru='Дата и время начала периода: ';de='Datum und Zeit des Zeitraumbeginns: '") + pPeriodFrom + Chars.LF + 
	              NStr("en='Period to: ';ru='Дата и время окончания периода: ';de='Datum und Zeit des Zeitraumendes: '") + pPeriodTo);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Try to find Фирма
	vCompany = Справочники.Фирмы.EmptyRef();
	If НЕ IsBlankString(pCompanyCode) Тогда
		vCompany = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Фирмы", pCompanyCode);
	EndIf;
	// Do in one transaction
	BeginTransaction();
	// Run query to get payments
	vPaymentsQry = New Query();
	vPaymentsQry.Text = 
	"SELECT
	|	ExternalPayments.Ref,
	|	ExternalPayments.ДатаДок
	|FROM
	|	(SELECT
	|		Платежи.Ref AS Ref,
	|		Платежи.ДатаДок AS Date
	|	FROM
	|		Document.Платеж AS Платежи
	|	WHERE
	|		Платежи.Posted
	|		AND Платежи.ДатаДок >= &qPeriodFrom
	|		AND Платежи.ДатаДок <= &qPeriodTo
	|		AND Платежи.Гостиница = &qHotel
	|		AND (Платежи.Фирма = &qCompany
	|				OR &qCompanyIsEmpty)
	|		AND Платежи.ExternalCode > &qEmptyString
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		CustomerPayments.Ref,
	|		CustomerPayments.ДатаДок
	|	FROM
	|		Document.ПлатежКонтрагента AS CustomerPayments
	|	WHERE
	|		CustomerPayments.Posted
	|		AND CustomerPayments.ДатаДок >= &qPeriodFrom
	|		AND CustomerPayments.ДатаДок <= &qPeriodTo
	|		AND CustomerPayments.Гостиница = &qHotel
	|		AND (CustomerPayments.Фирма = &qCompany
	|				OR &qCompanyIsEmpty)
	|		AND CustomerPayments.ExternalCode > &qEmptyString) AS ExternalPayments
	|
	|ORDER BY
	|	ExternalPayments.ДатаДок";
	vPaymentsQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vPaymentsQry.SetParameter("qPeriodTo", pPeriodTo);
	vPaymentsQry.SetParameter("qHotel", vHotel);
	vPaymentsQry.SetParameter("qCompany", vCompany);
	vPaymentsQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(vCompany));
	vPaymentsQry.SetParameter("qEmptyString", "");
	vPayments = vPaymentsQry.Execute().Unload();
	For Each vPaymentsRow In vPayments Do
		vPaymentObj = vPaymentsRow.Ref.GetObject();
		vPaymentObj.SetDeletionMark(True);
	EndDo;		
	// Commit transaction
	CommitTransaction();
	// Log success		
	WriteLogEvent(NStr("en='Clear external payments';ru='Очистить платежи внешней системы';de='Zahlungen des externen Systems löschen'"), EventLogLevel.Information, , , 
				  NStr("en='Cleared payments - ';ru='Помечено платежей - ';de='Zahlungen markiert - '") + vPayments.Count());
КонецПроцедуры //cmClearExternalPayments

//-----------------------------------------------------------------------------
// Description: This procedure creates guest group attachment with given type and texts
// Parameters: Guest group reference, Attachment types reference, Attachment remarks, Attachment text
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmWriteGuestGroupAttachment(pGuestGroupRef, pAttachmentType, pRemarks, pDocumentText) Экспорт
	// Write guest group attachment that payment was received
	vGrpAttachmentsRecMgr = InformationRegisters.ДокументыГруппыСведения.CreateRecordManager();
	vGrpAttachmentsRecMgr.Period = CurrentDate();
	vGrpAttachmentsRecMgr.ГруппаГостей = pGuestGroupRef;
	If ЗначениеЗаполнено(pGuestGroupRef.ClientDoc) And TypeOf(pGuestGroupRef.ClientDoc) <> Type("DocumentRef.СчетПроживания") Тогда
		If IsBlankString(vGrpAttachmentsRecMgr.Fax) Тогда
			vGrpAttachmentsRecMgr.Fax = pGuestGroupRef.ClientDoc.Fax;
		EndIf;
		If IsBlankString(vGrpAttachmentsRecMgr.EMail) Тогда
			vGrpAttachmentsRecMgr.EMail = pGuestGroupRef.ClientDoc.EMail;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(pGuestGroupRef.Клиент) Тогда
		If IsBlankString(vGrpAttachmentsRecMgr.Fax) Тогда
			vGrpAttachmentsRecMgr.Fax = pGuestGroupRef.Клиент.Fax;
		EndIf;
		If IsBlankString(vGrpAttachmentsRecMgr.EMail) Тогда
			vGrpAttachmentsRecMgr.EMail = pGuestGroupRef.Клиент.EMail;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(pGuestGroupRef.Контрагент) Тогда
		If IsBlankString(vGrpAttachmentsRecMgr.Fax) Тогда
			vGrpAttachmentsRecMgr.Fax = pGuestGroupRef.Контрагент.Fax;
		EndIf;
		If IsBlankString(vGrpAttachmentsRecMgr.EMail) Тогда
			vGrpAttachmentsRecMgr.EMail = pGuestGroupRef.Контрагент.EMail;
		EndIf;
	EndIf;
	vGrpAttachmentsRecMgr.AttachmentStatus = Перечисления.AttachmentStatuses.Ready;
	vGrpAttachmentsRecMgr.AttachmentType = pAttachmentType;
	vGrpAttachmentsRecMgr.Примечания = pRemarks;
	vGrpAttachmentsRecMgr.DocumentText = pDocumentText;
	// Write attachment
	vGrpAttachmentsRecMgr.Write();
КонецПроцедуры //cmWriteGuestGroupAttachment

//-----------------------------------------------------------------------------
// Description: Returns value table with vacant hotel products active for the period
//              given
// Parameters: Гостиница code, ГруппаНомеров type code, Контрагент name, Contract name, Agent name, 
//             ГруппаНомеров quota (allotment) code, Period from date, Period to date, Flags 
//             to defined what type of resources to return, External system code, 
//             Language code, Output type: XDTO oject, CSV string or XML, XML Writer to
//             write XML data to
// Return value: XDTO VacantHotelProducts object or CSV string or XML data
//-----------------------------------------------------------------------------
Function cmGetVacantCheckInPeriods(pHotelCode, pRoomRateCode, pRoomTypeCode, pCustomerName, pContractName, pAgentName, 
                                   pRoomQuotaCode, pPeriodFrom, pPeriodTo, 
                                   pExternalSystemCode, pLanguageCode = "RU", pOutputType = "CSV", pXMLWriter = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Get vacant allowed check-in periods';ru='Получить остатки по периодам заездов';de='Restbestände nach Anreisezeiträumen erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='ГруппаНомеров rate code: ';ru='Код тарифа: ';de='Tarifcode: '") + pRoomRateCode + Chars.LF + 
	              NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + pRoomTypeCode + Chars.LF + 
	              NStr("en='Контрагент name: ';ru='Название контрагента: ';de='Bezeichnung des Partners: '") + pCustomerName + Chars.LF + 
	              NStr("en='Contract name: ';ru='Название договора: ';de='Bezeichnung des Vertrags: '") + pContractName + Chars.LF + 
	              NStr("en='Agent name: ';ru='Название агента: ';de='Bezeichnung des Vertreters: '") + pAgentName + Chars.LF + 
	              NStr("en='Allotment code: ';ru='Код квоты номеров: ';de='Zimmerquotencode: '") + pRoomQuotaCode + Chars.LF + 
	              NStr("en='Period from: ';ru='Начало периода: ';de='Zeitraumbeginn: '") + pPeriodFrom + Chars.LF + 
	              NStr("en='Period to: ';ru='Конец периода: ';de='Zeitraumende: '") + pPeriodTo);  
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Retrieve parameter references based on codes
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	vRoomRate = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Тарифы", pRoomRateCode);
	vRoomType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыНомеров", pRoomTypeCode);
	vCustomer = cmGetCustomerByName(pCustomerName);
	vContract = cmGetContractByName(vCustomer, pContractName);
	vAgent = cmGetCustomerByName(pAgentName);
	vRoomQuota = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "КвотаНомеров", pRoomQuotaCode);
	// Call API to get value table with balances
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	CheckInPeriods.Гостиница AS Гостиница,
	|	CheckInPeriods.Тариф AS Тариф,
	|	CheckInPeriods.CheckInDate AS CheckInDate,
	|	CheckInPeriods.Продолжительность AS Продолжительность,
	|	CheckInPeriods.ДатаВыезда AS ДатаВыезда,
	|	CheckInPeriods.КвотаНомеров AS Allotment,
	|	SUM(CheckInPeriods.RoomsVacant) AS RoomsVacant,
	|	SUM(CheckInPeriods.BedsVacant) AS BedsVacant,
	|	SUM(CheckInPeriods.ОстаетсяНомеров) AS ОстаетсяНомеров,
	|	SUM(CheckInPeriods.ОстаетсяМест) AS ОстаетсяМест
	|FROM
	|	(SELECT
	|		CheckInPeriods1.Гостиница AS Гостиница,
	|		CheckInPeriods1.Тариф AS Тариф,
	|		CheckInPeriods1.CheckInDate AS CheckInDate,
	|		CheckInPeriods1.Продолжительность AS Продолжительность,
	|		CheckInPeriods1.ДатаВыезда AS ДатаВыезда,
	|		&qEmptyRoomQuota AS КвотаНомеров,
	|		MIN(ISNULL(ЗагрузкаНомеров.RoomsVacant, 0)) AS RoomsVacant,
	|		MIN(ISNULL(ЗагрузкаНомеров.BedsVacant, 0)) AS BedsVacant,
	|		0 AS ОстаетсяНомеров,
	|		0 AS ОстаетсяМест
	|	FROM
	|		InformationRegister.RoomQuotaCheckInPeriods AS CheckInPeriods1
	|			LEFT JOIN (SELECT
	|				RoomInventoryBalanceAndTurnovers.Гостиница AS RoomInventoryBalanceHotel,
	|				RoomInventoryBalanceAndTurnovers.Period AS RoomInventoryBalancePeriod,
	|				RoomInventoryBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
	|				RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance AS RoomsVacant,
	|				RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance AS BedsVacant
	|			FROM
	|				AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|						&qPeriodFrom,
	|						&qInventoryPeriodTo,
	|						Second,
	|						RegisterRecordsAndPeriodBoundaries,
	|						(Гостиница IN HIERARCHY (&qHotel)
	|							OR &qHotelIsEmpty)
	|							AND (ТипНомера IN HIERARCHY (&qRoomType)
	|								OR &qRoomTypeIsEmpty)) AS RoomInventoryBalanceAndTurnovers) AS ЗагрузкаНомеров
	|			ON (ЗагрузкаНомеров.RoomInventoryBalanceHotel = CheckInPeriods1.Гостиница)
	|				AND (CheckInPeriods1.КвотаНомеров = &qEmptyRoomQuota)
	|				AND (ЗагрузкаНомеров.RoomInventoryBalancePeriod >= CheckInPeriods1.CheckInDate)
	|				AND (ЗагрузкаНомеров.RoomInventoryBalancePeriod < CheckInPeriods1.ДатаВыезда)
	|	WHERE
	|		NOT CheckInPeriods1.IsNotActive
	|		AND CheckInPeriods1.Продолжительность > 1
	|		AND CheckInPeriods1.КвотаНомеров = &qEmptyRoomQuota
	|		AND (CheckInPeriods1.Гостиница IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|		AND (CheckInPeriods1.Тариф IN HIERARCHY (&qRoomRate)
	|				OR &qRoomRateIsEmpty)
	|		AND CheckInPeriods1.CheckInDate >= &qPeriodFrom
	|		AND CheckInPeriods1.CheckInDate <= &qPeriodTo
	|	
	|	GROUP BY
	|		CheckInPeriods1.Гостиница,
	|		CheckInPeriods1.Тариф,
	|		CheckInPeriods1.CheckInDate,
	|		CheckInPeriods1.Продолжительность,
	|		CheckInPeriods1.ДатаВыезда
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		CheckInPeriods2.Гостиница,
	|		CheckInPeriods2.Тариф,
	|		CheckInPeriods2.CheckInDate,
	|		CheckInPeriods2.Продолжительность,
	|		CheckInPeriods2.ДатаВыезда,
	|		CheckInPeriods2.КвотаНомеров,
	|		0,
	|		0,
	|		MIN(ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)),
	|		MIN(ISNULL(RoomQuotaBalances.ОстаетсяМест, 0))
	|	FROM
	|		InformationRegister.RoomQuotaCheckInPeriods AS CheckInPeriods2
	|			LEFT JOIN (SELECT
	|				RoomQuotaSalesBalanceAndTurnovers.Гостиница AS RoomQuotaSalesBalanceHotel,
	|				RoomQuotaSalesBalanceAndTurnovers.КвотаНомеров AS RoomQuotaSalesBalanceRoomQuota,
	|				RoomQuotaSalesBalanceAndTurnovers.Period AS RoomQuotaSalesBalancePeriod,
	|				RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
	|				RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS ОстаетсяНомеров,
	|				RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS ОстаетсяМест
	|			FROM
	|				AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|						&qPeriodFrom,
	|						&qInventoryPeriodTo,
	|						Second,
	|						RegisterRecordsAndPeriodBoundaries,
	|						(Гостиница IN HIERARCHY (&qHotel)
	|							OR &qHotelIsEmpty)
	|							AND (ТипНомера IN HIERARCHY (&qRoomType)
	|								OR &qRoomTypeIsEmpty)
	|							AND (КвотаНомеров IN HIERARCHY (&qRoomQuota)
	|								OR &qRoomQuotaIsEmpty)
	|							AND (КвотаНомеров.Агент IN HIERARCHY (&qAgent)
	|								OR &qAgentIsEmpty)
	|							AND (КвотаНомеров.Контрагент IN HIERARCHY (&qCustomer)
	|								OR &qCustomerIsEmpty)
	|							AND (КвотаНомеров.Договор = &qContract
	|								OR &qContractIsEmpty)) AS RoomQuotaSalesBalanceAndTurnovers) AS RoomQuotaBalances
	|			ON (RoomQuotaBalances.RoomQuotaSalesBalanceHotel = CheckInPeriods2.Гостиница)
	|				AND (RoomQuotaBalances.RoomQuotaSalesBalanceRoomQuota = CheckInPeriods2.КвотаНомеров)
	|				AND (RoomQuotaBalances.RoomQuotaSalesBalancePeriod >= CheckInPeriods2.CheckInDate)
	|				AND (RoomQuotaBalances.RoomQuotaSalesBalancePeriod < CheckInPeriods2.ДатаВыезда)
	|	WHERE
	|		NOT CheckInPeriods2.IsNotActive
	|		AND CheckInPeriods2.Продолжительность > 1
	|		AND CheckInPeriods2.КвотаНомеров <> &qEmptyRoomQuota
	|		AND (CheckInPeriods2.Гостиница IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|		AND (CheckInPeriods2.Тариф IN HIERARCHY (&qRoomRate)
	|				OR &qRoomRateIsEmpty)
	|		AND CheckInPeriods2.CheckInDate >= &qPeriodFrom
	|		AND CheckInPeriods2.CheckInDate <= &qPeriodTo
	|	
	|	GROUP BY
	|		CheckInPeriods2.Гостиница,
	|		CheckInPeriods2.Тариф,
	|		CheckInPeriods2.CheckInDate,
	|		CheckInPeriods2.Продолжительность,
	|		CheckInPeriods2.ДатаВыезда,
	|		CheckInPeriods2.КвотаНомеров) AS CheckInPeriods
	|
	|GROUP BY
	|	CheckInPeriods.Гостиница,
	|	CheckInPeriods.Тариф,
	|	CheckInPeriods.CheckInDate,
	|	CheckInPeriods.Продолжительность,
	|	CheckInPeriods.ДатаВыезда,
	|	CheckInPeriods.КвотаНомеров
	|
	|HAVING
	|	(NOT &qRoomQuotaIsEmpty
	|			AND SUM(CheckInPeriods.ОстаетсяМест) > 0
	|		OR &qRoomQuotaIsEmpty
	|			AND SUM(CheckInPeriods.BedsVacant) > 0)
	|
	|ORDER BY
	|	CheckInPeriods.Гостиница.ПорядокСортировки,
	|	CheckInDate,
	|	Продолжительность,
	|	ДатаВыезда";
	vQry.SetParameter("qHotel", vHotel);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(vHotel));
	vQry.SetParameter("qRoomRate", vRoomRate);
	vQry.SetParameter("qRoomRateIsEmpty", НЕ ЗначениеЗаполнено(vRoomRate));
	vQry.SetParameter("qRoomType", vRoomType);
	vQry.SetParameter("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(vRoomType));
	vQry.SetParameter("qCustomer", vCustomer);
	vQry.SetParameter("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(vCustomer));
	vQry.SetParameter("qContract", vContract);
	vQry.SetParameter("qContractIsEmpty", НЕ ЗначениеЗаполнено(vContract));
	vQry.SetParameter("qAgent", vAgent);
	vQry.SetParameter("qAgentIsEmpty", НЕ ЗначениеЗаполнено(vAgent));
	vQry.SetParameter("qRoomQuota", vRoomQuota);
	vQry.SetParameter("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(vRoomQuota));
	vQry.SetParameter("qEmptyRoomQuota", Справочники.КвотаНомеров.EmptyRef());
	vQry.SetParameter("qPeriodFrom", BegOfDay(pPeriodFrom));
	vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
	vQry.SetParameter("qInventoryPeriodTo", EndOfDay(pPeriodTo) + 90*24*3600);
	vVacantPeriods = vQry.Execute().Unload();
	vVacantPeriods.Columns.Add("ExtHotelCode", cmGetStringTypeDescription());
	vVacantPeriods.Columns.Add("ExtRoomRateCode", cmGetStringTypeDescription());
	vVacantPeriods.Columns.Add("RoomRateDescription", cmGetStringTypeDescription());
	vVacantPeriods.Columns.Add("ExtAllotmentCode", cmGetStringTypeDescription());
	vVacantPeriods.Columns.Add("AllotmentDescription", cmGetStringTypeDescription());
	// Build return string
	vRetStr = "";
	For Each vRow In vVacantPeriods Do
		// Reset hotel balances if ГруппаНомеров quota is specified
		If ЗначениеЗаполнено(vRoomQuota) Тогда
			vRow.RoomsVacant = 0;
			vRow.BedsVacant = 0;
		EndIf;
		// Fill output attributes		
		vRow.ExtHotelCode = "";
		If ЗначениеЗаполнено(vRow.Гостиница) Тогда
			vRow.ExtHotelCode = cmGetObjectExternalSystemCodeByRef(Справочники.Гостиницы.EmptyRef(), pExternalSystemCode, "Hotels", vRow.Гостиница);
		EndIf;
		vRow.ExtRoomRateCode = "";
		vRow.RoomRateDescription = "";
		If ЗначениеЗаполнено(vRow.Тариф) Тогда
			vRow.ExtRoomRateCode = cmGetObjectExternalSystemCodeByRef(vRow.Гостиница, pExternalSystemCode, "Тарифы", vRow.Тариф);
			vRow.RoomRateDescription = vRow.Тариф.GetObject().pmGetRoomRateDescription(vLanguage);
		EndIf;
		vRow.ExtAllotmentCode = "";
		vRow.AllotmentDescription = "";
		If ЗначениеЗаполнено(vRow.Allotment) Тогда
			vRow.ExtAllotmentCode = cmGetObjectExternalSystemCodeByRef(vRow.Гостиница, pExternalSystemCode, "КвотаНомеров", vRow.Allotment);
			vRow.AllotmentDescription = СокрЛП(vRow.Allotment.Description);
		EndIf;
		// Build return string
		vRetStr = vRetStr + 
		          """" + СокрЛП(vRow.ExtHotelCode) + """" + "," + 
		          """" + СокрЛП(vRow.ExtRoomRateCode) + """" + "," + 
		          """" + cmRemoveComma(vRow.RoomRateDescription) + """" + "," + 
		          """" + СокрЛП(vRow.ExtAllotmentCode) + """" + "," + 
		          """" + cmRemoveComma(vRow.AllotmentDescription) + """" + "," + 
		          """" + Format(vRow.CheckInDate, "DF='yyyy-MM-dd HH:mm'") + """" + "," + 
		          Format(vRow.Duration, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
		          """" + Format(vRow.CheckOutDate, "DF='yyyy-MM-dd HH:mm'") + """" + "," + 
		          Format(vRow.RoomsVacant, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
		          Format(vRow.BedsVacant, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
		          Format(vRow.RoomsRemains, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
				  Format(vRow.BedsRemains, "ND=10; NFD=0; NZ=; NG=; NN=") + 
				  Chars.LF;
	EndDo;
	WriteLogEvent(NStr("en='Get vacant allowed check-in periods';ru='Получить остатки по периодам заездов';de='Restbestände nach Anreisezeiträumen erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	// Return based on output type
	If pOutputType = "CSV" Тогда
		Return vRetStr;
	Else
		// Write XML
		If pOutputType = "XML" Тогда
			pXMLWriter.WriteStartElement("VacantCheckInPeriods");
		EndIf;
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "VacantCheckInPeriods"));
		vRetRowType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "VacantCheckInPeriodsRow");
		For Each vRow In vVacantPeriods Do
			vRetRow = XDTOFactory.Create(vRetRowType);
			vRetRow.Гостиница = СокрЛП(vRow.ExtHotelCode);
			vRetRow.Тариф = СокрЛП(vRow.ExtRoomRateCode);
			vRetRow.RoomRateDescription = СокрЛП(vRow.RoomRateDescription);
			vRetRow.Allotment = СокрЛП(vRow.ExtAllotmentCode);
			vRetRow.AllotmentDescription = СокрЛП(vRow.AllotmentDescription);
			vRetRow.CheckInDate = vRow.CheckInDate;
			vRetRow.Продолжительность = vRow.Duration;
			vRetRow.ДатаВыезда = vRow.CheckOutDate;
			vRetRow.RoomsVacant = vRow.RoomsVacant;
			vRetRow.BedsVacant = vRow.BedsVacant;
			vRetRow.ОстаетсяНомеров = vRow.RoomsRemains;
			vRetRow.ОстаетсяМест = vRow.BedsRemains;
			vRetXDTO.VacantCheckInPeriodsRow.Add(vRetRow);
			// Write XML
			If pOutputType = "XML" Тогда
				pXMLWriter.WriteStartElement("VacantCheckInPeriodsRow");
				
				pXMLWriter.WriteStartElement("Гостиница");
				pXMLWriter.WriteText(СокрЛП(vRow.ExtHotelCode));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("Тариф");
				pXMLWriter.WriteAttribute("Description", СокрЛП(vRow.RoomRateDescription));
				pXMLWriter.WriteText(СокрЛП(vRow.ExtRoomRateCode));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("Allotment");
				pXMLWriter.WriteAttribute("Description", СокрЛП(vRow.AllotmentDescription));
				pXMLWriter.WriteText(СокрЛП(vRow.ExtAllotmentCode));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("CheckInDate");
				pXMLWriter.WriteText(Format(vRow.CheckInDate, "DF='yyyy-MM-dd HH:mm'"));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("Продолжительность");
				pXMLWriter.WriteText(Format(vRow.Duration, "ND=10; NFD=0; NZ=; NG=; NN="));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("ДатаВыезда");
				pXMLWriter.WriteText(Format(vRow.CheckOutDate, "DF='yyyy-MM-dd HH:mm'"));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("RoomsVacant");
				pXMLWriter.WriteText(Format(vRow.RoomsVacant, "ND=10; NFD=0; NZ=; NG="));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("BedsVacant");
				pXMLWriter.WriteText(Format(vRow.BedsVacant, "ND=10; NFD=0; NZ=; NG="));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("ОстаетсяНомеров");
				pXMLWriter.WriteText(Format(vRow.RoomsRemains, "ND=10; NFD=0; NZ=; NG="));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteStartElement("ОстаетсяМест");
				pXMLWriter.WriteText(Format(vRow.BedsRemains, "ND=10; NFD=0; NZ=; NG="));
				pXMLWriter.WriteEndElement();
				
				pXMLWriter.WriteEndElement();
			EndIf;
		EndDo;
		// Write XML
		If pOutputType = "XML" Тогда
			pXMLWriter.WriteEndElement();
		EndIf;
		Return vRetXDTO;
	EndIf;
EndFunction //cmGetVacantCheckInPeriods

//-----------------------------------------------------------------------------
// Description: Returns guest group reservation data checking user identity according to the 
//              user e-mail or phone number
// Parameters: E-Mail, Phone, Login, Group code, Гостиница code, External system code, Language code, Output type: XDTO oject, CSV string
// Return value: XDTO ExternalGroupReservationStatus object or CSV string
//-----------------------------------------------------------------------------
Function cmGetGroupReservationDetails(pEMail, pPhone, pLogin, pGuestGroupCode, pHotelCode, pExternalSystemCode, pLanguageCode = "RU", pOutputType = "XDTO") Экспорт
	// Get language
	//vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Get result from old API
	vGroupStatusObj = cmGetExternalGroupReservationStatus(pGuestGroupCode, pHotelCode, pExternalSystemCode, pLanguageCode, pOutputType);
	// Check if authentication data are present in the returned data
	If pOutputType = "XDTO" Тогда
		If IsBlankString(vGroupStatusObj.ErrorDescription) Тогда
			If StrLen(pGuestGroupCode) <> 36 Тогда
				If НЕ IsBlankString(pEMail) Тогда
					If cmCheckEMailIsValid(СокрЛП(pEMail)) AND Find(Lower(vGroupStatusObj.GuestEMail), Lower(СокрЛП(pEMail))) > 0 Тогда
						Return vGroupStatusObj;
					EndIf;
				EndIf;
				//If НЕ IsBlankString(pPhone) Тогда
				//	If StrLen(СокрЛП(pPhone)) >= 7 AND Find(SMS.GetValidPhoneNumber(СокрЛП(vGroupStatusObj.GuestPhone)), SMS.GetValidPhoneNumber(СокрЛП(pPhone))) > 0 Тогда
				//		Return vGroupStatusObj;
				//	EndIf;
				//EndIf;
				If НЕ IsBlankString(pLogin) Тогда
					vCustomerStruct = cmGetCustomerByLogin(vHotel, pExternalSystemCode, pLogin);
					If vCustomerStruct <> Неопределено Тогда
						If ЗначениеЗаполнено(vCustomerStruct.Контрагент) Тогда
							If Find(Lower(vGroupStatusObj.Контрагент), Lower(СокрЛП(vCustomerStruct.Контрагент.Description))) > 0 Тогда
								Return vGroupStatusObj;
							EndIf;
						EndIf;
					EndIf;
				EndIf;
			Else
				Return vGroupStatusObj;
			EndIf;
		Else
			Return vGroupStatusObj;
		EndIf;
	ElsIf pOutputType = "CSV" Тогда
		If НЕ IsBlankString(pEMail) Тогда
			If Find(Lower(vGroupStatusObj), Lower(СокрЛП(pEMail))) > 0 Тогда
				Return vGroupStatusObj;
			EndIf;
		EndIf;
		If НЕ IsBlankString(pPhone) Тогда
			If Find(vGroupStatusObj, СокрЛП(pPhone)) > 0 Тогда
				Return vGroupStatusObj;
			EndIf;
		EndIf;
		If НЕ IsBlankString(pLogin) Тогда
			vCustomerStruct = cmGetCustomerByLogin(vHotel, pExternalSystemCode, pLogin);
			If vCustomerStruct <> Неопределено Тогда
				If ЗначениеЗаполнено(vCustomerStruct.Контрагент) Тогда
					If Find(Lower(vGroupStatusObj), Lower(СокрЛП(vCustomerStruct.Контрагент.Description))) > 0 Тогда
						Return vGroupStatusObj;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	// Error message
	vErrorMessage = "Пользователь не авторизован!";
	If pOutputType = "XDTO" Тогда
		vGroupStatusObj = XDTOFactory.Create(XDTOFactory.Type("http://www.1cho7tel.ru/interfaces/reservation/", "ExternalGroupReservationStatus"));
		vGroupStatusObj.ErrorDescription = vErrorMessage;
	Else
		vGroupStatusObj = vErrorMessage;
	EndIf;
	Return vGroupStatusObj;
EndFunction //cmGetGroupReservationDetails

//-----------------------------------------------------------------------------
// Description: Returns Контрагент and contract by login
// Parameters: Login
// Return value: Structure with Контрагент and contract elements
//-----------------------------------------------------------------------------
Function cmGetCustomerByLogin(pHotel, pExternalSystemCode, pLogin) Экспорт
	vCustomerStruct = Неопределено;
	If НЕ IsBlankString(pLogin) Тогда
		vCustomerStruct = New Structure("Контрагент, Договор", Неопределено, Неопределено);
		vLoginContract = cmGetObjectRefByExternalSystemCode(pHotel, pExternalSystemCode, "Договора", СокрЛП(pLogin));
		If ЗначениеЗаполнено(vLoginContract) And НЕ vLoginContract.DeletionMark Тогда
			vLoginCustomer = vLoginContract.Owner;
			If ЗначениеЗаполнено(vLoginCustomer) And НЕ vLoginCustomer.DeletionMark Тогда
				vCustomerStruct.Контрагент = vLoginCustomer;
				vCustomerStruct.Contract = vLoginContract;
			EndIf;
		EndIf;
	EndIf;
	Return vCustomerStruct;
EndFunction //cmGetCustomerByLogin

//-----------------------------------------------------------------------------
// Description: Cancels group reservation
// Parameters: Group code, Гостиница code, External system code, Language code
// Return value: Error description as string
//-----------------------------------------------------------------------------
Function cmCancelGroupReservation(pGuestGroupCode, pHotelCode, pExternalSystemCode, pLanguageCode = "RU", pReason = "", pExtReservationCode = "", pAnnulationStatus = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Cancel group reservation';ru='Отмена групповой брони';de='Abbruch der Gruppenreservierung'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='Guest group code: ';ru='Номер группы гостей: ';de='Nummer der Gästegruppe: '") + pGuestGroupCode + Chars.LF + 
	              NStr("en='Reservation code: ';ru='Код брони гостя: ';de='Reservierungscode des Gastes: '") + pExtReservationCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Annulation reason: ';ru='Причина отмены: ';de='Grund des Abbruchs: '") + pReason);
	// Get language
	//vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Get guest group by code
	vGuestGroup = cmGetGuestGroupByExternalCode(vHotel, pGuestGroupCode, "", "", False);
	// Check if group was found
	If НЕ ЗначениеЗаполнено(vGuestGroup) Тогда
		Return "Группа не найдена!";
	EndIf;
	vReservations = vGuestGroup.GetObject().pmGetReservations(True, True);
	Try
		BeginTransaction(DataLockControlMode.Managed);
		For Each vReservationsRow In vReservations Do
			vReservationRef = vReservationsRow.Бронирование;
			If НЕ IsBlankString(pExtReservationCode) Тогда
				If СокрЛП(vReservationRef.НомерДока) <> СокрЛП(pExtReservationCode) And 
				   СокрЛП(vReservationRef.ExternalCode) <> СокрЛП(pExtReservationCode) Тогда
					Continue;
				EndIf;
			EndIf;
			vAnnulationStatus = Справочники.СтатусБрони.EmptyRef();
			If ЗначениеЗаполнено(pAnnulationStatus) Тогда
				vAnnulationStatus = pAnnulationStatus;
			EndIf;
			If НЕ ЗначениеЗаполнено(vAnnulationStatus) Тогда
				vAnnulationStatus = cmGetReservationAnnulationStatus(vReservationRef);
			EndIf;
			If НЕ ЗначениеЗаполнено(vAnnulationStatus) Тогда
				Return "Не удалось получить статус аннуляции брони!";
			EndIf;
			If vReservationRef.ReservationStatus <> vAnnulationStatus Тогда
				vReservationObj = vReservationRef.GetObject();
				vReservationObj.ReservationStatus = vAnnulationStatus;
				vReservationObj.pmSetDoCharging();
				vReservationObj.AuthorOfAnnulation = ПараметрыСеанса.ТекПользователь;
				vReservationObj.DateOfAnnulation = CurrentDate();
				vReservationObj.AnnulationReason = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ПричиныВыполненияОпераций", TrimR(pReason));
				vReservationObj.pmCalculateServices();
				vReservationObj.Write(DocumentWriteMode.Posting);
				vReservationObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			EndIf;
		EndDo;
		CommitTransaction();
	Except
		vErrorDescription = ErrorDescription();
		If TransactionActive() Тогда
			RollbackTransaction();
		EndIf;
		Return Left(vErrorDescription, 2048);
	EndTry;
	Return "";
EndFunction //cmCancelGroupReservation

//-----------------------------------------------------------------------------
// Description: Cancels group reservation
// Parameters: Group code, Гостиница code, External system code, Language code
// Return value: Error description as string
//-----------------------------------------------------------------------------
Function cmGetActiveGroupsList(pLogin, pHotelCode, pExternalSystemCode, pLanguageCode = "RU") Экспорт
	WriteLogEvent(NStr("en='Get active groups list';ru='Получить список действующих групп';de='Liste der aktiven Gruppen erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='Login: ';ru='Логин: ';de='Login: '") + pLogin + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode);
	// Get language
	//vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Get Контрагент and contract by login
	vCustomerStruct = cmGetCustomerByLogin(vHotel, pExternalSystemCode, pLogin);
	// Create return object
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GroupsList"));
	// Get active reservations and group by them by guest group
	If vCustomerStruct <> Неопределено And ЗначениеЗаполнено(vCustomerStruct.Контрагент) Тогда
		// Get Контрагент and contract references
		vCustomer = vCustomerStruct.Контрагент;
		vContract = vCustomerStruct.Договор;
		// Run query
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ГруппыГостей.ГруппаГостей AS ГруппаГостей,
		|	ГруппыГостей.GuestGroupCode AS GuestGroupCode,
		|	ГруппыГостей.Status AS Status,
		|	ГруппыГостей.CheckInDate AS CheckInDate,
		|	ГруппыГостей.Продолжительность AS Продолжительность,
		|	ГруппыГостей.ДатаВыезда AS ДатаВыезда,
		|	ГруппыГостей.КоличествоЧеловек AS КоличествоЧеловек,
		|	ГруппыГостей.GuestFullName AS GuestFullName,
		|	ГруппыГостей.Телефон AS Телефон,
		|	ГруппыГостей.Email AS Email,
		|	ГруппыГостей.Примечания AS Примечания,
		|	ГруппыГостей.Агент AS Агент,
		|	ISNULL(GuestGroupTotalSales.Продажи, 0) AS Продажи,
		|	GuestGroupTotalSales.Валюта AS Валюта,
		|	GuestGroupTotalSales.Валюта.Code AS CurrencyCode,
		|	GuestGroupTotalSales.Валюта.Description AS CurrencyDescription,
		|	ISNULL(GuestGroupPayments.PaymentAmount, 0) AS PaymentAmount,
		|	GuestGroupPayments.PaymentCurrency AS PaymentCurrency
		|FROM
		|	(SELECT
		|		Бронирование.ГруппаГостей AS ГруппаГостей,
		|		Бронирование.ГруппаГостей.Code AS GuestGroupCode,
		|		Бронирование.ГруппаГостей.Status AS Status,
		|		Бронирование.ГруппаГостей.CheckInDate AS CheckInDate,
		|		Бронирование.ГруппаГостей.Продолжительность AS Продолжительность,
		|		Бронирование.ГруппаГостей.ДатаВыезда AS ДатаВыезда,
		|		Бронирование.ГруппаГостей.ЗаездГостей AS КоличествоЧеловек,
		|		Бронирование.ГруппаГостей.Клиент.FullName AS GuestFullName,
		|		MAX(Бронирование.Телефон) AS Телефон,
		|		MAX(Бронирование.EMail) AS Email,
		|		Бронирование.ГруппаГостей.Description AS Примечания,
		|		Бронирование.Агент.Description AS Агент
		|	FROM
		|		Document.Бронирование AS Бронирование
		|	WHERE
		|		Бронирование.Posted
		|		AND Бронирование.Гостиница = &qHotel
		|		AND Бронирование.Контрагент = &qCustomer
		|		AND Бронирование.Договор = &qContract
		|		AND (Бронирование.ReservationStatus.IsActive
		|				OR Бронирование.ReservationStatus.IsPreliminary)
		|	
		|	GROUP BY
		|		Бронирование.ГруппаГостей,
		|		Бронирование.ГруппаГостей.Status,
		|		Бронирование.ГруппаГостей.CheckInDate,
		|		Бронирование.ГруппаГостей.Продолжительность,
		|		Бронирование.ГруппаГостей.ДатаВыезда,
		|		Бронирование.ГруппаГостей.ЗаездГостей,
		|		Бронирование.ГруппаГостей.Клиент.FullName,
		|		Бронирование.ГруппаГостей.Description,
		|		Бронирование.Агент.Description,
		|		Бронирование.ГруппаГостей.Code) AS ГруппыГостей
		|		LEFT JOIN (SELECT
		|			GuestGroupSales.ГруппаГостей AS ГруппаГостей,
		|			GuestGroupSales.Валюта AS Валюта,
		|			SUM(GuestGroupSales.SalesTurnover) + SUM(GuestGroupSales.SalesForecastTurnover) AS Продажи
		|		FROM
		|			(SELECT
		|				CurrentAccountsReceivableTurnovers.ГруппаГостей AS ГруппаГостей,
		|				CurrentAccountsReceivableTurnovers.ВалютаЛицСчета AS Валюта,
		|				CurrentAccountsReceivableTurnovers.SumReceipt - CurrentAccountsReceivableTurnovers.CommissionSumReceipt AS SalesTurnover,
		|				0 AS SalesForecastTurnover
		|			FROM
		|				AccumulationRegister.РелизацияТекОтчетПериод.Turnovers(
		|						,
		|						,
		|						Period,
		|						Контрагент = &qCustomer
		|							AND Договор = &qContract
		|							AND Гостиница = &qHotel) AS CurrentAccountsReceivableTurnovers
		|			
		|			UNION ALL
		|			
		|			SELECT
		|				AccountsReceivableForecastTurnovers.ГруппаГостей,
		|				AccountsReceivableForecastTurnovers.ВалютаЛицСчета,
		|				0,
		|				AccountsReceivableForecastTurnovers.SalesTurnover - AccountsReceivableForecastTurnovers.CommissionSumTurnover
		|			FROM
		|				AccumulationRegister.ПрогнозРеализации.Turnovers(
		|						,
		|						,
		|						Period,
		|						Контрагент = &qCustomer
		|							AND Договор = &qContract
		|							AND Гостиница = &qHotel) AS AccountsReceivableForecastTurnovers) AS GuestGroupSales
		|		
		|		GROUP BY
		|			GuestGroupSales.ГруппаГостей,
		|			GuestGroupSales.Валюта) AS GuestGroupTotalSales
		|		ON ГруппыГостей.ГруппаГостей = GuestGroupTotalSales.ГруппаГостей
		|		LEFT JOIN (SELECT
		|			Платежи.ГруппаГостей AS ГруппаГостей,
		|			Платежи.ВалютаРасчетов AS PaymentCurrency,
		|			SUM(Платежи.SumExpense) AS PaymentAmount
		|		FROM
		|			AccumulationRegister.ВзаиморасчетыКонтрагенты.BalanceAndTurnovers(
		|					,
		|					,
		|					Period,
		|					RegisterRecordsAndPeriodBoundaries,
		|					Контрагент = &qCustomer
		|						AND Договор = &qContract
		|						AND Гостиница = &qHotel) AS Платежи
		|		
		|		GROUP BY
		|			Платежи.ГруппаГостей,
		|			Платежи.ВалютаРасчетов) AS GuestGroupPayments
		|		ON ГруппыГостей.ГруппаГостей = GuestGroupPayments.ГруппаГостей
		|
		|ORDER BY
		|	ГруппыГостей.CheckInDate,
		|	ГруппыГостей.GuestGroupCode";
		vQry.SetParameter("qHotel", vHotel);
		vQry.SetParameter("qCustomer", vCustomerStruct.Контрагент);
		vQry.SetParameter("qContract", vCustomerStruct.Договор);
		vGuestGroups = vQry.Execute().Unload();
		For Each vGuestGroupsRow In vGuestGroups Do
			// Build return object
			vGuestGroupDetails = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GuestGroupDetails"));
			// Get guest group object
			vGuestGroupObj = vGuestGroupsRow.GuestGroup.GetObject();
			// Fill XDTO object attributes
			vGuestGroupDetails.ГруппаГостей = Format(vGuestGroupObj.Code, "ND=12; NFD=0; NZ=; NG=");
			vGuestGroupDetails.Контрагент = СокрЛП(vCustomer.Description);
			vGuestGroupDetails.Договор = СокрЛП(vContract.Description);
			vGuestGroupDetails.Агент = СокрЛП(vGuestGroupsRow.Agent);
			If ЗначениеЗаполнено(vGuestGroupsRow.Status) Тогда
				vGuestGroupDetails.Status = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "СтатусБрони", vGuestGroupsRow.Status);
				vGuestGroupDetails.StatusCode = СокрЛП(vGuestGroupsRow.Status.Code);
				vGuestGroupDetails.StatusDescription = СокрЛП(vGuestGroupsRow.Status.Description);
			Else
				vGuestGroupDetails.Status = "";
				vGuestGroupDetails.StatusCode = "";
				vGuestGroupDetails.StatusDescription = "";
			EndIf;
			vGuestGroupDetails.CheckInDate = vGuestGroupsRow.CheckInDate;
			vGuestGroupDetails.Продолжительность = vGuestGroupsRow.Duration;
			vGuestGroupDetails.ДатаВыезда = vGuestGroupsRow.CheckOutDate;
			vGuestGroupDetails.КоличествоЧеловек = vGuestGroupsRow.NumberOfPersons;
			vGuestGroupDetails.GuestFullName = СокрЛП(vGuestGroupsRow.GuestFullName);
			vGuestGroupDetails.Телефон = СокрЛП(vGuestGroupsRow.Phone);
			vGuestGroupDetails.Email = СокрЛП(vGuestGroupsRow.Email);
			vGuestGroupDetails.Примечания = Left(vGuestGroupsRow.Remarks, 2048);
			vGuestGroupDetails.Amount = vGuestGroupsRow.Sales;
			vGuestGroupDetails.Balance = vGuestGroupsRow.Sales - vGuestGroupsRow.PaymentAmount;
			If vGuestGroupsRow.Sales <> 0 And ЗначениеЗаполнено(vGuestGroupsRow.Currency) Тогда
				vGuestGroupDetails.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vGuestGroupsRow.Currency);
				vGuestGroupDetails.CurrencyCode = СокрЛП(vGuestGroupsRow.CurrencyCode);
				vGuestGroupDetails.CurrencyDescription = СокрЛП(vGuestGroupsRow.CurrencyDescription);
				vGuestGroupDetails.PaymentPercent = Round(vGuestGroupsRow.PaymentAmount/vGuestGroupsRow.Sales*100, 0);
			Else
				vGuestGroupDetails.Валюта = "";
				vGuestGroupDetails.CurrencyCode = "";
				vGuestGroupDetails.CurrencyDescription = "";
				vGuestGroupDetails.PaymentPercent = 0;
			EndIf;
			// Add guest group to the return object
			vRetXDTO.GuestGroupDetails.Add(vGuestGroupDetails);
		EndDo;
	EndIf;	
	Return vRetXDTO;
EndFunction //cmGetActiveGroupsList 

//-----------------------------------------------------------------------------
// Description: Returns list of hotels available in database
// Parameters: External system code, Language code
// Return value: Гостиница list XDTO object
//-----------------------------------------------------------------------------
Function cmGetHotelsList(pExternalSystemCode, pLanguageCode) Экспорт
	// Run query to get hotels
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Гостиницы.Ref,
	|	Гостиницы.Code,
	|	Гостиницы.Description,
	|	Гостиницы.Language.Code AS LanguageCode
	|FROM
	|	Catalog.Гостиницы AS Hotels
	|WHERE
	|	NOT Гостиницы.IsFolder
	|	AND NOT Гостиницы.DeletionMark";
	vHotels = vQry.Execute().Unload();
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "Гостиницы"));
	For each vHotel in vHotels Do
		vRetXDTO.HotelParameters.Add(cmGetHotelParameters(vHotel.Code, pExternalSystemCode, pLanguageCode, "XDTO"));
	EndDo;
	Return vRetXDTO;
EndFunction //cmGetHotelsList

//-----------------------------------------------------------------------------
// Description: Returns list of ГруппаНомеров rates available for online booking
// Parameters: None
// Return value: Value list with ГруппаНомеров rate items value list
//-----------------------------------------------------------------------------
Function cmGetOnlineRoomRates(pHotel) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Тарифы.Ref AS Тариф
	|FROM
	|	Catalog.Тарифы AS Тарифы
	|WHERE
	|	(Тарифы.Гостиница = &qHotel
	|			OR Тарифы.Гостиница = &qEmptyHotel)
	|	AND NOT Тарифы.IsFolder
	|	AND NOT Тарифы.DeletionMark
	|	AND Тарифы.IsOnlineRate
	|
	|ORDER BY
	|	Тарифы.ПорядокСортировки";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vRoomRates = vQry.Execute().Unload();
	vRoomRatesArray = vRoomRates.UnloadColumn("Тариф");
	vRoomRatesList = New СписокЗначений();
	If vRoomRatesArray.Count() > 0 Тогда
		vRoomRatesList.LoadValues(vRoomRatesArray);
	EndIf;
	Return vRoomRatesList;
EndFunction //cmGetOnlineRoomRates

//-----------------------------------------------------------------------------
Function CheckRoomRateRestrictions(pHotel, pRoomRate, pRoomType, pCheckInDate, pCheckOutDate, pDuration, pWithoutOnline = False)
	vDayOfWeek = WeekDay(pCheckInDate);
	vCheckOutDayOfWeek = WeekDay(pCheckOutDate);
	vCalendarDayType = cmGetCalendarDayType(pRoomRate, pCheckInDate, pCheckInDate, pCheckOutDate);
	vResult = True;
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	RoomRateRestrictions.MLOS AS MLOS,
	|	RoomRateRestrictions.MaxLOS AS MaxLOS,
	|	RoomRateRestrictions.MinDaysBeforeCheckIn AS MinDaysBeforeCheckIn,
	|	RoomRateRestrictions.MaxDaysBeforeCheckIn AS MaxDaysBeforeCheckIn,
	|	RoomRateRestrictions.CTA AS CTA,
	|	RoomRateRestrictions.CTD AS CTD,
	|	RoomRateRestrictions.ТипДеньКалендарь AS ТипДеньКалендарь
	|FROM
	|	InformationRegister.RoomRateRestrictions AS RoomRateRestrictions
	|WHERE
	|	RoomRateRestrictions.Гостиница = &qHotel
	|	AND RoomRateRestrictions.Тариф = &qRoomRate
	|	AND (RoomRateRestrictions.ТипНомера = &qRoomType
	|			OR RoomRateRestrictions.ТипНомера = &qEmptyRoomType)
	|	AND (RoomRateRestrictions.УчетнаяДата = &qAccountingDate
	|			OR RoomRateRestrictions.УчетнаяДата = &qCheckOutAccountingDate
	|				AND RoomRateRestrictions.CTD
	|			OR RoomRateRestrictions.УчетнаяДата = &qEmptyDate
	|				AND RoomRateRestrictions.DayOfWeek = &qDayOfWeek
	|				AND RoomRateRestrictions.ТипДеньКалендарь = &qCalendarDayType
	|			OR RoomRateRestrictions.УчетнаяДата = &qEmptyDate
	|				AND RoomRateRestrictions.DayOfWeek = &qCheckOutDayOfWeek
	|				AND RoomRateRestrictions.ТипДеньКалендарь = &qCalendarDayType
	|				AND RoomRateRestrictions.CTD
	|			OR RoomRateRestrictions.УчетнаяДата = &qEmptyDate
	|				AND RoomRateRestrictions.DayOfWeek = &qDayOfWeek
	|				AND RoomRateRestrictions.ТипДеньКалендарь = &qEmptyCalendarDayType
	|			OR RoomRateRestrictions.УчетнаяДата = &qEmptyDate
	|				AND RoomRateRestrictions.DayOfWeek = &qCheckOutDayOfWeek
	|				AND RoomRateRestrictions.ТипДеньКалендарь = &qEmptyCalendarDayType
	|				AND RoomRateRestrictions.CTD
	|			OR RoomRateRestrictions.УчетнаяДата = &qEmptyDate
	|				AND RoomRateRestrictions.DayOfWeek = 0
	|				AND RoomRateRestrictions.ТипДеньКалендарь = &qEmptyCalendarDayType)
	|	AND (RoomRateRestrictions.MLOS > 0
	|				AND RoomRateRestrictions.MLOS > &qDuration
	|			OR RoomRateRestrictions.MaxLOS > 0
	|				AND RoomRateRestrictions.MaxLOS < &qDuration
	|			OR RoomRateRestrictions.MinDaysBeforeCheckIn > 0
	|				AND RoomRateRestrictions.MinDaysBeforeCheckIn > &qDaysBeforeCheckIn
	|			OR RoomRateRestrictions.MaxDaysBeforeCheckIn > 0
	|				AND RoomRateRestrictions.MaxDaysBeforeCheckIn < &qDaysBeforeCheckIn
	|			OR RoomRateRestrictions.CTA
	|			OR RoomRateRestrictions.CTD)
	|	AND (NOT &qWithoutOnline
	|			OR &qWithoutOnline
	|				AND NOT RoomRateRestrictions.IsForOnlineOnly)";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomRate", pRoomRate);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qEmptyRoomType", Справочники.ТипыНомеров.EmptyRef());
	vQry.SetParameter("qDayOfWeek", vDayOfWeek);
	vQry.SetParameter("qCheckOutDayOfWeek", vCheckOutDayOfWeek);
	vQry.SetParameter("qDuration", pDuration);
	vDaysBeforeCheckIn = Int((BegOfDay(pCheckInDate) - BegOfDay(CurrentDate()))/(24*3600));
	vQry.SetParameter("qDaysBeforeCheckIn", vDaysBeforeCheckIn);
	vQry.SetParameter("qCalendarDayType", vCalendarDayType);
	vQry.SetParameter("qEmptyCalendarDayType", Справочники.ТипДневногоКалендаря.EmptyRef());
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qAccountingDate", BegOfDay(pCheckInDate));
	vQry.SetParameter("qCheckOutAccountingDate", BegOfDay(pCheckOutDate));
	vQry.SetParameter("qWithoutOnline", pWithoutOnline);
	vQryResult = vQry.Execute().Unload();
	If vQryResult.Count() > 0 Тогда
		vResult = False;
	EndIf;		
	Return vResult;
EndFunction //CheckRoomRateRestrictions

//-----------------------------------------------------------------------------
// Checks if it is possible to use cached prices for calculations
//-----------------------------------------------------------------------------
Function cmRoomRatePricesCacheIsFilled(pHotel, pRoomRates, pClientType, pPeriodFrom, pPeriodTo) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomRateDailyPrices.Гостиница,
	|	RoomRateDailyPrices.Тариф,
	|	RoomRateDailyPrices.ТипКлиента,
	|	ISNULL(MIN(RoomRateDailyPrices.Period), &qEmptyDate) AS MinPeriod,
	|	ISNULL(MAX(RoomRateDailyPrices.Period), &qEmptyDate) AS MaxPeriod
	|FROM
	|	InformationRegister.RoomRateDailyPrices AS RoomRateDailyPrices
	|WHERE
	|	RoomRateDailyPrices.Гостиница = &qHotel
	|	AND RoomRateDailyPrices.Тариф IN (&qRoomRates)
	|	AND RoomRateDailyPrices.ТипКлиента = &qClientType
	|	AND RoomRateDailyPrices.Period >= &qPeriodFrom
	|	AND RoomRateDailyPrices.Period <= &qPeriodTo
	|
	|GROUP BY
	|	RoomRateDailyPrices.Гостиница,
	|	RoomRateDailyPrices.Тариф,
	|	RoomRateDailyPrices.ТипКлиента
	|
	|ORDER BY
	|	RoomRateDailyPrices.Гостиница.Code,
	|	RoomRateDailyPrices.Тариф.ПорядокСортировки,
	|	RoomRateDailyPrices.Тариф.Description,
	|	RoomRateDailyPrices.ТипКлиента.ПорядокСортировки,
	|	RoomRateDailyPrices.ТипКлиента.Description";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qClientType", pClientType);
	vQry.SetParameter("qRoomRates", pRoomRates);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQryRes = vQry.Execute().Unload();
	For Each vRoomRateItem In pRoomRates Do
		vRoomRateRow = vQryRes.Find(vRoomRateItem.Value, "Тариф");
		If vRoomRateRow = Неопределено Тогда
			Return False;
		Else
			If BegOfDay(pPeriodFrom) <> BegOfDay(vRoomRateRow.MinPeriod) Or BegOfDay(pPeriodTo) <> BegOfDay(vRoomRateRow.MaxPeriod) Тогда
				Return False;
			EndIf;
		EndIf;
	EndDo;
	Return True;
EndFunction //cmRoomRatePricesCacheIsFilled

//-----------------------------------------------------------------------------
// Description: Returns list of ГруппаНомеров type balances
//-----------------------------------------------------------------------------
Function cmGetAvailableRoomTypes(pHotelCode, pRoomRateCode, pClientTypeCode, pRoomTypeCode, pRoomQuotaCode, pPeriodFrom, pPeriodTo, pExternalSystemCode, pLanguageCode = "RU", pGuestsQuantity, pEMail, pPhone, pLogin, pPromoCode, pOutputType = "XDTO") Экспорт
	WriteLogEvent(NStr("en='Get available ГруппаНомеров types';ru='Получить остатки свободных номеров';de='Restbestände an freien Zimmern erhalten'"), EventLogLevel.Information, , , 
				  NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
				  NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
				  NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
				  NStr("en='ГруппаНомеров rate code: ';ru='Код тарифа: ';de='Tarifcode: '") + pRoomRateCode + Chars.LF + 
				  NStr("en='Client type code: ';ru='Код типа клиента: ';de='Kundentypcode: '") + pClientTypeCode + Chars.LF + 
				  NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + pRoomTypeCode + Chars.LF + 
				  NStr("en='Allotment code: ';ru='Код квоты: ';de='Quotencode: '") + pRoomQuotaCode + Chars.LF + 
				  NStr("en='Guest quantity: '; ru='Количество гостей: '") + pGuestsQuantity + Chars.LF + 
				  NStr("en='E-Mail: '; ru='E-Mail: '") + pEMail + Chars.LF + 
				  NStr("en='Phone number: ';ru='Номер телефона: ';de='Telefonnummer: '") + pPhone + Chars.LF + 
				  NStr("en='Login: ';ru='Логин: ';de='Login: '") + pLogin + Chars.LF + 
				  NStr("en='Promotion code: ';ru='Промо код: ';de='Promo Code: '") + pPromoCode + Chars.LF +
				  NStr("en='Period from: ';ru='Начало периода: ';de='Zeitraumbeginn: '") + pPeriodFrom + Chars.LF + 
				  NStr("en='Period to: ';ru='Конец периода: ';de='Zeitraumende: '") + pPeriodTo);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Retrieve parameter references based on codes
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	vExtHotelCode = cmGetObjectExternalSystemCodeByRef(Справочники.Гостиницы.EmptyRef(), pExternalSystemCode, "Hotels", vHotel);
	vRoomRates = New СписокЗначений();
	vRoomRate = Справочники.Тарифы.EmptyRef();
	If IsBlankString(pRoomRateCode) Тогда
		vRoomRates = cmGetOnlineRoomRates(vHotel);
		If vRoomRates.Count() = 0 Тогда
			If ЗначениеЗаполнено(vHotel) Тогда
				vRoomRate = vHotel.Тариф;
				If ЗначениеЗаполнено(vRoomRate) Тогда
					vRoomRates.Add(vRoomRate);
				EndIf;
			EndIf;
		EndIf;
	Else
		vRoomRate = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Тарифы", pRoomRateCode);
		If ЗначениеЗаполнено(vRoomRate) Тогда
			vRoomRates.Add(vRoomRate);
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(vRoomRate) And vRoomRates.Count() = 0 Тогда
		If ЗначениеЗаполнено(vHotel) Тогда
			vRoomRate = vHotel.Тариф;
			If ЗначениеЗаполнено(vRoomRate) Тогда
				vRoomRates.Add(vRoomRate);
			EndIf;
		EndIf;
	EndIf;
	vClientType = Справочники.ТипыКлиентов.EmptyRef();
	If НЕ IsBlankString(pClientTypeCode) Тогда
		vClientType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыКлиентов", pClientTypeCode);
	EndIf;
	vRoomType = Справочники.ТипыНомеров.EmptyRef();
	If НЕ IsBlankString(pRoomTypeCode) Тогда
		vRoomType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыНомеров", pRoomTypeCode);
	EndIf;
	vRoomQuota = Справочники.КвотаНомеров.EmptyRef();
	If НЕ IsBlankString(pRoomQuotaCode) Тогда
		vRoomQuota = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "КвотаНомеров", pRoomQuotaCode);
	EndIf;
	//vClient = Неопределено;
	If НЕ IsBlankString(pPhone) Тогда
		//vClient = Справочники.Клиенты.FindByAttribute("Телефон", СокрЛП(pPhone));
	ElsIf НЕ IsBlankString(pEMail) Тогда
		//vClient = Справочники.Клиенты.FindByAttribute("EMail", СокрЛП(pEMail));
	EndIf;
	If НЕ IsBlankString(pPromoCode) Тогда
		vPromoDiscountType = Неопределено;
		// Try to find discount card by promo code
		vPromoDiscountCard = Справочники.ДисконтныеКарты.FindByAttribute("Identifier", СокрЛП(pPromoCode));
		If ЗначениеЗаполнено(vPromoDiscountCard) And НЕ vPromoDiscountCard.DeletionMark And vPromoDiscountCard.ValidFrom < pPeriodTo And (vPromoDiscountCard.ValidTo = '00010101' Or vPromoDiscountCard.ValidTo > pPeriodFrom) Тогда
			vPromoDiscountType = vPromoDiscountCard.ТипСкидки;
		EndIf;
		If НЕ ЗначениеЗаполнено(vPromoDiscountType) Тогда
			vPromoDiscountType = Справочники.ТипыСкидок.FindByCode(СокрЛП(pPromoCode));
		EndIf;
		If ЗначениеЗаполнено(vPromoDiscountType) And НЕ vPromoDiscountType.DeletionMark And НЕ vPromoDiscountType.IsFolder Тогда
			vDiscountTypeIsActive = True;
			If ЗначениеЗаполнено(vPromoDiscountType.DateValidFrom) And pPeriodFrom < BegOfDay(vPromoDiscountType.DateValidFrom) Тогда
				vDiscountTypeIsActive = False;
			ElsIf ЗначениеЗаполнено(vPromoDiscountType.DateValidTo) And pPeriodTo > EndOfDay(vPromoDiscountType.DateValidTo) Тогда
				vDiscountTypeIsActive = False;
			EndIf;
			If vDiscountTypeIsActive Тогда
				vDiscountType = vPromoDiscountType;
			EndIf;
		EndIf;
	EndIf;
	vCustomer = Неопределено;
	vContract = Неопределено;
	If НЕ IsBlankString(pLogin) Тогда
		vCustomerStruct = cmGetCustomerByLogin(vHotel, pExternalSystemCode, pLogin);
		If vCustomerStruct <> Неопределено Тогда
			If ЗначениеЗаполнено(vCustomerStruct.Договор) And НЕ vCustomerStruct.Договор.DeletionMark Тогда
				If ЗначениеЗаполнено(vCustomerStruct.Контрагент) And НЕ vCustomerStruct.Контрагент.DeletionMark Тогда
					vCustomer = vCustomerStruct.Контрагент;
					vContract = vCustomerStruct.Договор;
					If ЗначениеЗаполнено(vCustomer) And НЕ ЗначениеЗаполнено(vContract) And ЗначениеЗаполнено(vCustomer.ВидКомиссииАгента) Тогда
						// ГруппаНомеров rate
						If vCustomer.Тарифы.Count() > 0 Тогда
							vRoomRates.LoadValues(vCustomer.Тарифы.UnloadColumn("Тариф"));
							If ЗначениеЗаполнено(vCustomer.Тариф) Тогда
								vRoomRate = vCustomer.Тариф;
								vFindedRR = vRoomRates.FindByValue(vRoomRate);
								If vFindedRR = Неопределено Тогда
									vRoomRates.Add(vRoomRate);
								EndIf;
							EndIf;
						EndIf;
						// Client type
						If ЗначениеЗаполнено(vCustomer.ТипКлиента) Тогда
							vClientType = vCustomer.ТипКлиента;
						EndIf;
					ElsIf ЗначениеЗаполнено(vContract) And ЗначениеЗаполнено(vContract.ВидКомиссииАгента) Тогда
						// ГруппаНомеров rate
						If vContract.Тарифы.Count() > 0 Тогда
							vRoomRates.LoadValues(vContract.Тарифы.UnloadColumn("Тариф"));
							If ЗначениеЗаполнено(vContract.Тариф) Тогда
								vRoomRate = vContract.Тариф;
								vFindedRR = vRoomRates.FindByValue(vRoomRate);
								If vFindedRR = Неопределено Тогда
									vRoomRates.Add(vRoomRate);
								EndIf;
							EndIf;
						EndIf;
						// Client type
						If ЗначениеЗаполнено(vContract.ТипКлиента) Тогда
							vClientType = vContract.ТипКлиента;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	
	// Retrieve reservation conditions
	vPaymentMethodCodesAllowedOnline = "";
	vReservationConditionsShort = "";
	vReservationConditionsOnline = "";
	vReservationConditions = "* Для аннулирования брони известите отдел бронирования до 18:00 дня предшествующего дате заезда
		|* Возможность поселения ранее указанного времени должна быть согласована с отделом бронирования";
	If ЗначениеЗаполнено(vHotel) And НЕ IsBlankString(vHotel.ReservationConditions) Тогда
		vReservationConditions = vHotel.ReservationConditions;
	EndIf;
	If ЗначениеЗаполнено(vRoomRate) And НЕ IsBlankString(vRoomRate.ReservationConditions) And НЕ IsBlankString(pRoomRateCode) Тогда
		vReservationConditions = vRoomRate.ReservationConditions;
		vReservationConditionsShort = vRoomRate.ReservationConditionsShort;
		vReservationConditionsOnline = vRoomRate.ReservationConditionsOnline;
		vPaymentMethodCodesAllowedOnline = СокрЛП(vRoomRate.PaymentMethodCodesAllowedOnline);
	EndIf;
	vReservationConditions = Left(vReservationConditions, 2048);
	vReservationConditionsShort = Left(vReservationConditionsShort, 2048);
	vReservationConditionsOnline = Left(vReservationConditionsOnline, 2048);
	vPaymentMethodCodesAllowedOnline = Left(vPaymentMethodCodesAllowedOnline, 2048);
	
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chot7el.ru/interfaces/reservation/", "AvailableRoomTypes"));
	vRetXDTO.ReservationConditions = vReservationConditions;
	vRetXDTO.ReservationConditionsShort = vReservationConditionsShort;
	vRetXDTO.ReservationConditionsOnline = vReservationConditionsOnline;
	vRetXDTO.PaymentMethodCodesAllowedOnline = vPaymentMethodCodesAllowedOnline;
	
	// Get accommodation types list with ages
	vAdultsQuantity = pGuestsQuantity.Adults.Количество;
	vKidsQuantity = pGuestsQuantity.Kids.Количество;
	vGuestsQuantity = vAdultsQuantity + vKidsQuantity;
	vAgeArray = New Array();
	Try
		For Each vAge In pGuestsQuantity.Kids.Age Do
			vAgeArray.Add(vAge);
		EndDo;
	Except
	EndTry;
	
	// Get available ГруппаНомеров types
	vRoomTypesByGQ = cmGetRoomTypesByGuestQuantity(vGuestsQuantity, vRoomType, vHotel);
	
	// Run query to retrieve available rooms/beds 
	vRoomTypes = cmGetRoomTypesWithBalances(vHotel, vRoomTypesByGQ.UnloadColumn("ТипНомера"), vRoomQuota, pPeriodFrom, pPeriodTo);
	
	// Remove stop sale periods from the list of prices
	cmRemoveStopSalePeriods(vRoomTypes, pPeriodFrom, pPeriodTo);
	
	// Sort ГруппаНомеров types list
	vRoomTypes.Sort("HotelSortCode, RoomTypeSortCode");
	
	vRetAccTypesRows = Неопределено;
	vRetAccTypesList = Неопределено;
	vAvailableRoomTypesRows = Неопределено;
	vAvailableRoomTypesByCheckInPeriodsRows = Неопределено;
	vNoAgent = True; // If we have at least one quota with this Контрагент\agent\contract - vNoAgent = False else True
	
	// Get check-in periods for the first ГруппаНомеров rate in the list of ГруппаНомеров rates
	If vRoomRates.Count() > 0 Тогда
		For Each vRoomRateItem In vRoomRates Do
			vRoomRate = vRoomRateItem.Value;
			// Check ГруппаНомеров rate is valid period
			If ЗначениеЗаполнено(vRoomRate.DateValidFrom) Or ЗначениеЗаполнено(vRoomRate.DateValidTo) Тогда
				If ЗначениеЗаполнено(vRoomRate.DateValidFrom) And pPeriodFrom < vRoomRate.DateValidFrom Тогда
					Continue;
				EndIf;
				If ЗначениеЗаполнено(vRoomRate.DateValidTo) And pPeriodTo > EndOfDay(vRoomRate.DateValidTo) Тогда
					Continue;
				EndIf;
			EndIf;
			Break;
		EndDo;

		// Call API to get value table with balances
		vAgent = Справочники.Контрагенты.EmptyRef();
		If ЗначениеЗаполнено(vCustomer) And ЗначениеЗаполнено(vCustomer.ВидКомиссииАгента) Тогда
			vAgent = vCustomer;
		EndIf;
		If ЗначениеЗаполнено(vCustomer) Or ЗначениеЗаполнено(vContract) Or ЗначениеЗаполнено(vAgent) Тогда
			vNoAgent = False;
			vQry = New Query();
			vQry.Text = 
			"SELECT 
			|	КвотаНомеров.Ref AS Ref
			|FROM
			|	Catalog.КвотаНомеров AS КвотаНомеров
			|WHERE
			|	НЕ КвотаНомеров.DeletionMark 
			|	AND НЕ КвотаНомеров.IsFolder
			|	AND (КвотаНомеров.Агент IN HIERARCHY (&qAgent))
			|	AND (КвотаНомеров.Контрагент IN HIERARCHY (&qCustomer))
			|	AND (КвотаНомеров.Договор = &qContract)";
			vQry.SetParameter("qCustomer", vCustomer);
			vQry.SetParameter("qContract", vContract);
			vQry.SetParameter("qAgent", vAgent);
			vResult = vQry.Execute().Unload();
			If vResult.Count() = 0 Тогда
				vNoAgent = True;
			EndIf;
		EndIf;

		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	CheckInPeriods.Гостиница AS Гостиница,
		|	CheckInPeriods.Тариф AS Тариф,
		|	CheckInPeriods.CheckInDate AS CheckInDate,
		|	CheckInPeriods.Продолжительность AS Продолжительность,
		|	CheckInPeriods.ДатаВыезда AS ДатаВыезда,
		|	CASE
		|		WHEN BEGINOFPERIOD(CheckInPeriods.ДатаВыезда, DAY) = &qBegOfPeriodTo
		|				AND BEGINOFPERIOD(CheckInPeriods.CheckInDate, DAY) = &qPeriodFromBegOfDay
		|			THEN 1
		|		ELSE CASE
		|				WHEN BEGINOFPERIOD(CheckInPeriods.ДатаВыезда, DAY) <> &qBegOfPeriodTo
		|						AND BEGINOFPERIOD(CheckInPeriods.CheckInDate, DAY) = &qPeriodFromBegOfDay
		|					THEN 2
		|				ELSE 3
		|			END
		|	END AS ПорядокСортировки,
		|	CheckInPeriods.КвотаНомеров AS Allotment,
		|	MIN(CheckInPeriods.ОстаетсяНомеров) AS ОстаетсяНомеров,
		|	MIN(CheckInPeriods.ОстаетсяМест) AS ОстаетсяМест,
		|	CheckInPeriods.ТипНомера AS ТипНомера
		|INTO CheckInPeriods
		|FROM
		|	(SELECT
		|		CheckInPeriods2.Гостиница AS Гостиница,
		|		CheckInPeriods2.Тариф AS Тариф,
		|		CheckInPeriods2.CheckInDate AS CheckInDate,
		|		CheckInPeriods2.Продолжительность AS Продолжительность,
		|		CheckInPeriods2.ДатаВыезда AS ДатаВыезда,
		|		CheckInPeriods2.КвотаНомеров AS КвотаНомеров,
		|		RoomQuotaBalances.ТипНомера AS ТипНомера,
		|		MIN(ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)) AS ОстаетсяНомеров,
		|		MIN(ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)) AS ОстаетсяМест
		|	FROM
		|		InformationRegister.RoomQuotaCheckInPeriods AS CheckInPeriods2
		|			LEFT JOIN (SELECT
		|				RoomQuotaSalesBalanceAndTurnovers.Period AS Period,
		|				RoomQuotaSalesBalanceAndTurnovers.Гостиница AS RoomQuotaSalesBalanceHotel,
		|				RoomQuotaSalesBalanceAndTurnovers.КвотаНомеров AS RoomQuotaSalesBalanceRoomQuota,
		|				MIN(RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance) AS ОстаетсяНомеров,
		|				MIN(RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance) AS ОстаетсяМест,
		|				MIN(RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance) AS СчетчикДокКвота,
		|				RoomQuotaSalesBalanceAndTurnovers.ТипНомера AS ТипНомера
		|			FROM
		|				AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
		|						DATEADD(&qPeriodFrom, DAY, -3),
		|						&qBegOfPeriodTo,
		|						DAY,
		|						RegisterRecordsAndPeriodBoundaries,
		|						(Гостиница IN HIERARCHY (&qHotel)
		|							OR &qHotelIsEmpty)
		|							AND (КвотаНомеров.Агент IN HIERARCHY (&qAgent)
		|								OR &qAgentIsEmpty)
		|							AND (КвотаНомеров.Контрагент IN HIERARCHY (&qCustomer)
		|								OR &qCustomerIsEmpty)
		|							AND (КвотаНомеров.Договор = &qContract
		|								OR &qContractIsEmpty)) AS RoomQuotaSalesBalanceAndTurnovers
		|			
		|			GROUP BY
		|				RoomQuotaSalesBalanceAndTurnovers.Гостиница,
		|				RoomQuotaSalesBalanceAndTurnovers.КвотаНомеров,
		|				RoomQuotaSalesBalanceAndTurnovers.ТипНомера,
		|				RoomQuotaSalesBalanceAndTurnovers.Period) AS RoomQuotaBalances
		|			ON (RoomQuotaBalances.RoomQuotaSalesBalanceHotel = CheckInPeriods2.Гостиница)
		|				AND (RoomQuotaBalances.RoomQuotaSalesBalanceRoomQuota = CheckInPeriods2.КвотаНомеров)
		|				AND (RoomQuotaBalances.Period >= BEGINOFPERIOD(CheckInPeriods2.CheckInDate, DAY))
		|				AND (RoomQuotaBalances.Period < BEGINOFPERIOD(CheckInPeriods2.ДатаВыезда, DAY))
		|	WHERE
		|		NOT CheckInPeriods2.IsNotActive
		|		AND CheckInPeriods2.Продолжительность > 0
		|		AND CheckInPeriods2.КвотаНомеров <> &qEmptyRoomQuota
		|		AND (CheckInPeriods2.Гостиница IN HIERARCHY (&qHotel)
		|				OR &qHotelIsEmpty)
		|		AND CheckInPeriods2.CheckInDate >= DATEADD(&qPeriodFromBegOfDay, DAY, -3)
		|		AND CheckInPeriods2.CheckInDate <= DATEADD(ENDOFPERIOD(&qPeriodTo, DAY), DAY, 3)
		|		AND CheckInPeriods2.ДатаВыезда <= DATEADD(ENDOFPERIOD(&qPeriodTo, DAY), DAY, 3)
		|		AND RoomQuotaBalances.ТипНомера.КоличествоГостейНомер >= &qNOP
		|	
		|	GROUP BY
		|		CheckInPeriods2.Гостиница,
		|		CheckInPeriods2.Тариф,
		|		CheckInPeriods2.CheckInDate,
		|		CheckInPeriods2.Продолжительность,
		|		CheckInPeriods2.ДатаВыезда,
		|		CheckInPeriods2.КвотаНомеров,
		|		RoomQuotaBalances.ТипНомера) AS CheckInPeriods
		|
		|GROUP BY
		|	CheckInPeriods.Гостиница,
		|	CheckInPeriods.Тариф,
		|	CheckInPeriods.CheckInDate,
		|	CheckInPeriods.Продолжительность,
		|	CheckInPeriods.ДатаВыезда,
		|	CASE
		|		WHEN BEGINOFPERIOD(CheckInPeriods.ДатаВыезда, DAY) = &qBegOfPeriodTo
		|				AND BEGINOFPERIOD(CheckInPeriods.CheckInDate, DAY) = &qPeriodFromBegOfDay
		|			THEN 1
		|		ELSE CASE
		|				WHEN BEGINOFPERIOD(CheckInPeriods.ДатаВыезда, DAY) <> &qBegOfPeriodTo
		|						AND BEGINOFPERIOD(CheckInPeriods.CheckInDate, DAY) = &qPeriodFromBegOfDay
		|					THEN 2
		|				ELSE 3
		|			END
		|	END,
		|	CheckInPeriods.КвотаНомеров,
		|	CheckInPeriods.ТипНомера
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT TOP 50
		|	CASE
		|		WHEN BEGINOFPERIOD(MAX(CheckInPeriods.ДатаВыезда), DAY) = &qBegOfPeriodTo
		|				AND BEGINOFPERIOD(MIN(CheckInPeriods.CheckInDate), DAY) = &qPeriodFromBegOfDay
		|			THEN 1
		|		ELSE 2
		|	END AS ПорядокСортировки,
		|	CASE
		|		WHEN DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration < 0
		|			THEN -(DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration)
		|		ELSE DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration
		|	END + YEAR(MIN(CheckInPeriods.CheckInDate)) + MONTH(MIN(CheckInPeriods.CheckInDate)) + MONTH(MAX(CheckInPeriods.ДатаВыезда)) + DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) * DAY(MIN(CheckInPeriods.CheckInDate)) * DAY(MAX(CheckInPeriods.ДатаВыезда)) AS UUID,
		|	CASE
		|		WHEN DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY) < 0
		|			THEN -DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY)
		|		ELSE DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY)
		|	END + CASE
		|		WHEN DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY) < 0
		|			THEN -DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY)
		|		ELSE DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY)
		|	END AS DifferenceFromTo,
		|	0 AS DifferenceDuration,
		|	CheckInPeriods.Гостиница AS Гостиница,
		|	MIN(CheckInPeriods.CheckInDate) AS CheckInDate,
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) AS Продолжительность,
		|	MAX(CheckInPeriods.ДатаВыезда) AS ДатаВыезда,
		|	CheckInPeriods.ТипНомера AS ТипНомера,
		|	CheckInPeriods.Allotment AS Allotment,
		|	CheckInPeriods.Allotment.Code AS AllotmentCode,
		|	CheckInPeriods.Allotment.Контрагент AS Контрагент,
		|	CheckInPeriods.Allotment.Агент AS Агент,
		|	CheckInPeriods.Allotment.Договор AS Договор,
		|	MIN(CheckInPeriods.ОстаетсяНомеров) AS ОстаетсяНомеров,
		|	MIN(CheckInPeriods.ОстаетсяМест) AS ОстаетсяМест,
		|	CheckInPeriods.Allotment.Тариф AS Тариф,
		|	CheckInPeriods.Allotment.ПорядокСортировки AS AllotmentSortCode,
		|	CheckInPeriods.Гостиница.ПорядокСортировки AS HotelSortCode,
		|	CheckInPeriods.ТипНомера.ПорядокСортировки AS RoomTypeSortCode
		|INTO ResultTable
		|FROM
		|	CheckInPeriods AS CheckInPeriods
		|WHERE
		|	CheckInPeriods.Продолжительность = 1
		|	AND CheckInPeriods.CheckInDate >= &qPeriodFromBegOfDay
		|	AND CheckInPeriods.ДатаВыезда <= ENDOFPERIOD(&qPeriodTo, DAY)
		|
		|GROUP BY
		|	CheckInPeriods.Гостиница,
		|	CheckInPeriods.Гостиница.ПорядокСортировки,
		|	CheckInPeriods.ТипНомера,
		|	CheckInPeriods.ТипНомера.ПорядокСортировки,
		|	CheckInPeriods.Allotment,
		|	CheckInPeriods.Allotment.Code,
		|	CheckInPeriods.Allotment.Контрагент,
		|	CheckInPeriods.Allotment.Агент,
		|	CheckInPeriods.Allotment.Договор,
		|	CheckInPeriods.Allotment.Тариф,
		|	CheckInPeriods.Allotment.ПорядокСортировки
		|
		|HAVING
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) = &qDuration AND
		|	MIN(CheckInPeriods.ОстаетсяНомеров) > 0
		|
		|UNION ALL
		|
		|SELECT TOP 50
		|	CASE
		|		WHEN BEGINOFPERIOD(MAX(CheckInPeriods.ДатаВыезда), DAY) = &qBegOfPeriodTo
		|				AND BEGINOFPERIOD(MIN(CheckInPeriods.CheckInDate), DAY) = &qPeriodFromBegOfDay
		|			THEN 1
		|		ELSE 2
		|	END,
		|	CASE
		|		WHEN DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration < 0
		|			THEN -(DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration)
		|		ELSE DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration
		|	END + YEAR(MIN(CheckInPeriods.CheckInDate)) + MONTH(MIN(CheckInPeriods.CheckInDate)) + MONTH(MAX(CheckInPeriods.ДатаВыезда)) + DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) * DAY(MIN(CheckInPeriods.CheckInDate)) * DAY(MAX(CheckInPeriods.ДатаВыезда)),
		|	CASE
		|		WHEN DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY) < 0
		|			THEN -DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY)
		|		ELSE DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY)
		|	END + CASE
		|		WHEN DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY) < 0
		|			THEN -DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY)
		|		ELSE DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY)
		|	END,
		|	0,
		|	CheckInPeriods.Гостиница,
		|	MIN(CheckInPeriods.CheckInDate),
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY),
		|	MAX(CheckInPeriods.ДатаВыезда),
		|	CheckInPeriods.ТипНомера,
		|	CheckInPeriods.Allotment,
		|	CheckInPeriods.Allotment.Code,
		|	CheckInPeriods.Allotment.Контрагент,
		|	CheckInPeriods.Allotment.Агент,
		|	CheckInPeriods.Allotment.Договор,
		|	MIN(CheckInPeriods.ОстаетсяНомеров),
		|	MIN(CheckInPeriods.ОстаетсяМест),
		|	CheckInPeriods.Allotment.Тариф,
		|	CheckInPeriods.Allotment.ПорядокСортировки,
		|	CheckInPeriods.Гостиница.ПорядокСортировки,
		|	CheckInPeriods.ТипНомера.ПорядокСортировки
		|FROM
		|	CheckInPeriods AS CheckInPeriods
		|
		|GROUP BY
		|	CheckInPeriods.Гостиница,
		|	CheckInPeriods.Гостиница.ПорядокСортировки,
		|	CheckInPeriods.ТипНомера,
		|	CheckInPeriods.ТипНомера.ПорядокСортировки,
		|	CheckInPeriods.Allotment,
		|	CheckInPeriods.Allotment.Code,
		|	CheckInPeriods.Allotment.Контрагент,
		|	CheckInPeriods.Allotment.Агент,
		|	CheckInPeriods.Allotment.Договор,
		|	CheckInPeriods.Allotment.Тариф,
		|	CheckInPeriods.Allotment.ПорядокСортировки
		|
		|HAVING
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) = &qDuration AND
		|	MIN(CheckInPeriods.ОстаетсяНомеров) > 0
		|
		|UNION ALL
		|
		|SELECT TOP 50
		|	2,
		|	CASE
		|		WHEN DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration < 0
		|			THEN -(DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration)
		|		ELSE DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration
		|	END + YEAR(MIN(CheckInPeriods.CheckInDate)) + MONTH(MIN(CheckInPeriods.CheckInDate)) + MONTH(MAX(CheckInPeriods.ДатаВыезда)) + DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) / 2 * DAY(MIN(CheckInPeriods.CheckInDate)) * DAY(MAX(CheckInPeriods.ДатаВыезда)),
		|	CASE
		|		WHEN DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY) < 0
		|			THEN -DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY)
		|		ELSE DATEDIFF(&qPeriodFromBegOfDay, MIN(CheckInPeriods.CheckInDate), DAY)
		|	END + CASE
		|		WHEN DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY) < 0
		|			THEN -DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY)
		|		ELSE DATEDIFF(&qBegOfPeriodTo, MAX(CheckInPeriods.ДатаВыезда), DAY)
		|	END,
		|	CASE
		|		WHEN DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration < 0
		|			THEN -(DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration)
		|		ELSE DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) - &qDuration
		|	END,
		|	CheckInPeriods.Гостиница,
		|	MIN(CheckInPeriods.CheckInDate),
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY),
		|	MAX(CheckInPeriods.ДатаВыезда),
		|	CheckInPeriods.ТипНомера,
		|	CheckInPeriods.Allotment,
		|	CheckInPeriods.Allotment.Code,
		|	CheckInPeriods.Allotment.Контрагент,
		|	CheckInPeriods.Allotment.Агент,
		|	CheckInPeriods.Allotment.Договор,
		|	MIN(CheckInPeriods.ОстаетсяНомеров),
		|	MIN(CheckInPeriods.ОстаетсяМест),
		|	CheckInPeriods.Allotment.Тариф,
		|	CheckInPeriods.Allotment.ПорядокСортировки,
		|	CheckInPeriods.Гостиница.ПорядокСортировки,
		|	CheckInPeriods.ТипНомера.ПорядокСортировки
		|FROM
		|	CheckInPeriods AS CheckInPeriods
		|
		|GROUP BY
		|	CheckInPeriods.Гостиница,
		|	CheckInPeriods.Гостиница.ПорядокСортировки,
		|	CheckInPeriods.ТипНомера,
		|	CheckInPeriods.ТипНомера.ПорядокСортировки,
		|	CheckInPeriods.Allotment,
		|	CheckInPeriods.Allotment.Code,
		|	CheckInPeriods.Allotment.Контрагент,
		|	CheckInPeriods.Allotment.Агент,
		|	CheckInPeriods.Allotment.Договор,
		|	CheckInPeriods.Allotment.Тариф,
		|	CheckInPeriods.Allotment.ПорядокСортировки
		|
		|HAVING
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) >= 0 AND
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) >= &qDuration - 3 AND
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) <= &qDuration + 3 AND
		|	DATEDIFF(MIN(CheckInPeriods.CheckInDate), MAX(CheckInPeriods.ДатаВыезда), DAY) <> &qDuration AND
		|	BEGINOFPERIOD(MIN(CheckInPeriods.CheckInDate), DAY) <> &qPeriodFromBegOfDay AND
		|	BEGINOFPERIOD(MIN(CheckInPeriods.CheckInDate), DAY) >= DATEADD(&qPeriodFromBegOfDay, DAY, -3) AND
		|	BEGINOFPERIOD(MIN(CheckInPeriods.CheckInDate), DAY) <= DATEADD(&qPeriodFromBegOfDay, DAY, 3) AND
		|	MIN(CheckInPeriods.ОстаетсяНомеров) > 0
		|
		|ORDER BY
		|	ПорядокСортировки,
		|	DifferenceDuration,
		|	Продолжительность DESC,
		|	DifferenceFromTo,
		|	HotelSortCode,
		|	CheckInDate,
		|	ДатаВыезда,
		|	AllotmentSortCode,
		|	RoomTypeSortCode
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT TOP 5
		|	MAX(ResultTable.ПорядокСортировки) AS ПорядокСортировки,
		|	MAX(ResultTable.DifferenceFromTo) AS DifferenceFromTo,
		|	MAX(ResultTable.DifferenceDuration) AS DifferenceDuration,
		|	MAX(ResultTable.CheckInDate) AS CheckInDate,
		|	MAX(ResultTable.Продолжительность) AS Продолжительность,
		|	MAX(ResultTable.ДатаВыезда) AS ДатаВыезда,
		|	MAX(ResultTable.AllotmentSortCode) AS AllotmentSortCode,
		|	MAX(ResultTable.HotelSortCode) AS HotelSortCode,
		|	MAX(ResultTable.RoomTypeSortCode) AS RoomTypeSortCode,
		|	ResultTable.UUID AS UUID,
		|	COUNT(ResultTable.UUID) AS UUIDCount
		|INTO RTCount
		|FROM
		|	ResultTable AS ResultTable
		|
		|GROUP BY
		|	ResultTable.UUID
		|
		|ORDER BY
		|	ПорядокСортировки,
		|	DifferenceDuration,
		|	Продолжительность DESC,
		|	DifferenceFromTo,
		|	HotelSortCode,
		|	CheckInDate,
		|	ДатаВыезда,
		|	AllotmentSortCode,
		|	RoomTypeSortCode
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ResultTable.ПорядокСортировки AS ПорядокСортировки,
		|	ResultTable.UUID AS UUID,
		|	ResultTable.DifferenceFromTo AS DifferenceFromTo,
		|	ResultTable.DifferenceDuration AS DifferenceDuration,
		|	ResultTable.Гостиница AS Гостиница,
		|	ResultTable.CheckInDate AS CheckInDate,
		|	ResultTable.Продолжительность AS Продолжительность,
		|	ResultTable.ДатаВыезда AS ДатаВыезда,
		|	ResultTable.ТипНомера AS ТипНомера,
		|	MAX(ResultTable.Allotment) AS Allotment,
		|	ResultTable.Контрагент AS Контрагент,
		|	ResultTable.Агент AS Агент,
		|	ResultTable.Договор AS Договор,
		|	MIN(ResultTable.ОстаетсяНомеров) AS ОстаетсяНомеров,
		|	MIN(ResultTable.ОстаетсяМест) AS ОстаетсяМест,
		|	ResultTable.Тариф AS Тариф,
		|	ResultTable.HotelSortCode AS HotelSortCode,
		|	ResultTable.RoomTypeSortCode AS RoomTypeSortCode
		|FROM
		|	ResultTable AS ResultTable
		|		INNER JOIN RTCount AS RTCount
		|		ON (RTCount.UUID = ResultTable.UUID)
		|WHERE
		|	(ResultTable.Allotment IN HIERARCHY (&qAllotment)
		|			OR &qRoomQuotaIsEmpty)
		|
		|GROUP BY
		|	ResultTable.ПорядокСортировки,
		|	ResultTable.UUID,
		|	ResultTable.DifferenceFromTo,
		|	ResultTable.DifferenceDuration,
		|	ResultTable.Гостиница,
		|	ResultTable.CheckInDate,
		|	ResultTable.Продолжительность,
		|	ResultTable.ДатаВыезда,
		|	ResultTable.ТипНомера,
		|	ResultTable.Контрагент,
		|	ResultTable.Агент,
		|	ResultTable.Договор,
		|	ResultTable.Тариф,
		|	ResultTable.HotelSortCode,
		|	ResultTable.RoomTypeSortCode
		|
		|ORDER BY
		|	ПорядокСортировки,
		|	DifferenceDuration,
		|	Продолжительность DESC,
		|	DifferenceFromTo,
		|	HotelSortCode,
		|	CheckInDate,
		|	ДатаВыезда,
		|	RoomTypeSortCode";
		vQry.SetParameter("qHotel", vHotel);
		vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(vHotel));
		vQry.SetParameter("qAllotment", vRoomQuota);
		vQry.SetParameter("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(vRoomQuota));
		vQry.SetParameter("qEmptyRoomQuota", Справочники.КвотаНомеров.EmptyRef());
		vQry.SetParameter("qPeriodFromBegOfDay", BegOfDay(pPeriodFrom));
		vQry.SetParameter("qPeriodFromEndOfDay", EndOfDay(pPeriodFrom));
		vQry.SetParameter("qPeriodFrom", pPeriodFrom);
		vQry.SetParameter("qPeriodTo", EndOfDay(pPeriodTo));
		vQry.SetParameter("qNOP", vGuestsQuantity);
		vQry.SetParameter("qBegOfPeriodTo", BegOfDay(pPeriodTo));
		If НЕ ЗначениеЗаполнено(vRoomRate) And ЗначениеЗаполнено(vHotel) And ЗначениеЗаполнено(vHotel.Тариф) Тогда
			vRoomRate = vHotel.Тариф;
		EndIf;
		vDuration = cmCalculateDuration(vRoomRate, pPeriodFrom, pPeriodTo);
		vQry.SetParameter("qDuration", vDuration);
		vQry.SetParameter("qCustomer", vCustomer);
		vQry.SetParameter("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(vCustomer) Or vNoAgent);
		vQry.SetParameter("qContract", vContract);
		vQry.SetParameter("qContractIsEmpty", НЕ ЗначениеЗаполнено(vContract) Or vNoAgent);
		vQry.SetParameter("qAgent", vAgent);
		vQry.SetParameter("qAgentIsEmpty", НЕ ЗначениеЗаполнено(vAgent) Or vNoAgent);
		vVacantPeriods = vQry.Execute().Unload();
		WriteLogEvent(NStr("en='Get available ГруппаНомеров types';ru='Получить остатки свободных номеров';de='Restbestände an freien Zimmern erhalten'"), EventLogLevel.Information, , , 
					  NStr("en='Гостиница: '; de='Гостиница: '; ru='Отель: '") + vHotel + Chars.LF + 
					  NStr("en='ГруппаНомеров rate: ';ru='Тариф: ';de='Tarif: '") + vRoomRate + Chars.LF + 
					  NStr("en='Guests quantity: '; ru='Кол-во гостей: '") + vGuestsQuantity + Chars.LF + 
					  NStr("en='Agent: ';ru='Агент: ';de='Vertreter: '") + vAgent + Chars.LF + 
					  NStr("en='Контрагент: '; ru='Заказчик: '") + vCustomer + Chars.LF + 
					  NStr("en='Contract: ';ru='Договор: ';de='Vertrag: '") + vContract + Chars.LF + 
					  NStr("en='Period from: ';ru='Начало периода: ';de='Zeitraumbeginn: '") + pPeriodFrom + Chars.LF + 
					  NStr("en='Period to: ';ru='Конец периода: ';de='Zeitraumende: '") + pPeriodTo);
	EndIf;

	// Check if rooom rate prices cache is filled
	If ЗначениеЗаполнено(vHotel) And vHotel.UseRoomRateDailyPrices And cmRoomRatePricesCacheIsFilled(vHotel, vRoomRates, vClientType, pPeriodFrom, pPeriodTo) Тогда
		// Get accommodation templates suitable for each ГруппаНомеров rate / ГруппаНомеров type
		//vAccTemplates = GetAccommodationTemplateDetailsByGuestsQuantity(vAdultsQuantity, vKidsQuantity, vAgeArray, vHotel);
		
		// Get prices for each suitable template
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	RoomRatePrices.Гостиница,
		|	RoomRatePrices.Тариф,
		|	RoomRatePrices.RoomRateCode,
		|	RoomRatePrices.RoomRateDescription,
		|	RoomRatePrices.AccommodationTemplate,
		|	RoomRatePrices.AccommodationTemplateCode,
		|	RoomRatePrices.ТипНомера,
		|	RoomRatePrices.RoomTypeCode,
		|	RoomRatePrices.RoomTypeDescription,
		|	RoomRatePrices.ВидРазмещения,
		|	RoomRatePrices.AccommodationTypeCode,
		|	RoomRatePrices.AccommodationTypeDescription,
		|	RoomRatePrices.Валюта,
		|	RoomRatePrices.CurrencyCode,
		|	RoomRatePrices.CurrencyDescription,
		|	RoomRatePrices.RoomTypePictureLink,
		|	RoomRatePrices.RoomTypeInfoLink,
		|	SUM(RoomRatePrices.Amount) AS Amount,
		|	SUM(RoomRatePrices.FirstDaySum) AS FirstDaySum
		|FROM
		|	(SELECT
		|		RoomRateDailyPrices.Period AS Period,
		|		RoomRateDailyPrices.Гостиница AS Гостиница,
		|		RoomRateDailyPrices.Тариф AS Тариф,
		|		RoomRateDailyPrices.Тариф.Code AS RoomRateCode,
		|		RoomRateDailyPrices.Тариф.Description AS RoomRateDescription,
		|		AccommodationTemplatesAccommodationTypes.Ref AS AccommodationTemplate,
		|		AccommodationTemplatesAccommodationTypes.Ref.Code AS AccommodationTemplateCode,
		|		RoomRateDailyPrices.ТипНомера AS ТипНомера,
		|		RoomRateDailyPrices.ТипНомера.Code AS RoomTypeCode,
		|		RoomRateDailyPrices.ТипНомера.Description AS RoomTypeDescription,
		|		RoomRateDailyPrices.ВидРазмещения AS ВидРазмещения,
		|		RoomRateDailyPrices.ВидРазмещения.Code AS AccommodationTypeCode,
		|		RoomRateDailyPrices.ВидРазмещения.Description AS AccommodationTypeDescription,
		|		RoomRateDailyPrices.Валюта AS Валюта,
		|		RoomRateDailyPrices.Валюта.Code AS CurrencyCode,
		|		RoomRateDailyPrices.Валюта.Description AS CurrencyDescription,
		|		RoomRateDailyPrices.Цена AS Amount,
		|		CASE
		|			WHEN BEGINOFPERIOD(RoomRateDailyPrices.Period, DAY) = BEGINOFPERIOD(&qPeriodFrom, DAY)
		|				THEN RoomRateDailyPrices.Цена
		|			ELSE 0
		|		END AS FirstDaySum,
		|		CAST(RoomRateDailyPrices.ТипНомера.RoomTypePictureLink AS STRING(1024)) AS RoomTypePictureLink,
		|		CAST(RoomRateDailyPrices.ТипНомера.RoomTypeInfoLink AS STRING(1024)) AS RoomTypeInfoLink
		|	FROM
		|		InformationRegister.RoomRateDailyPrices AS RoomRateDailyPrices
		|			INNER JOIN Catalog.ШаблоныРазмещения.ВидыРазмещения AS AccommodationTemplatesAccommodationTypes
		|			ON RoomRateDailyPrices.ВидРазмещения = AccommodationTemplatesAccommodationTypes.ВидРазмещения
		|	WHERE
		|		RoomRateDailyPrices.Period >= &qPeriodFrom
		|		AND RoomRateDailyPrices.Period < &qPeriodTo
		|		AND RoomRateDailyPrices.Гостиница = &qHotel
		|		AND RoomRateDailyPrices.ТипКлиента = &qClientType
		|		AND RoomRateDailyPrices.ПризнакЦены = &qPriceTag
		|		AND RoomRateDailyPrices.Тариф IN(&qRoomRates)
		|		AND AccommodationTemplatesAccommodationTypes.Ref IN(&qAccTemplates)) AS RoomRatePrices
		|
		|GROUP BY
		|	RoomRatePrices.Гостиница,
		|	RoomRatePrices.Тариф,
		|	RoomRatePrices.RoomRateCode,
		|	RoomRatePrices.RoomRateDescription,
		|	RoomRatePrices.AccommodationTemplate,
		|	RoomRatePrices.AccommodationTemplateCode,
		|	RoomRatePrices.ТипНомера,
		|	RoomRatePrices.RoomTypeCode,
		|	RoomRatePrices.RoomTypeDescription,
		|	RoomRatePrices.ВидРазмещения,
		|	RoomRatePrices.AccommodationTypeCode,
		|	RoomRatePrices.AccommodationTypeDescription,
		|	RoomRatePrices.Валюта,
		|	RoomRatePrices.CurrencyCode,
		|	RoomRatePrices.CurrencyDescription,
		|	RoomRatePrices.RoomTypePictureLink,
		|	RoomRatePrices.RoomTypeInfoLink
		|
		|ORDER BY
		|	RoomRatePrices.Гостиница.ПорядокСортировки,
		|	RoomRatePrices.Гостиница.Description,
		|	RoomRatePrices.Тариф.ПорядокСортировки,
		|	RoomRatePrices.Тариф.Description,
		|	RoomRatePrices.AccommodationTemplateCode,
		|	RoomRatePrices.ТипНомера.ПорядокСортировки,
		|	RoomRatePrices.ВидРазмещения.ПорядокСортировки";
		vQry.SetParameter("qHotel", vHotel);
		vQry.SetParameter("qClientType", vClientType);
		vQry.SetParameter("qPeriodFrom", pPeriodFrom);
		vQry.SetParameter("qPeriodTo", pPeriodTo);
		vQry.SetParameter("qPriceTag", Справочники.ПризнакЦены.EmptyRef());
		vQry.SetParameter("qRoomRates", vRoomRates);
		//vQry.SetParameter("qAccTemplates", vAccTemplates);
		vPrices = vQry.Execute().Unload();
		
		vRetStr = "";
		For Each vRoomRateItem In vRoomRates Do
			vRoomRate = vRoomRateItem.Value;
			
			// Check ГруппаНомеров rate is valid period
			If ЗначениеЗаполнено(vRoomRate.DateValidFrom) Or ЗначениеЗаполнено(vRoomRate.DateValidTo) Тогда
				If ЗначениеЗаполнено(vRoomRate.DateValidFrom) And pPeriodFrom < vRoomRate.DateValidFrom Тогда
					Continue;
				EndIf;
				If ЗначениеЗаполнено(vRoomRate.DateValidTo) And pPeriodTo > EndOfDay(vRoomRate.DateValidTo) Тогда
					Continue;
				EndIf;
			EndIf;
			
			// Build XDTO object
			If vRetAccTypesRows = Неопределено Тогда
				vRetAccTypesRows = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидыРазмещения"));
			EndIf;
			vRetRoomTypeRow = Неопределено;
			vRetAccTypesList = Неопределено;
			
			vCurRoomType = Неопределено;
			vRoomRateRoomTypePrices = Неопределено;
			For Each vRoomTypesRow In vRoomTypes Do
				If vCurRoomType <> vRoomTypesRow.ТипНомера Тогда
					vCurRoomType = vRoomTypesRow.ТипНомера;
					
					If vRetRoomTypeRow <> Неопределено Тогда
						vRetRoomTypeRow.AccommodationTypesList = vRetAccTypesList;
						vRetAccTypesRows.ТипНомера.Add(vRetRoomTypeRow);
					EndIf;
					
					// Get prices for current ГруппаНомеров rate and ГруппаНомеров type
					vRoomRateRoomTypePrices = vPrices.FindRows(New Structure("Тариф, ТипНомера", vRoomRate, vCurRoomType));
					
					vRetRoomTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ТипНомера"));
					vRetRoomTypeRow.Code = TrimR(vCurRoomType.Code);
					vRetRoomTypeRow.Description = TrimR(vCurRoomType.Description);
					
					vRetAccTypesList = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypesList"));
				EndIf;
				
				If vRoomRateRoomTypePrices <> Неопределено Тогда
					For Each vRoomRateRoomTypePricesRow In vRoomRateRoomTypePrices Do
						vCurAccommodationTemplate = vRoomRateRoomTypePricesRow.AccommodationTemplate;
						If ЗначениеЗаполнено(vCurAccommodationTemplate) Тогда
							If vCurAccommodationTemplate.ТипыНомеров.Count() <> 0 And vCurAccommodationTemplate.ТипыНомеров.Find(vCurRoomType, "ТипНомера") = Неопределено Тогда
								Continue;
							EndIf;
						EndIf;
						vCurAccommodationType = vRoomRateRoomTypePricesRow.ВидРазмещения;
						
						vRetAccTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидРазмещения"));
						vRetAccTypeRow.Code = TrimR(vCurAccommodationType.Code);
						vRetAccTypeRow.Description = vCurAccommodationType.GetObject().pmGetAccommodationTypeDescription(vLanguage);
						vRetAccTypeRow.Age = 0;
						For Each vAge In vAgeArray Do
							If vAge > vCurAccommodationType.AllowedClientAgeFrom And vAge < vCurAccommodationType.AllowedClientAgeTo Тогда
								vRetAccTypeRow.Age = vAge;
								Break;
							EndIf;
						EndDo;
						vRetAccTypeRow.ClientAgeFrom = vCurAccommodationType.AllowedClientAgeFrom;
						vRetAccTypeRow.ClientAgeTo = vCurAccommodationType.AllowedClientAgeTo;
						
						vAccTypeCurrency = vRoomRateRoomTypePricesRow.Валюта;
						vRetAccTypeRow.Amount = vRoomRateRoomTypePricesRow.Amount;
						vRetAccTypeRow.AmountPresentation = cmFormatSum(vRoomRateRoomTypePricesRow.Amount, vAccTypeCurrency, "NZ=");
						vRetAccTypeRow.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vAccTypeCurrency);
						If IsBlankString(vRetAccTypeRow.Валюта) Тогда
							vRetAccTypeRow.Валюта = СокрЛП(vAccTypeCurrency);
						EndIf;
						If ЗначениеЗаполнено(vAccTypeCurrency) Тогда
							vRetAccTypeRow.CurrencyCode = СокрЛП(vAccTypeCurrency.Code);
							vRetAccTypeRow.CurrencyDescription = СокрЛП(vAccTypeCurrency.Description);
						Else
							vRetAccTypeRow.CurrencyCode = "";
							vRetAccTypeRow.CurrencyDescription = "";
						EndIf;
					EndDo; // By prices
				EndIf;
				If vRetRoomTypeRow <> Неопределено Тогда
					vRetRoomTypeRow.AccommodationTypesList = vRetAccTypesList;
					vRetAccTypesRows.ТипНомера.Add(vRetRoomTypeRow);
				EndIf;
			EndDo; // By ГруппаНомеров types
			vRetXDTO.ВидыРазмещения = vRetAccTypesRows;
			
			// Build XDTO return object
			If vAvailableRoomTypesRows = Неопределено Тогда
				vAvailableRoomTypesRows = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AvailableRoomTypesRows"));
			EndIf;
			vCurRoomType = Неопределено;
			vAmount = 0;
			vFirstDaySum = 0;
			For Each vRoomTypesRow In vRoomTypes Do
				If vCurRoomType <> vRoomTypesRow.ТипНомера Тогда
					vRetAccTypesList = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypesList"));
					vCurRoomType = vRoomTypesRow.ТипНомера;
				EndIf;
				
				// Get prices for current ГруппаНомеров rate, ГруппаНомеров type
				j = 0;
				vRoomRateRoomTypePrices = vPrices.FindRows(New Structure("Тариф, ТипНомера", vRoomRate, vCurRoomType));
				For Each vRoomRateRoomTypePricesRow In vRoomRateRoomTypePrices Do
					j = j + 1;
					vCurAccommodationTemplate = vRoomRateRoomTypePricesRow.AccommodationTemplate;
					If ЗначениеЗаполнено(vCurAccommodationTemplate) Тогда
						If vCurAccommodationTemplate.ТипыНомеров.Count() <> 0 And vCurAccommodationTemplate.ТипыНомеров.Find(vCurRoomType, "ТипНомера") = Неопределено Тогда
							Continue;
						EndIf;
					EndIf;
					vCurRoomRate = vRoomRateRoomTypePricesRow.Тариф;
					vCurAccommodationType = vRoomRateRoomTypePricesRow.ВидРазмещения;
					
					vRetAccTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидРазмещения"));
					vRetAccTypeRow.Code = TrimR(vCurAccommodationType.Code);
					vRetAccTypeRow.Description = vCurAccommodationType.GetObject().pmGetAccommodationTypeDescription(vLanguage);
					vRetAccTypeRow.Age = 0;
					For Each vAge In vAgeArray Do
						If vAge > vCurAccommodationType.AllowedClientAgeFrom And vAge < vCurAccommodationType.AllowedClientAgeTo Тогда
							vRetAccTypeRow.Age = vAge;
							Break;
						EndIf;
					EndDo;
					vRetAccTypeRow.ClientAgeFrom = vCurAccommodationType.AllowedClientAgeFrom;
					vRetAccTypeRow.ClientAgeTo = vCurAccommodationType.AllowedClientAgeTo;
					
					vAccTypeCurrency = vRoomRateRoomTypePricesRow.Валюта;
					vRetAccTypeRow.Amount = vRoomRateRoomTypePricesRow.Amount;
					vRetAccTypeRow.AmountPresentation = cmFormatSum(vRoomRateRoomTypePricesRow.Amount, vAccTypeCurrency, "NZ=");
					vRetAccTypeRow.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vAccTypeCurrency);
					If IsBlankString(vRetAccTypeRow.Валюта) Тогда
						vRetAccTypeRow.Валюта = СокрЛП(vAccTypeCurrency);
					EndIf;
					If ЗначениеЗаполнено(vAccTypeCurrency) Тогда
						vRetAccTypeRow.CurrencyCode = СокрЛП(vAccTypeCurrency.Code);
						vRetAccTypeRow.CurrencyDescription = СокрЛП(vAccTypeCurrency.Description);
					Else
						vRetAccTypeRow.CurrencyCode = "";
						vRetAccTypeRow.CurrencyDescription = "";
					EndIf;            	
					
					vAmount = vAmount + vRoomRateRoomTypePricesRow.Amount;
					vFirstDaySum = vFirstDaySum + vRoomRateRoomTypePricesRow.FirstDaySum;
					
					vRetAccTypesList.ВидРазмещения.Add(vRetAccTypeRow);
					
					If j = vRoomRateRoomTypePrices.Count() Тогда 
						vRetRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AvailableRoomTypesRow"));
						vRetRow.Гостиница = cmGetObjectExternalSystemCodeByRef(vRoomRateRoomTypePricesRow.Гостиница, pExternalSystemCode, "Гостиницы", vRoomRateRoomTypePricesRow.Гостиница);
						vRetRow.RoomsAvailable = vRoomTypesRow.RoomsAvailable;
						vRetRow.BedsAvailable = vRoomTypesRow.BedsAvailable;
						vRetRow.Тариф = cmGetObjectExternalSystemCodeByRef(vRoomRateRoomTypePricesRow.Гостиница, pExternalSystemCode, "Тарифы", vRoomRateRoomTypePricesRow.Тариф);
						vRetRow.RoomRateCode = vRoomRateRoomTypePricesRow.RoomRateCode;
						vRetRow.RoomRateDescription = vRoomRateRoomTypePricesRow.RoomRateDescription;
						vRetRow.Валюта = vRetAccTypeRow.Валюта;
						vRetRow.FirstDaySum = vFirstDaySum;
						vRetRow.Amount = vAmount;
						vRetRow.ТипНомера = cmGetObjectExternalSystemCodeByRef(vRoomRateRoomTypePricesRow.Гостиница, pExternalSystemCode, "ТипыНомеров", vRoomRateRoomTypePricesRow.ТипНомера);
						vRetRow.RoomTypeCode = vRoomRateRoomTypePricesRow.RoomTypeCode;
						vRetRow.RoomTypeDescription = vRoomRateRoomTypePricesRow.RoomTypeDescription;
						vRetRow.CurrencyCode = vRoomRateRoomTypePricesRow.CurrencyCode;
						vRetRow.CurrencyDescription = vRoomRateRoomTypePricesRow.CurrencyDescription;
						vRetRow.RoomTypePictureLink = vRoomRateRoomTypePricesRow.RoomTypePictureLink;
						vRetRow.RoomTypeInfoLink = vRoomRateRoomTypePricesRow.RoomTypeInfoLink;
						vRetRow.AmountPresentation = cmFormatSum(vAmount, vRoomRateRoomTypePricesRow.Валюта, "NZ=");
						vRetRow.LimitedRoomsText = "";
						If vCurRoomType.LimitedRooms > 0 And vRoomTypesRow.RoomsAvailable > 0 And vRoomTypesRow.RoomsAvailable <= vCurRoomType.LimitedRooms Тогда
							If vRoomTypesRow.RoomsAvailable = 1 Тогда
								vRetRow.LimitedRoomsText = "Остался только " + Format(vRoomTypesRow.RoomsAvailable, "ND=10; NFD=0; NG=") + " НомерРазмещения";
							ElsIf vRoomTypesRow.RoomsAvailable >= 2 And vRoomTypesRow.RoomsAvailable < 5 Тогда
								vRetRow.LimitedRoomsText = "Осталось только " + Format(vRoomTypesRow.RoomsAvailable, "ND=10; NFD=0; NG=") + " номера";
							Else
								vRetRow.LimitedRoomsText = "Осталось только " + Format(vRoomTypesRow.RoomsAvailable, "ND=10; NFD=0; NG=") + " номеров";
							EndIf;
						EndIf;
						If ЗначениеЗаполнено(vRoomRateRoomTypePricesRow.Тариф) Тогда
							vRowRoomRate = vRoomRateRoomTypePricesRow.Тариф;
							vRetRow.ReservationConditionsShort = Left(vCurRoomRate.ReservationConditionsShort, 2048);
							vRetRow.ReservationConditionsOnline = Left(vCurRoomRate.ReservationConditionsOnline, 2048);
							vRetRow.PaymentMethodCodesAllowedOnline = Left(СокрЛП(vCurRoomRate.PaymentMethodCodesAllowedOnline), 2048);
						Else
							vRetRow.ReservationConditionsShort = "";
							vRetRow.ReservationConditionsOnline = "";
							vRetRow.PaymentMethodCodesAllowedOnline = "";
						EndIf;
						
						vRetRow.AccommodationTypesList = vRetAccTypesList;		
						
						vRetStr = vRetStr + """" + vRetRow.Гостиница + """" + "," + """" + vRetRow.ТипНомера + """" + "," + 
						"""" + СокрЛП(vRoomRateRoomTypePricesRow.AccommodationTemplateCode) + """" + "," + 
						Format(vRoomTypesRow.RoomsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + Format(vRoomTypesRow.BedsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
						"""" + vRetRow.Валюта + """" + "," + Format(vFirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + Format(vAmount, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
						"""" + vRoomRateRoomTypePricesRow.RoomTypeCode + """" + "," + """" + cmRemoveComma(vRoomRateRoomTypePricesRow.RoomTypeDescription) + """" + "," + 
						"""" + СокрЛП(vCurAccommodationType.Code) + """" + "," + """" + cmRemoveComma(СокрЛП(vCurAccommodationType.Description)) + """" + "," + 
						"""" + vRoomRateRoomTypePricesRow.RoomRateCode + """" + "," + """" + cmRemoveComma(vRoomRateRoomTypePricesRow.RoomRateDescription) + """" + "," + 
						"""" + vRoomRateRoomTypePricesRow.CurrencyCode + """" + "," + """" + cmRemoveComma(vRoomRateRoomTypePricesRow.CurrencyDescription) + """" + "," + 
						"""" + cmRemoveComma(vRetAccTypeRow.AmountPresentation) + """" + "," + 
						"""" + cmRemoveComma(vRoomRateRoomTypePricesRow.RoomTypePictureLink) + """" + "," + """" + cmRemoveComma(vRoomRateRoomTypePricesRow.RoomTypeInfoLink) + """" + Chars.LF;
						
						vAvailableRoomTypesRows.AvailableRoomTypesRow.Add(vRetRow);
						
						vAmount = 0;
						vFirstDaySum = 0;
					EndIf;
				EndDo;
			EndDo;
			vRetXDTO.AvailableRoomTypesRows = vAvailableRoomTypesRows;
		EndDo; // By ГруппаНомеров rates
	Else
		// Probe document object to calculate prices
		vProbeResObj = Documents.Бронирование.CreateDocument();
		vProbeResObj.Гостиница = vHotel;
		//vProbeResObj.pmFillAttributesWithDefaultValues(True);
		
		vRetStr = "";
		For Each vRoomRateItem In vRoomRates Do
			vRoomRate = vRoomRateItem.Value;
			// Check ГруппаНомеров rate is valid period
			If ЗначениеЗаполнено(vRoomRate.DateValidFrom) Or ЗначениеЗаполнено(vRoomRate.DateValidTo) Тогда
				If ЗначениеЗаполнено(vRoomRate.DateValidFrom) And pPeriodFrom < vRoomRate.DateValidFrom Тогда
					Continue;
				EndIf;
				If ЗначениеЗаполнено(vRoomRate.DateValidTo) And pPeriodTo > EndOfDay(vRoomRate.DateValidTo) Тогда
					Continue;
				EndIf;
			EndIf;
			
			// Get ГруппаНомеров types balances table
			vRoomTypeBalances = cmGetRoomTypeBalancesTable(vRoomTypes, True, vHotel, pPeriodFrom, pPeriodTo, vClientType, vCustomer, vContract, vDiscountType, vExtHotelCode, vLanguage, pExternalSystemCode, , vRoomRate, , vAdultsQuantity, vKidsQuantity, vAgeArray, vProbeResObj);
			
			// Build XDTO object
			If vRetAccTypesRows = Неопределено Тогда
				vRetAccTypesRows = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидыРазмещения"));
			EndIf;
			vRetRoomTypeRow = Неопределено;
			vRetAccTypesList = Неопределено;
			vCurRoomType = Неопределено;
			For Each vRoomTypeBalancesRow In vRoomTypeBalances Do
				If vCurRoomType <> vRoomTypeBalancesRow.ТипНомера Тогда
					vCurRoomType = vRoomTypeBalancesRow.ТипНомера;
					
					If vRetRoomTypeRow <> Неопределено Тогда
						vRetRoomTypeRow.AccommodationTypesList = vRetAccTypesList;
						vRetAccTypesRows.ТипНомера.Add(vRetRoomTypeRow);
					EndIf;
					
					vRetRoomTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ТипНомера"));
					vRetRoomTypeRow.Code = TrimR(vCurRoomType.Code);
					vRetRoomTypeRow.Description = TrimR(vCurRoomType.Description);
					
					vRetAccTypesList = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypesList"));
				EndIf;
				
				vCurAccommodationType = vRoomTypeBalancesRow.ВидРазмещения;
				
				vRetAccTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидРазмещения"));
				vRetAccTypeRow.Code = TrimR(vCurAccommodationType.Code);
				vRetAccTypeRow.Description = vCurAccommodationType.GetObject().pmGetAccommodationTypeDescription(vLanguage);
				vRetAccTypeRow.Age = vRoomTypeBalancesRow.Age;
				vRetAccTypeRow.ClientAgeFrom = vCurAccommodationType.AllowedClientAgeFrom;
				vRetAccTypeRow.ClientAgeTo = vCurAccommodationType.AllowedClientAgeTo;
				
				vAccTypeCurrency = vRoomTypeBalancesRow.Валюта;
				vRetAccTypeRow.Amount = ?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount);
				vRetAccTypeRow.AmountPresentation = cmFormatSum(?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount), vAccTypeCurrency, "NZ=");
				vRetAccTypeRow.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vAccTypeCurrency);
				If IsBlankString(vRetAccTypeRow.Валюта) Тогда
					vRetAccTypeRow.Валюта = СокрЛП(vAccTypeCurrency);
				EndIf;
				If ЗначениеЗаполнено(vAccTypeCurrency) Тогда
					vRetAccTypeRow.CurrencyCode = СокрЛП(vAccTypeCurrency.Code);
					vRetAccTypeRow.CurrencyDescription = СокрЛП(vAccTypeCurrency.Description);
				Else
					vRetAccTypeRow.CurrencyCode = "";
					vRetAccTypeRow.CurrencyDescription = "";
				EndIf;
				
				vRetAccTypesList.ВидРазмещения.Add(vRetAccTypeRow);
			EndDo;
			If vRetRoomTypeRow <> Неопределено Тогда
				vRetRoomTypeRow.AccommodationTypesList = vRetAccTypesList;
				vRetAccTypesRows.ТипНомера.Add(vRetRoomTypeRow);
			EndIf;
			If ЗначениеЗаполнено(vRoomType) And vRetAccTypesList = Неопределено Тогда
				// Get accommodation types table with ages
				vAccTypesWithAgeList = cmGetAvailableAccommodationTypesWithKidsAges(vAdultsQuantity, vKidsQuantity, vAgeArray, pExternalSystemCode, vHotel, vRoomType);
				If vAccTypesWithAgeList.Count() > 0 Тогда
					
					vCalendarDayTypes = Неопределено;
					If ЗначениеЗаполнено(vRoomRate.Calendar) Тогда
						vCalendarDayTypes = vRoomRate.Calendar.GetObject().pmGetDays(pPeriodFrom, pPeriodTo, pPeriodFrom, pPeriodTo);
						vCalendarDayTypes.Sort("Period");
					EndIf;
					vOrders = cmGetActiveSetRoomRatePrices(vRoomRate, cm1SecondShift(pPeriodFrom));
					rPriceTagsList = New СписокЗначений();
					vPriceTags = cmGetEffectivePriceTags(vHotel, vRoomRate, vRoomType, pPeriodFrom, pPeriodTo, rPriceTagsList);
					
					vAccTypesWithPricesTable = GetAccommodationTypePriceFromRoomRatePrices(vHotel, vRoomQuota, vRoomType, vAccTypesWithAgeList.UnloadColumn("ВидРазмещения"), vClientType, vRoomRate, pPeriodFrom, pPeriodTo, vCalendarDayTypes, vOrders, vPriceTags);
					vRetRoomTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ТипНомера"));
					vRetRoomTypeRow.Code = TrimR(vRoomType.Code);
					vRetRoomTypeRow.Description = TrimR(vRoomType.Description);
					
					vRetAccTypesList = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypesList"));
					For Each vAccTypeRow In vAccTypesWithAgeList Do
						vRetAccTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидРазмещения"));
						vRetAccTypeRow.Code = TrimR(vAccTypeRow.ВидРазмещения.Code);
						vRetAccTypeRow.Description = vAccTypeRow.ВидРазмещения.GetObject().pmGetAccommodationTypeDescription(vLanguage);
						vRetAccTypeRow.Age = vAccTypeRow.Age;
						vRetAccTypeRow.ClientAgeFrom = vAccTypeRow.ВидРазмещения.AllowedClientAgeFrom;
						vRetAccTypeRow.ClientAgeTo = vAccTypeRow.ВидРазмещения.AllowedClientAgeTo;
						
						vAccTypesWithPricesTableRow = vAccTypesWithPricesTable.Find(vAccTypeRow.ВидРазмещения, "ВидРазмещения");
						If vAccTypesWithPricesTableRow <> Неопределено Тогда
							vAccTypeCurrency = vAccTypesWithPricesTableRow.Валюта;
							vRetAccTypeRow.Amount = ?(vAccTypesWithPricesTableRow.Сумма = Неопределено, 0, vAccTypesWithPricesTableRow.Сумма);
							vRetAccTypeRow.AmountPresentation = cmFormatSum(?(vAccTypesWithPricesTableRow.Сумма = Неопределено, 0, vAccTypesWithPricesTableRow.Сумма), vAccTypeCurrency, "NZ=");
							vRetAccTypeRow.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vAccTypeCurrency);
							If IsBlankString(vRetAccTypeRow.Валюта) Тогда
								vRetAccTypeRow.Валюта = СокрЛП(vAccTypeCurrency);
							EndIf;
							If ЗначениеЗаполнено(vAccTypeCurrency) Тогда
								vRetAccTypeRow.CurrencyCode = СокрЛП(vAccTypeCurrency.Code);
								vRetAccTypeRow.CurrencyDescription = СокрЛП(vAccTypeCurrency.Description);
							Else
								vRetAccTypeRow.CurrencyCode = "";
								vRetAccTypeRow.CurrencyDescription = "";
							EndIf;
						Else
							vRetAccTypeRow.Amount = 0;
							vRetAccTypeRow.AmountPresentation = "";
							vRetAccTypeRow.Валюта = "";
							vRetAccTypeRow.CurrencyCode = "";
							vRetAccTypeRow.CurrencyDescription = "";
						EndIf;
						vRetAccTypesList.ВидРазмещения.Add(vRetAccTypeRow)
					EndDo;
					vRetRoomTypeRow.AccommodationTypesList = vRetAccTypesList;
					vRetAccTypesRows.ТипНомера.Add(vRetRoomTypeRow);
				EndIf;
			EndIf;
			vRetXDTO.ВидыРазмещения = vRetAccTypesRows;
			
			// Build XDTO return object
			If vAvailableRoomTypesRows = Неопределено Тогда
				vAvailableRoomTypesRows = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AvailableRoomTypesRows"));
			EndIf;
			vCurRoomType = Неопределено;
			vAmount = 0;
			vFirstDaySum = 0;
			For Each vRoomTypeBalancesRow In vRoomTypeBalances Do
				If vCurRoomType <> vRoomTypeBalancesRow.ТипНомера Тогда
					vRetAccTypesList = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypesList"));
					vCurRoomType = vRoomTypeBalancesRow.ТипНомера;
				EndIf;
				
				vCurAccommodationType = vRoomTypeBalancesRow.ВидРазмещения;
				
				vRetAccTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидРазмещения"));
				vRetAccTypeRow.Code = TrimR(vCurAccommodationType.Code);
				vRetAccTypeRow.Description = vCurAccommodationType.GetObject().pmGetAccommodationTypeDescription(vLanguage);
				vRetAccTypeRow.Age = vRoomTypeBalancesRow.Age;
				vRetAccTypeRow.ClientAgeFrom = vCurAccommodationType.AllowedClientAgeFrom;
				vRetAccTypeRow.ClientAgeTo = vCurAccommodationType.AllowedClientAgeTo;
				
				vAccTypeCurrency = vRoomTypeBalancesRow.Валюта;
				vRetAccTypeRow.Amount = ?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount);
				vRetAccTypeRow.AmountPresentation = cmFormatSum(?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount), vAccTypeCurrency, "NZ=");
				vRetAccTypeRow.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vAccTypeCurrency);
				If IsBlankString(vRetAccTypeRow.Валюта) Тогда
					vRetAccTypeRow.Валюта = СокрЛП(vAccTypeCurrency);
				EndIf;
				If ЗначениеЗаполнено(vAccTypeCurrency) Тогда
					vRetAccTypeRow.CurrencyCode = СокрЛП(vAccTypeCurrency.Code);
					vRetAccTypeRow.CurrencyDescription = СокрЛП(vAccTypeCurrency.Description);
				Else
					vRetAccTypeRow.CurrencyCode = "";
					vRetAccTypeRow.CurrencyDescription = "";
				EndIf;            	
				
				vAmount = vAmount + ?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount);
				vFirstDaySum = vFirstDaySum + ?(vRoomTypeBalancesRow.FirstDaySum = Неопределено, 0, vRoomTypeBalancesRow.FirstDaySum);
				
				vRetAccTypesList.ВидРазмещения.Add(vRetAccTypeRow);
				
				If ((vRoomTypeBalances.IndexOf(vRoomTypeBalancesRow)+1) = vRoomTypeBalances.Count()) 
					Or vRoomTypeBalances[vRoomTypeBalances.IndexOf(vRoomTypeBalancesRow)+1].ТипНомера <> vRoomTypeBalancesRow.ТипНомера Тогда
					
					vRetRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AvailableRoomTypesRow"));
					vRetRow.Гостиница = vRoomTypeBalancesRow.ExtHotelCode;
					vRetRow.RoomsAvailable = vRoomTypeBalancesRow.RoomsAvailable;
					vRetRow.BedsAvailable = vRoomTypeBalancesRow.BedsAvailable;
					vRetRow.Тариф = vRoomTypeBalancesRow.ExtRoomRateCode;
					vRetRow.RoomRateCode = vRoomTypeBalancesRow.RoomRateCode;
					vRetRow.RoomRateDescription = vRoomTypeBalancesRow.RoomRateDescription;
					vRetRow.Валюта = vRoomTypeBalancesRow.ExtCurrencyCode;
					vRetRow.FirstDaySum = vFirstDaySum;
					vRetRow.Amount = vAmount;
					vRetRow.ТипНомера = vRoomTypeBalancesRow.ExtRoomTypeCode;
					vRetRow.RoomTypeCode = vRoomTypeBalancesRow.RoomTypeCode;
					vRetRow.RoomTypeDescription = vRoomTypeBalancesRow.RoomTypeDescription;
					vRetRow.CurrencyCode = vRoomTypeBalancesRow.CurrencyCode;
					vRetRow.CurrencyDescription = vRoomTypeBalancesRow.CurrencyDescription;
					vRetRow.RoomTypePictureLink = vRoomTypeBalancesRow.RoomTypePictureLink;
					vRetRow.RoomTypeInfoLink = vRoomTypeBalancesRow.RoomTypeInfoLink;
					vRetRow.AmountPresentation = cmFormatSum(vAmount, vRoomTypeBalancesRow.Валюта, "NZ=");
					vRetRow.LimitedRoomsText = vRoomTypeBalancesRow.LimitedRoomsText;
					If ЗначениеЗаполнено(vRoomTypeBalancesRow.Тариф) Тогда
						vRowRoomRate = vRoomTypeBalancesRow.Тариф;
						vRetRow.ReservationConditionsShort = Left(vRowRoomRate.ReservationConditionsShort, 2048);
						vRetRow.ReservationConditionsOnline = Left(vRowRoomRate.ReservationConditionsOnline, 2048);
						vRetRow.PaymentMethodCodesAllowedOnline = Left(СокрЛП(vRowRoomRate.PaymentMethodCodesAllowedOnline), 2048);
					Else
						vRetRow.ReservationConditionsShort = "";
						vRetRow.ReservationConditionsOnline = "";
						vRetRow.PaymentMethodCodesAllowedOnline = "";
					EndIf;
					
					vRetRow.AccommodationTypesList = vRetAccTypesList;		
					
					vRetStr = vRetStr + """" + vRoomTypeBalancesRow.ExtHotelCode + """" + "," + """" + vRoomTypeBalancesRow.ExtRoomTypeCode + """" + "," + 
					"""" + СокрЛП(vRoomTypeBalancesRow.AccommodationTemplate.Code) + """" + "," + 
					Format(vRoomTypeBalancesRow.RoomsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + Format(vRoomTypeBalancesRow.BedsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
					"""" + vRoomTypeBalancesRow.ExtCurrencyCode + """" + "," + Format(vRoomTypeBalancesRow.FirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + Format(vRoomTypeBalancesRow.Amount, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
					"""" + vRoomTypeBalancesRow.RoomTypeCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypeDescription) + """" + "," + 
					"""" + СокрЛП(vCurAccommodationType.Code) + """" + "," + """" + cmRemoveComma(СокрЛП(vCurAccommodationType.Description)) + """" + "," + 
					"""" + vRoomTypeBalancesRow.RoomRateCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomRateDescription) + """" + "," + 
					"""" + vRoomTypeBalancesRow.CurrencyCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.CurrencyDescription) + """" + "," + 
					"""" + cmRemoveComma(vRoomTypeBalancesRow.AmountPresentation) + """" + "," + 
					"""" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypePictureLink) + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypeInfoLink) + """" + Chars.LF;
					
					
					vAvailableRoomTypesRows.AvailableRoomTypesRow.Add(vRetRow);
					
					vAmount = 0;
					vFirstDaySum = 0;
				EndIf;
			EndDo;
			vRetXDTO.AvailableRoomTypesRows = vAvailableRoomTypesRows;
			
			// Check check-in periods
			If vVacantPeriods.Count() > 0 Тогда 
				// Build XDTO return object
				If vAvailableRoomTypesByCheckInPeriodsRows = Неопределено Тогда
					vAvailableRoomTypesByCheckInPeriodsRows = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AvailableRoomTypesByCheckInPeriodsRows"));
				EndIf;
				
				vLastQuota = Неопределено;
				vLastPeriodFrom = Неопределено;
				vLastPeriodTo = Неопределено;
				vCheckInHotel = vHotel;
				vCheckInDate = pPeriodFrom;
				vCheckOutDate = pPeriodTo;
				vCustomer = vCustomer;
				vDuration = vDuration;
				vAllotmentDescription = "";
				vAllotmentCode = "";
				vAgent = vAgent;
				vContract = vContract;
				vRoomTypes = New ValueTable;
				vRoomTypes.Columns.Add("ТипНомера");
				vRoomTypes.Columns.Add("RoomsAvailable");
				vRoomTypes.Columns.Add("BedsAvailable");
				For Each vSameCheckOutDateRow In vVacantPeriods Do
					If vLastPeriodFrom <> vSameCheckOutDateRow.CheckInDate  Or vLastPeriodTo <> vSameCheckOutDateRow.CheckOutDate Or vLastQuota <> vSameCheckOutDateRow.Allotment Тогда
						If vLastPeriodFrom <> Неопределено And vLastPeriodTo <> Неопределено And vLastQuota <> Неопределено Тогда
							If НЕ ЗначениеЗаполнено(vRoomRate.Allotment) Or ЗначениеЗаполнено(vRoomRate.Allotment) And (vRoomRate.Allotment.IsFolder And vLastQuota.BelongsToItem(vRoomRate.Allotment) Or (НЕ vRoomRate.Allotment.IsFolder) And vLastQuota = vRoomRate.Allotment) Тогда
								// Get ГруппаНомеров types balances table
								vRoomTypeBalances = cmGetRoomTypeBalancesTable(vRoomTypes, True, vCheckInHotel, vCheckInDate, vCheckOutDate, vClientType, vCustomer, vContract, vDiscountType, vExtHotelCode, vLanguage, pExternalSystemCode, , vRoomRate,, vAdultsQuantity, vKidsQuantity, vAgeArray, vProbeResObj);
								vCurRoomType = Неопределено;
								vAmount = 0;
								vFirstDaySum = 0;
								For Each vRoomTypeBalancesRow In vRoomTypeBalances Do
									
									If vCurRoomType <> vRoomTypeBalancesRow.ТипНомера Тогда
										vRetAccTypesList = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypesList"));
										vCurRoomType = vRoomTypeBalancesRow.ТипНомера;
									EndIf;
									
									vCurAccommodationType = vRoomTypeBalancesRow.ВидРазмещения;
									
									vRetAccTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидРазмещения"));
									vRetAccTypeRow.Code = TrimR(vCurAccommodationType.Code);
									vRetAccTypeRow.Description = vCurAccommodationType.GetObject().pmGetAccommodationTypeDescription(vLanguage);
									vRetAccTypeRow.Age = vRoomTypeBalancesRow.Age;
									vRetAccTypeRow.ClientAgeFrom = vCurAccommodationType.AllowedClientAgeFrom;
									vRetAccTypeRow.ClientAgeTo = vCurAccommodationType.AllowedClientAgeTo;
									
									vAccTypeCurrency = vRoomTypeBalancesRow.Валюта;
									vRetAccTypeRow.Amount = ?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount);
									vRetAccTypeRow.AmountPresentation = cmFormatSum(?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount), vAccTypeCurrency, "NZ=");
									vRetAccTypeRow.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vAccTypeCurrency);
									If IsBlankString(vRetAccTypeRow.Валюта) Тогда
										vRetAccTypeRow.Валюта = СокрЛП(vAccTypeCurrency);
									EndIf;
									If ЗначениеЗаполнено(vAccTypeCurrency) Тогда
										vRetAccTypeRow.CurrencyCode = СокрЛП(vAccTypeCurrency.Code);
										vRetAccTypeRow.CurrencyDescription = СокрЛП(vAccTypeCurrency.Description);
									Else
										vRetAccTypeRow.CurrencyCode = "";
										vRetAccTypeRow.CurrencyDescription = "";
									EndIf;            	
									
									vRetAccTypesList.ВидРазмещения.Add(vRetAccTypeRow);
									
									vAmount = vAmount + ?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount);
									vFirstDaySum = vFirstDaySum + ?(vRoomTypeBalancesRow.FirstDaySum = Неопределено, 0, vRoomTypeBalancesRow.FirstDaySum);
									If ((vRoomTypeBalances.IndexOf(vRoomTypeBalancesRow)+1) = vRoomTypeBalances.Count()) 
										Or vRoomTypeBalances[vRoomTypeBalances.IndexOf(vRoomTypeBalancesRow)+1].ТипНомера <> vRoomTypeBalancesRow.ТипНомера Тогда
										vRetRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AvailableRoomTypesByCheckInPeriodsRow"));
										vRetRow.Гостиница = vRoomTypeBalancesRow.ExtHotelCode;
										vRetRow.ТипНомера = vRoomTypeBalancesRow.ExtRoomTypeCode;
										vRetRow.RoomTypeCode = vRoomTypeBalancesRow.RoomTypeCode;
										vRetRow.RoomTypeDescription = vRoomTypeBalancesRow.RoomTypeDescription;
										vRetRow.RoomTypePictureLink = vRoomTypeBalancesRow.RoomTypePictureLink;
										vRetRow.RoomTypeInfoLink = vRoomTypeBalancesRow.RoomTypeInfoLink;
										vRetRow.Тариф = cmGetObjectExternalSystemCodeByRef(vCheckInHotel, pExternalSystemCode, "Тарифы", vRoomRate);
										vRetRow.RoomRateCode = ?(ЗначениеЗаполнено(vRoomRate), СокрЛП(vRoomRate.Code), "");
										vRetRow.RoomRateDescription =  ?(ЗначениеЗаполнено(vRoomRate), СокрЛП(vRoomRate.Description), "");
										vRetRow.Валюта = vRoomTypeBalancesRow.ExtCurrencyCode;
										vRetRow.CurrencyCode = vRoomTypeBalancesRow.CurrencyCode;
										vRetRow.CurrencyDescription = vRoomTypeBalancesRow.CurrencyDescription;
										vRetRow.FirstDaySum = vFirstDaySum;
										vRetRow.Amount = vAmount;
										vRetRow.AmountPresentation = cmFormatSum(vAmount, vRoomTypeBalancesRow.Валюта, "NZ=");
										vRetRow.LimitedRoomsText = vRoomTypeBalancesRow.LimitedRoomsText;
										vRetRow.ОстаетсяНомеров = vRoomTypeBalancesRow.RoomsAvailable;
										vRetRow.ОстаетсяМест = vRoomTypeBalancesRow.BedsAvailable;
										vRetRow.Allotment = vAllotmentCode;
										vRetRow.AllotmentDescription = vAllotmentDescription;
										vRetRow.CheckInDate = vCheckInDate;
										vRetRow.Продолжительность = vDuration;
										vRetRow.ДатаВыезда = vCheckOutDate;
										If ЗначениеЗаполнено(vRoomRate) Тогда
											vRetRow.ReservationConditionsShort = Left(vRoomRate.ReservationConditionsShort, 2048);
											vRetRow.ReservationConditionsOnline = Left(vRoomRate.ReservationConditionsOnline, 2048);
											vRetRow.PaymentMethodCodesAllowedOnline = Left(СокрЛП(vRoomRate.PaymentMethodCodesAllowedOnline), 2048);
										Else
											vRetRow.ReservationConditionsShort = "";
											vRetRow.ReservationConditionsOnline = "";
											vRetRow.PaymentMethodCodesAllowedOnline = "";
										EndIf;
										vRetRow.AccommodationTypesList = vRetAccTypesList;
										
										vRetStr = vRetStr + """" + vRoomTypeBalancesRow.ExtHotelCode + """" + "," + """" + vRoomTypeBalancesRow.ExtRoomTypeCode + """" + "," + 
										"""" + СокрЛП(vRoomTypeBalancesRow.AccommodationTemplate.Code) + """" + "," + 
										Format(vRoomTypeBalancesRow.RoomsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + Format(vRoomTypeBalancesRow.BedsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
										"""" + vRoomTypeBalancesRow.ExtCurrencyCode + """" + "," + Format(vRoomTypeBalancesRow.FirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + Format(vRoomTypeBalancesRow.Amount, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
										"""" + vRoomTypeBalancesRow.RoomTypeCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypeDescription) + """" + "," + 
										"""" + СокрЛП(vCurAccommodationType.Code) + """" + "," + """" + cmRemoveComma(СокрЛП(vCurAccommodationType.Description)) + """" + "," + 
										"""" + vRoomTypeBalancesRow.RoomRateCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomRateDescription) + """" + "," + 
										"""" + vRoomTypeBalancesRow.CurrencyCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.CurrencyDescription) + """" + "," + 
										"""" + cmRemoveComma(vRoomTypeBalancesRow.AmountPresentation) + """" + "," + 
										"""" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypePictureLink) + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypeInfoLink) + """" + Chars.LF;
										
										vAvailableRoomTypesByCheckInPeriodsRows.AvailableRoomTypesByCheckInPeriodsRow.Add(vRetRow);
										
										vAmount = 0;
										vFirstDaySum = 0;
									EndIf;
								EndDo;
							EndIf;
						EndIf;
						vRoomTypes.Clear();
						vCheckInHotel = ?(ЗначениеЗаполнено(vSameCheckOutDateRow.Гостиница), vSameCheckOutDateRow.Гостиница, vHotel);
						vCheckInDate = vSameCheckOutDateRow.CheckInDate;
						vCheckOutDate = vSameCheckOutDateRow.CheckOutDate;
						vCustomer = vSameCheckOutDateRow.Контрагент;
						vDuration = vSameCheckOutDateRow.Duration;
						vAllotmentDescription = СокрЛП(String(vSameCheckOutDateRow.Allotment));
						vAllotmentCode = СокрЛП(vSameCheckOutDateRow.Allotment.Code);
						vAgent = vSameCheckOutDateRow.Agent;
						vContract = vSameCheckOutDateRow.Contract;
						vLastQuota = vSameCheckOutDateRow.Allotment;
						vLastPeriodFrom = vSameCheckOutDateRow.CheckInDate;
						vLastPeriodTo = vSameCheckOutDateRow.CheckOutDate;
					EndIf;
					vRoomsAvailable = vSameCheckOutDateRow.RoomsRemains;
					vBedsAvailable = vSameCheckOutDateRow.BedsRemains;
					If vRoomTypes.Find(vSameCheckOutDateRow.RoomType, "ТипНомера") = Неопределено Тогда
						vNewRow = vRoomTypes.Add();
						vNewRow.ТипНомера = vSameCheckOutDateRow.RoomType;
						vNewRow.RoomsAvailable = vRoomsAvailable;
						vNewRow.BedsAvailable = vBedsAvailable;
					EndIf;
				EndDo;
				If vLastPeriodFrom <> Неопределено And vLastPeriodTo <> Неопределено And vLastQuota <> Неопределено Тогда
					If НЕ ЗначениеЗаполнено(vRoomRate.Allotment) Or ЗначениеЗаполнено(vRoomRate.Allotment) And (vRoomRate.Allotment.IsFolder And vLastQuota.BelongsToItem(vRoomRate.Allotment) Or (НЕ vRoomRate.Allotment.IsFolder) And vLastQuota = vRoomRate.Allotment) Тогда
						// Get ГруппаНомеров types balances table
						vRoomTypeBalances = cmGetRoomTypeBalancesTable(vRoomTypes, True, vCheckInHotel, vCheckInDate, vCheckOutDate, vClientType, vCustomer, vContract, vDiscountType, vExtHotelCode, vLanguage, pExternalSystemCode, , vRoomRate,, vAdultsQuantity, vKidsQuantity, vAgeArray, vProbeResObj);
						vCurRoomType = Неопределено;
						vAmount = 0;
						vFirstDaySum = 0;
						For Each vRoomTypeBalancesRow In vRoomTypeBalances Do
							If vCurRoomType <> vRoomTypeBalancesRow.ТипНомера Тогда
								vRetAccTypesList = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AccommodationTypesList"));
								vCurRoomType = vRoomTypeBalancesRow.ТипНомера;
							EndIf;
							
							vCurAccommodationType = vRoomTypeBalancesRow.ВидРазмещения;
							
							vRetAccTypeRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ВидРазмещения"));
							vRetAccTypeRow.Code = TrimR(vCurAccommodationType.Code);
							vRetAccTypeRow.Description = vCurAccommodationType.GetObject().pmGetAccommodationTypeDescription(vLanguage);
							vRetAccTypeRow.Age = vRoomTypeBalancesRow.Age;
							vRetAccTypeRow.ClientAgeFrom = vCurAccommodationType.AllowedClientAgeFrom;
							vRetAccTypeRow.ClientAgeTo = vCurAccommodationType.AllowedClientAgeTo;
							
							vAccTypeCurrency = vRoomTypeBalancesRow.Валюта;
							vRetAccTypeRow.Amount = ?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount);
							vRetAccTypeRow.AmountPresentation = cmFormatSum(?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount), vAccTypeCurrency, "NZ=");
							vRetAccTypeRow.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vAccTypeCurrency);
							If IsBlankString(vRetAccTypeRow.Валюта) Тогда
								vRetAccTypeRow.Валюта = СокрЛП(vAccTypeCurrency);
							EndIf;
							If ЗначениеЗаполнено(vAccTypeCurrency) Тогда
								vRetAccTypeRow.CurrencyCode = СокрЛП(vAccTypeCurrency.Code);
								vRetAccTypeRow.CurrencyDescription = СокрЛП(vAccTypeCurrency.Description);
							Else
								vRetAccTypeRow.CurrencyCode = "";
								vRetAccTypeRow.CurrencyDescription = "";
							EndIf;            	
							
							vRetAccTypesList.ВидРазмещения.Add(vRetAccTypeRow);

							vAmount = vAmount + ?(vRoomTypeBalancesRow.Amount = Неопределено, 0, vRoomTypeBalancesRow.Amount);
							vFirstDaySum = vFirstDaySum + ?(vRoomTypeBalancesRow.FirstDaySum = Неопределено, 0, vRoomTypeBalancesRow.FirstDaySum);
							If ((vRoomTypeBalances.IndexOf(vRoomTypeBalancesRow)+1) = vRoomTypeBalances.Count()) 
								Or vRoomTypeBalances[vRoomTypeBalances.IndexOf(vRoomTypeBalancesRow)+1].ТипНомера <> vRoomTypeBalancesRow.ТипНомера Тогда
								vRetRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "AvailableRoomTypesByCheckInPeriodsRow"));
								vRetRow.Гостиница = vRoomTypeBalancesRow.ExtHotelCode;
								vRetRow.ТипНомера = vRoomTypeBalancesRow.ExtRoomTypeCode;
								vRetRow.RoomTypeCode = vRoomTypeBalancesRow.RoomTypeCode;
								vRetRow.RoomTypeDescription = vRoomTypeBalancesRow.RoomTypeDescription;
								vRetRow.RoomTypePictureLink = vRoomTypeBalancesRow.RoomTypePictureLink;
								vRetRow.RoomTypeInfoLink = vRoomTypeBalancesRow.RoomTypeInfoLink;
								vRetRow.Тариф = cmGetObjectExternalSystemCodeByRef(vCheckInHotel, pExternalSystemCode, "Тарифы", vRoomRate);
								vRetRow.RoomRateCode = ?(ЗначениеЗаполнено(vRoomRate), СокрЛП(vRoomRate.Code), "");
								vRetRow.RoomRateDescription =  ?(ЗначениеЗаполнено(vRoomRate), СокрЛП(vRoomRate.Description), "");
								vRetRow.Валюта = vRoomTypeBalancesRow.ExtCurrencyCode;
								vRetRow.CurrencyCode = vRoomTypeBalancesRow.CurrencyCode;
								vRetRow.CurrencyDescription = vRoomTypeBalancesRow.CurrencyDescription;
								vRetRow.FirstDaySum = vFirstDaySum;
								vRetRow.Amount = vAmount;
								vRetRow.AmountPresentation = cmFormatSum(vAmount, vRoomTypeBalancesRow.Валюта, "NZ=");
								vRetRow.LimitedRoomsText = vRoomTypeBalancesRow.LimitedRoomsText;
								vRetRow.ОстаетсяНомеров = vRoomTypeBalancesRow.RoomsAvailable;
								vRetRow.ОстаетсяМест = vRoomTypeBalancesRow.BedsAvailable;
								vRetRow.Allotment = vAllotmentCode;
								vRetRow.AllotmentDescription = vAllotmentDescription;
								vRetRow.CheckInDate = vCheckInDate;
								vRetRow.Продолжительность = vDuration;
								vRetRow.ДатаВыезда = vCheckOutDate;
								If ЗначениеЗаполнено(vRoomRate) Тогда
									vRetRow.ReservationConditionsShort = Left(vRoomRate.ReservationConditionsShort, 2048);
									vRetRow.ReservationConditionsOnline = Left(vRoomRate.ReservationConditionsOnline, 2048);
									vRetRow.PaymentMethodCodesAllowedOnline = Left(СокрЛП(vRoomRate.PaymentMethodCodesAllowedOnline), 2048);
								Else
									vRetRow.ReservationConditionsShort = "";
									vRetRow.ReservationConditionsOnline = "";
									vRetRow.PaymentMethodCodesAllowedOnline = "";
								EndIf;
								vRetRow.AccommodationTypesList = vRetAccTypesList;
								
								vRetStr = vRetStr + """" + vRoomTypeBalancesRow.ExtHotelCode + """" + "," + """" + vRoomTypeBalancesRow.ExtRoomTypeCode + """" + "," + 
								"""" + СокрЛП(vRoomTypeBalancesRow.AccommodationTemplate.Code) + """" + "," + 
								Format(vRoomTypeBalancesRow.RoomsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + Format(vRoomTypeBalancesRow.BedsAvailable, "ND=10; NFD=0; NZ=; NG=; NN=") + "," + 
								"""" + vRoomTypeBalancesRow.ExtCurrencyCode + """" + "," + Format(vRoomTypeBalancesRow.FirstDaySum, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + Format(vRoomTypeBalancesRow.Amount, "ND=17; NFD=2; NDS=.; NZ=; NG=; NN=") + "," + 
								"""" + vRoomTypeBalancesRow.RoomTypeCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypeDescription) + """" + "," + 
								"""" + СокрЛП(vCurAccommodationType.Code) + """" + "," + """" + cmRemoveComma(СокрЛП(vCurAccommodationType.Description)) + """" + "," + 
								"""" + vRoomTypeBalancesRow.RoomRateCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomRateDescription) + """" + "," + 
								"""" + vRoomTypeBalancesRow.CurrencyCode + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.CurrencyDescription) + """" + "," + 
								"""" + cmRemoveComma(vRoomTypeBalancesRow.AmountPresentation) + """" + "," + 
								"""" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypePictureLink) + """" + "," + """" + cmRemoveComma(vRoomTypeBalancesRow.RoomTypeInfoLink) + """" + Chars.LF;
								
								vAvailableRoomTypesByCheckInPeriodsRows.AvailableRoomTypesByCheckInPeriodsRow.Add(vRetRow);
								
								vAmount = 0;
								vFirstDaySum = 0;
							EndIf;
						EndDo;
					EndIf;
				EndIf;
				vRetXDTO.AvailableRoomTypesByCheckInPeriodsRows = vAvailableRoomTypesByCheckInPeriodsRows;
			EndIf;
		EndDo;
	EndIf;
	
	WriteLogEvent(NStr("en='Get available ГруппаНомеров types';ru='Получить остатки свободных номеров';de='Restbestände an freien Zimmern erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	
	If vProbeResObj <> Неопределено Тогда
		For Each vCRRow In vProbeResObj.ChargingRules Do
			vFolioObj = vCRRow.ChargingFolio.GetObject();
			vFolioObj.Delete();
		EndDo;
		vProbeResObj = Неопределено;
	EndIf;

	Return vRetXDTO;
EndFunction //cmGetAvailableRoomTypes

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Function GetKidsSortedByAge(pAgeArray)
	vKids = New СписокЗначений;
	For Each vKid in pAgeArray Do
		vKids.Add(vKid);
	EndDo;
	vKids.SortByValue(SortDirection.Desc);
	Return vKids;
EndFunction //GetKidsSortedByAge

//-----------------------------------------------------------------------------
Function cmGetRoomTypesByGuestQuantity(pGuestsQuantity, pRoomType, pHotel) Экспорт
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ТипыНомеров.Ref AS ТипНомера,
	|	ТипыНомеров.КоличествоМестНомер AS КоличествоМестНомер,
	|	ТипыНомеров.КоличествоГостейНомер AS КоличествоГостейНомер
	|FROM
	|	Catalog.ТипыНомеров AS ТипыНомеров
	|WHERE
	|	ТипыНомеров.КоличествоГостейНомер >= &qNOP
	|	AND ТипыНомеров.Ref IN HIERARCHY(&qRoomType)
	|	AND NOT ТипыНомеров.DeletionMark
	|	AND NOT ТипыНомеров.IsFolder
	|	AND ТипыНомеров.Owner = &qHotel
	|
	|ORDER BY
	|	ТипыНомеров.ПорядокСортировки";
	vQry.SetParameter("qNOP", pGuestsQuantity);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vRoomTypes = vQry.Execute().Unload();
	Return vRoomTypes;
EndFunction //cmGetRoomTypesByGuestQuantity

//-----------------------------------------------------------------------------
Function GetAccommodationTemplatesByGuestsQuantity(pAdultsQuantity, pKidsQuantity, pKidsAgeList, pRoomType = Неопределено, pHotel = Неопределено)
	vAdultsQuantity = pAdultsQuantity;
	vKidsQuantity = pKidsQuantity;
	If pKidsAgeList <> Неопределено Тогда
		vKidsAgeList = pKidsAgeList.Copy();
	Else
		vKidsAgeList = New СписокЗначений;
	EndIf;
	vGuestsQuantity = vAdultsQuantity + vKidsQuantity;
	vQry = New Query;
	vQry.Text = 
	"ВЫБРАТЬ
	|	MAX(ВидыРазмещения.AllowedClientAgeTo) AS AllowedClientAgeTo
	|ИЗ
	|	Справочник.ВидыРазмещения КАК ВидыРазмещения
	|ГДЕ
	|	НЕ ВидыРазмещения.ЭтоГруппа
	|	И НЕ ВидыРазмещения.ПометкаУдаления";
	vQryResult = vQry.Execute().Unload();
	If vQryResult.Count() > 0 Тогда
		vAgeRangeToMax = vQryResult[0].AllowedClientAgeTo;
	EndIf;
	If vKidsAgeList <> Неопределено Тогда
		vDelInd = 0;
		For vInd = 0 To vKidsAgeList.Count()-1 Do
			vAge = vKidsAgeList.Get(vInd-vDelInd);
			If vAge.Value >= vAgeRangeToMax Тогда
				vAdultsQuantity = vAdultsQuantity + 1;
				vKidsQuantity = vKidsQuantity - 1;
				vKidsAgeList.Delete(vAge);
				vDelInd = vDelInd + 1;
			EndIf;
		EndDo;
	EndIf;
	vQry = New Query;
	vQry.Text = 
	"ВЫБРАТЬ
	|	AccommodationTemplatesRoomTypes.ТипНомера,
	|	AccommodationTemplatesRoomTypes.Ref
	|ПОМЕСТИТЬ AccTemplatesWithRT
	|ИЗ
	|	Справочник.ШаблоныРазмещения.ТипыНомеров КАК AccommodationTemplatesRoomTypes
	|ГДЕ
	|	НЕ AccommodationTemplatesRoomTypes.Ссылка.ПометкаУдаления
	|
	|СГРУППИРОВАТЬ ПО
	|	AccommodationTemplatesRoomTypes.Ref,
	|	AccommodationTemplatesRoomTypes.ТипНомера
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	AccommodationTemplates.Ссылка,
	|	&qRoomType КАК ТипНомера,
	|	AccTemplatesWithRT.Ref КАК RefNull
	|ПОМЕСТИТЬ AccTemplateRoomTypes
	|ИЗ
	|	Справочник.ШаблоныРазмещения КАК AccommodationTemplates
	|		ЛЕВОЕ СОЕДИНЕНИЕ AccTemplatesWithRT КАК AccTemplatesWithRT
	|		ПО AccommodationTemplates.Ref = AccTemplatesWithRT.Ref
	|ГДЕ
	|	AccTemplatesWithRT.Ref IS NULL 
	|	И НЕ AccommodationTemplates.ПометкаУдаления
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|SELECT
	|	AccTemplatesWithRT.Ref,
	|	AccTemplatesWithRT.ТипНомера,
	|	NULL
	|ИЗ
	|	AccTemplatesWithRT КАК AccTemplatesWithRT
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	AccommodationTemplatesAccTypes.Ref,
	|	AccommodationTemplatesAccTypes.ВидРазмещения
	|ПОМЕСТИТЬ AccTemplateAccTypes
	|FROM
	|	Catalog.ШаблоныРазмещения.ВидыРазмещений КАК AccommodationTemplatesAccTypes
	|ГДЕ
	|	НЕ AccommodationTemplatesAccTypes.Ссылка.ПометкаУдаления
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	AccommodationTemplates.Ref,
	|	AccommodationTemplates.Code,
	|	MAX(AccommodationTemplatesAccommodationTypes.LineNumber) AS AccTypesCount
	|ПОМЕСТИТЬ Total
	|ИЗ
	|	Справочник.ШаблоныРазмещения.ВидыРазмещений КАК AccommodationTemplatesAccommodationTypes
	|		ЛЕВОЕ СОЕДИНЕНИЕ Catalog.ШаблоныРазмещения КАК AccommodationTemplates
	|		ПО AccommodationTemplatesAccommodationTypes.Ref = AccommodationTemplates.Ref
	|ГДЕ
	|	НЕ AccommodationTemplatesAccommodationTypes.Ссылка.ПометкаУдаления
	|
	|СГРУППИРОВАТЬ ПО
	|	AccommodationTemplates.Ref,
	|	AccommodationTemplates.Code
	|
	|ИМЕЮЩИЕ
	|	MAX(AccommodationTemplatesAccommodationTypes.LineNumber) = &qGuestsQuantity
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Total.Ref,
	|	Total.Code,
	|	Total.AccTypesCount,
	|	AccTemplateRoomTypes.ТипНомера,
	|	AccTemplateAccTypes.ВидРазмещения
	|ИЗ
	|	Total AS Total
	|		ЛЕВОЕ СОЕДИНЕНИЕ AccTemplateRoomTypes КАК AccTemplateRoomTypes
	|		ПО (AccTemplateRoomTypes.Ref = Total.Ref)
	|		ЛЕВОЕ СОЕДИНЕНИЕ AccTemplateAccTypes КАК AccTemplateAccTypes
	|		ПО (AccTemplateAccTypes.Ref = Total.Ref)
	|ГДЕ
	|	&qRoomTypeIsFilled И AccTemplateRoomTypes.ТипНомера = &qRoomType ИЛИ  НЕ &qRoomTypeIsFilled
	|
	|ORDER BY
	|	Total.Code,
	|	AccTemplateRoomTypes.ТипНомера.ПорядокСортировки,
	|	AccTemplateAccTypes.ВидРазмещения.ПорядокСортировки";
	vQry.SetParameter("qGuestsQuantity", vGuestsQuantity);
	vQry.SetParameter("qEmptyAT", Справочники.ШаблоныРазмещения.ПустаяСсылка());
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoomTypeIsFilled", ЗначениеЗаполнено(pRoomType));
	vAccTemplatesList = vQry.Execute().Unload();
	vArrayToDelete = New Array;
	vAccTemplatesList.Columns.Add("Age", cmGetNumberTypeDescription(10, 0));
	vAccTemplatesList.Columns.Add("IsMain", cmGetNumberTypeDescription(10, 0));
	If vAccTemplatesList.Count() > 0 Тогда
		vLastAT = Неопределено;
		vError = False;
		vFirstATIndex = 0;
		For Each vAccRow In vAccTemplatesList Do
			If vLastAT <> vAccRow.Ссылка Тогда
				vLastAT = vAccRow.Ссылка;
				vATAdultInd = vAdultsQuantity;
				vATKidInd = vKidsQuantity;
				vTogetherIndex = 0;
				If vError Тогда
					vLastATIndex = vAccTemplatesList.IndexOf(vAccRow)-1;
					For vATInd = vFirstATIndex To vLastATIndex Do
						vArrayToDelete.Add(vAccTemplatesList.Get(vATInd));
					EndDo;
				EndIf;
				vFirstATIndex = vAccTemplatesList.IndexOf(vAccRow);
				vError = False;
			EndIf;
			
			If vAccRow.AccommodationType.AllowedClientAgeTo = 0 Тогда
				If vAccRow.AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.Совместно Or vAccRow.AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.ДополнительноеМесто Тогда
					vTogetherIndex = vTogetherIndex + 1;
				EndIf;
				If vATAdultInd = 0 Тогда
					If vTogetherIndex > 0 Тогда
						vTogetherIndex = vTogetherIndex - 1;
					Else
						vError = True;
					EndIf;
				Else
					If vTogetherIndex > 0 Тогда
						vTogetherIndex = vTogetherIndex - 1;
					EndIf;
					vATAdultInd = vATAdultInd - 1;
				EndIf;
			Else
				If vATKidInd = 0 Тогда
					If vTogetherIndex > 0 Тогда
						vTogetherIndex = vTogetherIndex - 1;
					Else
						vError = True;
					EndIf;
				Else
					vATKidInd = vATKidInd - 1;
				EndIf;
			EndIf;
		EndDo;
		If vError Тогда
			vLastATIndex = vAccTemplatesList.IndexOf(vAccRow);
			For vATInd = vFirstATIndex To vLastATIndex Do
				vArrayToDelete.Add(vAccTemplatesList.Get(vATInd));
			EndDo;
		EndIf;
		For Each vDelItem In vArrayToDelete Do
			vAccTemplatesList.Delete(vDelItem);
		EndDo;
		vArrayToDelete.Clear();
		If vKidsQuantity > 0 Тогда
			// Try to find suitable template
			vWrkKidsAgeList = vKidsAgeList.Copy();
			vAdultInd = vAdultsQuantity;
			vKidInd = vKidsQuantity;
			vLastAccTempRef = Справочники.ШаблоныРазмещения.EmptyRef();
			vMainAccTempRef = Справочники.ШаблоныРазмещения.EmptyRef();
			For Each vRow In vAccTemplatesList Do
				If vLastAccTempRef <> vRow.Ref Тогда
					If ЗначениеЗаполнено(vLastAccTempRef) Тогда
						// Check results
						If vAdultInd = 0 And vWrkKidsAgeList.Count() = 0 Тогда
							vMainAccTempRef = vLastAccTempRef;
							Break;
						EndIf;
					EndIf;
					vLastAccTempRef = vRow.Ref;
					vWrkKidsAgeList = vKidsAgeList.Copy();
					vAdultInd = vAdultsQuantity;
					vKidInd = vKidsQuantity;
				EndIf;
				If vRow.AccommodationType.AllowedClientAgeTo <> 0 Тогда
					vKidWasFound = False;
					For Each vAge In vWrkKidsAgeList Do
						If vRow.AccommodationType.AllowedClientAgeTo > vAge.Value And 
						   (vRow.AccommodationType.AllowedClientAgeFrom < vAge.Value Or vRow.AccommodationType.AllowedClientAgeFrom = 0 And vAge.Value = 0) Тогда
							vKidInd = vKidInd - 1;
							vRow.Age = vAge.Value;
							vWrkKidsAgeList.Delete(vAge);
							vKidWasFound = True;
							Break;
						EndIf;
					EndDo;
					If НЕ vKidWasFound Тогда
						vAdultInd = vAdultInd - 1;
					EndIf;
				Else
					vAdultInd = vAdultInd - 1;
				EndIf;
			EndDo;
			If ЗначениеЗаполнено(vLastAccTempRef) Тогда
				// Check results
				If vAdultInd = 0 And vWrkKidsAgeList.Count() = 0 Тогда
					vMainAccTempRef = vLastAccTempRef;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(vMainAccTempRef) Тогда
				i = 0;
				While i < vAccTemplatesList.Count() Do
					vRow = vAccTemplatesList.Get(i);
					If vRow.Ref <> vMainAccTempRef Тогда
						vAccTemplatesList.Delete(i);
					Else
						vRow.IsMain = 0;
						i = i + 1;
					EndIf;
				EndDo;
				Return vAccTemplatesList;
			EndIf;
			// Try to find any suitable template
			vAdultInd = vAdultsQuantity;
			vKidInd = vKidsQuantity;
			vAddKidInd = vKidsQuantity;
			vMinAddKidInd = vKidsQuantity;
			vInd = 0;
			//vLastRT = Справочники.ТипыНомеров.EmptyRef();
			vLastAccTempRef = Справочники.ШаблоныРазмещения.EmptyRef();
			vMainAccTempRef = Справочники.ШаблоныРазмещения.EmptyRef();
			For Each vRow In vAccTemplatesList Do
				vArrayToDelete.Add(vRow);
				vRow.IsMain = 1;
				If vLastAccTempRef <> vRow.Ref Тогда
					vWrkKidsAgeList = vKidsAgeList.Copy();
					If vAddKidInd < vKidsQuantity And vAddKidInd < vMinAddKidInd Тогда
						vMainAccTempRef = vLastAccTempRef;
					EndIf;
					If vAddKidInd < vMinAddKidInd Тогда
						vMinAddKidInd = vAddKidInd;
					EndIf;
					vAddKidInd = vKidsQuantity;
					vLastAccTempRef = vRow.Ref;
				EndIf;
				If vRow.AccommodationType.AllowedClientAgeTo = 0 Тогда
					If vAdultInd = 0 And (vRow.AccommodationType.ТипРазмещения <> Перечисления.ВидыРазмещений.Together AND vRow.AccommodationType.ТипРазмещения <> Перечисления.AccomodationTypes.AdditionalBed) Тогда
						vAdultInd = vAdultInd - 1;
					EndIf;
				EndIf;
				If vRow.AccommodationType.AllowedClientAgeTo > 0 Or (vRow.AccommodationType.AllowedClientAgeTo = 0 And vAdultInd = 0 And (vRow.AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.Together or vRow.AccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.AdditionalBed)) Тогда
					For Each vAge In vWrkKidsAgeList Do
						If vRow.AccommodationType.AllowedClientAgeTo > vAge.Value Or (vRow.AccommodationType.AllowedClientAgeTo = 0 And vAdultInd = 0 And (vRow.AccommodationType.ТипРазмещения = Перечисления.ВидыРазмещений.Together or vRow.AccommodationType.ТипРазмещения = Перечисления.AccomodationTypes.AdditionalBed)) Тогда
							If vRow.AccommodationType.AllowedClientAgeTo > vAge.Value Тогда
								vAddKidInd = vAddKidInd - 1;
							EndIf;
							vKidInd = vKidInd - 1;
							vRow.Age = vAge.Value;
							vWrkKidsAgeList.Delete(vAge);
							Break;
						EndIf;
					EndDo;
				EndIf;
				If vRow.AccommodationType.AllowedClientAgeTo = 0 Тогда
					If vAdultInd > 0 Тогда
						vAdultInd = vAdultInd - 1;
					EndIf;
				EndIf;
				vInd = vInd + 1;
				If vInd = vGuestsQuantity Тогда
					If vKidInd = 0 And vAdultInd = 0 Тогда
						vCount = vArrayToDelete.Count();
						For vDelInd = 1 To vGuestsQuantity Do
							vArrayToDelete.Delete(vCount - vDelInd);
						EndDo;
					EndIf;
					vAdultInd = vAdultsQuantity;
					vKidInd = vKidsQuantity;
					vInd = 0;
				EndIf;
			EndDo;
			If ЗначениеЗаполнено(vLastAccTempRef) Тогда
				If vAddKidInd < vKidsQuantity And vAddKidInd < vMinAddKidInd Тогда
					vMainAccTempRef = vLastAccTempRef;
				EndIf;
			EndIf;
			For Each vItem In vArrayToDelete Do
				vAccTemplatesList.Delete(vItem);
			EndDo;
			If ЗначениеЗаполнено(vMainAccTempRef) Тогда
				vFindedRows = vAccTemplatesList.FindRows(New Structure("Ref", vMainAccTempRef));
				For Each vFindedRow In vFindedRows Do
					vFindedRow.IsMain = 0;
				EndDo;
			EndIf;
		EndIf;
	EndIf;
	Return vAccTemplatesList;
EndFunction //GetAccommodationTemplatesByGuestsQuantity

//-----------------------------------------------------------------------------
// Description: Returns annulation status for the given annulation
//-----------------------------------------------------------------------------
Function cmGetReservationAnnulationStatus(pDocRef) Экспорт
	vAnnulationStatus = Справочники.СтатусБрони.EmptyRef();
	// Try to find annulation reservation status
	vStatuses = cmGetAllReservationStatuses(True);
	For Each vStatusesRow In vStatuses Do
		vStatusRef = vStatusesRow.ReservationStatus;
		If НЕ vStatusRef.IsActive And 
		   НЕ vStatusRef.ЭтоЗаезд And 
		   НЕ vStatusRef.IsInWaitingList And 
		   НЕ vStatusRef.IsNoShow And 
		   НЕ vStatusRef.IsPreliminary Тогда
			vAnnulationStatus = vStatusRef;
			Break;
		EndIf;
	EndDo;
	If ЗначениеЗаполнено(pDocRef) And TypeOf(pDocRef) = Type("DocumentRef.Бронирование") Тогда
		If ЗначениеЗаполнено(pDocRef.ШтрафыУсловия) Тогда
			vFeeTerms = pDocRef.ШтрафыУсловия;
		ElsIf ЗначениеЗаполнено(pDocRef.Договор) And ЗначениеЗаполнено(pDocRef.Договор.ШтрафыУсловия) Тогда
			vFeeTerms = pDocRef.Договор.ШтрафыУсловия;
		ElsIf ЗначениеЗаполнено(pDocRef.Контрагент) And ЗначениеЗаполнено(pDocRef.Контрагент.ШтрафыУсловия) Тогда
			vFeeTerms = pDocRef.Контрагент.ШтрафыУсловия;
		ElsIf ЗначениеЗаполнено(pDocRef.Тариф) And ЗначениеЗаполнено(pDocRef.Тариф.ШтрафыУсловия) Тогда
			vFeeTerms = pDocRef.Тариф.ШтрафыУсловия;
		EndIf;
		If ЗначениеЗаполнено(vFeeTerms) And ЗначениеЗаполнено(vFeeTerms.LateAnnulationStatus) And vFeeTerms.LateAnnulationPeriod > 0 Тогда
			If (pDocRef.CheckInDate - CurrentDate())/(24*3600) < vFeeTerms.LateAnnulationPeriod Тогда
				vAnnulationStatus = vFeeTerms.LateAnnulationStatus;
			EndIf;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(vAnnulationStatus) Тогда
		ВызватьИсключение NStr("en='There is no reservation annulation status defined in system!';ru='В справочнике статусов брони не найден статус аннуляции брони!';de='Im Verzeichnis der Reservierungsstatus wurde kein Reservierungsstorno-Status gefunden!'");
	EndIf;
	Return vAnnulationStatus;
EndFunction //cmGetReservationAnnulationStatus

//-----------------------------------------------------------------------------
// Description: Returns annulation status for the given annulation
//-----------------------------------------------------------------------------
Function cmGetAccommodationAnnulationStatus(pDocRef) Экспорт
	vAnnulationStatus = Справочники.СтатусРазмещения.EmptyRef();
	// Try to find annulation reservation status
	vStatuses = cmGetAllAccommodationStatuses();
	For Each vStatusesRow In vStatuses Do
		vStatusRef = vStatusesRow.СтатусРазмещения;
		If НЕ vStatusRef.IsActive And 
		   НЕ vStatusRef.ЭтоЗаезд And 
		   НЕ vStatusRef.IsRoomChange And 
		   НЕ vStatusRef.ЭтоВыезд Тогда
			vAnnulationStatus = vStatusRef;
			Break;
		EndIf;
	EndDo;
	If НЕ ЗначениеЗаполнено(vAnnulationStatus) Тогда
		ВызватьИсключение NStr("en='There is no accommodation annulation status defined in system!';ru='В справочнике статусов размещения гостей не найден статус аннуляции!';de='Im Verzeichnis der Unterbringungsstatus wurde kein Storno-Status gefunden!'");
	EndIf;
	Return vAnnulationStatus;
EndFunction //cmGetAccommodationAnnulationStatus

//-----------------------------------------------------------------------------
// Description: Checks if accommodation type could be used for the given guest age
//-----------------------------------------------------------------------------
Function cmCheckGuestDateOfBirth(pDateOfBirth, pAccommodationType, pCheckInDate, pCheckOutDate, pHotel = Неопределено) Экспорт
	If pHotel = Неопределено Тогда
		pHotel = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	vCheckDate = pCheckInDate;
	vAge = 0;
	//Get guest age on check moment
	vAge = Year(vCheckDate)-Year(pDateOfBirth);
	If (Month(vCheckDate)-Month(pDateOfBirth)) < 0 Тогда
		vAge = vAge + 1;
	EndIf;
	If pAccommodationType.AllowedClientAgeFrom < vAge And pAccommodationType.AllowedClientAgeTo > vAge Тогда
		Return True;
	EndIf;
	Return False;
EndFunction //cmCheckGuestDateOfBirth

//-----------------------------------------------------------------------------
// Description: Returns value table with accommodation types and ages
//-----------------------------------------------------------------------------
Function cmGetAvailableAccommodationTypesWithKidsAges(pAdultsQuantity, pKidsQuantity, pAgeArray, pExternalSystemCode, pHotel, pRoomType, pAccommodationTypes = Неопределено, pOnlyTheFirstTemplate = False) Экспорт
	vHotel = pHotel;
	vRoomType = pRoomType;
    			
	// Adults quantity
	vAdultsQuantity = pAdultsQuantity;
	// Kids quantity
	vKidsQuantity = pKidsQuantity;
	// Guests quantity
	vGuestsQuantity = vAdultsQuantity + vKidsQuantity;
	
	vKidsAgeList = New СписокЗначений;
	If vKidsQuantity > 0 Тогда
		vKidsAgeList = GetKidsSortedByAge(pAgeArray);
	EndIf;

	// Get accommodation template ref
	vAccTemplate = GetAccommodationTemplatesByGuestsQuantity(vAdultsQuantity, vKidsQuantity, vKidsAgeList, vRoomType);
	
	// Join both tables
	vQry = New Query;
	If pAccommodationTypes = Неопределено Тогда
		vQry.Text =
		"SELECT
		|	Templates.Ссылка AS Ref,
		|	Templates.IsMain AS IsMain,
		|	Templates.ТипНомера AS ТипНомера,
		|	Templates.Код AS Code,
		|	Templates.ВидРазмещения AS ВидРазмещения,
		|	Templates.Age AS Age
		|INTO Templates
		|FROM
		|	&qTemplates AS Templates
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT  
		|	Templates.Ref AS AccTemplate,
		|	Templates.ВидРазмещения AS ВидРазмещения,
		|	Templates.Age AS Age,
		|	0 AS Amount,
		|	&qEmptyString AS AmountPresentation,
		|	&qEmptyCurrency AS Валюта
		|FROM
		|	Templates AS Templates
		|WHERE
		|	Templates.ТипНомера.Owner = &qHotel
		|	AND	Templates.ТипНомера = &qRoomType
		|ORDER BY
		|	Templates.IsMain,
		|	Templates.Ref.Code,
		|	Templates.ВидРазмещения.ПорядокСортировки";
		vQry.SetParameter("qTemplates", vAccTemplate);
		vQry.SetParameter("qRoomType", vRoomType);
	Else
		vQry.Text =
		"SELECT
		|	AccTypes.ВидРазмещения AS ВидРазмещения
		|INTO AccTypes
		|FROM
		|	&qAccTypes AS AccTypes
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT  
		|	&qEmptyTemplate AS AccTemplate,
		|	AccTypes.ВидРазмещения AS ВидРазмещения,
		|	0 AS Age,
		|	0 AS Amount,
		|	&qEmptyString AS AmountPresentation,
		|	&qEmptyCurrency AS Валюта
		|FROM
		|	AccTypes AS AccTypes
		|ORDER BY
		|	AccTypes.ВидРазмещения.ПорядокСортировки";
		vQry.SetParameter("qAccTypes", pAccommodationTypes);
		vQry.SetParameter("qEmptyTemplate", Справочники.ШаблоныРазмещения.EmptyRef());
	EndIf;
	vQry.SetParameter("qHotel", vHotel);
	vQry.SetParameter("qEmptyCurrency", Справочники.Валюты.EmptyRef());
	vQry.SetParameter("qEmptyString", "");
	vAccTypesWithAgeList = vQry.Execute().Unload();
	If pOnlyTheFirstTemplate And vAccTypesWithAgeList.Count() > 0 Тогда
		vLastTemplateRef = Справочники.ШаблоныРазмещения.EmptyRef();
		vRowsToDeleteArray = New Array;
		For Each vRow In vAccTypesWithAgeList Do
			If vLastTemplateRef = Справочники.ШаблоныРазмещения.EmptyRef() Тогда
				vLastTemplateRef = vRow.AccTemplate;
			EndIf;
			If vLastTemplateRef <> Справочники.ШаблоныРазмещения.EmptyRef() And vLastTemplateRef <> vRow.AccTemplate Тогда
				vRowsToDeleteArray.Add(vRow);
			EndIf;
		EndDo;
		For Each vItem In vRowsToDeleteArray Do
			vAccTypesWithAgeList.Delete(vItem);
		EndDo;
	EndIf;
	If vAccTypesWithAgeList.Count() = 0 And cmGetAllAccommodationTemplates(vHotel).Count() = 0 Тогда
		// Adults
		vAdultsQuantityInd = pAdultsQuantity;
		// Kids
		vKidsQuantityInd = pKidsQuantity;
		vQry = New Query;
		vQryMainText = 
		"SELECT 
		|	ВидыРазмещений.Ref AS Ref
		|FROM
		|	Catalog.ВидыРазмещения AS ВидыРазмещений
		|WHERE
		|	ВидыРазмещений.ТипРазмещения = &qType ";
		vQryOrderText =
		" AND NOT ВидыРазмещений.ПометкаУдаления
		|	AND NOT ВидыРазмещений.ЭтоГруппа
		|
		|ORDER BY
		|	ВидыРазмещений.ПорядокСортировки";
		vQry.Text = vQryMainText + " AND ВидыРазмещений.NumberOfPersons4Reservation >= &qNOP4Reserv " + vQryOrderText;
		vQry.SetParameter("qType", Перечисления.ВидыРазмещений.Номер);
		vQry.SetParameter("qNOP4Reserv", vAdultsQuantityInd);
		vAccList = vQry.Execute().Unload();
		If vAccList.Count() = 0 Тогда
			vQry.Text = vQryMainText + vQryOrderText;
			vQry.SetParameter("qType", Перечисления.ВидыРазмещений.Номер);
			vAccList = vQry.Execute().Unload();
		EndIf;
		If vAccList.Count() > 0 Тогда
			vNewGuest = vAccTypesWithAgeList.Add();
			vNewGuest.Age = 0;
			If vGuestsQuantity > 1 Тогда
				If vGuestsQuantity = 2 And vAccList.Count() > 1 Тогда
					vNewGuest.ВидРазмещения = vAccList[1].Ref;
				ElsIf vGuestsQuantity = 3 And vAccList.Count() > 2 Тогда
					vNewGuest.ВидРазмещения = vAccList[2].Ref;
				ElsIf vGuestsQuantity = 4 And vAccList.Count() > 3 Тогда
					vNewGuest.ВидРазмещения = vAccList[3].Ref;
				Else
					vNewGuest.ВидРазмещения = vAccList[vAccList.Count()-1].Ref;
				EndIf;
			Else
				vNewGuest.ВидРазмещения = vAccList[0].Ref;
			EndIf;
			vAdultsQuantityInd = vAdultsQuantityInd - 1;
		EndIf;
		vKids = vKidsAgeList.Copy();
		For vInd = 2 To vRoomType.КоличествоМестНомер Do
			vQry.Text = vQryMainText + vQryOrderText;
			vQry.SetParameter("qType", Перечисления.ВидыРазмещений.Совместно);
			vAccList = vQry.Execute().Unload();
			vAge = 0;
			If vAdultsQuantityInd = 0 Тогда
				If vKidsQuantityInd > 0 Тогда
					vAge = vKids[0].Value;
					vKids.Delete(0);
					vKidsQuantityInd = vKidsQuantityInd - 1;
				Else
					Break;
				EndIf;
			Else
				vAdultsQuantityInd = vAdultsQuantityInd - 1;
			EndIf;
			If vAccList.Count() > 0 Тогда
				vNewGuest = vAccTypesWithAgeList.Add();
				vNewGuest.Age = vAge;
				vNewGuest.ВидРазмещения = vAccList[0].Ref;
			EndIf;
		EndDo;
		vAddGuestsQuantity = vAdultsQuantityInd + vKidsQuantityInd;
		If vAddGuestsQuantity > 0 Тогда
			If (vRoomType.КоличествоГостейНомер - vRoomType.КоличествоМестНомер)>vAddGuestsQuantity Тогда
				vAdditionalBedsQuantity = vAddGuestsQuantity
			Else
				vAdditionalBedsQuantity = vRoomType.КоличествоГостейНомер - vRoomType.КоличествоМестНомер;
			EndIf;
			For vInd = 1 To vAdditionalBedsQuantity Do
				vAge = 0;
				If vAdultsQuantityInd > 0 Тогда
					vQry.Text = vQryMainText + vQryOrderText;
					vQry.SetParameter("qType", Перечисления.ВидыРазмещений.ДополнительноеМесто);
					vAccList = vQry.Execute().Unload();
					vAdultsQuantityInd = vAdultsQuantityInd - 1;
				Else
					If vKidsQuantityInd > 0 Тогда
						vAge = vKids[0].Value;
						vKids.Delete(0);
						vQry.Text = vQryMainText + " AND ВидыРазмещения.AllowedClientAgeFrom < &qClientAge
						|	AND ВидыРазмещения.AllowedClientAgeTo > &qClientAge "
						+ vQryOrderText;
						vQry.SetParameter("qType", Перечисления.ВидыРазмещений.ДополнительноеМесто);
						vQry.SetParameter("qClientAge", vAge);
						vAccList = vQry.Execute().Unload();
						If vAccList.Count() = 0 Тогда
							vQry.Text = vQryMainText + vQryOrderText;
							vQry.SetParameter("qType", Перечисления.ВидыРазмещений.ДополнительноеМесто);
							vAccList = vQry.Execute().Unload();
						EndIf;
						vKidsQuantityInd = vKidsQuantityInd - 1;
					Else
						Break;
					EndIf;
				EndIf;
				If vAccList.Count() > 0 Тогда
					vNewGuest = vAccTypesWithAgeList.Add();
					vNewGuest.Age = vAge;
					vNewGuest.ВидРазмещения = vAccList[0].Ref;
				EndIf;	
			EndDo;
		EndIf;
	EndIf;
	Return vAccTypesWithAgeList;
EndFunction //cmGetAvailableAccommodationTypesWithKidsAges

//-----------------------------------------------------------------------------
// Description: Returns ГруппаНомеров types balances table with calculated prices
//-----------------------------------------------------------------------------
Function cmGetRoomTypeBalancesTable(pRoomTypes, pExtRoomTypesTable = True, pHotel = Неопределено, pPeriodFrom, pPeriodTo, pClientType = Неопределено, pCustomer = Неопределено, pContract = Неопределено, pDiscountType = Неопределено, pExtHotelCode = Неопределено, pLanguage = Неопределено, pExternalSystemCode = Неопределено, pRoomType = Неопределено, pRoomRate = Неопределено, pAccommodationTypes = Неопределено, pAdultsQuantity, pKidsQuantity, pAgeArray, pProbeResObj = Неопределено) Экспорт
	// Retrieve language
	vLanguage = pLanguage;
	If pLanguage = Неопределено Тогда
		vLanguage = cmGetLanguageByCode("");
	EndIf;
	vAdultsQuantity = pAdultsQuantity; 
	vKidsQuantity = pKidsQuantity; 
	vAgeArray = pAgeArray;
	//vGuestsQuantity = vAdultsQuantity + vKidsQuantity;
	// Retrieve parameter references based on codes
	vHotel = pHotel;
	If pHotel = Неопределено Тогда
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	vExtHotelCode = pExtHotelCode;
	If pExtHotelCode = Неопределено Тогда
		vExtHotelCode = "";
	EndIf;
	vExternalSystemCode = pExternalSystemCode;
	If pExternalSystemCode = Неопределено Тогда
		vExternalSystemCode = "";
	EndIf;
	vClientType = pClientType;
	If pClientType = Неопределено Тогда
		vClientType = Справочники.ТипыКлиентов.EmptyRef();
	EndIf;
	vRoomRate = pRoomRate;
	If pRoomRate = Неопределено Тогда
		vRoomRate = Справочники.Тарифы.EmptyRef();
	EndIf;
	vDiscountType = pDiscountType;
	If pDiscountType = Неопределено Тогда
		vDiscountType = Справочники.ТипыСкидок.EmptyRef();
	EndIf;
	vCustomer = pCustomer;
	If pCustomer = Неопределено Тогда
		vCustomer = Справочники.Контрагенты.EmptyRef();
	EndIf;
	vContract = pContract;
	If pContract = Неопределено Тогда
		vContract = Справочники.Договора.EmptyRef();
	EndIf;
	
	// Add columns with hotel, ГруппаНомеров type, accommodation type and calendar day type external codes
	If pExtRoomTypesTable Тогда
		vRoomTypeBalances = New ValueTable();
		vRoomTypeBalances.Columns.Add("ExtHotelCode", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("ExtRoomTypeCode", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
		vRoomTypeBalances.Columns.Add("RoomTypeCode", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("RoomTypeDescription", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("ExtRoomRateCode", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("Тариф", cmGetCatalogTypeDescription("Тарифы"));
		vRoomTypeBalances.Columns.Add("RoomRateCode", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("RoomRateDescription", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("Валюта", cmGetCatalogTypeDescription("Валюты"));
		vRoomTypeBalances.Columns.Add("ExtCurrencyCode", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("CurrencyCode", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("CurrencyDescription", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("AccommodationTemplate", cmGetCatalogTypeDescription("ШаблоныРазмещения"));
		vRoomTypeBalances.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
		vRoomTypeBalances.Columns.Add("FirstDaySum", cmGetNumberTypeDescription(17, 2));
		vRoomTypeBalances.Columns.Add("Amount", cmGetNumberTypeDescription(17, 2));
		vRoomTypeBalances.Columns.Add("AmountPresentation", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("RoomTypePictureLink", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("RoomTypeInfoLink", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("RoomsAvailable", cmGetNumberTypeDescription(10, 0));
		vRoomTypeBalances.Columns.Add("BedsAvailable", cmGetNumberTypeDescription(10, 0));
		vRoomTypeBalances.Columns.Add("LimitedRoomsText", cmGetStringTypeDescription());
		vRoomTypeBalances.Columns.Add("Age", cmGetNumberTypeDescription(3, 0));
	EndIf;
	
	// Build probe reservation object to calaculate services
	If pProbeResObj <> Неопределено Тогда
		vProbeResObj = pProbeResObj;
		vProbeResObj.OccupationPercents.Clear();
	Else
		vProbeResObj = Documents.Бронирование.CreateDocument();
		vProbeResObj.Гостиница = vHotel;
		//vProbeResObj.pmFillAttributesWithDefaultValues(True);
	EndIf;
	vProbeResObj.ДатаЦены = Неопределено;
	vProbeResObj.Продолжительность = vProbeResObj.pmCalculateDuration();
	vProbeResObj.ТипКлиента = vClientType;
	vProbeResObj.Контрагент = vCustomer;
	vProbeResObj.Договор = vContract;

	If vRoomRate <> Неопределено Тогда
		vProbeResObj.Тариф = vRoomRate;
	EndIf;

	If ЗначениеЗаполнено(vProbeResObj.Договор) And ЗначениеЗаполнено(vProbeResObj.Договор.ВидКомиссииАгента) Тогда
		// Agent commission
		vProbeResObj.Агент = vProbeResObj.Договор.Агент;
		If ЗначениеЗаполнено(vProbeResObj.Контрагент) And ЗначениеЗаполнено(vProbeResObj.Договор.ВидКомиссииАгента) Тогда
			If НЕ ЗначениеЗаполнено(vProbeResObj.Агент) Тогда
				vProbeResObj.Агент = vProbeResObj.Контрагент;
			EndIf;
			vProbeResObj.КомиссияАгента = vProbeResObj.Договор.КомиссияАгента;
			vProbeResObj.ВидКомиссииАгента = vProbeResObj.Договор.ВидКомиссииАгента;
			vProbeResObj.КомиссияАгентУслуги = vProbeResObj.Договор.КомиссияАгентУслуги;
		EndIf;
		If НЕ ЗначениеЗаполнено(vProbeResObj.Агент) Тогда
			vProbeResObj.КомиссияАгента = 0;
			vProbeResObj.ВидКомиссииАгента = Неопределено;
			vProbeResObj.КомиссияАгентУслуги = Справочники.НаборыУслуг.EmptyRef();
		EndIf;
		// ГруппаНомеров rate
		vChangeRR = False;
		If ЗначениеЗаполнено(vProbeResObj.Тариф) Тогда
			vFindedRR = vProbeResObj.Договор.Тарифы.Find(vProbeResObj.Тариф, "Тариф");
			If vFindedRR = Неопределено And vProbeResObj.Тариф <> vProbeResObj.Договор.Тариф Тогда
				vChangeRR = True;
			EndIf;
		Else
			vChangeRR = True;
		EndIf;
		If vChangeRR Тогда
			If ЗначениеЗаполнено(vProbeResObj.Договор.Тариф) Тогда
				vProbeResObj.Тариф = vProbeResObj.Договор.Тариф;
				vProbeResObj.RoomRateServiceGroup = vProbeResObj.Договор.RoomRateServiceGroup;
			ElsIf ЗначениеЗаполнено(vProbeResObj.Контрагент) And ЗначениеЗаполнено(vProbeResObj.Контрагент.Тариф) Тогда
				vProbeResObj.Тариф = vProbeResObj.Контрагент.Тариф;
				vProbeResObj.RoomRateServiceGroup = vProbeResObj.Контрагент.RoomRateServiceGroup;
			ElsIf ЗначениеЗаполнено(vProbeResObj.Гостиница) And ЗначениеЗаполнено(vProbeResObj.Гостиница.Тариф) Тогда
				vProbeResObj.Тариф = vProbeResObj.Гостиница.Тариф;
				vProbeResObj.RoomRateServiceGroup = vProbeResObj.Гостиница.RoomRateServiceGroup;
			EndIf;
			// Client type
			If ЗначениеЗаполнено(vProbeResObj.Тариф) And ЗначениеЗаполнено(vProbeResObj.Тариф.ТипКлиента) Тогда
				vProbeResObj.ТипКлиента = vProbeResObj.Тариф.ТипКлиента;
				vProbeResObj.СтрокаПодтверждения = vProbeResObj.Тариф.СтрокаПодтверждения;
			EndIf;
		EndIf;
		// Client type
		If ЗначениеЗаполнено(vProbeResObj.Договор.ТипКлиента) Тогда
			vProbeResObj.ТипКлиента = vProbeResObj.Договор.ТипКлиента;
			vProbeResObj.СтрокаПодтверждения = vProbeResObj.Договор.СтрокаПодтверждения;
		EndIf;
		// Charging rules
		vProbeResObj.pmLoadChargingRules(vProbeResObj.Договор);
	EndIf;
	vProbeResObj.pmSetDiscounts();
	If ЗначениеЗаполнено(vDiscountType) Тогда
		vProbeResObj.ТипСкидки = vDiscountType;
		vProbeResObj.DiscountServiceGroup = vDiscountType.DiscountServiceGroup;
		vProbeResObj.Скидка = vProbeResObj.ТипСкидки.GetObject().pmGetDiscount(vProbeResObj.CheckInDate, , vProbeResObj.Гостиница);
	EndIf;
	vReferenceHour = cmGetReferenceHour(vProbeResObj.Тариф);
	vCheckInTime = cmGetDefaultCheckInTime(vProbeResObj.Тариф);
	vPeriodFrom = BegOfDay(pPeriodFrom)+(vCheckInTime-BegOfDay(vCheckInTime));
	vPeriodTo = BegOfDay(pPeriodTo)+(vReferenceHour-BegOfDay(vReferenceHour));
	If pPeriodFrom = pPeriodTo Тогда
		vPeriodTo = EndOfDay(pPeriodTo);
	EndIf;
	vProbeResObj.CheckInDate = cm1SecondShift(vPeriodFrom);
	vProbeResObj.ДатаВыезда = cm0SecondShift(vPeriodTo);
	vProbeResObj.Продолжительность = vProbeResObj.pmCalculateDuration();
	// Do for each ГруппаНомеров type in balances
	vCurrency = vHotel.Валюта;
	If pExtRoomTypesTable Тогда
		vLastRoomType = Справочники.ТипыНомеров.EmptyRef();
		For Each vRoomTypesRow In pRoomTypes Do
			//vError = False;
			If vRoomTypesRow.ТипНомера <> vLastRoomType Тогда
				vProbeResObj.ТипНомера = vRoomTypesRow.ТипНомера;
				vProbeResObj.ТипНомераРасчет = Справочники.ТипыНомеров.EmptyRef();
				If ЗначениеЗаполнено(vRoomTypesRow.ТипНомера.BaseRoomType) Тогда
					vProbeResObj.ТипНомера = vRoomTypesRow.ТипНомера.BaseRoomType;
					vProbeResObj.ТипНомераРасчет = vRoomTypesRow.ТипНомера;
				EndIf;
				vLastRoomType = vRoomTypesRow.ТипНомера;
			EndIf;
			
			If НЕ CheckRoomRateRestrictions(vProbeResObj.Гостиница, vProbeResObj.Тариф, vProbeResObj.ТипНомера, vProbeResObj.CheckInDate, vProbeResObj.ДатаВыезда, vProbeResObj.Продолжительность) Тогда
				Continue;
			EndIf;
			
			// Get accommodation types table with ages
			vAccTypesWithAgeList = cmGetAvailableAccommodationTypesWithKidsAges(vAdultsQuantity, vKidsQuantity, vAgeArray, vExternalSystemCode, vHotel, vRoomTypesRow.ТипНомера, pAccommodationTypes);
			
			// Get accommodation types for current ГруппаНомеров type
			If vAccTypesWithAgeList.Count() = 0 Тогда
				Continue;
			EndIf;
			vLastAT = Неопределено;
			vATError = Неопределено;
			vFindedAT = Неопределено;
			vArrayOfRowsToDelete = New Array;
			For Each vAccommodationTypesRow In vAccTypesWithAgeList Do
				If vAccommodationTypesRow.AccTemplate = Неопределено Тогда
					vAccommodationTypesRow.AccTemplate = Справочники.ШаблоныРазмещения.EmptyRef();
				EndIf;
				If vLastAT <> vAccommodationTypesRow.AccTemplate Тогда
					If vATError<>Неопределено And vATError Тогда
						vFindedRowsToDelete = vRoomTypeBalances.FindRows(New Structure("AccommodationTemplate, ТипНомера", vLastAT, vRoomTypesRow.ТипНомера));
						For Each vItem In vFindedRowsToDelete Do
							vArrayOfRowsToDelete.Add(vItem);
						EndDo;
						vLastAT = Неопределено;
						vFindedAT = Неопределено;
						vATError = False;
					EndIf;
					If (vATError = Неопределено Or НЕ vATError) And vLastAT<>Неопределено Тогда
						vFindedAT = vLastAT;
						break;
					EndIf;
					vLastAT = vAccommodationTypesRow.AccTemplate;
				EndIf;
				If vATError<>Неопределено And vATError Тогда
					Continue;
				EndIf;
				vProbeResObj.ВидРазмещения = vAccommodationTypesRow.ВидРазмещения;
				// Calculate resources
				vProbeResObj.//pmCalculateResources(True);
				// Automatic services list calculation
				vProbeResObj.pmCalculateServices();
				
				// Check if there are any services for this accommodation type
				vRoomRevenueServices = vProbeResObj.Услуги.FindRows(New Structure("IsRoomRevenue", True));
				If vRoomRevenueServices.Count() = 0 Тогда
					vATError = True;
					Continue;
				EndIf;
				
				// Calculate accommodation type amount
				vAccTypeAmount = vProbeResObj.Услуги.Total("Сумма") - vProbeResObj.Услуги.Total("СуммаСкидки");
				
				// Get currency
				For Each vSrvRow In vProbeResObj.Услуги Do
					If vSrvRow.IsRoomRevenue Тогда
						vCurrency = vSrvRow.ВалютаЛицСчета;
						Break;
					EndIf;
				EndDo;
				
				// Check if there are any services is in price
				vIsInPriceServices = vProbeResObj.Услуги.FindRows(New Structure("IsInPrice", True));
				vFirstDaySum = 0;
				vCheckInDate = BegOfDay(vProbeResObj.CheckInDate);
				vCheckInCurrency = vCurrency;
				For Each vIsInPriceServicesRow In vIsInPriceServices Do
					If vIsInPriceServicesRow.УчетнаяДата <> vCheckInDate Тогда
						Break;
					Else
						vCheckInDate = vIsInPriceServicesRow.УчетнаяДата;
						If vCheckInCurrency = Неопределено Тогда
							vCheckInCurrency = vIsInPriceServicesRow.ВалютаЛицСчета;
						ElsIf vCheckInCurrency <> vIsInPriceServicesRow.ВалютаЛицСчета Тогда
							Continue;
						EndIf;
						vFirstDaySum = vFirstDaySum + Round((vIsInPriceServicesRow.Сумма - vIsInPriceServicesRow.СуммаСкидки)/?(vIsInPriceServicesRow.Количество = 0, 1, vIsInPriceServicesRow.Количество), 2);
					EndIf;
				EndDo;
				
				// Save amount to the accommodation types value table
				vRoomTypeBalancesRow = vRoomTypeBalances.Add();
				vRoomTypeBalancesRow.Age = vAccommodationTypesRow.Age;
				vRoomTypeBalancesRow.AccommodationTemplate = vAccommodationTypesRow.AccTemplate;
				vRoomTypeBalancesRow.ВидРазмещения = vAccommodationTypesRow.ВидРазмещения;
				vRoomTypeBalancesRow.Валюта = vCurrency;
				vRoomTypeBalancesRow.ExtHotelCode = vExtHotelCode;
				vRoomTypeBalancesRow.ТипНомера = vRoomTypesRow.ТипНомера;
				vRoomTypeObj = vRoomTypesRow.ТипНомера.GetObject();
				vRoomTypeBalancesRow.RoomTypeCode = СокрЛП(vRoomTypeObj.Code);
				vRoomTypeBalancesRow.RoomTypeDescription = vRoomTypeObj.pmGetRoomTypeDescription(vLanguage);
				vRoomTypeBalancesRow.ExtRoomTypeCode = cmGetObjectExternalSystemCodeByRef(vHotel, vExternalSystemCode, "ТипыНомеров", vRoomTypesRow.ТипНомера);
				If IsBlankString(vRoomTypeBalancesRow.ExtRoomTypeCode) Тогда
					vRoomTypeBalancesRow.ExtRoomTypeCode = СокрЛП(vRoomTypeObj.Description);
				EndIf;
				vRoomTypeBalancesRow.ExtRoomTypeCode = Left(vRoomTypeBalancesRow.ExtRoomTypeCode, 36);
				vRoomTypeBalancesRow.RoomTypePictureLink = СокрЛП(vRoomTypeObj.RoomTypePictureLink);
				If НЕ IsBlankString(vRoomTypeObj.RoomTypeInfoLink) Тогда
					vRoomTypeBalancesRow.RoomTypeInfoLink = vRoomTypeObj.RoomTypeInfoLink;
				Else
					vRoomTypeBalancesRow.RoomTypeInfoLink = "";
				EndIf;
				vRoomTypeBalancesRow.Тариф = vProbeResObj.Тариф;
				vRoomRateObj = vProbeResObj.Тариф.GetObject();
				vRoomTypeBalancesRow.RoomRateCode = СокрЛП(vRoomRateObj.Code);
				vRoomTypeBalancesRow.RoomRateDescription = vRoomRateObj.pmGetRoomRateDescription(vLanguage);
				vRoomTypeBalancesRow.ExtRoomRateCode = cmGetObjectExternalSystemCodeByRef(vHotel, vExternalSystemCode, "Тарифы", vProbeResObj.Тариф);
				If IsBlankString(vRoomTypeBalancesRow.ExtRoomRateCode) Тогда
					vRoomTypeBalancesRow.ExtRoomRateCode = СокрЛП(vRoomRateObj.Description);
				EndIf;
				vRoomTypeBalancesRow.ExtRoomRateCode = Left(vRoomTypeBalancesRow.ExtRoomRateCode, 36);
				vRoomTypeBalancesRow.ExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vHotel, vExternalSystemCode, "Валюты", vCurrency);
				If IsBlankString(vRoomTypeBalancesRow.ExtCurrencyCode) Тогда
					vRoomTypeBalancesRow.ExtCurrencyCode = СокрЛП(vCurrency.Description);
				EndIf;
				vRoomTypeBalancesRow.CurrencyCode = СокрЛП(vCurrency.Code);
				vRoomTypeBalancesRow.CurrencyDescription = СокрЛП(vCurrency.Description);
				vRoomTypeBalancesRow.FirstDaySum = vFirstDaySum;
				vRoomTypeBalancesRow.Amount = vAccTypeAmount;
				vRoomTypeBalancesRow.AmountPresentation = cmFormatSum(vAccTypeAmount, vCurrency, "NZ=");
				vRoomTypeBalancesRow.RoomsAvailable = vRoomTypesRow.RoomsAvailable;
				vRoomTypeBalancesRow.BedsAvailable = vRoomTypesRow.BedsAvailable;
				vRoomTypeBalancesRow.LimitedRoomsText = "";
				If vRoomTypeObj.LimitedRooms > 0 And vRoomTypeBalancesRow.RoomsAvailable > 0 And 
					vRoomTypeBalancesRow.RoomsAvailable <= vRoomTypeObj.LimitedRooms Тогда
					If vRoomTypeBalancesRow.RoomsAvailable = 1 Тогда
						vRoomTypeBalancesRow.LimitedRoomsText = "Остался только ';de='Übrig nur '" + Format(vRoomTypeBalancesRow.RoomsAvailable, "ND=10; NFD=0; NG=") + "номер';de=' Zimmer(n)'";
					ElsIf vRoomTypeBalancesRow.RoomsAvailable >= 2 And vRoomTypeBalancesRow.RoomsAvailable < 5 Тогда
						vRoomTypeBalancesRow.LimitedRoomsText = "Осталось только ';de='Übrig nur '" + Format(vRoomTypeBalancesRow.RoomsAvailable, "ND=10; NFD=0; NG=") + "номера';de=' Zimmer(n)'";
					Else
						vRoomTypeBalancesRow.LimitedRoomsText = "Осталось только ';de='Übrig nur '" + Format(vRoomTypeBalancesRow.RoomsAvailable, "ND=10; NFD=0; NG=") + "номеров';de=' Zimmer(n)'";
					EndIf;
				EndIf;
			EndDo;
			If (vATError = Неопределено Or НЕ vATError) And vLastAT<>Неопределено Тогда
				vFindedAT = vLastAT;
			EndIf;
			For Each vArrayItem In vArrayOfRowsToDelete Do
				vRoomTypeBalances.Delete(vArrayItem);
			EndDo;
			If НЕ ЗначениеЗаполнено(vFindedAT) And vFindedAT<>Справочники.ШаблоныРазмещения.EmptyRef() Тогда
				vFindedRowsToDelete = vRoomTypeBalances.FindRows(New Structure("ТипНомера", vRoomTypesRow.ТипНомера));
				For Each vItem In vFindedRowsToDelete Do
					vRoomTypeBalances.Delete(vItem);
				EndDo;
				Continue;
			EndIf;
		EndDo;
	Else 
		vFindedRow = pRoomTypes.Find(pRoomType, "ТипНомера");
		If vFindedRow = Неопределено And ЗначениеЗаполнено(pRoomType) Тогда
			vMessage = New UserMessage;
			vMessage.Text = NStr("en='The number of guests in current ГруппаНомеров type can not accommodate';ru='В выбранный тип номера указанное число гостей разместить нельзя';de='Im Zimmer des gewählten Typs kann die genannten Anzahl von Gästen nicht untergebracht werden'");
			vMessage.Field = "SelRoomType";
			vMessage.Message();
		Else
			vRoomTypeBalances = New ValueTable;
			vRoomTypeBalances.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
			vRoomTypeBalances.Columns.Add("AccommodationTemplate", cmGetCatalogTypeDescription("ШаблоныРазмещения"));
			vRoomTypeBalances.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
			vRoomTypeBalances.Columns.Add("FirstDaySum", cmGetNumberTypeDescription(17, 2));
			vRoomTypeBalances.Columns.Add("Amount", cmGetNumberTypeDescription(17, 2));
			vRoomTypeBalances.Columns.Add("AmountPresentation", cmGetStringTypeDescription());
			vRoomTypeBalances.Columns.Add("Валюта", cmGetCatalogTypeDescription("Валюты"));
			vRoomTypesList = New СписокЗначений;
			//vRowsToDeleteArray = New Array;
			If ЗначениеЗаполнено(pRoomType) Тогда
				vFindedRowIndex = pRoomTypes.IndexOf(vFindedRow);
				vRoomTypesList.Add(vFindedRow.ТипНомера);
				If vFindedRowIndex > 0 Тогда
					vPrevIndex = vFindedRowIndex - 1;
					vRoomTypesList.Add(pRoomTypes.Get(vPrevIndex).ТипНомера);
				EndIf;
				If vFindedRowIndex < (pRoomTypes.Count() - 1) Тогда
					vNextIndex = vFindedRowIndex + 1;
					vRoomTypesList.Add(pRoomTypes.Get(vNextIndex).ТипНомера);
				EndIf;
			Else
				For Each vRow In pRoomTypes Do
					vRoomTypesList.Add(vRow.ТипНомера);
				EndDo;
			EndIf;
			vLastRoomType = Справочники.ТипыНомеров.EmptyRef();
			For Each vRTItem In vRoomTypesList Do
				// Get accommodation types table with ages
				vAccTypesWithAgeList = cmGetAvailableAccommodationTypesWithKidsAges(vAdultsQuantity, vKidsQuantity, vAgeArray, vExternalSystemCode, vHotel, vRTItem.Value, pAccommodationTypes);
				If vAccTypesWithAgeList.Count() = 0 Тогда
					Continue;
				EndIf;
				If vRTItem.Value <> vLastRoomType Тогда
					vProbeResObj.ТипНомера = vRTItem.Value;
					vLastRoomType = vRTItem.Value;
				EndIf;
				vLastAT = Неопределено;
				vATError = Неопределено;
				vFindedAT = Неопределено;
				vArrayOfRowsToDelete = New Array;
				For Each vATRow In vAccTypesWithAgeList Do
					If vLastAT <> vATRow.AccTemplate Тогда
						If vATError<>Неопределено And vATError Тогда
							vFindedRowsToDelete = vRoomTypeBalances.FindRows(New Structure("AccommodationTemplate, ТипНомера", vLastAT, vRTItem.Value));
							For Each vItem In vFindedRowsToDelete Do
								vArrayOfRowsToDelete.Add(vItem);
							EndDo;
							vLastAT = Неопределено;
							vFindedAT = Неопределено;
							vATError = False;
						EndIf;
						If (vATError = Неопределено Or НЕ vATError) And vLastAT<>Неопределено Тогда
							vFindedAT = vLastAT;
							break;
						EndIf;
						vLastAT = vATRow.AccTemplate;
					EndIf;
					If vATError<>Неопределено And vATError Тогда
						Continue;
					EndIf;
					vProbeResObj.ВидРазмещения = vATRow.ВидРазмещения;
					// Calculate resources
					vProbeResObj.//pmCalculateResources(True);
					// Automatic services list calculation
					vProbeResObj.pmCalculateServices();
					
					// Check if there are any services for this accommodation type
					vRoomRevenueServices = vProbeResObj.Услуги.FindRows(New Structure("IsRoomRevenue", True));
										
					If vRoomRevenueServices.Count() = 0 Тогда	
						vATError = True;
						Continue;
					EndIf;
					// Calculate accommodation type amount
					vAccTypeAmount = vProbeResObj.Услуги.Total("Сумма") - vProbeResObj.Услуги.Total("СуммаСкидки");
					
					// Get currency
					For Each vSrvRow In vProbeResObj.Услуги Do
						If vSrvRow.IsRoomRevenue Тогда
							vCurrency = vSrvRow.ВалютаЛицСчета;
							Break;
						EndIf;
					EndDo;
					
					// Check if there are any services is in price
					vIsInPriceServices = vProbeResObj.Услуги.FindRows(New Structure("IsInPrice", True));
					vFirstDaySum = 0;
					vCheckInDate = BegOfDay(vProbeResObj.CheckInDate);
					vCheckInCurrency = vCurrency;
					For Each vIsInPriceServicesRow In vIsInPriceServices Do
						If vIsInPriceServicesRow.УчетнаяДата <> vCheckInDate Тогда
							Break;
						Else
							vCheckInDate = vIsInPriceServicesRow.УчетнаяДата;
							If vCheckInCurrency = Неопределено Тогда
								vCheckInCurrency = vIsInPriceServicesRow.ВалютаЛицСчета;
							ElsIf vCheckInCurrency <> vIsInPriceServicesRow.ВалютаЛицСчета Тогда
								Continue;
							EndIf;
							vFirstDaySum = vFirstDaySum + Round((vIsInPriceServicesRow.Сумма - vIsInPriceServicesRow.СуммаСкидки)/?(vIsInPriceServicesRow.Количество = 0, 1, vIsInPriceServicesRow.Количество), 2);
						EndIf;
					EndDo;
					
					// Save amount to the accommodation types value table
					vNewBalanceRow = vRoomTypeBalances.Add();
					vNewBalanceRow.ТипНомера = vRTItem.Value;
					vNewBalanceRow.AccommodationTemplate = vATRow.AccTemplate;
					vNewBalanceRow.ВидРазмещения = vATRow.ВидРазмещения;
					vNewBalanceRow.FirstDaySum = vFirstDaySum;
					vNewBalanceRow.Amount = vAccTypeAmount;
					vNewBalanceRow.AmountPresentation = cmFormatSum(vAccTypeAmount, vCurrency, "NZ=");
					vNewBalanceRow.Валюта = vCurrency;
				EndDo;
				If (vATError = Неопределено Or НЕ vATError) And vLastAT<>Неопределено Тогда
					vFindedAT = vLastAT;
				EndIf;
				For Each vArrayItem In vArrayOfRowsToDelete Do
					vRoomTypeBalances.Delete(vArrayItem);
				EndDo;
				If НЕ ЗначениеЗаполнено(vFindedAT) And vATError = True Тогда
					vFindedRowsToDelete = vRoomTypeBalances.FindRows(New Structure("ТипНомера", vRTItem.Value));
					For Each vItem In vFindedRowsToDelete Do
						vRoomTypeBalances.Delete(vItem);
					EndDo;
					Continue;
				EndIf;
			EndDo;
		EndIf;
	EndIf;
	// Remove folios created by documents
	If pProbeResObj = Неопределено Тогда
		For Each vCRRow In vProbeResObj.ChargingRules Do
			vFolioObj = vCRRow.ChargingFolio.GetObject();
			vFolioObj.Delete();
		EndDo;
		vProbeResObj = Неопределено;
	EndIf;
	// Return
	Return vRoomTypeBalances;
EndFunction //cmGetRoomTypeBalancesTable

//-----------------------------------------------------------------------------
// Description: Returns list of services with appropriate service type
// Parameters: Гостиница code, Service type code, External system code, Language code
// Return value: Array of services as XDTO object
//-----------------------------------------------------------------------------
Function cmGetExtraServices(pHotelCode, pServiceTypeCode, pClientTypeCode, pExternalSystemCode, pLanguageCode = "RU") Экспорт
	WriteLogEvent(NStr("en='Get extra services';ru='Получить доп. услуги';de='Zusätzliche Dienstleistungen erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='Service type code: ';ru='Код типа услуги: ';de='Dienstleistungstypcode: '") + pServiceTypeCode + Chars.LF + 
	              NStr("en='Client type code: ';ru='Код типа клиента: ';de='Kundentypcode: '") + pClientTypeCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode);
	// Get language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Get service type
	vServiceType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыУслуг", pServiceTypeCode);
	// Get client type
	vClientType = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "ТипыКлиентов", pClientTypeCode);
	If vClientType = Неопределено Тогда
		vClientType = Справочники.ТипыКлиентов.EmptyRef();
	EndIf;
	// Create return object
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExtraServices"));
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Услуги.Ref
	|FROM
	|	Catalog.Услуги AS Услуги
	|WHERE
	|	NOT Услуги.IsFolder
	|	AND NOT Услуги.DeletionMark
	|	AND NOT Услуги.IsRoomRevenue
	|	AND (Услуги.Гостиница = &qHotel
	|				AND Услуги.Гостиница <> &qEmptyHotel
	|			OR Услуги.Гостиница = &qEmptyHotel)
	|	AND (Услуги.ServiceType = &qServiceType
	|			OR &qServiceTypeIsEmpty)
	|
	|ORDER BY
	|	Услуги.ПорядокСортировки,
	|	Услуги.Description";
	vQry.SetParameter("qHotel", vHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vQry.SetParameter("qServiceType", vServiceType);
	vQry.SetParameter("qServiceTypeIsEmpty", НЕ ЗначениеЗаполнено(vServiceType));
	vServices = vQry.Execute().Unload();
	For Each vServicesRow In vServices Do
		WriteLogEvent(NStr("en='Get extra services';ru='Получить доп. услуги';de='Zusätzliche Dienstleistungen erhalten'"), EventLogLevel.Information, , , СокрЛП(vServicesRow.Ref));
		// Get service object
		vExtraServiceObj = vServicesRow.Ref.GetObject();
		vSrvPrices = vExtraServiceObj.pmGetServicePrices(vHotel, CurrentDate(), vClientType);
		If vSrvPrices.Count() = 0 Тогда
			Continue;
		EndIf;
		vSrvPriceRow = vSrvPrices.Get(0);
		If НЕ ЗначениеЗаполнено(vSrvPriceRow.Валюта) Тогда
			Continue;
		EndIf;	
		// Build return object
		vExtraServiceDetails = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "ExtraServiceRow"));
		// Fill XDTO object attributes
		vExtraServiceDetails.ServiceCode = СокрЛП(vExtraServiceObj.Code);
		vExtraServiceDetails.ServiceDescription = vExtraServiceObj.pmGetServiceDescription(vLanguage);
		vExtraServiceDetails.Цена = vSrvPriceRow.Цена;
		vExtraServiceDetails.PricePresentation = cmFormatSum(vSrvPriceRow.Цена, vSrvPriceRow.Валюта, "NZ=", vLanguage);
		vExtraServiceDetails.ЕдИзмерения = vExtraServiceObj.pmGetServiceUnitDescription(vLanguage);
		vExtraServiceDetails.Примечания = vExtraServiceObj.Примечания;
		vExtraServiceDetails.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vSrvPriceRow.Валюта);
		vExtraServiceDetails.CurrencyCode = СокрЛП(vSrvPriceRow.Валюта.Code);
		vExtraServiceDetails.CurrencyDescription = СокрЛП(vSrvPriceRow.Валюта.Description);
		// Add extra service to the return object
		vRetXDTO.ExtraServiceRow.Add(vExtraServiceDetails);
	EndDo;
	Return vRetXDTO;
EndFunction //cmGetExtraServices 

//----------------------------------------------------------------------------
// Description: Checks if all client data is filled
// Parameters: Guest group item reference
// Return value: True or False
//----------------------------------------------------------------------------
Function cmCheckGuestsInformationFullness(pGuestGroup) Экспорт
	vGGroupObj = pGuestGroup.GetObject();
	vReservations = vGGroupObj.pmGetReservations(True, True);
	vOK = True;
	For Each vReservation In vReservations Do
		vClient = vReservation.Клиент;
		If НЕ ЗначениеЗаполнено(vCLient.Фамилия) Or НЕ ЗначениеЗаполнено(vCLient.Имя) Or НЕ ЗначениеЗаполнено(vCLient.ДатаРождения) Or
			 НЕ ЗначениеЗаполнено(vCLient.Citizenship) Or НЕ ЗначениеЗаполнено(vCLient.IdentityDocumentType) Or
			  НЕ ЗначениеЗаполнено(vCLient.IdentityDocumentNumber) Or НЕ ЗначениеЗаполнено(vCLient.IdentityDocumentIssueDate) Or
			  НЕ ЗначениеЗаполнено(vCLient.Address) Тогда
			  vOK = False;
			  Break;
		EndIf;
	EndDo;
	Return vOK;
EndFunction //cmCheckGuestsInformationFullness

//----------------------------------------------------------------------------
// Description: returns list of client identification document types
//----------------------------------------------------------------------------
Function cmGetIdentityDocumentsList() Экспорт
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	УдостоверениеЛичности.Ref,
	|	УдостоверениеЛичности.Code,
	|	УдостоверениеЛичности.Description
	|FROM
	|	Catalog.УдостоверениеЛичности AS УдостоверениеЛичности
	|WHERE
	|	NOT УдостоверениеЛичности.DeletionMark
	|	AND NOT УдостоверениеЛичности.IsFolder";
	vQryChoice = vQry.Execute().Choose();
	// Get language
	//vLanguageRU = cmGetLanguageByCode("RU");
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1cho7tel.ru/interfaces/reservation/", "IdentityDocumentsList"));
	While vQryChoice.Next() Do
		vRetRow = XDTOFactory.Create(XDTOFactory.Type("http://www.1chot7el.ru/interfaces/reservation/", "IdentityDocument"));
		vRetRow.IdentityDocumentTypeCode = СокрЛП(vQryChoice.Code);
		vRetRow.IdentityDocumentTypeNameRU = vQryChoice.Description;
		vRetXDTO.IdentityDocument.Add(vRetRow);
	EndDo;
	Return vRetXDTO;
EndFunction //cmGetIdentityDocumentsList

//----------------------------------------------------------------------------
// If pIsOnServer = TRUE then pHotel and pGroup parameters is catalog item references
// else string parameters
//----------------------------------------------------------------------------
Function cmSendExpressCheckInMessage(pHotel, pGroup, pExpressCheckInPath = "", pQRCodePath = "", pQRCodeFileName = "", pIsExpress = False, pExtHotelID = "", pIsOnServer = False) Экспорт
	WriteLogEvent(NStr("en='Send Express Check-In Messages'; de='Send Express Check-In Messages'; ru='Отправка сообщений модуля Експресс Заезда'"), EventLogLevel.Information, , , 
	              NStr("en='Гостиница: ';ru='Гостиница: ';de='Гостиница: '") + String(pHotel) + Chars.LF + 
	              NStr("en='Group: '; de='Gastgruppe: '; ru='Группа гостей: '") + String(pGroup) + Chars.LF + 
				  NStr("en='Express check-in: '; de='Express check-in: '; ru='Экспресс заезд: '") + String(pIsExpress) + Chars.LF +
				  NStr("en='Express check-in path: '; de='Express check-in path: '; ru='Путь к модулю Экспресс заезда: '") + СокрЛП(pExpressCheckInPath) + Chars.LF +
				  NStr("en='QR-code full path: '; de='QR-code full path: '; ru='Полный путь к QR-коду: '") + СокрЛП(pQRCodePath) + Chars.LF +
				  NStr("en='QR-code file name: '; de='QR-code file name: '; ru='Имя файла с QR-кодом: '") + СокрЛП(pQRCodeFileName) + Chars.LF +
				  NStr("en='External hotel ID: '; de='External hotel ID: '; ru='Код гостиницы во внешней системе: '") + СокрЛП(pExtHotelID) + Chars.LF +
				  NStr("en='Is on server: '; de='Is on server: '; ru='На сервере: '") + String(pIsOnServer));

	vHotelRef = Справочники.Гостиницы.EmptyRef();			  
	vGroupRef = Справочники.ГруппыГостей.EmptyRef();
	If pIsOnServer Тогда
		If ЗначениеЗаполнено(pHotel) Тогда
			vHotelRef = pHotel;
		Else
			If ЗначениеЗаполнено(pGroup) And ЗначениеЗаполнено(pGroup.Owner) Тогда
				vHotelRef = pGroup.Owner;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(pGroup) Тогда
			vGroupRef = pGroup;
		EndIf;
	Else
		If ЗначениеЗаполнено(pHotel) Тогда
			// Try to find hotel by name or code
			vHotelRef = cmGetHotelByCode(pHotel, "1CBITRIX");
		Else
			vHotelRef = ПараметрыСеанса.ТекущаяГостиница;
		EndIf;
		If ЗначениеЗаполнено(pGroup) And ЗначениеЗаполнено(vHotelRef) Тогда
			// Get guest group by code
			vGroupRef = cmGetGuestGroupByExternalCode(vHotelRef, pGroup, "", "", False);
		EndIf;
	EndIf;				  
	//Express check-in
	If pIsExpress = True Тогда
		If ЗначениеЗаполнено(vHotelRef) And ЗначениеЗаполнено(vGroupRef) And ЗначениеЗаполнено(vGroupRef.Клиент) And ЗначениеЗаполнено(vGroupRef.Клиент.EMail) Тогда
			vLanguage = vHotelRef.Language;
			If НЕ ЗначениеЗаполнено(vLanguage) Тогда
				vLanguage = ПараметрыСеанса.ТекЛокализация;
			EndIf;
			//if guest information is full
			If cmCheckGuestsInformationFullness(vGroupRef) Тогда
				If ЗначениеЗаполнено(pQRCodePath) And ЗначениеЗаполнено(pQRCodeFileName) Тогда
					vFilePath = cmTempFilesDir()+pQRCodeFileName;
					FileCopy(pQRCodePath+pQRCodeFileName, vFilePath);
					// Send e-mail with qr-code
					If ЗначениеЗаполнено(vHotelRef.ExpressCheckInQRCodeMessageTemplate) Тогда
						vTemplate = vHotelRef.ExpressCheckInQRCodeMessageTemplate;
						vText = "";
						If ЗначениеЗаполнено(vTemplate.HTMLText) Тогда
							vText = vTemplate.HTMLText;
							vText = StrReplace(vText, "&QRCodePath", vFilePath);
						Else
							vText = vTemplate.SMSText;
						EndIf;
						rErrorMessage = "";
						If НЕ РегламентныеЗадания.cmSendTextByEMail(СокрЛП(String(vTemplate)), СокрЛП(vText), СокрЛП(vGroupRef.Клиент.EMail), False, rErrorMessage) Тогда
							cmWriteGuestGroupAttachment(vGroupRef, Перечисления.AttachmentTypes.EMail, "", СокрЛП(vText));
							vError = "Ошибка отправки E-Mail! "+rErrorMessage;
							WriteLogEvent("Отправка сообщений модуля Експресс Заезда", EventLogLevel.Error, , , vError);
						EndIf;
					Else
						WriteLogEvent("Отправка сообщений модуля Експресс Заезда", EventLogLevel.Error, , , 
						"Ошибка отправки E-Mail! Шаблон сообщения не найден");
					EndIf;
				Else
					WriteLogEvent("Отправка сообщений модуля Експресс Заезда", EventLogLevel.Error, , , 
					"Ошибка отправки E-Mail! Не указаны пути к QR-коду'");
				EndIf;
			Else
				If ЗначениеЗаполнено(pExpressCheckInPath) Тогда
					vClientEMail = "";
					vClientPhone = "";
					If ЗначениеЗаполнено(vGroupRef) And ЗначениеЗаполнено(vGroupRef.Клиент) Тогда
						vClientEMail = vGroupRef.Клиент.Email;
						vClientPhone = vGroupRef.Клиент.Телефон;
					EndIf;
					If НЕ ЗначениеЗаполнено(vClientEMail) Or НЕ ЗначениеЗаполнено(vClientPhone) Тогда
						vLink = pExpressCheckInPath+"print_checkin.php?Гостиница="+СокрЛП(pExtHotelID)+"&booking="+СокрЛП(vGroupRef.Code)+?(ЗначениеЗаполнено(vClientPhone),"&Телефон="+СокрЛП(vClientPhone), "")+?(ЗначениеЗаполнено(vClientEMail),"&email="+СокрЛП(vClientEMail), "");
						//send e-mail with express check-in invitation
						If ЗначениеЗаполнено(vHotelRef.ExpressCheckInInvitationMessageTemplate) Тогда
							vTemplate = vHotelRef.ExpressCheckInInvitationMessageTemplate;
							vText = "";
							If ЗначениеЗаполнено(vTemplate.HTMLText) Тогда
								vText = vTemplate.HTMLText;
								vText = StrReplace(vText, "&ExpressCheckInLink", vLink);
							Else
								vText = vTemplate.SMSText;
							EndIf;
							rErrorMessage = "";
							If НЕ РегламентныеЗадания.cmSendTextByEMail(СокрЛП(String(vTemplate)), СокрЛП(vText), СокрЛП(vGroupRef.Клиент.EMail), False, rErrorMessage) Тогда
								cmWriteGuestGroupAttachment(vGroupRef, Перечисления.AttachmentTypes.EMail, "", СокрЛП(vText));
								vError = "Ошибка отправки E-Mail! "+rErrorMessage;
								WriteLogEvent("Отправка сообщений модуля Експресс Заезда'", EventLogLevel.Error, , , vError);
							EndIf;
						Else
							WriteLogEvent("Отправка сообщений модуля Експресс Заезда", EventLogLevel.Error, , , 
							"Ошибка отправки E-Mail! Шаблон сообщения не найден'");
						EndIf;
					EndIf;
				Else
					WriteLogEvent("Отправка сообщений модуля Експресс Заезда", EventLogLevel.Error, , , 
					"Ошибка отправки E-Mail! Не указан путь к модулю експресс заезда");
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	Return "";
EndFunction //cmSendExpressCheckInMessage

//-----------------------------------------------------------------------------
// Function is used to update client contact data from external system data
//-----------------------------------------------------------------------------
Function cmUpdateClientInfo(pClientInfo, pHotelCode = "", pGroupCode, pExternalSystemCode, pLanguageCode = "RU", pQRCodePath = "", pQRCodeFileName = "") Экспорт
	// Get language
	//vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Get guest group by code
	vGuestGroup = cmGetGuestGroupByExternalCode(vHotel, pGroupCode, "", "", False);
	// Create return object
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1cho7tel.ru/interfaces/reservation/", "ExpressCheckInUUID"));
		WriteLogEvent("Обновить информацию клиента'", EventLogLevel.Information, , , TypeOf(pClientInfo));
		WriteLogEvent("Обновить информацию клиента'", EventLogLevel.Information, , , pClientInfo);
	For each vClientInfo in pClientInfo.ClientRow Do
		WriteLogEvent("Обновить информацию клиента'", EventLogLevel.Information, , , 
					"Код внешней системы: " + pExternalSystemCode + Chars.LF + 
					"Код группы гостей: " + pGroupCode + Chars.LF + 
					"Полный путь к QR-коду: " + pQRCodePath + Chars.LF + 
					"Имя файла QR-кода: " + pQRCodeFileName + Chars.LF + 
					"Код гостиницы: " + pHotelCode + Chars.LF + 
					"Код языка: " + pLanguageCode + Chars.LF + 
					"Фамилия гостя: " + vClientInfo.ClientLastName + Chars.LF + 
					"Имя гостя: "+ vClientInfo.ClientFirstName + Chars.LF + 
					"Отчество гостя: " + vClientInfo.ClientSecondName + Chars.LF + 
					"Код пола гостя: " + vClientInfo.ClientSex + Chars.LF + 
					"Код гражданства гостя: " + vClientInfo.ClientCitizenship + Chars.LF + 
					"Дата рождения гостя: " + vClientInfo.ClientBirthDate + Chars.LF + 
					"Телефон гостя:  " + vClientInfo.ClientPhone + Chars.LF + 
					"Факс гостя: " + vClientInfo.ClientFax + Chars.LF + 
					"E-Mail гостя: " + vClientInfo.ClientEMail + Chars.LF + 
					"Код типа документа удостоверяющего личность:  " + vClientInfo.ClientIdentityDocumentType + Chars.LF + 
					"Серия документа удостоверяющего личность: " + vClientInfo.ClientIdentityDocumentSeries + Chars.LF + 
					"НомерРазмещения документа удостоверяющего личность: " + vClientInfo.ClientIdentityDocumentNumber + Chars.LF + 
					"Кем выдан документ удостоверяющего личность: " + vClientInfo.ClientIdentityDocumentIssuedBy + Chars.LF + 
					"Действителен до: " + vClientInfo.ClientIdentityDocumentValidToDate + Chars.LF + 
					"Дата выдачи документа удостоверяющего личность: " + vClientInfo.ClientIdentityDocumentIssueDate + Chars.LF + 
					"Адрес клиента: " + vClientInfo.Address);
		vError = "";
		vCltRef = Справочники.Клиенты.EmptyRef();
		//cmGetClientsByGroupCode(pGroupCode, pEMail, pPhone)
		// Check if group was found
		If НЕ ЗначениеЗаполнено(vGuestGroup) Тогда
			vError = "Группа не найдена!";
			WriteLogEvent("Обновить информацию клиента", EventLogLevel.Error, , , vError);
			vRetXDTO.Error = vError;
			Return vRetXDTO;
		EndIf;
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	Бронирование.Клиент,
		|	Бронирование.Клиент.Телефон AS Телефон,
		|	Бронирование.Клиент.Email AS Email
		|FROM
		|	Document.Бронирование AS Бронирование
		|WHERE
		|	Бронирование.Posted
		|	AND NOT Бронирование.DeletionMark
		|	AND Бронирование.ГруппаГостей = &qGroup
		|	AND Бронирование.CheckInDate > &qCurDate"+
		?(ЗначениеЗаполнено(vClientInfo.ClientLastName)," AND Бронирование.Клиент.Фамилия = &qLastName", "")+
		?(ЗначениеЗаполнено(vClientInfo.ClientFirstName)," AND Бронирование.Клиент.Имя = &qFirstName", "")+
		?(ЗначениеЗаполнено(vClientInfo.ClientSecondName)," AND Бронирование.Клиент.Отчество = &qSecondName", "");
		If ЗначениеЗаполнено(vClientInfo.ClientLastName) Тогда
			vQry.SetParameter("qLastName", vClientInfo.ClientLastName);
		EndIf;
		If ЗначениеЗаполнено(vClientInfo.ClientFirstName) Тогда
			vQry.SetParameter("qFirstName", vClientInfo.ClientFirstName);
		EndIf;
		If ЗначениеЗаполнено(vClientInfo.ClientSecondName) Тогда
			vQry.SetParameter("qSecondName", vClientInfo.ClientSecondName);
		EndIf;
		vQry.SetParameter("qCurDate", CurrentDate());
		vQry.SetParameter("qGroup", vGuestGroup);
		vQryResult = vQry.Execute().Unload();
		If vQryResult.Count()>0 Тогда
			If vQryResult.Count() = 1 Тогда
				vCltRef = vQryResult[0].Клиент;
			Else
				For Each vQryRow In vQryResult Do
					If ЗначениеЗаполнено(vClientInfo.ClientPhone) Тогда
						//If SMS.GetValidPhoneNumber(СокрЛП(vClientInfo.ClientPhone)) = vQryRow.Phone Тогда
						//	vCltRef = vQryRow.Guest;
						//	Break;
						//EndIf;
						If СокрЛП(vClientInfo.ClientEmail) = vQryRow.Email Тогда
							vCltRef = vQryRow.Guest;
							Break;
						EndIf;
					EndIf;
				EndDo;
				If НЕ ЗначениеЗаполнено(vCltRef) Тогда
					vCltRef = vQryResult[0].Клиент;
				EndIf;
			EndIf;
			WriteLogEvent("Клиент найден'", EventLogLevel.Information, , , 
			"Код клиента: " + vCltRef.Code + Chars.LF + 
			"Фамилия клиента: " + vCltRef.Фамилия + Chars.LF + 
			"Имя клиента: " + vCltRef.Имя + Chars.LF + 
			"Отчество клиента: " + vCltRef.Отчество);
		EndIf;
		//<> 
		If НЕ ЗначениеЗаполнено(vCltRef) Тогда
			vError = "Клиент не найден!";
			WriteLogEvent("Обновить информацию клиента", EventLogLevel.Error, , , vError);
			vRetXDTO.Error = vError;
			Return vRetXDTO;
		EndIf;
		Try
			vCltObj = vCltRef.GetObject();
			//Second name
			If ЗначениеЗаполнено(vClientInfo.ClientSecondName) And НЕ ЗначениеЗаполнено(vCltObj.Отчество) Тогда
				vCltObj.Отчество = vClientInfo.ClientSecondName;
			EndIf;
			//Date of birth
			If ЗначениеЗаполнено(vClientInfo.ClientBirthDate) Тогда
				vCltObj.ДатаРождения = BegOfDay(vClientInfo.ClientBirthDate);
			EndIf;
			If ЗначениеЗаполнено(vHotel) Тогда
				// Гражданство
				If НЕ ЗначениеЗаполнено(vCltObj.Citizenship) Тогда
					If IsBlankString(vClientInfo.ClientCitizenship) Тогда
						vCltObj.Гражданство = vHotel.Гражданство;
					Else
						vCltObj.Гражданство = cmGetCountryByCode(vClientInfo.ClientCitizenship);
					EndIf;
				ElsIf НЕ IsBlankString(vClientInfo.ClientCitizenship) Тогда
					vCltObj.Гражданство = cmGetCountryByCode(vClientInfo.ClientCitizenship);
				EndIf;
				// Language
				If НЕ ЗначениеЗаполнено(vCltObj.Language) Тогда
					vCltObj.Language = vHotel.Language;
				EndIf;
				// Identity document
				If НЕ ЗначениеЗаполнено(vCltObj.IdentityDocumentType) Тогда
					If vCltObj.Гражданство = vHotel.Гражданство Тогда
						vCltObj.IdentityDocumentType = vHotel.IdentityDocumentType;
					Else
						vCltObj.IdentityDocumentType = vHotel.IdentityDocumentTypeForForeigners;
					EndIf;
				EndIf;
			EndIf;
			// Sex
			If НЕ IsBlankString(vClientInfo.ClientSex) Тогда
				vSexLetter = Upper(Left(СокрЛП(vClientInfo.ClientSex), 1));
				If vSexLetter = "F" Or vSexLetter = "Ж" Тогда
					vCltObj.Пол = Перечисления.Пол.Female;
				Else
					vCltObj.Пол = Перечисления.Пол.Male;
				EndIf;
			Else
				vCltObj.Пол = cmGetSexByNames(vCltObj.Фамилия, vCltObj.Имя, vCltObj.Отчество);
			EndIf;
			//Contacts
			If ЗначениеЗаполнено(vClientInfo.ClientPhone) Тогда
				vCltObj.Телефон = СокрЛП(vClientInfo.ClientPhone);
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientEMail) Тогда
				vCltObj.EMail = СокрЛП(vClientInfo.ClientEMail);
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientFax) Тогда
				vCltObj.Fax = СокрЛП(vClientInfo.ClientFax);
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientIdentityDocumentType) Тогда
				vIdentityDocumentType = Справочники.УдостоверениеЛичности.FindByCode(СокрЛП(vClientInfo.ClientIdentityDocumentType));
				If ЗначениеЗаполнено(vIdentityDocumentType) Тогда
					vCltObj.IdentityDocumentType = vIdentityDocumentType;
				EndIf;
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientIdentityDocumentNumber) Тогда
				vCltObj.IdentityDocumentNumber = СокрЛП(vClientInfo.ClientIdentityDocumentNumber);
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientIdentityDocumentSeries) Тогда
				vCltObj.IdentityDocumentSeries = СокрЛП(vClientInfo.ClientIdentityDocumentSeries);
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientIdentityDocumentIssuedBy) Тогда
				vCltObj.IdentityDocumentIssuedBy = СокрЛП(vClientInfo.ClientIdentityDocumentIssuedBy);
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientIdentityDocumentValidToDate) Тогда
				vCltObj.IdentityDocumentValidToDate = vClientInfo.ClientIdentityDocumentValidToDate;
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.ClientIdentityDocumentIssueDate) Тогда
				vCltObj.IdentityDocumentIssueDate = vClientInfo.ClientIdentityDocumentIssueDate;
			EndIf;
			If ЗначениеЗаполнено(vClientInfo.Address) Тогда
				vCltObj.Address = СокрЛП(vClientInfo.Address);
			EndIf;
			// No SMS delivery
			If TypeOf(vClientInfo.ClientSendSMS) = Type("Boolean") Тогда
				vCltObj.NoSMSDelivery = НЕ vClientInfo.ClientSendSMS;
			EndIf;
			// Run some internal client functions to fill some client parameters
			vCltObj.Description = vCltObj.pmGetDescription();
			vCltObj.FullName = vCltObj.pmGetFullName();
			//Write
			vCltObj.Write();
			// Save data to the client change history
			vCltObj.pmWriteToClientChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
		Except
			vError = "Ошибка обновления данных клиента!";
			WriteLogEvent("Обновить информацию клиента'", EventLogLevel.Error, , , vError);
			vRetXDTO.Error = vError;
			Return vRetXDTO;
		EndTry;
	EndDo;
	//Send E-Mail
	cmSendExpressCheckInMessage(vHotel, vGuestGroup,, pQRCodePath, pQRCodeFileName, True, "",True);
	Return vRetXDTO;
EndFunction //cmUpdateClientInfo

//-----------------------------------------------------------------------------
// Function returns guest groups for the given agent. Groups are returned for the given period and hotel
//-----------------------------------------------------------------------------
Function cmGetAgentGroupsList(pLogin, pHotelCode, pExternalSystemCode, pPeriodFrom = '00010101', pPeriodTo = '00010101', pLanguageCode = "RU") Экспорт
	WriteLogEvent(NStr("en='Get active groups list';ru='Получить список действующих групп';de='Liste der aktiven Gruppen erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='Login: ';ru='Логин: ';de='Login: '") + pLogin + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode);
	// Create return object
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GroupsList"));
	If НЕ ЗначениеЗаполнено(pExternalSystemCode) Тогда
		Return vRetXDTO;
	EndIf;
	// Get language
	//vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Try to find hotel by name or code
	vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
	// Get Контрагент and contract by login
	vCustomerStruct = cmGetCustomerByLogin(vHotel, pExternalSystemCode, pLogin);
	// Try to find marketing code
	vMarketingCode = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "КодМаркетинга", pExternalSystemCode);
	// Get active reservations and group by them by guest group
	If (vCustomerStruct <> Неопределено And ЗначениеЗаполнено(vCustomerStruct.Контрагент)) Or ЗначениеЗаполнено(vMarketingCode) Тогда
		// Get Контрагент and contract references
		vCustomer = vCustomerStruct.Контрагент;
		vContract = vCustomerStruct.Договор;
		// Run query
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ГруппыГостей.ГруппаГостей AS ГруппаГостей,
		|	ГруппыГостей.GuestGroupCode AS GuestGroupCode,
		|	ГруппыГостей.Status AS Status,
		|	ГруппыГостей.CheckInDate AS CheckInDate,
		|	ГруппыГостей.Продолжительность AS Продолжительность,
		|	ГруппыГостей.ДатаВыезда AS ДатаВыезда,
		|	ГруппыГостей.КоличествоЧеловек AS КоличествоЧеловек,
		|	ГруппыГостей.GuestFullName AS GuestFullName,
		|	ГруппыГостей.Примечания AS Примечания,
		|	ГруппыГостей.Агент AS Агент,
		|	ISNULL(GuestGroupTotalSales.Продажи, 0) AS Продажи,
		|	GuestGroupTotalSales.Валюта AS Валюта,
		|	GuestGroupTotalSales.Валюта.Code AS CurrencyCode,
		|	GuestGroupTotalSales.Валюта.Description AS CurrencyDescription,
		|	ISNULL(GuestGroupPayments.PaymentAmount, 0) AS PaymentAmount,
		|	GuestGroupPayments.PaymentCurrency AS PaymentCurrency
		|FROM
		|	(SELECT
		|		Бронирование.ГруппаГостей AS ГруппаГостей,
		|		Бронирование.GuestGroupCode AS GuestGroupCode,
		|		Бронирование.Status AS Status,
		|		Бронирование.CheckInDate AS CheckInDate,
		|		Бронирование.Продолжительность AS Продолжительность,
		|		Бронирование.ДатаВыезда AS ДатаВыезда,
		|		Бронирование.КоличествоЧеловек AS КоличествоЧеловек,
		|		Бронирование.GuestFullName AS GuestFullName,
		|		Бронирование.Примечания AS Примечания,
		|		Бронирование.Агент AS Агент
		|	FROM
		|		(SELECT
		|			ReservationDocs.ГруппаГостей AS ГруппаГостей,
		|			ReservationDocs.ГруппаГостей.Code AS GuestGroupCode,
		|			ReservationDocs.ГруппаГостей.Status AS Status,
		|			ReservationDocs.ГруппаГостей.CheckInDate AS CheckInDate,
		|			ReservationDocs.ГруппаГостей.Продолжительность AS Продолжительность,
		|			ReservationDocs.ГруппаГостей.ДатаВыезда AS ДатаВыезда,
		|			ReservationDocs.ГруппаГостей.ЗаездГостей AS КоличествоЧеловек,
		|			ReservationDocs.ГруппаГостей.Клиент.FullName AS GuestFullName,
		|			ReservationDocs.ГруппаГостей.Description AS Примечания,
		|			ReservationDocs.Агент.Description AS Агент
		|		FROM
		|			Document.Бронирование AS ReservationDocs
		|		WHERE
		|			ReservationDocs.Posted
		|			AND ReservationDocs.Гостиница = &qHotel
		|			AND ((ReservationDocs.Контрагент = &qCustomer
		|						AND ReservationDocs.Договор = &qContract)
		|					OR ReservationDocs.Агент = &qCustomer
		|					OR &qCustomerIsEmpty)
		|			AND (ReservationDocs.МаретингНапрвл = &qMarketingCode
		|					OR &qMarketingCodeIsEmpty)
		|			AND (ReservationDocs.ReservationStatus.IsActive
		|					OR ReservationDocs.ReservationStatus.IsPreliminary)
		|		
		|		UNION ALL
		|		
		|		SELECT
		|			AccommodationDocs.ГруппаГостей,
		|			AccommodationDocs.ГруппаГостей.Code,
		|			AccommodationDocs.ГруппаГостей.Status,
		|			AccommodationDocs.ГруппаГостей.CheckInDate,
		|			AccommodationDocs.ГруппаГостей.Продолжительность,
		|			AccommodationDocs.ГруппаГостей.ДатаВыезда,
		|			AccommodationDocs.ГруппаГостей.ЗаездГостей,
		|			AccommodationDocs.ГруппаГостей.Клиент.FullName,
		|			AccommodationDocs.ГруппаГостей.Description,
		|			AccommodationDocs.Агент.Description
		|		FROM
		|			Document.Размещение AS AccommodationDocs
		|		WHERE
		|			AccommodationDocs.Posted
		|			AND AccommodationDocs.Гостиница = &qHotel
		|			AND ((AccommodationDocs.Контрагент = &qCustomer
		|						AND AccommodationDocs.Договор = &qContract)
		|					OR AccommodationDocs.Агент = &qCustomer
		|					OR &qCustomerIsEmpty)
		|			AND (AccommodationDocs.МаретингНапрвл = &qMarketingCode
		|					OR &qMarketingCodeIsEmpty)
		|			AND AccommodationDocs.СтатусРазмещения.IsActive) AS Бронирование
		|	
		|	GROUP BY
		|		Бронирование.ГруппаГостей,
		|		Бронирование.Status,
		|		Бронирование.CheckInDate,
		|		Бронирование.Продолжительность,
		|		Бронирование.ДатаВыезда,
		|		Бронирование.КоличествоЧеловек,
		|		Бронирование.GuestFullName,
		|		Бронирование.Примечания,
		|		Бронирование.Агент,
		|		Бронирование.GuestGroupCode) AS ГруппыГостей
		|		LEFT JOIN (SELECT
		|			GuestGroupSales.ГруппаГостей AS ГруппаГостей,
		|			GuestGroupSales.Валюта AS Валюта,
		|			SUM(GuestGroupSales.SalesTurnover) + SUM(GuestGroupSales.SalesForecastTurnover) AS Продажи
		|		FROM
		|			(SELECT
		|				CurrentAccountsReceivableTurnovers.ГруппаГостей AS ГруппаГостей,
		|				CurrentAccountsReceivableTurnovers.ВалютаЛицСчета AS Валюта,
		|				CurrentAccountsReceivableTurnovers.SumReceipt - CurrentAccountsReceivableTurnovers.CommissionSumReceipt AS SalesTurnover,
		|				0 AS SalesForecastTurnover
		|			FROM
		|				AccumulationRegister.РелизацияТекОтчетПериод.Turnovers(
		|						,
		|						,
		|						Period,
		|						Контрагент = &qCustomer
		|							AND Договор = &qContract
		|							AND Гостиница = &qHotel) AS CurrentAccountsReceivableTurnovers
		|			
		|			UNION ALL
		|			
		|			SELECT
		|				AccountsReceivableForecastTurnovers.ГруппаГостей,
		|				AccountsReceivableForecastTurnovers.ВалютаЛицСчета,
		|				0,
		|				AccountsReceivableForecastTurnovers.SalesTurnover - AccountsReceivableForecastTurnovers.CommissionSumTurnover
		|			FROM
		|				AccumulationRegister.ПрогнозРеализации.Turnovers(
		|						,
		|						,
		|						Period,
		|						Контрагент = &qCustomer
		|							AND Договор = &qContract
		|							AND Гостиница = &qHotel) AS AccountsReceivableForecastTurnovers) AS GuestGroupSales
		|		
		|		GROUP BY
		|			GuestGroupSales.ГруппаГостей,
		|			GuestGroupSales.Валюта) AS GuestGroupTotalSales
		|		ON ГруппыГостей.ГруппаГостей = GuestGroupTotalSales.ГруппаГостей
		|		LEFT JOIN (SELECT
		|			Платежи.ГруппаГостей AS ГруппаГостей,
		|			Платежи.ВалютаРасчетов AS PaymentCurrency,
		|			SUM(Платежи.SumExpense) AS PaymentAmount
		|		FROM
		|			AccumulationRegister.ВзаиморасчетыКонтрагенты.BalanceAndTurnovers(
		|					,
		|					,
		|					Period,
		|					RegisterRecordsAndPeriodBoundaries,
		|					Контрагент = &qCustomer
		|						AND Договор = &qContract
		|						AND Гостиница = &qHotel) AS Платежи
		|		
		|		GROUP BY
		|			Платежи.ГруппаГостей,
		|			Платежи.ВалютаРасчетов) AS GuestGroupPayments
		|		ON ГруппыГостей.ГруппаГостей = GuestGroupPayments.ГруппаГостей
		|
		|ORDER BY
		|	ГруппыГостей.CheckInDate,
		|	ГруппыГостей.GuestGroupCode";
		vQry.SetParameter("qHotel", vHotel);
		vQry.SetParameter("qCustomer", vCustomer);
		vQry.SetParameter("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(vCustomer));
		vQry.SetParameter("qContract", vContract);
		vQry.SetParameter("qMarketingCode", vMarketingCode);
		vQry.SetParameter("qMarketingCodeIsEmpty", НЕ ЗначениеЗаполнено(vMarketingCode));
		vGuestGroups = vQry.Execute().Unload();
		For Each vGuestGroupsRow In vGuestGroups Do
			// Build return object
			vGuestGroupDetails = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GuestGroupDetails"));
			// Get guest group object
			vGuestGroupObj = vGuestGroupsRow.GuestGroup.GetObject();
			// Fill XDTO object attributes
			vGuestGroupDetails.ГруппаГостей = Format(vGuestGroupObj.Code, "ND=12; NFD=0; NZ=; NG=");
			vGuestGroupDetails.Контрагент = СокрЛП(vCustomer.Description);
			vGuestGroupDetails.Договор = СокрЛП(vContract.Description);
			vGuestGroupDetails.Агент = СокрЛП(vGuestGroupsRow.Agent);
			If ЗначениеЗаполнено(vGuestGroupsRow.Status) Тогда
				vGuestGroupDetails.Status = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "СтатусБрони", vGuestGroupsRow.Status);
				vGuestGroupDetails.StatusCode = СокрЛП(vGuestGroupsRow.Status.Code);
				vGuestGroupDetails.StatusDescription = СокрЛП(vGuestGroupsRow.Status.Description);
			Else
				vGuestGroupDetails.Status = "";
				vGuestGroupDetails.StatusCode = "";
				vGuestGroupDetails.StatusDescription = "";
			EndIf;
			vGuestGroupDetails.CheckInDate = vGuestGroupsRow.CheckInDate;
			vGuestGroupDetails.Продолжительность = vGuestGroupsRow.Duration;
			vGuestGroupDetails.ДатаВыезда = vGuestGroupsRow.CheckOutDate;
			vGuestGroupDetails.КоличествоЧеловек = vGuestGroupsRow.NumberOfPersons;
			vGuestGroupDetails.GuestFullName = СокрЛП(vGuestGroupsRow.GuestFullName);
			vGuestGroupDetails.Примечания = Left(vGuestGroupsRow.Remarks, 2048);
			vGuestGroupDetails.Amount = vGuestGroupsRow.Sales;
			vGuestGroupDetails.Balance = vGuestGroupsRow.Sales - vGuestGroupsRow.PaymentAmount;
			If vGuestGroupsRow.Sales <> 0 And ЗначениеЗаполнено(vGuestGroupsRow.Currency) Тогда
				vGuestGroupDetails.Валюта = cmGetObjectExternalSystemCodeByRef(vHotel, pExternalSystemCode, "Валюты", vGuestGroupsRow.Currency);
				vGuestGroupDetails.CurrencyCode = СокрЛП(vGuestGroupsRow.CurrencyCode);
				vGuestGroupDetails.CurrencyDescription = СокрЛП(vGuestGroupsRow.CurrencyDescription);
				vGuestGroupDetails.PaymentPercent = Round(vGuestGroupsRow.PaymentAmount/vGuestGroupsRow.Sales*100, 0);
			Else
				vGuestGroupDetails.Валюта = "";
				vGuestGroupDetails.CurrencyCode = "";
				vGuestGroupDetails.CurrencyDescription = "";
				vGuestGroupDetails.PaymentPercent = 0;
			EndIf;
			// Add guest group to the return object
			vRetXDTO.GuestGroupDetails.Add(vGuestGroupDetails);
		EndDo;
	EndIf;	
	Return vRetXDTO;
EndFunction //cmGetAgentGroupsList 

//-----------------------------------------------------------------------------
// Description: Returns the amount of the certificate
// Parameters: Гостиница code, Gift certificate code
// Return value: -1 - if certificate is not found, -2 - certificate is blocked,  or amount of the certificate
//-----------------------------------------------------------------------------
Function cmGetCertificateAmount(pGiftCertificate) Экспорт 
	WriteLogEvent(NStr("en='Pay by certificate';ru='Оплата сертификатом.ЗапросБаланса';de='Pay by сertificate'"), EventLogLevel.Information, , , 
	NStr("en='Сertificate code: ';ru='Код сертификата: ';de='Gutschein-Code: '")+pGiftCertificate);
	vHotel = ПараметрыСеанса.ТекущаяГостиница;
	
	If НЕ cmGiftCertificateExists(vHotel,pGiftCertificate) Тогда
		Return -1;
	EndIf;
	
	vDate = CurrentDate();
	
	If cmGiftCertificateIsBlocked (vHotel,pGiftCertificate,vDate,"") Тогда
		Return -2;
	EndIf;

	Return cmGetGiftCertificateBalance(vHotel, pGiftCertificate, vDate); 

EndFunction // cmGetCertificateAmount()

//-----------------------------------------------------------------------------
Function GetAccommodationTypePriceFromRoomRatePrices(pHotel, pRoomQuota, pRoomType, pAccommodationType, pClientType, pRoomRate, pCheckInDate, pCheckOutDate, pCalendarDayTypes = Неопределено, pOrders = Неопределено, pPriceTags = Неопределено)
	// First get active for check in date set ГруппаНомеров rate prices documents
	vOrders = pOrders;
	If НЕ ЗначениеЗаполнено(vOrders) Тогда
		vOrders = cmGetActiveSetRoomRatePrices(pRoomRate, cm1SecondShift(pCheckInDate));
	EndIf;
	vSetRoomRatePrices = New СписокЗначений();
	vSetRoomRatePrices.LoadValues(vOrders.UnloadColumn("ПриказТариф"));
	// Retrieve set ГруппаНомеров rate prices documents rows
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomRatePrices.ТипНомера AS ТипНомера,
	|	RoomRatePrices.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	RoomRatePrices.ВидРазмещения AS ВидРазмещения,
	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки AS AccommodationTypeSortCode,
	|	RoomRatePrices.ТипДеньКалендарь AS ТипДеньКалендарь,
	|	RoomRatePrices.ТипДеньКалендарь.ПорядокСортировки AS CalendarDayTypeSortCode,
	|	RoomRatePrices.ПризнакЦены AS ПризнакЦены,
	|	RoomRatePrices.ПризнакЦены.ПорядокСортировки AS PriceTagSortCode,
	|	RoomRatePrices.Валюта AS Валюта,
	|	RoomRatePrices.Валюта.ПорядокСортировки AS CurrencySortCode,
	|	SUM(CASE
	|			WHEN RoomRatePrices.IsPricePerPerson
	|					AND RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation > 1
	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.NumberOfPersons4Reservation
	|			WHEN RoomRatePrices.IsPricePerPerson
	|					AND RoomRatePrices.ВидРазмещения.КоличествоЧеловек > 1
	|				THEN RoomRatePrices.Цена * RoomRatePrices.ВидРазмещения.КоличествоЧеловек
	|			ELSE RoomRatePrices.Цена
	|		END) AS Цена,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.ВсегоНомеров, 0)
	|			ELSE ISNULL(КвотаНомеров.НомеровКвота, 0)
	|		END) AS ВсегоНомеров,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.ВсегоМест, 0)
	|			ELSE ISNULL(КвотаНомеров.МестКвота, 0)
	|		END) AS ВсегоМест,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.RoomsAvailable, 0)
	|			WHEN &qRoomQuotaDoNotWriteOff
	|					AND ISNULL(ЗагрузкаНомеров.RoomsAvailable, 0) < ISNULL(КвотаНомеров.ОстаетсяНомеров, 0)
	|				THEN ISNULL(ЗагрузкаНомеров.RoomsAvailable, 0)
	|			ELSE ISNULL(КвотаНомеров.ОстаетсяНомеров, 0)
	|		END) AS RoomsAvailable,
	|	MIN(CASE
	|			WHEN &qRoomQuotaIsEmpty
	|				THEN ISNULL(ЗагрузкаНомеров.BedsAvailable, 0)
	|			WHEN &qRoomQuotaDoNotWriteOff
	|					AND ISNULL(ЗагрузкаНомеров.BedsAvailable, 0) < ISNULL(КвотаНомеров.ОстаетсяМест, 0)
	|				THEN ISNULL(ЗагрузкаНомеров.BedsAvailable, 0)
	|			ELSE ISNULL(КвотаНомеров.ОстаетсяМест, 0)
	|		END) AS BedsAvailable,
	|	1 AS Количество,
	|	0 AS Сумма,
	|	0 AS AvgPrice
	|FROM
	|	InformationRegister.RoomRatePrices AS RoomRatePrices
	|		LEFT JOIN (SELECT
	|			RoomInventoryBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.CounterClosingBalance, 0)) AS CounterClosingBalance,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance, 0)) AS ВсегоНомеров,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance, 0)) AS ВсегоМест,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance, 0)) AS RoomsAvailable,
	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance, 0)) AS BedsAvailable
	|		FROM
	|			AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|					&qCheckInDate,
	|					&qCheckOutDate,
	|					Second,
	|					RegisterRecordsAndPeriodBoundaries,
	|					Гостиница = &qHotel
	|						AND ТипНомера IN HIERARCHY (&qRoomType)) AS RoomInventoryBalanceAndTurnovers
	|		
	|		GROUP BY
	|			RoomInventoryBalanceAndTurnovers.ТипНомера) AS ЗагрузкаНомеров
	|		ON RoomRatePrices.ТипНомера = ЗагрузкаНомеров.ТипНомера
	|		LEFT JOIN (SELECT
	|			RoomQuotaSalesBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance, 0)) AS CounterClosingBalance,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance, 0)) AS НомеровКвота,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance, 0)) AS МестКвота,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance, 0)) AS ОстаетсяНомеров,
	|			MIN(ISNULL(RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance, 0)) AS ОстаетсяМест
	|		FROM
	|			AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|					&qCheckInDate,
	|					&qCheckOutDate,
	|					Second,
	|					RegisterRecordsAndPeriodBoundaries,
	|					Гостиница = &qHotel
	|						AND ТипНомера IN HIERARCHY (&qRoomType)
	|						AND КвотаНомеров IN HIERARCHY (&qRoomQuota)) AS RoomQuotaSalesBalanceAndTurnovers
	|		
	|		GROUP BY
	|			RoomQuotaSalesBalanceAndTurnovers.ТипНомера) AS КвотаНомеров
	|		ON RoomRatePrices.ТипНомера = КвотаНомеров.ТипНомера
	|WHERE
	|	RoomRatePrices.Гостиница = &qHotel
	|	AND RoomRatePrices.Тариф = &qRoomRate
	|	AND RoomRatePrices.ТипКлиента = &qClientType
	|	AND RoomRatePrices.ТипНомера IN HIERARCHY(&qRoomType)
	|	AND RoomRatePrices.ВидРазмещения IN HIERARCHY(&qAccommodationType)
	|	AND RoomRatePrices.ПриказТариф IN(&qSetRoomRatePrices)
	|	AND RoomRatePrices.IsInPrice = TRUE
	|
	|GROUP BY
	|	RoomRatePrices.ТипНомера,
	|	RoomRatePrices.ТипНомера.ПорядокСортировки,
	|	RoomRatePrices.ВидРазмещения,
	|	RoomRatePrices.ВидРазмещения.ПорядокСортировки,
	|	RoomRatePrices.ТипДеньКалендарь,
	|	RoomRatePrices.ТипДеньКалендарь.ПорядокСортировки,
	|	RoomRatePrices.ПризнакЦены,
	|	RoomRatePrices.ПризнакЦены.ПорядокСортировки,
	|	RoomRatePrices.Валюта,
	|	RoomRatePrices.Валюта.ПорядокСортировки
	|
	|ORDER BY
	|	RoomTypeSortCode,
	|	AccommodationTypeSortCode,
	|	CalendarDayTypeSortCode,
	|	PriceTagSortCode,
	|	CurrencySortCode
	|TOTALS BY
	|	ТипНомера ONLY HIERARCHY";
	vQry.SetParameter("qCheckInDate", cm1SecondShift(pCheckInDate));
	vQry.SetParameter("qCheckOutDate", New Boundary(cm0SecondShift(pCheckOutDate), BoundaryType.Excluding));
	vQry.SetParameter("qClientType", pClientType);
	vQry.SetParameter("qRoomRate", pRoomRate);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(pRoomQuota));
	vQry.SetParameter("qRoomQuotaDoNotWriteOff", ?(ЗначениеЗаполнено(pRoomQuota), НЕ pRoomQuota.DoWriteOff, False));
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qAccommodationType", pAccommodationType);
	vQry.SetParameter("qSetRoomRatePrices", vSetRoomRatePrices);
	vList = vQry.Execute().Unload();
	// Add prices from ГруппаНомеров rate service packages
	If ЗначениеЗаполнено(pRoomRate) Тогда
		vPackagesList = pRoomRate.GetObject().pmGetRoomRateServicePackagesList();
		For Each vPackagesListItem In vPackagesList Do
			vServicePackage = vPackagesListItem.Value;
			If ЗначениеЗаполнено(vServicePackage) Тогда
				If vServicePackage.DateValidFrom <= BegOfDay(pCheckInDate) And 
					(vServicePackage.DateValidTo >= BegOfDay(pCheckInDate) Or НЕ ЗначениеЗаполнено(vServicePackage.DateValidTo)) Тогда
					vServices = vServicePackage.GetObject().pmGetServices(pCheckInDate);
					For Each vServicePackageRow In vServices Do
						If vServicePackageRow.IsInPrice Тогда
							For Each vListRow In vList Do
								If vListRow.Currency = vServicePackageRow.Валюта And 
									(pClientType = vServicePackageRow.ТипКлиента Or ЗначениеЗаполнено(pClientType) And НЕ ЗначениеЗаполнено(vServicePackageRow.ТипКлиента)) And
									(vListRow.AccommodationType = vServicePackageRow.ВидРазмещения Or НЕ ЗначениеЗаполнено(vServicePackageRow.ВидРазмещения)) Тогда
									vListRow.Price = vListRow.Price + vServicePackageRow.Количество * vServicePackageRow.Цена;
								EndIf;
							EndDo;
						EndIf;
					EndDo;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	// Add discounts from ГруппаНомеров rate discount type
	If ЗначениеЗаполнено(pRoomRate) And ЗначениеЗаполнено(pRoomRate.ТипСкидки) Тогда
		vDiscountTypeObj = pRoomRate.ТипСкидки.GetObject();
		vDiscount = vDiscountTypeObj.pmGetDiscount(cm1SecondShift(pCheckInDate), , pHotel);
		For Each vListRow In vList Do
			vListRow.Price = vListRow.Price - Round(vListRow.Price*vDiscount/100, 2);
		EndDo;
	EndIf;
	// Calculate new row values
	If ЗначениеЗаполнено(pRoomRate) And ЗначениеЗаполнено(pRoomRate.Calendar) Тогда
		vCalendarDayTypes = pCalendarDayTypes;
		If НЕ ЗначениеЗаполнено(vCalendarDayTypes) Тогда
			vCalendarDayTypes = pRoomRate.Calendar.GetObject().pmGetDays(pCheckInDate, pCheckOutDate, pCheckInDate, pCheckOutDate);
			vCalendarDayTypes.Sort("Period");
		EndIf;
		vPriceTags = pPriceTags;
		For Each vListRow In vList Do
			If ЗначениеЗаполнено(vListRow.AccommodationType) And ЗначениеЗаполнено(vListRow.RoomType) Тогда
				vSum = 0;
				vNumDays = 0;
				//vAvgPrice = 0;
				vCurrency = Неопределено;
				vDate = BegOfDay(pCheckInDate);
				vEndDate = BegOfDay(pCheckOutDate);
				If pRoomRate.DurationCalculationRuleType <> Перечисления.DurationCalculationRuleTypes.ByDays Тогда
					vEndDate = vEndDate - 24*3600;
				EndIf;
				If НЕ ЗначениеЗаполнено(pPriceTags) Тогда
					rPriceTagsList = New СписокЗначений();
					vPriceTags = cmGetEffectivePriceTags(pHotel, pRoomRate, vListRow.RoomType, pCheckInDate, pCheckOutDate, rPriceTagsList);
				EndIf;
				While vDate <= vEndDate Do
					vNumDays = vNumDays + 1;
					vCalendarDayTypeRow = vCalendarDayTypes.Find(vDate, "Period");
					If vCalendarDayTypeRow <> Неопределено Тогда
						vCalendarDayType = vCalendarDayTypeRow.ТипДняКалендаря;
						vPriceTagRows = vPriceTags.FindRows(New Structure("Period, ТипНомера", vDate, vListRow.RoomType));
						If vPriceTagRows.Count() = 0 Тогда
							vPriceTagRow = vPriceTags.Find(vDate, "Period");
						Else
							vPriceTagRow = vPriceTagRows.Get(0);
						EndIf;
						If vPriceTagRow <> Неопределено Тогда
							vPriceTag = vPriceTagRow.ПризнакЦены;
							vRows = vList.FindRows(New Structure("ТипНомера, ВидРазмещения, ТипДеньКалендарь, ПризнакЦены", vListRow.RoomType, vListRow.AccommodationType, vCalendarDayType, vPriceTag));
							If vRows.Count() = 1 Тогда
								vRow = vRows.Get(0);
								If vCurrency = Неопределено Тогда
									vCurrency = vRow.Валюта;
								EndIf;
								If vCurrency <> vRow.Валюта Тогда
									Continue;
								EndIf;
								vSum = vSum + vRow.Цена;
							Else
								Continue;
							EndIf;
						Else
							Continue;
						EndIf;
					Else
						Continue;
					EndIf;
					vDate = vDate + 24*3600;
				EndDo;
				vListRow.Sum = vSum * vListRow.Quantity;
				If vNumDays > 0 Тогда 
					vListRow.AvgPrice = Round(vListRow.Sum/vNumDays, 2);
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	// Return
	Return vList;
EndFunction //GetAccommodationTypePriceFromRoomRatePrices

//-----------------------------------------------------------------------------
// Description: Writes external preauthorisation to the external reservation folio 
// Parameters: External reservation code, External guest group code, External client 
//             code, Payer name, Payment method, Payment amount (number), Payment 
//             currency, Гостиница code, External system code, Credit \
//             card processing reference number, Credit card processing authorisation 
//             code, Remarks as string, Output type: XDTO GuestGroupPreauthorisationStatus object 
//             or string in CSV format
// Return value: XDTO GuestGroupPreauthorisationStatus object or CSV string
//-----------------------------------------------------------------------------
Function cmWriteExternalPreauthorisation(pExtReservationCode, pExtGroupCode, pExtClientCode, 
                                pExtPayerCode = "", pPayerTIN = "", pPayerKPP = "", pPayerName = "", 
                                pPaymentMethod, pSum, pCurrency, pHotelCode, pExternalSystemCode, 
								pReferenceNumber, pAuthorizationCode, pRemarks, pGuaranteedReservationStatus = "", 
								pPreauthorisationDate = Неопределено, pCompanyCode = "", pPreauthorisationExternalCode = "", 
								pOutputType = "CSV", pExternalPaymentData = Неопределено) Экспорт
	WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExternalSystemCode + Chars.LF + 
	              NStr("en='External reservation code: ';ru='Код брони во внешней системе: ';de='Reservierungscode im externen System: '") + pExtReservationCode + Chars.LF + 
	              NStr("en='External group code: ';ru='Код группы во внешней системе: ';de='Gruppencode im externen System: '") + pExtGroupCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='External client code: ';ru='Код клиента во внешней системы: ';de='Kundecode im externen System: '") + pExtClientCode + Chars.LF + 
	              NStr("en='External payer code: ';ru='Код плательщика во внешней системе: ';de='Zahlercode im externen System: '") + pExtPayerCode + Chars.LF + 
	              NStr("en='Payer name: ';ru='Наименование плательщика: ';de='Bezeichnung des Zahlers: '") + pPayerName + Chars.LF + 
	              NStr("en='Payer ИНН: ';ru='ИНН плательщика: ';de='INN des Zahlers: '") + pPayerTIN + Chars.LF + 
	              NStr("en='Payer KPP: ';ru='КПП плательщика: ';de='Zahler-KPP: '") + pPayerKPP + Chars.LF + 
	              NStr("en='Payment method code: ';ru='Код способа оплаты: ';de='Code der Zahlungsmethode: '") + pPaymentMethod + Chars.LF + 
	              NStr("en='Reference number: ';ru='Референс номер: ';de='Referenznummer: '") + pReferenceNumber + Chars.LF + 
	              NStr("en='Authorization code: ';ru='Код авторизации: ';de='Autorisierungscode: '") + pAuthorizationCode + Chars.LF + 
	              NStr("en='Remarks: ';ru='Примечания: ';de='Anmerkungen: '") + pRemarks + Chars.LF + 
	              NStr("en='Guaranteed reservation status: ';ru='Статус оплаченной брони: ';de='Status der bezahlten Reservierung: '") + pGuaranteedReservationStatus + Chars.LF + 
	              NStr("en='Currency code: ';ru='Код валюты: ';de='Währungscode: '") + pCurrency + Chars.LF + 
	              NStr("en='Preauthorisation date: ';ru='Дата преавторизации: ';de='Vorautorisierung Datum: '") + pPreauthorisationDate + Chars.LF + 
	              NStr("en='Фирма code: ';ru='Код фирмы: ';de='Firmencode: '") + pCompanyCode + Chars.LF + 
	              NStr("en='Preauthorisation external code: ';ru='Код преавторизации во внешней системе: ';de='Vorautorisierung externen Code: '") + pPreauthorisationExternalCode + Chars.LF + 
	              NStr("en='Preauthorisation sum: ';ru='Сумма преавторизации: ';de='Vorautorisierung Summe: '") + Format(pSum, "ND=17; NFD=2; NZ="));
	If pExternalPaymentData <> Неопределено Тогда
		WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Information, , , 
		              NStr("en='Card number: ';ru='Номер карты: ';de='Kartenummer: '") + pExternalPaymentData.CardNumber + Chars.LF + 
		              NStr("en='Order number: ';ru='Номер заказа: ';de='Bestellungsnummer: '") + pExternalPaymentData.OrderNumber + Chars.LF + 
		              NStr("en='Card holder: ';ru='Держатель карты: ';de='Kartenhalter: '") + pExternalPaymentData.CardHolder + Chars.LF + 
		              NStr("en='Invoice code: ';ru='Код счета на оплату: ';de='Rechnungscode: '") + pExternalPaymentData.InvoiceCode + Chars.LF + 
					  NStr("en='Preauthorisation external code from acc: ';ru='Код преавторизации в бух системе: ';de='Vorautorisierung code im externen System: '") + pExternalPaymentData.ExternalPaymentCode + Chars.LF + 
		              NStr("en='Operation date: ';ru='Дата операции: ';de='Betriebsdatum: '") + Format(pExternalPaymentData.ДатаДок, "DF='dd.MM.yyyy HH:mm'"));
	EndIf;
	Try
		// Save current timestamp and start transaction
		vCurrentDate = CurrentDate();
		BeginTransaction(DataLockControlMode.Managed);
		// Initialize error description
		vErrorDescription = "";
		// Try to find hotel by name or code
		vHotel = cmGetHotelByCode(pHotelCode, pExternalSystemCode);
		// Try to find existing reservation with given external code
		vDocRef = Documents.Бронирование.EmptyRef();
		If НЕ IsBlankString(pExtReservationCode) Тогда
			vDocRef = cmGetReservationByExternalCode(vHotel, pExtReservationCode);
		EndIf;
		//
		If НЕ ЗначениеЗаполнено(pPreauthorisationExternalCode) And pExternalPaymentData <> Неопределено Тогда
			pPreauthorisationExternalCode = pExternalPaymentData.ExternalPaymentCode; 
		EndIf;	
		// Try to find guest group by code
		vGuestGroup = Справочники.ГруппыГостей.EmptyRef();
		If НЕ IsBlankString(pExtGroupCode) Тогда
			Try
				vGuestGroup = Справочники.ГруппыГостей.FindByCode(Number(pExtGroupCode), False, , vHotel);
			Except
			EndTry;
			If НЕ ЗначениеЗаполнено(vGuestGroup) Тогда
				vGuestGroup = cmGetGuestGroupByExternalCode(vHotel, pExtGroupCode, "", "", False);
			EndIf;
		EndIf;
		// Invoice
		vInvoiceRef = Неопределено;
		If pExternalPaymentData <> Неопределено And ЗначениеЗаполнено(pExternalPaymentData.Get("InvoiceCode")) Тогда
			vInvoiceCode = pExternalPaymentData.Get("InvoiceCode");
			vInvoiceRef = GetInvoiceByExternalSystemCode(vInvoiceCode);
			If ЗначениеЗаполнено(vInvoiceRef) Тогда
				If ЗначениеЗаполнено(vInvoiceRef.ГруппаГостей) And НЕ ЗначениеЗаполнено(vGuestGroup) Тогда
					vGuestGroup = vInvoiceRef.ГруппаГостей;
				EndIf;
			Else
				// Silently return from function because this invoice is not from this database. Simply skip this call
				vRetStr = "";
				If TransactionActive() Тогда
					RollbackTransaction();
				EndIf;
				// Log success		
				WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Information, , , 
							  NStr("en='Invoice code passed is not from hotel database - SKIPPING THIS CALL!';ru='Счет на оплату не найден по переданному коду! Этот счет не из отельной базы - ВЫЗОВ НЕ ОБРАБАТЫВАЕМ';de='Rechnung nicht über den übertragenen Code gefunden! Dieses Proformarechnung ist kein Гостиница - Anruf wird übersprungen.'"));
				// Return based on output type
				If pOutputType = "CSV" Тогда
					Return vRetStr;
				Else
					vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GuestGroupPreauthorisationStatus"));
					vRetXDTO.PreauthorisationNumber = "";
					vRetXDTO.ErrorDescription = "";
					vRetXDTO.TotalSum = 0;
					vRetXDTO.TotalSumPresentation = "";
					vRetXDTO.Balance = 0;
					vRetXDTO.BalancePresentation = "";
					vRetXDTO.UUID = "";
					Return vRetXDTO;
				EndIf;
			EndIf;
		EndIf;
		// Try to find client by code
		vClient = Справочники.Клиенты.EmptyRef();
		If НЕ IsBlankString(pExtClientCode) Тогда
			vClient = cmGetClientByExternalCode(pExtClientCode);
			If НЕ ЗначениеЗаполнено(vClient) Тогда
				vClient = cmGetClientByCode(pExtClientCode);
			EndIf;
		EndIf;
		// Try to find Фирма
		vCompany = Справочники.Фирмы.EmptyRef();
		If НЕ IsBlankString(pCompanyCode) Тогда
			vCompany = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Фирмы", pCompanyCode);
		EndIf;
		// Try to find payment method
		vPaymentMethod = Справочники.СпособОплаты.EmptyRef();
		If НЕ IsBlankString(pPaymentMethod) Тогда
			vPaymentMethod = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СпособОплаты", pPaymentMethod);
		EndIf;
		// Try to find reservation status
		vGuaranteedReservationStatus = Справочники.СтатусБрони.EmptyRef();
		If НЕ IsBlankString(pGuaranteedReservationStatus) Тогда
			vGuaranteedReservationStatus = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "СтатусБрони", pGuaranteedReservationStatus);
		Else
			vGuaranteedReservationStatus = vHotel.GuaranteedReservationStatus;
		EndIf;
		// Try to find currency
		vCurrency = Справочники.Валюты.EmptyRef();
		If НЕ IsBlankString(pCurrency) Тогда
			If Число(pCurrency) Тогда
				vCurrency = Справочники.Валюты.FindByCode(Number(pCurrency));
			EndIf;
			If НЕ ЗначениеЗаполнено(vCurrency) Тогда
				vCurrency = cmGetObjectRefByExternalSystemCode(vHotel, pExternalSystemCode, "Валюты", pCurrency);
			EndIf;
		EndIf;
		// Try to find payer
		vCustomer = Справочники.Контрагенты.EmptyRef();
		If НЕ IsBlankString(pExtPayerCode) Тогда
			// Try to find Контрагент by external code
			vCustomer = cmGetCustomerByExternalCode(TrimR(pExtPayerCode));
		EndIf;
		If НЕ ЗначениеЗаполнено(vCustomer) And НЕ IsBlankString(pPayerTIN) Тогда
			// Try to find Контрагент by ИНН and KPP
			vCustomer = cmGetCustomerByTIN(TrimR(pPayerTIN), TrimR(pPayerKPP), "", False);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCustomer) And НЕ IsBlankString(pPayerName) Тогда
			// Try to find Контрагент by name
			vCustomer = cmGetCustomerByName(Upper(TrimR(pPayerName)), , False);
		EndIf;
		If НЕ ЗначениеЗаполнено(vCustomer) And НЕ IsBlankString(pExtPayerCode) And НЕ IsBlankString(pPayerTIN) And НЕ IsBlankString(pPayerName) Тогда 
			vCustomerObj = Справочники.Контрагенты.CreateItem();
			vCustomerObj.pmFillAttributesWithDefaultValues();
			vCustomerObj.Description = TrimR(pPayerName);
			vCustomerObj.ЮрИмя = TrimR(vCustomerObj.Description);
			vCustomerObj.ИНН = TrimR(pPayerTIN);
			vCustomerObj.KPP = TrimR(pPayerKPP);
			vCustomerObj.ExternalCode = TrimR(pExtPayerCode);
			vCustomerObj.Write();
			vCustomerObj.pmWriteToCustomerChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			vCustomer = vCustomerObj.Ref;
		EndIf;
		// Check parameters
		If pSum = 0 Тогда
			ВызватьИсключение NStr("en='Preauthorisation sum should be filled!';ru='Сумма преавторизации должна быть указана!';de='Vorautorisierung Summe sollte ausgefüllt werden!'");
		ElsIf НЕ ЗначениеЗаполнено(vHotel) Тогда
			ВызватьИсключение NStr("en='Гостиница should be specified!';ru='Гостиница должна быть указана!';de='Das Гостиница muss angegeben sein!'");
		ElsIf НЕ ЗначениеЗаполнено(vCurrency) Тогда
			ВызватьИсключение NStr("en='Preauthorisation curency should be specified!';ru='Валюта преавторизации должна быть указана!';de='Vorautorisierung curency sollte festgelegt werden!'");
		ElsIf НЕ ЗначениеЗаполнено(vPaymentMethod) Тогда
			ВызватьИсключение NStr("en='Payment method should be choosen!';ru='Способ оплаты должен быть указан!';de='Zahlungsmethode muss definiert werden!'");
		EndIf;
		// Reset preauthorisation object
		vPreauthObj = Неопределено;
		// Try to find preauthorisation document by external preauthorisation code
		If НЕ IsBlankString(pPreauthorisationExternalCode) Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	Preauthorisations.Ref AS Ref,
			|	Preauthorisations.ДатаДок AS Date
			|FROM
			|	Document.ПреАвторизация AS Preauthorisations
			|WHERE
			|	Preauthorisations.ExternalCode = &qExternalCode
			|ORDER BY
			|	Date";
			vQry.SetParameter("qExternalCode", TrimR(pPreauthorisationExternalCode));
			vPreauthorisations = vQry.Execute().Unload();
			For Each vPreauthorisationsRow In vPreauthorisations Do
				vWrkPreauthorisationRef = vPreauthorisationsRow.Ref;
				If vPreauthorisations.IndexOf(vPreauthorisationsRow) > 0 Тогда
					If НЕ vWrkPreauthorisationRef.DeletionMark Тогда
						vWrkPreauthorisationObj = vWrkPreauthorisationRef.GetObject();
						vWrkPreauthorisationObj.SetDeletionMark(True);
					EndIf;
				EndIf;
			EndDo;
		EndIf;
		// Find guest group folio to write preauthorisation to
		If ЗначениеЗаполнено(vGuestGroup) Тогда
			// Fill hotel from guest group
			vHotel = vGuestGroup.Owner;
			// Run query to get folios to charge to
			vFolio = Неопределено;
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				vQry = New Query();
				vQry.Text = 
				"SELECT
				|	СчетПроживания.Ref,
				|	СчетПроживания.ДокОснование
				|FROM
				|	Document.СчетПроживания AS СчетПроживания
				|WHERE
				|	(NOT СчетПроживания.DeletionMark)
				|	AND СчетПроживания.Гостиница = &qHotel
				|	AND (СчетПроживания.ДокОснование = &qParentDoc
				|			OR &qParentDocIsEmpty)
				|	AND СчетПроживания.ГруппаГостей = &qGuestGroup
				|	AND (СчетПроживания.Клиент = &qClient
				|			OR &qClientIsEmpty)
				|	AND (СчетПроживания.Контрагент = &qCustomer
				|			OR &qCustomerIsEmpty)
				|	AND (СчетПроживания.Фирма = &qCompany
				|			OR &qCompanyIsEmpty)
				|ORDER BY
				|	СчетПроживания.PointInTime";
				vQry.SetParameter("qHotel", vHotel);
				vQry.SetParameter("qParentDoc", vDocRef);
				vQry.SetParameter("qParentDocIsEmpty", НЕ ЗначениеЗаполнено(vDocRef));
				vQry.SetParameter("qGuestGroup", vGuestGroup);
				vQry.SetParameter("qClient", vClient);
				vQry.SetParameter("qClientIsEmpty", НЕ ЗначениеЗаполнено(vClient));
				vQry.SetParameter("qCustomer", vCustomer);
				vQry.SetParameter("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(vCustomer));
				vQry.SetParameter("qCompany", vCompany);
				vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(vCompany));
				WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Information, vGuestGroup.Metadata(), vGuestGroup, 
							  NStr("en='Folios search:';ru='Поиск лицевых счетов:';de='Suche nach Personenkonten:'") + Chars.LF + 
							  "qHotel: " + vHotel + Chars.LF +
							  "qGuestGroup: " + vGuestGroup + Chars.LF +
							  "qParentDoc: " + vDocRef + Chars.LF +
							  "qParentDocIsEmpty: " + (НЕ ЗначениеЗаполнено(vDocRef)) + Chars.LF +
							  "qClient: " + vClient + ?(ЗначениеЗаполнено(vClient), " (" + СокрЛП(vClient.Code) + ")", "") + Chars.LF +
							  "qClientIsEmpty: " + (НЕ ЗначениеЗаполнено(vClient)) + Chars.LF +
							  "qCustomer: " + vCustomer + ?(ЗначениеЗаполнено(vCustomer), " (" + СокрЛП(vCustomer.Code) + ")", "") + Chars.LF +
							  "qCustomerIsEmpty: " + (НЕ ЗначениеЗаполнено(vCustomer)) + Chars.LF +
							  "qCompany: " + vCompany + ?(ЗначениеЗаполнено(vCompany), " (" + СокрЛП(vCompany.Code) + ")", "") + Chars.LF +
							  "qCompanyIsEmpty: " + (НЕ ЗначениеЗаполнено(vCompany)));
				vFolios = vQry.Execute().Unload();
				// Find folio with ГруппаНомеров revenue services
				For Each vFoliosRow In vFolios Do
					WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Information, vFoliosRow.Ref.Metadata(), vFoliosRow.Ref, 
								  NStr("en='Checking folio...';ru='Проверяем лицевой счет...';de='Wir überprüfen das Personenkonto...'"));
					If ЗначениеЗаполнено(vFoliosRow.ParentDoc) Тогда
						If TypeOf(vFoliosRow.ParentDoc) = Type("DocumentRef.Размещение") Or
						   TypeOf(vFoliosRow.ParentDoc) = Type("DocumentRef.Бронирование") Тогда
							If vFoliosRow.ParentDoc.Услуги.Count() > 0 Тогда
								vRoomRevenueServices = vFoliosRow.ParentDoc.Услуги.FindRows(New Structure("IsRoomRevenue", True));
								If vRoomRevenueServices.Count() > 0 Тогда
									vFolio = vRoomRevenueServices.Get(0).СчетПроживания;
									Break;
								EndIf;
							EndIf;
						EndIf;
					EndIf;
				EndDo;
			EndIf;
			// Get folio from group charging rules
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				If vGuestGroup.ChargingRules.Count() > 0 Тогда
					vGGCRRow = vGuestGroup.ChargingRules.Get(0);
					If ЗначениеЗаполнено(vGGCRRow.ChargingFolio) Тогда
						vFolio = vGGCRRow.ChargingFolio;
					EndIf;
				EndIf;
			EndIf;
			If НЕ ЗначениеЗаполнено(vFolio) Тогда
				ВызватьИсключение NStr("en='Preauthorisation folio was not found!';ru='Не найден лицевой счет!';de='Personenkonto nicht gefunden!'");
			EndIf;
			WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Information, vFolio.Metadata(), vFolio, 
						  NStr("en='ЛицевойСчет is choosen...';ru='Назначен лицевой счет...';de='Personenkonto wurde festgelegt…'"));
			// Create preauthorisation for the folio being found
			If vPreauthObj = Неопределено Тогда
				vPreauthObj = Documents.ПреАвторизация.CreateDocument();
				vPreauthObj.Гостиница = vHotel;
			EndIf;
			vPreauthObj.Fill(vFolio);
			If pPreauthorisationDate <> Неопределено Тогда
				vPreauthObj.ДатаДок = pPreauthorisationDate;
			EndIf;
			If ЗначениеЗаполнено(vCompany) Тогда
				vPreauthObj.Фирма = vCompany;
			EndIf;
			If НЕ IsBlankString(pPayerName) Тогда
				vPreauthObj.Примечания = pPayerName;
			EndIf;
			vPreauthObj.PaymentCurrency = vCurrency;
			vPreauthObj.СпособОплаты = vPaymentMethod;
			// Invoice
			If ЗначениеЗаполнено(vInvoiceRef) Тогда
				vPreauthObj.СчетНаОплату = vInvoiceRef;
			Else
				vInvoices = vFolio.ГруппаГостей.GetObject().pmGetInvoices(vFolio.Контрагент, vFolio.Договор);
				For Each vInvoicesRow In vInvoices Do
					If pSum > 0 And vInvoicesRow.Balance > 0 Тогда
						vPreauthObj.СчетНаОплату = vInvoices.Get(0).СчетНаОплату;
						Break;
					ElsIf pSum < 0 And vInvoicesRow.Balance = 0 Тогда
						vPreauthObj.СчетНаОплату = vInvoices.Get(0).СчетНаОплату;
						Break;
					EndIf;
				EndDo;
			EndIf;
			vPreauthObj.Сумма = pSum;
			vPreauthObj.pmRecalculateSums();			
			// Reference and authorization codes
			vPreauthObj.ReferenceNumber = СокрЛП(pReferenceNumber);
			vPreauthObj.AuthorizationCode = СокрЛП(pAuthorizationCode);
			// Preauthorisation remarks
			vPreauthObj.SlipText = TrimR(pRemarks);
			// External system preauthorisation code
			vPreauthObj.ExternalCode = TrimR(pPreauthorisationExternalCode);
			// Set Контрагент as payer
			If ЗначениеЗаполнено(vCustomer) And ЗначениеЗаполнено(vPreauthObj.СпособОплаты) And vPreauthObj.СпособОплаты.IsByBankTransfer Тогда
				If ЗначениеЗаполнено(vPreauthObj.Гостиница) And vCustomer <> vPreauthObj.Гостиница.IndividualsCustomer Тогда
					vPreauthObj.Payer = vCustomer;
				EndIf;
			EndIf;
			// Credit card
			vCreditCard = Справочники.КредитныеКарты.EmptyRef();
			If pExternalPaymentData <> Неопределено Тогда
				If ЗначениеЗаполнено(pExternalPaymentData.CardNumber) Тогда
					// Search cards with given owner and number
					vQry = New Query();
					vQry.Text = 
					"SELECT
					|	КредитныеКарты.Ref AS CreditCard
					|FROM
					|	Catalog.КредитныеКарты AS CreditCards
					|WHERE
					|	КредитныеКарты.CardOwner = &qCardOwner
					|	AND КредитныеКарты.CardNumber = &qCardNumber
					|	AND КредитныеКарты.DeletionMark = FALSE";
					vQry.SetParameter("qCardOwner", vPreauthObj.Payer);
					vQry.SetParameter("qCardNumber", СокрЛП(pExternalPaymentData.CardNumber));
					vCards = vQry.Execute().Unload();
					If vCards.Count() > 0 Тогда
						// Return first found
						vCreditCard = vCards.Get(0).CreditCard;
					Else
						vCreditCardObj = Справочники.КредитныеКарты.CreateItem();
						vCreditCardObj.Description = cmGetCreditCardDescription(pExternalPaymentData.CardNumber);
						vCreditCardObj.pmFillAttributesWithDefaultValues();
						vCreditCardObj.CardOwner = vPreauthObj.Payer;
						vCreditCardObj.CardNumber = pExternalPaymentData.CardNumber;
						vCreditCardObj.CardHolder = pExternalPaymentData.CardHolder;
						vCreditCardObj.Write();
						vCreditCard = vCreditCardObj.Ref;
					EndIf;
				EndIf;
			EndIf;
			vPreauthObj.CreditCard = vCreditCard;
			// Post preauthorisation
			vPreauthObj.Write(DocumentWriteMode.Posting);
			// Update guest group reservation status
			If ЗначениеЗаполнено(vGuaranteedReservationStatus) Тогда 
				vReservations = vGuestGroup.GetObject().pmGetReservations(True, True);
				For Each vReservationsRow In vReservations Do
					If ЗначениеЗаполнено(vReservationsRow.Status) And vReservationsRow.Status.IsActive And vReservationsRow.Status <> vGuaranteedReservationStatus Тогда
						vReservationObj = vReservationsRow.Бронирование.GetObject();
						vReservationObj.ReservationStatus = vGuaranteedReservationStatus;
						vReservationObj.pmSetDoCharging();
						Try
							vReservationObj.Write(DocumentWriteMode.Posting);
							// Write to the document change history
							vReservationObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
						Except
							// Log exception if any
							WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Warning, vReservationObj.Metadata(), vReservationObj.Ref, 
							              NStr("en='Error updating reservation status to ';ru='Ошибка при изменении статуса брони на ';de='Fehler bei der Änderung des Reservierungsstatus für '") + СокрЛП(vGuaranteedReservationStatus) + ":" + Chars.LF + 
							              ErrorDescription());
						EndTry;
					EndIf;
				EndDo;
			EndIf;
			// Write guest group attachment that preauthorisation was received
			vLanguage = vHotel.Language;
			If ЗначениеЗаполнено(vPreauthObj.Payer) And ЗначениеЗаполнено(vPreauthObj.Payer.Language) Тогда
				vLanguage = vPreauthObj.Payer.Language;
			EndIf;
			vRemarks = vHotel.GetObject().pmGetHotelPrintName(vLanguage) + 
			           "Преавторизация №" + СокрЛП(vPreauthObj.НомерДока) + " от " + Format(vPreauthObj.ДатаДок, "DF=dd.MM.yy") + "'";
			vDocumentText = "Автоматизированная система рассылки уведомлений об изменении статусов брони:'" + Chars.LF + Chars.LF +
								   ?(ЗначениеЗаполнено(vGuestGroup) And ЗначениеЗаполнено(vGuestGroup.Клиент), "Клиент: ';" + СокрЛП(vGuestGroup.Клиент.FullName) + Chars.LF, "") + 
								   ?(ЗначениеЗаполнено(vGuestGroup) And ЗначениеЗаполнено(vGuestGroup.CheckInDate) And ЗначениеЗаполнено(vGuestGroup.ДатаВыезда), "Период проживания: " + Format(vGuestGroup.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - "  + Format(vGuestGroup.ДатаВыезда, "DF='dd.MM.yyyy HH:mm'") + Chars.LF, "") + 
								   Chars.LF + "Преавторизация на сумму " + cmFormatSum(vPreauthObj.Сумма, vPreauthObj.PaymentCurrency, "NZ=") + " по брони НомерРазмещения " + Format(vGuestGroup.Code, "ND=12; NFD=0; NG=") + " был получен и успешно обработан!" + Chars.LF + 
			                       ?(ЗначениеЗаполнено(vGuaranteedReservationStatus), Chars.LF + "Статус брони был изменен на " + vGuaranteedReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage) + Chars.LF, Chars.LF) + Chars.LF + 
			                       "Детали преавторизации " + Chars.LF + 
			                       СокрЛП(vPreauthObj.SlipText) + Chars.LF + Chars.LF + 
			                       "С уважением," + Chars.LF + vHotel.GetObject().pmGetHotelPrintName(vLanguage) + Chars.LF + ПараметрыСеанса.ИмяКонфигурации;
			// Write attachment
			cmWriteGuestGroupAttachment(vGuestGroup, Перечисления.AttachmentTypes.EMail, vRemarks, vDocumentText);
		Else
			ВызватьИсключение( "Не удалось определить группу гостей");
		EndIf;
		vGroupObj = vGuestGroup.GetObject();
		vSalesTotals = vGroupObj.pmGetSalesTotals();
		vPaymentTotals = vGroupObj.pmGetPaymentsTotals();
		// Get total group amount
		vSum = 0;
		vCurrency = vHotel.BaseCurrency;
		vExtCurrencyCode = "";
		vSumPresentation = "";
		If vSalesTotals.Count() > 0 Тогда
			vCurrency = vSalesTotals.Get(0).Валюта;
			For Each vSalesTotalsRow In vSalesTotals Do
				If vSalesTotalsRow.Валюта = vCurrency Тогда
					vSum = vSum + vSalesTotalsRow.Продажи + vSalesTotalsRow.ПрогнозПродаж;
				Else
					vSum = vSum + cmConvertCurrencies(vSalesTotalsRow.Продажи + vSalesTotalsRow.ПрогнозПродаж, vSalesTotalsRow.Валюта, , vCurrency, , CurrentDate(), vHotel);
				EndIf;
			EndDo;
			vSum = Round(vSum, 2);
		EndIf;
		vSumPresentation = cmFormatSum(vSum, vCurrency, "NZ=");
		vExtCurrencyCode = cmGetObjectExternalSystemCodeByRef(vGuestGroup.Owner, pExternalSystemCode, "Валюты", vCurrency);
		If IsBlankString(vExtCurrencyCode) Тогда
			vExtCurrencyCode = СокрЛП(vCurrency.Description);
		EndIf;
		// Get base currency code
		vBaseCurrency = vHotel.BaseCurrency;
		vExtBaseCurrencyCode = cmGetObjectExternalSystemCodeByRef(vGuestGroup.Owner, pExternalSystemCode, "Валюты", vBaseCurrency);
		If IsBlankString(vExtBaseCurrencyCode) Тогда
			vExtBaseCurrencyCode = СокрЛП(vBaseCurrency.Description);
		EndIf;
		// Get currency rate
		//vCurrencyRate = cmGetCurrencyExchangeRate(vHotel, vCurrency, CurrentDate());
		// Get group balance
		vPaymentSum = 0;
		For Each vPaymentTotalsRow In vPaymentTotals Do
			If vPaymentTotalsRow.Валюта = vCurrency Тогда
				vPaymentSum = vPaymentSum + vPaymentTotalsRow.Сумма;
			Else
				vPaymentSum = vPaymentSum + cmConvertCurrencies(vPaymentTotalsRow.Сумма, vPaymentTotalsRow.Валюта, , vCurrency, , CurrentDate(), vHotel);
			EndIf;
			vPaymentSum = Round(vPaymentSum, 2);
		EndDo;
		vBalanceAmount = vSum - vPaymentSum;
		vBalanceAmountPresentation = cmFormatSum(vBalanceAmount, vCurrency, "NZ=");
		// Check time period
		If (CurrentDate() - vCurrentDate) > 20 And  vInvoiceRef = Неопределено Тогда
			ВызватьИсключение NStr("en='Rollback transaction lasting more then 20 seconds!'; ru='Откат транзакции продолжающейся более 20 секунд!'; de='Rollback Transaktion, die länger als 20 Sekunden!'");
		EndIf;
		CommitTransaction();
		// Build return string
		vRetStr = """" + СокрЛП(vPreauthObj.НомерДока) + """" + "," + """" + """";
		// Log success		
		WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Information, vPreauthObj.Metadata(), vPreauthObj.Ref, 
					  NStr("en='Preauthorisation is written - OK!';ru='Преавторизация записана в БД!';de='Vorautorisierung geschrieben - OK!'") + Chars.LF + vRetStr);
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GuestGroupPreauthorisationStatus"));
			vRetXDTO.PreauthorisationNumber = СокрЛП(vPreauthObj.НомерДока);
			vRetXDTO.ErrorDescription = "";
			vRetXDTO.TotalSum = vSum;
			vRetXDTO.TotalSumPresentation = vSumPresentation;
			vRetXDTO.Balance = vBalanceAmount;
			vRetXDTO.BalancePresentation = vBalanceAmountPresentation;
			vRetXDTO.UUID = String(vGuestGroup.UUID());
			Return vRetXDTO;
		EndIf;
	Except
		vErrorDescription = ErrorDescription();
		If TransactionActive() Тогда
			RollbackTransaction();
		EndIf;
		// Write log event
		WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Error, , , 
		              NStr("en='Error description: ';ru='Описание ошибки: ';de='Fehlerbeschreibung: '") + ErrorDescription());
		// Send error notifications
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And not IsBlankString(ПараметрыСеанса.ТекПользователь.BccEMail) Тогда
			WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Error, , , 
						  NStr("en='Send notification e-mail: ';ru='Отправка e-mail уведомления об ошибке: ';de='Versenden einer Fehlermeldung per E-Mail: '") + NStr("en='Failed to write external preauthorisation! ';ru='Ошибка при сохранении внешней преавторизации! ';de='Fehler beim externen Vorautorisierung schreiben! '") + pExtGroupCode + ", " + pExtPayerCode + " = " + pSum + " " + pCurrency + " -> " + СокрЛП(ПараметрыСеанса.ТекПользователь.BccEMail));
			vEMailErrorMessage = "";
			РеглЗадания.cmSendTextByEMail(NStr("en='Failed to write external preauthorisation! ';ru='Ошибка при сохранении внешней преавторизации! ';de='Fehler beim externen Vorautorisierung schreiben! '") + pExtGroupCode + ", " + pExtPayerCode + " = " + pSum + " " + pCurrency, pExtGroupCode + ", " + pExtPayerCode + " = " + pSum + " " + pCurrency + Chars.LF + Chars.LF + vErrorDescription, ПараметрыСеанса.ТекПользователь.BccEMail, False, vEMailErrorMessage);
			If НЕ IsBlankString(vEMailErrorMessage) Тогда
				WriteLogEvent(NStr("en='Write external preauthorisation';ru='Записать внешнюю преавторизацию';de='Schreiben externen Vorautorisierung'"), EventLogLevel.Error, , , 
							  NStr("en='Error sending notification e-mail: ';ru='Не удалось отправить e-mail уведомление об ошибке: ';de='Es konnte keine E-Mail-Fehlerbenachrichtigung verschickt werden: '") + vEMailErrorMessage);
			EndIf;
		EndIf;
		// Build return string
		vRetStr = """" + """" + "," + """" + vErrorDescription + """";
		// Return based on output type
		If pOutputType = "CSV" Тогда
			Return vRetStr;
		Else
			vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/reservation/", "GuestGroupPreauthorisationStatus"));
			vRetXDTO.PreauthorisationNumber = "";
			vRetXDTO.ErrorDescription = Left(vErrorDescription, 2048);
			vRetXDTO.TotalSum = 0;
			vRetXDTO.TotalSumPresentation = "";
			vRetXDTO.Balance = 0;
			vRetXDTO.BalancePresentation = "";
			vRetXDTO.UUID = "";
			Return vRetXDTO;
		EndIf;
	EndTry;
EndFunction //cmWriteExternalPreauthorisation
