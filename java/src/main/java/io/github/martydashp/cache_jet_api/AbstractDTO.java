package io.github.martydashp.cache_jet_api;

import com.intersys.jdbc.CacheListReader;

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
