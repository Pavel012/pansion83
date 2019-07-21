//-----------------------------------------------------------------------------
Function pmGetAccommodationTypeDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Description);
	//Else
	//	If IsBlankString(DescriptionTranslations) Тогда
	//		vDescr = СокрЛП(Description);
	//	Else
	//		vDescr = СокрЛП(DescriptionTranslations);
	//	EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetAccommodationTypeDescription

//-----------------------------------------------------------------------------
Function pmCheckAccommodationTypeAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	// Create query object	
	vQuery = New Query();		
	vQuery.Text = "SELECT
	|	ВидыРазмещений.ПорядокСортировки AS СчетчикДокКвота
	|FROM
	|	Catalog.ВидыРазмещения AS ВидыРазмещений
	|WHERE
	|	ВидыРазмещений.Ref <> &qRef
	|	AND ВидыРазмещений.ПорядокСортировки = &qSortCode";
	vQuery.SetParameter("qRef", Ref);
	vQuery.SetParameter("qSortCode", ПорядокСортировки);
	vQryRes = vQuery.Execute().Unload();
	If vQryRes.Count() > 0 Тогда
		vHasErrors = True; 
        vMsgTextRu = vMsgTextRu + "Реквизит <Порядок сортировки> не уникален! Укажите другой код." + Chars.LF;
        
        pAttributeInErr = "ПорядокСортировки";
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckAccommodationTypeAttributes

//-----------------------------------------------------------------------------
Function pmSetSortCode() Экспорт
	vSortCode = 0;
	vQuery = New Query;
	vQuery.Text = 
	"SELECT
	|	MAX(ВидыРазмещения.ПорядокСортировки) AS ПорядокСортировки
	|FROM
	|	Catalog.ВидыРазмещения AS ВидыРазмещений";
	vQueryResult = vQuery.Execute().Unload();
	If vQueryResult.Count() > 0 Тогда

		
			vSortCode = 10;
	
	EndIf;
	Return vSortCode;
EndFunction //pmSetSortCode
