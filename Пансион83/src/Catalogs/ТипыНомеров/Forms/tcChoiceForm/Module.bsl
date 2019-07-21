Перем CalendarDayTypes;
&НаКлиенте
Перем LastKidsNumber;

//-----------------------------------------------------------------------------
&AtServer
Процедура OnOpenForm()
	// Check permission to edit client type
	If НЕ cmCheckUserPermissions("HavePermissionToChooseClientTypeManually") Тогда
		Items.ТипКлиента.Enabled = False;
	EndIf;
	// Check that parameters are filled
	FillParametersByDefaultValues();
	ResetParameters();
	// Check permission to edit allotment
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.КвотаНомеров) Тогда
		Items.КвотаНомеров.ClearButton = False;
		Items.КвотаНомеров.ChoiceButton = False;
		Items.КвотаНомеров.OpenButton = False;
		Items.КвотаНомеров.ReadOnly = True;
	EndIf;
	// Build list
	
	// Try to Должность list on choice initial value
	DoInitialListPositioning();
	// Check hotel
	If НЕ ЗначениеЗаполнено(Гостиница) Or Гостиница.IsFolder Тогда
		Message(NStr("en='Гостиница chould be choosen!';ru='Должна быть выбрана гостиница!';de='Das Гостиница muss gewählt sein!'"));
		Return;
	EndIf;
КонецПроцедуры //OnOpenForm

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	LastKidsNumber = 0;
	NumberOfKidAgeFields = 4;
	If ЗначениеЗаполнено(NumberOfKids) Тогда
		
		If AgeList.Count()>0 Тогда
			vIndex = 1;
			For Each vItem In AgeList Do
				Try
					Items["KidAge"+String(vIndex)].Visible = True;
					ЭтаФорма["KidAge"+String(vIndex)] = vItem.Value;
				Except
				EndTry;
				vIndex = vIndex + 1;
			EndDo;
		EndIf;
	EndIf;
	OnOpenForm();
КонецПроцедуры //OnOpen

//-----------------------------------------------------------------------------
&AtServer
Процедура FillParametersByDefaultValues()
	If НЕ ЗначениеЗаполнено(SelCheckInDate) Тогда
		SelCheckInDate = Date(Year(CurrentDate()), Month(CurrentDate()), Day(CurrentDate()), 
	                 Hour(CurrentDate()), Minute(CurrentDate()), 0);
	EndIf;
	vPeriodInHours = 24;
	If НЕ ЗначениеЗаполнено(SelCheckOutDate) Тогда
		SelDuration = 1;
		SelCheckOutDate = SelCheckInDate + SelDuration * vPeriodInHours * 3600;
	Else
		SelDuration = Int((SelCheckOutDate - SelCheckInDate)/86400);
	EndIf;
	If НЕ ЗначениеЗаполнено(SelHotel) Тогда
		SelHotel = ПараметрыСеанса.ТекущаяГостиница;
		If ЗначениеЗаполнено(SelHotel) Тогда
			SelDuration = SelHotel.Продолжительность;
			SelRoomRate = SelHotel.Тариф;
			SelCheckOutDate = cmCalculateCheckOutDate(SelRoomRate, SelCheckInDate, SelDuration);
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(SelRoomRate) Тогда
		If ЗначениеЗаполнено(SelHotel) Тогда
			SelRoomRate = SelHotel.Тариф;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(SelRoomQuota) Тогда
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.КвотаНомеров) Тогда
			SelRoomQuota = ПараметрыСеанса.ТекПользователь.КвотаНомеров;
		EndIf;
	EndIf;
КонецПроцедуры //FillParametersByDefaultValues

//-----------------------------------------------------------------------------
&AtServer
Процедура ResetParameters()
	CheckInDate = SelCheckInDate;
	CheckInTime = SelCheckInDate;
	Duration = SelDuration;
	CheckOutDate = SelCheckOutDate;
	CheckOutTime = SelCheckOutDate;
	ClientType = SelClientType;
	Тариф = SelRoomRate;
	Гостиница = SelHotel;
	RoomType = SelRoomType;
	RoomQuota = SelRoomQuota;
	If НЕ ЗначениеЗаполнено(NumberOfAdults) Тогда
		NumberOfAdults = 1;
	EndIf;
