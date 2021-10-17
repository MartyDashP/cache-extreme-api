Class JetAPI.Reflection.Method Extends %RegisteredObject
{

ClassMethod GetReturnTypeInfo(cMethod As %Dictionary.CompiledMethod) As JetAPI.Reflection.Model.Attribute
{
	s typeInfo = ##class(JetAPI.Reflection.Model.Attribute).%New()
	s typeInfo.ElementType = cMethod.ReturnType
	
	#dim tmpTypeInfo as JetAPI.Reflection.Model.Attribute
	s tmpTypeInfo = ""
	
	if ##class(JetAPI.Reflection.Type.COS).IsStreamType(cMethod.ReturnType)
	{
		s tmpTypeInfo = ..GetReturnTypeParameters(cMethod.ReturnTypeParams)
		s typeInfo.StreamType = cMethod.ReturnType
		s typeInfo.ElementType = tmpTypeInfo.ElementType
		s typeInfo.CollectionType = tmpTypeInfo.CollectionType
	}
	elseif ##class(JetAPI.Reflection.Type.COS).IsList(cMethod.ReturnType)
	{	
		s tmpTypeInfo = ..GetReturnTypeParameters(cMethod.ReturnTypeParams)
		s typeInfo.CollectionType = cMethod.ReturnType
		s typeInfo.ElementType = tmpTypeInfo.ElementType
	}
	
	ret typeInfo
}

ClassMethod GetReturnTypeParameters(parameters As %String) As JetAPI.Reflection.Model.Attribute
{
	s typeInfo = ##class(JetAPI.Reflection.Model.Attribute).%New()
	s typeParams = $lfs(parameters, ",")

	f i=1:1:$ll(typeParams)
	{
		s typeParam = $lfs($lg(typeParams,i),"=")

		if ($lg(typeParam, 1) = "COLLECTIONTYPE")
		{
			s collectionType = $tr($lg(typeParam, 2),"""","")
			if (collectionType '= "")
			{
				s typeInfo.CollectionType = ##class(JetAPI.Reflection.Type.COS).Normalize(collectionType)
			}
		}
		elseif ($lg(typeParam, 1) = "ELEMENTTYPE")
		{
			s elementType =  $tr($lg(typeParam, 2),"""","")
			if (elementType '= "")
			{
				s typeInfo.ElementType = ##class(JetAPI.Reflection.Type.COS).Normalize(elementType)
			}
		}
	}

	ret typeInfo
}

ClassMethod GetArgInfo(arg As %List) As JetAPI.Reflection.Model.Attribute
{
	s argInfo = ##class(JetAPI.Reflection.Model.Attribute).%New()
	s argInfo.Name = $lg(arg, 1, "")
	s argInfo.ElementType = ##class(JetAPI.Reflection.Type.COS).Normalize($lg(arg, 2, ""))
	
	if ##class(JetAPI.Reflection.Type.COS).IsList(argInfo.ElementType)
	{
		s ptr = $lf(arg, "ELEMENTTYPE")
		if ((ptr = 0) || ($lg(arg, ptr+1, "") = ""))
		{
			ret argInfo
		}
		
		s elementType = $lg(arg, ptr+1)
		s elementType = $tr(elementType, """", "")
		s elementType = ##class(JetAPI.Reflection.Type.COS).Normalize(elementType)
		
		s argInfo.CollectionType = argInfo.ElementType
		s argInfo.ElementType = elementType
	}
	
	ret argInfo
}

}

