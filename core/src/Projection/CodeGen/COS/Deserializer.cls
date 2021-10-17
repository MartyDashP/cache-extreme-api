Include JetAPI.general

Class JetAPI.Projection.CodeGen.COS.Deserializer Extends %RegisteredObject
{

ClassMethod GetDeserializationScriptDTO(compClass As %Dictionary.CompiledClass) As %String
{
	d ##class(JetAPI.Reflection.Property).CollectByClass(compClass, .properties)
	
	s dObjName = "dObj"
	s sObjName = "sObj"
	s script = "	s "_dObjName_" = ..%New()"_$$$CRLF
	
	f i=1:1 {
		s key = $order(properties(key))
	 	q:key=""
	 	
	 	#dim property as %Dictionary.CompiledProperty
	 	s property = properties(key)
	 	
	 	#dim source as JetAPI.Reflection.Model.Attribute
	 	s source = ##class(JetAPI.Reflection.Property).GetAttributeInfo(property)
	 	s source.Alias = "$lg("_sObjName_","_i_")"
	 	
	 	#dim target as JetAPI.Reflection.Model.Attribute
	 	s target = ##class(JetAPI.Reflection.Property).GetAttributeInfo(property)
	 	s target.Alias = dObjName_"."_target.Name
	 	
	 	s script = script_..GetCodeParameterDeserialization(source, target)_$$$CRLF
	}
	
	s script = script_"	ret "_dObjName_$$$CRLF
	ret script
}

ClassMethod GetCodeParameterDeserialization(source As JetAPI.Reflection.Model.Attribute, target As JetAPI.Reflection.Model.Attribute) As %String
{
	s args = $lb(source.Alias)
	
	if target.IsList()
	{
		s targetListType = $case(target.CollectionType, 
			##class(%Collection.ListOfDT).%ClassName(1): 		##class(%Library.ListOfDataTypes).%ClassName(1),
			##class(%Library.ListOfDataTypes).%ClassName(1): 	##class(%Library.ListOfDataTypes).%ClassName(1),
			##class(%Collection.ListOfObj).%ClassName(1): 		##class(%Library.ListOfObjects).%ClassName(1),
			##class(%Library.ListOfObjects).%ClassName(1): 		##class(%Library.ListOfObjects).%ClassName(1))
			
		s args = args _ $lb("""DeserializeCollection""", """"_targetListType_"""")
	}
	
	if target.IsJetApiDTO()
	{
		s args = args _ $lb("""DeserializeObject""", """"_target.ElementType_"""")
	}
	elseif target.IsLB()
	{
		s args = args _ $lb("""DeserializePrimitive""")
	}
	elseif target.IsDataType()
	{
		s methodName = $case(target.ElementType,
			##class(JetAPI.Reflection.Type.COS).#String: "DeserializePrimitive",
			##class(JetAPI.Reflection.Type.COS).#Integer: "DeserializePrimitive",
			##class(JetAPI.Reflection.Type.COS).#Numeric: "DeserializePrimitive")
			
		s args = args _ $lb(""""_methodName_"""")
	}
	else
 	{
	 	throw ##class(JetAPI.Exception.UnsupportedTypeException).Create(target)
 	}
 	
 	s deserializerClassName = ##class(JetAPI.Projection.CodeGen.COS.Deserializer).%ClassName(1)
 	
 	ret "	if ("_source.Alias_" '= """") {"
 		_" s "_target.Alias_" = ##class("_deserializerClassName_").%Call("_$lts(args)_")"
		_" }"
}

}

