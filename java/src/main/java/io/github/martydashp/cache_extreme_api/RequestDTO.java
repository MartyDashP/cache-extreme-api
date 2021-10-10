package io.github.martydashp.cache_extreme_api;

public final class RequestDTO implements AbstractDTO {

    String controllerName;
    String methodName;

    RequestDTO(String controllerName, String methodName) {
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
