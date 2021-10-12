package io.github.martydashp.cache_jet_api.dto;

import com.intersys.jdbc.CacheListReader;
import io.github.martydashp.cache_jet_api.Connection;
import io.github.martydashp.cache_jet_api.Deserializer;
import io.github.martydashp.cache_jet_api.Serializer;

public interface AbstractDTO {

    static <T extends AbstractDTO> T deserialize(Class<T> clazz, CacheListReader cacheListReader) {
        try {
            T dto = clazz.getDeclaredConstructor().newInstance();
            dto.init(cacheListReader);
            return dto;
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    default void init(CacheListReader cacheListReader) {
        Deserializer d = new Deserializer(cacheListReader);
        init(d);
    }

    default byte[] getSerializedData(Connection connection) {
        Serializer serializer = new Serializer(connection);
        serialize(serializer);
        return serializer.getData();
    }

    void init(Deserializer deserializer);

    void serialize(Serializer serializer);

}
