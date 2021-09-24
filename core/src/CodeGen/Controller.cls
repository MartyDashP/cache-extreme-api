Include ExtremeAPI.general

Class ExtremeAPI.CodeGen.Controller Extends %RegisteredObject
{

Parameter DeserializerClassName = {##class(ExtremeAPI.CodeGen.Deserializer).%ClassName(1)};

Parameter SerializerClassName = {##class(ExtremeAPI.CodeGen.Serializer).%ClassName(1)};

Parameter SerializedPrefix = "s0";

Parameter DeserializedPrefix = "d0";

ClassMethod Generate(compClass As %Dictionary.CompiledClass, controllerClassName As %String) As %Status
{
	if (controllerClassName = "")
	{
		$$$ThrowException("ControllerClassName is undefined")
	}
	
	ret:(compClass.Abstract = 1) $$$OK
	

    s controller = ..GetClassDefinition(controllerClassName, compClass)
	$$$TOE(sc,controller.%Save())
	
	ret $system.OBJ.Compile(controller.Name,"b-r/checkuptodate")
}

ClassMethod GetControllerClassName(rootPackageName As %String, sourceClassName As %String) As %String
{
    ret rootPackageName_"."_sourceClassName
}

ClassMethod GetClassDefinition(className As %String, comClass As %Dictionary.CompiledClass) As %Dictionary.ClassDefinition
{
    s class = ##class(%Dictionary.ClassDefinition).%New()
	s class.Final = 1
	s class.GeneratedBy = ..%ClassName(1)
	s class.Name = className
	s class.ProcedureBlock = 1
	s class.Methods = ..GenerateClassMethods(class, comClass)
	
    ret class
}

ClassMethod GenerateClassMethods(parent As %Dictionary.ClassDefinition, comClass As %Dictionary.CompiledClass) As %ListOfObjects(ELEMENTTYPE="%Dictionary.MethodDefinition")
{
	s methods = ##class(%ListOfObjects).%New()
	
	f
	{
		#dim cMethod as %Dictionary.CompiledMethod
		s cMethod = comClass.Methods.GetNext(.key)
		q:key=""
		
		if ((cMethod.Private = 1) 
		|| (cMethod.Internal = 1) 
		|| (cMethod.Origin '= comClass.Name)
		|| (cMethod.ClassMethod = 0) )
		{
			continue
		}
		
		s method = ..GenerateClassMethod(cMethod)
		s method.parent = parent
		
		$$$TOE(sc,methods.Insert(method))
	}
		
	ret methods
}

ClassMethod GenerateClassMethod(cMethod As %Dictionary.CompiledMethod) As %Dictionary.MethodDefinition
{
	s method = ##class(%Dictionary.MethodDefinition).%New()
	s method.Name = cMethod.Name
	s method.Final = 1
	s method.ClassMethod = 1
	
	s sourceArgs = ""
	s targetArgs = ""
	s args = cMethod.FormalSpecParsed
		
	f i=1:1:$ll(args) {
		s arg = $lg(args,i)
		s codeBlock = ..ProcessArg(arg, .sourceArgs, .targetArgs)
		d method.Implementation.WriteLine(codeBlock)
	}
		
	s method.FormalSpec = $lts(sourceArgs)
	
	s returnType = cMethod.ReturnType
	
	if (returnType '= "")
	{
		s isCollection = $$$IsCollectionAsList(returnType)
		
		if ($$$IsDataType(returnType))
		{
			s method.ReturnType = returnType
		}
		else
		{
			s method.ReturnType = "%Library.List"
		}
	}
		
	if isCollection
	{
		if ($f(cMethod.ReturnTypeParams,"ELEMENTTYPE") = 0)
		{
			$$$ThrowException("return collection type must have parameter 'ELEMENTTYPE'")
		}
			
		s returnType = $lg($lfs(cMethod.ReturnTypeParams,"="),2)
			
		if (returnType = "")
		{
			$$$ThrowException("return collection element type is undefined")
		}
			
		s returnType = $$$NormalizeClassName($tr(returnType,"""",""))
	}
		
	s callControllerMethod = "##class("_cMethod.Origin_")."_cMethod.Name_"("_$lts(targetArgs)_")"
		
	if (returnType = "")
	{
		d method.Implementation.WriteLine("	d "_callControllerMethod)
	}
	else
	{
		s dResultVar = ..#DeserializedPrefix_"result"
		s sResultVar = ..#SerializedPrefix_"result"
		d method.Implementation.WriteLine("	s "_dResultVar_" = "_callControllerMethod)
		
		s condition = "("_dResultVar_" '= """")"
		s codeBlock = ##class(ExtremeAPI.CodeGen.Serializer).GetBlockCode(condition,sResultVar,dResultVar,returnType,isCollection)
		d method.Implementation.WriteLine(codeBlock)
		d method.Implementation.WriteLine("	ret "_sResultVar)
	}
	
	ret method
}

ClassMethod ProcessArg(arg As %List, ByRef sourceArgs As %List, ByRef targetArgs As %List) As %String
{
	s argName = $lg(arg,1,"")
	s argType = $lg(arg,2,"")

	if (argName = "")
	{
		$$$ThrowException("Has trouble in args specification")
	}

 	if (argType = "")
 	{
		$$$ThrowException("Arg '"_argName_"' has not type")
	}
	
	s targetName = ..#DeserializedPrefix_argName
	s targetType = $$$NormalizeClassName(argType)
	s targetArgs = targetArgs_$lb(targetName)

	s sourceName = ..#SerializedPrefix_argName
	s sourceType = "%Library.List"
	s:$$$IsDataType(targetType) sourceType = targetType
	s sourceArgs = sourceArgs_$lb(sourceName_":"_sourceType)
	
	if $$$IsCollectionAsList(targetType)
	{
		s ptr = $lf(arg,"ELEMENTTYPE")
		if ((ptr = 0) || ($lg(arg,ptr+1,"") = ""))
		{
			$$$ThrowException("Arg '"_targetName_"' is undefined 'ELEMENTTYPE' of collection")
		}
		s collectionTargetType = targetType
		s targetType = $$$NormalizeClassName($tr($lg(arg,ptr+1),"""",""))
	}
	
	ret ##class(ExtremeAPI.CodeGen.Deserializer).GetBlockCode(sourceName,targetName,targetType,collectionTargetType)
}

}

