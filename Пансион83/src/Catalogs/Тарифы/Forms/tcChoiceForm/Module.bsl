//-------------------------------------------------------
&AtServer
Процедура AddNewFilter(pItem, pValue) Экспорт
	vFilterItems = List.Filter.Items;
	vFindedField = List.ConditionalAppearance.FilterAvailableFields.Items.Find(Right(pItem, StrLen(pItem)-3)).Field;
	//Deleting old filter
	N=1;
	For Num = 1 to vFilterItems.Count() Do
		If vFilterItems.Get(vFilterItems.Count()-N).LeftValue = vFindedField Тогда
			vFilterItems.Delete(vFilterItems.Get(vFilterItems.Count()-N));
		Else
			N=N+1;
		EndIf;
	EndDo;
	//Add new filter
	If ЗначениеЗаполнено(String(pValue)) Тогда
		vNewFilter = vFilterItems.Add(Type("DataCompositionFilterItem"));
		vNewFilter.LeftValue = vFindedField;
		vNewFilter.RightValue = ЭтаФорма[pItem];		
	EndIf;
	
	// Reset all filters
	Title = NStr("en='Filter ГруппаНомеров rates by: ';ru='Отбор тарифов по: ';de='Auswahl von Tarifen nach: '");
	// Filter by ГруппаНомеров rate type
	If ЗначениеЗаполнено(SelRoomRateType) Тогда
		Title = Title + NStr("en='ГруппаНомеров rate type; ';ru='типу тарифа; ';de='Tariftyp; '");
	EndIf;
	// Filter by calendar
	If ЗначениеЗаполнено(SelCalendar) Тогда
		Title = Title + NStr("en='calendar; ';ru='календарю; ';de='dem Kalender; '");
	EndIf;
	// Filter by Фирма
	If ЗначениеЗаполнено(SelCompany) Тогда
		Title = Title + NStr("en='Фирма; ';ru='фирме; ';de='der Firma; '");
	EndIf;
	// Filter by hotel
	If ЗначениеЗаполнено(SelHotel) Тогда
		Title = Title + NStr("en='hotel; ';ru='гостинице; ';de='Гостиница; '");
	EndIf;
	
	//If show all ГруппаНомеров rates
	If НЕ ЗначениеЗаполнено(SelHotel)
		And НЕ ЗначениеЗаполнено(SelCompany)
		And НЕ ЗначениеЗаполнено(SelCalendar)
		And НЕ ЗначениеЗаполнено(SelRoomRateType) Тогда
		Title = NStr("en='All ГруппаНомеров rates';ru='Все тарифы';de='Alle Tarife'");
	EndIf;

КонецПроцедуры //AddNewFilter

//-------------------------------------------------------
&AtServer
Процедура DeletingAllFilters()
	List.Filter.Items.Clear();
КонецПроцедуры //DeletingAllFilters

//-------------------------------------------------------
&НаКлиенте
Процедура RoomRateTypeOnChange(pItem)
	AddNewFilter(pItem.Name, pItem.EditText);
КонецПроцедуры //RoomRateTypeOnChange

//-------------------------------------------------------
&НаКлиенте
Процедура CalendarOnChange(pItem)
	AddNewFilter(pItem.Name, pItem.EditText);
КонецПроцедуры //CalendarOnChange

//-------------------------------------------------------
&НаКлиенте
Процедура CompanyOnChange(pItem)
	AddNewFilter(pItem.Name, pItem.EditText);
КонецПроцедуры //CompanyOnChange

//-------------------------------------------------------
&НаКлиенте
Процедура HotelOnChange(pItem)
	AddNewFilter(pItem.Name, pItem.EditText);
КонецПроцедуры //HotelOnChange

//-------------------------------------------------------
&НаКлиенте
Процедура ShowAll(pCommand)
	Title = NStr("en='All ГруппаНомеров rates';ru='Все тарифы';de='Alle Tarife'");
	DeletingAllFilters();
КонецПроцедуры //ShowAll

//-------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	SetDefaultSearchFilter();
	If ЗначениеЗаполнено(УпрСерверныеФункции.cmGetCurrentUserAttribute("Контрагент")) Тогда
		Items.SelHotel.ClearButton = False;
		Items.FormShowAll.Visible = False;
	EndIf;
КонецПроцедуры //OnOpen

//-------------------------------------------------------
&AtServer
Процедура SetDefaultSearchFilter()
	If НЕ ЗначениеЗаполнено(SelHotel) Тогда
		SelHotel = ПараметрыСеанса.ТекущаяГостиница;
		AddNewFilter("SelHotel", SelHotel);
	EndIf;
КонецПроцедуры //SetDefaultSearchFilter
