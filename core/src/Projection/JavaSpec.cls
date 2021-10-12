Include JetAPI.general

Class JetAPI.Projection.JavaSpec Extends %Projection.AbstractProjection [ Abstract ]
{

Parameter TypeDTO = "dto";

Parameter TypeController = "controller";

Parameter TYPE;

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
	s projectionType = $ZCONVERT($g(parameters("TYPE")),"L")
	
	#dim compClass as %Dictionary.CompiledClass
	s compClass = $$$GetCompiledClass(classname)
	
	ret:(compClass.Abstract || (projectionType = "")) $$$OK
	
	s source = $case(projectionType,
		..#TypeDTO: ##class(JetAPI.Generator.Java.DTO).Generate(compClass),
		..#TypeController: ##class(JetAPI.Generator.Java.Controller).Generate(compClass),
		: "")
		
	s projectionFileName = ..GetProjectionFileName(compClass)
	
	if ($isObject(source) && (projectionFileName '= ""))
	{
		d ##class(JavaSpec.Writer).WriteSpec(source, projectionFileName)
		w !, "Java spec projection generated: "_projectionFileName, !
	}
	
	ret $$$OK
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = ##class(JetAPI.Util.Common).GetCompiledClass(classname)
	
	if ('$isObject(compClass) || compClass.Abstract)
	{
		ret $$$OK
	}
	
	s projectionFileName = ..GetProjectionFileName(compClass)
	
	if (projectionFileName '= "")
	{
		s isSuccess = ##class(%File).Delete(fullFileName)
		w:isSuccess !,"Java spec projection deleted: "_fullFileName,!
	}
	
	ret $$$OK
}

ClassMethod GetProjectionFileName(compClass As %Dictionary.CompiledClass) As %String
{
	s path = $classmethod(compClass.Name, "%jetApiJavaSpecProjectionTargetPath")
	
	if (path '= "")
	{
		s path = path_"\"_compClass.Name_".xml"
		s path = ##class(JetAPI.Util.Common).GetCannonicalPath(path)
	}
	
	ret path
}

}

