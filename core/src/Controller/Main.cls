Class ExtremeAPI.Controller.Main Extends %RegisteredObject [ Abstract, Final ]
{

ClassMethod %InvokeController(s0request As %List, args...) As %List
{
	s response = ##class(ExtremeAPI.DTO.Response).%New()
	
	try 
	{
		#dim request as ExtremeAPI.DTO.Request
		s request = ##class(ExtremeAPI.DTO.Request).%Deserialize(s0request)
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

