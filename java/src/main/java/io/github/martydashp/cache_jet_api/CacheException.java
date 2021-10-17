package io.github.martydashp.cache_jet_api;

import io.github.martydashp.cache_jet_api.dto.CacheExceptionDTO;

public class CacheException extends Exception {


    public final String name;
    public final String code;
    public final String data;
    public final String location;
    public final String innerException;

    public CacheException(CacheExceptionDTO dto) {
        super(dto.getMessage());
        this.name = dto.getName();
        this.code = dto.getCode();
        this.data = dto.getData();
        this.location = dto.getLocation();
        this.innerException = dto.getInnerException();
    }
}
