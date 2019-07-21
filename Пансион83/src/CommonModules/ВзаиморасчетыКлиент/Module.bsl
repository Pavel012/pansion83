//-----------------------------------------------------------------------------
// Описание: создает или находит кредитную карту по данным, считываемым с карты 
// Parameters: Card track 2 data, владелец карты, флаг создания новой карты или нет, если она не найдена
// Возвращаемое значение: ссылка на кредитную карту
//-----------------------------------------------------------------------------
Function cmGetCreditCardByText(pText, pCardOwner, pCreateNew = False, pPaymentMethod = Неопределено) Экспорт
	// Check card owner
	Если НЕ ЗначениеЗаполнено(pCardOwner) Тогда
		Return Справочники.КредитныеКарты.EmptyRef();
	EndIf;
	Try
		// Parse credit card data to fields
		vCardData = cmParseCreditCardData(pText);
		Если pPaymentMethod <> Неопределено Тогда
			Если ЗначениеЗаполнено(pPaymentMethod.CardType) Тогда
				vCardData.CardType = pPaymentMethod.CardType;
			EndIf;
			Если ЗначениеЗаполнено(pPaymentMethod.CardOwner) Тогда
				vCardData.CardOwner = pPaymentMethod.CardOwner;
			EndIf;
		EndIf;
		// Получить номер карты
		vCardNumber = vCardData.CardNumber;
		// Search cards with given owner and number
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	КредитныеКарты.Ref AS CreditCard
		|FROM
		|	Catalog.КредитныеКарты AS CreditCards
		|WHERE
		|	КредитныеКарты.CardOwner = &qCardOwner
		|	AND КредитныеКарты.CardNumber = &qCardNumber
		|	AND КредитныеКарты.DeletionMark = FALSE";
		vQry.SetParameter("qCardOwner", pCardOwner);
		vQry.SetParameter("qCardNumber", vCardNumber);
		vCards = vQry.Execute().Unload();
		Если vCards.Count() > 0 Тогда
			// Return first found
			Return vCards.Get(0).CreditCard;
		Else
			// Create new card if necessary
			Если pCreateNew Тогда
				Если НЕ ЗначениеЗаполнено(vCardData.CardHolder) Or НЕ ЗначениеЗаполнено(vCardData.CardType) Тогда
					vCardObj = Справочники.КредитныеКарты.CreateItem();
					vCardObj.Description = cmGetCreditCardDescription(vCardNumber);
					FillPropertyValues(vCardObj, vCardData);
					Если НЕ ЗначениеЗаполнено(vCardObj.CardOwner) Тогда
						vCardObj.CardOwner = pCardOwner;
					EndIf;
					vCardObj.Автор = ПараметрыСеанса.ТекПользователь;
					vCardObj.CreateDate = CurrentDate();
					// Open card item form
					vFrm = vCardObj.ПолучитьФорму();
					vFrm.DoModal();
					// Check that card was saved
					vCardIsSaved = False;
					Try
						vCardObj.Read();
						Если НЕ vCardObj.ЭтоНовый() Тогда
							vCardIsSaved = True;
						EndIf;
					Except
					EndTry;
					Если НЕ vCardIsSaved Тогда
						Return Справочники.КредитныеКарты.EmptyRef();
					Else
						Return vCardObj.Ref;
					EndIf;
				Else
					vCardObj = Справочники.КредитныеКарты.CreateItem();
					vCardObj.Description = cmGetCreditCardDescription(vCardNumber);
					FillPropertyValues(vCardObj, vCardData);
					Если НЕ ЗначениеЗаполнено(vCardObj.CardOwner) Тогда
						vCardObj.CardOwner = pCardOwner;
					EndIf;
					vCardObj.Автор = ПараметрыСеанса.ТекПользователь;
					vCardObj.CreateDate = CurrentDate();
					vCardObj.Write();
					Return vCardObj.Ref;
				EndIf;
			Else
				Return Справочники.КредитныеКарты.EmptyRef();
			EndIf;
		EndIf;
	Except
		vErrInfo = ErrorInfo();
		WriteLogEvent(NStr("en='CreditCards.GetCreditCardByText';ru='КредитныеКарты.GetCreditCardByText';de='Kreditkarten.GetCreditCardByText'"), EventLogLevel.Warning, Metadata.Справочники.КредитныеКарты, , cmGetRootErrorDescription(vErrInfo));
		ShowErrorInfo(vErrInfo);
		Return Справочники.КредитныеКарты.EmptyRef();
	EndTry;
