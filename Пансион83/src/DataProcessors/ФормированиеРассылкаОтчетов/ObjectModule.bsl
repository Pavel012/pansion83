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
//	pmRunAndSendReports(pIsInteractive);
//КонецПроцедуры //pmRun
//
////-----------------------------------------------------------------------------
//// Data processors framework end
////-----------------------------------------------------------------------------
//	
////-----------------------------------------------------------------------------
//Процедура pmRunAndSendReports(pIsInteractive = False) Экспорт
//	WriteLogEvent(NStr("en='DataProcessor.RunAndSendReports';ru='Обработка.ФормированиеИРассылкаОтчетов';de='DataProcessor.RunAndSendReports'"), EventLogLevel.Information, Неопределено, Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
//	// Do for each report in settings
//	For Each vReportsRow In ReportsList Do
//		Try
//			If vReportsRow.IsActive Тогда
//				// Create report object
//				vReportObj = cmBuildReportObject(vReportsRow.Report);
//				vReportObj.Report = vReportsRow.Report;
//				vReportObj.pmLoadReportAttributes();
//				vReportObj.Гостиница = Гостиница;
//				
//				// Create spreadsheet
//				vSpreadsheet = New SpreadsheetDocument();
//				
//				// Set report builder attributes
//				Try
//					cmSetReportBuilderAttributes(vReportObj, cmGetReportBuilderAttributesStructure());
//				Except
//				EndTry;
//				
//				// Fill spreadsheet
//				vReportObj.pmGenerate(vSpreadsheet);
//				
//				// Setup default attributes
//				cmSetDefaultPrintFormSettings(vSpreadsheet, 
//				                              ?(vReportsRow.PageOrientation = Перечисления.PageOrientations.Landscape, PageOrientation.Landscape, PageOrientation.Portrait), 
//											  vReportsRow.FitToPage, 
//											  vReportsRow.Copies, 
//											  vReportsRow.BlackAndWhite);
//				
//				// Check authorities
//				cmSetSpreadsheetProtection(vSpreadsheet);
//				
//				// Fill settings
//				cmSetSpreadsheetSettings(vSpreadsheet, vReportsRow);
//				
//				// Check printing direction
//				vName = cmGetPrintFormFileName(vReportsRow);
//				
//				// Save report as file
//				If vReportsRow.PrintDirection <> Перечисления.PrintDirections.Screen Тогда
//					cmDoSpreadsheetOutput(vSpreadsheet, vReportsRow, vName);
//				Else
//					ВызватьИсключение NStr("en='Output report to screen is not supported at server!'; 
//					           |ru='Вывод отчета на экран на сервере не поддерживается!'; 
//							   |de='Ausgabe des Berichts auf dem Bildschirm wird auf dem Server nicht unterstützt!'");
//				EndIf;
//			EndIf;
//		Except
//			vMessage = ErrorDescription();
//			WriteLogEvent(NStr("en='DataProcessor.RunAndSendReports';ru='Обработка.ФормированиеИРассылкаОтчетов';de='DataProcessor.RunAndSendReports'"), EventLogLevel.Warning, Неопределено, Неопределено, vMessage);
//			If pIsInteractive Тогда
//				Message(vMessage, MessageStatus.Attention);
//			EndIf;
//		EndTry;
//	EndDo;
//	WriteLogEvent(NStr("en='DataProcessor.RunAndSendReports';ru='Обработка.ФормированиеИРассылкаОтчетов';de='DataProcessor.RunAndSendReports'"), EventLogLevel.Information, Неопределено, Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
//КонецПроцедуры //pmRunAndSendReports
