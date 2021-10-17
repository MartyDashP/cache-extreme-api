Class JetAPI.Controller.Dispatcher Extends %RegisteredObject [ Abstract, Final ]
{

Parameter DeviceIO = "%jetApiDeviceIO";

ClassMethod %callMethodController(s0request As %List, args...) As JetAPI.DTO.Response [ Internal ]
{
	try 
	{
		#dim request as JetAPI.DTO.Request
		s request = ##class(JetAPI.DTO.Request).%jetApiDeserializeDTO(s0request)
		
		s proxyControllerName = ##class(JetAPI.Projection.ProxyController).GetProxyControllerName(request.ControllerName)
		s result = $classMethod(proxyControllerName, request.MethodName, args...)
		
		ret ##class(JetAPI.DTO.Response).Create(result)
	}
	catch ex
	{
		throw ##class(JetAPI.Exception.ConnectionException).Create(ex)
	}
}

ClassMethod %invoke(s0request As %List, args...) As %List [ Internal ]
{
	try 
	{		
		s response = ..%callMethodController(s0request, args...)
	}
	catch connectionException
	{
		s response = ##class(JetAPI.DTO.Response).Create(connectionException)
		s response.Status = response.#StatusException
	}

	ret response.%jetApiSerializeDTO()
}

ClassMethod %invokeStream(s0request As %List, args...) As %List [ Internal ]
{
	s @..#DeviceIO = $io
	
	try 
	{		
		d ..%callMethodController(s0request, args...)
		s response = ##class(JetAPI.DTO.Response).Create()
	}
	catch connectionException
	{
		s response = ##class(JetAPI.DTO.Response).Create(connectionException)
		s response.Status = response.#StatusException
	}
	
	k @..#DeviceIO
	
	ret response.%jetApiSerializeDTO()
}

ClassMethod %sendStreamItem(payload, payloadType As %String = "")
{
	s currentIO = $io
	use @..#DeviceIO
	
	#dim item as JetAPI.DTO.Response
	s item = ##class(JetAPI.DTO.Response).Create(payload)
	s item.PayloadType = payloadType
	s item.IsStream = 1
	
	w ..%getResponseHeader(item)
	w $c(0,0)
	w item.%jetApiSerializeDTO()
	w !

	use currentIO
}

ClassMethod %getResponseHeader(data As %List) [ Internal, Private ]
{
	s length = $NCONVERT($l(data),"U4")
	s msgId = $NCONVERT(%qmsgid,"U4")
	s type = $NCONVERT(%qacn,"U4")
	
	ret length_msgId_type
}

}

