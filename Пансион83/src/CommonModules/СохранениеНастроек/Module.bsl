//-----------------------------------------------------------------------------
// Function returns hotel non replicating attribute values from the information register
//-----------------------------------------------------------------------------
Function cmGetNonReplicatingHotelAttributes(pHotel) Экспорт
	// Read from database
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	HotelNonReplicatingAttributes.Гостиница,
	|	HotelNonReplicatingAttributes.Prefix,
	|	HotelNonReplicatingAttributes.GuestGroupFolder,
	|	HotelNonReplicatingAttributes.BLOBRootFolder,
	|	HotelNonReplicatingAttributes.FolioAccountingNumberPrefix,
	|	HotelNonReplicatingAttributes.FolioProFormaNumberPrefix
	|FROM
	|	InformationRegister.HotelNonReplicatingAttributes AS HotelNonReplicatingAttributes
	|WHERE
	|	HotelNonReplicatingAttributes.Гостиница = &qHotel";
	vQry.SetParameter("qHotel", pHotel);
	vNonReplicatingHotelAttributes = vQry.Execute().Unload();
	// Return
	Return vNonReplicatingHotelAttributes;
EndFunction //cmGetNonReplicatingHotelAttributes

//-----------------------------------------------------------------------------
// Function returns employee non replicating attribute values from the information register
//-----------------------------------------------------------------------------
Function сmGetEmployeeNonReplicatingAttributes(pEmployee) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СотрРеквНеизм.Employee,
	|	СотрРеквНеизм.Workstation,
	|	СотрРеквНеизм.PermissionGroup
	|FROM
	|	InformationRegister.СотрРеквНеизм AS СотрРеквНеизм
	|WHERE
	|	СотрРеквНеизм.Employee = &qEmployee";
	vQry.SetParameter("qEmployee", pEmployee);
	Return vQry.Execute().Unload();
EndFunction //сmGetEmployeeNonReplicatingAttributes

