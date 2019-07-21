Перем глВинShell Экспорт; // Объект Wscript.Shell com-объекта переменной. Используется для автоматического закрытия окна сообщения и отключение системы в случае необходимости
Перем глЛичныеОбъекты Экспорт; // Это структура с произвольными элементами, которые могут быть добавлены любые другие программисты для собственных нужд
Перем глКопировать Экспорт; // Эта структура для хранения копировать/вставить значения, используемые в программе
Перем глИдентКартСистемДрайвер Экспорт; // Это объект процессора данных драйвера идентификационных карт клиента
Перем глСчитывательМК Экспорт; // Это Scaner1C.dll компонент COM для работы с считывателями магнитных карт (MC) и сканерами штрих-кодов
Перем глЛенточныйПринтер Экспорт; // Это логический флаг, указывающий, что надстройка ленточного принтера уже загружена
Перем глСканерКодов Экспорт; //Это объект обработчика данных драйвера сканера штрих-кодов
Перем глСканерИзобр Экспорт; // Это COM-компонент, используемый для сканирования и распознавания документов, удостоверяющих личность клиента
Перем глСканерИзобрИнтерф Экспорт; // Это компонент COM-интерфейс, используемый в когнитивной scanify API-интерфейс
Перем глСканерИзобрДрайвер Экспорт; // Это изображения сканера 
Перем глАтрибутГруппыРазршОдинНомер Экспорт; // Это атрибут группы разрешение рисовал один номер
Перем глПропускИдентКарт Экспорт; //Этот флаг указывает на то, что программа делает работу с клиентом удостоверения личности и не должны обрабатывать события в других формах

//-----------------------------------------------------------------------------
Процедура ПриНачалеРаботыСистемы()
	
	слФрмРазмИзм = Неопределено;
	Если НЕ глОбновлениеБазы(слФрмРазмИзм) Тогда
		ЗавершитьРаботуСистемы(Ложь); 
		Возврат;
	КонецЕсли;
	
	// Инициализировать таблицу с последнего посещения объектов
	слТабПослВизитОбъект();
	
	// Initialize connection to the MC reader
	глСчитывательМК = Неопределено;
	Если ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) И 
	   ПараметрыСеанса.РабочееМесто.ПодклСистемКартИдентф И 
	   ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.ПарамПодклСистемКартКлиентов) Тогда
		глИдентКартСистемДрайвер = мИдентКартСистемОбработка();
		Если глИдентКартСистемДрайвер <> Неопределено И 
		   ЗначениеЗаполнено(глИдентКартСистемДрайвер.IdentityCardSystemParameters) И  
		    глИдентКартСистемДрайвер.IdentityCardSystemParameters.CardReaderType = Перечисления.CardReaderTypes.IronLogicZ2 Тогда
			Status("Подключение к считывателю карт...");
			глСчитывательМК = глИдентКартСистемДрайвер.pmConnect();
			Если глСчитывательМК = Неопределено Тогда
				слОписаниеОшибки = "";
				слКодОшибки = глИдентКартСистемДрайвер.pmGetLastError(слОписаниеОшибки);
				Сообщить("Ошибка подключения считывателя! Код ошибки: " + слКодОшибки + ". Описание ошибки: " + слОписаниеОшибки, СтатусСообщения.Внимание);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	// Initialize connection to the barcodes scanner
	Если ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) И 
	   ПараметрыСеанса.РабочееМесто.HasConnectionToBarcodesScanner И 
	   ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.СканерПараметры) Тогда
		глСканерКодов = cmGetBarcodesScannerDriverDataProcessor();
		Если глСканерКодов <> Неопределено Тогда
			Status("Подключение к сканеру штрихкодов...");
			vScanner = глСканерКодов.pmConnect(глСчитывательМК);
			Если vScanner = Неопределено Тогда
				слЗакрСообщение = Ложь;
				слОписаниеОшибки = "";
				слКодОшибки = глСканерКодов.pmGetLastError(слОписаниеОшибки);
				Сообщить("Ошибка подключения сканера штрихкодов! Код ошибки: " + слКодОшибки + ". Описание ошибки: " + 
						слОписаниеОшибки, MessageStatus.Attention);
			Иначе
				Если глСчитывательМК = Неопределено Тогда
					глСчитывательМК = vScanner;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	// Initialize image scanner driver
	Если ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) И 
	   ПараметрыСеанса.РабочееМесто.HasConnectionToImagesScanner И 
	   ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.ImagesScannerConnectionParameters) Тогда
		глСканерИзобрДрайвер = cmGetImagesScannerDriverDataProcessor();
	КонецЕсли;
	
	// Initialize Simple Calls driver
	//Если ЗначениеЗаполнено(ПараметрыСеанса.CurrentWorkstation) И 
	//   ПараметрыСеанса.CurrentWorkstation.HasConnectionToSimpleCalls И 
	//    НЕ ПараметрыСеанса.CurrentWorkstation.WorkStationAlreadyRun Тогда
	//	
	//	tcSimpleCallsOnClient.ConnectComponents();
	//	
	//	Если НЕ amSimpleCallsComponent = Неопределено И amSimpleCallsComponent.connectionState=1 Тогда
	//		vWorkStation = ПараметрыСеанса.CurrentWorkstation.GetObject();
	//		vWorkStation.WorkStationAlreadyRun = Истина;
	//		vWorkStation.Write();
	//	КонецЕсли;
	//КонецЕсли;
	
	// Initialize settings used to draw gui forms
	глАтрибутГруппыРазршОдинНомер = Ложь;
	vPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
	Если ЗначениеЗаполнено(vPermissionGroup) Тогда
		глАтрибутГруппыРазршОдинНомер = vPermissionGroup.DoNotHideOneRoomGuestsAttributes;
	КонецЕсли;
	
	// Open main menu
	Status("Инициализация главного меню...");
	vMainMenu = Неопределено;
		Если vMainMenu = Неопределено Тогда
		vCurUser = InfoBaseUsers.CurrentUser();
		Если vCurUser.DefaultInterface = Неопределено Тогда
			vMainMenu = ПолучитьОбщуюФорму("ГлавноеМеню");
		Иначе
			vMainMenu = ПолучитьОбщуюФорму("ГлавноеМеню");
		КонецЕсли;
		vMainMenu.Open();
	КонецЕсли;
	глЛичныеОбъекты.Вставить("MainMenuForm", vMainMenu);
	глЛичныеОбъекты.Вставить("OpenForms", Новый СписокЗначений());
	
		
		
	// Show success status
	Status("Программа успешно запущена!");
