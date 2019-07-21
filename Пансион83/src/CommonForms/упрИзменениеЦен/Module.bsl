//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	// Get all ГруппаНомеров rates
	vRoomRates = cmGetAllRoomRates(ПараметрыСеанса.ТекущаяГостиница);
	// Fill ГруппаНомеров rates table
	RatesTable.Load(vRoomRates);
	// Get all ГруппаНомеров types
	vRoomTypes = cmGetAllRoomTypes(ПараметрыСеанса.ТекущаяГостиница);
	// Fill ГруппаНомеров types table
	RoomTypesTable.Load(vRoomTypes);
	// Get all client types
	vClientTypes = cmGetAllClientTypes();
	// Fill client types table
	vCTFirstRow = ClientTypesTable.Add();
	vCTFirstRow.IsCheck = True;
	vCTFirstRow.ТипКлиента = Справочники.ТипыКлиентов.EmptyRef();
	vCTFirstRow.Title = NStr("en='<Empty client type>';ru='<Пустой тип клиента>';de='<Leerer Kundentyp>'");
	For Each vClientTypesRow In vClientTypes Do
		vCTRow = ClientTypesTable.Add();
		vCTRow.IsCheck = False;
		vCTRow.ТипКлиента = vClientTypesRow.ТипКлиента;
		vCTRow.Title = СокрЛП(vClientTypesRow.Description);
	EndDo;
    // Get all price tags
	vPriceTags = cmGetAllPriceTags();
	// Fill price tags table
	vPTFirstRow = PriceTagsTable.Add();
	vPTFirstRow.IsCheck = True;
	vPTFirstRow.ПризнакЦены = Справочники.ПризнакЦены.EmptyRef();
	vPTFirstRow.Title = NStr("en='<Empty price tag>';ru='<Пустой признак цены>';de='<Leerer Preisschild>'");
	For Each vPriceTagsRow In vPriceTags Do
		vPTRow = PriceTagsTable.Add();
		vPTRow.IsCheck = False;
		vPTRow.ПризнакЦены = vPriceTagsRow.ПризнакЦены;
		vPTRow.Title = СокрЛП(vPriceTagsRow.Description);
	EndDo;	
	// Fill week days table
	// All days
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Все'; en='All'; de='Alle'");
	vNewDayRow.Code= 0;
	// Monday
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Понедельник'; en='Monday'; de='Montag'");
	vNewDayRow.Code= 1;
	// Tuesday
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Вторник'; en='Tuesday'; de='Dienstag'");
	vNewDayRow.Code= 2;
	// Wednesday
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Среда'; en='Wednesday'; de='Mittwoch'");
	vNewDayRow.Code= 3;
	// Thursday
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Четверг'; en='Thursday'; de='Donnerstag'");
	vNewDayRow.Code= 4;
	// Friday
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Пятница'; en='Friday'; de='Freitag'");
	vNewDayRow.Code= 5;
	// Saturday
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Суббота'; en='Saturday'; de='Samstag'");
	vNewDayRow.Code= 6;
	// Sunday
	vNewDayRow = DaysTable.Add();
	vNewDayRow.Day = NStr("ru='Воскресение'; en='Sunday'; de='Sonntag'");
	vNewDayRow.Code= 7;
	// Create accommodation types fields
	vAccTypes = cmGetAllAccommodationTypes();
	vIndex = 0;
	vDefaultCurrency = ПараметрыСеанса.ТекущаяГостиница.ВалютаЛицСчета;
	For Each vAccTypesRow In vAccTypes Do
		If vAccTypesRow.ВидРазмещения.ТипРазмещения <> Перечисления.ВидыРазмещений.Together Тогда
			Try
				AddAccommodationTypeFieldAttributes(vIndex);
				ЭтаФорма["AccommodationType"+String(vIndex)] = vAccTypesRow.ВидРазмещения;
				ЭтаФорма["Currency"+String(vIndex)] = vDefaultCurrency;
			Except
			EndTry;
			vIndex = vIndex + 1;
		EndIf;
	EndDo;
	AccommodationTypesCount = vIndex;
