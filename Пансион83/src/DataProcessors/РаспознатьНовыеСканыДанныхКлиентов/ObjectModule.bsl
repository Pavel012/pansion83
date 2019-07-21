////-----------------------------------------------------------------------------
//// Data processors framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//
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
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//// Run data processor in silent mode
////-----------------------------------------------------------------------------
//Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
//	// Process finished resource reservations
//	pmRecognize(pIsInteractive);
//КонецПроцедуры //pmRun
//
////-----------------------------------------------------------------------------
//// Data processors framework end
////-----------------------------------------------------------------------------
//	
////-----------------------------------------------------------------------------
//Процедура pmRecognize(pIsInteractive = False) Экспорт
//	WriteLogEvent(NStr("en='DataProcessor.RecognizeNewClientDataScans';ru='Обработка.РаспознаваниеНовыхСкановДанныхКлиентов';de='DataProcessor.RecognizeNewClientDataScans'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
//	// Check parameters
//	WriteLogEvent(NStr("en='DataProcessor.RecognizeNewClientDataScans';ru='Обработка.РаспознаваниеНовыхСкановДанныхКлиентов';de='DataProcessor.RecognizeNewClientDataScans'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Гостиница: ';ru='Гостиница: ';de='Гостиница: '") + TrimAll(Гостиница));
//	// Get driver data processor object
//	//vDriverObj = cmGetImagesScannerDriverDataProcessor();
//	vScI = Неопределено;
//	rMessage = "";
//	vScObj = vDriverObj.pmConnect(rMessage, vScI);
//	If vScObj = Неопределено Тогда
//		ВызватьИсключение rMessage;
//	EndIf;
//	// Get list of new documents
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ДанныеКлиента.Ref AS Ref
//	|FROM
//	|	Document.ДанныеКлиента AS ДанныеКлиента
//	|WHERE
//	|	ДанныеКлиента.Posted
//	|	AND ДанныеКлиента.Status = &qЭтоНовый
//	|	AND (ДанныеКлиента.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|
//	|ORDER BY
//	|	ДанныеКлиента.PointInTime";
//	vQry.SetParameter("qЭтоНовый", Перечисления.ScanStatuses.ЭтоНовый);
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	vDocs = vQry.Execute().Unload();
//	// Do recognition for each document found
//	For Each vDocsRow In vDocs Do
//		Try
//			rMessage = "";
//			// Get document object
//			vDocObj = vDocsRow.Ref.GetObject();
//			vDocObj.Status = Перечисления.ScanStatuses.IsRecognized;
//			If НЕ vDriverObj.pmRecognizeDocument(vDocObj, rMessage, vScObj, vScI) Тогда
//				ВызватьИсключение rMessage;
//			EndIf;
//			vDocObj.Write(DocumentWriteMode.Posting);
//			
//			// Log current state
//			vMessage = NStr("ru = 'Обработан документ: " + String(vDocObj.Ref) + " - группа № " + TrimAll(vDocObj.ГруппаГостей) + "'; 
//			                |de = 'Document " + String(vDocObj.Ref) + " - group N " + TrimAll(vDocObj.ГруппаГостей) + " was processed'; 
//			                |en = 'Document " + String(vDocObj.Ref) + " - group N " + TrimAll(vDocObj.ГруппаГостей) + " was processed'");
//			WriteLogEvent(NStr("en='DataProcessor.RecognizeNewClientDataScans';ru='Обработка.РаспознаваниеНовыхСкановДанныхКлиентов';de='DataProcessor.RecognizeNewClientDataScans'"), EventLogLevel.Information, ThisObject.Metadata(), vDocObj.Ref, vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Information);
//			Endif;
//		Except
//			vMessage = ErrorDescription();
//			WriteLogEvent(NStr("en='DataProcessor.RecognizeNewClientDataScans';ru='Обработка.РаспознаваниеНовыхСкановДанныхКлиентов';de='DataProcessor.RecognizeNewClientDataScans'"), EventLogLevel.Warning, ThisObject.Metadata(), ?(vDocObj = Неопределено, Неопределено, vDocObj.Ref), vMessage);
//			Try
//				If vDriverObj <> Неопределено And vScObj <> Неопределено Тогда
//					vDriverObj.pmDisconnect(vScObj, vScI);
//				EndIf;
//			Except
//			EndTry;
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndTry;
//	EndDo;
//	If vDriverObj <> Неопределено And vScObj <> Неопределено Тогда
//		vDriverObj.pmDisconnect(vScObj, vScI);
//	EndIf;
//	WriteLogEvent(NStr("en='DataProcessor.RecognizeNewClientDataScans';ru='Обработка.РаспознаваниеНовыхСкановДанныхКлиентов';de='DataProcessor.RecognizeNewClientDataScans'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
//КонецПроцедуры //pmRecognizeNewClientDataScans
