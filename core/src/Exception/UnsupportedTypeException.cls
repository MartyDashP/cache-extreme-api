Class JetAPI.Exception.UnsupportedTypeException Extends %Exception.General
{

ClassMethod Create(attr As JetAPI.Reflection.Model.Attribute)
{
	s cause = "Jet API unsupported type '"_attr.ToString()_"'"
	ret ..%New("<UNSUPPORTED_TYPE>", "", "", cause, "")
}

}

