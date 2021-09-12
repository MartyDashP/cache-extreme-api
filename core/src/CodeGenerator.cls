Class ExtremeAPI.CodeGenerator Extends %RegisteredObject
{

ClassMethod GenerateSerializer() As %Status
{
	#dim %code as %Stream.MethodGenerator
	#dim %compiledclass as %Dictionary.CompiledClass
		
	d ##class(ExtremeAPI.CommonUtil).CollectClassProperties(.properties, %compiledclass)
	
	s argCounter = 0
	
	f {
		s key = $order(properties(key))
	 	q:key=""
	 	
	 	s argCounter = argCounter + 1
	 	s arg = "arg"_argCounter
	 	s args = args _ $lb(arg)
	 	
	 	#dim property as %Dictionary.CompiledProperty
	 	s property = properties(key)
	 	
	 	s serializeCode = ..GetTypeSerializationCode(property)
	 	
	 	if ##class(ExtremeAPI.CommonUtil).IsCollectionProperty(property)
	 	{
		 	d %code.WriteLine("	if m%"_property.Name_" { s "_arg_" = "_serializeCode_" }")
	 	}
	 	elseif ##class(ExtremeAPI.CommonUtil).IsObject(property)
	 	{
		 	d %code.WriteLine("	if $ISOBJECT(.."_property.Name_") { s "_arg_" = "_serializeCode_" }")
	 	}
	 	elseif ##class(ExtremeAPI.CommonUtil).IsDataTypeProperty(property)
	 	{
		 	d %code.WriteLine("	if (i%"_property.Name_" '= """") { s "_arg_" = "_serializeCode_" }")
	 	}
 	}
 	
	d %code.Write("	ret $lb("_$lts(args)_")")
 	
 	ret $$$OK
}

ClassMethod GetTypeSerializationCode(property As %Dictionary.CompiledProperty) As %String
{
	if ##class(ExtremeAPI.CommonUtil).IsCollectionProperty(property)
	{
		s args = args _ $lb("""SerializeCollectionList""")
	}
	
	s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(property.Type)
	
	if ##class(ExtremeAPI.CommonUtil).IsObject(property)
	{
		s args = args _ $lb("""SerializeObject""")
	} 
	elseif ##class(ExtremeAPI.CommonUtil).IsDataTypeProperty(property)
	{
		s serializeMethodName = $case(property.Type,
			"%Library.String": "SerializeString",
			"%Library.Integer": "SerializeNum",
			"%Library.Numeric": "SerializeNum", 
			: "")
			
		if (serializeMethodName = "")
		{
			throw ##class(%Exception.General).%New(
				"Unsupported serialization type",
				"XEP_BOOST_UNSUPPORTED_TYPE",
				"Type '"_property.Type_"' in unsupported for xep boost serialization")
		}
		
		s args = args _ $lb(""""_serializeMethodName_"""")
	}
	
	s args = args _ $lb(".."_property.Name)
	
	ret "##class(""ExtremeAPI.Converter"").%Call("_$lts(args)_")"
}

ClassMethod GenerateDeserializer() As %Status
{
	#dim %code as %Stream.MethodGenerator
	#dim %compiledclass as %Dictionary.CompiledClass
	
	d %code.WriteLine("	s xepBoostObj = ..%New()")
		
	d ##class(ExtremeAPI.CommonUtil).CollectClassProperties(.properties, %compiledclass)
	
	s argCounter = 0
	
	f {
		s key = $order(properties(key))
	 	q:key=""
	 	
	 	s argCounter = argCounter + 1
	 	
	 	d %code.WriteLine("	if $ld(serializedValue,"_argCounter_") {")
	 	
	 	s arg = "arg"_argCounter
	 	s args = args _ $lb(arg)
	 	
	 	#dim property as %Dictionary.CompiledProperty
	 	s property = properties(key)
	}
	
	d %code.WriteLine("	ret xepBoostObj")
		
	ret $$$OK
}

}
