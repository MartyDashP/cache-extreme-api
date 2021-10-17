Class JetAPI.DTO.Abstract Extends %RegisteredObject [ Abstract, DependsOn = (JetAPI.Projection.CodeGen.COS.Deserializer, JetAPI.Projection.CodeGen.COS.Serializer) ]
{

Projection JavaSpec As JetAPI.Projection.JavaSpec(TYPE = "dto");

Method %jetApiSerializeDTO() [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	if ('%compiledclass.Abstract)
	{ 
 		s code = ##class(JetAPI.Projection.CodeGen.COS.Serializer).GetSerializationScriptDTO(%compiledclass)
 		ret %code.WriteLine(code)
	}
	
 	ret $$$OK
}

ClassMethod %jetApiDeserializeDTO(sObj As %List) [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	if ('%compiledclass.Abstract)
	{
		s code = ##class(JetAPI.Projection.CodeGen.COS.Deserializer).GetDeserializationScriptDTO(%compiledclass)
		ret %code.WriteLine(code)
	}

 	ret $$$OK
}

ClassMethod %jetApiJavaSpecProjectionTargetPath() As %String [ Internal ]
{
	ret ^jetApiJavaSpecPath
}

}

