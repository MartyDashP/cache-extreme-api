ROUTINE JetAPI.general [Type=INC]
#Define E(%arg) %arg

///
#Define CollectSortedClassProperties(%props,%comClass) d $$$E(##class(JetAPI.Util.Common).CollectSortedClassProperties(%props,%comClass))

///
#Define IsSupportedObjectTypeProperty(%arg) $$$E(##class(JetAPI.Util.Common).IsSupportedObjectTypeProperty(%arg))

///
#Define IsSupportedObjectType(%arg) $$$E(##class(JetAPI.Util.Common).IsSupportedObjectType(%arg))

///
#Define IsListType(%arg) $$$E(##class(JetAPI.Util.Common).IsListType(%arg))

///
#Define IsDataType(%arg) $$$E(##class(JetAPI.Util.Common).IsDataType(%arg))

///
#Define IsDataTypeProperty(%arg) $$$E(##class(JetAPI.Util.Common).IsDataTypeProperty(%arg))

///
#Define IsCollectionProperty(%arg) $$$E(##class(JetAPI.Util.Common).IsCollectionProperty(%arg))

///
#Define IsCollectionAsList(%arg) $$$E(##class(JetAPI.Util.Common).IsCollectionAsList(%arg))

///
#Define GetCompiledClass(%arg) $$$E(##class(JetAPI.Util.Common).GetCompiledClass(%arg))

///
#Define UnsupportedTypeExeption(%type) $$$E(##class(JetAPI.Exception.UnsupportedTypeException).%New(%type))

///
#Define NormalizeClassName(%arg) $$$E(##class(JetAPI.Util.Common).NormalizeClassName(%arg))

///
#Define GetMethodName(%arg) ##safeexpression(""""_$e("%arg",3,*)_"""")

///
#Define Wrap(%arg) ##safeexpression("""""""""_%arg_""""""""")
