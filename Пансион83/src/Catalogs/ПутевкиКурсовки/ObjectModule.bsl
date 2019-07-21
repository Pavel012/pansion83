//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		If ЗначениеЗаполнено(RoomQuota) Тогда
			Гостиница = RoomQuota.Гостиница;
		Else
			Гостиница = ПараметрыСеанса.ТекущаяГостиница;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(Currency) Тогда
		If ЗначениеЗаполнено(Гостиница) Тогда
			Currency = Гостиница.FolioCurrency;
		EndIf;
	EndIf;
	If НЕ IsFolder Тогда
		If НЕ ЗначениеЗаполнено(CreateDate) Тогда
			CreateDate = CurrentDate();
			Author = ПараметрыСеанса.ТекПользователь;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetDefaultDescription() Экспорт
	vDescription = ?(ЗначениеЗаполнено(RoomQuota), СокрЛП(RoomQuota.Code) + " - ", "") + 
	               ?(ЗначениеЗаполнено(RoomType), СокрЛП(RoomType.Code) + " ", "") + 
	               Format(CheckInDate, "DF='dd.MM.yy HH:mm'") + " - " + 
	               Format(CheckOutDate, "DF='dd.MM.yy HH:mm'");
	Return vDescription;
EndFunction //pmGetDefaultDescription

//-----------------------------------------------------------------------------
Function pmGetDefaultCode() Экспорт
	vCode = ?(ЗначениеЗаполнено(RoomQuota), СокрЛП(RoomQuota.Code) + "-", "") + 
	        ?(ЗначениеЗаполнено(RoomType), СокрЛП(RoomType.Code) + "-", "") + 
	        Format(Year(CheckInDate) * 1000 + DayOfYear(CheckInDate), "ND=7; NFD=0; NZ=; NG=");
	Return vCode;
EndFunction //pmGetDefaultCode

//-----------------------------------------------------------------------------
Function pmCheckHotelProductAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	If IsBlankString(Code) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Код> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Code> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Code", pAttributeInErr);
	EndIf;
	If IsBlankString(Description) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Наименование> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Description> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Description", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
	EndIf;
	If ЗначениеЗаполнено(CheckInDate) And ЗначениеЗаполнено(CheckOutDate) And
	   CheckOutDate <= CheckInDate Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Дата выезда> должен быть позже даты заезда!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Check-out date> attribute should be filled and after check-in date!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ДатаВыезда", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckHotelProductAttributes

//-----------------------------------------------------------------------------
// Calculates and returns duration for giving check in and check out dates
//-----------------------------------------------------------------------------
Function pmCalculateDuration() Экспорт
	vDuration = 0;
	If ЗначениеЗаполнено(CheckInDate) And
	   ЗначениеЗаполнено(CheckOutDate) Тогда
		vReferenceHour = 0;
		vDurationCalculationRuleType = Неопределено;
		vPeriodInHours = 24;
		If ЗначениеЗаполнено(Parent) Тогда
			vDurationCalculationRuleType = Parent.DurationCalculationRuleType;
			vReferenceHour = Parent.ReferenceHour - BegOfDay(Parent.ReferenceHour);
		EndIf;
		If vDurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour And 
		   vReferenceHour = 0 Тогда
			vPerInSec = EndOfDay(CheckOutDate) - BegOfDay(CheckInDate);
			vDuration = Round(vPerInSec/vPeriodInHours/3600, 0);
		ElsIf vDurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
			vPerInSec = (BegOfDay(CheckOutDate) + vReferenceHour) - (BegOfDay(CheckInDate) + vReferenceHour);
			vDuration = Round(vPerInSec/vPeriodInHours/3600, 0);
		ElsIf vDurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
			vPerInSec = EndOfDay(CheckOutDate) - BegOfDay(CheckInDate);
			vDuration = Round(vPerInSec/vPeriodInHours/3600, 0);
		ElsIf vDurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
			vPerInSec = CheckOutDate - CheckInDate;
			vDuration = Round(vPerInSec/vPeriodInHours/3600, 0);
		Else
			vPerInSec = CheckOutDate - CheckInDate;
			vDuration = Round(vPerInSec/vPeriodInHours/3600, 0);
		EndIf;
	EndIf;
	Return vDuration;
EndFunction //pmCalculateDuration

