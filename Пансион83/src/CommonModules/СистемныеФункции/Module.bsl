//-----------------------------------------------------------------------------
// Description: Returns current exchange plan node
// Parameters: Node whose exchange plan to search for current node
// Возврат value: Exchange plan node
//-----------------------------------------------------------------------------
Функция омПереименоватьУзел(pNode) Экспорт
	Если pNode = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	Возврат ExchangePlans[pNode.Метаданные().Name].ThisNode();
EndFunction //cmGetThisNode

//-----------------------------------------------------------------------------
// Description: Removes .xml and .zip file with given name from the program temp 
//              directory
// Parameters: File name to search, Whether to delete .zip files or not
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура RemoveTempExchangeFiles(pFileName, pArchive)
	vTempXML = Новый File(pFileName + ".xml");
	Если vTempXML.Exist() Тогда
		DeleteFiles(pFileName + ".xml");
	КонецЕсли;
	Если pArchive Тогда
		vTempZIP = Новый File(pFileName + ".zip");
		Если vTempZIP.Exist() Тогда
			DeleteFiles(pFileName + ".zip");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //RemoveTempExchangeFiles

//-----------------------------------------------------------------------------
// Description: Writes exchange plan changes to the file on file system or FTP
//              server
// Parameters: Exchange plan node, Target directory or path at the FTP server, 
//             Number of objects to write in one transaction, Whether to archive 
//             file with changes or not, Zip password, Whether to put file at the 
//             FTP server or not, FTP server address, FTP user name, FTP user password,
//             FTP server port, Whether to use passive mode, FTP connection timeout,
//             Whether to use proxy server or not, Proxy server user, Proxy server 
//             user password
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmWriteExchangePlanChanges(pNode, Val pTargetAddress = "", pObjectsInTranCount = 0, pDoZip = True, pZipPwd = "", 
	                                 pUseFTP = False, pFTPAddress = "", pFTPUser = "", pFTPPwd = "", pFTPPort = 21, pUsePassiveMode = False, pFTPConnectionTimeout = 0, 
									 pInternetConnectionSettings = Неопределено) Экспорт
	Если pNode = Неопределено Тогда
		ВызватьИсключение "Не выбран узел для отправки изменений!";
	КонецЕсли;
	// Get and check this node
	vThisNode = омПереименоватьУзел(pNode);
	Если vThisNode = Неопределено Тогда
		ВызватьИсключение NStr("en='<This node> is not defined for the current configuration!';ru='В текущей конфигурации не определен <Этот узел>!';de='Из der aktuellen Konfiguration ist <Dieser Knoten> nicht festgelegt!'");
	КонецЕсли;
	Если pNode = vThisNode Тогда
		ВызватьИсключение NStr("en='Node to send changes to should not be this node!';ru='Нельзя отправлять изменения в текущий узел!';de='Änderungen dürfen nicht an den aktuellen Knoten gesendet werden!'");
	КонецЕсли;
	
	// Get temporal directory path and initialize file name
	vTempDirPath = СокрЛП(TempFilesDir());
	vTempDirPath = StrReplace(vTempDirPath, "\", "/");
	Если Right(vTempDirPath, 1) <> "/" Тогда
		vTempDirPath = vTempDirPath + "/";
	КонецЕсли;
	
	// Check path to write data to
	pTargetAddress = StrReplace(СокрЛП(pTargetAddress), "\", "/");
	Если Right(pTargetAddress, 1) <> "/" Тогда
		pTargetAddress = pTargetAddress + "/";
	КонецЕсли;
	
	// Initialize file name
	vMessageFileName = "Message_" + Upper(СокрЛП(vThisNode.Code)) + "_" + Upper(СокрЛП(pNode.Code));
	
	// Build file name to be used further
	vExchangeFileName = vMessageFileName + ?(pDoZip, ".zip", ".xml");
	
	// Initialize number of attempts. Use 1 if function is running interactively and 20 if function is running on server
	vNumberOfAttempts = 1;
	Если Left(InfoBaseConnectionString(), 5) <> "File=" Тогда
		#IF SERVER THEN
			vNumberOfAttempts = 20;
		#ENDIF
	КонецЕсли;
	
	// Цикл 20 attempts in server mode (5 minutes of tries) before raising failure if any
	vAttemptTime = CurrentDate();
	Для i = 1 По vNumberOfAttempts Цикл
		Попытка
			// Удалить temp files left from a previous run
			RemoveTempExchangeFiles(vTempDirPath + vMessageFileName, pDoZip);
			
			// Записать XML file with changes
			vXMLWriter = Новый XMLWriter();
			vXMLWriter.OpenFile(vTempDirPath + vMessageFileName + ".xml");
			vXMLWriter.WriteXMLDeclaration();
			vMessageWriter = ExchangePlans.CreateMessageWriter();
			vMessageWriter.BeginWrite(vXMLWriter, pNode);
			ExchangePlans.WriteChanges(vMessageWriter, pObjectsInTranCount);
			vMessageWriter.EndWrite();
			vXMLWriter.Close();
			
			// Zip file with changes if necessary
			Если pDoZip Тогда
				vArchive = Новый ZipFileWriter(vTempDirPath + vMessageFileName + ".zip", pZipPwd, , ZIPCompressionMethod.Deflate, ZIPCompressionLevel.Maximum, ZIPEncryptionMethod.AES256);
				vArchive.Add(vTempDirPath + vMessageFileName + ".xml", ZIPStorePathMode.DontStorePath);
				vArchive.Записать();
			КонецЕсли;
			
			// Copy file to the FTP or file target directory
			Если НЕ IsBlankString(pTargetAddress) Тогда
				Если pUseFTP Тогда
					vProxy = cmGetInternetProxy(pInternetConnectionSettings, False, pFTPAddress);
					vFTPServer = Неопределено;
					Если vProxy <> Неопределено Тогда
					    vFTPServer = Новый FTPConnection(pFTPAddress, pFTPPort, pFTPUser, pFTPPwd, vProxy, pUsePassiveMode, pFTPConnectionTimeout);
					Иначе
					    vFTPServer = Новый FTPConnection(pFTPAddress, pFTPPort, pFTPUser, pFTPPwd, , pUsePassiveMode, pFTPConnectionTimeout);
					КонецЕсли;
					// Удалить file left from previous run
					Если vFTPServer.FindFiles(pTargetAddress + vExchangeFileName).Count() > 0 Тогда
						vFTPServer.Удалить(pTargetAddress + vExchangeFileName);
					КонецЕсли;
					// Put file to server
					vFTPServer.Put(vTempDirPath + vExchangeFileName, pTargetAddress + vExchangeFileName);
				Иначе
					// Copy file
					FileCopy(vTempDirPath + vExchangeFileName, pTargetAddress + vExchangeFileName);
				КонецЕсли;
			КонецЕсли;
			
			// Удалить temp files
			RemoveTempExchangeFiles(vTempDirPath + vMessageFileName, pDoZip);
			
			// Break attempts cycle if everything is OK
			Break;
		Except
			// Save current error description
			vErrorDescription = ErrorDescription();
			// Close file with XML changes
			Попытка
				vXMLWriter.Close();
			Except
			EndTry;
			Если i = vNumberOfAttempts Тогда
				ВызватьИсключение vErrorDescription;
			Иначе
				// Wait 15 seconds and try again
				vGap = CurrentDate() - vAttemptTime;
				Пока vGap < 15 Цикл
					vGap = CurrentDate() - vAttemptTime;
				КонецЦикла;
				vAttemptTime = CurrentDate();
			КонецЕсли;
		EndTry;
	КонецЦикла;
КонецПроцедуры //cmWriteExchangePlanChanges

//-----------------------------------------------------------------------------
// Description: Reads exchange plan changes from the file on file system or FTP
//              server
// Parameters: Exchange plan node, Target directory or path at the FTP server, 
//             Number of objects to write in one transaction, Whether to unzip 
//             file with changes or not, Zip password, Whether to get file from the 
//             FTP server or not, FTP server address, FTP user name, FTP user password,
//             FTP server port, Whether to use passive mode, FTP connection timeout,
//             Whether to use proxy server or not, Proxy server user, Proxy server 
//             user password
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReadExchangePlanChanges(pNode, Val pSourceAddress = "", pObjectsInTranCount = 0, pUnzip = True, pZipPwd = "", 
	                                pUseFTP = False, pFTPAddress = "", pFTPUser = "", pFTPPwd = "", pFTPPort = 21, pUsePassiveMode = False, pFTPConnectionTimeout = 0, 
									pInternetConnectionSettings = Неопределено) Экспорт
	Если pNode = Неопределено Тогда
		ВызватьИсключение "Не выбран узел от которого нужно получить изменения!";
	КонецЕсли;
	// Get and check this node
	vThisNode = омПереименоватьУзел(pNode);
	Если vThisNode = Неопределено Тогда
		ВызватьИсключение "В текущей конфигурации не определен <Этот узел>!";
	КонецЕсли;
	Если pNode = vThisNode Тогда
		ВызватьИсключение NStr("en='Node to receive changes from should not be this node!';ru='Нельзя получать изменения от текущего узла!';de='Vom aktuellen Knoten dürfen keine Änderungen bezogen werden!'");
	КонецЕсли;
	
	// Get temporal directory path 
	vTempDirPath = СокрЛП(TempFilesDir());
	vTempDirPath = StrReplace(vTempDirPath, "\", "/");
	Если Right(vTempDirPath, 1) <> "/" Тогда
		vTempDirPath = vTempDirPath + "/";
	КонецЕсли;
	
	// Check path to read data from
	pSourceAddress = StrReplace(СокрЛП(pSourceAddress), "\", "/");
	Если Right(pSourceAddress, 1) <> "/" Тогда
		pSourceAddress = pSourceAddress + "/";
	КонецЕсли;
	
	// Initialize file name
	vMessageFileName = "Message_" + Upper(СокрЛП(pNode.Code)) + "_" + Upper(СокрЛП(vThisNode.Code));
	
	// Build file name to be used further
	vExchangeFileName = vMessageFileName + ?(pUnzip, ".zip", ".xml");
	
	// Initialize number of attempts. Use 1 if function is running interactively and 20 if function is running on server
	vNumberOfAttempts = 1;
	Если Left(InfoBaseConnectionString(), 5) <> "File=" Тогда
		#IF SERVER THEN
			vNumberOfAttempts = 20;
		#ENDIF
	КонецЕсли;
	
	// Цикл 20 attempts in server mode (5 minutes of tries) before raising failure if any
	vAttemptTime = CurrentDate();
	Для i = 1 По vNumberOfAttempts Цикл
		Попытка
			// Удалить temp files left from a previous run
			RemoveTempExchangeFiles(vTempDirPath + vMessageFileName, pUnzip);
			
			// Copy file from the FTP or file source directory
			Если НЕ IsBlankString(pSourceAddress) Тогда
				// Receive file from FTP or copy it from directory
				Если pUseFTP Тогда
					vProxy = cmGetInternetProxy(pInternetConnectionSettings, False, pFTPAddress);
					vFTPServer = Неопределено;
					Если vProxy <> Неопределено Тогда
					    vFTPServer = Новый FTPConnection(pFTPAddress, pFTPPort, pFTPUser, pFTPPwd, vProxy, pUsePassiveMode, pFTPConnectionTimeout);
					Иначе
					    vFTPServer = Новый FTPConnection(pFTPAddress, pFTPPort, pFTPUser, pFTPPwd, , pUsePassiveMode, pFTPConnectionTimeout);
					КонецЕсли;
					// Get file from FTP server
					vExchangeFiles = vFTPServer.FindFiles(pSourceAddress + vExchangeFileName);
					Для Каждого vExchangeFile Из vExchangeFiles Цикл
						vFTPServer.Get(vExchangeFile.FullName, vTempDirPath + vExchangeFileName);
					КонецЦикла;
				Иначе
					// Copy file
					FileCopy(pSourceAddress + vExchangeFileName, vTempDirPath + vExchangeFileName);
				КонецЕсли;
			КонецЕсли;
			
			// Unzip file with changes if necessary
			Если pUnzip Тогда
				vArchive = Новый ZipFileReader(vTempDirPath + vExchangeFileName, pZipPwd);
				vArchive.ExtractAll(vTempDirPath, ZIPRestoreFilePathsMode.DontRestore);
				vArchive.Close();
			КонецЕсли;
			
			// Load changes
			vXMLReader = Новый XMLReader();
			vXMLReader.OpenFile(vTempDirPath + vMessageFileName + ".xml");
			vMessageReader = ExchangePlans.CreateMessageReader();
			vMessageReader.BeginRead(vXMLReader, AllowedMessageNo.Any);
			Если vMessageReader.Sender <> pNode Тогда
				ВызватьИсключение NStr("en='Wrong node in the data exchange file!';ru='Неверный узел в файле обмена данными!';de='Falscher Knoten in der Datenaustauschdatei!'");
			ИначеЕсли vMessageReader.MessageNo > pNode.ReceivedNo Тогда
				ExchangePlans.ReadChanges(vMessageReader, pObjectsInTranCount); 
				vMessageReader.EndRead();
			Иначе
				WriteLogEvent(NStr("en='Процедура.ReadExchangePlanChanges';ru='Процедура.ЧтениеИзмененийПоПлануОбмена';de='Процедура.ReadExchangePlanChanges'"), EventLogLevel.Information, Неопределено, Неопределено, 
							  NStr("ru='Номер прочитанного сообщения " + Format(vMessageReader.MessageNo, "ND=9; NFD=0; NZ=; NG=") + " меньше или равен номеру " + Format(pNode.ReceivedNo, "ND=9; NFD=0; NZ=; NG=") + " последнего полученного сообщения!'; 
							       |de='Number " + Format(vMessageReader.MessageNo, "ND=9; NFD=0; NZ=; NG=") + " of Задача being read is less or equal the number " + Format(pNode.ReceivedNo, "ND=9; NFD=0; NZ=; NG=") + " of Задача being already received!';
								   |en='Number " + Format(vMessageReader.MessageNo, "ND=9; NFD=0; NZ=; NG=") + " of Задача being read is less or equal the number " + Format(pNode.ReceivedNo, "ND=9; NFD=0; NZ=; NG=") + " of Задача being already received!'"));
			КонецЕсли;
			vXMLReader.Close();
			
			// Удалить temp files
			RemoveTempExchangeFiles(vTempDirPath + vMessageFileName, pUnzip);
			
			// Break attempts cycle if everything is OK
			Break;
		Except
			// Save current error description
			vErrorDescription = ErrorDescription();
			// Rollback transaction if any and close file with XML changes
			Попытка
				Если TransactionActive() Тогда
					RollbackTransaction();
				КонецЕсли;
				vXMLReader.Close();
			Except
			EndTry;
			Если i = vNumberOfAttempts Тогда
				ВызватьИсключение vErrorDescription;
			Иначе
				// Wait 15 seconds and try again
				vGap = CurrentDate() - vAttemptTime;
				Пока vGap < 15 Цикл
					vGap = CurrentDate() - vAttemptTime;
				КонецЦикла;
				vAttemptTime = CurrentDate();
			КонецЕсли;
		EndTry;
	КонецЦикла;
КонецПроцедуры //cmReadExchangePlanChanges

//-----------------------------------------------------------------------------
// Description: Performs on-line data synchronization with nodes specified
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSynchronizeNodes(pExchangePlan, pSourceNode, pTargetNode) Экспорт
	vTempFilesDir = cmTempFilesDir();
	
	// Call synchronize method of target node
	vExchangePlanName = Mid(String(pExchangePlan), 21);
	vTargetWSDLHostAddress = TrimR(pTargetNode.DataExchangeWSDLHost);
	
	// Create WEB-services proxy
	vWSDef = Новый WSDefinitions(vTargetWSDLHostAddress);
	vWSProxy = Новый WSProxy(vWSDef, "http://www.1chtel.ru/ws/interface/dataexchange/", "DataExchangeInterfaces", "DataExchangeInterfacesSoap");
	
	// Прочитать source node changes
	vMessageFileName = vTempFilesDir + "Message_" + Upper(СокрЛП(pSourceNode.Code)) + "_" + Upper(СокрЛП(pTargetNode.Code)) + ".xml";
	vMessageFile = Новый File(vMessageFileName);
	Если vMessageFile.Exist() Тогда
		DeleteFiles(vMessageFileName);
	КонецЕсли;
	
	// Записать XML file with changes
	vXMLWriter = Новый XMLWriter();
	vXMLWriter.OpenFile(vMessageFileName);
	vXMLWriter.WriteXMLDeclaration();
	vMessageWriter = ExchangePlans.CreateMessageWriter();
	vMessageWriter.BeginWrite(vXMLWriter, pTargetNode);
	ExchangePlans.WriteChanges(vMessageWriter, 0);
	vMessageWriter.EndWrite();
	vXMLWriter.Close();
	
	// Zip and encript file with changes if necessary
	vMessageZIPFileName = Left(vMessageFileName, StrLen(vMessageFileName) - 4) + ".zip";
	vMessageZIPFile = Новый File(vMessageZIPFileName);
	Если vMessageZIPFile.Exist() Тогда
		DeleteFiles(vMessageZIPFileName);
	КонецЕсли;
	vZipFileWriter = Новый ZipFileWriter(vMessageZIPFileName, TrimR(pSourceNode.DataExchangePassword), , ZIPCompressionMethod.Deflate, ZIPCompressionLevel.Maximum, ZIPEncryptionMethod.AES256);
	vZipFileWriter.Add(vMessageFileName, ZIPStorePathMode.DontStorePath);
	vZipFileWriter.Записать();
	
	// Check that zip was successfull
	vZIPFileReader = Новый ZipFileReader(vMessageZIPFileName, TrimR(pSourceNode.DataExchangePassword));
	Если vZIPFileReader.Items.Count() > 0 Тогда
		vZIPFileReader.Close();
		// Прочитать binary data from zip file
		vBinaryData = Новый BinaryData(vMessageZIPFileName);
		// Удалить zip file
		DeleteFiles(vMessageZIPFileName);
	Иначе
		// Прочитать binary data from xml file
		vBinaryData = Новый BinaryData(vMessageFileName);
	КонецЕсли;
	// Прочитать base 64 string		
	vSourceBase64String = Base64String(vBinaryData);
	
	// Удалить files
	DeleteFiles(vMessageFileName);
	
	// Call web-service to transfer changes to the target node and to receive changes from it
	vTargetBase64String = vWSProxy.Synchronize(vExchangePlanName, TrimR(pSourceNode.Code), TrimR(pTargetNode.Code), vSourceBase64String);
	Если НЕ IsBlankString(vTargetBase64String) Тогда
		vMessageFileName = vTempFilesDir + "Message_" + Upper(СокрЛП(pTargetNode.Code)) + "_" + Upper(СокрЛП(pSourceNode.Code)) + ".xml";
		vMessageFile = Новый File(vMessageFileName);
		Если vMessageFile.Exist() Тогда
			DeleteFiles(vMessageFileName);
		КонецЕсли;
		vBinaryData = Base64Value(vTargetBase64String);
		vBinaryData.Записать(vMessageFileName);
		// Check if this is ZIP archive
		vTextReader = Новый TextReader(vMessageFileName, "UTF-8");
		vStr = vTextReader.Прочитать(5);
		vTextReader.Close();
		Если vStr <> Неопределено И vStr <> "<?xml" Тогда
			vMessageZIPFileName = Left(vMessageFileName, StrLen(vMessageFileName) - 4) + ".zip";
			vMessageZIPFile = Новый File(vMessageZIPFileName);
			Если vMessageZIPFile.Exist() Тогда
				DeleteFiles(vMessageZIPFileName);
			КонецЕсли;
			MoveFile(vMessageFileName, vMessageZIPFileName);
			Если vMessageZIPFile.Exist() Тогда
				vZIPFileReader = Новый ZipFileReader(vMessageZIPFileName, TrimR(pTargetNode.DataExchangePassword));
				vZIPFileReader.ExtractAll(vTempFilesDir, ZIPRestoreFilePathsMode.DontRestore);
				vZIPFileReader.Close();
				DeleteFiles(vMessageZIPFileName);
			Иначе
				ВызватьИсключение "Неудалось переименовать файл обмена данными в zip архив!";
			КонецЕсли;
		КонецЕсли;
		// Load source node changes
		Если vMessageFile.Exist() Тогда
			vXMLReader = Новый XMLReader();
			vXMLReader.OpenFile(vMessageFileName);
			vMessageReader = ExchangePlans.CreateMessageReader();
			vMessageReader.BeginRead(vXMLReader, AllowedMessageNo.Any);
			Если vMessageReader.Sender <> pTargetNode Тогда
				ВызватьИсключение NStr("en='Wrong node in the data exchange file!';ru='Неверный узел в файле обмена данными!';de='Falscher Knoten in der Datenaustauschdatei!'");
			ИначеЕсли vMessageReader.MessageNo > pSourceNode.ReceivedNo Тогда
				ExchangePlans.ReadChanges(vMessageReader, 0); 
				vMessageReader.EndRead();
			КонецЕсли;
			vXMLReader.Close();
			DeleteFiles(vMessageFileName);
		Иначе
			ВызватьИсключение NStr("en='Failed to receive synchronization confirmation reply!';ru='Неудалось получить подтверждение обработки команды синхронизации!';de='Die Bestätigung für die Bearbeitung des Synchronisationsbefehls konnte nicht eingehalten werden!'");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmSynchronizeNodes

//-----------------------------------------------------------------------------
// Description: Performs on-line data synchronization with all active nodes
// Возврат value: None
//-----------------------------------------------------------------------------
Функция cmSynchronize(pHotel, pSyncTime, rMessage) Экспорт
	vOK = True;
	rMessage = "";
	vTempFilesDir = cmTempFilesDir();
	// Check if previous run is completed
	vLockFileName = vTempFilesDir + "online_sync.lock";
	vLockFile = Новый File(vLockFileName);
	Если vLockFile.Exist() Тогда
		vLockFileAge = CurrentDate() - vLockFile.GetModificationTime();
		Если vLockFileAge < 0 Тогда
			vLockFileAge = -vLockFileAge;
		КонецЕсли;
		Если vLockFileAge > 7200 Тогда
			WriteLogEvent(NStr("en='On-lineSynchronization.Warning'; de='On-lineSynchronization.Warnung'; ru='On-lineСинхронизация.Предупреждение'"), EventLogLevel.Warning, Metadata.Constants.ВремяПоследнейСинхронизации, pSyncTime, NStr("en='Locking file is found! Previous syncing was started at ';ru='Найден файл блокировки! Предыдущий запуск процедуры синхронизации выполнен в ';de='Blockierungsdatei gefunden! Previous syncing was started at '") + vLockFile.GetModificationTime() + ", " + vLockFile.FullName + ", " + NStr("en='File will be deleted!'; ru='Файл будет удален!'; de='Die Datei wird gelöscht!'"));
			// Если file is older the 2 hours then assume that we have to ignore it
			Попытка
				DeleteFiles(vLockFileName);
			Except
				WriteLogEvent(NStr("en='On-lineSynchronization.Error'; de='On-lineSynchronization.Error'; ru='On-lineСинхронизация.Ошибка'"), EventLogLevel.Error, Metadata.Constants.ВремяПоследнейСинхронизации, pSyncTime, ErrorDescription());
			EndTry;
		Иначе
			rMessage = NStr("en='Locking file is found! Previous syncing was started at ';ru='Найден файл блокировки! Предыдущий запуск процедуры синхронизации выполнен в ';de='Blockierungsdatei gefunden! Previous syncing was started at '") + vLockFile.GetModificationTime() + ", " + vLockFile.FullName;
			Возврат False;
		КонецЕсли;
	КонецЕсли;
	Попытка
		// Place lock file to mark that synchronization process is running
		vLockFileData = Новый TextWriter(vLockFileName);
		vLockFileData.WriteLine("On-line synchronization in Индикатор...");
		vLockFileData.Close();
		// Цикл for each exchange plan
			
	Except
		rMessage = NStr("en='Error processing on-line synchronization!';ru='Ошибка при выполнении on-line синхронизации!';de='Fehler bei der Durchführung der Online-Synchronisation!'") + Chars.LF + ErrorDescription();
		WriteLogEvent(NStr("en='On-lineSynchronization.Error'; de='On-lineSynchronization.Error'; ru='On-lineСинхронизация.Ошибка'"), EventLogLevel.Error, Metadata.Constants.ВремяПоследнейСинхронизации, pSyncTime, rMessage);
		Message(rMessage, MessageStatus.VeryImportant);
		vOK = False;
	EndTry;
	Если vLockFile.Exist() Тогда
		Попытка
			DeleteFiles(vLockFileName);
		Except
		EndTry;
	КонецЕсли;
	Возврат vOK;
EndFunction //cmSynchronize

//-----------------------------------------------------------------------------
// Description: Call of this procedure initiates on-line data synchronization
//              for all exchange plans and active nodes
// Parameters: None
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSubmitSynchronization(pHotel = Неопределено) Экспорт
	vTempFilesDir = cmTempFilesDir();
	vStartTime = CurrentDate();
	Если НЕ Constants.OnlineSynchronizationIsTurnedOn.Get() Тогда
		vLastSyncTime = Constants.LastOnlineSynchronizationTime.Get();
		Если ЗначениеЗаполнено(vLastSyncTime) Тогда
			Constants.LastOnlineSynchronizationHotel.Set(Справочники.Гостиницы.EmptyRef());
			Constants.LastOnlineSynchronizationTime.Set('00010101');
		КонецЕсли;
		Возврат;
	КонецЕсли;
	Пока True Цикл
		Попытка
			Constants.LastOnlineSynchronizationHotel.Set(pHotel);
			Break;
		Except
			vErrorDescrition = ErrorDescription();
			Если Find(Upper(vErrorDescrition), "БЛОКИР") > 0 Or Find(Upper(vErrorDescrition), "LOCK") > 0 Тогда
				Если (CurrentDate() - vStartTime) > 60 Тогда
					vMessage = NStr("en='Failed to submit on-line synchronization! It took more then 1 minute to wait for previous synchronization to complete.';ru='Не удалось выполнить on-line синхронизацию данных! Ожидание завершения предыдущей синхронизации длилось более 1 минуты.';de='Die Online-Datensynchronisation ist fehlgeschlagen! Das Warten auf die Beendigung der vorherigen Synchronisation dauerte länger als 1 Minute.'");
					WriteLogEvent(NStr("en='OnlineSynchronization.Warning'; de='OnlineSynchronization.Warning'; ru='OnlineСинхронизация.Предупреждение'"), EventLogLevel.Warning, Metadata.Constants.ВремяПоследнейСинхронизации, Constants.LastOnlineSynchronizationTime.Get(), vMessage);
					Message(vMessage, MessageStatus.Attention);
					// Удалить lock file in case if it is hang
					vLockFileName = vTempFilesDir + "online_sync.lock";
					vLockFile = Новый File(vLockFileName);
					Если vLockFile.Exist() Тогда
						Попытка 
							DeleteFiles(vLockFileName);
							Continue;
						Except
						EndTry;
					КонецЕсли;
					// Break cycling
					Break;
				Иначе
					vStartWaitTime = CurrentDate();
					vCurrentTime = CurrentDate();
					Пока (vCurrentTime - vStartWaitTime) < 10 Цикл
						vCurrentTime = CurrentDate();
					КонецЦикла;
				КонецЕсли;
			Иначе
				Break;
			КонецЕсли;
		EndTry;
	КонецЦикла;
КонецПроцедуры //cmSubmitSynchronization

//-----------------------------------------------------------------------------
// Description: Returns temp file name 
// Parameters: Temp file extension
// Возврат value: Name of temp file that could be used
//-----------------------------------------------------------------------------
Функция cmGetTempFileName(pExt) Экспорт
	vTmpFileName = GetTempFileName(pExt);
	Если Find(vTmpFileName, "\") > 0 Тогда
		vTmpFileName = StrReplace(vTmpFileName, "/", "\");
	КонецЕсли;
	Возврат vTmpFileName;
EndFunction //cmGetTempFileName 

//-----------------------------------------------------------------------------
// Description: Returns directory where temp files are created
// Parameters: None
// Возврат value: Path to the temp files directory
//-----------------------------------------------------------------------------
Функция cmTempFilesDir() Экспорт
	vTmpDir = "";
	vTmpFileName = cmGetTempFileName("tmp");
	vTmpFile = Новый File(vTmpFileName);
	Если vTmpFile.Exist() Тогда
		DeleteFiles(vTmpFileName);
	КонецЕсли;
	vTmpFileNameLen = StrLen(vTmpFileName);
	i = vTmpFileNameLen;
	Пока i > 0 Цикл
		vChar = Mid(vTmpFileName, i, 1);
		Если vChar = "/" Or vChar = "\" Тогда
			Break;
		Иначе
			i = i - 1;
		КонецЕсли;
	КонецЦикла;
	Если i > 0 Тогда
		vTmpDir = Left(vTmpFileName, i);
	Иначе
		vTmpDir = TempFilesDir();
	КонецЕсли;
	Возврат vTmpDir;
EndFunction //cmTempFilesDir 

//-----------------------------------------------------------------------------
// Description: Returns value list with all workstations
// Parameters: None
// Возврат value: Value list
//-----------------------------------------------------------------------------
Функция cmGetWorkstationsList(pFilterByAllowed = False) Экспорт
	vList = Новый СписокЗначений();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	РабочиеМеста.Ref
	|FROM
	|	Catalog.РабочиеМеста AS РабочиеМеста
	|WHERE
	|	(NOT РабочиеМеста.DeletionMark)
	|	AND (NOT РабочиеМеста.IsFolder)
	|	AND (NOT &qFilterByAllowed OR &qFilterByAllowed AND NOT РабочиеМеста.НеПоказыватьВСпискеВыбораПриСтартеСистемы)
	|
	|ORDER BY
	|	РабочиеМеста.Description";
	vQry.SetParameter("qFilterByAllowed", pFilterByAllowed);
	
	vQryRes = vQry.Execute().Unload();
	Для Каждого vQryResRow Из vQryRes Цикл
		vList.Add(vQryResRow.Ссылка);
	КонецЦикла;
	Возврат vList;
EndFunction //cmGetWorkstationsList

//-----------------------------------------------------------------------------
// Description: Процедура is used to replace one client with another one in all
//              documents, catalog items, information registers and so on/
// Parameters: Client to use instead of client specified as second parameter
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmMergeClients(pMainClient, pMergedClient) Экспорт
	// Check parameters
	Если НЕ ЗначениеЗаполнено(pMainClient) or НЕ ЗначениеЗаполнено(pMergedClient) Тогда
		ВызватьИсключение NStr("en='Both clients should be filled!';ru='Обе карточки клиентов должны быть указаны!';de='Beide Kundenkarten müssen angegeben sein!'");
		//Возврат;
	КонецЕсли;
	Если НЕ ПравоДоступа("Edit", Metadata.InformationRegisters.ИсторияИзмКлиентов) Тогда
		ВызватьИсключение NStr("en='You do not have rights to merge clients! You have to have rights to edit client change history records.';ru='У вас нет прав на эту операцию! Необходимы права на редактирование истории изменения клиентов.';de='Sie haben keine Rechte für diesen Vorgang! Siebenötigen Rechte, um den Bearbeitungsverlauf der Kunden zu redigieren .'");
		//Возврат;
	КонецЕсли;
	// Find references to the second parameter client
	vRefsArray = Новый Array();
	vRefsArray.Add(pMergedClient);
	vRefs = FindByRef(vRefsArray);
	// Цикл in one transaction
	Попытка
		BeginTransaction(DataLockControlMode.Managed);
		// First run (do not repost accommodations and some other documents, just rewrite them)
		Для Каждого vRefsRow Из vRefs Цикл
			vObjRef = vRefsRow.Get(1);
			Если ТипЗнч(vObjRef) = Type("СправочникСсылка.КредитныеКарты") Тогда
				vObj = vObjRef.GetObject();
				vObj.CardOwner = pMainClient;
				vObj.Записать();
			ИначеЕсли ТипЗнч(vObjRef) = Type("СправочникСсылка.ДисконтныеКарты") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				vObj.Записать();
			ИначеЕсли ТипЗнч(vObjRef) = Type("СправочникСсылка.ГруппыГостей") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				vObj.Записать();
			ИначеЕсли ТипЗнч(vObjRef) = Type("СправочникСсылка.КартаИД") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				vObj.Записать();
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Размещение") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				Для Каждого vCRRow Из vObj.ChargingRules Цикл
					Если vCRRow.Owner = pMergedClient Тогда
						vCRRow.Owner = pMainClient;
					КонецЕсли;
				КонецЦикла;
				// Need to be reposted further
				vObj.Записать(РежимЗаписиДокумента.Записать);
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Бронирование") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				Для Каждого vCRRow Из vObj.ChargingRules Цикл
					Если vCRRow.Owner = pMergedClient Тогда
						vCRRow.Owner = pMainClient;
					КонецЕсли;
				КонецЦикла;
				// Need to be reposted further
				vObj.Записать(РежимЗаписиДокумента.Записать);
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.ДанныеКлиента") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				vObj.Записать(РежимЗаписиДокумента.Записать);
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.СчетПроживания") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				vObj.Записать(РежимЗаписиДокумента.Записать);
			
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.СчетНаОплату") Тогда
				vObj = vObjRef.GetObject();
				Для Каждого vSrvRow Из vObj.Услуги Цикл
					Если vSrvRow.Клиент = pMergedClient Тогда
						vSrvRow.Клиент = pMainClient;
					КонецЕсли;
				КонецЦикла;
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Posting);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Задача") Тогда
				vObj = vObjRef.GetObject();
				Если vObj.ByObject = pMergedClient Тогда
					vObj.ByObject = pMainClient;
					Если vObj.Проведен Тогда
						vObj.Записать(РежимЗаписиДокумента.Posting);
					Иначе
						vObj.Записать(РежимЗаписиДокумента.Записать);
					КонецЕсли;
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.ПланРабот") Тогда
				vObj = vObjRef.GetObject();
				Для Каждого vOprRow Из vObj.Работы Цикл
					Если vOprRow.Клиент = pMergedClient Тогда
						vOprRow.Клиент = pMainClient;
					КонецЕсли;
				КонецЦикла;
				vObj.Записать(РежимЗаписиДокумента.Записать);
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Платеж") Тогда
				vObj = vObjRef.GetObject();
				vObj.Payer = pMainClient;
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Posting);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.ПреАвторизация") Тогда
				vObj = vObjRef.GetObject();
				vObj.Payer = pMainClient;
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Проведение);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.УслугаВНомер") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				// Need to be reposted further
				vObj.Записать(РежимЗаписиДокумента.Записать);
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.БроньУслуг") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				// Need to be reposted further
				vObj.Записать(РежимЗаписиДокумента.Записать);
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Возврат") Тогда
				vObj = vObjRef.GetObject();
				vObj.Payer = pMainClient;
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Проведение);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.РегистрацияУслуги") Тогда
				vObj = vObjRef.GetObject();
				vObj.Клиент = pMainClient;
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Проведение);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Акт") Тогда
				vObj = vObjRef.GetObject();
				Для Каждого vSrvRow Из vObj.Услуги Цикл
					Если vSrvRow.Клиент = pMergedClient Тогда
						vSrvRow.Клиент = pMainClient;
					КонецЕсли;
				КонецЦикла;
				// Need to be reposted further
				vObj.Записать(РежимЗаписиДокумента.Записать);
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Начисление") Тогда
				vObj = vObjRef.GetObject();
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Проведение);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Сторно") Тогда
				vObj = vObjRef.GetObject();
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Проведение);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.ПеремещениеДепозита") Тогда
				vObj = vObjRef.GetObject();
				Если vObj.Проведен Тогда
					vObj.Записать(РежимЗаписиДокумента.Проведение);
				Иначе
					vObj.Записать(РежимЗаписиДокумента.Записать);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("InformationRegisterRecordKey.ИсторияИзмКлиентов") Тогда
				vMgr = InformationRegisters.ИсторияИзмКлиентов.CreateRecordManager();
				FillPropertyValues(vMgr, vObjRef);
				vMgr.Прочитать();
				
			ИначеЕсли ТипЗнч(vObjRef) = Type("InformationRegisterRecordKey.ИсторияИзмененийРазмещения") Тогда
				vMgr = InformationRegisters.ИсторияИзмененийРазмещения.CreateRecordManager();
				FillPropertyValues(vMgr, vObjRef);
				vMgr.Прочитать();
				
			
				
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.ЗакрытиеПериода") Тогда
				// Repost document at second step
			Иначе
				ВызватьИсключение "Не определен алгоритм обработки для типа " + СокрЛП(vObjRef) + "!";
			КонецЕсли;
		КонецЦикла;
		// Second run when we have to repost some documents
		Для Каждого vRefsRow Из vRefs Цикл
			vObjRef = vRefsRow.Get(1);
			
			Если ТипЗнч(vObjRef) = Type("ДокументСсылка.Размещение") Тогда
				Если vObjRef.Проведен Тогда
					vObj = vObjRef.GetObject();
					vObj.Записать(РежимЗаписиДокумента.Posting);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Бронирование") Тогда
				Если vObjRef.Проведен Тогда
					vObj = vObjRef.GetObject();
					vObj.Записать(РежимЗаписиДокумента.Posting);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.УслугаВНомер") Тогда
				Если vObjRef.Проведен Тогда
					vObj = vObjRef.GetObject();
					vObj.Записать(РежимЗаписиДокумента.Posting);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.БроньУслуг") Тогда
				Если vObjRef.Проведен Тогда
					vObj = vObjRef.GetObject();
					vObj.Записать(РежимЗаписиДокумента.Posting);
				КонецЕсли;
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.Акт") Тогда
				Если vObjRef.Проведен Тогда
					vObj = vObjRef.GetObject();
					vObj.Записать(РежимЗаписиДокумента.Posting);
				КонецЕсли;
			
			ИначеЕсли ТипЗнч(vObjRef) = Type("ДокументСсылка.ЗакрытиеПериода") Тогда
				Если vObjRef.Проведен Тогда
					vObj = vObjRef.GetObject();
					vObj.Записать(РежимЗаписиДокумента.Posting);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		// Check references again
		vRefs = FindByRef(vRefsArray);
		Если vRefs.Count() = 0 Тогда
			// Удалить client if nothing is found
			pMergedClient.GetObject().Удалить();
			pMergedClient = Неопределено;
		Иначе
			ВызватьИсключение "Не удалось обработать все ссылки на клиента " + СокрЛП(pMergedClient.FullName) + " (" + СокрЛП(pMergedClient.Code) + ")!";
		КонецЕсли;
		// Commit transaction		
		CommitTransaction();
	Исключение
		vErrorText = ErrorDescription();
		Если TransactionActive() Тогда
			RollbackTransaction();
		КонецЕсли;
		ВызватьИсключение vErrorText;
	КонецПопытки;
КонецПроцедуры //cmMergeClients 

//-----------------------------------------------------------------------------
// Description: Функция is used to replace and return web color with its RGB 
//              equivalent
// Parameters: Color object of type WebColor
// Возврат value: RGB Color
//-----------------------------------------------------------------------------
Функция cmGetRGB4WebColor(pWebColor) Экспорт
	Если pWebColor = WebColors.AliceBlue Тогда
		Возврат Новый Color(240, 248, 255);
	ИначеЕсли pWebColor = WebColors.AntiqueWhite Тогда
		Возврат Новый Color(250, 235, 215);
	ИначеЕсли pWebColor = WebColors.Aqua Тогда
		Возврат Новый Color(0, 255, 255);
	ИначеЕсли pWebColor = WebColors.Aquamarine Тогда
		Возврат Новый Color(127, 255, 212);
	ИначеЕсли pWebColor = WebColors.Azure Тогда
		Возврат Новый Color(240, 255, 255);
	ИначеЕсли pWebColor = WebColors.Beige Тогда
		Возврат Новый Color(245, 245, 220);
	ИначеЕсли pWebColor = WebColors.Bisque Тогда
		Возврат Новый Color(255, 228, 196);
	ИначеЕсли pWebColor = WebColors.Black Тогда
		Возврат Новый Color(0, 0, 0);
	ИначеЕсли pWebColor = WebColors.BlanchedAlmond Тогда
		Возврат Новый Color(255, 235, 205);
	ИначеЕсли pWebColor = WebColors.Blue Тогда
		Возврат Новый Color(0, 0, 255);
	ИначеЕсли pWebColor = WebColors.BlueViolet Тогда
		Возврат Новый Color(138, 43, 226);
	ИначеЕсли pWebColor = WebColors.Brown Тогда
		Возврат Новый Color(165, 42, 42);
	ИначеЕсли pWebColor = WebColors.BurlyWood Тогда
		Возврат Новый Color(222, 184, 135);
	ИначеЕсли pWebColor = WebColors.CadetBlue Тогда
		Возврат Новый Color(95, 158, 160);
	ИначеЕсли pWebColor = WebColors.Chartreuse Тогда
		Возврат Новый Color(127, 255, 0);
	ИначеЕсли pWebColor = WebColors.Chocolate Тогда
		Возврат Новый Color(210, 105, 30);
	ИначеЕсли pWebColor = WebColors.Coral Тогда
		Возврат Новый Color(255, 127, 80);
	ИначеЕсли pWebColor = WebColors.CornFlowerBlue Тогда
		Возврат Новый Color(100, 149, 237);
	ИначеЕсли pWebColor = WebColors.CornSilk Тогда
		Возврат Новый Color(255, 248, 220);
	ИначеЕсли pWebColor = WebColors.Cream Тогда
		Возврат Новый Color(255, 251, 240);
	ИначеЕсли pWebColor = WebColors.Crimson Тогда
		Возврат Новый Color(220, 20, 60);
	ИначеЕсли pWebColor = WebColors.Cyan Тогда
		Возврат Новый Color(0, 255, 255);
	ИначеЕсли pWebColor = WebColors.DarkBlue Тогда
		Возврат Новый Color(0, 0, 139);
	ИначеЕсли pWebColor = WebColors.DarkCyan Тогда
		Возврат Новый Color(0, 139, 139);
	ИначеЕсли pWebColor = WebColors.DarkGoldenRod Тогда
		Возврат Новый Color(184, 134, 11);
	ИначеЕсли pWebColor = WebColors.DarkGray Тогда
		Возврат Новый Color(169, 169, 169);
	ИначеЕсли pWebColor = WebColors.DarkGreen Тогда
		Возврат Новый Color(0, 100, 0);
	ИначеЕсли pWebColor = WebColors.DarkKhaki Тогда
		Возврат Новый Color(189, 183, 107);
	ИначеЕсли pWebColor = WebColors.DarkMagenta Тогда
		Возврат Новый Color(139, 0, 139);
	ИначеЕсли pWebColor = WebColors.DarkOliveGreen Тогда
		Возврат Новый Color(85, 107, 47);
	ИначеЕсли pWebColor = WebColors.DarkOrange Тогда
		Возврат Новый Color(255, 140, 0);
	ИначеЕсли pWebColor = WebColors.DarkOrchid Тогда
		Возврат Новый Color(153, 50, 204);
	ИначеЕсли pWebColor = WebColors.DarkRed Тогда
		Возврат Новый Color(139, 0, 0);
	ИначеЕсли pWebColor = WebColors.DarkSalmon Тогда
		Возврат Новый Color(233, 150, 122);
	ИначеЕсли pWebColor = WebColors.DarkSeaGreen Тогда
		Возврат Новый Color(143, 188, 139);
	ИначеЕсли pWebColor = WebColors.DarkSlateBlue Тогда
		Возврат Новый Color(72, 61, 139);
	ИначеЕсли pWebColor = WebColors.DarkSlateGray Тогда
		Возврат Новый Color(47, 79, 79);
	ИначеЕсли pWebColor = WebColors.DarkTurquoise Тогда
		Возврат Новый Color(0, 206, 209);
	ИначеЕсли pWebColor = WebColors.DarkViolet Тогда
		Возврат Новый Color(148, 0, 211);
	ИначеЕсли pWebColor = WebColors.DeepPink Тогда
		Возврат Новый Color(255, 20, 147);
	ИначеЕсли pWebColor = WebColors.DeepSkyBlue Тогда
		Возврат Новый Color(0, 191, 255);
	ИначеЕсли pWebColor = WebColors.DimGray Тогда
		Возврат Новый Color(105, 105, 105);
	ИначеЕсли pWebColor = WebColors.DodgerBlue Тогда
		Возврат Новый Color(30, 144, 255);
	ИначеЕсли pWebColor = WebColors.FireBrick Тогда
		Возврат Новый Color(178, 34, 34);
	ИначеЕсли pWebColor = WebColors.FloralWhite Тогда
		Возврат Новый Color(255, 250, 240);
	ИначеЕсли pWebColor = WebColors.ForestGreen Тогда
		Возврат Новый Color(34, 139, 34);
	ИначеЕсли pWebColor = WebColors.Fuchsia Тогда
		Возврат Новый Color(255, 0, 255);
	ИначеЕсли pWebColor = WebColors.Gainsboro Тогда
		Возврат Новый Color(220, 220, 220);
	ИначеЕсли pWebColor = WebColors.GhostWhite Тогда
		Возврат Новый Color(248, 248, 255);
	ИначеЕсли pWebColor = WebColors.Gold Тогда
		Возврат Новый Color(255, 215, 0);
	ИначеЕсли pWebColor = WebColors.Goldenrod Тогда
		Возврат Новый Color(218, 165, 32);
	ИначеЕсли pWebColor = WebColors.Gray Тогда
		Возврат Новый Color(128, 128, 128);
	ИначеЕсли pWebColor = WebColors.Green Тогда
		Возврат Новый Color(0, 128, 0);
	ИначеЕсли pWebColor = WebColors.GreenYellow Тогда
		Возврат Новый Color(173, 255, 47);
	ИначеЕсли pWebColor = WebColors.HoneyDew Тогда
		Возврат Новый Color(240, 255, 240);
	ИначеЕсли pWebColor = WebColors.HotPink Тогда
		Возврат Новый Color(255, 105, 180);
	ИначеЕсли pWebColor = WebColors.IndianRed Тогда
		Возврат Новый Color(205, 92, 92);
	ИначеЕсли pWebColor = WebColors.Indigo Тогда
		Возврат Новый Color(75, 0, 130);
	ИначеЕсли pWebColor = WebColors.Ivory Тогда
		Возврат Новый Color(255, 255, 240);
	ИначеЕсли pWebColor = WebColors.Khaki Тогда
		Возврат Новый Color(240, 230, 140);
	ИначеЕсли pWebColor = WebColors.Lavender Тогда
		Возврат Новый Color(230, 230, 250);
	ИначеЕсли pWebColor = WebColors.LavenderBlush Тогда
		Возврат Новый Color(255, 240, 245);
	ИначеЕсли pWebColor = WebColors.LawnGreen Тогда
		Возврат Новый Color(124, 252, 0);
	ИначеЕсли pWebColor = WebColors.LemonChiffon Тогда
		Возврат Новый Color(255, 250, 205);
	ИначеЕсли pWebColor = WebColors.LightBlue Тогда
		Возврат Новый Color(166, 202, 240);
	ИначеЕсли pWebColor = WebColors.LightCoral Тогда
		Возврат Новый Color(240, 128, 128);
	ИначеЕсли pWebColor = WebColors.LightCyan Тогда
		Возврат Новый Color(224, 255, 255);
	ИначеЕсли pWebColor = WebColors.LightGoldenRod Тогда
		Возврат Новый Color(255, 236, 139);
	ИначеЕсли pWebColor = WebColors.LightGoldenRodYellow Тогда
		Возврат Новый Color(250, 250, 210);
	ИначеЕсли pWebColor = WebColors.LightGray Тогда
		Возврат Новый Color(192, 192, 192);
	ИначеЕсли pWebColor = WebColors.LightGreen Тогда
		Возврат Новый Color(144, 238, 144);
	ИначеЕсли pWebColor = WebColors.LightPink Тогда
		Возврат Новый Color(255, 182, 193);
	ИначеЕсли pWebColor = WebColors.LightSalmon Тогда
		Возврат Новый Color(255, 160, 122);
	ИначеЕсли pWebColor = WebColors.LightSeaGreen Тогда
		Возврат Новый Color(32, 178, 170);
	ИначеЕсли pWebColor = WebColors.LightSkyBlue Тогда
		Возврат Новый Color(135, 206, 250);
	ИначеЕсли pWebColor = WebColors.LightSlateBlue Тогда
		Возврат Новый Color(132, 112, 255);
	ИначеЕсли pWebColor = WebColors.LightSlateGray Тогда
		Возврат Новый Color(119, 136, 153);
	ИначеЕсли pWebColor = WebColors.LightSteelBlue Тогда
		Возврат Новый Color(176, 196, 222);
	ИначеЕсли pWebColor = WebColors.LightYellow Тогда
		Возврат Новый Color(255, 255, 224);
	ИначеЕсли pWebColor = WebColors.Lime Тогда
		Возврат Новый Color(0, 255, 0);
	ИначеЕсли pWebColor = WebColors.LimeGreen Тогда
		Возврат Новый Color(50, 205, 50);
	ИначеЕсли pWebColor = WebColors.Linen Тогда
		Возврат Новый Color(250, 240, 230);
	ИначеЕсли pWebColor = WebColors.Magenta Тогда
		Возврат Новый Color(255, 0, 255);
	ИначеЕсли pWebColor = WebColors.Maroon Тогда
		Возврат Новый Color(128, 0, 0);
	ИначеЕсли pWebColor = WebColors.MediumAquaMarine Тогда
		Возврат Новый Color(102, 205, 170);
	ИначеЕсли pWebColor = WebColors.MediumBlue Тогда
		Возврат Новый Color(0, 0, 205);
	ИначеЕсли pWebColor = WebColors.MediumGray Тогда
		Возврат Новый Color(160, 160, 164);
	ИначеЕсли pWebColor = WebColors.MediumGreen Тогда
		Возврат Новый Color(192, 220, 192);
	ИначеЕсли pWebColor = WebColors.MediumOrchid Тогда
		Возврат Новый Color(186, 85, 211);
	ИначеЕсли pWebColor = WebColors.MediumPurple Тогда
		Возврат Новый Color(147, 112, 219);
	ИначеЕсли pWebColor = WebColors.MediumSeaGreen Тогда
		Возврат Новый Color(60, 179, 113);
	ИначеЕсли pWebColor = WebColors.MediumSlateBlue Тогда
		Возврат Новый Color(123, 104, 238);
	ИначеЕсли pWebColor = WebColors.MediumSpringGreen Тогда
		Возврат Новый Color(0, 250, 154);
	ИначеЕсли pWebColor = WebColors.MediumTurquoise Тогда
		Возврат Новый Color(72, 209, 204);
	ИначеЕсли pWebColor = WebColors.MediumVioletRed Тогда
		Возврат Новый Color(199, 21, 133);
	ИначеЕсли pWebColor = WebColors.MidnightBlue Тогда
		Возврат Новый Color(25, 25, 112);
	ИначеЕсли pWebColor = WebColors.MintCream Тогда
		Возврат Новый Color(245, 255, 250);
	ИначеЕсли pWebColor = WebColors.MistyRose Тогда
		Возврат Новый Color(255, 228, 225);
	ИначеЕсли pWebColor = WebColors.Moccasin Тогда
		Возврат Новый Color(255, 228, 181);
	ИначеЕсли pWebColor = WebColors.NavajoWhite Тогда
		Возврат Новый Color(255, 222, 173);
	ИначеЕсли pWebColor = WebColors.Navy Тогда
		Возврат Новый Color(0, 0, 128);
	ИначеЕсли pWebColor = WebColors.OldLace Тогда
		Возврат Новый Color(253, 245, 230);
	ИначеЕсли pWebColor = WebColors.Olive Тогда
		Возврат Новый Color(128, 128, 0);
	ИначеЕсли pWebColor = WebColors.Olivedrab Тогда
		Возврат Новый Color(107, 142, 35);
	ИначеЕсли pWebColor = WebColors.Orange Тогда
		Возврат Новый Color(255, 165, 0);
	ИначеЕсли pWebColor = WebColors.OrangeRed Тогда
		Возврат Новый Color(255, 69, 0);
	ИначеЕсли pWebColor = WebColors.Orchid Тогда
		Возврат Новый Color(218, 112, 214);
	ИначеЕсли pWebColor = WebColors.PaleGoldenrod Тогда
		Возврат Новый Color(238, 232, 170);
	ИначеЕсли pWebColor = WebColors.PaleGreen Тогда
		Возврат Новый Color(152, 251, 152);
	ИначеЕсли pWebColor = WebColors.PaleTurquoise Тогда
		Возврат Новый Color(175, 238, 238);
	ИначеЕсли pWebColor = WebColors.PaleVioletRed Тогда
		Возврат Новый Color(219, 112, 147);
	ИначеЕсли pWebColor = WebColors.PapayaWhip Тогда
		Возврат Новый Color(255, 239, 213);
	ИначеЕсли pWebColor = WebColors.PeachPuff Тогда
		Возврат Новый Color(255, 218, 185);
	ИначеЕсли pWebColor = WebColors.Peru Тогда
		Возврат Новый Color(205, 133, 63);
	ИначеЕсли pWebColor = WebColors.Pink Тогда
		Возврат Новый Color(255, 192, 203);
	ИначеЕсли pWebColor = WebColors.Plum Тогда
		Возврат Новый Color(221, 160, 221);
	ИначеЕсли pWebColor = WebColors.PowderBlue Тогда
		Возврат Новый Color(176, 224, 230);
	ИначеЕсли pWebColor = WebColors.Purple Тогда
		Возврат Новый Color(128, 0, 128);
	ИначеЕсли pWebColor = WebColors.Red Тогда
		Возврат Новый Color(255, 0, 0);
	ИначеЕсли pWebColor = WebColors.RosyBrown Тогда
		Возврат Новый Color(188, 143, 143);
	ИначеЕсли pWebColor = WebColors.RoyalBlue Тогда
		Возврат Новый Color(65, 105, 225);
	ИначеЕсли pWebColor = WebColors.SaddleBrown Тогда
		Возврат Новый Color(139, 69, 19);
	ИначеЕсли pWebColor = WebColors.Salmon Тогда
		Возврат Новый Color(250, 128, 114);
	ИначеЕсли pWebColor = WebColors.SandyBrown Тогда
		Возврат Новый Color(244, 164, 96);
	ИначеЕсли pWebColor = WebColors.Seagreen Тогда
		Возврат Новый Color(46, 139, 87);
	ИначеЕсли pWebColor = WebColors.SeaShell Тогда
		Возврат Новый Color(255, 245, 238);
	ИначеЕсли pWebColor = WebColors.Sienna Тогда
		Возврат Новый Color(160, 82, 45);
	ИначеЕсли pWebColor = WebColors.Silver Тогда
		Возврат Новый Color(192, 192, 192);
	ИначеЕсли pWebColor = WebColors.SkyBlue Тогда
		Возврат Новый Color(135, 206, 235);
	ИначеЕсли pWebColor = WebColors.SlateBlue Тогда
		Возврат Новый Color(106, 90, 205);
	ИначеЕсли pWebColor = WebColors.SlateGray Тогда
		Возврат Новый Color(112, 128, 144);
	ИначеЕсли pWebColor = WebColors.Snow Тогда
		Возврат Новый Color(255, 250, 250);
	ИначеЕсли pWebColor = WebColors.SpringGreen Тогда
		Возврат Новый Color(0, 255, 127);
	ИначеЕсли pWebColor = WebColors.SteelBlue Тогда
		Возврат Новый Color(70, 130, 180);
	ИначеЕсли pWebColor = WebColors.Tan Тогда
		Возврат Новый Color(210, 180, 140);
	ИначеЕсли pWebColor = WebColors.Teal Тогда
		Возврат Новый Color(0, 128, 128);
	ИначеЕсли pWebColor = WebColors.Thistle Тогда
		Возврат Новый Color(216, 191, 216);
	ИначеЕсли pWebColor = WebColors.Tomato Тогда
		Возврат Новый Color(255, 99, 71);
	ИначеЕсли pWebColor = WebColors.Turquoise Тогда
		Возврат Новый Color(64, 224, 208);
	ИначеЕсли pWebColor = WebColors.Violet Тогда
		Возврат Новый Color(238, 130, 238);
	ИначеЕсли pWebColor = WebColors.VioletRed Тогда
		Возврат Новый Color(208, 32, 144);
	ИначеЕсли pWebColor = WebColors.Wheat Тогда
		Возврат Новый Color(245, 222, 179);
	ИначеЕсли pWebColor = WebColors.White Тогда
		Возврат Новый Color(255, 255, 255);
	ИначеЕсли pWebColor = WebColors.WhiteSmoke Тогда
		Возврат Новый Color(245, 245, 245);
	ИначеЕсли pWebColor = WebColors.Yellow Тогда
		Возврат Новый Color(255, 255, 0);
	ИначеЕсли pWebColor = WebColors.YellowGreen Тогда
		Возврат Новый Color(154, 205, 50);
	КонецЕсли;
	Возврат pWebColor;
EndFunction //cmGetRGB4WebColor

//-----------------------------------------------------------------------------
// Description: Функция compares 2 objects and returns comparison result as 
//              human readable text
// Parameters: 2 objects to be compared
// Возврат value: String, comparison result
//-----------------------------------------------------------------------------
Функция cmGetObjectChanges(pObj) Экспорт
	vChanges = "";
	vAttributesToSkip = "ПорядокСортировки";
	// Get previous object state
	vPrevStateRec = pObj.pmGetPreviousObjectState('39991231235959');
	Если vPrevStateRec = Неопределено Тогда
		vChanges = NStr("en='<Новый>';ru='<Новый>';de='<Neu>'");
		Возврат vChanges;
	КонецЕсли;
	vPrevObj = Неопределено;
	Если ТипЗнч(pObj) = Type("DocumentObject.Размещение") Тогда
		vPrevObj = Documents.Размещение.CreateDocument();
	ИначеЕсли ТипЗнч(pObj) = Type("DocumentObject.Бронирование") Тогда
		vPrevObj = Documents.Бронирование.CreateDocument();
	ИначеЕсли ТипЗнч(pObj) = Type("DocumentObject.БроньУслуг") Тогда
		vPrevObj = Documents.БроньУслуг.CreateDocument();
	ИначеЕсли ТипЗнч(pObj) = Type("DocumentObject.ПриказТариф") Тогда
		vPrevObj = Documents.ПриказТариф.CreateDocument();
	ИначеЕсли ТипЗнч(pObj) = Type("DocumentObject.ИзмЦены") Тогда
		vPrevObj = Documents.ИзмЦены.CreateDocument();
	ИначеЕсли ТипЗнч(pObj) = Type("CatalogObject.Клиенты") Тогда
		vPrevObj = Справочники.Клиенты.CreateItem();
	ИначеЕсли ТипЗнч(pObj) = Type("CatalogObject.Контрагенты") Тогда
		vPrevObj = Справочники.Контрагенты.CreateItem();
	ИначеЕсли ТипЗнч(pObj) = Type("CatalogObject.Договора") Тогда
		vPrevObj = Справочники.Договора.CreateItem();
	КонецЕсли;
	Если vPrevObj = Неопределено Тогда
		ВызватьИсключение NStr("en='Object changes calculation algorithm is missing for type: ';ru='Не определен алгоритм получения изменений объекта с типом: ';de='Der Algorithmus für die Einholung von Änderungen am Objekt des Typs ist nicht festgelegt: '") + String(ТипЗнч(pObj));
	КонецЕсли;	
	vPrevObj.pmRestoreAttributesFromHistory(vPrevStateRec);
	// Get object metadata
	vObjMetadata = pObj.Metadata();
	// Compare code and description for catalog items
	Если ТипЗнч(pObj) = Type("CatalogObject.Клиенты") Or
	   ТипЗнч(pObj) = Type("CatalogObject.Контрагенты") Or 
	   ТипЗнч(pObj) = Type("CatalogObject.Договора") Тогда
		Если pObj.Code <> vPrevObj.Code Тогда
			vChanges = vChanges + NStr("en='Code';ru='Код';de='Code'") + ": " + СокрЛП(vPrevObj.Code) + " -> " + СокрЛП(pObj.Code) + Chars.LF + Chars.LF;
		КонецЕсли;
		Если pObj.Description <> vPrevObj.Description Тогда
			vChanges = vChanges + NStr("en='Description';ru='Наименование';de='Bezeichnung'") + ": " + СокрЛП(vPrevObj.Description) + " -> " + СокрЛП(pObj.Description) + Chars.LF + Chars.LF;
		КонецЕсли;
	КонецЕсли;
	// Compare number and date for documents
	Если ТипЗнч(pObj) = Type("DocumentObject.Размещение") Or
	   ТипЗнч(pObj) = Type("DocumentObject.Бронирование") Or
	   ТипЗнч(pObj) = Type("DocumentObject.БроньУслуг") Or
	   ТипЗнч(pObj) = Type("DocumentObject.ПриказТариф") Or
	   ТипЗнч(pObj) = Type("DocumentObject.ИзмЦены") Тогда
		Если pObj.НомерДока <> vPrevObj.НомерДока Тогда
			vChanges = vChanges + NStr("en='Document number';ru='Номер документа';de='Dokumentnummer'") + ": " + СокрЛП(vPrevObj.НомерДока) + " -> " + СокрЛП(pObj.НомерДока) + Chars.LF + Chars.LF;
		КонецЕсли;
		Если pObj.ДатаДок <> vPrevObj.ДатаДок Тогда
			vChanges = vChanges + NStr("en='Document date';ru='Дата документа';de='Datum des Dokuments'") + ": " + Format(vPrevObj.ДатаДок, "DF='dd.MM.yyyy HH:mm:ss'") + " -> " + Format(pObj.ДатаДок, "DF='dd.MM.yyyy HH:mm:ss'") + Chars.LF + Chars.LF;
		КонецЕсли;
	КонецЕсли;
	// Compare attributes
	Для Каждого vAttr Из vObjMetadata.Attributes Цикл
		Если Find(vAttributesToSkip, vAttr.Name) = 0 Тогда
			Если ТипЗнч(pObj[vAttr.Name]) <> Type("ValueStorage") Тогда
				Если pObj[vAttr.Name] <> vPrevObj[vAttr.Name] Тогда
					vChanges = vChanges + vAttr.Synonym + ": " + СокрЛП(String(vPrevObj[vAttr.Name])) + " -> " + СокрЛП(String(pObj[vAttr.Name])) + Chars.LF + Chars.LF;
				КонецЕсли;
			ИначеЕсли pObj[vAttr.Name] = Неопределено И vPrevObj[vAttr.Name] = Неопределено Тогда
			ИначеЕсли pObj[vAttr.Name] = Неопределено И vPrevObj[vAttr.Name] <> Неопределено Тогда
				vChanges = vChanges + vAttr.Synonym + ": " + String(vPrevObj[vAttr.Name]) + " -> " + Chars.LF + Chars.LF;
			ИначеЕсли pObj[vAttr.Name] <> Неопределено И vPrevObj[vAttr.Name] = Неопределено Тогда
				vChanges = vChanges + vAttr.Synonym + ": " + " -> " + String(pObj[vAttr.Name]) + Chars.LF + Chars.LF;
			ИначеЕсли pObj[vAttr.Name] <> Неопределено И vPrevObj[vAttr.Name] <> Неопределено Тогда
				vValue = pObj[vAttr.Name].Get();
				vPrevValue = vPrevObj[vAttr.Name].Get();
				Если vValue <> vPrevValue Тогда
					vChanges = vChanges + vAttr.Synonym + ": " + String(vPrevValue) + " -> " + String(vValue) + Chars.LF + Chars.LF;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	// Compare tabular parts
	Для Каждого vTS Из vObjMetadata.TabularSections Цикл
		Если pObj[vTS.Name].Count() > 0 Тогда
			Для Каждого vTSRow Из pObj[vTS.Name] Цикл
				vTSRowIndex = pObj[vTS.Name].IndexOf(vTSRow);
				vPrevTSRow = Неопределено;
				Если vTSRowIndex < vPrevObj[vTS.Name].Count() Тогда
					vRowChangesAreFound = False;
					vPrevTSRow = vPrevObj[vTS.Name].Get(vTSRowIndex);
					Для Каждого vTSAttr Из vObjMetadata.TabularSections[vTS.Name].Attributes Цикл
						Если vTSRow[vTSAttr.Name] <> vPrevTSRow[vTSAttr.Name] Тогда
							vRowChangesAreFound = True;
							vChanges = vChanges + vTS.Synonym + Chars.LF + "--------------------------------------------------------" + Chars.LF;
							vChanges = vChanges + NStr("en='First changed row N ';ru='Первая измененная строка № ';de='Erste geänderte Zeile Nr. '") + Format(vTSRowIndex + 1, "ND=10; NFD=0; NG=") + ": " + vTSAttr.Synonym + ": " + СокрЛП(String(vPrevTSRow[vTSAttr.Name])) + " -> " + СокрЛП(String(vTSRow[vTSAttr.Name])) + Chars.LF;
							Break;
						КонецЕсли;
					КонецЦикла;
					Если vRowChangesAreFound Тогда
						Break;
					ИначеЕсли pObj[vTS.Name].Count() <> vPrevObj[vTS.Name].Count() Тогда
						vChanges = vChanges + vTS.Synonym + Chars.LF + "--------------------------------------------------------" + Chars.LF;
						vChanges = vChanges + NStr("en='Different number of rows...';ru='Разное кол-во строк...';de='Unterschiedliche Menge an Zeile...'") + Chars.LF + Chars.LF;
						Break;
					КонецЕсли;
				Иначе
					Если vPrevObj[vTS.Name].Count() = 0 Тогда
						vChanges = vChanges + vTS.Synonym + Chars.LF + "--------------------------------------------------------" + Chars.LF;
						vChanges = vChanges + NStr("en='Новый rows were added to the empty table...';ru='Новые строки добавлены в пустую таблицу...';de='Neue Zeilen wurden in die leere Tabelle hinzugefügt...'") + Chars.LF + Chars.LF;
					Иначе
						vChanges = vChanges + vTS.Synonym + Chars.LF + "--------------------------------------------------------" + Chars.LF;
						vChanges = vChanges + NStr("en='Different number of rows...';ru='Разное кол-во строк...';de='Unterschiedliche Menge an Zeile...'") + Chars.LF + Chars.LF;
					КонецЕсли;
					Break;
				КонецЕсли;
			КонецЦикла;
		ИначеЕсли vPrevObj[vTS.Name].Count() > 0 Тогда
			vChanges = vChanges + vTS.Synonym + Chars.LF + "--------------------------------------------------------" + Chars.LF;
			vChanges = vChanges + NStr("en='All rows were deleted...';ru='Все строки были удалены...';de='Alle Zeilen wurden gelöscht...'") + Chars.LF + Chars.LF;
		КонецЕсли;
	КонецЦикла;
	Возврат СокрЛП(vChanges);
EndFunction //cmCompareObjectsData

//-----------------------------------------------------------------------------
// Description: Waits specified number of seconds
// Parameters: Number of seconds to wait
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmWait(pSeconds) Экспорт
	vCurTime = CurrentDate();
	vEndTime = vCurTime + pSeconds;
	Пока vCurTime <= vEndTime Цикл
		vCurTime = CurrentDate();
	КонецЦикла;
КонецПроцедуры //cmWait

//-----------------------------------------------------------------------------
// Description: Returns user readable root error descripion
// Parameters: Error info object
// Возврат value: Error description string 
//-----------------------------------------------------------------------------
Функция cmGetRootErrorDescription(pErrorInfo) Экспорт
	vErrorInfo = pErrorInfo;
	Если ТипЗнч(vErrorInfo) = Type("ErrorInfo") Тогда
		Пока vErrorInfo.Cause <> Неопределено Цикл
			vErrorInfo = vErrorInfo.Cause;
		КонецЦикла;
		Возврат vErrorInfo.Description;
	Иначе
		Возврат СокрЛП(pErrorInfo);
	КонецЕсли;
EndFunction //cmGetRootErrorDescription

//-----------------------------------------------------------------------------
// Description: Returns internet proxy object based on workstation settings
// Parameters: Internet connection settings catalog item reference, 
//             Boolean, true if proxy server is requested for a local address, 
//                      false for an internet address
//             Address as string to be checked across the list of addresses that should be bypassed
// Возврат value: Internet proxy object
//-----------------------------------------------------------------------------
Функция cmGetInternetProxy(pSettings = Неопределено, pIsLocal = False, pAddress = "") Экспорт
	vSettings = Неопределено;
	Если ЗначениеЗаполнено(pSettings) Тогда
		vSettings = pSettings;
	ИначеЕсли ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) И ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.НастройкиПодклИнет) Тогда
		vSettings = ПараметрыСеанса.РабочееМесто.НастройкиПодклИнет;
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(vSettings) Тогда
		Возврат Неопределено;
	Иначе
		Если pIsLocal И vSettings.BypassProxyOnLocal Тогда
			Возврат Неопределено;
		Иначе
			vProxy = Новый InternetProxy();
			vProxy.User = СокрЛП(vSettings.User);
			vProxy.Password = СокрЛП(vSettings.Password);
			Для Каждого vProtocolRow Из vSettings.Protocols Цикл
				Если НЕ IsBlankString(vProtocolRow.Protocol) И НЕ IsBlankString(vProtocolRow.Server) Тогда
					Если vProtocolRow.Port > 0 Тогда
						vProxy.Set(СокрЛП(vProtocolRow.Protocol), СокрЛП(vProtocolRow.Server), СокрЛП(vProtocolRow.Port));
					Иначе
						vProxy.Set(СокрЛП(vProtocolRow.Protocol), СокрЛП(vProtocolRow.Server));
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			// Check if input address is in the list of addresses that should be bypassed
			Если НЕ IsBlankString(pAddress) Тогда
				Для Каждого vAddress Из vProxy.BypassProxyOnAddresses Цикл
					Если Find(vAddress, СокрЛП(pAddress)) > 0 Or Find(СокрЛП(pAddress), vAddress) > 0 Тогда
						Возврат Неопределено;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
			// Возврат proxy object
			Возврат vProxy;
		КонецЕсли;
	КонецЕсли;
