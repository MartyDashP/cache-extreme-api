Class JetAPI.DTO.Abstract Extends %RegisteredObject [ Abstract, CompileAfter = (JetAPI.Generator.Deserializer, JetAPI.Generator.Serializer) ]
{

Projection JavaSpec As JetAPI.Projection.JavaSpec(TARGETDIR = "D:\_git\personal\java-cache-gateway-example\cache-projection\src\main\resources\", TYPE = "DTO");

Method %SerializeJetApiDTO() [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(JetAPI.Generator.Serializer).Generate())
 	ret sc
}

ClassMethod %DeserializeJetApiDTO(sObj As %List) [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(JetAPI.Generator.Deserializer).Generate())
 	ret sc
}

}

