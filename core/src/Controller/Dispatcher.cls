Class JetAPI.Controller.Dispatcher Extends %RegisteredObject [ Abstract, Final ]
{

Parameter DeviceIO = "%jetApiDeviceIO";

ClassMethod %invoke(s0request As %List, args...) As %List [ Internal ]
{
	#dim response as JetAPI.DTO.Response
	try 
	{	
		#dim request as JetAPI.DTO.Request
		s request = ##class(JetAPI.DTO.Request).%jetApiDeserializeDTO(s0request)
		
		s proxyControllerName = ##class(JetAPI.Projection.ProxyController).GetProxyControllerName(request.ControllerName)
		s result = $classMethod(proxyControllerName, request.MethodName, args...)
		
		s response = ##class(JetAPI.DTO.Response).Create(result)
		s serializedResponse = response.%jetApiSerializeDTO()
	}
	catch ex
	{
		s serializedResponse = ..%handleException(ex)
	}

	ret serializedResponse
}

ClassMethod %invokeStream(s0request As %List, args...) As %List [ Internal ]
{
	s @..#DeviceIO = $io
	
	#dim response as JetAPI.DTO.Response
	try 
	{		
		#dim request as JetAPI.DTO.Request
		s request = ##class(JetAPI.DTO.Request).%jetApiDeserializeDTO(s0request)
		
		s proxyControllerName = ##class(JetAPI.Projection.ProxyController).GetProxyControllerName(request.ControllerName)
		d $classMethod(proxyControllerName, request.MethodName, args...)
		
		s response = ##class(JetAPI.DTO.Response).Create()
		s serializedResponse = response.%jetApiSerializeDTO()
	}
	catch ex
	{
		s serializedResponse = ..%handleException(ex)
	}
	
	k @..#DeviceIO
	
	ret serializedResponse
}

ClassMethod %handleException(exception As %Exception.AbstractException)
{
	s cacheException = ##class(JetAPI.DTO.CacheException).Create(exception)
	s response = ##class(JetAPI.DTO.Response).Create(cacheException.%jetApiSerializeDTO())
	s response.Status = response.#StatusException
	
	ret response.%jetApiSerializeDTO()
}

ClassMethod %sendStreamItem(payload, key As %String = "")
{
	s currentIO = $io
	use @..#DeviceIO
	
	#dim response as JetAPI.DTO.Response
	s response = ##class(JetAPI.DTO.Response).Create(payload)
	s response.PayloadKey = key
	s response.IsStream = 1
	s serializedResponse = response.%jetApiSerializeDTO()
	
	w ..%getResponseHeader(serializedResponse)
	w $c(0,0)
	w serializedResponse
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

