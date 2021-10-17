Class JetAPI.DTO.CacheException Extends JetAPI.DTO.Abstract
{

/// no projection
Projection JavaSpec As JetAPI.Projection.JavaSpec;

Property Name As %String;

Property Code As %String;

Property Location As %String;

Property Data As %String;

Property InnerException As %String;

ClassMethod Create(ex As %Exception.AbstractException) As JetAPI.DTO.CacheException
{
	s cacheException = ..%New()
	s cacheException.Name = ex.Name
	s cacheException.Code = ex.Code
	s cacheException.Data = ex.Data
	s cacheException.Location = ex.Location
	s cacheException.InnerException = ex.InnerException
	ret cacheException
}

Method %jetApiSerializeDTO()
{
 	ret $lb(..Name, ..Code, ..Data, ..Location, ..InnerException)
}

ClassMethod %jetApiDeserializeDTO(sObj As %List)
{
}

}

