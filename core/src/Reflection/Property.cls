Class JetAPI.Reflection.Property Extends %RegisteredObject
{

ClassMethod CollectByClass(comClass As %Dictionary.CompiledClass, ByRef properties)
{
    s bannedProperties = $lb("%%OID")

    f i=1:1:comClass.Properties.Count()
	{
		#dim property as %Dictionary.PropertyDefinition
		s property = comClass.Properties.GetAt(i)
	
		if $lf(bannedProperties, property.Name)
		{
			continue
		}
			
		s properties(property.Name) = property
	}
}

ClassMethod GetAttributeInfo(property As %Dictionary.CompiledProperty) As JetAPI.Reflection.Model.Attribute
{
	s attr = ##class(JetAPI.Reflection.Model.Attribute).%New()
	s attr.Name = property.Name
	s attr.ElementType = property.Type
	
	if ##class(JetAPI.Reflection.Type.COS).IsList(property.RuntimeType)
	{
		s attr.CollectionType = property.RuntimeType	
	}
	
	ret attr
}

}

