Include ExtremeAPI.general

Class ExtremeAPI.Generator.Deserializer Extends %RegisteredObject
{

Parameter DeserializerClassName = {..%ClassName(1)};

ClassMethod Generate() As %Status
{
	$$$CollectSortedClassProperties(.properties, %compiledclass)
	
	s dObjName = "dObj"
	s sObjName = "sObj"
	
	d %code.WriteLine("	s "_dObjName_" = ..%New()")
	
	f i=1:1 {
		s key = $order(properties(key))
	 	q:key=""
	 	
	 	#dim property as %Dictionary.CompiledProperty
	 	s property = properties(key)
	 	
	 	s propertyName = property.Name
	 	s propertyType = property.Type
	 	s collectionType = ""
		s:$$$IsCollectionProperty(property) collectionType = property.RuntimeType
		
		s source = "$lg("_sObjName_","_i_")"
	 	s target = dObjName_"."_propertyName
	 	
	 	d %code.WriteLine(..GetBlockCode(source, target, propertyType, collectionType))
	}
	
	d %code.WriteLine("	ret "_dObjName)
		
	ret $$$OK
}

ClassMethod GetBlockCode(source As %String, target As %String, type As %String, collectionType As %String)
{
	s cb = "	if ("_source_" '= """") { "
	s cb = cb_"s "_target_" = "_..GetDeserializationBlockCode(source, type, collectionType)
	s cb = cb_" }"
	
	ret cb
}

ClassMethod GetDeserializationBlockCode(varName As %String, type As %String, collectionType As %String) As %String
{
	s args = $lb(varName)

	if (collectionType '= "")
	{
		s collectionType = $case(collectionType, 
			"%Collection.ListOfDT": ##class(%Library.ListOfDataTypes).%ClassName(1),
			##class(%Library.ListOfDataTypes).%ClassName(1): ##class(%Library.ListOfDataTypes).%ClassName(1),
			"%Collection.ListOfObj": ##class(%Library.ListOfObjects).%ClassName(1),
			##class(%Library.ListOfObjects).%ClassName(1): ##class(%Library.ListOfObjects).%ClassName(1),
			:"")
			
		if (collectionType = "")
		{
            $$$ThrowException("Extreme API unsupported collection type '"_type_"'")
		}
		
		s args = args_$lb($$$Wrap($$$GetMethodName(..DeserializeCollection)), $$$Wrap(collectionType))
	}
	
	if $$$IsSupportedObjectType(type)
	{
		s args = args_$lb($$$Wrap($$$GetMethodName(..DeserializeObject)),$$$Wrap(type))
	}
	elseif $$$IsListType(type)
	{
		s args = args_$lb($$$Wrap($$$GetMethodName(..DeserializePrimitive)))
	}
	elseif $$$IsDataType(type)
	{
		s deserializeMethodName = $case(type,
			"%Library.String": $$$GetMethodName(..DeserializePrimitive),
			"%Library.Integer": $$$GetMethodName(..DeserializePrimitive),
			"%Library.Numeric": $$$GetMethodName(..DeserializePrimitive), 
			: "")
			
		if (deserializeMethodName = "")
		{
            $$$ThrowException("Extreme API unsupported type '"_type_"'")
		}
		
		s args = args_$lb($$$Wrap(deserializeMethodName))
	}
	else
	{
		$$$ThrowException("Extreme API unsupported type '"_type_"'")
	}
	
	ret "##class("_..#DeserializerClassName_").%Call("_$lts(args)_")"
}

ClassMethod %Call(val, methodName As %String, args...)
{
	ret $classmethod(..%ClassName(1), methodName, val, args...)
}

ClassMethod DeserializePrimitive(val) [ Internal ]
{
	ret val
}

ClassMethod DeserializeObject(val As ExtremeAPI.AbstractDTO, className As %String) [ Internal ]
{
	ret $classmethod(className, "%DeserializeExtremeApiDTO", val)
}

ClassMethod DeserializeCollection(val As %List, collectionClassName As %String, itemDeserializer As %String, args...) As %ListOfObjects [ Internal ]
{
	s resultList = $classmethod(collectionClassName,"%New")
	
	s col = ##class(%Collection.ListOfDT).%New()
	
	f i=1:1:$ll(val)
	{
		s item = $lg(val,i)
		s result = ..%Call(item,itemDeserializer,args...)
		$$$TOE(sc,resultList.Insert(result)) 
	}	
	
	ret resultList
}

}

