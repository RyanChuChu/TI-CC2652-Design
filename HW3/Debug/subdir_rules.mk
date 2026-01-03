################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
LCD.o: ../LCD.s $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/Applications/ti/ccs2030/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/Users/ryan/workspace_ccstheia/HW3" -I"/Users/ryan/workspace_ccstheia/HW3/Debug" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m --language=ti-asm -I"/Users/ryan/workspace_ccstheia/HW3/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

build-985836369: ../empty.syscfg
	@echo 'Building file: "$<"'
	@echo 'Invoking: SysConfig'
	"/Users/ryan/ti/sysconfig_1.21.1/sysconfig_cli.sh" --script "/Users/ryan/workspace_ccstheia/HW3/empty.syscfg" -o "syscfg" -s "/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/.metadata/product.json" --compiler ticlang
	@echo 'Finished building: "$<"'
	@echo ' '

syscfg/ti_devices_config.c: build-985836369 ../empty.syscfg
syscfg/ti_drivers_config.c: build-985836369
syscfg/ti_drivers_config.h: build-985836369
syscfg/ti_utils_build_linker.cmd.genlibs: build-985836369
syscfg/ti_utils_build_linker.cmd.genmap: build-985836369
syscfg/ti_utils_build_compiler.opt: build-985836369
syscfg/syscfg_c.rov.xs: build-985836369
syscfg: build-985836369

syscfg/%.o: ./syscfg/%.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/Applications/ti/ccs2030/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/Users/ryan/workspace_ccstheia/HW3" -I"/Users/ryan/workspace_ccstheia/HW3/Debug" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m -MMD -MP -MF"syscfg/$(basename $(<F)).d_raw" -MT"$(@)" -I"/Users/ryan/workspace_ccstheia/HW3/Debug/syscfg"  $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

init.o: ../init.s $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/Applications/ti/ccs2030/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/Users/ryan/workspace_ccstheia/HW3" -I"/Users/ryan/workspace_ccstheia/HW3/Debug" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m --language=ti-asm -I"/Users/ryan/workspace_ccstheia/HW3/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

main.o: ../main.s $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/Applications/ti/ccs2030/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/Users/ryan/workspace_ccstheia/HW3" -I"/Users/ryan/workspace_ccstheia/HW3/Debug" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m --language=ti-asm -I"/Users/ryan/workspace_ccstheia/HW3/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

utils.o: ../utils.s $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/Applications/ti/ccs2030/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/Users/ryan/workspace_ccstheia/HW3" -I"/Users/ryan/workspace_ccstheia/HW3/Debug" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m --language=ti-asm -I"/Users/ryan/workspace_ccstheia/HW3/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

utils_bf.o: ../utils_bf.s $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"/Applications/ti/ccs2030/ccs/tools/compiler/ti-cgt-armllvm_4.0.3.LTS/bin/tiarmclang" -c -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -Oz -I"/Users/ryan/workspace_ccstheia/HW3" -I"/Users/ryan/workspace_ccstheia/HW3/Debug" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/source" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos" -I"/Users/ryan/ti/simplelink_cc13xx_cc26xx_sdk_8_31_00_11/kernel/nortos/posix" -gdwarf-3 -march=armv7e-m --language=ti-asm -I"/Users/ryan/workspace_ccstheia/HW3/Debug/syscfg" $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '


