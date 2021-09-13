Class ExtremeAPI.Functions Extends %RegisteredObject
{

Parameter BasicSupportedObjectClassName = "ExtremeAPI.AbstractDTO";

ClassMethod CollectSortedClassProperties(ByRef properties, comClass As %Dictionary.CompiledClass)
{
    s bannedProperties = $lb("%%OID")

    f i=1:1:comClass.Properties.Count()
	{
		#dim property as %Dictionary.PropertyDefinition
		s property = comClass.Properties.GetAt(i)
	
		if $lf(bannedProperties,property.Name)
		{
			continue
		}
			
		s properties(property.Name) = property
	}
}

ClassMethod GetCompiledClass(className As %String) As %Dictionary.CompiledClass
{
	s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(className)

	if (compiledClass = 0)
	{
		throw ##class(%Exception.General).%New("Compiled class '"_className_"' not found")
	}

	ret compiledClass
}

ClassMethod IsExtendClass(comClass As %Dictionary.CompiledClass, superClassName As %String) As %Boolean
{
	s superClasses = $lfs(comClass.PrimarySuper, "~")
	ret $lf(superClasses, superClassName)
}

ClassMethod IsSupportedObjectTypeProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	s compiledClass = ..GetCompiledClass(property.Type)
	ret ..IsExtendClass(compiledClass, ..#BasicSupportedObjectClassName)
}

ClassMethod IsCollectionProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	ret (property.Collection '= "")
}

ClassMethod IsDataTypeProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	s compiledClass = ..GetCompiledClass(property.Type)
	ret ..IsExtendClass(compiledClass, "%Library.DataType")
}

ClassMethod NormalizeClassName(className As %String) As %String
{
	$$$TOE(sc,$$NormalizeClassnameByCom^%occName(.result,className))
	ret result
}

}

