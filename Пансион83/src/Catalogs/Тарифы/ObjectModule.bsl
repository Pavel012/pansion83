//-----------------------------------------------------------------------------
// Get list of prices for given ГруппаНомеров rate and parameters
// - pDate is optional. If is not specified, then function gets current prices
// - pClientType is optional. If is not specified then it is being set to empty ref.
// - pRoomType is optional. If is specified, then prices for this given ГруппаНомеров type 
//   are returned.
// - pAccommodationType is optional. If is specified, then prices for this given 
//   accommodation type are returned.
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Function pmGetRoomRateServicePackagesList(pServicePackagesList = Неопределено) Экспорт
	vPackagesList = New СписокЗначений();
	If ЗначениеЗаполнено(ServicePackage) Тогда
		vPackagesList.Add(ServicePackage);
	EndIf;
	For Each vServicePackagesRow In ServicePackages Do
		If ЗначениеЗаполнено(vServicePackagesRow.ServicePackage) Тогда
			If vPackagesList.FindByValue(vServicePackagesRow.ServicePackage) = Неопределено Тогда
				vPackagesList.Add(vServicePackagesRow.ServicePackage);
			EndIf;
		EndIf;
	EndDo;
	If pServicePackagesList <> Неопределено Тогда
		For Each vServicePackagesListItem In pServicePackagesList Do
			If ЗначениеЗаполнено(vServicePackagesListItem.Value) Тогда
				vPackagesList.Add(vServicePackagesListItem.Value);
			EndIf;
		EndDo;
	EndIf;
	Return vPackagesList;
EndFunction //pmGetRoomRateServicePackagesList

//-----------------------------------------------------------------------------
Function pmGetRoomRateDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Description);
	Else
		If IsBlankString(DescriptionTranslations) Тогда
			vDescr = СокрЛП(Description);
		Else
			vDescr = СокрЛП(DescriptionTranslations);
		EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetRoomRateDescription

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	Author = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
	Гостиница = ПараметрыСеанса.ТекущаяГостиница;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Returns MLOS and CTA for the given check-in date and ГруппаНомеров type
