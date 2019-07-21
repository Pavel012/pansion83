//-----------------------------------------------------------------------------
Function cmCreateCloseOfPeriodJob(pCompany, pHotel, pDescription, pUserName) Экспорт
	vJob = РегламентныеЗадания.СоздатьРегламентноеЗадание(Metadata.ScheduledJobs.ЗакрытиеПериодаАвто);
	vJob.Use = True;
	vJob.Description = СокрЛП(pDescription);
	vJob.UserName = СокрЛП(pUserName);
	vJobParameters = New Array();
	vJobParameters.Add(pCompany);
	vJobParameters.Add(pHotel);
	vJob.Parameters = vJobParameters;
	vJob.Write();
	Return vJob.UUID;
EndFunction //cmCreateCloseOfPeriodJob

//-----------------------------------------------------------------------------
Процедура cmUpdateCloseOfPeriodJob(pJobUUID, pCompany, pHotel, pDescription, pUserName) Экспорт
	vJob = ScheduledJobs.FindByUUID(New UUID(pJobUUID));
	If vJob <> Неопределено Тогда
		vJob.Description = СокрЛП(pDescription);
		vJob.UserName = СокрЛП(pUserName);
		vJobParameters = New Array();
		vJobParameters.Add(pCompany);
		vJobParameters.Add(pHotel);
		vJob.Parameters = vJobParameters;
		vJob.Write();
	EndIf;
КонецПроцедуры //cmUpdateCloseOfPeriodJob

//-----------------------------------------------------------------------------
Процедура cmDeleteCloseOfPeriodJob(pJobUUID) Экспорт
	vJob = ScheduledJobs.FindByUUID(New UUID(pJobUUID));
	If vJob <> Неопределено Тогда
		vJob.Delete();
	EndIf;
КонецПроцедуры //cmDeleteCloseOfPeriodJob

//-----------------------------------------------------------------------------
Function cmGetCloseOfPeriodJob(pJobUUID) Экспорт
	vJob = ScheduledJobs.FindByUUID(New UUID(pJobUUID));
	Return vJob;
EndFunction //cmGetCloseOfPeriodJob
                                         
//-----------------------------------------------------------------------------
Процедура cmProcessCloseOfPeriodJob(pCompany, pHotel) Экспорт
	If ЗначениеЗаполнено(pCompany) Тогда
		vCloseOfPeriodObj = Documents.ЗакрытиеПериода.CreateDocument();
		vCloseOfPeriodObj.Fill(pCompany);
		vCloseOfPeriodObj.Гостиница = pHotel;
		vCloseOfPeriodObj.Write(DocumentWriteMode.Posting);
	EndIf;
КонецПроцедуры //cmProcessCloseOfPeriodJob 

//-----------------------------------------------------------------------------
Function омСоздатьСМСАвтоОтправку(pHotel, pUser, pDeliveryTemplate, pDeliveryType, pMessageTemplate, pSender, pDescription) Экспорт
	vJob = ScheduledJobs.CreateScheduledJob(Metadata.РегламентныеЗадания.ЗакрытиеПериодаАвто);
	vJob.Use = True;
	vJob.Description = СокрЛП(pDescription);
	If ЗначениеЗаполнено(pUser) Тогда
		vJob.UserName = СокрЛП(InfoBaseUsers.FindByUUID(New UUID(СокрЛП(pUser.Code))).Name);
	EndIf;
	vJobParameters = New Array();
	vJobParameters.Add(pHotel);
	vJobParameters.Add(pSender);
	vJobParameters.Add(pDeliveryTemplate);
	vJobParameters.Add(pMessageTemplate);
	vJobParameters.Add(pDeliveryType);
	vJob.Parameters = vJobParameters;
	vJob.Write();
	Return vJob.UUID;
EndFunction //cmCreateSMSAutoDeliveryJob

