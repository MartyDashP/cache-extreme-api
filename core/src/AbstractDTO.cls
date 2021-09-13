Class ExtremeAPI.AbstractDTO Extends %RegisteredObject [ Abstract, CompileAfter = ExtremeAPI.CodeGen.Serializer ]
{

Method %serializeExtremeApiDTO() [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(ExtremeAPI.CodeGen.Serializer).Generate())
 	ret sc
}

}

