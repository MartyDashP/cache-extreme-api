Class JetAPI.DTO.Request Extends JetAPI.DTO.Abstract [ Final ]
{

/// no projection
Projection JavaSpec As JetAPI.Projection.JavaSpec;

Property ControllerName As %String;

Property MethodName As %String;

Method %jetApiSerializeDTO() [ Internal ]
{
}

ClassMethod %jetApiDeserializeDTO(sObj As %List)
{
	s request = ..%New()
	s request.ControllerName = $lg(sObj,1)
	s request.MethodName = $lg(sObj,2)
		
	ret request
}

}