//-----------------------------------------------------------------------------
// Get list of calendar days with day types within given period
// - pCalendar is mandatory and is calendar item reference.
// - pDateFrom is mandatory.
// - pDateTo is mandatory.
// - CheckInDate and CheckOutDate are used to calculate guest period of stay length in days
//-----------------------------------------------------------------------------
Function cmGetCalendarDays(pCalendar, pDateFrom, pDateTo, pCheckInDate, pCheckOutDate) Экспорт
	// Common checks	
	If НЕ ЗначениеЗаполнено(pDateFrom) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetCalendarDays function.
		               |CAUSE: Empty pDateFrom parameter value was passed to the function.
					   |DESC: Mandatory parameter pDateFrom should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetCalendarDays.
					   |CAUSE: В функцию передано пустое значение параметра pDateFrom.
					   |DESC: Обязательный параметр pDateFrom должен быть явно указан.';
				   |de='ERR: Fehler bei Aufruf der Funktion cmGetCalendarDays
				       |CAUSE: In die Funktion wurde ein leerer Wert des Parameters pDateFrom übertragen.
					   |DESC: Das Pflichtparameter pDateFrom muss eindeutig angegeben sein.'"));
	EndIf;
	If НЕ ЗначениеЗаполнено(pDateTo) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling cmGetCalendarDays function.
		               |CAUSE: Empty pDateTo parameter value was passed to the function.
					   |DESC: Mandatory parameter pDateTo should be filled.';
				   |ru='ERR: Ошибка вызова функции cmGetCalendarDays.
				       |CAUSE: В функцию передано пустое значение параметра pDateTo.
					   |DESC: Обязательный параметр pDateTo должен быть явно указан.';
				   |de='ERR: Fehler bei Aufruf der Funktion cmGetCalendarDays
				       |CAUSE: In die Funktion wurde ein leerer Wert des Parameters pDateTo übertragen.
					   |DESC: Das Pflichtparameter pDateTo muss eindeutig angegeben sein.'"));
	EndIf;
	vCheckInDate = pCheckInDate;
	If НЕ ЗначениеЗаполнено(vCheckInDate) Тогда
		vCheckInDate = pDateFrom;
	EndIf;
	vCheckOutDate = pCheckOutDate;
	If НЕ ЗначениеЗаполнено(vCheckOutDate) Тогда
		vCheckOutDate = pDateTo;
	EndIf;
	
	// Build and run query to get calendar days
	qGetDays = New Query();
	If pCalendar.IsPerPeriod Тогда
		qGetDays.Text = 
		"SELECT
		|	КалендарьДень.Period AS Period,
		|	КалендарьДень.Calendar,
		|	КалендарьДень.ТипДеньКалендарь,
		|	КалендарьДень.ТипДеньКалендарь.ПорядокСортировки AS CalendarDayTypeSortCode,
		|	КалендарьДень.Timetable,
		|	DATEDIFF(&qCheckInDate, &qCheckOutDate, DAY) AS LengthOfStay,
		|	ДнейТипКалендарь.ТипДеньКалендарь AS CalendarDayTypeByLengthOfStay,
		|	ДнейТипКалендарь.ТипДеньКалендарь.ПорядокСортировки AS CalendarDayTypeByLengthOfStaySortCode,
		|	ДнейТипКалендарь.LengthOfStay AS LengthOfStayByLengthOfStay
		|FROM
		|	InformationRegister.КалендарьДень AS КалендарьДень
		|		LEFT JOIN InformationRegister.ДнейТипКалендарь AS ДнейТипКалендарь
		|		ON КалендарьДень.Calendar = ДнейТипКалендарь.Calendar
		|			AND (DATEDIFF(&qCheckInDate, &qCheckOutDate, DAY) >= ДнейТипКалендарь.LengthOfStay)
		|WHERE
		|	КалендарьДень.Calendar = &qCalendar
		|	AND КалендарьДень.Period >= &qDateFrom
		|	AND КалендарьДень.Period <= &qDateTo
		|
		|ORDER BY
		|	Period,
		|	LengthOfStayByLengthOfStay DESC";
	Else
		qGetDays.Text = 
		"SELECT
		|	КалендарьДень.Period AS Period,
		|	КалендарьДень.Calendar,
		|	КалендарьДень.ТипДеньКалендарь,
		|	КалендарьДень.ТипДеньКалендарь.ПорядокСортировки AS CalendarDayTypeSortCode,
		|	КалендарьДень.Timetable,
		|	DATEDIFF(&qCheckInDate, КалендарьДень.Period, DAY) + 1 AS LengthOfStay,
		|	ДнейТипКалендарь.ТипДеньКалендарь AS CalendarDayTypeByLengthOfStay,
		|	ДнейТипКалендарь.ТипДеньКалендарь.ПорядокСортировки AS CalendarDayTypeByLengthOfStaySortCode,
		|	ДнейТипКалендарь.LengthOfStay AS LengthOfStayByLengthOfStay
		|FROM
		|	InformationRegister.КалендарьДень AS КалендарьДень
		|		LEFT JOIN InformationRegister.ДнейТипКалендарь AS ДнейТипКалендарь
		|		ON КалендарьДень.Calendar = ДнейТипКалендарь.Calendar
		|			AND ((DATEDIFF(&qCheckInDate, КалендарьДень.Period, DAY) + 1) >= ДнейТипКалендарь.LengthOfStay)
		|WHERE
		|	КалендарьДень.Calendar = &qCalendar
		|	AND КалендарьДень.Period >= &qDateFrom
		|	AND КалендарьДень.Period <= &qDateTo
		|ORDER BY
		|	Period,
		|	LengthOfStayByLengthOfStay DESC";
	EndIf;
	qGetDays.SetParameter("qCalendar", pCalendar);
	qGetDays.SetParameter("qDateFrom", BegOfDay(pDateFrom));
	qGetDays.SetParameter("qDateTo", pDateTo);
	qGetDays.SetParameter("qCheckInDate", BegOfDay(vCheckInDate));
	qGetDays.SetParameter("qCheckOutDate", BegOfDay(vCheckOutDate));
	vDays = qGetDays.Execute().Unload();
	
	// Remove join extended rows and set resulting calendar day type by comparing weights of both
	If vDays.Count() > 0 Тогда
		If vDays.Count() > 1 Тогда
			i = 0;
			While i < (vDays.Count() - 1) Do
				vCurRow = vDays.Get(i);
				If ЗначениеЗаполнено(vCurRow.ТипДняКалендаря) And ЗначениеЗаполнено(vCurRow.CalendarDayTypeByLengthOfStay) Тогда
					If vCurRow.CalendarDayTypeByLengthOfStay.Weight > vCurRow.ТипДняКалендаря.Weight Тогда
						vCurRow.ТипДняКалендаря = vCurRow.CalendarDayTypeByLengthOfStay;
						vCurRow.CalendarDayTypeSortCode = vCurRow.CalendarDayTypeByLengthOfStaySortCode;
					EndIf;
				EndIf;
				vNextRow = vDays.Get(i + 1);
				If vCurRow.Period = vNextRow.Period And vCurRow.LengthOfStay = vNextRow.LengthOfStay Тогда
					vDays.Delete(i + 1);
				Else
					i = i + 1;
				EndIf;
			EndDo;
		Else
			vCurRow = vDays.Get(0);
			If ЗначениеЗаполнено(vCurRow.ТипДняКалендаря) And ЗначениеЗаполнено(vCurRow.CalendarDayTypeByLengthOfStay) Тогда
				If vCurRow.CalendarDayTypeByLengthOfStay.Weight > vCurRow.ТипДняКалендаря.Weight Тогда
					vCurRow.ТипДняКалендаря = vCurRow.CalendarDayTypeByLengthOfStay;
					vCurRow.CalendarDayTypeSortCode = vCurRow.CalendarDayTypeByLengthOfStaySortCode;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	
	// Return
	Return vDays;