КонецПроцедуры //ResetParameters

//-----------------------------------------------------------------------------
&AtServer
Процедура DoInitialListPositioning()
	vPosRow = Неопределено;
	If ЭтаФорма.SelChoiceInitialValue <> Неопределено Тогда
		vRoomType = ЭтаФорма.SelChoiceInitialValue.ТипНомера; 
		vAccommodationType = ЭтаФорма.SelChoiceInitialValue.ВидРазмещения;
		If ЗначениеЗаполнено(vRoomType) Тогда
			For Each vRow In RoomTypesList Do
				If vRoomType = vRow.ТипНомера Тогда
					If ЗначениеЗаполнено(vAccommodationType) Тогда
						If vAccommodationType = vRow.ВидРазмещения Тогда
							vPosRow = vRow;
							Break;
						EndIf;
					Else
						vPosRow = vRow;
						Break;
					EndIf;
				EndIf;
			EndDo;
		EndIf;
	EndIf;
	If vPosRow <> Неопределено Тогда
		Items.RoomTypesList.CurrentRow = vPosRow;
	EndIf;
КонецПроцедуры //DoInitialListPositioning

//-----------------------------------------------------------------------------
&AtServer
Процедура CalculateRowSumAndAvgPrice(vCurRow) Экспорт
	If vCurRow <> Неопределено Тогда
		// Reset row amounts
		vCurRow.Сумма = 0; 
		vCurRow.AvgPrice = 0;
		// Check ГруппаНомеров rate
		If ЗначениеЗаполнено(Тариф) Тогда
			If Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByHours Тогда
				Items.RoomTypesList.ChildItems.RoomTypesListSum.FooterText = "";
				Items.RoomTypesList.ChildItems.RoomTypesListAvgPrice.FooterText = "";
				Return;
			EndIf;
			// Calculate new row values
			vSum = 0;
			vNumDays = 0;
			//vAvgPrice = 0;
			vCurrency = Неопределено;
			vDate = BegOfDay(CheckInDate);
			vEndDate = BegOfDay(CheckOutDate);
			If Тариф.DurationCalculationRuleType <> Перечисления.DurationCalculationRuleTypes.ByDays Тогда
				vEndDate = vEndDate - 24*3600;
			EndIf;
			vRoomTypesList = FormAttributeToValue("RoomTypesList");
			While vDate <= vEndDate Do
				vNumDays = vNumDays + 1;
				vCalendarDayTypeRow = CalendarDayTypes.Find(vDate, "Period");
				If vCalendarDayTypeRow <> Неопределено Тогда
					vCalendarDayType = vCalendarDayTypeRow.ТипДняКалендаря;
					vRoomTypesList = FormAttributeToValue("RoomTypesList");
					vRows = vRoomTypesList.FindRows(New Structure("ТипНомера, ВидРазмещения, ТипДеньКалендарь", vCurRow.ТипНомера, vCurRow.ВидРазмещения, vCalendarDayType));
					If vRows.Count() = 1 Тогда
						vRow = vRows.Get(0);
						If vCurrency = Неопределено Тогда
							vCurrency = vRow.Валюта;
						EndIf;
						If vCurrency <> vRow.Валюта Тогда
							Items.RoomTypesList.ChildItems.RoomTypesListSum.FooterText = "";
							Items.RoomTypesList.ChildItems.RoomTypesListAvgPrice.FooterText = "";
							Return;
						EndIf;
						vSum = vSum + vRow.Цена;
					Else
						Items.RoomTypesList.ChildItems.RoomTypesListSum.FooterText = "";
						Items.RoomTypesList.ChildItems.RoomTypesListAvgPrice.FooterText = "";
						Return;
					EndIf;
				Else
					Items.RoomTypesList.ChildItems.RoomTypesListSum.FooterText = "";
					Items.RoomTypesList.ChildItems.RoomTypesListAvgPrice.FooterText = "";
					Return;
				EndIf;
				vDate = vDate + 24*3600;
			EndDo;
			vCurRow.Сумма = vSum * vCurRow.Количество;
			Items.RoomTypesList.ChildItems.RoomTypesListSum.FooterText = Format(vRoomTypesList.Total("Сумма"), "ND=17; NFD=2; NZ=");
			If vNumDays > 0 Тогда 
				vCurRow.AvgPrice = Round(vCurRow.Сумма/vNumDays, 2);
				Items.RoomTypesList.ChildItems.RoomTypesListAvgPrice.FooterText = Format(vRoomTypesList.Total("AvgPrice"), "ND=17; NFD=2; NZ=");
			EndIf;
		Else
			Items.RoomTypesList.ChildItems.RoomTypesListSum.FooterText = "";
			Items.RoomTypesList.ChildItems.RoomTypesListAvgPrice.FooterText = "";
		EndIf;
	EndIf;
