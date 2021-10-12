Class JetAPI.Controller.Main Extends %RegisteredObject [ Abstract, Final ]
{

ClassMethod %InvokeController(s0request As %List, args...) As %List
{
	s response = ##class(JetAPI.DTO.Response).%New()
	
	try 
	{
		#dim request as JetAPI.DTO.Request
		s request = ##class(JetAPI.DTO.Request).%Deserialize(s0request)
		s response.Status = response.#StatusOK
		s response.Payload = $lb($classMethod(request.ControllerName, request.MethodName, args...))
	}
	catch ex
	{
		s response.Status = response.#StatusException
	}
	
	ret response.%Serialize()
}

}

