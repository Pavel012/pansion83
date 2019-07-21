//-----------------------------------------------------------------------------
// Description: Runs data processor
// Parameters: Data processor catalog item, Parameter object, Is in interactive mode or not
// Return value: True if data processor object runs successfully, False if any exception was raised 
//-----------------------------------------------------------------------------
Function cmRunDataProcessor(pDataProcessor, pParameter = Неопределено, pIsInteractive = False) Экспорт
	Попытка
		// Initialize list of data processors to run
		vDPs = cmGetListOfDataProcessorsToRun(pDataProcessor);
		// Run each data processor from the list
		For Each vDPRow In vDPs Do
			// Check user rights to execute data processor
			If НЕ cmCheckUserRightsToExecuteDataProcessor(vDPRow.DataProcessor) Тогда
				ВызватьИсключение "У вас нет прав на запуск обработки:" + vDPRow.DataProcessor.Description + "!";
			EndIf;
			vDPObj = cmBuildDataProcessorObject(vDPRow.DataProcessor);
			If vDPObj <> Неопределено Тогда
				// Initialize data processor settings
				Попытка
					// Fill reference to the data processor catalog item
					vDPObj.DataProcessor = vDPRow.DataProcessor;
					// Load data processor catalog item attributes
					vDPObj.pmLoadDataProcessorAttributes(pParameter);
					// Run data processor
					vDPObj.pmRun(pParameter, pIsInteractive);
				Исключение
					vErrorDescription = ErrorDescription();
					#IF ThickClientOrdinaryApplication THEN
						vMessage = "Ошибка вызова метода pmRun обработки " + pDataProcessor.Description+ "! Описание ошибки:" +vErrorDescription;
						WriteLogEvent("Обработка.Выполнить", EventLogLevel.Warning, Metadata.Справочники.Обработки, pDataProcessor, vMessage);
						Message(vMessage, MessageStatus.Important);
						// Open data processor form
						If НЕ cmOpenDataProcessorForm(vDPRow.DataProcessor, pParameter) Тогда
							If pIsInteractive Тогда
								Return False;
							Else
								ВызватьИсключение NStr("en='Failed to open data processor object form!';ru='Не удалось открыть форму объекта обработки!';de='Das Formular des Bearbeitungsobjekts konnte nicht geöffnet werden!'");
							EndIf;
						EndIf;
					#ELSE
						ВызватьИсключение vErrorDescription;
					#ENDIF
				КонецПопытки
			EndIf;
		EndDo;
		Return True;
	Исключение
		vErrorDescription = ErrorDescription();
		vMessage = "Ошибка выполнения обработки " + pDataProcessor.Description+ "! Описание ошибки: " + vErrorDescription;
		WriteLogEvent("Обработка.Выполнить", EventLogLevel.Warning, Metadata.Справочники.Обработки, pDataProcessor, vMessage);
		Message(vMessage, MessageStatus.Attention);
		#IF CLIENT THEN
			If pIsInteractive Тогда
				Return False;
			Else
				ВызватьИсключение vErrorDescription;
			EndIf;
		#ELSE
			ВызватьИсключение vErrorDescription;
		#ENDIF
	КонецПопытки;
EndFunction //cmRunDataProcessor

#IF CLIENT THEN
	
//-----------------------------------------------------------------------------
// Description: Opens employees working time schedule form
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmOpenEmployeeWorkingTimeSchedule() Экспорт
	vFrm = InformationRegisters.EmployeeWorkingTimeSchedule.ПолучитьФорму("FillForm");
	If НЕ vFrm.IsOpen() Тогда
		vFrm.WindowAppearanceMode = WindowAppearanceModeVariant.Maximized;
	EndIf;
	vFrm.Open();
КонецПроцедуры //cmOpenEmployeeWorkingTimeSchedule
	
#ENDIF
