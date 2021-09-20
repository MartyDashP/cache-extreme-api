Class ExtremeAPI.AbstractDTO Extends %RegisteredObject [ Abstract, CompileAfter = (ExtremeAPI.CodeGen.Deserializer, ExtremeAPI.CodeGen.Serializer) ]
{

Method %SerializeExtremeApiDTO() [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(ExtremeAPI.CodeGen.Serializer).Generate())
 	ret sc
}

ClassMethod %DeserializeExtremeApiDTO(sObj As %List) [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(ExtremeAPI.CodeGen.Deserializer).Generate())
 	ret sc
}

}

