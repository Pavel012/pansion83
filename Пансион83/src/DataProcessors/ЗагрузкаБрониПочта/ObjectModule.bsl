////-----------------------------------------------------------------------------
//// Data processors framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура pmLoadDataProcessorAttributes(pParameter = Неопределено) Экспорт
//	cmLoadDataProcessorAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadDataProcessorAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmSaveDataProcessorAttributes() Экспорт
//	cmSaveDataProcessorAttributes(ThisObject);
//КонецПроцедуры //pmSaveDataProcessorAttributes
//
////-----------------------------------------------------------------------------
//// Initialize attributes with default values
//// Attention: This procedure could be called AFTER some attributes initialization
//// routine, so it SHOULD NOT reset attributes being set before
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ReservationStatus) And ЗначениеЗаполнено(Гостиница) Тогда
//		ReservationStatus = Гостиница.СтатусНовойБрониПоУмолчанию;
//	EndIf;
//	If InternetMailPOP3Port = 0 Тогда
//		InternetMailPOP3Port = 110;
//	EndIf;
//	If InternetMailTimeout = 0 Тогда
//		InternetMailTimeout = 60;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//// Run data processor in silent mode
////-----------------------------------------------------------------------------
//Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
//	// Do data exchange
//	pmLoadEMails(pIsInteractive);
//КонецПроцедуры //pmRun
//
////-----------------------------------------------------------------------------
//// Data processors framework end
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура ParseAndLoadReservation(pMessage)
//	// Try to find message text part with XML data
//	vXMLResDataText = "";
//	For Each vMessageText In pMessage.Texts Do
//		vStartPos = Find(vMessageText.Text, "<WriteExternalReservation>");
//		vEndPos = Find(vMessageText.Text, "</WriteExternalReservation>");
//		If vStartPos > 0 And vEndPos > 0 And vEndPos > vStartPos Тогда
//			// First try to find XML header with text encoding like <?xml version="1.0" encoding="windows-1251"?>
//			vXMLHeaderStartPos = Find(Left(vMessageText.Text, vStartPos), "<?xml version=");
//			If vXMLHeaderStartPos > 0 Тогда
//				vStartPos = vXMLHeaderStartPos;
//			EndIf;
//			// Retrieve message text block
//			vXMLResDataText = Mid(vMessageText.Text, vStartPos, vEndPos + 26);
//			Break;
//		EndIf;
//	EndDo;
//	If НЕ IsBlankString(vXMLResDataText) Тогда
//		// Initialize write external reservation API parameters
//		vReservationCode = "";
//		vGroupCode = 0;
//		vGroupDescription = "";
//		vGroupCustomer = "";
//		vReservationStatus = "";
//		vPeriodFrom = '00010101';
//		vPeriodTo = '00010101';
//		vHotel = "";
//		vRoomType = "";
//		vAccommodationType = "";
//		vClientType = "";
//		vRoomQuota = "";
//		vRoomRate = "";
//		vCustomer = "";
//		vContract = "";
//		vAgent = "";
//		vContactPerson = "";
//		vNumberOfRooms = 0;
//		vNumberOfPersons = 0;
//		vClientCode = "";
//		vClientLastName = "";
//		vClientFirstName = "";
//		vClientSecondName = "";
//		vClientSex = "";
//		vClientCitizenship = "";
//		vClientBirthDate = "";
//		vClientPhone = "";
//		vClientFax = "";
//		vClientEMail = "";
//		vClientRemarks = "";
//		vReservationRemarks = "";
//		vCar = "";
//		vPlannedPaymentMethod = "";
//		vExternalSystemCode = TrimAll(ExternalSystemCode);
//		// Try to parse reservation data XML
//		vXMLReader = New XMLReader();
//		vXMLReadParams = New XMLReaderSettings(, , XMLSpace.Preserve, , False, , , , , True);
//		vXMLReader.SetString(vXMLResDataText, vXMLReadParams);
//		vInElement = False;
//		vElementName = "";
//		While vXMLReader.Read() Do
//			If НЕ IsBlankString(vXMLReader.Name) And vXMLReader.NodeType = XMLNodeType.StartElement Тогда
//				vElementName = TrimAll(vXMLReader.Name);
//				vInElement = True;
//				Continue;
//			ElsIf НЕ IsBlankString(vXMLReader.Name) And vXMLReader.NodeType = XMLNodeType.EndElement Тогда
//				vInElement = False;
//				Continue;
//			ElsIf НЕ vInElement Or vXMLReader.NodeType <> XMLNodeType.Text Тогда
//				Continue;
//			EndIf;
//			If vElementName = "ReservationCode" Тогда
//				vReservationCode = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "GroupCode" Тогда
//				vGroupCode = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "GroupDescription" Тогда
//				vGroupDescription = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "GroupCustomer" Тогда
//				vGroupCustomer = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ReservationStatus" Тогда
//				vReservationStatus = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ПериодС" Тогда
//				If НЕ IsBlankString(vXMLReader.Value) Тогда
//					vDtStr = TrimAll(vXMLReader.Value);
//					vPeriodFrom = Date(Number(Left(vDtStr, 4)), Number(Mid(vDtStr, 6, 2)), Number(Mid(vDtStr, 9, 2)), Number(Mid(vDtStr, 12, 2)), Number(Mid(vDtStr, 15, 2)), 1);
//				EndIf;
//			ElsIf vElementName = "ПериодПо" Тогда
//				If НЕ IsBlankString(vXMLReader.Value) Тогда
//					vDtStr = TrimAll(vXMLReader.Value);
//					vPeriodTo = Date(Number(Left(vDtStr, 4)), Number(Mid(vDtStr, 6, 2)), Number(Mid(vDtStr, 9, 2)), Number(Mid(vDtStr, 12, 2)), Number(Mid(vDtStr, 15, 2)), 0);
//				EndIf;
//			ElsIf vElementName = "Гостиница" Тогда
//				vHotel = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ТипНомера" Тогда
//				vRoomType = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ВидРазмещения" Тогда
//				vAccommodationType = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ТипКлиента" Тогда
//				vClientType = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "КвотаНомеров" Тогда
//				vRoomQuota = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "Тариф" Тогда
//				vRoomRate = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "Контрагент" Тогда
//				vCustomer = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "Договор" Тогда
//				vContract = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "Агент" Тогда
//				vAgent = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "КонтактноеЛицо" Тогда
//				vContactPerson = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "КоличествоНомеров" Тогда
//				If НЕ IsBlankString(vXMLReader.Value) Тогда
//					vNumberOfRooms = Number(TrimAll(vXMLReader.Value));
//				EndIf;
//			ElsIf vElementName = "КоличествоЧеловек" Тогда
//				If НЕ IsBlankString(vXMLReader.Value) Тогда
//					vNumberOfPersons = Number(TrimAll(vXMLReader.Value));
//				EndIf;
//			ElsIf vElementName = "ClientCode" Тогда
//				vClientCode = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientLastName" Тогда
//				vClientLastName = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientFirstName" Тогда
//				vClientFirstName = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientSecondName" Тогда
//				vClientSecondName = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientSex" Тогда
//				vClientSex = Upper(Left(TrimAll(vXMLReader.Value), 1));
//			ElsIf vElementName = "ClientCitizenship" Тогда
//				vClientCitizenship = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientBirthDate" Тогда
//				If НЕ IsBlankString(vXMLReader.Value) Тогда
//					vDtStr = TrimAll(vXMLReader.Value);
//					vClientBirthDate = Date(Number(Left(vDtStr, 4)), Number(Mid(vDtStr, 6, 2)), Number(Mid(vDtStr, 9, 2)));
//				EndIf;
//			ElsIf vElementName = "ClientPhone" Тогда
//				vClientPhone = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientFax" Тогда
//				vClientFax = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientEMail" Тогда
//				vClientEMail = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ClientRemarks" Тогда
//				vClientRemarks = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ReservationRemarks" Тогда
//				vReservationRemarks = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "Car" Тогда
//				vCar = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "PlannedPaymentMethod" Тогда
//				vPlannedPaymentMethod = TrimAll(vXMLReader.Value);
//			ElsIf vElementName = "ExternalSystemCode" Тогда
//				If НЕ IsBlankString(vXMLReader.Value) Тогда
//					vExternalSystemCode = TrimAll(vXMLReader.Value);
//				EndIf;
//			EndIf;
//		EndDo;
//		vXMLReader.Close();
//		// Call API to create new reservation
//		cmWriteExternalReservation(vReservationCode, vGroupCode, vGroupDescription, 
//	                               vGroupCustomer, vReservationStatus, vPeriodFrom, vPeriodTo, 
//	                               vHotel, vRoomType, vAccommodationType, vClientType, vRoomQuota, 
//	                               vRoomRate, vCustomer, vContract, vAgent, vContactPerson, 
//	                               vNumberOfRooms, vNumberOfPersons, vClientCode, 
//	                               vClientLastName, vClientFirstName, vClientSecondName, 
//	                               vClientSex, vClientCitizenship, vClientBirthDate, 
//	                               vClientPhone, vClientFax, vClientEMail, 
//	                               vClientRemarks, , vReservationRemarks, vCar, 
//	                               vPlannedPaymentMethod, vExternalSystemCode, False, , "XDTO");
//	Else
//		WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Message text part with new reservation data was not found!';ru='Не найдена часть письма содержащая XML данные новой брони!';de='Der Teil des Schreibens mit XML-Daten der neuen Reservierung wurde nicht gefunden!'"));
//	EndIf;
//КонецПроцедуры //ParseAndLoadReservation
//
////-----------------------------------------------------------------------------
//Процедура pmLoadEMails(pIsInteractive = False) Экспорт
//	// Log processing start
//	WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
//	
//	// Check parameters
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		vMessage = NStr("ru='Не указана гостиница!';de='Das Гостиница ist nicht angegeben!';en = 'Гостиница is not set!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	If IsBlankString(EMail) Тогда
//		vMessage = NStr("ru='Не указан адрес электронной почты с которого получать сообщения с данными брони!';de='Die E-Mail-Adresse ist nicht angegeben, von der die Mitteilungen mit Reservierungsdaten empfangen werden sollen!';en='E-mail address to receive reservations from is not set!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	If IsBlankString(InternetMailPOP3ServerAddress) Тогда
//		vMessage = NStr("ru='Не указан адрес сервера электронной почты с которого получать сообщения с данными брони!';de='Die Adresse des E-Mail-Servers ist nicht angegeben, von dem die Mitteilungen mit Reservierungsdaten empfangen werden sollen!';en='POP3 server address to receive reservations from is not set!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	If IsBlankString(InternetMailPOP3Authentication) Тогда
//		vMessage = NStr("ru='Не указан тип аутентификации на сервере электронной почты!';de='Der Authentifizierungsweg auf dem E-Mai-Server ist nicht angegeben!';en='POP3 server authentication type is not set!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	If IsBlankString(InternetMailUser) Тогда
//		vMessage = NStr("ru='Не указан логин на сервер электронной почты!';de='Login zum E-Mail-Server ist nicht angegeben!';en='POP3 server login is not set!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	
//	// Get platform version
//	vAppVersion = cmGetPlatformVersion();
//	
//	// Try to connect to the POP3 server
//	vProfile = New InternetMailProfile();
//	vProfile.POP3BeforeSMTP = False;
//	vProfile.POP3ServerAddress = TrimAll(InternetMailPOP3ServerAddress);
//	vProfile.POP3Port = ?(InternetMailPOP3Port = 0, 110, InternetMailPOP3Port);
//	If vAppVersion = "8.3" Тогда
//		vProfile.POP3UseSSL = InternetMailPOP3UseSSL;
//		vProfile.POP3SecureAuthenticationOnly = InternetMailPOP3SecureAuthenticationOnly;
//	EndIf;
//	vProfile.POP3Authentication = cmGetPOP3Authentication(InternetMailPOP3Authentication);
//	vProfile.User = TrimAll(InternetMailUser);
//	vProfile.Password = TrimR(InternetMailPassword);
//	vProfile.Timeout = ?(InternetMailTimeout = 0, 30, InternetMailTimeout);
//	vInternetMail = New InternetMail;
//	vInternetMail.Logon(vProfile);
//	
//	// Receive new E-mails
//	vNewMessages = vInternetMail.Get(True);
//	If vNewMessages.Count() > 0 Тогда
//		For Each vNewMessage In vNewMessages Do
//			ParseAndLoadReservation(vNewMessage);
//		EndDo;
//	Else
//		WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='No new e-mails!';ru='Нет новых сообщений!';de='Es gibt keine neuen Mitteilungen!'"));
//	EndIf;
//	
//	// Logoff from the mail server 
//	vInternetMail.Logoff();
//	
//	// Log end of processing
//	WriteLogEvent(NStr("en='DataProcessor.LoadEMailReservations';ru='Обработка.ЗагрузкаEMailСообщенийСДаннымиБрони';de='DataProcessor.LoadEMailReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
//КонецПроцедуры //pmLoadEMails
