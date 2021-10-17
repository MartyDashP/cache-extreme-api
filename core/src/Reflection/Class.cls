Class JetAPI.Reflection.Class Extends %RegisteredObject
{

ClassMethod GetCompiledClass(className As %String) As %Dictionary.CompiledClass
{
	s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(className)

	if (compiledClass = 0)
	{
		throw ##class(%Exception.General).%New("Compiled class '"_className_"' not found")
	}

	ret compiledClass
}

ClassMethod IsExtendedClass(comClass As %Dictionary.CompiledClass, superClassName As %String) As %Boolean
{
	s superClasses = $lfs(comClass.PrimarySuper, "~")
	ret $lf(superClasses, superClassName) > 0
}

}

