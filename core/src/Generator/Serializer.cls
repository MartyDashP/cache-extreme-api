Include ExtremeAPI.general

Class ExtremeAPI.Generator.Serializer Extends %RegisteredObject
{

Parameter SerializerClassName = "ExtremeAPI.Generator.Serializer";

ClassMethod Generate() As %Status
{
	#dim %code as %Stream.MethodGenerator
	#dim %compiledclass as %Dictionary.CompiledClass

    $$$CollectSortedClassProperties(.properties, %compiledclass)

    f {
		s key = $order(properties(key))
	 	q:key=""
	 	
	 	#dim property as %Dictionary.CompiledProperty
	 	s property = properties(key)
	 	
	 	s targetParam = "s0"_property.Name
	 	s targetParams = targetParams _ $lb(targetParam)
	 	
	 	s sourceParam = property.Name
	 	s sourceType = property.Type

	 	if $$$IsCollectionProperty(property)
	 	{
		 	s condition = "m%"_sourceParam
	 	}
	 	elseif $$$IsSupportedObjectTypeProperty(property)
	 	{
		 	s condition = "$ISOBJECT(.."_sourceParam_")"
	 	}
	 	elseif ($$$IsDataTypeProperty(property) || $$$IsListType(sourceType))
	 	{
		 	s condition = "(i%"_sourceParam_" '= """")"
	 	}
	 	else
		{
			throw $$$UnsupportedTypeExeption(type)
		}

	 	s codeBlock = ..GetBlockCode(condition, targetParam, ".."_sourceParam, sourceType, $$$IsCollectionProperty(property))
	 	d %code.WriteLine(codeBlock)
 	}
 	
	d %code.WriteLine("	ret $lb("_$lts(targetParams)_")")
 	
 	ret $$$OK
}

ClassMethod GetBlockCode(condition As %String, target As %String, source As %String, type As %String, isCollection As %Boolean)
{
	s cb = "	if "_condition_" { "
	s cb = cb_"s "_target_" = "_..GetSerializationBlockCode(source, type, isCollection)
	s cb = cb_" }"
	
	ret cb
}

ClassMethod GetSerializationBlockCode(name As %String, type As %String, isCollection As %Boolean) As %String
{
	if isCollection
	{
		s args = args _ $lb($$$Wrap($$$GetMethodName(..SerializeCollectionList)))
	}
	
	s compiledClass = $$$GetCompiledClass(type)
	
	if $$$IsSupportedObjectType(type)
	{
		s args = args _ $lb($$$Wrap($$$GetMethodName(..SerializeObject)))
	} 
	elseif $$$IsListType(type)
	{
		s args = args_$lb($$$Wrap($$$GetMethodName(..SerializeList)))
	}
	elseif $$$IsDataType(type)
	{
		s serializeMethodName = $case(type,
			##class(ExtremeAPI.Util.ObjectScriptType).#StringType: $$$GetMethodName(..SerializeString),
			##class(ExtremeAPI.Util.ObjectScriptType).#IntegerType: $$$GetMethodName(..SerializeNum),
			##class(ExtremeAPI.Util.ObjectScriptType).#NumericType: $$$GetMethodName(..SerializeNum), 
			: "")
			
		throw:(serializeMethodName = "") $$$UnsupportedTypeExeption(type)	
		
		s args = args _ $lb($$$Wrap(serializeMethodName))
	}
	else
	{
		throw $$$UnsupportedTypeExeption(type)
	}
	
	s args = args _ $lb(name)
	
	ret "##class("_..#SerializerClassName_").%Call("_$lts(args)_")"
}

ClassMethod %Call(methodName As %String, args...)
{
	ret $classmethod(..%ClassName(1), methodName, args...)
}

ClassMethod SerializeList(val) [ Internal ]
{
	ret val
}

ClassMethod SerializeString(val) [ Internal ]
{
	ret val
}

ClassMethod SerializeNum(val) [ Internal ]
{
	ret +val
}

ClassMethod SerializeObject(val As ExtremeAPI.DTO.Abstract) [ Internal ]
{
	ret val.%SerializeExtremeApiDTO()
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
