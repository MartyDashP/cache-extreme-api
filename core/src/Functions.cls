Include ExtremeAPI.general

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
	ret (typeName = ##class(ExtremeAPI.ObjectScriptType).#ListType)
}

ClassMethod NormalizeClassName(className As %String) As %String
{
	$$$TOE(sc,$$NormalizeClassnameByCom^%occName(.result,className))
	ret result
}

ClassMethod GetMethodReturnInfo(cMethod As %Dictionary.CompiledMethod, ByRef type As %String, ByRef collectionType As %String)
{
	s type = cMethod.ReturnType

	if ..IsCollectionAsList(cMethod.ReturnType)
	{
		s collectionType = cMethod.ReturnType
		
		if ($f(cMethod.ReturnTypeParams,"ELEMENTTYPE") = 0)
		{
			throw ##class(%Exception.General).%New("return collection type must have parameter 'ELEMENTTYPE'")
		}
			
		s returnType = $lg($lfs(cMethod.ReturnTypeParams,"="),2)
		s returnType = $tr(returnType,"""","")
		
		if (returnType = "")
		{
			throw ##class(%Exception.General).%New("return collection element type is undefined")
		}
			
		s type = ..NormalizeClassName(returnType)
	}
}

ClassMethod GetMethodArgInfo(arg As %List, ByRef name As %String, ByRef type As %List, ByRef collectionType As %List)
{
	s name = $lg(arg,1,"")
	s type = $lg(arg,2,"")

	if (name = "")
	{
		throw ##class(%Exception.General).%New("Has trouble in args specification")
	}

 	if (type = "")
 	{
	 	throw ##class(%Exception.General).%New("Arg '"_argName_"' has not type")
	}
	
	s type = $$$NormalizeClassName(type)
	
	if $$$IsCollectionAsList(type)
	{
		s ptr = $lf(arg,"ELEMENTTYPE")
		if ((ptr = 0) || ($lg(arg,ptr+1,"") = ""))
		{
			throw ##class(%Exception.General).%New("Arg '"_name_"' is undefined 'ELEMENTTYPE' of collection")
		}
		s collectionType = type
		s type = $$$NormalizeClassName($tr($lg(arg,ptr+1),"""",""))
	}
}

}

