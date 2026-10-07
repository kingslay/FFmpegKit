#ifndef AVFORMAT_SHIM_H
#define AVFORMAT_SHIM_H

#import <Libavformat/avformat.h>
#import <Libavformat/avio.h>

//#import <Libavformat/vpcc.h>

/**
 * Writes VP codec configuration to the provided AVIOContext.
 *
 * @param s address of the AVFormatContext for the logging context.
 * @param pb address of the AVIOContext where the vpcC shall be written.
 * @param data address of a data array which contains coded bitstream data from
 *             which codec information can be extracted. May be NULL.
 * @param len length of the data array.
 * @param par address of the AVCodecParameters which contains codec information.
 * @return >=0 in case of success, a negative value corresponding to an AVERROR
 *         code in case of failure
 */
int ff_isom_write_vpcc(AVFormatContext *s, AVIOContext *pb,
                       const uint8_t *data, int len,
                       AVCodecParameters *par);
int ff_isom_write_avcc(AVIOContext *pb, const uint8_t *data, int len);
int ff_isom_write_hvcc(AVIOContext *pb, const uint8_t *data,
                       int size, int ps_array_completeness, void *logctx);
int ff_isom_write_av1c(AVIOContext *pb, const uint8_t *buf, int size, int write_seq_header);
//#import <Libavformat/url.h>

typedef struct URLContext {
    const AVClass *av_class;    /**< information for av_log(). Set by url_open(). */
    const struct URLProtocol *prot;
    void *priv_data;
    char *filename;             /**< specified URL */
    int flags;
    int max_packet_size;        /**< if non zero, the stream is packetized with this max packet size */
    int is_streamed;            /**< true if streamed (no seek possible), default = false */
    int is_connected;
    AVIOInterruptCB interrupt_callback;
    int64_t rw_timeout;         /**< maximum time to wait for (network) read/write operation completion, in mcs */
    const char *protocol_whitelist;
    const char *protocol_blacklist;
    int min_packet_size;        /**< if non zero, the stream is packetized with this min packet size */
} URLContext;

/**
 * Create a URLContext for accessing to the resource indicated by
 * url, but do not initiate the connection yet.
 *
 * @param puc pointer to the location where, in case of success, the
 * function puts the pointer to the created URLContext
 * @param flags flags which control how the resource indicated by url
 * is to be opened
 * @param int_cb interrupt callback to use for the URLContext, may be
 * NULL
 * @return >= 0 in case of success, a negative value corresponding to an
 * AVERROR code in case of failure
 */
int ffurl_alloc(URLContext **puc, const char *filename, int flags,
                const AVIOInterruptCB *int_cb);

/**
 * Connect an URLContext that has been allocated by ffurl_alloc
 *
 * @param options  A dictionary filled with options for nested protocols,
 * i.e. it will be passed to url_open2() for protocols implementing it.
 * This parameter will be destroyed and replaced with a dict containing options
 * that were not found. May be NULL.
 */
int ffurl_connect(URLContext *uc, AVDictionary **options);

/**
 * Create an URLContext for accessing to the resource indicated by
 * url, and open it.
 *
 * @param puc pointer to the location where, in case of success, the
 * function puts the pointer to the created URLContext
 * @param flags flags which control how the resource indicated by url
 * is to be opened
 * @param int_cb interrupt callback to use for the URLContext, may be
 * NULL
 * @param options  A dictionary filled with protocol-private options. On return
 * this parameter will be destroyed and replaced with a dict containing options
 * that were not found. May be NULL.
 * @param parent An enclosing URLContext, whose generic options should
 *               be applied to this URLContext as well.
 * @return >= 0 in case of success, a negative value corresponding to an
 * AVERROR code in case of failure
 */
int ffurl_open_whitelist(URLContext **puc, const char *filename, int flags,
                         const AVIOInterruptCB *int_cb, AVDictionary **options,
                         const char *whitelist, const char* blacklist,
                         URLContext *parent);
/**
 * Read up to size bytes from the resource accessed by h, and store
 * the read bytes in buf.
 *
 * @return The number of bytes actually read, or a negative value
 * corresponding to an AVERROR code in case of error. A value of zero
 * indicates that it is not possible to read more from the accessed
 * resource (except if the value of the size argument is also zero).
 */
int ffurl_read2(void *urlcontext, uint8_t *buf, int size);

/**
 * Read as many bytes as possible (up to size), calling the
 * read function multiple times if necessary.
 * This makes special short-read handling in applications
 * unnecessary, if the return value is < size then it is
 * certain there was either an error or the end of file was reached.
 */
int ffurl_read_complete(URLContext *h, unsigned char *buf, int size);

/**
 * Read as many bytes as possible (up to size), calling the
 * read function multiple times if necessary.
 * This makes special short-read handling in applications
 * unnecessary, if the return value is < size then it is
 * certain there was either an error or the end of file was reached.
 */
int ffurl_write2(void *urlcontext, uint8_t *buf, int size);

/**
 * Change the position that will be used by the next read/write
 * operation on the resource accessed by h.
 *
 * @param pos specifies the new position to set
 * @param whence specifies how pos should be interpreted, it must be
 * one of SEEK_SET (seek from the beginning), SEEK_CUR (seek from the
 * current position), SEEK_END (seek from the end), or AVSEEK_SIZE
 * (return the filesize of the requested resource, pos is ignored).
 * @return a negative value corresponding to an AVERROR code in case
 * of failure, or the resulting file position, measured in bytes from
 * the beginning of the file. You can use this feature together with
 * SEEK_CUR to read the current file position.
 */
int64_t ffurl_seek2(void *urlcontext, int64_t pos, int whence);

/**
 * Close the resource accessed by the URLContext h, and free the
 * memory used by it. Also set the URLContext pointer to NULL.
 *
 * @return a negative value if an error condition occurred, 0
 * otherwise
 */
int ffurl_closep(URLContext **h);
int ffurl_close(URLContext *h);

#endif /* AVFORMAT_SHIM_H */
