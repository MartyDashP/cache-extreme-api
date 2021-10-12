Class JetAPI.DTO.Response Extends JetAPI.DTO.Abstract [ Final ]
{

/// no projection
Projection JavaSpec As JetAPI.Projection.JavaSpec;

Parameter StatusOK = "ok";

Parameter StatusException = "exception";

Property Status As %String;

Property Payload As %List;

Property PayloadType As %String;

Property IsStream As %Boolean [ InitialExpression = 0 ];

ClassMethod Create(payload) As JetAPI.DTO.Response
{
	s response = ..%New()
	s response.Status = ..#StatusOK
	s response.Payload = $lb(payload)
	
	ret response
}

ClassMethod CreateStreamResponse(payload, payloadType As %String)
{
	#dim response as JetAPI.DTO.Response
	s response = ..Create(payload)
	s response.PayloadType = payloadType
	s response.IsStream = 1
	
	ret response
}

Method %jetApiSerializeDTO()
{
 	ret $lb(..Status, ..Payload, ..IsStream, ..PayloadType)
}

ClassMethod %jetApiDeserializeDTO(sObj As %List) [ Internal ]
{
}

}

