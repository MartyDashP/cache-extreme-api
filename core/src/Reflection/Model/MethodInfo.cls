Include JetAPI.general

Class JetAPI.Reflection.Model.MethodInfo Extends %RegisteredObject
{

Property Implementation As %String;

Property DesParamsInfo As list Of JetAPI.Reflection.Model.Attribute;

Property SerParamsInfo As list Of JetAPI.Reflection.Model.Attribute;

Property ResultInfo As JetAPI.Reflection.Model.Attribute;

ClassMethod Create() As JetAPI.Reflection.Model.MethodInfo
{
	s methodInfo = ..%New()
	s methodInfo.DesParamsInfo = ##class(%ListOfObjects).%New()
	s methodInfo.SerParamsInfo = ##class(%ListOfObjects).%New()
	
	ret methodInfo
}

Method AddImplLine(impl As %String)
{
	s ..Implementation = ..Implementation_impl_$$$CRLF
}

Method GetDesParamNameList()
{
	s list = ""
	ret:'$isObject(..DesParamsInfo) list
	
	f i=1:1:..DesParamsInfo.Count()
	{
		s list = list_$lb(..DesParamsInfo.GetAt(i).Alias)
	}
	
	ret list
}

Method GetMethodSpecs() As %List
{
	s specs = ""
	ret:'$isObject(..SerParamsInfo) specs
	
	f i=1:1:..SerParamsInfo.Count()
	{
		#dim paramInfo as JetAPI.Reflection.Model.Attribute
		s paramInfo = ..SerParamsInfo.GetAt(i)
		s list = list_$lb(paramInfo.Alias_":"_paramInfo.ElementType)
	}
	
	ret list
}

}

