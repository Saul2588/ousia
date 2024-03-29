$(BUILD_PATH)/$(OUSIA_TARGET): $(BUILD_PATH)/$(OUSIA_TARGET).bin

$(BUILD_PATH)/$(OUSIA_TARGET).bin: $(BUILD_PATH)/$(OUSIA_TARGET).elf
	$(SILENT_OBJCOPY) $(OBJCOPY) -v -Obinary $(BUILD_PATH)/$(OUSIA_TARGET).elf $@ 1>/dev/null
	$(SILENT_DISAS) $(DISAS) -d $(BUILD_PATH)/$(OUSIA_TARGET).elf > $(BUILD_PATH)/$(OUSIA_TARGET).disas
	@echo " "
	@echo "Object file sizes:"
	@find $(BUILD_PATH) -iname *.o | xargs $(SIZE) -t > $(BUILD_PATH)/$(OUSIA_TARGET).sizes
	@cat $(BUILD_PATH)/$(OUSIA_TARGET).sizes
	@echo " "
	@echo "Final Size:"
	@$(SIZE) $<
	@echo $(MEMORY_TARGET) > $(BUILD_PATH)/build-type

$(BUILD_PATH)/$(OUSIA_TARGET).elf: $(BUILDDIRS) $(TGT_BIN) $(USR_BUILDDIRS) $(USR_TGT_BIN)
	$(SILENT_LD) $(CC) $(LDFLAGS) -o $@ $(TGT_BIN) $(USR_TGT_BIN) -Wl,-Map,$(BUILD_PATH)/$(OUSIA_TARGET).map

