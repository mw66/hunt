module hunt.container.ByteBuffer;

import std.container.array;

import hunt.container.Buffer;
import hunt.container.StringBuffer;

import hunt.lang.common;
import hunt.string.StringBuilder;
import hunt.lang.exception;

import std.bitmanip;

abstract class ByteBuffer : Buffer
{
    protected byte[] hb; // Non-null only for heap buffers
    
    protected int offset;

    bool bigEndian = true;                                  // package-private
        
    // bool nativeByteOrder                             // package-private
    //     = (Bits.byteOrder() == ByteOrder.BIG_ENDIAN);

    /**
     * Retrieves this buffer's byte order.
     *
     * <p> The byte order is used when reading or writing multibyte values, and
     * when creating buffers that are views of this byte buffer.  The order of
     * a newly-created byte buffer is always {@link ByteOrder#BIG_ENDIAN
     * BIG_ENDIAN}.  </p>
     *
     * @return  This buffer's byte order
     */
    final ByteOrder order() {
        return bigEndian ? ByteOrder.BigEndian : ByteOrder.LittleEndian;
    }

    /**
     * Modifies this buffer's byte order.
     *
     * @param  bo
     *         The new byte order,
     *         either {@link ByteOrder#BIG_ENDIAN BIG_ENDIAN}
     *         or {@link ByteOrder#LITTLE_ENDIAN LITTLE_ENDIAN}
     *
     * @return  This buffer
     */
    final ByteBuffer order(ByteOrder bo) {
        bigEndian = (bo == ByteOrder.BigEndian);
        // nativeByteOrder =
        //     (bigEndian == (Bits.byteOrder() == ByteOrder.BigEndian));
        return this;
    }


    // Creates a new buffer with the given mark, position, limit, capacity,
    // backing array, and array offset
    //
    this(int mark, int pos, int lim, int cap, // package-private
            byte[] hb, int offset)
    {
        super(mark, pos, lim, cap);
        this.hb = hb;
        this.offset = offset;
    }

    // Creates a new buffer with the given mark, position, limit, and capacity
    //
    this(int mark, int pos, int lim, int cap)
    { // package-private
        this(mark, pos, lim, cap, null, 0);
    }

    // this(int capacity = 1024)
    // {
    //     super(capacity);
    // }

    /**
     * Allocates a new direct byte buffer.
     *
     * <p> The new buffer's position will be zero, its limit will be its
     * capacity, its mark will be undefined, and each of its elements will be
     * initialized to zero.  Whether or not it has a
     * {@link #hasArray backing array} is unspecified.
     *
     * @param  capacity
     *         The new buffer's capacity, in bytes
     *
     * @return  The new byte buffer
     *
     * @throws  IllegalArgumentException
     *          If the <tt>capacity</tt> is a negative integer
     */
    // static ByteBuffer allocateDirect(int capacity) {
    //     return new HeapByteBuffer(capacity, capacity); // DirectByteBuffer(capacity);
    // }

    /**
     * Allocates a new byte buffer.
     *
     * <p> The new buffer's position will be zero, its limit will be its
     * capacity, its mark will be undefined, and each of its elements will be
     * initialized to zero.  It will have a {@link #array backing array},
     * and its {@link #arrayOffset array offset} will be zero.
     *
     * @param  capacity
     *         The new buffer's capacity, in bytes
     *
     * @return  The new byte buffer
     *
     * @throws  IllegalArgumentException
     *          If the <tt>capacity</tt> is a negative integer
     */
    static ByteBuffer allocate(int capacity) {
        if (capacity < 0)
            throw new IllegalArgumentException("");
        return new HeapByteBuffer(capacity, capacity);
    }

    /**
     * Wraps a byte array into a buffer.
     *
     * <p> The new buffer will be backed by the given byte array;
     * that is, modifications to the buffer will cause the array to be modified
     * and vice versa.  The new buffer's capacity will be
     * <tt>array.length</tt>, its position will be <tt>offset</tt>, its limit
     * will be <tt>offset + length</tt>, and its mark will be undefined.  Its
     * {@link #array backing array} will be the given array, and
     * its {@link #arrayOffset array offset} will be zero.  </p>
     *
     * @param  array
     *         The array that will back the new buffer
     *
     * @param  offset
     *         The offset of the subarray to be used; must be non-negative and
     *         no larger than <tt>array.length</tt>.  The new buffer's position
     *         will be set to this value.
     *
     * @param  length
     *         The length of the subarray to be used;
     *         must be non-negative and no larger than
     *         <tt>array.length - offset</tt>.
     *         The new buffer's limit will be set to <tt>offset + length</tt>.
     *
     * @return  The new byte buffer
     *
     * @throws  IndexOutOfBoundsException
     *          If the preconditions on the <tt>offset</tt> and <tt>length</tt>
     *          parameters do not hold
     */
    static ByteBuffer wrap(byte[] array,
                                    int offset, int length)
    {
        try {
            return new HeapByteBuffer(array, offset, length);
        } catch (IllegalArgumentException x) {
            throw new IndexOutOfBoundsException("");
        }
    }