//-----------------------------------------------------------------------------
// Calculates and returns check out date based on giving duration and check in date
//-----------------------------------------------------------------------------
Function pmCalculateCheckOutDate() Экспорт
	vCheckOutDate = CheckOutDate;
	If ЗначениеЗаполнено(CheckInDate) And Duration > 0 Тогда
		vReferenceHour = 0;
		vDurationCalculationRuleType = Неопределено;
		vPeriodInHours = 24;
		If ЗначениеЗаполнено(Parent) Тогда
			vDurationCalculationRuleType = Parent.DurationCalculationRuleType;
			vReferenceHour = Parent.ReferenceHour - BegOfDay(Parent.ReferenceHour);
		EndIf;
		If vDurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
			If vReferenceHour = 0 Тогда
				vCheckOutDate = BegOfDay(CheckInDate) + vReferenceHour + Duration * vPeriodInHours * 3600 - 1;
			Else
				vCheckOutDate = BegOfDay(CheckInDate) + vReferenceHour + Duration * vPeriodInHours * 3600;
			EndIf;
		ElsIf vDurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
			vCheckOutDate = BegOfDay(CheckInDate) + Duration * vPeriodInHours * 3600 - 3 * 3600;
		ElsIf vDurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByNights Тогда
			vCheckInTime = CheckInDate - BegOfDay(CheckInDate);
			If vCheckInTime <= 9*3600 Тогда // Breakfast check-in
				vCheckOutDate = BegOfDay(CheckInDate) + Duration * vPeriodInHours * 3600 + 7 * 3600;
			ElsIf vCheckInTime <= 14*3600 Тогда // Lunch check-in
				vCheckOutDate = BegOfDay(CheckInDate) + Duration * vPeriodInHours * 3600 + 12 * 3600;
			ElsIf vCheckInTime <= 20*3600 Тогда // Supper check-in
				vCheckOutDate = BegOfDay(CheckInDate) + Duration * vPeriodInHours * 3600 + 18 * 3600;
			Else  // Late check-in
				vCheckOutDate = BegOfDay(CheckInDate) + Duration * vPeriodInHours * 3600 + 21 * 3600;
			EndIf;
		
		EndIf;
	EndIf;
	Return vCheckOutDate;
EndFunction //pmCalculateDateTo

//-----------------------------------------------------------------------------
Function pmGetHotelProductDocuments() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Размещение.Ref AS Document,
	|	Размещение.Контрагент,
	|	Размещение.Договор,
	|	Размещение.ГруппаГостей,
	|	Размещение.CheckInDate,
	|	Размещение.Продолжительность,
	|	Размещение.ДатаВыезда,
	|	Размещение.ТипНомера,
	|	Размещение.НомерРазмещения,
	|	Размещение.Клиент,
	|	Размещение.PointInTime AS PointInTime,
	|	4 AS Priority
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Posted
	|	AND Размещение.СтатусРазмещения.IsActive
	|	AND Размещение.ПутевкаКурсовка = &qHotelProduct
	|
	|UNION ALL
	|
	|SELECT
	|	СчетПроживания.Ref,
	|	СчетПроживания.Контрагент,
	|	СчетПроживания.Договор,
	|	СчетПроживания.ГруппаГостей,
	|	СчетПроживания.DateTimeFrom,
	|	0,
	|	СчетПроживания.DateTimeTo,
	|	СчетПроживания.НомерРазмещения.ТипНомера,
	|	СчетПроживания.НомерРазмещения,
	|	СчетПроживания.Клиент,
	|	СчетПроживания.PointInTime,
	|	3
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	СчетПроживания.ПутевкаКурсовка = &qHotelProduct
	|
	|UNION ALL
	|
	|SELECT
	|	Бронирование.Ref,
	|	Бронирование.Контрагент,
	|	Бронирование.Договор,
	|	Бронирование.ГруппаГостей,
	|	Бронирование.CheckInDate,
	|	Бронирование.Продолжительность,
	|	Бронирование.ДатаВыезда,
	|	Бронирование.ТипНомера,
	|	Бронирование.НомерРазмещения,
	|	Бронирование.Клиент,
	|	Бронирование.PointInTime,
	|	2
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.Posted
	|	AND Бронирование.ПутевкаКурсовка = &qHotelProduct
	|
	|UNION ALL
	|
	|SELECT
	|	Начисление.СчетПроживания,
	|	Начисление.СчетПроживания.Контрагент,
	|	Начисление.СчетПроживания.Договор,
	|	Начисление.СчетПроживания.ГруппаГостей,
	|	Начисление.СчетПроживания.DateTimeFrom,
	|	0,
	|	Начисление.СчетПроживания.DateTimeTo,
	|	Начисление.СчетПроживания.НомерРазмещения.ТипНомера,
	|	Начисление.СчетПроживания.НомерРазмещения,
	|	Начисление.СчетПроживания.Клиент,
	|	Начисление.PointInTime,
	|	1
	|FROM
	|	Document.Начисление AS Начисление
	|WHERE
	|	Начисление.Posted
	|	AND Начисление.ПутевкаКурсовка = &qHotelProduct
	|
	|ORDER BY
	|	Priority,
	|	PointInTime";
	vQry.SetParameter("qHotelProduct", Ref);
	Return vQry.Execute().Unload();
EndFunction //pmGetHotelProductDocuments

//-----------------------------------------------------------------------------
Function pmGetHotelProductAmount() Экспорт
	vAmount = 0;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	HotelProductSalesTurnovers.ПутевкаКурсовка,
	|	HotelProductSalesTurnovers.SalesTurnover AS Amount
	|FROM
	|	AccumulationRegister.ПродажиПутевокКурсовок.Turnovers(, , Period, ПутевкаКурсовка = &qHotelProduct) AS HotelProductSalesTurnovers";
	vQry.SetParameter("qHotelProduct", Ref);
	vRes = vQry.Execute().Unload();
	For Each vResRow In vRes Do
		vAmount = vAmount + vResRow.Amount;
	EndDo;
	Return vAmount;
