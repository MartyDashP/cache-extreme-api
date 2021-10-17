Class JetAPI.Converter.Serializer Extends %RegisteredObject
{

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

ClassMethod SerializeObject(val As JetAPI.DTO.Abstract) [ Internal ]
{
	ret val.%jetApiSerializeDTO()
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

