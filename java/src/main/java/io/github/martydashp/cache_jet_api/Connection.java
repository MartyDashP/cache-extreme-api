package io.github.martydashp.cache_jet_api;

import com.intersys.jdbc.CacheConnection;
import com.intersys.jdbc.CacheListReader;
import com.intersys.jdbc.InStream;
import com.intersys.jdbc.OutStream;
import io.github.martydashp.cache_jet_api.dto.AbstractDTO;
import io.github.martydashp.cache_jet_api.dto.CacheExceptionDTO;
import io.github.martydashp.cache_jet_api.dto.Request;
import io.github.martydashp.cache_jet_api.dto.Response;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.Function;

public class Connection extends CacheConnection {

    static final byte[] CLASS_METHOD_TYPE = new byte[]{88, 77};
    static final int STATEMENT = 5;
    final static String DISPATCHER = "JetAPI.Controller.Dispatcher";
    final static String INVOKE = "%invoke";
    final static String INVOKE_STREAM = "%invokeStream";

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
        invoke(controllerName, methodName, (Function) null, params);
    }

    public <T> T invoke(String controllerName, String methodName, Function<Deserializer, T> deserializeFunc,
        Object... params) {

        final Object[] inputBuf = prepareInputBuffer(controllerName, methodName, params);
        final Response response = invokeJetApi(inputBuf);

        if (deserializeFunc == null) {
            return null;
        }

        Deserializer deserializer = new Deserializer(response.getPayload());
        return deserializeFunc.apply(deserializer);
    }

    public void invoke(String controllerName, String methodName,
        BiConsumer<String, CacheListReader> streamItemHandler, Object... params) {
        final Object[] inputBuf = prepareInputBuffer(controllerName, methodName, params);
        invokeJetApiStream(streamItemHandler, inputBuf);
    }

    public <T> void invoke(String controllerName, String methodName, Consumer<T> streamItemHandler,
        Function<Deserializer, T> deserializeFunc, Object... params) {
        final BiConsumer<String, CacheListReader> handler = (key, payload) -> {
            Deserializer deserializer = new Deserializer(payload);
            streamItemHandler.accept(deserializeFunc.apply(deserializer));
        };
        invoke(controllerName, methodName, (BiConsumer) handler, params);
    }

    protected void checkResponse(Response response) throws CacheException {
        switch (response.getStatus()) {
            case Response.STATUS_OK:
                return;

            case Response.STATUS_EXCEPTION:
                Deserializer deserializer = new Deserializer(response.getPayload());
                CacheExceptionDTO dto = deserializer.getObject(CacheExceptionDTO.class);
                throw new CacheException(dto);

            default:
                throw new RuntimeException("Unknown status");
        }
    }

    protected InStream getInputMessage() {
        return (InStream) getInMessage();
    }

    protected OutStream getOutputMessage() {
        return (OutStream) getOutMessage();
    }

    protected OutputStream getOutputStream() throws NoSuchFieldException, IllegalAccessException {
        final Field outputStreamField = OutStream.class.getDeclaredField("outputStream");
        outputStreamField.setAccessible(true);
        final OutStream outputMessage = getOutputMessage();

        return (OutputStream) outputStreamField.get(outputMessage);
    }

    protected Method getReadBytesXEPMethod() throws NoSuchMethodException {
        final InStream inStream = getInputMessage();
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

    private Response readResponse()
        throws NoSuchMethodException, InvocationTargetException, IllegalAccessException, CacheException {
        final byte[] data = (byte[]) getReadBytesXEPMethod().invoke(getInputMessage());
        final CacheListReader reader = new CacheListReader(data, data.length, getServerLocale());
        final Response response = AbstractDTO.deserialize(Response.class, reader);
        checkResponse(response);
        return response;
    }

    private Response invokeJetApi(Object... parameters) {
        synchronized (messageCount) {
            try {
                sendRequest(INVOKE, parameters);
                return readResponse();
            } catch (Exception exc) {
                throw new RuntimeException(exc);
            }
        }
    }

    private <T> void invokeJetApiStream(BiConsumer<String, CacheListReader> streamItemHandler, Object... parameters) {
        synchronized (messageCount) {
            try {
                sendRequest(INVOKE_STREAM, parameters);
                Response response;

                while (true) {
                    response = readResponse();

                    if (!response.isStream()) {
                        break;
                    }

                    streamItemHandler.accept(response.getPayloadKey(), response.getPayload());
                }
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
        }
    }

    private void sendRequest(String methodName, Object... parameters)
        throws SQLException, NoSuchFieldException, IllegalAccessException, IOException {
        final OutStream outputMessage = getOutputMessage();
        outputMessage.wire.writeHeader(STATEMENT, CLASS_METHOD_TYPE);
        outputMessage.wire.set(DISPATCHER);
        outputMessage.wire.set(methodName);
        addParameters(parameters);
        outputMessage.send(messageCount.getCount());
        getOutputStream().flush();
    }

    public void addParameters(Object[] parameters) throws SQLException {
        final OutStream outStream = getOutputMessage();

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