EndFunction //pmGetHotelProductAmount

//-----------------------------------------------------------------------------
Function pmGetHotelProductClient() Экспорт
	vClient = 0;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	HotelProductSalesTurnovers.ПутевкаКурсовка,
	|	HotelProductSalesTurnovers.Клиент,
	|	HotelProductSalesTurnovers.SalesTurnover AS Amount
	|FROM
	|	AccumulationRegister.ПродажиПутевокКурсовок.Turnovers(, , Period, ПутевкаКурсовка = &qHotelProduct) AS HotelProductSalesTurnovers
	|
	|ORDER BY
	|	Amount DESC";
	vQry.SetParameter("qHotelProduct", Ref);
	vRes = vQry.Execute().Unload();
	For Each vResRow In vRes Do
		If ЗначениеЗаполнено(vResRow.Client) Тогда
			vClient = vResRow.Client;
		EndIf;
	EndDo;
	Return vClient;
EndFunction //pmGetHotelProductClient

//-----------------------------------------------------------------------------
Function pmGetHotelProductPaymentDate(rPaymentMethod) Экспорт
	vPaymentDate = '00010101';
	rPaymentMethod = Неопределено;
	vQry = New Query();
	vQry.Text = 
	"SELECT DISTINCT
	|	CASE
	|		WHEN ПродажиПутевокКурсовок.Recorder.СчетПроживания IS NULL 
	|			THEN ПродажиПутевокКурсовок.Recorder.ParentCharge.СчетПроживания
	|		ELSE ПродажиПутевокКурсовок.Recorder.СчетПроживания
	|	END AS СчетПроживания
	|INTO HotelProductFolios
	|FROM
	|	AccumulationRegister.ПродажиПутевокКурсовок AS ПродажиПутевокКурсовок
	|WHERE
	|	ПродажиПутевокКурсовок.ПутевкаКурсовка = &qHotelProduct
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT DISTINCT
	|	DepositTransfers.FolioFrom AS СчетПроживания
	|INTO TransferFolios
	|FROM
	|	Document.ПеремещениеДепозита AS DepositTransfers
	|WHERE
	|	DepositTransfers.Posted
	|	AND DepositTransfers.FolioTo IN
	|			(SELECT
	|				HotelProductFolios.СчетПроживания
	|			FROM
	|				HotelProductFolios AS HotelProductFolios)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	HotelProductFolios.СчетПроживания AS СчетПроживания
	|INTO BoundFolios
	|FROM
	|	HotelProductFolios AS HotelProductFolios
	|
	|UNION ALL
	|
	|SELECT
	|	TransferFolios.СчетПроживания
	|FROM
	|	TransferFolios AS TransferFolios
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Платежи.ДатаДок AS PaymentDate,
	|	Платежи.СпособОплаты AS СпособОплаты
	|FROM
	|	Document.Платеж AS Платежи
	|WHERE
	|	Платежи.Posted
	|	AND Платежи.СчетПроживания IN
	|			(SELECT
	|				BoundFolios.СчетПроживания
	|			FROM
	|				BoundFolios AS BoundFolios)
	|
	|ORDER BY
	|	PaymentDate DESC";
	vQry.SetParameter("qHotelProduct", Ref);
	vRes = vQry.Execute().Unload();
	For Each vResRow In vRes Do
		vPaymentDate = vResRow.PaymentDate;
		rPaymentMethod = vResRow.PaymentMethod;
		Break;
	EndDo;
	Return vPaymentDate;
EndFunction //pmGetHotelProductPaymentDate

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	// Clear product code and description
	If НЕ IsFolder Тогда
		Code = "";
		Description = "";
		ExternalCode = "";
		CreateDate = CurrentDate();
		Author = ПараметрыСеанса.ТекПользователь;
	EndIf;
КонецПроцедуры //OnCopy

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If НЕ IsFolder Тогда
		// Deletion mark date and author
		If НЕ DeletionMark Тогда
			If ЗначениеЗаполнено(DeletionMarkDate) Тогда
				DeletionMarkDate = Неопределено;
			EndIf;
			If ЗначениеЗаполнено(DeletionMarkAuthor) Тогда
				DeletionMarkAuthor = Справочники.Сотрудники.EmptyRef();
			EndIf;
		Else
			If НЕ ЗначениеЗаполнено(DeletionMarkDate) Тогда
				DeletionMarkDate = CurrentDate();
			EndIf;
			If НЕ ЗначениеЗаполнено(DeletionMarkAuthor) Тогда
				DeletionMarkAuthor = ПараметрыСеанса.ТекПользователь;
			EndIf;
		EndIf;
		// Payment date
		If НЕ ЗначениеЗаполнено(PaymentDate) Тогда
			vPaymentMethod = Неопределено;
			PaymentDate = pmGetHotelProductPaymentDate(vPaymentMethod);
			If ЗначениеЗаполнено(vPaymentMethod) Тогда
				PaymentMethod = vPaymentMethod;
			EndIf;
		EndIf;
		// Client
		
	EndIf;
КонецПроцедуры //BeforeWrite
