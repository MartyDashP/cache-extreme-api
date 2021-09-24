Include ExtremeAPI.general

Class ExtremeAPI.Projection.Controller Extends %Projection.AbstractProjection [ Abstract ]
{

Parameter ROOTPACKAGENAME;

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = $$$GetCompiledClass(classname)
	
	s rootPackageName = ..GetRootPackageName(.parameters)
	
	if (rootPackageName = "")
	{
		$$$ThrowException("Root package for controller projection is undefined")
	}
	
	s projectionName = ..GetProjectionName(rootPackageName, compClass.Name)
	ret ##class(ExtremeAPI.CodeGen.Controller).Generate(compClass, projectionName)
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
	s rootPackageName = ..GetRootPackageName(.parameters)
	
	if (rootPackageName '= "")
	{
		ret $$Delete^%apiOBJ(..GetProjectionName(rootPackageName, classname),"-d",,1)
	}
	
	ret $$$OK
}

ClassMethod GetRootPackageName(ByRef parameters) As %String
{
	ret $g(parameters("ROOTPACKAGENAME"))
}

ClassMethod GetProjectionName(rootPackageName As %String, sourceClassName As %String) As %String
{
    ret rootPackageName_"."_sourceClassName
}

}

