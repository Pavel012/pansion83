//-----------------------------------------------------------------------------
// Gets discount percent
// - pDate is optional. If is not specified, then function gets discount on current time
// Returns discount percent
//-----------------------------------------------------------------------------
Function pmGetDiscount(Val pDate = Неопределено, pService = Неопределено, pHotel = Неопределено) Экспорт
	// Fill parameter default values 
	If НЕ ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	EndIf;
	vHotel = Справочники.Гостиницы.EmptyRef();
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
	Else
		vHotel = pHotel;
	EndIf;
	
	// Initialize return parameters
	vDiscount = 0;
	
	// Build query
	q = New Query;
	If ЗначениеЗаполнено(pService) Тогда
		q.Text =
		"SELECT
		|	Скидки.Скидка
		|FROM
		|	InformationRegister.Скидки.SliceLast(
		|			&qDate,
		|			ТипСкидки = &qDiscountType
		|				AND (Гостиница = &qHotel
		|					OR Гостиница = &qEmptyHotel)
		|				AND ServiceGroup IN (&qServiceGroupsList)) AS Скидки";
		// Set parameters
		q.SetParameter("qDate", pDate);
		q.SetParameter("qDiscountType", Ref);
		q.SetParameter("qHotel", vHotel);
		q.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
		
		// Run query
		vResTable = q.Execute().Unload();
		For Each vResTableRow In vResTable Do
			vDiscount = vResTableRow.Discount;
			Break;
		EndDo;
	EndIf;
	If НЕ ЗначениеЗаполнено(pService) Or (ЗначениеЗаполнено(pService) And vDiscount = 0) Тогда
		q.Text =
		"SELECT
		|	Скидки.Скидка
		|FROM
		|	InformationRegister.Скидки.SliceLast(
		|			&qDate,
		|			ТипСкидки = &qDiscountType
		|				AND (Гостиница = &qHotel
		|					OR Гостиница = &qEmptyHotel)
		|				AND ServiceGroup = &qEmptyServiceGroup) AS Скидки";
		// Set parameters
		q.SetParameter("qDate", pDate);
		q.SetParameter("qDiscountType", Ref);
		q.SetParameter("qHotel", vHotel);
		q.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
		q.SetParameter("qEmptyServiceGroup", Справочники.НаборыУслуг.EmptyRef());
		// Run query
		vResTable = q.Execute().Unload();
		For Each vResTableRow In vResTable Do
			vDiscount = vResTableRow.Discount;
			Break;
		EndDo;
	EndIf;
	If НЕ ЗначениеЗаполнено(pService) And vDiscount = 0 And НЕ DifferentDiscountPercentsForServiceGroupsAllowed Тогда
		q.Text =
		"SELECT
		|	Скидки.Скидка
		|FROM
		|	InformationRegister.Скидки.SliceLast(
		|			&qDate,
		|			ТипСкидки = &qDiscountType
		|				AND (Гостиница = &qHotel
		|					OR Гостиница = &qEmptyHotel)) AS Скидки";
		// Set parameters
		q.SetParameter("qDate", pDate);
		q.SetParameter("qHotel", vHotel);
		q.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
		q.SetParameter("qDiscountType", Ref);
		// Run query
		vResTable = q.Execute().Unload();
		For Each vResTableRow In vResTable Do
			vDiscount = vResTableRow.Discount;
			Break;
		EndDo;
	EndIf;
	
	// Return
	Return vDiscount;
EndFunction //pmGetDiscount

//-----------------------------------------------------------------------------
// Gets accumulating discount percent
// - pDate is optional. If is not specified, then function gets discount on current time
// - pResource is mandatory. Resource is numeric value that is checked against resource limits.
// Returns discount percent
//-----------------------------------------------------------------------------
Function pmGetAccumulatingDiscount(pService, Val pDate = Неопределено, pResource, 
                                   rDiscountConfirmationText) Экспорт
	// Fill parameter default values 
	If НЕ ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	EndIf;
	
	// Initialize return parameters
	vDiscount = 0;
	
	// Build query
	q = New Query;
	q.Text =
	"SELECT
	|	Скидки.Скидка,
	|	Скидки.ResourceLimit AS ResourceLimit,
	|	Скидки.ServiceGroup
	|FROM
	|	InformationRegister.НакопительныеСкидки.SliceLast(&qDate, ТипСкидки = &qDiscountType) AS Скидки
	|ORDER BY
	|	ResourceLimit";
	// Set parameters
	q.SetParameter("qDate", pDate);
	q.SetParameter("qDiscountType", Ref);
	// Run query
	vAccDiscounts = q.Execute().Unload();
	For Each vAccDiscount In vAccDiscounts Do
		If НЕ ЗначениеЗаполнено(vAccDiscount.ServiceGroup) Тогда
			
		EndIf;
		If vAccDiscount.ResourceLimit <= pResource Тогда
			vDiscount = vAccDiscount.Discount;
			rDiscountConfirmationText = СокрЛП(Description) + 
			                            " (" + pResource + " >= " + vAccDiscount.ResourceLimit + ")";
		Else
			Break;
		EndIf;
	EndDo;
	
	// Return
	Return vDiscount;
