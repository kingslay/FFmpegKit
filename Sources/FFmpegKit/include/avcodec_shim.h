#ifndef AVCODEC_SHIM_H
#define AVCODEC_SHIM_H

#import <Libavcodec/avcodec.h>

//#import <Libavcodec/htmlsubtitles.h>
int ff_htmlmarkup_to_ass(void *log_ctx, AVBPrint *dst, const char *in);

//#import <Libavcodec/atsc_a53.h>
int ff_parse_a53_cc(AVBufferRef **pbuf, const uint8_t *data, int size);

//#import <Libavcodec/vt_internal.h>
//CFDataRef videotoolbox_esds_extradata_create(AVCodecContext *avctx);
//CFDataRef ff_videotoolbox_avcc_extradata_create(AVCodecContext *avctx);
//CFDataRef ff_videotoolbox_hvcc_extradata_create(AVCodecContext *avctx);
//CFDataRef ff_videotoolbox_vpcc_extradata_create(AVCodecContext *avctx);
//CFDataRef ff_videotoolbox_av1c_extradata_create(AVCodecContext *avctx);

#endif /* AVCODEC_SHIM_H */
