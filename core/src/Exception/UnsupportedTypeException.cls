Class ExtremeAPI.Exception.UnsupportedTypeException Extends %Exception.General
{

Method %OnNew(type As %String) As %Status [ Private ]
{
	s cause = "Extreme API unsupported type '"_type_"'"
	ret ##super("<UNSUPPORTED_TYPE>", "", "", cause, "")
}

}

