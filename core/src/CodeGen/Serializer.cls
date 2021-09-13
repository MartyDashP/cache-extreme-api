Include ExtremeAPI.general

Class ExtremeAPI.CodeGen.Serializer Extends %RegisteredObject
{

Parameter SerializerClassName = {..%ClassName(1)};

ClassMethod Generate() As %Status
{
	#dim %code as %Stream.MethodGenerator
	#dim %compiledclass as %Dictionary.CompiledClass

    $$$CollectSortedClassProperties(.properties, %compiledclass)

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
	 	
	 	if $$$IsCollectionProperty(property)
	 	{
		 	d %code.WriteLine("	if m%"_property.Name_" { s "_arg_" = "_serializeCode_" }")
	 	}
	 	elseif $$$IsSupportedObjectTypeProperty(property)
	 	{
		 	d %code.WriteLine("	if $ISOBJECT(.."_property.Name_") { s "_arg_" = "_serializeCode_" }")
	 	}
	 	elseif $$$IsDataTypeProperty(property)
	 	{
		 	d %code.WriteLine("	if (i%"_property.Name_" '= """") { s "_arg_" = "_serializeCode_" }")
	 	}
 	}
 	
	d %code.Write("	ret $lb("_$lts(args)_")")
 	
 	ret $$$OK
}

ClassMethod GetTypeSerializationCode(property As %Dictionary.CompiledProperty) As %String
{
	if $$$IsCollectionProperty(property)
	{
		s args = args _ $lb("""SerializeCollectionList""")
	}
	
	s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(property.Type)
	
	if $$$IsSupportedObjectTypeProperty(property)
	{
		s args = args _ $lb("""SerializeObject""")
	} 
	elseif $$$IsDataTypeProperty(property)
	{
		s serializeMethodName = $case(property.Type,
			"%Library.String": "SerializeString",
			"%Library.Integer": "SerializeNum",
			"%Library.Numeric": "SerializeNum", 
			: "")
			
		if (serializeMethodName = "")
		{
            $$$ThrowException("Type '"_property.Type_"' is unsupported for Extreme API serialization")
		}
		
		s args = args _ $lb(""""_serializeMethodName_"""")
	}
	
	s args = args _ $lb(".."_property.Name)
	
	ret "##class("""_..#SerializerClassName_""").%Call("_$lts(args)_")"
}

ClassMethod %Call(methodName As %String, args...)
{
	ret $classmethod(..%ClassName(1), methodName, args...)
}

ClassMethod SerializeString(val) [ Internal ]
{
	ret val
}

ClassMethod SerializeNum(val) [ Internal ]
{
	ret +val
}

ClassMethod SerializeObject(val As ExtremeAPI.AbstractDTO) [ Internal ]
{
	ret val.%serializeExtremeApiDTO()
}

ClassMethod SerializeCollectionList(itemSerializer As %String, list As %Collection.AbstractList) [ Internal ]
{
	f
	{
		s collectionItem = list.GetNext(.key)
		q:key=""
		
		k serializedValue
		
		if (itemSerializer = "SerializeString" || collectionItem '= "") 
		{
			s serializedValue = ..%Call(itemSerializer, collectionItem)
		}
		
		s serializedCollection = serializedCollection _ $lb(serializedValue) 
	}	

	s:(serializedCollection = "") serializedCollection = $lb()
	ret serializedCollection
}

}

