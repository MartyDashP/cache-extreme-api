package io.github.martydashp.cache_jet_api;

import com.intersys.jdbc.CacheListReader;
import io.github.martydashp.cache_jet_api.dto.AbstractDTO;

public class ConnectionException extends Exception implements AbstractDTO {

    String name;
    String code;
    String location;
    String innerException;

    public ConnectionException(String name, String code, String message, String location, String innerException) {
        super(message);
        this.name = name;
        this.code = code;
        this.location = location;
        this.innerException = innerException;
    }

    static ConnectionException deserialize(CacheListReader cacheListReader) {
        try {
            return new ConnectionException(
                cacheListReader.getString(),
                cacheListReader.getString(),
                cacheListReader.getString(),
                cacheListReader.getString(),
                cacheListReader.getString());
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    @Override
    public void init(Deserializer deserializer) {
    }

    @Override
    public void serialize(Serializer serializer) {
    }
}
