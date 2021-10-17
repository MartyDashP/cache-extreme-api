Class JetAPI.Reflection.Type.COS Extends %RegisteredObject
{

Parameter String = "%Library.String";

Parameter Integer = "%Library.Integer";

Parameter Numeric = "%Library.Numeric";

Parameter List = "%Library.List";

Parameter JetApiStream = "JetAPI.DataType.Stream";

Parameter JetApiAbstractDTO = "JetAPI.DTO.Abstract";

ClassMethod Normalize(name As %String) As %String
{
	$$$TOE(sc,$$NormalizeClassnameByCom^%occName(.result,name))
	ret result
}

ClassMethod IsList(className As %String) As %Boolean
{
	s collections = $lb(
		##class(%ListOfDataTypes).%ClassName(1),
		##class(%ListOfObjects).%ClassName(1),
		##class(%Collection.ListOfObj).%ClassName(1),
		##class(%Collection.ListOfDT).%ClassName(1))
		
	ret ($lf(collections, className) > 0)
}

ClassMethod IsLB(type As %String) As %Boolean
{
	ret (type = ..#List)
}

ClassMethod IsStreamType(type As %String) As %Boolean
{
	s streams = $lb(..#JetApiStream)
	ret ($lf(streams, type) > 0)
}

ClassMethod IsJetApiDto(className As %String) As %Boolean
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = ##class(JetAPI.Reflection.Class).GetCompiledClass(className)
	ret ##class(JetAPI.Reflection.Class).IsExtendedClass(compClass, ..#JetApiAbstractDTO)
}

ClassMethod IsDataType(type As %String) As %Boolean
{
	#dim compClass as %Dictionary.CompiledClass
	s compClass = ##class(JetAPI.Reflection.Class).GetCompiledClass(type)
	ret ##class(JetAPI.Reflection.Class).IsExtendedClass(compClass, "%Library.DataType")
}

}

