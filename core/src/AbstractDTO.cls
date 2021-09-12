Class ExtremeAPI.AbstractDTO Extends %RegisteredObject [ Abstract, CompileAfter = ExtremeAPI.CodeGenerator ]
{

Method %eapiSerializeDTO() [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	$$$TOE(sc,##class(ExtremeAPI.CodeGenerator).GenerateSerializer())
 	ret sc
}

ClassMethod %eapiDeserializeDTO(serializedValue As %List) [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	//$$$TOE(sc,##class(ExtremeAPI.CodeGenerator).GenerateDeserializer())
 	ret $$$OK
}

}
