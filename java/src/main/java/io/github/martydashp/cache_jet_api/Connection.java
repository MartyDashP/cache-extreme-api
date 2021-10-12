package io.github.martydashp.cache_jet_api;

import com.intersys.jdbc.CacheConnection;
import com.intersys.jdbc.CacheListReader;
import io.github.martydashp.cache_jet_api.dto.AbstractDTO;
import io.github.martydashp.cache_jet_api.dto.Request;
import io.github.martydashp.cache_jet_api.dto.Response;
import java.util.Arrays;
import java.util.function.Function;

public class Connection extends CacheConnection {

    final String mainControllerClassName = "JetAPI.Controller.Main";
    final String mainMethodClassName = "%jetApiInvoke";

    public final void connect(String host, int superServerPort, String namespace, String username, String password) {

        if (host == null || host.isBlank()) {
            throw new NullPointerException("Host is undefined");
        }

        if (namespace == null || namespace.isBlank()) {
            throw new NullPointerException("Namespace is undefined");
        }

        this.xepConnect(host, superServerPort, namespace, username, password);
    }

    public void invoke(String controllerName, String methodName, Object... params) {
        invoke(controllerName, methodName, null, params);
    }

    public <T> T invoke(String controllerName, String methodName, Function<Deserializer, T> des, Object... params) {
        final Object[] requestData = {new Request(controllerName, methodName).getSerializedData(this)};

        final Object[] inputBuf = Arrays.copyOf(requestData, requestData.length + params.length);
        System.arraycopy(params, 0, inputBuf, requestData.length, params.length);

        final byte[] outputBuf = this.callBytesClassMethod(mainControllerClassName, mainMethodClassName, inputBuf);
        final CacheListReader reader = new CacheListReader(outputBuf, outputBuf.length, getServerLocale());
        final Response response = AbstractDTO.deserialize(Response.class, reader);

        switch (response.getStatus()) {
            case Response.STATUS_OK:
                if (des != null) {
                    Deserializer deserializer = new Deserializer(response.getPayload());
                    return des.apply(deserializer);
                }
                return null;

            case Response.STATUS_EXCEPTION:
                throw new RuntimeException("EXCEPTION");

            default:
                throw new RuntimeException("Unknown status");
        }
    }
}
