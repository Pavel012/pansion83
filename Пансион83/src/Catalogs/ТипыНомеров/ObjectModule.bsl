////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Current hotel
//	If НЕ ЗначениеЗаполнено(Owner) Тогда
//		Owner = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues

////-----------------------------------------------------------------------------
//Function pmCheckRoomTypeAttributes(pMessage, pAttributeInErr) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//	vMsgTextEn = "";
//	vMsgTextDe = "";
//	If НЕ ЗначениеЗаполнено(Owner) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Owner", pAttributeInErr);
//	EndIf;
//	If IsBlankString(Code) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Код> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Code> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Code", pAttributeInErr);
//	EndIf;
//	If IsBlankString(Description) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Наименование> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Description> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Description", pAttributeInErr);
//	EndIf;
//	If SortCode <> 0 Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	COUNT(*) AS СчетчикДокКвота
//		|FROM
//		|	Catalog.ТипыНомеров AS ТипыНомеров
//		|WHERE
//		|	ТипыНомеров.ПорядокСортировки = &qSortCode
//		|	AND ТипыНомеров.Ref <> &qRef";
//		vQry.SetParameter("qSortCode", SortCode);		
//		vQry.SetParameter("qRef", Ref);
//		vQryRes = vQry.Execute().Unload();
//		If vQryRes.Count() > 0 Тогда
//			vRow = vQryRes.Get(0);
//			If vRow.СчетчикДокКвота > 0 Тогда 
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Реквизит <Порядок сортировки> не уникален! Укажите другой код." + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "<Sort code> attribute is not unique! Please, enter another code." + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "<Sort code> Attribut ist nicht einzigartig! Bitte geben Sie einen anderen Code." + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "ПорядокСортировки", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ IsVirtual And НЕ IsFolder Тогда
//		If NumberOfBedsPerRoom = 0 Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Реквизит <Количество мест в номере> должен быть заполнен!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<Number of beds per НомерРазмещения> attribute should be filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "КоличествоМестНомер", pAttributeInErr);
//		EndIf;
//		If NumberOfPersonsPerRoom = 0 Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Реквизит <Максимальное количество гостей в номере> должен быть заполнен!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<Number of persons per НомерРазмещения> attribute should be filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "КоличествоГостейНомер", pAttributeInErr);
//		EndIf;	
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckRoomTypeAttributes

////-----------------------------------------------------------------------------
//Function pmGetRoomTypeDescription(pLang) Экспорт
//	vDescr = "";
//	If НЕ ЗначениеЗаполнено(pLang) Тогда
//		vDescr = СокрЛП(Description);
//	Else
//		If IsBlankString(DescriptionTranslations) Тогда
//			vDescr = СокрЛП(Description);
//		Else
//			vDescr = СокрЛП(DescriptionTranslations);
//		EndIf;
//	EndIf;
//	Return vDescr;
//EndFunction //pmGetRoomTypeDescription

////-----------------------------------------------------------------------------
//Процедура BeforeWrite(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If НЕ IsFolder Тогда
//		If Left(СокрЛП(Description), StrLen(СокрЛП(Code))) <> СокрЛП(Code) Тогда
//			Description = СокрЛП(Code) + ?(IsBlankString(Description), "", " - " + СокрЛП(Description));
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
