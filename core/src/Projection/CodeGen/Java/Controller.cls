Include JetAPI.general

Class JetAPI.Projection.CodeGen.Java.Controller Extends %RegisteredObject
{

Property CompClass As %Dictionary.CompiledClass [ Private ];

Property CompProperties [ MultiDimensional, Private ];

Parameter ConnVarName = "connection";

Parameter SelfConnVarName = {"this."_..#ConnVarName};

Parameter ControllerVarName = "cacheControllerName";

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
	s source.StaticImports = ..GetStaticImports()
	s source.Definition = ..GetClassDefinition()
	
	ret source
}

Method GetStaticImports() As %ListOfObjects
{
	s imports = ##class(%ListOfObjects).%New()
	
	s serializer = ##class(JavaSpec.Model.StaticImport).%New()
	s serializer.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Reflection.Type.Java).#JetApiSerializer)
	s serializer.Names = ##class(%ListOfDataTypes).%New()
	$$$TOE(sc, serializer.Names.Insert("*"))
	$$$TOE(sc, imports.Insert(serializer))
	
	ret imports
}

Method GetClassDefinition() As JavaSpec.Model.ClassDefinition
{
	s classDefinition = ##class(JavaSpec.Model.ClassDefinition).%New()
	s classDefinition.Kind = "class"
	s classDefinition.JavaDoc = ##class(JetAPI.Util.Java).GetJavaDocByClass(..CompClass)
	s classDefinition.Name = ##class(JetAPI.Util.Java).GetClassName(..CompClass)
	s classDefinition.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("public", "final"))
	s classDefinition.Properties = ..GetProperties()
	s classDefinition.Methods = ..GetMethods()
	
	ret classDefinition
}

Method GetProperties() As %ListOfObjects(ELEMENTTYPE="JavaSpec.Model.Property")
{
	s properties = ##class(%ListOfObjects).%New()
	
	s property = ##class(JavaSpec.Model.Property).%New()
	s property.Name = ..#ControllerVarName
	s property.InitValue = """"_..CompClass.Name_""""
	s property.Type = ##class(JavaSpec.Model.Type).SimpleType("String")
	s property.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("private", "static", "final"))
	$$$TOE(sc, properties.Insert(property))
	
	s property = ##class(JavaSpec.Model.Property).%New()
	s property.Name = ..#ConnVarName
	s property.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Reflection.Type.Java).#JetApiConnection)
	s property.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("private", "final"))
	$$$TOE(sc, properties.Insert(property))
	
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
		$$$TOE(sc, methods.Insert(method))
	}
		
	ret methods
}

Method GetConstructor() As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Name = ##class(JavaSpec.Model.Method).#ConstructorName
	s method.Code = ..#SelfConnVarName_" = "_..#ConnVarName_";"
	s method.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("public"))
	s method.Parameters = ##class(%ListOfObjects).%New()
	
	s parameter = ##class(JavaSpec.Model.Parameter).%New()
	s parameter.Type = ##class(JavaSpec.Model.Type).SimpleType(##class(JetAPI.Reflection.Type.Java).#JetApiConnection)
	s parameter.Name = ..#ConnVarName
	$$$TOE(sc, method.Parameters.Insert(parameter))
	
	ret method
}

Method GetMethod(cMethod As %Dictionary.CompiledMethod) As JavaSpec.Model.Method
{
	s method = ##class(JavaSpec.Model.Method).%New()
	s method.Name = cMethod.Name
	s method.Modifiers = ##class(JetAPI.Util.General).LBToListOfDT($lb("public"))
	
	#dim methodInfo as JetAPI.Reflection.Model.MethodInfo
	s methodInfo = ##class(JetAPI.Reflection.Model.MethodInfo).Create()
	
	d ..ProcessMethodSpecs(cMethod, methodInfo)
	d ..ProcessMethodResult(cMethod, methodInfo)
	
	s method.Code = methodInfo.Implementation
	s method.ReturnType = ##class(JetAPI.Reflection.Type.Java).GetSpecType(methodInfo.ResultInfo)
	s method.Parameters = ##class(%ListOfObjects).%New()
	
	f i=1:1:methodInfo.DesParamsInfo.Count()
	{
		#dim paramInfo as JetAPI.Reflection.Model.Attribute
		s paramInfo = methodInfo.DesParamsInfo.GetAt(i)
		
		s parameter = ##class(JavaSpec.Model.Parameter).%New()
		s parameter.Name = paramInfo.Alias
		s parameter.Type = ##class(JetAPI.Reflection.Type.Java).GetSpecType(paramInfo)
		$$$TOE(sc, method.Parameters.Insert(parameter))
	}

	ret method
}