//-----------------------------------------------------------------------------
Процедура cmUpdateSMSAutoDeliveryJob(pJobUUID, pHotel, pUser, pDeliveryTemplate, pDeliveryType, pMessageTemplate, pSender, pDescription) Экспорт
	vJob = ScheduledJobs.FindByUUID(New UUID(pJobUUID));
	If vJob <> Неопределено Тогда
		vJob.Description = СокрЛП(pDescription);
		vJob.UserName = СокрЛП(pUser);
		vJobParameters = New Array();
		vJobParameters.Add(pHotel);
		vJobParameters.Add(pSender);
		vJobParameters.Add(pDeliveryTemplate);
		vJobParameters.Add(pMessageTemplate);
		vJobParameters.Add(pDeliveryType);
		vJob.Parameters = vJobParameters;
		vJob.Write();
	EndIf;
КонецПроцедуры //cmUpdateSMSAutoDeliveryJob

//-----------------------------------------------------------------------------
Процедура cmDeleteSMSAutoDeliveryJob(pJobUUID) Экспорт
	vJob = регламентныезадания.НайтиПоУникальномуИдентификатору(новый  УникальныйИдентификатор(pJobUUID));
	If vJob <> Неопределено Тогда
		vJob.Delete();
	EndIf;
КонецПроцедуры //cmDeleteSMSAutoDeliveryJob

//-----------------------------------------------------------------------------
Function cmGetSMSAutoDeliveryJob(pJobUUID) Экспорт
	vJob = Регламентныезадания.НайтиПоУникальномуИдентификатору(New UUID(pJobUUID));
	Return vJob;
EndFunction //cmGetSMSAutoDeliveryJob

//-----------------------------------------------------------------------------
Процедура cmRefreshFullTextSearchIndex() Экспорт
	If FullTextSearch.GetFullTextSearchMode() = FullTextSearchMode.Enable Тогда
		If НЕ FullTextSearch.IndexTrue() Тогда
			FullTextSearch.UpdateIndex(False, True);
		EndIf;
	EndIf;
КонецПроцедуры //cmRefreshFullTextSearchIndex

//-----------------------------------------------------------------------------
Процедура cmJoinFullTextSearchIndexes() Экспорт
	If FullTextSearch.GetFullTextSearchMode() = FullTextSearchMode.Enable Тогда
		If НЕ FullTextSearch.IndexUpdateComplete() Тогда
			FullTextSearch.UpdateIndex(True, True);
		EndIf;
	EndIf;
КонецПроцедуры //cmJoinFullTextSearchIndexes

//-----------------------------------------------------------------------------
Процедура cmLoadCurrencyRatesForTomorrow() Экспорт
	// Reference to the appropriate data processor catalog item object
	vDPRef = Справочники.Обработки.LoadCurrencyRatesForTomorrow;
	// Call load rates procedure for every hotel defined
	vHotels = cmGetAllHotels();
	For Each vHotelsRow In vHotels Do
		// Run data processor
		cmRunDataProcessor(vDPRef, vHotelsRow.Гостиница);
	EndDo;
КонецПроцедуры //cmLoadCurrencyRatesForTomorrow

//-----------------------------------------------------------------------------
// Description: Runs "Disable no-show reservations" data processor for the all 
//              hotels defined
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmDisableNoShowReservationsForToday() Экспорт
	// Reference to the appropriate data processor catalog item object
	vDPRef = Справочники.Обработки.DisableNoShowReservations;
	// Call disable no show reservations data processor for every hotel defined
	vHotels = cmGetAllHotels();
	For Each vHotelsRow In vHotels Do
		// Run data processor
		cmRunDataProcessor(vDPRef, vHotelsRow.Гостиница);
	EndDo;
КонецПроцедуры //cmDisableNoShowReservationsForToday

