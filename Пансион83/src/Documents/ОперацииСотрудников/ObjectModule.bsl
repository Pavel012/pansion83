//-----------------------------------------------------------------------------
Процедура PostToEmployeeOperationsHistory()
	Movement = RegisterRecords.СотрудникИсторияОпераций.Add();
	
	Movement.Period = ?(ЗначениеЗаполнено(OperationStartTime), OperationStartTime, Date);
	
	FillPropertyValues(Movement, ThisObject);
	
	RegisterRecords.СотрудникИсторияОпераций.Write();
КонецПроцедуры //PostToEmployeeOperationsHistory

//-----------------------------------------------------------------------------
Процедура PostToEmployeeOperationsTurnover()
	// Add record for the operation itself
	Movement = RegisterRecords.ОборотыРаботыПерсонал.Add();
	
	Movement.Period = ?(ЗначениеЗаполнено(OperationStartTime), OperationStartTime, Date);
	
	FillPropertyValues(Movement, ThisObject);
	
	// Fill count resource
	Movement.Count = Quantity;
	
	// Add records for the each article in articles
	For Each vRow In Articles Do
		Movement = RegisterRecords.ОборотыРаботыПерсонал.Add();
		
		Movement.Period = OperationStartTime;
		
		FillPropertyValues(Movement, ThisObject, , "Продолжительность, RoomSpace, КоличествоЧеловек");
		FillPropertyValues(Movement, vRow);
	EndDo;
	
	RegisterRecords.ОборотыРаботыПерсонал.Write();
КонецПроцедуры //PostToEmployeeOperationsTurnover

//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pPostingMode)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	
	// 1. Post to the employee operations history register
	PostToEmployeeOperationsHistory();
	
	// 2. Post to the employee operations turnover
	PostToEmployeeOperationsTurnover();
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(Employee) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Сотрудник> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Employee> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Employee> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Employee", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(Operation) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Работа> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Operation> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Operation> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Operation", pAttributeInErr);
	EndIf;
	If Quantity = 0 Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Количество работ> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Работы Количество> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Работы Количество> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Количество", pAttributeInErr);
	EndIf;
	// Check that there is only one document for the given employee, operation and operation start date
	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Employee) And ЗначениеЗаполнено(Operation) And ЗначениеЗаполнено(RoomType) Тогда
		// Run query
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ОперацииСотрудников.Ref
		|FROM
		|	Document.ОперацииСотрудников AS ОперацииСотрудников
		|WHERE
		|	ОперацииСотрудников.Posted
		|	AND ОперацииСотрудников.Employee = &qEmployee
		|	AND ОперацииСотрудников.Гостиница = &qHotel
		|	AND ОперацииСотрудников.Operation = &qOperation
		|	AND ОперацииСотрудников.ТипНомера = &qRoomType
		|	AND ОперацииСотрудников.НомерРазмещения = &qRoom
		|	AND ОперацииСотрудников.OperationStartTime = &qOperationStartTime
		|	AND ОперацииСотрудников.Ref <> &qRef
		|ORDER BY
		|	ОперацииСотрудников.PointInTime";
		vQry.SetParameter("qHotel", Гостиница);
		vQry.SetParameter("qEmployee", Employee);
		vQry.SetParameter("qOperation", Operation);
		vQry.SetParameter("qRoomType", RoomType);
		vQry.SetParameter("qRoom", Room);
		vQry.SetParameter("qOperationStartTime", OperationStartTime);
		vQry.SetParameter("qRef", Ref);
		vQryRes = vQry.Execute().Unload();
		// Check query result
		If vQryRes.Count() > 0 Тогда
			vHasErrors = True; 
			vMsgTextRu = vMsgTextRu + "У указанного сотрудника в указанное время начала работы уже есть один документ регистрации выбранной работы!" + Chars.LF;
			vMsgTextEn = vMsgTextEn + "There is already one operation registration document for the given operation, employee and operation start time!" + Chars.LF;
			vMsgTextDe = vMsgTextDe + "There is already one operation registration document for the given operation, employee and operation start time!" + Chars.LF;
			pAttributeInErr = ?(pAttributeInErr = "", "Employee", pAttributeInErr);
		EndIf;
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	// Fill from session parameters
	Author = ПараметрыСеанса.ТекПользователь;
	Date = CurrentDate();
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and date
	pmFillAuthorAndDate();
	// Fill from session parameters
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	//OperationStartTime = cm1SecondShift(CurrentDate());
	// Set quantity to 1
	Quantity = 1;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
	Перем vMessage, vAttributeInErr;
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If pWriteMode = DocumentWriteMode.Posting Тогда
		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
		If pCancel Тогда
			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
			Message(NStr(vMessage), MessageStatus.Attention);
			ВызватьИсключение NStr(vMessage);
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(Гостиница) Тогда
		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber

