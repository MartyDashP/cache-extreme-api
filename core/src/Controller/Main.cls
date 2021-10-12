Class JetAPI.Controller.Main Extends %RegisteredObject [ Abstract, Final ]
{

ClassMethod %jetApiInvoke(s0request As %List, args...) As %List [ Internal ]
{
	try 
	{
		#dim request as JetAPI.DTO.Request
		s request = ##class(JetAPI.DTO.Request).%jetApiDeserializeDTO(s0request)
		
		s proxyControllerName = ##class(JetAPI.Projection.ProxyController).GetProxyControllerName(request.ControllerName)
		s result = $classMethod(proxyControllerName, request.MethodName, args...)
		
		s response = ##class(JetAPI.DTO.Response).%New()
		s response.Status = response.#StatusOK
		s response.Payload = $lb(result)
	}
	catch ex
	{
		s response = ##class(JetAPI.DTO.Response).%New()
		s response.Status = response.#StatusException
	}
	
	ret response.%jetApiSerializeDTO()
}

}

