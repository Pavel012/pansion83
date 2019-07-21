//-----------------------------------------------------------------------------
// Description: Returns list of accumulation discount types
// Parameters: Discount type to return in value table
// Return value: Value table with accumulating discount types
//-----------------------------------------------------------------------------
Function cmGetAccumulatingDiscountTypes(pDiscountType = Неопределено) Экспорт
	Return СохранениеНастроек.cmGetAccumulatingDiscountTypesTable(pDiscountType);
EndFunction //cmGetAccumulatingDiscountTypes

//-----------------------------------------------------------------------------
// Description: Returns list of bonus discount types
// Parameters: Discount type to return in value table
// Return value: Value table with bonus discount types
//-----------------------------------------------------------------------------
Function cmGetBonusDiscountTypes(pDiscountType = Неопределено) Экспорт
	// Build and run query
	qAccDisTypes = New Query;
	qAccDisTypes.Text = 
	"SELECT
	|	DiscountTypes.Ref AS ТипСкидки,
	|	DiscountTypes.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.ТипыСкидок AS DiscountTypes
	|WHERE
	|	(NOT DiscountTypes.DeletionMark)
	|	AND DiscountTypes.IsAccumulatingDiscount
	|	AND DiscountTypes.BonusCalculationFactor <> 0
	|	AND (&qDiscountTypeIsEmpty
	|			OR NOT &qDiscountTypeIsEmpty
	|				AND DiscountTypes.Ref = &qDiscountType)
	|
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
EndFunction //cmGetBonusDiscountTypes

//-----------------------------------------------------------------------------
// Description: Checks if first discount is greater then second one
// Parameters: First discount percent, Second discount percent
// Return value: True if greater, False if not
//-----------------------------------------------------------------------------
Function cmFirstDiscountIsGreater(pFirstDiscount, pSecondDiscount) Экспорт
	If pFirstDiscount > pSecondDiscount Тогда
		Return True;
	Else
		Return False;
	EndIf;
EndFunction //cmFirstDiscountIsGreater

//-----------------------------------------------------------------------------
// Description: Returns discount dimension type description
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Function cmGetDiscountDimensionTypeDescription() Экспорт
	vTA = New Array;
	vTA.Add(Type("CatalogRef.Контрагенты"));
	vTA.Add(Type("CatalogRef.Договора"));
	vTA.Add(Type("CatalogRef.Клиенты"));
	vTA.Add(Type("CatalogRef.ДисконтныеКарты"));
	vTypeDescr = New TypeDescription(vTA);
	Return vTypeDescr;
EndFunction //cmGetDiscountDimensionTypeDescription

//-----------------------------------------------------------------------------
// Description: Returns accumulating discount resource type description
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------
Function cmGetAccumulatingDiscountResourceTypeDescription() Экспорт
	vNQ = New NumberQualifiers(19, 7);
	vTA = New Array;
	vTA.Add(Type("Number"));
	vTypeDescr = New TypeDescription(vTA, , vNQ);
	Return vTypeDescr;
EndFunction //cmGetAccumulatingDiscountResourceTypeDescription

//-----------------------------------------------------------------------------
// Description: Function tries to find and return discount card by card identifier
// Parameters: Card identifier
// Return value: Discount card reference or empty reference
//-----------------------------------------------------------------------------
Function cmGetDiscountCardById(pIdentifier, pSearchMarkedForDeletion = False) Экспорт
	vDiscountCardRef = Справочники.ДисконтныеКарты.EmptyRef();
	// Try to find discount card by identifier
	vQry =  New Query();
	vQry.Text = 
	"SELECT
	|	ДисконтныеКарты.Ref
	|FROM
	|	Catalog.ДисконтныеКарты AS DiscountCards
	|WHERE
	|	(NOT ДисконтныеКарты.DeletionMark OR &qSearchMarkedForDeletion)
	|	AND ДисконтныеКарты.Identifier = &qIdentifier
	|
	|ORDER BY
	|	ДисконтныеКарты.Code";
	vQry.SetParameter("qIdentifier", СокрЛП(pIdentifier));
	vQry.SetParameter("qSearchMarkedForDeletion", pSearchMarkedForDeletion);
	vDiscountCards = vQry.Execute().Unload();
	If vDiscountCards.Count() > 0 Тогда
		vDiscountCardRef = vDiscountCards.Get(0).Ref;
	EndIf;
	Return vDiscountCardRef;
EndFunction //cmGetDiscountCardById

//-----------------------------------------------------------------------------
// Description: Function tries to find and return discount card for the client
// Parameters: Client ref
// Return value: Discount card reference or empty reference
//-----------------------------------------------------------------------------
Function cmGetDiscountCardByClient(pClient) Экспорт
	vDiscountCardRef = Справочники.ДисконтныеКарты.EmptyRef();
	// Try to find discount card by client
	vQry =  New Query();
	vQry.Text = 
	"SELECT
	|	DiscountCards.Ref
	|FROM
	|	Catalog.ДисконтныеКарты AS DiscountCards
	|WHERE
	|	NOT DiscountCards.DeletionMark
	|	AND DiscountCards.Клиент = &qClient
	|	AND NOT ISNULL(DiscountCards.ТипСкидки.IsManualDiscount, FALSE)
	|
	|ORDER BY
	|	DiscountCards.Code DESC";
	vQry.SetParameter("qClient", pClient);
	vDiscountCards = vQry.Execute().Unload();
	If vDiscountCards.Count() > 0 Тогда
		vDiscountCardRef = vDiscountCards.Get(0).Ref;
	EndIf;
	Return vDiscountCardRef;
EndFunction //cmGetDiscountCardById

//-----------------------------------------------------------------------------
// Description: Rounds amount according to the number of decimal digits and type
//              pRoundDigits = -1: 24 -> 30; 29 -> 30; -33 -> -30; -37 -> -30
//              pRoundDigits =  1: 2.43 -> 2.50; 2.49 -> 2.50; -3.33 -> -3.30; -3.37 -> -3.30
//-----------------------------------------------------------------------------
Function cmRoundDiscountAmount(pAmount, pRoundDigits, pRoundType = Неопределено) Экспорт
	vAmount = pAmount;
	If НЕ ЗначениеЗаполнено(pRoundType) Тогда
		vAmount = cmRoundUp(pAmount, pRoundDigits);
	Else
		If pRoundType = Перечисления.DiscountAmountRoundTypes.Up Тогда
			vAmount = cmRoundUp(pAmount, pRoundDigits);
		ElsIf pRoundType = Перечисления.DiscountAmountRoundTypes.Down Тогда
			vAmount = cmRoundDown(pAmount, pRoundDigits);
		Else
			vAmount = Round(pAmount, pRoundDigits);
		EndIf;
	EndIf;
	Return vAmount;
EndFunction //cmRoundDiscountAmount
