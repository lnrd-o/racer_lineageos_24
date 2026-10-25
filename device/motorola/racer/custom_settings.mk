#
# Custom Tweaks and Overrides for Motorola Edge (racer)
# Hooked into lineage_racer.mk by scripts/03_link_device.sh.
# NOTE: these props are untested starting points; the upstream tree already sets
# most display/audio defaults, so remove any that conflict.
#

# --- Display & Graphics (90Hz OLED) ---
# Enable smooth display / dynamic refresh rate handling
PRODUCT_PROPERTY_OVERRIDES += \
    ro.surface_flinger.has_wide_color_display=true \
    ro.surface_flinger.has_HDR_display=true \
    ro.surface_flinger.use_color_management=true \
    ro.surface_flinger.set_idle_timer_ms=4000 \
    ro.surface_flinger.set_touch_timer_ms=200

# --- Audio Enhancements ---
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.audio.fluence.voicecall=true \
    persist.vendor.audio.fluence.voicerec=false \
    persist.vendor.audio.fluence.speaker=true \
    ro.qc.sdk.audio.fluencetype=fluence

# --- Performance & Responsiveness ---
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.avoid_gfx_accel=false \
    debug.sf.disable_backpressure=1 \
    debug.stagefright.ccodec=4