//-----------------------------------------------------------------------------
// Description: Runs "Release expired ГруппаНомеров allotments" data processor for the all 
//              hotels defined
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmReleaseExpiredRoomAllotments() Экспорт
	// Reference to the appropriate data processor catalog item object
	vDPRef = Справочники.Обработки.ReleaseExpiredRoomAllotments;
	// Call release expired ГруппаНомеров allotments data processor for every hotel defined
	vHotels = cmGetAllHotels();
	For Each vHotelsRow In vHotels Do
		// Run data processor
		cmRunDataProcessor(vDPRef, vHotelsRow.Гостиница);
	EndDo;
КонецПроцедуры //cmReleaseExpiredRoomAllotments

//-----------------------------------------------------------------------------
// Description: Runs "Process finished resource reservations" data processor for the all 
//              hotels defined
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmProcessFinishedResourceReservations() Экспорт
	// Reference to the appropriate data processor catalog item object
	vDPRef = Справочники.Обработки.ОбработатьЗавершеннуюБроньРесурсов;
	// Call data processor for every hotel defined
	vHotels = cmGetAllHotels();
	For Each vHotelsRow In vHotels Do
		// Run data processor
		cmRunDataProcessor(vDPRef, vHotelsRow.Гостиница);
	EndDo;
КонецПроцедуры //cmProcessFinishedResourceReservations

//-----------------------------------------------------------------------------
// Description: Runs "Manage Has ГруппаНомеров blocks flag" data processor for the all 
//              hotels defined
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmManageHasRoomBlocks() Экспорт
	// Reference to the appropriate data processor catalog item object
	vDPRef = Справочники.Обработки.ManageHasRoomBlocks;
	// Call data processor for every hotel defined
	vHotels = cmGetAllHotels();
	For Each vHotelsRow In vHotels Do
		// Run data processor
		cmRunDataProcessor(vDPRef, vHotelsRow.Гостиница);
	EndDo;
КонецПроцедуры //cmManageHasRoomBlocks

//-----------------------------------------------------------------------------
// Description: Runs "Clear database" data processor for the all 
//              hotels defined
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmClearDatabase() Экспорт
	// Reference to the appropriate data processor catalog item object
	vDPRef = Справочники.Обработки.ОчисткаБазы;
	// Call clear database data processor for every hotel defined
	vHotels = cmGetAllHotels();
	For Each vHotelsRow In vHotels Do
		// Run data processor
		cmRunDataProcessor(vDPRef, vHotelsRow.Гостиница);
	EndDo;
КонецПроцедуры //cmClearDatabase

//-----------------------------------------------------------------------------
// Description: Runs data processors found by key string
// Parameters: Key string
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmRunDataProcessorsByKey(pKey) Экспорт
	// Get catalog items by key
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Обработки.Ref AS DataProcessor
	|FROM
	|	Catalog.Обработки AS Обработки
	|WHERE
	|	Обработки.Key = &qKey
	|	AND Обработки.DeletionMark = FALSE
	|ORDER BY
	|	Обработки.ПорядокСортировки";
	vQry.SetParameter("qKey", pKey);
	vDPList = vQry.Execute().Unload();
	// Run all retrieved data processors
	For Each vDPRow In vDPList Do
		vDPRef = vDPRow.DataProcessor;
		cmRunDataProcessor(vDPRef);
	EndDo;
КонецПроцедуры //cmRunDataProcessorsByKey

//-----------------------------------------------------------------------------
// Description: Runs reports found by key string
// Parameters: Key string
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmRunReportsByKey(pKey) Экспорт
	// Add record to the information register
	vRecordManager = InformationRegisters.ОтчетыПоРасписанию.CreateRecordManager();
	vRecordManager.ScheduleDateTime = CurrentDate();
	vRecordManager.Key = TrimR(pKey);
	vRecordManager.Write(True);
КонецПроцедуры //cmRunReportsByKey

