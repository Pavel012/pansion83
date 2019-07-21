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
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ ЗначениеЗаполнено(DataExchangeFileCurrency) Тогда
//			DataExchangeFileCurrency = Гостиница.BaseCurrency;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(Service) Тогда
//			Service = Гостиница.CateringService;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//// Run data processor in silent mode
////-----------------------------------------------------------------------------
//Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
//	// Load restaurant orders
//	pmLoadOrders(pIsInteractive);
//КонецПроцедуры //pmRun
//
////-----------------------------------------------------------------------------
//// Data processors framework end
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Function AddTime(pDate, pTime)
//	vHours = Number(Left(pTime, 2));
//	vMinutes = Number(Mid(pTime, 4, 2));
//	vSeconds = Number(Right(pTime, 2));
//	Return BegOfday(pDate) + vHours*3600 + vMinutes*60 + vSeconds;
//EndFunction //AddTime
//
////-----------------------------------------------------------------------------
//Function GetTempDataExchangeFileName(pDataExchangeFile)
//	vExt = Right(TrimR(pDataExchangeFile), 4);
//	vLeft = Left(pDataExchangeFile, StrLen(TrimR(pDataExchangeFile))-4);
//	Return vLeft + "~" + vExt;
//EndFunction //GetTempDataExchangeFileName
//
////-----------------------------------------------------------------------------
//Function GetHistoryDataExchangeFileName(pDataExchangeFile)
//	vFile = New File(pDataExchangeFile);
//	vFileName = TrimAll(vFile.BaseName);
//	vExt = Right(pDataExchangeFile, 4);
//	vHistoryCatalog = TrimAll(HistoryCatalog);
//	If Right(vHistoryCatalog, 1) <> "\" And Right(vHistoryCatalog, 1) <> "/" Тогда
//		vHistoryCatalog = vHistoryCatalog + "\";
//	EndIf;
//	Return vHistoryCatalog + vFileName + "_" + Format(CurrentDate(), "DF=yyyyMMddHHmmss") + vExt;
//EndFunction //GetHistoryDataExchangeFileName
//
////-----------------------------------------------------------------------------
//Function GetXBaseEncoding(pDataExchangeFileEncoding)
//	If pDataExchangeFileEncoding = Перечисления.FileEncoding.OEM Тогда
//		Return XBaseEncoding.OEM;
//	Else
//		Return XBaseEncoding.ANSI;
//	EndIf;
//EndFunction //GetXBaseEncoding
//
////-----------------------------------------------------------------------------
//Процедура pmLoadOrders(pIsInteractive = False) Экспорт
//	WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
//	// Check parameters
//	If IsBlankString(DataExchangeFile) Тогда
//		vMessage = NStr("ru = 'Не указан файл обмена данными!'; 
//		                |de = 'Data exchange file is not set up!'; 
//						|en = 'Data exchange file is not set up!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Service) Тогда
//		vMessage = NStr("ru = 'Не указана услуга!'; 
//		                |de = 'Service is not set up!'; 
//						|en = 'Service is not set up!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DataExchangeFileCurrency) Тогда
//		vMessage = NStr("ru = 'Не указана валюта файла обмена!'; 
//		                |de = 'Data exchange file currency is not set up!';
//						|en = 'Data exchange file currency is not set up!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Attention);
//			Return;
//		Else
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	vOrdersFile = New File(TrimAll(DataExchangeFile));
//	If НЕ vOrdersFile.Exist() Тогда
//		vMessage = NStr("ru = 'Файл с выгруженными заказами ресторана не найден!'; 
//						|en = 'Data exchange file with exported restaurant orders is not found!';
//						|de = 'Data exchange file with exported restaurant orders is not found!'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Note, ThisObject.Metadata(), Неопределено, vMessage);
//		Return;
//	EndIf;
//	
//	// Rename data exchange file to lock it from external change
//	vDataExchangeFile = GetTempDataExchangeFileName(DataExchangeFile);
//	vFileIsNotMoved = True;
//	While vFileIsNotMoved Do
//		Try
//			MoveFile(DataExchangeFile, vDataExchangeFile);
//			vFileIsNotMoved = False;
//		Except
//			// Wait some time
//			i = 0;
//			While i < 50000 Do
//				i = i + 1;
//			EndDo;
//			
//			// Check user interrupt processing
//			If pIsInteractive Тогда
//				#IF CLIENT THEN
//					UserInterruptProcessing();
//				#ENDIF
//			EndIf;
//		EndTry;
//	EndDo;
//
//	// Begin transaction if running on server
//	If НЕ pIsInteractive Тогда
//		BeginTransaction(DataLockControlMode.Managed);
//	EndIf;
//	
//	// Open orders file
//	vCount = 0;
//	vOrders = New XBase();
//	vOrders.Encoding = GetXBaseEncoding(DataExchangeFileEncoding);
//	vOrders.ShowDeleted = False;
//	vOrders.OpenFile(TrimAll(vDataExchangeFile), , True);
//	If vOrders.First() Тогда
//		While НЕ vOrders.EOF() Do
//			Try
//				vCount = vCount + 1;
//				
//				// Parse orders fields
//				vOrderNumber = TrimAll(vOrders.NUMDOC);
//				vOrderTime = Date(vOrders.DATE);
//				vOrderTime = AddTime(vOrderTime, vOrders.TIME);
//				vOrderCardCode = TrimAll(vOrders.CODECARD);
//				vOrderCardID = TrimAll(vOrders.IDCARD);
//				vOrderPlace = TrimAll(vOrders.NAMEREST);
//				vOrderTable = TrimAll(vOrders.NUMPLACE);
//				vOrderAuthor = TrimAll(vOrders.TNOFIC);
//				
//				vOrderSum = Number(vOrders.SUMBN);
//				vOrderCashSum = Number(vOrders.SUMNAL);
//				vOrderCreditSum = Number(vOrders.SUMCREDIT);
//				vOrderNoPaymentSum = Number(vOrders.SUMNEPLAT);
//				
//				vOrderData = NStr("ru = 'Заказ №'; en = 'Order N'; de = 'Bestellung Nr.'") + vOrderNumber + NStr("en=' on ';ru=' от ';de=' vom '") + vOrderTime + " - " + vOrderPlace + NStr("ru = ', стол '; en = ', table '; de = ', Tisch '") + vOrderTable + " - " + vOrderAuthor;
//				
//				// Take ГруппаНомеров number description from the card code
//				vRoomDescription = vOrderCardCode;
//				// Take ГруппаНомеров code from the table number
//				vRoomCode = vOrderTable;
//				
//				// Load order sum only
//				If vOrderSum <> 0 Тогда
//					// Check if ГруппаНомеров is filled
//					vSkipLoading = False;
//					vRoomRef = Справочники.НомернойФонд.EmptyRef();
//					If НЕ IsBlankString(vRoomDescription) Or НЕ IsBlankString(vRoomCode) Тогда
//						If НЕ IsBlankString(vRoomCode) Тогда
//							vRoomRef = Справочники.НомернойФонд.FindByDescription(vRoomCode, True, , Гостиница);
//						EndIf;
//						If НЕ ЗначениеЗаполнено(vRoomRef) Тогда
//							If НЕ IsBlankString(vRoomDescription) Тогда
//								vRoomRef = Справочники.НомернойФонд.FindByDescription(vRoomDescription, True, , Гостиница);
//							EndIf;
//						EndIf;
//						If НЕ ЗначениеЗаполнено(vRoomRef) Тогда
//							// Skip this order cause this order do not have reference to the ГруппаНомеров
//							vSkipLoading = True;
//							
//							vMessage= NStr("ru = 'Пропущен заказ на стол '; en = 'Skip loading order from table '; de = 'Skip loading order from table '") + vOrderTable + "!" + Chars.LF + vOrderData;
//							WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Note, ThisObject.Metadata(), , vMessage);
//							If pIsInteractive Тогда
//								Message(vMessage, MessageStatus.Important);
//							EndIf;
//						EndIf;
//					Else
//						// Skip this order cause this order do not have reference to the ГруппаНомеров
//						vSkipLoading = True;
//						
//						vMessage= NStr("ru = 'Пропущен заказ без указания стола!'; en = 'Skip loading order without table!'; de = 'Skip loading order without table!'") + Chars.LF + vOrderData;
//						WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Note, ThisObject.Metadata(), , vMessage);
//						If pIsInteractive Тогда
//							Message(vMessage, MessageStatus.Important);
//						EndIf;
//					EndIf;
//					
//					// Try to create interface document
//					If НЕ vSkipLoading Тогда
//						WriteOrder(vRoomRef, vOrderTime, vOrderSum, vOrderAuthor, vOrderData, pIsInteractive);
//					EndIf;
//				EndIf;
//			Except
//				vMessage = ErrorDescription();
//				WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Warning, ThisObject.Metadata(), , vMessage);
//				
//				If pIsInteractive Тогда
//					Message(vMessage, MessageStatus.Attention);
//				Else
//					// Rollback transaction if running on server
//					RollbackTransaction();
//					
//					// Rename file back
//					If vOrders.IsOpen() Тогда
//						vOrders.CloseFile();
//					EndIf;
//					MoveFile(vDataExchangeFile, DataExchangeFile);
//					
//					ВызватьИсключение vMessage;
//				EndIf;
//			EndTry;
//			
//			// Go to the previous record
//			vOrders.Next();
//			
//			// Check user interrupt processing
//			If pIsInteractive Тогда
//				#IF CLIENT THEN
//					UserInterruptProcessing();
//				#ENDIF
//			EndIf;
//		EndDo;
//	EndIf;
//						
//	If vOrders.IsOpen() Тогда
//		vOrders.CloseFile();
//	EndIf;
//	
//	// Commit transaction if running on server
//	If НЕ pIsInteractive Тогда
//		CommitTransaction();
//	EndIf;
//	
//	// Move export file to the history catalog
//	If НЕ IsBlankString(HistoryCatalog) Тогда
//		If NumberOfFilesInHistory > 0 Тогда
//			vHistoryDataExchangeFile = GetHistoryDataExchangeFileName(DataExchangeFile);
//			MoveFile(vDataExchangeFile, vHistoryDataExchangeFile);
//			// Delete old files
//			vFilesArray = FindFiles(TrimAll(HistoryCatalog), "*.dbf");
//			If vFilesArray.Count() > 0 Тогда
//				vFilesList = New СписокЗначений();
//				For Each vFile In vFilesArray Do
//					vFileItem = vFilesList.Add(vFile, vFile.Name);
//				EndDo;
//				vFilesList.SortByPresentation(SortDirection.Asc);
//				While vFilesList.Count() > NumberOfFilesInHistory Do
//					vFileItem = vFilesList.Get(0);
//					DeleteFiles(vFileItem.Value.FullName);
//					vFilesList.Delete(0);
//				EndDo;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Log that processing is finished
//	WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("ru = 'Конец выполнения процедуры загрузки заказов ресторана. Загружено " + vCount + " записей.'; en = 'End of loading orders. " + vCount + " orders were loaded.'; de = 'End of loading orders. " + vCount + " orders were loaded.'"));
//КонецПроцедуры //pmLoadOrders
//
////-----------------------------------------------------------------------------
//Процедура WriteOrder(pRoom, pOrderTime, pOrderSum, pOrderAuthor, pOrderData, pIsInteractive)
//	// Create new interface document object
//	vRoomServiceObj = Documents.УслугаВНомер.CreateDocument();
//	vRoomServiceObj.Гостиница = Гостиница;
//	vRoomServiceObj.pmFillAuthorAndDate();
//	vRoomServiceObj.SetNewNumber();
//	vRoomServiceObj.pmFillAttributesWithDefaultValues();
//	
//	// Fill order sum
//	vRoomServiceObj.УслугиНомер = Service;
//	vRoomServiceObj.ЕдИзмерения = Service.Unit;
//	vRoomServiceObj.RoomServiceChargeType = NStr("en='Restaurant';ru='Ресторан';de='Restaurant'");
//	vRoomServiceObj.Цена = pOrderSum;
//	vRoomServiceObj.Количество = 1;
//	vRoomServiceObj.Сумма = pOrderSum;
//	
//	// Fill currency attributes
//	vRoomServiceObj.Валюта = DataExchangeFileCurrency;
//	vRoomServiceObj.CurrencyExchangeRate = cmGetCurrencyExchangeRate(vRoomServiceObj.Гостиница, vRoomServiceObj.Валюта, vRoomServiceObj.ExchangeRateDate);
//	
//	// Fill call attributes
//	vRoomServiceObj.ServiceDate = pOrderTime;
//	
//	// Try to find folio to charge to
//	vRoomServiceObj.НомерРазмещения = pRoom;
//	If ЗначениеЗаполнено(vRoomServiceObj.НомерРазмещения) Тогда
//		If ЗначениеЗаполнено(vRoomServiceObj.НомерРазмещения.Фирма) Тогда
//			vRoomServiceObj.Фирма = vRoomServiceObj.НомерРазмещения.Фирма;
//			If НЕ ЗначениеЗаполнено(vRoomServiceObj.УслугиНомер) Тогда
//				vRoomServiceObj.СтавкаНДС = vRoomServiceObj.Фирма.СтавкаНДС;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(vRoomServiceObj.FixedService) Тогда
//				vRoomServiceObj.FixedServiceVATRate = vRoomServiceObj.Фирма.СтавкаНДС;
//			EndIf;
//		EndIf;
//		vRoomServiceObj.СчетПроживания = vRoomServiceObj.pmGetFolioToChargeTo();
//	EndIf;
//	
//	// Try to find active ГруппаНомеров folio
//	If НЕ ЗначениеЗаполнено(vRoomServiceObj.СчетПроживания) Тогда
//		vFolios = cmGetActiveRoomFolios(Гостиница, vRoomServiceObj.НомерРазмещения, Гостиница.FolioCurrency);
//		If vFolios.Count() > 0 Тогда
//			vRow = vFolios.Get(0);
//			vRoomServiceObj.СчетПроживания = vRow.СчетПроживания;
//		EndIf;
//	EndIf;
//	// Create new empty one
//	If НЕ ЗначениеЗаполнено(vRoomServiceObj.СчетПроживания) Тогда
//		vFolioObj = Documents.СчетПроживания.CreateDocument();
//		vFolioObj.Гостиница = Гостиница;
//		vFolioObj.pmFillAttributesWithDefaultValues();
//		vFolioObj.НомерРазмещения = vRoomServiceObj.НомерРазмещения;
//		vFolioObj.Description = NStr("en='Restaurant orders on vacant rooms';ru='Заказы ресторана на свободные номера';de='Restaurantbestellungen auf freie Plätze'");
//		vFolioObj.Write(DocumentWriteMode.Write);
//		
//		vRoomServiceObj.СчетПроживания = vFolioObj.Ref;
//		
//		vMessage = NStr("ru = 'Создано фолио: " + String(vRoomServiceObj.СчетПроживания) + "'; 
//		                |de = 'ЛицевойСчет " + String(vRoomServiceObj.СчетПроживания) + " was created'; 
//						|en = 'ЛицевойСчет " + String(vRoomServiceObj.СчетПроживания) + " was created'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Note, vRoomServiceObj.СчетПроживания.Metadata(), vRoomServiceObj.СчетПроживания, vMessage);
//	EndIf;
//	
//	// Process folio
//	vRoomServiceObj.pmFillByFolio();
//	vRoomServiceObj.pmRecalculateSums();
//	
//	// Fill remarks
//	vRoomServiceObj.Примечания = pOrderData;
//	
//	// Post current document
//	vRoomServiceObj.Write(DocumentWriteMode.Posting);
//				
//	// Log current state
//	vMessage = NStr("ru = 'Создан документ: " + String(vRoomServiceObj.Ref) + "'; 
//	                |de = 'Document " + String(vRoomServiceObj.Ref) + " was created'; 
//					|en = 'Document " + String(vRoomServiceObj.Ref) + " was created'") + Chars.LF + pOrderData;
//	WriteLogEvent(NStr("en='DataProcessor.LoadOrdersFrom1CRestaurantFO'; de='DataProcessor.LoadOrdersFrom1CRestaurantFO'; ru='Обработка.ЗагрузкаЗаказовРесторанаИз1СФО'"), EventLogLevel.Information, ThisObject.Metadata(), vRoomServiceObj.Ref, vMessage);
//	If pIsInteractive Тогда
//		Message(vMessage, MessageStatus.Information);
//	Endif;
//КонецПроцедуры //WriteOrder
