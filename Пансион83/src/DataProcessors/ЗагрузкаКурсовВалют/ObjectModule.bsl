//Перем FileName;
//
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
//	// Fill parameters with default values
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(CurrencyRatesSource) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If ЗначениеЗаполнено(Гостиница.Гражданство) Тогда
//				If TrimAll(Гостиница.Гражданство.ISOCode) = "RU" Тогда
//					CurrencyRatesSource = Перечисления.CurrencyRatesSources.RBC;
//				ElsIf TrimAll(Гостиница.Гражданство.ISOCode) = "KG" Тогда
//					CurrencyRatesSource = Перечисления.CurrencyRatesSources.Kato;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = BegOfDay(CurrentDate() + 24*3600); // For tomorrow
//		PeriodTo = EndOfDay(PeriodFrom);
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//// Run data processor in silent mode
////-----------------------------------------------------------------------------
//Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
//	// Fill currencies list
//	pmFillCurrenciesList();
//	// Load rates
//	pmLoadCurrencyRates(pIsInteractive);
//КонецПроцедуры //pmRun
//
////-----------------------------------------------------------------------------
//// Data processors framework end
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура pmFillCurrenciesList() Экспорт
//	Currencies.Clear();
//	vAllCurrencies = cmGetAllCurrencies();
//	For Each vAllCurrenciesRow In vAllCurrencies Do
//		// Skip base currency
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If vAllCurrenciesRow.Валюта = Гостиница.BaseCurrency Тогда
//				Continue;
//			EndIf;
//		EndIf;
//		// Add row
//		vRow = Currencies.Add();
//		vRow.Валюта = vAllCurrenciesRow.Валюта;
//	EndDo;
//КонецПроцедуры //pmFillCurrenciesList
//	
////-----------------------------------------------------------------------------
//Процедура pmLoadCurrencyRates(pIsInteractive = False) Экспорт
//	WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
//	If CurrencyRatesSource = Перечисления.CurrencyRatesSources.RBC Тогда
//		pmLoadCurrencyRatesFromRBC(pIsInteractive);
//	ElsIf CurrencyRatesSource = Перечисления.CurrencyRatesSources.Kato Тогда
//		pmLoadCurrencyRatesFrom1CKato(pIsInteractive);
//	ElsIf CurrencyRatesSource = Перечисления.CurrencyRatesSources.BNM Тогда
//		pmLoadCurrencyRatesFromBNM(pIsInteractive);
//	EndIf;
//	WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
//КонецПроцедуры //pmLoadCurrencyRates	
//
////-----------------------------------------------------------------------------
//// Extracts characters before first TAB
////-----------------------------------------------------------------------------
//Function ExtractWord(pStr)
//	vWord = "";
//    vPos = Find(pStr, Chars.Tab);
//	If vPos > 0 Тогда
//		vWord = Left(pStr, vPos-1);
//		pStr = Mid(pStr, vPos+1);
//	Else
//		vWord = pStr;
//		pStr = "";
//	EndIf;
//	Return vWord;
//EndFunction //ExtractWord
//
////-----------------------------------------------------------------------------
//Процедура pmLoadCurrencyRatesFromRBC(pIsInteractive) Экспорт
//	Перем vHTTP;
//	
//	vCurrencyRatesMgr = InformationRegisters.КурсВалют.CreateRecordManager();
//
//	vText = New TextDocument();
//
//	vSourceCite = "cbrates.rbc.ru";
//
//	vAddress = "";
//	vPeriod = "";
//	If BegOfDay(PeriodFrom) = BegOfDay(PeriodTo) Тогда
//		vAddress = "tsv/";
//		vPeriod = "/" + Format(Year(PeriodTo),"NGS=; NG=0") + 
//		          "/" + Format(Month(PeriodTo), "ND=2; NFD=0; NLZ=") + 
//		          "/" + Format(Day(PeriodTo), "ND=2; NFD=0; NLZ=");
//	Else
//		vAddress = "tsv/cb/";
//		vPeriod = "";
//	EndIf;
//
//	vTmpDir = TempFilesDir() + "LoadRates";
//	CreateDirectory(vTmpDir);
//	DeleteFiles(vTmpDir, "*.*");
//	
//	For Each vCurrencyRow In Currencies Do
//		vCurCurrency = vCurrencyRow.Currency;
//			
//		// Read currency rate for the start of the period to get bonus rate last used
//		vLastCurrencyRates = InformationRegisters.КурсВалют.SliceLast(PeriodFrom, New Structure("Гостиница, Валюта", Гостиница, vCurCurrency));
//	
//		vRcvFileName = "" + vTmpDir + "\" + FileName;
//		vRcvFileAddress = vAddress + Right(vCurCurrency.Code, 3) + vPeriod + ".tsv";
//		
//		Try
//			vProxyServer = cmGetInternetProxy(InternetConnectionSettings, False, vSourceCite);
//			If vProxyServer = Неопределено Тогда
//				vHTTP = New HTTPConnection(vSourceCite);
//			Else
//				vHTTP = New HTTPConnection(vSourceCite, , , , vProxyServer);
//			EndIf;
//			vHTTP.Get(New HTTPRequest(vRcvFileAddress), vRcvFileName);
//		Except
//			vMessage = NStr("ru = 'Не удалось получить ресурс для валюты " + TrimAll(vCurCurrency.Description) + "! Курс для валюты не загружен.'; 
//			                |de = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'; 
//			                |en = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'");
//			WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Warning, ThisObject.Metadata(), vCurCurrency, vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//				Continue;
//			Else
//				ВызватьИсключение vMessage;
//			EndIf;
//		EndTry; 
//
//		vRcvFile = New File(vRcvFileName);
//		If НЕ vRcvFile.Exist() Тогда
//			vMessage = NStr("ru = 'Не удалось получить ресурс для валюты " + TrimAll(vCurCurrency.Description) + "! Курс для валюты не загружен.'; 
//			                |de = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'; 
//			                |en = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'");
//			WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Warning, ThisObject.Metadata(), vCurCurrency, vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//				Continue;
//			Else
//				ВызватьИсключение vMessage;
//			EndIf;
//		EndIf;
//
//		vText.Read(vRcvFileName, TextEncoding.ANSI);
//		vLineCount = vText.LineCount();
//		For i = 1 To vLineCount Do
//			vStr = vText.GetLine(i);
//			If (vStr = "") Or (Find(vStr, Chars.Tab) = 0) Тогда
//			   Continue;
//			EndIf;
//			vExchangeRateDate = Неопределено;
//			If BegOfDay(PeriodFrom) = BegOfDay(PeriodTo) Тогда
//				vExchangeRateDate = BegOfDay(PeriodTo);
//			Else 
//				vDateStr = ExtractWord(vStr);
//				vExchangeRateDate = Date(Left(vDateStr, 4), Mid(vDateStr, 5, 2), Mid(vDateStr, 7, 2));
//			EndIf;
//			vFactor = Number(ExtractWord(vStr));
//			vRate = Number(ExtractWord(vStr));
//
//			If vExchangeRateDate > BegOfDay(PeriodTo) Тогда
//				Break;
//			EndIf;
//
//			If vExchangeRateDate < BegOfDay(PeriodFrom) Тогда
//			   Continue;
//			EndIf;
//
//            vCurrencyRatesMgr.Гостиница = Гостиница;
//            vCurrencyRatesMgr.Валюта = vCurCurrency;
//			vCurrencyRatesMgr.Period = vExchangeRateDate;
//			vCurrencyRatesMgr.Read();
//			
//            vCurrencyRatesMgr.Гостиница = Гостиница;
//            vCurrencyRatesMgr.Валюта = vCurCurrency;
//			vCurrencyRatesMgr.Period = vExchangeRateDate;
//			vCurrencyRatesMgr.Rate = vRate;
//			vCurrencyRatesMgr.Factor = vFactor;
//			
//			If vLastCurrencyRates.Count() > 0 Тогда
//				vLastCurrencyRatesRow = vLastCurrencyRates.Get(0);
//				vCurrencyRatesMgr.BonusRate = vLastCurrencyRatesRow.BonusRate;
//			EndIf;
//			
//			vCurrencyRatesMgr.Write();
//		EndDo;
//			
//		// Log current state
//		vMessage = NStr("ru = 'Загружены курсы для валюты " + TrimAll(vCurCurrency) + "'; 
//		                |de = 'Exchange rates for " + TrimAll(vCurCurrency) + " Валюта were loaded'; 
//		                |en = 'Exchange rates for " + TrimAll(vCurCurrency) + " Валюта were loaded'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Information, ThisObject.Metadata(), vCurCurrency, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Information);
//		EndIf;
//	EndDo;	
//	
//	DeleteFiles(vTmpDir, "*.*");
//КонецПроцедуры //pmLoadCurrencyRatesFromRBC
//
////-----------------------------------------------------------------------------
//Процедура pmLoadCurrencyRatesFromBNM(pIsInteractive) Экспорт
//	Перем vHTTP;
//	
//	vCurrencyRatesMgr = InformationRegisters.КурсВалют.CreateRecordManager();
//	
//	vSourceCite = "www.bnm.md/";
//	
//	vAddress = "";
//	vPresPeriod = "";
//	
//	vCurrPeriod = PeriodFrom;
//	
//	While  BegOfDay(vCurrPeriod) <= BegOfDay(PeriodTo) Do
//		vAddress = "md/official_exchange_rates?get_xml=1&date=";
//		vPresPeriod = TrimAll(Format(vCurrPeriod,"ДФ=dd.MM.yyyy"));
//		
//		vTmpDir = TempFilesDir() + "LoadRates";
//		CreateDirectory(vTmpDir);
//		DeleteFiles(vTmpDir, "*.*");
//		
//		vRcvFileName = "" + vTmpDir + "\" + "courses_" + StrReplace(vPresPeriod,".","_") + ".xml";
//		vRcvFileAddress = vAddress + vPresPeriod;
//		
//		Try
//			vProxyServer = cmGetInternetProxy(InternetConnectionSettings, False, vSourceCite);
//			If vProxyServer = Неопределено Тогда
//				vHTTP = New HTTPConnection(vSourceCite);
//			Else
//				vHTTP = New HTTPConnection(vSourceCite, , , , vProxyServer);
//			EndIf;
//			vHTTP.Get(New HTTPRequest(vRcvFileAddress), vRcvFileName);
//		Except
//			vMessage = NStr("ru = 'Не удалось получить ресурс! Курсы для валют на дату "+vPresPeriod+" не загружен.'; 
//			|de = 'Failed to receive data on date "+vPresPeriod+". Валюта rates were not loaded.'; 
//			|en = 'Failed to receive data on date "+vPresPeriod+". Валюта rates were not loaded.'");
//			WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Warning, ThisObject.Metadata(), , vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//				vCurrPeriod = vCurrPeriod+86400;
//				Continue;
//			Else
//				ВызватьИсключение vMessage;
//			EndIf;
//		EndTry; 
//		
//		
//		vRcvFile = New File(vRcvFileName);
//		If НЕ vRcvFile.Exist() Or vRcvFile.Size()=0 Тогда
//			vMessage = NStr("ru = 'Не удалось получить ресурс! Курсы для валют на дату "+vPresPeriod+" не загружен.'; 
//			|de = 'Failed to receive data on date "+vPresPeriod+". Валюта rates were not loaded.'; 
//			|en = 'Failed to receive data on date "+vPresPeriod+". Валюта rates were not loaded.'");
//			WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Warning, ThisObject.Metadata(), , vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//				vCurrPeriod = vCurrPeriod+86400;
//				Continue;
//			Else
//				ВызватьИсключение vMessage;
//			EndIf;
//		EndIf;
//		
//		vListCurr = new ValueTable;
//		vListCurr.Columns.Add("Code");
//		vListCurr.Columns.Add("Валюта");
//		
//		For Each vCurrencyRow In Currencies Do
//			vStr = vListCurr.Add();
//			vStr.Code = vCurrencyRow.Currency.Code;
//			vStr.Валюта = vCurrencyRow.Currency; 
//		EndDo; 
//		
//		
//		vXMLReader = New XMLReader;
//		vXMLReader.OpenFile(vRcvFileName);
//		
//		While vXMLReader.Read() Do
//			If vXMLReader.NodeType = XMLNodeType.EndElement Тогда
//				Continue;;
//			EndIf;; 
//			
//			vNodeName = vXMLReader.LocalName;
//			
//			If vNodeName = "Valute" Тогда
//				
//				vCurCode = "";
//				vCurName = "";
//				vCurFullName = "";
//				vFactor = 0;
//				vRate = 0;
//				
//				While vXMLReader.Read() Do
//					If vXMLReader.NodeType = XMLNodeType.EndElement Тогда
//						Continue;
//					EndIf; 
//					
//					vNodeName = vXMLReader.LocalName;
//					
//					If vNodeName = "NumCode" Тогда
//						vXMLReader.Read();
//						
//						vCurCode = String(vXMLReader.Value);
//					ElsIf  vNodeName = "CharCode" Тогда
//						vXMLReader.Read();
//						
//						vCurName = String(vXMLReader.Value);
//					ElsIf  vNodeName = "Name" Тогда
//						vXMLReader.Read();
//						
//						vCurFullName = String(vXMLReader.Value);
//					ElsIf  vNodeName = "Nominal" Тогда
//						vXMLReader.Read();
//						
//						vFactor = Число(vXMLReader.Value);
//					ElsIf  vNodeName = "Value" Тогда
//						vXMLReader.Read();
//						
//						vRate = Число(vXMLReader.Value);
//						Break;
//					EndIf; 
//				EndDo;
//				
//				vRowListCurr = vListCurr.Find(Number(vCurCode),"Code");
//				
//				If vRowListCurr <> Неопределено Тогда
//					If НЕ (vFactor * vRate) = 0 Тогда
//						
//						// Read currency rate for the start of the period to get bonus rate last used
//						vLastCurrencyRates = InformationRegisters.КурсВалют.SliceLast(vCurrPeriod, New Structure("Гостиница, Валюта", Гостиница, vRowListCurr.Валюта));
//						
//						vCurrencyRatesMgr.Гостиница = Гостиница;
//						vCurrencyRatesMgr.Валюта = vRowListCurr.Валюта;
//						vCurrencyRatesMgr.Period = vCurrPeriod;
//						vCurrencyRatesMgr.Read();
//						
//						vCurrencyRatesMgr.Гостиница = Гостиница;
//						vCurrencyRatesMgr.Валюта = vRowListCurr.Валюта;
//						vCurrencyRatesMgr.Period = vCurrPeriod;
//						vCurrencyRatesMgr.Rate = vRate;
//						vCurrencyRatesMgr.Factor = vFactor;
//						
//						If vLastCurrencyRates.Count() > 0 Тогда
//							vLastCurrencyRatesRow = vLastCurrencyRates.Get(0);
//							vCurrencyRatesMgr.BonusRate = vLastCurrencyRatesRow.BonusRate;
//						EndIf;
//						
//						vCurrencyRatesMgr.Write();
//					EndIf;
//				EndIf; 
//			EndIf; 
//		EndDo;
//		
//		vXMLReader.Close();
//		
//		//Log current state
//		vMessage = NStr("en = 'Exchange rates currency were loaded on date "+vPresPeriod+"'; ru = 'Курсы  валют загружены на "+vPresPeriod+"'; de = 'Exchange rates Валюта were loaded on date "+vPresPeriod+"'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Information, ThisObject.Metadata(), , vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Information);
//		EndIf;
//		
//		DeleteFiles(vTmpDir, "*.*");
//		
//		vCurrPeriod = vCurrPeriod+86400;
//	EndDo;
//
//КонецПроцедуры //pmLoadCurrencyRatesFromRBC
//
////-----------------------------------------------------------------------------
//Процедура pmLoadCurrencyRatesFrom1CKato(pIsInteractive) Экспорт
//	Перем vHTTP;
//	
//	vCurrencyRatesMgr = InformationRegisters.КурсВалют.CreateRecordManager();
//
//	vText = New TextDocument();
//
//	vSourceCite = "1c-kato.kg";
//
//	vAddress = "/kato/Валюта.php";
//	vParams = "";
//	If BegOfDay(PeriodFrom) = BegOfDay(PeriodTo) Тогда
//		vPeriod = "/" + Format(Year(PeriodTo),"NGS=; NG=0") + 
//		          "/" + Format(Month(PeriodTo), "ND=2; NFD=0; NLZ=") + 
//		          "/" + Format(Day(PeriodTo), "ND=2; NFD=0; NLZ=");
//		vParams = "&year="+Format(Year(PeriodTo),"NGS=; NG=0") + 
//		          "&month="+Format(Month(PeriodTo),"ND=2; NFD=0; NLZ=") + 
//				  "&day="+Format(Day(PeriodTo),"ND=2; NFD=0; NLZ=");
//	EndIf;
//
//	vTmpDir = TempFilesDir() + "LoadRates";
//	CreateDirectory(vTmpDir);
//	DeleteFiles(vTmpDir, "*.*");
//	
//	For Each vCurrencyRow In Currencies Do
//		vCurCurrency = vCurrencyRow.Currency;
//			
//		// Read currency rate for the start of the period to get bonus rate last used
//		vLastCurrencyRates = InformationRegisters.КурсВалют.SliceLast(PeriodFrom, New Structure("Гостиница, Валюта", Гостиница, vCurCurrency));
//		
//		vRcvFileName = "" + vTmpDir + "\" + FileName;
//		vRcvFileAddress = vAddress + "?Валюта=" + Right(vCurCurrency.Code, 3) + vParams;
//		
//		Try
//			vProxyServer = cmGetInternetProxy(InternetConnectionSettings, False, vSourceCite);
//			If vProxyServer = Неопределено Тогда
//				vHTTP = New HTTPConnection(vSourceCite);
//			Else
//				vHTTP = New HTTPConnection(vSourceCite, , , , vProxyServer);
//			EndIf;
//			vHTTP.Get(New HTTPRequest(vRcvFileAddress), vRcvFileName);
//		Except
//			vMessage = NStr("ru = 'Не удалось получить ресурс для валюты " + TrimAll(vCurCurrency.Description) + "! Курс для валюты не загружен.';
//			                |de = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'; 
//			                |en = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'");
//			WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Warning, ThisObject.Metadata(), vCurCurrency, vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//				Continue;
//			Else
//				ВызватьИсключение vMessage;
//			EndIf;
//		EndTry; 
//
//		vRcvFile = New File(vRcvFileName);
//		If НЕ vRcvFile.Exist() Тогда
//			vMessage = NStr("ru = 'Не удалось получить ресурс для валюты " + TrimAll(vCurCurrency.Description) + "! Курс для валюты не загружен.'; 
//			                |de = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'; 
//			                |en = 'Failed to receive data for the " + TrimAll(vCurCurrency.Description) + "! Валюта rates were not loaded.'");
//			WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Warning, ThisObject.Metadata(), vCurCurrency, vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//				Continue;
//			Else
//				ВызватьИсключение vMessage;
//			EndIf;
//		EndIf;
//
//		vText.Read(vRcvFileName, TextEncoding.ANSI);
//		vLineCount = vText.LineCount();
//		For i = 1 To vLineCount Do
//			vStr = vText.GetLine(i);
//			If (vStr = "") Or (Find(vStr, Chars.Tab) = 0) Тогда
//			   Continue;
//			EndIf;
//			vExchangeRateDate = Неопределено;
//			If BegOfDay(PeriodFrom) = BegOfDay(PeriodTo) Тогда
//				vExchangeRateDate = BegOfDay(PeriodTo);
//			Else 
//				vDateStr = ExtractWord(vStr);
//				vExchangeRateDate = Date(Left(vDateStr, 4), Mid(vDateStr, 5, 2), Mid(vDateStr, 7, 2));
//			EndIf;
//			vFactor = Number(ExtractWord(vStr));
//			vRate = Number(ExtractWord(vStr));
//			
//			If vRate <= 0 Or vFactor <= 0 Тогда
//			   Continue;
//			EndIf;
//
//			If vExchangeRateDate > BegOfDay(PeriodTo) Тогда
//				Break;
//			EndIf;
//
//			If vExchangeRateDate < BegOfDay(PeriodFrom) Тогда
//			   Continue;
//			EndIf;
//
//            vCurrencyRatesMgr.Гостиница = Гостиница;
//            vCurrencyRatesMgr.Валюта = vCurCurrency;
//			vCurrencyRatesMgr.Period = vExchangeRateDate;
//			vCurrencyRatesMgr.Read();
//			
//            vCurrencyRatesMgr.Гостиница = Гостиница;
//            vCurrencyRatesMgr.Валюта = vCurCurrency;
//			vCurrencyRatesMgr.Period = vExchangeRateDate;
//			vCurrencyRatesMgr.Rate = vRate;
//			vCurrencyRatesMgr.Factor = vFactor;
//			
//			If vLastCurrencyRates.Count() > 0 Тогда
//				vLastCurrencyRatesRow = vLastCurrencyRates.Get(0);
//				vCurrencyRatesMgr.BonusRate = vLastCurrencyRatesRow.BonusRate;
//			EndIf;
//			
//			vCurrencyRatesMgr.Write();
//		EndDo;
//			
//		// Log current state
//		vMessage = NStr("ru = 'Загружены курсы для валюты " + TrimAll(vCurCurrency) + "'; 
//		                |de = 'Exchange rates for " + TrimAll(vCurCurrency) + " Валюта were loaded'; 
//		                |en = 'Exchange rates for " + TrimAll(vCurCurrency) + " Валюта were loaded'");
//		WriteLogEvent(NStr("en='DataProcessor.LoadCurrencyRates';ru='Обработка.ЗагрузкаКурсовВалют';de='Обработка.ЗагрузкаКурсовВалют'"), EventLogLevel.Information, ThisObject.Metadata(), vCurCurrency, vMessage);
//		If pIsInteractive Тогда
//			Message(vMessage, MessageStatus.Information);
//		EndIf;
//	EndDo;	
//	
//	DeleteFiles(vTmpDir, "*.*");
//КонецПроцедуры //pmLoadCurrencyRatesFrom1CKato
//
////-----------------------------------------------------------------------------
//FileName = "КурсВалют.txt";