КонецПроцедуры //CalculateRowSumAndAvgPrice

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RoomTypesListSelection(pItem, pSelectedRow, pField, pStandardProcessing)
	pStandardProcessing = False;
	If ЗначениеЗаполнено(RoomQuota) Тогда
		vIsFolder = УпрСерверныеФункции.cmGetAttributeByRef(RoomQuota, "IsFolder");
		If vIsFolder Тогда
			vMessage = New UserMessage;
			vMessage.Field = "КвотаНомеров";
			vMessage.Text = "Нельзя выбирать тип номера при указанной группе квот!";
			vMessage.Message();
			Return;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(pItem.CurrentData.Ref) Тогда
		If FormOwner = Неопределено Тогда
			If pSelectedRow<>Неопределено Тогда
				RoomType = pItem.CurrentData.Ref;
			EndIf;
		Else
			vFormOwner = FormOwner;
//			While TypeOf(vFormOwner) <> Type("ManagedForm") Or vFormOwner = Неопределено Do
//				vFormOwner = vFormOwner.Parent;
//			EndDo;
			If vFormOwner <> Неопределено Тогда
				If vFormOwner.FormName = "Document.Бронирование.Form.tcDocumentForm" Or vFormOwner.FormName = "Document.Размещение.Form.tcDocumentForm" Тогда
					NotifyChoice(New Structure("КвотаНомеров, ТипНомера, ВидРазмещения, Тариф, ТипКлиента", RoomQuota, pItem.CurrentData.Ref, pItem.CurrentData.ВидРазмещения, Тариф, ClientType));
				Else
					NotifyChoice(pItem.CurrentData.Ref);
				EndIf;
			Else
				NotifyChoice(pItem.CurrentData.Ref);
            EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //RoomTypesListSelection

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RoomTypeOnChange(pItem)
	// Build List
	BuildList();
КонецПроцедуры //RoomTypeOnChange




//-----------------------------------------------------------------------------
&AtServer
Процедура SetCurrentHotel(pHotelRef)
	ПараметрыСеанса.ТекущаяГостиница = pHotelRef;
КонецПроцедуры //SetCurrentHotel

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура HotelOnChange(pItem)
	ChangeCurrentHotel();
	If ЗначениеЗаполнено(Гостиница) Тогда
		Items.FormAvailableRoomsAction.Enabled = True;
	Else
		Items.FormAvailableRoomsAction.Enabled = False;
	EndIf;
	// Build list
	BuildList();
КонецПроцедуры //HotelOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура ChangeCurrentHotel()
	// Change current hotel in the session parameters
	If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.IsFolder Тогда
		SetCurrentHotel(Гостиница);
		ПараметрыСеанса.ТекущаяГостиница = Гостиница;
		Тариф = Гостиница.Тариф;
	EndIf;
КонецПроцедуры //ChangeCurrentHotel

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RoomQuotaOnChange(pItem)
	// Build list
	BuildList();
КонецПроцедуры //RoomQuotaOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RoomRateOnChange(pItem)
	If ЗначениеЗаполнено(Тариф) Тогда
		Items.FormAvailableRoomsAction.Enabled = True;
	Else
		Items.FormAvailableRoomsAction.Enabled = False;
	EndIf;
	// Build list
	BuildList();