EndFunction //cmGetCalendarDays

//-----------------------------------------------------------------------------
// Description: Returns list of accumulation discount types
// Parameters: Discount type to return in value table
// Return value: Value table with accumulating discount types
//-----------------------------------------------------------------------------
Function cmGetAccumulatingDiscountTypesTable(pDiscountType = Неопределено) Экспорт
	// Build and run query
	qAccDisTypes = New Query;
	qAccDisTypes.Text = 
	"SELECT
	|	ТипыСкидок.Ref AS ТипСкидки,
	|	ТипыСкидок.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.ТипыСкидок AS DiscountTypes
	|WHERE
	|	(NOT ТипыСкидок.DeletionMark)
	|	AND ТипыСкидок.IsAccumulatingDiscount
	|	AND ((NOT ТипыСкидок.HasToBeDirectlyAssigned)
	|				AND &qDiscountTypeIsEmpty
	|			OR ТипыСкидок.HasToBeDirectlyAssigned
	|				AND ТипыСкидок.Ref = &qDiscountType)
	|ORDER BY
	|	ПорядокСортировки";
	vDiscountType = Справочники.ТипыСкидок.EmptyRef();
	If ЗначениеЗаполнено(pDiscountType) Тогда
		If НЕ pDiscountType.IsFolder And НЕ pDiscountType.DeletionMark And 
		   pDiscountType.IsAccumulatingDiscount And pDiscountType.HasToBeDirectlyAssigned Тогда
			vDiscountType = pDiscountType;
		EndIf;
	EndIf;
	qAccDisTypes.SetParameter("qDiscountType", vDiscountType);
	qAccDisTypes.SetParameter("qDiscountTypeIsEmpty", НЕ ЗначениеЗаполнено(vDiscountType));
	vAccDisTypes = qAccDisTypes.Execute().Unload();
	Return vAccDisTypes;
EndFunction //cmGetAccumulatingDiscountTypes
