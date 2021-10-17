Class JetAPI.Reflection.Type.Java Extends %RegisteredObject
{

Parameter JetApiSerializer = "io.github.martydashp.cache_jet_api.Serializer";

Parameter JetApiDeserializer = "io.github.martydashp.cache_jet_api.Deserializer";

Parameter JetApiConnection = "io.github.martydashp.cache_jet_api.Connection";

Parameter JetApiAbstractDTO = "io.github.martydashp.cache_jet_api.dto.AbstractDTO";

Parameter CacheListReader = "com.intersys.jdbc.CacheListReader";

Parameter UtilList = "java.util.List";

Parameter BiConsumer = "java.util.function.BiConsumer";

Parameter Consumer = "java.util.function.Consumer";

ClassMethod GetSpecType(info As JetAPI.Reflection.Model.Attribute) As JavaSpec.Model.Type
{
	s javaType = ##class(JavaSpec.Model.Type).%New()

	if info.IsVoid()
	{
		s javaType.Name = "void"
	}
	elseif info.IsDataType()
	{
		s javaType.Name = $case(info.ElementType,
			##class(JetAPI.Reflection.Type.COS).#String: "String",
			##class(JetAPI.Reflection.Type.COS).#Integer: "Integer",
			##class(JetAPI.Reflection.Type.COS).#Numeric: "Integer")
	}
	elseif info.IsJetApiDTO()
	{
		s javaType.Name = info.ElementType
	}
	else
	{
		throw ##class(JetAPI.Exception.UnsupportedTypeException).Create(info)
	}
	
	if info.IsList()
	{
		s arg = ##class(JavaSpec.Model.Type).%New()
		s arg.Name = javaType.Name
			
		s javaType.Name = ..#UtilList
		s javaType.Arguments = ##class(%ListOfObjects).%New()
		$$$TOE(sc, javaType.Arguments.Insert(arg))
	}
	
	ret javaType
}

ClassMethod ToJavaClass(cacheType As %String) As %String
{
	ret $case(cacheType,
			##class(JetAPI.Reflection.Type.COS).#String: "String.class",
			##class(JetAPI.Reflection.Type.COS).#Integer: "Integer.class",
			##class(JetAPI.Reflection.Type.COS).#Numeric: "Integer.class")
}

}

