Class JetAPI.DTO.Response Extends JetAPI.DTO.Abstract [ Final ]
{

/// no projection
Projection JavaSpec As JetAPI.Projection.JavaSpec;

Parameter StatusOK = "ok";

Parameter StatusException = "exception";

Property Status As %String;

Property Payload As %List;

Method %jetApiSerializeDTO()
{
 	ret $lb(..Status, ..Payload)
}

ClassMethod %jetApiDeserializeDTO(sObj As %List) [ Internal ]
{
}

}

