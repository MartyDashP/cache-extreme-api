Class ExtremeAPI.RequestDTO Extends %RegisteredObject
{

Property ControllerName As %String;

Property MethodName As %String;

ClassMethod %Deserialize(serializedRequest As %List) As ExtremeAPI.RequestDTO
{
	s request = ..%New()
	s request.ControllerName = $lg(serializedRequest,1)
	s request.MethodName = $lg(serializedRequest,2)
		
	ret request
}

}

