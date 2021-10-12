Class JetAPI.DTO.Response Extends %RegisteredObject
{

Parameter StatusOK = "ok";

Parameter StatusException = "exception";

Property Status As %String;

Property Payload As %List;

Method %Serialize()
{
 	ret $lb(..Status, ..Payload)
}

}

