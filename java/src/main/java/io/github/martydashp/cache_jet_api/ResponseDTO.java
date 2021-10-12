package io.github.martydashp.cache_jet_api;

import com.intersys.jdbc.CacheListReader;

public final class ResponseDTO implements AbstractDTO {

    public static final String STATUS_OK = "ok";
    public static final String STATUS_EXCEPTION = "exception";

    String status;
    CacheListReader payload;

    @Override
    public void init(Deserializer deserializer) {
        status = deserializer.getValue(String.class);
        payload = deserializer.getCacheList();
    }

    @Override
    public void serialize(Serializer serializer) {
    }
}
