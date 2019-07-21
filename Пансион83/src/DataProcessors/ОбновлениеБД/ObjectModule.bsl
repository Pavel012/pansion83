///-----------------------------------------------------------------------------
//Процедура FillDefaultDurationCalculationRuleType()
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Тарифы.Ref AS Тариф
//	|FROM
//	|	Catalog.Тарифы AS Тарифы
//	|WHERE
//	|	(NOT Тарифы.DeletionMark)
//	|	AND (NOT Тарифы.IsFolder)
//	|	AND Тарифы.DurationCalculationRuleType NOT IN (&qList)";
//	vList = Новый СписокЗначений();
//	vList.Add(Перечисления.DurationCalculationRuleTypes.ByDays);
//	vList.Add(Перечисления.DurationCalculationRuleTypes.ByNights);
//	vList.Add(Перечисления.DurationCalculationRuleTypes.ByReferenceHour);
//	vList.Add(Перечисления.DurationCalculationRuleTypes.ByHours);
//	vQry.SetParameter("qList", vList);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryRow In vQryRes Do
//		vRoomRateObj = vQryRow.Тариф.GetObject();
//		vRoomRateObj.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour;
//		vRoomRateObj.Write();
//	EndDo;
//КонецПроцедуры //FillDefaultDurationCalculationRuleType
//
////-----------------------------------------------------------------------------
//Процедура RepostActiveReservations()
//#Если Клиент Тогда
//	Status("Перепроведение действующей брони...");
//#КонецЕсли
//	// Run query to get active reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref AS Document,
//	|	Reservation.ДатаДок AS Date,
//	|	Reservation.PointInTime AS PointInTime
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.ReservationStatus.IsActive
//	|	AND Reservation.Posted
//	|
//	|UNION ALL
//	|
//	|SELECT
//	|	БроньУслуг.Ref,
//	|	БроньУслуг.ДатаДок,
//	|	БроньУслуг.PointInTime
//	|FROM
//	|	Document.БроньУслуг AS БроньУслуг
//	|WHERE
//	|	БроньУслуг.ResourceReservationStatus.IsActive
//	|	AND (NOT БроньУслуг.ResourceReservationStatus.DoCharging)
//	|	AND БроньУслуг.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Undo posting active reservations first
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.UndoPosting);
//		Except
//			Message(Строка(vCurDocObj) + " - ошибка: " + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Undo posting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Undo posting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Отмена проведения действующей брони за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//	// Repost current reservations	
//	vCurDate = '00010101';
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Reposting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Reposting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Перепроведение действующей брони за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostActiveReservations
//
////-----------------------------------------------------------------------------
//Процедура RepostInHouseAccommodations()
//#Если Клиент Тогда
//	Status(NStr("en='Reposting in-house accommodations...'; de='Reposting in-house accommodations...'; ru='Перепроведение текущих размещений...'"));
//#КонецЕсли
//	// Run query to get in-house accommodations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Размещение.Ref AS Document,
//	|	Размещение.ДатаДок AS Date,
//	|	Размещение.PointInTime AS PointInTime
//	|FROM
//	|	Document.Размещение AS Размещение
//	|WHERE
//	|	Размещение.СтатусРазмещения.IsActive
//	|	AND Размещение.СтатусРазмещения.ЭтоГости
//	|	AND Размещение.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Choose();
//	vCurDate = '00010101';
//	While vQryRes.Next() Do
//		vCurDocObj = vQryRes.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryRes.ДатаДок) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryRes.ДатаДок);
//			Status(NStr("en='Reposting in-house accommodations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Reposting in-house accommodations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Перепроведение текущих размещений за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostInHouseAccommodations
//
////-----------------------------------------------------------------------------
//Процедура FillServiceCommissionAttributes()
//#Если Клиент Тогда
//	Status(NStr("en='Processing commissions in reservations and accommodations...'; de='Processing commissions in reservations and accommodations...'; ru='Обработка комиссий в брони и размещениях...'"));
//#КонецЕсли
//	// Run query to get active reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref AS Document,
//	|	Reservation.ДатаДок AS Date,
//	|	Reservation.PointInTime AS PointInTime
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.Posted
//	|
//	|UNION ALL
//	|
//	|SELECT
//	|	Размещение.Ref,
//	|	Размещение.ДатаДок,
//	|	Размещение.PointInTime
//	|FROM
//	|	Document.Размещение AS Размещение
//	|WHERE
//	|	Размещение.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Undo posting active reservations first
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		For Each vSrvRow In vCurDocObj.Услуги Do
//			vSrvRow.ВидКомиссииАгента = vCurDocObj.ВидКомиссииАгента;
//			vSrvRow.КомиссияАгента = vCurDocObj.КомиссияАгента;
//		EndDo;
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Write);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Processing commissions in reservations and accommodations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Processing commissions in reservations and accommodations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Обработка комиссий в брони и размещениях за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillServiceCommissionAttributes 
//
////-----------------------------------------------------------------------------
//Процедура FillGuestGroupParameters()
//#Если Клиент Тогда
//	Status(NStr("en='Filling guest group parameters...'; de='Filling guest group parameters...'; ru='Заполнение параметров групп гостей...'"));
//#КонецЕсли
//	// Run query to get active reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	GuestGroups.Ref AS ГруппаГостей
//	|FROM
//	|	Catalog.GuestGroups AS GuestGroups
//	|WHERE
//	|	(NOT GuestGroups.DeletionMark)
//	|	AND (NOT GuestGroups.IsFolder)
//	|
//	|ORDER BY
//	|	GuestGroups.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vGroupObj = vQryRes.ГруппаГостей.GetObject();
//		Try
//			vUpdateClient = False;
//			If НЕ ЗначениеЗаполнено(vGroupObj.Клиент) Тогда
//				vUpdateClient = True;
//			EndIf;
//			vUpdatePeriod = False;
//			vUpdateGuestsCheckedIn = False;
//			vGroupParams = cmGetGroupPeriodAndGuestsCheckedIn(vGroupObj.Ref);
//			If vGroupParams.Count() > 0 Тогда
//				vGroupParamsRow = vGroupParams.Get(0);
//				If vGroupParamsRow.CheckInDate <> vGroupObj.CheckInDate Or
//				   vGroupParamsRow.CheckOutDate <> vGroupObj.CheckOutDate Тогда
//					vUpdatePeriod = True;
//				EndIf;
//				If vGroupParamsRow.ЗаездГостей <> vGroupObj.ЗаездГостей Тогда
//					vUpdateGuestsCheckedIn = True;
//				EndIf;
//			EndIf;
//			If vUpdateClient Тогда
//				vClientDoc = Неопределено;
//				vGroupObj.Клиент = cmGetHeadOfGroupClient(vGroupObj.Ref, vGroupObj.Клиент, vClientDoc);
//				vGroupObj.ClientDoc = vClientDoc;
//			EndIf;
//			If vUpdatePeriod Тогда
//				vGroupObj.CheckInDate = vGroupParamsRow.CheckInDate;
//				vGroupObj.CheckOutDate = vGroupParamsRow.CheckOutDate;
//				If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//					vGroupObj.Продолжительность = cmCalculateDuration(ПараметрыСеанса.ТекущаяГостиница.Тариф, vGroupObj.CheckInDate, vGroupObj.CheckOutDate);
//				EndIf;
//			EndIf;
//			If vUpdateGuestsCheckedIn Тогда
//				vGroupObj.ЗаездГостей = vGroupParamsRow.ЗаездГостей;
//			EndIf;
//			vGroupObj.Write();
//		Except
//			Message(TrimAll(vGroupObj.Code) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		Status(NStr("en='Guest group " + TrimAll(vGroupObj.Code) + " processed...'; 
//		            |de='Guest group " + TrimAll(vGroupObj.Code) + " processed...'; 
//					|ru='Обработана группа " + TrimAll(vGroupObj.Code) + "...'"));
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillGuestGroupParameters
//
////-----------------------------------------------------------------------------
//Процедура Fill032033UserPermissions()
//	// Run query to get permission groups
//	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.НаборПрав) Тогда
//		Try
//			vPGObj = ПараметрыСеанса.ТекПользователь.НаборПрав.GetObject();
//			vPGObj.HavePermissionToStornoFolioCharges = True;
//			vPGObj.HavePermissionToReturnPayments = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndIf;
//КонецПроцедуры //Fill032033UserPermissions
//
////-----------------------------------------------------------------------------
//Процедура Fill095099112UserPermissions()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToPostPaymentsWithEmptyPaymentSections = True;
//			vPGObj.HavePermissionToSkipInputOfClientType = True;
//			vPGObj.HavePermissionToDoBookingWithoutRooms = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill095099112UserPermissions
//
////-----------------------------------------------------------------------------
//Процедура Fill103106UserPermissions()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToSkipInputOfReservationTripPurpose = True;
//			vPGObj.HavePermissionToSkipInputOfReservationMarketingCode = True;
//			vPGObj.HavePermissionToSkipInputOfReservationSourceOfBusiness = True;
//			vPGObj.HavePermissionToSeePricesDifferentFromRoomRackRates = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill103106UserPermissions
//
////-----------------------------------------------------------------------------
//Процедура Fill107UserPermissions()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToManageReportColumns = True;
//			vPGObj.FillDefaultRoomPolicy = Перечисления.FillDefaultRoomPolicies.NoDefaultRoom;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill107UserPermissions
//
////-----------------------------------------------------------------------------
//Процедура Fill109111UserPermissions()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToDoRoomTypeUpgrade = True;
//			vPGObj.HavePermissionToUseAnyRoomTypeForUpgrade = False;
//			vPGObj.HavePermissionToSkipInputOfReservationContactPerson = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill109111UserPermissions
//
////-----------------------------------------------------------------------------
//Процедура Fill113UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			If vPGObj.HavePermissionToManageRoomInventory Тогда
//				vPGObj.HavePermissionToManageHousekeeping = True;
//				vPGObj.Write();
//			EndIf;
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill113UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill135UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToChargeExtraServicesOnCredit = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill135UserPermission
//
////-----------------------------------------------------------------------------
//Процедура FillCorrectRUBCode()
//	vRUBRef = Справочники.Currencies.FindByCode(810);
//	If ЗначениеЗаполнено(vRUBRef) Тогда
//		vRUBObj = vRUBref.GetObject();
//		vRUBObj.Code = 643;
//		vRUBObj.Write();
//	EndIf;
//КонецПроцедуры //FillCorrectRUBCode
//
////-----------------------------------------------------------------------------
//Процедура FixAccommodationTypes()
//	vAllAccTypes = cmGetAllAccommodationTypes();
//	For Each vAllAccTypesRow In vAllAccTypes Do
//		vAccType = vAllAccTypesRow.ВидРазмещения;
//		If vAccType.ТипРазмещения = Перечисления.ВидыРазмещений.AdditionalBed Тогда
//			If vAccType.КолДопМест = 0 Тогда
//				vAccTypeObj = vAccType.GetObject();
//				vAccTypeObj.КолДопМест = 1;
//				vAccTypeObj.Write();
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //FixAccommodationTypes
//
////-----------------------------------------------------------------------------
//Процедура FillAuditReportsSettings()
//	// Create audit reports group first
//	vAuditReportsFolder = Справочники.Отчеты.FindByCode(790);
//	If НЕ ЗначениеЗаполнено(vAuditReportsFolder) Тогда
//		vAuditReportsFolderObj = Справочники.Отчеты.CreateFolder();
//		vAuditReportsFolderObj.Code = 790;
//		vAuditReportsFolderObj.Description = "EN='Audit reports'; RU='Аудиторские отчеты'";
//		vAuditReportsFolderObj.Write();
//		vAuditReportsFolder = vAuditReportsFolderObj.Ref;
//	ElsIf НЕ vAuditReportsFolder.IsFolder Тогда
//		vAuditReportsFolder = Справочники.Отчеты.EmptyRef();
//	EndIf;
//	// Fill report name and report folder for new reports
//	vRepRef = Справочники.Отчеты.FindByCode(792);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "АудитОтмены"; 
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.ПорядокСортировки = 792;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//	vRepRef = Справочники.Отчеты.FindByCode(794);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "PaymentAnnulations"; 
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.ПорядокСортировки = 794;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//	vRepRef = Справочники.Отчеты.FindByCode(796);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "ChargesStorno"; 
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.ПорядокСортировки = 796;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//	vRepRef = Справочники.Отчеты.FindByCode(798);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "АудитЗаменаКомнатРазмещения"; 
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.ПорядокСортировки = 798;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//	vRepRef = Справочники.Отчеты.FindByCode(799);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "GuestsInBlockedRooms"; 
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.ПорядокСортировки = 799;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillAuditReportsSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillCustomerOperationalBalancesObjectPrintingForm()
//	vCustomerFolder = Справочники.ObjectPrintingForms.FindByCode("1000");
//	vCustomerOperationalBalanceObj = Справочники.ObjectPrintingForms.CustomerPrintOperationalBalances.GetObject();
//	If ЗначениеЗаполнено(vCustomerFolder) And vCustomerFolder.IsFolder Тогда
//		vCustomerOperationalBalanceObj.Parent = vCustomerFolder;
//	EndIf;
//	vCustomerOperationalBalanceObj.ObjectType = Справочники.Customers.EmptyRef();
//	vCustomerOperationalBalanceObj.IsActive = True;
//	vCustomerOperationalBalanceObj.Report = Справочники.Отчеты.CustomerAccountsOperational;
//	vCustomerOperationalBalanceObj.Write();
//КонецПроцедуры //FillCustomerOperationalBalancesObjectPrintingForm
//
////-----------------------------------------------------------------------------
//Процедура FillCustomerSalesForecastReportSettings()
//	// Find analitical reports folder
//	vAnaliticalReportsFolder = Справочники.Отчеты.FindByCode(500);
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.FindByCode(521);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "CustomerSalesForecast"; 
//		If ЗначениеЗаполнено(vAnaliticalReportsFolder) And vAnaliticalReportsFolder.IsFolder Тогда
//			vRepObj.Parent = vAnaliticalReportsFolder;
//		EndIf;
//		vRepObj.ПорядокСортировки = 521;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = EndOfMonth(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillCustomerSalesForecastReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillOccupancyForecastReportSettings()
//	// Find analitical reports folder
//	vAnaliticalReportsFolder = Справочники.Отчеты.FindByCode(500);
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.FindByCode(235);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "OccupancyForecast"; 
//		If ЗначениеЗаполнено(vAnaliticalReportsFolder) And vAnaliticalReportsFolder.IsFolder Тогда
//			vRepObj.Parent = vAnaliticalReportsFolder;
//		EndIf;
//		vRepObj.ПорядокСортировки = 235;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = EndOfMonth(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillOccupancyForecastReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillChangedAccommodationsReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.FindByCode(850);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "ChangedAccommodations"; 
//		vRepObj.ПорядокСортировки = 850;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate()) - 24*3600;
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillChangedAccommodationsReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillIssuedHotelProductsReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.FindByCode(584);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "IssuedHotelProducts"; 
//		vRepObj.Parent = Справочники.Отчеты.EmptyRef();
//		vRepObj.ПорядокСортировки = 584;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillIssuedHotelProductsReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FixPaymentMethods()
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	СпособОплаты.Ref
//	|FROM
//	|	Catalog.СпособОплаты AS СпособОплаты
//	|WHERE
//	|	(NOT СпособОплаты.DeletionMark)
//	|	AND СпособОплаты.IsByCreditCard
//	|ORDER BY
//	|	СпособОплаты.ПорядокСортировки,
//	|	СпособОплаты.Description";
//	vPaymentMethods = vQry.Execute().Unload();
//	For Each vPaymentMethodsRow In vPaymentMethods Do
//		vPMRef = vPaymentMethodsRow.Ref;
//		If vPMRef.IsByCreditCard Тогда
//			vPMObj = vPMRef.GetObject();
//			vPMObj.AuthorizationCodeIsRequired = True;
//			vPMObj.ReferenceCodeIsRequired = True;
//			vPMObj.Write();
//		EndIf;
//	EndDo;
//КонецПроцедуры //FixPaymentMethods
//
////-----------------------------------------------------------------------------
//Процедура FillReleaseExpiredRoomAllotmentsDataProcessorSettings()
//	// Fill data processor name and dynamic parameters
//	vDPRef = Справочники.Обработки.ReleaseExpiredRoomAllotments;
//	If ЗначениеЗаполнено(vDPRef) And НЕ ЗначениеЗаполнено(vDPRef.Processing) Тогда
//		vDPObj = vDPRef.GetObject();
//		vDPObj.Processing = "ReleaseExpiredRoomAllotments"; 
//		vDPObj.ПорядокСортировки = 210;
//		vDPObj.DynamicParameters = "If ЗначениеЗаполнено(PARM) Тогда
//		                           |	DPO.Гостиница = PARM;
//		                           |EndIf;";
//		vDPObj.Write();
//	EndIf;
//КонецПроцедуры //FillReleaseExpiredRoomAllotmentsDataProcessorSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillSendGuestGroupNotificationsDataProcessorSettings()
//	// Fill data processor name and dynamic parameters
//	vDPRef = Справочники.Обработки.SendGuestGroupNotifications;
//	If ЗначениеЗаполнено(vDPRef) And НЕ ЗначениеЗаполнено(vDPRef.Processing) Тогда
//		vDPObj = vDPRef.GetObject();
//		vDPObj.Processing = "SendGuestGroupNotifications"; 
//		vDPObj.ПорядокСортировки = 810;
//		vDPObj.Write();
//	EndIf;
//КонецПроцедуры //FillSendGuestGroupNotificationsDataProcessorSettings 
//
////-----------------------------------------------------------------------------
//Процедура Fill112UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToDoBookingWithoutRooms = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill112UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill116UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToCancelAccommodations = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill116UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill117UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToEditFoliosCreditLimit = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill117UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill119UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToChooseClientTypeManually = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill119UserPermission
//
////-----------------------------------------------------------------------------
//Процедура FillCheckReservationWaitingListProcessingSettings()
//	// Fill data processor name and dynamic parameters
//	vDPRef = Справочники.Обработки.CheckReservationWaitingList;
//	If ЗначениеЗаполнено(vDPRef) And НЕ ЗначениеЗаполнено(vDPRef.Processing) Тогда
//		vDPObj = vDPRef.GetObject();
//		vDPObj.Processing = "CheckReservationWaitingList"; 
//		vDPObj.ПорядокСортировки = 820;
//		vDPObj.Write();
//	EndIf;
//КонецПроцедуры //FillCheckReservationWaitingListProcessingSettings
//
////-----------------------------------------------------------------------------
//Процедура FillReservationGuestFullNames()
//#Если Клиент Тогда
//	Status(NStr("en='Updating guest full names in reservations...'; de='Updating guest full names in reservations...'; ru='Заполнение ФИО гостей в брони...'"));
//#КонецЕсли
//	// Run query to get reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref AS Document,
//	|	Reservation.ДатаДок AS Date,
//	|	Reservation.PointInTime AS PointInTime
//	|FROM
//	|	Document.Reservation AS Reservation
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Rewrite documents
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Write);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Processing reservations dated " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Processing reservations dated " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Обработка брони за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillReservationGuestFullNames
//
////-----------------------------------------------------------------------------
//Процедура FillAccommodationGuestFullNames()
//#Если Клиент Тогда
//	Status(NStr("en='Updating guest full names in accommodations...'; de='Updating guest full names in accommodations...'; ru='Заполнение ФИО гостей в размещениях...'"));
//#КонецЕсли
//	// Run query to get reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Размещение.Ref AS Document,
//	|	Размещение.ДатаДок AS Date,
//	|	Размещение.PointInTime AS PointInTime
//	|FROM
//	|	Document.Размещение AS Размещение
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Rewrite documents
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Write);
//		Except
//			Message(Строка(vCurDocObj) + " - ошибка: " + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status("Обработка размещений за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...");
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillAccommodationGuestFullNames
//
////-----------------------------------------------------------------------------
//Процедура FillCustomerGuestsPercentsReportSettings()
//	// Find analitical reports folder
//	vAnaliticalReportsFolder = Справочники.Отчеты.FindByCode(500);
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.FindByCode(527);
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "CustomerGuestsPercents"; 
//		If ЗначениеЗаполнено(vAnaliticalReportsFolder) And vAnaliticalReportsFolder.IsFolder Тогда
//			vRepObj.Parent = vAnaliticalReportsFolder;
//		EndIf;
//		vRepObj.ПорядокСортировки = 527;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillCustomerGuestsPercentsReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillCheckCustomerServicesReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.CheckCustomerServices;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "CheckCustomerServices"; 
//		vRepObj.ПорядокСортировки = 167;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillCheckCustomerServicesReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillCheckCustomerGuestsReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.CheckCustomerGuests;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "CheckCustomerGuests"; 
//		vRepObj.ПорядокСортировки = 168;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillCheckCustomerGuestsReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillCopyGuestGroupReservationsObjectFormAction()
//	vObj = Справочники.ObjectFormActions.ReservationCopyGuestGroupReservations.GetObject();
//	vObj.IsActive = True;
//	vObj.ObjectType = Documents.Reservation.EmptyRef();
//	vObj.Write();
//КонецПроцедуры //FillCopyGuestGroupReservationsObjectFormAction
//
////-----------------------------------------------------------------------------
//Процедура RepostActiveReservationsInOneRun()
//#Если Клиент Тогда
//	Status("Перепроведение действующей брони...");
//#КонецЕсли
//	// Run query to get active reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref AS Document,
//	|	Reservation.ДатаДок AS Date,
//	|	Reservation.PointInTime AS PointInTime
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.ReservationStatus.IsActive
//	|	AND Reservation.Posted
//	|
//	|UNION ALL
//	|
//	|SELECT
//	|	БроньУслуг.Ref,
//	|	БроньУслуг.ДатаДок,
//	|	БроньУслуг.PointInTime
//	|FROM
//	|	Document.БроньУслуг AS БроньУслуг
//	|WHERE
//	|	БроньУслуг.ResourceReservationStatus.IsActive
//	|	AND (NOT БроньУслуг.ResourceReservationStatus.ServicesAreDelivered)
//	|	AND БроньУслуг.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Repost active reservations	
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + " - ошибка: " + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Reposting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Reposting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Перепроведение действующей брони за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostActiveReservationsInOneRun
//
////-----------------------------------------------------------------------------
//Процедура RepostPayments()
//#Если Клиент Тогда
//	Status("Перепроведение платежей...");
//#КонецЕсли
//	// Run query to get payments
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Платеж.Ref AS Document,
//	|	Платеж.ДатаДок AS Date,
//	|	Платеж.PointInTime AS PointInTime
//	|FROM
//	|	Document.Платеж AS Платеж
//	|WHERE
//	|	Платеж.Posted
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Repost payments
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + " - ошибка: " + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status("Перепроведение платежей за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...");
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostPayments
//
////-----------------------------------------------------------------------------
//Процедура RepostReturns()
//#Если Клиент Тогда
//	Status("Перепроведение возвратов...");
//#КонецЕсли
//	// Run query to get returns
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Return.Ref AS Document,
//	|	Return.ДатаДок AS Date,
//	|	Return.PointInTime AS PointInTime
//	|FROM
//	|	Document.Возврат AS Return
//	|WHERE
//	|	Return.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Repost returns
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Reposting returns on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Reposting returns on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Перепроведение возвратов за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostReturns
//
////-----------------------------------------------------------------------------
//Процедура RepostCustomerPayments()
//#Если Клиент Тогда
//	Status(NStr("en='Reposting Контрагент payments...'; de='Reposting Контрагент payments...'; ru='Перепроведение платежей контрагентов...'"));
//#КонецЕсли
//	// Run query to get Контрагент payments
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Return.Ref AS Document,
//	|	Return.ДатаДок AS Date,
//	|	Return.PointInTime AS PointInTime
//	|FROM
//	|	Document.Возврат AS Return
//	|WHERE
//	|	Return.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Repost returns
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Reposting Контрагент payments on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Reposting Контрагент payments on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Перепроведение платежей контрагентов за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostCustomerPayments
//
////-----------------------------------------------------------------------------
//Процедура RepostCloseOfCashRegisterDays()
//#Если Клиент Тогда
//	Status(NStr("en='Reposting close of cash register days...'; de='Reposting close of cash register days...'; ru='Перепроведение закрытия кассовых смен...'"));
//#КонецЕсли
//	// Run query to get сlose of cash register days
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	ЗакрытиеКассовойСмены.Ref AS Document,
//	|	ЗакрытиеКассовойСмены.ДатаДок AS Date,
//	|	ЗакрытиеКассовойСмены.PointInTime AS PointInTime
//	|FROM
//	|	Document.ЗакрытиеКассовойСмены AS ЗакрытиеКассовойСмены
//	|WHERE
//	|	ЗакрытиеКассовойСмены.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Repost сlose of cash register days
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Reposting close of cash register days on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Reposting close of cash register days on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Перепроведение закрытия кассовых смен за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostCloseOfCashRegisterDays
//
////-----------------------------------------------------------------------------
//Процедура FillExpectedCheckInOrderedByRoomsReportSettings()
//	// Find report
//	vRepRef = Справочники.Отчеты.ExpectedCheckInOrderedByRooms;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "ExpectedCheckIn"; 
//		vRepObj.ПорядокСортировки = 117;
//		vRepObj.StaticParameters = Справочники.Отчеты.ExpectedCheckInForToday.StaticParameters;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillExpectedCheckInOrderedByRoomsReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillReservationPrintGuestGroupRoomsObjectPrintingFormSetings()
//	If TypeOf(Справочники.ObjectPrintingForms.ReservationPrintGuestGroupRooms.ObjectType) <> Type("DocumentRef.Reservation") Тогда
//		vReservationFolder = Справочники.ObjectPrintingForms.FindByCode("200");
//		vPrtFormObj = Справочники.ObjectPrintingForms.ReservationPrintGuestGroupRooms.GetObject();
//		vPrtFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vPrtFormObj.Parent = vReservationFolder;
//		EndIf;
//		vPrtFormObj.IsActive = True;
//		vPrtFormObj.Примечания = "en='Print list of guest group rooms sorted by rooms sort order'; ru='Распечатать список номеров на брони по группе гостей отсортированный по номерам'";
//		vPrtFormObj.Write();
//	EndIf;
//КонецПроцедуры //FillReservationPrintGuestGroupRoomsObjectPrintingFormSetings
//
////-----------------------------------------------------------------------------
//Процедура FillSafetySystemEventsAuditReportSettings()
//	// Create audit reports group first
//	vAuditReportsFolder = Справочники.Отчеты.FindByCode(790);
//	If ЗначениеЗаполнено(vAuditReportsFolder) And НЕ vAuditReportsFolder.IsFolder Тогда
//		vAuditReportsFolder = Справочники.Отчеты.EmptyRef();
//	EndIf;
//	// Fill report name and report folder for new reports
//	vRepRef = Справочники.Отчеты.АудитСобытийБезопасности;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "SafetySystemEventsAudit"; 
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.ПорядокСортировки = 797;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate()) - 24*3600;
//		                            |REP.ПериодПо = EndOfDay(REP.ПериодС);";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillSafetySystemEventsAuditReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillPrintCouponsActionSetings()
//	vReservationFolder = Справочники.ObjectFormActions.FindByCode("200");
//	If TypeOf(Справочники.ObjectFormActions.ReservationPrintCoupons.ObjectType) <> Type("DocumentRef.Reservation") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ReservationPrintCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vReservationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the reservation'; ru='Распечатать список талонов по брони'";
//		vFrmActObj.Write();
//		
//		vFrmActObj = Справочники.ObjectFormActions.ReservationPrintRoomCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vReservationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the one ГруппаНомеров reservations'; ru='Распечатать список талонов по брони в одном номере'";
//		vFrmActObj.Write();
//		
//		vFrmActObj = Справочники.ObjectFormActions.ReservationPrintGuestGroupCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vReservationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the guest group reservations'; ru='Распечатать список талонов по брони из одной группы'";
//		vFrmActObj.Write();
//	EndIf;
//	vAccommodationFolder = Справочники.ObjectFormActions.FindByCode("100");
//	If TypeOf(Справочники.ObjectFormActions.AccommodationPrintCoupons.ObjectType) <> Type("DocumentRef.Размещение") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.AccommodationPrintCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vAccommodationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the accommodation'; ru='Распечатать список талонов по размещению'";
//		vFrmActObj.Write();
//		
//		vFrmActObj = Справочники.ObjectFormActions.AccommodationPrintRoomCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vAccommodationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the one ГруппаНомеров in-house guests'; ru='Распечатать список талонов по проживающим в одном номере гостям'";
//		vFrmActObj.Write();
//		
//		vFrmActObj = Справочники.ObjectFormActions.AccommodationPrintGuestGroupCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vAccommodationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the guest group in-house guests'; ru='Распечатать список талонов по проживающим гостям из одной группы'";
//		vFrmActObj.Write();
//	EndIf;
//	vResourceReservationFolder = Справочники.ObjectFormActions.FindByCode("1300");
//	If TypeOf(Справочники.ObjectFormActions.ResourceReservationPrintCoupons.ObjectType) <> Type("DocumentRef.БроньУслуг") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ResourceReservationPrintCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.БроньУслуг.EmptyRef();
//		If ЗначениеЗаполнено(vResourceReservationFolder) And vResourceReservationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vResourceReservationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the resource reservation'; ru='Распечатать список талонов по брони ресурсов'";
//		vFrmActObj.Write();
//		
//		vFrmActObj = Справочники.ObjectFormActions.ResourceReservationPrintGuestGroupCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.БроньУслуг.EmptyRef();
//		If ЗначениеЗаполнено(vResourceReservationFolder) And vResourceReservationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vResourceReservationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the guest group resource reservations'; ru='Распечатать список талонов по брони ресурсов из одной группы'";
//		vFrmActObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.FolioPrintCoupons.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFolioFolder = Справочники.ObjectFormActions.FindByCode("500");
//		vFrmActObj = Справочники.ObjectFormActions.FolioPrintCoupons.GetObject();
//		vFrmActObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmActObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Print coupons list for the folio'; ru='Распечатать список талонов по лицевому счету'";
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillPrintCouponsActionSetings
//
////-----------------------------------------------------------------------------
//Процедура FillClientObjectFormActionsSettings()
//	vClientFolder = Справочники.ObjectFormActions.FindByCode("1500");
//	If НЕ ЗначениеЗаполнено(vClientFolder) Тогда
//		vClientFolderObj = Справочники.ObjectFormActions.CreateFolder();
//		vClientFolderObj.Code = "1500";
//		vClientFolderObj.Description = "en='Client'; ru='Клиент'";
//		vClientFolderObj.Write();
//		vClientFolder = vClientFolderObj.Ref;
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.ClientFillReservation.ObjectType) <> Type("CatalogRef.Клиенты") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ClientFillReservation.GetObject();
//		vFrmActObj.ObjectType = Справочники.Клиенты.EmptyRef();
//		If ЗначениеЗаполнено(vClientFolder) And vClientFolder.IsFolder Тогда
//			vFrmActObj.Parent = vClientFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Fill new reservation for the client'; ru='Создать новую бронь для клиента'";
//		vFrmActObj.ObjectFormActionButton = Перечисления.ObjectFormActionButtons.Button1;
//		#Если Клиент Тогда
//			vFrmActObj.ActionIcon = Новый ValueStorage(PictureLib.ScheduledJobs);
//		#КонецЕсли
//		vFrmActObj.ButtonCaption = "en='Новый reservation (F7)'; ru='Новая бронь (F7)'";
//		vFrmActObj.ButtonToolTip = "en='Fill new reservation'; ru='Создать новую бронь'";
//		vFrmActObj.ButtonShortcut = "F7";
//		vFrmActObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.ClientFillAccommodation.ObjectType) <> Type("CatalogRef.Клиенты") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ClientFillAccommodation.GetObject();
//		vFrmActObj.ObjectType = Справочники.Клиенты.EmptyRef();
//		If ЗначениеЗаполнено(vClientFolder) And vClientFolder.IsFolder Тогда
//			vFrmActObj.Parent = vClientFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Fill new accommodation for the client'; ru='Создать новое размещение для клиента'";
//		vFrmActObj.ObjectFormActionButton = Перечисления.ObjectFormActionButtons.Button2;
//		#Если Клиент Тогда
//			vFrmActObj.ActionIcon = Новый ValueStorage(PictureLib.CheckIn);
//		#КонецЕсли
//		vFrmActObj.ButtonCaption = "en='Новый accommodation (F6)'; ru='Новое размещение (F6)'";
//		vFrmActObj.ButtonToolTip = "en='Fill new accommodation'; ru='Создать новое размещение'";
//		vFrmActObj.ButtonShortcut = "F6";
//		vFrmActObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.ClientFillResourceReservation.ObjectType) <> Type("CatalogRef.Клиенты") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ClientFillResourceReservation.GetObject();
//		vFrmActObj.ObjectType = Справочники.Клиенты.EmptyRef();
//		If ЗначениеЗаполнено(vClientFolder) And vClientFolder.IsFolder Тогда
//			vFrmActObj.Parent = vClientFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Fill new resource reservation for the client'; ru='Создать новую бронь ресурсов для клиента'";
//		vFrmActObj.ObjectFormActionButton = Перечисления.ObjectFormActionButtons.Button3;
//		#Если Клиент Тогда
//			vFrmActObj.ActionIcon = Новый ValueStorage(PictureLib.SpreadsheetInsertComment);
//		#КонецЕсли
//		vFrmActObj.ButtonCaption = "en='Новый resource reservation (F8)'; ru='Новая бронь ресурсов (F8)'";
//		vFrmActObj.ButtonToolTip = "en='Fill new resource reservation'; ru='Создать новую бронь ресурсов'";
//		vFrmActObj.ButtonShortcut = "F8";
//		vFrmActObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.ClientShowForeignerRegistryRecords.ObjectType) <> Type("CatalogRef.Клиенты") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ClientShowForeignerRegistryRecords.GetObject();
//		vFrmActObj.ObjectType = Справочники.Клиенты.EmptyRef();
//		If ЗначениеЗаполнено(vClientFolder) And vClientFolder.IsFolder Тогда
//			vFrmActObj.Parent = vClientFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Show list foreigner registry records for the client'; ru='Показать для клиента список его записей в журнал регистрации иностранцев'";
//		#Если Клиент Тогда
//			vFrmActObj.ActionIcon = Новый ValueStorage(PictureLib.GeographicalSchema);
//		#КонецЕсли
//		vFrmActObj.Write();
//	EndIf;
//	vAccommodationFolder = Справочники.ObjectFormActions.FindByCode("100");
//	If TypeOf(Справочники.ObjectFormActions.AccommodationScanClientData.ObjectType) <> Type("DocumentRef.Размещение") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.AccommodationScanClientData.GetObject();
//		vFrmActObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vAccommodationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Примечания = "en='Open client data scans document'; ru='Открыть документ сканирования данных клиента'";
//		#Если Клиент Тогда
//			vFrmActObj.ActionIcon = Новый ValueStorage(PictureLib.Magnifier);
//		#КонецЕсли
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillClientObjectFormActionsSettings
//
////-----------------------------------------------------------------------------
//Процедура FillClientObjectPrintFormsSettings()
//	vClientFolder = Справочники.ObjectPrintingForms.FindByCode("1700");
//	If НЕ ЗначениеЗаполнено(vClientFolder) Тогда
//		vClientFolderObj = Справочники.ObjectPrintingForms.CreateFolder();
//		vClientFolderObj.Code = "1700";
//		vClientFolderObj.Description = "en='Client'; ru='Клиент'";
//		vClientFolderObj.Write();
//		vClientFolder = vClientFolderObj.Ref;
//	EndIf;
//	If TypeOf(Справочники.ObjectPrintingForms.ClientPrintGuestAccommodationHistory.ObjectType) <> Type("CatalogRef.Клиенты") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.ClientPrintGuestAccommodationHistory.GetObject();
//		vFrmPrtObj.ObjectType = Справочники.Клиенты.EmptyRef();
//		If ЗначениеЗаполнено(vClientFolder) And vClientFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vClientFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.Примечания = "en='Print client's Размещение history'; ru='Распечатать историю проживаний клиента'";
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillClientObjectPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура FillCheckInCheckOutActionPictures()
//	#Если Клиент Тогда
//		// Reservation check-in action
//		vActObj = Справочники.ObjectFormActions.ReservationFillAccommodation.GetObject();
//		vActObj.ActionIcon = Новый ValueStorage(PictureLib.CheckIn);
//		vActObj.Write();
//		// Accommodation check-out action
//		vActObj = Справочники.ObjectFormActions.AccommodationCheckOut.GetObject();
//		vActObj.ActionIcon = Новый ValueStorage(PictureLib.ВыездФакт);
//		vActObj.Write();
//		// Accommodation group check-out action
//		vActObj = Справочники.ObjectFormActions.AccommodationGuestGroupCheckOut.GetObject();
//		vActObj.ActionIcon = Новый ValueStorage(PictureLib.ВыездФакт);
//		vActObj.Write();
//	#КонецЕсли
//КонецПроцедуры //FillCheckInCheckOutActionPictures
//
////-----------------------------------------------------------------------------
//Процедура FixExportForeignersDataToPVSOVD()
//	// Data processor
//	vDPObj = Справочники.Обработки.ExportForeignersDataToPVSOVD.GetObject();
//	If vDPObj.Processing <> "ExportForeignersDataToPVSOVD" Тогда
//		vDPObj.Processing = "ExportForeignersDataToPVSOVD";
//		vDPObj.Write();
//	EndIf;
//КонецПроцедуры //FixExportForeignersDataToPVSOVD
//
////-----------------------------------------------------------------------------
//Процедура FillAllowedAnnulationDelayTime()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.AllowedAnnulationDelayTime = 15;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //FillAllowedAnnulationDelayTime
//
////-----------------------------------------------------------------------------
//Процедура ClearHotelFromChargingRuleTemplateFolios()
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Folios.СчетПроживания AS СчетПроживания,
//	|	Folios.PointInTime AS PointInTime
//	|FROM
//	|	(SELECT
//	|		CustomersChargingRules.ChargingFolio AS СчетПроживания,
//	|		CustomersChargingRules.ChargingFolio.PointInTime AS PointInTime
//	|	FROM
//	|		Catalog.Customers.ChargingRules AS CustomersChargingRules
//	|	WHERE
//	|		CustomersChargingRules.ChargingFolio.Гостиница <> &qEmptyHotel
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		ContractsChargingRules.ChargingFolio,
//	|		ContractsChargingRules.ChargingFolio.PointInTime
//	|	FROM
//	|		Catalog.Contracts.ChargingRules AS ContractsChargingRules
//	|	WHERE
//	|		ContractsChargingRules.ChargingFolio.Гостиница <> &qEmptyHotel
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		ClientsChargingRules.ChargingFolio,
//	|		ClientsChargingRules.ChargingFolio.PointInTime
//	|	FROM
//	|		Catalog.Клиенты.ChargingRules AS ClientsChargingRules
//	|	WHERE
//	|		ClientsChargingRules.ChargingFolio.Гостиница <> &qEmptyHotel) AS Folios
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQry.SetParameter("qEmptyHotel", Справочники.Hotels.EmptyRef());
//	vFolios = vQry.Execute().Unload();
//	For Each vFoliosRow In vFolios Do
//		vFolioObj = vFoliosRow.ЛицевойСчет.GetObject();
//		vFolioObj.Гостиница = Справочники.Hotels.EmptyRef();
//		vFolioObj.Write(DocumentWriteMode.Write);
//	EndDo;
//КонецПроцедуры //ClearHotelFromChargingRuleTemplateFolios
//
////-----------------------------------------------------------------------------
//Процедура FillCustomerGuestsTurnoversReportSettings()
//	// Create audit reports group first
//	vTotalsReportsFolder = Справочники.Отчеты.EmptyRef();
//	vQry = Новый Запрос();
//	vQry.Text = "SELECT
//	            |	Отчеты.Ref
//	            |FROM
//	            |	Catalog.Отчеты AS Отчеты
//	            |WHERE
//	            |	Отчеты.Code = &qCode
//	            |	AND Отчеты.IsFolder
//	            |	AND (NOT Отчеты.DeletionMark)";
//	vQry.SetParameter("qCode", 500);
//	vFolders = vQry.Execute().Unload();
//	For Each vFoldersRow In vFolders Do
//		vTotalsReportsFolder = vFoldersRow.Ref;
//		Break;
//	EndDo;
//	// Fill report name and report folder for new reports
//	vRepRef = Справочники.Отчеты.CustomerGuestsTurnovers;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "CustomerGuestsTurnovers"; 
//		vRepObj.Parent = vTotalsReportsFolder;
//		vRepObj.ПорядокСортировки = 522;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate()) - 24*3600;
//		                            |REP.ПериодПо = EndOfDay(REP.ПериодС);";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillCustomerGuestsTurnoversReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillCustomerInitialBalancesActionSettings()
//	vCustomerFolder = Справочники.ObjectFormActions.FindByCode("1000");
//	If TypeOf(Справочники.ObjectFormActions.CustomerFillCustomerInitialBalances.ObjectType) <> Type("CatalogRef.Customers") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.CustomerFillCustomerInitialBalances.GetObject();
//		vFrmActObj.ObjectType = Справочники.Customers.EmptyRef();
//		If ЗначениеЗаполнено(vCustomerFolder) And vCustomerFolder.IsFolder Тогда
//			vFrmActObj.Parent = vCustomerFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillCustomerInitialBalancesActionSettings
//
////-----------------------------------------------------------------------------
//Процедура FillCustomerGuestsWithServicesReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.CustomerGuestsWithServices;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "CustomerGuestsWithServices"; 
//		vRepObj.ПорядокСортировки = 159;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillCustomerGuestsWithServicesReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillLostProfitsReportSettings()
//	// Find analysis Отдел reports folder
//	vAnalysisDepartmentReportsFolder = Справочники.Отчеты.FindByCode(500);
//	If ЗначениеЗаполнено(vAnalysisDepartmentReportsFolder) And НЕ vAnalysisDepartmentReportsFolder.IsFolder Тогда
//		vAnalysisDepartmentReportsFolder = Справочники.Отчеты.EmptyRef();
//	EndIf;
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.LostProfits;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Parent = vAnalysisDepartmentReportsFolder;
//		vRepObj.Report = "LostProfits"; 
//		vRepObj.ПорядокСортировки = 605;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(CurrentDate());";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillLostProfitsReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillIdentificationCardsAuditReportSettings()
//	// Find analysis Отдел reports folder
//	vAuditReportsFolder = Справочники.Отчеты.FindByCode(790);
//	If ЗначениеЗаполнено(vAuditReportsFolder) And НЕ vAuditReportsFolder.IsFolder Тогда
//		vAuditReportsFolder = Справочники.Отчеты.EmptyRef();
//	EndIf;
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.IdentificationCardsAudit;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.Report = "IdentificationCardsAudit"; 
//		vRepObj.ПорядокСортировки = 791;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate()) - 24*3600;
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillIdentificationCardsAuditReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillHotelProductsRegisterReportSettings()
//	// Find analysis Отдел reports folder
//	vHotelProductsReportsFolder = Справочники.Отчеты.FindByCode(1000);
//	If ЗначениеЗаполнено(vHotelProductsReportsFolder) And НЕ vHotelProductsReportsFolder.IsFolder Тогда
//		vHotelProductsReportsFolder = Справочники.Отчеты.EmptyRef();
//	EndIf;
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.HotelProductsRegister;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Parent = vHotelProductsReportsFolder;
//		vRepObj.Report = "HotelProductsRegister"; 
//		vRepObj.ПорядокСортировки = 896;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfMonth(CurrentDate());
//		                            |REP.ПериодПо = CurrentDate();";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillHotelProductsRegisterReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillReservationCheckInGuestGroupObjectFormActionSettings()
//	vReservationFolder = Справочники.ObjectFormActions.FindByCode("200");
//	If TypeOf(Справочники.ObjectFormActions.ReservationCheckInGuestGroup.ObjectType) <> Type("DocumentRef.Reservation") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ReservationCheckInGuestGroup.GetObject();
//		vFrmActObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vReservationFolder;
//		EndIf;
//		#Если Клиент Тогда
//			vFrmActObj.ActionIcon = PictureLib.CheckIn;
//		#КонецЕсли
//		vFrmActObj.Примечания = "en='Start check-in procedure for all guest group guests with check-in date equal to the check-in date of the reservation being opened'; 
//		                     |ru='Начать процедуру заселения для всех гостей из группы, у которых дата заезда совпадает с датой заезда открытой брони'";
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillReservationCheckInGuestGroupObjectFormActionSettings
//
////-----------------------------------------------------------------------------
//Процедура FillCheckIfReservationsWerePayedInTimeDataProcessorSettings()
//	// Fill data processor name and dynamic parameters
//	vDPRef = Справочники.Обработки.CheckIfReservationsWerePayedInTime;
//	If ЗначениеЗаполнено(vDPRef) And НЕ ЗначениеЗаполнено(vDPRef.Processing) Тогда
//		vDPObj = vDPRef.GetObject();
//		vDPObj.Processing = "CheckIfReservationsWerePayedInTime"; 
//		vDPObj.ПорядокСортировки = 205;
//		vDPObj.DynamicParameters = "If ЗначениеЗаполнено(PARM) Тогда
//		                           |	DPO.Гостиница = PARM;
//		                           |EndIf;";
//		vDPObj.Write();
//	EndIf;
//КонецПроцедуры //FillCheckIfReservationsWerePayedInTimeDataProcessorSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillClientHideNameAndNameHistoryActionSettings()
//	vClientFolder = Справочники.ObjectFormActions.FindByCode("1500");
//	If TypeOf(Справочники.ObjectFormActions.ClientHideNameAndNameHistory.ObjectType) <> Type("CatalogRef.Клиенты") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ClientHideNameAndNameHistory.GetObject();
//		vFrmActObj.ObjectType = Справочники.Клиенты.EmptyRef();
//		If ЗначениеЗаполнено(vClientFolder) And vClientFolder.IsFolder Тогда
//			vFrmActObj.Parent = vClientFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillClientHideNameAndNameHistoryActionSettings
//
////-----------------------------------------------------------------------------
//Процедура FillClientScanClientDataActionSettings()
//	vClientFolder = Справочники.ObjectFormActions.FindByCode("1500");
//	If TypeOf(Справочники.ObjectFormActions.ClientScanClientData.ObjectType) <> Type("CatalogRef.Клиенты") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.ClientScanClientData.GetObject();
//		vFrmActObj.ObjectType = Справочники.Клиенты.EmptyRef();
//		If ЗначениеЗаполнено(vClientFolder) And vClientFolder.IsFolder Тогда
//			vFrmActObj.Parent = vClientFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.ActionIcon = Новый ValueStorage(PictureLib.Scaner);
//		vFrmActObj.ButtonCaption = NStr("en='Scan passport data'; de='Scan passport data'; ru='Сканировать паспорт'");
//		vFrmActObj.ButtonToolTip = NStr("en='Scan client passport data'; de='Scan client passport data'; ru='Сканировать страницы паспорта клиента'");
//		vFrmActObj.Write();
//		// Update scan accommodation scan client data attributes
//		vFrmActObj = Справочники.ObjectFormActions.AccommodationScanClientData.GetObject();
//		vFrmActObj.ActionIcon = Новый ValueStorage(PictureLib.Scaner);
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillClientScanClientDataActionSettings
//
////-----------------------------------------------------------------------------
//Процедура FillFolioPrintHotelProductObjectPrintFormsSettings()
//	vFolioFolder = Справочники.ObjectPrintingForms.FindByCode("500");
//	If TypeOf(Справочники.ObjectPrintingForms.FolioPrintHotelProduct.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.FolioPrintHotelProduct.GetObject();
//		vFrmPrtObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.Примечания = "en='Print folio hotel product'; ru='Распечатать путевку указанную в лицевом счете'";
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillFolioPrintHotelProductObjectPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Function FillIsHotelProductServiceAttribute()
//	vFoundHotelProductServices = False;
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	HotelProductSalesTurnovers.Услуга,
//	|	HotelProductSalesTurnovers.SalesTurnover,
//	|	HotelProductSalesTurnovers.QuantityTurnover
//	|FROM
//	|	AccumulationRegister.ПродажиПутевокКурсовок.Turnovers AS HotelProductSalesTurnovers
//	|
//	|ORDER BY
//	|	HotelProductSalesTurnovers.Услуга.ПорядокСортировки,
//	|	HotelProductSalesTurnovers.Услуга.Description";
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do 
//		vSrvObj = vQryResRow.Service.GetObject();
//		vSrvObj.IsHotelProductService = True;
//		vSrvObj.Write();
//		vFoundHotelProductServices = True;
//	EndDo;
//	Return vFoundHotelProductServices;
//EndFunction //FillIsHotelProductServiceAttribute 
//
////-----------------------------------------------------------------------------
//Процедура RepostChargesAndStorno(pPeriodFrom, pPeriodTo)
//#Если Клиент Тогда
//	Status(NStr("en='Reposting charges and storno...'; de='Reposting charges and storno...'; ru='Перепроведение начислений и сторно...'"));
//#КонецЕсли
//	// Run query to get documents
//	vStatusMessage = "";
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НачислениеУслуг.Ref AS Document,
//	|	НачислениеУслуг.ДатаДок AS Date,
//	|	НачислениеУслуг.PointInTime AS PointInTime
//	|FROM
//	|	Document.Начисление AS НачислениеУслуг
//	|		LEFT JOIN AccumulationRegister.Продажи AS SalesMovements
//	|		ON НачислениеУслуг.Ref = SalesMovements.Recorder
//	|WHERE
//	|	НачислениеУслуг.Posted
//	|	AND НачислениеУслуг.ДатаДок >= &qPeriodFrom
//	|	AND НачислениеУслуг.ДатаДок <= &qPeriodTo
//	|	AND SalesMovements.Recorder IS NULL 
//	|
//	|UNION ALL
//	|
//	|SELECT
//	|	Сторно.Ref,
//	|	Сторно.ДатаДок,
//	|	Сторно.PointInTime
//	|FROM
//	|	Document.Сторно AS Сторно
//	|		LEFT JOIN AccumulationRegister.Продажи AS SalesMovements
//	|		ON Сторно.Ref = SalesMovements.Recorder
//	|WHERE
//	|	Сторно.Posted
//	|	AND Сторно.ДатаДок >= &qPeriodFrom
//	|	AND Сторно.ДатаДок <= &qPeriodTo
//	|	AND SalesMovements.Recorder IS NULL 
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
//	vQry.SetParameter("qPeriodTo", pPeriodTo);
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	vCount = vQryRes.Count();
//	// Repost charges and storno
//	i = 0;
//	For Each vQryResRow In vQryRes Do
//		i = i + 1;
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			If TypeOf(vCurDocObj.Ref) = Type("DocumentRef.Начисление") Тогда
//				If vCurDocObj.Цена = 0 And vCurDocObj.Сумма <> 0 Тогда
//					If vCurDocObj.Количество = 0 Тогда
//						vCurDocObj.Количество = 1;
//						vCurDocObj.Цена = vCurDocObj.Сумма;
//					Else
//						vCurDocObj.Цена = Round(vCurDocObj.Сумма/vCurDocObj.Количество, 2);
//					EndIf;
//				EndIf;
//				If ЗначениеЗаполнено(vCurDocObj.СчетПроживания) And vCurDocObj.СчетПроживания.DeletionMark Тогда
//					vCurDocObj.СчетПроживания.GetObject().SetDeletionMark(False);
//				EndIf;
//			EndIf;
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			vStatusMessage = NStr("en='Reposting charges and storno at " + Формат(vCurDate, "DF=dd.MM.yyyy") + " (" + i + " from " + vCount + ") ...'; 
//			                      |de='Reposting charges and storno at " + Формат(vCurDate, "DF=dd.MM.yyyy") + " (" + i + " from " + vCount + ") ...'; 
//			                      |ru='Перепроведение начислений и сторно за " + Формат(vCurDate, "DF=dd.MM.yyyy") + " (" + i + " из " + vCount + ") ...'");
//			Status(vStatusMessage);
//		EndIf;
//		// Wait 2 seconds every 15 charges
//		If Int(i/15) = (i/15) Тогда
//			vCurTime = CurrentDate() + 2;
//			While vCurTime <= CurrentDate() Do
//				Status(NStr("en='Giving 2 seconds to others to work...'; de='Giving 2 seconds to others to work...'; ru='Даем 2 секунды поработать другим...'"));
//			EndDo;				
//			Status(vStatusMessage);
//		EndIf;
//		// User interrupt processing
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostChargesAndStorno
//
////-----------------------------------------------------------------------------
//Процедура RepostSettlements()
//#Если Клиент Тогда
//	Status(NStr("en='Reposting settlements...'; de='Reposting settlements...'; ru='Перепроведение актов...'"));
//#КонецЕсли
//	// Run query to get documents
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Settlements.Ref AS Document,
//	|	Settlements.ДатаДок AS Date,
//	|	Settlements.PointInTime AS PointInTime
//	|FROM
//	|	Document.Акт AS Settlements
//	|WHERE
//	|	Settlements.Posted
//	|
//	|ORDER BY
//	|	Date,
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	vCount = vQryRes.Count();
//	// Repost settlements
//	i = 0;
//	For Each vQryResRow In vQryRes Do
//		i = i + 1;
//		vCurDocObj = vQryResRow.Document.GetObject();
//		For Each vSrvRow In vCurDocObj.Услуги Do
//			If ЗначениеЗаполнено(vSrvRow.Начисление) Тогда
//				vSrvRow.ПутевкаКурсовка = vSrvRow.Начисление.ПутевкаКурсовка;
//			EndIf;
//		EndDo;
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Reposting settlements at " + Формат(vCurDate, "DF=dd.MM.yyyy") + " (" + i + " from " + vCount + ") ...'; 
//			            |de='Reposting settlements at " + Формат(vCurDate, "DF=dd.MM.yyyy") + " (" + i + " from " + vCount + ") ...'; 
//			            |ru='Перепроведение актов за " + Формат(vCurDate, "DF=dd.MM.yyyy") + " (" + i + " из " + vCount + ") ...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //RepostSettlements
//
////-----------------------------------------------------------------------------
//Процедура ConvertQueryText(vQueryText)
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.CustomerSalesForecast", "AccumulationRegister.ПрогнозПродаж");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.CustomerSales", "AccumulationRegister.Продажи");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.ПланПродажРесурсов", "AccumulationRegister.ПрогнозПродаж");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.ResourceSales", "AccumulationRegister.Продажи");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.RoomSalesForecast", "AccumulationRegister.ПрогнозПродаж");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.RoomSales", "AccumulationRegister.Продажи");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.ServiceSalesForecast", "AccumulationRegister.ПрогнозПродаж");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.ServiceSales", "AccumulationRegister.Продажи");
//	vQueryText = StrReplace(vQueryText, "AccumulationRegister.GeographicSales", "AccumulationRegister.Продажи");
//	vQueryText = StrReplace(vQueryText, "ПланПродажРесурсов.Сумма AS", "ПланПродажРесурсов.Продажи AS");
//	vQueryText = StrReplace(vQueryText, "ПланПродажРесурсов.SumWithoutVAT AS", "ПланПродажРесурсов.ПродажиБезНДС AS");
//	vQueryText = StrReplace(vQueryText, "ResourceSales.SumTurnover AS", "ResourceSales.SalesTurnover AS");
//	vQueryText = StrReplace(vQueryText, "ResourceSales.SumWithoutVATTurnover AS", "ResourceSales.SalesWithoutVATTurnover AS");
//	vQueryText = StrReplace(vQueryText, "ResourceSalesForecastTurnovers.SumTurnover", "ResourceSalesForecastTurnovers.SalesTurnover");
//	vQueryText = StrReplace(vQueryText, "ResourceSalesForecastTurnovers.SumWithoutVATTurnover", "ResourceSalesForecastTurnovers.SalesWithoutVATTurnover");
//	vQueryText = StrReplace(vQueryText, "ОборотПродажРесурсов.SumTurnover", "ОборотПродажРесурсов.SalesTurnover");
//	vQueryText = StrReplace(vQueryText, "ОборотПродажРесурсов.SumWithoutVATTurnover", "ОборотПродажРесурсов.SalesWithoutVATTurnover");
//	vQueryText = StrReplace(vQueryText, "ResourceSales.Сумма AS", "ResourceSales.Продажи AS");
//	vQueryText = StrReplace(vQueryText, "ResourceSales.SumWithoutVAT AS", "ResourceSales.ПродажиБезНДС AS");
//	vQueryText = StrReplace(vQueryText, "ПланПродажРесурсов.Сумма,", "ПланПродажРесурсов.Продажи,");
//	vQueryText = StrReplace(vQueryText, "ПланПродажРесурсов.SumWithoutVAT,", "ПланПродажРесурсов.ПродажиБезНДС,");
//	vQueryText = StrReplace(vQueryText, "ResourceSales.Сумма,", "ResourceSales.Продажи,");
//	vQueryText = StrReplace(vQueryText, "ResourceSales.SumWithoutVAT,", "ResourceSales.ПродажиБезНДС,");
//	vQueryText = StrReplace(vQueryText, "ServiceSalesForecast.SumTurnover", "ServiceSalesForecast.SalesTurnover");
//	vQueryText = StrReplace(vQueryText, "ServiceSalesForecast.SumWithoutVATTurnover", "ServiceSalesForecast.SalesWithoutVATTurnover");
//	vQueryText = StrReplace(vQueryText, "ServiceSales.Сумма", "ServiceSales.Продажи");
//	vQueryText = StrReplace(vQueryText, "ServiceSales.SumWithoutVAT", "ServiceSales.ПродажиБезНДС");
//	vQueryText = StrReplace(vQueryText, "ServiceSalesForecast.Сумма", "ServiceSalesForecast.Продажи");
//	vQueryText = StrReplace(vQueryText, "ServiceSalesForecast.SumWithoutVAT", "ServiceSalesForecast.ПродажиБезНДС");
//	vQueryText = StrReplace(vQueryText, "ПродажиКвот.Агент", "ПродажиКвот.КвотаНомеров.Агент");
//	vQueryText = StrReplace(vQueryText, "ПродажиКвот.Контрагент", "ПродажиКвот.КвотаНомеров.Контрагент");
//	vQueryText = StrReplace(vQueryText, "ПродажиКвот.Договор", "ПродажиКвот.КвотаНомеров.Договор");
//	If Find(vQueryText, "AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(") > 0 Тогда
//		vQueryText = StrReplace(vQueryText, "AND (Агент IN HIERARCHY (&qAgent)", "AND (КвотаНомеров.Агент IN HIERARCHY (&qAgent)");
//		vQueryText = StrReplace(vQueryText, "AND (Контрагент IN HIERARCHY (&qCustomer)", "AND (КвотаНомеров.Контрагент IN HIERARCHY (&qCustomer)");
//		vQueryText = StrReplace(vQueryText, "AND (Договор = &qContract", "AND (КвотаНомеров.Договор = &qContract");
//	EndIf;
//КонецПроцедуры //ConvertQueryText 
//
////-----------------------------------------------------------------------------
//Процедура ConvertReports()
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Отчеты.Ref
//	|FROM
//	|	Catalog.Отчеты AS Отчеты
//	|WHERE
//	|	(NOT Отчеты.IsFolder)
//	|	AND (NOT Отчеты.DeletionMark)";
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do
//		vRep = vQryResRow.Ref;
//		vRB = Новый ReportBuilder();
//		// Process static parameters if are filled
//		vStatic = vRep.StaticParameters.Get();
//		If vStatic <> Неопределено Тогда
//			Try
//				vRBS = vStatic.ReportBuilderSettings;
//			Except
//				Continue;
//			EndTry;
//			Try
//				// Load report builder settings
//				If vStatic.ReportBuilderSettings <> Неопределено Тогда
//					// Update base query text
//					vQueryText = vStatic.QueryText;
//					ConvertQueryText(vQueryText);
//					vStatic.QueryText = vQueryText;
//					vRB.Text = vStatic.QueryText;
//					vRB.SetSettings(vStatic.ReportBuilderSettings, True, True, True, True, True);
//					vRB.Execute();
//					vStatic.Вставить("ReportBuilderSettings", vRB.GetSettings(True, True, True, True, True));
//				EndIf;
//			Except
//				vErrorText = ErrorDescription();
//				WriteLogEvent("ОбновлениеБД.ConverReports", EventLogLevel.Warning, , , TrimAll(vRep.Code) + " - " + vRep.Description + ": " + vErrorText);
//				Continue;
//			EndTry;
//		EndIf;
//		// Process dynamic parameters if are filled
//		vDynamic = TrimAll(vRep.DynamicParameters);
//		If НЕ IsBlankString(vDynamic) Тогда
//			ConvertQueryText(vDynamic);
//		EndIf;
//		// Update report
//		vRepObj = vRep.GetObject();
//		vRepObj.StaticParameters = Новый ValueStorage(vStatic);
//		vRepObj.DynamicParameters = vDynamic;
//		vRepObj.Write();
//	EndDo;
//КонецПроцедуры //ConvertReports
//
////-----------------------------------------------------------------------------
//Процедура FillClientsAgeRegionAndCity()
//	// Get all client items
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Клиенты.Ref
//	|FROM
//	|	Catalog.Клиенты AS Клиенты
//	|WHERE
//	|	(NOT Клиенты.DeletionMark)
//	|	AND (NOT Клиенты.IsFolder)
//	|
//	|ORDER BY
//	|	Клиенты.Code";
//	vQryRes = vQry.Execute().Unload();
//	vCount = vQryRes.Count();
//	i = 0;
//	For Each vQryResRow In vQryRes Do
//		i = i + 1;
//		vCltObj = vQryResRow.Ref.GetObject();
//		vCltObj.Write();
//		
//		
//#Если Клиент Тогда
//		// Status message
//		Status(NStr("en='Processing clients (" + i + " from " + vCount + ") ...'; 
//		            |de='Processing clients (" + i + " from " + vCount + ") ...'; 
//					|ru='Обработка клиентов (" + i + " из " + vCount + ") ...'"));
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillClientsAgeRegionAndCity
//
////-----------------------------------------------------------------------------
//Процедура FillForeignerRegistryRecordPrintForeignerCardFormObjectPrintFormsSettings()
//	vForeignerFolder = Справочники.ObjectPrintingForms.FindByCode("300");
//	If TypeOf(Справочники.ObjectPrintingForms.ForeignerRegistryRecordPrintForeignerCardForm.ObjectType) <> Type("DocumentRef.ForeignerRegistryRecord") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.ForeignerRegistryRecordPrintForeignerCardForm.GetObject();
//		vFrmPrtObj.ObjectType = Documents.ForeignerRegistryRecord.EmptyRef();
//		If ЗначениеЗаполнено(vForeignerFolder) And vForeignerFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vForeignerFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.Примечания = "";
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillForeignerRegistryRecordPrintForeignerCardFormObjectPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура FillFolioPrint3GFormObjectPrintFormsSettings()
//	vFolioFolder = Справочники.ObjectPrintingForms.FindByCode("500");
//	If TypeOf(Справочники.ObjectPrintingForms.FolioPrint3GForm.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.FolioPrint3GForm.GetObject();
//		vFrmPrtObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = False; // НЕ to be used by default
//		vFrmPrtObj.Примечания = "en='Print current payment 3-G form'; ru='Распечатать выбранный платеж на бланке формы 3-Г'";
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillFolioPrint3GFormObjectPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура FillIssueHotelProductsPrintHotelProductsLogPrintFormSettings()
//	vFolder = Справочники.ObjectPrintingForms.FindByCode("1600");
//	If TypeOf(Справочники.ObjectPrintingForms.IssueHotelProductsPrintHotelProductsLog.ObjectType) <> Type("DocumentRef.IssueHotelProducts") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.IssueHotelProductsPrintHotelProductsLog.GetObject();
//		vFrmPrtObj.ObjectType = Documents.IssueHotelProducts.EmptyRef();
//		If ЗначениеЗаполнено(vFolder) And vFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillIssueHotelProductsPrintHotelProductsLogPrintFormSettings
//
////-----------------------------------------------------------------------------
//Процедура FillExpectedGuestGroupsReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.ПланируемыеГруппы;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "ПланируемыеГруппы"; 
//		vRepObj.ПорядокСортировки = 240;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfMonth(EndOfMonth(CurrentDate()) + 1);";
//		vRepObj.DefaultSettings = Новый ValueStorage(cmReadReportDefaultSettingFromTemplate(vRepObj));
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillExpectedGuestGroupsReportSettings 
//
////-----------------------------------------------------------------------------
//Процедура FillReservationsNoShowReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.ReservationsNoShow;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "ReservationsHistory"; 
//		vRepObj.ПорядокСортировки = 227;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate()) - 24*3600;
//		                            |REP.ПериодПо = EndOfDay(REP.ПериодС);";
//		vRepObj.DefaultSettings = Новый ValueStorage(ThisObject.ПолучитьМакет("ReservationsNoShowReportDefaultSettings"));
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillReservationsNoShowReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillReservationAnnulationsReportSettings()
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.ReservationAnnulations;
//	vAuditFolder = Справочники.Отчеты.FindByCode("790");
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "ReservationAnnulations"; 
//		If ЗначениеЗаполнено(vAuditFolder) And vAuditFolder.IsFolder Тогда
//			vRepObj.Parent = vAuditFolder;
//		EndIf;
//		vRepObj.ПорядокСортировки = 793;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate()) - 24*3600;
//		                            |REP.ПериодПо = EndOfDay(REP.ПериодС);";
//		vRepObj.DefaultSettings = Новый ValueStorage(ThisObject.ПолучитьМакет("ReservationAnnulationsReportDefaultSettings"));
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillReservationAnnulationsReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillAgeRanges()
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	ВозрастныеГруппы.Ref
//	|FROM
//	|	Catalog.ВозрастныеГруппы AS AgeRanges";
//	vQryRes = vQry.Execute().Unload();
//	If vQryRes.Count() = 0 Тогда
//		vAgeRangeObj = Справочники.ВозрастныеГруппы.CreateItem();
//		vAgeRangeObj.Code = "CHLD";
//		vAgeRangeObj.Description = "Ребенок";
//		vAgeRangeObj.FromAge = 1;
//		vAgeRangeObj.ToAge = 14;
//		vAgeRangeObj.Write();
//		
//		vAgeRangeObj = Справочники.ВозрастныеГруппы.CreateItem();
//		vAgeRangeObj.Code = "TEEN";
//		vAgeRangeObj.Description = "Тинейджер";
//		vAgeRangeObj.FromAge = 15;
//		vAgeRangeObj.ToAge = 21;
//		vAgeRangeObj.Write();
//		
//		vAgeRangeObj = Справочники.ВозрастныеГруппы.CreateItem();
//		vAgeRangeObj.Code = "22-29";
//		vAgeRangeObj.Description = "От 22 до 29";
//		vAgeRangeObj.FromAge = 22;
//		vAgeRangeObj.ToAge = 29;
//		vAgeRangeObj.Write();
//		
//		vAgeRangeObj = Справочники.ВозрастныеГруппы.CreateItem();
//		vAgeRangeObj.Code = "30-39";
//		vAgeRangeObj.Description = "От 30 до 39";
//		vAgeRangeObj.FromAge = 30;
//		vAgeRangeObj.ToAge = 39;
//		vAgeRangeObj.Write();
//		
//		vAgeRangeObj = Справочники.ВозрастныеГруппы.CreateItem();
//		vAgeRangeObj.Code = "40-49";
//		vAgeRangeObj.Description = "От 40 до 49";
//		vAgeRangeObj.FromAge = 40;
//		vAgeRangeObj.ToAge = 49;
//		vAgeRangeObj.Write();
//		
//		vAgeRangeObj = Справочники.ВозрастныеГруппы.CreateItem();
//		vAgeRangeObj.Code = "50-59";
//		vAgeRangeObj.Description = "От 50 до 59";
//		vAgeRangeObj.FromAge = 50;
//		vAgeRangeObj.ToAge = 59;
//		vAgeRangeObj.Write();
//		
//		vAgeRangeObj = Справочники.ВозрастныеГруппы.CreateItem();
//		vAgeRangeObj.Code = "60";
//		vAgeRangeObj.Description = "Старше 60";
//		vAgeRangeObj.FromAge = 60;
//		vAgeRangeObj.ToAge = 150;
//		vAgeRangeObj.Write();
//	EndIf;
//КонецПроцедуры //FillAgeRanges
//
////-----------------------------------------------------------------------------
//Процедура FillCustomersDoNotPostCommission()
//	// Process hotels
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Hotels.Ref AS Ref,
//	|	Hotels.Code AS Code
//	|FROM
//	|	Catalog.Hotels AS Hotels
//	|WHERE
//	|	(NOT Hotels.DeletionMark)
//	|	AND (NOT Hotels.IsFolder)
//	|	AND (NOT Hotels.DoNotPostCommission)
//	|
//	|ORDER BY
//	|	Code";
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do
//		vItemObj = vQryResRow.Ref.GetObject();
//		vItemObj.DoNotPostCommission = True;
//		vItemObj.Write();
//	EndDo;
//	// Process customers
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Customers.Ref AS Ref,
//	|	Customers.CreateDate AS CreateDate,
//	|	Customers.Code AS Code
//	|FROM
//	|	Catalog.Customers AS Customers
//	|WHERE
//	|	NOT Customers.DeletionMark
//	|	AND NOT Customers.IsFolder
//	|	AND NOT Customers.DoNotPostCommission
//	|
//	|ORDER BY
//	|	CreateDate,
//	|	Code";
//	vQry.SetParameter("qEmptyAgentCommissionType", Перечисления.AgentCommissionTypes.EmptyRef());
//	vQryRes = vQry.Execute().Unload();
//	vCount = vQryRes.Count();
//	For Each vQryResRow In vQryRes Do
//		vItemObj = vQryResRow.Ref.GetObject();
//		vItemObj.DoNotPostCommission = True;
//		vItemObj.Write();
//		// Write to the change history
//		If TypeOf(vQryResRow.Ref) = Type("CatalogRef.Customers") Тогда
//			vItemObj.pmWriteToCustomerChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//		EndIf;
//		// Status
//		#Если Клиент Тогда
//			Status(NStr("en='Processed ';ru='Обработано ';de='Bearbeitet '") + (vQryRes.IndexOf(vQryResRow)+1) + NStr("en=' from '; de=' von '; ru=' из '") + vCount);
//			UserInterruptProcessing();
//		#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillCustomersDoNotPostCommission
//
////-----------------------------------------------------------------------------
//Процедура FillInvoicePrintPaymentOrderObjectPrintFormsSettings()
//	vInvoiceFolder = Справочники.ObjectPrintingForms.FindByCode("800");
//	If TypeOf(Справочники.ObjectPrintingForms.InvoicePrintPaymentOrder.ObjectType) <> Type("DocumentRef.СчетНаОплату") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.InvoicePrintPaymentOrder.GetObject();
//		vFrmPrtObj.ObjectType = Documents.СчетНаОплату.EmptyRef();
//		If ЗначениеЗаполнено(vInvoiceFolder) And vInvoiceFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vInvoiceFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.Примечания = "";
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillInvoicePrintPaymentOrderObjectPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура Fill121122UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToCreateReservationsWithoutContactClientAndCustomerData = True;
//			If vPGObj.HavePermissionToManageRoomInventory Тогда
//				vPGObj.HavePermissionToManageAllotments = True;
//			EndIf;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill121122UserPermission
//
////-----------------------------------------------------------------------------
//Процедура FillCustomerAdvanceDistributionActionSettings()
//	vCustomerFolder = Справочники.ObjectFormActions.FindByCode("1000");
//	vFrmActObj = Справочники.ObjectFormActions.CustomerFillCustomerAdvanceDistribution.GetObject();
//	vFrmActObj.ObjectType = Справочники.Customers.EmptyRef();
//	If ЗначениеЗаполнено(vCustomerFolder) And vCustomerFolder.IsFolder Тогда
//		vFrmActObj.Parent = vCustomerFolder;
//	EndIf;
//	vFrmActObj.IsActive = True;
//	vFrmActObj.ButtonCaption = "EN='Контрагент advance distribution (Ctrl+F10)'; RU='Распределение аванса (Ctrl+F10)'";
//	vFrmActObj.ButtonToolTip = "EN='Новый Контрагент advance distribution'; RU='Новое распределение аванса контрагента'";
//	vFrmActObj.Примечания = "EN='Create new Контрагент advance distribution'; RU='Создать новый документ распределения аванса контрагента'";
//	vFrmActObj.Write();
//КонецПроцедуры //FillCustomerAdvanceDistributionActionSettings
//
////-----------------------------------------------------------------------------
//Процедура FillContractAdvanceDistributionActionSettings()
//	vContractFolder = Справочники.ObjectFormActions.FindByCode("1100");
//	vFrmActObj = Справочники.ObjectFormActions.ContractFillCustomerAdvanceDistribution.GetObject();
//	vFrmActObj.ObjectType = Справочники.Contracts.EmptyRef();
//	If ЗначениеЗаполнено(vContractFolder) And vContractFolder.IsFolder Тогда
//		vFrmActObj.Parent = vContractFolder;
//	EndIf;
//	vFrmActObj.IsActive = True;
//	vFrmActObj.ButtonCaption = "EN='Контрагент advance distribution (Ctrl+F10)'; RU='Распределение аванса (Ctrl+F10)'";
//	vFrmActObj.ButtonToolTip = "EN='Новый Контрагент advance distribution'; RU='Новое распределение аванса контрагента'";
//	vFrmActObj.Примечания = "EN='Create new Контрагент advance distribution'; RU='Создать новый документ распределения аванса контрагента'";
//	vFrmActObj.Write();
//КонецПроцедуры //FillContractAdvanceDistributionActionSettings
//
////-----------------------------------------------------------------------------
//Процедура Fill124UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToIgnoreAccommodationTemplates = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill124UserPermission
//
////-----------------------------------------------------------------------------
//Процедура FillFolioPrintChargePrintFormsSettings()
//	vFolioFolder = Справочники.ObjectPrintingForms.FindByCode("500");
//	If TypeOf(Справочники.ObjectPrintingForms.FolioPrintChargeRu.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.FolioPrintChargeRu.GetObject();
//		vFrmPrtObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.Language = Справочники.Локализация.RU;
//		vFrmPrtObj.Примечания = "en='Print selected charge details in Russian'; ru='Распечатать детализацию по выбранному в лицевом счете начислению по русски'";
//		vFrmPrtObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectPrintingForms.FolioPrintChargeEn.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.FolioPrintChargeEn.GetObject();
//		vFrmPrtObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.Language = Справочники.Локализация.EN;
//		vFrmPrtObj.Примечания = "en='Print selected charge details in English'; ru='Распечатать детализацию по выбранному в лицевом счете начислению по английски'";
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillFolioPrintChargePrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура FillAccommodationFillInvoiceActionSettings()
//	vAccommodationFolder = Справочники.ObjectFormActions.FindByCode("100");
//	If TypeOf(Справочники.ObjectFormActions.AccommodationFillInvoice.ObjectType) <> Type("DocumentRef.Размещение") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.AccommodationFillInvoice.GetObject();
//		vFrmActObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vAccommodationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.AccommodationGuestGroupFillInvoice.ObjectType) <> Type("DocumentRef.Размещение") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.AccommodationGuestGroupFillInvoice.GetObject();
//		vFrmActObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vFrmActObj.Parent = vAccommodationFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillAccommodationFillInvoiceActionSettings
//
////-----------------------------------------------------------------------------
//Процедура FillGuestsWithBirthDayReportSettings()
//	// Fill report parameters
//	vRepRef = Справочники.Отчеты.FindByCode(103);
//	If ЗначениеЗаполнено(vRepRef) And vRepRef.Report <> "GuestsWithBirthday" Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Description = "EN='Guests with birthday'; RU='Гости, у которых день рождения'";
//		vRepObj.Report = "GuestsWithBirthday"; 
//		vRepObj.ПорядокСортировки = 103;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate());
//		                            |REP.ПериодПо = EndOfDay(REP.ПериодС);";
//		vRepObj.DefaultSettings = Новый ValueStorage(ThisObject.ПолучитьМакет("GuestsWithBirthdayReportDefaultSettings"));
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillGuestsWithBirthDayReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillActiveReservationsSortCode()
//#Если Клиент Тогда
//	Status(NStr("en='Fill reservation sort codes...'; de='Fill reservation sort codes...'; ru='Заполнение кода сортировки у действующей брони...'"));
//#КонецЕсли
//	// Run query to get active reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref AS Document,
//	|	Reservation.ДатаДок AS Date,
//	|	Reservation.PointInTime AS PointInTime
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.ReservationStatus.IsActive
//	|	AND Reservation.Posted
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Write active reservations
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Write);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.Date) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.Date);
//			Status(NStr("en='Processing reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Processing reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Обработка действующей брони за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillActiveReservationsSortCode
//
////-----------------------------------------------------------------------------
//Процедура FillInHouseAccommodationsSortCode()
//#Если Клиент Тогда
//	Status(NStr("en='Fill in-house accommodations sort code...'; de='Fill in-house accommodations sort code...'; ru='Заполнение кода сортировки у проживающих гостей...'"));
//#КонецЕсли
//	// Run query to get in-house accommodations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Размещение.Ref AS Document,
//	|	Размещение.ДатаДок AS Date,
//	|	Размещение.PointInTime AS PointInTime
//	|FROM
//	|	Document.Размещение AS Размещение
//	|WHERE
//	|	Размещение.СтатусРазмещения.IsActive
//	|	AND Размещение.СтатусРазмещения.ЭтоГости
//	|	AND Размещение.Posted
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQryRes = vQry.Execute().Choose();
//	vCurDate = '00010101';
//	While vQryRes.Next() Do
//		vCurDocObj = vQryRes.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Write);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryRes.ДатаДок) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryRes.ДатаДок);
//			Status(NStr("en='Processing in-house accommodations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Processing in-house accommodations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Обработка текущих размещений за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //FillInHouseAccommodationsSortCode
//
////-----------------------------------------------------------------------------
//Процедура FillSMSDeliveryPrintReceiversObjectPrintFormsSettings()
//	vSMSDeliveryFolder = Справочники.ObjectPrintingForms.FindByCode("1800");
//	If НЕ ЗначениеЗаполнено(vSMSDeliveryFolder) Тогда
//		vSMSDeliveryFolderObj = Справочники.ObjectPrintingForms.CreateFolder();
//		vSMSDeliveryFolderObj.Code = "1800";
//		vSMSDeliveryFolderObj.Description = NStr("en='Messages delivery';ru='Рассылка сообщений';de='Versand von Mitteilungen'");
//		vSMSDeliveryFolderObj.Write();
//		vSMSDeliveryFolder = vSMSDeliveryFolderObj.Ref;
//	EndIf;
//	If TypeOf(Справочники.ObjectPrintingForms.SMSDeliveryPrintReceivers.ObjectType) <> Type("DocumentRef.SMSDelivery") Тогда
//		vFrmPrtObj = Справочники.ObjectPrintingForms.SMSDeliveryPrintReceivers.GetObject();
//		vFrmPrtObj.ObjectType = Documents.SMSDelivery.EmptyRef();
//		If ЗначениеЗаполнено(vSMSDeliveryFolder) And vSMSDeliveryFolder.IsFolder Тогда
//			vFrmPrtObj.Parent = vSMSDeliveryFolder;
//		EndIf;
//		vFrmPrtObj.IsActive = True;
//		vFrmPrtObj.IsDefault = True;
//		vFrmPrtObj.Примечания = "";
//		vFrmPrtObj.Write();
//	EndIf;
//КонецПроцедуры //FillSMSDeliveryPrintReceiversObjectPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура FillSMSDeliveryObjectFormActionSettingsFolder()
//	vSMSDeliveryFolder = Справочники.ObjectFormActions.FindByCode("1600");
//	If НЕ ЗначениеЗаполнено(vSMSDeliveryFolder) Тогда
//		vSMSDeliveryFolderObj = Справочники.ObjectFormActions.CreateFolder();
//		vSMSDeliveryFolderObj.Code = "1600";
//		vSMSDeliveryFolderObj.Description = NStr("en='Messages delivery';ru='Рассылка сообщений';de='Versand von Mitteilungen'");
//		vSMSDeliveryFolderObj.Write();
//	EndIf;
//КонецПроцедуры //FillSMSDeliveryObjectFormActionSettingsFolder
//
////-----------------------------------------------------------------------------
//Процедура FillSMSBeingSentReportSettings()
//	// Find analitical reports folder
//	vOtherReportsFolder = Справочники.Отчеты.FindByCode(900);
//	// Fill report name and report folder for new report
//	vRepRef = Справочники.Отчеты.SMSBeingSent;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "SMSBeingSent"; 
//		If ЗначениеЗаполнено(vOtherReportsFolder) And vOtherReportsFolder.IsFolder Тогда
//			vRepObj.Parent = vOtherReportsFolder;
//		EndIf;
//		vRepObj.ПорядокСортировки = 960;
//		vRepObj.Write();
//	EndIf;
//	// Move messages report to the same folder
//	If ЗначениеЗаполнено(vOtherReportsFolder) And vOtherReportsFolder.IsFolder Тогда
//		vRepRef = Справочники.Отчеты.Задачи;
//		If НЕ ЗначениеЗаполнено(vRepRef.Parent) Тогда
//			vRepObj = vRepRef.GetObject();
//			vRepObj.Parent = vOtherReportsFolder;
//			vRepObj.Write();
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillSMSBeingSentReportSettings
//
////-----------------------------------------------------------------------------
//Процедура Fill126UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			If vPGObj.HavePermissionToSeeAllMessages Тогда
//				vPGObj.HavePermissionToMessagesDelivery = True;
//				vPGObj.Write();
//			EndIf;
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill126UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill127UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			If vPGObj.HavePermissionToEditExportedSettlements Тогда
//				vPGObj.HavePermissionToRecalculateInvoicesBeingAlreadyPaid = True;
//				vPGObj.Write();
//			EndIf;
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill127UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill128UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToDoBookingWithoutCustomerContactData = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill128UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill129UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToCreateCustomersWithoutTIN = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill129UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill130UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToEditInactiveReservations = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill130UserPermission
//
////-----------------------------------------------------------------------------
//Процедура FillAccommodationPrintArrivalSheetFormObjectPrintingFormSetings()
//	If TypeOf(Справочники.ObjectPrintingForms.AccommodationPrintArrivalSheetForm.ObjectType) <> Type("DocumentRef.Размещение") Тогда
//		vAccommodationFolder = Справочники.ObjectPrintingForms.FindByCode("100");
//		vPrtFormObj = Справочники.ObjectPrintingForms.AccommodationPrintArrivalSheetForm.GetObject();
//		vPrtFormObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vPrtFormObj.Parent = vAccommodationFolder;
//		EndIf;
//		vPrtFormObj.IsActive = True;
//		vPrtFormObj.Примечания = "";
//		vPrtFormObj.Write();
//	EndIf;
//КонецПроцедуры //FillAccommodationPrintArrivalSheetFormObjectPrintingFormSetings
//
////-----------------------------------------------------------------------------
//Процедура FillReservationPrintGuestFormObjectPrintFormsSettings()
//	If TypeOf(Справочники.ObjectPrintingForms.ReservationPrintGuestFormForm5.ObjectType) <> Type("DocumentRef.Reservation") Тогда
//		vReservationFolder = Справочники.ObjectPrintingForms.FindByCode("200");
//		
//		vPrtFormObj = Справочники.ObjectPrintingForms.ReservationPrintGuestFormForm5.GetObject();
//		vPrtFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vPrtFormObj.Parent = vReservationFolder;
//		EndIf;
//		vPrtFormObj.IsActive = True;
//		vPrtFormObj.Write();
//		
//		vPrtFormObj = Справочники.ObjectPrintingForms.ReservationPrintGuestForm2Forms5.GetObject();
//		vPrtFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vPrtFormObj.Parent = vReservationFolder;
//		EndIf;
//		vPrtFormObj.IsActive = True;
//		vPrtFormObj.Write();
//		
//		vPrtFormObj = Справочники.ObjectPrintingForms.ReservationPrintGuestsFormsForm5.GetObject();
//		vPrtFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vPrtFormObj.Parent = vReservationFolder;
//		EndIf;
//		vPrtFormObj.IsActive = True;
//		vPrtFormObj.Write();
//		
//		vPrtFormObj = Справочники.ObjectPrintingForms.ReservationPrintGuestsForms2Forms5.GetObject();
//		vPrtFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		If ЗначениеЗаполнено(vReservationFolder) And vReservationFolder.IsFolder Тогда
//			vPrtFormObj.Parent = vReservationFolder;
//		EndIf;
//		vPrtFormObj.IsActive = True;
//		vPrtFormObj.Write();
//	EndIf;
//КонецПроцедуры //FillReservationPrintGuestFormObjectPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура FillFolioGiftCertificatesActionSettings()
//	vFolioFolder = Справочники.ObjectFormActions.FindByCode("500");
//	If TypeOf(Справочники.ObjectFormActions.FolioBlockGiftCertificate.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.FolioBlockGiftCertificate.GetObject();
//		vFrmActObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmActObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.FolioShowGiftCertificate.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.FolioShowGiftCertificate.GetObject();
//		vFrmActObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmActObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//	If TypeOf(Справочники.ObjectFormActions.FolioIssueGiftCertificate.ObjectType) <> Type("DocumentRef.СчетПроживания") Тогда
//		vFrmActObj = Справочники.ObjectFormActions.FolioIssueGiftCertificate.GetObject();
//		vFrmActObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//		If ЗначениеЗаполнено(vFolioFolder) And vFolioFolder.IsFolder Тогда
//			vFrmActObj.Parent = vFolioFolder;
//		EndIf;
//		vFrmActObj.IsActive = True;
//		vFrmActObj.Write();
//	EndIf;
//КонецПроцедуры //FillFolioGiftCertificatesActionSettings
//
////-----------------------------------------------------------------------------
//Процедура FillActiveGiftCertificatesReportSettings()
//	// Find accounting reports folder
//	vAccountingReportsFolder = Справочники.Отчеты.FindByCode(500);
//	// Fill report parameters
//	vRepRef = Справочники.Отчеты.ПодарочСертификатСведения;
//	If ЗначениеЗаполнено(vRepRef) And vRepRef.Report <> "ActiveGiftCertificates" Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Примечания = "EN='Report shows open, not blocked gift certificates with balances'; RU='Отчет показывает список действующих, не заблокированных подарочных сертификатов, по которым не израсходованы все средства'";
//		vRepObj.Report = "ActiveGiftCertificates"; 
//		If ЗначениеЗаполнено(vAccountingReportsFolder) And vAccountingReportsFolder.IsFolder Тогда
//			vRepObj.Parent = vAccountingReportsFolder;
//		EndIf;
//		vRepObj.ПорядокСортировки = 970;
//		vRepObj.DynamicParameters = "REP.Period = CurrentDate();";
//		vRepObj.DefaultSettings = Новый ValueStorage(ThisObject.ПолучитьМакет("ActiveGiftCertificatesReportDefaultSettings"));
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillActiveGiftCertificatesReportSettings
//
////-----------------------------------------------------------------------------
//Процедура ChangeNorweqVisionConnectionType()
//	vQry = Новый Запрос();
//	vQry.Text =
//	"SELECT
//	|	DoorLockSystemParameters.Ref
//	|FROM
//	|	Catalog.DoorLockSystemParameters AS DoorLockSystemParameters
//	|WHERE
//	|	NOT DoorLockSystemParameters.IsFolder
//	|	AND DoorLockSystemParameters.DoorLockSystemType IN (&qDoorLockSystemTypeList)
//	|	AND DoorLockSystemParameters.ConnectionType = &qConnectionType
//	|
//	|ORDER BY
//	|	DoorLockSystemParameters.Code";
//	vList = Новый СписокЗначений();
//	vList.Add(Перечисления.DoorLockSystems.VingCardVision);
//	vList.Add(Перечисления.DoorLockSystems.VingCardDavinci);
//	vQry.SetParameter("qDoorLockSystemTypeList", vList);
//	vQry.SetParameter("qConnectionType", Перечисления.ConnectionTypes.TCPIP);
//	vSettings = vQry.Execute().Unload();
//	For Each vSettingsRow In vSettings Do
//		vSettingsObj = vSettingsRow.Ref.GetObject();
//		vSettingsObj.ConnectionType = Перечисления.ConnectionTypes.VisionIntDll;
//		vSettingsObj.Write();
//	EndDo;
//КонецПроцедуры //ChangeNorweqVisionConnectionType
//
////-----------------------------------------------------------------------------
//Процедура FillDoNightAuditPrecheckDataProcessorSettings()
//	// Fill data processor name and dynamic parameters
//	vDPRef = Справочники.Обработки.DoNightAuditPrecheck;
//	If ЗначениеЗаполнено(vDPRef) And НЕ ЗначениеЗаполнено(vDPRef.Processing) Тогда
//		vDPObj = vDPRef.GetObject();
//		vDPObj.Processing = "DoNightAuditPrecheck"; 
//		vDPObj.ПорядокСортировки = 510;
//		vDPObj.DynamicParameters = "If ЗначениеЗаполнено(PARM) Тогда
//		                           |	DPO.Гостиница = PARM;
//		                           |EndIf;";
//		vDPObj.Write();
//	EndIf;
//КонецПроцедуры //FillDoNightAuditPrecheckDataProcessorSettings
//
////-----------------------------------------------------------------------------
//Процедура FillServicePackageRecordsInformationRegister()
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	ПакетыУслуг.Ref
//	|FROM
//	|	Catalog.ПакетыУслуг AS ПакетыУслуг
//	|WHERE
//	|	NOT ПакетыУслуг.IsFolder
//	|	AND NOT ПакетыУслуг.DeletionMark
//	|
//	|ORDER BY
//	|	ПакетыУслуг.ПорядокСортировки,
//	|	ПакетыУслуг.Code";
//	vServicePackages = vQry.Execute().Unload();
//	For Each vServicePackagesRow In vServicePackages Do
//		vServicePackageObj = vServicePackagesRow.Ref.GetObject();
//		vServicePackageObj.Write();
//	EndDo;
//КонецПроцедуры //FillServicePackageRecordsInformationRegister
//
////-----------------------------------------------------------------------------
//Процедура SimpleRepostActiveReservations()
//#Если Клиент Тогда
//	Status(NStr("en='Reposting active reservations...'; de='Reposting active reservations...'; ru='Перепроведение действующей брони...'"));
//#КонецЕсли
//	// Run query to get active reservations
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref AS Document,
//	|	Reservation.CheckInDate AS CheckInDate,
//	|	Reservation.PointInTime AS PointInTime
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.ReservationStatus.IsActive
//	|	AND Reservation.Posted
//	|
//	|ORDER BY
//	|	CheckInDate,
//	|	PointInTime";
//	vQryRes = vQry.Execute().Unload();
//	vCurDate = '00010101';
//	// Undo posting active reservations first
//	For Each vQryResRow In vQryRes Do
//		vCurDocObj = vQryResRow.Document.GetObject();
//		Try
//			vCurDocObj.Write(DocumentWriteMode.Posting);
//		Except
//			Message(Строка(vCurDocObj) + NStr("en=' - error: '; de=' - Fehler: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//		
//#Если Клиент Тогда
//		// Status message
//		If BegOfDay(vQryResRow.CheckInDate) <> vCurDate Тогда
//			vCurDate = BegOfDay(vQryResRow.CheckInDate);
//			Status(NStr("en='Reposting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |de='Reposting active reservations on " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'; 
//			            |ru='Перепроведение действующей брони за " + Формат(vCurDate, "DF=dd.MM.yyyy") + "...'"));
//		EndIf;
//		UserInterruptProcessing();
//#КонецЕсли
//	EndDo;
//КонецПроцедуры //SimpleRepostActiveReservations
//
////-----------------------------------------------------------------------------
//Процедура FillGermanPrintingFormsSettings()
//	vInvoiceFolder = Справочники.ObjectPrintingForms.FindByCode("800");
//	If ЗначениеЗаполнено(vInvoiceFolder) And НЕ vInvoiceFolder.IsFolder Тогда
//		vInvoiceFolder = Неопределено;
//	EndIf;
//	vFolioFolder = Справочники.ObjectPrintingForms.FindByCode("500");
//	If ЗначениеЗаполнено(vFolioFolder) And НЕ vFolioFolder.IsFolder Тогда
//		vFolioFolder = Неопределено;
//	EndIf;
//	vReservationFolder = Справочники.ObjectPrintingForms.FindByCode("200");
//	If ЗначениеЗаполнено(vReservationFolder) And НЕ vReservationFolder.IsFolder Тогда
//		vReservationFolder = Неопределено;
//	EndIf;
//	// Get new forms list
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	ObjectPrintingForms.Ref,
//	|	ObjectPrintingForms.Description
//	|FROM
//	|	Catalog.ObjectPrintingForms AS ObjectPrintingForms
//	|WHERE
//	|	ObjectPrintingForms.Parent = &qEmptyParent
//	|	AND NOT ObjectPrintingForms.IsFolder
//	|	AND NOT ObjectPrintingForms.DeletionMark
//	|	AND ObjectPrintingForms.Language = &qEmptyLanguage
//	|	AND ObjectPrintingForms.ObjectType = &qUndefined
//	|
//	|ORDER BY
//	|	ObjectPrintingForms.Code";
//	vQry.SetParameter("qEmptyParent", Справочники.ObjectPrintingForms.EmptyRef());
//	vQry.SetParameter("qEmptyLanguage", Справочники.Локализация.EmptyRef());
//	vQry.SetParameter("qUndefined", Неопределено);
//	vForms = vQry.Execute().Unload();
//	For Each vFormsRow In vForms Do
//		If Find(vFormsRow.Description, "en='Invoice") > 0 Or Find(vFormsRow.Description, "en='Detailed invoice") > 0 Or Find(vFormsRow.Description, "en='Short invoice") > 0 Тогда
//			vFormObj = vFormsRow.Ref.GetObject();
//			vFormObj.ObjectType = Documents.СчетНаОплату.EmptyRef();
//			vFormObj.Language = Справочники.Локализация.DE;
//			vFormObj.IsActive = True;
//			If ЗначениеЗаполнено(vInvoiceFolder) Тогда
//				vFormObj.Parent = vInvoiceFolder;
//			EndIf;
//			vFormObj.Write();
//		EndIf;
//		If Find(vFormsRow.Description, "en = 'Print charge details") > 0 Or Find(vFormsRow.Description, "en='Print folio") > 0 Or Find(vFormsRow.Description, "en='Print hotel property damage list") > 0 Or Find(vFormsRow.Description, "en='Print external client folio") > 0 Тогда
//			vFormObj = vFormsRow.Ref.GetObject();
//			vFormObj.ObjectType = Documents.СчетПроживания.EmptyRef();
//			vFormObj.Language = Справочники.Локализация.DE;
//			vFormObj.IsActive = True;
//			If ЗначениеЗаполнено(vFolioFolder) Тогда
//				vFormObj.Parent = vFolioFolder;
//			EndIf;
//			vFormObj.Write();
//		EndIf;
//		If Find(vFormsRow.Description, "(DE)") > 0 Тогда
//			vFormObj = vFormsRow.Ref.GetObject();
//			vFormObj.ObjectType = Documents.Reservation.EmptyRef();
//			vFormObj.Language = Справочники.Локализация.DE;
//			vFormObj.IsActive = True;
//			If ЗначениеЗаполнено(vReservationFolder) Тогда
//				vFormObj.Parent = vReservationFolder;
//			EndIf;
//			vFormObj.Write();
//		EndIf;
//	EndDo;
//КонецПроцедуры //FillGermanPrintingFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура Fill131UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToSkipBoardPlaceSetting = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill131UserPermission
//
////-----------------------------------------------------------------------------
//Процедура ChangeGiftCertificatesReportSettings()
//	If Справочники.Отчеты.ПодарочСертификатСведения.Report <> "GiftCertificates" Тогда
//		vSPIRFolder = Справочники.Отчеты.FindByCode(100, , Справочники.Отчеты.EmptyRef());
//		vRepObj = Справочники.Отчеты.ПодарочСертификатСведения.GetObject();
//		vRepObj.Report = "GiftCertificates";
//		vRepObj.DynamicParameters = "REP.ПериодС = AddMonth(BegOfMonth(CurrentDate()), -1);
//		                            |REP.ПериодПо = AddMonth(EndOfMonth(CurrentDate()), -1);";
//		If ЗначениеЗаполнено(vSPIRFolder) And vSPIRFolder.IsFolder Тогда
//			vRepObj.Parent = vSPIRFolder;
//		EndIf;
//		vRepObj.Примечания = "";
//		vRepObj.DefaultSettings = Новый ValueStorage(cmReadReportDefaultSettingFromTemplate(vRepObj));
//		vRepObj.Write();
//		// Load this default report settings
//		vReportObject = cmBuildReportObject(vRepObj.Ref);
//		vReportObject.Report = vRepObj.Ref;
//		#Если Клиент Тогда
//			cmLoadDefaultReportSettings(vReportObject);
//		#КонецЕсли
//		// Save report settings
//		vReportObject.pmSaveReportAttributes();
//	EndIf;
//КонецПроцедуры //ChangeGiftCertificatesReportSettings
//
////-----------------------------------------------------------------------------
//Процедура FillReservationExpressCheckInInvitationPrintFormsSettings()
//	vReservationFolder = Справочники.ObjectPrintingForms.FindByCode("200");
//	If ЗначениеЗаполнено(vReservationFolder) And НЕ vReservationFolder.IsFolder Тогда
//		vReservationFolder = Неопределено;
//	EndIf;
//	// Get new forms list
//	If Справочники.ObjectPrintingForms.ReservationPrintExpressCheckInInvitationRu.ObjectType = Неопределено Тогда
//		vFormObj = Справочники.ObjectPrintingForms.ReservationPrintExpressCheckInInvitationRu.GetObject();
//		vFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		vFormObj.Language = Справочники.Локализация.RU;
//		vFormObj.IsActive = True;
//		If ЗначениеЗаполнено(vReservationFolder) Тогда
//			vFormObj.Parent = vReservationFolder;
//		EndIf;
//		vFormObj.Write();
//	EndIf;
//	If Справочники.ObjectPrintingForms.ReservationPrintExpressCheckInInvitationEn.ObjectType = Неопределено Тогда
//		vFormObj = Справочники.ObjectPrintingForms.ReservationPrintExpressCheckInInvitationEn.GetObject();
//		vFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		vFormObj.Language = Справочники.Локализация.EN;
//		vFormObj.IsActive = True;
//		If ЗначениеЗаполнено(vReservationFolder) Тогда
//			vFormObj.Parent = vReservationFolder;
//		EndIf;
//		vFormObj.Write();
//	EndIf;
//	If Справочники.ObjectPrintingForms.ReservationPrintExpressCheckInInvitationDe.ObjectType = Неопределено Тогда
//		vFormObj = Справочники.ObjectPrintingForms.ReservationPrintExpressCheckInInvitationDe.GetObject();
//		vFormObj.ObjectType = Documents.Reservation.EmptyRef();
//		vFormObj.Language = Справочники.Локализация.DE;
//		vFormObj.IsActive = True;
//		If ЗначениеЗаполнено(vReservationFolder) Тогда
//			vFormObj.Parent = vReservationFolder;
//		EndIf;
//		vFormObj.Write();
//	EndIf;
//КонецПроцедуры //FillReservationExpressCheckInInvitationPrintFormsSettings
//
////-----------------------------------------------------------------------------
//Процедура FixCountriesDescription()
//	vC = Справочники.Countries.Select();
//	While vC.Next() Do
//		If Find(vC.Description,",") > 0 Тогда
//			vCObj = vC.GetObject();
//			vCObj.Description = StrReplace(vCObj.Description,", "," ");
//			vCObj.Description = StrReplace(vCObj.Description,","," ");
//		EndIf;
//	EndDo;
//КонецПроцедуры //FixCountriesDescription
//
////-----------------------------------------------------------------------------
//Процедура FillFMSCodes()
//	InformationRegisters.CodesFMS.pmRun();	
//КонецПроцедуры //FillFMSCodes
//
////-----------------------------------------------------------------------------
//Процедура FillAccommodationMakeIdentificationCardFormActionSetings()
//	If TypeOf(Справочники.ObjectFormActions.AccommodationMakeIdentificationCard.ObjectType) <> Type("DocumentRef.Размещение") Тогда
//		vAccommodationFolder = Справочники.ObjectFormActions.FindByCode("100");
//		vFormActObj = Справочники.ObjectFormActions.AccommodationMakeIdentificationCard.GetObject();
//		vFormActObj.ObjectType = Documents.Размещение.EmptyRef();
//		If ЗначениеЗаполнено(vAccommodationFolder) And vAccommodationFolder.IsFolder Тогда
//			vFormActObj.Parent = vAccommodationFolder;
//		EndIf;
//		vFormActObj.IsActive = True;
//		vFormActObj.Примечания = "";
//		vFormActObj.Write();
//	EndIf;
//КонецПроцедуры //FillAccommodationMakeIdentificationCardFormActionSetings
//
////-----------------------------------------------------------------------------
//Процедура Fill133UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToInputDiscountCardNumberManually = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill133UserPermission
//
////-----------------------------------------------------------------------------
//Процедура Fill134UserPermission()
//	// Run query to get permission groups
//	vQry = Новый Запрос();
//	vQry.Text = 
//	"SELECT
//	|	НаборПрав.Ref AS Ref
//	|FROM
//	|	Catalog.НаборПрав AS НаборПрав
//	|WHERE
//	|	(NOT НаборПрав.DeletionMark)
//	|	AND (NOT НаборПрав.IsFolder)
//	|ORDER BY
//	|	НаборПрав.Code";
//	vQryRes = vQry.Execute().Choose();
//	While vQryRes.Next() Do
//		vPGObj = vQryRes.Ref.GetObject();
//		Try
//			vPGObj.HavePermissionToUseClientDiscountCardWithAnyOtherClientHavingIt = True;
//			vPGObj.Write();
//		Except
//			Message(TrimAll(vPGObj.Description) + NStr("en=' - error: '; de=' - error: '; ru=' - ошибка: '") + ErrorDescription());
//		EndTry;
//	EndDo;
//КонецПроцедуры //Fill134UserPermission
//
////-----------------------------------------------------------------------------
//Процедура FillEmployeeActionsAuditReportSettings()
//	// Create audit reports group first
//	vAuditReportsFolder = Справочники.Отчеты.FindByCode(790);
//	If ЗначениеЗаполнено(vAuditReportsFolder) And НЕ vAuditReportsFolder.IsFolder Тогда
//		vAuditReportsFolder = Справочники.Отчеты.EmptyRef();
//	EndIf;
//	// Fill report name and report folder for new reports
//	vRepRef = Справочники.Отчеты.EmployeeActionsAudit;
//	If ЗначениеЗаполнено(vRepRef) And НЕ ЗначениеЗаполнено(vRepRef.Report) Тогда
//		vRepObj = vRepRef.GetObject();
//		vRepObj.Report = "EmployeeActionsAudit"; 
//		vRepObj.Parent = vAuditReportsFolder;
//		vRepObj.ПорядокСортировки = 971;
//		vRepObj.DynamicParameters = "REP.ПериодС = BegOfDay(CurrentDate()) - 24*3600;
//		                            |REP.ПериодПо = EndOfDay(REP.ПериодС);";
//		vRepObj.Write();
//	EndIf;
//КонецПроцедуры //FillEmployeeActionsAuditReportSettings 
//
////-----------------------------------------------------------------------------
//Function парМодБазаОбн(pFrmWithChanges = Неопределено) Экспорт
//	// Old version number
//	vOldVersion = cmGetProgramVersionAsDateString();
//	// Set current version BEFORE conversion routines will run to allow users 
//	// start working before end of conversion took place (we assume that there 
//	// won't be any exclusive and critical conversion routines in the future. 
//	// At least it is so far...
//	
//	vTemplate = ПолучитьМакет("DescriptionUpdate");
//	vSpreadsheetDocument = Новый SpreadsheetDocument;
//	vSpreadsheetDocument.Clear();
//	
//	Constants.НомерРелиза.Set(Metadata.Version);
//	WriteLogEvent("Версия.НомерРазмещения", EventLogLevel.Note, , , "Предыдущая: " + vOldVersion + " -> Текущая: " + Metadata.Version);
//	// Save and clear hotel and Фирма edit prohibited dates
//	vEditProhibitedDates = Новый ValueTable();
//	vEditProhibitedDates.Columns.Add("Item");
//	vEditProhibitedDates.Columns.Add("EditProhibitedDate", cmGetDateTypeDescription());
//	vEditProhibitedDates.Columns.Add("УчетнаяДата", cmGetDateTypeDescription());
//	vHotels = cmGetAllHotels();
//	For Each vHotelsRow In vHotels Do
//		If ЗначениеЗаполнено(vHotelsRow.Гостиница.EditProhibitedDate) Тогда
//			vEditProhibitedDatesRow = vEditProhibitedDates.Add();
//			vEditProhibitedDatesRow.Item = vHotelsRow.Гостиница;
//			vEditProhibitedDatesRow.EditProhibitedDate = vHotelsRow.Гостиница.EditProhibitedDate;
//			vEditProhibitedDatesRow.УчетнаяДата = vHotelsRow.Гостиница.УчетнаяДата;
//			// Clear date
//			vItemObj = vHotelsRow.Гостиница.GetObject();
//			vItemObj.EditProhibitedDate = '00010101';
//			vItemObj.УчетнаяДата = '00010101';
//			vItemObj.Write();
//		EndIf;
//	EndDo;
//	vCompanies = cmGetAllCompanies();
//	For Each vCompaniesRow In vCompanies Do
//		If ЗначениеЗаполнено(vCompaniesRow.Фирма.EditProhibitedDate) Тогда
//			vEditProhibitedDatesRow = vEditProhibitedDates.Add();
//			vEditProhibitedDatesRow.Item = vCompaniesRow.Фирма;
//			vEditProhibitedDatesRow.EditProhibitedDate = vCompaniesRow.Фирма.EditProhibitedDate;
//			vEditProhibitedDatesRow.УчетнаяДата = '00010101';
//			// Clear date
//			vItemObj = vCompaniesRow.Фирма.GetObject();
//			vItemObj.EditProhibitedDate = '00010101';
//			vItemObj.Write();
//		EndIf;
//	EndDo;
//	// First of all convert permission rules
//	If vOldVersion < "090922" Тогда
//		Fill103106UserPermissions();
//	EndIf;
//	If vOldVersion < "091111" Тогда
//		Fill107UserPermissions();
//	EndIf;
//	If vOldVersion < "100202" Тогда
//		Fill109111UserPermissions();
//	EndIf;
//	If vOldVersion < "100215" Тогда
//		Fill112UserPermission();
//	EndIf;
//	If vOldVersion < "100413" Тогда
//		Fill095099112UserPermissions();
//		Fill113UserPermission();
//	EndIf;
//	If vOldVersion < "100928" Тогда
//		Fill032033UserPermissions();
//	EndIf;
//	If vOldVersion < "101026" Тогда
//		Fill116UserPermission();
//	EndIf;
//	If vOldVersion < "101102" Тогда
//		Fill117UserPermission();
//	EndIf;
//	If vOldVersion < "111026" Тогда
//		Fill119UserPermission();
//	EndIf;
//	If vOldVersion < "120325" Тогда
//		Fill121122UserPermission();
//	EndIf;
//	If vOldVersion < "120418" Тогда
//		Fill124UserPermission();
//	EndIf;
//	If vOldVersion < "121016" Тогда
//		Fill126UserPermission();
//	EndIf;
//	If vOldVersion < "121123" Тогда
//		Fill127UserPermission();
//		Fill128UserPermission();
//		Fill129UserPermission();
//	EndIf;
//	If vOldVersion < "121129" Тогда
//		Fill130UserPermission();
//	EndIf;
//	If vOldVersion < "140312" Тогда
//		Fill131UserPermission();
//	EndIf;
//	If vOldVersion < "150212" Тогда
//		Fill133UserPermission();
//		Fill134UserPermission();
//	EndIf;
//	If vOldVersion < "150615" Тогда
//		Fill135UserPermission();
//	EndIf;
//	// Call conversion routines
//	If vOldVersion < "090209" Тогда
//		FillDefaultDurationCalculationRuleType();
//	EndIf;
//	If vOldVersion < "090812" Тогда
//		// It is also could be ignored
//		FillGuestGroupParameters();
//	EndIf;
//	If vOldVersion < "091027" Тогда
//		FillCorrectRUBCode();
//	EndIf;
//	If vOldVersion < "091111" Тогда
//		// Those are recommended but could be postponed or ignored
//		RepostActiveReservations();
//		RepostInHouseAccommodations();
//	EndIf;
//	If vOldVersion < "091126" Тогда
//		FillAuditReportsSettings();
//	EndIf;
//	If vOldVersion < "091201" Тогда
//		FillCustomerOperationalBalancesObjectPrintingForm();
//	EndIf;
//	If vOldVersion >= "091111" And vOldVersion < "091215" Тогда
//		// This is recommended but could be postponed or ignored
//		RepostActiveReservations();
//	EndIf;
//	If vOldVersion < "091216" Тогда
//		FillCustomerSalesForecastReportSettings();
//	EndIf;
//	If vOldVersion < "091223" Тогда
//		FillIssuedHotelProductsReportSettings();
//	EndIf;
//	If vOldVersion < "100202" Тогда
//		FixAccommodationTypes();
//	EndIf;
//	If vOldVersion < "100209" Тогда
//		FixPaymentMethods();
//	EndIf;
//	If vOldVersion < "100215" Тогда
//		FillReleaseExpiredRoomAllotmentsDataProcessorSettings();
//	EndIf;
//	If vOldVersion < "100323" Тогда
//		FillSendGuestGroupNotificationsDataProcessorSettings();
//	EndIf;
//	If vOldVersion < "100329" Тогда
//		FillCheckReservationWaitingListProcessingSettings();
//	EndIf;
//	If vOldVersion < "100503" Тогда
//		FillChangedAccommodationsReportSettings();
//		FillOccupancyForecastReportSettings();
//	EndIf;
//	If vOldVersion < "100608" Тогда
//		// This is highly recommended but could be postponed
//		FillReservationGuestFullNames();
//	EndIf;
//	If vOldVersion < "100611" Тогда
//		FillCustomerGuestsPercentsReportSettings();
//	EndIf;
//	If vOldVersion < "100623" Тогда
//		FillCheckCustomerServicesReportSettings();
//	EndIf;
//	If vOldVersion < "100624" Тогда
//		FillCopyGuestGroupReservationsObjectFormAction();
//		// This is highly recommended but could be postponed
//		FillAccommodationGuestFullNames();
//		// Repost active reservations
//		RepostActiveReservationsInOneRun();
//	EndIf;
//	If vOldVersion < "100928" Тогда
//		// Repost all payments, returns and Контрагент payments
//		RepostPayments();
//		RepostReturns();
//		RepostCustomerPayments();
//		// Repost close of cash register days
//		RepostCloseOfCashRegisterDays();
//	EndIf;
//	If vOldVersion < "101004" Тогда
//		// Fill expected check-in ordered by rooms report settings
//		FillExpectedCheckInOrderedByRoomsReportSettings();
//		// Fill print group rooms reservation printing form settings
//		FillReservationPrintGuestGroupRoomsObjectPrintingFormSetings();
//		// Fill safety system events audit report settings
//		FillSafetySystemEventsAuditReportSettings();
//	EndIf;
//	If vOldVersion < "101026" Тогда
//		// Fill print coupons object form actions parameters
//		FillPrintCouponsActionSetings();
//	EndIf;
//	If vOldVersion < "101102" Тогда
//		// Fill client item form action settings
//		FillClientObjectFormActionsSettings();
//		// Fill client item print form settings
//		FillClientObjectPrintFormsSettings();
//	EndIf;
//	If vOldVersion < "101119" Тогда
//		// Fill changed icons
//		FillCheckInCheckOutActionPictures();
//		// Fix data procesor name
//		FixExportForeignersDataToPVSOVD();
//		// Fill permission group parameter
//		FillAllowedAnnulationDelayTime();
//	EndIf;
//	If vOldVersion < "101221" Тогда
//		// Clear hotel from charging rule template folios
//		ClearHotelFromChargingRuleTemplateFolios();
//	EndIf;
//	If vOldVersion < "101223" Тогда
//		// Fill new Контрагент guests turnovers report settings
//		FillCustomerGuestsTurnoversReportSettings();
//	EndIf;
//	If vOldVersion < "101224" Тогда
//		FillCheckCustomerGuestsReportSettings();
//	EndIf;
//	If vOldVersion < "110221" Тогда
//		FillCustomerInitialBalancesActionSettings();
//		FillCustomerGuestsWithServicesReportSettings();
//		FillLostProfitsReportSettings();
//	EndIf;
//	If vOldVersion < "110407" Тогда
//		FillIdentificationCardsAuditReportSettings();
//	EndIf;
//	If vOldVersion < "110420" Тогда
//		FillHotelProductsRegisterReportSettings();
//	EndIf;
//	If vOldVersion < "110518" Тогда
//		FillReservationCheckInGuestGroupObjectFormActionSettings();
//		FillCheckIfReservationsWerePayedInTimeDataProcessorSettings();
//	EndIf;
//	If vOldVersion < "110604" Тогда
//		FillClientHideNameAndNameHistoryActionSettings();
//		FillFolioPrintHotelProductObjectPrintFormsSettings();
//	EndIf;
//	If vOldVersion < "110615" Тогда
//		ConvertReports();
//		FillIssueHotelProductsPrintHotelProductsLogPrintFormSettings();
//		FillExpectedGuestGroupsReportSettings();
//		FillReservationsNoShowReportSettings();
//		FillForeignerRegistryRecordPrintForeignerCardFormObjectPrintFormsSettings();
//		FillFolioPrint3GFormObjectPrintFormsSettings();
//		FillAgeRanges();
//		FillClientsAgeRegionAndCity();
//		FillCustomersDoNotPostCommission();
//		vFoundHotelProductServices = FillIsHotelProductServiceAttribute();
//		FillServiceCommissionAttributes();
//		RepostActiveReservations();
//		RepostChargesAndStorno(BegOfMonth(BegOfMonth(CurrentDate()) - 1), '39991231');
//		RepostChargesAndStorno(BegOfYear(CurrentDate()), '39991231');
//		RepostChargesAndStorno('00010101', '39991231');
//		If vFoundHotelProductServices Тогда
//			RepostSettlements();
//		EndIf;
//	EndIf;
//	If vOldVersion < "111021" Тогда
//		FillInvoicePrintPaymentOrderObjectPrintFormsSettings();
//	EndIf;
//	If vOldVersion < "111112" Тогда
//		FillReservationAnnulationsReportSettings();
//	EndIf;
//	If vOldVersion < "120325" Тогда
//		FillClientScanClientDataActionSettings();
//	EndIf;
//	If vOldVersion < "120418" Тогда
//		FillCustomerAdvanceDistributionActionSettings();
//		FillContractAdvanceDistributionActionSettings();
//		FillFolioPrintChargePrintFormsSettings();
//	EndIf;
//	If vOldVersion < "120515" Тогда
//		FillAccommodationFillInvoiceActionSettings();
//		FillGuestsWithBirthDayReportSettings();
//	EndIf;
//	If vOldVersion < "120525" Тогда
//		FillActiveReservationsSortCode();
//		FillInHouseAccommodationsSortCode();
//	EndIf;
//	If vOldVersion < "121016" Тогда
//		FillSMSDeliveryPrintReceiversObjectPrintFormsSettings();
//		FillSMSDeliveryObjectFormActionSettingsFolder();
//		FillSMSBeingSentReportSettings();
//		Constants.SMSGateway.Set(Перечисления.SupportedSMSGateways.SMS1CHOTEL);
//	EndIf;
//	If vOldVersion < "121123" Тогда
//		FillAccommodationPrintArrivalSheetFormObjectPrintingFormSetings();
//	EndIf;
//	If vOldVersion < "130508" Тогда
//		FillFolioGiftCertificatesActionSettings();
//		FillActiveGiftCertificatesReportSettings();
//		ChangeNorweqVisionConnectionType();
//	EndIf;
//	If vOldVersion < "130920" Тогда
//		FillDoNightAuditPrecheckDataProcessorSettings();
//	EndIf;
//	If vOldVersion < "131206" Тогда
//		FillServicePackageRecordsInformationRegister();
//	EndIf;
//	If vOldVersion < "131225" Тогда
//		FillReservationPrintGuestFormObjectPrintFormsSettings();
//	EndIf;
//	If vOldVersion < "140312" Тогда
//		// This is mandatory
//		RepostInHouseAccommodations();
//		SimpleRepostActiveReservations();
//	EndIf;
//	If vOldVersion < "140319" Тогда
//		FillGermanPrintingFormsSettings();
//	EndIf;
//	If vOldVersion < "140415" Тогда
//		ChangeGiftCertificatesReportSettings();
//	EndIf;
//	If vOldVersion < "140530" Тогда
//		FillReservationExpressCheckInInvitationPrintFormsSettings();
//		FixCountriesDescription();
//	EndIf;
//	If vOldVersion < "140605" Тогда
//		FillFMSCodes();
//	EndIf;
//	If vOldVersion < "140818" Тогда
//		FillAccommodationMakeIdentificationCardFormActionSetings();
//	EndIf;
//	If vOldVersion < "140926" Тогда
//		//If IsBlankString(Constants.DadataToken.Get()) Тогда
//		//	Constants.DadataToken.Set("39d56491dac45396522f98c4958f0c16ab61152b");
//		//EndIf;
//		// Update UMMS catalogs
//		Справочники.УдостоверениеЛичности.mmLoadFromDictionary();
//		Справочники.TripPurposes.mmLoadFromDictionary();
//		Справочники.VisaTypes.mmLoadFromDictionary();
//		Справочники.EntryGoals.mmLoadFromDictionary();
//		//Справочники.КПП.mmClear();
//		//Справочники.КПП.mmLoadFromDictionary();
//	EndIf;
//	If vOldVersion < "141212" Тогда
//		// Update country phone code for RUSSIA
//		vRURef = Справочники.Countries.FindByCode(643);
//		If ЗначениеЗаполнено(vRURef) Тогда
//			vRUObj = vRURef.GetObject();
//			vRUObj.CountryPhoneCode = 7;
//			vRUObj.Write();
//		EndIf;
//	EndIf;
//	If vOldVersion < "150428" Тогда
//		FillEmployeeActionsAuditReportSettings();
//	EndIf;
//	If vOldVersion < "150624" Тогда
//		PutDescriptionUpdate("150624", vSpreadsheetDocument, vTemplate);
//	EndIf;
//	// Restore edit prohibited dates
//	For Each vEditProhibitedDatesRow In vEditProhibitedDates Do
//		If ЗначениеЗаполнено(vEditProhibitedDatesRow.Item) And ЗначениеЗаполнено(vEditProhibitedDatesRow.EditProhibitedDate) Тогда
//			vItemObj = vEditProhibitedDatesRow.Item.GetObject();
//			vItemObj.EditProhibitedDate = vEditProhibitedDatesRow.EditProhibitedDate;
//			If TypeOf(vItemObj) = Type("CatalogObject.Hotels") Тогда
//				vItemObj.УчетнаяДата = vEditProhibitedDatesRow.УчетнаяДата;
//			EndIf;
//			vItemObj.Write();
//		EndIf;
//	EndDo;
//	// Open form Description Update
//	#If  Client Тогда
//		If vSpreadsheetDocument.TableHeight > 0 Тогда
//			vFrm = ПолучитьФорму("DescriptionUpdate");
//			vFrm.TemplateDescriptionUpdate = vSpreadsheetDocument;
//			pFrmWithChanges = vFrm;
//		Endif;
//	#Endif
//	// Return info base update status
//	Return True;
//EndFunction //парМодБазаОбн
//
////-----------------------------------------------------------------------------
//Процедура PutDescriptionUpdate(pVersion, pSpreadsheetDocument, pTemplate)
//	Try
//		pSpreadsheetDocument.Put(pTemplate.GetArea("Head" + pVersion));
//		pSpreadsheetDocument.StartRowGroup("Version" + pVersion);
//		pSpreadsheetDocument.Put(pTemplate.GetArea("Version" + pVersion));
//		pSpreadsheetDocument.EndRowGroup();
//		pSpreadsheetDocument.Put(pTemplate.GetArea("Indent"));
//	Except
//	EndTry;
//КонецПроцедуры //PutDescriptionUpdate
