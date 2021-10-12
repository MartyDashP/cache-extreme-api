package io.github.martydashp.cache_jet_api.dto;

import com.intersys.jdbc.CacheListReader;
import io.github.martydashp.cache_jet_api.Deserializer;
import io.github.martydashp.cache_jet_api.Serializer;

public final class Response implements AbstractDTO {

    public static final String STATUS_OK = "ok";
    public static final String STATUS_EXCEPTION = "exception";

    String status;
    boolean isStream;
    String payloadType;
    CacheListReader payload;

    @Override
    public void init(Deserializer deserializer) {
        status = deserializer.getValue(String.class);
        payload = deserializer.getCacheList();
        isStream = deserializer.getValue(Boolean.class);
        payloadType = deserializer.getValue(String.class);
    }

    @Override
    public void serialize(Serializer serializer) {
    }

    public String getStatus() {
        return status;
    }

    public boolean isStream() {
        return isStream;
    }

    public String getPayloadType() {
        return payloadType;
    }

    public CacheListReader getPayload() {
        return payload;
    }
}
