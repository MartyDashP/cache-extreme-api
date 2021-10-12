Include JetAPI.general

Class JetAPI.Projection.ProxyController Extends %Projection.AbstractProjection [ Abstract ]
{

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = $$$GetCompiledClass(classname)
	
	ret:(compClass.Abstract) $$$OK
	
	s proxyName = ..GetProxyControllerName(compClass.Name)
	$$$TOE(sc, ##class(JetAPI.Generator.ProxyController).Generate(compClass, proxyName))
	
	w !,"Jet API proxy controller generated: "_proxyName,!
	
	ret sc
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = $$$GetCompiledClass(classname)
	s proxyName = ..GetProxyControllerName(compClass.Name)
	
	ret:(proxyName '= "") $$Delete^%apiOBJ(proxyName,"-d",,1)
	ret $$$OK
}

ClassMethod GetProxyControllerName(controllerName As %String)
{
	ret $classmethod(controllerName, "%jetApiProxyControllerName")
}

}