//-----------------------------------------------------------------------------
// Description: Sends text by e-mail
// Parameters: Message subject, Message text, E-Mails list, Whether fuction is called in 
//             the application server context
// Return value: True if success, False if not
//-----------------------------------------------------------------------------
Function cmSendTextByEMail(pSubject, pMessage, pEMails, pIsOnServer = False, rErrorMessage, rSMTPConnection = Неопределено, pLogoff = Неопределено, pAttachmentPath = "") Экспорт
	rErrorMessage = "";
	
	// Get current employee settings
	vCurEmployee = ПараметрыСеанса.ТекПользователь;
	If НЕ ЗначениеЗаполнено(vCurEmployee) Тогда
		rErrorMessage = "ru = Невозможно отправить E-mail на адрес " + СокрЛП(pEMails) + "! Не определен текущий пользователь!";
		WriteLogEvent(" ЭлектроннаяПочта.ОтправитьТекст;", EventLogLevel.Warning, , , rErrorMessage);
		If pIsOnServer Тогда
			ВызватьИсключение rErrorMessage;
		EndIf;
		Return False;
	EndIf;
	
	vResult = True;
	Try
		// Create E-Mail message
		vEMail = New InternetMailMessage();
		// Addresses and names
		vEMail.SenderName = vCurEmployee.GetObject().pmGetEmployeeDescription(ПараметрыСеанса.ТекЛокализация);
		If НЕ IsBlankString(vCurEmployee.EMail) Тогда
			vEMail.From = СокрЛП(vCurEmployee.EMail);
		EndIf;
		If НЕ IsBlankString(vCurEmployee.ReplyToEMail) Тогда
			vEMailsList = cmParseEMailAddress(СокрЛП(vCurEmployee.ReplyToEMail));
			For Each vEMailItem In vEMailsList Do
				vEMail.ReplyTo.Add(vEMailItem.Value);
			EndDo;
		EndIf;
		// Add to address
		vEMailsList = cmParseEMailAddress(pEMails);
		For Each vEMailItem In vEMailsList Do
			vEMail.To.Add(vEMailItem.Value);
		EndDo;
		// Add Bcc address
		If НЕ IsBlankString(vCurEmployee.BccEMail) Тогда
			vEMailsList = cmParseEMailAddress(vCurEmployee.BccEMail);
			For Each vEMailItem In vEMailsList Do
				vEMail.Bcc.Add(vEMailItem.Value);
			EndDo;
		EndIf;
		// Add message subject and text
		vEMail.Subject = СокрЛП(pSubject);
		If Find(Lower(СокрЛП(pMessage)), "<html") = 0 Тогда
			vEMail.Texts.Add(СокрЛП(pMessage));
		Else
			vEMail.Texts.Add(СокрЛП(pMessage), InternetMailTextType.HTML);
			vEMail.ProcessTexts();
		EndIf;
		// Add file as attachement
		If НЕ IsBlankString(pAttachmentPath) Тогда
			vEMail.Attachments.Add(СокрЛП(pAttachmentPath), cmGetFileName(pAttachmentPath));
		EndIf;
		// Get platform version
		vAppVersion = cmGetPlatformVersion();
		// Create profile to use for connection
		vProfile = New InternetMailProfile();
		vProfile.POP3BeforeSMTP = vCurEmployee.InternetMailPOP3BeforeSMTP;
		If vProfile.POP3BeforeSMTP Тогда
			vProfile.POP3ServerAddress = vCurEmployee.InternetMailPOP3ServerAddress;
			vProfile.POP3Port = vCurEmployee.InternetMailPOP3Port;
			If vAppVersion = "8.3" Тогда
				vProfile.POP3UseSSL = vCurEmployee.InternetMailPOP3UseSSL;
				vProfile.POP3SecureAuthenticationOnly = vCurEmployee.InternetMailPOP3SecureAuthenticationOnly;
			EndIf;
			vProfile.POP3Authentication = cmGetPOP3Authentication(vCurEmployee.InternetMailPOP3Authentication);
			vProfile.User = vCurEmployee.InternetMailUser;
			vProfile.Password = vCurEmployee.InternetMailPassword;
		EndIf;
		vProfile.SMTPServerAddress = vCurEmployee.InternetMailSMTPServerAddress;
		vProfile.SMTPPort = vCurEmployee.InternetMailSMTPPort;
		If vAppVersion = "8.3" Тогда
			vProfile.SMTPUseSSL = vCurEmployee.InternetMailSMTPUseSSL;
			vProfile.SMTPSecureAuthenticationOnly = vCurEmployee.InternetMailSMTPSecureAuthenticationOnly;
		EndIf;
		vProfile.SMTPAuthentication = cmGetSMTPAuthentication(vCurEmployee.InternetMailSMTPAuthentication);
		vProfile.SMTPUser = vCurEmployee.InternetMailSMTPUser;
		vProfile.SMTPPassword = vCurEmployee.InternetMailSMTPPassword;
		vProfile.Timeout = ?(vCurEmployee.InternetMailTimeout, 30, vCurEmployee.InternetMailTimeout);

		// Create connection to the mail server
		If rSMTPConnection = Неопределено Тогда
			rSMTPConnection = New InternetMail;
	    	rSMTPConnection.Logon(vProfile);
		EndIf;
		rSMTPConnection.Send(vEMail);
		If pLogoff = Неопределено Or pLogoff Тогда
			rSMTPConnection.Logoff();
		EndIf;
	Except
		rErrorMessage = "ru = 'Невозможно отправить E-Mail на адрес " + СокрЛП(pEMails) + "! Описание ошибки:" + ErrorDescription();
		WriteLogEvent(" ЭлектроннаяПочта.ОтправитьТекст", EventLogLevel.Warning, , , rErrorMessage);
		If pIsOnServer Тогда
			ВызватьИсключение rErrorMessage;
		EndIf;
		vResult = False;
	EndTry;
	
	// Return result
	If НЕ vResult Тогда
		rErrorMessage = СтрЗаменить(rErrorMessage, "{ОбщийМодуль.РеглЗадания.Module(281)}: ", "");
		rErrorMessage = СтрЗаменить(rErrorMessage, "{ОбщийМодуль.РеглЗадания.Module(283)}: ", "");
		rErrorMessage = СтрЗаменить(rErrorMessage, "{ОбщийМодуль.CommonFunctions.Module", "");
	EndIf;
	Return vResult;