КонецПроцедуры //OnCreateAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура AddAccommodationTypeFieldAttributes(pIndex)
		vTempArray = New Array;	
		vTempArray.Add(New FormAttribute("ВидРазмещения"+String(pIndex), New TypeDescription("CatalogRef.ВидыРазмещения")));
		vTempArray.Add(New FormAttribute("Цена"+String(pIndex), New TypeDescription("Number",,,New NumberQualifiers(17, 2))));
		vTempArray.Add(New FormAttribute("Валюта"+String(pIndex), New TypeDescription("CatalogRef.Currencies")));
		ChangeAttributes(vTempArray);
		
		// Accommodation type group
		vGuestGroup = Items.Add("ВидРазмещения"+String(pIndex)+"Group", Type("FormGroup"), Items.AccommodationTypesGroup);
		vGuestGroup.Title = NStr("en='""Accommodation type №';ru='Группа ""Вид размещения №';de='Gruppe ""Typ der Unterkunft Nr.'")+String(pIndex)+NStr("ru='""';en='"" group';de='"" gruppe'");
		vGuestGroup.ТипРазмещения = FormGroupType.UsualGroup;
		vGuestGroup.Representation = UsualGroupRepresentation.None;
		vGuestGroup.Group = ChildFormItemsGroup.Horizontal;
		vGuestGroup.ShowTitle = False;
		
		// Accommodation type field
		vNewField = Items.Add("ВидРазмещения"+String(pIndex), Type("FormField"), vGuestGroup);
		vNewField.ТипРазмещения = FormFieldType.LabelField;
		vNewField.DataPath = "ВидРазмещения"+String(pIndex);
		vNewField.Title = "";
		vNewField.TitleLocation = FormItemTitleLocation.None;
		vNewField.Width = 25;
		vNewField.HorizontalStretch = False;
		
		// Price field
		vNewField = Items.Add("Цена"+String(pIndex), Type("FormField"), vGuestGroup);
		vNewField.ТипРазмещения = FormFieldType.InputField;
		vNewField.Enabled = False;
		vNewField.TextEdit = True;
		vNewField.Title = "";
		vNewField.TitleLocation = FormItemTitleLocation.None;
		vNewField.DataPath = "Цена"+String(pIndex);
		vNewField.Width = 10;
		vNewField.ClearButton = False;
		vNewField.ChoiceButton = False;
		vNewField.OpenButton = False;
		vNewField.HorizontalStretch = False;
		
		// Currency field
		vNewField = Items.Add("Валюта"+String(pIndex), Type("FormField"), vGuestGroup);
		vNewField.ТипРазмещения = FormFieldType.InputField;
		vNewField.Enabled = True;
		vNewField.TextEdit = False;
		vNewField.Title = "";
		vNewField.TitleLocation = FormItemTitleLocation.None;
		vNewField.DataPath = "Валюта"+String(pIndex);
		vNewField.Width = 10;
		vNewField.ClearButton = False;
		vNewField.ChoiceButton = True;
		vNewField.OpenButton = False;
		vNewField.HorizontalStretch = False;
		vNewField.SetAction("StartChoice", "CurrencyStartChoice");
		
		Items.SetPrices.Enabled = ChangePrices;
КонецПроцедуры //AddKidAgeAttributes

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DaysTableIsCheckOnChange(pItem)
	If Items.DaysTable.CurrentRow = 0 Тогда
		If Items.DaysTable.CurrentData <> Неопределено Тогда
			vIsCheck = Items.DaysTable.CurrentData.IsCheck;
			For Each vRow In DaysTable Do
				vRow.IsCheck = vIsCheck;
			EndDo;
		EndIf;
	Else
		DaysTable.Get(0).IsCheck = False;
	EndIf;
КонецПроцедуры //DaysTableIsCheckOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CurrencyStartChoice(pItem, pChoiceData, pStandardProcessing)
	Try 
		vValue = ChooseFromList(GetCurrencies(), pItem).Value;
		ЭтаФорма[pItem.Name] = vValue;	
		pStandardProcessing = False;
	Except
		pStandardProcessing = False;
	EndTry;
КонецПроцедуры //CurrencyStartChoice

//-----------------------------------------------------------------------------
&AtServer
Процедура СheckParamAtServer()
	// Check parmeters
	If ЗначениеЗаполнено(BegOfDay(DateFrom)) And ЗначениеЗаполнено(EndOfDay(DateTo))   Тогда
		If НЕ BegOfDay(DateFrom) < EndOfDay(DateTo)  Тогда
			vMassege = NStr("en='Check-in date is later then check-out date!';ru='Дата окончания должна быть больше даты начала!';de='Das Abreisedatum liegt vor dem Anreisedatum!'");
			ВызватьИсключение vMassege;
		EndIf;
	Else
		vMassege = NStr("en='You must fill in the start date and the end date!';ru='Необходимо заполнить дату начала и дату окончания!';de='Sie müssen in der Startdatum und Enddatum zu füllen!'");
		ВызватьИсключение vMassege;
	EndIf;
	
	vFilterDaysTable 		=  DaysTable.FindRows(New Structure ("IsCheck",True));
	vFilterRatesTable 		=  RatesTable.FindRows(New Structure ("IsCheck",True));
	vFilterRoomTypesTable 	=  RoomTypesTable.FindRows(New Structure ("IsCheck",True));
	vFilterClientTypesTable	=  ClientTypesTable.FindRows(New Structure ("IsCheck",True));
	vFilterPriceTagsTable 	=  PriceTagsTable.FindRows(New Structure ("IsCheck",True));

	If vFilterDaysTable.Count()=0 Тогда
		vMassege = NStr("en='Check days of week!';ru='Отметьте дни недели!';de='Wochentage markieren!'");
		ВызватьИсключение vMassege;
	EndIf;
	
	If vFilterRatesTable.Count()=0 Тогда
		vMassege = NStr("en='Check ГруппаНомеров rates for a change!';ru='Отметьте тарифы для изменения!';de='Markieren Sie die Tarife die verändern wird!'");
		ВызватьИсключение vMassege;
	EndIf;

	If vFilterRoomTypesTable.Count()=0 Тогда
		vMassege = NStr("en='Check ГруппаНомеров types for a change!';ru='Отметьте типы номеров для изменения!';de='Markieren Sie die Zimmern Typen für eine Veränderung!'");
		ВызватьИсключение vMassege;
	EndIf;  
	
	If vFilterClientTypesTable.Count()=0 Тогда
		vCTFindedRows = ClientTypesTable.FindRows(New Structure ("ТипКлиента", Справочники.ТипыКлиентов.EmptyRef()));
		If vCTFindedRows.Count() > 0 Тогда
			vCTRow = vCTFindedRows.Get(0);
			vCTRow.IsCheck = True;
		EndIf;
	EndIf;
	
	If vFilterPriceTagsTable.Count()=0 Тогда
		vPTFindedRows = PriceTagsTable.FindRows(New Structure ("ПризнакЦены", Справочники.ПризнакЦены.EmptyRef()));
		If vPTFindedRows.Count() > 0 Тогда
			vPTRow = vPTFindedRows.Get(0);
			vPTRow.IsCheck = True;
		EndIf;
	EndIf;
