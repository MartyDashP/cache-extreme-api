package io.github.martydashp.cache_jet_api;

import com.intersys.jdbc.CacheListReader;
import io.github.martydashp.cache_jet_api.dto.AbstractDTO;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class Deserializer {

    private final CacheListReader reader;

    public Deserializer(CacheListReader reader) {
        this.reader = reader;
    }

    public <T> T getValue(Class<T> clazz) {
        try {
            if (reader.isNull()) {
                reader.next();
                return null;
            }

            if (String.class == clazz) {
                return (T) reader.getString();
            } else if (Integer.class == clazz) {
                return (T) Integer.valueOf(reader.getInt());
            } else if (Double.class == clazz) {
                return (T) Double.valueOf(reader.getDouble());
            }

            throw new RuntimeException(String.format("%s is unsupported type", clazz.getCanonicalName()));
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    public <T extends AbstractDTO> T getObject(Class<T> clazz) {
        try {
            if (reader.isNull()) {
                reader.next();
                return null;
            }

            final CacheListReader subReader = reader.getInnerList();
            return T.deserialize(clazz, subReader);
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    public <T> List<T> getList(Function<Deserializer, T> func) {
        try {
            if (reader.isNull()) {
                reader.next();
                return null;
            }

            final CacheListReader subReader = reader.getInnerList();
            final List<T> listDTO = new ArrayList<>();
            final Deserializer d = new Deserializer(subReader);

            for (int i = 0; i < subReader.getLength(); i++) {
                T item = func.apply(d);
                listDTO.add(item);
            }

            return listDTO;
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    public CacheListReader getCacheList() {
        try {
            if (reader.isNull()) {
                reader.next();
                return null;
            }

            return reader.getInnerList();
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

}
