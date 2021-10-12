Include JetAPI.general

Class JetAPI.Generator.Controller Extends %RegisteredObject [ CompileAfter = (JetAPI.Generator.Deserializer, JetAPI.Generator.Serializer) ]
{

Parameter DeserializerClassName = "JetAPI.Generator.Deserializer";

Parameter SerializerClassName = "JetAPI.Generator.Serializer";

Parameter SerializedPrefix = "s0";

Parameter DeserializedPrefix = "d0";

Property Controller As %Dictionary.ClassDefinition [ Private ];

Property CompClass As %Dictionary.CompiledClass [ Private ];

Property ControllerClassName As %String [ Private ];

ClassMethod Generate(compClass As %Dictionary.CompiledClass, controllerClassName As %String) As %Status
{
	if (controllerClassName = "")
	{
		throw ##class(%Exception.General).%New("ControllerClassName is undefined")
	}
	
	ret:(compClass.Abstract = 1) $$$OK
	
	s generator = ..%New()
	s generator.ControllerClassName = controllerClassName
	s generator.CompClass = compClass
	
	ret generator.CreateController()
}

Method CreateController()
{
	d ..GenerateClassDefinition()
	
	$$$TOE(sc, ..Controller.%Save())
	ret $system.OBJ.Compile(..Controller.Name, "b-r/checkuptodate")
}

Method GenerateClassDefinition()
{
	s ..Controller = ##class(%Dictionary.ClassDefinition).%New()
	s ..Controller.Final = 1
	s ..Controller.GeneratedBy = ..%ClassName(1)
	s ..Controller.Name = ..ControllerClassName
	s ..Controller.ProcedureBlock = 1
	s ..Controller.Methods = ..GetClassMethods()
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
		|| $lf(bannedMethods,cMethod.Name))
		{
			continue
		}
		
		s method = ..GenerateClassMethod(cMethod)
		s method.parent = ..Controller
		
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
	
	d ..ProcessMethodSpecs(cMethod, .methodImpl, .serializationSpecs, .deserializationSpecs)
	d:(methodImpl '= "") method.Implementation.Write(methodImpl)
		
	s method.FormalSpec = $lts(serializationSpecs)
	
	d ..ProcessMethodResult(cMethod,deserializationSpecs,.methodImpl,.returnType)
	s:(returnType '= "") method.ReturnType = returnType
	d method.Implementation.Write(methodImpl)
	
	ret method
}

Method ProcessMethodSpecs(cMethod As %Dictionary.CompiledMethod, ByRef methodImpl As %String, ByRef serializationSpecs As %List, ByRef deserializationSpecs As %List)
{
	f i=1:1:$ll(cMethod.FormalSpecParsed) {
		s arg = $lg(cMethod.FormalSpecParsed,i)
		
		d ##class(JetAPI.Util.Common).GetMethodArgInfo(arg,.argName,.dType,.dCollectionType)
		
		s dName = ..#DeserializedPrefix_argName
		s deserializationSpecs = deserializationSpecs_$lb(dName)

		s sName = ..#SerializedPrefix_argName
		s sType = "%Library.List"
		
		if ($$$IsDataType(dType) && (dCollectionType = ""))
		{
			s sType = dType
		}
		s serializationSpecs = serializationSpecs_$lb(sName_":"_sType)
		
		s code = ##class(JetAPI.Generator.Deserializer).GetBlockCode(sName,dName,dType,dCollectionType)
		s methodImpl = methodImpl_code_$c(13,10)
	}
}

Method ProcessMethodResult(cMethod As %Dictionary.CompiledMethod, deserializationSpecs As %List, ByRef methodImpl As %String, ByRef returnType As %String)
{
	d ##class(JetAPI.Util.Common).GetMethodReturnInfo(cMethod, .returnType, .collectionType)
	
	s isCollection = (collectionType '= "")
	s callControllerMethod = "##class("_cMethod.Origin_")."_cMethod.Name_"("_$lts(deserializationSpecs)_")"
	
	if (returnType = "")
	{
		s methodImpl = "	d "_callControllerMethod_$c(13,10)
	}
	else
	{	
		if ($$$IsDataType(returnType) && 'isCollection)
		{
			s returnType = returnType
		}
		else
		{
			s returnType = ##class(JetAPI.Util.ObjectScriptType).#ListType
		}
		
		s dResultVar = ..#DeserializedPrefix_"result"
		s sResultVar = ..#SerializedPrefix_"result"
		s condition = "("_dResultVar_" '= """")"
		
		s code = ##class(JetAPI.Generator.Serializer).GetBlockCode(condition,sResultVar,dResultVar,returnType,isCollection)
		
		s methodImpl = "	s "_dResultVar_" = "_callControllerMethod_$c(13,10)
			_code_$c(13,10)
			_"	ret "_sResultVar_$c(13,10)
	}
}

}
