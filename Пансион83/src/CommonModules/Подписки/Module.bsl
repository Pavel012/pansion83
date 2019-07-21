//-----------------------------------------------------------------------------
// Description: Checks hotel edit prohibition date for the documents
// Parameters: Document object, True if document couldn't be changed,
//             False if change is permitted
// Return value: None
//-----------------------------------------------------------------------------
Процедура HotelDocumentsCheckEditProhibitedDate(pSource, pCancel) Экспорт
	// Check hotel edit prohibited date and cancel operation if necessary
	If ЗначениеЗаполнено(pSource.Гостиница) Тогда
		If ЗначениеЗаполнено(pSource.Гостиница.EditProhibitedDate) Тогда
			If TypeOf(pSource) = Type("ДокументОбъект.Размещение") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаВыезда) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Бронирование") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаВыезда) Тогда
					pCancel = True;
				EndIf;
			
			ElsIf TypeOf(pSource) = Type("DocumentObject.БроньУслуг") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.DateTimeTo) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.СчетПроживания") Тогда
				If ЗначениеЗаполнено(pSource.DateTimeTo) And BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.DateTimeTo) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.БлокНомер") Тогда
				If ЗначениеЗаполнено(pSource.ДатаКонКвоты) And BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаКонКвоты) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.СоставКвоты") Тогда
				If ЗначениеЗаполнено(pSource.ДатаКонКвоты) And BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаКонКвоты) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Начисление") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					If ЗначениеЗаполнено(pSource.ДокОснование) Тогда
						If TypeOf(pSource.ДокОснование) = Type("ДокументОбъект.Размещение") Тогда
							If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДокОснование.ДатаВыезда) Тогда
								pCancel = True;
							EndIf;
						ElsIf TypeOf(pSource.ДокОснование) = Type("DocumentObject.Бронирование") Тогда
							If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДокОснование.ДатаВыезда) Тогда
								pCancel = True;
							EndIf;
						ElsIf TypeOf(pSource.ДокОснование) = Type("DocumentObject.БроньУслуг") Тогда
							If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДокОснование.DateTimeTo) Тогда
								pCancel = True;
							EndIf;
						ElsIf TypeOf(pSource.ДокОснование) = Type("DocumentObject.СоставКвоты") Тогда
							If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДокОснование.ДатаКонКвоты) Тогда
								pCancel = True;
							EndIf;
						EndIf;
					Else
						pCancel = True;
					EndIf;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.ПеремещениеНачисления") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.ЗакрытиеПериода") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.РаспределениеАванса") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.ПлатежКонтрагента") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.ПеремещениеДепозита") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.ОперацииСотрудников") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.СчетНаОплату") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					If ЗначениеЗаполнено(pSource.ДокОснование) Тогда
						If TypeOf(pSource.ДокОснование) = Type("DocumentRef.Бронирование") Тогда
							If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДокОснование.ДатаВыезда) Тогда
								pCancel = True;
							EndIf;
						ElsIf TypeOf(pSource.ДокОснование) = Type("DocumentRef.БроньУслуг") Тогда
							If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДокОснование.DateTimeTo) Тогда
								pCancel = True;
							EndIf;
						ElsIf TypeOf(pSource.ДокОснование) = Type("ДокументСсылка.Размещение") Тогда
							If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДокОснование.ДатаВыезда) Тогда
								pCancel = True;
							EndIf;
						Else
							pCancel = True;
						EndIf;
					Else
						If ЗначениеЗаполнено(pSource.ГруппаГостей) Тогда
							vGroupDetails = pSource.ГруппаГостей.GetObject().pmGetGuestGroupParameters();
							If vGroupDetails.Count() > 0 Тогда
								pCancel = True;
								For Each vGroupDetailsRow In vGroupDetails Do
									If BegOfDay(pSource.Гостиница.EditProhibitedDate) < BegOfDay(vGroupDetailsRow.DateTimeTo) Тогда
										pCancel = False;
										Break;
									EndIf;
								EndDo;
							Else
								pCancel = True;
							EndIf;
						Else
							pCancel = True;
						EndIf;
					EndIf;
				EndIf;
			
			ElsIf TypeOf(pSource) = Type("DocumentObject.ПланРабот") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Платеж") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
						ElsIf TypeOf(pSource) = Type("DocumentObject.УслугаВНомер") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Возврат") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Акт") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Сторно") Тогда
				If BegOfDay(pSource.Гостиница.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //HotelDocumentsCheckEditProhibitedDate

//-----------------------------------------------------------------------------
// Description: Checks Фирма edit prohibition date for the documents
// Parameters: Document object, True if document couldn't be changed,
//             False if change is permitted
// Return value: None
//-----------------------------------------------------------------------------
Процедура CompanyDocumentsCheckEditProhibitedDate(pSource, pCancel) Экспорт
	// Check Фирма edit prohibited date and cancel operation if necessary
	If ЗначениеЗаполнено(pSource.Фирма) Тогда
		If ЗначениеЗаполнено(pSource.Фирма.EditProhibitedDate) Тогда
			
			ElsIf TypeOf(pSource) = Type("DocumentObject.ЗакрытиеПериода") Тогда
				If BegOfDay(pSource.Фирма.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.РаспределениеАванса") Тогда
				If BegOfDay(pSource.Фирма.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.ПлатежКонтрагента") Тогда
				If BegOfDay(pSource.Фирма.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Платеж") Тогда
				If BegOfDay(pSource.Фирма.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Возврат") Тогда
				If BegOfDay(pSource.Фирма.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.СчетНаОплату") Тогда
				If BegOfDay(pSource.Фирма.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			ElsIf TypeOf(pSource) = Type("DocumentObject.Акт") Тогда
				If BegOfDay(pSource.Фирма.EditProhibitedDate) >= BegOfDay(pSource.ДатаДок) Тогда
					pCancel = True;
				EndIf;
			EndIf;
		EndIf;
КонецПроцедуры //CompanyDocumentsCheckEditProhibitedDate

//-----------------------------------------------------------------------------
// Description: Documents before write event processing routine
// Parameters: Document object, True if document couldn't be changed,
//             False if change is permitted, Document write mode, Document
//             posting mode
// Return value: None
//-----------------------------------------------------------------------------
Процедура HotelDocumentsBeforeWriteEventsBeforeWrite(pSource, pCancel, pWriteMode, pPostingMode) Экспорт
	If pSource.DataExchange.Load Тогда
		Return;
	EndIf;
	// Check hotel edit prohibited date and cancel operation if necessary
	HotelDocumentsCheckEditProhibitedDate(pSource, pCancel);
	// Check result
	If pCancel Тогда
		Message("Изменение документа запрещено, т.к. у гостиницы установлена дата запрета редактирования!", MessageStatus.Important);
	EndIf;
КонецПроцедуры //HotelDocumentsBeforeWriteEventsBeforeWrite

//-----------------------------------------------------------------------------
// Description: Documents before delete event processing routine
// Parameters: Document object, True if document couldn't be deleted,
//             False if deletion is permitted
// Return value: None
//-----------------------------------------------------------------------------
Процедура HotelDocumentsBeforeDeleteEventsBeforeDelete(pSource, pCancel) Экспорт
	If pSource.DataExchange.Load Тогда
		Return;
	EndIf;
	// Check hotel edit prohibited date and cancel operation if necessary
	HotelDocumentsCheckEditProhibitedDate(pSource, pCancel);
	// Check result
	If pCancel Тогда
		Message("Удаление документа запрещено, т.к. у гостиницы установлена дата запрета редактирования!", MessageStatus.Important);
	EndIf;
КонецПроцедуры //HotelDocumentsBeforeDeleteEventsBeforeDelete

//-----------------------------------------------------------------------------
// Description: Фирма documents before write event processing routine
// Parameters: Document object, True if document couldn't be changed,
//             False if change is permitted, Document write mode, Document
//             posting mode
// Return value: None
//-----------------------------------------------------------------------------
Процедура CompanyDocumentsBeforeWriteEventsBeforeWrite(pSource, pCancel, pWriteMode, pPostingMode) Экспорт
	If pSource.DataExchange.Load Тогда
		Return;
	EndIf;
	// Check Фирма edit prohibited date and cancel operation if necessary
	CompanyDocumentsCheckEditProhibitedDate(pSource, pCancel);
	// Check result
	If pCancel Тогда
		Message(NStr("en='Document could not be edited because of edit prohibited date set for the Фирма!';ru='Изменение документа запрещено, т.к. у фирмы установлена дата запрета редактирования!';de='Die Änderung des Dokuments ist verboten, da in der Firma das Datum für das Redaktionsverbot festgelegt wurde!'"), MessageStatus.Important);
	EndIf;
КонецПроцедуры //CompanyDocumentsBeforeWriteEventsBeforeWrite

//-----------------------------------------------------------------------------
// Description: Фирма documents before delete event processing routine
// Parameters: Document object, True if document couldn't be deleted,
//             False if deletion is permitted
// Return value: None
//-----------------------------------------------------------------------------
Процедура CompanyDocumentsBeforeDeleteEventsBeforeDelete(pSource, pCancel) Экспорт
	If pSource.DataExchange.Load Тогда
		Return;
	EndIf;
	// Check Фирма edit prohibited date and cancel operation if necessary
	CompanyDocumentsCheckEditProhibitedDate(pSource, pCancel);
	// Check result
	If pCancel Тогда
		Message("Удаление документа запрещено, т.к. у фирмы установлена дата запрета редактирования!", MessageStatus.Important);
	EndIf;
КонецПроцедуры //CompanyDocumentsBeforeDeleteEventsBeforeDelete