    /**
     * Wraps a byte array into a buffer.
     *
     * <p> The new buffer will be backed by the given byte array;
     * that is, modifications to the buffer will cause the array to be modified
     * and vice versa.  The new buffer's capacity and limit will be
     * <tt>array.length</tt>, its position will be zero, and its mark will be
     * undefined.  Its {@link #array backing array} will be the
     * given array, and its {@link #arrayOffset array offset>} will
     * be zero.  </p>
     *
     * @param  array
     *         The array that will back this buffer
     *
     * @return  The new byte buffer
     */
    static ByteBuffer wrap(byte[] array) {
        return wrap(array, 0, cast(int)array.length);
    }


    /**
     * Creates a new byte buffer whose content is a shared subsequence of
     * this buffer's content.
     *
     * <p> The content of the new buffer will start at this buffer's current
     * position.  Changes to this buffer's content will be visible in the new
     * buffer, and vice versa; the two buffers' position, limit, and mark
     * values will be independent.
     *
     * <p> The new buffer's position will be zero, its capacity and its limit
     * will be the number of bytes remaining in this buffer, and its mark
     * will be undefined.  The new buffer will be direct if, and only if, this
     * buffer is direct, and it will be read-only if, and only if, this buffer
     * is read-only.  </p>
     *
     * @return  The new byte buffer
     */
    abstract ByteBuffer slice();

    // void clear()
    // {
    //     hb = null;
    //     position = 0;
    //     limit = 0;
    // }

    /**
     * Creates a new byte buffer that shares this buffer's content.
     *
     * <p> The content of the new buffer will be that of this buffer.  Changes
     * to this buffer's content will be visible in the new buffer, and vice
     * versa; the two buffers' position, limit, and mark values will be
     * independent.
     *
     * <p> The new buffer's capacity, limit, position, and mark values will be
     * identical to those of this buffer.  The new buffer will be direct if,
     * and only if, this buffer is direct, and it will be read-only if, and
     * only if, this buffer is read-only.  </p>
     *
     * @return  The new byte buffer
     */
    abstract ByteBuffer duplicate();

    /**
     * Creates a new, read-only byte buffer that shares this buffer's
     * content.
     *
     * <p> The content of the new buffer will be that of this buffer.  Changes
     * to this buffer's content will be visible in the new buffer; the new
     * buffer itself, however, will be read-only and will not allow the shared
     * content to be modified.  The two buffers' position, limit, and mark
     * values will be independent.
     *
     * <p> The new buffer's capacity, limit, position, and mark values will be
     * identical to those of this buffer.
     *
     * <p> If this buffer is itself read-only then this method behaves in
     * exactly the same way as the {@link #duplicate duplicate} method.  </p>
     *
     * @return  The new, read-only byte buffer
     */
    abstract ByteBuffer asReadOnlyBuffer();


    // -- Singleton get/put methods --

    /**
     * Relative <i>get</i> method.  Reads the byte at this buffer's
     * current position, and then increments the position.
     *
     * @return  The byte at the buffer's current position
     *
     * @throws  BufferUnderflowException
     *          If the buffer's current position is not smaller than its limit
     */
    abstract byte get();

    /**
     * Relative <i>put</i> method&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes the given byte into this buffer at the current
     * position, and then increments the position. </p>
     *
     * @param  b
     *         The byte to be written
     *
     * @return  This buffer
     *
     * @throws  BufferOverflowException
     *          If this buffer's current position is not smaller than its limit
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    abstract ByteBuffer put(byte b);

    /**
     * Absolute <i>get</i> method.  Reads the byte at the given
     * index.
     *
     * @param  index
     *         The index from which the byte will be read
     *
     * @return  The byte at the given index
     *
     * @throws  IndexOutOfBoundsException
     *          If <tt>index</tt> is negative
     *          or not smaller than the buffer's limit
     */
    abstract byte get(int index);



    /**
     * Absolute <i>put</i> method&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes the given byte into this buffer at the given
     * index. </p>
     *
     * @param  index
     *         The index at which the byte will be written
     *
     * @param  b
     *         The byte value to be written
     *
     * @return  This buffer
     *
     * @throws  IndexOutOfBoundsException
     *          If <tt>index</tt> is negative
     *          or not smaller than the buffer's limit
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    abstract ByteBuffer put(int index, byte b);


    // -- Bulk get operations --

    /**
     * Relative bulk <i>get</i> method.
     *
     * <p> This method transfers bytes from this buffer into the given
     * destination array.  If there are fewer bytes remaining in the
     * buffer than are required to satisfy the request, that is, if
     * <tt>length</tt>&nbsp;<tt>&gt;</tt>&nbsp;<tt>remaining()</tt>, then no
     * bytes are transferred and a {@link BufferUnderflowException} is
     * thrown.
     *
     * <p> Otherwise, this method copies <tt>length</tt> bytes from this
     * buffer into the given array, starting at the current position of this
     * buffer and at the given offset in the array.  The position of this
     * buffer is then incremented by <tt>length</tt>.
     *
     * <p> In other words, an invocation of this method of the form
     * <tt>src.get(dst,&nbsp;off,&nbsp;len)</tt> has exactly the same effect as
     * the loop
     *
     * <pre>{@code
     *     for (int i = off; i < off + len; i++)
     *         dst[i] = src.get():
     * }</pre>
     *
     * except that it first checks that there are sufficient bytes in
     * this buffer and it is potentially much more efficient.
     *
     * @param  dst
     *         The array into which bytes are to be written
     *
     * @param  offset
     *         The offset within the array of the first byte to be
     *         written; must be non-negative and no larger than
     *         <tt>dst.length</tt>
     *
     * @param  length
     *         The maximum number of bytes to be written to the given
     *         array; must be non-negative and no larger than
     *         <tt>dst.length - offset</tt>
     *
     * @return  This buffer
     *
     * @throws  BufferUnderflowException
     *          If there are fewer than <tt>length</tt> bytes
     *          remaining in this buffer
     *
     * @throws  IndexOutOfBoundsException
     *          If the preconditions on the <tt>offset</tt> and <tt>length</tt>
     *          parameters do not hold
     */
    ByteBuffer get(byte[] dst, int offset, int length) {
        checkBounds(offset, length, cast(int)dst.length);
        if (length > remaining())
            throw new BufferUnderflowException("");
        int end = offset + length;
        for (int i = offset; i < end; i++)
            dst[i] = get();
        return this;
    }

    /**
     * Relative bulk <i>get</i> method.
     *
     * <p> This method transfers bytes from this buffer into the given
     * destination array.  An invocation of this method of the form
     * <tt>src.get(a)</tt> behaves in exactly the same way as the invocation
     *
     * <pre>
     *     src.get(a, 0, a.length) </pre>
     *
     * @param   dst
     *          The destination array
     *
     * @return  This buffer
     *
     * @throws  BufferUnderflowException
     *          If there are fewer than <tt>length</tt> bytes
     *          remaining in this buffer
     */
    ByteBuffer get(byte[] dst) {
        return get(dst, 0, cast(int)dst.length);
    }


    // -- Bulk put operations --

    /**
     * Relative bulk <i>put</i> method&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> This method transfers the bytes remaining in the given source
     * buffer into this buffer.  If there are more bytes remaining in the
     * source buffer than in this buffer, that is, if
     * <tt>src.remaining()</tt>&nbsp;<tt>&gt;</tt>&nbsp;<tt>remaining()</tt>,
     * then no bytes are transferred and a {@link
     * BufferOverflowException} is thrown.
     *
     * <p> Otherwise, this method copies
     * <i>n</i>&nbsp;=&nbsp;<tt>src.remaining()</tt> bytes from the given
     * buffer into this buffer, starting at each buffer's current position.
     * The positions of both buffers are then incremented by <i>n</i>.
     *
     * <p> In other words, an invocation of this method of the form
     * <tt>dst.put(src)</tt> has exactly the same effect as the loop
     *
     * <pre>
     *     while (src.hasRemaining())
     *         dst.put(src.get()); </pre>
     *
     * except that it first checks that there is sufficient space in this
     * buffer and it is potentially much more efficient.
     *
     * @param  src
     *         The source buffer from which bytes are to be read;
     *         must not be this buffer
     *
     * @return  This buffer
     *
     * @throws  BufferOverflowException
     *          If there is insufficient space in this buffer
     *          for the remaining bytes in the source buffer
     *
     * @throws  IllegalArgumentException
     *          If the source buffer is this buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    ByteBuffer put(ByteBuffer src) {
        if (src == this)
            throw new IllegalArgumentException("");
        if (isReadOnly())
            throw new ReadOnlyBufferException("");
        int n = src.remaining();
        if (n > remaining())
            throw new BufferOverflowException("");
        for (int i = 0; i < n; i++)
            put(src.get());
        return this;
    }

    /**
     * Relative bulk <i>put</i> method&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> This method transfers bytes into this buffer from the given
     * source array.  If there are more bytes to be copied from the array
     * than remain in this buffer, that is, if
     * <tt>length</tt>&nbsp;<tt>&gt;</tt>&nbsp;<tt>remaining()</tt>, then no
     * bytes are transferred and a {@link BufferOverflowException} is
     * thrown.
     *
     * <p> Otherwise, this method copies <tt>length</tt> bytes from the
     * given array into this buffer, starting at the given offset in the array
     * and at the current position of this buffer.  The position of this buffer
     * is then incremented by <tt>length</tt>.
     *
     * <p> In other words, an invocation of this method of the form
     * <tt>dst.put(src,&nbsp;off,&nbsp;len)</tt> has exactly the same effect as
     * the loop
     *
     * <pre>{@code
     *     for (int i = off; i < off + len; i++)
     *         dst.put(a[i]);
     * }</pre>
     *
     * except that it first checks that there is sufficient space in this
     * buffer and it is potentially much more efficient.
     *
     * @param  src
     *         The array from which bytes are to be read
     *
     * @param  offset
     *         The offset within the array of the first byte to be read;
     *         must be non-negative and no larger than <tt>array.length</tt>
     *
     * @param  length
     *         The number of bytes to be read from the given array;
     *         must be non-negative and no larger than
     *         <tt>array.length - offset</tt>
     *
     * @return  This buffer
     *
     * @throws  BufferOverflowException
     *          If there is insufficient space in this buffer
     *
     * @throws  IndexOutOfBoundsException
     *          If the preconditions on the <tt>offset</tt> and <tt>length</tt>
     *          parameters do not hold
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    ByteBuffer put(byte[] src, int offset, int length) {
        checkBounds(offset, length, cast(int)src.length);
        if (length > remaining())
            throw new BufferOverflowException("");
        int end = offset + length;
        for (int i = offset; i < end; i++)
            this.put(src[i]);
        return this;
    }

    /**
     * Relative bulk <i>put</i> method&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> This method transfers the entire content of the given source
     * byte array into this buffer.  An invocation of this method of the
     * form <tt>dst.put(a)</tt> behaves in exactly the same way as the
     * invocation
     *
     * <pre>
     *     dst.put(a, 0, a.length) </pre>
     *
     * @param   src
     *          The source array
     *
     * @return  This buffer
     *
     * @throws  BufferOverflowException
     *          If there is insufficient space in this buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    final ByteBuffer put(byte[] src) {
        return put(src, 0, cast(int)src.length);
    }

    final ByteBuffer put(string src) {
        return put(cast(byte[])src, 0, cast(int)src.length);
    }

    /**
     * Relative <i>get</i> method for reading a short value.
     *
     * <p> Reads the next two bytes at this buffer's current position,
     * composing them into a short value according to the current byte order,
     * and then increments the position by two.  </p>
     *
     * @return  The short value at the buffer's current position
     *
     * @throws  BufferUnderflowException
     *          If there are fewer than two bytes
     *          remaining in this buffer
     */
    abstract short getShort();

    /**
     * Relative <i>put</i> method for writing a short
     * value&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes two bytes containing the given short value, in the
     * current byte order, into this buffer at the current position, and then
     * increments the position by two.  </p>
     *
     * @param  value
     *         The short value to be written
     *
     * @return  This buffer
     *
     * @throws  BufferOverflowException
     *          If there are fewer than two bytes
     *          remaining in this buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    abstract ByteBuffer putShort(short value);

    /**
     * Absolute <i>get</i> method for reading a short value.
     *
     * <p> Reads two bytes at the given index, composing them into a
     * short value according to the current byte order.  </p>
     *
     * @param  index
     *         The index from which the bytes will be read
     *
     * @return  The short value at the given index
     *
     * @throws  IndexOutOfBoundsException
     *          If <tt>index</tt> is negative
     *          or not smaller than the buffer's limit,
     *          minus one
     */
    abstract short getShort(int index);

    /**
     * Absolute <i>put</i> method for writing a short
     * value&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes two bytes containing the given short value, in the
     * current byte order, into this buffer at the given index.  </p>
     *
     * @param  index
     *         The index at which the bytes will be written
     *
     * @param  value
     *         The short value to be written
     *
     * @return  This buffer
     *
     * @throws  IndexOutOfBoundsException
     *          If <tt>index</tt> is negative
     *          or not smaller than the buffer's limit,
     *          minus one
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    abstract ByteBuffer putShort(int index, short value);

    /**
     * Relative <i>get</i> method for reading an int value.
     *
     * <p> Reads the next four bytes at this buffer's current position,
     * composing them into an int value according to the current byte order,
     * and then increments the position by four.  </p>
     *
     * @return  The int value at the buffer's current position
     *
     * @throws  BufferUnderflowException
     *          If there are fewer than four bytes
     *          remaining in this buffer
     */
    abstract int getInt();

    /**
     * Relative <i>put</i> method for writing an int
     * value&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes four bytes containing the given int value, in the
     * current byte order, into this buffer at the current position, and then
     * increments the position by four.  </p>
     *
     * @param  value
     *         The int value to be written
     *
     * @return  This buffer
     *
     * @throws  BufferOverflowException
     *          If there are fewer than four bytes
     *          remaining in this buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    abstract ByteBuffer putInt(int value);

    /**
     * Absolute <i>get</i> method for reading an int value.
     *
     * <p> Reads four bytes at the given index, composing them into a
     * int value according to the current byte order.  </p>
     *
     * @param  index
     *         The index from which the bytes will be read
     *
     * @return  The int value at the given index
     *
     * @throws  IndexOutOfBoundsException
     *          If {@code index} is negative
     *          or not smaller than the buffer's limit,
     *          minus three
     */
    abstract int getInt(int index);

    /**
     * Absolute <i>put</i> method for writing an int
     * value&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes four bytes containing the given int value, in the
     * current byte order, into this buffer at the given index.  </p>
     *
     * @param  index
     *         The index at which the bytes will be written
     *
     * @param  value
     *         The int value to be written
     *
     * @return  This buffer
     *
     * @throws  IndexOutOfBoundsException
     *          If {@code index} is negative
     *          or not smaller than the buffer's limit,
     *          minus three
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    abstract ByteBuffer putInt(int index, int value);


    // -- Other stuff --

    /**
     * Tells whether or not this buffer is backed by an accessible byte
     * array.
     *
     * <p> If this method returns <tt>true</tt> then the {@link #array() array}
     * and {@link #arrayOffset() arrayOffset} methods may safely be invoked.
     * </p>
     *
     * @return  <tt>true</tt> if, and only if, this buffer
     *          is backed by an array and is not read-only
     */
    final override bool hasArray() {
        return (hb !is null) && !isReadOnly;
    }

    /**
     * Returns the byte array that backs this
     * buffer&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Modifications to this buffer's content will cause the returned
     * array's content to be modified, and vice versa.
     *
     * <p> Invoke the {@link #hasArray hasArray} method before invoking this
     * method in order to ensure that this buffer has an accessible backing
     * array.  </p>
     *
     * @return  The array that backs this buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is backed by an array but is read-only
     *
     * @throws  UnsupportedOperationException
     *          If this buffer is not backed by an accessible array
     */
    final byte[] array() {
        if (hb is null)
            throw new UnsupportedOperationException("");
        if (isReadOnly)
            throw new ReadOnlyBufferException("");
        return hb;
    }

    /**
     * Returns the offset within this buffer's backing array of the first
     * element of the buffer&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> If this buffer is backed by an array then buffer position <i>p</i>
     * corresponds to array index <i>p</i>&nbsp;+&nbsp;<tt>arrayOffset()</tt>.
     *
     * <p> Invoke the {@link #hasArray hasArray} method before invoking this
     * method in order to ensure that this buffer has an accessible backing
     * array.  </p>
     *
     * @return  The offset within this buffer's array
     *          of the first element of the buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is backed by an array but is read-only
     *
     * @throws  UnsupportedOperationException
     *          If this buffer is not backed by an accessible array
     */
    final override int arrayOffset() {
        if (hb is null)
            throw new UnsupportedOperationException("");
        if (isReadOnly)
            throw new ReadOnlyBufferException("");
        return offset;
    }

    /**
     * Compacts this buffer&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> The bytes between the buffer's current position and its limit,
     * if any, are copied to the beginning of the buffer.  That is, the
     * byte at index <i>p</i>&nbsp;=&nbsp;<tt>position()</tt> is copied
     * to index zero, the byte at index <i>p</i>&nbsp;+&nbsp;1 is copied
     * to index one, and so forth until the byte at index
     * <tt>limit()</tt>&nbsp;-&nbsp;1 is copied to index
     * <i>n</i>&nbsp;=&nbsp;<tt>limit()</tt>&nbsp;-&nbsp;<tt>1</tt>&nbsp;-&nbsp;<i>p</i>.
     * The buffer's position is then set to <i>n+1</i> and its limit is set to
     * its capacity.  The mark, if defined, is discarded.
     *
     * <p> The buffer's position is set to the number of bytes copied,
     * rather than to zero, so that an invocation of this method can be
     * followed immediately by an invocation of another relative <i>put</i>
     * method. </p>
     *

     *
     * <p> Invoke this method after writing data from a buffer in case the
     * write was incomplete.  The following loop, for example, copies bytes
     * from one channel to another via the buffer <tt>buf</tt>:
     *
     * <blockquote><pre>{@code
     *   buf.clear();          // Prepare buffer for use
     *   while (in.read(buf) >= 0 || buf.position != 0) {
     *       buf.flip();
     *       out.write(buf);
     *       buf.compact();    // In case of partial write
     *   }
     * }</pre></blockquote>
     *

     *
     * @return  This buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    abstract ByteBuffer compact();

    /**
     * Tells whether or not this byte buffer is direct.
     *
     * @return  <tt>true</tt> if, and only if, this buffer is direct
     */
    // abstract bool isDirect();


    /**
     * Relative <i>get</i> method for reading an int value.
     *
     * <p> Reads the next four bytes at this buffer's current position,
     * composing them into an int value according to the current byte order,
     * and then increments the position by four.  </p>
     *
     * @return  The int value at the buffer's current position
     *
     * @throws  BufferUnderflowException
     *          If there are fewer than four bytes
     *          remaining in this buffer
     */
    T get(T)() if( !is(T == byte))
    {
        enum len = T.sizeof;
        int index = ix(nextGetIndex(len));
        ubyte[len] bytes = cast(ubyte[])hb[index .. index+len];
        return bigEndianToNative!T(bytes);
    }

    /**
     * Absolute <i>get</i> method for reading an int value.
     *
     * <p> Reads four bytes at the given index, composing them into a
     * int value according to the current byte order.  </p>
     *
     * @param  index
     *         The index from which the bytes will be read
     *
     * @return  The int value at the given index
     *
     * @throws  IndexOutOfBoundsException
     *          If <tt>index</tt> is negative
     *          or not smaller than the buffer's limit,
     *          minus three
     */
    T get(T)(int index) if( !is(T == byte))
    {
        enum len = T.sizeof;
        int i = ix(checkIndex(index, len));
        ubyte[len] bytes = cast(ubyte[])hb[i .. i+len];
        return bigEndianToNative!T(bytes);
    }
    
    /**
     * Relative <i>put</i> method for writing a short
     * value&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes two bytes containing the given short value, in the
     * current byte order, into this buffer at the current position, and then
     * increments the position by two.  </p>
     *
     * @param  value
     *         The short value to be written
     *
     * @return  This buffer
     *
     * @throws  BufferOverflowException
     *          If there are fewer than two bytes
     *          remaining in this buffer
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    ByteBuffer put(T)(T value) if( !is(T == byte))
    {
        enum len = T.sizeof;
        int index = ix(nextPutIndex(len));
        ubyte[len] bytes = nativeToBigEndian(value);
        hb[index .. index+len] = cast(byte[])bytes[0 .. $];
        // byte* ptr = cast(byte*)&value;
        // byte[] data = ptr[0..T.sizeof];
        // put(data, 0, cast(int)data.length);
        return this;
    }


    /**
     * Absolute <i>put</i> method for writing a short
     * value&nbsp;&nbsp;<i>(optional operation)</i>.
     *
     * <p> Writes two bytes containing the given short value, in the
     * current byte order, into this buffer at the given index.  </p>
     *
     * @param  index
     *         The index at which the bytes will be written
     *
     * @param  value
     *         The short value to be written
     *
     * @return  This buffer
     *
     * @throws  IndexOutOfBoundsException
     *          If <tt>index</tt> is negative
     *          or not smaller than the buffer's limit,
     *          minus one
     *
     * @throws  ReadOnlyBufferException
     *          If this buffer is read-only
     */
    ByteBuffer put(T)(int index, T value) if( !is(T == byte))
    {
        // byte* ptr = cast(byte*)&value;
        // byte[] data = ptr[0..T.sizeof];
        // // put(data, 0, data.length);
        // for(int i=0; i<cast(int)data.length; i++)
        //     put(index+i, data[i]);

        enum len = T.sizeof;
        int i = ix(checkIndex(index, len));
        ubyte[len] bytes = nativeToBigEndian(value);
        hb[i .. i+len] = cast(byte[])bytes[0 .. $];
        
        return this;
    }

    protected int ix(int i)
    {
        return i + offset;
    }

    // protected long byteOffset(long i) {
    //     return offset + i;
    // }

    string getString(size_t offset, size_t len)
    {
        return cast(string) hb[offset..offset+len];
    }

    string getString()
    {
        return cast(string) hb;
    }


    /**
     * Returns a string summarizing the state of this buffer.
     *
     * @return  A summary string
     */
    override string toString()
    {
        StringBuffer sb = new StringBuffer();
        // sb.append(getClass().getName());
        sb.append("[pos=");
        sb.append(position());
        sb.append(" lim=");
        sb.append(limit());
        sb.append(" cap=");
        sb.append(capacity());
        sb.append("]");
        return sb.toString();
    }

}


/**
*/
class HeapByteBuffer : ByteBuffer
{

    // For speed these fields are actually declared in X-Buffer;
    // these declarations are here as documentation
    /*

    protected final byte[] hb;
    protected final int offset;

    */

    this(int cap, int lim)
    { // package-private

        super(-1, 0, lim, cap, new byte[cap], 0);
        /*
        hb = new byte[cap];
        offset = 0;
        */

    }

    this(byte[] buf, int off, int len)
    { // package-private

        super(-1, off, off + len, cast(int)buf.length, buf, 0);
        /*
        hb = buf;
        offset = 0;
        */

    }

    protected this(byte[] buf, int mark, int pos, int lim, int cap, int off)
    {

        super(mark, pos, lim, cap, buf, off);
        /*
        hb = buf;
        offset = off;
        */

    }

    override ByteBuffer slice()
    {
        return new HeapByteBuffer(hb, -1, 0, this.remaining(),
                this.remaining(), this.position() + offset);
    }

    override ByteBuffer duplicate()
    {
        return new HeapByteBuffer(hb, this.markValue(), this.position(),
                this.limit(), this.capacity(), offset);
    }

    override ByteBuffer asReadOnlyBuffer()
    {
        return new HeapByteBuffer(hb, this.markValue(), this.position(),
                this.limit(), this.capacity(), offset);
    }


    override byte get()
    {
        return hb[ix(nextGetIndex())];
    }

    override byte get(int i)
    {
        return hb[ix(checkIndex(i))];
    }

    override ByteBuffer get(byte[] dst, int offset, int length)
    {
        checkBounds(offset, length, cast(int)dst.length);
        if (length > remaining())
            throw new BufferUnderflowException("");
        // System.arraycopy(hb, ix(position()), dst, offset, length);
        int sourcePos = ix(position());
        dst[offset .. offset+length] = hb[sourcePos .. sourcePos + length];
        position(position() + length);
        return this;
    }

    override bool isDirect()
    {
        return false;
    }

    override bool isReadOnly()
    {
        return false;
    }

    override ByteBuffer put(byte x)
    {

        hb[ix(nextPutIndex())] = x;
        return this;

    }

    override ByteBuffer put(int i, byte x)
    {
        hb[ix(checkIndex(i))] = x;
        return this;
    }

    override ByteBuffer put(byte[] src, int offset, int length)
    {

        checkBounds(offset, length, cast(int)src.length);
        if (length > remaining())
            throw new BufferOverflowException("");
        // System.arraycopy(src, offset, hb, ix(position()), length);
        int newPos = ix(position());
        hb[newPos .. newPos+length] = src[offset .. offset+length];

        position(position() + length);
        return this;

    }

    override ByteBuffer put(ByteBuffer src)
    {
        if (typeid(src) == typeid(HeapByteBuffer))
        {
            if (src is this)
                throw new IllegalArgumentException("");
            HeapByteBuffer sb = cast(HeapByteBuffer) src;
            int n = sb.remaining();
            if (n > remaining())
                throw new BufferOverflowException("");
            // System.arraycopy(sb.hb, sb.ix(sb.position()), hb, ix(position()), n);
            
            int sourcePos = sb.ix(sb.position());
            int targetPos = ix(position());
            hb[targetPos .. targetPos+n] = sb.hb[sourcePos .. sourcePos+n];

            sb.position(sb.position() + n);
            position(position() + n);
        }
        else if (src.isDirect())
        {
            int n = src.remaining();
            if (n > remaining())
                throw new BufferOverflowException("");
            src.get(hb, ix(position()), n);
            position(position() + n);
        }
        else
        {
            super.put(src);
        }
        return this;

    }

    // short

    private static short makeShort(byte b1, byte b0) {
        return cast(short)((b1 << 8) | (b0 & 0xff));
    }
    private static byte short1(short x) { return cast(byte)(x >> 8); }
    private static byte short0(short x) { return cast(byte)(x     ); }

    override short getShort() {
        int index = ix(nextGetIndex(2));
        // short r = 0;
        // short* ptr = &r;
        // ptr[0]=hb[index+1]; // bigEndian
        // ptr[1]=hb[index]; 
        if(bigEndian)
            return makeShort(hb[index], hb[index+1]);
        else
            return makeShort(hb[index+1], hb[index]);
    }

    override short getShort(int i) {
        int index = ix(checkIndex(i, 2));
        if(bigEndian)
            return makeShort(hb[index], hb[index+1]);
        else
            return makeShort(hb[index+1], hb[index]);
    }

    override ByteBuffer putShort(short x) {
        int index = ix(nextPutIndex(2));
        if(bigEndian)
        {
            hb[index] = short1(x);
            hb[index+1] = short0(x);
        }
        else
        {
            hb[index] = short0(x);
            hb[index+1] = short1(x);
        }

        return this;
    }

    override ByteBuffer putShort(int i, short x) {
        int index = ix(checkIndex(i, 2));
        if(bigEndian)
        {
            hb[index] = short1(x);
            hb[index+1] = short0(x);
        }
        else
        {
            hb[index] = short0(x);
            hb[index+1] = short1(x);
        }
        return this;
    }


    // int
    override int getInt() {
        auto index = ix(nextGetIndex(4));
        return _getInt(index);
    }

    override int getInt(int i) {
        auto index = ix(checkIndex(i, 4));
        return _getInt(index);
    }

    version(LittleEndian)
    private int _getInt(long index) {
        if(bigEndian)
            return makeInt(hb[index], hb[index+1], hb[index+2], hb[index+3]);
        else
            return makeInt(hb[index+3], hb[index+2],hb[index+1], hb[index]);
    }

    private static int makeInt(byte b3, byte b2, byte b1, byte b0) {
        return  ((b3       ) << 24) | ((b2 & 0xff) << 16) |
                ((b1 & 0xff) <<  8) | (b0 & 0xff      );
    }

    override ByteBuffer putInt(int x) {
        putIntUnaligned(hb, ix(nextPutIndex(4)), x, bigEndian);
        return this;
    }

    override ByteBuffer putInt(int i, int x) {
        putIntUnaligned(hb, ix(checkIndex(i, 4)), x, bigEndian);
        return this;
    }

    version(LittleEndian)
    private static void putIntUnaligned(byte[] hb, int offset, int x, bool bigEndian) {
        if(bigEndian)
        {
            hb[offset] = int3(x);
            hb[offset+1] = int2(x);
            hb[offset+2] = int1(x);
            hb[offset+3] = int0(x);
        }
        else
        {
            hb[offset] = int0(x);
            hb[offset+1] = int1(x);
            hb[offset+2] = int2(x);
            hb[offset+3] = int3(x);
        }
    }

    private static byte int3(int x) { return cast(byte)(x >> 24); }
    private static byte int2(int x) { return cast(byte)(x >> 16); }
    private static byte int1(int x) { return cast(byte)(x >>  8); }
    private static byte int0(int x) { return cast(byte)(x      ); }

    override ByteBuffer compact()
    {
        int sourceIndex = ix(position());
        int targetIndex = ix(0);
        int len = remaining();
        hb[targetIndex .. targetIndex+len] = hb[sourceIndex .. sourceIndex+len];

        position(remaining());
        limit(capacity());
        discardMark();
        return this;

    }
}



/**
 * A direct byte buffer whose content is a memory-mapped region of a file.
 *
 * <p> Mapped byte buffers are created via the {@link
 * java.nio.channels.FileChannel#map FileChannel.map} method.  This class
 * : the {@link ByteBuffer} class with operations that are specific to
 * memory-mapped file regions.
 *
 * <p> A mapped byte buffer and the file mapping that it represents remain
 * valid until the buffer itself is garbage-collected.
 *
 * <p> The content of a mapped byte buffer can change at any time, for example
 * if the content of the corresponding region of the mapped file is changed by
 * this program or another.  Whether or not such changes occur, and when they
 * occur, is operating-system dependent and therefore unspecified.
 *
 * <a name="inaccess"></a><p> All or part of a mapped byte buffer may become
 * inaccessible at any time, for example if the mapped file is truncated.  An
 * attempt to access an inaccessible region of a mapped byte buffer will not
 * change the buffer's content and will cause an unspecified exception to be
 * thrown either at the time of the access or at some later time.  It is
 * therefore strongly recommended that appropriate precautions be taken to
 * avoid the manipulation of a mapped file by this program, or by a
 * concurrently running program, except to read or write the file's content.
 *
 * <p> Mapped byte buffers otherwise behave no differently than ordinary direct
 * byte buffers. </p>
 *
 *
 * @author Mark Reinhold
 * @author JSR-51 Expert Group
 * @since 1.4
 */
// abstract class MappedByteBuffer : ByteBuffer
// {

//     // This is a little bit backwards: By rights MappedByteBuffer should be a
//     // subclass of DirectByteBuffer, but to keep the spec clear and simple, and
//     // for optimization purposes, it's easier to do it the other way around.
//     // This works because DirectByteBuffer is a package-private class.

//     // For mapped buffers, a FileDescriptor that may be used for mapping
//     // operations if valid; null if the buffer is not mapped.
//     private FileDescriptor fd;

//     // This should only be invoked by the DirectByteBuffer constructors
//     //
//     this(int mark, int pos, int lim, int cap, // package-private
//                      FileDescriptor fd)
//     {
//         super(mark, pos, lim, cap);
//         this.fd = fd;
//     }

//     this(int mark, int pos, int lim, int cap) { // package-private
//         super(mark, pos, lim, cap);
//         this.fd = null;
//     }

//     private void checkMapped() {
//         if (fd is null)
//             // Can only happen if a luser explicitly casts a direct byte buffer
//             throw new UnsupportedOperationException();
//     }

//     // Returns the distance (in bytes) of the buffer from the page aligned address
//     // of the mapping. Computed each time to avoid storing in every direct buffer.
//     private long mappingOffset() {
//         int ps = Bits.pageSize();
//         long offset = address % ps;
//         return (offset >= 0) ? offset : (ps + offset);
//     }

//     private long mappingAddress(long mappingOffset) {
//         return address - mappingOffset;
//     }

//     private long mappingLength(long mappingOffset) {
//         return (long)capacity() + mappingOffset;
//     }

//     /**
//      * Tells whether or not this buffer's content is resident in physical
//      * memory.
//      *
//      * <p> A return value of <tt>true</tt> implies that it is highly likely
//      * that all of the data in this buffer is resident in physical memory and
//      * may therefore be accessed without incurring any virtual-memory page
//      * faults or I/O operations.  A return value of <tt>false</tt> does not
//      * necessarily imply that the buffer's content is not resident in physical
//      * memory.
//      *
//      * <p> The returned value is a hint, rather than a guarantee, because the
//      * underlying operating system may have paged out some of the buffer's data
//      * by the time that an invocation of this method returns.  </p>
//      *
//      * @return  <tt>true</tt> if it is likely that this buffer's content
//      *          is resident in physical memory
//      */
//     final bool isLoaded() {
//         checkMapped();
//         if ((address == 0) || (capacity() == 0))
//             return true;
//         long offset = mappingOffset();
//         long length = mappingLength(offset);
//         return isLoaded0(mappingAddress(offset), length, Bits.pageCount(length));
//     }

//     // not used, but a potential target for a store, see load() for details.
//     private static byte unused;

//     /**
//      * Loads this buffer's content into physical memory.
//      *
//      * <p> This method makes a best effort to ensure that, when it returns,
//      * this buffer's content is resident in physical memory.  Invoking this
//      * method may cause some number of page faults and I/O operations to
//      * occur. </p>
//      *
//      * @return  This buffer
//      */
//     final MappedByteBuffer load() {
//         checkMapped();
//         if ((address == 0) || (capacity() == 0))
//             return this;
//         long offset = mappingOffset();
//         long length = mappingLength(offset);
//         load0(mappingAddress(offset), length);

//         // Read a byte from each page to bring it into memory. A checksum
//         // is computed as we go along to prevent the compiler from otherwise
//         // considering the loop as dead code.
//         Unsafe unsafe = Unsafe.getUnsafe();
//         int ps = Bits.pageSize();
//         int count = Bits.pageCount(length);
//         long a = mappingAddress(offset);
//         byte x = 0;
//         for (int i=0; i<count; i++) {
//             x ^= unsafe.getByte(a);
//             a += ps;
//         }
//         if (unused != 0)
//             unused = x;

//         return this;
//     }

//     /**
//      * Forces any changes made to this buffer's content to be written to the
//      * storage device containing the mapped file.
//      *
//      * <p> If the file mapped into this buffer resides on a local storage
//      * device then when this method returns it is guaranteed that all changes
//      * made to the buffer since it was created, or since this method was last
//      * invoked, will have been written to that device.
//      *
//      * <p> If the file does not reside on a local device then no such guarantee
//      * is made.
//      *
//      * <p> If this buffer was not mapped in read/write mode ({@link
//      * java.nio.channels.FileChannel.MapMode#READ_WRITE}) then invoking this
//      * method has no effect. </p>
//      *
//      * @return  This buffer
//      */
//     final MappedByteBuffer force() {
//         checkMapped();
//         if ((address != 0) && (capacity() != 0)) {
//             long offset = mappingOffset();
//             force0(fd, mappingAddress(offset), mappingLength(offset));
//         }
//         return this;
//     }

//     private bool isLoaded0(long address, long length, int pageCount);
//     private void load0(long address, long length);
//     private void force0(FileDescriptor fd, long address, long length);
// }


// interface DirectBuffer {

//     long address();

//     Object attachment();

//     // Cleaner cleaner();
// }