EndFunction //cmGetInternetProxy

//-----------------------------------------------------------------------------
// Description: Returns program version as date string
// Parameters: None
// Возврат value: Program version as date string in YYMMDD format
//-----------------------------------------------------------------------------
Функция cmGetProgramVersionAsDateString() Экспорт
	// Current version number
	vVersion = Mid(СокрЛП(Constants.НомерРелиза.Get()), 5);
	// Change 1C:Гостиница version number to date representation
	Если vVersion = "1.1" Тогда
		vVersion = "100928";
	ИначеЕсли vVersion = "1.2" Тогда
		vVersion = "101018";
	ИначеЕсли vVersion = "1.3" Тогда
		vVersion = "101119";
	ИначеЕсли vVersion = "1.4" Тогда
		vVersion = "101231";
	ИначеЕсли vVersion = "1.5" Тогда
		vVersion = "110329";
	ИначеЕсли vVersion = "1.6" Тогда
		vVersion = "110404";
	ИначеЕсли vVersion = "1.7" Тогда
		vVersion = "110419";
	ИначеЕсли vVersion = "1.8" Тогда
		vVersion = "110427";
	ИначеЕсли vVersion = "1.9" Тогда
		vVersion = "110518";
	ИначеЕсли vVersion = "1.10" Тогда
		vVersion = "110523";
	ИначеЕсли vVersion = "1.11" Тогда
		vVersion = "110531";
	ИначеЕсли vVersion = "1.12" Тогда
		vVersion = "110604";
	ИначеЕсли vVersion = "2.1" Тогда
		vVersion = "110615";
	ИначеЕсли vVersion = "2.2" Тогда
		vVersion = "111128";
	ИначеЕсли vVersion = "2.3" Тогда
		vVersion = "111230";
	ИначеЕсли vVersion = "2.4" Тогда
		vVersion = "120119";
	ИначеЕсли vVersion = "2.5" Тогда
		vVersion = "120205";
	ИначеЕсли vVersion = "2.6" Тогда
		vVersion = "120325";
	ИначеЕсли vVersion = "2.7" Тогда
		vVersion = "120418";
	ИначеЕсли vVersion = "2.8" Тогда
		vVersion = "120525";
	ИначеЕсли vVersion = "2.9" Тогда
		vVersion = "120710";
	ИначеЕсли vVersion = "2.10" Тогда
		vVersion = "120904";
	ИначеЕсли vVersion = "2.11" Тогда
		vVersion = "120928";
	ИначеЕсли vVersion = "2.12" Тогда
		vVersion = "121016";
	ИначеЕсли vVersion = "2.13" Тогда
		vVersion = "121123";
	ИначеЕсли vVersion = "2.14" Тогда
		vVersion = "121129";
	ИначеЕсли vVersion = "2.15" Тогда
		vVersion = "121218";
	ИначеЕсли vVersion = "2.16" Тогда
		vVersion = "130508";
	ИначеЕсли vVersion = "2.17" Тогда
		vVersion = "130920";
	ИначеЕсли vVersion = "2.19" Тогда
		vVersion = "131213";
	ИначеЕсли vVersion = "2.20" Тогда
		vVersion = "131225";
	ИначеЕсли vVersion = "2.21" Тогда
		vVersion = "140117";
	ИначеЕсли vVersion = "2.22" Тогда
		vVersion = "140205";
	ИначеЕсли vVersion = "2.23" Тогда
		vVersion = "140512";
	ИначеЕсли vVersion = "2.24" Тогда
		vVersion = "140520";
	ИначеЕсли vVersion = "2.25" Тогда
		vVersion = "140605";
	ИначеЕсли vVersion = "2.26" Тогда
		vVersion = "140717";
	ИначеЕсли vVersion = "2.27" Тогда
		vVersion = "140724";
	ИначеЕсли vVersion = "2.28" Тогда
		vVersion = "140818";
	ИначеЕсли vVersion = "2.29" Тогда
		vVersion = "140926";
	ИначеЕсли vVersion = "2.30" Тогда
		vVersion = "141027";
	ИначеЕсли vVersion = "2.31" Тогда
		vVersion = "141031";
	ИначеЕсли vVersion = "2.32" Тогда
		vVersion = "141212";
	ИначеЕсли vVersion = "2.33" Тогда
		vVersion = "141223";
	ИначеЕсли vVersion = "2.34" Тогда
		vVersion = "150104";
	ИначеЕсли vVersion = "2.35" Тогда
		vVersion = "150212";
	ИначеЕсли vVersion = "2.36" Тогда
		vVersion = "150305";
	ИначеЕсли vVersion = "2.37" Тогда
		vVersion = "150312";
	ИначеЕсли vVersion = "2.38" Тогда
		vVersion = "150423";
	ИначеЕсли vVersion = "2.39" Тогда
		vVersion = "150615";
	ИначеЕсли vVersion = "2.40" Тогда
		vVersion = "150624";
	КонецЕсли;
	Возврат vVersion;
