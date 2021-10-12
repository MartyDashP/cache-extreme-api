Include JetAPI.general

Class JetAPI.Generator.Java.DTO Extends %RegisteredObject
{

Property CompClass As %Dictionary.CompiledClass [ Private ];

Property CompProperties [ MultiDimensional, Private ];

Parameter ListReaderVarName = "reader";

Parameter DeserializerVarName = "deserializer";

Parameter SerializerVarName = "serializer";

ClassMethod Generate(compClass As %Dictionary.CompiledClass) As JavaSpec.Model.Source
{
	s generator = ..%New()
	s generator.CompClass = compClass
	
	$$$CollectSortedClassProperties(.compProperties,compClass)
	m generator.CompProperties = compProperties
	
	ret generator.GetSource()
}

Method GetSource() As JavaSpec.Model.Source
{
	s source = ##class(JavaSpec.Model.Source).%New()
	s source.PackageName = $lts($li($lfs(..CompClass.Name,"."),1,*-1),".")
	s source.Definition = ..GetClassDefinition()
	
	ret source
}

Method GetClassDefinition() As JavaSpec.Model.ClassDefinition
{
	s classDefinition = ##class(JavaSpec.Model.ClassDefinition).%New()
	s classDefinition.Kind = "class"
	s classDefinition.Name = $lg($lfs(..CompClass.Name,"."),*)
	s classDefinition.Modifiers = ..GetModifiers($lb("public"))
	s classDefinition.SuperInterfaces = ..GetSuperInterfaces()
	s classDefinition.JavaDoc = ##class(JetAPI.Util.Common).GetJavaDocClass(..CompClass)
	s classDefinition.Properties = ..GetProperties()
	s classDefinition.Methods = ##class(%ListOfObjects).%New()
	d classDefinition.Methods.Insert(..GetInitMethod())
	d classDefinition.Methods.Insert(..GetSerializeMethod())
	
	ret classDefinition
}

Method GetSuperInterfaces() As %ListOfDataTypes
{
	s superInterfaces = ##class(%ListOfDataTypes).%New()
	$$$TOE(sc,superInterfaces.Insert(##class(JetAPI.Util.JavaType).#APIAbstractDTO))
	
	ret superInterfaces
}

Method GetModifiers(modifierList As %List) As %ListOfDataTypes
{
	s modifiers = ##class(%ListOfDataTypes).%New()
	
	f i=1:1:$ll(modifierList)
	{
		s modifier = $lg(modifierList,i)
		$$$TOE(sc,modifiers.Insert(modifier))
	}
	
	ret modifiers
}

Method GetProperties() As %ListOfObjects(ELEMENTTYPE="JavaSpec.Model.Property")
{
	s properties = ##class(%ListOfObjects).%New()

	f {
		s key = $order(..CompProperties(key))
	 	q:key=""
	 	
	 	#dim compProperty as %Dictionary.CompiledProperty
	 	s compProperty = ..CompProperties(key)
	 	
	 	s property = ..GetProperty(compProperty)
	 	
	 	$$$TOE(sc,properties.Insert(property))
	}
	
	ret properties
}

Method GetProperty(compProperty As %Dictionary.CompiledProperty) As JavaSpec.Model.Property
{
	s property = ##class(JavaSpec.Model.Property).%New()
	s property.Name = compProperty.Name
	s property.JavaDoc = compProperty.Description
	s property.Type = ##class(JetAPI.Util.JavaType).GetSpecType(compProperty.Type, compProperty.RuntimeType)
	s property.Modifiers = ..GetModifiers($lb("public"))
	
	ret property
}

Method GetInitMethod() As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Annotations = ##class(%ListOfObjects).%New()
	d method.Annotations.Insert(..GetOverideAnnotation())
	s method.Name = "init"
	s method.Modifiers = ..GetModifiers($lb("public"))
	s method.ReturnType = ##class(JavaSpec.Model.Type).SimpleType("void")
	s method.Parameters = ##class(%ListOfObjects).%New()
	
	s param = ##class(JavaSpec.Model.Parameter).%New()
	s param.Name = ..#DeserializerVarName
	s param.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Util.JavaType).#APIDeserializer)
	d method.Parameters.Insert(param)

	m props = ..CompProperties
	s method.Code = ##class(JetAPI.Generator.Java.Deserializer).GenerateCode(..#DeserializerVarName, .props)
	
	ret method
}

Method GetSerializeMethod() As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Annotations = ##class(%ListOfObjects).%New()
	d method.Annotations.Insert(..GetOverideAnnotation())
	s method.Name = "serialize"
	s method.Modifiers = ..GetModifiers($lb("public"))
	s method.ReturnType = ##class(JavaSpec.Model.Type).SimpleType("void")
	s method.Parameters = ##class(%ListOfObjects).%New()
	
	s param = ##class(JavaSpec.Model.Parameter).%New()
	s param.Name = ..#SerializerVarName
	s param.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Util.JavaType).#APISerializer)
	d method.Parameters.Insert(param)

	m props = ..CompProperties
	s method.Code = ##class(JetAPI.Generator.Java.Serializer).GenerateCode(..#SerializerVarName, .props)

	ret method
}

Method GetOverideAnnotation() As JavaSpec.Model.Annotation
{
	s annotation = ##class(JavaSpec.Model.Annotation).%New()
	s annotation.Name = "Override"
	
	ret annotation
}

}

