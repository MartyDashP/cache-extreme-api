Class JetAPI.Reflection.Model.Attribute Extends %RegisteredObject
{

Property Name As %String;

Property Alias As %String;

Property ElementType As %String;

Property CollectionType As %String;

Property StreamType As %String;

Method IsStream()
{
	ret (..StreamType '= "")
}

Method IsCollection()
{
	ret (..CollectionType '= "")
}

Method IsVoid()
{
	ret ((..ElementType = "") && (..CollectionType = ""))
}

Method IsList()
{
	ret ##class(JetAPI.Reflection.Type.COS).IsList(..CollectionType)
}

Method IsLB()
{
	ret ##class(JetAPI.Reflection.Type.COS).IsLB(..ElementType)
}

Method IsDataType()
{
	ret ##class(JetAPI.Reflection.Type.COS).IsDataType(..ElementType)
}

Method IsJetApiDTO()
{
	ret ##class(JetAPI.Reflection.Type.COS).IsJetApiDto(..ElementType)
}

Method Clone() As JetAPI.Reflection.Model.Attribute
{
	s newInst = ..%New()
 	s newInst.Name = ..Name
	s newInst.Alias= ..Alias
	s newInst.ElementType = ..ElementType
	s newInst.CollectionType = ..CollectionType
	s newInst.StreamType = ..StreamType
	
	ret newInst
}

Method ToString() As %String
{
	ret "[Name: "_..Name
	_" Alias: "_..Alias
	_" ElementType: "_..ElementType
	_" CollectionType: "_..CollectionType
	_" StreamType: "_..StreamType
	_"]"
}

}