EndFunction //cmGetProgramVersionAsDateString

//-----------------------------------------------------------------------------
// Description: Writes record to Safety System Events information register
// Parameters: Гостиница ref, Event type as string, Date and time of event, ГруппаНомеров ref, Card type as string, Card code as string, Document ref, Client ref, Event description as string, Check-in date, Check-out date, number of keys
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmWriteSafetyEvent(pHotel, pEventType, pPeriod = '00010101', pRoom, pCardType, pCardCode, pParentDoc = Неопределено, pClient = Неопределено, pEventDescription, pPeriodFrom = '00010101', pPeriodTo = '00010101', pNumberOfKeys = 0) Экспорт
	vRecMgr = InformationRegisters.SafetySystemEvents.CreateRecordManager();
	vRecMgr.Period = ?(ЗначениеЗаполнено(pPeriod), pPeriod, CurrentDate());
	vRecMgr.Автор = ПараметрыСеанса.ТекПользователь;
	vRecMgr.Гостиница = pHotel;
	vRecMgr.НомерРазмещения = pRoom;
	vRecMgr.EventType = pEventType;
	vRecMgr.CardType = pCardType;
	vRecMgr.CardCode = pCardCode;
	vRecMgr.ДокОснование = pParentDoc;
	vRecMgr.Клиент = pClient;
	vRecMgr.EventDescription = pEventDescription;
	vRecMgr.ПериодС = pPeriodFrom;
	vRecMgr.ПериодПо = pPeriodTo;
	vRecMgr.NumberOfKeys = pNumberOfKeys;
	vRecMgr.Записать();
КонецПроцедуры //cmWriteSafetyEvent

//-----------------------------------------------------------------------------
// Description: Returns 1C platform version as string
// Parameters: None
// Возврат value: String "8.2" or "8.3"
//-----------------------------------------------------------------------------
Функция cmGetPlatformVersion() Экспорт
	лСИ = Новый СистемнаяИнформация();
	vAppVersion = Лев(лСИ.ВерсияПриложения, 3);
	Если vAppVersion = "8.3" Тогда
		Если String(Метаданные.РежимСовместимости) = "Version8_2_16" Or String(Метаданные.РежимСовместимости) = "Version8_2_13" Тогда
			vAppVersion = "8.2";
		КонецЕсли;
	КонецЕсли;
	Возврат vAppVersion;
EndFunction //cmGetPlatformVersion

//-----------------------------------------------------------------------------
// Description: Checks RFID reader event name
// Parameters: Event name
// Возврат value: Boolean
//-----------------------------------------------------------------------------
Функция cmIsRFIDReaderExternalEvent(pStr) Экспорт
	Если pStr = "ironLogic Z-2" Тогда
		Возврат True;
	Иначе
		Возврат False;
	КонецЕсли;
EndFunction //cmIsRFIDReaderExternalEvent
