CFLAGS = -Irecipe-sysroot/usr/include/drm `pkg-config --cflags sdl2 wayland-client wayland-egl`
LDFLAGS += -ldrm -lpng16 -lz -lm -lpthread -lGLESv1_CM -lGLESv2 -lEGL `pkg-config --libs sdl2 wayland-client wayland-egl`

all: drm2png ntpc fbgrab i2c_read_data hello_triangle gles_linux init_window

i2c_read_data: i2c_read_data.o
	$(CC) $@.o -o $@ $(LDFLAGS)

fbgrab: fbgrab.o
	$(CC) $@.o -o $@ $(LDFLAGS)

ntpc: ntpc.o
	$(CC) $@.o -o $@ $(LDFLAGS)

drm2png: drm2png.o
	$(CC) $@.o -o $@ $(LDFLAGS)

init_window: init_window.o
	$(CC) $@.o -o $@ $(LDFLAGS)

gles_linux: gles_linux.o
	$(CC) $@.o -o $@ $(LDFLAGS)

hello_triangle: hello_triangle.o
	$(CXX) $@.o -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o drm2png ntpc fbgrab i2c_read_data
