Class ExtremeAPI.AbstractDTO Extends %RegisteredObject [ Abstract, CompileAfter = (ExtremeAPI.Generator.Deserializer, ExtremeAPI.Generator.Serializer) ]
{

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