КонецПроцедуры //RoomRateOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура CheckInDateChange()
	CheckInTime = CheckInDate;
	If ЗначениеЗаполнено(CheckInDate) Тогда
		vReferenceHour = CheckInDate - BegOfDay(CheckInDate);
		vDefaultCheckInTime = Неопределено;
		vPeriodInHours = 24;
		If ЗначениеЗаполнено(Тариф) Тогда
			vPeriodInHours = ?(Тариф.PeriodInHours = 0, vPeriodInHours, Тариф.PeriodInHours);
			If Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
				vReferenceHour = Тариф.ReferenceHour - BegOfDay(Тариф.ReferenceHour);
			EndIf;
			If ЗначениеЗаполнено(Тариф.DefaultCheckInTime) Тогда
				vDefaultCheckInTime = Тариф.DefaultCheckInTime - BegOfDay(Тариф.DefaultCheckInTime);
			EndIf;
		EndIf;
		If BegOfDay(CheckInDate) <> BegOfDay(CurrentDate()) Тогда
			If ЗначениеЗаполнено(vDefaultCheckInTime) Тогда
				CheckInDate = BegOfDay(CheckInDate) + vDefaultCheckInTime;
			Else
				CheckInDate = BegOfDay(CheckInDate) + vReferenceHour;
			EndIf;
			CheckInTime = CheckInDate;
		EndIf;
		CheckOutDate = cmCalculateCheckOutDate(Тариф, CheckInDate, Duration);
		CheckOutTime = CheckOutDate;
		// Build list
		BuildList();
	EndIf;
КонецПроцедуры //CheckInDateChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CheckInDateOnChange(pItem)
	CheckInDateChange();
КонецПроцедуры //CheckInDateOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура CheckOutDateChange()
	Duration = 0;
	CheckOutTime = CheckOutDate;
	If ЗначениеЗаполнено(Тариф) And
		ЗначениеЗаполнено(CheckInDate) And
		ЗначениеЗаполнено(CheckOutDate) Тогда
		Duration = cmCalculateDuration(Тариф, CheckInDate, CheckOutDate);
		//Build list
		BuildList();
	EndIf;
КонецПроцедуры //CheckOutDateChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CheckOutDateOnChange(pItem)
	CheckOutDateChange();
КонецПроцедуры //CheckOutDateOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура DurationChange()
	If ЗначениеЗаполнено(CheckInDate) Тогда
		CheckOutDate = cmCalculateCheckOutDate(Тариф, CheckInDate, Duration);
		CheckOutTime = CheckOutDate;
		//Build list
		BuildList();
	EndIf;	
КонецПроцедуры //DurationChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DurationOnChange(pItem)
	DurationChange();
КонецПроцедуры //DurationOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура CheckInTimeChange()
	CheckInDate = BegOfDay(CheckInDate) + (CheckInTime - BegOfDay(CheckInTime));
	CheckInTime = CheckInDate;
	If ЗначениеЗаполнено(CheckInDate) Тогда
		CheckOutDate = cmCalculateCheckOutDate(Тариф, CheckInDate, Duration);
		CheckOutTime = CheckOutDate;
		// Build list
		BuildList();
	EndIf;	
КонецПроцедуры //CheckInTimeChange

//-----------------------------------------------------------------------------
&AtServer
Процедура CheckOutTimeChange()
	CheckOutDate = BegOfDay(CheckOutDate) + (CheckOutTime - BegOfDay(CheckOutTime));
	CheckOutTime = CheckOutDate;
	CheckOutDateChange();
	// Build list
	BuildList();
КонецПроцедуры //CheckOutTimeChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CheckInTimeOnChange(pItem)
	CheckInTimeChange();
КонецПроцедуры //CheckInTimeOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CheckOutTimeOnChange(pItem)
	CheckOutTimeChange();
