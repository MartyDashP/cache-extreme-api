Class ExtremeAPI.Converter Extends %RegisteredObject
{

ClassMethod %Call(methodName As %String, args...)
{
	ret $classmethod(##class(ExtremeAPI.Converter).%ClassName(1), methodName, args...)
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
	ret val.%eapiSerializeDTO()
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

ClassMethod Deserialize(val) [ Internal ]
{
	ret val
}

ClassMethod DeserializeObject(className As %String, list As %List) [ Internal ]
{
	ret $classmethod(className, "%deserializeDtoExtremeApi", list)
}

ClassMethod DeserializeCollectionList(itemDerializer As %String, list As %List) As %Collection.AbstractList
{
}

}