КонецПроцедуры //СheckParamAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура GetRoomRatePrices()
	// Check parmeters
	СheckParamAtServer();
	
	vRatesTable 		= FormAttributeToValue("RatesTable");
	vRoomTypesTable  	= FormAttributeToValue("RoomTypesTable");
	//vDaysTable 			= FormAttributeToValue("DaysTable");
	vClientTypesTable 	= FormAttributeToValue("ClientTypesTable");
	vPriceTagsTable 	= FormAttributeToValue("PriceTagsTable");
	
	CheckInDate		= ЭтаФорма.ДатаНачКвоты;
	CheckOutDate	= ЭтаФорма.ДатаКонКвоты;
	
	//vFilterDaysTable 		=  vDaysTable.FindRows(New Structure ("IsCheck",True));
	vFilterRatesTable 		=  vRatesTable.FindRows(New Structure ("IsCheck",True));
	vFilterRoomTypesTable 	=  vRoomTypesTable.FindRows(New Structure ("IsCheck",True));
	vFilterClientTypesTable =  vClientTypesTable.FindRows(New Structure ("IsCheck",True));
	vFilterPriceTagsTable 	=  vPriceTagsTable.FindRows(New Structure ("IsCheck",True));

	vRoomRate   = vFilterRatesTable[vFilterRatesTable.Count()-1].Тариф;
	vRoomType   = vFilterRoomTypesTable[vFilterRoomTypesTable.Count()-1].ТипНомера;
	vClientType   = vFilterClientTypesTable[vFilterClientTypesTable.Count()-1].ТипКлиента;
	vPriceTag   = vFilterPriceTagsTable[vFilterPriceTagsTable.Count()-1].ПризнакЦены;
		
	// Get day type
	vDayType = cmGetCalendarDayType(vRoomRate, CheckInDate, CheckInDate, CheckOutDate);
	
	// Get prices valid for the period from date
	vBasePrices = vRoomRate.GetObject().pmGetRoomRatePrices(EndOfDay(CheckInDate), , vClientType, vRoomType, , , vPriceTag, CheckInDate, CheckOutDate);
	If vBasePrices.Count() = 0 Тогда
		vMassege = NStr("en='You have to perform initial prices configuration of the ГруппаНомеров rate item: ';ru='Нужно выполнить первоначальную настройку цен для тарифа: ';de='Sie haben die ersten Preise Konfiguration des Zimmerpreises durchführen für Tariff: '") + СокрЛП(vRoomRate.Description);
		ВызватьИсключение vMassege;
	EndIf;	
	vBasePrices.Sort("Recorder Desc");
	
	RoomRatePrices = Неопределено;
	If ЗначениеЗаполнено(vDayType) Тогда
		vFilterBasePrices = vBasePrices.FindRows(New Structure ("ТипДеньКалендарь", vDayType));
		If vFilterBasePrices.Count() = 0 Тогда
			RoomRatePrices = vBasePrices[0].Recorder;
		Else
			RoomRatePrices = vFilterBasePrices[0].Recorder;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(RoomRatePrices) Тогда
		vMassege = NStr("en='No active set ГруппаНомеров rate prices document found for the ГруппаНомеров rate: ';ru='Не найден действующий приказ об изменении цен для тарифа: ';de='Keine aktive Set Zimmerpreis Dokument für die Tariff gefunden: '") + СокрЛП(vRoomRate.Description) + ", " + СокрЛП(vDayType) + ", " + СокрЛП(vRoomType);
		ВызватьИсключение vMassege;
	EndIf;	
	
	// Get price table
	vTablePrice = GetPrices(vBasePrices, RoomRatePrices);
	If vTablePrice.Count() = 0 Тогда
		vMassege = NStr("en='No prices found for the ГруппаНомеров rate: ';ru='Не найдены цены для тарифа: ';de='Keine Preise für die Tariff gefunden: '") + СокрЛП(vRoomRate.Description);
		ВызватьИсключение vMassege;
	EndIf;	
	
	For vInd = 0 To (AccommodationTypesCount-1) Do
		 vRoomTypes = ЭтаФорма["AccommodationType" + String(vInd)];
		 
		 vPrice = vTablePrice.FindRows(New Structure("ВидРазмещения", vRoomTypes));
		 
		 ЭтаФорма["Price"+String(vInd)] = ?(vPrice.Count() > 0, vPrice[0].Цена, 0);
	EndDo;

	SetVisible();
