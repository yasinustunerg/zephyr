/* SPDX-License-Identifier: Apache-2.0 */

#ifdef CONFIG_STATIC_INIT_GNU
	SECTION_PROLOGUE(_CTOR_SECTION_NAME,,)
	{
		/*
		 * The compiler fills the constructor pointers table below,
		 * hence symbol __CTOR_LIST__ must be aligned on word
		 * boundary.  To align with the C++ standard, the first element
		 * of the array contains the number of actual constructors. The
		 * last element is NULL.
		 *
		 * The __CTOR_LIST__ and __CTOR_END__ symbols are always defined
		 * to result in an empty list.
		 * Instead, Zephyr's start-up code uses the __ZEPHYR_CTOR_LIST__ and
		 * __ZEHPYR_CTOR_END__ symbols.
		 * In this way, in native_simulator based targets, the host glibc process
		 * initialization code will not call the constructors before Zephyr loads.
		 */
#ifdef CONFIG_64BIT
		. = ALIGN(8);
		__ZEPHYR_CTOR_LIST__ = .;
		QUAD((__ZEPHYR_CTOR_END__ - __ZEPHYR_CTOR_LIST__) / 8 - 2)
		KEEP(*(SORT_BY_NAME(".ctors*")))
		__CTOR_LIST__ = .;
		QUAD(0)
		__ZEPHYR_CTOR_END__ = .;
		QUAD(0)
		__CTOR_END__ = .;
#else
		. = ALIGN(4);
		__ZEPHYR_CTOR_LIST__ = .;
		LONG((__ZEPHYR_CTOR_END__ - __ZEPHYR_CTOR_LIST__) / 4 - 2)
		KEEP(*(SORT_BY_NAME(".ctors*")))
		__CTOR_LIST__ = .;
		LONG(0)
		__ZEPHYR_CTOR_END__ = .;
		LONG(0)
		__CTOR_END__ = .;
#endif
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	SECTION_PROLOGUE(init_array,,)
	{
		/*
		* Similar to the schenanigans required for the __CTOR_LIST__ and
		* __CTOR_END__ symbols we define __init_array_start and __init_array_end
		* to the same address to define an empty list. This prevents the glibc
		* startup code from calling any global constructors before Zephyr loads.
		*
		* Zephyr's start-up code uses the __zephyr_init_array_start and
		* __zephyr_init_array_end symbols, so these need to be set correctly.
		*/
		. = ALIGN(4);
		__init_array_start = .;
		__init_array_end = .;
		__zephyr_init_array_start = .;
		KEEP(*(SORT_BY_NAME(".init_array*")))
		__zephyr_init_array_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

#elif defined(CONFIG_TOOLCHAIN_SUPPORTS_STATIC_INIT_GNU) && !defined(CONFIG_NATIVE_APPLICATION)
	/*
	 * If the code to invoke constructors is not enabled,
	 * make sure there aren't any in the application
	 */
	SECTION_PROLOGUE(init_array,,)
	{
		KEEP(*(SORT_BY_NAME(".ctors*")))
		KEEP(*(SORT_BY_NAME(".init_array*")))
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	ASSERT (SIZEOF(init_array) == 0,
		"GNU-style constructors required but STATIC_INIT_GNU not enabled")
#endif
