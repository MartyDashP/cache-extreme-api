package io.github.martydashp.cache_jet_api;

import com.intersys.jdbc.CacheConnection;
import com.intersys.jdbc.CacheListReader;
import com.intersys.jdbc.InStream;
import com.intersys.jdbc.OutStream;
import io.github.martydashp.cache_jet_api.dto.AbstractDTO;
import io.github.martydashp.cache_jet_api.dto.Request;
import io.github.martydashp.cache_jet_api.dto.Response;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.function.BiConsumer;
import java.util.function.Function;

public class Connection extends CacheConnection {

    static final byte[] CLASS_METHOD_TYPE = new byte[]{88, 77};
    static final int STATEMENT = 5;
    final static String MAIN_CONTROLLER_NAME = "JetAPI.Controller.Main";
    final static String METHOD_NAME = "%jetApiInvoke";
    final static String STREAM_METHOD_NAME = "%jetApiInvokeStream";

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
        final Object[] inputBuf = prepareInputBuffer(controllerName, methodName, params);
        final Response response = invokeJetApiController(inputBuf);

        if (des != null) {
            Deserializer deserializer = new Deserializer(response.getPayload());
            return des.apply(deserializer);
        }
        return null;
    }

    public void invokeStream(String controllerName, String methodName, BiConsumer<String, CacheListReader> streamHandler, Object... params) {
        invokeStream(controllerName, methodName, streamHandler, params);
    }

    public <T> T invokeStream(String controllerName, String methodName, BiConsumer<String, CacheListReader> streamHandler, Function<Deserializer, T> des, Object... params) {
        final Object[] inputBuf = prepareInputBuffer(controllerName, methodName, params);
        final Response response = invokeJetApiStreamController(streamHandler, inputBuf);

        if (des != null) {
            Deserializer deserializer = new Deserializer(response.getPayload());
            return des.apply(deserializer);
        }
        return null;
    }

    protected void checkResponse(Response response) {
        switch (response.getStatus()) {
            case Response.STATUS_OK:
                return;

            case Response.STATUS_EXCEPTION:
                throw new RuntimeException("EXCEPTION");

            default:
                throw new RuntimeException("Unknown status");
        }
    }

    protected OutStream getOutStream() {
        return (OutStream) getOutMessage();
    }

    protected InStream getInStream() {
        return (InStream) getInMessage();
    }

    protected Method getReadBytesXEPMethod() throws NoSuchMethodException {
        final InStream inStream = getInStream();
        final Method method = inStream.getClass().getDeclaredMethod("readBytesXEP");
        method.setAccessible(true);

        return method;
    }

    private Object[] prepareInputBuffer(String controllerName, String methodName, Object... params) {
        final Object[] requestData = {new Request(controllerName, methodName).getSerializedData(this)};

        final Object[] inputBuf = Arrays.copyOf(requestData, requestData.length + params.length);
        System.arraycopy(params, 0, inputBuf, requestData.length, params.length);

        return inputBuf;
    }

    private Response readResponse() throws NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        final byte[] data = (byte[]) getReadBytesXEPMethod().invoke(getInStream());
        final CacheListReader reader = new CacheListReader(data, data.length, getServerLocale());
        final Response response = AbstractDTO.deserialize(Response.class, reader);
        checkResponse(response);
        return response;
    }

    private Response readResponseStream(BiConsumer<String, CacheListReader> handler)
        throws InvocationTargetException, NoSuchMethodException, IllegalAccessException {
        Response response;

        while (true) {
            response = readResponse();

            if (!response.isStream()) {
                break;
            }

            handler.accept(response.getPayloadType(), response.getPayload());
        }

        return response;
    }

    private Response invokeJetApiController(Object... parameters) {
        synchronized (messageCount) {
            Response data;

            try {
                sendRequest(METHOD_NAME, parameters);
                data = readResponse();
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
            return data;
        }
    }

    private Response invokeJetApiStreamController(BiConsumer<String, CacheListReader> handler, Object... parameters) {
        synchronized (messageCount) {
            Response data;

            try {
                sendRequest(STREAM_METHOD_NAME, parameters);
                data = readResponseStream(handler);
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
            return data;
        }
    }

    private void sendRequest(String methodName, Object... parameters) throws SQLException {
        final OutStream outStream = getOutStream();
        outStream.wire.writeHeader(STATEMENT, CLASS_METHOD_TYPE);
        outStream.wire.set(MAIN_CONTROLLER_NAME);
        outStream.wire.set(methodName);
        addParameters(parameters);
        outStream.send(messageCount.getCount());
    }

    public void addParameters(Object[] parameters) throws SQLException {
        final OutStream outStream = getOutStream();

        if (parameters == null) {
            outStream.wire.set(0);
        } else {
            outStream.wire.set(parameters.length);

            for (int i = 0; i < parameters.length; ++i) {
                Object parameter = parameters[i];
                if (parameter == null) {
                    outStream.wire.setNull();
                } else if (parameter instanceof String) {
                    if (((String) parameter).equals("")) {
                        outStream.wire.setNull();
                    } else {
                        outStream.wire.set((String) parameter);
                    }
                } else if (parameter instanceof Integer) {
                    outStream.wire.set((Integer) parameter);
                } else if (parameter instanceof Long) {
                    outStream.wire.set((Long) parameter);
                } else if (parameter instanceof Double) {
                    outStream.wire.set((Double) parameter);
                } else {
                    if (!(parameter instanceof byte[])) {
                        throw new RuntimeException(
                            "Parameter type " + parameter.getClass().getName() + " is not supported in XEP");
                    }

                    outStream.wire.set((byte[]) ((byte[]) parameter));
                }
            }

        }
    }

}
