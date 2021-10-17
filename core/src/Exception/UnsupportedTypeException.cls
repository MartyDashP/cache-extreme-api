Class JetAPI.Exception.UnsupportedTypeException Extends %Exception.General
{

Method %OnNew(info As %String) As %Status [ Private ]
{
	s cause = "Jet API unsupported type '"_info_"'"
	ret ##super("<UNSUPPORTED_TYPE>", "", "", cause, "")
}

ClassMethod Create(attr As JetAPI.Reflection.Model.Attribute)
{
	ret ..%New(attr.ToString())
}

}