//-----------------------------------------------------------------------------
//Function pmGetOperationEndTime() Экспорт
//	vOperationEndTime = OperationEndTime;
//	If ЗначениеЗаполнено(OperationStartTime) Тогда
//		vOperationEndTime = cm0SecondShift(OperationStartTime + Duration * 60);
//	EndIf;
//	Return vOperationEndTime;
//EndFunction //pmGetOperationEndTime 

//-----------------------------------------------------------------------------
Function pmGetOperationDuration() Экспорт
	vDuration = Duration;
	If ЗначениеЗаполнено(OperationStartTime) And ЗначениеЗаполнено(OperationEndTime) Тогда
		If OperationEndTime >= OperationStartTime Тогда
			vDuration = Round((OperationEndTime - OperationStartTime)/60, 0);
		EndIf;
	EndIf;
	Return vDuration;
EndFunction //pmGetOperationEndTime

//-----------------------------------------------------------------------------
Процедура pmFillArticles() Экспорт
	// Initialize resulting value table
	vStds = New ValueTable();
	
	If ЗначениеЗаполнено(Operation) Тогда
		// Get data from the standards table for the ГруппаНомеров
		If ЗначениеЗаполнено(Room) Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	НормативыПотрНомеклатуры.Article,
			|	НормативыПотрНомеклатуры.Количество,
			|	НормативыПотрНомеклатуры.ЕдИзмерения,
			|	НормативыПотрНомеклатуры.IsPerPerson,
			|	НормативыПотрНомеклатуры.IsPerRoomSpaceUnit
			|FROM
			|	InformationRegister.НормативыПотрНомеклатуры AS НормативыПотрНомеклатуры
			|WHERE
			|	НормативыПотрНомеклатуры.Operation = &qOperation
			|	AND НормативыПотрНомеклатуры.Гостиница = &qHotel
			|	AND НормативыПотрНомеклатуры.НомерРазмещения = &qRoom
			|ORDER BY
			|	НормативыПотрНомеклатуры.Article.ПорядокСортировки";
			vQry.SetParameter("qOperation", Operation);
			vQry.SetParameter("qHotel", Гостиница);
			vQry.SetParameter("qRoom", Room);
			vStds = vQry.Execute().Unload();
		EndIf;
		
		// Get data from the standards table for the ГруппаНомеров type
		If vStds.Count() = 0 And ЗначениеЗаполнено(RoomType) Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	НормативыПотрНомеклатуры.Article,
			|	НормативыПотрНомеклатуры.Количество,
			|	НормативыПотрНомеклатуры.ЕдИзмерения,
			|	НормативыПотрНомеклатуры.IsPerPerson,
			|	НормативыПотрНомеклатуры.IsPerRoomSpaceUnit
			|FROM
			|	InformationRegister.НормативыПотрНомеклатуры AS НормативыПотрНомеклатуры
			|WHERE
			|	НормативыПотрНомеклатуры.Operation = &qOperation
			|	AND НормативыПотрНомеклатуры.Гостиница = &qHotel
			|	AND НормативыПотрНомеклатуры.ТипНомера = &qRoomType
			|	AND НормативыПотрНомеклатуры.НомерРазмещения = &qRoom
			|ORDER BY
			|	НормативыПотрНомеклатуры.Article.ПорядокСортировки";
			vQry.SetParameter("qOperation", Operation);
			vQry.SetParameter("qHotel", Гостиница);
			vQry.SetParameter("qRoomType", RoomType);
			vQry.SetParameter("qRoom", Справочники.НомернойФонд.EmptyRef());
			vStds = vQry.Execute().Unload();
		Endif;
		
		// Get data from the standards table for the hotel and empty ГруппаНомеров and ГруппаНомеров type
		If vStds.Count() = 0 Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	НормативыПотрНомеклатуры.Article,
			|	НормативыПотрНомеклатуры.Количество,
			|	НормативыПотрНомеклатуры.ЕдИзмерения,
			|	НормативыПотрНомеклатуры.IsPerPerson,
			|	НормативыПотрНомеклатуры.IsPerRoomSpaceUnit
			|FROM
			|	InformationRegister.НормативыПотрНомеклатуры AS НормативыПотрНомеклатуры
			|WHERE
			|	НормативыПотрНомеклатуры.Operation = &qOperation
			|	AND НормативыПотрНомеклатуры.Гостиница = &qHotel
			|	AND НормативыПотрНомеклатуры.ТипНомера = &qRoomType
			|	AND НормативыПотрНомеклатуры.НомерРазмещения = &qRoom
			|ORDER BY
			|	НормативыПотрНомеклатуры.Article.ПорядокСортировки";
			vQry.SetParameter("qOperation", Operation);
			vQry.SetParameter("qHotel", Гостиница);
			vQry.SetParameter("qRoomType", Справочники.ТипыНомеров.EmptyRef());
			vQry.SetParameter("qRoom", Справочники.НомернойФонд.EmptyRef());
			vStds = vQry.Execute().Unload();
		Endif;
		
		// Get data from the standards table for the empty hotel, ГруппаНомеров and ГруппаНомеров type
		If vStds.Count() = 0 Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	НормативыПотрНомеклатуры.Article,
			|	НормативыПотрНомеклатуры.Количество,
			|	НормативыПотрНомеклатуры.ЕдИзмерения,
			|	НормативыПотрНомеклатуры.IsPerPerson,
			|	НормативыПотрНомеклатуры.IsPerRoomSpaceUnit
			|FROM
			|	InformationRegister.НормативыПотрНомеклатуры AS НормативыПотрНомеклатуры
			|WHERE
			|	НормативыПотрНомеклатуры.Operation = &qOperation
			|	AND НормативыПотрНомеклатуры.Гостиница = &qHotel
			|	AND НормативыПотрНомеклатуры.ТипНомера = &qRoomType
			|	AND НормативыПотрНомеклатуры.НомерРазмещения = &qRoom
			|ORDER BY
			|	НормативыПотрНомеклатуры.Article.ПорядокСортировки";
			vQry.SetParameter("qOperation", Operation);
			vQry.SetParameter("qHotel", Справочники.Гостиницы.EmptyRef());
			vQry.SetParameter("qRoomType", Справочники.ТипыНомеров.EmptyRef());
			vQry.SetParameter("qRoom", Справочники.НомернойФонд.EmptyRef());
			vStds = vQry.Execute().Unload();
		Endif;
		
		// Add rows to the articles tabular part
		If vStds.Count() > 0 Тогда
			For Each vStdsRow In vStds Do
				vRow = Articles.Add();
				vRow.Article = vStdsRow.Article;
				vRow.ЕдИзмерения = vStdsRow.Unit;
				vRow.IsPerPerson = vStdsRow.IsPerPerson;
				vRow.IsPerRoomSpaceUnit = vStdsRow.IsPerRoomSpaceUnit;
				// Calculate article quantity according to the parameters
				If vRow.IsPerRoomSpaceUnit Тогда
					If vRow.IsPerPerson Тогда
						vRow.QuantityPerUnit = vStdsRow.Quantity;
						vRow.Количество = Quantity * vRow.QuantityPerUnit * RoomSpace * NumberOfPersons;
					Else
						vRow.QuantityPerUnit = vStdsRow.Quantity;
						vRow.Количество = Quantity * vRow.QuantityPerUnit * RoomSpace;
					EndIf;
				Else
					If vRow.IsPerPerson Тогда
						vRow.QuantityPerUnit = vStdsRow.Quantity;
						vRow.Количество = Quantity * vStdsRow.Quantity * NumberOfPersons;
					Else
						vRow.Количество = Quantity * vStdsRow.Quantity;
					EndIf;
				EndIf;
			EndDo;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillArticles

