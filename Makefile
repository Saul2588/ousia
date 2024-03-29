# Ousia Makefile
# Contact - g.leafgrass@gmail.com

VERSION = 0
SUBLEVEL = 0
DEVNUM = 3
NAME = Sweet Hibiscus

# TODO @OUSIA_TARGET the name of target binary file
#      @TARGET_PLATFORM specific directory name in folder $(PLATFORM_PATH)
#      @PROJECT_NAME specific directory name in folder $(PROJECT_PATH)
OUSIA_TARGET = ousia
TARGET_PLATFORM = stm32
PROJECT_NAME = sample_$(TARGET_PLATFORM)

# Useful paths
ifeq ($(OUSIA_HOME),)
	SRCROOT := .
else
	SRCROOT := $(OUSIA_HOME)
endif
BUILD_PATH = build
INCLUDE_PATH := $(SRCROOT)/include
PLATFORM_PATH := $(SRCROOT)/platform
CORE_PATH := $(SRCROOT)/core
DRIVER_PATH := $(SRCROOT)/driver
FRAMEWORK_PATH := $(SRCROOT)/framework
SUPPORT_PATH := $(SRCROOT)/support
SCRIPT_PATH := $(SRCROOT)/script
PROJECT_PATH := $(SRCROOT)/project

# FIXME This solution results to a problem.
#       In target platform directory, we must use too many .mk files.
#       i.e. Three files for now: rules.mk, config.mk and target.mk.
include $(PLATFORM_PATH)/$(TARGET_PLATFORM)/config.mk

.DEFAULT_GOAL := sketch

# Set up build rules and some useful templates
include $(SUPPORT_PATH)/make/build-rules.mk
include $(SUPPORT_PATH)/make/build-templates.mk

# Ousia source modules
MODULES	:= $(CORE_PATH)
MODULES += $(PLATFORM_PATH)
MODULES += $(FRAMEWORK_PATH)
# User application code
MODULES += $(PROJECT_PATH)/$(PROJECT_NAME)

# call each module rules.mk
$(foreach m,$(MODULES),$(eval $(call MODULE_template,$(m))))

# Main target
include $(SUPPORT_PATH)/make/build-targets.mk

.PHONY: install sketch lib clean help debug cscope tags ctags ram flash jtag update_port

# Download code to target device
install: sketch
	$(SHELL) ./script/download.sh

# Force a rebuild if the maple target changed
PREV_BUILD_TYPE = $(shell cat $(BUILD_PATH)/build-type 2>/dev/null)
build-check:
ifneq ($(PREV_BUILD_TYPE), $(MEMORY_TARGET))
	$(shell rm -rf $(BUILD_PATH))
endif

sketch: MSG_INFO build-check update $(BUILD_PATH)/$(OUSIA_TARGET)

lib: $(BUILD_PATH)/lib$(OUSIA_TARGET).a
	@find $(BUILD_PATH) -iname *.o | xargs $(SIZE) -t > $(BUILD_PATH)/$(OUSIA_TARGET).sizes
#	@cat $(BUILD_PATH)/$(OUSIA_TARGET).sizes

$(BUILD_PATH)/lib$(OUSIA_TARGET).a: MSG_INFO update $(BUILDDIRS) $(TGT_BIN)
	$(shell rm -f $@)
	$(SILENT_AR) $(AR) cr $(BUILD_PATH)/lib$(OUSIA_TARGET).a $(TGT_BIN)

# FIXME Better not run these line each time
update:
	$(shell rm -rf $(CORE_PATH)/port)
	$(shell cp -rf $(PLATFORM_PATH)/$(TARGET_PLATFORM)/port $(CORE_PATH)/port)

clean:
	rm -rf build

distclean:
	rm -rf build
	rm -rf tarball
	rm -f tags tags.ut tags.fn cscope.out

package:
	mkdir -p tarball
	$(SHELL) ./script/package.sh

help:
	@echo ""
	@echo "==========================================================="
	@echo "[Ousia Make Help]"
	@echo ""
	@echo "Build targets (default MEMORY_TARGET=flash):"
	@echo "  ram:       Compile sketch code to ram"
	@echo "  flash:     Compile sketch code to flash"
	@echo "  jtag:      Compile sketch code to jtag"
	@echo "  sketch:    Compile sketch code to target MEMORY_TARGET"
	@echo ""
	@echo "Downloading targets:"
	@echo "  install:   Download binary image to target device"
	@echo ""
	@echo "Debug targets:"
	@echo "  debug:     Start an openocd server"
	@echo ""
	@echo "Other targets:"
	@echo "  clean:     Remove all build files"
	@echo "  distclean: Remove all builds tarballs, and ohter misc"
	@echo "  help:      Show this message"
	@echo "  package:   Package current revision"
	@echo "==========================================================="
	@echo ""

MSG_INFO:
	@echo ""
	@echo "========================================"
	@echo "[Build Information]"
	@echo ""
	@echo "TARGET: "$(OUSIA_TARGET)
	@echo "VERSION: "$(VERSION)"."$(SUBLEVEL)"."$(DEVNUM)
	@echo "NAME: "$(NAME)
	@echo "PLATFORM: "$(TARGET_PLATFORM)
	@echo "PROJECT: "$(PROJECT_NAME)
	@echo ""
	@echo "  See 'make help' for more information"
	@echo "========================================"
	@echo ""

OPENOCD_WRAPPER := openocd -f ./support/openocd/stm32.cfg
debug:
	$(OPENOCD_WRAPPER)

ram:
	@$(MAKE) MEMORY_TARGET=ram --no-print-directory sketch

flash:
	@$(MAKE) MEMORY_TARGET=flash --no-print-directory sketch

jtag:
	@$(MAKE) MEMORY_TARGET=jtag --no-print-directory sketch

