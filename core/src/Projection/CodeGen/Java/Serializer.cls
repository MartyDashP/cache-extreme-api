Include JetAPI.general

Class JetAPI.Projection.CodeGen.Java.Serializer Extends %RegisteredObject
{

ClassMethod GetSerializationScript(serVarName As %String, ByRef compProperties) As %String
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
	 	
	 	s script = script_..GetCodeParameterSerialization(serVarName, propInfo)_";"_$$$CRLF
	}
	
	ret script
}

ClassMethod GetCodeParameterSerialization(serVarName As %String, attrInfo As JetAPI.Reflection.Model.Attribute) As %String
{
	if attrInfo.IsList()
	{
		#dim subAttrInfo as JetAPI.Reflection.Model.Attribute
		s subAttrInfo = attrInfo.Clone()
		s subAttrInfo.Alias = "v"
		s subAttrInfo.CollectionType = ""
		s subSerVarName = "s"
		
		s lambdaFunc = "("_subSerVarName_", "_subAttrInfo.Alias_") -> "_..GetCodeParameterSerialization(subSerVarName, subAttrInfo)
		ret serVarName_".setList("_attrInfo.Alias_", "_lambdaFunc_")"
	}
	
	if attrInfo.IsJetApiDTO()
	{
		ret serVarName_".setObject("_attrInfo.Alias_")"
	}
	elseif attrInfo.IsDataType()
	{		
		ret serVarName_".setValue("_attrInfo.Alias_")"
	}
	
	throw ##class(JetAPI.Exception.UnsupportedTypeException).Create(attrInfo)
}

ClassMethod GetCodeParameterStaticSerialization(connVarName As %String, desInfo As JetAPI.Reflection.Model.Attribute, serInfo As JetAPI.Reflection.Model.Attribute) As %String
{
	s code = "final byte[] "_serInfo.Alias_" = "
	
	if desInfo.IsList()
	{
		#dim subAttrInfo as JetAPI.Reflection.Model.Attribute
		s subAttrInfo = desInfo.Clone()
		s subAttrInfo.Alias = "v"
		s subAttrInfo.CollectionType = ""
		s subSerVarName = "s"
		
		s lambdaFunc = "("_subSerVarName_", "_subAttrInfo.Alias_") -> "_..GetCodeParameterSerialization(subSerVarName, subAttrInfo)
		ret code_"serializeList("_connVarName_", "_desInfo.Alias_", "_lambdaFunc_");"
	}
	
	if desInfo.IsJetApiDTO()
	{
		ret code_"serializeObject("_connVarName_", "_desInfo.Alias_");"
	}
	
	throw ##class(JetAPI.Exception.UnsupportedTypeException).Create(desInfo)
}

}

