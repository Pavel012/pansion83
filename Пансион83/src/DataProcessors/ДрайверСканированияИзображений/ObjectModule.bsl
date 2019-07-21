////-----------------------------------------------------------------------------
//Function GetPaperSize(pScanConfiguration)
//	vPSCode = "";
//	vPS = Неопределено;
//	If ЗначениеЗаполнено(pScanConfiguration) And ЗначениеЗаполнено(pScanConfiguration.PaperSize) Тогда
//		vPS = pScanConfiguration.PaperSize;
//	ElsIf ЗначениеЗаполнено(ImageScannerConnectionParameters.PaperSize) Тогда
//		vPS = ImageScannerConnectionParameters.PaperSize;
//	EndIf;
//	If ЗначениеЗаполнено(vPS) Тогда
//		If vPS = Перечисления.PaperSizes.A0 Тогда
//			vPSCode = "A0";
//		ElsIf vPS = Перечисления.PaperSizes.A1 Тогда
//			vPSCode = "A1";
//		ElsIf vPS = Перечисления.PaperSizes.A2 Тогда
//			vPSCode = "A2";
//		ElsIf vPS = Перечисления.PaperSizes.A3 Тогда
//			vPSCode = "A3";
//		ElsIf vPS = Перечисления.PaperSizes.A4 Тогда
//			vPSCode = "A4";
//		ElsIf vPS = Перечисления.PaperSizes.A5 Тогда
//			vPSCode = "A5";
//		ElsIf vPS = Перечисления.PaperSizes.A6 Тогда
//			vPSCode = "A6";
//		ElsIf vPS = Перечисления.PaperSizes.A7 Тогда
//			vPSCode = "A7";
//		ElsIf vPS = Перечисления.PaperSizes.A8 Тогда
//			vPSCode = "A8";
//		ElsIf vPS = Перечисления.PaperSizes.A9 Тогда
//			vPSCode = "A9";
//		ElsIf vPS = Перечисления.PaperSizes.A10 Тогда
//			vPSCode = "A10";
//		ElsIf vPS = Перечисления.PaperSizes.B3 Тогда
//			vPSCode = "B3";
//		ElsIf vPS = Перечисления.PaperSizes.B4 Тогда
//			vPSCode = "B4";
//		ElsIf vPS = Перечисления.PaperSizes.B5 Тогда
//			vPSCode = "B5";
//		ElsIf vPS = Перечисления.PaperSizes.B6 Тогда
//			vPSCode = "B6";
//		ElsIf vPS = Перечисления.PaperSizes.C4 Тогда
//			vPSCode = "C4";
//		ElsIf vPS = Перечисления.PaperSizes.C5 Тогда
//			vPSCode = "C5";
//		ElsIf vPS = Перечисления.PaperSizes.C6 Тогда
//			vPSCode = "C6";
//		ElsIf vPS = Перечисления.PaperSizes.A40 Тогда
//			vPSCode = "4A0";
//		ElsIf vPS = Перечисления.PaperSizes.A20 Тогда
//			vPSCode = "2A0";
//		ElsIf vPS = Перечисления.PaperSizes.USLET Тогда
//			vPSCode = "USLET";
//		ElsIf vPS = Перечисления.PaperSizes.USLEG Тогда
//			vPSCode = "USLEG";
//		ElsIf vPS = Перечисления.PaperSizes.USLEDGER Тогда
//			vPSCode = "USLEDGER";
//		ElsIf vPS = Перечисления.PaperSizes.USEXECUTIVE Тогда
//			vPSCode = "USEXECUTIVE";
//		EndIf;
//	EndIf;
//	Return vPSCode;
//EndFunction //GetPaperSize
//
////-----------------------------------------------------------------------------
//Function GetRotation(pScanConfiguration)
//	vRotation = "";
//	If ЗначениеЗаполнено(pScanConfiguration) And pScanConfiguration.Rotation <> 0 Тогда
//		vRotation = pScanConfiguration.Rotation;
//	ElsIf ImageScannerConnectionParameters.Rotation <> 0 Тогда
//		vRotation = ImageScannerConnectionParameters.Rotation;
//	EndIf;
//	Return vRotation;
//EndFunction //GetRotation
//
////-----------------------------------------------------------------------------
//Function GetColorDepth(pScanConfiguration)
//	vColorDepthCode = "";
//	vColorDepth = Неопределено;
//	If ЗначениеЗаполнено(pScanConfiguration) And ЗначениеЗаполнено(pScanConfiguration.ColorDepth) Тогда
//		vColorDepth = pScanConfiguration.ColorDepth;
//	ElsIf ЗначениеЗаполнено(ImageScannerConnectionParameters.ColorDepth) Тогда
//		vColorDepth = ImageScannerConnectionParameters.ColorDepth;
//	EndIf;
//	If ЗначениеЗаполнено(vColorDepth) Тогда
//		If vColorDepth = Перечисления.ColorDepths.RGB Тогда
//			vColorDepthCode = "RGB";
//		ElsIf vColorDepth = Перечисления.ColorDepths.Palette Тогда
//			vColorDepthCode = "PALETTE";
//		ElsIf vColorDepth = Перечисления.ColorDepths.Gray Тогда
//			vColorDepthCode = "GRAY";
//		ElsIf vColorDepth = Перечисления.ColorDepths.BW Тогда
//			vColorDepthCode = "BW";
//		EndIf;
//	EndIf;
//	Return vColorDepthCode;
//EndFunction //GetColorDepth
//
////-----------------------------------------------------------------------------
//Function pmGetListOfTWAINDevices(rMessage) Экспорт
//	vList = New СписокЗначений();
//	// Reset return status
//	rMessage = "";
//	// Try to load external component
//	vScObj = pmConnect(rMessage);
//	If vScObj <> Неопределено Тогда
//		Try
//			// Get list of TWAIN devices
//			If vScObj.SelectScanners() <> 1 Тогда
//				ВызватьИсключение NStr("en='Failed to load TWAIN devices list!';ru='Не удалось получить список TWAIN устройств!';de='Es konnte keine Liste von TWAIN-Geräten eingeholte werden!'");
//			EndIf;
//			While vScObj.GetScanner() = 1 Do
//				vList.Add(vScObj.ProductName);
//			EndDo;
//		Except
//			rMessage = ErrorDescription();
//		EndTry;
//	EndIf;
//	Return vList;
//EndFunction //pmGetListOfTWAINDevices
//
////-----------------------------------------------------------------------------
//Function pmGetListOfAllowedConfigurations(rMessage) Экспорт
//	vList = New СписокЗначений();
//	rMessage = NStr("en='Recognition configurations are not used by this driver!';ru='Конфигурации распознавания изображений не поддерживаются выбранным драйвером!';de='Die Konfigurationen für die Erkennungen von Abbildungen werden von diesem Treiber nicht unterstützt'");
//	Return vList;
//EndFunction //pmGetListOfAllowedConfigurations
//
////-----------------------------------------------------------------------------
//Процедура Connect(pScObj, pTwainDeviceName)
//	// Set current TWAIN device
//	If pScObj.SelectScanners() <> 1 Тогда
//		ВызватьИсключение NStr("en='Failed to load TWAIN devices list!';ru='Не удалось получить список TWAIN устройств!';de='Es konnte keine Liste von TWAIN-Geräten eingeholte werden!'");
//	EndIf;
//	If НЕ IsBlankString(pTwainDeviceName) Тогда
//		While pScObj.GetScanner() = 1 Do
//			If pScObj.ProductName = pTwainDeviceName Тогда
//				Break;
//			EndIf;
//		EndDo;
//	Else
//		pScObj.GetScanner();
//	EndIf;
//	If pScObj.Connect() = 0 Тогда
//		ВызватьИсключение NStr("en='Failed to switch to the scanner!';ru='Не удалось подключиться к сканеру!';de='Es konnte kein Anschluss an den Scanner hergestellt werden!'");
//	EndIf;
//	// Set resolution
//	If pScObj.SetParam("XResolution", 300) = -1 Тогда
//		vRes = pScObj.SetParam("XResolution", 100);
//		If vRes = 0 Тогда
//			ВызватьИсключение NStr("en='Failed to set resolution!';ru='Не удалось установить разрешение!';de='Die Auflösung konnte nicht festgelegt werden!'");
//		EndIf;
//	EndIf;
//	If pScObj.SetParam("YResolution", 300) = -1 Тогда
//		vRes = pScObj.SetParam("YResolution", 100);
//		If vRes = 0 Тогда
//			ВызватьИсключение NStr("en='Failed to set resolution!';ru='Не удалось установить разрешение!';de='Die Auflösung konnte nicht festgelegt werden!'");
//		EndIf;
//	EndIf;
//КонецПроцедуры //Connect
//
////-----------------------------------------------------------------------------
//Function pmConnect(rMessage, pDummy = Неопределено) Экспорт
//	
//	// Reset return status
//	rMessage = "";
//	// Try to load external component
//	Try
//		vTwainDeviceName = "";
//		If НЕ IsBlankString(ImageScannerConnectionParameters.TwainDeviceName) Тогда
//			vTwainDeviceName = TrimAll(ImageScannerConnectionParameters.TwainDeviceName);
//		EndIf;
//		// Use 1CScan.dll
//		vScObj = Неопределено;
//		#IF CLIENT THEN
//			If глСканерИзобр = Неопределено Тогда
//				Try
//					AttachAddIn("AddIn.ScanManager");
//					vScObj = New("AddIn.ScanManager");
//				Except
//					LoadAddIn("1CScan.dll");
//					vScObj = New("AddIn.ScanManager");
//				EndTry;
//				Connect(vScObj, vTwainDeviceName);
//				глСканерИзобр = vScObj;
//			Else
//				vScObj = глСканерИзобр;
//			EndIf;
//		#ELSE
//			vScObj = New COMObject("AddIn.ScanManager");
//			Connect(vScObj, vTwainDeviceName);
//		#ENDIF
//		// OK
//		Return vScObj;
//	Except
//		rMessage = ErrorDescription();
//		Return Неопределено;
//	EndTry;
//EndFunction //pmConnect
//
////-----------------------------------------------------------------------------
//Процедура pmDisconnect(pScObj, pDummy = Неопределено) Экспорт
//	Try
//		pScObj.Disconnect();
//		pScObj = Неопределено;
//		#IF CLIENT THEN
//			глСканерИзобр = Неопределено;
//		#ENDIF			
//	Except
//	EndTry;
//КонецПроцедуры //pmDisconnect
//
////-----------------------------------------------------------------------------
//Процедура ProcessException(pScObj, pFunction, rMessage)
//	Message(rMessage, MessageStatus.Attention);
//	WriteLogEvent(pFunction, EventLogLevel.Warning, ImageScannerConnectionParameters.Metadata(), ImageScannerConnectionParameters, "Error description: " + rMessage);
//	pmDisconnect(pScObj);
//КонецПроцедуры //ProcessException
//
////-----------------------------------------------------------------------------
//Процедура ConvertImage(pTargetFileName, pSourceFileName, pScObj)
//	// Build active X object to rotate picture
//	
//КонецПроцедуры //ConvertImage
//
////-----------------------------------------------------------------------------
//Function pmScanDocument(pScanConfiguration, pPictureStorage, rMessage) Экспорт
//	// Try to connect
//	vScObj = pmConnect(rMessage);
//	If vScObj = Неопределено Тогда
//		Return False;
//	Else
//		// Scanner was connected
//		Try
//			// Set document paper size
//			vPSCode = GetPaperSize(pScanConfiguration);
//			If НЕ IsBlankString(vPSCode) Тогда
//				If vScObj.SetParam("PaperSize", vPSCode) = 0 Тогда
//					ВызватьИсключение NStr("en='Failed to set paper size!';ru='Не удалось установить размер бумаги!';de='Papiergröße konnte nicht festgelegt werden!'");
//				EndIf;
//			EndIf;
//			// Set document rotation
//			vRotation = GetRotation(pScanConfiguration);
//			If НЕ IsBlankString(vRotation) Тогда
//				If vScObj.SetParam("Rotation", vRotation) = 0 Тогда
//					ВызватьИсключение NStr("en='Failed to set rotation degree!';ru='Не удалось установить угол поворота!';de='Der Drehwinkel konnte nicht festgelegt werden!'");
//				EndIf;
//			EndIf;
//			// Set document color depth
//			vColorDepthCode = GetColorDepth(pScanConfiguration);
//			If НЕ IsBlankString(vColorDepthCode) Тогда
//				If vScObj.SetParam("PixelType", vColorDepthCode) = 0 Тогда
//					ВызватьИсключение NStr("en='Failed to set color depth!';ru='Не удалось установить глубину цвета!';de='Die Farbentiefe konnte nicht festgelegt werden!'");
//				EndIf;
//			EndIf;
//			// Set scan resolution to 300 dpi
//			If vScObj.SetParam("XResolution", 300) = 0 Тогда
//				ВызватьИсключение NStr("en='Failed to set X resolution to 300 dpi!';ru='Не удалось установить разрешение по оси X в 300 dpi!';de='Die Auflösung der X-Achse im 300 dpi nicht eingestellt!'");
//			EndIf;
//			If vScObj.SetParam("YResolution", 300) = 0 Тогда
//				ВызватьИсключение NStr("en='Failed to set Y resolution to 300 dpi!';ru='Не удалось установить разрешение по оси Y в 300 dpi!';de='Die Auflösung der Y-Achse im 300 dpi nicht eingestellt!'");
//			EndIf;
//			// Scan document
//			vPictFileName = GetTempFileName();
//			vScObj.GetBMPFile(vPictFileName);
//			ConvertImage(vPictFileName + ".jpg", vPictFileName, vScObj);
//			pPictureStorage = New ValueStorage(New Picture(vPictFileName + ".jpg"));
//			Try
//				DeleteFiles(vPictFileName);
//				DeleteFiles(vPictFileName + ".jpg");
//			Except
//			EndTry;
//			// Return success
//			Return True;
//		Except
//			rMessage = ErrorDescription();
//			ProcessException(vScObj, NStr("en='ImageScannerDriver.ScanDocument';ru='СканерИзображений.СканироватьДокумент';de='ImageScannerDriver.ScanDocument'"), rMessage);
//		EndTry;
//	EndIf;
//	Return False;
//EndFunction //pmScanDocument
//
////-----------------------------------------------------------------------------
//Function pmRecognizeDocument(pClientDataScansObj, rMessage, pScObj = Неопределено, pDummy = Неопределено) Экспорт
//	rMessage = NStr("en='Image recognition feature is not supported by this driver!';ru='Функция распознавания изображений не поддерживается выбранным драйвером!';de='Die Bilderkennungsfunktion wird vom ausgewählten Treiber nicht unterstützt!'");
//	Return False;
//EndFunction //pmRecognizeDocument