EndFunction //cmSendTextByEMail

//-----------------------------------------------------------------------------
// Description: Sends file by e-mail
// Parameters: Message subject, Message text, E-Mails list, File name to attach, 
//             Full file name to attach, Language, Whether fuction is called in 
//             the application server context, Guest group
// Return value: True if success, False if not
//-----------------------------------------------------------------------------
Function cmSendFileByEMail(pSubject, pMessage, pEMails, pFileName, pFullFileName, pLanguage = Неопределено, pIsOnServer = False, pGuestGroup = Неопределено, pSenderName = "") Экспорт
	vLanguage = pLanguage;
	If НЕ ЗначениеЗаполнено(vLanguage) Тогда
		vLanguage = ПараметрыСеанса.ТекЛокализация;
	EndIf;
	
	// Get current employee settings
	vCurEmployee = ПараметрыСеанса.ТекПользователь;
	If НЕ ЗначениеЗаполнено(vCurEmployee) Тогда
		vError = NStr("ru = 'Невозможно отправить файл " + СокрЛП(pFileName) + " по электронной почте на адрес " + СокрЛП(pEMails) + "! Не определен текущий пользователь!'; 
		              |de = 'Unable to send file " + СокрЛП(pFileName) + " by e-mail to " + СокрЛП(pEMails) + "! Current user is not defined!'; 
		              |en = 'Unable to send file " + СокрЛП(pFileName) + " by e-mail to " + СокрЛП(pEMails) + "! Current user is not defined!'");
		Message(vError, MessageStatus.Attention);
		WriteLogEvent(NStr("en='InternetMail.SendFile';ru='ЭлектроннаяПочта.ОтправитьФайл';de='InternetMail.SendFile'"), EventLogLevel.Warning, , , vError);
		If pIsOnServer Тогда
			ВызватьИсключение vError;
		EndIf;
		Return False;
	EndIf;
	// Remove forbidden chars from file name
	vFileName = cmGetValidFileName(pFileName);
	
	Try
		// Create E-Mail message
		vEMail = New InternetMailMessage();
		// Addresses and names
		If НЕ IsBlankString(pSenderName) Тогда
			vEMail.SenderName = pSenderName;
		Else
			vEMail.SenderName = vCurEmployee.GetObject().pmGetEmployeeDescription(vLanguage);
		EndIf;
		If НЕ IsBlankString(vCurEmployee.EMail) Тогда
			vEMail.From = СокрЛП(vCurEmployee.EMail);
		EndIf;
		If НЕ IsBlankString(vCurEmployee.ReplyToEMail) Тогда
			vEMailsList = cmParseEMailAddress(СокрЛП(vCurEmployee.ReplyToEMail));
			For Each vEMailItem In vEMailsList Do
				vEMail.ReplyTo.Add(vEMailItem.Value);
			EndDo;
		EndIf;
		// Add to address
		vEMailsList = cmParseEMailAddress(pEMails);
		For Each vEMailItem In vEMailsList Do
			vEMail.To.Add(vEMailItem.Value);
		EndDo;
		// Add Bcc address
		If НЕ IsBlankString(vCurEmployee.BccEMail) Тогда
			vEMailsList = cmParseEMailAddress(vCurEmployee.BccEMail);
			For Each vEMailItem In vEMailsList Do
				vEMail.Bcc.Add(vEMailItem.Value);
			EndDo;
		EndIf;
		// Add file as attachement
		vEMail.Attachments.Add(pFullFileName, vFileName);
		// Add message subject and text
		vEMail.Subject = СокрЛП(pSubject);
		vEMail.Texts.Add(СокрЛП(pMessage));
		
		// Get platform version
		vAppVersion = cmGetPlatformVersion();

		// Create profile to use for connection
		vProfile = New InternetMailProfile();
		vProfile.POP3BeforeSMTP = vCurEmployee.InternetMailPOP3BeforeSMTP;
		If vProfile.POP3BeforeSMTP Тогда
			vProfile.POP3ServerAddress = vCurEmployee.InternetMailPOP3ServerAddress;
			vProfile.POP3Port = vCurEmployee.InternetMailPOP3Port;
			If vAppVersion = "8.3" Тогда
				vProfile.POP3UseSSL = vCurEmployee.InternetMailPOP3UseSSL;
				vProfile.POP3SecureAuthenticationOnly = vCurEmployee.InternetMailPOP3SecureAuthenticationOnly;
			EndIf;
			vProfile.POP3Authentication = cmGetPOP3Authentication(vCurEmployee.InternetMailPOP3Authentication);
			vProfile.User = vCurEmployee.InternetMailUser;
			vProfile.Password = vCurEmployee.InternetMailPassword;
		EndIf;
		vProfile.SMTPServerAddress = vCurEmployee.InternetMailSMTPServerAddress;
		vProfile.SMTPPort = vCurEmployee.InternetMailSMTPPort;
		If vAppVersion = "8.3" Тогда
			vProfile.SMTPUseSSL = vCurEmployee.InternetMailSMTPUseSSL;
			vProfile.SMTPSecureAuthenticationOnly = vCurEmployee.InternetMailSMTPSecureAuthenticationOnly;
		EndIf;
		vProfile.SMTPAuthentication = cmGetSMTPAuthentication(vCurEmployee.InternetMailSMTPAuthentication);
		vProfile.SMTPUser = vCurEmployee.InternetMailSMTPUser;
		vProfile.SMTPPassword = vCurEmployee.InternetMailSMTPPassword;
		vProfile.Timeout = ?(vCurEmployee.InternetMailTimeout = 0, 30, vCurEmployee.InternetMailTimeout);

		// Create connection to the mail server
		vInternetMail = New InternetMail;
    	vInternetMail.Logon(vProfile);
		vInternetMail.Send(vEMail);
		vInternetMail.Logoff();
	Except
		vError = NStr("ru = 'Невозможно отправить файл " + СокрЛП(pFileName) + " по электронной почте на адрес " + СокрЛП(pEMails) + "! Описание ошибки: '; 
		              |de = 'Unable to send file " + СокрЛП(pFileName) + " by e-mail to " + СокрЛП(pEMails) + "! Error description: ';
		              |en = 'Unable to send file " + СокрЛП(pFileName) + " by e-mail to " + СокрЛП(pEMails) + "! Error description: '") + ErrorDescription();
		Message(vError, MessageStatus.Attention);
		WriteLogEvent(NStr("en='InternetMail.SendFile';ru='ЭлектроннаяПочта.ОтправитьФайл';de='InternetMail.SendFile'"), EventLogLevel.Warning, , , vError);
		If pIsOnServer Тогда
			ВызватьИсключение vError;
		EndIf;
		Return False;
	EndTry;
	
	// Write guest group attachment that message was sent
	Try
		If ЗначениеЗаполнено(pGuestGroup) Тогда
			vGrpAttachmentsRecMgr = InformationRegisters.ДокументыГруппыСведения.CreateRecordManager();
			vGrpAttachmentsRecMgr.Period = CurrentDate();
			vGrpAttachmentsRecMgr.ГруппаГостей = pGuestGroup;
			vGrpAttachmentsRecMgr.EMail = pEMails;
			If ЗначениеЗаполнено(pGuestGroup.Клиент) Тогда
				vGrpAttachmentsRecMgr.Fax = pGuestGroup.Клиент.Fax;
			EndIf;
			vGrpAttachmentsRecMgr.AttachmentStatus = Перечисления.AttachmentStatuses.Sent;
			vGrpAttachmentsRecMgr.AttachmentType = Перечисления.AttachmentTypes.EMail;
			vLanguage = pGuestGroup.Owner.Language;
			If ЗначениеЗаполнено(pGuestGroup.Клиент) And ЗначениеЗаполнено(pGuestGroup.Клиент.Language) Тогда
				vLanguage = pGuestGroup.Клиент.Language;
			EndIf;
			vGrpAttachmentsRecMgr.Примечания = СокрЛП(pSubject); 
			vGrpAttachmentsRecMgr.DocumentText = СокрЛП(pMessage);
			vFile = New File(pFullFileName);
			If vFile.Exist() And vFile.IsFile() Тогда
				vGrpAttachmentsRecMgr.FileName = vFileName;
				vGrpAttachmentsRecMgr.FileLoadTime = CurrentDate();
				vGrpAttachmentsRecMgr.FileLastChangeTime = vFile.GetModificationTime();
				vBinary = New BinaryData(pFullFileName);
				vGrpAttachmentsRecMgr.ExtFile = New ValueStorage(vBinary);
			EndIf;
			// Write attachment
			vGrpAttachmentsRecMgr.Write();
		EndIf;
	Except
		vError = NStr("ru = 'Ошибка регистрации факта отправки сообщения " + СокрЛП(pFileName) + " по электронной почте на адрес " + СокрЛП(pEMails) + "! Описание ошибки: '; 
		              |de = 'Failed to write guest group attachment for e-mail message " + СокрЛП(pFileName) + " to " + СокрЛП(pEMails) + "! Error description: ';
		              |en = 'Failed to write guest group attachment for e-mail message " + СокрЛП(pFileName) + " to " + СокрЛП(pEMails) + "! Error description: '") + 
		         ErrorDescription();
		Message(vError, MessageStatus.Attention);
		WriteLogEvent(NStr("en='InternetMail.SendFile';ru='ЭлектроннаяПочта.ОтправитьФайл';de='InternetMail.SendFile'"), EventLogLevel.Warning, , , vError);
	EndTry;
	
	// Return success
	Return True;
EndFunction //cmSendFileByEMail

//-----------------------------------------------------------------------------
// Description: Процедура recalculates totals for accumulation registers 
//              if it is necessary
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmRecalculateAccumulationRegistersTotals() Экспорт
	vNotificationStartDay = 5;
	vRecalculateDay = 10;
	
	// Check if it is necessary to recalculate totals
	vRecalculationIsNecessary = True;
	vCurrentDayOfMonth = Day(CurrentDate());	
	If vCurrentDayOfMonth < vNotificationStartDay Тогда
		vRecalculationIsNecessary = False;
	Else
		If vCurrentDayOfMonth < vRecalculateDay Тогда
			vThereAreActiveUsers = False;
			Try
				SetExclusiveMode(True);
			Except
				vThereAreActiveUsers = True;
			EndTry;
			If НЕ vThereAreActiveUsers Тогда
				SetExclusiveMode(False);
			EndIf;
			vRecalculationIsNecessary = НЕ vThereAreActiveUsers;
		Else
			vRecalculationIsNecessary = True;
		EndIf;
	EndIf;
	If НЕ vRecalculationIsNecessary Тогда
		Return;
	EndIf;
	
	// Build list of registers to recalculate
	vRecalculationDate = BegOfMonth(CurrentDate()) - 1;
	vRegistersList = New СписокЗначений();
	For Each vRegister In AccumulationRegisters Do
		vRegisterMetadata = Metadata.FindByType(TypeOf(vRegister));
		If vRegisterMetadata.RegisterType = Metadata.ObjectProperties.AccumulationRegisterType.Balance Тогда
			If vRegister.GetTotalsPeriod() < vRecalculationDate Тогда
				If ПравоДоступа("TotalsControl", vRegisterMetadata) Тогда
					vRegistersList.Add(vRegister, NStr("en='Accumulation register ';ru='Регистр накопления ';de='Akkumulationsregister '") + vRegisterMetadata.Presentation());
				EndIf;
			EndIf;			
		EndIf;
	EndDo;	
	If vRegistersList.Count() = 0 Тогда
		Return;
	EndIf;

	// Recalculate registers
	For Each vRegisterItem In vRegistersList Do
		vRegister = vRegisterItem.Value;
		vRegister.SetTotalsPeriod(vRecalculationDate);
		
		// Add record to the system log
		vRegisterMetadata = Metadata.FindByType(TypeOf(vRegister));
		vMessage = NStr("ru = 'Итоги регистра накопления " + vRegisterMetadata.Presentation() + " были рассчитаны по " + Format(vRecalculationDate, "DF=dd.MM.yyyy") + "'; 
		                |de = '" + vRegisterMetadata.Presentation() + " accumulation register totals were recalculated to " + Format(vRecalculationDate, "DF=dd.MM.yyyy") + "'; 
		                |en = '" + vRegisterMetadata.Presentation() + " accumulation register totals were recalculated to " + Format(vRecalculationDate, "DF=dd.MM.yyyy") + "'");
		WriteLogEvent(NStr("en='AccumulationRegisters.TotalsRecalculation';ru='РегистрыНакопления.ПересчетИтогов';de='AccumulationRegisters.TotalsRecalculation'"), EventLogLevel.Information, vRegisterMetadata, , vMessage);
	EndDo;
КонецПроцедуры //cmRecalculateAccumulationRegistersTotals

//-----------------------------------------------------------------------------

