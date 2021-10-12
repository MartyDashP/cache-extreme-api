Include JetAPI.general

Class JetAPI.Generator.Java.Serializer Extends %RegisteredObject
{

Property SerializerVarName [ Private ];

Property CompProperties [ MultiDimensional, Private ];

ClassMethod GenerateCode(serializerVarName As %String, ByRef compProperties) As %Status
{
    s generator = ..%New()
    s generator.SerializerVarName = serializerVarName
    m generator.CompProperties = compProperties

    ret generator.GetCode()
}

Method GetCode() As %String
{
    s code = ""
    
    f {
		s key = $order(..CompProperties(key))
	 	q:key=""
	 	
	 	#dim compProperty as %Dictionary.CompiledProperty
	 	s compProperty = ..CompProperties(key)
	 	
	 	s propName = compProperty.Name
	 	s propType = compProperty.Type
	 	s collectionType = ""
		s:$$$IsCollectionProperty(compProperty) collectionType = compProperty.RuntimeType
	 	
	 	s prt = ..GetSerializationCode(..SerializerVarName, "this.", propName, propType, collectionType)_";"
	 	s code = code_prt_$c(13,10)
	}

    ret code
}

ClassMethod GetSerializationCode(serName As %String, prefix As %String, pName As %String, type As %String, collectionType As %String) As %String
{
	s pName = prefix_pName
	
	if $$$IsCollectionAsList(collectionType)
	{
		ret serName_".setList("_pName_", (s,v) -> "_..GetSerializationCode("s", "", "v", type, "")_")"
	}
	
	if $$$IsSupportedObjectType(type)
	{
		ret serName_".setObject("_pName_")"
	}
	elseif $$$IsDataType(type)
	{		
		ret serName_".setValue("_pName_")"
	}

	throw $$$UnsupportedTypeExeption(type)
}

ClassMethod GetStaticSerializationCode(connectionVarName As %String, varName As %String, type As %String, collectionType As %String) As %String
{
	if $$$IsCollectionAsList(collectionType)
	{
		ret "serializeList("_connectionVarName_", "_varName_", (s,v) -> "_..GetSerializationCode("s", "", "v", type, "")_")"
	}
	
	if $$$IsSupportedObjectType(type)
	{
		ret "serializeObject("_connectionVarName_", "_varName_")"
	}
	elseif $$$IsDataType(type)
	{		
		ret varName
	}

	throw $$$UnsupportedTypeExeption(type)
}

}