EndFunction //pmGetAccumulatingDiscount

//-----------------------------------------------------------------------------
Function pmGetAccumulatingDiscountResources(Val pDate = Неопределено, 
											pCustomer = Неопределено, 
                                            pContract = Неопределено, 
                                            pClient = Неопределено, 
                                            pDiscountCard = Неопределено,
											pGuestGroup = Неопределено) Экспорт
	// Fill parameter default values 
	If НЕ ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	EndIf;
	// Initialize map with resources
	
	// Build and run query
	vDateTo = pDate;
	qAccDisRes = New Query;
	If AccumulatingDiscountPeriod = 0 And НЕ ЗначениеЗаполнено(AccumulatingDiscountFromDate) Тогда
		qAccDisRes.Text = 
		"SELECT
		|	AccumulatingDiscountResourcesBalances.ТипСкидки,
		|	AccumulatingDiscountResourcesBalances.ИзмерениеСкидки,
		|	AccumulatingDiscountResourcesBalances.ResourceClosingBalance AS Ресурс,
		|	AccumulatingDiscountResourcesBalances.BonusClosingBalance AS Бонус,
		|	AccumulatingDiscountResourcesBalances.BonusReceipt AS BonusReceipt
		|FROM
		|	AccumulationRegister.НакопитСкидки.BalanceAndTurnovers(
		|			,
		|			&qDateTo,
		|			Period,
		|			RegisterRecordsAndPeriodBoundaries,
		|			ТипСкидки = &qDiscountType
		|				AND (ИзмерениеСкидки = &qCustomer
		|						AND &qCustomerIsFilled
		|					OR ИзмерениеСкидки = &qContract
		|						AND &qContractIsFilled
		|					OR ИзмерениеСкидки = &qClient
		|						AND &qClientIsFilled
		|					OR ИзмерениеСкидки = &qDiscountCard
		|						AND &qDiscountCardIsFilled)
		|				AND (ГруппаГостей = &qGuestGroup
		|					OR &qGuestGroupIsEmpty)) AS AccumulatingDiscountResourcesBalances";
	Else
		qAccDisRes.Text = 
		"SELECT
		|	AccumulatingDiscountResourcesTurnovers.ТипСкидки,
		|	AccumulatingDiscountResourcesTurnovers.ИзмерениеСкидки,
		|	AccumulatingDiscountResourcesTurnovers.ResourceTurnover AS Ресурс,
		|	AccumulatingDiscountResourcesTurnovers.BonusTurnover AS Бонус,
		|	AccumulatingDiscountResourcesTurnovers.BonusReceipt AS BonusReceipt
		|FROM
		|	AccumulationRegister.НакопитСкидки.Turnovers(
		|			&qDateFrom,
		|			&qDateTo,
		|			Period,
		|			ТипСкидки = &qDiscountType
		|				AND (ИзмерениеСкидки = &qCustomer
		|						AND &qCustomerIsFilled
		|					OR ИзмерениеСкидки = &qContract
		|						AND &qContractIsFilled
		|					OR ИзмерениеСкидки = &qClient
		|						AND &qClientIsFilled
		|					OR ИзмерениеСкидки = &qDiscountCard
		|						AND &qDiscountCardIsFilled)
		|				AND (ГруппаГостей = &qGuestGroup
		|					OR &qGuestGroupIsEmpty)) AS AccumulatingDiscountResourcesTurnovers";
		If ЗначениеЗаполнено(AccumulatingDiscountFromDate) Тогда
			vDateFrom = BegOfDay(AccumulatingDiscountFromDate);
		Else
			vDateFrom = BegOfDay(vDateTo - AccumulatingDiscountPeriod*24*3600);
		Endif;
		qAccDisRes.SetParameter("qDateFrom", vDateFrom);
	EndIf;
	qAccDisRes.SetParameter("qDateTo", New Boundary(vDateTo, BoundaryType.Excluding));
	qAccDisRes.SetParameter("qDiscountType", Ref);
	qAccDisRes.SetParameter("qCustomer", pCustomer);
	qAccDisRes.SetParameter("qCustomerIsFilled", ЗначениеЗаполнено(pCustomer));
	qAccDisRes.SetParameter("qContract", pContract);
	qAccDisRes.SetParameter("qContractIsFilled", ЗначениеЗаполнено(pContract));
	qAccDisRes.SetParameter("qClient", pClient);
	qAccDisRes.SetParameter("qClientIsFilled", ЗначениеЗаполнено(pClient));
	qAccDisRes.SetParameter("qDiscountCard", pDiscountCard);
	qAccDisRes.SetParameter("qDiscountCardIsFilled", ЗначениеЗаполнено(pDiscountCard));
	qAccDisRes.SetParameter("qGuestGroup", pGuestGroup);
	qAccDisRes.SetParameter("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(pGuestGroup));
	vAccDisRes = qAccDisRes.Execute().Unload();
	// Return
	Return vAccDisRes;
EndFunction //pmGetAccumulatingDiscountResources

//-----------------------------------------------------------------------------
// Calculates default accumulating discount dimension based
// Returns discount dimension
//-----------------------------------------------------------------------------
Function pmGetDefaultAccumulatingDiscountDimension() Экспорт
	vDiscountDimension = Неопределено;
	If ЗначениеЗаполнено(AccumulatingDiscountDimension) Тогда
		If AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Клиент Тогда
			vDiscountDimension = Справочники.Клиенты.EmptyRef();
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Контрагент Тогда
			vDiscountDimension = Справочники.Контрагенты.EmptyRef();
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Договор Тогда
			vDiscountDimension = Справочники.Договора.EmptyRef();
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Агент Тогда
			vDiscountDimension = Справочники.Контрагенты.EmptyRef();
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.ДисконтКарт Тогда
			vDiscountDimension = Справочники.ДисконтныеКарты.EmptyRef();
		EndIf;
	EndIf;
	Return vDiscountDimension;
EndFunction //pmGetDefaultAccumulatingDiscountDimension

//-----------------------------------------------------------------------------
// Calculates accumulating discount resource value based on given service and document
// pSrvRec - could be any charge document or services table part record
// Returns resource value for given service.
//-----------------------------------------------------------------------------
Function pmCalculateResource(pSrvRec, pNumberOfPersons, pFolio, pDiscountCard = Неопределено, rDiscountDimension = Неопределено, pIsResourceReservation = False) Экспорт
	vRes = 0;
	rDiscountDimension = Неопределено;
	vFolio = pFolio;
	vNumberOfPersons = ?(pNumberOfPersons > 0, pNumberOfPersons, 1);
	If ЗначениеЗаполнено(AccumulatingDiscountDimension) Тогда
		If AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Клиент Тогда
			If ЗначениеЗаполнено(vFolio.Клиент) Тогда
				rDiscountDimension = vFolio.Клиент;
			Else
				rDiscountDimension = Справочники.Клиенты.EmptyRef();
			EndIf;
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Контрагент Тогда
			If НЕ ЗначениеЗаполнено(vFolio.Контрагент) Тогда
				Return 0;
			Else
				rDiscountDimension = vFolio.Контрагент;
			EndIf;
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Договор Тогда
			If НЕ ЗначениеЗаполнено(vFolio.Договор) Тогда
				Return 0;
			Else
				rDiscountDimension = vFolio.Договор;
			EndIf;
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Агент Тогда
			If НЕ ЗначениеЗаполнено(vFolio.Агент) Тогда
				Return 0;
			Else
				rDiscountDimension = vFolio.Агент;
			EndIf;
		ElsIf AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.ДисконтКарт Тогда
			If НЕ ЗначениеЗаполнено(pDiscountCard) Тогда
				Return 0;
			Else
				rDiscountDimension = pDiscountCard;
			EndIf;
		EndIf;
	Else
		Return 0;
	EndIf;
	If AccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.ByAccommodationDuration Тогда
		If НЕ pIsResourceReservation Тогда
			If pSrvRec.IsRoomRevenue Тогда
				If pSrvRec.ПроданоНомеров <> 0 Or pSrvRec.ПроданоМест <> 0 Тогда
					vRes = pSrvRec.ЧеловекаДни/vNumberOfPersons;
				EndIf;
			EndIf;
		EndIf;
	ElsIf AccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.ByNumberOfGuestVisits Тогда
		If НЕ pIsResourceReservation Тогда
			If pSrvRec.IsRoomRevenue Тогда
				If pSrvRec.ПроданоНомеров <> 0 Or pSrvRec.ПроданоМест <> 0 Тогда
					vRes = pSrvRec.ЗаездГостей/vNumberOfPersons;
				EndIf;
			EndIf;
		EndIf;
	ElsIf AccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.ByServicesTotalSum Тогда
		vRes = pSrvRec.Сумма - pSrvRec.СуммаСкидки;
	ElsIf AccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.ByServiceQuantity Тогда
		vRes = pSrvRec.Количество;
	ElsIf AccumulatingDiscountType = Перечисления.AccumulatingDiscountTypes.External Тогда
		Execute(TrimR(ExternalAlgorithm.Algorithm));
	EndIf;
	Return vRes;
EndFunction //pmCalculateResource

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	DateValidFrom = '00010101';
КонецПроцедуры //pmFillAttributesWithDefaultValues