КонецПроцедуры //GetRoomRatePrices

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ChangePricesOnChange(Item)
	ЭтаФорма.Items.AccommodationTypesGroup.Visible = ChangePrices;
	For vInd = 0 To AccommodationTypesCount-1 Do
		 ЭтаФорма.Items["Price"+String(vInd)].Enabled = ChangePrices;
		 ЭтаФорма.Items.SetPrices.Enabled = ChangePrices;
	EndDo;
КонецПроцедуры //ChangePricesOnChange

//-----------------------------------------------------------------------------
Function CheckIfRoomRateHasUniqueCalendar(pRoomRate)
	vCalendar = pRoomRate.Calendar;
	// Try to find other ГруппаНомеров rates referencing the same calendar
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Тарифы.Ref
	|FROM
	|	Catalog.Тарифы AS Тарифы
	|WHERE
	|	NOT (Тарифы.DeletionMark)
	|	AND (NOT Тарифы.IsFolder)
	|	AND Тарифы.Ref <> &qRoomRate
	|	AND Тарифы.Calendar = &qCalendar
	|
	|ORDER BY
	|	Тарифы.ПорядокСортировки,
	|	Тарифы.Code";
	vQry.SetParameter("qRoomRate", pRoomRate);
	vQry.SetParameter("qCalendar", vCalendar);
	vOtherRoomRates = vQry.Execute().Unload();
	If vOtherRoomRates.Count() > 0 Тогда
		// There are other ГруппаНомеров rates referencing the same calendar. We need to create new calendar as a copy of current one
		vNewCalendarObj = vCalendar.Copy();
		vNewCalendarObj.Code = СокрЛП(pRoomRate.Code);
		vNewCalendarObj.Description = СокрЛП(pRoomRate.Description);
		vNewCalendarObj.Примечания = NStr("en='Automatically created by <Change ГруппаНомеров rate prices Wizard> as copy of calendar: '; ru='Автоматически создан <Мастером изменения цен> как копия календаря: '; de='Automatisch durch <Change Zimmerpreis Wizard> als Kopie Kalender erstellt: '") + СокрЛП(vCalendar.Code) + " - " + СокрЛП(vCalendar.Description);
		vNewCalendarObj.Write();
		vCalendar = vNewCalendarObj.Ref;
		// Write calendar days
		vDays = InformationRegisters.КалендарьДень.CreateRecordSet();
		vDays.Filter.Calendar.ComparisonType = ComparisonType.Equal;
		vDays.Filter.Calendar.Value = vCalendar;
		vDays.Filter.Calendar.Use = True;
		vDays.Read();
		// Get target calendar days
		vTgtDays = InformationRegisters.КалендарьДень.CreateRecordSet();
		vTgtDays.Filter.Calendar.ComparisonType = ComparisonType.Equal;
		vTgtDays.Filter.Calendar.Value = vCalendar;
		vTgtDays.Filter.Calendar.Use = True;
		vTgtDays.Read();
		vTgtDays.Clear();
		// Copy calendar days
		If vDays.Count() > 0 Тогда
			For Each vDaysRow In vDays Do
				vTgtDaysRow = vTgtDays.Add();
				vTgtDaysRow.Calendar = vCalendar;
				vTgtDaysRow.Period = vDaysRow.Period;
				vTgtDaysRow.ТипДняКалендаря = vDaysRow.ТипДняКалендаря;
				vTgtDaysRow.РаспорядокДня = vDaysRow.РаспорядокДня;
			EndDo;
			// Write record set to the database
			vTgtDays.Write(False);
		EndIf;
		// Save new calendar to the ГруппаНомеров rate
		vRoomRateObj = pRoomRate.GetObject();
		vRoomRateObj.Calendar = vCalendar;
		vRoomRateObj.Write();
	EndIf;
	// Return calendar reference
	Return vCalendar;
EndFunction //CheckIfRoomRateHasUniqueCalendar

