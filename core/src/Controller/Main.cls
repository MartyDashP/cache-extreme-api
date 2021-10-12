Class JetAPI.Controller.Main Extends %RegisteredObject [ Abstract, Final ]
{

Parameter DeviceIO = "%jetApiDeviceIO";

ClassMethod %jetApiInvoke(s0request As %List, args...) As %List [ Internal ]
{
	try 
	{
		#dim request as JetAPI.DTO.Request
		s request = ##class(JetAPI.DTO.Request).%jetApiDeserializeDTO(s0request)
		
		s proxyControllerName = ##class(JetAPI.Projection.ProxyController).GetProxyControllerName(request.ControllerName)
		s result = $classMethod(proxyControllerName, request.MethodName, args...)
		
		s response = ##class(JetAPI.DTO.Response).Create(result)
	}
	catch ex
	{
		s response = ##class(JetAPI.DTO.Response).%New()
		s response.Status = response.#StatusException
	}

	ret response.%jetApiSerializeDTO()
}

ClassMethod %jetApiInvokeStream(s0request As %List, args...) As %List [ Internal ]
{
	s @..#DeviceIO = $io
	
	s response = ..%jetApiInvoke(s0request, args...)
	
	k @..#DeviceIO
	
	ret response
}

ClassMethod %jetApiSendToStream(payload, payloadType As %String)
{
	s currentIO = $io
	use @..#DeviceIO
	
	s chunk = ##class(JetAPI.DTO.Response).CreateStreamResponse(payload, payloadType).%jetApiSerializeDTO()
	w ..%jetApiGetHeader(chunk)_$c(0,0)_chunk, !

	use currentIO
}

ClassMethod %jetApiGetHeader(data As %List) [ Private ]
{
	s length = $NCONVERT($l(data),"U4")
	s msgId = $NCONVERT(%qmsgid,"U4")
	s type = $NCONVERT(%qacn,"U4")
	
	ret length_msgId_type
}

}

