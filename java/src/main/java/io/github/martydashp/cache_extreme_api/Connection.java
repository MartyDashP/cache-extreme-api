package io.github.martydashp.cache_extreme_api;

import com.intersys.jdbc.CacheConnection;
import com.intersys.jdbc.CacheListReader;
import java.util.Arrays;
import java.util.function.Function;

public class Connection extends CacheConnection {

    final String mainControllerClassName = "ExtremeAPI.AbstractController";
    final String mainMethodClassName = "%Call";

    public final void connect(String host, int superServerPort, String namespace, String username, String password) {

        if (host == null || host.isBlank()) {
            throw new NullPointerException("Host is undefined");
        }

        if (namespace == null || namespace.isBlank()) {
            throw new NullPointerException("Namespace is undefined");
        }

        this.xepConnect(host, superServerPort, namespace, username, password);
    }

    public void callMethod(String controllerName, String methodName, Object... params) {
        callMethod(controllerName, methodName, null, params);
    }

    public <T> T callMethod(String controllerName, String methodName, Function<Deserializer, T> des, Object... params) {
        final Object[] requestData = {new RequestDTO(controllerName, methodName).getSerializedData(this)};

        final Object[] inputBuf = Arrays.copyOf(requestData, requestData.length + params.length);
        System.arraycopy(params, 0, inputBuf, requestData.length, params.length);

        final byte[] outputBuf = this.callBytesClassMethod(mainControllerClassName, mainMethodClassName, inputBuf);
        final CacheListReader reader = new CacheListReader(outputBuf, outputBuf.length, getServerLocale());
        final ResponseDTO response = AbstractDTO.deserialize(ResponseDTO.class, reader);

        switch (response.status) {
            case ResponseDTO.STATUS_OK:
                if (des != null) {
                    Deserializer deserializer = new Deserializer(response.payload);
                    return des.apply(deserializer);
                }
                return null;

            case ResponseDTO.STATUS_EXCEPTION:
                throw new RuntimeException("EXCEPTION");

            default:
                throw new RuntimeException("Unknown status");
        }
    }
}