//-----------------------------------------------------------------------------
&AtServer
Function SetPricesAtServer()
	vResult = False;
	
	СheckParamAtServer();
	
	// Accommodation types (Array with structures(AccommodationType, Price, Currency))
	vAccommodationTypes = New Array;
	For vInd = 0 To AccommodationTypesCount-1 Do
		Try
			vAccommodationTypes.Add(New Structure("ВидРазмещения, Цена, Валюта",ЭтаФорма["AccommodationType"+String(vInd)], ЭтаФорма["Price"+String(vInd)], ЭтаФорма["Currency"+String(vInd)]));
		Except
		EndTry;
	EndDo;
	
	// Choosen ГруппаНомеров types (value list)
	vRoomTypes				= RoomTypesTable.FindRows(new Structure("IsCheck",True));
	vFltrRoomRates  		= RatesTable.FindRows(new Structure("IsCheck",True));
	vFilterClientTypesTable	= ClientTypesTable.FindRows(New Structure("IsCheck",True));
	vFilterPriceTagsTable 	= PriceTagsTable.FindRows(New Structure("IsCheck",True));
	
	// Do all changes in one transaction
	BeginTransaction(DataLockControlMode.Managed);
	Try
		For Each vRate In vFltrRoomRates Do
			vRoomRate = vRate.Тариф;
			
			// Add day type to the calendar
			vRoomRateDayTypes = UpdateRoomRateCalendar(vRoomRate);
			
			// Get ГруппаНомеров rate prices
			For Each vRoomRateDayTypesRow In vRoomRateDayTypes Do
				vBasePrices = vRoomRate.GetObject().pmGetRoomRatePrices(EndOfDay(vRoomRateDayTypesRow.ДатаЦены));
				If vBasePrices.Count() = 0 Тогда
					vMassege = NStr("en='You have to perform the initial prices configuration of ГруппаНомеров rate: ';ru='Нужно выполнить первоначальную настройку цен для тарифа: ';de='Sie haben die ersten Preise Konfiguration des Zimmerpreises durchführen für Tariff: '") + СокрЛП(vRoomRate.Description);
					ВызватьИсключение vMassege;
				EndIf;
				vFltrBasePrices = vBasePrices.FindRows(new Structure("ТипДеньКалендарь", vRoomRateDayTypesRow.NewCalendarDayType));
				If vFltrBasePrices.Count() = 0 Тогда
					vFltrBasePrices = vBasePrices.FindRows(new Structure("ТипДеньКалендарь", vRoomRateDayTypesRow.OldCalendarDayType));
					If vFltrBasePrices.Count() = 0 Тогда
						vBasePrices.Sort("Recorder Desc");
						vRoomRatePrices = vBasePrices[0].Recorder;
					Else
						vRoomRatePrices = vFltrBasePrices[0].Recorder; 
					EndIf;
				Else
					vRoomRatePrices = vFltrBasePrices[0].Recorder; 
				EndIf;
				
				For Each vPriceTagItem In vFilterPriceTagsTable Do
					// Create new SetRoomRatePrices document
					vNewRoomRatePrices = vRoomRatePrices.Copy();
					vNewRoomRatePrices.ТипДняКалендаря 	= vRoomRateDayTypesRow.NewCalendarDayType;
					vNewRoomRatePrices.ДатаДок 			= GetDefaultDateByRoomRate(vRoomRate);
					vNewRoomRatePrices.Тариф 		= vRoomRate;
					vNewRoomRatePrices.ПризнакЦены 		= vPriceTagItem.ПризнакЦены;
				
					vTab = vNewRoomRatePrices.Цены;
					For Each vStrClientTypes In vFilterClientTypesTable Do
						For Each vStrRoomTypes In vRoomTypes Do
							vFltrRowTab = vTab.FindRows(New Structure("ТипНомера, ТипКлиента", vStrRoomTypes.ТипНомера, vStrClientTypes.ТипКлиента));
							For Each str In vFltrRowTab Do
								If str.IsRoomRevenue Тогда
									For Each Ind In vAccommodationTypes Do	
										If str.ВидРазмещения = Ind.ВидРазмещения Тогда
											str.Цена = Ind.Цена;
											str.Валюта = Ind.Валюта;
										EndIf;	
									EndDo;	
								EndIf;	
							EndDo;
						EndDo;	
					EndDo;
					vNewRoomRatePrices.SetTime(AutoTimeMode.Last); 
					vNewRoomRatePrices.Write(DocumentWriteMode.Posting); 
				EndDo; // By price tags
			EndDo; // By day types
		EndDo; //By ГруппаНомеров rates
		
		// Commit transaction
		CommitTransaction();
			
		// Reread prices
		GetRoomRatePrices();
		
		vResult = True;
	Except
		//vErrorInfo = ErrorInfo();
		If TransactionActive() Тогда
			RollbackTransaction();
		EndIf;
		//ВызватьИсключение cmGetRootErrorDescription(vErrorInfo);
	EndTry;
	
	Return vResult;