КонецПроцедуры //CheckOutTimeOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура GetAvailableRoomsForm()
	vCurRow = Items.RoomTypesList.CurrentData;
	// Open choice form
	If vCurRow <> Неопределено Тогда 
		vFrm = ПолучитьФорму("Справочник.НомернойФонд.ФормаВыбора");
		vFrm.Гостиница = Гостиница;
		vFrm.SelRoomQuota = RoomQuota;
		vFrm.SelRoomType = vCurRow.ТипНомера;
		vFrm.SelRoom = Неопределено;
		vFrm.SelNumberOfBeds = ?(ЗначениеЗаполнено(vCurRow.ВидРазмещения), УпрСерверныеФункции.cmGetCatalogItemRefByDescription("ВидыРазмещений", vCurRow.ВидРазмещения,,"КоличествоМест"), 0);
		vFrm.SelNumberOfRooms = ?(ЗначениеЗаполнено(vCurRow.ВидРазмещения), УпрСерверныеФункции.cmGetCatalogItemRefByDescription("ВидыРазмещений", vCurRow.ВидРазмещения,,"КоличествоНомеров"), 0);
		vFrm.ДатаНачКвоты = CheckInDate;
		vFrm.ДатаКонКвоты = CheckOutDate;
		vFrm.Open();
	EndIf;
КонецПроцедуры //GetAvailableRoomsForm

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура AvailableRoomsAction(pCommand)
	GetAvailableRoomsForm();
КонецПроцедуры //AvailableRoomsAction

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RowSelectionAction(pCommand)
	If ЗначениеЗаполнено(RoomQuota) Тогда
		vIsFolder = УпрСерверныеФункции.cmGetAttributeByRef(RoomQuota, "IsFolder");
		If vIsFolder Тогда
			vMessage = New UserMessage;
			vMessage.Field = "КвотаНомеров";
			vMessage.Text = NStr("en='You should choose allotment item not group to select ГруппаНомеров type!';ru='Нельзя выбирать тип номера при указанной группе квот!';de='Der Zimmertyp bei angegebener Quotengruppe darf nicht gewählt werden!'");
			vMessage.Message();
			Return;
		EndIf;
	EndIf;
	vItem = Items.RoomTypesList;
	vSelectedRow = Items.RoomTypesList.CurrentRow;
	If vItem.CurrentData <> Неопределено Тогда
		If ЗначениеЗаполнено(vItem.CurrentData.Ref) Тогда
			If FormOwner = Неопределено Тогда
				If vSelectedRow <> Неопределено Тогда
					RoomType = vItem.CurrentData.Ref;
				EndIf;
			Else
				vFormOwner = FormOwner;
//				While (TypeOf(vFormOwner) <> Type("ManagedForm")) Or vFormOwner = Неопределено Do
//					vFormOwner = vFormOwner.Parent;
//				EndDo;
				If vFormOwner <> Неопределено Тогда
					If vFormOwner.FormName = "Document.Бронирование.Form.tcDocumentForm" Тогда
						NotifyChoice(New Structure("КвотаНомеров, ТипНомера, ВидРазмещения, Тариф", RoomQuota, vItem.CurrentData.Ref, vItem.CurrentData.ВидРазмещения, Тариф));
					Else
						NotifyChoice(vItem.CurrentData.Ref);
					EndIf;
				Else
					NotifyChoice(vItem.CurrentData.Ref);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //RowSelectionAction