//-----------------------------------------------------------------------------
Function pmGetRoomRateRestrictions(pCheckInDate, pCheckOutDate, pRoomType, pWithoutOnline = False) Экспорт
	vRestrStruct = New Structure("MLOS, MaxLOS, MinDaysBeforeCheckIn, MaxDaysBeforeCheckIn, CTA, CTD", 0, 0, 0, 0, False, False);
	If НЕ ЗначениеЗаполнено(pCheckInDate) Or НЕ ЗначениеЗаполнено(pCheckOutDate) Тогда
		Return vRestrStruct;
	EndIf;
	// Get week days
	vDayOfWeek = WeekDay(pCheckInDate);
	vCheckOutDayOfWeek = WeekDay(pCheckOutDate);
	// Get accounting dates
	vAccountingDate = BegOfDay(pCheckInDate);
	vCheckOutAccountingDate = BegOfDay(pCheckOutDate);
	// Try to get calendar day type for the check-in date
	
	vQry = New Query();
	vQry.Text = "SELECT
	            |	RoomRateRestrictions.Гостиница,
	            |	RoomRateRestrictions.Тариф,
	            |	RoomRateRestrictions.ТипНомера,
	            |	RoomRateRestrictions.ТипДеньКалендарь,
	            |	RoomRateRestrictions.DayOfWeek,
	            |	RoomRateRestrictions.УчетнаяДата,
	            |	RoomRateRestrictions.MLOS,
	            |	RoomRateRestrictions.MaxLOS,
	            |	RoomRateRestrictions.CTA,
	            |	RoomRateRestrictions.CTD,
	            |	RoomRateRestrictions.MinDaysBeforeCheckIn,
	            |	RoomRateRestrictions.MaxDaysBeforeCheckIn,
	            |	RoomRateRestrictions.IsForOnlineOnly
	            |FROM
	            |	InformationRegister.RoomRateRestrictions AS RoomRateRestrictions
	            |WHERE
	            |	RoomRateRestrictions.Тариф = &qRoomRate
	            |	AND (RoomRateRestrictions.Гостиница = &qEmptyHotel
	            |			OR &qHotelIsFilled
	            |				AND RoomRateRestrictions.Гостиница = &qHotel)
	            |	AND (RoomRateRestrictions.ТипНомера = &qEmptyRoomType
	            |			OR &qRoomTypeIsFilled
	            |				AND RoomRateRestrictions.ТипНомера = &qRoomType)
	            |	AND (RoomRateRestrictions.ТипДеньКалендарь = &qEmptyCalendarDayType
	            |			OR &qCalendarDayTypeIsFilled
	            |				AND RoomRateRestrictions.ТипДеньКалендарь = &qCalendarDayType)
	            |	AND (RoomRateRestrictions.DayOfWeek = 0
	            |			OR RoomRateRestrictions.DayOfWeek = &qDayOfWeek
	            |				AND NOT RoomRateRestrictions.CTD
	            |				AND RoomRateRestrictions.DayOfWeek > 0
	            |			OR RoomRateRestrictions.DayOfWeek = &qCheckOutDayOfWeek
	            |				AND RoomRateRestrictions.CTD
	            |				AND RoomRateRestrictions.DayOfWeek > 0)
	            |	AND (RoomRateRestrictions.УчетнаяДата = &qEmptyDate
	            |			OR &qAccountingDateIsFilled
	            |				AND RoomRateRestrictions.УчетнаяДата = &qAccountingDate
	            |				AND NOT RoomRateRestrictions.CTD
	            |			OR RoomRateRestrictions.CTD)
	            |	AND (RoomRateRestrictions.УчетнаяДата = &qEmptyDate
	            |			OR &qCheckOutAccountingDateIsFilled
	            |				AND RoomRateRestrictions.УчетнаяДата = &qCheckOutAccountingDate
	            |				AND RoomRateRestrictions.CTD
	            |			OR NOT RoomRateRestrictions.CTD)
	            |	AND (NOT &qWithoutOnline
	            |			OR &qWithoutOnline
	            |				AND NOT RoomRateRestrictions.IsForOnlineOnly)";
	vQry.SetParameter("qRoomRate", Ref);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoomTypeIsFilled", ЗначениеЗаполнено(pRoomType));
	vQry.SetParameter("qEmptyRoomType", Справочники.ТипыНомеров.EmptyRef());
	
	vQry.SetParameter("qEmptyCalendarDayType", Справочники.ТипДневногоКалендаря.EmptyRef());
	vQry.SetParameter("qDayOfWeek", vDayOfWeek);
	vQry.SetParameter("qCheckOutDayOfWeek", vCheckOutDayOfWeek);
	vQry.SetParameter("qAccountingDate", vAccountingDate);
	vQry.SetParameter("qAccountingDateIsFilled", ЗначениеЗаполнено(vAccountingDate));
	vQry.SetParameter("qCheckOutAccountingDate", vCheckOutAccountingDate);
	vQry.SetParameter("qCheckOutAccountingDateIsFilled", ЗначениеЗаполнено(vCheckOutAccountingDate));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qWithoutOnline", pWithoutOnline);
	vRestrictions = vQry.Execute().Unload();
	For Each vRestrictionsRow In vRestrictions Do
		If vRestrictionsRow.CTA Тогда
			vRestrStruct.CTA = True;
		EndIf;
		If vRestrictionsRow.CTD Тогда
			vRestrStruct.CTD = True;
		EndIf;
		If vRestrictionsRow.MLOS > vRestrStruct.MLOS Тогда
			vRestrStruct.MLOS = vRestrictionsRow.MLOS;
		EndIf;
		If vRestrictionsRow.MaxLOS <> 0 And (vRestrStruct.MaxLOS = 0 Or vRestrictionsRow.MaxLOS < vRestrStruct.MaxLOS) Тогда
			vRestrStruct.MaxLOS = vRestrictionsRow.MaxLOS;
		EndIf;
		If vRestrictionsRow.MinDaysBeforeCheckIn > vRestrStruct.MinDaysBeforeCheckIn Тогда
			vRestrStruct.MinDaysBeforeCheckIn = vRestrictionsRow.MinDaysBeforeCheckIn;
		EndIf;
		If vRestrictionsRow.MaxDaysBeforeCheckIn <> 0 And (vRestrStruct.MaxDaysBeforeCheckIn = 0 Or vRestrictionsRow.MaxDaysBeforeCheckIn < vRestrStruct.MaxDaysBeforeCheckIn) Тогда
			vRestrStruct.MaxDaysBeforeCheckIn = vRestrictionsRow.MaxDaysBeforeCheckIn;
		EndIf;
	EndDo;
	Return vRestrStruct;
EndFunction //pmGetRoomRateRestrictions

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	If НЕ IsFolder Тогда
		Author = Справочники.Сотрудники.EmptyRef();
		CreateDate = '00010101';
		IsOnlineRate = False;
	EndIf;
КонецПроцедуры //OnCopy
