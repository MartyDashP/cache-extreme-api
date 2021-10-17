Include JetAPI.general

Class JetAPI.Projection.CodeGen.Java.Deserializer Extends %RegisteredObject
{

ClassMethod GetDeserializationScript(desVarName As %String, ByRef compProperties) As %String
{
	s script = ""
	
	f {
		s key = $order(compProperties(key))
	 	q:key=""
	 	
	 	#dim compProperty as %Dictionary.CompiledProperty
	 	s compProperty = compProperties(key)
	 	
	 	#dim propInfo as JetAPI.Reflection.Model.Attribute
	 	s propInfo = ##class(JetAPI.Reflection.Property).GetAttributeInfo(compProperty)
	 	s propInfo.Alias = "this."_propInfo.Name
	 	
	 	s script = script_propInfo.Alias_" = "_..GetCodeParameterDeserialization(desVarName, propInfo)_";"_$$$CRLF
	}
	
	ret script
}

ClassMethod GetCodeParameterDeserialization(desVarName As %String, attrInfo As JetAPI.Reflection.Model.Attribute) As %String
{
	if attrInfo.IsList()
	{
		#dim subAttrInfo as JetAPI.Reflection.Model.Attribute
		s subAttrInfo = attrInfo.Clone()
		s subAttrInfo.CollectionType = ""
		s subDesVarName = "_"_desVarName
		ret desVarName_".getList("_subDesVarName_" -> "_..GetCodeParameterDeserialization(subDesVarName, subAttrInfo)_")"
	}
	
	if attrInfo.IsJetApiDTO()
	{
		ret desVarName_".getObject("_attrInfo.ElementType_".class)"
	}
	elseif attrInfo.IsDataType()
	{
		s class = ##class(JetAPI.Reflection.Type.Java).ToJavaClass(attrInfo.ElementType)
		ret desVarName_".getValue("_class_")"
	}
	
	throw ##class(JetAPI.Exception.UnsupportedTypeException).Create(attrInfo)
}

}