//-----------------------------------------------------------------------------
Function pmGetPreviousOperation() Экспорт
	vPrevOp = Неопределено;
	vQry = New Query();
	vQry.Text = 
	"SELECT TOP 1
	|	ОперацииСотрудников.Ref
	|FROM
	|	Document.ОперацииСотрудников AS ОперацииСотрудников
	|WHERE
	|	ОперацииСотрудников.Posted
	|	AND ОперацииСотрудников.Гостиница = &qHotel
	|	AND ОперацииСотрудников.НомерРазмещения = &qRoom
	|	AND ОперацииСотрудников.Operation = &qOperation
	|	AND ОперацииСотрудников.OperationStartTime < &qPeriod
	|ORDER BY
	|	ОперацииСотрудников.PointInTime DESC";
	vQry.SetParameter("qPeriod", OperationStartTime);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qRoom", Room);
	vQry.SetParameter("qOperation", Operation);
	vPrevOperations = vQry.Execute().Unload();
	For Each vPrevOperationsRow In vPrevOperations Do
		vPrevOp = vPrevOperationsRow.Ref;
		Break;
	EndDo;
	Return vPrevOp;
EndFunction //pmGetPreviousOperation

//-----------------------------------------------------------------------------
Function pmGetNumberOfPersons() Экспорт
	//vOccupiedBeds = 0; 
	vOccupiedPersons = 0;
	If ЗначениеЗаполнено(Room) And ЗначениеЗаполнено(OperationStartTime) Тогда
		If ЗначениеЗаполнено(Operation) And ЗначениеЗаполнено(Гостиница) And Operation = Гостиница.CheckOutCleaning Тогда
			// ГруппаНомеров is usually empty at the moment of check-out cleaning start, 
			// so we need to find number of checked out guests. The best decision would be
			// to calculate the check-out persons turnover from the moment of previous check-out 
			// cleaning but we'll limit this turnover by the number of beds in the ГруппаНомеров
			vPrevOp = pmGetPreviousOperation();
			If ЗначениеЗаполнено(vPrevOp) Тогда
				vQry = New Query();
				vQry.Text = 
				"SELECT
				|	RoomInventoryTurnovers.GuestsCheckedOutTurnover,
				|	RoomInventoryTurnovers.BedsCheckedOutTurnover
				|FROM
				|	AccumulationRegister.ЗагрузкаНомеров.Turnovers(
				|			&qPeriodFrom,
				|			&qPeriodTo,
				|			Period,
				|			Гостиница = &qHotel
				|				AND НомерРазмещения = &qRoom) AS RoomInventoryTurnovers";
				vQry.SetParameter("qPeriodFrom", vPrevOp.OperationStartTime);
				vQry.SetParameter("qPeriodTo", OperationStartTime);
				vQry.SetParameter("qHotel", Гостиница);
				vQry.SetParameter("qRoom", Room);
				vTurnovers = vQry.Execute().Unload();
				If vTurnovers.Count() > 0 Тогда
					vTurnoversRow = vTurnovers.Get(0);
					//vOccupiedBeds = Min(ГруппаНомеров.КолМестВНомере, vTurnoversRow.BedsCheckedOutTurnover);
					vOccupiedPersons = Min(Room.КолМестВНомере, vTurnoversRow.GuestsCheckedOutTurnover);
				Else
					// We'll get the number of beds in the ГруппаНомеров
					//vOccupiedBeds = ГруппаНомеров.КолМестВНомере;
					vOccupiedPersons = Room.КолМестВНомере;
				EndIf;
			Else
				// We'll get the number of beds in the ГруппаНомеров
				//vOccupiedBeds = ГруппаНомеров.КолМестВНомере;
				vOccupiedPersons = Room.КолМестВНомере;
			EndIf;
		Else
			// In all other situations we'll get the number of persons currently in the ГруппаНомеров
			//vRoomPresentation = cmGetRoomPresentation(Гостиница, ГруппаНомеров, OperationStartTime, vOccupiedBeds, vOccupiedPersons);
		EndIf;
	Else
		If ЗначениеЗаполнено(RoomType) Тогда
			// We'll get the number of beds in the ГруппаНомеров
			//vOccupiedBeds = RoomType.NumberOfBedsPerRoom;
			vOccupiedPersons = RoomType.NumberOfBedsPerRoom;
		EndIf;
	EndIf;
	Return vOccupiedPersons;
