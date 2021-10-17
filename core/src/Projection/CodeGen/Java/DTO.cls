Class JetAPI.Projection.CodeGen.Java.DTO Extends %RegisteredObject
{

Property CompClass As %Dictionary.CompiledClass [ Private ];

Property CompProperties [ MultiDimensional, Private ];

Parameter ListReaderVarName = "reader";

Parameter DesVarName = "deserializer";

Parameter SerVarName = "serializer";

ClassMethod CreateJavaSpec(compClass As %Dictionary.CompiledClass) As JavaSpec.Model.Source
{
	s codeGen = ..%New()
	s codeGen.CompClass = compClass
	
	d ##class(JetAPI.Reflection.Property).CollectByClass(compClass, .compProperties)
	m codeGen.CompProperties = compProperties
	
	ret codeGen.Generate()
}

Method Generate() As JavaSpec.Model.Source
{
	s source = ##class(JavaSpec.Model.Source).%New()
	s source.PackageName = ##class(JetAPI.Util.Java).GetPackageName(..CompClass)
	s source.Definition = ..GetClassDefinition()
	
	ret source
}

Method GetClassDefinition() As JavaSpec.Model.ClassDefinition
{
	s classDefinition = ##class(JavaSpec.Model.ClassDefinition).%New()
	s classDefinition.Kind = "class"
	s classDefinition.JavaDoc = ##class(JetAPI.Util.Java).GetJavaDocByClass(..CompClass)
	s classDefinition.Name = ##class(JetAPI.Util.Java).GetClassName(..CompClass)
	s classDefinition.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("public"))
	s classDefinition.SuperInterfaces = ..GetSuperInterfaces()
	s classDefinition.Properties = ..GetProperties()
	s classDefinition.Methods = ##class(%ListOfObjects).%New()
	d classDefinition.Methods.Insert(..GetInitMethod())
	d classDefinition.Methods.Insert(..GetSerializeMethod())
	
	ret classDefinition
}

Method GetSuperInterfaces() As %ListOfDataTypes
{
	s superInterfaces = ##class(%ListOfDataTypes).%New()
	$$$TOE(sc,superInterfaces.Insert(##class(JetAPI.Reflection.Type.Java).#JetApiAbstractDTO))
	
	ret superInterfaces
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
	 	
	 	$$$TOE(sc, properties.Insert(property))
	}
	
	ret properties
}

Method GetProperty(compProperty As %Dictionary.CompiledProperty) As JavaSpec.Model.Property
{
	s property = ##class(JavaSpec.Model.Property).%New()
	s property.Name = compProperty.Name
	s property.JavaDoc = compProperty.Description
	s property.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("public"))
	
	s info = ##class(JetAPI.Reflection.Property).GetAttributeInfo(compProperty)
	s property.Type = ##class(JetAPI.Reflection.Type.Java).GetSpecType(info)
	
	ret property
}

Method GetInitMethod() As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Name = "init"
	s method.Annotations = ##class(%ListOfObjects).%New()
	d method.Annotations.Insert(##class(JetAPI.Util.Java).GetOverideAnnotation())
	s method.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("public"))
	s method.ReturnType = ##class(JavaSpec.Model.Type).SimpleType("void")
	s method.Parameters = ##class(%ListOfObjects).%New()
	
	s param = ##class(JavaSpec.Model.Parameter).%New()
	s param.Name = ..#DesVarName
	s param.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Reflection.Type.Java).#JetApiDeserializer)
	d method.Parameters.Insert(param)

	m props = ..CompProperties
	s method.Code = ##class(JetAPI.Projection.CodeGen.Java.Deserializer).GetDeserializationScript(..#DesVarName, .props)
	
	ret method
}

Method GetSerializeMethod() As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Name = "serialize"
	s method.Annotations = ##class(%ListOfObjects).%New()
	d method.Annotations.Insert(##class(JetAPI.Util.Java).GetOverideAnnotation())
	s method.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("public"))
	s method.ReturnType = ##class(JavaSpec.Model.Type).SimpleType("void")
	s method.Parameters = ##class(%ListOfObjects).%New()
	
	s param = ##class(JavaSpec.Model.Parameter).%New()
	s param.Name = ..#SerVarName
	s param.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Reflection.Type.Java).#JetApiSerializer)
	d method.Parameters.Insert(param)

	m props = ..CompProperties
	s method.Code = ##class(JetAPI.Projection.CodeGen.Java.Serializer).GetSerializationScript(..#SerVarName, .props)

	ret method
}

}