//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(Cancel, StandardProcessing)
	IsFromObject = False;
	vRoomRate = Неопределено;
	If ЭтаФорма.Parameters.Property("Тариф", vRoomRate) Тогда
		SelRoomRate = vRoomRate;
	EndIf;
	vHotel = Неопределено;
	If ЭтаФорма.Parameters.Property("Гостиница", vHotel) Тогда
		SelHotel = vHotel;
	EndIf;
	vCheckInDate = Неопределено;
	If ЭтаФорма.Parameters.Property("CheckInDate", vCheckInDate) Тогда
		SelCheckInDate = vCheckInDate;
		SelCheckInTime = vCheckInDate;
	EndIf;
	vCheckOutDate = Неопределено;
	If ЭтаФорма.Parameters.Property("ДатаВыезда", vCheckOutDate) Тогда
		SelCheckOutDate = vCheckOutDate;
		SelCheckOutTime = vCheckOutDate;
	EndIf;
	vRoomQuota = Неопределено;
	If ЭтаФорма.Parameters.Property("КвотаНомеров", vRoomQuota) Тогда
		SelRoomQuota = vRoomQuota;
	EndIf;
	vClientType = Неопределено;
	If ЭтаФорма.Parameters.Property("ТипКлиента", vClientType) Тогда
		SelClientType = vClientType;
	EndIf;
	vNumberOfAdults = Неопределено;
	If ЭтаФорма.Parameters.Property("КоличествоВзрослых", vNumberOfAdults) Тогда
		NumberOfAdults = vNumberOfAdults;
		IsFromObject = True;
	EndIf;
	vNumberOfKids = Неопределено;
	If ЭтаФорма.Parameters.Property("NumberOfKids", vNumberOfKids) Тогда
		NumberOfKids = vNumberOfKids;
		vAgeArray = Неопределено;
		If ЭтаФорма.Parameters.Property("AgeArray", vAgeArray) Тогда
			For Each vItem In vAgeArray Do
				AgeList.Add(vItem);
			EndDo;
		EndIf;
	EndIf;