EndFunction //pmGetNumberOfPersons

//-----------------------------------------------------------------------------
Процедура pmCalculateArticleQuantity(pRow) Экспорт
	If pRow.IsPerRoomSpaceUnit Тогда
		If pRow.IsPerPerson Тогда
			pRow.Количество = Quantity * pRow.QuantityPerUnit * RoomSpace * NumberOfPersons;
		Else
			pRow.Количество = Quantity * pRow.QuantityPerUnit * RoomSpace;
		EndIf;
	Else
		If pRow.IsPerPerson Тогда
			pRow.Количество = Quantity * pRow.QuantityPerUnit * NumberOfPersons;
		Else
			pRow.Количество = Quantity * pRow.QuantityPerUnit;
		EndIf;
	EndIf;
КонецПроцедуры //pmCalculateArticleQuantity

//-----------------------------------------------------------------------------
Процедура pmFillPBXCodes() Экспорт
	If ЗначениеЗаполнено(Employee) And ЗначениеЗаполнено(Operation) Тогда
		If Operation.PBXStartCode <> 0 And 
		   Operation.PBXEndCode <> 0 Тогда
			PBXStartCode = Operation.PBXStartCode;
			PBXEndCode = Operation.PBXEndCode;
		Else
			vCodes = Employee.GetObject().pmGetOperationPBXCodes(Operation);
			For Each vCodesRow In vCodes Do
				If vCodesRow.IsOperationStart Тогда
					PBXStartCode = vCodesRow.PBXCode;
				ElsIf vCodesRow.IsOperationEnd Тогда
					PBXEndCode = vCodesRow.PBXCode;
				EndIf;
			EndDo;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillPBXCodes
