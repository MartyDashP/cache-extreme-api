Include JetAPI.general

Class JetAPI.Generator.Java.Deserializer Extends %RegisteredObject
{

Property DeserializerVarName [ Private ];

Property CompProperties [ MultiDimensional, Private ];

ClassMethod GenerateCode(deserializerVarName As %String, ByRef compProperties) As %String
{
	s generator = ..%New()
	s generator.DeserializerVarName = deserializerVarName
	m generator.CompProperties = compProperties
	
	ret generator.GetCode()
}

Method GetCode() As %String
{
	s deserializerType = ##class(JetAPI.Util.JavaType).#APIDeserializer
	s code = ""
	
	f {
		s key = $order(..CompProperties(key))
	 	q:key=""
	 	
	 	#dim compProperty as %Dictionary.CompiledProperty
	 	s compProperty = ..CompProperties(key)
	 	
	 	s propertyName = "this."_compProperty.Name
	 	s propertyType = compProperty.Type
	 	s collectionType = ""
		s:$$$IsCollectionProperty(compProperty) collectionType = compProperty.RuntimeType
	 	
	 	s prt = propertyName_" = "_..GetDeserializationCode(..DeserializerVarName, propertyType, collectionType)_";"
	 	s code = code_prt_$c(13,10)
	}
	
	ret code
}

ClassMethod GetDeserializationCode(deserializerVarName As %String, type As %String, collectionType As %String) As %String
{
	s code = ""
	
	if $$$IsCollectionAsList(collectionType)
	{	
		s varName = "_"_deserializerVarName
		ret deserializerVarName_".getList("_varName_" -> "_..GetDeserializationCode(varName,type, "")_")"
	}
	
	if $$$IsSupportedObjectType(type)
	{
		ret deserializerVarName_".getObject("_type_".class)"
	}
	elseif $$$IsDataType(type)
	{
		s class = ##class(JetAPI.Util.JavaType).MapValueType(type)
		ret deserializerVarName_".getValue("_class_")"
	}

	throw $$$UnsupportedTypeExeption(type)
}

}

