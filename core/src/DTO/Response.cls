Class JetAPI.DTO.Response Extends JetAPI.DTO.Abstract [ Final ]
{

/// no projection
Projection JavaSpec As JetAPI.Projection.JavaSpec;

Parameter StatusOK = "ok";

Parameter StatusException = "exception";

Property Status As %String;

Property Payload As %List;

Property PayloadKey As %String;

Property IsStream As %Boolean [ InitialExpression = 0 ];

ClassMethod Create(payload) As JetAPI.DTO.Response
{
	s response = ..%New()
	s response.Status = ..#StatusOK
	s response.Payload = $lb(payload)
	
	ret response
}

Method %jetApiSerializeDTO()
{
 	ret $lb(..Status, ..Payload, ..IsStream, ..PayloadKey)
}

ClassMethod %jetApiDeserializeDTO(sObj As %List) [ Internal ]
{
}

}

