Class JetAPI.Exception.ConnectionException Extends (%Exception.AbstractException, JetAPI.DTO.Abstract)
{

/// no projection
Projection JavaSpec As JetAPI.Projection.JavaSpec;

Property InnerException As %String;

ClassMethod Create(ex As %Exception.AbstractException) As JetAPI.Exception.ConnectionException
{
	s connException = ..%New()
	s connException.Name = ex.Name
	s connException.Code = ex.Code
	s connException.Data = ex.Data
	s connException.Location = ex.Location
	s connException.InnerException = ex.InnerException
	
	ret connException
}

Method %jetApiSerializeDTO()
{
 	ret $lb(..Name, ..Code, ..Data, ..Location, ..InnerException)
}

}