EndFunction //cmGetCreditCardByText

//-----------------------------------------------------------------------------
// Description: Function calls Контрагент accounts detailed or short balances report
// Parameters: Контрагент, Contract, Guest group, Currency, Фирма, Гостиница, 
//             Start of report period date, End of report period date,
//             Object printing form reference, Call is in the automatic mode flag
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmPrintCustomerAccountingBalances(pCustomer, pContract, pGuestGroup = Неопределено, 
                                            pCurrency = Неопределено, pCompany = Неопределено, pHotel = Неопределено, 
                                            pPeriodFrom = Неопределено, pPeriodTo = Неопределено, 
                                            pForm = Неопределено, pIsInAutomaticMode = False) Экспорт
	vRepItem = pForm.Report;
	Если НЕ ЗначениеЗаполнено(vRepItem) Тогда
		Если pForm = Справочники.ПечатныеФормы.CustomerPrintBalances Тогда
			vRepItem = Справочники.Отчеты.ВзаиморасчетыКонтрагенты;
		Else
			vRepItem = Справочники.Отчеты.CustomerAccountsDetails;
		EndIf;
	EndIf;
	Если НЕ cmCheckUserRightsToOpenReport(vRepItem) Тогда
		ВызватьИсключение "У вас нет прав на формирование отчета: " + vRepItem.Description + "!";
	EndIf;
	vRepObj = cmBuildReportObject(vRepItem);
	Если vRepObj <> Неопределено Тогда
		// Load report catalog item attributes
		vRepObj.Report = pForm.Report;
		Если НЕ ЗначениеЗаполнено(vRepObj.Report) Тогда
			vRepObj.Report = vRepItem;
		EndIf;
		// Open report's default form
		vRepFrm = vRepObj.ПолучитьФорму();
		vRepFrm.GenerateOnFormOpen = False;
		vRepFrm.Open();
		// Set report attributes from parameters
		vRepObj.Фирма = pCompany;
		vRepObj.Контрагент = pCustomer;
		vRepObj.Договор = pContract;
		vRepObj.ГруппаГостей = pGuestGroup;
		vRepObj.Валюта = pCurrency;
		vRepObj.Гостиница = pHotel;
		vRepObj.ПериодС = pPeriodFrom;
		vRepObj.ПериодПо = pPeriodTo;
		If ЗначениеЗаполнено(vRepObj.Гостиница) Тогда
			vRepObj.ShowCurrentAccountsReceivable = vRepObj.Гостиница.ShowCurrentAccountsReceivable;
		EndIf;
		// Generate report
		vRepFrm.fmGenerateReport();
	EndIf;
КонецПроцедуры //cmPrintCustomerAccountingBalances

//-----------------------------------------------------------------------------
// Description: Function calls invoice balances report
// Parameters: Контрагент, Contract, Guest group, Currency, Фирма, Гостиница, 
//             Start of report period date, End of report period date,
//             Object printing form reference, Call is in the automatic mode flag
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmPrintInvoicesBalances(pCustomer, pContract, pGuestGroup = Неопределено, 
                                  pCurrency = Неопределено, pCompany = Неопределено, pHotel = Неопределено, 
                                  pPeriodFrom = Неопределено, pPeriodTo = Неопределено, pShowExpiredInvoicesOnly = False, 
                                  pForm = Неопределено, pIsInAutomaticMode = False) Экспорт
	vRepItem = Справочники.Отчеты.ВзаиморасчетыПоСчетам;
	If ЗначениеЗаполнено(pForm) And ЗначениеЗаполнено(pForm.Report) Тогда
		vRepItem = pForm.Report;
	EndIf;
	If НЕ cmCheckUserRightsToOpenReport(vRepItem) Тогда
		ВызватьИсключение("У вас нет прав на формирование отчета: " + vRepItem.Description + "!");
	EndIf;
	vRepObj = cmBuildReportObject(vRepItem);
	If vRepObj <> Неопределено Тогда
		// Load report catalog item attributes
		vRepObj.Report = vRepItem;
		// Open report's default form
		vRepFrm = vRepObj.ПолучитьФорму();
		vRepFrm.GenerateOnFormOpen = False;
		vRepFrm.Open();
		// Set report attributes from parameters
		vRepObj.Фирма = pCompany;
		vRepObj.Контрагент = pCustomer;
		vRepObj.Договор = pContract;
		vRepObj.ГруппаГостей = pGuestGroup;
		vRepObj.Валюта = pCurrency;
		vRepObj.Гостиница = pHotel;
		vRepObj.ПериодС = pPeriodFrom;
		vRepObj.ПериодПо = pPeriodTo;
		vRepObj.ShowExpiredInvoicesOnly = pShowExpiredInvoicesOnly;
		// Generate report
		vRepFrm.fmGenerateReport();
	EndIf;
КонецПроцедуры //cmPrintInvoicesBalances

//-----------------------------------------------------------------------------
// Description: Function checks whether currency rates are actual or should be updated
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmCheckCurrencyRatesActuality() Экспорт                                         /// нахрена эта функция?
	If cmCheckUserPermissions("HavePermissionToCheckCurrencyRatesActuality") Тогда
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
			vCurDayOfWeek = WeekDay(CurrentDate());
			If vCurDayOfWeek <> 7 And vCurDayOfWeek <> 1 Тогда
				vRates = InformationRegisters.КурсВалют.SliceLast(, New Structure("Гостиница", ПараметрыСеанса.ТекущаяГостиница));
				If vRates.Count() > 0 Тогда
					vTodayIsFound = False;
					vDate = Date('00010101');
					For Each vRatesRow In vRates Do
						vDate = Max(vDate, BegOfDay(vRatesRow.Период));
						If BegOfDay(vRatesRow.Период) >= BegOfDay(CurrentDate()) Тогда
							vTodayIsFound = True;
							Break;
						EndIf;
					EndDo;
					If НЕ vTodayIsFound Тогда
						Предупреждение(NStr("ru = 'На сегодня не установлены курсы валют! Курсы актуальны на " + Format(vDate, "DF='dd MMMM yyyy'") + " г. - " + cmGetDayOfWeekName(WeekDay(vDate), False) + ".';
						                  |de = 'На сегодня не установлены курсы валют! Курсы актуальны на " + Format(vDate, "DF='dd MMMM yyyy'") + " г. - " + cmGetDayOfWeekName(WeekDay(vDate), False) + ".';
						                  |en = 'There is no currency rates for today! Currency rates are actual for " + Format(vDate, "DF='dd MMMM yyyy'") + " - " + cmGetDayOfWeekName(WeekDay(vDate), False) + ".'"));
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //cmCheckCurrencyRatesActuality

//-----------------------------------------------------------------------------
// Description: Function checks balances for the given accommodations value list
// Parameters: Value list of accommodations
// Return value: True if balances are zero or False if not
//-----------------------------------------------------------------------------
Function cmCheckAccommodationsBalances(pAccList) Экспорт
	vFolios = cmGetDocumentFoliosWithDebts(pAccList);
	If vFolios.Count() > 0 Тогда
		vDoQuery = False;
		vThereAreDebts = False;
		vThereAreDeposits = False;
		vDebtsMessage = NStr("en='Folios: ';ru='По лицевым счетам: ';de='Nach Personenkonten: '") + Chars.LF;
		For Each vFoliosRow In vFolios Do
			If vFoliosRow.SumBalance < 0 Тогда
				vThereAreDeposits = True;
			ElsIf vFoliosRow.SumBalance > 0 Тогда
				vThereAreDebts = True;
			EndIf;
			If ЗначениеЗаполнено(vFoliosRow.СчетПроживания) Тогда
				If ЗначениеЗаполнено(vFoliosRow.СчетПроживания.СпособОплаты) Тогда
					If НЕ vFoliosRow.СчетПроживания.СпособОплаты.BookByCashRegister Or
					   (vFoliosRow.СчетПроживания.СпособОплаты.IsByBankTransfer And ЗначениеЗаполнено(vFoliosRow.СчетПроживания.Контрагент))Тогда
						Continue;
					EndIf;
				EndIf;
				vDoQuery = True;
				vDebtsMessage = vDebtsMessage + Chars.LF + "#" + СокрЛП(vFoliosRow.СчетПроживания.НомерДока) + " " + 
				                СокрЛП(vFoliosRow.СчетПроживания.Клиент) + NStr("ru = ', номер '; en = ', ГруппаНомеров '; de = ', zimmer '") + 
				                СокрЛП(vFoliosRow.СчетПроживания.НомерРазмещения) + NStr("ru = ', период '; en = ', period '; de = ', period '") + 
				                Format(vFoliosRow.СчетПроживания.DateTimeFrom, "DF='dd.MM.yy HH:mm'") + " - " + 
				                Format(vFoliosRow.СчетПроживания.DateTimeTo, "DF='dd.MM.yy HH:mm'") + " = " + 
				                cmFormatSum(vFoliosRow.SumBalance, vFoliosRow.СчетПроживания.ВалютаЛицСчета, "NZ=");
			Else
				vDoQuery = True;
				vDebtsMessage = vDebtsMessage + Chars.LF + NStr("en='<Empty folio>';ru='<Пустое фолио>';de='<Leeres Blatt>'") + " = " + cmFormatSum(vFoliosRow.SumBalance, "NZ=", , True);
			EndIf;
		EndDo;
		If vDoQuery Тогда
			If vThereAreDebts And НЕ vThereAreDeposits Тогда
				vDebtsMessage = vDebtsMessage + Chars.LF + Chars.LF + NStr("en='There are DEBTS!';ru='ЕСТЬ ЗАДОЛЖЕННОСТЬ!';de='ES LIEGT EINE SCHULD VOR!'");
			ElsIf НЕ vThereAreDebts And vThereAreDeposits Тогда
				vDebtsMessage = vDebtsMessage + Chars.LF + Chars.LF + NStr("en='There are DEPOSITS!';ru='ЕСТЬ ПЕРЕПЛАТА!';de='ES LIEGT EINE ÜBERZAHLUNG VOR!'");
			Else
				vDebtsMessage = vDebtsMessage + Chars.LF + Chars.LF + NStr("en='There are DEBTS AND DEPOSITS!';ru='ЕСТЬ ЗАДОЛЖЕННОСТЬ И ПЕРЕПЛАТА!';de='ES LIEGT EINE SCHULD oder ÜBERZAHLUNG vor!'");
			EndIf;
			vDebtsMessage = vDebtsMessage + Chars.LF + Chars.LF + NStr("de='Check-out Die Gäste?';en='Do check-out?';ru='Выселить гостей?'");
			If DoQueryBox(vDebtsMessage, QuestionDialogMode.YesNo, , DialogReturnCode.No) = DialogReturnCode.No Тогда
				WriteLogEvent(NStr("en='Accommodation.CheckBalances';ru='Размещение.ПроверкаБаланса';de='Accommodation.CheckBalances'"), EventLogLevel.Information, Metadata.Documents.СчетПроживания, , vDebtsMessage + NStr("en=' - No';ru=' - Нет';de=' - Nein'"));
				Return False;
			Else
				WriteLogEvent(NStr("en='Accommodation.CheckBalances';ru='Размещение.ПроверкаБаланса';de='Accommodation.CheckBalances'"), EventLogLevel.Information, Metadata.Documents.СчетПроживания, , vDebtsMessage + NStr("en=' - Yes';ru=' - Да';de=' - Ja'"));
			EndIf;
		EndIf;
	EndIf;
	Return True;
EndFunction //cmCheckAccommodationsBalances

//-----------------------------------------------------------------------------
// Description: Function checks balances (deposits that are negative balances) 
//              for the given reservations value list
// Parameters: Value list of reservations
// Return value: Always true so far
//-----------------------------------------------------------------------------
Function cmCheckReservationsDeposits(pResRef) Экспорт
	vFolios = cmGetDocumentFoliosWithDebts(pResRef, True); // Deposits only
	If vFolios.Count() > 0 Тогда
		vDebtsMessage = NStr("en='Folios: ';ru='По лицевым счетам: ';de='Nach Personenkonten: '") + Chars.LF;
		For Each vFoliosRow In vFolios Do
			If ЗначениеЗаполнено(vFoliosRow.СчетПроживания) Тогда
				vDebtsMessage = vDebtsMessage + Chars.LF + "#" + СокрЛП(vFoliosRow.СчетПроживания.НомерДока) + " " + 
				                СокрЛП(vFoliosRow.СчетПроживания.Клиент) + NStr("ru = ', номер '; en = ', ГруппаНомеров '; de = ', zimmer '") + 
				                СокрЛП(vFoliosRow.СчетПроживания.НомерРазмещения) + NStr("ru = ', период '; en = ', period '; de = ', period '") + 
				                Format(vFoliosRow.СчетПроживания.DateTimeFrom, "DF='dd.MM.yy HH:mm'") + " - " + 
				                Format(vFoliosRow.СчетПроживания.DateTimeTo, "DF='dd.MM.yy HH:mm'") + " = " + 
				                cmFormatSum(vFoliosRow.SumBalance, vFoliosRow.СчетПроживания.ВалютаЛицСчета, "NZ=");
			Else
				vDebtsMessage = vDebtsMessage + Chars.LF + NStr("en='<Empty folio>';ru='<Пустое фолио>';de='<Leeres Blatt>'") + " = " + cmFormatSum(vFoliosRow.SumBalance, "NZ=", , True);
			EndIf;
		EndDo;
		vDebtsMessage = vDebtsMessage + Chars.LF + Chars.LF + NStr("en='There are DEPOSITS!';ru='ЕСТЬ ПРЕДОПЛАТА!';de='ES LIEGT EINE ANZAHLUNG VOR!'");
		Предупреждение(vDebtsMessage);
		WriteLogEvent(NStr("en='Reservation.CheckDeposits';ru='Резервирование.ПроверкаДепозита';de='Reservation.CheckDeposits'"), EventLogLevel.Information, Metadata.Documents.СчетПроживания, , vDebtsMessage);
	EndIf;
	Return True;
EndFunction //cmCheckReservationsDeposits

//-----------------------------------------------------------------------------
// Description: Function returns accommodation service item reference searching 
//              value table with services by IsRoomRevenue column value equal true
// Parameters: Value table with services
// Return value: Services catalog item reference
//-----------------------------------------------------------------------------
Function cmGetAccommodationService(pServices) Экспорт
	vAccommodationService = Неопределено;
	For Each pServicesRow In pServices Do
		If pServicesRow.IsRoomRevenue And pServicesRow.IsInPrice Тогда
			vAccommodationService = pServicesRow.Услуга;
			Break;
		EndIf;
	EndDo;
	Return vAccommodationService;
EndFunction //cmGetAccommodationService

//-----------------------------------------------------------------------------
Процедура FillExtraInvoiceServices(pInvObj, pExtraServices)
	vAccommodationService = cmGetAccommodationService(pExtraServices);
	pExtraServices.FillValues(vAccommodationService, "Услуга");
	pExtraServices.FillValues(0, "Цена");
	pExtraServices.FillValues(0, "Количество");
	pExtraServices.GroupBy("Услуга, СтавкаНДС", "Количество, Цена, Сумма, СуммаНДС, СуммаСкидки, СуммаКомиссии, VATCommissionSum");
	pInvObj.Услуги.Load(pExtraServices);
	Для каждого vServicesRow Из pInvObj.Услуги Цикл
		
		If ЗначениеЗаполнено(pInvObj.ГруппаГостей) Тогда
			vServicesRow.Примечания = "Доплата по группе N"+ ?(ЗначениеЗаполнено(pInvObj.Контрагент), pInvObj.Контрагент.Language, Справочники.Локализация.RU) + Format(pInvObj.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
		ElsIf ЗначениеЗаполнено(pInvObj.Договор) Тогда
			vServicesRow.Примечания = "Доплата по договору "+ ?(ЗначениеЗаполнено(pInvObj.Контрагент), pInvObj.Контрагент.Language, Справочники.Локализация.RU) + СокрЛП(pInvObj.Договор);
		Else
			vServicesRow.Примечания = "Доплата"+ ?(ЗначениеЗаполнено(pInvObj.Контрагент), pInvObj.Контрагент.Language, Справочники.Локализация.RU);
		EndIf;
		vServicesRow.Цена = vServicesRow.Сумма;
		vServicesRow.Количество = 1;
	КонецЦикла;
КонецПроцедуры //FillExtraInvoiceServices

//-----------------------------------------------------------------------------
// Description: Checks guest group changes and asks user whether to create invoice for changes only
// Parameters: Guest group reference, New invoice object 
// Return value: False if user skipped selection, true if choice was done
//-----------------------------------------------------------------------------
Function cmCheckOtherInvoices(pGuestGroup, pInvObj, pForm, pButton, pExtraInvoice = False) Экспорт
	// Check if there are other guest group invoices
	vGuestGroupObj = pGuestGroup.GetObject();
	vExistingInvoices = vGuestGroupObj.pmGetInvoices();
	If vExistingInvoices.Count() > 0 Тогда
		vNewInvServices = pInvObj.Услуги.Unload();
		For Each vExistingInvoicesRow In vExistingInvoices Do
			If vExistingInvoicesRow.InvoiceDate <= pInvObj.ДатаДок And vExistingInvoicesRow.СчетНаОплату <> pInvObj.Ref Тогда
				For Each vExistingInvoicesServicesRow In vExistingInvoicesRow.СчетНаОплату.Услуги Do
					vNewInvServicesRow = vNewInvServices.Add();
					FillPropertyValues(vNewInvServicesRow, vExistingInvoicesServicesRow, , "LineNumber");
					vNewInvServicesRow.Количество = -vNewInvServicesRow.Количество;
					vNewInvServicesRow.Сумма = -vNewInvServicesRow.Сумма;
					vNewInvServicesRow.СуммаНДС = -vNewInvServicesRow.СуммаНДС;
					vNewInvServicesRow.СуммаСкидки = -vNewInvServicesRow.СуммаСкидки;
					vNewInvServicesRow.СуммаКомиссии = -vNewInvServicesRow.СуммаКомиссии;
					vNewInvServicesRow.СуммаКомиссииНДС = -vNewInvServicesRow.СуммаКомиссииНДС;
					vNewInvServicesRow.КоличествоЧеловек = -vNewInvServicesRow.КоличествоЧеловек;
					vNewInvServicesRow.RoomQuantity = -vNewInvServicesRow.RoomQuantity;
				EndDo;
			EndIf;
		EndDo;
		vNewInvServices.GroupBy("УчетнаяДата, Услуга, Цена, ЕдИзмерения, СтавкаНДС, Примечания, Клиент, ВидРазмещения, ТипНомера, НомерРазмещения, Ресурс, IsInPrice, IsRoomRevenue, IsResourceRevenue, DateTimeFrom, DateTimeTo, ТипДеньКалендарь, Скидка, ПутевкаКурсовка, Агент, ВидКомиссииАгента, КомиссияАгента, ГруппаГостей", "Количество, Сумма, СуммаНДС, КоличествоЧеловек, RoomQuantity, СуммаСкидки, СуммаКомиссии, VATCommissionSum");
		vMinusIsFound = False;
		i = 0;
		While i < vNewInvServices.Count() Do
			vNewInvServicesRow = vNewInvServices.Get(i);
			If vNewInvServicesRow.Количество < 0 Тогда
				vMinusIsFound = True;
			ElsIf vNewInvServicesRow.Количество = 0 And vNewInvServicesRow.Сумма = 0 Тогда
				vNewInvServices.Delete(i);
				Continue;
			EndIf;
			i = i + 1;
		EndDo;
		vNewFullAmount = pInvObj.Услуги.Total("Сумма");
		vNewExtraAmount = vNewInvServices.Total("Сумма");
		If pExtraInvoice Тогда
			If vMinusIsFound Тогда
				FillExtraInvoiceServices(pInvObj, vNewInvServices);
			Else
				pInvObj.Услуги.Load(vNewInvServices);
			EndIf;
		ElsIf vNewExtraAmount <> 0 And vNewFullAmount <> 0 And vNewFullAmount <> vNewExtraAmount Тогда
			vUCMenu = New СписокЗначений();
			vUCMenu.Add(1, NStr("en='Invoice for total amount ';ru='Счет на полную сумму ';de='Rechnung für die volle Summe '") + cmFormatSum(vNewFullAmount, pInvObj.ВалютаРасчетов));
			vUCMenu.Add(2, NStr("en='Invoice for extra amount ';ru='Счет на доплату ';de='Nachzahlungsrechnung '") + cmFormatSum(vNewExtraAmount, pInvObj.ВалютаРасчетов));
			vUC = pForm.ChooseFromMenu(vUCMenu, pButton);
			If vUC = Неопределено Тогда
				Return False;
			ElsIf vUC.Value = 2 Тогда
				If vMinusIsFound Тогда
					FillExtraInvoiceServices(pInvObj, vNewInvServices);
				Else
					pInvObj.Услуги.Load(vNewInvServices);
				EndIf;
				pInvObj.ExtraInvoice = True;
			EndIf;
		EndIf;
	EndIf;
	Return True;
EndFunction //cmCheckOtherInvoices