КонецПроцедуры //OnStart

//-----------------------------------------------------------------------------
Процедура ПередНачаломРаботыСистемы(pCancel)
	// Current workstation
	vCurComputer = ComputerName();
	vCurComputerRef = Справочники.РабочиеМеста.FindByCode(vCurComputer);
	// Если this is a new workstation then create it in the database
	Если НЕ ЗначениеЗаполнено(vCurComputerRef) Тогда
		vNewWstn = Справочники.РабочиеМеста.СоздатьЭлемент();
		vNewWstn.Code = vCurComputer;
		vSysInfo = Новый SystemInfo();
		vNewWstn.СистемИнфо = "Processor: " + vSysInfo.Processor + "; RAM: " + vSysInfo.RAM + "Mb; OS Version: " + vSysInfo.OSVersion;
		vNewWstn.Write();
		vCurComputerRef = vNewWstn.Ref;
		vMessage = "Зарегистрировано новое рабочее место <" + СокрЛП(vCurComputerRef.Code) + ">! Необходимо установить его параметры. "; 
		WriteLogEvent("Программа.Запуск", EventLogLevel.Information, vCurComputerRef.Metadata(), vCurComputerRef, NStr(vMessage));
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			cmSendMessageToEmployee(ПараметрыСеанса.ТекПользователь, NStr(vMessage));
		КонецЕсли;
	КонецЕсли;
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vEmployeeNonReplicatingAttributes = ПараметрыСеанса.ТекПользователь.GetObject().pmGetNonReplicatingAttributes();
		Если vEmployeeNonReplicatingAttributes.Count() > 0 И 
		   ЗначениеЗаполнено(vEmployeeNonReplicatingAttributes.Get(0).РабочееМесто) Тогда
			ПараметрыСеанса.РабочееМесто = vEmployeeNonReplicatingAttributes.Get(0).РабочееМесто;
		ИначеЕсли vEmployeeNonReplicatingAttributes.Count() = 0 И ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.РабочееМесто) Тогда
			ПараметрыСеанса.РабочееМесто = ПараметрыСеанса.ТекПользователь.РабочееМесто;
		ИначеЕсли cmCheckUserPermissions("HavePermissionToChooseWorkstationOnProgramStartUp") Тогда
			vWstns = cmGetWorkstationsList(Истина);
			vWstnItem = vWstns.ChooseItem("Выберите рабочее место...", vCurComputerRef);
			Если vWstnItem = Неопределено Тогда
				ПараметрыСеанса.РабочееМесто = vCurComputerRef;
			Иначе
				ПараметрыСеанса.РабочееМесто = vWstnItem.Value;
			КонецЕсли;
		Иначе
			ПараметрыСеанса.РабочееМесто = vCurComputerRef;
		КонецЕсли;
	Иначе
		ПараметрыСеанса.РабочееМесто = vCurComputerRef;
	КонецЕсли;
	// Load windows scripting host shell
	Попытка
		глВинShell = Новый COMObject("WScript.Shell");
	Исключение
		WriteLogEvent("Программа.Запуск", EventLogLevel.Note, vCurComputerRef.Metadata(), vCurComputerRef, ErrorDescription());
		глВинShell = Неопределено;
	КонецПопытки;
