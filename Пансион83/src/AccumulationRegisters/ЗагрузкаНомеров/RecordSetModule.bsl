//-----------------------------------------------------------------------------
Процедура OnWrite(pCancel, pReplacing)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Check if we have to log ГруппаНомеров inventory changes to the change history
	vChangesRcdSet = InformationRegisters.РесурсыНомеров.CreateRecordSet();
	For Each vRIRow In ThisObject Do
		If НЕ vRIRow.IsRoomInventory And 
		   ЗначениеЗаполнено(vRIRow.Гостиница) And vRIRow.Гостиница.EnableRoomInventoryChangeHistoryLogging And 
		   vRIRow.RecordType = AccumulationRecordType.Expense And 
		   ЗначениеЗаполнено(vRIRow.CheckInDate) And ЗначениеЗаполнено(vRIRow.CheckOutDate) And 
		   vRIRow.CheckInDate < vRIRow.CheckOutDate And 
		   (vRIRow.IsReservation Or vRIRow.IsAccommodation Or vRIRow.IsBlocking Or vRIRow.IsRoomQuota) Тогда
		    // Initialize check-in and check-out dates
			vCurDate = BegOfDay(vRIRow.CheckInDate);
			vCheckOutDate = BegOfDay(vRIRow.CheckOutDate);
			// Add records for each date inside period
			While vCurDate <= vCheckOutDate Do
				// Clear recordset and filter from the previous data
				vChangesRcdSet.Clear();
				vChangesRcdSet.Filter.Reset();
				// Set filter to the current data
				vHotelFlt = vChangesRcdSet.Filter.Гостиница;
				vHotelFlt.ComparisonType = ComparisonType.Equal;
				vHotelFlt.Value = vRIRow.Гостиница;
				vHotelFlt.Use = True;
				vRoomQuotaFlt = vChangesRcdSet.Filter.КвотаНомеров;
				vRoomQuotaFlt.ComparisonType = ComparisonType.Equal;
				vRoomQuotaFlt.Value = vRIRow.КвотаНомеров;
				vRoomQuotaFlt.Use = True;
				vRoomTypeFlt = vChangesRcdSet.Filter.ТипНомера;
				vRoomTypeFlt.ComparisonType = ComparisonType.Equal;
				vRoomTypeFlt.Value = vRIRow.ТипНомера;
				vRoomTypeFlt.Use = True;
				vDateFlt = vChangesRcdSet.Filter.ДатаДок;
				vDateFlt.ComparisonType = ComparisonType.Equal;
				vDateFlt.Value = vCurDate;
				vDateFlt.Use = True;
				// Add new record
				vChangesRow = vChangesRcdSet.Add();
				vChangesRow.Гостиница = vRIRow.Гостиница;
				vChangesRow.КвотаНомеров = vRIRow.КвотаНомеров;
				vChangesRow.ТипНомера = vRIRow.ТипНомера;
				vChangesRow.ДатаДок = vCurDate;
				// Write record to the database
				vChangesRcdSet.Write(True);
				// Go to the next date
				vCurDate = vCurDate + 24*3600;
			EndDo;
		EndIf;
	EndDo;
КонецПроцедуры //OnWrite
