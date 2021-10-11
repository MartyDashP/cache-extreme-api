Class ExtremeAPI.AbstractController Extends %RegisteredObject [ Abstract ]
{

Projection ExtremeAPIController As ExtremeAPI.Projection.Controller(ROOTPACKAGENAME = "generatedClasses");

Projection JavaSpec As ExtremeAPI.Projection.JavaSpec(ROOTPACKAGENAME = "generatedClasses", TARGETDIR = "", TYPE = "Controller");

ClassMethod %Call(s0request As %List, args...) As %List
{
	s response = ##class(ExtremeAPI.ResponseDTO).%New()
	
	try 
	{
		#dim request as ExtremeAPI.Request
		s request = ##class(ExtremeAPI.RequestDTO).%Deserialize(s0request)
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

