Class JetAPI.Converter.Deserializer Extends %RegisteredObject [ Final ]
{

ClassMethod %Call(val, methodName As %String, args...)
{
	ret $classmethod(..%ClassName(1), methodName, val, args...)
}

ClassMethod DeserializePrimitive(val As %List) [ Internal ]
{
	ret val
}

ClassMethod DeserializeObject(val As JetAPI.DTO.Abstract, className As %String) [ Internal ]
{
	ret $classmethod(className, "%jetApiDeserializeDTO", val)
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

