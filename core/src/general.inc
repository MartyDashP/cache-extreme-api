ROUTINE ExtremeAPI.general [Type=INC]
#Define E(%arg) %arg

///
#Define CollectSortedClassProperties(%props,%comClass) d $$$E(##class(ExtremeAPI.Util.Common).CollectSortedClassProperties(%props,%comClass))

///
#Define IsSupportedObjectTypeProperty(%arg) $$$E(##class(ExtremeAPI.Util.Common).IsSupportedObjectTypeProperty(%arg))

///
#Define IsSupportedObjectType(%arg) $$$E(##class(ExtremeAPI.Util.Common).IsSupportedObjectType(%arg))

///
#Define IsListType(%arg) $$$E(##class(ExtremeAPI.Util.Common).IsListType(%arg))

///
#Define IsDataType(%arg) $$$E(##class(ExtremeAPI.Util.Common).IsDataType(%arg))

///
#Define IsDataTypeProperty(%arg) $$$E(##class(ExtremeAPI.Util.Common).IsDataTypeProperty(%arg))

///
#Define IsCollectionProperty(%arg) $$$E(##class(ExtremeAPI.Util.Common).IsCollectionProperty(%arg))

///
#Define IsCollectionAsList(%arg) $$$E(##class(ExtremeAPI.Util.Common).IsCollectionAsList(%arg))

///
#Define GetCompiledClass(%arg) $$$E(##class(ExtremeAPI.Util.Common).GetCompiledClass(%arg))

///
#Define UnsupportedTypeExeption(%type) $$$E(##class(ExtremeAPI.Exception.UnsupportedTypeException).%New(%type))

///
#Define NormalizeClassName(%arg) $$$E(##class(ExtremeAPI.Util.Common).NormalizeClassName(%arg))

///
#Define GetMethodName(%arg) ##safeexpression(""""_$e("%arg",3,*)_"""")

///
#Define Wrap(%arg) ##safeexpression("""""""""_%arg_""""""""")
