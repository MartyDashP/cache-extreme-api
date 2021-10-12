package io.github.martydashp.cache_jet_api.dto;

import io.github.martydashp.cache_jet_api.Deserializer;
import io.github.martydashp.cache_jet_api.Serializer;

public final class Request implements AbstractDTO {

    String controllerName;
    String methodName;

    public Request(String controllerName, String methodName) {
        this.controllerName = controllerName;
        this.methodName = methodName;
    }

    @Override
    public void init(Deserializer deserializer) {
    }

    @Override
    public void serialize(Serializer serializer) {
        serializer.setValue(controllerName);
        serializer.setValue(methodName);
    }
}
