ifneq ($(BUILD_TINY_ANDROID),true)

ROOT_DIR := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_PATH:= $(ROOT_DIR)

# ---------------------------------------------------------------------------------
# 				Common definitons
# ---------------------------------------------------------------------------------

libOmxVdec-def += -D__align=__alignx
libOmxVdec-def += -Dinline=__inline
libOmxVdec-def += -DIMAGE_APPS_PROC
libOmxVdec-def += -D_ANDROID_
libOmxVdec-def += -DCDECL
libOmxVdec-def += -DT_ARM
libOmxVdec-def += -DNO_ARM_CLZ
libOmxVdec-def += -UENABLE_DEBUG_LOW
libOmxVdec-def += -UENABLE_DEBUG_HIGH
libOmxVdec-def += -DENABLE_DEBUG_ERROR
libOmxVdec-def += -UINPUT_BUFFER_LOG
libOmxVdec-def += -UOUTPUT_BUFFER_LOG
ifeq ($(TARGET_BOARD_PLATFORM),msm8660)
libOmxVdec-def += -DMAX_RES_1080P
libOmxVdec-def += -DPROCESS_EXTRADATA_IN_OUTPUT_PORT
libOmxVdec-def += -DTEST_TS_FROM_SEI
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm8960)
libOmxVdec-def += -DMAX_RES_1080P
libOmxVdec-def += -DMAX_RES_1080P_EBI
libOmxVdec-def += -DPROCESS_EXTRADATA_IN_OUTPUT_PORT
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm8974)
libOmxVdec-def += -DMAX_RES_1080P
libOmxVdec-def += -DMAX_RES_1080P_EBI
libOmxVdec-def += -DPROCESS_EXTRADATA_IN_OUTPUT_PORT
libOmxVdec-def += -D_COPPER_
endif

libOmxVdec-def += -D_ANDROID_ICS_

#ifeq ($(TARGET_USES_ION),true)
libOmxVdec-def += -DUSE_ION
#endif

ifeq ($(TARGET_NO_ADAPTIVE_PLAYBACK),true)
libOmxVdec-def += -DNO_ADAPTIVE_PLAYBACK
endif

ifeq ($(TARGET_USES_MEDIA_EXTENSIONS),true)
libOmxVdec-def += -DALLOCATE_OUTPUT_NATIVEHANDLE
endif

# ---------------------------------------------------------------------------------
# 			Make the Shared library (libOmxVdec)
# ---------------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_PATH:= $(ROOT_DIR)

libmm-vdec-inc          := $(LOCAL_PATH)/inc
libmm-vdec-inc          += $(OMX_VIDEO_PATH)/vidc/common/inc
libmm-vdec-inc          += hardware/qcom/media/mm-core/inc
libmm-vdec-inc          += hardware/qcom/display/libgralloc
libmm-vdec-inc          += hardware/qcom/media/libc2dcolorconvert
libmm-vdec-inc          += hardware/qcom/display/libcopybit
libmm-vdec-inc          += frameworks/av/include/media/stagefright
libmm-vdec-inc          += hardware/qcom/display/libqservice
libmm-vdec-inc          += frameworks/av/media/libmediaplayerservice
libmm-vdec-inc          += frameworks/native/include/binder
libmm-vdec-inc          += hardware/qcom/display/libqdutils

LOCAL_HEADER_LIBRARIES := \
        generated_kernel_headers \
        media_plugin_headers \
        libnativebase_headers \
        libutils_headers \
        libhardware_headers

LOCAL_MODULE                    := libOmxVdec
LOCAL_MODULE_TAGS               := optional
LOCAL_VENDOR_MODULE             := true
LOCAL_CFLAGS                    := $(libOmxVdec-def)
LOCAL_C_INCLUDES                += $(libmm-vdec-inc)

LOCAL_SHARED_LIBRARIES  := liblog libutils libui libbinder libcutils libdl

LOCAL_SHARED_LIBRARIES  += libqservice
LOCAL_SHARED_LIBRARIES  += libqdMetaData

LOCAL_SRC_FILES         := src/frameparser.cpp
LOCAL_SRC_FILES         += src/h264_utils.cpp
LOCAL_SRC_FILES         += src/ts_parser.cpp
LOCAL_SRC_FILES         += src/mp4_utils.cpp
LOCAL_SRC_FILES         += src/omx_vdec.cpp
LOCAL_SRC_FILES         += ../common/src/extra_data_handler.cpp
LOCAL_SRC_FILES         += ../common/src/vidc_color_converter.cpp

# omx_vdec.cpp: address of array 'extra->data' will always evaluate to 'true'
LOCAL_CLANG_CFLAGS      += -Wno-pointer-bool-conversion
LOCAL_CFLAGS            += -Wno-error -Wno-unused-parameter -Wno-format

include $(BUILD_SHARED_LIBRARY)

# ---------------------------------------------------------------------------------
# 			Make the apps-test (mm-vdec-omx-test)
# ---------------------------------------------------------------------------------
include $(CLEAR_VARS)

mm-vdec-test-inc    := hardware/qcom/media/mm-core/inc
mm-vdec-test-inc    += $(LOCAL_PATH)/inc

LOCAL_HEADER_LIBRARIES := generated_kernel_headers

LOCAL_MODULE                    := mm-vdec-omx-test
LOCAL_MODULE_TAGS               := optional
LOCAL_CFLAGS                    := $(libOmxVdec-def)
LOCAL_C_INCLUDES                := $(mm-vdec-test-inc)

LOCAL_SHARED_LIBRARIES    := libutils libui libOmxCore libOmxVdec libbinder libcutils

LOCAL_SRC_FILES           := src/queue.c
LOCAL_SRC_FILES           += test/omx_vdec_test.cpp

include $(BUILD_EXECUTABLE)

# ---------------------------------------------------------------------------------
# 			Make the driver-test (mm-video-driver-test)
# ---------------------------------------------------------------------------------
include $(CLEAR_VARS)

mm-vdec-drv-test-inc    := hardware/qcom/media/mm-core/inc
mm-vdec-drv-test-inc    += $(LOCAL_PATH)/inc

LOCAL_HEADER_LIBRARIES := generated_kernel_headers

LOCAL_MODULE                    := mm-video-driver-test
LOCAL_MODULE_TAGS               := optional
LOCAL_CFLAGS                    := $(libOmxVdec-def)
LOCAL_C_INCLUDES                := $(mm-vdec-drv-test-inc)

LOCAL_SRC_FILES                 := src/message_queue.c
LOCAL_SRC_FILES                 += test/decoder_driver_test.c

include $(BUILD_EXECUTABLE)

endif #BUILD_TINY_ANDROID

# ---------------------------------------------------------------------------------
#                END
# ---------------------------------------------------------------------------------
