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
	ret $lf(superClasses, superClassName) > 0
}

ClassMethod IsSupportedObjectTypeProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	ret ..IsSupportedObjectType(property.Type)
}

ClassMethod IsCollectionProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	ret (property.Collection '= "")
}

ClassMethod IsCollectionAsList(className As %String) As %Boolean
{
	s supportedCollections = $lb(
		##class(%ListOfDataTypes).%ClassName(1),
		##class(%ListOfObjects).%ClassName(1),
		##class(%Collection.ListOfObj).%ClassName(1),
		##class(%Collection.ListOfDT).%ClassName(1))
		
	ret ($lf(supportedCollections,className) > 0)
}

ClassMethod IsDataTypeProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	ret ..IsDataType(property.Type)
}

ClassMethod IsSupportedObjectType(className As %String) As %Boolean
{
	s compiledClass = ..GetCompiledClass(className)
	ret ..IsExtendClass(compiledClass, ..#BasicSupportedObjectClassName)
}

ClassMethod IsDataType(typeName As %String) As %Boolean
{
	s compiledClass = ..GetCompiledClass(typeName)
	ret ..IsExtendClass(compiledClass, "%Library.DataType")
}

ClassMethod IsListType(typeName As %String) As %Boolean
{
	ret (typeName = "%Library.List")
}

ClassMethod NormalizeClassName(className As %String) As %String
{
	$$$TOE(sc,$$NormalizeClassnameByCom^%occName(.result,className))
	ret result
}

}