EndFunction //SetPricesAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура SetPrices(pCommand)
	If SetPricesAtServer() Тогда
		ShowMessageBox(Неопределено, NStr("en='Price change has completed!';ru='Изменение цен завершено!';de='Preisänderung abgeschlossen ist!'"));
	EndIf;
КонецПроцедуры //SetPrices

//-----------------------------------------------------------------------------
&AtServer
Function UpdateRoomRateCalendar(pRoomRate)
	// Initialize value table 
	vDayTypesTable = New ValueTable();
	vDayTypesTable.Columns.Add("ДатаЦены", cmGetDateTypeDescription());
	vDayTypesTable.Columns.Add("NewCalendarDayType", cmGetCatalogTypeDescription("ТипДневногоКалендаря"));
	vDayTypesTable.Columns.Add("OldCalendarDayType", cmGetCatalogTypeDescription("ТипДневногоКалендаря"));
	
	// Get day type
	vPeriodDescription = GetPeriodDescription();
	vPeriodDayType = Справочники.ТипДневногоКалендаря.FindByDescription(vPeriodDescription, True);
	// Create new day type if it is not found
	If НЕ ЗначениеЗаполнено(vPeriodDayType) Тогда
		vNewDayTypeObj = Справочники.ТипДневногоКалендаря.CreateItem();
		vNewDayTypeObj.Description = vPeriodDescription;
		vNewDayTypeObj.SetNewCode();
		vNewDayTypeObj.Write();
		vPeriodDayType = vNewDayTypeObj.Ref;
	EndIf;	
	
	// Check if ГруппаНомеров rate has unique calendar. If not then create it as copy of the current
	vCalendar = CheckIfRoomRateHasUniqueCalendar(pRoomRate);
	
	// Process user input
	vCalendarDaysRcdSet = InformationRegisters.КалендарьДень.CreateRecordSet();
	vDate = DateFrom;
	vDateTo = DateTo;
	vCurDayType = Неопределено;
	vDateFromDayType = Неопределено;
	vDayTypesTableRow = Неопределено;
	While vDate <= vDateTo Do
		// Check day of week
		vDaysOfWeekItem = DaysTable.FindRows(new Structure("Code",WeekDay(vDate)));
		If vDaysOfWeekItem.Count()>0 Тогда
			If vDaysOfWeekItem[0].IsCheck Тогда
				// Read calendar record for the current date
				vCalendarDaysManager = InformationRegisters.КалендарьДень.CreateRecordManager();
				vCalendarDaysManager.Calendar = vCalendar;
				vCalendarDaysManager.Period = vDate;
				vCalendarDaysManager.Read();
				// Copy all day types that are inside choosen wizard period
				If vCalendarDaysManager.Selected() Тогда
					// Save old day type for the current date
					vOldDayType = vCalendarDaysManager.ТипДняКалендаря;
					If vCurDayType <> vOldDayType Тогда
						// Add row to the value table with new day types
						vDayTypesTableRow = vDayTypesTable.Add();
						vDayTypesTableRow.ДатаЦены = vDate;
						vDayTypesTableRow.OldCalendarDayType = vOldDayType;
						If vCurDayType = Неопределено Тогда
							vDateFromDayType = vOldDayType;
							vDayTypesTableRow.NewCalendarDayType = vPeriodDayType;
						Else
							If vOldDayType = vDateFromDayType Тогда
								vDayTypesTableRow.NewCalendarDayType = vPeriodDayType;
							Else
								// Create new day type as copy of the old one
								vNewDayTypeObj = vOldDayType.Copy();
								vNewDayTypeObj.SetNewCode();
								vNewDayTypeObj.Description = СокрЛП(Left(vNewDayTypeObj.Description, 19)) + " " + СокрЛП(vOldDayType.Code);
								vNewDayTypeObj.Write();
								vDayTypesTableRow.NewCalendarDayType = vNewDayTypeObj.Ref;
							EndIf;
						EndIf;
						
						// Save current date day type
						vCurDayType = vOldDayType;
					EndIf;
					
					// Delete old calendar days record
					vCalendarDaysManager.Delete();
				EndIf;
				
				// Write new caledar day record
				vCalendarDayRow = vCalendarDaysRcdSet.Add();
				vCalendarDayRow.Calendar = vCalendar;
				vCalendarDayRow.Period = vDate;
				vCalendarDayRow.ТипДняКалендаря = ?(vDayTypesTableRow = Неопределено, vPeriodDayType, vDayTypesTableRow.NewCalendarDayType);
				vCalendarDayRow.Active = True;
			EndIf;
		EndIf;
		
		// Go to the next date
		vDate = vDate + 24 * 3600;
	EndDo;
	
	// Update dates in the calendar
	If vCalendarDaysRcdSet.Count() > 0 Тогда
		vCalendarDaysRcdSet.Write(False);
	EndIf;
	
	Return vDayTypesTable;
