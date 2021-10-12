Class ExtremeAPI.DTO.Abstract Extends %RegisteredObject [ Abstract, CompileAfter = (ExtremeAPI.Generator.Deserializer, ExtremeAPI.Generator.Serializer) ]
{

Projection JavaSpec As ExtremeAPI.Projection.JavaSpec(TARGETDIR = "D:\_git\personal\java-cache-gateway-example\cache-projection\src\main\resources\", TYPE = "DTO");

Method %SerializeExtremeApiDTO() [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(ExtremeAPI.Generator.Serializer).Generate())
 	ret sc
}

ClassMethod %DeserializeExtremeApiDTO(sObj As %List) [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(ExtremeAPI.Generator.Deserializer).Generate())
 	ret sc
}

}