КонецПроцедуры //OnCreateAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура BuildList()
	RoomTypesList.Clear();
	// Check periods
	If CheckInDate >= CheckOutDate Тогда
		CheckOutDate = CheckInDate + 86400;	
		Duration = 1;
	EndIf;
	
	// Build array of kid ages
	vAgeArray = New Array;
	For vInd = 1 To NumberOfKids Do
		Try
			vAge = ЭтаФорма["KidAge"+String(vInd)];
			vAgeArray.Add(vAge);
		Except
		EndTry;
	EndDo;
	
	vGuestsQuantity = NumberOfAdults + NumberOfKids;
	
	// Get available ГруппаНомеров types
	vRoomTypes = cmGetRoomTypesByGuestQuantity(vGuestsQuantity, Справочники.ТипыНомеров.EmptyRef(), Гостиница);

	
	// Build and run query with ГруппаНомеров inventory balances
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
	|	Min(ЗагрузкаНомеров.RoomsVacant) AS RoomsAvailable,
	|	Min(ЗагрузкаНомеров.BedsVacant) AS BedsAvailable,
	|	&qEmptyNumber AS Количество,
	|	&qEmptyAccommodationType AS ВидРазмещения,
	|	&qEmptyCalendar AS ТипДеньКалендарь,
	|	&qEmptyNumber AS Цена,
	|	&qEmptyCurrency AS Валюта,
	|	&qEmptyNumber AS Сумма,
	|	&qEmptyString AS SumPresentation,
	|	&qEmptyNumber AS AvgPrice,
	|	ЗагрузкаНомеров.ТипНомера AS Ref
	|FROM
	|	(SELECT
	|		RoomInventoryBalance.Period AS Period,
	|		RoomInventoryBalance.Гостиница AS Гостиница,
	|		RoomInventoryBalance.ТипНомера AS ТипНомера,
	|		RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
	|		CASE
	|			WHEN &qRoomQuotaIsSet
	|					AND &qDoWriteOff
	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
	|				THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
	|			ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
	|		END AS RoomsVacant,
	|		CASE
	|			WHEN &qRoomQuotaIsSet
	|					AND &qDoWriteOff
	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
	|				THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
	|			WHEN &qRoomQuotaIsSet
	|					AND NOT &qDoWriteOff
	|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
	|			ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
	|		END AS BedsVacant,
	|		RoomInventoryBalance.Гостиница.ПорядокСортировки AS HotelSortCode,
	|		RoomInventoryBalance.ТипНомера.ПорядокСортировки AS RoomTypeSortCode
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|				&qDateTimeFrom,
	|				&qDateTimeTo,
	|				Day,
	|				RegisterRecordsAndPeriodBoundaries,
	|				&qHotelIsEmpty
	|					OR Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
	|			LEFT JOIN (SELECT
	|				RoomQuotaSalesBalanceAndTurnovers.Period AS Period,
	|				RoomQuotaSalesBalanceAndTurnovers.Гостиница AS Гостиница,
	|				RoomQuotaSalesBalanceAndTurnovers.ТипНомера AS ТипНомера,
	|				RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
	|				RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS НомеровКвота,
	|				RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS МестКвота,
	|				RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS ОстаетсяНомеров,
	|				RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS ОстаетсяМест
	|			FROM
	|				AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|						&qDateTimeFrom,
	|						&qDateTimeTo,
	|						Day,
	|						RegisterRecordsAndPeriodBoundaries,
	|						(&qHotelIsEmpty
	|							OR Гостиница = &qHotel)
	|							AND &qRoomQuotaIsSet
	|							AND КвотаНомеров = &qRoomQuota) AS RoomQuotaSalesBalanceAndTurnovers) AS RoomQuotaBalances
	|			ON RoomInventoryBalance.Гостиница = RoomQuotaBalances.Гостиница
	|				AND RoomInventoryBalance.ТипНомера = RoomQuotaBalances.ТипНомера
	|				AND RoomInventoryBalance.Period = RoomQuotaBalances.Period) AS ЗагрузкаНомеров
	|	WHERE ЗагрузкаНомеров.ТипНомера IN (&qRoomTypesList) "+
	?(ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент)," AND ЗагрузкаНомеров.RoomsVacant <> 0	AND ЗагрузкаНомеров.BedsVacant <> 0", "")+
	" GROUP BY
	|	ТипНомера
	| ORDER BY
	|	ТипНомера.ПорядокСортировки";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qRoomQuota", RoomQuota);
	vQry.SetParameter("qRoomQuotaIsSet", ЗначениеЗаполнено(RoomQuota));
	vQry.SetParameter("qDoWriteOff", ?(ЗначениеЗаполнено(RoomQuota), RoomQuota.DoWriteOff, False));
	vQry.SetParameter("qDateTimeFrom", BegOfDay(CheckInDate));
	vQry.SetParameter("qDateTimeTo", EndOfDay(CheckOutDate));
	vQry.SetParameter("qRoomTypesList", vRoomTypes.UnloadColumn("ТипНомера"));
	vQry.SetParameter("qEmptyNumber", 0);
	vQry.SetParameter("qEmptyString", "");
	vQry.SetParameter("qEmptyAccommodationType", Справочники.ВидыРазмещений.EmptyRef());
	vQry.SetParameter("qEmptyCalendar", Справочники.CalendarDayTypes.EmptyRef());
	vQry.SetParameter("qEmptyCurrency", Справочники.Currencies.EmptyRef());
	vQryRes = vQry.Execute().Unload();
	
	ValueToFormAttribute(vQryRes, "RoomTypesList");
	// Get default Контрагент
	vCustomer = Неопределено;
	vCurUser = ПараметрыСеанса.ТекПользователь;
	If ЗначениеЗаполнено(vCurUser.Контрагент) Тогда
		vCustomer = vCurUser.Контрагент;
	EndIf;
	If IsFromObject Тогда
		//Items.NumberOfPersons.Visible = True;
		// Get ГруппаНомеров type prices
		//vCurRoomTypeAccTypes = Неопределено;
		vRoomTypeBalances = cmGetRoomTypeBalancesTable(vQryRes, False, Гостиница, CheckInDate, CheckOutDate, ClientType, vCustomer, , , , , , , Тариф, , NumberOfAdults, NumberOfKids, vAgeArray);
		If vRoomTypeBalances <> Неопределено And vRoomTypeBalances.Count()>0 Тогда
			For Each vRow In RoomTypesList Do
				vFindedRows = vRoomTypeBalances.FindRows(New Structure("ТипНомера", vRow.ТипНомера)); 
				If vFindedRows <> Неопределено And vFindedRows.Count() > 0 Тогда
					vSum = 0;
					vCurrency = Справочники.Currencies.EmptyRef();
					For Each vBalanceRow In vFindedRows Do
						vSum = vSum + vBalanceRow.Amount;
						vCurrency = vBalanceRow.Валюта;
					EndDo;
					vRow.Сумма = vSum;
					vRow.SumPresentation = cmFormatSum(vSum, vCurrency);
					vRow.Валюта = vCurrency;
				EndIf;
			EndDo;
		EndIf;
		Items.RoomTypesListSumPresentation.Visible = True;
		Items.RoomTypesListCurrency.Visible = True;
	EndIf;	
