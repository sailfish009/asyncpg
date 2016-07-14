cdef bool_encode(ConnectionSettings settings, WriteBuffer buf, obj):
    if not cpython.PyBool_Check(obj):
        raise TypeError('a boolean is required (got type {})'.format(
            type(obj).__name__))

    buf.write_int32(1)
    buf.write_byte(b'\x01' if obj is True else b'\x00')


cdef bool_decode(ConnectionSettings settings, const char* data, int32_t len):
    return data[0] is b'\x01'


cdef int2_encode(ConnectionSettings settings, WriteBuffer buf, obj):
    cdef int32_t val = cpython.PyLong_AsLong(obj)
    if val < -32767 or val > 32767:
        raise ValueError(
            'integer too large to be encoded as INT2: {!r}'.format(val))

    buf.write_int32(2)
    buf.write_int16(val)


cdef int2_decode(ConnectionSettings settings, const char* data, int32_t len):
    return cpython.PyLong_FromLong(hton.unpack_int16(data))


cdef int4_encode(ConnectionSettings settings, WriteBuffer buf, obj):
    cdef int32_t val = cpython.PyLong_AsLong(obj)

    buf.write_int32(4)
    buf.write_int32(val)


cdef int4_decode(ConnectionSettings settings, const char* data, int32_t len):
    return cpython.PyLong_FromLong(hton.unpack_int32(data))


cdef int8_encode(ConnectionSettings settings, WriteBuffer buf, obj):
    cdef int64_t val = cpython.PyLong_AsLongLong(obj)
    buf.write_int32(8)
    buf.write_int64(val)


cdef int8_decode(ConnectionSettings settings, const char* data, int32_t len):
    return cpython.PyLong_FromLongLong(hton.unpack_int64(data))


cdef init_int_codecs():

    register_core_codec(BOOLOID,
                        <encode_func>&bool_encode,
                        <decode_func>&bool_decode,
                        PG_FORMAT_BINARY)

    register_core_codec(INT2OID,
                        <encode_func>&int2_encode,
                        <decode_func>&int2_decode,
                        PG_FORMAT_BINARY)

    register_core_codec(INT8OID,
                        <encode_func>&int8_encode,
                        <decode_func>&int8_decode,
                        PG_FORMAT_BINARY)
    int4oids = [
        INT4OID, OIDOID, TIDOID, XIDOID, CIDOID
    ]

    for int4oid in int4oids:
        register_core_codec(int4oid,
                            <encode_func>&int4_encode,
                            <decode_func>&int4_decode,
                            PG_FORMAT_BINARY)
