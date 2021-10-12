Include JetAPI.general

Class JetAPI.Generator.Java.Controller Extends %RegisteredObject
{

Property CompClass As %Dictionary.CompiledClass [ Private ];

Property CompProperties [ MultiDimensional, Private ];

Parameter SerializedPrefix = "b_";

Parameter DeserializedPrefix = "_";

Parameter ConnectionVarName = "connection";

Parameter SelfConnectionVarName = {"this."_..#ConnectionVarName};

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
	s source.StaticImports = ..GetStaticImports()
	
	ret source
}

Method GetStaticImports() As %ListOfObjects
{
	s imports = ##class(%ListOfObjects).%New()
	
	s serializer = ##class(JavaSpec.Model.StaticImport).%New()
	s serializer.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Util.JavaType).#APISerializer)
	s serializer.Names = ##class(%ListOfDataTypes).%New()
	$$$TOE(sc,serializer.Names.Insert("*"))
	$$$TOE(sc,imports.Insert(serializer))
	
	ret imports
}

Method GetClassDefinition() As JavaSpec.Model.ClassDefinition
{
	s classDefinition = ##class(JavaSpec.Model.ClassDefinition).%New()
	s classDefinition.Kind = "class"
	s classDefinition.Name = $lg($lfs(..CompClass.Name,"."),*)
	s classDefinition.JavaDoc = ##class(JetAPI.Util.Common).GetJavaDocClass(..CompClass)
	s classDefinition.Properties = ..GetProperties()
	s classDefinition.Modifiers = ..GetModifiers($lb("public", "final"))
	s classDefinition.Methods = ..GetMethods()
	
	ret classDefinition
}

ClassMethod GetModifiers(modifierList As %List) As %ListOfDataTypes
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
	
	s property = ##class(JavaSpec.Model.Property).%New()
	s property.Name = "cacheControllerName"
	s property.InitValue = """"_..CompClass.Name_""""
	s property.Type = ##class(JavaSpec.Model.Type).SimpleType("String")
	s property.Modifiers = ..GetModifiers($lb("private", "static", "final"))
	$$$TOE(sc,properties.Insert(property))
	
	s property = ##class(JavaSpec.Model.Property).%New()
	s property.Name = ..#ConnectionVarName
	s property.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Util.JavaType).#APIConnection)
	s property.Modifiers = ..GetModifiers($lb("private", "final"))
	$$$TOE(sc,properties.Insert(property))
	
	ret properties
}

Method GetMethods() As %ListOfObjects(ELEMENTTYPE="JavaSpec.Model.Method")
{
	s methods = ##class(%ListOfObjects).%New()
	$$$TOE(sc,methods.Insert(..GetConstructor()))
	
	f
	{
		#dim cMethod as %Dictionary.CompiledMethod
		s cMethod = ..CompClass.Methods.GetNext(.key)
		q:key=""
		
		if ((cMethod.Private = 1) 
		|| (cMethod.Internal = 1) 
		|| (cMethod.Origin '= ..CompClass.Name)
		|| (cMethod.ClassMethod = 0)
		|| $MATCH(cMethod.Name,"^\%(jetApi).*"))
		{
			continue
		}
		
		s method = ..GetMethod(cMethod)
		$$$TOE(sc,methods.Insert(method))
	}
		
	ret methods
}

Method GetConstructor() As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Name = "#constructor"
	s method.Code = ..#SelfConnectionVarName_" = "_..#ConnectionVarName_";"
	s method.Modifiers = ..GetModifiers($lb("public"))
	s method.Parameters = ##class(%ListOfObjects).%New()
	
	s parameter = ##class(JavaSpec.Model.Parameter).%New()
	s parameter.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Util.JavaType).#APIConnection)
	s parameter.Name = "connection"
	s parameter.Modifiers = ..GetModifiers($lb("final"))
	$$$TOE(sc,method.Parameters.Insert(parameter))
	
	ret method
}

Method GetMethod(cMethod As %Dictionary.CompiledMethod) As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Name = cMethod.Name
	s method.Modifiers = ..GetModifiers($lb("public"))
	
	d ..ProcessMethodSpecs(cMethod, .methodImpl, .methodParams, .args)
	s method.Parameters = methodParams
	
	d ..ProcessMethodResult(cMethod, args, .resultImpl, .resultType, .returnСollectionType)
	s method.ReturnType = ##class(JetAPI.Util.JavaType).GetSpecType(resultType, returnСollectionType)
	
	s method.Code = methodImpl_resultImpl
	
	ret method
}

Method ProcessMethodSpecs(cMethod As %Dictionary.CompiledMethod, ByRef methodImpl As %String, ByRef methodParams As %ListOfObjects(ELEMENTTYPE="JavaSpec.Model.Parameter"), ByRef args As %List)
{
	s methodParams = ##class(%ListOfObjects).%New()
	
	f i=1:1:$ll(cMethod.FormalSpecParsed) {
		s arg = $lg(cMethod.FormalSpecParsed,i)
		d ##class(JetAPI.Util.Common).GetMethodArgInfo(arg,.argName,.dType,.dCollectionType)
		s dVar = ..#DeserializedPrefix_argName

		/// declare java method parameter
		s parameter = ##class(JavaSpec.Model.Parameter).%New()
		s parameter.Name = dVar
		s parameter.Type = ##class(JetAPI.Util.JavaType).GetSpecType(dType,dCollectionType)
		$$$TOE(sc,methodParams.Insert(parameter))
		
		if ($$$IsDataType(dType) && (dCollectionType = ""))
		{
			s args = args_$lb(dVar)
			continue
		}
		
		s conn = ..#SelfConnectionVarName
		s sVar = ..#SerializedPrefix_argName
		s sCode = ##class(JetAPI.Generator.Java.Serializer).GetStaticSerializationCode(conn, dVar, dType, dCollectionType)
		s methodImpl = methodImpl_"final byte[] "_sVar_" = "_sCode_";"_$c(13,10)
		s args = args_$lb(sVar)
	}
}

Method ProcessMethodResult(cMethod As %Dictionary.CompiledMethod, args As %List, ByRef methodImpl As %String, ByRef returnType As %String, ByRef returnСollectionType As %String)
{
	d ##class(JetAPI.Util.Common).GetMethodReturnInfo(cMethod,.returnType,.returnСollectionType)
	
	if (returnType '= "")
	{
		s desVarName = "d"
		s desCode = ", "
			_desVarName
			_" -> "
			_##class(JetAPI.Generator.Java.Deserializer).GetDeserializationCode(desVarName,returnType,returnСollectionType)
	}
	
	s:(args '= "") args = ", "_$lts(args, ", ")
	s methodImpl = ..#SelfConnectionVarName_".invoke(cacheControllerName,"""_cMethod.Name_""""_desCode_args_");"_$c(13,10)
	
	if (desCode '= "")
	{
		s methodImpl = "return "_methodImpl
	}
}

}

