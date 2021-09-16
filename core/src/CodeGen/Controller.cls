Include ExtremeAPI.general

Class ExtremeAPI.CodeGen.Controller Extends %Projection.AbstractProjection
{

Parameter SourceClass = "%sourceClass";

Parameter ROOTPACKAGENAME = "ExtremeAPI.Controller";

Parameter DeserializerClassName = {##class(ExtremeAPI.CodeGen.Deserializer).%ClassName(1)};

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
	s @..#SourceClass = $$$GetCompiledClass(classname)
	
	ret:(..GetSourceClass().Abstract = 1) $$$OK
	
    s projection = ..GetClassDefinition()
	$$$TOE(sc,projection.%Save())

    k @..#SourceClass
	
	ret $system.OBJ.Compile(projection.Name,"b-r/checkuptodate")
}

ClassMethod GetSourceClass() As %Dictionary.CompiledClass
{
    ret @..#SourceClass
}

ClassMethod GetProjectionName(sourceClassName As %String) As %String
{
    ret ..#ROOTPACKAGENAME_"."_sourceClassName
}

ClassMethod GetClassDefinition(classname As %String) As %Dictionary.ClassDefinition
{
    s class = ##class(%Dictionary.ClassDefinition).%New()
	s class.Final = 1
	s class.GeneratedBy = ..%ClassName(1)
	s class.Name = ..GetProjectionName(..GetSourceClass().Name)
	s class.ProcedureBlock = 1
	s class.Methods = ..GenerateClassMethods(class)

    ret class
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
	ret $$Delete^%apiOBJ(..GetProjectionName(classname),"-d",,1)
}

ClassMethod GenerateClassMethods(parent As %Dictionary.ClassDefinition) As %ListOfObjects(TYPEELEMENT="%Dictionary.MethodDefinition")
{
	s methods = ##class(%ListOfObjects).%New()
	
	f
	{
		#dim cMethod as %Dictionary.CompiledMethod
		s cMethod = ..GetSourceClass().Methods.GetNext(.key)
		q:key=""
		
		if ((cMethod.Private = 1) 
		|| (cMethod.Internal = 1) 
		|| (cMethod.Origin '= ..GetSourceClass().Name)
		|| (cMethod.ClassMethod = 0) )
		{
			continue
		}
		
		s method = ##class(%Dictionary.MethodDefinition).%New()
		s method.parent = parent
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
		
		/// TODO implement serialization result
#;		s callControllerMethodCodeBlock = "##class("_cMethod.Origin_")."_cMethod.Name_"("_$lts(deserializedArgs)_")"
#;		
#;		if (cMethod.ReturnType = "")
#;		{
#;			d method.Implementation.WriteLine("	d "_callControllerMethodCodeBlock)
#;			$$$TOE(sc,methods.Insert(method))
#;			continue
#;		}
#;
#;		d method.Implementation.WriteLine("	s result = "_callControllerMethodCodeBlock)
		
		
		$$$TOE(sc,methods.Insert(method))
	}
	
	ret methods
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
	
	s targetName = "t0"_argName
	s targetType = $$$NormalizeClassName(argType)
	s targetArgs = targetArgs_$lb(targetName)

	s sourceName = "s0"_argName
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

