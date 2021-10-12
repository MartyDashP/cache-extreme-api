Class JetAPI.DTO.Abstract Extends %RegisteredObject [ Abstract, DependsOn = (JetAPI.Generator.Serializer, JetAPI.Generator.Deserializer, JetAPI.Projection.JavaSpec) ]
{

Projection JavaSpec As JetAPI.Projection.JavaSpec(TYPE = "dto");

Method %jetApiSerializeDTO() [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	if (%compiledclass.Name = "JetAPI.DTO.Abstract")
	{
		$$$TOE(sc, ##class(JetAPI.Generator.Serializer).Generate())
 		ret sc	
	}

 	ret $$$OK
}

ClassMethod %jetApiDeserializeDTO(sObj As %List) [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	if (%compiledclass.Name = "JetAPI.DTO.Abstract")
	{
		$$$TOE(sc, ##class(JetAPI.Generator.Deserializer).Generate())
	 	ret sc
	}

 	ret $$$OK
}

ClassMethod %jetApiJavaSpecProjectionTargetPath() As %String [ Internal ]
{
	ret ^jetApiJavaSpecPath
}

}

