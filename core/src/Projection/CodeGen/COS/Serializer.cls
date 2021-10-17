Include JetAPI.general

Class JetAPI.Projection.CodeGen.COS.Serializer Extends %RegisteredObject
{

ClassMethod GetSerializationScriptDTO(compClass As %Dictionary.CompiledClass) As %String
{
	d ##class(JetAPI.Reflection.Property).CollectByClass(compClass, .properties)
	s script = ""
	s targetParams = ""
	
	f {
		s key = $order(properties(key))
	 	q:key=""
	 	
	 	#dim property as %Dictionary.CompiledProperty
	 	s property = properties(key)
	 	
	 	#dim target as JetAPI.Reflection.Model.Attribute
	 	s target = ##class(JetAPI.Reflection.Property).GetAttributeInfo(property)
	 	s target.Alias = "s0"_property.Name
	 	s targetParams = targetParams _ $lb(target.Alias)
	 	
	 	#dim source as JetAPI.Reflection.Model.Attribute
	 	s source = ##class(JetAPI.Reflection.Property).GetAttributeInfo(property)
	 	s source.Alias = ".."_property.Name
	 
		s script = script_..GetCodeParameterSerialization(source, target)_$$$CRLF
 	}
	
	s script = script_"	ret $lb("_$lts(targetParams)_")"_$$$CRLF
	ret script
}

ClassMethod GetCodeParameterSerialization(source As JetAPI.Reflection.Model.Attribute, target As JetAPI.Reflection.Model.Attribute) As %String
{
	s args = ""
	
	if source.IsList()
	{
		s methodName = "SerializeCollectionList"
 		s args = args _ $lb(""""_methodName_"""")
	}
 	
 	if source.IsJetApiDTO()
 	{
	 	s methodName = "SerializeObject"
	 	s args = args _ $lb(""""_methodName_"""")
 	}
 	elseif source.IsLB()
 	{
	 	s methodName = "SerializeList"
		s args = args _ $lb(""""_methodName_"""")
 	}
 	elseif source.IsDataType()
 	{
	 	s methodName = $case(source.ElementType,
 			##class(JetAPI.Reflection.Type.COS).#String: "SerializeString",
 			##class(JetAPI.Reflection.Type.COS).#Integer: "SerializeNum",
 			##class(JetAPI.Reflection.Type.COS).#Numeric: "SerializeNum")
 			
 		s args = args _ $lb(""""_methodName_"""")
 	}
 	else
 	{
	 	throw ##class(JetAPI.Exception.UnsupportedTypeException).Create(attr)
 	}
		
	if (##class(JetAPI.Reflection.Type.COS).IsList(source) 
	|| ##class(JetAPI.Reflection.Type.COS).IsJetApiDto(source.ElementType))
	{
		s condition = "$isobject("_source.Alias_")"
	}
	elseif (##class(JetAPI.Reflection.Type.COS).IsDataType(source.ElementType)
	|| ##class(JetAPI.Reflection.Type.COS).IsLB(source.ElementType))
	{
		s condition = "("_source.Alias_" '= """")"
	}
	else
	{
		throw ##class(JetAPI.Exception.UnsupportedTypeException).Create(source)
	}
	
	s args = args _ $lb(source.Alias)
	
 	ret "	if "_condition_" {"
 		_" s "_target.Alias_" = ##class("_##class(JetAPI.Converter.Serializer).%ClassName(1)_").%Call("_$lts(args)_")"
 		_" }"
}

}

