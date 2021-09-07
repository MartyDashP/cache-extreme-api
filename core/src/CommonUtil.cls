Class ExtremeAPI.CommonUtil Extends %RegisteredObject
{

ClassMethod CollectClassProperties(ByRef properties, comClass As %Dictionary.CompiledClass)
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

ClassMethod IsExtendClass(comClass As %Dictionary.CompiledClass, superClassName As %String)
{
	s superClasses = $lfs(comClass.PrimarySuper,"~")
	ret $lf(superClasses, superClassName)
}

ClassMethod IsCollectionProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	ret (property.Collection '= "")
}

ClassMethod IsDataTypeProperty(property As %Dictionary.CompiledProperty) As %Boolean
{
	s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(property.Type)
	ret ..IsExtendClass(compiledClass, "%Library.DataType")
}

ClassMethod IsObject(property As %Dictionary.CompiledProperty) As %Boolean
{
	s compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(property.Type)
	ret ..IsExtendClass(compiledClass, "ExtremeAPI.AbstractDTO")
}

}
