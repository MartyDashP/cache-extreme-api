Class JetAPI.Controller.Abstract Extends %RegisteredObject [ Abstract, DependsOn = (JetAPI.Projection.ProxyController, JetAPI.Projection.JavaSpec) ]
{

Parameter ClassGenPrefix [ Internal ] = "GeneratedClasses";

Projection JetApiProxyController As JetAPI.Projection.ProxyController;

Projection JavaSpec As JetAPI.Projection.JavaSpec(TYPE = "Controller");

ClassMethod %jetApiProxyControllerName() As %String [ CodeMode = objectgenerator, Internal, ServerOnly = 1 ]
{
	if ('%compiledclass.Abstract)
	{
		s generatedClassName = ..#ClassGenPrefix_"."_%compiledclass.Name
	
		if ($f(generatedClassName,"..") || (..#ClassGenPrefix = ""))
		{
			throw ##class(%Exception.General).%New("Incorrect generated class name")
		}
	}
	
	if (generatedClassName = "")
	{
		d %code.WriteLine("	/// crutch for generation method with return empty value")
	}
	
	d %code.WriteLine("	ret """_generatedClassName_"""")
	ret $$$OK
}

ClassMethod %jetApiJavaSpecProjectionTargetPath() As %String [ Internal ]
{
	ret ^jetApiJavaSpecPath
}

}

