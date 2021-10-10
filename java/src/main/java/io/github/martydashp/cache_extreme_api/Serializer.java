package io.github.martydashp.cache_extreme_api;

import com.intersys.jdbc.CacheListBuilder;
import java.util.List;
import java.util.function.BiConsumer;

public class Serializer {

    private final Connection connection;
    private final CacheListBuilder lb;

    public static CacheListBuilder createLB(final Connection connection) {
        return new CacheListBuilder(connection.getServerLocale());
    }

    public static <T extends AbstractDTO> byte[] serializeObject(Connection connection, T object) {
        if (object == null) {
            return null;
        }

        return object.getSerializedData(connection);
    }

    public static <T> byte[] serializeList(Connection connection, List<T> list, BiConsumer<Serializer, T> func) {
        if (list == null) {
            return null;
        }

        Serializer serializer = new Serializer(connection);
        list.forEach(i -> func.accept(serializer, i));
        return serializer.getData();
    }

    public Serializer(final Connection connection) {
        this.connection = connection;
        this.lb = createLB(connection);
    }

    public byte[] getData() {
        return lb.getData();
    }

    public CacheListBuilder getLB() {
        return lb;
    }

    public <T> void setValue(T value) {
        try {
            lb.setObject(value);
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    public <T extends AbstractDTO> void setObject(T value) {
        try {
            byte[] data = serializeObject(connection, value);

            if (data == null) {
                lb.setNull();
                return;
            }

            lb.set(data);
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    public <T> void setList(List<T> list, BiConsumer<Serializer, T> func) {
        try {
            byte[] data = serializeList(connection, list, func);

            if (data == null) {
                lb.setNull();
                return;
            }

            lb.set(data);
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

}
