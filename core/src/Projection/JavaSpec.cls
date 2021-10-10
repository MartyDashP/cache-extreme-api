Include ExtremeAPI.general

Class ExtremeAPI.Projection.JavaSpec Extends %Projection.AbstractProjection [ Abstract ]
{

Parameter TYPE;

Parameter TARGETDIR;

Parameter ROOTPACKAGENAME;

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = $$$GetCompiledClass(classname)
	
	ret:compClass.Abstract $$$OK
	
	s type = ..GetParameter("TYPE", .parameters)
	s fullFileName = ..GetFullFileName(compClass.Name, .parameters)
		
	if (type = "DTO")
	{
		s source = ##class(ExtremeAPI.Generator.Java.DTO).Generate(compClass)
	}
	elseif (type = "Controller")
	{
		s controllerName = ..GetProjectionName(..GetParameter("ROOTPACKAGENAME", .parameters),compClass.Name)
		s source = ##class(ExtremeAPI.Generator.Java.Controller).Generate(controllerName, compClass)
	}
	
	if ($isObject(source) && (fullFileName '= ""))
	{
		d ##class(JavaSpec.Writer).WriteSpec(source, fullFileName)
		w !,"Java spec projection generated: "_fullFileName,!
	}
	
	ret $$$OK
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = ##class(ExtremeAPI.Functions).GetCompiledClass(classname)
	
	if ('$isObject(compClass) || compClass.Abstract)
	{
		ret $$$OK
	}
	
	s fullFileName = ..GetFullFileName(compClass.Name, .parameters)
	s isSuccess = ##class(%File).Delete(fullFileName)
	
	w:isSuccess !,"Java spec projection deleted: "_fullFileName,!
	
	ret $$$OK
}

ClassMethod GetParameter(name As %String, ByRef parameters) As %String
{
	ret $g(parameters(name))
}

ClassMethod GetFullFileName(className As %String, ByRef parameters)
{
	s targetDir = ..GetParameter("TARGETDIR", .parameters)
	s fileName = className_".xml"
	s fullFileName = targetDir_"\"_fileName
	
	if $$$isWINDOWS
	{
		ret $replace($tr(fullFileName, "\","/"),"//","/")
	}

	ret $replace($tr(fullFileName, "/","\"),"\\","\")
}

ClassMethod GetProjectionName(rootPackageName As %String, sourceClassName As %String) As %String
{
    ret $replace(rootPackageName_"."_sourceClassName,"..",".")
}

}

