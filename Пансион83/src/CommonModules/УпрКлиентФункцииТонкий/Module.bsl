//-----------------------------------------------------------------------------
// Returns type Number(17, 2)
//-----------------------------------------------------------------------------
Function cmGetSumTypeDescriptionOnClient() Экспорт
	vNQ = New NumberQualifiers(17, 2);
	vTA = New Array;
	vTA.Add(Type("Number"));
	vTypeDescr = New TypeDescription(vTA, vNQ);
	Return vTypeDescr;
EndFunction //cmGetSumTypeDescriptionOnClient