КонецПроцедуры //BuildList

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура NumberOfKidsOnChange(pItem)
	If NumberOfKids = 0 Тогда
		Items.AgeDecoration.Visible = False;
		If LastKidsNumber > 0 Тогда
			For vInd = 1 To LastKidsNumber Do
				Try
					Items["KidAge"+String(vInd)].Visible = False;
					ЭтаФорма["KidAge"+String(vInd)] = 0;
				Except
				EndTry;
			EndDo;
		EndIf;
	Else
		If NumberOfKids > NumberOfKidAgeFields Тогда
			NumberOfKids = NumberOfKidAgeFields;
			Предупреждение(NStr("en='Maximum number of children allowed is " + NumberOfKidAgeFields + "!'; de='Maximum number of children allowed is " + NumberOfKidAgeFields + "!'; ru='Максимально возможное число детей равно " + NumberOfKidAgeFields + "!'"));
		EndIf;
		Items.AgeDecoration.Visible = True;
		If NumberOfKids < LastKidsNumber Тогда
			For vInd = NumberOfKids + 1 To LastKidsNumber Do
				Try
					Items["KidAge"+String(vInd)].Visible = False;
					ЭтаФорма["KidAge"+String(vInd)] = 0;
				Except
				EndTry;
			EndDo;
		ElsIf NumberOfKids > LastKidsNumber Тогда
			vNumberOfFieldsToAdd = 0;
			If NumberOfKids > NumberOfKidAgeFields Тогда
				Try
					For vInd = LastKidsNumber + 1 To NumberOfKidAgeFields Do
						Items["KidAge"+String(vInd)].Visible = True;
						ЭтаФорма["KidAge"+String(vInd)] = 0;
					EndDo;
				Except
				EndTry;
				vNumberOfFieldsToAdd = NumberOfKids - NumberOfKidAgeFields;
				If LastKidsNumber > NumberOfKidAgeFields Тогда
					vNumberOfFieldsToAdd = vNumberOfFieldsToAdd - (LastKidsNumber - NumberOfKidAgeFields);
				EndIf;
				AddKidAgeAttributes(vNumberOfFieldsToAdd);
			Else
				Try
					For vInd = LastKidsNumber + 1 To NumberOfKids Do
						Items["KidAge"+String(vInd)].Visible = True;
						ЭтаФорма["KidAge"+String(vInd)] = 0;
					EndDo;
				Except
				EndTry;
			EndIf;
		EndIf;
	EndIf;
	LastKidsNumber = NumberOfKids;
КонецПроцедуры //NumberOfKidsOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура AddKidAgeAttributes(pNumberOfFields)
	vTempArray = New Array;
	For vInd = 1 To pNumberOfFields Do
		vTempArray.Add(New FormAttribute("KidAge"+String(NumberOfKidAgeFields+vInd), New TypeDescription("Number")));
	EndDo;
	ChangeAttributes(vTempArray);	
	For vInd = 1 To pNumberOfFields Do
		vNewField = Items.Add("KidAge"+String(NumberOfKidAgeFields+vInd), Type("FormField"), Items.KidsGroup);
		vNewField.ТипРазмещения = FormFieldType.InputField;
		vNewField.HorizontalAlign = ItemHorizontalLocation.Center;
		vNewField.Width = 2;
		vNewField.TitleLocation = FormItemTitleLocation.None;
		vNewField.DataPath = "KidAge"+String(NumberOfKidAgeFields+vInd);
	EndDo;
	NumberOfKidAgeFields = NumberOfKidAgeFields + pNumberOfFields;
КонецПроцедуры //AddKidAgeAttributes

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура KidAgeOnChange(pItem)
	BuildList();
КонецПроцедуры //KidAgeOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура NumberOfAdultsOnChange(pItem)
	BuildList();
КонецПроцедуры //NumberOfAdultsOnChange