ClassMethod DeserializeVar(varName As %String) As %String
{
	ret "d_"_varName
}

ClassMethod SerializeVar(varName As %String) As %String
{
	ret "s_"_varName
}

Method ProcessMethodSpecs(cMethod As %Dictionary.CompiledMethod, methodInfo As JetAPI.Reflection.Model.MethodInfo)
{
	s methodParams = ##class(%ListOfObjects).%New()
	
	f i=1:1:$ll(cMethod.FormalSpecParsed) {
		s arg = $lg(cMethod.FormalSpecParsed, i)
		
		#dim desParamsInfo, serParamsInfo as JetAPI.Reflection.Model.Attribute
		s desParamsInfo = ##class(JetAPI.Reflection.Method).GetArgInfo(arg)
		s serParamsInfo = desParamsInfo.Clone()
		
		s desParamsInfo.Alias = ..DeserializeVar(desParamsInfo.Name)
		s serParamsInfo.Alias = ..SerializeVar(serParamsInfo.Name)
		
		d methodInfo.DesParamsInfo.Insert(desParamsInfo)

		/// declare java method parameter
		s parameter = ##class(JavaSpec.Model.Parameter).%New()
		s parameter.Name = desParamsInfo.Alias
		s parameter.Type = ##class(JetAPI.Reflection.Type.Java).GetSpecType(desParamsInfo)
		$$$TOE(sc, methodParams.Insert(parameter))
		
		if ('desParamsInfo.IsCollection() && desParamsInfo.IsDataType())
		{
			$$$TOE(sc, methodInfo.SerParamsInfo.Insert(desParamsInfo))
			continue
		}
		
		s code = ##class(JetAPI.Projection.CodeGen.Java.Serializer).GetCodeParameterStaticSerialization(..#SelfConnVarName, desParamsInfo, serParamsInfo)
		d methodInfo.AddImplLine(code)
		d methodInfo.SerParamsInfo.Insert(serParamsInfo)
	}
}

Method ProcessMethodResult(cMethod As %Dictionary.CompiledMethod, methodInfo As JetAPI.Reflection.Model.MethodInfo)
{
	#dim resultInfo as JetAPI.Reflection.Model.Attribute
	s resultInfo = ##class(JetAPI.Reflection.Method).GetReturnTypeInfo(cMethod)
	s methodName = "invoke"
	s methodArgs = $lb(..#ControllerVarName, """"_cMethod.Name_"""")
	
	if ('resultInfo.IsVoid() && 'resultInfo.IsStream())
	{
		s desVarName = "d"
		s lambda = desVarName
			_" -> "
			_##class(JetAPI.Projection.CodeGen.Java.Deserializer).GetCodeParameterDeserialization(desVarName, resultInfo)
			
		s methodArgs = methodArgs_$lb(lambda)
	}
	
	f i=1:1:methodInfo.SerParamsInfo.Count()
	{
		#dim paramInfo as JetAPI.Reflection.Model.Attribute
		s paramInfo = methodInfo.SerParamsInfo.GetAt(i)
		s methodArgs = methodArgs_$lb(paramInfo.Alias)
	}
	
	s cmd = ..#SelfConnVarName_"."_methodName_"("_$lts(methodArgs, ", ")_");"
	
	if ('resultInfo.IsVoid() && 'resultInfo.IsStream())
	{
		s cmd = "return "_cmd
	}
	
	s methodInfo.ResultInfo = resultInfo
	d methodInfo.AddImplLine(cmd)
}

}