EndFunction //UpdateRoomRateCalendar

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ChangeLimitsOnChange(Item)
	ЭтаФорма.Items.SetLimits.Enabled =	ChangeLimits;
	Items.RestrictionsGroup1.Visible =	ChangeLimits;
КонецПроцедуры //ChangeLimitsOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура SetLimitsAtServer()
	vRoomTypeEmpry = Справочники.ТипыТарифов.EmptyRef();
	If ChangeLimits Тогда
		vFltrRate = RatesTable.FindRows(new Structure("IsCheck",True));
		For Each vStr In vFltrRate Do
			
			//vCalendar = vStr.Тариф.Calendar;
			vRoomRateRestrictions = InformationRegisters.ТарифОграничение.CreateRecordSet();

			vRoomTypes = RoomTypesTable.FindRows(new Structure("IsCheck",True));
			
			If vRoomTypes.Count()>0 Тогда 
				For Each vStrRoomType In vRoomTypes Do
										
					vDate = DateFrom;
					vDateTo = DateTo;
					
					While vDate <= vDateTo Do
						// Check day of week
						vDaysOfWeekItem = DaysTable.FindRows(new Structure("Code", WeekDay(vDate)));
						If vDaysOfWeekItem.Count()>0  Тогда
							If vDaysOfWeekItem[0].IsCheck Тогда
								Try
									vRestrictions = InformationRegisters.ТарифОграничение.CreateRecordManager();
									vRestrictions.Гостиница 			= vStr.Тариф.Гостиница;
									vRestrictions.Тариф 			= vStr.Тариф;
									vRestrictions.УчетнаяДата 	= vDate;
									vRestrictions.ТипНомера 			= vStrRoomType.ТипНомера;
									vRestrictions.DayOfWeek 		= WeekDay(vDate);
									
									vRestrictions.Delete();
								Except
									//f=0;
								EndTry;	
								
								vRateRestrictions = vRoomRateRestrictions.Add();
								vRateRestrictions.Гостиница 				= vStr.Тариф.Гостиница;
								vRateRestrictions.Тариф 				= vStr.Тариф;
								vRateRestrictions.УчетнаяДата 		= vDate;
								vRateRestrictions.ТипНомера 				= vStrRoomType.ТипНомера;
								vRateRestrictions.MLOS 					= MLOS;
								vRateRestrictions.MaxLOS 				= MaxLOS;
								vRateRestrictions.CTA 					= CTA;
								vRateRestrictions.CTD 					= CTD;
								vRateRestrictions.MinDaysBeforeCheckIn 	= MinDaysBeforeCheckIn;
								vRateRestrictions.MaxDaysBeforeCheckIn 	= MaxDaysBeforeCheckIn;
								vRateRestrictions.DayOfWeek 			= WeekDay(vDate);
								vRateRestrictions.Active = True;
							EndIf;
						EndIf;
						// Go to the next date
						vDate = vDate + 24 * 3600;
					EndDo;
					If vRoomRateRestrictions.Count() > 0 Тогда
						vRoomRateRestrictions.Write(False);
					EndIf;
				EndDo;
			Else
				vDate = DateFrom;
				vDateTo = DateTo;
				
				While vDate <= vDateTo Do
					// Check day of week
					vDaysOfWeekItem = DaysTable.FindRows(new Structure("Code",WeekDay(vDate)));
					If vDaysOfWeekItem.Count()>0  Тогда
						If vDaysOfWeekItem[0].IsCheck Тогда
							Try
								vRestrictions = InformationRegisters.ТарифОграничение.CreateRecordManager();
								vRestrictions.Гостиница 			= vStr.Тариф.Гостиница;
								vRestrictions.Тариф 			= vStr.Тариф;
								vRestrictions.УчетнаяДата 	= vDate;
								vRestrictions.ТипНомера 			= vRoomTypeEmpry;
								vRestrictions.DayOfWeek 		= WeekDay(vDate);
								
								vRestrictions.Delete();
							Except
								//f=0;
							EndTry;	
							
							vRateRestrictions = vRoomRateRestrictions.Add();
							vRateRestrictions.Гостиница 				= vStr.Тариф.Гостиница;
							vRateRestrictions.Тариф 				= vStr.Тариф;
							vRateRestrictions.УчетнаяДата 		= vDate;
							vRateRestrictions.ТипНомера 				= vRoomTypeEmpry;
							vRateRestrictions.MLOS 					= MLOS;
							vRateRestrictions.MaxLOS 				= MaxLOS;
							vRateRestrictions.CTA 					= CTA;
							vRateRestrictions.CTD 					= CTD;
							vRateRestrictions.MinDaysBeforeCheckIn 	= MinDaysBeforeCheckIn;
							vRateRestrictions.MaxDaysBeforeCheckIn 	= MaxDaysBeforeCheckIn;
							vRateRestrictions.DayOfWeek 			= WeekDay(vDate);
							vRateRestrictions.Active = True;
						EndIf;
					EndIf;
					// Go to the next date
					vDate = vDate + 24 * 3600;
				EndDo;
				If vRoomRateRestrictions.Count() > 0 Тогда
					vRoomRateRestrictions.Write(False);
				EndIf;
				
			EndIf;
		EndDo;	
		Message(NStr("en='ГруппаНомеров rate restrictions change has completed!';ru='Установка ограничений по тарифу завершена!';de='Einschränkungen Wechsel abgeschlossen!'"), MessageStatus.Information);
	EndIf;	
