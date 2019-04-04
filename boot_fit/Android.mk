ifneq ($(filter beagle_x15%, $(TARGET_DEVICE)),)
ifeq ($(TARGET_BOOTIMAGE_FIT), true)

MKIMAGE := $(HOST_OUT_EXECUTABLES)/mkimage
DTC := $(HOST_OUT_EXECUTABLES)/dtc
BOARD_DIR := device/ti/beagle_x15
ITS := beagle_x15.its
BOOTIMG_FIT := $(PRODUCT_OUT)/boot_fit.img
BOOTIMG_FIT_INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel
BOOTIMG_FIT_INSTALLED_RAMDISK_TARGET := $(PRODUCT_OUT)/ramdisk.img

$(BOOTIMG_FIT): PRIVATE_DTC_FLAGS_MKIMAGE = -I dts -O dtb -p 500 -Wno-unit_address_vs_reg
$(BOOTIMG_FIT): PRIVATE_INTERMEDIATES := $(call intermediates-dir-for,PACKAGING,fit)
$(BOOTIMG_FIT): PRIVATE_ITS := $(ITS)
$(BOOTIMG_FIT): PRIVATE_MKIMAGE := $(MKIMAGE)
$(BOOTIMG_FIT): PRIVATE_BOARD_DIR := $(BOARD_DIR)
$(BOOTIMG_FIT): PRIVATE_INSTALLED_KERNEL_TARGET := $(BOOTIMG_FIT_INSTALLED_KERNEL_TARGET)
$(BOOTIMG_FIT): PRIVATE_INSTALLED_RAMDISK_TARGET := $(BOOTIMG_FIT_INSTALLED_RAMDISK_TARGET)
$(BOOTIMG_FIT): $(BOOTIMG_FIT_INSTALLED_KERNEL_TARGET) $(BOOTIMG_FIT_INSTALLED_RAMDISK_TARGET)
$(BOOTIMG_FIT): $(BOARD_DIR)/$(ITS) $(MKIMAGE) $(DTC) $(wildcard $(LOCAL_KERNEL)/$(TARGET_KERNEL_USE)/*.dtb*)
	mkdir -p $(PRIVATE_INTERMEDIATES)
	cp $(PRIVATE_BOARD_DIR)/$(PRIVATE_ITS) $(PRIVATE_INTERMEDIATES)/
	cp $(PRIVATE_INSTALLED_RAMDISK_TARGET) $(PRIVATE_INTERMEDIATES)/
	cp $(PRIVATE_INSTALLED_KERNEL_TARGET) $(PRIVATE_INTERMEDIATES)/zImage
	cp $(LOCAL_KERNEL)/$(TARGET_KERNEL_USE)/*.dtb* $(PRIVATE_INTERMEDIATES)/
	PATH=$(HOST_OUT_EXECUTABLES):$$PATH $(PRIVATE_MKIMAGE) -D "$(PRIVATE_DTC_FLAGS_MKIMAGE)" -f $(PRIVATE_INTERMEDIATES)/$(PRIVATE_ITS) $@

include $(CLEAR_VARS)
LOCAL_MODULE := bootfitimage
LOCAL_ADDITIONAL_DEPENDENCIES := $(BOOTIMG_FIT)
include $(BUILD_PHONY_PACKAGE)

endif
endif
