//-----------------------------------------------------------------------------
// Get operation standards for the specified hotel, ГруппаНомеров and ГруппаНомеров type
//-----------------------------------------------------------------------------
Function pmGetOperationStandards(Val pHotel, pRoomType, pRoom) Экспорт
	// Initialize resulting value table
	vStds = New ValueTable();
	
	// Fill parameter default values 
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		pHotel = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	
	// Build and run query to get data for the ГруппаНомеров
	If ЗначениеЗаполнено(pRoom) Тогда
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	НормативыРабот.Operation,
		|	SUM(НормативыРабот.Продолжительность) AS Продолжительность,
		|	SUM(НормативыРабот.RoomSpace) AS RoomSpace
		|FROM
		|	InformationRegister.НормативыРабот AS НормативыРабот
		|WHERE
		|	НормативыРабот.Operation = &qOperation
		|	AND НормативыРабот.Гостиница = &qHotel
		|	AND НормативыРабот.НомерРазмещения = &qRoom
		|GROUP BY
		|	НормативыРабот.Operation";
		vQry.SetParameter("qOperation", Ref);
		vQry.SetParameter("qHotel", pHotel);
		vQry.SetParameter("qRoom", pRoom);
		vStds = vQry.Execute().Unload();
	EndIf;
	
	// Run query to get data for the ГруппаНомеров type
	If vStds.Count() = 0 And ЗначениеЗаполнено(pRoomType) Тогда
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	НормативыРабот.Operation,
		|	SUM(НормативыРабот.Продолжительность) AS Продолжительность,
		|	SUM(НормативыРабот.RoomSpace) AS RoomSpace
		|FROM
		|	InformationRegister.НормативыРабот AS НормативыРабот
		|WHERE
		|	НормативыРабот.Operation = &qOperation
		|	AND НормативыРабот.Гостиница = &qHotel
		|	AND НормативыРабот.ТипНомера = &qRoomType
		|GROUP BY
		|	НормативыРабот.Operation";
		vQry.SetParameter("qOperation", Ref);
		vQry.SetParameter("qHotel", pHotel);
		vQry.SetParameter("qRoomType", pRoomType);
		vStds = vQry.Execute().Unload();
	EndIf;
	
	// Run query to get data for the empty ГруппаНомеров and ГруппаНомеров type
	If vStds.Count() = 0 Тогда
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	НормативыРабот.Operation,
		|	SUM(НормативыРабот.Продолжительность) AS Продолжительность,
		|	SUM(НормативыРабот.RoomSpace) AS RoomSpace
		|FROM
		|	InformationRegister.НормативыРабот AS НормативыРабот
		|WHERE
		|	НормативыРабот.Operation = &qOperation
		|	AND НормативыРабот.Гостиница = &qHotel
		|	AND НормативыРабот.ТипНомера = &qRoomType
		|GROUP BY
		|	НормативыРабот.Operation";
		vQry.SetParameter("qOperation", Ref);
		vQry.SetParameter("qHotel", pHotel);
		vQry.SetParameter("qRoomType", Справочники.ТипыНомеров.EmptyRef());
		vQry.SetParameter("qRoom", Справочники.НомернойФонд.EmptyRef());
		vStds = vQry.Execute().Unload();
	EndIf;
	
	// Run query to get data for the empty hotel, ГруппаНомеров and ГруппаНомеров type
	If vStds.Count() = 0 Тогда
		vQry = New Query;
		vQry.Text = 
		"SELECT
		|	НормативыРабот.Operation,
		|	SUM(НормативыРабот.Продолжительность) AS Продолжительность,
		|	SUM(НормативыРабот.RoomSpace) AS RoomSpace
		|FROM
		|	InformationRegister.НормативыРабот AS НормативыРабот
		|WHERE
		|	НормативыРабот.Operation = &qOperation
		|	AND НормативыРабот.Гостиница = &qHotel
		|	AND НормативыРабот.ТипНомера = &qRoomType
		|GROUP BY
		|	НормативыРабот.Operation";
		vQry.SetParameter("qOperation", Ref);
		vQry.SetParameter("qHotel", Справочники.Гостиницы.EmptyRef());
		vQry.SetParameter("qRoomType", Справочники.ТипыНомеров.EmptyRef());
		vQry.SetParameter("qRoom", Справочники.НомернойФонд.EmptyRef());
		vStds = vQry.Execute().Unload();
	EndIf;
	
	Return vStds;
EndFunction //pmGetOperationStandards
