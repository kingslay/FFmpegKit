////
////  renderer.c
////
////
////  Created by kintan on 5/5/24.
////
//
//#include <stdio.h>
//#include <libplacebo/vulkan.h>
//#include <vulkan/vulkan_beta.h>
//
//// Should keep sync with optional_device_exts inside hwcontext_vulkan.c
//static const char *optional_device_exts[] = {
//    /* Misc or required by other extensions */
//    VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME,
//    VK_KHR_PUSH_DESCRIPTOR_EXTENSION_NAME,
//    VK_KHR_SAMPLER_YCBCR_CONVERSION_EXTENSION_NAME,
//    VK_EXT_DESCRIPTOR_BUFFER_EXTENSION_NAME,
//    VK_EXT_PHYSICAL_DEVICE_DRM_EXTENSION_NAME,
//    VK_EXT_SHADER_ATOMIC_FLOAT_EXTENSION_NAME,
//    VK_KHR_COOPERATIVE_MATRIX_EXTENSION_NAME,
//
//    /* Imports/exports */
//    VK_KHR_EXTERNAL_MEMORY_FD_EXTENSION_NAME,
//    VK_EXT_EXTERNAL_MEMORY_DMA_BUF_EXTENSION_NAME,
//    VK_EXT_IMAGE_DRM_FORMAT_MODIFIER_EXTENSION_NAME,
//    VK_KHR_EXTERNAL_SEMAPHORE_FD_EXTENSION_NAME,
//    VK_EXT_EXTERNAL_MEMORY_HOST_EXTENSION_NAME,
//#ifdef _WIN32
//    VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME,
//    VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME,
//#endif
//
//    /* Video encoding/decoding */
//    VK_KHR_VIDEO_QUEUE_EXTENSION_NAME,
//    VK_KHR_VIDEO_DECODE_QUEUE_EXTENSION_NAME,
//    VK_KHR_VIDEO_DECODE_H264_EXTENSION_NAME,
//    VK_KHR_VIDEO_DECODE_H265_EXTENSION_NAME,
//    "VK_MESA_video_decode_av1",
//};
//
//typedef struct VkRenderer VkRenderer;
//
//struct VkRenderer {
//    const AVClass *class;
//
//    int (*get_hw_dev)(VkRenderer *renderer, AVBufferRef **dev);
//
//    int (*display)(VkRenderer *renderer, AVFrame *frame);
//
//    int (*resize)(VkRenderer *renderer, int width, int height);
//
//    void (*destroy)(VkRenderer *renderer);
//};
//
//static VkRenderer *vk_renderer;
//
//typedef struct RendererContext {
//    VkRenderer api;
//
//    // Can be NULL when vulkan instance is created by avutil
//    pl_vk_inst placebo_instance;
//    pl_vulkan placebo_vulkan;
//    pl_swapchain swapchain;
//    VkSurfaceKHR vk_surface;
//    pl_renderer renderer;
//    pl_tex tex[4];
//
//    pl_log vk_log;
//
//    AVBufferRef *hw_device_ref;
//    AVBufferRef *hw_frame_ref;
//    enum AVPixelFormat *transfer_formats;
//    AVHWFramesConstraints *constraints;
//
//    PFN_vkGetInstanceProcAddr get_proc_addr;
//    // This field is a copy from pl_vk_inst->instance or hw_device_ref instance.
//    VkInstance inst;
//
//    AVFrame *vk_frame;
//} RendererContext;
//
//
//static void placebo_lock_queue(struct AVHWDeviceContext *dev_ctx,
//                               uint32_t queue_family, uint32_t index)
//{
//    RendererContext *ctx = dev_ctx->user_opaque;
//    pl_vulkan vk = ctx->placebo_vulkan;
//    vk->lock_queue(vk, queue_family, index);
//}
//
//static void placebo_unlock_queue(struct AVHWDeviceContext *dev_ctx,
//                                 uint32_t queue_family,
//                                 uint32_t index)
//{
//    RendererContext *ctx = dev_ctx->user_opaque;
//    pl_vulkan vk = ctx->placebo_vulkan;
//    vk->unlock_queue(vk, queue_family, index);
//}
//
//static int get_decode_queue(VkRenderer *renderer, int *index, int *count)
//{
//    RendererContext *ctx = (RendererContext *) renderer;
//    VkQueueFamilyProperties *queue_family_prop = NULL;
//    uint32_t num_queue_family_prop = 0;
//    PFN_vkGetPhysicalDeviceQueueFamilyProperties get_queue_family_prop;
//    PFN_vkGetInstanceProcAddr get_proc_addr = ctx->get_proc_addr;
//
//    *index = -1;
//    *count = 0;
//    get_queue_family_prop = (PFN_vkGetPhysicalDeviceQueueFamilyProperties)
//    get_proc_addr(ctx->placebo_instance->instance,
//                  "vkGetPhysicalDeviceQueueFamilyProperties");
//    get_queue_family_prop(ctx->placebo_vulkan->phys_device,
//                          &num_queue_family_prop, NULL);
//    if (!num_queue_family_prop)
//        return AVERROR_EXTERNAL;
//
//    queue_family_prop = av_calloc(num_queue_family_prop,
//                                  sizeof(*queue_family_prop));
//    if (!queue_family_prop)
//        return AVERROR(ENOMEM);
//
//    get_queue_family_prop(ctx->placebo_vulkan->phys_device,
//                          &num_queue_family_prop,
//                          queue_family_prop);
//
//    for (int i = 0; i < num_queue_family_prop; i++) {
//        if (queue_family_prop[i].queueFlags & VK_QUEUE_VIDEO_DECODE_BIT_KHR) {
//            *index = i;
//            *count = queue_family_prop[i].queueCount;
//            break;
//        }
//    }
//    av_free(queue_family_prop);
//
//    return 0;
//}
//
//static int create_vk_by_placebo(VkRenderer *renderer,
//                                const char **ext, unsigned num_ext,
//                                const AVDictionary *opt)
//{
//    RendererContext *ctx = (RendererContext *) renderer;
//    AVHWDeviceContext *device_ctx;
//    AVVulkanDeviceContext *vk_dev_ctx;
//    int decode_index;
//    int decode_count;
//    int ret;
//
////    ctx->get_proc_addr = SDL_Vulkan_GetVkGetInstanceProcAddr();
//
//    ctx->placebo_instance = pl_vk_inst_create(ctx->vk_log, pl_vk_inst_params(
//                                                                             .get_proc_addr = ctx->get_proc_addr,
//                                                                             .extensions = ext,
//                                                                             .num_extensions = num_ext
//                                                                             ));
//    if (!ctx->placebo_instance) {
//        return AVERROR_EXTERNAL;
//    }
//    ctx->inst = ctx->placebo_instance->instance;
//
//    ctx->placebo_vulkan = pl_vulkan_create(ctx->vk_log, pl_vulkan_params(
//                                                                         .instance = ctx->placebo_instance->instance,
//                                                                         .get_proc_addr = ctx->placebo_instance->get_proc_addr,
//                                                                         .surface = ctx->vk_surface,
//                                                                         .allow_software = false,
//                                                                         .opt_extensions = optional_device_exts,
//                                                                         .num_opt_extensions = FF_ARRAY_ELEMS(optional_device_exts),
//                                                                         .extra_queues = VK_QUEUE_VIDEO_DECODE_BIT_KHR,
//                                                                         .device_name = NULL,
//                                                                         ));
//    if (!ctx->placebo_vulkan)
//        return AVERROR_EXTERNAL;
//    ctx->hw_device_ref = av_hwdevice_ctx_alloc(AV_HWDEVICE_TYPE_VULKAN);
//    if (!ctx->hw_device_ref) {
//        return AVERROR(ENOMEM);
//    }
//
//    device_ctx = (AVHWDeviceContext *) ctx->hw_device_ref->data;
//    device_ctx->user_opaque = ctx;
//
//    vk_dev_ctx = device_ctx->hwctx;
////    vk_dev_ctx->lock_queue = placebo_lock_queue;
////    vk_dev_ctx->unlock_queue = placebo_unlock_queue;
//
//    vk_dev_ctx->get_proc_addr = ctx->placebo_instance->get_proc_addr;
//
//    vk_dev_ctx->inst = ctx->placebo_instance->instance;
//    vk_dev_ctx->phys_dev = ctx->placebo_vulkan->phys_device;
//    vk_dev_ctx->act_dev = ctx->placebo_vulkan->device;
//
//    vk_dev_ctx->device_features = *ctx->placebo_vulkan->features;
//
//    vk_dev_ctx->enabled_inst_extensions = ctx->placebo_instance->extensions;
//    vk_dev_ctx->nb_enabled_inst_extensions = ctx->placebo_instance->num_extensions;
//
//    vk_dev_ctx->enabled_dev_extensions = ctx->placebo_vulkan->extensions;
//    vk_dev_ctx->nb_enabled_dev_extensions = ctx->placebo_vulkan->num_extensions;
//
//    vk_dev_ctx->queue_family_index = ctx->placebo_vulkan->queue_graphics.index;
//    vk_dev_ctx->nb_graphics_queues = ctx->placebo_vulkan->queue_graphics.count;
//
//    vk_dev_ctx->queue_family_tx_index = ctx->placebo_vulkan->queue_transfer.index;
//    vk_dev_ctx->nb_tx_queues = ctx->placebo_vulkan->queue_transfer.count;
//
//    vk_dev_ctx->queue_family_comp_index = ctx->placebo_vulkan->queue_compute.index;
//    vk_dev_ctx->nb_comp_queues = ctx->placebo_vulkan->queue_compute.count;
//
//    ret = get_decode_queue(renderer, &decode_index, &decode_count);
//    if (ret < 0)
//        return ret;
//
//    vk_dev_ctx->queue_family_decode_index = decode_index;
//    vk_dev_ctx->nb_decode_queues = decode_count;
//
//    ret = av_hwdevice_ctx_init(ctx->hw_device_ref);
//    if (ret < 0)
//        return ret;
//
//    return 0;
//}
