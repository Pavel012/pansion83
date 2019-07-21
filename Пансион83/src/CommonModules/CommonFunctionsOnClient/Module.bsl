//-----------------------------------------------------------------------------
// Description: Returns shortcut object based on shortcut text representation  
// Parameters: Text representation of the shortcut
// Возврат value: Shortcut object
//-----------------------------------------------------------------------------
Функция cmGetShortcutObject(Val pShortcutStr) Экспорт
	Если IsBlankString(pShortcutStr) Тогда
		Возврат Новый Shortcut(Key.None, Ложь, Ложь, Ложь);
	Иначе
	
		vAlt = Ложь;
		vAltPos = Find(pShortcutStr, "Alt+");
		Если vAltPos > 0 Тогда
			vAlt = Истина;
			pShortcutStr = StrReplace(pShortcutStr, "Alt+", "");
		КонецЕсли;
		// Ctrl
		vCtrl = Ложь;
		vCtrlPos = Find(pShortcutStr, "Ctrl+");
		Если vCtrlPos > 0 Тогда
			vCtrl = Истина;
			pShortcutStr = StrReplace(pShortcutStr, "Ctrl+", "");
		КонецЕсли;
		// Shift
		vShift = Ложь;
		vShiftPos = Find(pShortcutStr, "Shift+");
		Если vShiftPos > 0 Тогда
			vShift = Истина;
			pShortcutStr = StrReplace(pShortcutStr, "Shift+", "");
		КонецЕсли;
		// Key
		vKey = Key[pShortcutStr];
		// Shortcut object
		Возврат Новый Shortcut(vKey, vAlt, vCtrl, vShift);
	КонецЕсли;
EndFunction //cmGetShortcutObject 

//-----------------------------------------------------------------------------
// Description: Sets object form button captions, shortcuts and tooltips
// Parameters: Button control, Button action, Form action
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetButtonAttributes(pButton, pButtonAction, pFormAction) Экспорт
	Если pButtonAction = Неопределено Тогда
		pFormAction = Справочники.ObjectFormActions.EmptyRef();
		pButton.Enabled = Ложь;
		pButton.Visible = Ложь;
	Иначе
		pFormAction = pButtonAction.ObjectFormAction;
		pButton.Enabled = Истина;
		pButton.Visible = Истина;
		pButton.Caption = pButtonAction.ButtonCaption;
		pButton.ToolTip = pButtonAction.ButtonToolTip;
		pButton.Shortcut = cmGetShortcutObject(pButtonAction.ButtonShortcut);
		vIcon = pButtonAction.ObjectFormAction.ActionIcon.Get();
		Если vIcon = Неопределено Тогда
			pButton.Picture = Новый Picture;
		Иначе
			pButton.Picture = pButtonAction.ObjectFormAction.ActionIcon.Get();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmSetButtonAttributes

//-----------------------------------------------------------------------------
// Description: Shows open file dialog
// Parameters: Returns full file name of file being open
// Возврат value: Истина if file was choosen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmOpenFile(rFullFileName) Экспорт
	vFileOpen = Новый FileDialog(FileDialogMode.Open);
	vFileOpen.FullFileName = rFullFileName;
	vFileOpen.Filter = NStr("ru='Все файлы (*.*)|*.*|';
	                        |de='Alle Dateien (*.*)|*.*|';
	                        |en='All files (*.*)|*.*|'");
	vFileOpen.Multiselect = Ложь;
	vFileOpen.Title = NStr("en='Open file';ru='Выбрать файл';de='Datei wählen'");
	vFileOpen.Preview = Истина;
	Если vFileOpen.Choose() Тогда
		rFullFileName = vFileOpen.FullFileName;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
EndFunction //cmOpenFile

//-----------------------------------------------------------------------------
// Description: Shows open picture dialog
// Parameters: Returns full file name of picture being open
// Возврат value: Истина if picture was choosen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmOpenPicture(rFullFileName) Экспорт
	vFileOpen = Новый FileDialog(FileDialogMode.Open);
	vFileOpen.FullFileName = rFullFileName;
	vFileOpen.Filter = NStr("ru = 'Картинки (*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.tif;*.gif;*.png;*.ico;*.wmf;*.emf)|*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.tif;*.gif;*.png;*.ico;*.wmf;*.emf|" +
	                               "bmp (*.bmp;*.dib;*.rle)|*.bmp;*.dib;*.rle|" + 
	                               "JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg|" + 
	                               "TIFF (*.tif)|*.tif|" + 
	                               "GIF (*.gif)|*.gif|" + 
	                               "PNG (*.png)|*.png|" + 
	                               "icon (*.ico)|*.ico|" + 
	                               "метафайл (*.wmf;*.emf)|*.wmf;*.emf|'; 
	                        |de = 'Картинки (*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.tif;*.gif;*.png;*.ico;*.wmf;*.emf)|*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.tif;*.gif;*.png;*.ico;*.wmf;*.emf|" +
	                               "bmp (*.bmp;*.dib;*.rle)|*.bmp;*.dib;*.rle|" + 
	                               "JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg|" + 
	                               "TIFF (*.tif)|*.tif|" + 
	                               "GIF (*.gif)|*.gif|" + 
	                               "PNG (*.png)|*.png|" + 
	                               "icon (*.ico)|*.ico|" + 
	                               "метафайл (*.wmf;*.emf)|*.wmf;*.emf|'; 
	                        |en = 'Pictures (*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.tif;*.gif;*.png;*.ico;*.wmf;*.emf)|*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.tif;*.gif;*.png;*.ico;*.wmf;*.emf|" +
	                               "bmp (*.bmp;*.dib;*.rle)|*.bmp;*.dib;*.rle|" + 
	                               "JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg|" + 
	                               "TIFF (*.tif)|*.tif|" + 
	                               "GIF (*.gif)|*.gif|" + 
	                               "PNG (*.png)|*.png|" + 
	                               "icon (*.ico)|*.ico|" + 
	                               "metafile (*.wmf;*.emf)|*.wmf;*.emf|'");
	vFileOpen.Multiselect = Ложь;
	vFileOpen.Title = NStr("en='Load picture';ru='Загрузить картинку';de='Bild laden'");
	vFileOpen.Preview = Истина;
	Если vFileOpen.Choose() Тогда
		rFullFileName = vFileOpen.FullFileName;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
EndFunction //cmOpenPicture

//-----------------------------------------------------------------------------
// Description: Shows open mxl template file dialog
// Parameters: Returns full file name of mxl template file being open
// Возврат value: Истина if file was choosen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmOpenTemplate(rFullFileName) Экспорт
	vFileOpen = Новый FileDialog(FileDialogMode.Open);
	vFileOpen.FullFileName = rFullFileName;
	vFileOpen.Filter = NStr("ru = 'Макеты 1С (*.mxl)|*.mxl|'; en = '1C templates (*.mxl)|*.mxl|'; de = '1C templates (*.mxl)|*.mxl|'");
	vFileOpen.Multiselect = Ложь;
	vFileOpen.Title = NStr("en='Load template';ru='Загрузить макет';de='Design laden'");
	vFileOpen.Preview = Ложь;
	Если vFileOpen.Choose() Тогда
		rFullFileName = vFileOpen.FullFileName;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
EndFunction //cmOpenTemplate

//-----------------------------------------------------------------------------
// Description: Shows open external data processor file dialog
// Parameters: Returns full file name of data processor being open, Тип of external data processor
// Возврат value: Истина if file was choosen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmOpenExternalDataProcessorFile(rFullFileName, pExternalProcessingType = Неопределено) Экспорт
	vFileOpen = Новый FileDialog(FileDialogMode.Open);
	vFileOpen.FullFileName = rFullFileName;
	Если ЗначениеЗаполнено(pExternalProcessingType) Тогда
		Если pExternalProcessingType = Перечисления.ExternalProcessingTypes.DataProcessor Тогда
			vFileOpen.Filter = NStr("ru='Внешняя обработка (*.epf)|*.epf|';
			                        |de='Externe Bearbeitung (*.epf)|*.epf|';
			                        |en='External data processor (*.epf)|*.epf|'");
		ElsIf pExternalProcessingType = Перечисления.ExternalProcessingTypes.Report Тогда
			vFileOpen.Filter = NStr("ru='Внешний отчет (*.erf)|*.erf|';
			                        |de='Externer Bericht (*.erf)|*.erf|';
			                        |en='External report (*.erf)|*.erf|'");
		Иначе
			vFileOpen.Filter = NStr("ru='Любой файл (*.*)|*.*|';
			                        |de='Beliebige Date (*.*)|*.*|';
			                        |en='Any file (*.*)|*.*|'");
		КонецЕсли;
	Иначе
		vFileOpen.Filter = NStr("ru = 'Внешний отчет или обработка (*.erf;*.epf)|*.erf;*.epf|" +
		                              "Внешний отчет (*.erf)|*.erf|" + 
		                              "Внешняя обработка (*.epf)|*.epf|'; 
		                        |de = 'Внешний отчет или обработка (*.erf;*.epf)|*.erf;*.epf|" +
		                              "Внешний отчет (*.erf)|*.erf|" + 
		                              "Внешняя обработка (*.epf)|*.epf|'; 
								|en = 'External report or data processor (*.erf;*.epf)|*.erf;*.epf|" +
		                              "External report (*.erf)|*.erf|" + 
		                              "External data processor (*.epf)|*.epf|'");
	КонецЕсли;
	vFileOpen.Multiselect = Ложь;
	vFileOpen.Title = NStr("en='Load external data processor or report';de='Load external data processor or report';ru='Загрузить внешнюю обработку или отчет';de='Externe Bearbeitung oder Bericht laden'");
	vFileOpen.Preview = Ложь;
	Если vFileOpen.Choose() Тогда
		rFullFileName = vFileOpen.FullFileName;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
EndFunction //cmOpenExternalDataProcessorFile

//-----------------------------------------------------------------------------
// Description: Shows choose directory dialog
// Parameters: Returns full directory name being choosen
// Возврат value: Истина if directory was choosen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmChooseDirectory(rDirectoryName) Экспорт
	vFileOpen = Новый FileDialog(FileDialogMode.ChooseDirectory);
	vFileOpen.Directory = rDirectoryName;
	vFileOpen.Multiselect = Ложь;
	vFileOpen.Title = NStr("en='Choose directory';ru='Выбрать папку';de='Ordner auswählen'");
	vFileOpen.Preview = Ложь;
	Если vFileOpen.Choose() Тогда
		rDirectoryName = vFileOpen.Directory;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
EndFunction //cmChooseDirectory

//-----------------------------------------------------------------------------
// Description: Shows choose file name dialog
// Parameters: Returns full file name being choosen
// Возврат value: Истина if directory was choosen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmSaveXMLFile(rFileName) Экспорт
	vFileSave = Новый FileDialog(FileDialogMode.Save);
	vFileSave.Filter = "XML (*.xml)|*.xml";
	vFileSave.DefaultExt = "xml";
	vFileSave.FullFileName = rFileName;
	vFileSave.Multiselect = Ложь;
	vFileSave.Title = NStr("en='Choose file name and directory';ru='Укажите имя файла и путь';de='Geben Sie Namen und Pfad der Datei an'");
	vFileSave.Preview = Ложь;
	Если vFileSave.Choose() Тогда
		rFileName = vFileSave.FullFileName;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
EndFunction //cmSaveXMLFile

//-----------------------------------------------------------------------------
// Description: Shows choose file name dialog
// Parameters: Returns full file name being choosen
// Возврат value: Истина if directory was choosen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmOpenXMLFile(rFileName) Экспорт
	vFileOpen = Новый FileDialog(FileDialogMode.Open);
	vFileOpen.Filter = "XML (*.xml)|*.xml";
	vFileOpen.Multiselect = Ложь;
	vFileOpen.Title = NStr("en='Choose file';ru='Выберите файл';de='Wählen Sie die Datei'");
	vFileOpen.Preview = Ложь;
	Если vFileOpen.Choose() Тогда
		rFileName = vFileOpen.FullFileName;
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
EndFunction //cmOpenXMLFile

//-----------------------------------------------------------------------------
// Description: Saves report static and dynamic settings and parameters to the XML file
// Parameters: Reports catalog item reference or object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSaveReportSettingsToFile(pRep) Экспорт
	vFileName = StrReplace(СокрЛП(pRep.Report), " ", "") + "_" + СокрЛП(pRep.Code);
	Если cmSaveXMLFile(vFileName) Тогда
		cmWriteReportSettingsToFile(pRep, vFileName);
		ShowMessageBox(Неопределено, NStr("en='Report settings are saved to file successfully!';ru='Настройки отчета успешено сохранены в файл!';de='Einstellungen des Berichts wurden erfolgreich in die Datei gespeichert!'"));
	КонецЕсли;
КонецПроцедуры //cmSaveReportSettingsToFile 

//-----------------------------------------------------------------------------
// Description: Load's report static and dynamic settings and parameters from the XML file
// Parameters: Reports catalog item object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmLoadReportSettingsFromFile(pRepObj) Экспорт
	vFileName = "";
	Если cmOpenXMLFile(vFileName) Тогда
		cmReadReportSettingsFromFile(pRepObj, vFileName);
		Предупреждение(NStr("en='Report settings are loaded from file successfully!';ru='Настройки отчета успешено загружены из файла!';de='Einstellungen des Berichts wurden erfolgreich aus der Datei geladen!'"));
	КонецЕсли;
КонецПроцедуры //cmLoadReportSettingsFromFile

//-----------------------------------------------------------------------------
// Description: Opens full text search form
// Parameters: Metadata to be searched name or value list of such metadata names,
//             String to be searched
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmOpenFullTextSearch(pMetadata, pSearchString = "") Экспорт
	vFrm = Обработки.FullTextSearch.ПолучитьФорму("Form", , "FullTextSearch");
	vFrm.LimitSearchArea = Истина;
	vFrm.SearchAreaList.Clear();
	Если TypeOf(pMetadata) = Тип("СписокЗначений") Тогда
		vFrm.SearchAreaList = pMetadata;
	Иначе
		vFrm.SearchAreaList.Add(pMetadata);
	КонецЕсли;
	vFrm.Open();
	// Check search string
	Если НЕ IsBlankString(pSearchString) Тогда
		vFrm.SearchString = pSearchString;
		vFrm.Search();
	КонецЕсли;
КонецПроцедуры //cmOpenFullTextSearch

//-----------------------------------------------------------------------------
// Description: Opens form with document child structure
// Parameters: Document to build child documents tree from 
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmShowDocumentTree(pDoc) Экспорт
	Если НЕ ЗначениеЗаполнено(pDoc) Тогда
		Возврат;
	КонецЕсли;
	vFrm = GetCommonForm("DocumentsTree");
	Если vFrm.IsOpen() Тогда
		vFrm.Close();
	КонецЕсли;
	vFrm.DocumentRef = pDoc;
	vFrm.Open();
КонецПроцедуры //cmShowDocumentTree

//-----------------------------------------------------------------------------
// Description: Opens form of the given document
// Parameters: Document reference
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmOpenDocumentForm(pDoc) Экспорт
	vFrm = pDoc.ПолучитьФорму();
	vFrm.Open();
КонецПроцедуры //cmOpenDocumentForm

//-----------------------------------------------------------------------------
// Description: Sets availability of "save as" button in the print form
// Parameters: Print form, Spreadsheet object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetSaveAsButtonsAppearance(pForm, pSpreadsheet) Экспорт
	Try
		Если pSpreadsheet.Protection Тогда
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Enabled = Ложь;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsPDF.Enabled = Ложь;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsMXL.Enabled = Ложь;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsXLS.Enabled = Ложь;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsHTML.Enabled = Ложь;
		Иначе
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Enabled = Истина;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsPDF.Enabled = Истина;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsMXL.Enabled = Истина;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsXLS.Enabled = Истина;
			pForm.ЭлементыФормы.FormActions.Buttons.ActionSaveAs.Buttons.ActionSaveAsHTML.Enabled = Истина;
		КонецЕсли;
	Except
	EndTry;
КонецПроцедуры //cmSetSaveAsButtonsAppearance 

//-----------------------------------------------------------------------------
// Description: This function is used to open new data processor item form
//              filled with parameters of data processor object currently open
// Parameters: Data processor object, Data processor form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSaveNewDataProcessorAttributesSetting(pDPObject, pDPForm) Экспорт
	vDPObj = Справочники.Обработки.CreateItem();
	vDPObj.Description = pDPObject.Metadata().Presentation();
	vDPObj.IsExternal = Ложь;
	vDPObj.Processing = pDPObject.Metadata().Name;
	Если ЗначениеЗаполнено(pDPObject.DataProcessor) Тогда
		vDPObj.Description = pDPObject.DataProcessor.Description;
		vDPObj.ПорядокСортировки = pDPObject.DataProcessor.ПорядокСортировки;
		vDPObj.Key = pDPObject.DataProcessor.Key;
		vDPObj.НаборПрав = pDPObject.DataProcessor.НаборПрав;
		vDPObj.Parent = pDPObject.DataProcessor.Parent;
		vDPObj.IsExternal = pDPObject.DataProcessor.IsExternal;
		Если vDPObj.IsExternal Тогда
			vDPObj.Processing = pDPObject.DataProcessor.Processing;
		КонецЕсли;
		vDPObj.DynamicParameters = pDPObject.DataProcessor.DynamicParameters;
	КонецЕсли;
	vDPObj.StaticParameters = cmGetDataProcessorStaticParametersValue(pDPObject);
	Если НЕ cmCheckUserPermissions("HavePermissionToRunAllDataProcessors") Тогда
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			vDPObj.НаборПрав = ПараметрыСеанса.ТекПользователь.НаборПрав;
		КонецЕсли;
	КонецЕсли;
	vFrm = vDPObj.ПолучитьФорму(, pDPForm);
	vFrm.Open();
КонецПроцедуры //cmSaveNewDataProcessorAttributesSetting

//-----------------------------------------------------------------------------
// Description: This function is used to open new report item form
//              filled with parameters of report object currently open
// Parameters: Report object, Report settings form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSaveNewReportAttributesSetting(pRepObject, pRepSettingsForm) Экспорт
	vRepObj = Справочники.Отчеты.CreateItem();
	vRepObj.Description = pRepObject.Metadata().Presentation();
	vRepObj.IsExternal = Ложь;
	vRepObj.Report = pRepObject.Metadata().Name;
	Если ЗначениеЗаполнено(pRepObject.Report) Тогда
		vRepObj.Description = pRepObject.Report.Description;
		vRepObj.ПорядокСортировки = pRepObject.Report.ПорядокСортировки;
		vRepObj.Key = pRepObject.Report.Key;
		vRepObj.НаборПрав = pRepObject.Report.НаборПрав;
		vRepObj.Parent = pRepObject.Report.Parent;
		vRepObj.IsExternal = pRepObject.Report.IsExternal;
		Если vRepObj.IsExternal Тогда
			vRepObj.Report = pRepObject.Report.Report;
		КонецЕсли;
		vRepObj.DynamicParameters = pRepObject.Report.DynamicParameters;
	КонецЕсли;
	vRepObj.StaticParameters = cmGetReportStaticParametersValue(pRepObject);
	Если НЕ cmCheckUserPermissions("HavePermissionToRunAllReports") Тогда
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			vRepObj.НаборПрав = ПараметрыСеанса.ТекПользователь.НаборПрав;
		КонецЕсли;
	КонецЕсли;
	vFrm = vRepObj.ПолучитьФорму(, pRepSettingsForm);
	vFrm.Open();
КонецПроцедуры //cmSaveNewReportAttributesSetting

//-----------------------------------------------------------------------------
// Description: This function is used to save current report settings to some existing
//              report setting
// Parameters: Report object, Report settings form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSaveAsReportAttributesSetting(pRepObject, pRepSettingsForm) Экспорт
	// Choose new report item
	vFrm = Справочники.Отчеты.GetChoiceForm();
	Если ЗначениеЗаполнено(pRepObject.Report) Тогда
		vFrm.SelPermissionGroup = pRepObject.Report.НаборПрав;
		vFrm.SelReport = pRepObject.Report.Report;
	Иначе
		Если НЕ cmCheckUserPermissions("HavePermissionToRunAllReports") Тогда
			Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
				vFrm.SelPermissionGroup = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	vReportItem = vFrm.DoModal();
	Если ЗначениеЗаполнено(vReportItem) Тогда
		// Set reference to the new report item
		pRepObject.Report = vReportItem;
		// Set settings form appearance
		pRepSettingsForm.fmCommandBarAttributesAppearance();
		// Save setings to the changed report item
		cmSaveReportAttributes(pRepObject);
	КонецЕсли;
КонецПроцедуры //cmSaveAsReportAttributesSetting

//-----------------------------------------------------------------------------
// Description: Applies rules to the "Send by e-mail" print form button appearance
// Parameters: Submenu object, Document reference
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSendByEmailSubmenuAppearance(pSendByEMail, pDoc) Экспорт
	pSendByEMail.Buttons.Clear();
	pSendByEMail.Enabled = Ложь;
	Если ЗначениеЗаполнено(pDoc) Тогда
		vDocumentEMail = "";
		vCustomerEMail = "";
		vContactPersonEMail = "";
		vGuestEMail = "";
		vDocument = Неопределено;
		vCustomer = Неопределено;
		vGuest = Неопределено;
		vContactPerson = "";
		Если TypeOf(pDoc) = Тип("DocumentRef.Бронирование") Or 
		   TypeOf(pDoc) = Тип("DocumentRef.Размещение") Тогда
			vDocument = pDoc;
			vDocumentEmail = СокрЛП(pDoc.EMail);
			vCustomer = pDoc.Контрагент;
			Если ЗначениеЗаполнено(pDoc.Контрагент) Тогда
				vCustomerEMail = СокрЛП(pDoc.Контрагент.EMail);
			КонецЕсли;
			Если ЗначениеЗаполнено(pDoc.Клиент) Тогда
				vGuest = pDoc.Клиент;
				vGuestEMail = СокрЛП(vGuest.EMail);
			КонецЕсли;
			Если НЕ IsBlankString(pDoc.КонтактноеЛицо) Тогда
				vContactPersonEMail = cmGetContactPersonEMail(pDoc.КонтактноеЛицо);
				vContactPerson = СокрЛП(pDoc.КонтактноеЛицо);
			КонецЕсли;				
		ElsIf TypeOf(pDoc) = Тип("DocumentRef.БроньУслуг") Тогда
			vDocument = pDoc;
			vDocumentEmail = СокрЛП(pDoc.EMail);
			vCustomer = pDoc.Контрагент;
			Если ЗначениеЗаполнено(pDoc.Контрагент) Тогда
				vCustomerEMail = СокрЛП(pDoc.Контрагент.EMail);
			КонецЕсли;
			Если ЗначениеЗаполнено(pDoc.Клиент) Тогда
				vGuest = pDoc.Клиент;
				vGuestEMail = СокрЛП(vGuest.EMail);
			КонецЕсли;
			Если НЕ IsBlankString(pDoc.КонтактноеЛицо) Тогда
				vContactPersonEMail = cmGetContactPersonEMail(pDoc.КонтактноеЛицо);
				vContactPerson = СокрЛП(pDoc.КонтактноеЛицо);
			КонецЕсли;				
		ElsIf TypeOf(pDoc) = Тип("DocumentRef.СчетНаОплату") Тогда
			vDocumentEmail = СокрЛП(pDoc.EMail);
			vCustomer = pDoc.Контрагент;
			Если ЗначениеЗаполнено(vCustomer) Тогда
				vCustomerEMail = СокрЛП(vCustomer.EMail);
			КонецЕсли;
			vDocument = pDoc.ДокОснование;
			Если ЗначениеЗаполнено(vDocument) And TypeOf(vDocument) = Тип("DocumentRef.Акт") Тогда
				vDocument = Неопределено;
			КонецЕсли;
			Если НЕ ЗначениеЗаполнено(vDocument) And ЗначениеЗаполнено(pDoc.ГруппаГостей) And ЗначениеЗаполнено(pDoc.ГруппаГостей.ClientDoc) Тогда
				vDocument = pDoc.ГруппаГостей.ClientDoc;
			КонецЕсли;
			Если ЗначениеЗаполнено(vDocument) Тогда
				Если TypeOf(vDocument) = Тип("DocumentRef.Бронирование") Or 
				   TypeOf(vDocument) = Тип("DocumentRef.Размещение") Тогда
					Если ЗначениеЗаполнено(vDocument.Клиент) Тогда
						vGuest = vDocument.Клиент;
						vGuestEMail = СокрЛП(vGuest.EMail);
					КонецЕсли;
					Если НЕ IsBlankString(vDocument.КонтактноеЛицо) Тогда
						vContactPersonEMail = cmGetContactPersonEMail(vDocument.КонтактноеЛицо);
						vContactPerson = СокрЛП(vDocument.КонтактноеЛицо);
					КонецЕсли;				
				ElsIf TypeOf(vDocument) = Тип("DocumentRef.БроньУслуг") Тогда
					Если ЗначениеЗаполнено(vDocument.Клиент) Тогда
						vGuest = vDocument.Клиент;
						vGuestEMail = СокрЛП(vGuest.EMail);
					КонецЕсли;
					Если НЕ IsBlankString(vDocument.КонтактноеЛицо) Тогда
						vContactPersonEMail = cmGetContactPersonEMail(vDocument.КонтактноеЛицо);
						vContactPerson = СокрЛП(vDocument.КонтактноеЛицо);
					КонецЕсли;				
				КонецЕсли;
			КонецЕсли;
		ElsIf TypeOf(pDoc) = Тип("DocumentRef.СчетПроживания") Тогда
			vDocument = pDoc.ДокОснование;
			Если ЗначениеЗаполнено(vDocument) Тогда
				vDocumentEmail = СокрЛП(vDocument.EMail);
				Если TypeOf(vDocument) = Тип("DocumentRef.Бронирование") Or 
				   TypeOf(vDocument) = Тип("DocumentRef.БроньУслуг") Or 
				   TypeOf(vDocument) = Тип("DocumentRef.Размещение") Тогда
					Если НЕ IsBlankString(vDocument.КонтактноеЛицо) Тогда
						vContactPersonEMail = cmGetContactPersonEMail(vDocument.КонтактноеЛицо);
						vContactPerson = СокрЛП(vDocument.КонтактноеЛицо);
					КонецЕсли;				
				КонецЕсли;
			КонецЕсли;
			vCustomer = pDoc.Контрагент;
			Если ЗначениеЗаполнено(pDoc.Контрагент) Тогда
				vCustomerEMail = СокрЛП(pDoc.Контрагент.EMail);
			КонецЕсли;
			Если ЗначениеЗаполнено(pDoc.Клиент) Тогда
				vGuest = pDoc.Клиент;
				vGuestEMail = СокрЛП(vGuest.EMail);
			КонецЕсли;
		ElsIf TypeOf(pDoc) = Тип("DocumentRef.Акт") Тогда
			vCustomer = pDoc.Контрагент;
			Если ЗначениеЗаполнено(vCustomer) Тогда
				vCustomerEMail = СокрЛП(vCustomer.EMail);
			КонецЕсли;
			vDocument = pDoc.ДокОснование;
			Если НЕ ЗначениеЗаполнено(vDocument) And ЗначениеЗаполнено(pDoc.ГруппаГостей) Тогда
				Если ЗначениеЗаполнено(pDoc.ГруппаГостей.Клиент) Тогда
					vGuest = pDoc.ГруппаГостей.Клиент;
					vGuestEMail = СокрЛП(vGuest.EMail);
				КонецЕсли;
				Если ЗначениеЗаполнено(pDoc.ГруппаГостей.ClientDoc) Тогда
					vDocument = pDoc.ГруппаГостей.ClientDoc;
				КонецЕсли;
			КонецЕсли;
			Если ЗначениеЗаполнено(vDocument) Тогда
				Если TypeOf(vDocument) = Тип("DocumentRef.Бронирование") Or 
				   TypeOf(vDocument) = Тип("DocumentRef.БроньУслуг") Or 
				   TypeOf(vDocument) = Тип("DocumentRef.Размещение") Тогда
					vDocumentEmail = СокрЛП(vDocument.EMail);
					Если НЕ IsBlankString(vDocument.КонтактноеЛицо) Тогда
						vContactPersonEMail = cmGetContactPersonEMail(vDocument.КонтактноеЛицо);
						vContactPerson = СокрЛП(vDocument.КонтактноеЛицо);
					КонецЕсли;				
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если НЕ IsBlankString(vDocumentEmail) Or 
		   НЕ IsBlankString(vCustomerEmail) Or 
		   НЕ IsBlankString(vGuestEmail) Or 
		   НЕ IsBlankString(vContactPersonEMail) Тогда
			pSendByEMail.Enabled = Истина;
			Если НЕ IsBlankString(vDocumentEmail) Тогда
				vButton = pSendByEMail.Buttons.Add("ActionSendToDocumentEMail", 
												   CommandBarButtonType.Action, 
												   vDocumentEmail, 
												   Новый Action("SendToDocumentEMailAction"));
				vButton.Picture = PictureLib.HTMLPage;
				vButton.Representation = CommandBarButtonRepresentation.PictureText;
				vButton.Description = NStr("ru='Отправить на адрес электронной почты указанный в документе';
				                           |de='An die im Dokument angegeben E-Mail-Adresse senden';
										   |en='Send to E-Mail address specified in the document'");
				vButton.ToolTip = NStr("ru='Отправить на адрес электронной почты указанный в документе';
				                       |de='An die im Dokument angegeben E-Mail-Adresse senden';
									   |en='Send to E-Mail address specified in the document'");
			КонецЕсли;
			Если НЕ IsBlankString(vCustomerEmail) Тогда
				vButton = pSendByEMail.Buttons.Add("ActionSendToCustomerEMail", 
												   CommandBarButtonType.Action, 
												   vCustomerEmail + " (" + СокрЛП(vCustomer) + ")", 
												   Новый Action("SendToCustomerEMailAction"));
				vButton.Picture = PictureLib.HTMLPage;
				vButton.Representation = CommandBarButtonRepresentation.PictureText;
				vButton.Description = NStr("ru='Отправить на адрес электронной почты указанный у контрагента';
				                           |de='An die beim Partner angegebene E-Mail-Adresse senden';
										   |en='Send to E-Mail address specified for Контрагент'");
				vButton.ToolTip = NStr("ru='Отправить на адрес электронной почты указанный у контрагента';
				                       |de='An die beim Partner angegebene E-Mail-Adresse senden';
									   |en='Send to E-Mail address specified for Контрагент'");
			КонецЕсли;
			Если НЕ IsBlankString(vGuestEmail) Тогда
				vButton = pSendByEMail.Buttons.Add("ActionSendToGuestEMail", 
												   CommandBarButtonType.Action, 
												   vGuestEmail + " (" + СокрЛП(vGuest) + ")", 
												   Новый Action("SendToGuestEMailAction"));
				vButton.Picture = PictureLib.HTMLPage;
				vButton.Representation = CommandBarButtonRepresentation.PictureText;
				vButton.Description = NStr("ru='Отправить на адрес электронной почты указанный у гостя';
				                           |de='An die beim Gast angegeben E-Mail-Adresse senden';
										   |en='Send to E-Mail address specified for guest'");
				vButton.ToolTip = NStr("ru='Отправить на адрес электронной почты указанный у гостя';
				                       |de='An die beim Gast angegeben E-Mail-Adresse senden';
									   |en='Send to E-Mail address specified for guest'");
			КонецЕсли;
			Если НЕ IsBlankString(vContactPersonEMail) Тогда
				vButton = pSendByEMail.Buttons.Add("ActionSendToContactPersonEMail", 
												   CommandBarButtonType.Action, 
												   vContactPersonEMail + " (" + СокрЛП(vContactPerson) + ")", 
												   Новый Action("SendToContactPersonEMailAction"));
				vButton.Picture = PictureLib.HTMLPage;
				vButton.Representation = CommandBarButtonRepresentation.PictureText;
				vButton.Description = NStr("ru='Отправить на адрес электронной почты указанный у контактного лица';
				                           |de='An die bei der Kontaktperson angegebene E-Mail-Adresse senden';
										   |en='Send to E-Mail address specified for contact person'");
				vButton.ToolTip = NStr("ru='Отправить на адрес электронной почты указанный у контактного лица';
				                       |de='An die bei der Kontaktperson angegebene E-Mail-Adresse senden';
									   |en='Send to E-Mail address specified for contact person'");
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmSendByEmailSubmenuAppearance

//-----------------------------------------------------------------------------
// Description: Runs scheduled jobs in the file mode of the 1C:Enterprize
// Parameters: None
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmProcessScheduledJobs() Экспорт
	ProcessJobs();
КонецПроцедуры //cmProcessScheduledJobs

//-----------------------------------------------------------------------------
// Description: Checks scheduled reports information register for the new records
//              where schedule date&time is less then current date. Если some records 
//              found then reports are generated for each of them and those records 
//              are deleted
// Parameters: None
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmProcessScheduledReports() Экспорт
	// Create scheduled reports register record manager
	vRecordManager = InformationRegisters.ОтчетыПоРасписанию.CreateRecordManager();
	
	// Run query to get all active report keys
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ScheduledReports.ScheduleDateTime AS ScheduleDateTime,
	|	ScheduledReports.Key AS Key
	|FROM
	|	InformationRegister.ScheduledReports AS ScheduledReports
	|WHERE
	|	ScheduledReports.ScheduleDateTime <= &qPeriod
	|ORDER BY
	|	ScheduleDateTime";
	vQry.SetParameter("qPeriod", CurrentDate());
	vScheduledReports = vQry.Execute().Unload();
	For Each vRow In vScheduledReports Do	
		// Generate reports by current register row key
		cmGenerateReportsByKey(TrimR(vRow.Key));
		
		// Delete processed register record
		Try
			vRecordManager.ScheduleDateTime = vRow.ScheduleDateTime;
			vRecordManager.Key = TrimR(vRow.Key);
			vRecordManager.Delete();
		Except
		EndTry;
	EndDo;
КонецПроцедуры //cmProcessScheduledReports

//-----------------------------------------------------------------------------
// Description: Generates reports from the report package
// Parameters: Main package report item, Report object to use parameters from, 
//             Spreadsheet where to put reports, REport builder details object,
//             Report parameter object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmGenerateReportsInThePackage(pReport, pParentRepObj, 
                                        pSpreadsheet, pReportBuilderDetails, 
                                        pParameter = Неопределено) Экспорт
	For Each vReportRow In pReport.Package Do
		Если НЕ vReportRow.IsActive Тогда
			Continue;
		КонецЕсли;
		// Put horizontal page break if necessary
		Если vReportRow.ReportPutHorizontalPageBreakBefore Тогда
			pSpreadsheet.PutHorizontalPageBreak();
		КонецЕсли;
		// Build package report object and generate report
		vRepObj = cmBuildReportObject(vReportRow.Report);
		Если vRepObj <> Неопределено Тогда
			// Initialize report settings
			Try
				// Fill reference to the report catalog item
				vRepObj.Report = vReportRow.Report;
				// Load report catalog item attributes
				vRepObj.pmLoadReportAttributes(pParameter);
				// Fill report attributes from the current report object
				Если НЕ vReportRow.DoNotUseParentReportAttributes Тогда
					Try
						cmFillChildReportAttributes(vRepObj, pParentRepObj);
					Except
					EndTry;
				КонецЕсли;
				// Generate report
				vRepFrm = vRepObj.ПолучитьФорму();
				vRepFrm.GenerateOnFormOpen = Истина;
				Если pReportBuilderDetails <> Неопределено Тогда
					vRepFrm.ReportBuilderDetails = pReportBuilderDetails;
				КонецЕсли;
				vRepFrm.fmGenerateReport(pParameter, pSpreadsheet, Ложь, Ложь, vReportRow);
			Except
				Continue;
			EndTry;
		КонецЕсли;
	EndDo;
КонецПроцедуры //cmGenerateReportsInThePackage	

//-----------------------------------------------------------------------------
// Description: Fills child report (from the package) attributes from the 
//              attributes of the parent main package report
// Parameters: Child report object, Parent report object 
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillChildReportAttributes(vChildRepObj, vParentRepObj) Экспорт
	vExcludingAttributes = "Report, ReportBuilder, QueryText, ReportAppearanceTemplateType, " + 
	                       "ReportDimensionsPlacementOnRowsType, ReportDimensionsPlacementOnColumnsType, " + 
	                       "ReportTotalsPlacementOnRowsType, ReportTotalsPlacementOnColumnsType, " + 
	                       "ReportDimensionAttributesPlacementInRowsType, ReportDimensionAttributesPlacementInColumnsType, " + 
	                       "ReportDoNotPutReportHeader, ReportDoNotPutTableHeader, " + 
	                       "ReportDoNotPutDetailRecords, ReportDoNotPutTableFooter, " + 
	                       "ReportDoNotPutOveralls, ReportDoNotPutReportFooter"; 
	FillPropertyValues(vChildRepObj, vParentRepObj, , vExcludingAttributes);
КонецПроцедуры //cmFillChildReportAttributes

//-----------------------------------------------------------------------------
// Description: Applies package row settings to the child report builder object
// Parameters: Structure of child report builder object, Package row
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmApplyPackageRowSettings(pReportBuilderAttrStruct, pPackageRow) Экспорт
	// Override some report settings from the package row
	pReportBuilderAttrStruct.PutReportHeader = НЕ pPackageRow.ReportDoNotPutReportHeader;
	pReportBuilderAttrStruct.PutTableHeader = НЕ pPackageRow.ReportDoNotPutTableHeader;
	pReportBuilderAttrStruct.PutDetailRecords = НЕ pPackageRow.ReportDoNotPutDetailRecords;
	pReportBuilderAttrStruct.PutTableFooter = НЕ pPackageRow.ReportDoNotPutTableFooter;
	pReportBuilderAttrStruct.PutOveralls = НЕ pPackageRow.ReportDoNotPutOveralls;
	pReportBuilderAttrStruct.PutReportFooter = НЕ pPackageRow.ReportDoNotPutReportFooter;
КонецПроцедуры //cmApplyPackageRowSettings

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Cash region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillCashMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	vArea = vTemplate.GetArea("CashMonitorHeader");
	pSpreadsheet.Put(vArea);
	
	// Get list of allowed cash registers
	
	
		
	// Do output
		
		//pSpreadsheet.Put(vArea);

КонецПроцедуры //cmFillCashMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Payments region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillPaymentsMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	vArea = vTemplate.GetArea("PaymentsMonitorHeader");
	//pSpreadsheet.Put(vArea);
	
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	PaymentsTurnovers.СпособОплаты,
	|	PaymentsTurnovers.PaymentCurrency,
	|	SUM(PaymentsTurnovers.SumExpenseTurnover) AS SumExpenseTurnover,
	|	SUM(PaymentsTurnovers.SumReceiptTurnover) AS SumReceiptTurnover
	|FROM
	|	РегистрНакопления.Платежи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS PaymentsTurnovers
	|
	|GROUP BY
	|	PaymentsTurnovers.СпособОплаты,
	|	PaymentsTurnovers.PaymentCurrency
	|
	|ORDER BY
	|	PaymentsTurnovers.СпособОплаты.ПорядокСортировки,
	|	PaymentsTurnovers.PaymentCurrency.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQry.SetParameter("qPeriodTo", CurrentDate());
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vResult = vQry.Execute().Unload();
	
	// Do output
	vArea = vTemplate.GetArea("СпособОплаты");
	For Each vResultRow In vResult Do
		// Skip settlements
		Если vResultRow.PaymentMethod = Справочники.СпособОплаты.Акт Тогда
			Continue;
		КонецЕсли;
		
		vArea.Parameters.mPaymentMethod = vResultRow.PaymentMethod;
		vArea.Parameters.mCurrency = cmGetCurrencyPresentation(vResultRow.PaymentCurrency);
		vArea.Parameters.mReceipt = vResultRow.SumReceiptTurnover;
		vArea.Parameters.mExpense = vResultRow.SumExpenseTurnover;
		
		pSpreadsheet.Put(vArea);
	EndDo;
КонецПроцедуры //cmFillPaymentsMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Check-in region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillCheckInMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get current hotel
	вГостиница = ПараметрыСеанса.ТекущаяГостиница;
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	vArea = vTemplate.GetArea("CheckIn");
	
	// Run query to get planned resources for today
	vQryPlannedToday = Новый Query();
	vQryPlannedToday.Text = 
	"SELECT
	|	RoomInventoryTurnovers.Гостиница,
	|	-SUM(RoomInventoryTurnovers.ExpectedRoomsCheckedInTurnover) AS RoomsReservedExpense,
	|	-SUM(RoomInventoryTurnovers.ExpectedBedsCheckedInTurnover) AS BedsReservedExpense,
	|	-SUM(RoomInventoryTurnovers.ExpectedGuestsCheckedInTurnover) AS GuestsReservedExpense
	|ИЗ
	|	РегистрНакопления.ЗагрузкаНомеров.Обороты(&qPeriodFrom, &qPeriodTo, Period, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryTurnovers
	|
	|GROUP BY
	|	RoomInventoryTurnovers.Гостиница";
	vQryPlannedToday.SetParameter("qPeriodFrom", cmGetMinCheckInDate(вГостиница));
	vQryPlannedToday.SetParameter("qPeriodTo", EndOfDay(ТекущаяДата()));
	vQryPlannedToday.SetParameter("qHotel", вГостиница);
	vPlannedTodayResult = vQryPlannedToday.Выполнить().Выгрузить();
	vPlannedTodayResult.GroupBy(, "RoomsReservedExpense, BedsReservedExpense, GuestsReservedExpense");
	
	vPlannedRoomsToday = 0;
	vPlannedBedsToday = 0;
	vPlannedGuestsToday = 0;
	Если vPlannedTodayResult.Количество() > 0 Тогда
		vPlannedTodayRow = vPlannedTodayResult.Get(0);
		
		vPlannedRoomsToday = ?(vPlannedTodayRow.RoomsReservedExpense < 0, 0, vPlannedTodayRow.RoomsReservedExpense);
		vPlannedBedsToday = vPlannedTodayRow.BedsReservedExpense;
		vPlannedGuestsToday = vPlannedTodayRow.GuestsReservedExpense;
	КонецЕсли;
	
	// Run query to get planned resources for tomorrow
	vQryPlannedTomorrow = Новый Query();
	vQryPlannedTomorrow.Text = 
	"SELECT
	|	RoomInventoryTurnovers.Гостиница,
	|	-SUM(RoomInventoryTurnovers.ExpectedRoomsCheckedInTurnover) AS RoomsReservedExpense,
	|	-SUM(RoomInventoryTurnovers.ExpectedBedsCheckedInTurnover) AS BedsReservedExpense,
	|	-SUM(RoomInventoryTurnovers.ExpectedGuestsCheckedInTurnover) AS GuestsReservedExpense
	|FROM
	|	РегистрНакопления.ЗагрузкаНомеров.Обороты(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryTurnovers
	|GROUP BY
	|	RoomInventoryTurnovers.Гостиница";
	vQryPlannedTomorrow.SetParameter("qPeriodFrom", НачалоДня(ТекущаяДата())+24*3600);
	vQryPlannedTomorrow.SetParameter("qPeriodTo", КонецДня(ТекущаяДата())+24*3600);  
	vQryPlannedTomorrow.SetParameter("qHotel", вГостиница);
	vPlannedTomorrowResult = vQryPlannedTomorrow.Execute().Unload();
	vPlannedTomorrowResult.GroupBy(, "RoomsReservedExpense, BedsReservedExpense, GuestsReservedExpense");
	
	vPlannedRoomsTomorrow = 0;
	vPlannedBedsTomorrow = 0;
	vPlannedGuestsTomorrow = 0;
	Если vPlannedTomorrowResult.Count() > 0 Тогда
		vPlannedTomorrowRow = vPlannedTomorrowResult.Get(0);
		
		vPlannedRoomsTomorrow = ?(vPlannedTomorrowRow.RoomsReservedExpense < 0, 0, vPlannedTomorrowRow.RoomsReservedExpense);
		vPlannedBedsTomorrow = vPlannedTomorrowRow.BedsReservedExpense;
		vPlannedGuestsTomorrow = vPlannedTomorrowRow.GuestsReservedExpense;
	КонецЕсли;
	
	// Run query to get checked in guests for today
	vQryToday = Новый Query();
	vQryToday.Text = 
	"ВЫБРАТЬ
	|	ЗагрузкаНомеровОбороты.Гостиница КАК Гостиница,
	|	-СУММА(ЗагрузкаНомеровОбороты.ЗаездНомеровОборот) КАК ЗаездНомеров,
	|	-СУММА(ЗагрузкаНомеровОбороты.BedsCheckedInОборот) КАК ЗаездМест,
	|	-СУММА(ЗагрузкаНомеровОбороты.GuestsCheckedInОборот) КАК ЗаездГостей
	|ИЗ
	|	РегистрНакопления.ЗагрузкаНомеров.Обороты(&qPeriodFrom, &qPeriodTo, День, Гостиница В ИЕРАРХИИ (&qHotel)) КАК ЗагрузкаНомеровОбороты
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗагрузкаНомеровОбороты.Гостиница";
	vQryToday.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQryToday.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQryToday.SetParameter("qHotel", вГостиница);
	vTodayResult = vQryToday.Execute().Unload();
	vTodayResult.GroupBy(, "ЗаездНомеров, ЗаездМест, ЗаездГостей");
	
	vRoomsToday = 0;
	vBedsToday = 0;
	vGuestsToday = 0;
	Если vTodayResult.Count() > 0 Тогда
		vTodayRow = vTodayResult.Get(0);
		
		vRoomsToday = ?(vTodayRow.ЗаездНомеров < 0, 0, vTodayRow.ЗаездНомеров);
		vBedsToday = vTodayRow.ЗаездМест;
		vGuestsToday = vTodayRow.ЗаездГостей;
	КонецЕсли;
	
	// Do output
	vArea.Parameters.mPlannedGuestsToday = vPlannedGuestsToday;
	vArea.Parameters.mPlannedGuestsTomorrow = vPlannedGuestsTomorrow;
	vArea.Parameters.mGuestsToday = vGuestsToday;
	
	vShowInBeds = Ложь;
	Если ЗначениеЗаполнено(вГостиница) Тогда
		Если вГостиница.ShowReportsInBeds Тогда
			vShowInBeds = Истина;
		КонецЕсли;
	КонецЕсли;
	Если vShowInBeds Тогда
		vArea.Parameters.mRoomsLabel = NStr("en='Beds';ru='Мест';de='Betten'");
		
		vArea.Parameters.mPlannedRoomsToday = vPlannedBedsToday;
		vArea.Parameters.mPlannedRoomsTomorrow = vPlannedBedsTomorrow;
		vArea.Parameters.mRoomsToday = vBedsToday;
	Иначе
		vArea.Parameters.mRoomsLabel = NStr("en='Rooms';ru='Номеров';de='Zimmern'");
		
		vArea.Parameters.mPlannedRoomsToday = vPlannedRoomsToday;
		vArea.Parameters.mPlannedRoomsTomorrow = vPlannedRoomsTomorrow;
		vArea.Parameters.mRoomsToday = vRoomsToday;
	КонецЕсли;
	 	// Initialize details structures
	vArea.Parameters.mPlannedCheckInTodayDetailsStructure = Новый Structure("Report", "ExpectedCheckInForToday");
	vArea.Parameters.mPlannedCheckInTomorrowDetailsStructure = Новый Structure("Report", "ExpectedCheckInForTomorrow");
	vArea.Parameters.mCheckInTodayDetailsStructure = Новый Structure("Report", "GuestsCheckedInToday");
	
	pSpreadsheet.Put(vArea);
КонецПроцедуры //cmFillCheckInMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Check-out region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillCheckOutMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get current hotel
	вГостиница = ПараметрыСеанса.ТекущаяГостиница;
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	vArea = vTemplate.GetArea("ВыездФакт");
	
	// Run query to get planned resources for today
	vQryPlannedToday = Новый Query();
	vQryPlannedToday.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
	|	SUM(ЗагрузкаНомеров.ИспользованоНомеров) AS ИспользованоНомеров,
	|	SUM(ЗагрузкаНомеров.ИспользованоМест) AS ИспользованоМест,
	|	SUM(ЗагрузкаНомеров.InHouseGuests) AS InHouseGuests
	|FROM
	|	(SELECT
	|		RoomInventoryMovements.Гостиница AS Гостиница,
	|		RoomInventoryMovements.Номер AS НомерРазмещения,
	|		CASE
	|			WHEN SUM(RoomInventoryMovements.RoomsCheckedOut) < 0
	|				THEN 0
	|			ELSE SUM(RoomInventoryMovements.RoomsCheckedOut)
	|		END AS ИспользованоНомеров,
	|		SUM(RoomInventoryMovements.BedsCheckedOut) AS ИспользованоМест,
	|		SUM(RoomInventoryMovements.GuestsCheckedOut) AS InHouseGuests
	|	FROM
	|		РегистрНакопления.ЗагрузкаНомеров AS RoomInventoryMovements
	|	WHERE
	|		RoomInventoryMovements.IsAccommodation
	|		AND RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Receipt) " + 
			?(ЗначениеЗаполнено(вГостиница), ?(вГостиница.IsFolder, " AND RoomInventoryMovements.Гостиница IN HIERARCHY(&qHotel)", " AND RoomInventoryMovements.Гостиница = &qHotel"), "") + "
	|		AND RoomInventoryMovements.PeriodTo <= &qPeriodTo
	|		AND RoomInventoryMovements.PeriodTo = RoomInventoryMovements.CheckOutDate
	|		AND RoomInventoryMovements.IsInHouse
	|		AND RoomInventoryMovements.IsCheckOut
	|	
	|	GROUP BY
	|		RoomInventoryMovements.Гостиница,
	|		RoomInventoryMovements.Номер) AS ЗагрузкаНомеров
	|
	|GROUP BY
	|	ЗагрузкаНомеров.Гостиница";
	vQryPlannedToday.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQryPlannedToday.SetParameter("qHotel", вГостиница);
	vPlannedTodayResult = vQryPlannedToday.Execute().Unload();
	vPlannedTodayResult.GroupBy(, "ИспользованоНомеров, ИспользованоМест, InHouseGuests");
	
	vPlannedRoomsToday = 0;
	vPlannedBedsToday = 0;
	vPlannedGuestsToday = 0;
	Если vPlannedTodayResult.Count() > 0 Тогда
		vPlannedTodayRow = vPlannedTodayResult.Get(0);
		
		vPlannedRoomsToday = vPlannedTodayRow.ИспользованоНомеров;
		vPlannedBedsToday = vPlannedTodayRow.ИспользованоМест;
		vPlannedGuestsToday = vPlannedTodayRow.InHouseGuests;
	КонецЕсли;
	
	// Run query to get planned resources for tomorrow
	vQryPlannedTomorrow = Новый Query();
	vQryPlannedTomorrow.Text = 
	"SELECT
	|	ЗагрузкаНомеровОбороты.Гостиница,
	|	SUM(ЗагрузкаНомеровОбороты.RoomsCheckedOutTurnover) AS RoomsCheckedOut,
	|	SUM(ЗагрузкаНомеровОбороты.BedsCheckedOutTurnover) AS BedsCheckedOut,
	|	SUM(ЗагрузкаНомеровОбороты.GuestsCheckedOutTurnover) AS GuestsCheckedOut
	|FROM
	|	РегистрНакопления.ЗагрузкаНомеров.Обороты(&qPeriodFrom, &qPeriodTo, Day, " + 
	?(ЗначениеЗаполнено(вГостиница), ?(вГостиница.IsFolder, " Гостиница IN HIERARCHY (&qHotel)", " Гостиница = &qHotel"), "") + "
	|	) AS ЗагрузкаНомеровОбороты
	|GROUP BY
	|	ЗагрузкаНомеровОбороты.Гостиница";
	vQryPlannedTomorrow.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()) + 24*3600);
	vQryPlannedTomorrow.SetParameter("qPeriodTo", EndOfDay(CurrentDate()) + 24*3600);
	vQryPlannedTomorrow.SetParameter("qHotel", вГостиница);
	vPlannedTomorrowResult = vQryPlannedTomorrow.Execute().Unload();
	vPlannedTomorrowResult.GroupBy(, "RoomsCheckedOut, BedsCheckedOut, GuestsCheckedOut");
	
	vPlannedRoomsTomorrow = 0;
	vPlannedBedsTomorrow = 0;
	vPlannedGuestsTomorrow = 0;
	Если vPlannedTomorrowResult.Count() > 0 Тогда
		vPlannedTomorrowRow = vPlannedTomorrowResult.Get(0);
		
		vPlannedRoomsTomorrow = vPlannedTomorrowRow.RoomsCheckedOut;
		vPlannedBedsTomorrow = vPlannedTomorrowRow.BedsCheckedOut;
		vPlannedGuestsTomorrow = vPlannedTomorrowRow.GuestsCheckedOut;
	КонецЕсли;
	
	// Do output
	vArea.Parameters.mPlannedGuestsToday = vPlannedGuestsToday;
	vArea.Parameters.mPlannedGuestsTomorrow = vPlannedGuestsTomorrow;
	
	vShowInBeds = Ложь;
	Если ЗначениеЗаполнено(вГостиница) Тогда
		Если вГостиница.ShowReportsInBeds Тогда
			vShowInBeds = Истина;
		КонецЕсли;
	КонецЕсли;
	Если vShowInBeds Тогда
		vArea.Parameters.mRoomsLabel = NStr("en='Beds';ru='Мест';de='Betten'");
		
		vArea.Parameters.mPlannedRoomsToday = vPlannedBedsToday;
		vArea.Parameters.mPlannedRoomsTomorrow = vPlannedBedsTomorrow;
	Иначе
		vArea.Parameters.mRoomsLabel = NStr("en='Rooms';ru='Номеров';de='Zimmern'");
		
		vArea.Parameters.mPlannedRoomsToday = vPlannedRoomsToday;
		vArea.Parameters.mPlannedRoomsTomorrow = vPlannedRoomsTomorrow;
	КонецЕсли;
	
	// Initialize details structures
	vArea.Parameters.mCheckOutTodayDetailsStructure = Новый Structure("Report", "ExpectedCheckOutForToday");
	vArea.Parameters.mCheckOutTomorrowDetailsStructure = Новый Structure("Report", "ExpectedCheckOutForTomorrow");
	
	pSpreadsheet.Put(vArea);
КонецПроцедуры //cmFillCheckOutMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Occupation percents region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillOccupationMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Show in beds
	вГостиница = ПараметрыСеанса.ТекущаяГостиница;
	
	vShowInBeds = Ложь;
	vShowSalesWithVAT = Ложь;
	Если ЗначениеЗаполнено(вГостиница) Тогда
		vShowInBeds = вГостиница.ShowReportsInBeds;
		vShowSalesWithVAT = вГостиница.ShowSalesInReportsWithVAT;
	КонецЕсли;
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	
	// Run query to get ГруппаНомеров inventory statistics
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеровОстатки.Гостиница,
	|	SUM(ЗагрузкаНомеровОстатки.TotalRoomsBalance) AS TotalRoomsBalance,
	|	SUM(ЗагрузкаНомеровОстатки.TotalBedsBalance) AS TotalBedsBalance,
	|	SUM(ЗагрузкаНомеровОстатки.RoomsBlockedBalance) AS RoomsBlockedBalance,
	|	SUM(ЗагрузкаНомеровОстатки.BedsBlockedBalance) AS BedsBlockedBalance,
	|	SUM(ЗагрузкаНомеровОстатки.RoomsVacantBalance) AS RoomsVacantBalance,
	|	SUM(ЗагрузкаНомеровОстатки.BedsVacantBalance) AS BedsVacantBalance,
	|	SUM(ЗагрузкаНомеровОстатки.InHouseGuestsBalance) AS InHouseGuestsBalance
	|FROM
	|	РегистрНакопления.ЗагрузкаНомеров.Balance(
	|			&qPeriodTo, 
	|			Гостиница IN HIERARCHY (&qHotel)) AS ЗагрузкаНомеровОстатки
	|GROUP BY
	|	ЗагрузкаНомеровОстатки.Гостиница";
	vQry.SetParameter("qPeriodTo", CurrentDate());
	vQry.SetParameter("qHotel", вГостиница);
	vInvResult = vQry.Execute().Unload();
	vInvResult.GroupBy(, "TotalRoomsBalance, TotalBedsBalance, RoomsBlockedBalance, BedsBlockedBalance, RoomsVacantBalance, BedsVacantBalance, InHouseGuestsBalance");
	
	vTotalRooms = 0;
	vTotalBeds = 0;
	vRoomsBlocked = 0;
	vBedsBlocked = 0;
	Если vInvResult.Count() > 0 Тогда
		vResultRow = vInvResult.Get(0);
		vTotalRooms = vResultRow.TotalRoomsBalance;
		vTotalBeds = vResultRow.TotalBedsBalance;
		vRoomsBlocked = -vResultRow.RoomsBlockedBalance;
		vBedsBlocked = -vResultRow.BedsBlockedBalance;
	КонецЕсли;	
	
	// Run query to get total ГруппаНомеров blocks that should be added to the number of total rooms rented
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	RoomBlocksBalance.Гостиница,
	|	SUM(RoomBlocksBalance.RoomsBlockedBalance) AS SpecRoomsBlocked,
	|	SUM(RoomBlocksBalance.BedsBlockedBalance) AS SpecBedsBlocked
	|FROM
	|	РегистрНакопления.БлокирНомеров.Balance(&qPeriodTo, Гостиница IN HIERARCHY (&qHotel)
	|	AND RoomBlockType.AddToRoomsRentedInSummaryIndexes) AS RoomBlocksBalance
	|GROUP BY
	|	RoomBlocksBalance.Гостиница";
	vQry.SetParameter("qHotel", вГостиница);
	vQry.SetParameter("qPeriodTo", CurrentDate());
	vSpecBlocksResult = vQry.Execute().Unload();
	
	vSpecRoomsBlocked = 0;
	vSpecBedsBlocked = 0;
	Если vSpecBlocksResult.Count() > 0 Тогда
		vSpecBlocksResultRow = vSpecBlocksResult.Get(0);
		vSpecRoomsBlocked = vSpecBlocksResultRow.SpecRoomsBlocked;
		vSpecBedsBlocked = vSpecBlocksResultRow.SpecBedsBlocked;
	КонецЕсли;
	
	// Fill area A.
	Если vShowInBeds Тогда
		vAreaA = vTemplate.GetArea("ВсегоМест");
		vAreaA.Parameters.mTotalBeds = vTotalBeds;
		vAreaA.Parameters.mBedsBlocked = vBedsBlocked - vSpecBedsBlocked;
	Иначе
		vAreaA = vTemplate.GetArea("ВсегоНомеров");
		vAreaA.Parameters.mTotalRooms = vTotalRooms;
		vAreaA.Parameters.mRoomsBlocked = vRoomsBlocked - vSpecRoomsBlocked;
	КонецЕсли;
	
	// Run query to get ГруппаНомеров sales for today
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Валюта,
	|	SUM(ОборотыПродажиНомеров.SalesTurnover) AS SalesTurnover,
	|	SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueTurnover) AS RoomRevenueTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.GuestDaysTurnover) AS GuestDaysTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS RoomsRentedTurnover,
	|	SUM(ОборотыПродажиНомеров.BedsRentedTurnover) AS BedsRentedTurnover
	|FROM
	|	РегистрНакопления.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Валюта
	|ORDER BY
	|	ОборотыПродажиНомеров.Валюта.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQry.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQry.SetParameter("qHotel", вГостиница);
	vSalesResult = vQry.Execute().Unload();
	
	// Get number of rooms/beds sold
	vReportingCurrency = Неопределено;
	Если ЗначениеЗаполнено(вГостиница) Тогда
		vReportingCurrency = вГостиница.Валюта;
	КонецЕсли;
	vSales = 0;
	vSalesWithoutVAT = 0;
	vRoomRevenue = 0;
	vRoomRevenueWithoutVAT = 0;
	vRoomsSold = 0;
	vBedsSold = 0;
	vGuestDays = 0;
	For Each vSalesResultRow In vSalesResult Do
		vReportingCurrency = vSalesResultRow.ReportingCurrency;
		vSales = vSales + vSalesResultRow.SalesTurnover;
		vSalesWithoutVAT = vSalesWithoutVAT + vSalesResultRow.SalesWithoutVATTurnover;
		vRoomRevenue = vRoomRevenue + vSalesResultRow.RoomRevenueTurnover;
		vRoomRevenueWithoutVAT = vRoomRevenueWithoutVAT + vSalesResultRow.RoomRevenueWithoutVATTurnover;
		vRoomsSold = vRoomsSold + vSalesResultRow.RoomsRentedTurnover;
		vBedsSold = vBedsSold + vSalesResultRow.BedsRentedTurnover;
		vGuestDays = vGuestDays + vSalesResultRow.GuestDaysTurnover;
	EndDo;
	
	// Run query to get ГруппаНомеров sales forcast for today
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesForecastTurnovers.Валюта,
	|	СУММА(RoomSalesForecastTurnovers.ПродажиОборот) AS SalesTurnover,
	|	СУММА(RoomSalesForecastTurnovers.ПродБезНДСОборот) AS SalesWithoutVATTurnover,
	|	СУММА(RoomSalesForecastTurnovers.ПроданоНомеровОборот) AS RoomRevenueTurnover,
	|	СУММА(RoomSalesForecastTurnovers.ДоходПродНомерБезНДСОборот) AS RoomRevenueWithoutVATTurnover,
	|	СУММА(RoomSalesForecastTurnovers.ЗаездГостейОборот) AS GuestDaysTurnover,
	|	СУММА(RoomSalesForecastTurnovers.ПроданоНомеровОборот) AS RoomsRentedTurnover,
	|	СУММА(RoomSalesForecastTurnovers.ПроданоМестОборот) AS BedsRentedTurnover
	|FROM
	|	РегистрНакопления.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS
	|		RoomSalesForecastTurnovers
	|GROUP BY
	|	RoomSalesForecastTurnovers.Валюта
	|ORDER BY
	|	RoomSalesForecastTurnovers.Валюта.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQry.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQry.SetParameter("qHotel", вГостиница);
	vSalesForecastResult = vQry.Execute().Unload();
	
	// Get number of rooms/beds sold
	vSalesForecast = 0;
	vSalesWithoutVATForecast = 0;
	vRoomRevenueForecast = 0;
	vRoomRevenueWithoutVATForecast = 0;
	vRoomsSoldForecast = 0;
	vBedsSoldForecast = 0;
	vGuestDaysForecast = 0;
	For Each vSalesForecastResultRow In vSalesForecastResult Do
		vSalesForecast = vSalesForecast + vSalesForecastResultRow.SalesTurnover;
		vSalesWithoutVATForecast = vSalesWithoutVATForecast + vSalesForecastResultRow.SalesWithoutVATTurnover;
		vRoomRevenueForecast = vRoomRevenueForecast + vSalesForecastResultRow.RoomRevenueTurnover;
		vRoomRevenueWithoutVATForecast = vRoomRevenueWithoutVATForecast + vSalesForecastResultRow.RoomRevenueWithoutVATTurnover;
		vRoomsSoldForecast = vRoomsSoldForecast + vSalesForecastResultRow.RoomsRentedTurnover;
		vBedsSoldForecast = vBedsSoldForecast + vSalesForecastResultRow.BedsRentedTurnover;
		vGuestDaysForecast = vGuestDaysForecast + vSalesForecastResultRow.GuestDaysTurnover;
	EndDo;
	
	// Fill areas C.D.E.
	Если vShowInBeds Тогда
		vAreaCDE = vTemplate.GetArea("BedsSold|First2Columns");
		vDiagramCDE = vTemplate.GetArea("BedsSold|Last3Column");
		vDiagram = vDiagramCDE.Area("BedsSoldMeter").Object;
		
		Если vBedsSoldForecast <> 0 Тогда
			vAreaCDE.Parameters.mBedsSold = "" + Format(vBedsSold + vSpecBedsBlocked, "ND=10; NFD=1; NZ=; NG=") + " / " + Format(vBedsSold + vBedsSoldForecast + vSpecBedsBlocked, "ND=10; NFD=1; NZ=; NG=");
		Иначе
			vAreaCDE.Parameters.mBedsSold = "" + Format(vBedsSold + vSpecBedsBlocked, "ND=10; NFD=1; NZ=; NG=");
		КонецЕсли;
	Иначе
		vAreaCDE = vTemplate.GetArea("RoomsSold|First2Columns");
		vDiagramCDE = vTemplate.GetArea("RoomsSold|Last3Column");
		vDiagram = vDiagramCDE.Area("RoomsSoldMeter").Object;
		
		Если vRoomsSoldForecast <> 0 Тогда
			vAreaCDE.Parameters.mRoomsSold = "" + Format(vRoomsSold + vSpecRoomsBlocked, "ND=10; NFD=1; NZ=; NG=") + " / " + Format(vRoomsSold + vRoomsSoldForecast + vSpecRoomsBlocked, "ND=10; NFD=1; NZ=; NG=");
		Иначе
			vAreaCDE.Parameters.mRoomsSold = "" + Format(vRoomsSold + vSpecRoomsBlocked, "ND=10; NFD=1; NZ=; NG=");
		КонецЕсли;
	КонецЕсли;
	
	mOccupationPercent = 0;
	mOccupationPercentForecast = 0;
	Если vShowInBeds Тогда
		Если (vTotalBeds - vBedsBlocked + vSpecBedsBlocked) <> 0 Тогда 
			mOccupationPercent = Round(100*(vBedsSold + vSpecBedsBlocked)/(vTotalBeds - vBedsBlocked + vSpecBedsBlocked), 2);
			mOccupationPercentForecast = Round(100*(vBedsSold + vBedsSoldForecast + vSpecBedsBlocked)/(vTotalBeds - vBedsBlocked + vSpecBedsBlocked), 2);
		КонецЕсли;
	Иначе
		Если (vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked) <> 0 Тогда 
			mOccupationPercent = Round(100*(vRoomsSold + vSpecRoomsBlocked)/(vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked), 2);
			mOccupationPercentForecast = Round(100*(vRoomsSold + vRoomsSoldForecast + vSpecRoomsBlocked)/(vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked), 2);
		КонецЕсли;
	КонецЕсли;
	Если mOccupationPercent = mOccupationPercentForecast Тогда
		vAreaCDE.Parameters.mOccupationPercent = "" + mOccupationPercent;
	Иначе
		vAreaCDE.Parameters.mOccupationPercent = "" + mOccupationPercent + " / " + mOccupationPercentForecast;
	КонецЕсли;
	
	Если vGuestDaysForecast <> 0 Тогда
		vAreaCDE.Parameters.mInHouseGuests = "" + Format(vGuestDays, "ND=10; NFD=0; NZ=; NG=") + " / " + Format(vGuestDays + vGuestDaysForecast, "ND=10; NFD=0; NZ=; NG=");
	Иначе
		vAreaCDE.Parameters.mInHouseGuests = "" + Format(vGuestDays, "ND=10; NFD=0; NZ=; NG=");
	КонецЕсли;
	
	// Get occupation percent meter
	vDiagram.RefreshEnabled = Ложь;
	vDiagram.AutoSeriesText = Ложь;
	vDiagram.AutoPointText = Ложь;
	vDiagram.Clear();
	vSeria = vDiagram.Series.Add(NStr("en='Current occupancy %';ru='Тек. % загрузки';de='Aktueller % die Belegung'"));
	vSeriaForecast = vDiagram.Series.Add(NStr("en='Forecast occupancy %';ru='План. % загрузки';de='Geplant % des Ladens'"));
	Если vShowInBeds Тогда
		vPoint = vDiagram.Points.Add(NStr("en='By beds sold';ru='По проданным местам';de='Nach verkauften Betten'"));
	Иначе
		vPoint = vDiagram.Points.Add(NStr("en='By rooms sold';ru='По проданным номерам';de='Nach verkauften Zimmern'"));
	КонецЕсли;
	vDiagram.SetValue(vPoint, vSeria, Min(?(mOccupationPercent < 0, 0, mOccupationPercent), 100));
	vDiagram.SetValue(vPoint, vSeriaForecast, Min(?(mOccupationPercentForecast < 0, 0, mOccupationPercentForecast), 100));
	vDiagram.RefreshEnabled = Истина;

	// Do output	
	vArea = vTemplate.GetArea("StatisticsMonitorHeader");
	pSpreadsheet.Put(vArea);
	
	// Output section A
	pSpreadsheet.Put(vAreaA);
	// Output section C, D, E
	pSpreadsheet.Put(vAreaCDE);
	pSpreadsheet.Join(vDiagramCDE);
	
	// Output section F
	Если vShowSalesWithVAT Тогда
		vAreaFHeader = vTemplate.GetArea("SalesHeaderWithVAT");
	Иначе
		vAreaFHeader = vTemplate.GetArea("SalesHeader");
	КонецЕсли;
	pSpreadsheet.Put(vAreaFHeader);
	
	vAreaF = vTemplate.GetArea("Продажи");
	Если vShowSalesWithVAT Тогда
		vAreaF.Parameters.mSales = vSales + vSalesForecast;
		vAreaF.Parameters.mRoomRevenue = vRoomRevenue + vRoomRevenueForecast;
	Иначе
		vAreaF.Parameters.mSales = vSalesWithoutVAT + vSalesWithoutVATForecast;
		vAreaF.Parameters.mRoomRevenue = vRoomRevenueWithoutVAT + vRoomRevenueWithoutVATForecast;
	КонецЕсли;
	vAreaF.Parameters.mCurrency = cmGetCurrencyPresentation(vReportingCurrency);
	
	pSpreadsheet.Put(vAreaF);
	
	// Output section G
	Если vShowInBeds Тогда
		vAreaGHeader = vTemplate.GetArea("AverageBedStatisticsHeader");
	Иначе
		vAreaGHeader = vTemplate.GetArea("AverageRoomStatisticsHeader");
	КонецЕсли;
	pSpreadsheet.Put(vAreaGHeader);
	
	Если vShowInBeds Тогда
		vAreaG = vTemplate.GetArea("AverageBedStatistics");
	Иначе
		vAreaG = vTemplate.GetArea("AverageRoomStatistics");
	КонецЕсли;
	Если vShowSalesWithVAT Тогда
		Если vShowInBeds Тогда
			Если (vBedsSold + vBedsSoldForecast) = 0 Тогда
				vAreaG.Parameters.mAvgBedPrice = 0;
			Иначе
				vAreaG.Parameters.mAvgBedPrice = Round((vRoomRevenue + vRoomRevenueForecast)/(vBedsSold + vBedsSoldForecast), 2);
			КонецЕсли;
			Если (vTotalBeds - vBedsBlocked + vSpecBedsBlocked) = 0 Тогда
				vAreaG.Parameters.mAvgBedIncome = 0;
			Иначе
				vAreaG.Parameters.mAvgBedIncome = Round((vRoomRevenue + vRoomRevenueForecast)/(vTotalBeds - vBedsBlocked + vSpecBedsBlocked), 2);
			КонецЕсли;
		Иначе
			Если (vRoomsSold + vRoomsSoldForecast) = 0 Тогда
				vAreaG.Parameters.mAvgRoomPrice = 0;
			Иначе
				vAreaG.Parameters.mAvgRoomPrice = Round((vRoomRevenue + vRoomRevenueForecast)/(vRoomsSold + vRoomsSoldForecast), 2);
			КонецЕсли;
			Если (vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked) = 0 Тогда
				vAreaG.Parameters.mAvgRoomIncome = 0;
			Иначе
				vAreaG.Parameters.mAvgRoomIncome = Round((vRoomRevenue + vRoomRevenueForecast)/(vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked), 2);
			КонецЕсли;
		КонецЕсли;
	Иначе
		Если vShowInBeds Тогда
			Если (vBedsSold + vBedsSoldForecast) = 0 Тогда
				vAreaG.Parameters.mAvgBedPrice = 0;
			Иначе
				vAreaG.Parameters.mAvgBedPrice = Round((vRoomRevenueWithoutVAT + vRoomRevenueWithoutVATForecast)/(vBedsSold + vBedsSoldForecast), 2);
			КонецЕсли;
			Если (vTotalBeds - vBedsBlocked + vSpecBedsBlocked) = 0 Тогда
				vAreaG.Parameters.mAvgBedIncome = 0;
			Иначе
				vAreaG.Parameters.mAvgBedIncome = Round((vRoomRevenueWithoutVAT + vRoomRevenueWithoutVATForecast)/(vTotalBeds - vBedsBlocked + vSpecBedsBlocked), 2);
			КонецЕсли;
		Иначе
			Если (vRoomsSold + vRoomsSoldForecast) = 0 Тогда
				vAreaG.Parameters.mAvgRoomPrice = 0;
			Иначе
				vAreaG.Parameters.mAvgRoomPrice = Round((vRoomRevenueWithoutVAT + vRoomRevenueWithoutVATForecast)/(vRoomsSold + vRoomsSoldForecast), 2);
			КонецЕсли;
			Если (vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked) = 0 Тогда
				vAreaG.Parameters.mAvgRoomIncome = 0;
			Иначе
				vAreaG.Parameters.mAvgRoomIncome = Round((vRoomRevenueWithoutVAT + vRoomRevenueWithoutVATForecast)/(vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked), 2);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	vAreaG.Parameters.mCurrency = cmGetCurrencyPresentation(vReportingCurrency);
	
	pSpreadsheet.Put(vAreaG);
КонецПроцедуры //cmFillOccupationMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Occupation percents region with data in 
//              case if ShowOccupationPercentBasedOnInHouseGuests hotel parameter 
//              is true
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillOccupationMonitorByRoomInventory(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Show in beds
	вГостиница = ПараметрыСеанса.ТекущаяГостиница;
	
	vShowInBeds = Ложь;
	vShowSalesWithVAT = Ложь;
	Если ЗначениеЗаполнено(вГостиница) Тогда
		vShowInBeds = вГостиница.ShowReportsInBeds;
		vShowSalesWithVAT = вГостиница.ShowSalesInReportsWithVAT;
	КонецЕсли;
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	
	// Run query to get ГруппаНомеров inventory statistics
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеровОстатки.Гостиница,
	|	SUM(ЗагрузкаНомеровОстатки.ВсегоНомеровОстаток) AS TotalRoomsBalance,
	|	SUM(ЗагрузкаНомеровОстатки.ВсегоМестОстаток) AS TotalBedsBalance,
	|	SUM(ЗагрузкаНомеровОстатки.ЗаблокНомеровОстаток) AS RoomsBlockedBalance,
	|	SUM(ЗагрузкаНомеровОстатки.ЗаблокМестОстаток) AS BedsBlockedBalance,
	|	SUM(ЗагрузкаНомеровОстатки.RoomsVacantBalance) AS RoomsVacantBalance,
	|	SUM(ЗагрузкаНомеровОстатки.BedsVacantBalance) AS BedsVacantBalance,
	|	SUM(ЗагрузкаНомеровОстатки.InHouseGuestsBalance) AS InHouseGuestsBalance,
	|	SUM(ЗагрузкаНомеровОстатки.InHouseBedsBalance) AS InHouseBedsBalance,
	|	SUM(ЗагрузкаНомеровОстатки.InHouseRoomsBalance) AS InHouseRoomsBalance
	|FROM
	|	РегистрНакопления.ЗагрузкаНомеров.Остатки(&qPeriodTo, Гостиница IN HIERARCHY (&qHotel)) AS ЗагрузкаНомеровОстатки
	|GROUP BY
	|	ЗагрузкаНомеровОстатки.Гостиница";
	vQry.SetParameter("qPeriodTo", CurrentDate());
	vQry.SetParameter("qHotel", вГостиница);
	vInvResult = vQry.Execute().Unload();
	vInvResult.GroupBy(, "TotalRoomsBalance, TotalBedsBalance, RoomsBlockedBalance, BedsBlockedBalance, RoomsVacantBalance, BedsVacantBalance, InHouseGuestsBalance, InHouseRoomsBalance, InHouseBedsBalance");
	
	vTotalRooms = 0;
	vTotalBeds = 0;
	vRoomsBlocked = 0;
	vBedsBlocked = 0;
	
	
	vInHouseGuests = 0;
	vInHouseRooms = 0;
	vInHouseBeds = 0;
	Если vInvResult.Count() > 0 Тогда
		vResultRow = vInvResult.Get(0);
		
		vTotalRooms = vResultRow.TotalRoomsBalance;
		vTotalBeds = vResultRow.TotalBedsBalance;
		vRoomsBlocked = -vResultRow.RoomsBlockedBalance;
		vBedsBlocked = -vResultRow.BedsBlockedBalance;
		
		vInHouseGuests = -vResultRow.InHouseGuestsBalance;
		vInHouseRooms = -vResultRow.InHouseRoomsBalance;
		vInHouseBeds = -vResultRow.InHouseBedsBalance;
	КонецЕсли;
	
	// Run query to get total ГруппаНомеров blocks that should be added to the number of total rooms rented
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	RoomBlocksBalance.Гостиница,
	|	SUM(RoomBlocksBalance.RoomsBlockedBalance) AS SpecRoomsBlocked,
	|	SUM(RoomBlocksBalance.BedsBlockedBalance) AS SpecBedsBlocked
	|FROM
	|	РегистрНакопления.БлокирНомеров.Остатки(
	|			&qPeriodTo,
	|			Гостиница IN HIERARCHY (&qHotel) AND
	|			RoomBlockType.AddToRoomsRentedInSummaryIndexes) AS RoomBlocksBalance
	|GROUP BY
	|	RoomBlocksBalance.Гостиница";
	vQry.SetParameter("qHotel", вГостиница);
	vQry.SetParameter("qPeriodTo", CurrentDate());
	vSpecBlocksResult = vQry.Execute().Unload();
	
	vSpecRoomsBlocked = 0;
	vSpecBedsBlocked = 0;
	Если vSpecBlocksResult.Count() > 0 Тогда
		vSpecBlocksResultRow = vSpecBlocksResult.Get(0);
		
		vSpecRoomsBlocked = vSpecBlocksResultRow.SpecRoomsBlocked;
		vSpecBedsBlocked = vSpecBlocksResultRow.SpecBedsBlocked;
	КонецЕсли;
	
	// Fill area A.
	Если vShowInBeds Тогда
		vAreaA = vTemplate.GetArea("ВсегоМест");
		vAreaA.Parameters.mTotalBeds = vTotalBeds;
		vAreaA.Parameters.mBedsBlocked = vBedsBlocked - vSpecBedsBlocked;
	Иначе
		vAreaA = vTemplate.GetArea("ВсегоНомеров");
		vAreaA.Parameters.mTotalRooms = vTotalRooms;
		vAreaA.Parameters.mRoomsBlocked = vRoomsBlocked - vSpecRoomsBlocked;
	КонецЕсли;
	
	// Run query to get ГруппаНомеров sales for today
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Валюта,
	|	SUM(ОборотыПродажиНомеров.ПродажиОборот) AS SalesTurnover,
	|	SUM(ОборотыПродажиНомеров.ПродажиБезНДСОборот) AS SalesWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.ДоходОтНомеровОборот) AS RoomRevenueTurnover,
	|	SUM(ОборотыПродажиНомеров.ДоходОтНомеровБезНДСОборот) AS RoomRevenueWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.ПроданоНомеровОборот) AS RoomsRentedTurnover,
	|	SUM(ОборотыПродажиНомеров.ПроданоМестОборот) AS BedsRentedTurnover
	|FROM
	|	РегистрНакопления.Продажи.Обороты(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Валюта
	|ORDER BY
	|	ОборотыПродажиНомеров.Валюта.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQry.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQry.SetParameter("qHotel", вГостиница);
	vSalesResult = vQry.Execute().Unload();
	
	// Fill area C.D.E.
	Если vShowInBeds Тогда
		vAreaCDE = vTemplate.GetArea("BedsInHouse|First2Columns");
		vDiagramCDE = vTemplate.GetArea("BedsInHouse|Last3Column");
		vDiagram = vDiagramCDE.Area("BedsInHouseMeter").Object;
		
		vAreaCDE.Parameters.mBedsInHouse = vInHouseBeds + vSpecBedsBlocked;
	Иначе
		vAreaCDE = vTemplate.GetArea("RoomsInHouse|First2Columns");
		vDiagramCDE = vTemplate.GetArea("RoomsInHouse|Last3Column");
		vDiagram = vDiagramCDE.Area("RoomsInHouseMeter").Object;
		
		vAreaCDE.Parameters.mRoomsInHouse = vInHouseRooms + vSpecRoomsBlocked;
	КонецЕсли;
	
	Если vShowInBeds Тогда
		Если (vTotalBeds - vBedsBlocked + vSpecBedsBlocked) = 0 Тогда 
			vAreaCDE.Parameters.mOccupationPercent = 0;
		Иначе
			vAreaCDE.Parameters.mOccupationPercent = Round(100*(vInHouseBeds + vSpecBedsBlocked)/(vTotalBeds - vBedsBlocked + vSpecBedsBlocked), 2);
		КонецЕсли;
	Иначе
		Если (vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked) = 0 Тогда 
			vAreaCDE.Parameters.mOccupationPercent = 0;
		Иначе
			vAreaCDE.Parameters.mOccupationPercent = Round(100*(vInHouseRooms + vSpecRoomsBlocked)/(vTotalRooms - vRoomsBlocked + vSpecRoomsBlocked), 2);
		КонецЕсли;
	КонецЕсли;
	
	vAreaCDE.Parameters.mInHouseGuests = vInHouseGuests;
	
	// Get occupation percent meter
	vDiagram.RefreshEnabled = Ложь;
	vDiagram.AutoSeriesText = Ложь;
	vDiagram.AutoPointText = Ложь;
	vDiagram.Clear();
	vSeria = vDiagram.Series.Add(NStr("en='Occupancy %'; ru='% Загрузки'; de='% die Belegung'"));
	Если vShowInBeds Тогда
		vPoint = vDiagram.Points.Add(NStr("en='By beds in-house';ru='По занятым местам';de='Nach besetzten Betten'"));
	Иначе
		vPoint = vDiagram.Points.Add(NStr("en='By rooms in-house';ru='По занятым номерам';de='Nach belegten Zimmern'"));
	КонецЕсли;
	mOccupationPercent = vAreaCDE.Parameters.mOccupationPercent;
	vDiagram.SetValue(vPoint, vSeria, Min(?(mOccupationPercent < 0, 0, mOccupationPercent), 100));
	vDiagram.RefreshEnabled = Истина;

	// Do output	
	vArea = vTemplate.GetArea("StatisticsMonitorHeader");
	pSpreadsheet.Put(vArea);
	
	// Output section A
	pSpreadsheet.Put(vAreaA);
	// Output section C
	pSpreadsheet.Put(vAreaCDE);
	pSpreadsheet.Join(vDiagramCDE);
	
	// Output section F
	Если vShowSalesWithVAT Тогда
		vAreaFHeader = vTemplate.GetArea("SalesHeaderWithVAT");
	Иначе
		vAreaFHeader = vTemplate.GetArea("SalesHeader");
	КонецЕсли;
	pSpreadsheet.Put(vAreaFHeader);
	
	vAreaF = vTemplate.GetArea("Продажи");
	For Each vSalesResultRow In vSalesResult Do
		Если vShowSalesWithVAT Тогда
			vAreaF.Parameters.mSales = vSalesResultRow.SalesTurnover;
			vAreaF.Parameters.mRoomRevenue = vSalesResultRow.RoomRevenueTurnover;
		Иначе
			vAreaF.Parameters.mSales = vSalesResultRow.SalesWithoutVATTurnover;
			vAreaF.Parameters.mRoomRevenue = vSalesResultRow.RoomRevenueWithoutVATTurnover;
		КонецЕсли;
		vAreaF.Parameters.mCurrency = cmGetCurrencyPresentation(vSalesResultRow.ReportingCurrency);
		
		pSpreadsheet.Put(vAreaF);
	EndDo;
	
	// Output section G
	Если vShowInBeds Тогда
		vAreaGHeader = vTemplate.GetArea("AverageBedInventoryStatisticsHeader");
	Иначе
		vAreaGHeader = vTemplate.GetArea("AverageRoomInventoryStatisticsHeader");
	КонецЕсли;
	pSpreadsheet.Put(vAreaGHeader);
	
	Если vShowInBeds Тогда
		vAreaG = vTemplate.GetArea("AverageBedInventoryStatistics");
	Иначе
		vAreaG = vTemplate.GetArea("AverageRoomInventoryStatistics");
	КонецЕсли;
	For Each vSalesResultRow In vSalesResult Do
		Если vShowSalesWithVAT Тогда
			Если vShowInBeds Тогда
				Если vSalesResultRow.BedsRentedTurnover = 0 Тогда
					vAreaG.Parameters.mAvgBedPrice = 0;
				Иначе
					vAreaG.Parameters.mAvgBedPrice = Round(vSalesResultRow.RoomRevenueTurnover/vSalesResultRow.BedsRentedTurnover, 2);
				КонецЕсли;
			Иначе
				Если vSalesResultRow.RoomsRentedTurnover = 0 Тогда
					vAreaG.Parameters.mAvgRoomPrice = 0;
				Иначе
					vAreaG.Parameters.mAvgRoomPrice = Round(vSalesResultRow.RoomRevenueTurnover/vSalesResultRow.RoomsRentedTurnover, 2);
				КонецЕсли;
			КонецЕсли;
		Иначе
			Если vShowInBeds Тогда
				Если vSalesResultRow.BedsRentedTurnover = 0 Тогда
					vAreaG.Parameters.mAvgBedPrice = 0;
				Иначе
					vAreaG.Parameters.mAvgBedPrice = Round(vSalesResultRow.RoomRevenueWithoutVATTurnover/vSalesResultRow.BedsRentedTurnover, 2);
				КонецЕсли;
			Иначе
				Если vSalesResultRow.RoomsRentedTurnover = 0 Тогда
					vAreaG.Parameters.mAvgRoomPrice = 0;
				Иначе
					vAreaG.Parameters.mAvgRoomPrice = Round(vSalesResultRow.RoomRevenueWithoutVATTurnover/vSalesResultRow.RoomsRentedTurnover, 2);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		vAreaG.Parameters.mCurrency = cmGetCurrencyPresentation(vSalesResultRow.ReportingCurrency);
		
		pSpreadsheet.Put(vAreaG);
	EndDo;
КонецПроцедуры //cmFillOccupationMonitorByRoomInventory

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Customers region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillCustomersMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	vArea = vTemplate.GetArea("CustomersMonitorHeader");
	pSpreadsheet.Put(vArea);
	
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	CustomerSales.Контрагент,
	|	CustomerSales.Валюта,
	|	SUM(CustomerSales.SalesTurnover) AS SalesTurnover,
	|	SUM(CustomerSales.CommissionSumTurnover) AS CommissionSumTurnover,
	|	SUM(CustomerSales.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(CustomerSales.CommissionSumWithoutVATTurnover) AS CommissionSumWithoutVATTurnover,
	|	SUM(CustomerSales.DiscountSumTurnover) AS DiscountSumTurnover,
	|	SUM(CustomerSales.DiscountSumWithoutVATTurnover) AS DiscountSumWithoutVATTurnover
	|FROM
	|	(SELECT
	|		SalesTurnovers.Контрагент AS Контрагент,
	|		SalesTurnovers.Валюта AS Валюта,
	|		SalesTurnovers.SalesTurnover AS SalesTurnover,
	|		SalesTurnovers.CommissionSumTurnover AS CommissionSumTurnover,
	|		SalesTurnovers.SalesWithoutVATTurnover AS SalesWithoutVATTurnover,
	|		SalesTurnovers.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATTurnover,
	|		SalesTurnovers.DiscountSumTurnover AS DiscountSumTurnover,
	|		SalesTurnovers.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATTurnover
	|	FROM
	|		РегистрНакопления.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, PERIOD, Гостиница IN HIERARCHY (&qHotel)) AS SalesTurnovers
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		ExpectedSalesTurnovers.Контрагент,
	|		ExpectedSalesTurnovers.Валюта,
	|		ExpectedSalesTurnovers.SalesTurnover,
	|		ExpectedSalesTurnovers.CommissionSumTurnover,
	|		ExpectedSalesTurnovers.SalesWithoutVATTurnover,
	|		ExpectedSalesTurnovers.CommissionSumWithoutVATTurnover,
	|		ExpectedSalesTurnovers.DiscountSumTurnover,
	|		ExpectedSalesTurnovers.DiscountSumWithoutVATTurnover
	|	FROM
	|		РегистрНакопления.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, PERIOD, Гостиница IN HIERARCHY (&qHotel)) AS ExpectedSalesTurnovers) AS CustomerSales
	|
	|GROUP BY
	|	CustomerSales.Контрагент,
	|	CustomerSales.Валюта
	|
	|ORDER BY
	|	CustomerSales.Валюта.ПорядокСортировки,
	|	SalesTurnover DESC,
	|	CustomerSales.Контрагент.Description";
	vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQry.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Do top 5 output
	i = 0;
	vArea = vTemplate.GetArea("Контрагент");
	For Each vQryResultRow In vQryResult Do
		Если i < 5 Тогда
			Если ЗначениеЗаполнено(vQryResultRow.Customer) Тогда
				vArea.Parameters.mCustomer = vQryResultRow.Контрагент;
				vArea.Parameters.mCustomerRef = vQryResultRow.Контрагент;
			Иначе
				vArea.Parameters.mCustomer = NStr("en='<Persons>';ru='<Физические лица>';de='<Natürliche Personen>'");
				vArea.Parameters.mCustomerRef = Неопределено;
			КонецЕсли;
			vArea.Parameters.mCurrency = cmGetCurrencyPresentation(vQryResultRow.ReportingCurrency);
			vArea.Parameters.mSales = vQryResultRow.SalesTurnover;
			vArea.Parameters.mCommission = vQryResultRow.CommissionSumTurnover;
			
			pSpreadsheet.Put(vArea);
			
			i = i + 1;
		Иначе
			Break;
		КонецЕсли;
	EndDo;
	
	// Group all other customers into one row
	Если i = 5 Тогда
		// Delete top 5 rows
		i = 0;
		While i < 5 Do
			vQryResult.Delete(0);
			i = i + 1;
		EndDo;
		// Group all other
		vQryResult.GroupBy("Валюта", "SalesTurnover, CommissionSumTurnover, DiscountSumTurnover");
		vQryResult.Sort("Валюта Asc, SalesTurnover Desc");
		For Each vQryResultRow In vQryResult Do
			vArea.Parameters.mCustomer = NStr("en='<All other>';ru='<Все остальные>';de='<Alle anderen>'");
			vArea.Parameters.mCustomerRef = Неопределено;
			vArea.Parameters.mCurrency = cmGetCurrencyPresentation(vQryResultRow.ReportingCurrency);
			vArea.Parameters.mSales = vQryResultRow.SalesTurnover;
			vArea.Parameters.mCommission = vQryResultRow.CommissionSumTurnover;
			
			pSpreadsheet.Put(vArea);
		EndDo;
	КонецЕсли;
КонецПроцедуры //cmFillCustomersMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Debtors region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillDebtorsMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	vArea = vTemplate.GetArea("DebtorsMonitorHeader");
	pSpreadsheet.Put(vArea);
	
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ВзаиморасчетыКонтрагенты.Контрагент AS Контрагент,
	|	ВзаиморасчетыКонтрагенты.ВалютаРасчетов AS ВалютаРасчетов,
	|	SUM(ВзаиморасчетыКонтрагенты.SumBalance) AS SumBalance
	|FROM
	|	(SELECT
	|		CustomerAccountsBalance.Контрагент AS Контрагент,
	|		CustomerAccountsBalance.ВалютаРасчетов AS ВалютаРасчетов,
	|		CustomerAccountsBalance.SumBalance AS SumBalance
	|	FROM
	|		РегистрНакопления.ВзаиморасчетыКонтрагенты.Balance(
	|				&qPeriodTo,
	|				Гостиница = &qHotel
	|					OR &qHotelIsEmpty) AS CustomerAccountsBalance
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		CASE
	|			WHEN CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer
	|				THEN &qIndividualsCustomer
	|			ELSE CurrentAccountsReceivableBalance.Контрагент
	|		END,
	|		CurrentAccountsReceivableBalance.ВалютаЛицСчета,
	|		CurrentAccountsReceivableBalance.SumBalance - CurrentAccountsReceivableBalance.CommissionSumBalance
	|	FROM
	|		РегистрНакопления.РелизацияТекОтчетПериод.Balance(
	|				&qPeriodTo,
	|				&qShowCurrentAccountsReceivable
	|					AND (Гостиница = &qHotel
	|						OR &qHotelIsEmpty)) AS CurrentAccountsReceivableBalance) AS ВзаиморасчетыКонтрагенты
	|
	|GROUP BY
	|	ВзаиморасчетыКонтрагенты.Контрагент,
	|	ВзаиморасчетыКонтрагенты.ВалютаРасчетов
	|
	|ORDER BY
	|	SumBalance DESC,
	|	ВзаиморасчетыКонтрагенты.Контрагент.Description,
	|	ВзаиморасчетыКонтрагенты.ВалютаРасчетов.ПорядокСортировки";
	vQry.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница));
	vQry.SetParameter("qShowCurrentAccountsReceivable", ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница), ПараметрыСеанса.ТекущаяГостиница.ShowCurrentAccountsReceivable, Ложь));
	vQry.SetParameter("qEmptyCustomer", Справочники.Customers.EmptyRef());
	vQry.SetParameter("qIndividualsCustomer", ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница), ПараметрыСеанса.ТекущаяГостиница.IndividualsCustomer, Справочники.Customers.EmptyRef()));
	vQryResult = vQry.Execute().Unload();
	
	// Do top 5 output
	i = 0;
	vArea = vTemplate.GetArea("Debtor");
	For Each vQryResultRow In vQryResult Do
		Если i < 5 Тогда
			vArea.Parameters.mCustomer = vQryResultRow.AccountingCustomer;
			vArea.Parameters.mCustomerRef = vQryResultRow.AccountingCustomer;
			vArea.Parameters.mCurrency = cmGetCurrencyPresentation(vQryResultRow.AccountingCurrency);
			vArea.Parameters.mSum = vQryResultRow.SumBalance;
			
			pSpreadsheet.Put(vArea);
			
			i = i + 1;
		Иначе
			Break;
		КонецЕсли;
	EndDo;
	
	// Group all other customers into one row
	Если i = 5 Тогда
		// Delete top 5 rows
		i = 0;
		While i < 5 Do
			vQryResult.Delete(0);
			i = i + 1;
		EndDo;
		// Group all other
		vQryResult.GroupBy("ВалютаРасчетов", "SumBalance");
		vQryResult.Sort("SumBalance Desc");
		For Each vQryResultRow In vQryResult Do
			vArea.Parameters.mCustomer = NStr("en='<All other>';ru='<Все остальные>';de='<Alle anderen>'");
			vArea.Parameters.mCustomerRef = Неопределено;
			vArea.Parameters.mCurrency = cmGetCurrencyPresentation(vQryResultRow.AccountingCurrency);
			vArea.Parameters.mSum = vQryResultRow.SumBalance;
			
			pSpreadsheet.Put(vArea);
		EndDo;
	КонецЕсли;
КонецПроцедуры //cmFillDebtorsMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop ГруппаНомеров statuses region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillRoomStatusesMonitor(pSpreadsheet) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	vArea = vTemplate.GetArea("RoomStatusesMonitorHeader");
	pSpreadsheet.Put(vArea);
	
	// Run query
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	НомернойФонд.СтатусНомера,
	|	COUNT(НомернойФонд.СтатусНомера) AS Количество
	|FROM
	|	Catalog.НомернойФонд AS НомернойФонд
	|WHERE
	|	НомернойФонд.Owner IN HIERARCHY(&qHotel)
	|	AND (NOT НомернойФонд.IsFolder)
	|	AND (NOT НомернойФонд.DeletionMark)
	|	AND НомернойФонд.ДатаВводаЭкспл <= &qPeriod
	|	AND (НомернойФонд.ДатаВыводаЭкспл = &qEmptyDate
	|			OR НомернойФонд.ДатаВыводаЭкспл >= &qPeriod)
	|
	|GROUP BY
	|	НомернойФонд.СтатусНомера
	|
	|ORDER BY
	|	НомернойФонд.СтатусНомера.ПорядокСортировки,
	|	НомернойФонд.СтатусНомера.Description";
	vQry.SetParameter("qPeriod", BegOfDay(CurrentDate()));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Do output
	vArea = vTemplate.GetArea("СтатусНомера");
	For Each vQryResultRow In vQryResult Do
		Если ЗначениеЗаполнено(vQryResultRow.RoomStatus) Тогда
			vArea.Parameters.mRoomStatus = vQryResultRow.RoomStatus;
			vArea.Parameters.mRoomStatusRef = vQryResultRow.RoomStatus;
		Иначе
			vArea.Parameters.mRoomStatus = NStr("en='<Empty status>';ru='<Пустой статус>';de='<Leerer Status>'");
			vArea.Parameters.mRoomStatusRef = Неопределено;
		КонецЕсли;
		vArea.Parameters.mQuantity = vQryResultRow.Quantity;
		
		pSpreadsheet.Put(vArea);
	EndDo;
КонецПроцедуры //cmFillRoomStatusesMonitor

//-----------------------------------------------------------------------------
// Description: Fills main menu desktop Check-in region with data
// Parameters: Spreadsheet where to put data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillGroupStatusMonitor(pSpreadsheet, pEmployee) Экспорт
	// Clear spreadsheet
	pSpreadsheet.Clear();
	
	// Get current hotel
	вГостиница = ПараметрыСеанса.ТекущаяГостиница;
	
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	
	vArea = vTemplate.GetArea("GroupStatusesMonitorHeader");
	pSpreadsheet.Put(vArea);
	
	vArea = vTemplate.GetArea("GroupStatus");
	
	// Get list of statuses that are interesting to the sales managers
	vStatusesList = cmGetSalesGuestGroupStatuses();
	
	// Run query to get ГруппаНомеров status statistics
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	GuestGroups.Status AS Status,
	|	CASE
	|		WHEN GuestGroups.Status.IsPreliminary
	|				AND (NOT GuestGroups.Status.IsActive)
	|			THEN 1
	|		WHEN GuestGroups.Status.IsPreliminary
	|				AND GuestGroups.Status.IsActive
	|			THEN 2
	|		WHEN (NOT GuestGroups.Status.IsPreliminary)
	|				AND GuestGroups.Status.IsActive
	|			THEN 3
	|		ELSE 4
	|	END AS TypeSortOrder,
	|	GuestGroups.Status.ПорядокСортировки AS StatusSortOrder,
	|	GuestGroups.Status.Description AS StatusDescription,
	|	SUM(GuestGroups.ЗаездГостей) AS NumberOfGuests,
	|	COUNT(GuestGroups.Ref) AS NumberOfGroups
	|FROM
	|	Catalog.GuestGroups AS GuestGroups
	|WHERE
	|	(NOT GuestGroups.DeletionMark)
	|	AND GuestGroups.Owner = &qHotel
	|	AND (GuestGroups.Автор = &qEmployee
	|			OR &qEmployeeIsEmpty)
	|	AND GuestGroups.CheckInDate >= &qPeriodFrom
	|	AND GuestGroups.Status IN(&qStatuses)
	|
	|GROUP BY
	|	GuestGroups.Status,
	|	CASE
	|		WHEN GuestGroups.Status.IsPreliminary
	|				AND (NOT GuestGroups.Status.IsActive)
	|			THEN 1
	|		WHEN GuestGroups.Status.IsPreliminary
	|				AND GuestGroups.Status.IsActive
	|			THEN 2
	|		WHEN (NOT GuestGroups.Status.IsPreliminary)
	|				AND GuestGroups.Status.IsActive
	|			THEN 3
	|		ELSE 4
	|	END,
	|	GuestGroups.Status.ПорядокСортировки,
	|	GuestGroups.Status.Description
	|
	|ORDER BY
	|	TypeSortOrder,
	|	StatusSortOrder,
	|	StatusDescription";
	vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQry.SetParameter("qHotel", вГостиница);
	vQry.SetParameter("qEmployee", pEmployee);
	vQry.SetParameter("qEmployeeIsEmpty", НЕ ЗначениеЗаполнено(pEmployee));
	vQry.SetParameter("qStatuses", vStatusesList);
	vStatuses = vQry.Execute().Unload();
	
	// Do output
	vTotalGroups = 0;
	vTotalGuests = 0;
	For Each vStatusesRow In vStatuses Do
		vArea.Parameters.mGroupStatus = vStatusesRow.Status;
		vArea.Parameters.mGroups = vStatusesRow.NumberOfGroups;
		vArea.Parameters.mGuests = vStatusesRow.NumberOfGuests;
		
		vTotalGroups = vTotalGroups + vStatusesRow.NumberOfGroups;
		vTotalGuests = vTotalGuests + vStatusesRow.NumberOfGuests;
	
		pSpreadsheet.Put(vArea);
	EndDo;
	vArea = vTemplate.GetArea("GroupStatusTotals");
	vArea.Parameters.mTotalGroups = vTotalGroups;
	vArea.Parameters.mTotalGuests = vTotalGuests;
	pSpreadsheet.Put(vArea);
	
	// Fill group status diagram
	vArea = vTemplate.GetArea("GroupStatusesDiagram");
	vDiagram = vArea.Area("GroupStatusesStats").Object;
	vDiagram.RefreshEnabled = Ложь;
	vDiagram.Clear();
	vDiagram.LabelTextColor = StyleColors.FieldSelectedTextColor;
	//vGroupGuestsSeria = vDiagram.Series.Add(NStr("en='Guests q-ty';ru='Кол-во гостей';de='Gästeanzahl'"));
	vGroupCountSeria = vDiagram.Series.Add(NStr("en='Groups q-ty';ru='Кол-во групп';de='Gruppenanzahl'"));
	vGroupCountSeria.Color = StyleColors.FieldSelectionBackColor;
	vGroupCountSeria.ColorPriority = Истина;
	i = vStatuses.Count() - 1;
	While i >= 0 Do
		vStatusesRow = vStatuses.Get(i);
		vStatusPoint = vDiagram.Points.Add(СокрЛП(vStatusesRow.Status));
		vStatusPoint.Details = vStatusesRow.Status;
		vStatusPoint.Value = vStatusesRow.Status;
		vDiagram.SetValue(vStatusPoint, vGroupCountSeria, vStatusesRow.NumberOfGroups, vStatusesRow.Status, СокрЛП(vStatusesRow.Status));
		//vDiagram.SetValue(vStatusPoint, vGroupGuestsSeria, vStatusesRow.NumberOfGuests);
		i = i - 1;
	EndDo;
	vDiagram.RefreshEnabled = Истина;
	pSpreadsheet.Put(vArea);
КонецПроцедуры //cmFillGroupStatusMonitor

//-----------------------------------------------------------------------------
// Description: Shows payment method confirmation dialog when OK button is pressed
//              in payments
// Parameters: Payment document object
// Возврат value: Истина to continue document posting, Ложь to cancel operation
//-----------------------------------------------------------------------------
Функция cmConfirmPaymentMethodChoice(pObj) Экспорт
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.НастройкиПользователя) Тогда
			Если ПараметрыСеанса.ТекПользователь.НастройкиПользователя.AskForPaymentMethodConfirmation Тогда
				vQuery = NStr("ru = 'В документе выбран способ оплаты
				              |
				              |" + Upper(СокрЛП(pObj.СпособОплаты)) + ".
				              |
				              |Вы подтверждаете выбор этого способа оплаты?
				              |
				              |Ответ ""Да"" - провести документ" + ?(ЗначениеЗаполнено(pObj.Касса), " по ККМ " + Upper(СокрЛП(pObj.Касса)) + ".", ".") + "
				              |Ответ ""Нет"" - вернуться в режим редактирования документа.'; 
							  |de = 'You have choosen 
				              |
				              |" + Upper(СокрЛП(pObj.СпособОплаты)) + " Платеж method.
				              |
				              |Would you like to confirm your choice?
				              |
				              |Answer ""Yes"" to post document" + ?(ЗначениеЗаполнено(pObj.Касса), " by " + Upper(СокрЛП(pObj.Касса)) + " cash register.", ".") + "
				              |Answer ""No"" to return to the document form.';
							  |en = 'You have choosen 
				              |
				              |" + Upper(СокрЛП(pObj.СпособОплаты)) + " Платеж method.
				              |
				              |Would you like to confirm your choice?
				              |
				              |Answer ""Yes"" to post document" + ?(ЗначениеЗаполнено(pObj.Касса), " by " + Upper(СокрЛП(pObj.Касса)) + " cash register.", ".") + "
				              |Answer ""No"" to return to the document form.'");
				Если DoQueryBox(vQuery, QuestionDialogMode.YesNo, , DialogReturnCode.No) = DialogReturnCode.No Тогда
					Возврат Ложь;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат Истина;
EndFunction //cmConfirmPaymentMethodChoice

//-----------------------------------------------------------------------------
// Description: Opens current user preferences catalog item form
// Parameters: None
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmOpenCurrentUserPreferences() Экспорт
	vCurEmpPrefRef = Справочники.НастройкиПользователя.EmptyRef();
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.НастройкиПользователя) Тогда
			vCurEmpPrefRef = ПараметрыСеанса.ТекПользователь.НастройкиПользователя;
		Иначе
			// Create new one
			vCurEmpPrefObj = Справочники.НастройкиПользователя.CreateItem();
			vCurEmpPrefObj.Description = ПараметрыСеанса.ТекПользователь.Description;
			vCurEmpPrefObj.Write();
			vCurEmpPrefRef = vCurEmpPrefObj.Ref;
			
			vCurEmpObj = ПараметрыСеанса.ТекПользователь.GetObject();
			vCurEmpObj.НастройкиПользователя = vCurEmpPrefRef;
			vCurEmpObj.Write();
		КонецЕсли;
		// Open preferences item form
		Если ЗначениеЗаполнено(vCurEmpPrefRef) Тогда
			vFrm = vCurEmpPrefRef.ПолучитьФорму();
			vFrm.PasswordChangeAllowed = Истина;
			vFrm.Open();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmOpenCurrentUserPreferences

//-----------------------------------------------------------------------------
// Description: Checks if there are any active object print forms. Если yes then
//              object form "Print" button is enabled and visible, otherwise not
// Parameters: Object form, Object type (empty ref)
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmLoadFormPrintButton(pForm, pObjectType) Экспорт
	vForms = cmGetObjectPrintingForms(pObjectType, Неопределено);
	// Print button
	vButtonPrint = pForm.ЭлементыФормы.ButtonPrint;
	Если vForms.Count() = 0 Тогда
		vButtonPrint.Enabled = Ложь;
		vButtonPrint.Visible = Ложь;
	Иначе
		vButtonPrint.Enabled = Истина;
		vButtonPrint.Visible = Истина;
	КонецЕсли;
КонецПроцедуры //cmLoadFormPrintButton

//-----------------------------------------------------------------------------
// Description: Loads form action buttons defined for the given object type
// Parameters: Object form, Object type (empty ref), Если yes then no action buttons 
//             will be shown
// Возврат value: None
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Description: Processes report columns page on row output event
// Parameters: Report object, Table of report columns, Row appearance, Row data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportColumnsOnRowOutput(pRepObject, pControl, pRowAppearance, pRowData) Экспорт
	Если pRepObject.ReportColumnOverrides.Count() > 0 And 
	   pRepObject.ReportColumnOverrides.Columns.Count() > 0 Тогда
		vOverrideRow = pRepObject.ReportColumnOverrides.Find(pRowData.Name, "ColumnName");
		Если vOverrideRow <> Неопределено Тогда
			Try
				Если vOverrideRow.ColumnWidth > 0 Тогда
					Если pControl.Columns.ColumnWidth.Visible Тогда
						pRowAppearance.Cells.ColumnWidth.ShowText = Истина;
						pRowAppearance.Cells.ColumnWidth.Text = Format(vOverrideRow.ColumnWidth, "ND=6; NFD=2");
					КонецЕсли;
				КонецЕсли;
				Если ЗначениеЗаполнено(vOverrideRow.ColumnHeaderDescription) Тогда
					Если pControl.Columns.ColumnHeaderDescription.Visible Тогда
						pRowAppearance.Cells.ColumnHeaderDescription.ShowText = Истина;
						pRowAppearance.Cells.ColumnHeaderDescription.Text = СокрЛП(vOverrideRow.ColumnHeaderDescription);
					КонецЕсли;
				КонецЕсли;
				Если ЗначениеЗаполнено(vOverrideRow.ColumnFormat) Тогда
					Если pControl.Columns.ColumnFormat.Visible Тогда
						pRowAppearance.Cells.ColumnFormat.ShowText = Истина;
						pRowAppearance.Cells.ColumnFormat.Text = СокрЛП(vOverrideRow.ColumnFormat);
					КонецЕсли;
				КонецЕсли;
				Если ЗначениеЗаполнено(vOverrideRow.ColumnTextPlacement) Тогда
					Если pControl.Columns.ColumnTextPlacement.Visible Тогда
						pRowAppearance.Cells.ColumnTextPlacement.ShowText = Истина;
						pRowAppearance.Cells.ColumnTextPlacement.Text = СокрЛП(vOverrideRow.ColumnTextPlacement);
					КонецЕсли;
				КонецЕсли;
				Если pControl.Columns.Find("ShowInChart") <> Неопределено Тогда
					Если pControl.Columns.ShowInChart.Visible Тогда
						pRowAppearance.Cells.ShowInChart.CheckValue = vOverrideRow.ShowInChart;
						pRowAppearance.Cells.ShowInChart.ShowText = Истина;
						Если vOverrideRow.ShowInChart Тогда
							pRowAppearance.Cells.ShowInChart.Text = NStr("en='+'; de='+'; ru='+'");
						Иначе
							pRowAppearance.Cells.ShowInChart.Text = "";
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			Except
			EndTry;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportColumnsOnRowOutput

//-----------------------------------------------------------------------------
// Description: Processes report columns page on start edit event
// Parameters: Report object, Report settings form, Table of report columns, 
//             Если this is new row, Если this is clone operation
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportColumnsOnStartEdit(pRepObject, pRepSettingsForm, pControl, pNewRow, pClone) Экспорт
	vWithChart = Ложь;
	Если pRepSettingsForm.ЭлементыФормы.Columns.Columns.Find("ShowInChart") <> Неопределено Тогда
		vWithChart = Истина;
	КонецЕсли;
	// Check if report ReportColumnOverrides attribute is initialized
	Если pRepObject.ReportColumnOverrides.Columns.Find("ColumnName") = Неопределено Тогда
		pRepObject.ReportColumnOverrides.Columns.Add("ColumnName", cmGetStringTypeDescription());
	КонецЕсли;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ColumnWidth") = Неопределено Тогда
		pRepObject.ReportColumnOverrides.Columns.Add("ColumnWidth", cmGetNumberTypeDescription(6, 2));
	КонецЕсли;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ColumnHeaderDescription") = Неопределено Тогда
		pRepObject.ReportColumnOverrides.Columns.Add("ColumnHeaderDescription", cmGetStringTypeDescription());
	КонецЕсли;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ColumnFormat") = Неопределено Тогда
		pRepObject.ReportColumnOverrides.Columns.Add("ColumnFormat", cmGetStringTypeDescription());
	КонецЕсли;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ColumnTextPlacement") = Неопределено Тогда
		pRepObject.ReportColumnOverrides.Columns.Add("ColumnTextPlacement", cmGetEnumTypeDescription("TextPlacements"));
	КонецЕсли;
	Если vWithChart Тогда
		Если pRepObject.ReportColumnOverrides.Columns.Find("ShowInChart") = Неопределено Тогда
			pRepObject.ReportColumnOverrides.Columns.Add("ShowInChart", cmGetBooleanTypeDescription());
		КонецЕсли;
	КонецЕсли;
	// Get current column name
	vColumnName = String(pControl.CurrentRow.Name);
	Если IsBlankString(vColumnName) Тогда
		Возврат;
	КонецЕсли;
	// Try to find appropriate row in the ReportColumnOverrides value table
	vOverrideRow = pRepObject.ReportColumnOverrides.Find(vColumnName, "ColumnName");
	Если vOverrideRow <> Неопределено Тогда
		// Get override values
		vColumnWidth = vOverrideRow.ColumnWidth;
		vColumnHeaderDescription = vOverrideRow.ColumnHeaderDescription;
		vColumnFormat = vOverrideRow.ColumnFormat;
		vColumnTextPlacement = vOverrideRow.ColumnTextPlacement;
		vShowInChart = Ложь;
		Если vWithChart Тогда
			vShowInChart = vOverrideRow.ShowInChart;
		КонецЕсли;
		// Set this value to the controls
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnWidth.Control.Value = vColumnWidth;
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnHeaderDescription.Control.Value = vColumnHeaderDescription;
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnFormat.Control.Value = vColumnFormat;
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnTextPlacement.Control.Value = vColumnTextPlacement;
		Если vWithChart Тогда
			pRepSettingsForm.ЭлементыФормы.Columns.Columns.ShowInChart.Control.Value = vShowInChart;
		КонецЕсли;
	Иначе
		// Set 0 to the Columns.ColumnWidth control
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnWidth.Control.Value = 0;
		// Set "" to the Columns.ColumnHeaderDescription control
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnHeaderDescription.Control.Value = "";
		// Set "" to the Columns.ColumnFormat control
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnFormat.Control.Value = "";
		// Set Неопределено to the Columns.ColumnTextPlacement control
		pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnTextPlacement.Control.Value = Неопределено;
		// Set Ложь to the Columns.ShowInChart control
		Если vWithChart Тогда
			pRepSettingsForm.ЭлементыФормы.Columns.Columns.ShowInChart.Control.Value = Ложь;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportColumnsOnStartEdit

//-----------------------------------------------------------------------------
// Description: Processes report columns page on edit end event
// Parameters: Report object, Report settings form, Table of report columns 
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportColumnsOnEditEnd(pRepObject, pRepSettingsForm, pControl) Экспорт
	vWithChart = Ложь;
	Если pRepSettingsForm.ЭлементыФормы.Columns.Columns.Find("ShowInChart") <> Неопределено Тогда
		vWithChart = Истина;
	КонецЕсли;
	vWithShowGroupClosed = Ложь;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
		vWithShowGroupClosed = Истина;
	КонецЕсли;
	vWithShowColumnGroupClosed = Ложь;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ShowColumnGroupClosed") <> Неопределено Тогда
		vWithShowColumnGroupClosed = Истина;
	КонецЕсли;
	// Get current values
	vColumnWidth = pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnWidth.Control.Value;
	vColumnHeaderDescription = pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnHeaderDescription.Control.Value;
	vColumnFormat = pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnFormat.Control.Value;
	vColumnTextPlacement = pRepSettingsForm.ЭлементыФормы.Columns.Columns.ColumnTextPlacement.Control.Value;
	vShowInChart = Ложь;
	Если vWithChart Тогда
		vShowInChart = pRepSettingsForm.ЭлементыФормы.Columns.Columns.ShowInChart.Control.Value;
	КонецЕсли;
	// Get current column name
	vColumnName = String(pRepSettingsForm.ЭлементыФормы.Columns.CurrentRow.Name);
	Если IsBlankString(vColumnName) Тогда
		Возврат;
	КонецЕсли;
	// Try to find appropriate row in the ReportColumnOverrides value table
	vOverrideRow = pRepObject.ReportColumnOverrides.Find(vColumnName, "ColumnName");
	Если vOverrideRow <> Неопределено Тогда
		// Check that row and column groups are not overriding
		vShowGroupClosed = Ложь;
		Если vWithShowGroupClosed Тогда
			vShowGroupClosed = vOverrideRow.ShowGroupClosed;
		КонецЕсли;
		vShowColumnGroupClosed = Ложь;
		Если vWithShowColumnGroupClosed Тогда
			vShowColumnGroupClosed = vOverrideRow.ShowColumnGroupClosed;
		КонецЕсли;
		Если vColumnWidth = 0 And 
		   IsBlankString(vColumnHeaderDescription) And 
		   IsBlankString(vColumnFormat) And 
		   НЕ ЗначениеЗаполнено(vColumnTextPlacement) And 
		   НЕ vShowInChart And 
		   НЕ vShowGroupClosed And 
		   НЕ vShowColumnGroupClosed Тогда
			// Delete this row
			pRepObject.ReportColumnOverrides.Delete(vOverrideRow);
		Иначе
			// Update this row
			vOverrideRow.ColumnWidth = vColumnWidth;
			vOverrideRow.ColumnHeaderDescription = vColumnHeaderDescription;
			vOverrideRow.ColumnFormat = vColumnFormat;
			vOverrideRow.ColumnTextPlacement = vColumnTextPlacement;
			Если vWithChart Тогда
				vOverrideRow.ShowInChart = vShowInChart;
			КонецЕсли;
		КонецЕсли;
	Иначе
		Если vColumnWidth > 0 Or 
		   НЕ IsBlankString(vColumnHeaderDescription) Or 
		   НЕ IsBlankString(vColumnFormat) Or 
		   ЗначениеЗаполнено(vColumnTextPlacement) Or 
		   vShowInChart Тогда
			// Add row
			vOverrideRow = pRepObject.ReportColumnOverrides.Add();
			vOverrideRow.ColumnName = vColumnName;
			vOverrideRow.ColumnWidth = vColumnWidth;
			vOverrideRow.ColumnHeaderDescription = vColumnHeaderDescription;
			vOverrideRow.ColumnFormat = vColumnFormat;
			vOverrideRow.ColumnTextPlacement = vColumnTextPlacement;
			Если vWithChart Тогда
				vOverrideRow.ShowInChart = vShowInChart;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportColumnsOnEditEnd

//-----------------------------------------------------------------------------
// Description: Processes report row totals page on row output event
// Parameters: Report object, Table of report row totals, Row appearance, Row data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportRowTotalsOnRowOutput(pRepObject, pControl, pRowAppearance, pRowData) Экспорт
	Если pRepObject.ReportColumnOverrides.Count() > 0 And 
	   pRepObject.ReportColumnOverrides.Columns.Count() > 0 Тогда
		vOverrideRow = pRepObject.ReportColumnOverrides.Find(pRowData.Name, "ColumnName");
		Если vOverrideRow <> Неопределено Тогда
			Try
				Если pControl.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
					Если pControl.Columns.ShowGroupClosed.Visible Тогда
						pRowAppearance.Cells.ShowGroupClosed.CheckValue = vOverrideRow.ShowGroupClosed;
						pRowAppearance.Cells.ShowGroupClosed.ShowText = Истина;
						Если vOverrideRow.ShowGroupClosed Тогда
							pRowAppearance.Cells.ShowGroupClosed.Text = NStr("en='+'; ru='+'; de='+'");
						Иначе
							pRowAppearance.Cells.ShowGroupClosed.Text = "";
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			Except
			EndTry;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportRowTotalsOnRowOutput

//-----------------------------------------------------------------------------
// Description: Processes report row totals page on start edit event
// Parameters: Report object, Report settings form, Table of report row totals, 
//             Если this is new row, Если this is clone operation
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportRowTotalsOnStartEdit(pRepObject, pRepSettingsForm, pControl, pNewRow, pClone) Экспорт
	// Check if report ReportColumnOverrides attribute is initialized
	vColumnShowGroupClosed = Ложь;
	Если pRepSettingsForm.ЭлементыФормы.RowTotals.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
		vColumnShowGroupClosed = Истина;
		Если pRepObject.ReportColumnOverrides.Columns.Find("ShowGroupClosed") = Неопределено Тогда
			pRepObject.ReportColumnOverrides.Columns.Add("ShowGroupClosed", cmGetBooleanTypeDescription());
		КонецЕсли;
	КонецЕсли;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ColumnName") = Неопределено Тогда
		pRepObject.ReportColumnOverrides.Columns.Add("ColumnName", cmGetStringTypeDescription());
	КонецЕсли;
	// Get current column name
	vColumnName = String(pControl.CurrentRow.Name);
	Если IsBlankString(vColumnName) Тогда
		Возврат;
	КонецЕсли;
	// Try to find appropriate row in the ReportColumnOverrides value table
	vOverrideRow = pRepObject.ReportColumnOverrides.Find(vColumnName, "ColumnName");
	Если vOverrideRow <> Неопределено Тогда
		// Get override values
		vShowGroupClosed = Ложь;
		Если vColumnShowGroupClosed Тогда
			vShowGroupClosed = vOverrideRow.ShowGroupClosed;
			pRepSettingsForm.ЭлементыФормы.RowTotals.Columns.ShowGroupClosed.Control.Value = vShowGroupClosed;
		КонецЕсли;
	Иначе
		// Set Ложь to the RowTotals.ShowGroupClosed control
		Если vColumnShowGroupClosed Тогда
			pRepSettingsForm.ЭлементыФормы.RowTotals.Columns.ShowGroupClosed.Control.Value = Ложь;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportRowTotalsOnStartEdit

//-----------------------------------------------------------------------------
// Description: Processes report row totals page on edit end event
// Parameters: Report object, Report settings form, Table of report row totals
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportRowTotalsOnEditEnd(pRepObject, pRepSettingsForm, pControl) Экспорт
	vColumnShowGroupClosed = Ложь;
	Если pRepSettingsForm.ЭлементыФормы.RowTotals.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
		vColumnShowGroupClosed = Истина;
	КонецЕсли;
	// Get current values
	vShowGroupClosed = Ложь;
	Если vColumnShowGroupClosed Тогда
		vShowGroupClosed = pRepSettingsForm.ЭлементыФормы.RowTotals.Columns.ShowGroupClosed.Control.Value;
	КонецЕсли;
	// Get current column name
	vColumnName = String(pRepSettingsForm.ЭлементыФормы.RowTotals.CurrentRow.Name);
	Если IsBlankString(vColumnName) Тогда
		Возврат;
	КонецЕсли;
	// Try to find appropriate row in the ReportColumnOverrides value table
	vOverrideRow = pRepObject.ReportColumnOverrides.Find(vColumnName, "ColumnName");
	Если vOverrideRow <> Неопределено Тогда
		// Update this row
		Если vColumnShowGroupClosed Тогда
			vOverrideRow.ShowGroupClosed = vShowGroupClosed;
		КонецЕсли;
	Иначе
		Если vColumnShowGroupClosed Тогда
			// Add row
			vOverrideRow = pRepObject.ReportColumnOverrides.Add();
			vOverrideRow.ColumnName = vColumnName;
			Если vShowGroupClosed Тогда
				vOverrideRow.ShowGroupClosed = vShowGroupClosed;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportRowTotalsOnEditEnd

//-----------------------------------------------------------------------------
// Description: Processes report column totals page on row output event
// Parameters: Report object, Table of report column totals, Row appearance, Row data
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportColumnTotalsOnRowOutput(pRepObject, pControl, pRowAppearance, pRowData) Экспорт
	Если pRepObject.ReportColumnOverrides.Count() > 0 And 
	   pRepObject.ReportColumnOverrides.Columns.Count() > 0 Тогда
		vOverrideRow = pRepObject.ReportColumnOverrides.Find(pRowData.Name, "ColumnName");
		Если vOverrideRow <> Неопределено Тогда
			Try
				Если pControl.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
					Если pControl.Columns.ShowGroupClosed.Visible Тогда
						pRowAppearance.Cells.ShowGroupClosed.CheckValue = vOverrideRow.ShowColumnGroupClosed;
						pRowAppearance.Cells.ShowGroupClosed.ShowText = Истина;
						Если vOverrideRow.ShowColumnGroupClosed Тогда
							pRowAppearance.Cells.ShowGroupClosed.Text = NStr("en='+'; ru='+'; de='+'");
						Иначе
							pRowAppearance.Cells.ShowGroupClosed.Text = "";
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			Except
			EndTry;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportColumnTotalsOnRowOutput

//-----------------------------------------------------------------------------
// Description: Processes report column totals page on start edit event
// Parameters: Report object, Report settings form, Table of report column totals, 
//             Если this is new row, Если this is clone operation
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportColumnTotalsOnStartEdit(pRepObject, pRepSettingsForm, pControl, pNewRow, pClone) Экспорт
	// Check if report ReportColumnOverrides attribute is initialized
	vColumnShowGroupClosed = Ложь;
	Если pRepSettingsForm.ЭлементыФормы.ColumnTotals.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
		vColumnShowGroupClosed = Истина;
		Если pRepObject.ReportColumnOverrides.Columns.Find("ShowColumnGroupClosed") = Неопределено Тогда
			pRepObject.ReportColumnOverrides.Columns.Add("ShowColumnGroupClosed", cmGetBooleanTypeDescription());
		КонецЕсли;
	КонецЕсли;
	Если pRepObject.ReportColumnOverrides.Columns.Find("ColumnName") = Неопределено Тогда
		pRepObject.ReportColumnOverrides.Columns.Add("ColumnName", cmGetStringTypeDescription());
	КонецЕсли;
	// Get current column name
	vColumnName = String(pControl.CurrentRow.Name);
	Если IsBlankString(vColumnName) Тогда
		Возврат;
	КонецЕсли;
	// Try to find appropriate row in the ReportColumnOverrides value table
	vOverrideRow = pRepObject.ReportColumnOverrides.Find(vColumnName, "ColumnName");
	Если vOverrideRow <> Неопределено Тогда
		// Get override values
		vShowGroupClosed = Ложь;
		Если vColumnShowGroupClosed Тогда
			vShowGroupClosed = vOverrideRow.ShowColumnGroupClosed;
			pRepSettingsForm.ЭлементыФормы.ColumnTotals.Columns.ShowGroupClosed.Control.Value = vShowGroupClosed;
		КонецЕсли;
	Иначе
		// Set Ложь to the ColumnTotals.ShowGroupClosed control
		Если vColumnShowGroupClosed Тогда
			pRepSettingsForm.ЭлементыФормы.ColumnTotals.Columns.ShowGroupClosed.Control.Value = Ложь;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportColumnTotalsOnStartEdit

//-----------------------------------------------------------------------------
// Description: Processes report column totals page on edit end event
// Parameters: Report object, Report settings form, Table of report column totals
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportColumnTotalsOnEditEnd(pRepObject, pRepSettingsForm, pControl) Экспорт
	vColumnShowGroupClosed = Ложь;
	Если pRepSettingsForm.ЭлементыФормы.ColumnTotals.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
		vColumnShowGroupClosed = Истина;
	КонецЕсли;
	// Get current values
	vShowGroupClosed = Ложь;
	Если vColumnShowGroupClosed Тогда
		vShowGroupClosed = pRepSettingsForm.ЭлементыФормы.ColumnTotals.Columns.ShowGroupClosed.Control.Value;
	КонецЕсли;
	// Get current column name
	vColumnName = String(pRepSettingsForm.ЭлементыФормы.ColumnTotals.CurrentRow.Name);
	Если IsBlankString(vColumnName) Тогда
		Возврат;
	КонецЕсли;
	// Try to find appropriate row in the ReportColumnOverrides value table
	vOverrideRow = pRepObject.ReportColumnOverrides.Find(vColumnName, "ColumnName");
	Если vOverrideRow <> Неопределено Тогда
		// Update this row
		Если vColumnShowGroupClosed Тогда
			vOverrideRow.ShowColumnGroupClosed = vShowGroupClosed;
		КонецЕсли;
	Иначе
		Если vColumnShowGroupClosed Тогда
			// Add row
			vOverrideRow = pRepObject.ReportColumnOverrides.Add();
			vOverrideRow.ColumnName = vColumnName;
			Если vShowGroupClosed Тогда
				vOverrideRow.ShowColumnGroupClosed = vShowGroupClosed;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmReportColumnTotalsOnEditEnd

//-----------------------------------------------------------------------------
// Description: Shows edit report column format string dialog
// Parameters: Report object, Report settings form, Table of report columns 
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReportColumnsColumnFormatStartChoice(pRepObject, pRepSettingsForm, pControl) Экспорт
	vFormatWizard = Неопределено;
	vFormat = pControl.Value;
	Если IsBlankString(vFormat) Тогда
		vFormatWizard = Новый FormatStringWizard();
	Иначе
		vFormatWizard = Новый FormatStringWizard(vFormat);
	КонецЕсли;
	Если vFormatWizard.DoModal() Тогда
		pControl.Value = vFormatWizard.Text;
	КонецЕсли;
КонецПроцедуры //cmReportColumnsColumnFormatStartChoice

//-----------------------------------------------------------------------------
// Description: Returns picture index of the given ГруппаНомеров status
// Parameters: ГруппаНомеров status 
// Возврат value: Number
//-----------------------------------------------------------------------------
Функция cmGetRoomStatusIconIndex(pRoomStatus) Экспорт
	vPictureIndex = 6;
	Если ЗначениеЗаполнено(pRoomStatus) Тогда
		Если ЗначениеЗаполнено(pRoomStatus.RoomStatusIcon) Тогда
			Если pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Occupied Тогда
				vPictureIndex = 3;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Reserved Тогда
				vPictureIndex = 7;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Waiting Тогда
				vPictureIndex = 2;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.TidyingUp Тогда
				vPictureIndex = 1;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.ВыездФакт Тогда
				vPictureIndex = 4;
			ElsIf pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Vacant Тогда
				vPictureIndex = 5;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vPictureIndex;
EndFunction //cmGetRoomStatusIconIndex

//-----------------------------------------------------------------------------
// Description: Returns icon of the given reservation status
// Parameters: Reservation status 
// Возврат value: Picture object
//-----------------------------------------------------------------------------
Функция cmGetReservationStatusIcon(pReservationStatus, pParentDoc = Неопределено) Экспорт
	vPicture = PictureLib.Empty;
	Если ЗначениеЗаполнено(pReservationStatus) Тогда
		Если pReservationStatus.IsActive Тогда
			Если ЗначениеЗаполнено(pParentDoc) Тогда
				vPicture = PictureLib.MoveRightAll;
			ElsIf pReservationStatus.IsGuaranteed Тогда
				vPicture = PictureLib.РегистрНакопления;
			Иначе
				vPicture = PictureLib.IsActive;
			КонецЕсли;
		ElsIf pReservationStatus.ЭтоЗаезд Тогда
			vPicture = PictureLib.ЭтоЗаезд;
		ElsIf pReservationStatus.IsNoShow Тогда
			vPicture = PictureLib.Attention;
		ElsIf pReservationStatus.IsPreliminary Тогда
			vPicture = PictureLib.IsPreliminary;
		Иначе
			vPicture = PictureLib.IsNotActive;
		КонецЕсли;
	КонецЕсли;
	Возврат vPicture;
EndFunction //cmGetReservationStatusIcon

//-----------------------------------------------------------------------------
// Description: Returns icon of the given resource reservation status
// Parameters: Resource reservation status 
// Возврат value: Picture object
//-----------------------------------------------------------------------------
Функция cmGetResourceReservationStatusIcon(pResourceReservationStatus) Экспорт
	vPicture = PictureLib.Empty;
	Если ЗначениеЗаполнено(pResourceReservationStatus) Тогда
		Если pResourceReservationStatus.IsActive Тогда 
			Если pResourceReservationStatus.ServicesAreDelivered Тогда
				vPicture = PictureLib.Pin;
			ElsIf pResourceReservationStatus.DoCharging Тогда
				vPicture = PictureLib.РегистрНакопления;
			ElsIf pResourceReservationStatus.IsGuaranteed Тогда
				vPicture = PictureLib.CheckMark;
			Иначе
				vPicture = PictureLib.IsActive;
			КонецЕсли;
		Иначе
			vPicture = PictureLib.IsNotActive;
		КонецЕсли;
	КонецЕсли;
	Возврат vPicture;
EndFunction //cmGetResourceReservationStatusIcon

//-----------------------------------------------------------------------------
// Description: Returns icon of the given accommodation status
// Parameters: Accommodation status 
// Возврат value: Picture object
//-----------------------------------------------------------------------------
Функция cmGetAccommodationStatusIcon(pAccommodationStatus) Экспорт
	vPicture = PictureLib.Empty;
	Если ЗначениеЗаполнено(pAccommodationStatus) Тогда
		Если pAccommodationStatus.Действует Тогда
			Если pAccommodationStatus.ЭтоЗаезд And pAccommodationStatus.ЭтоГости Тогда
				vPicture = PictureLib.CheckIn;
			ElsIf pAccommodationStatus.IsRoomChange And pAccommodationStatus.ЭтоГости Тогда
				vPicture = PictureLib.ПереселениеНомер;
			Иначе
				vPicture = PictureLib.ВыездФакт;
			КонецЕсли;
		Иначе
			vPicture = PictureLib.IsNotActive;
		КонецЕсли;
	КонецЕсли;
	Возврат vPicture;
EndFunction //cmGetAccommodationStatusIcon

//-----------------------------------------------------------------------------
// Description: Returns client sex icon
// Parameters: Client
// Возврат value: Picture object
//-----------------------------------------------------------------------------
Функция cmGetClientSexIcon(pClientRef) Экспорт
	vPicture = PictureLib.NaturalPerson;
	Если ЗначениеЗаполнено(pClientRef) And ЗначениеЗаполнено(pClientRef.Пол) Тогда
		Если pClientRef.Пол = Перечисления.Пол.Мужской Тогда
			vPicture = PictureLib.Male;
		Иначе
			vPicture = PictureLib.Female;
		КонецЕсли;
	КонецЕсли;
	Возврат vPicture;
EndFunction //cmGetClientSexIcon

//-----------------------------------------------------------------------------
// Description: Writes to the main menu "Last visited objects list" 
// Parameters: Persistent objects application structure, Object reference
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmWriteToLastVisitedObjects(pPersistentObjects, pObjectRef) Экспорт
	Если ЗначениеЗаполнено(pObjectRef) Тогда
		vLastVisitedObjects = Неопределено;
		Если pPersistentObjects.Property("ПослИсполОбъекты", vLastVisitedObjects) Тогда
			Если TypeOf(vLastVisitedObjects) = Тип("ValueTable") Тогда
				// Try to find this object in the list
				vObjectRow = vLastVisitedObjects.Find(pObjectRef, "LastVisitedObject");
				Если vObjectRow <> Неопределено Тогда
					// Delete this row from the list
					vLastVisitedObjects.Delete(vObjectRow);
				КонецЕсли;
				// Add new last row
				vLastVisitedObjectsRow = vLastVisitedObjects.Вставить(0);
				vLastVisitedObjectsRow.Period = CurrentDate();
				vLastVisitedObjectsRow.LastVisitedObject = pObjectRef;
				// Remove last row from the end
				Если vLastVisitedObjects.Count() > 50 Тогда
					vLastVisitedObjects.Delete(vLastVisitedObjects.Count() - 1);
				КонецЕсли;
				// Save last visited value table to the employee item
				Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
					vEmployeeObject = ПараметрыСеанса.ТекПользователь.GetObject();
					vEmployeeObject.Read();
					vEmployeeObject.ПослИсполОбъекты = Новый ValueStorage(vLastVisitedObjects);
					Try
						vEmployeeObject.Write();
					Except
					EndTry;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmWriteToLastVisitedObjects

//-----------------------------------------------------------------------------
// Description: Returns object presentation string for the "Last visited objects list" 
// Parameters: Object reference
// Возврат value: String to be shown in the list for the given object
//-----------------------------------------------------------------------------
Функция cmGetObjectPresentation(pObjectRef) Экспорт
	vPresentation = Новый Structure("Icon, Text", PictureLib.Empty, "");
	Если ЗначениеЗаполнено(pObjectRef) Тогда
		Если TypeOf(pObjectRef) = Тип("DocumentRef.Бронирование") Тогда
			vPresentation.Icon = cmGetReservationStatusIcon(pObjectRef.ReservationStatus, pObjectRef.ДокОснование);
			vPresentation.Text = СокрЛП(pObjectRef.ReservationStatus) + Chars.LF + 
			                     СокрЛП(pObjectRef.ГруппаГостей) + ", " + 
			                     СокрЛП(pObjectRef.Гость) + ", " + СокрЛП(pObjectRef.НомерРазмещения) + Chars.LF + 
			                     СокрЛП(pObjectRef.Контрагент);
		ElsIf TypeOf(pObjectRef) = Тип("ДокументСсылка.Размещение") Тогда
			vPresentation.Icon = cmGetAccommodationStatusIcon(pObjectRef.СтатусРазмещения);
			vPresentation.Text = СокрЛП(pObjectRef.СтатусРазмещения) + Chars.LF + 
			                     СокрЛП(pObjectRef.ГруппаГостей) + ", " + 
			                     СокрЛП(pObjectRef.Гость) + ", " + СокрЛП(pObjectRef.НомерРазмещения) + Chars.LF + 
			                     СокрЛП(pObjectRef.Контрагент);
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.БроньУслуг") Тогда
			vPresentation.Icon = cmGetResourceReservationStatusIcon(pObjectRef.ResourceReservationStatus);
			vPresentation.Text = СокрЛП(pObjectRef.ResourceReservationStatus) + Chars.LF + 
			                     СокрЛП(pObjectRef.ГруппаГостей) + ", " + 
			                     СокрЛП(pObjectRef.Клиент) + ", " + СокрЛП(pObjectRef.Ресурс) + Chars.LF + 
			                     СокрЛП(pObjectRef.Контрагент);
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.РегистрацияУслуги") Тогда
			vPresentation.Icon = PictureLib.GeographicalSchema;
			vPresentation.Text = СокрЛП(pObjectRef.Клиент) + Chars.LF + 
			                     СокрЛП(pObjectRef.Citizenship);
		ElsIf TypeOf(pObjectRef) = Тип("СправочникСсылка.Клиенты") Тогда
			vPresentation.Icon = cmGetClientSexIcon(pObjectRef);
			vPresentation.Text = СокрЛП(pObjectRef.FullName) + ", " + 
			                     Format(pObjectRef.ДатаРождения, "DF=dd.MM.yyyy");
		ElsIf TypeOf(pObjectRef) = Тип("СправочникСсылка.Клиенты") Тогда
			vPresentation.Icon = PictureLib.Контрагент;
			vPresentation.Text = СокрЛП(pObjectRef.Description);
		ElsIf TypeOf(pObjectRef) = Тип("СправочникСсылка.Договора") Тогда
			vPresentation.Icon = PictureLib.Appointment;
			vPresentation.Text = СокрЛП(pObjectRef.Description);
		ElsIf TypeOf(pObjectRef) = Тип("СправочникСсылка.ТипыКонтрагентов") Тогда
			vPresentation.Icon = PictureLib.Клиенты;
			vPresentation.Text = СокрЛП(pObjectRef.Code) + Chars.LF + СокрЛП(pObjectRef.Description);
		ElsIf TypeOf(pObjectRef) = Тип("СправочникСсылка.ПутевкиКурсовки") Тогда
			vPresentation.Icon = PictureLib.PeriodWeek;
			vPresentation.Text = СокрЛП(pObjectRef.Description);
		ElsIf TypeOf(pObjectRef) = Тип("CatalogRef.НомернойФонд") Тогда
			Если НЕ pObjectRef.IsFolder Тогда
				vPresentation.Icon = PictureLib.НомернойФонд;
				vPresentation.Text = СокрЛП(pObjectRef.Description) + " " + 
				                     ?(ЗначениеЗаполнено(pObjectRef.ТипНомера), СокрЛП(pObjectRef.ТипНомера.Code), "");
			КонецЕсли;
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.СчетПроживания") Тогда
			vPresentation.Icon = PictureLib.Calculator;
			vPresentation.Text = СокрЛП(pObjectRef.Номер) + Chars.LF + 
			                     СокрЛП(pObjectRef.НомерРазмещения) + " " + 
								 СокрЛП(pObjectRef.Клиент) + Chars.LF + 
 			                     СокрЛП(pObjectRef.Description);
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.СчетНаОплату") Тогда
			vPresentation.Icon = PictureLib.DocumentObject;
			vPresentation.Text = СокрЛП(pObjectRef.Номер) + " " + 
			                     СокрЛП(pObjectRef.Фирма) + Chars.LF + pObjectRef.Сумма;
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.Акт") Тогда
			vPresentation.Icon = PictureLib.Deal;
			vPresentation.Text = СокрЛП(pObjectRef.Номер) + " " + 
			                     СокрЛП(pObjectRef.Фирма) + Chars.LF + pObjectRef.Сумма;
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.ПлатежКонтрагента") Тогда
			vPresentation.Icon = PictureLib.РегистрНакопления;
			vPresentation.Text = СокрЛП(pObjectRef.Номер) + " " + 
			                     СокрЛП(pObjectRef.Фирма) + Chars.LF + pObjectRef.Сумма;
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.РаспределениеАванса") Тогда
			vPresentation.Icon = PictureLib.РегистрНакопления;
			vPresentation.Text = СокрЛП(pObjectRef.Номер) + " " + 
			                     СокрЛП(pObjectRef.Фирма) + Chars.LF + pObjectRef.GuestGroups.Total("Сумма");
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.БлокНомер") Тогда
			vPresentation.Icon = PictureLib.Stop;
			vPresentation.Text = СокрЛП(pObjectRef.НомерРазмещения) + " - " + СокрЛП(pObjectRef.RoomBlockType);
		ElsIf TypeOf(pObjectRef) = Тип("DocumentRef.ПланРабот") Тогда
			vPresentation.Icon = PictureLib.PeriodDay;
			vPresentation.Text = Format(pObjectRef.ДатаДок, "DLF=DD");
		Иначе
			vPresentation.Text = String(pObjectRef);
		КонецЕсли;
		vPresentation.Text = СокрЛП(vPresentation.Text);
	КонецЕсли;
	Возврат vPresentation;
EndFunction //cmGetObjectPresentation

//-----------------------------------------------------------------------------
// Description: Checks user rights to add/remove report columns
// Parameters: Report settings form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetReportSettingsAvailability(pSettingsForm) Экспорт
	Если НЕ cmCheckUserPermissions("HavePermissionToManageReportColumns") Тогда
		pSettingsForm.ЭлементыФормы.Columns.ChangeRowSet = Ложь;
		pSettingsForm.ЭлементыФормы.Columns.Columns.Field.ReadOnly = Истина;
		pSettingsForm.ЭлементыФормы.CommandBarColumns.Buttons.ActionLoadDefaultColumns.Enabled = Ложь;
	Иначе
		pSettingsForm.ЭлементыФормы.Columns.ChangeRowSet = Истина;
		pSettingsForm.ЭлементыФормы.Columns.Columns.Field.ReadOnly = Ложь;
		pSettingsForm.ЭлементыФормы.CommandBarColumns.Buttons.ActionLoadDefaultColumns.Enabled = Истина;
	КонецЕсли;
КонецПроцедуры //cmSetReportSettingsAvailability

//-----------------------------------------------------------------------------
// Описание: изменяет заголовок окна приложения
// Параметры: Гостиница
// Значение Возврат: нет
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Description: Sets height of the choice forms to the main menu form height
// Parameters: Choice form, Main menu form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetChoiceFormHeight(pChoiceForm, pMainMenuForm) Экспорт
	vDefaultChoiceFormHeight = pMainMenuForm.Height - 50;
	Если vDefaultChoiceFormHeight > pChoiceForm.Height Тогда
		pChoiceForm.Height = vDefaultChoiceFormHeight;
	КонецЕсли;
КонецПроцедуры //cmSetChoiceFormHeight

//-----------------------------------------------------------------------------
// Description: Sets width of the item forms slightly less then main menu form width 
// Parameters: Item form, Main menu form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetWideItemFormWidth(pForm, pMainMenuForm) Экспорт
	vDefaultFormWidth = pMainMenuForm.Width - 200;
	Если vDefaultFormWidth > 960 Тогда
		vDefaultFormWidth = 960;
	КонецЕсли;
	Если vDefaultFormWidth > pForm.Width Тогда
		pForm.Width = vDefaultFormWidth;
	КонецЕсли;
КонецПроцедуры //cmSetWideItemFormWidth

//-----------------------------------------------------------------------------
// Description: Checks whether scheduled jobs manager is running or not
// Parameters: None
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmCheckScheduledJobsAgentState() Экспорт
	Если IsInRole("Administrator") Тогда
		vIsHanging = Истина;
		Try
			vBackgroundJobs = BackgroundJobs.GetBackgroundJobs();
			Если vBackgroundJobs.Count() > 0 Тогда
				vIsHanging = Ложь;
			КонецЕсли;
		Except
		EndTry;
		Если vIsHanging Тогда
			vMessage = NStr("en='Background jobs manager is likely in a ""hanging"" state! Please check background jobs console and ask your system administrator to restart 1C:Enterprise application server if background jobs list is empty!';
			                |ru='Менеджер фоновых заданий возможно ""завис"" и не работает! Пожалуйста проверьте консоль фоновых заданий и, если список фоновых заданий (нижний список) пуст, обратитесь к системному администратору и перезапустите сервер приложений 1С:Предприятия.';
							|de='Hintergrundaufgaben-Manager ""hängt"" möglicherweise und funktioniert nicht. Prüfen Sie bitte die Konsole der Hintergrundaufgaben  und, wenn die Liste der Hintergrundaufgaben (untere Liste) leer ist, wenden Sie sich an den Systemadministrator und starten Sie den Anwendungsserver 1C:Unternehmen neu.'");
			WriteLogEvent(NStr("en='ScheduledJobsManagerStateCheck';ru='ПроверкаСостоянияМенеджераФоновыхЗаданий';de='ScheduledJobsManagerStateCheck'"), EventLogLevel.Warning, , , vMessage);
			Message(vMessage, MessageStatus.Important);
			Предупреждение(vMessage, 60);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmCheckScheduledJobsAgentState

//-----------------------------------------------------------------------------
// Description: Returns true if scheduled jobs manager is running, false otherwise
// Parameters: None
// Возврат value: None
//-----------------------------------------------------------------------------
Функция cmGetScheduledJobsAgentState() Экспорт
	vIsRunning = Истина;
	
	Try
		Если vIsRunning Тогда
			// Restart processing if this is the only client running
			vThereAreOtherThickSessions = Ложь;
			vCurSessionNumber = InfoBaseSessionNumber();
			vActiveConnections = GetInfoBaseConnections();
			For Each vActiveConnection In vActiveConnections Do
				Если vCurSessionNumber <> vActiveConnection.SessionNumber Тогда
					Если СокрЛП(vActiveConnection.ApplicationName) = "1CV8" Тогда
						vThereAreOtherThickSessions = Истина;
						Break;
					КонецЕсли;
				КонецЕсли;
			EndDo;
			Если НЕ vThereAreOtherThickSessions Тогда
				vIsRunning = Ложь;
			КонецЕсли;
		КонецЕсли;
	Except
	EndTry;
	Возврат vIsRunning;
EndFunction //cmGetScheduledJobsAgentState

//-----------------------------------------------------------------------------
// Description: Returns icon of the external interface type (TV, Phone, Internet, e.t.c)
// Parameters: Interface type enum item
// Возврат value: Picture
//-----------------------------------------------------------------------------
Функция cmGetInterfaceTypePicture(pInterfaceType) Экспорт
	Если pInterfaceType = Перечисления.InterfaceTypes.Internet Тогда
		Возврат PictureLib.HTMLPage;
	ElsIf pInterfaceType = Перечисления.InterfaceTypes.Minibar Тогда
		Возврат PictureLib.Minibar;
	ElsIf pInterfaceType = Перечисления.InterfaceTypes.Телефон Тогда
		Возврат PictureLib.Телефон;
	ElsIf pInterfaceType = Перечисления.InterfaceTypes.TV Тогда
		Возврат PictureLib.TV;
	Иначе
		Возврат PictureLib.Empty;
	КонецЕсли;
EndFunction //cmGetInterfaceTypePicture

//-----------------------------------------------------------------------------
// Description: Saves current report settings to the report catalog item value storage
// Parameters: Report object, Report settings form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSaveAsDefaultReportSettings(pReportObject, pReportSettingsForm) Экспорт
	Если ЗначениеЗаполнено(pReportObject.Report) Тогда
		pReportObject.pmSaveReportAttributes();
		pReportSettingsForm.Modified = Ложь;
		vFileName = GetTempFileName("xml");
		cmWriteReportSettingsToFile(pReportObject.Report, vFileName);
		vFileReader = Новый TextReader(vFileName, TextEncoding.UTF8);
		vXMLData = vFileReader.Read();
		vFileReader.Close();
		vRepObj = pReportObject.Report.GetObject();
		vRepObj.DefaultSettings = Новый ValueStorage(vXMLData);
		vRepObj.Write();
	Иначе
		ShowMessageBox(Неопределено, NStr("en='Use menu option <Save current form attributes to existing setting> first!';
		                  |ru='Сначала выполните пункт меню <Сохранить параметры в существующую настройку>!';
						  |de='Zuerst im Menü den Punkt <Alle Parameter in den existierenden Einstellungen speichern> ausführen!'"));
	КонецЕсли;
КонецПроцедуры //SaveAsDefaultReportSettingsAction

//-----------------------------------------------------------------------------
// Description: Loads default report settings from the report binary template or from
//              report catalog item value storage
// Parameters: Report object, Report settings form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmLoadDefaultReportSettings(pReportObject, pReportSettingsForm = Неопределено) Экспорт
	vDefaultSettings = Неопределено;
	Если НЕ ЗначениеЗаполнено(pReportObject.Report) Тогда
		Предупреждение(NStr("en='Use menu option <Save current form attributes to existing setting> first!';
		                  |ru='Сначала выполните пункт меню <Сохранить параметры в существующую настройку>!';
						  |de='Zuerst im Menü den Punkt <Alle Parameter in den existierenden Einstellungen speichern> ausführen!'"));
		Возврат;
	КонецЕсли;
	Если pReportObject.Report.DefaultSettings <> Неопределено Тогда
		// Read settings from the report catalog item value storage
		vDefaultSettings = pReportObject.Report.DefaultSettings.Get();
		Если TypeOf(vDefaultSettings) <> Тип("String") Тогда
			// Read settings from the report binary template if found
			Try
				vFileName = GetTempFileName("xml");
				pReportObject.GetTemplate("DefaultSettings").Write(vFileName);
				vFileReader = Новый TextReader(vFileName, TextEncoding.UTF8);
				vDefaultSettings = vFileReader.Read();
				vFileReader.Close();
			Except
			EndTry;
		КонецЕсли;
	КонецЕсли;
	Если TypeOf(vDefaultSettings) <> Тип("String") Тогда
		Предупреждение(NStr("en='Default report settings are not filled!';
		                  |ru='Настройки отчета по умолчанию не заполнены!';
		                  |de='Standardeinstellungen des Berichts sind nicht ausgefüllt!'"));
		Возврат;
	КонецЕсли;
	vFileName = GetTempFileName("xml");
	vFileWriter = Новый TextWriter(vFileName, TextEncoding.UTF8);
	vFileWriter.Write(vDefaultSettings);
	vFileWriter.Close();
	// Update report object
	vRepObj = pReportObject.Report.GetObject();
	cmReadReportSettingsFromFile(vRepObj, vFileName);
	vRepObj.Write();
	// Reload report attribuets from the catalog item
	pReportObject.pmLoadReportAttributes();
	// Set attributes command bar buttons appearance
	Если pReportSettingsForm <> Неопределено Тогда
		pReportSettingsForm.fmCommandBarAttributesAppearance();
	КонецЕсли;
КонецПроцедуры //cmLoadDefaultReportSettings
	
//-----------------------------------------------------------------------------
// Description: Opens default data processor's form
// Parameters: Data processors catalog folder or item
// Возврат value: Истина if form was opened successfully, Ложь if not
//-----------------------------------------------------------------------------
Функция cmOpenDataProcessorForm(pDataProcessor, pParameter = Неопределено) Экспорт
	Try
		// Initialize list of data processors to run
		vDPs = cmGetListOfDataProcessorsToRun(pDataProcessor);
		// Run each data processor from the list
		For Each vDPRow In vDPs Do
			// Check user rights to execute data processor
			Если НЕ cmCheckUserRightsToExecuteDataProcessor(vDPRow.DataProcessor) Тогда
				ВызватьИсключение "У вас нет прав на запуск обработки" + vDPRow.DataProcessor.Description + "!";
			КонецЕсли;
			vDPObj = cmBuildDataProcessorObject(vDPRow.DataProcessor);
			Если vDPObj <> Неопределено Тогда
				// Fill reference to the data processor catalog item
				Try
					vDPObj.DataProcessor = vDPRow.DataProcessor;
				Except
				EndTry;
				// Open data processor's default form
				Try
					vDPFrm = vDPObj.ПолучитьФорму();
					vDPFrm.Open();
				Except
					vDPFrm = ПолучитьФорму("DataProcessor." + СокрЛП(vDPObj.DataProcessor.Processing) + ".Form");
					vObj = FormDataToValue(vDPFrm.Object, Тип("DataProcessorObject."+СокрЛП(vDPObj.DataProcessor.Processing)));
					vObj.DataProcessor = vDPObj.DataProcessor;
					ValueToFormData(vObj, vDPFrm.Object);
					vDPFrm.DoModal();
				EndTry;
			КонецЕсли;
		EndDo;
		Возврат Истина;
	Except
		vErrorDescription = ErrorDescription();
		vMessage = "Ошибка выполнения обработки " + pDataProcessor.Description+ ПараметрыСеанса.ТекЛокализация + "! Описание ошибки: "+ vErrorDescription;
		WriteLogEvent(NStr("en='DataProcessor.Run';ru='Обработка.Выполнить';de='DataProcessor.Run'"), EventLogLevel.Warning, Metadata.Справочники.Обработки, pDataProcessor, vMessage);
		Message(vMessage, MessageStatus.Attention);
		Возврат Ложь;
	EndTry;
EndFunction //cmOpenDataProcessorForm