КонецПроцедуры //SetLimitsAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура SetLimits(Command)
	SetLimitsAtServer();
КонецПроцедуры //SetLimits

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура FillPrices(Command)
	GetRoomRatePrices();
КонецПроцедуры //FillPrices

//-----------------------------------------------------------------------------
&AtServer
Процедура SetVisible()
	If ЗначениеЗаполнено(RoomRatePrices) Тогда
		vAccType = RoomRatePrices.Prices.Unload(,"ВидРазмещения");  
		vAccType.GroupBy("ВидРазмещения");
		
		For vInd = 0 To AccommodationTypesCount-1 Do
			vRoomTypes = ЭтаФорма["AccommodationType"+String(vInd)];
			
			vIsVisible = vAccType.FindRows(New Structure ("ВидРазмещения",vRoomTypes)).Count()>0;
			ЭтаФорма.Items["AccommodationType"+String(vInd)].Visible 	= vIsVisible;
			ЭтаФорма.Items["Currency"+String(vInd)].Visible 			= vIsVisible;
			ЭтаФорма.Items["Price"+String(vInd)].Visible 				= vIsVisible;
		EndDo;
	EndIf;	
КонецПроцедуры //SetVisible	

//-----------------------------------------------------------------------------
Function GetCurrencies()
	vCurrenciesList = New СписокЗначений;
	vCurrencies = cmGetAllCurrencies();
	vCurrenciesList.LoadValues(vCurrencies.UnloadColumn("Валюта"));
	Return vCurrenciesList;
EndFunction //GetCurrencies

//-----------------------------------------------------------------------------
&AtServer
Function GetPeriodDescription()
	vDays = String(Format(DateFrom,"DF=dd.MM")) + "-" + String(Format(DateTo,"DF=dd.MM")) + "_";
	For vInd = 1 To DaysTable.Count()-1 Do
		vDayRow = DaysTable.Get(vInd);
		If vDayRow.IsCheck Тогда
			vDays = vDays + vDayRow.Code;
		EndIf;
	EndDo;
	Return vDays;
EndFunction //GetPeriodDescription

//-----------------------------------------------------------------------------
&AtServer
Function GetPrices(pBasePrices,pRoomRatePrices)
	vQry = New Query;
	vQry.Text =
	"SELECT
	|	*
	|INTO vTrans
	|FROM
	|	&qTrans AS vTrans
	|WHERE
	|	vTrans.Recorder = &qDoc
	|	AND vTrans.IsRoomRevenue = TRUE
	|;             
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	*
	|FROM
	|	vTrans AS vTrans";
	vQry.SetParameter("qTrans", pBasePrices);
	vQry.SetParameter("qDoc", pRoomRatePrices);
	
	vQryResult = vQry.Execute().Unload();
	Return vQryResult;
EndFunction //GetPrices

//-----------------------------------------------------------------------------
&AtServer
Function GetDefaultDateByRoomRate(pRoomRate)
	vQry = New Query;
	vQry.Text =
	"SELECT TOP 1
	|	RoomRatePrices.Recorder.ДатаДок as Date,
	|	MIN(RoomRatePrices.Recorder) AS Recorder
	|FROM
	|	InformationRegister.RoomRatePrices AS RoomRatePrices
	|WHERE
	|	RoomRatePrices.Тариф IN HIERARCHY(&qRoomRate)
	|
	|GROUP BY
	|	RoomRatePrices.Recorder.ДатаДок";
	vQry.SetParameter("qRoomRate", pRoomRate);
	
	vQryResult = vQry.Execute().Unload();

	Return ?(vQryResult.Count()>0, vQryResult[0].ДатаДок, Date('20000101'));
EndFunction	//GetDefaultDateByRoomRate

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DateFromOnChange(pItem)
	If ЗначениеЗаполнено(DateFrom) And DateFrom <= DateTo Тогда
		ЭтаФорма.Items.GetPrices.Title = NStr("en='Get prices active for the date: '; ru='Получить цены действующие на '; de='Holen Sie sich aktuelle Preise für das Datum: '") + Format(DateFrom, "DF=dd.MM.yyyy");
	Else
		ЭтаФорма.Items.GetPrices.Title = NStr("en='Get active prices'; ru='Получить действующие цены'; de='Holen Sie sich aktuelle Preise'");
	EndIf;
КонецПроцедуры //DateFromOnChange
