Include JetAPI.general

Class JetAPI.Util.Java Extends %RegisteredObject
{

ClassMethod GetPackageName(compClass As %Dictionary.CompiledClass) As %String
{
	s nodes = $lfs(compClass.Name,".")
	ret $lts($li(nodes, 1, *-1), ".")
}

ClassMethod GetClassName(compClass As %Dictionary.CompiledClass) As %String
{
	s nodes = $lfs(compClass.Name,".")
	ret $lg(nodes, *)
}

ClassMethod GetJavaDocByClass(compClass As %Dictionary.CompiledClass) As %String
{
	s javaDoc = "Origin: """_compClass.Name_""""_$$$CRLF
		_"Timestamp: "_##class(%Library.UTC).NowLocal()
		
	if (compClass.Description '= "")
	{
		s javaDoc = javaDoc_$$$CRLF
			_"Description: "_$$$CRLF
			_"--------------"_$$$CRLF
			_compClass.Description_$$$CRLF
			_"--------------"_$$$CRLF
	}
	
	ret javaDoc
}

ClassMethod GetOverideAnnotation() As JavaSpec.Model.Annotation
{
	s annotation = ##class(JavaSpec.Model.Annotation).%New()
	s annotation.Name = "Override"
	
	ret annotation
}

}

