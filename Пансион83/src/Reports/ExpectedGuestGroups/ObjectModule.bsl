//Перем EventBackColor;
//
////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes
//
////-----------------------------------------------------------------------------
//// Initialize attributes with default values
//// Attention: This procedure could be called AFTER some attributes initialization
//// routine, so it SHOULD NOT reset attributes being set before
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill parameters with default values
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = BegOfDay(CurrentDate()); // For today
//		PeriodTo = EndOfDay(PeriodFrom);
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetReportParametersPresentation() Экспорт
//	vParamPresentation = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ Гостиница.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Гостиница ';ru='Гостиница ';de='Гостиница'") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Hotels folder ';ru='Группа гостиниц ';de='Gruppe Hotels '") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom = PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If НЕ Контрагент.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("de='Firma';en='Контрагент ';ru='Контрагент '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("de='Gruppe Firmen';en='Customers folder ';ru='Группа контрагентов '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guest group ';ru='Группа ';de='Gruppe '") + 
//							 TrimAll(GuestGroup.Code) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(RoomType) Тогда
//		If НЕ RoomType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров type ';ru='Тип номера ';de='Zimmertyp'") + 
//			                     TrimAll(RoomType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров types folder ';ru='Группа типов номеров ';de='Gruppe Zimmertypen'") + 
//			                     TrimAll(RoomType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(RoomQuota) Тогда
//		If НЕ RoomQuota.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Allotment ';ru='Квота ';de='Quote '") + 
//			                     TrimAll(RoomQuota.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Allotements folder ';ru='Группа квот ';de='Gruppe Quoten '") + 
//			                     TrimAll(RoomQuota.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ReservationStatus) Тогда
//		If НЕ ReservationStatus.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Статус брони '; en = 'Reservation status '") + 
//			                     TrimAll(ReservationStatus.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа статусов брони '; en = 'Reservation statuses folder '") + 
//			                     TrimAll(ReservationStatus.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Manager) Тогда
//		If НЕ Manager.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Менеджер групп '; en = 'Group manager '") + 
//			                     TrimAll(Manager.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа менеджеров '; en = 'Group manager folder '") + 
//			                     TrimAll(Manager.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation
//
////-----------------------------------------------------------------------------
//// Runs report
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet) Экспорт
//	
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//	
//	// Initialize report builder query generator attributes
//	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
//	
//	// Fill report parameters
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qReservationStatus", ReservationStatus);
//	ReportBuilder.Parameters.Вставить("qReservationStatusIsEmpty", НЕ ЗначениеЗаполнено(ReservationStatus));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qRoomQuota", RoomQuota);
//	ReportBuilder.Parameters.Вставить("qRoomQuotaIsEmpty", НЕ ЗначениеЗаполнено(RoomQuota));
//	ReportBuilder.Parameters.Вставить("qManager", Manager);
//	ReportBuilder.Parameters.Вставить("qManagerIsEmpty", НЕ ЗначениеЗаполнено(Manager));
//	
//	// Always do not show totals
//	ReportBuilder.PutOveralls = False;
//
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Output report to the spreadsheet
//	ReportBuilder.Put(pSpreadsheet);
//	//ReportBuilder.Template.Show(); // For debug purpose
//
//	// Apply appearance settings to the report spreadsheet
//	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
//	
//	// Get row where to place events
//	vResourcesCount = 0;
//	For Each vFld In ReportBuilder.SelectedFields Do
//		If pmIsResource(vFld.Name) Тогда
//			vResourcesCount = vResourcesCount + 1;
//		EndIf;
//	EndDo;
//	//vEvents = cmGetEvents(PeriodFrom, PeriodTo, Гостиница);
//	
//	h = 5;
//	If vResourcesCount > 1 Тогда
//		h = h + 1;
//	EndIf;
//	//If vEvents.Count() > 0 Тогда
//	//	h = h + 1;
//	//EndIf;
//	
//	// Try to find first date range searching for the date format string
//	i = 1;
//	While i < pSpreadsheet.TableWidth Do
//		vDateArea = pSpreadsheet.Area(4, i, 4, i);
//		If НЕ IsBlankString(vDateArea.Format) Тогда
//			w = i;
//			Break;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	
//	// Get events and modify report with events
//	w = 0;
//	If PeriodFrom > '19000101' And PeriodTo < '30000101' And 
//	   pSpreadsheet.TableHeight > h Тогда
//		// Copy this row and update it
//		//If vEvents.Count() > 0 Тогда
//		//	vSourceRowArea = pSpreadsheet.Area(h - 1, , h - 1, );
//		//	vTargetRowArea = pSpreadsheet.Area(h - 1, , h - 1, );
//		//	pSpreadsheet.InsertArea(vSourceRowArea, vTargetRowArea, SpreadsheetDocumentShiftType.Vertical, True);
//		//	vTargetRowArea = pSpreadsheet.Area(h - 1, , h - 1, );
//		//	vTargetRowArea.Clear(True, True);
//		//	// Add events name
//		//	vEventsNameArea = pSpreadsheet.Area(h - 1, 2, h - 1, 2);
//		//	vEventsNameArea.Text = NStr("en='Events';ru='Мероприятия';de='Veranstaltungen'");
//		//	vEventsNameArea.Font = vDateArea.Font;
//		//EndIf;			
//		// Do for each date from the report period
////		vEventsRow = Неопределено;
////		vCommentIsPlaced = False;
//		vCurDate = BegOfDay(PeriodFrom);
//		vEndDate = BegOfDay(PeriodTo);
//		p = 1;
//		//If vEvents.Count() > 0 Тогда
//		//	p = 2;
//		//EndIf;
//		While vCurDate <= vEndDate Do
//			// Clear resource name
//			If vResourcesCount > 1 Тогда
//				vDayResourceArea = pSpreadsheet.Area(h - p, i, h - p, i);
//				vDayResourceArea.Text = " ";
//			EndIf;
//			If vCurDate = vEndDate Тогда
//				vDayDateArea = Неопределено;
//				If vResourcesCount > 1 Тогда
//					vDayDateArea = pSpreadsheet.Area(h - p - 1, i, h - p - 1, i + vResourcesCount - 1);
//				Else
//					vDayDateArea = pSpreadsheet.Area(h - p, i, h - p, i + vResourcesCount - 1);
//				EndIf;
//				If vDayDateArea <> Неопределено Тогда
//					vDayDateArea.UndoMerge();
//					If vResourcesCount > 1 Тогда
//						vDayDateArea = pSpreadsheet.Area(h - p - 1, i, h - p - 1, i);
//					Else
//						vDayDateArea = pSpreadsheet.Area(h - p, i, h - p, i);
//					EndIf;
//					If vDayDateArea <> Неопределено Тогда
//						vDayDateArea.TextPlacement = SpreadsheetDocumentTextPlacementType.Wrap;
//						vDayDateArea.BySelectedColumns = False;
//						vDayDateArea.RightBorder = New Line(SpreadsheetDocumentCellLineType.Solid, 1);
//					EndIf;
//					For k = 2 To vResourcesCount Do
//						vDayResourceNameArea = pSpreadsheet.Area(h - p - 1, i + k - 1, h - p - 1, i + k - 1);
//						vDayResourceArea = pSpreadsheet.Area(h - p, i + k - 1, h - p, i + k - 1);
//						
//						vDayResourceNameArea.Text = vDayResourceArea.Text;
//						vDayResourceNameArea.TextPlacement = vDayResourceArea.TextPlacement;
//						vDayResourceNameArea.BySelectedColumns = vDayResourceArea.BySelectedColumns;
//						vDayResourceNameArea.RightBorder = vDayResourceArea.RightBorder;
//						
//						vDayResourceArea.Text = " ";
//					EndDo;
//					If vResourcesCount > 1 Тогда
//						vResorcesRowArea = pSpreadsheet.Area(h - p, , h - p, );
//						vResorcesRowArea.AutoRowHeight = False;
//						vResorcesRowArea.RowHeight = 1;
//					EndIf;
//				EndIf;
//			EndIf;
//			//If vEvents.Count() > 0 Тогда
//			//	vEventArea = pSpreadsheet.Area(h - 1, i, h - 1, i);
//			//	// Try to find event starting from this date
//			//	vThisIsFirstPeriodOfEvent = False;
//			//	vProbeEventsRow = vEvents.Find(vCurDate, "DateFrom");
//			//	If vProbeEventsRow <> Неопределено Тогда
//			//		If vEventsRow = Неопределено Тогда
//			//			vEventsRow = vProbeEventsRow;
//			//			vThisIsFirstPeriodOfEvent = True;
//			//			vCommentIsPlaced = False;
//			//		Else
//			//			If vEventsRow <> vProbeEventsRow Тогда
//			//				vEventsRow = vProbeEventsRow;
//			//				vThisIsFirstPeriodOfEvent = True;
//			//				vCommentIsPlaced = False;
//			//			EndIf;
//			//		EndIf;
//			//	EndIf;
//			//	vIsEventDate = False;
//			//	If vEventsRow <> Неопределено Тогда
//			//		If vCurDate > vEventsRow.DateTo Or vCurDate < vEventsRow.DateFrom Тогда
//			//			vEventsRow = Неопределено;
//			//		Else
//			//			vIsEventDate = True;
//			//		EndIf;
//			//	EndIf;
//			//	If vEventsRow <> Неопределено And vIsEventDate Тогда
//			//		If vThisIsFirstPeriodOfEvent Тогда
//			//			vEventArea.Text = TrimAll(vEventsRow.Description);
//			//		Else
//			//			vEventArea.Text = "";
//			//		EndIf;
//			//		If vEventsRow.DateTo = BegOfDay(vCurDate) And НЕ vCommentIsPlaced Тогда
//			//			vCommentIsPlaced = True;
//			//			vEventArea.Comment.Text = Chars.LF + Chars.LF + TrimAll(Format(vEventsRow.DateFrom, "DF=dd.MM.yyyy") + " - " + Format(vEventsRow.DateTo, "DF=dd.MM.yyyy") + Chars.LF +
//			//									  TrimAll(vEventsRow.Remarks));
//			//		EndIf;
//			//		For j = 1 To vResourcesCount Do
//			//			vEventArea.Details = vEventsRow.Ref;
//			//			vEventArea.TextPlacement = SpreadsheetDocumentTextPlacementType.Auto;
//			//			vEventArea.BySelectedColumns = True;
//			//			vEventArea.HorizontalAlign = HorizontalAlign.Left;
//			//			vEventArea.VerticalAlign = VerticalAlign.Center;
//			//			vEventColor = Неопределено;
//			//			If vEventsRow.Color <> Неопределено Тогда
//			//				vEventColor = vEventsRow.Color.Get();
//			//			EndIf;
//			//			vEventBackColor = EventBackColor;
//			//			If vEventColor <> Неопределено Тогда
//			//				vEventBackColor = vEventColor;
//			//			EndIf;
//			//			vEventArea.BackColor = vEventBackColor;
//			//			vEventArea.RightBorder = New Line(SpreadsheetDocumentCellLineType.None, 1);
//			//			If НЕ vThisIsFirstPeriodOfEvent Or j > 1 Тогда
//			//				vEventArea.LeftBorder = New Line(SpreadsheetDocumentCellLineType.None, 1);
//			//				vEventArea.Clear(True);
//			//			EndIf;
//			//			// Next area
//			//			i = i + 1;
//			//			vEventArea = pSpreadsheet.Area(h - 1, i, h - 1, i);
//			//		EndDo;
//			//	ElsIf НЕ vIsEventDate Тогда
//			//		For j = 1 To vResourcesCount Do
//			//			vEventArea.Text = " ";
//			//			vEventArea.Details = Справочники.Events.EmptyRef();
//			//			// Next area
//			//			i = i + 1;
//			//			vEventArea = pSpreadsheet.Area(h - 1, i, h - 1, i);
//			//		EndDo;
//			//	Else
//			//		For j = 1 To vResourcesCount Do
//			//			// Next area
//			//			i = i + 1;
//			//		EndDo;
//			//	EndIf;
//			//Else
//			//	For j = 1 To vResourcesCount Do
//			//		// Next area
//			//		i = i + 1;
//			//	EndDo;
//			//EndIf;
//			vCurDate = vCurDate + 24*3600;
//		EndDo;
//	EndIf;
//	
//	// Remove doubled hotel vacant ГруппаНомеров totals
//	vGroupsCount = ReportBuilder.RowDimensions.Count();
//	If vGroupsCount > 1 Тогда
//		r1 = h + 1;
//		r2 = h + 1 + vGroupsCount - 2;
//		If r2 >= r1 And r2 <= pSpreadsheet.TableWidth Тогда
//			vAreaToDelete = pSpreadsheet.Area(r1, , r2, );
//			vAreaToDelete.Ungroup();
//			pSpreadsheet.DeleteArea(vAreaToDelete, SpreadsheetDocumentShiftType.Vertical);
//		EndIf;		
//	EndIf;
//	
//	// Lock first h rows
//	pSpreadsheet.FixedTop = h;
//	
//	// Add vacants name
//	If h < pSpreadsheet.TableWidth And vDateArea <> Неопределено Тогда
//		vVacantsNameArea = pSpreadsheet.Area(h, 2, h, 2);
//		vVacantsNameArea.FillType = SpreadsheetDocumentAreaFillType.Text;
//		vVacantsNameArea.Text = NStr("en='Vacant';ru='Свободно';de='frei'");
//		vVacantsNameArea.Font = vDateArea.Font;
//	EndIf;
//	
//	// Check if we have to change width of the totals columns
//	i = pSpreadsheet.TableWidth;
//	While i > 0 Do
//		vResourceTotalsArea = pSpreadsheet.Area(h, i, h, i);
//		If vResourceTotalsArea.ColumnWidth < 1 Тогда
//			vResourceTotalsArea.ColumnWidth = 12;
//		Else
//			Break;
//		EndIf;
//		i = i - 1;
//	EndDo;
//	
//	// Try to place average resources data from the hidden columns 
//	// to the total columns in the last report date
//	If vResourcesCount > 1 Тогда
//		vHiddenResources = New СписокЗначений();
//		For j = h To pSpreadsheet.TableHeight Do
//			vHiddenResources.Clear();
//			vHiddenColumnIndex = 0;
//			For i = w To pSpreadsheet.TableWidth Do
//				vResourceArea = pSpreadsheet.Area(j, i, j, i);
//				If vResourceArea.ColumnWidth < 1 Тогда
//					// This is hidden resource column
//					vHiddenColumnIndex = vHiddenColumnIndex + 1;
//					If vHiddenResources.Count() >= vHiddenColumnIndex Тогда 
//						vHiddenResourcesItem = vHiddenResources.Get(vHiddenColumnIndex - 1);
//						If ЗначениеЗаполнено(vHiddenResourcesItem.Value) Тогда
//							If vHiddenResourcesItem.Value < TrimAll(vResourceArea.Text) Тогда
//								vHiddenResourcesItem.Value = TrimAll(vResourceArea.Text);
//							EndIf;
//						Else
//							vHiddenResourcesItem.Value = TrimAll(vResourceArea.Text);
//						EndIf;
//					Else
//						vHiddenResources.Add(TrimAll(vResourceArea.Text));
//					EndIf;
//				Else
//					vHiddenColumnIndex = 0;
//				EndIf;
//				If vHiddenResources.Count() > 0 And 
//				   i > (pSpreadsheet.TableWidth - vHiddenResources.Count()) Тогда
//					vTotalsColumnIndex = i - pSpreadsheet.TableWidth + vHiddenResources.Count() - 1;
//					If vTotalsColumnIndex >= 0 Тогда
//						vHiddenResourcesItem = vHiddenResources.Get(vTotalsColumnIndex);
//						vResourceArea.Text = vHiddenResourcesItem.Value;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmGenerate
//
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	GuestGroupsForecast.Period AS Period,
//	|	GuestGroupsForecast.Гостиница AS Гостиница,
//	|	GuestGroupsForecast.ReservationStatus AS ReservationStatus,
//	|	GuestGroupsForecast.КвотаНомеров AS КвотаНомеров,
//	|	GuestGroupsForecast.ТипНомера AS ТипНомера,
//	|	GuestGroupsForecast.ГруппаГостей AS ГруппаГостей,
//	|	GuestGroupsForecast.ГруппаГостей.Контрагент AS Контрагент,
//	|	GuestGroupsForecast.ЗабронНомеров AS ЗабронНомеров,
//	|	GuestGroupsForecast.ЗабронированоМест AS ЗабронированоМест,
//	|	GuestGroupsForecast.ЗабронДопМест AS ЗабронДопМест,
//	|	GuestGroupsForecast.ЗабронГостей AS ЗабронГостей,
//	|	GuestGroupsForecast.Revenue AS Revenue,
//	|	GuestGroupsForecast.AveragePrice AS AveragePrice,
//	|	GuestGroupsForecast.MinimumPrice AS MinimumPrice,
//	|	GuestGroupsForecast.MaximumPrice AS MaximumPrice
//	|{SELECT
//	|	Гостиница.*,
//	|	КвотаНомеров.*,
//	|	ReservationStatus.*,
//	|	Контрагент.*,
//	|	ГруппаГостей.*,
//	|	ТипНомера.*,
//	|	Period,
//	|	ЗабронНомеров,
//	|	ЗабронированоМест,
//	|	ЗабронДопМест,
//	|	ЗабронГостей,
//	|	Revenue,
//	|	AveragePrice,
//	|	MinimumPrice,
//	|	MaximumPrice}
//	|FROM
//	|	(SELECT
//	|		PeriodDays.Period AS Period,
//	|		ExpectedGuestGroupsTurnovers.Гостиница AS Гостиница,
//	|		ExpectedGuestGroupsTurnovers.ReservationStatus AS ReservationStatus,
//	|		ExpectedGuestGroupsTurnovers.КвотаНомеров AS КвотаНомеров,
//	|		ExpectedGuestGroupsTurnovers.ТипНомера AS ТипНомера,
//	|		ExpectedGuestGroupsTurnovers.ГруппаГостей AS ГруппаГостей,
//	|		ExpectedGuestGroupsTurnovers.ГруппаГостей.Контрагент AS Контрагент,
//	|		ExpectedGuestGroupsTurnovers.RoomsReservedTurnover AS ЗабронНомеров,
//	|		ExpectedGuestGroupsTurnovers.BedsReservedTurnover AS ЗабронированоМест,
//	|		ExpectedGuestGroupsTurnovers.AdditionalBedsReservedTurnover AS ЗабронДопМест,
//	|		ExpectedGuestGroupsTurnovers.GuestsReservedTurnover AS ЗабронГостей,
//	|		GroupRevenue.Revenue AS Revenue,
//	|		GroupRevenue.AveragePrice AS AveragePrice,
//	|		GroupRevenue.MinimumPrice AS MinimumPrice,
//	|		GroupRevenue.MaximumPrice AS MaximumPrice,
//	|		0 AS Dummy
//	|	FROM
//	|		(SELECT
//	|			RoomInventoryTurnovers.Period AS Period,
//	|			RoomInventoryTurnovers.Гостиница AS Гостиница,
//	|			RoomInventoryTurnovers.CounterTurnover AS CounterTurnover
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					(Гостиница = &qHotel
//	|						OR &qHotelIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qRoomTypeIsEmpty)) AS RoomInventoryTurnovers) AS PeriodDays
//	|			LEFT JOIN AccumulationRegister.ПланируемыеГруппы.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					(Гостиница = &qHotel
//	|						OR &qHotelIsEmpty)
//	|						AND (ReservationStatus IN HIERARCHY (&qReservationStatus)
//	|							OR &qReservationStatusIsEmpty)
//	|						AND (ГруппаГостей.Автор IN HIERARCHY (&qManager)
//	|							OR &qManagerIsEmpty)
//	|						AND (КвотаНомеров IN HIERARCHY (&qRoomQuota)
//	|							OR &qRoomQuotaIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qRoomTypeIsEmpty)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qGuestGroupIsEmpty)
//	|						AND (ГруппаГостей.Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qCustomerIsEmpty)) AS ExpectedGuestGroupsTurnovers
//	|			ON PeriodDays.Period = ExpectedGuestGroupsTurnovers.Period
//	|				AND PeriodDays.Гостиница = ExpectedGuestGroupsTurnovers.Гостиница
//	|			LEFT JOIN (SELECT
//	|				GroupSalesTotals.Гостиница AS Гостиница,
//	|				GroupSalesTotals.ГруппаГостей AS ГруппаГостей,
//	|				GroupSalesTotals.КвотаНомеров AS КвотаНомеров,
//	|				GroupSalesTotals.ReservationStatus AS ReservationStatus,
//	|				GroupSalesTotals.ТипНомера AS ТипНомера,
//	|				GroupSalesTotals.TotalRevenue AS Revenue,
//	|				CASE
//	|					WHEN GroupSalesTotals.ГруппаГостей.Продолжительность <> 0
//	|						THEN CAST(GroupSalesTotals.TotalRevenue / GroupSalesTotals.ГруппаГостей.Продолжительность AS NUMBER(17, 2))
//	|					ELSE 0
//	|				END AS AveragePrice,
//	|				CASE
//	|					WHEN GroupSalesTotals.MinimumRevenue = 999999999999
//	|						THEN 0
//	|					ELSE GroupSalesTotals.MinimumRevenue
//	|				END AS MinimumPrice,
//	|				GroupSalesTotals.MaximumRevenue AS MaximumPrice
//	|			FROM
//	|				(SELECT
//	|					AccountsReceivableForecastTurnovers.Гостиница AS Гостиница,
//	|					AccountsReceivableForecastTurnovers.ГруппаГостей AS ГруппаГостей,
//	|					AccountsReceivableForecastTurnovers.ДокОснование.КвотаНомеров AS КвотаНомеров,
//	|					AccountsReceivableForecastTurnovers.ДокОснование.ReservationStatus AS ReservationStatus,
//	|					AccountsReceivableForecastTurnovers.ДокОснование.ТипНомера AS ТипНомера,
//	|					SUM(AccountsReceivableForecastTurnovers.ExpectedSalesTurnover - AccountsReceivableForecastTurnovers.ExpectedCommissionSumTurnover) AS TotalRevenue,
//	|					MIN(CASE
//	|							WHEN AccountsReceivableForecastTurnovers.ExpectedRoomRevenueTurnover <> 0
//	|								THEN AccountsReceivableForecastTurnovers.ExpectedSalesTurnover - AccountsReceivableForecastTurnovers.ExpectedCommissionSumTurnover
//	|							ELSE 999999999999
//	|						END) AS MinimumRevenue,
//	|					MAX(CASE
//	|							WHEN AccountsReceivableForecastTurnovers.ExpectedRoomRevenueTurnover <> 0
//	|								THEN AccountsReceivableForecastTurnovers.ExpectedSalesTurnover - AccountsReceivableForecastTurnovers.ExpectedCommissionSumTurnover
//	|							ELSE 0
//	|						END) AS MaximumRevenue
//	|				FROM
//	|					AccumulationRegister.ПрогнозРеализации.Turnovers(
//	|							&qPeriodFrom,
//	|							&qPeriodTo,
//	|							Day,
//	|							(Гостиница = &qHotel
//	|								OR &qHotelIsEmpty)
//	|								AND (ДокОснование.ReservationStatus IN HIERARCHY (&qReservationStatus)
//	|									OR &qReservationStatusIsEmpty)
//	|								AND (ГруппаГостей.Автор IN HIERARCHY (&qManager)
//	|									OR &qManagerIsEmpty)
//	|								AND (ДокОснование.КвотаНомеров IN HIERARCHY (&qRoomQuota)
//	|									OR &qRoomQuotaIsEmpty)
//	|								AND (ДокОснование.ТипНомера IN HIERARCHY (&qRoomType)
//	|									OR &qRoomTypeIsEmpty)
//	|								AND (ГруппаГостей = &qGuestGroup
//	|									OR &qGuestGroupIsEmpty)
//	|								AND (ГруппаГостей.Контрагент IN HIERARCHY (&qCustomer)
//	|									OR &qCustomerIsEmpty)) AS AccountsReceivableForecastTurnovers
//	|				
//	|				GROUP BY
//	|					AccountsReceivableForecastTurnovers.Гостиница,
//	|					AccountsReceivableForecastTurnovers.ГруппаГостей,
//	|					AccountsReceivableForecastTurnovers.ДокОснование.КвотаНомеров,
//	|					AccountsReceivableForecastTurnovers.ДокОснование.ReservationStatus,
//	|					AccountsReceivableForecastTurnovers.ДокОснование.ТипНомера) AS GroupSalesTotals) AS GroupRevenue
//	|			ON (GroupRevenue.ГруппаГостей = ExpectedGuestGroupsTurnovers.ГруппаГостей)
//	|				AND (GroupRevenue.Гостиница = ExpectedGuestGroupsTurnovers.Гостиница)
//	|				AND (GroupRevenue.КвотаНомеров = ExpectedGuestGroupsTurnovers.КвотаНомеров)
//	|				AND (GroupRevenue.ReservationStatus = ExpectedGuestGroupsTurnovers.ReservationStatus)
//	|				AND (GroupRevenue.ТипНомера = ExpectedGuestGroupsTurnovers.ТипНомера)
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		RIBalances.Period,
//	|		RIBalances.Гостиница,
//	|		NULL,
//	|		NULL,
//	|		RIBalances.ТипНомера,
//	|		NULL,
//	|		NULL,
//	|		RIBalances.RoomsVacantClosingBalance,
//	|		RIBalances.BedsVacantClosingBalance,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		RIBalances.CounterClosingBalance
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Day,
//	|				RegisterRecordsAndPeriodBoundaries,
//	|				&qRoomQuotaIsEmpty
//	|					AND (Гостиница = &qHotel
//	|						OR &qHotelIsEmpty)) AS RIBalances
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		RQBalances.Period,
//	|		RQBalances.Гостиница,
//	|		NULL,
//	|		RQBalances.КвотаНомеров,
//	|		RQBalances.ТипНомера,
//	|		NULL,
//	|		NULL,
//	|		RQBalances.RoomsRemainsClosingBalance,
//	|		RQBalances.BedsRemainsClosingBalance,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		RQBalances.CounterClosingBalance
//	|	FROM
//	|		AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Day,
//	|				RegisterRecordsAndPeriodBoundaries,
//	|				(NOT &qRoomQuotaIsEmpty)
//	|					AND (Гостиница = &qHotel
//	|						OR &qHotelIsEmpty)) AS RQBalances) AS GuestGroupsForecast
//	|{WHERE
//	|	GuestGroupsForecast.Гостиница.*,
//	|	GuestGroupsForecast.ReservationStatus AS ReservationStatus,
//	|	GuestGroupsForecast.КвотаНомеров.*,
//	|	GuestGroupsForecast.ТипНомера.*,
//	|	GuestGroupsForecast.ГруппаГостей.*,
//	|	GuestGroupsForecast.ГруппаГостей.Контрагент.* AS Контрагент,
//	|	GuestGroupsForecast.Period,
//	|	GuestGroupsForecast.ЗабронНомеров AS ЗабронНомеров,
//	|	GuestGroupsForecast.ЗабронированоМест AS ЗабронированоМест,
//	|	GuestGroupsForecast.ЗабронДопМест AS ЗабронДопМест,
//	|	GuestGroupsForecast.ЗабронГостей AS ЗабронГостей,
//	|	GuestGroupsForecast.Revenue,
//	|	GuestGroupsForecast.AveragePrice,
//	|	GuestGroupsForecast.MinimumPrice,
//	|	GuestGroupsForecast.MaximumPrice}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	ReservationStatus,
//	|	КвотаНомеров,
//	|	ТипНомера,
//	|	Контрагент,
//	|	ГруппаГостей,
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	Гостиница.*,
//	|	ReservationStatus.*,
//	|	КвотаНомеров.*,
//	|	ТипНомера.*,
//	|	ГруппаГостей.*,
//	|	Контрагент.*,
//	|	ЗабронНомеров,
//	|	ЗабронированоМест,
//	|	ЗабронДопМест,
//	|	ЗабронГостей,
//	|	Revenue,
//	|	AveragePrice,
//	|	MinimumPrice,
//	|	MaximumPrice}
//	|TOTALS
//	|	SUM(ЗабронНомеров),
//	|	SUM(ЗабронированоМест),
//	|	SUM(ЗабронДопМест),
//	|	SUM(ЗабронГостей),
//	|	SUM(Revenue),
//	|	MAX(AveragePrice),
//	|	MIN(MinimumPrice),
//	|	MAX(MaximumPrice)
//	|BY
//	|	Гостиница,
//	|	ReservationStatus,
//	|	КвотаНомеров,
//	|	ТипНомера,
//	|	Контрагент,
//	|	ГруппаГостей,
//	|	Period
//	|{TOTALS BY
//	|	Period,
//	|	ReservationStatus.*,
//	|	Гостиница.*,
//	|	КвотаНомеров.*,
//	|	ТипНомера.*,
//	|	ГруппаГостей.*,
//	|	Контрагент.*,
//	|	Revenue,
//	|	AveragePrice,
//	|	MinimumPrice,
//	|	MaximumPrice}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Expected guest groups';RU='Планируемые группы';de='Geplante Gruppe'");
//	
//	// Fill report builder fields presentations from the report template
//	//
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//Function pmIsResource(pName) Экспорт
//	If pName = "ЗабронНомеров" 
//	   Or pName = "ЗабронированоМест" 
//	   Or pName = "ЗабронДопМест" 
//	   Or pName = "ЗабронГостей" 
//	   Or pName = "Revenue" 
//	   Or pName = "AveragePrice" 
//	   Or pName = "MinimumPrice" 
//	   Or pName = "MaximumPrice" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
//
//// Event back color
//EventBackColor = New Color(240, 240, 240);