КонецПроцедуры //BeforeStart

//-----------------------------------------------------------------------------
Процедура ПередЗавершениемРаботыСистемы(Отмена)
	// Program exit confirmation only if program exits normally 
	// (not because of protection system command)
	vProtectionIsOn = Истина;
	Если vProtectionIsOn Тогда
		vEmployee = ПараметрыСеанса.ТекПользователь;
		Если ЗначениеЗаполнено(vEmployee) Тогда
			Если ЗначениеЗаполнено(vEmployee.НастройкиПользователя) Тогда
				Если vEmployee.НастройкиПользователя.AskForProgramExitConfirmation Тогда
					Если DoQueryBox("Завершить работу с программой?", QuestionDialogMode.YesNo, 60, DialogReturnCode.Yes) = DialogReturnCode.No Тогда
						Отмена = Истина;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //BeforeExit

//-----------------------------------------------------------------------------
Процедура ПриЗавершенииРаботыСистемы()
	// Close TrPosX connection
	Если ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто)  И 
	   ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.ПараметрыПроцессинга) И
	   (ПараметрыСеанса.РабочееМесто.ПараметрыПроцессинга.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.TrPosPOSTerminalsDriver Or 
	    ПараметрыСеанса.РабочееМесто.ПараметрыПроцессинга.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.INPASPulsarSystemDriver Or 
	    ПараметрыСеанса.РабочееМесто.ПараметрыПроцессинга.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.INPASSmartConnectorDriver Or 
	    ПараметрыСеанса.РабочееМесто.ПараметрыПроцессинга.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.SberbankSBRFCOMSystemDriver Or 
	    ПараметрыСеанса.РабочееМесто.ПараметрыПроцессинга.CreditCardsProcessingSystemType = Перечисления.CreditCardsProcessingSystems.UCSSystemDriver) Тогда
		vPayCardProcessor = cmGetPayCardDataProcessor(ПараметрыСеанса.РабочееМесто.ПараметрыПроцессинга);
		vPayCardProcessor.pmDisconnect();
	КонецЕсли;
	// Close reader MC connection
	Если глИдентКартСистемДрайвер <> Неопределено Тогда
		глИдентКартСистемДрайвер.pmDisconnect(глСчитывательМК);
		глИдентКартСистемДрайвер = Неопределено;
	КонецЕсли;
	// Close barcodes scanner connection
	Если глСканерКодов <> Неопределено Тогда
		глСканерКодов.pmDisconnect(глСчитывательМК);
		глСканерКодов = Неопределено;
	КонецЕсли;
	глСчитывательМК = Неопределено;
	// Close image scanner connection
	Если глСканерИзобрДрайвер <> Неопределено Тогда
		глСканерИзобрДрайвер.pmDisconnect(глСканерИзобр, глСканерИзобрИнтерф);
		глСканерИзобрДрайвер = Неопределено;
	КонецЕсли;
	глСканерИзобр = Неопределено;
	глСканерИзобрИнтерф = Неопределено;
	// Shutdown protection system
	//Protection.cmShutdown();
	// Log off Windows if necessary
	Если cmCheckUserPermissions("LogOffAfterProgramExit") Тогда
		amLogOffWindows();
	КонецЕсли;
	// Release windows scripting host shell object
	глВинShell = Неопределено;
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) И 
	   ПараметрыСеанса.РабочееМесто.HasConnectionToSimpleCalls И 
	    ПараметрыСеанса.РабочееМесто.WorkStationAlreadyRun Тогда
		//tcSimpleCallsOnClient.Disconnect();
		vWorkStation = ПараметрыСеанса.РабочееМесто.GetObject();
		vWorkStation.WorkStationAlreadyRun = Ложь;
		vWorkStation.Write();
	КонецЕсли;

КонецПроцедуры //OnExit

//-----------------------------------------------------------------------------
// Description: Closes messages window using windows scripting host
//              Special keys are: "%" - alt, "+" - Shift, "^" - Ctrl
//-----------------------------------------------------------------------------
Процедура amCloseMessages() Экспорт
	Если глВинShell <> Неопределено Тогда
		Попытка
			// Посылка Ctrl+Shift+Z комбинации клавиш
		    глВинShell.SendKeys("^+Z");
		Исключение
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры //закрыть окно

