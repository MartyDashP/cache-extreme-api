Include JetAPI.general

Class JetAPI.Projection.CodeGen.COS.ProxyController Extends %RegisteredObject [ DependsOn = (JetAPI.Projection.CodeGen.COS.Deserializer, JetAPI.Projection.CodeGen.COS.Serializer) ]
{

Property ProxyController As %Dictionary.ClassDefinition [ Private ];

Property CompClass As %Dictionary.CompiledClass [ Private ];

Property ControllerClassName As %String [ Private ];

ClassMethod CreateProxyController(compClass As %Dictionary.CompiledClass, controllerClassName As %String) As %Status
{
	ret:(compClass.Abstract = 1) $$$OK
	
	s generator = ..%New()
	s generator.ControllerClassName = controllerClassName
	s generator.CompClass = compClass
	
	ret generator.Generate()
}

Method Generate()
{
	d ..GenerateClassDefinition()
	
	$$$TOE(sc, ..ProxyController.%Save())
	ret $system.OBJ.Compile(..ProxyController.Name, "b-r/checkuptodate")
}

Method GenerateClassDefinition()
{
	s ..ProxyController = ##class(%Dictionary.ClassDefinition).%New()
	s ..ProxyController.Final = 1
	s ..ProxyController.GeneratedBy = ..%ClassName(1)
	s ..ProxyController.Name = ..ControllerClassName
	s ..ProxyController.ProcedureBlock = 1
	s ..ProxyController.Methods = ..GetClassMethods()
}

Method GetClassMethods() As %ListOfObjects(ELEMENTTYPE="%Dictionary.MethodDefinition")
{
	s methods = ##class(%ListOfObjects).%New()
	
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
		
		s method = ..GenerateClassMethod(cMethod)
		s method.parent = ..ProxyController
		
		$$$TOE(sc,methods.Insert(method))
	}
		
	ret methods
}

Method GenerateClassMethod(cMethod As %Dictionary.CompiledMethod) As %Dictionary.MethodDefinition
{
	s method = ##class(%Dictionary.MethodDefinition).%New()
	s method.Name = cMethod.Name
	s method.Final = 1
	s method.ClassMethod = 1
	
	#dim methodInfo as JetAPI.Reflection.Model.MethodInfo
	s methodInfo = ##class(JetAPI.Reflection.Model.MethodInfo).Create()
	
	d ..ProcessMethodSpecs(cMethod, methodInfo)
	d ..ProcessMethodResult(cMethod, methodInfo)
	
	if $isObject(methodInfo.ResultInfo)
	{
		s method.ReturnType = methodInfo.ResultInfo.ElementType
	}
	
	s method.FormalSpec = $lts(methodInfo.GetMethodSpecs())
	d method.Implementation.Write(methodInfo.Implementation)
	
	ret method
}

ClassMethod DeserializeVar(varName As %String) As %String
{
	ret "d0"_varName
}

ClassMethod SerializeVar(varName As %String) As %String
{
	ret "s0"_varName
}

Method ProcessMethodSpecs(cMethod As %Dictionary.CompiledMethod, methodInfo As JetAPI.Reflection.Model.MethodInfo)
{
	f i=1:1:$ll(cMethod.FormalSpecParsed) {
		s arg = $lg(cMethod.FormalSpecParsed, i)

		#dim desParamsInfo, serParamsInfo as JetAPI.Reflection.Model.Attribute
		s desParamsInfo = ##class(JetAPI.Reflection.Method).GetArgInfo(arg)
		s serParamsInfo = desParamsInfo.Clone()

		s desParamsInfo.Alias = ..DeserializeVar(desParamsInfo.Name)
		s serParamsInfo.Alias = ..SerializeVar(serParamsInfo.Name)
		
		if (desParamsInfo.IsJetApiDTO() || desParamsInfo.IsCollection())
		{
			s serParamsInfo.CollectionType = ""
			s serParamsInfo.ElementType = ##class(JetAPI.Reflection.Type.COS).#List
		}
		
		$$$TOE(sc, methodInfo.DesParamsInfo.Insert(desParamsInfo))
		$$$TOE(sc, methodInfo.SerParamsInfo.Insert(serParamsInfo))
		d methodInfo.AddImplLine(##class(JetAPI.Projection.CodeGen.COS.Deserializer).GetCodeParameterDeserialization(serParamsInfo, desParamsInfo))
	}
}

Method ProcessMethodResult(cMethod As %Dictionary.CompiledMethod, methodInfo As JetAPI.Reflection.Model.MethodInfo)
{
	#dim sourceResult, targetResult as JetAPI.Reflection.Model.Attribute
	s sourceResult = ##class(JetAPI.Reflection.Method).GetReturnTypeInfo(cMethod)
	s targetResult = sourceResult.Clone()
	
	s sourceResult.Alias = ..DeserializeVar("result")
	s targetResult.Alias = ..SerializeVar("result")
	
	s args = $lts(methodInfo.GetDesParamNameList())
	s invokeCmd = "##class("_cMethod.Origin_")."_cMethod.Name_"("_args_")"
	
	if (sourceResult.IsVoid() || sourceResult.IsStream())
	{
		d methodInfo.AddImplLine("	d "_invokeCmd)
		ret
	}
	
	if (sourceResult.IsJetApiDTO() || sourceResult.IsCollection())
	{
		s targetResult.CollectionType = ""
		s targetResult.ElementType = ##class(JetAPI.Reflection.Type.COS).#List
	}

	s methodInfo.ResultInfo = targetResult
	d methodInfo.AddImplLine("	s "_sourceResult.Alias_" = "_invokeCmd)
	d methodInfo.AddImplLine(##class(JetAPI.Projection.CodeGen.COS.Serializer).GetCodeParameterSerialization(sourceResult, targetResult))
	d methodInfo.AddImplLine("	ret "_targetResult.Alias)
}

}

