package io.github.martydashp.cache_jet_api.dto;

import io.github.martydashp.cache_jet_api.Deserializer;
import io.github.martydashp.cache_jet_api.Serializer;

public class CacheExceptionDTO implements AbstractDTO {

    String name;
    String code;
    String data;
    String location;
    String innerException;

    @Override
    public void init(Deserializer deserializer) {
        name = deserializer.getValue(String.class);
        code = deserializer.getValue(String.class);
        data = deserializer.getValue(String.class);
        location = deserializer.getValue(String.class);
        innerException = deserializer.getValue(String.class);
    }

    @Override
    public void serialize(Serializer serializer) {
    }

    public String getMessage() {
        final String template = "\n Name: %s;\n Code: %s;\n Data: %s;\n Location: %s;\n InnerException: %s\n";
        return String.format(template, name, code, data, location, innerException);
    }

    public String getName() {
        return name;
    }

    public String getCode() {
        return code;
    }

    public String getData() {
        return data;
    }

    public String getLocation() {
        return location;
    }

    public String getInnerException() {
        return innerException;
    }
}