//-----------------------------------------------------------------------------
// Description: Closes all windows using windows scripting host
//              Special keys are: "%" - alt, "+" - Shift, "^" - Ctrl
//-----------------------------------------------------------------------------
Процедура amCloseAllWindows() Экспорт
	Если глВинShell <> Неопределено Тогда
		Попытка
			// Посылка Alt+О комбинации и  когда С
		    глВинShell.SendKeys("%+О");
		    глВинShell.SendKeys("С");
		Исключение
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры //закрыть все окна

//-----------------------------------------------------------------------------
// Logs off current user from Windows
//-----------------------------------------------------------------------------
Процедура amLogOffWindows()
	Если глВинShell <> Неопределено Тогда
		Попытка
			// вызов командной оболочки на выкл станции "shutdown -l -f"
		    глВинShell.Exec("shutdown -l -f");
		Исключение
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры //amLogOffWindows

//-----------------------------------------------------------------------------
Процедура слТабПослВизитОбъект()
	лПослВизит = Новый ТаблицаЗначений;
	лПослВизит.Columns.Add("Period", cmGetDateTimeTypeDescription());
	лПослВизит.Columns.Add("LastVisitedObject", cmGetObjectsTypeDescription());
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		// Попытка to read it from the employee
		vEmpLastVisited = ПараметрыСеанса.ТекПользователь.ПослИсполОбъекты.Get();
		Если vEmpLastVisited <> Неопределено Тогда
			// Use cycle to fill value table because value table columns set and 
			// format could change in future
			Для Каждого vEmpLastVisitedRow Из vEmpLastVisited Цикл
				vLastVisitedRow = лПослВизит.Add();
				FillPropertyValues(vLastVisitedRow, vEmpLastVisitedRow);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	глЛичныеОбъекты.Вставить("ПослИсполОбъекты", лПослВизит);
КонецПроцедуры //слТабПослВизитОбъект

//-----------------------------------------------------------------------------
Процедура ExternEventProcessing(pSource, pEvent, pData)
	Если pSource = "MagneticStripeCardReader" Or cmIsRFIDReaderExternalEvent(pSource) Тогда
		Если pEvent = "MagneticStripeCardValue" Or cmIsRFIDReaderExternalEvent(pEvent) Тогда
			Если глСчитывательМК <> Неопределено Тогда
				// Delete event
				глСчитывательМК.DeleteEvent();
				глСчитывательМК.DataEventEnabled = 1;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Если pSource = "BarCodeScaner" Тогда
		Если pEvent = "BarCodeValue" Тогда
			Если глСчитывательМК <> Неопределено Тогда
				vValue = глСчитывательМК.ScanData;
				
				// Delete event
				глСчитывательМК.DeleteEvent();
				глСчитывательМК.DataEventEnabled = 1;
				
				// Get Reservation
				Попытка
					vUUID = Новый UUID(СокрЛП(vValue));
				Исключение
					Возврат;
				КонецПопытки;
				vReservation = Documents.Бронирование.GetRef(vUUID);
				Если НЕ ЗначениеЗаполнено(vReservation) Тогда
					Предупреждение("Гости не найдены");
					Возврат;
				КонецЕсли;
				
				//Get Expected Check-In form
				vFrm = ПолучитьФорму("CommonForm.упрЭкспрессЗаезд", Новый Structure("Key", vReservation));
				Если vFrm <> Неопределено Тогда
					Если vFrm.IsOpen() Тогда
						vFrm.Close();
						vFrm = ПолучитьФорму("CommonForm.упрЭкспрессЗаезд", Новый Structure("Key", vReservation));
					КонецЕсли;
					vFrm.Open();
				Иначе
					Если vReservation.ReservationStatus.ЭтоЗаезд Тогда
						Предупреждение("Клиент уже заехал.");
					ИначеЕсли vReservation.ReservationStatus.IsAnnulation Тогда
						Предупреждение("Бронь была аннулирована");
					ИначеЕсли BegOfDay(vReservation.CheckInDate) <> BegOfDay(ТекущаяДата()) Тогда
						Предупреждение("Дата заезда не совпадает с текущей датой");
					Иначе
						Предупреждение("Неизвестная ошибка! Проверьте бронь.");
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //ExternEventProcessing
 
//-----------------------------------------------------------------------------
глВинShell = Неопределено;
глЛичныеОбъекты = Новый Структура;
глКопировать = Новый Структура;
глЛенточныйПринтер = Ложь;
глСканерИзобр = Неопределено;
глСканерИзобрИнтерф = Неопределено;
глПропускИдентКарт = Ложь;