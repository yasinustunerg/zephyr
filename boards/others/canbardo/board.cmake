# Copyright (c) 2024-2025 Henrik Brix Andersen <henrik@brixandersen.dk>
# SPDX-License-Identifier: Apache-2.0

board_runner_args(jlink "--device=ATSAME70N20B")
board_runner_args(openocd --cmd-post-verify "atsamv gpnvm set 1")

include(${ZEPHYR_BASE}/boards/common/jlink.board.cmake)
include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)
